import Foundation
import SwiftUI

/// Responses available at a probation violation hearing under the Justice Reinvestment Act.
enum HearingDecision: String, CaseIterable, Hashable {
    case continueAsIs, modify, quickDip, crv, revoke, terminate

    var label: String {
        switch self {
        case .continueAsIs: return "No violation found / continue on the same terms"
        case .modify: return "Find a violation; modify conditions"
        case .quickDip: return "Find a violation; order a quick dip (3 days in jail)"
        case .crv: return "Find a violation; order a CRV"
        case .revoke: return "Revoke probation and activate the suspended sentence"
        case .terminate: return "Terminate probation unsuccessfully"
        }
    }

    var detail: String {
        switch self {
        case .continueAsIs: return "Probation continues unchanged."
        case .modify: return "Add or change conditions, and optionally extend the term."
        case .quickDip: return "A short jail stay as a sanction, then probation resumes (G.S. 15A-1343(a1)(3))."
        case .crv: return "Confinement in response to violation: 90 days for a felony, up to 90 days for a misdemeanor, then probation resumes. The time is credited to the suspended sentence (G.S. 15A-1344(d2))."
        case .revoke: return "The statute permits revocation for a new criminal offense, absconding, or after two prior CRVs (G.S. 15A-1344(a))."
        case .terminate: return "Ends supervision now. Unpaid money becomes a civil judgment."
        }
    }
}

enum ViolationFinding: String, CaseIterable, Hashable {
    case established, excused, notProven

    var label: String {
        switch self {
        case .established: return "Violation established"
        case .excused: return "Lawful excuse shown"
        case .notProven: return "Not proven"
        }
    }

    var detail: String {
        switch self {
        case .established: return "You are reasonably satisfied the probationer violated a condition without lawful excuse."
        case .excused: return "The violation happened, but it wasn't willful (for example, inability to pay)."
        case .notProven: return "The State hasn't shown the violation occurred."
        }
    }
}

struct HearingRulings {
    var finding: ViolationFinding?
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
    /// The violation the court found, for the person's record (nil when none was found).
    var violation: SupervisionViolation? = nil
    /// A conditional discharge revoked: the conviction the court entered.
    var newPriors: [PriorConviction] = []
    /// A felony sentence activated: post-release supervision that follows release (G.S. 15A-1368.2).
    var pendingPostRelease: PostReleaseTerm? = nil
}

extension ProbationTerm {
    /// The suspended misdemeanor sentence in days; older saves fall back to months × 30.
    var suspendedDays: Int { activeDays ?? activeMonths * 30 }
    /// Days already served on CRV; older saves assume 90 days for each CRV.
    var crvCreditDays: Int { crvDaysServed ?? (crvCount ?? 0) * 90 }
    /// Misdemeanor days still suspended after CRV credit.
    var remainingDays: Int { max(0, suspendedDays - crvCreditDays) }
    /// Felony months still to serve on revocation after CRV credit.
    var remainingFelonyMonths: Int { max(0, activeMonths - crvCreditDays / 30) }
    var isConditionalDischarge: Bool { conditionalDischarge == true }
}

extension String {
    /// The text without trailing periods, for joining sentences into one line.
    var trimmingTrailingPeriods: String {
        var text = self.trimmingCharacters(in: .whitespaces)
        while text.hasSuffix(".") { text.removeLast() }
        return text
    }

    /// Lowercases only the first character, so proper nouns later in the text keep their capitals.
    var lowercasingFirstLetter: String {
        guard let first else { return self }
        return first.lowercased() + dropFirst()
    }

    /// "a" or "an" before this word.
    var withIndefiniteArticle: String {
        guard let first = first?.lowercased() else { return self }
        return ("aeiou".contains(first) ? "an " : "a ") + self
    }
}

enum ViolationHearings {

    static func canRevoke(_ h: ViolationHearing) -> Bool {
        h.absconded || h.newCriminalConduct || (h.probation.crvCount ?? 0) >= 2
    }

