import Foundation

/// Courtroom moments that call for a ruling on the spot. At most one per trial, and only now and then.
enum Incidents {
    static func make(for c: CourtCase, rng: inout SeededRNG) -> [CourtIncident] {
        let roll = Double.random(in: 0..<1, using: &rng)
        if roll < 0.05 { return [selfRepresentation(c, rng: &rng)] }
        if roll < 0.11, let i = interpreter(c, rng: &rng) { return [i] }
        if roll < 0.18, let i = discovery(c, rng: &rng) { return [i] }
        if roll < 0.25 { return [outburst(c, rng: &rng)] }
        return []
    }

    // MARK: - A defendant who wants to represent themself (G.S. 15A-1242; Faretta v. California)

    static func selfRepresentation(_ c: CourtCase, rng: inout SeededRNG) -> CourtIncident {
        let d = c.defendant.lastName
        if rng.chance(0.5) {
            // Clear, timely, and knowing: the right must be honored after the statutory inquiry.
            return CourtIncident(
                kind: .selfRepresentation, moment: .beforeTrial, title: "\(d) asks to go to trial without a lawyer",
                body: "Before the State's first witness, \(c.defendant.name) stands: \"Your Honor, I want to represent myself. I've read every page of the discovery, and my lawyer won't file the motions I asked for.\" Asked by the court, \(d) correctly states the charges and the most time \(d) could get, says \(d) has a high school diploma and has read the rules of evidence, and says \(d) understands \(d) will be held to the same rules as a lawyer. Appointed counsel says \(d) is competent and has been clear about this for weeks.",
                lawID: "selfRepresentation",
                options: [
                    IncidentOption(label: "Finish the inquiry, accept the written waiver, and let \(d) proceed with counsel on standby",
                                   result: "\(d) proceeds alone, with appointed counsel at the next table on standby. \(d)'s cross-examination is rough but the record shows a knowing, voluntary waiver.",
                                   proper: true, error: false, effect: .proSe),
                    IncidentOption(label: "Deny the request: \(d) keeps appointed counsel",
                                   result: "\(d) objects for the record and sits back down. The trial goes on with counsel.",
                                   proper: false, error: true,
                                   appealText: "You denied the defendant's clear and timely request to proceed without counsel, made after a full inquiry. Denial of the right of self-representation is structural error."),
                    IncidentOption(label: "Allow it now and skip the rest of the inquiry to save time",
                                   result: "\(d) proceeds alone. The record has no complete inquiry under G.S. 15A-1242.",
                                   proper: false, error: true, effect: .proSe,
                                   appealText: "You allowed the defendant to proceed without counsel without the full inquiry G.S. 15A-1242 requires, so the record doesn't show a knowing and voluntary waiver.")
                ])
        }
        // Equivocal, and not knowing: the court should keep counsel in place.
        return CourtIncident(
            kind: .selfRepresentation, moment: .beforeTrial, title: "\(d) wants a different lawyer, or none at all",
            body: "As the trial is called, \(c.defendant.name) says: \"I don't want this lawyer. I want somebody else. Or I guess I'll just do it myself if I have to.\" Asked by the court, \(d) can't say what the most serious charge carries and says \(d) \"doesn't need to know all that.\" Appointed counsel says they've met six times and is ready for trial.",
            lawID: "selfRepresentation",
            options: [
                IncidentOption(label: "Deny: the request isn't clear and unequivocal, and there's no good cause for new counsel",
                               result: "The trial goes on with appointed counsel. The record shows why.",
                               proper: true, error: false),
                IncidentOption(label: "Let \(d) proceed without a lawyer, with counsel on standby",
                               result: "\(d) proceeds alone, though the inquiry showed \(d) didn't know the maximum punishment.",
                               proper: false, error: true, effect: .proSe,
                               appealText: "You allowed the defendant to waive counsel on an equivocal request, after an inquiry showing the defendant did not understand the possible punishment (G.S. 15A-1242(3))."),
                IncidentOption(label: "Appoint a new lawyer and continue the trial four weeks",
                               result: "New counsel is appointed. The case goes to another date.",
                               proper: false, error: false, effect: .continueCase, days: 28)
            ])
    }

