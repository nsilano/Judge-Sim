import SwiftUI

struct CourtroomView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session: CaseSession
    @State private var showLibrary = false
    @State private var showCounsel = false
    @State private var confirmRecess = false

    init(courtCase: CourtCase, judgeName: String, county: County) {
        _session = StateObject(wrappedValue: CaseSession(courtCase: courtCase, judgeName: judgeName, county: county))
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        StageTracker(stages: session.visibleStages, current: session.stage)
                            .id("top")

                        if session.stage != .judgment {
                            CounselPrompt(available: session.unaskedCount) { showCounsel = true }
                        }

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
                        case .probation:
                            ProbationStage(session: session)
                        case .judgment:
                            if let outcome = session.outcome {
                                JudgmentStage(courtCase: session.courtCase, outcome: outcome) {
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
                if session.stage != .judgment {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Recess") { confirmRecess = true }
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    if session.stage != .judgment {
                        Button {
                            showCounsel = true
                        } label: {
                            Label("Ask counsel", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                    }
                    Button {
                        showLibrary = true
                    } label: {
                        Label("Law Library", systemImage: "books.vertical.fill")
                    }
                }
            }
            .sheet(isPresented: $showCounsel) {
                CounselSheet(provider: session)
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: session.courtCase.relevantLawIDs, showsDoneButton: true)
            }
            .confirmationDialog("Recess court?", isPresented: $confirmRecess, titleVisibility: .visible) {
                Button("Recess (rulings so far are set aside)", role: .destructive) { dismiss() }
                Button("Stay in session", role: .cancel) {}
            } message: {
                Text("The case stays on the calendar. When court resumes, the hearing starts over.")
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
                Text("\(session.county.courtName.uppercased()) · CRIMINAL SESSION")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.gold)
                Text("\(c.docket) · \(SentenceFormat.date(c.sessionDate))")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text(c.headline)
                    .font(.system(.title, design: .serif).weight(.bold))
                Text(c.caption)
                    .font(.subheadline.italic())
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Pill(text: c.court.label, color: Theme.gold, icon: "building.columns")
                        Pill(text: c.mood.label, icon: c.mood.icon)
                        if c.defendant.isReturning {
                            Pill(text: "Returning defendant", color: .purple, icon: "arrow.uturn.left")
                        }
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

            SectionTitle(text: "Procedural posture", icon: "doc.plaintext")
            BulletList(items: c.proceduralNotes, symbol: "circle.fill")
                .font(.callout)
                .card()

            SectionTitle(text: "The defendant", icon: "person.fill")
            DefendantCard(defendant: c.defendant, county: session.county)

            SectionTitle(text: "Charges", icon: "list.bullet.rectangle.fill")
            ForEach(c.charges) { charge in
                ChargeCard(charge: charge)
            }

            SectionTitle(text: "Counsel & investigation", icon: "person.2.fill")
            VStack(alignment: .leading, spacing: 8) {
                Label { Text("For the State: ").bold() + Text(c.prosecutor) } icon: {
                    Image(systemName: "building.columns").foregroundStyle(Theme.prosecution)
                }
                Label { Text("For the defendant: ").bold() + Text(c.defenseAttorney) } icon: {
                    Image(systemName: "shield").foregroundStyle(Theme.defense)
                }
                Label { Text("Investigating agency: ").bold() + Text(c.investigatingAgency) } icon: {
                    Image(systemName: "star.circle").foregroundStyle(.secondary)
                }
            }
            .font(.callout)
            .card()

            PrimaryButton(title: c.motions.isEmpty ? "Call the Case for Trial" : "Hear Pretrial Motions") {
                session.advance()
            }
        }
    }
}

struct DefendantCard: View {
    let defendant: Defendant
    let county: County

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
            Text(defendant.background).font(.callout)

            if defendant.isReturning {
                Divider()
                Text("Previously before this court").font(.caption.weight(.bold)).foregroundStyle(.purple)
                ForEach(Array(defendant.history.enumerated()), id: \.offset) { _, appearance in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(appearance.docket) · \(SentenceFormat.shortDate(appearance.date))")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        Text("\(appearance.charges): \(appearance.outcome)").font(.callout)
                    }
                }
            }

            if let probation = defendant.probation {
                Label("On probation: \(probation.docket), \(probation.offense). Suspended sentence: \(probation.suspendedSentence). Term ends \(SentenceFormat.shortDate(probation.ends)).",
                      systemImage: "person.badge.clock.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            }

            Divider()
            Text("Criminal record").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            if defendant.priors.isEmpty {
                Label("No prior convictions", systemImage: "checkmark.circle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(defendant.priors) { prior in
                    PriorRow(prior: prior)
                }
            }
        }
        .card()
    }
}

struct PriorRow: View {
    let prior: PriorConviction

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(String(prior.year))
                .font(.caption.monospacedDigit().weight(.semibold))
                .frame(width: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(prior.offense).font(.callout.weight(.semibold))
                    if prior.fromThisCourt {
                        Pill(text: "Your court", color: .purple)
                    }
                }
                Text("\(prior.ncClass.shortLabel) · \(prior.county) · \(prior.sentence)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
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
                if let cls = law.ncClass {
                    Pill(text: cls.label, color: cls.isFelony ? Theme.bad : .orange)
                }
            }
            Text(law.title).font(.headline)
            Text(law.statute).font(.caption.monospaced()).foregroundStyle(.secondary)
            Text(charge.specification).font(.callout)
            HStack {
                LawLink(lawID: law.id)
                if let lesser = charge.lesserLawID {
                    LawLink(lawID: lesser)
                }
            }
            if let lesser = charge.lesserLaw, let cls = lesser.ncClass {
                Text("Lesser-included offense: \(lesser.title) (\(cls.shortLabel))")
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
            Text("The defense has filed pretrial motions. You've heard testimony and argument at the suppression hearing. Rule on each.")
                .font(.callout)
                .foregroundStyle(.secondary)

            ForEach(session.courtCase.motions) { motion in
                MotionCard(motion: motion,
                           target: session.courtCase.evidence(motion.targetEvidenceID),
                           selection: session.motionBinding(motion))
            }

            PrimaryButton(title: session.dismissedBySpeedyTrial ? "Enter Order of Dismissal" : "Proceed to Trial",
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
                Text("Evidence at the hearing").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                Text(motion.facts)
            }
            argument(side: .defense, text: motion.defenseArgument)
            argument(side: .prosecution, text: motion.prosecutionResponse)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack { ForEach(motion.doctrineIDs, id: \.self) { LawLink(lawID: $0) } }
            }
            RulingPicker(first: "Allow", second: "Deny", selection: $selection)
            if selection == true {
                Text(motion.kind == .dismissSpeedyTrial
                     ? "All charges will be dismissed."
                     : "This evidence will not be admitted at trial.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
