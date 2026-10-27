import Foundation

/// Something that happened in the judge's court since the paper last went out.
enum Happening: Hashable {
    case trialDateSet(caption: String, defendant: String, date: Date, jailed: Bool, prominent: Bool)
    case reassigned(caption: String, defendant: String, toJudge: String)
    case moved(caption: String, to: Date)
    case timeOffBooked(from: Date, to: Date, days: Int)
    case scheduleChanged(weeklyTrials: Int)
    case verdictEntered(trialsHeard: Int, convicted: Bool)
    case reputation(CourthouseMood.Name)
    case calendarCall(matters: Int)
    case hearingHeld(name: String, revoked: Bool)
    case perjuryReferral(name: String)
}

/// The day's paper: short items on what the court did, and the life of the county around it.
enum DailyNews {

    struct Snapshot {
        var date: Date
        var county: County
        var judge: String
        var awaiting: Int
        var jailedWaiting: Int
        var oldestWait: Int
        var trialsHeard: Int
        var leaveLeft: Int
        var recentHeadlines: Set<String>
    }

    static func items(_ s: Snapshot, happenings: [Happening], rng: inout SeededRNG) -> [NewsItem] {
        var out: [NewsItem] = []
        func add(_ headline: String, _ body: String, kind: NewsItem.Kind = .community, prominence: Int = 0, section: String = "Local") {
            guard !s.recentHeadlines.contains(headline), !out.contains(where: { $0.headline == headline }) else { return }
            out.append(NewsItem(date: s.date, kind: kind, headline: headline, body: body, prominence: prominence, section: section))
        }
        let judge = "Judge \(s.judge)"
        let c = s.county

        // What the court did yesterday, a couple of items at most.
        for happening in happenings.shuffled(using: &rng) where out.count < 2 {
            switch happening {
            case .trialDateSet(let caption, let defendant, let date, let jailed, let prominent):
                // By the time the paper is out, a trial set for that day or the day before has already been called.
                guard CourtCalendar.calendar.startOfDay(for: date) > CourtCalendar.calendar.startOfDay(for: s.date),
                      prominent || jailed || rng.chance(0.25) else { continue }
                add("Trial date set in \(caption)",
                    "\(judge) set \(defendant)'s trial for \(SentenceFormat.shortDate(date))."
                        + (jailed ? " \(defendant) remains in the \(c.name) Detention Center." : "")
                        + rng.pick([" Both sides say they'll be ready.", " The defense said it may ask for more time.", ""]),
                    prominence: prominent ? 1 : 0, section: "Courts")
            case .reassigned(let caption, let defendant, let toJudge):
                add("\(caption) moves to \(toJudge)",
                    "\(judge) reassigned the case against \(defendant) to \(toJudge), citing a crowded calendar. " +
                    rng.pick(["Courthouse regulars say it happens more than people think.", "The district attorney's office said it had no objection.",
                              "Defense counsel said a new judge means a fresh look."]), section: "Courts")
            case .moved(let caption, let to):
                guard rng.chance(0.4) else { continue }
                add("\(caption) pushed to \(SentenceFormat.shortDate(to))",
                    "\(judge) moved the trial to clear a crowded day. " + rng.pick(["Witnesses were notified by the clerk's office.", "The victim's family said they'll be there either way."]),
                    section: "Courts")
            case .timeOffBooked(let from, let to, let days):
                add(days > 3 ? "\(judge) to be off the bench \(SentenceFormat.shortDate(from))–\(SentenceFormat.shortDate(to))" : "\(judge) out of court \(SentenceFormat.shortDate(from))",
                    "Matters set for those days will move to the next days with room on the calendar, Clerk of Court \(c.clerk)'s office said."
                        + (days > 5 ? " " + rng.pick(["Lawyers joked they'd finally catch up on paperwork.", "The DA's office said it would use the time to prepare for trials."]) : ""),
                    section: "Courts")
            case .scheduleChanged(let weekly):
                add("\(judge) changes the trial calendar",
                    "\(judge)'s courtroom will now take about \(weekly) trial\(weekly == 1 ? "" : "s") a week. " +
                    (weekly <= 2 ? "Defense lawyers worry the backlog will grow." : weekly >= 6 ? "Prosecutors said they'll need more help to keep up." : "Lawyers on both sides called it workable."),
                    section: "Courts")
            case .verdictEntered(let heard, _):
                if heard > 0 && heard % 25 == 0 {
                    add("\(judge) hears \(heard)th trial",
                        "The milestone came this week. \"Every one of them is somebody's worst day,\" the judge told a court reporter afterward. \"I try to remember that.\"",
                        prominence: 1, section: "Courts")
                }
            case .reputation(let name):
                switch name {
                case .lenient:
                    add("DA's office: \(judge)'s courtroom 'tilts toward the defense'",
                        "District Attorney \(c.districtAttorney) told a civic club that prosecutors \"have to bring twice the proof\" in \(judge)'s courtroom. The public defender called that \"the burden of proof working.\"",
                        prominence: 1, section: "Courts")
                case .harsh:
                    add("Defense bar: clients fear \(judge)'s sentences",
                        "Chief Public Defender \(c.chiefPublicDefender) said more clients are taking pleas rather than face sentencing in \(judge)'s courtroom. The DA's office said the sentences are \"what the law provides.\"",
                        prominence: 1, section: "Courts")
                case .respected:
                    add("Lawyers on both sides praise \(judge)",
                        "In an unusual show of agreement, prosecutors and defense lawyers both told the paper \(judge) runs \"a fair, predictable courtroom.\"",
                        section: "Courts")
                case .neutral:
                    break
                }
            case .calendarCall(let matters):
                guard rng.chance(0.35) else { continue }
                add("Busy calendar call: \(matters) matters in one morning",
                    "Pleas, bond hearings and motions filled \(judge)'s administrative session. " +
                    rng.pick(["The hallway was standing room only by 9.", "One defendant brought a grandmother, a pastor and a former teacher to vouch for him.", "Court ran through lunch."]),
                    section: "Courts")
            case .hearingHeld(let name, let revoked):
                guard rng.chance(0.4) else { continue }
                add(revoked ? "Probation revoked for \(name)" : "\(name) stays on probation",
                    revoked ? "\(judge) activated \(name)'s suspended sentence after a violation hearing." : "\(judge) continued \(name) on probation after a violation hearing, with new conditions.",
                    section: "Courts")
            case .perjuryReferral(let name):
                add("\(judge) sends witness's testimony to DA",
                    "\(judge) referred testimony by \(name) to the district attorney for possible perjury charges. Judges rarely do it; lawyers say it's a warning to every witness who takes the stand.",
                    prominence: 1, section: "Courts")
            }
        }

        // The docket, now and then.
        if s.awaiting >= 6 && rng.chance(0.2) {
            add("By the numbers: \(s.awaiting) cases wait for trial dates",
                "\(s.awaiting) criminal cases in \(c.name) Superior Court are waiting for \(judge) to set trial dates. \(s.jailedWaiting) of the defendants are in jail. The oldest has waited \(s.oldestWait) days.",
                section: "Courts")
        }

        // The rest of the county.
        if rng.chance(0.6), let item = ambient(s, rng: &rng) { add(item.0, item.1, section: item.2) }
        return out
    }

