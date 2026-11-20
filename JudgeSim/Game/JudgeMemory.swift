import Foundation

/// What a lawyer is like to deal with. Fixed by name, so the same lawyer is the same every time.
enum LawyerStyle: String, Codable, Hashable {
    case hardliner, balanced, dealmaker   // prosecutors
    case fighter, pragmatic, stretched    // defense

    /// Styles handed out across the county's whole roster, so a handful of lawyers is never all one kind.
    nonisolated(unsafe) static var assigned: [String: LawyerStyle] = [:]

    private static func key(_ name: String) -> String {
        var k = name.components(separatedBy: ",").first ?? name
        if k.hasPrefix("ADA ") { k.removeFirst(4) }
        return k.trimmingCharacters(in: .whitespaces)
    }

    /// Gives about a quarter of the prosecutors the hardliner label and a quarter the dealmaker label (at least one of
    /// each), and the same share of defense lawyers the fighter and stretched labels. The rest have no strong style.
    static func assign(prosecutors: [String], defenders: [String]) {
        // A lawyer's reputation doesn't change when the roster does: new hires fall back to the name-based style.
        if (prosecutors + defenders).contains(where: { assigned[key($0)] != nil }) { return }
        var result: [String: LawyerStyle] = [:]
        func spread(_ names: [String], first: LawyerStyle, second: LawyerStyle, rest: LawyerStyle) {
            let keys = names.map(key).sorted { SeededRNG.stableHash("style|" + $0) < SeededRNG.stableHash("style|" + $1) }
            guard !keys.isEmpty else { return }
            let each = max(1, keys.count / 4)
            for (i, k) in keys.enumerated() {
                result[k] = i < each ? first : (i >= keys.count - each && keys.count >= 2 * each + 1 ? second : rest)
            }
        }
        spread(prosecutors, first: .hardliner, second: .dealmaker, rest: .balanced)
        spread(defenders, first: .fighter, second: .stretched, rest: .pragmatic)
        assigned = result
    }

    static func of(_ name: String, prosecutor: Bool) -> LawyerStyle {
        if let style = assigned[key(name)], prosecutor == [.hardliner, .balanced, .dealmaker].contains(style) { return style }
        let h = SeededRNG.stableHash(name) % 10
        if prosecutor { return h < 3 ? .hardliner : (h < 7 ? .balanced : .dealmaker) }
        return h < 3 ? .fighter : (h < 7 ? .pragmatic : .stretched)
    }

    var isStretched: Bool { self == .stretched }

    /// A line about the lawyer for the card; nothing for a lawyer with no strong style.
    var descriptor: String? {
        switch self {
        case .hardliner: return "has a name for asking the most the law allows."
        case .dealmaker: return "is known for bargaining early."
        case .fighter: return "contests nearly everything."
        case .stretched: return "carries a full caseload and tends to take the offer."
        default: return nil
        }
    }
}

/// One ruling the judge made, kept so both sides can learn from it.
struct RulingMemory: Codable, Hashable {
    enum Kind: String, Codable { case bond, plea, continuance }
    var date: Date
    var kind: Kind
    /// The kind of charge: category group and felony or misdemeanor ("violent-felony", "drug-misd").
    var tier: String
    /// Bond: the State's secured figure. Zero otherwise.
    var asked: Int
    /// Bond: the amount set. Zero otherwise.
    var ruled: Int
    /// Bond: the option chosen (0 promise, 1 custody, 2 unsecured, 3 secured, 4 secured with house arrest, 5 hold).
    /// Plea: the option chosen. Continuance: 0 granted, 1 denied.
    var form: Int
    /// Bond: whether the State asked for a secured bond or to hold.
    var stateWantedSecured: Bool
    /// Plea: the judge took the State's (or the joint) recommendation.
    var tookStateAsk: Bool
    /// Whether the State got what it asked for, and whether the defense did.
    var stateWon: Bool
    var defenseWon: Bool
    /// Who the ruling was about and what it was, for a lawyer to cite later (optional so a record without them still reads).
    var who: String? = nil
    var outcome: String? = nil
}

/// What the judge tends to do on bonds of a kind.
struct BondTendency {
    var n: Int
    /// Average of the amount set over the State's secured ask, on the secured bonds set.
    var ratio: Double
    var unsecuredShare: Double
    /// The average amount set on the secured bonds.
    var typical: Int
}

/// The judge's habits as the lawyers have seen them: kept short, newest weighed heaviest by only looking at recent rulings.
/// A release that went wrong: the defendant was arrested again or missed court. The lawyers remember it.
struct Fallout: Codable, Hashable {
    var date: Date
    var tier: String
    var kind: String
    var who: String
    var condition: String
}

