import Foundation

/// The local paper's newsroom: who writes what, how it's phrased, and the stories that fill the pages between
/// verdicts. Everything here is drawn from what actually happened in the judge's courtroom and county.
enum NewsDesk {

    struct Reporter {
        let name: String
        let beat: String
    }

    static let courts = Reporter(name: "Dana Whitlock", beat: "courts reporter")
    static let publicSafety = Reporter(name: "Marcus Bell", beat: "public safety reporter")
    static let metro = Reporter(name: "Priya Raman", beat: "metro reporter")
    static let columnist = Reporter(name: "Hal Pruitt", beat: "columnist")
    static let editors = Reporter(name: "The editorial board", beat: "")

    static func byline(_ r: Reporter, paper: String) -> String {
        r.beat.isEmpty ? r.name : "By \(r.name), \(paper) \(r.beat)"
    }

    /// Who covers a story of this kind, and the section it runs in.
    static func desk(for kind: NewsItem.Kind) -> (Reporter, String) {
        switch kind {
        case .verdict, .appeal, .exoneration: return (courts, "Courts")
        case .arrest: return (publicSafety, "Public Safety")
        case .revelation: return (courts, "Courts")
        case .ethics: return (metro, "Metro")
        case .community: return (metro, "Local")
        }
    }

    // MARK: Verdicts

    struct VerdictFacts {
        var name: String
        var last: String
        var age: Int
        var judge: String
        var offense: String
        var headline: String
        var place: String?
        var countsTotal: Int
        var countsConvicted: Int
        var sentence: String
        var active: Bool
        var returning: Bool
        var custodyDays: Int
        var victim: String?
        var mediaAttention: Int
        /// An active term was imposed but jail credit already satisfies it.
        var timeServed = false
    }

    static func convictionHeadline(_ f: VerdictFacts, rng: inout SeededRNG) -> String {
        var options = ["\(f.name) convicted in \(f.offense) case",
                       "Judge finds \(f.last) guilty of \(f.offense)",
                       "Guilty: \(f.last) case ends in conviction",
                       "\(f.last) found guilty after \(f.mediaAttention >= 2 ? "closely watched" : "brief") bench trial"]
        if f.active && !f.sentence.isEmpty { options.append("\(f.last) headed to prison after \(f.offense) conviction") }
        if f.timeServed { options += ["\(f.last) convicted, released with time served", "Jail credit covers \(f.last)'s sentence"] }
        else if !f.active && !f.sentence.isEmpty { options.append("\(f.last) convicted, avoids prison") }
        if f.countsTotal > 1 && f.countsConvicted < f.countsTotal { options.append("Split verdict for \(f.last): guilty on \(f.countsConvicted) of \(f.countsTotal) counts") }
        if f.mediaAttention >= 2 { options.append("Verdict in \u{2018}\(f.headline)\u{2019} case: guilty") }
        return rng.pick(options)
    }

    static func acquittalHeadline(_ f: VerdictFacts, rng: inout SeededRNG) -> String {
        var options = ["\(f.name) found not guilty of \(f.offense)",
                       "Judge acquits \(f.last) in \(f.offense) case",
                       "\(f.last) walks free after bench trial",
                       "Not guilty: State's case against \(f.last) falls short"]
        if f.custodyDays > 0 { options.append("After \(f.custodyDays) days in jail, \(f.last) is acquitted") }
        if f.mediaAttention >= 2 { options.append("Acquittal in \u{2018}\(f.headline)\u{2019} case") }
        return rng.pick(options)
    }

