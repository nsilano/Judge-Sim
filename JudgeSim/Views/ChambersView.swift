import SwiftUI

struct RootView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        if game.judgeName == nil {
            OnboardingView()
        } else {
            TabView {
                ChambersView()
                    .tabItem { Label("Chambers", systemImage: "building.columns.fill") }
                LawLibraryView()
                    .tabItem { Label("Law Library", systemImage: "books.vertical.fill") }
                CareerView()
                    .tabItem { Label("Career", systemImage: "person.text.rectangle.fill") }
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var game: GameState
    @State private var name = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.gold)
                    .padding(.top, 48)
                Text("Judge Sim")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                Text("You've just been sworn in as a trial judge in the \(LawLibrary.jurisdiction). Defendants have waived their right to a jury. In your courtroom, you decide everything.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 14) {
                    feature("doc.text.magnifyingglass", "Rule on motions", "Suppress illegally seized evidence, even when it means letting the guilty go free.")
                    feature("hand.raised.fill", "Sustain or overrule", "Hearsay, speculation, leading questions. The appeals court is watching.")
                    feature("checkmark.seal.fill", "Decide guilt", "Proof beyond a reasonable doubt. Nothing less.")
                    feature("scalemass.fill", "Pass sentence", "Weigh aggravating and mitigating factors within the statutory range.")
                    feature("eye.fill", "Learn the truth", "After each case, you discover what really happened.")
                }
                .card()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your name").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    TextField("e.g. Morgan Avery", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                }

                PrimaryButton(title: "Take the Oath", icon: "hand.raised.fill",
                              enabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    Haptics.gavel()
                    game.startCareer(name: name.trimmingCharacters(in: .whitespaces))
                }

                Text(LawLibrary.disclaimer)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func feature(_ icon: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.gold)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.bold))
                Text(text).font(.callout).foregroundStyle(.secondary)
            }
        }
    }
}

struct ChambersView: View {
    @EnvironmentObject private var game: GameState
    @State private var activeCase: CourtCase?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    profileCard

                    if let end = game.careerEnd {
                        careerOver(end)
                    } else {
                        if let message = game.lastReviewMessage {
                            Label(message, systemImage: "checkmark.seal.fill")
                                .font(.callout)
                                .card(tint: Theme.good)
                        }
                        docketCard
                    }

                    if !game.history.isEmpty {
                        SectionTitle(text: "Recent rulings", icon: "clock.fill")
                        ForEach(game.history.prefix(5)) { record in
                            CaseRecordRow(record: record)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Chambers")
            .fullScreenCover(item: $activeCase) { courtCase in
                CourtroomView(courtCase: courtCase)
                    .environmentObject(game)
            }
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.mahogany)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hon. \(game.judgeName ?? "")")
                        .font(.system(.title2, design: .serif).weight(.bold))
                    Text(game.title)
                        .font(.subheadline)
                        .foregroundStyle(Theme.gold)
                }
            }
            Meter(label: "Integrity", value: game.integrity, icon: "checkmark.shield.fill", color: .blue)
            Meter(label: "Public Approval", value: game.approval, icon: "person.3.fill", color: .orange)
            HStack {
                stat("\(game.casesHeard)", "Cases")
                Spacer()
                stat("\(game.reversals)", "Reversed")
                Spacer()
                stat(game.careerEnd == nil ? "\(game.casesUntilReview)" : "—", "To retention vote")
            }
        }
        .card()
    }

    private var docketCard: some View {
        let next = game.currentCase
        return VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "Today's docket", icon: "calendar")
            if let next {
                Text(next.docket).font(.caption.monospaced()).foregroundStyle(.secondary)
                Text(next.headline).font(.system(.title3, design: .serif).weight(.bold))
                Text(next.caption).font(.subheadline.italic()).foregroundStyle(.secondary)
                Text(next.charges.map(\.law.title).joined(separator: " · "))
                    .font(.callout)
            } else {
                Text("A new case is waiting in the clerk's office.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            PrimaryButton(title: next == nil ? "Call the Next Case" : "Resume Case", icon: "hammer.fill") {
                Haptics.gavel()
                activeCase = game.docketCase()
            }
        }
        .card(tint: Theme.gold)
    }

    private func careerOver(_ end: CareerEnd) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(end.title)
                .font(.system(.title, design: .serif).weight(.bold))
                .foregroundStyle(Theme.bad)
            Text(end.reason)
            Text("You heard \(game.casesHeard) cases. \(game.wrongfulConvictions) innocent people were convicted in your courtroom, and \(game.guiltyAcquitted) guilty people walked free.")
                .font(.callout)
                .foregroundStyle(.secondary)
            PrimaryButton(title: "Begin a New Career", icon: "arrow.counterclockwise") {
                game.resetCareer()
            }
        }
        .card(tint: Theme.bad)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading) {
            Text(value).font(.system(.title3, design: .rounded).weight(.bold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct CaseRecordRow: View {
    let record: CaseRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(record.grade)
                .font(.system(.title2, design: .serif).weight(.black))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.gold.opacity(0.18)))
            VStack(alignment: .leading, spacing: 4) {
                Text(record.caption).font(.subheadline.weight(.semibold))
                Text(record.verdictSummary).font(.caption)
                if let sentence = record.sentenceSummary {
                    Text(sentence).font(.caption).foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Pill(text: record.appealLabel,
                         color: record.appealLabel.contains("Reversed") || record.appealLabel.contains("vacated") ? Theme.bad : .secondary)
                    if record.convicted != record.actuallyGuilty {
                        Pill(text: record.convicted ? "Innocent convicted" : "Guilty freed", color: .purple)
                    }
                }
            }
        }
        .card()
    }
}

struct CareerView: View {
    @EnvironmentObject private var game: GameState
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            List {
                Section("Record") {
                    row("Title", game.title)
                    row("Cases heard", "\(game.casesHeard)")
                    row("Integrity", "\(game.integrity) / 100")
                    row("Public approval", "\(game.approval) / 100")
                    row("Reversed on appeal", "\(game.reversals) (\(Int((game.reversalRate * 100).rounded()))% of convictions)")
                }
                Section {
                    row("Innocent people convicted", "\(game.wrongfulConvictions)")
                    row("Guilty people acquitted", "\(game.guiltyAcquitted)")
                } header: {
                    Text("The truth")
                } footer: {
                    Text("A good judge follows the law even when it leads somewhere uncomfortable. Integrity measures legal soundness, not luck.")
                }
                Section("All cases") {
                    if game.history.isEmpty {
                        Text("No cases heard yet.").foregroundStyle(.secondary)
                    }
                    ForEach(game.history) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(record.caption).font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(record.grade).font(.headline)
                            }
                            Text(record.headline).font(.caption).foregroundStyle(.secondary)
                            Text(record.verdictSummary).font(.caption)
                        }
                    }
                }
                Section {
                    Button("Resign and Start Over", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("Career")
            .confirmationDialog("Resign from the bench? Your entire record will be erased.",
                                isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Resign", role: .destructive) { game.resetCareer() }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
        }
    }
}