    // MARK: - Interpreters (G.S. 7A-314; AOC standards for court interpreting)

    static func interpreter(_ c: CourtCase, rng: inout SeededRNG) -> CourtIncident? {
        let d = c.defendant.lastName
        let witness = c.witnesses.first { $0.calledBy == .prosecution && $0.name != c.victimName && !$0.role.lowercased().contains("detective")
            && !$0.role.lowercased().contains("officer") && !$0.role.lowercased().contains("deputy") && !$0.role.lowercased().contains("trooper")
            && !$0.role.lowercased().contains("analyst") && !$0.role.lowercased().contains("examiner") }
        switch rng.int(0...2) {
        case 0:
            return CourtIncident(
                kind: .interpreter, moment: .beforeTrial, title: "No Spanish interpreter until this afternoon",
                body: "\(c.defendant.name) speaks Spanish and little English. The certified court interpreter is finishing a hearing in Robeson County and can't be here until about 1:30. \(d)'s teenage son, in the gallery, offers to interpret so the trial can start on time.",
                lawID: "interpreters",
                options: [
                    IncidentOption(label: "Recess until the certified interpreter arrives", result: "The morning is lost. The trial starts at 1:45 with the certified interpreter.",
                                   proper: true, error: false),
                    IncidentOption(label: "Let the son interpret so the trial can start", result: "The son interprets. Twice he summarizes long answers in a few words.",
                                   proper: false, error: true,
                                   appealText: "You let the defendant's teenage son, an untested relative with a stake in the outcome, interpret the trial instead of a qualified court interpreter."),
                    IncidentOption(label: "Proceed; defense counsel speaks some Spanish and can help", result: "Counsel whispers translations when there's time.",
                                   proper: false, error: true,
                                   appealText: "You proceeded without an interpreter for a defendant who could not follow the proceedings in English.")
                ])
        case 1:
            guard let w = witness else { return nil }
            return CourtIncident(
                kind: .interpreter, moment: .beforeTrial, title: "\(w.name) is Deaf; no ASL interpreter today",
                body: "The State's witness \(w.name) (\(w.role.lowercased())) is Deaf and uses American Sign Language. The AOC can't send a certified ASL interpreter until next week. The State asks to proceed with \(w.name) writing answers on a legal pad.",
                lawID: "interpreters",
                options: [
                    IncidentOption(label: "Continue the trial a week for a certified ASL interpreter", result: "The case goes to next week.",
                                   proper: true, error: false, effect: .continueCase, days: 7),
                    IncidentOption(label: "Proceed with written answers on a pad", result: "\(w.name) writes answers; cross-examination crawls and the defense objects throughout.",
                                   proper: false, error: true,
                                   appealText: "You let a Deaf State witness testify by handwritten notes instead of through a qualified interpreter, limiting cross-examination."),
                    IncidentOption(label: "Proceed today without \(w.name)'s testimony", result: "The State goes forward without \(w.name).",
                                   proper: false, error: false, effect: .removeWitness, witnessID: w.id)
                ])
        default:
            return CourtIncident(
                kind: .interpreter, moment: .beforeTrial, title: "A Vietnamese interpreter, by video only",
                body: "\(c.defendant.name)'s first language is Vietnamese. No Vietnamese interpreter can come in person this month, but a certified interpreter can appear by video from Raleigh today. A bailiff who speaks some Vietnamese has also offered.",
                lawID: "interpreters",
                options: [
                    IncidentOption(label: "Proceed with the certified interpreter by video", result: "The trial goes on with the interpreter on a screen beside the witness stand.",
                                   proper: true, error: false),
                    IncidentOption(label: "Continue the trial until an interpreter can be here in person", result: "The case goes to another date, five weeks out.",
                                   proper: false, error: false, effect: .continueCase, days: 35),
                    IncidentOption(label: "Use the bailiff to interpret", result: "The bailiff interprets, with long pauses, while also guarding the defendant.",
                                   proper: false, error: true,
                                   appealText: "You used a bailiff with no interpreter qualification, who was also guarding the defendant, as the trial interpreter.")
                ])
        }
    }

    // MARK: - Discovery not turned over (G.S. 15A-903, 15A-910; Brady v. Maryland)

