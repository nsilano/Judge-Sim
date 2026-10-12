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

            SectionTitle(text: "Opening statements", icon: "text.quote")
            VStack(alignment: .leading, spacing: 12) {
                Statement(side: .prosecution, speaker: c.prosecutor, text: c.prosecutionOpening)
                Statement(side: .defense, speaker: c.defenseAttorney, text: c.defenseOpening)
            }
            .card()

            caseInChief(for: .prosecution, title: "The State's case", icon: "building.columns.fill")
            caseInChief(for: .defense, title: "The defense case", icon: "shield.fill")

            SectionTitle(text: "Closing arguments", icon: "text.quote")
            VStack(alignment: .leading, spacing: 12) {
                Statement(side: .prosecution, speaker: c.prosecutor, text: c.prosecutionClosing)
                Statement(side: .defense, speaker: c.defenseAttorney, text: c.defenseClosing)
            }
            .card()

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
        return "Scroll up to " + parts.joined(separator: " and ") + "."
    }

    @ViewBuilder
    private func caseInChief(for side: Side, title: String, icon: String) -> some View {
        let exhibits = c.evidence.filter { $0.side == side }
        let witnesses = c.witnesses.filter { $0.calledBy == side }
        if !exhibits.isEmpty || !witnesses.isEmpty {
            SectionTitle(text: title, icon: icon)
            ForEach(exhibits) { item in
                EvidenceCard(evidence: item, suppressed: session.isSuppressed(item))
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

            Text("Direct examination").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            ForEach(Array(witness.direct.enumerated()), id: \.offset) { _, line in
                Text(line).font(.system(.callout, design: .serif))
            }
            ForEach(objections.filter { $0.raisedBy != witness.calledBy }) { objection in
                ObjectionView(objection: objection, selection: session.objectionBinding(objection))
            }

            Text("Cross-examination").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            ForEach(Array(witness.cross.enumerated()), id: \.offset) { _, line in
                Text(line).font(.system(.callout, design: .serif))
            }
            ForEach(objections.filter { $0.raisedBy == witness.calledBy }) { objection in
                ObjectionView(objection: objection, selection: session.objectionBinding(objection))
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
