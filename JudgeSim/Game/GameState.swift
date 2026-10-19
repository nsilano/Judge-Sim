import Foundation
import SwiftUI

struct CaseRecord: Identifiable, Codable, Hashable {
    var id = UUID()
    var docket: String
    var caption: String
    var headline: String
    var category: LawCategory
    var date: Date
    var defendantID: UUID
    var outcome: String
    var judgments: [String]
    var returningDefendant: Bool
    var appealStatus: String?
    /// "trial", "hearing", or "calendar" (optional for older saves).
    var kind: String?
    /// The appeal taken from this judgment, if any (optional for older saves).
    var appealID: UUID? = nil

    var resolvedKind: String {
        if let kind { return kind }
        return docket.contains("(PV)") ? "hearing" : "trial"
    }
}

/// A neutral tally of how a career has gone. No scoring; just the record.
struct CareerStats: Codable, Hashable {
    var belowPresumptive = 0
    var withinPresumptive = 0
    var abovePresumptive = 0
    var activeSentences = 0
    var suspendedSentences = 0
    var probationCompleted = 0
    var probationRevoked = 0
    var releasedFromPrison = 0
    var exonerations = 0
    /// People this court let go, by acquittal, dismissal, or probation, who were charged with a new crime (optional for older saves).
    var chargedAgainAfterRelease: Int? = nil
    /// Violations of stay-away orders this court entered.
    var orderViolations: Int? = nil
}

/// What's on today's calendar.
enum DocketItem: Identifiable {
    case trial(CourtCase, CaseSnapshot?)
    case hearing(ViolationHearing)
    case calendar(CalendarCall)

    var id: UUID {
        switch self {
        case .trial(let c, _): return c.id
        case .hearing(let h): return h.id
        case .calendar(let call): return call.id
        }
    }
}

private struct SaveData: Codable {
    var judgeName: String?
    var county: County?
    var currentDate: Date
    var docketSequence: Int
    var history: [CaseRecord]
    var people: [PersonRecord]
    var news: [NewsItem]
    var pending: [PendingEvent]
    var currentCase: CourtCase?
    var currentHearing: ViolationHearing?
    var recentTemplates: [String]
    var usedSignatures: [String]?
    var seedBase: UInt64
    var currentCalendar: CalendarCall?
    var retrials: [CourtCase]?
    var stats: CareerStats?
    var today: CourtDay?
    var scheduled: [ScheduledMatter]?
    var openingMinutes: Int?
    var sessionEnds: Date?
    var digest: [NewsItem]?
    var appeals: [AppealTracker]?
    var recentLineKeys: [UInt64]?
    var careerStart: Date?
    var weekNumber: Int?
    var lightWeeks: Bool?
    var yearStartStats: CareerStats?
    var reputation: [BarSurvey]?
    var lastYearReviewed: Int?
    var unseated: Bool?
    var reliefQueue: [ReliefMotion]?
    var murderLastWeek: Bool?
    var reoffenseQueue: [Reoffense]?
    var freshAppeals: [UUID]?
}

/// The judge's world: one county, a calendar, everyone who has come through the courtroom, and the local news.
@MainActor
final class GameState: ObservableObject {
    @Published var judgeName: String?
    @Published var county: County?
    @Published var currentDate = Date()
    @Published var history: [CaseRecord] = []
    @Published var people: [PersonRecord] = []
    @Published var news: [NewsItem] = []
    @Published private(set) var stats = CareerStats()
    /// Today's calendar in court.
    @Published private(set) var today: CourtDay?
    /// Matters continued to later dates.
    @Published private(set) var scheduled: [ScheduledMatter] = []
    /// The hour court opens each day, in minutes after midnight.
    @Published private(set) var openingMinutes = 9 * 60 + 30
    /// Every appeal taken from this court, pending or decided.
    @Published private(set) var appeals: [AppealTracker] = []
    /// What happened since the judge last sat: appeals decided, releases, new arrests.
    @Published private(set) var digest: [NewsItem] = []
    /// The last day of the current court week.
    private var sessionEnds = Date()
    /// A lighter docket each week: two trials and a hearing, for shorter sessions on the phone.
    @Published private(set) var lightWeeks = false
    /// Career standing: the bar's yearly survey of the judge, most recent first.
    @Published private(set) var reputation: [BarSurvey] = []
    /// Set when the judge lost an election; the career can continue on emergency assignment.
    @Published private(set) var unseated = false
    /// Career statistics as of January 1, for the year in review.
    private var yearStartStats: CareerStats?
    private var lastYearReviewed: Int?
    /// Post-conviction motions waiting for the next calendar call.
    private var reliefQueue: [ReliefMotion] = []
    /// New cases against people this court already judged, waiting for a place on the calendar.
    private var reoffenseQueue: [Reoffense] = []
    /// Appeals the Court of Appeals decided since the judge last sat, newest last.
    @Published private(set) var freshAppeals: [UUID] = []
    /// Whether last week's trial calendar had a murder case, so two murder weeks don't come back to back.
    private var murderLastWeek = false
    /// The Monday of the judge's first week on the bench.
    @Published private(set) var careerStart = Date()
    /// Which week on the bench the current calendar is, starting at 1. Weeks on leave don't count.
    @Published private(set) var weekNumber = 1
    // Kept only to bring forward a matter left open in an older save.
    private var currentCase: CourtCase?
    private var currentHearing: ViolationHearing?
    private var currentCalendar: CalendarCall?

    private var retrials: [CourtCase] = []
    private var pending: [PendingEvent] = []
    private var docketSequence = 1_000
    private var recentTemplates: [String] = []
    /// Fingerprints of testimony and argument the judge has read recently, so new cases steer away from them.
    private var recentLineKeys: [UInt64] = []
    private var usedSignatures: [String] = []
    private var seedBase: UInt64 = UInt64.random(in: 1...UInt64.max / 2)
    private let saveKey = "JudgeSim.nc.save.v1"

    init() {
        load()
    }

    var casesHeard: Int { history.filter { $0.resolvedKind != "continuance" }.count }
    var trialsHeard: Int { history.filter { $0.resolvedKind == "trial" }.count }
    var hearingsHeard: Int { history.filter { $0.resolvedKind == "hearing" }.count }

    /// The senior resident judge is the one with the longest continuous service in the district (G.S. 7A-41.1(a));
    /// the judges ahead of this one are assumed to have left the bench after about six years.
    var title: String {
        if emergencyJudge { return "Emergency Superior Court Judge" }
        let years = CourtCalendar.calendar.dateComponents([.year], from: careerStart, to: currentDate).year ?? 0
        return years >= 6 ? "Senior Resident Superior Court Judge" : "Resident Superior Court Judge"
    }

    /// After losing an election, a former judge can keep hearing cases on emergency assignment (G.S. 7A-52).
    var emergencyJudge: Bool { reputation.contains { $0.comments.contains(Self.unseatedMarker) } && !unseated }
    private static let unseatedMarker = "Lost reelection."

    func setLightWeeks(_ on: Bool) {
        lightWeeks = on
        save()
    }

    /// The judge keeps sitting, on emergency assignment, after losing an election.
    func continueAsEmergencyJudge() {
        unseated = false
        save()
    }

