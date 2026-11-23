import Foundation

/// Pattern searches compiled once and kept. The system's own `range(of:options: .regularExpression)` builds the pattern
/// again on every call, and on newer iOS versions does it slowly; a case build makes hundreds of these searches, so a long
/// career spent whole seconds there and iOS closed the app.
enum RegexCache {
    nonisolated(unsafe) private static var cache: [String: NSRegularExpression] = [:]
    nonisolated(unsafe) static var calls = 0
    /// For the playtest harness: how often each pattern is searched.
    nonisolated(unsafe) static var tally: [String: Int]? = nil
    private static let lock = NSLock()

    static func regex(_ pattern: String, caseInsensitive: Bool) -> NSRegularExpression? {
        let key = (caseInsensitive ? "i:" : "s:") + pattern
        lock.lock(); defer { lock.unlock() }
        if let found = cache[key] { return found }
        guard let made = try? NSRegularExpression(pattern: pattern, options: caseInsensitive ? [.caseInsensitive] : []) else { return nil }
        cache[key] = made
        return made
    }
}

extension StringProtocol {
    /// Same answer as `range(of:options:)`, with the pattern compiled once when the options ask for a regular expression.
    func regexRange(of pattern: String, options: String.CompareOptions = []) -> Range<Index>? {
        guard options.contains(.regularExpression) else {
            return range(of: pattern, options: options, range: nil, locale: nil)
        }
        RegexCache.calls += 1
        if RegexCache.tally != nil { RegexCache.tally![pattern, default: 0] += 1 }
        guard let regex = RegexCache.regex(pattern, caseInsensitive: options.contains(.caseInsensitive)) else { return nil }
        let text = String(self)
        let full = NSRange(location: 0, length: text.utf16.count)
        var found: NSRange?
        if options.contains(.backwards) {
            regex.enumerateMatches(in: text, options: [], range: full) { match, _, _ in if let match { found = match.range } }
        } else {
            found = regex.firstMatch(in: text, options: [], range: full)?.range
        }
        guard let nsRange = found, let r = Range(nsRange, in: text) else { return nil }
        // The range is in the copy's indices; map it back by distance so a Substring gets indices into itself.
        let lower = distance(from: text.startIndex, to: r.lowerBound)
        let upper = distance(from: text.startIndex, to: r.upperBound)
        return index(startIndex, offsetBy: lower)..<index(startIndex, offsetBy: upper)
    }

    /// Same answer as `replacingOccurrences(of:with:options:)` for a regular expression, with the pattern compiled once.
    func regexReplacing(of pattern: String, with template: String) -> String {
        RegexCache.calls += 1
        let text = String(self)
        guard let regex = RegexCache.regex(pattern, caseInsensitive: false) else { return text }
        return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count), withTemplate: template)
    }
}
