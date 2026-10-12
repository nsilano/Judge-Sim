import SwiftUI

// MARK: - Verdict

struct VerdictStage: View {
    @ObservedObject var session: CaseSession
    @State private var confirm = false
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Your duty as fact-finder", systemImage: "scalemass.fill").font(.headline)
                Text("Decide each count using only admissible evidence. Ignore anything you suppressed or struck. If the State hasn't proven every element beyond a reasonable doubt, you must acquit, even if you suspect guilt.")
                    .font(.callout)
                HStack {
                    LawLink(lawID: "burdenOfProof")
                    if c.charges.contains(where: { $0.lesserLawID != nil }) {
                        LawLink(lawID: "lesserIncluded")
                    }
                }
            }
            .card(tint: Theme.gold)

            SectionTitle(text: "Evidence you admitted", icon: "tray.full.fill")
            VStack(alignment: .leading, spacing: 8) {
                ForEach(c.evidence.filter { !session.isSuppressed($0) }) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle().fill(Theme.color(for: item.side)).frame(width: 8, height: 8)
                        Text(item.title).font(.callout)
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

            SectionTitle(text: "Your verdict", icon: "checkmark.seal.fill")
            ForEach(c.charges) { charge in
                VerdictCard(charge: charge, selection: session.verdictBinding(charge))
            }

            PrimaryButton(title: "Deliver the Verdict", icon: "hammer.fill", enabled: session.verdictsComplete) {
                confirm = true
            }
        }
        .confirmationDialog("A verdict is final. Are you ready?", isPresented: $confirm, titleVisibility: .visible) {
            Button("Deliver the verdict") {
                Haptics.gavel()
                session.advance()
            }
            Button("Keep deliberating", role: .cancel) {}
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
            option(.guilty, "Guilty", "As charged", Theme.bad)
            if let lesser = charge.lesserLaw {
                option(.lesser, "Guilty of \(lesser.title)", "Lesser included offense", .orange)
            }
            option(.notGuilty, "Not Guilty", "The State did not prove its case", Theme.good)
        }
        .card(tint: selection == nil ? nil : Theme.gold)
    }

    private func option(_ verdict: Verdict, _ title: String, _ subtitle: String, _ color: Color) -> some View {
        let isSelected = selection == verdict
        return Button {
            Haptics.tap()
            withAnimation(.snappy) { selection = verdict }
        } label: {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? color : .secondary)
                VStack(alignment: .leading) {
                    Text(title).font(.subheadline.weight(.bold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? color.opacity(0.12) : Color(.tertiarySystemFill)))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sentencing

struct SentencingStage: View {
    @ObservedObject var session: CaseSession
    private var c: CourtCase { session.courtCase }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("You found \(c.defendant.name) guilty. Now you must decide the sentence. It should be sufficient, but not greater than necessary.")
                .font(.callout)
                .foregroundStyle(.secondary)
            LawLink(lawID: "sentencingFactors")

            if let impact = c.victimImpact {
                SectionTitle(text: "Victim impact statement", icon: "heart.text.square.fill")
                Text(impact)
                    .font(.system(.callout, design: .serif)).italic()
                    .card(tint: Theme.prosecution)
            }

            SectionTitle(text: "The defendant addresses the court", icon: "person.wave.2.fill")
            Text(c.allocution)
                .font(.system(.callout, design: .serif)).italic()
                .card(tint: Theme.defense)

            SectionTitle(text: "Factors", icon: "list.bullet.clipboard.fill")
            VStack(alignment: .leading, spacing: 12) {
                Text("Aggravating").font(.caption.weight(.bold)).foregroundStyle(Theme.bad)
                BulletList(items: c.aggravating, symbol: "plus.circle.fill", color: Theme.bad)
                Text("Mitigating").font(.caption.weight(.bold)).foregroundStyle(Theme.good)
                BulletList(items: c.mitigating, symbol: "minus.circle.fill", color: Theme.good)
                Text("Prior record").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                Text(c.defendant.priorRecord.isEmpty ? "None" : "\(c.defendant.priorRecord.count) prior conviction\(c.defendant.priorRecord.count == 1 ? "" : "s")")
                    .font(.callout)
            }
            .card()

            SectionTitle(text: "Sentence", icon: "scalemass.fill")
            ForEach(session.convictions, id: \.charge.id) { item in
                if let range = item.law.sentence {
                    SentenceSlider(title: "Count \(item.charge.count): \(item.law.title)",
                                   law: item.law,
                                   range: range,
                                   value: session.sentenceBinding(item.charge, range: range),
                                   disabled: session.rulings.probation)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                if session.probationAvailable {
                    Toggle(isOn: $session.rulings.probation) {
                        VStack(alignment: .leading) {
                            Text("Suspend prison: probation").font(.subheadline.weight(.semibold))
                            Text("Supervised release with conditions").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Label("Probation isn't available for this conviction.", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if session.convictions.count > 1 {
                    Toggle(isOn: $session.rulings.consecutive) {
                        VStack(alignment: .leading) {
                            Text("Run sentences consecutively").font(.subheadline.weight(.semibold))
                            Text(session.rulings.consecutive ? "Terms are served back-to-back" : "Terms are served at the same time")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                if session.maxFine > 0 {
                    Stepper(value: $session.rulings.fine, in: 0...session.maxFine, step: fineStep) {
                        VStack(alignment: .leading) {
                            Text("Fine: \(SentenceFormat.dollars(session.rulings.fine))").font(.subheadline.weight(.semibold))
                            Text("Up to \(SentenceFormat.dollars(session.maxFine))").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .card()

            HStack {
                Text("Total sentence").font(.headline)
                Spacer()
                Text(session.rulings.probation ? "Probation" : SentenceFormat.months(session.totalSentence))
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.gold)
            }
            .card(tint: Theme.gold)

            PrimaryButton(title: "Impose Sentence", icon: "hammer.fill") {
                Haptics.gavel()
                session.advance()
            }
        }
        .tint(Theme.gold)
    }

    private var fineStep: Int {
        let raw = session.maxFine / 20
        return max(100, (raw / 100) * 100)
    }
}

struct SentenceSlider: View {
    let title: String
    let law: Law
    let range: SentenceRange
    @Binding var value: Double
    let disabled: Bool

    private var step: Double {
        let span = range.maxMonths - range.minMonths
        if span <= 24 { return 1 }
        if span <= 120 { return 3 }
        return 6
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                LawLink(lawID: law.id)
            }
            Text(disabled ? "Suspended" : SentenceFormat.months(Int(value)))
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(disabled ? Color.secondary : Color.primary)
            Slider(value: $value,
                   in: Double(range.minMonths)...Double(range.maxMonths),
                   step: step) {
                Text("Months")
            } minimumValueLabel: {
                Text(SentenceFormat.months(range.minMonths)).font(.caption2)
            } maximumValueLabel: {
                Text(SentenceFormat.months(range.maxMonths)).font(.caption2)
            }
            .disabled(disabled)
            HStack {
                Text("Typical: \(SentenceFormat.months(range.typicalMonths))")
                if range.mandatoryMinimum {
                    Text("· Mandatory minimum").foregroundStyle(Theme.bad)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .card()
    }
}

// MARK: - Outcome

struct OutcomeStage: View {
    let courtCase: CourtCase
    let outcome: CaseOutcome
    let onFinish: () -> Void
    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(courtCase.caption).font(.caption).foregroundStyle(.secondary)
                    Text(outcome.headline)
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                }
                Spacer()
                VStack(spacing: 0) {
                    Text(outcome.grade)
                        .font(.system(size: 40, weight: .black, design: .serif))
                    Text("\(outcome.score)%").font(.caption.monospacedDigit())
                }
                .frame(width: 80, height: 80)
                .background(Circle().fill(gradeColor.opacity(0.18)))
                .foregroundStyle(gradeColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(outcome.appeal.label, systemImage: outcome.appeal.isBad ? "arrow.uturn.backward.circle.fill" : "checkmark.shield.fill")
                    .font(.headline)
                    .foregroundStyle(outcome.appeal.isBad ? Theme.bad : Theme.good)
                Text(outcome.appeal.detail).font(.callout)
            }
            .card(tint: outcome.appeal.isBad ? Theme.bad : Theme.good)

            if !outcome.verdictLines.isEmpty {
                SectionTitle(text: "Verdict review", icon: "checkmark.seal.fill")
                ForEach(outcome.verdictLines) { line in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Count \(line.count): \(line.chargeTitle)").font(.subheadline.weight(.semibold))
                            Spacer()
                            Pill(text: line.sound ? "Sound" : "Unsound",
                                 color: line.sound ? Theme.good : Theme.bad,
                                 icon: line.sound ? "checkmark" : "xmark")
                        }
                        Text("Your verdict: \(line.verdictLabel)").font(.callout)
                        Text(line.explanation).font(.caption).foregroundStyle(.secondary)
                    }
                    .card()
                }
            }

            if let sentence = outcome.sentenceSummary {
                SectionTitle(text: "Sentence", icon: "scalemass.fill")
                VStack(alignment: .leading, spacing: 6) {
                    Text(sentence).font(.headline)
                    if let assessment = outcome.sentenceAssessment {
                        Text(assessment).font(.callout).foregroundStyle(.secondary)
                    }
                }
                .card()
            }

            if !outcome.reviews.isEmpty {
                SectionTitle(text: "Your rulings, reviewed", icon: "doc.text.magnifyingglass")
                ForEach(outcome.reviews) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Image(systemName: review.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(review.correct ? Theme.good : Theme.bad)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(review.title).font(.subheadline.weight(.semibold))
                                Text("You ruled: \(review.yourRuling)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Text(review.explanation).font(.callout)
                        if let doctrine = review.doctrineID { LawLink(lawID: doctrine) }
                    }
                    .card()
                }
            }

            SectionTitle(text: "Public reaction", icon: "newspaper.fill")
            Text(outcome.publicReaction).card()

            SectionTitle(text: "What really happened", icon: "eye.fill")
            if revealed {
                VStack(alignment: .leading, spacing: 10) {
                    Pill(text: outcome.truthGuilty ? "The defendant was guilty" : "The defendant was innocent",
                         color: outcome.truthGuilty ? Theme.bad : Theme.good,
                         icon: outcome.truthGuilty ? "person.fill.xmark" : "person.fill.checkmark")
                    Text(outcome.truthText).font(.system(.body, design: .serif))
                    Divider()
                    Text(outcome.epilogue).font(.callout.italic()).foregroundStyle(.secondary)
                }
                .card(tint: outcome.truthGuilty ? Theme.bad : Theme.good)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                Button {
                    Haptics.tap()
                    withAnimation(.spring) { revealed = true }
                } label: {
                    Label("Reveal the truth", systemImage: "lock.open.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.gold, lineWidth: 2))
                }
                .buttonStyle(.plain)
                Text("A judge never learns this for certain. You get to, after the gavel falls.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            SectionTitle(text: "Career impact", icon: "person.text.rectangle.fill")
            HStack {
                delta("Integrity", outcome.integrityDelta)
                Spacer()
                delta("Public approval", outcome.approvalDelta)
            }
            .card()

            PrimaryButton(title: "Return to Chambers", icon: "house.fill", action: onFinish)
        }
    }

    private var gradeColor: Color {
        switch outcome.grade {
        case "A", "B": return Theme.good
        case "C": return .orange
        default: return Theme.bad
        }
    }

    private func delta(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value >= 0 ? "+\(value)" : "\(value)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(value >= 0 ? Theme.good : Theme.bad)
        }
    }
}
