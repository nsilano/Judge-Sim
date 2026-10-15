import SwiftUI

/// Row for an appeal in a list.
struct AppealRow: View {
    let appeal: AppealTracker
    let today: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(appeal.caption).font(.system(.subheadline, design: .serif).weight(.semibold))
                Spacer()
                Pill(text: appeal.isPending ? "Pending" : (appeal.wasReversed ? "Reversed" : "Upheld"),
                     color: appeal.isPending ? Theme.gold : (appeal.wasReversed ? .orange : .green))
            }
            Text("\(CourtForms.appealsNumber(for: appeal)) · from \(appeal.docket)")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Text(appeal.statusText(on: today)).font(.caption)
        }
    }
}

/// The Court of Appeals file for one appeal: the notice of appeal, the appellate docket sheet,
/// the opinion, and what happened after.
struct AppealDetail: View {
    @EnvironmentObject private var game: GameState
    let appeal: AppealTracker
    let today: Date

    private var county: String { CourtForms.countyShortName(game.county) }
    private var coaNumber: String { CourtForms.appealsNumber(for: appeal) }
    private var trialRecord: CaseRecord? { game.history.first { $0.docket == appeal.docket } }
    private var person: PersonRecord? { game.people.first { $0.id == appeal.personID } }
    private var defendantName: String {
        if let person { return person.name }
        return appeal.caption.hasPrefix("State v. ") ? String(appeal.caption.dropFirst("State v. ".count)) : appeal.caption
    }
    private var appellantTitle: String {
        appeal.appellant.hasPrefix("the ") ? String(appeal.appellant.dropFirst(4)) : appeal.appellant
    }
    /// "Defendant", "State", or "Probationer".
    private var appellantLabel: String { appellantTitle.prefix(1).uppercased() + appellantTitle.dropFirst() }