    /// The rest of the paper: letters, columns, courthouse life, follow-ups, and the police log.
    private func localPages(weekOf monday: Date, publishing date: Date) {
        guard let county, let judgeName else { return }
        var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(date.timeIntervalSince1970)) / 3_600) ^ 0x9E37)
        let start = CourtCalendar.monday(onOrBefore: monday)
        let waiting = scheduled.map(\.entry) + (today?.entries ?? [])
        let jailed = waiting.filter { entry in
            if case .trial(let c) = entry.matter { return c.background?.isJailed ?? false }
            return false
        }.count
        let sentenced = stats.belowPresumptive + stats.withinPresumptive + stats.abovePresumptive
        let ninetyDays = CourtCalendar.calendar.date(byAdding: .day, value: -90, to: date) ?? date
        let released = people.filter { person in
            person.status != .incarcerated && person.profile != nil
                && person.priors.contains { $0.fromThisCourt && $0.sentence.contains("active") }
                && (person.appearances.last?.date ?? date) < ninetyDays
        }
        let snapshot = NewsDesk.WeekSnapshot(
            paper: county.newspaper, county: county, judge: lastName(judgeName), date: date,
            verdicts: news.filter { $0.kind == .verdict && $0.date >= start },
            jailedAwaitingTrial: jailed,
            inPrison: people.filter { $0.status == .incarcerated }.count,
            onProbation: people.filter { $0.status == .probation }.count,
            recentReleases: Array(released.shuffled(using: &rng).prefix(3)),
            reversals: appeals.filter(\.wasReversed).count,
            harshShare: sentenced < 4 ? 0 : Double(stats.abovePresumptive) / Double(sentenced),
            lenientShare: sentenced < 4 ? 0 : Double(stats.belowPresumptive) / Double(sentenced),
            recentHeadlines: Set(news.prefix(80).map(\.headline)))
        for item in NewsDesk.weekly(snapshot, rng: &rng) { post(item) }
    }

    /// The bar survey at New Year's, the year in review, and every eighth November an election.
    private func yearlyEvents(from previous: Date, to next: Date) {
        guard let judgeName else { return }
        let cal = CourtCalendar.calendar
        let oldYear = cal.component(.year, from: previous)
        let newYear = cal.component(.year, from: next)
        let startYear = cal.component(.year, from: careerStart)
        let last = lastName(judgeName)

        // Election day: the first Tuesday after the first Monday in November.
        let crossedIntoNovember = (cal.component(.month, from: previous) <= 10 || oldYear < newYear) && cal.component(.month, from: next) >= 11
            && cal.component(.year, from: next) == newYear
        // An emergency judge isn't on the ballot.
        if crossedIntoNovember, !unseated, !emergencyJudge, Reputation.isElectionYear(newYear, careerStartYear: startYear) {
            var survey = Reputation.survey(year: newYear, stats: stats, appeals: appeals, history: history)
            var rng = SeededRNG(seed: seedBase ^ UInt64(newYear))
            let share = Reputation.voteShare(survey, rng: &rng)
            let percent = Int((share * 100).rounded())
            let won = share >= 0.5
            post(NewsItem(date: next, kind: .community,
                          headline: won ? "\(judgeName) wins another eight-year term" : "\(judgeName) unseated in Superior Court race",
                          body: won
                            ? "Voters returned Judge \(last) to the Hollis County Superior Court bench with \(percent) percent of the vote. " + (survey.affirmedPercent.map { "Supporters pointed to a record affirmed \($0) percent of the time on appeal." } ?? "")
                            : "Judge \(last) lost the Superior Court race with \(percent) percent of the vote. The challenger campaigned on the judge's sentencing record and the cases that came apart after trial.",
                          prominence: 3))
            if !won {
                survey.comments.append(Self.unseatedMarker)
                reputation.insert(survey, at: 0)
                unseated = true
            }
        }

        guard newYear > oldYear, lastYearReviewed != oldYear else { return }
        lastYearReviewed = oldYear
        // The term ends with the year: a judge who hasn't decided goes on emergency assignment.
        if unseated {
            unseated = false
            post(NewsItem(date: next, kind: .community, headline: "\(judgeName) to keep hearing cases on emergency assignment",
                          body: "Judge \(last)'s term ended December 31. The Chief Justice has commissioned the former judge to keep hearing cases in Hollis County on emergency assignment (G.S. 7A-52).",
                          prominence: 1))
        }
        var survey = Reputation.survey(year: oldYear, stats: stats, appeals: appeals, history: history)
        if let index = reputation.firstIndex(where: { $0.year == oldYear }) {
            // The election-year survey is already on file; bring it up to date and keep the election result.
            survey.comments += reputation[index].comments.filter { $0 == Self.unseatedMarker }
            reputation[index] = survey
        } else {
            reputation.insert(survey, at: 0)
        }
        post(NewsItem(date: next, kind: .community, headline: "Bar survey: lawyers rate Judge \(last)",
                      body: "In the Hollis County Bar's annual survey, lawyers who appeared before Judge \(last) gave an overall rating of \(survey.overall) out of 100. Prosecutors: \(survey.prosecutors). Defense lawyers: \(survey.defenseBar). A newspaper poll put public approval at \(survey.publicApproval) percent. " + survey.comments.joined(separator: " "),
                      prominence: 2))

        // The year in review.
        let base = yearStartStats ?? CareerStats()
        let inYear = history.filter { cal.component(.year, from: $0.date) == oldYear }
        let trials = inYear.filter { $0.resolvedKind == "trial" }.count
        let hearings = inYear.filter { $0.resolvedKind == "hearing" }.count
        let returning = inYear.filter { $0.resolvedKind == "trial" && $0.returningDefendant }.count
        let decided = appeals.filter { $0.decided.map { cal.component(.year, from: $0) == oldYear } ?? false }
        let reversed = decided.filter(\.wasReversed).count
        var lines = ["Judge \(last) heard \(trials) trial\(trials == 1 ? "" : "s") and \(hearings) violation hearing\(hearings == 1 ? "" : "s") in \(oldYear)."]
        let active = stats.activeSentences - base.activeSentences, suspended = stats.suspendedSentences - base.suspendedSentences
        if active + suspended > 0 { lines.append("\(active) active sentence\(active == 1 ? "" : "s") and \(suspended) suspended.") }
        if !decided.isEmpty { lines.append("The Court of Appeals decided \(decided.count) appeal\(decided.count == 1 ? "" : "s") from the court and reversed \(reversed).") }
        let released = stats.releasedFromPrison - base.releasedFromPrison
        let finished = stats.probationCompleted - base.probationCompleted
        let revoked = stats.probationRevoked - base.probationRevoked
        if released > 0 { lines.append("\(released) \(released == 1 ? "person" : "people") sentenced here came home from prison.") }
        if finished + revoked > 0 { lines.append("\(finished) finished probation; \(revoked) had it revoked.") }
        if returning > 0 { lines.append("\(returning) defendant\(returning == 1 ? " was" : "s were") back in the courtroom a second time.") }
        let exonerated = stats.exonerations - base.exonerations
        if exonerated > 0 { lines.append("\(exonerated) conviction\(exonerated == 1 ? " was" : "s were") later overturned as wrongful.") }
        let again = (stats.chargedAgainAfterRelease ?? 0) - (base.chargedAgainAfterRelease ?? 0)
        if again > 0 { lines.append("\(again) \(again == 1 ? "person" : "people") the court let go or sent home on probation \(again == 1 ? "was" : "were") charged with a new crime.") }
        let broken = (stats.orderViolations ?? 0) - (base.orderViolations ?? 0)
        if broken > 0 { lines.append("Stay-away orders from this court were violated \(broken) time\(broken == 1 ? "" : "s").") }
        post(NewsItem(date: next, kind: .community, headline: "\(oldYear): a year on the bench", body: lines.joined(separator: " "), prominence: 2))
        yearStartStats = stats
    }

    // MARK: Career

    func startCareer(name: String, start: Date) {
        judgeName = name
        county = County.generate(seed: seedBase)
        let parts = CourtCalendar.calendar.dateComponents([.hour, .minute], from: start)
        openingMinutes = Self.courtOpening((parts.hour ?? 9) * 60 + (parts.minute ?? 30))
        currentDate = CourtCalendar.weekday(onOrAfter: start)
        careerStart = CourtCalendar.monday(onOrBefore: currentDate)
        weekNumber = 1
        var rng = SeededRNG(seed: seedBase)
        docketSequence = rng.int(1_200...4_800)
        sessionEnds = sessionFriday(for: currentDate)
        if let county {
            news = [NewsItem(date: currentDate, kind: .community,
                             headline: "\(name) sworn in as Resident Superior Court Judge",
                             body: "In a ceremony at the \(county.courthouse), \(name) took the oath of office as a Resident Superior Court Judge for \(county.name). District Attorney \(county.districtAttorney), Chief Public Defender \(county.chiefPublicDefender), Sheriff \(county.sheriff), and Clerk of Superior Court \(county.clerk) attended.")]
        }
        today = buildDay(currentDate, kind: .trial, sessionDay: 1)
        save()
    }

    // MARK: The day in court

    private func sessionFriday(for date: Date) -> Date {
        var day = CourtCalendar.calendar.startOfDay(for: date)
        while CourtCalendar.calendar.component(.weekday, from: day) != 6 { day = CourtCalendar.calendar.date(byAdding: .day, value: 1, to: day) ?? day }
        return day
    }

    /// Calendar weeks since the career began, counting any leave. Older saves didn't count weeks sat, so this stands in.
    private var calendarWeekNumber: Int {
        let start = CourtCalendar.monday(onOrBefore: careerStart)
        let current = CourtCalendar.monday(onOrBefore: today?.date ?? currentDate)
        let days = CourtCalendar.calendar.dateComponents([.day], from: start, to: current).day ?? 0
        return max(1, days / 7 + 1)
    }

    /// Court opens between 8 and 11 in the morning.
    static func courtOpening(_ minutes: Int) -> Int { min(11 * 60, max(8 * 60, minutes)) }

    /// Moves the courtroom clock forward. No new matter is called after 4:30 p.m.: once the day's matters run that late,
    /// the next one is taken up the following weekday morning. On Friday the week runs late, but never past midnight.
    private func advanceClock(_ day: inout CourtDay, minutes: Int) {
        let cal = CourtCalendar.calendar
        let started = day.clock
        day.clock = cal.date(byAdding: .minute, value: minutes, to: day.clock) ?? day.clock
        var friday = sessionFriday(for: day.date)
        // When Friday is a holiday the week ends Thursday.
        while !CourtCalendar.isCourtDay(friday) && friday > day.date {
            friday = cal.date(byAdding: .day, value: -1, to: friday) ?? friday
        }
        let lastCall = cal.date(bySettingHour: 16, minute: 30, second: 0, of: started) ?? started
        if !day.isComplete, day.clock >= lastCall || !cal.isDate(day.clock, inSameDayAs: started) {
            let next = CourtCalendar.nextWeekday(after: started)
            if next <= friday {
                day.clock = CourtCalendar.opening(on: next, minutesAfterMidnight: openingMinutes)
            }
        }
        // Friday's calendar can run into the night, but not into the weekend.
        let lastMinute = cal.date(bySettingHour: 23, minute: 59, second: 0, of: friday) ?? friday
        day.clock = min(day.clock, lastMinute)
        currentDate = cal.startOfDay(for: day.clock)
    }

    /// Opens a matter on today's calendar.
    func open(_ entryID: UUID) -> DocketItem? {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.id == entryID }) else { return nil }
        let entry = day.entries[index]
        guard entry.isOpen else { return nil }
        if entry.status == .inProgress && entry.resume == nil {
            // The matter was left without a continuance; the court's time on it is spent, and it is called again from the start.
            advanceClock(&day, minutes: 30)
        }
        day.entries[index].status = .inProgress
        // A matter is heard on whatever day of the week the court reaches it, including a trial resumed after a continuance.
        let heard = CourtCalendar.calendar.startOfDay(for: day.clock)
        if entry.status == .pending {
            switch entry.matter {
            case .trial(var c):
                creditJailTime(&c, through: heard)
                c.sessionDate = heard
                day.entries[index].matter = .trial(c)
            case .hearing(var h):
                h.date = heard
                day.entries[index].matter = .hearing(h)
            case .calendar(var call):
                call.date = heard
                day.entries[index].matter = .calendar(call)
            }
        }
        today = day
        save()
        switch day.entries[index].matter {
        case .trial(let c): return .trial(c, entry.resume)
        case .hearing(let h): return .hearing(h)
        case .calendar(let call): return .calendar(call)
        }
    }

    /// Marks the matter done and moves the courtroom clock forward.
    private func finishEntry(matterID: UUID, outcome: String) {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.matterID == matterID }) else { return }
        day.entries[index].status = .done
        day.entries[index].outcome = outcome
        advanceClock(&day, minutes: day.entries[index].estimatedMinutes)
        today = day
    }

    /// Continues a matter to a later date. A trial picks up exactly where it left off.
    func continueMatter(_ matterID: UUID, to date: Date, reason: String, snapshot: CaseSnapshot?, requests: [EvidenceRequest] = []) {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.matterID == matterID }) else { return }
        let target = max(CourtCalendar.weekday(onOrAfter: date), nextCourtDate)
        var entry = day.entries[index]
        entry.status = .pending
        entry.resume = snapshot ?? entry.resume
        if case .trial(var c) = entry.matter, c.continuanceMotion != nil {
            // Any continuance disposes of a pending motion to continue.
            c.continuanceMotion = nil
            entry.matter = .trial(c)
        }
        entry.continuances += 1
        entry.requests = requests.isEmpty ? nil : requests
        entry.note = "Continued from \(SentenceFormat.shortDate(currentDate)): \(reason)"
            + (requests.isEmpty ? "" : " Follow-up ordered: \(requests.count) request\(requests.count == 1 ? "" : "s").")
        scheduled.append(ScheduledMatter(date: target, entry: entry))
        scheduled.sort { $0.date < $1.date }
        day.entries[index].status = .continued
        day.entries[index].outcome = "Continued to \(SentenceFormat.shortDate(target)). \(reason)"
        advanceClock(&day, minutes: 10)
        today = day
        if case .trial(let c) = entry.matter {
            history.insert(CaseRecord(docket: c.docket, caption: c.caption, headline: c.headline, category: c.category,
                                      date: currentDate, defendantID: c.defendant.personID,
                                      outcome: "Continued to \(SentenceFormat.shortDate(target))", judgments: [reason],
                                      returningDefendant: c.defendant.isReturning, appealStatus: nil, kind: "continuance"), at: 0)
        }
        save()
    }

    /// The next court date: the Monday after this court week.
    var nextCourtDate: Date {
        let base = today?.date ?? currentDate
        let saturday = CourtCalendar.calendar.date(byAdding: .day, value: 1, to: sessionFriday(for: base)) ?? base
        return CourtCalendar.weekday(onOrAfter: CourtCalendar.monday(onOrAfter: saturday))
    }

    /// The most trials the court takes up in a week; anything more waits for the next week.
    var trialCap: Int { lightWeeks ? 2 : 3 }
    /// The most matters on Monday's calendar call.
    private var calendarCap: Int { lightWeeks ? 4 : 6 }

    /// Trials set for a later week and waiting their turn.
    var trialBacklog: Int {
        scheduled.filter { if case .trial = $0.entry.matter { return true } else { return false } }.count
    }

    /// The holidays that close the courthouse during the current court week.
    var holidaysThisWeek: [(Date, String)] {
        CourtCalendar.holidays(inWeekOf: CourtCalendar.monday(onOrBefore: today?.date ?? currentDate))
    }

    static func isMurder(_ c: CourtCase) -> Bool {
        c.charges.contains { $0.law.id.hasPrefix("murder") }
    }

    /// The next court week always opens as a new criminal session.
    var nextCourtDayKind: (kind: CourtDay.Kind, newSession: Bool) { (.trial, true) }

    /// Closes the court week and opens next week's calendar.
    func adjourn() {
        guard let day = today, day.isComplete else { return }
        let next = nextCourtDate
        let week = weekNumber
        let review = weekInReview(day, week: week)
        let releasedBefore = stats.releasedFromPrison
        let completedBefore = stats.probationCompleted
        let appealsBefore = appeals.filter { !$0.isPending }.count
        let marker = news.first?.id
        advanceWorld(to: next)
        yearlyEvents(from: day.date, to: next)
        localPages(weekOf: day.date, publishing: next)
        var body = review
        let released = stats.releasedFromPrison - releasedBefore
        let completed = stats.probationCompleted - completedBefore
        let decided = appeals.filter { !$0.isPending }.count - appealsBefore
        var outside: [String] = []
        if released > 0 { outside.append("\(released) \(released == 1 ? "person" : "people") you sentenced left custody") }
        if completed > 0 { outside.append("\(completed) finished probation") }
        if decided > 0 { outside.append("the Court of Appeals decided \(decided) appeal\(decided == 1 ? "" : "s") from your court") }
        if !outside.isEmpty { body += " This past week, " + outside.joined(separator: ", ") + "." }
        weekNumber = week + 1
        sessionEnds = sessionFriday(for: next)
        today = buildDay(next, kind: .trial, sessionDay: 1)
        // Count what actually made this week's calendar after the trial cap, not everything set for it.
        let back = today?.entries.filter { $0.continuances > 0 }.count ?? 0
        if back > 0 { body += " \(back) continued matter\(back == 1 ? " is" : "s are") back on this week's calendar." }
        post(NewsItem(date: sessionFriday(for: day.date), kind: .community, headline: "Week \(week) in review", body: body))
        for (date, name) in CourtCalendar.holidays(inWeekOf: CourtCalendar.monday(onOrBefore: next)) {
            post(NewsItem(date: next, kind: .community, headline: "Courthouse closed \(date.formatted(.dateTime.weekday(.wide))) for \(name)",
                          body: "The \(county?.courthouse ?? "courthouse") will be closed \(SentenceFormat.shortDate(date)) for \(name), a state court holiday. Matters set that day are heard the next day court is in session.",
                          prominence: 0))
        }
        digest = Array(news.prefix { $0.id != marker })
        save()
    }

    /// A short account of the court week just finished.
    private func weekInReview(_ day: CourtDay, week: Int) -> String {
        var trials = 0, hearings = 0, calls = 0, continued = 0
        for entry in day.entries {
            switch (entry.matter, entry.status) {
            case (_, .continued): continued += 1
            case (.trial, _): trials += 1
            case (.hearing, _): hearings += 1
            case (.calendar(let call), _): calls += call.matters.count
            }
        }
        let start = CourtCalendar.monday(onOrBefore: day.date)
        let tally = day.tally ?? CourtDay.Tally()
        var parts: [String] = []
        parts.append("\(trials) trial\(trials == 1 ? "" : "s")")
        if hearings > 0 { parts.append("\(hearings) violation hearing\(hearings == 1 ? "" : "s")") }
        if calls > 0 { parts.append("\(calls) calendar matter\(calls == 1 ? "" : "s")") }
        var text = "Week \(week) on the bench (\(SentenceFormat.shortDate(start)) – \(SentenceFormat.shortDate(sessionFriday(for: start)))): " + parts.joined(separator: ", ") + "."
        var verdicts: [String] = []
        if tally.convictions > 0 { verdicts.append("\(tally.convictions) conviction\(tally.convictions == 1 ? "" : "s")") }
        if tally.withoutConviction > 0 { verdicts.append("\(tally.withoutConviction) ended without a conviction") }
        if tally.active > 0 { verdicts.append("\(tally.active) active prison sentence\(tally.active == 1 ? "" : "s")") }
        if !verdicts.isEmpty { text += " " + verdicts.joined(separator: ", ").capitalizedFirst + "." }
        if continued > 0 { text += " \(continued) matter\(continued == 1 ? " was" : "s were") continued." }
        return text
    }

    // MARK: Time off

    /// The Monday the judge would return to the bench after skipping `weeks` court weeks.
    func leaveReturnDate(weeks: Int) -> Date {
        let next = nextCourtDate
        return CourtCalendar.weekday(onOrAfter: CourtCalendar.monday(onOrAfter: CourtCalendar.calendar.date(byAdding: .day, value: 7 * max(1, weeks), to: next) ?? next))
    }

    /// Steps away from the bench. The world keeps moving: sentences end, appeals come down, people are released.
    /// Matters continued into the leave are reset to the first day back.
    func takeLeave(weeks: Int) {
        guard let day = today, day.isComplete, let judgeName else { return }
        let back = leaveReturnDate(weeks: weeks)
        let marker = news.first?.id
        post(NewsItem(date: sessionFriday(for: day.date), kind: .community, headline: "Week \(weekNumber) in review",
                      body: weekInReview(day, week: weekNumber)))
        weekNumber += 1

        var reset = 0
        for index in scheduled.indices where scheduled[index].date < back {
            scheduled[index].date = back
            scheduled[index].entry.note = (scheduled[index].entry.note ?? "") + " Reset to \(SentenceFormat.shortDate(back)) while the court was on leave."
            reset += 1
        }

        // Walk through the leave a week at a time so events land in order.
        var cursor = day.date
        let releasedBefore = stats.releasedFromPrison
        let completedBefore = stats.probationCompleted
        let appealsBefore = appeals.filter { !$0.isPending }.count
        while cursor < back {
            let previous = cursor
            cursor = min(back, CourtCalendar.calendar.date(byAdding: .day, value: 7, to: cursor) ?? back)
            advanceWorld(to: cursor)
            yearlyEvents(from: previous, to: cursor)
        }

        var summary = ["Judge \(lastName(judgeName)) returned to the bench after \(weeks) week\(weeks == 1 ? "" : "s") away."]
        let released = stats.releasedFromPrison - releasedBefore
        let completed = stats.probationCompleted - completedBefore
        let decided = appeals.filter { !$0.isPending }.count - appealsBefore
        if released > 0 { summary.append("\(released) \(released == 1 ? "person" : "people") you sentenced left custody.") }
        if completed > 0 { summary.append("\(completed) finished probation.") }
        if decided > 0 { summary.append("The Court of Appeals decided \(decided) appeal\(decided == 1 ? "" : "s") from your court.") }
        if reset > 0 { summary.append("\(reset) continued matter\(reset == 1 ? " was" : "s were") reset to your first day back.") }
        if released == 0 && completed == 0 && decided == 0 && reset == 0 { summary.append("It was a quiet stretch.") }
        post(NewsItem(date: back, kind: .community, headline: "Judge \(lastName(judgeName)) back from leave", body: summary.joined(separator: " ")))

        sessionEnds = sessionFriday(for: back)
        today = buildDay(back, kind: .trial, sessionDay: 1)
        digest = Array(news.prefix { $0.id != marker })
        save()
    }

    /// Starts following each appeal taken today, and puts any oral argument on the calendar. Returns the events
    /// tagged with the appeal they decide, ready to schedule.
    private func trackAppeals(_ events: [PendingEvent], docket: String, caption: String, personID: UUID, appellant: String, plea: Bool,
                              grounds: [String] = [], groundErrors: [Bool] = []) -> [PendingEvent] {
        var rng = SeededRNG(seed: seedBase ^ SeededRNG.stableHash(docket) ^ UInt64(appeals.count))
        let decisions = events.filter { $0.news.kind == .appeal && $0.news.docket == docket && !Appeals.isFollowUp($0) }
        guard let first = decisions.min(by: { $0.due < $1.due }) else { return events }
        let headline = first.news.headline
        let issue: String
        let byState = headline.contains("reinstates") || (first.news.body.contains("On appeal by the State"))
        if headline.contains("reinstates") {
            issue = "Whether the trial court erred in dismissing the charges for a speedy-trial violation"
        } else if docket.hasSuffix("(PV)") {
            issue = "Whether the court had authority to sanction the probationer as it did"
        } else if first.effect == .resentence || headline.contains("vacates sentence") || first.news.body.contains("remanded for resentencing") {
            issue = "Whether the sentence is authorized by North Carolina law"
        } else if plea {
            issue = "Sentencing issues following a plea (G.S. 15A-1444)"
        } else {
            issue = "The sufficiency of the evidence and the trial court's rulings on motions and objections"
        }
        var tracker = Appeals.tracker(for: first, caption: caption, personID: personID, filed: currentDate,
                                      appellant: byState ? "the State" : appellant, issue: issue, rng: &rng)
        tracker.docket = docket
        tracker.grounds = grounds.isEmpty ? nil : grounds
        tracker.groundErrors = groundErrors.isEmpty ? nil : groundErrors
        appeals.insert(tracker, at: 0)
        // The judgment appealed from was just entered.
        if let index = history.firstIndex(where: { $0.docket == docket && $0.resolvedKind != "continuance" }) {
            history[index].appealID = tracker.id
        }
        if let argument = tracker.argument {
            pending.append(PendingEvent(due: argument,
                                        news: NewsItem(date: argument, kind: .community,
                                                       headline: "Court of Appeals hears argument in \(caption)",
                                                       body: "A three-judge panel of the North Carolina Court of Appeals heard oral argument in Raleigh in the appeal from Judge \(lastName(judgeName ?? ""))'s judgment in \(caption). The issue: \(issue.prefix(1).lowercased() + issue.dropFirst()). A written opinion typically follows within a few months.",
                                                       docket: docket)))
        }
        // The decision and any word on a retrial belong to this appeal.
        return events.map { event in
            var event = event
            if event.news.kind == .appeal && event.news.docket == docket { event.appealID = tracker.id }
            return event
        }
    }

    /// Appeals taken before the tracker existed still have pending decisions; give each one a tracker.
    private func backfillAppeals() {
        var added = false
        for event in pending where event.news.kind == .appeal && !Appeals.isFollowUp(event) {
            guard let docket = event.news.docket, event.appealID == nil, !appeals.contains(where: { $0.docket == docket }) else { continue }
            let record = history.first { $0.docket == docket && $0.resolvedKind != "continuance" }
            let filed = record?.date ?? currentDate
            var rng = SeededRNG(seed: seedBase ^ SeededRNG.stableHash(docket))
            let byState = event.news.headline.contains("reinstates") || event.news.body.contains("On appeal by the State")
            let issue: String
            if event.news.headline.contains("reinstates") {
                issue = "Whether the trial court erred in dismissing the charges for a speedy-trial violation"
            } else if docket.hasSuffix("(PV)") {
                issue = "Whether the court had authority to sanction the probationer as it did"
            } else if event.effect == .resentence || event.news.body.contains("remanded for resentencing") {
                issue = "Whether the sentence is authorized by North Carolina law"
            } else {
                issue = "The sufficiency of the evidence and the trial court's rulings"
            }
            let tracker = Appeals.tracker(for: event, caption: record?.caption ?? "State v. \(docket)",
                                          personID: event.personID ?? record?.defendantID ?? UUID(), filed: filed,
                                          appellant: byState ? "the State" : "the defendant", issue: issue, rng: &rng)
            appeals.append(tracker)
            added = true
        }
        if added {
            appeals.sort { ($0.isPending ? 0 : 1, $1.filed) < ($1.isPending ? 0 : 1, $0.filed) }
            save()
        }
    }

    func clearDigest() {
        digest = []
        freshAppeals = []
        save()
    }

    /// A probationer sentenced elsewhere whose supervision was transferred to this county.
    private func makeOutsideHearing(date: Date, rng: inout SeededRNG) -> ViolationHearing? {
        guard let county else { return nil }
        var used = Set(people.map(\.name))
        let name = NameBank.person(using: &rng, excluding: &used)
        let age = rng.int(20...58)
        let year = CourtCalendar.calendar.component(.year, from: date)
        let seed = rng.pick(GenericPools.priorSeeds)
        var priors: [PriorConviction] = []
        // Adult convictions only: none before age 18.
        let earliest = max(2, min(12, age - 18))
        for _ in 0..<rng.int(0...3) {
            let p = rng.pick(GenericPools.priorSeeds)
            priors.append(PriorConviction(offense: p.offense, ncClass: p.ncClass, year: year - rng.int(2...earliest),
                                          county: rng.pick(GenericPools.otherCounties), sentence: rng.pick(p.sentences)))
        }
        let otherCounty = rng.pick(GenericPools.otherCounties)
        let felony = seed.ncClass.isFelony
        let months = felony ? rng.int(6...20) : rng.int(1...4)
        // Probation began some months ago and runs its full length from then.
        let served = rng.int(4...12)
        let left = felony ? rng.int(6...20) : rng.int(6...12)
        let sentenced = CourtCalendar.calendar.date(byAdding: .month, value: -served, to: date) ?? date
        let sentencedYear = CourtCalendar.calendar.component(.year, from: sentenced)
        let docket = String(format: "%02d %@ %06d", sentencedYear % 100, felony ? "CRS" : "CR", rng.int(1_000...90_000))
        let judge = "Judge " + (NameBank.person(using: &rng, excluding: &used).components(separatedBy: " ").last ?? "Ward")
        priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: sentencedYear, county: otherCounty,
                                      sentence: felony ? "\(months) months suspended, \(served + left) months probation" : "\(months * 30) days suspended, \(served + left) months probation",
                                      docket: docket))
        let term = ProbationTerm(docket: docket, offense: seed.offense, isFelony: felony,
                                 suspendedSentence: felony ? "\(months)–\(StructuredSentencing.maximum(forMinimum: months, cls: seed.ncClass)) months" : "\(months * 30) days",
                                 activeMonths: months,
                                 ends: CourtCalendar.calendar.date(byAdding: .month, value: left, to: date) ?? date,
                                 imposedInThisCourt: false, supervised: true,
                                 conditions: rng.chance(0.5) ? ["Obtain a substance abuse assessment and complete recommended treatment."] : [],
                                 monthlyObligation: rng.int(1...4) * 40, violationRisk: 0.25, crvCount: rng.chance(0.2) ? 1 : 0,
                                 treatmentNeed: rng.chance(0.5) ? .substance : TreatmentNeed.none,
                                 origin: "Sentenced by \(judge) in \(otherCounty); supervision transferred to \(county.name) when the probationer moved here.")
        let person = PersonRecord(id: UUID(), name: name, birthYear: year - age, occupation: rng.pick(NameBank.occupations).capitalizedFirst,
                                  background: "Moved to \(rng.pick(county.towns)) after being placed on probation in \(otherCounty).", priors: priors,
                                  status: .probation, probation: term, propensity: rng.chance(0.5) ? 0.35 : 0.2)
        people.append(person)
        return ViolationHearings.make(person: person, county: county, date: date, seed: rng.next())
    }

    /// Builds the calendar for a court date.
    private func buildDay(_ date: Date, kind: CourtDay.Kind, sessionDay: Int) -> CourtDay {
        var rng = SeededRNG(seed: seedBase &+ UInt64(abs(Int(date.timeIntervalSince1970)) / 60) &* 0x2545_F491)
        var entries: [DocketEntry] = []

        // Continued matters set any day this week come first.
        let weekEnd = sessionFriday(for: date)
        let due = scheduled.filter { CourtCalendar.calendar.startOfDay(for: $0.date) <= weekEnd }
        scheduled.removeAll { CourtCalendar.calendar.startOfDay(for: $0.date) <= weekEnd }
        for item in due {
            var entry = item.entry
            if case .hearing(var h) = entry.matter {
                // A continued hearing is heard, and any confinement runs, from the day it is actually held.
                h.date = date
                if let person = person(h.personID) {
                    h.personAge = person.age(on: date)
                    if let current = person.probation { h.probation = current }
                }
                entry.matter = .hearing(h)
            }
            if case .trial(var c) = entry.matter {
                creditJailTime(&c, through: date)
                applyDelayCosts(&c, entry: &entry, rng: &rng)
                c.sessionDate = date
                refreshDefendant(&c)
                if let requests = entry.requests, !requests.isEmpty {
                    let added = SupplementalEvidence.gather(for: &c, requests: requests, rng: &rng)
                    entry.note = (entry.note ?? "") + " New evidence is in: " + added.joined(separator: "; ") + "."
                    entry.requests = nil
                }
                entry.matter = .trial(c)
            }
            entries.append(entry)
        }
        // Cases back from the Court of Appeals. One whose defendant already has a matter waiting is taken up later.
        var waitingPeople = Set<UUID>()
        for entry in entries + scheduled.map(\.entry) {
            if case .trial(let c) = entry.matter { waitingPeople.insert(c.defendant.personID) }
            if case .hearing(let h) = entry.matter { waitingPeople.insert(h.personID) }
        }
        let deferred = retrials.filter { waitingPeople.contains($0.defendant.personID) }
        retrials.removeAll { waitingPeople.contains($0.defendant.personID) }
        defer { retrials += deferred }
        while !retrials.isEmpty {
            var retrial = retrials.removeFirst()
            retrial.id = UUID()
            creditVacatedTime(&retrial, through: date)
            retrial.sessionDate = date
            refreshDefendant(&retrial)
            entries.append(DocketEntry(matter: .trial(retrial), note: "Returned from the Court of Appeals"))
        }

        // The week takes only so many trials: a trial already under way comes first, then a jailed defendant,
        // then the oldest setting. The rest wait for next week.
        if kind != .specialSetting {
            func isTrial(_ e: DocketEntry) -> Bool { if case .trial = e.matter { return true } else { return false } }
            func rank(_ e: DocketEntry) -> Int {
                guard case .trial(let c) = e.matter else { return 0 }
                if e.resume != nil { return 0 }
                return (c.background?.isJailed ?? false) ? 1 : 2
            }
            let trials = entries.enumerated().filter { isTrial($0.element) }
            if trials.count > trialCap {
                let keep = Set(trials.sorted { (rank($0.element), $0.offset) < (rank($1.element), $1.offset) }.prefix(trialCap).map(\.element.id))
                let saturday = CourtCalendar.calendar.date(byAdding: .day, value: 1, to: weekEnd) ?? weekEnd
                let nextWeek = CourtCalendar.weekday(onOrAfter: CourtCalendar.monday(onOrAfter: saturday))
                for (_, entry) in trials where !keep.contains(entry.id) {
                    var carried = entry
                    carried.note = (carried.note ?? "") + " Carried over: the week's trial calendar was full."
                    scheduled.append(ScheduledMatter(date: nextWeek, entry: carried))
                }
                entries.removeAll { isTrial($0) && !keep.contains($0.id) }
                scheduled.sort { $0.date < $1.date }
            }
        }
        var murderThisWeek = entries.contains { if case .trial(let c) = $0.matter { return Self.isMurder(c) } else { return false } }

        // Anyone already on today's calendar, or holding a continued matter, isn't given a second matter.
        var usedPeople = Set<UUID>()
        for entry in entries + scheduled.map(\.entry) {
            switch entry.matter {
            case .trial(let c): usedPeople.insert(c.defendant.personID)
            case .hearing(let h): usedPeople.insert(h.personID)
            case .calendar(let call): call.matters.forEach { usedPeople.insert($0.personID) }
            }
        }
        if kind != .specialSetting {
            // A court week: Monday morning's administrative calendar call, then the week's trials and hearings.
            if let county {
                var call = CalendarCalls.make(county: county, date: date, docketSequence: docketSequence, people: people,
                                              excluding: usedPeople, seed: rng.next())
                docketSequence += 200
                // Leave room on the calendar for the new arrest, a relief motion, and most weeks a warrant and an arraignment.
                let wantsWarrant = rng.chance(0.7)
                let wantsArraignment = !lightWeeks && rng.chance(0.6)
                let reserved = 1 + (reliefQueue.isEmpty ? 0 : 1) + (wantsWarrant ? 1 : 0) + (wantsArraignment ? 1 : 0)
                let room = max(1, calendarCap - reserved)
                if call.matters.count > room {
                    // The quick pleas and probation matters stay; the overflow goes to another session.
                    call.matters = Array(call.matters.prefix(room))
                }
                call.matters.forEach { usedPeople.insert($0.personID) }
                if let relief = reliefQueue.first { usedPeople.insert(relief.personID) }
                // Pleas, continuance motions, failures to appear, and capacity motions are about real cases:
                // what the court orders puts each one on an actual calendar.
                for index in call.matters.indices
                where [.quickPlea, .continuance, .failureToAppear, .capacity, .bondModification].contains(call.matters[index].kind) {
                    if var c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: false, allowMurder: false, announce: false) {
                        if call.matters[index].kind == .bondModification {
                            // A jailed defendant asking for a lower bond.
                            if var bg = c.background { bg.custodyDays = max(bg.custodyDays, rng.int(30...150)); bg.onRelease = false; c.background = bg }
                            call.matters[index] = CalendarCalls.bondReductionMatter(for: c, rng: &rng)
                        } else {
                            if call.matters[index].kind == .failureToAppear, var bg = c.background {
                                // Only someone out on bond can fail to appear.
                                bg.onRelease = true
                                bg.bondStatus = "Out on a secured bond; did not answer the calendar call."
                                c.background = bg
                            }
                            call.matters[index] = CalendarCalls.bind(call.matters[index], to: c)
                        }
                    }
                }
                // A new arrest for conditions of release, and a case to arraign and set for trial.
                if var c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: false, allowMurder: false, announce: false) {
                    // Arrested days ago and held until this first hearing on conditions of release.
                    if var bg = c.background {
                        bg.custodyDays = rng.int(1...3)
                        bg.onRelease = false
                        bg.bondStatus = "Held since the arrest pending a bond hearing; in custody for \(bg.custodyDays) days."
                        c.background = bg
                    }
                    call.matters.append(CalendarCalls.bondMatter(for: c, rng: &rng))
                }
                if wantsArraignment, let c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: false, allowMurder: false, announce: false) {
                    call.matters.append(CalendarCalls.arraignmentMatter(for: c))
                }
                // Motions for appropriate relief in cases tried here come back to this judge.
                if !reliefQueue.isEmpty, let judgeName {
                    let relief = reliefQueue.removeFirst()
                    call.matters.insert(CalendarCalls.reliefMatter(relief, judgeLast: lastName(judgeName)), at: 0)
                }
                // Most weeks an officer brings a search warrant application.
                if wantsWarrant {
                    let kind = rng.pick([WarrantApplication.Kind.residenceDrugs, .storageStolen, .phoneRecords])
                    if let c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: false, categories: kind.categories, allowMurder: false, announce: false) {
                        let w = SearchWarrants.application(for: c, date: date, rng: &rng)
                        call.matters.insert(CalendarCalls.warrantMatter(w, for: c), at: min(1, call.matters.count))
                    }
                }
                call.matters.forEach { usedPeople.insert($0.personID) }
                entries.insert(DocketEntry(matter: .calendar(call)), at: 0)
            }
            // Now and then someone this court has judged is arrested on something new, and the case comes back here.
            let quiet = CourtCalendar.calendar.date(byAdding: .day, value: -120, to: date) ?? date
            let candidates = people.filter { person in
                person.status != .incarcerated && person.propensity >= 0.25 && !usedPeople.contains(person.id)
                    && (person.appearances.last?.date ?? .distantFuture) < quiet
                    && !reoffenseQueue.contains { $0.personID == person.id }
            }
            if rng.chance(0.18), !candidates.isEmpty {
                let person = rng.pick(candidates)
                if let last = person.appearances.last {
                    let incident = CourtCalendar.calendar.date(byAdding: .day, value: -rng.int(30...70), to: date) ?? date
                    reoffenseQueue.append(Reoffense(personID: person.id, templateKeys: FollowUpCases.newCharges.shuffled(using: &rng), victimName: nil,
                                                    incident: incident,
                                                    note: "Back in your court: \(person.name) was before you on \(last.charges.lowercased()) on \(SentenceFormat.shortDate(last.date)).",
                                                    priorOffense: last.charges, priorDate: last.date))
                }
            }
            // Cases that come back because of what this court decided before.
            var followUps = 0
            while followUps < 2, let index = reoffenseQueue.firstIndex(where: { !usedPeople.contains($0.personID) }) {
                let followUp = reoffenseQueue.remove(at: index)
                // Someone already back in prison on something else isn't brought over for this one.
                guard let person = person(followUp.personID), person.status != .incarcerated else { continue }
                if let c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: false, followUp: followUp) {
                    if Self.isMurder(c) { murderThisWeek = true }
                    entries.append(DocketEntry(matter: .trial(c), note: followUp.note))
                    followUps += 1
                }
            }
            let wanted = lightWeeks ? 2 : rng.int(2...3)
            let already = entries.filter { if case .trial = $0.matter { return true } else { return false } }.count
            // Every trial on the docket is a written case.
            let slots = max(0, min(wanted, trialCap) - already)
            for _ in 0..<slots {
                // At most one murder trial a week, and not two weeks running.
                let allowMurder = !murderThisWeek && !murderLastWeek
                if var c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: true, allowMurder: allowMurder) {
                    if Self.isMurder(c) { murderThisWeek = true }
                    // Some cases are called with a party asking for more time.
                    if c.background?.arrangementPresented != true && rng.chance(0.25) {
                        c.continuanceMotion = ContinuanceMotions.make(for: c, rng: &rng)
                    }
                    entries.append(DocketEntry(matter: .trial(c)))
                }
            }
            for _ in 0..<(lightWeeks ? 1 : rng.int(1...2)) {
                if let hearing = makeViolationHearing(date: date, excluding: &usedPeople, rng: &rng) {
                    entries.append(DocketEntry(matter: .hearing(hearing)))
                }
            }
            if !lightWeeks, rng.chance(0.5), let hearing = makeOutsideHearing(date: date, rng: &rng) {
                entries.append(DocketEntry(matter: .hearing(hearing)))
            }
        }
        if entries.isEmpty, let c = generateCase(date: date, rng: &rng, excluding: &usedPeople) {
            entries.append(DocketEntry(matter: .trial(c)))
        }
        if kind != .specialSetting { murderLastWeek = murderThisWeek }
        return CourtDay(date: date, clock: CourtCalendar.opening(on: date, minutesAfterMidnight: openingMinutes),
                        kind: kind, entries: entries, sessionDay: sessionDay)
    }

    /// A defendant held in jail earns credit for every day the case waits to be heard (G.S. 15-196.1).
    private func creditJailTime(_ c: inout CourtCase, through date: Date) {
        guard var background = c.background, background.isJailed else { return }
        let cal = CourtCalendar.calendar
        let waited = cal.dateComponents([.day], from: cal.startOfDay(for: c.sessionDate), to: cal.startOfDay(for: date)).day ?? 0
        guard waited > 0 else { return }
        let before = background.custodyDays
        background.custodyDays += waited
        background.bondStatus = background.bondStatus.replacingOccurrences(of: "for \(before) days", with: "for \(background.custodyDays) days")
        c.background = background
    }

    /// Time spent in custody on a judgment the Court of Appeals vacated counts toward any sentence on retrial
    /// (G.S. 15-196.1): from the original trial until the person was released, or until today if still held on it.
    private func creditVacatedTime(_ c: inout CourtCase, through date: Date) {
        guard var background = c.background, let person = person(c.defendant.personID) else { return }
        let cal = CourtCalendar.calendar
        let heldThroughRetrial = person.status == .incarcerated && person.custodyDocket == c.docket
        let released = person.appearances.last(where: { $0.docket == c.docket })?.date
        let wasActive = heldThroughRetrial
            || history.contains { $0.docket == c.docket && $0.resolvedKind == "trial" && $0.judgments.contains { $0.contains("active") || $0.contains("Life") } }
        guard wasActive else { return }
        // Released when the appeal was decided, unless still held on this judgment.
        let decided = appeals.last(where: { $0.docket == c.docket })?.decided
        let end = heldThroughRetrial ? date : min(date, decided ?? date)
        let start = released ?? c.sessionDate
        let served = max(0, cal.dateComponents([.day], from: cal.startOfDay(for: start), to: cal.startOfDay(for: end)).day ?? 0)
        guard served > 0 else { return }
        background.custodyDays += served
        c.background = background
        c.proceduralNotes.append("Credit for \(served) days in custody on the vacated judgment is added to pretrial confinement (G.S. 15-196.1).")
    }

    /// Delay has a price. Each time a trial is put off, witnesses drift, the victim's family loses patience,
    /// and a jailed defendant's lawyer builds a speedy-trial record.
    private func applyDelayCosts(_ c: inout CourtCase, entry: inout DocketEntry, rng: inout SeededRNG) {
        let times = entry.continuances
        guard times > 0 else { return }
        let jailed = c.background?.isJailed ?? false
        let started = (entry.resume?.stage ?? 0) >= CaseSession.Stage.trial.rawValue
        var notes: [String] = []
        // From the second continuance on, an ordinary State witness may no longer be available.
        if times >= 2, !started, !c.templateKey.hasPrefix("story."), rng.chance(0.2 + 0.1 * Double(min(times, 4))) {
            let candidates = c.witnesses.filter { $0.calledBy == .prosecution && $0.lay == true && $0.name != c.victimName && $0.isDefendant != true }
            if c.witnesses.filter({ $0.calledBy == .prosecution }).count > 1, let gone = candidates.first {
                c.witnesses.removeAll { $0.id == gone.id }
                c.objections.removeAll { $0.witnessID == gone.id }
                notes.append("\(gone.name) (\(gone.role.lowercased())) has moved out of state and can't be found for trial; the State proceeds without that testimony.")
            }
        }
        if times >= 2, let victim = c.victimName, rng.chance(0.6) {
            post(NewsItem(date: c.sessionDate, kind: .community,
                          headline: "Family of \(victim) frustrated as \(c.defendant.lastName) case is delayed again",
                          body: "The case against \(c.defendant.name) in Hollis County Superior Court has been continued \(times) times. \(victim)'s family told reporters they have taken days off work for every setting. \"We just want it over,\" a relative said.",
                          docket: c.docket, prominence: 1))
            notes.append("\(victim)'s family has written to the court about the delays.")
        }
        if times >= 2 && jailed {
            notes.append("Defense counsel objects to further delay for the record: \(c.defendant.lastName) has been held \(c.background?.custodyDays ?? 0) days awaiting trial (Barker v. Wingo; N.C. Const. art. I, § 18).")
        }
        if !notes.isEmpty {
            entry.note = (entry.note ?? "") + " " + notes.joined(separator: " ")
            c.proceduralNotes.append(contentsOf: notes)
        }
    }

    /// Puts the cases behind the calendar call's rulings on a real calendar: this week, a later week, or (after an
    /// order for arrest or a capacity evaluation) whenever the defendant can be brought to court.
    private func scheduleCalendarCases(_ call: CalendarCall, choices: [UUID: Int], amounts: [UUID: Int]) {
        var rng = SeededRNG(seed: seedBase ^ SeededRNG.stableHash(call.id.uuidString))
        let heard = SentenceFormat.shortDate(call.date)
        func later(weeks: Int) -> Date {
            CourtCalendar.monday(onOrAfter: CourtCalendar.calendar.date(byAdding: .day, value: 7 * weeks, to: call.date) ?? call.date)
        }
        func schedule(_ c: CourtCase, _ weeks: Int, _ note: String, _ continuances: Int) {
            setFor(c, weeks: weeks, note: note, continuances: continuances)
        }
        func setFor(_ c: CourtCase, weeks: Int, note: String, continuances: Int = 0) {
            var entry = DocketEntry(matter: .trial(c), note: note)
            entry.continuances = continuances
            scheduled.append(ScheduledMatter(date: max(later(weeks: weeks), nextCourtDate), entry: entry))
        }
        func thisWeek(_ c: CourtCase, note: String, continuances: Int = 0) {
            guard var day = today else { setFor(c, weeks: 1, note: note, continuances: continuances); return }
            let openTrials = day.entries.filter { e in
                if case .trial = e.matter { return e.isOpen } else { return false }
            }.count
            guard openTrials < trialCap else {
                setFor(c, weeks: 1, note: note.replacingOccurrences(of: "tried this week", with: "set for next week") + " This week's trial calendar was already full.",
                       continuances: continuances)
                return
            }
            var c = c
            c.sessionDate = day.date
            var entry = DocketEntry(matter: .trial(c), note: note)
            entry.continuances = continuances
            day.entries.append(entry)
            today = day
        }
        for m in call.matters {
            guard let c = m.pendingCase else { continue }
            let choice = choices[m.id] ?? 0
            switch m.kind {
            case .quickPlea where choice == 3:
                setFor(c, weeks: 2, note: "Plea rejected at the calendar call on \(heard); set for trial.")
            case .continuance:
                // The motion says which continuance it would be: the "third" means two came before.
                let before = m.summary.contains("fourth") ? 3 : (m.summary.contains("third") ? 2 : 1)
                if choice == 0 {
                    setFor(c, weeks: 4, note: "Continued at the calendar call on \(heard) on the defense's motion.", continuances: before + 1)
                } else {
                    thisWeek(c, note: "Motion to continue denied at the calendar call; the case is tried this week.", continuances: before)
                }
            case .failureToAppear:
                switch choice {
                case 0:
                    // Picked up on the order for arrest some weeks later, and held.
                    var held = c
                    let weeksOut = rng.int(2...5)
                    let arrested = CourtCalendar.calendar.date(byAdding: .day, value: 7 * weeksOut - rng.int(3...10), to: call.date) ?? call.date
                    if var bg = held.background {
                        bg.onRelease = false
                        bg.bondStatus = "Arrested on the order for arrest after failing to appear; bond doubled and held for \(bg.custodyDays) days."
                        held.background = bg
                    }
                    // Jail credit runs from the arrest, not from the missed court date.
                    held.sessionDate = arrested
                    setFor(held, weeks: weeksOut, note: "Arrested on the order for arrest issued at the calendar call on \(heard).")
                case 1:
                    if rng.chance(0.6) {
                        thisWeek(c, note: "Appeared at the afternoon session after missing the morning call; tried this week.")
                    } else {
                        setFor(c, weeks: rng.int(2...5), note: "Never appeared on \(heard); arrested on an order for arrest issued that afternoon.")
                    }
                default:
                    setFor(c, weeks: 3, note: "Continued at the calendar call on \(heard) after a failure to appear; new notice sent.", continuances: 1)
                }
            case .firstAppearance, .bondModification:
                guard let bond = m.bond else { continue }
                let set = amounts[m.id] ?? m.suggestedAmount ?? bond.moderate
                let amount: Int
                let monitored: Bool
                let condition: String
                if m.kind == .firstAppearance {
                    amount = choice >= 2 ? set : 0
                    monitored = choice == 3
                    condition = ["a written promise to appear", "an unsecured bond of $\(bond.moderate.formatted())",
                                 "a $\(set.formatted()) secured bond", "a $\(set.formatted()) secured bond with electronic house arrest"][min(choice, 3)]
                } else {
                    amount = choice == 1 ? bond.moderate : set
                    monitored = choice == 2
                    condition = ["a reduced $\(set.formatted()) secured bond", "the $\(bond.moderate.formatted()) secured bond left in place",
                                 "a reduced $\(set.formatted()) secured bond with electronic house arrest"][min(choice, 2)]
                }
                decideRelease(c, bond: bond, amount: amount, monitored: monitored, condition: condition, heard: heard, date: call.date,
                              rng: &rng, schedule: schedule)
            case .arraignment:
                let weeks = [2, 5, 10][min(choice, 2)]
                var setCase = c
                if weeks == 2 && c.charges.count > 1 && rng.chance(0.6) {
                    // Too soon for the defense to be ready.
                    setCase.continuanceMotion = ContinuanceMotions.make(for: setCase, rng: &rng)
                }
                setFor(setCase, weeks: weeks, note: "Arraigned on \(heard); pleaded not guilty and set for trial.")
            case .motionForRelief:
                guard let relief = m.relief else { continue }
                let options = m.options
                let picked = options.indices.contains(choice) ? options[choice] : ""
                if picked.hasPrefix("Hold an evidentiary hearing") {
                    var heardMotion = relief
                    heardMotion.hearingHeld = true
                    reliefQueue.append(heardMotion)
                } else if picked.hasPrefix("Grant") {
                    vacateForNewTrial(relief, on: call.date, rng: &rng)
                    // The new trial starts from today: time served on the vacated judgment is credited, and no
                    // jail days accrue for the years between the trials.
                    var retrial = relief.retrial
                    retrial.sessionDate = call.date
                    if var bg = retrial.background {
                        bg.onRelease = true
                        bg.bondStatus = "Released when the conviction was vacated on \(heard); awaiting the new trial."
                        retrial.background = bg
                    }
                    creditVacatedTime(&retrial, through: call.date)
                    setFor(retrial, weeks: rng.int(4...8), note: "New trial ordered on your grant of a motion for appropriate relief on \(heard).")
                } else if relief.meritorious {
                    // The innocence commission may still take it up, and the record will show the denial.
                    let judge = lastName(judgeName ?? "")
                    for index in pending.indices where pending[index].vacatesDocket == relief.docket && pending[index].news.kind == .exoneration {
                        pending[index].news.body += " Judge \(judge) had denied a motion for a new trial based on the same evidence."
                    }
                }
            case .searchWarrant:
                guard let w = m.warrant else { continue }
                // Without catch-all language there are two choices: sign (0) or deny (1, the same as 2 below).
                let choice = m.options.count == 2 && choice == 1 ? 2 : choice
                let judge = lastName(judgeName ?? "")
                if choice == 2 {
                    if w.probableCause && rng.chance(0.5) {
                        // A sound application, denied: the detectives build more and come back to another judge.
                        let rebuilt = SearchWarrants.executed(WarrantApplication(kind: w.kind, affiant: w.affiant, agency: w.agency,
                                                                                 applied: call.date, target: w.target, place: w.place,
                                                                                 items: w.items, affidavit: w.affidavit, flaw: .none),
                                                              on: c, limited: true, signedBy: rng.pick(NameBank.lastNames), byThisJudge: false)
                        setFor(rebuilt, weeks: rng.int(6...10), note: "You denied the first warrant application on \(heard); detectives added surveillance and another judge signed a second one.")
                    } else if w.probableCause {
                        post(NewsItem(date: call.date, kind: .community, headline: "Investigation stalls after warrant denied",
                                      body: "Detectives with the \(w.agency) say an investigation in \(w.place.components(separatedBy: ",").dropFirst().first?.trimmingCharacters(in: .whitespaces) ?? "the county") has stalled after Judge \(judge) declined to sign a search warrant.",
                                      prominence: 1))
                    }
                    continue
                }
                let executed = SearchWarrants.executed(w, on: c, limited: choice == 1, signedBy: judge)
                setFor(executed, weeks: rng.int(5...9), note: "Charged after the search warrant you signed on \(heard) was executed.")
            case .capacity:
                switch choice {
                case 0:
                    if rng.chance(0.25) {
                        // The finding comes when the evaluation is done, about ten weeks out.
                        let found = CourtCalendar.calendar.date(byAdding: .day, value: 7 * rng.int(9...11), to: call.date) ?? call.date
                        pending.append(PendingEvent(due: found, news: NewsItem(
                            date: found, kind: .community, headline: "\(c.defendant.name) found incapable to proceed",
                            body: "After an evaluation at Central Regional Hospital, \(c.defendant.name) was found incapable of proceeding to trial on \(c.charges.first?.law.title.lowercased() ?? "the charge"). The case is on hold while treatment to restore capacity continues (G.S. 15A-1002).",
                            docket: c.docket)))
                        setFor(c, weeks: rng.int(20...30), note: "Capacity restored after treatment at Central Regional Hospital; set for trial.")
                    } else {
                        setFor(c, weeks: rng.int(9...12), note: "Central Regional Hospital found the defendant capable to proceed; set for trial.")
                    }
                case 1:
                    setFor(c, weeks: 3, note: "The local screening found the defendant capable to proceed; set for trial.")
                default:
                    thisWeek(c, note: "Found capable at the calendar call; the case is tried this week.")
                }
            default:
                break
            }
        }
        scheduled.sort { $0.date < $1.date }
    }

    /// A conviction vacated for a new trial: it comes off the record, and the person is released if held on it.
    private func vacateForNewTrial(_ relief: ReliefMotion, on date: Date, rng: inout SeededRNG) {
        pending.removeAll { $0.vacatesDocket == relief.docket && $0.news.kind == .exoneration }
        // A pending appeal from the vacated judgment is moot.
        if let a = appeals.firstIndex(where: { $0.docket == relief.docket && $0.isPending }) {
            let trackerID = appeals[a].id
            appeals[a].decided = date
            appeals[a].result = "Dismissed as moot"
            appeals[a].opinion = "The appeal was dismissed as moot after the trial court vacated the judgment and ordered a new trial."
            pending.removeAll { $0.appealID == trackerID || ($0.news.docket == relief.docket && ($0.news.kind == .appeal || $0.news.headline.hasPrefix("Court of Appeals hears argument"))) }
            if let h = history.firstIndex(where: { $0.appealID == trackerID }) { history[h].appealStatus = "Appeal dismissed as moot" }
        }
        guard let index = people.firstIndex(where: { $0.id == relief.personID }) else { return }
        people[index].priors.removeAll { $0.docket == relief.docket }
        if people[index].probation?.docket == relief.docket { people[index].probation = nil }
        if people[index].pendingPostRelease?.docket == relief.docket { people[index].pendingPostRelease = nil }
        if people[index].postRelease?.docket == relief.docket { people[index].postRelease = nil }
        let held = people[index].custodyDocket
        if people[index].status == .incarcerated && (held == nil || held == relief.docket || held == relief.docket + " (PV)") {
            releaseFromCustody(index, on: date, announce: false, rng: &rng)
        } else if people[index].status == .probation && people[index].probation == nil {
            people[index].status = .free
        }
        post(NewsItem(date: date, kind: .community, headline: "Judge orders new trial for \(relief.personName)",
                      body: "Citing newly discovered evidence, Judge \(lastName(judgeName ?? "")) vacated the conviction of \(relief.personName) for \(relief.offense.lowercased()) and ordered a new trial.",
                      docket: relief.docket, prominence: 2))
    }

    /// What follows from conditions of release: a defendant who can post goes home, and may miss court or be
    /// arrested again; one who can't sits in jail until trial, and that time counts.
    private func decideRelease(_ c: CourtCase, bond: BondFacts, amount: Int, monitored: Bool, condition: String, heard: String,
                               date: Date, rng: inout SeededRNG, schedule: (CourtCase, Int, String, Int) -> Void) {
        var held = c
        guard var bg = held.background else { schedule(c, rng.int(5...8), "Set for trial on \(heard).", 0); return }
        if amount <= bond.canPost {
            // The days already spent in jail stay as credit; the clock stops while the defendant is out.
            bg.onRelease = true
            bg.bondStatus = "Released on \(condition) on \(heard)."
            held.background = bg
            // House arrest makes running and new arrests less likely.
            let watch = monitored ? 0.4 : 1.0
            let cal = CourtCalendar.calendar
            if rng.chance(bond.danger * watch) {
                let weeksOut = rng.int(1...3)
                let arrested = cal.date(byAdding: .day, value: 7 * weeksOut, to: date) ?? date
                pending.append(PendingEvent(due: arrested, news: NewsItem(
                    date: arrested, kind: .arrest, headline: NewsDesk.rearrestHeadline(c.defendant.name, rng: &rng),
                    body: "\(c.defendant.name), released on \(condition) by Judge \(lastName(judgeName ?? "")), was arrested again this week, according to the \(county?.sheriffsOffice ?? "Sheriff's Office"). The new charge is pending in district court.",
                    docket: c.docket, prominence: 2)))
                bg.onRelease = false
                bg.bondStatus = "Released on \(condition), then arrested on a new charge; bond revoked and held for \(bg.custodyDays) days."
                held.background = bg
                held.sessionDate = arrested
                schedule(held, weeksOut + rng.int(3...6), "Bond revoked after a new arrest while on release.", 0)
            } else if rng.chance(bond.flightRisk * watch) {
                let weeksOut = rng.int(3...6)
                let arrested = cal.date(byAdding: .day, value: 7 * weeksOut, to: date) ?? date
                // A failure to appear doubles the bond (G.S. 15A-544.3; local bond policy).
                let doubled = max(1_000, amount * 2)
                bg.onRelease = false
                bg.bondStatus = "Released on \(condition); failed to appear and was arrested on an order for arrest. Bond doubled to $\(doubled.formatted()) secured; held for \(bg.custodyDays) days."
                held.background = bg
                held.sessionDate = arrested
                schedule(held, weeksOut + rng.int(3...6), "Missed the first trial setting after release; arrested on an order for arrest.", 0)
            } else {
                schedule(held, rng.int(5...8), "On release since \(heard).", 0)
            }
        } else {
            bg.custodyDays = max(1, bg.custodyDays)
            bg.onRelease = false
            bg.bondStatus = "Held on \(condition) set on \(heard); unable to post it. In custody for \(bg.custodyDays) days."
            held.background = bg
            schedule(held, rng.int(5...8), "In custody since \(heard): couldn't post \(condition).", 0)
        }
    }

    /// How many times a matter on this week's calendar has already been continued.
    func continuances(of matterID: UUID) -> Int {
        today?.entries.first { $0.matterID == matterID }?.continuances ?? 0
    }

    /// Brings a defendant's record up to date before a case is heard again.
    private func refreshDefendant(_ c: inout CourtCase) {
        guard let person = person(c.defendant.personID) else { return }
        c.defendant.priors = person.priors
        c.defendant.probation = person.status == .probation ? person.probation : nil
        c.defendant.postRelease = person.status == .incarcerated ? nil : person.postRelease
        c.defendant.violations = person.violations
        c.defendant.history = person.appearances
        c.defendant.age = person.age(on: c.sessionDate)
    }

    func completeCalendar(_ call: CalendarCall, choices: [UUID: Int], amounts: [UUID: Int] = [:]) {
        guard let county, let judgeName, stillOpen(call.id) else { return }
        let result = CalendarCalls.resolve(call, choices: choices, amounts: amounts, judgeName: judgeName, county: county)
        for newcomer in result.newPeople {
            // A returning defendant who pleads keeps one record.
            if let index = people.firstIndex(where: { $0.id == newcomer.id }) {
                people[index].priors.append(contentsOf: newcomer.priors.filter { prior in !people[index].priors.contains { $0.docket == prior.docket && $0.offense == prior.offense } })
                people[index].appearances.append(contentsOf: newcomer.appearances)
                if newcomer.status != .free || people[index].status == .free {
                    people[index].status = newcomer.status
                    people[index].releaseDate = newcomer.releaseDate ?? people[index].releaseDate
                    people[index].releaseNote = newcomer.releaseNote ?? people[index].releaseNote
                }
                if var term = newcomer.probation {
                    // Probation already running on another case runs alongside the new term rather than vanishing.
                    if let earlier = people[index].probation, earlier.docket != term.docket {
                        term.ends = max(term.ends, earlier.ends)
                        term.suspendedSentence += "; also on probation in \(earlier.docket) (\(earlier.suspendedSentence))"
                        term.conditions = Array(Set((term.conditions ?? []) + (earlier.conditions ?? []))).sorted()
                        term.supervised = (term.supervised ?? true) || (earlier.supervised ?? true)
                        term.activeMonths = max(term.activeMonths, earlier.activeMonths)
                    }
                    people[index].probation = term
                }
                if let prs = newcomer.pendingPostRelease { people[index].pendingPostRelease = prs }
                if let prs = newcomer.postRelease { people[index].postRelease = prs }
            } else {
                people.append(newcomer)
            }
        }
        for (id, update) in result.updates {
            if let index = people.firstIndex(where: { $0.id == id }) {
                let wasHeld = people[index].status == .incarcerated
                update(&people[index])
                // A CRV ordered at the calendar call is now the commitment in effect.
                if !wasHeld && people[index].status == .incarcerated { people[index].custodyDocket = people[index].appearances.last?.docket }
            }
        }
        for newcomer in result.newPeople where newcomer.status == .incarcerated {
            if let index = people.firstIndex(where: { $0.id == newcomer.id }) {
                people[index].custodyDocket = newcomer.appearances.last?.docket
            }
        }
        pending.append(contentsOf: result.pending)
        scheduleCalendarCases(call, choices: choices, amounts: amounts)
        stats.activeSentences += result.activeSentences
        stats.suspendedSentences += result.suspendedSentences
        stats.probationCompleted += result.probationCompleted
        history.insert(CaseRecord(docket: "Calendar call", caption: "Administrative calendar call",
                                  headline: "\(call.matters.count) matters", category: .procedure, date: currentDate,
                                  defendantID: UUID(), outcome: "\(call.matters.count) matters handled", judgments: result.lines,
                                  returningDefendant: false, appealStatus: nil, kind: "calendar"), at: 0)
        let pleas = result.newPeople.count
        post(NewsItem(date: currentDate, kind: .community,
                      headline: "Judge \(lastName(judgeName)) works through crowded calendar",
                      body: "At an administrative session of Hollis County Superior Court, Judge \(lastName(judgeName)) handled \(call.matters.count) matters" + (pleas > 0 ? ", including \(pleas) guilty plea\(pleas == 1 ? "" : "s")." : "."),
                      prominence: 1))
        finishEntry(matterID: call.id, outcome: "\(call.matters.count) matters handled")
        save()
    }

    private func makeViolationHearing(date: Date, excluding used: inout Set<UUID>, rng: inout SeededRNG) -> ViolationHearing? {
        guard let county else { return nil }
        let recentCutoff = CourtCalendar.calendar.date(byAdding: .day, value: -45, to: date) ?? date
        let candidates = people.filter { person in
            // Only a supervised probationer has an officer to file a violation report.
            person.status == .probation
                && person.probation != nil
                && (person.probation?.supervised ?? true)
                && (person.appearances.last?.date ?? .distantPast) < recentCutoff
                && !used.contains(person.id)
        }
        let risks = candidates.map { $0.probation?.violationRisk ?? 0.15 }
        let total = risks.reduce(0, +)
        guard total > 0, rng.chance(min(0.7, total * 0.5)) else { return nil }
        var target = Double.random(in: 0..<total, using: &rng)
        var chosen = candidates[candidates.count - 1]
        for (person, risk) in zip(candidates, risks) {
            target -= risk
            if target <= 0 { chosen = person; break }
        }
        used.insert(chosen.id)
        return ViolationHearings.make(person: chosen, county: county, date: date, seed: rng.next())
    }

    func completeHearing(_ hearing: ViolationHearing, outcome: HearingOutcome) {
        guard stillOpen(hearing.id) else { return }
        let appearance = PersonRecord.Appearance(docket: hearing.probation.docket + " (PV)", date: currentDate,
                                                 charges: "Probation violation", outcome: outcome.appearance)
        if let index = people.firstIndex(where: { $0.id == hearing.personID }) {
            people[index].status = outcome.status
            people[index].releaseDate = outcome.releaseDate
            people[index].releaseNote = outcome.releaseDate == nil ? nil : outcome.lines.first
            people[index].custodyDocket = outcome.status == .incarcerated ? appearance.docket : nil
            people[index].probation = outcome.probation
            people[index].propensity = min(0.85, max(0.03, people[index].propensity + outcome.propensityChange))
            if let violation = outcome.violation { people[index].violations = (people[index].violations ?? []) + [violation] }
            // A revoked conditional discharge enters the conviction; an activated felony term carries supervision after release.
            people[index].priors.append(contentsOf: outcome.newPriors)
            if let prs = outcome.pendingPostRelease { people[index].pendingPostRelease = prs }
            people[index].appearances.append(appearance)
        }
        history.insert(CaseRecord(docket: hearing.probation.docket + " (PV)", caption: "Probation violation: \(hearing.personName)",
                                  headline: "Probation violation hearing", category: .procedure, date: currentDate,
                                  defendantID: hearing.personID, outcome: outcome.appearance, judgments: outcome.lines,
                                  returningDefendant: true,
                                  appealStatus: outcome.pending.contains(where: { $0.news.kind == .appeal }) ? "Appeal pending" : nil,
                                  kind: "hearing"), at: 0)
        if outcome.status == .incarcerated && outcome.probation == nil { stats.probationRevoked += 1 }
        var item = outcome.news
        item.date = currentDate
        post(item)
        pending.append(contentsOf: trackAppeals(outcome.pending, docket: hearing.probation.docket + " (PV)",
                                                caption: "State v. \(hearing.personName) (probation violation)",
                                                personID: hearing.personID, appellant: "the probationer", plea: false,
                                                grounds: outcome.lines.filter { $0.hasPrefix("Note:") }.map { String($0.dropFirst(6)) },
                                                groundErrors: outcome.lines.filter { $0.hasPrefix("Note:") }.map { _ in true }))
        finishEntry(matterID: hearing.id, outcome: outcome.appearance)
        save()
    }

    /// A new case for the calendar.
    private func generateCase(date: Date, rng: inout SeededRNG, excluding used: inout Set<UUID>, storySlot: Bool = true,
                              categories: Set<LawCategory>? = nil, allowMurder: Bool = true, announce: Bool = true,
                              followUp: Reoffense? = nil) -> CourtCase? {
        guard let county, let judgeName else { return nil }
        // A written case brings its own defendant; returning defendants come back through calendar matters and follow-ups.
        var returning = followUp.flatMap { person($0.personID) } ?? (storySlot && followUp == nil ? nil : pickReturningDefendant(rng: &rng, date: date))
        if followUp == nil, let person = returning, used.contains(person.id) { returning = nil }
        var context = CaseGenerator.Context(county: county, judgeName: judgeName, date: date,
                                            docketSequence: docketSequence, recentTemplateKeys: recentTemplates,
                                            usedSignatures: Set(usedSignatures), returning: returning,
                                            usedBackgrounds: Set(people.map(\.background)), storySlot: followUp == nil && storySlot,
                                            categories: categories, allowMurder: allowMurder)
        if let followUp {
            context.forcedTemplateKeys = followUp.templateKeys
            context.victimOverride = followUp.victimName
            context.incidentDaysAgo = CourtCalendar.calendar.dateComponents([.day], from: followUp.incident, to: date).day
            context.priorOffense = followUp.priorOffense
            context.priorDate = followUp.priorDate
        }
        let announce = announce && followUp == nil
        // Draw a few candidates, cut lines that don't fit, and keep the one that holds together and reads newest.
        let recent = Set(recentLineKeys)
        var best: (score: Int, value: CourtCase)?
        for _ in 0..<4 {
            var candidate = CaseGenerator.generate(seed: rng.next(), context: context)
            let report = CaseAuditor.audit(&candidate)
            let keys = CaseAuditor.lineKeys(candidate)
            let repeats = keys.filter { recent.contains($0) }.count
            // Take the first draw that holds together and is mostly fresh; scoring on anything else would
            // favor the same few kinds of case over and over.
            let score = report.fatal.count * 1_000 + repeats
            if best == nil || score < best!.score { best = (score, candidate) }
            if report.fatal.isEmpty && repeats * 4 <= max(4, keys.count) { break }
        }
        guard let newCase = best?.value else { return nil }
        recentLineKeys.append(contentsOf: CaseAuditor.lineKeys(newCase))
        if recentLineKeys.count > 2_500 { recentLineKeys.removeFirst(recentLineKeys.count - 2_500) }
        used.insert(newCase.defendant.personID)
        docketSequence += rng.int(30...420)
        recentTemplates.append(newCase.templateKey)
        if let signature = newCase.scenarioSignature { usedSignatures.append(signature) }
        // Written stories stay on the list for good so none repeats; older generated scenarios age off.
        let generated = usedSignatures.filter { !$0.hasPrefix("story.") }
        if generated.count > 1_500 {
            let drop = Set(generated.prefix(generated.count - 1_500))
            usedSignatures.removeAll { drop.contains($0) && !$0.hasPrefix("story.") }
        }
        if recentTemplates.count > 8 { recentTemplates.removeFirst(recentTemplates.count - 8) }

        // Calendar-call matters and warrant cases aren't trials set before this judge; no "charged again" story for them.
        if let returning, announce {
            let lead = returning.status == .probation ? "while on probation" : returning.postRelease != nil ? "while on post-release supervision" : "again"
            post(NewsItem(date: date, kind: .arrest,
                          headline: NewsDesk.chargedAgainHeadline(returning.name, lead: lead, rng: &rng),
                          body: "\(returning.name), \(returning.age(on: date)), who has previously appeared in Hollis County Superior Court, has been charged with \(newCase.charges.first?.law.title.lowercased() ?? "a new offense"). The case is set for trial before Judge \(lastName(judgeName)).",
                          docket: newCase.docket))
        }
        return newCase
    }

    private func pickReturningDefendant(rng: inout SeededRNG, date: Date) -> PersonRecord? {
        let recentCutoff = CourtCalendar.calendar.date(byAdding: .day, value: -30, to: date) ?? date
        let eligible = people.filter { person in
            person.status != .incarcerated
                && (person.appearances.last?.date ?? .distantPast) < recentCutoff
                && person.age(on: date) < 75
        }
        let total = eligible.reduce(0) { $0 + $1.propensity }
        guard total > 0, rng.chance(min(0.3, total * 0.1)) else { return nil }
        var target = Double.random(in: 0..<total, using: &rng)
        for person in eligible {
            target -= person.propensity
            if target <= 0 { return person }
        }
        return eligible.last
    }

    /// A matter can be decided once: a second tap, or a sheet reopened after the fact, changes nothing.
    private func stillOpen(_ matterID: UUID) -> Bool {
        guard let entry = today?.entries.first(where: { $0.matterID == matterID }) else { return true }
        return entry.isOpen
    }

    func complete(_ courtCase: CourtCase, outcome: CaseOutcome) {
        guard stillOpen(courtCase.id) else { return }
        let d = courtCase.defendant
        let judgmentText = outcome.judgments.map { ([$0.title] + $0.lines).joined(separator: " · ") }
            + [outcome.habitualNote, outcome.probationHearing].compactMap { $0 }
            + [outcome.stayAwayOrder.map { "Stay-away order: no contact with \($0.protectedName), and stay away from their home, work, and school, until \(SentenceFormat.shortDate($0.expires))." }].compactMap { $0 }
        // A retrial of the same case doesn't make the defendant a returning one.
        let retried = history.contains { $0.docket == courtCase.docket && $0.resolvedKind == "trial" }

        history.insert(CaseRecord(docket: courtCase.docket, caption: courtCase.caption, headline: courtCase.headline,
                                  category: courtCase.category, date: currentDate, defendantID: d.personID,
                                  outcome: outcome.appearanceSummary, judgments: judgmentText,
                                  returningDefendant: d.isReturning && !retried,
                                  appealStatus: outcome.appealNotice == nil && !outcome.pending.contains(where: { $0.news.kind == .appeal && $0.news.docket == courtCase.docket }) ? nil : "Appeal pending",
                                  kind: "trial"), at: 0)
        if let position = outcome.sentencePosition {
            switch position {
            case .below: stats.belowPresumptive += 1
            case .within: stats.withinPresumptive += 1
            case .above: stats.abovePresumptive += 1
            }
        }
        let activeImposed = outcome.custodyMonths > 0
            || outcome.newPriors.contains { $0.sentence.hasSuffix(" active") || $0.sentence.hasPrefix("Life") }
        if activeImposed { stats.activeSentences += 1 } else if outcome.newProbation != nil && outcome.convicted { stats.suspendedSentences += 1 }
        if var day = today {
            var tally = day.tally ?? CourtDay.Tally()
            if outcome.convicted { tally.convictions += 1 } else { tally.withoutConviction += 1 }
            if activeImposed { tally.active += 1 }
            day.tally = tally
            today = day
        }
        // Only the probation revocation counts here; a post-release supervision revocation reads "... revoked. The defendant is returned".
        if courtCase.defendant.probation != nil && outcome.probationHearing?.contains("revoked. The suspended sentence") == true { stats.probationRevoked += 1 }

        // Update the person's record
        let appearance = PersonRecord.Appearance(docket: courtCase.docket, date: currentDate,
                                                 charges: courtCase.charges.map { $0.law.title }.joined(separator: ", "),
                                                 outcome: outcome.appearanceSummary)
        if let index = people.firstIndex(where: { $0.id == d.personID }) {
            let before = people[index]
            people[index].priors.append(contentsOf: outcome.newPriors)
            // Custody and supervision from other dockets carry on. Today's judgment adds to them; it never cuts them short.
            let heldElsewhere = before.status == .incarcerated && before.custodyDocket != courtCase.docket
                && (before.releaseDate ?? .distantPast) > currentDate
            let todaysRelease = outcome.personStatus == .incarcerated ? (outcome.releaseDate ?? .distantPast) : .distantPast
            let keepsEarlierCommitment = heldElsewhere && (before.releaseDate ?? .distantPast) >= todaysRelease
            if !keepsEarlierCommitment {
                people[index].status = outcome.personStatus
                people[index].releaseDate = outcome.releaseDate
                people[index].releaseNote = outcome.releaseBasis
                people[index].custodyDocket = outcome.personStatus == .incarcerated ? courtCase.docket : nil
            }

            // Probation the case didn't know about (on another docket) continues alongside any new term.
            var probation = outcome.newProbation
            if d.probation == nil, let earlier = before.probation, earlier.docket != courtCase.docket {
                if var merged = probation {
                    merged.ends = max(merged.ends, earlier.ends)
                    merged.suspendedSentence += "; also on probation in \(earlier.docket) (\(earlier.suspendedSentence))"
                    merged.conditions = Array(Set((merged.conditions ?? []) + (earlier.conditions ?? []))).sorted()
                    merged.supervised = (merged.supervised ?? true) || (earlier.supervised ?? true)
                    merged.activeMonths = max(merged.activeMonths, earlier.activeMonths)
                    probation = merged
                } else {
                    probation = earlier
                }
            }
            people[index].probation = probation
            if people[index].status == .free && probation != nil { people[index].status = .probation }

            // A new prison term ends supervision on an old one; otherwise supervision the case didn't touch carries on.
            let newPrisonTerm = outcome.newPriors.contains { $0.sentence.hasSuffix(" active") || $0.sentence.hasPrefix("Life") }
            if newPrisonTerm {
                people[index].postRelease = nil
            } else if d.postRelease != nil || before.postRelease?.docket == courtCase.docket {
                people[index].postRelease = outcome.continuedPostRelease
            }
            if !outcome.violations.isEmpty { people[index].violations = (people[index].violations ?? []) + outcome.violations }
            if keepsEarlierCommitment {
                people[index].pendingPostRelease = before.pendingPostRelease ?? outcome.newPostRelease
            } else {
                people[index].pendingPostRelease = outcome.newPostRelease ?? (outcome.personStatus == .incarcerated ? before.pendingPostRelease : nil)
            }
            // Life imprisonment: no probation or supervision will follow.
            if people[index].releaseDate == .distantFuture {
                people[index].probation = nil
                people[index].postRelease = nil
                people[index].pendingPostRelease = nil
            }

            people[index].propensity = (people[index].propensity + outcome.propensity) / 2 + 0.05
            people[index].appearances.append(appearance)
            if let profile = d.profile { people[index].profile = profile }
        } else {
            let birthYear = CourtCalendar.calendar.component(.year, from: currentDate) - d.age
            people.append(PersonRecord(id: d.personID, name: d.name, birthYear: birthYear, occupation: d.occupation,
                                       background: d.background, priors: d.priors + outcome.newPriors,
                                       status: outcome.personStatus, releaseDate: outcome.releaseDate,
                                       probation: outcome.newProbation, propensity: outcome.propensity,
                                       appearances: [appearance], releaseNote: outcome.releaseBasis,
                                       pendingPostRelease: outcome.newPostRelease,
                                       custodyDocket: outcome.personStatus == .incarcerated ? courtCase.docket : nil,
                                       profile: d.profile))
        }
        // The stay-away order protecting the victim goes on the person's record, where the world can test it.
        if let order = outcome.stayAwayOrder, let index = people.firstIndex(where: { $0.id == d.personID }) {
            people[index].stayAwayOrders = (people[index].stayAwayOrders ?? []) + [order]
        }
        // Credit already satisfied the prison term: post-release supervision starts today.
        if let index = people.firstIndex(where: { $0.id == d.personID }), people[index].status != .incarcerated,
           var prs = people[index].pendingPostRelease {
            prs.ends = CourtCalendar.calendar.date(byAdding: .month, value: prs.supervisionMonths, to: currentDate) ?? currentDate
            people[index].postRelease = prs
            people[index].pendingPostRelease = nil
        }

        var verdictNews = outcome.news
        verdictNews.date = currentDate
        post(verdictNews)
        let appellant = (outcome.appealNotice ?? "").contains("The State") ? "the State" : "the defendant"
        pending.append(contentsOf: trackAppeals(outcome.pending, docket: courtCase.docket, caption: courtCase.caption, personID: d.personID,
                                                appellant: appellant, plea: outcome.verdictLines.contains { $0.verdictLabel.contains("plea") || $0.verdictLabel.contains("No contest") },
                                                grounds: outcome.appealGrounds, groundErrors: outcome.appealGroundErrors))
        finishEntry(matterID: courtCase.id, outcome: outcome.appearanceSummary)
        save()
    }

    func resetCareer() {
        judgeName = nil
        county = nil
        currentDate = Date()
        history = []
        people = []
        news = []
        pending = []
        currentCase = nil
        currentHearing = nil
        currentCalendar = nil
        today = nil
        scheduled = []
        digest = []
        appeals = []
        retrials = []
        stats = CareerStats()
        recentTemplates = []
        recentLineKeys = []
        usedSignatures = []
        weekNumber = 1
        reputation = []
        unseated = false
        reliefQueue = []
        murderLastWeek = false
        reoffenseQueue = []
        freshAppeals = []
        careerStart = Date()
        docketSequence = 0
        sessionEnds = Date()
        lightWeeks = false
        yearStartStats = nil
        lastYearReviewed = nil
        seedBase = UInt64.random(in: 1...UInt64.max / 2)
        save()
    }

    func person(_ id: UUID) -> PersonRecord? {
        people.first { $0.id == id }
    }

    // MARK: Time

    /// Moves the world forward to a new date: appeals come down, sentences end, probation finishes.
    private func advanceWorld(to date: Date) {
        var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(date.timeIntervalSince1970)) / 86_400))
        currentDate = date

        // Scheduled events
        let due = pending.filter { $0.due <= currentDate }.sorted { $0.due < $1.due }
        pending.removeAll { $0.due <= currentDate }
        for event in due {
            var item = event.news
            item.date = event.due
            post(item)
            if let retrial = event.retrial { retrials.append(retrial) }
            if let followUp = event.reoffense {
                reoffenseQueue.append(followUp)
                if followUp.note.hasPrefix("You ") { stats.chargedAgainAfterRelease = (stats.chargedAgainAfterRelease ?? 0) + 1 }
            }
            if let relief = event.reliefMotion { reliefQueue.append(relief) }
            if item.kind == .exoneration { stats.exonerations += 1 }
            if let personID = event.personID, let index = people.firstIndex(where: { $0.id == personID }) {
                switch event.effect {
                case .releasePerson:
                    var custodyFromThisCase = true
                    if let docket = event.vacatesDocket {
                        people[index].priors.removeAll { $0.docket == docket || $0.docket == docket + " (PV)" }
                        if people[index].probation?.docket == docket { people[index].probation = nil }
                        // Supervision after release from the vacated sentence goes with it.
                        if people[index].postRelease?.docket == docket { people[index].postRelease = nil }
                        if people[index].pendingPostRelease?.docket == docket { people[index].pendingPostRelease = nil }
                        // Custody imposed later in another case continues.
                        if let held = people[index].custodyDocket {
                            custodyFromThisCase = held == docket || held == docket + " (PV)"
                        } else {
                            let lastDocket = people[index].appearances.last?.docket
                            custodyFromThisCase = lastDocket == nil || lastDocket == docket || lastDocket == docket + " (PV)"
                        }
                    } else {
                        people[index].probation = nil
                    }
                    if people[index].status != .incarcerated {
                        people[index].status = people[index].probation == nil ? .free : .probation
                    } else if custodyFromThisCase {
                        // The decision itself is the news.
                        releaseFromCustody(index, on: event.due, announce: false, rng: &rng)
                    }
                case .raisePropensity:
                    people[index].propensity = min(0.85, people[index].propensity + 0.15)
                case .resentence:
                    // Resentencing on remand can only shorten the term the appeal attacked.
                    let heldOnThisDocket = people[index].custodyDocket.map { $0 == event.news.docket } ?? true
                    if let restore = event.restoreProbation {
                        // A probation order vacated on appeal: the violation comes off the record and probation stands as it
                        // was before the order, including any CRV it counted.
                        if let id = event.removesViolationID { people[index].violations?.removeAll { $0.id == id } }
                        // Probation whose term has since run out isn't brought back; it's simply over.
                        guard restore.ends > currentDate else {
                            if people[index].status == .incarcerated && heldOnThisDocket {
                                releaseFromCustody(index, on: event.due, announce: false, rng: &rng)
                            }
                            people[index].probation = nil
                            if people[index].status != .incarcerated { people[index].status = .free }
                            break
                        }
                        people[index].probation = restore
                        if people[index].status == .incarcerated && heldOnThisDocket {
                            people[index].releaseDate = nil
                            people[index].releaseNote = nil
                            people[index].custodyDocket = nil
                            people[index].status = .probation
                        } else if people[index].status != .incarcerated {
                            people[index].status = .probation
                        }
                    } else if people[index].status == .incarcerated, heldOnThisDocket, let newRelease = event.newReleaseDate {
                        if newRelease <= currentDate {
                            releaseFromCustody(index, on: event.due, announce: true, rng: &rng)
                        } else if newRelease < (people[index].releaseDate ?? .distantFuture) {
                            people[index].releaseDate = newRelease
                        }
                    }
                case .lengthen:
                    // Resentenced upward on the State's appeal: the lawful term runs from the original judgment.
                    guard let lawful = event.newReleaseDate, lawful > currentDate, let docket = event.news.docket else { break }
                    if people[index].status == .incarcerated {
                        if people[index].custodyDocket == docket || people[index].custodyDocket == nil {
                            people[index].releaseDate = max(people[index].releaseDate ?? lawful, lawful)
                        }
                    } else {
                        if people[index].probation?.docket == docket { people[index].probation = nil }
                        people[index].status = .incarcerated
                        people[index].releaseDate = lawful
                        people[index].custodyDocket = docket
                        people[index].releaseNote = "Resentenced on remand after the State's appeal; committed to serve the lawful term."
                        people[index].appearances.append(PersonRecord.Appearance(docket: docket, date: event.due, charges: "Resentencing on remand",
                                                                                 outcome: "Committed: the Court of Appeals vacated the original sentence as unauthorized"))
                    }
                case .none:
                    break
                }
            }
            if event.news.kind == .appeal, let docket = event.news.docket {
                let followUp = Appeals.isFollowUp(event)
                // Older saves didn't tag events with their appeal: match the docket, preferring the appeal this decision was set for.
                let tracked = event.appealID.flatMap { id in appeals.firstIndex { $0.id == id } }
                    ?? appeals.firstIndex { $0.docket == docket && $0.isPending == !followUp && $0.decisionDue == event.due }
                    ?? appeals.firstIndex { $0.docket == docket && $0.isPending == !followUp }
                    ?? appeals.firstIndex { $0.docket == docket }
                if let index = tracked {
                    if appeals[index].decided == nil && !followUp {
                        appeals[index].decided = event.due
                        appeals[index].result = Appeals.status(for: event)
                        appeals[index].opinion = event.news.body
                        appeals[index].holdings = Appeals.holdings(for: appeals[index], reversed: appeals[index].wasReversed)
                        freshAppeals.append(appeals[index].id)
                    } else {
                        appeals[index].followUps.append("\(SentenceFormat.shortDate(event.due)): \(event.news.headline)")
                        if followUp { appeals[index].result = Appeals.status(for: event) }
                    }
                }
                let appealID = tracked.map { appeals[$0].id }
                let record = history.firstIndex { appealID != nil && $0.appealID == appealID }
                    ?? history.lastIndex { $0.docket == docket && $0.appealStatus == "Appeal pending" }
                    ?? history.firstIndex { $0.docket == docket && $0.resolvedKind != "continuance" }
                if let record { history[record].appealStatus = Appeals.status(for: event) }
            }
        }

        checkStayAwayOrders(rng: &rng)

        // Sentences expire
        for index in people.indices {
            if let prs = people[index].postRelease, prs.ends <= currentDate { people[index].postRelease = nil }
            let person = people[index]
            switch person.status {
            case .incarcerated:
                if let release = person.releaseDate, release <= currentDate {
                    releaseFromCustody(index, on: release, announce: true, rng: &rng)
                }
            case .probation:
                // Probation stays open while a violation hearing on it is still to be heard.
                if let probation = person.probation, probation.ends <= currentDate, !violationHearingPending(for: person.id) {
                    people[index].status = .free
                    people[index].probation = nil
                    stats.probationCompleted += 1
                    let treatmentCourt = (probation.conditions ?? []).contains { $0.contains("Drug Treatment Court") }
                    if treatmentCourt {
                        post(NewsItem(date: probation.ends, kind: .community,
                                      headline: "\(person.name) graduates from Hollis County Drug Treatment Court",
                                      body: "\(person.name) was among the graduates honored this week. \"I didn't think I'd make it,\" \(person.lastName) told the gathering. The program's coordinator credited the team of judges, treatment providers, and probation officers.",
                                      docket: probation.docket, prominence: 2))
                    } else if probation.imposedInThisCourt && rng.chance(0.3) {
                        post(NewsItem(date: probation.ends, kind: .community,
                                      headline: NewsDesk.probationDoneHeadline(person.name, last: person.lastName, rng: &rng),
                                      body: "\(person.name) completed probation in \(probation.docket) this week, closing the case.",
                                      docket: probation.docket))
                    }
                }
            case .free:
                break
            }
        }
    }

    /// Each week, anyone free under a stay-away order this court entered may break it. A violation is news, and
    /// the new charge comes back to this courtroom.
    private func checkStayAwayOrders(rng: inout SeededRNG) {
        guard let judgeName else { return }
        for index in people.indices where people[index].status != .incarcerated {
            guard var orders = people[index].stayAwayOrders, !orders.isEmpty else { continue }
            for o in orders.indices where orders[o].issued < currentDate && orders[o].expires > currentDate {
                let risk = (orders[o].domestic ? 0.025 : 0.02) * (0.5 + people[index].propensity * 2.5)
                guard rng.chance(min(0.08, risk)) else { continue }
                orders[o].violations += 1
                stats.orderViolations = (stats.orderViolations ?? 0) + 1
                let person = people[index], order = orders[o]
                let what = rng.pick(["showed up at \(order.protectedName)'s workplace", "was found parked outside \(order.protectedName)'s home",
                                     "sent \(order.protectedName) dozens of messages from a new number", "followed \(order.protectedName) from a grocery store",
                                     "left a note on \(order.protectedName)'s car"])
                post(NewsItem(date: currentDate, kind: .arrest,
                              headline: "\(person.name) arrested for violating court order protecting \(order.protectedName)",
                              body: "Deputies say \(person.name) \(what), in violation of the stay-away order Judge \(lastName(judgeName)) entered in \(order.docket) on \(SentenceFormat.shortDate(order.issued)). \(person.lastName) is being held pending a first appearance.",
                              docket: order.docket, prominence: 2))
                let toCourt = CourtCalendar.calendar.date(byAdding: .day, value: 7 * rng.int(3...6), to: currentDate) ?? currentDate
                pending.append(PendingEvent(due: toCourt,
                                            news: NewsItem(date: toCourt, kind: .arrest, headline: "\(person.name) to face Judge \(lastName(judgeName)) again",
                                                           body: "The new charges against \(person.name), arising from the alleged violation of a stay-away order protecting \(order.protectedName), are set for trial before the judge who entered the order.",
                                                           docket: order.docket),
                                            personID: person.id,
                                            reoffense: Reoffense(personID: person.id, templateKeys: Consequences.violationTemplates(domestic: order.domestic),
                                                                 victimName: order.protectedName, incident: currentDate,
                                                                 note: "Charged with violating the stay-away order you entered on \(SentenceFormat.shortDate(order.issued)) in \(order.docket), protecting \(order.protectedName). It was \(person.lastName)'s violation number \(order.violations).",
                                                                 priorOffense: person.priors.first { $0.docket == order.docket }?.offense, priorDate: order.issued)))
                break
            }
            people[index].stayAwayOrders = orders
        }
    }

    /// Releases a person whose custody has ended: post-release supervision starts, probation begins or resumes, and the
    /// release is counted. A hospital commitment after an insanity verdict isn't a sentence, so it isn't counted as one.
    private func releaseFromCustody(_ index: Int, on release: Date, announce: Bool, rng: inout SeededRNG) {
        let person = people[index]
        let hospital = person.releaseNote?.contains("not guilty by reason of insanity") ?? false
        // County jail, not prison: a CRV, a quick dip, a probation sanction, or a misdemeanor term counted in days.
        let note = person.releaseNote ?? ""
        let sanction = (person.custodyDocket?.hasSuffix("(PV)") ?? false) || note.hasPrefix("Quick dip") || note.hasPrefix("Confinement in response")
        let jail = sanction || note.contains(" days active") || (note.contains(" days") && !note.contains("months"))
        people[index].releaseDate = nil
        people[index].releaseNote = nil
        people[index].custodyDocket = nil
        if var prs = person.pendingPostRelease {
            prs.ends = CourtCalendar.calendar.date(byAdding: .month, value: prs.supervisionMonths, to: release) ?? release
            people[index].postRelease = prs
            people[index].pendingPostRelease = nil
        }
        if let probation = person.probation, probation.ends > currentDate {
            people[index].status = .probation
        } else {
            // Probation that ran out during a CRV or quick dip is finished, not revoked.
            if person.probation != nil && sanction { stats.probationCompleted += 1 }
            people[index].status = .free
            people[index].probation = nil
        }
        if !hospital && !jail { stats.releasedFromPrison += 1 }
        // A few days on a probation sanction isn't news.
        guard announce, !sanction, rng.chance(0.4) else { return }
        let docket = person.custodyDocket ?? person.appearances.last?.docket
        if hospital {
            post(NewsItem(date: release, kind: .community,
                          headline: "\(person.name) released from state hospital",
                          body: "\(person.name), \(person.age(on: currentDate)), was released from a state psychiatric hospital this week after a hearing found that \(person.lastName) is no longer mentally ill or dangerous to others. \(person.lastName) had been committed after a verdict of not guilty by reason of insanity in Hollis County Superior Court.",
                          docket: docket, prominence: 1))
            return
        }
        var body = "\(person.name), \(person.age(on: currentDate)), sentenced in Hollis County Superior Court, was released this week"
        if people[index].status == .probation {
            body += person.probationResumesOnRelease ? " and returns to \(person.probationKind) probation." : " and begins a term of \(person.probationKind) probation."
        } else if people[index].postRelease != nil {
            body += " and begins post-release supervision."
        } else {
            body += "."
        }
        post(NewsItem(date: release, kind: .community,
                      headline: NewsDesk.releaseHeadline(person.name, last: person.lastName, jail: jail, rng: &rng),
                      body: body + " " + NewsDesk.releaseColor(person.lastName, town: rng.pick(county?.towns ?? ["Port Hollis"]), jail: jail, rng: &rng),
                      docket: docket, prominence: 1))
    }

    /// Whether a probation violation hearing for this person is still waiting on the calendar.
    private func violationHearingPending(for personID: UUID) -> Bool {
        let waiting = scheduled.map(\.entry) + (today?.entries.filter(\.isOpen) ?? [])
        return waiting.contains { entry in
            if case .hearing(let h) = entry.matter { return h.personID == personID }
            return false
        }
    }

    private func post(_ item: NewsItem) {
        var item = item
        // Every story has a writer and a page.
        if item.byline == nil || item.section == nil {
            let (reporter, section) = NewsDesk.desk(for: item.kind)
            if item.byline == nil && !item.headline.hasPrefix("Week ") { item.byline = NewsDesk.byline(reporter, paper: county?.newspaper ?? "Ledger") }
            if item.section == nil { item.section = item.headline.hasPrefix("Week ") ? "Your court" : section }
        }
        news.insert(item, at: 0)
        if news.count > 500 { news.removeLast(news.count - 500) }
    }

    private func lastName(_ name: String) -> String {
        name.components(separatedBy: " ").last ?? name
    }

    // MARK: Persistence

    private func save() {
        let data = SaveData(judgeName: judgeName, county: county, currentDate: currentDate, docketSequence: docketSequence,
                            history: history, people: people, news: news, pending: pending,
                            currentCase: currentCase, currentHearing: currentHearing, recentTemplates: recentTemplates,
                            usedSignatures: usedSignatures, seedBase: seedBase,
                            currentCalendar: currentCalendar, retrials: retrials, stats: stats,
                            today: today, scheduled: scheduled, openingMinutes: openingMinutes, sessionEnds: sessionEnds,
                            digest: digest, appeals: appeals, recentLineKeys: recentLineKeys, careerStart: careerStart,
                            weekNumber: weekNumber, lightWeeks: lightWeeks, yearStartStats: yearStartStats,
                            reputation: reputation, lastYearReviewed: lastYearReviewed, unseated: unseated,
                            reliefQueue: reliefQueue, murderLastWeek: murderLastWeek, reoffenseQueue: reoffenseQueue,
                            freshAppeals: freshAppeals)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        guard let raw = UserDefaults.standard.data(forKey: saveKey) else { return }
        let data: SaveData
        do {
            data = try JSONDecoder().decode(SaveData.self, from: raw)
        } catch {
            // Keep the career that couldn't be read under its own key before a new one can be saved over it.
            let backupKey = saveKey + ".backup-\(Int(Date().timeIntervalSince1970))"
            UserDefaults.standard.set(raw, forKey: backupKey)
            NSLog("JudgeSim: the saved career could not be read and was kept under %@: %@", backupKey, String(describing: error))
            return
        }
        judgeName = data.judgeName
        county = data.county
        currentDate = data.currentDate
        docketSequence = data.docketSequence
        history = data.history
        people = data.people
        news = data.news
        pending = data.pending
        currentCase = data.currentCase
        currentHearing = data.currentHearing
        recentTemplates = data.recentTemplates
        usedSignatures = data.usedSignatures ?? []
        seedBase = data.seedBase
        currentCalendar = data.currentCalendar
        retrials = data.retrials ?? []
        stats = data.stats ?? CareerStats()
        scheduled = data.scheduled ?? []
        digest = data.digest ?? []
        appeals = data.appeals ?? []
        recentLineKeys = data.recentLineKeys ?? []
        openingMinutes = Self.courtOpening(data.openingMinutes ?? openingMinutes)
        sessionEnds = data.sessionEnds ?? sessionFriday(for: currentDate)
        today = data.today
        // Older saves didn't record the first week; the earliest record stands in for it.
        careerStart = data.careerStart ?? CourtCalendar.monday(onOrBefore: ([currentDate] + history.map(\.date) + news.map(\.date)).min() ?? currentDate)
        weekNumber = data.weekNumber ?? calendarWeekNumber
        lightWeeks = data.lightWeeks ?? false
        reputation = data.reputation ?? []
        unseated = data.unseated ?? false
        yearStartStats = data.yearStartStats
        lastYearReviewed = data.lastYearReviewed
        reliefQueue = data.reliefQueue ?? []
        murderLastWeek = data.murderLastWeek ?? false
        reoffenseQueue = data.reoffenseQueue ?? []
        freshAppeals = data.freshAppeals ?? []
        // Runs only after every field is restored: it may save, and an earlier save would drop today's calendar.
        backfillAppeals()
        if today == nil && judgeName != nil {
            // An older save: start the calendar today, keeping any matter left open.
            currentDate = CourtCalendar.weekday(onOrAfter: currentDate)
            sessionEnds = sessionFriday(for: currentDate)
            var day = buildDay(currentDate, kind: .trial, sessionDay: 1)
            if let currentCase { day.entries.insert(DocketEntry(matter: .trial(currentCase)), at: 0) }
            if let currentHearing { day.entries.insert(DocketEntry(matter: .hearing(currentHearing)), at: 0) }
            if let currentCalendar { day.entries.insert(DocketEntry(matter: .calendar(currentCalendar)), at: 0) }
            currentCase = nil
            currentHearing = nil
            currentCalendar = nil
            today = day
            save()
        }
    }
}