struct JudgeMemory: Codable, Hashable {
    var rulings: [RulingMemory] = []
    var fallouts: [Fallout]? = nil

    mutating func recordFallout(_ f: Fallout) {
        var list = fallouts ?? []
        list.append(f)
        if list.count > 30 { list.removeFirst(list.count - 30) }
        fallouts = list
    }

    /// One of the last few releases that went wrong on this kind of charge.
    func recentFallout(tier: String, asOf: Date) -> Fallout? {
        (fallouts ?? []).last { $0.tier == tier && $0.date <= asOf && asOf.timeIntervalSince($0.date) < 45 * 86_400 }
    }

    /// The most recent ruling on this kind of bond that was lenient (a promise or an unsecured bond over the State's ask for
    /// money), or strict (secured with house arrest, or a hold), for a lawyer to cite.
    func precedent(tier: String, lenient: Bool, excluding who: String, asOf: Date) -> RulingMemory? {
        rulings.reversed().first { r in
            r.date <= asOf && asOf.timeIntervalSince(r.date) < 45 * 86_400 && r.kind == .bond && r.tier == tier && r.who != nil && r.who != who && r.stateWantedSecured
                && (lenient ? r.form <= 2 : (r.form >= 4))
        }
    }

    mutating func record(_ r: RulingMemory) {
        rulings.append(r)
        if rulings.count > 240 { rulings.removeFirst(rulings.count - 240) }
    }

    /// "violent-felony", "drug-misd".
    static func tier(category: LawCategory, felony: Bool) -> String {
        let group: String
        switch category {
        case .violent, .robbery: group = "violent"
        case .drugs: group = "drug"
        case .property, .whiteCollar: group = "property"
        case .traffic: group = "traffic"
        case .family: group = "family"
        default: group = "other"
        }
        return group + (felony ? "-felony" : "-misd")
    }

    /// "violent felony", "drug misdemeanor".
    static func phrase(_ tier: String) -> String {
        let parts = tier.split(separator: "-").map(String.init)
        guard parts.count == 2 else { return "such" }
        let group = parts[0] == "other" ? "" : parts[0] + " "
        return group + (parts[1] == "felony" ? "felony" : "misdemeanor")
    }

    private func recent(_ kind: RulingMemory.Kind, _ tier: String?, limit: Int) -> [RulingMemory] {
        Array(rulings.filter { $0.kind == kind && (tier == nil || $0.tier == tier) }.suffix(limit))
    }

    /// How this judge has set bonds on this kind of charge when the State wanted money. Needs three rulings.
    func bond(tier: String) -> BondTendency? {
        let sample = recent(.bond, tier, limit: 10).filter { $0.stateWantedSecured && $0.asked > 0 }
        guard sample.count >= 3 else { return nil }
        let secured = sample.filter { $0.form >= 3 && $0.form <= 4 }
        let ratio = secured.isEmpty ? 0.3 : secured.map { Double($0.ruled) / Double($0.asked) }.reduce(0, +) / Double(secured.count)
        let loose = Double(sample.filter { $0.form <= 2 }.count) / Double(sample.count)
        let typical = secured.isEmpty ? 0 : secured.map(\.ruled).reduce(0, +) / secured.count
        return BondTendency(n: sample.count, ratio: ratio, unsecuredShare: loose, typical: typical)
    }

    /// The share of recent pleas of this kind where the judge took the State's recommendation. Needs three rulings.
    func pleaFollowRate(tier: String) -> (n: Int, rate: Double)? {
        let sample = recent(.plea, tier, limit: 10)
        guard sample.count >= 3 else { return nil }
        return (sample.count, Double(sample.filter(\.tookStateAsk).count) / Double(sample.count))
    }

    /// The option the judge picked most on this kind of plea, and how often.
    func pleaFavorite(tier: String) -> (option: Int, share: Double, n: Int)? {
        let sample = recent(.plea, tier, limit: 10)
        guard sample.count >= 3 else { return nil }
        let counts = Dictionary(grouping: sample, by: \.form).mapValues(\.count)
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        return (top.key, Double(top.value) / Double(sample.count), sample.count)
    }

    /// The share of recent continuances the judge granted. Needs four rulings.
    func continuanceGrantRate() -> Double? {
        let sample = recent(.continuance, nil, limit: 12)
        guard sample.count >= 4 else { return nil }
        return Double(sample.filter { $0.form == 0 }.count) / Double(sample.count)
    }

