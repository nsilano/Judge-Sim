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

// MARK: - State Crime Laboratory analysts

extension Testimony {

    enum Discipline: CaseIterable {
        case drugChemistry, toxicology, dna, latentPrints, firearms, fireDebris, trace

        var section: String {
            switch self {
            case .drugChemistry: return "Drug Chemistry"
            case .toxicology: return "Toxicology"
            case .dna: return "Forensic Biology and DNA"
            case .latentPrints: return "Latent Evidence"
            case .firearms: return "Firearms and Toolmarks"
            case .fireDebris: return "Trace Evidence (fire debris)"
            case .trace: return "Trace Evidence"
            }
        }

        var title: String {
            switch self {
            case .drugChemistry: return "Forensic chemist"
            case .toxicology: return "Forensic toxicologist"
            case .dna: return "DNA analyst"
            case .latentPrints: return "Latent print examiner"
            case .firearms: return "Firearms examiner"
            case .fireDebris, .trace: return "Trace evidence analyst"
            }
        }

        static func of(_ item: Evidence, setting: CaseSetting) -> Discipline {
            let t = (item.title + " " + item.detail).lowercased()
            if ["blood alcohol", "blood-alcohol", "toxicology", "bac", "alcohol concentration", "blood draw", "blood test"].contains(where: { t.contains($0) }) { return .toxicology }
            if ["dna", "swab", "profile"].contains(where: { t.contains($0) }) { return .dna }
            if ["fingerprint", "latent", "print"].contains(where: { t.contains($0) }) { return .latentPrints }
            if ["casing", "cartridge", "bullet", "ballistic", "firearm", "rifling"].contains(where: { t.contains($0) }) { return .firearms }
            if ["accelerant", "gasoline", "fire debris", "ignitable"].contains(where: { t.contains($0) }) { return .fireDebris }
            if setting == .drugs || ["cocaine", "fentanyl", "heroin", "methamphetamine", "oxycodone", "grams", "powder", "pills", "substance", "thc", "plant material"].contains(where: { t.contains($0) }) { return .drugChemistry }
            if ["toxic", "poison", "overdose", "antifreeze", "ethylene"].contains(where: { t.contains($0) }) { return .toxicology }
            return .trace
        }
    }

    /// One analyst per laboratory section that handled this case's forensic exhibits (at most two).
    static func analysts(ctx: Context, names: [String], rng: inout SeededRNG) -> [Witness] {
        let forensic = ctx.state.filter { $0.kind == .forensic }
        var groups: [(Discipline, [Evidence])] = []
        for item in forensic {
            let discipline = Discipline.of(item, setting: ctx.setting)
            if let index = groups.firstIndex(where: { $0.0 == discipline }) { groups[index].1.append(item) } else { groups.append((discipline, [item])) }
        }
        var out: [Witness] = []
        for (index, group) in groups.prefix(min(2, names.count)).enumerated() {
            out.append(analyst(name: names[index], discipline: group.0, items: group.1, ctx: ctx, rng: &rng))
        }
        return out
    }

