import SwiftUI

/// The judge questions a witness directly from the bench (N.C. R. Evid. 614(b)).
struct WitnessQuestionSheet: View {
    @ObservedObject var session: CaseSession
    let witness: Witness
    @ObservedObject private var settings = AISettings.shared
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var thinking = false
    @State private var errorText: String?

    private let suggestions = [
        "How far away were you?", "What was the lighting like?", "How sure are you?",
        "Did anyone talk to you about your testimony?", "What happened right before that?", "Is there anything you left out?"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "person.wave.2.fill").foregroundStyle(Theme.color(for: witness.calledBy))
                                VStack(alignment: .leading) {
                                    Text(witness.name).font(.headline)
                                    Text(witness.role).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .card()
                            Text("Under Rule 614, a judge may question any witness. Counsel may object to the court's questions, so keep them neutral.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ForEach(session.witnessTranscript(for: witness)) { entry in
                                TranscriptBubble(entry: entry)
                            }
                            if thinking {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("\(witness.name) is answering…").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            if let errorText {
                                Label(errorText, systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.orange)
                            }
                            if session.witnessTranscript(for: witness).isEmpty {
                                Text("Try asking").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button(suggestion) { send(suggestion) }
                                        .font(.callout)
                                        .buttonStyle(.bordered)
                                }
                            }
                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding()
                    }
                    .onChange(of: session.witnessTranscript(for: witness).count) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }
                VStack(spacing: 6) {
                    HStack(alignment: .bottom, spacing: 8) {
                        TextField("Ask \(witness.name) a question…", text: $draft, axis: .vertical)
                            .lineLimit(1...4)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemGroupedBackground)))
                            .onSubmit { send(draft) }
                        Button { send(draft) } label: {
                            Image(systemName: "arrow.up.circle.fill").font(.system(size: 32))
                                .foregroundStyle(canSend ? Theme.gold : Color.secondary)
                        }
                        .disabled(!canSend)
                    }
                    Text(settings.activeEngine == .offline ? "Answers come from the witness's testimony. Turn on live answers in Settings." : settings.activeLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Questions from the Bench")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    private var canSend: Bool { !thinking && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private func send(_ text: String) {
        let question = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !thinking else { return }
        draft = ""
        errorText = nil
        thinking = true
        Task { @MainActor in
            let error = await session.askWitness(question, witness: witness)
            thinking = false
            if let error { errorText = error; draft = question }
        }
    }
}
