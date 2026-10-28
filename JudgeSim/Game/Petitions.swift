import Foundation

/// Petitions heard at the calendar call: expunctions (G.S. 15A-145.5), a surety's motion to set aside a bond
/// forfeiture (G.S. 15A-544.5), and limited driving privileges after an impaired-driving conviction (G.S. 20-179.3).
/// The card gives the facts the law turns on; whether the petition qualifies is for the judge to see. A ruling the
/// law doesn't support comes back as news.
enum Petitions {
    struct Ruling {
        var update: (inout PersonRecord) -> Void
        var later: [PendingEvent]
    }

    static let bondingCompanies = ["Coastal Carolina Bail Bonds", "Second Chance Bonding", "A-1 Bail of Hollis County",
                                   "Riverbend Bonding Company", "Tar Heel Surety Agents"]

    // MARK: - Expunction

    /// Offenses G.S. 15A-145.5 never allows to be expunged under the nonviolent-offense statute.
    static func violentOrExcluded(_ offense: String) -> Bool {
        let o = offense.lowercased()
        return ["assault", "impaired", "sexual", "rape", "stalking", "strangulation", "murder", "manslaughter", "kidnapping",
                "robbery", "firearm", "weapon", "child abuse", "threat", "domestic", "protective order", "death by", "burglary",
                "arson", "trafficking", "cruelty"].contains { o.contains($0) }
    }

    /// Whether the newest conviction can be expunged this year, and why or why not.
    static func expunctionEligibility(priors: [PriorConviction], year: Int) -> (Bool, String) {
        guard let target = priors.max(by: { $0.year < $1.year }) else { return (false, "There is no conviction to expunge.") }
        let others = priors.filter { $0.id != target.id }
        if violentOrExcluded(target.offense) {
            return (false, "\(target.offense) is excluded from expunction under G.S. 15A-145.5 as a violent or listed offense.")
        }
        if target.ncClass.isFelony && target.ncClass.severity < NCClass.H.severity {
            return (false, "Only Class H and I felonies can be expunged under G.S. 15A-145.5; this was Class \(target.ncClass.rawValue).")
        }
        let wait = target.ncClass.isFelony ? 10 : (others.isEmpty ? 5 : 7)
        if year - target.year < wait {
            return (false, "The petition is early: the law requires \(wait) years without a new conviction, and it has been \(year - target.year).")
        }
        if target.ncClass.isFelony && !others.isEmpty {
            return (false, "A felony can be expunged under this statute only when it is the person's one conviction.")
        }
        if others.contains(where: { $0.ncClass.isFelony || violentOrExcluded($0.offense) }) {
            return (false, "The other convictions on the record keep this one from being expunged.")
        }
        return (true, "The conviction is a nonviolent \(target.ncClass.isFelony ? "Class \(target.ncClass.rawValue) felony" : "misdemeanor"), and \(year - target.year) years have passed without another conviction.")
    }

    static func expunctionMatter(personID: UUID, name: String, age: Int, occupation: String, priors: [PriorConviction], year: Int,
                                 newPerson: Bool, docketSequence: Int, rng: inout SeededRNG) -> CalendarMatter? {
        guard let target = priors.max(by: { $0.year < $1.year }) else { return nil }
        let (eligible, reason) = expunctionEligibility(priors: priors, year: year)
        let last = name.components(separatedBy: " ").last ?? name
        let others = priors.count - 1
        let why = rng.pick(["\(last) has been offered a job that requires a clean background check.",
                            "\(last) is finishing nursing school, and the state board asks about every conviction.",
                            "\(last) was turned down for an apartment twice because of the record.",
                            "\(last) wants to coach a youth league team and can't pass the screening.",
                            "\(last) is applying to the Coast Guard reserve."])
        let record = others == 0 ? "No other convictions on the record." : "\(others) other conviction\(others == 1 ? "" : "s") on the record; see the file."
        let stateAsk: String = eligible
            ? rng.pick(["The State takes no position.", "The State doesn't object, Judge.", "The State has reviewed the record and doesn't oppose it."])
            : rng.pick(["The State objects. \(reason)", "The State objects; the petition doesn't meet the statute.",
                        "The State takes no position.", "The State defers to the court."])
        return CalendarMatter(
            kind: .expunction, personID: personID, personName: name, personAge: age, occupation: occupation,
            docket: "\(year % 100) CRS \(String(format: "%06d", docketSequence)) (expunction)",
            summary: "\(name), \(age), petitions to expunge a \(target.year) conviction for \(target.offense.lowercased()) (\(target.ncClass.isFelony ? "Class \(target.ncClass.rawValue) felony" : "misdemeanor")) in \(target.county) County, sentenced to \(target.sentence.lowercased()). \(record) \(why)",
            stateAsk: stateAsk,
            defenseAsk: rng.pick(["\(last) has stayed out of trouble ever since. One mistake shouldn't follow someone forever.",
                                  "My client has a letter from the employer and from the pastor. The record is the only thing standing in the way.",
                                  "My client was \(max(16, age - (year - target.year))) at the time. That isn't who my client is now."]),
            options: ["Grant the petition: expunge the conviction", "Deny the petition"],
            lawID: "expunction", priors: priors,
            petition: PetitionFacts(eligible: eligible, reason: reason, offense: target.offense, priorID: target.id,
                                    newPerson: newPerson ? true : nil))
    }