    private static func analyst(name: String, discipline: Discipline, items: [Evidence], ctx: Context, rng: inout SeededRNG) -> Witness {
        let s = ctx.sheet
        let dl = ctx.dl
        var ex: [TestimonyExchange] = []
        func d(_ q: String, _ a: String) { ex.append(.init(phase: .direct, examiner: .prosecution, question: q, answer: a)) }
        func c(_ q: String, _ a: String) { ex.append(.init(phase: .cross, examiner: .defense, question: q, answer: a)) }
        let years = rng.int(3...21)
        let degree: String
        switch discipline {
        case .drugChemistry, .toxicology, .fireDebris, .trace: degree = rng.pick(["a bachelor's degree in chemistry", "a master's degree in forensic science", "a degree in biochemistry"])
        case .dna: degree = rng.pick(["a master's degree in molecular biology", "a bachelor's degree in biology with graduate coursework in genetics"])
        case .latentPrints: degree = rng.pick(["a bachelor's degree in forensic science and IAI certification as a latent print examiner", "a biology degree and a two-year in-house training program"])
        case .firearms: degree = rng.pick(["a bachelor's degree in chemistry and the laboratory's two-year firearms training program", "a forensic science degree and AFTE training"])
        }

        d(rng.pick(["Where do you work, and what do you do?", "Please tell the court your name and your position.", "Where are you employed?"]),
          "\(name). I'm a forensic scientist in the \(discipline.section) section of the North Carolina State Crime Laboratory" + rng.pick([". I've been there \(years) years.", ", for \(years) years now.", "; I've worked there \(years) years."]))
        d(rng.pick(["What is your training?", "Tell the court about your education and experience.", "What qualifies you to do this work?"]),
          "I have \(degree). " + rng.pick(["I pass a proficiency test every year, and I've analyzed more than \(rng.int(8...40) * 100) items.",
                                           "Before I worked cases on my own I completed a supervised training program and competency tests.",
                                           "I've testified about my work \(rng.int(10...150)) times, in state and federal court."]))
        if rng.chance(0.6) {
            d(rng.pick(["Is the laboratory accredited?", "Does the lab follow written procedures?"]),
              rng.pick(["Yes. We're accredited under the ISO/IEC 17025 standard, and we're audited regularly.",
                        "Yes. Every method we use is validated and written down, and the lab is accredited and audited by an outside body.",
                        "Yes, accredited. Every report is technically reviewed by a second qualified analyst before it's released."]))
        }
        if rng.chance(0.5) {
            d("Your Honor, the State tenders \(name) as an expert in \(discipline.section.lowercased()).",
              rng.pick(["Without objection, the witness is accepted as an expert.", "The defense has no objection. The court accepts the witness."]))
        }

        for (index, item) in items.prefix(2).enumerated() {
            let title = lower(item.title)
            let sent = s.labSubmitted.map { CaseDates.day($0) } ?? "the date on the request"
            d(index == 0 ? rng.pick(["How did the \(title) come to you?", "Tell the court how \(item.exhibit) reached the laboratory.", "What did you receive in this case?"])
                         : rng.pick(["Did you also examine the \(title)?", "What about \(item.exhibit)?"]),
              "\(s.agency) submitted it on \(sent), " + rng.pick(["in a sealed bag with the officer's initials across the seal.", "heat-sealed and labeled with the case number.", "with a request for analysis and a chain-of-custody form."])
                + " " + rng.pick(["The seal was intact when I opened it, and I documented that.", "I checked the seal and the labels against the request before opening it.", "Nothing about the packaging suggested tampering."]))
            d(rng.pick(["What did you do with it?", "How did you analyze it?", "Walk the court through your method."]), method(discipline, rng: &rng))
            d(rng.pick(["What were your results?", "What did you conclude?", "What did the analysis show?"]),
              ("\(item.detail) " + conclusionFrame(discipline, rng: &rng)).trimmingCharacters(in: .whitespaces))
        }
        if let back = s.labReturned {
            d(rng.pick(["When did you issue your report?", "When was your report released?"]),
              "On \(CaseDates.day(back)). " + rng.pick(["It was technically and administratively reviewed before it went out.", "A second analyst reviewed my data and agreed with my conclusions."]))
        }

        // Cross: the limits of this discipline
        var pool = crossPool(discipline, ctx: ctx, rng: &rng)
        pool.append(("Has your lab ever had to correct a result?", "Every lab has corrected errors. That's why there's a review process, and this result was reviewed."))
        pool.append(("Were there items from this case the agency never sent you?", rng.chance(0.5) ? "Yes. Some items weren't submitted for testing." : "Not that I'm aware of."))
        pool.append(("You don't know what happened to the \(lower(items[0].title)) before it got to your lab?", "I know what the chain-of-custody form says. Before that, I'd defer to the officers."))
        for (q, a) in rng.pick(pool, count: rng.int(3...4)) { c(q, a) }
        ex.append(.init(phase: .redirect, examiner: .prosecution,
                        question: rng.pick(["Does anything you were asked on cross change your results?", "Was your result confirmed?"]),
                        answer: rng.pick(["No. The limits counsel pointed out are real, and they're in my report. The result is the result.",
                                          "Yes. It was reviewed, and the controls ran correctly. My conclusion stands.", "No. I'd testify to the same result today."])))
        _ = dl
        return witness(name: name, role: "\(discipline.title), State Crime Laboratory", side: .prosecution, exchanges: ex)
    }

