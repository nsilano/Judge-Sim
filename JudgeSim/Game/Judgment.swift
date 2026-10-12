import Foundation

enum Verdict: String, Codable, Hashable {
    case guilty, lesser, notGuilty
}

enum JudgmentMode: String, CaseIterable, Hashable {
    case consolidated, concurrent, consecutive

    var label: String {
        switch self {
        case .consolidated: return "Consolidate for judgment"
        case .concurrent: return "Separate judgments, concurrent"
        case .consecutive: return "Separate judgments, consecutive"
        }
    }
}

enum ProbationDecision: String, CaseIterable, Hashable {
    case revoke, modify, continueAsIs

    var label: String {
        switch self {
        case .revoke: return "Revoke probation and activate the suspended sentence"
        case .modify: return "Find a violation, modify conditions, and extend probation 12 months"
        case .continueAsIs: return "Continue probation on the same terms"
        }
    }
}

/// One sentence entry: felony months or misdemeanor days, plus disposition.
struct SentenceChoice: Hashable {
    var range: SentenceRangeKind = .presumptive
    /// Months for felonies, days for misdemeanors.
    var minimum = 0
    var disposition: Disposition?
    var probationMonths = 18
    var lifeWithoutParole = false
}

/// Everything the judge decided during a case.
struct Rulings {
    var motions: [UUID: Bool] = [:]
    var objections: [UUID: Bool] = [:]
    var verdicts: [UUID: Verdict] = [:]
    var ethicsChoice: UUID?
    var habitualFound: Bool?
    var foundAggravating: Set<String> = []
    var foundMitigating: Set<String> = []
    var mode: JudgmentMode = .consolidated
    var sentences: [UUID: SentenceChoice] = [:]
    var fine = 0
    var probationDecision: ProbationDecision?

    func excludedEvidence(in courtCase: CourtCase) -> Set<UUID> {
        Set(courtCase.motions.compactMap { motion in
            (motions[motion.id] ?? false) ? motion.targetEvidenceID : nil
        })
    }
}

/// A single judgment to be sentenced: one count, or several consolidated counts.
struct SentencingUnit: Identifiable, Hashable {
    let id: UUID
    let counts: [Int]
    let law: Law
    let offenseClass: NCClass
    let sentencingClass: NCClass
    let level: Int

    var isFelony: Bool { sentencingClass.isFelony }
    var isMandatoryLife: Bool { sentencingClass == .A }
    var felonyCell: FelonyCell? { StructuredSentencing.felonyCell(sentencingClass, level: level) }
    var misdemeanorCell: MisdemeanorCell? { StructuredSentencing.misdemeanorCell(sentencingClass, level: level) }
    var levelLabel: String { SentenceFormat.romanLevels[max(0, min(5, level - 1))] }

    var title: String {
        let countText = counts.count == 1 ? "Count \(counts[0])" : "Counts " + counts.map(String.init).joined(separator: ", ") + " (consolidated)"
        return "\(countText): \(law.title)"
    }

    var classLine: String {
        var text = isFelony
            ? "\(sentencingClass.label), prior record level \(levelLabel)"
            : "\(sentencingClass.label), prior conviction level \(levelLabel)"
        if sentencingClass != offenseClass {
            text += " (habitual felon; offense is \(offenseClass.shortLabel))"
        }
        return text
    }
}

struct VerdictLine: Identifiable, Hashable {
    let id = UUID()
    let count: Int
    let chargeTitle: String
    let verdictLabel: String
}

struct JudgmentEntry: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let lines: [String]
}

struct CaseOutcome {
    var dismissed: Bool
    var verdictLines: [VerdictLine]
    var judgments: [JudgmentEntry]
    var habitualNote: String?
    var probationHearing: String?
    var convicted: Bool
    var custodyMonths: Int
    var personStatus: PersonRecord.Status
    var releaseDate: Date?
    var newProbation: ProbationTerm?
    var newPriors: [PriorConviction]
    var propensity: Double
    var appealNotice: String?
    var reactions: [String]
    var news: NewsItem
    var ethicsResult: String?
    var pending: [PendingEvent]
    var appearanceSummary: String
}

