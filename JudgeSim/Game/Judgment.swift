import Foundation

enum Verdict: String, Codable, Hashable {
    case guilty, lesser, notGuilty
}

enum JudgmentMode: String, CaseIterable, Codable, Hashable {
    case consolidated, concurrent, consecutive

    var label: String {
        switch self {
        case .consolidated: return "Consolidate for judgment"
        case .concurrent: return "Separate judgments, concurrent"
        case .consecutive: return "Separate judgments, consecutive"
        }
    }
}

enum ProbationDecision: String, CaseIterable, Codable, Hashable {
    case revoke, crv, modify, continueAsIs

    var label: String {
        switch self {
        case .revoke: return "Revoke probation and activate the suspended sentence"
        case .crv: return "Find a violation and order confinement in response to violation (CRV)"
        case .modify: return "Find a violation, modify conditions, and extend probation 12 months"
        case .continueAsIs: return "Continue probation on the same terms"
        }
    }
}

enum PleaKind: String, CaseIterable, Codable, Hashable {
    case guilty, alford, noContest

    var label: String {
        switch self {
        case .guilty: return "Guilty"
        case .alford: return "Guilty (Alford)"
        case .noContest: return "No contest"
        }
    }

    var detail: String {
        switch self {
        case .guilty: return "The defendant admits guilt."
        case .alford: return "The defendant maintains innocence but concedes the State's evidence would likely convict (North Carolina v. Alford)."
        case .noContest: return "The defendant does not contest the charge. Requires the State's consent and the court's approval (G.S. 15A-1011(a)(3))."
        }
    }
}

enum HalftimeRuling: String, CaseIterable, Codable, Hashable {
    case deny, dismiss, lesserOnly

    var label: String {
        switch self {
        case .deny: return "Deny"
        case .dismiss: return "Dismiss"
        case .lesserOnly: return "Lesser only"
        }
    }
}

/// Alternatives to entering an ordinary judgment.
enum SpecialDisposition: String, CaseIterable, Codable, Hashable {
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
struct ProbationConditions: Codable, Hashable {
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
struct FinancialOrders: Codable, Hashable {
    static let courtCosts = 213
    static let supervisionFeePerMonth = 40
    static let communityServiceFee = 250
    static let labFee = 600
    static let appointmentFee = 60

    var fine = 0
    var courtCosts = true
    var restitution = 0
    var attorneyFees = true
    var waiveSupervisionFees = false
}

/// Recommendations attached to an active sentence.
struct ActiveRecommendations: Codable, Hashable {
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
struct SentenceChoice: Codable, Hashable {
    var range: SentenceRangeKind = .presumptive
    /// Months for felonies, days for misdemeanors.
    var minimum = 0
    var disposition: Disposition?
    var probationMonths = 18
    var lifeWithoutParole = false
    /// A term of the judge's own choosing instead of a chart range.
    var customTerm = false
    /// Custom maximum (felonies only). nil uses the statutory formula.
    var customMaximum: Int?
}

/// Everything the judge decided during a case.
struct Rulings: Codable, Hashable {
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
    var customConditions: [String] = []
    var probationDecision: ProbationDecision?
    /// nil: no plea presented or not yet decided. true: accepted. false: rejected.
    var pleaAccepted: Bool?
    var dismissedByPlea: Set<UUID> = []
    var pleaKind: PleaKind = .guilty
    /// The defendant withdrew the plea after the court announced a harsher sentence (G.S. 15A-1024).
    var pleaWithdrawn = false
    /// An activated sentence runs at the expiration of today's sentence instead of concurrently.
    var revocationConsecutive = false
    /// Whether the court counts the point for committing the offense while on supervision. nil follows the notice.
    var countProbationPoint: Bool?
    /// Prior convictions the court found the State did not prove.
    var priorsNotProven: Set<UUID> = []
    /// Rulings on the motion to dismiss at the close of the State's evidence (G.S. 15A-1227).
    var halftime: [UUID: HalftimeRuling] = [:]
    /// Whether the defendant elected to testify.
    var defendantTestifies: Bool?
    /// After a sentence harsher than the plea arrangement: true if the defendant was told and chose to stand on the plea,
    /// false if the court entered it without offering withdrawal.
    var pleaDepartureDisclosed: Bool?

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

enum SentencePosition: String, Codable {
    case below, within, above
}

struct CaseOutcome {
    var sentencePosition: SentencePosition?
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

    static func properStrength(_ c: CourtCase, _ r: Rulings? = nil) -> Int {
        let excluded = Set(c.motions.compactMap { $0.shouldGrant ? $0.targetEvidenceID : nil })
        return strength(c, excluded: excluded) { !$0.shouldSustain } - testimonyWeight(c, r)
    }

    static func ruledStrength(_ c: CourtCase, _ r: Rulings) -> Int {
        strength(c, excluded: r.excludedEvidence(in: c)) { !(r.objections[$0.id] ?? false) } - testimonyWeight(c, r)
    }

    /// The defendant's own testimony helps or hurts the defense depending on how it holds up.
    static func testimonyWeight(_ c: CourtCase, _ r: Rulings?) -> Int {
        guard r?.defendantTestifies == true, let testimony = c.defendantTestimony else { return 0 }
        return testimony.weight
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
        let felonies = c.defendant.priors.filter { $0.ncClass.isFelony && !r.priorsNotProven.contains($0.id) }
            .sorted { $0.year < $1.year }
        return Set(felonies.prefix(3).map(\.id))
    }

    /// The State must give 30 days' notice before relying on the probation point (G.S. 15A-1340.16(a6)).
    static func probationNoticeGiven(_ c: CourtCase) -> Bool {
        c.background?.probationPointNotice ?? true
    }

    static func countsProbationPoint(_ c: CourtCase, _ r: Rulings) -> Bool {
        guard c.defendant.probation != nil else { return false }
        return r.countProbationPoint ?? probationNoticeGiven(c)
    }

