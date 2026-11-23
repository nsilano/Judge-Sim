import Foundation
import Darwin

/// Catches what a crash leaves behind. Standard error goes to a file (Swift's own "Fatal error: ..." message, with the
/// file and line when it has them, is written there), an uncaught exception's reason is recorded, and a fatal signal leaves a
/// marker. The next time the game opens, whatever was left is turned into a crash report for the developer dashboard.
enum CrashHandler {
    nonisolated(unsafe) private static var signalFD: Int32 = -1

    static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = base.appendingPathComponent("JudgeSim", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    static var errorLogURL: URL { directory.appendingPathComponent("stderr.log") }
    private static var signalURL: URL { directory.appendingPathComponent("last-signal.txt") }

    /// Call once at launch, before anything else runs.
    static func install() {
        collectPrevious()
        let fm = FileManager.default
        if let size = (try? fm.attributesOfItem(atPath: errorLogURL.path))?[.size] as? Int, size > 400_000 {
            try? fm.removeItem(at: errorLogURL)
        }
        // Standard error goes to a file from here on.
        if let file = fopen(errorLogURL.path, "a") { dup2(fileno(file), STDERR_FILENO) }
        signalFD = open(signalURL.path, O_WRONLY | O_CREAT | O_TRUNC, 0o644)
        NSSetUncaughtExceptionHandler { exception in
            let text = "UNCAUGHT EXCEPTION \(exception.name.rawValue): \(exception.reason ?? "")\n"
                + exception.callStackSymbols.joined(separator: "\n") + "\n"
            CrashHandler.writeMarker(text)
        }
        for sig in [SIGABRT, SIGILL, SIGSEGV, SIGBUS, SIGTRAP, SIGFPE] {
            _ = signal(sig) { received in
                CrashHandler.writeMarker("SIGNAL \(received)\n")
                _ = signal(received, SIG_DFL)
                raise(received)
            }
        }
    }

    private static func writeMarker(_ text: String) {
        guard signalFD >= 0 else { return }
        text.withCString { _ = write(signalFD, $0, strlen($0)) }
    }

    /// Turns what the last run left behind into a saved crash report.
    private static func collectPrevious() {
        guard let marker = try? String(contentsOf: signalURL, encoding: .utf8),
              marker.contains("SIGNAL") || marker.contains("UNCAUGHT") else { return }
        var report = "The game crashed.\n\(marker)\n"
        if let log = try? String(contentsOf: errorLogURL, encoding: .utf8) {
            report += "--- the end of the game's error output ---\n" + String(log.suffix(20_000)) + "\n"
        }
        DiagnosticsCollector.saveCaughtCrash(report)
        try? FileManager.default.removeItem(at: signalURL)
    }
}
