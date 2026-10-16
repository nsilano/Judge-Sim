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
    /// The last day of the current week-long criminal session.
    private var sessionEnds = Date()
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

    var title: String {
        casesHeard >= 40 ? "Senior Resident Superior Court Judge" : "Resident Superior Court Judge"
    }

    // MARK: Career

    func startCareer(name: String, start: Date) {
        judgeName = name
        county = County.generate(seed: seedBase)
        let parts = Calendar.current.dateComponents([.hour, .minute], from: start)
        openingMinutes = (parts.hour ?? 9) * 60 + (parts.minute ?? 30)
        currentDate = CourtCalendar.weekday(onOrAfter: start)
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
        var day = Calendar.current.startOfDay(for: date)
        while Calendar.current.component(.weekday, from: day) != 6 { day = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day }
        return day
    }

    /// Opens a matter on today's calendar.
    func open(_ entryID: UUID) -> DocketItem? {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.id == entryID }) else { return nil }
        let entry = day.entries[index]
        guard entry.isOpen else { return nil }
        day.entries[index].status = .inProgress
        today = day
        save()
        switch entry.matter {
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
        day.clock = Calendar.current.date(byAdding: .minute, value: day.entries[index].estimatedMinutes, to: day.clock) ?? day.clock
        today = day
    }

    /// Continues a matter to a later date. A trial picks up exactly where it left off.
    func continueMatter(_ matterID: UUID, to date: Date, reason: String, snapshot: CaseSnapshot?, requests: [EvidenceRequest] = []) {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.matterID == matterID }) else { return }
        let target = max(CourtCalendar.weekday(onOrAfter: date), CourtCalendar.nextWeekday(after: day.date))
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
        entry.note = "Continued from \(SentenceFormat.shortDate(day.date)): \(reason)"
            + (requests.isEmpty ? "" : " Follow-up ordered: \(requests.count) request\(requests.count == 1 ? "" : "s").")
        scheduled.append(ScheduledMatter(date: target, entry: entry))
        scheduled.sort { $0.date < $1.date }
        day.entries[index].status = .continued
        day.entries[index].outcome = "Continued to \(SentenceFormat.shortDate(target)). \(reason)"
        day.clock = Calendar.current.date(byAdding: .minute, value: 10, to: day.clock) ?? day.clock
        today = day
        if case .trial(let c) = entry.matter {
            history.insert(CaseRecord(docket: c.docket, caption: c.caption, headline: c.headline, category: c.category,
                                      date: currentDate, defendantID: c.defendant.personID,
                                      outcome: "Continued to \(SentenceFormat.shortDate(target))", judgments: [reason],
                                      returningDefendant: c.defendant.isReturning, appealStatus: nil, kind: "continuance"), at: 0)
        }
        save()
    }

    /// The next court date: tomorrow during a session, otherwise the next session or an earlier special setting.
    var nextCourtDate: Date {
        guard let day = today else { return currentDate }
        var next = CourtCalendar.nextWeekday(after: day.date)
        if next > sessionEnds {
            var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(day.date.timeIntervalSince1970)) / 86_400))
            next = CourtCalendar.monday(onOrAfter: Calendar.current.date(byAdding: .day, value: rng.int(14...24), to: day.date) ?? next)
            if let special = scheduled.map(\.date).min(), special < next {
                next = CourtCalendar.weekday(onOrAfter: special)
            }
        }
        return next
    }

    /// What the next court date will be: a day of the current session, the first day of a new session, or a special setting.
    var nextCourtDayKind: (kind: CourtDay.Kind, newSession: Bool) {
        let next = nextCourtDate
        guard today != nil else { return (.trial, false) }
        if next <= sessionEnds {
            var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(next.timeIntervalSince1970)) / 3_600))
            return (rng.chance(0.15) ? .administrative : .trial, false)
        }
        if CourtCalendar.calendar.component(.weekday, from: next) == 2 && !scheduled.contains(where: { $0.date <= next && !CourtCalendar.isSameDay($0.date, next) }) {
            return (.administrative, true)
        }
        return (.specialSetting, false)
    }

    /// Closes the day and opens the next court date.
    func adjourn() {
        guard let day = today, day.isComplete else { return }
        let next = nextCourtDate
        let plan = nextCourtDayKind
        let kind = plan.kind
        let sessionDay: Int
        if plan.newSession {
            sessionEnds = sessionFriday(for: next)
            sessionDay = 1
        } else if kind == .specialSetting {
            sessionDay = 0
        } else {
            sessionDay = day.sessionDay + 1
        }
        let marker = news.first?.id
        advanceWorld(to: next)
        today = buildDay(next, kind: kind, sessionDay: sessionDay)
        digest = Array(news.prefix { $0.id != marker })
        save()
    }

    // MARK: Time off

    /// The Monday the judge would return to the bench after `weeks` weeks of leave.
    func leaveReturnDate(weeks: Int) -> Date {
        let base = today?.date ?? currentDate
        let after = Calendar.current.date(byAdding: .day, value: 7 * max(1, weeks), to: base) ?? base
        return CourtCalendar.monday(onOrAfter: after)
    }

    /// Steps away from the bench. The world keeps moving: sentences end, appeals come down, people are released.
    /// Matters continued into the leave are reset to the first day back.
    func takeLeave(weeks: Int) {
        guard let day = today, day.isComplete, let judgeName else { return }
        let back = leaveReturnDate(weeks: weeks)
        let marker = news.first?.id

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
            cursor = min(back, Calendar.current.date(byAdding: .day, value: 7, to: cursor) ?? back)
            advanceWorld(to: cursor)
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
        today = buildDay(back, kind: .administrative, sessionDay: 1)
        digest = Array(news.prefix { $0.id != marker })
        save()
    }

    /// Starts following each appeal taken today, and puts any oral argument on the calendar.
    private func trackAppeals(_ events: [PendingEvent], docket: String, caption: String, personID: UUID, appellant: String, plea: Bool) {
        var rng = SeededRNG(seed: seedBase ^ UInt64(abs(docket.hashValue % 1_000_000)) ^ UInt64(appeals.count))
        let decisions = events.filter { $0.news.kind == .appeal && $0.news.docket == docket && !Appeals.isFollowUp($0) }
        guard let first = decisions.min(by: { $0.due < $1.due }) else { return }
        let headline = first.news.headline
        let issue: String
        let byState = headline.contains("reinstates") || (first.news.body.contains("On appeal by the State"))
        if headline.contains("reinstates") {
            issue = "Whether the trial court erred in dismissing the charges for a speedy-trial violation"
        } else if first.effect == .resentence || headline.contains("vacates sentence") || first.news.body.contains("remanded for resentencing") {
            issue = "Whether the sentence is authorized by North Carolina law"
        } else if docket.hasSuffix("(PV)") {
            issue = "Whether the court had authority to sanction the probationer as it did"
        } else if plea {
            issue = "Sentencing issues following a plea (G.S. 15A-1444)"
        } else {
            issue = "The sufficiency of the evidence and the trial court's rulings on motions and objections"
        }
        var tracker = Appeals.tracker(for: first, caption: caption, personID: personID, filed: currentDate,
                                      appellant: byState ? "the State" : appellant, issue: issue, rng: &rng)
        tracker.docket = docket
        appeals.insert(tracker, at: 0)
        if let argument = tracker.argument {
            pending.append(PendingEvent(due: argument,
                                        news: NewsItem(date: argument, kind: .community,
                                                       headline: "Court of Appeals hears argument in \(caption)",
                                                       body: "A three-judge panel of the North Carolina Court of Appeals heard oral argument in Raleigh in the appeal from Judge \(lastName(judgeName ?? ""))'s judgment in \(caption). The issue: \(issue.prefix(1).lowercased() + issue.dropFirst()). A written opinion typically follows within a few months.",
                                                       docket: docket)))
        }
    }

    /// Appeals taken before the tracker existed still have pending decisions; give each one a tracker.
    private func backfillAppeals() {
        var added = false
        for event in pending where event.news.kind == .appeal && !Appeals.isFollowUp(event) {
            guard let docket = event.news.docket, !appeals.contains(where: { $0.docket == docket }) else { continue }
            let record = history.first { $0.docket == docket }
            let filed = record?.date ?? currentDate
            var rng = SeededRNG(seed: seedBase ^ UInt64(abs(docket.hashValue % 1_000_000)))
            let byState = event.news.headline.contains("reinstates") || event.news.body.contains("On appeal by the State")
            let issue: String
            if event.news.headline.contains("reinstates") {
                issue = "Whether the trial court erred in dismissing the charges for a speedy-trial violation"
            } else if event.effect == .resentence || event.news.body.contains("remanded for resentencing") {
                issue = "Whether the sentence is authorized by North Carolina law"
            } else if docket.hasSuffix("(PV)") {
                issue = "Whether the court had authority to sanction the probationer as it did"
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

    /// A probationer sentenced elsewhere whose supervision was transferred to this county.
    private func makeOutsideHearing(date: Date, rng: inout SeededRNG) -> ViolationHearing? {
        guard let county else { return nil }
        var used = Set(people.map(\.name))
        let name = NameBank.person(using: &rng, excluding: &used)
        let age = rng.int(20...58)
        let year = Calendar.current.component(.year, from: date)
        let seed = rng.pick(GenericPools.priorSeeds)
        var priors: [PriorConviction] = []
        for _ in 0..<rng.int(0...3) {
            let p = rng.pick(GenericPools.priorSeeds)
            priors.append(PriorConviction(offense: p.offense, ncClass: p.ncClass, year: year - rng.int(2...12),
                                          county: rng.pick(GenericPools.otherCounties), sentence: rng.pick(p.sentences)))
        }
        let otherCounty = rng.pick(GenericPools.otherCounties)
        let felony = seed.ncClass.isFelony
        let months = felony ? rng.int(6...20) : rng.int(1...4)
        let docket = String(format: "%02d %@ %06d", (year - 1) % 100, felony ? "CRS" : "CR", rng.int(1_000...90_000))
        let judge = "Judge " + (NameBank.person(using: &rng, excluding: &used).components(separatedBy: " ").last ?? "Ward")
        priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: year - 1, county: otherCounty,
                                      sentence: felony ? "\(months) months suspended, 30 months probation" : "\(months * 30) days suspended, 18 months probation",
                                      docket: docket))
        let term = ProbationTerm(docket: docket, offense: seed.offense, isFelony: felony,
                                 suspendedSentence: felony ? "\(months)–\(StructuredSentencing.maximum(forMinimum: months, cls: seed.ncClass)) months" : "\(months * 30) days",
                                 activeMonths: months,
                                 ends: Calendar.current.date(byAdding: .month, value: rng.int(6...20), to: date) ?? date,
                                 imposedInThisCourt: false, supervised: true,
                                 conditions: rng.chance(0.5) ? ["Obtain a substance abuse assessment and complete recommended treatment."] : [],
                                 monthlyObligation: rng.int(1...4) * 40, violationRisk: 0.25, crvCount: rng.chance(0.2) ? 1 : 0,
                                 treatmentNeed: rng.chance(0.5) ? .substance : TreatmentNeed.none,
                                 origin: "Sentenced by \(judge) in \(otherCounty); supervision transferred to \(county.name) when the probationer moved here.")
        let person = PersonRecord(id: UUID(), name: name, birthYear: year - age, occupation: rng.pick(NameBank.occupations).capitalizedFirst,
                                  background: "Moved to \(rng.pick(county.towns)) last year.", priors: priors,
                                  status: .probation, probation: term, propensity: rng.chance(0.5) ? 0.35 : 0.2)
        people.append(person)
        return ViolationHearings.make(person: person, county: county, date: date, seed: rng.next())
    }

    /// Builds the calendar for a court date.
    private func buildDay(_ date: Date, kind: CourtDay.Kind, sessionDay: Int) -> CourtDay {
        var rng = SeededRNG(seed: seedBase &+ UInt64(abs(Int(date.timeIntervalSince1970)) / 60) &* 0x2545_F491)
        var entries: [DocketEntry] = []

        // Continued matters come first.
        let due = scheduled.filter { Calendar.current.startOfDay(for: $0.date) <= date }
        scheduled.removeAll { Calendar.current.startOfDay(for: $0.date) <= date }
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
        // Cases back from the Court of Appeals.
        while !retrials.isEmpty {
            var retrial = retrials.removeFirst()
            retrial.id = UUID()
            retrial.sessionDate = date
            refreshDefendant(&retrial)
            entries.append(DocketEntry(matter: .trial(retrial), note: "Returned from the Court of Appeals"))
        }

        // Anyone already on today's calendar, or holding a continued matter, isn't given a second matter.
        var usedPeople = Set<UUID>()
        for entry in entries + scheduled.map(\.entry) {
            switch entry.matter {
            case .trial(let c): usedPeople.insert(c.defendant.personID)
            case .hearing(let h): usedPeople.insert(h.personID)
            case .calendar(let call): call.matters.forEach { usedPeople.insert($0.personID) }
            }
        }
        switch kind {
        case .specialSetting:
            break
        case .administrative:
            if let county {
                let call = CalendarCalls.make(county: county, date: date, docketSequence: docketSequence, people: people,
                                              excluding: usedPeople, seed: rng.next())
                docketSequence += 200
                call.matters.forEach { usedPeople.insert($0.personID) }
                entries.append(DocketEntry(matter: .calendar(call)))
            }
            for _ in 0..<rng.int(1...2) {
                if let hearing = makeViolationHearing(date: date, excluding: &usedPeople, rng: &rng) {
                    entries.append(DocketEntry(matter: .hearing(hearing)))
                }
            }
            if rng.chance(0.7), let hearing = makeOutsideHearing(date: date, rng: &rng) {
                entries.append(DocketEntry(matter: .hearing(hearing)))
            }
        case .trial:
            let roll = Double.random(in: 0..<1, using: &rng)
            let wanted = roll < 0.4 ? 1 : (roll < 0.85 ? 2 : 3)
            let already = entries.filter { if case .trial = $0.matter { return true } else { return false } }.count
            for _ in 0..<max(0, wanted - already) {
                if var c = generateCase(date: date, rng: &rng, excluding: &usedPeople) {
                    // Some cases are called with a party asking for more time.
                    if c.background?.arrangementPresented != true && rng.chance(0.25) {
                        c.continuanceMotion = ContinuanceMotions.make(for: c, rng: &rng)
                    }
                    entries.append(DocketEntry(matter: .trial(c)))
                }
            }
            if rng.chance(0.35), let hearing = makeViolationHearing(date: date, excluding: &usedPeople, rng: &rng) {
                entries.append(DocketEntry(matter: .hearing(hearing)))
            } else if rng.chance(0.25), let hearing = makeOutsideHearing(date: date, rng: &rng) {
                entries.append(DocketEntry(matter: .hearing(hearing)))
            }
        }
        if entries.isEmpty, let c = generateCase(date: date, rng: &rng, excluding: &usedPeople) {
            entries.append(DocketEntry(matter: .trial(c)))
        }
        return CourtDay(date: date, clock: CourtCalendar.opening(on: date, minutesAfterMidnight: openingMinutes),
                        kind: kind, entries: entries, sessionDay: sessionDay)
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

    func completeCalendar(_ call: CalendarCall, choices: [UUID: Int]) {
        guard let county, let judgeName else { return }
        let result = CalendarCalls.resolve(call, choices: choices, judgeName: judgeName, county: county)
        people.append(contentsOf: result.newPeople)
        for (id, update) in result.updates {
            if let index = people.firstIndex(where: { $0.id == id }) { update(&people[index]) }
        }
        pending.append(contentsOf: result.pending)
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
        let recentCutoff = Calendar.current.date(byAdding: .day, value: -45, to: date) ?? date
        let candidates = people.filter { person in
            person.status == .probation
                && person.probation != nil
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
        let appearance = PersonRecord.Appearance(docket: hearing.probation.docket + " (PV)", date: currentDate,
                                                 charges: "Probation violation", outcome: outcome.appearance)
        if let index = people.firstIndex(where: { $0.id == hearing.personID }) {
            people[index].status = outcome.status
            people[index].releaseDate = outcome.releaseDate
            people[index].releaseNote = outcome.releaseDate == nil ? nil : outcome.lines.first
            people[index].probation = outcome.probation
            people[index].propensity = min(0.85, max(0.03, people[index].propensity + outcome.propensityChange))
            if let violation = outcome.violation { people[index].violations = (people[index].violations ?? []) + [violation] }
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
        pending.append(contentsOf: outcome.pending)
        trackAppeals(outcome.pending, docket: hearing.probation.docket + " (PV)", caption: "State v. \(hearing.personName) (probation violation)",
                     personID: hearing.personID, appellant: "the probationer", plea: false)
        finishEntry(matterID: hearing.id, outcome: outcome.appearance)
        save()
    }

    /// A new case for the calendar.
    private func generateCase(date: Date, rng: inout SeededRNG, excluding used: inout Set<UUID>) -> CourtCase? {
        guard let county, let judgeName else { return nil }
        var returning = pickReturningDefendant(rng: &rng, date: date)
        if let person = returning, used.contains(person.id) { returning = nil }
        let context = CaseGenerator.Context(county: county, judgeName: judgeName, date: date,
                                            docketSequence: docketSequence, recentTemplateKeys: recentTemplates,
                                            usedSignatures: Set(usedSignatures), returning: returning,
                                            usedBackgrounds: Set(people.map(\.background)))
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
        if recentTemplates.count > 8 { recentTemplates.removeFirst(recentTemplates.count - 8) }

        if let returning {
            let lead = returning.status == .probation ? "while on probation" : returning.postRelease != nil ? "while on post-release supervision" : "again"
            post(NewsItem(date: date, kind: .arrest,
                          headline: "\(returning.name) charged \(lead)",
                          body: "\(returning.name), \(returning.age(on: date)), who has previously appeared in Hollis County Superior Court, has been charged with \(newCase.charges.first?.law.title.lowercased() ?? "a new offense"). The case is set for trial before Judge \(lastName(judgeName)).",
                          docket: newCase.docket))
        }
        return newCase
    }

    private func pickReturningDefendant(rng: inout SeededRNG, date: Date) -> PersonRecord? {
        let recentCutoff = Calendar.current.date(byAdding: .day, value: -30, to: date) ?? date
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

    func complete(_ courtCase: CourtCase, outcome: CaseOutcome) {
        let d = courtCase.defendant
        let judgmentText = outcome.judgments.map { ([$0.title] + $0.lines).joined(separator: " · ") }
            + [outcome.habitualNote, outcome.probationHearing].compactMap { $0 }

        history.insert(CaseRecord(docket: courtCase.docket, caption: courtCase.caption, headline: courtCase.headline,
                                  category: courtCase.category, date: currentDate, defendantID: d.personID,
                                  outcome: outcome.appearanceSummary, judgments: judgmentText,
                                  returningDefendant: d.isReturning,
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
        if courtCase.defendant.probation != nil && outcome.probationHearing?.contains("revoked") == true { stats.probationRevoked += 1 }

        // Update the person's record
        let appearance = PersonRecord.Appearance(docket: courtCase.docket, date: currentDate,
                                                 charges: courtCase.charges.map { $0.law.title }.joined(separator: ", "),
                                                 outcome: outcome.appearanceSummary)
        if let index = people.firstIndex(where: { $0.id == d.personID }) {
            people[index].priors.append(contentsOf: outcome.newPriors)
            people[index].status = outcome.personStatus
            people[index].releaseDate = outcome.releaseDate
            people[index].releaseNote = outcome.releaseBasis
            people[index].probation = outcome.newProbation
            people[index].postRelease = outcome.continuedPostRelease
            if !outcome.violations.isEmpty { people[index].violations = (people[index].violations ?? []) + outcome.violations }
            people[index].pendingPostRelease = outcome.newPostRelease ?? (outcome.personStatus == .incarcerated ? people[index].pendingPostRelease : nil)

            people[index].propensity = (people[index].propensity + outcome.propensity) / 2 + 0.05
            people[index].appearances.append(appearance)
        } else {
            let birthYear = Calendar.current.component(.year, from: currentDate) - d.age
            people.append(PersonRecord(id: d.personID, name: d.name, birthYear: birthYear, occupation: d.occupation,
                                       background: d.background, priors: d.priors + outcome.newPriors,
                                       status: outcome.personStatus, releaseDate: outcome.releaseDate,
                                       probation: outcome.newProbation, propensity: outcome.propensity,
                                       appearances: [appearance], releaseNote: outcome.releaseBasis,
                                       pendingPostRelease: outcome.newPostRelease))
        }
        // Credit already satisfied the prison term: post-release supervision starts today.
        if outcome.personStatus != .incarcerated, let index = people.firstIndex(where: { $0.id == d.personID }),
           var prs = people[index].pendingPostRelease {
            prs.ends = Calendar.current.date(byAdding: .month, value: prs.supervisionMonths, to: currentDate) ?? currentDate
            people[index].postRelease = prs
            people[index].pendingPostRelease = nil
        }

        var verdictNews = outcome.news
        verdictNews.date = currentDate
        post(verdictNews)
        pending.append(contentsOf: outcome.pending)
        let appellant = (outcome.appealNotice ?? "").contains("The State") ? "the State" : "the defendant"
        trackAppeals(outcome.pending, docket: courtCase.docket, caption: courtCase.caption, personID: d.personID,
                     appellant: appellant, plea: outcome.verdictLines.contains { $0.verdictLabel.contains("plea") || $0.verdictLabel.contains("No contest") })
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
            if item.kind == .exoneration { stats.exonerations += 1 }
            if let personID = event.personID, let index = people.firstIndex(where: { $0.id == personID }) {
                switch event.effect {
                case .releasePerson:
                    var custodyFromThisCase = true
                    if let docket = event.vacatesDocket {
                        people[index].priors.removeAll { $0.docket == docket || $0.docket == docket + " (PV)" }
                        if people[index].probation?.docket == docket { people[index].probation = nil }
                        // Custody imposed later in another case continues.
                        let lastDocket = people[index].appearances.last?.docket
                        custodyFromThisCase = lastDocket == nil || lastDocket == docket || lastDocket == docket + " (PV)"
                    } else {
                        people[index].probation = nil
                    }
                    if people[index].status != .incarcerated || custodyFromThisCase {
                        people[index].status = people[index].probation == nil ? .free : .probation
                        people[index].releaseDate = nil
                    }
                case .raisePropensity:
                    people[index].propensity = min(0.85, people[index].propensity + 0.15)
                case .resentence:
                    if people[index].status == .incarcerated, let newRelease = event.newReleaseDate {
                        // Resentencing on remand can only shorten the term the appeal attacked.
                        if newRelease <= currentDate {
                            people[index].status = people[index].probation == nil ? .free : .probation
                            people[index].releaseDate = nil
                        } else if newRelease < (people[index].releaseDate ?? .distantFuture) {
                            people[index].releaseDate = newRelease
                        }
                    }
                case .none:
                    break
                }
            }
            if event.news.kind == .appeal, let docket = event.news.docket,
               let index = appeals.firstIndex(where: { $0.docket == docket }) {
                if appeals[index].decided == nil && !Appeals.isFollowUp(event) {
                    appeals[index].decided = event.due
                    appeals[index].result = Appeals.status(for: event)
                    appeals[index].opinion = event.news.body
                } else {
                    appeals[index].followUps.append("\(SentenceFormat.shortDate(event.due)): \(event.news.headline)")
                    if Appeals.isFollowUp(event) { appeals[index].result = Appeals.status(for: event) }
                }
            }
            if event.news.kind == .appeal, let docket = event.news.docket,
               let index = history.firstIndex(where: { $0.docket == docket }) {
                let headline = event.news.headline
                let status: String
                if event.effect == .resentence || headline.contains("vacates sentence") {
                    status = "Sentence vacated; remanded for resentencing"
                } else if headline.contains("will retry") {
                    status = "New trial ordered; the State will retry"
                } else if headline.contains("No retrial") {
                    status = "New trial ordered; the State declined to retry"
                } else if headline.contains("new trial") {
                    status = "New trial ordered on appeal"
                } else if headline.contains("vacates conviction") {
                    status = "Conviction vacated on appeal"
                } else if headline.contains("reinstates") {
                    status = "Dismissal reversed; charges reinstated"
                } else if headline.contains("Appeal dismissed") {
                    status = "Appeal dismissed"
                } else if headline.contains("vacates probation") || headline.contains("reverses probation") {
                    status = "Probation order vacated on appeal"
                } else {
                    status = "Affirmed on appeal"
                }
                history[index].appealStatus = status
            }
        }

        // Sentences expire
        for index in people.indices {
            if let prs = people[index].postRelease, prs.ends <= currentDate { people[index].postRelease = nil }
            let person = people[index]
            let lastDocket = person.appearances.last?.docket
            switch person.status {
            case .incarcerated:
                if let release = person.releaseDate, release <= currentDate {
                    people[index].releaseDate = nil
                    people[index].releaseNote = nil
                    if var prs = person.pendingPostRelease {
                        prs.ends = Calendar.current.date(byAdding: .month, value: prs.supervisionMonths, to: release) ?? release
                        people[index].postRelease = prs
                        people[index].pendingPostRelease = nil
                    }
                    if let probation = person.probation, probation.ends > currentDate {
                        people[index].status = .probation
                    } else {
                        people[index].status = .free
                        people[index].probation = nil
                    }
                    stats.releasedFromPrison += 1
                    if rng.chance(0.4) {
                        post(NewsItem(date: release, kind: .community,
                                      headline: "\(person.name) released from custody",
                                      body: "\(person.name), \(person.age(on: currentDate)), sentenced in Hollis County Superior Court, was released this week" + (people[index].status == .probation ? " and begins a term of supervised probation." : ".") + " " + rng.pick([
                                        "A relative said the family plans a small dinner. \"We're just glad to have them home.\"",
                                        "A reentry program in Port Hollis has offered a bed and job placement.",
                                        "Neither \(person.lastName) nor counsel could be reached for comment."
                                      ]),
                                      docket: lastDocket, prominence: 1))
                    }
                }
            case .probation:
                if let probation = person.probation, probation.ends <= currentDate {
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
                                      headline: "\(person.name) completes probation",
                                      body: "\(person.name) completed probation in \(probation.docket) this week, closing the case.",
                                      docket: probation.docket))
                    }
                }
            case .free:
                break
            }
        }
    }

    private func post(_ item: NewsItem) {
        news.insert(item, at: 0)
        if news.count > 150 { news.removeLast(news.count - 150) }
    }

    private func lastName(_ name: String) -> String {
        name.components(separatedBy: " ").last ?? name
    }

    // MARK: Persistence

    private func save() {
        let data = SaveData(judgeName: judgeName, county: county, currentDate: currentDate, docketSequence: docketSequence,
                            history: Array(history.prefix(300)), people: people, news: news, pending: pending,
                            currentCase: currentCase, currentHearing: currentHearing, recentTemplates: recentTemplates,
                            usedSignatures: usedSignatures, seedBase: seedBase,
                            currentCalendar: currentCalendar, retrials: retrials, stats: stats,
                            today: today, scheduled: scheduled, openingMinutes: openingMinutes, sessionEnds: sessionEnds,
                            digest: digest, appeals: appeals, recentLineKeys: recentLineKeys)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        guard let raw = UserDefaults.standard.data(forKey: saveKey),
              let data = try? JSONDecoder().decode(SaveData.self, from: raw) else { return }
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
        openingMinutes = data.openingMinutes ?? openingMinutes
        sessionEnds = data.sessionEnds ?? sessionFriday(for: currentDate)
        today = data.today
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