    /// One item from the life of the county: the season, the courthouse, the towns, and what the court does.
    private static func ambient(_ s: Snapshot, rng: inout SeededRNG) -> (String, String, String)? {
        let c = s.county
        let town = rng.pick(c.towns)
        let month = CourtCalendar.calendar.component(.month, from: s.date)
        var pool: [(String, String, String)] = []

        // The season.
        switch month {
        case 12, 1, 2:
            pool += [("Ice on the bridges this morning", "The Sheriff's Office asked drivers to stay off the Route 17 bridge until the sun is up. Court opened on time.", "Weather"),
                     ("Warming center opens at \(town) fellowship hall", "Volunteers set up 40 cots. Deputies are bringing people in off the street on the coldest nights.", "Community")]
        case 3, 4:
            pool += [("Pollen count hits the season's high", "Yellow dust covered every car in the courthouse lot by noon. The clerk's office ran out of tissues.", "Weather"),
                     ("\(town) Easter egg hunt draws record crowd", "Organizers hid 6,000 eggs. Deputies helped find three lost children and one lost grandfather.", "Community")]
        case 5, 6, 7:
            pool += [("Afternoon storms knock out power in \(town)", "Duke Energy restored service by evening. The courthouse generator kicked on for eleven minutes; nobody noticed.", "Weather"),
                     ("Heat advisory: courthouse opens cooling room", "The jury assembly room is open as a cooling center through the weekend.", "Community"),
                     ("\(town) fireworks back on the river", "The volunteer fire department says the barge is ready. Deputies remind boaters: no drinking at the wheel.", "Community")]
        case 8, 9, 10:
            pool += [("Tropical storm watch for the coast", "Emergency management is checking shelters. The clerk's office says court will close if the county declares an emergency.", "Weather"),
                     ("County fair opens with a new Ferris wheel", "The fair runs ten days. Deputies will run a lost-child tent and a DWI checkpoint on the way out.", "Community"),
                     ("Deputies: check the candy, walk with the kids", "The Sheriff's Office handed out reflective bags for Halloween and reminded drivers to slow down in neighborhoods.", "Community")]
        default:
            pool += [("Food drive fills two church vans", "The \(town) food pantry says this year's Thanksgiving drive beat last year's by a third.", "Community"),
                     ("Christmas parade route set through \(c.seat)", "Main Street closes at 4 p.m. Saturday. The Sheriff's Office float will be a giant pair of handcuffs, again.", "Community")]
        }

        // The courthouse.
        pool += [
            ("Courthouse elevator out again", "Lawyers took the stairs and witnesses waited in the lobby. The county says a part is on order. It said that in March too.", "Courthouse"),
            ("New security scanners at the courthouse door", "Lines moved faster this week. Deputies confiscated four pocketknives, a screwdriver and, inexplicably, a whole ham.", "Courthouse"),
            ("Clerk's office adds evening hours", "Clerk of Court \(c.clerk) says the office will stay open until 7 on Thursdays so people can pay fines without missing work.", "Courthouse"),
            ("Courthouse cat gets a name", "The gray cat who sleeps on the courthouse steps has been named Docket by vote of the clerk's office. The county says the cat is not an employee.", "Courthouse"),
            ("Former judge's portrait unveiled", "A portrait of a judge who served the county for 22 years now hangs outside the main courtroom. Family members came from three states.", "Courthouse"),
            ("Courthouse lot repaving starts Monday", "Lawyers and jurors should park at the church lot on Market Street for two weeks.", "Courthouse"),
        ]

        // County life.
        pool += [
            ("Commissioners debate a bigger jail", "The board heard a plan to add 120 beds. Opponents said the county should spend the money on mental health care instead. A vote is set for next month.", "Government"),
            ("Sheriff \(c.sheriff) swears in nine new deputies", "The class includes two former teachers and a retired Marine. They start on patrol next week.", "Community"),
            ("Cow on Route 17 slows morning traffic", "A deputy and a farmer walked the cow home after twenty minutes. No one was hurt, though the cow did not cooperate.", "Community"),
            ("Alligator spotted in \(town) retention pond", "Wildlife officers say to leave it alone. Neighbors have named it.", "Community"),
            ("\(town) High wins on a last-second field goal", "The kicker had never made one from that far. The crowd rushed the field; a deputy said nobody got arrested, which counts as a good night.", "Sports"),
            ("Library hosts free legal-aid clinic", "Volunteer lawyers helped 40 people with expunctions, custody papers and traffic tickets.", "Community"),
            ("\(c.policeDepartment) launches coffee-with-a-cop", "Officers will be at a different diner each week. The first one ran out of biscuits by 8.", "Community"),
        ]

        // The county's own places, the same ones the cases happen at.
        if let diner = Gazetteer.place(.restaurant, rng: &rng), let church = Gazetteer.place(.church, rng: &rng),
           let plant = Gazetteer.place(.plant, rng: &rng), let park = Gazetteer.place(.park, rng: &rng),
           let bar = Gazetteer.place(.bar, rng: &rng), let landing = Gazetteer.place(.boatLanding, rng: &rng),
           let school = Gazetteer.place(.school, rng: &rng), let grocery = Gazetteer.place(.grocery, rng: &rng) {
            pool += [
                ("\(diner.name) marks 30 years on \(diner.street)", "The owners served the first plate at the original prices for an hour. The line went around the block in \(diner.town).", "Community"),
                ("Fish fry at \(church.name) sells out by noon", "Volunteers fried 400 pounds of whiting. Proceeds go to the church's heating-assistance fund in \(church.town).", "Community"),
                ("\(plant.name) adds a weekend shift", "The \(plant.town) employer says it will hire about 60 people. Applications are taken at the gate on \(plant.street).", "Business"),
                ("Splash pad reopens at \(park.name)", "Repairs took most of the summer. Parents in \(park.town) say it was worth the wait; the kids did not comment.", "Community"),
                ("\(bar.name) hosts a fundraiser for a sick bartender", "Regulars raised $7,400 in one night on \(bar.street) in \(bar.town). The owner matched the tips.", "Community"),
                ("Kayak rentals return to \(landing.name)", "The rental stand is open weekends through October. Wildlife officers remind paddlers that life jackets are the law for children under 13.", "Community"),
                ("\(school.name) robotics team heads to state", "The team built its robot in a borrowed shop class. Local businesses in \(school.town) covered the bus.", "Community"),
                ("\(grocery.name) expands its produce section", "The store on \(grocery.street) will now carry vegetables from three \(grocery.town)-area farms.", "Business"),
            ]
        }

        // Know your court: short explainers.
        pool += [
            ("Know your court: what's a calendar call?", "Once a week the judge takes up the short matters: pleas, bond hearings, motions and arraignments. Most criminal cases end there, not at trial.", "Courts"),
            ("Know your court: what does bond actually do?", "Bond isn't punishment. Under state law it's meant to make sure a defendant comes back to court and the public stays safe, using the least restrictive conditions that will do that.", "Courts"),
            ("Know your court: the Alford plea", "A defendant can plead guilty while saying they're innocent, if the evidence is strong enough that they'd likely be convicted. The judge has to agree to it.", "Courts"),
            ("Know your court: why some trials have no jury", "In North Carolina a defendant can give up the right to a jury in most felony cases and let the judge decide. The State gets notice, and the judge has to approve.", "Courts"),
            ("Know your court: what's a PJC?", "A prayer for judgment continued means the court finds you guilty but doesn't enter a sentence. It's often used for first offenses, and it still counts in some ways.", "Courts"),
            ("Know your court: expunctions", "Many old convictions can now be cleared from a record after a waiting period. The clerk's office has the forms, and the library clinic helps fill them out.", "Courts"),
            ("Know your court: speedy trial", "The Constitution guarantees a speedy trial, but there's no fixed deadline. Courts weigh how long the wait was, why, whether the defendant asked, and what harm it did.", "Courts"),
        ]
        if s.leaveLeft <= 3 {
            pool.append(("Hardworking or overworked?", "Court watchers note \(s.judge.isEmpty ? "the judge" : "Judge " + s.judge) has used nearly all of this year's leave. \"It's a heavy docket,\" one lawyer said.", "Courts"))
        }
        let fresh = pool.filter { !s.recentHeadlines.contains($0.0) }
        return fresh.isEmpty ? nil : rng.pick(fresh)
    }
}
