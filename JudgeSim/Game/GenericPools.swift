import Foundation

/// Building blocks shared by every case template.
enum GenericPools {

    // MARK: Witness credibility

    static let prosecutionImpeachments: [Impeachment] = [
        Impeachment(text: "Admits on cross to having had \"four or five\" drinks that night.", penalty: 1),
        Impeachment(text: "Admits to a pending shoplifting charge being handled by the same District Attorney's office.", penalty: 2),
        Impeachment(text: "Concedes they were roughly 70 feet away, at night, under a flickering streetlight.", penalty: 1),
        Impeachment(text: "Acknowledges a long-running feud with {DL} over a $2,000 debt.", penalty: 2),
        Impeachment(text: "Admits their first statement to police described someone \"shorter, maybe heavier.\"", penalty: 2),
        Impeachment(text: "Admits they came forward only after a $5,000 reward was announced.", penalty: 2),
        Impeachment(text: "Has no connection to either party and called 911 within a minute. Cross-examination doesn't shake the account.", penalty: -1)
    ]

    static let defenseImpeachments: [Impeachment] = [
        Impeachment(text: "Admits being {DL}'s cousin and living with {DL} for two years.", penalty: 1),
        Impeachment(text: "Admits never mentioning any of this to police, despite being interviewed twice.", penalty: 2),
        Impeachment(text: "Has a prior conviction for perjury.", penalty: 2),
        Impeachment(text: "Admits {DL} has been paying their rent since the arrest.", penalty: 2),
        Impeachment(text: "Is a retired schoolteacher with no ties to {DL} beyond living on the same block. The account holds up on cross.", penalty: -1)
    ]

    // MARK: Objections

