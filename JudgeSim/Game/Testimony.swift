import Foundation

/// Turns a witness's key lines into full examinations in open court, and writes the testimony of the
/// investigators, responding officers, analysts, and character witnesses who appear in most real trials.
enum Testimony {

    private static let officialWords = ["detective", "officer", "deputy", "trooper", "agent", "investigator", "examiner",
                                        "analyst", "doctor", "physician", "nurse", "sergeant", "chemist", "accountant", "expert"]

    static func isOfficial(_ role: String) -> Bool {
        let lower = role.lowercased()
        return officialWords.contains { lower.contains($0) }
    }

    private static func lawyer(_ side: Side) -> Side { side }

    /// Full examination built around a witness's key lines from the case.
    static func examination(for w: Witness, isVictim: Bool, defendantLast dl: String, rng: inout SeededRNG) -> [TestimonyExchange] {
        let calling = w.calledBy
        let opposing: Side = calling == .prosecution ? .defense : .prosecution
        let official = isOfficial(w.role)
        var out: [TestimonyExchange] = []

        // Direct
        out.append(.init(phase: .direct, examiner: calling,
                         question: official ? "Please state your name and your position." : "Please tell the court your name and how you're connected to this case.",
                         answer: official ? "\(w.name). I'm a \(w.role.lowercased())."
                                          : (isVictim ? "\(w.name). It happened to me." : "\(w.name). I'm the \(w.role.lowercased()).")))
        if official {
            out.append(.init(phase: .direct, examiner: calling, question: "How long have you done that work?",
                             answer: "\(rng.int(4...22)) years."))
        } else if w.calledBy == .defense {
            out.append(.init(phase: .direct, examiner: calling, question: "How do you know \(dl)?",
                             answer: rng.pick(["We've known each other about \(rng.int(3...20)) years.", "Through work.", "We're neighbors.", "Family."])))
        }
        let prompts = official
            ? ["What did you find?", "Walk the court through what you did.", "What did that show?", "Anything else of note?"]
            : (calling == .prosecution
               ? ["What happened?", "What did you see?", "What happened next?", "What else do you remember?"]
               : ["What can you tell the court?", "What do you know about that night?", "What else?", "Why are you here today?"])
        for (index, line) in w.direct.enumerated() {
            out.append(.init(phase: .direct, examiner: calling, question: prompts[min(index, prompts.count - 1)], answer: line))
        }
        out.append(.init(phase: .direct, examiner: calling,
                         question: official ? "Did you document that at the time?" : "How sure are you about what you've told the court?",
                         answer: official ? "Yes. It's in my report, written the same day."
                                          : (w.weight >= 3 ? "Completely sure." : w.weight >= 2 ? "I'm sure." : "Pretty sure. It's what I remember.")))

        // Cross
        let openers = official
            ? ["You'd agree your report doesn't cover everything that happened that night?",
               "You never personally saw \(dl) commit any crime, did you?"]
            : (calling == .prosecution
               ? ["It all happened quickly, didn't it?", "You'd never met \(dl) before that night?", "You've talked about this case with other people since, haven't you?"]
               : ["You care about \(dl), don't you?", "You weren't with \(dl) the whole night, were you?", "You'd like to see \(dl) go home today?"])
        let opener = rng.pick(openers)
        let openerAnswer: String
        switch opener {
        case let q where q.contains("report doesn't cover"): openerAnswer = "A report covers what matters. It doesn't cover every minute."
        case let q where q.contains("personally saw"): openerAnswer = "No. I wasn't there when it happened."
        case let q where q.contains("quickly"): openerAnswer = w.weight >= 3 ? "It felt slow to me. I saw what I saw." : "...Yes. It was fast."
        case let q where q.contains("never met"): openerAnswer = "No. Never."
        case let q where q.contains("talked about"): openerAnswer = "With my family. Not about the details."
        case let q where q.contains("care about"): openerAnswer = "Yes. That doesn't change what I'm telling you."
        case let q where q.contains("whole night"): openerAnswer = "Not the whole night, no."
        default: openerAnswer = "Of course I would. I'm still telling the truth."
        }
        out.append(.init(phase: .cross, examiner: opposing, question: opener, answer: openerAnswer))
        let crossPrompts = ["Let's be clear about something.", "Isn't it true that there's more to it?", "One more thing."]
        for (index, line) in w.cross.enumerated() {
            let quoted = line.hasPrefix("\"") || line.hasPrefix("\u{201C}")
            out.append(.init(phase: .cross, examiner: opposing,
                             question: quoted ? crossPrompts[min(index, crossPrompts.count - 1)] : "",
                             answer: line))
        }

        // Redirect
        out.append(.init(phase: .redirect, examiner: calling,
                         question: "Does anything you were asked on cross change what you told the court?",
                         answer: w.weight >= 2 ? "No. It doesn't." : "It doesn't change what I remember. I understand why they asked."))
        return out
    }

