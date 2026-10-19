import SwiftUI

/// The whole case file, open at any stage: what was filed, argued, admitted, and ruled on so far.
struct CaseReviewSheet: View {
    @ObservedObject var session: CaseSession
    @Environment(\.dismiss) private var dismiss
    @State var section: Section = .file

    enum Section: String, CaseIterable, Identifiable {
        case file = "File", investigation = "Investigation", motions = "Motions", evidence = "Evidence", testimony = "Testimony", arguments = "Arguments", notes = "Notes"
        var id: String { rawValue }
    }

    private var c: CourtCase { session.courtCase }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Section.allCases) { item in
                            Button {
                                withAnimation(.snappy) { section = item }
                            } label: {
                                Text(item.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(section == item ? Theme.gold : Theme.raised))
                                    .foregroundStyle(section == item ? Color.black : Color.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        switch section {
                        case .file: fileSection
                        case .investigation:
                            if let report = c.investigation {
                                InvestigationReportView(report: report).card()
                            } else {
                                empty("No investigation report in this file.")
                            }
                        case .motions: motionsSection
                        case .evidence: evidenceSection
                        case .testimony: testimonySection
                        case .arguments: argumentsSection
                        case .notes: notesSection
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.background)
            .navigationTitle("Case File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: Sections

    @ViewBuilder
    private var fileSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(c.caption).font(.system(.title3, design: .serif).weight(.bold))
            Text("\(c.docket) · \(c.court.label)").font(.caption.monospaced()).foregroundStyle(.secondary)
            Text(c.summary).font(.callout)
        }
        .card()
        SectionTitle(text: "Charges", icon: "list.bullet.rectangle")
        ForEach(c.charges) { charge in
            VStack(alignment: .leading, spacing: 4) {
                ChargeCard(charge: charge)
                if let note = status(of: charge) {
                    Label(note, systemImage: "info.circle").font(.caption).foregroundStyle(.secondary).padding(.horizontal, 4)
                }
            }
        }
        SectionTitle(text: "The defendant", icon: "person.fill")
        DefendantCard(defendant: c.defendant, county: session.county)
        SectionTitle(text: "Procedural posture", icon: "doc.plaintext")
        BulletList(items: c.proceduralNotes, symbol: "circle.fill").font(.callout).card()
        if let twist = c.twist {
            Text(twist).font(.callout).card(tint: .orange)
        }
    }

    @ViewBuilder
    private var motionsSection: some View {
        if c.motions.isEmpty {
            empty("No pretrial motions were filed.")
        }
        ForEach(c.motions) { motion in
            VStack(alignment: .leading, spacing: 8) {
                Text(motion.kind.title).font(.headline)
                if let target = c.evidence(motion.targetEvidenceID) {
                    Text("Target: \(target.exhibit), \(target.title)").font(.caption).foregroundStyle(.secondary)
                }
                Text(motion.facts).font(.callout)
                Text("Defense: \(motion.defenseArgument)").font(.caption).foregroundStyle(Theme.defense)
                Text("State: \(motion.prosecutionResponse)").font(.caption).foregroundStyle(Theme.prosecution)
                rulingLabel(session.rulings.motions[motion.id].map { $0 ? "You granted the motion." : "You denied the motion." })
            }
            .card()
        }
    }

    @ViewBuilder
    private var evidenceSection: some View {
        let state = c.evidence.filter { $0.side == .prosecution }
        let defense = c.evidence.filter { $0.side == .defense }
        SectionTitle(text: "State's exhibits", icon: "building.columns.fill")
        ForEach(state) { item in EvidenceCard(evidence: item, suppressed: session.isSuppressed(item), courtCase: c) }
        if !defense.isEmpty {
            SectionTitle(text: "Defense exhibits", icon: "shield.fill")
            ForEach(defense) { item in EvidenceCard(evidence: item, suppressed: session.isSuppressed(item), courtCase: c) }
        }
    }

    @ViewBuilder
    private var testimonySection: some View {
        let witnesses = c.witnesses + (session.rulings.defendantTestifies == true ? [c.defendantTestimony].compactMap { $0 } : [])
        if witnesses.isEmpty { empty("No witnesses testified.") }
        ForEach(witnesses) { witness in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill").foregroundStyle(Theme.color(for: witness.calledBy))
                    VStack(alignment: .leading) {
                        Text(witness.name).font(.headline)
                        Text("\(witness.role) · called by the \(witness.calledBy.rawValue)").font(.caption).foregroundStyle(.secondary)
                    }
                }
                ExaminationTranscript(witness: witness)
                ForEach(session.witnessTranscript(for: witness)) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Court: \(entry.question)").font(.caption.weight(.semibold)).foregroundStyle(Theme.gold)
                        Text(entry.answer).font(.system(.callout, design: .serif))
                    }
                }
                ForEach(c.objections(for: witness)) { objection in
                    let ruling = session.rulings.objections[objection.id]
                    VStack(alignment: .leading, spacing: 3) {
                        Text(objection.question).font(.caption)
                        Text(objection.answer).font(.system(.caption, design: .serif)).strikethrough(ruling == true)
                        Text(ruling == nil ? "Objection (\(objection.grounds.lowercased())) not yet ruled on."
                             : ruling == true ? "Sustained (\(objection.grounds.lowercased())). Stricken."
                             : "Overruled (\(objection.grounds.lowercased())). Admitted.")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(ruling == true ? Color.orange : Color.secondary)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Theme.raised))
                }
            }
            .card()
        }
        if session.rulings.defendantTestifies == false {
            empty("The defendant chose not to testify. No inference may be drawn from that.")
        }
    }

    @ViewBuilder
    private var argumentsSection: some View {
        SectionTitle(text: "Opening statements", icon: "text.quote")
        VStack(alignment: .leading, spacing: 12) {
            Statement(side: .prosecution, speaker: c.prosecutor, text: c.prosecutionOpening)
            Statement(side: .defense, speaker: c.defenseAttorney, text: c.defenseOpening)
        }
        .card()
        SectionTitle(text: "Closing arguments", icon: "text.quote")
        VStack(alignment: .leading, spacing: 12) {
            Statement(side: .prosecution, speaker: c.prosecutor, text: c.prosecutionClosing)
            Statement(side: .defense, speaker: c.defenseAttorney, text: c.defenseClosing)
        }
        .card()
        if !session.aggravatingFactors.isEmpty || !session.mitigatingFactors.isEmpty {
            SectionTitle(text: "Factors offered for sentencing", icon: "list.bullet.clipboard")
            VStack(alignment: .leading, spacing: 6) {
                ForEach(session.aggravatingFactors, id: \.self) { Text("Aggravating: \($0)").font(.caption).foregroundStyle(Theme.prosecution) }
                ForEach(session.mitigatingFactors, id: \.self) { Text("Mitigating: \($0)").font(.caption).foregroundStyle(Theme.defense) }
            }
            .card()
        }
    }

    @ViewBuilder
    private var notesSection: some View {
        let entries = session.transcript
        if entries.isEmpty { empty("You haven't held a bench conference yet. What counsel tells you will appear here.") }
        ForEach(entries) { entry in TranscriptBubble(entry: entry) }
    }

    // MARK: Helpers

    private func empty(_ text: String) -> some View {
        Text(text).font(.callout).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
    }

    @ViewBuilder
    private func rulingLabel(_ text: String?) -> some View {
        Label(text ?? "Not yet ruled on.", systemImage: text == nil ? "hourglass" : "hammer.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(text == nil ? Color.secondary : Theme.gold)
    }

    private func status(of charge: Charge) -> String? {
        let r = session.rulings
        if r.dismissedByPlea.contains(charge.id) { return "Dismissed under the plea arrangement." }
        if r.halftime[charge.id] == .dismiss { return "You dismissed this count at the close of the State's evidence." }
        if r.halftime[charge.id] == .lesserOnly { return "You let this count proceed only on the lesser offense." }
        guard session.stage.rawValue > CaseSession.Stage.verdict.rawValue || r.pleaAccepted == true, let v = r.verdicts[charge.id] else { return nil }
        switch v {
        case .guilty: return "Verdict: guilty."
        case .lesser: return "Verdict: guilty of \(charge.lesserLaw?.title ?? "the lesser offense")."
        case .notGuilty: return "Verdict: not guilty."
        case .insanity: return "Verdict: not guilty by reason of insanity."
        }
    }
}

