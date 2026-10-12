import SwiftUI

struct CourtroomView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session: CaseSession
    @State private var showLibrary = false
    @State private var confirmRecess = false

    init(courtCase: CourtCase) {
        _session = StateObject(wrappedValue: CaseSession(courtCase: courtCase))
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        StageTracker(stages: session.visibleStages, current: session.stage)
                            .id("top")

                        switch session.stage {
                        case .briefing:
                            BriefingStage(session: session)
                        case .motions:
                            MotionsStage(session: session)
                        case .trial:
                            TrialStage(session: session)
                        case .verdict:
                            VerdictStage(session: session)
                        case .sentencing:
                            SentencingStage(session: session)
                        case .outcome:
                            if let outcome = session.outcome {
                                OutcomeStage(courtCase: session.courtCase, outcome: outcome) {
                                    game.complete(session.courtCase, outcome: outcome)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: session.stage) {
                    withAnimation { proxy.scrollTo("top", anchor: .top) }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(session.stage.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if session.stage != .outcome {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Recess") { confirmRecess = true }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showLibrary = true
                    } label: {
                        Label("Law Library", systemImage: "books.vertical.fill")
                    }
                }
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: session.courtCase.relevantLawIDs, showsDoneButton: true)
            }
            .confirmationDialog("Call a recess?", isPresented: $confirmRecess, titleVisibility: .visible) {
                Button("Recess (rulings will be lost)", role: .destructive) { dismiss() }
                Button("Stay in court", role: .cancel) {}
            } message: {
                Text("The case stays on your docket, but you'll have to hear it again from the start.")
            }
        }
        .interactiveDismissDisabled()
    }
}

struct StageTracker: View {
    let stages: [CaseSession.Stage]
    let current: CaseSession.Stage

    var body: some View {
        HStack(spacing: 4) {
            ForEach(stages) { stage in
                let reached = stage.rawValue <= current.rawValue
                VStack(spacing: 4) {
                    Image(systemName: stage.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(reached ? Theme.gold : Color(.tertiarySystemFill)))
                        .foregroundStyle(reached ? Color.black : Color.secondary)
                    Capsule()
                        .fill(stage == current ? Theme.gold : Color.clear)
                        .frame(width: 16, height: 3)
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel(stage.title)
            }
        }
    }
}

// MARK: - Briefing

struct BriefingStage: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(c.docket) · Bench Trial")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text(c.headline)
                    .font(.system(.title, design: .serif).weight(.bold))
                Text(c.caption)
                    .font(.subheadline.italic())
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Pill(text: c.category.rawValue, color: Theme.gold, icon: c.category.icon)
                        Pill(text: c.mood.label, icon: c.mood.icon)
                        Pill(text: String(repeating: "★", count: c.mediaAttention) + " media", color: .orange)
                    }
                }
            }

            Text(c.summary)
                .card()

            if let twist = c.twist {
                Label(twist, systemImage: "exclamationmark.bubble.fill")
                    .font(.callout)
                    .card(tint: .orange)
            }

            SectionTitle(text: "The Defendant", icon: "person.fill")
            DefendantCard(defendant: c.defendant)

            SectionTitle(text: "Charges", icon: "list.bullet.rectangle.fill")
            ForEach(c.charges) { charge in
                ChargeCard(charge: charge)
            }

            SectionTitle(text: "Counsel", icon: "person.2.fill")
            VStack(alignment: .leading, spacing: 8) {
                Label { Text("For the State: ").bold() + Text(c.prosecutor) } icon: {
                    Image(systemName: "building.columns").foregroundStyle(Theme.prosecution)
                }
                Label { Text("For the Defense: ").bold() + Text(c.defenseAttorney) } icon: {
                    Image(systemName: "shield").foregroundStyle(Theme.defense)
                }
                Text("The defendant has waived a jury. You alone will decide the facts, the law, and the sentence.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .card()

            PrimaryButton(title: c.motions.isEmpty ? "Begin Trial" : "Hear Pretrial Motions") {
                session.advance()
            }
        }
    }
}

struct DefendantCard: View {
    let defendant: Defendant

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.square.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.mahogany)
                VStack(alignment: .leading) {
                    Text(defendant.name).font(.title3.weight(.bold))
                    Text("Age \(defendant.age) · \(defendant.occupation)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Text(defendant.background)
                .font(.callout)
            Divider()
            Text("Criminal record").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            if defendant.priorRecord.isEmpty {
                Label("No prior convictions", systemImage: "checkmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(Theme.good)
            } else {
                BulletList(items: defendant.priorRecord, symbol: "exclamationmark.circle.fill", color: .orange)
                    .font(.callout)
            }
        }
        .card()
    }
}

struct ChargeCard: View {
    let charge: Charge

    var body: some View {
        let law = charge.law
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Count \(charge.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                if let offenseClass = law.offenseClass {
                    Pill(text: offenseClass.rawValue, color: offenseClass.isFelony ? Theme.bad : .orange)
                }
            }
            Text(law.title).font(.headline)
            Text(charge.specification).font(.callout)
            if let sentence = law.sentence {
                Label("\(law.code) · \(sentence.summary)\(sentence.mandatoryMinimum ? " · mandatory minimum" : "")",
                      systemImage: "scalemass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                LawLink(lawID: law.id)
                if let lesser = charge.lesserLawID {
                    LawLink(lawID: lesser)
                }
            }
            if let lesser = charge.lesserLaw {
                Text("Lesser included offense available: \(lesser.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }
}

// MARK: - Motions

struct MotionsStage: View {
    @ObservedObject var session: CaseSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before trial begins, the defense has filed motions. Rule on each one. Suppressed evidence won't be heard at trial, and the appeals court will review your rulings.")
                .font(.callout)
                .foregroundStyle(.secondary)

            ForEach(session.courtCase.motions) { motion in
                MotionCard(motion: motion,
                           target: session.courtCase.evidence(motion.targetEvidenceID),
                           selection: session.motionBinding(motion))
            }

            PrimaryButton(title: session.dismissedBySpeedyTrial ? "Dismiss the Case" : "Proceed to Trial",
                          icon: session.dismissedBySpeedyTrial ? "xmark.seal.fill" : "chevron.right",
                          enabled: session.motionsComplete) {
                Haptics.gavel()
                session.advance()
            }
        }
    }
}

struct MotionCard: View {
    let motion: Motion
    let target: Evidence?
    @Binding var selection: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(motion.kind.title).font(.headline)
            if let target {
                Label("\(target.exhibit): \(target.title)", systemImage: target.kind.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.gold)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Facts established at the hearing").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                Text(motion.facts)
            }
            argument(side: .defense, text: motion.defenseArgument)
            argument(side: .prosecution, text: motion.prosecutionResponse)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack { ForEach(motion.doctrineIDs, id: \.self) { LawLink(lawID: $0) } }
            }
            RulingPicker(first: "Grant", second: "Deny", selection: $selection)
            if selection == true {
                Text(motion.kind == .dismissSpeedyTrial
                     ? "All charges will be dismissed with prejudice."
                     : "This evidence will be excluded from trial.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .card(tint: selection == nil ? nil : Theme.gold)
    }

    private func argument(side: Side, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle().fill(Theme.color(for: side)).frame(width: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(side.rawValue).font(.caption.weight(.bold)).foregroundStyle(Theme.color(for: side))
                Text(text).font(.callout)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