    /// The lead detective: how the case was built, and what wasn't done.
    static func detective(name: String, agency: String, report: InvestigationReport, statementTaken: Bool,
                          stateEvidence: [Evidence], defendantLast dl: String, alternateSuspectInDefense: Bool,
                          rng: inout SeededRNG) -> Witness {
        var ex: [TestimonyExchange] = [
            .init(phase: .direct, examiner: .prosecution, question: "Please state your name and assignment.",
                  answer: "\(name), \(agency). I was the lead investigator on this case."),
            .init(phase: .direct, examiner: .prosecution, question: "How long have you been a detective?",
                  answer: "\(rng.int(5...18)) years, after \(rng.int(3...8)) years on patrol."),
            .init(phase: .direct, examiner: .prosecution, question: "What did the investigation involve?",
                  answer: "We interviewed \(report.interviews.count - 1) witnesses, " + (report.warrants.isEmpty ? "" : "executed \(report.warrants.count) search warrant\(report.warrants.count == 1 ? "" : "s"), ")
                    + (report.lab.isEmpty ? "and reviewed the records." : "and sent \(report.lab.count) item\(report.lab.count == 1 ? "" : "s") to the State Crime Laboratory.")),
            .init(phase: .direct, examiner: .prosecution, question: "How did \(dl) become a suspect?", answer: report.howIdentified),
            .init(phase: .direct, examiner: .prosecution, question: "What evidence did you develop?",
                  answer: stateEvidence.prefix(4).map(\.title).joined(separator: ", ") + "."),
            .init(phase: .direct, examiner: .prosecution, question: "Did \(dl) give a statement?",
                  answer: statementTaken ? "Yes, after I read the Miranda warnings and \(dl) signed a waiver. It was recorded."
                                         : "No. \(dl) asked for a lawyer, and the interview ended.")
        ]
        let gaps = Investigations.gaps.filter { report.notDone.contains($0.finding) }
        for gap in gaps {
            ex.append(.init(phase: .cross, examiner: .defense, question: gap.question, answer: gap.answer))
        }
        ex.append(.init(phase: .cross, examiner: .defense, question: "Did you ever seriously consider anyone other than \(dl)?",
                        answer: alternateSuspectInDefense ? "We looked at it. Not as closely as we might have." : "We followed the evidence. It led to \(dl)."))
        ex.append(.init(phase: .cross, examiner: .defense, question: "Once you had a suspect, you stopped looking, didn't you?",
                        answer: "No. We kept working the case through the arrest."))
        ex.append(.init(phase: .redirect, examiner: .prosecution, question: "Why did the investigation focus on \(dl)?",
                        answer: "Because of what the evidence showed. " + report.howIdentified))
        return witness(name: name, role: "Lead investigator, \(agency)", side: .prosecution, exchanges: ex)
    }

    /// The first officer on scene.
    static func firstOfficer(name: String, agency: String, report: InvestigationReport, defendantLast dl: String,
                             rng: inout SeededRNG) -> Witness {
        let late = rng.chance(0.4)
        let ex: [TestimonyExchange] = [
            .init(phase: .direct, examiner: .prosecution, question: "Officer, how did you come to respond?",
                  answer: "I was dispatched by 911 Communications to a call near the scene."),
            .init(phase: .direct, examiner: .prosecution, question: "What did you see when you arrived?", answer: report.scene),
            .init(phase: .direct, examiner: .prosecution, question: "What did you do?",
                  answer: "Checked on everyone's safety, separated the people present, secured the area, and called for a detective and evidence technicians."),
            .init(phase: .direct, examiner: .prosecution, question: "Was your body camera running?",
                  answer: late ? "Yes. I activated it about two minutes after I arrived." : "Yes, from the moment I got out of the car."),
            .init(phase: .cross, examiner: .defense, question: "You didn't see any crime being committed, did you?",
                  answer: "No. It was over when I got there."),
            .init(phase: .cross, examiner: .defense, question: late ? "So the first two minutes aren't on video?" : "Did you write down what people told you word for word?",
                  answer: late ? "That's right." : "I wrote down the substance. Not every word."),
            .init(phase: .cross, examiner: .defense, question: "Did anyone at the scene name \(dl) to you?",
                  answer: rng.pick(["Not by name. They gave a description.", "One person did, yes.", "No, not that night."]))
        ]
        return witness(name: name, role: "Responding officer, \(agency)", side: .prosecution, exchanges: ex)
    }