    static func discovery(_ c: CourtCase, rng: inout SeededRNG) -> CourtIncident? {
        let d = c.defendant.lastName
        let target = c.evidence.filter { $0.side == .prosecution && $0.weight >= 2 }.max { $0.weight < $1.weight }
        switch rng.int(0...2) {
        case 0:
            return CourtIncident(
                kind: .discovery, moment: .trial, title: "A supplemental report never turned over",
                body: "During the State's case, the defense learns that the lead investigator wrote a two-page supplemental report that was never given to the defense. It mostly repeats the main report, but adds the time a neighbor was interviewed. The ADA says it was an oversight and hands it over now.",
                lawID: "discoverySanctions",
                options: [
                    IncidentOption(label: "Recess until tomorrow so the defense can review it and recall the witness",
                                   result: "The defense reviews the report overnight and recalls the investigator for ten minutes of cross.", proper: true, error: false),
                    IncidentOption(label: "Declare a mistrial", result: "The trial ends; the case is set again.", proper: false, error: true, effect: .mistrial, days: 42,
                                   appealText: "You declared a mistrial over a minor, curable discovery lapse, a sanction far beyond what G.S. 15A-910 contemplates."),
                    IncidentOption(label: "Note the violation and go on without a recess",
                                   result: "The defense cross-examines without having read the report.", proper: false, error: true,
                                   appealText: "You found a discovery violation and gave the defense no time to use the late report (G.S. 15A-910).")
                ])
        case 1:
            guard let e = target else { return nil }
            return CourtIncident(
                kind: .discovery, moment: .trial, title: "Body camera video the defense never saw",
                body: "Mid-trial, the defense learns that a deputy's body camera recorded part of the investigation behind \(e.exhibit) (\(e.title.lowercased())), and the video was never disclosed. The defense says it can't test \(e.exhibit) without it. The ADA says the State didn't plan to use the video.",
                lawID: "discoverySanctions",
                options: [
                    IncidentOption(label: "Exclude \(e.exhibit): the State can't rely on it", result: "\(e.exhibit) is out of the case.",
                                   proper: true, error: false, effect: .excludeEvidence, evidenceID: e.id,
                                   laterHeadline: "Judge excludes evidence after deputy's video withheld",
                                   laterBody: "In \(c.caption), Judge {JUDGE} kept out a piece of the State's evidence after learning a deputy's body camera video was never turned over to the defense."),
                    IncidentOption(label: "Recess two days for the defense to review the video", result: "The defense reviews the video; \(e.exhibit) stays in.",
                                   proper: true, error: false),
                    IncidentOption(label: "Deny any remedy; the State didn't plan to use the video", result: "\(e.exhibit) comes in. The defense never sees the video.",
                                   proper: false, error: true,
                                   appealText: "You denied any remedy after finding the State withheld body camera video bearing on \(e.exhibit) (G.S. 15A-903, 15A-910).")
                ])
        default:
            return CourtIncident(
                kind: .discovery, moment: .trial, title: "A statement naming someone else",
                body: "On the second day of trial, the defense learns that a witness told an officer, early on, that \"it was the cousin, not \(d)\" and later took it back. The statement was in the ADA's file. The ADA says it was overlooked. The defense moves for a mistrial.",
                lawID: "discoverySanctions",
                options: [
                    IncidentOption(label: "Grant the defense's motion for a mistrial", result: "The trial ends. The case is set again with full disclosure.",
                                   proper: true, error: false, effect: .mistrial, days: 42,
                                   laterHeadline: "Mistrial after prosecutors withheld statement",
                                   laterBody: "Judge {JUDGE} declared a mistrial in \(c.caption) after the defense learned a witness had once named another person, a statement that sat in the prosecution's file. The district attorney said the office is reviewing its procedures."),
                    IncidentOption(label: "Recess a day so the defense can find and question the witness", result: "The defense locates the witness and recalls them; the statement comes out on cross.",
                                   proper: false, error: false),
                    IncidentOption(label: "Deny the motion and go on", result: "The trial continues. The court never hears the statement.",
                                   proper: false, error: true,
                                   appealText: "You denied any remedy for the State's failure to disclose a witness's statement naming another person, which was favorable and material (Brady v. Maryland).")
                ])
        }
    }

