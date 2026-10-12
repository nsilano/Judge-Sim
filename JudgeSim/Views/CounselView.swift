import SwiftUI

/// Anything the judge can hold a bench conference in.
protocol CounselProvider: ObservableObject {
    var unaskedCount: Int { get }
    func counselName(_ side: Side) -> String
    func counselStyle(_ side: Side) -> CounselStyle
    func availableQuestions(_ side: Side) -> [CounselQuestion]
    func entries(for side: Side) -> [TranscriptEntry]
    func ask(_ question: CounselQuestion)
    func allQuestions(_ side: Side) -> [CounselQuestion]
    func brief(for side: Side) -> String
    func heldBackFactor(for side: Side) -> CounselReveal?
    func record(side: Side, question: String, answer: String, reveal: CounselReveal?)
}

extension CounselProvider {
    /// Answers a question the judge typed: live through Claude if an API key is set, otherwise from the case file.
    @MainActor
    func askFreeform(_ question: String, side: Side) async -> String? {
        let settings = AISettings.shared
        guard settings.hasKey else {
            let (answer, reveal) = OfflineCounsel.answer(question, from: allQuestions(side), style: counselStyle(side))
            record(side: side, question: question, answer: answer, reveal: reveal)
            return nil
        }
        let history = entries(for: side).map { (question: $0.question, answer: $0.answer) }
        do {
            let reply = try await ClaudeClient.counselReply(system: brief(for: side), history: history, question: question)
            let reveal = reply.raisesFactor ? heldBackFactor(for: side) : nil
            record(side: side, question: question, answer: reply.answer, reveal: reveal)
            return nil
        } catch ClaudeError.refusal {
            record(side: side, question: question,
                   answer: counselStyle(side).opener + "I'd rather not get into that at the bench. Is there something else the court needs from me?",
                   reveal: nil)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
}

extension CaseSession: CounselProvider {}
extension HearingSession: CounselProvider {}

/// Inline prompt that opens the bench conference.
struct CounselPrompt: View {
    let available: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ask counsel").font(.subheadline.weight(.semibold))
                    Text(available == 0 ? "Ask the State or the defense anything" : "Ask anything, or pick from \(available) suggested question\(available == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .card()
        }
        .buttonStyle(.plain)
    }
}

struct CounselSheet<Provider: CounselProvider>: View {
    @ObservedObject var provider: Provider
    @Environment(\.dismiss) private var dismiss
    @State private var side: Side = .prosecution
    @State private var draft = ""
    @State private var thinking = false
    @State private var errorText: String?
    @State private var showSuggestions = false
    @ObservedObject private var settings = AISettings.shared
    @FocusState private var inputFocused: Bool

    private var inputBar: some View {
        VStack(spacing: 6) {
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Ask \(provider.counselName(side)) anything…", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemGroupedBackground)))
                    .submitLabel(.send)
                    .onSubmit { send(draft) }
                Button {
                    send(draft)
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(canSend ? Theme.gold : Color.secondary)
                }
                .disabled(!canSend)
            }
            Text(settings.hasKey ? "Live answers from \(settings.model.label)." : "Offline: answers come from the case file. Add a Claude API key in Settings for live answers.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var canSend: Bool {
        !thinking && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func send(_ text: String) {
        let question = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !thinking else { return }
        draft = ""
        errorText = nil
        thinking = true
        let askedSide = side
        Task { @MainActor in
            let error = await provider.askFreeform(question, side: askedSide)
            thinking = false
            if let error {
                errorText = error
                draft = question
            } else {
                Haptics.tap()
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Counsel", selection: $side) {
                    Text("State").tag(Side.prosecution)
                    Text("Defense").tag(Side.defense)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                Image(systemName: side == .prosecution ? "building.columns.fill" : "shield.fill")
                                    .font(.title2)
                                    .foregroundStyle(Theme.color(for: side))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(provider.counselName(side)).font(.headline)
                                    Text(provider.counselStyle(side).label).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .card()

                            ForEach(provider.entries(for: side)) { entry in
                                TranscriptBubble(entry: entry)
                            }

                            if thinking {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("\(provider.counselName(side)) is answering…").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            if let errorText {
                                Label(errorText, systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }

                            let questions = provider.availableQuestions(side)
                            if !questions.isEmpty {
                                Button {
                                    withAnimation(.snappy) { showSuggestions.toggle() }
                                } label: {
                                    HStack {
                                        SectionTitle(text: "Suggested questions (\(questions.count))", icon: "lightbulb.fill")
                                        Spacer()
                                        Image(systemName: "chevron.down").rotationEffect(.degrees(showSuggestions ? 0 : -90)).foregroundStyle(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            if showSuggestions && !questions.isEmpty {
                                ForEach(questions) { question in
                                    Button {
                                        Haptics.tap()
                                        if AISettings.shared.hasKey {
                                            send(question.question)
                                        } else {
                                            withAnimation(.snappy) { provider.ask(question) }
                                        }
                                    } label: {
                                        HStack {
                                            Text(question.question)
                                                .font(.callout)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                            Image(systemName: "arrow.up.circle.fill").foregroundStyle(Theme.gold)
                                        }
                                        .padding(12)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemFill)))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding()
                    }
                    .onChange(of: provider.entries(for: side).count) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                    .onChange(of: thinking) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }

                inputBar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Bench Conference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct TranscriptBubble: View {
    let entry: TranscriptEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer(minLength: 40)
                Text(entry.question)
                    .font(.callout)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Theme.gold.opacity(0.25)))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.speaker).font(.caption.weight(.bold)).foregroundStyle(Theme.color(for: entry.side))
                Text(entry.answer).font(.system(.callout, design: .serif))
                switch entry.reveal {
                case .mitigating(let factor)?:
                    Label("Mitigating factor offered: \(factor)", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.defense)
                case .aggravating(let factor)?:
                    Label("Aggravating factor offered: \(factor)", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.prosecution)
                case nil:
                    EmptyView()
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
            .padding(.trailing, 30)
        }
    }
}
