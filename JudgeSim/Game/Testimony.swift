import Foundation

/// Turns a witness's key lines into full examinations in open court, and writes the testimony of the
/// investigators, responding officers, analysts, character witnesses, and defendants who appear in most real trials.
/// Everything is built from the case's fact sheet, so dates, times, places, and exhibits agree from witness to witness.
enum Testimony {

    /// Everything a generated witness can draw on.
    struct Context {
        let facts: CaseFacts
        let sheet: CaseFactSheet
        let report: InvestigationReport
        let gaps: [Investigations.Gap]
        let evidence: [Evidence]
        let charges: [Charge]
        let defendant: Defendant
        let victim: String?
        let values: [String: String]
        let defenseTheory: String

        var dl: String { defendant.lastName }
        var state: [Evidence] { evidence.filter { $0.side == .prosecution } }
        var defense: [Evidence] { evidence.filter { $0.side == .defense } }
        var setting: CaseSetting { facts.setting }
        /// The State's exhibits in the order the investigation found them.
        var stateInOrder: [Evidence] {
            let rank: [EvidenceKind: Int] = [.physical: 0, .forensic: 1, .video: 2, .digital: 3, .document: 4, .statement: 5]
            return state.enumerated().sorted { (rank[$0.element.kind] ?? 9, $0.offset) < (rank[$1.element.kind] ?? 9, $1.offset) }.map(\.element)
        }
        var strongest: Evidence? { state.max { $0.weight < $1.weight } }
        var lawIDs: [String] { charges.map(\.lawID) }
        /// Someone died.
        var fatal: Bool {
            let deadly: Set<String> = ["murder1", "murder2", "volManslaughter", "invManslaughter", "felonyDBV", "misdDBV", "deathByDistribution"]
            return lawIDs.contains { deadly.contains($0) }
        }
        var organization: String? {
            for key in ["CHARITY", "BIZ", "HOSP", "PHARM", "STORE2", "STORE", "REST"] { if let v = values[key] { return v } }
            return nil
        }
    }

    // MARK: Who a witness is

    enum Kind { case investigator, expert, lay }

    private static let expertWords = ["examiner", "analyst", "doctor", "physician", "nurse", "chemist", "accountant", "expert",
                                      "professor", "psychologist", "pediatrician", "engineer", "reconstruction", "toxicologist",
                                      "researcher", "consultant", "scientist", "veterinarian", "medical", "specialist", "trainer",
                                      "commander", "paramedic"]
    private static let investigatorWords = ["detective", "officer", "deputy", "trooper", "agent", "investigator", "sergeant", "marshal"]

    static func kind(_ role: String) -> Kind {
        let lower = role.lowercased()
        if lower.contains("insurance agent") || lower.contains("counselor") || (lower.contains("director") && !lower.contains("medical")) { return .lay }
        if expertWords.contains(where: { lower.contains($0) }) { return .expert }
        if investigatorWords.contains(where: { lower.contains($0) }) { return .investigator }
        return .lay
    }

    static func isOfficial(_ role: String) -> Bool { kind(role) != .lay }

    /// True when the witness describes seeing or hearing events firsthand.
    static func sawEvents(_ w: Witness) -> Bool {
        let text = (w.direct + w.cross).joined(separator: " ").lowercased()
        return ["i saw", " saw ", "watched", "i heard", "i looked", "seen", "came running", "ran ", "in front of me", "i was there"].contains { text.contains($0) }
    }

    /// "a forensic accountant", "an investigator", "Smith's roommate".
    static func withArticle(_ role: String) -> String {
        let lower = role.prefix(1).lowercased() + role.dropFirst()
        if role.contains("'s ") || role.lowercased().hasPrefix("the ") { return lower }
        let vowel = "aeiou".contains(lower.prefix(1))
        return (vowel ? "an " : "a ") + lower
    }

