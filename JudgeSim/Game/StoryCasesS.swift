import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchS: [CaseTemplate] = [lowcountryLawyer, textingSuicide, hazingDeath, fakeKidnapping, brakeCheckShooting]

    // MARK: - 104. The lawyer (a prominent attorney's wife and son shot at the dog kennels)

    static let lowcountryLawyer = CaseTemplate(
        key: "story.lowcountryLawyer", category: .violent,
        headlines: ["Prominent Lawyer's Wife and Son Found Shot at Family Estate", "Kennel Video Places Lawyer at Scene Minutes Before Killings"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 10, lesserThreshold: 8,
        specification: "With premeditation and deliberation, killed {V}, the defendant's son, with a shotgun at the dog kennels on the family property.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, the defendant's wife, with a rifle at the dog kennels.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "embezzlement100k", specification: "Embezzled $3.4 million from his law firm and clients, including a settlement owed to the family of a housekeeper.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Lied to investigators about being at the kennels, and staged a roadside shooting of himself to gain sympathy.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "falseReport", specification: "Falsely reported to police that a stranger shot him on a roadside three months after the killings.", chance: 1.0, threshold: 0)
        ],
        ageRange: 52...56, occupations: ["personal injury lawyer"], hasVictim: true,
        summaries: [
            "On {DATE}, {D}, a fourth-generation lawyer from one of the county's most powerful families, called 911 from the family's hunting estate in {HOOD} to report finding his wife, {VIC2}, and son, {V}, shot to death by the dog kennels. {VL} was killed with two shotgun blasts; {VIC2} with five rounds from a rifle. {DL} told investigators he'd been napping at the house and never went to the kennels. That same day, his law firm's CFO had confronted him about missing money. A video {VL} took on his phone at 8:44 p.m., found a year later, has {DL}'s voice in the background at the kennels, minutes before both phones stopped moving for good. {DL} has since admitted stealing millions from clients and to lying about the kennels, but denies the murders."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Kennel Video", "{VL}'s phone video at 8:44 p.m., with three voices: {VL}, {VIC2}, and, as identified by multiple witnesses, {DL}.", .search),
            E(.digital, 3, "Phone Activity", "{VIC2}'s and {VL}'s phones stop all activity by 8:50 p.m. {DL}'s phone shows no steps from 8:05 to 9:02, then 283 steps in 15 minutes as he drives to his mother's house.", .search),
            E(.document, 3, "Financial Crimes", "Records of $3.4 million stolen from clients and the firm, and a CFO confrontation that day; a court hearing on his finances was set for the next week."),
            E(.forensic, 2, "Weapons", "Family rifles of the same caliber; spent casings at the kennels match casings from a range on the property.")
        ],
        defenseEvidence: [
            E(.document, 2, "No Weapons Found", "Neither murder weapon was ever found."),
            E(.forensic, 2, "No Blood on Clothes", "No blood or gunshot residue found on the clothes {DL} wore when officers arrived."),
            E(.statement, 1, "Boat Crash Threats", "{VL} faced charges from a fatal boat crash and had received threats on social media.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Family friend who identified the voice on the video",
                        direct: ["\"That's his voice.\""],
                        cross: ["\"It's three seconds of audio.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("Whose voices are on the 8:44 video?", "\"{VL}'s. {VIC2}'s. And his. I've known him thirty years. That's his voice calling the dog.\""),
                            .cross("It's a few seconds of muffled audio?", "\"It's enough. I'd know it anywhere.\""),
                            .cross("You only came forward after you heard the State's theory?", "\"I came forward when they asked me.\"")
                        ]),
            WitnessSeed(name: nil, role: "Law firm CFO",
                        direct: ["\"I confronted him that morning.\""],
                        cross: ["\"Financial crimes aren't murder.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened on the day of the killings?", "\"I told him I'd found a missing fee, almost $800,000, and I wanted to know where it went. He said he'd explain. That night his wife and son were dead.\""),
                            .cross("You'd have reported him either way?", "\"Either way. The numbers didn't add up.\""),
                            .cross("Stealing money doesn't make someone a killer?", "\"No. But he was about to lose everything.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense crime scene expert",
                        direct: ["\"Two shooters is more likely.\""],
                        cross: ["\"I wasn't at the scene.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What does the shooting pattern suggest?", "\"Two different weapons, two different positions, fired within moments. That suggests two shooters.\""),
                            .cross("You reviewed photos; you never went to the scene?", "\"Photos and reports. I was hired after the scene was released.\""),
                            .cross("One person can carry two guns?", "\"It's possible.\"")
                        ])
        ],
        prosecutionTheory: ["The day his thefts were about to come out, {D} killed his wife and son to buy sympathy and time. He lied about being at the kennels until the video caught his voice."],
        defenseTheory: ["{DL} is a thief and a liar, and he's admitted it. But no weapon, no blood, and a father who loved his son. Someone else, with a grudge from the boat crash, was at those kennels."],
        aggravating: ["The offense involved multiple victims", "The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VIC2}'s sister: \"He took my sister and my nephew, and then he stood at their funeral and accepted our hugs.\""],
        allocutions: ["\"I lied about the kennels because I was paranoid from pills. I did not kill my wife and my son. I would never.\""],
        guiltyTruths: ["A blue raincoat recovered at {DL}'s mother's house was found to have gunshot residue on its lining."],
        innocentTruths: ["A man later charged in another killing told a cellmate he and a friend had gone to the kennels that night over the boat crash."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        extras: ["VIC2": ["Maggie", "Margaret", "Lynn"]],
        story: StoryExtras(
            timeline: [(0, "Morning: CFO confronts {DL} about missing money."),
                       (0, "8:44 p.m.: {VL}'s video at the kennels captures three voices."),
                       (0, "8:49 p.m.: both victims' phones go still."),
                       (0, "9:06 p.m.: {DL} drives to his mother's house."),
                       (0, "10:07 p.m.: {DL} calls 911 from the kennels."),
                       (95, "{DL} reports being shot by a stranger on a roadside; later admits staging it."),
                       (400, "Kennel video recovered from {VL}'s phone; {DL} charged with the murders.")],
            howIdentified: "The kennel video and phone data contradicting his account.",
            notDone: ["The house was not processed for blood that night."],
            defendantExam: [
                .direct("Why did you lie about the kennels?", "\"I was addicted to opioids. I was paranoid. I panicked. I was down there for a few minutes and went back to the house.\""),
                .direct("Did you kill your wife and son?", "\"No. I would never hurt them.\""),
                .cross("You lied to police for over a year.", "\"Fourteen months. I told myself I was protecting my kids.\""),
                .cross("You lied to your clients for a decade. Why should anyone believe you now?", "\"Because I'm telling the truth about this.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Tell the court about every client he stole from.\"",
                                  answer: "\"There are dozens...\"",
                                  raisedBy: .defense, onCross: false, grounds: "Unfair prejudice (Rule 403)", shouldSustain: false,
                                  explanation: "The financial crimes are charged in this case and are the State's theory of motive; the court may limit cumulative detail, but the evidence is admissible.",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "A video. Three voices. Two phones go silent. And a man who swore he was never there.",
            defenseOpening: "A thief, yes. A liar, yes. A murderer? The State can't prove it.",
            prosecutionClosing: "He lied about the one place that mattered.",
            defenseClosing: "No weapon, no blood, no proof. Just a man everyone wants to hate.",
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(relationship: "The defendant's son."),
            employer: "the family law firm",
            family: "Widowed, 1 child. The late spouse is a victim in this case, as is a second son.",
            residence: "The family home in {HOOD}; the family also owns a hunting estate there.",
            yearsAtJob: 26,
            sameSurname: true
        )
    )

    // MARK: - 105. The texts (a girlfriend who urged her boyfriend to go through with it)

    static let textingSuicide = CaseTemplate(
        key: "story.textingSuicide", category: .violent,
        headlines: ["Teen Charged After Texts Urged Boyfriend to Take His Own Life", "'Get Back In': Texts at Center of Manslaughter Case"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Unlawfully caused the death of {V} by wanton and reckless conduct, urging him by phone and text to kill himself and telling him to get back in his truck as it filled with carbon monoxide.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Repeatedly sent electronic messages to {V} for the purpose of abusing and tormenting him.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...18, occupations: ["high school senior"], hasVictim: true,
        summaries: [
            "On the night of {DATE}, {V}, 18, died in his pickup in a store parking lot in {HOOD}, found the next morning, poisoned by a gas-powered water pump running in the cab. He had struggled with depression for years. Hundreds of texts from his girlfriend, {D}, over the previous weeks pushed him to do it: \"You keep pushing it off and you say you'll do it but you never do,\" and \"Tonight is the night.\" That evening, {DL} was on the phone with him. She later texted a friend: \"I told him to get back in.\" She never called 911 or his family. The defense says {VL} had been planning his death long before, that words aren't a weapon, and that the First Amendment protects speech."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Texts Urging Suicide", "Messages over two weeks: \"Tonight is the night,\" \"You just need to do it,\" \"When are you doing it?\" and a plan for the pump.", .search),
            E(.digital, 3, "Text to Friend", "{DL} to a friend afterward: \"I told him to get back in because I knew he would do it all over again the next day.\"", .search),
            E(.document, 2, "Phone Records", "A 43-minute call between {DL} and {VL} during the time he died."),
            E(.statement, 2, "No Call for Help", "{DL} called no one during or after the call; she texted {VL}'s sister asking where he was the next day.")
        ],
        defenseEvidence: [
            E(.document, 2, "Prior Attempts", "{VL}'s medical records show two earlier attempts and a long-standing plan predating the relationship."),
            E(.digital, 2, "Earlier Texts", "Months of earlier texts in which {DL} begged {VL} to get help and to tell his parents."),
            E(.document, 1, "Medication", "{DL} was taking an antidepressant that a psychiatrist says can affect a teenager's judgment.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Detective who recovered the messages",
                        direct: ["\"She told him to get back in.\""],
                        cross: ["\"Earlier texts begged him to get help.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the messages show in the last two weeks?", "\"A countdown. She helped him research methods, pushed him when he hesitated, and asked over and over when he'd do it.\""),
                            .direct("And the text to her friend?", "\"That he got out of the truck because he was scared, and she told him to get back in.\""),
                            .cross("Months earlier, {DL} begged him to get help?", "\"She did. That changed.\""),
                            .cross("There's no recording of what was actually said on that call?", "\"No. We have the call records and her own text describing it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Friend who received the text",
                        direct: ["\"She said she told him to get back in.\""],
                        cross: ["\"She was hysterical.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"We're friends. We talked all the time.\""),
                            .direct("What did {DL} tell you?", "\"That she was on the phone, he got out of the truck, and she told him to get back in. She said his death was her fault.\""),
                            .direct("How did you react when you read that?", "\"I felt sick. I didn't know what to write back.\""),
                            .cross("She was crying and upset when she wrote that?", "\"Yes. She was a mess.\""),
                            .cross("You weren't on that call, so all you know is what {DL} wrote you?", "\"Yes. Only what she told me.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense psychiatrist",
                        direct: ["\"She believed she was helping him.\""],
                        cross: ["\"She knew death was the outcome.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was {DL}'s state of mind?", "\"An immature, medicated teenager who came to believe, wrongly, that ending his pain was what a loving person would support.\""),
                            .direct("Did the medication matter?", "\"She was on an antidepressant that can affect a teenager's judgment. In my opinion it's part of the picture.\""),
                            .cross("She understood he would die?", "\"She understood. That's the hard part of my report.\""),
                            .cross("She didn't call anyone?", "\"She didn't. Not one call.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pressured a vulnerable young man for weeks, and when he got out of the truck, she told him to get back in. Her words were the cause, and her silence let him die."],
        defenseTheory: ["{VL} chose to end his life, as he had tried before. {DL} was a confused, medicated teenager. Words alone, however cruel, aren't manslaughter."],
        aggravating: ["The victim was especially vulnerable"],
        mitigating: ["{DL} was 18 with no prior record", "The defendant suffered from a mental condition that significantly reduced culpability"],
        victimImpacts: ["{VL}'s mother: \"He was getting better. He had plans for college. She talked him out of living.\""],
        allocutions: ["\"I loved him. I will regret that night for the rest of my life.\""],
        guiltyTruths: ["A deleted note on {DL}'s phone, recovered later, drafted a social media post about grieving her boyfriend, written two days before his death."],
        innocentTruths: ["A suicide note {VL} wrote weeks before the texts began, found later in a book in his room, described the exact plan."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-400, "{DL} and {VL} begin dating, mostly by text."),
                       (-14, "Messages turn to urging and planning."),
                       (0, "6:00 p.m.: {VL} drives to a store parking lot."),
                       (0, "8:31–9:14 p.m.: 43-minute phone call."),
                       (1, "{VL} found dead in his truck."),
                       (40, "{DL}'s text to a friend recovered.")],
            howIdentified: "{VL}'s phone, recovered from the truck.",
            notDone: ["The audio of the phone call was never recorded; only {DL}'s later text describes it."],
            defendantExam: [
                .direct("Why did you send those messages?", "\"He'd been suffering so long. He said it was the only way to stop hurting. I thought supporting him was what he needed. I was wrong.\""),
                .direct("Did you tell him to get back in the truck?", "\"I don't remember exactly what I said. I was panicking.\""),
                .cross("You wrote that you told him to get back in.", "\"I wrote a lot of things I don't remember.\""),
                .cross("You didn't call 911.", "\"I didn't. I can't explain that to you.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Doctor, is she a danger to anyone?\"",
                                  answer: "\"No.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Relevance to guilt", shouldSustain: true,
                                  explanation: "Future dangerousness doesn't bear on whether the elements were proved; it may be offered at sentencing.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "\"Tonight is the night.\" And when he got out of the truck: get back in.",
            defenseOpening: "A tragedy that began long before these texts, and a teenager who didn't understand.",
            prosecutionClosing: "She was there, by phone, and she sent him back in.",
            defenseClosing: "Cruel words aren't a weapon, and his choice was his own.",
            genders: ["D": .female, "V": .male],
            victim: VictimFacts(relationship: "The defendant's boyfriend."),
            family: "Single, no children. The victim in this case was the defendant's boyfriend."
        )
    )

    // MARK: - 106. The pledge (a fraternity hazing night caught on camera)

    static let hazingDeath = CaseTemplate(
        key: "story.hazingDeath", category: .violent,
        headlines: ["Pledge Dies After Fraternity 'Gauntlet' Night", "Security Cameras Show Brothers Waited 12 Hours to Call for Help"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 11, lesserThreshold: 9,
        specification: "Unlawfully caused the death of {V}, a pledge, by culpable negligence in forcing him to drink and then failing to get medical help after he fell down the basement stairs.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Deleted security camera footage from the fraternity house after {V}'s death.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "simpleAssault", specification: "Struck {V} and poured liquid on him while he lay unconscious on a couch.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...22, occupations: ["college junior and fraternity pledge master"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 19, a pledge at a fraternity near the university in {HOOD}, was made to run a \"gauntlet\" of drinking stations, downing nearly a bottle and a half of vodka in under two hours. His blood alcohol later measured 0.36. He fell headfirst down the basement stairs. Brothers carried him to a couch. The house's own security cameras show him struggling for twelve hours: falling, trying to stand, hitting his head again, while brothers walked past. At one point {DL} slapped him and poured a cup of liquid on his face. No one called 911 until the next morning. He died of a ruptured spleen and brain injuries. {D}, the pledge master who organized the gauntlet, is one of several brothers charged. Someone deleted footage from the cameras after the death; the police recovered it."
        ],
        prosecutionEvidence: [
            E(.video, 3, "House Security Video", "Twelve hours of footage: {VL} falling down the stairs, carried to a couch, falling repeatedly, {DL} slapping him and pouring liquid on him, and others stepping over him.", .search),
            E(.digital, 3, "Group Messages", "The pledge master's messages planning the gauntlet, and a 3 a.m. message: \"he's fine, just let him sleep it off.\"", .search),
            E(.forensic, 2, "Autopsy", "BAC estimated at 0.36; ruptured spleen and traumatic brain injury; death came after hours of internal bleeding."),
            E(.document, 2, "Deleted Footage", "The camera system's log shows footage deleted the day after, from an account {DL} used.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Others Present", "Thirty people were at the house; others, not {DL}, were with {VL} through the night."),
            E(.statement, 1, "Tried to Help", "{DL} put {VL} on his side and placed a backpack behind him to keep him from rolling."),
            E(.document, 1, "Voluntary Drinking", "Pledges were told they could stop at any station.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Fraternity brother (cooperating)",
                        direct: ["\"Someone said call 911 and he said no.\""],
                        cross: ["\"I didn't call either.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("Who set up the gauntlet?", "\"{DL}. {D.He} was pledge master. {D.He} planned the drinking stations.\""),
                            .direct("Did anyone suggest calling for help?", "\"Around midnight a brother said we should call 911. {DL} said no, it'd get the house shut down, and he'd be fine.\""),
                            .cross("You didn't call either?", "\"No. I'll live with that.\""),
                            .cross("You've been promised leniency?", "\"My charges were reduced.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic pathologist",
                        direct: ["\"He could have been saved.\""],
                        cross: ["\"The fall caused the injuries.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What was the cause of death?", "\"A ruptured spleen and traumatic brain injury. He bled internally for hours.\""),
                            .direct("How intoxicated was he?", "\"His blood alcohol was estimated at 0.36. That's a dangerous level on its own.\""),
                            .direct("Would prompt medical care have made a difference?", "\"Almost certainly. The spleen bled for hours. With an ambulance in the first two hours, he very likely survives.\""),
                            .cross("The fall caused the injuries, not anyone hitting him?", "\"The fall was the main injury. The delay is what killed him.\""),
                            .cross("You can't say to the minute when it became too late?", "\"No. Not to the minute.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Another pledge",
                        direct: ["\"We could stop if we wanted.\""],
                        cross: ["\"Nobody stopped.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Were you at the house that night?", "\"Yes. I was a pledge too. I went through the gauntlet.\""),
                            .direct("Were pledges forced to drink?", "\"They said we could stop. Nobody held anybody down.\""),
                            .direct("Did you see {DL} do anything for {VL}?", "\"I saw {D.him} put {VL} on his side and stick a backpack behind him so he wouldn't roll.\""),
                            .cross("Did anyone stop?", "\"No. You don't, if you want to get in.\""),
                            .cross("And nobody called 911 that night?", "\"No. Nobody did.\"")
                        ])
        ],
        prosecutionTheory: ["{D} designed a drinking gauntlet that left a nineteen-year-old with a deadly blood alcohol level, then refused to call for help to protect the house. Twelve hours of video show what culpable negligence looks like."],
        defenseTheory: ["{VL}'s death is a tragedy shared by thirty people. {DL} didn't push him down the stairs and tried to keep him safe. The State is singling out one young man for a group's failure."],
        aggravating: ["The victim was especially vulnerable"],
        mitigating: ["No prior criminal record", "The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s father: \"Twelve hours. Any one of them could have picked up a phone. He was alone in a house full of people.\""],
        allocutions: ["\"I think about it every hour of every day. I should have called. I'm so sorry.\""],
        guiltyTruths: ["A recovered message showed {DL} texting a brother at 7 a.m., before anyone called 911: \"delete the basement camera.\""],
        innocentTruths: ["A recording found later showed {DL} pleading with the chapter president at 1 a.m. to call an ambulance and being overruled."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "9:20 p.m.: the gauntlet begins."),
                       (0, "11:00 p.m.: {VL} falls down the basement stairs."),
                       (0, "Midnight: a brother suggests calling 911; the suggestion is rejected."),
                       (1, "10:48 a.m.: 911 called."),
                       (2, "{VL} dies at the hospital."),
                       (3, "Footage found deleted; later recovered.")],
            howIdentified: "The fraternity house's own camera system.",
            notDone: ["The chapter president's phone was not searched."],
            defendantExam: [
                .direct("Why didn't you call 911?", "\"I thought he was just drunk. Everyone had seen people pass out before. I put him on his side. I thought he'd sleep it off.\""),
                .direct("Did you delete the footage?", "\"No. I don't know who did.\""),
                .cross("Someone suggested calling, and you said no.", "\"I said wait. I didn't think it was serious.\""),
                .cross("The deletion came from your account.", "\"Other people knew my password.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Weren't you the one who poured the drinks at the third station?\"",
                                  answer: "\"Yes.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "A cooperating witness's own role in the events bears on bias and credibility; the question is proper cross-examination.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Twelve hours on camera. A boy falling over and over, and a house that wouldn't call for help.",
            defenseOpening: "A shared failure, and one young man made to carry all of it.",
            prosecutionClosing: "He planned the drinking and blocked the call. That's culpable.",
            defenseClosing: "Thirty people were in that house. Negligence isn't a crime unless it's this man's.",
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(occupation: "College student and fraternity pledge", relationship: "A pledge; the defendant was the fraternity's pledge master.")
        )
    )

    // MARK: - 107. The kidnapping that wasn't (a jogger found on the highway)

    static let fakeKidnapping = CaseTemplate(
        key: "story.fakeKidnapping", category: .publicOrder,
        headlines: ["Missing Mother Found on Highway After Three Weeks; Describes Abduction", "Prosecutors: Kidnapping Was a Hoax"],
        primaryLaw: "falseReport", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Made a false report to law enforcement that two women abducted and held her for three weeks.",
        secondary: [
            SecondaryCharge(lawID: "falseReport", specification: "Gave a false description of her abductors to an FBI sketch artist, sending investigators after nonexistent suspects.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $30,000 in victim compensation and counseling payments by false pretenses.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Self-inflicted injuries, including a brand, to support a false account of captivity.", chance: 1.0, threshold: 0)
        ],
        ageRange: 34...39, occupations: ["stay-at-home mother"], hasVictim: false,
        summaries: [
            "{D}, a mother of two from {HOOD}, vanished while jogging. Her husband found her phone and earbuds on the road. For three weeks hundreds of volunteers searched and the story drew national attention. On {DATE}, at dawn on Thanksgiving, she was found on the side of the interstate a hundred miles away, bound with a chain, her hair cut, her face beaten, and a brand on her shoulder. She told investigators two Hispanic women with a gun had held her in a closet. There were no such women. DNA on her clothes led to a former boyfriend from another state, who told the FBI she asked him to pick her up, stayed at his apartment, and hurt herself. She has been paid $30,000 from the state's victim compensation fund."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Ex-Boyfriend's Statement", "The former boyfriend says {DL} asked him to pick her up, stayed at his apartment, and told him to say nothing; he has rental car and gas receipts for the pickup and drop-off."),
            E(.digital, 3, "Pre-Paid Phone", "Texts between {DL} and the ex-boyfriend on a prepaid phone, planning the pickup weeks earlier.", .search),
            E(.forensic, 2, "Apartment Evidence", "{DL}'s DNA and hair in the boyfriend's apartment, and a store receipt for the type of chain she was found in."),
            E(.document, 2, "Compensation Claim", "A $30,000 claim to the victim compensation fund citing the abduction.")
        ],
        defenseEvidence: [
            E(.document, 2, "Mental Health", "Records of a long history of depression and dissociative episodes."),
            E(.statement, 1, "Real Injuries", "Doctors confirmed real injuries and weight loss consistent with captivity."),
            E(.statement, 1, "Ex-Boyfriend's Motive", "The former boyfriend avoided charges by cooperating.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Former boyfriend",
                        direct: ["\"She asked me to come get her.\""],
                        cross: ["\"I'm not being charged.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How did {DL} come to be at your apartment?", "\"She texted me that she needed to get away, that her husband was abusive. I drove ten hours and picked her up. She stayed three weeks. She hurt herself. She asked me to drive her back and leave her by the highway.\""),
                            .direct("How was the pickup arranged?", "\"Texts on a prepaid phone, weeks ahead. She told me when and where to be.\""),
                            .cross("You're not being charged?", "\"Nobody's charged me. Nobody's promised me anything either.\""),
                            .cross("You didn't call anyone during three weeks of national news?", "\"She begged me not to. I should have.\"")
                        ]),
            WitnessSeed(name: nil, role: "FBI agent",
                        direct: ["\"The abductors never existed.\""],
                        cross: ["\"Her injuries were real.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What happened to the two women {DL} described?", "\"We spent months and thousands of hours looking for them. They don't exist. The sketch she helped create was shared across the country.\""),
                            .direct("What led you to the former boyfriend?", "\"Male DNA on her clothes. It matched him.\""),
                            .direct("What did you find at his apartment?", "\"Her DNA and hair, and a store receipt for the same type of chain she was found in.\""),
                            .cross("Her injuries were real?", "\"Self-inflicted, according to the evidence. But real.\""),
                            .cross("The former boyfriend hasn't been charged because he cooperated?", "\"He hasn't been charged. He cooperated.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Psychiatrist",
                        direct: ["\"She was in a dissociative crisis.\""],
                        cross: ["\"She planned the pickup weeks ahead.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What is {DL}'s history?", "\"A long history of depression and dissociative episodes. It's all through her records.\""),
                            .direct("What explains her account?", "\"A severe dissociative episode. She may have partly believed the story she told.\""),
                            .cross("She arranged a prepaid phone and a pickup weeks in advance?", "\"Yes. That's planning.\""),
                            .cross("And she filed a $30,000 compensation claim citing the abduction?", "\"She did. I can't tell you what she believed when she filed it.\"")
                        ])
        ],
        prosecutionTheory: ["{D} staged her own abduction, cost the community months of fear and the government thousands of hours, and then took money meant for real crime victims."],
        defenseTheory: ["{DL} is a deeply ill woman. The false report charge is real, but the compensation claim came from a person who may have believed her own story."],
        aggravating: ["The offense involved the taking of property of great monetary value (G.S. 15A-1340.16(d)(14))"],
        mitigating: ["No prior criminal record", "The defendant suffered from a mental condition that significantly reduced culpability"],
        victimImpacts: ["A volunteer searcher: \"I took two weeks off work to walk ditches looking for her. My kids were afraid to go outside.\""],
        allocutions: ["\"I'm ashamed of the pain I caused. I'm getting help. I'll pay back every dollar.\""],
        guiltyTruths: ["A search history on the prepaid phone, recovered later, included \"how long do brands take to heal.\""],
        innocentTruths: ["A treating psychiatrist's notes from before the disappearance describe {DL} reporting fears of being taken by two women, years before any of this."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-40, "Texts arranging the pickup begin on a prepaid phone."),
                       (-22, "{DL} disappears while jogging; phone found on the road."),
                       (0, "{DL} found on the interstate on Thanksgiving morning."),
                       (2, "{DL} describes two female abductors."),
                       (150, "DNA leads to the former boyfriend."),
                       (190, "{DL} charged.")],
            howIdentified: "Male DNA on her clothes, matched to a former boyfriend.",
            notDone: ["No forensic psychiatric evaluation was done before charging."],
            defendantExam: [
                .direct("Were you abducted?", "\"I wasn't kidnapped by those women. I've had to accept that. I was running from something, and I can't explain all of it.\""),
                .direct("Why take the compensation money?", "\"At the time I told the story, I think part of me believed it.\""),
                .cross("You planned it for weeks.", "\"I planned to leave. I didn't plan the rest.\""),
                .cross("You described two women to a sketch artist.", "\"Two women. I was sure there were two.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Doctor, would prison make her condition worse?\"",
                                  answer: "\"Almost certainly.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Relevance to guilt", shouldSustain: true,
                                  explanation: "The effect of punishment isn't relevant to guilt; it may be offered at sentencing.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Three weeks of searching for two women who never existed.",
            defenseOpening: "A false report, yes, from a woman who is very sick.",
            prosecutionClosing: "A prepaid phone, a planned pickup, and a claim for victims' money.",
            defenseClosing: "Mental illness doesn't excuse it, but it explains it.",
            when: .thanksgiving,
            genders: ["D": .female],
            family: "Married, 2 children."
        )
    )

    // MARK: - 108. The brake check (road rage on the interstate)

    static let brakeCheckShooting = CaseTemplate(
        key: "story.brakeCheckShooting", category: .violent,
        headlines: ["Driver Shot Dead After Brake-Check on I-40", "Shooter Says He Feared Being Run Off the Road"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 8, lesserThreshold: 6,
        specification: "Unlawfully and with malice killed {V} by shooting into {V.his} car on the interstate.",
        secondary: [
            SecondaryCharge(lawID: "dischargingOccupied", specification: "Discharged a handgun into a moving vehicle occupied by {V} and a passenger.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "awdwik", specification: "Assaulted the passenger, {ALT}, with a deadly weapon with intent to kill; a bullet grazed the passenger's arm.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove at more than 95 mph, weaving through traffic in pursuit of {V}'s car.", chance: 1.0, threshold: 0)
        ],
        ageRange: 29...44, occupations: ["HVAC technician", "landscaper", "insurance adjuster"], hasVictim: true,
        summaries: [
            "On {DATE}, on Interstate 40 near the {HOOD} exit, {V} braked hard in front of {D}'s pickup after {DL} tailgated {V.him} for two miles. {DL} swerved, then chased {VL}'s car at more than 95 mph for four miles. A dashcam in another car shows {DL}'s pickup pulling alongside and {DL} firing four shots through the passenger window. {VL} was hit in the neck and the car hit the median. {V.His} passenger, {ALT}, was grazed. {DL} drove home, parked the truck in a relative's garage, and turned himself in two days later with a lawyer. He says {VL} brake-checked him three times and swerved toward his truck, and he fired because he thought he would be run off the road."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dashcam Footage", "Another driver's dashcam: the pickup speeding alongside, a muzzle flash, the car veering into the median."),
            E(.forensic, 3, "Ballistics", "Four .40-caliber casings in {DL}'s truck bed; bullets from {VL}'s car match {DL}'s pistol.", .search),
            E(.statement, 2, "Passenger", "{ALT} says {VL} braked once after being tailgated, then tried to get away."),
            E(.document, 1, "Hidden Truck", "The pickup found in a relative's garage under a tarp.")
        ],
        defenseEvidence: [
            E(.video, 2, "Earlier Dashcam Clip", "A different clip shows {VL}'s car braking hard in front of the pickup twice."),
            E(.statement, 2, "Swerve", "{DL} says the car swerved into his lane before he fired."),
            E(.document, 1, "Concealed Carry Permit", "{DL} held a valid concealed carry permit and had no record.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{ALT}", role: "Passenger in the victim's car",
                        direct: ["\"We were trying to get away.\""],
                        cross: ["\"{V.He} did brake hard once.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened after the brake?", "\"The truck came up behind us, flashing, honking, so close I couldn't see its headlights. {VL} said, 'Let's just get off at the next exit.' Then it came alongside and I saw a gun.\""),
                            .direct("What happened when the shots were fired?", "\"Glass everywhere. {VL} was hit in the neck and the car went into the median. A bullet grazed my arm.\""),
                            .cross("{VL} braked hard in front of the truck?", "\"Once. After it rode our bumper for miles.\""),
                            .cross("Did your car swerve toward the truck?", "\"No. We were trying to get away from it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Highway Patrol crash reconstructionist",
                        direct: ["\"The truck chased them.\""],
                        cross: ["\"Both drivers were aggressive.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the dashcams and data show?", "\"After the brake, the pickup accelerated to 97 mph and closed four miles on the car. The car was in the right lane, slowing, when the shots were fired.\""),
                            .direct("Where were the shots fired from?", "\"From the pickup, pulled alongside, through the car's passenger window. Four casings were recovered from the truck bed.\""),
                            .cross("Both drivers were driving aggressively?", "\"Before the brake check, yes. After it, one of them was chasing the other.\""),
                            .cross("And another clip shows {VL}'s car braking hard in front of the pickup twice?", "\"Yes, it does.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Driver behind both cars",
                        direct: ["\"The car brake-checked him twice.\""],
                        cross: ["\"The truck went after them.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where were you?", "\"On I-40, behind both of them.\""),
                            .direct("What did you see?", "\"The car slammed its brakes twice in front of the truck. Nearly caused a pileup.\""),
                            .direct("Was that dangerous?", "\"Yes. At highway speed, somebody could have died right there.\""),
                            .cross("After that, the truck sped up and chased the car?", "\"Yes. Way faster than everyone else.\""),
                            .cross("And before any braking, the truck had been riding the car's bumper?", "\"Yes. It was right on it.\"")
                        ])
        ],
        prosecutionTheory: ["A brake check made {D} angry. He chased {V} for four miles at 95 mph and fired four shots into the car. That is malice, not fear."],
        defenseTheory: ["{VL} started a dangerous confrontation at highway speed. {DL} feared being forced off the road and fired in a split second. At most, this is manslaughter."],
        aggravating: ["The defendant knowingly created a great risk of death to more than one person"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{VL}'s mother: \"Everybody's been brake-checked. Nobody should die for it.\""],
        allocutions: ["\"I lost my temper. I'll never forgive myself.\""],
        guiltyTruths: ["A text {DL} sent his brother from the road, recovered later, read: \"this guy is about to learn.\""],
        innocentTruths: ["A third dashcam surfaced showing {VL}'s car swerving hard toward the truck a moment before the shots."],
        moods: [.wantsConviction], doctrines: ["selfDefense", "imperfectSelfDefense", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(0, "5:12 p.m.: {DL} tailgates {VL} on I-40."),
                       (0, "5:14 p.m.: {VL} brakes hard in front of the pickup."),
                       (0, "5:15–5:18 p.m.: the pickup chases the car at up to 97 mph."),
                       (0, "5:18 p.m.: four shots; the car hits the median."),
                       (2, "{DL} turns himself in.")],
            howIdentified: "A dashcam captured the pickup's tag.",
            notDone: ["Not all of the dashcam owners who called in were interviewed."],
            defendantExam: [
                .direct("Why did you fire?", "\"The car braked on me three times, then swerved at my truck. I thought he was trying to put me into the guardrail at seventy miles an hour.\""),
                .direct("Why chase them?", "\"I wasn't chasing. I was trying to get past.\""),
                .cross("At 97 miles an hour, for four miles.", "\"I was scared.\""),
                .cross("And then you hid the truck under a tarp.", "\"My lawyer said to keep it safe for evidence.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"In your opinion, was the defendant in fear for his life?\"",
                                  answer: "\"No.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation about the defendant's state of mind", shouldSustain: true,
                                  explanation: "The reconstructionist can testify to speeds and positions, not to what the defendant feared.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A brake check. Four miles. Ninety-seven miles an hour. Four shots.",
            defenseOpening: "A dangerous stranger, a highway, and a split second.",
            prosecutionClosing: "You don't chase what you're afraid of.",
            defenseClosing: "Honest fear, even if unreasonable, makes this manslaughter.",
            genders: ["D": .male, "V": .male, "ALT": .female],
            victim: VictimFacts(relationship: "Strangers; they met on the highway.")
        )
    )
}
