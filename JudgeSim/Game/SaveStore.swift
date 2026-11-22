import Foundation

/// Where the career is kept. It lives in a file in Application Support, not in UserDefaults: a career grows to several
/// megabytes, and iOS does not store anything that large in UserDefaults reliably (it warns at 4 MB and can drop the
/// value or fail to launch). The file is written atomically, the two previous copies stay beside it, and the career as
/// it was before an app update is kept once per build, so a bad write or an incompatible update never costs a career.
enum SaveStore {
    static let legacyKey = "JudgeSim.nc.save.v1"
    private static let current = "career.json"
    private static let previous = ["career.prev1.json", "career.prev2.json"]

    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = base.appendingPathComponent("JudgeSim", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func url(_ name: String) -> URL { directory.appendingPathComponent(name) }

    /// Writes the career. Returns whether the file is on disk.
    @discardableResult
    static func write(_ data: Data) -> Bool {
        let fm = FileManager.default
        // The copy before this one becomes the previous copy; the one before that becomes the second.
        if fm.fileExists(atPath: url(current).path) {
            try? fm.removeItem(at: url(previous[1]))
            if fm.fileExists(atPath: url(previous[0]).path) { try? fm.moveItem(at: url(previous[0]), to: url(previous[1])) }
            try? fm.copyItem(at: url(current), to: url(previous[0]))
        }
        do {
            try data.write(to: url(current), options: [.atomic])
        } catch {
            NSLog("JudgeSim: the career could not be written: %@", String(describing: error))
            return false
        }
        // Once the file is safely there, the old UserDefaults copy (too large to keep) is dropped.
        if UserDefaults.standard.data(forKey: legacyKey) != nil, (try? Data(contentsOf: url(current)))?.count == data.count {
            UserDefaults.standard.removeObject(forKey: legacyKey)
        }
        return true
    }

    /// Every copy of the career that might be readable, newest first.
    static func candidates() -> [(label: String, data: Data)] {
        var out: [(String, Data)] = []
        for name in [current] + previous {
            if let data = try? Data(contentsOf: url(name)), !data.isEmpty { out.append((name, data)) }
        }
        // A career saved by an older build lived in UserDefaults.
        if let legacy = UserDefaults.standard.data(forKey: legacyKey), !legacy.isEmpty { out.append(("UserDefaults", legacy)) }
        return out
    }

    /// A copy that could not be read is kept, never deleted.
    static func keepUnreadable(_ data: Data, from label: String) {
        let name = "career.unreadable-\(Int(Date().timeIntervalSince1970))-\(label.replacingOccurrences(of: "/", with: "_"))"
        try? data.write(to: url(name), options: [.atomic])
    }

    /// Keeps the career as it stood before the first launch of a new build, the last three builds' worth.
    static func backUpBeforeUpdate(build: String) {
        let defaults = UserDefaults.standard
        let key = "JudgeSim.lastBuild"
        let last = defaults.string(forKey: key)
        defer { defaults.set(build, forKey: key) }
        guard let last, last != build, let data = try? Data(contentsOf: url(current)), !data.isEmpty else { return }
        try? data.write(to: url("career.before-update-from-build-\(last).json"), options: [.atomic])
        let kept = ((try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? [])
            .filter { $0.hasPrefix("career.before-update-from-build-") }.sorted()
        for old in kept.dropLast(3) { try? FileManager.default.removeItem(at: url(old)) }
    }

    /// Size of the career file, for the playtest harness.
    static var currentBytes: Int { (try? Data(contentsOf: url(current)))?.count ?? -1 }
}
