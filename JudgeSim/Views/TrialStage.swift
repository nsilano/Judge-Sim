import SwiftUI

struct TrialStage: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let ethics = c.ethics {
                EthicsCard(event: ethics, chosen: session.rulings.ethicsChoice) { option in
                    session.chooseEthics(option)
                }
            }

            CollapsibleSection(title: "Opening statements", icon: "text.quote", summary: "Tap to read each side's opening", expanded: false) {
                Statement(side: .prosecution, speaker: c.prosecutor, text: c.prosecutionOpening)
                Statement(side: .defense, speaker: c.defenseAttorney, text: c.defenseOpening)
            }

            caseInChief(for: .prosecution, title: "The State's case", icon: "building.columns.fill")

            if session.stateRested {
                HalftimeMotionCard(session: session)
                if session.halftimeComplete {
                    RightToTestifyCard(session: session)
                }
            } else {
                Label("Rule on the objections in the State's case. When the State rests, the defense may move to dismiss.",
                      systemImage: "hourglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if session.halftimeComplete && session.testimonyDecided {
                caseInChief(for: .defense, title: "The defense case", icon: "shield.fill")
                if session.rulings.defendantTestifies == true, let testimony = c.defendantTestimony {
                    WitnessCard(witness: testimony, objections: [], session: session)
                }
            }

            if session.halftimeComplete && session.testimonyDecided {
                SectionTitle(text: "Closing arguments", icon: "text.quote")
                VStack(alignment: .leading, spacing: 12) {
                    Statement(side: .prosecution, speaker: c.prosecutor, text: c.prosecutionClosing)
                    Statement(side: .defense, speaker: c.defenseAttorney, text: c.defenseClosing)
                }
                .card()
            }

            PrimaryButton(title: "Close the Evidence & Decide the Verdict", icon: "checkmark.seal", enabled: session.trialComplete,
                          hint: pendingText) {
                session.advance()
            }
        }
    }

    private var pendingText: String {
        var parts: [String] = []
        if session.ethicsPending { parts.append("respond to the ethics issue") }
        let pending = session.pendingObjections
        if pending > 0 { parts.append("rule on \(pending) objection\(pending == 1 ? "" : "s")") }
        if session.stateRested && !session.halftimeComplete { parts.append("rule on the motion to dismiss") }
        if session.halftimeComplete && !session.testimonyDecided { parts.append("advise the defendant on the right to testify") }
        return "Still to do above: " + parts.joined(separator: ", ") + "."
    }

    @ViewBuilder
    private func caseInChief(for side: Side, title: String, icon: String) -> some View {
        let exhibits = c.evidence.filter { $0.side == side }
        let witnesses = c.witnesses.filter { $0.calledBy == side }
        if !exhibits.isEmpty || !witnesses.isEmpty {
            SectionTitle(text: title, icon: icon)
            if !exhibits.isEmpty {
                CollapsibleSection(title: "\(exhibits.count) exhibit\(exhibits.count == 1 ? "" : "s")", icon: "tray.full.fill",
                                   summary: exhibits.map(\.title).joined(separator: " · "), expanded: side == .prosecution) {
                    ForEach(exhibits) { item in
                        EvidenceCard(evidence: item, suppressed: session.isSuppressed(item))
                    }
                }
            }
            ForEach(witnesses) { witness in
                WitnessCard(witness: witness, objections: c.objections(for: witness), session: session)
            }
        }
    }
}

struct Statement: View {
    let side: Side
    let speaker: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle().fill(Theme.color(for: side)).frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(speaker).font(.caption.weight(.bold)).foregroundStyle(Theme.color(for: side))
                Text("\u{201C}\(text)\u{201D}").font(.system(.callout, design: .serif)).italic()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct EvidenceCard: View {
    let evidence: Evidence
    let suppressed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: evidence.kind.icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.color(for: evidence.side).opacity(0.15)))
                .foregroundStyle(Theme.color(for: evidence.side))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(evidence.exhibit).font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    Spacer()
                    if suppressed {
                        Pill(text: "Suppressed", color: Theme.bad, icon: "nosign")
                    } else if evidence.supplemental != nil {
                        Pill(text: "New", color: .purple, icon: "sparkles")
                    } else {
                        Text(evidence.kind.label).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Text(evidence.title)
                    .font(.headline)
                    .strikethrough(suppressed)
                Text(evidence.detail)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .opacity(suppressed ? 0.5 : 1)
        .card()
    }
}

