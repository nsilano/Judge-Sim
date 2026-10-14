import SwiftUI

@main
struct JudgeSimApp: App {
    @StateObject private var game = GameState()

    init() { Theme.applyAppearance() }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(game)
                .tint(Theme.gold)
                .preferredColorScheme(.dark)
        }
    }
}
