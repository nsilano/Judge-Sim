import Foundation

/// What the State and the defense say at a hearing, worked out from the case instead of drawn at random, so the same
/// case gets the same kind of answer every time it comes back. The State's position at a bond-reduction hearing follows
/// from what it asked at the first appearance, the charge, the record and any missed court dates; it does not oppose
/// something it already agreed to unless the facts have changed.
enum PartyPositions {

    struct Facts {
        var worst: NCClass?
        /// A violent felony (Iryna's Law territory), not just a charge in the violent category.
        var violentFelony: Bool
        var felonies: Int
        var priors: Int
        var ftas: Int
        var noBond: Bool
        /// The amount the State asked for at the first appearance, when this court heard it.
        var originalAsk: Int?
    }

    static func facts(for c: CourtCase, ftas: Int, noBond: Bool) -> Facts {
        let d = c.defendant
        let worst = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let violentFelony = c.charges.contains { $0.law.ncClass?.isFelony == true }
            && (c.category == .violent || c.category == .robbery || c.charges.contains { Corrections.soundsViolent($0.law.title) })
        return Facts(worst: worst, violentFelony: violentFelony, felonies: d.priors.filter { $0.ncClass.isFelony }.count,
                     priors: d.priors.count, ftas: ftas, noBond: noBond, originalAsk: c.background?.stateBondAsk)
    }

    struct Position { var supports: Bool; var line: String }

    /// The State's answer to a request to lower the bond from `current` to `requested`.
    static func stateOnReduction(_ f: Facts, current: Int, requested: Int?) -> Position {
        if f.noBond { return Position(supports: false, line: "Keep holding without bond.") }
        if f.ftas > 0 {
            return Position(supports: false, line: "Opposes: missed court \(f.ftas == 1 ? "before" : "\(f.ftas) times before").")
        }
        let serious = (f.worst.map { $0.severity <= NCClass.D.severity } ?? false)
        if f.violentFelony || serious || f.felonies >= 2 {
            let why = f.violentFelony ? "a violent felony charge" : serious ? "the seriousness of the charge" : "\(f.felonies) prior felonies"
            return Position(supports: false, line: "Opposes a reduction: \(why).")
        }
        // The State's own earlier position is the anchor.
        if let original = f.originalAsk, original > 0 {
            if current > Int(Double(original) * 1.15) {
                return Position(supports: true, line: "The State asked for $\(original.formatted()) at the first appearance and doesn't oppose bringing the bond back down to it.")
            }
            if let requested, requested < Int(Double(original) * 0.5) {
                return Position(supports: false, line: "Opposes going that low: the State asked for $\(original.formatted()) at the first appearance and nothing has changed.")
            }
            return Position(supports: true, line: "The State doesn't oppose a modest cut with a monitor; it asked for $\(original.formatted()) at the first appearance.")
        }
        // No history here: a clean, minor case draws little resistance; a record draws more.
        if f.priors == 0 { return Position(supports: true, line: "No objection to a reduction with a monitor. No record.") }
        return Position(supports: true, line: "Would agree to a modest cut with a monitor.")
    }
}