    /// Turns a conceded answer into the leading question that drew it: "Yes, I never saw a contract." → "Isn't it true you never saw a contract?"
    static func leadingQuestion(from line: String, rng: inout SeededRNG) -> String? {
        var s = line.trimmingCharacters(in: .whitespaces)
        let quotes = CharacterSet(charactersIn: "\"\u{201C}\u{201D}")
        s = s.trimmingCharacters(in: quotes)
        guard !s.contains("?") else { return nil }
        for prefix in ["Yes, ", "Yes. ", "No, ", "No. ", "Yeah, ", "Sure, ", "Correct. ", "That's right. ", "That's true. ", "...", "\u{2026}"] where s.hasPrefix(prefix) {
            s = String(s.dropFirst(prefix.count))
        }
        if let end = s.range(of: ". ") { s = String(s[..<end.lowerBound]) }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: ".! "))
        for suffix in [", yes", ", no", ", sure", ", I guess"] where s.lowercased().hasSuffix(suffix) {
            s = String(s.dropLast(suffix.count))
        }
        let swap: [String: String] = ["i": "you", "i'm": "you're", "i've": "you've", "i'd": "you'd", "i'll": "you'll", "me": "you",
                                      "my": "your", "mine": "yours", "myself": "yourself", "we": "you", "we're": "you're",
                                      "we've": "you've", "our": "your", "us": "you", "am": "are", "ourselves": "yourselves"]
        var words: [String] = []
        for raw in s.replacingOccurrences(of: "\u{2019}", with: "'").split(separator: " ") {
            let token = String(raw)
            let core = token.trimmingCharacters(in: .punctuationCharacters.subtracting(CharacterSet(charactersIn: "'")))
            let trail = String(token.dropFirst(core.count))
            if let replacement = swap[core.lowercased()] { words.append(replacement + trail) } else { words.append(token) }
        }
        guard words.count >= 3 else { return nil }
        var sentence = words.joined(separator: " ")
            .replacingOccurrences(of: "you was", with: "you were")
            .replacingOccurrences(of: "you wasn't", with: "you weren't")
        let common = ["the", "a", "an", "it", "it's", "that", "there", "this", "they", "you", "your", "he", "she", "nobody", "none", "not", "never", "maybe", "some", "every", "all"]
        if let first = sentence.split(separator: " ").first, common.contains(first.lowercased()) {
            sentence = sentence.prefix(1).lowercased() + sentence.dropFirst()
        }
        return rng.pick(["Isn't it true that \(sentence)?", "You'd agree that \(sentence)?", "So \(sentence)?",
                         "Let me make sure the court has this: \(sentence)?", "Fair to say \(sentence)?"])
    }

    // MARK: The fallback examination for any witness without written testimony

    static func examination(for w: Witness, isVictim: Bool, ctx: Context, impeachment: (String, String)?,
                            timingSlip: Bool, rng: inout SeededRNG) -> [TestimonyExchange] {
        let calling = w.calledBy
        let opposing: Side = calling == .prosecution ? .defense : .prosecution
        let kind = Self.kind(w.role)
        let dl = ctx.dl
        let paper = ctx.setting == .paper
        let eyewitness = sawEvents(w) && !paper
        let role = w.role.lowercased()
        var out: [TestimonyExchange] = []
        func ask(_ phase: TestimonyExchange.Phase, _ q: String, _ a: String) {
            out.append(.init(phase: phase, examiner: phase == .cross ? opposing : calling, question: q, answer: a))
        }

        // Who the witness is
        switch kind {
        case .investigator, .expert:
            ask(.direct, rng.pick(["Please state your name and your position.", "Tell the court who you are and what you do.",
                                   "State your name and occupation for the record, please."]),
                "\(w.name). I'm \(withArticle(w.role)).")
            if kind == .expert {
                let n = rng.int(6...24)
                ask(.direct, rng.pick(["What are your qualifications?", "Tell the court about your training and experience.", "How long have you worked in this field?"]),
                    rng.pick(["\(n) years in the field. I've reviewed hundreds of cases and testified as an expert \(rng.int(4...40)) times, for the State and for the defense.",
                              "A graduate degree in the field and \(n) years of practice. I keep my certifications current and I teach continuing-education courses.",
                              "\(n) years. I've been qualified as an expert in North Carolina courts before, and I've published on this subject."]))
                if rng.chance(0.5) {
                    ask(.direct, "Your Honor, we tender \(w.name) as an expert in the field.",
                        rng.pick(["Without objection, the court accepts the witness as an expert.", "The other side has no objection. The witness is accepted as an expert."]))
                }
            } else {
                let n = rng.int(4...22)
                ask(.direct, rng.pick(["How long have you done that work?", "How long have you been in that position?", "What's your experience?"]),
                    rng.pick(["\(n) years.", "\(n) years, the last \(max(1, n / 3)) in this assignment.", "About \(n) years. Before that, \(rng.int(2...6)) years in uniform."]))
            }
        case .lay:
            let intro = rng.pick(["Please tell the court your name and how you're connected to this case.", "Would you introduce yourself to the court?",
                                  "Tell us who you are and how you came to be involved."])
            let answer: String
            if isVictim {
                answer = rng.pick(["\(w.name). I'm the one this happened to.", "\(w.name). " + (role == "victim" || role == "complainant" ? "I'm the one who reported it." : "I'm \(withArticle(w.role))."),
                                   "\(w.name). I'm \(withArticle(w.role)). This happened to me."])
            } else {
                answer = "\(w.name). I'm \(withArticle(w.role))."
            }
            ask(.direct, intro, answer)
            let relation = ["'s ", "friend", "cousin", "spouse", "roommate", "neighbor", "pastor", "landlord", "sibling", "mother",
                            "father", "coworker", "crew", "board member", "daughter", "son", "partner", "former cashier"]
            if relation.contains(where: { role.contains($0) }) {
                let years = rng.int(2...20)
                ask(.direct, rng.pick(["How long have you known \(dl)?", "How do you know \(dl)?", "How well do you know \(dl)?"]),
                    rng.pick(["About \(years) years.", "\(years) years, give or take. Well enough.", "Going on \(years) years. I'd say I know \(dl) as well as anybody."]))
            }
            if paper && !isVictim, let org = ctx.organization, rng.chance(0.6) {
                ask(.direct, rng.pick(["What's your connection to \(org)?", "How long were you involved with \(org)?"]),
                    rng.pick(["I've been there \(rng.int(2...14)) years.", "About \(rng.int(2...14)) years. I know how the place runs, and I know the people."]))
            }
            // Where the witness was, from the fact sheet
            if eyewitness, let time = ctx.sheet.time {
                let said = timingSlip ? Clock.shift(time, by: rng.pick([-35, -25, -20, 20, 25, 35])) : time
                ask(.direct, rng.pick(["Take the court back to \(ctx.sheet.day). Where were you?", "Where were you on the \(Clock.partOfDay(time)) of \(ctx.sheet.day)?",
                                       "Let's go to \(ctx.sheet.day). What brought you there?"]),
                    rng.pick(["I was \(ctx.sheet.place). It was about \(said).", "\(ctx.sheet.place.capitalizedFirst). I remember it was around \(said), because I'd just checked my phone.",
                              "I was right there, \(ctx.sheet.place). Around \(said), I'd say."]))
            }
        }

        // The witness's own account
        let first: [String]
        let next: [String]
        switch kind {
        case .investigator:
            first = ["What did you find?", "Tell the court what you found.", "What did your work turn up?"]
            next = ["What did you do next?", "What else did you find?", "What did that tell you?", "Anything else of note?"]
        case .expert:
            first = ["What did your review show?", "What is your opinion?", "What conclusions did you reach?", "What did you find?"]
            next = ["What else did you conclude?", "Anything else the court should know?", "Did anything else stand out?"]
        case .lay:
            if isVictim {
                first = paper ? ["Tell the court how this started.", "What happened?", "Take us through it, at your own pace."]
                              : ["Tell the court what happened to you.", "What happened?", "Take us through it, at your own pace."]
            } else if eyewitness {
                first = ["What happened?", "Tell the court what you saw.", "Take us through what happened.", "What did you see?"]
            } else if paper {
                first = ["What can you tell the court about this?", "When did you first realize something was wrong?", "What did you notice?", "Tell the court what you found out."]
            } else {
                first = ["What can you tell the court?", "What do you know about this?", "Tell the court what you know.", "What did you notice?"]
            }
            next = ["What happened after that?", "What else?", "Go on.", "Is there anything else the court should know?", "And then?"]
        }
        for (index, line) in w.direct.enumerated() {
            ask(.direct, index == 0 ? rng.pick(first) : rng.pick(next), line)
        }

        // How the witness knows it
        switch kind {
        case .investigator:
            ask(.direct, rng.pick(["Did you document that at the time?", "Is that in your report?", "Were your findings written up?"]),
                rng.pick(["Yes. It's in my report, written within a day or two.", "Yes, with the supporting \(paper ? "records" : "photographs") attached.", "Yes. My report was finished on \(CaseDates.day(CaseDates.add(rng.int(1...6), to: ctx.sheet.assigned)))."]))
        case .expert:
            ask(.direct, rng.pick(["How confident are you in that opinion?", "Do you hold that opinion to a reasonable degree of certainty in your field?", "Was your work reviewed by anyone else?"]),
                rng.pick(["Confident. I'd reach the same conclusion if I did it again tomorrow.", "Yes, to a reasonable degree of scientific certainty.", "Yes. A colleague reviewed the work before I signed it."]))
        case .lay:
            if eyewitness || isVictim {
                ask(.direct, rng.pick(["How sure are you about what you've told the court?", "Is there any doubt in your mind about what you saw?", "How clearly could you see?"]),
                    w.weight >= 3 ? rng.pick(["Completely sure.", "No doubt at all. I was right there.", "Clearly. I wasn't more than a few feet away."])
                        : w.weight >= 2 ? rng.pick(["I'm sure.", "I'm sure about what I've told you.", "Clear enough."])
                        : rng.pick(["Pretty sure. It's what I remember.", "As sure as I can be. It happened fast.", "I saw enough."]))
            } else if paper {
                ask(.direct, rng.pick(["Is that from your own knowledge?", "How do you know that?"]),
                    rng.pick(["Yes. I saw the records myself.", "I worked with those records every day.", "I was there for it. I'm not repeating what somebody told me."]))
            } else if calling == .defense {
                ask(.direct, rng.pick(["Why did you come to court today?", "Has anyone asked you to say any of this?"]),
                    rng.pick(["Because I know what's true, and somebody should say it.", "No. I asked to be here.", "Because \(dl) asked, and because it's true."]))
            }
        }

        // Cross
        var openers: [(String, String)] = []
        switch kind {
        case .investigator:
            openers = [("You never personally saw \(dl) commit any crime, did you?", "No. I came in afterward, like investigators do."),
                       ("Your report doesn't cover everything, does it?", "A report covers what matters. It doesn't cover every minute."),
                       ("You decided who did this fairly early, didn't you?", "I followed the evidence. It went where it went.")]
        case .expert:
            openers = [("You're being paid for your time here?", "I'm paid for my time, not my opinion."),
                       ("Your opinion is only as good as the information you were given?", "That's true of any expert. I checked what I could."),
                       ("Another expert could look at the same material and disagree?", "They could. I'd want to know their reasons.")]
        case .lay:
            if paper && !isVictim {
                openers = calling == .prosecution
                    ? [("You're not an accountant, are you?", "No. I'm telling you what I saw in our own records."),
                       ("You weren't the one keeping these records, were you?", "No. That wasn't my job."),
                       ("Somebody has to answer for the losses, and it's easier if it's \(dl), isn't it?", "I want whoever did it to answer for it. That's all.")]
                    : [("You and \(dl) are friends?", "We worked together a long time. That doesn't change what I saw."),
                       ("You weren't part of every decision, were you?", "No. But I was there for the ones that mattered."),
                       ("You'd like to see \(dl) go home today?", "I'd like the court to have the whole story.")]
            } else if paper && isVictim {
                openers = [("You didn't ask many questions at the time, did you?", "No. I trusted them. That was the point."),
                           ("You've talked about this case with other people since, haven't you?", "With my family. Not about the details."),
                           ("You want your money back, and a conviction helps with that?", "I want it back. I'd want the truth either way.")]
            } else if calling == .prosecution {
                if isVictim {
                    openers = [("You were frightened, weren't you?", "Of course I was. That doesn't mean I got it wrong."),
                               ("You've talked about this case with other people since, haven't you?", "With my family. Not about the details."),
                               ("You'd like to see \(dl) punished?", "I'd like to see it taken seriously.")]
                } else if eyewitness {
                    openers = [("It all happened quickly, didn't it?", w.weight >= 3 ? "It felt slow to me. I saw what I saw." : "...Yes. It was fast."),
                               ("You've talked about this case with other people since, haven't you?", "With my family. Not about the details."),
                               ("You were paying attention to other things before it started?", "Until it started. Then I was paying attention to that.")]
                } else {
                    openers = [("You weren't there for all of it, were you?", "No. I'm telling you what I know."),
                               ("You've talked about this case with other people since, haven't you?", "Some. Not about the details."),
                               ("What you know about \(dl) comes mostly from other people?", "Some of it. The part I told you, I know myself.")]
                }
            } else {
                openers = [("You care about \(dl), don't you?", "Yes. That doesn't change what I'm telling you."),
                           ("You weren't with \(dl) every minute, were you?", "Not every minute, no."),
                           ("You'd like to see \(dl) go home today?", "Of course I would. I'm still telling the truth.")]
            }
        }
        for (q, a) in rng.pick(openers, count: rng.int(1...2)) { ask(.cross, q, a) }
        if timingSlip, let time = ctx.sheet.time {
            ask(.cross, rng.pick(["You told the court this happened around a different time than the 911 call shows. The call came in at \(time), didn't it?",
                                  "The records put this at \(time). That's not what you just told the court, is it?"]),
                rng.pick(["Then I'm off on the time. I'm not off on what I saw.", "...I may have the time wrong. I wasn't looking at a clock.", "If that's what the records say. It felt later to me."]))
        }
        let narrated = impeachment == nil ? w.cross : Array(w.cross.dropLast())
        for line in narrated {
            let quoted = line.hasPrefix("\"") || line.hasPrefix("\u{201C}")
            ask(.cross, quoted ? (leadingQuestion(from: line, rng: &rng) ?? rng.pick(["One more thing.", "Let me ask you about something else."])) : "", line)
        }
        if let imp = impeachment { ask(.cross, imp.0, imp.1) }

        // Redirect
        ask(.redirect, rng.pick(["Does anything you were asked on cross change what you told the court?",
                                 "Having heard those questions, is your testimony any different?",
                                 "Is there anything you want to clarify after those questions?"]),
            w.weight >= 2 ? rng.pick(["No. It doesn't.", "No. What I told you is what happened.", "Nothing changes. I'd say it all again."])
                          : rng.pick(["It doesn't change what I remember. I understand why they asked.", "No. Some of it I'm less sure of, and I've said so.", "Not the important part."]))
        return out
    }

    // MARK: Shared pieces

    private static func lower(_ s: String) -> String { s.prefix(1).lowercased() + s.dropFirst() }

    /// How an exhibit came to the investigation, consistent with the fact sheet.
    private static func howObtained(_ item: Evidence, ctx: Context, rng: inout SeededRNG) -> String {
        let s = ctx.sheet
        switch item.kind {
        case .physical:
            switch ctx.facts.origin {
            case .stop: return rng.pick(["It was recovered from the vehicle at the stop on \(s.day) and logged that night.", "It came out of the car during the stop, photographed where it lay, then bagged and sealed."])
            case .warrant: return rng.pick(["It was seized when the warrant was served on \(s.day).", "The search team found it on \(s.day); it was photographed in place before anyone moved it."])
            case .records: return "It was collected during the investigation and logged into evidence."
            default: return rng.pick(["It was collected \(s.place) on \(s.day), photographed in place, and sealed.", "An evidence technician collected it that \(Clock.partOfDay(s.time)) and logged it into the property room."])
            }
        case .forensic:
            let sent = s.labSubmitted.map { " on \(CaseDates.day($0))" } ?? ""
            let back = s.labReturned.map { ", and the report came back \(CaseDates.day($0))" } ?? ""
            return rng.pick(["I submitted it to the State Crime Laboratory\(sent)\(back).", "It went to the State Crime Laboratory\(sent) with a request for analysis\(back)."])
        case .video:
            return rng.pick(["I collected the footage within a few days, before the system could record over it.", "The owner of the system gave us a copy, and I checked its clock against real time.",
                             "We downloaded it and verified the timestamp."])
        case .digital:
            return rng.pick(["We obtained it with a search warrant.", "It came from the provider under a warrant, with a records custodian's certification.", "A forensic examiner extracted it from the device under a warrant."])
        case .document:
            return rng.pick(["We got it by subpoena.", "It was produced to us by the records custodian.", "It came in through a subpoena, certified as a business record."])
        case .statement:
            if let day = s.interview { return "That's \(ctx.dl)'s own statement, recorded on \(CaseDates.day(day))." }
            return rng.pick(["Those are \(ctx.dl)'s own words.", "That statement was made to an officer and documented the same day."])
        }
    }

    private static let significance = [
        "That mattered because it lined up with what the witnesses told us.",
        "On its own it doesn't prove everything, but it fit with the rest.",
        "That was one of the first things that pointed us in a direction.",
        "It's corroboration. It matched the timeline we'd already built.",
        "I'd call it significant. It's hard to explain away.",
        "It helped fix the timing."
    ]

    private static func unit(for ctx: Context) -> String {
        switch ctx.setting {
        case .paper: return ctx.facts.category == .cyber ? "computer crimes" : "financial crimes"
        case .drugs: return "narcotics"
        case .road: return "collision and impaired-driving enforcement"
        case .scene:
            switch ctx.facts.category {
            case .property: return "property crimes"
            case .family: return "crimes against children and families"
            default: return "violent crimes"
            }
        }
    }

    private static func witness(name: String, role: String, side: Side, exchanges: [TestimonyExchange]) -> Witness {
        var w = Witness(name: name, role: role, calledBy: side,
                        direct: exchanges.filter { $0.phase == .direct }.map(\.answer),
                        cross: exchanges.filter { $0.phase != .direct }.map(\.answer),
                        weight: 0, lay: false)
        w.exchanges = exchanges
        return w
    }
}