    static func lede(_ f: VerdictFacts, convicted: Bool, rng: inout SeededRNG) -> String {
        let place = f.place.map { " in \($0)" } ?? ""
        let counts = f.countsTotal > 1
            ? (f.countsConvicted == f.countsTotal ? (f.countsTotal == 2 ? " on both counts" : " on all \(f.countsTotal) counts") : " on \(f.countsConvicted) of \(f.countsTotal) counts")
            : ""
        if convicted {
            let sentence = f.sentence.isEmpty ? "" : ", and imposed \(f.sentence)"
            return rng.pick([
                "Superior Court Judge \(f.judge) found \(f.name), \(f.age), guilty\(counts)\(sentence), ending a case that began with an arrest\(place).",
                "\(f.name) stood as Judge \(f.judge) announced the verdict: guilty\(counts). The judge then imposed \(f.sentence.isEmpty ? "judgment" : f.sentence).",
                "A Hollis County judge has convicted \(f.name)\(counts) of \(f.offense)\(sentence).",
                "After hearing the evidence without a jury, Judge \(f.judge) found \(f.last) guilty\(counts)\(sentence)."
            ])
        }
        return rng.pick([
            "Judge \(f.judge) found \(f.name), \(f.age), not guilty of \(f.offense) after a bench trial, saying the State had not proven its case beyond a reasonable doubt.",
            "\(f.name) left the Hollis County Courthouse a free \(rng.chance(0.5) ? "person" : "defendant") after Judge \(f.judge) returned a verdict of not guilty.",
            "The State's case against \(f.name) ended in acquittal\(place.isEmpty ? "" : " in a case that began\(place)").",
            "In a ruling from the bench, Judge \(f.judge) acquitted \(f.last) of \(f.offense)."
        ])
    }

    static func kicker(_ f: VerdictFacts, convicted: Bool, rng: inout SeededRNG) -> String {
        var options: [String] = []
        if convicted && f.active { options += ["\(f.last) was taken into custody in the courtroom.", "Deputies led \(f.last) out a side door."] }
        if convicted && f.timeServed {
            options.append("With credit for \(f.custodyDays) days already spent in the Hollis County Detention Center, \(f.last) was released.")
        } else if convicted && !f.active {
            options.append("\(f.last) left the courthouse with family.")
            if f.sentence.lowercased().contains("supervised probation") { options.append("\(f.last) is to report to a probation officer within 72 hours.") }
        }
        if !convicted && f.custodyDays > 0 { options.append("\(f.last) had been held in the Hollis County Detention Center for \(f.custodyDays) days.") }
        if f.returning { options.append("It was not \(f.last)'s first case in Judge \(f.judge)'s courtroom.") }
        if f.mediaAttention >= 3 { options += ["Television trucks lined the street outside the courthouse.", "The gallery was full an hour before court opened."] }
        if options.isEmpty { options = ["The case was heard over \(rng.int(1...3)) day\(rng.chance(0.5) ? "s" : "")."] }
        return rng.pick(options)
    }

    // MARK: Other stories

    static func rearrestHeadline(_ name: String, rng: inout SeededRNG) -> String {
        rng.pick(["\(name), out on bond, arrested again", "Released last month, \(name) back in jail",
                  "New charge for \(name) while case is pending", "\(name) arrested while awaiting trial"])
    }

    static func releaseHeadline(_ name: String, last: String, jail: Bool = false, rng: inout SeededRNG) -> String {
        if jail {
            return rng.pick(["\(name) released from the county jail", "\(last) comes home", "\(name) completes jail term", "\(last) out of jail"])
        }
        return rng.pick(["\(name) released from custody", "\(last) comes home", "After prison, \(last) begins again",
                  "\(name) completes prison term", "Out of prison, \(last) faces the next step"])
    }

    static func releaseColor(_ last: String, town: String, jail: Bool = false, rng: inout SeededRNG) -> String {
        if jail {
            return rng.pick(["A relative said the family plans a small dinner. \"We're just glad to have them home.\"",
                             "Neither \(last) nor counsel could be reached for comment.",
                             "A pastor from \(town) picked \(last) up outside the detention center.",
                             "\(last)'s first stop, a relative said, was a barbershop on Main Street."])
        }
        return rng.pick(["A relative said the family plans a small dinner. \"We're just glad to have them home.\"",
                  "A reentry program in \(town) has offered a bed and job placement.",
                  "Neither \(last) nor counsel could be reached for comment.",
                  "\"I've got a lot to make up for,\" \(last) told a reporter outside the prison gate. \"I know that.\"",
                  "A pastor from \(town) picked \(last) up at the gate.",
                  "\(last)'s first stop, a relative said, was a barbershop on Main Street."])
    }

    static func probationDoneHeadline(_ name: String, last: String, rng: inout SeededRNG) -> String {
        rng.pick(["\(name) completes probation", "\(last) finishes probation without a violation",
                  "Probation ends for \(last)", "\(last) closes the book on a conviction"])
    }

