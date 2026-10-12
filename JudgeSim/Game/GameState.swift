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
    case trial(CourtCase)
    case hearing(ViolationHearing)
    case calendar(CalendarCall)

    var id: UUID {
        switch self {
        case .trial(let c): return c.id
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
    @Published var currentCase: CourtCase?
    @Published var currentHearing: ViolationHearing?
    @Published var currentCalendar: CalendarCall?
    @Published private(set) var stats = CareerStats()

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

    func startCareer(name: String) {
        judgeName = name
        county = County.generate(seed: seedBase)
        currentDate = Date()
        var rng = SeededRNG(seed: seedBase)
        docketSequence = rng.int(1_200...4_800)
        if let county {
            news = [NewsItem(date: currentDate, kind: .community,
                             headline: "\(name) sworn in as Resident Superior Court Judge",
                             body: "In a ceremony at the \(county.courthouse), \(name) took the oath of office as a Resident Superior Court Judge for \(county.name). District Attorney \(county.districtAttorney), Chief Public Defender \(county.chiefPublicDefender), Sheriff \(county.sheriff), and Clerk of Superior Court \(county.clerk) attended.")]
        }
        save()
    }

    /// The next matter on the calendar: a pending trial or hearing, or a newly scheduled one.
    func nextDocketItem() -> DocketItem {
        if let currentCase { return .trial(currentCase) }
        if let currentHearing { return .hearing(currentHearing) }
        if let currentCalendar { return .calendar(currentCalendar) }
        if let retrial = docketRetrial() { return .trial(retrial) }
        if casesHeard > 2 && casesHeard % 4 == 3, let county {
            let call = CalendarCalls.make(county: county, date: currentDate, docketSequence: docketSequence, people: people,
                                          seed: seedBase ^ UInt64(casesHeard &* 31_337))
            docketSequence += 200
            currentCalendar = call
            save()
            return .calendar(call)
        }
        if let hearing = scheduleViolationHearing() { return .hearing(hearing) }
        return .trial(docketCase())
    }

    /// Brings back a case the Court of Appeals sent back for a new trial, or charges it reinstated.
    private func docketRetrial() -> CourtCase? {
        guard !retrials.isEmpty else { return nil }
        var retrial = retrials.removeFirst()
        retrial.id = UUID()
        retrial.sessionDate = currentDate
        if let person = person(retrial.defendant.personID) {
            retrial.defendant.priors = person.priors
            retrial.defendant.probation = person.status == .probation ? person.probation : nil
            retrial.defendant.history = person.appearances
            retrial.defendant.age = person.age(on: currentDate)
        }
        currentCase = retrial
        save()
        return retrial
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
        currentCalendar = nil
        advanceCalendar()
        save()
    }

    private func scheduleViolationHearing() -> ViolationHearing? {
        guard let county else { return nil }
        var rng = SeededRNG(seed: seedBase ^ UInt64(casesHeard &* 104_729 &+ 17))
        let recentCutoff = Calendar.current.date(byAdding: .day, value: -60, to: currentDate) ?? currentDate
        let candidates = people.filter { person in
            person.status == .probation
                && (person.probation?.imposedInThisCourt ?? false)
                && (person.appearances.last?.date ?? .distantPast) < recentCutoff
        }
        let risks = candidates.map { $0.probation?.violationRisk ?? 0.15 }
        let total = risks.reduce(0, +)
        guard total > 0, rng.chance(min(0.35, total * 0.35)) else { return nil }
        var target = Double.random(in: 0..<total, using: &rng)
        var chosen = candidates[candidates.count - 1]
        for (person, risk) in zip(candidates, risks) {
            target -= risk
            if target <= 0 { chosen = person; break }
        }
        guard let hearing = ViolationHearings.make(person: chosen, county: county, date: currentDate, seed: rng.next()) else { return nil }
        currentHearing = hearing
        save()
        return hearing
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
        currentHearing = nil
        advanceCalendar()
        save()
    }

    /// The case on today's calendar, generating one if needed.
    func docketCase() -> CourtCase {
        if let currentCase { return currentCase }
        guard let county, let judgeName else { fatalError("Career not started") }

        var rng = SeededRNG(seed: seedBase &+ UInt64(casesHeard + 1) &* 0x9E37_79B9_7F4A_7C15)
        let returning = pickReturningDefendant(rng: &rng)
        let context = CaseGenerator.Context(county: county, judgeName: judgeName, date: currentDate,
                                            docketSequence: docketSequence, recentTemplateKeys: recentTemplates,
                                            usedSignatures: Set(usedSignatures), returning: returning)
        let seed = rng.next()
        let newCase = CaseGenerator.generate(seed: seed, context: context)
        currentCase = newCase
        docketSequence += rng.int(30...420)
        recentTemplates.append(newCase.templateKey)
        if let signature = newCase.scenarioSignature { usedSignatures.append(signature) }
        if recentTemplates.count > 8 { recentTemplates.removeFirst(recentTemplates.count - 8) }

        if let returning {
            let lead = returning.status == .probation ? "while on probation" : "again"
            post(NewsItem(date: currentDate, kind: .arrest,
                          headline: "\(returning.name) charged \(lead)",
                          body: "\(returning.name), \(returning.age(on: currentDate)), who has previously appeared in Hollis County Superior Court, has been charged with \(newCase.charges.first?.law.title.lowercased() ?? "a new offense"). The case is set for trial before Judge \(lastName(judgeName)).",
                          docket: newCase.docket))
        }
        save()
        return newCase
    }

    private func pickReturningDefendant(rng: inout SeededRNG) -> PersonRecord? {
        let recentCutoff = Calendar.current.date(byAdding: .day, value: -45, to: currentDate) ?? currentDate
        let eligible = people.filter { person in
            person.status != .incarcerated
                && (person.appearances.last?.date ?? .distantPast) < recentCutoff
                && person.age(on: currentDate) < 75
        }
        let total = eligible.reduce(0) { $0 + $1.propensity }
        guard total > 0, rng.chance(min(0.35, total * 0.12)) else { return nil }
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
        currentCase = nil

        advanceCalendar()
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

    private func advanceCalendar() {
        var rng = SeededRNG(seed: seedBase ^ UInt64(casesHeard &* 7919))
        currentDate = Calendar.current.date(byAdding: .day, value: rng.int(7...24), to: currentDate) ?? currentDate

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
                            currentCalendar: currentCalendar, retrials: retrials, stats: stats)
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
    }
}