    // MARK: - Bond forfeiture

    static func forfeitureMatter(personID: UUID, name: String, age: Int, occupation: String, docket: String, date: Date,
                                 newPerson: Bool, rng: inout SeededRNG) -> CalendarMatter {
        let amount = rng.pick([5_000, 7_500, 10_000, 15_000, 25_000, 50_000])
        let company = rng.pick(bondingCompanies)
        let last = name.components(separatedBy: " ").last ?? name
        func earlier(_ days: ClosedRange<Int>) -> String {
            SentenceFormat.shortDate(CourtCalendar.calendar.date(byAdding: .day, value: -rng.int(days), to: date) ?? date)
        }
        // The grounds G.S. 15A-544.5(b) allows, and the ones it doesn't.
        let grounds: [(String, Bool, String)] = [
            ("The surety surrendered \(last) to the Hollis County jail on \(earlier(10...60)); the sheriff's receipt is attached.", true,
             "Surrender by the surety, shown by the sheriff's receipt, is a ground to set aside under G.S. 15A-544.5(b)(3)."),
            ("\(last) was served with the order for arrest on \(earlier(10...60)); the served order is attached.", true,
             "Service of the order for arrest is a ground to set aside under G.S. 15A-544.5(b)(4)."),
            ("\(last) was in state prison in another county on the day of the missed court date; the DAC record is attached.", true,
             "Incarceration in a unit of the Department of Adult Correction at the time is a ground under G.S. 15A-544.5(b)(7)."),
            ("The surety's agents searched for three weeks and hired a recovery agent. \(last) is still at large.", false,
             "Effort alone isn't a ground to set aside under G.S. 15A-544.5(b); the defendant was never returned."),
            ("\(last) was arrested on the order on \(earlier(10...60)), but the motion attaches no sheriff's receipt or served order.", false,
             "The statute requires the documents with the motion; without them, the motion fails."),
            ("\(last) was surrendered on \(earlier(10...60)), but the motion was filed \(rng.int(160...210)) days after the notice of forfeiture.", false,
             "The motion has to be filed within 150 days of the notice of forfeiture (G.S. 15A-544.5(e))."),
        ]
        let g = rng.pick(grounds)
        let schools = rng.chance(g.1 ? 0.25 : 0.7)
        return CalendarMatter(
            kind: .bondForfeiture, personID: personID, personName: name, personAge: age, occupation: occupation,
            docket: docket + " (forfeiture)",
            summary: "\(name) missed court while out on a $\(amount.formatted()) secured bond written by \(company), and the bond was forfeited. \(company) moves to set the forfeiture aside. \(g.0)",
            stateAsk: schools
                ? rng.pick(["The county board of education objects. The forfeiture money goes to the schools, and the statute's grounds aren't met.",
                            "The board of education objects and asks the court to enforce the forfeiture."])
                : rng.pick(["The State takes no position. The board of education filed no objection.", "The State defers to the court."]),
            defenseAsk: rng.pick(["\(company) did its job, Judge. We ask the court to set it aside.",
                                  "Bondsmen keep this courthouse running. Holding us to every technicality drives up bonds for everybody.",
                                  "We've written bonds in this county for twenty years and never asked for anything we weren't owed."]),
            options: ["Set aside the forfeiture", "Deny: the forfeiture stands; the surety pays $\(amount.formatted()) to the schools"],
            lawID: "bondForfeiture",
            petition: PetitionFacts(eligible: g.1, reason: g.2, amount: amount, company: company, newPerson: newPerson ? true : nil))
    }

