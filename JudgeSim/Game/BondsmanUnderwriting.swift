import Foundation

/// How a bail bondsman decides whether to write a bond, how much risk to take on, and what to charge.
///
/// A bondsman posts the whole bond and keeps a fee (North Carolina caps it at 15 percent, G.S. 58-71-95). If the
/// defendant skips court, the bondsman owes the full amount, so the decision is underwriting: how likely is this
/// person to show up, how bad is the charge, how big is the exposure, and does the defendant have the means and ties
/// that make a bond safe to write. Each factor adds or subtracts points; the total decides yes or no, the fee rate,
/// and the largest bond the bondsman will write for this person.
struct BondsmanDecision: Hashable {
    var willing: Bool
    var feeRate: Double
    /// The most the bondsman will write for this defendant.
    var ceiling: Int
    var score: Int
    /// Why not, in a few words, when the answer is no ("a serious felony charge, a missed court date").
    var reason: String?
    /// Everything that counted, for the file: positive and negative.
    var factors: [String]
}

enum BondsmanUnderwriting {

    struct Inputs {
        var worstClass: NCClass?
        var chargeTitle: String
        var category: LawCategory
        var priorCount: Int
        var priorFelonies: Int
        /// Priors for the same kind of offense as this charge: a pattern, not a one-time mistake.
        var priorSameKind: Int
        var failuresToAppear: Int
        var local: Bool
        var employed: Bool
        var age: Int
        /// The secured bond the State wants (or the bond the defendant is held on).
        var ask: Int
        /// Cash the defendant and family can put toward the fee.
        var cash: Int
        var onSupervision: Bool
        var otherCharges: Int
    }

    static func assess(_ i: Inputs, seed: UInt64) -> BondsmanDecision {
        var score = 58
        var factors: [String] = []
        var against: [(Int, String)] = []
        func add(_ points: Int, _ label: String) {
            score += points
            factors.append("\(points >= 0 ? "+" : "")\(points) \(label)")
            if points < 0 { against.append((points, label)) }
        }

        // How serious the charge is: the bigger the likely sentence, the more reason to run.
        switch i.worstClass {
        case .A?, .B1?, .B2?: add(-60, "a very serious felony charge")
        case .C?: add(-34, "a serious felony charge")
        case .D?: add(-26, "a serious felony charge")
        case .E?: add(-18, "a felony with a long possible sentence")
        case .F?, .G?: add(-11, "a mid-level felony charge")
        case .H?: add(-7, "a felony charge")
        case .I?: add(-3, "a low-level felony charge")
        case .misdA1?, .misd1?, .misd2?, .misd3?: add(7, "only a misdemeanor charge")
        default: break
        }

        let title = i.chargeTitle.lowercased()
        if i.category == .violent || i.category == .robbery { add(-10, "a violent charge") }
        if ["rape", "sexual", "child abuse", "child sex", "kidnap", "minor"].contains(where: title.contains) { add(-12, "the nature of the offense") }
        if ["weapon", "firearm", "gun", "discharg"].contains(where: title.contains) { add(-5, "a weapon involved") }
        if title.contains("trafficking") { add(-10, "a trafficking charge") }
        if i.otherCharges > 0 { add(-3 * min(3, i.otherCharges), "additional counts") }

        // Record: a clean record is the best sign there is; a pattern is the worst.
        if i.priorCount == 0 { add(12, "no criminal history") }
        else {
            add(-3 * min(5, i.priorCount), "\(i.priorCount) prior conviction\(i.priorCount == 1 ? "" : "s")")
            if i.priorFelonies > 0 { add(-4 * min(4, i.priorFelonies), "prior felonies") }
        }
        if i.priorSameKind > 0 { add(-9 * min(2, i.priorSameKind) - 3, "a repeat of the same kind of offense") }
        if i.onSupervision { add(-14, "a new arrest while on probation or release") }

        // Court history: nothing worries a bondsman more than a missed court date.
        if i.failuresToAppear >= 2 { add(-70, "repeated missed court dates") }
        else if i.failuresToAppear == 1 { add(-24, "a missed court date") }

        // Ties and means.
        add(i.local ? 8 : -14, i.local ? "lives here" : "no ties to the area")
        add(i.employed ? 8 : -6, i.employed ? "has a job" : "no steady income")
        if i.age < 21 { add(-3, "young and without a record of showing up") }

        // Exposure: the same bond is a bigger bet on a riskier person, and some bonds are too big for any bondsman.
        let exposure = i.ask
        if exposure > 250_000 { add(-40, "a bond too large to write") }
        else if exposure > 100_000 { add(-12, "a very large bond") }
        else if exposure > 50_000 { add(-6, "a large bond") }
        else if exposure <= 5_000 && exposure > 0 { add(4, "a small bond") }

        // Can the defendant pay the fee, and is there skin in the game?
        let fee = Double(max(exposure, 500)) * 0.15
        if i.cash <= 0 { add(-40, "nothing to pay the fee with") }
        else if Double(i.cash) >= fee * 1.5 { add(6, "enough cash to cover the fee comfortably") }
        else if Double(i.cash) < fee * 0.4 { add(-6, "very little toward the fee") }

        // Bondsmen differ a little; the same case can get a yes from one and a no from another near the line.
        var rng = SeededRNG(seed: seed ^ 0xB04D)
        let judgment = rng.int(-4...4)
        score += judgment

        let willing = score >= 44 && i.cash > 0
        let rate: Double = score >= 78 ? 0.10 : score >= 66 ? 0.12 : 0.15
        let ceiling = score >= 78 ? 250_000 : score >= 66 ? 100_000 : score >= 54 ? 50_000 : 25_000
        var reason: String?
        if !willing {
            let top = against.sorted { $0.0 < $1.0 }.prefix(2).map(\.1)
            reason = top.isEmpty ? "too much risk for the fee" : top.joined(separator: " and ")
        }
        return BondsmanDecision(willing: willing, feeRate: rate, ceiling: ceiling, score: score, reason: reason, factors: factors)
    }

    /// Words that put two offenses in the same family: a second theft after a theft, a second assault after an assault.
    static func sameKind(_ a: String, _ b: String) -> Bool {
        let x = a.lowercased(), y = b.lowercased()
        if x == y { return true }
        let families = ["larceny", "theft", "assault", "burglary", "breaking", "robbery", "fraud", "forgery", "embezzle",
                        "possession of", "sale of", "delivery", "trafficking", "driving while impaired", "dwi", "stalking",
                        "arson", "trespass", "false pretense", "uttering", "identity"]
        return families.contains { x.contains($0) && y.contains($0) }
    }

    static func inputs(for c: CourtCase, local: Bool, employed: Bool, ftas: Int, ask: Int, cash: Int, onSupervision: Bool = false) -> Inputs {
        let d = c.defendant
        let law = c.charges.first?.law
        let title = law?.title ?? ""
        let worst = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let repeats = d.priors.filter { sameKind($0.offense, title) }.count
        return Inputs(worstClass: worst, chargeTitle: title, category: c.category, priorCount: d.priors.count,
                      priorFelonies: d.priors.filter { $0.ncClass.isFelony }.count, priorSameKind: repeats,
                      failuresToAppear: ftas, local: local, employed: employed, age: d.age, ask: ask, cash: cash,
                      onSupervision: onSupervision, otherCharges: max(0, c.charges.count - 1))
    }
}