    static func priorRecord(_ c: CourtCase, _ r: Rulings) -> PriorRecord {
        let offenses = c.charges.compactMap { charge in r.verdicts[charge.id].flatMap { convictedLaw(charge, $0)?.title } }
        return PriorRecord(priors: c.defendant.priors, onSupervision: countsProbationPoint(c, r),
                           habitualPredicates: habitualPredicates(c, r), excluded: r.priorsNotProven,
                           currentOffenses: offenses)
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

    /// Advanced Supervised Release (G.S. 15A-1340.18): active sentences in the presumptive or mitigated range for
    /// Class D (levels I–III), E (I–IV), F (I–V), and G or H (any level).
    static func asrEligible(_ unit: SentencingUnit, _ r: Rulings) -> Bool {
        let selected = choice(unit, r)
        guard selected.disposition == .active, !selected.lifeWithoutParole, let cell = unit.felonyCell else { return false }
        if selected.customTerm ? selected.minimum > cell.presumptive.high : selected.range == .aggravated { return false }
        switch unit.sentencingClass {
        case .D: return unit.level <= 3
        case .E: return unit.level <= 4
        case .F: return unit.level <= 5
        case .G, .H: return true
        default: return false
        }
    }

    /// Months until ASR release: the bottom of the mitigated range for a presumptive sentence, or 80 percent of a mitigated minimum.
    static func asrReleaseMonths(_ unit: SentencingUnit, choice selected: SentenceChoice) -> Int {
        guard let cell = unit.felonyCell else { return selected.minimum }
        let mitigated = selected.customTerm ? selected.minimum < cell.presumptive.low : selected.range == .mitigated
        if mitigated { return max(1, Int((Double(selected.minimum) * 0.8).rounded(.up))) }
        return min(selected.minimum, cell.mitigated.low)
    }

    static func convictedLaws(_ c: CourtCase, _ r: Rulings) -> [Law] {
        c.charges.compactMap { charge in r.verdicts[charge.id].flatMap { convictedLaw(charge, $0) } }
    }

    /// The judge may continue prayer for judgment in any case; the law limits it for serious felonies (flagged separately).
    static func pjcAvailable(_ c: CourtCase, _ r: Rulings) -> Bool {
        !convictedLaws(c, r).isEmpty
    }

    enum DischargeBasis {
        /// G.S. 90-96: drug possession, no prior felony or drug conviction.
        case drugPossession
        /// G.S. 15A-1341(a4): Class H or I felony or misdemeanor, no prior felony, on joint motion.
        case jointMotion
        case ineligible
    }

    private static let drugWords = ["schedule", "pwisd", "paraphernalia", "cocaine", "drug", "trafficking", "marijuana", "heroin", "fentanyl"]

    static func dischargeBasis(_ c: CourtCase, _ r: Rulings) -> DischargeBasis {
        let laws = convictedLaws(c, r)
        guard !laws.isEmpty else { return .ineligible }
        let priors = c.defendant.priors
        let priorFelony = priors.contains { $0.ncClass.isFelony }
        let priorDrug = priors.contains { prior in drugWords.contains { prior.offense.lowercased().contains($0) } }
        let priorDischarge = priors.contains { $0.sentence.lowercased().contains("conditional discharge") }
        if priorFelony || priorDischarge { return .ineligible }
        let possession = ["possSchedII", "possParaphernalia", "simplePossession"]
        if laws.allSatisfy({ possession.contains($0.id) }) && !priorDrug { return .drugPossession }
        let lowLevel = laws.allSatisfy { law in
            guard let cls = law.ncClass else { return false }
            return !cls.isFelony || cls == .H || cls == .I
        }
        return lowLevel ? .jointMotion : .ineligible
    }

    /// Offered whenever there is a conviction; eligibility is flagged, not enforced.
    static func conditionalDischargeAvailable(_ c: CourtCase, _ r: Rulings) -> Bool {
        !convictedLaws(c, r).isEmpty
    }

    /// How the chosen sentence is harsher than the plea arrangement, if it is.
    static func pleaDeparture(_ c: CourtCase, _ r: Rulings) -> String? {
        guard r.pleaAccepted == true, let kind = c.background?.arrangementKind, kind != "open" else { return nil }
        if r.special != .none { return nil }
        for unit in units(c, r) {
            let selected = choice(unit, r)
            if selected.lifeWithoutParole { return "The arrangement did not contemplate life imprisonment." }
            switch kind {
            case "bottom":
                if let cell = unit.felonyCell, selected.minimum > cell.presumptive.low {
                    return "The State recommended \(cell.presumptive.low) months, the bottom of the presumptive range. You chose \(selected.minimum)."
                }
                if let cell = unit.misdemeanorCell, selected.minimum > max(1, cell.maxDays / 3) {
                    return "The State recommended a sentence at the low end of the range. You chose \(selected.minimum) days."
                }
            case "suspended":
                if selected.disposition == .active {
                    return "The parties recommended a suspended sentence. You chose an active sentence."
                }
            default:
                break
            }
        }
        return nil
    }

    static func appointedCounsel(_ c: CourtCase) -> Bool {
        c.defenseAttorney.contains("Public Defender")
    }

    // MARK: Departures from North Carolina law (informational; never blocks the judge)

    private static let unconstitutionalWords = ["banish", "leave the county", "leave the state", "church", "pray", "bible",
                                                "religio", "steriliz", "vasectomy", "marry", "divorce", "sign that says",
                                                "wear a sign", "shame", "flog", "whip", "public apology on", "no children",
                                                "not have children", "pregnan", "exile"]

    static func conditionLooksUnlawful(_ text: String) -> Bool {
        let lower = text.lowercased()
        return unconstitutionalWords.contains { lower.contains($0) }
    }

    /// Ways the chosen judgment departs from what North Carolina law allows.
    static func legalIssues(_ c: CourtCase, _ r: Rulings) -> [String] {
        var issues: [String] = []
        let convictedUnits = units(c, r)
        guard !convictedUnits.isEmpty else { return [] }

        if r.habitualFound == true && convictedUnits.contains(where: { $0.offenseClass.isFelony }) {
            let proven = c.defendant.priors.filter { $0.ncClass.isFelony && !r.priorsNotProven.contains($0.id) }.count
            if proven < 3 {
                issues.append("Habitual felon status requires three prior felony convictions (G.S. 14-7.1); the record shows \(proven).")
            }
        }

        switch r.special {
        case .prayerForJudgment:
            let barred: [NCClass] = [.A, .B1, .B2, .C, .D, .E]
            if convictedUnits.contains(where: { barred.contains($0.offenseClass) }) {
                issues.append("G.S. 15A-1331.2 does not allow a prayer for judgment continued for a Class A through E felony.")
            }
            if r.money.fine > 0 || !r.customConditions.isEmpty {
                issues.append("Conditions beyond costs and obeying the law (a fine or other orders) turn a PJC into a final judgment.")
            }
        case .conditionalDischarge:
            switch dischargeBasis(c, r) {
            case .drugPossession:
                break
            case .jointMotion:
                if c.background?.stateJoinsDischarge == false {
                    issues.append("A conditional discharge under G.S. 15A-1341(a4) requires a joint motion. The State did not join.")
                }
            case .ineligible:
                issues.append("The defendant is not eligible for a conditional discharge: it requires no prior felony convictions and a Class H or I felony, a misdemeanor, or drug possession (G.S. 90-96, 15A-1341(a4)).")
            }
        case .none:
            for unit in convictedUnits {
                let selected = choice(unit, r)
                let title = unit.counts.count == 1 ? "Count \(unit.counts[0])" : "The consolidated judgment"
                if unit.isMandatoryLife && !selected.lifeWithoutParole {
                    issues.append("\(title): a Class A felony requires life without parole.")
                }
                if selected.lifeWithoutParole && !unit.isMandatoryLife {
                    let allowedLife = unit.sentencingClass == .B1 && unit.level >= 5 && !r.foundAggravating.isEmpty
                    if !allowedLife { issues.append("\(title): life without parole is not an authorized punishment for this offense.") }
                    continue
                }
                if selected.lifeWithoutParole { continue }
                if let cell = unit.felonyCell {
                    if selected.customTerm {
                        let lowest = cell.mitigated.low
                        let highest = cell.aggravated?.high ?? cell.presumptive.high
                        if selected.minimum < lowest || selected.minimum > highest {
                            issues.append("\(title): a minimum of \(selected.minimum) months is outside the \(lowest)–\(highest) months authorized for \(unit.sentencingClass.label) at level \(unit.levelLabel).")
                        }
                        if let custom = selected.customMaximum, custom != StructuredSentencing.maximum(forMinimum: selected.minimum, cls: unit.sentencingClass) {
                            issues.append("\(title): the maximum term must be the statutory maximum that corresponds to the minimum.")
                        }
                    } else {
                        if selected.range == .aggravated && r.foundAggravating.isEmpty {
                            issues.append("\(title): an aggravated-range sentence without any aggravating factor found.")
                        }
                        if selected.range == .mitigated && r.foundMitigating.isEmpty {
                            issues.append("\(title): a mitigated-range sentence without any mitigating factor found.")
                        }
                    }
                    if let disposition = selected.disposition, !cell.dispositions.contains(disposition) {
                        issues.append("\(title): a \(disposition.label) disposition is not authorized in this cell of the punishment chart (allowed: \(cell.dispositionCode)).")
                    }
                } else if let cell = unit.misdemeanorCell {
                    if selected.minimum > cell.maxDays {
                        issues.append("\(title): \(selected.minimum) days exceeds the \(cell.maxDays)-day maximum for this class and level.")
                    }
                    if unit.sentencingClass == .misd3 && c.defendant.priors.count <= 3 && selected.minimum > 0 {
                        issues.append("\(title): with no more than three prior convictions, a Class 3 misdemeanor judgment may consist only of a fine (G.S. 15A-1340.23(d)).")
                    }
                    if let disposition = selected.disposition, !cell.dispositions.contains(disposition) {
                        issues.append("\(title): a \(disposition.label) disposition is not authorized for this class and level (allowed: \(cell.dispositionCode)).")
                    }
                    if let cap = unit.sentencingClass.maxFine, r.money.fine > cap {
                        issues.append("\(title): the fine exceeds the \(SentenceFormat.dollars(cap)) statutory maximum.")
                    }
                }
                if isSuspended(unit, r) && selected.probationMonths > 60 {
                    issues.append("\(title): probation may not exceed five years.")
                }
            }
            if (r.conditions.specialProbationDays > 0 || r.conditions.drugTreatmentCourt) && anySuspended(c, r) && !anyIntermediate(c, r) {
                issues.append("Special probation and Drug Treatment Court are intermediate conditions; a community punishment cannot include them.")
            } else if r.conditions.specialProbationDays > 0 && r.conditions.specialProbationDays > maxSpecialProbationDays(c, r) {
                issues.append("Special probation exceeds one-fourth of the maximum suspended sentence.")
            }
            if anyIntermediate(c, r) && !r.conditions.supervised {
                issues.append("Intermediate punishment requires supervised probation.")
            }
            if r.recommendations.advancedSupervisedRelease && anyActive(c, r) {
                if !convictedUnits.contains(where: { asrEligible($0, r) }) {
                    issues.append("Advanced Supervised Release isn't available for this class, prior record level, or range.")
                } else if c.background?.stateObjectsToASR ?? false {
                    issues.append("Advanced Supervised Release was ordered although the prosecutor objected (G.S. 15A-1340.18(c)).")
                }
            }
            // Consecutive misdemeanors may not exceed twice the maximum for the most serious offense (G.S. 15A-1340.22(a)).
            let misdemeanors = convictedUnits.filter { !$0.isFelony }
            if r.mode == .consecutive && misdemeanors.count > 1 && !convictedUnits.contains(where: { $0.isFelony }) {
                let total = misdemeanors.map { choice($0, r).minimum }.reduce(0, +)
                let cap = 2 * (misdemeanors.compactMap { $0.misdemeanorCell?.maxDays }.max() ?? 0)
                if cap > 0 && total > cap {
                    issues.append("Consecutive misdemeanor sentences total \(total) days, more than twice the \(cap / 2)-day maximum for the most serious offense.")
                }
            }
            // Factors
            let bg = c.background
            if let hidden = bg?.hiddenAggravator, r.foundAggravating.contains(hidden) {
                issues.append("The aggravating factor \"\(hidden)\" was found without the 30 days' written notice the State must give (G.S. 15A-1340.16(a6)).")
            }
            if r.foundAggravating.contains(where: { $0.lowercased().contains("remorse") || $0.lowercased().contains("went to trial") }) {
                issues.append("Lack of remorse or exercising the right to trial is not a proper aggravating factor.")
            }
        }
        if countsProbationPoint(c, r) && !probationNoticeGiven(c) && !convictedUnits.isEmpty {
            issues.append("The probation point was counted although the State did not give 30 days' notice of its intent to prove it (G.S. 15A-1340.16(a6)).")
        }
        if r.money.restitution > 0 {
            let documented = c.background?.restitution ?? 0
            if documented == 0 {
                issues.append("Restitution was ordered with no evidence of the victim's loss in the record.")
            } else if Double(r.money.restitution) > Double(documented) * 1.1 {
                issues.append("Restitution of \(SentenceFormat.dollars(r.money.restitution)) exceeds the \(SentenceFormat.dollars(documented)) supported by the evidence.")
            }
        }
        if r.pleaDepartureDisclosed == false {
            issues.append("The sentence is harsher than the plea arrangement, and the defendant was not told or offered the chance to withdraw the plea (G.S. 15A-1024).")
        }
        if r.pleaAccepted == true && r.pleaKind == .noContest && c.background?.stateConsentsNoContest != true {
            issues.append("A no-contest plea was accepted without the State's consent (G.S. 15A-1011(a)(3)).")
        }
        for condition in r.customConditions where conditionLooksUnlawful(condition) {
            issues.append("The order \"\(condition)\" is likely unconstitutional or not reasonably related to the offense.")
        }
        return issues
    }

    /// Itemized money owed under the judgment.
    static func obligations(_ c: CourtCase, _ r: Rulings) -> [(label: String, amount: Int)] {
        var items: [(label: String, amount: Int)] = []
        if r.money.fine > 0 { items.append(("Fine", r.money.fine)) }
        if r.money.courtCosts { items.append(("Court costs", FinancialOrders.courtCosts)) }
        if r.money.restitution > 0 { items.append(("Restitution", r.money.restitution)) }
        if r.money.attorneyFees && appointedCounsel(c) {
            items.append(("Appointed attorney fees", c.background?.attorneyFeeEstimate ?? 1_500))
            items.append(("Attorney appointment fee", FinancialOrders.appointmentFee))
        }
        if r.money.courtCosts && c.evidence.contains(where: { $0.kind == .forensic && $0.side == .prosecution }) {
            items.append(("State Crime Laboratory fee", FinancialOrders.labFee))
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
        if choice.customTerm, let custom = choice.customMaximum { return max(custom, choice.minimum) }
        return StructuredSentencing.maximum(forMinimum: choice.minimum, cls: unit.sentencingClass)
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
        lines.append(choice.customTerm ? "Term set by the court" : "\(choice.range.label) range")
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
        let proper = properStrength(c, r)
        if !dismissed {
            for charge in c.charges {
                let verdict = r.verdicts[charge.id] ?? .notGuilty
                let plea = r.pleaAccepted == true
                var label: String
                switch verdict {
                case .guilty: label = "Guilty"
                case .lesser: label = "Guilty of \(charge.lesserLaw?.title ?? "lesser offense")"
                case .notGuilty: label = "Not Guilty"
                }
                if r.dismissedByPlea.contains(charge.id) {
                    label = "Dismissed under plea arrangement"
                } else if r.halftime[charge.id] == .dismiss {
                    label = "Dismissed at the close of the State's evidence (G.S. 15A-1227)"
                } else if plea && verdict != .notGuilty {
                    switch r.pleaKind {
                    case .guilty: label += " (plea)"
                    case .alford: label += " (Alford plea)"
                    case .noContest: label = verdict == .lesser ? "No contest to \(charge.lesserLaw?.title ?? "lesser offense")" : "No contest"
                    }
                }
                if verdict != .notGuilty {
                    convicted = true
                    if !plea && !isSupported(verdict, charge: charge, strength: proper) { anyUnsupported = true }
                }
                verdictLines.append(VerdictLine(count: charge.count, chargeTitle: charge.law.title, verdictLabel: label))
            }
        }

        // Judgments
        let bg = c.background
        let plea = r.pleaAccepted == true
        var judgments: [JudgmentEntry] = []
        var newPriors: [PriorConviction] = []
        var activeTerms: [Int] = []
        var activeFelony = false
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
            if let findings = findingsEntry(c, r, units: sentencingUnits) { judgments.append(findings) }
            for (index, unit) in sentencingUnits.enumerated() {
                let selected = choice(unit, r)
                var lines = judgmentLines(for: unit, choice: selected)
                if index > 0 {
                    let first = sentencingUnits[0].counts.first ?? 1
                    let previous = sentencingUnits[index - 1].counts.first ?? 1
                    lines.append(r.mode == .consecutive
                        ? "This sentence shall begin at the expiration of the sentence imposed in Count \(previous)."
                        : "This sentence shall run concurrently with the sentence imposed in Count \(first).")
                }

                var months: Int
                if selected.lifeWithoutParole {
                    life = true
                    months = 0
                } else {
                    months = unit.isFelony ? selected.minimum : Int((Double(selected.minimum) / 30).rounded(.up))
                }
                if selected.lifeWithoutParole || selected.disposition == .active {
                    if r.recommendations.advancedSupervisedRelease && asrEligible(unit, r) {
                        let release = asrReleaseMonths(unit, choice: selected)
                        months = min(months, release)
                        let objection = (bg?.stateObjectsToASR ?? false) ? " over the prosecutor's objection" : ""
                        lines.append("Advanced Supervised Release ordered\(objection): eligible for release after \(release) months upon completing risk-reduction programming (G.S. 15A-1340.18).")
                        newsExtras.append("Advanced Supervised Release could shorten the term if programming is completed.")
                    }
                    activeTerms.append(months)
                    if unit.isFelony { activeFelony = true }
                } else {
                    suspendedTerms.append(months)
                    probationMonths = max(probationMonths, selected.probationMonths)
                    suspendedText.append(termText(for: unit, choice: selected))
                    if unit.isFelony { anyFelonySuspended = true }
                }
                judgments.append(JudgmentEntry(title: unit.title, lines: lines))
            }

            if activeTerms.count > 0 {
                var lines = r.recommendations.lines + (suspendedTerms.isEmpty ? r.customConditions : [])
                if let days = bg?.custodyDays, days > 0 {
                    lines.insert("Credit for \(days) days of pretrial confinement (G.S. 15-196.1).", at: 0)
                }
                if activeFelony {
                    lines.append("Upon release, the defendant will serve a period of post-release supervision (G.S. 15A-1368.2).")
                }
                if !lines.isEmpty { judgments.append(JudgmentEntry(title: "Commitment", lines: lines)) }
            }
            if !suspendedTerms.isEmpty {
                var lines = r.conditions.descriptions(victimName: c.victimName) + r.customConditions
                lines.insert("Regular conditions of probation under G.S. 15A-1343(b) apply.", at: 0)
                if !activeTerms.isEmpty {
                    lines.insert("Probation begins when the defendant is released from the active sentence.", at: 1)
                }
                judgments.append(JudgmentEntry(title: "Conditions of probation", lines: lines))
            }
        } else if special == .prayerForJudgment {
            judgments.append(JudgmentEntry(title: "Prayer for judgment continued",
                                           lines: ["Prayer for judgment is continued. No sentence is imposed.",
                                                   "The finding of guilt remains and will count as a prior conviction."] + r.customConditions))
            newsSentence = "a prayer for judgment continued, with no sentence imposed"
        } else {
            probationMonths = 12
            let basis = dischargeBasis(c, r) == .drugPossession ? "G.S. 90-96" : "G.S. 15A-1341(a4)"
            judgments.append(JudgmentEntry(title: "Conditional discharge (\(basis))",
                                           lines: ["Further proceedings are deferred without entry of judgment.",
                                                   "The defendant is placed on 12 months of supervised probation. On successful completion, the charge will be dismissed."]
                                           + r.conditions.descriptions(victimName: c.victimName).dropFirst() + r.customConditions))
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
        if convicted && c.victimName != nil {
            judgments.append(JudgmentEntry(title: "Victim notification",
                                           lines: ["The District Attorney's victim-witness legal assistant will notify the victim of the judgment and of any release, appeal, or post-conviction hearing (N.C. Const. art. I, § 37)."]))
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
                                                 sentence: sentence, fromThisCourt: true, docket: c.docket))
            }
        }

