import Foundation

/// What the treatment team reports at a review: the program, the phase, and how the last period went.
struct TreatmentReviewFacts: Codable, Hashable {
    enum Report: String, Codable { case clean, slip, missed }
    var program: String
    var phase: Int
    var report: Report
    var strikes: Int
    var conditionalDischarge: Bool
}

/// Drug and veterans treatment courts. The person reports to the judge every six weeks or so; the team reports
/// screens, attendance, and work. Four phases, then graduation. Praise, sanctions, and the decision to terminate
/// are the judge's.
enum TreatmentCourts {
    struct Ruling {
        var update: (inout PersonRecord) -> Void
        var later: [PendingEvent]
        var endsProbation = false
        var terminated = false
    }

    static func isVeteran(_ background: String) -> Bool {
        let b = background.lowercased()
        return ["served four years in the navy", "with the army", "marine corps", "in the air force", "enlisted in the army",
                "national guard", "coast guard"].contains { b.contains($0) }
    }

    /// The next review: how the period went depends on the person and on how many setbacks there have been.
    static func reviewMatter(_ person: PersonRecord, term: ProbationTerm, date: Date, rng: inout SeededRNG) -> CalendarMatter? {
        guard let program = term.treatmentCourt else { return nil }
        let phase = term.courtPhase ?? 1
        let strikes = term.courtStrikes ?? 0
        let slip = min(0.6, 0.12 + person.propensity * 0.4 + Double(strikes) * 0.05 - Double(phase - 1) * 0.03)
        let roll = Double.random(in: 0..<1, using: &rng)
        let report: TreatmentReviewFacts.Report = roll < slip * 0.65 ? .slip : (roll < slip ? .missed : .clean)
        let last = person.lastName
        let veteran = program.hasPrefix("Veterans")
        let facts = TreatmentReviewFacts(program: program, phase: phase, report: report, strikes: strikes,
                                         conditionalDischarge: term.conditionalDischarge == true)
        if phase >= 4 && report == .clean {
            return CalendarMatter(
                kind: .treatmentGraduation, personID: person.id, personName: person.name, personAge: person.age(on: date), occupation: person.occupation,
                docket: term.docket,
                summary: "\(person.name) has finished all four phases of \(program): \(rng.int(9...14)) months, every screen clean since phase two, \(rng.pick(["full-time work at the same job for six months", "a GED earned in phase three", "a sponsor and a home group", "custody of a child restored last month"])). The team recommends graduation.\(term.conditionalDischarge == true ? " The case is a conditional discharge: on completion the charge is dismissed." : "")",
                stateAsk: rng.pick(["The State joins the recommendation.", "The State agrees, Judge. This is what the program is for."]),
                defenseAsk: "\(last) would like to say a few words to the court.\(veteran ? " \(last)'s mentor is here too." : "")",
                options: ["Graduate \(last): end probation now\(term.conditionalDischarge == true ? " and dismiss the charge" : "")",
                          "Graduate \(last); probation continues to its end date", "Hold graduation another month"],
                review: facts)
        }
        let period: String
        switch report {
        case .clean:
            period = rng.pick(["Every screen clean, every session attended, and \(last) started a new job at \(rng.pick(["the poultry plant", "a lumber yard", "a body shop", "the hospital laundry"])).",
                               "Clean screens and perfect attendance. \(last) is leading the newcomers' group on Tuesdays.",
                               "All screens negative. \(last) paid off the court costs and moved into a sober-living house."])
        case .slip:
            period = rng.pick(["One positive screen for \(rng.pick(["methamphetamine", "fentanyl", "cocaine", "alcohol"])). \(last) told the case manager before the result came back.",
                               "\(last) relapsed after a death in the family: one positive screen, admitted, and back in treatment the next day.",
                               "A positive screen and a diluted one the week after. \(last) denies using."])
        case .missed:
            period = rng.pick(["\(last) missed two group sessions and one screen, and didn't call the case manager.",
                               "No-show for a screen, then two days late to the next. \(last) says the car broke down.",
                               "\(last) missed a week of treatment and wasn't at the address on file when the officer checked."])
        }
        let summary = "\(program), phase \(phase) of 4. \(period)\(strikes > 0 ? " Earlier setbacks in the program: \(strikes)." : "")"
        let options: [String] = report == .clean
            ? ["Praise \(last) and advance to the next phase", "Praise \(last); stay in this phase another month"]
            : ["Sanction: a weekend in the county jail", "Increase testing and treatment, no jail", "Encourage \(last) and continue as is",
               "Terminate \(last) from the program and send it to a violation hearing"]
        return CalendarMatter(
            kind: .treatmentReview, personID: person.id, personName: person.name, personAge: person.age(on: date), occupation: person.occupation,
            docket: term.docket,
            summary: summary,
            stateAsk: report == .clean ? "The State is pleased, Judge."
                : (strikes >= 2 ? "The State asks the court to terminate. This is the \(strikes + 1)\(strikes + 1 == 3 ? "rd" : "th") setback."
                                : rng.pick(["The State asks for a jail sanction. The team needs to see consequences.", "The State defers to the team's recommendation."])),
            defenseAsk: report == .clean ? "\(last) wants the court to know the team has made the difference."
                : rng.pick(["Relapse is part of recovery, Judge. \(last) came in honest. We ask the court to keep \(last) in.",
                            "The team recommends more treatment, not jail.",
                            "\(last) knows this is serious. One more chance."]),
            options: options,
            review: facts)
    }

