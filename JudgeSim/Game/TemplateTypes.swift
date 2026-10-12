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

/// One question and answer written for a specific witness. Tokens like {DL} are filled in.
/// Each witness testifies in one of several versions: version k uses the k-th question and answer
/// (wrapping around when a line has fewer), so the same kind of case plays out differently each time.
struct ExamLine {
    let phase: TestimonyExchange.Phase
    let questions: [String]
    let answers: [String]
    /// Optional lines are asked in some trials and not others.
    var optional = false

    /// Asked by the side that called the witness. Extra answers are alternate versions.
    static func direct(_ question: String, _ answers: String...) -> ExamLine { ExamLine(phase: .direct, questions: [question], answers: answers) }
    static func direct(_ questions: [String], _ answers: String...) -> ExamLine { ExamLine(phase: .direct, questions: questions, answers: answers) }
    /// Asked by the other side.
    static func cross(_ question: String, _ answers: String...) -> ExamLine { ExamLine(phase: .cross, questions: [question], answers: answers) }
    static func cross(_ questions: [String], _ answers: String...) -> ExamLine { ExamLine(phase: .cross, questions: questions, answers: answers) }
    /// Asked by the side that called the witness, after cross.
    static func redirect(_ question: String, _ answers: String...) -> ExamLine { ExamLine(phase: .redirect, questions: [question], answers: answers) }
    static func redirect(_ questions: [String], _ answers: String...) -> ExamLine { ExamLine(phase: .redirect, questions: questions, answers: answers) }

    /// The same line, asked only in some trials.
    var sometimes: ExamLine { var copy = self; copy.optional = true; return copy }

    func question(_ version: Int) -> String { questions.isEmpty ? "" : questions[version % questions.count] }
    func answer(_ version: Int) -> String { answers.isEmpty ? "" : answers[version % answers.count] }
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
    /// Full testimony written for this witness. When present it replaces the generic examination.
    var exam: [ExamLine] = []
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
    /// Prior convictions every defendant in this scenario must have, by offense name from GenericPools.priorSeeds.
    var forcedPriorOffenses: [String] = []
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
    /// Only fits an ordinary eyewitness, not an officer or expert.
    var layOnly: Bool = false
}

struct MotionSeed {
    let kind: MotionKind
    let facts: String
    let shouldGrant: Bool
    let explanation: String
    let doctrines: [String]
    /// Evidence kinds this fact pattern fits (empty means any).
    var kinds: [EvidenceKind] = []
    /// Where the search happened (empty means anywhere).
    var places: [SearchPlace] = []
}

enum SearchPlace: Hashable {
    case vehicle, home, phone, person

    /// Infers where an item was found from its description.
    static func infer(_ text: String, kind: EvidenceKind) -> SearchPlace {
        let t = text.lowercased()
        if kind == .digital || t.contains("phone") || t.contains("text") || t.contains("records") { return .phone }
        for word in ["car", "truck", "trunk", "vehicle", "glovebox", "console", "passenger seat", "van", "suv"] where t.contains(word) {
            return .vehicle
        }
        for word in ["home", "house", "apartment", "closet", "bedroom", "garage", "kitchen", "residence", "shed", "attic", "drawer", "basement"] where t.contains(word) {
            return .home
        }
        return .person
    }
}

struct TwistSeed {
    var key: String = ""
    let text: String
    var mitigating: String? = nil
    var aggravating: String? = nil
    var mood: PublicMood? = nil
    var mediaBoost: Int = 0
    var doctrine: String? = nil
    var ages: ClosedRange<Int> = 16...90
    /// Makes no sense if the case resolves by plea before trial.
    var trialOnly: Bool = false
}

struct Impeachment {
    let text: String
    /// Amount subtracted from the witness's weight (negative bolsters).
    let penalty: Int
    /// Safe to use on the complaining witness.
    var victimSafe: Bool = true
}
