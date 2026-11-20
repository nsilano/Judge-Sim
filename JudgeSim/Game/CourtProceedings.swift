import Foundation

/// Two parts of a criminal case where the judge's handling is what gets reviewed on appeal: the plea colloquy
/// (G.S. 15A-1022) and jury selection (G.S. 15A-1212 and Batson v. Kentucky). Each is a short matter on the calendar with a
/// few ways to handle it, and each way is rated by the law.
enum CourtProceedings {
    enum Part { case colloquy, jury }

    struct Scenario {
        var id: String
        var part: Part
        var summary: String
        var note: String
        var options: [String]
        /// How each option rates: 0 right, 1 a lapse that does no lasting harm, 2 an error an appeals court would notice.
        var rating: [Int]
        /// What follows from each option, in the court's own words.
        var results: [String]
        /// The headline if a real error comes back on appeal.
        var appealHeadline: String
        var appealBody: String
    }

    static func matter(part: Part, county: County, rng: inout SeededRNG) -> CalendarMatter {
        let pool = scenarios(county: county).filter { $0.part == part }
        let s = pool[rng.int(0...(pool.count - 1))]
        let kind: CalendarMatter.Kind = part == .colloquy ? .pleaColloquy : .jurySelection
        return CalendarMatter(kind: kind, personID: UUID(), personName: part == .colloquy ? "Plea hearing" : "Jury selection", personAge: 0,
                              occupation: "", docket: part == .colloquy ? "Plea colloquy" : "Voir dire",
                              summary: s.summary, stateAsk: "", defenseAsk: "", options: s.options, lawID: s.id, lawNote: s.note)
    }

    static func scenario(id: String, county: County) -> Scenario? {
        scenarios(county: county).first { $0.id == id }
    }