struct WitnessCard: View {
    let witness: Witness
    let objections: [Objection]
    @ObservedObject var session: CaseSession
    @State private var askingWitness = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "person.wave.2.fill")
                    .foregroundStyle(Theme.color(for: witness.calledBy))
                VStack(alignment: .leading) {
                    Text(witness.name).font(.headline)
                    Text("\(witness.role) · called by the \(witness.calledBy.rawValue.lowercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ExaminationTranscript(witness: witness)
            ForEach(objections) { objection in
                ObjectionView(objection: objection, selection: session.objectionBinding(objection))
            }
            Button {
                Haptics.tap()
                askingWitness = true
            } label: {
                Label("Question this witness yourself", systemImage: "questionmark.bubble.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(Theme.gold)
            .sheet(isPresented: $askingWitness) {
                WitnessQuestionSheet(session: session, witness: witness)
            }
        }
        .card()
    }
}

struct ObjectionView: View {
    let objection: Objection
    @Binding var selection: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(objection.question).font(.callout.weight(.semibold))
            Text(objection.answer)
                .font(.system(.callout, design: .serif))
                .strikethrough(selection == true)
                .foregroundStyle(selection == true ? Color.secondary : Color.primary)
            HStack(spacing: 6) {
                Image(systemName: "hand.raised.fill")
                Text("\(objection.raisedBy == .prosecution ? "Prosecutor" : "Defense"): \"Objection, Your Honor! \(objection.grounds).\"")
            }
            .font(.callout.weight(.bold))
            .foregroundStyle(Theme.color(for: objection.raisedBy))
            LawLink(lawID: objection.doctrineID)
            RulingPicker(first: "Sustain", second: "Overrule",
                         firstDetail: "Answer is struck", secondDetail: "Answer stays in",
                         selection: $selection)
            if selection == true {
                Text("The answer is stricken. You must disregard it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.orange.opacity(0.4)))
    }
}

struct EthicsCard: View {
    let event: EthicsEvent
    let chosen: UUID?
    let onChoose: (EthicsOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ethics: \(event.title)", systemImage: "exclamationmark.shield.fill")
                .font(.headline)
                .foregroundStyle(.purple)
            Text(event.body)
            if let chosen, let option = event.options.first(where: { $0.id == chosen }) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("You chose: \(option.label)").font(.callout.weight(.semibold))
                    Text(option.result).font(.callout).foregroundStyle(.secondary)
                }
            } else {
                ForEach(event.options) { option in
                    Button {
                        Haptics.tap()
                        onChoose(option)
                    } label: {
                        Text(option.label)
                            .font(.callout.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
                LawLink(lawID: event.doctrineID)
            }
        }
        .card(tint: .purple)
    }
}


// MARK: - Motion to dismiss at the close of the State's evidence

struct HalftimeMotionCard: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        SectionTitle(text: "Motion to dismiss", icon: "hand.raised.fill")
        VStack(alignment: .leading, spacing: 12) {
            Text("The State rests. \(c.defenseAttorney.components(separatedBy: ",").first ?? "Defense counsel") moves to dismiss every count for insufficient evidence (G.S. 15A-1227).")
                .font(.callout)
            Text("The question is whether there is substantial evidence of each element and that the defendant committed the offense, taking the evidence in the light most favorable to the State. A dismissal is an acquittal and cannot be appealed by the State.")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(c.charges) { charge in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Count \(charge.count): \(charge.law.title)").font(.subheadline.weight(.semibold))
                    HStack(spacing: 8) {
                        ForEach(options(for: charge), id: \.self) { option in
                            let selected = session.rulings.halftime[charge.id] == option
                            Button {
                                Haptics.tap()
                                withAnimation(.snappy) { session.halftimeBinding(charge).wrappedValue = option }
                            } label: {
                                Text(option == .lesserOnly ? "Lesser only" : option.label)
                                    .font(.caption.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(selected ? Theme.gold.opacity(0.3) : Color(.tertiarySystemFill)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            LawLink(lawID: "burdenOfProof")
        }
        .card(tint: session.halftimeComplete ? Theme.gold : nil)
    }

    private func options(for charge: Charge) -> [HalftimeRuling] {
        charge.lesserLawID == nil ? [.deny, .dismiss] : [.deny, .lesserOnly, .dismiss]
    }
}

// MARK: - Right to testify

struct RightToTestifyCard: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        if c.defendantTestimony != nil {
            SectionTitle(text: "The defendant's right to testify", icon: "person.fill.questionmark")
            VStack(alignment: .leading, spacing: 10) {
                if let testifies = session.rulings.defendantTestifies {
                    Text("Court: \"\(c.defendant.lastName), you have the absolute right to testify, and the absolute right not to. If you don't, I will draw no inference from it. The decision is yours, not your lawyer's. Have you made it?\"")
                        .font(.system(.callout, design: .serif))
                    Text(testifies
                         ? "\(c.defendant.lastName): \"Yes, Your Honor. I want to testify.\""
                         : "\(c.defendant.lastName): \"Yes. I'm not going to testify.\"")
                        .font(.system(.callout, design: .serif)).italic()
                } else {
                    Text("Before the defense presents its case, you may address the defendant personally about the right to testify or remain silent.")
                        .font(.callout)
                    PrimaryButton(title: "Advise the Defendant", icon: "text.bubble.fill", enabled: true, hint: nil) {
                        withAnimation(.snappy) { session.adviseRightToTestify() }
                    }
                }
            }
            .card(tint: session.rulings.defendantTestifies == nil ? nil : Theme.gold)
        }
    }
}

// MARK: - Testimony transcript

/// A witness's testimony, question by question, grouped into direct, cross, and redirect.
struct ExaminationTranscript: View {
    let witness: Witness
    var struckAnswers: Set<String> = []

    private var exchanges: [TestimonyExchange] {
        if let exchanges = witness.exchanges, !exchanges.isEmpty { return exchanges }
        let opposing: Side = witness.calledBy == .prosecution ? .defense : .prosecution
        return witness.direct.map { TestimonyExchange(phase: .direct, examiner: witness.calledBy, question: "", answer: $0) }
            + witness.cross.map { TestimonyExchange(phase: .cross, examiner: opposing, question: "", answer: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach([TestimonyExchange.Phase.direct, .cross, .redirect], id: \.self) { phase in
                let lines = exchanges.filter { $0.phase == phase }
                if !lines.isEmpty {
                    PhaseBlock(phase: phase, lines: lines, expandedByDefault: phase != .redirect)
                }
            }
        }
    }

    private struct PhaseBlock: View {
        let phase: TestimonyExchange.Phase
        let lines: [TestimonyExchange]
        @State var expanded: Bool

        init(phase: TestimonyExchange.Phase, lines: [TestimonyExchange], expandedByDefault: Bool) {
            self.phase = phase
            self.lines = lines
            _expanded = State(initialValue: expandedByDefault)
        }

        var body: some View {
            DisclosureGroup(isExpanded: $expanded) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        VStack(alignment: .leading, spacing: 2) {
                            if !line.question.isEmpty {
                                Text("Q (\(line.examiner == .prosecution ? "State" : "Defense")): \(line.question)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.color(for: line.examiner))
                            }
                            Text(line.question.isEmpty ? line.answer : "A: \(line.answer)")
                                .font(.system(.callout, design: .serif))
                                .italic(line.question.isEmpty)
                        }
                    }
                }
                .padding(.top, 6)
            } label: {
                Text("\(phase.rawValue) · \(lines.count) question\(lines.count == 1 ? "" : "s")")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .tint(.secondary)
        }
    }
}
