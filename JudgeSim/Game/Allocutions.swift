import Foundation

/// What the defendant says before sentence, and how the prosecutor argues for it, built from the facts of each case:
/// the charge, the victim, the record, family and work, time in jail, and whether the defendant still denies it.
enum Allocutions {

    // MARK: Facts the speakers draw on

    private struct Facts {
        let last: String
        let offense: String
        let category: LawCategory
        let victim: String?
        let death: Bool
        let priors: Int
        let felonies: Int
        let wasOnProbation: Bool
        let custodyDays: Int
        let jailed: Bool
        let children: Int
        let occupation: String
        let unemployed: Bool
        let age: Int
        let need: TreatmentNeed
        let supportInCourt: String?
        let returning: Bool
        let mood: PublicMood
        let aggravating: [String]

        init(_ c: CourtCase) {
            let d = c.defendant
            last = d.lastName
            offense = (c.charges.first?.law.title ?? "this offense").lowercased()
            category = c.category
            victim = c.victimName
            let ids = c.charges.map { $0.lawID.lowercased() }
            death = ids.contains { $0.contains("murder") || $0.contains("manslaughter") || $0.contains("dbv") || $0.contains("neglect") }
            priors = d.priors.count
            felonies = d.priors.filter { $0.ncClass.isFelony }.count
            wasOnProbation = d.probation != nil || d.priors.contains { $0.sentence.lowercased().contains("probation") }
            custodyDays = c.background?.custodyDays ?? 0
            jailed = c.background?.isJailed ?? false
            let family = d.profile?.family ?? ""
            let digits = family.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap(Int.init)
            children = family.contains("child") && !family.contains("no children") ? (digits.first ?? 1) : 0
            occupation = d.occupation.lowercasedPhrase
            unemployed = d.occupation.lowercased().contains("unemployed")
            age = d.age
            need = c.background?.treatmentNeed ?? .none
            supportInCourt = c.background?.supportPeople
            returning = d.isReturning
            mood = c.mood
            aggravating = c.aggravating
        }
    }

    // MARK: The defendant addresses the court

    /// Written cases keep the statement their authors wrote; every other case gets one built from its facts.
    /// The same case always says the same thing.
    static func statement(_ c: CourtCase, afterPlea: Bool) -> String {
        let written = c.allocution
        let lower = written.lowercased()
        let denies = lower.contains("didn't do it") || lower.contains("pending appeal") || lower.contains("innocent")
        if !written.isEmpty && !isStock(written) && !(afterPlea && denies) { return written }

        var rng = SeededRNG(seed: c.seed ^ 0xA110C)
        let f = Facts(c)
        let roll = Double.random(in: 0..<1, using: &rng)
        // A defendant convicted at trial of something they didn't do keeps saying so; most guilty ones don't.
        let deniesIt = !afterPlea && roll < (c.truth.actuallyGuilty ? 0.12 : 0.7)
        let declines = !deniesIt && roll > 0.93
        let deflects = !deniesIt && !declines && roll > 0.83

        if declines { return declined(f, afterTrial: !afterPlea, rng: &rng) }
        var lines: [String] = []
        if deniesIt {
            lines.append(rng.pick([
                "I've respected this court the whole way through, and I'm going to respect it now. But I didn't do this.",
                "I know what the verdict says. I'm still going to tell you the truth: I didn't do it.",
                "My lawyer told me to keep it short. So I'll just say it one more time. It wasn't me.",
                "I'm not going to stand up here and apologize for something I didn't do. I can't.",
                "I sat through every day of this trial and listened to people say things about me that aren't true."
            ]))
            if let v = f.victim {
                lines.append(rng.pick([
                    "I'm sorry for what happened to \(v). I am. I just wasn't the one who did it.",
                    "\(v)'s family deserves the person who really did this. That's not me.",
                    "I don't blame \(v)'s family for hating me. They were told I did it."
                ]))
            }
            lines.append(rng.pick([
                "I'm going to keep fighting this.",
                "Whatever you give me, I'm appealing.",
                "Somebody, someday, is going to find out what really happened.",
                "I just want that on the record."
            ]))
        } else if deflects {
            lines.append(rng.pick([
                "I'm not saying I didn't do anything. But nobody in this room has told the whole story.",
                "I made a mistake. But the way the police went about this, the way it got written up, that wasn't fair either.",
                "I take responsibility for my part. My part.",
                "I've been made out to be some kind of monster in here, and I'm not."
            ]))
            if f.victim != nil && !f.death {
                lines.append(rng.pick([
                    "There was a lot going on between us that didn't come out in court.",
                    "It wasn't all one-sided, Your Honor. I'll leave it at that."
                ]))
            }
            lines.append(rng.pick(["I just want to get this over with.", "That's all I've got to say.", "I'll do whatever you tell me to do."]))
        } else {
            lines.append(admission(f, afterPlea: afterPlea, rng: &rng))
            var middle: [String] = []
            if let v = f.victim { middle.append(victimLine(v, death: f.death, rng: &rng)) }
            if f.children > 0 { middle.append(childrenLine(f, rng: &rng)) }
            if f.need != .none { middle.append(treatmentLine(f, rng: &rng)) }
            if f.jailed && f.custodyDays >= 30 { middle.append(jailLine(f, rng: &rng)) }
            if f.priors >= 3 || f.returning { middle.append(recordLine(f, rng: &rng)) }
            if f.priors == 0 { middle.append(firstTimeLine(f, rng: &rng)) }
            if !f.unemployed && f.age < 65 { middle.append(workLine(f, rng: &rng)) }
            if f.supportInCourt != nil { middle.append(rng.pick([
                "My family is sitting back there. They shouldn't have to be in a courtroom because of me.",
                "I see who came today. I don't deserve them, but they came.",
                "The people who came here for me today, I owe them more than I can say."
            ])) }
            middle.shuffle(using: &rng)
            lines += middle.prefix(rng.int(1...3))
            lines.append(closer(rng: &rng))
        }
        return stage(f, rng: &rng) + " \"" + lines.joined(separator: " ") + "\""
    }

