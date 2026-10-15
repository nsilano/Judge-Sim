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
        let other = rng.pick(["a coworker", "a neighbor", "my cousin", "somebody at the shop", "a friend of a friend", "my sister", "a guy I know from work"])
        let setting = ctx.setting
        var out: [Draft] = []

        // Hearsay: something a non-witness said, offered for its truth.
        if kind == .lay && !isDefendant {
            let rumor = rng.pick([
                "\(other.capitalizedFirst) told me \(dl) had been bragging about it.",
                "\(other.capitalizedFirst) said everybody already knew it was \(dl).",
                "I heard from \(other) that \(dl) was trying to get rid of evidence.",
                "\(other.capitalizedFirst) said \(dl) had done the same kind of thing before."])
            out.append(Draft(question: rng.pick(["What did you hear about it afterward?", "Did anyone tell you anything about what happened?",
                                                  "What were people saying in the days after \(day)?"]),
                             answer: rumor, grounds: "Hearsay", sustain: true,
                             explanation: "An out-of-court statement by someone who isn't testifying, offered to prove \(dl) did it. No exception applies.",
                             doctrine: "hearsay", weight: 2))
        }

        // Excited utterance: only where there was a sudden, startling event.
        if setting == .scene || setting == .road, kind == .lay, !isDefendant, Testimony.sawEvents(w) {
            let speaker = victim.map { rng.pick([$0, "a bystander", "the person next to me"]) } ?? rng.pick(["a bystander", "a woman on the sidewalk", "the driver behind me"])
            let shout = setting == .road
                ? rng.pick(["\"Oh my God, they ran the light!\"", "\"That car came out of nowhere, it was flying!\"", "\"Somebody call 911, they're not moving!\""])
                : rng.pick(["\"Call 911, they've got a weapon!\"", "\"That's the one, right there, stop them!\"", "\"Why would you do that?\""])
            out.append(Draft(question: rng.pick(["What did you hear in the seconds right after?", "Did anyone say anything right then?"]),
                             answer: "\(speaker.capitalizedFirst) was shaking and yelled, \(shout)", grounds: "Hearsay", sustain: false,
                             explanation: "A statement made while the speaker was still under the stress of a startling event is an excited utterance (Rule 803(2)).",
                             doctrine: "hearsayExceptions", weight: 1))
        }

        // The defendant's own words are not hearsay when the State offers them.
        if asker == .prosecution, !isDefendant, kind != .expert {
            let words: String
            switch setting {
            case .road: words = rng.pick(["\"I only had a couple, I'm fine to drive.\"", "\"I didn't even see them until it was too late.\"", "\"Please don't call the cops, I can't lose my license.\""])
            case .paper: words = rng.pick(["\"I was going to pay it all back before anyone noticed.\"", "\"Everybody moves money around like that here.\"", "\"Just don't look too hard at the March statements.\""])
            case .drugs: words = rng.pick(["\"That's not mine, I was just holding it for somebody.\"", "\"I only sell to people I know.\"", "\"How much do you think that's worth?\""])
            case .scene: words = rng.pick(["\"They had it coming.\"", "\"I never meant for it to go that far.\"", "\"You didn't see anything, understand?\""])
            }
            out.append(Draft(question: rng.pick(["Did \(dl) say anything to you about it?", "What did \(dl) say when you spoke afterward?"]),
                             answer: "\(dl) told me, \(words)", grounds: "Hearsay", sustain: false,
                             explanation: "A party's own statement offered against that party is not hearsay (Rule 801(d)).",
                             doctrine: "partyAdmission", weight: 2))
        }

        // Speculation about what someone else was thinking, written to the case type.
        if !isDefendant && kind != .expert {
            let guess: String
            switch setting {
            case .road: guess = rng.pick(["\(dl) must have known they were too drunk to drive.", "\(dl) was probably texting. Why else would they drift like that?"])
            case .paper: guess = rng.pick(["\(dl) obviously knew the books would never be audited.", "\(dl) must have been planning to leave town with it."])
            case .drugs: guess = rng.pick(["\(dl) had to know what was in that bag.", "Anybody in that house knew what was going on."])
            case .scene: guess = rng.pick(["\(dl) went there looking for a fight.", "\(dl) wanted to scare \(victim ?? "them") into keeping quiet."])
            }
            out.append(Draft(question: rng.pick(["Why do you think \(dl) did it?", "What do you think was going through \(dl)'s mind?",
                                                  "In your view, what was \(dl) thinking?"]),
                             answer: guess, grounds: "Speculation", sustain: true,
                             explanation: "The witness has no personal knowledge of what \(dl) knew or intended (Rules 602, 701).",
                             doctrine: "speculation", weight: 1))
        }

        // Leading on direct.
        if asker == w.calledBy {
            let lead: String
            switch setting {
            case .road: lead = rng.pick(["And the car was going well over the speed limit, wasn't it?", "You smelled alcohol on the driver, didn't you?"])
            case .paper: lead = rng.pick(["And those transfers were never approved by anyone, were they?", "You never authorized those payments, correct?"])
            case .drugs: lead = rng.pick(["And the bag was right next to where \(dl) was sitting, wasn't it?", "The money was bundled the way dealers bundle it, correct?"])
            case .scene: lead = rng.pick(["And it was \(dl) you saw at \(place), wasn't it?", "\(dl) swung first, didn't they?"])
            }
            out.append(Draft(question: lead, answer: rng.pick(["Yes, that's right.", "Yes.", "That's correct."]), grounds: "Leading", sustain: true,
                             explanation: "A leading question on direct suggests the answer the lawyer wants (Rule 611(c)). Nothing here justifies leading.",
                             doctrine: "leading", weight: 1))
            if kind == .lay && rng.chance(0.5) {
                out.append(Draft(question: rng.pick(["You were at \(place) on \(day), correct?", "You've known \(dl) for a few years, right?"]),
                                 answer: "Yes.", grounds: "Leading", sustain: false,
                                 explanation: "Leading is allowed on preliminary, undisputed matters to move testimony along (Rule 611(c)).",
                                 doctrine: "leading", weight: 0))
            }
        }

        // Character and prior acts.
        if !isDefendant {
            let history: String
            switch setting {
            case .road: history = rng.pick(["Everybody knows \(dl) drinks every weekend and drives home anyway.", "\(dl) wrecked a car two years ago too."])
            case .paper: history = rng.pick(["\(dl) got fired from the last job for the same kind of thing.", "\(dl) has always been sloppy with other people's money."])
            case .drugs: history = rng.pick(["\(dl)'s been dealing on that street for years.", "Everyone in the neighborhood knows what \(dl) does for money."])
            case .scene: history = rng.pick(["\(dl) has always had a temper. Everybody on the block says so.", "\(dl) got into a fight at the same place last year."])
            }
            if asker == .prosecution {
                out.append(Draft(question: rng.pick(["How would you describe \(dl)?", "What do you know about \(dl)'s history?"]),
                                 answer: history, grounds: rng.chance(0.5) ? "Improper character evidence" : "Other bad acts (Rule 404(b))", sustain: true,
                                 explanation: "The State can't prove guilt by showing \(dl) is the kind of person who would do it (Rules 404(a), 404(b)).",
                                 doctrine: rng.chance(0.5) ? "characterEvidence" : "priorActs", weight: 1))
            }
        }

        // Relevance on cross: an irrelevant attack on the witness.
        if asker != w.calledBy && kind == .lay {
            out.append(Draft(question: rng.pick(["Isn't it true you were behind on your rent last year?", "You were divorced twice, weren't you?",
                                                  "You were fired from a job about ten years ago, correct?"]),
                             answer: rng.pick(["What does that have to do with anything?", "...Yes."]), grounds: "Relevance", sustain: true,
                             explanation: "Personal misfortunes unrelated to truthfulness or bias aren't proper impeachment (Rules 401–403, 608).",
                             doctrine: "relevance", weight: 0))
            out.append(Draft(question: rng.pick(["You've talked to \(victim ?? "the State's investigators") about your testimony before today, haven't you?",
                                                  "Has anyone promised you anything for testifying today?"]),
                             answer: rng.pick(["We talked once, about scheduling.", "No. Nobody promised me anything."]), grounds: "Relevance", sustain: false,
                             explanation: "Bias and interest are always fair subjects on cross-examination.",
                             doctrine: "relevance", weight: 0))
        }

        // Officers and investigators.
        if kind == .investigator {
            if setting == .road {
                out.append(Draft(question: rng.pick(["Based on the damage, how fast was \(dl)'s vehicle going?", "From the scene, what speed would you estimate at impact?"]),
                                 answer: rng.pick(["At least 70, maybe 75.", "Easily twenty over the limit."]), grounds: "Lay opinion without foundation", sustain: !w.role.lowercased().contains("reconstruct"),
                                 explanation: "Speed estimates from damage require accident reconstruction training. Without it, this is improper opinion (Rules 701, 702).",
                                 doctrine: "expertTestimony", weight: 2))
                out.append(Draft(question: "How long did you observe \(dl) before the breath test?",
                                 answer: rng.pick(["Fifteen minutes, as required. Nothing in the mouth, no burping or vomiting.", "About ten minutes. We were busy that night."]),
                                 grounds: "Foundation", sustain: false,
                                 explanation: "The question goes to whether the observation period was followed; it's proper, and the answer affects weight.",
                                 doctrine: "chainOfCustody", weight: 1))
            }
            if let item = exhibit, asker == .prosecution {
                out.append(Draft(question: "Who had \(item.title.lowercased()) between when it was collected and when it came to court?",
                                 answer: rng.pick(["It went into the evidence locker that night. I don't have the log with me, but it stayed there.",
                                                   "I sealed it, initialed it, and logged it. It went to the lab and came back sealed."]),
                                 grounds: "Chain of custody", sustain: rng.chance(0.35),
                                 explanation: "Minor gaps in the chain of custody go to weight, not admissibility, unless there's reason to suspect tampering (Rule 901).",
                                 doctrine: "chainOfCustody", weight: item.weight))
            }
            out.append(Draft(question: rng.pick(["What did the other witnesses tell you during your investigation?", "What did the neighbors tell you when you canvassed?"]),
                             answer: rng.pick(["They all said it was \(dl).", "Two of them described someone who looked just like \(dl)."]),
                             grounds: "Hearsay", sustain: true,
                             explanation: "An officer can't relay what others said to prove it true. Those people must testify themselves.",
                             doctrine: "hearsay", weight: 2))
            out.append(Draft(question: "Why did you focus your investigation on \(dl)?",
                             answer: rng.pick(["Because of what we developed early on.", "The evidence kept pointing back to \(dl)."]),
                             grounds: "Hearsay", sustain: false,
                             explanation: "Explaining why the officer took the next step isn't offered for the truth of anything anyone said.",
                             doctrine: "hearsay", weight: 0))
        }

        // Experts.
        if kind == .expert {
            let lab = ctx.state.first { $0.kind == .forensic }
            if asker == w.calledBy && asker == .prosecution {
            out.append(Draft(question: rng.pick(["In your expert opinion, is \(dl) guilty?", "Based on your work, did \(dl) commit this crime?"]),
                             answer: "In my opinion, yes.", grounds: "Opinion on guilt", sustain: true,
                             explanation: "An expert may help the factfinder understand evidence, but may not offer an opinion that the defendant is guilty.",
                             doctrine: "expertTestimony", weight: 1))
            }
            if let lab, asker == .prosecution {
                let finding = lab.detail.trimmingCharacters(in: CharacterSet(charactersIn: ". "))
                out.append(Draft(question: "Can you tell the court what the lab report on the \(lab.title.lowercased()) concluded?",
                                 answer: rng.pick(["I didn't do that analysis myself; a colleague did. But the report says: \(finding).",
                                                   "The analyst who ran it isn't here today. Reading from the report: \(finding)."]),
                                 grounds: "Confrontation Clause", sustain: rng.chance(0.6),
                                 explanation: "Reading another analyst's testimonial lab conclusions, without that analyst testifying, can violate the right to confrontation; an expert may give an independent opinion but not merely repeat the report.",
                                 doctrine: "hearsay", weight: lab.weight))
            }
            out.append(Draft(question: rng.pick(["How many cases have you testified in?", "What's your training in this field?"]),
                             answer: rng.pick(["Over a hundred, for both sides.", "Two degrees, eight years at the lab, annual proficiency testing."]),
                             grounds: "Relevance", sustain: false,
                             explanation: "Qualifications are always relevant to the weight of an expert's opinion (Rule 702).",
                             doctrine: "expertTestimony", weight: 0))
        }

        // Records cases.
        if setting == .paper {
            let record = ctx.state.first { $0.kind == .document } ?? exhibit
            if let record {
                out.append(Draft(question: "I'm handing you \(record.exhibit). What is it?",
                                 answer: rng.pick(["It's a printout of our account history. I pulled it myself from the system we use every day.",
                                                   "Somebody in accounting gave it to me. I'm not sure who made it."]),
                                 grounds: "Hearsay (business records foundation)", sustain: rng.chance(0.4),
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
            out.append(Draft(question: rng.pick(["You've been convicted before, haven't you?", "This isn't your first time in this courtroom, is it?"]),
                             answer: "...Yes.", grounds: "Improper impeachment", sustain: !(ctx.defendant.priors.isEmpty == false && rng.chance(0.6)),
                             explanation: "A testifying defendant may be impeached with prior convictions punishable by more than 60 days (Rule 609), but only with the name, date, and sentence, not the details.",
                             doctrine: "priorActs", weight: 1))
            out.append(Draft(question: "So every witness who testified against you is lying?",
                             answer: "I'm saying they're wrong.", grounds: "Argumentative", sustain: true,
                             explanation: "Asking a witness to call other witnesses liars is argumentative and improper.",
                             doctrine: "relevance", weight: 0))
        }

        // Assumes facts not in evidence, built from an exhibit the other side hasn't proven.
        if asker != w.calledBy, let item = exhibit {
            out.append(Draft(question: "After you saw \(item.title.lowercased()), you changed your story, didn't you?",
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
