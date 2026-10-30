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
                CourtCalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                RecordsView()
                    .tabItem { Label("Records", systemImage: "archivebox.fill") }
                CorrectionsView()
                    .tabItem { Label("Corrections", systemImage: "lock.shield.fill") }
                    .badge(game.corrections?.openNotice?.kind == .releases ? 1 : 0)
                LawLibraryView()
                    .tabItem { Label("Law Library", systemImage: "books.vertical.fill") }
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var game: GameState
    @State private var name = ""
    // A career opens on a Monday, so the first week is a full week with its calendar call.
    @State private var startDay = CourtCalendar.weekday(onOrAfter: CourtCalendar.monday(onOrAfter: Date()))
    @State private var openingTime = CourtCalendar.opening(on: Date(), minutesAfterMidnight: 9 * 60 + 30)

    var body: some View {
        FixedWidthScroll {
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
                    Text("You set your own court calendar: the days you sit, how many trials and hearings each day takes, and when each case is tried. Each week opens with a calendar call on the first day you sit. There is no score: only the record you build.")
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
            FixedWidthScroll {
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
                    if let notice = game.corrections?.openNotice { sheriffCard(notice) }
                    docketCard
                    if !game.arrestOrders.isEmpty { arrestOrdersCard }
                    if let survey = game.reputation.first { standingCard(survey) }
                    if game.history.contains(where: { $0.resolvedKind == "trial" }), let county = game.county { courthouseMoodCard(county) }

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
                    Stepper("Take \(leaveWeeks) week\(leaveWeeks == 1 ? "" : "s") off", value: $leaveWeeks, in: 1...12)
                    LabeledContent("Back on the bench", value: CourtCalendar.dayTitle(game.leaveReturnDate(weeks: leaveWeeks)))
                    LabeledContent("Leave left this year", value: "\(game.leaveLeft) court days")
                } footer: {
                    Text("Time keeps moving while you're away: sentences end, people are released, probation runs its course, and appeals are decided. Matters set during your leave move to the first days with room after it. To book single days, use the Calendar tab.")
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
                Text("Week \(game.weekNumber) · " + SentenceFormat.date(game.currentDate) + (game.scheduled.isEmpty ? "" : " · \(game.scheduled.count) matter\(game.scheduled.count == 1 ? "" : "s") set for later days"))
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
                    SectionTitle(text: "Today's docket", icon: "calendar")
                    Spacer()
                }
                Text(CourtCalendar.dayTitle(day.date)).font(.system(.title3, design: .serif).weight(.bold))
                let remaining = day.entries.filter(\.isOpen).count
                Text("Week \(game.weekNumber) on the bench" + (day.isComplete ? " · Docket clear" : " · \(remaining) matter\(remaining == 1 ? "" : "s") left"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !game.awaiting.isEmpty {
                    let urgent = game.awaiting.filter { game.urgency(of: $0).level >= .urgent }.count
                    Label("\(game.awaiting.count) case\(game.awaiting.count == 1 ? " is" : "s are") waiting for you to set a trial date"
                          + (urgent > 0 ? ", \(urgent) urgent" : "") + ". Set dates in the Calendar tab.",
                          systemImage: "tray.full.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(urgent > 0 ? Theme.bad : Theme.gold)
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
                            if entry.isOpen && entry.status == .inProgress {
                                Text(entry.resume == nil ? "Start over" : "Resume")
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

                let next = game.nextCourtDate
                let open = day.entries.filter(\.isOpen).count
                PrimaryButton(title: "Adjourn for the Day", icon: "moon.stars.fill") {
                    Haptics.gavel()
                    withAnimation { game.adjourn() }
                }
                Text((open > 0 ? "\(open) matter\(open == 1 ? "" : "s") not reached will go to the next day with room. " : "")
                     + "Court next sits \(CourtCalendar.dayTitle(next)). The world moves to that day: sentences run, appeals come down, and new cases are filed.")
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
            }
        }
        .card(tint: Theme.gold)
    }

    /// What the lawyers who appear before the judge are saying, from what the judge has done.
    /// The sheriff's letter about the jail, until the count comes down.
    private func sheriffCard(_ notice: SheriffNotice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: notice.kind == .releases ? "From the sheriff: early releases" : "From the sheriff",
                         icon: notice.kind == .releases ? "exclamationmark.triangle.fill" : "envelope.fill")
            Text(notice.message).font(.system(.callout, design: .serif)).italic()
            Text(notice.kind == .releases ? "Open the Corrections tab to choose who goes before the sheriff does." : "The Corrections tab shows who is in the jail and why.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .card(tint: notice.kind == .releases ? Theme.bad : nil)
    }

    private func courthouseMoodCard(_ county: County) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "Around the courthouse", icon: "bubble.left.and.bubble.right.fill")
            Text(game.mood.line(prosecutor: "District Attorney \(county.districtAttorney)"))
                .font(.system(.callout, design: .serif)).italic()
            Text(game.mood.line(defender: "Chief Public Defender \(county.chiefPublicDefender)"))
                .font(.system(.callout, design: .serif)).italic()
            Text(Community.townTalk(standing: game.stats.communityStanding ?? 0))
                .font(.system(.callout, design: .serif)).italic()
            Text("Prosecutors remember acquittals and light sentences, and defenders remember prison terms. The public remembers how the cases it followed ended, and the newspaper poll at New Year shows it. The DA's plea offers at your calendar calls follow the office's mood.")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .card()
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
    /// Orders for arrest the court signed for failures to appear, and where each stands.
    private var arrestOrdersCard: some View {
        let open = game.arrestOrders.filter { !$0.resolved }
        let shown = (open.isEmpty ? Array(game.arrestOrders.prefix(3)) : Array(open.prefix(8)))
        return CollapsibleSection(title: "Orders for arrest", icon: "person.badge.shield.checkmark.fill",
                                  summary: "\(open.filter { $0.servedOn > game.currentDate && !$0.served }.count) outstanding · \(open.filter { $0.served || $0.servedOn <= game.currentDate }.count) in custody",
                                  expanded: false) {
            if game.arrestOrders.contains(where: { $0.served || $0.resolved }) {
                Button("Clear served orders") { withAnimation { game.clearServedArrestOrders() } }
                    .font(.caption.weight(.semibold))
            }
            ForEach(shown) { order in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(order.personName).font(.subheadline.weight(.semibold))
                        Spacer()
                        let outstanding = !order.served && order.servedOn > game.currentDate
                        Pill(text: order.resolved ? "Resolved" : (outstanding ? "Outstanding" : "In custody"),
                             color: order.resolved ? .secondary : (outstanding ? .orange : Theme.gold))
                    }
                    Text("\(order.docket) · \(order.offense) · issued \(SentenceFormat.shortDate(order.issued))")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(order.status(on: game.currentDate)).font(.caption)
                }
                .padding(.vertical, 2)
            }
        }
        .card()
    }

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
        // Decisions shown in "From the Court of Appeals" aren't repeated here.
        let appeals = game.digest.filter { ($0.kind == .appeal && game.freshAppeals.isEmpty) || $0.kind == .exoneration }
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

// CaseRecordDetail and PersonDetail live in RecordDocuments.swift and PersonRecordView.swift.
