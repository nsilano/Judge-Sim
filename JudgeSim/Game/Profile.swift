import Foundation

/// Adds up how long the game's main steps take, so a slow day can be traced to the step that makes it slow.
enum Profile {
    nonisolated(unsafe) private static var totals: [String: (seconds: Double, calls: Int)] = [:]

    @discardableResult
    static func measure<T>(_ name: String, _ work: () -> T) -> T {
        let start = DispatchTime.now().uptimeNanoseconds
        let result = work()
        let elapsed = Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000_000
        let old = totals[name] ?? (0, 0)
        totals[name] = (old.seconds + elapsed, old.calls + 1)
        return result
    }

    static func report() -> [String] {
        totals.sorted { $0.value.seconds > $1.value.seconds }.map {
            String(format: "%-26@ %8.2f s over %6d calls (%.1f ms each)", $0.key as NSString, $0.value.seconds, $0.value.calls, $0.value.seconds * 1000 / Double(max(1, $0.value.calls)))
        }
    }

    static func reset() { totals = [:] }
}
