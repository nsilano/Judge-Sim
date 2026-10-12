import SwiftUI

// The court file for one docket: each judgment the judge entered, rendered as the AOC form it would be
// filed on. Also the form naming used by the Records lists.

struct FormInfo: Hashable {
    var number: String?
    var title: String
    var subtitle: String?

    /// "AOC-CR-601 · Judgment and Commitment", for list rows.
    var indexLabel: String {
        [number, title].compactMap { $0 }.joined(separator: " · ")
    }
}

enum RecordForms {
    static func sentenceForm(_ entry: RecordEntry) -> FormInfo {
        switch (entry.isFelony, entry.isActive) {
        case (true, true):
            return FormInfo(number: "AOC-CR-601", title: "Judgment and Commitment",
                            subtitle: "Active Punishment – Felony (Structured Sentencing)")
        case (false, true):
            return FormInfo(number: "AOC-CR-602", title: "Judgment and Commitment",
                            subtitle: "Active Punishment – Non-DWI Misdemeanor")
        case (true, false):
            return FormInfo(number: "AOC-CR-603", title: "Judgment Suspending Sentence",
                            subtitle: "Felony – Community or Intermediate Punishment")
        case (false, false):
            return FormInfo(number: "AOC-CR-604", title: "Judgment Suspending Sentence",
                            subtitle: "Non-DWI Misdemeanor – Community or Intermediate Punishment")
        }
    }

    static let findings = FormInfo(number: "AOC-CR-605", title: "Felony Judgment Findings of Aggravating and Mitigating Factors",
                                   subtitle: "Structured Sentencing – G.S. 15A-1340.16")
    static let appealEntries = FormInfo(number: "AOC-CR-350", title: "Appeal Entries",
                                        subtitle: "Notice of appeal to the Court of Appeals")

    static func violationForm(_ record: CaseRecord) -> FormInfo {
        record.isRevocation
            ? FormInfo(number: "AOC-CR-607", title: "Judgment and Commitment upon Revocation of Probation",
                       subtitle: "G.S. 15A-1344, -1345")
            : FormInfo(number: "AOC-CR-609", title: "Order on Violation of Probation",
                       subtitle: "Probation continued, modified, or confinement in response to violation")
    }

    /// The form that heads a record's file, for list rows.
    static func primary(for record: CaseRecord) -> FormInfo {
        switch record.resolvedKind {
        case "hearing": return violationForm(record)
        case "calendar": return FormInfo(number: nil, title: "Calendar Call – Clerk's Minutes", subtitle: nil)
        case "continuance": return FormInfo(number: nil, title: "Order Continuing Case", subtitle: nil)
        default: break
        }
        let entries = record.recordEntries
        let sentences = entries.filter { $0.kind == .sentence }
        if let lead = sentences.first(where: { $0.isActive && $0.isFelony }) ?? sentences.first(where: \.isActive)
            ?? sentences.first(where: \.isFelony) ?? sentences.first {
            return sentenceForm(lead)
        }
        if entries.contains(where: { $0.kind == .prayerForJudgment }) {
            return FormInfo(number: nil, title: "Prayer for Judgment Continued", subtitle: nil)
        }
        if entries.contains(where: { $0.kind == .conditionalDischarge }) {
            return FormInfo(number: nil, title: "Order Deferring Proceedings – Conditional Discharge", subtitle: nil)
        }
        if record.outcome.hasPrefix("Dismissed") {
            return FormInfo(number: nil, title: "Order of Dismissal", subtitle: nil)
        }
        if record.outcome.hasPrefix("Not guilty") {
            return FormInfo(number: nil, title: "Verdict – Not Guilty", subtitle: nil)
        }
        return FormInfo(number: nil, title: "Judgment", subtitle: nil)
    }

    static func isPlea(_ record: CaseRecord) -> Bool {
        record.outcome.contains("plea") || record.outcome.contains("No contest")
    }
}

/// One row in the Records lists: caption, file number, and the form that heads the file.
struct DocketIndexRow: View {
    let record: CaseRecord
    var showDate = true