    private static func method(_ discipline: Discipline, rng: inout SeededRNG) -> String {
        switch discipline {
        case .drugChemistry:
            return rng.pick(["I weighed it, then ran a color test as a screen and confirmed with gas chromatography-mass spectrometry, which identifies the compound by its chemical fingerprint.",
                             "Net weight first, without packaging. Then I took a representative sample and confirmed its identity by GC-MS against a reference standard run the same day.",
                             "I documented the packaging, weighed the contents, and analyzed a sample with GC-MS. The instrument's controls ran clean before and after."])
        case .toxicology:
            return rng.pick(["Headspace gas chromatography, run in duplicate with calibrators and controls. The two results have to agree within a set tolerance.",
                             "I analyzed the blood for alcohol by headspace GC, in duplicate, and screened for other drugs with an immunoassay followed by confirmation.",
                             "Two separate aliquots, each run against a calibration curve, with controls above and below the legal limit."])
        case .dna:
            return rng.pick(["I extracted DNA, measured how much there was, copied specific regions, and compared the resulting profile to the known reference samples.",
                             "Standard STR testing: extraction, quantitation, amplification, and capillary electrophoresis. Then a statistical comparison with probabilistic genotyping software.",
                             "I swabbed the item, developed a profile, and compared it to the reference swabs submitted with the case."])
        case .latentPrints:
            return rng.pick(["I processed the item chemically, photographed the prints that developed, and compared them to the known prints using ACE-V: analysis, comparison, evaluation, and verification by a second examiner.",
                             "I used powder and superglue fuming, captured the latent prints, and compared them side by side with the ten-print card.",
                             "ACE-V. I analyzed the latent print for quality first, compared it with the known prints, evaluated the agreement, and a second examiner verified it blind."])
        case .firearms:
            return rng.pick(["I test-fired the firearm into a water tank, recovered the test bullets and casings, and compared their markings under a comparison microscope.",
                             "I checked the firearm for function, fired test shots, and compared the toolmarks on the test casings with the casings from the scene.",
                             "Comparison microscopy: the evidence casing on one side, a test-fired casing on the other, looking for agreement in individual markings."])
        case .fireDebris:
            return rng.pick(["I extracted the debris with a passive headspace method and ran the extract on GC-MS, comparing the pattern to known ignitable liquids.",
                             "The cans were sealed at the scene. I extracted vapors onto a carbon strip and analyzed them by GC-MS."])
        case .trace:
            return rng.pick(["Microscopy first, then instrumental comparison of the questioned sample with the known sample.",
                             "I compared the questioned material with the known samples using microscopy and infrared spectroscopy."])
        }
    }

    private static func conclusionFrame(_ discipline: Discipline, rng: inout SeededRNG) -> String {
        switch discipline {
        case .drugChemistry: return rng.pick(["That's a confirmed identification, not a field test.", "The identification is by GC-MS, which is the confirmatory standard.", ""])
        case .toxicology: return rng.pick(["That result reflects the blood at the time it was drawn.", "Both runs agreed within tolerance.", ""])
        case .dna: return rng.pick(["DNA tells you whose DNA is there. It doesn't tell you when or how it got there.", "The statistic is in my report.", ""])
        case .latentPrints: return rng.pick(["The conclusion was verified by a second examiner.", "A print can't be dated; I can only say whose it is.", ""])
        case .firearms: return rng.pick(["That's my opinion based on the agreement of individual markings.", "A second examiner verified the comparison.", ""])
        case .fireDebris, .trace: return rng.pick(["That's what the instrument data supports, and no more.", ""])
        }
    }

