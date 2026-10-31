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
    /// How the public has taken the court's rulings in cases it followed: up when the outcome matched what it wanted,
    /// down when it didn't. Fades by half each New Year.
    var communityStanding: Int? = nil
    /// Cases this judge handed to another judge.
    var delegated: Int? = nil
    // The judge's corrections record, which follows the judge from county to county (optional for older saves).
    /// Bond conditions set at bond hearings, by kind, and how many defendants couldn't post the bond.
    var bondKinds: [String: Int]? = nil
    var bondsNotPosted: Int? = nil
    /// Bed-days in jail and prison, and days on probation, that this judge's rulings account for.
    var jailBedDays: Int? = nil
    var prisonBedDays: Int? = nil
    var probationDays: Int? = nil
    /// Days the jail ran over capacity: the strain fades by half each New Year, the total stays.
    var crowdingStrain: Int? = nil
    var crowdedDays: Int? = nil
    /// People let out of the jail early to ease crowding, by whose choice.
    var earlyReleasesOrdered: Int? = nil
    var earlyReleasesBySheriff: Int? = nil
    var earlyReleaseRearrests: Int? = nil
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
    var calendarLog: [CalendarRuling]?
    var schedule: CourtSchedule?
    var awaiting: [AwaitingCase]?
    var weekTally: CourtDay.Tally?
    var mood: CourthouseMood?
    var investigations: [OpenInvestigation]?
    var placeHistory: [String: [String]]?
    var residents: [Resident]?
    var officerRecords: [String: OfficerRecord]?
    var lawyerRecords: [String: LawyerRecord]?
    var living: LivingCounty?
    /// People arrested in followed cases, held for a bond hearing at the next calendar call (optional for older saves).
    var bondQueue: [OpenInvestigation]? = nil
    /// Show-cause hearings waiting for the next short session (optional for older saves).
    var showCauseQueue: [CalendarMatter]? = nil
    /// The county jail, prison, and probation picture, and what became of each defendant (optional for older saves).
    var corrections: CorrectionsState? = nil
    var dispositions: [DispositionRecord]? = nil
    var arraignQueue: [PendingArraignment]? = nil
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
    /// Every calendar-call and bond-hearing ruling, newest first.
    @Published private(set) var calendarLog: [CalendarRuling] = []
    /// The county's jail, prison, and probation numbers as this court's rulings drive them.
    @Published private(set) var corrections: CorrectionsState?
    /// Defendants who have had a first appearance and wait to be arraigned, or to plead, at a calendar call.
    @Published private(set) var arraignQueue: [PendingArraignment] = []
    /// What became of each defendant at judgment, and whether the person was arrested again once free.
    @Published private(set) var dispositions: [DispositionRecord] = []
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
    /// Arrested and held for a first bond hearing before the judge.
    @Published private(set) var bondQueue: [OpenInvestigation] = []
    /// Stay-away violations by people not on probation, waiting for a show-cause hearing.
    @Published private(set) var showCauseQueue: [CalendarMatter] = []
    /// The dockets that came out of each place on the county map, oldest first.
    @Published private(set) var placeHistory: [String: [String]] = [:]
    /// Victims and witnesses: everyone who has come through the court other than as a defendant.
    @Published private(set) var residents: [Resident] = []
    /// Officers' and lawyers' records before this judge, by name.
    @Published private(set) var officerRecords: [String: OfficerRecord] = [:]
    @Published private(set) var lawyerRecords: [String: LawyerRecord] = [:]
    /// What has happened to the county in this career: closings, openings, sales, hard times.
    @Published private(set) var living = LivingCounty()
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
    /// Names given out this session before their case reaches a calendar (several cases are built in one pass).
    private var namesIssued: Set<String> = []
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
            recentHeadlines: Set(news.prefix(80).map(\.headline)),
            waiting: trialsInPipeline, oldestWaitDays: scheduled.map { CourtCalendar.calendar.dateComponents([.day], from: date, to: $0.date).day ?? 0 }.max() ?? 0)
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
                            : "Judge \(last) lost the Superior Court race with \(percent) percent of the vote. The challenger campaigned on the judge's sentencing record and the cases that came apart after trial."
                                + ((corrections?.yearDaysOver ?? 0) >= 15 ? " Campaign mailers cited the \(corrections?.yearDaysOver ?? 0) days this year the county jail held more people than it has beds." : ""),
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
        defer {
            stats.communityStanding = (stats.communityStanding ?? 0) / 2
            stats.crowdingStrain = (stats.crowdingStrain ?? 0) / 2
        }
        if let index = reputation.firstIndex(where: { $0.year == oldYear }) {
            // The election-year survey is already on file; bring it up to date and keep the election result.
            survey.comments += reputation[index].comments.filter { $0 == Self.unseatedMarker }
            reputation[index] = survey
        } else {
            reputation.insert(survey, at: 0)
        }
        post(NewsItem(date: next, kind: .community, headline: "Bar survey: lawyers rate Judge \(last)",
                      body: "In the Hollis County Bar's annual survey, lawyers who appeared before Judge \(last) rated the judge's legal soundness \(survey.overall) out of 100. On fairness to their side, prosecutors gave \(survey.prosecutors) and defense lawyers \(survey.defenseBar). A newspaper poll put public approval at \(survey.publicApproval) percent. " + survey.comments.joined(separator: " "),
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
        corrections = nil
        dispositions = []
        arraignQueue = []
        // Every career's county starts a little different.
        living = CountyLife.begin(seed: seedBase)
        Gazetteer.living = living
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

    /// Takes served and resolved orders off the list; the ones still outstanding stay.
    func clearServedArrestOrders() {
        arrestOrders.removeAll { $0.served || $0.resolved }
        save()
    }

    /// Records an order for arrest the court signed, so its status can be followed until the case is heard.
    private func issueArrestOrder(for c: CourtCase, issued: Date, servedOn: Date, how: String? = nil, heldCase: CourtCase? = nil) {
        let bond = c.background.map { _ in "a doubled secured bond" } ?? "a secured bond"
        arrestOrders.insert(ArrestOrder(personID: c.defendant.personID, personName: c.defendant.name, docket: c.docket,
                                        offense: c.charges.first?.law.title ?? "the charges", issued: issued,
                                        servedOn: max(servedOn, issued), bond: bond, how: how, heldCase: heldCase), at: 0)
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
        // The ruling that sent the case to another date is done; a mistrial starts a new trial with none of them.
        if case .trial(var c) = entry.matter, let incidents = c.incidents, !incidents.isEmpty {
            if let r = snapshot?.rulings {
                c.incidents = incidents.filter { i in
                    guard let o = r.choice(for: i) else { return true }
                    return o.effect != .continueCase && o.effect != .mistrial
                }
            } else {
                c.incidents = []
            }
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

    /// What a finished trial adds to the officers' and lawyers' records, and the paper when an officer's searches keep
    /// getting thrown out.
    private func recordTrackRecords(_ c: CourtCase, outcome: CaseOutcome) {
        let convicted = outcome.convicted
        let suppressed = outcome.rulingNotes.contains { $0.title.hasPrefix("Motion to Suppress") && $0.yourRuling == "Granted" }
        for officer in [c.investigation?.facts?.lead, c.investigation?.facts?.firstOfficer].compactMap({ $0 }) where !officer.isEmpty {
            var r = officerRecords[officer] ?? OfficerRecord(name: officer)
            guard !r.cases.contains(c.caption) else { continue }
            r.cases.append(c.caption)
            if convicted { r.convictions += 1 } else { r.acquittals += 1 }
            // Suppression follows the lead investigator, whose search or interview it was.
            if suppressed && officer == c.investigation?.facts?.lead {
                r.suppressed.append(c.caption)
                if r.suppressed.count >= 2, let judgeName {
                    post(NewsItem(date: currentDate, kind: .community,
                                  headline: "Judge \(lastName(judgeName)) again throws out evidence from \(officer)",
                                  body: "For the \(r.suppressed.count == 2 ? "second" : "\(r.suppressed.count)th") time, Judge \(lastName(judgeName)) suppressed evidence gathered by \(officer), this time in \(c.caption). Defense lawyers say they will raise it in every case the officer works.",
                                  docket: c.docket, prominence: 1, section: "Courts"))
                }
            }
            officerRecords[officer] = r
        }
        for (name, prosecutor) in [(c.prosecutor, true), (c.defenseAttorney, false)] where !name.isEmpty {
            var r = lawyerRecords[name] ?? LawyerRecord(name: name, prosecutor: prosecutor)
            if convicted { r.convictions += 1 } else { r.acquittals += 1 }
            r.lastCaption = c.caption
            r.lastResult = convicted ? "conviction" : "acquittal"
            lawyerRecords[name] = r
        }
    }

    /// A case that names a store's or salon's owner makes that person the owner on the county's books, so the
    /// directory and the paper agree with what the case said.
    private func rememberOwners(_ c: CourtCase) {
        guard let scene = c.investigation?.facts?.place,
              let place = Gazetteer.livePlaces.sorted(by: { $0.name.count > $1.name.count }).first(where: { scene.contains($0.name) }) else { return }
        let owner = c.witnesses.first { w in
            let r = w.role.lowercased()
            return r.contains("owner") && !["homeowner", "car owner", "truck owner", "owner of the"].contains(where: r.contains)
        }
        guard let owner, living.owners[place.name] != owner.name else { return }
        living.owners[place.name] = owner.name
        Gazetteer.living = living
    }

    /// A new case knows its people's history: the defense crosses an officer on searches this court threw out, and
    /// the case file notes how its lawyers have done before this judge.
    private func applyTrackRecords(_ c: inout CourtCase, rng: inout SeededRNG) {
        for i in c.witnesses.indices where c.witnesses[i].calledBy == .prosecution {
            guard let r = officerRecords[c.witnesses[i].name], let last = r.suppressed.last else { continue }
            let (q, a) = TrackRecords.suppressionCross(last, count: r.suppressed.count, rng: &rng)
            var exchanges = c.witnesses[i].exchanges ?? []
            let at = exchanges.firstIndex { $0.phase == .redirect } ?? exchanges.count
            exchanges.insert(TestimonyExchange(phase: .cross, examiner: .defense, question: q, answer: a), at: at)
            c.witnesses[i].exchanges = exchanges
            c.witnesses[i].cross.append(a)
            // An officer whose work keeps getting thrown out carries less weight.
            if r.suppressed.count >= 2 { c.witnesses[i].weight = max(1, c.witnesses[i].weight - 1) }
        }
        for name in [c.prosecutor, c.defenseAttorney] {
            if let note = lawyerRecords[name].flatMap(TrackRecords.counselNote) { c.proceduralNotes.append(note) }
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
            // Everyone arrested is held until the judge sets conditions of release at the next calendar call.
            if var bg = c.background {
                bg.onRelease = false
                bg.custodyDays = 1
                bg.custodyAtIntake = 0
                bg.bondStatus = "Held in the \(county.name) Detention Center since the arrest on \(SentenceFormat.shortDate(item.arrest)), awaiting a bond hearing."
                c.background = bg
            }
            post(InvestigationArc.arrestNews(c, on: date, town: item.town, agency: c.investigation?.facts?.agency ?? c.investigatingAgency,
                                             judge: lastName(judgeName), county: county, followed: item.note == nil, bondHearing: true))
            var held = item
            held.courtCase = c
            bondQueue.append(held)
        }
    }

    /// A crime happens: the paper reports it, investigators work it, and an arrest follows, at the scene or days to
    /// weeks later. The defendant is booked into the jail and comes before the court at the next bond hearing.
    /// Every new case reaches the court this way.
    private func openCrime(on date: Date, story: Bool, allowMurder: Bool, knownDefendant: Resident?, rng: inout SeededRNG,
                           excluding used: inout Set<UUID>) {
        let cal = CourtCalendar.calendar
        let today = cal.startOfDay(for: date)
        let incident = cal.date(byAdding: .day, value: -1, to: today) ?? today
        let atScene = rng.chance(story ? 0.3 : 0.45)
        let arrest = atScene ? incident : (cal.date(byAdding: .day, value: story ? rng.int(3...24) : rng.int(2...12), to: incident) ?? incident)
        // The case is built as of its first possible trial day, so every entry in its file falls before it.
        let ready = cal.date(byAdding: .day, value: rng.int(35...56), to: arrest) ?? arrest
        let daysAgo = cal.dateComponents([.day], from: incident, to: ready).day ?? 40
        guard var c = generateCase(date: ready, rng: &rng, excluding: &used, storySlot: story, allowMurder: allowMurder, announce: false,
                                   generic: !story, incidentDaysAgo: daysAgo, arrestOn: arrest, residentDefendant: knownDefendant) else { return }
        if story && c.background?.arrangementPresented != true && rng.chance(0.25) {
            c.continuanceMotion = ContinuanceMotions.make(for: c, rng: &rng)
        }
        // A written case with dates of its own keeps them; it is never booked more than a day before it reaches the court.
        let facts = c.investigation?.facts
        let happened = facts.map { cal.startOfDay(for: $0.incident) } ?? incident
        let booked = max(facts.map { cal.startOfDay(for: $0.arrest) } ?? arrest, incident)
        let town = facts?.town ?? county?.seat ?? ""
        let followed = booked > happened
        if followed {
            var beats = InvestigationArc.beats(for: c, incident: happened, arrest: booked, town: town,
                                               agency: facts?.agency ?? c.investigatingAgency, rng: &rng)
            // A smaller crime gets a line in the paper, not a running story.
            if !story { beats = Array(beats.prefix(1)) }
            pending.append(contentsOf: beats)
        }
        investigations.append(OpenInvestigation(courtCase: c, incident: happened, arrest: booked, town: town,
                                                offense: InvestigationArc.subject(c), ready: max(ready, booked),
                                                note: followed ? nil : "Arrested at the scene on \(SentenceFormat.shortDate(booked))."))
    }

    /// After a first appearance: a case that goes to trial joins the list waiting for a trial date; any other comes
    /// back at a calendar call a week or two later to plead.
    private func queueArraignment(_ c: CourtCase, note: String, on date: Date) {
        let cal = CourtCalendar.calendar
        let start = max(cal.startOfDay(for: date), cal.startOfDay(for: c.sessionDate))
        // After the bond hearing the case joins the list waiting for a trial date; the State needs a few weeks for
        // discovery before it can be tried. (Only a smaller case from an older save still comes back to plead.)
        if c.templateKey.hasPrefix("story.") {
            var held = c
            held.background?.arraigned = true
            let investigationReady = (c.investigation?.facts?.arrest).flatMap { cal.date(byAdding: .day, value: 35, to: cal.startOfDay(for: $0)) }
            let ready = max(investigationReady ?? start, cal.date(byAdding: .day, value: 21, to: start) ?? start)
            awaitCase(held, note: note, on: date, earliest: ready, reason: "Discovery is still being exchanged")
            return
        }
        let due = cal.date(byAdding: .day, value: 6 + Int(c.seed % 8), to: start) ?? start
        arraignQueue.removeAll { $0.courtCase.id == c.id }
        arraignQueue.append(PendingArraignment(courtCase: c, since: date, due: due, note: note))
    }

    /// A case built around an arrest the court already knows the date of: the incident comes before it, and the
    /// file's lab work and interviews finish before the first day it could be tried.
    private func freshCase(on date: Date, arrest: Date, incidentBefore: ClosedRange<Int>, categories: Set<LawCategory>? = nil,
                           generic: Bool = false, rng: inout SeededRNG, excluding used: inout Set<UUID>) -> CourtCase? {
        let cal = CourtCalendar.calendar
        let incident = cal.date(byAdding: .day, value: -rng.int(incidentBefore), to: min(arrest, date)) ?? date
        let ready = cal.date(byAdding: .day, value: rng.int(42...56), to: max(arrest, date)) ?? date
        let daysAgo = cal.dateComponents([.day], from: incident, to: ready).day ?? 30
        guard var c = generateCase(date: ready, rng: &rng, excluding: &used, storySlot: false, categories: categories,
                                   allowMurder: false, announce: false, generic: generic, incidentDaysAgo: daysAgo, arrestOn: arrest) else { return nil }
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
            trialsHeard: trialsHeard, leaveLeft: leaveLeft, recentHeadlines: Set(news.prefix(700).map(\.headline)))
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
        var used = namesInPlay()
        let name = NameBank.person(using: &rng, excluding: &used)
        namesIssued.insert(name)
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
                                              excluding: usedPeople, seed: rng.next(), takenNames: namesInPlay(plus: entries))
                call.matters.forEach { namesIssued.insert($0.personName) }
                docketSequence += 200
                // Leave room on the calendar for the new arrest, a relief motion, and most weeks a warrant and an arraignment.
                // Fewer new matters while the new judge's courtroom is still filling up.
                let wantsWarrant = rng.chance(0.7 * max(0.3, caseloadRamp) * intakeFactor)
                // Defendants who had their first appearance come back to be arraigned or to plead.
                let dueArraignments = arraignQueue.filter { cal.startOfDay(for: $0.due) <= cal.startOfDay(for: date) }
                    .sorted { $0.due < $1.due }
                let reserved = 1 + (reliefQueue.isEmpty ? 0 : 1) + (wantsWarrant ? 1 : 0) + min(3, dueArraignments.count)
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
                var priorContinuances: [UUID: Int] = [:]
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
                    // A missed court date is about a case called at this calendar: one waiting for a trial date, or one
                    // set for trial in the next two weeks, never a trial months away. Someone charged with murder is
                    // held, not out on bond.
                    let soon = cal.date(byAdding: .day, value: 14, to: date) ?? date
                    let pool = scheduled.filter { $0.entry.resume == nil && (kind != .failureToAppear || $0.date <= soon) }.map(\.entry)
                        + awaiting.map(\.entry)
                    let waiting = pool.compactMap { entry -> CourtCase? in
                        guard case .trial(let c) = entry.matter, !claimed.contains(c.id),
                              c.templateKey.hasPrefix("story.") else { return nil }
                        // A defense asks to continue a case that has been around a while, and says truthfully which
                        // continuance it would be.
                        if kind == .continuance {
                            let incident = c.investigation?.facts?.incident ?? c.sessionDate
                            guard (cal.dateComponents([.day], from: incident, to: date).day ?? 0) >= 45 else { return nil }
                            priorContinuances[c.id] = entry.continuances
                        }
                        let jailed = c.background?.isJailed ?? false
                        switch kind {
                        case .bondModification: return jailed ? c : nil
                        case .failureToAppear: return jailed || Self.isMurder(c) ? nil : c
                        default: return c
                        }
                    }
                    guard var c = waiting.isEmpty ? nil : rng.pick(waiting) else {
                        unbound.append(call.matters[index].id)
                        continue
                    }
                    claimed.insert(c.id)
                    if kind == .bondModification {
                        call.matters[index] = CalendarCalls.bondReductionMatter(for: c, on: date, rng: &rng)
                    } else {
                        if kind == .failureToAppear, var bg = c.background {
                            // Only someone out on bond can fail to appear.
                            bg.onRelease = true
                            bg.bondStatus = "Out on a secured bond; did not answer the calendar call."
                            c.background = bg
                        }
                        call.matters[index] = CalendarCalls.bind(call.matters[index], to: c)
                        if kind == .continuance {
                            let ordinals = ["first", "second", "third", "fourth", "fifth"]
                            let nth = ordinals[min(priorContinuances[c.id] ?? 0, ordinals.count - 1)]
                            for word in ["second", "third", "fourth"] {
                                call.matters[index].summary = call.matters[index].summary
                                    .replacingOccurrences(of: "be the \(word) continuance", with: "be the \(nth) continuance")
                            }
                        }
                        if kind == .failureToAppear {
                            let set = scheduled.first { if case .trial(let t) = $0.entry.matter { return t.id == c.id } else { return false } }
                            call.matters[index].summary += set.map { " The trial is set for \(SentenceFormat.shortDate($0.date))." }
                                ?? " The case has no trial date yet; it was on today's calendar for setting."
                        }
                    }
                }
                // A motion with no case waiting for it isn't on the calendar this week.
                call.matters.removeAll { unbound.contains($0.id) }
                // New cases come in when the trial calendar has room for them.
                let roomForNew = trialsInPipeline < pipelineTarget
                // Arraignments and pleas: only defendants already arrested and brought before the court. A written case
                // is arraigned and set for trial; any other case is resolved by a plea. Any left over wait for next week.
                let arraignRoom = max(1, calendarCap - call.matters.count - (reliefQueue.isEmpty ? 0 : 1) - (wantsWarrant ? 1 : 0))
                for item in dueArraignments.prefix(min(4, arraignRoom)) {
                    var c = item.courtCase
                    // Jail time keeps counting while the defendant waits.
                    if var bg = c.background, bg.isJailed {
                        let since = cal.dateComponents([.day], from: cal.startOfDay(for: c.sessionDate), to: cal.startOfDay(for: date)).day ?? 0
                        let before = bg.custodyDays
                        bg.custodyDays = max(1, before + max(0, since))
                        bg.bondStatus = bg.bondStatus.replacingOccurrences(of: "for \(before) day\(before == 1 ? "" : "s")",
                                                                           with: "for \(bg.custodyDays) day\(bg.custodyDays == 1 ? "" : "s")")
                        c.background = bg
                        c.sessionDate = cal.startOfDay(for: date)
                    }
                    var matter = c.templateKey.hasPrefix("story.") ? CalendarCalls.arraignmentMatter(for: c) : CalendarCalls.pleaMatter(for: c)
                    if matter.kind == .quickPlea, let status = c.background?.bondStatus { matter.summary += " " + status }
                    call.matters.append(matter)
                    usedPeople.insert(c.defendant.personID)
                    arraignQueue.removeAll { $0.id == item.id }
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
                // Petitions: an expunction, a bonding company's motion, a driving privilege after a DWI.
                call.matters += petitionMatters(on: date, excluding: usedPeople, rng: &rng)
                call.matters += treatmentCourtMatters(on: date, excluding: usedPeople, rng: &rng)
                let onThisCall = Set(call.matters.map(\.personID) + call.matters.compactMap { $0.pendingCase?.defendant.personID })
                // Every pending defendant is "in play"; only the ones already on this calendar are off limits.
                if let m = counselWithdrawal(on: date, excluding: onThisCall, rng: &rng) { call.matters.append(m) }
                call.matters.forEach { usedPeople.insert($0.personID) }
                HolidayAsks.apply(&call)
                entries.insert(DocketEntry(matter: .calendar(call)), at: 0)
            }
        }

        // First appearances: anyone arrested and held since the last court day gets a bond hearing, a separate short
        // session from the week's calendar call. Most weeks there's also a fresh arrest the paper didn't follow.
        if kind != .specialSetting {
            let cal = CourtCalendar.calendar
            var bondCall = CalendarCall(date: date, matters: [], bondSession: true)
            for item in bondQueue {
                var c = item.courtCase
                let days = max(1, cal.dateComponents([.day], from: cal.startOfDay(for: item.arrest), to: cal.startOfDay(for: date)).day ?? 1)
                if var bg = c.background {
                    bg.custodyDays = days
                    bg.bondStatus = "Held since the arrest on \(SentenceFormat.shortDate(item.arrest)) pending this bond hearing; in custody for \(days) day\(days == 1 ? "" : "s")."
                    c.background = bg
                }
                var matter = CalendarCalls.bondMatter(for: c, rng: &rng)
                matter.summary = matter.summary.replacingOccurrences(of: "arrested this week", with: "arrested on \(SentenceFormat.shortDate(item.arrest))")
                if item.note == nil {
                    matter.summary = "The arrest in the \(item.town) case the paper has followed. " + matter.summary
                } else if let note = item.note, !note.hasPrefix("Arrested at the scene") {
                    matter.summary = note + " " + matter.summary
                }
                bondCall.matters.append(matter)
                usedPeople.insert(c.defendant.personID)
            }
            bondQueue = []
            for matter in showCauseQueue where !usedPeople.contains(matter.personID) {
                bondCall.matters.append(matter)
                usedPeople.insert(matter.personID)
            }
            showCauseQueue.removeAll { m in bondCall.matters.contains { $0.id == m.id } }
            if !bondCall.matters.isEmpty {
                HolidayAsks.apply(&bondCall)
                entries.insert(DocketEntry(matter: .calendar(bondCall)), at: 0)
            }
        }
        return CourtDay(date: date, clock: CourtCalendar.opening(on: date, minutesAfterMidnight: openingMinutes),
                        kind: kind, entries: entries, sessionDay: sessionDay)
    }

    /// Everyone with a matter on a calendar or waiting for a trial date.
    /// Every name already given to someone in this county: no new person ever gets one of them. Shared last names
    /// or first names are fine; two different people never have the same full name.
    func namesInPlay(plus extra: [DocketEntry] = []) -> Set<String> {
        var names = Set(people.map(\.name)).union(residents.map(\.name)).union(living.owners.values).union(officerRecords.keys)
        if let county { names.formUnion(Gazetteer.regulars(for: county).values) }
        func add(_ c: CourtCase) {
            names.insert(c.defendant.name)
            if let v = c.victimName { names.insert(v) }
            c.witnesses.forEach { names.insert($0.name) }
        }
        arraignQueue.forEach { add($0.courtCase) }
        bondQueue.forEach { add($0.courtCase) }
        for entry in extra + (today?.entries ?? []) + scheduled.map(\.entry) + awaiting.map(\.entry) {
            switch entry.matter {
            case .trial(let c): add(c)
            case .hearing(let h): names.insert(h.personName)
            case .calendar(let call):
                for m in call.matters {
                    names.insert(m.personName)
                    if let c = m.pendingCase { add(c) }
                }
            }
        }
        investigations.forEach { add($0.courtCase) }
        bondQueue.forEach { add($0.courtCase) }
        return names.union(namesIssued)
    }

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
        bondQueue.forEach { used.insert($0.courtCase.defendant.personID) }
        arraignQueue.forEach { used.insert($0.courtCase.defendant.personID) }
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
        awaiting.count + investigations.count + bondQueue.count + scheduled.filter { if case .trial = $0.entry.matter { return true } else { return false } }.count
    }

    /// How many trials the court keeps in the pipeline: about two weeks of the judge's own schedule.
    /// A new judge's courtroom starts quiet and fills over the first couple of months: a quarter of the full
    /// caseload the first week, rising each week to all of it by week ten.
    var caseloadRamp: Double { min(1, 0.4 + Double(calendarWeekNumber - 1) * 0.1) }

    var pipelineTarget: Int { max(3, Int((Double(max(6, 3 * schedule.weeklyTrials + 3)) * caseloadRamp * caseloadPressure).rounded())) }

    /// The share of new cases the judge has asked for.
    var intakeFactor: Double { (schedule.intake ?? .full).factor }

    /// Asks the chief judge to send more or fewer new cases.
    func setIntake(_ level: CourtSchedule.Intake) {
        guard level != (schedule.intake ?? .full), let judgeName else { return }
        let before = schedule.intake ?? .full
        schedule.intake = level
        let fewer = level.factor < before.factor
        post(NewsItem(date: currentDate, kind: .community,
                      headline: fewer ? "Judge \(lastName(judgeName)) asks for fewer new cases" : "Judge \(lastName(judgeName)) takes on more new cases",
                      body: fewer
                        ? "Citing \(trialsInPipeline) trials already waiting, Judge \(lastName(judgeName)) asked the chief judge to send " + (level == .closed ? "no new cases for now" : "fewer new felony cases") + ". Visiting judges will pick up the rest."
                        : "Judge \(lastName(judgeName)) told the chief judge the court can take " + (level == .full ? "its full share of new cases again." : "more new cases."),
                      prominence: 1, section: "Courts"))
        save()
    }

    /// Past the first months, arrests don't wait on the court: the county sends more cases than one judge can hear, a
    /// little more each month, until the docket is truly backed up (about double after a year).
    var caseloadPressure: Double { min(2.2, 1 + Double(max(0, calendarWeekNumber - 10)) * 0.025) }

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
        // Thin supervision on an overloaded probation office lets more people drift back into trouble.
        let overload = probationOverload
        if rng.chance(0.04 + (overload > 1 ? min(0.04, (overload - 1) * 0.05) : 0)), !candidates.isEmpty {
            let probationers = candidates.filter { $0.status == .probation }
            let person = rng.pick(overload > 1 && !probationers.isEmpty && rng.chance(0.5) ? probationers : candidates)
            if let prior = person.priors.last(where: { $0.fromThisCourt && $0.docket != nil && !($0.docket ?? "").hasSuffix("(PV)") }),
               let entered = person.appearances.last(where: { $0.docket == prior.docket }) {
                let incident = cal.date(byAdding: .day, value: -rng.int(30...70), to: date) ?? date
                stats.chargedAgainAfterRelease = (stats.chargedAgainAfterRelease ?? 0) + 1
                noteRearrest(person.id, on: incident)
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
            // Everything in the queue follows an arrest that already happened, so a later stint in custody doesn't
            // make the charge go away; the case is heard with the defendant brought over from the jail.
            guard let person = person(followUp.personID) else { continue }
            if var c = generateCase(date: date, rng: &rng, excluding: &used, storySlot: false, followUp: followUp) {
                if person.status == .incarcerated, var bg = c.background {
                    bg.onRelease = false
                    c.background = bg
                }
                // The grand jury's indictment brings an order for arrest: the defendant is booked into the jail and comes
                // before the court for conditions of release. Someone already in custody goes straight to arraignment.
                c.sessionDate = cal.startOfDay(for: date)
                if person.status == .incarcerated {
                    queueArraignment(c, note: followUp.note, on: date)
                } else {
                    let booked = cal.startOfDay(for: date)
                    if var bg = c.background {
                        bg.onRelease = false
                        bg.custodyDays = 1
                        bg.custodyAtIntake = 0
                        bg.bondStatus = "Held in the \(county?.name ?? "county") jail since the arrest on the indictment on \(SentenceFormat.shortDate(booked)), awaiting a bond hearing."
                        c.background = bg
                    }
                    let facts = c.investigation?.facts
                    bondQueue.append(OpenInvestigation(courtCase: c, incident: facts?.incident ?? followUp.incident, arrest: booked,
                                                       town: facts?.town ?? county?.seat ?? "", offense: InvestigationArc.subject(c),
                                                       ready: cal.date(byAdding: .day, value: 42, to: booked) ?? booked,
                                                       note: followUp.note + " Arrested on the indictment on \(SentenceFormat.shortDate(booked))."))
                }
                // An arrest while on probation is also a violation: the officer files a report on the same conduct.
                if person.status == .probation, person.probation != nil, !hasHearingSet(for: person.id) {
                    let offense = (c.charges.first?.law.title ?? "a new offense").lowercased()
                    fileViolationReport(person, text: "arrested and charged with \(offense). The charge is pending before this court in \(c.docket); the officer will offer the underlying facts.",
                                        contact: false, note: "Violation report filed after \(person.lastName)'s arrest in \(c.docket).", on: date, rng: &rng)
                }
            }
        }
        // New indictments, when the court's docket has room for them.
        // Cases keep coming even when the court is full; a backed-up court just has more of them waiting.
        let underTarget = trialsInPipeline < pipelineTarget
        // Over target, arrivals slow but don't stop, and they pick up as the county's pressure grows: a few extra
        // cases a week by the end of the first year, enough that the list outruns the calendar.
        let overflow = caseloadPressure > 1.05 ? min(0.85, 0.25 + 0.5 * (caseloadPressure - 1)) : 0
        if trialsInPipeline < pipelineTarget * 4, rng.chance(intakeFactor),
           (underTarget && rng.chance(0.75 * max(0.5, caseloadRamp))) || (!underTarget && rng.chance(overflow)) {
            let murderWaiting = (awaiting.map(\.entry) + scheduled.map(\.entry)).contains { entry in
                if case .trial(let c) = entry.matter { return Self.isMurder(c) } else { return false }
            }
            // Now and then someone the court knows from an earlier case (a witness, a victim) is the one charged.
            let knownPool = residents.filter { !$0.deceased && $0.occupation == nil }
            let knownDefendant = rng.chance(0.06) && !knownPool.isEmpty ? knownPool[rng.int(0...(knownPool.count - 1))] : nil
            openCrime(on: date, story: true, allowMurder: !murderWaiting, knownDefendant: knownDefendant, rng: &rng, excluding: &used)
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
    }

    /// Cases left waiting cost something: jail time runs, defense lawyers file, the paper notices, and a victim the
    /// court hasn't protected can be hurt again. Each cost lands once.
    private func reviewWaiting(on date: Date, rng: inout SeededRNG) {
        let cal = CourtCalendar.calendar
        let judge = lastName(judgeName ?? "")
        for index in awaiting.indices {
            guard let c = awaiting[index].courtCase else { continue }
            let waited = cal.dateComponents([.day], from: awaiting[index].since, to: date).day ?? 0
            // Days the judge could have set it: from when it reached the list, or when it was ready, whichever is later.
            let readySince = max(awaiting[index].since, awaiting[index].earliest ?? awaiting[index].since)
            let settable = max(0, cal.dateComponents([.day], from: readySince, to: date).day ?? 0)
            let jailed = c.background?.isJailed ?? false
            let held = jailed ? (c.background?.custodyDays ?? 0) + max(0, cal.dateComponents([.day], from: cal.startOfDay(for: c.sessionDate), to: date).day ?? 0) : 0
            func once(_ key: String, _ action: () -> Void) {
                guard !awaiting[index].warnings.contains(key) else { return }
                awaiting[index].warnings.append(key)
                action()
            }
            // The paper and the defense only blame the court once the case has sat ready on its list for a while.
            if jailed && held >= 120 && settable >= 30 {
                once("jail120") {
                    stats.delayedCases = (stats.delayedCases ?? 0) + 1
                    post(NewsItem(date: date, kind: .community, headline: "\(c.defendant.name) held \(held) day\(held == 1 ? "" : "s") with no trial date",
                                  body: "\(c.defendant.name) has been in the Hollis County jail for \(held) day\(held == 1 ? "" : "s") on \(c.charges.first?.law.title.lowercased() ?? "the charges"), and the case has been ready for trial for \(settable) day\(settable == 1 ? "" : "s") with no date from Judge \(judge). Defense lawyers say the wait is becoming a constitutional problem.",
                                  docket: c.docket, prominence: 1))
                }
            }
            if jailed && held >= 240 && settable >= 60 {
                once("jail240") {
                    let note = "The defense has moved to dismiss for violation of the right to a speedy trial: \(c.defendant.lastName) has been held \(held) day\(held == 1 ? "" : "s") awaiting trial (Barker v. Wingo; N.C. Const. art. I, § 18)."
                    awaiting[index].entry.note = ((awaiting[index].entry.note ?? "") + " " + note).trimmingCharacters(in: .whitespaces)
                    if case .trial(var tc) = awaiting[index].entry.matter {
                        tc.proceduralNotes.append(note)
                        awaiting[index].entry.matter = .trial(tc)
                    }
                    post(NewsItem(date: date, kind: .community, headline: "Lawyers for \(c.defendant.name) seek dismissal over delay",
                                  body: "After \(held) day\(held == 1 ? "" : "s") in jail without a trial, \(c.defendant.name)'s lawyers asked Judge \(judge) to dismiss the charges for violation of the right to a speedy trial.",
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
                                  body: "\(victim) told deputies that \(c.defendant.name), who is free while charges are pending in Hollis County Superior Court, came to \(victim)'s home this week. The case has waited \(waited) day\(waited == 1 ? "" : "s") for a trial date before Judge \(judge).",
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
            if settable >= 180 {
                once("halfYear") {
                    stats.delayedCases = (stats.delayedCases ?? 0) + 1
                    post(NewsItem(date: date, kind: .community, headline: "Six months on, no trial date in \(c.caption)",
                                  body: "The case against \(c.defendant.name) has waited \(waited) day\(waited == 1 ? "" : "s") for a trial date in Hollis County Superior Court." + (c.victimName.map { " \($0)'s family says the wait has been hard." } ?? ""),
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
        guard waited != 0 else { return }
        let before = background.custodyDays
        // A trial moved up to an earlier date than the file was written for takes the credit back with it.
        background.custodyDays = max(1, background.custodyDays + waited)
        let after = background.custodyDays
        background.bondStatus = background.bondStatus.replacingOccurrences(of: "for \(before) days?\\b", with: "for \(after) day\(after == 1 ? "" : "s")",
                                                                           options: .regularExpression)
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
        c.proceduralNotes.append("Credit for \(served) day\(served == 1 ? "" : "s") in custody on the vacated judgment is added to pretrial confinement (G.S. 15-196.1).")
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
                          headline: "After \(times) delays, \(c.defendant.lastName) case is finally called",
                          body: "The case against \(c.defendant.name) in Hollis County Superior Court had been continued \(times) times before it was called this week. \(victim)'s family told reporters they took days off work for every setting. \"We just want it over,\" a relative said.",
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
        /// The trial date the judge had already set for the case being ruled on; a ruling keeps it when it still works.
        var setDate: Date?
        /// Puts the case back on the date the judge set, if it falls on or after `from`. Returns whether it did.
        func keepDate(_ c: CourtCase, note: String, continuances: Int, from: Date) -> Bool {
            guard let setDate, CourtCalendar.calendar.startOfDay(for: setDate) >= CourtCalendar.calendar.startOfDay(for: from) else { return false }
            var entry = DocketEntry(matter: .trial(c), note: note + " The trial stays set for \(SentenceFormat.shortDate(setDate)).")
            entry.continuances = continuances
            scheduled.append(ScheduledMatter(date: setDate, entry: entry))
            scheduled.sort { $0.date < $1.date }
            return true
        }
        func schedule(_ c: CourtCase, _ weeks: Int, _ note: String, _ continuances: Int) {
            setFor(c, weeks: weeks, note: note, continuances: continuances)
        }
        /// Set for trial: the case keeps its trial date if that still works; otherwise it joins the list waiting for the
        /// judge to give it a date, ready from the week given.
        func setFor(_ c: CourtCase, weeks: Int, note: String, continuances: Int = 0) {
            let ready = later(weeks: weeks)
            if keepDate(c, note: note, continuances: continuances, from: ready) { return }
            awaitCase(c, note: note, on: call.date, earliest: ready,
                      reason: weeks <= 2 ? "The parties need time to prepare" : "Discovery is still being exchanged",
                      continuances: continuances)
        }
        /// An order for arrest plays out: most people are picked up within weeks, some turn themselves in, some run and
        /// are caught months later, often out of state, and a few are never found. The case waits for the arrest.
        func orderForArrest(_ c: CourtCase, missed: String, note: String) {
            var held = c
            if var bg = held.background {
                bg.onRelease = false
                bg.custodyDays = max(1, bg.custodyDays)
                bg.bondStatus = "\(missed); order for arrest outstanding. Once served, held on a doubled secured bond."
                held.background = bg
            }
            let cal = CourtCalendar.calendar
            let roll = rng.int(1...100)
            if roll <= 80 {
                let surrendered = roll > 65
                let weeksOut = surrendered ? rng.int(1...3) : rng.int(2...5)
                let arrested = cal.date(byAdding: .day, value: max(1, 7 * weeksOut - rng.int(3...6)), to: call.date) ?? call.date
                let how = surrendered ? "Turned in at the Hollis County jail"
                    : rng.pick(["Arrested at home by deputies", "Arrested at work by deputies", "Picked up by deputies on a traffic stop",
                                "Arrested by deputies at a relative's house"])
                // The case waits with the order; once served, the defendant comes before the court on bond.
                issueArrestOrder(for: c, issued: call.date, servedOn: arrested, how: how, heldCase: held)
            } else if roll <= 95 {
                let found = cal.date(byAdding: .day, value: rng.int(45...270), to: call.date) ?? call.date
                let how = rng.pick(["Arrested in South Carolina and returned to Hollis County", "Found in Virginia and extradited",
                                    "Arrested on a traffic stop two counties over", "Caught by the U.S. Marshals fugitive task force",
                                    "Arrested in Georgia on the warrant and returned"])
                issueArrestOrder(for: c, issued: call.date, servedOn: found, how: how, heldCase: held)
            } else {
                issueArrestOrder(for: c, issued: call.date, servedOn: .distantFuture, heldCase: held)
            }
        }
        /// To be tried now: today, if the day has room under the judge's limits, or the next day that does.
        func thisWeek(_ c: CourtCase, note: String, continuances: Int = 0) {
            if keepDate(c, note: note.replacingOccurrences(of: "; the case is tried this week", with: "")
                            .replacingOccurrences(of: "; tried this week", with: ""), continuances: continuances, from: call.date) { return }
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
            // A case already set for trial, or waiting for a date, is taken off its old setting; the ruling sets the new one,
            // keeping the judge's date when it still works.
            setDate = scheduled.first { item in if case .trial(let t) = item.entry.matter { return t.id == c.id } else { return false } }?.date
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
                let before = ["first", "second", "third", "fourth", "fifth"].firstIndex { m.summary.contains("be the \($0) continuance") } ?? 1
                if choice == 0 {
                    setFor(c, weeks: 4, note: "Continued at the calendar call on \(heard) on the defense's motion.", continuances: before + 1)
                } else {
                    // Denied: the trial date stands; with none yet, the case is ready now and waits for the judge to set one.
                    let note = "Motion to continue denied at the calendar call on \(heard); ready for trial."
                    if !keepDate(c, note: note, continuances: before, from: call.date) {
                        awaitCase(c, note: note, on: call.date, continuances: before)
                    }
                }
            case .counselWithdrawal:
                if choice <= 1 {
                    var fresh = c
                    let old = c.defenseAttorney.components(separatedBy: ", ").first ?? c.defenseAttorney
                    let retained = c.defenseAttorney.contains("retained")
                    // A hired lawyer is replaced by another hired one, or by the public defender; an appointed one by
                    // another public defender or a private lawyer Indigent Defense Services appoints.
                    let usePD = retained ? choice == 1 : choice == 0
                    let pool = (usePD ? county?.assistantPDs : county?.privateCounsel) ?? []
                    if let next = pool.filter({ $0 != old }).randomElement(using: &rng) {
                        fresh.defenseAttorney = next + (usePD ? ", Assistant Public Defender" : (retained ? ", retained counsel" : ", appointed counsel"))
                    }
                    let newName = fresh.defenseAttorney.components(separatedBy: ", ").first ?? fresh.defenseAttorney
                    setFor(fresh, weeks: choice == 0 ? 6 : 3,
                           note: "\(old) allowed to withdraw at the calendar call on \(heard); \(newName) \(retained && choice == 0 ? "hired" : "appointed").")
                } else {
                    // A real conflict comes back when the trial is called.
                    var kept = c
                    if m.petition?.eligible == true {
                        kept.incidents = (kept.incidents ?? []) + [Incidents.conflictedCounsel(kept, reason: m.petition?.reason ?? "")]
                    }
                    let note = "Motion to withdraw denied at the calendar call on \(heard)."
                    if !keepDate(kept, note: note, continuances: 0, from: call.date) {
                        awaitCase(kept, note: note, on: call.date)
                    }
                }
            case .failureToAppear:
                switch choice {
                case 0:
                    orderForArrest(c, missed: "Failed to appear at the calendar call on \(heard)",
                                   note: "Order for arrest issued at the calendar call on \(heard) after a failure to appear.")
                case 1:
                    if rng.chance(0.6) {
                        var appeared = c
                        if var bg = appeared.background {
                            bg.bondStatus = "Out on bond; missed the morning calendar call on \(heard) but appeared that afternoon."
                            appeared.background = bg
                        }
                        thisWeek(appeared, note: "Appeared at the afternoon session after missing the morning call; tried this week.")
                    } else {
                        orderForArrest(c, missed: "Never appeared on \(heard)",
                                       note: "Never appeared on \(heard); order for arrest issued after the calendar call.")
                    }
                default:
                    setFor(c, weeks: 3, note: "Continued at the calendar call on \(heard) after a failure to appear; new notice sent.", continuances: 1)
                }
            case .firstAppearance, .bondModification:
                guard let bond = m.bond else { continue }
                // A bond hearing saved before every bond type took an amount had four options: promise, a fixed
                // unsecured bond, secured, secured with house arrest.
                var choice = choice
                if m.kind == .firstAppearance && m.options.count == 4 { choice = [0, 2, 3, 4][min(choice, 3)] }
                let set = amounts[m.id] ?? (m.options.count == 4 && choice == 2 ? bond.moderate : nil) ?? m.suggested(for: choice) ?? bond.moderate
                // Only a secured bond has to be posted; a promise, custody release, or unsecured bond releases the
                // defendant on signing.
                let amount: Int
                let monitored: Bool
                var watch: Double? = nil
                let condition: String
                if m.kind == .firstAppearance {
                    amount = choice >= 3 ? set : 0
                    monitored = choice == 4
                    if choice == 1 { watch = 0.7 }
                    condition = ["a written promise to appear", "release to the custody of a designated person",
                                 "a $\(set.formatted()) unsecured bond", "a $\(set.formatted()) secured bond",
                                 "a $\(set.formatted()) secured bond with electronic house arrest"][min(choice, 4)]
                } else {
                    amount = choice == 1 ? bond.moderate : (choice == 0 || choice == 2 ? set : 0)
                    monitored = choice == 2
                    condition = ["a new $\(set.formatted()) secured bond", "the $\(bond.moderate.formatted()) secured bond left in place",
                                 "a new $\(set.formatted()) secured bond with electronic house arrest", "a $\(set.formatted()) unsecured bond",
                                 "a written promise to appear"][min(choice, 4)]
                }
                // After a first appearance the case goes on to arraignment; a case already arraigned (a defendant
                // back on an order for arrest, or a bond review) waits for its trial date.
                let firstUp = m.kind == .firstAppearance && c.background?.arraigned != true
                func arraign(_ c: CourtCase, _ weeks: Int, _ note: String, _ n: Int) { queueArraignment(c, note: note, on: call.date) }
                decideRelease(c, bond: bond, amount: amount, monitored: monitored, condition: condition, heard: heard, date: call.date,
                              rng: &rng, schedule: firstUp ? arraign : schedule, watch: watch)
            case .arraignment:
                if choice == 0, let picked = dates[m.id] {
                    // The judge picks the day. Too soon, and the defense asks for more time.
                    var setCase = c
                    setCase.background?.arraigned = true
                    let days = CourtCalendar.calendar.dateComponents([.day], from: call.date, to: picked).day ?? 35
                    if days < 21 && c.charges.count > 1 && rng.chance(0.6) {
                        setCase.continuanceMotion = ContinuanceMotions.make(for: setCase, rng: &rng)
                    }
                    awaitCase(setCase, note: "Arraigned on \(heard); pleaded not guilty.", on: call.date)
                    if let id = awaiting.last?.id { setTrialDate(id, to: picked) }
                } else {
                    var arraigned = c
                    arraigned.background?.arraigned = true
                    setFor(arraigned, weeks: 2, note: "Arraigned on \(heard); pleaded not guilty. Trial date to be set.")
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
        // A violation hearing on probation from the vacated judgment has nothing left to hear.
        func onVacatedProbation(_ entry: DocketEntry) -> Bool {
            if case .hearing(let h) = entry.matter { return h.personID == relief.personID && h.probation.docket == relief.docket }
            return false
        }
        scheduled.removeAll { onVacatedProbation($0.entry) }
        if var day = today { day.entries.removeAll { $0.isOpen && onVacatedProbation($0) }; today = day }
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
                               date: Date, rng: inout SeededRNG, schedule: (CourtCase, Int, String, Int) -> Void, watch supervision: Double? = nil) {
        var held = c
        guard var bg = held.background else { schedule(c, rng.int(5...8), "Set for trial on \(heard).", 0); return }
        let kind = condition.contains("promise") ? "Written promise" : condition.contains("custody of") ? "Custody release"
            : condition.contains("unsecured") ? "Unsecured bond" : condition.contains("house arrest") ? "Secured bond with house arrest" : "Secured bond"
        var kinds = stats.bondKinds ?? [:]
        kinds[kind, default: 0] += 1
        stats.bondKinds = kinds
        if amount <= bond.canPost {
            // The days already spent in jail stay as credit; the clock stops while the defendant is out.
            bg.onRelease = true
            bg.heldOnCourtBond = false
            bg.bondStatus = "Released on \(condition) on \(heard)."
            held.background = bg
            // House arrest makes running and new arrests less likely.
            let watch = supervision ?? (monitored ? 0.4 : 1.0)
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
                bg.bondStatus = "Released on \(condition), then arrested on a new charge; bond revoked and held for \(bg.custodyDays) day\(bg.custodyDays == 1 ? "" : "s")."
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
                bg.bondStatus = "Released on \(condition); failed to appear and was arrested on an order for arrest. Bond doubled to $\(doubled.formatted()) secured; held for \(bg.custodyDays) day\(bg.custodyDays == 1 ? "" : "s")."
                held.background = bg
                held.sessionDate = arrested
                schedule(held, weeksOut + rng.int(3...6), "Missed the first trial setting after release; arrested on an order for arrest.", 0)
            } else {
                schedule(held, rng.int(5...8), "On release since \(heard).", 0)
            }
        } else {
            bg.custodyDays = max(1, bg.custodyDays)
            bg.onRelease = false
            bg.heldOnCourtBond = true
            stats.bondsNotPosted = (stats.bondsNotPosted ?? 0) + 1
            bg.bondStatus = "Held on \(condition) set on \(heard); unable to post it. In custody for \(bg.custodyDays) day\(bg.custodyDays == 1 ? "" : "s")."
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
        // The record of what was decided, for the Calendar tab in Records.
        for m in call.matters {
            let choice = choices[m.id] ?? 0
            var ruling = m.options.indices.contains(choice) ? m.options[choice] : "Ruled on"
            if let amount = amounts[m.id] {
                ruling = ruling.replacingOccurrences(of: "an amount you set", with: "$\(amount.formatted())")
            }
            calendarLog.insert(CalendarRuling(date: call.date, kind: m.kind, personName: m.personName, docket: m.docket,
                                              summary: m.summary, ruling: ruling), at: 0)
        }
        if calendarLog.count > 600 { calendarLog.removeLast(calendarLog.count - 600) }
        guard let county, let judgeName, stillOpen(call.id) else { return }
        let result = CalendarCalls.resolve(call, choices: choices, amounts: amounts, judgeName: judgeName, county: county)
        if !call.isBondSession { happened(.calendarCall(matters: call.matters.count)) }
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
        // Someone the judge terminates from treatment court goes to a violation hearing on the probation.
        for m in call.matters where m.kind == .treatmentReview && m.options.count == 4 && choices[m.id] == 3 {
            guard let person = people.first(where: { $0.id == m.personID }), person.probation != nil, !hasHearingSet(for: person.id) else { continue }
            var vrng = SeededRNG(seed: seedBase ^ SeededRNG.stableHash(m.docket + "tc"))
            fileViolationReport(person, text: "terminated from \(m.review?.program ?? "treatment court") for repeated setbacks: \(m.summary)",
                                contact: false, note: "Violation report filed after termination from \(m.review?.program ?? "treatment court").",
                                on: call.date, rng: &vrng)
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
        history.insert(CaseRecord(docket: call.isBondSession ? "Bond hearings" : "Calendar call",
                                  caption: call.isBondSession ? call.sessionTitle : "Administrative calendar call",
                                  headline: "\(call.matters.count) matters", category: .procedure, date: currentDate,
                                  defendantID: UUID(), outcome: "\(call.matters.count) matters handled", judgments: result.lines,
                                  returningDefendant: false, appealStatus: nil, kind: "calendar"), at: 0)
        let pleas = result.newPeople.count
        if !call.isBondSession {
        post(NewsItem(date: currentDate, kind: .community,
                      headline: "Judge \(lastName(judgeName)) works through crowded calendar",
                      body: "At an administrative session of Hollis County Superior Court, Judge \(lastName(judgeName)) handled \(call.matters.count) matters" + (pleas > 0 ? ", including \(pleas) guilty plea\(pleas == 1 ? "" : "s")." : "."),
                      prominence: 1))
        }
        finishEntry(matterID: call.id, outcome: "\(call.matters.count) matters handled")
        save()
    }

    private func makeViolationHearing(date: Date, excluding used: inout Set<UUID>, rng: inout SeededRNG) -> ViolationHearing? {
        guard let county else { return nil }
        let recentCutoff = CourtCalendar.calendar.date(byAdding: .day, value: -45, to: date) ?? date
        // Nobody racks up violations in their first two months: there has to be time to miss visits, fail screens, or fall behind.
        let settledCutoff = CourtCalendar.calendar.date(byAdding: .day, value: -60, to: date) ?? date
        let candidates = people.filter { person in
            // Only a supervised probationer has an officer to file a violation report.
            person.status == .probation
                && person.probation != nil
                && (person.probation.flatMap { ViolationHearings.probationStart(person, $0) } ?? .distantPast) < settledCutoff
                && (person.lastReleased ?? .distantPast) < settledCutoff
                && (person.probation?.supervised ?? true)
                && (person.appearances.last?.date ?? .distantPast) < recentCutoff
                && !used.contains(person.id)
        }
        // Who breaks probation follows who they are: a first offender usually keeps the conditions; someone with a long
        // record and a pull toward trouble usually doesn't.
        let risks = candidates.map { person -> Double in
            let base = person.probation?.violationRisk ?? 0.15
            let others = person.priors.filter { $0.docket == nil || $0.docket != person.probation?.docket }
            let felonies = others.filter { $0.ncClass.isFelony }.count
            let record: Double
            switch others.count {
            case 0: record = 0.25
            case 1...2: record = 0.8
            case 3...5: record = 1.4
            default: record = 1.9
            }
            return base * (record + 0.15 * Double(min(3, felonies))) * (0.6 + person.propensity * 1.4)
        }
        let total = risks.reduce(0, +)
        // Officers carrying too many cases catch fewer violations.
        guard total > 0, rng.chance(min(0.7, total * 0.5 / max(1, probationOverload))) else { return nil }
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
        // Names the county already knows; new people never share them.
        var reserved = Set(residents.map(\.name)).union(living.owners.values).union(officerRecords.keys)
        reserved.formUnion(Gazetteer.regulars(for: county).values)
        // Everyone already in the world, past defendants included: a new person never shares a full name with them.
        // (A returning defendant or a former witness charged later keeps their own name; that's the same person.)
        reserved.formUnion(namesInPlay())
        context.reservedNames = reserved
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
        guard var newCase = best?.value else { return nil }
        applyTrackRecords(&newCase, rng: &rng)
        // Now and then something happens in the courtroom that needs a ruling on the spot.
        if newCase.incidents == nil && !generic { newCase.incidents = Incidents.make(for: newCase, rng: &rng) }
        rememberOwners(newCase)
        recentLineKeys.append(contentsOf: CaseAuditor.lineKeys(newCase))
        if recentLineKeys.count > 2_500 { recentLineKeys.removeFirst(recentLineKeys.count - 2_500) }
        used.insert(newCase.defendant.personID)
        namesIssued.insert(newCase.defendant.name)
        if let v = newCase.victimName { namesIssued.insert(v) }
        newCase.witnesses.forEach { namesIssued.insert($0.name) }
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

    /// Appointed counsel asks to get off a case set for trial here: too many files, a new job with the DA, a grievance,
    /// a conflict just discovered. A real conflict requires letting counsel go; a caseload is the court's call.
    private func counselWithdrawal(on date: Date, excluding used: Set<UUID>, rng: inout SeededRNG) -> CalendarMatter? {
        guard rng.chance(min(0.3, 0.12 * caseloadPressure)) else { return nil }
        let pool = (scheduled.filter { $0.entry.resume == nil && $0.date > date }.map(\.entry) + awaiting.map(\.entry)).compactMap { e -> CourtCase? in
            guard case .trial(let c) = e.matter, c.templateKey.hasPrefix("story."), !used.contains(c.defendant.personID),
                  !(c.incidents ?? []).contains(where: { $0.title.contains("renews the motion to withdraw") }) else { return nil }
            return c
        }
        guard let c = pool.isEmpty ? nil : rng.pick(pool) else { return nil }
        let counsel = c.defenseAttorney.components(separatedBy: ", ").first ?? c.defenseAttorney, d = c.defendant
        let retained = c.defenseAttorney.contains("retained")
        let grounds: [(String, Bool, String)] = [
            (retained ? "\(counsel) says \(d.lastName) hasn't paid the fee in four months and has stopped returning calls." : "\(counsel) is carrying \(rng.int(140...190)) open felony files and says this one can't be prepared properly in time.", false,
             "A heavy caseload is for the court to weigh; it isn't a conflict that requires withdrawal."),
            ("\(counsel) has accepted a job with the District Attorney's office starting next month.", true,
             "A defense lawyer joining the prosecutor's office has a conflict; withdrawal is required."),
            ("\(d.name) has filed a State Bar grievance against \(counsel), and \(counsel) says they no longer speak.", true,
             "A complete breakdown in communication, with a pending grievance, is good cause for new counsel."),
            ("\(counsel) represented one of the State's witnesses in an earlier case and only just learned it.", true,
             "Prior representation of a State witness is a conflict of interest; withdrawal should be allowed."),
            ("\(d.name) says \(counsel) hasn't visited the jail in two months; \(counsel) says \(d.lastName) won't take calls.", false,
             "A disagreement over contact or strategy isn't good cause for new appointed counsel by itself.")]
        let g = rng.pick(grounds)
        return CalendarMatter(
            kind: .counselWithdrawal, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation, docket: c.docket,
            summary: "\(counsel), \(retained ? "hired to defend \(d.name)" : "appointed to represent \(d.name)") on \(c.charges.first?.law.title.lowercased() ?? "the charges"), moves to withdraw. \(g.0)",
            stateAsk: rng.pick(["The State is ready for trial and objects to any delay.", "The State takes no position on who represents the defendant.",
                                "The State asks that any new lawyer be ready by the current trial date."]),
            defenseAsk: "\(counsel): \(rng.pick(["I can't give this client the representation the Constitution requires.", "I'd ask the court to let me out and appoint someone who can do this right.", "I've never asked to withdraw from a case in fifteen years. I'm asking now."]))",
            options: retained
                ? ["Allow withdrawal; give \(d.lastName) time to hire a new lawyer (about six weeks)",
                   "Allow withdrawal; appoint the public defender if \(d.lastName) can't afford one (about three weeks)",
                   "Deny: \(counsel) stays on the case"]
                : ["Allow withdrawal; appoint the next lawyer on the list (about six weeks to get ready)",
                   "Allow withdrawal; ask Indigent Defense Services for a private lawyer (about three weeks)",
                   "Deny: \(counsel) stays on the case"],
            lawID: "rightToCounsel", pendingCase: c,
            petition: PetitionFacts(eligible: g.1, reason: g.2))
    }

    /// Treatment court participants due for a review (every six weeks or so) report to the judge at the calendar call.
    private func treatmentCourtMatters(on date: Date, excluding used: Set<UUID>, rng: inout SeededRNG) -> [CalendarMatter] {
        let cal = CourtCalendar.calendar
        let horizon = cal.date(byAdding: .day, value: 6, to: date) ?? date
        var out: [CalendarMatter] = []
        for index in people.indices where people[index].status == .probation && !used.contains(people[index].id) {
            guard let term = people[index].probation, term.treatmentCourt != nil, term.courtGraduated != true else { continue }
            if term.courtReviewDue == nil {
                let start = term.starts ?? people[index].appearances.last?.date ?? date
                people[index].probation?.courtReviewDue = cal.date(byAdding: .day, value: 42, to: start)
                people[index].probation?.courtPhase = 1
            }
            guard let due = people[index].probation?.courtReviewDue, due <= horizon, out.count < 3,
                  let current = people[index].probation,
                  let m = TreatmentCourts.reviewMatter(people[index], term: current, date: date, rng: &rng) else { continue }
            out.append(m)
        }
        return out
    }

    /// This week's petitions, mostly from people the court already knows: someone with an old conviction asking to
    /// clear it, a bonding company after a missed court date, someone convicted of DWI asking to drive to work.
    /// Bond forfeitures and driving privileges only for people the court already knows; an expunction can come from
    /// anyone with an old record.
    private func petitionMatters(on date: Date, excluding used: Set<UUID>, rng: inout SeededRNG) -> [CalendarMatter] {
        guard let county else { return [] }
        let cal = CourtCalendar.calendar
        let year = cal.component(.year, from: date)
        var out: [CalendarMatter] = []
        var taken = used
        var names = namesInPlay()
        // An expunction petitioner the court hasn't seen: someone with an old record and nothing since.
        func fresh(age: ClosedRange<Int>) -> (UUID, String, Int, String) {
            let avoid = names
            let name = NameBank.person(using: &rng, excluding: &names, avoiding: avoid)
            namesIssued.insert(name)
            return (UUID(), name, rng.int(age), rng.pick(NameBank.occupations).capitalizedFirst)
        }
        func docket() -> String {
            docketSequence += rng.int(20...200)
            return "\(year % 100) CRS \(String(format: "%06d", docketSequence))"
        }

        if rng.chance(0.35) {
            // Someone with an old conviction and nothing since.
            let known = people.filter { p in
                p.status == .free && p.probation == nil && !taken.contains(p.id) && !p.priors.isEmpty
                    && (p.appearances.last.map { (cal.dateComponents([.year], from: $0.date, to: date).year ?? 0) >= 1 } ?? true)
            }
            if let p = known.isEmpty || rng.chance(0.5) ? nil : rng.pick(known) {
                docketSequence += 10
                if let m = Petitions.expunctionMatter(personID: p.id, name: p.name, age: p.age(on: date), occupation: p.occupation, priors: p.priors,
                                                      year: year, newPerson: false, docketSequence: docketSequence, rng: &rng) {
                    out.append(m); taken.insert(p.id)
                }
            } else {
                let (id, name, age, job) = fresh(age: 24...60)
                let offenses: [(String, NCClass, String)] = [
                    ("Misdemeanor Larceny", .misd1, "45 days suspended, 12 months probation"), ("Possession of Marijuana", .misd1, "Fine and costs"),
                    ("Worthless Check", .misd2, "Fine and restitution"), ("Possession of Stolen Goods", .H, "6 to 17 months suspended"),
                    ("Breaking or Entering a Motor Vehicle", .I, "4 to 14 months suspended"), ("Simple Assault", .misd2, "30 days suspended"),
                    ("Driving While Impaired", .misd1, "Level 5"), ("Obtaining Property by False Pretenses", .H, "6 to 17 months suspended"),
                    ("Assault with a Deadly Weapon", .misdA1, "60 days suspended")]
                var priors: [PriorConviction] = []
                let first = rng.pick(offenses)
                priors.append(PriorConviction(offense: first.0, ncClass: first.1, year: year - rng.int(3...16), county: rng.pick(["Hollis", "Robeson", "Brunswick", "Onslow", "Pender"]), sentence: first.2))
                if rng.chance(0.25) {
                    let second = rng.pick(offenses)
                    priors.append(PriorConviction(offense: second.0, ncClass: second.1, year: year - rng.int(8...22), county: "Hollis", sentence: second.2))
                }
                docketSequence += 10
                if let m = Petitions.expunctionMatter(personID: id, name: name, age: max(age, 18 + (year - priors.map(\.year).min()!)), occupation: job,
                                                      priors: priors, year: year, newPerson: true, docketSequence: docketSequence, rng: &rng) {
                    out.append(m)
                }
            }
        }
        if rng.chance(0.25) {
            // A missed court date on a bond: someone with an order for arrest, or a case the court hasn't seen.
            let missed = people.filter { p in !taken.contains(p.id) && p.appearances.contains { $0.charges.lowercased().contains("failure to appear") || $0.outcome.lowercased().contains("order for arrest") } }
            if let p = missed.isEmpty ? nil : rng.pick(missed) {
                let d = p.appearances.last(where: { $0.outcome.lowercased().contains("order for arrest") })?.docket ?? p.appearances.last?.docket ?? docket()
                out.append(Petitions.forfeitureMatter(personID: p.id, name: p.name, age: p.age(on: date), occupation: p.occupation,
                                                      docket: d.replacingOccurrences(of: " (forfeiture)", with: ""), date: date, newPerson: false, rng: &rng))
                taken.insert(p.id)
            }
        }
        if rng.chance(0.25) {
            // A DWI conviction in the past year.
            let drivers = people.compactMap { p -> (PersonRecord, PersonRecord.Appearance)? in
                guard p.status != .incarcerated, !taken.contains(p.id),
                      let a = p.appearances.last(where: { $0.charges.contains("Driving While Impaired") && !$0.outcome.lowercased().contains("not guilty") }),
                      (cal.dateComponents([.day], from: a.date, to: date).day ?? 999) <= 365,
                      !p.appearances.contains(where: { $0.charges.contains("limited driving privilege") && $0.docket.hasPrefix(a.docket) }) else { return nil }
                return (p, a)
            }
            if let (p, a) = drivers.isEmpty ? nil : rng.pick(drivers) {
                let level = a.outcome.range(of: "Level [1-5]", options: .regularExpression).flatMap { Int(a.outcome[$0].suffix(1)) }
                out.append(Petitions.privilegeMatter(personID: p.id, name: p.name, age: p.age(on: date), occupation: p.occupation, docket: a.docket,
                                                     level: level, convicted: a.date, date: date, propensity: p.propensity, newPerson: false, rng: &rng))
                taken.insert(p.id)
            }
        }
        return Array(out.prefix(2))
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
        recordTrackRecords(courtCase, outcome: outcome)
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
        // What the judgment did with the defendant, to follow later.
        if let index = people.firstIndex(where: { $0.id == d.personID }) {
            let p = people[index]
            var group: DispositionRecord.Group?
            if p.status == .incarcerated && p.custodyDocket == courtCase.docket {
                group = p.custodyPlace == .jail ? .jail : (p.custodyPlace == .prison ? .prison : nil)
            } else if !outcome.convicted {
                group = .acquitted
            } else {
                group = outcome.newProbation != nil ? .probation : .noCustody
            }
            if let group {
                let free = group == .jail || group == .prison ? nil : currentDate
                dispositions.append(DispositionRecord(personID: d.personID, docket: courtCase.docket, group: group, date: currentDate, freeFrom: free))
                if dispositions.count > 6_000 { dispositions.removeFirst(dispositions.count - 6_000) }
                if group == .prison { corrections?.prisonAdmissions.append(currentDate) }
            }
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
        // The community takes the ruling the way it felt going in, and remembers.
        let reaction = Community.reaction(courtCase, convicted: outcome.convicted, active: activeImposed, position: outcome.sentencePosition,
                                          judgeLast: judgeName.map(lastName) ?? "the judge", date: currentDate)
        if let news = reaction.news {
            stats.communityStanding = (stats.communityStanding ?? 0) + reaction.delta
            post(news)
        }
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
        calendarLog = []
        freshAppeals = []
        schedule = CourtSchedule()
        awaiting = []
        weekTally = CourtDay.Tally()
        mood = CourthouseMood()
        investigations = []
        bondQueue = []
        showCauseQueue = []
        corrections = nil
        dispositions = []
        arraignQueue = []
        placeHistory = [:]
        residents = []
        officerRecords = [:]
        lawyerRecords = [:]
        living = LivingCounty()
        Gazetteer.living = living
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
                          headline: order.heldCase != nil ? "\(order.personName), wanted since \(SentenceFormat.shortDate(order.issued)), back in custody"
                              : "\(order.personName) arrested on order for failing to appear",
                          body: (order.how.map { "\($0). " } ?? "") + "Deputies served an order for arrest on \(order.personName), who missed a court date in Hollis County Superior Court on a charge of \(order.offense.lowercasedPhrase). \(order.personName.components(separatedBy: " ").last ?? order.personName) is held until a bond hearing.",
                          docket: order.docket, prominence: 1))
            // The case file catches up: the defendant is now in custody on the order.
            let served = SentenceFormat.shortDate(order.servedOn)
            func update(_ entry: inout DocketEntry) {
                guard case .trial(var c) = entry.matter, c.docket == order.docket, var bg = c.background else { return }
                bg.bondStatus = "Arrested on the order for arrest on \(served) after failing to appear on \(SentenceFormat.shortDate(order.issued)); held on \(order.bond)."
                c.background = bg
                entry.matter = .trial(c)
                entry.note = ((entry.note ?? "") + " Served \(served); in custody.").trimmingCharacters(in: .whitespaces)
            }
            for j in awaiting.indices { update(&awaiting[j].entry) }
            for j in scheduled.indices { update(&scheduled[j].entry) }
            // Once served, the defendant comes before the court at the next bond hearing; after the judge sets
            // conditions, the case waits for a trial date like any other.
            if var c = order.heldCase {
                if var bg = c.background {
                    bg.arraigned = true
                    bg.onRelease = false
                    bg.bondStatus = "\(order.how ?? "Arrested on the order for arrest") on \(served) after failing to appear on \(SentenceFormat.shortDate(order.issued)); held pending a bond hearing."
                    c.background = bg
                }
                c.sessionDate = order.servedOn
                let town = c.investigation?.facts?.town ?? county?.seat ?? ""
                bondQueue.append(OpenInvestigation(courtCase: c, incident: c.investigation?.facts?.incident ?? order.issued,
                                                   arrest: order.servedOn, town: town, offense: order.offense, ready: order.servedOn,
                                                   note: "\(order.how ?? "Arrested") on \(served) on the order for arrest issued \(SentenceFormat.shortDate(order.issued)) after a failure to appear."))
                arrestOrders[i].heldCase = nil
            }
        }

        // Scheduled events
        let due = pending.filter { $0.due <= currentDate }.sorted { $0.due < $1.due }
        pending.removeAll { $0.due <= currentDate }
        for event in due {
            // Nobody is arrested for something new while locked up: news of a new arrest, and the case it would bring,
            // fall away for a person in custody when the day comes.
            // A court-order violation was already an arrest (saves from before it went straight to the docket), so it stays.
            let alreadyArrested = event.reoffense?.note.hasPrefix("Charged with violating") ?? false
            if event.effect == .none, !alreadyArrested, event.reoffense != nil || event.news.kind == .arrest,
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
            if let personID = event.personID, event.reoffense != nil || item.kind == .arrest {
                noteRearrest(personID, on: event.due)
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
        updateCorrections(on: date, rng: &rng)
        if weekly { weatherAndAssignments(on: date, rng: &rng) }
        // The county changes week to week.
        if weekly {
            if let item = CountyLife.week(&living, on: date, placeHistory: placeHistory, rng: &rng) { post(item) }
            Gazetteer.living = living
        }

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
                    if let program = probation.treatmentCourt, probation.courtGraduated != true {
                        post(NewsItem(date: probation.ends, kind: .community,
                                      headline: "\(person.name) graduates from Hollis County \(program)",
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

    /// Whether a violation hearing for this person is already on the calendar.
    private func hasHearingSet(for personID: UUID) -> Bool {
        let entries = (today?.entries ?? []) + scheduled.map(\.entry)
        return entries.contains { if case .hearing(let h) = $0.matter { return h.personID == personID } else { return false } }
    }

    /// The probation officer reports a new arrest; the hearing goes on the next day the judge sits.
    private func fileViolationReport(_ person: PersonRecord, text: String, contact: Bool, note: String, on date: Date, rng: inout SeededRNG) {
        guard let county, let hearing = ViolationHearings.make(person: person, county: county, date: date, seed: rng.next(),
                                                               newCharge: (text: text, contact: contact)) else { return }
        place(DocketEntry(matter: .hearing(hearing), note: note), from: nextSittingDay(after: date))
    }

    /// Each week, anyone free under a stay-away order this court entered may break it. A violation is news, and
    /// the new charge comes back to this courtroom.
    // MARK: - Storms and assignments

    /// Once a week: a hurricane (August through October) or an ice storm (January and February) may close the
    /// courthouse, and once each half-year the Chief Justice assigns the judge to a week of court in a neighboring
    /// county. Nothing is heard here on those days; whatever was set moves to the next days with room.
    private func weatherAndAssignments(on date: Date, rng: inout SeededRNG) {
        guard let judgeName else { return }
        let cal = CourtCalendar.calendar
        let month = cal.component(.month, from: date)
        let year = cal.component(.year, from: date)
        let judgeLast = lastName(judgeName)
        let closures = schedule.closures ?? [:]
        func near(_ word: String, days: Int) -> Bool {
            closures.contains { key, reason in
                reason.contains(word) && (CourtSchedule.date(key).map { abs(cal.dateComponents([.day], from: $0, to: date).day ?? 999) <= days } ?? false)
            }
        }
        /// The next `count` days the court would otherwise sit, from `start`.
        func sittingDays(from start: Date, count: Int, within: Int = 10) -> [Date] {
            var out: [Date] = []
            var day = cal.startOfDay(for: start)
            for _ in 0..<within where out.count < count {
                if schedule.sits(on: day) { out.append(day) }
                day = cal.date(byAdding: .day, value: 1, to: day) ?? day
            }
            return out
        }
        func close(_ days: [Date], _ reason: String) {
            var all = schedule.closures ?? [:]
            for d in days { all[CourtSchedule.key(d)] = reason }
            schedule.closures = all
            reflow(note: reason)
        }
        let span = { (days: [Date]) -> String in
            days.count == 1 ? SentenceFormat.shortDate(days[0]) : "\(SentenceFormat.shortDate(days.first!)) through \(SentenceFormat.shortDate(days.last!))"
        }

        if (8...10).contains(month) && !near("Hurricane", days: 60) && rng.chance(0.07) {
            let name = rng.pick(["Arlene", "Bertha", "Colin", "Dorian", "Earl", "Florence", "Gaston", "Hermine", "Isaias", "Josephine", "Kyle", "Leah"])
            let landfall = cal.date(byAdding: .day, value: rng.int(3...5), to: date) ?? date
            let days = sittingDays(from: landfall, count: rng.int(2...4))
            if !days.isEmpty {
                close(days, "Courthouse closed: Hurricane \(name)")
                let town = rng.pick(["Port Hollis", "Harbor Point", "Bayard"])
                post(NewsItem(date: date, kind: .community, headline: "Hurricane \(name) on track for the Hollis County coast",
                              body: "Forecasters expect Hurricane \(name) to come ashore near \(town) on \(SentenceFormat.shortDate(landfall)). The clerk of court says the courthouse will close \(span(days)), and every case set those days will be reset. The sheriff says the jail will stay staffed through the storm.",
                              prominence: 2))
                pending.append(PendingEvent(due: landfall, news: NewsItem(date: landfall, kind: .community,
                    headline: "Hurricane \(name) floods \(town) waterfront",
                    body: "Storm surge pushed water three feet deep onto Water Street, and thousands are without power across the county. Deputies moved inmates from the jail's ground floor overnight. The courthouse is closed.")))
                if let back = days.last.flatMap({ cal.date(byAdding: .day, value: 1, to: $0) }) {
                    pending.append(PendingEvent(due: back, news: NewsItem(date: back, kind: .community,
                        headline: "Courthouse reopens after Hurricane \(name)",
                        body: "The clerk's office says cases set during the closure have been moved to the next open days on Judge \(judgeLast)'s calendar. Defendants held in the jail waited \(days.count) more court day\(days.count == 1 ? "" : "s") for their hearings. Some witnesses are still displaced.")))
                }
            }
        }

        if (month == 1 || month == 2) && !near("ice", days: 40) && rng.chance(0.03) {
            let days = sittingDays(from: cal.date(byAdding: .day, value: 1, to: date) ?? date, count: 1)
            if !days.isEmpty {
                close(days, "Courthouse closed: ice on the roads")
                post(NewsItem(date: date, kind: .community, headline: "Ice storm closes courthouse",
                              body: "Freezing rain coated roads across Hollis County overnight. The courthouse is closed \(span(days)); cases set that day will be reset by the clerk."))
            }
        }

        let halfStart = month <= 6 ? 1 : 7
        let assigned = closures.contains { key, reason in
            reason.hasPrefix("Holding court in") && (CourtSchedule.date(key).map {
                cal.component(.year, from: $0) == year && (halfStart..<(halfStart + 6)).contains(cal.component(.month, from: $0)) } ?? false)
        }
        if !assigned && (month == halfStart || month == halfStart + 1) && rng.chance(0.3) {
            let other = rng.pick(["Pender", "Columbus", "Bladen", "Brunswick", "Robeson"])
            let start = CourtCalendar.monday(onOrAfter: cal.date(byAdding: .day, value: 21, to: date) ?? date)
            let days = sittingDays(from: start, count: 5, within: 5)
            if !days.isEmpty {
                close(days, "Holding court in \(other) County")
                post(NewsItem(date: date, kind: .community, headline: "Judge \(judgeLast) assigned to a week of court in \(other) County",
                              body: "The Chief Justice has assigned Judge \(judgeName) to hold a one-week criminal session in \(other) County, \(span(days)), to help with a backlog of felony cases there. Superior court judges in North Carolina rotate among counties. Cases set in Hollis County that week will be moved."))
                if let end = days.last {
                    let cleared = rng.int(9...18)
                    pending.append(PendingEvent(due: end, news: NewsItem(date: end, kind: .community,
                        headline: "Judge \(judgeLast) clears \(cleared) cases in \(other) County session",
                        body: "In a week holding court in \(other) County, Judge \(judgeLast) took \(cleared) pleas and tried two cases, the \(other) County clerk said. The judge returns to the Hollis County calendar next week.")))
                }
            }
        }
    }

    private func checkStayAwayOrders(rng: inout SeededRNG) {
        guard let judgeName else { return }
        for index in people.indices where people[index].status != .incarcerated {
            guard var orders = people[index].stayAwayOrders, !orders.isEmpty else { continue }
            // Someone already facing a new case isn't arrested on another violation before it's heard.
            let personID = people[index].id
            if reoffenseQueue.contains(where: { $0.personID == personID }) || pending.contains(where: { $0.reoffense?.personID == personID })
                || showCauseQueue.contains(where: { $0.personID == personID }) { continue }
            // A new order isn't tested in its first month.
            let settled = CourtCalendar.calendar.date(byAdding: .day, value: -30, to: currentDate) ?? currentDate
            for o in orders.indices where orders[o].issued < settled && orders[o].expires > currentDate {
                // Tested weekly: a typical person under an order has about a one-in-four chance of breaking it in
                // the first year (a bit more in domestic cases, more for someone with a long record).
                let risk = (orders[o].domestic ? 0.007 : 0.005) * (0.5 + people[index].propensity * 2.5)
                guard rng.chance(min(0.025, risk)) else { continue }
                orders[o].violations += 1
                stats.orderViolations = (stats.orderViolations ?? 0) + 1
                let person = people[index], order = orders[o]
                // The case comes first, so the news describes the same violation the trial will be about.
                let kinds = Consequences.violationTemplates(domestic: order.domestic)
                // Only a case written for this person (age, and the defendant's sex where the case fixes it), so the
                // trial is the same violation the paper reports.
                let sex = NameBank.gender(of: person.name)
                let fitting = kinds.filter { key in
                    FollowUpCases.fits(key, age: person.age(on: currentDate))
                        && (FollowUpCases.all.first { $0.key == key }?.requiredGenders["D"].map { $0 == sex } ?? true)
                }
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
                              body: "Deputies say \(person.name) \(what), in violation of the \(order.label) Judge \(lastName(judgeName)) imposed in \(order.docket) on \(SentenceFormat.shortDate(order.issued)). \(person.status == .probation && person.probation != nil ? "\(person.lastName), who is on probation, is being held for a probation violation hearing before Judge \(lastName(judgeName))." : "\(person.lastName) has been ordered to appear before Judge \(lastName(judgeName)) to show cause why \(person.lastName) should not be held in contempt.")",
                              docket: order.docket, prominence: 2))
                // On probation, the violation goes back to the judge who set the conditions as a violation hearing,
                // where the judge hears the officer and the probationer and can revoke; there's no separate trial.
                if person.status == .probation, person.probation != nil {
                    if !hasHearingSet(for: person.id) {
                        fileViolationReport(person, text: "arrested for violating the \(order.label) protecting \(order.protectedName) (\(order.docket)): \(person.lastName) \(what). The State proceeds on it at this hearing rather than as a separate prosecution.",
                                            contact: true, note: "Violation report filed after \(person.lastName)'s arrest for violating the \(order.label) in \(order.docket).",
                                            on: currentDate, rng: &rng)
                    }
                    break
                }
                // Not on probation: a short hearing on contempt of the court's order, not a new trial.
                var mrng = SeededRNG(seed: rng.next())
                showCauseQueue.append(CalendarCalls.contemptMatter(person: person, order: order, conduct: what, date: currentDate, rng: &mrng))
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
        people[index].stateBedDate = nil
        people[index].stateBedDocket = nil
        if let d = dispositions.lastIndex(where: { $0.personID == person.id && $0.freeFrom == nil }) { dispositions[d].freeFrom = release }
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

    // MARK: Corrections

    /// Supervised probationers this court placed, per officer, against the caseload officers are meant to carry.
    var probationOverload: Double {
        guard let state = corrections else { return 0 }
        let count = people.filter { $0.status == .probation && ($0.probation?.imposedInThisCourt ?? false) && ($0.probation?.supervised ?? true) }.count
        return Double(count) / Double(max(1, state.officers * Corrections.caseloadPerOfficer))
    }

    /// Cases this court heard in the past year: a young court counts what it expects to hear.
    private func casesHeardLastYear(on date: Date) -> Int {
        let cal = CourtCalendar.calendar
        let yearAgo = cal.date(byAdding: .year, value: -1, to: date) ?? date
        let heard = history.filter { $0.date > yearAgo && ($0.resolvedKind == "trial" || $0.resolvedKind == "hearing") }.count
        let span = cal.dateComponents([.day], from: max(careerStart, yearAgo), to: date).day ?? 365
        guard span >= 120 else { return max(180, heard * 365 / max(span, 1)) }
        return heard * 365 / min(max(span, 1), 365)
    }

    /// Defendants waiting for trial in the jail because this judge set a bond they couldn't post, one case per person.
    private func heldForTrial() -> [CourtCase] {
        var seen = Set<UUID>()
        var held: [CourtCase] = []
        let entries = (today?.entries.filter(\.isOpen) ?? []) + scheduled.map(\.entry) + awaiting.map(\.entry)
        var cases = entries.compactMap { entry -> CourtCase? in
            if case .trial(let c) = entry.matter { return c } else { return nil }
        }
        cases += arraignQueue.map(\.courtCase)
        for c in cases {
            guard let bg = c.background, bg.isJailed, bg.heldOnCourtBond == true,
                  person(c.defendant.personID)?.status != .incarcerated, seen.insert(c.defendant.personID).inserted else { continue }
            held.append(c)
        }
        return held
    }

    /// Everyone in the county jail tonight because of this court: sentenced, waiting for a prison bed, or held for trial.
    func jailRoster() -> [JailInmate] {
        let date = currentDate
        var roster: [JailInmate] = []
        var seen = Set<UUID>()
        for p in people where p.inCountyJail(on: date) {
            seen.insert(p.id)
            let docket = p.custodyDocket ?? p.appearances.last?.docket ?? ""
            let appearance = p.appearances.last { $0.docket == docket } ?? p.appearances.last
            let charge = appearance?.charges.components(separatedBy: ", ").first ?? "Unknown charge"
            let felony = p.priors.last { $0.docket == docket }?.ncClass.isFelony ?? (p.custodyPlace == .prison)
            let violent = Corrections.soundsViolent(appearance?.charges ?? charge)
            let orders = p.activeOrders(on: date).count
            let failures = (p.violations?.count ?? 0) + p.priors.filter { $0.offense.lowercased().contains("failure to appear") }.count
            var flags: [String] = []
            if violent { flags.append("Violent charge") }
            if orders > 0 { flags.append("Stay-away order in force") }
            if p.priors.count > 1 { flags.append("\(p.priors.count) convictions on record") }
            if failures > 0 { flags.append("\(failures) supervision violation\(failures == 1 ? "" : "s") or missed court date\(failures == 1 ? "" : "s")") }
            let awaiting = p.awaitingStateBed(on: date)
            roster.append(JailInmate(personID: p.id, caseID: nil, name: p.name, age: p.age(on: date), docket: docket, charge: charge,
                                     kind: awaiting ? .awaitingBed : .sentenced, since: appearance?.date, releaseDate: p.releaseDate,
                                     bedDate: p.stateBedDocket == p.custodyDocket ? p.stateBedDate : nil, bond: nil,
                                     violent: violent, felony: felony, priors: p.priors.count,
                                     risk: Corrections.risk(violent: violent, felony: felony, priors: p.priors.count, orders: orders, failures: failures),
                                     flags: flags))
        }
        for c in heldForTrial() where !seen.contains(c.defendant.personID) {
            let d = c.defendant
            let charge = c.charges.first?.law.title ?? "Unknown charge"
            let violent = [LawCategory.violent, .robbery, .family].contains(c.category) || Corrections.soundsViolent(charge)
            let felony = c.charges.contains { $0.law.ncClass?.isFelony ?? false }
            let orders = person(d.personID)?.activeOrders(on: date).count ?? 0
            let failures = d.priors.filter { $0.offense.lowercased().contains("failure to appear") }.count
            let days = max(1, c.background?.custodyDays ?? 1)
            let since = c.investigation?.facts?.arrest ?? CourtCalendar.calendar.date(byAdding: .day, value: -days, to: date)
            var flags: [String] = []
            if violent { flags.append("Violent charge") }
            if felony { flags.append("Felony charge") }
            if orders > 0 { flags.append("Stay-away order in force") }
            if !d.priors.isEmpty { flags.append("\(d.priors.count) prior conviction\(d.priors.count == 1 ? "" : "s")") }
            if failures > 0 { flags.append("\(failures) earlier failure\(failures == 1 ? "" : "s") to appear") }
            roster.append(JailInmate(personID: d.personID, caseID: c.id, name: d.name, age: d.age, docket: c.docket, charge: charge,
                                     kind: .pretrial, since: since, releaseDate: nil, bedDate: nil, bond: c.background?.bondStatus,
                                     violent: violent, felony: felony, priors: d.priors.count,
                                     risk: Corrections.risk(violent: violent, felony: felony, priors: d.priors.count, orders: orders, failures: failures),
                                     flags: flags))
        }
        return roster
    }

    /// A new county starts its own jail and probation office; the judge's record goes along.
    private func ensureCorrections(on date: Date) {
        guard let county, corrections?.countyName != county.name else { return }
        let cases = casesHeardLastYear(on: date)
        corrections = CorrectionsState(countyName: county.name, beds: Corrections.beds(casesPerYear: cases),
                                       officers: Corrections.officers(casesPerYear: cases),
                                       budgetYear: CourtCalendar.calendar.component(.year, from: date))
    }

    /// Counts the jail, prison, and probation each day, assigns state prison beds, and runs the sheriff's notices.
    private func updateCorrections(on date: Date, rng: inout SeededRNG) {
        guard let county else { return }
        let cal = CourtCalendar.calendar
        let year = cal.component(.year, from: date)
        ensureCorrections(on: date)
        guard var state = corrections else { return }
        if let last = state.lastDay, cal.isDate(last, inSameDayAs: date) { return }

        // The county budget grows the jail and the probation office with the court's caseload, never shrinks them.
        if let budget = state.budgetYear, year > budget {
            let cases = casesHeardLastYear(on: date)
            let beds = max(state.beds, Corrections.beds(casesPerYear: cases))
            let officers = max(state.officers, Corrections.officers(casesPerYear: cases))
            if beds > state.beds || officers > state.officers {
                var parts: [String] = []
                if beds > state.beds { parts.append("\(beds - state.beds) jail bed\(beds - state.beds == 1 ? "" : "s")") }
                if officers > state.officers { parts.append("\(officers - state.officers) probation officer\(officers - state.officers == 1 ? "" : "s")") }
                post(NewsItem(date: date, kind: .community, headline: "County budget adds \(parts.joined(separator: " and "))",
                              body: "The \(county.name) commissioners' new budget adds \(parts.joined(separator: " and ")) to keep pace with the Superior Court's caseload. The jail now has \(beds) beds for the court's defendants, and \(officers) officer\(officers == 1 ? "" : "s") supervise the court's probationers.",
                              prominence: 1))
            }
            state.beds = beds
            state.officers = officers
            state.budgetYear = year
            state.yearDaysOver = 0
            state.yearBedDays = 0
        }

        // A prison commitment waits in the county jail until the state has a bed.
        let recentCutoff = cal.date(byAdding: .day, value: -60, to: date) ?? date
        let yearCutoff = cal.date(byAdding: .day, value: -365, to: date) ?? date
        state.prisonAdmissions.removeAll { $0 < yearCutoff }
        let recent = state.prisonAdmissions.filter { $0 >= recentCutoff }.count
        for i in people.indices where people[i].custodyPlace == .prison {
            guard people[i].stateBedDate == nil || people[i].stateBedDocket != people[i].custodyDocket else { continue }
            let docket = people[i].custodyDocket ?? ""
            let committed = people[i].appearances.last { $0.docket == docket }?.date ?? date
            let wait = Corrections.stateBedWait(personID: people[i].id, docket: docket, recentAdmissions: recent)
            people[i].stateBedDate = cal.date(byAdding: .day, value: wait, to: cal.startOfDay(for: committed))
            people[i].stateBedDocket = people[i].custodyDocket
        }

        let inJail = people.filter { $0.inCountyJail(on: date) }
        let awaitingBed = inJail.filter { $0.awaitingStateBed(on: date) }.count
        let pretrial = heldForTrial().count
        let jail = inJail.count + pretrial
        let prison = people.filter { $0.custodyPlace == .prison && !$0.awaitingStateBed(on: date) }.count
        let probation = people.filter { $0.status == .probation && ($0.probation?.imposedInThisCourt ?? false) && ($0.probation?.supervised ?? true) }.count
        let postRelease = people.filter { $0.status != .incarcerated && $0.postRelease != nil }.count

        stats.jailBedDays = (stats.jailBedDays ?? 0) + jail
        stats.prisonBedDays = (stats.prisonBedDays ?? 0) + prison
        stats.probationDays = (stats.probationDays ?? 0) + probation
        state.bedDays += jail
        state.yearBedDays += jail
        if jail > state.beds {
            state.daysOver += 1
            state.yearDaysOver += 1
            stats.crowdingStrain = (stats.crowdingStrain ?? 0) + 1
            stats.crowdedDays = (stats.crowdedDays ?? 0) + 1
        }
        // An overloaded probation office strains the county too, at half the weight of a full jail.
        if Double(probation) > Double(state.officers * Corrections.caseloadPerOfficer) && state.log.count % 2 == 0 {
            stats.crowdingStrain = (stats.crowdingStrain ?? 0) + 1
        }
        if jail > state.peak {
            state.peak = jail
            state.peakDate = date
        }
        state.log.append(CorrectionsDay(date: date, jail: jail, pretrial: pretrial, sentenced: inJail.count - awaitingBed,
                                        awaitingBed: awaitingBed, prison: prison, probation: probation, postRelease: postRelease, beds: state.beds))
        if state.log.count > 1_100 { state.log.removeFirst(state.log.count - 1_100) }
        state.lastDay = date
        corrections = state
        sheriffNotices(jail: jail, on: date, rng: &rng)
    }

    /// The sheriff writes when the jail nears capacity, gives notice before releasing anyone, and then releases
    /// the people the judge hasn't already let go.
    private func sheriffNotices(jail: Int, on date: Date, rng: inout SeededRNG) {
        guard let county, let state = corrections else { return }
        let cal = CourtCalendar.calendar
        let beds = state.beds
        let ratio = Double(jail) / Double(max(1, beds))
        let sheriff = "Sheriff \(county.sheriff)"
        let shortDate = SentenceFormat.shortDate(date)
        if let index = state.notices.lastIndex(where: \.isOpen) {
            let notice = state.notices[index]
            switch notice.kind {
            case .nearCapacity:
                if jail > beds {
                    corrections?.notices[index].closed = date
                    corrections?.notices[index].outcome = "The jail went over capacity on \(shortDate)."
                } else if ratio < Corrections.warnAt - 0.08 {
                    corrections?.notices[index].closed = date
                    corrections?.notices[index].outcome = "The count fell back to \(jail) of \(beds) beds by \(shortDate)."
                }
            case .releases:
                let ordered = state.releases.filter { $0.byJudge && $0.date >= notice.issued }.count
                let floor = Int(Double(beds) * Corrections.releaseFloor)
                let due = notice.deadline.map { date >= $0 } ?? true
                // The notice stands until the jail has some room again, or until the deadline finds it within capacity.
                if jail <= floor || (due && jail <= beds) {
                    corrections?.notices[index].closed = date
                    corrections?.notices[index].outcome = ordered > 0
                        ? "Back under capacity on \(shortDate) after you ordered \(ordered) release\(ordered == 1 ? "" : "s"). The sheriff released no one."
                        : "Back under capacity on \(shortDate). The sheriff released no one."
                } else if due {
                    let released = sheriffReleases(rng: &rng)
                    corrections?.notices[index].closed = date
                    corrections?.notices[index].outcome = "The sheriff released \(released) \(released == 1 ? "person" : "people") on \(shortDate)"
                        + (ordered > 0 ? ", after you ordered \(ordered) release\(ordered == 1 ? "" : "s")." : ".")
                    if released > 0 {
                        stats.communityStanding = (stats.communityStanding ?? 0) - 2
                        post(NewsItem(date: date, kind: .community, headline: "Sheriff releases \(released) early from crowded \(county.name) jail",
                                      body: "\(sheriff) released \(released) \(released == 1 ? "inmate" : "inmates") early this week to bring the jail back under capacity. The jail held \(jail) of the Superior Court's defendants in space for \(beds). \"I gave the court notice,\" the sheriff said. \"We can't stack people in the hallways.\"",
                                      prominence: 2))
                    }
                }
            }
        }
        guard corrections?.openNotice == nil else { return }
        let lastRelease = state.notices.last { $0.kind == .releases }
        let recentRelease = lastRelease.map { date.timeIntervalSince($0.closed ?? $0.issued) < 7 * 86_400 } ?? false
        if jail > beds && !recentRelease {
            let deadline = cal.date(byAdding: .day, value: Corrections.noticeDays, to: date) ?? date
            corrections?.notices.append(SheriffNotice(kind: .releases, issued: date, deadline: deadline, population: jail, beds: beds,
                message: "Judge, the jail is holding \(jail) of your defendants in space for \(beds). Unless the count comes down, I'll begin releasing inmates on \(SentenceFormat.shortDate(deadline)), starting with those whose charges and records concern me least. You may choose who goes first from the jail roster. No one held for the State's prisons can be released."))
            // The paper writes about the first notice in a while, not every one.
            let newsworthy = lastRelease.map { date.timeIntervalSince($0.issued) > 45 * 86_400 } ?? true
            if newsworthy {
            stats.communityStanding = (stats.communityStanding ?? 0) - 1
            post(NewsItem(date: date, kind: .community, headline: "\(county.name) jail over capacity; sheriff warns of early releases",
                          body: "The \(county.name) jail is holding \(jail) Superior Court defendants in space for \(beds), and \(sheriff) has notified Judge \(lastName(judgeName ?? "")) that early releases will begin in \(Corrections.noticeDays) days if the count doesn't come down.",
                          prominence: 2))
            }
        } else if ratio >= Corrections.warnAt {
            let lastWarning = state.notices.last { $0.kind == .nearCapacity }?.issued ?? .distantPast
            guard date.timeIntervalSince(lastWarning) > 21 * 86_400 else { return }
            corrections?.notices.append(SheriffNotice(kind: .nearCapacity, issued: date, population: jail, beds: beds,
                message: "Judge, a heads-up: the jail is holding \(jail) of your defendants in space for \(beds). If it goes over, I'll have to give notice of early releases."))
        }
        if (corrections?.notices.count ?? 0) > 80 { corrections?.notices.removeFirst() }
    }

    /// The sheriff picks who goes: the lowest-risk people on the roster, judged by their charges and records, until
    /// the jail is a little under capacity.
    private func sheriffReleases(rng: inout SeededRNG) -> Int {
        guard let state = corrections else { return 0 }
        let target = Int(Double(state.beds) * Corrections.releaseFloor)
        let roster = jailRoster()
        var count = roster.count
        var released = 0
        // The sheriff reads the same file the judge does, but not always the same way.
        let candidates = roster.filter(\.canRelease).map { ($0, $0.risk + Double(rng.int(-8...8)) / 100) }.sorted { $0.1 < $1.1 }
        for (inmate, _) in candidates where count > target {
            releaseEarly(inmate, byJudge: false, rng: &rng)
            count -= 1
            released += 1
        }
        return released
    }

    /// The judge's own picks from the jail roster while the sheriff's notice is open.
    func orderEarlyRelease(_ personIDs: Set<UUID>) {
        guard !personIDs.isEmpty, let county else { return }
        var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(currentDate.timeIntervalSince1970)) / 86_400) ^ 0xE41A)
        let picked = jailRoster().filter { personIDs.contains($0.personID) && $0.canRelease }
        for inmate in picked { releaseEarly(inmate, byJudge: true, rng: &rng) }
        guard !picked.isEmpty else { return }
        let judge = lastName(judgeName ?? "")
        post(NewsItem(date: currentDate, kind: .community,
                      headline: "Judge \(judge) orders \(picked.count) released from crowded jail",
                      body: "Facing the sheriff's notice that the \(county.name) jail was over capacity, Judge \(judge) ordered \(picked.count) \(picked.count == 1 ? "defendant" : "defendants") released early. The judge chose them from the jail roster.",
                      prominence: 1))
        // The count drops tonight; a notice the releases satisfied closes now.
        let jail = jailRoster().count
        if let index = corrections?.notices.lastIndex(where: { $0.isOpen && $0.kind == .releases }),
           jail <= Int(Double(corrections?.beds ?? 0) * Corrections.releaseFloor) {
            corrections?.notices[index].closed = currentDate
            corrections?.notices[index].outcome = "Back under capacity on \(SentenceFormat.shortDate(currentDate)) after you ordered \(picked.count) release\(picked.count == 1 ? "" : "s"). The sheriff released no one."
        }
        save()
    }

    private func releaseEarly(_ inmate: JailInmate, byJudge: Bool, rng: inout SeededRNG) {
        let date = currentDate
        let cal = CourtCalendar.calendar
        let shortDate = SentenceFormat.shortDate(date)
        let judge = lastName(judgeName ?? "")
        var days = 0
        switch inmate.kind {
        case .awaitingBed:
            return
        case .sentenced:
            guard let index = people.firstIndex(where: { $0.id == inmate.personID }), people[index].inCountyJail(on: date) else { return }
            if let end = people[index].releaseDate, end != .distantFuture {
                days = max(0, cal.dateComponents([.day], from: date, to: end).day ?? 0)
            }
            releaseFromCustody(index, on: date, announce: false, rng: &rng)
            people[index].appearances.append(PersonRecord.Appearance(docket: inmate.docket, date: date, charges: "Early release from the county jail",
                outcome: byJudge ? "Released early on your order to ease jail crowding, with \(days) day\(days == 1 ? "" : "s") left to serve"
                                 : "Released early by the sheriff to ease jail crowding, with \(days) day\(days == 1 ? "" : "s") left to serve"))
        case .pretrial:
            guard let caseID = inmate.caseID else { return }
            let reason = byJudge ? "on Judge \(judge)'s order to ease jail crowding" : "by the sheriff to ease jail crowding"
            func freeCase(_ c: inout CourtCase) {
                guard c.id == caseID, var bg = c.background else { return }
                days = bg.custodyDays
                bg.onRelease = true
                bg.heldOnCourtBond = false
                bg.bondStatus = "Released on a written promise to appear on \(shortDate) \(reason), after \(bg.custodyDays) day\(bg.custodyDays == 1 ? "" : "s") in custody."
                c.background = bg
            }
            func free(_ entry: inout DocketEntry) {
                guard case .trial(var c) = entry.matter, c.id == caseID else { return }
                freeCase(&c)
                entry.matter = .trial(c)
            }
            for i in arraignQueue.indices { freeCase(&arraignQueue[i].courtCase) }
            if var day = today {
                for i in day.entries.indices { free(&day.entries[i]) }
                today = day
            }
            for i in scheduled.indices { free(&scheduled[i].entry) }
            for i in awaiting.indices { free(&awaiting[i].entry) }
        }
        corrections?.releases.append(EarlyRelease(personID: inmate.personID, name: inmate.name, docket: inmate.docket, charge: inmate.charge,
                                                  date: date, byJudge: byJudge, pretrial: inmate.kind == .pretrial, days: days))
        if (corrections?.releases.count ?? 0) > 400 { corrections?.releases.removeFirst() }
        dispositions.append(DispositionRecord(personID: inmate.personID, docket: inmate.docket, group: .early, date: date, freeFrom: date))
        if byJudge { stats.earlyReleasesOrdered = (stats.earlyReleasesOrdered ?? 0) + 1 }
        else { stats.earlyReleasesBySheriff = (stats.earlyReleasesBySheriff ?? 0) + 1 }

        // Some of the people let out early are arrested again: more often the riskier ones.
        let propensity = person(inmate.personID)?.propensity ?? 0.3
        guard rng.chance(min(0.55, 0.04 + inmate.risk * 0.3 + propensity * 0.3)) else { return }
        let incident = cal.date(byAdding: .day, value: rng.int(25...200), to: date) ?? date
        let last = inmate.name.components(separatedBy: " ").last ?? inmate.name
        let by = byJudge ? "on Judge \(judge)'s order" : "by the sheriff"
        pending.append(PendingEvent(due: incident, news: NewsItem(
            date: incident, kind: .arrest, headline: "\(last), released early from crowded jail, arrested again",
            body: "\(inmate.name), released early from the \(county?.name ?? "county") jail on \(shortDate) \(by) to ease crowding, was arrested again this week, according to the \(county?.sheriffsOffice ?? "Sheriff's Office").",
            docket: inmate.docket, prominence: 2), personID: inmate.personID))
        // Someone already judged here comes back to this court on the new charge.
        guard inmate.kind == .sentenced, let p = person(inmate.personID) else { return }
        let toCourt = cal.date(byAdding: .day, value: rng.int(56...100), to: incident) ?? incident
        let fitting = FollowUpCases.newCharges.filter { FollowUpCases.fits($0, age: p.age(on: incident)) }
        let note = byJudge ? "You ordered \(inmate.name) released early from the crowded jail on \(shortDate)."
                           : "The sheriff released \(inmate.name) early from your over-capacity jail on \(shortDate)."
        pending.append(PendingEvent(due: toCourt, news: NewsItem(
            date: toCourt, kind: .arrest, headline: "\(inmate.name) indicted; case returns to Judge \(judge)",
            body: "A \(county?.name ?? "county") grand jury returned an indictment against \(inmate.name), released early from the jail last year. The case is set before Judge \(judge).",
            docket: inmate.docket), personID: inmate.personID,
            reoffense: Reoffense(personID: inmate.personID, templateKeys: (fitting.isEmpty ? FollowUpCases.newCharges : fitting).shuffled(using: &rng),
                                 victimName: nil, incident: incident, note: note, priorOffense: inmate.charge, priorDate: date)))
    }

    /// A new arrest of someone this court let go: counted against the disposition that freed the person.
    private func noteRearrest(_ personID: UUID, on date: Date) {
        // The arrest and the indictment that follows are one new case, counted once.
        let sameCase = dispositions.contains { $0.personID == personID && ($0.rearrested.map { abs($0.timeIntervalSince(date)) < 150 * 86_400 } ?? false) }
        if !sameCase, let index = dispositions.lastIndex(where: { $0.personID == personID && $0.rearrested == nil && ($0.freeFrom ?? .distantFuture) <= date }) {
            dispositions[index].rearrested = date
        }
        if let index = corrections?.releases.lastIndex(where: { $0.personID == personID && $0.rearrested == nil && $0.date <= date }) {
            corrections?.releases[index].rearrested = date
            stats.earlyReleaseRearrests = (stats.earlyReleaseRearrests ?? 0) + 1
            stats.communityStanding = (stats.communityStanding ?? 0) - ((corrections?.releases[index].byJudge ?? false) ? 2 : 1)
        }
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
                            freshAppeals: freshAppeals, arrestOrders: arrestOrders, calendarLog: calendarLog, schedule: schedule, awaiting: awaiting,
                            weekTally: weekTally, mood: mood, investigations: investigations, placeHistory: placeHistory, residents: residents,
                            officerRecords: officerRecords, lawyerRecords: lawyerRecords, living: living, bondQueue: bondQueue,
                            showCauseQueue: showCauseQueue, corrections: corrections, dispositions: dispositions, arraignQueue: arraignQueue)
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
        calendarLog = data.calendarLog ?? []
        freshAppeals = data.freshAppeals ?? []
        schedule = data.schedule ?? CourtSchedule()
        awaiting = data.awaiting ?? []
        weekTally = data.weekTally ?? CourtDay.Tally()
        mood = data.mood ?? CourthouseMood()
        investigations = data.investigations ?? []
        bondQueue = data.bondQueue ?? []
        showCauseQueue = data.showCauseQueue ?? []
        corrections = data.corrections
        dispositions = data.dispositions ?? []
        arraignQueue = data.arraignQueue ?? []
        // Cases that go to trial no longer wait for an arraignment: they join the list waiting for a trial date.
        for item in arraignQueue where item.courtCase.templateKey.hasPrefix("story.") {
            arraignQueue.removeAll { $0.id == item.id }
            queueArraignment(item.courtCase, note: item.note, on: item.since)
        }
        ensureCorrections(on: currentDate)
        placeHistory = data.placeHistory ?? [:]
        residents = data.residents ?? []
        officerRecords = data.officerRecords ?? [:]
        lawyerRecords = data.lawyerRecords ?? [:]
        living = data.living ?? CountyLife.begin(seed: seedBase)
        Gazetteer.living = living
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
            if let bg = c.background, bg.isJailed { notes.append("Defendant held in jail \(bg.custodyDays) day\(bg.custodyDays == 1 ? "" : "s") awaiting trial") }
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
