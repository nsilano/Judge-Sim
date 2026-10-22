import Foundation

/// What the victim, or the victim's family, wants from the sentence, as the State relays it, and the close of the
/// impact statement. Each is put together from the case: who is speaking, what was lost, what they're asking for.
enum VictimVoice {

    /// Someone who speaks for the victim, with the grammar that goes with them.
    struct Speaker {
        var name: String
        var subject: String
        var plural: Bool

        func v(_ singular: String, _ pluralForm: String) -> String { plural ? pluralForm : singular }
    }

    /// Impact statements that already ask the court not to send the defendant away.
    static func asksMercy(_ impact: String?) -> Bool {
        guard let text = impact?.lowercased() else { return false }
        return ["i forgive", "not to prison", "don't send", "don't want prison", "don't want revenge"].contains { text.contains($0) }
            || text.range(of: #"don't want \S+ in (prison|jail)"#, options: .regularExpression) != nil
    }

    static func speaker(victim: String, died: Bool, child: Bool, rng: inout SeededRNG) -> Speaker {
        if died {
            return rng.pick([Speaker(name: "\(victim)'s family", subject: "They", plural: true),
                             Speaker(name: "\(victim)'s mother", subject: "She", plural: false),
                             Speaker(name: "\(victim)'s sister", subject: "She", plural: false),
                             Speaker(name: "\(victim)'s oldest son", subject: "He", plural: false),
                             Speaker(name: "\(victim)'s parents", subject: "They", plural: true),
                             Speaker(name: "\(victim)'s children", subject: "They", plural: true),
                             Speaker(name: "\(victim)'s brother", subject: "He", plural: false)])
        }
        if child {
            return rng.pick([Speaker(name: "\(victim)'s mother", subject: "She", plural: false),
                             Speaker(name: "\(victim)'s parents", subject: "They", plural: true),
                             Speaker(name: "\(victim)'s grandmother, who has custody", subject: "She", plural: false),
                             Speaker(name: "\(victim)'s father", subject: "He", plural: false)])
        }
        return Speaker(name: victim, subject: victim, plural: false)
    }

    /// The State's account of the victim's position on the sentence.
    static func position(stance: VictimStance, victim: String, defendant: String, category: LawCategory,
                         died: Bool, child: Bool, restitutionBasis: String?, cls: NCClass? = nil, rng: inout SeededRNG) -> String {
        let s = speaker(victim: victim, died: died, child: child, rng: &rng)
        let who = s.name
        let subj = s.subject
        let contact = rng.pick([
            "I met with \(who) in our office last week.",
            "I spoke with \(who) by phone on Friday.",
            "\(who) came in with our victim advocate on Monday.",
            "Our victim-witness coordinator has been in touch with \(who) since the arrest.",
            "\(who) wrote our office a letter; it's in the sentencing packet.",
            "I sat down with \(who) after the last hearing.",
            "\(who) \(s.v("has", "have")) been at every setting in this case."
        ])
        var wants: [String]
        switch stance {
        case .wantsMaximum:
            wants = [
                "\(subj) \(s.v("wants", "want")) the longest sentence the law allows.",
                "\(subj) \(s.v("is", "are")) asking for an active sentence at the top of the range.",
                "\(subj) \(s.v("asks", "ask")) the court not to consider probation in any form.",
                "\(subj) \(s.v("wants", "want")) \(defendant) in prison, and \(s.v("doesn't", "don't")) want me to soften that.",
                "\(subj) \(s.v("wants", "want")) the aggravated range, Judge, and \(s.v("has", "have")) asked me to say so plainly.",
                "\(subj) \(s.v("believes", "believe")) anything short of a long active term would be a second injury."
            ]
        case .wantsAccountability:
            wants = [
                "\(subj) \(s.v("isn't", "aren't")) asking for a number. \(subj) \(s.v("wants", "want")) \(defendant) to admit what happened.",
                "\(subj) \(s.v("wants", "want")) this taken seriously, whatever form the sentence takes.",
                "\(subj) \(s.v("leaves", "leave")) the sentence to the court, but \(s.v("wants", "want")) it on the record that this mattered.",
                "\(subj) \(s.v("says", "say")) the length matters less than \(defendant) understanding the harm.",
                "\(subj) \(s.v("would", "would")) accept probation if it comes with real conditions and real consequences.",
                "\(subj) \(s.v("wants", "want")) a sentence that means something, and \(s.v("trusts", "trust")) the court to decide what that is."
            ]
        case .wantsLeniency:
            wants = [
                "This is unusual, Judge: \(subj.lowercasedIfPronoun) \(s.v("doesn't", "don't")) want \(defendant) to go to prison.",
                "\(subj) \(s.v("asks", "ask")) the court for mercy. \(subj) \(s.v("wants", "want")) \(defendant) to get help, not a cell.",
                "\(subj) \(s.v("supports", "support")) probation with treatment, and \(s.v("has", "have")) asked me to tell the court so.",
                "\(subj) \(s.v("has", "have")) forgiven \(defendant), and \(s.v("asks", "ask")) that the sentence leave room for a future.",
                "\(subj) \(s.v("does", "do")) not want an active sentence. The State's recommendation is our own, not \(s.v("theirs", "theirs"))."
            ]
        case .none:
            return "There's no identified victim in this case."
        }
        // Most victims who ask for something name it; the numbers come from the chart for the charge.
        let specific = asks(stance: stance, cls: cls, s: s, defendant: defendant, restitution: restitutionBasis != nil, rng: &rng)
        if !specific.isEmpty && rng.chance(0.7) { wants = specific }
        var reasons: [String] = []
        if died {
            reasons = ["Nothing brings \(victim) back.", "\(subj) \(s.v("has", "have")) been to the cemetery every Sunday since.",
                       "\(subj) \(s.v("says", "say")) the hardest part is the holidays.", "There's an empty chair at every family dinner now."]
        } else if child {
            reasons = ["\(victim) is in counseling twice a week.", "\(victim) still won't sleep alone.",
                       "\(victim) changed schools after this.", "\(subj) \(s.v("says", "say")) \(victim) is a different child now."]
        } else {
            switch category {
            case .property, .robbery:
                reasons = ["\(subj) \(s.v("has", "have")) changed the locks twice.", "\(subj) \(s.v("doesn't", "don't")) feel safe at home anymore.",
                           "\(subj) \(s.v("lost", "lost")) things that can't be replaced.", "\(subj) took unpaid days off work for every court date."]
            case .whiteCollar, .cyber:
                reasons = ["\(subj) \(s.v("is", "are")) still untangling the credit damage.", "\(subj) \(s.v("trusted", "trusted")) \(defendant).",
                           "The money was meant for retirement.", "\(subj) \(s.v("checks", "check")) every bank statement twice now."]
            case .traffic:
                reasons = ["\(subj) still can't drive that road.", "The medical bills are still coming.",
                           "\(subj) \(s.v("has", "have")) months of physical therapy left.", "\(subj) jumps at every car horn."]
            case .drugs:
                reasons = ["\(subj) watched what the drugs did to the neighborhood.", "\(subj) \(s.v("wants", "want")) the cycle to stop."]
            default:
                reasons = ["\(subj) still \(s.v("has", "have")) nightmares.", "\(subj) \(s.v("has", "have")) missed weeks of work.",
                           "\(subj) moved after this.", "\(subj) \(s.v("is", "are")) still in counseling.",
                           "\(subj) \(s.v("doesn't", "don't")) go out after dark anymore."]
            }
        }
        var extras = [
            "\(subj) \(s.v("has", "have")) asked to be notified of every hearing and any release.",
            "\(subj) \(s.v("doesn't", "don't")) plan to speak in court, but asked me to make sure you heard this.",
            "\(subj) will be in the courtroom for the sentence.",
            ""
        ]
        if !died && !child && stance != .wantsLeniency { extras.append("\(subj) also \(s.v("asks", "ask")) for a no-contact condition with any sentence.") }
        if let basis = restitutionBasis, !basis.isEmpty { extras.append("\(subj) \(s.v("is", "are")) asking for restitution for \(basis).") }
        let order = rng.int(0...1)
        let parts = order == 0
            ? [contact, rng.pick(reasons), rng.pick(wants), rng.pick(extras)]
            : [contact, rng.pick(wants), rng.pick(reasons), rng.pick(extras)]
        return parts.filter { !$0.isEmpty }.joined(separator: " ")
    }

    private static func months(_ m: Int) -> String {
        if m >= 24 && m % 12 == 0 { return "\(m / 12) years" }
        return m == 1 ? "1 month" : "\(m) months"
    }

    private static func span(_ low: Int, _ high: Int) -> String {
        low < 24 && high < 24 ? "\(low) to \(high) months" : "\(months(low)) to \(months(high))"
    }

    /// Concrete requests, with numbers, for a charge of this class. Felony numbers come from prior record level I,
    /// the lowest row of the chart, so a request is never more than the law could give.
    private static func asks(stance: VictimStance, cls: NCClass?, s: Speaker, defendant: String, restitution: Bool,
                             rng: inout SeededRNG) -> [String] {
        guard let cls else { return [] }
        let subj = s.subject
        let felony = cls.isFelony
        let probation = rng.int(StructuredSentencing.probationMonths(felony: felony, disposition: .intermediate))
        var out: [String] = []
        switch stance {
        case .wantsMaximum:
            if cls == .A {
                out = ["\(subj) \(s.v("wants", "want")) life without parole, and \(s.v("has", "have")) asked me to say the words in court.",
                       "\(subj) \(s.v("asks", "ask")) for the only sentence \(s.v("thinks", "think")) fits: life in prison."]
            } else if felony, let cell = StructuredSentencing.felonyCell(cls, level: 1) {
                let top = cell.aggravated?.high ?? cell.presumptive.high
                out = ["\(subj) \(s.v("wants", "want")) \(defendant) to serve at least \(months(top)) in prison, and no probation.",
                       "\(subj) asked me to put a number on it, Judge: a minimum of \(months(top)), active.",
                       "\(subj) \(s.v("is", "are")) asking for \(months(cell.presumptive.high)) at the very least, and more if the court can give it.",
                       "\(subj) \(s.v("wants", "want")) an active sentence of \(months(top)). \(subj) \(s.v("doesn't", "don't")) want to hear the word probation."]
            } else if let cell = StructuredSentencing.misdemeanorCell(cls, level: 1) {
                out = ["\(subj) \(s.v("wants", "want")) \(defendant) to do at least \(cell.maxDays) days in the county jail.",
                       "\(subj) \(s.v("is", "are")) asking for \(cell.maxDays) days active, not suspended.",
                       "\(subj) \(s.v("wants", "want")) jail time, Judge. \(cell.maxDays) days is the number \(s.v("gave", "gave")) me."]
            }
        case .wantsAccountability:
            if felony, cls != .A, let cell = StructuredSentencing.felonyCell(cls, level: 1) {
                out = ["\(subj) \(s.v("thinks", "think")) \(span(cell.mitigated.low, cell.presumptive.low)) is about right, and \(s.v("doesn't", "don't")) need more than that.",
                       "\(subj) would accept probation, but only with \(probation) months of supervision and a no-contact order.",
                       "\(subj) \(s.v("asks", "ask")) for a split sentence: \(rng.int(1...3)) months in the jail first, then \(probation) months of probation.",
                       "\(subj) \(s.v("wants", "want")) \(months(cell.presumptive.low)) in prison. Not the most the court could give, but real time."]
            } else if !felony, let cell = StructuredSentencing.misdemeanorCell(cls, level: 1) {
                let hours = rng.pick([50, 75, 100, 150])
                out = ["\(subj) \(s.v("asks", "ask")) for \(cell.maxDays) days, suspended, with \(probation) months of supervised probation.",
                       "\(subj) would be satisfied with \(hours) hours of community service and a written apology.",
                       "\(subj) \(s.v("wants", "want")) a few days in jail, \(rng.int(2...min(10, cell.maxDays))) or so, so \(defendant) feels it, then probation.",
                       "\(subj) \(s.v("asks", "ask")) for \(probation) months of probation with an anger-management class and a no-contact order."]
            }
            if restitution {
                out.append("\(subj) \(s.v("cares", "care")) most about the money: every dollar of restitution, paid on a schedule the court enforces.")
            }
        case .wantsLeniency:
            out = ["\(subj) \(s.v("suggests", "suggest")) \(probation) months of probation with treatment, and no jail.",
                   "\(subj) \(s.v("asks", "ask")) for a suspended sentence so \(defendant) can keep working."]
            if restitution {
                out.append("\(subj) \(s.v("wants", "want")) \(defendant) out and working, because that's the only way the restitution gets paid.")
            }
        case .none:
            break
        }
        return out
    }

    /// The State's account when the people hurt aren't one named victim.
    static func groupPosition(rng: inout SeededRNG) -> String {
        rng.pick([
            "There isn't one named victim in this case, Judge, but people were hurt by it. Their statements are in the sentencing file.",
            "Several people were affected. Three of them wrote to the court; they ask that the sentence reflect how many lives this touched.",
            "The people harmed here didn't all want to come forward, Judge. The ones who did ask for a sentence that's taken seriously.",
            "We've heard from a handful of those affected. They don't agree on a number, but they all want it on the record that this mattered.",
            "The statements from those affected are in the file. Most ask for accountability; one asks the court for treatment over prison."
        ])
    }

    /// The last words of the impact statement: what the speaker asks of the court, in the speaker's own voice.
    static func closing(stance: VictimStance, defendant: String, died: Bool, rng: inout SeededRNG) -> String? {
        let lines: [String]
        switch stance {
        case .wantsMaximum:
            lines = ["I'm asking you to give \(defendant) every day the law allows.",
                     "Please don't let \(defendant) walk out of here.",
                     died ? "We got a life sentence the day this happened. I'm asking for the same." : "I've done my time with this. Now it's \(defendant)'s turn.",
                     "Whatever you give \(defendant), it won't be enough. Make it as close as you can.",
                     "I don't want to see \(defendant) at the grocery store next year."]
        case .wantsAccountability:
            lines = ["I told the DA what I think is fair. Mostly I just want someone to say this was wrong.",
                     "Whatever you decide, I need to know it counted.",
                     "I want \(defendant) to think about this every day, the way I do.",
                     "I'd like to hear \(defendant) say it. Just once.",
                     "I trust you to get this right. I'm asking you to take it seriously."]
        case .wantsLeniency:
            lines = ["Prison won't fix this. Please give \(defendant) a chance to.",
                     "I've had enough loss. I don't need \(defendant) to lose everything too.",
                     "I'm asking for mercy. I know that's strange coming from me.",
                     "Get \(defendant) help. That's all I want from today."]
        case .none:
            return nil
        }
        return rng.pick(lines + [""]).nilIfEmpty
    }

    /// The impact statement with the speaker's closing ask, kept inside the same quotation.
    static func impact(_ base: String, stance: VictimStance, defendant: String, died: Bool, rng: inout SeededRNG) -> String {
        guard base.hasSuffix("\""), !base.contains("don't want to talk"),
              let close = closing(stance: stance, defendant: defendant, died: died, rng: &rng) else { return base }
        return String(base.dropLast()) + " " + close + "\""
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
    /// "She" → "she" at the middle of a sentence; a name stays as it is.
    var lowercasedIfPronoun: String { ["She", "He", "They"].contains(self) ? lowercased() : self }
}
