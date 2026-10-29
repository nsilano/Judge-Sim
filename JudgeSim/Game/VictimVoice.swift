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
        return ["i forgive", "not to prison", "don't send", "don't want prison", "don't want revenge", "asking for mercy",
                "lose everything too", "second chance", "find whoever is making"].contains { text.contains($0) }
            || text.range(of: #"don't want \S+ in (prison|jail)"#, options: .regularExpression) != nil
    }

    static func speaker(victim: String, died: Bool, child: Bool, young: Bool = false, rng: inout SeededRNG) -> Speaker {
        // A young victim's family is parents and siblings, never the victim's own children.
        if died && young && !child {
            return rng.pick([Speaker(name: "\(victim)'s mother", subject: "She", plural: false),
                             Speaker(name: "\(victim)'s parents", subject: "They", plural: true),
                             Speaker(name: "\(victim)'s father", subject: "He", plural: false),
                             Speaker(name: "\(victim)'s sister", subject: "She", plural: false),
                             Speaker(name: "\(victim)'s family", subject: "They", plural: true)])
        }
        if died && !child {
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
                         died: Bool, child: Bool, restitutionBasis: String?, cls: NCClass? = nil, young: Bool = false,
                         rng: inout SeededRNG) -> String {
        let s = speaker(victim: victim, died: died, child: child, young: young, rng: &rng)
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
                "\(subj) \(s.v("wants", "want")) \(defendant) in prison. Not probation. Prison.",
                "\(subj) \(s.v("says", "say")) probation would be a slap on the wrist, and \(s.v("doesn't", "don't")) want to hear the word.",
                "\(subj) \(s.v("wants", "want")) \(defendant) in prison, and \(s.v("doesn't", "don't")) want me to soften that.",
                "\(subj) \(s.v("wants", "want")) the most you can give, Judge, and \(s.v("has", "have")) asked me to say so plainly.",
                "\(subj) \(s.v("says", "say")) anything short of a long time away would feel like it happened all over again."
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
                "\(subj) \(s.v("wants", "want")) \(defendant) to get treatment, and \(s.v("has", "have")) asked me to tell the court so.",
                "\(subj) \(s.v("has", "have")) forgiven \(defendant), and \(s.v("asks", "ask")) that the sentence leave room for a future.",
                "\(subj) \(s.v("doesn't", "don't")) want \(defendant) locked up. The State's recommendation is our own, not \(s.v("the victim's", "the family's"))."
            ]
        case .none:
            return "There's no identified victim in this case."
        }
        // Most victims say what they want in their own words.
        let specific = asks(stance: stance, cls: cls, s: s, defendant: defendant, restitution: restitutionBasis != nil, rng: &rng)
        if !specific.isEmpty && rng.chance(0.6) { wants = specific }
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

    /// What the victim or the family actually said they want, the way people say it: from the gut, not the
    /// statute book. A number, when there is one, is a feeling, not a range. The precise recommendation is the
    /// prosecutor's, made separately in the State's sentencing argument.
    private static func asks(stance: VictimStance, cls: NCClass?, s: Speaker, defendant: String, restitution: Bool,
                             rng: inout SeededRNG) -> [String] {
        let subj = s.subject
        let low = subj.lowercasedIfPronoun
        let serious = cls.map { [.A, .B1, .B2, .C, .D].contains($0) } ?? false
        let told = rng.pick(["told me", "said to me", "kept saying", "asked me to tell you"])
        var out: [String] = []
        switch stance {
        case .wantsMaximum:
            out = ["\(subj) \(told), \"Lock \(defendant) up and throw away the key.\" I said I'd pass it along.",
                   "\(subj) \(s.v("wants", "want")) \(defendant) gone for as long as \(low) \(s.v("is", "are")) alive. Those were the words.",
                   "\(subj) \(told), \"Not one day less than what we lost.\" When I asked what that meant, \(low) couldn't say. \(subj) just cried.",
                   "\(subj) \(s.v("doesn't", "don't")) care about the guidelines, Judge. \(subj) \(s.v("wants", "want")) \(defendant) to hurt the way \(low) \(s.v("hurts", "hurt"))."]
            if !serious {
                out.append("\(subj) asked for twenty years. I explained that isn't possible on this charge. \(subj) asked me to say it anyway.")
                out.append("\(subj) \(told), \"Give \(defendant) the max. Whatever it is, the max.\"")
            } else {
                out.append("\(subj) \(s.v("wants", "want")) life. I explained what the law allows here. \(subj) said, \"Then give the most there is.\"")
            }
        case .wantsAccountability:
            out = ["\(subj) \(told), \"I don't know what the right number is. I just want \(defendant) to know what this did.\"",
                   "\(subj) \(s.v("wants", "want")) some jail. \"Even a weekend. Something. So it's real.\"",
                   "\(subj) said, \"A year, maybe? I don't know how this works. Something that shows it mattered.\"",
                   "\(subj) \(s.v("is", "are")) torn, Judge. One day \(low) \(s.v("wants", "want")) prison, the next \(low) just \(s.v("wants", "want")) it over.",
                   "\(subj) \(s.v("wants", "want")) \(defendant) to stay away. \"I don't care what else you do. Keep \(defendant) away from me.\""]
            if restitution {
                out.append("\(subj) \(told), \"Pay me back. Every penny. That's what I want.\"")
            }
        case .wantsLeniency:
            out = ["\(subj) \(told), \"I don't want \(defendant) locked up. I want \(defendant) to get better.\"",
                   "\(subj) said, \"Sending \(defendant) away won't give me anything back.\"",
                   "\(subj) \(s.v("is", "are")) worried about \(defendant)'s family. \"They didn't do this. They shouldn't pay for it.\""]
            if restitution {
                out.append("\(subj) \(s.v("wants", "want")) \(defendant) working, because \"you can't pay anybody back from a cell.\"")
            }
        case .none:
            break
        }
        return out
    }

    /// Impact statements that demand punishment, so the closing never turns around and asks for mercy.
    static func asksHarsh(_ impact: String?) -> Bool {
        guard let text = impact?.lowercased() else { return false }
        return ["make them pay", "make him pay", "make her pay", "to rot", "rot in", "never forgive", "the maximum", "lock him", "lock her",
                "lock them", "locked up for", "throw away the key", "every day the law"].contains { text.contains($0) }
    }

    /// The State's account when one person who isn't the named victim wrote to the court.
    static func singlePosition(rng: inout SeededRNG) -> String {
        rng.pick(["One person this hurt wrote to the court, Judge. The statement is in the sentencing file.",
                  "There's one statement from someone affected. It's in the file, and it's worth reading before you decide."])
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
        // A statement that already says what the speaker wants keeps its own last word.
        guard base.hasSuffix("\""), !base.contains("don't want to talk"), !asksMercy(base), !asksHarsh(base),
              let close = closing(stance: stance, defendant: defendant, died: died, rng: &rng) else { return base }
        return String(base.dropLast()) + " " + close + "\""
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
    /// "She" → "she" at the middle of a sentence; a name stays as it is.
    var lowercasedIfPronoun: String { ["She", "He", "They"].contains(self) ? lowercased() : self }
}