    /// The old one-size-fits-all statements, still stored in older saves and generated cases.
    private static func isStock(_ text: String) -> Bool {
        ["I know nothing I say fixes this", "on the advice of counsel, pending appeal", "I've had a lot of time to think in that cell",
         "I still say I didn't do it. But I respect the court", "Your Honor, whatever you decide, I'll take it."]
            .contains { text.contains($0) }
    }

    private static func stage(_ f: Facts, rng: inout SeededRNG) -> String {
        var options = [
            "\(f.last) stands and grips the edge of the table:",
            "\(f.last) unfolds a sheet of notebook paper and reads from it, stopping twice:",
            "\(f.last) stands. It takes a moment to begin:",
            "\(f.last) speaks so quietly that the court reporter asks for the first sentence again:",
            "\(f.last) glances back at the gallery, then faces the bench:",
            "\(f.last) looks at the floor the whole time:",
            "\(f.last) speaks quickly, as if it had been rehearsed in a cell:",
            "\(f.last) reads from an index card, then sets it down and keeps going without it:",
            "\(f.last) waits for counsel's nod, then stands:",
            "\(f.last), steady at first, loses composure halfway through:"
        ]
        if f.jailed { options += ["In an orange jumpsuit, hands cuffed in front, \(f.last) leans toward the microphone:",
                                  "A deputy steps back to give \(f.last) room at the lectern:"] }
        return rng.pick(options)
    }

    private static func declined(_ f: Facts, afterTrial: Bool, rng: inout SeededRNG) -> String {
        rng.pick([
            "\(f.last) confers with counsel and declines to make a statement.",
            "\(f.last) stands, starts to speak, then shakes their head: \"No. I'm sorry. I can't.\"",
            "\"No, Your Honor. Nothing to say.\" \(f.last) sits back down.",
            afterTrial ? "On the advice of counsel, with an appeal likely, \(f.last) declines to address the court." : "\(f.last) says only: \"I said it all when I pleaded, Judge.\""
        ])
    }

