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
    case revoke, crv, modify, continueAsIs

    var label: String {
        switch self {
        case .revoke: return "Revoke probation and activate the suspended sentence"
        case .crv: return "Find a violation and order a 90-day period of confinement in response to violation (CRV)"
        case .modify: return "Find a violation, modify conditions, and extend probation 12 months"
        case .continueAsIs: return "Continue probation on the same terms"
        }
    }
}

/// Alternatives to entering an ordinary judgment.
enum SpecialDisposition: String, CaseIterable, Hashable {
    case none, prayerForJudgment, conditionalDischarge

    var label: String {
        switch self {
        case .none: return "Enter judgment"
        case .prayerForJudgment: return "Prayer for judgment continued (PJC)"
        case .conditionalDischarge: return "Conditional discharge (G.S. 90-96)"
        }
    }

    var detail: String {
        switch self {
        case .none: return "Impose sentence under Structured Sentencing."
        case .prayerForJudgment: return "No sentence is imposed and judgment is continued. Costs may be taxed. The conviction still counts on the defendant's record."
        case .conditionalDischarge: return "Defer proceedings and place the defendant on probation. If completed, the charge is dismissed and no conviction is entered."
        }
    }
}

/// Conditions attached to a suspended sentence (G.S. 15A-1343).
struct ProbationConditions: Hashable {
    var supervised = true
    var specialProbationDays = 0
    var houseArrestDays = 0
    var communityServiceHours = 0
    var drugTreatmentCourt = false
    var substanceTreatment = false
    var mentalHealthTreatment = false
    var randomTesting = false
    var abstainAlcohol = false
    var curfew = false
    var noContactVictim = false
    var stayAway = false
    var surrenderFirearms = false
    var maintainEmployment = false
    var education = false
    var angerManagement = false

    var specialCount: Int {
        [specialProbationDays > 0, houseArrestDays > 0, communityServiceHours > 0, drugTreatmentCourt, substanceTreatment,
         mentalHealthTreatment, randomTesting, abstainAlcohol, curfew, noContactVictim, stayAway, surrenderFirearms,
         maintainEmployment, education, angerManagement].filter { $0 }.count
    }

    func descriptions(victimName: String?) -> [String] {
        var lines: [String] = [supervised
            ? "Supervised probation: report as directed, submit to warrantless searches by the probation officer, remain within the jurisdiction."
            : "Unsupervised probation: commit no criminal offense and pay all monetary obligations."]
        if specialProbationDays > 0 { lines.append("Special probation: serve \(specialProbationDays) days in the custody of the Sheriff as a condition of probation.") }
        if houseArrestDays > 0 { lines.append("House arrest with electronic monitoring for \(houseArrestDays) days.") }
        if communityServiceHours > 0 { lines.append("Complete \(communityServiceHours) hours of community service and pay the $250 community service fee.") }
        if drugTreatmentCourt { lines.append("Participate in and complete Hollis County Drug Treatment Court.") }
        if substanceTreatment { lines.append("Obtain a substance abuse assessment through TASC and complete all recommended treatment.") }
        if mentalHealthTreatment { lines.append("Obtain a mental health evaluation and comply with all recommended treatment and medication.") }
        if randomTesting { lines.append("Submit to random drug and alcohol testing.") }
        if abstainAlcohol { lines.append("Abstain from alcohol; may be monitored by continuous alcohol monitoring device.") }
        if curfew { lines.append("Curfew from 9:00 p.m. to 6:00 a.m. unless at verified employment.") }
        if noContactVictim { lines.append("Have no contact, direct or indirect, with \(victimName ?? "the victim") or their family.") }
        if stayAway { lines.append("Stay away from the location of the offense.") }
        if surrenderFirearms { lines.append("Surrender all firearms and possess no firearms during probation.") }
        if maintainEmployment { lines.append("Maintain suitable employment or be enrolled full time in school.") }
        if education { lines.append("Work toward and obtain a high school equivalency (GED/HiSET) diploma.") }
        if angerManagement { lines.append("Complete an anger management or abuser treatment program.") }
        return lines
    }
}