    /// Days of CRV: 90 for a felony; for a misdemeanor up to 90, but never more than the suspended time left (G.S. 15A-1344(d2)).
    static func crvDays(_ term: ProbationTerm) -> Int {
        term.isFelony ? 90 : min(90, term.remainingDays)
    }

    static func crvDays(_ h: ViolationHearing) -> Int { crvDays(h.probation) }

    /// Months left to serve on revocation, after credit for prior CRVs (felony months; misdemeanor days rounded up).
    static func revocationMonths(_ term: ProbationTerm) -> Int {
        term.isFelony ? term.remainingFelonyMonths : Int((Double(term.remainingDays) / 30).rounded(.up))
    }

    /// How much custody revocation activates, in words, e.g. "45 days" or "8 months".
    static func exposureText(_ term: ProbationTerm) -> String {
        term.isFelony
            ? "\(term.remainingFelonyMonths) month\(term.remainingFelonyMonths == 1 ? "" : "s")"
            : "\(term.remainingDays) day\(term.remainingDays == 1 ? "" : "s")"
    }

    /// Probation, including extensions, may not run more than five years in all (G.S. 15A-1342(a)).
    static func maxExtensionMonths(_ term: ProbationTerm) -> Int {
        guard let start = term.starts else { return 60 }
        let served = Calendar.current.dateComponents([.month], from: start, to: term.ends).month ?? 0
        return max(0, 60 - served)
    }

    /// When probation began: the date stored with the term, or the sentencing appearance on that docket.
    static func probationStart(_ person: PersonRecord, _ term: ProbationTerm) -> Date? {
        term.starts ?? person.appearances.first(where: { $0.docket == term.docket })?.date
    }

    /// What revoking probation (or a conditional discharge) puts into effect.
    struct Activation {
        var months = 0
        var days = 0
        var text: String
        /// A conditional discharge revoked: the judgment the court now enters.
        var prior: PriorConviction?
        /// A felony term activated: post-release supervision follows release (G.S. 15A-1368.2).
        var postRelease: PostReleaseTerm?
    }

    static func activation(_ term: ProbationTerm, county: County, date: Date) -> Activation {
        let cls = term.offenseClass ?? (term.isFelony ? .H : .misd1)
        let months = term.isFelony ? term.remainingFelonyMonths : 0
        let days = term.isFelony ? 0 : term.remainingDays
        let credit = term.crvCreditDays
        let creditText = credit > 0 ? ", with credit for \(credit) days already served in confinement in response to violation" : ""
        var result: Activation
        if term.isConditionalDischarge {
            let sentence = term.isFelony
                ? "\(term.activeMonths) to \(StructuredSentencing.maximum(forMinimum: term.activeMonths, cls: cls)) months"
                : "\(term.suspendedDays) days"
            result = Activation(months: months, days: days,
                                text: "The court finds the conditional discharge in \(term.docket) violated, ends the deferral, and enters judgment on \(term.offense) (\(cls.shortLabel)). The defendant is sentenced to \(sentence), active\(creditText).")
            result.prior = PriorConviction(offense: term.offense, ncClass: cls, year: Calendar.current.component(.year, from: date),
                                           county: county.name, sentence: "\(sentence) active, after a conditional discharge was revoked",
                                           fromThisCourt: true, docket: term.docket,
                                           sessionKey: Judgment.sessionKey(county: county, date: date))
        } else if months == 0 && days == 0 {
            result = Activation(text: "Probation in \(term.docket) is revoked. No suspended time remains to activate after credit for time served, so the defendant is released from supervision on that judgment.")
        } else {
            result = Activation(months: months, days: days,
                                text: "Probation in \(term.docket) is revoked. The suspended sentence of \(term.suspendedSentence) is activated\(creditText).")
        }
        if term.isFelony && months > 0 && cls.isFelony {
            let supervision = StructuredSentencing.postReleaseMonths(for: cls)
            let unserved = StructuredSentencing.maximum(forMinimum: term.activeMonths, cls: cls) - term.activeMonths
            result.postRelease = PostReleaseTerm(docket: term.docket, offense: term.offense, ends: date,
                                                 supervisionMonths: supervision, remainingMonths: max(supervision, unserved))
        }
        return result
    }