    private static func crossPool(_ discipline: Discipline, ctx: Context, rng: inout SeededRNG) -> [(String, String)] {
        let dl = ctx.dl
        switch discipline {
        case .drugChemistry:
            return [("You tested one sample. The rest you weighed?", "One representative sample from the bulk, consistent with our sampling plan."),
                    ("Your result tells the court what the substance is, not who possessed it?", "That's right. Possession isn't a chemistry question."),
                    ("You didn't test purity?", "No. North Carolina law goes by weight, not purity, so purity isn't part of the analysis."),
                    ("How long did the item sit before you tested it?", "It waited in the queue. It was sealed and stored in the vault the whole time.")]
        case .toxicology:
            var pool: [(String, String)] = [
                ("Your number is the level when the blood was drawn, not when \(dl) was driving?", "Correct. I measured the sample I received."),
                ("Alcohol can still be absorbing after someone stops drinking?", "It can. Whether it was still absorbing depends on facts I don't have."),
                ("You didn't do a retrograde extrapolation?", "I wasn't asked to, and it would require assumptions about drinking and food I can't verify.")]
            if ctx.facts.mentions(["hospital"]) { pool.append(("Hospital serum results run higher than whole blood, don't they?", "Serum values run higher, yes. My result is on whole blood.")) }
            return pool
        case .dna:
            return [("DNA can be transferred by touch, without the person ever being there?", "Secondary transfer happens. I can't tell you how the DNA got there."),
                    ("The sample was a mixture?", rng.pick(["There was a minor contributor I couldn't interpret.", "A two-person mixture. The major profile is the one I reported."])),
                    ("You can't say when the DNA was left?", "No. DNA doesn't carry a date."),
                    ("Was the unknown profile ever run through CODIS?", rng.pick(["It didn't meet the upload criteria.", "Not that I'm aware of."]))]
        case .latentPrints:
            return [("Fingerprint comparison is ultimately a judgment call by the examiner?", "It's a trained judgment, documented and verified. Yes, it's a judgment."),
                    ("There's no agreed number of points required for an identification?", "Not in this country. The quality and quantity of detail are evaluated together."),
                    ("A print can't tell the court when it was left?", "Correct.")]
        case .firearms:
            return [("There's no statistic behind 'identification' in your field, is there?", "We don't report a statistic. Our conclusions are based on validated comparison methods."),
                    ("The 2016 PCAST report criticized the foundations of firearms comparison?", "It raised concerns. Studies since then have addressed some of them."),
                    ("You can't say who fired the gun?", "No. Only that the casing was fired in that firearm.")]
        case .fireDebris:
            return [("Gasoline is found in plenty of garages and sheds without anyone committing arson?", "It's common. My result is about the debris, not intent."),
                    ("You can't say how the liquid got there?", "No.")]
        case .trace:
            return [("Your comparison shows the materials are similar, not that they came from the same source?", "Consistent with a common source. Not unique."),
                    ("Those materials are mass-produced?", "Many are, yes.")]
        }
    }
}

// MARK: - Character witnesses

extension Testimony {

