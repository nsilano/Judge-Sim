import SwiftUI

/// A speaker button for any text on screen. Tap to read it aloud, tap again to pause, and the second button stops it.
struct ReadAloudButton: View {
    @ObservedObject private var reader = SpeechReader.shared
    let id: String
    let lines: () -> [SpeechReader.Line]
    var title: String? = nil

    var body: some View {
        let active = reader.playing == id
        HStack(spacing: 6) {
            Button {
                reader.toggle(id: id, lines: lines())
            } label: {
                if let title {
                    Label(active ? (reader.paused ? "Resume" : "Pause") : title,
                          systemImage: active ? (reader.paused ? "play.circle.fill" : "pause.circle.fill") : "speaker.wave.2.circle.fill")
                } else {
                    Image(systemName: active ? (reader.paused ? "play.circle.fill" : "pause.circle.fill") : "speaker.wave.2.circle.fill")
                }
            }
            .buttonStyle(.borderless)
            .font(title == nil ? .title3 : .caption.weight(.semibold))
            .foregroundStyle(Theme.gold)
            .accessibilityLabel(active ? (reader.paused ? "Resume reading" : "Pause reading") : "Read aloud")
            if active {
                Button {
                    reader.stop()
                } label: {
                    Image(systemName: "stop.circle.fill")
                }
                .buttonStyle(.borderless)
                .font(title == nil ? .title3 : .caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityLabel("Stop reading")
            }
        }
    }
}
