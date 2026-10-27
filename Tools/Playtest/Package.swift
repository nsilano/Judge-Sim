// swift-tools-version:5.9
import PackageDescription

// A headless build of the Judge Sim engine for Linux, so a career can be played and checked as text.
// `sync.py` copies JudgeSim/Game and JudgeSim/Models into Sources/Playtest with the Apple-only pieces stubbed.
let package = Package(
    name: "Playtest",
    targets: [
        .executableTarget(name: "Playtest", path: "Sources/Playtest",
                          swiftSettings: [.unsafeFlags(["-suppress-warnings", "-Xfrontend", "-solver-expression-time-threshold=600"])])
    ]
)
