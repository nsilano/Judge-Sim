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
    /// Cases whose wait for a trial date made the news or did harm (optional for older saves).
    var delayedCases: Int? = nil
    /// Cases this judge handed to another judge.
    var delegated: Int? = nil
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
    var arrestOrders: [ArrestOrder]?
    var schedule: CourtSchedule?
    var awaiting: [AwaitingCase]?
    var weekTally: CourtDay.Tally?
    var mood: CourthouseMood?
    var investigations: [OpenInvestigation]?
    var placeHistory: [String: [String]]?
    var residents: [Resident]?
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
    /// Orders for arrest this court issued for failures to appear, newest first.
    @Published private(set) var arrestOrders: [ArrestOrder] = []
    /// The judge's standing schedule: court days, daily limits, one-day changes and time off.
    @Published private(set) var schedule = CourtSchedule()
    /// Cases set for trial with no date yet; the judge picks each one's date.
    @Published private(set) var awaiting: [AwaitingCase] = []
    /// How this week's trials came out, for the week in review.
    private var weekTally = CourtDay.Tally()
    /// How the prosecutors and defenders feel about the judge.
    @Published private(set) var mood = CourthouseMood()
    /// Crimes the paper is following before anyone is charged; each becomes a case at the arrest.
    @Published private(set) var investigations: [OpenInvestigation] = []
    /// The dockets that came out of each place on the county map, oldest first.
    @Published private(set) var placeHistory: [String: [String]] = [:]
    /// Victims and witnesses: everyone who has come through the court other than as a defendant.
    @Published private(set) var residents: [Resident] = []
    /// What happened in court since the paper last went out.
    private var happenings: [Happening] = []

    private func happened(_ h: Happening) {
        if case .scheduleChanged = h { happenings.removeAll { if case .scheduleChanged = $0 { return true } else { return false } } }
        happenings.append(h)
    }
    /// What the last calendar call decided, and where each case went, for the results screen.
    @Published private(set) var lastCalendarResults: [String] = []
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

    var casesHeard: Int { history.filter { !["continuance", "reassigned"].contains($0.resolvedKind) }.count }
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
        for item in NewsDesk.weekly(snapshot, rng: &rng) {
            // A new prosecutor joins the District Attorney's office: the courthouse roster gets the name, so the
            // new ADA appears under Courthouse names and starts trying cases.
            if item.headline == "New assistant district attorney sworn in",
               let name = item.body.components(separatedBy: ", a graduate").first, !name.isEmpty,
               var roster = self.county, !roster.assistantDAs.contains(name) {
                roster.assistantDAs.append(name)
                // The office stays about the same size: the longest-serving ADA moves on.
                if roster.assistantDAs.count > 6 { roster.assistantDAs.removeFirst() }
                self.county = roster
            }
            post(item)
        }
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
        let electionDay = CourtCalendar.electionDay(in: newYear)
        let crossedElection = previous < electionDay && electionDay <= next
        // An emergency judge isn't on the ballot.
        if crossedElection, !unseated, !emergencyJudge, Reputation.isElectionYear(newYear, careerStartYear: startYear) {
            var survey = Reputation.survey(year: newYear, stats: stats, appeals: appeals, history: history)
            var rng = SeededRNG(seed: seedBase ^ UInt64(newYear))
            let share = Reputation.voteShare(survey, rng: &rng)
            let percent = Int((share * 100).rounded())
            let won = share >= 0.5
            post(NewsItem(date: electionDay, kind: .community,
                          headline: won ? "\(judgeName) wins reelection to the Superior Court bench" : "\(judgeName) unseated in Superior Court race",
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
        currentDate = nextSittingDay(onOrAfter: currentDate)
        // The new judge inherits a couple of indicted cases waiting for trial dates; more come as the weeks go on.
        var intakeRNG = SeededRNG(seed: seedBase ^ 0xF125_7A11)
        var used = Set<UUID>()
        for _ in 0..<2 {
            if let c = generateCase(date: currentDate, rng: &intakeRNG, excluding: &used, storySlot: true, allowMurder: false) {
                awaitCase(c, note: "Indicted before you took the bench; waiting for a trial date.", on: currentDate)
            }
        }
        // Day one starts with an empty docket: the new judge sets the first trials from the waiting list.
        today = CourtDay(date: currentDate, clock: CourtCalendar.opening(on: currentDate, minutesAfterMidnight: openingMinutes),
                         kind: .trial, entries: [], sessionDay: 1)
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

    /// Moves the courtroom clock forward. A court day can run late, but never past midnight; whatever isn't reached is
    /// carried to the next day with room when the judge adjourns.
    private func advanceClock(_ day: inout CourtDay, minutes: Int) {
        let cal = CourtCalendar.calendar
        day.clock = cal.date(byAdding: .minute, value: minutes, to: day.clock) ?? day.clock
        let lastMinute = cal.date(bySettingHour: 23, minute: 59, second: 0, of: day.date) ?? day.date
        day.clock = min(day.clock, lastMinute)
        currentDate = cal.startOfDay(for: day.date)
    }

    /// Leaving a matter without a continuance: whatever was saved from an earlier sitting is set aside, and the
    /// matter is heard from the start when it's called again.
    func startOver(_ matterID: UUID) {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.matterID == matterID }) else { return }
        day.entries[index].resume = nil
        today = day
        save()
    }

    /// Records an order for arrest the court signed, so its status can be followed until the case is heard.
    private func issueArrestOrder(for c: CourtCase, issued: Date, servedOn: Date) {
        let bond = c.background.map { _ in "a doubled secured bond" } ?? "a secured bond"
        arrestOrders.insert(ArrestOrder(personID: c.defendant.personID, personName: c.defendant.name, docket: c.docket,
                                        offense: c.charges.first?.law.title ?? "the charges", issued: issued,
                                        servedOn: max(servedOn, issued), bond: bond), at: 0)
        if arrestOrders.count > 60 { arrestOrders.removeLast(arrestOrders.count - 60) }
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
        // A matter is heard on the day it is called, including a trial resumed after a continuance.
        let heard = CourtCalendar.calendar.startOfDay(for: day.date)
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
        let target = nextSittingDay(onOrAfter: max(date, nextCourtDate))
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

    /// The next day the judge sits after today.
    var nextCourtDate: Date { nextSittingDay(after: today?.date ?? currentDate) }

    /// The first day on or after this date that the judge sits.
    func nextSittingDay(onOrAfter date: Date) -> Date {
        let cal = CourtCalendar.calendar
        var day = cal.startOfDay(for: date)
        for _ in 0..<500 {
            if schedule.sits(on: day) { return day }
            day = cal.date(byAdding: .day, value: 1, to: day) ?? day
        }
        return CourtCalendar.weekday(onOrAfter: date)
    }

    func nextSittingDay(after date: Date) -> Date {
        nextSittingDay(onOrAfter: CourtCalendar.calendar.date(byAdding: .day, value: 1, to: CourtCalendar.calendar.startOfDay(for: date)) ?? date)
    }

    /// The trials a week takes, under the judge's usual schedule (at least one).
    var trialCap: Int { max(1, schedule.weeklyTrials) }

    func trialCap(forWeekOf date: Date) -> Int {
        let monday = CourtCalendar.monday(onOrBefore: date)
        return (0..<5).reduce(0) { total, offset in
            total + schedule.limit(on: CourtCalendar.calendar.date(byAdding: .day, value: offset, to: monday) ?? monday).trials
        }
    }

    /// The most matters on a calendar call.
    private var calendarCap: Int { lightWeeks ? 4 : 6 }

    /// Trials carried from a full day and waiting their turn.
    var trialBacklog: Int {
        scheduled.filter { $0.entry.carriedOver == true }.count
    }

    /// The holidays that close the courthouse during the current week.
    var holidaysThisWeek: [(Date, String)] {
        CourtCalendar.holidays(inWeekOf: CourtCalendar.monday(onOrBefore: today?.date ?? currentDate))
    }

    static func isMurder(_ c: CourtCase) -> Bool {
        c.charges.contains { $0.law.id.hasPrefix("murder") }
    }

    /// The next court day always opens as a criminal session.
    var nextCourtDayKind: (kind: CourtDay.Kind, newSession: Bool) { (.trial, true) }

    /// Closes today's court and opens the next day the judge sits. Whatever wasn't reached today goes to the next day
    /// with room. The world moves through every day in between: sentences run, appeals come down, new cases are filed.
    func adjourn() {
        guard let day = today else { return }
        freshAppeals = []
        let cal = CourtCalendar.calendar
        let next = nextCourtDate
        let seenBefore = Set(news.map(\.id))
        // Matters not reached today wait for the next day with room; none of it is anyone's fault.
        for entry in day.entries where entry.isOpen {
            var carried = entry
            carried.status = .pending
            carried.carriedOver = true
            if !(carried.note ?? "").contains("Not reached") {
                carried.note = ((carried.note ?? "") + " Not reached on \(SentenceFormat.shortDate(day.date)).").trimmingCharacters(in: .whitespaces)
            }
            place(carried, from: next)
        }
        let releasedBefore = stats.releasedFromPrison
        let completedBefore = stats.probationCompleted
        let appealsBefore = appeals.filter { !$0.isPending }.count
        // Walk the days between, so each day's events land on their own date.
        var cursor = cal.startOfDay(for: day.date)
        var leaveDays = 0
        while cursor < next {
            let previous = cursor
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? next
            if schedule.isOff(cursor) && CourtCalendar.isCourtDay(cursor) { leaveDays += 1 }
            let newWeek = !cal.isDate(CourtCalendar.monday(onOrBefore: previous), inSameDayAs: CourtCalendar.monday(onOrBefore: cursor))
            if newWeek {
                closeWeek(endingBefore: cursor)
            }
            advanceWorld(to: cursor, weekly: newWeek)
            resolveInvestigations(on: cursor)
            creditWaitingJailTime(through: cursor)
            yearlyEvents(from: previous, to: cursor)
            if newWeek { localPages(weekOf: previous, publishing: cursor) }
            if CourtCalendar.isCourtDay(cursor) {
                var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(cursor.timeIntervalSince1970)) / 3_600) ^ 0x1A7E)
                intake(on: cursor, rng: &rng)
                reviewWaiting(on: cursor, rng: &rng)
                publishDailyPaper(on: cursor, rng: &rng)
            }
        }
        if leaveDays > 0, let judgeName {
            var summary = ["Judge \(lastName(judgeName)) returned to the bench after \(leaveDays) court day\(leaveDays == 1 ? "" : "s") away."]
            let released = stats.releasedFromPrison - releasedBefore
            let completed = stats.probationCompleted - completedBefore
            let decided = appeals.filter { !$0.isPending }.count - appealsBefore
            if released > 0 { summary.append("\(released) \(released == 1 ? "person" : "people") you sentenced left custody.") }
            if completed > 0 { summary.append("\(completed) finished probation.") }
            if decided > 0 { summary.append("The Court of Appeals decided \(decided) appeal\(decided == 1 ? "" : "s") from your court.") }
            if awaiting.count > 0 { summary.append("\(awaiting.count) case\(awaiting.count == 1 ? " is" : "s are") waiting for a trial date.") }
            post(NewsItem(date: next, kind: .community, headline: "Judge \(lastName(judgeName)) back from leave", body: summary.joined(separator: " ")))
        }
        sessionEnds = next
        today = buildDay(next, kind: .trial, sessionDay: 1)
        digest = news.filter { !seenBefore.contains($0.id) }
        save()
    }

    /// Everyone besides the defendant who took part in a trial goes into the court's memory: the victim, and each
    /// ordinary witness, with the town and job the case gave them.
    private func rememberParticipants(_ c: CourtCase) {
        let town = c.investigation?.facts?.town
        func remember(_ name: String, part: String, occupation: String? = nil, livesHere: Bool = false, died: Bool = false) {
            guard !name.isEmpty, !people.contains(where: { $0.name == name }) else { return }
            let role = Resident.Role(date: currentDate, docket: c.docket, caption: c.caption, part: part)
            if let i = residents.firstIndex(where: { $0.name == name }) {
                if !residents[i].roles.contains(where: { $0.docket == c.docket }) { residents[i].roles.append(role) }
                if residents[i].occupation == nil { residents[i].occupation = occupation }
                if residents[i].town == nil && livesHere { residents[i].town = town }
                if died { residents[i].deceased = true }
            } else {
                residents.append(Resident(name: name, town: livesHere ? town : nil, occupation: occupation, deceased: died, roles: [role]))
            }
        }
        if let victim = c.victimName, victim != "the complainant" {
            remember(victim, part: "Victim", livesHere: true, died: Consequences.victimDied(c))
        }
        for w in c.witnesses where w.lay == true && w.isDefendant != true && w.name != c.victimName {
            let side = w.calledBy == .prosecution ? "State's witness" : "Defense witness"
            remember(w.name, part: "\(side) (\(w.role.prefix(1).lowercased() + w.role.dropFirst()))",
                     occupation: Residents.isPlaceJob(w.role) ? w.role : nil, livesHere: w.role.lowercased().contains("neighbor"))
        }
    }

    /// Investigations that end in an arrest today: the paper names the defendant and the case comes to the court.
    private func resolveInvestigations(on date: Date) {
        guard let county, let judgeName else { return }
        let cal = CourtCalendar.calendar
        let due = investigations.filter { cal.startOfDay(for: $0.arrest) <= cal.startOfDay(for: date) }
        guard !due.isEmpty else { return }
        investigations.removeAll { item in due.contains { $0.id == item.id } }
        for item in due {
            var c = item.courtCase
            c.sessionDate = date
            if var bg = c.background, bg.bondStatus == "Not yet arrested." && bg.onRelease == true {
                bg.bondStatus = "Arrested on \(SentenceFormat.shortDate(item.arrest)) and released on a secured bond."
                c.background = bg
            } else if var bg = c.background, bg.isJailed || bg.bondStatus == "Not yet arrested." {
                bg.onRelease = false
                bg.custodyDays = 1
                bg.bondStatus = "Held in the \(county.name) Detention Center since the arrest on \(SentenceFormat.shortDate(item.arrest))."
                c.background = bg
            }
            post(InvestigationArc.arrestNews(c, on: date, town: item.town, agency: c.investigation?.facts?.agency ?? c.investigatingAgency,
                                             judge: lastName(judgeName), county: county, followed: item.note == nil))
            awaitCase(c, note: item.note ?? "Arrested on \(SentenceFormat.shortDate(item.arrest)) after an investigation the paper followed from \(item.town).",
                      on: date, earliest: item.ready, reason: "Discovery is still being exchanged")
        }
    }

    /// A case built around an arrest the court already knows the date of: the incident comes before it, and the
    /// file's lab work and interviews finish before the first day it could be tried.
    private func freshCase(on date: Date, arrest: Date, incidentBefore: ClosedRange<Int>, categories: Set<LawCategory>? = nil,
                           rng: inout SeededRNG, excluding used: inout Set<UUID>) -> CourtCase? {
        let cal = CourtCalendar.calendar
        let incident = cal.date(byAdding: .day, value: -rng.int(incidentBefore), to: min(arrest, date)) ?? date
        let ready = cal.date(byAdding: .day, value: rng.int(42...56), to: max(arrest, date)) ?? date
        let daysAgo = cal.dateComponents([.day], from: incident, to: ready).day ?? 30
        guard var c = generateCase(date: ready, rng: &rng, excluding: &used, storySlot: false, categories: categories,
                                   allowMurder: false, announce: false, incidentDaysAgo: daysAgo, arrestOn: arrest) else { return nil }
        c.sessionDate = cal.startOfDay(for: date)
        return c
    }

    /// A signed warrant is executed a day or so later; the arrest comes then, and the case lands on the waiting list.
    private func arrestOnWarrant(_ c: CourtCase, note: String, rng: inout SeededRNG) {
        let cal = CourtCalendar.calendar
        guard let facts = c.investigation?.facts else {
            awaitCase(c, note: note, on: currentDate)
            return
        }
        let ready = cal.date(byAdding: .day, value: rng.int(49...63), to: facts.arrest) ?? facts.arrest
        investigations.append(OpenInvestigation(courtCase: c, incident: cal.startOfDay(for: facts.incident), arrest: cal.startOfDay(for: facts.arrest),
                                                town: facts.town, offense: InvestigationArc.subject(c), ready: ready, note: note))
    }

    /// The morning paper: what the court did yesterday, and the life of the county.
    private func publishDailyPaper(on date: Date, rng: inout SeededRNG) {
        guard let county, let judgeName else { return }
        let cal = CourtCalendar.calendar
        let snapshot = DailyNews.Snapshot(
            date: date, county: county, judge: lastName(judgeName), awaiting: awaiting.count,
            jailedWaiting: awaiting.filter { $0.courtCase?.background?.isJailed == true }.count,
            oldestWait: awaiting.map { cal.dateComponents([.day], from: $0.since, to: date).day ?? 0 }.max() ?? 0,
            trialsHeard: trialsHeard, leaveLeft: leaveLeft, recentHeadlines: Set(news.prefix(150).map(\.headline)))
        for item in DailyNews.items(snapshot, happenings: happenings, rng: &rng) { post(item) }
        happenings = []
    }

    /// The end of a court week: the week in review, the new week's number, and the holidays ahead.
    private func closeWeek(endingBefore start: Date) {
        let cal = CourtCalendar.calendar
        let monday = CourtCalendar.monday(onOrBefore: cal.date(byAdding: .day, value: -1, to: start) ?? start)
        let sat = (0..<5).contains { offset in schedule.sits(on: cal.date(byAdding: .day, value: offset, to: monday) ?? monday) }
        if sat {
            post(NewsItem(date: sessionFriday(for: monday), kind: .community, headline: "Week \(weekNumber) in review",
                          body: weekInReview(monday: monday, week: weekNumber)))
            weekNumber += 1
        }
        weekTally = CourtDay.Tally()
        announceHolidays(weekOf: start)
    }

    /// Notice of the days the courthouse is closed in the week court opens.
    private func announceHolidays(weekOf start: Date) {
        for (date, name) in CourtCalendar.holidays(inWeekOf: CourtCalendar.monday(onOrBefore: start)) {
            post(NewsItem(date: start, kind: .community, headline: "Courthouse closed \(date.formatted(.dateTime.weekday(.wide))) for \(name)",
                          body: "The \(county?.courthouse ?? "courthouse") will be closed \(SentenceFormat.shortDate(date)) for \(name), a state court holiday. Matters set that day are heard the next day court is in session.",
                          prominence: 0))
        }
    }

    /// A short account of a court week, from the record.
    private func weekInReview(monday: Date, week: Int) -> String {
        let cal = CourtCalendar.calendar
        let end = cal.date(byAdding: .day, value: 7, to: monday) ?? monday
        let inWeek = history.filter { $0.date >= monday && $0.date < end }
        let trials = inWeek.filter { $0.resolvedKind == "trial" }.count
        let hearings = inWeek.filter { $0.resolvedKind == "hearing" }.count
        let calls = inWeek.filter { $0.resolvedKind == "calendar" }.count
        let continued = inWeek.filter { $0.resolvedKind == "continuance" }.count
        let tally = weekTally
        var parts: [String] = ["\(trials) trial\(trials == 1 ? "" : "s")"]
        if hearings > 0 { parts.append("\(hearings) violation hearing\(hearings == 1 ? "" : "s")") }
        if calls > 0 { parts.append("\(calls) calendar call\(calls == 1 ? "" : "s")") }
        var text = "Week \(week) on the bench (\(SentenceFormat.shortDate(monday)) – \(SentenceFormat.shortDate(sessionFriday(for: monday)))): " + parts.joined(separator: ", ") + "."
        var verdicts: [String] = []
        if tally.convictions > 0 { verdicts.append("\(tally.convictions) conviction\(tally.convictions == 1 ? "" : "s")") }
        if tally.withoutConviction > 0 { verdicts.append("\(tally.withoutConviction) ended without a conviction") }
        if tally.active > 0 { verdicts.append("\(tally.active) active prison sentence\(tally.active == 1 ? "" : "s")") }
        if !verdicts.isEmpty { text += " " + verdicts.joined(separator: ", ").capitalizedFirst + "." }
        if continued > 0 { text += " \(continued) matter\(continued == 1 ? " was" : "s were") continued." }
        if !awaiting.isEmpty { text += " \(awaiting.count) case\(awaiting.count == 1 ? " is" : "s are") waiting for a trial date." }
        return text
    }

    // MARK: Time off

    /// The day the judge would be back after booking off the next `weeks` weeks.
    func leaveReturnDate(weeks: Int) -> Date {
        let cal = CourtCalendar.calendar
        let monday = CourtCalendar.monday(onOrBefore: nextCourtDate)
        let back = cal.date(byAdding: .day, value: 7 * max(1, weeks), to: monday) ?? monday
        return nextSittingDay(onOrAfter: back)
    }

    /// The last day court sits this week.
    var lastCourtDayThisWeek: Date {
        let monday = CourtCalendar.monday(onOrBefore: today?.date ?? currentDate)
        let days = (0..<5).compactMap { CourtCalendar.calendar.date(byAdding: .day, value: $0, to: monday) }.filter { schedule.sits(on: $0) }
        return days.last ?? monday
    }

    /// Books the next `weeks` weeks off and adjourns. The world keeps moving while the judge is away.
    func takeLeave(weeks: Int) {
        guard let day = today else { return }
        let cal = CourtCalendar.calendar
        let start = cal.date(byAdding: .day, value: 1, to: day.date) ?? day.date
        let end = cal.date(byAdding: .day, value: -1, to: leaveReturnDate(weeks: weeks)) ?? start
        bookTimeOff(from: start, to: end)
        adjourn()
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
        save()
    }

    func clearFreshAppeals() {
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

    /// Builds the docket for one court day: what was set for it, and on the first day the judge sits each week,
    /// the administrative calendar call.
    private func buildDay(_ date: Date, kind: CourtDay.Kind, sessionDay: Int) -> CourtDay {
        var rng = SeededRNG(seed: seedBase &+ UInt64(abs(Int(date.timeIntervalSince1970)) / 60) &* 0x2545_F491)
        let cal = CourtCalendar.calendar
        let dayStart = cal.startOfDay(for: date)
        var entries: [DocketEntry] = []

        // Everything set for today, or for a day the court didn't sit.
        let due = scheduled.filter { cal.startOfDay(for: $0.date) <= dayStart }
        scheduled.removeAll { cal.startOfDay(for: $0.date) <= dayStart }
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
                // A trial the court itself couldn't reach costs neither side anything.
                if entry.carriedOver != true { applyDelayCosts(&c, entry: &entry, rng: &rng) }
                // On the calendar now; a later continuance is an ordinary one.
                entry.carriedOver = nil
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

        // Anyone already on a calendar, or waiting for a date, isn't given a second matter.
        var usedPeople = peopleInPlay(plus: entries)

        if kind != .specialSetting && isFirstSittingDayOfWeek(date) {
            // The week's administrative calendar call opens the first day the judge sits.
            if let county {
                var call = CalendarCalls.make(county: county, date: date, docketSequence: docketSequence, people: people,
                                              excluding: usedPeople, seed: rng.next())
                docketSequence += 200
                // Leave room on the calendar for the new arrest, a relief motion, and most weeks a warrant and an arraignment.
                // Fewer new matters while the new judge's courtroom is still filling up.
                let wantsWarrant = rng.chance(0.7 * max(0.3, caseloadRamp))
                let wantsArraignment = !lightWeeks && rng.chance(0.6 * max(0.3, caseloadRamp))
                let reserved = 1 + (reliefQueue.isEmpty ? 0 : 1) + (wantsWarrant ? 1 : 0) + (wantsArraignment ? 1 : 0)
                let room = max(1, calendarCap - reserved)
                if call.matters.count > room {
                    // Probation matters stay (the person is waiting on them); the overflow of the rest goes to another session.
                    let probation: Set<CalendarMatter.Kind> = [.earlyTermination, .pvAdmission]
                    let kept = call.matters.filter { probation.contains($0.kind) }
                    let others = call.matters.filter { !probation.contains($0.kind) }
                    call.matters = kept + Array(others.prefix(max(0, room - kept.count)))
                }
                call.matters.forEach { usedPeople.insert($0.personID) }
                if let relief = reliefQueue.first { usedPeople.insert(relief.personID) }
                // Pleas, continuance motions, failures to appear, and capacity motions are about real cases:
                // what the court orders puts each one on an actual calendar.
                var claimed = Set<UUID>()
                var unbound: [UUID] = []
                for index in call.matters.indices
                where [.quickPlea, .continuance, .failureToAppear, .capacity, .bondModification].contains(call.matters[index].kind) {
                    let kind = call.matters[index].kind
                    if kind == .quickPlea {
                        // A plea offered at the calendar call is a short matter; no written story is spent on it.
                        if let c = generateCase(date: date, rng: &rng, excluding: &usedPeople, storySlot: false, allowMurder: false,
                                                announce: false, generic: true) {
                            call.matters[index] = CalendarCalls.bind(call.matters[index], to: c)
                        }
                        continue
                    }
                    // Motions, missed court dates and bond reviews are about cases already set for trial in this court,
                    // so they feed the trials you hear rather than adding new ones.
                    let pool = scheduled.filter { $0.entry.resume == nil }.map(\.entry) + awaiting.map(\.entry)
                    let waiting = pool.compactMap { entry -> CourtCase? in
                        guard case .trial(let c) = entry.matter, !claimed.contains(c.id),
                              c.templateKey.hasPrefix("story.") else { return nil }
                        let jailed = c.background?.isJailed ?? false
                        switch kind {
                        case .bondModification: return jailed ? c : nil
                        case .failureToAppear: return jailed ? nil : c
                        default: return c
                        }
                    }
                    guard var c = waiting.isEmpty ? nil : rng.pick(waiting) else {
                        unbound.append(call.matters[index].id)
                        continue
                    }
                    claimed.insert(c.id)
                    if kind == .bondModification {
                        call.matters[index] = CalendarCalls.bondReductionMatter(for: c, rng: &rng)
                    } else {
                        if kind == .failureToAppear, var bg = c.background {
                            // Only someone out on bond can fail to appear.
                            bg.onRelease = true
                            bg.bondStatus = "Out on a secured bond; did not answer the calendar call."
                            c.background = bg
                        }
                        call.matters[index] = CalendarCalls.bind(call.matters[index], to: c)
                    }
                }
                // A motion with no case waiting for it isn't on the calendar this week.
                call.matters.removeAll { unbound.contains($0.id) }
                // New cases come in when the trial calendar has room for them.
                let roomForNew = trialsInPipeline < pipelineTarget
                // A new arrest for conditions of release, and a case to arraign and set for trial.
                let held = rng.int(1...3)
                let arrested = cal.date(byAdding: .day, value: -held, to: date) ?? date
                if rng.chance(max(0.4, caseloadRamp)), var c = freshCase(on: date, arrest: arrested, incidentBefore: 0...14, rng: &rng, excluding: &usedPeople) {
                    // Arrested days ago and held until this first hearing on conditions of release.
                    if var bg = c.background {
                        bg.custodyDays = held
                        bg.onRelease = false
                        bg.bondStatus = "Held since the arrest on \(SentenceFormat.shortDate(arrested)) pending a bond hearing; in custody for \(held) days."
                        c.background = bg
                    }
                    call.matters.append(CalendarCalls.bondMatter(for: c, rng: &rng))
                }
                let arrestedEarlier = cal.date(byAdding: .day, value: -rng.int(14...45), to: date) ?? date
                if wantsArraignment && roomForNew, var c = freshCase(on: date, arrest: arrestedEarlier, incidentBefore: 0...20, rng: &rng, excluding: &usedPeople) {
                    // Held since the arrest, if held at all: the count starts on the arrest date.
                    if var bg = c.background, bg.isJailed {
                        bg.custodyDays = max(1, cal.dateComponents([.day], from: arrestedEarlier, to: date).day ?? 1)
                        bg.bondStatus = "Held since the arrest on \(SentenceFormat.shortDate(arrestedEarlier)); in custody for \(bg.custodyDays) days."
                        c.background = bg
                    }
                    call.matters.append(CalendarCalls.arraignmentMatter(for: c))
                }
                // Motions for appropriate relief in cases tried here come back to this judge.
                if !reliefQueue.isEmpty, let judgeName {
                    let relief = reliefQueue.removeFirst()
                    call.matters.insert(CalendarCalls.reliefMatter(relief, judgeLast: lastName(judgeName)), at: 0)
                }
                // Most weeks an officer brings a search warrant application.
                if wantsWarrant && roomForNew {
                    let kind = rng.pick([WarrantApplication.Kind.residenceDrugs, .storageStolen, .phoneRecords])
                    // Nobody is arrested yet: the crime is under investigation, and the warrant, if signed, is executed in a day or three.
                    let execution = cal.date(byAdding: .day, value: rng.int(1...3), to: date) ?? date
                    if var c = freshCase(on: date, arrest: execution, incidentBefore: 5...30, categories: kind.categories, rng: &rng, excluding: &usedPeople) {
                        // Not arrested yet. Whether the defendant will be held or bonded out after the arrest is kept
                        // in onRelease until then.
                        if var bg = c.background {
                            bg.onRelease = bg.custodyDays == 0
                            bg.custodyDays = 0
                            bg.bondStatus = "Not yet arrested."
                            c.background = bg
                        }
                        let w = SearchWarrants.application(for: c, date: date, rng: &rng)
                        call.matters.insert(CalendarCalls.warrantMatter(w, for: c), at: min(1, call.matters.count))
                    }
                }
                call.matters.forEach { usedPeople.insert($0.personID) }
                entries.insert(DocketEntry(matter: .calendar(call)), at: 0)
            }
        }
        return CourtDay(date: date, clock: CourtCalendar.opening(on: date, minutesAfterMidnight: openingMinutes),
                        kind: kind, entries: entries, sessionDay: sessionDay)
    }

    /// Everyone with a matter on a calendar or waiting for a trial date.
    private func peopleInPlay(plus extra: [DocketEntry] = []) -> Set<UUID> {
        var used = Set<UUID>()
        for entry in extra + (today?.entries ?? []) + scheduled.map(\.entry) + awaiting.map(\.entry) {
            switch entry.matter {
            case .trial(let c): used.insert(c.defendant.personID)
            case .hearing(let h): used.insert(h.personID)
            case .calendar(let call): call.matters.forEach { used.insert($0.personID) }
            }
        }
        investigations.forEach { used.insert($0.courtCase.defendant.personID) }
        return used
    }

    /// The first day of its week the judge sits.
    private func isFirstSittingDayOfWeek(_ date: Date) -> Bool {
        guard schedule.sits(on: date) else { return false }
        let cal = CourtCalendar.calendar
        var day = CourtCalendar.monday(onOrBefore: date)
        while day < cal.startOfDay(for: date) {
            if schedule.sits(on: day) { return false }
            day = cal.date(byAdding: .day, value: 1, to: day) ?? date
        }
        return true
    }

    // MARK: The judge's calendar

    /// Trials on a calendar or waiting for a date.
    var trialsInPipeline: Int {
        awaiting.count + investigations.count + scheduled.filter { if case .trial = $0.entry.matter { return true } else { return false } }.count
    }

    /// How many trials the court keeps in the pipeline: about two weeks of the judge's own schedule.
    /// A new judge's courtroom starts quiet and fills over the first couple of months: a quarter of the full
    /// caseload the first week, rising each week to all of it by week ten.
    var caseloadRamp: Double { min(1, 0.25 + Double(calendarWeekNumber - 1) * 0.085) }

    var pipelineTarget: Int { max(2, Int((Double(max(4, 2 * schedule.weeklyTrials + 2)) * caseloadRamp).rounded())) }

    /// Trials and hearings set for a day, today's docket included.
    func counts(on date: Date) -> (trials: Int, hearings: Int) {
        let cal = CourtCalendar.calendar
        var list = scheduled.filter { cal.isDate($0.date, inSameDayAs: date) }.map(\.entry)
        if let day = today, cal.isDate(day.date, inSameDayAs: date) { list += day.entries }
        let trials = list.filter { if case .trial = $0.matter { return true } else { return false } }.count
        let hearings = list.filter { if case .hearing = $0.matter { return true } else { return false } }.count
        return (trials, hearings)
    }

    /// Whether a day has room for one more matter of this kind under the judge's limits.
    func hasRoom(on date: Date, for entry: DocketEntry, extraTrials: Int = 0) -> Bool {
        let limit = schedule.limit(on: date)
        let n = counts(on: date)
        switch entry.matter {
        case .trial: return n.trials + extraTrials < limit.trials
        case .hearing: return n.hearings < limit.hearings
        case .calendar: return schedule.sits(on: date)
        }
    }

    /// The first day from this date the judge sits with room for the matter. A schedule with no room anywhere
    /// falls back to the next day the judge sits.
    func openDay(for entry: DocketEntry, from date: Date) -> Date {
        var day = nextSittingDay(onOrAfter: date)
        for _ in 0..<260 {
            if hasRoom(on: day, for: entry) { return day }
            day = nextSittingDay(after: day)
        }
        return nextSittingDay(onOrAfter: date)
    }

    /// Puts a matter on the first day with room.
    private func place(_ entry: DocketEntry, from date: Date) {
        scheduled.append(ScheduledMatter(date: openDay(for: entry, from: date), entry: entry))
        scheduled.sort { $0.date < $1.date }
    }

    /// A case set for trial with no date yet; the judge chooses it.
    private func awaitCase(_ c: CourtCase, note: String, on date: Date, earliest: Date? = nil, reason: String? = nil,
                           continuances: Int = 0) {
        var entry = DocketEntry(matter: .trial(c), note: note)
        entry.continuances = continuances
        let cal = CourtCalendar.calendar
        let first = earliest.map { cal.startOfDay(for: $0) }
        awaiting.removeAll { $0.courtCase?.id == c.id }
        var item = AwaitingCase(entry: entry, since: cal.startOfDay(for: date),
                                earliest: first.flatMap { $0 > cal.startOfDay(for: date) ? $0 : nil }, earliestReason: reason)
        // Some dates won't work for someone the trial needs.
        var rng = SeededRNG(seed: c.seed ^ 0xC0F1_1C75)
        if rng.chance(0.35) {
            var reasons = ["The lead detective is testifying in federal court in Raleigh",
                           "Defense counsel is in a murder trial in Pitt County",
                           "The State's laboratory analyst is on leave",
                           "A key witness is out of state for work",
                           "Defense counsel has a long-planned family surgery"]
            if c.victimName != nil { reasons.append("The victim has a scheduled surgery and can't travel") }
            var conflicts: [String: String] = [:]
            for _ in 0..<rng.int(1...3) {
                let day = nextSittingDay(onOrAfter: cal.date(byAdding: .day, value: rng.int(7...45), to: date) ?? date)
                conflicts[CourtSchedule.key(day)] = rng.pick(reasons)
            }
            item.conflicts = conflicts
        }
        awaiting.append(item)
    }

    /// How urgently a waiting case needs its date.
    func urgency(of item: AwaitingCase) -> Urgency {
        guard let c = item.courtCase else { return Urgency(level: .routine, score: 0, reasons: []) }
        var u = Urgency.of(c, entry: item.entry, since: item.since, today: today?.date ?? currentDate)
        if let reason = item.priorityReason {
            u.level = max(u.level, .soon)
            u.score += 8
            u.reasons.insert("The DA's office asked for a priority setting: \(reason)", at: 0)
        }
        return u
    }

    /// Waiting cases, most urgent first.
    var awaitingByUrgency: [AwaitingCase] {
        awaiting.map { ($0, urgency(of: $0)) }
            .sorted { ($0.1.level, $0.1.score) > ($1.1.level, $1.1.score) }
            .map(\.0)
    }

    /// Sets a waiting case for trial on a day the judge chooses (or the next day the judge sits after it).
    func setTrialDate(_ id: UUID, to date: Date) {
        guard let index = awaiting.firstIndex(where: { $0.id == id }) else { return }
        var item = awaiting.remove(at: index)
        let cal = CourtCalendar.calendar
        let todayDate = today.map { cal.startOfDay(for: $0.date) } ?? cal.startOfDay(for: currentDate)
        let day = nextSittingDay(onOrAfter: max(cal.startOfDay(for: date), todayDate))
        item.entry.note = ((item.entry.note ?? "") + " Set for trial on \(SentenceFormat.shortDate(day)).").trimmingCharacters(in: .whitespaces)
        // Setting a trial over someone's known conflict costs goodwill with that side.
        if let conflict = item.conflicts?[CourtSchedule.key(day)] {
            item.entry.note = (item.entry.note ?? "") + " Set over a known conflict: \(conflict.prefix(1).lowercased() + String(conflict.dropFirst()))."
            if conflict.contains("Defense counsel") { mood.adjust(prosecutors: 0, defenders: -2) } else { mood.adjust(prosecutors: -2, defenders: 0) }
            CourthouseMood.current = mood
            CalendarCalls.prosecutorEdge = mood.prosecutorEdge
        }
        // The DA's office notices when its priority request is honored.
        if let asked = item.priorityRequested, (cal.dateComponents([.day], from: asked, to: todayDate).day ?? 99) <= 30 {
            mood.adjust(prosecutors: 1, defenders: 0)
            CourthouseMood.current = mood
            CalendarCalls.prosecutorEdge = mood.prosecutorEdge
        }
        if var docket = today, cal.isDate(docket.date, inSameDayAs: day), case .trial(var c) = item.entry.matter {
            creditJailTime(&c, through: day)
            c.sessionDate = day
            refreshDefendant(&c)
            item.entry.matter = .trial(c)
            docket.entries.append(item.entry)
            today = docket
        } else {
            scheduled.append(ScheduledMatter(date: day, entry: item.entry))
            scheduled.sort { $0.date < $1.date }
        }
        if let c = item.courtCase {
            happened(.trialDateSet(caption: c.caption, defendant: c.defendant.name, date: day,
                                   jailed: c.background?.isJailed == true, prominent: c.mediaAttention >= 2))
        }
        save()
    }

    /// A trial set for a date goes back to the list of cases waiting for one.
    func unschedule(_ scheduledID: UUID) {
        guard let index = scheduled.firstIndex(where: { $0.id == scheduledID }), case .trial = scheduled[index].entry.matter else { return }
        let item = scheduled.remove(at: index)
        awaiting.append(AwaitingCase(entry: item.entry, since: today?.date ?? currentDate))
        save()
    }

    /// Dates for every waiting case, most urgent first, on the first days with room after each case is ready.
    func suggestedDates() -> [(id: UUID, date: Date)] {
        var extra: [Date: Int] = [:]
        var out: [(id: UUID, date: Date)] = []
        let start = nextSittingDay(onOrAfter: today?.date ?? currentDate)
        for item in awaitingByUrgency {
            var day = nextSittingDay(onOrAfter: max(start, item.earliest ?? start))
            var found: Date?
            for _ in 0..<260 {
                if hasRoom(on: day, for: item.entry, extraTrials: extra[day] ?? 0) { found = day; break }
                day = nextSittingDay(after: day)
            }
            guard let found else { continue }
            extra[found, default: 0] += 1
            out.append((item.id, found))
        }
        return out
    }

    func acceptSuggestions(_ list: [(id: UUID, date: Date)]) {
        for item in list { setTrialDate(item.id, to: item.date) }
    }

    // MARK: Handing a case to another judge

    /// A waiting case goes to another judge. It's tried there; the result comes back in the paper.
    func reassign(awaitingID: UUID) {
        guard let index = awaiting.firstIndex(where: { $0.id == awaitingID }), let c = awaiting[index].courtCase else { return }
        awaiting.remove(at: index)
        handOff(c)
    }

    /// A trial already set for a date goes to another judge.
    func reassign(scheduledID: UUID) {
        guard let index = scheduled.firstIndex(where: { $0.id == scheduledID }), case .trial(let c) = scheduled[index].entry.matter else { return }
        scheduled.remove(at: index)
        handOff(c)
    }

    private func handOff(_ c: CourtCase) {
        let date = today?.date ?? currentDate
        var rng = SeededRNG(seed: c.seed ^ 0xDE1E_6A7E)
        let other = "Judge " + rng.pick(NameBank.lastNames.filter { !(judgeName ?? "").hasSuffix($0) })
        stats.delegated = (stats.delegated ?? 0) + 1
        happened(.reassigned(caption: c.caption, defendant: c.defendant.name, toJudge: other))
        history.insert(CaseRecord(docket: c.docket, caption: c.caption, headline: c.headline, category: c.category, date: date,
                                  defendantID: c.defendant.personID, outcome: "Reassigned to \(other)",
                                  judgments: ["Reassigned to \(other) to relieve the court's calendar."],
                                  returningDefendant: c.defendant.isReturning, appealStatus: nil, kind: "reassigned"), at: 0)
        // The other judge hears it on the evidence; a strong case usually ends in a conviction, a weak one usually doesn't.
        let strength = Judgment.properStrength(c)
        let threshold = c.charges.first?.threshold ?? 5
        let proven = strength >= threshold
        let plea = proven && rng.chance(0.45)
        let convicted = plea || (proven ? rng.chance(0.85) : rng.chance(0.2))
        let offense = c.charges.first?.law.title.lowercased() ?? "the charges"
        let when = CourtCalendar.calendar.date(byAdding: .day, value: rng.int(14...60), to: date) ?? date
        let body: String
        let headline: String
        if plea {
            headline = "\(c.defendant.name) pleads guilty before \(other)"
            body = "\(c.defendant.name) pleaded guilty to \(offense) before \(other), who took the case when it was reassigned from Judge \(lastName(judgeName ?? ""))'s calendar."
        } else if convicted {
            headline = "\(other) convicts \(c.defendant.name) of \(offense)"
            body = "In a bench trial, \(other) found \(c.defendant.name) guilty of \(offense). The case was reassigned from Judge \(lastName(judgeName ?? ""))'s calendar to ease a heavy docket."
        } else {
            headline = "\(c.defendant.name) acquitted before \(other)"
            body = "\(other) found \(c.defendant.name) not guilty of \(offense), saying the State's evidence fell short. The case had been reassigned from Judge \(lastName(judgeName ?? ""))'s calendar."
        }
        pending.append(PendingEvent(due: when, news: NewsItem(date: when, kind: .verdict, headline: headline, body: body, docket: c.docket, prominence: 1),
                                    personID: c.defendant.personID))
        save()
    }

    // MARK: Schedule changes

    func setCourtDay(_ weekday: Int, sits: Bool) {
        if sits { schedule.courtDays.insert(weekday) } else { schedule.courtDays.remove(weekday) }
        reflow()
        happened(.scheduleChanged(weeklyTrials: schedule.weeklyTrials))
        save()
    }

    func setWeekdayLimit(_ weekday: Int, _ limit: DayLimit) {
        schedule.limits[weekday] = DayLimit(trials: max(0, min(4, limit.trials)), hearings: max(0, min(4, limit.hearings)))
        happened(.scheduleChanged(weeklyTrials: schedule.weeklyTrials))
        save()
    }

    /// A one-day change to what the court takes; nil goes back to the weekday's usual limit.
    func setDayLimit(_ date: Date, _ limit: DayLimit?) {
        let key = CourtSchedule.key(date)
        if let limit { schedule.overrides[key] = DayLimit(trials: max(0, min(4, limit.trials)), hearings: max(0, min(4, limit.hearings))) }
        else { schedule.overrides[key] = nil }
        save()
    }

    func applyTemplate(_ template: CourtSchedule.Template) {
        schedule.limits = template.limits
        lightWeeks = template == .light
        happened(.scheduleChanged(weeklyTrials: schedule.weeklyTrials))
        save()
    }

    func setLightWeeks(_ on: Bool) {
        applyTemplate(on ? .light : .standard)
    }

    /// Books days off. Anything set on them moves to the first day with room after the last day off.
    func bookTimeOff(from start: Date, to end: Date) {
        let cal = CourtCalendar.calendar
        let todayDate = cal.startOfDay(for: today?.date ?? currentDate)
        var day = max(cal.startOfDay(for: start), cal.date(byAdding: .day, value: 1, to: todayDate) ?? todayDate)
        let last = cal.startOfDay(for: end)
        guard day <= last else { return }
        while day <= last {
            schedule.timeOff.insert(CourtSchedule.key(day))
            day = cal.date(byAdding: .day, value: 1, to: day) ?? last
        }
        reflow(note: "Reset while the court is on leave")
        let booked = stride(from: 0, through: cal.dateComponents([.day], from: cal.startOfDay(for: start), to: last).day ?? 0, by: 1)
            .compactMap { cal.date(byAdding: .day, value: $0, to: cal.startOfDay(for: start)) }
            .filter { CourtCalendar.isCourtDay($0) && schedule.courtDays.contains(CourtSchedule.weekday($0)) }.count
        if booked > 0 { happened(.timeOffBooked(from: max(cal.startOfDay(for: start), todayDate), to: last, days: booked)) }
        save()
    }

    func cancelTimeOff(_ date: Date) {
        schedule.timeOff.remove(CourtSchedule.key(date))
        save()
    }

    /// Court days of leave left this year.
    var leaveLeft: Int {
        let year = CourtCalendar.calendar.component(.year, from: today?.date ?? currentDate)
        return schedule.leavePerYear - schedule.leaveUsed(in: year)
    }

    /// Moves anything set on a day the court no longer sits to the next day with room.
    private func reflow(note: String = "Moved: the court isn't sitting that day") {
        let moving = scheduled.filter { !schedule.sits(on: $0.date) }
        guard !moving.isEmpty else { return }
        scheduled.removeAll { !schedule.sits(on: $0.date) }
        for item in moving {
            var entry = item.entry
            entry.carriedOver = true
            entry.note = ((entry.note ?? "") + " \(note) (\(SentenceFormat.shortDate(item.date))).").trimmingCharacters(in: .whitespaces)
            place(entry, from: item.date)
        }
    }

    // MARK: New cases and the cost of waiting

    /// What comes in on a court day: new indictments when the docket has room, people this court judged before charged
    /// again, cases back from the Court of Appeals, and probation violations.
    private func intake(on date: Date, rng: inout SeededRNG) {
        let cal = CourtCalendar.calendar
        var used = peopleInPlay()
        // Cases back from the Court of Appeals wait for a new trial date.
        while !retrials.isEmpty {
            var retrial = retrials.removeFirst()
            retrial.id = UUID()
            creditVacatedTime(&retrial, through: date)
            retrial.sessionDate = date
            refreshDefendant(&retrial)
            if var bg = retrial.background, let person = person(retrial.defendant.personID) {
                bg.onRelease = person.status != .incarcerated
                retrial.background = bg
            }
            awaitCase(retrial, note: "Returned from the Court of Appeals for a new trial.", on: date)
            used.insert(retrial.defendant.personID)
        }
        // Now and then someone this court has judged is arrested on something new.
        let quiet = cal.date(byAdding: .day, value: -120, to: date) ?? date
        let candidates = people.filter { person in
            person.status != .incarcerated && person.propensity >= 0.25 && !used.contains(person.id)
                && (person.appearances.last?.date ?? .distantFuture) < quiet && person.age(on: date) < 75
                && (person.lastReleased ?? .distantPast) < (cal.date(byAdding: .day, value: -75, to: date) ?? date)
                && !reoffenseQueue.contains { $0.personID == person.id }
        }
        if rng.chance(0.04), !candidates.isEmpty {
            let person = rng.pick(candidates)
            if let prior = person.priors.last(where: { $0.fromThisCourt && $0.docket != nil && !($0.docket ?? "").hasSuffix("(PV)") }),
               let entered = person.appearances.last(where: { $0.docket == prior.docket }) {
                let incident = cal.date(byAdding: .day, value: -rng.int(30...70), to: date) ?? date
                stats.chargedAgainAfterRelease = (stats.chargedAgainAfterRelease ?? 0) + 1
                let fitting = FollowUpCases.newCharges.filter { FollowUpCases.fits($0, age: person.age(on: date)) }
                reoffenseQueue.append(Reoffense(personID: person.id, templateKeys: (fitting.isEmpty ? FollowUpCases.newCharges : fitting).shuffled(using: &rng),
                                                victimName: nil, incident: incident,
                                                note: "Back in your court: you sentenced \(person.name) for \(prior.offense.lowercasedPhrase) on \(SentenceFormat.shortDate(entered.date)).",
                                                priorOffense: prior.offense, priorDate: entered.date))
            }
        }
        // Cases that come back because of what this court decided.
        while let index = reoffenseQueue.firstIndex(where: { !used.contains($0.personID) }) {
            let followUp = reoffenseQueue.remove(at: index)
            guard let person = person(followUp.personID), person.status != .incarcerated else { continue }
            if let c = generateCase(date: date, rng: &rng, excluding: &used, storySlot: false, followUp: followUp) {
                awaitCase(c, note: followUp.note, on: date)
            }
        }
        // New indictments, when the court's docket has room for them.
        if trialsInPipeline < pipelineTarget && rng.chance(0.4 * max(0.35, caseloadRamp)) {
            let murderWaiting = (awaiting.map(\.entry) + scheduled.map(\.entry)).contains { entry in
                if case .trial(let c) = entry.matter { return Self.isMurder(c) } else { return false }
            }
            // Now and then someone the court knows from an earlier case (a witness, a victim) is the one charged.
            let knownPool = residents.filter { !$0.deceased && $0.occupation == nil }
            let knownDefendant = rng.chance(0.06) && !knownPool.isEmpty ? knownPool[rng.int(0...(knownPool.count - 1))] : nil
            // About half the time the paper follows the crime from the day it happens; the case comes at the arrest.
            if rng.chance(0.5) {
                // The case is built as of its first possible trial day, so every entry in its file falls before it.
                let ready = cal.date(byAdding: .day, value: rng.int(35...60), to: date) ?? date
                let incident = cal.date(byAdding: .day, value: -1, to: date) ?? date
                let daysAgo = (cal.dateComponents([.day], from: incident, to: ready).day ?? 30)
                if var c = generateCase(date: ready, rng: &rng, excluding: &used, storySlot: true, allowMurder: !murderWaiting,
                                        announce: false, incidentDaysAgo: daysAgo) {
                    if c.background?.arrangementPresented != true && rng.chance(0.25) {
                        c.continuanceMotion = ContinuanceMotions.make(for: c, rng: &rng)
                    }
                    let facts = c.investigation?.facts
                    let happened = facts.map { cal.startOfDay(for: $0.incident) } ?? .distantPast
                    let arrest = facts.map { cal.startOfDay(for: $0.arrest) } ?? .distantPast
                    if cal.isDate(happened, inSameDayAs: incident) && arrest > cal.startOfDay(for: date), let facts {
                        pending.append(contentsOf: InvestigationArc.beats(for: c, incident: happened, arrest: arrest, town: facts.town,
                                                                          agency: facts.agency, rng: &rng))
                        investigations.append(OpenInvestigation(courtCase: c, incident: happened, arrest: arrest, town: facts.town,
                                                                offense: InvestigationArc.subject(c), ready: ready))
                    } else {
                        // A dated story or an arrest at the scene: there was nothing for the paper to follow.
                        awaitCase(c, note: "Indicted by the grand jury on \(SentenceFormat.shortDate(date)).", on: date,
                                  earliest: ready, reason: "Discovery is still being exchanged")
                    }
                }
            } else if var c = generateCase(date: date, rng: &rng, excluding: &used, storySlot: true, allowMurder: !murderWaiting,
                                           residentDefendant: knownDefendant) {
                if c.background?.arrangementPresented != true && rng.chance(0.25) {
                    c.continuanceMotion = ContinuanceMotions.make(for: c, rng: &rng)
                }
                let ready = cal.date(byAdding: .day, value: rng.int(7...21), to: date)
                awaitCase(c, note: "Indicted by the grand jury on \(SentenceFormat.shortDate(date)).", on: date,
                          earliest: ready, reason: "Discovery is still being exchanged")
            }
        }
        // Now and then the DA's office asks that a waiting case be set first.
        if rng.chance(0.08), let index = awaiting.indices.filter({ awaiting[$0].priorityRequested == nil && awaiting[$0].courtCase != nil }).randomElement(using: &rng),
           let c = awaiting[index].courtCase {
            var reasons = ["a witness is about to deploy with the National Guard", "the State's key witness is moving out of state",
                           "the investigating officer is retiring"]
            if c.victimName != nil { reasons += ["the victim's family is asking every week", "the victim is elderly and in poor health"] }
            if c.background?.isJailed == true { reasons.append("the defendant has been held a long time and the office wants it tried") }
            awaiting[index].priorityRequested = date
            awaiting[index].priorityReason = rng.pick(reasons)
        }
        // Probation violations are short matters: each goes on the next day with room for a hearing.
        if rng.chance(lightWeeks ? 0.15 : 0.3), let hearing = makeViolationHearing(date: date, excluding: &used, rng: &rng) {
            place(DocketEntry(matter: .hearing(hearing)), from: nextSittingDay(after: date))
        }
        if !lightWeeks, rng.chance(0.08), let hearing = makeOutsideHearing(date: date, rng: &rng) {
            place(DocketEntry(matter: .hearing(hearing)), from: nextSittingDay(after: date))
        }
    }

    /// Cases left waiting cost something: jail time runs, defense lawyers file, the paper notices, and a victim the
    /// court hasn't protected can be hurt again. Each cost lands once.
    private func reviewWaiting(on date: Date, rng: inout SeededRNG) {
        let cal = CourtCalendar.calendar
        let judge = lastName(judgeName ?? "")
        for index in awaiting.indices {
            guard let c = awaiting[index].courtCase else { continue }
            let waited = cal.dateComponents([.day], from: awaiting[index].since, to: date).day ?? 0
            let jailed = c.background?.isJailed ?? false
            let held = jailed ? (c.background?.custodyDays ?? 0) + max(0, cal.dateComponents([.day], from: cal.startOfDay(for: c.sessionDate), to: date).day ?? 0) : 0
            func once(_ key: String, _ action: () -> Void) {
                guard !awaiting[index].warnings.contains(key) else { return }
                awaiting[index].warnings.append(key)
                action()
            }
            if jailed && held >= 120 {
                once("jail120") {
                    stats.delayedCases = (stats.delayedCases ?? 0) + 1
                    post(NewsItem(date: date, kind: .community, headline: "\(c.defendant.name) held \(held) days with no trial date",
                                  body: "\(c.defendant.name) has been in the Hollis County jail for \(held) days on \(c.charges.first?.law.title.lowercased() ?? "the charges") and still has no trial date before Judge \(judge). Defense lawyers say the wait is becoming a constitutional problem.",
                                  docket: c.docket, prominence: 1))
                }
            }
            if jailed && held >= 240 {
                once("jail240") {
                    let note = "The defense has moved to dismiss for violation of the right to a speedy trial: \(c.defendant.lastName) has been held \(held) days awaiting trial (Barker v. Wingo; N.C. Const. art. I, § 18)."
                    awaiting[index].entry.note = ((awaiting[index].entry.note ?? "") + " " + note).trimmingCharacters(in: .whitespaces)
                    if case .trial(var tc) = awaiting[index].entry.matter {
                        tc.proceduralNotes.append(note)
                        awaiting[index].entry.matter = .trial(tc)
                    }
                    post(NewsItem(date: date, kind: .community, headline: "Lawyers for \(c.defendant.name) seek dismissal over delay",
                                  body: "After \(held) days in jail without a trial, \(c.defendant.name)'s lawyers asked Judge \(judge) to dismiss the charges for violation of the right to a speedy trial.",
                                  docket: c.docket, prominence: 2))
                }
            }
            if !jailed && Consequences.stateWantsOrder(c) && waited >= 21, let victim = c.victimName,
               !awaiting[index].warnings.contains("incident"), rng.chance(0.03) {
                once("incident") {
                    let note = "New incident reported while the case waited for a trial date: \(victim) told deputies \(c.defendant.lastName) came to \(victim)'s home again."
                    awaiting[index].entry.note = ((awaiting[index].entry.note ?? "") + " " + note).trimmingCharacters(in: .whitespaces)
                    stats.delayedCases = (stats.delayedCases ?? 0) + 1
                    post(NewsItem(date: date, kind: .arrest, headline: "\(victim) reports new contact from \(c.defendant.name) as case waits",
                                  body: "\(victim) told deputies that \(c.defendant.name), who is free while charges are pending in Hollis County Superior Court, came to \(victim)'s home this week. The case has waited \(waited) days for a trial date before Judge \(judge).",
                                  docket: c.docket, prominence: 2))
                }
            }
            if let asked = awaiting[index].priorityRequested, (cal.dateComponents([.day], from: asked, to: date).day ?? 0) >= 30 {
                once("priorityIgnored") {
                    mood.adjust(prosecutors: -3, defenders: 0)
                    CourthouseMood.current = mood
                    CalendarCalls.prosecutorEdge = mood.prosecutorEdge
                    awaiting[index].entry.note = ((awaiting[index].entry.note ?? "") + " The DA's office has complained that its request for a priority setting was ignored.").trimmingCharacters(in: .whitespaces)
                }
            }
            if waited >= 180 {
                once("halfYear") {
                    stats.delayedCases = (stats.delayedCases ?? 0) + 1
                    post(NewsItem(date: date, kind: .community, headline: "Six months on, no trial date in \(c.caption)",
                                  body: "The case against \(c.defendant.name) has waited \(waited) days for a trial date in Hollis County Superior Court." + (c.victimName.map { " \($0)'s family says the wait has been hard." } ?? ""),
                                  docket: c.docket, prominence: 1))
                }
            }
        }
    }

    /// The day-by-day loop for matters that are waiting (for a date, or on a later day's calendar): a jailed defendant
    /// gets that day's credit, and every file reads as of today, so nothing the judge opens is stale.
    private func creditWaitingJailTime(through date: Date) {
        let day = CourtCalendar.calendar.startOfDay(for: date)
        func credit(_ entry: inout DocketEntry) {
            switch entry.matter {
            case .trial(var c):
                // Jail credit for the day, then the case file moves to today: age, record, custody count.
                creditJailTime(&c, through: day)
                c.sessionDate = max(c.sessionDate, day)
                refreshDefendant(&c)
                entry.matter = .trial(c)
            case .hearing(var h):
                if let person = person(h.personID) { h.personAge = person.age(on: day) }
                entry.matter = .hearing(h)
            case .calendar:
                break
            }
        }
        for i in awaiting.indices { credit(&awaiting[i].entry) }
        for i in scheduled.indices { credit(&scheduled[i].entry) }
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
        let judged = person.appearances.last(where: { $0.docket == c.docket })?.date
        let wasActive = heldThroughRetrial
            || history.contains { $0.docket == c.docket && $0.resolvedKind == "trial" && $0.judgments.contains { $0.contains("active") || $0.contains("Life") } }
        guard wasActive else { return }
        // Held from the judgment until the actual release on it, or the appeal decision, whichever came first.
        let start = judged ?? c.sessionDate
        let decided = appeals.last(where: { $0.docket == c.docket })?.decided
        var end = heldThroughRetrial ? date : min(date, decided ?? date)
        if !heldThroughRetrial, let out = person.lastReleased, out > start { end = min(end, out) }
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
    private func scheduleCalendarCases(_ call: CalendarCall, choices: [UUID: Int], amounts: [UUID: Int], dates: [UUID: Date] = [:]) {
        var rng = SeededRNG(seed: seedBase ^ SeededRNG.stableHash(call.id.uuidString))
        let heard = SentenceFormat.shortDate(call.date)
        func later(weeks: Int) -> Date {
            // The first day court sits that week: Tuesday when Monday is a holiday.
            CourtCalendar.weekday(onOrAfter: CourtCalendar.monday(onOrAfter: CourtCalendar.calendar.date(byAdding: .day, value: 7 * weeks, to: call.date) ?? call.date))
        }
        func schedule(_ c: CourtCase, _ weeks: Int, _ note: String, _ continuances: Int) {
            setFor(c, weeks: weeks, note: note, continuances: continuances)
        }
        /// Set for trial: the case joins the list waiting for the judge to give it a date, ready from the week given.
        func setFor(_ c: CourtCase, weeks: Int, note: String, continuances: Int = 0) {
            let ready = later(weeks: weeks)
            awaitCase(c, note: note, on: call.date, earliest: ready,
                      reason: weeks <= 2 ? "The parties need time to prepare" : "Discovery is still being exchanged",
                      continuances: continuances)
        }
        /// To be tried now: today, if the day has room under the judge's limits, or the next day that does.
        func thisWeek(_ c: CourtCase, note: String, continuances: Int = 0) {
            var entry = DocketEntry(matter: .trial(c), note: note)
            entry.continuances = continuances
            if var day = today, hasRoom(on: day.date, for: entry) {
                var c = c
                c.sessionDate = day.date
                entry.matter = .trial(c)
                day.entries.append(entry)
                today = day
            } else {
                entry.note = note.replacingOccurrences(of: "tried this week", with: "set for the next day with room")
                place(entry, from: nextCourtDate)
            }
        }
        for m in call.matters {
            guard let c = m.pendingCase else { continue }
            let choice = choices[m.id] ?? 0
            // A case already set for trial, or waiting for a date, is taken off its old setting; the ruling sets the new one.
            scheduled.removeAll { item in if case .trial(let t) = item.entry.matter { return t.id == c.id } else { return false } }
            awaiting.removeAll { $0.courtCase?.id == c.id }
            switch m.kind {
            case .quickPlea where choice == 3:
                // Only written cases are tried before you; a rejected calendar-call plea goes to another session.
                if c.templateKey.hasPrefix("story.") {
                    setFor(c, weeks: 2, note: "Plea rejected at the calendar call on \(heard); set for trial.")
                }
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
                        bg.custodyDays = max(1, bg.custodyDays)
                        bg.bondStatus = "Arrested on the order for arrest after failing to appear; bond doubled and held for \(bg.custodyDays) days."
                        held.background = bg
                    }
                    // Jail credit runs from the arrest, not from the missed court date.
                    held.sessionDate = arrested
                    setFor(held, weeks: weeksOut, note: "Arrested on the order for arrest issued at the calendar call on \(heard).")
                    issueArrestOrder(for: c, issued: call.date, servedOn: arrested)
                case 1:
                    if rng.chance(0.6) {
                        thisWeek(c, note: "Appeared at the afternoon session after missing the morning call; tried this week.")
                    } else {
                        var held = c
                        if var bg = held.background {
                            bg.onRelease = false
                            bg.custodyDays = max(1, bg.custodyDays)
                            bg.bondStatus = "Never appeared on \(heard); arrested on the order for arrest and held for \(bg.custodyDays) days."
                            held.background = bg
                        }
                        let weeksOut = rng.int(2...5)
                        // Jail credit runs from the arrest, not from the missed court date.
                        held.sessionDate = CourtCalendar.calendar.date(byAdding: .day, value: 7 * weeksOut - rng.int(3...10), to: call.date) ?? call.date
                        setFor(held, weeks: weeksOut, note: "Never appeared on \(heard); arrested on an order for arrest issued after the calendar call.")
                        issueArrestOrder(for: c, issued: call.date, servedOn: held.sessionDate)
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
                if choice == 0, let picked = dates[m.id] {
                    // The judge picks the day. Too soon, and the defense asks for more time.
                    var setCase = c
                    let days = CourtCalendar.calendar.dateComponents([.day], from: call.date, to: picked).day ?? 35
                    if days < 21 && c.charges.count > 1 && rng.chance(0.6) {
                        setCase.continuanceMotion = ContinuanceMotions.make(for: setCase, rng: &rng)
                    }
                    awaitCase(setCase, note: "Arraigned on \(heard); pleaded not guilty.", on: call.date)
                    if let id = awaiting.last?.id { setTrialDate(id, to: picked) }
                } else {
                    setFor(c, weeks: 2, note: "Arraigned on \(heard); pleaded not guilty. Trial date to be set.")
                }
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
                        arrestOnWarrant(rebuilt, note: "You denied the first warrant application on \(heard); detectives added surveillance and another judge signed a second one.", rng: &rng)
                    } else if w.probableCause {
                        post(NewsItem(date: call.date, kind: .community, headline: "Investigation stalls after warrant denied",
                                      body: "Detectives with the \(w.agency) say an investigation in \(w.place.components(separatedBy: ",").dropFirst().first?.trimmingCharacters(in: .whitespaces) ?? "the county") has stalled after Judge \(judge) declined to sign a search warrant.",
                                      prominence: 1))
                    }
                    continue
                }
                let executed = SearchWarrants.executed(w, on: c, limited: choice == 1, signedBy: judge)
                arrestOnWarrant(executed, note: "Arrested when the search warrant you signed on \(heard) was executed.", rng: &rng)
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

    /// Motions for a new trial on a docket whose conviction is already gone: still to be filed, or waiting to be heard.
    private func dropRelief(for docket: String) {
        pending.removeAll { $0.reliefMotion?.docket == docket }
        reliefQueue.removeAll { $0.docket == docket }
    }

    /// A conviction vacated for a new trial: it comes off the record, and the person is released if held on it.
    private func vacateForNewTrial(_ relief: ReliefMotion, on date: Date, rng: inout SeededRNG) {
        pending.removeAll { $0.vacatesDocket == relief.docket && $0.news.kind == .exoneration }
        // The appeal's own new trial, if one is coming, would try the case twice.
        pending.removeAll { $0.news.docket == relief.docket && $0.retrial != nil }
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
        people[index].stayAwayOrders?.removeAll { $0.docket == relief.docket }
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
                bg.custodyDays = max(1, bg.custodyDays)
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
                bg.custodyDays = max(1, bg.custodyDays)
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

    func completeCalendar(_ call: CalendarCall, choices: [UUID: Int], amounts: [UUID: Int] = [:], dates: [UUID: Date] = [:]) {
        guard let county, let judgeName, stillOpen(call.id) else { return }
        let result = CalendarCalls.resolve(call, choices: choices, amounts: amounts, judgeName: judgeName, county: county)
        happened(.calendarCall(matters: call.matters.count))
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
        scheduleCalendarCases(call, choices: choices, amounts: amounts, dates: dates)
        stats.activeSentences += result.activeSentences
        stats.suspendedSentences += result.suspendedSentences
        stats.probationCompleted += result.probationCompleted
        // Where each case went: tried this week, or set for a later date.
        var placed: [String] = []
        for m in call.matters where m.pendingCase != nil {
            if m.kind == .quickPlea, choices[m.id] == 3, m.pendingCase?.templateKey.hasPrefix("story.") != true {
                placed.append("\(m.personName): plea rejected; set for trial before another judge in a later session.")
            } else if let entry = today?.entries.first(where: { if case .trial(let c) = $0.matter { return c.defendant.personID == m.personID } else { return false } }), entry.isOpen {
                placed.append("\(m.personName): on today's docket.")
            } else if let set = scheduled.first(where: { if case .trial(let c) = $0.entry.matter { return c.defendant.personID == m.personID } else { return false } }) {
                placed.append("\(m.personName): set for trial on \(SentenceFormat.shortDate(set.date)).")
            } else if let wait = awaiting.first(where: { $0.courtCase?.defendant.personID == m.personID }) {
                placed.append("\(m.personName): waiting for you to set a trial date" + (wait.earliest.map { "; ready from \(SentenceFormat.shortDate($0))" } ?? "") + ".")
            }
        }
        lastCalendarResults = result.lines + (placed.isEmpty ? [] : ["Where the cases went:"] + placed)
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
        happened(.hearingHeld(name: hearing.personName, revoked: outcome.status == .incarcerated))
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
                              followUp: Reoffense? = nil, generic: Bool = false, incidentDaysAgo: Int? = nil,
                              arrestOn: Date? = nil, residentDefendant: Resident? = nil) -> CourtCase? {
        guard let county, let judgeName else { return nil }
        // A written case brings its own defendant; returning defendants come back through calendar matters and follow-ups.
        var returning = followUp.flatMap { person($0.personID) } ?? (storySlot && followUp == nil ? nil : pickReturningDefendant(rng: &rng, date: date))
        if followUp == nil, let person = returning, used.contains(person.id) { returning = nil }
        var context = CaseGenerator.Context(county: county, judgeName: judgeName, date: date,
                                            docketSequence: docketSequence, recentTemplateKeys: recentTemplates,
                                            usedSignatures: Set(usedSignatures), returning: returning,
                                            usedBackgrounds: Set(people.map(\.background)), storySlot: followUp == nil && storySlot,
                                            categories: categories, allowMurder: allowMurder)
        context.generic = generic
        context.incidentDaysAgo = incidentDaysAgo
        context.arrestOn = arrestOn
        context.residentDefendant = residentDefendant.map { ResidentRef(name: $0.name, town: $0.town, occupation: $0.occupation, lastCaption: nil) }
        context.residents = residents.filter { !$0.deceased }.map { r in
            ResidentRef(name: r.name, town: r.town, occupation: r.occupation,
                        lastCaption: r.roles.last(where: { $0.part != "Victim" })?.caption)
        }
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

    func complete(_ courtCase: CourtCase, outcome: CaseOutcome, perjuryReferrals: [Witness] = []) {
        guard stillOpen(courtCase.id) else { return }
        // Testimony the judge sent to the district attorney: the DA's decision, and what comes of it, arrive later.
        if !perjuryReferrals.isEmpty, let judgeName {
            for witness in perjuryReferrals {
                happened(.perjuryReferral(name: witness.name))
                pending += Perjury.events(for: witness, in: courtCase, convicted: outcome.convicted,
                                          judgeLast: lastName(judgeName), date: currentDate)
            }
        }
        for i in arrestOrders.indices where arrestOrders[i].docket == courtCase.docket {
            arrestOrders[i].served = true
            arrestOrders[i].resolved = true
        }
        let d = courtCase.defendant
        let judgmentText = outcome.judgments.map { ([$0.title] + $0.lines).joined(separator: " · ") }
            + [outcome.habitualNote, outcome.probationHearing].compactMap { $0 }
            + [outcome.stayAwayOrder.map { $0.fromProbation == true
                ? "Condition of probation: no contact with \($0.protectedName) or their family until \(SentenceFormat.shortDate($0.expires))."
                : "Stay-away order: no contact with \($0.protectedName), and stay away from their home, work, and school, until \(SentenceFormat.shortDate($0.expires))." }].compactMap { $0 }
        // A retrial of the same case doesn't make the defendant a returning one.
        let retried = history.contains { $0.docket == courtCase.docket && $0.resolvedKind == "trial" }
        if retried {
            // What was coming from the first judgment, a later exoneration or a motion for a new trial, ends with this one.
            pending.removeAll { $0.news.docket == courtCase.docket && ($0.news.kind == .exoneration || $0.reliefMotion != nil) }
            reliefQueue.removeAll { $0.docket == courtCase.docket }
        }

        history.insert(CaseRecord(docket: courtCase.docket, caption: courtCase.caption, headline: courtCase.headline,
                                  category: courtCase.category, date: currentDate, defendantID: d.personID,
                                  outcome: outcome.appearanceSummary, judgments: judgmentText,
                                  returningDefendant: d.isReturning && !retried,
                                  appealStatus: outcome.appealNotice == nil && !outcome.pending.contains(where: { $0.news.kind == .appeal && $0.news.docket == courtCase.docket }) ? nil : "Appeal pending",
                                  kind: "trial"), at: 0)
        rememberParticipants(courtCase)
        // The place it happened remembers it; a place that keeps coming up makes the paper.
        if let scene = courtCase.investigation?.facts?.place,
           let place = Gazetteer.places.sorted(by: { $0.name.count > $1.name.count }).first(where: { scene.contains($0.name) }) {
            var dockets = placeHistory[place.name] ?? []
            if !dockets.contains(courtCase.docket) { dockets.append(courtCase.docket) }
            placeHistory[place.name] = dockets
            if dockets.count >= 2, let judgeName {
                let ordinals = ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth"]
                let nth = dockets.count < ordinals.count ? ordinals[dockets.count] : "\(dockets.count)th"
                post(NewsItem(date: currentDate, kind: .community,
                              headline: "Another case out of \(place.name)",
                              body: "\(courtCase.caption) is the \(nth) case from \(place.described) to reach Judge \(lastName(judgeName))'s courtroom. "
                                + (place.kind == .bar || place.kind == .club ? "Neighbors on \(place.street) say the late nights there have gotten worse." : "Regulars say they're tired of seeing it in the paper."),
                              docket: courtCase.docket, prominence: 0, section: "Local"))
            }
        }
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
            let nameBefore = mood.name
            defer {
                happened(.verdictEntered(trialsHeard: trialsHeard, convicted: outcome.convicted))
                if mood.name != nameBefore { happened(.reputation(mood.name)) }
            }
            if outcome.convicted { weekTally.convictions += 1 } else { weekTally.withoutConviction += 1 }
            if activeImposed { weekTally.active += 1 }
            // The lawyers remember: acquittals and light sentences sit badly with the State, prison terms with the defense.
            if !outcome.convicted { mood.adjust(prosecutors: outcome.dismissed ? -4 : -3, defenders: 2) }
            else if activeImposed { mood.adjust(prosecutors: 2, defenders: -2) }
            else { mood.adjust(prosecutors: -1, defenders: 1) }
            switch outcome.sentencePosition {
            case .above?: mood.adjust(prosecutors: 1, defenders: -2)
            case .below?: mood.adjust(prosecutors: -2, defenders: 1)
            default: break
            }
            // Both sides respect a judge whose rulings hold up.
            let unsound = outcome.rulingNotes.filter { !$0.sound }.count
            if unsound == 0 && !outcome.rulingNotes.isEmpty { mood.adjust(prosecutors: 1, defenders: 1) }
            else if unsound >= 2 { mood.adjust(prosecutors: -1, defenders: -1) }
            CalendarCalls.prosecutorEdge = mood.prosecutorEdge
            CourthouseMood.current = mood
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
        arrestOrders = []
        freshAppeals = []
        schedule = CourtSchedule()
        awaiting = []
        weekTally = CourtDay.Tally()
        mood = CourthouseMood()
        investigations = []
        placeHistory = [:]
        residents = []
        CalendarCalls.prosecutorEdge = 0
        CourthouseMood.current = mood
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
    private func advanceWorld(to date: Date, weekly: Bool = true) {
        var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(date.timeIntervalSince1970)) / 86_400))
        currentDate = date

        // Orders for arrest served since the last court day.
        for i in arrestOrders.indices where !arrestOrders[i].served && arrestOrders[i].servedOn <= date {
            arrestOrders[i].served = true
            let order = arrestOrders[i]
            post(NewsItem(date: order.servedOn, kind: .arrest,
                          headline: "\(order.personName) arrested on order for failing to appear",
                          body: "Deputies served an order for arrest on \(order.personName), who missed a trial date in Hollis County Superior Court on a charge of \(order.offense.lowercasedPhrase). \(order.personName.components(separatedBy: " ").last ?? order.personName) is held on \(order.bond) until trial.",
                          docket: order.docket, prominence: 1))
        }

        // Scheduled events
        let due = pending.filter { $0.due <= currentDate }.sorted { $0.due < $1.due }
        pending.removeAll { $0.due <= currentDate }
        for event in due {
            // Nobody is arrested for something new while locked up: news of a new arrest, and the case it would bring,
            // fall away for a person in custody when the day comes.
            if event.effect == .none, event.reoffense != nil || event.news.kind == .arrest,
               let personID = event.personID, person(personID)?.status == .incarcerated {
                // The indictment that would follow an arrest that never happened goes too.
                if event.reoffense == nil {
                    pending.removeAll { $0.personID == personID && $0.reoffense.map { CourtCalendar.isSameDay($0.incident, event.due) } == true }
                }
                continue
            }
            var item = event.news
            item.date = event.due
            post(item)
            if let retrial = event.retrial { retrials.append(retrial) }
            // A conviction set aside takes its stay-away order and any pending motion for a new trial with it.
            let setAside = event.retrial != nil || item.kind == .exoneration || (event.effect == .releasePerson && event.vacatesDocket != nil)
                || (event.appealReversed && (event.effect == .releasePerson || item.headline.contains("new trial")))
            if setAside, let docket = event.vacatesDocket ?? item.docket {
                dropRelief(for: docket)
                if let personID = event.personID, let index = people.firstIndex(where: { $0.id == personID }) {
                    people[index].stayAwayOrders?.removeAll { $0.docket == docket }
                }
            }
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
                        // What the vacated revocation added goes with it: a judgment entered on a conditional discharge,
                        // and supervision that would follow the activated term.
                        if restore.conditionalDischarge == true {
                            people[index].priors.removeAll { $0.docket == restore.docket && $0.sentence.contains("after a conditional discharge was revoked") }
                        }
                        if people[index].pendingPostRelease?.docket == restore.docket { people[index].pendingPostRelease = nil }
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

        // Stay-away orders are tested a week at a time.
        if weekly { checkStayAwayOrders(rng: &rng) }

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
            // Someone already facing a new case isn't arrested on another violation before it's heard.
            let personID = people[index].id
            if reoffenseQueue.contains(where: { $0.personID == personID }) || pending.contains(where: { $0.reoffense?.personID == personID }) { continue }
            for o in orders.indices where orders[o].issued < currentDate && orders[o].expires > currentDate {
                let risk = (orders[o].domestic ? 0.025 : 0.02) * (0.5 + people[index].propensity * 2.5)
                guard rng.chance(min(0.08, risk)) else { continue }
                orders[o].violations += 1
                stats.orderViolations = (stats.orderViolations ?? 0) + 1
                let person = people[index], order = orders[o]
                // The case comes first, so the news describes the same violation the trial will be about.
                let kinds = Consequences.violationTemplates(domestic: order.domestic)
                let fitting = kinds.filter { FollowUpCases.fits($0, age: person.age(on: currentDate)) }
                let key = rng.pick(fitting.isEmpty ? kinds : fitting)
                let what: String
                var incident = currentDate
                switch key {
                case "story.followup.workplaceVisit": what = "showed up at \(order.protectedName)'s workplace and followed \(order.protectedName) to the parking lot"
                case "story.followup.newNumber": what = "sent \(order.protectedName) dozens of messages from a new number"
                case "story.followup.parkingLotWatch": what = "was found parked outside \(order.protectedName)'s home night after night"
                default:
                    what = "left notes on \(order.protectedName)'s car and slashed a tire"
                    incident = CourtCalendar.calendar.date(byAdding: .day, value: -20, to: currentDate) ?? currentDate
                }
                post(NewsItem(date: currentDate, kind: .arrest,
                              headline: "\(person.name) arrested for violating court order protecting \(order.protectedName)",
                              body: "Deputies say \(person.name) \(what), in violation of the \(order.label) Judge \(lastName(judgeName)) imposed in \(order.docket) on \(SentenceFormat.shortDate(order.issued)). \(person.lastName) is being held pending a first appearance.",
                              docket: order.docket, prominence: 2))
                let toCourt = CourtCalendar.calendar.date(byAdding: .day, value: 7 * rng.int(3...6), to: currentDate) ?? currentDate
                pending.append(PendingEvent(due: toCourt,
                                            news: NewsItem(date: toCourt, kind: .arrest, headline: "\(person.name) to face Judge \(lastName(judgeName)) again",
                                                           body: "The new charges against \(person.name), arising from the alleged violation of a \(order.label) protecting \(order.protectedName), are set for trial before the judge who entered the order.",
                                                           docket: order.docket),
                                            personID: person.id,
                                            reoffense: Reoffense(personID: person.id, templateKeys: [key],
                                                                 victimName: order.protectedName, incident: incident,
                                                                 note: "Charged with violating the \(order.label) you imposed on \(SentenceFormat.shortDate(order.issued)) in \(order.docket), protecting \(order.protectedName). It was \(person.lastName)'s violation number \(order.violations).",
                                                                 priorOffense: order.offense ?? person.priors.first { $0.docket == order.docket }?.offense, priorDate: order.issued)))
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
        // A revocation also carries the "(PV)" docket but activates the sentence, so the note decides.
        let lowerNote = note.lowercased()
        // A revocation's credit for earlier CRV time mentions the phrase too, so only the order itself counts.
        let sanction = lowerNote.contains("quick dip") || lowerNote.hasPrefix("confinement in response to violation")
            || lowerNote.contains("period of confinement in response to violation")
        let jail = sanction || note.contains(" days active") || (note.contains(" days") && !note.contains("months"))
        people[index].releaseDate = nil
        people[index].releaseNote = nil
        people[index].custodyDocket = nil
        people[index].lastReleased = release
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
        // The paper reads newest first, whatever order the stories were filed in.
        let index = news.firstIndex { $0.date <= item.date } ?? news.count
        news.insert(item, at: index)
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
                            freshAppeals: freshAppeals, arrestOrders: arrestOrders, schedule: schedule, awaiting: awaiting,
                            weekTally: weekTally, mood: mood, investigations: investigations, placeHistory: placeHistory, residents: residents)
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
        // Older saves announced new ADAs without adding them to the roster; add the ones the paper reported.
        if var roster = county {
            for item in news.reversed() where item.headline == "New assistant district attorney sworn in" {
                if let name = item.body.components(separatedBy: ", a graduate").first, !name.isEmpty, !roster.assistantDAs.contains(name) {
                    roster.assistantDAs.append(name)
                    if roster.assistantDAs.count > 6 { roster.assistantDAs.removeFirst() }
                }
            }
            county = roster
        }
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
        arrestOrders = data.arrestOrders ?? []
        freshAppeals = data.freshAppeals ?? []
        schedule = data.schedule ?? CourtSchedule()
        awaiting = data.awaiting ?? []
        weekTally = data.weekTally ?? CourtDay.Tally()
        mood = data.mood ?? CourthouseMood()
        investigations = data.investigations ?? []
        placeHistory = data.placeHistory ?? [:]
        residents = data.residents ?? []
        CalendarCalls.prosecutorEdge = mood.prosecutorEdge
        CourthouseMood.current = mood
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

// MARK: - Court calendar planner

/// One matter on the court calendar, with where it is projected to fall.
struct PlannedMatter: Identifiable {
    enum Kind { case calendarCall, trial, hearing }
    enum Source {
        /// On today's docket.
        case today(entryID: UUID, matterID: UUID)
        /// Set for a later day.
        case scheduled(UUID)
        /// Not yet on the calendar, but every court week has one.
        case expected
    }

    let id: String
    let kind: Kind
    let source: Source
    let title: String
    let subtitle: String
    let minutes: Int
    var notes: [String]
    var courtCase: CourtCase?
    var done = false
    var outcome: String?
    /// Set past the day's limit.
    var carriesOver = false
    var start: Date?
    var day: Date?

    var canContinue: Bool {
        guard kind != .calendarCall, !done else { return false }
        if case .expected = source { return false }
        return true
    }
}

/// Something else on the calendar: a holiday, an appeal, a release, an election.
struct CalendarEvent: Identifiable {
    enum Kind { case holiday, appeal, release, probation, election, year }
    let id = UUID()
    let date: Date
    let kind: Kind
    let title: String
    let detail: String

    var icon: String {
        switch kind {
        case .holiday: return "flag.fill"
        case .appeal: return "building.columns"
        case .release: return "door.left.hand.open"
        case .probation: return "checkmark.seal"
        case .election: return "checkmark.rectangle.stack.fill"
        case .year: return "chart.bar.doc.horizontal"
        }
    }
}

/// A court week as it stands now: what is set for each day, and how full each day is against the judge's limits.
struct WeekPlan: Identifiable {
    var id: Date { monday }
    let monday: Date
    /// The days the judge sits this week.
    let courtDays: [Date]
    let holidays: [(Date, String)]
    let isCurrent: Bool
    /// The trials the week takes under the judge's limits.
    let cap: Int
    var matters: [PlannedMatter]
    /// Trial seats still open on the days ahead, for cases waiting for a date.
    var openSeats: Int
    var minutesByDay: [Date: Int]
    /// Courtroom minutes in a day, from opening to the last call at 4:30.
    let dayCapacity: Int
    /// Each day's limit.
    let limits: [Date: DayLimit]
    /// Days the judge booked off.
    let daysOff: [Date]

    var trialsSet: Int { matters.filter { $0.kind == .trial && !$0.carriesOver }.count }
    /// Matters set past a day's limit.
    var carryingOver: Int { matters.filter(\.carriesOver).count }
    var plannedMinutes: Int { minutesByDay.values.reduce(0, +) }
    var capacity: Int { dayCapacity * max(1, courtDays.count) }

    func matters(on day: Date) -> [PlannedMatter] {
        matters.filter { $0.day.map { CourtCalendar.isSameDay($0, day) } ?? false }
    }

    func load(on day: Date) -> Double {
        Double(minutesByDay[CourtCalendar.calendar.startOfDay(for: day)] ?? 0) / Double(max(1, dayCapacity))
    }

    func limit(on day: Date) -> DayLimit { limits[CourtCalendar.calendar.startOfDay(for: day)] ?? .closed }

    func isOff(_ day: Date) -> Bool { daysOff.contains { CourtCalendar.isSameDay($0, day) } }
}

extension GameState {

    /// Courtroom minutes from opening to the last call at 4:30.
    var courtMinutesPerDay: Int { max(60, 16 * 60 + 30 - openingMinutes) }

    /// This week and the weeks after it, as the calendar stands now.
    func weekPlans(count: Int = 12) -> [WeekPlan] {
        guard let day = today else { return [] }
        let cal = CourtCalendar.calendar
        let first = CourtCalendar.monday(onOrBefore: day.date)
        return (0..<count).compactMap { offset in
            guard let monday = cal.date(byAdding: .day, value: 7 * offset, to: first) else { return nil }
            return weekPlan(monday: monday, today: day)
        }
    }

    private func planned(_ entry: DocketEntry, source: PlannedMatter.Source) -> PlannedMatter {
        var notes: [String] = []
        var courtCase: CourtCase?
        let kind: PlannedMatter.Kind
        switch entry.matter {
        case .trial(let c):
            kind = .trial
            courtCase = c
            if let bg = c.background, bg.isJailed { notes.append("Defendant held in jail \(bg.custodyDays) days awaiting trial") }
            if Self.isMurder(c) { notes.append("Murder trial") }
            if c.background?.arrangementPresented == true { notes.append("A plea arrangement is expected; a shorter hearing") }
            if c.continuanceMotion != nil { notes.append("A party will move to continue when it is called") }
            if c.defendant.isReturning { notes.append("You've seen this defendant before") }
            if let victim = c.victimName { notes.append("Victim: \(victim)") }
        case .hearing(let h):
            kind = .hearing
            notes.append("\(h.personName), on probation for \(h.probation.offense.lowercasedPhrase)")
        case .calendar(let call):
            kind = .calendarCall
            let pleas = call.matters.filter { $0.kind == .quickPlea }.count
            notes.append("\(call.matters.count) short matters" + (pleas > 0 ? ", \(pleas) with a plea" : ""))
        }
        if entry.continuances > 0 { notes.append("Continued \(entry.continuances == 1 ? "once" : "\(entry.continuances) times")") }
        if entry.carriedOver == true { notes.append("Moved from a full or closed day") }
        if let requests = entry.requests, !requests.isEmpty {
            notes.append("Follow-up evidence ordered: \(requests.count) request\(requests.count == 1 ? "" : "s")")
        }
        if entry.resume != nil { notes.append("Picks up where it left off") }
        let id: String
        switch source {
        case .today(let entryID, _): id = entryID.uuidString
        case .scheduled(let sid): id = sid.uuidString
        case .expected: id = UUID().uuidString
        }
        return PlannedMatter(id: id, kind: kind, source: source, title: entry.title, subtitle: entry.subtitle,
                             minutes: entry.estimatedMinutes, notes: notes, courtCase: courtCase,
                             done: !entry.isOpen, outcome: entry.isOpen ? nil : entry.outcome)
    }

    /// One day's matters in the order they're heard, with projected start times. Anything past the day's limits is marked.
    private func lay(_ matters: inout [PlannedMatter], on day: Date, from start: Date, limit: DayLimit) -> Int {
        let cal = CourtCalendar.calendar
        var clock = start
        var minutes = 0
        var trials = 0, hearings = 0
        for index in matters.indices where !matters[index].done {
            matters[index].day = cal.startOfDay(for: day)
            switch matters[index].kind {
            case .trial:
                trials += 1
                if trials > limit.trials {
                    matters[index].carriesOver = true
                    matters[index].notes.insert("Over your limit of \(limit.trials) trial\(limit.trials == 1 ? "" : "s") for this day", at: 0)
                }
            case .hearing:
                hearings += 1
                if hearings > limit.hearings {
                    matters[index].carriesOver = true
                    matters[index].notes.insert("Over your limit of \(limit.hearings) hearing\(limit.hearings == 1 ? "" : "s") for this day", at: 0)
                }
            case .calendarCall:
                break
            }
            matters[index].start = clock
            minutes += matters[index].minutes
            clock = cal.date(byAdding: .minute, value: matters[index].minutes, to: clock) ?? clock
        }
        return minutes
    }

    private func weekPlan(monday: Date, today day: CourtDay) -> WeekPlan {
        let cal = CourtCalendar.calendar
        let todayStart = cal.startOfDay(for: day.date)
        let weekdays = (0..<5).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
        let sitting = weekdays.filter { schedule.sits(on: $0) }
        var limits: [Date: DayLimit] = [:]
        for d in weekdays { limits[d] = schedule.limit(on: d) }
        var all: [PlannedMatter] = []
        var minutes: [Date: Int] = [:]
        var openSeats = 0
        let isCurrent = cal.isDate(monday, inSameDayAs: CourtCalendar.monday(onOrBefore: todayStart))
        for d in weekdays {
            let limit = limits[d] ?? .closed
            var matters: [PlannedMatter] = []
            if cal.isDate(d, inSameDayAs: todayStart) {
                matters = day.entries.map { planned($0, source: .today(entryID: $0.id, matterID: $0.matterID)) }
                let spent = max(0, cal.dateComponents([.minute], from: CourtCalendar.opening(on: d, minutesAfterMidnight: openingMinutes), to: day.clock).minute ?? 0)
                minutes[d] = spent + lay(&matters, on: d, from: max(day.clock, CourtCalendar.opening(on: d, minutesAfterMidnight: openingMinutes)), limit: limit)
                // Done matters show on today too.
                for index in matters.indices where matters[index].done { matters[index].day = d }
            } else if d > todayStart {
                if isFirstSittingDayOfWeek(d) {
                    let expected = lightWeeks ? 4 : 6
                    matters.append(PlannedMatter(id: "call-\(d.timeIntervalSince1970)", kind: .calendarCall, source: .expected,
                                                 title: "Administrative calendar call", subtitle: "Pleas, bond hearings, motions and arraignments",
                                                 minutes: 20 * expected,
                                                 notes: ["The week's short matters are set when the day opens; usually \(expected - 2)–\(expected)"]))
                }
                // Hearings after trials, the way the day is called: jailed defendants and resumed trials first.
                let set = scheduled.filter { cal.isDate($0.date, inSameDayAs: d) }
                let trials = set.filter { if case .trial = $0.entry.matter { return true } else { return false } }
                    .sorted { lhs, rhs in
                        func rank(_ s: ScheduledMatter) -> Int {
                            if s.entry.resume != nil { return 0 }
                            if case .trial(let c) = s.entry.matter, c.background?.isJailed == true { return 1 }
                            return 2
                        }
                        return rank(lhs) < rank(rhs)
                    }
                matters += trials.map { planned($0.entry, source: .scheduled($0.id)) }
                matters += set.filter { if case .hearing = $0.entry.matter { return true } else { return false } }
                    .map { planned($0.entry, source: .scheduled($0.id)) }
                minutes[d] = lay(&matters, on: d, from: CourtCalendar.opening(on: d, minutesAfterMidnight: openingMinutes), limit: limit)
                if schedule.sits(on: d) { openSeats += max(0, limit.trials - trials.count) }
            }
            all += matters
        }
        let off = weekdays.filter { schedule.isOff($0) }
        return WeekPlan(monday: monday, courtDays: sitting, holidays: CourtCalendar.holidays(inWeekOf: monday), isCurrent: isCurrent,
                        cap: sitting.reduce(0) { $0 + (limits[$1]?.trials ?? 0) }, matters: all, openSeats: openSeats,
                        minutesByDay: minutes, dayCapacity: courtMinutesPerDay, limits: limits, daysOff: off)
    }

    /// Everything else on the calendar between two dates.
    func calendarEvents(from start: Date, to end: Date) -> [CalendarEvent] {
        let cal = CourtCalendar.calendar
        func inRange(_ d: Date) -> Bool { d >= cal.startOfDay(for: start) && d <= end }
        var events: [CalendarEvent] = []
        let years = Set([cal.component(.year, from: start), cal.component(.year, from: end)])
        for year in years.sorted() {
            for (date, name) in CourtCalendar.holidays(in: year) where inRange(date) {
                events.append(CalendarEvent(date: date, kind: .holiday, title: name, detail: "State court holiday. The courthouse is closed."))
            }
            let election = CourtCalendar.electionDay(in: year)
            if inRange(election), !unseated, !emergencyJudge,
               Reputation.isElectionYear(year, careerStartYear: cal.component(.year, from: careerStart)) {
                events.append(CalendarEvent(date: election, kind: .election, title: "Election Day",
                                            detail: "Your seat on the Superior Court bench is on the ballot."))
            }
            if let newYear = cal.date(from: DateComponents(year: year, month: 1, day: 1)), inRange(newYear) {
                events.append(CalendarEvent(date: newYear, kind: .year, title: "Year in review",
                                            detail: "The bar survey of your court and the year in review come out."))
            }
        }
        for appeal in appeals where appeal.isPending {
            if inRange(appeal.briefsDue) {
                events.append(CalendarEvent(date: appeal.briefsDue, kind: .appeal, title: "Briefs due: \(appeal.caption)",
                                            detail: "\(appeal.docket) · Appeal by \(appeal.appellant)"))
            }
            if let argument = appeal.argument, inRange(argument) {
                events.append(CalendarEvent(date: argument, kind: .appeal, title: "Oral argument: \(appeal.caption)",
                                            detail: "\(appeal.docket) · Court of Appeals, Raleigh"))
            }
            if inRange(appeal.decisionDue) {
                events.append(CalendarEvent(date: appeal.decisionDue, kind: .appeal, title: "Decision expected: \(appeal.caption)",
                                            detail: "\(appeal.docket) · \(appeal.issue)"))
            }
        }
        for person in people {
            if person.status == .incarcerated, let release = person.releaseDate, inRange(release) {
                events.append(CalendarEvent(date: release, kind: .release, title: "\(person.name) due for release",
                                            detail: person.releaseNote ?? "Projected release from custody."))
            }
            if person.status == .probation, let term = person.probation, inRange(term.ends) {
                events.append(CalendarEvent(date: term.ends, kind: .probation, title: "\(person.name)'s probation ends",
                                            detail: "\(term.docket) · \(term.offense)"))
            }
        }
        return events.sorted { $0.date < $1.date }
    }

    /// Moves a matter to another day because the calendar is too full. The court's own reset costs neither side anything.
    func resetForCongestion(_ matter: PlannedMatter, to date: Date) {
        let target = nextSittingDay(onOrAfter: max(date, nextCourtDate))
        let note = "Reset by the court to \(SentenceFormat.shortDate(target)): the calendar was too full."
        switch matter.source {
        case .scheduled(let id):
            guard let index = scheduled.firstIndex(where: { $0.id == id }) else { return }
            scheduled[index].date = target
            if matter.kind == .trial { happened(.moved(caption: matter.title, to: target)) }
            scheduled[index].entry.carriedOver = true
            scheduled[index].entry.note = ((scheduled[index].entry.note ?? "") + " " + note).trimmingCharacters(in: .whitespaces)
            scheduled.sort { $0.date < $1.date }
            save()
        case .today(_, let matterID):
            continueMatter(matterID, to: target, reason: "The court's calendar was too full.", snapshot: nil)
            if let index = scheduled.lastIndex(where: { $0.entry.matterID == matterID }) {
                scheduled[index].entry.carriedOver = true
                save()
            }
        case .expected:
            break
        }
    }
}
