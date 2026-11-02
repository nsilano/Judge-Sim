import SwiftUI

/// Which people a list shows.
enum PeopleFilter: String, CaseIterable, Identifiable {
    case all, custody, probation, postRelease, free, returning, violations, appeals, exonerated

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "Everyone"
        case .custody: return "In custody"
        case .probation: return "On probation"
        case .postRelease: return "Post-release"
        case .free: return "At liberty"
        case .returning: return "Returning"
        case .violations: return "Violations"
        case .appeals: return "Appeal pending"
        case .exonerated: return "Exonerated"
        }
    }

    var icon: String {
        switch self {
        case .all: return "person.3.fill"
        case .custody: return "lock.fill"
        case .probation: return "person.badge.clock.fill"
        case .postRelease: return "figure.walk.departure"
        case .free: return "figure.walk"
        case .returning: return "arrow.uturn.left"
        case .violations: return "exclamationmark.triangle.fill"
        case .appeals: return "building.columns.fill"
        case .exonerated: return "lock.open.fill"
        }
    }

    @MainActor
    func includes(_ p: PersonRecord, game: GameState) -> Bool {
        switch self {
        case .all: return true
        case .custody: return p.status == .incarcerated
        case .probation: return p.status == .probation
        case .postRelease: return p.postRelease != nil && p.status != .incarcerated
        case .free: return p.status == .free && p.postRelease == nil
        case .returning: return Set(p.appearances.map { $0.docket.replacingOccurrences(of: " (PV)", with: "") }).count > 1
        case .violations: return !(p.violations ?? []).isEmpty
        case .appeals: return game.appeals.contains { $0.personID == p.id && $0.isPending }
        case .exonerated: return game.news.contains { $0.kind == .exoneration && $0.body.contains(p.name) }
            || p.appearances.contains { $0.outcome.lowercased().contains("exonerat") }
        }
    }
}

/// How a list of people is ordered.
enum PeopleSort: String, CaseIterable, Identifiable {
    case recent, name, release, appearances, probationEnds

    var id: String { rawValue }

    var label: String {
        switch self {
        case .recent: return "Most recent appearance"
        case .name: return "Name"
        case .release: return "Release date, soonest first"
        case .appearances: return "Most appearances"
        case .probationEnds: return "Supervision ends, soonest first"
        }
    }

    func sorted(_ people: [PersonRecord]) -> [PersonRecord] {
        switch self {
        case .recent:
            return people.sorted { ($0.appearances.last?.date ?? .distantPast) > ($1.appearances.last?.date ?? .distantPast) }
        case .name:
            return people.sorted { $0.lastName == $1.lastName ? $0.name < $1.name : $0.lastName < $1.lastName }
        case .release:
            return people.sorted { ($0.releaseDate ?? .distantFuture) < ($1.releaseDate ?? .distantFuture) }
        case .appearances:
            return people.sorted { $0.appearances.count > $1.appearances.count }
        case .probationEnds:
            func ends(_ p: PersonRecord) -> Date { p.probation?.ends ?? p.postRelease?.ends ?? .distantFuture }
            return people.sorted { ends($0) < ends($1) }
        }
    }
}