// MARK: - The lead investigator

extension Testimony {

    /// The lead investigator: how the case began, what was gathered and when, and what wasn't done.
    static func leadInvestigator(name: String, agency: String, ctx: Context, madeTheStop: Bool, rng: inout SeededRNG) -> Witness {
        let s = ctx.sheet
        let dl = ctx.dl
        let facts = ctx.facts
        var ex: [TestimonyExchange] = []
        func d(_ q: String, _ a: String) { ex.append(.init(phase: .direct, examiner: .prosecution, question: q, answer: a)) }
        func c(_ q: String, _ a: String) { ex.append(.init(phase: .cross, examiner: .defense, question: q, answer: a)) }
        func r(_ q: String, _ a: String) { ex.append(.init(phase: .redirect, examiner: .prosecution, question: q, answer: a)) }
        let trooper = agency.contains("Highway Patrol")

        // Who
        d(rng.pick(["Please state your name and assignment.", "Tell the court who you are and where you work.", "State your name and your agency, please."]),
          "\(name), \(agency). " + rng.pick(["I was the lead investigator on this case.",
                                             "I was assigned this case on \(CaseDates.day(s.assigned)) and handled it through the arrest.",
                                             "I've had this case since \(CaseDates.day(s.assigned))."]))
        let years = rng.int(4...19)
        d(rng.pick(["How long have you worked investigations?", "What's your background?", "Tell the court about your experience."]),
          rng.pick(["\(years) years with \(trooper ? "the Patrol" : "the agency"), the last \(max(2, years / 2)) in \(unit(for: ctx)).",
                    "\(rng.int(2...6)) years on patrol, then \(years) years in \(unit(for: ctx)). I've worked somewhere around \(rng.int(6...30) * 10) cases.",
                    "\(years) years. Most of that time has been \(unit(for: ctx))."])
          + (rng.chance(0.5) ? " " + trainingLine(ctx, rng: &rng) : ""))

        // How it began, from the fact sheet
        let begin: String
        switch facts.origin {
        case .call:
            begin = rng.pick([
                "On \(s.day) at about \(s.time ?? "that time"), 911 got a call reporting \(Investigations.incidentNoun(facts, charges: ctx.charges)) \(s.place). \(s.firstOfficer) was first there, at about \(s.arrivalTime ?? "a few minutes later"). I was called \(s.assigned == s.incident ? "out that night" : "the next morning") and took the case.",
                "It started with a 911 call on \(s.day), about \(s.time ?? "that night"). Patrol responded \(s.place). I was assigned \(s.assigned == s.incident ? "within the hour" : "on \(CaseDates.day(s.assigned))")."])
        case .stop:
            begin = madeTheStop
                ? rng.pick(["I was on patrol on \(s.day). At about \(s.time ?? "that time") I stopped the vehicle \(s.place).",
                            "On \(s.day), around \(s.time ?? "that time"), I was working \(s.place) when I stopped the car \(dl) was driving."])
                : "\(s.firstOfficer) made a stop \(s.place) on \(s.day), at about \(s.time ?? "that time"), and called me in once the search turned up what it did."
        case .warrant:
            begin = rng.pick(["We'd been getting information about a residence on \(s.street) for several weeks. I opened the file, built the probable cause, and applied for the warrant we served on \(s.day).",
                              "Complaints and surveillance led us to a house on \(s.street) in \(s.town). The warrant was signed the day before we served it, on \(s.day)."])
        case .report:
            let who = ctx.victim ?? "a member of the public"
            begin = "\(who.capitalizedFirst) reported it to \(agency), and \(s.firstOfficer) took the first report. I was assigned on \(CaseDates.day(s.assigned))."
        case .records:
            let who = ctx.victim ?? ctx.organization ?? "the complaining party"
            begin = rng.pick(["\(who.capitalizedFirst) contacted us on \(s.day) with concerns about \(facts.money ? "missing money" : "what had happened"). I was assigned on \(CaseDates.day(s.assigned)).",
                              "The complaint came in on \(s.day). By \(CaseDates.day(s.assigned)) I had the file and had sent preservation letters."])
        }
        d(rng.pick(["How did this case come to you?", "How did you get involved?", "When did you first hear about this case?"]), begin)

        // First steps
        let steps: [String]
        switch facts.origin {
        case .records:
            steps = ["I sent preservation letters so nothing would be destroyed, then subpoenaed the \(facts.money ? "bank and business records" : "account and provider records").",
                     "I met with \(ctx.victim ?? ctx.organization ?? "the people who reported it"), got the records they had, and then went around them with subpoenas so I wasn't relying only on their copies.",
                     "We reconstructed the \(facts.money ? "transactions one by one" : "account activity") from the source records, then went looking for who had access."]
        case .stop:
            steps = facts.impaired
                ? ["I asked for license and registration, noticed what I noticed, and asked \(dl) to step out for standardized field sobriety tests.",
                   "I had \(dl) step out. I administered the horizontal gaze nystagmus test, the walk-and-turn, and the one-leg stand, then placed \(dl) under arrest and transported for a breath test."]
                : ["I approached, identified the driver, and explained the reason for the stop.",
                   "I spoke with the driver, ran the license, and went from there based on what I saw in the car."]
        case .warrant:
            steps = ["We did surveillance, documented the traffic, and \(facts.mentions(["controlled buy"]) ? "made controlled purchases with an informant" : "checked lease and utility records").",
                     "Before applying for the warrant I confirmed who lived there and who paid the utilities."]
        default:
            steps = facts.setting == .road
                ? ["I photographed and measured the roadway, documented where the vehicles came to rest, and \(facts.mentions(["blood"]) ? "got a search warrant for a blood draw" : "spoke with the drivers and the witnesses").",
                   "I went to the scene, worked with the reconstruction unit on measurements, and made sure the vehicles were held."]
                : ["I went to \(s.place), walked it with the evidence technicians, and made sure everything was photographed before anything moved.",
                   "I spoke with the first officer, had the scene processed, and started lining up interviews.",
                   "I reviewed the first officer's report and body camera, then went back to \(s.street) in daylight to see it for myself."]
        }
        d(rng.pick(["What did you do first?", "What were your first steps?", "Walk the court through how you started."]), rng.pick(steps))

        // The evidence, in the order it was found
        let items = Array(ctx.stateInOrder.filter { $0.kind != .statement }.prefix(rng.int(2...4)))
        for (index, item) in items.enumerated() {
            let q = index == 0
                ? rng.pick(["Let's turn to \(item.exhibit). What is it?", "Tell the court about \(item.exhibit), the \(lower(item.title)).", "What's \(item.exhibit)?"])
                : rng.pick(["What about \(item.exhibit)?", "And \(item.exhibit), the \(lower(item.title))?", "Tell the court how you got the \(lower(item.title)).", "What did the \(lower(item.title)) show?"])
            let how = howObtained(item, ctx: ctx, rng: &rng)
            let why = rng.chance(0.55) ? " " + rng.pick(significance) : ""
            d(q, "\(item.detail) \(how)\(why)")
        }

        // Who it was
        let identityAtIssue = facts.identity || facts.origin == .records || facts.origin == .report
            || (facts.origin == .call && facts.setting != .road && !ctx.report.howIdentified.contains("still"))
        if identityAtIssue {
            d(rng.pick(["How did \(dl) become a suspect?", "How did the investigation come to focus on \(dl)?", "What led you to \(dl)?"]),
              ctx.report.howIdentified + " " + rng.pick(["Everything after that was about testing it.", "From there we tried to confirm it or rule it out.", "We didn't stop there; we kept checking it against the rest."]))
        } else {
            d(rng.pick(["Was there any question about who was involved?", "How was \(dl) identified?"]),
              ctx.report.howIdentified)
        }

        // The statement
        if let day = s.interview {
            let statement = ctx.state.first { $0.kind == .statement }
            d(rng.pick(["Did \(dl) give a statement?", "Did you interview \(dl)?", "Did \(dl) talk to you?"]),
              "Yes. On \(CaseDates.day(day)), after Miranda warnings, \(dl) signed a waiver and talked for about \(rng.int(2...9) * 10) minutes. It was recorded." + (statement.map { " The key part: \($0.detail)" } ?? ""))
        } else {
            d(rng.pick(["Did \(dl) give a statement?", "Did you try to interview \(dl)?"]),
              rng.pick(["No. \(dl) asked for a lawyer, and the interview ended.", "I asked. \(dl) declined and asked for an attorney, which is \(dl)'s right.",
                        "\(dl) declined through counsel."]))
        }

        // The arrest
        let resisted = ctx.lawIDs.contains("resisting")
        let arrestLine: String
        if facts.origin == .records {
            arrestLine = rng.pick(["\(dl) surrendered at the magistrate's office with a lawyer.", "\(dl) surrendered by arrangement with counsel."])
        } else if resisted {
            arrestLine = "\(dl) pulled away and had to be taken to the ground before handcuffs went on."
        } else if s.arrest == s.incident && facts.origin != .warrant {
            arrestLine = rng.pick(["It happened right there. \(dl) was cooperative.", "That same \(Clock.partOfDay(s.time)). There were no problems."])
        } else {
            arrestLine = rng.pick(["It was uneventful.", "\(dl) was cooperative.", "No problems. \(dl) was quiet."])
        }
        d(rng.pick(["When was \(dl) arrested?", "Tell the court about the arrest.", "How did the arrest happen?"]),
          "On \(CaseDates.day(s.arrest)). " + arrestLine)

        if let sent = s.labSubmitted {
            let forensic = ctx.state.filter { $0.kind == .forensic }
            d(rng.pick(["Did anything go to the State Crime Laboratory?", "Were items submitted for testing?"]),
              "Yes. On \(CaseDates.day(sent)) I submitted \(forensic.map { lower($0.title) }.joined(separator: " and ")). " + (s.labReturned.map { "The results came back on \(CaseDates.day($0))." } ?? ""))
        }

        // Cross: the gaps in this file, then the weak points of this kind of case
        for gap in ctx.gaps { c(gap.question, gap.answer) }
        var pool: [(String, String)] = []
        if identityAtIssue && facts.setting != .paper {
            pool.append(("Did you ever seriously consider anyone other than \(dl)?",
                         ctx.defense.contains { $0.title.lowercased().contains("tip") } ? "We looked at it. Not as closely as we might have." : "We followed the evidence. It led to \(dl)."))
            pool.append(("Once you had a suspect, you stopped looking, didn't you?", rng.pick(["No. We kept working the case through the arrest.", "I'd disagree. We kept testing it."])))
        }
        switch facts.setting {
        case .road:
            if facts.impaired {
                pool.append(("Nystagmus can come from things other than alcohol, can't it?", "Some forms can. What I saw was consistent with impairment, and the breath result confirmed it."))
                pool.append(("\(dl) was polite and cooperative?", "Yes. That's not unusual."))
                pool.append(("\(dl) produced a license and registration without fumbling?", rng.pick(["That part went fine.", "Yes, as I recall."])))
            }
            if facts.mentions(["crash", "struck", "killed", "collision"]) {
                pool.append(("You never saw \(dl) driving before the crash?", "No. I arrived after."))
                pool.append(("Your report doesn't analyze what the other vehicle was doing?", "It focuses on what caused the crash. I didn't find fault on the other side."))
            }
        case .drugs:
            pool.append(("You never saw \(dl) sell anything to anyone?", rng.pick(["Not personally, no.", "Not with my own eyes. The circumstances showed it."])))
            pool.append(("Nothing illegal was found in \(dl)'s pockets?", rng.pick(["Not in the pockets, no.", "Correct. It was in the \(facts.origin == .stop ? "car" : "house")."])))
            pool.append(("\(dl) works as \(withArticle(ctx.defendant.occupation)). Cash can come from a job, can't it?", "It can. We didn't find a pay stub that explained that amount."))
        case .paper:
            pool.append(("You're not an accountant?", rng.pick(["No. We had an analyst for the numbers, and I reviewed the work.", "No. I'm an investigator. The totals were checked by someone who is."])))
            pool.append(("You took the complainant's word for which transactions were unauthorized?", "At first. Then we tested it against the records."))
            if s.interview == nil { pool.append(("You never heard \(dl)'s side before charging?", "\(dl) declined to be interviewed through counsel. That was the opportunity.")) }
        case .scene:
            if facts.origin == .report {
                pool.append(("Most of what you know came from \(ctx.victim ?? "the person who reported it")?", "The report started there. The investigation didn't end there."))
            }
        }
        pool.append(("You wrote your final report after the arrest, didn't you?", "The supplemental report, yes. The initial report was written as things happened."))
        if let def = ctx.defense.first {
            pool.append(("Did your investigation ever account for the \(lower(def.title))?",
                         rng.pick(["I learned about it from the defense. It didn't change my view of the evidence.", "I'm aware of it. I don't think it outweighs what we found.", "No. That came in later."])))
        }
        for (q, a) in rng.pick(pool, count: rng.int(2...3)) { c(q, a) }

        // Redirect
        var redirect: [(String, String)] = [
            ("Does anything you were asked on cross change what the evidence showed?", "No. The gaps they pointed to are real, but they don't change what we found."),
            ("Did you have any reason to cut corners in this case?", "No. It got the same work I'd give any case.")
        ]
        if let top = ctx.strongest {
            redirect.append(("Would any of the steps counsel mentioned change what the \(lower(top.title)) shows?", "No. The \(lower(top.title)) is what it is."))
        }
        if identityAtIssue {
            redirect.append(("Why did the investigation focus on \(dl)?", "Because of what the evidence showed. " + ctx.report.howIdentified))
        }
        for (q, a) in rng.pick(redirect, count: rng.int(1...2)) { r(q, a) }
        return witness(name: name, role: trooper ? "Investigating trooper, \(agency)" : "Lead investigator, \(agency)", side: .prosecution, exchanges: ex)
    }

