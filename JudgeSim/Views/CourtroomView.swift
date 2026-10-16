import SwiftUI

struct CourtroomView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var session: CaseSession
    @State private var showLibrary = false
    @State private var showCounsel = false
    @State private var confirmRecess = false
    @State private var showContinuance = false
    /// Set when the court grants a party's motion to continue, so the sheet opens with that motion's reason and follow-up.
    @State private var grantingMotion: ContinuanceMotion?
    @State private var reviewSection: CaseReviewSheet.Section?

    init(courtCase: CourtCase, judgeName: String, county: County, resume: CaseSnapshot? = nil) {
        _session = StateObject(wrappedValue: CaseSession(courtCase: courtCase, judgeName: judgeName, county: county, resume: resume))
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Hollis County Superior Court".uppercased())
                                    .font(.caption)
                                    .tracking(1.6)
                                    .foregroundStyle(Theme.gold)
                                Spacer()
                                Text(session.courtCase.docket)
                                    .font(.caption)
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Text("State v. \(session.courtCase.defendant.lastName)")
                                .font(.system(.title, design: .serif).weight(.semibold))
                                .foregroundStyle(Theme.text)
                            StageTracker(stages: session.visibleStages, current: session.stage) { tapped in
                                reviewSection = section(for: tapped)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.border, lineWidth: 1))
                        .id("top")

                        switch session.stage {
                        case .briefing:
                            BriefingStage(session: session) { motion in
                                grantingMotion = motion
                                showContinuance = true
                            }
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
            .background(Theme.background)
            .safeAreaInset(edge: .bottom) {
                if session.stage != .judgment {
                    CourtActionBar(counselCount: session.unaskedCount, next: session.nextStep,
                                   onCounsel: { showCounsel = true },
                                   onReview: { reviewSection = session.stage == .briefing ? .file : .evidence })
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        .frame(maxWidth: .infinity)
                        .background {
                            Theme.surface
                                .overlay(alignment: .top) { Rectangle().fill(Theme.border).frame(height: 1) }
                                .ignoresSafeArea(edges: .bottom)
                        }
                }
            }
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
                if session.stage != .judgment {
                    ToolbarItem(placement: .secondaryAction) {
                        Button {
                            showContinuance = true
                        } label: {
                            Label("Continue the Case…", systemImage: "calendar.badge.clock")
                        }
                    }
                }
            }
            .sheet(item: $reviewSection) { section in
                CaseReviewSheet(session: session, section: section)
            }
            .sheet(isPresented: $showContinuance, onDismiss: { grantingMotion = nil }) {
                ContinuanceSheet(today: session.courtCase.sessionDate, subject: session.courtCase.caption,
                                 requestOptions: EvidenceRequest.options(for: session.courtCase),
                                 initialRequests: grantingMotion.map { [$0.request] } ?? [],
                                 initialReason: grantingMotion.map { "On the \($0.movant == .prosecution ? "State's" : "defense's") motion: \($0.title.lowercased())." },
                                 initialDays: grantingMotion?.suggestedDays) { date, reason, requests in
                    showContinuance = false
                    game.continueMatter(session.courtCase.id, to: date, reason: reason, snapshot: session.snapshot, requests: requests)
                    dismiss()
                }
            }
            .sheet(isPresented: $showCounsel) {
                CounselSheet(provider: session)
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: session.courtCase.relevantLawIDs, showsDoneButton: true)
            }
            .confirmationDialog("Leave the courtroom?", isPresented: $confirmRecess, titleVisibility: .visible) {
                Button("Continue the case to another date") { showContinuance = true }
                Button("Leave and start this case over later today", role: .destructive) { dismiss() }
                Button("Stay", role: .cancel) {}
            } message: {
                Text("A continuance keeps every ruling you've made. Leaving without one means starting this case over.")
            }
        }
        .interactiveDismissDisabled()
    }
}

extension CourtroomView {
    /// Tapping a finished step opens that part of the case file.
    func section(for stage: CaseSession.Stage) -> CaseReviewSheet.Section {
        switch stage {
        case .briefing: return .file
        case .motions: return .motions
        case .trial: return .testimony
        default: return .evidence
        }
    }
}