        let combine: ([Int]) -> Int = { terms in
            r.mode == .consecutive ? terms.reduce(0, +) : (terms.max() ?? 0)
        }
        var custodyMonths = combine(activeTerms)
        if custodyMonths > 0, let days = bg?.custodyDays, days > 0 {
            // Credit for time already served can satisfy the active term entirely (G.S. 15-196.1).
            custodyMonths = max(0, custodyMonths - days / 30)
            if custodyMonths == 0, let index = judgments.firstIndex(where: { $0.title == "Commitment" }) {
                judgments[index] = JudgmentEntry(title: "Commitment",
                                                 lines: judgments[index].lines + ["Pretrial confinement credit satisfies the active term; the defendant is released from custody on this judgment."])
            }
        }
        /// An active term was imposed, even if jail credit has already satisfied it.
        let activeImposed = life || !activeTerms.isEmpty

        // Habitual felon
        var habitualNote: String?
        if c.habitualIndicted {
            if plea, let admitted = bg?.arrangementHabitual {
                habitualNote = admitted
                    ? "Under the plea arrangement, the defendant admitted habitual felon status."
                    : "Under the plea arrangement, the State dismissed the habitual felon indictment."
            } else if !anyFelonyConviction(c, r) {
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
        var continuedProbation: ProbationTerm?
        var revokedMonths = 0
        if let existing = d.probation {
            let credit = (existing.crvCount ?? 0) * 3
            let stacked = r.revocationConsecutive && custodyMonths > 0
            switch r.probationDecision ?? .continueAsIs {
            case .revoke:
                revokedMonths = max(1, existing.activeMonths - credit)
                custodyMonths = stacked ? custodyMonths + revokedMonths : max(custodyMonths, revokedMonths)
                var text = "Probation in \(existing.docket) revoked. The suspended sentence of \(existing.suspendedSentence) is activated"
                if credit > 0 { text += ", with credit for \(credit) months already served in confinement in response to violation" }
                if custodyMonths > revokedMonths || stacked {
                    text += stacked ? ", to begin at the expiration of the sentence imposed today" : ", to run concurrently with the sentence imposed today"
                }
                probationHearing = text + "."
            case .crv:
                let crv = existing.isFelony ? 3 : min(3, max(1, existing.activeMonths - credit))
                custodyMonths = stacked ? custodyMonths + crv : max(custodyMonths, crv)
                var continued = existing
                continued.crvCount = (existing.crvCount ?? 0) + 1
                continuedProbation = continued
                let days = existing.isFelony ? "90-day" : "\(crv * 30)-day"
                probationHearing = "Violation found in \(existing.docket). The defendant is ordered to serve a \(days) period of confinement in response to violation (G.S. 15A-1344(d2)), after which probation resumes."
            case .modify:
                var extended = existing
                extended.ends = Calendar.current.date(byAdding: .month, value: 12, to: existing.ends) ?? existing.ends
                continuedProbation = extended
                probationHearing = "Violation found in \(existing.docket). Probation modified and extended 12 months."
            case .continueAsIs:
                continuedProbation = existing
                probationHearing = r.probationDecision == nil ? nil : "Probation in \(existing.docket) continued on the same terms."
            }
        }

        // New probation from today's judgment, including split sentences that begin after release
        var newProbation = continuedProbation
        if !life && (!suspendedTerms.isEmpty || special == .conditionalDischarge) {
            let start = Calendar.current.date(byAdding: .month, value: custodyMonths, to: date) ?? date
            let ends = Calendar.current.date(byAdding: .month, value: probationMonths, to: start) ?? start
            let fallbackMonths = sentencingUnits.first.flatMap { $0.felonyCell?.presumptive.low } ?? 3
            var term = ProbationTerm(docket: c.docket,
                                     offense: sentencingUnits.first?.law.title ?? principalTitle,
                                     isFelony: anyFelonySuspended || special == .conditionalDischarge,
                                     suspendedSentence: special == .conditionalDischarge ? "conditional discharge (judgment would be entered)" : suspendedText.joined(separator: "; "),
                                     activeMonths: special == .conditionalDischarge ? fallbackMonths : combine(suspendedTerms),
                                     ends: ends, imposedInThisCourt: true,
                                     supervised: k.supervised || special == .conditionalDischarge,
                                     conditions: Array(k.descriptions(victimName: c.victimName).dropFirst()) + r.customConditions,
                                     monthlyObligation: probationMonths > 0 ? totalOwed / probationMonths : 0,
                                     violationRisk: violationRisk, crvCount: 0, treatmentNeed: need)
            if let earlier = continuedProbation {
                term.ends = max(term.ends, earlier.ends)
                term.suspendedSentence += "; also on probation in \(earlier.docket) (\(earlier.suspendedSentence))"
                term.conditions = Array(Set((term.conditions ?? []) + (earlier.conditions ?? []))).sorted()
                term.supervised = (term.supervised ?? true) || (earlier.supervised ?? true)
                term.activeMonths = max(term.activeMonths, earlier.activeMonths)
            }
            newProbation = term
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
        } else if !activeTerms.isEmpty {
            let unitLabel = activeFelony ? "months in prison" : "days in the Hollis County jail"
            // Felony months and misdemeanor days aren't added together; when a felony is active, report the felony terms.
            let activeUnits = sentencingUnits.filter { choice($0, r).disposition == .active && !choice($0, r).lifeWithoutParole }
                .filter { !activeFelony || $0.isFelony }
            let minima = activeUnits.map { choice($0, r).minimum }
            let maxima = activeUnits.map { $0.isFelony ? maximum(for: $0, choice: choice($0, r)) : choice($0, r).minimum }
            if activeUnits.count == 1, let low = minima.first, let high = maxima.first {
                newsSentence = activeFelony ? "\(low) to \(high) \(unitLabel)" : "\(low) \(unitLabel)"
            } else if r.mode == .consecutive {
                let low = minima.reduce(0, +), high = maxima.reduce(0, +)
                newsSentence = activeFelony
                    ? "consecutive sentences totaling \(low) to \(high) months in prison"
                    : "consecutive sentences totaling \(low) days in jail"
            } else {
                let low = minima.max() ?? 0, high = maxima.max() ?? 0
                newsSentence = activeFelony
                    ? "concurrent sentences, the longest \(low) to \(high) months in prison"
                    : "concurrent sentences, the longest \(low) days in jail"
            }
            if !suspendedTerms.isEmpty { newsSentence += ", followed by \(probationMonths) months of probation" }
        } else if probationMonths > 0 {
            newsSentence = "a suspended sentence and \(probationMonths) months of probation"
        }
        if revokedMonths > 0 {
            newsSentence += newsSentence.isEmpty
                ? "an active sentence after probation in an earlier case was revoked"
                : ", and activated a suspended sentence from an earlier case"
        }
        if totalOwed >= 1_000 && convicted {
            newsExtras.append("The judgment includes \(SentenceFormat.dollars(totalOwed)) in fines, fees, costs, and restitution.")
        }

        // Departures from the law draw appeals and attention, but the judgment stands as entered.
        let issues = convicted ? legalIssues(c, r) : []
        var appealScheduled = false
        var appealNotice: String?
        let harsh = activeImposed || custodyMonths > 0
        if !issues.isEmpty {
            var newRelease: Date?
            if harsh, let unit = sentencingUnits.first {
                let lawful = unit.felonyCell?.presumptive.low ?? max(1, (unit.misdemeanorCell?.maxDays ?? 30) / 30)
                newRelease = Calendar.current.date(byAdding: .month, value: unit.isMandatoryLife ? 1_200 : lawful + revokedMonths, to: date)
            }
            if rng.chance(0.9) {
                appealScheduled = true
                let appellant = harsh ? "the defendant" : "the State"
                appealNotice = harsh
                    ? "The defendant gave notice of appeal to the North Carolina Court of Appeals in open court."
                    : "The State gave notice of appeal from the judgment (G.S. 15A-1445(a)(3))."
                pending.append(PendingEvent(due: later(120...300),
                                            news: NewsItem(date: date, kind: .appeal,
                                                           headline: "Appeals court vacates sentence in \(d.name) case",
                                                           body: "On appeal by \(appellant), the North Carolina Court of Appeals vacated the judgment Judge \(judgeLast) entered in \(c.caption) and remanded for resentencing. The court held: " + issues.prefix(2).joined(separator: " "),
                                                           docket: c.docket),
                                            personID: d.personID,
                                            effect: newRelease == nil ? .none : .resentence,
                                            appealReversed: true,
                                            newReleaseDate: newRelease))
            }
            newsExtras.append("Courthouse observers said parts of the sentence appear to depart from North Carolina's sentencing laws.")
            let egregious = issues.contains { $0.contains("unconstitutional") || $0.contains("not an authorized punishment") }
                || (custodyMonths > 0 && sentencingUnits.first.flatMap { $0.felonyCell?.presumptive.high }.map { custodyMonths > $0 * 3 } ?? false)
            if egregious && rng.chance(0.6) {
                pending.append(PendingEvent(due: later(45...150),
                                            news: NewsItem(date: date, kind: .ethics,
                                                           headline: "Judicial Standards Commission reviewing sentence by Judge \(judgeLast)",
                                                           body: "Following complaints about the judgment in \(c.caption), the Judicial Standards Commission has opened a confidential inquiry. The Commission may issue a private letter of caution or a public reprimand, or recommend censure, suspension, or removal to the Supreme Court.",
                                                           docket: c.docket)))
            }
        }

        // Appeal
        if convicted && special != .conditionalDischarge && !appealScheduled {
            let appeals = rng.chance(plea ? 0.1 : (harsh ? 0.7 : 0.3))
            if appeals {
                appealNotice = "The defendant gave notice of appeal to the North Carolina Court of Appeals in open court."
                pending.append(contentsOf: appealEvents(c, r, anyUnsupported: anyUnsupported, proper: proper,
                                                        judgeLast: judgeLast, due: later(150...330), plea: plea,
                                                        retryChance: rng.chance(0.7)))
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
                                            personID: d.personID, effect: .releasePerson, vacatesDocket: c.docket))
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
        let reactions = makeReactions(c, county: county, convicted: convicted, dismissed: dismissed, active: custodyMonths > 0 || activeImposed,
                                      plea: plea ? r.pleaKind : nil, rng: &rng)
        var news = makeNews(c, county: county, judgeLast: judgeLast, date: date, convicted: convicted, dismissed: dismissed,
                            plea: plea ? r.pleaKind : nil, pleaLaw: plea ? sentencingUnits.first?.law : nil,
                            sentence: newsSentence, active: custodyMonths > 0 || activeImposed, reactions: reactions)
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
            appealNotice = "The State gave notice of appeal from the order of dismissal (G.S. 15A-1445(a)(1))."
            pending.append(PendingEvent(due: later(150...300),
                                        news: NewsItem(date: date, kind: .appeal,
                                                       headline: "Court of Appeals reinstates charges against \(d.name)",
                                                       body: "In \(c.caption), the State appealed Judge \(judgeLast)'s dismissal. The Court of Appeals held the delay did not violate the defendant's right to a speedy trial, noting that most of it was attributable to the defense, and remanded the case for trial.",
                                                       docket: c.docket),
                                        retrial: retrialCase(c, r, reinstated: true)))
        }

        var position: SentencePosition?
        if special == .none, let unit = sentencingUnits.first(where: { $0.isFelony }), let cell = unit.felonyCell {
            let selected = choice(unit, r)
            if selected.lifeWithoutParole {
                position = unit.isMandatoryLife ? .within : .above
            } else if selected.minimum < cell.presumptive.low {
                position = .below
            } else if selected.minimum > cell.presumptive.high {
                position = .above
            } else {
                position = .within
            }
        }

        return CaseOutcome(sentencePosition: position, dismissed: dismissed, verdictLines: verdictLines, judgments: judgments,
                           habitualNote: habitualNote, probationHearing: probationHearing, convicted: convicted,
                           custodyMonths: custodyMonths, personStatus: status, releaseDate: releaseDate,
                           newProbation: newProbation, newPriors: newPriors, propensity: propensity,
                           appealNotice: appealNotice, reactions: reactions, news: news, ethicsResult: ethicsResult,
                           pending: pending, appearanceSummary: appearance)
    }

