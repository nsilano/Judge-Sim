import SwiftUI

struct RootView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        if game.judgeName == nil || game.county == nil {
            OnboardingView()
        } else {
            TabView {
                ChambersView()
                    .tabItem { Label("Chambers", systemImage: "building.columns.fill") }
                RecordsView()
                    .tabItem { Label("Records", systemImage: "archivebox.fill") }
                LawLibraryView()
                    .tabItem { Label("Law Library", systemImage: "books.vertical.fill") }
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var game: GameState
    @State private var name = ""
    @State private var startDay = CourtCalendar.weekday(onOrAfter: Date())
    @State private var openingTime = CourtCalendar.opening(on: Date(), minutesAfterMidnight: 9 * 60 + 30)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    VersionBadge()
                }
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.gold)
                    .padding(.top, 24)
                Text("Judge Sim")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                Text("You have been elected Resident Superior Court Judge for Hollis County, North Carolina. Defendants in your courtroom have waived their right to a jury, so the facts, the law, and the sentence are yours to decide.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 14) {
                    feature("doc.text.magnifyingglass", "Pretrial motions", "Suppression hearings and speedy-trial motions.")
                    feature("person.3.fill", "Bench trials", "Hear the evidence and rule on objections under the North Carolina Rules of Evidence.")
                    feature("scalemass.fill", "Structured Sentencing", "Prior record levels, aggravating and mitigating factors, habitual felon status, and probation.")
                    feature("person.2.wave.2.fill", "One county", "The same prosecutors, defenders, and officers, and the same people coming back through your courtroom.")
                    feature("newspaper.fill", "Consequences", "Appeals, news, and what happens to people after they leave your courtroom.")
                }
                .card()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your name").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    TextField("e.g. Morgan Avery", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your first day on the bench").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    DatePicker("First court date", selection: $startDay, displayedComponents: .date)
                    DatePicker("Court opens at", selection: $openingTime, displayedComponents: .hourAndMinute)
                    Text("Court sits on weekdays. You'll hold week-long criminal sessions, with a few weeks between them.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))

                PrimaryButton(title: "Take the Oath of Office", icon: "hand.raised.fill",
                              enabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    Haptics.gavel()
                    let time = Calendar.current.dateComponents([.hour, .minute], from: openingTime)
                    let start = Calendar.current.date(bySettingHour: time.hour ?? 9, minute: time.minute ?? 30, second: 0, of: startDay) ?? startDay
                    game.startCareer(name: name.trimmingCharacters(in: .whitespaces), start: start)
                }

                Text(LawLibrary.disclaimer)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func feature(_ icon: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.gold)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.bold))
                Text(text).font(.callout).foregroundStyle(.secondary)
            }
        }
    }
}