    private static func scenarios(county: County) -> [Scenario] {
        let clerk = county.clerk
        return [
            // MARK: Plea colloquy
            Scenario(id: "plea.alford", part: .colloquy,
                     summary: "A defendant is about to plead guilty to a felony. Asked if he did it, he says, \"No, Your Honor. I'm pleading because the State's offer is better than what I'll get at trial.\" The prosecutor says the evidence is strong.",
                     note: "North Carolina v. Alford: a court may accept a guilty plea from a defendant who maintains innocence if the plea is knowing and voluntary and the record has a strong factual basis (G.S. 15A-1022(c)).",
                     options: ["Confirm he understands what an Alford plea is, have the State put the evidence on the record, and accept it as an Alford plea",
                               "Take the plea as an ordinary guilty plea and move on",
                               "Refuse the plea and set the case for trial"],
                     rating: [0, 2, 1],
                     results: ["The record shows a knowing choice and a factual basis. The plea stands.",
                               "A guilty plea from a man who says he is innocent, with no inquiry, is the kind of record that comes back on a motion for appropriate relief.",
                               "The case goes back on the trial list. Nothing was wrong with the offer; the court simply would not hear it."],
                     appealHeadline: "Plea set aside after defendant said he did not commit the crime",
                     appealBody: "A defendant who told the court he was innocent was allowed to plead guilty without any inquiry into the factual basis. The plea was set aside and the case returns to the trial calendar."),
            Scenario(id: "plea.medication", part: .colloquy,
                     summary: "A defendant has taken medication that morning for a condition and answers the court's questions slowly. Twice he has to be asked again whether he understands the rights he is giving up. His lawyer says he is fine.",
                     note: "G.S. 15A-1022(a): the court may not accept a guilty plea without first determining that the plea is the product of informed choice.",
                     options: ["Continue the plea to another day when the defendant is clear-headed", "Ask a few more questions and proceed if the answers are sound", "Proceed; his lawyer says he understands"],
                     rating: [0, 1, 2],
                     results: ["The plea is reset. No one can say later that the defendant did not know what he was giving up.",
                               "The answers held up. A thinner record than a new date would have made, but a defensible one.",
                               "The court relied on counsel's word over what it saw. That plea is open to challenge."],
                     appealHeadline: "Appeals court questions plea taken from defendant on medication",
                     appealBody: "A defendant who struggled to answer the court's questions pleaded guilty the same morning he took medication. The question on appeal is whether the plea was the product of informed choice."),
            Scenario(id: "plea.immigration", part: .colloquy,
                     summary: "A defendant pleading to a felony speaks with an accent and tells the court he came here as a child and has a green card. Nobody has mentioned immigration consequences.",
                     note: "G.S. 15A-1022(a)(7): the court must advise a defendant that a plea may result in deportation, exclusion, or denial of naturalization if he is not a citizen.",
                     options: ["Give the statutory warning on the record and offer him time to talk with his lawyer", "Ask his lawyer whether he has advised him and take counsel's word", "Proceed; it was not asked"],
                     rating: [0, 1, 2],
                     results: ["The warning is on the record, and the defendant took a moment with his lawyer before going on.",
                               "Counsel said yes. The statute asks the court to give the warning itself, so the record is thinner than it should be.",
                               "The required advice was never given. The defendant can attack the plea if consequences follow."],
                     appealHeadline: "Plea vacated: judge never gave the immigration warning",
                     appealBody: "A non-citizen defendant pleaded guilty without the warning that G.S. 15A-1022 requires the court to give. The plea was vacated."),
            Scenario(id: "plea.hesitates", part: .colloquy,
                     summary: "A young defendant stalls when asked if he is pleading of his own free will. \"My lawyer said I should take it. I guess so.\" His mother is shaking her head in the second row.",
                     note: "G.S. 15A-1022(b): the court may not accept a plea without determining it is voluntary and not the result of coercion or promises beyond the plea arrangement.",
                     options: ["Pause the hearing and let him speak privately with his lawyer before going on", "Ask him plainly whether he wants to plead guilty or go to trial, and take his answer", "Set the plea aside and keep the trial date"],
                     rating: [0, 1, 1],
                     results: ["After ten minutes, he decided to plead and said so in his own words. The record is clean.",
                               "He said yes, quietly. The answer is on the record, but the room was not convinced.",
                               "The case stays on the trial list. The court protected the choice and cost the offer."],
                     appealHeadline: "Defendant says he was pushed into pleading guilty",
                     appealBody: "A defendant has asked to withdraw a plea, saying he took it only because his lawyer told him to. The hearing transcript shows he hesitated."),
            Scenario(id: "plea.terms", part: .colloquy,
                     summary: "The defendant tells the court he understood the deal to be probation. The written plea transcript says an active sentence. The prosecutor says the written terms are the offer; defense counsel says there was a misunderstanding.",
                     note: "G.S. 15A-1022(a)(5)–(6) and 15A-1023: the judge must tell the defendant the maximum and minimum sentences and the terms of the plea arrangement before accepting it.",
                     options: ["Stop and have both sides state the agreement on the record; let the defendant withdraw if the terms differ from what he understood", "Accept the plea as written; the paper controls", "Tell the defendant the lawyers will sort it out later"],
                     rating: [0, 2, 2],
                     results: ["The terms were clarified. The defendant decided to go to trial rather than take active time.",
                               "The defendant leaves believing he was promised probation. The motion to withdraw is already being drafted.",
                               "Nobody ever put the real terms on the record. That plea will not survive review."],
                     appealHeadline: "Defendant says he was promised probation, got prison",
                     appealBody: "A defendant says the plea he entered was understood to carry probation but was entered on paper as an active sentence. The judge never put the agreed terms on the record."),
            Scenario(id: "plea.withdraw", part: .colloquy,
                     summary: "A defendant who pleaded guilty three weeks ago, before sentencing, now asks to withdraw the plea. He says he panicked and now wants a trial. The State objects and says it has already released its witnesses.",
                     note: "State v. Handy: before sentencing, a defendant may withdraw a plea for any fair and just reason. The State's reliance is weighed, but it is not a veto.",
                     options: ["Hold a short hearing: ask why, weigh how long it has been and whether he maintains innocence, and rule", "Deny it without a hearing; a plea is a plea", "Allow it without argument, given the stakes"],
                     rating: [0, 2, 1],
                     results: ["After hearing both sides, the court ruled with reasons on the record. Neither side could say it was not heard.",
                               "A defendant who asked before sentencing was turned away without a hearing. That is a ground for reversal.",
                               "The plea is withdrawn. The State is unhappy it was not heard, and so is the clerk's office, which will have to reset the case."],
                     appealHeadline: "Judge refused to hear plea withdrawal, appeals court says",
                     appealBody: "A defendant asked to withdraw his plea before sentencing and was denied without a hearing. The Court of Appeals remanded for a hearing on whether there was a fair and just reason."),
            Scenario(id: "plea.interpreter", part: .colloquy,
                     summary: "A defendant who speaks Spanish at home is pleading guilty. Clerk \(clerk) says no interpreter has been scheduled, and his lawyer says he can translate as they go.",
                     note: "G.S. 15A-1022(a): the court must be satisfied the defendant understands the proceeding. A court-appointed interpreter is the usual way.",
                     options: ["Reset the plea until a certified interpreter can be present", "Let his lawyer interpret and have the defendant confirm he understands", "Go ahead; he answered in English a few times"],
                     rating: [0, 1, 2],
                     results: ["The plea moved a week. The next hearing ran with a certified interpreter and a good record.",
                               "The hearing ran, but the lawyer cannot be both interpreter and advocate. The record is thin.",
                               "A few English answers do not show he understood the rights he waived. The plea is open to attack."],
                     appealHeadline: "Defendant pleaded guilty without an interpreter",
                     appealBody: "A defendant who speaks little English pleaded guilty without a court interpreter. The defendant now says he did not understand the rights he gave up."),
            // MARK: Jury selection
            Scenario(id: "jury.knowsOfficer", part: .jury,
                     summary: "In a felony jury trial, a prospective juror says the lead detective is a member of her church. \"I'd take his word over a stranger's.\" The defense challenges her for cause. The State objects.",
                     note: "G.S. 15A-1212: a juror may be challenged for cause if she is unable to render a fair and impartial verdict. A juror's stated inability to be impartial is a ground; the judge rules.",
                     options: ["Grant the challenge for cause", "Ask her whether she could set that aside and decide only on the evidence, then rule on what she says", "Deny the challenge; people can be fair"],
                     rating: [0, 0, 2],
                     results: ["She was excused. The defense kept a peremptory strike.",
                               "She answered that she could not honestly say she would. The court granted the challenge on her own words.",
                               "The defense had to burn a peremptory strike on a juror who said she would favor the State's witness. An appeals court would not like that record."],
                     appealHeadline: "New trial ordered: judge kept juror who said she would believe the detective",
                     appealBody: "A juror said she would favor the lead detective's testimony because of a church connection. The trial judge refused to excuse her for cause. The Court of Appeals ordered a new trial."),
            Scenario(id: "jury.batson", part: .jury,
                     summary: "The State has used its third peremptory strike in a row on a Black prospective juror. The defense raises a Batson objection. The prosecutor says, \"I just didn't like her demeanor.\"",
                     note: "Batson v. Kentucky: a peremptory strike may not be based on race. The court must hear the objection, require a race-neutral reason, and decide whether the reason is genuine.",
                     options: ["Ask the State for race-neutral reasons on the record, compare the stated reasons with the other jurors, and rule", "Overrule it; three strikes is not a pattern", "Sustain it and seat the juror without asking for reasons"],
                     rating: [0, 2, 1],
                     results: ["The State gave a reason; the court tested it against the jurors who stayed on the panel and ruled with findings. The record is solid.",
                               "A Batson challenge was brushed aside without the inquiry the case law requires. A new trial is possible if the defendant is convicted.",
                               "The juror was seated, but the court did not make the findings required, which leaves the record open to the State's objection."],
                     appealHeadline: "Judge failed to hold full Batson inquiry, defense says",
                     appealBody: "The defense says the trial judge overruled a Batson objection without requiring a race-neutral reason or making findings. The appeal is pending."),
            Scenario(id: "jury.prejudged", part: .jury,
                     summary: "A prospective juror tells the court in front of the panel, \"I looked at him when he walked in. He looks guilty to me.\" The defense moves to excuse her for cause. The State says she is just being honest.",
                     note: "G.S. 15A-1212(9): a juror who has formed an opinion on guilt that she cannot put aside may be challenged for cause. The panel has heard it too.",
                     options: ["Excuse her, and then ask the rest of the panel if anyone else feels that way", "Ask her if she could keep an open mind and keep her if she says yes", "Deny the challenge and instruct the panel to ignore the remark"],
                     rating: [0, 1, 2],
                     results: ["She was excused and two others said they were uneasy. They were questioned and one was excused too.",
                               "She said yes, grudgingly. The defense used a peremptory on her, and a few jurors were seen looking at the defendant.",
                               "A juror who announced the defendant looked guilty stayed on the panel. Convictions have been reversed for less."],
                     appealHeadline: "Defendant convicted by jury that included member who said he looked guilty",
                     appealBody: "During jury selection a prospective juror said the defendant looked guilty. The judge refused to excuse her. The defendant, convicted, says the panel was tainted."),
            Scenario(id: "jury.knowsWitness", part: .jury,
                     summary: "A prospective juror says she knows the State's main witness from the neighborhood but \"we aren't close.\" Neither side has moved to strike her.",
                     note: "G.S. 15A-1212: relationship to a witness is a ground for challenge. The court should make sure the connection is explored even if the lawyers do not ask.",
                     options: ["Ask how well she knows the witness and whether it would affect her, and excuse her if the answers raise doubt", "Seat her; neither side objected", "Excuse her on your own motion without asking"],
                     rating: [0, 2, 1],
                     results: ["She said they had dinner a few times a year. The court excused her, and both lawyers thanked the court.",
                               "No one asked and no one knew. A juror with a social tie to the State's key witness deliberated.",
                               "She was excused without a record of why. The panel is smaller, and the defense wonders about the others."],
                     appealHeadline: "Juror knew key State witness; no one asked, defense says",
                     appealBody: "After a conviction, the defense learned that a juror had a social connection to the State's main witness. The judge had not asked about it during jury selection."),
            Scenario(id: "jury.hardship", part: .jury,
                     summary: "A prospective juror says she runs a one-woman daycare and has no one to cover for her. \"If I'm here for a week, I lose my families.\" The State says every juror has something.",
                     note: "G.S. 9-6.1: a judge may defer jury service or excuse a juror for undue hardship. The statute favors deferral to a later term where the hardship is temporary.",
                     options: ["Defer her service to a later term, as the statute prefers", "Excuse her outright, no questions", "Deny it; everyone has obligations"],
                     rating: [0, 1, 1],
                     results: ["She was deferred to a later term. She will serve, and the daycare gets time to arrange cover.",
                               "She was excused. The panel is smaller, and the clerk's office noted that service is now optional if you ask nicely.",
                               "She stayed. She spent the week distracted and phoned her families from the hallway. Everyone noticed."],
                     appealHeadline: "Jury service hardship excuses draw complaints at county courthouse",
                     appealBody: "Several residents summoned for jury duty say the courthouse's handling of hardship requests is inconsistent from one courtroom to the next."),
            Scenario(id: "jury.victimDistress", part: .jury,
                     summary: "In an assault trial, a prospective juror begins to cry in open court and says her brother was beaten almost to death last year. The rest of the panel is watching.",
                     note: "The court's duty to protect the panel: questions that expose a juror's private pain, and may influence the others, are better handled out of the panel's hearing.",
                     options: ["Excuse her gently, then bring her to the bench with the lawyers to confirm what she said", "Keep questioning her in front of the panel to find out whether she can be fair", "Excuse her without more and move on"],
                     rating: [0, 2, 1],
                     results: ["She was excused after a short exchange at the bench. The panel saw only that she left.",
                               "The entire panel heard a detailed account of the violence in her family. Three more jurors said they could not be fair.",
                               "She left. The lawyers had no chance to ask the follow-up they wanted, and the defense noted it for the record."],
                     appealHeadline: "Defense says jury was tainted by juror's account of family violence",
                     appealBody: "The defense says a juror's account of her brother's beating, given in open court in front of the whole panel and without a bench conference, tainted the jury."),
            Scenario(id: "jury.disagrees", part: .jury,
                     summary: "A prospective juror in a drug trial says, \"I don't think marijuana should be illegal.\" The State moves to excuse him for cause. The defense says he has a right to his opinion.",
                     note: "G.S. 15A-1212: a juror may be excused for cause only if he cannot follow the court's instructions on the law. A personal opinion about the law alone is not enough.",
                     options: ["Ask whether he can follow the law as the court instructs, and keep him if he says he can", "Excuse him; he disagrees with the law", "Keep him and tell him to follow the law"],
                     rating: [0, 1, 1],
                     results: ["He said he could follow the instructions even if he disagreed, and he stayed. The State used a peremptory strike on him anyway.",
                               "He was excused without being asked whether he could follow the law. The defense noted that the standard is whether he can, not whether he likes it.",
                               "He sat on the panel with no questions asked. The State is not happy and the record is thin."],
                     appealHeadline: "State challenges jury selection ruling in drug case",
                     appealBody: "The State has asked the Court of Appeals to review whether a trial judge applied the right standard in excusing a juror who disagreed with marijuana laws.")
        ]
    }
}