    private static func trainingLine(_ ctx: Context, rng: inout SeededRNG) -> String {
        switch ctx.setting {
        case .road: return rng.pick(["I'm certified to administer standardized field sobriety tests and to operate the Intoxilyzer 9000.", "I've completed advanced collision investigation and drug recognition training."])
        case .paper: return rng.pick(["I've completed financial investigations training through the SBI and certified fraud examiner coursework.", "I've had training in following money through bank records and in digital evidence."])
        case .drugs: return rng.pick(["I've completed DEA basic narcotics school and interdiction training.", "I've been through the State's drug identification and undercover operations courses."])
        case .scene: return rng.pick(["I've completed homicide and crime scene courses at the Justice Academy.", "I've had interview and interrogation training and crime scene processing courses."])
        }
    }
}

// MARK: - The first officer

extension Testimony {

    /// The patrol officer or deputy who got there first (or made the stop, or helped serve the warrant).
    static func firstOfficer(name: String, agency: String, ctx: Context, rng: inout SeededRNG) -> Witness {
        let s = ctx.sheet
        let dl = ctx.dl
        let facts = ctx.facts
        var ex: [TestimonyExchange] = []
        func d(_ q: String, _ a: String) { ex.append(.init(phase: .direct, examiner: .prosecution, question: q, answer: a)) }
        func c(_ q: String, _ a: String) { ex.append(.init(phase: .cross, examiner: .defense, question: q, answer: a)) }
        let late = rng.chance(0.35)
        let years = rng.int(2...16)
        let collected = ctx.state.filter { $0.kind == .physical }

        d(rng.pick(["Please state your name and assignment.", "Tell the court who you are.", "Where do you work, and what do you do?"]),
          "\(name). I'm with \(agency), assigned to \(rng.pick(["patrol", "the \(s.town) district", "the evening patrol shift", "uniform patrol"])). " + rng.pick(["\(years) years now.", "I've been there \(years) years.", "Going on \(years) years."]))

        var crossPool: [(String, String)] = []
        switch facts.origin {
        case .stop:
            let reason: String
            if facts.impaired { reason = rng.pick(["The vehicle crossed the center line twice and drifted onto the fog line.", "It was weaving inside its lane and then braked hard for no reason at a green light."]) }
            else if facts.mentions(["windshield"]) { reason = "A cracked windshield obstructing the driver's view." }
            else if facts.mentions(["taillight", "headlight"]) { reason = "An equipment violation: a light was out." }
            else { reason = rng.pick(["It was doing 58 in a 45.", "Expired registration and a dead tag light.", "It rolled through a stop sign."]) }
            d(rng.pick(["Why did you stop the vehicle?", "What drew your attention to the car?"]),
              "On \(s.day), at about \(s.time ?? "that time"), I was on patrol \(s.place). \(reason)")
            d(rng.pick(["Who was driving?", "Who did you find behind the wheel?"]),
              "\(dl). " + rng.pick(["I identified \(dl) from a driver's license.", "\(dl) gave me a license, and the photo matched.", "There was no question about that; \(dl) was the only one in the driver's seat."]))
            d(rng.pick(["What did you notice when you spoke with the driver?", "What happened when you approached?"]),
              facts.setting == .drugs
                ? rng.pick(["\(dl)'s hands were shaking and \(dl) kept looking at the center console. There was a strong odor coming from the car.", "\(dl) was talking fast and gave two different answers about where \(dl) was coming from."])
                : rng.pick(["\(dl) was nervous and kept reaching toward the console.", "\(dl) was calm, but the story about where \(dl) was headed didn't add up."]))
            if !collected.isEmpty {
                d(rng.pick(["What was found in the vehicle?", "Did you find anything?"]),
                  collected.map { "\($0.title): \($0.detail)" }.prefix(2).joined(separator: " "))
            }
            crossPool += [("The reason for the stop was minor, wasn't it?", "It was a violation. I stop cars for that every shift."),
                          ("You'd already decided to search before you had any reason to?", "No. I searched because of what I saw once I was at the window."),
                          ("Nothing about the driving itself was dangerous?", "Not in the moment I saw. That's not the standard for a stop.")]
        case .warrant:
            d(rng.pick(["What was your role on \(s.day)?", "How were you involved in the search?"]),
              rng.pick(["I was on the entry team. We knocked, announced, waited, and went in when no one answered.", "I held the perimeter, then helped search the back bedroom once the house was secured."]))
            d(rng.pick(["Who was inside?", "What did you find when you went in?"]),
              facts.mentions(["three people"]) ? "Three adults. \(dl) was one of them, in the living room." : "\(dl) was there. " + rng.pick(["In the kitchen.", "Coming out of the hallway.", "On the couch."]))
            if !collected.isEmpty { d("What did you find?", collected.map { "\($0.title): \($0.detail)" }.prefix(2).joined(separator: " ")) }
            crossPool += [("You didn't see \(dl) holding anything illegal?", "No. I saw where things were and who was there."),
                          ("Other people lived in or visited that house?", "Other people were there. I can't tell you who lived there."),
                          ("The bedroom where it was found, you don't know whose it was?", "I know what was in it. Mail with \(dl)'s name was on the dresser.")]
        case .report:
            let who = ctx.victim ?? "the person reporting it"
            d(rng.pick(["How did you get involved?", "What was your role?"]),
              "I took the initial report from \(who) on \(CaseDates.day(CaseDates.add(0, to: s.incident))). " + rng.pick(["\(who.capitalizedFirst) was upset but clear about what happened.", "I wrote down what I was told and passed it to investigations."]))
            d(rng.pick(["What did you do with that report?", "What happened next?"]),
              "It went to \(s.lead), who took over on \(CaseDates.day(s.assigned)).")
            crossPool += [("You didn't see any of this yourself?", "No. I took the report."),
                          ("You wrote down what you were told, not what you verified?", "That's what an initial report is.")]
        default:
            d(rng.pick(["How did you come to respond on \(s.day)?", "Officer, how did you get involved?", "What brought you there?"]),
              "I was on patrol in \(s.town) when dispatch sent me to a call reporting \(Investigations.incidentNoun(facts, charges: ctx.charges)) \(s.place). I got there at about \(s.arrivalTime ?? "a few minutes later").")
            d(rng.pick(["What did you see when you arrived?", "Describe what you found.", "What was going on when you got there?"]), arrivalScene(ctx, rng: &rng))
            d(rng.pick(["What did you do?", "What were your first steps?"]),
              rng.pick(["Checked on everyone's safety, separated the people present, secured the area, and called for a detective and evidence technicians.",
                        "I made sure no one was still in danger, called for EMS, and kept everyone who'd seen anything from leaving.",
                        "Set up tape, started a scene log, and kept witnesses apart until investigators arrived."]))
            let named = ctx.report.howIdentified.contains("to the first officer")
            d(rng.pick(["Did anyone speak with you?", "Did anyone tell you what happened?"]),
              named ? "\(ctx.victim ?? "One person") did, and gave me \(dl)'s name." :
                rng.pick(["A few people. They gave a description, but no names that night.", "People were talking over each other. I wrote down what I could and got contact information."]))
            if !collected.isEmpty && rng.chance(0.6) {
                d(rng.pick(["Was anything collected while you were there?", "Did you see any physical evidence?"]),
                  "The technicians collected \(collected.map { lower($0.title) }.prefix(2).joined(separator: " and ")). I stood by and kept the scene log.")
            }
            crossPool += [("You didn't see any crime being committed, did you?", "No. It was over when I got there."),
                          ("You arrived after the people involved had time to talk to each other?", "Some of them, yes."),
                          ("Did anyone at the scene name \(dl) to you?", named ? "Yes. I've said so." : rng.pick(["Not by name. They gave a description.", "No, not that night."]))]
        }
        d(rng.pick(["Was your body camera running?", "Is any of this on video?"]),
          late ? "Yes. I activated it about two minutes after I \(facts.origin == .stop ? "walked up to the car" : "arrived")." : rng.pick(["Yes, from the moment I got out of the car.", "Yes. Body camera and dash camera both."]))
        if late { crossPool.append(("So the first two minutes aren't on video?", "That's right.")) }
        crossPool.append(("Did you write down what people told you word for word?", "I wrote down the substance. Not every word."))
        for (q, a) in rng.pick(crossPool, count: rng.int(2...4)) { c(q, a) }
        if rng.chance(0.6) {
            ex.append(.init(phase: .redirect, examiner: .prosecution, question: rng.pick(["Is your report accurate?", "Did you record what you saw accurately?"]),
                            answer: rng.pick(["Yes. I wrote it that night, while it was fresh.", "Yes. Everything I saw is in it."])))
        }
        return witness(name: name, role: facts.origin == .stop ? "Arresting officer, \(agency)" : "Responding officer, \(agency)", side: .prosecution, exchanges: ex)
    }