struct ChambersView: View {
    @EnvironmentObject private var game: GameState
    @State private var activeItem: DocketItem?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        VersionBadge()
                    }
                    header
                    if !game.digest.isEmpty {
                        digestCard
                    }
                    docketCard

                    if let county = game.county {
                        NavigationLink {
                            CourthouseView(county: county)
                        } label: {
                            HStack {
                                Label("\(county.courthouse)", systemImage: "building.2.fill")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.secondary)
                            }
                            .card()
                        }
                        .buttonStyle(.plain)
                    }

                    SectionTitle(text: game.county?.newspaper ?? "Local news", icon: "newspaper.fill")
                    ForEach(game.news.prefix(3)) { item in
                        NewsCard(item: item)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Chambers")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(item: $activeItem) { item in
                if let county = game.county, let judgeName = game.judgeName {
                    switch item {
                    case .trial(let courtCase, let resume):
                        CourtroomView(courtCase: courtCase, judgeName: judgeName, county: county, resume: resume)
                            .environmentObject(game)
                    case .hearing(let hearing):
                        HearingView(hearing: hearing, judgeName: judgeName, county: county)
                            .environmentObject(game)
                    case .calendar(let call):
                        CalendarCallView(call: call)
                            .environmentObject(game)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.mahogany)
            VStack(alignment: .leading, spacing: 2) {
                Text("Hon. \(game.judgeName ?? "")")
                    .font(.system(.title2, design: .serif).weight(.bold))
                Text("\(game.title) · \(game.county?.name ?? "")")
                    .font(.subheadline)
                    .foregroundStyle(Theme.gold)
                Text(SentenceFormat.date(game.currentDate) + (game.scheduled.isEmpty ? "" : " · \(game.scheduled.count) continued matter\(game.scheduled.count == 1 ? "" : "s") pending"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
    }

    private var docketCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let day = game.today {
                HStack(alignment: .firstTextBaseline) {
                    SectionTitle(text: "Today's calendar", icon: "calendar")
                    Spacer()
                    Label(CourtCalendar.time(day.clock), systemImage: "clock.fill")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Theme.gold)
                }
                Text(CourtCalendar.dayTitle(day.date)).font(.system(.title3, design: .serif).weight(.bold))
                Text(day.kind.label + (day.sessionDay > 0 ? " · Day \(day.sessionDay) of 5" : ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if Calendar.current.component(.hour, from: day.clock) >= 17 && !day.isComplete {
                    Label("Court is running late.", systemImage: "moon.fill").font(.caption).foregroundStyle(.orange)
                }

                ForEach(day.entries) { entry in
                    Button {
                        Haptics.tap()
                        activeItem = game.open(entry.id)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: statusIcon(entry))
                                .font(.title3)
                                .foregroundStyle(statusColor(entry))
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.title).font(.subheadline.weight(.semibold)).multilineTextAlignment(.leading)
                                Text(entry.subtitle).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                                if let note = entry.note, entry.isOpen {
                                    Text(note).font(.caption2).foregroundStyle(.purple).multilineTextAlignment(.leading)
                                }
                                if let outcome = entry.outcome, !entry.isOpen {
                                    Text(outcome).font(.caption2).foregroundStyle(.secondary).lineLimit(2).multilineTextAlignment(.leading)
                                }
                                if entry.isOpen, case .trial(let c) = entry.matter, c.defendant.isReturning {
                                    Label("You've seen this defendant before.", systemImage: "arrow.uturn.left")
                                        .font(.caption2).foregroundStyle(.purple)
                                }
                            }
                            Spacer()
                            if entry.isOpen {
                                Text(entry.status == .inProgress ? "Resume" : "~\(entry.estimatedMinutes / 60 > 0 ? "\(entry.estimatedMinutes / 60)h " : "")\(entry.estimatedMinutes % 60)m")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemFill)).opacity(entry.isOpen ? 1 : 0.5))
                    }
                    .buttonStyle(.plain)
                    .disabled(!entry.isOpen)
                }

                if day.isComplete {
                    let next = game.nextCourtDate
                    PrimaryButton(title: "Adjourn for the Day", icon: "moon.stars.fill") {
                        Haptics.gavel()
                        withAnimation { game.adjourn() }
                    }
                    let plan = game.nextCourtDayKind
                    Text("Next court date: \(CourtCalendar.dayTitle(next))"
                         + (plan.newSession ? ". Your criminal session is over; the next one starts then."
                            : (plan.kind == .specialSetting ? ", a special setting for continued matters." : ".")))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Take the matters in any order. When the calendar is clear, you can adjourn.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .card(tint: Theme.gold)
    }

    /// Appeals decided, releases, and arrests since the last court day, with appeals first.
    private var digestCard: some View {
        let appeals = game.digest.filter { $0.kind == .appeal || $0.kind == .exoneration }
        let others = game.digest.filter { $0.kind != .appeal && $0.kind != .exoneration }
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionTitle(text: "Since you last sat", icon: "envelope.open.fill")
                Spacer()
                Button("Dismiss") { withAnimation { game.clearDigest() } }
                    .font(.caption.weight(.semibold))
            }
            if !appeals.isEmpty {
                Text("Appellate decisions").font(.caption.weight(.bold)).foregroundStyle(.orange)
                ForEach(appeals) { item in digestRow(item, highlight: true) }
            }
            if !others.isEmpty {
                if !appeals.isEmpty { Divider() }
                ForEach(others.prefix(6)) { item in digestRow(item, highlight: false) }
                if others.count > 6 {
                    Text("And \(others.count - 6) more in Records → News.").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .card(tint: appeals.isEmpty ? nil : .orange)
    }

    private func digestRow(_ item: NewsItem, highlight: Bool) -> some View {
        DisclosureGroup {
            Text(item.body).font(.callout).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
            if let docket = item.docket {
                Text(docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
        } label: {
            Label {
                Text(item.headline).font(.subheadline.weight(highlight ? .semibold : .regular)).multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: item.kind.icon).foregroundStyle(highlight ? Color.orange : Theme.gold)
            }
        }
        .tint(.primary)
    }

    private func statusIcon(_ entry: DocketEntry) -> String {
        switch entry.status {
        case .pending: return entry.icon
        case .inProgress: return "pause.circle.fill"
        case .done: return "checkmark.circle.fill"
        case .continued: return "arrow.forward.circle.fill"
        }
    }

    private func statusColor(_ entry: DocketEntry) -> Color {
        switch entry.status {
        case .pending: return Theme.gold
        case .inProgress: return .orange
        case .done: return .green
        case .continued: return .purple
        }
    }
}

struct CourthouseView: View {
    let county: County

    var body: some View {
        List {
            Section("Superior Court") {
                row("Clerk of Superior Court", county.clerk)
                row("Courthouse", county.courthouse)
                row("County seat", county.seat)
            }
            Section("District Attorney's Office") {
                row("District Attorney", county.districtAttorney)
                ForEach(county.assistantDAs, id: \.self) { row("Assistant District Attorney", $0) }
            }
            Section("Defense bar") {
                row("Chief Public Defender", county.chiefPublicDefender)
                ForEach(county.assistantPDs, id: \.self) { row("Assistant Public Defender", $0) }
                ForEach(county.privateCounsel, id: \.self) { row("Private counsel", $0) }
            }
            Section("Law enforcement") {
                row("Sheriff", county.sheriff)
                row("Chief of Police, Port Hollis", county.policeChief)
                ForEach(county.detectives, id: \.self) { row("\($0.title), \($0.agency)", $0.name) }
                ForEach(county.officers, id: \.self) { row("\($0.title), \($0.agency)", $0.name) }
                ForEach(county.troopers, id: \.self) { row("Trooper, N.C. State Highway Patrol", $0) }
            }
            Section("Communities") {
                Text(county.towns.joined(separator: " · "))
            }
        }
        .navigationTitle(county.name)
    }

    private func row(_ role: String, _ name: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.body)
            Text(role).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct RecordsView: View {
    @EnvironmentObject private var game: GameState
    @State private var section = 3
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            List {
                Picker("Records", selection: $section) {
                    Text("Calendar").tag(3)
                    Text("Cases").tag(0)
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

                Section {
                    Button("Leave the Bench and Start Over", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("Records")
            .confirmationDialog("Leave the bench? This erases your county, cases, and records.",
                                isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Leave the bench", role: .destructive) { game.resetCareer() }
            }
        }
    }

    @ViewBuilder
    private var appealsSection: some View {
        let pendingAppeals = game.appeals.filter(\.isPending)
        let decided = game.appeals.filter { !$0.isPending }
        Section("Pending") {
            if pendingAppeals.isEmpty { Text("No appeals pending.").foregroundStyle(.secondary) }
            ForEach(pendingAppeals) { appeal in
                NavigationLink { AppealDetail(appeal: appeal, today: game.currentDate) } label: { AppealRow(appeal: appeal, today: game.currentDate) }
            }
        }
        if !decided.isEmpty {
            Section("Decided") {
                ForEach(decided) { appeal in
                    NavigationLink { AppealDetail(appeal: appeal, today: game.currentDate) } label: { AppealRow(appeal: appeal, today: game.currentDate) }
                }
            }
        }
    }

    @ViewBuilder
    private var calendarSection: some View {
        Section("Coming up") {
            if game.scheduled.isEmpty {
                Text("Nothing has been continued to a later date.").foregroundStyle(.secondary)
            }
            ForEach(game.scheduled) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(CourtCalendar.dayTitle(item.date)).font(.caption.weight(.bold)).foregroundStyle(Theme.gold)
                    Text(item.entry.title).font(.subheadline.weight(.semibold))
                    Text(item.entry.subtitle).font(.caption).foregroundStyle(.secondary)
                    if let note = item.entry.note { Text(note).font(.caption2).foregroundStyle(.purple) }
                }
            }
        }
        let days = Dictionary(grouping: game.history) { Calendar.current.startOfDay(for: $0.date) }
        ForEach(days.keys.sorted(by: >), id: \.self) { day in
            Section(CourtCalendar.dayTitle(day)) {
                ForEach(days[day] ?? []) { record in
                    NavigationLink {
                        CaseRecordDetail(record: record)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(record.caption).font(.subheadline.weight(.semibold))
                            Text(record.outcome).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            if let appeal = record.appealStatus {
                                Text(appeal).font(.caption2.weight(.semibold)).foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var casesSection: some View {
        Section {
            HStack {
                stat("\(game.trialsHeard)", "Cases")
                Spacer()
                stat("\(game.hearingsHeard)", "Hearings")
                Spacer()
                stat("\(game.people.filter { $0.status == .incarcerated }.count)", "In custody")
                Spacer()
                stat("\(game.people.filter { $0.status == .probation }.count)", "On probation")
            }
        }
        Section("Career ledger") {
            let trials = game.history.filter { $0.resolvedKind == "trial" }
            let s = game.stats
            ledgerRow("Convictions", trials.filter { $0.outcome.contains("Guilty") || $0.outcome.contains("No contest") }.count)
            ledgerRow("Acquittals and dismissals", trials.filter { $0.outcome.hasPrefix("Not guilty") || $0.outcome.hasPrefix("Dismissed") }.count)
            ledgerRow("Guilty pleas", trials.filter { $0.outcome.contains("plea)") || $0.outcome.contains("No contest") }.count)
            ledgerRow("Returning defendants", trials.filter(\.returningDefendant).count)
            ledgerRow("Felony sentences below the presumptive range", s.belowPresumptive)
            ledgerRow("Felony sentences within the presumptive range", s.withinPresumptive)
            ledgerRow("Felony sentences above the presumptive range", s.abovePresumptive)
            ledgerRow("Active sentences", s.activeSentences)
            ledgerRow("Suspended sentences", s.suspendedSentences)
            ledgerRow("Probation completed", s.probationCompleted)
            ledgerRow("Probation revoked", s.probationRevoked)
            ledgerRow("Released from custody", s.releasedFromPrison)
            ledgerRow("Affirmed on appeal", trials.filter { $0.appealStatus == "Affirmed on appeal" }.count)
            ledgerRow("Reversed or vacated on appeal", trials.filter { ($0.appealStatus ?? "").contains("New trial") || ($0.appealStatus ?? "").contains("vacated") || ($0.appealStatus ?? "").contains("reversed") }.count)
            ledgerRow("Exonerations", s.exonerations)
        }
        Section("Docket history") {
            if game.history.isEmpty {
                Text("No cases heard yet.").foregroundStyle(.secondary)
            }
            ForEach(game.history) { record in
                NavigationLink {
                    CaseRecordDetail(record: record)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.caption).font(.subheadline.weight(.semibold))
                        Text("\(record.docket) · \(SentenceFormat.shortDate(record.date))")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                        Text(record.outcome).font(.caption)
                        if let appeal = record.appealStatus {
                            Text(appeal).font(.caption2.weight(.semibold)).foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var peopleSection: some View {
        let sentenced = game.people.filter { person in
            person.status != .free && (person.priors.contains { $0.fromThisCourt } || (person.probation?.imposedInThisCourt ?? false))
        }
        if !sentenced.isEmpty {
            Section("Serving a sentence you imposed") {
                ForEach(sentenced.sorted { $0.name < $1.name }) { person in
                    NavigationLink {
                        PersonDetail(person: person, today: game.currentDate)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name).font(.subheadline.weight(.semibold))
                                Text(statusLine(person)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Pill(text: person.status.label, color: statusColor(person.status))
                        }
                    }
                }
            }
        }
        Section("Everyone who has appeared before you") {
            if game.people.isEmpty {
                Text("No one yet.").foregroundStyle(.secondary)
            }
            ForEach(game.people.sorted { ($0.appearances.last?.date ?? .distantPast) > ($1.appearances.last?.date ?? .distantPast) }) { person in
                NavigationLink {
                    PersonDetail(person: person, today: game.currentDate)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.name).font(.subheadline.weight(.semibold))
                            Text("\(person.appearances.count) appearance\(person.appearances.count == 1 ? "" : "s") · \(person.priors.count) conviction\(person.priors.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Pill(text: person.status.label, color: statusColor(person.status))
                    }
                }
            }
        }
    }

    private func statusLine(_ person: PersonRecord) -> String {
        switch person.status {
        case .incarcerated:
            guard let release = person.releaseDate else { return "In custody" }
            return release == .distantFuture ? "Life without parole" : "Release projected \(SentenceFormat.shortDate(release))"
        case .probation:
            return person.probation.map { "Probation ends \(SentenceFormat.shortDate($0.ends))" } ?? "On probation"
        case .free:
            return ""
        }
    }

    @ViewBuilder
    private var newsSection: some View {
        Section(game.county?.newspaper ?? "News") {
            ForEach(game.news) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Label(SentenceFormat.shortDate(item.date), systemImage: item.kind.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.headline).font(.system(.subheadline, design: .serif).weight(.semibold))
                    Text(item.body).font(.caption)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func ledgerRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label).font(.callout)
            Spacer()
            Text("\(value)").font(.callout.monospacedDigit().weight(.semibold))
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack {
            Text(value).font(.system(.title3, design: .rounded).weight(.bold))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private func statusColor(_ status: PersonRecord.Status) -> Color {
        switch status {
        case .free: return .secondary
        case .probation: return .orange
        case .incarcerated: return Theme.bad
        }
    }
}

struct CaseRecordDetail: View {
    @EnvironmentObject private var game: GameState
    let record: CaseRecord

    var body: some View {
        List {
            Section {
                Text(record.headline).font(.system(.headline, design: .serif))
                Text("\(record.docket) · \(SentenceFormat.date(record.date))").font(.caption.monospaced())
                if record.returningDefendant {
                    Label("Returning defendant", systemImage: "arrow.uturn.left").foregroundStyle(.purple)
                }
            }
            Section("Outcome") {
                Text(record.outcome)
                ForEach(record.judgments, id: \.self) { Text($0).font(.callout) }
            }
            if let tracker = game.appeals.first(where: { $0.docket == record.docket }) {
                Section("Appeal") {
                    NavigationLink { AppealDetail(appeal: tracker, today: game.currentDate) } label: {
                        AppealRow(appeal: tracker, today: game.currentDate)
                    }
                }
            } else if let appeal = record.appealStatus {
                Section("Appeal") { Text(appeal) }
            }
        }
        .navigationTitle(record.caption)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PersonDetail: View {
    @EnvironmentObject private var game: GameState
    let person: PersonRecord
    let today: Date

    var body: some View {
        List {
            Section {
                Text("Age \(person.age(on: today)) · \(person.occupation)")
                Text(person.background).font(.callout).foregroundStyle(.secondary)
            }
            Section("Status today") {
                PersonStatusCard(person: person, today: today,
                                 appeals: game.appeals.filter { $0.personID == person.id },
                                 upcoming: game.scheduled.filter { item in
                                     switch item.entry.matter {
                                     case .trial(let c): return c.defendant.personID == person.id
                                     case .hearing(let h): return h.personID == person.id
                                     case .calendar: return false
                                     }
                                 })
            }
            Section("Appearances in your court") {
                ForEach(Array(person.appearances.enumerated()), id: \.offset) { _, appearance in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(appearance.docket) · \(SentenceFormat.shortDate(appearance.date))").font(.caption.monospaced())
                        Text(appearance.charges).font(.subheadline.weight(.semibold))
                        Text(appearance.outcome).font(.caption)
                    }
                }
            }
            Section("Criminal record") {
                if person.priors.isEmpty {
                    Text("No convictions").foregroundStyle(.secondary)
                }
                ForEach(person.priors) { PriorRow(prior: $0) }
            }
        }
        .navigationTitle(person.name)
    }
}
