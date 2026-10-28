import SwiftUI

struct TrialStage: View {
    @ObservedObject var session: CaseSession
    /// Called when a ruling sends the case to another date (reason, days, start the trial over).
    var onIncidentContinue: (String, Int, Bool) -> Void = { _, _, _ in }
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IncidentCards(session: session, moment: .trial, onContinue: onIncidentContinue)
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
                if session.halftimeMotion.isMade {
                    HalftimeMotionCard(session: session)
                } else {
                    Label("The State rests. The defense makes no motion to dismiss.", systemImage: "checkmark.seal")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
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
                    SectionTitle(text: "\(c.defendant.name) takes the stand", icon: "person.fill.questionmark")
                    Text("The defendant testifies in their own defense and is cross-examined by the State. Weigh this testimony like any other witness's.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    WitnessCard(witness: testimony, objections: c.objections(for: testimony), session: session)
                }
                if session.halftimeMotion.isMade {
                    Label(session.halftimeMotion.renewal, systemImage: "hand.raised")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if session.halftimeComplete && session.testimonyDecided {
                SectionTitle(text: "Closing arguments", icon: "text.quote")
                VStack(alignment: .leading, spacing: 12) {
                    Statement(side: .prosecution, speaker: c.prosecutor, text: Allocutions.closing(c, side: .prosecution, rulings: session.rulings))
                    Statement(side: .defense, speaker: c.defenseAttorney, text: Allocutions.closing(c, side: .defense, rulings: session.rulings))
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
                        EvidenceCard(evidence: item, suppressed: session.isSuppressed(item), courtCase: c)
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
    /// The case the exhibit belongs to; when given, the exhibit can be opened and reviewed.
    var courtCase: CourtCase? = nil
    @State private var reviewing = false

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
                if courtCase != nil {
                    Button {
                        Haptics.tap()
                        reviewing = true
                    } label: {
                        Label(reviewLabel, systemImage: "eye.fill").font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 2)
                }
            }
        }
        .opacity(suppressed ? 0.5 : 1)
        .card()
        .sheet(isPresented: $reviewing) {
            if let courtCase { ExhibitViewer(evidence: evidence, courtCase: courtCase, suppressed: suppressed) }
        }
    }

    private var reviewLabel: String {
        switch evidence.kind {
        case .video: return "Watch the footage"
        case .document: return "Read the document"
        case .digital: return "Open the extraction"
        case .statement: return "Read the transcript"
        case .forensic: return "Read the lab report"
        case .physical: return "Examine the item"
        }
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

            // Objections come up where they happen: right after the question that drew them.
            ExaminationTranscript(witness: witness, suppressed: session.suppressedTerms,
                                  objections: objections, objectionBinding: { session.objectionBinding($0) })
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
            Text("Objection · \(objection.grounds)".uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Theme.objectionLabel)
            Text(objection.question).font(.callout).foregroundStyle(Theme.quoteText)
            Text(objection.answer)
                .font(.system(.body, design: .serif))
                .strikethrough(selection == true)
                .foregroundStyle(selection == true ? Theme.secondaryText : Theme.text)
            HStack(spacing: 6) {
                Image(systemName: "hand.raised.fill")
                Text("\(objection.raisedBy == .prosecution ? "Prosecutor" : "Defense"): \"Objection, Your Honor! \(objection.grounds).\"")
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(Theme.text)
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
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.objectionFill))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.objectionBorder, lineWidth: 1))
    }
}

/// The courtroom incidents at one point in the case, each with its options until the judge rules.
struct IncidentCards: View {
    @ObservedObject var session: CaseSession
    let moment: CourtIncident.Moment
    var onContinue: (String, Int, Bool) -> Void = { _, _, _ in }

    var body: some View {
        ForEach(session.incidents(at: moment)) { incident in
            IncidentCard(incident: incident, chosen: session.rulings.choice(for: incident)) { option in
                session.chooseIncident(incident, option)
                if option.effect == .continueCase || option.effect == .mistrial {
                    onContinue("\(incident.title): \(option.label.lowercased()).", option.days ?? 28, option.effect == .mistrial)
                }
            }
            if let pending = session.incidentContinuance, pending.incident.id == incident.id {
                Button {
                    onContinue("\(incident.title): \(pending.option.label.lowercased()).", pending.option.days ?? 28, pending.option.effect == .mistrial)
                } label: {
                    Label("Set the new date", systemImage: "calendar.badge.clock").font(.subheadline.weight(.semibold))
                }
            }
        }
    }
}