    private static func admission(_ f: Facts, afterPlea: Bool, rng: inout SeededRNG) -> String {
        var options: [String]
        switch f.category {
        case .violent:
            options = f.death
                ? ["Somebody is dead because of me. I wake up with that and I go to sleep with it.",
                   "I can't give back what I took. Nobody can.",
                   "There isn't a sentence long enough to fix this, and I know that."]
                : ["I hurt somebody. There's no other way to say it.",
                   "I lost my temper and somebody got hurt, and it was my fault, not theirs.",
                   "I've gone over that night a thousand times. Every version ends with me doing the wrong thing."]
        case .robbery:
            options = ["I scared somebody half to death for money. I know that now in a way I didn't then.",
                       "That person was just at work. They didn't do anything to me.",
                       "I told myself nobody would get hurt. That's not something you get to promise when you do what I did."]
        case .property:
            options = ["I took things that weren't mine. People worked for those things.",
                       "I went into somebody's place like it was nothing. It wasn't nothing to them.",
                       "I needed money and I took the easy way. It wasn't easy for the people I took from."]
        case .drugs:
            options = ["I sold drugs. I told myself the people buying were going to get it somewhere anyway. That's a lie I told a lot.",
                       "I was using and I was selling to keep using. Both of those are on me.",
                       "I know what that stuff does to people. I've watched it. I sold it anyway."]
        case .traffic:
            options = ["I got behind the wheel. Nobody made me do it.",
                       "I knew better. I'd been told. I did it anyway.",
                       "I keep thinking about how many cars I passed that night."]
        case .whiteCollar:
            options = ["People trusted me with their money and I took it. I can make excuses, but that's what happened.",
                       "I kept telling myself I'd pay it back before anybody noticed.",
                       "I lied on paper for a long time. I'm not going to lie standing here."]
        case .family:
            options = ["The people I hurt were supposed to be able to count on me.",
                       "My family should have been the safest place, and I made it the opposite.",
                       "I let down the people who needed me most."]
        default:
            options = ["What I did was wrong, and I knew it was wrong when I did it.",
                       "I'm not going to make excuses. I did it.",
                       "I've had a long time to think about \(f.offense), and I don't have a good reason for any of it."]
        }
        if afterPlea { options.append("I pleaded guilty because I'm guilty. I didn't want anybody to have to testify about it.") }
        return rng.pick(options)
    }

    private static func victimLine(_ v: String, death: Bool, rng: inout SeededRNG) -> String {
        let first = v.components(separatedBy: " ").first ?? v
        return death
            ? rng.pick(["To \(v)'s family: I don't expect you to ever forgive me. I wouldn't.",
                        "I think about \(first) every single day. I'm sorry. I know that word isn't enough.",
                        "\(v)'s mother looked at me the whole trial. I couldn't look back. I'm sorry."])
            : rng.pick(["\(first), if you're here, I'm sorry. You didn't deserve any of it.",
                        "I wrote a letter to \(v) but my lawyer said I couldn't send it. It says I'm sorry, and I mean it.",
                        "I hope \(v) can sleep at night again. I hope that more than anything for myself.",
                        "Whatever \(v) needs, if I can ever pay it back, I will."])
    }

    private static func childrenLine(_ f: Facts, rng: inout SeededRNG) -> String {
        let kids = f.children == 1 ? "my kid" : "my \(f.children) kids"
        return rng.pick([
            "I have \(f.children == 1 ? "a child" : "\(f.children) children"). They're going to grow up hearing about this, and that's on me.",
            "I missed a birthday sitting in that jail. I'm not going to miss any more if I can help it.",
            "Every time I talk to \(kids) on the phone, they ask when I'm coming home. I don't know what to tell them.",
            "I want \(kids) to see me do better than this. That's all I want."
        ])
    }

