import SwiftUI

// MARK: - Verdict

struct VerdictStage: View {
    @ObservedObject var session: CaseSession
    @State private var confirm = false
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Deliberation", systemImage: "scalemass.fill").font(.headline)
                Text("As fact-finder, consider only the evidence admitted at trial. Disregard anything suppressed or stricken. The State must prove each element beyond a reasonable doubt.")
                    .font(.callout)
                HStack {
                    LawLink(lawID: "burdenOfProof")
                    if c.charges.contains(where: { $0.lesserLawID != nil }) {
                        LawLink(lawID: "lesserIncluded")
                    }
                }
            }
            .card(tint: Theme.gold)

            SectionTitle(text: "The record", icon: "tray.full.fill")
            RecordReview(session: session)

            SectionTitle(text: "Verdict", icon: "checkmark.seal.fill")
            ForEach(c.charges) { charge in
                VerdictCard(charge: charge, allowed: session.verdictOptions(charge),
                            note: halftimeNote(charge),
                            lesserOptions: session.lesserOptions(charge),
                            onChooseLesser: { session.chooseLesser(charge, lawID: $0) },
                            selection: session.verdictBinding(charge))
            }

            PrimaryButton(title: "Announce Verdict", icon: "hammer.fill", enabled: session.verdictsComplete,
                          hint: "Choose a verdict for every count.") {
                confirm = true
            }
        }
        .confirmationDialog("Announce the verdict in open court?", isPresented: $confirm, titleVisibility: .visible) {
            Button("Announce") {
                Haptics.gavel()
                session.advance()
            }
            Button("Continue deliberating", role: .cancel) {}
        }
    }
}

extension VerdictStage {
    func halftimeNote(_ charge: Charge) -> String? {
        switch session.rulings.halftime[charge.id] {
        case .dismiss?: return "You dismissed this count at the close of the State's evidence."
        case .lesserOnly?: return "You allowed this count to proceed only on the lesser offense."
        default: return nil
        }
    }
}

/// Everything the fact-finder may consider, with suppressed and stricken material marked.
struct RecordReview: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exhibits").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            ForEach(c.evidence) { item in
                let suppressed = session.isSuppressed(item)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Circle().fill(Theme.color(for: item.side)).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(item.exhibit): \(item.title)").font(.callout).strikethrough(suppressed)
                        if suppressed {
                            Text("Suppressed. Disregard.").font(.caption2.weight(.bold)).foregroundStyle(.orange)
                        }
                    }
                }
                .opacity(suppressed ? 0.6 : 1)
            }
            Divider()
            Text("Testimony").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            ForEach(witnesses) { witness in
                CollapsibleSection(title: witness.name, icon: witness.isDefendant == true ? "person.fill.questionmark" : "person.fill",
                                   summary: witness.role, expanded: false) {
                    ExaminationTranscript(witness: witness, suppressed: session.suppressedTerms)
                    ForEach(c.objections(for: witness)) { objection in
                        let sustained = session.rulings.objections[objection.id] == true
                        VStack(alignment: .leading, spacing: 2) {
                            Text(objection.answer).font(.system(.caption, design: .serif)).strikethrough(sustained)
                            Text(sustained ? "Objection sustained (\(objection.grounds.lowercased())). Stricken." : "Admitted over objection (\(objection.grounds.lowercased())).")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(sustained ? .orange : .secondary)
                        }
                    }
                }
            }
            if session.rulings.defendantTestifies == false {
                Text("The defendant did not testify. No inference may be drawn from that choice.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    private var witnesses: [Witness] {
        var list = c.witnesses
        if session.rulings.defendantTestifies == true, let testimony = c.defendantTestimony { list.append(testimony) }
        return list
    }
}