struct StageTracker: View {
    let stages: [CaseSession.Stage]
    let current: CaseSession.Stage
    var onReview: ((CaseSession.Stage) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(stages) { stage in
                    let reached = stage.rawValue <= current.rawValue
                    VStack(spacing: 5) {
                        Capsule()
                            .fill(reached ? Theme.gold : Theme.border)
                            .frame(height: 4)
                        Text(stage.shortTitle)
                            .font(.system(size: 10, weight: stage == current ? .bold : .regular))
                            .foregroundStyle(stage == current ? Theme.lightGold : (reached ? Theme.gold : Theme.secondaryText))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if stage.rawValue < current.rawValue { onReview?(stage) }
                    }
                    .accessibilityLabel(stage.title)
                    .accessibilityHint(stage.rawValue < current.rawValue ? "Review this part of the case" : "")
                }
            }
            if let index = stages.firstIndex(of: current) {
                Text("Stage \(index + 1) of \(stages.count) · \(current.title)")
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

// MARK: - Briefing

struct BriefingStage: View {
    @ObservedObject var session: CaseSession
    /// Called when the judge grants a party's motion to continue.
    var onGrantContinuance: (ContinuanceMotion) -> Void = { _ in }
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

            if let motion = session.continuanceMotion {
                ContinuanceMotionCard(motion: motion, denied: session.rulings.continuanceMotionDenied == true,
                                      onGrant: { onGrantContinuance(motion) },
                                      onDeny: { session.denyContinuanceMotion() })
            }

            if let twist = c.twist {
                Label(twist, systemImage: "exclamationmark.bubble.fill")
                    .font(.callout)
                    .card(tint: .orange)
            }

            SectionTitle(text: c.charges.count == 1 ? "The charge" : "\(c.charges.count) charges", icon: "list.bullet.rectangle.fill")
            ForEach(c.charges) { charge in
                ChargeCard(charge: charge)
            }

            if let report = c.investigation {
                CollapsibleSection(title: "Investigation report", icon: "magnifyingglass",
                                   summary: "\(report.agency) · \(report.timeline.count) entries · lead: \(report.leadInvestigator)",
                                   expanded: false) {
                    InvestigationReportView(report: report)
                }
            }

            CollapsibleSection(title: "The defendant", icon: "person.fill",
                               summary: "\(c.defendant.name), \(c.defendant.age) · \(c.defendant.profile?.jobs.first?.title ?? c.defendant.occupation) · " + (c.defendant.priors.isEmpty ? "no prior record" : "\(c.defendant.priors.count) prior conviction\(c.defendant.priors.count == 1 ? "" : "s")") + (c.defendant.probation != nil ? " · on probation" : c.defendant.postRelease != nil ? " · on post-release supervision" : ""),
                               expanded: false) {
                DefendantCard(defendant: c.defendant, county: session.county)
            }

            CollapsibleSection(title: "Procedural posture", icon: "doc.plaintext",
                               summary: c.habitualIndicted ? "Jury waived · habitual felon indictment" : (c.court == .misdemeanorAppeal ? "Appeal from district court" : "Jury waived"),
                               expanded: false) {
                BulletList(items: c.proceduralNotes + deNovoNote, symbol: "circle.fill")
                    .font(.callout)
            }

            CollapsibleSection(title: "Counsel & investigation", icon: "person.2.fill",
                               summary: "\(c.prosecutor) for the State · \(c.defenseAttorney.components(separatedBy: ",").first ?? c.defenseAttorney) for the defense",
                               expanded: false) {
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
            }

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
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.raised))
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
                          enabled: !session.continuanceMotionPending && (!session.pleaPresented || session.rulings.pleaAccepted == false),
                          hint: session.continuanceMotionPending ? "Rule on the motion to continue first." : "Accept or reject the plea arrangement first.") {
                session.advance()
            }
        }
    }
}

