import Foundation

/// Builds objections from the witness on the stand and the facts of the case, so each one fits what that
/// witness could actually be asked, and no two trials hear the same exchange.
enum ObjectionEngine {

    private struct Draft {
        let question: String
        let answer: String
        let grounds: String
        let sustain: Bool
        let explanation: String
        let doctrine: String
        let weight: Int
    }

    static func make(for w: Witness, ctx: Testimony.Context, rng: inout SeededRNG) -> Objection? {
        let onDirect = rng.chance(0.6)
        let asker: Side = onDirect ? w.calledBy : (w.calledBy == .prosecution ? .defense : .prosecution)
        let objector: Side = asker == .prosecution ? .defense : .prosecution
        let lawyer = asker == .prosecution ? "Prosecutor" : "Defense attorney"
        let kind = Testimony.kind(w.role)
        let isDefendant = w.isDefendant == true
        let drafts = candidates(w, ctx: ctx, kind: kind, onDirect: onDirect, asker: asker, isDefendant: isDefendant, rng: &rng)
        guard !drafts.isEmpty else { return nil }
        let d = rng.pick(drafts)
        return Objection(witnessID: w.id, question: "\(lawyer): \"\(d.question)\"", answer: "\"\(d.answer)\"",
                         raisedBy: objector, grounds: d.grounds, shouldSustain: d.sustain,
                         appellateNote: d.explanation, doctrineID: d.doctrine, weightIfAdmitted: d.weight)
    }

    // MARK: Building the choices