    // MARK: - Limited driving privilege

    static func privilegeMatter(personID: UUID, name: String, age: Int, occupation: String, docket: String, level: Int?, convicted: Date,
                                date: Date, propensity: Double, newPerson: Bool, rng: inout SeededRNG) -> CalendarMatter {
        let last = name.components(separatedBy: " ").last ?? name
        let lvl = level ?? rng.pick([3, 4, 4, 5, 5, 5, 2])
        let bac = Double(rng.int(8...21)) / 100
        let priorDWI = rng.chance(0.12)
        let licenseValid = rng.chance(0.9)
        let assessed = rng.chance(0.88)
        let interlock = bac >= 0.15
        var reason = "Level \(lvl), a valid license at the time, no impaired-driving conviction in the past seven years, and an assessment on file: eligible under G.S. 20-179.3."
        var eligible = true
        if lvl < 3 { eligible = false; reason = "Level \(lvl) sentences aren't eligible; a privilege is allowed only after Level 3, 4, or 5 (G.S. 20-179.3(b))." }
        else if !licenseValid { eligible = false; reason = "\(last)'s license wasn't valid at the time of the offense, so no privilege can issue." }
        else if priorDWI { eligible = false; reason = "An impaired-driving conviction within the past seven years bars a privilege." }
        else if !assessed { eligible = false; reason = "There is no substance abuse assessment on file, which the statute requires first." }
        let work = rng.pick(["drives a delivery route", "works first shift at the poultry plant in Cane Creek", "is a home health aide with patients in three towns",
                             "works construction sites across the county", "works nights at the hospital in Port Hollis"])
        return CalendarMatter(
            kind: .drivingPrivilege, personID: personID, personName: name, personAge: age, occupation: occupation,
            docket: docket + " (privilege)",
            summary: "\(name), convicted of driving while impaired on \(SentenceFormat.shortDate(convicted)) and sentenced at Level \(lvl), asks for a limited privilege to drive to work, treatment, and school. \(last) \(work). The alcohol concentration was \(String(format: "%.2f", bac)). License valid at the time: \(licenseValid ? "yes" : "no"). Impaired-driving convictions in the past seven years: \(priorDWI ? "one" : "none"). Substance abuse assessment: \(assessed ? "on file" : "not yet done").",
            stateAsk: rng.pick(["The State takes no position if the statute is met.", "The State asks the court to look closely at the record.",
                                "The State objects. \(last) shouldn't be back behind the wheel this soon."]),
            defenseAsk: rng.pick(["Without a privilege, \(last) loses the job. We ask for standard work hours.",
                                  "\(last) has been to every treatment session. We'll accept any conditions the court sets.",
                                  "There's no bus where \(last) lives. It's this or unemployment."]),
            options: ["Grant: drive for work, school, and treatment, 6 a.m. to 8 p.m. weekdays",
                      "Grant, with an ignition interlock on every vehicle \(last) drives", "Deny the privilege"],
            lawID: "limitedPrivilege",
            petition: PetitionFacts(eligible: eligible, reason: reason, risk: min(0.6, propensity * 0.6 + (bac >= 0.15 ? 0.1 : 0)),
                                    interlockRequired: interlock, newPerson: newPerson ? true : nil))
    }

    // MARK: - Rulings