/// One person, compact: name and age, status, one line of what's next, and small flags.
struct PersonCompactRow: View {
    @EnvironmentObject private var game: GameState
    let person: PersonRecord

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(person.name).font(.system(.subheadline, design: .serif).weight(.semibold))
                    Text("\(person.age(on: game.currentDate))").font(.caption).foregroundStyle(.secondary)
                }
                Text(nextLine).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                if !flags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(flags, id: \.0) { flag in
                            Image(systemName: flag.0).font(.caption2).foregroundStyle(flag.1)
                                .accessibilityLabel(flag.2)
                        }
                    }
                }
            }
            Spacer()
            Pill(text: shortStatus, color: statusColor)
        }
    }

    private var shortStatus: String {
        if person.status == .free && person.postRelease != nil { return "Post-release" }
        return person.status.label
    }

    private var statusColor: Color {
        switch person.status {
        case .incarcerated: return .red
        case .probation: return .orange
        case .free: return person.postRelease != nil ? .orange : .secondary
        }
    }

    /// The one thing worth knowing at a glance.
    private var nextLine: String {
        switch person.status {
        case .incarcerated:
            guard let release = person.releaseDate else { return "In custody" }
            if release == .distantFuture { return "Life without parole" }
            return "Release \(SentenceFormat.shortDate(release))" + (person.pendingPostRelease != nil ? " · then post-release supervision" : (person.probation != nil ? " · then probation" : ""))
        case .probation:
            return person.probation.map { "Probation to \(SentenceFormat.shortDate($0.ends)) · \($0.offense)" } ?? "On probation"
        case .free:
            if let prs = person.postRelease { return "Post-release supervision to \(SentenceFormat.shortDate(prs.ends))" }
            let n = person.appearances.count
            return "\(n) appearance\(n == 1 ? "" : "s") · \(person.priors.count) conviction\(person.priors.count == 1 ? "" : "s")"
        }
    }

    private var flags: [(String, Color, String)] {
        var f: [(String, Color, String)] = []
        if PeopleFilter.returning.includes(person, game: game) { f.append(("arrow.uturn.left", .purple, "Returning defendant")) }
        if !(person.violations ?? []).isEmpty { f.append(("exclamationmark.triangle.fill", .orange, "Supervision violations")) }
        if game.appeals.contains(where: { $0.personID == person.id && $0.isPending }) { f.append(("building.columns.fill", .orange, "Appeal pending")) }
        if person.releaseDate == .distantFuture { f.append(("infinity", .red, "Life sentence")) }
        let upcoming = game.scheduled.contains { item in
            if case .trial(let c) = item.entry.matter { return c.defendant.personID == person.id }
            if case .hearing(let h) = item.entry.matter { return h.personID == person.id }
            return false
        }
        if upcoming { f.append(("calendar.badge.clock", Theme.gold, "Coming up on the calendar")) }
        return f
    }
}

/// A person's life in this court, in order: arrests, judgments, violations, releases, and appeals.
struct PersonTimeline: View {
    @EnvironmentObject private var game: GameState
    let person: PersonRecord
    var limit: Int? = 6

    struct Event: Identifiable {
        let id = UUID()
        let date: Date
        let icon: String
        let color: Color
        let text: String
        /// Smaller lines under the main one: the verdicts, the sentence.
        var details: [String] = []
        /// Shown next to the date, such as the docket number.
        var tag: String? = nil
    }

    /// "A, A, A, B" → "A (3 counts) · B".
    static func groupedCharges(_ charges: String) -> String {
        var order: [String] = []
        var counts: [String: Int] = [:]
        for charge in charges.components(separatedBy: ", ") where !charge.isEmpty {
            if counts[charge] == nil { order.append(charge) }
            counts[charge, default: 0] += 1
        }
        return order.map { counts[$0, default: 1] > 1 ? "\($0) (\(counts[$0, default: 1]) counts)" : $0 }.joined(separator: " · ")
    }

    /// "Ct. 1 Guilty; Ct. 2 Guilty. Sentence…" → ["Guilty on all 2 counts", "Sentence…"].
    static func outcomeLines(_ outcome: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: #"Ct\. (\d+) ([^;.]+)"#) else { return [outcome] }
        let range = NSRange(outcome.startIndex..., in: outcome)
        let matches = regex.matches(in: outcome, range: range)
        guard !matches.isEmpty, let last = matches.last, let end = Range(last.range, in: outcome)?.upperBound else { return [outcome] }
        let labels = matches.compactMap { m in Range(m.range(at: 2), in: outcome).map { String(outcome[$0]).trimmingCharacters(in: .whitespaces) } }
        let verdict: String
        if Set(labels).count == 1, let only = labels.first {
            verdict = labels.count == 1 ? only : "\(only) on all \(labels.count) counts"
        } else {
            verdict = labels.enumerated().map { "Ct. \($0.offset + 1): \($0.element)" }.joined(separator: " · ")
        }
        let rest = String(outcome[end...]).trimmingCharacters(in: CharacterSet(charactersIn: ". "))
        return rest.isEmpty ? [verdict] : [verdict, rest.capitalizedFirst]
    }

