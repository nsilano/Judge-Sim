import SwiftUI
import UIKit
import os

/// For the developer: what the game is doing, how the saves are, and every crash report it has caught, in one place, with
/// a button that shares all of it.
struct DeveloperDashboardView: View {
    @EnvironmentObject private var game: GameState
    @State private var tick = 0
    @State private var confirmTestCrash = false
    @State private var copied = false

    var body: some View {
        List {
            Section("This build") {
                row("Version", VersionBadge.text)
                row("Device", "\(UIDevice.current.model), iOS \(UIDevice.current.systemVersion)")
                row("Memory left before iOS closes the app", "\(os_proc_available_memory() / 1_048_576) MB")
                row("Last session", Breadcrumbs.previousTrail == nil ? "ended normally" : "ended unexpectedly")
            }
            Section("The career") {
                row("Weeks on the bench", "\(game.weekNumber)")
                row("Cases heard", "\(game.casesHeard)")
                row("People on file", "\(game.people.count)")
                row("Case log entries", "\(game.caseLog.count)")
                row("News items", "\(game.news.count)")
            }
            Section("Saves") {
                ForEach(SaveStore.summary(), id: \.self) { line in
                    Text(line).font(.caption.monospaced())
                }
            }
            Section("Crash reports") {
                let files = DiagnosticsCollector.reportFiles
                if files.isEmpty && Breadcrumbs.previousTrail == nil {
                    Text("None recorded.").foregroundStyle(.secondary)
                }
                if let previous = Breadcrumbs.previousTrail {
                    NavigationLink("What the game was doing before it closed") { ReportText(title: "Before it closed", text: previous) }
                }
                ForEach(files, id: \.self) { url in
                    NavigationLink(url.lastPathComponent) {
                        ReportText(title: url.lastPathComponent, text: (try? String(contentsOf: url, encoding: .utf8)) ?? "Could not read this file.")
                    }
                }
            }
            Section("What the game is doing now") {
                let recent = Breadcrumbs.recent(30)
                if recent.isEmpty { Text("Nothing yet.").foregroundStyle(.secondary) }
                ForEach(Array(recent.reversed().enumerated()), id: \.offset) { _, line in
                    Text(line).font(.caption2.monospaced())
                }
            }
            Section {
                ShareLink(item: DiagnosticsCollector.report()) {
                    Label("Share everything", systemImage: "square.and.arrow.up")
                }
                Button {
                    UIPasteboard.general.string = DiagnosticsCollector.report()
                    copied = true
                } label: {
                    Label(copied ? "Copied" : "Copy everything", systemImage: "doc.on.doc")
                }
                Button {
                    tick += 1
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                Button(role: .destructive) {
                    confirmTestCrash = true
                } label: {
                    Label("Test crash capture (closes the game)", systemImage: "exclamationmark.triangle")
                }
            } footer: {
                Text("Open the game again after a crash and this screen shows what happened. iOS adds its own report a day or so later.")
            }
        }
        .id(tick)
        .benchBackground()
        .navigationTitle("Developer dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Close the game on purpose?", isPresented: $confirmTestCrash) {
            Button("Cancel", role: .cancel) {}
            Button("Crash", role: .destructive) {
                Breadcrumbs.note("test crash requested")
                fatalError("Test crash from the developer dashboard")
            }
        } message: {
            Text("This closes the game to check that crash information is saved. Your career is saved and is not affected.")
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
        }
        .font(.callout)
    }
}

private struct ReportText: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(.caption2.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Theme.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { ShareLink(item: text) }
        }
    }
}