    static func resolve(_ m: CalendarMatter, facts p: PetitionFacts, choice: Int, date: Date, judgeLast: String,
                        rng: inout SeededRNG) -> Ruling {
        let cal = CourtCalendar.calendar
        func later(_ days: ClosedRange<Int>, _ headline: String, _ body: String, kind: NewsItem.Kind = .community) -> PendingEvent {
            let due = cal.date(byAdding: .day, value: rng.int(days), to: date) ?? date
            return PendingEvent(due: due, news: NewsItem(date: due, kind: kind, headline: headline, body: body, docket: m.docket), personID: m.personID)
        }
        let name = m.personName, last = name.components(separatedBy: " ").last ?? name
        var events: [PendingEvent] = []
        switch m.kind {
        case .expunction:
            let granted = choice == 0
            if granted && !p.eligible {
                events.append(later(20...50, "DA asks judge to undo expunction granted in error",
                                    "The district attorney's office has asked Judge \(judgeLast) to set aside an expunction order entered at a recent calendar call, saying the petition didn't qualify: \(p.reason.prefix(1).lowercased() + p.reason.dropFirst()) The petitioner's lawyer says the order should stand."))
            }
            let priorID = p.priorID
            return Ruling(update: { person in
                if granted { person.priors.removeAll { $0.id == priorID } }
                person.appearances.append(.init(docket: m.docket, date: date, charges: "Petition for expunction",
                                                outcome: granted ? "Granted: the conviction was expunged" : "Denied"))
            }, later: events)
        case .bondForfeiture:
            let setAside = choice == 0
            let amount = (p.amount ?? 0).formatted()
            if setAside && !p.eligible {
                events.append(later(15...45, "School board appeals judge's order on $\(amount) bond forfeiture",
                                    "The Hollis County Board of Education has appealed Judge \(judgeLast)'s order setting aside a $\(amount) bond forfeiture in the case of \(name). The board says \(p.company ?? "the surety") showed no ground the statute allows. Forfeited bonds go to the county's public schools."))
            } else if !setAside && p.eligible {
                events.append(later(15...45, "\(p.company ?? "Bonding company") appeals forfeiture ruling",
                                    "\(p.company ?? "A bonding company") has appealed Judge \(judgeLast)'s refusal to set aside a $\(amount) forfeiture on the bond of \(name), saying it met the statute: \(p.reason.prefix(1).lowercased() + p.reason.dropFirst())"))
            } else if !setAside && rng.chance(0.3) {
                events.append(later(20...60, "Bond forfeitures add to school budget",
                                    "Forfeited bonds, including $\(amount) on the bond of \(name) ordered paid by Judge \(judgeLast), will go to Hollis County Schools this year, the finance officer told the school board."))
            }
            return Ruling(update: { person in
                person.appearances.append(.init(docket: m.docket, date: date, charges: "Motion to set aside bond forfeiture (\(p.company ?? "surety"))",
                                                outcome: setAside ? "Granted: forfeiture set aside" : "Denied: forfeiture stands"))
            }, later: events)
        default:
            let granted = choice < 2
            let interlock = choice == 1
            if granted && !p.eligible {
                events.append(later(15...40, "Driving privilege for DWI defendant was not allowed, DA says",
                                    "Prosecutors have asked Judge \(judgeLast) to revoke a limited driving privilege granted to \(name) after an impaired-driving conviction: \(p.reason.prefix(1).lowercased() + p.reason.dropFirst())"))
            } else if granted && p.interlockRequired == true && !interlock {
                events.append(later(15...40, "Privilege issued without required interlock",
                                    "A limited driving privilege granted to \(name) by Judge \(judgeLast) left out the ignition interlock the law requires when the alcohol concentration is 0.15 or more, prosecutors said in asking the court to correct it."))
            }
            if granted, rng.chance((p.risk ?? 0.1) * (interlock ? 0.25 : 1)) {
                events.append(later(40...200, "\(name) charged with DWI while driving on limited privilege",
                                    "A trooper says \(name) was stopped at 11:40 p.m., outside the hours of the limited privilege Judge \(judgeLast) granted after \(last)'s earlier impaired-driving conviction, and blew over the legal limit.",
                                    kind: .arrest))
            }
            return Ruling(update: { person in
                person.appearances.append(.init(docket: m.docket, date: date, charges: "Petition for limited driving privilege",
                                                outcome: granted ? (interlock ? "Granted with an ignition interlock" : "Granted: work, school, and treatment hours") : "Denied"))
            }, later: events)
        }
    }
}
