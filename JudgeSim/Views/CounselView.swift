import SwiftUI

/// Anything the judge can hold a bench conference in.
protocol CounselProvider: ObservableObject {
    var unaskedCount: Int { get }
    func counselName(_ side: Side) -> String
    func counselStyle(_ side: Side) -> CounselStyle
    func availableQuestions(_ side: Side) -> [CounselQuestion]
    func entries(for side: Side) -> [TranscriptEntry]
    func ask(_ question: CounselQuestion)
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
                    Text(available == 0 ? "No new questions at this stage" : "\(available) question\(available == 1 ? "" : "s") you can put to the State or the defense")
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

                            let questions = provider.availableQuestions(side)
                            if questions.isEmpty {
                                Text("No further questions for \(side == .prosecution ? "the State" : "the defense") at this stage.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 8)
                            } else {
                                SectionTitle(text: "Ask", icon: "questionmark.bubble.fill")
                                ForEach(questions) { question in
                                    Button {
                                        Haptics.tap()
                                        withAnimation(.snappy) { provider.ask(question) }
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
                }
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
