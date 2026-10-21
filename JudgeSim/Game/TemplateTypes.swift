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
    /// A fully written case: every witness, objection, and argument is authored, and nothing generic is mixed in.
    var story: StoryExtras? = nil
    /// People whose sex the case fixes, keyed "D", "V", or "ALT".
    var genders: [String: Gender] = [:]

    /// Every sex the case requires: its own, the written story's, and what the charges themselves require
    /// (assault on a female is committed by a male on a female, G.S. 14-33(c)(2)).
    /// Whether the victim named {V} died, by the story's word or by a homicide count that names {V}.
    var victimDies: Bool {
        if let died = story?.victimDied { return died }
        let deathLaws = ["murder1", "murder2", "volManslaughter", "invManslaughter", "felonyDBV", "misdDBV",
                         "deathByDistribution", "patientNeglect", "concealingDeath"]
        func namesV(_ text: String) -> Bool { text.contains("{V}") || text.contains("{VL}") }
        if deathLaws.contains(primaryLaw) && (namesV(specification) || story == nil) { return true }
        return secondary.contains { deathLaws.contains($0.lawID) && namesV($0.specification) }
    }

    var requiredGenders: [String: Gender] {
        var result = genders.merging(story?.genders ?? [:]) { a, _ in a }
        let laws = [primaryLaw] + [lesserLaw].compactMap { $0 } + secondary.map(\.lawID)
        if laws.contains("assaultFemale") {
            result["D"] = result["D"] ?? .male
            result["V"] = result["V"] ?? .female
        }
        return result
    }
}

/// The parts of a written case that templates don't otherwise carry.
struct StoryExtras {
    /// What the lead investigator's file shows, as (days after the incident, what happened).
    var timeline: [(Int, String)]
    var howIdentified: String
    var notDone: [String] = []
    /// The defendant's own testimony, if they take the stand.
    var defendantExam: [ExamLine]
    /// Objections, tied to a witness by position: State witnesses first, then the defense's.
    var objections: [(witness: Int, seed: ObjectionSeed)] = []
    var prosecutionOpening: String
    var defenseOpening: String
    var prosecutionClosing: String
    var defenseClosing: String
    /// When the story has to happen at a particular time of year.
    var when: StoryDate? = nil
    /// People whose sex the story fixes (its text calls them an aunt, an uncle, a daughter...), keyed "D", "V", or "ALT".
    var genders: [String: Gender] = [:]
    /// Whether {V} died, when the charges alone don't say (a hit and run that killed, a murder of someone else).
    var victimDied: Bool? = nil
    /// Who {V} is, as the story tells it, for the victim's profile.
    var victim: VictimFacts? = nil
    /// When it happened, e.g. "4:12 p.m."; otherwise read from the timeline.
    var time: String? = nil
    /// Where the defendant works, as the story names it (tokens allowed), and whether the job ended over this case.
    var employer: String? = nil
    var employmentEnded = false
    /// Where the defendant goes to school, as the story names it.
    var school: String? = nil
    /// What checking the alibi turns up: records that back it up when the defendant didn't do it, and break it when
    /// the defendant did. Only for cases where a defense witness puts the defendant somewhere else.
    var alibiCheck: AlibiCheck? = nil
}

/// What a written case says about its victim, so the victim's profile matches the story.
/// The records that test an alibi, written for the case.
struct AlibiCheck {
    struct Finding {
        let title: String
        let detail: String
        let kind: EvidenceKind
    }
    /// What the records show when the defendant was where the witness says.
    let holds: Finding
    /// What they show when the defendant wasn't.
    let breaks: Finding
}

struct VictimFacts {
    var age: Int? = nil
    var occupation: String? = nil
    var relationship: String? = nil
    var family: String? = nil
    var harm: [String]? = nil
    var record: String? = nil
}

enum StoryDate {
    /// Thanksgiving Day: the fourth Thursday of November.
    case thanksgiving
    /// Any day in one of these months (1 = January).
    case months([Int])
    /// A cold case: about this many years before the session.
    case yearsAgo(Int)

