import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchX: [CaseTemplate] = [deedForgery, halloweenPorch, tractorDWI, pillPress, pensionMother]

    // MARK: - 129. The empty lot (a forged deed and a sale to a stranger)

    static let deedForgery = CaseTemplate(
        key: "story.deedForgery", category: .whiteCollar,
        headlines: ["Out-of-State Owner Finds Her Land Sold Without Her", "Forged Deed Scheme: Buyer Paid $62,000 for Lot Seller Didn't Own"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Obtained $62,000 from {BUYER} by falsely representing that {D.he} had authority to sell a waterfront lot in {HOOD} owned by {V}.",
        secondary: [
            SecondaryCharge(lawID: "forgery", specification: "Falsely made a general warranty deed bearing the signature of {V}.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "uttering", specification: "Presented the forged deed for recording at the Hollis County Register of Deeds, knowing it was forged.", chance: 1.0, threshold: 0)
        ],
        ageRange: 34...60, occupations: ["handyman", "property manager", "self-employed contractor"], hasVictim: true,
        summaries: [
            "{V}, who lives in Ohio, inherited a vacant waterfront lot in {HOOD} and visited it once a year. On {DATE}, {V.he} drove down and found a house foundation being poured on it. The Register of Deeds showed a deed, signed in {V.his} name and notarized, transferring the lot to {BUYER} for $62,000. The sale proceeds went to an account opened by {D}, who had mowed the lot for {V} years earlier and once received a copy of {V.his} driver's license to pay a tax bill. The notary stamp belonged to a notary who died two years before the deed's date. {DL} says {D.he} was hired by a man named \"Ray\" to handle the paperwork and passed the money on to him."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Recorded Deed", "A deed signed \"{V}\" with a notary stamp belonging to a notary who died two years before the signing date."),
            E(.document, 3, "Closing Account", "The $62,000 sale proceeds wired to an account opened by {DL} eleven days before closing; $58,000 withdrawn in cash within a week.", .search),
            E(.document, 2, "Handwriting Comparison", "A document examiner finds the signature on the deed \"probably\" written by {DL}.")
        ],
        defenseEvidence: [
            E(.digital, 2, "Messages With 'Ray'", "Texts on {DL}'s phone from a prepaid number signed \"Ray\" giving closing instructions."),
            E(.statement, 1, "Prior Work", "{DL} had legitimately managed property for other absentee owners for years.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Lot owner",
                        direct: ["\"I never signed anything. I was in Ohio.\""],
                        cross: ["\"I did send {DL} a copy of my license once.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you come to own the lot?", "\"I inherited it. I live in Ohio and get down to see it about once a year.\""),
                            .direct("What did you find when you drove down?", "\"A house foundation being poured on my land.\""),
                            .direct("Did you sign this deed?", "\"No. I've never sold that lot and I was at work in Ohio the day it says I signed.\""),
                            .cross("{DL} used to mow that lot for you?", "\"Years ago, yes.\""),
                            .cross("You once sent {DL} a copy of your driver's license?", "\"Years ago, so {D.he} could pay the property tax for me.\"")
                        ]),
            WitnessSeed(name: "{BUYER}", role: "Buyer of the lot",
                        direct: ["\"I paid sixty-two thousand dollars for land that wasn't for sale.\""],
                        cross: ["\"I never met the owner.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How much did you pay for the lot?", "\"Sixty-two thousand dollars.\""),
                            .direct("Who did you deal with?", "\"Only {DL}. {D.He} said {D.he} managed the lot for an owner up north who wanted a quick cash sale.\""),
                            .direct("What did you do with the land after closing?", "\"Started building. We'd poured the foundation when the owner showed up.\""),
                            .cross("You never met the owner before closing?", "\"No. I never met the owner.\""),
                            .cross("Did {DL} ever mention someone named Ray?", "\"Not once. I never heard that name until court.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Absentee owner {DL} worked for",
                        direct: ["\"{DL} handled my rentals honestly for six years.\""],
                        cross: ["\"I don't know anything about this lot.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} do for you?", "\"Managed my rental property, since I don't live here.\""),
                            .direct("How did {DL} handle your property?", "\"Rent on time, receipts for everything. Six years, never a problem.\""),
                            .direct("Did you ever have reason to doubt {D.his} honesty?", "\"No, never.\""),
                            .cross("You know nothing about this sale?", "\"Nothing.\""),
                            .cross("And you can't say what became of the $58,000 {DL} withdrew in cash?", "\"No, I can't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew the lot, had the owner's license, opened an account for the money, and took nearly all of it out in cash."],
        defenseTheory: ["{DL} was a middleman used by a man named Ray. The State never looked for Ray."],
        aggravating: ["The offense involved a large monetary loss"],
        mitigating: ["The defendant has a record of honest work for other owners"],
        victimImpacts: ["{BUYER}: \"That was my retirement. I paid a builder too, and now the foundation sits on land I don't own.\""],
        allocutions: ["\"I trusted the wrong man.\""],
        guiltyTruths: ["The prepaid phone used by \"Ray\" was bought with {DL}'s debit card."],
        innocentTruths: ["A man using the name Ray Pruett was later arrested in South Carolina for the same scheme on four other lots, using local handymen as fronts."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["BUYER": ["Dale Whitson", "Karen Oyler", "Martin Gaskins"]],
        story: StoryExtras(
            timeline: [(-75, "Account opened by {DL}."), (-64, "Closing; deed recorded."), (-58, "$58,000 withdrawn in cash."), (0, "{VL} finds the foundation."), (35, "Handwriting report; {DL} charged.")],
            howIdentified: "The closing account in {DL}'s name.",
            notDone: ["The prepaid number for \"Ray\" was not subpoenaed for subscriber records."],
            defendantExam: [
                .direct("Who is Ray?", "\"A man I met at a job site. He said he was the owner's nephew and needed help with the sale.\""),
                .cross("You opened the account and took out $58,000 in cash.", "\"I gave it to Ray.\""),
                .cross("You never told the buyer about Ray.", "\"Ray told me not to.\"")
            ],
            prosecutionOpening: "A dead notary's stamp, a forged signature, and $58,000 in cash through {DL}'s hands.",
            defenseOpening: "The man behind this is named Ray, and nobody went looking for him.",
            prosecutionClosing: "Ray is a name on a text. The account, the cash, and the handwriting are {DL}'s.",
            defenseClosing: "The handwriting expert said 'probably.' That isn't proof beyond a reasonable doubt.",
            genders: ["V": .female],
            victim: VictimFacts(relationship: "The defendant once mowed her lot.", restitution: 62000, restitutionBasis: "the $62,000 from the sale of her land")
        )
    )

    // MARK: - 130. The porch (a shotgun on Halloween night)

    static let halloweenPorch = CaseTemplate(
        key: "story.halloweenPorch", category: .violent,
        headlines: ["Homeowner Points Shotgun at Teens on Halloween", "\"They'd Egged My House Three Years Running\""],
        primaryLaw: "assaultPointingGun", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Assaulted {V}, age 15, by pointing a shotgun at {V.him}.",
        secondary: [
            SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened to shoot {V}, saying, \"Next one of you on my porch gets buried,\" in a manner that made {V} believe the threat would be carried out.", chance: 1.0, threshold: 0)
        ],
        ageRange: 55...78, occupations: ["retired welder", "retired trucker", "farmer"], hasVictim: true,
        summaries: [
            "On Halloween night, {DATE}, a group of teenagers walked up {D}'s driveway in {HOOD}. {D}'s house had been egged on Halloween the two previous years. {DL} came out onto the porch with a pump shotgun. {V}, 15, says {DL} pointed it at {V.his} chest and said, \"Next one of you on my porch gets buried.\" A neighbor's doorbell camera recorded the audio and part of the porch. {DL} says the shotgun was unloaded, that {D.he} held it pointed at the ground, and that {D.he} only wanted to scare off kids who had come to vandalize {D.his} house."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Doorbell Camera", "Audio of a voice saying \"Next one of you on my porch gets buried\"; the frame shows the barrel rising toward the teens before the porch post blocks the view.", .search),
            E(.statement, 2, "Three Teens' Statements", "Three of the teens say the barrel was pointed at {VL}'s chest."),
            E(.physical, 1, "Shotgun", "A 12-gauge pump shotgun, unloaded when deputies seized it an hour later.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Prior Vandalism Reports", "Reports of eggs and spray paint on {DL}'s house the two previous Halloweens."),
            E(.physical, 1, "Carton of Eggs", "A carton of eggs found in the ditch by the driveway.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Teen on the driveway",
                        direct: ["\"It was pointed right at me. Right here.\" (The witness touches the center of {V.his} chest.)"],
                        cross: ["\"Somebody had eggs. It wasn't me, I swear.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why were you on that driveway?", "\"It was Halloween. We were just walking around with my friends. Everybody goes down that street.\""),
                            .direct("What did you see when the door opened?", "\"A man came out with a big gun. He held it up at me, like at my chest, and he said the next one of us on his porch gets buried. I didn't even know what to do.\""),
                            .direct("How did you feel?", "\"I thought I was going to die. My legs wouldn't move. I peed a little. I never told anybody that.\"", "\"I thought he was going to shoot me. I couldn't move my legs. I just started crying.\""),
                            .cross("Your group brought eggs?", "\"One kid did. I didn't know till we were already in the driveway. I told him that was dumb.\""),
                            .cross("You have no idea whether that gun was loaded?", "\"How would I know that? I'm fifteen.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "Deputy",
                        direct: ["\"The gun was unloaded when I seized it.\""],
                        cross: ["\"An hour had passed.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("When did you seize the shotgun?", "\"At 9:45, about an hour after the teens were on the driveway.\""),
                            .direct("What did you find?", "\"A pump shotgun leaning by the door, unloaded, and a box of shells on the kitchen table.\""),
                            .direct("What does the doorbell video show?", "\"You hear 'Next one of you on my porch gets buried,' and you see the barrel rise toward the teens before the porch post blocks the view.\""),
                            .cross("You can't say whether it was loaded on the porch?", "\"No. An hour had gone by.\""),
                            .cross("There was a carton of eggs in the ditch by the driveway?", "\"Yes, there was.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Next-door neighbor",
                        direct: ["\"Those kids hit his house every year.\""],
                        cross: ["\"I didn't see where the gun was pointed.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Did you see that damage yourself?", "\"Yes, both years. I live right next door.\""),
                            .direct("What happened the two years before?", "\"Eggs all over the siding and paint on the mailbox. He cleaned it up himself, both times.\""),
                            .direct("What did you notice this Halloween?", "\"Yelling over at {DL}'s place.\""),
                            .cross("You didn't see the porch that night?", "\"Only heard yelling.\""),
                            .cross("So you can't say where the gun was pointed?", "\"No. I didn't see where it was pointed.\"")
                        ])
        ],
        prosecutionTheory: ["Whatever the teens planned, pointing a shotgun at a fifteen-year-old's chest and threatening to bury {V.him} is an assault and a threat."],
        defenseTheory: ["{DL} held an unloaded gun pointed at the ground and spoke harshly to vandals. The doorbell camera never shows the gun aimed at anyone."],
        aggravating: ["The victim was very young"],
        mitigating: ["The defendant was provoked by repeated vandalism", "No prior criminal record"],
        victimImpacts: ["{VL}'s parent: \"My child sleeps with the light on now. Over eggs.\""],
        allocutions: ["\"I'm too old for this. I wanted them to leave me alone. I'd never shoot a child.\""],
        guiltyTruths: ["{DL} told a neighbor the next morning, \"I put the bead right on that kid's chest. They won't be back.\""],
        innocentTruths: ["A second doorbell camera across the street, found later, shows the barrel pointed at the porch floor throughout."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-730, "First Halloween vandalism report."), (-365, "Second Halloween vandalism report."), (0, "8:40 p.m.: teens on the driveway."), (0, "9:45 p.m.: deputies seize the shotgun."), (7, "Doorbell video obtained; {DL} charged.")],
            howIdentified: "The homeowner.",
            notDone: ["Not every teen in the group was interviewed."],
            defendantExam: [
                .direct("Did you point the gun at anyone?", "\"No. I held it low. I wanted them to see it.\""),
                .cross("\"Next one of you on my porch gets buried.\" Those were your words?", "\"I was angry.\""),
                .cross("The camera shows the barrel rising.", "\"I lifted it up off the floor. Not at anybody.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"You and your friends had planned to egg the house, hadn't you?\"",
                                  answer: "\"Some of them had.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "The teens' purpose bears on what {DL} perceived and on provocation, so the question is relevant.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Eggs are vandalism. A shotgun pointed at a child is an assault.",
            defenseOpening: "An old homeowner who'd had enough, and an unloaded gun held low.",
            prosecutionClosing: "The camera caught the words and the barrel rising. That's enough.",
            defenseClosing: "Nobody can see where the gun was pointed. That's reasonable doubt.",
            when: .window(month: 10, days: 31...31),
            genders: ["D": .male],
            victim: VictimFacts(relationship: "A trick-or-treater; no prior contact with the defendant.", restitution: 0),
            residence: "Owns the house in {HOOD} where this happened; has lived there for decades."
        )
    )

    // MARK: - 131. The tractor (an impaired farmer on the highway)

    static let tractorDWI = CaseTemplate(
        key: "story.tractorDWI", category: .traffic,
        headlines: ["Farmer Charged With DWI on Tractor", "Tractor on Highway 17 Forces Cars Into Ditch"],
        primaryLaw: "dwi", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Drove a vehicle, a farm tractor, on Highway 17 while under the influence of an impairing substance and with an alcohol concentration of 0.08 or more.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove a farm tractor on Highway 17 carelessly and heedlessly in willful disregard of the rights and safety of others, crossing the center line twice.", chance: 1.0, threshold: 0)
        ],
        ageRange: 48...72, occupations: ["farmer", "dairy farmer", "tobacco farmer"], hasVictim: false,
        summaries: [
            "At 6:10 p.m. on {DATE}, two drivers on Highway 17 near {HOOD} swerved into the ditch to avoid a farm tractor crossing the center line. {TROOPER} stopped the tractor a mile on. {D} was driving it home from a friend's barbecue. The trooper smelled alcohol and saw red, glassy eyes; {DL} swayed on the clean-up walk test and refused the others. {D.His} breath test at the station, an hour and forty minutes later, was 0.09. {DL} says a tractor on a farm road isn't the same as a car, that {D.he} had two beers, and that the steering on the old tractor pulls left."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Breath Test", "0.09 on the Intox EC/IR II, 7:52 p.m."),
            E(.video, 2, "Dash Camera", "The tractor crossing the center line twice, and two cars swerving onto the shoulder."),
            E(.statement, 2, "Trooper's Observations", "Odor of alcohol, red glassy eyes, swaying, and refusal of field sobriety tests.")
        ],
        defenseEvidence: [
            E(.document, 2, "Repair Invoice", "A mechanic's invoice from the previous spring noting the tractor's steering \"pulls hard left; needs kingpins.\""),
            E(.statement, 1, "Barbecue Host", "The host says {DL} had two beers over three hours with a plate of food.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{TROOPER}", role: "State Highway Patrol trooper",
                        direct: ["\"0.09, an hour and forty minutes after driving.\""],
                        cross: ["\"I didn't drive the tractor myself.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Why did you stop the tractor?", "\"I watched it cross the center line twice and two cars swerve onto the shoulder. My dash camera recorded it.\""),
                            .direct("What did you observe?", "\"Strong odor of alcohol, red glassy eyes, and swaying. {DL} refused the walk-and-turn and one-leg stand.\""),
                            .direct("And the breath test?", "\"0.09, after the required observation period, at 7:52.\""),
                            .cross("You never tested the tractor's steering?", "\"No. I watched it cross the line twice.\""),
                            .cross("The breath test came an hour and forty minutes after the driving?", "\"Yes.\"")
                        ]),
            WitnessSeed(name: nil, role: "Driver forced off the road",
                        direct: ["\"It came right into my lane.\""],
                        cross: ["\"It was going maybe fifteen miles an hour.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you driving?", "\"On Highway 17, a little after six in the evening.\""),
                            .direct("What happened?", "\"The tractor drifted over the center line right at me. I went into the ditch.\""),
                            .direct("Were you the only one who had to swerve?", "\"No. Another car went off too.\""),
                            .cross("How fast was it going?", "\"Slow. Fifteen, maybe. It was huge, though.\""),
                            .cross("You don't know why the tractor drifted over?", "\"No. I just saw it coming at me.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Farm equipment mechanic",
                        direct: ["\"That steering pulls hard left.\""],
                        cross: ["\"A sober driver can correct for it.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Did you put that in writing?", "\"Yes. My invoice from last spring says it pulls hard left and needs kingpins.\""),
                            .direct("What's wrong with the tractor?", "\"Worn kingpins. It pulls hard left, and I told {DL} so last spring.\""),
                            .cross("You didn't look at the tractor after the stop?", "\"No, I didn't.\""),
                            .cross("Can a careful, sober driver keep it in the lane?", "\"With effort, yes.\"")
                        ])
        ],
        prosecutionTheory: ["A tractor on a highway is a vehicle, and {D} drove it there at 0.09 and across the center line twice."],
        defenseTheory: ["Two beers with food, a breath test long after driving, and a tractor whose steering pulls left. The State can't prove impairment while driving."],
        aggravating: [],
        mitigating: ["No prior impaired driving convictions", "The defendant has completed a substance abuse assessment"],
        allocutions: ["\"I've farmed that road forty years. I shouldn't have had anything to drink. It won't happen again.\""],
        guiltyTruths: ["The barbecue host later admitted {DL} drank most of a bottle of bourbon."],
        innocentTruths: ["The Intox instrument failed its next scheduled calibration check, reading high by 0.02."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "6:10 p.m.: tractor crosses the center line."), (0, "6:14 p.m.: traffic stop."), (0, "7:52 p.m.: breath test, 0.09."), (14, "Charge filed in district court; appealed to superior court.")],
            howIdentified: "{DL} was driving when stopped.",
            notDone: ["The tractor's steering was not inspected."],
            defendantExam: [
                .direct("How much did you drink?", "\"Two beers, over the afternoon, with barbecue.\""),
                .cross("You refused the field tests.", "\"I've got bad knees. I wasn't going to walk a line on the shoulder.\""),
                .cross("0.09, nearly two hours later.", "\"I can't explain the machine.\"")
            ],
            prosecutionOpening: "A tractor is a vehicle. {DL} drove it impaired, and two drivers ended up in a ditch.",
            defenseOpening: "Two beers, bad steering, and a test taken long after the drive.",
            prosecutionClosing: "Alcohol rises and falls slowly. 0.09 at 7:52 means impaired at 6:10.",
            defenseClosing: "Worn kingpins explain the line. Two beers don't make 0.09.",
            scene: "Highway 17 near {HOOD}"
        )
    )

    // MARK: - 132. The pill press (counterfeit pills in a rented garage)

    static let pillPress = CaseTemplate(
        key: "story.pillPress", category: .drugs,
        headlines: ["Pill Press Seized in Rented Garage; 4,000 Counterfeit Pills Found", "Fake Oxycodone Pressed With Fentanyl, Agents Say"],
        primaryLaw: "traffickingOpioid28", lesserLaw: "traffickingOpioid", threshold: 11, lesserThreshold: 9,
        specification: "Trafficked in opioids by manufacturing and possessing 28 grams or more of a mixture containing fentanyl.",
        secondary: [
            SecondaryCharge(lawID: "maintainingDwelling", specification: "Knowingly kept and maintained a house in {HOOD} for the purpose of manufacturing and keeping controlled substances.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...40, occupations: ["auto detailer", "unemployed", "tattoo artist"], hasVictim: false,
        summaries: [
            "After three overdoses in {HOOD} in one week, all from blue pills stamped \"M 30,\" detectives traced purchases to a house on {STREET} that {D} rented. On {DATE}, deputies executed a search warrant. In the detached garage they found a tabletop pill press, blue dye, binder powder, a digital scale, and two bags holding 4,000 pressed pills weighing 412 grams; lab testing found fentanyl in the mixture. {DL}'s fingerprints were on the press and the scale. {DL} says {D.his} roommate ran the garage, that {D.he} touched the press only to move it, and that the warrant's informant was unreliable."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Pill Press and Pills", "A tabletop pill press, dye, binder, and 4,000 pills totaling 412 grams, recovered from the garage.", .search),
            E(.forensic, 3, "Lab Results", "The State Crime Laboratory found fentanyl in a representative sample of the pills.", .search),
            E(.forensic, 2, "Fingerprints", "{DL}'s prints on the press lever and the scale's display.", .search),
            E(.document, 2, "Lease", "The house and garage leased in {DL}'s name alone.")
        ],
        defenseEvidence: [
            E(.statement, 2, "The Roommate", "A roommate, not on the lease, lived in the house and had a key to the garage."),
            E(.document, 1, "Informant's Record", "The informant whose tip supported the warrant had two pending charges and was paid $300.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Narcotics detective",
                        direct: ["\"A working pill press with fentanyl residue.\""],
                        cross: ["\"The roommate was gone when we arrived.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did the investigation lead to that house?", "\"Three overdoses in one week, all from blue 'M 30' pills. We traced purchases to the house and made a controlled buy there.\""),
                            .direct("What was in the garage?", "\"A pill press set up on a workbench, blue dye, binder, a scale, and two bags of finished pills.\""),
                            .direct("Whose fingerprints were found?", "\"{DL}'s, on the press lever and on the scale's display.\""),
                            .cross("A roommate lived there too?", "\"Someone did. He left the week before the warrant and we haven't found him.\""),
                            .cross("The informant who made that buy had two pending charges and was paid $300?", "\"Yes. It was still a controlled buy.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic chemist, State Crime Laboratory",
                        direct: ["\"Fentanyl, in a 412-gram mixture.\""],
                        cross: ["\"I tested a representative sample, not every pill.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you receive for testing?", "\"Two bags of blue pressed pills, 4,000 in all.\""),
                            .direct("What did you find?", "\"The pills were consistent in appearance, and the representative sample contained fentanyl. Total weight 412 grams.\""),
                            .direct("What is fentanyl?", "\"A synthetic opioid, far stronger than the oxycodone these pills were made to look like.\""),
                            .cross("You didn't test all 4,000 pills?", "\"No. Our accredited sampling method tests a statistically chosen subset.\""),
                            .cross("Your testing can't tell us who pressed these pills?", "\"No. Only what's in them.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor",
                        direct: ["\"The roommate was in that garage every night.\""],
                        cross: ["\"I saw {DL} go in sometimes too.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Can you see that garage from your house?", "\"Yes. I can see the garage light from my window.\""),
                            .direct("Did the roommate live at the house?", "\"Yes, he did.\""),
                            .direct("Who used the garage?", "\"The roommate. Light on until two or three in the morning.\""),
                            .cross("You never saw what anyone was doing inside?", "\"No. Just the light on.\""),
                            .cross("Did you ever see {DL} go in?", "\"Sometimes, yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} leased the house, {D.his} prints were on the press and the scale, and the garage made thousands of fentanyl pills."],
        defenseTheory: ["The roommate ran the garage and vanished. Prints on a machine {DL} moved don't prove {D.he} knew what it made."],
        aggravating: ["The offense endangered public safety"],
        mitigating: [],
        allocutions: ["\"I knew he was doing something out there. I didn't know it was that.\""],
        guiltyTruths: ["{DL}'s phone held a photo of a finished batch with the caption \"2k ready.\""],
        innocentTruths: ["The roommate was arrested in Georgia with a second press and admitted {DL} never knew what he was making."],
        moods: [.wantsConviction], doctrines: ["searchSeizure", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(-10, "Three overdoses from blue \"M 30\" pills."), (-4, "Informant buys pills at the house."), (0, "Search warrant executed."), (45, "Lab confirms fentanyl; {DL} indicted.")],
            howIdentified: "A controlled buy at the house and the lease in {DL}'s name.",
            notDone: ["The roommate's identity was never confirmed."],
            defendantExam: [
                .direct("What was the press for?", "\"My roommate said it made vitamins for his gym.\""),
                .cross("Your prints are on the lever.", "\"I moved it off the floor once.\""),
                .cross("The lights were on in that garage every night and you never asked?", "\"I didn't want to know.\"")
            ],
            prosecutionOpening: "A press, dye, and 4,000 pills of fentanyl in {DL}'s garage, with {DL}'s prints on the lever.",
            defenseOpening: "A roommate's operation in a garage {DL} rarely entered.",
            prosecutionClosing: "Constructive possession: {D.his} house, {D.his} prints, {D.his} garage.",
            defenseClosing: "Knowledge is an element. The State proved the roommate's knowledge, not {DL}'s.",
            residence: "Rents the house on {STREET} in {HOOD} where the press was found."
        )
    )

    // MARK: - 133. The pension (a mother's death hidden)

    static let pensionMother = CaseTemplate(
        key: "story.pensionMother", category: .family,
        headlines: ["Woman's Body Found in Home Months After Death; Pension Kept Coming", "Adult Child Charged With Concealing Mother's Death"],
        primaryLaw: "concealingDeath", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Failed to notify law enforcement of the death of {V}, with the intent to conceal the death.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $26,400 in state retirement payments by falsely representing that {V} was alive, including by signing {V.his} name to an annual benefit verification form.", chance: 1.0, threshold: 0)
        ],
        ageRange: 45...62, occupations: ["unemployed", "part-time cashier", "freelance graphic designer"], hasVictim: true,
        summaries: [
            "{V}, 84, a retired schoolteacher, lived with {V.his} adult child, {D}, in {HOOD}. When a neighbor hadn't seen {VF} in months, deputies made a welfare check on {DATE}. They found {VF}'s remains in a locked back bedroom. The medical examiner estimated death about eight months earlier, from heart disease, with no sign of injury. In those eight months, $26,400 in {VF}'s state teacher pension had been deposited and spent from a joint account, and an annual verification form, due in the spring, was signed with {VF}'s name. {DL} says {D.he} froze when {D.his} mother died, couldn't face it, and used the money to keep the house."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Autopsy Report", "Death about eight months before discovery from atherosclerotic heart disease; no trauma."),
            E(.document, 3, "Pension Records", "Eight monthly deposits totaling $26,400 after the estimated date of death, and a benefit verification form signed in {VF}'s name.", .search),
            E(.document, 2, "Bank Records", "The deposits spent on utilities, groceries, and {DL}'s car payment.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Mental Health Records", "{DL} was treated for severe depression for years before {D.his} mother's death."),
            E(.statement, 1, "Joint Account", "The account had been joint for a decade, and {DL} paid the household bills from it.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"Natural death, about eight months earlier.\""],
                        cross: ["\"Nothing suggests {VF} was harmed.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What examination did you perform?", "\"A full autopsy, three days after the remains were found.\""),
                            .direct("How and when did {VF} die?", "\"Heart disease. The condition of the remains puts death about eight months before discovery.\""),
                            .direct("What kind of heart disease?", "\"Atherosclerotic heart disease. Hardening of the arteries.\""),
                            .cross("No sign of injury or neglect causing death?", "\"None. This was a natural death.\""),
                            .cross("So nothing {DL} did caused {D.his} mother's death?", "\"Nothing I found.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The bedroom door was locked and the vents taped.\""],
                        cross: ["\"{DL} cried when we found {D.him}.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you go to the house?", "\"A neighbor hadn't seen {VF} in months, so we made a welfare check.\""),
                            .direct("What did you find in the house?", "\"A back bedroom locked from the outside, towels under the door, and the air vents taped over.\""),
                            .direct("And the verification form?", "\"Signed in {VF}'s name in April, months after the death.\""),
                            .cross("How did {DL} react?", "\"{D.He} broke down and said, 'I couldn't say it out loud.'\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Psychiatrist",
                        direct: ["\"Severe depression can freeze a person.\""],
                        cross: ["\"Signing the form required a decision.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What do {DL}'s records show?", "\"Years of treatment for severe depression, well before {D.his} mother died.\""),
                            .direct("How did {DL}'s depression affect {D.him}?", "\"Profoundly. Avoidance is a hallmark. Some people cannot act on a loss at all.\""),
                            .direct("Can a person in that state still handle daily tasks?", "\"Yes. Bills and groceries can go on while the larger loss goes untouched.\""),
                            .cross("Signing your mother's name on a pension form is a decision, isn't it?", "\"It is a decision. It can be made in a very disordered state.\""),
                            .cross("And the pension money also went to {DL}'s car payment?", "\"That's what the bank records show.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sealed {D.his} mother's room, taped the vents, kept her pension coming, and signed her name to keep it coming."],
        defenseTheory: ["Grief and severe depression, not a scheme. {DL} lived on a joint account {D.he} had always used for the household."],
        aggravating: [],
        mitigating: ["The defendant suffered from a mental or physical condition that reduced culpability", "No prior criminal record"],
        victimImpacts: ["{VF}'s sister: \"Nobody got to say goodbye. Nobody got to bury her.\""],
        allocutions: ["\"I couldn't lose her. So I pretended I hadn't.\""],
        guiltyTruths: ["{DL} had searched online, the week after the death, \"how long can pension keep paying after death.\""],
        innocentTruths: ["{DL}'s treating doctor recorded a psychotic depressive episode that month, with {DL} believing {D.his} mother was still alive."],
        moods: [.sympathetic], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-240, "Estimated date of {VF}'s death."), (-150, "Benefit verification form signed in {VF}'s name."), (0, "Welfare check; remains found."), (3, "Autopsy."), (30, "Pension records subpoenaed; {DL} charged.")],
            howIdentified: "{DL} lived in the home.",
            notDone: ["No psychological evaluation was ordered before charging."],
            defendantExam: [
                .direct("Why didn't you call anyone?", "\"I kept thinking tomorrow. Then it was months.\""),
                .cross("You signed your mother's name on the form.", "\"My mother's name. She'd been gone for months by then. I kept the house going.\""),
                .cross("You taped the vents.", "\"Because of the smell. I didn't want the neighbors to know.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"In your experience, do people who hide a death usually do it for money?\"",
                                  answer: "\"Usually, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation; improper opinion", shouldSustain: true,
                                  explanation: "What other people usually intend says nothing about this defendant's intent.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A locked door, taped vents, and eight pension checks.",
            defenseOpening: "A grieving, mentally ill child who could not face a mother's death.",
            prosecutionClosing: "Grief doesn't sign a dead woman's name.",
            defenseClosing: "Intent to conceal is an element. Illness isn't intent.",
            genders: ["V": .female],
            victim: VictimFacts(relationship: "The defendant's mother; they lived together."),
            residence: "Lived in {VF}'s house on {STREET} in {HOOD}.",
            sameSurname: true
        )
    )
}
