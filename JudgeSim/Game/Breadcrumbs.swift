import Foundation

/// A short trail of what the game was doing, kept in a file, so a crash that leaves no log still leaves a clue. The trail
/// of the session before this one is kept when that session did not end cleanly (the app was in front and then vanished).
enum Breadcrumbs {
    nonisolated(unsafe) private static var lines: [String] = []
    private static let lock = NSLock()

    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = base.appendingPathComponent("JudgeSim", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    private static var trailURL: URL { directory.appendingPathComponent("trail.txt") }
    private static var previousURL: URL { directory.appendingPathComponent("previous-trail.txt") }
    private static var runningURL: URL { directory.appendingPathComponent("running.flag") }

    /// Records one step. Cheap: the file is rewritten with the last 80 steps.
    static func note(_ text: String) {
        lock.lock()
        let stamp = ISO8601DateFormatter().string(from: Date())
        lines.append("\(stamp) \(text)")
        if lines.count > 80 { lines.removeFirst(lines.count - 80) }
        let body = lines.joined(separator: "\n")
        lock.unlock()
        try? body.write(to: trailURL, atomically: true, encoding: .utf8)
    }

    /// Call when the app comes to the front. Returns true when the last session never ended cleanly.
    @discardableResult
    static func sessionStarted(build: String) -> Bool {
        let fm = FileManager.default
        let crashed = fm.fileExists(atPath: runningURL.path)
        if crashed, let trail = try? String(contentsOf: trailURL, encoding: .utf8) {
            try? "Previous session ended without a clean exit.\n\(trail)".write(to: previousURL, atomically: true, encoding: .utf8)
        }
        try? build.write(to: runningURL, atomically: true, encoding: .utf8)
        lock.lock(); lines = []; lock.unlock()
        note("session started, build \(build)")
        return crashed
    }

    /// Call when the app goes to the background: from here, being closed is not a crash.
    static func sessionEndedCleanly() {
        note("moved to the background")
        try? FileManager.default.removeItem(at: runningURL)
    }

    /// The newest steps of this session, oldest first.
    static func recent(_ count: Int) -> [String] {
        lock.lock(); defer { lock.unlock() }
        return Array(lines.suffix(count))
    }

    /// The trail of the session that ended badly, if there was one.
    static var previousTrail: String? { try? String(contentsOf: previousURL, encoding: .utf8) }

    static func clearPrevious() { try? FileManager.default.removeItem(at: previousURL) }
}
