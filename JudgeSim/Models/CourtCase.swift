import Foundation

enum Side: String, Codable, Hashable {
    case prosecution = "State"
    case defense = "Defense"
}

enum EvidenceKind: String, Codable, Hashable {
    case physical, forensic, digital, document, statement, video

    var icon: String {
        switch self {
        case .physical: return "shippingbox.fill"
        case .forensic: return "testtube.2"
        case .digital: return "iphone"
        case .document: return "doc.text.fill"
        case .statement: return "quote.bubble.fill"
        case .video: return "video.fill"
        }
    }

    var label: String { rawValue.capitalized }
}

enum CourtKind: String, Codable, Hashable {
    case felony
    case misdemeanorAppeal

    var label: String {
        switch self {
        case .felony: return "Felony bench trial"
        case .misdemeanorAppeal: return "Misdemeanor appeal (trial de novo)"
        }
    }
}

struct Defendant: Codable, Hashable {
    var personID: UUID
    var name: String
    var age: Int
    var occupation: String
    var background: String
    var priors: [PriorConviction]
    var probation: ProbationTerm?
    var history: [PersonRecord.Appearance]
    /// Work, education, family, and residence (optional for older saves).
    var profile: DefendantProfile? = nil
    /// Post-release supervision the defendant is on (optional for older saves).
    var postRelease: PostReleaseTerm? = nil
    /// Earlier supervision violations (optional for older saves).
    var violations: [SupervisionViolation]? = nil

    /// On probation or post-release supervision, so the court rules on a violation after the new case.
    var underSupervision: Bool { probation != nil || postRelease != nil }

    var lastName: String { name.components(separatedBy: " ").last ?? name }
    var isReturning: Bool { !history.isEmpty }
}

struct Evidence: Identifiable, Codable, Hashable {
    var id = UUID()
    var exhibit: String
    var title: String
    var detail: String
    var side: Side
    var kind: EvidenceKind
    /// How strongly this item points toward (State) or away from (defense) guilt. Never shown.
    var weight: Int
    /// Set when the item came in after a continuance, e.g. "Obtained during the continuance".
    var supplemental: String? = nil
}

struct Witness: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var role: String
    var calledBy: Side
    var direct: [String]
    var cross: [String]
    var weight: Int
    /// Ordinary eyewitness rather than an officer or expert. Optional for older saves.
    var lay: Bool? = nil
    /// The defendant, testifying in their own defense.
    var isDefendant: Bool? = nil
    /// Question-by-question testimony (optional for older saves; direct and cross hold the key lines).
    var exchanges: [TestimonyExchange]? = nil
}

struct Objection: Identifiable, Codable, Hashable {
    var id = UUID()
    var witnessID: UUID
    var question: String
    var answer: String
    var raisedBy: Side
    var grounds: String
    /// How an appellate court would view the ruling. Never shown during play.
    var shouldSustain: Bool
    var appellateNote: String
    var doctrineID: String
    var weightIfAdmitted: Int
}

enum MotionKind: String, Codable, Hashable {
    case suppressSearch
    case suppressStatement
    case dismissSpeedyTrial
    case suppressIdentification
    case excludePriorActs
    case dismissIndictment

    var title: String {
        switch self {
        case .suppressSearch: return "Motion to Suppress Evidence"
        case .suppressStatement: return "Motion to Suppress Statement"
        case .dismissSpeedyTrial: return "Motion to Dismiss: Speedy Trial"
        case .suppressIdentification: return "Motion to Suppress Identification"
        case .excludePriorActs: return "Motion in Limine: Other Acts (Rule 404(b))"
        case .dismissIndictment: return "Motion to Dismiss: Defective Indictment"
        }
    }
}

struct Motion: Identifiable, Codable, Hashable {
    var id = UUID()
    var kind: MotionKind
    var facts: String
    var defenseArgument: String
    var prosecutionResponse: String
    var targetEvidenceID: UUID?
    /// How an appellate court would view the ruling. Never shown during play.
    var shouldGrant: Bool
    var appellateNote: String
    var doctrineIDs: [String]
    /// For a motion to dismiss one count: the count it attacks (optional for older saves).
    var targetChargeID: UUID? = nil
}

struct Charge: Identifiable, Codable, Hashable {
    var id = UUID()
    var count: Int
    var lawID: String
    var lesserLawID: String?
    var specification: String
    var threshold: Int
    var lesserThreshold: Int

    var law: Law { LawLibrary.law(lawID) }
    var lesserLaw: Law? { lesserLawID.map { LawLibrary.law($0) } }
}

struct EthicsOption: Identifiable, Codable, Hashable {
    var id = UUID()
    var label: String
    var result: String
    /// Optional story the local paper runs later.
    var laterHeadline: String?
}

struct EthicsEvent: Codable, Hashable {
    var title: String
    var body: String
    var doctrineID: String
    var options: [EthicsOption]
}

enum PublicMood: String, Codable, Hashable {
    case wantsConviction, sympathetic, divided, indifferent

    var label: String {
        switch self {
        case .wantsConviction: return "Community wants accountability"
        case .sympathetic: return "Community sympathizes with the defendant"
        case .divided: return "Community is divided"
        case .indifferent: return "Little public attention"
        }
    }

    var icon: String {
        switch self {
        case .wantsConviction: return "flame.fill"
        case .sympathetic: return "heart.fill"
        case .divided: return "arrow.left.arrow.right"
        case .indifferent: return "moon.zzz.fill"
        }
    }
}

enum VictimStance: String, Codable, Hashable {
    case wantsMaximum, wantsAccountability, wantsLeniency, none
}

enum TreatmentNeed: String, Codable, Hashable {
    case none, substance, mentalHealth, both