    static let objectionSeeds: [ObjectionSeed] = [
        // Defense objects during prosecution witnesses
        ObjectionSeed(question: "Prosecutor: \"What did you hear afterward?\"",
                      answer: "\"A neighbor told me the next day that it was {DL}. Everybody knew.\"",
                      raisedBy: .defense, onCross: false, grounds: "Hearsay",
                      shouldSustain: true,
                      explanation: "The neighbor's out-of-court statement is offered to prove {DL} did it. That is classic hearsay, and no exception applies.",
                      doctrineID: "hearsay", weight: 2),
        ObjectionSeed(question: "Prosecutor: \"What happened right after?\"",
                      answer: "\"Someone came running out screaming, 'It's them! The one in the gray jacket!' They were shaking.\"",
                      raisedBy: .defense, onCross: false, grounds: "Hearsay",
                      shouldSustain: false,
                      explanation: "A statement made under the stress of a startling event is an excited utterance, a recognized hearsay exception.",
                      doctrineID: "hearsayExceptions", weight: 1),
        ObjectionSeed(question: "Prosecutor: \"Did you speak with the defendant afterward?\"",
                      answer: "\"Yeah. {DL} told me, 'I never meant for it to go that far.'\"",
                      raisedBy: .defense, onCross: false, grounds: "Hearsay",
                      shouldSustain: false,
                      explanation: "A defendant's own words, offered by the prosecution, are an opposing party's statement and not hearsay at all.",
                      doctrineID: "partyAdmission", weight: 2),
        ObjectionSeed(question: "Prosecutor: \"Why do you think it happened?\"",
                      answer: "\"If you ask me, {DL} had been planning this for weeks.\"",
                      raisedBy: .defense, onCross: false, grounds: "Speculation",
                      shouldSustain: true,
                      explanation: "The witness has no personal knowledge of {DL}'s plans. This is speculation.",
                      doctrineID: "speculation", weight: 1),
        ObjectionSeed(question: "Prosecutor: \"How would you describe the defendant?\"",
                      answer: "\"Everyone on the block knows {DL} is trouble. Always has been.\"",
                      raisedBy: .defense, onCross: false, grounds: "Improper character evidence",
                      shouldSustain: true,
                      explanation: "The prosecution can't prove guilt by arguing the defendant is a bad person. This is propensity evidence barred by Rule 404(a).",
                      doctrineID: "characterEvidence", weight: 1),
        ObjectionSeed(question: "Prosecutor: \"You clearly saw the defendant do it, didn't you?\"",
                      answer: "\"...Yes.\"",
                      raisedBy: .defense, onCross: false, grounds: "Leading the witness",
                      shouldSustain: true,
                      explanation: "On direct examination, a lawyer may not put the answer in their own witness's mouth.",
                      doctrineID: "leading", weight: 1),
        ObjectionSeed(question: "Prosecutor: \"Had you ever seen the defendant and the victim interact before?\"",
                      answer: "\"Two days earlier I heard {DL} tell {VL}, 'You're going to pay for this.'\"",
                      raisedBy: .defense, onCross: false, grounds: "Prior bad acts",
                      shouldSustain: false,
                      explanation: "A recent threat against the same victim isn't offered to show bad character. It's offered to show motive and intent, which Rule 404(b) allows.",
                      doctrineID: "priorActs", weight: 2, needsVictim: true),
        ObjectionSeed(question: "Prosecutor: \"What did the injuries look like to you?\"",
                      answer: "\"I'm no doctor, but those injuries were obviously deliberate.\"",
                      raisedBy: .defense, onCross: false, grounds: "Improper lay opinion",
                      shouldSustain: true,
                      explanation: "Whether injuries were deliberate is a medical opinion requiring expertise. A lay witness can describe what they saw, not diagnose it.",
                      doctrineID: "speculation", weight: 1, needsVictim: true),
        ObjectionSeed(question: "Defense attorney: \"You'd been drinking that night, hadn't you?\"",
                      answer: "\"...A couple. Maybe three.\"",
                      raisedBy: .prosecution, onCross: true, grounds: "Leading the witness",
                      shouldSustain: false,
                      explanation: "Leading questions are permitted on cross-examination.",
                      doctrineID: "leading", weight: -1),
        ObjectionSeed(question: "Defense attorney: \"Isn't it true the police showed you only one photo, and it was the defendant's?\"",
                      answer: "\"...They showed me one photo first, yes. Then the lineup.\"",
                      raisedBy: .prosecution, onCross: true, grounds: "Argumentative",
                      shouldSustain: false,
                      explanation: "This is a fair, pointed cross-examination question about the reliability of the identification. It is not argumentative.",
                      doctrineID: "leading", weight: -2),

        // Prosecution objects during defense witnesses
        ObjectionSeed(question: "Defense attorney: \"Did you ever hear anyone else talk about this crime?\"",
                      answer: "\"My friend told me they heard some other guy bragging about doing it.\"",
                      raisedBy: .prosecution, onCross: false, grounds: "Hearsay",
                      shouldSustain: true,
                      explanation: "This is double hearsay: a friend repeating what an unknown person said. No exception applies.",
                      doctrineID: "hearsay", weight: -2),
        ObjectionSeed(question: "Defense attorney: \"What did your brother tell you before he passed away?\"",
                      answer: "\"He said he was the one who really did it, and that he was scared he'd go to prison.\"",
                      raisedBy: .prosecution, onCross: false, grounds: "Hearsay",
                      shouldSustain: false,
                      explanation: "A now-unavailable person's statement against their own penal interest, corroborated by circumstances, is a recognized hearsay exception.",
                      doctrineID: "hearsayExceptions", weight: -2),
        ObjectionSeed(question: "Defense attorney: \"Isn't it true the complaining witness was fired from a job ten years ago?\"",
                      answer: "\"I heard that, yes.\"",
                      raisedBy: .prosecution, onCross: false, grounds: "Relevance",
                      shouldSustain: true,
                      explanation: "A decade-old firing has nothing to do with whether this crime happened. It's irrelevant and only meant to smear.",
                      doctrineID: "relevance", weight: -1),
        ObjectionSeed(question: "Defense attorney: \"What is the defendant's reputation in the community?\"",
                      answer: "\"I've known {DL} fifteen years. Around here, {DL} is known as gentle and honest. Everyone says so.\"",
                      raisedBy: .prosecution, onCross: false, grounds: "Character evidence",
                      shouldSustain: false,
                      explanation: "A criminal defendant may offer evidence of a pertinent good character trait. Rule 404(a)(2)(A) carves out exactly this.",
                      doctrineID: "characterEvidence", weight: -1),
        ObjectionSeed(question: "Defense attorney: \"Why do you think {DL} was arrested?\"",
                      answer: "\"Honestly? The cops just grabbed the first person who fit the description.\"",
                      raisedBy: .prosecution, onCross: false, grounds: "Speculation",
                      shouldSustain: true,
                      explanation: "The witness has no personal knowledge of how police chose a suspect.",
                      doctrineID: "speculation", weight: -1)
    ]

    // MARK: Motions

