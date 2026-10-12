import Foundation

/// How a piece of prosecution evidence was obtained, which decides which motions can target it.
enum Acquisition {
    case none
    case search
    case statement
}

struct EvidenceSeed {
    let kind: EvidenceKind
    let weight: Int
    let title: String
    let detail: String
    let acquisition: Acquisition

    init(_ kind: EvidenceKind, _ weight: Int, _ title: String, _ detail: String, _ acquisition: Acquisition = .none) {
        self.kind = kind
        self.weight = weight
        self.title = title
        self.detail = detail
        self.acquisition = acquisition
    }
}

struct WitnessSeed {
    /// A token like "{V}" or "{DET}", or nil for a random new name.
    let name: String?
    let role: String
    let direct: [String]
    let cross: [String]
    let weight: Int
    /// Lay witnesses can be impeached with generic credibility problems.
    let lay: Bool
}

struct SecondaryCharge {
    let lawID: String
    let specification: String
    let chance: Double
    let threshold: Int
}

/// A blueprint for one kind of case. The generator combines it with random people,
/// evidence subsets, motions, objections, twists, and ethics dilemmas.
struct CaseTemplate {
    let key: String
    let category: LawCategory
    let headlines: [String]
    let primaryLaw: String
    let lesserLaw: String?
    let threshold: Int
    let lesserThreshold: Int
    let specification: String
    var secondary: [SecondaryCharge] = []
    let ageRange: ClosedRange<Int>
    var occupations: [String] = []
    var requiresFelonyPrior = false
    let hasVictim: Bool
    let summaries: [String]
    let prosecutionEvidence: [EvidenceSeed]
    let defenseEvidence: [EvidenceSeed]
    let prosecutionWitnesses: [WitnessSeed]
    let defenseWitnesses: [WitnessSeed]
    let prosecutionTheory: [String]
    let defenseTheory: [String]
    let aggravating: [String]
    let mitigating: [String]
    var victimImpacts: [String] = []
    var allocutions: [String] = []
    let guiltyTruths: [String]
    let innocentTruths: [String]
    let moods: [PublicMood]
    let doctrines: [String]
    var extras: [String: [String]] = [:]
}

struct ObjectionSeed {
    let question: String
    let answer: String
    let raisedBy: Side
    /// True when the objection arises while the opposing lawyer cross-examines.
    let onCross: Bool
    let grounds: String
    let shouldSustain: Bool
    let explanation: String
    let doctrineID: String
    let weight: Int
    var needsVictim: Bool = false
}

struct MotionSeed {
    let kind: MotionKind
    let facts: String
    let shouldGrant: Bool
    let explanation: String
    let doctrines: [String]
    /// Evidence kinds this fact pattern fits (empty means any).
    var kinds: [EvidenceKind] = []
}

struct TwistSeed {
    let text: String
    var mitigating: String? = nil
    var aggravating: String? = nil
    var mood: PublicMood? = nil
    var mediaBoost: Int = 0
    var doctrine: String? = nil
}

struct Impeachment {
    let text: String
    /// Amount subtracted from the witness's weight (negative bolsters).
    let penalty: Int
}
