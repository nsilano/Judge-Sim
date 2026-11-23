import SwiftUI

@main
struct JudgeSimApp: App {
    @StateObject private var game = GameState()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        CrashHandler.install()
        Theme.applyAppearance()
        DiagnosticsCollector.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(game)
                .tint(Theme.gold)
                .preferredColorScheme(.dark)
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                .onChange(of: scenePhase, initial: true) { _, phase in
                    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
                    if phase == .active { Breadcrumbs.sessionStarted(build: build) }
                    else if phase == .background { SaveStore.flush(); Breadcrumbs.sessionEndedCleanly() }
                }
        }
    }
}
