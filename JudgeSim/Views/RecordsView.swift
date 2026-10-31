import SwiftUI

/// The court's records: cases, the calendar, appeals, people, and the paper. One search reaches all of them.
struct RecordsView: View {
    @EnvironmentObject private var game: GameState
    @State private var section = 0
    @State private var confirmReset = false
    @State private var query = ""
    /// The stat tapped in the bar at the top of Cases; its list replaces the recent docket until tapped again.
    @State private var focus: StatFocus?
    @State private var sort: PeopleSort = .recent
    @State private var peopleFilter: PeopleChip = .all
    @State private var peopleShown = RecordsView.pageSize
    @State private var showAllComing = false
    @State private var openMonths: Set<String> = []
    @State private var appealFilter = 0
    @State private var showDecided = false
    @State private var newsKind: NewsItem.Kind?
    @AppStorage("pinnedPeople") private var pinnedRaw = ""

    /// How many recent matters the Cases tab lists before pointing to the Calendar and News tabs.
    static let recentLimit = 10
    static let pageSize = 50

    enum StatFocus: String {
        case cases, hearings

        var title: String { self == .cases ? "Cases heard" : "Violation hearings" }
    }

    /// The filters across the top of People.
    enum PeopleChip: String, CaseIterable, Identifiable {
        case all, pinned, custody, probation, awaiting, postRelease, free, returning, violations, appeals, archived
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "Active"
            case .pinned: return "Pinned"
            case .custody: return "In custody"
            case .probation: return "Probation"
            case .awaiting: return "Awaiting trial"
            case .postRelease: return "Post-release"
            case .free: return "At liberty"
            case .returning: return "Returning"
            case .violations: return "Violations"
            case .appeals: return "Appeal pending"
            case .archived: return "Archived"
            }
        }
        var icon: String {
            switch self {
            case .all: return "person.3.fill"
            case .pinned: return "pin.fill"
            case .custody: return "lock.fill"
            case .probation: return "person.badge.clock.fill"
            case .awaiting: return "hourglass"
            case .postRelease: return "figure.walk.departure"
            case .free: return "figure.walk"
            case .returning: return "arrow.uturn.left"
            case .violations: return "exclamationmark.triangle.fill"
            case .appeals: return "building.columns.fill"
            case .archived: return "archivebox"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !trimmedQuery.isEmpty {
                    searchResults
                } else {
                    Picker("Records", selection: $section) {
                        Text("Cases").tag(0)
                        Text("Calendar").tag(3)
                        Text("Appeals").tag(4)
                        Text("People").tag(1)
                        Text("News").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)

                    switch section {
                    case 0: casesSection
                    case 1: peopleSection
                    case 3: calendarSection
                    case 4: appealsSection
                    default: newsSection
                    }
                }
            }
            .benchBackground()
            .navigationTitle("Records")
            .searchable(text: $query, prompt: "Names, dockets, charges, headlines")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Leave the Bench and Start Over", systemImage: "door.left.hand.open", role: .destructive) { confirmReset = true }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .confirmationDialog("Leave the bench? This erases your county, cases, and records.",
                                isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Leave the bench", role: .destructive) { game.resetCareer() }
            }
            .onChange(of: peopleFilter) { peopleShown = Self.pageSize }
        }
    }

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespaces).lowercased() }

    // MARK: Search

    @ViewBuilder
    private var searchResults: some View {
        let q = trimmedQuery
        let people = game.people.filter { person in
            person.name.lowercased().contains(q)
                || person.appearances.contains { $0.docket.lowercased().contains(q) || $0.charges.lowercased().contains(q) }
        }
        let cases = game.history.filter {
            $0.docket.lowercased().contains(q) || $0.caption.lowercased().contains(q) || $0.headline.lowercased().contains(q)
                || $0.outcome.lowercased().contains(q)
        }
        let rulings = game.calendarLog.filter {
            $0.personName.lowercased().contains(q) || $0.docket.lowercased().contains(q) || $0.ruling.lowercased().contains(q)
        }
        let appeals = game.appeals.filter { $0.caption.lowercased().contains(q) || $0.docket.lowercased().contains(q) || $0.issue.lowercased().contains(q) }
        let news = game.news.filter { $0.headline.lowercased().contains(q) || $0.body.lowercased().contains(q) || ($0.docket ?? "").lowercased().contains(q) }

        if people.isEmpty && cases.isEmpty && rulings.isEmpty && appeals.isEmpty && news.isEmpty {
            Section { Text("Nothing in the records matches \"\(query)\".").foregroundStyle(.secondary) }
        }
        if !people.isEmpty {
            Section("People · \(people.count)") {
                ForEach(sort.sorted(people).prefix(20)) { personLink($0) }
            }
        }
        if !cases.isEmpty {
            Section("Cases · \(cases.count)") {
                ForEach(cases.prefix(20)) { record in
                    NavigationLink { CaseRecordDetail(record: record) } label: { DocketIndexRow(record: record) }
                }
            }
        }
        if !rulings.isEmpty {
            Section("Calendar rulings · \(rulings.count)") {
                ForEach(rulings.prefix(20)) { RulingRow(ruling: $0) }
            }
        }
        if !appeals.isEmpty {
            Section("Appeals · \(appeals.count)") {
                ForEach(appeals.prefix(20)) { appeal in
                    NavigationLink { AppealDetail(appeal: appeal, today: game.currentDate) } label: { AppealRow(appeal: appeal, today: game.currentDate) }
                }
            }
        }
        if !news.isEmpty {
            Section("News · \(news.count)") {
                ForEach(news.prefix(20)) { NewsRow(item: $0) }
            }
        }
    }

    // MARK: Cases

    @ViewBuilder
    private var casesSection: some View {
        let trials = game.history.filter { $0.resolvedKind == "trial" }
        let convictions = trials.filter { $0.outcome.contains("Guilty") || $0.outcome.contains("No contest") }.count
        let decided = game.appeals.filter { !$0.isPending && !$0.isMoot && $0.result != "Appeal dismissed" }
        let affirmed = decided.isEmpty ? "—" : "\((decided.count - decided.filter(\.wasReversed).count) * 100 / decided.count)%"
        Section {
            HStack {
                stat("\(game.trialsHeard)", "Cases", .cases)
                Spacer()
                stat("\(game.hearingsHeard)", "Hearings", .hearings)
                Spacer()
                plainStat("\(convictions)", "Convictions")
                Spacer()
                plainStat(affirmed, "Affirmed")
            }
        } footer: {
            Text(focus == nil ? "Tap Cases or Hearings to see each one. Who is in custody or on probation is on the Corrections tab."
                              : "Tap it again to go back.")
        }
        if let focus {
            let records = game.history.filter { $0.resolvedKind == (focus == .cases ? "trial" : "hearing") }
            Section {
                if records.isEmpty { Text("None yet.").foregroundStyle(.secondary) }
                ForEach(records.prefix(Self.pageSize)) { record in
                    NavigationLink { CaseRecordDetail(record: record) } label: { DocketIndexRow(record: record) }
                }
            } header: {
                Text(focus.title)
            } footer: {
                if records.count > Self.pageSize {
                    Text("The last \(Self.pageSize) of \(records.count). Search above, or look by month on the Calendar tab.")
                }
            }
        } else {
            Section {
                NavigationLink {
                    CareerLedgerView()
                } label: {
                    Label("Career ledger", systemImage: "book.closed.fill")
                }
            }
            Section {
                if game.history.isEmpty { Text("No cases heard yet.").foregroundStyle(.secondary) }
                ForEach(game.history.prefix(Self.recentLimit)) { record in
                    NavigationLink { CaseRecordDetail(record: record) } label: { DocketIndexRow(record: record) }
                }
            } header: {
                Text("Recent docket")
            } footer: {
                if game.history.count > Self.recentLimit {
                    Text("Your last \(Self.recentLimit). Every earlier matter is on the Calendar tab by month, and search finds any of them.")
                }
            }
        }
    }

    /// One number in the bar. Borderless, so each one in the row is its own button.
    private func stat(_ value: String, _ label: String, _ target: StatFocus) -> some View {
        Button {
            withAnimation { focus = focus == target ? nil : target }
        } label: {
            VStack {
                Text(value).font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(focus == target ? Theme.gold : Color.primary)
                Text(label).font(.caption2).foregroundStyle(focus == target ? Theme.gold : Color.secondary)
            }
        }
        .buttonStyle(.borderless)
    }

    private func plainStat(_ value: String, _ label: String) -> some View {
        VStack {
            Text(value).font(.system(.title3, design: .rounded).weight(.bold))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    // MARK: Calendar

    @ViewBuilder
    private var calendarSection: some View {
        let coming = showAllComing ? game.scheduled : Array(game.scheduled.prefix(5))
        Section {
            if game.scheduled.isEmpty {
                Text("Nothing has been continued to a later date.").foregroundStyle(.secondary)
            }
            ForEach(coming) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(CourtCalendar.dayTitle(item.date)).font(.caption.weight(.bold)).foregroundStyle(Theme.gold)
                    Text(item.entry.title).font(.subheadline.weight(.semibold))
                    Text(item.entry.subtitle).font(.caption).foregroundStyle(.secondary)
                    if let note = item.entry.note { Text(note).font(.caption2).foregroundStyle(.purple) }
                }
            }
            if game.scheduled.count > 5 {
                Button(showAllComing ? "Show fewer" : "Show all \(game.scheduled.count)") { withAnimation { showAllComing.toggle() } }
                    .font(.caption.weight(.semibold))
            }
        } header: {
            Text("Coming up")
        }
        Section {
            NavigationLink {
                RulingsView()
            } label: {
                HStack {
                    Label("Calendar call and bond hearing rulings", systemImage: "list.clipboard.fill")
                    Spacer()
                    Text("\(game.calendarLog.count)").foregroundStyle(.secondary)
                }
            }
        }
        let months = Dictionary(grouping: game.history) { monthKey($0.date) }
        let current = monthKey(game.currentDate)
        ForEach(months.keys.sorted(by: >), id: \.self) { key in
            let records = months[key] ?? []
            Section {
                DisclosureGroup(isExpanded: monthBinding(key, current: current)) {
                    let days = Dictionary(grouping: records) { CourtCalendar.calendar.startOfDay(for: $0.date) }
                    ForEach(days.keys.sorted(by: >), id: \.self) { day in
                        Text(CourtCalendar.dayTitle(day)).font(.caption.weight(.bold)).foregroundStyle(Theme.gold)
                        ForEach(days[day] ?? []) { record in
                            NavigationLink { CaseRecordDetail(record: record) } label: { DocketIndexRow(record: record, showDate: false) }
                        }
                    }
                } label: {
                    HStack {
                        Text(monthTitle(records.first?.date ?? game.currentDate)).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(records.count) matter\(records.count == 1 ? "" : "s")").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func monthKey(_ date: Date) -> String {
        let c = CourtCalendar.calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", c.year ?? 0, c.month ?? 0)
    }

    private func monthTitle(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).year())
    }

    /// The current month starts open; every other month starts closed.
    private func monthBinding(_ key: String, current: String) -> Binding<Bool> {
        Binding(
            get: { openMonths.contains(key) != (key == current) },
            set: { open in
                let differs = open != (key == current)
                if differs { openMonths.insert(key) } else { openMonths.remove(key) }
            })
    }

    // MARK: Appeals

    @ViewBuilder
    private var appealsSection: some View {
        let pending = game.appeals.filter(\.isPending)
        let decided = game.appeals.filter { !$0.isPending }
        let shown = decided.filter { appeal in
            switch appealFilter {
            case 1: return !appeal.wasReversed && !appeal.isMoot
            case 2: return appeal.wasReversed
            default: return true
            }
        }
        Section("Pending · \(pending.count)") {
            if pending.isEmpty { Text("No appeals pending.").foregroundStyle(.secondary) }
            ForEach(pending) { appeal in
                NavigationLink { AppealDetail(appeal: appeal, today: game.currentDate) } label: { AppealRow(appeal: appeal, today: game.currentDate) }
            }
        }
        if !decided.isEmpty {
            Section {
                DisclosureGroup(isExpanded: $showDecided) {
                    Picker("Show", selection: $appealFilter) {
                        Text("All").tag(0)
                        Text("Affirmed").tag(1)
                        Text("Reversed").tag(2)
                    }
                    .pickerStyle(.segmented)
                    if shown.isEmpty { Text("None.").foregroundStyle(.secondary) }
                    ForEach(shown) { appeal in
                        NavigationLink { AppealDetail(appeal: appeal, today: game.currentDate) } label: { AppealRow(appeal: appeal, today: game.currentDate) }
                    }
                } label: {
                    HStack {
                        Text("Decided").font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(decided.count) · \(decided.filter(\.wasReversed).count) reversed").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: People

    private var pinned: Set<UUID> {
        Set(pinnedRaw.split(separator: ",").compactMap { UUID(uuidString: String($0)) })
    }

    private func togglePin(_ id: UUID) {
        var set = pinned
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
        pinnedRaw = set.map(\.uuidString).joined(separator: ",")
    }

    /// People with a trial still to come in this court.
    private var awaitingTrial: Set<UUID> {
        var ids = Set<UUID>()
        for entry in game.scheduled.map(\.entry) + game.awaiting.map(\.entry) {
            if case .trial(let c) = entry.matter { ids.insert(c.defendant.personID) }
        }
        return ids
    }

    private func matches(_ person: PersonRecord, _ chip: PeopleChip, awaiting: Set<UUID>, pins: Set<UUID>) -> Bool {
        let archived = isArchived(person)
        switch chip {
        case .all: return !archived
        case .pinned: return pins.contains(person.id)
        case .custody: return PeopleFilter.custody.includes(person, game: game)
        case .probation: return PeopleFilter.probation.includes(person, game: game)
        case .awaiting: return awaiting.contains(person.id)
        case .postRelease: return PeopleFilter.postRelease.includes(person, game: game)
        case .free: return !archived && PeopleFilter.free.includes(person, game: game)
        case .returning: return PeopleFilter.returning.includes(person, game: game)
        case .violations: return PeopleFilter.violations.includes(person, game: game)
        case .appeals: return PeopleFilter.appeals.includes(person, game: game)
        case .archived: return archived
        }
    }

    @ViewBuilder
    private var peopleSection: some View {
        let awaiting = awaitingTrial
        let pins = pinned
        let counts = Dictionary(uniqueKeysWithValues: PeopleChip.allCases.map { chip in
            (chip, game.people.filter { matches($0, chip, awaiting: awaiting, pins: pins) }.count)
        })
        let list = sort.sorted(game.people.filter { matches($0, peopleFilter, awaiting: awaiting, pins: pins) })
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PeopleChip.allCases.filter { $0 == .all || $0 == peopleFilter || (counts[$0] ?? 0) > 0 }) { chip in
                        Button {
                            withAnimation { peopleFilter = chip }
                        } label: {
                            Label("\(chip.label) \(counts[chip] ?? 0)", systemImage: chip.icon)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundStyle(peopleFilter == chip ? Theme.background : Theme.text)
                                .background(Capsule().fill(peopleFilter == chip ? Theme.gold : Theme.raised))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        } footer: {
            Text(peopleFilter == .archived
                 ? "People with no sentence, supervision, or appeal left and no appearance in the past year."
                 : "Swipe a name to pin it. Search at the top finds anyone, archived or not.")
        }
        Section {
            if list.isEmpty { Text("No one here.").foregroundStyle(.secondary) }
            ForEach(list.prefix(peopleShown)) { person in
                personLink(person)
                    .swipeActions(edge: .trailing) {
                        Button(pins.contains(person.id) ? "Unpin" : "Pin", systemImage: pins.contains(person.id) ? "pin.slash" : "pin") {
                            togglePin(person.id)
                        }
                        .tint(Theme.gold)
                    }
            }
            if list.count > peopleShown {
                Button("Show \(min(Self.pageSize, list.count - peopleShown)) more of \(list.count - peopleShown)") {
                    peopleShown += Self.pageSize
                }
                .font(.caption.weight(.semibold))
            }
        } header: {
            HStack {
                Text("\(peopleFilter.label) · \(list.count)")
                Spacer()
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(PeopleSort.allCases) { Text($0.label).tag($0) }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down").font(.caption.weight(.semibold))
                }
                .textCase(nil)
            }
        }
    }

    private func personLink(_ person: PersonRecord) -> some View {
        NavigationLink { PersonDetail(person: person, today: game.currentDate) } label: {
            HStack(spacing: 6) {
                if pinned.contains(person.id) { Image(systemName: "pin.fill").font(.caption2).foregroundStyle(Theme.gold) }
                PersonCompactRow(person: person)
            }
        }
    }

    /// Done with the court: nothing left to serve or supervise, no appeal pending, and nothing in the past year.
    private func isArchived(_ person: PersonRecord) -> Bool {
        guard person.status == .free, person.postRelease == nil, person.probation == nil else { return false }
        if game.appeals.contains(where: { $0.personID == person.id && $0.isPending }) { return false }
        guard let last = person.appearances.map(\.date).max() else { return false }
        let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: game.currentDate) ?? game.currentDate
        return last < yearAgo
    }

    // MARK: News

    @ViewBuilder
    private var newsSection: some View {
        let items = game.news.filter { newsKind == nil || $0.kind == newsKind }
        Section {
            Picker("Kind", selection: $newsKind) {
                Text("All stories").tag(NewsItem.Kind?.none)
                ForEach(NewsItem.Kind.allKinds, id: \.self) { kind in
                    Label(kind.label, systemImage: kind.icon).tag(NewsItem.Kind?.some(kind))
                }
            }
        } header: {
            Text(game.county?.newspaper ?? "News")
        }
        let months = Dictionary(grouping: items) { monthKey($0.date) }
        let current = monthKey(game.currentDate)
        if items.isEmpty { Section { Text("No stories.").foregroundStyle(.secondary) } }
        ForEach(months.keys.sorted(by: >), id: \.self) { key in
            let stories = months[key] ?? []
            Section {
                DisclosureGroup(isExpanded: monthBinding("news-" + key, current: "news-" + current)) {
                    ForEach(stories) { NewsRow(item: $0) }
                } label: {
                    HStack {
                        Text(monthTitle(stories.first?.date ?? game.currentDate)).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(stories.count) stor\(stories.count == 1 ? "y" : "ies")").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

extension NewsItem.Kind {
    static let allKinds: [NewsItem.Kind] = [.verdict, .arrest, .appeal, .community, .exoneration, .revelation, .ethics]

    var label: String {
        switch self {
        case .verdict: return "Verdicts"
        case .appeal: return "Appeals"
        case .exoneration: return "Exonerations"
        case .arrest: return "Arrests"
        case .revelation: return "Revelations"
        case .ethics: return "Ethics"
        case .community: return "Community"
        }
    }
}

private struct NewsRow: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label(SentenceFormat.shortDate(item.date), systemImage: item.kind.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let placement = item.placement {
                    Text(placement.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(.secondary)
                }
            }
            if let section = item.section {
                Text(section.uppercased()).font(.system(size: 9, weight: .bold)).tracking(0.8).foregroundStyle(Theme.gold)
            }
            Text(item.headline).font(.system(.subheadline, design: .serif).weight(.semibold))
            if let byline = item.byline {
                Text(byline).font(.system(.caption2, design: .serif)).italic().foregroundStyle(.secondary)
            }
            Text(item.body).font(.system(.caption, design: .serif))
            if let docket = item.docket {
                Text(docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct RulingRow: View {
    let ruling: CalendarRuling

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(ruling.kind.label).font(.caption.weight(.bold)).foregroundStyle(Theme.gold)
                Spacer()
                Text(SentenceFormat.shortDate(ruling.date)).font(.caption2).foregroundStyle(.secondary)
            }
            Text(ruling.personName).font(.subheadline.weight(.semibold))
            Text(ruling.ruling).font(.caption)
            Text(ruling.docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
        }
    }
}

/// What the judge decided at calendar calls and bond hearings, newest first, filtered by kind, a page at a time.
private struct RulingsView: View {
    @EnvironmentObject private var game: GameState
    @State private var filter: CalendarRuling.Group = .all
    @State private var shown = 30

    var body: some View {
        let rulings = game.calendarLog.filter { filter == .all || $0.group == filter }
        List {
            Picker("Show", selection: $filter) {
                ForEach(CalendarRuling.Group.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            Section("\(rulings.count) ruling\(rulings.count == 1 ? "" : "s")") {
                if rulings.isEmpty { Text("No rulings yet.").foregroundStyle(.secondary) }
                ForEach(rulings.prefix(shown)) { RulingRow(ruling: $0) }
                if rulings.count > shown {
                    Button("Show more") { shown += 30 }.font(.caption.weight(.semibold))
                }
            }
        }
        .benchBackground()
        .navigationTitle("Rulings")
        .onChange(of: filter) { shown = 30 }
    }
}

/// The career in numbers, grouped the way a judicial performance report would be.
private struct CareerLedgerView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        let trials = game.history.filter { $0.resolvedKind == "trial" }
        let s = game.stats
        // A retrial of the same case isn't a defendant returning.
        let firstHeard = Dictionary(trials.map { ($0.docket, $0.date) }, uniquingKeysWith: { min($0, $1) })
        List {
            Section("Verdicts") {
                ledgerRow("Convictions at trial", trials.filter { $0.outcome.contains("Guilty") && !$0.outcome.contains("plea)") && !$0.outcome.contains("No contest") }.count)
                ledgerRow("Acquittals and dismissals at trial", trials.filter { $0.outcome.hasPrefix("Not guilty") || $0.outcome.hasPrefix("Dismissed") || $0.outcome.hasPrefix("All counts dismissed") }.count)
                ledgerRow("Guilty pleas", trials.filter { $0.outcome.contains("plea)") || $0.outcome.contains("No contest") }.count)
                ledgerRow("Returning defendants", trials.filter { $0.returningDefendant && $0.date <= (firstHeard[$0.docket] ?? $0.date) }.count)
                ledgerRow("Exonerations", s.exonerations)
            }
            Section("Sentencing") {
                ledgerRow("Felony sentences below the presumptive range", s.belowPresumptive)
                ledgerRow("Felony sentences within the presumptive range", s.withinPresumptive)
                ledgerRow("Felony sentences above the presumptive range", s.abovePresumptive)
                ledgerRow("Active sentences", s.activeSentences)
                ledgerRow("Suspended sentences", s.suspendedSentences)
            }
            Section("Supervision and release") {
                ledgerRow("Probation completed", s.probationCompleted)
                ledgerRow("Probation revoked", s.probationRevoked)
                ledgerRow("Released from custody", s.releasedFromPrison)
                ledgerRow("Let go, then charged again", s.chargedAgainAfterRelease ?? 0)
                ledgerRow("Stay-away order violations", s.orderViolations ?? 0)
            }
            Section("Appeals") {
                ledgerRow("Affirmed on appeal", trials.filter { $0.appealStatus == "Affirmed on appeal" }.count)
                ledgerRow("Reversed or vacated on appeal", trials.filter { ($0.appealStatus ?? "").contains("New trial") || ($0.appealStatus ?? "").contains("vacated") || ($0.appealStatus ?? "").contains("reversed") }.count)
            }
            Section("Docket") {
                ledgerRow("Cases that waited too long", s.delayedCases ?? 0)
                ledgerRow("Cases handed to another judge", s.delegated ?? 0)
            }
        }
        .benchBackground()
        .navigationTitle("Career ledger")
    }

    private func ledgerRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label).font(.callout)
            Spacer()
            Text("\(value)").font(.callout.monospacedDigit().weight(.semibold))
        }
    }
}