    // MARK: Appeals

    private static func appealEvents(_ c: CourtCase, _ r: Rulings, anyUnsupported: Bool, proper: Int,
                                     judgeLast: String, due: Date, plea: Bool, retryChance: Bool) -> [PendingEvent] {
        let event = appealEvent(c, r, anyUnsupported: anyUnsupported, proper: proper, judgeLast: judgeLast, due: due, plea: plea)
        guard event.appealReversed, event.news.headline.contains("new trial") else { return [event] }
        let followUp = Calendar.current.date(byAdding: .day, value: 75, to: due) ?? due
        if retryChance {
            var retry = PendingEvent(due: followUp,
                                     news: NewsItem(date: followUp, kind: .appeal,
                                                    headline: "District Attorney will retry \(c.defendant.name)",
                                                    body: "Following the Court of Appeals decision in \(c.caption), the District Attorney's office announced it will try the case again. It returns to Judge \(judgeLast)'s courtroom.",
                                                    docket: c.docket),
                                     personID: c.defendant.personID)
            retry.retrial = retrialCase(c, r)
            return [event, retry]
        }
        return [event, PendingEvent(due: followUp,
                                    news: NewsItem(date: followUp, kind: .appeal,
                                                   headline: "No retrial for \(c.defendant.name)",
                                                   body: "The District Attorney's office said it will not retry \(c.caption) after the Court of Appeals ordered a new trial, citing the evidence that remains admissible.",
                                                   docket: c.docket),
                                    personID: c.defendant.personID)]
    }