    /// Someone who knows the defendant outside this case: a supervisor, teacher, pastor, coach, or neighbor.
    static func characterWitness(name: String, ctx: Context, rng: inout SeededRNG) -> Witness {
        let dl = ctx.dl
        let profile = ctx.defendant.profile
        let background = ctx.defendant.background.lowercased()
        let job = profile?.jobs.first { $0.current && $0.title != "Unemployed" }
        let pastJob = profile?.jobs.first { !$0.current }
        let student = job.map { $0.title.lowercased().contains("student") } ?? false
        let years = rng.int(3...16)

        enum Tie { case supervisor, instructor, formerBoss, pastor, coach, neighbor }
        var ties: [Tie] = [.neighbor]
        if job != nil { ties.append(student ? .instructor : .supervisor) }
        if pastJob != nil { ties.append(.formerBoss) }
        if background.contains("church") || background.contains("pantry") { ties.append(.pastor) }
        if background.contains("coach") || background.contains("soccer") { ties.append(.coach) }
        let tie = rng.pick(ties)

        let role: String
        let howKnown: String
        let seen: String
        switch tie {
        case .supervisor:
            role = "\(dl)'s supervisor at \(job?.employer ?? "work")"
            howKnown = "I've supervised \(dl) at \(job?.employer ?? "work") since \(job.map { String($0.years.prefix(4)) } ?? "a few years back")."
            seen = rng.pick(["Shows up early, stays when we're short. I've trusted \(dl) with the keys and the cash drawer.",
                             "When we had layoffs, \(dl) was one of the people I fought to keep.",
                             "Reliable. If \(dl) says something's done, it's done."])
        case .instructor:
            role = "\(dl)'s instructor at \(job?.employer ?? "school")"
            howKnown = "\(dl) has been in my classes for \(rng.int(2...4)) semesters."
            seen = rng.pick(["Turns in the work, asks good questions, helps the students who are struggling.", "Quiet, but the kind of student other students go to for help."])
        case .formerBoss:
            role = "\(dl)'s former employer at \(pastJob?.employer ?? "a previous job")"
            howKnown = "\(dl) worked for me as \(withArticle(pastJob?.title.lowercased() ?? "an employee")), \(pastJob?.years ?? "for a few years")."
            seen = rng.pick(["I'd hire \(dl) back tomorrow.", "Never a write-up. Not one.", "When \(dl) left, it was for a better job, and I gave a good reference."])
        case .pastor:
            role = "\(dl)'s pastor"
            howKnown = "\(dl) has been part of our congregation for \(years) years, and volunteers at the food pantry most weekends."
            seen = rng.pick(["When the pantry ran short last winter, \(dl) organized a drive on their own.", "I've watched \(dl) with the families who come to us. Patient. Respectful."])
        case .coach:
            role = "Fellow youth soccer coach"
            howKnown = "We've coached kids' soccer together in \(ctx.sheet.town) for \(years) seasons."
            seen = rng.pick(["I've seen \(dl) with a team of nine-year-olds after a bad loss. Never lost that temper once.", "Parents ask for \(dl)'s team. That tells you something."])
        case .neighbor:
            role = "\(dl)'s longtime neighbor"
            howKnown = "We've lived next door to each other for \(years) years."
            seen = rng.pick(["Checks on my mother when I'm out of town. Shovels the walk without being asked.", "We look out for each other's houses. \(dl) has a key to mine.", "Quiet. Friendly. The kind of neighbor you hope for."])
        }

        let trait: String
        switch ctx.setting {
        case .paper: trait = "honesty"
        case .drugs, .road: trait = "being law-abiding"
        case .scene: trait = ([.violent, .robbery, .family, .publicOrder] as [LawCategory]).contains(ctx.facts.category) ? "peacefulness" : "honesty"
        }

        var ex: [TestimonyExchange] = []
        func d(_ q: String, _ a: String) { ex.append(.init(phase: .direct, examiner: .defense, question: q, answer: a)) }
        func c(_ q: String, _ a: String) { ex.append(.init(phase: .cross, examiner: .prosecution, question: q, answer: a)) }
        d(rng.pick(["Please tell the court your name.", "Would you introduce yourself?"]), "\(name).")
        d(rng.pick(["How do you know \(dl)?", "What's your connection to \(dl)?"]), howKnown)
        d(rng.pick(["What have you seen of \(dl) in that time?", "Tell the court what \(dl) is like.", "How would you describe \(dl)?"]), seen)
        d(rng.pick(["Do you know \(dl)'s reputation in the community for \(trait)?", "What is \(dl)'s reputation for \(trait)?"]),
          rng.pick(["Good. People trust \(dl).", "I've never heard a bad word about \(dl) on that score.", "Excellent. Ask anybody who knows \(dl)."]))
        d(rng.pick(["Do you have your own opinion about \(dl)'s \(trait)?", "And your personal opinion?"]),
          rng.pick(["I do. I'd stake my own name on it.", "In my opinion, \(dl) is as \(trait == "peacefulness" ? "gentle" : "honest") a person as I know.", "My opinion is the same as everyone else's."]))
        if rng.chance(0.6) {
            d(rng.pick(["Has anything about \(dl) changed since the arrest?", "How has \(dl) been since this started?"]),
              rng.pick(["Quieter. Worried. Still shows up.", "Not that I've seen.", "Stressed, like anyone would be. Still the same person."]))
        }

        var pool: [(String, String)] = [
            ("You weren't there when this happened, were you?", "No."),
            ("You don't know what \(dl) does when you're not around?", "Nobody knows that about anybody. I know who I've seen."),
            ("Did you talk with \(dl)'s lawyer before testifying today?", "Once, to find out when to be here."),
            ("You haven't seen the evidence in this case?", "No. I can only tell you about the person I know.")
        ]
        if let prior = ctx.defendant.priors.last {
            pool.append(("Did you know \(dl) was convicted of \(prior.offense.lowercased()) in \(prior.year)?",
                         rng.pick(["I knew there was something years ago. People change.", "No, I didn't know that.", "I heard about it. That isn't the person I know."])))
        }
        if tie == .supervisor || tie == .formerBoss {
            pool.append(("If \(dl) were convicted, you'd lose a good worker. You have a stake in this.", "I'd lose a good worker. I'd still tell you the truth."))
        }
        switch ctx.setting {
        case .paper: pool.append(("You've never seen \(dl)'s bank records, have you?", "No. I've seen how \(dl) handles responsibility."))
        case .road: if ctx.facts.impaired { pool.append(("Have you ever seen \(dl) drink?", rng.pick(["At a cookout. A beer or two.", "Not much. I don't really socialize with \(dl) that way."]))) }
        case .drugs: pool.append(("You don't know who \(dl) spends evenings with, do you?", "Not every evening, no."))
        case .scene: if trait == "peacefulness" { pool.append(("You've never seen \(dl) angry?", "I've seen \(dl) frustrated. Never violent.")) }
        }
        for (q, a) in rng.pick(pool, count: rng.int(2...4)) { c(q, a) }
        if rng.chance(0.5) {
            ex.append(.init(phase: .redirect, examiner: .defense, question: "Does anything you heard on cross change your opinion?",
                            answer: rng.pick(["No.", "No. I know \(dl).", "No. I came here because I believe it."])))
        }
        return witness(name: name, role: role, side: .defense, exchanges: ex)
    }
}

