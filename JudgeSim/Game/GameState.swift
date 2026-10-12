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
    private var usedSignatures: [String] = []
    private var seedBase: UInt64 = UInt64.random(in: 1...UInt64.max / 2)
    private let saveKey = "JudgeSim.nc.save.v1"

    init() {
        load()
    }

    var casesHeard: Int { history.count }
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
    func continueMatter(_ matterID: UUID, to date: Date, reason: String, snapshot: CaseSnapshot?) {
        guard var day = today, let index = day.entries.firstIndex(where: { $0.matterID == matterID }) else { return }
        let target = max(CourtCalendar.weekday(onOrAfter: date), CourtCalendar.nextWeekday(after: day.date))
        var entry = day.entries[index]
        entry.status = .pending
        entry.resume = snapshot ?? entry.resume
        entry.continuances += 1
        entry.note = "Continued from \(SentenceFormat.shortDate(day.date)): \(reason)"
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

    /// Closes the day and opens the next court date.
    func adjourn() {
        guard let day = today, day.isComplete else { return }
        let next = nextCourtDate
        let kind: CourtDay.Kind
        let sessionDay: Int
        if next <= sessionEnds {
            sessionDay = day.sessionDay + 1
            var rng = SeededRNG(seed: seedBase ^ UInt64(abs(Int(next.timeIntervalSince1970)) / 3_600))
            kind = rng.chance(0.15) ? .administrative : .trial
        } else if CourtCalendar.calendar.component(.weekday, from: next) == 2 && !scheduled.contains(where: { $0.date <= next && !CourtCalendar.isSameDay($0.date, next) }) {
            sessionEnds = sessionFriday(for: next)
            sessionDay = 1
            kind = .administrative
        } else {
            sessionDay = 0
            kind = .specialSetting
        }
        advanceWorld(to: next)
        today = buildDay(next, kind: kind, sessionDay: sessionDay)
        save()
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
            if case .trial(var c) = entry.matter {
                c.sessionDate = date
                refreshDefendant(&c)
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

        var usedPeople = Set<UUID>()
        switch kind {
        case .specialSetting:
            break
        case .administrative:
            if let county {
                let call = CalendarCalls.make(county: county, date: date, docketSequence: docketSequence, people: people,
                                              seed: rng.next())
                docketSequence += 200
                entries.append(DocketEntry(matter: .calendar(call)))
            }
            for _ in 0..<rng.int(1...2) {
                if let hearing = makeViolationHearing(date: date, excluding: &usedPeople, rng: &rng) {
                    entries.append(DocketEntry(matter: .hearing(hearing)))
                }
            }
        case .trial:
            let roll = Double.random(in: 0..<1, using: &rng)
            let wanted = roll < 0.4 ? 1 : (roll < 0.85 ? 2 : 3)
            let already = entries.filter { if case .trial = $0.matter { return true } else { return false } }.count
            for _ in 0..<max(0, wanted - already) {
                if let c = generateCase(date: date, rng: &rng, excluding: &usedPeople) {
                    entries.append(DocketEntry(matter: .trial(c)))
                }
            }
            if rng.chance(0.35), let hearing = makeViolationHearing(date: date, excluding: &usedPeople, rng: &rng) {
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
                && (person.probation?.imposedInThisCourt ?? false)
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
            people[index].probation = outcome.probation
            people[index].propensity = min(0.85, max(0.03, people[index].propensity + outcome.propensityChange))
            people[index].appearances.append(appearance)
        }
        history.insert(CaseRecord(docket: hearing.probation.docket + " (PV)", caption: "Probation violation: \(hearing.personName)",
                                  headline: "Probation violation hearing", category: .procedure, date: currentDate,
                                  defendantID: hearing.personID, outcome: outcome.appearance, judgments: outcome.lines,
                                  returningDefendant: true, appealStatus: nil, kind: "hearing"), at: 0)
        if outcome.status == .incarcerated && outcome.probation == nil { stats.probationRevoked += 1 }
        var item = outcome.news
        item.date = currentDate
        post(item)
        pending.append(contentsOf: outcome.pending)
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
                                            usedSignatures: Set(usedSignatures), returning: returning)
        let newCase = CaseGenerator.generate(seed: rng.next(), context: context)
        used.insert(newCase.defendant.personID)
        docketSequence += rng.int(30...420)
        recentTemplates.append(newCase.templateKey)
        if let signature = newCase.scenarioSignature { usedSignatures.append(signature) }
        if recentTemplates.count > 8 { recentTemplates.removeFirst(recentTemplates.count - 8) }

        if let returning {
            let lead = returning.status == .probation ? "while on probation" : "again"
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
                                  appealStatus: outcome.appealNotice == nil ? nil : "Appeal pending", kind: "trial"), at: 0)
        if let position = outcome.sentencePosition {
            switch position {
            case .below: stats.belowPresumptive += 1
            case .within: stats.withinPresumptive += 1
            case .above: stats.abovePresumptive += 1
            }
        }
        if outcome.custodyMonths > 0 { stats.activeSentences += 1 } else if outcome.newProbation != nil && outcome.convicted { stats.suspendedSentences += 1 }
        if courtCase.defendant.probation != nil && outcome.probationHearing?.contains("revoked") == true { stats.probationRevoked += 1 }

        // Update the person's record
        let appearance = PersonRecord.Appearance(docket: courtCase.docket, date: currentDate,
                                                 charges: courtCase.charges.map { $0.law.title }.joined(separator: ", "),
                                                 outcome: outcome.appearanceSummary)
        if let index = people.firstIndex(where: { $0.id == d.personID }) {
            people[index].priors.append(contentsOf: outcome.newPriors)
            people[index].status = outcome.personStatus
            people[index].releaseDate = outcome.releaseDate
            people[index].probation = outcome.newProbation
            people[index].propensity = (people[index].propensity + outcome.propensity) / 2 + 0.05
            people[index].appearances.append(appearance)
        } else {
            let birthYear = Calendar.current.component(.year, from: currentDate) - d.age
            people.append(PersonRecord(id: d.personID, name: d.name, birthYear: birthYear, occupation: d.occupation,
                                       background: d.background, priors: d.priors + outcome.newPriors,
                                       status: outcome.personStatus, releaseDate: outcome.releaseDate,
                                       probation: outcome.newProbation, propensity: outcome.propensity,
                                       appearances: [appearance]))
        }

        var verdictNews = outcome.news
        verdictNews.date = currentDate
        post(verdictNews)
        pending.append(contentsOf: outcome.pending)
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
        retrials = []
        stats = CareerStats()
        recentTemplates = []
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
                    if let docket = event.vacatesDocket {
                        people[index].priors.removeAll { $0.docket == docket || $0.docket == docket + " (PV)" }
                        if people[index].probation?.docket == docket { people[index].probation = nil }
                    } else {
                        people[index].probation = nil
                    }
                    people[index].status = people[index].probation == nil ? .free : .probation
                    people[index].releaseDate = nil
                case .raisePropensity:
                    people[index].propensity = min(0.85, people[index].propensity + 0.15)
                case .resentence:
                    if people[index].status == .incarcerated, let newRelease = event.newReleaseDate {
                        if newRelease <= currentDate {
                            people[index].status = people[index].probation == nil ? .free : .probation
                            people[index].releaseDate = nil
                        } else {
                            people[index].releaseDate = newRelease
                        }
                    }
                case .none:
                    break
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
            let person = people[index]
            let lastDocket = person.appearances.last?.docket
            switch person.status {
            case .incarcerated:
                if let release = person.releaseDate, release <= currentDate {
                    people[index].releaseDate = nil
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
                            today: today, scheduled: scheduled, openingMinutes: openingMinutes, sessionEnds: sessionEnds)
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
        openingMinutes = data.openingMinutes ?? openingMinutes
        sessionEnds = data.sessionEnds ?? sessionFriday(for: currentDate)
        today = data.today
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
