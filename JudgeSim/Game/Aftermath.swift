import Foundation

/// What happens after a case leaves the courtroom, decided by what the judge did: the people in it go on living,
/// the paper keeps writing, and some of it comes back. Written beats for particular cases come first; every case with
/// a victim also gets that victim's story a year on, and a decision that stirs people up gets more than one day's news.
enum Aftermath {

    /// The judgment, as the world sees it.
    enum Trigger: Hashable {
        /// A guilty person walked: acquitted, or the case dismissed.
        case freed
        /// An innocent person convicted.
        case wronglyConvicted
        /// A guilty person sent home on probation.
        case probation
        /// A guilty person sent to prison.
        case prison
        /// Any acquittal or dismissal of someone who didn't do it.
        case cleared
    }

    /// One thing that may follow a judgment, written for a particular case.
    struct Beat {
        let triggers: Set<Trigger>
        let chance: Double
        /// Days after the judgment.
        let days: ClosedRange<Int>
        let headline: String
        let body: String
        /// A written follow-up case it brings back to this court, if any.
        var followUps: [String] = []
        var sameVictim = false
    }

    static func trigger(convicted: Bool, actuallyGuilty: Bool, active: Bool) -> Trigger {
        switch (convicted, actuallyGuilty) {
        case (false, true): return .freed
        case (false, false): return .cleared
        case (true, false): return .wronglyConvicted
        case (true, true): return active ? .prison : .probation
        }
    }

    /// Everything that follows this judgment. Returns the events and whether a written beat already brought a new case,
    /// so the general reoffense roll doesn't bring a second one.
    static func events(for c: CourtCase, convicted: Bool, active: Bool, judgeLast: String, date: Date, dismissed: Bool = false,
                       rng: inout SeededRNG) -> (events: [PendingEvent], broughtCase: Bool) {
        let d = c.defendant
        let trigger = trigger(convicted: convicted, actuallyGuilty: c.truth.actuallyGuilty, active: active)
        let cal = CourtCalendar.calendar
        func later(_ days: ClosedRange<Int>) -> Date { cal.date(byAdding: .day, value: rng.int(days), to: date) ?? date }
        func fill(_ text: String) -> String {
            var text = text
            // A case the judge dismissed was never decided by a verdict; the beats say so.
            if dismissed {
                for (from, to) in [("acquitted by Judge {JUDGE}", "whose case Judge {JUDGE} dismissed"),
                                   ("Judge {JUDGE} acquitted {DL}", "Judge {JUDGE} dismissed the case against {DL}"),
                                   ("Judge {JUDGE} acquitted {D}", "Judge {JUDGE} dismissed the case against {D}"),
                                   ("acquittal", "dismissal"), ("acquitted", "cleared")] {
                    text = text.replacingOccurrences(of: from, with: to)
                }
            }
            var out = text.replacingOccurrences(of: "{D}", with: d.name).replacingOccurrences(of: "{DL}", with: d.lastName)
                .replacingOccurrences(of: "{JUDGE}", with: judgeLast)
            // The defendant's pronouns, the same as in the case itself.
            for (key, value) in NameBank.gender(of: d.name).tokens(for: "D") {
                out = out.replacingOccurrences(of: "{\(key)}", with: value)
            }
            if let v = c.victimName {
                out = out.replacingOccurrences(of: "{V}", with: v)
                    .replacingOccurrences(of: "{VL}", with: v.components(separatedBy: " ").last ?? v)
            }
            return out
        }
        var out: [PendingEvent] = []
        var broughtCase = false

        // Written beats for this case.
        for beat in StoryAftermath.beats[c.templateKey] ?? [] where beat.triggers.contains(trigger) {
            guard rng.chance(beat.chance) else { continue }
            if !beat.followUps.isEmpty && (broughtCase || !beat.followUps.contains(where: { FollowUpCases.fits($0, age: d.age) })) { continue }
            let when = later(beat.days)
            var event = PendingEvent(due: when, news: NewsItem(date: when, kind: beat.followUps.isEmpty ? .community : .arrest,
                                                               headline: fill(beat.headline), body: fill(beat.body),
                                                               docket: c.docket, prominence: beat.followUps.isEmpty ? 1 : 2),
                                     personID: d.personID)
            if !beat.followUps.isEmpty {
                let toCourt = cal.date(byAdding: .day, value: rng.int(50...90), to: when) ?? when
                out.append(event)
                event = PendingEvent(due: toCourt,
                                     news: NewsItem(date: toCourt, kind: .arrest, headline: "\(d.name) indicted; case returns to Judge \(judgeLast)",
                                                    body: "A Hollis County grand jury returned a new indictment against \(d.name). The case comes back to Judge \(judgeLast), who presided over \(d.lastName)'s earlier case.",
                                                    docket: c.docket),
                                     personID: d.personID,
                                     reoffense: Reoffense(personID: d.personID, templateKeys: beat.followUps,
                                                          victimName: beat.sameVictim ? c.victimName : nil, incident: when,
                                                          note: "Back in your court after your judgment in \(c.caption) on \(SentenceFormat.shortDate(date)). " + fill(beat.headline) + ".",
                                                          priorOffense: c.charges.first?.law.title, priorDate: date))
                broughtCase = true
            }
            out.append(event)
        }

        // The victim, a year on.
        if let victim = c.victimName, rng.chance(0.65) {
            let when = later(200...420)
            out.append(PendingEvent(due: when, news: NewsItem(date: when, kind: .community,
                                                              headline: rng.pick(["A year later: \(victim)", "Where \(victim) is now", "After the verdict, \(victim)"]),
                                                              body: victimEpilogue(c, victim: victim, trigger: trigger, judgeLast: judgeLast, rng: &rng),
                                                              docket: c.docket, prominence: 1)))
        }

        // A judgment that stirs people up gets more than one day's news.
        let violent = [LawCategory.violent, .family, .robbery].contains(c.category)
        if (trigger == .freed && violent) || (trigger == .probation && violent && c.victimName != nil) || c.mediaAttention >= 3 {
            let when = later(5...18)
            let piece = reaction(c, trigger: trigger, judgeLast: judgeLast, rng: &rng)
            out.append(PendingEvent(due: when, news: NewsItem(date: when, kind: .community, headline: piece.headline, body: piece.body,
                                                              docket: c.docket, prominence: 1)))
        }
        // After a dismissal there was no verdict; every line the paper runs says so.
        if dismissed {
            func ruled(_ text: String) -> String {
                var text = text
                for (from, to) in [("Not guilty doesn't mean innocent", "A dismissal doesn't mean innocent"), ("the acquittal", "the dismissal"),
                                   ("acquittal", "dismissal"), ("acquitted", "cleared"), ("After the verdict", "After the ruling"),
                                   ("'s verdict", "'s ruling"), ("the verdict", "the ruling")] {
                    text = text.replacingOccurrences(of: from, with: to)
                }
                return text
            }
            for i in out.indices {
                out[i].news.headline = ruled(out[i].news.headline)
                out[i].news.body = ruled(out[i].news.body)
            }
        }
        return (out, broughtCase)
    }