    // MARK: - Counsel with a conflict, kept on after a motion to withdraw was denied (Sixth Amendment; Cuyler v. Sullivan)

    static func conflictedCounsel(_ c: CourtCase, reason: String) -> CourtIncident {
        CourtIncident(
            kind: .selfRepresentation, moment: .beforeTrial, title: "\(c.defenseAttorney) renews the motion to withdraw",
            body: "You denied \(c.defenseAttorney)'s motion to withdraw at the calendar call. As the trial is called, counsel renews it for the record: \(reason) \(c.defendant.name) says \(c.defendant.lastName) wants a different lawyer.",
            lawID: "rightToCounsel",
            options: [
                IncidentOption(label: "Allow the withdrawal now and continue the trial four weeks for new counsel",
                               result: "New counsel is appointed and the case goes to another date.", proper: true, error: false, effect: .continueCase, days: 28),
                IncidentOption(label: "Deny it again and proceed to trial", result: "The trial goes on with \(c.defenseAttorney) at the defense table.",
                               proper: false, error: true,
                               appealText: "You required the defendant to go to trial with appointed counsel who had an actual conflict of interest, after counsel asked twice to withdraw.")
            ])
    }

    // MARK: - Outbursts (G.S. 15A-1032 removal; G.S. 5A-14 summary contempt)

    static func outburst(_ c: CourtCase, rng: inout SeededRNG) -> CourtIncident {
        let d = c.defendant.lastName
        if rng.chance(0.5) || c.victimName == nil {
            return CourtIncident(
                kind: .outburst, moment: .sentencing, title: "\(d) shouts during sentencing",
                body: "As the State argues for its sentence, \(c.defendant.name) stands and shouts across the courtroom, \"That's a lie and you know it!\", then curses at the prosecutor. A deputy steps forward. \(d) hasn't been warned before.",
                lawID: "courtroomContempt",
                options: [
                    IncidentOption(label: "Warn \(d) that another outburst means removal from the courtroom",
                                   result: "\(d) sits. The rest of the hearing is quiet.", proper: true, error: false),
                    IncidentOption(label: "Have \(d) removed now and finish sentencing without \(d)",
                                   result: "Deputies take \(d) out. Sentence is pronounced in \(d)'s absence.", proper: false, error: true,
                                   appealText: "You removed the defendant from the courtroom without the warning G.S. 15A-1032 requires, and pronounced sentence in the defendant's absence."),
                    IncidentOption(label: "Give \(d) a chance to respond, then hold \(d) in direct contempt: 30 days",
                                   result: "\(d) apologizes but the court finds willful contempt: 30 days, to begin after this sentence.", proper: false, error: false)
                ])
        }
        let v = c.victimName ?? "the victim"
        let died = Consequences.victimDied(c)
        let relative = died ? "\(v)'s sister" : "\(v)'s father"
        return CourtIncident(
            kind: .outburst, moment: .sentencing, title: "\(relative.capitalizedFirst) shouts at \(d)",
            body: "When the sentence is announced, \(relative) stands up in the gallery and shouts at \(c.defendant.name), \"You'll rot for this!\", then at the bench: \"This is a joke!\" Deputies look to you.",
            lawID: "courtroomContempt",
            options: [
                IncidentOption(label: "Ask the deputies to walk the family member out, gently, and move on",
                               result: "A deputy walks \(relative) to the hallway. The hearing finishes.", proper: true, error: false),
                IncidentOption(label: "Give a chance to respond, then hold \(relative) in direct contempt: 24 hours",
                               result: "\(relative.capitalizedFirst) spends the night in the county jail.", proper: false, error: false,
                               laterHeadline: "Judge jails victim's family member for courtroom outburst",
                               laterBody: "\(relative.capitalizedFirst) spent a night in the Hollis County jail after Judge {JUDGE} found contempt over an outburst at the sentencing in \(c.caption). Victim advocates called it heartless; the clerk said courtroom order has to apply to everyone."),
                IncidentOption(label: "Let it pass without comment", result: "The gallery murmurs. \(d) turns to answer and counsel pulls \(d) back down.",
                               proper: false, error: false)
            ])
    }
}