enum Judgment {

    // MARK: Case strength (internal; used for appellate review and the hidden truth)

    static func strength(_ c: CourtCase, excluded: Set<UUID>, admitted: (Objection) -> Bool) -> Int {
        var s = 0
        for e in c.evidence where !excluded.contains(e.id) {
            s += e.side == .prosecution ? e.weight : -e.weight
        }
        for w in c.witnesses {
            s += w.calledBy == .prosecution ? w.weight : -w.weight
        }
        for o in c.objections where admitted(o) {
            s += o.weightIfAdmitted
        }
        return s
    }

    static func properStrength(_ c: CourtCase) -> Int {
        let excluded = Set(c.motions.compactMap { $0.shouldGrant ? $0.targetEvidenceID : nil })
        return strength(c, excluded: excluded) { !$0.shouldSustain }
    }

    static func ruledStrength(_ c: CourtCase, _ r: Rulings) -> Int {
        strength(c, excluded: r.excludedEvidence(in: c)) { !(r.objections[$0.id] ?? false) }
    }

    /// Whether a conviction would survive appellate sufficiency review.
    static func isSupported(_ verdict: Verdict, charge: Charge, strength s: Int) -> Bool {
        switch verdict {
        case .guilty: return s >= charge.threshold - 1
        case .lesser: return s >= charge.lesserThreshold - 1
        case .notGuilty: return true
        }
    }

    // MARK: Sentencing structure

    static func convictedLaw(_ charge: Charge, _ verdict: Verdict) -> Law? {
        switch verdict {
        case .guilty: return charge.law
        case .lesser: return charge.lesserLaw
        case .notGuilty: return nil
        }
    }

    static func habitualPredicates(_ c: CourtCase, _ r: Rulings) -> Set<UUID> {
        guard r.habitualFound == true else { return [] }
        let felonies = c.defendant.priors.filter { $0.ncClass.isFelony }.sorted { $0.year < $1.year }
        return Set(felonies.prefix(3).map(\.id))
    }

    static func priorRecord(_ c: CourtCase, _ r: Rulings) -> PriorRecord {
        PriorRecord(priors: c.defendant.priors, onSupervision: c.defendant.probation != nil,
                    habitualPredicates: habitualPredicates(c, r))
    }

    static func anyFelonyConviction(_ c: CourtCase, _ r: Rulings) -> Bool {
        c.charges.contains { charge in
            guard let verdict = r.verdicts[charge.id], let law = convictedLaw(charge, verdict) else { return false }
            return law.ncClass?.isFelony ?? false
        }
    }

    static func units(_ c: CourtCase, _ r: Rulings) -> [SentencingUnit] {
        let record = priorRecord(c, r)
        var items: [(charge: Charge, law: Law, offense: NCClass, sentencing: NCClass)] = []
        for charge in c.charges {
            guard let verdict = r.verdicts[charge.id],
                  let law = convictedLaw(charge, verdict),
                  let cls = law.ncClass else { continue }
            let sentencingClass = (r.habitualFound == true && cls.isFelony) ? StructuredSentencing.habitualClass(for: cls) : cls
            items.append((charge, law, cls, sentencingClass))
        }
        items.sort { $0.sentencing.severity < $1.sentencing.severity }

        func unit(_ item: (charge: Charge, law: Law, offense: NCClass, sentencing: NCClass), counts: [Int]) -> SentencingUnit {
            SentencingUnit(id: item.charge.id, counts: counts, law: item.law, offenseClass: item.offense,
                           sentencingClass: item.sentencing,
                           level: item.sentencing.isFelony ? record.felonyLevel : record.misdemeanorLevel)
        }

        guard let principal = items.first else { return [] }
        if r.mode == .consolidated || items.count == 1 {
            return [unit(principal, counts: items.map { $0.charge.count }.sorted())]
        }
        return items.map { unit($0, counts: [$0.charge.count]) }
    }