    static func make(person: PersonRecord, county: County, date: Date, seed: UInt64) -> ViolationHearing? {
        guard var term = person.probation else { return nil }
        var rng = SeededRNG(seed: seed)
        var used = Set([person.name])
        let officer = NameBank.person(using: &rng, excluding: &used)
        let conditions = (term.conditions ?? []).joined(separator: " ").lowercased()
        let need = term.treatmentNeed ?? TreatmentNeed.none
        let monthly = term.monthlyObligation ?? 0
        let supervised = term.supervised ?? true
        let cal = Calendar.current
        // How long the person has been on probation shapes what can have gone wrong.
        let start = probationStart(person, term)
        if term.starts == nil { term.starts = start }
        let elapsed = start.map { max(0, cal.dateComponents([.month], from: $0, to: date).month ?? 0) }

        var candidates: [(text: String, willfulChance: Double)] = []
        if need.substance || conditions.contains("drug") {
            let count = rng.int(2...4)
            candidates.append(("Tested positive for \(rng.pick(["cocaine", "methamphetamine", "fentanyl", "marijuana"])) on \(count) occasions.", need.substance ? 0.45 : 0.8))
        }
        if conditions.contains("community service") {
            let recent = (elapsed ?? 12) > 3 ? "with no hours in the last three months" : "with no hours since the first weeks of probation"
            candidates.append(("Completed \(rng.int(0...20)) of the ordered community service hours, \(recent).", 0.6))
        }
        if monthly > 0 {
            // No more months behind than the months on probation.
            let behind = rng.int(3...8)
            let months = elapsed.map { max(1, min(behind, $0)) } ?? behind
            candidates.append(("\(SentenceFormat.dollars(monthly * months)) in arrears on court-ordered payments.", monthly > 150 ? 0.3 : 0.55))
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
        // Unsupervised probation has no office visits; its regular conditions are to pay and to obey the law.
        if supervised && (candidates.isEmpty || rng.chance(0.3)) {
            candidates.append(("Missed \(rng.int(2...4)) scheduled office visits with the probation officer.", 0.6))
        }

        // Only a supervised probationer can abscond from supervision (G.S. 15A-1343(b)(3a)).
        let absconded = supervised && rng.chance(0.12)
        // With nothing else to violate, an unsupervised probationer comes back to court on a new charge.
        let newCrime = !absconded && (candidates.isEmpty || rng.chance(supervised ? 0.15 : 0.3))
        var picked = candidates.isEmpty ? [] : rng.pick(candidates, count: min(candidates.count, rng.int(1...3)))
        if absconded {
            picked.insert(("Absconded: failed to report and whereabouts were unknown for \(rng.int(35...90)) days, until arrested on an order for arrest.", 0.9), at: 0)
        }
        let female = NameBank.gender(of: person.name) == .female
        let newOffense = rng.pick(["misdemeanor larceny from a Dollar General in \(rng.pick(county.towns))",
                                   "possession of methamphetamine during a traffic stop",
                                   female
                                    ? "simple assault, after a call to a residence in \(rng.pick(county.towns))"
                                    : "assault on a female, after a call to a residence in \(rng.pick(county.towns))",
                                   "driving while license revoked and resisting a public officer"])
        if newCrime {
            picked.insert(("New criminal offense: charged with \(newOffense). The charge is pending in district court; the \(supervised ? "officer" : "State") will offer the underlying facts.", 0.85), at: 0)
        }
        let willfulChance = picked.map { $0.willfulChance }.reduce(0, +) / Double(max(1, picked.count))
        let willful = rng.chance(willfulChance)

        let circumstances = rng.pick([
            "\(person.lastName) lost a job at a warehouse two months in and has been staying with different friends since.",
            supervised ? "\(person.lastName) has no car, and the probation office is a 40-minute bus ride each way."
                       : "\(person.lastName) has no car, and the courthouse is a 40-minute bus ride each way.",
            "\(person.lastName)'s treatment provider closed its Hollis County office in the spring.",
            "\(person.lastName) has been working double shifts to cover rent and child support.",
            "\(person.lastName) was hospitalized for eight days during the reporting period."
        ])
        let explanation = willful
            ? rng.pick(["My client admits the violations. \(person.lastName) got off track and is asking for one more chance.",
                        "My client doesn't contest the report, Judge, but asks the court to consider what's been going on."])
            : rng.pick(["These violations weren't willful, Judge. \(circumstances)",
                        "My client has been trying. \(circumstances) That's not the same as defiance."])

        let count = picked.count == 1 ? "one alleged violation" : "\(picked.count) alleged violations"
        let report = supervised
            ? "Probation/Parole Officer \(officer) of the N.C. Department of Adult Correction, Community Supervision, reports that \(person.name) has \(count) of the judgment in \(term.docket) and requests a hearing."
            : "On unsupervised probation, no officer supervises \(person.name). Based on the clerk's records, the District Attorney's office moves for a hearing on \(count) of the judgment in \(term.docket)."
        let witness = supervised ? "Officer \(officer)" : "Deputy Clerk \(officer)"
        let mainProblem = picked.first.map { "The main problem: \($0.text.lowercasingFirstLetter)" } ?? ""
        // The officer can't have supervised the person since before probation began.
        var since = cal.date(byAdding: .month, value: -rng.int(5...16), to: date) ?? date
        if let start { since = min(date, max(since, start)) }
        let opening = supervised
            ? "\(witness): \"I've supervised \(person.lastName) since \(SentenceFormat.shortDate(since)). " + mainProblem + "\""
            : "\(witness): \"I keep the file in \(term.docket). " + mainProblem + "\""
        let priorViolations = (person.violations ?? []).filter { $0.docket == term.docket }.count
        return ViolationHearing(seed: seed, date: date, personID: person.id, personName: person.name,
                                personAge: person.age(on: date), probation: term,
                                violations: picked.map { $0.text }, absconded: absconded, newCriminalConduct: newCrime,
                                officerName: officer, officerReport: report, defenseExplanation: explanation,
                                prosecutor: "ADA \(rng.pick(county.assistantDAs))",
                                defenseAttorney: "\(rng.pick(county.assistantPDs)), Assistant Public Defender",
                                willful: willful, circumstances: circumstances,
                                admits: rng.chance(willful ? 0.7 : 0.3),
                                officerTestimony: [
                                    opening,
                                    newCrime
                                        ? "\(witness): \"I reviewed the arrest report\(supervised ? " and spoke with the arresting officer" : ""). I'm satisfied it happened the way the report says.\""
                                        : (supervised
                                            ? "\(witness): \"I documented each violation in the case notes and reviewed them with \(person.lastName) at the time.\""
                                            : "\(witness): \"The payment ledger and the community service reports are in the file.\"")
                                ],
                                officerCross: [
                                    willful
                                        ? "On cross, the witness concedes \(person.lastName) never told the \(supervised ? "office" : "court") about any hardship."
                                        : "On cross, the witness concedes the hardship: \(circumstances)",
                                    newCrime ? "The witness admits having no personal knowledge of the new offense and that the charge hasn't been tried." : (supervised ? "The officer agrees \(person.lastName) was never rude or threatening." : "The clerk agrees \(person.lastName) was never contacted about the shortfall.")
                                ],
                                priorViolationCount: priorViolations)
    }

    // MARK: Questions

    static func questions(_ h: ViolationHearing) -> [CounselQuestion] {
        let state = h.prosecutor.components(separatedBy: ",").first ?? h.prosecutor
        let defense = h.defenseAttorney.components(separatedBy: ",").first ?? h.defenseAttorney
        let s = CounselStyle.forName(state, side: .prosecution)
        let d = CounselStyle.forName(defense, side: .defense)
        let last = h.personName.components(separatedBy: " ").last ?? h.personName
        let revocable = canRevoke(h)
        let supervised = h.probation.supervised ?? true
        return [
            CounselQuestion(id: "hv.state.ask", side: .prosecution, question: "What is the State asking for?",
                            answer: s.opener + (revocable
                                ? "revocation. " + (h.absconded ? "The probationer absconded from supervision." : (h.newCriminalConduct ? "The probationer committed a new criminal offense while on probation." : "This is the third violation after two CRVs.")) + " Under the statute, the court may revoke."
                                : (s == .aggressive ? "a \(crvDays(h))-day CRV. Probation only works if the conditions mean something." : "a modification with tighter conditions, and a quick dip so the message lands."))),
            supervised
                ? CounselQuestion(id: "hv.state.officer", side: .prosecution, question: "What does the probation officer say about compliance overall?",
                                  answer: s.opener + (h.willful
                                    ? "Officer \(h.officerName) describes the probationer as avoidant. Phone calls go unanswered, and home visits find no one home."
                                    : "Officer \(h.officerName) says \(last) shows up when transportation allows and has been honest about the problems."))
                : CounselQuestion(id: "hv.state.officer", side: .prosecution, question: "What does the clerk's file show about compliance overall?",
                                  answer: s.opener + (h.willful
                                    ? "the file shows no payments in months and no contact with the court. Unsupervised probation depends on the probationer doing it on their own."
                                    : "the file shows partial payments, then a gap. \(last) has been in touch with the clerk's office about the problems.")),
            CounselQuestion(id: "hv.state.prior", side: .prosecution, question: "Has there been any prior violation or CRV?",
                            answer: s.opener + priorAnswer(h)),
            CounselQuestion(id: "hv.def.explain", side: .defense, question: "What's your client's explanation?",
                            answer: h.defenseExplanation),
            CounselQuestion(id: "hv.def.ask", side: .defense, question: "What is the defense asking for?",
                            answer: d.opener + (h.willful
                                ? "continue probation, add treatment if needed. Jail will cost \(last) the job and the apartment, and then we're back here."
                                : "find these violations were not willful and continue probation. Remit the fees; they're the problem, not the solution.")),
            CounselQuestion(id: "hv.def.circumstances", side: .defense, question: "What's going on in your client's life right now?",
                            answer: h.circumstances),
            CounselQuestion(id: "hv.def.admit", side: .defense, question: "Does your client admit or deny the violations?",
                            answer: d.opener + ((h.admits ?? true)
                                ? "\(last) admits the violations, Judge. We're here on disposition."
                                : "\(last) denies them. We'd ask the State to put on its evidence."))
        ]
    }

    /// The State's answer about earlier violations in this case, from the person's record.
    static func priorAnswer(_ h: ViolationHearing) -> String {
        let crvs = h.probation.crvCount ?? 0
        let found = max(h.priorViolationCount ?? 0, crvs)
        guard found > 0 else {
            return h.priorViolationCount == nil ? "no CRV has been ordered in this case." : "no prior violations have been found in this case."
        }
        var text = "yes. The court has found \(found == 1 ? "one earlier violation" : "\(found) earlier violations") in this case, so this would be violation number \(found + 1)"
        if crvs > 0 { text += ", and there \(crvs == 1 ? "has been one prior CRV" : "have been \(crvs) prior CRVs")" }
        return text + "."
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
        var newPriors: [PriorConviction] = []
        var pendingPostRelease: PostReleaseTerm?

        if r.remitFees {
            term.monthlyObligation = 0
            lines.append("Remaining fees and costs are remitted.")
            risk -= 0.06
        }

        switch decision {
        case .continueAsIs:
            lines.insert((r.finding ?? .established) == .established
                ? "The court finds a violation but, in its discretion, continues probation on the same terms."
                : "The court finds no willful violation. Probation continues on the same terms.", at: 0)
        case .modify:
            lines.insert((r.finding ?? .established) == .established
                ? "The court finds the probationer in willful violation and modifies the judgment."
                : "For good cause shown, the court modifies the conditions of probation (G.S. 15A-1344(d)).", at: 0)
            if r.addTreatment { addedConditions.append("Obtain a substance abuse and mental health assessment and complete recommended treatment."); risk -= 0.08; propensityChange -= 0.05 }
            if r.addTesting { addedConditions.append("Submit to random drug testing."); risk += 0.03 }
            if r.addCurfew { addedConditions.append("Curfew from 9:00 p.m. to 6:00 a.m."); risk += 0.02; propensityChange -= 0.02 }
            if r.addHouseArrest { addedConditions.append("House arrest with electronic monitoring for 60 days."); risk += 0.03; propensityChange -= 0.03 }
            // Probation may not run more than five years in all (G.S. 15A-1342(a)).
            let extend = min(r.extendMonths, maxExtensionMonths(term))
            if extend > 0 {
                term.ends = Calendar.current.date(byAdding: .month, value: extend, to: term.ends) ?? term.ends
                lines.append("Probation extended \(extend) months.")
            }
        case .quickDip:
            lines.insert("The court finds a willful violation and orders the probationer to serve 3 days in the Hollis County jail as a quick dip, after which probation resumes.", at: 0)
            risk -= 0.03
        case .crv:
            let days = crvDays(h)
            if days > 0 {
                term.crvCount = (term.crvCount ?? 0) + 1
                term.crvDaysServed = term.crvCreditDays + days
                lines.insert("The court finds a willful violation and orders a \(days)-day period of confinement in response to violation (G.S. 15A-1344(d2)), credited against the suspended sentence. Probation resumes on release.", at: 0)
                status = .incarcerated
                release = Calendar.current.date(byAdding: .day, value: days, to: date)
            } else {
                lines.insert("The court finds a willful violation, but no suspended time remains to serve as confinement in response to violation. Probation continues.", at: 0)
            }
            risk -= 0.02
        case .revoke:
            let activated = activation(term, county: county, date: date)
            lines.insert(activated.text, at: 0)
            if let prior = activated.prior { newPriors.append(prior) }
            pendingPostRelease = activated.postRelease
            if activated.months > 0 || activated.days > 0 {
                status = .incarcerated
                let afterMonths = Calendar.current.date(byAdding: .month, value: activated.months, to: date) ?? date
                release = Calendar.current.date(byAdding: .day, value: activated.days, to: afterMonths)
            } else {
                status = .free
            }
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
        // Probationers appeal an unauthorized sanction often, but not always.
        var appealRNG = SeededRNG(seed: h.seed ^ 0xA_9915)
        let appeals = appealRNG.chance(0.6)
        let finding = r.finding ?? .established
        // A violation goes on the record only when the court finds one, whatever it then orders.
        let violation: SupervisionViolation? = finding == .established
            ? SupervisionViolation(docket: term.docket, date: date, kind: "Probation violation",
                                   conduct: h.violations.map(\.trimmingTrailingPeriods).joined(separator: "; "),
                                   result: decision.label)
            : nil
        let sanction = [HearingDecision.quickDip, .crv, .revoke].contains(decision)
        if finding != .established {
            lines.insert(finding == .excused
                ? "The court finds the probationer has shown lawful excuse for the alleged violations."
                : "The court finds the State has not proven the alleged violations.", at: 1)
        }
        if sanction && finding != .established {
            lines.append("Note: a sanction was imposed without finding a violation.")
            if appeals && decision != .quickDip {
            let due = Calendar.current.date(byAdding: .day, value: 140, to: date) ?? date
            pending.append(PendingEvent(due: due,
                                        news: NewsItem(date: due, kind: .appeal,
                                                       headline: "Court of Appeals vacates probation order for \(h.personName)",
                                                       body: "The Court of Appeals held that Judge \(judgeLast) could not impose a sanction after finding no willful violation of probation, and vacated the order.",
                                                       docket: term.docket + " (PV)"),
                                        personID: h.personID, effect: .resentence, appealReversed: true, newReleaseDate: due,
                                        restoreProbation: h.probation, removesViolationID: violation?.id))
            }
        } else if decision == .revoke && !canRevoke(h) {
            lines.append("Note: the record does not show a new offense, absconding, or two prior CRVs.")
            if appeals {
            let due = Calendar.current.date(byAdding: .day, value: 150, to: date) ?? date
            pending.append(PendingEvent(due: due,
                                        news: NewsItem(date: due, kind: .appeal,
                                                       headline: "Court of Appeals reverses probation revocation of \(h.personName)",
                                                       body: "The Court of Appeals held that Judge \(judgeLast) lacked statutory authority to revoke probation for technical violations alone under G.S. 15A-1344(a), and remanded. \(h.personName) was released from custody.",
                                                       docket: term.docket + " (PV)"),
                                        personID: h.personID, effect: .resentence, appealReversed: true, newReleaseDate: due,
                                        restoreProbation: h.probation, removesViolationID: violation?.id))
            }
        }

        let keepsProbation = decision != .revoke && decision != .terminate
        let headline: String
        switch decision {
        case .revoke: headline = "Probation revoked for \(h.personName)"
        case .crv: headline = "\(h.personName) ordered to \(crvDays(h)) days for probation violations"
        case .terminate: headline = "Judge ends probation for \(h.personName)"
        default: headline = "\(h.personName) remains on probation after violation hearing"
        }
        let body = "At a probation violation hearing in Hollis County Superior Court, Judge \(judgeLast) heard a report that \(h.personName), \(h.personAge), " +
            "had \(h.violations.count == 1 ? "violated a condition" : "violated several conditions") of probation in \(term.docket). " + lines[0]
        let news = NewsItem(date: date, kind: .verdict, headline: headline, body: body, docket: term.docket + " (PV)", prominence: 1)

        return HearingOutcome(lines: lines, status: status, releaseDate: release,
                              probation: keepsProbation ? term : nil,
                              propensityChange: propensityChange, news: news,
                              appearance: "Probation violation hearing: " + appearanceSummary(decision, finding: finding, term: h.probation),
                              pending: pending,
                              violation: violation,
                              newPriors: newPriors,
                              pendingPostRelease: pendingPostRelease)
    }

    /// A short summary of the order for the person's record, e.g. "violation found; 45-day CRV".
    static func appearanceSummary(_ decision: HearingDecision, finding: ViolationFinding, term: ProbationTerm) -> String {
        let found = finding == .established ? "violation found; " : (finding == .excused ? "lawful excuse shown; " : "violation not proven; ")
        switch decision {
        case .continueAsIs: return found + "probation continued"
        case .modify: return found + "conditions modified"
        case .quickDip: return found + "3-day quick dip"
        case .crv:
            let days = crvDays(term)
            return found + (days > 0 ? "\(days)-day CRV" : "probation continued")
        case .revoke: return found + (term.isConditionalDischarge ? "conditional discharge revoked; judgment entered" : "probation revoked")
        case .terminate: return found + "probation terminated unsuccessfully"
        }
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

    func allQuestions(_ side: Side) -> [CounselQuestion] {
        ViolationHearings.questions(hearing).filter { $0.side == side }
    }

    func brief(for side: Side, compact: Bool) -> String { CounselBrief.make(for: hearing, side: side, compact: compact) }

    func heldBackFactor(for side: Side) -> CounselReveal? { nil }

    func record(side: Side, question: String, answer: String, reveal: CounselReveal?) {
        transcript.append(TranscriptEntry(side: side, speaker: counselName(side), question: question, answer: answer, reveal: nil))
        if let preset = allQuestions(side).first(where: { $0.answer == answer }) { askedIDs.insert(preset.id) }
    }

    func finish() {
        withAnimation(.easeInOut) {
            outcome = ViolationHearings.evaluate(hearing, rulings, judgeName: judgeName, county: county, date: hearing.date)
        }
    }
}