    /// How the victim, or the victim's family, is doing a year after the judgment.
    private static func victimEpilogue(_ c: CourtCase, victim: String, trigger: Trigger, judgeLast: String, rng: inout SeededRNG) -> String {
        let last = victim.components(separatedBy: " ").last ?? victim
        let died = Consequences.victimDied(c)
        let d = c.defendant
        if died {
            switch trigger {
            case .prison:
                return rng.pick(["\(victim)'s family marked the first anniversary of the death with a vigil. \"Knowing \(d.lastName) is where \(d.lastName) is lets us grieve instead of fight,\" a relative said.",
                                 "A scholarship in \(victim)'s name gave its first award this spring. The family attended every hearing in \(d.lastName)'s case and say they won't go to another one."])
            case .probation:
                return rng.pick(["\(victim)'s family says the year has been hard in a particular way: \"We see \(d.lastName) at the grocery store.\" They have asked the legislature for tougher sentencing in cases like this one.",
                                 "The \(last) family still keeps \(victim)'s room the way it was. \"The judge gave \(d.lastName) a second chance,\" a relative said. \"We just hope it's used.\""])
            case .freed, .cleared:
                return rng.pick(["\(victim)'s family says the acquittal left them with no answers. \"Somebody did this,\" a relative said. \"Nobody has been made to say so.\"",
                                 "A year after Judge \(judgeLast)'s verdict, the \(last) family still hasn't taken down the photos from the trial. They say they have stopped reading the news."])
            case .wronglyConvicted:
                return "\(victim)'s family still believes the court got the right person. Others in the community have begun to ask questions."
            }
        }
        switch trigger {
        case .prison:
            return rng.pick(["\(victim) has gone back to work and says the hardest part is over. \"I testified. I was believed. That mattered more than the number of years.\"",
                             "\(victim) moved across the county this spring and started over. \"I don't check the inmate locator every day anymore. Maybe once a week.\"",
                             "\(victim) now volunteers with the victim advocates who sat through the trial. \"Somebody did that for me. Now I do it.\""])
        case .probation:
            return rng.pick(["\(victim) says the sentence still sits wrong some days. \(d.lastName) is on probation in the same town, and \(victim) has changed routes to work.",
                             "\(victim) says \(d.lastName) has kept to the conditions, as far as anyone can tell. \"I hope the judge was right. I'm the one who finds out if not.\"",
                             "\(victim) has a new job and a new routine. \"I don't think about the case every day now. Most days, but not every day.\""])
        case .freed:
            return rng.pick(["\(victim) says the verdict felt like being called a liar. \"I know what happened to me. The court didn't say otherwise; it just didn't say anything.\"",
                             "\(victim) installed cameras and moved twice in the year since the trial. \(d.lastName) still lives in the county.",
                             "\(victim) says friends stopped asking about the case after the verdict. \"Everybody moved on but me.\""])
        case .cleared:
            return rng.pick(["\(victim) says the trial raised more questions than it answered. \"Whoever did it is still out there. I'd rather know that than the wrong person pay.\"",
                             "\(victim) has asked investigators to keep the case open. The Sheriff's Office says it is."])
        case .wronglyConvicted:
            return "\(victim) says the trial brought relief at the time. \"I believed the court. I still want to.\""
        }
    }

