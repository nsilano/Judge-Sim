import Foundation

/// Building blocks shared by every case template.
enum GenericPools {

    // MARK: Witness credibility

    static let prosecutionImpeachments: [Impeachment] = [
        Impeachment(text: "Admits on cross to having had \"four or five\" drinks that night.", penalty: 1),
        Impeachment(text: "Admits to a pending shoplifting charge being handled by the same District Attorney's office.", penalty: 2),
        Impeachment(text: "Concedes they were roughly 70 feet away, at night, under a flickering streetlight.", penalty: 1),
        Impeachment(text: "Acknowledges a long-running feud with {DL} over a $2,000 debt.", penalty: 2),
        Impeachment(text: "Admits their first statement to police described someone \"shorter, maybe heavier.\"", penalty: 2, victimSafe: false),
        Impeachment(text: "Admits they came forward only after a $5,000 reward was announced.", penalty: 2, victimSafe: false),
        Impeachment(text: "Has no connection to either party and called 911 within a minute. Cross-examination doesn't shake the account.", penalty: -1, victimSafe: false)
    ]

    static let defenseImpeachments: [Impeachment] = [
        Impeachment(text: "Admits being {DL}'s cousin and living with {D.him} for two years.", penalty: 1),
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
                      doctrineID: "hearsay", weight: 2, layOnly: true),
        ObjectionSeed(question: "Prosecutor: \"What happened right after?\"",
                      answer: "\"Someone came running out screaming, 'It's them! The one in the gray jacket!' They were shaking.\"",
                      raisedBy: .defense, onCross: false, grounds: "Hearsay",
                      shouldSustain: false,
                      explanation: "A statement made under the stress of a startling event is an excited utterance, a recognized hearsay exception.",
                      doctrineID: "hearsayExceptions", weight: 1, layOnly: true),
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
                      doctrineID: "leading", weight: 1, layOnly: true),
        ObjectionSeed(question: "Prosecutor: \"Had you ever seen the defendant and the victim interact before?\"",
                      answer: "\"Two days earlier I heard {DL} tell {VL}, 'You're going to pay for this.'\"",
                      raisedBy: .defense, onCross: false, grounds: "Prior bad acts",
                      shouldSustain: false,
                      explanation: "A recent threat against the same victim isn't offered to show bad character. It's offered to show motive and intent, which Rule 404(b) allows.",
                      doctrineID: "priorActs", weight: 2, needsVictim: true, layOnly: true),
        ObjectionSeed(question: "Prosecutor: \"What did the injuries look like to you?\"",
                      answer: "\"I'm no doctor, but those injuries were obviously deliberate.\"",
                      raisedBy: .defense, onCross: false, grounds: "Improper lay opinion",
                      shouldSustain: true,
                      explanation: "Whether injuries were deliberate is a medical opinion requiring expertise. A lay witness can describe what they saw, not diagnose it.",
                      doctrineID: "speculation", weight: 1, needsVictim: true, layOnly: true),
        ObjectionSeed(question: "Defense attorney: \"You'd been drinking that night, hadn't you?\"",
                      answer: "\"...A couple. Maybe three.\"",
                      raisedBy: .prosecution, onCross: true, grounds: "Leading the witness",
                      shouldSustain: false,
                      explanation: "Leading questions are permitted on cross-examination.",
                      doctrineID: "leading", weight: -1, layOnly: true),
        ObjectionSeed(question: "Defense attorney: \"Isn't it true the police showed you only one photo, and it was the defendant's?\"",
                      answer: "\"...They showed me one photo first, yes. Then the lineup.\"",
                      raisedBy: .prosecution, onCross: true, grounds: "Argumentative",
                      shouldSustain: false,
                      explanation: "This is a fair, pointed cross-examination question about the reliability of the identification. It is not argumentative.",
                      doctrineID: "leading", weight: -2, layOnly: true),

        ObjectionSeed(question: "Prosecutor: \"I'm handing you State's photographs 14 through 31. Please describe each one for the court.\"",
                      answer: "\"These are... more of the injuries. Closer up. From different angles.\"",
                      raisedBy: .defense, onCross: false, grounds: "Rule 403: cumulative and unfairly prejudicial",
                      shouldSustain: true,
                      explanation: "Eighteen more graphic photographs of injuries already shown in detail add almost nothing. Rule 403 lets a judge exclude needlessly cumulative evidence whose prejudice outweighs its value.",
                      doctrineID: "relevance", weight: 1, needsVictim: true),
        ObjectionSeed(question: "Prosecutor: \"Just so the court is clear, you're certain it was the defendant?\"",
                      answer: "\"Yes. Like I said three times already, I'm sure.\"",
                      raisedBy: .defense, onCross: false, grounds: "Asked and answered",
                      shouldSustain: true,
                      explanation: "The witness had already answered the same question on direct. Repeating it only adds emphasis; the judge may cut it off under Rule 611(a).",
                      doctrineID: "leading", weight: 0, layOnly: true),
        ObjectionSeed(question: "Prosecutor: \"Would looking at your written statement refresh your memory?\"",
                      answer: "The witness takes the statement and begins reading it aloud, word for word.",
                      raisedBy: .defense, onCross: false, grounds: "Improper refreshing of recollection (Rule 612)",
                      shouldSustain: true,
                      explanation: "A writing may be used to jog a memory, but the witness must then testify from that memory. Reading the document aloud puts an unadmitted statement into evidence.",
                      doctrineID: "hearsay", weight: 1),
        ObjectionSeed(question: "Defense attorney: \"Let's talk about something you didn't cover on direct. Have you been promised anything for testifying?\"",
                      answer: "\"...They said they'd put in a good word on my own case.\"",
                      raisedBy: .prosecution, onCross: true, grounds: "Beyond the scope of direct",
                      shouldSustain: false,
                      explanation: "Unlike federal court, North Carolina's Rule 611(b) allows cross-examination on any relevant matter, including bias. Scope is not a valid objection here.",
                      doctrineID: "leading", weight: -2, layOnly: true),

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
                      explanation: "A criminal defendant may offer evidence of a pertinent good character trait. Rule 404(a)(1) carves out exactly this.",
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
                   doctrines: ["searchSeizure", "warrantExceptions"], kinds: [.physical, .forensic, .document], places: [.home]),
        MotionSeed(kind: .suppressSearch,
                   facts: "{OFF} stopped {DL}'s car because it \"looked out of place in that neighborhood.\" On cross, the officer admits no traffic violation occurred, then describes searching the trunk.",
                   shouldGrant: true,
                   explanation: "A stop requires reasonable suspicion of a violation. A hunch about the neighborhood is not enough, so everything found is fruit of the poisonous tree.",
                   doctrines: ["searchSeizure", "fruitPoisonousTree"], kinds: [.physical, .forensic], places: [.vehicle]),
        MotionSeed(kind: .suppressSearch,
                   facts: "The warrant authorized a search of Apartment 2B. Officers searched Apartment 2D, where {DL} lives, \"because the layout matched.\"",
                   shouldGrant: true,
                   explanation: "A warrant must particularly describe the place to be searched. 2D was simply not covered.",
                   doctrines: ["searchSeizure"], kinds: [.physical, .forensic, .document, .digital], places: [.home, .phone]),
        MotionSeed(kind: .suppressSearch,
                   facts: "After arresting {DL}, officers scrolled through {D.his} unlocked phone at the scene without a warrant, and that is how this evidence was found.",
                   shouldGrant: true,
                   explanation: "Under Riley v. California, police must get a warrant before searching a phone's data, even after a lawful arrest.",
                   doctrines: ["searchSeizure", "warrantExceptions"], kinds: [.digital], places: [.phone]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Police obtained 47 days of {DL}'s cell-site location records from the phone carrier with a subpoena, not a warrant.",
                   shouldGrant: true,
                   explanation: "Carpenter v. United States requires a warrant for historical cell-site location information.",
                   doctrines: ["searchSeizure"], kinds: [.digital], places: [.phone]),
        MotionSeed(kind: .suppressSearch,
                   facts: "{DL} initially refused consent. Officers then said they would \"tear the place apart and call CPS\" unless {DL} signed the consent form, which {D.he} then did.",
                   shouldGrant: true,
                   explanation: "Consent must be voluntary. Consent extracted with threats about one's family is coerced and invalid.",
                   doctrines: ["warrantExceptions"], kinds: [.physical, .forensic, .document, .digital], places: [.home, .vehicle]),

        MotionSeed(kind: .suppressSearch,
                   facts: "{DL} signed a written consent form. Bodycam shows a calm, two-minute conversation in which officers said {DL} could refuse.",
                   shouldGrant: false,
                   explanation: "Voluntary consent by someone with authority is a valid exception to the warrant requirement.",
                   doctrines: ["warrantExceptions"], kinds: [.physical, .forensic, .document, .digital], places: [.home, .vehicle, .phone]),
        MotionSeed(kind: .suppressSearch,
                   facts: "The item was sitting on the passenger seat, in plain view, when {DL} was lawfully pulled over for running a red light.",
                   shouldGrant: false,
                   explanation: "Plain view: the officer was lawfully present, and the incriminating nature of the item was immediately apparent.",
                   doctrines: ["warrantExceptions"], kinds: [.physical], places: [.vehicle]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Officers heard a scream and breaking glass inside, forced the door to render aid, and saw the evidence while checking rooms.",
                   shouldGrant: false,
                   explanation: "Exigent circumstances, here an apparent emergency, justified the warrantless entry, and the evidence was in plain view.",
                   doctrines: ["warrantExceptions"], kinds: [.physical, .forensic], places: [.home]),
        MotionSeed(kind: .suppressSearch,
                   facts: "A judge signed the search warrant. The defense calls the affidavit \"thin,\" but it described two controlled buys and an informant who had been reliable on four prior cases.",
                   shouldGrant: false,
                   explanation: "The affidavit established probable cause. Reviewing courts give substantial deference to the issuing judge.",
                   doctrines: ["searchSeizure"], kinds: [.physical, .forensic, .document, .digital], places: [.home, .vehicle, .phone]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Officers went in a few minutes early without the warrant. But a warrant application, built on independent evidence, was already being signed. It was approved twenty minutes later.",
                   shouldGrant: false,
                   explanation: "Inevitable discovery and independent source: the evidence would have been lawfully found anyway.",
                   doctrines: ["fruitPoisonousTree"], kinds: [.physical, .forensic, .document, .digital], places: [.home]),
        MotionSeed(kind: .suppressSearch,
                   facts: "Investigators obtained a warrant for the phone's contents, limited to the crime and the relevant date range, before examining it.",
                   shouldGrant: false,
                   explanation: "A particularized warrant is exactly what Riley requires. The search was lawful.",
                   doctrines: ["searchSeizure"], kinds: [.digital], places: [.phone]),
        MotionSeed(kind: .suppressSearch,
                   facts: "The warrant had a clerical error: it was dated the wrong year. Officers relied on it in good faith, and nothing suggests they knew.",
                   shouldGrant: false,
                   explanation: "The good-faith exception applies when officers reasonably rely on a warrant later found technically defective.",
                   doctrines: ["warrantExceptions"], kinds: [])
    ]

    static let suppressStatementSeeds: [MotionSeed] = [
        MotionSeed(kind: .suppressStatement,
                   facts: "{DL} was questioned for nine hours without food. Twice, {DL} said, \"I want a lawyer.\" {DET} kept going.",
                   shouldGrant: true,
                   explanation: "Once a suspect clearly invokes the right to counsel, all questioning must stop (Edwards v. Arizona).",
                   doctrines: ["miranda", "rightToCounsel"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "{DL} was handcuffed in the back of a patrol car when {OFF} asked, \"So why'd you do it?\" No Miranda warnings had been given.",
                   shouldGrant: true,
                   explanation: "Handcuffed in a patrol car is custody, and a direct question is interrogation. Without warnings, the answer is inadmissible.",
                   doctrines: ["miranda"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "The recording shows {DET} telling {DL}: \"Say it and you're home with your family tonight. Stay quiet and you'll never see them again.\"",
                   shouldGrant: true,
                   explanation: "Threats about one's family and promises of release make a confession involuntary, whatever warnings were given.",
                   doctrines: ["voluntariness"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "As officers walked through the door, before anyone asked a question, {DL} blurted out the statement.",
                   shouldGrant: false,
                   explanation: "Miranda covers interrogation. A spontaneous, volunteered statement is admissible.",
                   doctrines: ["miranda"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "Detectives spoke with {DL} at {D.his} own kitchen table, said three times that {D.he} was free to end the conversation, and left without arresting anyone.",
                   shouldGrant: false,
                   explanation: "Miranda requires custody. A voluntary conversation at home, with no restraint, is not custodial.",
                   doctrines: ["miranda"]),
        MotionSeed(kind: .suppressStatement,
                   facts: "{DL} was read Miranda rights, initialed each one, signed a waiver, and spoke for 40 minutes. The recording shows no threats or promises.",
                   shouldGrant: false,
                   explanation: "A knowing, voluntary waiver after full warnings makes the statement admissible.",
                   doctrines: ["miranda", "voluntariness"])
    ]

    static let identificationSeeds: [MotionSeed] = [
        MotionSeed(kind: .suppressIdentification,
                   facts: "{DET}, who built the photo array and knew which photo was {DL}'s, showed it to the witness personally. {DL}'s was the only photo of someone wearing a red jacket like the one described. The witness was never told the person might not be in the array.",
                   shouldGrant: true,
                   explanation: "The lineup broke the Eyewitness Identification Reform Act three ways and singled out the defendant with the jacket. An unnecessarily suggestive procedure, plus a fleeting view at night, made misidentification substantially likely; the identification is excluded.",
                   doctrines: ["eyewitnessID"]),
        MotionSeed(kind: .suppressIdentification,
                   facts: "Two hours after the offense, officers drove the witness past {DL}, who was handcuffed beside a patrol car with a spotlight on {D.him}, three miles from the scene. The witness had described the person only as \"a guy in dark clothes.\"",
                   shouldGrant: true,
                   explanation: "A handcuffed, spotlighted show-up hours later and miles away is unnecessarily suggestive, and a vague description gives it no independent reliability. Suppression is required.",
                   doctrines: ["eyewitnessID"]),
        MotionSeed(kind: .suppressIdentification,
                   facts: "An officer who didn't know the suspect ran a six-person photo lineup with fillers matching the witness's description, read the standard instruction that the person may not be present, and recorded the witness's statement: \"I'm sure. I'd know that face anywhere.\"",
                   shouldGrant: false,
                   explanation: "The lineup followed the Act. Nothing about it was suggestive, so there is no basis to suppress; any doubts go to weight.",
                   doctrines: ["eyewitnessID"]),
        MotionSeed(kind: .suppressIdentification,
                   facts: "Ten minutes after the offense and two blocks away, the witness saw {DL} detained and said, \"That's the one. Same clothes,\" matching the detailed description the witness gave the 911 dispatcher.",
                   shouldGrant: false,
                   explanation: "A prompt show-up near the scene is justified by the need to confirm or clear a suspect quickly, and the detailed prior description makes the identification reliable under Manson v. Brathwaite.",
                   doctrines: ["eyewitnessID"])
    ]

    static let priorActsSeeds: [MotionSeed] = [
        MotionSeed(kind: .excludePriorActs,
                   facts: "The State intends to offer that {DL} was involved in a bar fight eleven years ago in another county, with a different person and different circumstances, to show {D.he} \"has a violent streak.\"",
                   shouldGrant: true,
                   explanation: "Offered only to show propensity, an old, dissimilar act is barred by Rule 404(b); even if marginally relevant, its prejudice substantially outweighs any probative value under Rule 403.",
                   doctrines: ["priorActs", "relevance"]),
        MotionSeed(kind: .excludePriorActs,
                   facts: "The State intends to offer that, three weeks before the offense, {DL} sent {V} a text reading \"you'll regret this,\" and was seen slashing the tires on {V}'s car.",
                   shouldGrant: false,
                   explanation: "Recent threats and acts against the same victim are admissible under Rule 404(b) to show motive and intent, and their probative value isn't substantially outweighed by unfair prejudice.",
                   doctrines: ["priorActs"]),
        MotionSeed(kind: .excludePriorActs,
                   facts: "The State intends to offer {DL}'s earlier conviction for a break-in where the same unusual method was used: entering through a pet door with a hooked rod and taking only jewelry.",
                   shouldGrant: false,
                   explanation: "A distinctive modus operandi is admissible under Rule 404(b) to show identity; North Carolina treats the rule as one of inclusion when the acts are similar enough.",
                   doctrines: ["priorActs"]),
        MotionSeed(kind: .excludePriorActs,
                   facts: "The State intends to offer that {DL} was arrested once for drug possession, a charge that was dismissed, to suggest {D.he} needed money.",
                   shouldGrant: true,
                   explanation: "A dismissed arrest for an unrelated offense, offered to suggest bad character and a motive by inference upon inference, is inadmissible propensity evidence.",
                   doctrines: ["priorActs", "characterEvidence"])
    ]

    static let indictmentSeeds: [MotionSeed] = [
        MotionSeed(kind: .dismissIndictment,
                   facts: "The indictment on count {COUNT} charges larceny of property \"belonging to the Dollar Mart,\" without alleging that Dollar Mart is a corporation or other entity capable of owning property.",
                   shouldGrant: true,
                   explanation: "A larceny indictment must name an owner that is a person or a legal entity capable of owning property; failing to allege that Dollar Mart is one is a fatal defect in the count.",
                   doctrines: ["indictment"]),
        MotionSeed(kind: .dismissIndictment,
                   facts: "The indictment on count {COUNT} omits the allegation that the defendant acted \"with intent to permanently deprive,\" an element of the offense charged.",
                   shouldGrant: true,
                   explanation: "An indictment that fails to allege an essential element doesn't charge the crime; the count must be dismissed.",
                   doctrines: ["indictment"]),
        MotionSeed(kind: .dismissIndictment,
                   facts: "The indictment on count {COUNT} misspells the victim's middle name and lists the street address one digit off. The defense doesn't claim it was misled.",
                   shouldGrant: false,
                   explanation: "Minor clerical errors that don't affect the elements or mislead the defense aren't fatal; after State v. Singleton they are reviewed for prejudice, and there is none.",
                   doctrines: ["indictment"]),
        MotionSeed(kind: .dismissIndictment,
                   facts: "The defense argues count {COUNT} should be dismissed because the indictment uses the statutory language but doesn't describe the evidence the State will offer.",
                   shouldGrant: false,
                   explanation: "An indictment tracking the statute and alleging the elements is sufficient; it need not lay out the State's evidence (G.S. 15A-924(a)(5)).",
                   doctrines: ["indictment"])
    ]

    static let speedyTrialSeeds: [MotionSeed] = [
        MotionSeed(kind: .dismissSpeedyTrial,
                   facts: "{DL} has been awaiting trial for {DELAY} months. The State requested nine continuances, twice because it misplaced the file. {DL} demanded a speedy trial in writing five times. A key defense witness has since died.",
                   shouldGrant: true,
                   explanation: "All four Barker factors favor the defendant: long delay, the State's fault, repeated demands, and real prejudice. Dismissal with prejudice is required.",
                   doctrines: ["speedyTrial"]),
        MotionSeed(kind: .dismissSpeedyTrial,
                   facts: "The case is {DELAY} months old, but {DEFDELAY} of those months came from continuances the defense itself requested. {DL} never raised the speedy-trial right until last week.",
                   shouldGrant: false,
                   explanation: "Delay requested by the defense doesn't count against the State, and the late assertion of the right weighs heavily against dismissal.",
                   doctrines: ["speedyTrial"])
    ]

    // MARK: Twists

    static let twists: [TwistSeed] = [
        TwistSeed(key: "caregiver", text: "{DL} is the sole caregiver for three children under ten. Their other parent died last year.",
                  mitigating: "Sole caregiver for three young children", mood: .sympathetic, ages: 21...55),
        TwistSeed(text: "{DL} is a Fort Bragg Army veteran diagnosed with severe PTSD after two combat tours.",
                  mitigating: "Combat veteran with diagnosed PTSD", mood: .sympathetic),
        TwistSeed(key: "youth", text: "{DL} turned 18 just three weeks before the offense, too old for juvenile court by less than a month.",
                  mitigating: "Youth: barely 18 at the time of the offense", ages: 18...18),
        TwistSeed(key: "senator", text: "{DL} is the child of a sitting state senator. Reporters are watching for any hint of favoritism.",
                  mood: .wantsConviction, mediaBoost: 2, ages: 18...45),
        TwistSeed(text: "While awaiting trial, {DL} was diagnosed with stage IV pancreatic cancer. Doctors estimate a year to live.",
                  mitigating: "Terminal illness", mood: .sympathetic),
        TwistSeed(key: "rejectedPlea", text: "Before trial, {DL} turned down a plea offer to a lesser felony in order to exercise the right to trial.", trialOnly: true),
        TwistSeed(key: "jailed", text: "{DL} has already spent {JAILTIME} in the Hollis County jail, unable to post a $5,000 secured bond.",
                  mitigating: "Already served {JAILTIME} awaiting trial"),
        TwistSeed(key: "smirk", text: "During testimony, {DL} smirked at witnesses and had to be admonished twice.",
                  aggravating: "Mocked witnesses from the defense table during testimony", mood: .wantsConviction, trialOnly: true),
        TwistSeed(key: "protest", text: "About 200 protesters have gathered outside the courthouse every day of trial.",
                  mood: .divided, mediaBoost: 1, trialOnly: true),
        TwistSeed(text: "District Attorney {ELECTEDDA} is up for re-election this fall and told the Ledger this case is \"exactly why the people elected me.\"",
                  mood: .wantsConviction, mediaBoost: 1),
        TwistSeed(text: "Three years ago, {DL} pulled a child from a burning car and received a city commendation.",
                  mitigating: "Documented act of heroism and community service", mood: .sympathetic),
        TwistSeed(key: "rehab", text: "Since the arrest, {DL} has completed a 12-month treatment program and held a steady job.",
                  mitigating: "Demonstrated rehabilitation since arrest"),
        TwistSeed(key: "posted", text: "During trial, {DL} posted about the case on social media, mocking the prosecution's witnesses.",
                  aggravating: "Publicly mocked witnesses during trial", mood: .wantsConviction, mediaBoost: 1, trialOnly: true),
        TwistSeed(key: "podcast", text: "A true-crime podcast with two million listeners is covering every day of this trial.",
                  mediaBoost: 2, trialOnly: true)
    ]

    // MARK: Ethics dilemmas

    static func ethicsEvents(hasVictim: Bool, retainedCounsel: Bool) -> [EthicsEvent] {
        var events: [EthicsEvent] = [
            EthicsEvent(title: "A Private Email",
                        body: "The night before trial, ADA {PROS} emails your personal account: \"Off the record, Judge, {DL} is much worse than this file shows. Trust me.\"",
                        doctrineID: "exParte",
                        options: [
                            EthicsOption(label: "Disclose the email to both sides on the record and say you will disregard it",
                                         result: "You read it into the record. Defense counsel thanks you; {PROS} looks at the floor. District Attorney {ELECTEDDA} calls that afternoon to apologize for the assistant."),
                            EthicsOption(label: "Delete it and say nothing",
                                         result: "You delete it and put it out of your mind.",
                                         laterHeadline: "Defense learns of undisclosed email between prosecutor and Judge {JUDGE}"),
                            EthicsOption(label: "Reply: \"What do you mean?\"",
                                         result: "{PROS} replies within minutes with three paragraphs about {DL}'s juvenile record and a rumor from the jail.",
                                         laterHeadline: "Judicial Standards Commission reviewing contact between Judge {JUDGE} and prosecutor")
                        ]),
            EthicsEvent(title: "An Old Connection",
                        body: "Reviewing the file, you realize {DL}'s parent was your college roommate. You haven't spoken in fifteen years.",
                        doctrineID: "disqualification",
                        options: [
                            EthicsOption(label: "Disclose it on the record and offer to recuse",
                                         result: "Both sides confer in the hallway and return to waive the issue on the record. The trial goes forward."),
                            EthicsOption(label: "Say nothing",
                                         result: "You decide fifteen years is long enough that it doesn't matter.",
                                         laterHeadline: "Ledger review: Judge {JUDGE} did not disclose family ties to defendant {D}")
                        ]),
            EthicsEvent(title: "In the Parking Deck",
                        body: "A reporter from WHCN-TV catches you at your car: \"Judge! Is {DL} going to walk?\"",
                        doctrineID: "publicComment",
                        options: [
                            EthicsOption(label: "\"I can't comment on a pending case.\"",
                                         result: "The clip runs for four seconds on the evening news."),
                            EthicsOption(label: "\"Not in my courtroom.\"",
                                         result: "It leads the 6 o'clock broadcast. The next morning, defense counsel files a motion asking you to recuse, attaching the clip. You deny it, but it's in the record now.",
                                         laterHeadline: "Defense cites Judge {JUDGE}'s TV remark in appeal"),
                            EthicsOption(label: "\"The evidence will speak for itself.\"",
                                         result: "Both sides spend the evening parsing what you meant.")
                        ]),
            EthicsEvent(title: "A Call from City Hall",
                        body: "The Port Hollis mayor's chief of staff calls chambers: \"The mayor would appreciate a strong message in this case. Election years are long, Judge.\"",
                        doctrineID: "exParte",
                        options: [
                            EthicsOption(label: "Report the call to the Judicial Standards Commission and disclose it to the parties",
                                         result: "You put the call on the record. Neither side knows what to make of it.",
                                         laterHeadline: "Mayor's office acknowledges call to judge's chambers during pending trial"),
                            EthicsOption(label: "End the call and do nothing further",
                                         result: "You hang up. The case goes on as if it never happened."),
                            EthicsOption(label: "\"I'll keep that in mind.\"",
                                         result: "\"That's all we ask,\" the chief of staff says, and hangs up.")
                        ]),
            EthicsEvent(title: "Gone Viral",
                        body: hasVictim
                            ? "{VL}'s family tags your personal account in a post: \"Judge, if you let {DL} walk, the blood is on YOUR hands.\" It has 40,000 shares."
                            : "A post tags your personal account: \"Judge, if you let {DL} walk, you're part of the problem.\" It has 40,000 shares.",
                        doctrineID: "publicComment",
                        options: [
                            EthicsOption(label: "Don't respond",
                                         result: "The post keeps circulating for a few days, then fades."),
                            EthicsOption(label: "Ask the Sheriff's Office to review it for threats",
                                         result: "Sheriff {SHERIFF} assigns a deputy to the courtroom door for the rest of the trial."),
                            EthicsOption(label: "Post a reply explaining the presumption of innocence",
                                         result: "Your reply gets 9,000 comments.",
                                         laterHeadline: "Judge {JUDGE}'s social media reply draws complaint")
                        ])
        ]
        if retainedCounsel {
            events.append(
            EthicsEvent(title: "A Gift Basket",
                        body: "A gift basket arrives at chambers from the firm representing {DL}: wine, chocolates, and two tickets to a Hurricanes playoff game. The card reads, \"With admiration.\"",
                        doctrineID: "gifts",
                        options: [
                            EthicsOption(label: "Return everything and disclose it to the prosecution",
                                         result: "Your judicial assistant sends it all back with a polite note. ADA {PROS} raises an eyebrow and says nothing."),
                            EthicsOption(label: "Keep the chocolates, return the tickets",
                                         result: "The chocolates are excellent."),
                            EthicsOption(label: "Keep it all",
                                         result: "You enjoy the game from lower level seats.",
                                         laterHeadline: "Photo shows Judge {JUDGE} at playoff game on defense firm's tickets")
                        ])
            )
        }
        return events
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

    // MARK: Prior records

    struct PriorSeed {
        let offense: String
        let ncClass: NCClass
        let sentences: [String]
    }

    static let priorSeeds: [PriorSeed] = [
        PriorSeed(offense: "Misdemeanor Larceny", ncClass: .misd1, sentences: ["45 days suspended, 12 months probation", "20 days active", "Prayer for judgment continued"]),
        PriorSeed(offense: "Simple Assault", ncClass: .misd2, sentences: ["30 days suspended, 12 months unsupervised probation", "Time served"]),
        PriorSeed(offense: "Assault on a Female", ncClass: .misdA1, sentences: ["60 days suspended, 18 months supervised probation", "75 days active"]),
        PriorSeed(offense: "Driving While Impaired", ncClass: .misd1, sentences: ["Level 5, 60 days suspended", "Level 3, 6 months suspended"]),
        PriorSeed(offense: "Resisting a Public Officer", ncClass: .misd2, sentences: ["Time served", "$100 fine and costs"]),
        PriorSeed(offense: "Possession of Drug Paraphernalia", ncClass: .misd1, sentences: ["$100 fine and costs", "Time served"]),
        PriorSeed(offense: "Assault with a Deadly Weapon", ncClass: .misdA1, sentences: ["75 days active", "60 days suspended, 24 months probation"]),
        PriorSeed(offense: "Possession of Schedule II (cocaine)", ncClass: .I, sentences: ["4–14 months suspended, 18 months probation", "5–15 months active"]),
        PriorSeed(offense: "Breaking or Entering", ncClass: .H, sentences: ["6–17 months suspended, 24 months probation", "8–19 months active"]),
        PriorSeed(offense: "Possession of Stolen Goods", ncClass: .H, sentences: ["5–15 months suspended, 30 months probation", "6–17 months active"]),
        PriorSeed(offense: "Felony Larceny", ncClass: .H, sentences: ["6–17 months suspended, 24 months probation", "9–20 months active"]),
        PriorSeed(offense: "PWISD Cocaine", ncClass: .H, sentences: ["8–19 months active", "6–17 months suspended, 36 months probation"]),
        PriorSeed(offense: "Common Law Robbery", ncClass: .G, sentences: ["13–25 months active", "10–21 months active"]),
        PriorSeed(offense: "Second-Degree Burglary", ncClass: .G, sentences: ["12–24 months active", "10–21 months suspended, 36 months probation"]),
        PriorSeed(offense: "Assault with a Deadly Weapon Inflicting Serious Injury", ncClass: .E, sentences: ["25–42 months active", "20–36 months active"])
    ]

    static let otherCounties = [
        "Wake County", "Mecklenburg County", "Cumberland County", "Robeson County", "New Hanover County",
        "Pitt County", "Guilford County", "Onslow County", "Johnston County", "Brunswick County"
    ]
}
