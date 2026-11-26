import AVFoundation
import Foundation

/// Reads the game's text aloud with the phone's own voices, so nobody has to read all of it. Each speaker keeps one voice
/// (a witness sounds the same every time) and the voice's sex follows the speaker's name. Play, pause and stop are one button.
final class SpeechReader: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechReader()

    /// One thing to say and who says it.
    struct Line {
        var text: String
        var speaker: String
    }

    /// The id of what is being read now, so the button for that text shows pause.
    @Published private(set) var playing: String?
    @Published private(set) var paused = false

    private let synthesizer = AVSpeechSynthesizer()
    private var remaining = 0

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: Settings (stored by the Settings screen under the same keys)

    static var rate: Float {
        let stored = UserDefaults.standard.float(forKey: "speech.rate")
        return stored == 0 ? 0.5 : min(0.6, max(0.35, stored))
    }

    static var variedVoices: Bool { UserDefaults.standard.object(forKey: "speech.varied") as? Bool ?? true }

    // MARK: Playing

    /// Starts reading, or pauses and resumes if this is already what is being read.
    func toggle(id: String, lines: [Line]) {
        if playing == id {
            if synthesizer.isPaused {
                synthesizer.continueSpeaking()
                paused = false
            } else if synthesizer.isSpeaking {
                synthesizer.pauseSpeaking(at: .word)
                paused = true
            }
            return
        }
        stop()
        let spoken = lines.filter { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !spoken.isEmpty else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        playing = id
        paused = false
        remaining = spoken.count
        for line in spoken { synthesizer.speak(utterance(for: line)) }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        remaining = 0
        playing = nil
        paused = false
    }

    // MARK: Voices

    private static let englishVoices: [AVSpeechSynthesisVoice] = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }

    private func utterance(for line: Line) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: Self.plain(line.text))
        utterance.rate = Self.rate
        utterance.postUtteranceDelay = 0.2
        if Self.variedVoices {
            let (voice, pitch) = voice(for: line.speaker)
            utterance.voice = voice
            utterance.pitchMultiplier = pitch
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        return utterance
    }

    /// The same speaker always gets the same voice and pitch, drawn from the better English voices of the right sex.
    private func voice(for speaker: String) -> (AVSpeechSynthesisVoice?, Float) {
        let first = speaker.split(separator: " ").first.map(String.init) ?? speaker
        let female = NameBank.gender(of: first + " Doe") == .female
        let wanted: AVSpeechSynthesisVoiceGender = female ? .female : .male
        var pool = Self.englishVoices.filter { $0.gender == wanted }
        if pool.isEmpty { pool = Self.englishVoices }
        pool.sort { $0.quality.rawValue != $1.quality.rawValue ? $0.quality.rawValue > $1.quality.rawValue : $0.identifier < $1.identifier }
        let choices = Array(pool.prefix(4))
        let hash = SeededRNG.stableHash(speaker)
        let chosen = choices.isEmpty ? nil : choices[Int(hash % UInt64(choices.count))]
        let pitch = 0.9 + Float(SeededRNG.stableHash(speaker + "|pitch") % 21) / 100
        return (chosen, pitch)
    }

    /// Text as it should be spoken: curly quotes and the marks that are only for the eye are dropped.
    private static func plain(_ text: String) -> String {
        text.replacingOccurrences(of: "\u{201C}", with: "").replacingOccurrences(of: "\u{201D}", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "§", with: "section ")
            .replacingOccurrences(of: "G.S.", with: "General Statute")
    }

    // MARK: AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.remaining -= 1
            if self.remaining <= 0 {
                self.playing = nil
                self.paused = false
                self.remaining = 0
            }
        }
    }
}