    /// A State Crime Laboratory analyst.
    static func analyst(name: String, forensic: [Evidence], defendantLast dl: String, rng: inout SeededRNG) -> Witness {
        var ex: [TestimonyExchange] = [
            .init(phase: .direct, examiner: .prosecution, question: "Where do you work, and what do you do?",
                  answer: "The North Carolina State Crime Laboratory. I'm a forensic scientist; I've worked there \(rng.int(3...19)) years."),
            .init(phase: .direct, examiner: .prosecution, question: "Is the laboratory accredited?",
                  answer: "Yes, under international standards. Our methods are validated and peer-reviewed.")
        ]
        for item in forensic.prefix(3) {
            ex.append(.init(phase: .direct, examiner: .prosecution, question: "What did you conclude about \(item.title.lowercased())?",
                            answer: item.detail))
        }
        ex.append(.init(phase: .cross, examiner: .defense, question: "Your analysis can't tell the court when or how that was left, can it?",
                        answer: "No. It tells you what, not when or how."))
        ex.append(.init(phase: .cross, examiner: .defense, question: "Were there items from this case the agency never sent you?",
                        answer: rng.chance(0.5) ? "Yes. Some items weren't submitted for testing." : "Not that I'm aware of."))
        ex.append(.init(phase: .cross, examiner: .defense, question: "Has your lab ever had to correct a result?",
                        answer: "Every lab has corrected errors. That's why there's a review process, and this result was reviewed."))
        return witness(name: name, role: "Forensic scientist, State Crime Laboratory", side: .prosecution, exchanges: ex)
    }

    /// A supervisor or longtime acquaintance who speaks to the defendant's character and work.
    static func characterWitness(name: String, profile: DefendantProfile?, defendantLast dl: String, rng: inout SeededRNG) -> Witness {
        let job = profile?.jobs.first { $0.current && $0.title != "Unemployed" }
        let role = job.map { "\(dl)'s supervisor at \($0.employer)" } ?? "\(dl)'s longtime neighbor"
        let ex: [TestimonyExchange] = [
            .init(phase: .direct, examiner: .defense, question: "How do you know \(dl)?",
                  answer: job.map { "I've supervised \(dl) at \($0.employer) since \($0.years.prefix(4))." } ?? "We've lived next door to each other for \(rng.int(4...15)) years."),
            .init(phase: .direct, examiner: .defense, question: "What is \(dl)'s reputation for honesty and peacefulness?",
                  answer: rng.pick(["Good. People trust \(dl).", "I've never heard a bad word about \(dl).", "Reliable. Shows up, does the work, no trouble."])),
            .init(phase: .direct, examiner: .defense, question: "Has anything about \(dl) changed since the arrest?",
                  answer: rng.pick(["Quieter. Worried. Still shows up.", "Not that I've seen.", "Stressed, like anyone would be."])),
            .init(phase: .cross, examiner: .prosecution, question: "You weren't there when this happened, were you?", answer: "No."),
            .init(phase: .cross, examiner: .prosecution, question: "You don't know what \(dl) does when you're not around?",
                  answer: "Nobody knows that about anybody. I know who I've seen."),
            .init(phase: .cross, examiner: .prosecution, question: "If \(dl) were convicted, you'd lose a good worker. You have a stake in this.",
                  answer: job == nil ? "I don't employ \(dl). I'm just a neighbor." : "I'd lose a good worker. I'd still tell you the truth.")
        ]
        return witness(name: name, role: role, side: .defense, exchanges: ex)
    }

    /// The defendant's own testimony, as a full examination.
    static func defendant(_ base: Witness, defendantLast dl: String, holds: Bool, strongestState: String?) -> [TestimonyExchange] {
        var ex: [TestimonyExchange] = [
            .init(phase: .direct, examiner: .defense, question: "Tell the court about yourself.", answer: "\(base.name). I live here in the county. I work, I take care of my family."),
            .init(phase: .direct, examiner: .defense, question: "Did you do what the State says?", answer: "No, Your Honor. Not the way they describe it.")
        ]
        for line in base.direct { ex.append(.init(phase: .direct, examiner: .defense, question: "Tell the court what happened.", answer: line)) }
        ex.append(.init(phase: .cross, examiner: .prosecution,
                        question: "Explain \(strongestState.map { "the \($0.lowercased())" } ?? "the State's evidence"), then.",
                        answer: holds ? "I can. It's not what it looks like, and I told the detective the same thing." : "I... I don't know how to explain that."))
        ex.append(.init(phase: .cross, examiner: .prosecution, question: "You've had months to come up with this story, haven't you?",
                        answer: holds ? "I've had months to think about the truth. It hasn't changed." : "That's not fair. I'm telling you what I remember."))
        for line in base.cross { ex.append(.init(phase: .cross, examiner: .prosecution, question: "", answer: line)) }
        ex.append(.init(phase: .redirect, examiner: .defense, question: "Why did you choose to testify?",
                        answer: "Because I wanted you to hear it from me."))
        return ex
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