    /// The case as it would be tried again: erroneously admitted evidence comes out, rulings start fresh.
    static func retrialCase(_ c: CourtCase, _ r: Rulings, reinstated: Bool = false) -> CourtCase {
        var retrial = c
        retrial.id = UUID()
        let wronglyAdmitted = Set(c.motions.compactMap { m in
            m.shouldGrant && !(r.motions[m.id] ?? false) ? m.targetEvidenceID : nil
        })
        retrial.evidence.removeAll { wronglyAdmitted.contains($0.id) }
        retrial.motions.removeAll { $0.shouldGrant && !(r.motions[$0.id] ?? false) }
        retrial.motions.removeAll { $0.kind == .dismissSpeedyTrial }
        retrial.objections.removeAll { $0.shouldSustain && !(r.objections[$0.id] ?? false) }
        retrial.ethics = nil
        retrial.twist = nil
        retrial.mediaAttention = min(3, c.mediaAttention + 1)
        retrial.headline = (reinstated ? "Reinstated: " : "Retrial: ") + c.headline
        retrial.proceduralNotes.insert(reinstated
            ? "The Court of Appeals reversed your speedy-trial dismissal and reinstated the charges. The case is back for trial."
            : "The Court of Appeals ordered a new trial. Evidence it held inadmissible has been excluded, and the earlier verdict carries no weight.", at: 0)
        if var bg = retrial.background {
            bg.arrangementPresented = false
            bg.arrangementTerms = nil
            retrial.background = bg
        }
        return retrial
    }

