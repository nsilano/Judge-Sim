import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchP: [CaseTemplate] = [parentsMansion, ponziAdvisor, neighborhoodWatch, hiredTeen, trailMurders]

    // MARK: - 89. The den (two sons and their parents' shotgun murders)

    static let parentsMansion = CaseTemplate(
        key: "story.parentsMansion", category: .family,
        headlines: ["Wealthy Couple Shot to Death in {HOOD} Home", "Sons Claim Years of Abuse in Parents' Killing"],
        primaryLaw: "murder1", lesserLaw: "volManslaughter", threshold: 8, lesserThreshold: 6,
        specification: "With premeditation and deliberation, killed {V}, the defendant's father, with a shotgun.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, the defendant's mother, with a shotgun.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "identityTheft", specification: "Used another person's stolen driver's license to buy two shotguns two days before the killings.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Disposed of the shotguns and bloody clothing and staged the scene to look like an organized-crime killing.", chance: 1.0, threshold: 0)
        ],
        ageRange: 21...22, occupations: ["college student", "tennis instructor"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, a media executive, and {V.his} wife, {VIC2}, were shot to death while watching television in the den of their {HOOD} home. {VL} was shot five times, once in the back of the head at close range; {VIC2} was shot ten times, the last while crawling. Their sons, {D} and {BRO}, called 911 that night, sobbing, saying they had come home from a movie and found them. Over the next six months the brothers spent nearly $700,000: watches, a restaurant, a Porsche, tennis coaching. Two days before the killings they had bought two shotguns in another county using a stolen driver's license. {BRO} confessed to a therapist, who told his lover, who told police. {DL} now says the brothers killed their parents out of fear, after years of sexual abuse by their father, because they believed their parents were about to kill them."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Shotgun Purchase", "A sporting goods store record of two 12-gauge shotguns bought two days before, with a stolen driver's license; the clerk identifies {DL}."),
            E(.statement, 3, "Therapist's Tape", "{BRO}'s recorded session: \"We decided to do it. It was the only way to be free.\" The court has ruled the recording not privileged because of a threat to the therapist.", .statement),
            E(.document, 2, "Spending Records", "$700,000 spent in six months: watches, cars, a restaurant, and private tennis coaching."),
            E(.forensic, 2, "Contact Wound", "The shot to {VL}'s head was fired with the muzzle against the skin after {V.he} was already wounded. {DL} went outside to reload before the final shot to {VIC2}.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Relatives' Testimony", "A cousin and an aunt describe {VL} as cruel and controlling and say {DL}'s sibling told them about abuse years earlier."),
            E(.document, 2, "Childhood Records", "Pediatric records noting unexplained injuries and a counselor's note about \"secrets\" when the brothers were children."),
            E(.statement, 1, "Mother's Pills and Drinking", "Testimony that {VIC2} drank heavily and once threatened the boys with a gun.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sporting goods store clerk",
                        direct: ["\"{DL} bought the shotguns.\""],
                        cross: ["\"The license had someone else's name.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Who bought the shotguns?", "\"That man there. {DL}. He showed a license with a different name, but I remember him because he asked twice which load would 'do the most damage.'\""),
                            .cross("The ID said a different name?", "\"Yes.\""),
                            .cross("You sell dozens of guns a week. How can you remember one face?", "\"Because of that question.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Homicide detective",
                        direct: ["\"Two shotguns, sixteen shots, and a reload.\""],
                        cross: ["\"We didn't investigate abuse claims.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Walk us through the shooting.", "\"They entered the den with two shotguns. {VL} was hit first. {VIC2} tried to get away. They ran out of shells. {DL} went to the car, reloaded, came back, and fired the last shot into {VIC2}'s face.\""),
                            .direct("What did they say that night?", "\"That they'd been at a movie. The ticket stub they gave us was for a showing they couldn't have attended.\""),
                            .cross("Did anyone investigate the abuse claims?", "\"No. We investigated the murder.\""),
                            .cross("They were young men living at home with their father?", "\"Twenty-one and eighteen.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Cousin",
                        direct: ["\"{BRO} told me when we were kids.\""],
                        cross: ["\"I never told anyone.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {BRO} tell you as a child?", "\"When we were about thirteen, he said his father was touching him and he didn't know how to make it stop. I told him to tell his mother. He said she knew.\""),
                            .cross("You never told an adult?", "\"No. I was thirteen.\""),
                            .cross("You first mentioned this after the brothers were charged?", "\"Yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} and {BRO} planned to kill their wealthy parents for the inheritance. They bought guns with a fake ID, built an alibi, reloaded to finish the job, and spent the money within months."],
        defenseTheory: ["The brothers were abused for years. They believed, honestly if unreasonably, that their parents were about to kill them. That is imperfect self-defense: voluntary manslaughter, not murder."],
        aggravating: ["The offense involved multiple victims", "The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record", "The defendant was suffering from a mental or physical condition that reduced culpability"],
        victimImpacts: ["{VIC2}'s sister: \"Whatever happened in that house, my sister was crawling away when they reloaded.\""],
        allocutions: ["\"I'm sorry. I was afraid. I know that doesn't make it right.\""],
        guiltyTruths: ["A letter {DL} wrote from jail asked a friend to testify falsely about seeing {VL} hit {D.him}."],
        innocentTruths: ["A sealed family court file later surfaced in which {VIC2} had reported {VL}'s abuse of the boys years earlier and then withdrawn it."],
        moods: [.divided], doctrines: ["imperfectSelfDefense", "burdenOfProof"],
        extras: ["BRO": ["Erik", "Kyle", "Grant"], "VIC2": ["Kitty", "Joanne", "Mary Louise"]],
        story: StoryExtras(
            timeline: [(-2, "Two shotguns bought with a stolen license."),
                       (0, "Around 10 p.m.: parents shot in the den."),
                       (0, "11:47 p.m.: {DL} and {BRO} call 911."),
                       (30, "Spending begins: Rolex watches, a Porsche."),
                       (150, "{BRO} confides in a therapist."),
                       (210, "Brothers arrested.")],
            howIdentified: "The therapist's recording, after the therapist's lover went to police.",
            notDone: ["No one interviewed the family's former housekeeper about the home."],
            defendantExam: [
                .direct("Why did you do it?", "\"Because I was terrified. That week my brother told our mother about the abuse. My father said if we told anyone he'd kill us. I believed him.\""),
                .direct("Why buy guns with a fake ID?", "\"Because we didn't want to be traced if we had to use them to protect ourselves.\""),
                .cross("Your parents were watching TV. Your father had nothing in his hands.", "\"I thought they were coming for us.\""),
                .cross("You walked to your car, reloaded, and came back.", "\"I don't remember that clearly.\""),
                .cross("And you bought a Rolex a few days later.", "\"I know how that looks.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Was the father a monster?\"",
                                  answer: "\"Yes.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Improper character evidence and opinion", shouldSustain: true,
                                  explanation: "The witness can describe specific facts the witness knows, including what {BRO} said, if relevant to the brothers' fear; a bare characterization isn't helpful.",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "Shotguns bought with a stolen license. A movie alibi. A reload. Then a Rolex.",
            defenseOpening: "Behind the money was a house of horror. Two boys believed they were going to die.",
            prosecutionClosing: "Fear doesn't reload. Fear doesn't go shopping.",
            defenseClosing: "Honest fear, even if unreasonable, makes this manslaughter.",
            genders: ["D": .male, "V": .male]
        )
    )

    // MARK: - 90. The advisor (a Ponzi scheme in a small county)

    static let ponziAdvisor = CaseTemplate(
        key: "story.ponziAdvisor", category: .whiteCollar,
        headlines: ["Trusted {CITY} Advisor's 'Guaranteed' Fund Was a Ponzi Scheme", "Retirees Lose $14 Million"],
        primaryLaw: "falsePretenses100k", lesserLaw: "falsePretenses", threshold: 10, lesserThreshold: 8,
        specification: "Obtained $480,000 from {V} by falsely representing it would be invested in a guaranteed fund paying 9 percent.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses100k", specification: "Obtained $310,000 from {VIC2}, a widowed retired nurse, through the same false representations.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "falsePretenses100k", specification: "Obtained $1.2 million from the Hollis Volunteer Fire Department pension board through the same false representations.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "securitiesFraud", specification: "Sold unregistered securities through fraudulent statements about returns, in violation of the North Carolina Securities Act.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "exploitationElder", specification: "Exploited {V}, age 81, by persuading {V.him} to cash out {V.his} entire retirement into the fund.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Forged quarterly account statements showing fictional gains.", chance: 1.0, threshold: 0)
        ],
        ageRange: 58...66, occupations: ["financial advisor"], hasVictim: true,
        summaries: [
            "For eleven years, {D}, a deacon and one of {CITY}'s best-known financial advisors, sold a private \"Guaranteed Income Fund\" paying 9 percent a year, every year. More than 200 people invested $14 million: retirees, church members, the volunteer fire department pension board. There was never a fund. Statements were made on {DL}'s office printer. Old investors were paid with new investors' money, and about $4 million went to {DL}'s lake house, private school tuition, and a failing car dealership. The scheme collapsed on {DATE} when the fire department board asked to withdraw its money and there was nothing to give. {V}, 81, lost everything {V.he} had. {DL} says {D.he} always intended to make it right and was a victim of the market."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Analysis", "A forensic accountant's tracing: deposits from 214 investors, payments to earlier investors, $4.1 million to {DL}'s personal expenses, no securities ever purchased."),
            E(.document, 3, "Fake Statements", "Quarterly statements created in {DL}'s office using templates found on {D.his} computer, showing smooth gains every quarter for eleven years.", .search),
            E(.statement, 2, "Assistant's Testimony", "{DL}'s office assistant was told to print statements with numbers {DL} provided on a sticky note."),
            E(.document, 2, "Securities Registration", "The Secretary of State has no record of the fund being registered; {DL}'s license was for insurance only.")
        ],
        defenseEvidence: [
            E(.document, 2, "Early Investments", "In the first two years {DL} did trade some securities and lost money in a market drop."),
            E(.document, 1, "Repayments", "{DL} paid back $2.3 million to investors who withdrew over the years."),
            E(.statement, 1, "Character Letters", "Letters from church members about {DL}'s generosity.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic accountant",
                        direct: ["\"There was never any fund.\""],
                        cross: ["\"There were some trades in the first year.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the money go?", "\"Into one checking account. From there, to earlier investors as 'returns,' to {DL}'s lake house, credit cards, tuition, and the dealership. After year two, not one dollar was invested in anything.\""),
                            .direct("Could the 9 percent have been real?", "\"Nothing pays 9 percent every single quarter for eleven years. Not even the best fund in the world.\""),
                            .cross("{DL} made actual trades in the first year?", "\"Yes, and lost 30 percent. Then the statements started showing gains.\""),
                            .cross("{DL} repaid some investors?", "\"With other investors' money.\"")
                        ]),
            WitnessSeed(name: nil, role: "Investor (retired nurse)",
                        direct: ["\"{DL} said it was safer than a bank.\""],
                        cross: ["\"I didn't read the paperwork closely.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That it was guaranteed. Safer than a bank. That {D.he} had {D.his} own mother's money in it.\""),
                            .direct("What did you lose?", "\"$310,000. My husband's life insurance and our savings. I went back to work at seventy-two.\""),
                            .cross("You signed papers saying investments carry risk?", "\"{DL} said that was boilerplate.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pastor",
                        direct: ["\"{DL} gave to everyone.\""],
                        cross: ["\"I invested too.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What kind of person is {DL}?", "\"Generous. {D.He} paid for the church roof. Helped families with funerals.\""),
                            .cross("Did the church invest in the fund?", "\"Yes. $200,000 of the building fund.\""),
                            .cross("Was the roof paid for with investors' money?", "\"I don't know. I suppose it was.\"")
                        ])
        ],
        prosecutionTheory: ["{D} ran a textbook Ponzi scheme: a fake fund, fake statements, guaranteed returns, and a lifestyle paid for with neighbors' retirements."],
        defenseTheory: ["{DL} started out legitimately, lost money, and dug a hole trying to make investors whole. {D.He} intended to repay everyone. That's poor judgment, not intent to defraud."],
        aggravating: ["The offense involved multiple victims", "The defendant took advantage of a position of trust", "The offense involved an actual loss of more than $100,000"],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: ["{VL}: \"I was going to leave something for my grandchildren. Now my grandchildren are paying my light bill.\"",
                        "A retired firefighter: \"Thirty years of running into burning buildings and the pension's gone.\""],
        allocutions: ["\"I always meant to pay it back. I thought the next year would be better. I'm so sorry.\""],
        guiltyTruths: ["A file on {DL}'s laptop titled \"exit\" listed offshore banks and countries without extradition treaties."],
        innocentTruths: ["Records later showed {DL}'s business partner, not {DL}, controlled the account from year three and created the statements."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["VIC2": ["Edna Pruitt", "Gail Shuford", "Lorraine Bost"]],
        story: StoryExtras(
            timeline: [(-4015, "Fund launched."),
                       (-3650, "{DL} loses 30 percent in trading; statements begin showing gains."),
                       (-400, "{V} cashes out retirement and invests $480,000."),
                       (0, "Fire department board requests withdrawal; no funds."),
                       (14, "{DL} confesses to {D.his} pastor."),
                       (60, "Indictment.")],
            howIdentified: "The fire department board's complaint to the Secretary of State.",
            notDone: ["The business partner was never charged."],
            defendantExam: [
                .direct("Did you set out to steal?", "\"No. I lost money in the first year and couldn't face telling anyone. I kept thinking I'd make it back.\""),
                .direct("Why the statements?", "\"So people wouldn't panic and pull out all at once.\""),
                .cross("So people wouldn't find out.", "\"Yes.\""),
                .cross("You took $4 million for yourself while you were 'making it back.'", "\"I paid my salary.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Pastor, has {DL} been a good person all {D.his} life?\"",
                                  answer: "\"Yes, absolutely.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Improper character evidence", shouldSustain: false,
                                  explanation: "A defendant may offer evidence of a pertinent character trait, such as honesty, through reputation or opinion; general goodness is borderline but commonly allowed in a bench trial with limited weight.",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "Nine percent, every quarter, for eleven years. It never existed.",
            defenseOpening: "A man in over his head who never stopped trying to make his clients whole.",
            prosecutionClosing: "Every fake statement was a new lie to keep the money flowing.",
            defenseClosing: "Intent to repay is not intent to defraud.",
            genders: ["D": .male]
        )
    )

    // MARK: - 91. The neighborhood watch (an armed volunteer and an unarmed teen)

    static let neighborhoodWatch = CaseTemplate(
        key: "story.neighborhoodWatch", category: .violent,
        headlines: ["Unarmed Teen Shot by Neighborhood Watch Captain", "Shooter Says Teen Attacked Him"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 3, lesserThreshold: 1,
        specification: "Unlawfully and with malice killed {V}, age 17, by shooting {V.him} in the chest.",
        secondary: [
            SecondaryCharge(lawID: "concealedWeapon", specification: "Carried a concealed handgun with a concealed carry permit that had expired three weeks earlier.", chance: 1.0, threshold: 0)
        ],
        ageRange: 27...30, occupations: ["insurance underwriter"], hasVictim: true,
        summaries: [
            "On {DATE}, {D}, the volunteer captain of the neighborhood watch in a gated townhouse community in {HOOD}, called police to report \"a real suspicious guy\" walking in the rain. It was {V}, 17, walking back from a convenience store with candy and a drink to the home of {V.his} father's fiancée. The dispatcher told {DL} \"we don't need you to do that\" when {D.he} said {D.he} was following. Minutes later, {DL} and {VL} were in a fight on the grass behind the townhouses. Neighbors heard screams for help, then one shot. {VL} was dead. {DL} had a bloody nose and cuts on the back of {D.his} head. {D.He} says {VL} jumped {D.him}, was banging {D.his} head on the sidewalk, and reached for {D.his} gun."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Non-Emergency Call", "{DL}: \"These guys always get away.\" Dispatcher: \"Are you following him?\" {DL}: \"Yeah.\" Dispatcher: \"OK, we don't need you to do that.\""),
            E(.statement, 2, "Phone Call with Friend", "A friend on the phone with {VL} says {V.he} said a man was following {V.him} and {V.he} was scared."),
            E(.forensic, 2, "No DNA on Gun", "{VL}'s DNA was not found on the gun or holster."),
            E(.document, 1, "Expired Permit", "{DL}'s concealed carry permit had expired 21 days earlier.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Injuries", "Photos of {DL}'s broken nose and two lacerations on the back of {D.his} head."),
            E(.forensic, 2, "Gunshot Distance", "The shot was fired with the muzzle against {VL}'s clothing but 2–4 inches from the skin, consistent with {VL} leaning over {DL}."),
            E(.statement, 2, "Eyewitness", "A neighbor saw a person on top, wearing dark clothes, throwing punches \"MMA style.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s friend (on the phone)",
                        direct: ["\"{V.He} said a man was following {V.him}.\""],
                        cross: ["\"I couldn't see anything.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {VL} tell you?", "\"That a creepy man was watching {V.him} from a car, then following {V.him}. I told {V.him} to run. Then I heard {V.him} say, 'Why are you following me?' and a man say, 'What are you doing around here?' Then the phone went dead.\""),
                            .cross("You couldn't see who threw the first punch?", "\"No.\""),
                            .cross("{VL} said {V.he} wasn't going to run anymore?", "\"{V.He} said {V.he} was almost home.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead investigator",
                        direct: ["\"{DL} got out of {D.his} truck to follow on foot.\""],
                        cross: ["\"{DL}'s injuries were real.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Did {DL} stay in {D.his} truck as instructed?", "\"No. {D.He} got out and followed on foot. {D.He} said {D.he} was looking for a street sign. It's a community with three streets that {D.he} patrolled every night.\""),
                            .direct("Did {DL}'s account change?", "\"In details. Where {VL} came from, what {VL} said, whether {D.he} was following or returning to the truck.\""),
                            .cross("{DL}'s injuries were real?", "\"Yes. Broken nose. Lacerations on the scalp.\""),
                            .cross("{DL} cooperated and gave five statements?", "\"Yes, without a lawyer.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor (eyewitness)",
                        direct: ["\"The one on top was beating the one on the bottom.\""],
                        cross: ["\"It was dark and raining.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Two people on the grass. The one on top, in dark clothes, was throwing punches down. The one on the bottom was yelling help.\""),
                            .cross("It was dark and raining?", "\"Yes.\""),
                            .cross("You couldn't see faces?", "\"No. Just the clothes.\""),
                            .cross("Whose voice was yelling for help?", "\"I don't know.\"")
                        ])
        ],
        prosecutionTheory: ["{D} profiled a teenager walking home, followed {V.him} against a dispatcher's advice, and started a confrontation with a gun. A person who provokes the fight can't claim self-defense."],
        defenseTheory: ["{DL} lost sight of {VL}, was walking back to {D.his} truck, and was attacked. With {D.his} head being slammed on concrete, {D.he} reasonably feared death or great bodily harm."],
        aggravating: ["The defendant was armed with a deadly weapon"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{VL}'s father: \"He was walking home with candy. He was seventeen. He had every right to be there.\""],
        allocutions: ["\"I'm sorry for the loss of your son. I didn't know how old he was. I thought he had a gun.\""],
        guiltyTruths: ["A neighbor later came forward to say {DL} had told the neighbor weeks earlier, \"Next time one of them comes through here, I'm not waiting for the cops.\""],
        innocentTruths: ["A second neighbor's doorbell camera, found later, showed {VL} doubling back toward {DL} after {DL} had turned toward {D.his} truck."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense"],
        story: StoryExtras(
            timeline: [(0, "6:54 p.m.: {VL} leaves convenience store."),
                       (0, "7:09 p.m.: {DL} calls non-emergency line; told not to follow."),
                       (0, "7:13 p.m.: {VL}'s phone call drops."),
                       (0, "7:16 p.m.: neighbors call 911; single gunshot heard on a call."),
                       (0, "7:17 p.m.: police arrive; {VL} dead."),
                       (45, "{DL} charged after special prosecutor review.")],
            howIdentified: "{DL} was at the scene and admitted the shooting.",
            notDone: ["The scream on the 911 call was never analyzed by a qualified voice expert."],
            defendantExam: [
                .direct("Why did you follow {VL}?", "\"There had been break-ins. I didn't recognize {V.him}. I wanted to keep {V.him} in sight for the police.\""),
                .direct("Who started the fight?", "\"I was walking back to my truck. {V.He} came from the dark and said, 'You got a problem?' and punched me. I fell. {V.He} got on top of me and slammed my head on the sidewalk.\""),
                .cross("The dispatcher told you not to follow.", "\"They said 'we don't need you to.' I said OK.\""),
                .cross("Your permit was expired, but you still brought the gun.", "\"I didn't know it had expired.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, did {DL} profile {VL}?\"",
                                  answer: "\"I believe {D.he} did.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation about the defendant's state of mind", shouldSustain: true,
                                  explanation: "The detective can't testify to what was in {DL}'s mind; the State can argue profiling from the call and the evidence.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "\"We don't need you to do that.\" If {DL} had listened, {VL} would be alive.",
            defenseOpening: "A broken nose, a head on concrete, and a split-second decision.",
            prosecutionClosing: "{DL} created the danger. You can't start the fight and then claim you were afraid of it.",
            defenseClosing: "Whoever started it, a person being beaten on concrete may defend his life.",
            genders: ["D": .male, "V": .male]
        )
    )

    // MARK: - 92. The teacher (a spouse's murder by a teenage lover)

    static let hiredTeen = CaseTemplate(
        key: "story.hiredTeen", category: .violent,
        headlines: ["Teen Confesses to Killing Teacher's Husband, Says She Asked Him To", "School Media Coordinator Charged in Husband's Murder"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 10, lesserThreshold: 8,
        specification: "With premeditation and deliberation, procured and counseled a student to kill {V}, the defendant's husband, who was shot in their condominium.",
        secondary: [
            SecondaryCharge(lawID: "witnessIntimidation", specification: "Urged a teenage witness to lie to police and to stop talking to investigators.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Told police the killing was a burglary and left the condominium unlocked to stage it.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "insuranceFraud", specification: "Filed a claim on {V}'s $140,000 life insurance policy, representing that {V.he} was killed by a burglar.", chance: 1.0, threshold: 0)
        ],
        ageRange: 22...24, occupations: ["school media coordinator"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 24, an insurance salesman, was shot once in the head in the condominium he shared with his wife, {D}, in {HOOD}. {DL}, the high school's media coordinator, came home from a school board meeting and called 911, screaming that the place had been robbed. Three months later, {TEEN}, a 15-year-old student, and two friends confessed: {TEEN} was having a sexual relationship with {DL}, and {DL} told him that unless {V} was gone they couldn't be together and that a divorce would cost her everything. She told him to make it look like a burglary and to keep the dog in the basement so it wouldn't be traumatized. A fourth student, cooperating with police, wore a wire and recorded {DL} telling her to lie. {TEEN} has pleaded guilty and will testify."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Wiretap Recordings", "{DL} to the cooperating student: \"If you tell the truth, you're going to have to live with that, and so am I... you could be an accessory.\"", .statement),
            E(.statement, 3, "{TEEN}'s Testimony", "{TEEN} says {DL} planned the killing, provided the timing, and told him to leave the door unlocked and put the dog in the basement."),
            E(.document, 2, "Life Insurance", "A $140,000 life insurance policy on {VL} with {DL} as beneficiary."),
            E(.forensic, 2, "Dog in the Basement", "Police found the dog shut in the basement; a real burglar wouldn't know where to put it.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Cooperation Deal", "{TEEN} pleaded to second-degree murder for a sentence with release in his thirties in exchange for testimony."),
            E(.document, 1, "No Physical Evidence", "No physical evidence ties {DL} to the shooting; she was at a board meeting."),
            E(.statement, 1, "Wiretap Context", "{DL} says she was playing along on the recordings to learn what the students had done.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{TEEN}", role: "Student (cooperating co-defendant)",
                        direct: ["\"She said it was the only way.\""],
                        cross: ["\"I got a deal.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("Whose idea was it to kill {VL}?", "\"Hers. She said if he was gone we could be together and she'd lose the condo and the dog in a divorce. She said it a lot of times until I said I'd do it.\""),
                            .direct("What did she tell you about that night?", "\"That she'd be at a board meeting. Leave the door unlocked. Put the dog in the basement so he wouldn't see it. Make it look like a robbery.\""),
                            .cross("You're getting out of prison in your thirties for this testimony?", "\"That's the deal.\""),
                            .cross("You pulled the trigger?", "\"Yes.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"She told the student to lie.\""],
                        cross: ["\"No physical evidence ties her to the shooting.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the recordings show?", "\"{DL} telling a student to lie to us, and saying if one person talked, they would all go to prison for the rest of their lives, including her.\""),
                            .direct("Why does 'including her' matter?", "\"Because she'd have no reason to go to prison if she wasn't involved.\""),
                            .cross("There's no physical evidence tying {DL} to the shooting?", "\"She wasn't there. That was the plan.\""),
                            .cross("She was at a public meeting with thirty witnesses?", "\"Yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Coworker",
                        direct: ["\"She was devastated after.\""],
                        cross: ["\"She went back to work three days later.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did {DL} act after {VL}'s death?", "\"Crying. Couldn't eat. She seemed devastated.\""),
                            .cross("She gave press interviews and talked about makeup and her hair?", "\"She did a couple of interviews.\""),
                            .cross("She went back to work three days later?", "\"Yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} seduced a fifteen-year-old and talked him into killing her husband so she could keep the condo, the dog, and the insurance without a divorce."],
        defenseTheory: ["{DL} had an inappropriate relationship with a student, but a jealous teenager decided to kill {VL} on his own. Now he's blaming the adult to cut his sentence."],
        aggravating: ["The defendant took advantage of a position of trust", "The defendant induced others to participate in the commission of the offense", "The offense was committed for pecuniary gain"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s mother: \"She used a child to murder my son. Two families are destroyed and she smiled at the cameras.\""],
        allocutions: ["\"I didn't ask anyone to kill my husband. I made terrible mistakes but I am not a murderer.\""],
        guiltyTruths: ["A letter later surfaced in which {DL} wrote to {TEEN}, before the killing, \"Remember, once it's done, nobody can ever know.\""],
        innocentTruths: ["{TEEN} later recanted to a journalist, saying a friend suggested blaming {DL} to get a deal."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["TEEN": ["Billy Flynn", "Cody Weller", "Pete Randall"]],
        story: StoryExtras(
            timeline: [(-120, "{DL} begins relationship with {TEEN}."),
                       (-30, "{DL} and {TEEN} discuss killing {VL}."),
                       (0, "{DL} attends a school board meeting."),
                       (0, "8:30 p.m.: {VL} shot in the condominium."),
                       (0, "10:00 p.m.: {DL} calls 911."),
                       (75, "Cooperating student begins recording {DL}."),
                       (90, "{TEEN} and friends arrested; {DL} arrested.")],
            howIdentified: "Students talked; one cooperated and wore a wire.",
            notDone: ["The other teenagers' phones were not examined for messages from {DL}."],
            defendantExam: [
                .direct("Did you ask {TEEN} to kill your husband?", "\"Never. I had an affair with a student and that was wrong. I never asked him to hurt anyone.\""),
                .direct("Then why did you say on the recording that you'd go to prison too?", "\"I was trying to get the student to tell me what they knew. I was scared.\""),
                .cross("You told her to lie to the police.", "\"I told her to be careful.\""),
                .cross("The dog was in the basement. Who knew where to put the dog?", "\"{TEEN} had been to the condo.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Isn't it true you've been in juvenile court before for theft?\"",
                                  answer: "\"Once, when I was thirteen.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper impeachment with a juvenile adjudication", shouldSustain: true,
                                  explanation: "Under Rule 609(d), juvenile adjudications generally are not admissible to impeach a witness's credibility.",
                                  doctrineID: "priorActs", weight: -1))
            ],
            prosecutionOpening: "A teacher, a fifteen-year-old, and a plan to make it look like a burglary.",
            defenseOpening: "A shameful affair, and a teenager who killed and now needs someone to blame.",
            prosecutionClosing: "Who put the dog in the basement? Who said 'including me'?",
            defenseClosing: "Every piece of the State's case comes from a killer who earned a deal.",
            genders: ["D": .female, "V": .male]
        )
    )

    // MARK: - 93. The trail (two girls, a bridge, and a video)

    static let trailMurders = CaseTemplate(
        key: "story.trailMurders", category: .violent,
        headlines: ["Two Girls Found Dead Near Creek Trail in {HOOD}", "Five Years Later, Local Man Charged in Trail Murders"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 7, lesserThreshold: 5,
        specification: "With premeditation and deliberation, killed {V}, age 13, near the old railroad bridge on the Creek Trail.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, age 14, near the old railroad bridge on the Creek Trail.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "kidnapping1", specification: "Unlawfully removed {V} from the bridge at gunpoint for the purpose of committing a felony, and the victim was not released in a safe place.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "kidnapping1", specification: "Unlawfully removed {VIC2} from the bridge at gunpoint for the purpose of committing a felony, and the victim was not released in a safe place.", chance: 1.0, threshold: 0)
        ],
        ageRange: 48...52, occupations: ["pharmacy technician"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 13, and {VIC2}, 14, were dropped off at the Creek Trail in {HOOD} on a school holiday. They walked to the old railroad bridge. {VL} recorded 43 seconds on {V.his} phone: a man in a blue jacket and jeans walking toward them on the bridge, and a man's voice saying, \"Guys... down the hill.\" Their bodies were found the next day in the woods across the creek, throats cut. The case went unsolved for five years. Then a records clerk found a tip from the first week: {D}, a local pharmacy technician, had told an officer {D.he} was on the trail that afternoon wearing a blue jacket. An unspent .40-caliber round found between the girls' bodies was matched to a pistol in {DL}'s home. In jail, {DL} confessed more than 60 times to guards, a psychologist, and {D.his} spouse on the phone. {DL} says the confessions came from a breakdown in solitary confinement and that the killings were done by others."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Bridge Video", "43 seconds from {VL}'s phone: a man in a blue jacket, jeans, and hat walks toward the girls; a voice says \"down the hill.\""),
            E(.forensic, 3, "Unspent Round", "A .40-caliber round found between the bodies bears extractor marks matched to {DL}'s Sig Sauer pistol.", .search),
            E(.statement, 3, "Jail Confessions", "More than 60 confessions, including a recorded call to {D.his} spouse: \"I did it. I killed those girls.\"", .statement),
            E(.statement, 2, "Original Tip", "{DL}'s statement in the first week placing {D.himself} on the trail at the time, wearing a blue jacket and jeans.")
        ],
        defenseEvidence: [
            E(.forensic, 2, "Toolmark Science", "A defense firearms expert says extractor marks on a cycled, unfired round can't reliably be matched to one gun."),
            E(.document, 2, "Solitary Confinement Records", "{DL} was held in isolation for over a year, was medicated for psychosis, ate {D.his} own papers, and smeared feces before the confessions."),
            E(.document, 2, "Alternative Suspects", "Investigators' notes about a group whose members were near the trail and whose symbols the defense says were found at the scene."),
            E(.forensic, 1, "No DNA", "No DNA from {DL} was found at the scene or on the victims.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State firearms examiner",
                        direct: ["\"That round was cycled through {DL}'s gun.\""],
                        cross: ["\"There's no statistical error rate.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you compare?", "\"The extractor and ejector marks on the unspent round from the scene with test rounds I cycled through {DL}'s pistol. The marks match.\""),
                            .direct("How certain are you?", "\"Identification. That round was cycled through that gun to the exclusion of all others.\""),
                            .cross("Is there a published error rate for unfired-cartridge comparisons?", "\"Not specifically for unfired rounds.\""),
                            .cross("You took photos of your comparison?", "\"Not of every step. I document conclusions.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead investigator",
                        direct: ["\"{DL} put {D.himself} on the bridge.\""],
                        cross: ["\"The tip sat unfiled for five years.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} tell officers the first week?", "\"That {D.he} walked the trail from 1:30 to 3:30 that afternoon, to the bridge, wearing a blue jacket and jeans. That's the window and the clothing in the video.\""),
                            .direct("What did {DL} say in jail?", "\"Over sixty admissions. To {D.his} spouse: 'I did it.' To a guard: 'I killed those girls.'\""),
                            .cross("The tip was misfiled for five years?", "\"It was mislabeled as cleared. That was a mistake.\""),
                            .cross("{DL} was in isolation, medicated, and psychotic when {D.he} confessed?", "\"{D.He} was having mental health issues. Some confessions included details only the killer would know.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Forensic psychiatrist",
                        direct: ["\"Those confessions are the product of a breakdown.\""],
                        cross: ["\"Some details were accurate.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was {DL}'s condition?", "\"Psychotic. Thirteen months in isolation. {D.He} was eating paper and smearing feces. A person in that state will say whatever stops the voices or ends the conversation.\""),
                            .cross("Did some confessions include non-public details?", "\"A few, but many details were in the media or in discovery {DL} had in {D.his} cell.\""),
                            .cross("{DL} confessed to {D.his} spouse, the person {D.he} trusted most?", "\"Yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} told police {D.he} was on that bridge, dressed as the man in the video, at that time. A round cycled through {D.his} pistol was left between the girls. And {D.he} confessed again and again."],
        defenseTheory: ["A misfiled tip, junk science on an unfired bullet, and confessions from a broken mind. The investigation ignored other suspects for five years and then built a case around the one name it found."],
        aggravating: ["The offense involved multiple victims", "The victims were very young", "The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s grandmother: \"She was brave enough to take that video. She knew. She gave us his face.\"",
                        "{VIC2}'s mother: \"They were best friends. They're buried side by side.\""],
        allocutions: ["\"I didn't kill those girls. I'll say that until I die.\""],
        guiltyTruths: ["A box cutter recovered from {DL}'s garage, overlooked in the first search, had traces of {VIC2}'s DNA in the hinge."],
        innocentTruths: ["A hair found in {VIC2}'s hand, tested years later, came from an unknown man who was not {DL}."],
        moods: [.divided], doctrines: ["burdenOfProof", "voluntariness", "expertTestimony"],
        extras: ["VIC2": ["Abby Williams", "Liberty Carr", "Hannah Rowe"]],
        story: StoryExtras(
            timeline: [(0, "1:35 p.m.: girls dropped off at the trail."),
                       (0, "2:13 p.m.: bridge video recorded."),
                       (0, "5:30 p.m.: girls reported missing."),
                       (1, "Bodies found across the creek."),
                       (7, "{DL} tells an officer {D.he} was on the trail that afternoon; tip misfiled."),
                       (1825, "Tip rediscovered; search warrant executed."),
                       (1830, "{DL} arrested.")],
            howIdentified: "A rediscovered tip, then the pistol found in a search of {DL}'s home.",
            notDone: ["The hair found in {VIC2}'s hand was never fully tested before trial.", "The alternative suspects' alibis were never checked."],
            defendantExam: [
                .direct("Were you on the trail that day?", "\"Yes. I told the police that the first week. I walked to the bridge, saw some teenagers, and left before 2. I never saw those girls.\""),
                .direct("Why did you confess?", "\"I was out of my mind. Locked alone for a year. I wanted it to end.\""),
                .cross("You told your spouse, 'I did it.'", "\"I said a lot of things.\""),
                .cross("The round from your gun was between them.", "\"I don't know how it got there. I don't believe it's from my gun.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Isn't firearms identification just your subjective opinion?\"",
                                  answer: "\"It is an opinion based on training and experience.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: false,
                                  explanation: "A cross-examiner may challenge the basis and reliability of an expert's opinion under Rule 702; the question is fair and not argumentative.",
                                  doctrineID: "expertTestimony", weight: -1))
            ],
            prosecutionOpening: "\"Down the hill.\" A girl had the courage to record her killer. He told police he was there.",
            defenseOpening: "A five-year failure, a bullet that was never fired, and a man broken in solitary.",
            prosecutionClosing: "He was there. His gun was there. And he told us.",
            defenseClosing: "Fear and grief are not proof. This case has never been solved.",
            genders: ["D": .male, "V": .female]
        )
    )
}