    var events: [Event] {
        var list: [Event] = []
        let cal = CourtCalendar.calendar
        let logged = game.log(for: person.id)
        /// When the court ruled in a docket on a day: the logged verdict's time, else mid-afternoon.
        func ruled(_ docket: String, on date: Date) -> Date {
            guard date == cal.startOfDay(for: date) else { return date }
            if let verdict = logged.last(where: { $0.kind == .verdict && $0.docket == docket && cal.isDate($0.date, inSameDayAs: date) }) {
                return verdict.date
            }
            return cal.date(byAdding: .minute, value: 15 * 60, to: date) ?? date
        }
        func minutes(_ n: Int, after date: Date) -> Date { cal.date(byAdding: .minute, value: n, to: date) ?? date }
        for a in person.appearances {
            let pv = a.docket.hasSuffix("(PV)")
            list.append(Event(date: ruled(a.docket, on: a.date), icon: pv ? "person.badge.clock.fill" : "hammer.fill", color: pv ? .orange : Theme.gold,
                              text: Self.groupedCharges(a.charges), details: Self.outcomeLines(a.outcome), tag: a.docket))
        }
        for order in person.stayAwayOrders ?? [] {
            list.append(Event(date: minutes(1, after: ruled(order.docket, on: order.issued)), icon: "hand.raised.fill", color: Theme.prosecution,
                              text: "\(order.label.capitalizedFirst) protecting \(order.protectedName) until \(SentenceFormat.shortDate(order.expires))"
                                + (order.violations > 0 ? ". Violated \(order.violations) time\(order.violations == 1 ? "" : "s")." : ".")))
        }
        for v in person.violations ?? [] {
            // The conduct is reported in the evening, when officers make their home visits and checks.
            let reported = v.date == cal.startOfDay(for: v.date) ? minutes(17 * 60 + (v.conduct.count * 37) % 240, after: v.date) : v.date
            list.append(Event(date: reported, icon: "exclamationmark.triangle.fill", color: .orange, text: "\(v.kind): \(v.conduct.trimmingTrailingPeriods). \(v.result)"))
        }
        for appeal in game.appeals where appeal.personID == person.id {
            // Notice of appeal is given in open court, right after judgment.
            list.append(Event(date: minutes(2, after: ruled(appeal.docket, on: appeal.filed)), icon: "building.columns", color: .secondary, text: "Appeal filed (\(appeal.appellant))"))
            if let decided = appeal.decided {
                // The Court of Appeals files its opinions in the morning.
                let filed = decided == cal.startOfDay(for: decided) ? minutes(11 * 60, after: decided) : decided
                list.append(Event(date: filed, icon: "building.columns.fill", color: appeal.wasReversed ? .orange : Theme.good,
                                  text: appeal.result ?? "Appeal decided"))
            }
        }
        // The arrests, jail stays, bond hearings, trial settings, and transfers the court's log recorded.
        for e in logged where e.kind != .verdict {
            list.append(Event(date: e.date, icon: e.kind.icon, color: Self.color(for: e.kind), text: e.text, tag: e.docket))
        }
        if let release = person.releaseDate, release != .distantFuture, person.status == .incarcerated {
            list.append(Event(date: release, icon: "door.left.hand.open", color: .secondary, text: "Projected release"))
        }
        // Oldest first, so the story reads top to bottom in the order it happened.
        return list.sorted { $0.date < $1.date }
    }

    static func color(for kind: LogEvent.Kind) -> Color {
        switch kind {
        case .crime, .arrest, .warrant: return Theme.prosecution
        case .jailIn, .prison: return Theme.bad
        case .jailOut, .release, .early: return Theme.good
        case .bond: return Theme.gold
        case .probation: return .orange
        case .investigation, .trialSet, .continued, .court, .verdict: return Theme.defense
        }
    }