    private static func arrivalScene(_ ctx: Context, rng: inout SeededRNG) -> String {
        let s = ctx.sheet
        let light = Clock.partOfDay(s.time) == "night" ? rng.pick(["It was dark; the light was from a streetlight and my headlights.", "It was dark except for the storefront lights."]) : "It was daylight."
        let what: String
        switch ctx.setting {
        case .road:
            what = rng.pick(["Two vehicles off the road, one on its side. People were out of their cars, some on the phone with 911.",
                             "A vehicle in the ditch with front-end damage, debris across both lanes, and people standing on the shoulder."])
        case .drugs:
            what = rng.pick(["A small crowd outside a house, and someone doing CPR inside.", "People in the yard, and one person on the floor inside not responding."])
        default:
            switch ctx.facts.category {
            case .property:
                what = rng.pick(["The rear door was open and the frame was splintered. Nobody was inside.", "Glass on the ground and a door standing open."])
            case .violent, .robbery, .family:
                if let v = ctx.victim, ctx.fatal {
                    what = rng.pick(["\(v) was on the ground, not responding. A bystander was doing CPR, and I took over until EMS arrived.", "EMS was already working on \(v). People nearby were shouting, and someone was crying."])
                } else if let v = ctx.victim {
                    what = rng.pick(["\(v) was there, hurt and upset. Two or three other people were standing around.", "A small crowd, and \(v) being helped by a bystander."])
                } else {
                    what = rng.pick(["A small crowd and a lot of shouting.", "People standing around, and a lot of talking at once."])
                }
            default:
                what = rng.pick(["A crowd, some shouting, and people pointing in different directions.", "A small group of people, most of them on their phones."])
            }
        }
        return "\(what) \(light)"
    }
}
