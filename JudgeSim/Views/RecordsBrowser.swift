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
    }

    var events: [Event] {
        var list: [Event] = []
        for a in person.appearances {
            let pv = a.docket.hasSuffix("(PV)")
            list.append(Event(date: a.date, icon: pv ? "person.badge.clock.fill" : "hammer.fill", color: pv ? .orange : Theme.gold,
                              text: "\(a.charges) (\(a.docket)): \(a.outcome)"))
        }
        for v in person.violations ?? [] {
            list.append(Event(date: v.date, icon: "exclamationmark.triangle.fill", color: .orange, text: "\(v.kind): \(v.conduct.trimmingTrailingPeriods). \(v.result)"))
        }
        for appeal in game.appeals where appeal.personID == person.id {
            list.append(Event(date: appeal.filed, icon: "building.columns", color: .secondary, text: "Appeal filed (\(appeal.appellant))"))
            if let decided = appeal.decided {
                list.append(Event(date: decided, icon: "building.columns.fill", color: appeal.wasReversed ? .orange : Theme.good,
                                  text: appeal.result ?? "Appeal decided"))
            }
        }
        if let release = person.releaseDate, release != .distantFuture, person.status == .incarcerated {
            list.append(Event(date: release, icon: "door.left.hand.open", color: .secondary, text: "Projected release"))
        }
        return list.sorted { $0.date > $1.date }
    }

    var body: some View {
        let all = events
        let shown = limit.map { Array(all.prefix($0)) } ?? all
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionTitle(text: "Timeline", icon: "clock.arrow.circlepath")
                Spacer()
                if let limit, all.count > limit {
                    NavigationLink("All \(all.count)") {
                        ScrollView { PersonTimeline(person: person, limit: nil).padding() }
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
                        Text(event.date > game.currentDate ? "\(SentenceFormat.shortDate(event.date)) (expected)" : SentenceFormat.shortDate(event.date))
                            .font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                        Text(event.text).font(.callout).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .card()
    }
}
