import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchT: [CaseTemplate] = [churchArsonist, mercyKilling, moonshineExplosion, hurricaneFraud, nursingHomeNeglect]

    // MARK: - 109. The churches (a string of fires at rural churches)

    static let churchArsonist = CaseTemplate(
        key: "story.churchArsonist", category: .property,
        headlines: ["Third Rural Church Burns in Six Weeks", "Volunteer Firefighter Charged in Church Fires"],
        primaryLaw: "burningBuildings", lesserLaw: "injuryRealProperty", threshold: 10, lesserThreshold: 8,
        specification: "Willfully and wantonly set fire to and burned Mount Zion Missionary Baptist Church, a building used for public worship.",
        secondary: [
            SecondaryCharge(lawID: "burningBuildings", specification: "Willfully and wantonly set fire to and burned Cane Creek Free Will Baptist Church.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "burningBuildings", specification: "Willfully and wantonly set fire to and burned Bethel A.M.E. Zion Church.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "firefighterInjury", specification: "Set a fire that seriously injured a volunteer firefighter when the Bethel church roof collapsed.", chance: 1.0, threshold: 0)
        ],
        ageRange: 23...31, occupations: ["volunteer firefighter and convenience store clerk"], hasVictim: false,
        summaries: [
            "Over six weeks, three country churches in {HOOD} and the surrounding townships burned in the middle of the night: Mount Zion Missionary Baptist, Cane Creek Free Will Baptist, and finally Bethel A.M.E. Zion on {DATE}, where a firefighter was badly hurt when the roof collapsed. Two of the congregations are Black and one is white, and the fires drew federal investigators. {D}, a volunteer firefighter, was among the first to respond to all three fires, twice before the alarm was dispatched. Cell phone records put {D.his} phone near each church minutes before each fire. A gas can at {D.his} home holds a fuel mix that matches residue at two of the scenes. {DL} says {D.he} got to the fires first because {D.he} listens to the scanner and lives nearby."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Cell Site Records", "{DL}'s phone connected to towers serving each church in the 30 minutes before each fire was reported.", .search),
            E(.forensic, 3, "Accelerant Analysis", "A gasoline and two-stroke oil mixture at two scenes, matching a gas can in {DL}'s shed.", .search),
            E(.document, 2, "Response Logs", "{DL} radioed \"on scene\" at two fires before the 911 call was dispatched."),
            E(.statement, 2, "Statement to Investigators", "{DL}: \"I just like being the one who gets there first. People notice you.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 2, "Scanner Habit", "Coworkers confirm {DL} listened to the fire scanner constantly and lived within four miles of all three churches."),
            E(.document, 1, "Common Fuel Mix", "The two-stroke fuel mix is sold at every hardware store in the county for chain saws and mowers."),
            E(.statement, 1, "Commendations", "Two commendations from the fire department for rescues.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "ATF certified fire investigator",
                        direct: ["\"All three were set.\""],
                        cross: ["\"That fuel is common.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did the fires start?", "\"Each was set at a back door with poured accelerant. Same method, same time of night, same fuel mix at two scenes.\""),
                            .direct("And the firefighter's own arrival times?", "\"At two fires {DL} reported being on scene before anyone had called it in. Both times {DL}'s pager log shows no page went out yet.\""),
                            .cross("The fuel mix is sold everywhere?", "\"It's common. That's why we also looked at the phone records.\""),
                            .cross("And {DL} lives within four miles of all three churches?", "\"Yes. But {D.his} phone hit the towers serving each church in the half hour before each fire.\"")
                        ]),
            WitnessSeed(name: nil, role: "Injured firefighter",
                        direct: ["\"The roof came down on me.\""],
                        cross: ["\"I don't know who set it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see when you arrived at Bethel?", "\"Fire at the back of the building, coming up into the roof. It was the middle of the night.\""),
                            .direct("What happened at Bethel?", "\"We went in to check for anyone sleeping in the fellowship hall. The roof trusses gave way. I have plates in my back and I won't fight fires again.\""),
                            .cross("You don't know who set the fire?", "\"No. I know {DL} was standing outside when I got there.\""),
                            .cross("{DL} was often first to a fire, wasn't {D.he}?", "\"Often, yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fire chief",
                        direct: ["\"{D.He} was always first on scene.\""],
                        cross: ["\"Before dispatch is unusual.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What kind of firefighter is {DL}?", "\"A good one. {D.He}'s got two commendations from the department for rescues.\""),
                            .direct("Was it unusual for {DL} to arrive first?", "\"No. {D.He} lives in the middle of the district and sleeps with the scanner on. {D.He} was first to half our calls.\""),
                            .cross("First before the call was even dispatched?", "\"That's unusual, yes.\""),
                            .cross("And that happened at two of these three church fires?", "\"Yes. Two of them.\"")
                        ])
        ],
        prosecutionTheory: ["{D} set three churches on fire so {D.he} could be the hero who got there first. The phone, the fuel, and the radio logs put {D.him} at every fire before anyone else knew."],
        defenseTheory: ["{DL} is a dedicated firefighter who lives near all three churches. The fuel is common, the phone towers cover miles, and early arrivals are what good volunteers do."],
        aggravating: ["The offense involved multiple victims", "The defendant knowingly created a great risk of death to more than one person"],
        mitigating: ["No prior criminal record", "The defendant has a long record of public service"],
        victimImpacts: ["A Bethel deacon: \"My grandmother was baptized in that church. We're holding services in the school cafeteria.\""],
        allocutions: ["\"I've spent years running into fires to help people. I'd never burn a church.\""],
        guiltyTruths: ["A lighter engraved with {DL}'s fire company insignia was later found buried in ash at the back door of Mount Zion."],
        innocentTruths: ["A man arrested for a fourth church fire a year later confessed to all four, describing details of the first three."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-42, "Mount Zion Missionary Baptist burns."),
                       (-20, "Cane Creek Free Will Baptist burns."),
                       (0, "2:40 a.m.: Bethel A.M.E. Zion burns; a firefighter is injured."),
                       (10, "Cell site records obtained by warrant."),
                       (21, "Gas can seized; {DL} interviewed and arrested.")],
            howIdentified: "Radio logs showing {DL} on scene before dispatch, then phone records.",
            notDone: ["No canvass for home security cameras near the first two churches."],
            defendantExam: [
                .direct("How did you get to the fires before dispatch?", "\"I'd hear the trucks' pagers tone out on my scanner before the dispatcher said the address. I know the district.\""),
                .direct("The gas can?", "\"It's for my chain saw. Everybody has one.\""),
                .cross("You told investigators you like being the first one there because people notice.", "\"I meant I like helping.\""),
                .cross("Your phone was at each church before each fire.", "\"I drive those roads every night.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Is it common for firefighters to be arsonists?\"",
                                  answer: "\"It's a recognized phenomenon.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Profile evidence; unfair prejudice", shouldSustain: true,
                                  explanation: "Generic profile testimony that people like the defendant commit such crimes is not evidence that this defendant did, and it invites propensity reasoning.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "Three churches, three fires, and one firefighter who was always there first.",
            defenseOpening: "A volunteer who lives in the middle of it all, and a theory built on coincidence.",
            prosecutionClosing: "First on the radio before the fire was even reported.",
            defenseClosing: "Being nearby isn't being guilty.",
            employer: "a convenience store in {HOOD} and the volunteer fire department"
        )
    )

    // MARK: - 110. The promise (a husband and his wife with dementia)

    static let mercyKilling = CaseTemplate(
        key: "story.mercyKilling", category: .family,
        headlines: ["Husband, 84, Charged After Shooting Wife With Dementia", "'I Promised Her': Mercy Killing Case Divides Town"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 7, lesserThreshold: 5,
        specification: "With premeditation and deliberation, killed {V}, the defendant's wife of 61 years, by shooting her as she slept.",
        secondary: [],
        ageRange: 84...84, occupations: ["retired tobacco farmer"], hasVictim: true,
        summaries: [
            "On {DATE}, {D}, 84, called 911 from the farmhouse in {HOOD} where he had lived with his wife, {V}, for sixty-one years. \"I've shot my wife,\" he told the dispatcher. \"I'll be on the porch.\" {VL}, 81, had advanced Alzheimer's. She no longer knew him, screamed through the nights, and had been refused by two memory care facilities after striking aides. Their savings were gone. {DL} told deputies that years earlier, when she was first diagnosed, she made him promise he would never let her \"end up like that.\" He wrote a note, laid out his best suit, and shot her once while she slept. He had intended to shoot himself afterward but couldn't. The district attorney charged first-degree murder, saying the law doesn't allow anyone to decide another person's life is not worth living."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "911 Call", "\"I've shot my wife. I'll be on the porch. Please don't let the dogs out.\""),
            E(.document, 3, "Note", "A handwritten note: \"I kept my promise. Forgive me. Bury us together.\""),
            E(.forensic, 2, "Autopsy", "A single close-range gunshot to the head while {VL} was asleep."),
            E(.statement, 2, "Interview", "{DL}: \"I'd been thinking about it for a month. I waited till she was sleeping peaceful.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Medical Records", "Advanced Alzheimer's; two facilities refused admission; a hospice nurse's notes describe {DL} sleeping two hours a night."),
            E(.statement, 2, "Promise", "Their daughter heard her mother ask for the promise years ago."),
            E(.document, 1, "Caregiver Collapse", "A geriatric psychiatrist diagnoses severe caregiver depression.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Sheriff's detective",
                        direct: ["\"He'd planned it for a month.\""],
                        cross: ["\"He was exhausted.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That he'd thought about it for a month, picked a night when she was calm, and shot her while she slept. He wanted us to know it was a decision.\""),
                            .direct("What did you find in the house?", "\"His best suit laid out, and a handwritten note: 'I kept my promise. Forgive me. Bury us together.'\""),
                            .cross("He hadn't slept in weeks?", "\"He looked like it.\""),
                            .cross("He asked about the dogs before he asked about a lawyer?", "\"He did.\"")
                        ]),
            WitnessSeed(name: nil, role: "Hospice nurse",
                        direct: ["\"She was not in pain at the end.\""],
                        cross: ["\"He was drowning.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Was {VL} dying?", "\"She had months, maybe a year or more. She wasn't in pain. She was confused and frightened, but comfortable most days.\""),
                            .direct("Was {VL} getting good care at home?", "\"Yes. He kept her clean and fed and safe. He never left her.\""),
                            .cross("How was {DL} doing?", "\"Drowning. I told the family he couldn't keep doing it alone. Nobody could take her.\""),
                            .cross("Your notes say he was sleeping about two hours a night?", "\"Yes. That's what I wrote.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "The couple's daughter",
                        direct: ["\"She made him promise.\""],
                        cross: ["\"I didn't know he'd do it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What promise?", "\"At the kitchen table when she was diagnosed. She said, 'Don't you let me go on like your mother did. Promise me.' He promised.\""),
                            .direct("How was your father managing in those last months?", "\"Worn out. Their savings were gone, and two places had refused to take her.\""),
                            .cross("Did your mother ever say she wanted to be killed?", "\"She never said those words.\""),
                            .cross("You live in Charlotte?", "\"Yes. I should have been here more.\"")
                        ])
        ],
        prosecutionTheory: ["However sympathetic, {D} planned for a month and shot his sleeping wife. No one gets to decide another person's life is over. That is premeditated murder."],
        defenseTheory: ["{DL} acted out of love and total exhaustion, keeping a promise to the person he'd loved for sixty-one years. The court should consider second-degree murder or less."],
        aggravating: ["The victim was especially vulnerable due to age or disability"],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community", "The defendant suffered from a mental condition that significantly reduced culpability"],
        victimImpacts: ["{VL}'s sister: \"She was still in there sometimes. She'd hum hymns. He didn't have the right.\"",
                        "Their grandson: \"He's the most gentle man I've ever known. Please let him come home.\""],
        allocutions: ["\"I kept my word to her. I'll answer for it to God. I don't much care what happens to me now.\""],
        guiltyTruths: ["A neighbor later said {DL} had told him a week earlier, \"She doesn't know me anymore. It's like living with a stranger.\""],
        innocentTruths: ["A letter in {VL}'s handwriting, dated soon after her diagnosis and found in the family Bible, asked him to keep \"the promise you made at the kitchen table.\""],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-2200, "{VL} diagnosed with Alzheimer's."),
                       (-90, "Second memory care facility refuses admission."),
                       (-30, "{DL} begins thinking about it, he later says."),
                       (0, "3:10 a.m.: {DL} shoots {VL} and calls 911."),
                       (1, "Charged with first-degree murder.")],
            howIdentified: "{DL} called 911 himself.",
            notDone: ["No one from adult protective services ever visited the home."],
            defendantExam: [
                .direct("Why did you do it?", "\"Because I promised her. She was scared all the time, and she didn't know where she was or who I was. That wasn't her life anymore.\""),
                .direct("Did you mean to kill yourself too?", "\"I meant to. My hands wouldn't do it.\""),
                .cross("She wasn't in pain. She had months.", "\"You didn't hear her screaming at three in the morning.\""),
                .cross("You planned it for a month.", "\"A month. Every detail.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Should your father go to prison?\"",
                                  answer: "\"No. Please, no.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Relevance to guilt", shouldSustain: true,
                                  explanation: "A witness's view of the appropriate punishment is not relevant to guilt; it may be heard at sentencing.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "A month of planning, a sleeping woman, and one shot. Love doesn't change what the law calls that.",
            defenseOpening: "Sixty-one years, a promise at a kitchen table, and a man who had nothing left.",
            prosecutionClosing: "Premeditation doesn't require malice in the heart. It requires a plan. He had one.",
            defenseClosing: "The law has room for mercy, and this is the case for it.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(occupation: "Retired; homemaker", relationship: "Married to the defendant for sixty-one years.", family: "Married to the defendant for sixty-one years; grown children."),
            family: "Widowed, 2 children, both grown. The late spouse is the victim in this case.",
            residence: "The farmhouse in {HOOD} where he and his wife lived for sixty-one years."
        )
    )

    // MARK: - 111. The still (an illegal liquor operation explodes)

    static let moonshineExplosion = CaseTemplate(
        key: "story.moonshineExplosion", category: .publicOrder,
        headlines: ["Barn Explosion Kills Teen Helper at Illegal Still", "Moonshiner Charged in Teen's Death"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Unlawfully caused the death of {V}, age 17, by culpable negligence in operating a propane-fired liquor still in an enclosed barn.",
        secondary: [
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Caused the destruction of a neighbor's barn by fire from the explosion.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "felonFirearm", specification: "Possessed two rifles in the farmhouse after a prior felony conviction.", chance: 1.0, threshold: 0)
        ],
        ageRange: 45...62, occupations: ["farmer", "auto mechanic"], forcedPriorOffenses: ["Possession of Schedule II (cocaine)"], hasVictim: true,
        summaries: [
            "On {DATE}, an explosion blew the roof off a tobacco barn on {D}'s property in {HOOD} and started a fire that spread to a neighbor's barn. Inside was a 300-gallon copper still fired by propane, and {V}, 17, a neighbor's son {DL} paid $50 a night to watch the fire. {VL} died of burns two days later. Investigators found two propane tanks connected with garden hose and duct tape, no ventilation, and alcohol vapor that had collected under the barn roof. {DL} has run the still for years and sold to bootleggers in three counties. {DL} says the boy was told never to light a cigarette in the barn and must have."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Fire Investigation", "Origin at the still; ethanol vapor ignited by the open propane burner in an unventilated barn. A cigarette lighter, unused, was in the boy's pocket."),
            E(.physical, 3, "Equipment", "Propane lines made of garden hose and duct tape; regulator removed; no ventilation.", .search),
            E(.statement, 2, "Payment Ledger", "A notebook recording $50 nightly payments to \"{VL}\" and gallons sold to buyers."),
            E(.document, 2, "Prior Warning", "A neighbor's complaint to the fire marshal a year earlier about \"fumes and a flame\" in the barn.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Rules Posted", "A handwritten sign in the barn: \"NO SMOKING NO FIRE.\""),
            E(.document, 1, "Boy's Experience", "{VL} had worked the still for months and knew the risks."),
            E(.statement, 1, "Tried to Rescue", "{DL} was burned pulling {VL} out.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State fire marshal investigator",
                        direct: ["\"That barn was a bomb.\""],
                        cross: ["\"There was a no-smoking sign.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What caused the explosion?", "\"Alcohol vapor from the still, trapped under a closed roof, reaching the open propane flame under the pot. It didn't need a cigarette. The flame was already there.\""),
                            .direct("And the propane setup?", "\"Garden hose, duct tape, and no regulator. If the vapor hadn't done it, the propane would have.\""),
                            .cross("There was a no-smoking sign?", "\"There was. The burner under the still was the open flame.\""),
                            .cross("And there was a cigarette lighter in the boy's pocket?", "\"There was. It hadn't been used.\"")
                        ]),
            WitnessSeed(name: nil, role: "Victim's mother",
                        direct: ["\"He said it was just watching a fire.\""],
                        cross: ["\"I knew he worked there.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did your son tell you about the job?", "\"That he watched a fire at night for {DL} and got fifty dollars. He was saving for a truck.\""),
                            .direct("How long had he been going over there?", "\"About five months. Most nights.\""),
                            .direct("What happened to him?", "\"He was burned in the explosion. He died two days later.\""),
                            .cross("You knew he was working at the still?", "\"I knew he was working at the barn. I didn't know what it was.\""),
                            .cross("And you let him go over there at night?", "\"Yes. I thought he was watching a fire for a neighbor.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor and customer",
                        direct: ["\"{DL} was careful.\""],
                        cross: ["\"I bought liquor from {D.him}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"We're neighbors. I've known {D.him} a long time.\""),
                            .direct("What kind of operator was {DL}?", "\"{D.He} ran that still twenty years without a problem. Careful, clean.\""),
                            .direct("Were there rules in that barn?", "\"Yes. {D.He} had a sign up, no smoking, no fire, and {D.he} meant it.\""),
                            .cross("You bought liquor from {DL}?", "\"I'm not going to answer that.\""),
                            .cross("You've never seen a still built to any safety standard, have you?", "\"No. I just know {D.his} never blew up before.\"")
                        ])
        ],
        prosecutionTheory: ["{D} ran a homemade propane still in a closed barn, ignored a warning, and paid a teenager to sit next to it at night. That is culpable negligence, and it killed {V}."],
        defenseTheory: ["Making liquor without a license is a crime, but {VL}'s death was an accident. {DL} posted rules, trained the boy, and ran into the fire to save him."],
        aggravating: ["The victim was very young"],
        mitigating: ["The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s mother: \"He was seventeen. He was saving for a truck. He thought it was an adventure.\""],
        allocutions: ["\"I loved that boy like my own. I'd trade places with him today.\""],
        guiltyTruths: ["A buyer later told agents {DL} had asked him to \"keep the boy's name out of it\" the morning after the explosion."],
        innocentTruths: ["A neighbor's game camera, reviewed later, showed {VL} stepping outside to smoke and walking back in moments before the blast."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-365, "Neighbor complains to the fire marshal about fumes and flame."),
                       (-150, "{VL} begins working nights at the barn."),
                       (0, "11:50 p.m.: explosion; fire spreads to a neighbor's barn."),
                       (2, "{VL} dies of burns."),
                       (5, "Still and ledger seized.")],
            howIdentified: "The fire and the still on {DL}'s land.",
            notDone: ["The fire marshal never inspected the barn after the neighbor's complaint."],
            defendantExam: [
                .direct("Did you warn the boy about fire?", "\"Every night. No smoking, no lighters, and step outside if you smell anything sweet.\""),
                .direct("Why no ventilation?", "\"I'd always kept the doors cracked. That night it was cold and he must have shut them.\""),
                .cross("You paid a seventeen-year-old to sit by an open flame and a pot of alcohol.", "\"To watch it. To keep it from boiling over.\""),
                .cross("Garden hose for propane?", "\"It worked for years.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"What kind of man pays a child to sit by a bomb?\"",
                                  answer: "\"A man who didn't care.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Argumentative; calls for opinion on character", shouldSustain: true,
                                  explanation: "The question is argument, not a request for facts within the witness's knowledge.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "A still, a closed barn, garden hose for propane, and a seventeen-year-old paid to sit beside it.",
            defenseOpening: "An old trade, an accident, and a man who ran into the fire.",
            prosecutionClosing: "The flame was always there. The danger was always known.",
            defenseClosing: "A tragedy isn't always a crime.",
            when: .months([8, 9, 10]),
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(occupation: "High school student; the defendant paid him to watch the still's fire", relationship: "A neighbor's son who worked nights for the defendant."),
            residence: "Owns the property in {HOOD} with the tobacco barn."
        )
    )

    // MARK: - 112. The storm (disaster assistance fraud after a hurricane)

    static let hurricaneFraud = CaseTemplate(
        key: "story.hurricaneFraud", category: .whiteCollar,
        headlines: ["After the Hurricane, a 'Relief Coordinator' Took Their Money", "Fake Contractor Charged With Storm Fraud"],
        primaryLaw: "falsePretenses100k", lesserLaw: "falsePretenses", threshold: 10, lesserThreshold: 8,
        specification: "Obtained more than $100,000 from homeowners in {HOOD} by falsely representing himself as a licensed contractor approved by FEMA to repair storm damage.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $14,000 from {V}, 77, as a deposit for a roof that was never repaired.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "identityTheft", specification: "Filed disaster assistance claims in the names of six residents without their knowledge.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "exploitationElder", specification: "Exploited {V}, an older adult, through deception.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Forged a general contractor license and a FEMA vendor letter.", chance: 1.0, threshold: 0)
        ],
        ageRange: 36...50, occupations: ["self-described disaster relief contractor"], hasVictim: true,
        summaries: [
            "Two weeks after a hurricane flooded {HOOD} and tore roofs off half the houses in the county, {D} arrived in a truck with a magnetic sign reading \"FEMA Approved Disaster Recovery.\" Going door to door with a clipboard, {D.he} collected deposits from 31 families, mostly elderly, for roof and drywall work, and helped some fill out assistance applications, using their information to file six claims of {D.his} own. {V}, 77, gave {D.him} $14,000, nearly all of her insurance check. Almost no work was done. {D.His} contractor license was a photocopy of someone else's with the name changed. On {DATE}, {DL} was arrested in South Carolina, doing the same thing after another storm."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Deposit Records", "Thirty-one contracts and canceled checks totaling $286,000 deposited to {DL}'s personal account."),
            E(.document, 3, "Forged License", "The license number belongs to a Raleigh contractor who never heard of {DL}; FEMA has no record of any vendor letter."),
            E(.digital, 2, "Disaster Claims", "Six assistance claims filed from {DL}'s laptop using residents' Social Security numbers.", .search),
            E(.statement, 2, "Victims' Statements", "Twelve homeowners who identify {DL} from a photo lineup.")
        ],
        defenseEvidence: [
            E(.document, 2, "Some Work Done", "Photos of tarps installed on nine roofs and two kitchens gutted."),
            E(.statement, 1, "Supply Shortage", "A supplier confirms shingles and drywall were back-ordered for months after the storm."),
            E(.document, 1, "Subcontractor Disputes", "Texts showing {DL}'s subcontractors walked off the job unpaid.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner, 77",
                        direct: ["\"He said FEMA sent him.\""],
                        cross: ["\"He put a tarp on.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That FEMA sent him to help seniors first. He had a badge on a lanyard. He said if I paid the deposit that day I'd be at the top of the list.\""),
                            .direct("What work was done?", "\"A blue tarp. It blew off in October. I've been living in two rooms.\""),
                            .cross("He did put a tarp on your roof?", "\"For $14,000, a tarp.\""),
                            .cross("He told you shingles were back-ordered after the storm?", "\"Yes, he told me that. He kept my money anyway.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Bureau of Investigation financial agent",
                        direct: ["\"The money went to a boat and a casino.\""],
                        cross: ["\"Some went to supplies.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How much did homeowners pay {DL}?", "\"$286,000 from thirty-one families, all deposited to {D.his} personal account.\""),
                            .direct("Was {DL} a licensed contractor?", "\"No. The license number belongs to a Raleigh contractor who'd never heard of {D.him}, and FEMA has no record of any vendor letter.\""),
                            .direct("Where did the deposits go?", "\"About eleven percent to building supplies. The rest to a bass boat, a casino in Cherokee, and cash withdrawals in four states.\""),
                            .cross("Some money did go to supplies?", "\"About thirty thousand dollars of two hundred eighty-six.\""),
                            .cross("And tarps did go up on nine roofs?", "\"Yes. Nine tarps, and two kitchens gutted.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Subcontractor",
                        direct: ["\"Supplies weren't available.\""],
                        cross: ["\"He never paid us.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you do for {DL}?", "\"Roof and drywall work on the storm jobs.\""),
                            .direct("Was any work done?", "\"Some. We put tarps on roofs and gutted a couple of kitchens.\""),
                            .direct("Why wasn't the work done?", "\"There wasn't a shingle to be had for three counties. Everybody was waiting.\""),
                            .cross("Did {DL} pay you for the work you did do?", "\"No. That's why we left.\""),
                            .cross("You didn't know {DL} had collected $286,000 in deposits?", "\"No. I never heard that number until this case.\"")
                        ])
        ],
        prosecutionTheory: ["{D} followed the storm, faked a license and a FEMA badge, took deposits from frightened elderly people, and spent them on himself. It's the same scheme in every disaster."],
        defenseTheory: ["{DL} was an unlicensed contractor overwhelmed by demand and shortages, not a thief. Some work was done. This is a contract dispute dressed up as a felony."],
        aggravating: ["The offense involved multiple victims", "The victim was especially vulnerable due to age", "The offense involved the taking of property of great monetary value (G.S. 15A-1340.16(d)(14))"],
        mitigating: [],
        victimImpacts: ["{V}: \"I've lived in that house fifty years. The storm took my roof. He took the money to fix it.\""],
        allocutions: ["\"I got in over my head. I meant to do the work.\""],
        guiltyTruths: ["A notebook found in {DL}'s truck listed storms by date and county, with notes like \"elderly, insurance paid, move fast.\""],
        innocentTruths: ["Records later showed {DL}'s business partner controlled the account and made most of the withdrawals without {DL}'s knowledge."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-120, "Hurricane makes landfall."),
                       (-105, "{DL} begins going door to door."),
                       (-100, "{V} pays a $14,000 deposit."),
                       (-30, "Homeowners report {DL} to the attorney general."),
                       (0, "{DL} arrested in South Carolina."),
                       (25, "{DL} extradited and indicted.")],
            howIdentified: "Complaints to the attorney general's consumer protection line.",
            notDone: ["The business partner was never interviewed."],
            defendantExam: [
                .direct("Did you mean to do the work?", "\"Yes. I had crews lined up. Then nobody could get materials and my guys walked.\""),
                .direct("The FEMA badge?", "\"I registered on a website. I thought that's what it meant.\""),
                .cross("The license had someone else's number.", "\"Somebody made it for me.\""),
                .cross("A bass boat and a casino.", "\"I made some bad decisions.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How many other families did he do this to?\"",
                                  answer: "\"Everybody on my street.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Lack of personal knowledge", shouldSustain: true,
                                  explanation: "The witness can speak to her own dealings; what happened to others is outside her personal knowledge (Rule 602).",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A hurricane, a magnetic sign, and thirty-one families who paid for roofs that never came.",
            defenseOpening: "A shortage, a contractor in over his head, and a contract dispute.",
            prosecutionClosing: "Eleven cents of every dollar went to supplies.",
            defenseClosing: "Bad business isn't always a crime.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(relationship: "A homeowner who hired the defendant after the storm.", restitution: 14000, restitutionBasis: "her $14,000 deposit")
        )
    )

    // MARK: - 113. The night shift (neglect at a nursing home)

    static let nursingHomeNeglect = CaseTemplate(
        key: "story.nursingHomeNeglect", category: .family,
        headlines: ["Nursing Home Resident Dies of Untreated Sores", "Director of Nursing Charged; Charts Show Turns That Never Happened"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Unlawfully caused the death of {V}, a resident, by culpable negligence in failing to provide care for pressure wounds over six weeks.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Falsified care records showing {V} was turned every two hours when she was not.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Signed the names of nursing assistants to 140 care entries they never made.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "patientNeglect", specification: "As a person responsible for the care of {V}, a resident of a health care facility, culpably neglected her, proximately causing her death.", chance: 1.0, threshold: 0)
        ],
        ageRange: 44...58, occupations: ["director of nursing"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 88, a resident of a nursing home in {HOOD}, died of sepsis from pressure wounds so deep they exposed bone. She couldn't move on her own. State inspectors found the facility had run nights with one nursing assistant for 42 residents for months. The chart showed {VL} turned every two hours, with initials from assistants; one of them testifies that the assistants were never on that hall and never signed. {D}, the director of nursing, filled in the entries, the State says, to pass an inspection. {DL} says {D.he} begged the owners for staff in writing, and that the chart entries were \"catching up\" on care {D.he} believed had been given."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Falsified Chart", "140 turning entries over six weeks, with initials of assistants who weren't working; handwriting analysis matches {DL}.", .search),
            E(.forensic, 3, "Autopsy and Wound Photos", "Stage 4 pressure wounds to bone at the sacrum and both heels; death from sepsis."),
            E(.document, 2, "Staffing Records", "Payroll shows one assistant for 42 residents on most nights."),
            E(.statement, 2, "Assistants' Statements", "Three assistants say they never cared for {VL} and never initialed her chart.")
        ],
        defenseEvidence: [
            E(.document, 3, "Emails to Owners", "Eleven emails from {DL} to the corporate owners begging for more staff, all refused."),
            E(.document, 1, "Corporate Pressure", "A memo from the owners setting a staffing budget below state minimums."),
            E(.statement, 1, "Long Hours", "Timecards show {DL} working 70-hour weeks.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Nursing assistant",
                        direct: ["\"Those aren't my initials.\""],
                        cross: ["\"There weren't enough of us.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How many assistants worked nights?", "\"Most nights, one. One of us for 42 residents.\""),
                            .direct("Did you turn {VL} on those nights?", "\"I never worked that hall. I was pulled to the dining room and laundry those nights. Those aren't my initials, and that's not how I write.\""),
                            .direct("Did anyone ask you to initial her chart?", "\"No. Nobody ever asked me. I didn't know my initials were on it.\""),
                            .cross("Could anyone have turned 42 residents every two hours alone?", "\"No. Nobody could.\""),
                            .cross("The staffing wasn't something {DL} could fix alone, was it?", "\"Not alone. The owners set the staff.\"")
                        ]),
            WitnessSeed(name: nil, role: "State nurse surveyor",
                        direct: ["\"This took weeks.\""],
                        cross: ["\"The owners understaffed it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find on staffing?", "\"One nursing assistant for 42 residents on most nights, for months.\""),
                            .direct("How long does a wound like this take?", "\"Weeks of no turning, no wound care. Any nurse looking at her would have seen it.\""),
                            .direct("What did {VL}'s chart say?", "\"That she was turned every two hours, with assistants' initials. Those assistants weren't on her hall.\""),
                            .cross("The owners staffed below state minimums?", "\"Yes. We've cited them.\""),
                            .cross("And {DL} emailed the owners eleven times asking for more staff?", "\"Yes. I've seen those emails.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former administrator",
                        direct: ["\"The owners wouldn't pay for staff.\""],
                        cross: ["\"Faking charts was {D.his} choice.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How hard was {DL} working?", "\"Seventy-hour weeks. The timecards show it.\""),
                            .direct("What happened when {DL} asked for staff?", "\"Corporate said no every time. Budget. We were told to make it work.\""),
                            .cross("Did corporate tell {DL} to fake the charts?", "\"Nobody at corporate said that. They said fix the numbers.\""),
                            .cross("Being short-staffed didn't require anyone to sign other people's initials?", "\"No. It didn't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew {V} was not being turned and filled in her chart to say she was. The falsified records hid the neglect until it killed her."],
        defenseTheory: ["{DL} was set up to fail by owners who wouldn't staff the building. The deaths belong to them. Bad paperwork isn't culpable negligence."],
        aggravating: ["The victim was especially vulnerable due to age or disability", "The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{VL}'s daughter: \"Every Sunday I asked if she was being turned. They showed me the chart.\""],
        allocutions: ["\"I tried. I couldn't be everywhere. I'm sorry I wrote down what I wished was true.\""],
        guiltyTruths: ["A text from {DL} to the administrator the week inspectors came: \"Charts are fixed. Don't let them see Room 14.\""],
        innocentTruths: ["The regional manager later admitted ordering all directors of nursing to \"complete the charts\" before inspections."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-180, "Corporate cuts night staff."),
                       (-45, "First wound noted on {VL}'s heel."),
                       (-10, "State inspection; charts reviewed."),
                       (0, "{VL} dies of sepsis."),
                       (40, "Handwriting analysis completed; {DL} charged.")],
            howIdentified: "A state inspection after {VL}'s family complained.",
            notDone: ["The corporate owners were not charged."],
            defendantExam: [
                .direct("Why did you fill in those entries?", "\"Because I believed the girls were doing the turns and just not charting. I was catching up the paperwork. I was wrong about what was happening.\""),
                .direct("Did you ask for help?", "\"Eleven times, in writing.\""),
                .cross("You signed other people's initials.", "\"I signed them. I knew better.\""),
                .cross("You never looked at her wounds.", "\"I didn't have time to look at anybody.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Are you angry at the company for firing you?\"",
                                  answer: "\"Yes.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "A witness's bias against a party is always a proper subject of cross-examination.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A chart that says she was turned every two hours, and wounds that say she wasn't.",
            defenseOpening: "A nurse left alone by owners who wouldn't pay for help.",
            prosecutionClosing: "The paper lied, and the lie let her die.",
            defenseClosing: "Blame the company that built the failure, not the nurse who drowned in it.",
            genders: ["D": .female, "V": .female],
            victim: VictimFacts(occupation: "Retired; nursing home resident", relationship: "A resident in the defendant's care.")
        )
    )
}
