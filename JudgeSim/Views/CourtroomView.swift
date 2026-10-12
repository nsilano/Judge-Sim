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
                        Button {
                            confirmRecess = true
                        } label: {
                            Label("Leave", systemImage: "chevron.left")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showLibrary = true
                    } label: {
                        Label("Laws", systemImage: "books.vertical.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .sheet(isPresented: $showCounsel) {
                CounselSheet(provider: session)
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: session.courtCase.relevantLawIDs, showsDoneButton: true)
            }
            .confirmationDialog("Leave the courtroom?", isPresented: $confirmRecess, titleVisibility: .visible) {
                Button("Leave and start this case over later", role: .destructive) { dismiss() }
                Button("Stay", role: .cancel) {}
            } message: {
                Text("The case stays on your calendar, but rulings you've made so far will not be saved.")
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
                    Image(systemName: stage.rawValue < current.rawValue ? "checkmark" : stage.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(reached ? Theme.gold : Color(.tertiarySystemFill)))
                        .foregroundStyle(reached ? Color.black : Color.secondary)
                    Text(stage.shortTitle)
                        .font(.system(size: 10, weight: stage == current ? .bold : .regular))
                        .foregroundStyle(stage == current ? Color.primary : Color.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
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
    @State private var showColloquy = false
    private var c: CourtCase { session.courtCase }

    private var deNovoNote: [String] {
        guard c.court == .misdemeanorAppeal, let sentence = c.background?.districtCourtSentence else { return [] }
        return ["District court judgment: \(sentence). On a trial de novo you may impose any lawful sentence, including a harsher one."]
    }

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
            BulletList(items: c.proceduralNotes + deNovoNote, symbol: "circle.fill")
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

            if session.pleaPresented, let terms = c.background?.arrangementTerms {
                SectionTitle(text: "Plea arrangement", icon: "signature")
                VStack(alignment: .leading, spacing: 12) {
                    Text("The State and the defense present a negotiated plea for your approval.")
                        .font(.callout.weight(.semibold))
                    Text(terms).font(.callout)
                    Text("If you accept, the case goes straight to sentencing and you may impose whatever sentence you choose. If you reject it, the case goes to trial.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if session.rulings.pleaWithdrawn {
                        Label(session.pleaWithdrawalNote ?? "The defendant withdrew the plea. The case will be tried.", systemImage: "arrow.uturn.backward.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.orange)
                    } else if session.rulings.pleaAccepted == false {
                        Label("You rejected the plea. The case will be tried.", systemImage: "xmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.orange)
                    } else {
                        HStack(spacing: 10) {
                            Button {
                                Haptics.tap()
                                showColloquy = true
                            } label: {
                                Label("Take the plea", systemImage: "checkmark.seal.fill")
                                    .font(.subheadline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.gold))
                                    .foregroundStyle(Color.black)
                            }
                            .buttonStyle(.plain)
                            Button {
                                Haptics.tap()
                                session.rejectPlea()
                            } label: {
                                Label("Reject, go to trial", systemImage: "xmark")
                                    .font(.subheadline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemFill)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .card(tint: Theme.gold)
            }

            Color.clear.frame(height: 0)
                .sheet(isPresented: $showColloquy) {
                    PleaColloquySheet(session: session) { kind in
                        showColloquy = false
                        Haptics.gavel()
                        session.acceptPlea(kind: kind)
                    } onReject: {
                        showColloquy = false
                        session.rejectPlea()
                    }
                }

            PrimaryButton(title: c.motions.isEmpty ? "Start the Trial" : "Go to Pretrial Motions",
                          enabled: !session.pleaPresented || session.rulings.pleaAccepted == false,
                          hint: "Accept or reject the plea arrangement first.") {
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

            PrimaryButton(title: session.dismissedBySpeedyTrial ? "Dismiss the Case" : "Start the Trial",
                          icon: session.dismissedBySpeedyTrial ? "xmark.seal.fill" : "chevron.right",
                          enabled: session.motionsComplete,
                          hint: "Grant or deny every motion to continue.") {
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
            RulingPicker(first: "Grant", second: "Deny",
                         firstDetail: motion.kind == .dismissSpeedyTrial ? "Case is dismissed" : "Evidence is excluded",
                         secondDetail: motion.kind == .dismissSpeedyTrial ? "Case goes forward" : "Evidence comes in",
                         selection: $selection)
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


// MARK: - Plea colloquy (G.S. 15A-1022)

struct PleaColloquySheet: View {
    @ObservedObject var session: CaseSession
    let onAccept: (PleaKind) -> Void
    let onReject: () -> Void
    @State private var kind: PleaKind = .guilty
    @State private var asked = 0
    @Environment(\.dismiss) private var dismiss

    private var c: CourtCase { session.courtCase }

    private struct Exchange {
        let question: String
        let answer: String
    }

    private var exchanges: [Exchange] {
        let dl = c.defendant.lastName
        var rng = SeededRNG(seed: c.seed ^ 0x1022)
        let lawTitle = c.background?.arrangementLawID.map { LawLibrary.law($0).title } ?? "the charge"
        let hesitant = !c.truth.actuallyGuilty && rng.chance(0.5)
        let noncitizen = rng.chance(0.12)
        var list = [
            Exchange(question: "Do you understand that you have the right to remain silent, and that anything you say may be used against you?",
                     answer: "\(dl): \"Yes, Your Honor.\""),
            Exchange(question: "Do you understand that by pleading you give up your right to a trial, to confront the witnesses against you, and to make the State prove your guilt beyond a reasonable doubt?",
                     answer: "\(dl): \"Yes.\""),
            Exchange(question: "Do you understand that the charge is \(lawTitle), and that the maximum possible punishment is \(session.pleaMaximumText)?",
                     answer: "\(dl): \"Yes, Your Honor. My lawyer went over that.\""),
            Exchange(question: "If you are not a citizen of the United States, do you understand this plea may result in deportation, exclusion from admission, or denial of naturalization?",
                     answer: noncitizen
                        ? "\(dl): \"Yes. I'm a permanent resident. My lawyer had me talk to an immigration attorney first.\""
                        : "\(dl): \"I'm a citizen, Your Honor. But yes, I understand.\""),
            Exchange(question: "Has anyone promised you anything or threatened you in any way to cause you to enter this plea against your wishes, other than the terms of the arrangement?",
                     answer: "\(dl): \"No, Your Honor.\""),
            Exchange(question: "Are you satisfied with your lawyer's services?",
                     answer: "\(dl): \"Yes.\""),
            Exchange(question: "What is the State's factual basis for the plea?",
                     answer: "\(c.prosecutor): \"\(c.summary)\"")
        ]
        list.append(Exchange(question: "Are you in fact guilty?",
                             answer: hesitant
                                ? "\(dl) looks at counsel for a long moment. \"I... I didn't do it the way they say. But I can't risk a trial.\" Defense counsel asks whether the court will accept an Alford plea."
                                : "\(dl): \"Yes, Your Honor.\""))
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Before accepting a plea, the judge must address the defendant personally in open court (G.S. 15A-1022).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(Array(exchanges.prefix(asked).enumerated()), id: \.offset) { _, exchange in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Court: \(exchange.question)").font(.callout.weight(.semibold))
                            Text(exchange.answer).font(.system(.callout, design: .serif)).italic()
                        }
                        .card()
                    }
                    if asked < exchanges.count {
                        Button {
                            Haptics.tap()
                            withAnimation(.snappy) { asked += 1 }
                        } label: {
                            Label(asked == 0 ? "Begin the colloquy" : "Next question", systemImage: "text.bubble.fill")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemFill)))
                        }
                        .buttonStyle(.plain)
                        Button("Skip to the end") { withAnimation { asked = exchanges.count } }
                            .font(.caption)
                    } else {
                        Text("Form of the plea").font(.headline)
                        ForEach(PleaKind.allCases, id: \.self) { option in
                            ChoiceRow(title: option.label,
                                      subtitle: option.detail + (option == .noContest
                                        ? (c.background?.stateConsentsNoContest == true ? " The State consents." : " The State does not consent.")
                                        : ""),
                                      selected: kind == option) {
                                kind = option
                            }
                        }
                        PrimaryButton(title: "Accept the Plea", icon: "checkmark.seal.fill", enabled: true, hint: nil) {
                            onAccept(kind)
                        }
                        Button(role: .destructive) {
                            onReject()
                        } label: {
                            Text("Reject the plea and set the case for trial").frame(maxWidth: .infinity)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
            }
            .navigationTitle("Plea Colloquy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