    /// What people said after a judgment that stirred them up.
    /// The talk after a judgment that stirred people up: each headline goes with its own story, and the story names the
    /// case, the town, and the people in it.
    private static func reaction(_ c: CourtCase, trigger: Trigger, judgeLast: String, rng: inout SeededRNG) -> (headline: String, body: String) {
        let d = c.defendant
        let town = c.investigation?.facts?.town ?? "the county"
        let offense = c.charges.first?.law.title.lowercased() ?? "the charges"
        let victim = c.victimName
        switch trigger {
        case .freed, .cleared:
            return rng.pick([
                ("Letters: readers weigh in on the \(d.lastName) case",
                 "Readers wrote in large numbers this week about Judge \(judgeLast)'s verdict for \(d.name). \"Not guilty doesn't mean innocent,\" a reader from \(town) wrote. Another: \"The State didn't prove it. That's the whole job.\""),
                ("DA's office \u{2018}disagrees profoundly\u{2019} with \(d.lastName) verdict",
                 "The District Attorney's office said it respects Judge \(judgeLast)'s verdict acquitting \(d.name) of \(offense) but \"disagrees with it profoundly.\" The public defender's office called it \"the presumption of innocence working as intended.\""),
                ("In \(town), the \(d.lastName) verdict is all anyone talks about",
                 "At the diner counter and after Sunday services, people in \(town) were still arguing about \(d.name)'s acquittal this week."
                    + (victim.map { " \"Somebody hurt \($0),\" one man said. \"That didn't change because of a verdict.\"" } ?? " \"I'd want the same rules if it was me,\" one woman said."))
            ])
        case .probation:
            return rng.pick([
                ("Letters: readers split over probation for \(d.name)",
                 "Letters this week split over Judge \(judgeLast)'s probationary sentence for \(d.name) on \(offense). \"Prison isn't the only accountability,\" a reader from \(town) wrote. \"Tell that to the victim,\" wrote another."),
                ("Victims' group asks Judge \(judgeLast) to explain \(d.lastName) sentence",
                 "A victims' rights group said it will watch \(d.name)'s probation closely and asked Judge \(judgeLast) to explain the sentence. The judge, as judges do, declined to comment.")
            ])
        case .prison:
            return rng.pick([
                ("Letters: most readers back the \(d.lastName) sentence",
                 "Most letters this week supported the prison sentence for \(d.name) on \(offense). A few, mostly from \(town), asked whether the years would make anyone safer."),
                ("\(d.lastName) family: \u{2018}This one is too long\u{2019}",
                 "\(d.name)'s family spoke at a church gathering in \(town) this week. \"We're not saying no consequence,\" a relative said. \"We're saying this one is too long.\"")
            ])
        case .wronglyConvicted:
            return ("Readers question the evidence against \(d.name)",
                    "Some readers questioned the evidence that convicted \(d.name) of \(offense). \"I sat through two days of it,\" a reader from \(town) wrote. \"I'm not sure I'd have been sure.\"")
        }
    }
}
