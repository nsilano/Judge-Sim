import Foundation

enum Verdict: String, Codable, Hashable {
    case guilty, lesser, notGuilty
    /// Dismissed for insufficient evidence (G.S. 15A-1227): the State's proof fails as a matter of law, whatever the
    /// judge would find as fact-finder. Like a not-guilty verdict, it ends the case and bars a retrial.
    case dismissed
    /// Not guilty by reason of insanity (G.S. 15A-1237); the defendant is committed for evaluation and treatment.
    case insanity

    var isConviction: Bool { self == .guilty || self == .lesser }
}

enum PostReleaseDecision: String, CaseIterable, Codable, Hashable {
    case revoke, confine, continueAsIs

    var label: String {
        switch self {
        case .revoke: return "Revoke post-release supervision; return to prison for the rest of the sentence"
        case .confine: return "Find a violation; three months' confinement, then supervision resumes"
        case .continueAsIs: return "Continue post-release supervision"
        }
    }
}

enum JudgmentMode: String, CaseIterable, Codable, Hashable {
    case consolidated, concurrent, consecutive, grouped

    var label: String {
        switch self {
        case .grouped: return "Group counts into separate judgments"
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
        case .modify: return "Find a violation, modify conditions, and extend probation"
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
    /// With an active term: probation that begins on release (optional for older saves).
    var probationAfterActive: Bool?
    /// With probation after an active term: how much of the term (months for felonies, days for misdemeanors)
    /// is served before release onto probation. nil serves all of it.
    var servedBeforeProbation: Int?
    /// Impaired driving only: the punishment level under G.S. 20-179 (0 is Level A1, then 1 through 5).
    var dwiLevel: Int?

    /// The part of the active term actually served before release.
    var servedTerm: Int {
        guard probationAfterActive == true, let served = servedBeforeProbation else { return minimum }
        return min(max(0, served), minimum)
    }
    /// The part of the term suspended when the court releases early onto probation.
    var suspendedBalance: Int { minimum - servedTerm }
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
    /// The court denied a party's motion to continue and went forward (nil: none made or not yet ruled on).
    var continuanceMotionDenied: Bool?
    /// Years of a stay-away order protecting the victim, entered with the judgment (0: none).
    var stayAwayYears = 0
    /// With grouped judgments: which judgment each convicted count belongs to (1, 2, 3...).
    var groups: [UUID: Int] = [:]
    /// With grouped judgments: whether the judgments run one after another.
    var groupsConsecutive = false
    /// With grouped judgments: each judgment's own choice to run after the one before it (optional for older saves).
    var unitConsecutive: [UUID: Bool]?
    /// Counts on which the court arrested judgment at sentencing, after a bench conference.
    var arrestedCounts: Set<UUID> = []
    /// Length of probation under a conditional discharge (nil: 12 months).
    var dischargeMonths: Int?
    /// How long a modified probation is extended after a violation (nil: 12 months).
    var extensionMonths: Int?
    /// What the court did about the defendant's post-release supervision.
    var postReleaseDecision: PostReleaseDecision?
    /// The lesser-included offense the court chose for each count, when it differs from the one the case came with.
    var lesserChoices: [UUID: String]?

    /// Whether separate judgments run one after another.
    var runsConsecutively: Bool {
        mode == .consecutive || (mode == .grouped && (groupsConsecutive || (unitConsecutive ?? [:]).values.contains(true)))
    }

    /// Whether the judgment at this position runs after the one before it. With grouped judgments the court
    /// decides each one; otherwise the mode decides for all.
    func consecutive(_ unitID: UUID, index: Int) -> Bool {
        guard index > 0 else { return false }
        if mode == .grouped, let choice = unitConsecutive?[unitID] { return choice }
        return mode == .consecutive || (mode == .grouped && groupsConsecutive)
    }

    func excludedEvidence(in courtCase: CourtCase) -> Set<UUID> {
        Set(courtCase.motions.compactMap { motion in
            (motions[motion.id] ?? false) ? motion.targetEvidenceID : nil
        })
    }
}

extension Rulings {
    /// Rulings are saved inside a continued trial's snapshot. Fields added since then decode as their defaults,
    /// so an older save still loads.
    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        motions = try c.decodeIfPresent([UUID: Bool].self, forKey: .motions) ?? motions
        objections = try c.decodeIfPresent([UUID: Bool].self, forKey: .objections) ?? objections
        verdicts = try c.decodeIfPresent([UUID: Verdict].self, forKey: .verdicts) ?? verdicts
        ethicsChoice = try c.decodeIfPresent(UUID.self, forKey: .ethicsChoice)
        habitualFound = try c.decodeIfPresent(Bool.self, forKey: .habitualFound)
        foundAggravating = try c.decodeIfPresent(Set<String>.self, forKey: .foundAggravating) ?? foundAggravating
        foundMitigating = try c.decodeIfPresent(Set<String>.self, forKey: .foundMitigating) ?? foundMitigating
        mode = try c.decodeIfPresent(JudgmentMode.self, forKey: .mode) ?? mode
        sentences = try c.decodeIfPresent([UUID: SentenceChoice].self, forKey: .sentences) ?? sentences
        special = try c.decodeIfPresent(SpecialDisposition.self, forKey: .special) ?? special
        conditions = try c.decodeIfPresent(ProbationConditions.self, forKey: .conditions) ?? conditions
        money = try c.decodeIfPresent(FinancialOrders.self, forKey: .money) ?? money
        recommendations = try c.decodeIfPresent(ActiveRecommendations.self, forKey: .recommendations) ?? recommendations
        customConditions = try c.decodeIfPresent([String].self, forKey: .customConditions) ?? customConditions
        probationDecision = try c.decodeIfPresent(ProbationDecision.self, forKey: .probationDecision)
        pleaAccepted = try c.decodeIfPresent(Bool.self, forKey: .pleaAccepted)
        dismissedByPlea = try c.decodeIfPresent(Set<UUID>.self, forKey: .dismissedByPlea) ?? dismissedByPlea
        pleaKind = try c.decodeIfPresent(PleaKind.self, forKey: .pleaKind) ?? pleaKind
        pleaWithdrawn = try c.decodeIfPresent(Bool.self, forKey: .pleaWithdrawn) ?? pleaWithdrawn
        revocationConsecutive = try c.decodeIfPresent(Bool.self, forKey: .revocationConsecutive) ?? revocationConsecutive
        countProbationPoint = try c.decodeIfPresent(Bool.self, forKey: .countProbationPoint)
        priorsNotProven = try c.decodeIfPresent(Set<UUID>.self, forKey: .priorsNotProven) ?? priorsNotProven
        halftime = try c.decodeIfPresent([UUID: HalftimeRuling].self, forKey: .halftime) ?? halftime
        defendantTestifies = try c.decodeIfPresent(Bool.self, forKey: .defendantTestifies)
        pleaDepartureDisclosed = try c.decodeIfPresent(Bool.self, forKey: .pleaDepartureDisclosed)
        continuanceMotionDenied = try c.decodeIfPresent(Bool.self, forKey: .continuanceMotionDenied)
        groups = try c.decodeIfPresent([UUID: Int].self, forKey: .groups) ?? groups
        stayAwayYears = try c.decodeIfPresent(Int.self, forKey: .stayAwayYears) ?? stayAwayYears
        groupsConsecutive = try c.decodeIfPresent(Bool.self, forKey: .groupsConsecutive) ?? groupsConsecutive
        unitConsecutive = try c.decodeIfPresent([UUID: Bool].self, forKey: .unitConsecutive)
        arrestedCounts = try c.decodeIfPresent(Set<UUID>.self, forKey: .arrestedCounts) ?? arrestedCounts
        dischargeMonths = try c.decodeIfPresent(Int.self, forKey: .dischargeMonths)
        extensionMonths = try c.decodeIfPresent(Int.self, forKey: .extensionMonths)
        postReleaseDecision = try c.decodeIfPresent(PostReleaseDecision.self, forKey: .postReleaseDecision)
        lesserChoices = try c.decodeIfPresent([UUID: String].self, forKey: .lesserChoices)
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
    /// Impaired driving, sentenced by level under G.S. 20-179 instead of Structured Sentencing.
    var isDWI = false

    var isFelony: Bool { sentencingClass.isFelony }
    var isMandatoryLife: Bool { sentencingClass == .A }
    var felonyCell: FelonyCell? { isDWI ? nil : StructuredSentencing.felonyCell(sentencingClass, level: level) }
    var misdemeanorCell: MisdemeanorCell? { isDWI ? nil : StructuredSentencing.misdemeanorCell(sentencingClass, level: level) }
    var levelLabel: String { SentenceFormat.romanLevels[max(0, min(5, level - 1))] }

    var title: String {
        let countText = counts.count == 1 ? "Count \(counts[0])" : "Counts " + counts.map(String.init).joined(separator: ", ") + " (consolidated)"
        return "\(countText): \(law.title)"
    }

    var classLine: String {
        if isDWI { return "Impaired driving: sentenced by level under G.S. 20-179, not Structured Sentencing" }
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
    /// How the release date was figured, for the person's status card.
    var releaseBasis: String? = nil
    /// Post-release supervision that carries on after this case (nil when revoked or none).
    var continuedPostRelease: PostReleaseTerm? = nil
    /// Post-release supervision that will follow today's prison term.
    var newPostRelease: PostReleaseTerm? = nil
    /// Supervision violations the court found in this case.
    var violations: [SupervisionViolation] = []
    /// Each contested ruling, with how an appellate court would see it.
    var rulingNotes: [RulingNote] = []
    /// What the appellant says the court got wrong, strongest arguments first.
    var appealGrounds: [String] = []
    /// For each ground: whether the ruling really was wrong (never shown until the appeal is decided).
    var appealGroundErrors: [Bool] = []
    /// A stay-away order protecting the victim, entered with the judgment.
    var stayAwayOrder: StayAwayOrder? = nil
}

/// One ruling the judge made at trial and what the law says about it, shown once judgment is entered.
struct RulingNote: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var yourRuling: String
    var proper: String
    var sound: Bool
    var note: String
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
        let silent = r?.defendantTestifies != true
        return strength(c, excluded: excluded) { !$0.shouldSustain && !(silent && isDefendantTestimony($0, c)) } - testimonyWeight(c, r)
    }

    static func ruledStrength(_ c: CourtCase, _ r: Rulings) -> Int {
        let silent = r.defendantTestifies != true
        return strength(c, excluded: r.excludedEvidence(in: c)) { !(r.objections[$0.id] ?? false) && !(silent && isDefendantTestimony($0, c)) }
            - testimonyWeight(c, r)
    }

    /// An objection during the defendant's own testimony, which only exists if the defendant takes the stand.
    static func isDefendantTestimony(_ o: Objection, _ c: CourtCase) -> Bool {
        guard let testimony = c.defendantTestimony else { return false }
        return o.witnessID == testimony.id
    }

    /// The defendant's own testimony helps or hurts the defense depending on how it holds up.
    static func testimonyWeight(_ c: CourtCase, _ r: Rulings?) -> Int {
        guard r?.defendantTestifies == true, let testimony = c.defendantTestimony else { return 0 }
        return testimony.weight
    }

    /// What an appellate court weighs on sufficiency review: only the State's properly admitted evidence, taken in the
    /// light most favorable to the State. Defense evidence and the defendant's own testimony are left out, and so is
    /// State evidence that should have been suppressed or excluded (that error is reviewed for prejudice instead).
    static func stateStrength(_ c: CourtCase) -> Int {
        let excluded = Set(c.motions.compactMap { $0.shouldGrant ? $0.targetEvidenceID : nil })
        var s = 0
        for e in c.evidence where e.side == .prosecution && !excluded.contains(e.id) {
            s += e.weight
        }
        for w in c.witnesses where w.calledBy == .prosecution {
            s += w.weight
        }
        // Testimony the defense objected to, properly admitted, is part of the State's case.
        for o in c.objections where o.raisedBy == .defense && !o.shouldSustain && !isDefendantTestimony(o, c) {
            s += max(0, o.weightIfAdmitted)
        }
        return s
    }

    /// Whether a conviction would survive appellate sufficiency review.
    static func isSupported(_ verdict: Verdict, charge: Charge, strength s: Int) -> Bool {
        switch verdict {
        case .guilty: return s >= charge.threshold - 1
        case .lesser: return s >= charge.lesserThreshold - 1
        case .notGuilty, .dismissed, .insanity: return true
        }
    }

    // MARK: Sentencing structure

    static func convictedLaw(_ charge: Charge, _ verdict: Verdict) -> Law? {
        switch verdict {
        case .guilty: return charge.law
        case .lesser: return charge.lesserLaw
        case .notGuilty, .dismissed, .insanity: return nil
        }
    }

    static func habitualPredicates(_ c: CourtCase, _ r: Rulings) -> Set<UUID> {
        guard r.habitualFound == true else { return [] }
        let felonies = c.defendant.priors.filter { $0.ncClass.isFelony && !r.priorsNotProven.contains($0.id) }
            .sorted { $0.year < $1.year }
        // One felony per session of court: convictions entered together count once (G.S. 14-7.1).
        var seen = Set<String>()
        let distinct = felonies.filter { seen.insert(sessionOf($0)).inserted }
        return Set(distinct.prefix(3).map(\.id))
    }

    /// The session a prior conviction came from: its recorded session, or its year and county.
    static func sessionOf(_ p: PriorConviction) -> String {
        p.sessionKey ?? p.docket ?? "\(p.year)-\(p.county)-\(p.id)"
    }

    /// Prior felonies that count separately toward habitual felon status.
    static func distinctFelonySessions(_ priors: [PriorConviction]) -> Int {
        Set(priors.filter { $0.ncClass.isFelony }.map(sessionOf)).count
    }

    /// The State must give 30 days' notice before relying on the probation point (G.S. 15A-1340.16(a6)).
    static func probationNoticeGiven(_ c: CourtCase) -> Bool {
        c.background?.probationPointNotice ?? true
    }

    static func countsProbationPoint(_ c: CourtCase, _ r: Rulings) -> Bool {
        guard c.defendant.underSupervision else { return false }
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
        for charge in c.charges where !r.arrestedCounts.contains(charge.id) {
            guard let verdict = r.verdicts[charge.id],
                  let law = convictedLaw(charge, verdict),
                  let cls = law.ncClass ?? (isDWI(law) ? NCClass.misd1 : nil) else { continue }
            let sentencingClass = (r.habitualFound == true && cls.isFelony) ? StructuredSentencing.habitualClass(for: cls) : cls
            items.append((charge, law, cls, sentencingClass))
        }
        items.sort { $0.sentencing.severity < $1.sentencing.severity }

        func unit(_ item: (charge: Charge, law: Law, offense: NCClass, sentencing: NCClass), counts: [Int]) -> SentencingUnit {
            SentencingUnit(id: item.charge.id, counts: counts, law: item.law, offenseClass: item.offense,
                           sentencingClass: item.sentencing,
                           level: item.sentencing.isFelony ? record.felonyLevel : record.misdemeanorLevel,
                           isDWI: isDWI(item.law))
        }

        guard let principal = items.first else { return [] }
        if r.mode == .grouped && items.count > 1 {
            // Each judgment is sentenced on its most serious count; the order of judgments follows seriousness.
            var order: [Int] = []
            var members: [Int: [(charge: Charge, law: Law, offense: NCClass, sentencing: NCClass)]] = [:]
            for item in items {
                let group = r.groups[item.charge.id] ?? 1
                if members[group] == nil { order.append(group) }
                members[group, default: []].append(item)
            }
            return order.compactMap { group in
                guard let list = members[group], let lead = list.first else { return nil }
                return unit(lead, counts: list.map { $0.charge.count }.sorted())
            }
        }
        if r.mode == .consolidated || items.count == 1 {
            return [unit(principal, counts: items.map { $0.charge.count }.sorted())]
        }
        return items.map { unit($0, counts: [$0.charge.count]) }
    }

    /// Impaired driving is punished by level under G.S. 20-179, outside Structured Sentencing. For prior record
    /// purposes it counts as a Class 1 misdemeanor (G.S. 15A-1340.14(b)(5)).
    static func isDWI(_ law: Law) -> Bool { law.id == "dwi" }

    /// The G.S. 20-179 level chosen for an impaired-driving judgment, if any.
    static func dwiLevel(_ choice: SentenceChoice) -> StructuredSentencing.DWILevel? {
        guard let index = choice.dwiLevel, StructuredSentencing.dwiLevels.indices.contains(index) else { return nil }
        return StructuredSentencing.dwiLevels[index]
    }

    /// The most a misdemeanor or impaired-driving judgment may impose, in days.
    static func maxDays(for unit: SentencingUnit, choice: SentenceChoice) -> Int? {
        if unit.isDWI { return dwiLevel(choice)?.maxDays }
        return unit.misdemeanorCell?.maxDays
    }

    /// The starting misdemeanor term: the low end of the authorized range (one-third of the maximum).
    /// A plea arrangement for "the low end" is measured against the same figure.
    static func misdemeanorLowEnd(_ cell: MisdemeanorCell) -> Int { max(1, cell.maxDays / 3) }

    /// The most the court may order served before release onto probation on a split sentence: special probation
    /// may not exceed one-fourth of the maximum term (G.S. 15A-1351(a)). Months for felonies, days otherwise.
    static func specialProbationLimit(_ unit: SentencingUnit, choice: SentenceChoice) -> Int {
        unit.isFelony ? maximum(for: unit, choice: choice) / 4 : choice.minimum / 4
    }

    /// Life without parole was imposed on some judgment today.
    static func lifeImposed(_ c: CourtCase, _ r: Rulings) -> Bool {
        r.special == .none && units(c, r).contains { choice($0, r).lifeWithoutParole }
    }

    /// Convictions entered in this court in the same calendar week share a key: only the most serious one counts
    /// toward a later prior record level (G.S. 15A-1340.14(d)).
    static func sessionKey(county: County, date: Date) -> String {
        let parts = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "\(county.name) Superior Court, week \(parts.weekOfYear ?? 0) of \(parts.yearForWeekOfYear ?? 0)"
    }

    static func defaultChoice(for unit: SentencingUnit) -> SentenceChoice {
        var choice = SentenceChoice()
        if unit.isDWI {
            // The judge picks the level first; the term and disposition follow from it.
            choice.probationMonths = 12
            return choice
        }
        if unit.isMandatoryLife {
            choice.lifeWithoutParole = true
            choice.disposition = .active
        } else if let cell = unit.felonyCell {
            choice.minimum = cell.presumptive.low
            choice.disposition = cell.dispositions.count == 1 ? cell.dispositions[0] : nil
            choice.probationMonths = 24
        } else if let cell = unit.misdemeanorCell {
            // A Class 3 misdemeanor with few priors is punished by a fine only (G.S. 15A-1340.23(d)).
            choice.minimum = unit.sentencingClass == .misd3 && unit.level <= 2 ? 0 : misdemeanorLowEnd(cell)
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

    /// The judgment puts the defendant on probation: a suspended term, or probation ordered to follow an active one.
    static func hasProbation(_ unit: SentencingUnit, _ r: Rulings) -> Bool {
        let selected = choice(unit, r)
        return isSuspended(unit, r) || (!selected.lifeWithoutParole && selected.disposition == .active && selected.probationAfterActive == true)
    }

    static func anySuspended(_ c: CourtCase, _ r: Rulings) -> Bool {
        r.special == .conditionalDischarge || units(c, r).contains { hasProbation($0, r) }
    }

    static func anyIntermediate(_ c: CourtCase, _ r: Rulings) -> Bool {
        units(c, r).contains { choice($0, r).disposition == .intermediate }
    }

    static func anyActive(_ c: CourtCase, _ r: Rulings) -> Bool {
        units(c, r).contains { choice($0, r).disposition == .active || choice($0, r).lifeWithoutParole }
    }

    /// Special probation may not exceed one-fourth of the maximum suspended term (G.S. 15A-1351(a)).
    static func maxSpecialProbationDays(_ c: CourtCase, _ r: Rulings) -> Int {
        units(c, r).filter { choice($0, r).disposition == .intermediate || (dwiSuspended($0, r)) }.map { unit in
            let selected = choice(unit, r)
            if unit.isDWI {
                // G.S. 20-179 requires jail as a condition of suspending the higher levels.
                return max(StructuredSentencing.dwiJailIfSuspended(level: selected.dwiLevel ?? 5, term: selected.minimum), selected.minimum / 4)
            }
            return unit.isFelony ? maximum(for: unit, choice: selected) * 30 / 4 : selected.minimum / 4
        }.max() ?? 0
    }

    /// An impaired-driving term the court suspended.
    static func dwiSuspended(_ unit: SentencingUnit, _ r: Rulings) -> Bool {
        unit.isDWI && isSuspended(unit, r)
    }

    static func probationLength(_ c: CourtCase, _ r: Rulings) -> Int {
        if r.special == .conditionalDischarge { return r.dischargeMonths ?? 12 }
        return units(c, r).filter { hasProbation($0, r) }.map { choice($0, r).probationMonths }.max() ?? 0
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
        // Not for a Class A through E felony (G.S. 15A-1331.2), and never for impaired driving (G.S. 20-179).
        let barred: [NCClass] = [.A, .B1, .B2, .C, .D, .E]
        let convicted = units(c, r)
        return !convictedLaws(c, r).isEmpty && !convicted.contains { barred.contains($0.offenseClass) || $0.isDWI }
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
                if let cell = unit.misdemeanorCell, selected.minimum > misdemeanorLowEnd(cell) {
                    return "The State recommended \(misdemeanorLowEnd(cell)) days, the low end of the range. You chose \(selected.minimum) days."
                }
            case "suspended":
                if selected.disposition == .active {
                    let allowed = unit.felonyCell?.dispositions ?? unit.misdemeanorCell?.dispositions ?? [.community, .active]
                    if !allowed.contains(.community) && !allowed.contains(.intermediate) {
                        // The court can't follow an unlawful recommendation, but the defendant must still be told.
                        return "The parties recommended a suspended sentence, but the punishment chart allows only an active sentence for \(unit.sentencingClass.label) at level \(unit.levelLabel), so an active sentence is the only lawful choice. It still differs from what the defendant agreed to."
                    }
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

    /// One way the chosen judgment departs from North Carolina law.
    struct LegalIssue: Hashable {
        let text: String
        /// True when the departure hurts the defendant (the defendant would appeal); false when it is too lenient (only the State could complain).
        let againstDefendant: Bool
        /// True when fixing it changes the length of the custody term.
        let affectsTerm: Bool
    }

    /// Ways the chosen judgment departs from what North Carolina law allows.
    static func legalIssues(_ c: CourtCase, _ r: Rulings) -> [String] {
        legalIssueDetails(c, r).map(\.text)
    }

    /// Departures from the law only; choices the statutes leave to the judge's discretion are never listed.
    static func legalIssueDetails(_ c: CourtCase, _ r: Rulings) -> [LegalIssue] {
        var issues: [LegalIssue] = []
        func add(_ text: String, against: Bool, term: Bool = false) {
            issues.append(LegalIssue(text: text, againstDefendant: against, affectsTerm: term))
        }
        let convictedUnits = units(c, r)
        guard !convictedUnits.isEmpty else { return [] }
        let provenPriors = c.defendant.priors.filter { !r.priorsNotProven.contains($0.id) }
        for charge in c.charges where r.arrestedCounts.contains(charge.id) && !BenchConference.stateConsents(c, r, charge: charge)
            && !BenchConference.merges(c, r, charge: charge) {
            add("Judgment arrested on Count \(charge.count) over the State's objection, without a merger or other legal basis.", against: false, term: true)
        }

        if r.habitualFound == true && convictedUnits.contains(where: { $0.offenseClass.isFelony }) {
            let proven = distinctFelonySessions(provenPriors)
            if proven < 3 {
                add("Habitual felon status requires three prior felony convictions from separate sessions of court (G.S. 14-7.1); the record shows \(proven).", against: true, term: true)
            }
        }

        switch r.special {
        case .prayerForJudgment:
            let barred: [NCClass] = [.A, .B1, .B2, .C, .D, .E]
            if convictedUnits.contains(where: { barred.contains($0.offenseClass) }) {
                add("G.S. 15A-1331.2 does not allow a prayer for judgment continued for a Class A through E felony.", against: false)
            }
            if convictedUnits.contains(where: \.isDWI) {
                add("Impaired driving can't be resolved by a prayer for judgment continued; the court must sentence under G.S. 20-179.", against: false)
            }
        case .conditionalDischarge:
            switch dischargeBasis(c, r) {
            case .drugPossession:
                break
            case .jointMotion:
                if c.background?.stateJoinsDischarge == false {
                    add("A conditional discharge under G.S. 15A-1341(a4) requires a joint motion. The State did not join.", against: false)
                }
            case .ineligible:
                add("The defendant is not eligible for a conditional discharge: it requires no prior felony convictions and a Class H or I felony, a misdemeanor, or drug possession (G.S. 90-96, 15A-1341(a4)).", against: false)
            }
        case .none:
            for unit in convictedUnits {
                let selected = choice(unit, r)
                let title = unit.counts.count == 1 ? "Count \(unit.counts[0])" : "The consolidated judgment"
                if unit.isMandatoryLife && !selected.lifeWithoutParole {
                    add("\(title): a Class A felony requires life without parole.", against: false, term: true)
                }
                if selected.lifeWithoutParole && !unit.isMandatoryLife {
                    let allowedLife = unit.sentencingClass == .B1 && unit.level >= 5 && !r.foundAggravating.isEmpty
                    if !allowedLife { add("\(title): life without parole is not an authorized punishment for this offense.", against: true, term: true) }
                    continue
                }
                if selected.lifeWithoutParole { continue }
                if let cell = unit.felonyCell {
                    if selected.customTerm {
                        let lowest = cell.mitigated.low
                        let highest = cell.aggravated?.high ?? cell.presumptive.high
                        if selected.minimum < lowest {
                            add("\(title): a minimum of \(selected.minimum) months is below the \(lowest)–\(highest) months authorized for \(unit.sentencingClass.label) at level \(unit.levelLabel).", against: false, term: true)
                        } else if selected.minimum > highest {
                            add("\(title): a minimum of \(selected.minimum) months is above the \(lowest)–\(highest) months authorized for \(unit.sentencingClass.label) at level \(unit.levelLabel).", against: true, term: true)
                        } else if selected.minimum > cell.presumptive.high && r.foundAggravating.isEmpty {
                            add("\(title): a minimum of \(selected.minimum) months is in the aggravated range, but no aggravating factor was found.", against: true, term: true)
                        } else if selected.minimum < cell.presumptive.low && r.foundMitigating.isEmpty {
                            add("\(title): a minimum of \(selected.minimum) months is in the mitigated range, but no mitigating factor was found.", against: false, term: true)
                        }
                        if let custom = selected.customMaximum {
                            let statutory = StructuredSentencing.maximum(forMinimum: selected.minimum, cls: unit.sentencingClass)
                            if custom != statutory {
                                add("\(title): the maximum term must be the statutory maximum (\(statutory) months) that corresponds to the minimum.", against: custom > statutory, term: true)
                            }
                        }
                    } else {
                        if selected.range == .aggravated && r.foundAggravating.isEmpty {
                            add("\(title): an aggravated-range sentence without any aggravating factor found.", against: true, term: true)
                        }
                        if selected.range == .mitigated && r.foundMitigating.isEmpty {
                            add("\(title): a mitigated-range sentence without any mitigating factor found.", against: false, term: true)
                        }
                    }
                    if let disposition = selected.disposition, !cell.dispositions.contains(disposition) {
                        add("\(title): a \(disposition.label) disposition is not authorized in this cell of the punishment chart (allowed: \(cell.dispositionCode)).",
                            against: disposition == .active, term: true)
                    }
                } else if let cell = unit.misdemeanorCell {
                    if selected.minimum > cell.maxDays {
                        add("\(title): \(selected.minimum) days exceeds the \(cell.maxDays)-day maximum for this class and level.", against: true, term: true)
                    }
                    if unit.sentencingClass == .misd3 && provenPriors.count <= 3 && selected.minimum > 0 {
                        add("\(title): with no more than three prior convictions, a Class 3 misdemeanor judgment may consist only of a fine (G.S. 15A-1340.23(d)).", against: true, term: true)
                    }
                    if let disposition = selected.disposition, !cell.dispositions.contains(disposition) {
                        add("\(title): a \(disposition.label) disposition is not authorized for this class and level (allowed: \(cell.dispositionCode)).",
                            against: disposition == .active, term: true)
                    }
                    if let cap = unit.sentencingClass.maxFine, r.money.fine > cap {
                        add("\(title): the fine exceeds the \(SentenceFormat.dollars(cap)) statutory maximum.", against: true)
                    }
                } else if unit.isDWI, let level = dwiLevel(selected) {
                    if selected.minimum > level.maxDays {
                        add("\(title): \(selected.minimum) days exceeds the \(level.maxDays)-day maximum for \(level.label) impaired driving (G.S. 20-179).", against: true, term: true)
                    } else if selected.minimum < level.minDays {
                        add("\(title): \(selected.minimum) days is below the \(level.minDays)-day minimum for \(level.label) impaired driving (G.S. 20-179).", against: false, term: true)
                    }
                    if r.money.fine > level.maxFine {
                        add("\(title): the fine exceeds the \(SentenceFormat.dollars(level.maxFine)) maximum for \(level.label) (G.S. 20-179).", against: true)
                    }
                    if isSuspended(unit, r) {
                        let jail = StructuredSentencing.dwiJailIfSuspended(level: selected.dwiLevel ?? 5, term: selected.minimum)
                        let service = level.serviceInstead
                        let met = r.conditions.specialProbationDays >= jail || (service > 0 && r.conditions.communityServiceHours >= service)
                        if !met {
                            add("\(title): a suspended \(level.label) sentence requires at least \(jail) day\(jail == 1 ? "" : "s") in jail as a condition of probation" + (service > 0 ? ", or \(service) hours of community service" : "") + " (G.S. 20-179).", against: false, term: true)
                        }
                    }
                }
                // A split sentence is special probation: part of a suspended term served first (G.S. 15A-1351(a)).
                if selected.disposition == .active && selected.probationAfterActive == true && !unit.isDWI {
                    let limit = specialProbationLimit(unit, choice: selected)
                    let unitName = unit.isFelony ? "months" : "days"
                    let allowed = unit.felonyCell?.dispositions ?? unit.misdemeanorCell?.dispositions ?? []
                    if selected.suspendedBalance == 0 {
                        add("\(title): probation can't follow an active term served in full on the same judgment, because nothing is left suspended to enforce. Use a split sentence (serve part, suspend the rest) or a separate suspended judgment.", against: true)
                    } else if selected.servedTerm > limit {
                        add("\(title): a split sentence may require no more than one-fourth of the maximum term (\(limit) \(unitName)) to be served before probation (G.S. 15A-1351(a)).", against: true, term: true)
                    }
                    if !allowed.isEmpty && !allowed.contains(.intermediate) && selected.suspendedBalance > 0 {
                        add("\(title): a split sentence is special probation, an intermediate punishment the chart doesn't authorize here (allowed: \(allowed.map(\.rawValue).joined(separator: "/"))).", against: false, term: true)
                    }
                }
                if hasProbation(unit, r) && selected.probationMonths > 60 {
                    add("\(title): probation may not exceed five years.", against: true)
                }
            }
            // Since the Justice Reinvestment Act, only special probation separates intermediate from community punishment.
            if r.conditions.specialProbationDays > 0 && anySuspended(c, r) && !anyIntermediate(c, r)
                && !convictedUnits.contains(where: { dwiSuspended($0, r) }) {
                add("Special probation is an intermediate condition; a community punishment cannot include it (G.S. 15A-1340.11).", against: true)
            } else if r.conditions.specialProbationDays > 0 && r.conditions.specialProbationDays > maxSpecialProbationDays(c, r) {
                add("Special probation exceeds one-fourth of the maximum suspended sentence (G.S. 15A-1351(a)).", against: true)
            }
            if anyIntermediate(c, r) && !r.conditions.supervised {
                add("Intermediate punishment requires supervised probation.", against: false)
            }
            if r.recommendations.advancedSupervisedRelease && anyActive(c, r) {
                if !convictedUnits.contains(where: { asrEligible($0, r) }) {
                    add("Advanced Supervised Release isn't available for this class, prior record level, or range.", against: false, term: true)
                } else if c.background?.stateObjectsToASR ?? false {
                    add("Advanced Supervised Release was ordered although the prosecutor objected (G.S. 15A-1340.18(c)).", against: false, term: true)
                }
            }
            // Consecutive misdemeanors may not exceed twice the maximum for the most serious offense (G.S. 15A-1340.22(a)).
            let misdemeanors = convictedUnits.filter { !$0.isFelony && !$0.isDWI }
            if r.runsConsecutively && misdemeanors.count > 1 && !convictedUnits.contains(where: { $0.isFelony }) {
                let total = misdemeanors.map { choice($0, r).minimum }.reduce(0, +)
                let cap = 2 * (misdemeanors.compactMap { $0.misdemeanorCell?.maxDays }.max() ?? 0)
                if cap > 0 && total > cap {
                    add("Consecutive misdemeanor sentences total \(total) days, more than twice the \(cap / 2)-day maximum for the most serious offense.", against: true, term: true)
                }
            }
            // Factors only matter when they support a sentence outside the presumptive range.
            let bg = c.background
            let outsidePresumptive = convictedUnits.contains { unit in
                guard let cell = unit.felonyCell else { return false }
                let selected = choice(unit, r)
                return selected.customTerm ? selected.minimum > cell.presumptive.high : selected.range == .aggravated
            }
            if outsidePresumptive, let hidden = bg?.hiddenAggravator, r.foundAggravating.contains(hidden) {
                add("The aggravating factor \"\(hidden)\" was found without the 30 days' written notice the State must give (G.S. 15A-1340.16(a6)).", against: true, term: true)
            }
            if outsidePresumptive && r.foundAggravating.contains(where: { $0.lowercased().contains("remorse") || $0.lowercased().contains("went to trial") }) {
                add("Lack of remorse or exercising the right to trial is not a proper aggravating factor.", against: true, term: true)
            }
        }
        if countsProbationPoint(c, r) && !probationNoticeGiven(c) && convictedUnits.contains(where: \.isFelony) {
            let without = PriorRecord(priors: c.defendant.priors, onSupervision: false, habitualPredicates: habitualPredicates(c, r),
                                      excluded: r.priorsNotProven,
                                      currentOffenses: c.charges.compactMap { ch in r.verdicts[ch.id].flatMap { convictedLaw(ch, $0)?.title } })
            if without.felonyLevel != priorRecord(c, r).felonyLevel {
                add("The probation point was counted although the State did not give 30 days' notice of its intent to prove it (G.S. 15A-1340.16(a6)), and it raised the prior record level.", against: true, term: true)
            }
        }
        if r.money.restitution > 0 {
            let documented = c.background?.restitution ?? 0
            if documented == 0 {
                add("Restitution was ordered with no evidence of the victim's loss in the record.", against: true)
            } else if Double(r.money.restitution) > Double(documented) * 1.1 {
                add("Restitution of \(SentenceFormat.dollars(r.money.restitution)) exceeds the \(SentenceFormat.dollars(documented)) supported by the evidence.", against: true)
            }
        }
        if r.pleaDepartureDisclosed == false {
            add("The sentence is harsher than the plea arrangement, and the defendant was not told or offered the chance to withdraw the plea (G.S. 15A-1024).", against: true, term: true)
        }
        if r.pleaAccepted == true && r.pleaKind == .noContest && c.background?.stateConsentsNoContest != true {
            add("A no-contest plea was accepted without the State's consent (G.S. 15A-1011(a)(3)).", against: false)
        }
        for condition in r.customConditions where conditionLooksUnlawful(condition) {
            add("The order \"\(condition)\" is likely unconstitutional or not reasonably related to the offense.", against: true)
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
        if r.special == .conditionalDischarge {
            // Conditional discharge probation is supervised; the fee runs for the term the court set.
            if !r.money.waiveSupervisionFees {
                items.append(("Supervision fees ($40/month)", FinancialOrders.supervisionFeePerMonth * probationLength(c, r)))
            }
            if r.conditions.communityServiceHours > 0 {
                items.append(("Community service fee", FinancialOrders.communityServiceFee))
            }
        } else if r.special == .none && anySuspended(c, r) {
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
        if unit.isDWI {
            lines.append("\(dwiLevel(choice)?.label ?? "Level not chosen") punishment (G.S. 20-179)")
        } else {
            lines.append(choice.customTerm ? "Term set by the court" : "\(choice.range.label) range")
        }
        let term = termText(for: unit, choice: choice)
        switch choice.disposition {
        case .active?:
            lines.append(unit.isFelony
                ? "Minimum \(choice.minimum), maximum \(maximum(for: unit, choice: choice)) months. Active: committed to the custody of the N.C. Department of Adult Correction."
                : "\(choice.minimum) days. Active: committed to the custody of the Hollis County Sheriff.")
        case .some where unit.isDWI:
            lines.append("\(term), suspended: \(choice.probationMonths) months of probation.")
        case let disposition?:
            lines.append("\(term), suspended. \(disposition.label) punishment: \(choice.probationMonths) months of \(disposition == .community ? "probation" : "supervised probation").")
        case nil:
            break
        }
        return lines
    }

    // MARK: Time in custody

    /// When an active sentence lets the defendant out. North Carolina inmates serve at least the minimum term:
    /// earned time can bring release down toward the minimum but never below it. A felon is released onto
    /// post-release supervision no later than the maximum less the supervision period (12 months for B1–E, 9 for F–I).
    struct CustodyProjection {
        /// Release after serving the minimum (or the Advanced Supervised Release term the judge chose), less jail credit.
        let earliest: Date
        /// Release at the maximum less post-release supervision, less jail credit.
        let latest: Date
        let minimumText: String
        let maximumText: String
        let creditDays: Int
        let usesASR: Bool
        let felony: Bool

        var lines: [String] {
            var lines = ["Minimum term to be served before the defendant is eligible for release: \(minimumText)" + (usesASR ? " (Advanced Supervised Release term, as the court ordered)." : ".")]
            if felony {
                lines.append("Maximum term: \(maximumText). Earned time can move release toward the minimum, never below it; post-release supervision follows release.")
            }
            if creditDays > 0 { lines.append("Credit for \(creditDays) days already served in pretrial confinement (G.S. 15-196.1).") }
            if earliest == latest {
                lines.append("Projected release: \(SentenceFormat.date(earliest)).")
            } else {
                lines.append("Projected release: no earlier than \(SentenceFormat.date(earliest)), and no later than \(SentenceFormat.date(latest)).")
            }
            return lines
        }
    }

    static func monthsAndDays(_ months: Int, _ days: Int) -> String {
        var parts: [String] = []
        if months > 0 { parts.append("\(months) month\(months == 1 ? "" : "s")" + (months >= 12 ? " (\(SentenceFormat.months(months)))" : "")) }
        if days > 0 { parts.append("\(days) day\(days == 1 ? "" : "s")") }
        return parts.isEmpty ? "no time" : parts.joined(separator: " and ")
    }

    /// Projected custody for today's active sentences; nil when nothing active is imposed, or when any judgment is
    /// life without parole (there is no release to project).
    static func custodyProjection(_ c: CourtCase, _ r: Rulings, units allUnits: [SentencingUnit], from date: Date) -> CustodyProjection? {
        guard r.special == .none else { return nil }
        guard !allUnits.contains(where: { choice($0, r).lifeWithoutParole }) else { return nil }
        let active = allUnits.filter { choice($0, r).disposition == .active && !choice($0, r).lifeWithoutParole }
        guard !active.isEmpty else { return nil }
        let cal = Calendar.current
        func add(_ months: Int, _ days: Int, to start: Date) -> Date {
            let afterMonths = cal.date(byAdding: .month, value: months, to: start) ?? start
            return cal.date(byAdding: .day, value: days, to: afterMonths) ?? afterMonths
        }
        // (min months, min days, latest months, latest days, max months for display)
        var terms: [(minM: Int, minD: Int, lateM: Int, lateD: Int, maxM: Int)] = []
        var usesASR = false
        for unit in active {
            let selected = choice(unit, r)
            if unit.isFelony {
                var minimum = selected.minimum
                if r.recommendations.advancedSupervisedRelease && asrEligible(unit, r) {
                    minimum = asrReleaseMonths(unit, choice: selected)
                    usesASR = true
                }
                let maxTerm = Judgment.maximum(for: unit, choice: selected)
                if selected.suspendedBalance > 0 {
                    // Released early onto probation: the served part is the whole stay.
                    terms.append((selected.servedTerm, 0, selected.servedTerm, 0, maxTerm))
                    continue
                }
                let supervision = StructuredSentencing.postReleaseMonths(for: unit.sentencingClass)
                terms.append((minimum, 0, max(selected.minimum, maxTerm - supervision), 0, maxTerm))
            } else {
                terms.append((0, selected.servedTerm, 0, selected.servedTerm, 0))
            }
        }
        let credit = max(0, c.background?.custodyDays ?? 0)
        var earliest: Date
        var latest: Date
        let minText: String
        let maxText: String
        let flags = active.enumerated().map { i, unit in i > 0 && r.consecutive(unit.id, index: allUnits.firstIndex(of: unit) ?? i) }
        let mixed = flags.dropFirst().contains(true) && flags.dropFirst().contains(false)
        if mixed {
            var minEnd = date, lateEnd = date, bestEnd = date, bestLate = date, maxRun = 0, bestMax = 0
            for (i, term) in terms.enumerated() {
                minEnd = add(term.minM, term.minD, to: flags[i] ? minEnd : date)
                lateEnd = add(term.lateM, term.lateD, to: flags[i] ? lateEnd : date)
                maxRun = (flags[i] ? maxRun : 0) + term.maxM
                bestEnd = max(bestEnd, minEnd); bestLate = max(bestLate, lateEnd); bestMax = max(bestMax, maxRun)
            }
            earliest = bestEnd
            latest = bestLate
            minText = "\(monthsBetween(date, bestEnd)) months in all (some judgments consecutive, others concurrent)"
            maxText = "\(bestMax) months in all"
        } else if flags.dropFirst().contains(true) && terms.count > 1 {
            let minM = terms.map { $0.minM }.reduce(0, +), minD = terms.map { $0.minD }.reduce(0, +)
            let lateM = terms.map { $0.lateM }.reduce(0, +), lateD = terms.map { $0.lateD }.reduce(0, +)
            earliest = add(minM, minD, to: date)
            latest = add(lateM, lateD, to: date)
            minText = monthsAndDays(minM, minD) + " in all (consecutive)"
            maxText = "\(terms.map { $0.maxM }.reduce(0, +)) months in all"
        } else {
            var bestEnd = date, bestLate = date, bestMinM = 0, bestMinD = 0
            for term in terms {
                let end = add(term.minM, term.minD, to: date)
                if end >= bestEnd { bestEnd = end; bestMinM = term.minM; bestMinD = term.minD }
                bestLate = max(bestLate, add(term.lateM, term.lateD, to: date))
            }
            earliest = bestEnd
            latest = bestLate
            minText = monthsAndDays(bestMinM, bestMinD) + (terms.count > 1 ? " (the longest of the concurrent terms)" : "")
            maxText = "\(terms.map { $0.maxM }.max() ?? 0) months"
        }
        earliest = max(date, cal.date(byAdding: .day, value: -credit, to: earliest) ?? earliest)
        latest = max(earliest, cal.date(byAdding: .day, value: -credit, to: latest) ?? latest)
        return CustodyProjection(earliest: earliest, latest: latest, minimumText: minText, maximumText: maxText,
                                 creditDays: credit, usesASR: usesASR, felony: active.contains(where: \.isFelony))
    }

    /// Whole months from one date to a later one, rounded up.
    static func monthsBetween(_ start: Date, _ end: Date) -> Int {
        guard end > start else { return 0 }
        let parts = Calendar.current.dateComponents([.month, .day], from: start, to: end)
        return (parts.month ?? 0) + ((parts.day ?? 0) > 0 ? 1 : 0)
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
        // Sufficiency on appeal looks only at the State's evidence, in the light most favorable to the State.
        let proper = stateStrength(c)
        if !dismissed {
            for charge in c.charges {
                let verdict = r.verdicts[charge.id] ?? .notGuilty
                let plea = r.pleaAccepted == true
                var label: String
                switch verdict {
                case .guilty: label = "Guilty"
                case .lesser: label = "Guilty of \(charge.lesserLaw?.title ?? "lesser offense")"
                case .notGuilty: label = "Not Guilty"
                case .dismissed: label = "Dismissed (insufficient evidence)"
                case .insanity: label = "Not Guilty by Reason of Insanity"
                }
                if r.arrestedCounts.contains(charge.id) && verdict.isConviction {
                    label += "; judgment arrested"
                }
                if r.dismissedByPlea.contains(charge.id) {
                    label = "Dismissed under plea arrangement"
                } else if r.halftime[charge.id] == .dismiss {
                    label = "Dismissed at the close of the State's evidence (G.S. 15A-1227)"
                } else if plea && verdict.isConviction {
                    switch r.pleaKind {
                    case .guilty: label += " (plea)"
                    case .alford: label += " (Alford plea)"
                    case .noContest: label = verdict == .lesser ? "No contest to \(charge.lesserLaw?.title ?? "lesser offense")" : "No contest"
                    }
                }
                if verdict.isConviction {
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
        /// The suspended balance of split sentences (served part, then probation); revocation activates only that balance.
        var afterActiveTerms: [Int] = []
        /// Misdemeanor exposure in days, for suspended terms and split-sentence balances.
        var suspendedDays: [Int] = []
        var afterActiveDays: [Int] = []
        var afterActiveText: [String] = []
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
                    lines.append(r.consecutive(unit.id, index: index)
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
                    if !selected.lifeWithoutParole && selected.probationAfterActive == true {
                        let unitName = unit.isFelony ? "month" : "day"
                        let balance = selected.suspendedBalance
                        let toMonths = { (n: Int) in unit.isFelony ? n : Int((Double(n) / 30).rounded(.up)) }
                        // Revocation activates only the suspended balance. A term served in full leaves nothing to activate.
                        afterActiveTerms.append(toMonths(balance))
                        if !unit.isFelony { afterActiveDays.append(balance) }
                        probationMonths = max(probationMonths, selected.probationMonths)
                        if unit.isFelony { anyFelonySuspended = true }
                        if balance > 0 {
                            activeTerms[activeTerms.count - 1] = toMonths(selected.servedTerm)
                            afterActiveText.append("\(balance) \(unitName)s of \(termText(for: unit, choice: selected)) suspended after \(selected.servedTerm) served")
                            lines.append("Special probation: the defendant shall serve \(selected.servedTerm) \(unitName)\(selected.servedTerm == 1 ? "" : "s") of this term, after which the remaining \(balance) \(unitName)\(balance == 1 ? "" : "s") are suspended and the defendant is placed on \(selected.probationMonths) months of supervised probation (G.S. 15A-1351(a)). A violation can activate only the suspended \(balance) \(unitName)\(balance == 1 ? "" : "s").")
                        } else {
                            afterActiveText.append("probation following an active term of \(termText(for: unit, choice: selected)), served in full")
                            lines.append("Upon release, the defendant is placed on \(selected.probationMonths) months of supervised probation. Because the whole term is served first, no suspended time remains to activate on a violation.")
                        }
                    }
                } else {
                    suspendedTerms.append(months)
                    if !unit.isFelony { suspendedDays.append(selected.minimum) }
                    probationMonths = max(probationMonths, selected.probationMonths)
                    suspendedText.append(termText(for: unit, choice: selected))
                    if unit.isFelony { anyFelonySuspended = true }
                }
                judgments.append(JudgmentEntry(title: unit.title, lines: lines))
            }

            if activeTerms.count > 0 {
                var lines = r.recommendations.lines + (suspendedTerms.isEmpty && afterActiveTerms.isEmpty ? r.customConditions : [])
                if life {
                    // Life without parole: no release date, no credit toward release, no supervision after.
                    lines.insert("The defendant is committed for the remainder of the defendant's natural life and will not be released.", at: 0)
                } else if let projection = custodyProjection(c, r, units: sentencingUnits, from: date) {
                    lines.insert(contentsOf: projection.lines, at: 0)
                } else if let days = bg?.custodyDays, days > 0 {
                    lines.insert("Credit for \(days) days of pretrial confinement (G.S. 15-196.1).", at: 0)
                }
                // Supervision follows release only from a felony term that ends; split terms are on probation instead.
                let releasedFelony = sentencingUnits.contains { unit in
                    let selected = choice(unit, r)
                    return unit.isFelony && selected.disposition == .active && !selected.lifeWithoutParole && selected.suspendedBalance == 0
                }
                if releasedFelony && !life {
                    lines.append("Upon release, the defendant will serve a period of post-release supervision (G.S. 15A-1368.2).")
                }
                if !lines.isEmpty { judgments.append(JudgmentEntry(title: "Commitment", lines: lines)) }
            }
            if !suspendedTerms.isEmpty || !afterActiveTerms.isEmpty {
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
                                                   "The finding of guilt remains and will count as a prior conviction."] + r.customConditions
                                           + (r.money.fine > 0 || !r.customConditions.isEmpty
                                              ? ["Because the court attached conditions beyond paying costs and obeying the law, this prayer for judgment operates as a final judgment."]
                                              : [])))
            newsSentence = "a prayer for judgment continued, with no sentence imposed"
        } else {
            probationMonths = r.dischargeMonths ?? 12
            let basis = dischargeBasis(c, r) == .drugPossession ? "G.S. 90-96" : "G.S. 15A-1341(a4)"
            judgments.append(JudgmentEntry(title: "Conditional discharge (\(basis))",
                                           lines: ["Further proceedings are deferred without entry of judgment.",
                                                   "The defendant is placed on \(probationMonths) months of supervised probation. On successful completion, the charge will be dismissed."]
                                           + r.conditions.descriptions(victimName: c.victimName).dropFirst() + r.customConditions))
            newsSentence = "a conditional discharge: if \(d.lastName) completes \(probationMonths) month\(probationMonths == 1 ? "" : "s") of probation, the charge will be dismissed"
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
        // Every conviction is recorded. Impaired driving has no class of its own and counts as a Class 1 misdemeanor
        // for prior record purposes. Convictions entered this week share a session key (G.S. 15A-1340.14(d)).
        let session = sessionKey(county: county, date: date)
        if convicted && special != .conditionalDischarge {
            // A count on which judgment was arrested is not a conviction on the record.
            for charge in c.charges where !r.arrestedCounts.contains(charge.id) {
                guard let verdict = r.verdicts[charge.id], let law = convictedLaw(charge, verdict) else { continue }
                let cls = law.ncClass ?? .misd1
                let unitForCharge = sentencingUnits.first { $0.counts.contains(charge.count) }
                let sentence: String
                if special == .prayerForJudgment {
                    sentence = "Prayer for judgment continued"
                } else if let unitForCharge {
                    let selected = choice(unitForCharge, r)
                    let suffix = selected.lifeWithoutParole ? "" : (selected.disposition == .active ? " active" : " suspended, \(selected.probationMonths) months probation")
                    let level = unitForCharge.isDWI ? (dwiLevel(selected).map { "\($0.label), " } ?? "") : ""
                    sentence = level + termText(for: unitForCharge, choice: selected) + suffix
                } else {
                    sentence = "Consolidated"
                }
                newPriors.append(PriorConviction(offense: law.title, ncClass: cls, year: year, county: county.name,
                                                 sentence: sentence, fromThisCourt: true, docket: c.docket, sessionKey: session))
            }
        }

        let combine: ([Int]) -> Int = { terms in
            r.runsConsecutively ? terms.reduce(0, +) : (terms.max() ?? 0)
            // (Grouped judgments with mixed choices are figured exactly in the custody projection.)
        }
        let projection = special == .none ? custodyProjection(c, r, units: sentencingUnits, from: date) : nil
        var releaseOn = projection?.earliest ?? date
        var custodyMonths = monthsBetween(date, releaseOn)
        if projection != nil && releaseOn <= date, let index = judgments.firstIndex(where: { $0.title == "Commitment" }) {
            judgments[index] = JudgmentEntry(title: "Commitment",
                                             lines: judgments[index].lines + ["Pretrial confinement credit satisfies the active term; the defendant is released from custody on this judgment."])
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
        let onProbation = !suspendedTerms.isEmpty || !afterActiveTerms.isEmpty
        let treatedSubstance = (k.substanceTreatment || k.drugTreatmentCourt) && onProbation
            || (r.recommendations.substanceTreatment && !activeTerms.isEmpty)
        let treatedMental = (k.mentalHealthTreatment && onProbation)
            || (r.recommendations.mentalHealth && !activeTerms.isEmpty)

        var propensity = truthGuilty ? 0.42 : 0.1
        if truthGuilty && !convicted { propensity += 0.15 }
        if d.priors.count >= 3 { propensity += 0.1 }
        if d.age > 50 { propensity *= 0.6 }
        if convicted {
            if need.substance { propensity *= treatedSubstance ? 0.7 : 1.15 }
            if need.mentalHealth { propensity *= treatedMental ? 0.75 : 1.1 }
            if k.maintainEmployment && bg?.employmentPlan != nil && onProbation { propensity *= 0.9 }
            if (k.education && onProbation) || (r.recommendations.vocational && !activeTerms.isEmpty) { propensity *= 0.93 }
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
        var revokedText = ""
        var revokedPostRelease: PostReleaseTerm?
        if let existing = d.probation, life {
            // Life without parole leaves nothing for probation to supervise.
            probationHearing = "Because the defendant is committed for life without parole, probation in \(existing.docket) is terminated."
        } else if let existing = d.probation {
            let stacked = r.revocationConsecutive && releaseOn > date
            func confine(months: Int, days: Int = 0) {
                let cal = Calendar.current
                func add(_ start: Date) -> Date {
                    let afterMonths = cal.date(byAdding: .month, value: months, to: start) ?? start
                    return cal.date(byAdding: .day, value: days, to: afterMonths) ?? afterMonths
                }
                releaseOn = stacked ? add(releaseOn) : max(releaseOn, add(date))
                custodyMonths = monthsBetween(date, releaseOn)
            }
            switch r.probationDecision ?? .continueAsIs {
            case .revoke:
                let activation = ViolationHearings.activation(existing, county: county, date: date)
                revokedMonths = activation.months + Int((Double(activation.days) / 30).rounded(.up))
                revokedText = activation.months > 0 ? "\(activation.months) months" : "\(activation.days) days"
                if let prior = activation.prior { newPriors.append(prior) }
                revokedPostRelease = activation.postRelease
                var text = activation.text
                if revokedMonths > 0 {
                    confine(months: activation.months, days: activation.days)
                    if custodyMonths > revokedMonths || stacked {
                        text.removeLast()
                        text += stacked ? ", to begin at the expiration of the sentence imposed today." : ", to run concurrently with the sentence imposed today."
                    }
                }
                probationHearing = text
            case .crv:
                let days = ViolationHearings.crvDays(existing)
                var continued = existing
                if days > 0 {
                    confine(months: 0, days: days)
                    continued.crvCount = (existing.crvCount ?? 0) + 1
                    continued.crvDaysServed = existing.crvCreditDays + days
                    probationHearing = "Violation found in \(existing.docket). The defendant is ordered to serve a \(days)-day period of confinement in response to violation (G.S. 15A-1344(d2)), after which probation resumes."
                } else {
                    probationHearing = "Violation found in \(existing.docket). No suspended time remains to serve as confinement in response to violation; probation continues."
                }
                continuedProbation = continued
            case .modify:
                let extraMonths = min(r.extensionMonths ?? 12, ViolationHearings.maxExtensionMonths(existing))
                var extended = existing
                extended.ends = Calendar.current.date(byAdding: .month, value: extraMonths, to: existing.ends) ?? existing.ends
                continuedProbation = extended
                probationHearing = extraMonths == 0
                    ? "Violation found in \(existing.docket). Probation conditions modified; the term is not extended."
                    : "Violation found in \(existing.docket). Probation modified and extended \(extraMonths) month\(extraMonths == 1 ? "" : "s")."
            case .continueAsIs:
                continuedProbation = existing
                probationHearing = r.probationDecision == nil ? nil : "Probation in \(existing.docket) continued on the same terms."
            }
        }

        // Existing post-release supervision
        var continuedPostRelease: PostReleaseTerm?
        var postReleaseMonths = 0
        if let prs = d.postRelease, life {
            let text = "Because the defendant is committed for life without parole, post-release supervision in \(prs.docket) is terminated."
            probationHearing = [probationHearing, text].compactMap { $0 }.joined(separator: " ")
        } else if let prs = d.postRelease {
            let stacked = r.revocationConsecutive && releaseOn > date
            func confine(months: Int) {
                let alone = Calendar.current.date(byAdding: .month, value: months, to: date) ?? date
                releaseOn = stacked ? (Calendar.current.date(byAdding: .month, value: months, to: releaseOn) ?? releaseOn) : max(releaseOn, alone)
                custodyMonths = monthsBetween(date, releaseOn)
            }
            let decided = r.postReleaseDecision != nil
            var text: String?
            switch r.postReleaseDecision ?? .continueAsIs {
            case .revoke:
                postReleaseMonths = max(1, prs.remainingMonths)
                confine(months: postReleaseMonths)
                text = "Post-release supervision in \(prs.docket) revoked. The defendant is returned to the custody of the Department of Adult Correction to serve the remaining \(postReleaseMonths) months of the maximum term" + (stacked ? ", beginning at the expiration of today's sentence." : ".")
            case .confine:
                postReleaseMonths = min(3, max(1, prs.remainingMonths))
                confine(months: postReleaseMonths)
                var continued = prs
                continued.remainingMonths = max(0, prs.remainingMonths - postReleaseMonths)
                continued.ends = Calendar.current.date(byAdding: .month, value: postReleaseMonths, to: prs.ends) ?? prs.ends
                continuedPostRelease = continued
                text = "Violation of post-release supervision found in \(prs.docket). The defendant is confined for \(postReleaseMonths) months, after which supervision resumes."
            case .continueAsIs:
                continuedPostRelease = prs
                text = decided ? "Post-release supervision in \(prs.docket) continued." : nil
            }
            if let text { probationHearing = [probationHearing, text].compactMap { $0 }.joined(separator: " ") }
        }

        // Violations found today, for the record.
        var violationsFound: [SupervisionViolation] = []
        let conduct = "New criminal offense charged in \(c.docket)"
        if !life, let existing = d.probation, let decision = r.probationDecision, decision != .continueAsIs {
            violationsFound.append(SupervisionViolation(docket: existing.docket, date: date, kind: "Probation violation",
                                                        conduct: conduct, result: decision.label))
        }
        if !life, let prs = d.postRelease, let decision = r.postReleaseDecision, decision != .continueAsIs {
            violationsFound.append(SupervisionViolation(docket: prs.docket, date: date, kind: "Post-release supervision violation",
                                                        conduct: conduct, result: decision.label))
        }

        // New probation from today's judgment, including split sentences that begin after release
        var newProbation = continuedProbation
        if !life && (!suspendedTerms.isEmpty || !afterActiveTerms.isEmpty || special == .conditionalDischarge) {
            let start = releaseOn
            let ends = Calendar.current.date(byAdding: .month, value: probationMonths, to: start) ?? start
            let discharge = special == .conditionalDischarge
            let lead = sentencingUnits.first
            // A conditional discharge defers judgment: on a violation the court enters judgment and sentences the
            // defendant. Keep what that judgment would be: the bottom of the presumptive range, or the low end for a misdemeanor.
            let dischargeFelony = discharge && sentencingUnits.contains(where: \.isFelony)
            let dischargeDays = lead?.misdemeanorCell.map { misdemeanorLowEnd($0) } ?? 30
            let dischargeMonths = dischargeFelony ? (lead?.felonyCell?.presumptive.low ?? 4) : Int((Double(dischargeDays) / 30).rounded(.up))
            let isFelonyTerm = discharge ? dischargeFelony : anyFelonySuspended
            var term = ProbationTerm(docket: c.docket,
                                     offense: lead?.law.title ?? principalTitle,
                                     isFelony: isFelonyTerm,
                                     suspendedSentence: discharge
                                        ? "conditional discharge (no judgment entered yet; on a violation the court may enter judgment on \(lead?.law.title ?? principalTitle) and sentence the defendant)"
                                        : (suspendedText + afterActiveText).joined(separator: "; "),
                                     activeMonths: discharge ? dischargeMonths : max(combine(suspendedTerms), combine(afterActiveTerms)),
                                     ends: ends, imposedInThisCourt: true,
                                     supervised: k.supervised || discharge,
                                     conditions: Array(k.descriptions(victimName: c.victimName).dropFirst()) + r.customConditions,
                                     monthlyObligation: probationMonths > 0 ? totalOwed / probationMonths : 0,
                                     violationRisk: violationRisk, crvCount: 0, treatmentNeed: need)
            if !isFelonyTerm {
                term.activeDays = discharge ? dischargeDays : max(combine(suspendedDays), combine(afterActiveDays))
            }
            term.crvDaysServed = 0
            term.starts = start
            term.offenseClass = lead?.offenseClass
            if discharge { term.conditionalDischarge = true }
            if let earlier = continuedProbation {
                term.ends = max(term.ends, earlier.ends)
                term.suspendedSentence += "; also on probation in \(earlier.docket) (\(earlier.suspendedSentence))"
                term.conditions = Array(Set((term.conditions ?? []) + (earlier.conditions ?? []))).sorted()
                term.supervised = (term.supervised ?? true) || (earlier.supervised ?? true)
                term.activeMonths = max(term.activeMonths, earlier.activeMonths)
                if !term.isFelony && !earlier.isFelony { term.activeDays = max(term.suspendedDays, earlier.suspendedDays) }
            }
            newProbation = term
            if k.specialProbationDays > 0 {
                newsExtras.append("The sentence includes \(k.specialProbationDays) days in jail as a condition of probation.")
            }
            if k.drugTreatmentCourt { newsExtras.append("The defendant was ordered into Drug Treatment Court.") }
            if k.communityServiceHours > 0 { newsExtras.append("\(k.communityServiceHours) hours of community service were ordered.") }
        }

        var releaseBasis: String?
        if life {
            releaseBasis = "Life imprisonment without parole."
        } else if releaseOn > date {
            var parts: [String] = []
            if let projection {
                parts.append("Minimum \(projection.minimumText)" + (projection.usesASR ? " under Advanced Supervised Release" : "") + "; maximum \(projection.maximumText).")
                if projection.creditDays > 0 { parts.append("Less \(projection.creditDays) days of jail credit.") }
                if projection.latest > projection.earliest {
                    parts.append("Release no earlier than \(SentenceFormat.shortDate(projection.earliest)), no later than \(SentenceFormat.shortDate(projection.latest)).")
                }
            }
            if revokedMonths > 0 { parts.append("Includes \(revokedText) activated on probation revocation" + (r.revocationConsecutive ? ", consecutive." : ", concurrent.")) }
            if postReleaseMonths > 0 { parts.append("Includes \(postReleaseMonths) months on the post-release supervision violation" + (r.revocationConsecutive ? ", consecutive." : ", concurrent.")) }
            if parts.isEmpty { parts.append("Confinement in response to violation, ordered with the judgment on the probation violation.") }
            releaseBasis = parts.joined(separator: " ")
        }

        if let projection, releaseOn > date, projection.creditDays > 0 || projection.usesASR {
            newsExtras.append("Counting \(projection.creditDays > 0 ? "\(projection.creditDays) days already served" : "Advanced Supervised Release"), the earliest possible release is \(SentenceFormat.date(projection.earliest)).")
        }

        // Post-release supervision that follows today's active felony term (G.S. 15A-1368.2): 12 months for
        // Class B1 through E, 9 months for F through I. Revocation activates the unserved part of the maximum.
        var newPostRelease: PostReleaseTerm?
        if !life && special == .none {
            // A term the court split with probation is supervised by probation, not post-release supervision.
            let felonyActive = sentencingUnits.filter { $0.isFelony && choice($0, r).disposition == .active && !choice($0, r).lifeWithoutParole
                && choice($0, r).suspendedBalance == 0 }
            if let first = felonyActive.first {
                let minima = felonyActive.map { choice($0, r).minimum }
                let maxima = felonyActive.map { maximum(for: $0, choice: choice($0, r)) }
                let months = felonyActive.map { StructuredSentencing.postReleaseMonths(for: $0.sentencingClass) }.max() ?? 9
                newPostRelease = PostReleaseTerm(docket: c.docket, offense: first.law.title, ends: releaseOn, supervisionMonths: months,
                                                 remainingMonths: max(months, combine(maxima) - combine(minima)))
            }
        }
        // A felony sentence activated on revocation also ends in post-release supervision (G.S. 15A-1368.2).
        if newPostRelease == nil, let revokedPostRelease {
            var prs = revokedPostRelease
            prs.ends = releaseOn
            newPostRelease = prs
        }

        let status: PersonRecord.Status
        var releaseDate: Date?
        let insanityAcquittal = !dismissed && !convicted && c.charges.contains { r.verdicts[$0.id] == .insanity }
        if insanityAcquittal {
            // Committed under G.S. 15A-1321; release comes only after a hearing, usually years later.
            status = .incarcerated
            releaseDate = later(900...2_400)
            releaseBasis = "Committed to Central Regional Hospital under G.S. 15A-1321 after a verdict of not guilty by reason of insanity. Release only by court order, after a hearing showing \(d.lastName) is no longer mentally ill or dangerous."
            judgments.append(JudgmentEntry(title: "Order of Commitment",
                                           lines: ["The defendant, found not guilty by reason of insanity, is committed to a state facility for the mentally ill (G.S. 15A-1321).",
                                                   "A hearing will be held within 50 days. The defendant bears the burden of proving by a preponderance of the evidence that the defendant is no longer mentally ill or no longer dangerous to others.",
                                                   "The clerk will notify the District Attorney and the victims' families of any release hearing."]))
        } else if life {
            status = .incarcerated
            releaseDate = .distantFuture
        } else if releaseOn > date {
            status = .incarcerated
            releaseDate = releaseOn
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
            } else if r.runsConsecutively {
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
            if !suspendedTerms.isEmpty || !afterActiveTerms.isEmpty { newsSentence += ", followed by \(probationMonths) months of probation" }
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
        // Appeals. A lawful judgment draws only the ordinary appeals a real docket sees.
        let issueDetails = convicted ? legalIssueDetails(c, r) : []
        let issues = issueDetails.map { $0.text }
        let harmful = issueDetails.filter { $0.againstDefendant }
        let lenient = issueDetails.filter { !$0.againstDefendant }
        var appealScheduled = false
        var appealNotice: String?
        let harsh = activeImposed || custodyMonths > 0
        if !harmful.isEmpty && rng.chance(harsh ? 0.75 : 0.4) {
            // A defendant may appeal a sentence the law doesn't authorize, even after a plea (G.S. 15A-1444(a1), (a2)).
            var newRelease: Date?
            if harmful.contains(where: { $0.affectsTerm }), let current = releaseDate, let unit = sentencingUnits.first {
                let credit = bg?.custodyDays ?? 0
                var lawful: Date
                if let cell = unit.felonyCell {
                    lawful = Calendar.current.date(byAdding: .month, value: cell.presumptive.high, to: date) ?? date
                } else {
                    lawful = Calendar.current.date(byAdding: .day, value: maxDays(for: unit, choice: choice(unit, r)) ?? 30, to: date) ?? date
                }
                lawful = Calendar.current.date(byAdding: .day, value: -credit, to: lawful) ?? lawful
                if revokedMonths > 0 { lawful = max(lawful, Calendar.current.date(byAdding: .month, value: revokedMonths, to: date) ?? lawful) }
                if lawful < current { newRelease = max(date, lawful) }
            }
            appealScheduled = true
            appealNotice = "The defendant gave notice of appeal to the North Carolina Court of Appeals in open court."
            pending.append(PendingEvent(due: later(120...300),
                                        news: NewsItem(date: date, kind: .appeal,
                                                       headline: "Appeals court vacates sentence in \(d.name) case",
                                                       body: "On appeal by the defendant, the North Carolina Court of Appeals vacated the judgment Judge \(judgeLast) entered in \(c.caption) and remanded for resentencing. The court held: " + harmful.prefix(2).map { $0.text }.joined(separator: " "),
                                                       docket: c.docket),
                                        personID: d.personID,
                                        effect: newRelease == nil ? .none : .resentence,
                                        appealReversed: true,
                                        newReleaseDate: newRelease))
        } else if !lenient.isEmpty && rng.chance(0.3) {
            // The State may appeal a sentence the law doesn't authorize (G.S. 15A-1445(a)(3)), but seldom does.
            appealScheduled = true
            appealNotice = "The State gave notice of appeal from the judgment (G.S. 15A-1445(a)(3))."
            // On remand the court enters the least sentence the law allows: the bottom of the presumptive range for a
            // felony, with credit for time served.
            var lawfulRelease: Date?
            var resentenced = ""
            if lenient.contains(where: { $0.affectsTerm }), let unit = sentencingUnits.first, let cell = unit.felonyCell, !life {
                let months = cell.presumptive.low
                let full = Calendar.current.date(byAdding: .month, value: months, to: date) ?? date
                let lawful = Calendar.current.date(byAdding: .day, value: -(bg?.custodyDays ?? 0), to: full) ?? full
                if lawful > (releaseDate ?? date) {
                    lawfulRelease = lawful
                    resentenced = " On remand, the defendant was resentenced to a minimum of \(months) months, with credit for time already served."
                }
            }
            pending.append(PendingEvent(due: later(120...300),
                                        news: NewsItem(date: date, kind: .appeal,
                                                       headline: "Appeals court vacates sentence in \(d.name) case",
                                                       body: "On appeal by the State, the North Carolina Court of Appeals vacated the judgment Judge \(judgeLast) entered in \(c.caption) and remanded for resentencing. The court held: " + lenient.prefix(2).map { $0.text }.joined(separator: " ") + resentenced,
                                                       docket: c.docket),
                                        personID: d.personID, effect: lawfulRelease == nil ? .none : .lengthen, appealReversed: true,
                                        newReleaseDate: lawfulRelease))
        }
        if !issues.isEmpty {
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

        // An ordinary appeal of right after a conviction at trial (G.S. 7A-27(b), 15A-1444(a)). A guilty plea waives it,
        // and a prayer for judgment continued or a conditional discharge enters no final judgment to appeal.
        if convicted && !plea && special == .none && !appealScheduled {
            if rng.chance(harsh ? 0.3 : 0.1) {
                appealNotice = "The defendant gave notice of appeal to the North Carolina Court of Appeals in open court."
                pending.append(contentsOf: appealEvents(c, r, anyUnsupported: anyUnsupported, proper: proper,
                                                        judgeLast: judgeLast, due: later(150...330), plea: plea,
                                                        retryChance: rng.chance(0.7)))
            }
        }
        // A motion for appropriate relief on newly discovered evidence, heard by this court (G.S. 15A-1415(c)).
        if convicted && !plea && rng.chance(truthGuilty ? 0.1 : 0.6) {
            var retrial = retrialCase(c, r, relief: true)
            let evidence = truthGuilty
                ? "\(rng.pick(["A State witness", "The State's main eyewitness", "A co-defendant"])) has signed an affidavit recanting \(rng.pick(["their", "the"])) trial testimony and saying \(d.lastName) wasn't involved."
                : c.truth.revelation
            retrial.evidence.append(Evidence(exhibit: "Defendant's Exhibit \(c.evidence.filter { $0.side == .defense }.count + 1)",
                                             title: "Newly Discovered Evidence", detail: evidence, side: .defense,
                                             kind: .document, weight: truthGuilty ? 1 : 4, supplemental: "Found after the first trial"))
            retrial.headline = "New trial: " + c.headline
            let motion = ReliefMotion(docket: c.docket, personID: d.personID, personName: d.name, offense: principalTitle,
                                      newEvidence: evidence, meritorious: !truthGuilty, retrial: retrial)
            pending.append(PendingEvent(due: later(45...170),
                                        news: NewsItem(date: date, kind: .revelation,
                                                       headline: "\(d.name) asks for a new trial, citing new evidence",
                                                       body: "Lawyers for \(d.name), convicted in Hollis County Superior Court of \(principalTitle.lowercased()), filed a motion for appropriate relief claiming newly discovered evidence. Judge \(judgeLast), who presided at trial, will hear it.",
                                                       docket: c.docket),
                                        personID: d.personID, reliefMotion: motion))
        }

        // What the defendant does next, if the judgment let a guilty person go.
        // What follows in the world: written beats for this case, the victim a year on, the community's reaction.
        var broughtCase = false
        // Whether the defendant actually leaves in custody today; jail credit can satisfy an active term outright.
        let goingIn = life || releaseOn > date
        let timeServed = activeImposed && !goingIn
        if !insanityAcquittal {
            let aftermath = Aftermath.events(for: c, convicted: convicted, active: goingIn,
                                             judgeLast: judgeLast, date: date, dismissed: dismissed, rng: &rng)
            pending.append(contentsOf: aftermath.events)
            broughtCase = aftermath.broughtCase
        }
        if !broughtCase {
            pending.append(contentsOf: Consequences.afterJudgment(c, convicted: convicted, active: goingIn,
                                                                  dismissed: dismissed, insanity: insanityAcquittal, judgeLast: judgeLast, date: date, rng: &rng))
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
        // How the sentence compares with what the courthouse expected: -1 lenient, 0 about right, 1 severe.
        var severity = 0
        if convicted {
            if special != .none {
                severity = -1
            } else if let unit = sentencingUnits.first {
                let selected = choice(unit, r)
                if selected.lifeWithoutParole {
                    severity = 1
                } else if let cell = unit.felonyCell {
                    if selected.disposition != .active && !cell.dispositions.contains(.community) && !cell.dispositions.contains(.intermediate) {
                        severity = -1
                    } else if selected.minimum < cell.presumptive.low || (selected.disposition != .active && cell.dispositions == [.intermediate, .active] && unit.level >= 2) {
                        severity = -1
                    } else if selected.minimum > cell.presumptive.high || (r.runsConsecutively && activeTerms.count > 1) {
                        severity = 1
                    }
                } else if let cell = unit.misdemeanorCell {
                    if selected.disposition == .active && selected.minimum * 4 >= cell.maxDays * 3 { severity = 1 }
                    if selected.disposition != .active && selected.minimum == 0 { severity = -1 }
                }
            }
        }
        let reactions = makeReactions(c, county: county, convicted: convicted, dismissed: dismissed, active: goingIn, timeServed: timeServed,
                                      years: life || custodyMonths >= 12, onProbation: newProbation != nil, plea: plea ? r.pleaKind : nil, severity: severity, sentence: newsSentence, rng: &rng)
        var news = makeNews(c, county: county, judgeLast: judgeLast, date: date, convicted: convicted, dismissed: dismissed,
                            plea: plea ? r.pleaKind : nil, pleaLaw: plea ? sentencingUnits.first?.law : nil,
                            sentence: newsSentence, active: goingIn, timeServed: timeServed, reactions: reactions,
                            countsConvicted: verdictLines.filter { $0.verdictLabel.lowercased().contains("guilty") && !$0.verdictLabel.lowercased().contains("not guilty") }.count,
                            lead: convictedLaws(c, r).min { ($0.ncClass?.severity ?? 99) < ($1.ncClass?.severity ?? 99) })
        if !newsExtras.isEmpty { news.body += " " + newsExtras.joined(separator: " ") }

        let appearance: String
        if dismissed {
            appearance = "Dismissed (speedy trial)"
        } else if convicted {
            appearance = verdictLines.map { "Ct. \($0.count) \($0.verdictLabel)" }.joined(separator: "; ") + (newsSentence.isEmpty ? "" : ". \(newsSentence.capitalizedFirst)")
        } else if insanityAcquittal {
            appearance = "Not guilty by reason of insanity; committed to Central Regional Hospital (G.S. 15A-1321)"
            news.headline = "\(d.name) found not guilty by reason of insanity"
            news.body = "Judge \(judgeLast) found \(d.name) not guilty by reason of insanity in \(c.caption) and ordered \(d.lastName) committed to Central Regional Hospital in Butner. Under state law, \(d.lastName) can be released only after a court hearing. " + reactions.prefix(2).joined(separator: " ")
        } else {
            let verdicts = c.charges.compactMap { r.verdicts[$0.id] }
            appearance = !verdicts.isEmpty && verdicts.allSatisfy({ $0 == .dismissed }) ? "All counts dismissed for insufficient evidence"
                : (verdicts.contains(.dismissed) ? "Not guilty or dismissed on all counts" : "Not guilty on all counts")
        }

        if dismissed && c.motions.contains(where: { $0.kind == .dismissSpeedyTrial && !$0.shouldGrant }) && rng.chance(0.35) {
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
                           pending: pending, appearanceSummary: appearance, releaseBasis: releaseBasis,
                           continuedPostRelease: continuedPostRelease, newPostRelease: newPostRelease,
                           violations: violationsFound, rulingNotes: rulingNotes(c, r),
                           appealGrounds: appealGroundDetails(c, r, issues: issueDetails, byState: (appealNotice ?? "").contains("The State")).map(\.text),
                           appealGroundErrors: appealGroundDetails(c, r, issues: issueDetails, byState: (appealNotice ?? "").contains("The State")).map(\.error),
                           stayAwayOrder: stayAwayOrder(c, r, convicted: convicted, date: date, probationEnds: newProbation?.ends))
    }

    /// The order protecting the victim: one the court entered for a set number of years, or, failing that, the
    /// no-contact condition of probation for as long as probation runs.
    static func stayAwayOrder(_ c: CourtCase, _ r: Rulings, convicted: Bool, date: Date, probationEnds: Date?) -> StayAwayOrder? {
        guard convicted, let victim = c.victimName, !Consequences.victimDied(c), !Consequences.victimIsChild(c) else { return nil }
        let expires: Date
        let fromProbation = r.stayAwayYears == 0
        if r.stayAwayYears > 0 {
            expires = Calendar.current.date(byAdding: .year, value: r.stayAwayYears, to: date) ?? date
        } else if r.conditions.noContactVictim, let ends = probationEnds {
            expires = ends
        } else {
            return nil
        }
        return StayAwayOrder(docket: c.docket, protectedName: victim, issued: date, expires: expires, domestic: Consequences.isDomestic(c),
                             offense: BenchConference.convictedCharges(c, r).first?.law.title ?? c.charges.first?.law.title,
                             fromProbation: fromProbation ? true : nil)
    }

    /// The assignments of error an appellant would brief: the rulings that went against them, the ones an appellate
    /// court would likely find wrong listed first, and any unlawful part of the sentence.
    static func appealGroundDetails(_ c: CourtCase, _ r: Rulings, issues: [LegalIssue], byState: Bool) -> [(text: String, error: Bool)] {
        if byState {
            let speedy = c.motions.first { $0.kind == .dismissSpeedyTrial && r.motions[$0.id] == true }
            var grounds = issues.filter { !$0.againstDefendant }.map { (text: "The sentence: \($0.text)", error: true) }
            if let speedy {
                grounds.insert((text: "You dismissed the charges for a speedy-trial violation. The State argues the delay didn't violate the Sixth Amendment under Barker v. Wingo.",
                                error: !speedy.shouldGrant), at: 0)
            }
            return grounds
        }
        var strong: [(text: String, error: Bool)] = []
        var lesser: [(text: String, error: Bool)] = []
        func add(_ text: String, error: Bool) { if error { strong.append((text, true)) } else { lesser.append((text, false)) } }
        for m in c.motions where r.motions[m.id] == false {
            let target = c.evidence(m.targetEvidenceID).map { " (\($0.exhibit), \($0.phrase))" } ?? ""
            add("You denied the \(m.kind.title.lowercased())\(target).", error: m.shouldGrant)
        }
        for o in c.objections {
            guard let sustained = r.objections[o.id] else { continue }
            let question = ["Prosecutor: ", "Defense attorney: ", "Defense: ", "Prosecution: "].reduce(o.question) { $0.replacingOccurrences(of: $1, with: "") }
            if o.raisedBy == .defense && !sustained {
                add("You overruled the defense's objection (\(o.grounds.lowercased())) to the question \(question)", error: o.shouldSustain)
            } else if o.raisedBy == .prosecution && sustained {
                add("You sustained the State's objection (\(o.grounds.lowercased())) and kept out the answer to \(question)", error: !o.shouldSustain)
            }
        }
        let state = stateStrength(c)
        for charge in c.charges {
            guard let verdict = r.verdicts[charge.id], verdict == .guilty || verdict == .lesser else { continue }
            let supported = isSupported(verdict, charge: charge, strength: state)
            if r.halftime[charge.id] == .deny || r.halftime[charge.id] == .lesserOnly {
                add("You denied the motion to dismiss Count \(charge.count) (\(charge.law.title)) at the close of the State's evidence.", error: !supported)
            } else if !supported {
                add("The evidence was insufficient to convict on Count \(charge.count) (\(charge.law.title)).", error: true)
            }
        }
        for issue in issues where issue.againstDefendant { strong.append(("The sentence: \(issue.text)", true)) }
        let grounds = strong + lesser
        return grounds.isEmpty
            ? [("The defense argues the verdict is against the weight of the evidence and preserves every ruling for review. No single ruling is singled out.", false)]
            : Array(grounds.prefix(5))
    }

    /// Every motion, objection, and halftime motion the judge ruled on, and how the ruling would hold up.
    static func rulingNotes(_ c: CourtCase, _ r: Rulings) -> [RulingNote] {
        var notes: [RulingNote] = []
        for m in c.motions {
            guard let granted = r.motions[m.id] else { continue }
            notes.append(RulingNote(title: m.kind.title, yourRuling: granted ? "Granted" : "Denied",
                                    proper: m.shouldGrant ? "Grant" : "Deny", sound: granted == m.shouldGrant, note: m.appellateNote))
        }
        for o in c.objections {
            guard let sustained = r.objections[o.id] else { continue }
            let who = o.raisedBy == .defense ? "Defense" : "State"
            notes.append(RulingNote(title: "\(who) objection: \(o.grounds)", yourRuling: sustained ? "Sustained" : "Overruled",
                                    proper: o.shouldSustain ? "Sustain" : "Overrule", sound: sustained == o.shouldSustain,
                                    note: o.appellateNote))
        }
        let state = stateStrength(c)
        for charge in c.charges {
            guard let ruling = r.halftime[charge.id] else { continue }
            // The same line the Court of Appeals draws on sufficiency review.
            let substantial = isSupported(.guilty, charge: charge, strength: state)
            let lesserSubstantial = charge.lesserLawID != nil && isSupported(.lesser, charge: charge, strength: state)
            let sound: Bool
            switch ruling {
            case .deny: sound = substantial
            case .dismiss: sound = !substantial
            case .lesserOnly: sound = !substantial && lesserSubstantial
            }
            let note = substantial
                ? "Taken in the light most favorable to the State, there was substantial evidence of each element of \(charge.law.title). Credibility and conflicts in the evidence are for the factfinder, so the count should go forward."
                : (lesserSubstantial && charge.lesserLawID != nil
                    ? "The State's evidence was thin on an element of \(charge.law.title) but supported the lesser offense. Sending only the lesser offense forward is the careful ruling."
                    : "The State's evidence did not reach substantial evidence of every element. Dismissal at the close of the State's case is proper, and it can't be appealed by the State.")
            notes.append(RulingNote(title: "Motion to dismiss count \(charge.count): \(charge.law.title)", yourRuling: ruling.label,
                                    proper: substantial ? "Deny" : (lesserSubstantial && charge.lesserLawID != nil ? "Lesser offense only" : "Dismiss"),
                                    sound: sound, note: note))
        }
        return notes
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
    static func retrialCase(_ c: CourtCase, _ r: Rulings, reinstated: Bool = false, relief: Bool = false) -> CourtCase {
        var retrial = c
        retrial.id = UUID()
        // A count on a defective indictment that should have been dismissed can't be tried again.
        let defective = Set(c.motions.compactMap { m in
            m.kind == .dismissIndictment && m.shouldGrant && r.motions[m.id] != true ? m.targetChargeID : nil
        })
        if !defective.isEmpty && c.charges.contains(where: { !defective.contains($0.id) }) {
            retrial.charges.removeAll { defective.contains($0.id) }
        }
        // Only rulings actually made and held wrong change the retrial; motions never reached are heard fresh.
        let wronglyAdmitted = Set(c.motions.compactMap { m in
            m.shouldGrant && r.motions[m.id] == false ? m.targetEvidenceID : nil
        })
        retrial.evidence.removeAll { wronglyAdmitted.contains($0.id) }
        retrial.motions.removeAll { $0.shouldGrant && r.motions[$0.id] == false }
        retrial.motions.removeAll { $0.kind == .dismissSpeedyTrial }
        retrial.objections.removeAll { $0.shouldSustain && r.objections[$0.id] == false }
        retrial.ethics = nil
        retrial.twist = nil
        retrial.mediaAttention = min(3, c.mediaAttention + 1)
        retrial.headline = (reinstated ? "Reinstated: " : "Retrial: ") + c.headline
        retrial.proceduralNotes.insert(reinstated
            ? "The Court of Appeals reversed your speedy-trial dismissal and reinstated the charges. The case is back for trial."
            : relief
                ? "You granted a motion for appropriate relief and ordered a new trial. The earlier verdict carries no weight, and the newly discovered evidence is part of the case."
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
        for objection in c.objections where objection.raisedBy == .defense && objection.shouldSustain
            && !(r.objections[objection.id] ?? false) && objection.weightIfAdmitted > 0 {
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
                                      timeServed: Bool = false, years: Bool = true, onProbation: Bool = true, plea: PleaKind?, severity: Int, sentence: String, rng: inout SeededRNG) -> [String] {
        let defenseName = c.defenseAttorney.components(separatedBy: ",").first ?? c.defenseAttorney
        let ada = c.prosecutor
        let da = rng.chance(c.mediaAttention >= 2 ? 0.7 : 0.3) ? "District Attorney \(county.districtAttorney)" : ada
        let dl = c.defendant.lastName
        // A real job the defendant still holds, and one a conviction doesn't end on its own.
        let job = c.defendant.profile?.jobs.first { job in
            let text = (job.title + " " + job.employer).lowercased()
            return job.current && job.title != "Unemployed" && job.title != "In custody"
                && !["police", "sheriff", "detention", "officer", "school", "day care", "daycare", "teacher", "nurs", "pharmac", "bank", "financial"].contains(where: text.contains)
        }
        let topic: String
        switch c.category {
        case .violent, .robbery: topic = rng.pick(["violence in our community", "the people who were hurt", "public safety"])
        case .drugs: topic = rng.pick(["the drug trade in Hollis County", "the overdoses this county has buried", "addiction"])
        case .property: topic = rng.pick(["homeowners and small businesses", "people's sense of being safe at home", "property crime"])
        case .whiteCollar, .cyber: topic = rng.pick(["people who trusted the wrong person with their money", "financial crime", "public trust"])
        case .traffic: topic = rng.pick(["safety on our roads", "families who share the highway", "impaired driving"])
        case .family: topic = rng.pick(["children and families", "the most vulnerable people we serve", "family violence"])
        default: topic = rng.pick(["public safety", "the rule of law", "our community"])
        }
        var lines: [String] = []

        // The State
        if dismissed {
            lines.append("\(da): " + rng.pick([
                "\"We're disappointed and reviewing our options for appeal.\"",
                "\"We disagree with the ruling. Our office will decide in the coming days whether to appeal.\"",
                "\"Delay is never acceptable, and we'll look hard at how this case moved through our office.\""]))
        } else if !convicted {
            lines.append("\(da): " + rng.pick([
                "\"We respect the court's decision, though we see the evidence differently.\"",
                "\"The court has spoken. Our office will keep standing up for \(topic).\"",
                "\"We presented the evidence we had. We accept the verdict.\"",
                "\"A bench trial is a judge's call to make. We made our case and we'll move on to the next one.\"",
                "\"We'll be talking with the investigators about what we could have done differently.\""]))
        } else if plea != nil {
            lines.append("\(da): " + rng.pick([
                "\"This plea holds \(dl) accountable and spares the witnesses from having to testify.\"",
                "\"A certain conviction today was worth more than an uncertain verdict tomorrow.\"",
                "\"We're satisfied with the resolution and grateful to the investigators.\"",
                severity > 0 ? "\"The court went further than the agreement, and that was the court's call.\"" : "\"The agreement reflects the evidence and the law, and the court accepted it.\""]))
        } else {
            switch severity {
            case 1:
                lines.append("\(da): " + rng.pick([
                    "\"The sentence reflects how seriously this court takes \(topic).\"",
                    "\"We asked the court to look at the whole picture. It did.\"",
                    "\"Our assistant district attorneys tried this case the right way, and the result speaks for itself.\""]))
            case -1:
                lines.append("\(da): " + rng.pick([
                    "\"We respect the court's authority, but we asked for more, and we think the facts called for it.\"",
                    "\"The conviction matters. We'd hoped the sentence would say more about \(topic).\"",
                    "\"We'll be watching closely to make sure every condition of that probation is enforced.\""]))
            default:
                lines.append("\(da): " + rng.pick([
                    "\"We're grateful to the officers and witnesses who saw this case through.\"",
                    "\"The evidence was clear, and the court followed it.\"",
                    "\"No verdict undoes the harm. But this one says it mattered.\"",
                    "\"This is a fair result under the sentencing laws, and it's about \(topic).\""]))
            }
        }

        // The defense
        if dismissed {
            lines.append("\(defenseName): " + rng.pick([
                "\"The Constitution doesn't let the State hold someone in limbo indefinitely.\"",
                "\"\(dl) waited years for a trial that never came. The court did what the law requires.\""]))
        } else if !convicted {
            lines.append("\(defenseName): " + rng.pick([
                "\"The court held the State to its burden. That's how it's supposed to work.\"",
                "\"\(dl) can finally go home.\"",
                "\"Suspicion isn't proof. Today the system worked.\"",
                "\"\(dl) has lived under this charge for a long time. It's over.\"" ]))
        } else if plea == .alford {
            lines.append("\(defenseName): \"My client still maintains their innocence. This plea was about certainty, not guilt.\"")
        } else {
            switch (active, severity) {
            case (true, 1):
                lines.append("\(defenseName): " + rng.pick([
                    "\"This sentence is far more than this case called for, and we'll be reviewing every option.\"",
                    "\"\(dl) will be gone for years. The family is devastated.\"",
                    plea != nil ? "\"My client accepted responsibility. We had hoped the court would give more weight to that.\"" : "\"We believe there were errors at trial, and we intend to raise them.\""]))
            case (true, _):
                lines.append("\(defenseName): " + rng.pick([
                    "\"We're disappointed, but the court listened. \(dl) will do the time and come home.\"",
                    "\"It's a hard day. We'll be talking with \(dl) about next steps.\"",
                    plea != nil ? "\"My client accepted responsibility and is ready to serve the sentence.\"" : "\"We respect the court, even though we see the evidence differently.\""]))
            case (false, _) where timeServed:
                lines.append("\(defenseName): " + rng.pick([
                    "\"\(dl) has already served this sentence in the county jail. It's time to go home.\"",
                    "\"The months in jail were punishment enough, and the court recognized that.\"",
                    "\"\(dl) walks out today with the time already done. Now comes the hard part: staying out.\""]))
            case (false, _):
                lines.append("\(defenseName): " + rng.pick([
                    "\"My client has a chance to put this behind them, and intends to take it.\"",
                    "\"The court saw a person, not just a file. We're grateful.\"",
                    job.map { "\"\(dl) gets to keep the job at \($0.employer). That matters more than people think.\"" } ?? "\"Probation is hard. \(dl) knows that, and knows what's at stake.\"",
                    "\"This gives \(dl) a way forward that a prison cell never would.\""]))
            }
        }

        // The victim's family, when there is one
        if let victim = c.victimName {
            let family = victim.components(separatedBy: " ").last ?? victim
            let stance = c.background?.victimStance ?? .wantsAccountability
            let speaker = rng.pick(["A member of the \(family) family", "\(victim)'s sister", "A relative of \(victim)", "\(victim)'s father", "A family friend of the \(family)s"])
            // Grief and loss only when someone died; otherwise the words fit what the victim lived through.
            let died = Consequences.victimDied(c)
            var line: String?
            switch (convicted, active, stance) {
            case (false, _, .wantsLeniency):
                line = rng.pick(["\"We never wanted this case. Maybe now everyone can heal.\"", "\"We just want to be left alone now.\""])
            case (false, _, _):
                line = rng.pick(["\"So that's it? That's justice?\"", "\"We'll be living with this. \(dl) gets to walk away.\"",
                                 "\"We sat through every day of this. I don't know what else we could have done.\"",
                                 "\"The judge didn't hear what we heard that night.\""])
            case (true, true, .wantsLeniency):
                line = rng.pick(["\"We didn't want this. Prison won't fix anything.\"", "\"We asked for mercy. I hope \(dl) gets help in there.\""])
            case (true, false, .wantsLeniency):
                line = rng.pick(["\"We asked for mercy, and the judge listened. That's what we wanted.\"", "\"This is the right outcome. Everybody gets a second chance.\""])
            case (true, true, .wantsMaximum):
                line = severity > 0
                    ? rng.pick(["\"Finally someone listened to us.\"", died ? "\"It won't bring back what we lost, but the judge got it right.\"" : "\"The judge got it right. Now we can stop looking over our shoulders.\""])
                    : rng.pick(["\"It's not enough. It's never going to be enough.\"",
                                died ? "\"\(dl) will be out before we've stopped grieving.\"" : "\"\(dl) will be out before we feel safe again.\""])
            case (true, false, .wantsMaximum) where timeServed:
                line = rng.pick(["\"A few months in the county jail, and \(dl) just walks out?\"",
                                 died ? "\"\(dl) goes home tonight. We go home to an empty chair.\"" : "\"\(dl) goes home tonight, and we're supposed to feel safe?\"",
                                 "\"Time served. That's what they call it. We'll be serving ours a lot longer.\""])
            case (true, false, .wantsMaximum):
                line = rng.pick(["\"Probation. I don't know what to say.\"",
                                 died ? "\"\(dl) walks out the front door today. We go home to an empty chair.\"" : "\"\(dl) walks out the front door today, and we're supposed to feel safe?\"",
                                 "\"We'll be at every hearing if \(dl) slips once.\""])
            case (true, true, _):
                line = rng.pick([died ? "\"Nothing brings back what we lost. But today someone was held responsible.\"" : "\"Today someone was held responsible. That matters.\"",
                                 "\"It's something. We can start to move on.\"",
                                 severity < 0 ? "\"I thought it would be more. But at least it's over.\"" : "\"The judge took it seriously. That's all we asked.\""])
            case (true, false, _) where timeServed && !onProbation:
                line = rng.pick(["\"\(dl) already sat in jail for it. I guess that's the sentence.\"",
                                 "\"At least it's on the record now. If it happens again, everyone will know.\"",
                                 "\"We just want to be left alone now.\""])
            case (true, false, _):
                line = rng.pick(["\"We'll be watching to make sure every condition is followed.\"",
                                 "\"At least there's a record now. If it happens again, everyone will know.\"",
                                 "\"I hope \(dl) understands how close that was.\""])
            }
            if let line { lines.append("\(speaker), outside the courtroom: \(line)") }
        }

        // The defendant's own people, when they came
        if let support = c.background?.supportPeople?.lowercased() {
            let who: String
            if support.contains("grandmother") { who = "\(dl)'s grandmother" }
            else if support.contains("mother") { who = "\(dl)'s mother" }
            else if support.contains("partner") { who = "\(dl)'s partner" }
            else if support.contains("spouse") { who = "\(dl)'s spouse" }
            else if support.contains("employer") { who = "A former employer of \(dl)'s" }
            else { who = "A relative of \(dl)'s" }
            let words: String
            switch (convicted, active) {
            case (false, _):
                words = rng.pick(["\"I knew it. I knew the truth would come out.\"", "\"I'm taking my baby home.\"", "\"Thank God. Thank God.\""])
            case (true, true):
                words = severity > 0 && years
                    ? rng.pick(["\"Years? For this? I don't understand.\"", (c.defendant.profile?.childCount ?? 0) > 0 && c.defendant.profile?.familyIsVictim != true ? "\"The kids won't know their parent when this is over.\"" : "\"Years. I'll be old when this is over.\"", "\"We'll be there every visiting day. Every one.\""])
                    : rng.pick(["\"We'll be waiting when it's over.\"", "\"It's hard. But it could have been worse, and we know it.\""])
            case (true, false) where timeServed:
                words = rng.pick(["\"\(dl) is coming home tonight. It's been a long few months.\"", "\"We've got the car out front. We're going home.\"",
                                  "\"The time's done. Now we make sure \(dl) never sees the inside of that jail again.\""])
            case (true, false):
                words = rng.pick(["\"Now the work starts. We'll make sure every appointment gets kept.\"", "\"We're just grateful to have \(dl) home tonight.\"",
                                  job.map { _ in "\"Keeping that job is everything. The judge understood.\"" } ?? "\"This is the last time. It has to be.\""])
            }
            lines.append("\(who): \(words)")
        } else if convicted && active && c.defendant.isReturning {
            lines.append(rng.pick(["A courthouse regular in the gallery: \"Seen \(dl) in here before. Hope this is the last time.\"",
                                   "A deputy, escorting \(dl) out: \"Let's go.\" \(dl) didn't look back."]))
        }

        // Cameras, when the case drew them
        if c.mediaAttention >= 3 {
            lines.append(rng.pick(["A crowd of reporters waited on the courthouse steps; neither side stopped to talk beyond brief statements.",
                                   "WHCN-TV carried the announcement live from the courthouse steps.",
                                   "The case drew a full gallery, and several people left in tears."]))
        }
        _ = sentence
        return lines
    }

    private static func makeNews(_ c: CourtCase, county: County, judgeLast: String, date: Date, convicted: Bool,
                                 dismissed: Bool, plea: PleaKind?, pleaLaw: Law?, sentence: String, active: Bool,
                                 timeServed: Bool = false, reactions: [String], countsConvicted: Int = 0, lead: Law? = nil) -> NewsItem {
        let d = c.defendant
        var rng = SeededRNG(seed: c.seed ^ 0x5EED_AB1E)
        // A conviction story leads with the most serious count the defendant was actually convicted of.
        let title = (convicted ? lead?.title : nil) ?? c.charges.first?.law.title ?? "charges"
        let facts = NewsDesk.VerdictFacts(name: d.name, last: d.lastName, age: d.age, judge: judgeLast, offense: title.lowercased(),
                                          headline: c.headline, place: c.investigation?.facts?.town, countsTotal: c.charges.count,
                                          countsConvicted: countsConvicted, sentence: sentence, active: active, returning: d.isReturning,
                                          custodyDays: c.background?.custodyDays ?? 0, victim: c.victimName, mediaAttention: c.mediaAttention,
                                          timeServed: timeServed)
        let headline: String
        var body: String
        if dismissed {
            headline = rng.pick(["Charges against \(d.name) dismissed over trial delays", "Too long a wait: judge tosses \(d.lastName) case",
                                 "Speedy-trial ruling ends \(d.lastName) prosecution"])
            body = "Superior Court Judge \(judgeLast) dismissed the \(title.lowercased()) case against \(d.name), \(d.age), finding the delay in bringing it to trial violated the constitutional right to a speedy trial."
        } else if let plea, convicted {
            let offense = (pleaLaw?.title ?? title).lowercased()
            switch plea {
            case .guilty:
                headline = rng.pick(["\(d.name) pleads guilty to \(offense)", "\(d.lastName) admits \(offense) in plea deal", "Plea ends \(d.lastName) case before trial"])
                body = "\(d.name), \(d.age), pleaded guilty to \(offense) before Judge \(judgeLast) in Hollis County Superior Court"
            case .alford:
                headline = rng.pick(["\(d.name) enters Alford plea to \(offense)", "Maintaining innocence, \(d.lastName) takes Alford plea"])
                body = "\(d.name), \(d.age), entered an Alford plea to \(offense) before Judge \(judgeLast), maintaining innocence while conceding the State's evidence would likely convict"
            case .noContest:
                headline = rng.pick(["\(d.name) pleads no contest to \(offense)", "No contest plea from \(d.lastName)"])
                body = "\(d.name), \(d.age), pleaded no contest to \(offense) before Judge \(judgeLast) in Hollis County Superior Court"
            }
            body += sentence.isEmpty ? "." : ", and was sentenced to \(sentence)."
        } else if convicted {
            headline = NewsDesk.convictionHeadline(facts, rng: &rng)
            body = NewsDesk.lede(facts, convicted: true, rng: &rng)
        } else {
            headline = NewsDesk.acquittalHeadline(facts, rng: &rng)
            body = NewsDesk.lede(facts, convicted: false, rng: &rng)
        }
        // What the case was about, in the paper's words.
        if let first = Exhibits.sentences(c.summary).first, first.count < 320 {
            var names = Set((c.witnesses.map(\.name) + [d.name, c.victimName ?? "", county.name] + county.towns)
                .flatMap { $0.components(separatedBy: " ") })
            names.remove("")
            body += " " + rng.pick(["Prosecutors said that ", "According to court records, ", ""])
                .capitalizedFirstIfStart(of: first, names: names, context: c.summary)
        }
        switch (c.mood, convicted) {
        case (.wantsConviction, false):
            body += " " + rng.pick(["The verdict drew angry reactions from the gallery.", "Someone in the back row shouted as the verdict was read.", "Several people walked out before the judge finished."])
        case (.wantsConviction, true) where !active:
            body += " " + rng.pick(["Some in the community questioned whether the sentence was enough.", "Outside, a small group said probation wasn't justice."])
        case (.sympathetic, true) where active:
            body += " " + rng.pick(["Several supporters wept as deputies led the defendant away.", "A row of supporters in matching T-shirts sat silent."])
        case (.sympathetic, false):
            body += " " + rng.pick(["Supporters cheered outside the courthouse.", "Supporters hugged on the courthouse steps."])
        case (.divided, _):
            body += " " + rng.pick(["Reaction outside the courthouse was split.", "Two groups gathered on opposite sides of the courthouse steps.", "Opinions in the hallway afterward were as divided as the evidence."])
        default:
            break
        }
        // Two or three voices, not one.
        var quotes = reactions
        let take = min(quotes.count, c.mediaAttention >= 2 ? 3 : 2)
        for _ in 0..<take {
            let index = Int(rng.next() % UInt64(max(1, quotes.count)))
            body += " " + quotes.remove(at: index)
        }
        body += " " + NewsDesk.kicker(facts, convicted: convicted, rng: &rng)
        return NewsItem(date: date, kind: .verdict, headline: headline, body: body, docket: c.docket,
                        prominence: c.mediaAttention, byline: NewsDesk.byline(NewsDesk.courts, paper: county.newspaper), section: "Courts")
    }
}

private extension String {
    /// Joins a lead-in like "According to court records, " to a sentence. A leading common word is lowercased to
    /// fit after the lead-in; a name keeps its capital.
    func capitalizedFirstIfStart(of sentence: String, names: Set<String>, context: String) -> String {
        guard !isEmpty else { return sentence }
        let word = String(sentence.prefix { $0.isLetter || $0 == "'" })
        let letters = word.filter(\.isLetter)
        // Keep the capital on a name, an acronym, "I", or any word the case text capitalizes mid-sentence.
        let acronym = letters.count >= 2 && letters.allSatisfy(\.isUppercase)
        let midSentence = context.range(of: "[a-z,;] \(NSRegularExpression.escapedPattern(for: word))\\b", options: .regularExpression) != nil
        let keep = word.isEmpty || word == "I" || acronym || names.contains(word) || midSentence
        let body = keep ? sentence : sentence.prefix(1).lowercased() + sentence.dropFirst()
        return self + body
    }
}