// MARK: - Investigation report and defendant profile

struct InvestigationReportView: View {
    let report: InvestigationReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(report.agency) · Report \(report.reportNumber)").font(.caption.monospaced()).foregroundStyle(.secondary)
                Text("Lead investigator: \(report.leadInvestigator)").font(.callout.weight(.semibold))
                Text("Incident: \(report.incident)").font(.callout)
            }
            group("The scene") { Text(report.scene).font(.callout) }
            group("Timeline") {
                ForEach(Array(report.timeline.enumerated()), id: \.offset) { _, entry in
                    HStack(alignment: .top, spacing: 8) {
                        Text(entry.when).font(.caption.weight(.bold)).foregroundStyle(Theme.gold).frame(width: 96, alignment: .leading)
                        Text(entry.what).font(.callout)
                    }
                }
            }
            group("How the defendant was identified") { Text(report.howIdentified).font(.callout) }
            group("People interviewed") { BulletList(items: report.interviews).font(.callout) }
            if !report.warrants.isEmpty {
                group("Search warrants") { BulletList(items: report.warrants).font(.callout) }
            }
            if !report.lab.isEmpty {
                group("Laboratory work") { BulletList(items: report.lab).font(.callout) }
            }
            group("Not done") {
                BulletList(items: report.notDone, symbol: "exclamationmark.circle.fill", color: .orange).font(.callout)
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased()).font(.caption2.weight(.heavy)).tracking(0.5).foregroundStyle(.secondary)
            content()
        }
    }
}

struct DefendantProfileView: View {
    let profile: DefendantProfile
    @State private var tab: Tab = .life

    enum Tab: String, CaseIterable, Identifiable {
        case life = "Life", work = "Work", education = "Education"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Profile", selection: $tab) {
                ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            switch tab {
            case .life:
                Label(profile.family, systemImage: "house.fill").font(.callout)
                Label(profile.residence, systemImage: "mappin.and.ellipse").font(.callout)
                Label(profile.income, systemImage: "dollarsign.circle").font(.callout)
            case .work:
                if profile.jobs.isEmpty {
                    Label("No work history", systemImage: "briefcase").font(.callout).foregroundStyle(.secondary)
                }
                ForEach(Array(profile.jobs.enumerated()), id: \.offset) { _, job in
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: job.title == "In custody" ? "lock.fill" : (job.current ? "briefcase.fill" : "briefcase"))
                            .foregroundStyle(job.current ? Theme.gold : .secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(job.title).font(.callout.weight(.semibold))
                            Text("\(job.employer) · \(job.years)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            case .education:
                // One line per school or credential, most recent last.
                ForEach(Array(educationLines.enumerated()), id: \.offset) { _, line in
                    Label(line, systemImage: "graduationcap.fill").font(.callout)
                }
            }
        }
    }

    private var educationLines: [String] {
        profile.education
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map { line in
                var text = line.prefix(1).uppercased() + line.dropFirst()
                if !text.hasSuffix(".") { text += "." }
                return text
            }
    }
}