    private static func treatmentLine(_ f: Facts, rng: inout SeededRNG) -> String {
        switch f.need {
        case .mentalHealth:
            return rng.pick(["I wasn't taking my medication. I'm not saying that's an excuse. It's just what was going on.",
                             "I've been seeing the counselor at the jail. For the first time somebody explained what's wrong with me.",
                             "I didn't know how sick I was until I got locked up and started getting treatment."])
        default:
            return rng.pick(["I was using every day back then. I'm not the same person sober.",
                             "I've been going to the NA meetings in the jail every week. I've got \(max(1, f.custodyDays / 30)) month\(f.custodyDays / 30 == 1 ? "" : "s") clean.",
                             "If there's a treatment program, I'll do it. I've never actually asked for help before. I'm asking now.",
                             "Drinking took everything I had. I don't want it to take the rest."])
        }
    }

    private static func jailLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I've been in the county jail \(f.custodyDays) days. I've had a lot of nights to think.",
                  "\(f.custodyDays) days in there. I got my GED started. I want to finish it.",
                  "Being locked up, I had to look at myself. I didn't like what I saw."])
    }

    private static func recordLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I know I've been in front of judges before. I know you've heard people say they've changed. I'm not asking you to believe me. I'm asking you to watch.",
                  "Every time before this, I told the judge what they wanted to hear. I'm trying not to do that today.",
                  f.wasOnProbation ? "I had my chances on probation, and I wasted them. I know that." : "I keep ending up back here. I'm tired of it."])
    }

    private static func firstTimeLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I've never been in trouble before. I don't even know how I ended up here.",
                  "I'd never been in a courtroom before this case. I hope I never see one again.",
                  "Before this, I'd never even had a speeding ticket. I don't say that to get out of anything."])
    }

    private static func workLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I worked as \(f.occupation.withIndefiniteArticle). If I can get back to it, I can pay back what I owe.",
                  "My boss said the job's there if I can get to it. I'd like to get to it.",
                  "I've worked since I was sixteen. I want to work again."])
    }

    private static func closer(rng: inout SeededRNG) -> String {
        rng.pick(["Whatever you decide, I'll do it.",
                  "I'm asking for a chance. That's all.",
                  "Thank you for listening to me.",
                  "That's all I have, Your Honor.",
                  "I'm not going to ask for anything. I'll take what I get.",
                  "I'm sorry. I'm going to keep saying it until it means something.",
                  "I just want to go home and do it right this time.",
                  "I'll accept what you give me."])
    }

    // MARK: The State's argument for sentence

    /// A prosecutor's reasons for the sentence asked, from the facts of this case. One to three sentences.
    static func stateReasons(_ c: CourtCase, plea: Bool, salt: UInt64 = 0) -> String {
        var rng = SeededRNG(seed: c.seed ^ 0x57A7E ^ salt)
        let f = Facts(c)
        var reasons: [String] = []
        if let v = f.victim {
            reasons.append(f.death
                ? rng.pick(["\(v) is never coming home. That has to mean something in this courtroom.",
                            "\(v)'s family has sat through every setting of this case. They're here today.",
                            "There's an empty chair at \(v)'s family's table, and there will be one for the rest of their lives."])
                : rng.pick(["\(v) still won't answer the door after dark.",
                            "\(v) missed weeks of work and is still paying medical bills.",
                            "\(v) has been to every setting of this case, and \(v) is here today.",
                            "\(v) came to court and testified about the worst day of their life. The sentence should reflect that."]))
        }
        if f.felonies >= 2 {
            reasons.append(rng.pick(["This is not \(f.last)'s first felony. It's not the second.",
                                     "\(f.last) has \(f.felonies) prior felony convictions. The record speaks for itself.",
                                     "Every prior judge gave \(f.last) the benefit of the doubt. Look at where that got us."]))
        } else if f.wasOnProbation && f.priors > 0 {
            reasons.append(rng.pick(["Probation has been tried. It didn't work.",
                                     "\(f.last) was given supervision before and didn't take it seriously."]))
        } else if f.priors == 0 {
            reasons.append(rng.pick(["The State recognizes \(f.last) has no record. That's already built into this recommendation.",
                                     "The State isn't asking the court to throw away the key. We're asking for a sentence that fits the conduct."]))
        }
        if let factor = f.aggravating.first {
            reasons.append("The evidence supports the aggravating factor: \(factor.prefix(1).lowercased() + String(factor.dropFirst())).")
        }
        switch f.category {
        case .drugs: reasons.append(rng.pick(["What \(f.last) sold ended up in this county's neighborhoods.", "The overdose numbers in this county aren't an abstraction."]))
        case .traffic: reasons.append(rng.pick(["Everybody on that road that night was at risk.", "Other people who drink and drive need to hear what happens."]))
        case .whiteCollar: reasons.append(rng.pick(["This wasn't one bad moment. It was a choice made over and over.", "The people who lost money trusted \(f.last) completely."]))
        case .violent, .robbery: reasons.append(rng.pick(["The violence here wasn't impulsive.", "The court has to protect the public from this happening again."]))
        default: break
        }
        if f.mood == .wantsConviction { reasons.append("This community is paying attention to what happens in this courtroom today.") }
        if plea { reasons.append(rng.pick(["The State acknowledges \(f.last) accepted responsibility, and our recommendation already reflects that.",
                                           "The plea spared the witnesses a trial, and the State has taken that into account."])) }
        if reasons.isEmpty {
            reasons.append(rng.pick(["The sentence should match what the evidence showed.", "Anything less sends the wrong message about \(f.offense).",
                                     "That's what the chart calls for, and nothing in this record justifies going below it."]))
        }
        reasons.shuffle(using: &rng)
        var said = Array(reasons.prefix(rng.int(1...2)))
        if let bg = c.background, bg.restitution > 0 {
            let amount = SentenceFormat.dollars(bg.restitution)
            let basis = bg.restitutionBasis ?? "the losses"
            said.append(rng.pick(["The State also asks for \(amount) in restitution for \(basis). The documentation is in the file.",
                                  "And restitution: \(amount), for \(basis).",
                                  "We're requesting \(amount) in restitution for \(basis), and we've handed up the receipts."]))
        }
        return said.joined(separator: " ")
    }

    /// The prosecutor asking for sentence at the bench: the request, then why.
    static func stateArgument(_ c: CourtCase, request: String, plea: Bool, salt: UInt64 = 0) -> String {
        var rng = SeededRNG(seed: c.seed ^ 0xB3A7 ^ salt)
        let opener = rng.pick(["", "Judge, ", "Your Honor, ", "Briefly, Judge. ", "The State's position is simple. "])
        let body = opener.isEmpty ? request : opener + request.prefix(1).lowercased() + String(request.dropFirst())
        return body + " " + stateReasons(c, plea: plea, salt: salt)
    }

    // MARK: Closing arguments

    /// The stock closings older generated cases carry; they are rebuilt from the case itself when shown.
    private static let stockClosings = [
        "The evidence points one direction, Your Honor", "Every piece of this puzzle fits.", "Reasonable doubt is not any doubt.",
        "The State has given you suspicion, Your Honor, not proof.", "If you have a reasonable doubt, and you should",
        "Look at what's missing from this case."
    ]

    /// A closing argument: the written one for a written case, otherwise one built from the evidence and witnesses.
    static func closing(_ c: CourtCase, side: Side, rulings: Rulings? = nil) -> String {
        // Evidence the court kept out, and counts it already dismissed, aren't argued.
        let excluded = rulings?.excludedEvidence(in: c) ?? []
        let gone = Set(c.motions.compactMap { m in m.kind == .dismissIndictment && rulings?.motions[m.id] == true ? m.targetChargeID : nil })
        let counts = c.charges.filter { !gone.contains($0.id) && rulings?.halftime[$0.id] != .dismiss }
        let stored = side == .prosecution ? c.prosecutionClosing : c.defenseClosing
        let citesExcluded = c.evidence.contains { excluded.contains($0.id) && stored.contains($0.exhibit) }
        guard stored.isEmpty || stockClosings.contains(where: stored.contains) || citesExcluded || counts.count < c.charges.count else { return stored }
        var rng = SeededRNG(seed: c.seed ^ (side == .prosecution ? 0xC105E : 0xDEF0C))
        let dl = c.defendant.lastName
        let charge = (counts.first ?? c.charges.first)?.law.title.lowercasedPhrase ?? "the charges"
        let ours = c.evidence.filter { $0.side == side && !excluded.contains($0.id) }.sorted { $0.weight > $1.weight }
        let theirs = c.evidence.filter { $0.side != side && !excluded.contains($0.id) }.sorted { $0.weight > $1.weight }
        let witness = c.witnesses.filter { $0.calledBy == side && $0.isDefendant != true }.max { $0.weight < $1.weight }
        var parts: [String] = []

        if side == .prosecution {
            parts.append(rng.pick(["Your Honor, this case comes down to a few pieces of evidence, and they all point the same way.",
                                   "Judge, I'll be brief, because the evidence doesn't need much help.",
                                   "May it please the court. Let's start with what isn't disputed.",
                                   "Your Honor, the defense wants you to look at this case one piece at a time. Look at it all together."]))
            if let first = ours.first {
                parts.append(rng.pick(["Start with \(first.exhibit), the \(first.title.lowercased()).",
                                       "\(first.exhibit), the \(first.title.lowercased()), is where this case begins and ends.",
                                       "The \(first.title.lowercased()) alone puts \(dl) right in the middle of this."]))
            }
            if ours.count > 1 {
                let second = ours[1]
                parts.append(rng.pick(["Add the \(second.title.lowercased()).", "Then there's the \(second.title.lowercased()), which nobody has explained away.",
                                       "And the \(second.title.lowercased()) fits with all of it."]))
            }
            if let witness {
                parts.append(rng.pick(["You heard from \(witness.name). Nothing on cross changed what \(witness.name) told you.",
                                       "\(witness.name) had no reason to make any of this up.",
                                       "Think about \(witness.name)'s testimony, and how well it matches everything else."]))
            }
            if let counter = theirs.first {
                parts.append(rng.pick(["The defense points to the \(counter.title.lowercased()). It doesn't explain the rest.",
                                       "Yes, there's the \(counter.title.lowercased()). Weigh it against everything else and it doesn't move the needle.",
                                       "The defense will lean on the \(counter.title.lowercased()). Ask what it actually proves."]))
            }
            if let v = c.victimName {
                parts.append(rng.pick(["\(v) deserves a verdict that matches the evidence.", "This case is about what happened to \(v)."]))
            }
            parts.append(rng.pick(["The State has proven every element beyond a reasonable doubt. We ask the court to find \(c.defendant.name) guilty of \(charge).",
                                   "We ask for a verdict of guilty on \(charge).",
                                   "Put it together and there's one reasonable conclusion. \(dl) is guilty."]))
        } else {
            parts.append(rng.pick(["Your Honor, the State's case sounds good from a distance. Up close it doesn't hold.",
                                   "Judge, the question isn't whether something happened. It's whether the State proved that \(dl) did it.",
                                   "May it please the court. The burden is the State's, and it never shifts.",
                                   "Your Honor, I'm going to ask you to do the hard thing and hold the State to its burden."]))
            if let first = theirs.first {
                parts.append(rng.pick(["The State's case rests on the \(first.title.lowercased()). Take that away and what's left?",
                                       "Look closely at \(first.exhibit). It shows less than the State claims.",
                                       "The \(first.title.lowercased()) is the best the State has, and it doesn't get them there."]))
            }
            if let mine = ours.first {
                parts.append(rng.pick(["Then there's the \(mine.title.lowercased()), which the State never really answered.",
                                       "The State has no good explanation for the \(mine.title.lowercased()).",
                                       "Remember \(mine.exhibit). It points somewhere else."]))
            }
            if let witness {
                parts.append(rng.pick(["\(witness.name) told you what really happened, and the State couldn't shake it.",
                                       "Think about what \(witness.name) said, and why the State spent so little time on it."]))
            }
            parts.append(rng.pick(["That is reasonable doubt, and the law says \(dl) must be found not guilty.",
                                   "Suspicion isn't proof. We ask for a verdict of not guilty.",
                                   "If you hesitate, and you should, that's reasonable doubt. Find \(dl) not guilty.",
                                   "The State asked you to fill in the gaps. The law doesn't allow that. Not guilty."]))
        }
        return parts.joined(separator: " ")
    }
}
