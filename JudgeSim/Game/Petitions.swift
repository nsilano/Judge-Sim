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
        let why = Variety.pick(["Needs it for a job offer.", "Finishing nursing school.", "Turned down for apartments because of it.",
                            "Wants to coach a youth league.", "Applying to the Coast Guard reserve.", "Applying to a nursing program.", "Wants to open a food truck and the permit asks about convictions.", "Trying to rent a home for a family.", "Applying for a commercial driver's license.", "Wants to volunteer at a school.", "Seeking a promotion that requires a background check.", "Applying to the volunteer fire department."], rng: &rng)
        let record = others == 0 ? "No other convictions." : "\(others) other conviction\(others == 1 ? "" : "s")."
        let stateAsk: String = eligible
            ? rng.pick(["No position.", "No objection.", "No objection to the petition.", "The State does not oppose.", "No position; the record is clean.", "The State has reviewed the file and has no objection.", "Doesn't oppose.", "The State takes no position on this petition."])
            : Variety.pick(["Objects: \(reason)", "Objects: doesn't meet the statute.", "No position.", "Objects: a waiting period has not run.", "Objects: the statute doesn't allow it for this offense.", "Objects: later convictions are on the record.", "Objects: the petitioner has a pending charge.", "Objects: the statutory period has not passed.", "Objects: a prior expungement was already granted.", "Objects: the conviction is of a type the statute excludes.", "Objects: the petition doesn't include the required affidavits.", "Objects: the petitioner has not paid all fines and costs."], rng: &rng)
        return CalendarMatter(
            kind: .expunction, personID: personID, personName: name, personAge: age, occupation: occupation,
            docket: "\(year % 100) CRS \(String(format: "%06d", docketSequence)) (expunction)",
            summary: "\(name), \(age), asks to expunge a \(target.year) \(target.offense.lowercased()) conviction (\(target.ncClass.isFelony ? "Class \(target.ncClass.rawValue) felony" : "misdemeanor")). \(record) \(why)",
            stateAsk: stateAsk,
            defenseAsk: Variety.pick(["Clean ever since; one mistake shouldn't follow forever.",
                                  "Has letters from an employer and a pastor.",
                                  "Was \(max(16, age - (year - target.year))) at the time; a different person now.", "Has completed every condition and held a steady job since.", "The conviction costs a job offer every time it shows up.", "Has raised a family and stayed out of trouble for years.", "Wants the chance the statute gives a person who has changed.", "Has stayed out of trouble since and wants a fresh start.", "Needs the record cleared to qualify for a better job.", "Has been volunteering at a church food pantry for years.", "The conviction keeps showing up on background checks and costs housing applications.", "Has finished school and wants to start a career the record blocks.", "Has been sober and working since the conviction."], rng: &rng),
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
            summary: "\(company) asks to set aside the forfeited $\(amount.formatted()) bond for \(name). \(g.0)",
            stateAsk: schools
                ? rng.pick(["School board objects: grounds not met.", "School board asks to enforce it.", "School board objects: the defendant was not surrendered in time.", "School board says the schools are owed the full amount.", "School board objects: the surety did not act promptly.", "School board asks the court to keep the forfeiture in place.", "School board says the notice requirements were met.", "School board objects: no evidence the defendant could not have appeared.", "School board says the forfeited money is owed to the county schools.", "School board objects: the surety took the risk when it wrote the bond."])
                : rng.pick(["No position; no objection filed.", "Defers to the court.", "The school board did not appear.", "No objection from the school board.", "School board takes no position.", "No one appeared for the school board.", "No objection filed by the school board.", "The school board left the matter to the court.", "School board offered no response.", "The school board did not oppose the motion."]),
            defenseAsk: rng.pick(["\(company) did its job; set it aside.", "Asks the court not to hold bondsmen to every technicality.", "The defendant was in custody elsewhere on that date; the surety could not have produced them.", "The surety surrendered the defendant within the statutory period.", "\(company) paid for a fugitive recovery agent; it should not also lose the bond.", "The missed date came from a clerical error in the notice.", "\(company) acted quickly once the defendant missed court, and the delay was not its fault.", "The notice of forfeiture went to the wrong address, and \(company) never received it.", "The defendant was in the hospital on the court date, and \(company) has the records.", "\(company) located the defendant and returned the defendant to custody; the forfeiture should be set aside.", "The defendant died before the forfeiture became final.", "The defendant was in federal custody on the court date."]),
            options: ["Set aside the forfeiture", "Deny: the forfeiture stands; the surety pays $\(amount.formatted()) to the schools"],
            lawID: "bondForfeiture",
            petition: PetitionFacts(eligible: g.1, reason: g.2, amount: amount, company: company, newPerson: newPerson ? true : nil))
    }

    // MARK: - Limited driving privilege

    /// The blood-alcohol figure a case's text states (".12", "0.09"), when it states one.
    static func bac(in text: String) -> Double? {
        guard let range = text.regexRange(of: #"(?<![0-9])0?\.(0[89]|1[0-9]|2[01])(?![0-9])"#, options: .regularExpression) else { return nil }
        return Double(text[range].hasPrefix("0") ? String(text[range]) : "0" + String(text[range]))
    }

    static func privilegeMatter(personID: UUID, name: String, age: Int, occupation: String, docket: String, level: Int?, convicted: Date,
                                date: Date, propensity: Double, newPerson: Bool, knownBAC: Double? = nil, priorDWI knownPrior: Bool? = nil,
                                rng: inout SeededRNG) -> CalendarMatter {
        let last = name.components(separatedBy: " ").last ?? name
        let lvl = level ?? rng.pick([3, 4, 4, 5, 5, 5, 2])
        let bac = knownBAC ?? Double(rng.int(8...21)) / 100
        let priorDWI = knownPrior ?? rng.chance(0.12)
        let licenseValid = rng.chance(0.9)
        let assessed = rng.chance(0.88)
        let interlock = bac >= 0.15
        var reason = "Level \(lvl), a valid license at the time, no impaired-driving conviction in the past seven years, and an assessment on file: eligible under G.S. 20-179.3."
        var eligible = true
        if lvl < 3 { eligible = false; reason = "Level \(lvl) sentences aren't eligible; a privilege is allowed only after Level 3, 4, or 5 (G.S. 20-179.3(b))." }
        else if !licenseValid { eligible = false; reason = "\(last)'s license wasn't valid at the time of the offense, so no privilege can issue." }
        else if priorDWI { eligible = false; reason = "An impaired-driving conviction within the past seven years bars a privilege." }
        else if !assessed { eligible = false; reason = "There is no substance abuse assessment on file, which the statute requires first." }
        return CalendarMatter(
            kind: .drivingPrivilege, personID: personID, personName: name, personAge: age, occupation: occupation,
            docket: docket + " (privilege)",
            summary: "\(name): DWI Level \(lvl) (\(SentenceFormat.shortDate(convicted))), asks to drive to work and treatment. BAC \(String(format: "%.2f", bac)) · license valid: \(licenseValid ? "yes" : "no") · DWI in 7 years: \(priorDWI ? "yes" : "no") · assessment: \(assessed ? "done" : "not done").",
            stateAsk: Variety.pick(["No position if the statute is met.", "Asks for a close look at the record.", "Objects: too soon.", "No position if the work letter is genuine.", "Asks that an ignition interlock be required.", "Objects: the record shows an earlier violation of a privilege.", "No position if the BAC and the record support it.", "Asks for a restricted privilege with limited hours.", "No position if treatment is verified.", "Objects until proof of assessment is filed.", "Asks that the privilege be limited to work and treatment only.", "Asks the court to require proof of insurance.", "No position if the employer's letter is verified."], rng: &rng),
            defenseAsk: Variety.pick(["Loses the job without it.", "Attending every treatment session.", "No bus where \(last) lives.", "No bus runs to the job site.", "Needs to get a child to school and to treatment.", "Has a doctor's letter for regular appointments.", "Is the only driver in the household.", "Needs to get to a second job across the county.", "The only way to the treatment program is by car.", "Drives a coworker who has no license to the same job site.", "Has an employer who will only keep the job if driving is allowed.", "Needs to pick up a parent from dialysis three days a week.", "Works early shifts when no bus is running."], rng: &rng),
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
                events.append(later(20...50, "DA asks judge to undo \(name)'s expunction",
                                    "The district attorney's office has asked Judge \(judgeLast) to set aside the expunction order entered for \(name) (\(m.docket)) at a recent calendar call, saying the petition didn't qualify: \(p.reason.prefix(1).lowercased() + p.reason.dropFirst()) \(last)'s lawyer says the order should stand."))
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
            if granted && p.interlockRequired == true && !interlock {
                events.append(later(15...40, "Privilege issued without required interlock",
                                    "A limited driving privilege granted to \(name) by Judge \(judgeLast) left out the ignition interlock the law requires when the alcohol concentration is 0.15 or more, prosecutors told the paper."))
            }
            return Ruling(update: { person in
                person.appearances.append(.init(docket: m.docket, date: date, charges: "Petition for limited driving privilege",
                                                outcome: granted ? (interlock ? "Granted with an ignition interlock" : "Granted: work, school, and treatment hours") : "Denied"))
            }, later: events)
        }
    }
}