    private static func appealEvent(_ c: CourtCase, _ r: Rulings, anyUnsupported: Bool, proper: Int,
                                    judgeLast: String, due: Date, plea: Bool) -> PendingEvent {
        let court = "The North Carolina Court of Appeals"
        if plea {
            let pleaLabel = r.pleaKind == .guilty ? "guilty plea" : (r.pleaKind == .alford ? "Alford plea" : "no-contest plea")
            let body = "\(court) dismissed the defendant's appeal in \(c.caption). After a \(pleaLabel), a defendant may appeal only limited sentencing issues (G.S. 15A-1444), and the panel found none preserved. The judgment of Judge \(judgeLast) stands."
            return PendingEvent(due: due,
                                news: NewsItem(date: due, kind: .appeal, headline: "Appeal dismissed in \(c.defendant.name) plea case", body: body, docket: c.docket),
                                personID: c.defendant.personID)
        }
        var errors: [String] = []
        for motion in c.motions where motion.shouldGrant && !(r.motions[motion.id] ?? false) {
            let target = c.evidence(motion.targetEvidenceID)?.title ?? "the evidence"
            errors.append("the trial court erred in denying the motion to suppress \(target.lowercased()). \(motion.appellateNote)")
        }
        for objection in c.objections where objection.shouldSustain && !(r.objections[objection.id] ?? false) && objection.weightIfAdmitted > 0 {
            errors.append("the trial court erred in overruling the defendant's \(objection.grounds.lowercased()) objection. \(objection.appellateNote)")
        }

        let headline: String
        var body: String
        let reversed = anyUnsupported
        if reversed {
            if let first = errors.first {
                headline = "Appeals court orders new trial for \(c.defendant.name)"
                body = "\(court) held that \(first) Because the error was prejudicial, the court vacated the conviction and ordered a new trial."
                body += " The District Attorney's office said it is reviewing whether to retry the case."
            } else {
                headline = "Appeals court vacates conviction of \(c.defendant.name)"
                body = "\(court) held that the State's evidence was insufficient to support the conviction and vacated it. Because the evidence was insufficient, double jeopardy bars a retrial."
            }
        } else if let first = errors.first {
            headline = "Conviction of \(c.defendant.name) upheld despite trial error"
            body = "\(court) concluded that \(first) But in light of the other evidence, the panel found no reasonable possibility of a different result, and held there was no prejudicial error."
        } else {
            headline = "Appeals court finds no error in \(c.defendant.name) conviction"
            body = "\(court) rejected all of the defendant's arguments in \(c.caption) and found no error in Judge \(judgeLast)'s rulings."
        }
        var event = PendingEvent(due: due,
                                 news: NewsItem(date: due, kind: .appeal, headline: headline, body: body, docket: c.docket),
                                 personID: c.defendant.personID,
                                 effect: reversed ? .releasePerson : .none,
                                 appealReversed: reversed)
        if reversed { event.vacatesDocket = c.docket }
        return event
    }