/// A party asks for more time before the trial starts.
struct ContinuanceMotionCard: View {
    let motion: ContinuanceMotion
    let denied: Bool
    let onGrant: () -> Void
    let onDeny: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Motion to continue: \(motion.title)", systemImage: "calendar.badge.clock")
                .font(.headline)
            Text(motion.movant == .prosecution ? "Moved by the State" : "Moved by the defense")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.color(for: motion.movant))
            Text(motion.argument).font(.system(.callout, design: .serif))
            Text(motion.opposition).font(.system(.callout, design: .serif)).foregroundStyle(.secondary)
            Text("A continuance is in the court's discretion; the movant must show good cause (G.S. 15A-952(g)). If granted, the follow-up comes back as evidence when the case returns: \(motion.request.label.lowercased()).")
                .font(.caption)
                .foregroundStyle(.secondary)
            if denied {
                Label("Denied. " + motion.ifDenied, systemImage: "xmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            } else {
                HStack(spacing: 10) {
                    Button {
                        Haptics.tap()
                        onGrant()
                    } label: {
                        Label("Grant; pick a date", systemImage: "calendar")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.gold))
                            .foregroundStyle(Color.black)
                    }
                    .buttonStyle(.plain)
                    Button {
                        Haptics.tap()
                        onDeny()
                    } label: {
                        Label("Deny; proceed", systemImage: "hammer.fill")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.raised))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .card(tint: denied ? nil : .orange)
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
                    Text("Age \(defendant.age) · \(NameBank.gender(of: defendant.name).label) · \(defendant.occupation)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Text(defendant.background).font(.callout)

            if let profile = defendant.profile {
                Divider()
                DefendantProfileView(profile: profile)
            }

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

            if let prs = defendant.postRelease {
                Label("On post-release supervision: \(prs.docket), \(prs.offense). Supervision ends \(SentenceFormat.shortDate(prs.ends)); \(prs.remainingMonths) months of the maximum term unserved.",
                      systemImage: "person.badge.clock.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
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
            if let violations = defendant.violations, !violations.isEmpty {
                Text("Supervision violations").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                ForEach(violations.sorted { $0.date > $1.date }) { v in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(v.kind) · \(v.docket) · \(SentenceFormat.shortDate(v.date))")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.orange)
                        Text("\(v.conduct). \(v.result).").font(.caption).foregroundStyle(.secondary)
                    }
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
                                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.raised))
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
            .background(Theme.background)
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


// MARK: - Continuance

/// Pick a date to reconvene and the reason for the continuance.
struct ContinuanceSheet: View {
    let today: Date
    let subject: String
    var requestOptions: [EvidenceRequest] = []
    let onContinue: (Date, String, [EvidenceRequest]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var reason: String
    @State private var reasonOptions: [String]
    @State private var requests: Set<EvidenceRequest>

    static let reasons = [
        "On the court's own motion.",
        "On the defense's motion, to prepare.",
        "On the State's motion: a witness is unavailable.",
        "Awaiting a State Crime Laboratory report.",
        "For a pre-sentence report before sentencing.",
        "So the defendant can complete treatment before sentencing.",
        "Defense counsel has a conflict in another courtroom."
    ]

    init(today: Date, subject: String, requestOptions: [EvidenceRequest] = [], initialRequests: [EvidenceRequest] = [],
         initialReason: String? = nil, initialDays: Int? = nil,
         onContinue: @escaping (Date, String, [EvidenceRequest]) -> Void) {
        self.today = today
        self.subject = subject
        self.requestOptions = requestOptions
        self.onContinue = onContinue
        let days = max(1, (initialDays ?? 7) - 1)
        let suggested = CourtCalendar.nextWeekday(after: Calendar.current.date(byAdding: .day, value: days, to: today) ?? today)
        _date = State(initialValue: max(suggested, Self.earliest(after: today)))
        let options = (initialReason.map { [$0] } ?? []) + Self.reasons
        _reasonOptions = State(initialValue: options)
        _reason = State(initialValue: options[0])
        _requests = State(initialValue: Set(initialRequests))
    }

    /// This week's calendar is already set, so a continued matter comes back next week at the earliest.
    static func earliest(after today: Date) -> Date {
        CourtCalendar.monday(onOrAfter: CourtCalendar.nextWeekday(after: today))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(subject).font(.headline)
                    DatePicker("Reconvene on", selection: $date,
                               in: Self.earliest(after: today)...,
                               displayedComponents: .date)
                    Text("It will be on the calendar for the \("w" + CourtCalendar.weekTitle(CourtCalendar.weekday(onOrAfter: date)).dropFirst()).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Every ruling you've made is kept. The case comes back on that week's calendar, right where you left it.")
                }
                if !requestOptions.isEmpty {
                    Section {
                        ForEach(requestOptions) { option in
                            Button {
                                if requests.contains(option) { requests.remove(option) } else { requests.insert(option) }
                            } label: {
                                HStack {
                                    Image(systemName: requests.contains(option) ? "checkmark.square.fill" : "square")
                                        .foregroundStyle(requests.contains(option) ? Theme.gold : .secondary)
                                    Label(option.label, systemImage: option.icon).foregroundStyle(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Order follow-up before you reconvene")
                    } footer: {
                        Text("Results arrive as new exhibits when the case comes back. They may help either side, or come back inconclusive.")
                    }
                }
                Section("Reason") {
                    Picker("Reason", selection: $reason) {
                        ForEach(reasonOptions, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .benchBackground()
            .navigationTitle("Continuance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        let ownMotion = reason == Self.reasons[0]
                        onContinue(date, requests.isEmpty || !ownMotion ? reason : "For further investigation, on the court's own motion.", Array(requests))
                    }
                }
            }
        }
    }
}