    var substance: Bool { self == .substance || self == .both }
    var mentalHealth: Bool { self == .mentalHealth || self == .both }
}

/// Facts outside the trial record that counsel know about and the judge can ask about.
struct CaseBackground: Codable, Hashable {
    var pleaOffer: String?
    var pleaRejection: String?
    /// Days of pretrial confinement that count as credit. A defendant who has since made bond keeps the credit.
    var custodyDays: Int
    var bondStatus: String
    /// True once the defendant has made bond after time in jail: the credit stands, but the clock stops.
    var onRelease: Bool?
    var restitution: Int
    var restitutionBasis: String?
    var victimStance: VictimStance
    var victimStanceDetail: String
    var treatmentNeed: TreatmentNeed
    var treatmentDetail: String?
    var treatmentBedAvailable: Bool
    var employmentPlan: String?
    var indigent: Bool
    var supportPeople: String?
    var willTestify: Bool
    var discoveryIssue: String?
    var stateObjectsToASR: Bool
    var hiddenMitigator: String?
    var hiddenAggravator: String?
    var attorneyFeeEstimate: Int
    // Plea arrangement presented to the court (optional for older saves).
    var arrangementPresented: Bool?
    var arrangementLawID: String?
    var arrangementTerms: String?
    /// nil: no habitual indictment. true: status admitted. false: indictment dismissed.
    var arrangementHabitual: Bool?
    /// Whether the State served 30 days' notice of the probation point and aggravating factors (G.S. 15A-1340.16(a6)).
    var probationPointNotice: Bool?
    /// A prior conviction the defense disputes, and why.
    var disputedPriorID: UUID?
    var disputedPriorReason: String?
    /// Whether the State joins a motion for conditional discharge under G.S. 15A-1341(a4).
    var stateJoinsDischarge: Bool?
    /// What the district court imposed before the defendant appealed for a trial de novo.
    var districtCourtSentence: String?
    /// "bottom" (bottom of the presumptive range), "suspended", or "open" sentencing.
    var arrangementKind: String?
    var stateConsentsNoContest: Bool?
}

/// A motion by the State or the defense to continue the trial, with a concrete reason drawn from the case.
struct ContinuanceMotion: Codable, Hashable {
    var movant: Side
    /// Short label, e.g. "Lab report not back".
    var title: String
    /// What the moving party tells the court.
    var argument: String
    /// What the other side says.
    var opposition: String
    /// The follow-up that comes back as new evidence if the motion is granted.
    var request: EvidenceRequest
    /// What it means to go forward now.
    var ifDenied: String
    /// How long the movant says it needs.
    var suggestedDays: Int
}

/// What actually happened. The player never sees this directly; it may surface later in the news.
struct HiddenTruth: Codable, Hashable {
    var actuallyGuilty: Bool
    var revelation: String
}

struct CourtCase: Identifiable, Codable, Hashable {
    var id = UUID()
    var seed: UInt64
    var templateKey: String
    var docket: String
    var court: CourtKind
    var sessionDate: Date
    var headline: String
    var category: LawCategory
    var summary: String
    var defendant: Defendant
    var victimName: String?
    var charges: [Charge]
    var habitualIndicted: Bool
    var proceduralNotes: [String]
    var motions: [Motion]
    var prosecutor: String
    var defenseAttorney: String
    var investigatingAgency: String
    var prosecutionOpening: String
    var defenseOpening: String
    var prosecutionClosing: String
    var defenseClosing: String
    var evidence: [Evidence]
    var witnesses: [Witness]
    var objections: [Objection]
    var aggravating: [String]
    var mitigating: [String]
    var victimImpact: String?
    var allocution: String
    var twist: String?
    var ethics: EthicsEvent?
    var mood: PublicMood
    var mediaAttention: Int
    var truth: HiddenTruth
    var relatedDoctrines: [String]
    /// Optional so cases saved by earlier builds still load.
    var background: CaseBackground?
    /// Identifies the exact scenario so it is never repeated in a career.
    var scenarioSignature: String?
    /// What the defendant would say if they chose to testify.
    var defendantTestimony: Witness?
    /// The investigating agency's file.
    var investigation: InvestigationReport?
    /// A party's motion to continue, heard when the case is called (optional; most cases have none).
    var continuanceMotion: ContinuanceMotion? = nil

    var caption: String { "State of North Carolina v. \(defendant.name)" }

    /// What the defendant says before sentence: the written statement, or one built from this case's facts.
    func allocution(afterPlea: Bool) -> String {
        Allocutions.statement(self, afterPlea: afterPlea)
    }

    func evidence(_ id: UUID?) -> Evidence? {
        guard let id else { return nil }
        return evidence.first { $0.id == id }
    }

    func objections(for witness: Witness) -> [Objection] {
        objections.filter { $0.witnessID == witness.id }
    }

    var relevantLawIDs: [String] {
        var ids: [String] = []
        for charge in charges {
            ids.append(charge.lawID)
            if let lesser = charge.lesserLawID { ids.append(lesser) }
        }
        if habitualIndicted { ids.append("habitualFelon") }
        if defendant.probation != nil { ids.append("probationViolation") }
        if defendant.postRelease != nil { ids.append("postRelease") }
        ids.append(contentsOf: motions.flatMap(\.doctrineIDs))
        ids.append(contentsOf: objections.map(\.doctrineID))
        ids.append(contentsOf: relatedDoctrines)
        if let ethics { ids.append(ethics.doctrineID) }
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted && LawLibrary.lawIfPresent($0) != nil }
    }
}

extension CaseBackground {
    /// Held in jail awaiting trial right now.
    var isJailed: Bool { custodyDays > 0 && onRelease != true }
}
