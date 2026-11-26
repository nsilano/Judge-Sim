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
    /// Whether a witness's job puts them in the books: an employee, bookkeeper, manager, and so on.
    static func handlesRecords(_ role: String) -> Bool {
        let r = role.lowercased()
        return ["coworker", "co-worker", "bookkeeper", "accountant", "manager", "cashier", "clerk", "employee", "teller", "auditor",
                "treasurer", "board member", "office", "payroll", "finance", "owner", "partner", "supervisor", "crew"].contains { r.contains($0) }
    }

    /// The answer to "How do you know the defendant?": the relationship, not a number of years.
    static func howTheyKnow(_ role: String, dl: String, years: Int, rng: inout SeededRNG) -> String {
        let r = role.lowercased()
        // Someone else's neighbor, friend, or relative knows the defendant through that person.
        if let range = role.range(of: "'s "), !role[..<range.lowerBound].contains(dl) {
            let through = String(role[..<range.lowerBound])
            return Variety.pick(["Through \(through). I'd see \(dl) over there all the time.", "From \(through)'s. \(dl) was around most days.",
                             "Only through \(through). We'd talk in the yard sometimes.", "Through \(through). I'd run into \(dl) at their place a couple of times a month.", "I know \(dl) through \(through). We've sat at the same cookouts for years.", "Mostly through \(through). \(dl) and I would nod and talk a minute when we crossed paths.", "Through \(through). I was around when \(dl) came by, so we got to know each other.", "That's how I met \(dl), through \(through). We've kept running into each other since.", "Only because of \(through). I'd see \(dl) at get-togethers and we'd chat."], rng: &rng)
        }
        if r.contains("neighbor") { return rng.pick(["We live on the same street. Have for about \(years) years.", "I live next door. \(years) years now.", "We're neighbors. My house is three doors down, and it's been about \(years) years.", "I live across the road. We've been neighbors for \(years) years or so.", "Our driveways almost touch. I've lived there about \(years) years.", "Same block, \(years) years. We see each other over the fence all the time.", "I'm right around the corner. \(years) years of waving from the mailbox.", "We share a property line. I've lived beside \(dl) for about \(years) years."]) }
        if r.contains("coworker") || r.contains("crew") || r.contains("employee") || r.contains("cashier") {
            return rng.pick(["We worked together. About \(years) years.", "Same job, same shift, for a long time.", "We were on the same crew for a long time. I'd say \(years) years.", "I worked alongside \(dl) day in and day out. It was about \(years) years.", "We clocked in together most mornings. I'd guess \(years) years.", "We worked the same floor. I got to know \(dl) well over \(years) years or so.", "We had the same supervisor and the same hours for years. Maybe \(years) years, all told.", "We worked side by side. I couldn't tell you the exact date we met, but it's been about \(years) years."])
        }
        if r.contains("pastor") { return "\(dl) has been in my congregation about \(years) years." }
        if r.contains("landlord") { return "\(dl) rents from me. Has for \(years) years." }
        if r.contains("roommate") { return "We've shared an apartment for about \(years) years." }
        for family in ["cousin", "spouse", "sibling", "mother", "father", "daughter", "son", "partner", "wife", "husband", "sister", "brother", "aunt", "uncle", "grandmother"]
        where r.contains(family) {
            return "\(dl) is family. I'm \(dl)'s \(family)."
        }
        if r.contains("friend") { return rng.pick(["We've been friends about \(years) years.", "Since high school. We've been friends a long time.", "We're close friends. I'd say \(years) years now.", "We met through church and we've stayed friends for about \(years) years.", "We grew up a few miles apart. We've been friends \(years) years or more.", "We've been friends since we met on a job, about \(years) years back.", "We've been through a lot together. \(years) years of friendship, give or take.", "We go back about \(years) years. I'd call \(dl) a real friend."]) }
        return "We've known each other about \(years) years."
    }

    static func withArticle(_ role: String) -> String {
        let lower = role.prefix(1).lowercased() + role.dropFirst()
        // "Adeyemi's neighbor" starts with a name: no article, and the name keeps its capital.
        if role.contains("'s ") { return role }
        if role.lowercased().hasPrefix("the ") { return lower }
        // By sound: "a use-of-force expert", "a uniformed officer", "an hour".
        let vowelLetter = "aeiou".contains(lower.prefix(1)) && !["use", "uni", "eu", "one"].contains { lower.hasPrefix($0) }
        let vowel = vowelLetter || ["hour", "honest", "honor"].contains { lower.hasPrefix($0) }
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
        // The first sentence, without breaking on an initial ("an R. Smith") or a title ("Dr. Hale").
        var searchFrom = s.startIndex
        while let end = s.range(of: ". ", range: searchFrom..<s.endIndex) {
            let before = s[..<end.lowerBound].split(separator: " ").last.map(String.init) ?? ""
            if (before.count == 1 && before.uppercased() == before) || ["Mr", "Mrs", "Ms", "Dr", "St", "Jr", "Sr"].contains(before) {
                searchFrom = end.upperBound
                continue
            }
            s = String(s[..<end.lowerBound])
            break
        }
        // A line that already says "you" can't be turned around without garbling it.
        if s.lowercased().regexRange(of: "\\byou(r|'re|'ve|'d|'ll)?\\b", options: .regularExpression) != nil { return nil }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: ".! "))
        for suffix in [", yes", ", no", ", sure", ", I guess"] where s.lowercased().hasSuffix(suffix) {
            s = String(s.dropLast(suffix.count))
        }
        let swap: [String: String] = ["i": "you", "i'm": "you're", "i've": "you've", "i'd": "you'd", "i'll": "you'll", "me": "you",
                                      "my": "your", "mine": "yours", "myself": "yourself", "we": "you", "we're": "you're",
                                      "we've": "you've", "we'd": "you'd", "we'll": "you'll", "our": "your", "us": "you", "am": "are",
                                      "ourselves": "yourselves"]
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
        if let first = sentence.split(separator: " ").first,
           common.contains(first.lowercased()) || common.contains(String(first.lowercased().split(separator: "'").first ?? "")) {
            sentence = sentence.prefix(1).lowercased() + sentence.dropFirst()
        }
        return Variety.pick(["Isn't it true that \(sentence)?", "You'd agree that \(sentence)?", "So \(sentence)?",
                         "Let me make sure the court has this: \(sentence)?", "Fair to say \(sentence)?", "Isn't it a fact that \(sentence)?", "Would it be fair to say \(sentence)?", "Is it correct that \(sentence)?", "Do you agree that \(sentence)?", "Am I right that \(sentence)?", "Correct me if I'm wrong, but \(sentence)?"], rng: &rng)
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
            ask(.direct, Variety.pick(["Please state your name and your position.", "Tell the court who you are and what you do.",
                                   "State your name and occupation for the record, please.", "Would you state your name and your line of work for the record?", "Who are you, and what is your job?", "Please introduce yourself to the court and tell us what you do.", "For the record, your name and your position?", "Tell us your name and what you do for a living.", "Please identify yourself and describe your work."], rng: &rng),
                "\(w.name). I'm \(withArticle(w.role)).")
            if kind == .expert {
                let n = rng.int(6...24)
                ask(.direct, Variety.pick(["What are your qualifications?", "Tell the court about your training and experience.", "How long have you worked in this field?", "What is your educational background?", "Describe your credentials for the court.", "What training have you had in this area?", "How many years have you practiced, and what certifications do you hold?", "What's your professional background?", "How did you come to work in this field?"], rng: &rng),
                    Variety.pick(["\(n) years in the field. I've reviewed hundreds of cases and testified as an expert \(rng.int(4...40)) times, for the State and for the defense.",
                              "A graduate degree in the field and \(n) years of practice. I keep my certifications current and I teach continuing-education courses.",
                              "\(n) years. I've been qualified as an expert in North Carolina courts before, and I've published on this subject.", "I hold a graduate degree in the field, and I've spent \(n) years applying it. I attend training every year to stay current.", "\(n) years of practice. I've been certified in my specialty since early in my career and recertified several times since.", "I trained under senior practitioners and then worked on my own for \(n) years. I've taught other professionals how to do this work.", "\(n) years. I've given talks at regional conferences, and North Carolina courts have accepted me as an expert before.", "I've done this work for \(n) years. I have the degree, the certifications, and a long list of cases behind me.", "\(n) years in this field, with continuing training every year and regular peer review of my work."], rng: &rng))
                if rng.chance(0.5) {
                    ask(.direct, "Your Honor, we tender \(w.name) as an expert in the field.",
                        "The Court: " + rng.pick(["Without objection, the court accepts the witness as an expert.", "The other side has no objection. The witness is accepted as an expert.", "Hearing no objection, the witness may testify as an expert.", "The court recognizes the witness as an expert in the field and will allow opinion testimony.", "No objection from opposing counsel. The witness is qualified and may give opinions within the field.", "The court finds the witness qualified and will receive the testimony as expert opinion.", "Very well. The witness is accepted as an expert. You may proceed.", "There being no objection, the court accepts the witness as an expert."]))
                }
            } else {
                let n = rng.int(4...22)
                ask(.direct, Variety.pick(["How long have you done that work?", "How long have you been in that position?", "What's your experience?", "How many years have you held this job?", "Tell the court how long you've been doing this.", "How much experience do you have in this role?", "How long have you been assigned to this kind of work?", "When did you start in this line of work?", "How long have you been at it?"], rng: &rng),
                    Variety.pick(["\(n) years.", "\(n) years, the last \(max(1, n / 3)) in this assignment.", "About \(n) years. Before that, \(rng.int(2...6)) years in uniform.", "I've been at it \(n) years now.", "Roughly \(n) years, and I've handled this kind of matter many times.", "\(n) years. I started out on the ground and worked my way into this assignment.", "It's been \(n) years. I've seen most situations at least once.", "A little over \(n) years.", "\(n) years, with training every year since I started."], rng: &rng))
            }
        case .lay:
            let intro = Variety.pick(["Please tell the court your name and how you're connected to this case.", "Would you introduce yourself to the court?",
                                  "Tell us who you are and how you came to be involved.", "State your name for the record and tell the court how you know about this case.", "Please introduce yourself and explain why you're here today.", "Who are you, and how did you come to be a witness in this matter?", "Tell the court your name and your connection to what happened.", "Would you tell us your name and what brings you here today?", "For the record, please state your name and how you got involved."], rng: &rng)
            let answer: String
            if isVictim {
                answer = rng.pick(["\(w.name). I'm the one this happened to.", "\(w.name). " + (role == "victim" || role == "complainant" ? "I'm the one who reported it." : "I'm \(withArticle(w.role))."),
                                   "\(w.name). I'm \(withArticle(w.role)). This happened to me.", "\(w.name). I'm here because it happened to me.", "\(w.name). I'm \(withArticle(w.role)), and I was there when it happened.", "\(w.name). It happened to me, and I'm here to tell you about it.", "\(w.name). I'm \(withArticle(w.role)). I was directly affected by what happened.", "\(w.name). I was the person it was done to.", "\(w.name). I'm \(withArticle(w.role)), and I lived through this."])
            } else {
                answer = "\(w.name). I'm \(withArticle(w.role))."
            }
            ask(.direct, intro, answer)
            let relation = ["'s ", "friend", "cousin", "spouse", "roommate", "neighbor", "pastor", "landlord", "sibling", "mother",
                            "father", "coworker", "crew", "board member", "daughter", "son", "partner", "former cashier"]
            if relation.contains(where: { role.contains($0) }) {
                let years = rng.int(2...20)
                if rng.chance(0.5) {
                    if rng.chance(0.5) {
                        ask(.direct, "How long have you known \(dl)?",
                            Variety.pick(["About \(years) years.", "\(years) years, give or take.", "Going on \(years) years.", "Roughly \(years) years now.", "It's been \(years) years or so.", "I'd say \(years) years, maybe a little more.", "A good \(years) years.", "Right at \(years) years, I think.", "Over \(years) years now."], rng: &rng))
                    } else {
                        ask(.direct, "How well do you know \(dl)?",
                            Variety.pick(["Well. About \(years) years now.", "Well enough. \(years) years, give or take.", "As well as anybody, I'd say. Going on \(years) years.", "Pretty well. We've known each other \(years) years.", "Very well. It's been \(years) years or so.", "Well enough to speak to it. About \(years) years of knowing each other.", "Better than most, after \(years) years.", "Well. I've known \(dl) for \(years) years, through good times and bad.", "Quite well, after about \(years) years."], rng: &rng))
                    }
                } else {
                    ask(.direct, "How do you know \(dl)?", howTheyKnow(w.role, dl: dl, years: years, rng: &rng))
                }
            }
            if paper && !isVictim, let org = ctx.organization, rng.chance(0.6) {
                ask(.direct, rng.pick(["What's your connection to \(org)?", "How long were you involved with \(org)?", "How are you associated with \(org)?", "How are you involved with \(org)?", "Tell the court how you know \(org).", "How long have you been connected with \(org)?", "What is your history with \(org)?", "What's your relationship to \(org)?"]),
                    rng.pick(["I've been there \(rng.int(2...14)) years.", "About \(rng.int(2...14)) years. I know how the place runs, and I know the people.", "Around \(rng.int(2...14)) years. I've seen how it runs day to day.", "I've been connected to it for \(rng.int(2...14)) years, give or take.", "\(rng.int(2...14)) years now. I know the routine and the people involved.", "About \(rng.int(2...14)) years. I've watched how the place handles its business.", "Going on \(rng.int(2...14)) years. I've seen most of how it operates.", "It's been \(rng.int(2...14)) years or so, and I've paid attention the whole time."]))
            }
            // Where the witness was, from the fact sheet
            if eyewitness, let time = ctx.sheet.time {
                let said = timingSlip ? Clock.shift(time, by: rng.pick([-35, -25, -20, 20, 25, 35])) : time
                ask(.direct, Variety.pick(["Take the court back to \(ctx.sheet.day). Where were you?", "Where were you on the \(Clock.partOfDay(time)) of \(ctx.sheet.day)?",
                                       "Let's go to \(ctx.sheet.day). What brought you there?", "Let's go back to \(ctx.sheet.day). Where were you when this began?", "Where were you on \(ctx.sheet.day)?", "Tell the court where you were on the \(Clock.partOfDay(time)) of \(ctx.sheet.day).", "What were you doing on \(ctx.sheet.day), and where?", "Focus on \(ctx.sheet.day) for me. Where were you?", "How did you come to be there on \(ctx.sheet.day)?"], rng: &rng),
                    Variety.pick(["I was \(ctx.sheet.place). It was about \(said).", "\(ctx.sheet.place.capitalizedFirst). I remember it was around \(said), because I'd just checked my phone.",
                              "I was right there, \(ctx.sheet.place). Around \(said), I'd say.", "I was \(ctx.sheet.place). It was right around \(said).", "\(ctx.sheet.place.capitalizedFirst). I know it was close to \(said) because I remember glancing at the time.", "I was there, \(ctx.sheet.place). It was about \(said), give or take a few minutes.", "\(ctx.sheet.place.capitalizedFirst), at about \(said). I'd been there a little while.", "I was \(ctx.sheet.place) around \(said). I remember because of what happened next.", "\(ctx.sheet.place.capitalizedFirst). It was roughly \(said), as best I can recall."], rng: &rng))
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
            ask(.direct, Variety.pick(["Did you document that at the time?", "Is that in your report?", "Were your findings written up?", "Did you put that in writing?", "Is that documented anywhere?", "Did you make a record of your work?", "Did you write up what you found?", "Is there a report covering that?", "Was any of that recorded in your notes or a report?"], rng: &rng),
                Variety.pick(["Yes. It's in my report, written within a day or two.", "Yes, with the supporting \(paper ? "records" : "photographs") attached.", "Yes. My report was finished on \(CaseDates.day(CaseDates.add(rng.int(1...6), to: ctx.sheet.assigned))).", "Yes. I took notes as I went and wrote the report from them.", "Yes. I documented it the same day and filed it with the case.", "Yes. I write everything up while it's fresh, and this was no exception.", "Yes. It was documented, and a supervisor reviewed the report afterward.", "Yes. My notes are in the case file, and the full report followed within the week.", "Yes. Every step is in the file, in the order that it happened."], rng: &rng))
        case .expert:
            let (q, a) = rng.pick([
                ("How confident are you in that opinion?", "Confident. I'd reach the same conclusion if I did it again tomorrow."),
                ("Do you hold that opinion to a reasonable degree of certainty in your field?", "Yes, to a reasonable degree of scientific certainty."),
                ("Was your work reviewed by anyone else?", "Yes. A second qualified examiner reviewed my notes and conclusions before the report went out."),
                ("Did anything about this work fall outside your normal procedures?", "No. It was handled under our standard protocols, start to finish.")])
            ask(.direct, q, a)
        case .lay:
            if eyewitness || (isVictim && !paper) {
                switch rng.int(0...2) {
                case 0:
                    ask(.direct, "How sure are you about what you've told the court?",
                        w.weight >= 3 ? rng.pick(["Completely sure.", "Completely. I was right there.", "Absolutely sure. I'd stake my word on it.", "One hundred percent. I know what I saw.", "Completely sure. It's not something I'd forget.", "Yes, completely. I've gone over it in my head and it doesn't change.", "As sure as I've ever been about anything.", "Totally sure. I was standing right there."])
                            : w.weight >= 2 ? rng.pick(["I'm sure.", "I'm sure about what I've told you.", "I'm quite sure about it.", "Sure enough to swear to it.", "I'm confident in what I've said.", "I'm sure of the main things, and I've told you those.", "I believe so. I wouldn't have said it otherwise.", "Sure. I've told you only what I know."])
                            : rng.pick(["Pretty sure. It's what I remember.", "As sure as I can be. It happened fast.", "Fairly sure, though it all happened quickly.", "As sure as anyone can be after that long.", "I'm reasonably sure. Some of the small details I couldn't swear to.", "Pretty sure about the main part, less about the rest.", "I think I'm right. It was over before I could take it all in.", "Mostly sure. I've told you what stuck with me."]))
                case 1:
                    ask(.direct, "Is there any doubt in your mind about what you saw?",
                        w.weight >= 3 ? rng.pick(["No doubt at all. I was right there.", "None.", "No. I'd say the same thing again.", "None. I saw it with my own eyes.", "No doubt whatsoever.", "Not a bit. I've never wavered on it.", "No. It's burned into my memory.", "None at all about what happened."])
                            : w.weight >= 2 ? rng.pick(["No. I know what I saw.", "Not about what I've told you.", "No, not about the main points.", "Not that I can think of.", "No. I'd tell you if I had any.", "Very little. I know what I saw.", "No, I don't think so.", "Not about what I've told the court today."])
                            : rng.pick(["Some, maybe. It happened fast.", "Not about the main part.", "A little, about the small details.", "Some, honestly. It was a stressful moment.", "Not about the main part, but I can't swear to every detail.", "There's some doubt on the edges, I'll admit.", "A bit, about the order things happened in.", "I have a little, and I'm not going to pretend otherwise."]))
                default:
                    ask(.direct, "How clearly could you see?",
                        w.weight >= 3 ? rng.pick(["Clearly. I wasn't more than a few feet away.", "Very clearly. Nothing was in the way.", "Perfectly clearly. The light was good and I had a straight view.", "Very clearly. I was close and I was looking right at it.", "Clear as day. Nothing was between us.", "As clearly as I'm seeing you now.", "Clearly. I had no reason to look away.", "I could see everything. I was paying attention the whole time."])
                            : w.weight >= 2 ? rng.pick(["Clear enough.", "Well enough to tell you what I told you.", "Pretty clearly.", "Good enough to be certain about the main things.", "I had a decent view the whole time.", "Fairly well. I wasn't far away.", "Well enough. Nothing blocked my view for long.", "Clear enough that I'm comfortable with what I said."])
                            : rng.pick(["Not perfectly. I saw enough.", "Well enough, I think. It happened fast.", "Not as well as I'd like, but I saw the important part.", "Partly. Some of it was at an angle.", "It was a quick look, but I saw what I saw.", "Not perfectly. There was a lot going on.", "Fair, though people were moving around.", "Well enough to know what happened, if not every detail."]))
                }
            } else if paper {
                if rng.chance(0.5) {
                    ask(.direct, "Is that from your own knowledge?",
                        Self.handlesRecords(role)
                            ? rng.pick(["Yes. I saw the records myself.", "Yes. I worked with those records every day.", "Yes. Handling those records is part of my job.", "Yes. I've looked at those same records many times.", "Yes. I keep them, so I know what's in them.", "Yes. I personally reviewed them, not a summary.", "Yes. Nobody described them to me. I handled them.", "Yes. They pass through my hands regularly."])
                            : rng.pick(["Yes. I saw it myself. I was over there most days.", "Yes. I'm not repeating what somebody told me.", "Yes. I was there and saw it firsthand.", "Yes. This is what I've seen with my own eyes.", "Yes. I'm telling you what I lived, not what I heard.", "Yes. I was around often enough to know.", "Yes. Nobody had to tell me. I was there.", "Yes. I saw it happen over time, not just once."]))
                } else {
                    ask(.direct, "How do you know that?",
                        Self.handlesRecords(role)
                            ? Variety.pick(["I saw the records myself.", "I worked with those records every day.", "I was there for it. I'm not repeating what somebody told me.", "Handling them was part of my job, so I know them well.", "I reviewed them personally when they came in.", "I kept those records and looked at them regularly.", "I've been through those files more than once myself.", "It was my job to keep track of them.", "Nobody described them to me. I handled them."], rng: &rng)
                            : Variety.pick(["I saw it myself. I was over there most days.", "I was there. I'm not repeating what somebody told me.",
                                        "From being around them. I saw how they were with each other.", "I was around often enough to see it myself.", "I saw it firsthand, more than once.", "I was in the room for a lot of it. I'm not guessing.", "I know it from being there, not from other people's stories.", "I was close enough to see how things worked day to day.", "Over the years I watched it happen myself."], rng: &rng))
                }
            } else if calling == .defense {
                if rng.chance(0.5) {
                    ask(.direct, "Why did you come to court today?",
                        rng.pick(["Because I know what's true, and somebody should say it.", "Because \(dl) asked, and because it's true.", "Because I couldn't stay quiet knowing what I know.", "Because I was asked, and I owe it to \(dl) to tell the truth.", "Because the court should hear from somebody who was there.", "Because I think there's more to this than has been said.", "Because I care what happens here, and I'm telling the truth.", "Because I've known \(dl) long enough to speak to it."]))
                } else {
                    ask(.direct, "Has anyone told you what to say today?",
                        rng.pick(["No. Nobody told me what to say. I'm here because it's true.", "No. \(dl)'s lawyer asked me to tell the truth, and that's what I'm doing.", "No. They only asked me to be honest.", "No. I was told to answer what I'm asked and tell the truth.", "No. I've said what I remember, in my own words.", "No. Nobody has put words in my mouth.", "No. I met with \(dl)'s lawyer once, and all I was asked was to tell the truth.", "No. Nobody scripted this. It's what I know."]))
                }
            }
        }

        // Cross
        var openers: [(String, String)] = []
        switch kind {
        case .investigator:
            openers = [("You never personally saw \(dl) commit any crime, did you?", "No. I came in afterward, like investigators do."),
                       ("Your report doesn't cover everything, does it?", "A report covers what matters. It doesn't cover every minute."),
                       ("You wrote your report after \(dl) was already charged?", "The final version, yes. My notes were made as I went."),
                       ("You didn't record every interview you did?", rng.pick(["Not the short ones at the scene. The formal interviews were recorded.", "No. Some were brief conversations; I summarized those in my notes.", "No. Where it was just a few questions at the scene, I wrote notes afterward.", "Not every one. The ones that mattered most were recorded.", "Some, no. Short follow-up calls I documented in the file instead.", "No. Informal conversations aren't recorded. The formal interviews were.", "Not all of them. My notes cover the ones that weren't.", "No, but every contact is written up in the case file."]))]
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
                    : [("You and \(dl) are friends?", Self.handlesRecords(role) ? "We worked together a long time. That doesn't change what I saw."
                                                                               : "I'd say so. That doesn't change what I saw."),
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
                           ("You'd like to see \(dl) go home today?", "Of course I would. That doesn't make it any less true.")]
            }
        }
        for (q, a) in rng.pick(openers, count: rng.int(1...2)) { ask(.cross, q, a) }
        if timingSlip, let time = ctx.sheet.time {
            ask(.cross, ctx.facts.origin == .call
                    ? rng.pick(["You told the court this happened around a different time than the 911 call shows. The call came in at \(time), didn't it?",
                                "The records put this at \(time). That's not what you just told the court, is it?", "The 911 call is time-stamped \(time). That doesn't match the time you just gave, does it?", "Dispatch logged the call at \(time). That's not the time you gave the court, is it?", "The recording shows the call coming in at \(time). A moment ago you gave a different time, didn't you?", "You gave one time on direct. The 911 log says \(time), correct?", "Isn't it true the call came in at \(time), and not when you said?", "The dispatch record has \(time). Your time was different, wasn't it?"])
                    : "The records put this at \(time). That's not what you just told the court, is it?",
                Variety.pick(["Then I'm off on the time. I'm not off on what I saw.", "...I may have the time wrong. I wasn't looking at a clock.", "If that's what the records say. It felt later to me.", "Maybe I've got the time wrong. I haven't got the events wrong.", "I wasn't watching the clock. If the record says that, I'll accept it.", "Then my memory of the hour is off. What happened, I remember.", "I can't argue with a timestamp. I can tell you what I saw.", "That could be. Time gets away from you in a moment like that.", "If that's what's logged, then I was wrong about the time, not about the rest."], rng: &rng))
        }
        let narrated = impeachment == nil ? w.cross : Array(w.cross.dropLast())
        for line in narrated {
            let quoted = line.hasPrefix("\"") || line.hasPrefix("\u{201C}")
            ask(.cross, quoted ? (leadingQuestion(from: line, rng: &rng) ?? rng.pick(["One more thing.", "Let me ask you about something else.", "Let me ask you about that.", "Now, about something you said.", "I want to go back to something.", "Help me understand one thing.", "Let's talk about something else you mentioned.", "One more question, if I may."])) : "", line)
        }
        if let imp = impeachment { ask(.cross, imp.0, imp.1) }

        // Redirect
        ask(.redirect, Variety.pick(["Does anything you were asked on cross change what you told the court?",
                                 "Having heard those questions, is your testimony any different?",
                                 "Did any of those questions change your account?", "After those questions, is there anything you'd like to change in what you said?", "Do you stand by what you told the court on direct?", "Did anything on cross make you doubt your testimony?", "Having been questioned by the other side, is your account the same?", "Is what you told us earlier still your testimony?", "Do those questions alter what you remember?"], rng: &rng),
            w.weight >= 2 ? Variety.pick(["No. It doesn't.", "No. What I told you is what happened.", "Nothing changes. I'd say it all again.", "No. I'd tell it the same way again.", "No. I've told you what I know and it hasn't changed.", "Not at all. My account is the same.", "No. Those questions don't change what happened.", "No. I stand by every word.", "No. If anything, I'm more sure after going through it again."], rng: &rng)
                          : Variety.pick(["It doesn't change what I remember. I understand why they asked.", "No. Some of it I'm less sure of, and I've said so.", "Not the important part.", "Some details I'm less sure of, but the heart of it stands.", "I understand the questions, but they don't change what I remember.", "Mostly the same. I've been honest about what I'm not sure of.", "No. I've told you what I know and where I'm unsure.", "The core of it is the same. The edges are fuzzy, and I've said so.", "It doesn't change what I saw, only how sure I am of the small things."], rng: &rng))
        return out
    }

    /// The defendant's own account of their family, read from the profile so it never says otherwise.
    static func familyAnswer(_ p: DefendantProfile, rng: inout SeededRNG) -> String {
        let kids = p.childCount
        let numbers = ["", "one", "two", "three", "four", "five", "six"]
        let count = kids < numbers.count ? numbers[kids] : "\(kids)"
        let children = kids == 1 ? "a child" : "\(count) kids"
        var answer: String
        if p.married { answer = "I'm married." }
        else if p.status.hasPrefix("Engaged") { answer = "I'm engaged." }
        else if p.partnered { answer = "I've been with my partner a long time." }
        else if p.status.hasPrefix("Divorced") { answer = "I'm divorced." }
        else if p.status.hasPrefix("Separated") { answer = "I'm separated." }
        else if p.status.hasPrefix("Widowed") { answer = "I lost my spouse." }
        else { answer = kids > 0 || p.raisesOthers ? "I'm single." : rng.pick(["It's just me right now.", "I'm on my own. My family's nearby.", "I live alone. I see my family when I can.", "No partner right now. I keep to myself mostly.", "I'm on my own, and I'm fine with it.", "There's nobody at home but me right now.", "I'm not seeing anyone. My family is what I have.", "Just me. I've got relatives close by, though."]) }
        if kids > 0 {
            answer += " I have \(children). " + (kids == 1 ? rng.pick(["Everything I do is for my child.", "My child is why I'm fighting this.", "My child depends on me every day.", "I need to be there for my child, and that's what this is about.", "I can't lose time with my child over this.", "My child is the reason I get up in the morning.", "I'm doing this for my child's sake.", "My child needs me home."])
                                                            : rng.pick(["Everything I do is for them.", "They're why I'm fighting this.", "They depend on me every day.", "I need to be there for them, and that's what this is about.", "I can't lose time with them over this.", "They're the reason I get up in the morning.", "I'm doing this for their sake.", "They need me home."]))
        } else if p.raisesOthers {
            answer += p.family.contains("Foster parent") ? " I'm a foster parent to two teenagers." : " I'm raising my niece and nephew."
        } else if p.married || p.partnered {
            answer += " No children."
        }
        return answer
    }

    // MARK: Shared pieces

    private static func lower(_ s: String) -> String { s.prefix(1).lowercased() + s.dropFirst() }

    /// How an exhibit came to the investigation, consistent with the fact sheet.
    private static func howObtained(_ item: Evidence, ctx: Context, rng: inout SeededRNG) -> String {
        let s = ctx.sheet
        switch item.kind {
        case .physical:
            switch ctx.facts.origin {
            case .stop: return rng.pick(["It was recovered from the vehicle at the stop on \(s.day) and logged that night.", "It came out of the car during the stop, photographed where it lay, then bagged and sealed.", "It was found inside the vehicle during the stop on \(s.day). I photographed it, tagged it, and logged it that night.", "We located it in the car on \(s.day), documented where it was, and packaged it right there.", "It was taken from the vehicle at the roadside on \(s.day) and entered into evidence before the end of the shift.", "During the stop on \(s.day), it was found in the car. Its location was recorded, and then it was sealed in an evidence bag.", "It came from the vehicle on \(s.day). Photographs were taken first, then it was collected and labeled.", "It was in the car at the time of the stop on \(s.day). It was photographed, bagged, and turned in that night."])
            case .warrant: return rng.pick(["It was seized when the warrant was served on \(s.day).", "The search team found it on \(s.day); it was photographed in place before anyone moved it.", "It was found during the search on \(s.day), photographed where it sat, and logged on the inventory sheet.", "When the warrant was executed on \(s.day), the search team located it and recorded its position before collecting it.", "It was recovered on \(s.day) when we served the warrant. It was photographed, bagged, and listed on the return.", "The team found it during the search on \(s.day) and noted the room and the spot where it was.", "It was seized under the warrant on \(s.day), with each step documented on the inventory.", "Officers located it while executing the warrant on \(s.day) and photographed it before it was touched."])
            case .records: return "It was collected during the investigation and logged into evidence."
            default: return rng.pick(["It was collected \(s.place) on \(s.day), photographed in place, and sealed.", "An evidence technician collected it that \(Clock.partOfDay(s.time)) and logged it into the property room.", "It was collected \(s.place) on \(s.day) and photographed, then labeled and packaged.", "It was processed \(s.place) on \(s.day), photographed and measured before it went into a sealed bag.", "It was picked up \(s.place) on \(s.day) by an evidence technician and logged into the property room.", "We collected it \(s.place) on \(s.day), documented where it was found, and secured it.", "An evidence technician recovered it \(s.place) on \(s.day) and sealed it at the scene.", "It was documented \(s.place) on \(s.day) and then bagged, tagged, and logged."])
            }
        case .forensic:
            let sent = s.labSubmitted.map { " on \(CaseDates.day($0))" } ?? ""
            let back = s.labReturned.map { ", and the report came back \(CaseDates.day($0))" } ?? ""
            return rng.pick(["I submitted it to the State Crime Laboratory\(sent)\(back).", "It went to the State Crime Laboratory\(sent) with a request for analysis\(back).", "I sent it to the State Crime Laboratory\(sent) for testing\(back).", "It was packaged and delivered to the State Crime Laboratory\(sent), with a request for examination\(back).", "The State Crime Laboratory received it from me\(sent), under a chain-of-custody form\(back).", "I turned it over to the State Crime Laboratory\(sent) to be tested\(back).", "I requested laboratory analysis and shipped it to the State Crime Laboratory\(sent)\(back).", "I sealed it, filled out the submission forms, and sent it to the State Crime Laboratory\(sent)\(back)."])
        case .video:
            return Variety.pick(["I collected the footage within a few days, before the system could record over it.", "The owner of the system gave us a copy, and I checked its clock against real time.",
                             "We downloaded it and verified the timestamp.", "The camera belongs to a nearby business. I asked for the footage right away and copied it onto a disk.", "I went to the location, watched the video with the owner, and had the relevant part exported.", "We pulled the video from the recorder, and I confirmed the timestamp against my own watch.", "The system records over itself, so I requested the clip quickly and secured a copy.", "I made a copy of the video at the scene and noted how the recorder's clock was set.", "The owner of the system exported the clip for me, and I confirmed it played the same on our equipment."], rng: &rng)
        case .digital:
            return Variety.pick(["We obtained it with a search warrant.", "It came from the provider under a warrant, with a records custodian's certification.", "A forensic examiner extracted it from the device under a warrant.", "A forensic examiner imaged the device after we obtained a warrant.", "We served a warrant on the provider, and the records came back with a certification.", "The device was seized and its contents were extracted by a trained examiner under a warrant.", "We got a search warrant for the account, and the provider sent us the data.", "After the warrant was signed, an examiner made a forensic copy so the original stayed untouched.", "It was recovered from the device by a forensic examiner, and I confirmed the warrant covered it."], rng: &rng)
        case .document:
            return Variety.pick(["We got it by subpoena.", "It was produced to us by the records custodian.", "It came in through a subpoena, certified as a business record.", "I requested it from the custodian, and it came with a certification.", "It was produced in response to a subpoena, with a records custodian's affidavit.", "We asked for it through a subpoena and the custodian delivered certified copies.", "The business turned it over after we served a subpoena.", "It was obtained from the records custodian, who certified that it was kept in the regular course of business.", "It came to us by subpoena, and I compared it against the originals at the custodian's office."], rng: &rng)
        case .statement:
            if let day = s.interview { return "That's \(ctx.dl)'s own statement, recorded on \(CaseDates.day(day))." }
            return rng.pick(["Those are \(ctx.dl)'s own words.", "That statement was made to an officer and documented the same day.", "That's what \(ctx.dl) told the officer, and it was written down at the time.", "This was given to an officer and put on paper shortly afterward.", "Those words came from \(ctx.dl), not from anyone else, and they were documented.", "It's a record of what \(ctx.dl) said to us.", "That statement was taken by an officer and filed with the case.", "The statement was documented when it was made, and it reflects what \(ctx.dl) said."])
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

    /// A witness is never asked the same thing twice: within one phase, a question that is nearly the same as one already asked
    /// (the same content words) is dropped with its answer, so lines from different lists never read as a repeat.
    static func withoutRepeats(_ exchanges: [TestimonyExchange]) -> [TestimonyExchange] {
        let stop: Set<String> = ["a", "an", "the", "of", "to", "and", "or", "in", "on", "at", "for", "with", "by", "is", "was", "were", "are", "be", "been",
                                 "did", "do", "does", "you", "your", "didn't", "don't", "not", "it", "that", "this", "i", "he", "she", "they"]
        func tokens(_ q: String) -> Set<String> {
            Set(q.lowercased().split(whereSeparator: { !($0.isLetter || $0.isNumber || $0 == "$") }).map(String.init).filter { !stop.contains($0) })
        }
        var seen: [TestimonyExchange.Phase: [(Set<String>, Bool)]] = [:]
        var out: [TestimonyExchange] = []
        for e in exchanges {
            let q = e.question.trimmingCharacters(in: .whitespaces)
            guard !q.isEmpty else { out.append(e); continue }
            let tq = tokens(q)
            let exhibit = q.lowercased().contains("exhibit")
            let repeated = tq.count >= 2 && (seen[e.phase] ?? []).contains { other, otherExhibit in
                !(exhibit && otherExhibit) && other.count >= 2 && Double(tq.intersection(other).count) / Double(min(tq.count, other.count)) >= 0.8
            }
            if repeated { continue }
            seen[e.phase, default: []].append((tq, exhibit))
            out.append(e)
        }
        return out
    }

    private static func witness(name: String, role: String, side: Side, exchanges all: [TestimonyExchange]) -> Witness {
        let exchanges = withoutRepeats(all)
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
        d(Variety.pick(["Please state your name and assignment.", "Tell the court who you are and where you work.", "State your name and your agency, please.", "Which agency do you work for, and what is your assignment?", "State your name, your agency, and your role in this case.", "Who are you with, and what do you do there?", "Please identify yourself for the record.", "Tell the court your name and who employs you.", "Introduce yourself to the court and tell us your assignment."], rng: &rng),
          "\(name), \(agency). " + Variety.pick(["I was the lead investigator on this case.",
                                             "I was assigned this case on \(CaseDates.day(s.assigned)) and handled it through the arrest.",
                                             "I've had this case since \(CaseDates.day(s.assigned)).", "I was the case agent on this matter from start to finish.", "I was the primary investigator assigned to this case.", "I took over as lead on this case on \(CaseDates.day(s.assigned)) and worked it through the arrest.", "I picked this case up on \(CaseDates.day(s.assigned)) and stayed with it to the end.", "I've been the investigating officer since \(CaseDates.day(s.assigned)).", "I was assigned as the lead investigator on \(CaseDates.day(s.assigned))."], rng: &rng))
        let years = rng.int(4...19)
        d(Variety.pick(["How long have you worked investigations?", "What's your background?", "Tell the court about your experience.", "How many years have you been an investigator?", "Tell the court about your law enforcement career.", "What experience do you have investigating cases like this?", "What's your professional history?", "How did you come to be an investigator?", "Describe your training and background."], rng: &rng),
          Variety.pick(["\(years) years with \(trooper ? "the Patrol" : "the agency"), the last \(max(2, years / 2)) in \(unit(for: ctx)).",
                    "\(rng.int(2...6)) years on patrol, then \(years) years in \(unit(for: ctx)). I've worked somewhere around \(rng.int(6...30) * 10) cases.",
                    "\(years) years. Most of that time has been \(unit(for: ctx)).", "I've spent \(years) years in law enforcement, most of it in \(unit(for: ctx)).", "\(years) years total. I started on patrol and moved into \(unit(for: ctx)) later on.", "I've been an investigator for the past \(max(2, years / 2)) years, after a long stretch in uniform. Most of my work is \(unit(for: ctx)).", "\(years) years sworn, and \(unit(for: ctx)) has been my focus for much of that time.", "I came up through patrol and have spent the last \(max(2, years / 2)) years in \(unit(for: ctx)).", "About \(years) years. Much of it has been in \(unit(for: ctx)), and I've kept up with regular training."], rng: &rng)
          + (rng.chance(0.5) ? " " + trainingLine(ctx, rng: &rng) : ""))

        // How it began, from the fact sheet
        let begin: String
        // A drug sale made to an undercover officer or informant isn't a 911 call about "suspected drug activity": the unit was working it.
        let drugBuy = facts.setting == .drugs && facts.mentions(["undercover", "controlled buy", "controlled purchase", "informant"])
        switch facts.origin {
        case .call where drugBuy:
            begin = rng.pick(["Our unit had complaints about drug sales in the area, and on \(s.day) I set up a purchase \(s.place). I was the case agent from that point on.",
                              "On \(s.day), at about \(s.time ?? "that time"), we made a planned purchase \(s.place) as part of an ongoing narcotics investigation. I was assigned the case that day.",
                              "We'd had tips about sales \(s.place), so on \(s.day) we arranged a buy and watched it happen. I took the case from there."])
        case .call:
            begin = rng.pick([
                "On \(s.day) at about \(s.time ?? "that time"), 911 got a call reporting \(Investigations.incidentNoun(facts, charges: ctx.charges)) \(s.place). \(s.firstOfficer) was first there, at about \(s.arrivalTime ?? "a few minutes later"). I was called \(s.assigned == s.incident ? "out that night" : "the next morning") and took the case.",
                "It started with a 911 call on \(s.day), about \(s.time ?? "that night"). Patrol responded \(s.place). I was assigned \(s.assigned == s.incident ? "within the hour" : "on \(CaseDates.day(s.assigned))").", "A 911 call came in on \(s.day) reporting \(Investigations.incidentNoun(facts, charges: ctx.charges)) \(s.place). \(s.firstOfficer) responded first, and I took over the case on \(CaseDates.day(s.assigned)).", "Dispatch sent patrol \(s.place) on \(s.day) after a 911 call. \(s.firstOfficer) secured things, and the case was handed to me on \(CaseDates.day(s.assigned)).", "It began as a 911 call on \(s.day). \(s.firstOfficer) was the first officer there, and I was assigned the investigation on \(CaseDates.day(s.assigned)).", "I got the case on \(CaseDates.day(s.assigned)). It started with a 911 call on \(s.day), and \(s.firstOfficer) responded \(s.place).", "On \(s.day), someone called 911 about \(Investigations.incidentNoun(facts, charges: ctx.charges)) \(s.place). Officers went out right away, and the case came to me on \(CaseDates.day(s.assigned)).", "The case started with an emergency call on \(s.day). \(s.firstOfficer) was dispatched \(s.place), and I picked up the investigation on \(CaseDates.day(s.assigned))."])
        case .stop:
            begin = madeTheStop
                ? rng.pick(["I was on patrol on \(s.day). At about \(s.time ?? "that time") I stopped the vehicle \(s.place).",
                            "On \(s.day), around \(s.time ?? "that time"), I was working \(s.place) when I stopped the car \(dl) was driving.", "On \(s.day) I was on patrol \(s.place) when I made a traffic stop on the vehicle \(dl) was driving.", "I was working a shift on \(s.day) and initiated a stop \(s.place). \(dl) was the driver.", "On \(s.day), I pulled over a car \(s.place) that \(dl) was driving.", "I was on duty on \(s.day) \(s.place) when I stopped a vehicle. \(dl) was behind the wheel.", "My shift on \(s.day) put me \(s.place), and that's where I stopped the car.", "I stopped \(dl)'s vehicle \(s.place) on \(s.day) while on routine patrol."])
                : "\(s.firstOfficer) made a stop \(s.place) on \(s.day), at about \(s.time ?? "that time"), and called me in once the search turned up what it did."
        case .warrant:
            begin = rng.pick(["We'd been getting information about a residence on \(s.street) for several weeks. I opened the file, built the probable cause, and applied for the warrant we served on \(s.day).",
                              "Complaints and surveillance led us to a house on \(s.street) in \(s.town). The warrant was signed the day before we served it, on \(s.day).", "Over several weeks we developed information that tied a house on \(s.street) to what we were investigating. I wrote the affidavit, a judge signed the warrant, and we served it on \(s.day).", "A series of tips about \(s.street) led me to open the case. I checked what I could, took it to a judge, and we served the warrant on \(s.day).", "We watched a home on \(s.street) in \(s.town) for a while before I applied for a search warrant. It was served on \(s.day).", "A detective on my team brought me information about a house on \(s.street). I verified it, and the warrant was served on \(s.day).", "The investigation centered on a residence on \(s.street). After gathering information, I sought the warrant, and we served it on \(s.day).", "I'd been working information on a house on \(s.street) in \(s.town) for weeks. Once the warrant was approved, we went in on \(s.day)."])
        case .report:
            let who = ctx.victim ?? "a member of the public"
            begin = "\(who.capitalizedFirst) reported it to \(agency), and \(s.firstOfficer) took the first report. I was assigned on \(CaseDates.day(s.assigned))."
        case .records:
            let who = ctx.victim ?? ctx.organization ?? "the complaining party"
            begin = rng.pick(["\(who.capitalizedFirst) contacted us on \(s.day) with concerns about \(facts.money ? "missing money" : "what had happened"). I was assigned on \(CaseDates.day(s.assigned)).",
                              "The complaint came in on \(s.day). By \(CaseDates.day(s.assigned)) I had the file and had sent preservation letters.", "The complaint reached us on \(s.day). I was assigned on \(CaseDates.day(s.assigned)) and started by securing the records.", "\(who.capitalizedFirst) brought this to us on \(s.day). I took the file on \(CaseDates.day(s.assigned)) and began by requesting records.", "This started with a report from \(who) on \(s.day). By \(CaseDates.day(s.assigned)) I had the file and a plan for getting the records.", "We got the complaint on \(s.day), and it was assigned to me on \(CaseDates.day(s.assigned)). My first move was to lock down the evidence before anything could change.", "The case came to me on \(CaseDates.day(s.assigned)) after \(who) came forward on \(s.day).", "\(who.capitalizedFirst) first raised the problem with us on \(s.day). I was handed the file on \(CaseDates.day(s.assigned))."])
        }
        d(Variety.pick(["How did this case come to you?", "How did you get involved?", "When did you first hear about this case?", "How did you come to be assigned to this case?", "What was your first involvement?", "How did this investigation begin?", "Tell the court how this case started for you.", "How did this matter reach your desk?", "When and how did you become involved?"], rng: &rng), begin)

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
        d(Variety.pick(["What did you do first?", "What were your first steps?", "Walk the court through how you started.", "What was the first thing you did?", "Where did you begin?", "What did the investigation look like in the early stages?", "What happened first after you took the case?", "How did you get started?", "Tell the court what you did in the beginning."], rng: &rng), rng.pick(steps))

        // The evidence, in the order it was found
        let items = Array(ctx.stateInOrder.filter { $0.kind != .statement }.prefix(rng.int(2...4)))
        for (index, item) in items.enumerated() {
            let q = index == 0
                ? Variety.pick(["Let's turn to \(item.exhibit). What is it?", "Tell the court about \(item.exhibit), \(item.phrase).", "What's \(item.exhibit)?", "I'd like to show you \(item.exhibit). Can you tell the court what it is?", "Let's look at \(item.exhibit). What can you tell us about it?", "Directing your attention to \(item.exhibit). What is that?", "Moving on to \(item.exhibit). What do we have there?", "Tell the court what \(item.exhibit) is.", "Let's talk about \(item.exhibit), \(item.phrase). What is it?"], rng: &rng)
                : Variety.pick(["What about \(item.exhibit)?", "And \(item.exhibit), \(item.phrase)?", "Tell the court how you got \(item.phrase).", "What did \(item.phrase) show?", "Moving to \(item.exhibit), \(item.phrase). What can you tell us?", "Next, \(item.exhibit). What is it?", "Let's go on to \(item.exhibit). What did you do with it?", "What can you tell the court about \(item.exhibit)?", "Is there anything about \(item.exhibit) the court should hear?", "Turning to \(item.exhibit). What do we have there?"], rng: &rng)
            let how = howObtained(item, ctx: ctx, rng: &rng)
            let why = rng.chance(0.55) ? " " + rng.pick(significance) : ""
            d(q, "\(item.detail) \(how)\(why)")
        }

        // Who it was
        let identityAtIssue = facts.identity || facts.origin == .records || facts.origin == .report
            || (facts.origin == .call && facts.setting != .road && !ctx.report.howIdentified.contains("still"))
        if identityAtIssue {
            d(Variety.pick(["How did \(dl) become a suspect?", "How did the investigation come to focus on \(dl)?", "What led you to \(dl)?", "How did \(dl) first come to your attention?", "What made \(dl) a person of interest?", "How did you narrow it down to \(dl)?", "What pointed you toward \(dl)?", "At what point did \(dl) become the focus?", "How did \(dl)'s name come up?"], rng: &rng),
              ctx.report.howIdentified + " " + Variety.pick(["Everything after that was about testing it.", "From there we tried to confirm it or rule it out.", "We didn't stop there; we kept checking it against the rest.", "After that, the work was making sure we had the right person.", "I treated that as a lead, not a conclusion, and kept working.", "That gave us a direction, and we built on it with everything else.", "We then looked for anything that would support it or contradict it.", "From there, each piece of evidence either fit or it didn't.", "That was where we started, not where we stopped."], rng: &rng))
        } else {
            d(rng.pick(["Was there any question about who was involved?", "How was \(dl) identified?", "Who was identified as the person involved?", "How did you identify \(dl)?", "Was there any doubt as to who was responsible?", "How did you know who to look for?", "Tell the court how \(dl) was identified.", "How did \(dl) come into the investigation?"]),
              ctx.report.howIdentified)
        }

        // The statement
        if let day = s.interview {
            let statement = ctx.state.first { $0.kind == .statement }
            d(Variety.pick(["Did \(dl) give a statement?", "Did you interview \(dl)?", "Did \(dl) talk to you?", "Did you get a statement from \(dl)?", "Did you have a chance to speak with \(dl)?", "Was \(dl) interviewed?", "Did \(dl) say anything to you about this?", "Did you question \(dl) about this?", "Did \(dl) agree to talk with you?"], rng: &rng),
              "Yes. On \(CaseDates.day(day)), after Miranda warnings, \(dl) signed a waiver and talked for about \(rng.int(2...9) * 10) minutes. It was recorded." + (statement.map { " The key part: \($0.detail)" } ?? ""))
        }
        // With no statement, the State doesn't ask: a defendant's choice to stay silent or ask for a lawyer can't be used
        // against them (Doyle v. Ohio; State v. Ward).

        // The arrest
        let resisted = ctx.lawIDs.contains("resisting")
        let arrestLine: String
        if facts.origin == .records {
            arrestLine = rng.pick(["\(dl) surrendered at the magistrate's office with a lawyer.", "\(dl) surrendered by arrangement with counsel.", "\(dl) turned in voluntarily at the sheriff's office, accompanied by an attorney.", "After we contacted counsel, \(dl) came in and turned in at the jail.", "\(dl) was booked after surrendering through an attorney, with no struggle.", "\(dl) arranged through a lawyer to turn in at the magistrate's office, and did.", "\(dl) appeared at the jail with counsel and was taken into custody there.", "\(dl) came in voluntarily with an attorney and was processed without incident."])
        } else if resisted {
            arrestLine = "\(dl) pulled away and had to be taken to the ground before handcuffs went on."
        } else if s.arrest == s.incident && facts.origin != .warrant {
            arrestLine = rng.pick(["It happened right there. \(dl) was cooperative.", "That same \(Clock.partOfDay(s.time)). There were no problems.", "It was done at the scene. \(dl) did what was asked.", "It happened that same \(Clock.partOfDay(s.time)), and \(dl) went along without an issue.", "Right there at the scene, and \(dl) was calm about it.", "That same \(Clock.partOfDay(s.time)), without any trouble.", "\(dl) was taken into custody on the spot, quietly.", "It happened immediately, and \(dl) gave us no trouble."])
        } else {
            arrestLine = Variety.pick(["It was uneventful.", "\(dl) was cooperative.", "No problems. \(dl) was quiet.", "It went smoothly.", "\(dl) came along without any trouble.", "There was no resistance of any kind.", "\(dl) was polite and did what was asked.", "Nothing out of the ordinary happened.", "It was routine. \(dl) was calm the whole time."], rng: &rng)
        }
        d(Variety.pick(["When was \(dl) arrested?", "Tell the court about the arrest.", "How did the arrest happen?", "How and when did the arrest take place?", "Was \(dl) taken into custody?", "What can you tell the court about the arrest?", "Describe how \(dl) was taken into custody.", "When did the arrest occur?", "Tell us about the day \(dl) was arrested."], rng: &rng),
          "On \(CaseDates.day(s.arrest)). " + arrestLine)

        if let sent = s.labSubmitted {
            let forensic = ctx.state.filter { $0.kind == .forensic }
            d(rng.pick(["Did anything go to the State Crime Laboratory?", "Were items submitted for testing?", "Did you send any evidence to the lab?", "Was any of the evidence tested?", "Did you ask for any forensic analysis?", "Were any items sent out for examination?", "Was anything submitted to the crime lab?", "Did you have any of this analyzed?"]),
              "Yes. On \(CaseDates.day(sent)) I submitted \(forensic.map { $0.phrase }.joined(separator: " and ")). " + (s.labReturned.map { "The results came back on \(CaseDates.day($0))." } ?? ""))
        }

        // Cross: the gaps in this file, then the weak points of this kind of case
        for gap in ctx.gaps { c(gap.question, gap.answer) }
        var pool: [(String, String)] = []
        if identityAtIssue && facts.setting != .paper {
            let days = CaseDates.days(from: s.incident, to: s.arrest)
            pool.append(rng.pick([
                ("Between \(s.day) and the arrest, how many people did you actually interview?",
                 "\(rng.int(3...9)), not counting brief conversations at the scene. I can go through each one if the court wants."),
                ("The tip that named \(dl) came in anonymously, correct?",
                 ctx.defense.contains { $0.title.lowercased().contains("tip") } ? "Yes. We couldn't identify the caller, which is why we looked for other corroboration." : "No. The first name we had came from a witness who gave a statement.")]))
            var arrestQuestions: [(String, String)] = []
            if days > 0 {
                arrestQuestions.append(("You arrested \(dl) \(days) day\(days == 1 ? "" : "s") after the incident. What new evidence came in on the last day?",
                                        "Nothing on the last day itself. It was the combination of what we'd gathered by then."))
            }
            pool.append(rng.pick(arrestQuestions + [
                ("Did you ever put a photo of anyone besides \(dl) in front of a witness?",
                 rng.pick(["Yes, in a six-person array with fillers. That's our procedure.", "No. We didn't use a lineup in this case.", "Yes, a photo array of six, shown by an officer who wasn't involved in the case.", "No. Nobody was shown a photo array in this investigation.", "Yes. Several photos were shown, and each witness was told the suspect might not be among them.", "No. The identification didn't depend on a photograph.", "Yes. A double-blind array was used, as our policy requires.", "No. Photo arrays weren't part of how this case came together."])),
                ("Was anyone else's phone, car, or home ever searched in this case?",
                 rng.pick(["No. There was no basis to search anyone else.", "One other person's car, early on, with consent. Nothing came of it.", "No. Nothing pointed to anyone else.", "Yes. Another person's phone was checked early on, with consent, and it led nowhere.", "No. There was never a reason to get a warrant for anyone else.", "One other person's home, briefly, by consent. Nothing connected it to this case.", "No. The evidence led one direction, and we followed it.", "Early on I looked into one other person. That person was ruled out within a day."]))]))
        }
        switch facts.setting {
        case .road:
            if facts.impaired {
                pool.append(("Nystagmus can come from things other than alcohol, can't it?", "Some forms can. What I saw was consistent with impairment, and the breath result confirmed it."))
                pool.append(("\(dl) was polite and cooperative?", "Yes. That's not unusual."))
                pool.append(("\(dl) produced a license and registration without fumbling?", rng.pick(["That part went fine.", "Yes, as I recall.", "Yes. There was no delay.", "I don't recall any difficulty with that.", "Yes. That was normal.", "Yes. Everything was in order.", "Yes, I believe so.", "Nothing unusual about that part."])))
            }
            if facts.mentions(["crash", "struck", "killed", "collision"]) {
                pool.append(("You never saw \(dl) driving before the crash?", "No. I arrived after."))
                pool.append(("Your report doesn't analyze what the other vehicle was doing?", "It focuses on what caused the crash. I didn't find fault on the other side."))
            }
        case .drugs:
            pool.append(("You never saw \(dl) sell anything to anyone?", rng.pick(["Not personally, no.", "Not with my own eyes. The circumstances showed it.", "No. I didn't witness a sale.", "Not myself. The case rests on what was found and what it indicated.", "I didn't see an exchange, no. I'm telling you what the evidence showed.", "No, I never saw money change hands.", "Not directly. That's not how these cases usually come together.", "Correct. I didn't see a transaction myself."])))
            pool.append(("Nothing illegal was found in \(dl)'s pockets?", rng.pick(["Not in the pockets, no.", "Correct. It was in the \(facts.origin == .stop ? "car" : "house").", "Right. Nothing was on \(dl)'s person.", "No. The pockets held nothing illegal.", "That's correct. What we found was elsewhere.", "No, not on \(dl)'s person.", "Correct. Nothing illegal was in the pockets.", "No. What was recovered was found somewhere else."])))
            pool.append(("\(dl) works as \(withArticle(ctx.defendant.occupation)). Cash can come from a job, can't it?", "It can. We didn't find a pay stub that explained that amount."))
        case .paper:
            pool.append(("You're not an accountant?", rng.pick(["No. We had an analyst for the numbers, and I reviewed the work.", "No. I'm an investigator. The totals were checked by someone who is.", "No. I'm not an accountant, but I've trained to read financial records.", "No. A forensic accountant helped with the totals.", "No. My job is to investigate. Accountants checked the math.", "No. I work from the records, and a trained analyst verified the figures.", "No, I'm not. The numbers were reconstructed with an analyst and double-checked.", "Correct. I rely on trained analysts for the arithmetic."])))
            pool.append(("You took the complainant's word for which transactions were unauthorized?", "At first. Then we tested it against the records."))
            if s.interview == nil { pool.append(("You never heard \(dl)'s side before charging?", "\(dl) declined to be interviewed through counsel. That was the opportunity.")) }
        case .scene:
            if facts.origin == .report {
                pool.append(("Most of what you know came from \(ctx.victim ?? "the person who reported it")?", "The report started there. The investigation didn't end there."))
            }
        }
        pool.append(("You wrote your final report after the arrest, didn't you?", "The supplemental report, yes. The initial report was written as things happened."))
        if let def = ctx.defense.first {
            pool.append(("Did your investigation ever account for \(def.phrase)?",
                         Variety.pick(["I learned about it from the defense. It didn't change my view of the evidence.", "I'm aware of it. I don't think it outweighs what we found.", "No. That came in later.", "Not at the time. I've since looked at it, and I don't think it changes anything.", "Yes, I considered it. It didn't fit with the rest of the evidence.", "I became aware of it afterward, and I looked into it.", "It wasn't part of what I knew when I made my decisions.", "I reviewed it once it was raised. It didn't change my conclusions.", "We looked at it as far as we could. It didn't explain what we found."], rng: &rng)))
        }
        for (q, a) in rng.pick(pool, count: rng.int(2...3)) { c(q, a) }

        // Redirect
        var redirect: [(String, String)] = [
            ("Does anything you were asked on cross change what the evidence showed?", ctx.gaps.isEmpty ? "No. Everything that should have been done was done, and the evidence is what it is." : "No. The points they raised are fair, but they don't change what we found."),
            ("Did you have any reason to cut corners in this case?", "No. It got the same work I'd give any case.")
        ]
        if let top = ctx.strongest {
            redirect.append(("Would any of the steps counsel mentioned change what \(top.phrase) shows?", "No. \(top.phrase.capitalizedFirst) is what it is."))
        }
        if identityAtIssue {
            redirect.append(("Why did the investigation focus on \(dl)?", "Because of what the evidence showed. " + ctx.report.howIdentified))
        }
        for (q, a) in rng.pick(redirect, count: rng.int(1...2)) { r(q, a) }
        return witness(name: name, role: trooper ? "Investigating trooper, \(agency)" : "Lead investigator, \(agency)", side: .prosecution, exchanges: ex)
    }

    private static func trainingLine(_ ctx: Context, rng: inout SeededRNG) -> String {
        switch ctx.setting {
        case .road: return rng.pick(["I'm certified to administer standardized field sobriety tests and to operate the Intoxilyzer 9000.", "I've completed advanced collision investigation and drug recognition training.", "I've taken advanced training in detecting impaired drivers and in investigating serious collisions.", "I'm a certified breath test operator, and I've had advanced roadside impaired-driving enforcement training.", "I've been trained in crash investigation and in recognizing drivers impaired by drugs or alcohol.", "I've completed collision reconstruction coursework and I recertify in field sobriety testing regularly.", "I've completed specialized training in commercial vehicle inspections and collision scene measurement.", "I've had years of traffic enforcement training, including courses on DWI detection and report writing."])
        case .paper: return rng.pick(["I've completed financial investigations training through the SBI and certified fraud examiner coursework.", "I've had training in following money through bank records and in digital evidence.", "I've completed training in fraud examination and in analyzing bank and business records.", "I've taken courses in computer forensics and in tracing electronic transactions.", "I've had specialized training in financial crime investigations and in testifying about records.", "I've completed courses on identity theft, check fraud, and embezzlement investigations.", "I've had training in forensic accounting basics and in handling digital evidence.", "I've attended several state and federal workshops on economic crime investigation."])
        case .drugs: return rng.pick(["I've completed DEA basic narcotics school and interdiction training.", "I've been through the State's drug identification and undercover operations courses.", "I've been through the State's basic and advanced narcotics investigation courses.", "I've had training in recognizing controlled substances and the packaging used for sales.", "I've completed courses on surveillance, informant handling, and search warrant execution.", "I've worked with a multi-agency drug task force and taken their required training.", "I've completed training in field-testing suspected controlled substances.", "I've attended regional narcotics schools and supported undercover operations for several years."])
        case .scene: return rng.pick(["I've completed homicide and crime scene courses at the Justice Academy.", "I've had interview and interrogation training and crime scene processing courses.", "I've completed training in crime scene documentation and in evidence packaging.", "I've been through courses on evidence collection and chain of custody.", "I've had advanced training in interviewing witnesses and suspects.", "I've completed crime scene photography and evidence recovery courses.", "I've attended training on scene processing and working with forensic laboratories.", "I've taken courses on investigating crimes against persons and working with victims."])
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

        d(Variety.pick(["Please state your name and assignment.", "Tell the court who you are.", "Where do you work, and what do you do?", "Tell the court your name and where you're assigned.", "Who are you with, and what's your assignment?", "State your name and the agency you work for.", "For the record, please tell us who you are and what you do.", "What agency do you work for, and what do you do there?", "Introduce yourself to the court, please."], rng: &rng),
          "\(name). I'm with \(agency), assigned to \(Variety.pick(["patrol", "the \(s.town) district", "the evening patrol shift", "uniform patrol", "the day shift", "the night shift", "the \(s.town) beat", "road patrol", "the first-shift patrol squad", "community patrol"], rng: &rng)). " + Variety.pick(["\(years) years now.", "I've been there \(years) years.", "Going on \(years) years.", "I've been on the job \(years) years.", "That's \(years) years for me.", "\(years) years in uniform.", "I've worked there about \(years) years.", "It's been \(years) years.", "A little over \(years) years."], rng: &rng))

        var crossPool: [(String, String)] = []
        switch facts.origin {
        case .stop:
            let reason: String
            if facts.impaired { reason = rng.pick(["The vehicle crossed the center line twice and drifted onto the fog line.", "It was weaving inside its lane and then braked hard for no reason at a green light.", "The vehicle was straddling the lane line and swerved when it met another car.", "It was going well under the limit, then sped up, and drifted toward the shoulder twice.", "It failed to maintain its lane several times and came close to a parked car.", "It made a wide turn into the opposite lane and corrected late.", "It sped up and slowed down repeatedly, and it almost sideswiped a guardrail.", "It stopped at a green light for several seconds and then took off unevenly."]) }
            else if facts.mentions(["windshield"]) { reason = "A cracked windshield obstructing the driver's view." }
            else if facts.mentions(["taillight", "headlight"]) { reason = "An equipment violation: a light was out." }
            else { reason = Variety.pick(["It was doing 58 in a 45.", "Expired registration and a dead tag light.", "It rolled through a stop sign.", "It was doing 71 in a 55.", "It had a broken brake light on the left side.", "It changed lanes without signaling.", "It was following the car ahead too closely.", "It failed to stop at the red light before turning right.", "Its license plate light was out and the tag was partly covered."], rng: &rng) }
            d(rng.pick(["Why did you stop the vehicle?", "What drew your attention to the car?", "What made you stop the car?", "What was the reason for the stop?", "Tell the court why you pulled the vehicle over.", "What did you see before you made the stop?", "What was it about the vehicle that caught your eye?", "Why did you pull the car over?"]),
              "On \(s.day), at about \(s.time ?? "that time"), I was on patrol \(s.place). \(reason)")
            d(rng.pick(["Who was driving?", "Who did you find behind the wheel?", "Who was operating the vehicle?", "Who was in the driver's seat?", "Did you identify the driver?", "Who was behind the wheel when you reached the car?", "Who did you speak to at the driver's window?", "Who was the person driving the car?"]),
              "\(dl). " + Variety.pick(["I identified \(dl) from a driver's license.", "\(dl) gave me a license, and the photo matched.", "There was no question about that; \(dl) was the only one in the driver's seat.", "\(dl) handed over a license, and I checked it against the face.", "I confirmed who \(dl) was from the license and a records check.", "I ran the license, and the photo and information matched \(dl).", "\(dl) was alone in the vehicle, and the license left no doubt about who it was.", "The license \(dl) gave me checked out as valid and matched the person in front of me.", "\(dl) told me the name out loud, and the license backed that up."], rng: &rng))
            d(rng.pick(["What did you notice when you spoke with the driver?", "What happened when you approached?", "What did you observe when you made contact?", "How did the driver act when you reached the window?", "Tell the court what you noticed up close.", "What stood out to you at the driver's window?", "Did anything about the driver stand out?", "What was your first impression when you spoke to the driver?"]),
              facts.setting == .drugs
                ? rng.pick(["\(dl)'s hands were shaking and \(dl) kept looking at the center console. There was a strong odor coming from the car.", "\(dl) was talking fast and gave two different answers about where \(dl) was coming from.", "\(dl) wouldn't look at me and kept saying the car belonged to a friend. There was a strong smell I recognized.", "\(dl) was sweating and kept glancing at the back seat.", "\(dl) answered questions before I finished asking them and kept glancing at the glove box.", "\(dl) was jumpy, and there was an odor from the car that I associate with narcotics.", "\(dl) fumbled with the registration and said the car was borrowed, then said it wasn't.", "\(dl) had trouble sitting still and offered information I hadn't asked for."])
                : rng.pick(["\(dl) was nervous and kept reaching toward the console.", "\(dl) was calm, but the story about where \(dl) was headed didn't add up.", "\(dl) was polite but kept checking the mirror and avoiding eye contact.", "\(dl) seemed uneasy and moved quickly toward the glove box when I asked for the registration.", "\(dl) was talkative and offered an explanation for the driving before I asked.", "\(dl) was quiet, answered in short phrases, and said nothing about where \(dl) was headed.", "\(dl) was cooperative at first, but the timeline of the evening kept shifting.", "\(dl) seemed rattled and kept apologizing without saying what for."]))
            if !collected.isEmpty {
                d(rng.pick(["What was found in the vehicle?", "Did you find anything?", "What, if anything, was in the car?", "Did you search the vehicle?", "What did you recover from the vehicle?", "What turned up in the car?", "Tell the court what was found inside the vehicle.", "Was anything of note in the car?"]),
                  collected.map { "\($0.title): \($0.detail)" }.prefix(2).joined(separator: " "))
            }
            crossPool += [("The reason for the stop was minor, wasn't it?", "It was a violation. I stop cars for that every shift."),
                          ("You'd already decided to search before you had any reason to?", "No. I searched because of what I saw once I was at the window."),
                          ("Nothing about the driving itself was dangerous?", "Not in the moment I saw. That's not the standard for a stop.")]
        case .warrant:
            d(rng.pick(["What was your role on \(s.day)?", "How were you involved in the search?", "What was your assignment when the warrant was served?", "Where were you when the team went in?", "Tell the court what you did on \(s.day).", "What part did you play in executing the warrant?", "What was your job during the search?", "How did you take part in the operation?"]),
              rng.pick(["I was on the entry team. We knocked, announced, waited, and went in when no one answered.", "I held the perimeter, then helped search the back bedroom once the house was secured.", "I was assigned to the rear of the house to make sure nobody left, and I came inside after it was cleared.", "I was the second officer in. I helped clear the rooms and stayed with the occupants.", "I was on the search team. After the house was secured, I took the kitchen and the hallway closet.", "I covered the front door while the entry team went in, then searched the living room.", "I handled the occupants while the others cleared the house, and I stayed with them until the search ended.", "I helped inventory what the search team found and made sure everything was photographed first."]))
            d(rng.pick(["Who was inside?", "What did you find when you went in?", "Who did you encounter in the residence?", "Who was home?", "Was anyone present when you went in?", "What did the team see when the door opened?", "Who was there when you entered?", "What was the scene when you got inside?"]),
              facts.mentions(["three people"]) ? "Three adults. \(dl) was one of them, in the living room." : "\(dl) was there. " + Variety.pick(["In the kitchen.", "Coming out of the hallway.", "On the couch.", "Standing by the kitchen table.", "Seated on the couch with the television on.", "Coming out of a back bedroom.", "In the front room, near the door.", "At the dining table.", "Walking toward the front door when we came in."], rng: &rng))
            if !collected.isEmpty { d("What did you find?", collected.map { "\($0.title): \($0.detail)" }.prefix(2).joined(separator: " ")) }
            crossPool += [("You didn't see \(dl) holding anything illegal?", "No. I saw where things were and who was there."),
                          ("Other people lived in or visited that house?", "Other people were there. I can't tell you who lived there."),
                          ("The bedroom where it was found, you don't know whose it was?", "I know what was in it and where we found it. Whose room it was is a question for the paperwork.")]
        case .report:
            let who = ctx.victim ?? "the person reporting it"
            d(rng.pick(["How did you get involved?", "What was your role?", "How did this come to your attention?", "What was your involvement?", "Tell the court how you came to take the report.", "What did you do in this case?", "Why were you the officer who handled this?", "How did you first learn about this?"]),
              "I took the initial report from \(who) on \(CaseDates.day(CaseDates.add(0, to: s.incident))). " + rng.pick(["\(who.capitalizedFirst) was upset but clear about what happened.", "I wrote down what I was told and passed it to investigations.", "\(who.capitalizedFirst) gave me the details in order and answered each follow-up question.", "I recorded the account, collected contact information, and told \(who) what would happen next.", "\(who.capitalizedFirst) was shaken but able to describe everything.", "I asked what happened, wrote it down, and read it back to confirm I had it right.", "\(who.capitalizedFirst) was calm and clear, and I took careful notes.", "I took the report, gave \(who) a case number, and sent the file on for follow-up."]))
            d(rng.pick(["What did you do with that report?", "What happened next?", "Where did the report go?", "What became of the report?", "After you took it, what did you do?", "Who received it after you?", "What was the next step?", "Did you pass it along?"]),
              "It went to \(s.lead), who took over on \(CaseDates.day(s.assigned)).")
            crossPool += [("You didn't see any of this yourself?", "No. I took the report."),
                          ("You wrote down what you were told, not what you verified?", "That's what an initial report is.")]
        default:
            d(Variety.pick(["How did you come to respond on \(s.day)?", "Officer, how did you get involved?", "What brought you there?", "What brought you to the scene on \(s.day)?", "Tell the court how you came to be there.", "How did you learn something had happened?", "Officer, what were you doing when the call came in?", "What was your assignment that day?", "How were you dispatched?"], rng: &rng),
              facts.setting == .drugs && facts.mentions(["undercover", "controlled buy", "controlled purchase", "informant"])
                ? "I was assigned to the arrest team for a planned purchase \(s.place). When the detective gave the signal I moved in, at about \(s.arrivalTime ?? "the time of the buy")."
                : "I was on patrol in \(s.town) when dispatch sent me to a call reporting \(Investigations.incidentNoun(facts, charges: ctx.charges)) \(s.place). I got there at about \(s.arrivalTime ?? "a few minutes later").")
            d(Variety.pick(["What did you see when you arrived?", "Describe what you found.", "What was going on when you got there?", "What did you find when you got there?", "What was the scene like when you arrived?", "Tell the court what was in front of you.", "What did you observe on arrival?", "Describe the scene as you saw it.", "What was happening when you pulled up?"], rng: &rng), arrivalScene(ctx, rng: &rng))
            d(rng.pick(["What did you do?", "What were your first steps?", "What did you do once you got there?", "What was the first thing you did?", "How did you handle the scene?", "What actions did you take?", "What was your response?", "What did you do after you arrived?"]),
              Variety.pick(["Checked on everyone's safety, separated the people present, secured the area, and called for a detective and evidence technicians.",
                        "I made sure no one was still in danger, called for EMS, and kept everyone who'd seen anything from leaving.",
                        "Set up tape, started a scene log, and kept witnesses apart until investigators arrived.", "I made sure everyone was safe, kept people from walking through the area, and asked dispatch to send investigators.", "Confirmed no one else was hurt, kept the crowd back, and wrote down who was there.", "I secured the entrance and exits, started a log, and radioed for supervisors and evidence technicians.", "I took control of the scene, kept people out of it, and waited for the detectives.", "I checked for injuries, requested more units, and separated anyone who'd seen what happened.", "I cleared the area, kept it undisturbed, and began identifying witnesses."], rng: &rng))
            // When the victim knows the defendant (a neighbor, tenant, former partner...), the victim names them at the scene.
            let victimKnowsDefendant = !facts.identity
                && ((ctx.victim != nil && facts.mentions(["neighbor", "roommate", "coworker", "former ", "ex-", "tenant", "landlord", "employer", "boyfriend", "girlfriend", "spouse", "husband", "wife", "relative", "brother", "sister", "cousin", "his friend", "her friend", "argued", "dispute", "grudge"]))
                    || facts.mentions(["banned", "written notice", "trespass notice", "warned", "owner told", "told in writing"]))
            let named = ctx.report.howIdentified.contains("to the first officer") || victimKnowsDefendant
            d(rng.pick(["Did anyone speak with you?", "Did anyone tell you what happened?", "Did anyone approach you at the scene?", "Did you talk with anyone there?", "Were there any witnesses who talked to you?", "What did people tell you when you arrived?", "Did anyone offer you information?", "Did anybody give you a description of what happened?"]),
              named ? "\(ctx.victim ?? "One person") did, and gave me \(dl)'s name." :
                rng.pick(["A few people. They gave a description, but no names that night.", "People were talking over each other. I wrote down what I could and got contact information.", "Several people. They described what they saw, but nobody gave me a name.", "A couple of bystanders. I took their numbers for the detectives.", "Yes, a few. Their accounts weren't all the same, and I noted that.", "A handful of people spoke up. I took their statements down and passed them along.", "Some did. Nobody I spoke to that night knew anyone's name.", "Yes. I collected contact information from everyone who offered to talk."]))
            if !collected.isEmpty && rng.chance(0.6) {
                d(rng.pick(["Was anything collected while you were there?", "Did you see any physical evidence?", "Did evidence technicians collect anything?", "Was any evidence gathered at the scene?", "Did you see anything collected while you were present?", "Was anything taken into evidence?", "Were any items logged while you were there?", "Did anyone collect anything in your presence?"]),
                  "The technicians collected \(collected.map { $0.phrase }.prefix(2).joined(separator: " and ")). I stood by and kept the scene log.")
            }
            crossPool += [("You didn't see any crime being committed, did you?", "No. It was over when I got there."),
                          ("You arrived after the people involved had time to talk to each other?", "Some of them, yes."),
                          ("Did anyone at the scene name \(dl) to you?", named ? "Yes. I've said so." : rng.pick(["Not by name. They gave a description.", "No, not that night.", "No. Nobody gave me a name that night.", "Not to me. I got descriptions, not names.", "Not by name, no.", "No. If anyone knew a name, they didn't say it to me.", "No. The names came later, from investigators.", "Not while I was there."]))]
        }
        d(rng.pick(["Was your body camera running?", "Is any of this on video?", "Do you have body camera footage of this?", "Did you record any of this?", "Was your camera on during this?", "Is there video of what you've described?", "Did your body camera capture any of it?", "Was any of this recorded?"]),
          late ? "Yes. I activated it about two minutes after I \(facts.origin == .stop ? "walked up to the car" : "arrived")." : rng.pick(["Yes, from the moment I got out of the car.", "Yes. Body camera and dash camera both.", "Yes. It was running the entire time.", "Yes. I turned it on as I responded, before I made contact with anyone.", "Yes. It was recording when I walked up and stayed on.", "Yes. The camera was on from the start.", "Yes. It was recording through my whole contact.", "Yes. I always activate it when I arrive."]))
        if late { crossPool.append(("So the first two minutes aren't on video?", "That's right.")) }
        crossPool.append(("Did you write down what people told you word for word?", "I wrote down the substance. Not every word."))
        for (q, a) in rng.pick(crossPool, count: rng.int(2...4)) { c(q, a) }
        if rng.chance(0.6) {
            ex.append(.init(phase: .redirect, examiner: .prosecution, question: rng.pick(["Is your report accurate?", "Did you record what you saw accurately?", "Is what you wrote in your report true?", "Does your report fairly reflect what happened?", "Did you write your report truthfully?", "Is your report complete?"]),
                            answer: rng.pick(["Yes. I wrote it that night, while it was fresh.", "Yes. Everything I saw is in it.", "Yes. I wrote it from my notes and my memory of the night.", "Yes. I wrote it before the end of my shift.", "Yes. It's accurate to the best of my knowledge.", "Yes. I took care to write down only what I saw and heard.", "Yes. I reviewed it again before today, and it's right.", "Yes. I'd stand behind every line of it."])))
        }
        return witness(name: name, role: facts.origin == .stop ? "Arresting officer, \(agency)" : "Responding officer, \(agency)", side: .prosecution, exchanges: ex)
    }

    private static func arrivalScene(_ ctx: Context, rng: inout SeededRNG) -> String {
        let s = ctx.sheet
        let light = Clock.partOfDay(s.time) == "night" ? rng.pick(["It was dark; the light was from a streetlight and my headlights.", "It was dark except for the storefront lights.", "It was dark, and the only light came from porch lights and my spotlight.", "It was dark, with the glow of a few windows and the emergency lights.", "It was dark, and I relied on my flashlight and the scene lighting.", "It was dark, but the area was lit by a nearby gas station.", "It was dark, and the only thing I could see well was what was under my flashlight.", "It was night, with the street lighting spotty on that stretch."]) : "It was daylight."
        let what: String
        switch ctx.setting {
        case .road:
            what = rng.pick(["Two vehicles off the road, one on its side. People were out of their cars, some on the phone with 911.",
                             "A vehicle in the ditch with front-end damage, debris across both lanes, and people standing on the shoulder.", "A pickup stopped crosswise in the road and a sedan with the front end crushed. A few people were standing in the lane waving cars around.", "One car on the shoulder with the airbags out, and another still in the roadway with its hazards flashing.", "A car against the guardrail with the driver's door open, and debris across the pavement.", "Two cars in the roadway, one spun around facing the wrong way, and glass everywhere.", "A vehicle rolled onto its roof in the ditch, and people were climbing down to check on it.", "A truck nose-down in a drainage ditch and a car stopped sideways with its lights still on."])
        case .drugs where ctx.facts.mentions(["undercover", "controlled buy", "controlled purchase", "informant"]) && !ctx.fatal:
            what = rng.pick(["The arrest team was already out of the cars, with the person held beside the vehicle where the sale had been made.", "A parking area with the detective's team around one car, and the person who had made the sale on the ground with hands behind the back.", "The detective gave me the signal, and when I arrived two officers had the person against the car and the money was on the seat."])
        case .drugs:
            what = !ctx.fatal ? rng.pick(["A few people standing in the driveway and someone yelling from the porch.", "People gathered at the street, and a car idling in front of the house with its doors open.",
                                           "A porch with several people on it, a screen door hanging open, and music coming from inside.",
                                           "People in the yard who went quiet when the cruiser pulled up, and a man holding the front door.", "A group on the lawn, some of them backing toward the street as we arrived."])
                : rng.pick(["A small crowd outside a house, and someone doing CPR inside.", "People in the yard, and one person on the floor inside not responding.", "A few people standing in the driveway and someone yelling from the porch.", "Several people outside a house and one person on the kitchen floor who wasn't responding.", "People gathered at the street, and a person on the ground at the front door.", "A porch full of people, a screen door hanging open, and someone being attended to inside.", "People yelling in the yard, and one person sitting on the steps holding their head.", "A crowd on the lawn and a person inside who was struggling to breathe."])
        default:
            switch ctx.facts.category {
            case .property:
                let law = ctx.charges.first?.lawID.lowercased() ?? ""
                if law.contains("larcenymerchant") || (ctx.facts.mentions(["shoplift", "register", "checkout", "ran out", "left without paying", "walked out"]) && !law.contains("burglary") && !law.contains("trespass")) {
                    what = rng.pick(["A store employee holding the merchandise and pointing toward the door, and the person waiting near the front counter.", "The clerk had the person at the front of the store, and the items were on the counter.", "A manager standing with the person by the register, with the merchandise set out on the counter.", "The store employee met me at the door and showed me where the items had been, with the person still inside."])
                } else if law.contains("trespass") {
                    what = rng.pick(["The owner met me at the edge of the property and pointed out where the person had been told to stay away from.", "The owner stood waiting with the notice in hand and showed me where the person had been.", "The owner showed me where the person had been standing and the notice that had been sent, and nothing on the property was damaged."])
                } else if law.contains("injury") {
                    what = rng.pick(["The damage was plain to see, and the owner was standing next to it waiting for me.", "The owner showed me the damage and the place it happened, and there was no one else around.", "Visible damage to the property, with the owner pointing out what had been there before."])
                } else if !(law.contains("burglary") || law.contains("feloniousbe") || law.contains("breakingvehicle")) {
                    what = rng.pick(["The owner met me outside and showed me where the property had been. Nothing else was disturbed.", "The place where the property had been was empty, and the owner was waiting there for me.", "The owner showed me the empty spot and the camera, and nothing else had been touched."])
                } else {
                what = rng.pick(["The rear door was open and the frame was splintered. Nobody was inside.", "Glass on the ground and a door standing open.", "A broken window at the back of the house, with glass inside on the floor. Nobody was around.", "The garage door was forced up and tools were scattered on the floor.", "A pried-open side door and drawers pulled out in the bedroom.", "The front door was kicked in, and the lock was lying on the porch.", "A cut screen and an open window, with muddy footprints across the carpet.", "A forced entry at the back, a ransacked room, and no sign of anyone."])
                }
            case .violent, .robbery, .family:
                if let v = ctx.victim, ctx.fatal {
                    what = rng.pick(["\(v) was on the ground, not responding. A bystander was doing CPR, and I took over until EMS arrived.", "EMS was already working on \(v). People nearby were shouting, and someone was crying.", "\(v) was on the ground and not breathing. I started compressions until the ambulance got there.", "Paramedics were kneeling over \(v), and a small crowd had gathered. Several people were in tears.", "\(v) was lying still, with a neighbor kneeling nearby trying to get a response.", "\(v) was unresponsive when I got there. A man from next door was still giving CPR.", "EMS and a fire crew were already there. \(v) was being worked on, and no one was talking.", "I found \(v) on the ground and not responding. People were gathered around, and one person was screaming."])
                } else if let v = ctx.victim {
                    what = rng.pick(["\(v) was there, hurt and upset. Two or three other people were standing around.", "A small crowd, and \(v) being helped by a bystander.", "A bystander was sitting with \(v), who was crying and could barely get words out.", "\(v) was upset and holding an injured arm, and several people were trying to help.", "\(v) was standing near the door, visibly shaken, with a couple of neighbors close by.", "\(v) was upset and pacing, and talking to anyone who would listen.", "A few people had gathered around \(v), who was clearly shaken.", "\(v) was on the porch, upset, while a neighbor held a phone to call for help."])
                } else {
                    what = rng.pick(["A small crowd and a lot of shouting.", "People standing around, and a lot of talking at once.", "A handful of people in the yard, all trying to tell me different things.", "Neighbors on porches and a few people in the street, some of them upset.", "A group gathered near the entrance, some shouting and some quiet.", "People out in the road, talking loudly and pointing toward the house.", "Several people standing in a circle, and one person trying to calm the others.", "A tense group of people and a lot of noise."])
                }
            default:
                what = rng.pick(["A crowd, some shouting, and people pointing in different directions.", "A small group of people, most of them on their phones.", "A few people outside, talking in low voices and watching what was going on.", "Two groups of people, standing apart and watching each other.", "People coming out of nearby buildings to see what was happening.", "A small crowd on the sidewalk, and a manager waiting for me at the door.", "Several people milling around, and one waving me over as I pulled up.", "Some bystanders and a lot of confusion about what had happened."])
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
        // A toxicologist tests blood for alcohol in an impaired-driving case, and for drugs everywhere else.
        let alcohol = discipline == .toxicology && alcoholCase(items, ctx: ctx)
        let postmortem = discipline == .toxicology && !alcohol && ctx.fatal
        let degree: String
        switch discipline {
        case .drugChemistry, .toxicology, .fireDebris, .trace: degree = Variety.pick(["a bachelor's degree in chemistry", "a master's degree in forensic science", "a degree in biochemistry", "a bachelor's degree in analytical chemistry", "a master's degree in chemistry", "a bachelor's degree in biology and chemistry", "a master's degree in toxicology", "a degree in forensic chemistry", "a doctorate in analytical chemistry"], rng: &rng)
        case .dna: degree = rng.pick(["a master's degree in molecular biology", "a bachelor's degree in biology with graduate coursework in genetics", "a bachelor's degree in genetics and a master's degree in forensic science", "a master's degree in biology with a focus on human genetics", "a bachelor's degree in biochemistry and specialized DNA analysis training", "a doctorate in molecular genetics", "a degree in microbiology and the laboratory's DNA training program", "a bachelor's degree in biology and two years of supervised DNA casework training"])
        case .latentPrints: degree = rng.pick(["a bachelor's degree in forensic science and IAI certification as a latent print examiner", "a biology degree and a two-year in-house training program", "a bachelor's degree in criminal justice and IAI certification as a latent print examiner", "a chemistry degree and a supervised two-year latent print training program", "a bachelor's degree in biology and a year of supervised latent print training", "a forensic science degree and IAI certification, along with years of casework", "a degree in physical science and the laboratory's latent print training program", "a forensic science degree and certification through the International Association for Identification"])
        case .firearms: degree = rng.pick(["a bachelor's degree in chemistry and the laboratory's two-year firearms training program", "a forensic science degree and AFTE training", "a bachelor's degree in physics and the laboratory's firearms and toolmark training", "a degree in criminal justice and AFTE-based training", "a master's degree in forensic science and years of firearms examiner training", "a mechanical engineering degree and the laboratory's two-year firearms program", "a bachelor's degree in chemistry and AFTE certification", "a forensic science degree and a two-year apprenticeship in firearms examination"])
        }

        d(Variety.pick(["Where do you work, and what do you do?", "Please tell the court your name and your position.", "Where are you employed?", "Please state your name and where you work.", "Tell the court who you are and what you do.", "What is your position at the laboratory?", "Please identify yourself and your employer.", "What do you do for a living?", "For the record, your name and your occupation?"], rng: &rng),
          "\(name). I'm a forensic scientist in the \(discipline.section) section of the North Carolina State Crime Laboratory" + Variety.pick([". I've been there \(years) years.", ", for \(years) years now.", "; I've worked there \(years) years.", ", where I've been for \(years) years.", ". I joined \(years) years ago.", ". I've been with the lab \(years) years now.", ". It's been \(years) years.", ", and I've worked there for \(years) years.", "; \(years) years now."], rng: &rng))
        d(Variety.pick(["What is your training?", "Tell the court about your education and experience.", "What qualifies you to do this work?", "What is your educational background?", "Tell the court about your credentials.", "How did you train for this work?", "What degrees and training do you have?", "What's your background in this field?", "How are you qualified to give opinions here?"], rng: &rng),
          "I have \(degree). " + Variety.pick(["I pass a proficiency test every year, and I've analyzed more than \(rng.int(8...40) * 100) items.",
                                           "Before I worked cases on my own I completed a supervised training program and competency tests.",
                                           "I've testified about my work \(rng.int((years + 2)...(years * 12 + 8))) times, in state and federal court.", "I've worked under a quality system for \(years) years, with supervised competency testing before I handled casework alone.", "My work is proficiency-tested and audited, and I complete continuing education every year.", "I trained for more than a year under senior analysts before I did any case on my own.", "I've presented at professional meetings, and my work has been peer-reviewed throughout my career.", "I hold a certification in my discipline, and I renew it through continuing education.", "I've been through external proficiency testing and technical review of my work for as long as I've done this."], rng: &rng))
        if rng.chance(0.6) {
            let qcQuestion = rng.pick(["Is the laboratory accredited?", "Does the lab follow written procedures?", "Does your laboratory have quality controls?", "Is the work at your laboratory reviewed?", "What standards does the laboratory follow?", "How is quality maintained at the lab?", "Is your lab inspected by anyone outside?", "Are your results checked by anyone else?"])
            let qcAnswer = Variety.pick(["Yes. We're accredited under the ISO/IEC 17025 standard, and we're audited regularly.",
                        "Yes. Every method we use is validated and written down, and the lab is accredited and audited by an outside body.",
                        "Yes, accredited. Every report is technically reviewed by a second qualified analyst before it's released.", "Yes. Every analysis is checked against written protocols, and our instruments are calibrated and maintained on a schedule.", "Yes. We run controls with every batch, and a second examiner reviews each report before it goes out.", "Yes. The lab is inspected by an outside accrediting body, and our procedures are written and validated.", "Yes. We keep records of every step, and anything that falls outside protocol is documented and reviewed.", "Yes. Our methods follow written standards, and we're evaluated regularly on proficiency tests.", "Yes. The laboratory is accredited, and every analyst's work is peer-reviewed before it's released."], rng: &rng)
            // A "what" or "how" question gets the same facts as a plain statement, not a "Yes."
            var qcSpoken = qcAnswer
            if qcQuestion.hasPrefix("What") || qcQuestion.hasPrefix("How") {
                for lead in ["Yes, accredited. ", "Yes. "] where qcSpoken.hasPrefix(lead) {
                    qcSpoken = (lead == "Yes, accredited. " ? "The laboratory is accredited. " : "") + String(qcSpoken.dropFirst(lead.count))
                    break
                }
            }
            d(qcQuestion, qcSpoken)
        }
        if rng.chance(0.5) {
            d("Your Honor, the State tenders \(name) as an expert in \(discipline.section.lowercased()).",
              "The Court: " + rng.pick(["Without objection, the witness is accepted as an expert.", "The defense has no objection. The court accepts the witness.", "The defense does not object. The witness is accepted as an expert.", "Hearing no objection, the court recognizes the witness as an expert in the field.", "No objection from the defense. The witness may give opinions in this area.", "The court accepts the witness as an expert, with no objection from the defense.", "Very well. The witness is qualified as an expert, and the State may proceed.", "There is no objection. The court finds the witness qualified."]))
        }

        for (index, item) in items.prefix(2).enumerated() {
            let title = item.phrase
            let sent = s.labSubmitted.map { CaseDates.day($0) } ?? "the date on the request"
            d(index == 0 ? Variety.pick(["How did \(title) come to you?", "Tell the court how \(item.exhibit) reached the laboratory.", "What did you receive in this case?", "How did \(title) reach your laboratory?", "What did \(s.agency) send to you?", "Tell the court what was submitted for analysis.", "What was the first item you received?", "Describe how \(title) arrived at the lab.", "What did you get in this case?"], rng: &rng)
                         : rng.pick(["Did you also examine \(title)?", "What about \(item.exhibit)?", "Was \(title) also submitted to you?", "Did you examine anything else?", "What can you tell us about \(item.exhibit)?", "Did \(title) come to you as well?", "Were you also given \(title)?", "What happened with \(item.exhibit)?"]),
              "\(s.agency) submitted it on \(sent), " + Variety.pick(["in a sealed bag with the officer's initials across the seal.", "heat-sealed and labeled with the case number.", "with a request for analysis and a chain-of-custody form.", "in a heat-sealed evidence bag with the officer's initials and a case number.", "in a tamper-evident envelope with a signed submission form.", "in a sealed container with the evidence tag attached.", "sealed in an evidence bag with the case number and the officer's signature across the seal.", "along with a laboratory request form and the case paperwork.", "packaged and sealed, with a chain-of-custody form attached."], rng: &rng)
                + " " + Variety.pick(["The seal was intact when I opened it, and I documented that.", "I checked the seal and the labels against the request before opening it.", "Nothing about the packaging suggested tampering.", "The package was sealed when it arrived, and I noted that in my file.", "I compared the labels with the request form before I broke the seal.", "There was nothing unusual about the packaging, and the seal was unbroken.", "I inspected it on receipt and found no signs that it had been opened.", "The seal and the markings matched the paperwork when I received it.", "I recorded the condition of the packaging in my notes before I started."], rng: &rng))
            d(Variety.pick(["What did you do with it?", "How did you analyze it?", "Walk the court through your method.", "What testing did you perform on it?", "Describe your analysis for the court.", "What steps did you take once it reached your bench?", "How did you go about examining it?", "Tell the court what you did after you opened the package.", "What was your process from start to finish?"], rng: &rng), method(discipline, alcohol: alcohol, postmortem: postmortem, rng: &rng))
            d(Variety.pick(["What were your results?", "What did you conclude?", "What did the analysis show?", "What did you find?", "What were the results of your testing?", "What conclusion did you reach?", "What did you determine from your analysis?", "Tell the court what your testing showed.", "Did your testing produce a result?"], rng: &rng),
              ("\(item.detail) " + conclusionFrame(discipline, alcohol: alcohol, rng: &rng)).trimmingCharacters(in: .whitespaces))
        }
        if let back = s.labReturned {
            d(rng.pick(["When did you issue your report?", "When was your report released?", "When was your report finalized?", "When did your report go out to the agency?", "What date did you complete your written report?", "When did the agency receive your findings?", "When did you sign your report?", "On what date was your report issued?"]),
              "On \(CaseDates.day(back)). " + rng.pick(["It was technically and administratively reviewed before it went out.", "A second analyst reviewed my data and agreed with my conclusions.", "It went through technical review by a second qualified analyst, and nothing is released until that review is done.", "Another examiner checked my notes and the raw data against my conclusions before I signed.", "It went through our standard peer review before release, the same as every report from this lab.", "A reviewer who had no part in the testing went through the data line by line and signed off.", "It was reviewed by a supervisor and a second analyst, as every report here is.", "The review checked my calculations and my interpretation against the case file, and it was approved."]))
        }

        // Cross: the limits of this discipline
        var pool = crossPool(discipline, alcohol: alcohol, postmortem: postmortem, ctx: ctx, rng: &rng)
        pool.append(("Has your lab ever had to correct a result?", "Every lab has corrected errors. That's why there's a review process, and this result was reviewed."))
        pool.append(("Were there items from this case the agency never sent you?", rng.chance(0.5) ? "Yes. Some items weren't submitted for testing." : "Not that I'm aware of."))
        pool.append(("You don't know what happened to \(items[0].phrase) before it got to your lab?", "I know what the chain-of-custody form says. Before that, I'd defer to the officers."))
        for (q, a) in rng.pick(pool, count: rng.int(3...4)) { c(q, a) }
        let redirect: (String, String) = rng.chance(0.5)
            ? (Variety.pick(["Does anything you were asked on cross change your results?", "Did anything defense counsel raised change your analysis?", "Would you change anything in your report now?"], rng: &rng), Variety.pick(["No. The limits counsel pointed out are real, and they're in my report. The result is the result.", "No. I'd testify to the same result today.", "No. Nothing counsel asked changes the data. The instrument doesn't know who is asking the question.", "No. I went back over my bench notes, and they say the same thing they said the day I wrote them.", "No. Those are fair limits, and I've noted them in my report, but they don't move the result.", "No. I would sign the same report again today."], rng: &rng))
            : (Variety.pick(["Was your result confirmed?", "Do you still stand by your findings?", "After those questions, is your result the same?", "Was your result checked by anyone else?", "Does your conclusion hold up after cross-examination?"], rng: &rng), Variety.pick(["Yes. It was reviewed, and the controls ran correctly. My conclusion stands.", "Yes. A second analyst verified it, and the quality controls were within limits the day I ran it.", "Yes. It was reviewed against the raw data, and my conclusion stands as written.", "Yes. I stand by it. The controls ran correctly, and nothing counsel asked changes what the data show.", "Yes. I would give the same result today, and the second reviewer reached the same conclusion from the raw data.", "Yes. Counsel raised fair points about limits, and they're in my report, but the conclusion holds."], rng: &rng))
        ex.append(.init(phase: .redirect, examiner: .prosecution,
                        question: redirect.0,
                        answer: redirect.1))
        _ = dl
        return witness(name: name, role: "\(discipline.title), State Crime Laboratory", side: .prosecution, exchanges: ex)
    }

    private static func method(_ discipline: Discipline, alcohol: Bool, postmortem: Bool, rng: inout SeededRNG) -> String {
        switch discipline {
        case .drugChemistry:
            return Variety.pick(["I weighed it, then ran a color test as a screen and confirmed with gas chromatography-mass spectrometry, which identifies the compound by its chemical fingerprint.",
                             "Net weight first, without packaging. Then I took a representative sample and confirmed its identity by GC-MS against a reference standard run the same day.",
                             "I documented the packaging, weighed the contents, and analyzed a sample with GC-MS. The instrument's controls ran clean before and after.", "I opened the package under a hood, weighed the contents, took a sample for a color test, and then ran that sample on the GC-MS to confirm what the substance was.", "After documenting the packaging, I weighed the material on a calibrated balance and identified it by GC-MS, comparing the spectrum to a certified reference standard.", "I photographed the item as received, recorded the net weight, and confirmed the identity of the substance with instrumental analysis, not just a color test.", "A color test is only a screen, so I followed it with GC-MS. The instrument was checked with a blank and a standard before my sample ran.", "I logged the seal, weighed the substance, and ran a sample through the mass spectrometer, which I read against our library and a reference standard.", "I sampled the material according to our protocol, ran it on GC-MS with blanks on either side, and compared the result to the known standard."], rng: &rng)
        case .toxicology where !alcohol:
            let sample = postmortem ? rng.pick(["femoral blood and vitreous fluid collected at autopsy", "the autopsy blood, drawn from the femoral vein, and urine", "blood from the femoral vein, along with urine and vitreous fluid, collected at autopsy", "the postmortem femoral blood and a sample of liver tissue", "the vitreous fluid and the autopsy blood from the femoral vein", "peripheral blood collected at autopsy and the urine from the bladder", "femoral blood drawn at autopsy, together with the gastric contents", "the postmortem blood and vitreous fluid the medical examiner's office submitted"])
                                    : rng.pick(["the blood sample", "the blood and urine samples", "the whole blood specimen", "the two tubes of blood", "the blood specimen and the urine specimen", "the blood draw", "the blood kit", "the gray-top tubes of blood"])
            return Variety.pick(["I screened \(sample) by immunoassay and a broad drug panel, then confirmed and quantified each drug by liquid chromatography with tandem mass spectrometry, LC-MS/MS.",
                             "I ran \(sample) on a comprehensive drug screen, then confirmed every positive with LC-MS/MS against calibrators and controls run the same day.",
                             "Screening first, then confirmation. Each drug the screen flagged was quantified by LC-MS/MS from \(sample), with internal standards.", "I extracted \(sample), ran a broad screen for drug classes, and then confirmed and quantified each positive by LC-MS/MS using certified reference materials.", "I prepared \(sample) for analysis and screened it by immunoassay. Each class that came back positive was identified and measured by LC-MS/MS, with controls run alongside.", "Two steps: a screen on \(sample), then a confirmation on the instrument for every drug the screen suggested, quantified against a calibration curve.", "I tested \(sample) for a wide panel of drugs and metabolites, and I only report the ones that were confirmed by mass spectrometry.", "I took an aliquot of \(sample), added internal standards, and analyzed it by LC-MS/MS, comparing each peak to calibrators run the same day.", "I screened \(sample) first, then confirmed every presumptive positive by a second, more specific method before I reported anything."], rng: &rng)
        case .toxicology:
            return Variety.pick(["Headspace gas chromatography, run in duplicate with calibrators and controls. The two results have to agree within a set tolerance.",
                             "I analyzed the blood for alcohol by headspace GC, in duplicate, and screened for other drugs with an immunoassay followed by confirmation.",
                             "Two separate aliquots, each run against a calibration curve, with controls above and below the legal limit.", "I ran the blood on two different columns by headspace gas chromatography, so each result is confirmed by an independent measurement.", "Each sample was prepared twice, analyzed against a calibration curve, and run with controls at known concentrations. The results had to agree before I reported.", "I analyzed the blood for ethanol by headspace GC with an internal standard, in duplicate, and the instrument was checked with known controls the same day.", "Headspace gas chromatography, using two separate preparations of the blood and a reference standard of known alcohol concentration.", "The sample was opened, mixed, and divided into two portions. Each portion was analyzed against calibrators, and I reported the result only after both agreed.", "I tested the blood for alcohol by gas chromatography with flame ionization detection, using controls that bracket the result."], rng: &rng)
        case .dna:
            return Variety.pick(["I extracted DNA, measured how much there was, copied specific regions, and compared the resulting profile to the known reference samples.",
                             "Standard STR testing: extraction, quantitation, amplification, and capillary electrophoresis. Then a statistical comparison with probabilistic genotyping software.",
                             "I swabbed the item, developed a profile, and compared it to the reference swabs submitted with the case.", "I took cuttings from the item, extracted the DNA, measured it, and amplified the standard STR regions. The profile was read on a genetic analyzer and compared with the reference samples.", "After documenting the item, I sampled the areas most likely to hold DNA, ran the standard laboratory process, and compared the resulting profile with each known sample.", "I used our validated STR workflow with a reagent blank and a positive control alongside the evidence, then compared the evidence profile to the references.", "I swabbed the likely contact areas, extracted and quantified the DNA, and developed a profile. Interpretation was done in software that calculates the strength of the match.", "Extraction, quantitation, amplification, and electrophoresis, each step with controls. Then I compared the evidence profile to the known profiles one at a time.", "I cut a portion of the item, recovered the DNA, and generated a profile. A second analyst independently reviewed the electropherograms."], rng: &rng)
        case .latentPrints:
            return Variety.pick(["I processed the item chemically, photographed the prints that developed, and compared them to the known prints using ACE-V: analysis, comparison, evaluation, and verification by a second examiner.",
                             "I used powder and superglue fuming, captured the latent prints, and compared them side by side with the ten-print card.",
                             "ACE-V. I analyzed the latent print for quality first, compared it with the known prints, evaluated the agreement, and a second examiner verified it blind.", "I processed the surface with powder, lifted and photographed what developed, then compared each print to the known prints under magnification.", "I examined the item under an alternate light source, developed the prints, and compared them to the known ten-print cards using ACE-V.", "I fumed the item, dusted it, and photographed each latent print at scale. Prints with enough detail were compared to the known prints, then handed to a second examiner for verification.", "I assessed each latent print for quality, discarded the ones without enough detail, and compared the rest to the known prints on file.", "I used chemical processing suited to the surface, digitally captured the latent prints, and compared them to the submitted known prints, ridge by ridge.", "After processing, I compared the latent print to the known print, looking at the flow of the ridges and the small details inside them, and my result was independently verified."], rng: &rng)
        case .firearms:
            return Variety.pick(["I test-fired the firearm into a water tank, recovered the test bullets and casings, and compared their markings under a comparison microscope.",
                             "I checked the firearm for function, fired test shots, and compared the toolmarks on the test casings with the casings from the scene.",
                             "Comparison microscopy: the evidence casing on one side, a test-fired casing on the other, looking for agreement in individual markings.", "I confirmed the firearm was safe and functional, fired it into the recovery tank, and put the test cartridge cases and the evidence casing side by side under the comparison microscope.", "I examined the firearm, test-fired it, and compared the marks the gun leaves on bullets and cartridge cases with the evidence from the scene.", "I examined the class characteristics first, such as caliber and rifling, and then looked at the individual marks under the microscope.", "After the function check, I fired several test rounds, collected the bullets and casings, and compared their markings with the evidence item.", "I compared the breech face and firing pin impressions on the test casings to the ones on the casing recovered in this case.", "I test-fired the weapon, then examined the evidence and the test fires on the same microscope, mark by mark, with my notes and photographs documenting each step."], rng: &rng)
        case .fireDebris:
            return rng.pick(["I extracted the debris with a passive headspace method and ran the extract on GC-MS, comparing the pattern to known ignitable liquids.",
                             "The cans were sealed at the scene. I extracted vapors onto a carbon strip and analyzed them by GC-MS.", "I heated the sealed container, drew the vapors onto an activated carbon strip, and ran the extract on GC-MS to look for the pattern of an ignitable liquid.", "I opened the can in the lab, sampled the headspace onto a carbon strip, desorbed it with solvent, and analyzed it on the instrument.", "I extracted the sample, ran a blank and a known gasoline standard, and compared the chromatogram from this case with the known patterns.", "The debris came to me sealed. I recovered the vapors, ran them on GC-MS, and compared the pattern to our reference library of ignitable liquids.", "I examined the debris for odor and appearance, extracted what was there onto carbon, and identified the compounds with GC-MS.", "I tested for ignitable liquid residue by passive extraction, a standard method in my field, and I ran a control to make sure the can itself wasn't the source."])
        case .trace:
            return rng.pick(["Microscopy first, then instrumental comparison of the questioned sample with the known sample.",
                             "I compared the questioned material with the known samples using microscopy and infrared spectroscopy.", "I examined both samples under the microscope and compared color, shape, and structure, then used an instrument to compare their chemical makeup.", "I looked at the questioned material and the known material side by side, microscopically first, and then analyzed both by spectroscopy.", "I documented each item, compared them under magnification, and ran each through the same instrument so the data could be compared directly.", "I examined each sample with a comparison microscope and then tested them with infrared spectroscopy to see if their composition matched.", "I started with what could be seen, then tested what couldn't, looking for any difference between the questioned and known samples.", "I compared the questioned fibers to the known fibers by microscopy and instrument analysis, looking for features that would exclude a common source."])
        }
    }

    /// Blood tested for alcohol: an impaired-driving charge, or an exhibit that says so.
    static func alcoholCase(_ items: [Evidence], ctx: Context) -> Bool {
        let text = items.map { ($0.title + " " + $0.detail).lowercased() }.joined(separator: " ")
        let drugWords = ["fentanyl", "heroin", "cocaine", "methamphetamine", "oxycodone", "opioid", "overdose", "xylazine", "benzodiazepine", "drug screen"]
        let impairedCharge = ctx.lawIDs.contains { ["felonyDBV", "misdDBV"].contains($0) || $0.lowercased().contains("dwi") }
        // An overdose screen that also reports "no alcohol detected" is still a drug case.
        if drugWords.contains(where: { text.contains($0) }) { return impairedCharge && text.contains("alcohol") }
        if ["alcohol", "ethanol", "breath test"].contains(where: { text.contains($0) }) { return true }
        return impairedCharge
    }

    private static func conclusionFrame(_ discipline: Discipline, alcohol: Bool, rng: inout SeededRNG) -> String {
        switch discipline {
        case .drugChemistry: return Variety.pick(["That's a confirmed identification, not a field test.", "The identification is by GC-MS, which is the confirmatory standard.", "", "A field test is only a clue. This was identified by instrumental analysis in the laboratory.", "The substance was identified by its mass spectrum, which is far more specific than a color test.", "That identification is reported to a reasonable scientific certainty.", "The weight is the net weight, without the packaging.", "The standard I compared it to was run on the same instrument the same day.", "That identification was peer reviewed before the report was issued."], rng: &rng)
        case .toxicology:
            return alcohol ? Variety.pick(["That result reflects the blood at the time it was drawn.", "Both runs agreed within tolerance.", "", "The two measurements agreed with each other well inside our limits.", "The calibration and controls for that run were all within range.", "That's the concentration in the sample I received. The sample was stored refrigerated with a preservative.", "The result was reviewed by a second analyst before I reported it.", "I report the measurement with its uncertainty, and the uncertainty is in my report.", "The result is the average of two independent preparations."], rng: &rng)
                           : Variety.pick(["Each drug was confirmed against its own reference standard.", "The levels are in my report; what they mean for cause of death is the medical examiner's call.", "", "I report only the drugs that were confirmed by two methods.", "The concentrations are in my report along with the uncertainty for each.", "Some of these are metabolites, which is what the body makes after a drug is taken.", "What the levels mean for the person is a question for the medical examiner, not for the laboratory.", "Controls and calibrators for that run were within range.", "A second analyst reviewed each result against the raw instrument data."], rng: &rng)
        case .dna: return Variety.pick(["DNA tells you whose DNA is there. It doesn't tell you when or how it got there.", "The statistic is in my report.", "", "I can say whose DNA it is. I can't say what the person was doing when it got there.", "The profile is a match to the reference sample, and the strength of that match is in my report.", "The laboratory can tell you what profile was on the item. It can't tell you what kind of contact left it.", "A second analyst reviewed the profile and agreed with the interpretation.", "My controls were clean, so the profile comes from the item and not from the lab.", "The statistic in my report tells the court how rare that profile is, and nothing more."], rng: &rng)
        case .latentPrints: return Variety.pick(["The conclusion was verified by a second examiner.", "A print can't be dated; I can only say whose it is.", "", "Identification means the ridge detail is in sufficient agreement that the print came from that finger.", "I can tell whose finger left the print. I can't tell when it was left or what the person was doing.", "My conclusion was reviewed independently by a second certified examiner.", "The detail in this print was clear enough for a conclusion. Many prints aren't.", "The comparison is documented in my notes and photographs.", "That identification was made on the print itself, and the second examiner reached the same conclusion."], rng: &rng)
        case .firearms: return Variety.pick(["That's my opinion based on the agreement of individual markings.", "A second examiner verified the comparison.", "", "The comparison was documented with photographs and notes that another examiner can review.", "I can only say that the casing and the test fires share enough markings to come from the same gun.", "My conclusion is the examiner's opinion, reached under a validated method, and a second examiner confirmed it.", "The weapon was functional and produced consistent marks across the test fires.", "The identification is based on the agreement of fine marks, not on caliber alone.", "What I can say is limited to the evidence I examined."], rng: &rng)
        case .fireDebris, .trace: return rng.pick(["That's what the instrument data supports, and no more.", "", "I'm limited to what the sample contained. I can't say how it got there.", "The control samples came back clean, so the result is not from contamination in the lab.", "That's the pattern the instrument recorded, and it's in my report with the chromatogram.", "That's a comparison of chemistry, not a conclusion about anyone's intent.", "A second analyst looked at the data and reached the same conclusion.", "My opinion goes only as far as the laboratory results do."])
        }
    }

    private static func crossPool(_ discipline: Discipline, alcohol: Bool, postmortem: Bool, ctx: Context, rng: inout SeededRNG) -> [(String, String)] {
        let dl = ctx.dl
        switch discipline {
        case .drugChemistry:
            return [("You tested one sample. The rest you weighed?", "One representative sample from the bulk, consistent with our sampling plan."),
                    ("Your result tells the court what the substance is, not who possessed it?", "That's right. Possession isn't a chemistry question."),
                    ("You didn't test purity?", "No. North Carolina law goes by weight, not purity, so purity isn't part of the analysis."),
                    ("How long did the item sit before you tested it?", "It waited in the queue. It was sealed and stored in the vault the whole time.")]
        case .toxicology where !alcohol:
            let person = postmortem ? (ctx.victim.map { $0.components(separatedBy: " ").last ?? $0 } ?? "the decedent") : dl
            var pool: [(String, String)] = [
                ("Your report shows more than one drug in \(person)'s blood?", rng.pick(["It does. I report every drug I confirm.", "Yes, and I listed each of them with its level.", "Yes. I list every drug and metabolite I can confirm, along with its level.", "It does. A full panel often shows several substances, and I report all of them.", "Yes. There were several, and the levels for each are in the table in my report.", "That's correct. I can't tell you which one mattered most, only what was present.", "Yes. I don't leave out anything I can confirm, whether or not it's relevant to the charge.", "Yes, more than one, each confirmed separately."])),
                ("There's no fixed fatal level for fentanyl, is there?", "No. Tolerance varies widely. Levels in fatal and non-fatal cases overlap."),
                ("You can't tell the court where the drugs came from or who supplied them?", "No. Chemistry tells you what's in the blood, not how it got there."),
                ("You can't say when the drugs were taken?", rng.pick(["Not precisely. The ratio of parent drug to metabolite gives a rough idea, nothing more.", "Only broadly. I can't give the court a time.", "No. Blood levels depend on dose, tolerance, and how the body handles the drug. I can't back out a time of use.", "I can't give the court a time of ingestion. All I can say is what was in the sample when it was collected.", "Only within a wide window, and I wouldn't want to commit to one.", "No. Nothing in a single blood sample gives an exact time.", "That's beyond what a single sample can tell me.", "The presence of a metabolite tells me the drug had been in the body for a while, but not for how long."]))]
            // Fatal levels only come up when someone died.
            pool.removeAll { $0.0.contains("fatal level for fentanyl") && !postmortem }
            if postmortem {
                pool.append(("Drug levels can change in the body after death?", "Postmortem redistribution is real. That's why we test femoral blood, which is less affected."))
                pool.append(("Cause of death isn't your opinion to give?", "Correct. That's the medical examiner's determination. I report what's in the blood."))
            }
            return pool
        case .toxicology:
            var pool: [(String, String)] = [
                ("Your number is the level when the blood was drawn, not when \(dl) was driving?", "Correct. I measured the sample I received."),
                ("Alcohol can still be absorbing after someone stops drinking?", "It can. Whether it was still absorbing depends on facts I don't have."),
                ("You didn't do a retrograde extrapolation?", "I wasn't asked to, and it would require assumptions about drinking and food I can't verify.")]
            if ctx.facts.mentions(["hospital"]) { pool.append(("Hospital serum results run higher than whole blood, don't they?", "Serum values run higher, yes. My result is on whole blood.")) }
            return pool
        case .dna:
            return [("DNA can be transferred by touch, without the person ever being there?", "Secondary transfer happens. I can't tell you how the DNA got there."),
                    ("The sample was a mixture?", rng.pick(["There was a minor contributor I couldn't interpret.", "A two-person mixture. The major profile is the one I reported.", "The sample had more than one person's DNA, and I reported only what I could interpret reliably.", "It was a mixture, yes. The major contributor was clear and the minor one was too low to use.", "Yes, a mixture of at least two people, and the report describes how I handled it.", "There were low-level traces from another person that were below what we're able to report.", "It was a mixture, and I used probabilistic software to evaluate it.", "Yes. Items handled by several people often produce mixtures."])),
                    ("You can't say when the DNA was left?", "No. DNA doesn't carry a date."),
                    ("Was the unknown profile ever run through CODIS?", rng.pick(["It didn't meet the upload criteria.", "Not that I'm aware of.", "I didn't run it. That's not a decision made at my bench.", "A profile has to meet specific quality standards before it can be searched, and I don't know whether this one did.", "I only compared it to the reference samples I was sent. I wasn't asked to search any database.", "That would be a separate request, and I don't have a record of one in this case.", "The profile was partial, which limits what can be done with it.", "No. My comparison was only to the known samples submitted."]))]
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
            seen = Variety.pick(["Shows up early, stays when we're short. I've trusted \(dl) with the keys and the cash drawer.",
                             "When we had layoffs, \(dl) was one of the people I fought to keep.",
                             "Reliable. If \(dl) says something's done, it's done.", "When a deadline hits, \(dl) is the first one in and the last to leave, and never complains about it.", "New hires get sent to \(dl) to learn the job, because everyone knows \(dl) will show them the right way.", "I've never had a complaint from a customer about \(dl). I've had several compliments.", "\(dl) covered for a coworker whose child was sick, and never asked for anything in return.", "In all the time I've supervised \(dl), I've never had to ask twice for anything.", "When the register came up short once, \(dl) was the first to tell me and help me sort out what happened."], rng: &rng)
        case .instructor:
            role = "\(dl)'s instructor at \(job?.employer ?? "school")"
            howKnown = "\(dl) has been in my classes for \(rng.int(2...4)) semesters."
            seen = rng.pick(["Turns in the work, asks good questions, helps the students who are struggling.", "Quiet, but the kind of student other students go to for help.", "\(dl) is never late and never unprepared, and has stayed after class to help others with the material.", "A respectful student. In all the time I've had \(dl) in class, I've never seen a flash of temper.", "\(dl) works hard, holds down a job and still turns in the assignments on time, which a lot of students can't do.", "\(dl) is the first to volunteer when a group needs someone to take the lead, and the one who makes sure everyone gets heard.", "When another student was upset in my class last spring, \(dl) was the one who sat with that student after the lecture.", "My other students look up to \(dl). That says more than any grade I could give."])
        case .formerBoss:
            role = "\(dl)'s former employer at \(pastJob?.employer ?? "a previous job")"
            howKnown = "\(dl) worked for me as \(withArticle(pastJob?.title.lowercased() ?? "an employee")), \(pastJob?.years ?? "for a few years")."
            seen = Variety.pick(["I'd hire \(dl) back tomorrow.", "Never a write-up. Not one.", "When \(dl) left, it was for a better job, and I gave a good reference.", "\(dl) was one of the most dependable people I ever had on my payroll, and I told everyone that.", "I trusted \(dl) to open and close the place, and nothing was ever missing.", "Customers asked for \(dl) by name. I can't say that about many employees.", "\(dl) took on extra shifts without being asked, and always made sure the work was finished right.", "There was never an incident with \(dl) in all the time I knew \(dl). Never a complaint, never a call.", "I'd write the same recommendation today that I wrote when \(dl) left."], rng: &rng)
        case .pastor:
            role = "\(dl)'s pastor"
            howKnown = "\(dl) has been part of our congregation for \(years) years, and volunteers at the food pantry most weekends."
            seen = rng.pick(["When the pantry ran short last winter, \(dl) organized a drive on their own.", "I've watched \(dl) with the families who come to us. Patient. Respectful.", "I've seen \(dl) unload trucks at six in the morning in the cold, and then stay to help families carry their boxes to their cars.", "When one of our older members was in the hospital, \(dl) took meals to the house and never mentioned it.", "\(dl) sits with the members who have nobody else, and listens. I don't see that often.", "Our youth group trusts \(dl). The children talk to \(dl) in ways they don't with most adults.", "When we had a fire in the fellowship hall, \(dl) was there that same night to help us clear things out.", "Through every hard season this congregation has had, \(dl) has been among the first to show up."])
        case .coach:
            role = "Fellow youth soccer coach"
            howKnown = "We've coached kids' soccer together in \(ctx.sheet.town) for \(years) seasons."
            seen = rng.pick(["I've seen \(dl) with a team of nine-year-olds after a bad loss. Never lost that temper once.", "Parents ask for \(dl)'s team. That tells you something.", "I've watched \(dl) calm down a parent who was shouting from the sideline, and do it with respect.", "\(dl) makes sure the kid who sits on the bench gets playing time, no matter what the score is.", "When a child on our team got hurt last season, \(dl) was the first one on the field and stayed with the family until the ambulance came.", "In all the seasons I've coached beside \(dl), I've never heard a raised voice at a child.", "\(dl) pays for the cleats for the kids whose families can't afford them, and has never wanted anyone to know.", "The kids line up to shake \(dl)'s hand after every game, win or lose."])
        case .neighbor:
            role = "\(dl)'s longtime neighbor"
            howKnown = "We've lived next door to each other for \(years) years."
            seen = Variety.pick(["Checks on my mother when I'm out of town. Shovels the walk without being asked.", "We look out for each other's houses. \(dl) has a key to mine.", "Quiet. Friendly. The kind of neighbor you hope for.", "When my car broke down last year, \(dl) drove me to work for two weeks and wouldn't take gas money.", "\(dl) brought soup over when I had the flu and never made a thing of it.", "We've had cookouts in each other's yards for years, and I've never heard a harsh word from \(dl).", "When the big storm took a tree down on my fence, \(dl) was out there with a chainsaw before I'd even called anyone.", "\(dl) keeps an eye on the kids on our street and has never once raised a voice at them.", "When I was laid off, \(dl) was the first person at my door asking what I needed."], rng: &rng)
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
        d(rng.pick(["Please tell the court your name.", "Would you introduce yourself?", "State your name for the record, please.", "Would you tell the court your name?", "Please introduce yourself to the court.", "Could you give the court your full name?", "Who are you, please?", "Will you tell us your name?"]), "\(name).")
        d(rng.pick(["How do you know \(dl)?", "What's your connection to \(dl)?", "How long have you known \(dl)?", "What is your relationship to \(dl)?", "In what capacity do you know \(dl)?", "How did you come to know \(dl)?", "Tell the court how you and \(dl) are acquainted.", "How are you acquainted with \(dl)?"]), howKnown)
        d(Variety.pick(["What have you seen of \(dl) in that time?", "Tell the court what \(dl) is like.", "How would you describe \(dl)?", "What is \(dl) like to deal with?", "What have you observed about \(dl)'s character?", "What kind of person is \(dl)?", "Tell the court what you've seen of \(dl)'s character.", "What has been your experience with \(dl)?", "What stands out to you about \(dl)?"], rng: &rng), seen)
        d(rng.pick(["Do you know \(dl)'s reputation in the community for \(trait)?", "What is \(dl)'s reputation for \(trait)?", "Are you familiar with \(dl)'s reputation for \(trait) among the people who know \(dl)?", "Among those who know \(dl), what is said about \(dl)'s \(trait)?", "Is there a reputation in the community for \(dl) when it comes to \(trait)?", "How is \(dl) regarded by others for \(trait)?", "Have you heard other people talk about \(dl)'s \(trait)?", "What do people in the community say about \(dl)'s \(trait)?"]),
          Variety.pick(["Good. People trust \(dl).", "I've never heard a bad word about \(dl) on that score.", "Excellent. Ask anybody who knows \(dl).", "Very good. Anyone who has dealt with \(dl) will tell you the same thing.", "Solid. I've heard \(dl) described as someone people can count on.", "As far as I know it's a good one, and I've never heard anything to the contrary.", "Everyone I know who knows \(dl) speaks well of \(dl) on that score.", "It's a strong reputation, and I think a deserved one.", "People around here think highly of \(dl)."], rng: &rng))
        d(rng.pick(["Do you have your own opinion about \(dl)'s \(trait)?", "And your personal opinion?", "Is that also your own view?", "What is your own opinion of \(dl)'s \(trait)?", "Setting reputation aside, what do you think yourself?", "Based on what you've seen yourself, what is your opinion of \(dl)'s \(trait)?", "Do you share that view?", "What do you personally think of \(dl)'s \(trait)?"]),
          Variety.pick(["I do. I'd stake my own name on it.", "In my opinion, \(dl) is as \(trait == "peacefulness" ? "gentle" : "honest") a person as I know.", "My opinion is the same as everyone else's.", "Yes, and it's a good one. I've seen nothing that would make me think otherwise.", "I think very highly of \(dl) on that point, and I have for a long time.", "After all these years, my opinion is that \(dl) can be trusted.", "I have no doubts about \(dl)'s character, and I'd say so anywhere I was asked.", "From everything I've seen firsthand, \(dl) is exactly who people say \(dl) is.", "I'd say the same thing if I were asked on the street. It's what I believe."], rng: &rng))
        if rng.chance(0.6) {
            let changeQuestion = rng.pick(["Has anything about \(dl) changed since the arrest?", "How has \(dl) been since this started?", "Have you noticed any change in \(dl) since this case began?", "How has \(dl) been handling all of this?", "What has \(dl) been like these past months?", "Is \(dl) the same person now as before this started?", "How have things been for \(dl) lately?", "Have you spoken with \(dl) since the arrest, and how did \(dl) seem?"])
            let changeAnswer = Variety.pick(["Quieter and worried, but \(dl) still shows up for everything.", "Not that I've seen.", "Stressed, like anyone would be. Still the same person.", "Tired, mostly. It's been hard on \(dl), but \(dl) keeps going to work and keeps going on.", "Worried sick, but still polite and still the same person underneath.", "I haven't noticed any change in how \(dl) treats people.", "More withdrawn than before, which is understandable, but still the person I've always known.", "Anxious. This has weighed on \(dl), and it shows in \(dl)'s face.", "\(dl) leans on friends more than before, and that's the only difference I can see."], rng: &rng)
            // "Not that I've seen" only answers a yes-or-no question about change; it would be a non-answer to "How has she been?"
            let asksIfChanged = changeQuestion.hasPrefix("Has anything") || changeQuestion.hasPrefix("Have you noticed") || changeQuestion.hasPrefix("Is ")
            d(changeQuestion, !asksIfChanged && (changeAnswer == "Not that I've seen." || changeAnswer.hasPrefix("I haven't noticed any change"))
                ? "Worried and worn down, but still the same person underneath, and still showing up for everything." : changeAnswer)
        }

        var pool: [(String, String)] = [
            ("You weren't there when this happened, were you?", "No."),
            ("You don't know what \(dl) does when you're not around?", "Nobody knows that about anybody. I know who I've seen."),
            ("Did you talk with \(dl)'s lawyer before testifying today?", "Once, to find out when to be here."),
            ("You haven't seen the evidence in this case?", "No. I can only tell you about the person I know.")
        ]
        if let prior = ctx.defendant.priors.last {
            pool.append(("Did you know \(dl) was convicted of \(prior.offense.lowercased()) in \(prior.year)?",
                         Variety.pick(["I knew there was something years ago. People change.", "No, I didn't know that.", "I heard about it. That isn't the person I know.", "I'd heard something about it, but never from \(dl). All I can tell you is what I've seen in the years I've known \(dl).", "Yes, I knew about that. It doesn't match the person I see week after week.", "No, I wasn't aware of that, and it surprises me.", "I knew. \(dl) told me about it a long time ago, without my asking.", "I'd heard about it. My opinion is based on what I've seen with my own eyes.", "That's news to me. I'd have to think about it, but I haven't seen anything like it from \(dl)."], rng: &rng)))
        }
        if tie == .supervisor || tie == .formerBoss {
            pool.append(("If \(dl) were convicted, you'd lose a good worker. You have a stake in this.", "I'd lose a good worker. I'd still tell you the truth."))
        }
        switch ctx.setting {
        case .paper: pool.append(("You've never seen \(dl)'s bank records, have you?", "No. I've seen how \(dl) handles responsibility."))
        case .road: if ctx.facts.impaired { pool.append(("Have you ever seen \(dl) drink?", rng.pick(["At a cookout. A beer or two.", "Not much. I don't really socialize with \(dl) that way.", "Now and then, a glass of wine with dinner.", "I've seen \(dl) have a beer at a ball game. I've never seen \(dl) drunk.", "Socially, yes, a drink or two. Never anything that worried me.", "I've never seen \(dl) have more than a couple of drinks.", "Occasionally. I have never seen \(dl) out of control.", "Yes, at birthdays and holidays. Always responsibly, as far as I've seen."]))) }
        case .drugs: pool.append(("You don't know who \(dl) spends evenings with, do you?", "Not every evening, no."))
        case .scene: if trait == "peacefulness" { pool.append(("You've never seen \(dl) angry?", "I've seen \(dl) frustrated. Never violent.")) }
        }
        for (q, a) in rng.pick(pool, count: rng.int(2...4)) { c(q, a) }
        if rng.chance(0.5) {
            ex.append(.init(phase: .redirect, examiner: .defense, question: "Does anything you heard on cross change your opinion?",
                            answer: Variety.pick(["No.", "No. I know \(dl).", "No. I came here because I believe it.", "No. What I told you is what I know to be true.", "No. If anything, I feel the same as when I walked in.", "No. Nothing the prosecutor asked is something I hadn't already thought about, and my opinion is the same.", "No. I came to tell the court the truth about the person I know.", "No. That's what I came here to say, and I'd say it again.", "No. My opinion of \(dl) hasn't changed."], rng: &rng)))
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
        let occupation = ctx.defendant.occupation.lowercasedPhrase
        let work: String
        if occupation.contains("unemployed") { work = "I'm between jobs right now." }
        else if occupation.hasPrefix("retired") { work = "I'm \(occupation.withIndefiniteArticle)." }
        else if let job = profile?.jobs.first(where: { $0.current }) { work = "I work as \(withArticle(job.title.lowercased())) at \(job.employer)." }
        else { work = "I work as \(withArticle(occupation))." }
        d(Variety.pick(["Please tell the court your name and a little about yourself.", "Tell the court about yourself.", "Who are you?", "Would you introduce yourself to the court?", "Please state your name and tell the court a little about your life.", "Tell us who you are.", "Start by telling the court your name and where you live.", "Tell the court a bit about your background.", "Who are you, and what do you do?"], rng: &rng),
          "\(base.name). I'm \(ctx.defendant.age). " + work + (profile.map { " " + $0.residence.replacingOccurrences(of: "Rents", with: "I rent").replacingOccurrences(of: "Lives", with: "I live").replacingOccurrences(of: "Owns", with: "I own").replacingOccurrences(of: "Has moved", with: "I've moved") } ?? ""))
        if let profile, rng.chance(0.6) {
            d(rng.pick(["Tell the court about your family.", "Who's at home with you?", "Tell the court about your family situation.", "Who are the people closest to you?", "Is there family you want the court to know about?", "What's your family like?", "Tell the court who your people are.", "Who is your family?"]), Self.familyAnswer(profile, rng: &rng))
        }
        if let victim = victim, ctx.facts.mentions(["partner", "spouse", "ex-", "best friend", "neighbor", "coworker", "roommate", "boyfriend", "girlfriend", "husband", "wife"]) {
            d(rng.pick(["How do you know \(victim)?", "What was your relationship with \(victim)?", "How long had you known \(victim)?", "Tell the court about your history with \(victim).", "What was \(victim) to you?", "How would you describe things between you and \(victim)?", "How did you and \(victim) first meet?", "How well did you know \(victim)?"]),
              rng.pick(["We go back a long way. It's complicated, but I never wanted any of this.", "We were close, once. That's what makes this so hard.", "We'd known each other for years. We had our problems, but I never wished harm on anybody.", "We were in each other's lives a lot, which is why none of this makes sense to me.", "We didn't always agree, but I never wanted it to come to this.", "We'd had our share of disagreements, like anyone does, but nothing like this.", "It's a long story, and it wasn't always easy, but I never meant any harm.", "We saw each other almost every day. I'd never have wanted this to happen."]))
        }

        // That day, from the fact sheet
        if ctx.setting == .paper {
            if let org = ctx.organization {
                d(rng.pick(["What was your role at \(org)?", "How did you come to work with \(org)?", "What did your job at \(org) involve?", "What did you do for \(org)?", "Describe your duties at \(org).", "What were your responsibilities at \(org)?", "How long were you with \(org), and what did you do there?", "Tell the court about your work with \(org)."]),
                  rng.pick(["I handled the books and the day-to-day money. For years nobody had a complaint.", "I did whatever needed doing. Some of it was paperwork I wasn't trained for.", "I kept the accounts and signed off on the routine payments. Nobody ever asked me to do it any other way.", "My title said one thing, but I ended up doing a bit of everything, including the money.", "I was trusted with the checkbook because I was there every day. I never thought of it as anything but a job.", "I took over the bookkeeping when the person before me left. Nobody trained me, but nobody complained either.", "I did the deposits and paid the bills, mostly. I thought I was doing it the way I'd been told.", "Most days it was routine. I paid what needed to be paid and kept the records as best I could."]))
            }
        } else {
            let whereLine: String
            switch theme {
            case .alibi: whereLine = Variety.pick(["I was at home. My \(rng.pick(["partner", "sister", "roommate", "brother", "cousin", "mother", "grandmother", "best friend", "aunt"])) was there.", "I was at work until close, then I drove straight home.", "Nowhere near \(s.place). I was across town.", "I was at a friend's house for most of the \(Clock.partOfDay(s.time)), and several people there can tell you so.", "I was at the grocery store and then I went home and stayed in. There should be a receipt.", "I was out of town on a job that day and didn't get back until late.", "I was home with the TV on and never went out again.", "I was at my mother's house for dinner and stayed late helping out with some things.", "I was running errands across town, and I have the receipts to show where."], rng: &rng)
            case .misidentification: whereLine = rng.pick(["Not \(s.place). I've told everyone that from the start.", "I was out, but I wasn't there.", "I was never \(s.place). Whoever they saw, it wasn't me.", "I was somewhere else entirely, and I can tell you where.", "I wasn't there. I don't know who they saw, but it wasn't me.", "Not \(s.place). I was on the other side of town.", "I was somewhere else that \(Clock.partOfDay(s.time)). I've said so since the day I was arrested.", "I wasn't at that place at all, and I don't understand why anyone says I was."])
            default: whereLine = Variety.pick(["I was \(s.place), yes. I'm not going to deny that.", "I was there. I'll tell you exactly what happened.", "I was \(s.place), around \(s.time ?? "then").", "Yes, I was \(s.place). I'm not going to pretend otherwise.", "I was there, and I'll tell you everything I remember.", "I was \(s.place) that \(Clock.partOfDay(s.time)), just like they say.", "I was there. I'm not hiding that.", "I was \(s.place). Let me explain how I got there and what happened.", "That's where I was, \(s.place). I've never said otherwise."], rng: &rng)
            }
            d(Variety.pick(["Take the court back to \(s.day). Where were you?", "Where were you on the \(Clock.partOfDay(s.time)) of \(s.day)?", "Let's talk about \(s.day). Where were you?", "Where were you on \(s.day)?", "Tell the court where you were on \(s.day).", "Start with \(s.day). Where were you?", "I want to ask about \(s.day). Where were you?", "Let's begin with the \(Clock.partOfDay(s.time)) of \(s.day). Where were you?", "Where were you when this happened?"], rng: &rng), whereLine)
        }
        if let narrated = base.direct.first {
            d(Variety.pick(["Tell the court what happened.", "In your own words, what happened?", "Walk the court through it.", "Tell the court what took place.", "Tell the court your side.", "Take us through what happened, step by step.", "What happened, from the beginning?", "Describe what happened for the court.", "Tell the court what you remember."], rng: &rng), narrated)
        }
        for line in rng.pick(themeLines(theme, ctx: ctx, rng: &rng), count: rng.int(1...2)) {
            d(Variety.pick(["What were you thinking at that point?", "What happened next?", "Why?", "What do you want the court to understand about that?", "What went through your mind?", "Tell the court more about that.", "What did you do then?", "Can you explain that to the court?", "How did that moment feel to you?", "Is there more the court should know about that?"], rng: &rng), line)
        }
        if let top = ctx.strongest {
            d(Variety.pick(["The State showed the court \(top.exhibit), \(top.phrase). What do you say about that?", "Let's talk about \(top.phrase).", "How do you explain \(top.phrase)?", "The prosecutor has pointed to \(top.phrase). What is your response?", "Let's address \(top.exhibit). What can you tell the court about it?", "You've heard the evidence about \(top.phrase). What do you say to it?", "What do you make of \(top.phrase)?", "Tell the court about \(top.phrase).", "The court has seen \(top.exhibit). How does that fit with what you've told us?"], rng: &rng),
              holds ? Variety.pick(["I'm not going to pretend it isn't there. But it doesn't mean what they say it means.", "I can explain it, and I did explain it, to anyone who would listen.", "It looks bad on paper. Here's what it doesn't show: the rest of that day.", "That evidence is real, and I'm not going to pretend it isn't. What it doesn't do is prove what the State says.", "I've seen it, and I understand why it looks the way it does. There's more to the story.", "I'm not disputing that it exists. I'm disputing what they say it means.", "I've asked myself how it looks to a stranger. I'd ask you to hear the rest.", "I can explain it, and I've never changed my explanation.", "It's accurate as far as it goes. It just doesn't go far enough."], rng: &rng)
                    : Variety.pick(["I don't know how to explain that.", "I've thought about that a lot. I can't explain it.", "I don't know. I just know I didn't do this.", "I wish I had an answer for that.", "I keep going back over it, and I don't have a good explanation.", "I can see how it looks. I don't have an answer for it.", "I don't have an explanation that would satisfy anyone.", "I honestly don't know. I've asked myself the same thing.", "I can't explain it, and I know that doesn't help me."], rng: &rng))
        }
        if let day = s.interview {
            d(rng.pick(["Did you talk to the police?", "Did you speak with investigators?", "Did you give investigators a statement?", "Did you cooperate with the investigation?", "Did you agree to talk to the officers?", "Did you sit down with the detectives?", "Were you interviewed?", "Did you tell the police your side?"]), "I did, on \(CaseDates.day(day)). I told them the truth, without a lawyer, because I had nothing to hide.")
        } else {
            d(rng.pick(["Did you talk to the police?", "Why didn't you give a statement?", "Did you give the police a statement?", "Why didn't you speak with investigators?", "Did you ever sit down with the officers?", "What happened when the police wanted to question you?", "Why didn't you tell your side to the officers?", "Did the officers ask to talk with you?"]), rng.pick(["My lawyer told me not to, so I didn't.", "I asked for a lawyer. I was scared, and I'd been told that's what you do.", "I didn't say anything. I was advised that the best thing was to wait and tell it here, under oath.", "I asked to talk to a lawyer first, and they stopped asking. That's my right.", "I was told to let my lawyer handle it, and that's what I did.", "I didn't want to say something wrong when I was that upset, so I waited.", "My lawyer said anything I said could be twisted, so I kept quiet until today.", "I was afraid of making it worse, so I did what I was told and stayed quiet."]))
        }
        d(rng.pick(["Did you do what you're charged with?", "Did you commit this crime?", "Are you guilty of what the State says?", "Did you do what the State accuses you of?", "Did you commit the offense you're charged with?", "Is the State's account of what you did true?", "Let me ask you plainly: did you do this?", "Are you responsible for this crime?"]),
          theme == .accident || theme == .sober ? "Not the way they say it. I'm sorry for what happened. I didn't commit a crime." : Variety.pick(["No.", "No, Your Honor.", "No. I didn't.", "No. I did not do this.", "No, Your Honor. I did not commit this crime.", "No, I didn't, and I'll say that as many times as I'm asked.", "No. I would never have done this.", "No, Your Honor, I did not.", "No. I did not do what they've charged."], rng: &rng))
        if base.direct.count > 1 {
            d(rng.pick(["Why did you decide to testify?", "Is there anything else you want the court to know?", "Why did you want to take the stand?", "What would you like the court to know before you step down?", "Is there something more you want to say?", "Why is it important to you to speak here today?", "Is there anything you haven't had the chance to tell the court?", "What do you want the court to take from your testimony?"]), base.direct[1])
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
                         holds ? Variety.pick(["I can. It's not what it looks like, and I told my lawyer the same thing the day I saw it.", "There's an innocent reason for that, and I've given it.", "I explained that already. Nothing about it changes.", "I can. It looks worse than it is, and the explanation is simple when you hear all of it.", "Yes. That has an ordinary explanation, and I gave it the first chance I had.", "It isn't what the State says. I can walk you through exactly what it was.", "I can explain that, and my explanation hasn't changed since the day I first heard about it.", "Yes, and it's not complicated. People read things into it that aren't there.", "I can. I've gone over it with my lawyer more times than I can count, and it comes out the same every time."], rng: &rng)
                               : Variety.pick(["I... I don't know how to explain that.", "I can't. I wish I could.", "I don't remember it that way.", "I've tried to figure that out myself. I don't have a good answer.", "I wish I could give you something better. I can't.", "I can't say. I don't remember it the way you're describing it.", "I know how it looks, and I don't have an answer for it.", "I've thought about that more than anything else, and I still can't explain it.", "I don't know. I really don't."], rng: &rng)))
        }
        if let day = s.interview {
            pool.append(("When you spoke to \(s.lead) on \(CaseDates.day(day)), you didn't say any of this, did you?",
                         holds ? "I said the same thing. Read the transcript." : "I was nervous. I didn't say it right."))
        }
        let impeachable = ctx.defendant.priors.filter { $0.ncClass.isFelony || $0.ncClass == .misdA1 || $0.ncClass == .misd1 }
        if let prior = impeachable.last {
            pool.append(("You were convicted of \(prior.offense.lowercased()) in \(prior.year), weren't you?", Variety.pick(["Yes. I did my time for that.", "Yes. That was a long time ago.", "Yes. I'm not hiding it.", "Yes. I paid for that, and I've tried to live differently since.", "Yes, that's right. It's the reason I'm being careful about every word I say today.", "Yes. I'm not proud of it, and it has nothing to do with what happened here.", "Yes. I made a mistake then, and I owned up to it.", "Yes. It's part of my record, and I won't pretend it isn't.", "Yes. I was younger and I made a bad decision, and I took the consequences."], rng: &rng)))
        }
        switch ctx.setting {
        case .paper where ctx.state.contains(where: { ev in ["debt", "behind", "bills", "loan", "overdue", "gambling"].contains { word in (ev.title + " " + ev.detail).lowercased().contains(word) } }):
            pool.append(("You were behind on your own bills that year, weren't you?", holds ? "Some months. Lots of people are." : "...Yes."))
        case .drugs where ctx.state.contains(where: { ev in ["cash", "currency", "$"].contains { word in (ev.title + " " + ev.detail).lowercased().contains(word) } }):
            pool.append(("Where did the cash come from?", holds ? "Work. I don't trust banks." : "...Some of it was from work."))
        case .road: if ctx.facts.impaired { pool.append(("How many drinks did you have that night?", holds ? "Two. With dinner, hours before." : "A few. I don't remember exactly.")) }
        case .scene:
            if let victim = victim, theme == .selfDefense { pool.append(("\(victim) never touched a weapon, did they?", holds ? "I didn't know that then. I saw a hand go to a pocket." : "...I thought I saw something.")) }
            else if let victim = victim { pool.append(("You were angry at \(victim), weren't you?", holds ? "I was upset. I wasn't going to hurt anybody." : "...I was angry, yes.")) }
        default: break
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
