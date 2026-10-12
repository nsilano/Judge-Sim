import Foundation
import SwiftUI

/// Responses available at a probation violation hearing under the Justice Reinvestment Act.
enum HearingDecision: String, CaseIterable, Hashable {
    case continueAsIs, modify, quickDip, crv, revoke, terminate

    var label: String {
        switch self {
        case .continueAsIs: return "No violation found / continue on the same terms"
        case .modify: return "Find a violation; modify conditions"
        case .quickDip: return "Find a violation; order a quick dip (2–3 days in jail)"
        case .crv: return "Find a violation; order a 90-day CRV"
        case .revoke: return "Revoke probation and activate the suspended sentence"
        case .terminate: return "Terminate probation unsuccessfully"
        }
    }

    var detail: String {
        switch self {
        case .continueAsIs: return "Probation continues unchanged."
        case .modify: return "Add or change conditions, and optionally extend the term."
        case .quickDip: return "A short jail stay as a sanction, then probation resumes (G.S. 15A-1343(a1)(3))."
        case .crv: return "Confinement in response to violation: 90 days in custody, then probation resumes (G.S. 15A-1344(d2))."
        case .revoke: return "The statute permits revocation for a new criminal offense, absconding, or after two prior CRVs (G.S. 15A-1344(a))."
        case .terminate: return "Ends supervision now. Unpaid money becomes a civil judgment."
        }
    }
}

struct HearingRulings {
    var decision: HearingDecision?
    var addTreatment = false
    var addTesting = false
    var addCurfew = false
    var addHouseArrest = false
    var extendMonths = 0
    var remitFees = false
}

struct HearingOutcome {
    var lines: [String]
    var status: PersonRecord.Status
    var releaseDate: Date?
    var probation: ProbationTerm?
    var propensityChange: Double
    var news: NewsItem
    var appearance: String
    var pending: [PendingEvent] = []
}

enum ViolationHearings {

    static func canRevoke(_ h: ViolationHearing) -> Bool {
        h.absconded || h.newCriminalConduct || (h.probation.crvCount ?? 0) >= 2
    }

    static func make(person: PersonRecord, county: County, date: Date, seed: UInt64) -> ViolationHearing? {
        guard let term = person.probation else { return nil }
        var rng = SeededRNG(seed: seed)
        var used = Set([person.name])
        let officer = NameBank.person(using: &rng, excluding: &used)
        let conditions = (term.conditions ?? []).joined(separator: " ").lowercased()
        let need = term.treatmentNeed ?? TreatmentNeed.none
        let monthly = term.monthlyObligation ?? 0

        var candidates: [(text: String, willfulChance: Double)] = []
        if need.substance || conditions.contains("drug") {
            let count = rng.int(2...4)
            candidates.append(("Tested positive for \(rng.pick(["cocaine", "methamphetamine", "fentanyl", "marijuana"])) on \(count) occasions.", need.substance ? 0.45 : 0.8))
        }
        if conditions.contains("community service") {
            candidates.append(("Completed \(rng.int(0...20)) of the ordered community service hours, with no hours in the last three months.", 0.6))
        }
        if monthly > 0 {
            let arrears = monthly * rng.int(3...8)
            candidates.append(("\(SentenceFormat.dollars(arrears)) in arrears on court-ordered payments.", monthly > 150 ? 0.3 : 0.55))
        }
        if conditions.contains("curfew") || conditions.contains("house arrest") {
            candidates.append(("Curfew violations recorded on \(rng.int(3...9)) nights by electronic monitoring.", 0.7))
        }
        if conditions.contains("treatment") || conditions.contains("evaluation") {
            candidates.append(("Discharged from the treatment program for non-attendance.", need != .none ? 0.4 : 0.7))
        }
        if conditions.contains("no contact") {
            candidates.append(("Sent text messages to the victim on two occasions in violation of the no-contact condition.", 0.85))
        }
        if candidates.isEmpty || rng.chance(0.3) {
            candidates.append(("Missed \(rng.int(2...4)) scheduled office visits with the probation officer.", 0.6))
        }

        let absconded = rng.chance(0.12)
        var picked = rng.pick(candidates, count: min(candidates.count, rng.int(1...3)))
        if absconded {
            picked.insert(("Absconded: failed to report and whereabouts were unknown for \(rng.int(35...90)) days, until arrested on an order for arrest.", 0.9), at: 0)
        }
        let willfulChance = picked.map { $0.willfulChance }.reduce(0, +) / Double(max(1, picked.count))
        let willful = rng.chance(willfulChance)

        let circumstances = rng.pick([
            "\(person.lastName) lost a job at a warehouse two months in and has been staying with different friends since.",
            "\(person.lastName) has no car, and the probation office is a 40-minute bus ride each way.",
            "\(person.lastName)'s treatment provider closed its Hollis County office in the spring.",
            "\(person.lastName) has been working double shifts to cover rent and child support.",
            "\(person.lastName) was hospitalized for eight days during the reporting period."
        ])
        let explanation = willful
            ? rng.pick(["My client admits the violations. \(person.lastName) got off track and is asking for one more chance.",
                        "My client doesn't contest the report, Judge, but asks the court to consider what's been going on."])
            : rng.pick(["These violations weren't willful, Judge. \(circumstances)",
                        "My client has been trying. \(circumstances) That's not the same as defiance."])

        let report = "Probation Officer \(officer) reports that \(person.name) has \(picked.count == 1 ? "one alleged violation" : "\(picked.count) alleged violations") of the judgment in \(term.docket) and requests a hearing."
        return ViolationHearing(seed: seed, date: date, personID: person.id, personName: person.name,
                                personAge: person.age(on: date), probation: term,
                                violations: picked.map { $0.text }, absconded: absconded, newCriminalConduct: false,
                                officerName: officer, officerReport: report, defenseExplanation: explanation,
                                prosecutor: "ADA \(rng.pick(county.assistantDAs))",
                                defenseAttorney: "\(rng.pick(county.assistantPDs)), Assistant Public Defender",
                                willful: willful, circumstances: circumstances)
    }