/// Money owed under the judgment.
struct FinancialOrders: Hashable {
    static let courtCosts = 213
    static let supervisionFeePerMonth = 40
    static let communityServiceFee = 250

    var fine = 0
    var courtCosts = true
    var restitution = 0
    var attorneyFees = true
    var waiveSupervisionFees = false
}

/// Recommendations attached to an active sentence.
struct ActiveRecommendations: Hashable {
    var advancedSupervisedRelease = false
    var substanceTreatment = false
    var mentalHealth = false
    var workRelease = false
    var vocational = false

    var lines: [String] {
        var lines: [String] = []
        if substanceTreatment { lines.append("The court recommends substance abuse treatment while in custody.") }
        if mentalHealth { lines.append("The court recommends mental health evaluation and treatment while in custody.") }
        if workRelease { lines.append("The court recommends work release.") }
        if vocational { lines.append("The court recommends vocational and educational programming.") }
        return lines
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
    var special: SpecialDisposition = .none
    var conditions = ProbationConditions()
    var money = FinancialOrders()
    var recommendations = ActiveRecommendations()
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

    static func choice(_ unit: SentencingUnit, _ r: Rulings) -> SentenceChoice {
        r.sentences[unit.id] ?? defaultChoice(for: unit)
    }

    static func isSuspended(_ unit: SentencingUnit, _ r: Rulings) -> Bool {
        let selected = choice(unit, r)
        return !selected.lifeWithoutParole && selected.disposition != nil && selected.disposition != .active
    }

    static func anySuspended(_ c: CourtCase, _ r: Rulings) -> Bool {
        r.special == .conditionalDischarge || units(c, r).contains { isSuspended($0, r) }
    }

    static func anyIntermediate(_ c: CourtCase, _ r: Rulings) -> Bool {
        units(c, r).contains { choice($0, r).disposition == .intermediate }
    }

    static func anyActive(_ c: CourtCase, _ r: Rulings) -> Bool {
        units(c, r).contains { choice($0, r).disposition == .active || choice($0, r).lifeWithoutParole }
    }

    /// Special probation may not exceed one-fourth of the maximum suspended term (G.S. 15A-1351(a)).
    static func maxSpecialProbationDays(_ c: CourtCase, _ r: Rulings) -> Int {
        units(c, r).filter { choice($0, r).disposition == .intermediate }.map { unit in
            let selected = choice(unit, r)
            return unit.isFelony ? maximum(for: unit, choice: selected) * 30 / 4 : selected.minimum / 4
        }.max() ?? 0
    }

    static func probationLength(_ c: CourtCase, _ r: Rulings) -> Int {
        if r.special == .conditionalDischarge { return 12 }
        return units(c, r).filter { isSuspended($0, r) }.map { choice($0, r).probationMonths }.max() ?? 0
    }

    /// Advanced Supervised Release: active Class D–H sentences in the presumptive or mitigated range (G.S. 15A-1340.18).
    static func asrEligible(_ unit: SentencingUnit, _ r: Rulings) -> Bool {
        let selected = choice(unit, r)
        let classes: [NCClass] = [.D, .E, .F, .G, .H]
        return selected.disposition == .active && !selected.lifeWithoutParole && selected.range != .aggravated
            && classes.contains(unit.sentencingClass)
    }

    static func pjcAvailable(_ c: CourtCase, _ r: Rulings) -> Bool {
        let laws = c.charges.compactMap { charge in r.verdicts[charge.id].flatMap { convictedLaw(charge, $0) } }
        return !laws.isEmpty && laws.allSatisfy { !($0.ncClass?.isFelony ?? true) }
    }

    static func conditionalDischargeAvailable(_ c: CourtCase, _ r: Rulings) -> Bool {
        let laws = c.charges.compactMap { charge in r.verdicts[charge.id].flatMap { convictedLaw(charge, $0) } }
        let drugWords = ["schedule", "pwisd", "paraphernalia", "cocaine", "drug", "trafficking"]
        let priorDrug = c.defendant.priors.contains { prior in drugWords.contains { prior.offense.lowercased().contains($0) } }
        return !laws.isEmpty && laws.allSatisfy { $0.id == "possSchedII" } && !priorDrug
    }

    static func appointedCounsel(_ c: CourtCase) -> Bool {
        c.defenseAttorney.contains("Public Defender")
    }

    /// Itemized money owed under the judgment.
    static func obligations(_ c: CourtCase, _ r: Rulings) -> [(label: String, amount: Int)] {
        var items: [(label: String, amount: Int)] = []
        if r.money.fine > 0 { items.append(("Fine", r.money.fine)) }
        if r.money.courtCosts { items.append(("Court costs", FinancialOrders.courtCosts)) }
        if r.money.restitution > 0 { items.append(("Restitution", r.money.restitution)) }
        if r.money.attorneyFees && appointedCounsel(c) {
            items.append(("Appointed attorney fees", c.background?.attorneyFeeEstimate ?? 1_500))
        }
        if r.special == .none && anySuspended(c, r) {
            if r.conditions.supervised && !r.money.waiveSupervisionFees {
                items.append(("Supervision fees ($40/month)", FinancialOrders.supervisionFeePerMonth * probationLength(c, r)))
            }
            if r.conditions.communityServiceHours > 0 {
                items.append(("Community service fee", FinancialOrders.communityServiceFee))
            }
        }
        return items
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
        let bg = c.background
        var judgments: [JudgmentEntry] = []
        var newPriors: [PriorConviction] = []
        var activeTerms: [Int] = []
        var suspendedTerms: [Int] = []
        var probationMonths = 0
        var suspendedText: [String] = []
        var anyFelonySuspended = false
        var life = false
        var newsSentence = ""
        var newsExtras: [String] = []
        let year = Calendar.current.component(.year, from: date)
        let special = convicted ? r.special : .none

        let sentencingUnits = convicted ? units(c, r) : []
        if special == .none {
            for unit in sentencingUnits {
                let selected = choice(unit, r)
                var lines = judgmentLines(for: unit, choice: selected)

                var months: Int
                if selected.lifeWithoutParole {
                    life = true
                    months = 0
                } else {
                    months = unit.isFelony ? selected.minimum : Int((Double(selected.minimum) / 30).rounded(.up))
                }
                if selected.lifeWithoutParole || selected.disposition == .active {
                    if r.recommendations.advancedSupervisedRelease && asrEligible(unit, r), let cell = unit.felonyCell {
                        if bg?.stateObjectsToASR ?? false {
                            lines.append("The State objected to Advanced Supervised Release. ASR is not ordered (G.S. 15A-1340.18).")
                        } else {
                            months = min(months, cell.mitigated.low)
                            lines.append("Advanced Supervised Release ordered: eligible for release after \(cell.mitigated.low) months upon completing risk-reduction programming.")
                            newsExtras.append("Advanced Supervised Release could shorten the term if programming is completed.")
                        }
                    }
                    activeTerms.append(months)
                } else {
                    suspendedTerms.append(months)
                    probationMonths = max(probationMonths, selected.probationMonths)
                    suspendedText.append(termText(for: unit, choice: selected))
                    if unit.isFelony { anyFelonySuspended = true }
                }
                judgments.append(JudgmentEntry(title: unit.title, lines: lines))
            }

            if activeTerms.count > 0 {
                var lines = r.recommendations.lines
                if let days = bg?.custodyDays, days > 0 {
                    lines.insert("Credit for \(days) days of pretrial confinement (G.S. 15-196.1).", at: 0)
                }
                if !lines.isEmpty { judgments.append(JudgmentEntry(title: "Commitment", lines: lines)) }
            }
            if !suspendedTerms.isEmpty {
                var lines = r.conditions.descriptions(victimName: c.victimName)
                lines.insert("Regular conditions of probation under G.S. 15A-1343(b) apply.", at: 0)
                judgments.append(JudgmentEntry(title: "Conditions of probation", lines: lines))
            }
        } else if special == .prayerForJudgment {
            judgments.append(JudgmentEntry(title: "Prayer for judgment continued",
                                           lines: ["Prayer for judgment is continued. No sentence is imposed.",
                                                   "The finding of guilt remains and will count as a prior conviction."]))
            newsSentence = "a prayer for judgment continued, with no sentence imposed"
        } else {
            probationMonths = 12
            judgments.append(JudgmentEntry(title: "Conditional discharge (G.S. 90-96)",
                                           lines: ["Further proceedings are deferred without entry of judgment.",
                                                   "The defendant is placed on 12 months of supervised probation. On successful completion, the charge will be dismissed."]
                                           + r.conditions.descriptions(victimName: c.victimName).dropFirst()))
            newsSentence = "a conditional discharge: if \(d.lastName) completes 12 months of probation, the charge will be dismissed"
        }

        // Money
        let owed = convicted ? obligations(c, r) : []
        let totalOwed = owed.reduce(0) { $0 + $1.amount }
        if !owed.isEmpty {
            var lines = owed.map { "\($0.label): \(SentenceFormat.dollars($0.amount))" }
            lines.append("Total: \(SentenceFormat.dollars(totalOwed))")
            if (bg?.indigent ?? false) && !r.money.courtCosts { lines.append("Costs remitted; the defendant was found indigent.") }
            judgments.append(JudgmentEntry(title: "Monetary obligations", lines: lines))
        }

        // Record entries
        if convicted && special != .conditionalDischarge {
            for charge in c.charges {
                guard let verdict = r.verdicts[charge.id], let law = convictedLaw(charge, verdict), let cls = law.ncClass else { continue }
                let unitForCharge = sentencingUnits.first { $0.counts.contains(charge.count) }
                let sentence: String
                if special == .prayerForJudgment {
                    sentence = "Prayer for judgment continued"
                } else if let unitForCharge {
                    let selected = choice(unitForCharge, r)
                    let suffix = selected.lifeWithoutParole ? "" : (selected.disposition == .active ? " active" : " suspended, \(selected.probationMonths) months probation")
                    sentence = termText(for: unitForCharge, choice: selected) + suffix
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
        if custodyMonths > 0, let days = bg?.custodyDays, days > 0 {
            custodyMonths = max(1, custodyMonths - days / 30)
        }

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

        // How the conditions bear on what happens next
        let truthGuilty = c.truth.actuallyGuilty
        let need = bg?.treatmentNeed ?? TreatmentNeed.none
        let k = r.conditions
        let treatedSubstance = (k.substanceTreatment || k.drugTreatmentCourt) && !suspendedTerms.isEmpty
            || (r.recommendations.substanceTreatment && !activeTerms.isEmpty)
        let treatedMental = (k.mentalHealthTreatment && !suspendedTerms.isEmpty)
            || (r.recommendations.mentalHealth && !activeTerms.isEmpty)

        var propensity = truthGuilty ? 0.42 : 0.1
        if truthGuilty && !convicted { propensity += 0.15 }
        if d.priors.count >= 3 { propensity += 0.1 }
        if d.age > 50 { propensity *= 0.6 }
        if convicted {
            if need.substance { propensity *= treatedSubstance ? 0.7 : 1.15 }
            if need.mentalHealth { propensity *= treatedMental ? 0.75 : 1.1 }
            if k.maintainEmployment && bg?.employmentPlan != nil && !suspendedTerms.isEmpty { propensity *= 0.9 }
            if (k.education && !suspendedTerms.isEmpty) || (r.recommendations.vocational && !activeTerms.isEmpty) { propensity *= 0.93 }
            if k.angerManagement && (c.category == .violent || c.category == .robbery) { propensity *= 0.92 }
        }
        propensity = min(0.8, max(0.03, propensity))

        var violationRisk = 0.12 + Double(k.specialCount) * 0.025 + propensity * 0.2
        if (bg?.indigent ?? false) && totalOwed > 1_500 { violationRisk += 0.12 }
        if need.substance && !treatedSubstance { violationRisk += k.randomTesting ? 0.2 : 0.12 }
        if need.mentalHealth && !treatedMental { violationRisk += 0.08 }
        if k.houseArrestDays > 0 || k.curfew { violationRisk += 0.04 }
        if !k.supervised { violationRisk -= 0.06 }
        violationRisk = min(0.7, max(0.03, violationRisk))

        // Existing probation
        var probationHearing: String?
        var newProbation: ProbationTerm?
        if let existing = d.probation, let decision = r.probationDecision {
            switch decision {
            case .revoke:
                custodyMonths += existing.activeMonths
                probationHearing = "Probation in \(existing.docket) revoked. The suspended sentence of \(existing.suspendedSentence) is activated\(custodyMonths > existing.activeMonths ? ", to run at the expiration of any sentence imposed today" : "")."
            case .crv:
                custodyMonths += 3
                var continued = existing
                continued.crvCount = (existing.crvCount ?? 0) + 1
                newProbation = continued
                probationHearing = "Violation found in \(existing.docket). The defendant is ordered to serve a 90-day period of confinement in response to violation, after which probation resumes."
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

        // New probation from today's judgment
        if !life && (activeTerms.isEmpty) && (!suspendedTerms.isEmpty || special == .conditionalDischarge) {
            let ends = Calendar.current.date(byAdding: .month, value: probationMonths, to: date) ?? date
            let fallbackMonths = sentencingUnits.first.flatMap { $0.felonyCell?.presumptive.low } ?? 3
            newProbation = ProbationTerm(docket: c.docket,
                                         offense: sentencingUnits.first?.law.title ?? principalTitle,
                                         isFelony: anyFelonySuspended || special == .conditionalDischarge,
                                         suspendedSentence: special == .conditionalDischarge ? "conditional discharge (judgment would be entered)" : suspendedText.joined(separator: "; "),
                                         activeMonths: special == .conditionalDischarge ? fallbackMonths : combine(suspendedTerms),
                                         ends: ends, imposedInThisCourt: true,
                                         supervised: k.supervised || special == .conditionalDischarge,
                                         conditions: Array(k.descriptions(victimName: c.victimName).dropFirst()),
                                         monthlyObligation: probationMonths > 0 ? totalOwed / probationMonths : 0,
                                         violationRisk: violationRisk, crvCount: 0, treatmentNeed: need)
            if k.specialProbationDays > 0 {
                newsExtras.append("The sentence includes \(k.specialProbationDays) days in jail as a condition of probation.")
            }
            if k.drugTreatmentCourt { newsExtras.append("The defendant was ordered into Drug Treatment Court.") }
            if k.communityServiceHours > 0 { newsExtras.append("\(k.communityServiceHours) hours of community service were ordered.") }
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
        if special != .none {
            // set above
        } else if life {
            newsSentence = "life in prison without the possibility of parole"
        } else if !activeTerms.isEmpty, let unit = sentencingUnits.first {
            let selected = choice(unit, r)
            newsSentence = unit.isFelony
                ? "\(selected.minimum) to \(maximum(for: unit, choice: selected)) months in prison"
                : "\(selected.minimum) days in the Hollis County jail"
        } else if custodyMonths > 0 {
            newsSentence = "an active sentence after probation in an earlier case was revoked"
        } else if probationMonths > 0 {
            newsSentence = "a suspended sentence and \(probationMonths) months of probation"
        }
        if totalOwed >= 1_000 && convicted {
            newsExtras.append("The judgment includes \(SentenceFormat.dollars(totalOwed)) in fines, fees, costs, and restitution.")
        }

        // Appeal
        var appealNotice: String?
        if convicted && special != .conditionalDischarge {
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

        // The local paper
        let reactions = makeReactions(c, county: county, convicted: convicted, dismissed: dismissed, active: custodyMonths > 0 || life)
        var news = makeNews(c, county: county, judgeLast: judgeLast, date: date, convicted: convicted, dismissed: dismissed,
                            sentence: newsSentence, active: custodyMonths > 0 || life, reactions: reactions)
        if !newsExtras.isEmpty { news.body += " " + newsExtras.joined(separator: " ") }

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