    static func chargedAgainHeadline(_ name: String, lead: String, rng: inout SeededRNG) -> String {
        rng.pick(["\(name) charged \(lead)", "Familiar name: \(name) arrested \(lead)",
                  "\(name) back before the court, charged \(lead)", "New arrest for \(name)"])
    }

    // MARK: The week's other pages

    struct WeekSnapshot {
        var paper: String
        var county: County
        var judge: String
        var date: Date
        var verdicts: [NewsItem]
        var jailedAwaitingTrial: Int
        var inPrison: Int
        var onProbation: Int
        var recentReleases: [PersonRecord]
        var reversals: Int
        var harshShare: Double
        var lenientShare: Double
        var recentHeadlines: Set<String>
        /// Trials pending before the judge (with or without a date), and how far out the last trial date is.
        var waiting: Int = 0
        var oldestWaitDays: Int = 0
    }

    /// One or two stories that aren't about a single case: letters, columns, courthouse life, follow-ups.
    static func weekly(_ w: WeekSnapshot, rng: inout SeededRNG) -> [NewsItem] {
        var items: [NewsItem] = []
        let county = w.county
        let towns = county.towns

        // Letters to the editor about last week's biggest verdict.
        if let big = w.verdicts.max(by: { ($0.prominence ?? 0) < ($1.prominence ?? 0) }), (big.prominence ?? 0) >= 2 || rng.chance(0.35) {
            // What readers write depends on what happened: an acquittal, prison, or probation.
            let text = (big.headline + " " + big.body).lowercased()
            let acquitted = text.contains("not guilty") || text.contains("acquit") || text.contains("walks free") || text.contains("falls short")
            let prison = !acquitted && (text.contains("in prison") || text.contains("headed to prison") || text.contains("months in prison"))
            let home = rng.pick(towns)
            let agree: [String]
            let disagree: [String]
            if acquitted {
                agree = ["The State has to prove it. If it can't, the judge has to say so, even when it's unpopular.",
                         "I sat through the whole trial. I'd have had a doubt too.",
                         "People forget the defendant lives here too, and has to keep living here after this."]
                disagree = ["I live in \(home), and I don't feel any safer this week.",
                            "Somebody did it. If not this person, who's still out there?",
                            "Tell the family that was a fair result. I'll wait."]
            } else if prison {
                agree = ["That family waited a long time for somebody to take it seriously. Somebody finally did.",
                         "Hollis County isn't a place where you get to do that and go home. Good.",
                         "My nephew is a deputy. This is the kind of outcome that keeps them going."]
                disagree = ["Years in prison and then what? Same streets, fewer chances.",
                            "We spend more locking people up than we do on the schools in \(home).",
                            "I don't excuse it, but there were kids in that house. Who looks after them now?"]
            } else {
                agree = ["A job and a probation officer will do more good than a cell.",
                         "Make them pay it back and stay out of trouble. That's accountability too.",
                         "My brother got a second chance like this once. He never wasted it."]
                disagree = ["Probation again. Nothing changes until something changes.",
                            "Ask the victim whether probation feels like justice.",
                            "Folks in \(home) are tired of reading about the same people."]
            }
            func writer() -> String { "\(rng.pick(NameBank.firstNames)) \(rng.pick(NameBank.lastNames)), \(rng.pick(towns))" }
            items.append(NewsItem(date: w.date, kind: .community, headline: "Letters: readers react to \u{2018}\(big.headline)\u{2019}",
                                  body: "\"\(rng.pick(agree))\" — \(writer()). \"\(rng.pick(disagree))\" — \(writer()).",
                                  byline: "Letters to the editor", section: "Opinion"))
        }

        // A column or editorial, now and then, on what the numbers show.
        if rng.chance(0.3) {
            var topics: [(String, String)] = []
            if w.waiting >= 30 {
                topics.append(("Hollis County's criminal backlog reaches \(w.waiting) cases",
                               "\(w.waiting) felony cases are waiting for trial in Hollis County Superior Court, and new trial dates now run \(w.oldestWaitDays) days out. Judge \(w.judge) is hearing cases as fast as the calendar allows, lawyers say, but the arrests haven't slowed. The District Attorney says the office has asked the state for another courtroom and a second resident judge."))
            }
            if w.jailedAwaitingTrial >= 3 {
                topics.append(("Our jail is full of people who haven't been convicted",
                               "\(w.jailedAwaitingTrial) people on this week's court calendars are sitting in the detention center waiting for trial. Some can't post a few thousand dollars. Bond is supposed to make sure people come back to court, not punish them before a verdict."))
            }
            if w.harshShare > 0.35 {
                topics.append(("Is Judge \(w.judge) the toughest sentencer in the district?",
                               "Lawyers on both sides say sentences in Judge \(w.judge)'s courtroom run toward the top of the range. Prosecutors call it accountability. Defense lawyers call it a lottery: which judge you draw matters as much as what you did."))
            }
            if w.lenientShare > 0.35 {
                topics.append(("Second chances, or soft on crime?",
                               "Judge \(w.judge) has sent a striking share of defendants home on probation. Supporters say that keeps jobs and families together. Critics, including the sheriff's union, say it sends the wrong message."))
            }
            if w.reversals > 0 {
                topics.append(("When the Court of Appeals says the trial judge got it wrong",
                               "The Court of Appeals has reversed \(w.reversals) decision\(w.reversals == 1 ? "" : "s") from Hollis County Superior Court. Every reversal means witnesses come back, victims wait longer, and taxpayers pay twice."))
            }
            topics.append(("A day in Courtroom 2",
                           "Spend a morning at the \(county.courthouse) and you'll see the whole county pass through: a mother with a toddler on her hip waiting for a child-support case, a retired teacher on jury duty, a young man in an orange jumpsuit looking for someone in the gallery. It deserves more of our attention than it gets."))
            // Only once the court has put enough people on probation for the load to be its own doing.
            if w.onProbation >= 25 {
                topics.append(("Probation officers are stretched thin",
                               "\(w.onProbation) people sentenced in Judge \(w.judge)'s courtroom are on probation right now, and every probation officer in the county carries a caseload above the state's target. Supervision only works if someone is supervising."))
            }
            let fresh = topics.filter { !w.recentHeadlines.contains($0.0) }
            if !fresh.isEmpty {
                let topic = rng.pick(fresh)
                items.append(NewsItem(date: w.date, kind: .community, headline: topic.0, body: topic.1,
                                      byline: byline(columnist, paper: w.paper), section: "Opinion"))
            }
        }

        // Life around the courthouse.
        if rng.chance(0.5) {
            let ada = rng.pick(county.assistantDAs)
            let graduates = rng.int(5...14)
            let pool: [(String, String)] = [
                ("Drug Treatment Court graduates \(graduates)", "In a ceremony in the jury assembly room, \(graduates) participants finished Hollis County's Drug Treatment Court. One graduate, two years sober, thanked the probation officer who \"never gave up on me, even when I did.\""),
                ("Scam calls claim to be from the courthouse", "The \(county.sheriffsOffice) warns residents about callers who say they've missed jury duty and must pay a fine by gift card. \"No court will ever call you and demand money over the phone,\" Clerk of Superior Court \(county.clerk) said."),
                ("Courthouse elevator out again", "For the third time this year, the main elevator at the \(county.courthouse) is out of service. Deputies carried a wheelchair user up two flights for a hearing Tuesday. County commissioners say repairs are budgeted for spring."),
                ("Public defenders carry record caseloads", "Chief Public Defender \(county.chiefPublicDefender) told county commissioners that each assistant public defender is carrying more than \(rng.int(110...180)) open felony cases. \"We are triaging justice,\" \(county.chiefPublicDefender) said."),
                ("New assistant district attorney sworn in", "\(rng.pick(NameBank.firstNames)) \(rng.pick(NameBank.lastNames)), a graduate of the N.C. Central University School of Law, was sworn in as an assistant district attorney. District Attorney \(county.districtAttorney) said the hire will help with the backlog of violent felony cases."),
                ("Jury duty no-shows frustrate clerk", "Nearly a third of residents summoned for jury duty last month didn't show up, Clerk \(county.clerk) said. Bench trials have filled some of the gap, but \"a court system needs citizens,\" the clerk said."),
                ("Bar association food drive fills the lobby", "Lawyers from the Hollis County Bar collected \(rng.int(1_200...4_800)) pounds of canned goods in the courthouse lobby. \(ada) and a public defender who face off most weeks carried the last boxes out together."),
                ("Storm closes courthouse early", "The \(county.courthouse) closed at noon Friday as a coastal storm brought flooding to low-lying streets in \(rng.pick(towns)). Cases set for the afternoon will be reset by the clerk's office."),
                ("Sheriff asks for more jail staff", "Sheriff \(county.sheriff) asked commissioners for \(rng.int(6...14)) more detention officers, saying the jail averaged \(Int(Double(w.jailedAwaitingTrial + 120) * 1.1)) inmates last month in a building designed for 150."),
                ("Teen court volunteers wanted", "Hollis County's teen court, where young people charged with minor offenses are judged by their peers, needs volunteer attorneys and students for the spring term.")
            ]
            let fresh = pool.filter { !w.recentHeadlines.contains($0.0) }
            if let story = fresh.isEmpty ? nil : rng.pick(fresh) {
                items.append(NewsItem(date: w.date, kind: .community, headline: story.0, body: story.1,
                                      byline: byline(rng.chance(0.5) ? metro : publicSafety, paper: w.paper), section: "Local"))
            }
        }

        // Where are they now: someone sentenced here, after release.
        if let person = w.recentReleases.first(where: { !w.recentHeadlines.contains("Where are they now: \($0.name)") }), rng.chance(0.35) {
            let job = person.profile?.jobs.first(where: { $0.current && $0.title != "Unemployed" })
            // Only someone still under supervision has an officer to describe them.
            let supervised = person.postRelease != nil || (person.status == .probation && (person.probation?.supervised ?? true))
            let line = job.map { "\(person.lastName) now works as \($0.title.lowercasedPhrase.withIndefiniteArticle) at \($0.employer)." }
                ?? rng.pick(["\(person.lastName) is still looking for work. \"Every application asks about a record,\" \(person.lastName) said.",
                             "\(person.lastName) lives with family in \(rng.pick(towns)) and attends a reentry group on Thursdays."])
            var closers = ["\"I think about that courtroom every day,\" \(person.lastName) said.", "\(person.lastName) declined to talk about the case."]
            if supervised {
                let officer = person.postRelease != nil ? "A post-release supervision officer" : "A probation officer"
                closers.append("\(officer) described \(person.lastName) as \"doing the work.\"")
            }
            let closer = rng.pick(closers)
            items.append(NewsItem(date: w.date, kind: .community, headline: "Where are they now: \(person.name)",
                                  body: "Months after leaving custody, \(person.name) is trying to build a life in Hollis County. \(line) \(closer)",
                                  byline: byline(metro, paper: w.paper), section: "Local"))
        }

        // The blotter.
        if rng.chance(0.45) {
            let entries = (0..<rng.int(3...5)).map { _ in
                rng.pick(["A \(rng.int(19...61))-year-old \(rng.pick(towns)) resident was charged with driving while impaired after a crash on Highway 17.",
                          "Deputies recovered a stolen pickup at a boat ramp near \(rng.pick(towns)).",
                          "Port Hollis police are investigating a break-in at a vape shop on Front Street.",
                          "A \(rng.int(18...35))-year-old was charged with felony possession of cocaine after a traffic stop.",
                          "Catalytic converters were taken from \(rng.int(3...9)) vehicles at a church parking lot overnight.",
                          "A \(rng.int(20...70))-year-old was charged with assault on a female after a domestic call in \(rng.pick(towns)).",
                          "Deputies seized \(rng.int(2...14)) firearms during a search in \(rng.pick(towns)); charges are pending.",
                          "A man was cited for trespassing after sleeping in the courthouse parking deck."])
            }
            items.append(NewsItem(date: w.date, kind: .arrest, headline: "Sheriff's and police log",
                                  body: Array(Set(entries)).joined(separator: " "),
                                  byline: byline(publicSafety, paper: w.paper), section: "Public Safety"))
        }
        return items
    }
}