struct VerdictCard: View {
    let charge: Charge
    var allowed: [Verdict] = [.guilty, .lesser, .notGuilty]
    var note: String? = nil
    var lesserOptions: [Law] = []
    var onChooseLesser: (String) -> Void = { _ in }
    @Binding var selection: Verdict?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Count \(charge.count): \(charge.law.title)").font(.headline)
            Text(charge.specification).font(.callout).foregroundStyle(.secondary)
            if let note {
                Label(note, systemImage: "info.circle").font(.caption).foregroundStyle(.orange)
            }
            if allowed.contains(.guilty) {
                option(.guilty, "Guilty", charge.law.ncClass?.label ?? "As charged")
            }
            if allowed.contains(.lesser), let lesser = charge.lesserLaw ?? lesserOptions.first {
                option(.lesser, "Guilty of a lesser-included offense", "\(lesser.title) · \(lesser.ncClass?.label ?? "")")
                if selection == .lesser && lesserOptions.count > 1 {
                    Menu {
                        ForEach(lesserOptions) { law in
                            Button {
                                Haptics.tap()
                                onChooseLesser(law.id)
                            } label: {
                                if law.id == lesser.id {
                                    Label("\(law.title) (\(law.ncClass?.label ?? ""))", systemImage: "checkmark")
                                } else {
                                    Text("\(law.title) (\(law.ncClass?.label ?? ""))")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lesser offense").font(.caption).foregroundStyle(Theme.secondaryText)
                                Text(lesser.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                            }
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down").foregroundStyle(Theme.gold)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.gold, lineWidth: 1))
                    }
                    LawLink(lawID: lesser.id)
                }
            }
            if allowed.contains(.notGuilty) {
                option(.notGuilty, "Not Guilty", "As fact-finder, you aren't convinced beyond a reasonable doubt")
            }
            if allowed.contains(.dismissed) {
                option(.dismissed, allowed == [.dismissed] ? "Dismissed at the close of the State's evidence" : "Dismiss",
                       "The evidence is insufficient as a matter of law (G.S. 15A-1227)")
            }
            if allowed.contains(.insanity) {
                option(.insanity, "Not Guilty by Reason of Insanity", "G.S. 15A-1237 · the defendant is committed for treatment")
            }
        }
        .card(tint: selection == nil ? nil : Theme.gold)
    }

    private func option(_ verdict: Verdict, _ title: String, _ subtitle: String) -> some View {
        let isSelected = selection == verdict
        return Button {
            Haptics.tap()
            withAnimation(.snappy) { selection = verdict }
        } label: {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? Theme.gold : .secondary)
                VStack(alignment: .leading) {
                    Text(title).font(.subheadline.weight(.bold))
                    if !subtitle.isEmpty {
                        Text(subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? Theme.gold.opacity(0.15) : Theme.raised))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sentencing

struct SentencingStage: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        let record = session.priorRecord
        let units = session.units
        let issues = session.legalIssues
        VStack(alignment: .leading, spacing: 16) {
            IncidentCards(session: session, moment: .sentencing)
            Text(session.rulings.pleaAccepted == true
                 ? "You accepted the plea. The sentence is up to you."
                 : "The sentence is up to you. The chart and counsel's recommendations are guidance, not limits.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if c.court == .misdemeanorAppeal, let prior = c.background?.districtCourtSentence {
                Label("The district court imposed \(prior). Its judgment was vacated by the appeal; you sentence fresh.", systemImage: "arrow.up.forward.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            StepHeader(number: 1, title: "Hear from the parties", detail: "The victim's statement and the defendant's words to the court.")
            CollapsibleSection(title: "Victim & defendant", icon: "person.2.fill",
                               summary: "Victim impact statement and allocution", expanded: true) {
                if let impact = c.victimImpact {
                    Text("Victim impact").font(.caption.weight(.bold)).foregroundStyle(Theme.prosecution)
                    Text(impact).font(.system(.callout, design: .serif)).italic()
                }
                Text("The defendant addresses the court").font(.caption.weight(.bold)).foregroundStyle(Theme.defense)
                Text(c.allocution(afterPlea: session.rulings.pleaAccepted == true, pleaKind: session.rulings.pleaKind)).font(.system(.callout, design: .serif)).italic()
            }

            StepHeader(number: 2, title: "Record & factors", detail: "Prior record level and any aggravating or mitigating factors you find.")
            if session.needsHabitualDecision {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Habitual felon status", systemImage: "exclamationmark.triangle.fill").font(.headline)
                    Text("The State offers certified judgments of these prior felony convictions. If you find the status proven, the defendant is sentenced four classes higher (up to Class C).")
                        .font(.callout)
                    ForEach(record.priorFelonies) { prior in
                        PriorRow(prior: prior)
                    }
                    RulingPicker(first: "Proven", second: "Not proven",
                                 firstDetail: "Sentence as a habitual felon", secondDetail: "Sentence normally",
                                 selection: Binding(get: { session.rulings.habitualFound },
                                                    set: { if let value = $0 { session.setHabitual(value) } }))
                    LawLink(lawID: "habitualFelon")
                }
                .card(tint: .orange)
            }

            CollapsibleSection(title: "Prior record", icon: "list.number",
                               summary: "Felony level \(SentenceFormat.romanLevels[record.felonyLevel - 1]) (\(record.points) pts) · Misdemeanor level \(SentenceFormat.romanLevels[record.misdemeanorLevel - 1])",
                               expanded: c.background?.disputedPriorID != nil) {
                PriorRecordCard(record: record, carded: false)
                PriorRecordRulings(session: session)
            }

            if units.contains(where: { $0.isFelony }) {
            CollapsibleSection(title: "Findings of factors", icon: "list.bullet.clipboard.fill",
                               summary: "\(session.rulings.foundAggravating.count) aggravating, \(session.rulings.foundMitigating.count) mitigating found") {
                Text("Turn on each factor you find. Under the statute, findings support the aggravated or mitigated range, but you can sentence however you choose.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Aggravating (offered by the State)").font(.caption.weight(.bold)).foregroundStyle(Theme.prosecution)
                ForEach(session.aggravatingFactors, id: \.self) { factor in
                    Toggle(factor, isOn: session.factorBinding(factor, aggravating: true)).font(.callout)
                }
                Divider()
                Text("Mitigating (offered by the defense)").font(.caption.weight(.bold)).foregroundStyle(Theme.defense)
                ForEach(session.mitigatingFactors, id: \.self) { factor in
                    Toggle(factor, isOn: session.factorBinding(factor, aggravating: false)).font(.callout)
                }
                LawLink(lawID: "aggravatingFactors")
            }
            }

            StepHeader(number: 3, title: "The sentence",
                       detail: units.count > 1 ? "One sentence per judgment. Choose a term and a disposition for each." : "Choose a term and a disposition.")
            CollapsibleSection(title: "Form of judgment", icon: "doc.badge.gearshape.fill",
                               summary: session.rulings.special.label, expanded: false) {
                // Only the forms of judgment the law allows for these convictions.
                ForEach(SpecialDisposition.allCases.filter { option in
                    switch option {
                    case .prayerForJudgment: return session.pjcAvailable
                    case .conditionalDischarge: return session.conditionalDischargeAvailable
                    case .none: return true
                    }
                }, id: \.self) { option in
                    ChoiceRow(title: option.label, subtitle: formNote(option), selected: session.rulings.special == option) {
                        session.rulings.special = option
                    }
                }
                if session.rulings.special == .conditionalDischarge {
                    AmountStepper(title: "Probation: \(session.rulings.dischargeMonths ?? 12) months",
                                  caption: "Typical: 12 months. Charges are dismissed when probation is completed.",
                                  value: Binding(get: { session.rulings.dischargeMonths ?? 12 },
                                                 set: { session.rulings.dischargeMonths = $0 }),
                                  range: 1...60, fine: 1, coarse: 6, fineLabel: "± 1 month", coarseLabel: "± 6 months")
                }
                HStack {
                    LawLink(lawID: "pjc")
                    LawLink(lawID: "conditionalDischarge")
                }
            }

            if session.rulings.special == .none && !(session.needsHabitualDecision && session.rulings.habitualFound == nil) {
                if convictionCount > 1 {
                    CollapsibleSection(title: "Multiple convictions", icon: "square.stack.3d.up.fill",
                                       summary: session.rulings.mode.label, expanded: false) {
                        ForEach(JudgmentMode.allCases, id: \.self) { mode in
                            ChoiceRow(title: mode.label, selected: session.rulings.mode == mode) {
                                session.setMode(mode)
                            }
                        }
                        if session.rulings.mode == .grouped {
                            Text("Put counts in the same judgment to consolidate them; each judgment is sentenced on its most serious count.")
                                .font(.caption).foregroundStyle(.secondary)
                            ForEach(convictedCharges) { charge in
                                HStack {
                                    Text("Count \(charge.count): \(charge.law.title)").font(.callout).lineLimit(2)
                                    Spacer()
                                    Picker("Judgment", selection: session.groupBinding(charge)) {
                                        ForEach(1...max(1, convictionCount), id: \.self) { number in
                                            Text("Judgment \(number)").tag(number)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            let groupUnits = session.units
                            if groupUnits.count > 1 {
                                Divider()
                                Text("How the judgments run").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                                ForEach(Array(groupUnits.enumerated()).dropFirst(), id: \.element.id) { index, unit in
                                    Toggle(isOn: session.unitConsecutiveBinding(unit, index: index)) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Judgment \(index + 1): \(unit.counts.count == 1 ? "Count" : "Counts") \(unit.counts.map(String.init).joined(separator: ", "))")
                                                .font(.callout.weight(.semibold))
                                            Text(session.rulings.consecutive(unit.id, index: index)
                                                 ? "Begins when Judgment \(index) ends (consecutive)"
                                                 : "Runs at the same time as the others (concurrent)")
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        LawLink(lawID: "consolidation")
                    }

                    CollapsibleSection(title: "Bench conference", icon: "person.2.wave.2.fill",
                                       summary: session.rulings.arrestedCounts.isEmpty ? "Hear both sides before judgment"
                                           : "Judgment arrested on \(session.rulings.arrestedCounts.count) count\(session.rulings.arrestedCounts.count == 1 ? "" : "s")",
                                       expanded: false) {
                        ForEach(BenchConference.transcript(c, session.rulings)) { line in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(line.speaker).font(.caption.weight(.bold))
                                    .foregroundStyle(line.side == .prosecution ? Theme.prosecution : (line.side == .defense ? Theme.defense : .secondary))
                                Text(line.text).font(.callout)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                        Text("Arrest judgment on a count").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                        // The lead count carries the judgment; only the others can be arrested.
                        let lead = BenchConference.convictedCharges(c, session.rulings).first?.id
                        ForEach(convictedCharges.filter { $0.id != lead }) { charge in
                            let arrested = session.rulings.arrestedCounts.contains(charge.id)
                            let consents = BenchConference.stateConsents(c, session.rulings, charge: charge)
                            let merges = BenchConference.merges(c, session.rulings, charge: charge)
                            ChoiceRow(title: (arrested ? "Judgment arrested: " : "Arrest judgment on ") + "Count \(charge.count)",
                                      subtitle: consents ? "The State consents."
                                        : (merges ? "The State objects, but this count merges with the lead count; arresting judgment is proper."
                                                  : "The State objects; arresting judgment here would be appealable."),
                                      selected: arrested) {
                                session.toggleArrest(charge)
                            }
                        }
                    }
                }

                ForEach(units) { unit in
                    UnitSentenceCard(unit: unit,
                                     aggravatingFound: !session.rulings.foundAggravating.isEmpty,
                                     mitigatingFound: !session.rulings.foundMitigating.isEmpty,
                                     choice: session.choiceBinding(for: unit),
                                     sentenceDate: c.sessionDate,
                                     creditDays: c.background?.custodyDays ?? 0)
                }

                if session.anyActive {
                    ActiveOrdersCard(session: session)
                }
            }

            StepHeader(number: 4, title: "Conditions & money", detail: "Optional. Probation conditions, orders of your own, fines, costs, and restitution.")
            if session.anySuspended && session.rulings.special != .prayerForJudgment {
                ProbationConditionsCard(session: session)
            }

            CustomConditionsCard(session: session)

            if session.courtCase.victimName != nil && !Consequences.victimDied(session.courtCase) && !Consequences.victimIsChild(session.courtCase) {
                StayAwayOrderCard(session: session)
            }

            MoneyCard(session: session)

            StepHeader(number: 5, title: "Enter judgment")
            if session.sentencingComplete {
                JudgmentSummaryCard(session: session)
            }

            if !issues.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Departures from North Carolina law", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text("You can enter this judgment as is. Expect it to be appealed, and possibly vacated.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    BulletList(items: issues, symbol: "circle.fill", color: .orange)
                        .font(.caption)
                }
                .card(tint: .orange)
            }

            PrimaryButton(title: "Enter Judgment", icon: "hammer.fill", enabled: session.sentencingComplete,
                          hint: session.sentencingHint) {
                Haptics.gavel()
                session.advance()
            }
        }
        .tint(Theme.gold)
        .confirmationDialog("This sentence departs from the plea arrangement",
                            isPresented: Binding(get: { session.pendingPleaDeparture != nil },
                                                 set: { if !$0 { session.pendingPleaDeparture = nil } }),
                            titleVisibility: .visible) {
            Button("Tell the defendant and offer withdrawal") { session.informDefendantOfDeparture() }
            Button("Enter it without telling them", role: .destructive) { session.enterDepartureWithoutNotice() }
            Button("Go back and reconsider", role: .cancel) { session.pendingPleaDeparture = nil }
        } message: {
            Text((session.pendingPleaDeparture ?? "") + " Under G.S. 15A-1024, the court must tell the defendant and allow the plea to be withdrawn.")
        }
    }

    private var convictionCount: Int {
        c.charges.filter { session.rulings.verdicts[$0.id]?.isConviction == true }.count
    }

    private var convictedCharges: [Charge] {
        c.charges.filter { session.rulings.verdicts[$0.id]?.isConviction == true }
    }


    private func formNote(_ option: SpecialDisposition) -> String {
        switch option {
        case .none: return option.detail
        case .prayerForJudgment:
            let barred: [NCClass] = [.A, .B1, .B2, .C, .D, .E]
            return option.detail + (session.units.contains { barred.contains($0.offenseClass) } ? " Not allowed for Class A–E felonies (G.S. 15A-1331.2)." : "")
        case .conditionalDischarge:
            switch Judgment.dischargeBasis(c, session.rulings) {
            case .drugPossession: return option.detail + " Eligible under G.S. 90-96."
            case .jointMotion:
                return option.detail + (c.background?.stateJoinsDischarge == false
                    ? " Requires a joint motion under G.S. 15A-1341(a4); the State has not joined."
                    : " The State joins a motion under G.S. 15A-1341(a4).")
            case .ineligible: return option.detail + " The defendant doesn't meet the statutory eligibility requirements."
            }
        }
    }
}

struct PriorRecordCard: View {
    let record: PriorRecord
    var carded = true

    var body: some View {
        let content = VStack(alignment: .leading, spacing: 8) {
            if record.lines.isEmpty {
                Text("No prior convictions.").font(.callout).foregroundStyle(.secondary)
            }
            ForEach(Array(record.lines.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .firstTextBaseline) {
                    Text(line.text).font(.caption)
                    Spacer()
                    Text("\(line.points)").font(.caption.monospacedDigit().weight(.bold))
                }
            }
            Divider()
            HStack {
                Text("Felony prior record level").font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(record.points) pts · Level \(SentenceFormat.romanLevels[record.felonyLevel - 1])")
                    .font(.subheadline.monospacedDigit())
            }
            HStack {
                Text("Misdemeanor prior conviction level").font(.subheadline.weight(.semibold))
                Spacer()
                Text("Level \(SentenceFormat.romanLevels[record.misdemeanorLevel - 1])")
                    .font(.subheadline.monospacedDigit())
            }
            LawLink(lawID: "priorRecord")
        }
        if carded {
            content.card()
        } else {
            content
        }
    }
}

struct ConditionToggle: View {
    let title: String
    var detail: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                if let detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// Adjusts a number with a fine stepper and a coarse stepper.
/// A dollar amount the judge types in.
struct DollarField: View {
    let title: String
    var caption: String? = nil
    @Binding var value: Int
    var limit = 100_000_000
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            if let caption {
                Text(caption).font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                Text("$").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                TextField("0", value: Binding(get: { value }, set: { value = min(limit, max(0, $0)) }),
                          format: .number.grouping(.automatic))
                    .keyboardType(.numberPad)
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .focused($focused)
                if focused {
                    Button("Done") { focused = false }
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised))
        }
    }
}

struct AmountStepper: View {
    let title: String
    var caption: String? = nil
    @Binding var value: Int
    let range: ClosedRange<Int>
    let fine: Int
    let coarse: Int
    let fineLabel: String
    let coarseLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold))
            if let caption {
                Text(caption).font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Stepper(fineLabel, value: $value, in: range, step: fine).font(.caption)
            }
            if coarse > fine {
                Stepper(coarseLabel, value: $value, in: range, step: coarse).font(.caption)
            }
        }
    }
}

struct ProbationConditionsCard: View {
    @ObservedObject var session: CaseSession

    var body: some View {
        CollapsibleSection(title: "Conditions of probation", icon: "checklist",
                           summary: "\(session.rulings.conditions.supervised ? "Supervised" : "Unsupervised"), \(session.rulings.conditions.specialCount) special conditions",
                           expanded: false) {
            Text("Regular conditions always apply: commit no new offense, remain in the jurisdiction, possess no firearm, and pay money owed. Every condition you add is another way to violate. Conditions that address the defendant's real problems make success more likely.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ConditionToggle(title: "Supervised probation",
                            detail: "A probation officer, office visits, and warrantless searches. Off means unsupervised.",
                            isOn: $session.rulings.conditions.supervised)

            Text("Jail and confinement").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            AmountStepper(title: "Special probation: \(session.rulings.conditions.specialProbationDays) day\(session.rulings.conditions.specialProbationDays == 1 ? "" : "s") in jail",
                          caption: session.anyIntermediate
                            ? "A split sentence served before or during probation. The statute caps it at one-fourth of the maximum (\(session.maxSpecialProbationDays) day\(session.maxSpecialProbationDays == 1 ? "" : "s") here)."
                            : "An intermediate condition. With only community punishment chosen, ordering it departs from the statute.",
                          value: $session.rulings.conditions.specialProbationDays, range: 0...3_650,
                          fine: 1, coarse: 30, fineLabel: "± 1 day", coarseLabel: "± 30 days")
            AmountStepper(title: "House arrest with electronic monitoring: \(session.rulings.conditions.houseArrestDays) day\(session.rulings.conditions.houseArrestDays == 1 ? "" : "s")",
                          value: $session.rulings.conditions.houseArrestDays, range: 0...3_650,
                          fine: 1, coarse: 30, fineLabel: "± 1 day", coarseLabel: "± 30 days")
            ConditionToggle(title: "Drug Treatment Court", detail: "Intensive court-supervised treatment with frequent review hearings. An intermediate condition.",
                            isOn: $session.rulings.conditions.drugTreatmentCourt)
            if TreatmentCourts.isVeteran(session.courtCase.defendant.background) {
                ConditionToggle(title: "Veterans Treatment Court",
                                detail: "Court-supervised treatment through the VA, with a fellow veteran as mentor. For defendants who served.",
                                isOn: Binding(get: { session.rulings.conditions.veteransTreatmentCourt == true },
                                              set: { session.rulings.conditions.veteransTreatmentCourt = $0 }))
            }
            ConditionToggle(title: "Curfew, 9 p.m. to 6 a.m.", isOn: $session.rulings.conditions.curfew)

            Divider()
            Text("Treatment and service").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            AmountStepper(title: "Community service: \(session.rulings.conditions.communityServiceHours) hours",
                          caption: "Adds the $250 community service fee",
                          value: $session.rulings.conditions.communityServiceHours, range: 0...5_000,
                          fine: 10, coarse: 100, fineLabel: "± 10 hours", coarseLabel: "± 100 hours")
            ConditionToggle(title: "Substance abuse assessment and treatment (TASC)", isOn: $session.rulings.conditions.substanceTreatment)
            ConditionToggle(title: "Mental health evaluation and treatment", isOn: $session.rulings.conditions.mentalHealthTreatment)
            ConditionToggle(title: "Random drug and alcohol testing", isOn: $session.rulings.conditions.randomTesting)
            ConditionToggle(title: "Abstain from alcohol", isOn: $session.rulings.conditions.abstainAlcohol)
            ConditionToggle(title: "Anger management or abuser treatment", isOn: $session.rulings.conditions.angerManagement)

            Divider()
            Text("Restrictions and obligations").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            if session.courtCase.victimName != nil {
                ConditionToggle(title: "No contact with the victim or their family", isOn: $session.rulings.conditions.noContactVictim)
            }
            ConditionToggle(title: "Stay away from the scene of the offense", isOn: $session.rulings.conditions.stayAway)
            ConditionToggle(title: "Surrender all firearms", isOn: $session.rulings.conditions.surrenderFirearms)
            ConditionToggle(title: "Maintain employment or full-time school", isOn: $session.rulings.conditions.maintainEmployment)
            ConditionToggle(title: "Obtain a high school equivalency diploma", isOn: $session.rulings.conditions.education)

            HStack {
                LawLink(lawID: "probationConditions")
                LawLink(lawID: "specialProbation")
            }
        }
    }
}

/// An order, entered with the judgment, that the defendant have no contact with the victim and stay away from their
/// home, work, and school. Whoever it binds may still break it.
struct StayAwayOrderCard: View {
    @ObservedObject var session: CaseSession

    var body: some View {
        let c = session.courtCase
        let victim = c.victimName ?? "the victim"
        let years = session.rulings.stayAwayYears
        let wanted = Consequences.stateWantsOrder(c)
        CollapsibleSection(title: "Stay-away order", icon: "hand.raised.fill",
                           summary: years > 0 ? "Protecting \(victim) for \(years) year\(years == 1 ? "" : "s")"
                            : (wanted ? "The State asks for one" : "None entered"),
                           expanded: wanted) {
            if wanted {
                Label("The State asks the court to order \(c.defendant.lastName) to stay away from \(victim).", systemImage: "exclamationmark.bubble.fill")
                    .font(.callout)
                    .foregroundStyle(Theme.prosecution)
            }
            Text("No contact with \(victim), directly or through anyone else, and stay away from \(victim)'s home, work, and school. A violation is a new crime that comes back to this court.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Length", selection: $session.rulings.stayAwayYears) {
                Text("None").tag(0)
                Text("1 yr").tag(1)
                Text("2 yrs").tag(2)
                Text("5 yrs").tag(5)
                Text("10 yrs").tag(10)
            }
            .pickerStyle(.segmented)
            if years == 0 && session.rulings.conditions.noContactVictim {
                Text("The no-contact condition of probation protects \(victim) while probation lasts.").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct CustomConditionsCard: View {
    @ObservedObject var session: CaseSession
    @State private var draft = ""

    private let ideas = [
        "Write a letter of apology to the victim",
        "Attend a victim impact panel",
        "Complete a parenting class",
        "No social media use during probation",
        "Pay restitution at $100 per month",
        "Volunteer at the county animal shelter"
    ]

    var body: some View {
        CollapsibleSection(title: "Your own orders", icon: "pencil.and.list.clipboard",
                           summary: session.rulings.customConditions.isEmpty ? "None added" : "\(session.rulings.customConditions.count) added",
                           expanded: !session.rulings.customConditions.isEmpty) {
            Text("Add anything you want the judgment to order. It becomes part of the judgment exactly as you write it.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                TextField("Type an order or condition", text: $draft, axis: .vertical)
                    .lineLimit(1...3)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised))
                Button {
                    session.addCustomCondition(draft)
                    draft = ""
                } label: {
                    Image(systemName: "plus.circle.fill").font(.title2)
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ideas, id: \.self) { idea in
                        Button(idea) { session.addCustomCondition(idea) }
                            .font(.caption)
                            .buttonStyle(.bordered)
                    }
                }
            }
            ForEach(Array(session.rulings.customConditions.enumerated()), id: \.offset) { index, condition in
                HStack(alignment: .top) {
                    Image(systemName: "text.badge.checkmark").foregroundStyle(Theme.gold)
                    Text(condition).font(.callout)
                    Spacer()
                    Button {
                        session.removeCustomCondition(at: index)
                    } label: {
                        Image(systemName: "trash").foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ActiveOrdersCard: View {
    @ObservedObject var session: CaseSession

    var body: some View {
        let custodyDays = session.courtCase.background?.custodyDays ?? 0
        let objects = session.courtCase.background?.stateObjectsToASR ?? true
        CollapsibleSection(title: "Commitment & recommendations", icon: "lock.fill",
                           summary: custodyDays > 0 ? "\(custodyDays) day\(custodyDays == 1 ? "" : "s") of credit for time served" : "No pretrial credit", expanded: false) {
            Label(custodyDays > 0
                  ? "Credit for \(custodyDays) day\(custodyDays == 1 ? "" : "s") of pretrial confinement will be applied (G.S. 15-196.1)."
                  : "No pretrial confinement credit: the defendant was out on bond.",
                  systemImage: "calendar.badge.clock")
                .font(.subheadline)

            if session.asrEligible {
                ConditionToggle(title: "Advanced Supervised Release (ASR)",
                                detail: (session.askedAboutASR
                                    ? (objects ? "The State objected on the record. Ordering ASR anyway departs from the statute." : "The State does not object.")
                                    : "Early release after risk-reduction programs. The statute requires that the State not object; ask the prosecutor.")
                                    + " Your choice: if ordered, the defendant can be released before the minimum term.",
                                isOn: $session.rulings.recommendations.advancedSupervisedRelease)
            }
            ConditionToggle(title: "Recommend substance abuse treatment in custody", isOn: $session.rulings.recommendations.substanceTreatment)
            ConditionToggle(title: "Recommend mental health treatment in custody", isOn: $session.rulings.recommendations.mentalHealth)
            ConditionToggle(title: "Recommend work release", isOn: $session.rulings.recommendations.workRelease)
            ConditionToggle(title: "Recommend vocational and educational programs", isOn: $session.rulings.recommendations.vocational)
            Text("Recommendations don't bind the Department of Adult Correction.")
                .font(.caption)
                .foregroundStyle(.secondary)
            LawLink(lawID: "asr")
        }
    }
}

struct MoneyCard: View {
    @ObservedObject var session: CaseSession

    var body: some View {
        let bg = session.courtCase.background
        let items = session.obligations
        let total = items.reduce(0) { $0 + $1.amount }
        CollapsibleSection(title: "Fines, costs & restitution", icon: "dollarsign.circle.fill",
                           summary: total > 0 ? "Total \(SentenceFormat.dollars(total))"
                            : ((bg?.restitution ?? 0) > 0 ? "The State requests \(SentenceFormat.dollars(bg?.restitution ?? 0)) in restitution" : "Nothing owed"),
                           expanded: (bg?.restitution ?? 0) > 0) {
            DollarField(title: "Fine", caption: fineNote, value: $session.rulings.money.fine, limit: 10_000_000)
            DollarField(title: "Restitution",
                        caption: bg.map { $0.restitution > 0 ? "State's figure: \(SentenceFormat.dollars($0.restitution)) for \($0.restitutionBasis ?? "losses")" : "The State hasn't requested restitution" },
                        value: $session.rulings.money.restitution)
            ConditionToggle(title: "Tax court costs", detail: "About \(SentenceFormat.dollars(FinancialOrders.courtCosts)). Off remits costs.",
                            isOn: $session.rulings.money.courtCosts)
            if Judgment.appointedCounsel(session.courtCase) {
                ConditionToggle(title: "Judgment for appointed attorney fees",
                                detail: "About \(SentenceFormat.dollars(bg?.attorneyFeeEstimate ?? 1_500)) for court-appointed counsel",
                                isOn: $session.rulings.money.attorneyFees)
            }
            if session.anySuspended && session.rulings.conditions.supervised {
                ConditionToggle(title: "Waive the $40/month supervision fee", isOn: $session.rulings.money.waiveSupervisionFees)
            }
            if !items.isEmpty {
                Divider()
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack {
                        Text(item.label).font(.caption)
                        Spacer()
                        Text(SentenceFormat.dollars(item.amount)).font(.caption.monospacedDigit())
                    }
                }
                HStack {
                    Text("Total").font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(SentenceFormat.dollars(total)).font(.subheadline.monospacedDigit().weight(.semibold))
                }
            }
            if bg?.indigent ?? false {
                Label("Defense counsel says the defendant is indigent.", systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            LawLink(lawID: "monetaryObligations")
        }
    }

    private var fineNote: String {
        let caps = session.units.compactMap { $0.sentencingClass.maxFine }
        if let cap = caps.max(), !session.units.contains(where: { $0.isFelony }) {
            return "Statutory maximum for this class: \(SentenceFormat.dollars(cap))"
        }
        return "Amount in the court's discretion"
    }
}

struct ChoiceRow: View {
    let title: String
    var subtitle: String? = nil
    let selected: Bool
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            withAnimation(.snappy) { action() }
        } label: {
            HStack(alignment: .top) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? Theme.gold : .secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold)).multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                    }
                }
                Spacer()
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(selected ? Theme.gold.opacity(0.15) : Theme.raised))
            .opacity(enabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct UnitSentenceCard: View {
    let unit: SentencingUnit
    let aggravatingFound: Bool
    let mitigatingFound: Bool
    @Binding var choice: SentenceChoice
    var sentenceDate: Date? = nil
    var creditDays: Int = 0

    private enum Mode { case chart(SentenceRangeKind), custom, life }

    private var mode: Mode {
        if choice.lifeWithoutParole { return .life }
        if choice.customTerm { return .custom }
        return .chart(choice.range)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(unit.title).font(.headline)
            Text(unit.classLine).font(.caption).foregroundStyle(.secondary)
            if unit.isMandatoryLife {
                Label("The statute makes life without parole mandatory for a Class A felony. The choice below is still yours.",
                      systemImage: "info.circle")
                    .font(.caption)
            }

            Text("Term").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            if let cell = unit.felonyCell {
                ForEach(SentenceRangeKind.allCases, id: \.self) { kind in
                    if let range = cell.range(kind) {
                        ChoiceRow(title: "\(kind.label) range", subtitle: rangeSubtitle(kind, range), selected: isChart(kind)) {
                            choice.lifeWithoutParole = false
                            choice.customTerm = false
                            choice.range = kind
                            choice.minimum = min(max(choice.minimum, range.low), range.high)
                        }
                    }
                }
            } else if let cell = unit.misdemeanorCell {
                ChoiceRow(title: "Authorized range", subtitle: "1–\(cell.maxDays) day\(cell.maxDays == 1 ? "" : "s") for this class and level",
                          selected: isChart(.presumptive)) {
                    choice.lifeWithoutParole = false
                    choice.customTerm = false
                    choice.range = .presumptive
                    choice.minimum = min(max(choice.minimum, 1), cell.maxDays)
                }
            } else if unit.isDWI {
                // G.S. 20-179: the court weighs grossly aggravating, aggravating, and mitigating factors to set the level.
                ForEach(StructuredSentencing.dwiLevels.indices, id: \.self) { index in
                    let level = StructuredSentencing.dwiLevels[index]
                    ChoiceRow(title: level.label, subtitle: level.note,
                              selected: choice.dwiLevel == index && !choice.customTerm) {
                        choice.lifeWithoutParole = false
                        choice.customTerm = false
                        choice.dwiLevel = index
                        choice.minimum = min(max(choice.minimum, level.minDays), level.maxDays)
                    }
                }
            }
            ChoiceRow(title: "Set my own term", subtitle: "Any length, inside or outside the chart",
                      selected: isCustom) {
                choice.lifeWithoutParole = false
                choice.customTerm = true
            }
            if unit.sentencingClass == .A || unit.sentencingClass == .B1 {
                ChoiceRow(title: "Life imprisonment without parole", subtitle: lifeSubtitle, selected: choice.lifeWithoutParole) {
                    choice.lifeWithoutParole = true
                    choice.disposition = .active
                }
            } else if isCustom || choice.lifeWithoutParole {
                ConditionToggle(title: "Impose life without parole instead", detail: lifeSubtitle,
                                isOn: Binding(get: { choice.lifeWithoutParole },
                                              set: { on in
                                                  choice.lifeWithoutParole = on
                                                  choice.customTerm = true
                                                  if on { choice.disposition = .active }
                                              }))
            }

            if !choice.lifeWithoutParole {
                termEditor
                dispositionPicker
                releasePreview
            }
        }
        .card(tint: Judgment.isComplete(choice) ? Theme.gold : nil)
    }

    private var isCustom: Bool {
        if case .custom = mode { return true }
        return false
    }

    private var supervisionMonths: Int {
        StructuredSentencing.postReleaseMonths(for: unit.sentencingClass)
    }

    /// When this judgment, served alone, would let the defendant out.
    @ViewBuilder
    private var releasePreview: some View {
        if choice.disposition == .active, let start = sentenceDate {
            let cal = Calendar.current
            let creditBack: (Date) -> Date = { max(start, cal.date(byAdding: .day, value: -creditDays, to: $0) ?? $0) }
            let earliest = creditBack(unit.isFelony
                ? (cal.date(byAdding: .month, value: choice.minimum, to: start) ?? start)
                : (cal.date(byAdding: .day, value: choice.minimum, to: start) ?? start))
            let latest = creditBack(unit.isFelony
                ? (cal.date(byAdding: .month, value: max(choice.minimum, Judgment.maximum(for: unit, choice: choice) - supervisionMonths), to: start) ?? start)
                : (cal.date(byAdding: .day, value: choice.minimum, to: start) ?? start))
            VStack(alignment: .leading, spacing: 3) {
                Label("If served alone: earliest release \(SentenceFormat.shortDate(earliest))" + (unit.isFelony ? ", latest \(SentenceFormat.shortDate(latest))" : ""),
                      systemImage: "calendar.badge.clock")
                    .font(.caption.weight(.semibold))
                Text(unit.isFelony
                     ? "The defendant serves the full minimum before release; earned time can't shorten it. Release comes no later than the maximum less \(supervisionMonths) months of post-release supervision." + (creditDays > 0 ? " Includes \(creditDays) day\(creditDays == 1 ? "" : "s") of jail credit." : "")
                     : "Jail time is served day for day" + (creditDays > 0 ? ", less \(creditDays) day\(creditDays == 1 ? "" : "s") of jail credit." : "."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func isChart(_ kind: SentenceRangeKind) -> Bool {
        if case .chart(let selected) = mode { return selected == kind }
        return false
    }

    private func rangeSubtitle(_ kind: SentenceRangeKind, _ range: MonthRange) -> String {
        var text = "\(range.text) minimum"
        if kind == .aggravated && !aggravatingFound { text += " · no aggravating factor found yet" }
        if kind == .mitigated && !mitigatingFound { text += " · no mitigating factor found yet" }
        return text
    }

    private var lifeSubtitle: String {
        if unit.isMandatoryLife { return "Required by statute for Class A" }
        if unit.sentencingClass == .B1 && unit.level >= 5 { return "Authorized at this level if you find an aggravating factor" }
        return "Not authorized for this offense"
    }

    @ViewBuilder
    private var termEditor: some View {
        if unit.isFelony {
            let statutoryMax = StructuredSentencing.maximum(forMinimum: choice.minimum, cls: unit.sentencingClass)
            if isCustom || unit.felonyCell == nil {
                AmountStepper(title: "Minimum term: \(SentenceFormat.months(choice.minimum)) (\(choice.minimum) months)",
                              caption: "Time the defendant must serve before becoming eligible for release.",
                              value: $choice.minimum, range: 0...1_200,
                              fine: 1, coarse: 12, fineLabel: "± 1 month", coarseLabel: "± 1 year")
                ConditionToggle(title: "Use the statutory maximum (\(statutoryMax) months)",
                                isOn: Binding(get: { choice.customMaximum == nil },
                                              set: { choice.customMaximum = $0 ? nil : statutoryMax }))
                if let custom = choice.customMaximum {
                    AmountStepper(title: "Maximum: \(SentenceFormat.months(custom)) (\(custom) months)",
                                  value: Binding(get: { choice.customMaximum ?? statutoryMax },
                                                 set: { choice.customMaximum = max($0, choice.minimum) }),
                                  range: 0...1_200, fine: 1, coarse: 12, fineLabel: "± 1 month", coarseLabel: "± 1 year")
                }
            } else if let range = unit.felonyCell?.range(choice.range) {
                Stepper(value: $choice.minimum, in: range.low...range.high) {
                    VStack(alignment: .leading) {
                        Text("Minimum term: \(choice.minimum) months").font(.title3.weight(.bold))
                        Text("Must be served in full before release eligibility (\(SentenceFormat.months(choice.minimum))).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Maximum term: \(statutoryMax) months (\(SentenceFormat.months(statutoryMax))), set by statute; includes \(supervisionMonths) months of post-release supervision.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } else {
            let dwiCap = unit.isDWI ? choice.dwiLevel.flatMap { StructuredSentencing.dwiLevels.indices.contains($0) ? StructuredSentencing.dwiLevels[$0].maxDays : nil } : nil
            let cap = isCustom ? 3_650 : (dwiCap ?? unit.misdemeanorCell?.maxDays ?? 150)
            AmountStepper(title: choice.minimum == 0 ? "No jail time (fine only)" : "\(choice.minimum) day\(choice.minimum == 1 ? "" : "s")",
                          value: $choice.minimum, range: 0...cap,
                          fine: 1, coarse: 30, fineLabel: "± 1 day", coarseLabel: "± 30 days")
        }
    }

    @ViewBuilder
    private var dispositionPicker: some View {
        let allowed = unit.isDWI ? [Disposition.active, .intermediate, .community]
            : (unit.felonyCell?.dispositions ?? unit.misdemeanorCell?.dispositions ?? [.active])
        Text("Disposition").font(.caption.weight(.bold)).foregroundStyle(.secondary)
        ForEach(Disposition.allCases.reversed(), id: \.self) { disposition in
            ChoiceRow(title: disposition.label,
                      subtitle: disposition.detail + (allowed.contains(disposition) ? "" : " · Not authorized by the chart here"),
                      selected: choice.disposition == disposition) {
                choice.disposition = disposition
                let months = StructuredSentencing.probationMonths(felony: unit.isFelony, disposition: disposition)
                if choice.probationMonths < 1 { choice.probationMonths = months.lowerBound }
            }
        }
        if choice.disposition == .active && !choice.lifeWithoutParole {
            ConditionToggle(title: "Follow the active term with probation",
                            detail: "A split sentence: part of the term is served, the rest is suspended, and probation begins on release. Revocation can activate only the suspended balance.",
                            isOn: Binding(get: { choice.probationAfterActive == true },
                                          set: { choice.probationAfterActive = $0 }))
            if choice.probationAfterActive == true {
                let unitName = unit.isFelony ? "month" : "day"
                AmountStepper(title: "Serve before release: \(choice.servedTerm) of \(choice.minimum) \(unitName)s",
                              caption: choice.suspendedBalance > 0
                                ? "The other \(choice.suspendedBalance) \(unitName)s are suspended; a violation can send the defendant back to serve them."
                                : "The whole term is served before probation begins.",
                              value: Binding(get: { choice.servedTerm }, set: { choice.servedBeforeProbation = $0 }),
                              range: 0...max(0, choice.minimum),
                              fine: 1, coarse: unit.isFelony ? 6 : 30, fineLabel: unit.isFelony ? "± 1 month" : "± 1 day", coarseLabel: unit.isFelony ? "± 6 months" : "± 30 days")
                AmountStepper(title: "Probation after release: \(choice.probationMonths) months",
                              caption: "Any length you choose. Conditions are set in the probation section below.",
                              value: $choice.probationMonths, range: 1...240,
                              fine: 1, coarse: 12, fineLabel: "± 1 month", coarseLabel: "± 1 year")
            }
        }
        if let disposition = choice.disposition, disposition != .active {
            let typical = StructuredSentencing.probationMonths(felony: unit.isFelony, disposition: disposition)
            AmountStepper(title: "Probation: \(choice.probationMonths) months",
                          caption: "Typical: \(typical.lowerBound)–\(typical.upperBound) months. The statute caps probation at 5 years.",
                          value: $choice.probationMonths, range: 1...240,
                          fine: 1, coarse: 12, fineLabel: "± 1 month", coarseLabel: "± 1 year")
        }
    }
}

// MARK: - Probation violation

struct ProbationStage: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let probation = c.defendant.probation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Probation violation hearing").font(.headline)
                    Text("\(probation.docket): \(probation.offense)").font(.subheadline.weight(.semibold))
                    Text("Suspended sentence: \(probation.suspendedSentence). Probation set to end \(SentenceFormat.shortDate(probation.ends)).")
                        .font(.callout)
                    if probation.imposedInThisCourt {
                        Text("You imposed this sentence.").font(.caption).foregroundStyle(.purple)
                    }
                    Divider()
                    Text("Alleged violation: commission of a new criminal offense (\(c.docket)).").font(.callout)
                    Text(session.dismissedBySpeedyTrial
                         ? "You dismissed the new case on speedy-trial grounds. A violation may still be found only if you are reasonably satisfied that the new offense occurred."
                         : session.anyConviction
                         ? "You have just found the probationer guilty in the new case."
                         : "You have just acquitted the probationer in the new case. A violation still may be found if you are reasonably satisfied, in your discretion, that the new offense occurred.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    LawLink(lawID: "probationViolation")
                }
                .card(tint: .orange)

                ForEach(ProbationDecision.allCases, id: \.self) { decision in
                    ChoiceRow(title: decision.label,
                              subtitle: subtitle(for: decision, probation: probation),
                              selected: session.rulings.probationDecision == decision) {
                        session.rulings.probationDecision = decision
                    }
                }

                if session.rulings.probationDecision == .modify {
                    let extraMonths = session.rulings.extensionMonths ?? 12
                    AmountStepper(title: extraMonths == 0 ? "No extension" : "Extend probation \(extraMonths) month\(extraMonths == 1 ? "" : "s")",
                                  caption: "Probation now ends \(SentenceFormat.shortDate(probation.ends)). Total probation generally may not exceed 5 years (G.S. 15A-1342(a)).",
                                  value: Binding(get: { session.rulings.extensionMonths ?? 12 },
                                                 set: { session.rulings.extensionMonths = $0 }),
                                  range: 0...60, fine: 1, coarse: 6, fineLabel: "± 1 month", coarseLabel: "± 6 months")
                }

                if session.anyActive && [.revoke, .crv].contains(session.rulings.probationDecision) {
                    Toggle(isOn: $session.rulings.revocationConsecutive) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Run consecutively to today's sentence").font(.subheadline.weight(.semibold))
                            Text("Off: the time runs at the same time as today's active sentence (the default under G.S. 15A-1344(d)).")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .card()
                }
            }

            if let prs = c.defendant.postRelease {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Post-release supervision violation").font(.headline)
                    Text("\(prs.docket): \(prs.offense)").font(.subheadline.weight(.semibold))
                    Text("Released from prison onto \(prs.supervisionMonths) months of post-release supervision, ending \(SentenceFormat.shortDate(prs.ends)). Unserved maximum term: \(prs.remainingMonths) months.")
                        .font(.callout)
                    Divider()
                    Text("Alleged violation: commission of a new criminal offense (\(c.docket)).").font(.callout)
                    Text("In North Carolina this decision normally belongs to the Post-Release Supervision and Parole Commission; in Hollis County the court hears it with the new charge.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .card(tint: .orange)

                ForEach(PostReleaseDecision.allCases, id: \.self) { decision in
                    ChoiceRow(title: decision.label,
                              subtitle: postReleaseSubtitle(decision, prs),
                              selected: session.rulings.postReleaseDecision == decision) {
                        session.rulings.postReleaseDecision = decision
                    }
                }

                if session.anyActive && [.revoke, .confine].contains(session.rulings.postReleaseDecision) && c.defendant.probation == nil {
                    Toggle(isOn: $session.rulings.revocationConsecutive) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Run consecutively to today's sentence").font(.subheadline.weight(.semibold))
                            Text("Off: the time runs at the same time as today's active sentence.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .card()
                }
            }

            PrimaryButton(title: "Enter Order", icon: "hammer.fill",
                          enabled: (session.rulings.probationDecision != nil || c.defendant.probation == nil)
                            && (session.rulings.postReleaseDecision != nil || c.defendant.postRelease == nil),
                          hint: "Decide the supervision violation.") {
                Haptics.gavel()
                session.advance()
            }
        }
    }

    private func postReleaseSubtitle(_ decision: PostReleaseDecision, _ prs: PostReleaseTerm) -> String? {
        switch decision {
        case .revoke: return "Serves the remaining \(prs.remainingMonths) months of the maximum term in prison. No further supervision on that sentence."
        case .confine: return "\(min(3, prs.remainingMonths)) months in custody, then back on supervision."
        case .continueAsIs: return "No additional time on the old sentence."
        }
    }

    private func subtitle(for decision: ProbationDecision, probation: ProbationTerm) -> String? {
        let credit = (probation.crvCount ?? 0) * 3
        switch decision {
        case .revoke:
            return "Activates \(probation.suspendedSentence)" + (credit > 0 ? ", less \(credit) months already served on CRV" : "")
        case .crv:
            return probation.isFelony ? "90 days for a felony probationer" : "Up to 90 days, or the rest of the suspended sentence if less"
        default:
            return nil
        }
    }
}

// MARK: - Judgment

struct JudgmentStage: View {
    let courtCase: CourtCase
    let outcome: CaseOutcome
    /// Called with the witnesses the judge sends to the district attorney for perjury.
    let onFinish: ([Witness]) -> Void
    @State private var referred: Set<UUID> = []

    /// Everyone who testified, other than the defendant.
    private var witnesses: [Witness] { courtCase.witnesses.filter { $0.isDefendant != true } }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(courtCase.caption).font(.caption).foregroundStyle(.secondary)
                Text(outcome.dismissed ? "Order of Dismissal" : "Judgment Entered")
                    .font(.system(.largeTitle, design: .serif).weight(.bold))
                Text("\(courtCase.docket) · \(SentenceFormat.date(courtCase.sessionDate))")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            if !outcome.verdictLines.isEmpty {
                SectionTitle(text: "Verdict", icon: "checkmark.seal.fill")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(outcome.verdictLines) { line in
                        HStack(alignment: .firstTextBaseline) {
                            Text("Count \(line.count): \(line.chargeTitle)").font(.callout)
                            Spacer()
                            Text(line.verdictLabel).font(.callout.weight(.bold)).multilineTextAlignment(.trailing)
                        }
                    }
                }
                .card()
            }

            if let habitual = outcome.habitualNote {
                Text(habitual).font(.callout).card()
            }

            if !outcome.rulingNotes.isEmpty {
                let sound = outcome.rulingNotes.filter(\.sound).count
                CollapsibleSection(title: "Your rulings on review", icon: "building.columns.fill",
                                   summary: "\(sound) of \(outcome.rulingNotes.count) would hold up on appeal",
                                   expanded: false) {
                    ForEach(outcome.rulingNotes) { note in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: note.sound ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundStyle(note.sound ? Theme.good : .orange)
                                Text(note.title).font(.subheadline.weight(.semibold))
                            }
                            Text("You: \(note.yourRuling)" + (note.sound ? "" : " · The better ruling: \(note.proper)"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(note.note).font(.callout).fixedSize(horizontal: false, vertical: true)
                        }
                        .card()
                    }
                }
            }

            if !outcome.judgments.isEmpty {
                SectionTitle(text: "Judgment and commitment", icon: "doc.text.fill")
                ForEach(outcome.judgments) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.title).font(.subheadline.weight(.semibold))
                        ForEach(entry.lines, id: \.self) { line in
                            Text(line).font(.callout)
                        }
                    }
                    .card()
                }
            }

            if let probation = outcome.probationHearing {
                SectionTitle(text: "Probation", icon: "person.badge.clock.fill")
                Text(probation).font(.callout).card()
            }

            if let order = outcome.stayAwayOrder {
                Label((order.fromProbation == true ? "Condition of probation: no contact with " : "Stay-away order entered: no contact with ")
                      + "\(order.protectedName) until \(SentenceFormat.shortDate(order.expires)).",
                      systemImage: "hand.raised.fill")
                    .font(.callout)
                    .card()
            }

            if let appeal = outcome.appealNotice {
                VStack(alignment: .leading, spacing: 6) {
                    Label(appeal, systemImage: "arrow.up.doc.fill").font(.callout)
                    if !outcome.appealGrounds.isEmpty {
                        Text("Counsel says the appeal will argue:").font(.caption.weight(.bold))
                        ForEach(Array(outcome.appealGrounds.enumerated()), id: \.offset) { index, ground in
                            Text("\(index + 1). \(ground)").font(.caption).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .card()
            }

            ForEach(outcome.incidentResults, id: \.self) { line in
                Label(line, systemImage: "exclamationmark.bubble.fill").font(.callout).card()
            }
            if let ethics = outcome.ethicsResult {
                SectionTitle(text: "Outside the courtroom", icon: "exclamationmark.shield.fill")
                Text(ethics).font(.callout).card()
            }

            SectionTitle(text: "In the hallway", icon: "quote.bubble.fill")
            VStack(alignment: .leading, spacing: 10) {
                ForEach(outcome.reactions, id: \.self) { line in
                    Text(line).font(.system(.callout, design: .serif))
                }
            }
            .card()

            SectionTitle(text: "Tomorrow's paper", icon: "newspaper.fill")
            NewsCard(item: outcome.news)

            if !witnesses.isEmpty { perjurySection }

            PrimaryButton(title: "Return to Chambers", icon: "house.fill") {
                onFinish(witnesses.filter { referred.contains($0.id) })
            }
        }
    }
}

struct NewsCard: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(SentenceFormat.shortDate(item.date), systemImage: item.kind.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let docket = item.docket {
                    Text(docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
                }
            }
            if let placement = item.placement {
                Text(placement.uppercased())
                    .font(.caption2.weight(.heavy))
                    .tracking(1)
                    .foregroundStyle(Theme.gold)
            }
            Text(item.headline).font(.system((item.prominence ?? 0) >= 3 ? .title3 : .headline, design: .serif).weight(.bold))
            Text(item.body).font(.callout).foregroundStyle(.secondary)
        }
        .card()
    }
}

// MARK: - Prior record rulings

struct PriorRecordRulings: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let id = c.background?.disputedPriorID, let prior = c.defendant.priors.first(where: { $0.id == id }) {
                Divider()
                Label("Disputed prior conviction", systemImage: "questionmark.folder.fill").font(.subheadline.weight(.semibold))
                if let reason = c.background?.disputedPriorReason {
                    Text("Defense: \"\(reason)\"").font(.caption)
                }
                Text("The State must prove each prior by a preponderance of the evidence. A DCI record is one permitted method (G.S. 15A-1340.14(f)).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                RulingPicker(first: "Proven", second: "Not proven",
                             firstDetail: "Count the \(prior.year) \(prior.offense)", secondDetail: "Leave it out",
                             selection: Binding(get: { session.rulings.priorsNotProven.contains(id) ? false : true },
                                                set: { proven in
                                                    if proven == false { session.rulings.priorsNotProven.insert(id) }
                                                    else { session.rulings.priorsNotProven.remove(id) }
                                                    session.rulings.sentences = [:]
                                                }))
            }
            if c.defendant.underSupervision {
                Divider()
                let notice = Judgment.probationNoticeGiven(c)
                ConditionToggle(title: "Count the point for offending while on \(c.defendant.probation != nil ? "probation" : "post-release supervision")",
                                detail: notice
                                    ? "The State served written notice 30 days before trial."
                                    : "The State did not serve the 30-day notice the statute requires (G.S. 15A-1340.16(a6)).",
                                isOn: Binding(get: { Judgment.countsProbationPoint(c, session.rulings) },
                                              set: { session.rulings.countProbationPoint = $0; session.rulings.sentences = [:] }))
            }
        }
    }
}

// MARK: - Summary before entering judgment

struct JudgmentSummaryCard: View {
    @ObservedObject var session: CaseSession

    var body: some View {
        let r = session.rulings
        VStack(alignment: .leading, spacing: 6) {
            Label("The judgment you are about to enter", systemImage: "doc.text.fill").font(.headline)
            switch r.special {
            case .prayerForJudgment:
                Text("Prayer for judgment continued. No sentence.").font(.callout)
            case .conditionalDischarge:
                Text("Conditional discharge with \(r.dischargeMonths ?? 12) months of probation.").font(.callout)
            case .none:
                ForEach(Array(session.units.enumerated()), id: \.offset) { index, unit in
                    let choice = session.choice(for: unit)
                    let disposition = choice.lifeWithoutParole ? "" : (choice.disposition == .active ? ", active" : ", suspended, \(choice.probationMonths) months probation")
                    let relation = index == 0 ? "" : (r.consecutive(unit.id, index: index) ? " (consecutive)" : " (concurrent)")
                    Text("• \(unit.title): \(Judgment.termText(for: unit, choice: choice))\(disposition)\(relation)")
                        .font(.callout)
                }
            }
            if let projection = Judgment.custodyProjection(session.courtCase, r, units: session.units, from: session.courtCase.sessionDate) {
                ForEach(projection.lines, id: \.self) { line in
                    Text("• " + line).font(.callout)
                }
            }
            let total = session.obligations.reduce(0) { $0 + $1.amount }
            if total > 0 {
                Text("• Monetary obligations: \(SentenceFormat.dollars(total))").font(.callout)
            }
            if !r.customConditions.isEmpty {
                Text("• \(r.customConditions.count) order\(r.customConditions.count == 1 ? "" : "s") of your own").font(.callout)
            }
        }
        .card(tint: Theme.gold)
    }
}

extension JudgmentStage {
    /// Sending testimony the judge believes was a lie to the district attorney.
    var perjurySection: some View {
        // Optional, and out of the way: a single row until the judge opens it.
        CollapsibleSection(title: "Refer a witness for perjury", icon: "exclamationmark.bubble.fill",
                           summary: referred.isEmpty ? "Optional" : "\(referred.count) to refer", expanded: false) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Only for a knowing lie about something that mattered. The DA decides whether to charge.")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(witnesses) { witness in
                let on = referred.contains(witness.id)
                Button {
                    Haptics.tap()
                    if on { referred.remove(witness.id) } else { referred.insert(witness.id) }
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: on ? "checkmark.square.fill" : "square")
                            .foregroundStyle(on ? Theme.bad : Theme.secondaryText)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(witness.name).font(.subheadline.weight(.semibold))
                            Text("\(witness.role) · called by \(witness.calledBy == .prosecution ? "the State" : "the defense")")
                                .font(.caption).foregroundStyle(.secondary)
                            if let line = Perjury.answers(witness).first {
                                Text("\u{201C}\(CounselBrief.clip(line, 80))\u{201D}")
                                    .font(.system(.caption, design: .serif)).italic()
                                    .foregroundStyle(Theme.quoteText)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(on ? Theme.objectionFill : Theme.raised.opacity(0.6)))
                }
                .buttonStyle(.plain)
            }
            if !referred.isEmpty {
                Label("\(referred.count) witness\(referred.count == 1 ? "" : "es") will be referred to the district attorney when you return to chambers.",
                      systemImage: "paperplane.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.bad)
            }
          }
        }
    }
}