struct IncidentCard: View {
    let incident: CourtIncident
    let chosen: IncidentOption?
    let onChoose: (IncidentOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(incident.title, systemImage: "exclamationmark.bubble.fill")
                .font(.headline)
                .foregroundStyle(.orange)
            Text(incident.body).font(.callout)
            if let chosen {
                VStack(alignment: .leading, spacing: 6) {
                    Text("You ruled: \(chosen.label)").font(.callout.weight(.semibold))
                    Text(chosen.result).font(.callout).foregroundStyle(.secondary)
                }
            } else {
                ForEach(incident.options) { option in
                    Button {
                        Haptics.tap()
                        onChoose(option)
                    } label: {
                        Text(option.label)
                            .font(.callout.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
                LawLink(lawID: incident.lawID)
            }
        }
        .card(tint: .orange)
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
            let motion = session.halftimeMotion
            Text(motion.opening)
                .font(.callout)
            Text(motion.response)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(Theme.prosecution)
            Text("The question is whether there is substantial evidence of each element and that the defendant committed the offense, taking the evidence in the light most favorable to the State. A dismissal is an acquittal and cannot be appealed by the State.")
                .font(.caption)
                .foregroundStyle(.secondary)
            let unchallenged = c.charges.filter { !motion.challenged.contains($0.id) }
            if !unchallenged.isEmpty {
                Text("Not challenged, and going forward: " + unchallenged.map { "Count \($0.count)" }.joined(separator: ", ") + ".")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(c.charges.filter { motion.challenged.contains($0.id) }) { charge in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Count \(charge.count): \(charge.law.title)").font(.subheadline.weight(.semibold))
                    if let argument = motion.arguments[charge.id] {
                        Text("\u{201C}\(argument)\u{201D}")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Theme.defense)
                    }
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
                                    .background(RoundedRectangle(cornerRadius: 10).fill(selected ? Theme.gold.opacity(0.3) : Theme.raised))
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
    /// Exhibits the court suppressed; questions about them aren't asked.
    var suppressed: [String] = []
    /// Objections to rule on, shown in the transcript where they arise.
    var objections: [Objection] = []
    var objectionBinding: ((Objection) -> Binding<Bool?>)? = nil

    /// Which phase an objection arises in (direct when the questioner called the witness), and after which question.
    private func placement(_ o: Objection, lines: [TestimonyExchange]) -> Int {
        guard !lines.isEmpty else { return -1 }
        return "\(o.id)".stableHash % lines.count
    }

    private func phase(of o: Objection) -> TestimonyExchange.Phase {
        let asker: Side = o.raisedBy == .defense ? .prosecution : .defense
        return asker == witness.calledBy ? .direct : .cross
    }

    private var exchanges: [TestimonyExchange] {
        let all: [TestimonyExchange]
        if let exchanges = witness.exchanges, !exchanges.isEmpty {
            all = exchanges
        } else {
            let opposing: Side = witness.calledBy == .prosecution ? .defense : .prosecution
            all = witness.direct.map { TestimonyExchange(phase: .direct, examiner: witness.calledBy, question: "", answer: $0) }
                + witness.cross.map { TestimonyExchange(phase: .cross, examiner: opposing, question: "", answer: $0) }
        }
        guard !suppressed.isEmpty else { return all }
        // Whole phrases only: suppressing "State's Exhibit 1" leaves Exhibit 12 alone.
        let patterns = suppressed.map { "(?i)\\b" + NSRegularExpression.escapedPattern(for: $0) + "(?![0-9A-Za-z])" }
        func mentions(_ text: String) -> Bool { patterns.contains { text.range(of: $0, options: .regularExpression) != nil } }
        return all.filter { e in !mentions(e.question) && !mentions(e.answer) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach([TestimonyExchange.Phase.direct, .cross, .redirect], id: \.self) { phase in
                let lines = exchanges.filter { $0.phase == phase }
                let here = objections.filter { self.phase(of: $0) == phase }.map { (after: placement($0, lines: lines), objection: $0) }
                if !lines.isEmpty || !here.isEmpty {
                    PhaseBlock(phase: phase, lines: lines, objections: here, binding: objectionBinding,
                               expandedByDefault: phase != .redirect || !here.isEmpty)
                }
            }
        }
    }

    /// Testimony in curly quotes, whether or not the text already carries straight ones.
    static func quoted(_ text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("\""), t.hasSuffix("\""), t.count >= 2 { t = String(t.dropFirst().dropLast()) }
        return "\u{201C}" + t + "\u{201D}"
    }

    private struct PhaseBlock: View {
        let phase: TestimonyExchange.Phase
        let lines: [TestimonyExchange]
        let objections: [(after: Int, objection: Objection)]
        let binding: ((Objection) -> Binding<Bool?>)?
        @State var expanded: Bool

        init(phase: TestimonyExchange.Phase, lines: [TestimonyExchange], objections: [(after: Int, objection: Objection)] = [],
             binding: ((Objection) -> Binding<Bool?>)? = nil, expandedByDefault: Bool) {
            self.phase = phase
            self.lines = lines
            self.objections = objections
            self.binding = binding
            _expanded = State(initialValue: expandedByDefault)
        }

        @ViewBuilder
        private func objectionsAfter(_ index: Int) -> some View {
            ForEach(objections.filter { $0.after == index }.map(\.objection)) { objection in
                if let binding {
                    ObjectionView(objection: objection, selection: binding(objection))
                }
            }
        }

        var body: some View {
            DisclosureGroup(isExpanded: $expanded) {
                VStack(alignment: .leading, spacing: 8) {
                    objectionsAfter(-1)
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        VStack(alignment: .leading, spacing: 3) {
                            if !line.question.isEmpty {
                                Text(line.examiner == .prosecution ? "State" : "Defense")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Theme.color(for: line.examiner))
                                Text(line.question)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.quoteText)
                            }
                            Text(line.question.isEmpty ? line.answer : ExaminationTranscript.quoted(line.answer))
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(Theme.text)
                                .italic(line.question.isEmpty)
                        }
                        .padding(.vertical, 2)
                        objectionsAfter(index)
                    }
                }
                .padding(.top, 6)
            } label: {
                Text("\(phase.rawValue) · \(lines.count) question\(lines.count == 1 ? "" : "s")"
                     + (objections.isEmpty ? "" : " · \(objections.count) objection\(objections.count == 1 ? "" : "s")"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .tint(.secondary)
        }
    }
}
