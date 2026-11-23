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

/// Replaces `{KEY}` tokens in template text. A case is thousands of strings, so each is read once: markers are found as the
/// text is scanned and swapped in, instead of trying every possible marker against the whole string.
struct TextFiller {
    var values: [String: String]

    func callAsFunction(_ text: String) -> String {
        // Most strings have nothing to fill.
        guard text.utf8.contains(UInt8(ascii: "{")) else { return text }
        var map = values
        // Two passes so extras can themselves contain tokens like {DL}.
        var result = text
        for _ in 0..<2 {
            guard result.utf8.contains(UInt8(ascii: "{")) else { break }
            // he/she, him/her, his/her for each named person, from the first name. Only worked out when the text asks for one.
            for key in ["D", "V", "ALT"] where map["\(key).he"] == nil && result.contains("{\(key).") {
                if let name = map[key] { map.merge(NameBank.gender(of: name).tokens(for: key)) { a, _ in a } }
            }
            result = Self.substitute(result, map)
        }
        return result
    }

    private static func substitute(_ text: String, _ map: [String: String]) -> String {
        let bytes = Array(text.utf8)
        var out: [UInt8] = []
        out.reserveCapacity(bytes.count + 64)
        var i = 0
        let open = UInt8(ascii: "{"), close = UInt8(ascii: "}")
        while i < bytes.count {
            if bytes[i] == open, let end = bytes[(i + 1)...].firstIndex(of: close) {
                let key = String(decoding: bytes[(i + 1)..<end], as: UTF8.self)
                if let value = map[key] {
                    out.append(contentsOf: value.utf8)
                    i = end + 1
                    continue
                }
            }
            out.append(bytes[i])
            i += 1
        }
        return String(decoding: out, as: UTF8.self)
    }

    func callAsFunction(_ texts: [String]) -> [String] {
        texts.map { self($0) }
    }
}