    // MARK: Questions

    static func questions(_ h: ViolationHearing) -> [CounselQuestion] {
        let state = h.prosecutor.components(separatedBy: ",").first ?? h.prosecutor
        let defense = h.defenseAttorney.components(separatedBy: ",").first ?? h.defenseAttorney
        let s = CounselStyle.forName(state, side: .prosecution)
        let d = CounselStyle.forName(defense, side: .defense)
        let last = h.personName.components(separatedBy: " ").last ?? h.personName
        let revocable = canRevoke(h)
        return [
            CounselQuestion(id: "hv.state.ask", side: .prosecution, question: "What is the State asking for?",
                            answer: s.opener + (revocable
                                ? "revocation. " + (h.absconded ? "The probationer absconded from supervision." : "This is the third violation after two CRVs.") + " Under the statute, the court may revoke."
                                : (s == .aggressive ? "a 90-day CRV. Probation only works if the conditions mean something." : "a modification with tighter conditions, and a quick dip so the message lands."))),
            CounselQuestion(id: "hv.state.officer", side: .prosecution, question: "What does the probation officer say about compliance overall?",
                            answer: s.opener + (h.willful
                                ? "Officer \(h.officerName) describes the probationer as avoidant. Phone calls go unanswered, and home visits find no one home."
                                : "Officer \(h.officerName) says \(last) shows up when transportation allows and has been honest about the problems.")),
            CounselQuestion(id: "hv.state.prior", side: .prosecution, question: "Has there been any prior violation or CRV?",
                            answer: s.opener + ((h.probation.crvCount ?? 0) > 0
                                ? "yes. This would be violation number \((h.probation.crvCount ?? 0) + 1), and there's been a prior CRV."
                                : "no prior violations have been filed in this case.")),
            CounselQuestion(id: "hv.def.explain", side: .defense, question: "What's your client's explanation?",
                            answer: h.defenseExplanation),
            CounselQuestion(id: "hv.def.ask", side: .defense, question: "What is the defense asking for?",
                            answer: d.opener + (h.willful
                                ? "continue probation, add treatment if needed. Jail will cost \(last) the job and the apartment, and then we're back here."
                                : "find these violations were not willful and continue probation. Remit the fees; they're the problem, not the solution.")),
            CounselQuestion(id: "hv.def.circumstances", side: .defense, question: "What's going on in your client's life right now?",
                            answer: h.circumstances)
        ]
    }

    // MARK: Decision