    static func defaultChoice(for unit: SentencingUnit) -> SentenceChoice {
        var choice = SentenceChoice()
        if unit.isMandatoryLife {
            choice.lifeWithoutParole = true
            choice.disposition = .active
        } else if let cell = unit.felonyCell {
            choice.minimum = cell.presumptive.low
            choice.disposition = cell.dispositions.count == 1 ? cell.dispositions[0] : nil
            choice.probationMonths = 24
        } else if let cell = unit.misdemeanorCell {
            choice.minimum = max(1, cell.maxDays / 2)
            choice.disposition = cell.dispositions.count == 1 ? cell.dispositions[0] : nil
            choice.probationMonths = 12
        }
        return choice
    }

    static func isComplete(_ choice: SentenceChoice) -> Bool {
        choice.lifeWithoutParole || choice.disposition != nil
    }

    static func maximum(for unit: SentencingUnit, choice: SentenceChoice) -> Int {
        StructuredSentencing.maximum(forMinimum: choice.minimum, cls: unit.sentencingClass)
    }

    /// Short description, e.g. "59 to 83 months, active".
    static func termText(for unit: SentencingUnit, choice: SentenceChoice) -> String {
        if choice.lifeWithoutParole { return "Life imprisonment without parole" }
        if unit.isFelony {
            return "\(choice.minimum) to \(maximum(for: unit, choice: choice)) months"
        }
        return "\(choice.minimum) days"
    }

    static func judgmentLines(for unit: SentencingUnit, choice: SentenceChoice) -> [String] {
        var lines = [unit.classLine]
        if choice.lifeWithoutParole {
            lines.append("Life imprisonment without parole. Committed to the custody of the N.C. Department of Adult Correction.")
            return lines
        }
        lines.append("\(choice.range.label) range")
        let term = termText(for: unit, choice: choice)
        switch choice.disposition {
        case .active?:
            lines.append(unit.isFelony
                ? "Minimum \(choice.minimum), maximum \(maximum(for: unit, choice: choice)) months. Active: committed to the custody of the N.C. Department of Adult Correction."
                : "\(choice.minimum) days. Active: committed to the custody of the Hollis County Sheriff.")
        case let disposition?:
            lines.append("\(term), suspended. \(disposition.label) punishment: \(choice.probationMonths) months of \(disposition == .community ? "probation" : "supervised probation").")
        case nil:
            break
        }
        return lines
    }

    // MARK: Entering judgment

