import Foundation
import MetricKit
import UIKit

/// Crash reports without TestFlight: iOS hands the app a diagnostic report (what crashed, and the call stack) the next
/// time it runs, through MetricKit. They are saved to a folder and can be shared from Settings.
final class DiagnosticsCollector: NSObject, MXMetricManagerSubscriber {
    static let shared = DiagnosticsCollector()

    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = base.appendingPathComponent("JudgeSim/diagnostics", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// A crash the game caught itself (the signal or exception, and the error output before it).
    static func saveCaughtCrash(_ text: String) {
        let url = directory.appendingPathComponent("crash-\(Int(Date().timeIntervalSince1970)).txt")
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Every saved report, newest first.
    static var reportFiles: [URL] {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        func written(_ url: URL) -> Date { ((try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date) ?? .distantPast }
        return names.map { directory.appendingPathComponent($0) }.sorted { written($0) > written($1) }
    }

    func start() {
        MXMetricManager.shared.add(self)
        // Reports iOS already holds for this app arrive at once.
        save(MXMetricManager.shared.pastDiagnosticPayloads)
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) { save(payloads) }

    private func save(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            let stamp = Int(payload.timeStampEnd.timeIntervalSince1970)
            let url = Self.directory.appendingPathComponent("diagnostic-\(stamp).json")
            guard !FileManager.default.fileExists(atPath: url.path) else { continue }
            try? payload.jsonRepresentation().write(to: url, options: [.atomic])
        }
        // Keep the ten newest.
        let files = ((try? FileManager.default.contentsOfDirectory(atPath: Self.directory.path)) ?? []).sorted()
        for old in files.dropLast(10) { try? FileManager.default.removeItem(at: Self.directory.appendingPathComponent(old)) }
    }

    /// Everything worth sending when the game crashes: the build, the device, what the game was doing, and iOS's own report.
    static func report() -> String {
        var out: [String] = []
        let info = Bundle.main.infoDictionary
        out.append("Judge Sim \(info?["CFBundleShortVersionString"] as? String ?? "?") (\(info?["CFBundleVersion"] as? String ?? "?"))")
        out.append("\(UIDevice.current.model), iOS \(UIDevice.current.systemVersion)")
        out.append("Physical memory: \(ProcessInfo.processInfo.physicalMemory / 1_048_576) MB")
        out.append("")
        if let previous = Breadcrumbs.previousTrail {
            out.append("== What the game was doing before it closed ==")
            out.append(previous)
            out.append("")
        }
        out.append("== Saves ==")
        out.append(contentsOf: SaveStore.summary())
        out.append("")
        for url in reportFiles.prefix(4) {
            let name = url.lastPathComponent
            if let text = try? String(contentsOf: url, encoding: .utf8) {
                out.append("== Report: \(name) ==")
                out.append(String(text.prefix(60_000)))
                out.append("")
            }
        }
        if reportFiles.isEmpty && Breadcrumbs.previousTrail == nil { out.append("No crash information has been recorded yet. iOS delivers its report the next time the game opens, often within a day.") }
        return out.joined(separator: "\n")
    }

    /// Whether there is anything to send.
    static var hasReport: Bool {
        Breadcrumbs.previousTrail != nil || !reportFiles.isEmpty
    }
}