// MARK: - The defendant

extension Testimony {

    /// What the defense says happened, sorted into the kind of story a defendant tells.
    enum DefenseTheme { case selfDefense, alibi, noKnowledge, approval, misidentification, accident, sober, general

        static func of(_ theory: String) -> DefenseTheme {
            let t = theory.lowercased()
            func has(_ words: [String]) -> Bool { words.contains { t.contains($0) } }
            if has(["self-defense", "defend", "afraid", "feared", "protect", "attacked first", "came at"]) { return .selfDefense }
            if has(["wasn't there", "alibi", "elsewhere", "across town", "at home", "at work", "in raleigh"]) { return .alibi }
            if has(["wrong person", "misidentif", "mistaken", "looks like", "someone else", "another person"]) { return .misidentification }
            if has(["didn't know", "no idea", "wasn't mine", "not mine", "unaware", "never knew", "belonged to"]) { return .noKnowledge }
            if has(["approved", "consent", "permission", "authorized", "advances", "allowed", "agreed"]) { return .approval }
            if has(["not impaired", "sober", "wasn't drunk", "fatigue", "tired", "two beers", "glare", "wasn't impaired"]) { return .sober }
            if has(["accident", "never meant", "unintentional", "fell", "rolled", "mistake"]) { return .accident }
            return .general
        }

        /// True when the defense can hardly be made without the defendant's own account.
        var needsTestimony: Bool { self != .general && self != .misidentification }
    }