    /// The ruling a calendar matter produced, kept for later. Bond hearings, pleas and motions to continue only.
    static func entry(for m: CalendarMatter, choice: Int, amount: Int?, on date: Date) -> RulingMemory? {
        switch m.kind {
        case .firstAppearance:
            guard let c = m.pendingCase, let law = c.charges.first?.law else { return nil }
            let worst = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
            let tier = tier(category: c.category, felony: worst?.isFelony ?? law.ncClass?.isFelony ?? false)
            let wanted = m.stateAsk.hasPrefix("$") || m.stateAsk.hasPrefix("Hold")
            let asked = m.bond?.stateAsk ?? 0
            let ruled = [2, 3, 4].contains(choice) ? (amount ?? m.suggested(for: choice) ?? 0) : 0
            let holdAsked = m.stateAsk.hasPrefix("Hold")
            let stateWon = wanted && ((holdAsked && choice == 5) || (!holdAsked && [3, 4].contains(choice) && ruled * 10 >= asked * 9))
            let defenseWon = choice <= 2 || ([3, 4].contains(choice) && ruled * 10 < asked * 9)
            return RulingMemory(date: date, kind: .bond, tier: tier, asked: asked, ruled: ruled, form: choice, stateWantedSecured: wanted,
                                tookStateAsk: stateWon, stateWon: stateWon, defenseWon: defenseWon,
                                who: m.personName, outcome: m.optionText(choice, amount: ruled > 0 ? ruled : nil))
        case .quickPlea:
            guard let id = m.lawID else { return nil }
            let law = LawLibrary.law(id)
            let tier = tier(category: law.category, felony: law.ncClass?.isFelony ?? false)
            let option = m.options.indices.contains(choice) ? m.options[choice] : ""
            let tookState = option.contains("State's ask") || option.contains("joint recommendation")
            let tookDefense = option.contains("defense's ask") || option.contains("joint recommendation")
            return RulingMemory(date: date, kind: .plea, tier: tier, asked: 0, ruled: 0, form: choice, stateWantedSecured: false,
                                tookStateAsk: tookState, stateWon: tookState, defenseWon: tookDefense)
        case .continuance:
            guard let c = m.pendingCase else { return nil }
            let worst = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
            let tier = tier(category: c.category, felony: worst?.isFelony ?? false)
            return RulingMemory(date: date, kind: .continuance, tier: tier, asked: 0, ruled: 0, form: choice == 0 ? 0 : 1,
                                stateWantedSecured: false, tookStateAsk: choice != 0, stateWon: choice != 0, defenseWon: choice == 0)
        default:
            return nil
        }
    }
}


/// Small things the courtroom staff mention: nothing that changes a ruling, just a courtroom that has people in it.
enum CourtStaff {
    static func note(county: County, seed: UInt64) -> String? {
        var rng = SeededRNG(seed: seed ^ 0x57A1)
        guard rng.chance(0.22) else { return nil }
        let clerk = county.clerk
        let bailiff = county.bailiff ?? "the bailiff"
        let reporter = county.courtReporter ?? "the court reporter"
        return rng.pick([
            "Clerk \(clerk) says the clerk's office is a deputy clerk short this week, so files may reach the bench a few minutes late.",
            "Bailiff \(bailiff) reports the jail transport van ran late; the first defendants were brought over after the hour.",
            "Court reporter \(reporter) is out sick today, and a substitute reporter is taking the record.",
            "Court reporter \(reporter) asks counsel to speak one at a time; the record has been hard to transcribe lately.",
            "Clerk \(clerk) found a misfiled order from last month and has corrected the docket.",
            "Bailiff \(bailiff) reminds the gallery that phones stay silent in the courtroom.",
            "Clerk \(clerk) has a stack of orders ready for the judge's signature after the session.",
            "Bailiff \(bailiff) says the courtroom's air conditioning is out and the room is warm.",
            "Court reporter \(reporter) has asked for a short recess after the long morning calendar last week; counsel should keep it moving.",
            "Clerk \(clerk) reminds counsel that proposed orders must be handed up before the session, not after.",
            "Bailiff \(bailiff) has moved the gallery's seating so family members for the first appearances can sit together.",
            "The courthouse elevator is down; Bailiff \(bailiff) is escorting defendants and witnesses by the back stairs.",
            "Clerk \(clerk) says a boxed set of old files came up from storage and is on the cart outside the courtroom.",
            "Court reporter \(reporter) is running a new recording system today; if the room echoes, counsel should speak up."
        ])
    }
}