    static func resolve(_ m: CalendarMatter, facts r: TreatmentReviewFacts, choice: Int, date: Date, judgeLast: String,
                        rng: inout SeededRNG) -> Ruling {
        let cal = CourtCalendar.calendar
        let name = m.personName, last = name.components(separatedBy: " ").last ?? name
        func due(_ days: Int) -> Date { cal.date(byAdding: .day, value: days, to: date) ?? date }
        if m.kind == .treatmentGraduation {
            let news = PendingEvent(due: due(2), news: NewsItem(date: due(2), kind: .community,
                headline: "\(name) graduates from Hollis County \(r.program)",
                body: "\(name) was among the graduates Judge \(judgeLast) honored this week. \"I didn't think I'd make it,\" \(last) told the room. \(r.program.hasPrefix("Veterans") ? "\(last)'s mentor, a Vietnam veteran, pinned a program coin on \(last)'s jacket." : "The program's coordinator credited the team of treatment providers, probation officers, and the court.")",
                docket: m.docket), personID: m.personID)
            switch choice {
            case 0:
                return Ruling(update: { person in
                    person.probation = nil
                    person.status = .free
                    person.propensity = max(0.03, person.propensity * 0.7)
                    if r.conditionalDischarge { person.priors.removeAll { $0.docket == m.docket } }
                    person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) graduation",
                                                    outcome: r.conditionalDischarge ? "Graduated: probation ended and the charge dismissed" : "Graduated: probation ended"))
                }, later: [news], endsProbation: true)
            case 1:
                return Ruling(update: { person in
                    person.probation?.courtGraduated = true
                    person.propensity = max(0.03, person.propensity * 0.8)
                    person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) graduation",
                                                    outcome: "Graduated; probation continues to its end date"))
                }, later: [news])
            default:
                return Ruling(update: { person in
                    person.probation?.courtReviewDue = due(28)
                    person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) review", outcome: "Graduation held another month"))
                }, later: [])
            }
        }
        // A review.
        let outcome = m.options.indices.contains(choice) ? m.options[choice] : ""
        if r.report == .clean {
            let advance = choice == 0
            return Ruling(update: { person in
                person.probation?.courtPhase = advance ? min(4, r.phase + 1) : r.phase
                person.probation?.courtReviewDue = due(42)
                person.propensity = max(0.03, person.propensity - 0.02)
                person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) review, phase \(r.phase)", outcome: outcome))
            }, later: [])
        }
        switch choice {
        case 0:
            // A short sanction works for most people; it does little for someone who's stopped trying.
            return Ruling(update: { person in
                person.status = .incarcerated
                person.releaseDate = due(2)
                person.releaseNote = "\(r.program) sanction: a weekend in the county jail. The program resumes on release."
                person.probation?.courtStrikes = r.strikes + 1
                person.probation?.courtReviewDue = due(28)
                person.propensity = max(0.03, person.propensity - (r.report == .slip ? 0.04 : 0.02))
                person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) review, phase \(r.phase)", outcome: outcome))
            }, later: [])
        case 1:
            return Ruling(update: { person in
                person.probation?.courtStrikes = r.strikes + 1
                person.probation?.courtReviewDue = due(28)
                person.propensity = max(0.03, person.propensity - (r.report == .slip ? 0.05 : 0.01))
                let added = (person.probation?.conditions ?? []) + ["Twice-weekly testing and an added treatment session, ordered at a \(r.program) review."]
                person.probation?.conditions = added
                person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) review, phase \(r.phase)", outcome: outcome))
            }, later: [])
        case 2:
            return Ruling(update: { person in
                person.probation?.courtStrikes = r.strikes + 1
                person.probation?.courtReviewDue = due(42)
                person.propensity = min(0.95, person.propensity + (r.report == .missed ? 0.04 : 0))
                person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) review, phase \(r.phase)", outcome: outcome))
            }, later: [])
        default:
            return Ruling(update: { person in
                let kept = (person.probation?.conditions ?? []).filter { !$0.contains("Treatment Court") }
                person.probation?.conditions = kept
                person.probation?.courtPhase = nil
                person.probation?.courtReviewDue = nil
                person.appearances.append(.init(docket: m.docket, date: date, charges: "\(r.program) review, phase \(r.phase)",
                                                outcome: "Terminated from the program; a violation report was filed"))
            }, later: [], terminated: true)
        }
    }
}