    /// The defendant's own testimony, as a full examination.
    static func defendant(_ base: Witness, ctx: Context, holds: Bool, sessionDate: Date, rng: inout SeededRNG) -> [TestimonyExchange] {
        let s = ctx.sheet
        let dl = ctx.dl
        let theme = DefenseTheme.of(ctx.defenseTheory)
        let victim = ctx.victim
        let profile = ctx.defendant.profile
        var ex: [TestimonyExchange] = []
        func d(_ q: String, _ a: String) { ex.append(.init(phase: .direct, examiner: .defense, question: q, answer: a)) }
        func c(_ q: String, _ a: String) { ex.append(.init(phase: .cross, examiner: .prosecution, question: q, answer: a)) }
        func r(_ q: String, _ a: String) { ex.append(.init(phase: .redirect, examiner: .defense, question: q, answer: a)) }

        // Who
        let occupation = ctx.defendant.occupation.lowercased()
        let work: String
        if occupation.contains("unemployed") { work = "I'm between jobs right now." }
        else if occupation.hasPrefix("retired") { work = "I'm \(occupation)." }
        else if let job = profile?.jobs.first(where: { $0.current }) { work = "I work as \(withArticle(job.title.lowercased())) at \(job.employer)." }
        else { work = "I work as \(withArticle(occupation))." }
        d(rng.pick(["Please tell the court your name and a little about yourself.", "Tell the court about yourself.", "Who are you?"]),
          "\(base.name). I'm \(ctx.defendant.age). " + work + (profile.map { " " + $0.residence.replacingOccurrences(of: "Rents", with: "I rent").replacingOccurrences(of: "Lives", with: "I live").replacingOccurrences(of: "Owns", with: "I own").replacingOccurrences(of: "Has moved", with: "I've moved") } ?? ""))
        if let family = profile?.family, rng.chance(0.6) {
            d(rng.pick(["Tell the court about your family.", "Who's at home with you?"]),
              family.hasPrefix("Married") ? "I'm married." + (family.contains("child") ? " We have kids. They're why I'm fighting this." : "")
                : family.contains("child") ? "I have kids. Everything I do is for them." : rng.pick(["It's just me right now.", "I'm on my own. My family's nearby."]))
        }
        if let victim = victim, ctx.facts.mentions(["partner", "spouse", "ex-", "best friend", "neighbor", "coworker", "roommate", "boyfriend", "girlfriend", "husband", "wife"]) {
            d(rng.pick(["How do you know \(victim)?", "What was your relationship with \(victim)?"]),
              rng.pick(["We go back a long way. It's complicated, but I never wanted any of this.", "We were close, once. That's what makes this so hard."]))
        }

        // That day, from the fact sheet
        if ctx.setting == .paper {
            if let org = ctx.organization {
                d(rng.pick(["What was your role at \(org)?", "How did you come to work with \(org)?"]),
                  rng.pick(["I handled the books and the day-to-day money. For years nobody had a complaint.", "I did whatever needed doing. Some of it was paperwork I wasn't trained for."]))
            }
        } else {
            let whereLine: String
            switch theme {
            case .alibi: whereLine = rng.pick(["I was at home. My \(rng.pick(["partner", "sister", "roommate"])) was there.", "I was at work until close, then I drove straight home.", "Nowhere near \(s.place). I was across town."])
            case .misidentification: whereLine = rng.pick(["Not \(s.place). I've told everyone that from the start.", "I was out, but I wasn't there."])
            default: whereLine = rng.pick(["I was \(s.place), yes. I'm not going to deny that.", "I was there. I'll tell you exactly what happened.", "I was \(s.place), around \(s.time ?? "then")."])
            }
            d(rng.pick(["Take the court back to \(s.day). Where were you?", "Where were you on the \(Clock.partOfDay(s.time)) of \(s.day)?", "Let's talk about \(s.day). Where were you?"]), whereLine)
        }
        if let narrated = base.direct.first {
            d(rng.pick(["Tell the court what happened.", "In your own words, what happened?", "Walk the court through it."]), narrated)
        }
        for line in rng.pick(themeLines(theme, ctx: ctx, rng: &rng), count: rng.int(1...2)) {
            d(rng.pick(["What were you thinking at that point?", "What happened next?", "Why?", "What do you want the court to understand about that?"]), line)
        }
        if let top = ctx.strongest {
            d(rng.pick(["The State showed the court \(top.exhibit), the \(lower(top.title)). What do you say about that?", "Let's talk about the \(lower(top.title)).", "How do you explain the \(lower(top.title))?"]),
              holds ? rng.pick(["I'm not going to pretend it isn't there. But it doesn't mean what they say it means.", "I can explain it, and I did explain it, to anyone who would listen.", "It looks bad on paper. Here's what it doesn't show: the rest of that day."])
                    : rng.pick(["I don't know how to explain that.", "I've thought about that a lot. I can't explain it.", "I don't know. I just know I didn't do this."]))
        }
        if let day = s.interview {
            d(rng.pick(["Did you talk to the police?", "Did you speak with investigators?"]), "I did, on \(CaseDates.day(day)). I told them the truth, without a lawyer, because I had nothing to hide.")
        } else {
            d(rng.pick(["Did you talk to the police?", "Why didn't you give a statement?"]), rng.pick(["My lawyer told me not to, so I didn't.", "I asked for a lawyer. I was scared, and I'd been told that's what you do."]))
        }
        d(rng.pick(["Did you do what you're charged with?", "Did you commit this crime?"]),
          theme == .accident || theme == .sober ? "Not the way they say it. I'm sorry for what happened. I didn't commit a crime." : rng.pick(["No.", "No, Your Honor.", "No. I didn't."]))
        if base.direct.count > 1 {
            d(rng.pick(["Why did you decide to testify?", "Is there anything else you want the court to know?"]), base.direct[1])
        }

        // Cross: the prosecutor presses the evidence
        let months = max(1, CaseDates.days(from: s.arrest, to: sessionDate) / 30)
        var pool: [(String, String)] = [
            ("You've had \(months) months to think about this story, haven't you?", holds ? "I've had \(months) months to think about the truth. It hasn't changed." : "That's not fair. I'm telling you what I remember."),
            ("You'd say whatever you needed to say to walk out of here today?", holds ? "I'd tell the truth. That's all I've got." : "...No. I'm not lying.")
        ]
        let byWeight = ctx.state.sorted { $0.weight > $1.weight }
        for item in byWeight.prefix(2) {
            pool.append(("Explain \(item.exhibit), then. \(item.detail)",
                         holds ? rng.pick(["I can. It's not what it looks like, and I told my lawyer the same thing the day I saw it.", "There's an innocent reason for that, and I've given it.", "I explained that already. Nothing about it changes."])
                               : rng.pick(["I... I don't know how to explain that.", "I can't. I wish I could.", "I don't remember it that way."])))
        }
        if let day = s.interview {
            pool.append(("When you spoke to \(s.lead) on \(CaseDates.day(day)), you didn't say any of this, did you?",
                         holds ? "I said the same thing. Read the transcript." : "I was nervous. I didn't say it right."))
        }
        let impeachable = ctx.defendant.priors.filter { $0.ncClass.isFelony || $0.ncClass == .misdA1 || $0.ncClass == .misd1 }
        if let prior = impeachable.last {
            pool.append(("You were convicted of \(prior.offense.lowercased()) in \(prior.year), weren't you?", rng.pick(["Yes. I did my time for that.", "Yes. That was a long time ago.", "Yes. I'm not hiding it."])))
        }
        switch ctx.setting {
        case .paper: pool.append(("You were behind on your own bills that year, weren't you?", holds ? "Some months. Lots of people are." : "...Yes."))
        case .drugs: pool.append(("Where did the cash come from?", holds ? "Work. I don't trust banks." : "...Some of it was from work."))
        case .road: if ctx.facts.impaired { pool.append(("How many drinks did you have that night?", holds ? "Two. With dinner, hours before." : "A few. I don't remember exactly.")) }
        case .scene:
            if let victim = victim, theme == .selfDefense { pool.append(("\(victim) never touched a weapon, did they?", holds ? "I didn't know that then. I saw a hand go to a pocket." : "...I thought I saw something.")) }
            else if let victim = victim { pool.append(("You were angry at \(victim), weren't you?", holds ? "I was upset. I wasn't going to hurt anybody." : "...I was angry, yes.")) }
        }
        for (q, a) in rng.pick(pool, count: rng.int(4...5)) { c(q, a) }
        for line in base.cross { c("", line) }

        // Redirect
        let redirect: [(String, String)] = [
            ("Have you told the court the truth today?", holds ? "Yes. Every word." : "Yes. As best I can remember."),
            ("Why did you choose to testify, when you didn't have to?", "Because I wanted you to hear it from me."),
            ("Is there anything about your account that has changed since \(s.day)?", holds ? "No." : "Only the parts I couldn't remember at first.")
        ]
        for (q, a) in rng.pick(redirect, count: rng.int(1...2)) { r(q, a) }
        return ex
    }

