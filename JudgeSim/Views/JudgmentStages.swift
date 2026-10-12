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
            VStack(alignment: .leading, spacing: 8) {
                ForEach(c.evidence.filter { !session.isSuppressed($0) }) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle().fill(Theme.color(for: item.side)).frame(width: 8, height: 8)
                        Text("\(item.exhibit): \(item.title)").font(.callout)
                    }
                }
                ForEach(c.witnesses) { witness in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "person.fill").font(.caption).foregroundStyle(Theme.color(for: witness.calledBy))
                        Text("\(witness.name), \(witness.role.lowercased())").font(.callout)
                    }
                }
            }
            .card()

            SectionTitle(text: "Verdict", icon: "checkmark.seal.fill")
            ForEach(c.charges) { charge in
                VerdictCard(charge: charge, selection: session.verdictBinding(charge))
            }

            PrimaryButton(title: "Announce Verdict", icon: "hammer.fill", enabled: session.verdictsComplete) {
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

struct VerdictCard: View {
    let charge: Charge
    @Binding var selection: Verdict?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Count \(charge.count): \(charge.law.title)").font(.headline)
            Text(charge.specification).font(.callout).foregroundStyle(.secondary)
            option(.guilty, "Guilty", charge.law.ncClass?.label ?? "As charged")
            if let lesser = charge.lesserLaw {
                option(.lesser, "Guilty of \(lesser.title)", "Lesser-included offense · \(lesser.ncClass?.label ?? "")")
            }
            option(.notGuilty, "Not Guilty", "")
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
            .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? Theme.gold.opacity(0.15) : Color(.tertiarySystemFill)))
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
        VStack(alignment: .leading, spacing: 16) {
            Text("The court proceeds to sentencing under the Structured Sentencing Act.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if let impact = c.victimImpact {
                SectionTitle(text: "Victim impact", icon: "heart.text.square.fill")
                Text(impact)
                    .font(.system(.callout, design: .serif)).italic()
                    .card(tint: Theme.prosecution)
            }

            SectionTitle(text: "Allocution", icon: "person.wave.2.fill")
            Text(c.allocution)
                .font(.system(.callout, design: .serif)).italic()
                .card(tint: Theme.defense)

            if session.needsHabitualDecision {
                SectionTitle(text: "Habitual felon status", icon: "exclamationmark.triangle.fill")
                VStack(alignment: .leading, spacing: 10) {
                    Text("The State offers certified judgments of these prior felony convictions:")
                        .font(.callout)
                    ForEach(record.priorFelonies) { prior in
                        PriorRow(prior: prior)
                    }
                    LawLink(lawID: "habitualFelon")
                    RulingPicker(first: "Status proven", second: "Not proven",
                                 selection: Binding(get: { session.rulings.habitualFound },
                                                    set: { if let value = $0 { session.setHabitual(value) } }))
                }
                .card(tint: .orange)
            }

            SectionTitle(text: "Prior record", icon: "list.number")
            VStack(alignment: .leading, spacing: 8) {
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
            .card()

            SectionTitle(text: "Findings of factors", icon: "list.bullet.clipboard.fill")
            VStack(alignment: .leading, spacing: 12) {
                Text("Aggravating factors offered by the State").font(.caption.weight(.bold)).foregroundStyle(Theme.prosecution)
                ForEach(c.aggravating, id: \.self) { factor in
                    Toggle(factor, isOn: session.factorBinding(factor, aggravating: true)).font(.callout)
                }
                Divider()
                Text("Mitigating factors offered by the defense").font(.caption.weight(.bold)).foregroundStyle(Theme.defense)
                ForEach(c.mitigating, id: \.self) { factor in
                    Toggle(factor, isOn: session.factorBinding(factor, aggravating: false)).font(.callout)
                }
                Text("Finding an aggravating factor permits the aggravated range; finding a mitigating factor permits the mitigated range. Whether to depart is your decision.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                LawLink(lawID: "aggravatingFactors")
            }
            .card()

            if convictionCount > 1 {
                SectionTitle(text: "Multiple convictions", icon: "square.stack.3d.up.fill")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(JudgmentMode.allCases, id: \.self) { mode in
                        ChoiceRow(title: mode.label, selected: session.rulings.mode == mode) {
                            session.setMode(mode)
                        }
                    }
                    LawLink(lawID: "consolidation")
                }
                .card()
            }

            if !(session.needsHabitualDecision && session.rulings.habitualFound == nil) {
                SectionTitle(text: units.count == 1 ? "Judgment" : "Judgments", icon: "doc.text.fill")
                ForEach(units) { unit in
                    UnitSentenceCard(unit: unit,
                                     allowedRanges: session.allowedRanges(for: unit),
                                     choice: session.choiceBinding(for: unit))
                }

                VStack(alignment: .leading) {
                    Stepper(value: $session.rulings.fine, in: 0...maxFine, step: fineStep) {
                        VStack(alignment: .leading) {
                            Text("Fine: \(SentenceFormat.dollars(session.rulings.fine))").font(.subheadline.weight(.semibold))
                            Text("Plus court costs").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .card()
            }

            PrimaryButton(title: "Enter Judgment", icon: "hammer.fill", enabled: session.sentencingComplete) {
                Haptics.gavel()
                session.advance()
            }
        }
        .tint(Theme.gold)
    }

    private var convictionCount: Int {
        c.charges.filter { (session.rulings.verdicts[$0.id] ?? .notGuilty) != .notGuilty }.count
    }

    private var maxFine: Int {
        let units = session.units
        if units.contains(where: { $0.isFelony }) { return 50_000 }
        let caps = units.map { $0.sentencingClass.maxFine ?? 10_000 }
        return caps.max() ?? 1_000
    }

    private var fineStep: Int {
        maxFine <= 1_000 ? 50 : (maxFine <= 10_000 ? 250 : 1_000)
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
            .background(RoundedRectangle(cornerRadius: 10).fill(selected ? Theme.gold.opacity(0.15) : Color(.tertiarySystemFill)))
            .opacity(enabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct UnitSentenceCard: View {
    let unit: SentencingUnit
    let allowedRanges: [SentenceRangeKind]
    @Binding var choice: SentenceChoice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(unit.title).font(.headline)
            Text(unit.classLine).font(.caption).foregroundStyle(.secondary)

            if unit.isMandatoryLife {
                Label("Class A felony: life imprisonment without parole is mandatory for a defendant who was 18 or older.",
                      systemImage: "lock.fill")
                    .font(.callout)
            } else if let cell = unit.felonyCell {
                felony(cell)
            } else if let cell = unit.misdemeanorCell {
                misdemeanor(cell)
            }
        }
        .card(tint: Judgment.isComplete(choice) ? Theme.gold : nil)
    }

    @ViewBuilder
    private func felony(_ cell: FelonyCell) -> some View {
        Text("Minimum sentence range").font(.caption.weight(.bold)).foregroundStyle(.secondary)
        ForEach(SentenceRangeKind.allCases, id: \.self) { kind in
            let range = cell.range(kind)
            ChoiceRow(title: kind.label,
                      subtitle: range?.text ?? "Life imprisonment without parole",
                      selected: choice.range == kind,
                      enabled: allowedRanges.contains(kind)) {
                choice.range = kind
                if let range {
                    choice.lifeWithoutParole = false
                    choice.minimum = min(max(choice.minimum, range.low), range.high)
                } else {
                    choice.lifeWithoutParole = true
                    choice.disposition = .active
                }
            }
        }

        if !choice.lifeWithoutParole, let range = cell.range(choice.range) {
            Stepper(value: $choice.minimum, in: range.low...range.high) {
                VStack(alignment: .leading) {
                    Text("Minimum \(choice.minimum) months").font(.title3.weight(.bold))
                    Text("Maximum \(StructuredSentencing.maximum(forMinimum: choice.minimum, cls: unit.sentencingClass)) months · \(SentenceFormat.months(choice.minimum)) to \(SentenceFormat.months(StructuredSentencing.maximum(forMinimum: choice.minimum, cls: unit.sentencingClass)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            dispositionPicker(cell.dispositions, felony: true)
        }
    }

    @ViewBuilder
    private func misdemeanor(_ cell: MisdemeanorCell) -> some View {
        Stepper(value: $choice.minimum, in: 1...cell.maxDays) {
            VStack(alignment: .leading) {
                Text("\(choice.minimum) days").font(.title3.weight(.bold))
                Text("Authorized: 1–\(cell.maxDays) days").font(.caption).foregroundStyle(.secondary)
            }
        }
        dispositionPicker(cell.dispositions, felony: false)
    }

    @ViewBuilder
    private func dispositionPicker(_ allowed: [Disposition], felony: Bool) -> some View {
        Text("Disposition (allowed: \(allowed.map(\.rawValue).joined(separator: "/")))")
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
        ForEach(allowed, id: \.self) { disposition in
            ChoiceRow(title: disposition.label, subtitle: disposition.detail, selected: choice.disposition == disposition) {
                choice.disposition = disposition
                let months = StructuredSentencing.probationMonths(felony: felony, disposition: disposition)
                choice.probationMonths = min(max(choice.probationMonths, months.lowerBound), months.upperBound)
            }
        }
        if let disposition = choice.disposition, disposition != .active {
            let months = StructuredSentencing.probationMonths(felony: felony, disposition: disposition)
            Stepper(value: $choice.probationMonths, in: months) {
                Text("Probation: \(choice.probationMonths) months").font(.subheadline.weight(.semibold))
            }
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
                    Text(session.anyConviction
                         ? "You have just found the probationer guilty in the new case."
                         : "You have just acquitted the probationer in the new case. A violation still may be found if you are reasonably satisfied, in your discretion, that the new offense occurred.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    LawLink(lawID: "probationViolation")
                }
                .card(tint: .orange)

                ForEach(ProbationDecision.allCases, id: \.self) { decision in
                    ChoiceRow(title: decision.label,
                              subtitle: decision == .revoke ? "Activates \(probation.suspendedSentence)" : nil,
                              selected: session.rulings.probationDecision == decision) {
                        session.rulings.probationDecision = decision
                    }
                }
            }

            PrimaryButton(title: "Enter Order", icon: "hammer.fill", enabled: session.rulings.probationDecision != nil) {
                Haptics.gavel()
                session.advance()
            }
        }
    }
}

// MARK: - Judgment

struct JudgmentStage: View {
    let courtCase: CourtCase
    let outcome: CaseOutcome
    let onFinish: () -> Void

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

            if let appeal = outcome.appealNotice {
                Label(appeal, systemImage: "arrow.up.doc.fill").font(.callout).card()
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

            PrimaryButton(title: "Adjourn", icon: "house.fill", action: onFinish)
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
            Text(item.headline).font(.system(.headline, design: .serif))
            Text(item.body).font(.callout).foregroundStyle(.secondary)
        }
        .card()
    }
}
