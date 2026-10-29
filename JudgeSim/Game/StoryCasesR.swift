import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchR: [CaseTemplate] = [staircaseDeath, arsenicWidow, cityStrangler, motelCarbonMonoxide, lotteryWinner]

    // MARK: - 99. The staircase (a novelist's wife at the bottom of the stairs)

    static let staircaseDeath = CaseTemplate(
        key: "story.staircaseDeath", category: .violent,
        headlines: ["Novelist's Wife Found Dead at Foot of Stairs", "Fall or Beating? Experts Clash Over Stairway Death"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 7, lesserThreshold: 5,
        specification: "With premeditation and deliberation, killed {V}, the defendant's wife, by beating her about the head in the back stairwell of their home.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Cleaned blood from the stairwell walls before calling for help, and delayed the 911 call.", chance: 1.0, threshold: 0)
        ],
        ageRange: 56...62, occupations: ["novelist and newspaper columnist"], hasVictim: true,
        summaries: [
            "At 2:40 a.m. on {DATE}, {D}, a novelist and former newspaper columnist, called 911 from his home in {HOOD} to say his wife, {V}, had fallen down the stairs and was still breathing. When paramedics arrived, {VL} was dead at the foot of a narrow back staircase, in a large amount of partly dried blood, with seven lacerations on the back of her head. {DL} was covered in blood. He said they had been drinking wine by the pool and he found her when he came inside. The medical examiner ruled it a homicide by blunt force. The defense says the injuries are consistent with a fall on steep stairs after alcohol and Valium. Investigators found that {DL} had been exchanging emails with a male escort, and that {VL}'s company was about to lay her off, which would have cost her a large life insurance policy."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Autopsy", "Seven deep lacerations to the back of the scalp, bruising on the arms consistent with defense wounds, and a fractured thyroid cartilage. No skull fracture."),
            E(.forensic, 3, "Blood Spatter Analysis", "An SBI analyst concludes some spatter on the walls was cast off from a weapon swung repeatedly, not from a fall."),
            E(.document, 2, "Life Insurance and Finances", "A $1.4 million life insurance policy and mounting debts; {VL}'s employer had scheduled layoffs."),
            E(.statement, 2, "911 Call Timing", "Blood on {VL}'s body had partly dried by the time paramedics arrived, which the State says means more time passed than {DL} claims.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Defense Pathologist", "A forensic pathologist says the injuries match repeated falls on the steep, narrow stairs, and that a beating with a weapon nearly always fractures the skull."),
            E(.forensic, 2, "Toxicology", "{VL}'s blood alcohol was 0.07, with Valium."),
            E(.document, 1, "No Weapon", "No murder weapon was ever found. A fireplace blow poke the State said was missing was later found in the garage, clean.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "SBI blood spatter analyst",
                        direct: ["\"That pattern is cast-off from a swung object.\""],
                        cross: ["\"I didn't publish my experiments.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the blood on the stairwell walls show?", "\"Linear patterns of small droplets, eight feet up the wall. That's cast-off: blood flung from an object being swung. A fall doesn't put blood there.\""),
                            .direct("And the dried blood?", "\"Blood on her neck and back had dried. That takes time, longer than the few minutes the defendant described.\""),
                            .cross("Your conclusions rest on experiments you didn't document or publish?", "\"I did tests. I didn't write up every one.\""),
                            .cross("Couldn't a person coughing up blood after a head injury create that spatter?", "\"Some of it, maybe. Not all of it.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"He'd been cleaning the walls.\""],
                        cross: ["\"There was no weapon.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you see on arrival?", "\"A wet paper towel on the floor, and wiped smears on the wall at the bottom of the stairs. Someone had been cleaning.\""),
                            .direct("What about the finances?", "\"Credit card debt in six figures, a big house, and a wife about to lose her job and her insurance.\""),
                            .cross("You never found a weapon?", "\"We looked everywhere we could think of. Nothing.\""),
                            .cross("The blow poke you testified was missing turned up in the garage?", "\"Yes. The defense found it in the garage a few weeks ago.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense forensic pathologist",
                        direct: ["\"This is a fall.\""],
                        cross: ["\"I was paid for my review.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Are the injuries consistent with a beating?", "\"No. In beating deaths with a weapon, I see skull fractures and brain injury almost every time. She had none. Scalp lacerations from striking stair edges, and then she bled for a long time.\""),
                            .cross("You've testified for defendants many times?", "\"For both sides.\""),
                            .cross("And the fractured thyroid cartilage, from strangulation?", "\"It can happen in a fall. It's not common.\"")
                        ])
        ],
        prosecutionTheory: ["{D} beat his wife in the stairwell after she learned of his secret life, and he cleaned up before calling for help. The money was the motive and the blood is the proof."],
        defenseTheory: ["{VL} fell on steep stairs after alcohol and Valium. The State's spatter science is unreliable and there's no weapon. A secret is not a motive for murder."],
        aggravating: ["The offense was committed for pecuniary gain"],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: ["{VL}'s sister: \"She was my best friend. I don't believe stairs did that.\""],
        allocutions: ["\"I loved my wife. I didn't kill her. I'll say it until the end.\""],
        guiltyTruths: ["A neighbor later came forward to say she heard a man shouting and a woman crying 'stop' from the house around 1:30 that morning."],
        innocentTruths: ["A forensic engineer later found three of {VL}'s hairs, roots attached, clutched with feathers from a barred owl, suggesting an owl attack outside before she came in and fell."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(0, "Evening: {DL} and {VL} drink wine by the pool."),
                       (0, "Around 1:30 a.m.: the last confirmed time {VL} was alive."),
                       (0, "2:40 a.m.: {DL} calls 911."),
                       (0, "2:48 a.m.: paramedics arrive; {VL} is dead."),
                       (14, "Medical examiner rules the death a homicide."),
                       (40, "{DL} indicted for first-degree murder.")],
            howIdentified: "{DL} was the only other person in the house.",
            notDone: ["The stairwell was not sealed until hours after the first officers arrived, and dozens of people walked through it.", "Hairs found in {VL}'s hand were never examined."],
            defendantExam: [
                .direct("What happened that night?", "\"We'd had wine. She went in first. I stayed out by the pool. When I came in, she was at the bottom of the stairs. There was so much blood. I tried to hold her up.\""),
                .direct("Did you clean the walls?", "\"I wiped her face and tried to stop the bleeding. I didn't clean anything to hide it.\""),
                .cross("You had a secret life your wife didn't know about.", "\"She knew more than you think.\""),
                .cross("She was alive when you found her, and you waited to call?", "\"I called the second I found her.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Isn't it true the SBI lab has been found to misrepresent blood evidence in other cases?\"",
                                  answer: "\"There was an audit, yes.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "The reliability of the lab and the analyst's methods is a proper subject of cross-examination of an expert under Rule 702.",
                                  doctrineID: "expertTestimony", weight: -1))
            ],
            prosecutionOpening: "Cast-off blood eight feet up a wall. A wiped stairwell. A marriage about to fall apart.",
            defenseOpening: "A steep staircase, a terrible accident, and an investigation that decided the answer first.",
            prosecutionClosing: "Stairs don't swing. Someone did.",
            defenseClosing: "No weapon, no fracture, no proof. A fall is still a fall.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(relationship: "Married to the defendant."),
            family: "Widowed, no children. The late spouse is the victim in this case.",
            residence: "The home in {HOOD} the defendant shared with the victim.",
            yearsAtJob: 25
        )
    )

    // MARK: - 100. The widow (arsenic in the banana pudding)

    static let arsenicWidow = CaseTemplate(
        key: "story.arsenicWidow", category: .violent,
        headlines: ["Minister Survives Arsenic Poisoning; Wife Charged", "Exhumation Finds Arsenic in Two Earlier Deaths"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 11, lesserThreshold: 9,
        specification: "With premeditation and deliberation, killed {VIC2}, the defendant's former boyfriend, by poisoning him with arsenic over several months.",
        secondary: [
            SecondaryCharge(lawID: "attemptedMurder1", specification: "Attempted to kill {V}, the defendant's husband of five months, by feeding him arsenic in food she brought to the hospital.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "awdwikisi", specification: "Assaulted {V} with a deadly weapon, arsenic, with intent to kill, inflicting serious injury.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "insuranceFraud", specification: "Collected $31,000 in life insurance on {VIC2}, knowing she had caused his death.", chance: 1.0, threshold: 0)
        ],
        ageRange: 56...60, occupations: ["grocery store head cashier"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, a Baptist minister in {HOOD}, was admitted to the hospital with nausea, numbness in his hands and feet, and failing kidneys, five months after marrying {D}. Doctors found 100 times the normal level of arsenic in his body. He nearly died, and his levels rose again while in the hospital, after {D} brought him homemade banana pudding and milkshakes. Investigators exhumed {VIC2}, {DL}'s boyfriend of twelve years, who died six years ago of what was called a heart attack. His body was full of arsenic. {DL}'s first husband and her father had also died of mysterious stomach illnesses. {DL} is charged with {VIC2}'s murder and with trying to kill {VL}."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Exhumation Toxicology", "Arsenic in {VIC2}'s hair and nails at levels showing repeated doses over the last months of his life."),
            E(.forensic, 3, "Hospital Arsenic Levels", "{VL}'s arsenic levels fell after admission, then spiked twice, on days the visitor log shows {DL} brought food."),
            E(.document, 2, "Insurance Payouts", "{DL} collected life insurance on {VIC2} and was the beneficiary of a new policy on {VL}."),
            E(.physical, 2, "Ant Poison", "A container of arsenic-based ant killer found in {DL}'s mother's shed, a product discontinued years earlier.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Environmental Exposure", "Records of an old orchard on {VL}'s church property treated with arsenic pesticides decades ago."),
            E(.statement, 1, "Character Witnesses", "Coworkers and church members describe {DL} as devoted and kind."),
            E(.document, 1, "No One Saw", "No one saw {DL} add anything to food.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Minister (surviving victim)",
                        direct: ["\"I got sicker every time she visited.\""],
                        cross: ["\"I never saw her put anything in my food.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened in the hospital?", "\"I started feeling better. Then she'd bring banana pudding or a milkshake, and that night I couldn't feel my legs again. It happened twice before the doctors stopped all outside food.\""),
                            .direct("How do you feel now?", "\"I walk with a cane. I'll never feel my feet again.\""),
                            .cross("You never saw {DL} put anything in your food?", "\"I never saw it. I was talking to the others at the table.\""),
                            .cross("You still loved her when you got sick?", "\"I did. That's the hardest part.\"")
                        ]),
            WitnessSeed(name: nil, role: "State toxicologist",
                        direct: ["\"Repeated doses, months of them.\""],
                        cross: ["\"Arsenic exists in the environment.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did {VIC2}'s hair show?", "\"Hair grows about half an inch a month. Segment by segment, arsenic rises and falls for the last six months of his life. That's someone being given it over and over.\""),
                            .direct("Could orchard soil cause this?", "\"Not at these levels, and not in two men who lived in different places years apart.\""),
                            .cross("Arsenic occurs naturally in soil and water?", "\"In trace amounts. These are not trace amounts.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Coworker",
                        direct: ["\"She took care of everybody.\""],
                        cross: ["\"She talked about the insurance.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What is {DL} like?", "\"She brought food to anybody who was sick. Cakes, casseroles, pudding. That's just who she is.\""),
                            .cross("Did {DL} ever talk about life insurance?", "\"She said once you can't be too careful, everybody needs a policy.\""),
                            .cross("Food to anybody who was sick. And the people she fed got sicker?", "\"I don't know about that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} poisoned the men closest to her for money, slowly, with food. {VIC2} died. {VL} survived only because the hospital stopped her from feeding him."],
        defenseTheory: ["No one saw {DL} poison anyone. Arsenic was in the soil, the water, the old orchard. The State took two tragedies and built a monster."],
        aggravating: ["The offense was committed for pecuniary gain", "The offense was especially heinous, atrocious, or cruel", "The offense involved multiple victims"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}: \"I married her in front of my whole church. I'd have given her anything she asked for.\"",
                        "{VIC2}'s daughter: \"He suffered for months and she held his hand the whole time.\""],
        allocutions: ["\"I never hurt anybody. God knows the truth.\""],
        guiltyTruths: ["A pharmacist later identified {DL} as the woman who asked, years earlier, which ant poisons \"still have the real arsenic in them.\""],
        innocentTruths: ["Well testing at {VL}'s parsonage later found arsenic levels forty times the federal limit, from old pesticide in the soil."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        extras: ["VIC2": ["Raymond Reid", "Dwight Moore", "Calvin Teague"]],
        story: StoryExtras(
            timeline: [(-2190, "{VIC2} dies after months of stomach illness."),
                       (-150, "{DL} marries {V}."),
                       (0, "{VL} admitted to the hospital; arsenic found."),
                       (6, "{VL}'s arsenic level spikes after {DL}'s visit."),
                       (40, "{VIC2}'s body exhumed."),
                       (75, "{DL} arrested.")],
            howIdentified: "Hospital testing, then exhumation of {DL}'s former boyfriend.",
            notDone: ["The water at {VL}'s parsonage was never tested."],
            defendantExam: [
                .direct("Did you poison anyone?", "\"No. I cooked for them because I loved them. I sat with {VIC2} every day he was sick.\""),
                .direct("The ant poison in your mother's shed?", "\"It's been there since the 1970s. Mama never threw anything away.\""),
                .cross("Every time you brought food, his arsenic went up.", "\"Then something else was making him sick.\""),
                .cross("Two men you loved, full of arsenic, and you got paid both times.", "\"I didn't kill anybody for money.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Doctor, did {DL}'s first husband and father also die of arsenic?\"",
                                  answer: "\"I wasn't asked to test them.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation and uncharged acts", shouldSustain: true,
                                  explanation: "The witness has no basis to testify about deaths the witness never examined; insinuating other poisonings without evidence is improper under Rules 404(b) and 602.",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "Banana pudding, a milkshake, and an arsenic level that spiked every time she visited.",
            defenseOpening: "A caring woman, a contaminated house, and no one who ever saw her do it.",
            prosecutionClosing: "Two men. Same poison. Same woman. Same payout.",
            defenseClosing: "Suspicion stacked on suspicion is still not proof.",
            genders: ["D": .female, "V": .male],
            victim: VictimFacts(occupation: "Baptist minister", relationship: "Married to the defendant.", harm: ["Arsenic poisoning: numbness in his hands and feet and failing kidneys. He nearly died."]),
            family: "Married. The spouse is the alleged victim in this case; a former partner of twelve years is the other."
        )
    )

    // MARK: - 101. The strangler (a series of women killed in apartments across the city)

    static let cityStrangler = CaseTemplate(
        key: "story.cityStrangler", category: .violent,
        headlines: ["Third Woman Found Strangled in Her Apartment", "Fast-Food Manager Charged in String of Killings"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 8, lesserThreshold: 6,
        specification: "With premeditation and deliberation, killed {V} by strangulation in her apartment.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2} by strangulation in her apartment.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC3} by strangulation in her apartment.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "felonyLarceny", specification: "Took {VIC3}'s purse and bank card after her death.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "cardFraud", specification: "Used {VIC3}'s bank card at three ATMs the night of her death.", chance: 1.0, threshold: 0)
        ],
        ageRange: 28...32, occupations: ["fast-food restaurant manager"], hasVictim: true,
        summaries: [
            "Over eleven months, three young women were found strangled in their apartments in {HOOD} and nearby neighborhoods: {VIC2}, {VIC3}, and finally {V}, found on {DATE}. None of the doors were forced; each victim seemed to have let her killer in. Two of the women had worked at, or been regulars at, the restaurant {D} managed. After {VIC3}'s death, someone used her bank card at three ATMs; one camera caught a man in a ballcap. A fingerprint on a bottle in {VL}'s kitchen matched {DL}. Under questioning, {DL} gave a twelve-hour confession describing each killing in detail. {DL}'s lawyers say the confession was the product of exhaustion and leading questions, and that the details came from the detectives."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Twelve-Hour Confession", "{DL}'s recorded confession, describing how {D.he} strangled each woman with a towel and what each was wearing.", .statement),
            E(.forensic, 3, "Fingerprint on Bottle", "A latent print on a bottle in {VL}'s kitchen matched to {DL}'s right thumb.", .search),
            E(.video, 2, "ATM Camera", "A man in a ballcap using {VIC3}'s card at 1:12 a.m.; the State says the build and jacket match {DL}."),
            E(.forensic, 2, "DNA", "Male DNA under {VIC2}'s fingernails consistent with {DL}; the profile is partial.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Interrogation Length", "The confession came at hour eleven of questioning, after {DL} asked twice to sleep."),
            E(.document, 2, "Restaurant Access", "{DL} knew {VL} from the restaurant and had been to her apartment for a party, which could explain the print."),
            E(.document, 1, "Partial DNA", "The fingernail profile is consistent with about one in 5,000 men.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Lead homicide detective",
                        direct: ["\"He knew what each of them was wearing.\""],
                        cross: ["\"It was a long interview.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What details did {DL} give that weren't public?", "\"What each woman was wearing. That {VIC3}'s car keys were left in the freezer. The color of the towel. None of that was ever released.\""),
                            .direct("Was {DL} offered breaks?", "\"Food, water, the bathroom. It's on the recording.\""),
                            .cross("Twelve hours, and {DL} asked twice to sleep?", "\"{D.He} asked. We kept going because {D.he} was talking.\""),
                            .cross("Did detectives mention any of those details during the questioning, before {DL} said them?", "\"I'd have to look at the recording.\"")
                        ]),
            WitnessSeed(name: nil, role: "Latent print examiner",
                        direct: ["\"That's {DL}'s thumb.\""],
                        cross: ["\"I can't date a print.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where was the bottle?", "\"In {VL}'s kitchen. It was collected from the scene and brought to the lab for processing.\""),
                            .direct("Was the print good enough to compare?", "\"Yes. It had clear ridge detail, enough for a full comparison.\""),
                            .direct("Whose print is on the bottle?", "\"{DL}'s right thumb. Fourteen points of comparison, verified by a second examiner.\""),
                            .cross("You can't tell when the print was left?", "\"No. Prints can't be dated.\""),
                            .cross("So if {DL} touched that bottle at a party in {VL}'s apartment, the print would look exactly the same?", "\"Yes. The print tells you who touched it, not when or why.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "False confession expert",
                        direct: ["\"Long interrogations produce false confessions.\""],
                        cross: ["\"I can't say this one is false.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What raises the risk of a false confession?", "\"Length, exhaustion, and contamination: when interrogators feed details, intentionally or not, and then the suspect gives them back.\""),
                            .direct("Were those conditions present here?", "\"The length and the exhaustion were. The confession came at hour eleven, after {DL} had asked twice to sleep.\""),
                            .cross("Can you say {DL}'s confession is false?", "\"No. I can say the conditions make it less reliable.\""),
                            .cross("The keys in the freezer: did detectives mention that before {DL} did?", "\"Not that I found on the recording.\"")
                        ])
        ],
        prosecutionTheory: ["{D} used trust to get through the door: women who knew {D.him} from the restaurant. A print, an ATM, DNA, and a confession with details only the killer knew."],
        defenseTheory: ["A tired man was questioned for twelve hours until he said what detectives wanted. The print has an innocent explanation, the DNA is partial, and the ATM image could be anyone."],
        aggravating: ["The offense involved multiple victims", "The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s mother: \"She opened the door because she trusted him. She trusted everybody.\"",
                        "{VIC2}'s brother: \"For a year we thought it was a stranger. It was the man who handed her lunch.\""],
        allocutions: ["\"I'm sorry. I don't know why I did it.\""],
        guiltyTruths: ["A cellmate later produced a letter in {DL}'s handwriting listing two more women's names, both unsolved strangulations in another county."],
        innocentTruths: ["A full DNA profile developed years later from {VIC3}'s apartment matched a man already in prison for a similar killing."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "voluntariness"],
        extras: ["VIC2": ["Shawna Hawkins", "Audrey Spencer", "Brandi Henderson"], "VIC3": ["Vanessa Mack", "Kimberly Long", "Tanya Bethea"]],
        story: StoryExtras(
            timeline: [(-330, "{VIC2} found strangled in her apartment."),
                       (-150, "{VIC3} found strangled; her bank card used at three ATMs."),
                       (0, "{V} found strangled."),
                       (3, "Print on a bottle matched to {DL}."),
                       (4, "Twelve-hour interview; {DL} confesses."),
                       (5, "{DL} charged with three counts of murder.")],
            howIdentified: "A fingerprint on a bottle in {VL}'s kitchen.",
            notDone: ["Other men who knew all three women were never swabbed for DNA."],
            defendantExam: [
                .direct("Why did you confess?", "\"I hadn't slept in two days. They kept saying they knew. After a while I just wanted it to stop.\""),
                .direct("How did you know the keys were in the freezer?", "\"I don't remember who said that first.\""),
                .cross("You knew what each woman was wearing.", "\"They showed me pictures.\""),
                .cross("Pictures from the crime scenes? None were shown on the recording.", "\"Then I can't tell you where those details came from.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Doctor, isn't it true that most people who confess are guilty?\"",
                                  answer: "\"Most, yes.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Argumentative; beyond the expert's opinion", shouldSustain: false,
                                  explanation: "The State may test the limits of the expert's testimony on cross; asking about base rates goes to the weight of the opinion.",
                                  doctrineID: "expertTestimony", weight: 1))
            ],
            prosecutionOpening: "Three women opened their doors to someone they knew. He told us how he killed each one.",
            defenseOpening: "Twelve hours, no sleep, and a confession built from the detectives' own words.",
            prosecutionClosing: "Keys in the freezer. Only the killer knew.",
            defenseClosing: "A confession you can't trust and science that can't say when.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(relationship: "May have known the defendant from the restaurant he managed.")
        )
    )

    // MARK: - 102. The motel (carbon monoxide in Room 225)

    static let motelCarbonMonoxide = CaseTemplate(
        key: "story.motelCarbonMonoxide", category: .violent,
        headlines: ["Boy, 11, Dies in Same Motel Room Where Couple Died Weeks Earlier", "Motel Manager Charged in Carbon Monoxide Deaths"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Unlawfully and unintentionally killed {KID}, age 11, by culpable negligence in operating a motel with a known carbon monoxide hazard.",
        secondary: [
            SecondaryCharge(lawID: "invManslaughter", specification: "Unlawfully killed {V}, a guest in Room 225, by culpable negligence.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "invManslaughter", specification: "Unlawfully killed {VIC2}, a guest in Room 225, by culpable negligence.", chance: 1.0, threshold: 0)
        ],
        ageRange: 40...55, occupations: ["motel management company president"], hasVictim: true,
        summaries: [
            "Fifty days earlier, {V} and {VIC2}, a retired couple, died in Room 225 of a motel in {HOOD}. The medical examiner's toxicology took weeks. Before the results came back, on {DATE}, {KID}, 11, died in the same room, and his mother was found unconscious with brain damage. Room 225 sat directly above a natural gas water heater for the pool, which had been converted from propane without permits. A corroded exhaust vent leaked carbon monoxide up into the room through the floor. {D}, president of the management company, had overseen the conversion. After the first deaths, the room was rented again within days. The defense says no one knew about the leak and that the medical examiner's delay is to blame."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Carbon Monoxide Testing", "Fire investigators measured carbon monoxide in Room 225 at levels that cause death within hours, venting from a corroded flue below."),
            E(.document, 3, "Unpermitted Conversion", "Contracts showing {DL}'s company converted the pool heater from propane to natural gas without permits or inspection, and reused the old vent."),
            E(.document, 2, "Rented Again", "Front-desk records showing Room 225 rented eleven times between the first deaths and the boy's death."),
            E(.statement, 2, "Maintenance Worker", "A maintenance worker told {DL} he smelled \"something like exhaust\" in the pool equipment room months earlier.")
        ],
        defenseEvidence: [
            E(.document, 2, "Medical Examiner Delay", "The toxicology on the couple took six weeks; had it been run in days, the room would have been closed."),
            E(.document, 2, "Contractor", "An outside contractor installed the vent; {DL} relied on the contractor's assurance it was to code."),
            E(.statement, 1, "Detectors Not Required", "State law at the time did not require carbon monoxide detectors in motel rooms.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Fire marshal",
                        direct: ["\"The vent was rotted through.\""],
                        cross: ["\"The contractor did the install.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find under Room 225?", "\"A gas water heater vented through an old propane flue that wasn't sized for it, corroded through in two places. Exhaust was going straight up through the floor of 225.\""),
                            .direct("What carbon monoxide levels did you measure in the room?", "\"Levels that cause death within hours. It was coming up from the corroded flue below.\""),
                            .direct("Would a permit have caught this?", "\"Any inspector would have failed it on sight.\""),
                            .cross("An outside contractor installed the vent?", "\"Yes, on {DL}'s company's instructions to reuse the old flue to save money.\""),
                            .cross("And state law didn't require carbon monoxide detectors in motel rooms then?", "\"No, it didn't. The problem here was the vent, though.\"")
                        ]),
            WitnessSeed(name: nil, role: "Maintenance worker",
                        direct: ["\"I told {D.him} I smelled exhaust.\""],
                        cross: ["\"I didn't say carbon monoxide.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What was your job at the motel?", "\"Maintenance. Rooms, plumbing, and the pool equipment room.\""),
                            .direct("What did you tell {DL}?", "\"That the pool room smelled like exhaust and gave me headaches. {D.He} said it was the chlorine.\""),
                            .direct("Did you think it was chlorine?", "\"No. I know what chlorine smells like. This smelled like a car running in a garage.\""),
                            .cross("You never said carbon monoxide?", "\"I didn't know what it was. I said exhaust.\""),
                            .cross("And when {DL} said chlorine, you let it go?", "\"Yes. {D.He} was the boss.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former county medical examiner",
                        direct: ["\"The lab was backlogged.\""],
                        cross: ["\"The room should have been checked anyway.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Why did the couple's toxicology take seven weeks?", "\"The state lab was backlogged. We sent it routine. In hindsight it should have been expedited.\""),
                            .direct("If the results had come back in days, what would have happened?", "\"We'd have known it was carbon monoxide, and that room would have been closed.\""),
                            .cross("Two healthy people dying in the same room: should someone have checked the room?", "\"Someone should have. I should have.\""),
                            .cross("Nothing about the lab backlog stopped the motel from checking that room itself?", "\"No. Nothing stopped them.\"")
                        ])
        ],
        prosecutionTheory: ["{D} cut corners on a gas conversion with no permit and a rotted vent, ignored a worker's warning, and kept renting the room where two people had just died."],
        defenseTheory: ["{DL} relied on a contractor and didn't know. The medical examiner's delay, not culpable negligence by {DL}, is why the room stayed open."],
        aggravating: ["The offense involved multiple victims", "The victim was very young"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{KID}'s father: \"He wanted to swim in the pool. That's all. He wanted to swim.\""],
        allocutions: ["\"I would give anything to go back. I didn't know. I'm so sorry.\""],
        guiltyTruths: ["An email recovered from the company's server showed {DL} writing, \"skip the permit, nobody inspects pool rooms.\""],
        innocentTruths: ["The contractor later admitted falsifying a document telling {DL} the vent had passed a county inspection."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["VIC2": ["Shirley Jenkins", "Daryl Jenkins", "Ann Pruitt"], "KID": ["Jeffrey", "Logan", "Mason"]],
        story: StoryExtras(
            timeline: [(-400, "Pool heater converted to natural gas without a permit."),
                       (-120, "Maintenance worker reports an exhaust smell."),
                       (-50, "{V} and {VIC2} found dead in Room 225."),
                       (-50, "Room 225 rented again within days."),
                       (0, "{KID} dies in Room 225; his mother is hospitalized."),
                       (2, "Fire marshal finds the corroded vent.")],
            howIdentified: "The second death in the same room, and the fire marshal's inspection.",
            notDone: ["The contractor's own records were never subpoenaed."],
            defendantExam: [
                .direct("Did you know the vent was dangerous?", "\"No. The contractor told me it was done right. I'm not a gas fitter.\""),
                .direct("Why rent the room after the couple died?", "\"Nobody told us anything about the room. We thought they died of natural causes.\""),
                .cross("You told your worker the exhaust smell was chlorine.", "\"That's honestly what I believed it was.\""),
                .cross("You chose to skip the permit.", "\"The contractor said it wasn't needed.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Doctor, if you'd expedited the test, would the boy be alive?\"",
                                  answer: "\"Probably.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Speculation", shouldSustain: false,
                                  explanation: "An expert familiar with the testing timeline can give an opinion on how long expedited results would take; whether another's failure breaks causation is for the factfinder.",
                                  doctrineID: "speculation", weight: -1))
            ],
            prosecutionOpening: "Two people died in Room 225. Then a boy did. The vent was rotted, the permit skipped, and the warning ignored.",
            defenseOpening: "A hidden leak, a contractor's assurance, and a medical examiner who took six weeks.",
            prosecutionClosing: "Skipping a permit on a gas line is gambling with other people's lives.",
            defenseClosing: "Negligence isn't a crime unless it's culpable, and {DL} didn't know.",
            when: .months([6]),
            genders: ["V": .male],
            victim: VictimFacts(relationship: "A guest at a motel the defendant's company managed.")
        )
    )

    // MARK: - 103. The lottery winner (a new best friend and a missing man)

    static let lotteryWinner = CaseTemplate(
        key: "story.lotteryWinner", category: .violent,
        headlines: ["Missing Lottery Winner Found Buried Under Concrete Slab", "Woman Who Befriended Winner Charged With Murder"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 10, lesserThreshold: 8,
        specification: "With premeditation and deliberation, killed {V}, a lottery winner, by shooting him twice in the chest.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses100k", specification: "Obtained $1.3 million from {V} by falsely claiming to manage his money as a financial advisor.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Forged {V}'s signature on documents transferring his house and accounts to her company.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "concealingDeath", specification: "Concealed {V}'s death by burying his body under a concrete slab and sending texts from his phone for months.", chance: 1.0, threshold: 0)
        ],
        ageRange: 34...40, occupations: ["self-described financial advisor"], hasVictim: true,
        summaries: [
            "{V}, a former laborer from {HOOD}, won a $17 million lottery jackpot and took a lump sum of about $11 million. Within three years most of it was gone, much of it to {D}, a self-described financial advisor who befriended him, moved his money into her company, and bought his house. {VL} disappeared. For nine months, his family received text messages from his phone saying he was traveling and wanted to be left alone. On {DATE}, after a man {DL} had tried to recruit told police, investigators found {VL}'s body under a freshly poured concrete slab behind a house {DL}'s boyfriend owned, shot twice in the chest. {DL} says {VL} was killed by drug dealers he owed money and that she only helped hide the body out of fear."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Informant Recordings", "Recordings of {DL} asking a man to confess to the killing for money, and describing where the body was.", .statement),
            E(.document, 3, "Money Trail", "$1.3 million moved from {VL}'s accounts to {DL}'s company, and deeds signed over to her."),
            E(.digital, 2, "Texts From the Victim's Phone", "Months of texts sent from {VL}'s phone, from cell towers near {DL}'s home, using her spelling quirks.", .search),
            E(.forensic, 2, "Autopsy", "Two gunshot wounds to the chest; the body had been under concrete for months.")
        ],
        defenseEvidence: [
            E(.document, 2, "Victim's Debts", "Evidence {VL} owed money to several people, including men with drug convictions."),
            E(.statement, 1, "Informant's Deal", "The man who recorded {DL} is a felon paid by police and promised leniency."),
            E(.forensic, 1, "No Gun", "The gun was never found.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Informant",
                        direct: ["\"She offered me money to say I did it.\""],
                        cross: ["\"I got paid.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did {DL} ask you to do?", "\"Take the blame. She said she'd pay me and get me a good lawyer. She told me where he was buried so my story would match.\""),
                            .direct("Were those conversations recorded?", "\"Yes. After I went to the police, I recorded her. It's her voice saying all of it.\""),
                            .cross("You've been convicted of felonies, and you were paid by police?", "\"Three felonies, and they paid me. I'm not hiding either one.\""),
                            .cross("You got leniency on your own charges?", "\"They said they'd consider it.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead investigator",
                        direct: ["\"His phone kept texting after he died.\""],
                        cross: ["\"He owed money to dangerous people.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where was {VL} found?", "\"Under a freshly poured concrete slab behind a house owned by {DL}'s boyfriend. Shot twice in the chest.\""),
                            .direct("Where did {VL}'s money go?", "\"About $1.3 million moved into {DL}'s company, and his house and accounts were signed over to her.\""),
                            .direct("Who sent the texts from {VL}'s phone?", "\"Somebody near {DL}'s house, using phrases {DL} uses in her own texts. {VL} could barely read or write.\""),
                            .cross("{VL} owed money to people with drug records?", "\"He owed a lot of people. By then {DL} had taken most of his money.\""),
                            .cross("And the gun was never found?", "\"No, it hasn't been found.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Acquaintance of the victim",
                        direct: ["\"People were after him for money.\""],
                        cross: ["\"I never saw anyone threaten him.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did you know {VL}?", "\"From around {HOOD}, from before he won. We'd see each other.\""),
                            .direct("Who was after {VL}?", "\"Everybody. Once you win, everybody's your cousin. A couple of guys said he owed them and they'd get it.\""),
                            .cross("Did you ever see anyone threaten {VL}?", "\"Not myself.\""),
                            .cross("And by the time {VL} went missing, most of his money had already gone to {DL}'s company?", "\"That's what I heard, yes. I don't know the numbers.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took {V}'s fortune, killed him when the money ran low, buried him under concrete, and pretended to be him by text. Then she tried to pay someone else to take the blame."],
        defenseTheory: ["{DL} managed {VL}'s money badly but didn't kill him. Dangerous men were owed money. She panicked and helped hide the body."],
        aggravating: ["The offense was committed for pecuniary gain", "The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s mother: \"He told me money would make everything easier. He bought me a house. Then he was gone and I got text messages.\""],
        allocutions: ["\"I didn't kill him. I was scared and I did terrible things after.\""],
        guiltyTruths: ["A handgun recovered later from a pond behind {DL}'s boyfriend's property was matched to the bullets in {VL}'s chest; it was registered to {DL}."],
        innocentTruths: ["A man arrested in another state later bragged on a jail call about \"the lottery guy\" and described the slab in detail."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-1100, "{VL} wins the lottery."),
                       (-800, "{DL} begins managing {VL}'s money."),
                       (-280, "{VL} last seen; texts from his phone begin."),
                       (-20, "{DL} asks an informant to take the blame."),
                       (0, "{VL}'s body found under a concrete slab."),
                       (3, "{DL} arrested.")],
            howIdentified: "An informant's recordings of {DL}.",
            notDone: ["The men {VL} owed money to were never interviewed."],
            defendantExam: [
                .direct("Did you kill {VL}?", "\"No. Some men came for him. I helped hide him because they said I was next.\""),
                .direct("Why the texts?", "\"So nobody would come looking and get hurt.\""),
                .cross("You had $1.3 million of his money.", "\"I was investing it.\""),
                .cross("And you offered a man money to confess.", "\"I was desperate.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"How many times have you lied to police before?\"",
                                  answer: "\"A few.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper impeachment", shouldSustain: false,
                                  explanation: "A cooperating witness's prior lies to police bear directly on credibility; cross-examination on them is permitted under Rule 608(b).",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "A fortune, a new best friend, a slab of concrete, and nine months of texts from a dead man's phone.",
            defenseOpening: "Bad money management and panic aren't murder.",
            prosecutionClosing: "She didn't just hide a body. She became him.",
            defenseClosing: "Other people wanted his money too.",
            genders: ["D": .female, "V": .male],
            victim: VictimFacts(relationship: "A client of the defendant, who managed his money.")
        )
    )
}