    static func evaluate(_ c: CourtCase, _ r: Rulings, judgeName: String, county: County, date: Date) -> CaseOutcome {
        var rng = SeededRNG(seed: c.seed ^ 0xD0C4E7)
        let judgeLast = judgeName.components(separatedBy: " ").last ?? judgeName
        let d = c.defendant
        var pending: [PendingEvent] = []

        func later(_ days: ClosedRange<Int>) -> Date {
            Calendar.current.date(byAdding: .day, value: rng.int(days), to: date) ?? date
        }

        // Ethics consequences
        var ethicsResult: String?
        if let ethics = c.ethics, let choiceID = r.ethicsChoice,
           let choice = ethics.options.first(where: { $0.id == choiceID }) {
            ethicsResult = choice.result
            if let headline = choice.laterHeadline {
                pending.append(PendingEvent(due: later(30...120),
                                            news: NewsItem(date: date, kind: .ethics, headline: headline,
                                                           body: "The matter arose during \(c.caption), \(c.docket).",
                                                           docket: c.docket)))
            }
        }

        let dismissed = c.motions.contains { $0.kind == .dismissSpeedyTrial && (r.motions[$0.id] ?? false) }
        let principalTitle = c.charges.first?.law.title ?? "the charges"

        var verdictLines: [VerdictLine] = []
        var convicted = false
        var anyUnsupported = false
        let proper = properStrength(c)
        if !dismissed {
            for charge in c.charges {
                let verdict = r.verdicts[charge.id] ?? .notGuilty
                let label: String
                switch verdict {
                case .guilty: label = "Guilty"
                case .lesser: label = "Guilty of \(charge.lesserLaw?.title ?? "lesser offense")"
                case .notGuilty: label = "Not Guilty"
                }
                if verdict != .notGuilty {
                    convicted = true
                    if !isSupported(verdict, charge: charge, strength: proper) { anyUnsupported = true }
                }
                verdictLines.append(VerdictLine(count: charge.count, chargeTitle: charge.law.title, verdictLabel: label))
            }
        }

        // Judgments
        var judgments: [JudgmentEntry] = []
        var newPriors: [PriorConviction] = []
        var activeTerms: [Int] = []
        var suspendedTerms: [Int] = []
        var probationMonths = 0
        var suspendedText: [String] = []
        var anyFelonySuspended = false
        var life = false
        var newsSentence = ""
        let year = Calendar.current.component(.year, from: date)

        let sentencingUnits = convicted ? units(c, r) : []
        for unit in sentencingUnits {
            let choice = r.sentences[unit.id] ?? defaultChoice(for: unit)
            var lines = judgmentLines(for: unit, choice: choice)
            if unit.id == sentencingUnits.first?.id && r.fine > 0 {
                lines.append("Fine: \(SentenceFormat.dollars(r.fine)), plus costs.")
            }
            judgments.append(JudgmentEntry(title: unit.title, lines: lines))

            let months: Int
            if choice.lifeWithoutParole {
                life = true
                months = 0
            } else {
                months = unit.isFelony ? choice.minimum : Int((Double(choice.minimum) / 30).rounded(.up))
            }
            if choice.lifeWithoutParole || choice.disposition == .active {
                activeTerms.append(months)
            } else {
                suspendedTerms.append(months)
                probationMonths = max(probationMonths, choice.probationMonths)
                suspendedText.append(termText(for: unit, choice: choice))
                if unit.isFelony { anyFelonySuspended = true }
            }
        }
        if convicted {
            for charge in c.charges {
                guard let verdict = r.verdicts[charge.id], let law = convictedLaw(charge, verdict), let cls = law.ncClass else { continue }
                let unitForCharge = sentencingUnits.first { $0.counts.contains(charge.count) }
                let choice = unitForCharge.flatMap { r.sentences[$0.id] }
                let sentence: String
                if let unitForCharge, let choice {
                    let suffix = choice.lifeWithoutParole ? "" : (choice.disposition == .active ? " active" : " suspended, \(choice.probationMonths) months probation")
                    sentence = termText(for: unitForCharge, choice: choice) + suffix
                } else {
                    sentence = "Consolidated"
                }
                newPriors.append(PriorConviction(offense: law.title, ncClass: cls, year: year, county: county.name,
                                                 sentence: sentence, fromThisCourt: true))
            }
        }

        let combine: ([Int]) -> Int = { terms in
            r.mode == .consecutive ? terms.reduce(0, +) : (terms.max() ?? 0)
        }
        var custodyMonths = combine(activeTerms)

        // Habitual felon
        var habitualNote: String?
        if c.habitualIndicted {
            if !anyFelonyConviction(c, r) {
                habitualNote = "Habitual felon status was not reached because there was no felony conviction."
            } else if r.habitualFound == true {
                habitualNote = "The court found that the defendant has attained the status of habitual felon."
            } else {
                habitualNote = "The court found the State did not prove habitual felon status."
            }
        }

        // Existing probation
        var probationHearing: String?
        var newProbation: ProbationTerm?
        if let existing = d.probation, let decision = r.probationDecision {
            switch decision {
            case .revoke:
                custodyMonths += existing.activeMonths
                probationHearing = "Probation in \(existing.docket) revoked. The suspended sentence of \(existing.suspendedSentence) is activated\(custodyMonths > existing.activeMonths ? ", to run at the expiration of any sentence imposed today" : "")."
            case .modify:
                var extended = existing
                extended.ends = Calendar.current.date(byAdding: .month, value: 12, to: existing.ends) ?? existing.ends
                newProbation = extended
                probationHearing = "Violation found in \(existing.docket). Probation modified and extended 12 months."
            case .continueAsIs:
                newProbation = existing
                probationHearing = "Probation in \(existing.docket) continued on the same terms."
            }
        }

        // New probation from today's judgment (if nothing active)
        if !life && custodyMonths == 0 && !suspendedTerms.isEmpty {
            let ends = Calendar.current.date(byAdding: .month, value: probationMonths, to: date) ?? date
            newProbation = ProbationTerm(docket: c.docket, offense: sentencingUnits.first?.law.title ?? principalTitle,
                                         isFelony: anyFelonySuspended,
                                         suspendedSentence: suspendedText.joined(separator: "; "),
                                         activeMonths: combine(suspendedTerms), ends: ends, imposedInThisCourt: true)
        }

        let status: PersonRecord.Status
        var releaseDate: Date?
        if life {
            status = .incarcerated
            releaseDate = .distantFuture
        } else if custodyMonths > 0 {
            status = .incarcerated
            releaseDate = Calendar.current.date(byAdding: .month, value: custodyMonths, to: date)
        } else if newProbation != nil {
            status = .probation
        } else {
            status = .free
        }

        // News summary of the sentence
        if life {
            newsSentence = "life in prison without the possibility of parole"
        } else if custodyMonths > 0, let unit = sentencingUnits.first, let choice = r.sentences[unit.id], choice.disposition == .active {
            newsSentence = unit.isFelony
                ? "\(choice.minimum) to \(maximum(for: unit, choice: choice)) months in prison"
                : "\(choice.minimum) days in the Hollis County jail"
        } else if custodyMonths > 0 {
            newsSentence = "an active sentence after probation in an earlier case was revoked"
        } else if probationMonths > 0 {
            newsSentence = "a suspended sentence and \(probationMonths) months of probation"
        }

        // Appeal
        var appealNotice: String?
        if convicted {
            let appeals = rng.chance(custodyMonths > 0 || life ? 0.7 : 0.3)
            if appeals {
                appealNotice = life
                    ? "The defendant gave notice of appeal to the Supreme Court of North Carolina in open court."
                    : "The defendant gave notice of appeal to the North Carolina Court of Appeals in open court."
                pending.append(appealEvent(c, r, anyUnsupported: anyUnsupported, proper: proper,
                                           judgeLast: judgeLast, due: later(150...330), life: life))
            }
        }

        // Things that may surface about what really happened
        let truthGuilty = c.truth.actuallyGuilty
        switch (convicted, truthGuilty) {
        case (true, false):
            if rng.chance(0.55) {
                pending.append(PendingEvent(due: later(240...900),
                                            news: NewsItem(date: date, kind: .exoneration,
                                                           headline: "New evidence in \(d.name) case",
                                                           body: c.truth.revelation + " The North Carolina Innocence Inquiry Commission has referred the case to a three-judge panel, which declared \(d.name) innocent.",
                                                           docket: c.docket),
                                            personID: d.personID, effect: .releasePerson))
            }
        case (false, true):
            if rng.chance(0.35) {
                pending.append(PendingEvent(due: later(60...400),
                                            news: NewsItem(date: date, kind: .revelation,
                                                           headline: "Questions resurface in \(dismissed ? "dismissed" : "acquitted") \(principalTitle.lowercased()) case",
                                                           body: c.truth.revelation,
                                                           docket: c.docket),
                                            personID: d.personID, effect: .raisePropensity))
            }
        case (true, true):
            if rng.chance(0.25) {
                pending.append(PendingEvent(due: later(120...700),
                                            news: NewsItem(date: date, kind: .revelation,
                                                           headline: "Update in the \(d.lastName) case",
                                                           body: c.truth.revelation, docket: c.docket)))
            }
        case (false, false):
            if rng.chance(0.3) {
                pending.append(PendingEvent(due: later(60...500),
                                            news: NewsItem(date: date, kind: .revelation,
                                                           headline: "Another name emerges in \(principalTitle.lowercased()) case",
                                                           body: c.truth.revelation, docket: c.docket)))
            }
        }

        // Likelihood of returning to court
        var propensity = truthGuilty ? 0.42 : 0.1
        if truthGuilty && !convicted { propensity += 0.15 }
        if d.priors.count >= 3 { propensity += 0.1 }
        if d.age > 50 { propensity *= 0.6 }
        propensity = min(0.8, max(0.03, propensity))

        // The local paper
        let reactions = makeReactions(c, county: county, convicted: convicted, dismissed: dismissed, active: custodyMonths > 0 || life)
        let news = makeNews(c, county: county, judgeLast: judgeLast, date: date, convicted: convicted, dismissed: dismissed,
                            sentence: newsSentence, active: custodyMonths > 0 || life, reactions: reactions)

        let appearance: String
        if dismissed {
            appearance = "Dismissed (speedy trial)"
        } else if convicted {
            appearance = verdictLines.map { "Ct. \($0.count) \($0.verdictLabel)" }.joined(separator: "; ") + (newsSentence.isEmpty ? "" : ". \(newsSentence.capitalizedFirst)")
        } else {
            appearance = "Not guilty on all counts"
        }

        if dismissed && c.motions.contains(where: { $0.kind == .dismissSpeedyTrial && !$0.shouldGrant }) && rng.chance(0.6) {
            pending.append(PendingEvent(due: later(150...300),
                                        news: NewsItem(date: date, kind: .appeal,
                                                       headline: "Court of Appeals reinstates charges against \(d.name)",
                                                       body: "In \(c.caption), the State appealed Judge \(judgeLast)'s dismissal. The Court of Appeals held the delay did not violate the defendant's right to a speedy trial, noting that most of it was attributable to the defense, and remanded the case for trial.",
                                                       docket: c.docket)))
        }

        return CaseOutcome(dismissed: dismissed, verdictLines: verdictLines, judgments: judgments,
                           habitualNote: habitualNote, probationHearing: probationHearing, convicted: convicted,
                           custodyMonths: custodyMonths, personStatus: status, releaseDate: releaseDate,
                           newProbation: newProbation, newPriors: newPriors, propensity: propensity,
                           appealNotice: appealNotice, reactions: reactions, news: news, ethicsResult: ethicsResult,
                           pending: pending, appearanceSummary: appearance)
    }