    private static func candidates(_ w: Witness, ctx: Testimony.Context, kind: Testimony.Kind, onDirect: Bool, asker: Side,
                                   isDefendant: Bool, rng: inout SeededRNG) -> [Draft] {
        let dl = ctx.dl
        let s = ctx.sheet
        let place = s.place
        let day = s.day
        let time = s.time ?? "that afternoon"
        let victim = ctx.victim
        let favored = asker == .prosecution ? ctx.state : ctx.defense
        let exhibit = favored.isEmpty ? nil : rng.pick(favored)
        let other = rng.pick(["a coworker", "a neighbor", "my cousin", "somebody at the shop", "a friend of a friend", "my sister", "a guy I know from work", "my brother-in-law", "a woman at church", "somebody from my old job", "a man I used to work with", "a friend from the gym", "the guy who runs the corner store"])
        let setting = ctx.setting
        var out: [Draft] = []

        // Hearsay: something a non-witness said, offered for its truth (and against the defendant, so the State asks it).
        if kind == .lay && !isDefendant && asker == .prosecution {
            let rumor = rng.pick([
                "\(other.capitalizedFirst) told me \(dl) had been bragging about it.",
                "\(other.capitalizedFirst) said everybody already knew it was \(dl).",
                "I heard from \(other) that \(dl) was trying to get rid of evidence.",
                "\(other.capitalizedFirst) said \(dl) had done the same kind of thing before.", "\(other.capitalizedFirst) told me \(dl) had been talking big about what happened that night.", "\(other.capitalizedFirst) said \(dl) admitted it at a party the weekend after.", "I heard from \(other) that \(dl) was planning to leave town.", "\(other.capitalizedFirst) told me \(dl) had been bragging that nobody could ever prove anything.", "\(other.capitalizedFirst) said \(dl) had been nervous and sweating when anyone brought it up.", "I heard from \(other) that \(dl) had already been looking for a lawyer before anyone said a word."])
            out.append(Draft(question: rng.pick(["What did you hear about it afterward?", "Did anyone tell you anything about what happened?",
                                                  "What were people saying in the days after \(day)?", "Did you hear anything from other people after it happened?", "What have people told you about what happened?", "What was the talk around town once word got out?", "Did anyone share an opinion with you about who was responsible?", "What did you learn from others in the days that followed?", "Did anybody say anything to you about \(dl) after \(day)?"]),
                             answer: rumor, grounds: "Hearsay", sustain: true,
                             explanation: "An out-of-court statement by someone who isn't testifying, offered to prove \(dl) did it. No exception applies.",
                             doctrine: "hearsay", weight: 2))
        }

        // Excited utterance: only where there was a sudden, startling event.
        if setting == .scene || setting == .road, kind == .lay, !isDefendant, Testimony.sawEvents(w) {
            let speaker = victim.map { rng.pick([$0, "a bystander", "the person next to me"]) } ?? rng.pick(["a bystander", "a woman on the sidewalk", "the driver behind me", "a man walking his dog", "a cashier standing in the doorway", "a passerby", "the person behind me", "a teenager on the corner", "the clerk from the store"])
            let shout = setting == .road
                ? rng.pick(["\"Oh my God, they ran the light!\"", "\"That car came out of nowhere, it was flying!\"", "\"Somebody call 911, they're not moving!\"", "\"Oh no, they hit that car head on!\"", "\"Stop! Stop the car!\"", "\"They didn't even brake, did you see that?\"", "\"Somebody help, there are people in that car!\"", "\"That car just blew through the stop sign!\"", "\"Get an ambulance, hurry!\""])
                : rng.pick(["\"Call 911, they've got a weapon!\"", "\"That's the one, right there, stop them!\"", "\"Why would you do that?\"", "\"Stop it, stop it, you're going to hurt somebody!\"", "\"Somebody help, they're not breathing!\"", "\"Get back, everybody get back!\"", "\"Don't let them get away!\"", "\"That's them, that's who did it!\"", "\"Somebody help, they're hurt bad!\""])
            out.append(Draft(question: rng.pick(["What did you hear in the seconds right after?", "Did anyone say anything right then?", "Did you hear anyone cry out as it happened?", "What was said in the first moments?", "Did anybody shout anything?", "What were the first words you heard?", "Immediately afterward, what did you hear from the people around you?", "Was anything said at the moment it happened?"]),
                             answer: "\(speaker.capitalizedFirst) was shaking and yelled, \(shout)", grounds: "Hearsay", sustain: false,
                             explanation: "A statement made while the speaker was still under the stress of a startling event is an excited utterance (Rule 803(2)).",
                             doctrine: "hearsayExceptions", weight: 1))
        }

        // The defendant's own words are not hearsay when the State offers them.
        if asker == .prosecution, !isDefendant, kind != .expert {
            let words: String
            switch setting {
            case .road: words = rng.pick(["\"I only had a couple, I'm fine to drive.\"", "\"I didn't even see them until it was too late.\"", "\"Please don't call the cops, I can't lose my license.\"", "\"I wasn't going that fast, I swear.\"", "\"I had a drink at dinner, that's all.\"", "\"I looked down for one second, and that's all it took.\"", "\"I was just trying to get home.\"", "\"I know I shouldn't have been behind the wheel.\"", "\"My phone buzzed and I looked.\""])
            case .paper: words = rng.pick(["\"I was going to pay it all back before anyone noticed.\"", "\"Everybody moves money around like that here.\"", "\"Just don't look too hard at the March statements.\"", "\"I was going to put it back before the audit.\"", "\"Nobody ever checked, so I kept going.\"", "\"I figured the company wouldn't miss it.\"", "\"It was only supposed to be until payday.\"", "\"I'll fix the numbers before the board sees them.\"", "\"Don't ask me about the second account.\""])
            case .drugs: words = rng.pick(["\"That's not mine, I was just holding it for somebody.\"", "\"I only sell to people I know.\"", "\"How much do you think that's worth?\"", "\"I get it from a guy over in Dunmore Mills.\"", "\"Whose is it? It's my cousin's. I just moved it.\"", "\"Don't touch the stash in the back room.\"", "\"Cash only, no names, that's how it works.\"", "\"I'm not paying for it until it moves.\"", "\"Keep it quiet, there've been cops on this street.\""])
            case .scene: words = rng.pick(["\"They had it coming.\"", "\"I never meant for it to go that far.\"", "\"You didn't see anything, understand?\"", "\"I just snapped.\"", "\"I told them to stay away from me.\"", "\"Nobody's going to believe them over me.\"", "\"It's not like I planned it.\"", "\"I didn't think anybody would actually get hurt.\"", "\"I'd do it again.\""])
            }
            out.append(Draft(question: rng.pick(["Did \(dl) say anything to you about it?", "What did \(dl) say when you spoke afterward?", "Did you ever talk with \(dl) about what happened?", "What, if anything, did \(dl) tell you?", "When you saw \(dl) after \(day), what did \(dl) say?", "Did \(dl) ever mention it to you?", "Did \(dl) make any comment to you afterward?", "What did \(dl) say to you directly?"]),
                             answer: "\(dl) told me, \(words)", grounds: "Hearsay", sustain: false,
                             explanation: "A party's own statement offered against that party is not hearsay (Rule 801(d)).",
                             doctrine: "partyAdmission", weight: 2))
        }

        // Speculation about what someone else was thinking, written to the case type (against the defendant, so the State asks it).
        if !isDefendant && kind != .expert && asker == .prosecution {
            let guess: String
            switch setting {
            case .road: guess = rng.pick(["\(dl) must have known they were too drunk to drive.", "\(dl) was probably texting. Why else would they drift like that?", "\(dl) obviously had no business behind the wheel that night.", "\(dl) was clearly in a hurry and didn't care who was on the road.", "\(dl) must have fallen asleep. That's the only explanation.", "\(dl) had to be on the phone. Nobody drifts like that otherwise.", "\(dl) was clearly trying to beat the light.", "\(dl) was probably angry about something and took it out on the road."])
            case .paper: guess = rng.pick(["\(dl) obviously knew the books would never be audited.", "\(dl) must have been planning to leave town with it.", "\(dl) must have known nobody was checking the accounts.", "\(dl) was surely covering for a gambling habit.", "\(dl) clearly planned to put the money back and never got to.", "\(dl) probably thought nobody would ever notice.", "\(dl) was obviously hiding something from the owners.", "\(dl) must have been in serious money trouble."])
            case .drugs: guess = rng.pick(["\(dl) had to know what was in that bag.", "Anybody in that house knew what was going on.", "\(dl) must have known exactly who was coming and going.", "Everybody there knew whose stuff that was.", "\(dl) obviously knew the car was loaded.", "\(dl) had to know what was in that room.", "Anybody living there would have to know what was in the closet.", "\(dl) was surely selling it. Why else would there be so much?"])
            case .scene: guess = rng.pick(["\(dl) went there looking for a fight.", "\(dl) wanted to scare \(victim ?? "them") into keeping quiet.", "\(dl) was clearly looking to settle a score.", "\(dl) came there angry and ready for trouble.", "\(dl) was never going to back down.", "\(dl) had been planning something for weeks.", "\(dl) was trying to intimidate everybody in the room.", "\(dl) obviously meant to cause trouble from the start."])
            }
            out.append(Draft(question: rng.pick(["Why do you think \(dl) did it?", "What do you think was going through \(dl)'s mind?",
                                                  "In your view, what was \(dl) thinking?", "Why do you think \(dl) acted that way?", "What was \(dl) trying to accomplish, in your opinion?", "What do you believe \(dl) knew at the time?", "What do you think \(dl) intended?", "Do you have a sense of what \(dl) wanted?", "What do you think was the reason?"]),
                             answer: guess, grounds: "Speculation", sustain: true,
                             explanation: "The witness has no personal knowledge of what \(dl) knew or intended (Rules 602, 701).",
                             doctrine: "speculation", weight: 1))
        }

        // Leading on direct.
        if asker == w.calledBy {
            let lead: String
            if asker == .prosecution {
                switch setting {
                case .road: lead = rng.pick(["And the car was going well over the speed limit, wasn't it?", "You smelled alcohol on the driver, didn't you?", "And the driver was weaving between lanes, wasn't that right?", "You could smell alcohol coming from the car, correct?", "And the driver never braked before the impact, right?", "The driver was slurring words, wasn't that your observation?", "And the vehicle crossed the center line, didn't it?", "You saw the driver run the stop sign, correct?"])
                case .paper: lead = rng.pick(["And those transfers were never approved by anyone, were they?", "You never authorized those payments, correct?", "And you never saw any approval for those payments, did you?", "Nobody in the company authorized those withdrawals, correct?", "The records show those transfers happened late at night, don't they?", "And those transfers were buried in the monthly reports, weren't they?", "You had never seen that account before this investigation, correct?", "And no one ever gave \(dl) permission to move that money, right?"])
                case .drugs: lead = rng.pick(["And the bag was right next to where \(dl) was sitting, wasn't it?", "The money was bundled the way dealers bundle it, correct?", "And you found the scale in plain view, didn't you?", "The packaging was consistent with sale, correct?", "And \(dl) was the only person in the car, wasn't that so?", "The bag was within arm's reach of \(dl), wasn't it?", "And there was cash in the console next to the drugs, correct?", "\(dl) lived at that address, correct?"])
                case .scene: lead = rng.pick(["And it was \(dl) you saw at \(place), wasn't it?", "\(dl) swung first, correct?", "And \(dl) was the first to throw a punch, wasn't that so?", "You saw \(dl) leave right after it happened, didn't you?", "And \(dl) was angry that night, correct?", "\(dl) threatened them before it happened, correct?", "And \(dl) was the only person standing near \(place), wasn't that right?", "You saw \(dl) at \(place) that day, correct?"])
                }
            } else {
                // The defense leading its own witness toward a defense-friendly answer.
                switch setting {
                case .road: lead = rng.pick(["And \(dl) seemed perfectly steady to you that night, correct?", "The road was dark and wet, wasn't it?", "And \(dl) never swerved or crossed the line, correct?", "\(dl) was driving at a normal speed, wasn't that your impression?", "You didn't smell alcohol on \(dl), did you?", "The other driver came out of nowhere, correct?", "And \(dl) did everything the officer asked, correct?", "The pavement was slick that night, wasn't it?"])
                case .paper: lead = rng.pick(["And everyone in that office knew about those transfers, correct?", "Management signed off on that kind of payment all the time, correct?", "And nobody ever told \(dl) that those payments were wrong, correct?", "The company had no written policy against that, did it?", "And your supervisors knew exactly what was being done, correct?", "Several employees had the same system access, correct?", "\(dl) never tried to hide anything, right?", "And the software allowed anyone in the office to make those entries, right?"])
                case .drugs: lead = rng.pick(["And other people used that space all the time, correct?", "\(dl) never had anything to do with that bag, right?", "And you never saw \(dl) touching that bag, did you?", "Several people had keys to that house, correct?", "Nobody saw \(dl) handing anything to anyone, right?", "And the bag could have belonged to anyone in that car, couldn't it?", "\(dl) was cooperative the whole time, wasn't that right?", "There was nothing with \(dl)'s name on it in that room, correct?"])
                case .scene: lead = rng.pick(["And \(dl) was only trying to get away, right?", "\(dl) never threw a punch, right?", "And \(dl) tried to walk away first, correct?", "\(dl) never raised a hand until cornered, correct?", "\(dl) tried to calm everyone down, correct?", "And \(dl) was shoved first, wasn't that right?", "You never saw \(dl) with a weapon, did you?", "And \(dl) backed away more than once, correct?"])
                }
            }
            out.append(Draft(question: lead, answer: rng.pick(["Yes, that's right.", "Yes.", "That's correct.", "That's right.", "Correct."]), grounds: "Leading", sustain: true,
                             explanation: "A leading question on direct suggests the answer the lawyer wants (Rule 611(c)). Nothing here justifies leading.",
                             doctrine: "leading", weight: asker == .prosecution ? 1 : -1))
            if kind == .lay && rng.chance(0.5) {
                out.append(Draft(question: rng.pick(["You were at \(place) on \(day), correct?", "You've known \(dl) for a few years, right?", "You're familiar with \(place), right?", "You were present at \(place) on \(day), weren't you?", "You've lived in this county for several years, correct?", "You came here today under subpoena, right?", "You know \(dl) personally, correct?", "You gave a statement to the police, didn't you?"]),
                                 answer: "Yes.", grounds: "Leading", sustain: false,
                                 explanation: "Leading is allowed on preliminary, undisputed matters to move testimony along (Rule 611(c)).",
                                 doctrine: "leading", weight: 0))
            }
        }

        // Character and prior acts.
        if !isDefendant {
            let history: String
            switch setting {
            case .road: history = rng.pick(["Everybody knows \(dl) drinks every weekend and drives home anyway.", "\(dl) wrecked a car two years ago too.", "\(dl) got a speeding ticket just last month.", "\(dl) has been seen leaving the bar drunk on more than one occasion.", "\(dl) lost a license once before. Everyone knows that.", "Everybody in town knows \(dl) has a problem with alcohol.", "\(dl) had another close call on that same road last year.", "\(dl) has been in trouble with the DMV before."])
            case .paper: history = rng.pick(["\(dl) got fired from the last job for the same kind of thing.", "\(dl) has always been sloppy with other people's money.", "\(dl) was caught padding an expense report at another company.", "\(dl) has been in trouble over money before. Everyone knows that.", "\(dl) was accused of taking from the cash drawer at the last job.", "\(dl) left the last company under a cloud.", "Folks at the old office say \(dl) always had sticky fingers.", "\(dl) had a bad-check problem years ago."])
            case .drugs: history = rng.pick(["\(dl)'s been dealing on that street for years.", "Everyone in the neighborhood knows what \(dl) does for money.", "\(dl) was arrested for the same thing a few years back.", "Everybody knows \(dl) sells out of that house.", "\(dl) has been running with a bad crowd for years.", "People say \(dl) always has cash and no job.", "\(dl) was picked up with pills before.", "Half the block has bought from \(dl) at one time or another."])
            case .scene: history = rng.pick(["\(dl) has always had a temper. Everybody on the block says so.", "\(dl) got into a fight at the same place last year.", "\(dl) once put somebody in the hospital in a bar fight.", "\(dl) has threatened people before. Everybody around here knows it.", "\(dl) was in a shoving match at that same place last summer.", "\(dl) has a reputation for starting trouble.", "\(dl) was banned from that place for fighting.", "\(dl) has been violent with people before. I've heard it more than once."])
            }
            if asker == .prosecution {
                out.append(Draft(question: rng.pick(["How would you describe \(dl)?", "What do you know about \(dl)'s history?", "What kind of person is \(dl)?", "What have you heard about \(dl) over the years?", "Tell the court about \(dl)'s reputation.", "What is \(dl) known for around here?", "What do you know about \(dl)'s past?", "Has \(dl) been in trouble before?"]),
                                 answer: history, grounds: rng.chance(0.5) ? "Improper character evidence" : "Other bad acts (Rule 404(b))", sustain: true,
                                 explanation: "The State can't prove guilt by showing \(dl) is the kind of person who would do it (Rules 404(a), 404(b)).",
                                 doctrine: rng.chance(0.5) ? "characterEvidence" : "priorActs", weight: 1))
            }
        }

        // Relevance on cross: an irrelevant attack on the witness.
        if asker != w.calledBy && kind == .lay {
            out.append(Draft(question: rng.pick(["Isn't it true you were behind on your rent last year?", "You were divorced twice, weren't you?",
                                                  "You were fired from a job about ten years ago, correct?", "You filed for bankruptcy a while back, isn't that true?", "Someone in your family has been in jail, haven't they?", "You've been late on your car payments, haven't you?", "Your landlord took you to court once, correct?", "You had a bad breakup last year, didn't you?", "You were evicted from an apartment once, weren't you?"]),
                             answer: rng.pick(["What does that have to do with anything?", "...Yes.", "I don't see what my finances have to do with this.", "That was a hard time in my life, and I don't see how it matters.", "Yes, but that's private.", "I don't know why that's being asked.", "...I'd rather not talk about that.", "Yes. That was a long time ago."]), grounds: "Relevance", sustain: true,
                             explanation: "Personal misfortunes unrelated to truthfulness or bias aren't proper impeachment (Rules 401–403, 608).",
                             doctrine: "relevance", weight: 0))
            out.append(Draft(question: rng.pick(["You've talked to \(victim.flatMap { $0 == w.name ? nil : $0 } ?? "the State's investigators") about your testimony before today, haven't you?",
                                                  "Has anyone promised you anything for testifying today?", "Did you review your statement with anyone before testifying today?", "Have you spoken with anyone about this case before today?", "Did you meet with the lawyers before taking the stand?", "Has anyone told you what to say?", "Have you been paid or helped in any way in connection with testifying?", "Did you talk with anybody about your testimony before you came in?"]),
                             answer: rng.pick(["We talked once, about scheduling.", "No. Nobody promised me anything.", "I met with them briefly to go over where to sit.", "No. I was subpoenaed, and that's the only reason I'm here.", "We spoke for a few minutes. Nobody told me what to say.", "No. I'm not getting anything out of this.", "I reviewed my statement with them, yes. That's all we did.", "Just a quick call about parking and what time to come."]), grounds: "Relevance", sustain: false,
                             explanation: "Bias and interest are always fair subjects on cross-examination.",
                             doctrine: "relevance", weight: 0))
        }

        // Officers and investigators, questioned by the State that called them.
        if kind == .investigator && asker == .prosecution {
            if setting == .road {
                out.append(Draft(question: rng.pick(["Based on the damage, how fast was \(dl)'s vehicle going?", "From the scene, what speed would you estimate at impact?", "How fast would you say the vehicle was traveling?", "What speed do you think \(dl)'s vehicle was doing?", "Looking at the damage, how fast was the car going?", "From the damage you saw, how quickly was \(dl) driving?", "What was the vehicle's speed when it hit?", "In your experience, how fast must that vehicle have been traveling?"]),
                                 answer: rng.pick(["At least 70, maybe 75.", "Easily twenty over the limit.", "I'd say sixty-five to seventy, easily.", "Judging by the damage, no less than 60.", "From what I saw, close to 80.", "I've worked a lot of wrecks like this. Somewhere around 65.", "It had to be way over the posted limit. Seventy at least.", "Based on that damage, I'd put it at fifty-five to sixty."]), grounds: "Lay opinion without foundation", sustain: !w.role.lowercased().contains("reconstruct"),
                                 explanation: "Speed estimates from damage require accident reconstruction training. Without it, this is improper opinion (Rules 701, 702).",
                                 doctrine: "expertTestimony", weight: 2))
                let observed = rng.pick(["Fifteen minutes, as required. Nothing in the mouth, no burping or vomiting.", "About ten minutes. We were busy that night.", "A full fifteen minutes. I watched the whole time and nothing went into the mouth.", "Fifteen minutes by the clock on the wall, and I noted the start and end time on the form.", "A bit more than fifteen. I was with \(dl) the entire time.", "I think it was about twelve minutes, but I was watching closely.", "Fifteen minutes. We follow the same routine every time.", "I was right there for the whole period, and I wrote down when it started."])
                // Under fifteen minutes is the textbook failure of the observation period (G.S. 20-139.1(b2)); anything else is weight.
                let tooShort = observed.contains("ten minutes") || observed.contains("twelve minutes")
                out.append(Draft(question: "How long did you observe \(dl) before the breath test?",
                                 answer: observed,
                                 grounds: "Foundation", sustain: tooShort,
                                 explanation: tooShort ? "North Carolina requires the officer to observe the person for at least fifteen minutes before a breath test (G.S. 20-139.1(b2)). An answer of less than that means the foundation for the result is missing."
                                                       : "The question goes to whether the observation period was followed; it's proper, and the answer affects weight.",
                                 doctrine: "chainOfCustody", weight: 1))
            }
            if let item = exhibit, asker == .prosecution {
                out.append(Draft(question: "Who had \(item.phrase) between when it was collected and when it came to court?",
                                 answer: rng.pick(["It went into the evidence locker that night. I don't have the log with me, but it stayed there.",
                                                   "I sealed it, initialed it, and logged it. It went to the lab and came back sealed.", "It was locked in the evidence room until I took it to the lab myself, and I signed for it both times.", "I bagged it at the scene, sealed it, and put it into the locker before my shift ended.", "The property clerk had it after I turned it in. I'd have to check the log for the exact times.", "I handed it to the evidence technician that night, and the log shows who had it after that.", "It stayed sealed in the vault, and the seal was intact when it was brought to court.", "I'm not sure who signed it out in between, but the form should show every person who handled it."]),
                                 grounds: "Chain of custody", sustain: rng.chance(0.35),
                                 explanation: "Minor gaps in the chain of custody go to weight, not admissibility, unless there's reason to suspect tampering (Rule 901).",
                                 doctrine: "chainOfCustody", weight: item.weight))
            }
            out.append(Draft(question: rng.pick(["What did the other witnesses tell you during your investigation?", "What did the neighbors tell you when you canvassed?", "What did people in the area tell you when you spoke with them?", "What did the other people at the scene say to you?", "What did you learn from interviewing the witnesses?", "What did the store employees tell you?", "Who did you talk to, and what did they say?", "What information did you get from the people you interviewed?"]),
                             answer: rng.pick(["They all said it was \(dl).", "Two of them described someone who looked just like \(dl).", "Several people told me they saw \(dl) there.", "One of them said \(dl) was the only one it could have been.", "Everyone I talked to pointed to \(dl).", "Three people told me the same thing: it was \(dl).", "Two of them told me \(dl) had been threatening to do it for weeks.", "They all described \(dl), and one gave me the name."]),
                             grounds: "Hearsay", sustain: true,
                             explanation: "An officer can't relay what others said to prove it true. Those people must testify themselves.",
                             doctrine: "hearsay", weight: 2))
            out.append(Draft(question: "Why did you focus your investigation on \(dl)?",
                             answer: rng.pick(["Because of what we developed early on.", "The evidence kept pointing back to \(dl).", "Several leads we followed early on pointed in that direction.", "Information we received in the first days made \(dl) the person to talk to.", "After the first interviews, \(dl) was the person we needed to speak with.", "We followed the evidence where it led, and it led to \(dl).", "The things we learned in the first week narrowed it down to \(dl).", "Once we put the timeline together, \(dl) was the logical focus."]),
                             grounds: "Hearsay", sustain: false,
                             explanation: "Explaining why the officer took the next step isn't offered for the truth of anything anyone said.",
                             doctrine: "hearsay", weight: 0))
        }

        // Experts.
        if kind == .expert {
            let lab = ctx.state.first { $0.kind == .forensic }
            if asker == w.calledBy && asker == .prosecution {
            out.append(Draft(question: rng.pick(["In your expert opinion, is \(dl) guilty?", "Based on your work, did \(dl) commit this crime?", "Based on your analysis, is \(dl) the person responsible?", "As an expert, would you say \(dl) did this?", "Do you believe \(dl) is guilty?", "From your professional experience, did \(dl) commit this offense?", "Having reviewed everything, is \(dl) guilty or not?", "Is it your opinion that \(dl) committed this crime?"]),
                             answer: "In my opinion, yes.", grounds: "Opinion on guilt", sustain: true,
                             explanation: "An expert may help the factfinder understand evidence, but may not offer an opinion that the defendant is guilty.",
                             doctrine: "expertTestimony", weight: 1))
            }
            if let lab, asker == .prosecution {
                let finding = lab.detail.trimmingCharacters(in: CharacterSet(charactersIn: ". "))
                out.append(Draft(question: "Can you tell the court what the lab report on \(lab.phrase) concluded?",
                                 answer: rng.pick(["I didn't do that analysis myself; a colleague did. But the report says: \(finding).",
                                                   "The analyst who ran it isn't here today. Reading from the report: \(finding).", "The examiner who tested it has since left the lab, but I reviewed the file, and it concludes: \(finding).", "I wasn't the analyst. I'm relaying what the report says: \(finding).", "Another examiner did the bench work, and I read the report afterward. It says: \(finding).", "I can only tell you what the written report says, since someone else did the testing: \(finding).", "The analyst is on leave. I've read the report, and it states: \(finding).", "I didn't run the test. The report that was handed to me says: \(finding)."]),
                                 grounds: "Confrontation Clause", sustain: true,
                                 explanation: "Reading another analyst's testimonial lab conclusions, without that analyst testifying, can violate the right to confrontation; an expert may give an independent opinion but not merely repeat the report.",
                                 doctrine: "hearsay", weight: lab.weight))
            }
            out.append(Draft(question: rng.pick(["How many cases have you testified in?", "What's your training in this field?", "How long have you been doing this work?", "What are your credentials?", "How did you become qualified in this field?", "How many times have you been qualified as an expert?", "Tell the court about your background in this field.", "What certifications do you hold?"]),
                             answer: rng.pick(["Over a hundred, for both sides.", "Two degrees, eight years at the lab, annual proficiency testing.", "About sixty times, mostly in superior court.", "Fifteen years in the field and certification through my professional board.", "I've testified in this courthouse many times, for the prosecution and the defense.", "A master's degree, a year of supervised training, and continuing education every year since.", "Over twenty years, and I've been qualified in every court I've testified in.", "Specialized training from the state, plus regular proficiency tests."]),
                             grounds: "Relevance", sustain: false,
                             explanation: "Qualifications are always relevant to the weight of an expert's opinion (Rule 702).",
                             doctrine: "expertTestimony", weight: 0))
        }

        // Records cases.
        // Only the State asks its own records witness to lay a foundation or to say who took the money.
        if setting == .paper && asker == .prosecution && w.calledBy == .prosecution && onDirect {
            let record = ctx.state.first { $0.kind == .document } ?? exhibit
            if let record {
                let recordAnswer = rng.pick(["It's a printout of our account history. I pulled it myself from the system we use every day.",
                                                   "Somebody in accounting gave it to me. I'm not sure who made it.", "It's a monthly statement for the account. I've seen hundreds of them, and I handle them every day.", "It's a spreadsheet someone emailed me last week. I don't know who built it.", "It looks like a copy of the ledger. I'd have to check with our bookkeeper about who keeps it.", "It's a report I generate from our software every month, and this is the one for that period.", "I found it in a folder on the shared drive. I can't say who put it there.", "It's the bank's record of the account. We get one every month and file it."])
                // A witness who can't say who made the record or how it was kept hasn't laid the foundation (Rule 803(6)).
                let noFoundation = ["Somebody in accounting", "someone emailed me", "I'd have to check", "I can't say who", "I don't know who"].contains { recordAnswer.contains($0) }
                out.append(Draft(question: "I'm handing you \(record.exhibit). What is it?",
                                 answer: recordAnswer,
                                 grounds: "Hearsay (business records foundation)", sustain: noFoundation,
                                 explanation: "Business records come in only with a custodian or qualified witness who can say they were kept in the regular course of business (Rule 803(6)).",
                                 doctrine: "hearsayExceptions", weight: record.weight))
            }
            out.append(Draft(question: "Looking at the totals, would you say \(dl) stole that money?",
                             answer: "Yes. Nobody else had access.", grounds: "Lay opinion", sustain: true,
                             explanation: "Whether the money was stolen is the ultimate question for the factfinder; a lay witness may describe records, not conclude guilt.",
                             doctrine: "speculation", weight: 1))
        }

        // The defendant on the stand.
        if isDefendant && asker == .prosecution {
            if !ctx.defendant.priors.isEmpty {
            out.append(Draft(question: rng.pick(["You've been convicted before, haven't you?", "This isn't your first time in this courtroom, is it?", "You have a criminal record, don't you?", "You've been in trouble with the law before, haven't you?", "You've been convicted of a crime in the past, isn't that right?", "You've stood in front of a judge before, haven't you?", "You've got a record, don't you?", "This isn't the first time you've been charged, is it?"]),
                             answer: "...Yes.", grounds: "Improper impeachment", sustain: false,
                             explanation: "A testifying defendant may be impeached with prior convictions punishable by more than 60 days (Rule 609), but only with the name, date, and sentence, not the details.",
                             doctrine: "priorActs", weight: 1))
            }
            out.append(Draft(question: "So every witness who testified against you is lying?",
                             answer: "I'm saying they're wrong.", grounds: "Argumentative", sustain: true,
                             explanation: "Asking a witness to call other witnesses liars is argumentative and improper.",
                             doctrine: "relevance", weight: 0))
        }

        // Assumes facts not in evidence, built from an exhibit the other side hasn't proven.
        if asker != w.calledBy, let item = exhibit {
            out.append(Draft(question: "After you saw \(item.phrase), you changed your story, didn't you?",
                             answer: "I never changed anything.", grounds: "Assumes facts not in evidence", sustain: rng.chance(0.7),
                             explanation: "The question assumes the witness saw the exhibit and changed an account, which no evidence shows.",
                             doctrine: "relevance", weight: 0))
        }

        // Narrative answers.
        // Never put to the defendant, who can't be asked to tell everything known about themself.
        if asker == w.calledBy && kind == .lay && !isDefendant {
            let aboutDefendant = w.calledBy == .prosecution
            out.append(Draft(question: aboutDefendant ? "Just tell the court everything you know about \(dl)." : "Just tell the court everything that happened that night.",
                             answer: aboutDefendant
                                ? "Where do I start? I've known \(dl) for years, and there were always rumors, and then on \(day) around \(time)..."
                                : "Where do I start? It was \(day), around \(time), and before that there was a whole history, and people were saying...",
                             grounds: "Calls for a narrative", sustain: true,
                             explanation: "An open-ended request for everything the witness knows invites inadmissible material; the court may require question-and-answer form (Rule 611(a)).",
                             doctrine: "relevance", weight: 0))
        }
        return out
    }
}
