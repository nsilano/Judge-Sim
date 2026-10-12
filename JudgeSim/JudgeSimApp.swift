import SwiftUI

@main
struct JudgeSimApp: App {
    @StateObject private var game = GameState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(game)
                .tint(Theme.gold)
        }
    }
}