    // MARK: Appeals

    private static func appealEvent(_ c: CourtCase, _ r: Rulings, anyUnsupported: Bool, proper: Int,
                                    judgeLast: String, due: Date, life: Bool) -> PendingEvent {
        var errors: [String] = []
        for motion in c.motions where motion.shouldGrant && !(r.motions[motion.id] ?? false) {
            let target = c.evidence(motion.targetEvidenceID)?.title ?? "the evidence"
            errors.append("the trial court erred in denying the motion to suppress \(target.lowercased()). \(motion.appellateNote)")
        }
        for objection in c.objections where objection.shouldSustain && !(r.objections[objection.id] ?? false) && objection.weightIfAdmitted > 0 {
            errors.append("the trial court erred in overruling the defendant's \(objection.grounds.lowercased()) objection. \(objection.appellateNote)")
        }

        let court = life ? "The Supreme Court of North Carolina" : "The North Carolina Court of Appeals"
        let headline: String
        var body: String
        let reversed = anyUnsupported
        if reversed {
            headline = "Appeals court orders new trial for \(c.defendant.name)"
            if let first = errors.first {
                body = "\(court) held that \(first) Because the error was prejudicial, the court vacated the conviction and ordered a new trial."
            } else {
                body = "\(court) held that the State's evidence was insufficient to support the conviction and vacated it."
            }
            body += " The District Attorney's office said it is reviewing whether to retry the case."
        } else if let first = errors.first {
            headline = "Conviction of \(c.defendant.name) upheld despite trial error"
            body = "\(court) concluded that \(first) But in light of the other evidence, the panel found no reasonable possibility of a different result, and held there was no prejudicial error."
        } else {
            headline = "Appeals court finds no error in \(c.defendant.name) conviction"
            body = "\(court) rejected all of the defendant's arguments in \(c.caption) and found no error in Judge \(judgeLast)'s rulings."
        }
        return PendingEvent(due: due,
                            news: NewsItem(date: due, kind: .appeal, headline: headline, body: body, docket: c.docket),
                            personID: c.defendant.personID,
                            effect: reversed ? .releasePerson : .none,
                            appealReversed: reversed)
    }

