import Foundation

// MARK: - The decision journal

/// One decision the judge made, or what came of one, kept for the whole career.
struct JournalEntry: Codable, Hashable {
    enum Kind: String, Codable {
        case caseDrawn, verdict, sentence, bondRelease, bondHeld, heldWithoutBond, earlyRelease, continuance, missedCourt
        case reoffense, jail, delay, appeal, outcome, publicReaction, callback
    }
    var date: Date
    var kind: Kind
    var name: String
    var docket: String
    var category: String?
    var detail: String
    /// Short facts the director can test: "convicted", "active", "releasedViolentOnBond", "theme:weapon".
    var flags: [String]
}

/// Every decision of a career, written to its own file as it happens so saving the game stays fast and the early
/// years are never trimmed away. The file belongs to one career: a new career (a new seed) starts a new file.
final class DecisionJournal {
    private var openSeed: UInt64?
    private var loaded: [JournalEntry] = []

    private func url(for seed: UInt64) -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("judgesim-journal-\(seed).jsonl")
    }

    private func open(_ seed: UInt64) {
        guard openSeed != seed else { return }
        // A different seed means the old career was abandoned: its journal goes with it.
        if let old = openSeed { try? FileManager.default.removeItem(at: url(for: old)) }
        openSeed = seed
        loaded = []
        guard let data = try? Data(contentsOf: url(for: seed)) else { return }
        let decoder = JSONDecoder()
        for line in data.split(separator: 0x0A) {
            if let entry = try? decoder.decode(JournalEntry.self, from: Data(line)) { loaded.append(entry) }
        }
    }

    func entries(seed: UInt64) -> [JournalEntry] {
        open(seed)
        return loaded
    }

    func record(_ entry: JournalEntry, seed: UInt64) {
        open(seed)
        loaded.append(entry)
        guard var line = try? JSONEncoder().encode(entry) else { return }
        line.append(0x0A)
        let file = url(for: seed)
        if let handle = try? FileHandle(forWritingTo: file) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: line)
        } else {
            try? line.write(to: file)
        }
    }

    /// Wipes the career's journal (a career erased on purpose).
    func erase(seed: UInt64) {
        try? FileManager.default.removeItem(at: url(for: seed))
        loaded = []
        openSeed = seed
    }
}

// MARK: - Tags for every written case

/// The flags the director reads off every case: genre, weight, who is hurt, and what it's about. They come from the
/// case's own data and text, so a new case is tagged the moment it is written.
enum CaseTags {
    nonisolated(unsafe) private static var cache: [String: Set<String>] = [:]

    private static let themes: [(String, [String])] = [
        ("weapon", ["gun", "pistol", "firearm", "rifle", "shot ", "shooting", "knife", "stabb", "shotgun"]),
        ("drugs", ["cocaine", "fentanyl", "opioid", "heroin", "oxycodone", "marijuana", "pills", "overdose", "methamphetamine"]),
        ("child", ["child", "toddler", "baby", "infant", "daycare", "teenage", "juvenile", "preschool"]),
        ("elder", ["elderly", "nursing home", "older adult", "grandmother", "grandfather", "88-year", "81-year"]),
        ("domestic", ["ex-husband", "ex-wife", "boyfriend", "girlfriend", "husband", "wife", "protective order", "domestic"]),
        ("money", ["insurance", "bank", "loan", "embezzl", "account", "fraud", "scam", "payroll", "checks"]),
        ("fire", ["fire ", "arson", "burned", "burning"]),
        ("vehicle", ["crash", "dwi", "truck", "driver", "motorcycle", "tractor", "golf cart", "vehicle"]),
        ("digital", ["online", "text message", "facebook", "computer", "password", "email", "phone records"]),
    ]

    static func of(_ t: CaseTemplate) -> Set<String> {
        if let hit = cache[t.key] { return hit }
        var tags: Set<String> = ["genre:\(t.category.rawValue)"]
        let law = LawLibrary.law(t.primaryLaw)
        switch law.ncClass {
        case .A?, .B1?, .B2?, .C?, .D?, .E?: tags.insert("weight:heavy")
        case .F?, .G?, .H?: tags.insert("weight:medium")
        default: tags.insert("weight:light")
        }
        tags.insert(t.hasVictim ? "victim" : "noVictim")
        if t.victimDies { tags.insert("death"); tags.insert("weight:heavy"); tags.remove("weight:light"); tags.remove("weight:medium") }
        if t.moods.contains(.sympathetic) { tags.insert("mood:sympathetic") }
        if t.moods.contains(.wantsConviction) { tags.insert("mood:wantsConviction") }
        let text = (t.summaries.joined(separator: " ") + " " + t.specification).lowercased()
        for (theme, words) in themes where words.contains(where: { text.contains($0) }) { tags.insert("theme:\(theme)") }
        cache[t.key] = tags
        return tags
    }
}

