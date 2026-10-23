import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchW: [CaseTemplate] = [bingoHall, feedStoreFire, boatLanding, nurseDiversion, clerkShootsBack]

    // MARK: - 124. Bingo night (a veterans' post quartermaster and the cash box)

    static let bingoHall = CaseTemplate(
        key: "story.bingoHall", category: .whiteCollar,
        headlines: ["$74,000 in Bingo Money Missing From Veterans' Post", "Post Quartermaster Charged; Members Say Hall Repairs Never Came"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "As quartermaster of {POST}, embezzled $74,000 in bingo proceeds entrusted to {D.him} for the post.",
        secondary: [
            SecondaryCharge(lawID: "forgery", specification: "Falsely made a bank deposit summary for {POST} showing deposits that were never made.", chance: 1.0, threshold: 0)
        ],
        ageRange: 58...74, occupations: ["retired postal carrier", "retired machinist", "retired Army sergeant"], hasVictim: true,
        summaries: [
            "For six years {D} was the elected quartermaster of {POST} in {HOOD}, which runs bingo every Thursday night. The quartermaster counts the cash box with one other member, signs the count sheet, and takes the money to the bank on Friday. In {DATE}'s audit, the state bingo regulators found the count sheets showed $212,000 over three years, but the post's account received $138,000. {V}, the post commander, says {DL} always insisted on making the deposits alone. {DL} says the missing money went to cash prizes and hall repairs that were never written down, and that the post's books were a mess long before {D.he} took over."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Count Sheets and Deposits", "Count sheets signed by {DL} totaling $212,000; bank deposits of $138,000 over the same 156 bingo nights.", .search),
            E(.document, 3, "Deposit Summaries", "Eleven typed deposit summaries given to the post's board, each showing a deposit the bank has no record of."),
            E(.document, 2, "Personal Account", "{DL}'s own account received $41,000 in cash deposits over the same period, always on Fridays.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Prize Payouts", "Bingo rules allow cash prizes up to $500 a game, and no prize log was kept before {DL} became quartermaster."),
            E(.statement, 1, "Roof Repair", "A member remembers {DL} paying a roofer in cash after a storm.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Post commander",
                        direct: ["\"{D.He} never let anyone ride to the bank with {D.him}.\""],
                        cross: ["\"Our books weren't perfect before {D.him} either.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Who took the money to the bank?", "\"{DL} did, every Friday. Twice I offered to go along. {D.He} said it was the quartermaster's job and nobody else's.\""),
                            .direct("What did the board see?", "\"Typed deposit summaries. They looked fine. We had no reason to call the bank.\""),
                            .cross("The post's records were in poor shape before {DL} took over?", "\"They were. That's why we elected {D.him}. {D.He} promised to fix them.\""),
                            .cross("You never saw {DL} put post money in {D.his} own pocket?", "\"No. I never saw that.\"")
                        ]),
            WitnessSeed(name: nil, role: "Auditor, state bingo program",
                        direct: ["\"Seventy-four thousand dollars never reached the bank.\""],
                        cross: ["\"I can't say where it went.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What period did you review?", "\"Three years. 156 bingo nights.\""),
                            .direct("What did the audit find?", "\"The count sheets, signed by the defendant and a second member, total $212,000. Deposits total $138,000. Prizes are paid before the count, so they can't explain the gap.\""),
                            .direct("What about the deposit summaries given to the board?", "\"Eleven typed summaries each show a deposit the bank has no record of.\""),
                            .cross("No prize log was kept before {DL} became quartermaster?", "\"Not that I found. But prizes come out before the count.\""),
                            .cross("You can't say where the cash went?", "\"No. I can say it was counted and then it wasn't deposited.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Longtime post member",
                        direct: ["\"{DL} paid the roofer in cash.\""],
                        cross: ["\"I don't know how much.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Were you at the hall after the storm?", "\"Yes. I was there when the water came through.\""),
                            .direct("What did you see after the storm?", "\"Water coming through the hall ceiling. {DL} got a roofer out there the next week and paid him in cash out of an envelope.\""),
                            .cross("How much was in that envelope?", "\"I don't know. I didn't count it.\""),
                            .cross("And you don't know whose money it was?", "\"No. I just saw {DL} hand it over.\"")
                        ])
        ],
        prosecutionTheory: ["{D} counted the money, signed for it, carried it to the bank alone, and deposited a third of it in {D.his} own account."],
        defenseTheory: ["A volunteer quartermaster with sloppy records and undocumented repairs isn't a thief. The State can't trace a single dollar from the cash box to {DL}."],
        aggravating: ["The offense involved a large monetary loss"],
        mitigating: ["The defendant has a long record of public and community service", "No prior criminal record"],
        victimImpacts: ["{V}: \"Those bingo nights paid for wheelchair ramps and funerals. Men I served with went without because of this.\""],
        allocutions: ["\"I gave that post twenty years. I never meant to hurt anybody.\""],
        guiltyTruths: ["{DL}'s home computer held a spreadsheet titled \"Thursday\" tracking the skimmed amount week by week."],
        innocentTruths: ["The second counter later admitted signing count sheets inflated to cover his own sports betting debts."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["POST": ["VFW Post 8817", "American Legion Post 54", "VFW Post 2209"]],
        story: StoryExtras(
            timeline: [(-1095, "First count sheet in the audit period."), (-60, "Board member asks for bank statements; {DL} delays."), (0, "State bingo audit completed."), (30, "Bank records subpoenaed."), (55, "{DL} charged.")],
            howIdentified: "{DL} signed every count sheet and made every deposit.",
            notDone: ["The second counter's finances were not examined."],
            defendantExam: [
                .direct("Did you take any of the post's money?", "\"No. I paid prizes and bills in cash when things came up. I should have written them down.\""),
                .cross("$41,000 in cash went into your account, always on Fridays.", "\"That was my own money. I sell firewood.\""),
                .cross("Do you have a single receipt for the firewood?", "\"Not written down, no.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"What did the other members say about {DL} once the audit came out?\"",
                                  answer: "\"They said they'd always wondered about {D.him}.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: true,
                                  explanation: "Out-of-court statements by other members offered to show {DL} was suspected are hearsay.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "One person counted the money, signed for it, and carried it to the bank. A third of it never got there.",
            defenseOpening: "Bad bookkeeping by a volunteer is not a crime.",
            prosecutionClosing: "Sloppy records lose receipts. They don't put $41,000 in your own account on Fridays.",
            defenseClosing: "Nobody can tell you where the money went. That's reasonable doubt."
        )
    )

    // MARK: - 125. The feed store (a failing business burns)

    static let feedStoreFire = CaseTemplate(
        key: "story.feedStoreFire", category: .property,
        headlines: ["Fire Destroys Century-Old Feed Store", "Owner Charged With Arson, Insurance Fraud"],
        primaryLaw: "burningBuildings", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Wantonly and willfully set fire to and burned {STORE}, a store building in {HOOD}.",
        secondary: [
            SecondaryCharge(lawID: "insuranceFraud", specification: "Presented a claim for $480,000 to an insurer knowing it contained false and misleading information about the cause of the fire.", chance: 1.0, threshold: 0)
        ],
        ageRange: 45...66, occupations: ["feed store owner"], hasVictim: false,
        summaries: [
            "{STORE} had been in {D}'s family for three generations. By {DATE} it was four months behind on its loan, and the bank had sent a foreclosure notice. At 2:15 a.m. that night a passing deputy saw flames in the back of the building. It burned to the ground. The state fire investigator found burn patterns on the floor in three separate places and traces of gasoline in two of them. Nine days later {DL} filed a $480,000 claim, having raised the policy's coverage four months earlier. {DL} says {D.he} was home asleep, that an old wiring problem started the fire, and that {D.he} raised the coverage because the bank required it."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Fire Investigator's Report", "Three separate points of origin on the floor; gasoline detected in debris samples from two of them by the State Crime Laboratory."),
            E(.document, 3, "Foreclosure Notice and Policy Change", "A bank foreclosure notice, and a policy increase from $250,000 to $480,000 four months before the fire."),
            E(.digital, 2, "Phone Location", "{DL}'s phone connected to the tower serving the store at 1:41 a.m.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Electrical Inspection", "A 2019 inspection noted aluminum wiring in the back room that \"should be replaced.\""),
            E(.document, 1, "Bank Letter", "A letter from the bank asking for coverage equal to the appraised value.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State fire investigator",
                        direct: ["\"Three origins. Fires don't start in three places on their own.\""],
                        cross: ["\"I didn't rule out wiring until I'd examined it.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you examine?", "\"The burned building, the floor of the back room, and every circuit in that room. I sent debris samples to the State Crime Laboratory.\""),
                            .direct("Where did the fire start?", "\"In three separate places on the floor of the back room, with unburned floor between them. Two had gasoline. That's an incendiary fire.\""),
                            .cross("The back room had old aluminum wiring?", "\"It did. I examined all of it. None of the circuits showed arcing at those points.\""),
                            .cross("Gasoline is sold at a feed store?", "\"Small cans of mixed fuel, yes. Not on the floor in three puddles.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "Patrol deputy",
                        direct: ["\"The back of the building was already fully involved.\""],
                        cross: ["\"I didn't see anyone leaving.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Why were you near the store?", "\"I was on patrol, passing by.\""),
                            .direct("What did you see?", "\"Orange light in the back windows at 2:15. By the time I called it in, the back half was fully involved.\""),
                            .direct("Could the building be saved?", "\"No. It burned to the ground.\""),
                            .cross("No one around the building?", "\"No one I saw, and no car in the lot.\""),
                            .cross("You can't tell us how the fire started?", "\"No. I only saw it burning.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Loan officer",
                        direct: ["\"We asked for coverage at appraised value.\""],
                        cross: ["\"We didn't ask for it to be raised that particular month.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was your role with the store?", "\"I handled the store's loan at the bank.\""),
                            .direct("Did the bank ask {DL} to raise the coverage?", "\"Yes. Our letter asked for coverage equal to the appraisal, which was $475,000.\""),
                            .cross("The letter was sent two years before the change?", "\"That's right. {DL} didn't act on it until this year.\""),
                            .cross("By the time of the fire, the loan was four months behind and the bank had sent a foreclosure notice?", "\"Yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was losing the store, raised the insurance, drove there in the middle of the night, and poured gasoline in three places."],
        defenseTheory: ["An old building with bad wiring burned. The coverage matched the bank's demand, and a phone tower covers miles, not a doorway."],
        aggravating: ["The offense endangered the responding firefighters"],
        mitigating: ["No prior criminal record", "The defendant has strong community ties"],
        allocutions: ["\"That store was my grandfather's. I'd never burn it.\""],
        guiltyTruths: ["A gas station camera two miles away showed {DL} filling two red cans at 1:20 a.m."],
        innocentTruths: ["An electrician later found a failed junction box behind the wall, hidden from the investigator by collapsed shelving."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["STORE": ["Pruitt Feed & Seed", "Coastal Farm Supply", "Bayard Feed and Hardware"]],
        story: StoryExtras(
            timeline: [(-120, "Coverage raised to $480,000."), (-30, "Foreclosure notice."), (0, "1:41 a.m.: {DL}'s phone near the store."), (0, "2:15 a.m.: deputy sees the fire."), (9, "Insurance claim filed."), (60, "Lab finds gasoline; {DL} charged.")],
            howIdentified: "Motive, the policy change, and phone location records.",
            notDone: ["No one canvassed gas stations near the store until weeks later."],
            defendantExam: [
                .direct("Where were you that night?", "\"Home in bed.\""),
                .cross("Your phone was near the store at 1:41.", "\"I live four miles away. Maybe it hit that tower.\""),
                .cross("Why raise the insurance the month the loan went bad?", "\"Because I finally had the money for the premium.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Isn't it true most investigators have been wrong about gasoline detection before?\"",
                                  answer: "\"Some investigators, in some cases, yes.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance; assumes facts", shouldSustain: true,
                                  explanation: "Other investigators' errors in other cases don't test this witness's work or the lab's findings here.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A store about to be lost, a bigger policy, a phone near the building, and gasoline in three places.",
            defenseOpening: "A ninety-year-old building with wiring the inspector had already flagged.",
            prosecutionClosing: "Wiring doesn't start three fires, and it doesn't carry gasoline.",
            defenseClosing: "Motive isn't proof. The State has to put {DL} at that building."
        )
    )

    // MARK: - 126. The boat landing (a fight over a dock spot)

    static let boatLanding = CaseTemplate(
        key: "story.boatLanding", category: .violent,
        headlines: ["Fight at Boat Ramp Leaves Fisherman With Fractured Skull", "Paddle Swing Was Self-Defense, Boater Says"],
        primaryLaw: "awdwisi", lesserLaw: "aisi", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon, a wooden boat paddle, inflicting serious injury.",
        secondary: [],
        ageRange: 28...58, occupations: ["commercial fisherman", "marine mechanic", "charter boat captain"], hasVictim: true,
        summaries: [
            "On the morning of {DATE}, at the public boat landing on the river in {HOOD}, {D} and {V} argued over who had been waiting longer for the ramp. Witnesses agree {VL} walked down the dock toward {DL}'s boat shouting. What happened next is disputed. {DL} says {VL} reached for a filleting knife on {D.his} belt and {D.he} swung a wooden paddle once to keep {VL} back. {VL} fell, struck the dock cleat, and suffered a fractured skull. Deputies found a sheathed knife on {VL}'s belt. A witness says {VL}'s hands were empty and at {V.his} sides."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Two Eyewitnesses", "Two people at the landing say {VL}'s hands were empty and {DL} swung the paddle with both hands."),
            E(.document, 3, "Medical Records", "Depressed skull fracture; four days in intensive care; ongoing balance problems."),
            E(.physical, 2, "The Paddle", "A six-foot wooden paddle with a cracked blade and {VL}'s blood on the edge.")
        ],
        defenseEvidence: [
            E(.physical, 2, "Sheathed Knife", "A fixed-blade filleting knife on {VL}'s belt, snap undone when deputies arrived."),
            E(.statement, 1, "Earlier Threat", "A dock attendant heard {VL} say \"I'll gut you\" a few minutes before.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Kayaker at the landing",
                        direct: ["\"{VL}'s hands were empty.\""],
                        cross: ["\"I was about thirty yards away.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{VL} came down the dock yelling. {DL} grabbed the paddle and swung it like a bat. {VL} went down and hit the cleat.\""),
                            .direct("Where were {VL}'s hands?", "\"Down at {V.his} sides. Nothing in them.\""),
                            .cross("You were thirty yards away, loading your kayak?", "\"About that. I stopped loading when the yelling started.\""),
                            .cross("And {VL} was coming down the dock at {DL}, yelling, when the paddle swung?", "\"Yes. {V.He} was coming down the dock.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Victim",
                        direct: ["\"I never touched the knife.\""],
                        cross: ["\"I was angry. I said things.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What were you and {DL} arguing about?", "\"Who'd been waiting longer for the ramp.\""),
                            .direct("Did you reach for your knife?", "\"No. I wear it every time I fish. I was yelling, that's all.\""),
                            .direct("What were your injuries?", "\"A fractured skull. Four days in intensive care, and my balance still isn't right.\""),
                            .cross("You told {DL} you'd gut {D.him}?", "\"I don't remember saying that. I was angry.\""),
                            .cross("The snap on your sheath was undone.", "\"It comes undone. It's an old sheath.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Dock attendant",
                        direct: ["\"I heard '{VL}' say 'I'll gut you.'\""],
                        cross: ["\"I didn't see the swing.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you that morning?", "\"Working the landing, inside the bait shop.\""),
                            .direct("What did you hear before the fight?", "\"{VL} said, 'I'll gut you,' loud enough that I came out of the bait shop.\""),
                            .direct("How long before the fight was that?", "\"A few minutes.\""),
                            .cross("Did you see the paddle swing?", "\"No. I was walking around the building when it happened.\""),
                            .cross("So you never saw where {VL}'s hands were when {D.he} swung?", "\"No, I didn't.\"")
                        ])
        ],
        prosecutionTheory: ["{VL} was loud and angry but empty-handed. {D} answered words with a two-handed swing of a six-foot paddle to the head."],
        defenseTheory: ["{VL} threatened to gut {DL}, came at {D.him} with a knife on {V.his} belt and the snap undone. One swing to keep {V.him} back was self-defense."],
        aggravating: [],
        mitigating: ["The defendant was provoked by the victim's threats", "No prior criminal record"],
        victimImpacts: ["{V}: \"I can't stand on a boat anymore without falling. Fishing was my whole life.\""],
        allocutions: ["\"I thought {V.he} was going for the knife. I'm sorry {V.he} got hurt that bad.\""],
        guiltyTruths: ["{DL} texted a friend that afternoon: \"Guy ran his mouth, so I rang his bell. Knife never came out.\""],
        innocentTruths: ["A boat-mounted camera later found on another vessel showed {VL}'s hand on the knife handle as {V.he} stepped toward {DL}."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "6:40 a.m.: argument over the ramp."), (0, "6:45 a.m.: the paddle swing; 911 called."), (0, "Deputies photograph {VL}'s knife and sheath."), (4, "{VL} leaves intensive care."), (12, "{DL} charged.")],
            howIdentified: "{DL} stayed at the landing and told deputies {D.he} swung the paddle.",
            notDone: ["Boats at the landing were not checked for cameras."],
            defendantExam: [
                .direct("Why did you swing?", "\"{V.He} said {V.he}'d gut me and came at me with {V.his} hand going to that knife.\""),
                .cross("You swung a six-foot paddle with both hands at {V.his} head.", "\"I swung at {V.him}. I wasn't aiming.\""),
                .cross("You could have pushed off from the dock.", "\"Not with my boat still tied.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"You've been in fights at that landing before, haven't you?\"",
                                  answer: "\"Once, years ago.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper character evidence", shouldSustain: false,
                                  explanation: "When self-defense is raised, the victim's prior violent acts known to the defendant can bear on who was the aggressor, so the question is allowed.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "Angry words, empty hands, and a six-foot paddle swung at a man's head.",
            defenseOpening: "A threat to gut a man, a knife on the belt, and one swing to stay alive.",
            prosecutionClosing: "Two witnesses saw empty hands. Words don't justify a fractured skull.",
            defenseClosing: "The State has to prove beyond a reasonable doubt that this wasn't self-defense. A threat and an unsnapped knife make that impossible.",
            genders: ["V": .male]
        )
    )

    // MARK: - 127. The night shift (a nurse diverting fentanyl)

    static let nurseDiversion = CaseTemplate(
        key: "story.nurseDiversion", category: .drugs,
        headlines: ["Nurse Charged With Stealing Fentanyl Meant for Patients", "Hospital Audit Flags Hundreds of Wasted Doses"],
        primaryLaw: "prescriptionFraud", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Obtained fentanyl, a Schedule II controlled substance, by fraud, deceit, and misrepresentation, by documenting doses as given or wasted that were not.",
        secondary: [
            SecondaryCharge(lawID: "possSchedII", specification: "Possessed fentanyl, a Schedule II controlled substance.", chance: 1.0, threshold: 0)
        ],
        ageRange: 27...45, occupations: ["registered nurse"], hasVictim: false,
        summaries: [
            "{D} worked nights as a surgical recovery nurse at Hollis Regional Medical Center. The hospital's automated dispensing records showed {DL} withdrew fentanyl at three times the rate of other nurses on the unit, and recorded 212 partial doses as \"wasted\" over four months, often without a second nurse's witness signature. On {DATE}, a pharmacist tested a returned syringe {DL} had logged as fentanyl and found saline. A search of {DL}'s locker found two empty vials. {DL} says the unit was short-staffed, that nurses routinely skipped the witness step, and that someone else could have used {D.his} login."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Dispensing Records", "{DL}'s fentanyl withdrawals ran three times the unit average; 212 doses recorded as wasted, 140 without a witness.", .search),
            E(.forensic, 3, "Saline Syringe", "A syringe logged by {DL} as 50 micrograms of fentanyl tested as saline at the hospital lab and the State Crime Laboratory."),
            E(.physical, 2, "Locker Search", "Two empty fentanyl vials in {DL}'s locker.", .search),
            E(.document, 1, "Patient Pain Scores", "Several of {DL}'s patients reported unrelieved pain after documented doses.")
        ],
        defenseEvidence: [
            E(.document, 2, "Staffing Records", "The unit ran two nurses short on most of {DL}'s shifts."),
            E(.statement, 1, "Shared Login Practice", "A former coworker says nurses sometimes left the dispensing cabinet logged in during emergencies.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Pharmacy diversion specialist",
                        direct: ["\"Three times the unit average, every month.\""],
                        cross: ["\"Some nurses do skip the witness step.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the dispensing records show?", "\"{DL} pulled fentanyl three times as often as the other nurses on the same patients' units, and wasted partial doses at a rate I've never seen.\""),
                            .direct("How many doses were recorded as wasted?", "\"212 over four months. 140 of them had no witness signature.\""),
                            .direct("And the returned syringe?", "\"Logged as fentanyl. It was saline.\""),
                            .cross("The unit ran two nurses short on most of {DL}'s shifts?", "\"Yes, it did.\""),
                            .cross("Skipping the witness signature is common when the floor is busy?", "\"It happens. Not 140 times by one nurse.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective, drug diversion unit",
                        direct: ["\"Two empty vials in the locker.\""],
                        cross: ["\"The lockers don't have individual cameras.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Whose locker did you search?", "\"{DL}'s locker at the hospital.\""),
                            .direct("What did you find in the locker?", "\"Two empty fentanyl vials in the pocket of a jacket.\""),
                            .direct("What happened to the returned syringe?", "\"It went to the State Crime Laboratory, which confirmed it was saline.\""),
                            .cross("Other people could open those lockers?", "\"They have combination locks. We don't know who else had the combination.\""),
                            .cross("The dispensing records show {DL}'s login, not who was standing at the cabinet?", "\"They show the login, yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former coworker",
                        direct: ["\"We left the cabinet logged in during codes.\""],
                        cross: ["\"I never saw anyone use {DL}'s login.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Did you work on the same unit as {DL}?", "\"Yes, surgical recovery.\""),
                            .direct("How was the unit staffed?", "\"Short. We were down two nurses on a lot of shifts.\""),
                            .direct("Did nurses share logins?", "\"During a code, someone would pull meds while the cabinet was still logged in under whoever opened it.\""),
                            .cross("That happened during codes, not as a routine?", "\"Mostly during codes, yes.\""),
                            .cross("Did you ever see anyone use {DL}'s login?", "\"No, not that I saw.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pulled fentanyl under {D.his} own login, logged it as given or wasted, and gave patients saline."],
        defenseTheory: ["A short-staffed unit, shared logins, and lockers anyone could open. The State can't show {DL} was the one taking the drug."],
        aggravating: ["The defendant took advantage of a position of trust"],
        mitigating: ["The defendant has sought treatment for substance use", "No prior criminal record"],
        allocutions: ["\"I got hurt on the job and I got hooked. I'm in treatment now. My patients deserved better.\""],
        guiltyTruths: ["{DL}'s hair test, ordered by the nursing board, was positive for fentanyl for the whole four-month period."],
        innocentTruths: ["A traveling nurse who left the hospital the week of the search was later caught diverting under other nurses' logins at another hospital."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-120, "First flagged waste."), (-20, "Pharmacy diversion report on {DL}."), (0, "Saline found in a returned syringe."), (0, "Locker search."), (40, "State Crime Laboratory confirms saline; {DL} charged.")],
            howIdentified: "Dispensing records under {DL}'s login and the tested syringe.",
            notDone: ["Cabinet logins were not compared with badge swipes at the unit door."],
            defendantExam: [
                .direct("Did you take fentanyl from the hospital?", "\"I wasted doses alone because there was nobody to witness. I didn't take them.\""),
                .cross("A syringe you logged as fentanyl was saline.", "\"I don't know how that happened.\""),
                .cross("The vials were in your jacket.", "\"Anybody could have put them there.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"In your experience, do nurses who divert usually start because of an injury?\"",
                                  answer: "\"Very often, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Testimony that people who fit a profile tend to divert invites guilt by association; it doesn't prove this defendant did.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Fentanyl in, saline out, under one login.",
            defenseOpening: "A broken system, not a guilty nurse.",
            prosecutionClosing: "Shared logins don't explain three times the average, every month, on {DL}'s shifts.",
            defenseClosing: "Records show a login, not a person.",
            employer: "Hollis Regional Medical Center"
        )
    )

    // MARK: - 128. The clerk shoots back (a robbery that went wrong)

    static let clerkShootsBack = CaseTemplate(
        key: "story.clerkShootsBack", category: .robbery,
        headlines: ["Store Clerk Shoots Armed Robber", "Wounded Suspect Charged; Clerk Not Charged"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 10, lesserThreshold: 8,
        specification: "Took $612 from the person and presence of {V}, a clerk at {SHOP}, by the use of a handgun, whereby {V.his} life was threatened.",
        secondary: [
            SecondaryCharge(lawID: "conspiracyRobbery", specification: "Agreed with {ALT} to rob {SHOP} with a firearm.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...27, occupations: ["unemployed", "fast food cook", "car wash attendant"], hasVictim: true,
        summaries: [
            "Just after 11 p.m. on {DATE}, two people in ski masks walked into {SHOP} on {STREET} in {HOOD}. One pointed a black handgun at {V}, the clerk, and demanded the register. {V} handed over $612, then pulled a pistol from under the counter and fired twice as the two ran out. A trail of blood led across the lot. Forty minutes later {D} arrived at the emergency room with a gunshot wound to the shoulder, saying {D.he} had been shot during a drive-by. DNA from the blood trail matched {DL}. {DL}'s friend {ALT} was arrested the next week and agreed to testify. {DL} says {D.he} was shot walking past the store and ran because {D.he} panicked."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Store Camera", "Two masked people, one pointing a handgun at the clerk; the clerk firing as they run.", .search),
            E(.forensic, 3, "Blood Trail DNA", "Blood drops from the counter to the parking lot match {DL}'s DNA profile.", .search),
            E(.document, 2, "ER Records", "{DL} admitted at 11:52 p.m. with a gunshot wound to the left shoulder; told staff it was a drive-by."),
            E(.statement, 2, "Co-defendant", "{ALT} says {DL} planned the robbery and carried the gun.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Plea Deal", "{ALT} pleaded to common law robbery in exchange for testimony, avoiding a mandatory sentence."),
            E(.physical, 1, "No Gun Recovered", "No handgun was found on {DL} or along {D.his} route.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Store clerk",
                        direct: ["\"The gun was a foot from my face.\""],
                        cross: ["\"I couldn't see faces under the masks.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("When did this happen?", "\"Just after eleven at night.\""),
                            .direct("What happened?", "\"Two came in masked. The taller one put a black pistol a foot from my face and said 'Register, now.' I gave them the money. When they turned, I got my gun and fired twice.\""),
                            .direct("What did you see after they ran?", "\"Blood. Drops from my counter out across the parking lot.\""),
                            .cross("You fired as they were running out?", "\"Yes. They'd just had a gun in my face.\""),
                            .cross("You can't say who was under either mask?", "\"No. I can say one of them was bleeding on my floor.\"")
                        ]),
            WitnessSeed(name: "{ALT}", role: "Co-defendant",
                        direct: ["\"{DL} had the gun. It was {D.his} idea.\""],
                        cross: ["\"I got a deal.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Whose idea was the robbery?", "\"{DL}'s. {D.He} said that store kept cash late and the clerk wouldn't fight.\""),
                            .direct("Who had the gun?", "\"{DL}. {D.He} got rid of it in a storm drain after.\""),
                            .cross("Your plea deal took you out of the armed robbery sentence?", "\"Out of the armed robbery range entirely.\""),
                            .cross("Without the deal you'd be facing years more?", "\"Yes. I'm still telling the truth.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor",
                        direct: ["\"I heard shots out on the street around then.\""],
                        cross: ["\"I didn't see a car.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where were you that night?", "\"At home, near the store.\""),
                            .direct("What did you hear that night?", "\"Two or three pops out toward the street, a little after eleven.\""),
                            .direct("Did you look outside?", "\"No. I just heard it.\""),
                            .cross("You didn't see a car?", "\"No, I didn't see a car.\""),
                            .cross("Could those be the shots from inside the store?", "\"I suppose. I just heard pops.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s blood runs from the counter to the lot, {D.he} lied to the ER, and {D.his} partner says {D.he} held the gun."],
        defenseTheory: ["{DL} was hit by a stray shot walking past and ran. The only person who puts a gun in {D.his} hand bought a lighter sentence with that story."],
        aggravating: [],
        mitigating: ["The defendant was young at the time of the offense"],
        victimImpacts: ["{V}: \"I quit that job. I still see the barrel every time I close my eyes.\""],
        allocutions: ["\"I didn't have a gun. I got shot and I panicked.\""],
        guiltyTruths: ["The storm drain {ALT} described was searched months later and held a black pistol traced to a burglary in {DL}'s neighborhood."],
        innocentTruths: ["{ALT}'s cousin later admitted being the second masked robber, and the blood was {DL}'s from being hit walking past the door."],
        moods: [.wantsConviction], doctrines: ["accompliceTestimony", "burdenOfProof"],
        extras: ["SHOP": ["Quik Stop #4", "Riverside Mini Mart", "Harbor Mart"]],
        story: StoryExtras(
            timeline: [(0, "11:06 p.m.: robbery; clerk fires twice."), (0, "11:52 p.m.: {DL} arrives at the ER."), (3, "DNA sample taken under warrant."), (8, "{ALT} arrested."), (21, "DNA match; {DL} charged.")],
            howIdentified: "DNA from the blood trail, the ER visit, and {ALT}'s statement.",
            notDone: ["The storm drain {ALT} named was not searched before the trial."],
            defendantExam: [
                .direct("Why were you at the store?", "\"I was walking past to my cousin's. I heard shots and felt my shoulder burn.\""),
                .cross("Your blood is on the floor in front of the register.", "\"I don't know how.\""),
                .cross("You told the ER it was a drive-by.", "\"At the time I thought that's what it was.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Did {DL} rob anybody else that month?\"",
                                  answer: "\"{D.He} talked about a gas station.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character evidence (Rule 404(b))", shouldSustain: true,
                                  explanation: "Talk of other robberies offered to show {DL} is a robber is barred by Rule 404(b).",
                                  doctrineID: "priorActs", weight: 2))
            ],
            prosecutionOpening: "{DL}'s blood at the register tells you who was there.",
            defenseOpening: "A stray bullet, a panicked kid, and a partner who traded a story for a deal.",
            prosecutionClosing: "Blood doesn't lie, and the ER story was a lie.",
            defenseClosing: "Take away {ALT}'s bargained testimony and there's no gun in {DL}'s hand.",
            victim: VictimFacts(occupation: "Convenience store clerk")
        )
    )
}
