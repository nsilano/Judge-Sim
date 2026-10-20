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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your first day on the bench").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    DatePicker("First court date", selection: $startDay, displayedComponents: .date)
                    DatePicker("Court opens at", selection: $openingTime,
                               in: CourtCalendar.opening(on: Date(), minutesAfterMidnight: 8 * 60)...CourtCalendar.opening(on: Date(), minutesAfterMidnight: 11 * 60),
                               displayedComponents: .hourAndMinute)
                    Text("Court sits every week. Each week opens with a Monday calendar call, then you take the week's trials and hearings in any order, and adjourn for the week when the calendar is clear. There is no score: only the record you build.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))

                PrimaryButton(title: "Take the Oath of Office", icon: "hand.raised.fill",
                              enabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    Haptics.gavel()
                    let time = CourtCalendar.calendar.dateComponents([.hour, .minute], from: openingTime)
                    let start = CourtCalendar.calendar.date(bySettingHour: time.hour ?? 9, minute: time.minute ?? 30, second: 0, of: startDay) ?? startDay
                    game.startCareer(name: name.trimmingCharacters(in: .whitespaces), start: start)
                }

                Text(LawLibrary.disclaimer)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .background(Theme.background)
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
    @State private var showLeave = false
    @State private var leaveWeeks = 2
    @State private var confirmStepDown = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        VersionBadge()
                    }
                    header
                    if game.unseated { unseatedCard }
                    if !game.freshAppeals.isEmpty {
                        appealsDecidedCard
                    }
                    if !game.digest.isEmpty {
                        digestCard
                    }
                    docketCard
                    if let survey = game.reputation.first { standingCard(survey) }

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
            .background(Theme.background)
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
            .sheet(isPresented: $showLeave) { leaveSheet }
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

    private var leaveSheet: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("Skip \(leaveWeeks) court week\(leaveWeeks == 1 ? "" : "s")", value: $leaveWeeks, in: 1...12)
                    LabeledContent("Back on the bench", value: CourtCalendar.dayTitle(game.leaveReturnDate(weeks: leaveWeeks)))
                } footer: {
                    Text("Time keeps moving while you're away: sentences end, people are released, probation runs its course, and appeals are decided. Matters continued into your leave are reset to your first day back. You'll get a summary when you return.")
                }
            }
            .benchBackground()
            .navigationTitle("Time Off")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showLeave = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Take Leave") {
                        showLeave = false
                        withAnimation { game.takeLeave(weeks: leaveWeeks) }
                    }
                }
            }
        }
        .presentationDetents([.medium])
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
                Text("Week \(game.weekNumber) · " + SentenceFormat.date(game.currentDate) + (game.scheduled.isEmpty ? "" : " · \(game.scheduled.count) matter\(game.scheduled.count == 1 ? "" : "s") set for later weeks"))
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
                    SectionTitle(text: "This week's calendar", icon: "calendar")
                    Spacer()
                    Label(day.clock.formatted(.dateTime.weekday(.abbreviated)) + " " + CourtCalendar.time(day.clock), systemImage: "clock.fill")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Theme.gold)
                }
                Text(CourtCalendar.weekTitle(day.date)).font(.system(.title3, design: .serif).weight(.bold))
                let remaining = day.entries.filter(\.isOpen).count
                Text("Week \(game.weekNumber) on the bench · Now in court: \(day.clock.formatted(.dateTime.weekday(.wide)))"
                     + (day.isComplete ? "" : " · \(remaining) matter\(remaining == 1 ? "" : "s") left"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(game.holidaysThisWeek, id: \.0) { holiday in
                    Label("\(holiday.0.formatted(.dateTime.weekday(.wide))): \(holiday.1). The courthouse is closed.", systemImage: "flag.fill")
                        .font(.caption).foregroundStyle(Theme.gold)
                }
                if game.trialBacklog > 0 {
                    Label("\(game.trialBacklog) trial\(game.trialBacklog == 1 ? "" : "s") waiting for a later week (up to \(game.trialCap) a week)", systemImage: "tray.full.fill")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if CourtCalendar.isSameDay(day.clock, game.lastCourtDayThisWeek)
                    && CourtCalendar.calendar.component(.hour, from: day.clock) >= 17 && !day.isComplete {
                    Label("\(game.lastCourtDayThisWeek.formatted(.dateTime.weekday(.wide))) is running late. Finish the week's calendar before you adjourn.", systemImage: "moon.fill").font(.caption).foregroundStyle(.orange)
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
                                Text(entry.status == .inProgress ? (entry.resume == nil ? "Start over (+30m)" : "Resume") : "~\(entry.estimatedMinutes / 60 > 0 ? "\(entry.estimatedMinutes / 60)h " : "")\(entry.estimatedMinutes % 60)m")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.raised).opacity(entry.isOpen ? 1 : 0.5))
                    }
                    .buttonStyle(.plain)
                    .disabled(!entry.isOpen)
                }

                if day.isComplete {
                    let next = game.nextCourtDate
                    PrimaryButton(title: "Adjourn for the Week", icon: "moon.stars.fill") {
                        Haptics.gavel()
                        withAnimation { game.adjourn() }
                    }
                    Text("Next week's calendar opens \(CourtCalendar.dayTitle(next)). The world moves a week: sentences run, appeals come down, and new cases are filed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        Haptics.tap()
                        showLeave = true
                    } label: {
                        Label("Take Time Off…", systemImage: "beach.umbrella.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    Toggle(isOn: Binding(get: { game.lightWeeks }, set: { game.setLightWeeks($0) })) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Light weeks").font(.subheadline.weight(.semibold))
                            Text("Up to two trials and one hearing a week, for shorter sessions. Starts next week.").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .tint(Theme.gold)
                } else {
                    Text("Take the week's matters in any order. No new matter is called after 4:30 p.m.; when a day fills up, the next matter is heard the following morning. When the calendar is clear, you can adjourn for the week.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .card(tint: Theme.gold)
    }

    /// The voters have spoken; the judge decides what comes next.
    private var unseatedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "You lost the election", icon: "envelope.badge.fill")
            Text("Your term ends at the close of the year. A former Superior Court judge can still be commissioned to hear cases on emergency assignment, or you can step down and begin a new career somewhere else.")
                .font(.callout)
            PrimaryButton(title: "Keep Sitting as an Emergency Judge", icon: "hammer.fill") {
                withAnimation { game.continueAsEmergencyJudge() }
            }
            Button(role: .destructive) {
                confirmStepDown = true
            } label: {
                Label("Step Down and Start a New Career", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .confirmationDialog("Step down from the bench?", isPresented: $confirmStepDown, titleVisibility: .visible) {
                Button("Step Down and Erase This Career", role: .destructive) { withAnimation { game.resetCareer() } }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Every case, person, and news story from this career is erased. This can't be undone.")
            }
        }
        .card(tint: .orange)
    }

    /// The most recent bar survey.
    private func standingCard(_ survey: BarSurvey) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                surveyRow("Lawyers overall", survey.overall)
                surveyRow("Prosecutors", survey.prosecutors)
                surveyRow("Defense lawyers", survey.defenseBar)
                surveyRow("Public approval", survey.publicApproval)
                if let affirmed = survey.affirmedPercent {
                    Text("Affirmed on appeal: \(affirmed)% of decided appeals").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(survey.comments, id: \.self) { Text($0).font(.callout).italic() }
                if game.reputation.count > 1 {
                    Text("Earlier years: " + game.reputation.dropFirst().prefix(5).map { "\($0.year): \($0.overall)" }.joined(separator: " · "))
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.top, 6)
        } label: {
            HStack {
                SectionTitle(text: "Standing with the bar", icon: "person.3.sequence.fill")
                Spacer()
                Text("\(survey.year) · \(survey.overall)/100").font(.caption.weight(.semibold)).foregroundStyle(Theme.gold)
            }
        }
        .card()
    }

    private func surveyRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            ProgressView(value: Double(value), total: 100).frame(width: 110).tint(value >= 60 ? Theme.good : (value >= 40 ? .orange : Theme.bad))
            Text("\(value)").font(.subheadline.monospacedDigit()).frame(width: 30, alignment: .trailing)
        }
    }

    /// The Court of Appeals decided cases from this court since the judge last sat: upheld or changed, and why.
    private var appealsDecidedCard: some View {
        let decided = game.freshAppeals.compactMap { id in game.appeals.first { $0.id == id } }
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionTitle(text: "From the Court of Appeals", icon: "building.columns.fill")
                Spacer()
                Button("Dismiss") { withAnimation { game.clearFreshAppeals() } }
                    .font(.caption.weight(.semibold))
            }
            Text("\(decided.filter { !$0.wasReversed && !$0.isMoot }.count) upheld · \(decided.filter(\.wasReversed).count) changed"
                 + (decided.contains(where: \.isMoot) ? " · \(decided.filter(\.isMoot).count) moot" : ""))
                .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            ForEach(decided) { appeal in
                NavigationLink {
                    AppealDetail(appeal: appeal, today: game.currentDate)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appeal.caption).font(.system(.subheadline, design: .serif).weight(.semibold)).foregroundStyle(.primary)
                        AppealDecisionCard(appeal: appeal, compact: true)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .card()
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
        .benchBackground()
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
    @State private var section = 0
    @State private var confirmReset = false
    /// The stat tapped in the bar at the top of Cases; its list replaces the ledger until tapped again.
    @State private var focus: StatFocus?
    @State private var sort: PeopleSort = .recent

    /// How many recent matters the Cases tab lists before pointing to the Calendar and News tabs.
    static let recentLimit = 10

    enum StatFocus: String {
        case cases, hearings, custody, probation

        var title: String {
            switch self {
            case .cases: return "Cases heard"
            case .hearings: return "Violation hearings"
            case .custody: return "In custody now"
            case .probation: return "On probation now"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
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

                Section {
                    Button("Leave the Bench and Start Over", role: .destructive) { confirmReset = true }
                }
            }
            .benchBackground()
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
                        DocketIndexRow(record: record, showDate: false)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var casesSection: some View {
        Section {
            HStack {
                stat("\(game.trialsHeard)", "Cases", .cases)
                Spacer()
                stat("\(game.hearingsHeard)", "Hearings", .hearings)
                Spacer()
                stat("\(game.people.filter { $0.status == .incarcerated }.count)", "In custody", .custody)
                Spacer()
                stat("\(game.people.filter { $0.status == .probation }.count)", "On probation", .probation)
            }
        } footer: {
            Text(focus == nil ? "Tap a number to see who or what it counts." : "Tap it again to go back.")
        }
        if let focus {
            focusSection(focus)
        } else {
            ledgerAndHistory
        }
    }

    /// The list behind a number in the bar, right here on the same screen.
    @ViewBuilder
    private func focusSection(_ focus: StatFocus) -> some View {
        switch focus {
        case .cases, .hearings:
            let records = game.history.filter { $0.resolvedKind == (focus == .cases ? "trial" : "hearing") }
            Section {
                if records.isEmpty { Text("None yet.").foregroundStyle(.secondary) }
                ForEach(records.prefix(Self.recentLimit)) { record in
                    NavigationLink { CaseRecordDetail(record: record) } label: { DocketIndexRow(record: record) }
                }
            } header: {
                Text(focus.title)
            } footer: {
                if records.count > Self.recentLimit {
                    Text("The last \(Self.recentLimit) of \(records.count). The rest are on the Calendar tab, and the coverage is in News.")
                }
            }
        case .custody, .probation:
            let people = sort.sorted(game.people.filter { $0.status == (focus == .custody ? .incarcerated : .probation) })
            Section {
                if people.isEmpty { Text("No one right now.").foregroundStyle(.secondary) }
                ForEach(people) { person in
                    NavigationLink { PersonDetail(person: person, today: game.currentDate) } label: { PersonCompactRow(person: person) }
                }
            } header: {
                sortHeader(focus.title)
            }
        }
    }

    /// A section title with a sort menu beside it.
    private func sortHeader(_ title: String) -> some View {
        HStack {
            Text(title)
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

    @ViewBuilder
    private var ledgerAndHistory: some View {
        Section {
            DisclosureGroup("Career ledger") {
            let trials = game.history.filter { $0.resolvedKind == "trial" }
            let s = game.stats
            ledgerRow("Convictions at trial", trials.filter { $0.outcome.contains("Guilty") && !$0.outcome.contains("plea)") && !$0.outcome.contains("No contest") }.count)
            ledgerRow("Acquittals and dismissals at trial", trials.filter { $0.outcome.hasPrefix("Not guilty") || $0.outcome.hasPrefix("Dismissed") }.count)
            ledgerRow("Guilty pleas", trials.filter { $0.outcome.contains("plea)") || $0.outcome.contains("No contest") }.count)
            // A retrial of the same case isn't a defendant returning.
            let firstHeard = Dictionary(trials.map { ($0.docket, $0.date) }, uniquingKeysWith: { min($0, $1) })
            ledgerRow("Returning defendants", trials.filter { $0.returningDefendant && $0.date <= (firstHeard[$0.docket] ?? $0.date) }.count)
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
            ledgerRow("Let go, then charged again", s.chargedAgainAfterRelease ?? 0)
            ledgerRow("Stay-away order violations", s.orderViolations ?? 0)
            }
        }
        // An overview: the most recent matters only. The full history is on the Calendar tab, the stories in News.
        Section {
            if game.history.isEmpty {
                Text("No cases heard yet.").foregroundStyle(.secondary)
            }
            ForEach(game.history.prefix(Self.recentLimit)) { record in
                NavigationLink {
                    CaseRecordDetail(record: record)
                } label: {
                    DocketIndexRow(record: record)
                }
            }
        } header: {
            Text("Recent docket")
        } footer: {
            if game.history.count > Self.recentLimit {
                Text("Showing your last \(Self.recentLimit). Every earlier matter is on the Calendar tab, and the coverage is in News.")
            }
        }
    }

    @ViewBuilder
    private var peopleSection: some View {
        let sentenced = game.people.filter { person in
            (person.status != .free || person.postRelease != nil)
                && (person.priors.contains { $0.fromThisCourt } || (person.probation?.imposedInThisCourt ?? false))
        }
        if !sentenced.isEmpty {
            Section {
                ForEach(sort.sorted(sentenced)) { person in
                    NavigationLink { PersonDetail(person: person, today: game.currentDate) } label: { PersonCompactRow(person: person) }
                }
            } header: {
                sortHeader("Serving a sentence you imposed")
            }
        }
        Section {
            if game.people.isEmpty {
                Text("No one yet.").foregroundStyle(.secondary)
            }
            ForEach(sort.sorted(game.people)) { person in
                NavigationLink { PersonDetail(person: person, today: game.currentDate) } label: { PersonCompactRow(person: person) }
            }
        } header: {
            sortHeader("Everyone who has appeared before you")
        }
    }

    @ViewBuilder
    private var newsSection: some View {
        Section(game.county?.newspaper ?? "News") {
            ForEach(game.news) { item in
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
    }

    private func ledgerRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label).font(.callout)
            Spacer()
            Text("\(value)").font(.callout.monospacedDigit().weight(.semibold))
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

    private func statusColor(_ status: PersonRecord.Status) -> Color {
        switch status {
        case .free: return .secondary
        case .probation: return .orange
        case .incarcerated: return Theme.bad
        }
    }
}

// CaseRecordDetail and PersonDetail live in RecordDocuments.swift and PersonRecordView.swift.
