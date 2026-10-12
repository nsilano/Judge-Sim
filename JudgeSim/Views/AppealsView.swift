import SwiftUI

/// Row for an appeal in a list.
struct AppealRow: View {
    let appeal: AppealTracker
    let today: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(appeal.caption).font(.subheadline.weight(.semibold))
                Spacer()
                Pill(text: appeal.isPending ? "Pending" : (appeal.wasReversed ? "Reversed" : "Upheld"),
                     color: appeal.isPending ? Theme.gold : (appeal.wasReversed ? .orange : .green))
            }
            Text(appeal.docket).font(.caption.monospaced()).foregroundStyle(.secondary)
            Text(appeal.statusText(on: today)).font(.caption)
        }
    }
}

/// The life of one appeal: notice, briefs, argument, decision, and what came after.
struct AppealDetail: View {
    let appeal: AppealTracker
    let today: Date

    var body: some View {
        List {
            Section {
                Text(appeal.caption).font(.system(.headline, design: .serif))
                Text("\(appeal.docket) · North Carolina Court of Appeals").font(.caption.monospaced())
                Text("Appeal by \(appeal.appellant)").font(.callout)
                Text("Issue: \(appeal.issue)").font(.callout).foregroundStyle(.secondary)
            }
            Section("Timeline") {
                step("Notice of appeal filed", date: appeal.filed, done: true)
                step("Record on appeal and briefs due", date: appeal.briefsDue, done: today >= appeal.briefsDue || !appeal.isPending)
                if let argument = appeal.argument {
                    step("Oral argument before a three-judge panel in Raleigh", date: argument, done: today >= argument || !appeal.isPending)
                } else if !appeal.isPending || today >= appeal.briefsDue {
                    step("Submitted on the briefs, without oral argument", date: nil, done: true)
                } else {
                    step("Oral argument: not yet calendared", date: nil, done: false)
                }
                if let decided = appeal.decided {
                    step("Opinion filed: \(appeal.result ?? "Decided")", date: decided, done: true)
                } else {
                    step("Awaiting the court's opinion", date: nil, done: false)
                }
            }
            if let opinion = appeal.opinion {
                Section("The court's decision") {
                    Text(opinion).font(.callout)
                }
            }
            if !appeal.followUps.isEmpty {
                Section("Since the decision") {
                    ForEach(appeal.followUps, id: \.self) { Text($0).font(.callout) }
                }
            }
        }
        .navigationTitle("Appeal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func step(_ title: String, date: Date?, done: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(done ? Theme.gold : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.callout)
                if let date {
                    Text((done ? "" : "Scheduled: ") + CourtCalendar.dayTitle(date)).font(.caption).foregroundStyle(.secondary)
                }
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
            switch person.status {
            case .incarcerated:
                if let release = person.releaseDate {
                    if release == .distantFuture {
                        Text("Serving life imprisonment without parole.").font(.callout)
                    } else {
                        let days = max(0, Calendar.current.dateComponents([.day], from: today, to: release).day ?? 0)
                        Text("Projected release \(SentenceFormat.shortDate(release)), about \(duration(days)) from now.").font(.callout)
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
                        BulletList(items: conditions).font(.caption)
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