    /// Written findings of aggravating and mitigating factors (form AOC-CR-605).
    static func findingsEntry(_ c: CourtCase, _ r: Rulings, units: [SentencingUnit]) -> JudgmentEntry? {
        guard units.contains(where: { $0.isFelony }) else { return nil }
        guard !r.foundAggravating.isEmpty || !r.foundMitigating.isEmpty else { return nil }
        var lines: [String] = []
        lines += r.foundAggravating.sorted().map { "Aggravating: \($0)" }
        lines += r.foundMitigating.sorted().map { "Mitigating: \($0)" }
        let ranges = units.filter(\.isFelony).map { choice($0, r).range }
        if ranges.contains(.aggravated) {
            lines.append("The court finds that the factors in aggravation outweigh the factors in mitigation and that an aggravated sentence is justified.")
        } else if ranges.contains(.mitigated) {
            lines.append("The court finds that the factors in mitigation outweigh the factors in aggravation and that a mitigated sentence is justified.")
        } else {
            lines.append("The court finds that a sentence within the presumptive range is justified.")
        }
        return JudgmentEntry(title: "Findings of factors (AOC-CR-605)", lines: lines)
    }

    // MARK: Press

    private static func makeReactions(_ c: CourtCase, county: County, convicted: Bool, dismissed: Bool, active: Bool,
                                      plea: PleaKind?, rng: inout SeededRNG) -> [String] {
        let defenseName = c.defenseAttorney.components(separatedBy: ",").first ?? c.defenseAttorney
        let da = "District Attorney \(county.districtAttorney)"
        let dl = c.defendant.lastName
        var lines: [String] = []
        if dismissed {
            lines.append(rng.pick([
                "\(da): \"We're disappointed and reviewing our options for appeal.\"",
                "\(da): \"We disagree with the ruling. Our office will decide in the coming days whether to appeal.\""
            ]))
            lines.append(rng.pick([
                "\(defenseName): \"The Constitution doesn't let the State hold someone in limbo indefinitely.\"",
                "\(defenseName): \"\(dl) waited years for a trial that never came. The court did what the law requires.\""
            ]))
        } else if let plea {
            lines.append(rng.pick([
                "\(da): \"This plea holds \(dl) accountable and spares the witnesses from having to testify.\"",
                "\(da): \"A certain conviction today was worth more than an uncertain verdict tomorrow.\"",
                "\(da): \"We're satisfied with the resolution and grateful to the investigators.\""
            ]))
            lines.append(plea == .alford
                ? "\(defenseName): \"My client still maintains their innocence. This plea was about certainty, not guilt.\""
                : (active
                    ? "\(defenseName): \"My client accepted responsibility. We had hoped the court would give more weight to that.\""
                    : "\(defenseName): \"My client accepted responsibility and has a chance to prove it.\""))
        } else if convicted {
            lines.append(rng.pick([
                "\(da): \"We're grateful to the officers and witnesses who saw this case through.\"",
                "\(da): \"The evidence was clear, and the court followed it.\"",
                "\(da): \"No verdict undoes the harm. But this one says it mattered.\"",
                "\(da): \"Our assistant district attorneys tried this case the right way. We respect the sentence.\""
            ]))
            lines.append(active
                ? rng.pick(["\(defenseName): \"We're disappointed, and we'll be reviewing all of our options.\"",
                            "\(defenseName): \"We believe there were errors at trial, and we intend to raise them on appeal.\"",
                            "\(defenseName): \"This sentence is far more than this case called for.\""])
                : rng.pick(["\(defenseName): \"My client has a chance to put this behind them, and intends to take it.\"",
                            "\(defenseName): \"The court saw a person, not just a file. We're grateful.\""]))
        } else {
            lines.append(rng.pick([
                "\(da): \"We respect the court's decision, though we see the evidence differently.\"",
                "\(da): \"The court has spoken. Our office will continue to stand with victims.\"",
                "\(da): \"We presented the evidence we had. We accept the verdict.\""
            ]))
            lines.append(rng.pick([
                "\(defenseName): \"The court held the State to its burden. That's how it's supposed to work.\"",
                "\(defenseName): \"\(dl) can finally go home.\"",
                "\(defenseName): \"Suspicion isn't proof. Today the system worked.\""
            ]))
        }
        if let victim = c.victimName {
            let family = victim.components(separatedBy: " ").last ?? victim
            let stance = c.background?.victimStance ?? .wantsAccountability
            switch (convicted, active) {
            case (false, _) where c.mood == .wantsConviction || c.mood == .divided || stance == .wantsMaximum:
                lines.append(rng.pick(["A member of the \(family) family, outside the courtroom: \"So that's it? That's justice?\"",
                                       "A relative of \(victim), leaving the courthouse: \"We'll be living with this. \(dl) gets to walk away.\""]))
            case (true, false) where stance == .wantsLeniency:
                lines.append("A member of the \(family) family: \"We asked for mercy, and the judge listened. That's what we wanted.\"")
            case (true, false):
                lines.append(rng.pick(["A member of the \(family) family: \"Probation. I don't know what to say.\"",
                                       "A relative of \(victim): \"We'll be watching to make sure every condition is followed.\""]))
            case (true, true) where stance == .wantsLeniency:
                lines.append("A member of the \(family) family: \"We didn't want this. Prison won't fix anything.\"")
            case (true, true):
                lines.append(rng.pick(["A member of the \(family) family: \"Nothing brings back what we lost. But today someone was held responsible.\"",
                                       "A relative of \(victim): \"It's not enough. It's never going to be enough. But it's something.\""]))
            default:
                break
            }
        }
        return lines
    }

