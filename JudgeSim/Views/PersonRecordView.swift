import SwiftUI

/// A person's full file: identity and status, the active sentence with everything ordered for custody,
/// probation with every condition, the criminal record, every judgment this court entered, appearances,
/// appeals, and news.
struct PersonDetail: View {
    @EnvironmentObject private var game: GameState
    let person: PersonRecord
    let today: Date

    var body: some View {
        let current = game.people.first { $0.id == person.id } ?? person
        let file = PersonFile(person: current, history: game.history, appeals: game.appeals, news: game.news,
                              scheduled: game.scheduled, today: game.currentDate)
        DocumentDesk {
            PersonStatusCard(person: current, today: game.currentDate, appeals: file.appeals, upcoming: file.upcoming)
                .card(tint: statusTint(current.status))
            PersonFileDocuments(file: file)
        }
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusTint(_ status: PersonRecord.Status) -> Color? {
        switch status {
        case .incarcerated: return .red
        case .probation: return .orange
        case .free: return nil
        }
    }
}

struct PersonFileDocuments: View {
    @EnvironmentObject private var game: GameState
    let file: PersonFile

    private var person: PersonRecord { file.person }
    private var county: String { CourtForms.countyShortName(game.county) }
    private var judge: String { game.judgeName ?? "Presiding Judge" }
    private var leadFile: String { file.records.first?.docket ?? person.appearances.last?.docket ?? "—" }

    var body: some View {
        DeskLabel(text: "Defendant", icon: "person.text.rectangle.fill")
        identityDocument

        if let active = file.activeSentence {
            DeskLabel(text: "Active sentence", icon: "lock.fill")
            activeDocument(active)
        }

        if let term = person.probation {
            DeskLabel(text: person.status == .incarcerated ? "Probation to follow release" : "Probation", icon: "person.badge.clock.fill")
            probationDocument(term)
        }

        DeskLabel(text: "Criminal record", icon: "list.bullet.rectangle.portrait.fill")
        criminalHistoryDocument

        if !file.records.isEmpty || !file.calendarLines.isEmpty {
            DeskLabel(text: "Judgments you entered", icon: "hammer.fill")
            judgmentsDocument
            ForEach(file.records) { record in
                DeskLink(title: "Filed forms · \(record.docket)",
                         detail: "\(RecordForms.primary(for: record).indexLabel) · \(SentenceFormat.shortDate(record.date))",
                         icon: "doc.text.fill") {
                    CaseRecordDetail(record: record)
                }
            }
        }

        if !person.appearances.isEmpty {
            DeskLabel(text: "Appearances", icon: "calendar")
            appearancesDocument
        }

        if !file.appeals.isEmpty {
            DeskLabel(text: "Appeals", icon: "building.columns.fill")
            ForEach(file.appeals) { appeal in
                DeskLink(title: "\(CourtForms.appealsNumber(for: appeal)) · \(appeal.docket)",
                         detail: appeal.statusText(on: game.currentDate), icon: "building.columns.fill") {
                    AppealDetail(appeal: appeal, today: game.currentDate)
                }
            }
        }

        if !file.news.isEmpty {
            DeskLabel(text: game.county?.newspaper ?? "In the news", icon: "newspaper.fill")
            ForEach(file.news) { item in
                NewsClipping(item: item)
            }
        }
    }

    // MARK: Identity and status

    private var identityDocument: some View {
        CourtDocument(caption: .superior(county: county), title: "Defendant Information",
                      subtitle: "Identity, custody, and status as of \(SentenceFormat.date(file.today))",
                      fileNumber: leadFile, defendant: person.name) {
            DocFieldPair(first: ("Year of birth", String(person.birthYear)),
                         second: ("Age", "\(person.age(on: file.today))"))
            DocField(label: "Occupation", value: person.occupation)
            DocField(label: "Background", value: person.background)

            DocSection(title: "Present status")
            DocCheck(checked: person.status == .incarcerated, text: "In custody")
            DocCheck(checked: person.status == .probation || (person.status == .incarcerated && person.probation != nil),
                     text: person.status == .incarcerated && person.probation != nil ? "Probation to begin on release" : "On probation")
            DocCheck(checked: person.status == .free, text: "At liberty")
            DocField(label: "Custody / supervision", value: file.custodyLine)
            if person.status == .incarcerated, let release = person.releaseDate {
                DocField(label: "Projected release",
                         value: release == .distantFuture ? "None – life imprisonment without parole" : SentenceFormat.date(release))
            }
            if let term = person.probation {
                DocField(label: "Probation ends", value: "\(SentenceFormat.date(term.ends)) (\(term.docket))")
            }
        }
    }

    // MARK: Active sentence