    private static func themeLines(_ theme: DefenseTheme, ctx: Context, rng: inout SeededRNG) -> [String] {
        let v = ctx.victim ?? "they"
        switch theme {
        case .selfDefense:
            return ["\(v.capitalizedFirst) came at me. I backed up until I couldn't back up anymore.", "I was scared for my life. I've never been that scared.",
                    "I only did what I had to do to get away. The second I could stop, I stopped."]
        case .alibi:
            return ["I can tell you exactly where I was, and it wasn't \(ctx.sheet.place).", "I didn't even hear about it until the next day, when the police called.",
                    "There are people who saw me. I gave my lawyer their names."]
        case .noKnowledge:
            return ["I didn't know it was there. That's the truth.", "If I'd known, I'd never have let it near my \(ctx.facts.origin == .warrant ? "house" : "car").",
                    "Other people used that \(ctx.facts.origin == .warrant ? "house" : "car"). I wasn't the only one with a key."]
        case .approval:
            return ["Everything I did, somebody above me knew about. Nobody hid anything.", "I was told it was fine. I kept whatever paperwork I could.",
                    "If I'd thought it was wrong, why would I have put my own name on it?"]
        case .misidentification:
            return ["They have the wrong person. I know what the pictures look like. That isn't me.", "Lots of people around here look like me and dress like me."]
        case .accident:
            return ["It was an accident. I'd give anything to take it back.", "I never meant for anyone to get hurt. I think about it every day.", "It happened so fast. I've gone over it a thousand times."]
        case .sober:
            return ["I'd had two beers with dinner, hours before. I wasn't impaired.", "I'd worked a double shift. I was exhausted, and that's what they saw.",
                    "I did their tests on the side of the road at night with cars going by. I'd like to see anyone do them perfectly."]
        case .general:
            return ["I didn't do what they're saying.", "It didn't happen the way the State says. Not even close.", "I've never been in trouble like this. I don't know how I ended up here."]
        }
    }
}