    /// The most recent qualifying day that leaves at least `minDays` before the session.
    func incident(before session: Date, minDays: Int, using rng: inout SeededRNG) -> Date? {
        let cal = Calendar.current
        if case .yearsAgo(let years) = self {
            return cal.date(byAdding: .day, value: -(max(years * 365, minDays) + rng.int(0...60)), to: session)
        }
        guard let latest = cal.date(byAdding: .day, value: -minDays, to: session) else { return nil }
        let year = cal.component(.year, from: latest)
        var candidates: [Date] = []
        for y in [year, year - 1, year - 2] {
            switch self {
            case .thanksgiving:
                var c = DateComponents(year: y, month: 11, weekday: 5, weekdayOrdinal: 4)
                c.hour = 12
                if let d = cal.date(from: c) { candidates.append(d) }
            case .yearsAgo:
                break
            case .months(let months):
                for m in months {
                    guard let first = cal.date(from: DateComponents(year: y, month: m, day: 1, hour: 12)),
                          let days = cal.range(of: .day, in: .month, for: first)?.count,
                          let d = cal.date(byAdding: .day, value: rng.int(0...(days - 1)), to: first) else { continue }
                    candidates.append(d)
                }
            }
        }
        return candidates.filter { $0 <= latest }.max()
    }
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
    /// Kinds of case this exchange fits (empty means any).
    var settings: Set<CaseSetting> = []
    /// Only fits a witness who saw or heard the events firsthand.
    var eyewitnessOnly: Bool = false
    /// Only fits an officer, investigator, or expert.
    var officialOnly: Bool = false
    /// Words, one of which must appear somewhere in the case (summary, charges, evidence, testimony). Empty means any case.
    var needsFacts: [String] = []
    /// Words, one of which must appear in the witness's role (empty means any role).
    var roleWords: [String] = []
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
    /// Kinds of case this fits (empty means any).
    var settings: Set<CaseSetting> = []
}

struct Impeachment {
    let text: String
    /// Amount subtracted from the witness's weight (negative bolsters).
    let penalty: Int
    /// Safe to use on the complaining witness.
    var victimSafe: Bool = true
    /// Kinds of case this fits (empty means any).
    var settings: Set<CaseSetting> = []
    /// Only fits a witness who saw the events firsthand.
    var eyewitness: Bool = false
    /// How the point is drawn out on cross: alternate (question, answer) pairs.
    var asked: [(String, String)] = []
}

// MARK: - Fitting shared text to a case

/// What kind of facts a case turns on, so shared text (objections, testimony, gaps, follow-up evidence) fits it.
enum CaseSetting: String, Codable, Hashable {
    /// Something happened at a place, in front of people: assaults, robberies, break-ins.
    case scene
    /// Records and computers: fraud, embezzlement, hacking, perjury.
    case paper
    /// Drugs found, sold, or delivered.
    case drugs
    /// Driving: impaired driving, crashes, chases.
    case road

    static func of(category: LawCategory, key: String) -> CaseSetting {
        switch key {
        case "perjuryTrial", "prescriptionForgery": return .paper
        default: break
        }
        switch category {
        case .whiteCollar, .cyber: return .paper
        case .drugs: return .drugs
        case .traffic: return .road
        default: return .scene
        }
    }
}

/// How the police first got involved.
enum CaseOrigin: Hashable {
    /// A 911 call about something that just happened.
    case call
    /// An officer stopped a vehicle.
    case stop
    /// A planned search warrant after an investigation.
    case warrant
    /// Someone reported it afterward.
    case report
    /// An audit, complaint, or records review.
    case records

    static func of(key: String, setting: CaseSetting) -> CaseOrigin {
        if setting == .paper { return .records }
        switch key {
        case "trafficStopDrugs", "habitualDWI", "fleeingElude", "felonGun": return .stop
        case "trapHouse", "hiddenGun": return .warrant
        case "schoolThreat", "animalHoarding", "fakeCop", "stalking", "custodyFlight", "shakenInfant",
             "protectiveOrderParty", "witnessIntimidation": return .report
        default: return .call
        }
    }
}

/// Everything known about a case, for checking whether a shared line fits it.
struct CaseFacts {
    let key: String
    let category: LawCategory
    let setting: CaseSetting
    let origin: CaseOrigin
    let hasVictim: Bool
    /// Summaries, charges, evidence, and testimony, lowercased.
    let text: String

    init(key: String, category: LawCategory, hasVictim: Bool, text: String) {
        self.key = key
        self.category = category
        self.setting = CaseSetting.of(category: category, key: key)
        self.origin = CaseOrigin.of(key: key, setting: setting)
        self.hasVictim = hasVictim
        self.text = text.lowercased()
    }

    init(_ c: CourtCase) {
        var parts: [String] = [c.summary]
        parts += c.charges.map { $0.specification }
        parts += c.evidence.map { $0.title + ". " + $0.detail }
        for w in c.witnesses { parts += w.direct + w.cross }
        self.init(key: c.templateKey, category: c.category, hasVictim: c.victimName != nil, text: parts.joined(separator: " "))
    }

    /// True when any of the words appears in the case (or when no words are given).
    func mentions(_ words: [String]) -> Bool {
        words.isEmpty || words.contains { text.contains($0) }
    }

    /// Alcohol or another impairing substance is part of the case.
    var impaired: Bool { mentions(["impair", "alcohol", "blew 0", "breath test", "intoxilyzer", "dwi", "drunk", "drinking", "blood-alcohol"]) }
    /// Money moved, was taken, or was paid.
    var money: Bool { mentions(["$", "money", "payroll", "invoice", "deposit", "transfer", "account", "wallet", "check"]) }
    /// Who did it is in dispute: descriptions, lineups, footage.
    var identity: Bool { mentions(["description", "lineup", "identif", "mask", "hoodie", "matching", "unknown", "footage"]) }
}
