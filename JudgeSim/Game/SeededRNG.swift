import Foundation

/// Deterministic SplitMix64 generator, so a case can be rebuilt from its seed.
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func chance(_ probability: Double) -> Bool {
        Double.random(in: 0..<1, using: &self) < probability
    }

    mutating func pick<T>(_ items: [T]) -> T {
        items[Int.random(in: 0..<items.count, using: &self)]
    }

    mutating func pick<T>(_ items: [T], count: Int) -> [T] {
        Array(items.shuffled(using: &self).prefix(max(0, min(count, items.count))))
    }

    mutating func int(_ range: ClosedRange<Int>) -> Int {
        Int.random(in: range, using: &self)
    }

    /// A hash of the text that is the same on every launch (FNV-1a), for seeding. `hashValue` changes from run to run.
    static func stableHash(_ text: String) -> UInt64 {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325
        for byte in text.utf8 { hash = (hash ^ UInt64(byte)) &* 0x0000_0100_0000_01B3 }
        return hash
    }
}

/// Replaces `{KEY}` tokens in template text.
struct TextFiller {
    var values: [String: String]

    func callAsFunction(_ text: String) -> String {
        var result = text
        var values = values
        // he/she, him/her, his/her for each named person, from the first name.
        for key in ["D", "V", "ALT"] where values["\(key).he"] == nil {
            if let name = values[key] { values.merge(NameBank.gender(of: name).tokens(for: key)) { a, _ in a } }
        }
        // Two passes so extras can themselves contain tokens like {DL}.
        for _ in 0..<2 {
            for (key, value) in values {
                result = result.replacingOccurrences(of: "{\(key)}", with: value)
            }
        }
        return result
    }

    func callAsFunction(_ texts: [String]) -> [String] {
        texts.map { self($0) }
    }
}