    static func evaluate(_ h: ViolationHearing, _ r: HearingRulings, judgeName: String, county: County, date: Date) -> HearingOutcome {
        var term = h.probation
        var lines: [String] = []
        var status: PersonRecord.Status = .probation
        var release: Date?
        var propensityChange = 0.0
        var risk = term.violationRisk ?? 0.2
        let decision = r.decision ?? .continueAsIs
        let judgeLast = judgeName.components(separatedBy: " ").last ?? judgeName
        var addedConditions: [String] = []

        if r.remitFees {
            term.monthlyObligation = 0
            lines.append("Remaining fees and costs are remitted.")
            risk -= 0.06
        }

        switch decision {
        case .continueAsIs:
            lines.insert("The court \(h.willful ? "declines to find a willful violation" : "finds no willful violation"). Probation continues on the same terms.", at: 0)
        case .modify:
            lines.insert("The court finds the probationer in willful violation and modifies the judgment.", at: 0)
            if r.addTreatment { addedConditions.append("Obtain a substance abuse and mental health assessment and complete recommended treatment."); risk -= 0.08; propensityChange -= 0.05 }
            if r.addTesting { addedConditions.append("Submit to random drug testing."); risk += 0.03 }
            if r.addCurfew { addedConditions.append("Curfew from 9:00 p.m. to 6:00 a.m."); risk += 0.02; propensityChange -= 0.02 }
            if r.addHouseArrest { addedConditions.append("House arrest with electronic monitoring for 60 days."); risk += 0.03; propensityChange -= 0.03 }
            if r.extendMonths > 0 {
                term.ends = Calendar.current.date(byAdding: .month, value: r.extendMonths, to: term.ends) ?? term.ends
                lines.append("Probation extended \(r.extendMonths) months.")
            }
        case .quickDip:
            lines.insert("The court finds a willful violation and orders the probationer to serve 3 days in the Hollis County jail as a quick dip, after which probation resumes.", at: 0)
            risk -= 0.03
        case .crv:
            term.crvCount = (term.crvCount ?? 0) + 1
            lines.insert("The court finds a willful violation and orders a 90-day period of confinement in response to violation. Probation resumes on release.", at: 0)
            status = .incarcerated
            release = Calendar.current.date(byAdding: .day, value: 90, to: date)
            risk -= 0.02
        case .revoke:
            lines.insert("Probation is revoked. The suspended sentence of \(term.suspendedSentence) is activated.", at: 0)
            status = .incarcerated
            release = Calendar.current.date(byAdding: .month, value: max(1, term.activeMonths), to: date)
        case .terminate:
            lines.insert("Probation is terminated unsuccessfully. Any unpaid monetary obligations are docketed as a civil judgment.", at: 0)
            status = .free
        }
        if !addedConditions.isEmpty {
            lines.append(contentsOf: addedConditions.map { "Added condition: \($0)" })
            term.conditions = (term.conditions ?? []) + addedConditions
        }
        if !h.willful && (decision == .crv || decision == .revoke) { propensityChange += 0.05 }
        term.violationRisk = min(0.7, max(0.03, risk))

        var pending: [PendingEvent] = []
        if decision == .revoke && !canRevoke(h) {
            lines.append("Note: the record does not show a new offense, absconding, or two prior CRVs.")
            let due = Calendar.current.date(byAdding: .day, value: 150, to: date) ?? date
            pending.append(PendingEvent(due: due,
                                        news: NewsItem(date: due, kind: .appeal,
                                                       headline: "Court of Appeals reverses probation revocation of \(h.personName)",
                                                       body: "The Court of Appeals held that Judge \(judgeLast) lacked statutory authority to revoke probation for technical violations alone under G.S. 15A-1344(a), and remanded. \(h.personName) was released from custody.",
                                                       docket: term.docket),
                                        personID: h.personID, effect: .resentence, appealReversed: true, newReleaseDate: due))
        }

        let keepsProbation = decision != .revoke && decision != .terminate
        let headline: String
        switch decision {
        case .revoke: headline = "Probation revoked for \(h.personName)"
        case .crv: headline = "\(h.personName) ordered to 90 days for probation violations"
        case .terminate: headline = "Judge ends probation for \(h.personName)"
        default: headline = "\(h.personName) remains on probation after violation hearing"
        }
        let body = "At a probation violation hearing in Hollis County Superior Court, Judge \(judgeLast) heard a report that \(h.personName), \(h.personAge), " +
            "had \(h.violations.count == 1 ? "violated a condition" : "violated several conditions") of probation in \(term.docket). " + lines[0]
        let news = NewsItem(date: date, kind: .verdict, headline: headline, body: body, docket: term.docket)

        return HearingOutcome(lines: lines, status: status, releaseDate: release,
                              probation: keepsProbation ? term : nil,
                              propensityChange: propensityChange, news: news,
                              appearance: "Probation violation hearing: \(decision.label.lowercased())",
                              pending: pending)
    }
}

/// Live state of a violation hearing in progress.
final class HearingSession: ObservableObject {
    let hearing: ViolationHearing
    let judgeName: String
    let county: County
    @Published var rulings = HearingRulings()
    @Published private(set) var outcome: HearingOutcome?
    @Published private(set) var transcript: [TranscriptEntry] = []
    private var askedIDs = Set<String>()

    init(hearing: ViolationHearing, judgeName: String, county: County) {
        self.hearing = hearing
        self.judgeName = judgeName
        self.county = county
    }

    func counselName(_ side: Side) -> String {
        let raw = side == .prosecution ? hearing.prosecutor : hearing.defenseAttorney
        return raw.components(separatedBy: ",").first ?? raw
    }

    func counselStyle(_ side: Side) -> CounselStyle { CounselStyle.forName(counselName(side), side: side) }

    func availableQuestions(_ side: Side) -> [CounselQuestion] {
        ViolationHearings.questions(hearing).filter { $0.side == side && !askedIDs.contains($0.id) }
    }

    func entries(for side: Side) -> [TranscriptEntry] { transcript.filter { $0.side == side } }

    var unaskedCount: Int { ViolationHearings.questions(hearing).filter { !askedIDs.contains($0.id) }.count }

    func ask(_ question: CounselQuestion) {
        guard !askedIDs.contains(question.id) else { return }
        askedIDs.insert(question.id)
        transcript.append(TranscriptEntry(side: question.side, speaker: counselName(question.side),
                                          question: question.question, answer: question.answer, reveal: nil))
    }

    var canRevoke: Bool { ViolationHearings.canRevoke(hearing) }

    func finish() {
        withAnimation(.easeInOut) {
            outcome = ViolationHearings.evaluate(hearing, rulings, judgeName: judgeName, county: county, date: hearing.date)
        }
    }
}