extension CaseTags {
    /// How common this kind of crime is in a real county's courts: petty theft, fleeing, resisting, trespass and
    /// driving offenses fill the dockets, and murder is rare. The director multiplies a case's score by this.
    static func frequency(_ t: CaseTemplate) -> Double {
        switch LawLibrary.law(t.primaryLaw).ncClass {
        case .misdA1?, .misd1?, .misd2?, .misd3?: return 2.0
        case .I?: return 1.8
        case .H?: return 1.5
        case .G?: return 1.1
        case .F?: return 1.0
        case .E?: return 0.7
        case .D?: return 0.55
        case .C?: return 0.4
        case .B2?, .B1?: return 0.35
        case .A?: return 0.3
        case nil: return 1.0
        }
    }
}

extension StoryCases {
    static let byKey: [String: CaseTemplate] = Dictionary(all.map { ($0.key, $0) }, uniquingKeysWith: { a, _ in a })
}

// MARK: - The director

/// What the playthrough looks like right now, read from the journal and the court's own books. The director scores
/// every story that could come next against it.
struct DirectorSnapshot {
    var week = 0
    var jail = 0
    var beds = 0
    var awaiting = 0
    var pipelineTarget = 0.0
    /// The last cases drawn, newest first.
    var drawn: [Set<String>] = []
    /// The last verdicts, newest first: true when the defendant was convicted.
    var verdicts: [Bool] = []
    var activeShare: Double? = nil
    var reoffenses90 = 0
    var violentReleases90 = 0

    private func genre(_ tags: Set<String>) -> String { tags.first { $0.hasPrefix("genre:") } ?? "" }

    func score(_ t: CaseTemplate) -> (value: Double, why: [String]) {
        let tags = CaseTags.of(t)
        let myGenre = genre(tags)
        var s = CaseTags.frequency(t)
        var why: [String] = []
        if s >= 1.8 { why.append("a common offense") } else if s <= 0.55 { why.append("a rare, serious case") }

        // Genre: never the same kind again and again, and favor what hasn't come up in a while.
        let sameGenre = drawn.prefix(8).filter { genre($0) == myGenre }.count
        if sameGenre > 0 { s *= pow(0.5, Double(sameGenre)); why.append("\(sameGenre) \(myGenre.dropFirst(6)) lately") }
        else if !drawn.prefix(12).contains(where: { genre($0) == myGenre }) { s *= 1.5; why.append("fresh genre") }
        for theme in tags where theme.hasPrefix("theme:") && drawn.prefix(5).contains(where: { $0.contains(theme) }) { s *= 0.8 }

        // Weight: a heavy case isn't followed by another; a long run of light ones makes room for a heavy one.
        let heavy = tags.contains("weight:heavy"), light = tags.contains("weight:light")
        let heavyRecent = drawn.prefix(3).filter { $0.contains("weight:heavy") }.count
        if heavy && heavyRecent >= 1 { s *= 0.5; why.append("a heavy case just ran") }
        if heavy && drawn.count >= 5 && !drawn.prefix(5).contains(where: { $0.contains("weight:heavy") }) { s *= 1.4; why.append("time for a heavy case") }
        if heavy && week < 4 { s *= 0.4; why.append("easing in") }

        // The jail and the backlog: a full jail and a long list want quick cases, not more murders.
        let load = beds > 0 ? Double(jail) / Double(beds) : 0
        if load >= 0.85 { if light { s *= 1.6; why.append("jail \(Int(load * 100))% full") } else if heavy { s *= 0.7 } }
        else if load < 0.4 && week > 6 && heavy { s *= 1.2 }
        if Double(awaiting) > pipelineTarget * 1.5 && light { s *= 1.3; why.append("long wait list") }

        // The verdicts the player has been giving: a run of acquittals brings a case the public wants decided; a run of
        // convictions brings one that tests mercy.
        if verdicts.count >= 6 {
            let recent = verdicts.prefix(6)
            let convicted = recent.filter { $0 }.count
            if 6 - convicted >= 4 && tags.contains("mood:wantsConviction") { s *= 1.5; why.append("a run of acquittals") }
            if convicted >= 5 && tags.contains("mood:sympathetic") { s *= 1.5; why.append("a run of convictions") }
        }
        if let activeShare, activeShare > 0.75, tags.contains("mood:sympathetic") { s *= 1.2 }

        // What the court's releases did: people who came back put victims in the story.
        if reoffenses90 >= 2 && tags.contains("victim") { s *= 1.3; why.append("recent reoffenses") }
        if violentReleases90 >= 2 && tags.contains("theme:weapon") { s *= 1.3 }
        return (s, why)
    }

    /// A weighted draw: the best-fitting stories are the likeliest, but a poor fit still has a chance.
    func pick(from pool: [CaseTemplate], using rng: inout SeededRNG) -> CaseTemplate {
        guard pool.count > 1 else { return pool[0] }
        let weights = pool.map { pow(max(0.02, score($0).value), 1.5) }
        var roll = Double.random(in: 0..<weights.reduce(0, +), using: &rng)
        for (template, weight) in zip(pool, weights) {
            roll -= weight
            if roll <= 0 { return template }
        }
        return pool[pool.count - 1]
    }
}