    var body: some View {
        let form = RecordForms.primary(for: record)
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline) {
                Text(record.docket)
                    .font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 6)
                if showDate {
                    Text(SentenceFormat.shortDate(record.date))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Text(record.caption)
                .font(.system(.subheadline, design: .serif).weight(.semibold))
            Text(form.indexLabel.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .tracking(0.4)
                .foregroundStyle(Theme.gold)
            Text(record.outcome)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let appeal = record.appealStatus {
                Label(appeal, systemImage: "building.columns.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: Case file

/// The filed documents for one record, with links to the defendant and any appeal.
struct CaseRecordDetail: View {
    @EnvironmentObject private var game: GameState
    let record: CaseRecord

    var body: some View {
        DocumentDesk {
            if record.returningDefendant {
                Label("Returning defendant: this person had appeared before you earlier.", systemImage: "arrow.uturn.left")
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
            CaseRecordDocuments(record: record)
            if let tracker = game.appeals.first(where: { $0.docket == record.docket }) {
                DeskLink(title: "Court of Appeals file", detail: "\(CourtForms.appealsNumber(for: tracker)) · \(tracker.statusText(on: game.currentDate))",
                         icon: "building.columns.fill") {
                    AppealDetail(appeal: tracker, today: game.currentDate)
                }
            }
            if record.resolvedKind != "calendar", let person = game.people.first(where: { $0.id == record.defendantID }) {
                DeskLink(title: "Full record: \(person.name)", detail: "\(person.status.label) · sentence, conditions, and history",
                         icon: "person.text.rectangle.fill") {
                    PersonDetail(person: person, today: game.currentDate)
                }
            }
        }
        .navigationTitle(record.docket)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Every form in one record's file, in the order the clerk would file them.
struct CaseRecordDocuments: View {
    @EnvironmentObject private var game: GameState
    let record: CaseRecord

    private var county: String { CourtForms.countyShortName(game.county) }
    private var signature: DocSignature { DocSignature(name: game.judgeName ?? "Presiding Judge", date: record.date) }
    private var filing: DocFiling { DocFiling(date: record.date, office: CourtForms.clerkOffice(game.county)) }
    private var person: PersonRecord? { game.people.first { $0.id == record.defendantID } }

    private var defendantName: String {
        if let person { return person.name }
        for prefix in ["State v. ", "Probation violation: "] where record.caption.hasPrefix(prefix) {
            return String(record.caption.dropFirst(prefix.count))
        }
        return record.caption
    }

    private var charges: String? {
        person?.appearances.first { $0.docket == record.docket && Calendar.current.isDate($0.date, inSameDayAs: record.date) }?.charges
            ?? person?.appearances.last { $0.docket == record.docket }?.charges
    }

    var body: some View {
        switch record.resolvedKind {
        case "hearing": violationDocument
        case "calendar": calendarDocument
        case "continuance": continuanceDocument
        default: trialDocuments
        }
    }

    // MARK: Trial

    @ViewBuilder
    private var trialDocuments: some View {
        let entries = record.recordEntries
        let sentences = entries.filter { $0.kind == .sentence }
        let commitment = entries.first { $0.kind == .commitment }
        let conditions = entries.first { $0.kind == .probationConditions }
        let money = entries.first { $0.kind == .money }
        let findings = entries.first { $0.kind == .findings }
        let firstActive = sentences.firstIndex(where: \.isActive)
        let firstSuspended = sentences.firstIndex(where: \.isSuspended)
        let moneyHome = firstSuspended ?? (sentences.isEmpty ? nil : 0)
        let others = entries.filter { $0.kind == .prayerForJudgment || $0.kind == .conditionalDischarge }
        let additional = entries.filter { $0.kind == .victimNotice || $0.kind == .note || $0.kind == .other }
            + ((moneyHome == nil && others.isEmpty) ? [money].compactMap { $0 } : [])

        verdictDocument

        ForEach(Array(sentences.enumerated()), id: \.offset) { index, entry in
            sentenceDocument(entry,
                             commitment: index == firstActive ? commitment : nil,
                             conditions: index == firstSuspended ? conditions : nil,
                             money: index == moneyHome ? money : nil,
                             findingsAttached: findings != nil && entry.isFelony)
        }

        if let findings {
            findingsDocument(findings)
        }

        ForEach(Array(others.enumerated()), id: \.offset) { _, entry in
            specialDispositionDocument(entry, money: moneyHome == nil ? money : nil)
        }

        if !additional.isEmpty {
            CourtDocument(caption: .superior(county: county), title: "Additional Orders and Entries",
                          fileNumber: record.docket, defendant: defendantName, signature: signature, filed: filing) {
                ForEach(Array(additional.enumerated()), id: \.offset) { _, entry in
                    entryBlock(entry)
                }
            }
        }

        appealEntries
    }

    private var verdictDocument: some View {
        let plea = RecordForms.isPlea(record)
        return CourtDocument(caption: .superior(county: county),
                             formNumber: plea ? "AOC-CR-300" : nil,
                             title: plea ? "Transcript of Plea – Adjudication" : "Verdict – Bench Trial",
                             subtitle: plea ? "The court accepts the plea and orders it recorded"
                                            : "Trial by jury waived (G.S. 15A-1201); tried before the court",
                             fileNumber: record.docket, defendant: defendantName, signature: signature, filed: filing) {
            if let charges {
                DocField(label: "Offense(s) charged", value: charges)
            }
            DocFieldPair(first: ("Date of adjudication", SentenceFormat.date(record.date)),
                         second: ("Session", "\(county) County Superior Court"))
            DocSection(title: plea ? "Plea and adjudication" : "Verdict of the court")
            ForEach(Array(dispositionParts.enumerated()), id: \.offset) { _, part in
                DocCheck(checked: true, text: part)
            }
            DocField(label: "Matter", value: record.headline)
        }
    }

    /// "Ct. 1 Guilty; Ct. 2 Not Guilty. Sentence…" split into readable pieces.
    private var dispositionParts: [String] {
        let parts = record.outcome.components(separatedBy: "; ").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return parts.isEmpty ? [record.outcome] : parts
    }

    private func sentenceDocument(_ entry: RecordEntry, commitment: RecordEntry?, conditions: RecordEntry?,
                                  money: RecordEntry?, findingsAttached: Bool) -> some View {
        let form = RecordForms.sentenceForm(entry)
        return CourtDocument(caption: .superior(county: county), formNumber: form.number, title: form.title,
                             subtitle: form.subtitle, fileNumber: record.docket, defendant: defendantName,
                             signature: signature, filed: filing) {
            Group {
                DocSection(title: "Offense")
                DocFieldPair(first: ("Count No.", entry.countLabel), second: ("Date of judgment", SentenceFormat.shortDate(record.date)))
                DocField(label: "Offense of conviction", value: entry.offense)
                if let classLine = entry.classLine {
                    DocField(label: "Class · prior record / conviction level", value: classLine)
                }
            }

            Group {
                DocSection(title: "Findings")
                if entry.isLife {
                    DocCheck(checked: true, text: "Sentence of life imprisonment without parole.")
                } else if entry.rangeLine == "Term set by the court" {
                    DocCheck(checked: true, text: "Term set by the court")
                } else {
                    ForEach(["Presumptive range", "Aggravated range", "Mitigated range"], id: \.self) { range in
                        DocCheck(checked: entry.rangeLine == range,
                                 text: "The court imposes a sentence from the \(range.lowercased()).")
                    }
                }
                if findingsAttached {
                    DocCheck(checked: true, text: "The court makes the findings of aggravating and mitigating factors set out on the attached AOC-CR-605.")
                }
            }

            Group {
                DocSection(title: entry.isActive ? "Judgment – Active punishment" : "Judgment – Sentence suspended")
                if let mm = entry.minimumMaximum {
                    DocFieldPair(first: ("Minimum term", "\(mm.minimum) months"), second: ("Maximum term", "\(mm.maximum) months"))
                }
                if let line = entry.sentenceLine {
                    DocText(line)
                }
                ForEach(Array(entry.otherLines.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
                if let prs = entry.postReleaseMonths {
                    DocCheck(checked: true, text: "Upon release, \(prs) months of post-release supervision (G.S. 15A-1368.2).")
                }
            }

            if let commitment {
                DocSection(title: "Commitment and recommendations")
                ForEach(Array(commitment.lines.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
            }
            if let conditions {
                DocSection(title: "Conditions of probation")
                ForEach(Array(conditions.lines.enumerated()), id: \.offset) { _, line in
                    DocCheck(checked: true, text: line)
                }
            }
            if let money {
                moneyBlock(money)
            }
        }
    }

    private func moneyBlock(_ money: RecordEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            DocSection(title: "Monetary conditions")
            ForEach(Array(money.lines.enumerated()), id: \.offset) { _, line in
                if let pair = RecordText.labelValue(line) {
                    DocTableRow(left: pair.value, right: pair.label, leftWidth: 74)
                } else {
                    DocText(line, italic: true)
                }
            }
        }
    }

    private func findingsDocument(_ entry: RecordEntry) -> some View {
        let aggravating = entry.lines.filter { $0.hasPrefix("Aggravating: ") }.map { String($0.dropFirst("Aggravating: ".count)) }
        let mitigating = entry.lines.filter { $0.hasPrefix("Mitigating: ") }.map { String($0.dropFirst("Mitigating: ".count)) }
        let weighing = entry.lines.filter { !$0.hasPrefix("Aggravating: ") && !$0.hasPrefix("Mitigating: ") }
        let form = RecordForms.findings
        return CourtDocument(caption: .superior(county: county), formNumber: form.number, title: form.title,
                             subtitle: form.subtitle, fileNumber: record.docket, defendant: defendantName,
                             signature: signature, filed: filing) {
            DocSection(title: "Aggravating factors")
            if aggravating.isEmpty {
                DocCheck(checked: false, text: "None found")
            }
            ForEach(Array(aggravating.enumerated()), id: \.offset) { _, line in
                DocCheck(checked: true, text: line)
            }
            DocSection(title: "Mitigating factors")
            if mitigating.isEmpty {
                DocCheck(checked: false, text: "None found")
            }
            ForEach(Array(mitigating.enumerated()), id: \.offset) { _, line in
                DocCheck(checked: true, text: line)
            }
            DocSection(title: "Weighing")
            ForEach(Array(weighing.enumerated()), id: \.offset) { _, line in
                DocText(line)
            }
        }
    }

    private func specialDispositionDocument(_ entry: RecordEntry, money: RecordEntry?) -> some View {
        let isPJC = entry.kind == .prayerForJudgment
        return CourtDocument(caption: .superior(county: county),
                             title: isPJC ? "Prayer for Judgment Continued" : "Order Deferring Further Proceedings",
                             subtitle: isPJC ? nil : (entry.title ?? "Conditional discharge"),
                             fileNumber: record.docket, defendant: defendantName, signature: signature, filed: filing) {
            DocSection(title: "It is ordered")
            ForEach(Array(entry.lines.enumerated()), id: \.offset) { index, line in
                DocNumbered(number: index + 1, text: line)
            }
            if let money {
                moneyBlock(money)
            }
        }
    }

    @ViewBuilder
    private func entryBlock(_ entry: RecordEntry) -> some View {
        if entry.kind == .money {
            moneyBlock(entry)
        } else {
            if let title = entry.title {
                DocSection(title: title)
            }
            ForEach(Array(entry.lines.enumerated()), id: \.offset) { _, line in
                DocCheck(checked: true, text: line)
            }
        }
    }

    @ViewBuilder
    private var appealEntries: some View {
        if let tracker = game.appeals.first(where: { $0.docket == record.docket }) {
            let form = RecordForms.appealEntries
            CourtDocument(caption: .superior(county: county), formNumber: form.number, title: form.title,
                          subtitle: form.subtitle, fileNumber: record.docket, defendant: defendantName,
                          signature: DocSignature(name: game.judgeName ?? "Presiding Judge", date: tracker.filed),
                          filed: DocFiling(date: tracker.filed, office: CourtForms.clerkOffice(game.county))) {
                DocCheck(checked: true, text: "Notice of appeal to the North Carolina Court of Appeals given by \(tracker.appellant).")
                DocFieldPair(first: ("Judgment entered", SentenceFormat.shortDate(record.date)),
                             second: ("Notice filed", SentenceFormat.shortDate(tracker.filed)))
                DocField(label: "Issue to be raised on appeal", value: tracker.issue)
                DocField(label: "Court of Appeals No.", value: CourtForms.appealsNumber(for: tracker), monospaced: true)
                DocField(label: "Present status", value: tracker.statusText(on: game.currentDate))
            }
        } else if let status = record.appealStatus {
            CourtDocument(caption: .superior(county: county), formNumber: RecordForms.appealEntries.number,
                          title: RecordForms.appealEntries.title, fileNumber: record.docket, defendant: defendantName) {
                DocCheck(checked: true, text: "Notice of appeal to the North Carolina Court of Appeals.")
                DocField(label: "Present status", value: status)
            }
        }
    }

    // MARK: Hearings and calendars

    private var violationDocument: some View {
        let form = RecordForms.violationForm(record)
        return VStack(alignment: .leading, spacing: 18) {
            CourtDocument(caption: .superior(county: county), formNumber: form.number, title: form.title,
                          subtitle: form.subtitle, fileNumber: record.docket, defendant: defendantName,
                          signature: signature, filed: filing) {
                DocFieldPair(first: ("Original judgment", record.baseDocket), second: ("Hearing date", SentenceFormat.shortDate(record.date)))
                DocSection(title: "Findings and judgment")
                ForEach(Array(record.judgments.enumerated()), id: \.offset) { index, line in
                    DocNumbered(number: index + 1, text: line)
                }
                DocField(label: "Disposition", value: record.outcome)
            }
            appealEntries
        }
    }

    private var calendarDocument: some View {
        CourtDocument(caption: .superior(county: county), title: "Administrative Calendar",
                      subtitle: "Clerk's minutes of matters called", fileNumber: SentenceFormat.shortDate(record.date),
                      signature: signature, filed: filing) {
            DocField(label: "Matters on the calendar", value: record.headline)
            DocSection(title: "Minutes")
            ForEach(Array(record.judgments.enumerated()), id: \.offset) { _, line in
                CalendarMinuteRow(line: line)
            }
        }
    }

    private var continuanceDocument: some View {
        CourtDocument(caption: .superior(county: county), title: "Order Continuing Case",
                      fileNumber: record.docket, defendant: defendantName, signature: signature, filed: filing) {
            DocField(label: "Matter", value: record.headline)
            DocCheck(checked: true, text: record.outcome)
            DocSection(title: "Reason")
            ForEach(Array(record.judgments.enumerated()), id: \.offset) { _, line in
                DocText(line)
            }
        }
    }
}

/// One line of calendar-call minutes: "26 CR 001234 · Name · Matter: Action." or a follow-on order.
struct CalendarMinuteRow: View {
    let line: String

    var body: some View {
        let parts = line.components(separatedBy: " · ")
        if parts.count >= 3 {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(parts[1]).font(DocInk.serif(.callout, weight: .semibold))
                    Spacer(minLength: 6)
                    Text(parts[0]).font(.system(.caption2, design: .monospaced)).foregroundStyle(DocInk.faint)
                }
                Text(parts.dropFirst(2).joined(separator: " · "))
                    .font(DocInk.serif(.callout))
                    .fixedSize(horizontal: false, vertical: true)
                Rectangle().fill(DocInk.rule.opacity(0.6)).frame(height: 0.5)
            }
        } else {
            DocCheck(checked: true, text: line)
        }
    }
}