    static let suppressSearchSeeds: [MotionSeed] = [
        MotionSeed(kind: .suppressSearch,
                   facts: "Officers entered {DL}'s apartment without a warrant after an anonymous tip. Bodycam shows no emergency, no consent, and no one home.",
                   shouldGrant: true,
                   explanation: "No warrant, no consent, no exigency. The entry was unconstitutional, and the exclusionary rule requires suppression.",
                   doctrines: ["searchSeizure", "warrantExceptions"], kinds: [.physical, .forensic, .document]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Officer {OFF} stopped {DL}'s car because it \"looked out of place in that neighborhood.\" On cross, the officer admits no traffic violation occurred, then describes searching the trunk.",
                   shouldGrant: true,
                   explanation: "A stop requires reasonable suspicion of a violation. A hunch about the neighborhood is not enough, so everything found is fruit of the poisonous tree.",
                   doctrines: ["searchSeizure", "fruitPoisonousTree"], kinds: [.physical, .forensic]),
        MotionSeed(kind: .suppressSearch,
                   facts: "The warrant authorized a search of Apartment 2B. Officers searched Apartment 2D, where {DL} lives, \"because the layout matched.\"",
                   shouldGrant: true,
                   explanation: "A warrant must particularly describe the place to be searched. 2D was simply not covered.",
                   doctrines: ["searchSeizure"], kinds: [.physical, .forensic, .document, .digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "After arresting {DL}, officers scrolled through {DL}'s unlocked phone at the scene without a warrant, and that is how this evidence was found.",
                   shouldGrant: true,
                   explanation: "Under Riley v. California, police must get a warrant before searching a phone's data, even after a lawful arrest.",
                   doctrines: ["searchSeizure", "warrantExceptions"], kinds: [.digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Police obtained 47 days of {DL}'s cell-site location records from the phone carrier with a subpoena, not a warrant.",
                   shouldGrant: true,
                   explanation: "Carpenter v. United States requires a warrant for historical cell-site location information.",
                   doctrines: ["searchSeizure"], kinds: [.digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "{DL} initially refused consent. Officers then said they would \"tear the place apart and call CPS about the kids\" unless {DL} signed the consent form, which {DL} then did.",
                   shouldGrant: true,
                   explanation: "Consent must be voluntary. Consent extracted with threats about one's children is coerced and invalid.",
                   doctrines: ["warrantExceptions"], kinds: [.physical, .forensic, .document, .digital]),

        MotionSeed(kind: .suppressSearch,
                   facts: "{DL} signed a written consent form. Bodycam shows a calm, two-minute conversation in which officers said {DL} could refuse.",
                   shouldGrant: false,
                   explanation: "Voluntary consent by someone with authority is a valid exception to the warrant requirement.",
                   doctrines: ["warrantExceptions"], kinds: [.physical, .forensic, .document, .digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "The item was sitting on the passenger seat, in plain view, when {DL} was lawfully pulled over for running a red light.",
                   shouldGrant: false,
                   explanation: "Plain view: the officer was lawfully present, and the incriminating nature of the item was immediately apparent.",
                   doctrines: ["warrantExceptions"], kinds: [.physical]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Officers heard a scream and breaking glass inside, forced the door to render aid, and saw the evidence while checking rooms.",
                   shouldGrant: false,
                   explanation: "Exigent circumstances, here an apparent emergency, justified the warrantless entry, and the evidence was in plain view.",
                   doctrines: ["warrantExceptions"], kinds: [.physical, .forensic]),
        MotionSeed(kind: .suppressSearch,
                   facts: "A judge signed the search warrant. The defense calls the affidavit \"thin,\" but it described two controlled buys and an informant who had been reliable on four prior cases.",
                   shouldGrant: false,
                   explanation: "The affidavit established probable cause. Reviewing courts give substantial deference to the issuing judge.",
                   doctrines: ["searchSeizure"], kinds: [.physical, .forensic, .document, .digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Officers went in a few minutes early without the warrant. But a warrant application, built on independent evidence, was already being signed. It was approved twenty minutes later.",
                   shouldGrant: false,
                   explanation: "Inevitable discovery and independent source: the evidence would have been lawfully found anyway.",
                   doctrines: ["fruitPoisonousTree"], kinds: [.physical, .forensic, .document, .digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Investigators obtained a warrant for the phone's contents, limited to the crime and the relevant date range, before examining it.",
                   shouldGrant: false,
                   explanation: "A particularized warrant is exactly what Riley requires. The search was lawful.",
                   doctrines: ["searchSeizure"], kinds: [.digital]),
        MotionSeed(kind: .suppressSearch,
                   facts: "The warrant had a clerical error: it was dated the wrong year. Officers relied on it in good faith, and nothing suggests they knew.",
                   shouldGrant: false,
                   explanation: "The good-faith exception applies when officers reasonably rely on a warrant later found technically defective.",
                   doctrines: ["warrantExceptions"], kinds: [])
    ]

    static let suppressStatementSeeds: [MotionSeed] = [
        MotionSeed(kind: .suppressStatement,
                   facts: "{DL} was questioned for nine hours without food. Twice, {DL} said, \"I want a lawyer.\" Detective {DET} kept going.",
                   shouldGrant: true,
                   explanation: "Once a suspect clearly invokes the right to counsel, all questioning must stop (Edwards v. Arizona).",
                   doctrines: ["miranda", "rightToCounsel"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "{DL} was handcuffed in the back of a patrol car when Officer {OFF} asked, \"So why'd you do it?\" No Miranda warnings had been given.",
                   shouldGrant: true,
                   explanation: "Handcuffed in a patrol car is custody, and a direct question is interrogation. Without warnings, the answer is inadmissible.",
                   doctrines: ["miranda"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "The recording shows Detective {DET} telling {DL}: \"Say it and you're home with your kids tonight. Stay quiet and you'll never see them again.\"",
                   shouldGrant: true,
                   explanation: "Threats about one's children and promises of release make a confession involuntary, whatever warnings were given.",
                   doctrines: ["voluntariness"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "As officers walked through the door, before anyone asked a question, {DL} blurted out the statement.",
                   shouldGrant: false,
                   explanation: "Miranda covers interrogation. A spontaneous, volunteered statement is admissible.",
                   doctrines: ["miranda"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "Detectives spoke with {DL} at {DL}'s own kitchen table, said three times that {DL} was free to end the conversation, and left without arresting anyone.",
                   shouldGrant: false,
                   explanation: "Miranda requires custody. A voluntary conversation at home, with no restraint, is not custodial.",
                   doctrines: ["miranda"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "{DL} was read Miranda rights, initialed each one, signed a waiver, and spoke for 40 minutes. The recording shows no threats or promises.",
                   shouldGrant: false,
                   explanation: "A knowing, voluntary waiver after full warnings makes the statement admissible.",
                   doctrines: ["miranda", "voluntariness"])
    ]

    static let speedyTrialSeeds: [MotionSeed] = [
        MotionSeed(kind: .dismissSpeedyTrial,
                   facts: "{DL} has been jailed awaiting trial for 31 months. The State requested nine continuances, twice because it misplaced the file. {DL} demanded a speedy trial in writing five times. A key defense witness has since died.",
                   shouldGrant: true,
                   explanation: "All four Barker factors favor the defendant: long delay, the State's fault, repeated demands, and real prejudice. Dismissal with prejudice is required.",
                   doctrines: ["speedyTrial"]),
        MotionSeed(kind: .dismissSpeedyTrial,
                   facts: "The case is 26 months old, but 21 of those months came from continuances the defense itself requested. {DL} never raised the speedy-trial right until last week.",
                   shouldGrant: false,
                   explanation: "Delay requested by the defense doesn't count against the State, and the late assertion of the right weighs heavily against dismissal.",
                   doctrines: ["speedyTrial"])
    ]

    // MARK: Twists

    static let twists: [TwistSeed] = [
        TwistSeed(text: "{DL} is the sole caregiver for three children under ten. Their other parent died last year.",
                  mitigating: "Sole caregiver for three young children", mood: .sympathetic),
        TwistSeed(text: "{DL} is a decorated Army veteran diagnosed with severe PTSD after two combat tours.",
                  mitigating: "Combat veteran with diagnosed PTSD", mood: .sympathetic),
        TwistSeed(text: "{DL} turned 18 just three weeks before the offense.",
                  mitigating: "Youth: barely 18 at the time of the offense"),
        TwistSeed(text: "{DL} is the child of a sitting state senator. Reporters are watching for any hint of favoritism.",
                  mood: .wantsConviction, mediaBoost: 2),
        TwistSeed(text: "While awaiting trial, {DL} was diagnosed with stage IV pancreatic cancer. Doctors estimate a year to live.",
                  mitigating: "Terminal illness", mood: .sympathetic),
        TwistSeed(text: "Before trial, {DL} turned down a plea offer of 18 months in order to exercise the right to trial.",
                  doctrine: "trialPenalty"),
        TwistSeed(text: "{DL} has already spent 11 months in pretrial detention, unable to afford $5,000 bail.",
                  mitigating: "Already served 11 months awaiting trial"),
        TwistSeed(text: "During testimony, {DL} smirked at witnesses and had to be admonished twice.",
                  aggravating: "Courtroom conduct shows no remorse", mood: .wantsConviction),
        TwistSeed(text: "About 200 protesters have gathered outside the courthouse every day of trial.",
                  mood: .divided, mediaBoost: 1),
        TwistSeed(text: "The District Attorney is running for re-election on a \"tough on crime\" platform and has publicly demanded the maximum.",
                  mood: .wantsConviction, mediaBoost: 1),
        TwistSeed(text: "Three years ago, {DL} pulled a child from a burning car and received a city commendation.",
                  mitigating: "Documented act of heroism and community service", mood: .sympathetic),
        TwistSeed(text: "Since the arrest, {DL} has completed a 12-month treatment program and held a steady job.",
                  mitigating: "Demonstrated rehabilitation since arrest"),
        TwistSeed(text: "During trial, {DL} posted about the case on social media, mocking the prosecution's witnesses.",
                  aggravating: "Publicly mocked witnesses during trial", mood: .wantsConviction, mediaBoost: 1),
        TwistSeed(text: "A true-crime podcast with two million listeners is covering every day of this trial.",
                  mediaBoost: 2)
    ]

    // MARK: Ethics dilemmas

    static func ethicsEvents(hasVictim: Bool) -> [EthicsEvent] {
        [
            EthicsEvent(title: "A Private Email",
                        body: "The night before trial, ADA {PROS} emails your personal account: \"Off the record, Judge, {DL} is much worse than this file shows. Trust me.\"",
                        doctrineID: "exParte",
                        options: [
                            EthicsOption(label: "Disclose the email to both sides on the record, and disregard it",
                                         result: "You read the email into the record. Defense counsel thanks you; the ADA turns red. The Judicial Conduct Commission later cites your handling as a model.",
                                         integrity: 6, approval: 0, isProper: true),
                            EthicsOption(label: "Delete it and say nothing",
                                         result: "You delete it. But ex parte contacts must be disclosed, and when it surfaces in discovery months later, it looks like you hid it.",
                                         integrity: -5, approval: 0, isProper: false),
                            EthicsOption(label: "Reply: \"What do you mean?\"",
                                         result: "You opened a secret channel with one side of a pending case. The defense finds out and moves for your recusal.",
                                         integrity: -15, approval: -2, isProper: false)
                        ]),
            EthicsEvent(title: "An Old Connection",
                        body: "Reviewing the file, you realize {DL}'s parent was your college roommate. You haven't spoken in fifteen years.",
                        doctrineID: "recusal",
                        options: [
                            EthicsOption(label: "Disclose it on the record and offer to recuse",
                                         result: "Both sides confer and waive the conflict on the record. The trial proceeds cleanly.",
                                         integrity: 5, approval: 1, isProper: true),
                            EthicsOption(label: "Say nothing. It won't affect you.",
                                         result: "It might not. But a reporter later digs up the connection, and \"Judge Hid Ties to Defendant's Family\" runs above the fold.",
                                         integrity: -10, approval: -4, isProper: false)
                        ]),
            EthicsEvent(title: "Ambush in the Parking Garage",
                        body: "A Channel 7 reporter corners you at your car: \"Judge! Is {DL} going to walk?\"",
                        doctrineID: "extrajudicial",
                        options: [
                            EthicsOption(label: "\"I can't comment on a pending case.\"",
                                         result: "The clip is boring and nobody airs it. Exactly right.",
                                         integrity: 3, approval: 0, isProper: true),
                            EthicsOption(label: "\"Not in my courtroom.\"",
                                         result: "It plays great at 6 p.m. It also signals you'd prejudged the case, and the defense files a motion citing the clip.",
                                         integrity: -12, approval: 6, isProper: false),
                            EthicsOption(label: "\"Frankly, the evidence is thin.\"",
                                         result: "The prosecution moves for your recusal the next morning. You had no business saying that.",
                                         integrity: -12, approval: -3, isProper: false)
                        ]),
            EthicsEvent(title: "A Call from City Hall",
                        body: "The mayor's chief of staff calls your chambers: \"The mayor would appreciate a strong message in this case. Your reappointment is next year, Judge.\"",
                        doctrineID: "exParte",
                        options: [
                            EthicsOption(label: "Report the call to the Judicial Conduct Commission",
                                         result: "The Commission opens an inquiry into the mayor's office. Some allies go cold on you, but your independence is on the record.",
                                         integrity: 8, approval: -3, isProper: true),
                            EthicsOption(label: "Hang up and ignore it",
                                         result: "You don't bend. But an attempt to influence a judge should be reported, and you let it slide.",
                                         integrity: 1, approval: 0, isProper: false),
                            EthicsOption(label: "\"I'll keep that in mind.\"",
                                         result: "That's the sound of judicial independence leaving the room.",
                                         integrity: -20, approval: 3, isProper: false)
                        ]),
            EthicsEvent(title: "A Generous Gift",
                        body: "A gift basket arrives at chambers from the law firm representing {DL}: wine, chocolates, and two courtside playoff tickets. The card reads, \"With admiration.\"",
                        doctrineID: "gifts",
                        options: [
                            EthicsOption(label: "Return everything and disclose it to the prosecution",
                                         result: "You send it all back with a polite note and file a disclosure. Clean.",
                                         integrity: 5, approval: 0, isProper: true),
                            EthicsOption(label: "Keep the chocolates, return the tickets",
                                         result: "Half-measures. A gift from counsel in a pending case shouldn't be accepted at all.",
                                         integrity: -3, approval: 0, isProper: false),
                            EthicsOption(label: "Keep it all. It's just a basket.",
                                         result: "Someone posts a photo of you at the playoff game. The caption writes itself.",
                                         integrity: -15, approval: -5, isProper: false)
                        ]),
            EthicsEvent(title: "Gone Viral",
                        body: hasVictim
                            ? "{VL}'s family tags your personal account in a viral post: \"Judge, if you let {DL} walk, the blood is on YOUR hands.\" It has 40,000 shares."
                            : "A viral post tags your personal account: \"Judge, if you let {DL} walk, you're part of the problem.\" It has 40,000 shares.",
                        doctrineID: "extrajudicial",
                        options: [
                            EthicsOption(label: "Don't respond. Decide the case on the record.",
                                         result: "The storm passes, as storms do. Your ruling will be your answer.",
                                         integrity: 3, approval: 0, isProper: true),
                            EthicsOption(label: "Post a reply defending your record",
                                         result: "Judges don't litigate pending cases on social media. The reply gets screenshotted into a motion to recuse.",
                                         integrity: -10, approval: 2, isProper: false)
                        ])
        ]
    }

    // MARK: Closing lines

    static let prosecutionClosings = [
        "The evidence points one direction, Your Honor: at {D}. The State asks for a verdict of guilty.",
        "Every piece of this puzzle fits. The only person it fits is {D}.",
        "Reasonable doubt is not any doubt. It's not imagined doubt. The State has proven this case."
    ]

    static let defenseClosings = [
        "The State has given you suspicion, Your Honor, not proof. Suspicion is not enough to take someone's freedom.",
        "If you have a reasonable doubt, and you should, the law says you must acquit {D}.",
        "Look at what's missing from this case. That's where your reasonable doubt lives."
    ]

    static let genericAllocutions = [
        "{DL} stands, voice shaking: \"I know nothing I say fixes this. I'm sorry. I'm so sorry.\"",
        "{DL} declines to speak, on the advice of counsel, pending appeal.",
        "{DL}: \"I've had a lot of time to think in that cell. I'm not the same person. I just want a chance to prove it.\"",
        "{DL}: \"I still say I didn't do it. But I respect the court.\"",
        "{DL} looks at the gallery: \"Mom, I'm sorry. Your Honor, whatever you decide, I'll take it.\""
    ]

    // MARK: Epilogues

    static let convictedGuilty = [
        "The conviction stands for what it is: the right person, held to account.",
        "Whatever the sentence, the truth and the verdict lined up this time. That doesn't always happen."
    ]

    static let convictedInnocent = [
        "An innocent person was convicted in your courtroom. {DL} lost years that no apology can return.",
        "The Westbrook Innocence Project took the case. {DL} was exonerated, after years behind bars, for something {DL} never did."
    ]

    static let acquittedGuilty = [
        "{DL} walked out of your courtroom free, and was guilty. The law demands proof. Sometimes the guilty go home.",
        "You never learn what {DL} did next. You think about it sometimes."
    ]

    static let acquittedInnocent = [
        "You acquitted an innocent person. {DL} went home that night.",
        "{DL} hugged their lawyer for a long time. They'd been telling the truth all along."
    ]
}
