import Foundation

/// The game's memory of the stock reasons, excuses and wordings it has already used, so a list with a fixed number of
/// answers doesn't wear out. Every pick is random, but an option that has come up often is less likely and one that has
/// hardly come up is more likely. Nothing is ever ruled out: the same excuse can come again, it is just passive pressure
/// toward whatever has been left unused. The counts are saved with the career.
enum Variety {
    /// How many times each option has been picked, by a short fingerprint of its text.
    nonisolated(unsafe) static var counts: [String: Int] = [:]
    /// How many picks were made from lists of more than one option, for the developer dashboard.
    nonisolated(unsafe) static var picks = 0

    /// The fingerprint ignores what changes from one use to the next (numbers, names and dates inside the text), so a line
    /// with a different defendant's name in it still counts as the same option and the ledger does not grow without end.
    private static func key(_ text: String) -> String {
        var shape = ""
        var word = ""
        func flush() {
            if let first = word.first, first.isNumber { shape += "#" }
            else if let first = word.first, first.isUppercase, word.count > 1 { shape += "N" }
            else { shape += word }
            word = ""
        }
        for ch in text.prefix(160) {
            if ch.isLetter || ch.isNumber || ch == "'" { word.append(ch) } else { flush(); shape.append(ch) }
        }
        flush()
        return String(SeededRNG.stableHash(shape) & 0xFFFF_FFFF_FFFF, radix: 36)
    }

    static func uses(_ text: String) -> Int { counts[key(text)] ?? 0 }

    private static func note(_ text: String) {
        counts[key(text), default: 0] += 1
        // A very long career keeps the options that matter: when the table grows past 30,000 entries, the rarely used go.
        if counts.count > 30_000 { counts = counts.filter { $0.value > 1 } }
    }

    /// One option, chosen at random with the less-used ones favored (weight 1 / (1 + uses)^2).
    static func pick(_ items: [String], rng: inout SeededRNG) -> String {
        guard !items.isEmpty else { return "" }
        guard items.count > 1 else { note(items[0]); return items[0] }
        let weights = items.map { 1.0 / pow(1.0 + Double(uses($0)), 2.0) }
        let total = weights.reduce(0, +)
        var roll = Double.random(in: 0..<total, using: &rng)
        var chosen = items[items.count - 1]
        for (i, w) in weights.enumerated() {
            roll -= w
            if roll < 0 { chosen = items[i]; break }
        }
        picks += 1
        note(chosen)
        return chosen
    }

    /// Several distinct options, the less-used ones favored (for lists like "two reasons from this pool").
    static func pick(_ items: [String], count: Int, rng: inout SeededRNG) -> [String] {
        var pool = items
        var out: [String] = []
        while out.count < count, !pool.isEmpty {
            let one = pick(pool, rng: &rng)
            out.append(one)
            if let at = pool.firstIndex(of: one) { pool.remove(at: at) }
        }
        return out
    }

    /// For the dashboard: distinct options remembered, and the most any one has been used.
    static var summary: String {
        let most = counts.values.max() ?? 0
        return "\(counts.count) different options used, \(picks) picks, the most any one option has been used is \(most)"
    }
}
