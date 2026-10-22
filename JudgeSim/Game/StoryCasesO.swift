import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchO: [CaseTemplate] = [affluenzaCrash, paradeSUV, eyeDropPoisoning, swattingCall, showerStabbing]

    // MARK: - 84. The rich kid's pickup (a drunk teenager kills four on a country road)

    static let affluenzaCrash = CaseTemplate(
        key: "story.affluenzaCrash", category: .traffic,
        headlines: ["Four Killed by Drunk Teen Driver on Old Mill Road", "Expert Blames 'Privilege' in Fatal Crash Defense"],
        primaryLaw: "felonyDBV", lesserLaw: "misdDBV", threshold: 10, lesserThreshold: 8,
        specification: "While impaired, unlawfully and unintentionally caused the death of {V}, whose car had broken down on Old Mill Road.",
        secondary: [
            SecondaryCharge(lawID: "felonyDBV", specification: "While impaired, unlawfully caused the death of {VIC2}, who had stopped to help {V}.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "felonyDBV", specification: "While impaired, unlawfully caused the death of {VIC3}, who lived beside the road and came out to help.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "felonyDBV", specification: "While impaired, unlawfully caused the death of {VIC4}, a youth pastor who stopped to help.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "misdLarceny", specification: "Stole two cases of beer from a {CITY} grocery store hours before the crash.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...18, occupations: ["unemployed", "college student"], hasVictim: true,
        summaries: [
            "On {DATE}, {D}, just past {D.his} eighteenth birthday, drove {D.his} parent's pickup at about 70 mph on a 40 mph stretch of Old Mill Road with seven friends in the truck. {D.His} blood alcohol was 0.24 three hours after the crash, and {D.he} had Valium in {D.his} system. Earlier that evening {DL} had been recorded on camera walking out of a grocery store with two cases of beer without paying. The truck plowed into a group on the shoulder: {V}, whose car had stalled; {VIC2} and {VIC4}, who had stopped to help; and {VIC3}, who lived next to the road. All four died. Two of {DL}'s passengers were thrown from the truck; one will never walk again. {DL}'s family has hired a psychologist who says {DL} never learned consequences because {D.his} parents never imposed any."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Blood Test", "BAC 0.24 drawn three hours after the crash under a search warrant, plus diazepam.", .search),
            E(.forensic, 3, "Crash Reconstruction", "The pickup's event data recorder: 70 mph five seconds before impact, no braking until 0.5 seconds before."),
            E(.video, 2, "Grocery Store Camera", "{DL} and two friends carrying two cases of beer past the registers and out the door."),
            E(.statement, 2, "Passenger Statement", "A passenger heard {DL} say \"watch this\" as {D.he} sped up toward the curve.")
        ],
        defenseEvidence: [
            E(.document, 2, "Psychologist's Report", "Describes a home with no rules, alcohol supplied by a parent from age 13, and no consequences ever imposed."),
            E(.document, 1, "Road Lighting", "The stalled car had no hazard lights on and the stretch has no streetlights."),
            E(.statement, 1, "Remorse Letters", "Letters {DL} wrote to each victim's family from jail.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Highway Patrol crash reconstructionist",
                        direct: ["\"Seventy in a forty, no braking.\""],
                        cross: ["\"The stalled car had no hazards on.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How fast was the pickup going?", "\"Seventy miles per hour five seconds before impact. The posted limit is forty. The brakes were applied half a second before impact. Nothing before that.\""),
                            .direct("Could a sober driver at the limit have stopped?", "\"Yes. The people on the shoulder were visible in headlights from about 350 feet. At forty a sober driver stops in about 200.\""),
                            .cross("The stalled car's hazard lights weren't on?", "\"Correct. There were three people with phone flashlights standing beside it, though.\""),
                            .cross("There are no streetlights on that stretch?", "\"Not a single one for two miles.\"")
                        ]),
            WitnessSeed(name: nil, role: "Passenger in the truck",
                        direct: ["\"{DL} said 'watch this.'\""],
                        cross: ["\"We were all drinking.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {DL} say before the crash?", "\"{D.He} said 'watch this' and floored it. We were going into the curve and I said slow down. Then everybody was screaming.\""),
                            .direct("How much had {DL} had to drink?", "\"A lot. We'd been at it since about four. {D.He} took some pills from {D.his} parent's cabinet too.\""),
                            .cross("You were drinking too?", "\"Yes. I wasn't driving.\""),
                            .cross("You took beer from the store with {DL}?", "\"Yes. I've been charged for it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Forensic psychologist",
                        direct: ["\"{DL} was raised without limits.\""],
                        cross: ["\"{DL} knew drunk driving was wrong.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find?", "\"A young person raised with money and no limits. A parent bought {D.him} alcohol at thirteen. When {D.he} was caught driving at fifteen, the family paid it away. {DL} never learned that actions have consequences.\""),
                            .cross("Did {DL} know that drinking and driving could kill people?", "\"Intellectually, yes.\""),
                            .cross("Is 'never told no' a mental illness?", "\"No. It's a developmental explanation, not a diagnosis.\""),
                            .cross("How much are you being paid?", "\"My fee is $450 an hour.\"")
                        ])
        ],
        prosecutionTheory: ["{D} chose to drink, steal beer, take pills, and drive seventy in the dark with a truck full of kids. Four people who stopped to help a stranger are dead."],
        defenseTheory: ["{DL} doesn't dispute driving drunk. The question is punishment: {DL} is a product of how {D.he} was raised, and {D.he} is eighteen and capable of change."],
        aggravating: ["The offense involved multiple victims", "The defendant knowingly created a great risk of death to more than one person"],
        mitigating: ["{DL} was 18 with no prior record", "The defendant has expressed remorse"],
        victimImpacts: ["{VIC3}'s spouse: \"I heard the crash from our kitchen. I watched my spouse run outside to help. I never saw them alive again.\"",
                        "{VIC4}'s child: \"My parent stopped because that's who they were. Somebody needed help, they stopped.\""],
        allocutions: ["\"I'm so sorry. I can't fix it. I know there isn't anything I can say.\""],
        guiltyTruths: ["A video from that night shows {DL} saying in the truck, \"My parents will just pay for it,\" after a friend asked if {D.he} should drive."],
        innocentTruths: ["Toxicology on the second blood draw showed the diazepam was at a level consistent with a prescription {DL} had for a sports injury, taken that morning."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["VIC2": ["Hollie Jennings", "Brianna Mitchell", "Shelby Kent"], "VIC3": ["Dana Lyles", "Marla Tisdale", "Opal Greer"], "VIC4": ["Brian Jennings", "Kevin Mosley", "Darren Cobb"]],
        story: StoryExtras(
            timeline: [(0, "6:40 p.m.: {DL} and friends take beer from a grocery store."),
                       (0, "11:45 p.m.: {V}'s car stalls on Old Mill Road."),
                       (0, "11:58 p.m.: pickup strikes four people on the shoulder."),
                       (0, "2:55 a.m.: warrant blood draw; BAC 0.24."),
                       (14, "{DL} indicted on four counts of felony death by vehicle.")],
            howIdentified: "{DL} was the driver and was found at the wheel.",
            notDone: ["No one ever tested the passengers to see whether any of them was less impaired and could have driven."],
            defendantExam: [
                .direct("What do you remember?", "\"Drinking. Getting in the truck. My friend saying slow down. Then waking up with glass in my face.\""),
                .direct("Did anyone ever stop you from drinking before?", "\"No. My parent used to buy it for us.\""),
                .cross("You said 'watch this' and sped up.", "\"I don't remember saying that. I believe them that I did.\""),
                .cross("You knew how to get away with things because you always had.", "\"I guess so. Yes.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Doctor, would prison simply teach {DL} more bad lessons?\"",
                                  answer: "\"Studies show that young offenders in adult prisons tend to reoffend more.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Beyond the scope of the witness's evaluation", shouldSustain: true,
                                  explanation: "The psychologist evaluated {DL}; general opinions about prison policy aren't based on that evaluation and aren't relevant to guilt. They may be offered at sentencing.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Four people stopped on a dark road to help a stranger. {DL} came around the curve at seventy.",
            defenseOpening: "No one disputes what happened. This case is about who {DL} was raised to be, and who {D.he} still can be.",
            prosecutionClosing: "Being spoiled is not a defense. Four families are owed accountability.",
            defenseClosing: "Punish {DL}, but punish the eighteen-year-old in front of you, not the parent who made {D.him}."
        )
    )

    // MARK: - 85. The parade (an SUV through a Christmas parade)

    static let paradeSUV = CaseTemplate(
        key: "story.paradeSUV", category: .violent,
        headlines: ["SUV Plows Through {CITY} Christmas Parade; Three Dead", "Driver Fled Domestic Fight Minutes Before Parade Crash"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 11, lesserThreshold: 9,
        specification: "With premeditation and deliberation, killed {V} by driving an SUV through the {CITY} Christmas parade.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, a member of a children's dance troupe, by driving an SUV through the parade.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC3}, a parade volunteer, by driving an SUV through the parade.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "awdwikisi", specification: "Assaulted parade spectators and marchers with a deadly weapon, an SUV, with intent to kill, injuring 41 people.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "assaultFemale", specification: "Assaulted the mother of {D.his} child in a gas station parking lot minutes before the parade.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "fleeing", specification: "Fled from a police officer who tried to stop the SUV on Main Street.", chance: 1.0, threshold: 0)
        ],
        ageRange: 36...42, occupations: ["unemployed", "aspiring rapper"], forcedPriorOffenses: ["Assault on a Female", "Assault on a Female"], hasVictim: true,
        summaries: [
            "On {DATE}, minutes after a fight with the mother of {D.his} child in a gas station lot, {D} drove a red SUV past a barricade onto Main Street during the {CITY} Christmas parade. Video from a dozen phones shows the SUV weaving through the parade route at about 30 mph for a block and a half, through a high-school band, a grandmothers' dance troupe, and a children's dance team. An officer stood in front of the SUV and pounded on the hood; the driver swerved around. Three people died, including {V}, and 41 were injured. {DL} was found at a nearby house, asking for a ride. {DL} was out on bail at the time on another assault charge involving the same woman."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Parade Videos", "Fourteen phone and body-camera videos showing the SUV's path, swerves around obstacles, and continued acceleration through crowds."),
            E(.forensic, 3, "Vehicle Data", "The SUV's computer: accelerator pressed, no braking for 31 seconds through the route, steering inputs consistent with weaving."),
            E(.video, 2, "Officer's Body Camera", "An officer in front of the SUV slapping the hood and shouting \"Stop!\" The SUV turns around the officer."),
            E(.video, 2, "Gas Station Video", "Minutes before: {DL} shoving the mother of {D.his} child against the SUV and running over her foot as {D.he} leaves.")
        ],
        defenseEvidence: [
            E(.forensic, 2, "Stuck Accelerator Theory", "A mechanic found the SUV's throttle body had a known defect subject to a recall."),
            E(.document, 1, "Mental Health History", "Records of bipolar disorder and a history of erratic behavior, untreated for a year."),
            E(.statement, 1, "Honking", "Several witnesses say the SUV was honking, which the defense says was a warning.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Police officer who stood in front of the SUV",
                        direct: ["\"I banged on the hood. The driver looked right at me and went around.\""],
                        cross: ["\"I couldn't see the driver's feet.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened when the SUV reached you?", "\"I stepped in front and pounded on the hood and yelled stop. The driver looked right at me. Eye contact. Then the wheel turned and the SUV went around me and sped up.\""),
                            .direct("Did the driver appear panicked?", "\"No. Calm. Focused.\""),
                            .cross("You couldn't see the driver's feet?", "\"From where I stood, I couldn't see below the dash.\""),
                            .cross("Could a stuck accelerator have caused the speed?", "\"It doesn't explain steering around me. Or around the band.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Bureau of Investigation vehicle analyst",
                        direct: ["\"The throttle was pressed, and the brakes never were.\""],
                        cross: ["\"There is a recall for the throttle body.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the SUV's data show?", "\"Accelerator input of 40 to 70 percent the whole time. No brake application for 31 seconds. Steering inputs that track the gaps between people.\""),
                            .direct("Did you test the recall defect?", "\"Yes. The defect causes a hesitation, not acceleration. And it doesn't explain why the brakes were never used.\""),
                            .cross("There is an open recall on this model?", "\"There is.\""),
                            .cross("You can't tell who was pressing the pedal?", "\"Only one person was in the SUV.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Parade spectator",
                        direct: ["\"It was honking. Like a warning.\""],
                        cross: ["\"It didn't stop.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear?", "\"Honking. Long blasts. I thought maybe it was part of the parade at first, then I thought somebody was trying to warn us.\""),
                            .cross("Did the SUV slow down?", "\"No. It went faster.\""),
                            .cross("Did it stop when it hit people?", "\"It kept going. That's what I can't get past.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was angry and fleeing the assault {D.he} had just committed. {D.He} chose to drive through a parade rather than stop, steering around an officer and through children for a block and a half."],
        defenseTheory: ["This was a terrible event, but not a planned murder. {DL} was in a mental health crisis, the SUV had a known defect, and the honking shows {D.he} was trying to warn people."],
        aggravating: ["The offense involved multiple victims", "The defendant knowingly created a great risk of death to more than one person", "The defendant was on pretrial release for another offense"],
        mitigating: ["The defendant suffered from a mental condition that significantly reduced culpability"],
        victimImpacts: ["{VIC2}'s mother: \"She was eight. She was in the parade in her sequins. She waved at me.\"",
                        "A grandmother in the dance troupe: \"I was beside my friend. Now I march for her.\""],
        allocutions: ["\"I'm not a monster. People keep saying that. I'm not evil. God knows my heart.\""],
        guiltyTruths: ["Jail calls recorded {DL} telling a relative, \"I told them to move. They didn't move.\""],
        innocentTruths: ["A later recall bulletin found the model's accelerator pedal could stick under the floor mat at high pressure, and the mat in the SUV was found jammed forward."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "insanity"],
        extras: ["VIC2": ["Jayla Barnes", "Kenzie Ruiz", "Ava Lindsay"], "VIC3": ["Ruth Holcomb", "Gloria Ellison", "Bev Strand"]],
        story: StoryExtras(
            timeline: [(0, "4:30 p.m.: parade begins on Main Street."),
                       (0, "4:33 p.m.: {DL} assaults the mother of {D.his} child at a gas station."),
                       (0, "4:39 p.m.: SUV passes barricade and enters the parade route."),
                       (0, "4:40 p.m.: SUV exits the route after 31 seconds."),
                       (0, "4:57 p.m.: {DL} detained at a nearby house."),
                       (3, "Charges filed.")],
            howIdentified: "A homeowner called police after {DL} knocked on {D.his} door asking for a ride; the SUV was a block away.",
            notDone: ["The floor mat was not photographed before the SUV was towed."],
            defendantExam: [
                .direct("What happened on Main Street?", "\"I was trying to get away from the fight. I didn't know there was a parade. I honked. People came out of nowhere. I couldn't stop it.\""),
                .direct("Did you try to brake?", "\"I pressed everything. It wouldn't stop.\""),
                .cross("You steered around the officer.", "\"I was trying not to hit the officer.\""),
                .cross("And then you kept going into the band.", "\"I didn't see a band.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Officer, was the driver intending to kill?\"",
                                  answer: "\"In my opinion, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation about the defendant's state of mind", shouldSustain: true,
                                  explanation: "A lay witness may describe what {D.he} saw, such as eye contact and steering, but not testify to another person's intent.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "Thirty-one seconds. A block and a half. Not one touch of the brakes.",
            defenseOpening: "A tragedy, a sick man, and a defective car. Not a plan.",
            prosecutionClosing: "Steering around people is choosing where to hit people.",
            defenseClosing: "The honking was a warning. That's not someone who wants to kill.",
            when: .months([12]),
            genders: ["D": .male]
        )
    )

    // MARK: - 86. The eye drops (poisoning a spouse's water)

    static let eyeDropPoisoning = CaseTemplate(
        key: "story.eyeDropPoisoning", category: .violent,
        headlines: ["Wife Charged With Poisoning Husband With Eye Drops", "Toxicology Finds Visine Ingredient in Man's Blood"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 11, lesserThreshold: 9,
        specification: "With premeditation and deliberation, killed {V} by poisoning {V.him} with tetrahydrozoline, the active ingredient in eye drops.",
        secondary: [
            SecondaryCharge(lawID: "forgery", specification: "Forged {V}'s signature on checks drawn on {V.his} account after {V.his} death.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "uttering", specification: "Passed forged checks drawn on {V}'s account, totaling $41,000.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "insuranceFraud", specification: "Made a false statement on a life insurance claim, stating {V}'s death was natural.", chance: 1.0, threshold: 0)
        ],
        ageRange: 34...40, occupations: ["paramedic", "pharmacy technician"], hasVictim: true,
        summaries: [
            "On {DATE}, {D} called 911 to report that {D.his} husband, {V}, had fallen down the stairs of their home in {HOOD}. Paramedics found {VL} dead at the bottom of the steps. The medical examiner first called it an accident. A routine toxicology screen, sent out because {VL} had a heart condition, came back with tetrahydrozoline at many times a therapeutic level, the decongestant in over-the-counter eye drops. Swallowed, it slows the heart and drops blood pressure. Over the next month, {DL} wrote {D.himself} $41,000 in checks from {VL}'s account and filed a life insurance claim. {DL} first told police {VL} had been depressed, then later said {D.he} had put drops in {V.his} water over three days to make {V.him} sick, not to kill {V.him}."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Toxicology", "Tetrahydrozoline at 30 times the level from proper use, and in stomach contents."),
            E(.statement, 3, "Recorded Interview", "{DL}: \"I put the drops in his water for three days. I wanted him to feel sick. I didn't think it would kill him.\"", .statement),
            E(.digital, 2, "Search History", "Searches over the prior month: \"Visine poisoning,\" \"how much tetrahydrozoline to kill a man,\" and \"can a medical examiner detect.\"", .search),
            E(.document, 2, "Bank Records", "Eleven checks totaling $41,000 written after {VL}'s death, signature not matching {VL}'s.")
        ],
        defenseEvidence: [
            E(.document, 1, "Cardiac History", "{VL} had heart disease and had been hospitalized twice for arrhythmia."),
            E(.document, 1, "Joint Account Authority", "{DL} had written checks on the account before with {VL}'s consent."),
            E(.statement, 1, "Domestic History", "A friend who says {VL} controlled the family's money tightly and belittled {DL}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic toxicologist",
                        direct: ["\"That level doesn't come from eye drops in the eyes.\""],
                        cross: ["\"The heart disease made {V.him} more vulnerable.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find?", "\"Tetrahydrozoline at about 30 times what you'd see from someone using eye drops properly. It was also in the stomach contents. It was swallowed, and in large amounts.\""),
                            .direct("What does it do when swallowed?", "\"It slows the heart sharply, drops blood pressure, and can cause unconsciousness and death. In someone with heart disease it's especially dangerous.\""),
                            .cross("{VL}'s heart disease made {V.him} more vulnerable?", "\"It did. A weaker heart doesn't handle that kind of stress.\""),
                            .cross("Could {V.he} have swallowed it {V.himself}?", "\"In theory. There's no reason anyone would swallow several bottles.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"The searches came weeks before.\""],
                        cross: ["\"{DL} said {D.he} didn't mean to kill.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("When were the searches made?", "\"Three to five weeks before the death. 'How much tetrahydrozoline to kill a man' was on the eighteenth day before.\""),
                            .direct("What did {DL} say about the checks?", "\"That {D.he} was owed it. That {VL} never let {D.him} have money.\""),
                            .cross("{DL} told you {D.he} didn't intend for {VL} to die?", "\"{D.He} said that, after first saying {VL} was suicidal.\""),
                            .cross("{DL} had a history of signing checks from that account?", "\"Some, with permission, while {VL} was alive.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend of {DL}",
                        direct: ["\"{VL} controlled every dollar.\""],
                        cross: ["\"I never saw {VL} hit {D.him}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was the marriage like?", "\"{VL} made {DL} account for every receipt. Called {D.him} stupid in front of people. {DL} cried in my car more than once.\""),
                            .cross("Did you ever see {VL} hurt {DL} physically?", "\"Never saw a hand raised. I saw plenty of yelling.\""),
                            .cross("Did {DL} ever tell you {D.he} wanted {VL} dead?", "\"{D.He} said once {D.he} wished {V.he} would just go away. People say that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} researched how much eye drop poison would kill a man, fed it to {V.him} for days, called it a fall, and started cashing {V.his} checks."],
        defenseTheory: ["{DL} did something terrible, but {D.he} meant to make {VL} sick, not kill {V.him}. {VL}'s heart disease is what made this fatal. This is at most second-degree murder."],
        aggravating: ["The defendant took advantage of a position of trust", "The offense was committed for pecuniary gain"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s sister: \"My brother was not perfect. He did not deserve to be poisoned in his own kitchen.\""],
        allocutions: ["\"I didn't want him dead. I wanted him to need me for once.\""],
        guiltyTruths: ["A note in {DL}'s phone dated a week before listed the insurance company's claims number and the amount of the policy."],
        innocentTruths: ["A pharmacist later remembered {VL} buying several bottles of eye drops {V.himself} the week before, saying they helped {V.him} sleep."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-35, "Search: \"Visine poisoning.\""),
                       (-18, "Search: \"how much tetrahydrozoline to kill a man.\""),
                       (-3, "{VL} complains of dizziness and nausea."),
                       (0, "{DL} calls 911; {VL} found dead at the bottom of the stairs."),
                       (24, "Toxicology results returned."),
                       (31, "{DL} interviewed and arrested.")],
            howIdentified: "Toxicology results and {DL}'s interview.",
            notDone: ["Eye drop bottles in the house were not fingerprinted."],
            defendantExam: [
                .direct("Why did you put drops in his water?", "\"I wanted him sick so he'd stay home and be nice to me. When he was sick he was nicer.\""),
                .direct("Why the searches?", "\"I wanted to know how much would be dangerous so I wouldn't give that much.\""),
                .cross("You searched 'how much to kill a man,' not 'how much is safe.'", "\"I was trying to find the line.\""),
                .cross("And you started writing yourself checks the week after he died.", "\"I needed money for the funeral.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Did {VL} ever talk about leaving {DL} with nothing?\"",
                                  answer: "\"{DL} told me {VL} said that.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Hearsay", shouldSustain: true,
                                  explanation: "The witness is repeating what {DL} told the witness that {VL} said, offered for its truth; it's the defendant's own out-of-court statement offered by the defendant.",
                                  doctrineID: "hearsay", weight: -1))
            ],
            prosecutionOpening: "A search for how much would kill a man. Three days of poisoned water. A fall that wasn't.",
            defenseOpening: "A cruel marriage and a desperate, stupid act, not a plan to kill.",
            prosecutionClosing: "You don't search how much it takes to kill a man to make him sick.",
            defenseClosing: "A weak heart killed {VL}. {DL}'s crime is reckless, not premeditated.",
            genders: ["D": .female, "V": .male]
        )
    )

    // MARK: - 87. The swatting call (a gamer's prank call ends in a police shooting)

    static let swattingCall = CaseTemplate(
        key: "story.swattingCall", category: .cyber,
        headlines: ["Fake Hostage Call Leads Police to Kill Innocent Man", "Online Gamer Charged in Fatal 'Swatting'"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Unlawfully caused the death of {V} by making a false emergency report that led police to surround and shoot {V.him} at {V.his} home.",
        secondary: [
            SecondaryCharge(lawID: "falseReport", specification: "Made a false report to the Hollis County 911 center that a man at {V}'s address had killed a family member and held others hostage.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "massViolenceThreat", specification: "Called in a false bomb threat to a {CITY} high school two weeks earlier, causing an evacuation.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...27, occupations: ["unemployed"], hasVictim: true,
        summaries: [
            "On {DATE}, a caller told the Hollis County 911 center that he had shot his father at an address in {HOOD}, was holding his mother and brother at gunpoint, and had poured gasoline in the house. Officers surrounded the house. {V}, 28, who lived there and had no idea, stepped onto the porch when he saw lights. Officers shouted commands; he lowered his hands toward his waist, and an officer fired once. {VL} died. There was no hostage situation. The call came from {D}, who lives in another state. Two online gamers had a dispute over a $1.50 bet; one gave {DL} an old address as a dare, and {DL}, who had made dozens of swatting calls for money, called it in. {VL} had nothing to do with either gamer."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "911 Recording", "The call: a calm voice describing a shooting, hostages, and gasoline, from a number routed through an internet calling service."),
            E(.digital, 3, "Online Messages", "Messages between {DL} and a gamer: \"give me an addy\" and, after the shooting, \"I didn't get anyone killed because I didn't discharge a weapon.\"", .search),
            E(.document, 2, "Prior Swatting Log", "Records of 46 false emergency calls traced to {DL}'s accounts, including the high school bomb threat."),
            E(.statement, 2, "Post-Arrest Interview", "{DL}: \"I do it for a few bucks. I didn't think anyone would die.\"", .statement)
        ],
        defenseEvidence: [
            E(.video, 2, "Body Camera", "The shooting officer fired from 40 yards; other officers say they never saw a weapon."),
            E(.document, 2, "Department Policy", "Policy required officers to verify a hostage report before setting a perimeter in the dark."),
            E(.document, 1, "Officer Not Charged", "The district attorney declined to charge the officer.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "911 dispatcher",
                        direct: ["\"He said he'd poured gasoline everywhere.\""],
                        cross: ["\"We didn't verify the address.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did the caller say?", "\"He said he'd shot his father in the head, had his mother and brother in a closet, and poured gasoline and was going to set it on fire. He sounded calm.\""),
                            .direct("What did you do?", "\"Dispatched everybody we had. That's a mass casualty call.\""),
                            .cross("Did anyone try to call the house first?", "\"No. The protocol didn't require it then.\""),
                            .cross("Was the caller's number a local one?", "\"No. It came through an internet service.\"")
                        ]),
            WitnessSeed(name: nil, role: "FBI cyber agent",
                        direct: ["\"{DL} made 46 of these calls.\""],
                        cross: ["\"{DL} didn't pick the address.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you identify {DL}?", "\"The calling service account traced to an email {DL} used for gaming and for a forum where {D.he} advertised swatting for hire.\""),
                            .direct("What did {DL} write after the shooting?", "\"'I didn't get anyone killed because I didn't discharge a weapon and I'm not a cop.'\""),
                            .cross("Another gamer gave {DL} the address?", "\"Yes, as a dare. It was an old address; that gamer hadn't lived there in years.\""),
                            .cross("{DL} never met {VL}?", "\"Never met, never spoke. Not one call between them.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former police tactical commander",
                        direct: ["\"The police made the fatal decision.\""],
                        cross: ["\"The police only came because of the call.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Was the shooting consistent with good practice?", "\"No. A single officer fired from 40 yards at a man on his own porch while others saw no weapon. That's an independent, unreasonable decision.\""),
                            .cross("Would the officers have been at that house without the call?", "\"They had no reason to be there without that call.\""),
                            .cross("Is it foreseeable that a report of a man with a gun and gasoline will bring armed police?", "\"Yes. That's the point of a swatting call.\"")
                        ])
        ],
        prosecutionTheory: ["{D} made a false report designed to bring armed police to a house in the dark, expecting a violent confrontation. That's the danger swatting creates, and it killed {V}."],
        defenseTheory: ["{DL}'s call was criminal, but the death was caused by an officer's unreasonable shot. The officer's decision breaks the chain of causation for manslaughter."],
        aggravating: [],
        mitigating: ["The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s mother: \"He was coming out to see what was happening. He was a father of two. He was killed over a dollar fifty.\""],
        allocutions: ["\"I've done this so many times. I never pictured a real person. I'm sorry.\""],
        guiltyTruths: ["{DL} had posted online a week earlier, \"I want to see one go wrong for once.\""],
        innocentTruths: ["Investigators later found a second swatting call to the same address that night, minutes earlier, from a different caller."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-14, "False bomb report to a {CITY} high school."),
                       (0, "Online dispute over a $1.50 game bet."),
                       (0, "6:10 p.m.: {DL} calls 911 with false hostage report."),
                       (0, "6:18 p.m.: police surround the house; {VL} shot on the porch."),
                       (2, "Online messages identify the caller."),
                       (9, "{DL} arrested in another state and extradited.")],
            howIdentified: "The calling-service account and gaming email traced to {DL}.",
            notDone: ["The 911 center never tried to call the residence before officers arrived."],
            defendantExam: [
                .direct("Why did you make the call?", "\"Someone gave me an address and dared me. I'd done it before. Usually the cops show up, nobody's home, and it's on a livestream.\""),
                .direct("Did you want anyone hurt?", "\"God, no. I wanted everyone to go home.\""),
                .cross("You told them a man had a gun and gasoline. What did you expect the police to do?", "\"Show up.\""),
                .cross("With guns drawn.", "\"Rifles up, at a house with kids in it.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Should the officer have been charged?\"",
                                  answer: "\"In my opinion, yes.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Relevance", shouldSustain: true,
                                  explanation: "Whether someone else could also be charged doesn't decide whether {DL}'s act was a proximate cause; the witness can testify that the shot was unreasonable, but not about charging decisions.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "A man with a gun, gasoline, hostages. None of it was true. All of it was meant to bring armed police.",
            defenseOpening: "The call was wrong. The shot was worse, and the shot killed {VL}.",
            prosecutionClosing: "A swatting call works only because it brings guns. It worked.",
            defenseClosing: "An officer's unreasonable choice to fire is the cause of this death.",
            genders: ["V": .male, "D": .male],
            residence: "Lives with family in another state."
        )
    )

    // MARK: - 88. The shower (an ex-girlfriend, 27 wounds, and a camera)

    static let showerStabbing = CaseTemplate(
        key: "story.showerStabbing", category: .violent,
        headlines: ["Man Found Stabbed 27 Times, Shot in His Shower", "Deleted Photos Place Ex-Girlfriend at Scene"],
        primaryLaw: "murder1", lesserLaw: "volManslaughter", threshold: 12, lesserThreshold: 10,
        specification: "With premeditation and deliberation, killed {V} by stabbing {V.him} 27 times, cutting {V.his} throat, and shooting {V.him} in the head.",
        secondary: [
            SecondaryCharge(lawID: "larcenyFirearm", specification: "Stole a .25-caliber handgun from a relative's home a week before {V}'s death.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "stalking", specification: "Stalked {V} in the months before {V.his} death, including slashing {V.his} tires twice and reading {V.his} messages.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Called {V}'s friends and left voicemails on {V.his} phone after the killing to create the appearance {D.he} didn't know {V.he} was dead.", chance: 1.0, threshold: 0)
        ],
        ageRange: 27...30, occupations: ["photographer", "waitress"], hasVictim: true,
        summaries: [
            "On {DATE}, friends found {V}, 30, dead in the shower of {V.his} home in {HOOD}. {V.He} had been stabbed 27 times, {V.his} throat cut nearly ear to ear, and shot in the head. {V.He} had been dead five days. A damaged camera found in the washing machine held deleted photos from that afternoon: {VL} posing in the shower, then a photo of {D}, {V.his} ex-girlfriend, at 5:22 p.m., then accidental shots of a bleeding man on the bathroom floor. A bloody palm print on the hallway wall matched {DL}. {DL} first said {D.he} wasn't there, then that masked intruders killed {VL} while {D.he} hid, and now says {VL} attacked {D.him} after years of abuse and {D.he} killed {V.him} in self-defense."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Recovered Camera Photos", "Time-stamped images: {VL} in the shower at 5:29 p.m.; an accidental image of the ceiling at 5:30; a man's body being dragged at 5:32.", .search),
            E(.forensic, 3, "Palm Print", "A bloody palm print in the hallway containing both {DL}'s and {VL}'s DNA."),
            E(.forensic, 3, "Autopsy", "Twenty-seven stab wounds, including defensive wounds to {VL}'s hands; throat cut; gunshot to the head, likely after death or near death."),
            E(.document, 2, "Stolen Gun Report", "A relative of {DL}'s reported a .25-caliber pistol stolen in a burglary eight days before {VL}'s death."),
            E(.digital, 2, "Rental Car and Gas Records", "{DL} rented a car 90 miles from home, bought gas cans, and turned off {D.his} phone for the drive.", .search)
        ],
        defenseEvidence: [
            E(.digital, 2, "Messages Between Them", "Sexually degrading messages from {VL} to {DL} and a recording where {VL} insults {D.him}."),
            E(.statement, 2, "Domestic Abuse Expert", "An expert on intimate partner violence who says {DL} shows signs of a long abusive relationship."),
            E(.document, 1, "No Prior Record", "{DL} has no criminal history.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"Defensive wounds on both hands.\""],
                        cross: ["\"I can't say which wound came first with certainty.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Describe the injuries.", "\"Twenty-seven stab wounds, defensive cuts on both hands, a throat wound from one ear nearly to the other, and a gunshot to the head. The throat wound alone would have been fatal.\""),
                            .direct("Did the gunshot come first?", "\"In my opinion it came last. There was little bleeding around it, which suggests the heart had nearly stopped.\""),
                            .cross("Another examiner thinks the gunshot came first?", "\"I'm aware of that opinion. I disagree.\""),
                            .cross("You can't say who started the fight?", "\"I can say who was naked and who had the knife.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"{DL} gave three different stories.\""],
                        cross: ["\"There was no knife found.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} first say?", "\"That {D.he} hadn't seen {VL} in months. When we showed the photos, {D.he} said two masked people broke in and killed {V.him} while {D.he} hid.\""),
                            .direct("Why the rental car?", "\"Rented 90 miles from home so {D.his} own car wouldn't be seen. Phone off during the drive. Three gas cans so {D.he} wouldn't need to stop at a station near {VL}'s house.\""),
                            .cross("The knife was never found?", "\"No. Nor the gun.\""),
                            .cross("{DL} was invited to the house that day?", "\"The messages show {VL} said {D.he} could come over.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Domestic violence expert",
                        direct: ["\"{DL} fits the profile of an abused partner.\""],
                        cross: ["\"I relied on {DL}'s account.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find?", "\"A relationship where {VL} used {DL} sexually and degraded {D.him}, and {DL} kept coming back. That's a recognized pattern.\""),
                            .cross("Your conclusions come from {DL}'s own account?", "\"Mostly, and from the messages.\""),
                            .cross("Did you know {DL} lied to police twice about being there?", "\"I was told that.\""),
                            .cross("Does the profile include renting a car and bringing a gun?", "\"That's planning. It isn't part of any profile I know.\"")
                        ])
        ],
        prosecutionTheory: ["{D} couldn't let {V} go. {D.He} stole a gun, rented a car, brought gas cans so {D.he} wouldn't be seen, and killed {VL} in {V.his} shower. Then {D.he} lied, and lied again."],
        defenseTheory: ["{VL} attacked {DL} in a rage after {D.he} dropped the camera. {DL} grabbed the gun to defend {D.himself}. Everything after was panic by an abused partner."],
        aggravating: ["The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s sister: \"Twenty-seven times. And then she called his phone and left a message asking him to call her back.\""],
        allocutions: ["\"I'm sorry. I loved him. I'll regret that day for the rest of my life.\""],
        guiltyTruths: ["A friend later produced a message from {DL} weeks before: \"If I can't have him, nobody will.\""],
        innocentTruths: ["A neighbor later reported seeing two people in dark clothes leaving the house through the back yard around 6 p.m. that day."],
        moods: [.wantsConviction], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(-120, "{VL} begins dating someone else; {DL} begins slashing {VL}'s tires."),
                       (-8, "Pistol stolen from {DL}'s relative."),
                       (-1, "{DL} rents a car 90 miles from home."),
                       (0, "5:22 p.m.: photo of {DL} taken in {VL}'s bedroom."),
                       (0, "5:32 p.m.: accidental photo of body being dragged."),
                       (1, "{DL} leaves voicemail on {VL}'s phone."),
                       (5, "{VL}'s body found."),
                       (40, "{DL} arrested.")],
            howIdentified: "Recovered camera photos and the palm print.",
            notDone: ["The back door and yard were not processed for prints or footprints."],
            defendantExam: [
                .direct("What happened in the bathroom?", "\"I dropped the camera. {V.He} came out of the shower screaming. {V.He} body-slammed me. I ran to the closet where I knew {V.he} kept a gun, and it went off.\""),
                .direct("Why did you lie twice?", "\"I was ashamed and terrified.\""),
                .cross("{VL} kept a gun in the closet? Nobody ever saw one there.", "\"{V.He} did.\""),
                .cross("Your relative's .25 went missing the week before. Same caliber.", "\"That's a coincidence.\""),
                .cross("And the 27 stab wounds?", "\"I don't remember them.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, in your opinion, was {DL} lying about the intruders?\"",
                                  answer: "\"Absolutely.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Opinion on credibility", shouldSustain: true,
                                  explanation: "A witness can't vouch for or against another person's truthfulness; the detective can describe the statements and the evidence that contradicts them.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A stolen gun. A rental car. Gas cans. And a camera that kept taking pictures.",
            defenseOpening: "A toxic relationship, a dropped camera, and a terrifying moment of self-defense.",
            prosecutionClosing: "Twenty-seven wounds and a cut throat is not fear. It's rage, planned for in advance.",
            defenseClosing: "{DL}'s lies were shameful. They don't prove premeditation.",
            genders: ["D": .female, "V": .male],
            victim: VictimFacts(relationship: "A former partner of the defendant.")
        )
    )
}