    // MARK: Press

    private static func makeReactions(_ c: CourtCase, county: County, convicted: Bool, dismissed: Bool, active: Bool) -> [String] {
        let defenseName = c.defenseAttorney.components(separatedBy: ",").first ?? c.defenseAttorney
        var lines: [String] = []
        if dismissed {
            lines.append("District Attorney \(county.districtAttorney): \"We're disappointed and reviewing our options for appeal.\"")
            lines.append("\(defenseName): \"The Constitution doesn't let the State hold someone in limbo indefinitely.\"")
        } else if convicted {
            lines.append("District Attorney \(county.districtAttorney): \"We're grateful to the officers and witnesses who saw this case through.\"")
            lines.append(active
                ? "\(defenseName): \"We're disappointed, and we'll be reviewing all of our options.\""
                : "\(defenseName): \"My client has a chance to put this behind them, and intends to take it.\"")
        } else {
            lines.append("District Attorney \(county.districtAttorney): \"We respect the court's decision, though we see the evidence differently.\"")
            lines.append("\(defenseName): \"The court held the State to its burden. That's how it's supposed to work.\"")
        }
        if let victim = c.victimName {
            let family = victim.components(separatedBy: " ").last ?? victim
            switch (c.mood, convicted) {
            case (.wantsConviction, false), (.divided, false):
                lines.append("A member of the \(family) family, outside the courtroom: \"So that's it? That's justice?\"")
            case (_, true) where !active:
                lines.append("A member of the \(family) family: \"Probation. I don't know what to say.\"")
            case (_, true):
                lines.append("A member of the \(family) family: \"Nothing brings back what we lost. But today someone was held responsible.\"")
            default:
                break
            }
        }
        return lines
    }

