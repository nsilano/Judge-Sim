import SwiftUI

struct HearingView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session: HearingSession
    @State private var showCounsel = false
    @State private var showLibrary = false
    @State private var confirmLeave = false
    @State private var showContinuance = false

    init(hearing: ViolationHearing, judgeName: String, county: County) {
        _session = StateObject(wrappedValue: HearingSession(hearing: hearing, judgeName: judgeName, county: county))
    }

    private var h: ViolationHearing { session.hearing }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let outcome = session.outcome {
                        outcomeView(outcome)
                    } else {
                        hearingView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Probation Violation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if session.outcome == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            confirmLeave = true
                        } label: {
                            Label("Leave", systemImage: "chevron.left").labelStyle(.titleAndIcon)
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showLibrary = true } label: {
                        Label("Laws", systemImage: "books.vertical.fill").labelStyle(.titleAndIcon)
                    }
                }
            }
            .sheet(isPresented: $showCounsel) { CounselSheet(provider: session) }
            .sheet(isPresented: $showContinuance) {
                ContinuanceSheet(today: h.date, subject: "Probation violation: \(h.personName)") { date, reason, _ in
                    showContinuance = false
                    game.continueMatter(h.id, to: date, reason: reason, snapshot: nil)
                    dismiss()
                }
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: ["probationViolation", "crv", "probationConditions", "dispositions"], showsDoneButton: true)
            }
        }
        .interactiveDismissDisabled()
        .confirmationDialog("Leave the hearing?", isPresented: $confirmLeave, titleVisibility: .visible) {
            Button("Continue the hearing to another date") { showContinuance = true }
            Button("Leave; resume later today") { dismiss() }
            Button("Stay", role: .cancel) {}
        } message: {
            Text("The hearing stays on your docket. Your rulings so far won't be kept.")
        }
    }

    @ViewBuilder
    private var hearingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(session.county.courtName.uppercased()) · PROBATION VIOLATION")
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundStyle(Theme.gold)
            Text("\(h.probation.docket) · \(SentenceFormat.date(h.date))")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Text("State v. \(h.personName)")
                .font(.system(.title, design: .serif).weight(.bold))
            Text("Age \(h.personAge) · On probation for \(h.probation.offense)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        CounselPrompt(available: session.unaskedCount) { showCounsel = true }

        SectionTitle(text: "Violation report", icon: "doc.text.fill")
        VStack(alignment: .leading, spacing: 10) {
            Text(h.officerReport).font(.callout)
            BulletList(items: h.violations, symbol: "exclamationmark.circle.fill", color: .orange)
                .font(.callout)
        }
        .card(tint: .orange)

        SectionTitle(text: "Admission or denial", icon: "person.fill.questionmark")
        VStack(alignment: .leading, spacing: 10) {
            let last = h.personName.components(separatedBy: " ").last ?? h.personName
            if h.admits ?? true {
                Text("Through counsel, \(last) admits the violations. The hearing proceeds to disposition; you still decide whether each was without lawful excuse.")
                    .font(.callout)
            } else {
                Text("\(last) denies the violations. The State calls the probation officer.").font(.callout)
                ForEach(h.officerTestimony ?? [], id: \.self) { line in
                    Text(line).font(.system(.callout, design: .serif)).italic()
                }
                ForEach(h.officerCross ?? [], id: \.self) { line in
                    Text(line).font(.callout).foregroundStyle(.secondary)
                }
                Text("The rules of evidence don't strictly apply at a violation hearing, but you must be reasonably satisfied the violation occurred (G.S. 15A-1345(e)).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Finding").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            ForEach(ViolationFinding.allCases, id: \.self) { finding in
                ChoiceRow(title: finding.label, subtitle: finding.detail, selected: session.rulings.finding == finding) {
                    session.rulings.finding = finding
                }
            }
        }
        .card(tint: .orange)

        SectionTitle(text: "The judgment being enforced", icon: "scalemass.fill")
        VStack(alignment: .leading, spacing: 8) {
            Text("Suspended sentence: \(h.probation.suspendedSentence)").font(.callout)
            Text("\(h.probation.supervised ?? true ? "Supervised" : "Unsupervised") probation, ending \(SentenceFormat.shortDate(h.probation.ends))")
                .font(.callout)
            if h.probation.imposedInThisCourt {
                Text("You imposed this sentence.").font(.caption).foregroundStyle(.purple)
            } else {
                Text(h.probation.origin ?? "Another judge imposed this sentence.").font(.caption).foregroundStyle(.secondary)
            }
            if let conditions = h.probation.conditions, !conditions.isEmpty {
                Divider()
                Text("Special conditions").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                BulletList(items: conditions).font(.caption)
            }
            if let monthly = h.probation.monthlyObligation, monthly > 0 {
                Text("Monthly payment obligation: about \(SentenceFormat.dollars(monthly))").font(.caption).foregroundStyle(.secondary)
            }
        }
        .card()

        SectionTitle(text: "Order", icon: "hammer.fill")
        VStack(alignment: .leading, spacing: 8) {
            ForEach(HearingDecision.allCases, id: \.self) { decision in
                ChoiceRow(title: decision.label,
                          subtitle: decision == .crv ? "\(ViolationHearings.crvDays(h)) days here. " + decision.detail
                            : (decision == .revoke ? "Activates \(ViolationHearings.revocationMonths(h.probation)) months after CRV credit. " + decision.detail : decision.detail),
                          selected: session.rulings.decision == decision) {
                    session.rulings.decision = decision
                }
            }
            if session.rulings.finding != nil && session.rulings.finding != .established
                && [HearingDecision.quickDip, .crv, .revoke].contains(session.rulings.decision) {
                Label("You found no willful violation. A sanction now may be vacated on appeal.",
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else if !session.canRevoke && session.rulings.decision == .revoke {
                Label("Heads up: there's no new offense, absconding, or two prior CRVs here. The statute doesn't authorize revocation, and it may be reversed on appeal.",
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            LawLink(lawID: "crv")
        }
        .card()

        if session.rulings.decision == .modify {
            SectionTitle(text: "Modifications", icon: "slider.horizontal.3")
            VStack(alignment: .leading, spacing: 12) {
                ConditionToggle(title: "Add substance abuse / mental health assessment and treatment", isOn: $session.rulings.addTreatment)
                ConditionToggle(title: "Add random drug testing", isOn: $session.rulings.addTesting)
                ConditionToggle(title: "Add curfew", isOn: $session.rulings.addCurfew)
                ConditionToggle(title: "Add 60 days of house arrest with electronic monitoring", isOn: $session.rulings.addHouseArrest)
                Stepper(value: $session.rulings.extendMonths, in: 0...24, step: 6) {
                    Text("Extend probation: \(session.rulings.extendMonths) months").font(.subheadline)
                }
            }
            .card()
        }

        VStack(alignment: .leading) {
            ConditionToggle(title: "Remit remaining fees and costs",
                            detail: "Forgive unpaid fees. Doesn't affect restitution owed to a victim.",
                            isOn: $session.rulings.remitFees)
        }
        .card()

        PrimaryButton(title: "Enter Order", icon: "hammer.fill", enabled: session.rulings.decision != nil && session.rulings.finding != nil,
                      hint: "Make a finding and choose an order above.") {
            Haptics.gavel()
            session.finish()
        }
    }

    @ViewBuilder
    private func outcomeView(_ outcome: HearingOutcome) -> some View {
        Text("Order Entered")
            .font(.system(.largeTitle, design: .serif).weight(.bold))
        Text("\(h.probation.docket) · \(h.personName)")
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
        VStack(alignment: .leading, spacing: 8) {
            ForEach(outcome.lines, id: \.self) { Text($0).font(.callout) }
        }
        .card()
        SectionTitle(text: "Tomorrow's paper", icon: "newspaper.fill")
        NewsCard(item: outcome.news)
        PrimaryButton(title: "Return to Chambers", icon: "house.fill") {
            game.completeHearing(h, outcome: outcome)
            dismiss()
        }
    }
}
