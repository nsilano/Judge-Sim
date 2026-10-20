import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchN: [CaseTemplate] = [joggerChase, wrongApartment, taserMistake, movieSetGun, hotCarDeath]

    // MARK: - 79. The jogger (a chase by neighbors who suspected a burglar)

    static let joggerChase = CaseTemplate(
        key: "story.joggerChase", category: .violent,
        headlines: ["Jogger Shot After Neighbors Chase Him Through {HOOD}", "Defense Claims Citizen's Arrest in Jogger's Death"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 9, lesserThreshold: 7,
        specification: "Unlawfully and with malice killed {V} with a shotgun after pursuing {V.him} in a pickup truck.",
        secondary: [
            SecondaryCharge(lawID: "kidnapping2", specification: "Unlawfully restrained {V} by cornering {V.him} with a pickup truck on {STREET}.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "assaultPointingGun", specification: "Pointed a shotgun at {V} from the bed of a pickup truck during the chase.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "awdw", specification: "Assaulted {V} with a deadly weapon, a pickup truck, by trying to run {V.him} off the road.", chance: 1.0, threshold: 0)
        ],
        ageRange: 55...68, occupations: ["retired police investigator"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 25, was jogging through a subdivision in {HOOD} when {D}, a retired police investigator, and {D.his} adult child saw {V.him} on a neighbor's security camera walking through a house under construction. They grabbed a shotgun and a pistol, got in a pickup, and chased {VL} for five minutes, cornering {V.him} twice. A neighbor recorded the end on a phone: {VL} running around the truck, a struggle over the shotgun, three shots. {VL} died in the street. Nothing was ever taken from the construction site. {DL} says they were making a citizen's arrest of a suspected burglar and that {VL} attacked the shotgun. The child pleaded guilty and is expected to testify."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Neighbor's Phone Video", "Twenty-eight seconds: the truck stopped in the road, {VL} running around it, a struggle at the front of the truck, three shotgun blasts."),
            E(.video, 2, "Construction Site Camera", "{VL} walks into the unfinished house, looks around for four minutes, and leaves with nothing. Others had done the same on earlier nights."),
            E(.statement, 3, "Child's Plea Statement", "{DL}'s adult child, who fired the shots, has pleaded guilty and says {DL} said, \"Let's get him,\" and directed the chase."),
            E(.statement, 2, "{DL}'s 911 Call", "{DL}, during the chase: \"There's a guy running down the street. I'm going to stop him.\" The dispatcher asked what he had done; {DL} didn't answer.", .statement)
        ],
        defenseEvidence: [
            E(.document, 2, "Prior Break-Ins", "Six reports of thefts from unlocked cars and the construction site in the neighborhood over three months."),
            E(.forensic, 2, "Struggle", "{VL}'s hands were on the shotgun when the second and third shots were fired, according to the video frame analysis."),
            E(.document, 1, "Citizen's Arrest Training", "{DL}'s police training included the law on citizen's arrest, which {DL} believed applied.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s adult child (cooperating co-defendant)",
                        direct: ["\"{DL} said, 'Let's get him.'\""],
                        cross: ["\"I took a deal.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened when you saw {VL} run past?", "\"{DL} yelled for me to grab the shotgun. {D.He} said, 'Let's get him.' I drove. We cut {V.him} off twice. {V.He} kept running around us.\""),
                            .direct("Did {VL} ever threaten you?", "\"No. {V.He} was running away the whole time until the end.\""),
                            .cross("You fired the shots, and you pleaded guilty in exchange for this testimony?", "\"Yes.\""),
                            .cross("{VL} grabbed the shotgun?", "\"After I pointed it at {V.him}, yeah. {V.He} grabbed the barrel.\"")
                        ]),
            WitnessSeed(name: nil, role: "SBI agent",
                        direct: ["\"Nothing was ever stolen.\""],
                        cross: ["\"There had been break-ins.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {VL} take from the construction site?", "\"Nothing. The owner said nothing was ever missing. The camera shows {V.him} walking in, looking, and walking out, like a dozen other people, including kids.\""),
                            .direct("Could {DL} make a citizen's arrest?", "\"Under our law a private person can only detain someone for a felony committed in their presence. {DL} saw nothing. {D.He} saw a man jogging.\""),
                            .cross("There were six reports of thefts in that neighborhood?", "\"From unlocked cars. None linked to {VL}.\""),
                            .cross("{DL} called 911 during the chase?", "\"{D.He} did. When asked what the man had done, {D.he} didn't say.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor",
                        direct: ["\"We were all scared of the break-ins.\""],
                        cross: ["\"Nobody saw {VL} take anything.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was the neighborhood like that winter?", "\"Scared. Cars broken into. We had a group text. Somebody had seen a person at the construction site at night a few times.\""),
                            .cross("Did anyone ever see {VL} steal anything?", "\"No.\""),
                            .cross("Was anyone in the group text told to grab guns and chase people?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{D} saw a young man jogging, armed {D.himself}, and hunted {V.him} down. There was no crime to arrest {V.him} for. {DL} started the confrontation that killed {V.him}."],
        defenseTheory: ["{DL} believed a burglar was fleeing and tried to hold {V.him} for police. {VL} grabbed the shotgun. At most, this is a tragic mistake, not malice."],
        aggravating: ["The defendant was armed with a deadly weapon"],
        mitigating: ["No prior criminal record", "The defendant has a long record of public service"],
        victimImpacts: ["{VL}'s mother: \"My son went out for a run. He was hunted. Say his name.\""],
        allocutions: ["\"I thought I was protecting my neighbors. I'm sorry a young man is dead.\""],
        guiltyTruths: ["A text {DL} sent a friend that afternoon, recovered later, said \"one of those guys came through again, we'll handle it.\""],
        innocentTruths: ["A neighbor later confirmed telling {DL} that night that a man matching {VL}'s description had stolen a gun from a truck the week before."],
        moods: [.wantsConviction], doctrines: ["selfDefense", "justification"],
        story: StoryExtras(
            timeline: [(-90, "Neighborhood begins reporting thefts from cars."),
                       (0, "1:04 p.m.: construction site camera shows {VL} enter and leave."),
                       (0, "1:08–1:13 p.m.: chase; shots fired; {VL} dies at the scene."),
                       (60, "Neighbor's phone video becomes public."),
                       (62, "{DL} and {DL}'s child arrested.")],
            howIdentified: "{DL} called 911 and remained at the scene.",
            notDone: ["The initial responding officers didn't arrest anyone for two months."],
            defendantExam: [
                .direct("Why did you chase {VL}?", "\"I recognized {V.him} from the camera at the construction site. I thought {V.he} was the one breaking into cars. I wanted to hold {V.him} for the police.\""),
                .direct("Did you tell your child to shoot?", "\"No. I said grab the gun so we'd be safe.\""),
                .cross("What crime did you see {VL} commit?", "\"I saw the video of {V.him} in the house.\""),
                .cross("{VL} ran away from you for five minutes.", "\"Running from us, yes. That's what guilty people do.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Agent, was this a hate crime?\"",
                                  answer: "\"In my opinion, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper opinion on an ultimate issue", shouldSustain: true,
                                  explanation: "The agent's opinion on motive isn't based on specialized knowledge and invades the factfinder's role.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A young man went for a run. Three neighbors decided he was a criminal and hunted him.",
            defenseOpening: "Scared neighbors, a man on a construction site camera, and a struggle over a gun.",
            prosecutionClosing: "You can't create the danger and then claim self-defense against it.",
            defenseClosing: "{DL} made a terrible judgment. Malice requires more.",
            when: .months([12, 1, 2]),
            genders: ["V": .male]
        )
    )

    // MARK: - 80. The wrong apartment (an off-duty officer kills a neighbor)

    static let wrongApartment = CaseTemplate(
        key: "story.wrongApartment", category: .violent,
        headlines: ["Off-Duty Officer Shoots Neighbor in His Own Apartment", "Officer Says She Thought She Was Home"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 8, lesserThreshold: 6,
        specification: "Unlawfully and with malice killed {V} in {V.his} own apartment with a service pistol.",
        ageRange: 28...36, occupations: ["Port Hollis police officer"], hasVictim: true,
        summaries: [
            "At 9:58 p.m. on {DATE}, {D}, a Port Hollis police officer, came home from a fourteen-hour shift to the Harbor View apartments, parked on the fourth floor of the garage instead of the third, and walked to the apartment directly above {D.hers}. The door was ajar. Inside, {V}, 26, an accountant, was eating ice cream on the couch. {DL} drew {D.his} service pistol and fired twice, killing {V.him}. {DL} says {D.he} believed {D.he} was in {D.his} own apartment and that {VL} was a burglar coming toward {D.him}. The apartment had a bright red doormat; {DL}'s had none."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Red Doormat", "{VL}'s apartment had a bright red doormat outside the door; {DL}'s, one floor down, had none."),
            E(.forensic, 3, "Bullet Trajectory", "The fatal bullet entered {VL}'s chest at a downward angle consistent with {V.him} rising from the couch, not advancing."),
            E(.digital, 2, "Sexually Explicit Texts", "Texts with a partner on {DL}'s phone in the minutes before, while walking to the door.", .search),
            E(.document, 2, "Training Records", "{DL}'s training required taking cover and calling for backup before entering a possible burglary.")
        ],
        defenseEvidence: [
            E(.document, 2, "Fourteen-Hour Shift", "{DL} had worked fourteen hours, including a violent arrest that afternoon."),
            E(.document, 2, "Identical Layouts", "Every floor of the building has identical hallways and identical apartment layouts; residents had complained of going to the wrong floor."),
            E(.statement, 1, "911 Call", "{DL} on 911: \"I thought it was my apartment. Oh my God. I'm going to lose my job. I thought it was my apartment.\"", .statement)
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "SBI agent",
                        direct: ["\"The doormat was right there.\""],
                        cross: ["\"The floors are identical.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What would {DL} have seen at the door?", "\"A bright red doormat, a different number on the door, and a door that was open. {DL}'s door had no mat.\""),
                            .direct("What did {DL}'s training require?", "\"If you think someone is in your home, you back out, take cover, and call it in. You don't go in alone.\""),
                            .cross("Residents had gone to the wrong floor before?", "\"Several had.\""),
                            .cross("It was dark inside the apartment?", "\"The lights were off except the TV.\"")
                        ]),
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"{VL} was rising, not charging.\""],
                        cross: ["\"I can't say how fast.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the wound path show?", "\"The bullet went downward through the chest. That fits someone getting up from a seated or crouched position. It doesn't fit someone running at a shooter.\""),
                            .cross("You can't say whether {VL} was moving toward {DL}?", "\"I can say the angle was downward.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Use-of-force expert",
                        direct: ["\"In the dark, with a stranger in your home, you have seconds.\""],
                        cross: ["\"It wasn't her home.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How do officers respond to a perceived intruder at close range?", "\"Training says you have one or two seconds. If you believe a stranger is coming at you in your own dark apartment, firing is consistent with that belief.\""),
                            .cross("The belief has to be reasonable, and the apartment wasn't hers?", "\"Reasonable in the moment, yes.\""),
                            .cross("Training also says back out and call backup?", "\"When you can.\"")
                        ])
        ],
        prosecutionTheory: ["{D} ignored a red doormat and an open door, walked into a stranger's home with a drawn gun instead of calling for help, and shot a man eating ice cream on his couch."],
        defenseTheory: ["An exhausted officer in an identical hallway honestly believed {D.he} was home and facing an intruder. A mistaken, honest belief is not malice; at most it is manslaughter."],
        aggravating: ["The defendant abused a position of public trust"],
        mitigating: ["No prior criminal record", "The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s brother: \"He was in his own home. The safest place in the world.\""],
        allocutions: ["\"I wish he'd been the one with the gun. I ask God every day why I'm alive and he's not.\""],
        guiltyTruths: ["The building's hallway camera, recovered later, showed {DL} pausing at the red mat and reading the door number before entering."],
        innocentTruths: ["The building manager later admitted the third and fourth floor door numbers had been swapped by a contractor that week."],
        moods: [.wantsConviction], doctrines: ["selfDefense", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(0, "9:58 p.m.: {DL} enters {VL}'s apartment and fires twice."),
                       (0, "10:00 p.m.: {DL} calls 911."),
                       (1, "Autopsy."),
                       (3, "{DL} placed on leave and charged with manslaughter."),
                       (75, "Indicted for murder.")],
            howIdentified: "{DL} called 911.",
            notDone: ["The hallway camera footage was not requested for a week."],
            defendantExam: [
                .direct("What did you believe when you got to the door?", "\"That I was home. The key was in my hand and the door pushed open. I saw a silhouette in my apartment and I thought I was going to die.\""),
                .direct("Did you see the red doormat?", "\"No. I was looking at my phone and my keys. I was so tired.\""),
                .cross("You were texting about meeting your partner.", "\"I was texting my partner, yes.\""),
                .cross("Your training says back out and call for backup.", "\"I didn't think. I'm so sorry.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Would a reasonable officer in that moment have fired?\"",
                                  answer: "\"Yes.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Calls for a legal conclusion", shouldSustain: true,
                                  explanation: "Whether the defendant's belief was reasonable is the ultimate question for the factfinder.",
                                  doctrineID: "expertTestimony", weight: -1))
            ],
            prosecutionOpening: "A red doormat, an open door, and a man eating ice cream.",
            defenseOpening: "An exhausted officer, identical hallways, and a split second in the dark.",
            prosecutionClosing: "An honest mistake doesn't excuse an unreasonable one.",
            defenseClosing: "{DL} didn't intend to kill a neighbor. {D.He} thought {D.he} was home.",
            genders: ["D": .female, "V": .male]
        )
    )

    // MARK: - 81. The taser mistake (an officer draws a gun instead)

    static let taserMistake = CaseTemplate(
        key: "story.taserMistake", category: .violent,
        headlines: ["Officer Says She Meant to Use Taser in Fatal Traffic Stop", "Veteran Officer Charged After Gun-Taser Mix-Up"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "By culpable negligence, unintentionally killed {V} by firing a handgun believing it was a Taser.",
        ageRange: 44...52, occupations: ["Port Hollis police officer and field training officer"], hasVictim: true,
        summaries: [
            "On {DATE}, officers stopped {V}, 20, for expired tags in {HOOD} and found a warrant for a missed court date. As they tried to handcuff {VL}, {V.he} pulled away and got back into the driver's seat. {D}, a 26-year veteran training a rookie, shouted \"Taser! Taser! Taser!\" and fired once. It was {D.his} pistol. {VL} drove a block and crashed, and died at the scene. Body camera captures {DL} saying \"Holy shit, I just shot him.\" {DL} wore the Taser on the opposite side, in a yellow holster, under department policy. {DL} says it was a horrific mistake under stress."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Camera", "{DL} draws from the right side, points, shouts \"Taser!\" three times, fires once, then: \"Holy shit, I just shot him.\""),
            E(.document, 3, "Holster Configuration", "{DL}'s Taser was yellow and holstered on the left, cross-draw; the black pistol was on the right."),
            E(.document, 2, "Training Records", "{DL} completed annual Taser training including weapon confusion scenarios for 26 years.")
        ],
        defenseEvidence: [
            E(.document, 2, "Weapon Confusion Studies", "Documented cases nationwide of officers drawing a firearm when intending a Taser under stress."),
            E(.video, 2, "Struggle", "Body camera shows another officer half inside the car being dragged as {VL} tried to drive."),
            E(.statement, 1, "Immediate Reaction", "{DL}'s immediate words and collapse to the curb show the shot wasn't intended.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Police training supervisor",
                        direct: ["\"Twenty-six years of training on exactly this.\""],
                        cross: ["\"Stress causes mistakes.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How is the Taser carried?", "\"Weak side, cross-draw, bright yellow. Everything about it is designed so you can't confuse it with the pistol. {DL} trained new officers on that.\""),
                            .direct("What does the video show?", "\"A strong-side draw of a black pistol, held for five seconds before firing. That's long enough to look at what's in your hand.\""),
                            .cross("Weapon confusion has happened to other trained officers?", "\"It has. Rarely.\""),
                            .cross("Another officer was being dragged by the car?", "\"Half in the car, yes.\"")
                        ]),
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"One gunshot to the chest.\""],
                        cross: ["\"The crash didn't cause the death.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What killed {VL}?", "\"A single gunshot wound to the chest that went through the heart and lung.\""),
                            .cross("The crash injuries were minor?", "\"Minor. The gunshot was fatal.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Human-factors expert",
                        direct: ["\"Under extreme stress, the brain runs the most practiced motion.\""],
                        cross: ["\"It's still a failure.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How does weapon confusion happen?", "\"An officer who has drawn a pistol thousands of times in training can, under extreme stress, run that motor program while consciously intending something else. The officer genuinely believes the Taser is in hand.\""),
                            .cross("That's a failure of training and attention?", "\"It's a failure. It isn't a choice.\""),
                            .cross("Five seconds passed between the draw and the shot?", "\"About five.\"")
                        ])
        ],
        prosecutionTheory: ["After 26 years of training on exactly this danger, {D} drew a black gun from the wrong side, held it for five seconds, and fired. That's culpable negligence."],
        defenseTheory: ["A horrific mistake under extreme stress, with a fellow officer being dragged, by an officer who shouted 'Taser' because {D.he} believed it. Mistakes are tragedies, not crimes."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has a long record of public service", "The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s mother: \"He had a two-year-old son. He was going to court on Monday to take care of that warrant.\""],
        allocutions: ["\"I'm so sorry. I didn't want to hurt anybody. I will never forgive myself.\""],
        guiltyTruths: ["An earlier body camera clip from the same shift showed {DL} drawing the pistol by mistake and catching it, then joking about it."],
        innocentTruths: ["A department memo later revealed the holster configuration had been changed the week before without retraining."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "2:01 p.m.: traffic stop for expired tags; warrant discovered."),
                       (0, "2:04 p.m.: single shot fired; {VL} crashes a block away."),
                       (1, "Body camera video released."),
                       (3, "{DL} resigns and is charged.")],
            howIdentified: "Body camera.",
            notDone: [],
            defendantExam: [
                .direct("What did you mean to do?", "\"Tase {V.him}. I said 'Taser' because I thought I had my Taser. My partner was being dragged.\""),
                .direct("When did you realize?", "\"When it fired and the sound was wrong. I looked down and it was my gun.\""),
                .cross("You trained rookies on exactly this.", "\"I did. I don't know how it happened.\""),
                .cross("You held it for five seconds.", "\"It felt like one.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"So any officer can kill someone and call it a 'motor program'?\"",
                                  answer: "\"That's not what I said.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "The question argues with the expert instead of asking about facts or opinions.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Twenty-six years of training, a yellow Taser on the left, and a black gun on the right.",
            defenseOpening: "\"Taser! Taser! Taser!\" She believed it.",
            prosecutionClosing: "The law asks what a careful officer would have done. Not this.",
            defenseClosing: "A mistake isn't culpable negligence when stress takes over.",
            genders: ["D": .female, "V": .male]
        )
    )

    // MARK: - 82. The movie set (a live round in a prop gun)

    static let movieSetGun = CaseTemplate(
        key: "story.movieSetGun", category: .violent,
        headlines: ["Cinematographer Killed by Prop Gun on Film Set", "Armorer Charged After Live Round Found in Prop Revolver"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "By culpable negligence in handling firearms on a film set, unintentionally caused the death of {V}.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by handing a bag of possible evidence to a crew member after the shooting.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...30, occupations: ["film set armorer"], hasVictim: true,
        summaries: [
            "On {DATE}, during a rehearsal for a western being filmed on a ranch outside {HOOD}, the lead actor pointed a revolver toward the camera while practicing a draw. It fired a live round that killed {V}, the cinematographer, and wounded the director. {D} was the film's armorer, responsible for every gun and round on set. Investigators found six live rounds mixed with dummy rounds in the ammunition box and on a cart. {DL} says {D.he} checked the gun that morning, that the assistant director handed it to the actor without {DL}, and that the live rounds came from a supplier's box labeled dummies."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Live Rounds", "Six live rounds found among dummy rounds in the ammunition box and on the prop cart."),
            E(.statement, 2, "Crew Testimony", "Crew members say {DL} left the revolver on a cart during lunch, unsecured, and didn't shake-check the rounds after."),
            E(.document, 2, "Safety Complaints", "Two earlier accidental discharges on set in the prior week, and an email from a crew member warning of unsafe handling."),
            E(.statement, 1, "Bag Handoff", "A crew member says {DL} handed off a small bag minutes after the shooting and asked them to hold it.")
        ],
        defenseEvidence: [
            E(.document, 2, "Supplier Box", "The ammunition box from the supplier was labeled \"dummy\" and contained live rounds of the same brand found on set."),
            E(.statement, 2, "Assistant Director", "The assistant director, who handed the gun to the actor, admitted calling it a \"cold gun\" without checking."),
            E(.document, 1, "Dual Role", "Production hired {DL} as both armorer and props assistant, cutting armorer time to half."),
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Firearms safety expert",
                        direct: ["\"An armorer's first job is to keep live rounds off set.\""],
                        cross: ["\"The assistant director broke protocol too.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does an armorer do?", "\"Controls every gun and every round. Live ammunition never comes on a set. Every round loaded is shaken, looked at, and shown to the actor.\""),
                            .direct("What went wrong here?", "\"Live rounds were mixed with dummies, the gun was left unsecured, and it wasn't checked again before it went to the actor.\""),
                            .cross("The assistant director handed over the gun and called it cold without checking?", "\"That's a failure too.\""),
                            .cross("Production gave {DL} two jobs?", "\"I understand {DL} was stretched.\"")
                        ]),
            WitnessSeed(name: nil, role: "Prop master",
                        direct: ["\"{DL} left the guns on the cart at lunch.\""],
                        cross: ["\"I didn't see who loaded the live round.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see that day?", "\"At lunch, the guns were on the cart outside the church set, unlocked. {DL} was eating with the crew.\""),
                            .direct("What happened after the shooting?", "\"{DL} handed me a little bag and said hold this. I gave it to a deputy later. It had some drugs in it.\""),
                            .cross("You didn't see who put a live round in the gun?", "\"No.\""),
                            .cross("The box from the supplier was labeled dummy?", "\"That's what it said on it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Film set armorer with 30 years' experience",
                        direct: ["\"No one person can catch everything on a rushed set.\""],
                        cross: ["\"The armorer is the last line.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What about this production concerns you?", "\"Half-time armorer, crew walking off over safety, rehearsals moving without the armorer present. That's a production that put schedule over safety.\""),
                            .cross("The armorer is still responsible for keeping live rounds off set?", "\"The armorer is the last line. Not the only line.\""),
                            .cross("Would you have left the guns on a cart at lunch?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was responsible for every round on set, let live ammunition mix with dummies, left guns unsecured, and didn't check the gun before it went to the actor."],
        defenseTheory: ["A rushed production gave {DL} two jobs, a supplier mislabeled live rounds, and the assistant director handed over the gun without {DL}. Many people failed; the State chose the youngest."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s spouse: \"Our son was nine. He asks why a movie was worth it.\""],
        allocutions: ["\"I would give anything to undo that day. I did my best with what they gave me.\""],
        guiltyTruths: ["A crew member later testified seeing {DL} use live rounds for target practice with the same revolver off set."],
        innocentTruths: ["The supplier's records later showed it had shipped a mixed box of live and dummy rounds to two other productions."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-6, "Two accidental discharges on set; safety email sent."),
                       (0, "1:46 p.m.: revolver fires during rehearsal; {VL} killed."),
                       (1, "Search of the set; live rounds found."),
                       (90, "FBI lab confirms live rounds; supplier box tested."),
                       (120, "{DL} charged.")],
            howIdentified: "{DL} was the armorer in charge of every firearm on set.",
            notDone: ["The supplier was never charged or fully investigated."],
            defendantExam: [
                .direct("Did you load the revolver that morning?", "\"Yes, with dummies from the box labeled dummies. I shook every one.\""),
                .direct("Why weren't you there when it was handed to the actor?", "\"I was doing my other job, props, across the set. They started without calling me.\""),
                .cross("You left the guns on a cart at lunch.", "\"In view of the crew, for an hour.\""),
                .cross("You handed off a bag after the shooting.", "\"It was personal. It had nothing to do with the gun.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"What was in the bag {DL} handed you?\"",
                                  answer: "\"Cocaine, I think.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Unfair prejudice", shouldSustain: true,
                                  explanation: "Drugs in a bag have no bearing on how the round got into the gun and invite conviction for bad character (Rule 403).",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Every round on that set was {DL}'s responsibility. One was live.",
            defenseOpening: "A production that cut corners, a mislabeled box, and a gun handed over without the armorer.",
            prosecutionClosing: "The armorer's one job is no live rounds. That failure killed {VL}.",
            defenseClosing: "Many failures caused this. Culpable negligence requires more than being the youngest person on set."
        )
    )

    // MARK: - 83. The hot car (a toddler left in a car seat)

    static let hotCarDeath = CaseTemplate(
        key: "story.hotCarDeath", category: .violent,
        headlines: ["Toddler Dies in Hot Car Outside Parent's Office", "Prosecutors Say Parent's Secret Life Was the Motive"],
        primaryLaw: "murder1", lesserLaw: "invManslaughter", threshold: 6, lesserThreshold: 4,
        specification: "With premeditation and deliberation, killed {KID}, age 22 months, by leaving the child in a hot car.",
        secondary: [
            SecondaryCharge(lawID: "felonyChildAbuse", specification: "Inflicted serious physical injury on {KID} by leaving the child in a car for seven hours in 92-degree heat.", chance: 1.0, threshold: 0)
        ],
        ageRange: 30...36, occupations: ["software developer"], hasVictim: false,
        summaries: [
            "On {DATE}, {D} buckled 22-month-old {KID} into a rear-facing car seat, stopped for breakfast with {KID}, and drove past the day care to an office park in {HOOD}. {KID} died in the car over the next seven hours in 92-degree heat. At lunch, {DL} opened the driver's door to put a bag inside. That afternoon {DL} drove a mile, pulled over screaming, and pulled {KID} out. Investigators found {DL} had searched \"how hot does a car get\" and a child-free lifestyle forum in the weeks before, and that {DL} was messaging several women, including a 16-year-old, during the hours {KID} was dying. {DL} says it was a tragic memory failure."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Search History", "Searches for \"how hot does a car get to kill\" and visits to a child-free forum in the prior month.", .search),
            E(.digital, 3, "Messages During the Day", "Sexually explicit messages to six women, including a 16-year-old, while {KID} was in the car.", .search),
            E(.document, 2, "Life Insurance", "Two life insurance policies on {KID}, one bought six months earlier."),
            E(.video, 2, "Lunch Visit", "Parking lot camera shows {DL} opening the driver's door at 12:42 p.m., leaning in, and closing it.")
        ],
        defenseEvidence: [
            E(.document, 3, "Memory Science", "Research documenting dozens of cases a year of loving parents forgetting children in cars after a change in routine."),
            E(.statement, 2, "Witnesses to Grief", "Bystanders who saw {DL} pull {KID} from the car describe screaming, CPR, and collapse."),
            E(.document, 1, "Policy Through Employer", "The newer life insurance policy was an automatic employer benefit enrollment.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{DL} was sexting while {KID} died.\""],
                        cross: ["\"I can't read minds.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did {DL}'s phone show?", "\"Searches about heat deaths in cars a month before, and all day long, explicit messages with six women, including a sixteen-year-old. {DL} wrote one, 'I love my son but we all need escapes.'\""),
                            .direct("What did the lunch visit show?", "\"{DL} opened the driver's door and leaned in to put a bag on the seat. The car seat was right behind {D.him}, at head height.\""),
                            .cross("The car seat was rear-facing and {KID} was small?", "\"It was rear-facing.\""),
                            .cross("You can't say what {DL} saw when leaning in?", "\"I can say where the seat was.\"")
                        ]),
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"Hyperthermia, over hours.\""],
                        cross: ["\"No other injuries.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did {KID} die?", "\"Hyperthermia. The car's interior would have reached about 130 degrees. Death took hours.\""),
                            .cross("No other injuries on the child?", "\"None. No signs of abuse.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Memory scientist",
                        direct: ["\"Prospective memory fails without warning.\""],
                        cross: ["\"It doesn't explain the searches.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How can a parent forget a child in a car?", "\"The habit system takes over on a familiar drive, and the plan to stop at day care drops out of awareness. It happens to devoted parents of every kind. The brain then 'remembers' the child is at day care.\""),
                            .cross("Memory failure doesn't explain searching how hot a car gets to kill?", "\"No. That's not my field.\""),
                            .cross("Or opening the car door at lunch with the child behind?", "\"A rear-facing seat can be invisible from the front.\"")
                        ])
        ],
        prosecutionTheory: ["{D} wanted out of family life, researched how a child dies in a hot car, left {KID} there, and spent the day sexting while {KID} died."],
        defenseTheory: ["A devastating memory failure that has happened to hundreds of loving parents. {DL}'s private life is ugly but it isn't proof {D.he} killed {D.his} child on purpose."],
        aggravating: ["The victim was very young", "The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{KID}'s grandparent: \"He was the happiest baby. He waved at every truck.\""],
        allocutions: ["\"I loved my son. I would trade my life for his.\""],
        guiltyTruths: ["A deleted message recovered from {DL}'s laptop said, \"Soon I'll be free of all of it.\""],
        innocentTruths: ["The searches were later traced to {DL}'s spouse, who was researching a news story after a neighbor's child died the same way."],
        moods: [.divided], doctrines: ["burdenOfProof", "priorActs"],
        extras: ["KID": ["Cooper", "Mason", "Eli"]],
        story: StoryExtras(
            timeline: [(-30, "Search: 'how hot does a car get to kill.'"),
                       (0, "9:15 a.m.: breakfast stop with {KID}; drives past day care."),
                       (0, "12:42 p.m.: {DL} opens the car door at lunch."),
                       (0, "4:16 p.m.: {DL} pulls over and removes {KID}; pronounced dead at 4:40 p.m."),
                       (2, "Phone and computer searched under warrant."),
                       (21, "{DL} indicted.")],
            howIdentified: "{DL} discovered the child and called for help.",
            notDone: ["The spouse's devices were never examined."],
            defendantExam: [
                .direct("What happened that morning?", "\"We had breakfast. I was thinking about a work problem. I drove to work the way I always do. In my head, he was at day care.\""),
                .direct("Why did you search about hot cars?", "\"I'd seen a news story. I was scared it could happen to us.\""),
                .cross("You were messaging a sixteen-year-old while your son died.", "\"I'm ashamed of that. It doesn't make me a murderer.\""),
                .cross("You opened the door at lunch with your son right behind you.", "\"I didn't see him. I wish to God I had.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Tell us about the explicit photos {DL} sent that day.\"",
                                  answer: "\"There were dozens, some to the minor.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Unfair prejudice", shouldSustain: false,
                                  explanation: "The messages bear on the State's theory of motive, a desire to escape family life; the court may limit details but the evidence is admissible for that purpose.",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "A search for how hot a car gets, a lunch visit to the car, and a day of messages while a baby died.",
            defenseOpening: "A loving parent, a broken routine, and a memory failure that happens every summer.",
            prosecutionClosing: "Forgetting doesn't search for how to kill.",
            defenseClosing: "Shameful isn't the same as guilty of murder.",
            when: .months([6, 7, 8]),
            genders: ["D": .male]
        )
    )
}