    private static func makeNews(_ c: CourtCase, county: County, judgeLast: String, date: Date, convicted: Bool,
                                 dismissed: Bool, plea: PleaKind?, pleaLaw: Law?, sentence: String, active: Bool,
                                 reactions: [String]) -> NewsItem {
        let d = c.defendant
        let title = c.charges.first?.law.title ?? "charges"
        let headline: String
        var body: String
        if dismissed {
            headline = "Charges against \(d.name) dismissed over trial delays"
            body = "Superior Court Judge \(judgeLast) dismissed the \(title.lowercased()) case against \(d.name), \(d.age), finding the delay in bringing it to trial violated the constitutional right to a speedy trial."
        } else if let plea, convicted {
            let offense = (pleaLaw?.title ?? title).lowercased()
            switch plea {
            case .guilty:
                headline = "\(d.name) pleads guilty to \(offense)"
                body = "\(d.name), \(d.age), pleaded guilty to \(offense) before Judge \(judgeLast) in Hollis County Superior Court"
            case .alford:
                headline = "\(d.name) enters Alford plea to \(offense)"
                body = "\(d.name), \(d.age), entered an Alford plea to \(offense) before Judge \(judgeLast), maintaining innocence while conceding the State's evidence would likely convict"
            case .noContest:
                headline = "\(d.name) pleads no contest to \(offense)"
                body = "\(d.name), \(d.age), pleaded no contest to \(offense) before Judge \(judgeLast) in Hollis County Superior Court"
            }
            body += sentence.isEmpty ? "." : ", and was sentenced to \(sentence)."
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
        return NewsItem(date: date, kind: .verdict, headline: headline, body: body, docket: c.docket,
                        prominence: c.mediaAttention)
    }
}