    var body: some View {
        DocumentDesk {
            DeskLabel(text: "Status", icon: "building.columns.fill")
            statusCard
            DeskLabel(text: "Superior Court", icon: "doc.text.fill")
            noticeDocument
            DeskLabel(text: "Court of Appeals", icon: "building.columns.fill")
            docketSheet
            if appeal.decided != nil {
                opinionDocument
            }
            if !appeal.followUps.isEmpty {
                DeskLabel(text: "After the decision", icon: "arrow.turn.down.right")
                followUpDocument
            }
            if let trialRecord {
                DeskLink(title: "Trial court file · \(trialRecord.docket)",
                         detail: RecordForms.primary(for: trialRecord).indexLabel, icon: "doc.text.fill") {
                    CaseRecordDetail(record: trialRecord)
                }
            }
            if let person {
                DeskLink(title: "Full record: \(person.name)", detail: person.status.label, icon: "person.text.rectangle.fill") {
                    PersonDetail(person: person, today: game.currentDate)
                }
            }
        }
        .navigationTitle(coaNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(appeal.caption).font(.system(.headline, design: .serif))
                Spacer()
                Pill(text: appeal.isPending ? "Pending" : (appeal.wasReversed ? "Reversed" : "Upheld"),
                     color: appeal.isPending ? Theme.gold : (appeal.wasReversed ? .orange : .green))
            }
            Text("Appeal by \(appeal.appellant)").font(.callout)
            Text(appeal.statusText(on: today)).font(.callout.weight(.semibold))
            Text("Issue: \(appeal.issue)").font(.caption).foregroundStyle(.secondary)
        }
        .card(tint: appeal.isPending ? Theme.gold : (appeal.wasReversed ? .orange : .green))
    }

    private var noticeDocument: some View {
        CourtDocument(caption: .superior(county: county), formNumber: RecordForms.appealEntries.number,
                      title: RecordForms.appealEntries.title, subtitle: "Notice of appeal",
                      fileNumber: appeal.docket, defendant: defendantName,
                      signature: DocSignature(name: game.judgeName ?? "Presiding Judge", date: appeal.filed),
                      filed: DocFiling(date: appeal.filed, office: CourtForms.clerkOffice(game.county))) {
            DocCheck(checked: true, text: "\(appellantLabel) gives notice of appeal to the North Carolina Court of Appeals from the judgment entered in this case.")
            DocFieldPair(first: ("Judgment entered", trialRecord.map { SentenceFormat.shortDate($0.date) } ?? "—"),
                         second: ("Notice filed", SentenceFormat.shortDate(appeal.filed)))
            DocField(label: "Appellant", value: appellantLabel)
            DocField(label: "Issue to be raised on appeal", value: appeal.issue)
            DocCheck(checked: true, text: "The Clerk shall transmit the record to the Court of Appeals.")
        }
    }

    private var docketSheet: some View {
        CourtDocument(caption: .appeals(county: county, trialFile: appeal.docket), title: "Docket Sheet",
                      subtitle: "State of North Carolina v. \(defendantName)", fileNumber: coaNumber) {
            DocSection(title: "Proceedings")
            DocCheck(checked: true, text: "Notice of appeal filed in the trial division",
                     detail: SentenceFormat.date(appeal.filed))
            DocCheck(checked: today >= appeal.briefsDue || !appeal.isPending,
                     text: "Record on appeal settled and filed; briefs of the parties due",
                     detail: (today >= appeal.briefsDue || !appeal.isPending ? "" : "Due ") + SentenceFormat.date(appeal.briefsDue))
            if let argument = appeal.argument {
                DocCheck(checked: today >= argument || !appeal.isPending,
                         text: "Oral argument before a three-judge panel in Raleigh",
                         detail: (today >= argument || !appeal.isPending ? "Heard " : "Calendared for ") + SentenceFormat.date(argument))
            } else if !appeal.isPending || today >= appeal.briefsDue {
                DocCheck(checked: true, text: "Submitted on the record and briefs without oral argument")
            } else {
                DocCheck(checked: false, text: "Oral argument: not yet calendared")
            }
            if let decided = appeal.decided {
                DocCheck(checked: true, text: "Opinion filed: \(appeal.result ?? "Decided")", detail: SentenceFormat.date(decided))
            } else {
                DocCheck(checked: false, text: "Opinion of the Court", detail: "Awaiting decision")
            }
            DocField(label: "Present status", value: appeal.statusText(on: today))
        }
    }

    /// The disposition line that closes an opinion.
    private var disposition: String {
        let result = appeal.result ?? ""
        if result.contains("resentencing") { return "VACATED AND REMANDED FOR RESENTENCING." }
        if result.contains("New trial") { return "NEW TRIAL." }
        if result.contains("Conviction vacated") { return "VACATED." }
        if result.contains("reinstated") || result.contains("reversed") { return "REVERSED AND REMANDED." }
        if result.contains("Appeal dismissed") { return "DISMISSED." }
        if result.contains("Probation order vacated") { return "VACATED AND REMANDED." }
        let trialAppeal = appeal.appellant == "the defendant" && !appeal.docket.contains("(PV)") && !(trialRecord.map(RecordForms.isPlea) ?? false)
        return trialAppeal ? "NO ERROR." : "AFFIRMED."
    }

    private var opinionDocument: some View {
        let decided = appeal.decided ?? today
        let heard = appeal.argument.map { "Heard in the Court of Appeals \(SentenceFormat.date($0))." }
            ?? "Submitted without oral argument."
        let entered = trialRecord.map { "judgment entered \(SentenceFormat.date($0.date))" } ?? "the judgment entered"
        let judge = game.judgeName.map { " by Judge \($0)" } ?? ""
        return CourtDocument(caption: .appeals(county: county, trialFile: appeal.docket), title: "Opinion",
                             fileNumber: coaNumber,
                             filed: DocFiling(date: decided, office: "N.C. Court of Appeals")) {
            DocField(label: "Filed", value: SentenceFormat.date(decided))
            VStack(spacing: 2) {
                Text("STATE OF NORTH CAROLINA").font(DocInk.serif(.callout, weight: .semibold))
                Text("v.").font(DocInk.serif(.callout)).italic()
                Text("\(defendantName.uppercased()), \(appeal.docket.contains("(PV)") ? "Probationer" : "Defendant").")
                    .font(DocInk.serif(.callout, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            DocText("Appeal by \(appeal.appellant) from \(entered)\(judge) in \(county) County Superior Court. \(heard)", italic: true)
            DocRule()
            DocField(label: "Issue presented", value: appeal.issue)
            if let opinion = appeal.opinion {
                ForEach(Array(paragraphs(opinion).enumerated()), id: \.offset) { _, paragraph in
                    DocText(paragraph)
                }
            }
            DocField(label: "Holding", value: appeal.result ?? "Decided")
            Text(disposition)
                .font(DocInk.serif(.body, weight: .bold))
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
        }
    }

    private func paragraphs(_ text: String) -> [String] {
        let parts = text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return parts.isEmpty ? [text] : parts
    }

    private var followUpDocument: some View {
        CourtDocument(caption: .superior(county: county), title: "Subsequent Proceedings",
                      subtitle: "After the mandate of the Court of Appeals", fileNumber: appeal.docket, defendant: defendantName) {
            ForEach(Array(appeal.followUps.enumerated()), id: \.offset) { index, line in
                DocNumbered(number: index + 1, text: line)
            }
        }
    }
}

/// Where a person stands right now: custody, probation, court dates, and appeals.
struct PersonStatusCard: View {
    let person: PersonRecord
    let today: Date
    let appeals: [AppealTracker]
    let upcoming: [ScheduledMatter]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(person.status.label, systemImage: icon).font(.headline).foregroundStyle(color)
            Text("\(NameBank.gender(of: person.name).label) · age \(person.age(on: today)) · \(person.occupation)")
                .font(.caption).foregroundStyle(.secondary)
            switch person.status {
            case .incarcerated:
                if let release = person.releaseDate {
                    if release == .distantFuture {
                        Text("Serving life imprisonment without parole.").font(.callout)
                    } else {
                        let days = max(0, Calendar.current.dateComponents([.day], from: today, to: release).day ?? 0)
                        Text("Projected release \(SentenceFormat.shortDate(release)), about \(duration(days)) from now.").font(.callout)
                        if let note = person.releaseNote {
                            Text(note).font(.caption).foregroundStyle(.secondary)
                        }
                        if person.probation != nil {
                            Text("Probation begins on release.").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            case .probation:
                if let term = person.probation {
                    let days = max(0, Calendar.current.dateComponents([.day], from: today, to: term.ends).day ?? 0)
                    Text("\((term.supervised ?? true) ? "Supervised" : "Unsupervised") probation in \(term.docket) for \(term.offense), ending \(SentenceFormat.shortDate(term.ends)) (\(duration(days)) left).")
                        .font(.callout)
                    Text("Suspended sentence: \(term.suspendedSentence)" + ((term.crvCount ?? 0) > 0 ? " · \(term.crvCount ?? 0) CRV so far" : ""))
                        .font(.caption).foregroundStyle(.secondary)
                    if let monthly = term.monthlyObligation, monthly > 0 {
                        Text("Pays about \(SentenceFormat.dollars(monthly)) a month toward money owed.").font(.caption).foregroundStyle(.secondary)
                    }
                    if let conditions = term.conditions, !conditions.isEmpty {
                        Text("\(conditions.count) special condition\(conditions.count == 1 ? "" : "s"); see the conditions of probation below.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Text(term.imposedInThisCourt ? "You imposed this sentence." : (term.origin ?? "Sentenced in another court."))
                        .font(.caption).foregroundStyle(term.imposedInThisCourt ? .purple : .secondary)
                }
            case .free:
                Text("No sentence being served.").font(.callout)
            }
            ForEach(upcoming) { item in
                Label("Back in court \(SentenceFormat.shortDate(item.date)): \(item.entry.note ?? "continued matter")", systemImage: "calendar")
                    .font(.caption).foregroundStyle(.purple)
            }
            ForEach(appeals) { appeal in
                Label("Appeal in \(appeal.docket): \(appeal.statusText(on: today))", systemImage: "building.columns.fill")
                    .font(.caption).foregroundStyle(appeal.isPending ? Theme.gold : .secondary)
            }
        }
    }

    private var icon: String {
        switch person.status {
        case .incarcerated: return "lock.fill"
        case .probation: return "person.badge.clock.fill"
        case .free: return "figure.walk"
        }
    }

    private var color: Color {
        switch person.status {
        case .incarcerated: return .red
        case .probation: return .orange
        case .free: return .green
        }
    }

    private func duration(_ days: Int) -> String {
        if days >= 730 { return "\(days / 365) years" }
        if days >= 60 { return "\(days / 30) months" }
        return "\(days) day\(days == 1 ? "" : "s")"
    }
}