    private func activeDocument(_ active: ActiveSentenceSummary) -> some View {
        let fromThisCourt = file.records.contains { $0.docket == active.docket }
        return CourtDocument(caption: .superior(county: county),
                             formNumber: active.terms.contains(where: \.isFelony) ? "AOC-CR-601" : (active.terms.isEmpty ? nil : "AOC-CR-602"),
                             title: "Commitment Summary", subtitle: active.source,
                             fileNumber: active.docket, defendant: person.name,
                             signature: fromThisCourt ? DocSignature(name: judge, date: active.date) : nil,
                             filed: fromThisCourt ? DocFiling(date: active.date, office: CourtForms.clerkOffice(game.county)) : nil) {
            DocFieldPair(first: ("Committed", SentenceFormat.shortDate(active.date)), second: ("Custody", active.custody))

            ForEach(Array(active.terms.enumerated()), id: \.offset) { _, term in
                DocSection(title: term.title ?? "Sentence")
                if let classLine = term.classLine { DocText(classLine, italic: true) }
                if let mm = term.minimumMaximum {
                    DocFieldPair(first: ("Minimum", "\(mm.minimum) months"), second: ("Maximum", "\(mm.maximum) months"))
                }
                if let line = term.sentenceLine { DocText(line) }
                ForEach(Array(term.otherLines.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
            }

            if !active.revocationLines.isEmpty {
                DocSection(title: "Order of the court")
                ForEach(Array(active.revocationLines.enumerated()), id: \.offset) { index, line in
                    DocNumbered(number: index + 1, text: line)
                }
            }

            Group {
                DocSection(title: "Release")
                if let release = person.releaseDate {
                    DocField(label: "Projected release date",
                             value: release == .distantFuture ? "None – life imprisonment without parole" : SentenceFormat.date(release))
                }
                if let prs = active.postReleaseMonths {
                    DocCheck(checked: true, text: "\(prs) months of post-release supervision after release (G.S. 15A-1368.2). Conditions are set by the Post-Release Supervision and Parole Commission.")
                }
                ForEach(Array(active.advancedSupervisedRelease.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
                if let term = person.probation {
                    DocCheck(checked: true, text: "On release, supervised probation begins in \(term.docket) (see the conditions of probation).")
                }
            }

            Group {
                DocSection(title: "Credits and recommendations to custody")
                let other = active.commitment.filter { !active.recommendations.contains($0) && !$0.contains("post-release supervision") }
                ForEach(Array(other.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
                if active.recommendations.isEmpty {
                    DocCheck(checked: false, text: "No program recommendations were made with this judgment.")
                }
                ForEach(Array(active.recommendations.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
            }
        }
    }

    // MARK: Probation

    private func probationDocument(_ term: ProbationTerm) -> some View {
        let record = file.probationRecord
        let entries = record?.recordEntries ?? []
        let suspended = entries.filter { $0.kind == .sentence && $0.isSuspended }
        let money = entries.first { $0.kind == .money }
        let supervised = term.supervised ?? true
        return CourtDocument(caption: .superior(county: county),
                             formNumber: term.isFelony ? "AOC-CR-603" : "AOC-CR-604",
                             title: "Judgment Suspending Sentence",
                             subtitle: "Conditions of probation – \(term.isFelony ? "Felony" : "Misdemeanor")",
                             fileNumber: term.docket, defendant: person.name,
                             signature: term.imposedInThisCourt ? DocSignature(name: judge, date: record?.date ?? file.today) : nil,
                             filed: (term.imposedInThisCourt && record != nil) ? DocFiling(date: record?.date ?? file.today, office: CourtForms.clerkOffice(game.county)) : nil) {
            Group {
                DocField(label: "Offense", value: term.offense)
                DocFieldPair(first: ("Suspended sentence", term.suspendedSentence),
                             second: ("Probation ends", SentenceFormat.shortDate(term.ends)))
                ForEach(Array(suspended.enumerated()), id: \.offset) { _, entry in
                    if let line = entry.sentenceLine {
                        DocField(label: entry.countLabel, value: line)
                    }
                }
                if !term.imposedInThisCourt {
                    DocField(label: "Sentencing court", value: term.origin ?? "Sentenced in another court")
                }
            }

            Group {
                DocSection(title: "Supervision")
                DocCheck(checked: supervised, text: "Supervised probation")
                DocCheck(checked: !supervised, text: "Unsupervised probation")
                if person.status == .incarcerated {
                    DocCheck(checked: true, text: "Probation begins when the defendant is released from the active sentence.")
                }
                if let crv = term.crvCount, crv > 0 {
                    DocCheck(checked: true, text: "\(crv) period\(crv == 1 ? "" : "s") of confinement in response to violation served (G.S. 15A-1344(d2)).")
                }
            }

            Group {
                DocSection(title: "Regular conditions – G.S. 15A-1343(b)")
                ForEach(PersonFile.regularConditions(supervised: supervised), id: \.self) { line in
                    DocCheck(checked: true, text: line)
                }
            }

            Group {
                DocSection(title: "Special conditions – G.S. 15A-1343(b1)")
                let special = term.conditions ?? []
                if special.isEmpty {
                    DocCheck(checked: false, text: "No special conditions ordered.")
                }
                ForEach(Array(special.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
            }

            Group {
                DocSection(title: "Monetary conditions")
                if let money {
                    ForEach(Array(money.lines.enumerated()), id: \.offset) { _, line in
                        if let pair = RecordText.labelValue(line) {
                            DocTableRow(left: pair.value, right: pair.label, leftWidth: 74)
                        } else {
                            DocText(line, italic: true)
                        }
                    }
                }
                if let monthly = term.monthlyObligation, monthly > 0 {
                    DocField(label: "Payment schedule", value: "\(SentenceFormat.dollars(monthly)) per month to the Clerk of Superior Court")
                } else if money == nil {
                    DocCheck(checked: false, text: "No monetary obligations recorded.")
                }
            }
        }
    }

    // MARK: Criminal record

    private var criminalHistoryDocument: some View {
        let record = file.priorRecord
        let priors = person.priors.sorted { $0.year > $1.year }
        return CourtDocument(caption: .agency("Criminal history summary"), formNumber: "AOC-CR-600 (worksheet)",
                             title: "Criminal Record", subtitle: "Convictions on file, most recent first",
                             fileNumber: String(person.id.uuidString.prefix(8)), defendant: person.name) {
            DocSection(title: "Convictions")
            if priors.isEmpty {
                DocCheck(checked: false, text: "No prior convictions.")
            }
            ForEach(priors) { prior in
                DocTableRow(left: String(prior.year),
                            right: prior.offense + (prior.fromThisCourt ? "  ✦" : ""),
                            detail: [prior.ncClass.label, prior.county, prior.sentence, prior.docket].compactMap { $0 }.joined(separator: " · "),
                            leftWidth: 40)
            }
            if priors.contains(where: \.fromThisCourt) {
                DocText("✦ Judgment entered in your court.", italic: true)
            }

            DocSection(title: "Prior record level (if sentenced today)")
            ForEach(Array(record.lines.enumerated()), id: \.offset) { _, line in
                DocTableRow(left: "\(line.points) pt\(line.points == 1 ? "" : "s")", right: line.text, leftWidth: 40)
            }
            DocFieldPair(first: ("Total points", "\(record.points)"),
                         second: ("Felony prior record level", SentenceFormat.romanLevels[max(0, min(5, record.felonyLevel - 1))]))
            DocField(label: "Misdemeanor prior conviction level", value: SentenceFormat.romanLevels[max(0, min(2, record.misdemeanorLevel - 1))])
            DocText("Before any point for the new offense's elements or for being on supervision when it was committed.", italic: true)
        }
    }

    // MARK: Judgments

    private var judgmentsDocument: some View {
        CourtDocument(caption: .superior(county: county), title: "Register of Judgments",
                      subtitle: "Every judgment and order you entered for this defendant",
                      fileNumber: leadFile, defendant: person.name) {
            ForEach(file.records) { record in
                VStack(alignment: .leading, spacing: 8) {
                    DocSection(title: "\(record.docket) · \(SentenceFormat.shortDate(record.date))")
                    Text(RecordForms.primary(for: record).indexLabel.uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .serif))
                        .foregroundStyle(DocInk.faint)
                    DocField(label: "Disposition", value: record.outcome)
                    ForEach(Array(record.recordEntries.enumerated()), id: \.offset) { _, entry in
                        if let title = entry.title {
                            Text(title)
                                .font(DocInk.serif(.callout, weight: .semibold))
                        }
                        ForEach(Array(entry.lines.enumerated()), id: \.offset) { _, line in
                            DocCheck(checked: true, text: line)
                        }
                    }
                    if let appeal = record.appealStatus {
                        DocField(label: "Appeal", value: appeal)
                    }
                }
            }
            ForEach(Array(file.calendarLines.enumerated()), id: \.offset) { _, minutes in
                VStack(alignment: .leading, spacing: 8) {
                    DocSection(title: "Calendar call · \(SentenceFormat.shortDate(minutes.date))")
                    ForEach(Array(minutes.lines.enumerated()), id: \.offset) { _, line in
                        CalendarMinuteRow(line: line)
                    }
                }
            }
        }
    }

    // MARK: Appearances

    private var appearancesDocument: some View {
        CourtDocument(caption: .superior(county: county), title: "Register of Actions",
                      subtitle: "Appearances in \(county) County Superior Court",
                      fileNumber: leadFile, defendant: person.name) {
            ForEach(Array(person.appearances.reversed().enumerated()), id: \.offset) { _, appearance in
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(SentenceFormat.shortDate(appearance.date))
                            .font(.system(.caption, design: .monospaced).weight(.semibold))
                        Spacer(minLength: 6)
                        Text(appearance.docket)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(DocInk.faint)
                    }
                    Text(appearance.charges)
                        .font(DocInk.serif(.callout, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(appearance.outcome)
                        .font(DocInk.serif(.callout))
                        .fixedSize(horizontal: false, vertical: true)
                    Rectangle().fill(DocInk.rule.opacity(0.6)).frame(height: 0.5)
                }
            }
        }
    }
}

/// A newspaper clipping on the desk.
struct NewsClipping: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label(SentenceFormat.shortDate(item.date), systemImage: item.kind.icon)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if let placement = item.placement {
                    Text(placement.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(.secondary)
                }
            }
            Text(item.headline)
                .font(.system(.headline, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            Text(item.body)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let docket = item.docket {
                Text(docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
        }
        .card()
    }
}
