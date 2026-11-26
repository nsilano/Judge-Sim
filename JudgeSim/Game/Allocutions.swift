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
        /// Stalking or violating a court order: conduct aimed at one person, not a theft or a fight.
        let stalking: Bool
        /// The law ids charged, lowercased.
        let lawIDs: [String]
        /// A drug charge about selling, delivering, trafficking or making, as opposed to having.
        let sale: Bool

        init(_ c: CourtCase) {
            let d = c.defendant
            last = d.lastName
            offense = (c.charges.first?.law.title ?? "this offense").lowercased()
            category = c.category
            victim = c.victimName
            let ids = c.charges.map { $0.lawID.lowercased() }
            death = Consequences.victimDied(c)
            priors = d.priors.count
            felonies = d.priors.filter { $0.ncClass.isFelony }.count
            wasOnProbation = d.probation != nil || d.priors.contains { $0.sentence.lowercased().contains("probation") }
            custodyDays = c.background?.custodyDays ?? 0
            jailed = c.background?.isJailed ?? false
            children = d.profile?.childCount ?? 0
            // Work talk follows the profile: a real current job, not a student, retiree, or a job already lost.
            let job = d.profile?.currentJob
            occupation = job?.title.lowercased() ?? d.occupation.lowercasedPhrase
            unemployed = !DefendantProfile.isWork(d.occupation) || (d.profile != nil && job == nil)
            age = d.age
            need = c.background?.treatmentNeed ?? .none
            supportInCourt = c.background?.supportPeople
            returning = d.isReturning
            mood = c.mood
            aggravating = c.aggravating
            stalking = ids.contains { $0.contains("stalking") || $0 == "dvpoviolation" }
            lawIDs = ids
            sale = ids.contains { id in ["pwisd", "sell", "sale", "deliver", "traffick", "manufactur"].contains { id.contains($0) } }
        }
    }

    // MARK: The defendant addresses the court

    /// Written cases keep the statement their authors wrote; every other case gets one built from its facts.
    /// The same case always says the same thing.
    static func statement(_ c: CourtCase, afterPlea: Bool, pleaKind: PleaKind = .guilty, asCharged: Bool = true) -> String {
        let written = c.allocution
        let lower = written.lowercased()
        let denies = ["didn't", "did not", "never", "wasn't me", "it wasn't", "not guilty", "pending appeal", "innocent", "i'm not the one"]
            .contains { lower.contains($0) }
        // A statement written for after a trial doesn't fit a plea.
        let speaksOfTrial = ["trial", "jury", "testif", "verdict", "witness stand"].contains { lower.contains($0) }
        // The written statement is about the main charge as charged; if the court found something less (or nothing) on it, the
        // defendant speaks from the facts that were proved instead.
        if asCharged && !written.isEmpty && !isStock(written) && !(afterPlea && (denies || speaksOfTrial)) && !(afterPlea && pleaKind != .guilty) { return written }

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
                "I sat through every day of this trial and listened to people say things about me that aren't true.",
            "I'm not going to disrespect this court. I'm going to tell you I'm innocent and let that stand.",
            "I understand why you ruled the way you did. It doesn't change what I know happened.",
            "Whatever happens today, I want it on the record that I didn't do this.",
            "I've told the same story since the night I was arrested, and I'll tell it again today. I didn't do this.",
            "I'm not angry at the jury. I'm only telling you they got it wrong, and I'll keep saying so.",
            "My family raised me not to lie, and I'm not going to start now to make this easier. I didn't do it.",
            "I know the court has a job to do. I'm only asking that you remember I never once said I was guilty.",
            "I can live with whatever you decide, but I can't stand here and say I did something I didn't do.",
            "I haven't slept a full night since this started, because I know I'm innocent and nobody has believed it."
            ]))
            if let v = f.victim {
                lines.append(rng.pick([
                    "I'm sorry for what happened to \(v). I am. I just wasn't the one who did it.",
                    "\(v)'s family deserves the person who really did this. That's not me.",
                    "I don't blame \(v)'s family for hating me. They were told I did it.",
                "I feel for \(v) and everyone who loves \(v). I wish I could give them the person responsible.",
                "I'm not going to pretend \(v)'s loss isn't real. I'm just not the one who caused it.",
                "I know \(v) has been hurt, and I wish that pain had a real answer. It just isn't me.",
                "I sat in this room and watched \(v)'s family listen to the evidence. I'd want answers too, but I'm not the answer.",
                "If I thought I'd done something to \(v), I would say so. I didn't, and I can't say otherwise.",
                "I hope somebody finds out who really hurt \(v), because the family deserves that, and so do I.",
                "I don't have any hard feelings toward \(v). I just can't carry what somebody else did.",
                "Nothing I say will help \(v)'s family today, and I understand that. I only ask them to keep looking for the truth."
                ]))
            }
            lines.append(rng.pick([
                "I'm going to keep fighting this.",
                "Whatever you give me, I'm appealing.",
                "Somebody, someday, is going to find out what really happened.",
                "I just want that on the record.",
            "I'll keep appealing this as long as I have to.",
            "This isn't the end of it for me.",
            "I'm asking my lawyer to file the notice today.",
            "I'm not going to stop until somebody looks at this the right way.",
            "There are things in this record I'll be asking a higher court to look at.",
            "I'll be talking to my lawyer about the appeal as soon as I walk out of here.",
            "I haven't given up, and I don't intend to.",
            "A jury made a decision. I respect that they did their job, but I'm not done.",
            "I'm going to ask the Court of Appeals to look at every bit of this, and I'll wait as long as it takes."
            ]))
        } else if deflects {
            lines.append(rng.pick([
                "I'm not saying I didn't do anything. But nobody in this room has told the whole story.",
                "I made a mistake. But the way the police went about this, the way it got written up, that wasn't fair either.",
                "I take responsibility for my part. My part.",
                "I've been made out to be some kind of monster in here, and I'm not.",
            "There's more to what happened than the State put on.",
            "I did my part in it. I didn't do what they say.",
            "The court heard one version. There's another one.",
            "I'm not going to say I did nothing wrong. I'm going to say it wasn't as simple as they made it sound.",
            "I know where I went wrong. I just don't think the picture you were given was the whole picture.",
            "A lot of what the witnesses said was true. A lot of what they left out was true too.",
            "I own my part in it. I don't own everything they hung on it.",
            "I'm not asking you to excuse any of it, only to understand there was more going on than came out here.",
            "Nobody was asked what led up to it, Your Honor, and that matters."
            ]))
            if f.victim != nil && !f.death {
                lines.append(rng.pick([
                    "There was a lot going on between us that didn't come out in court.",
                    "It wasn't all one-sided, Your Honor. I'll leave it at that.",
                "We had a history the court never heard about.",
                "It's more complicated than what was said in here.",
                "Some of this goes back a long way, and it didn't get said in here, and I'm not going to say it now.",
                "Both of us had a hand in how things got to where they were. I think that's fair to say.",
                "People only heard the worst day of it. There were a lot of other days.",
                "I'm not trying to blame anyone, Your Honor. I just want the court to know there was more to it.",
                "There's a side to this that wasn't allowed in, and I accept that. But it exists.",
                "What was going on between us was a lot messier than anything that was said in here."
                ]))
            }
            lines.append(rng.pick(["I just want to get this over with.", "That's all I've got to say.", "I'll do whatever you tell me to do.", "I'm ready to hear it.", "I've said what I came to say.", "I'll accept whatever you decide.", "I've said everything I know how to say.", "I'm not going to take up any more of the court's time.", "I understand what's happening, and I'll accept it.", "I just hope the court sees that I'm trying.", "I don't have anything to add to what my lawyer said.", "Whatever you decide, I'll deal with it."]))
        } else if afterPlea && pleaKind != .guilty {
            // An Alford or no-contest plea admits nothing.
            lines.append(rng.pick([
                "I took this plea because I couldn't take the chance of a trial. I'm not standing here saying it all happened the way they say.",
                "My lawyer explained what could happen if I went to trial. I made the choice that was best for my family.",
                "I'm not admitting to it, Your Honor. I'm accepting the plea so this can be over.",
                "I know how the evidence looks. That's why I took the deal.",
            "I took the deal because I was scared of what a trial might cost me.",
            "I took the plea so my family wouldn't have to go through a trial.",
            "I'm here because the plea was the safest option, not because I agree with every word that was read.",
            "I weighed the risk of a trial against the offer, and I made the decision I could live with.",
            "Taking this plea doesn't mean I think the State's version is the whole story.",
            "I was told what a conviction at trial could mean, and I wasn't willing to gamble with my family's future.",
            "I accepted the plea because it lets me know what's going to happen, and a trial couldn't promise me that.",
            "I don't have to agree with how this was described to accept that I'm better off ending it today."
            ]))
            if let v = f.victim, !f.death {
                lines.append(rng.pick(["I don't wish \(v) anything bad. I hope everybody can move on.", "I'll stay away from \(v). I'll do what the court says.", "I hope \(v) and \(v)'s family can have some peace.", "I won't contact \(v) in any way. You have my word.", "I'm not going to reach out to \(v). I'd like to be left alone and I'll leave \(v) alone.", "I hope \(v) is doing all right. I'll keep my distance like the court says.", "I don't want to make anything harder for \(v), and staying away is the least I can do.", "If \(v) never wants to see me again, I understand that, and I'll respect it.", "I'm sorry if any of this has made \(v) afraid. That was never what I wanted.", "I'll follow every condition about \(v), and I won't go looking for ways around them."]))
            }
            lines.append(rng.pick(["I'll do whatever the court orders.", "That's all I want to say.", "I just want to get back to work and take care of my family.", "I'm ready to do what it takes to make this right.", "I just want to put this behind me and move forward.", "I'll follow whatever conditions you put on me.", "I want to get on with my life and do right by the people counting on me.", "I'm ready to take responsibility and do my time or my probation, whichever you decide.", "I don't plan on coming back in front of you. I've learned that much.", "I'd like to start working off whatever I owe as soon as I can.", "I'm grateful for the chance to speak, and that's all I have."]))
        } else {
            lines.append(admission(f, afterPlea: afterPlea, rng: &rng))
            var middle: [String] = []
            if let v = f.victim { middle.append(victimLine(v, death: f.death, afterPlea: afterPlea, rng: &rng)) }
            if f.children > 0 { middle.append(childrenLine(f, rng: &rng)) }
            if f.need != .none { middle.append(treatmentLine(f, rng: &rng)) }
            if f.jailed && f.custodyDays >= 30 { middle.append(jailLine(f, rng: &rng)) }
            if f.priors >= 3 || f.returning { middle.append(recordLine(f, rng: &rng)) }
            if f.priors == 0 { middle.append(firstTimeLine(f, rng: &rng)) }
            if !f.unemployed && f.age < 65 { middle.append(workLine(f, rng: &rng)) }
            if f.supportInCourt != nil { middle.append(rng.pick([
                "My family is sitting back there. They shouldn't have to be in a courtroom because of me.",
                "I see who came today. I don't deserve them, but they came.",
                "The people who came here for me today, I owe them more than I can say.",
            "My mother took off work to be here. She shouldn't have to.",
            "Someone I love is in the back. This isn't what I wanted them to see.",
            "The people sitting behind me have stood by me through all of this, and I don't take that lightly.",
            "Having my family here today means more than I can put into words.",
            "I'm sorry my family had to take time out of their lives to sit in this courtroom for me.",
            "I can see my people in the gallery. They deserve better than this, and I'm going to try to give it to them.",
            "A few folks drove a long way to be here for me today, and I want them to know I noticed.",
            "I'm ashamed they had to see me stand here, but I'm glad they came."
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
        if f.stalking {
            options = ["The court told me to stay away, and I didn't. I don't have an excuse for that.",
                       "I kept telling myself I just needed to talk. Nobody needed me to talk. I needed to leave it alone.",
                       "I scared somebody who had already been through enough. I see that now."]
            if afterPlea { options.append("I pleaded guilty because I did it, and I didn't want anyone to have to come in here and say it again.") }
            return rng.pick(options)
        }
        func charged(_ words: [String]) -> Bool { f.lawIDs.contains { id in words.contains { id.contains($0) } } }
        let plain = ["What I did was wrong, and I knew it was wrong when I did it.",
                     "I'm not going to make excuses. I did it.",
                     "I've had a long time to think about \(f.offense), and I don't have a good reason for any of it."]
        // The category is broad; some charges in it aren't a fight, a theft, or a robbery, and the stock words would be wrong.
        if (f.category == .violent && !f.death && charged(["sexual", "rape", "neglect", "interfering", "threat"]))
            || (f.category == .robbery && charged(["kidnap", "threat", "extortion"]))
            || (f.category == .family && charged(["custody"])) {
            options = plain
            if afterPlea { options.append("I pleaded guilty because I'm guilty. I didn't want anybody to have to testify about it.") }
            return rng.pick(options)
        }
        if f.category == .property && charged(["trespass", "injury", "vandal", "damage", "arson", "burn"]) {
            options = ["I damaged something that wasn't mine, and somebody had to pay to fix it.",
                       "I told myself it didn't matter. It mattered to the person who had to deal with it.",
                       "I wasn't thinking about what it would cost somebody else, and I should have been."]
            if afterPlea { options.append("I pleaded guilty because I did it, and I'd rather own it than argue about it.") }
            return rng.pick(options)
        }
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
            options = f.sale
                ? ["I sold drugs. I told myself the people buying were going to get it somewhere anyway. That's a lie I told a lot.",
                   "I was using and I was selling to keep using. Both of those are on me.",
                   "I know what that stuff does to people. I've watched it. I sold it anyway."]
                : ["I had that stuff on me, and I knew exactly what it was. That's on me.",
                   "I've been using, and I'm not going to pretend I wasn't. I'm tired of living like this.",
                   "I know what these drugs do to people. I've watched it happen, and I kept using anyway."]
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

    private static func victimLine(_ v: String, death: Bool, afterPlea: Bool, rng: inout SeededRNG) -> String {
        let first = v.components(separatedBy: " ").first ?? v
        return death
            ? rng.pick(["To \(v)'s family: I don't expect you to ever forgive me. I wouldn't.",
                        "I think about \(first) every single day. I'm sorry. I know that word isn't enough.",
                        "\(v)'s mother has been at every hearing. I couldn't look at her. I'm sorry.", "To \(v)'s family: I can't undo it. I'll carry it for the rest of my life.", "I'm sorry to everyone who loved \(v). There's nothing I can say that matches what you lost.", "I know nothing I say will help \(v)'s family, but I want them to hear from my own mouth that I'm sorry.", "I've thought about what I took from \(v)'s family every night in that cell, and I always will.", "To everyone who loved \(v): I'm not asking for forgiveness. I only want you to know I understand what I did.", "I can't bring \(first) back, and I would give anything if I could trade places.", "\(v)'s family has to live with this forever, and so do I. I'm sorry for the part I can't ever fix.", "I'm sorry, and I know it will never be enough. \(first) mattered, and I won't ever forget that."])
            : rng.pick(["\(first), if you're here, I'm sorry. You didn't deserve any of it.",
                        "I wrote a letter to \(v) but my lawyer said I couldn't send it. It says I'm sorry, and I mean it.",
                        "I hope \(v) can sleep at night again. I hope that more than anything for myself.",
                        "Whatever \(v) needs, if I can ever pay it back, I will.", "\(first), I'm sorry for what I put you through.", "I hope \(first) can sleep at night again. I'm sorry I took that from you.", "I'm sorry for what I did to \(v). I hope \(v) gets to feel safe again.", "\(first), you didn't ask for any of this to happen to you, and I'm sorry that it did.", "I'd like \(v) to know that I think about what happened and I regret it.", "I don't expect \(v) to want to hear from me. I just want to say I'm sorry out loud in front of everyone.", "If \(v) is listening, I hope my being sorry counts for something, even a little.", "I'm sorry that \(v) had to come to court and relive it. That's on me."])
    }

    private static func childrenLine(_ f: Facts, rng: inout SeededRNG) -> String {
        let kids = f.children == 1 ? "my kid" : "my \(f.children) kids"
        return rng.pick([
            "I have \(f.children == 1 ? "a child" : "\(f.children) children"). They're going to grow up hearing about this, and that's on me.",
            "I missed a birthday sitting in that jail. I'm not going to miss any more if I can help it.",
            "Every time I talk to \(kids) on the phone, they ask when I'm coming home. I don't know what to tell them.",
            "I want \(kids) to see me do better than this. That's all I want.",
        "I want \(kids) to be able to look at me someday without being ashamed.",
        "I want \(kids) to know I'm trying to do right by them, even from here.",
        "When I'm not there, \(kids) feel it. I can't keep putting them through that.",
        "I'd like to be at the next school event for \(kids), and I can't do that if I keep making these mistakes.",
        "Whatever you give me, I'm going to explain it to \(kids) honestly. They deserve that much.",
        "I'm not asking for sympathy for me. I'm asking you to think about what happens to \(kids) while I'm away."
        ])
    }

    private static func treatmentLine(_ f: Facts, rng: inout SeededRNG) -> String {
        switch f.need {
        case .mentalHealth:
            return rng.pick(["I wasn't taking my medication. I'm not saying that's an excuse. It's just what was going on.",
                             "I've been seeing the counselor at the jail. For the first time somebody explained what's wrong with me.",
                             "I didn't know how sick I was until I got locked up and started getting treatment.", "I'd been off my medication for a month, and I'd stopped telling anyone.", "I was in a bad place and I didn't ask for help. I should have.", "I've started seeing a doctor regularly and taking what they prescribe. I wish I'd done it a long time ago.", "When I'm not well, I don't think straight. I understand now that I need help to stay on track.", "Nobody ever told me what I was dealing with could be treated, and I let it go on too long.", "I'm in a better place now than I was when this happened, and I want to keep it that way.", "I was struggling, and instead of reaching out I shut everybody out. I'm going to do better.", "I'd like to keep getting treatment, whatever the court decides. It's the first thing that's helped."])
        default:
            return rng.pick(["I was using every day back then. I'm not the same person sober.",
                             "I've been going to the NA meetings in the jail every week. I've got \(max(1, f.custodyDays / 30)) month\(f.custodyDays / 30 == 1 ? "" : "s") clean.",
                             "If there's a treatment program, I'll do it. I've never actually asked for help before. I'm asking now.",
                             "Drinking took everything I had. I don't want it to take the rest.", "I was drinking before I knew what day it was. That wasn't me.", "I've been clean since the arrest, and I intend to stay that way.", "I started using to get through the days, and it ended up running my whole life.", "I've been sober since I got locked up, and I'd like to prove it can last on the outside.", "I know the drugs and the drinking were behind most of the choices I made. That doesn't excuse them, but it explains them.", "I'm tired of living like that. I'll take whatever treatment the court orders.", "My family begged me to get help for years, and I didn't listen. I'm listening now.", "The person who did this is somebody I don't want to be anymore."])
        }
    }

    private static func jailLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I've been in the county jail \(f.custodyDays) day\(f.custodyDays == 1 ? "" : "s"). I've had a lot of nights to think.",
                  "\(f.custodyDays) day\(f.custodyDays == 1 ? "" : "s") in there. I got my GED started. I want to finish it.",
                  "Being locked up, I had to look at myself. I didn't like what I saw.", "Sitting in the county jail showed me how much I had to lose, and I don't want to lose it again.", "I spent a lot of time in that jail thinking about how I got here. I'm not proud of the answer.", "Being locked up away from everybody was the hardest thing I've ever done, and I don't want to go through it again.", "The time I've already served has taught me more than I wanted to learn.", "I read a lot while I was in the county jail, and I thought hard about what I'd do differently.", "I've seen what that place does to people, and I don't plan on being back there."])
    }

    private static func recordLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I know I've been in front of judges before. I know you've heard people say they've changed. I'm not asking you to believe me. I'm asking you to watch.",
                  "Every time before this, I told the judge what they wanted to hear. I'm trying not to do that today.",
                  f.wasOnProbation ? "I had my chances on probation, and I wasted them. I know that." : "I keep ending up back here. I'm tired of it."])
    }

    private static func firstTimeLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I've never been in trouble before. I don't even know how I ended up here.",
                  "I'd never been in a courtroom before this case. I hope I never see one again.",
                  "Before this, I'd never even had a speeding ticket. I don't say that to get out of anything.", "This is the first time I've ever been charged with anything.", "I don't have any other record. I hope that counts for something.", "I kept my record clean my whole life until now, and I'm ashamed to be standing here.", "I never imagined I would be in a courtroom as the defendant. It's a hard thing to face.", "I've never so much as been arrested before this. I'm asking the court to keep that in mind.", "This is the only time I've ever been in trouble, and it will be the last.", "I've always tried to stay on the right side of the law, and one bad decision changed that.", "I don't have a history of this. I hope the court sees this as the exception that it is."])
    }

    private static func workLine(_ f: Facts, rng: inout SeededRNG) -> String {
        rng.pick(["I worked as \(f.occupation.withIndefiniteArticle). If I can get back to it, I can pay back what I owe.",
                  "My boss said the job's there if I can get to it. I'd like to get to it.",
                  "I've worked since I was sixteen. I want to work again.", "I've held steady work for years, and I'd like the chance to keep doing it.", "I have a job to get back to, and I can't take care of my obligations if I lose it.", "Work is how I pay my bills and take care of the people who depend on me. I want to keep doing that.", "I've always shown up for work, even on the worst days. That's who I am when I'm not in a courtroom.", "My coworkers have been covering for me while this goes on, and I want to get back and carry my weight.", "If the court lets me keep working, I'll pay every dollar of what I owe."])
    }

    private static func closer(rng: inout SeededRNG) -> String {
        rng.pick(["Whatever you decide, I'll do it.",
                  "I'm asking for a chance. That's all.",
                  "Thank you for listening to me.",
                  "That's all I have, Your Honor.",
                  "I'm not going to ask for anything. I'll take what I get.",
                  "I'm sorry. I'm going to keep saying it until it means something.",
                  "I just want to go home and do it right this time.",
                  "I'll accept what you give me.", "I appreciate the court hearing me.", "I'm asking only to be treated fairly."])
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
                            "There's an empty chair at \(v)'s family's table, and there will be one for the rest of their lives.", "Nothing the court does will bring \(v) back, but it matters what the court says.", "The family has not had a normal day since \(v) died.", "\(v)'s family has had to learn how to get through holidays and ordinary Sundays without \(v), and it never gets easier.", "We ask the court to remember that \(v) was a person with plans, not just a name in a file.", "Every day since \(v) died, someone in this family has had to explain it all over again to someone who hadn't heard.", "\(v) left people behind who are still trying to make sense of it, and this courtroom is where we've had to do that.", "No sentence is going to be long enough for us, but we need the court to take what was lost seriously.", "The family has waited a long time to have \(v)'s name said in this courtroom."])
                : rng.pick(victimToll(c, v) + [
                            "\(v) has been to every setting of this case, and \(v) is here today.",
                            !plea && c.witnesses.contains(where: { $0.name == v })
                                ? "\(v) came to court and testified about the worst day of their life. The sentence should reflect that."
                                : "\(v) has had to relive this every time the case was called."]))
        }
        if f.felonies >= 2 {
            reasons.append(rng.pick(["This is not \(f.last)'s first felony. It's not the second.",
                                     "\(f.last) has \(f.felonies) prior felony convictions. The record speaks for itself.",
                                     "Every prior judge gave \(f.last) the benefit of the doubt. Look at where that got us.", "\(f.last) has been in front of this court before, and the same promises were made then.", "The record shows \(f.felonies) prior felonies. At some point a pattern is not a coincidence.", "Probation has been tried with \(f.last) already. It did not change anything.", "Each earlier sentence was supposed to be a turning point. This one needs to be taken seriously.", "We aren't here on a first offense, and the sentence shouldn't be written as if we were.", "The court has more than enough on paper to know who \(f.last) has been over the years."]))
        } else if f.wasOnProbation && f.priors > 0 {
            reasons.append(rng.pick(["Probation has been tried. It didn't work.",
                                     "\(f.last) was given supervision before and didn't take it seriously.", "A probationary sentence has already been tried in \(f.last)'s case, and it did not hold.", "The court gave \(f.last) a chance at supervision before. The State asks that the same chance not be extended again.", "Supervised probation was supposed to keep \(f.last) out of this courtroom. It didn't.", "We can't treat this as a fresh start when \(f.last) already had one under supervision.", "A probation officer's job is to prevent a return trip to court. Here it didn't work.", "The court has seen what happens when \(f.last) is given a chance to comply, and the result is in the record."]))
        } else if f.priors == 0 {
            reasons.append(rng.pick(["The State recognizes \(f.last) has no record. That's already built into this recommendation.",
                                     "The State isn't asking the court to throw away the key. We're asking for a sentence that fits the conduct.", "\(f.last) has no prior record, and the State gave that real weight in what it is asking for.", "This isn't a request to punish a first offense as if it were the tenth. It's a request to hold \(f.last) accountable for what happened.", "The State has looked at the clean record and still believes this sentence is the right one.", "A clean history matters, and the recommendation reflects it, but it doesn't erase what the evidence showed.", "The State isn't asking for the maximum because \(f.last) has no history. We're asking for what this conduct warrants.", "The lack of a record is the reason the State is asking for what it is and not more."]))
        }
        if let factor = f.aggravating.first {
            reasons.append("The evidence supports the aggravating factor: \(factor.prefix(1).lowercased() + String(factor.dropFirst())).")
        }
        switch f.category {
        case .drugs: reasons.append(rng.pick([f.sale ? "What \(f.last) sold ended up in this county's neighborhoods." : "Drugs like these do their damage far beyond the person holding them.", "The overdose numbers in this county aren't an abstraction.", "Drugs like these don't stay with one person. They end up in somebody's family.", "Emergency crews in this county have seen what this does, and the court has too.", "Every case like this one costs the county somewhere else, in treatment beds, in ambulance calls, in funerals.", "The State has to think about the families this reaches, not only the person in the chair.", "Whatever \(f.last)'s own story is, the drugs in this case were a danger to everyone around them.", "The court knows what cases like this do to a town the size of ours."]))
        case .traffic:
            let impaired = c.charges.contains { ["dwi", "habitualDWI", "felonyDBV", "dwlrImpaired", "seriousInjuryVehicle"].contains($0.lawID) } || CaseFacts(c).impaired
            reasons.append(rng.pick(["Everybody on that road that night was at risk.",
                                     impaired ? "Other people who drink and drive need to hear what happens." : "Other drivers need to hear what happens when you drive like that."]))
        case .whiteCollar: reasons.append(rng.pick(["This wasn't one bad moment. It was a choice made over and over.", "The people who lost money trusted \(f.last) completely.", "This took planning, and it took time. It wasn't a momentary lapse.", "\(f.last) had every chance to stop and kept going.", "Financial crimes like this one do real damage, even when no one is physically hurt.", "Those who were taken advantage of did nothing to deserve it.", "The people hurt here worked for what they lost.", "Trust was the tool in this case, and \(f.last) used it deliberately."]))
        case .violent, .robbery:
            // Only a crime of intent can be called planned.
            let intended = c.charges.contains { ["murder1", "attemptedMurder1", "awdwik", "awdwikisi", "dangerousRobbery", "kidnapping1", "kidnapping2", "conspiracyRobbery"].contains($0.lawID) }
            reasons.append(rng.pick(intended ? ["The violence here wasn't impulsive.", "The court has to protect the public from this happening again."]
                                             : ["The court has to protect the public from this happening again.", "Someone was badly hurt, and that has to count for something."]))
        default: break
        }
        if f.mood == .wantsConviction { reasons.append("This community is paying attention to what happens in this courtroom today.") }
        if plea { reasons.append(rng.pick(["The State acknowledges \(f.last) accepted responsibility, and our recommendation already reflects that.",
                                           "The plea spared the witnesses a trial, and the State has taken that into account.", "\(f.last) took the plea and saved everyone the time and cost of a trial, and the State's number reflects that.", "The State gave \(f.last) credit for pleading, and that credit is the reason for this recommendation.", "This is a negotiated resolution, and the State is asking for a sentence it can stand behind.", "The plea means no one has to relive this on the stand, and the State appreciates that.", "The recommendation is lower than it would have been after a trial, and that is because of the plea.", "The agreement was a fair one, and the State is asking the court to honor it."])) }
        if reasons.isEmpty {
            reasons.append(rng.pick(["The sentence should match what the evidence showed.", "Anything less sends the wrong message about \(f.offense).",
                                     "That's what the chart calls for, and nothing in this record justifies going below it.", "The sentence needs to reflect that this was a serious matter, and nothing in the record shows otherwise.", "The State asks for what the facts support, no more and no less.", "The State takes \(f.offense) seriously, and the sentence should show that.", "The chart is there so people in similar cases are treated alike, and this recommendation follows it.", "Nothing about the facts here calls for a departure in either direction.", "The record is what it is, and the State's request follows from it."]))
        }
        reasons.shuffle(using: &rng)
        var said = Array(reasons.prefix(rng.int(1...2)))
        if let bg = c.background, bg.restitution > 0 {
            let amount = SentenceFormat.dollars(bg.restitution)
            let basis = bg.restitutionBasis ?? "the losses"
            said.append(rng.pick(["The State also asks for \(amount) in restitution for \(basis). The documentation is in the file.",
                                  "And restitution: \(amount), for \(basis).",
                                  "We're requesting \(amount) in restitution for \(basis), and we've handed up the receipts.", "The State is also seeking restitution of \(amount) for \(basis), and the supporting records have been provided.", "On restitution, we're asking for \(amount) to cover \(basis).", "Restitution should be ordered in the amount of \(amount), for \(basis). The figures come straight from the victim's records.", "There's also a restitution request of \(amount) for \(basis), and it's documented.", "Finally, restitution: \(amount), for \(basis), so the loss doesn't fall on the person who suffered it.", "The State asks that \(amount) be repaid for \(basis), and the paperwork supports every dollar."]))
        }
        return said.joined(separator: " ")
    }

    /// The prosecutor asking for sentence at the bench: the request, then why.
    /// What the crime cost a living victim, in terms that fit the kind of crime.
    private static func victimToll(_ c: CourtCase, _ v: String) -> [String] {
        let threats = ["stalking", "stalkingCourtOrder", "cyberstalking", "communicatingThreats", "witnessIntimidation", "extortion", "privateImages"]
        if c.charges.contains(where: { threats.contains($0.lawID) }) {
            return ["\(v) still won't answer the door after dark.", "\(v) changed numbers, routines, and the way home from work."]
        }
        switch c.category {
        case .whiteCollar, .cyber: return ["\(v) lost money that isn't coming back.", "\(v) trusted the wrong person and paid for it."]
        case .property: return ["\(v) doesn't feel safe in that place anymore.", "\(v) is still replacing what was taken."]
        default: return ["\(v) missed weeks of work and is still paying medical bills.", "\(v) still won't answer the door after dark."]
        }
    }

    static func stateArgument(_ c: CourtCase, request: String, plea: Bool, salt: UInt64 = 0) -> String {
        var rng = SeededRNG(seed: c.seed ^ 0xB3A7 ^ salt)
        let opener = rng.pick(["", "Judge, ", "Your Honor, ", "Briefly, Judge. ", "The State's position is simple. ", "Respectfully, Your Honor, ", "With the court's permission, ", "Judge, on sentencing, ", "On the question of sentence, Your Honor, ", "To be plain, Judge, ", "Your Honor, if I may, "])
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
                                   "Your Honor, the defense wants you to look at this case one piece at a time. Look at it all together.", "Your Honor, I'll keep this short. Every piece of evidence in this case leads to the same place.", "May it please the court. The State asks you to consider the evidence as a whole, because that's how it was meant to be seen.", "Judge, after this trial there's very little left in dispute.", "Your Honor, we've heard the evidence, and what it adds up to isn't complicated.", "May it please the court. The State put on its case, and it was not shaken.", "Judge, this is a case where the facts speak louder than any argument I can make."]))
            if let first = ours.first {
                parts.append(rng.pick(["Start with \(first.exhibit), \(first.phrase).",
                                       "\(first.exhibit), \(first.phrase), is where this case begins and ends.",
                                       "\(first.phrase.capitalizedFirst) alone puts \(dl) right in the middle of this.", "I'd ask the court to begin with \(first.exhibit), \(first.phrase).", "\(first.exhibit) is \(first.phrase), and it speaks for itself.", "Look first at \(first.phrase). It's \(first.exhibit), and it matters.", "Nothing in this trial was more telling than \(first.phrase).", "\(first.phrase.capitalizedFirst) is the foundation of the State's case, and it held up.", "Consider \(first.exhibit), \(first.phrase), and ask what an innocent explanation would look like."]))
            }
            if ours.count > 1 {
                let second = ours[1]
                parts.append(rng.pick(["Add \(second.phrase).", "Then there's \(second.phrase), which nobody has explained away.",
                                       "And \(second.phrase) fits with all of it.", "Next, \(second.phrase).", "There's also \(second.phrase), which only adds to it.", "\(second.phrase.capitalizedFirst) points the same way.", "Then look at \(second.exhibit). It tells the same story.", "Put \(second.phrase) next to the rest, and the picture only gets clearer.", "And don't overlook \(second.phrase). Nothing in the defense's case answers it."]))
            }
            if let witness {
                parts.append(rng.pick(["You heard from \(witness.name). Nothing on cross changed what \(witness.name) told you.",
                                       "\(witness.name) had no reason to make any of this up.",
                                       "Think about \(witness.name)'s testimony, and how well it matches everything else.", "\(witness.name) took the stand and told you what happened, and that testimony held together from start to finish.", "Remember \(witness.name), who had nothing to gain by being here.", "\(witness.name)'s account didn't change under questioning, and it lines up with the rest of the evidence.", "Think about how \(witness.name) answered every question put to them, including the hard ones.", "The defense didn't give you a reason to doubt \(witness.name).", "When \(witness.name) testified, it was plain they were telling it straight."]))
            }
            if let counter = theirs.first {
                parts.append(rng.pick(["The defense points to \(counter.phrase). It doesn't explain the rest.",
                                       "Yes, there's \(counter.phrase). Weigh it against everything else and it doesn't move the needle.",
                                       "The defense will lean on \(counter.phrase). Ask what it actually proves.", "The defense has pointed to \(counter.phrase). Even if you give it weight, it leaves the main question untouched.", "Yes, \(counter.phrase) was raised. It isn't enough to outweigh what the State has shown.", "I expect the defense to say something about \(counter.phrase). Ask yourself whether it changes anything that matters.", "\(counter.phrase.capitalizedFirst) is the defense's best point, and it still falls short.", "Don't let \(counter.phrase) distract you from everything else the evidence showed.", "The defense wants you to focus on \(counter.phrase). The State asks you to look at the whole case."]))
            }
            if let v = c.victimName {
                parts.append(rng.pick(["\(v) deserves a verdict that matches the evidence.", "This case is about what happened to \(v).", "\(v) came to court because something happened, and the evidence shows what it was.", "Don't lose sight of \(v) in all of this.", "The people of this state owe \(v) a careful decision based on the evidence.", "Think of what \(v) went through, and what the evidence proves about who is responsible.", "\(v) is more than a name on a charging document.", "This verdict matters to \(v), and the State asks that it be made carefully."]))
            }
            parts.append(rng.pick(["The State has proven every element beyond a reasonable doubt. We ask the court to find \(c.defendant.name) guilty of \(charge).",
                                   "We ask for a verdict of guilty on \(charge).",
                                   "Put it together and there's one reasonable conclusion. \(dl) is guilty.", "The evidence is in front of you. We ask the court to find \(dl) guilty on \(charge).", "Taken together, the evidence leaves no reasonable doubt. The State asks for a guilty verdict on \(charge).", "The State has carried its burden. Guilty.", "We've met our burden, Your Honor, and we ask for a verdict of guilty on \(charge).", "The only fair reading of this evidence is guilt on \(charge).", "Your Honor, the State asks you to follow the evidence where it leads, and it leads to guilty on \(charge)."]))
        } else {
            parts.append(rng.pick(["Your Honor, the State's case sounds good from a distance. Up close it doesn't hold.",
                                   "Judge, the question isn't whether something happened. It's whether the State proved that \(dl) did it.",
                                   "May it please the court. The burden is the State's, and it never shifts.",
                                   "Your Honor, I'm going to ask you to do the hard thing and hold the State to its burden.", "Your Honor, I want to begin where the law begins, with the presumption of innocence.", "Judge, the State told you a story. A story isn't evidence.", "May it please the court. I'll ask you to look at what the State actually proved, not at what it hoped to prove.", "Your Honor, there's a gap between what the State alleged and what it showed, and that gap is where my client has been living.", "Judge, I'll be brief. The evidence doesn't get the State to where it needs to be.", "May it please the court. Doubt in this case isn't a technicality. It's what the evidence left us with."]))
            if let first = theirs.first {
                parts.append(rng.pick(["The State's case rests on \(first.phrase). Take that away and what's left?",
                                       "Look closely at \(first.exhibit). It shows less than the State claims.",
                                       "\(first.phrase.capitalizedFirst) is the best the State has, and it doesn't get them there.", "The State leans on \(first.phrase). Ask what it truly proves, and what it doesn't.", "\(first.exhibit) is the centerpiece of the State's case, and it can't carry that weight.", "Take \(first.phrase) by itself and it raises more questions than it answers.", "The State wants you to see \(first.phrase) as the end of the inquiry. It's only the start of one.", "\(first.phrase.capitalizedFirst) sounds important until you ask what it actually shows.", "I'd ask the court to look hard at \(first.exhibit) and decide whether it really shows what the State says."]))
            }
            if let mine = ours.first {
                parts.append(rng.pick(["Then there's \(mine.phrase), which the State never really answered.",
                                       "The State has no good explanation for \(mine.phrase).",
                                       "Remember \(mine.exhibit). It points somewhere else.", "Consider \(mine.phrase). The State had every chance to explain it and didn't.", "\(mine.exhibit) deserves the court's attention, because it cuts against the State's version.", "\(mine.phrase.capitalizedFirst) is the piece that doesn't fit the State's story.", "Nobody on the other side has accounted for \(mine.phrase).", "Weigh \(mine.phrase) honestly, and doubt is the result.", "The State's theory has no room for \(mine.phrase), and that should concern the court."]))
            }
            if let witness {
                parts.append(rng.pick(["\(witness.name) told you what really happened, and the State couldn't shake it.",
                                       "Think about what \(witness.name) said, and why the State spent so little time on it.", "\(witness.name) testified plainly, and nothing the State asked made that testimony less believable.", "Don't set aside what \(witness.name) said. It's the part of this trial the State least wanted to talk about.", "\(witness.name) had no stake in this except the truth, and the State hasn't given you a reason to doubt it.", "When you weigh the evidence, give \(witness.name)'s testimony the weight it deserves.", "The State asked \(witness.name) a few questions and moved on. Ask yourself why.", "\(witness.name) came in and told you straight. That counts for something."]))
            }
            parts.append(rng.pick(["That is reasonable doubt, and the law says \(dl) must be found not guilty.",
                                   "Suspicion isn't proof. We ask for a verdict of not guilty.",
                                   "If you hesitate, and you should, that's reasonable doubt. Find \(dl) not guilty.",
                                   "The State asked you to fill in the gaps. The law doesn't allow that. Not guilty.", "The State had the burden, and it wasn't met. \(dl) is entitled to a verdict of not guilty.", "Where the evidence leaves doubt, the law leaves one answer. Not guilty.", "This record doesn't prove \(dl) did this, and the law requires more than a guess. Not guilty.", "We ask you to follow the presumption of innocence all the way through. Find \(dl) not guilty.", "The honest answer after all this evidence is that the State hasn't shown it. Not guilty, Your Honor.", "A reasonable doubt is not a loophole. It's the safeguard the law gives every accused person, and \(dl) is entitled to it."]))
        }
        return parts.joined(separator: " ")
    }
}