    var body: some View {
        let all = events
        // A short preview shows the latest events, still in the order they happened.
        let shown = limit.map { Array(all.suffix($0)) } ?? all
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionTitle(text: "Timeline", icon: "clock.arrow.circlepath")
                Spacer()
                if let limit, all.count > limit {
                    NavigationLink("All \(all.count)") {
                        FixedWidthScroll { PersonTimeline(person: person, limit: nil).padding() }
                            .benchBackground()
                            .navigationTitle("Timeline")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .font(.caption.weight(.semibold))
                }
            }
            if shown.isEmpty { Text("Nothing recorded yet.").font(.callout).foregroundStyle(.secondary) }
            ForEach(shown) { event in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: event.icon).foregroundStyle(event.color).frame(width: 20)
                    VStack(alignment: .leading, spacing: 1) {
                        Text((CourtCalendar.calendar.startOfDay(for: event.date) > game.currentDate ? "\(SentenceFormat.shortDate(event.date)) (expected)" : SentenceFormat.dateAndTime(event.date))
                             + (event.tag.map { " · \($0)" } ?? ""))
                            .font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                        Text(event.text).font(.callout.weight(event.details.isEmpty ? .regular : .semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(event.details, id: \.self) { line in
                            Text(line).font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .card()
    }
}


/// Every stretch a person spent in custody, from the court's log.
struct CustodyHistory: View {
    @EnvironmentObject private var game: GameState
    let personID: UUID

    var body: some View {
        let stays = CustodyStay.stays(from: game.log(for: personID))
        if !stays.isEmpty {
            let total = stays.map { $0.days(through: game.currentDate) }.reduce(0, +)
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(text: "Time in custody · \(total) day\(total == 1 ? "" : "s")", icon: "lock.fill")
                ForEach(stays.reversed()) { stay in
                    let days = stay.days(through: game.currentDate)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(SentenceFormat.shortDate(stay.start)) – \(stay.end.map(SentenceFormat.shortDate) ?? "now") · \(days) day\(days == 1 ? "" : "s")")
                            .font(.caption.monospacedDigit().weight(.semibold))
                        Text(stay.reason).font(.caption).foregroundStyle(.secondary)
                        if let out = stay.endReason { Text(out).font(.caption).foregroundStyle(Theme.good) }
                    }
                }
            }
            .card()
        }
    }
}

/// One case from the crime to the last thing that happened in it.
struct CaseTimelineView: View {
    @EnvironmentObject private var game: GameState
    let docket: String

    var body: some View {
        let events = game.log(docket: docket)
        List {
            if let first = events.first {
                Section {
                    Text("State v. \(first.name)").font(.system(.headline, design: .serif))
                    let stays = CustodyStay.stays(from: events)
                    if !stays.isEmpty {
                        let total = stays.map { $0.days(through: game.currentDate) }.reduce(0, +)
                        Label("\(total) day\(total == 1 ? "" : "s") in custody on this case", systemImage: "lock.fill")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    if let id = first.personID, let person = game.person(id) {
                        NavigationLink("Full record: \(person.name)") { PersonDetail(person: person, today: game.currentDate) }
                            .font(.caption.weight(.semibold))
                    }
                }
            }
            Section("Timeline") {
                if events.isEmpty { Text("Nothing logged for this case yet.").foregroundStyle(.secondary) }
                ForEach(events) { e in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: e.kind.icon).foregroundStyle(PersonTimeline.color(for: e.kind)).frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(CourtCalendar.calendar.startOfDay(for: e.date) > game.currentDate ? "\(SentenceFormat.shortDate(e.date)) (expected)" : SentenceFormat.dateAndTime(e.date))
                                .font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                            Text(e.text).font(.callout).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .benchBackground()
        .navigationTitle(docket)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CaseLogRow: Identifiable {
    let id: String
    let first: LogEvent
    let last: LogEvent
}

/// Every case the log knows, newest activity first: arrests, investigations, and everything after.
struct CaseLogIndex: View {
    @EnvironmentObject private var game: GameState
    @State private var query = ""
    @State private var shown = 50

    var body: some View {
        let byDocket = Dictionary(grouping: game.caseLog, by: \.docket)
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let cases = byDocket.compactMap { docket, events -> CaseLogRow? in
            guard !docket.isEmpty, let first = events.min(by: { $0.date < $1.date }), let last = events.max(by: { $0.date < $1.date }) else { return nil }
            if !q.isEmpty && !docket.lowercased().contains(q) && !first.name.lowercased().contains(q) { return nil }
            return CaseLogRow(id: docket, first: first, last: last)
        }.sorted { $0.last.date > $1.last.date }
        List {
            Section {
                ForEach(cases.prefix(shown)) { item in
                    NavigationLink { CaseTimelineView(docket: item.id) } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(item.first.name).font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(item.id).font(.caption2.monospaced()).foregroundStyle(.secondary)
                            }
                            Label(item.last.text, systemImage: item.last.kind.icon).font(.caption).lineLimit(2)
                                .foregroundStyle(PersonTimeline.color(for: item.last.kind))
                            Text("Latest: \(SentenceFormat.shortDate(item.last.date)) · began \(SentenceFormat.shortDate(item.first.date))")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
                if cases.count > shown {
                    Button("Show more") { shown += 50 }.font(.caption.weight(.semibold))
                }
            } header: {
                Text("\(cases.count) case\(cases.count == 1 ? "" : "s")")
            } footer: {
                Text("Every case from the crime on: the investigation, the arrest, nights in jail, the bond hearing, trial settings, the verdict, prison, and release. Cases from before this log began start partway through.")
            }
        }
        .searchable(text: $query, prompt: "Name or docket")
        .benchBackground()
        .navigationTitle("Case log")
    }
}
