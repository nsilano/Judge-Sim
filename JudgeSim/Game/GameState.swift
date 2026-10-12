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
}

/// What's on today's calendar.
enum DocketItem: Identifiable {
    case trial(CourtCase)
    case hearing(ViolationHearing)

    var id: UUID {
        switch self {
        case .trial(let c): return c.id
        case .hearing(let h): return h.id
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
        if let hearing = scheduleViolationHearing() { return .hearing(hearing) }
        return .trial(docketCase())
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
                                  returningDefendant: true, appealStatus: nil), at: 0)
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
                                            returning: returning, usedSignatures: Set(usedSignatures))
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
                                  appealStatus: outcome.appealNotice == nil ? nil : "Appeal pending"), at: 0)

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
            if let personID = event.personID, let index = people.firstIndex(where: { $0.id == personID }) {
                switch event.effect {
                case .releasePerson:
                    people[index].status = .free
                    people[index].releaseDate = nil
                    people[index].probation = nil
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
                history[index].appealStatus = event.effect == .resentence || event.news.headline.contains("vacates sentence")
                    ? "Sentence vacated; remanded for resentencing"
                    : (event.appealReversed ? "New trial ordered on appeal" : "Affirmed on appeal")
            }
        }

        // Sentences expire
        for index in people.indices {
            switch people[index].status {
            case .incarcerated:
                if let release = people[index].releaseDate, release <= currentDate {
                    people[index].releaseDate = nil
                    if let probation = people[index].probation, probation.ends > currentDate {
                        people[index].status = .probation
                    } else {
                        people[index].status = .free
                        people[index].probation = nil
                    }
                }
            case .probation:
                if let probation = people[index].probation, probation.ends <= currentDate {
                    people[index].status = .free
                    people[index].probation = nil
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
                            usedSignatures: usedSignatures, seedBase: seedBase)
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
    }
}