    private static func makeNews(_ c: CourtCase, county: County, judgeLast: String, date: Date, convicted: Bool,
                                 dismissed: Bool, sentence: String, active: Bool, reactions: [String]) -> NewsItem {
        let d = c.defendant
        let title = c.charges.first?.law.title ?? "charges"
        let headline: String
        var body: String
        if dismissed {
            headline = "Charges against \(d.name) dismissed over trial delays"
            body = "Superior Court Judge \(judgeLast) dismissed the \(title.lowercased()) case against \(d.name), \(d.age), finding the delay in bringing it to trial violated the constitutional right to a speedy trial."
        } else if convicted {
            headline = "\(d.name) convicted in \(title.lowercased()) case"
            body = "Following a bench trial in Hollis County Superior Court, Judge \(judgeLast) found \(d.name), \(d.age), guilty"
            body += sentence.isEmpty ? "." : " and imposed \(sentence)."
        } else {
            headline = "\(d.name) found not guilty of \(title.lowercased())"
            body = "Judge \(judgeLast) acquitted \(d.name), \(d.age), after a bench trial in Hollis County Superior Court."
        }
        if d.isReturning {
            body += " It was not \(d.lastName)'s first appearance in Judge \(judgeLast)'s courtroom."
        }
        switch (c.mood, convicted) {
        case (.wantsConviction, false):
            body += " The verdict drew angry reactions from the gallery."
        case (.wantsConviction, true) where !active:
            body += " Some in the community questioned whether the sentence was enough."
        case (.sympathetic, true) where active:
            body += " Several supporters wept as deputies led the defendant away."
        case (.sympathetic, false):
            body += " Supporters cheered outside the courthouse."
        case (.divided, _):
            body += " Reaction outside the courthouse was split."
        default:
            break
        }
        if let quote = reactions.first {
            body += " " + quote
        }
        return NewsItem(date: date, kind: .verdict, headline: headline, body: body, docket: c.docket)
    }
}
