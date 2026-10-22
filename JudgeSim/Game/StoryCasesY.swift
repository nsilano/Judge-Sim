import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchY: [CaseTemplate] = [beachTrip, footballRiot, dragRaceDeath, deerCampFelon, coachCyberstalking]

    // MARK: - 134. The beach trip (a parent takes a child out of state)

    static let beachTrip = CaseTemplate(
        key: "story.beachTrip", category: .family,
        headlines: ["Parent Takes Child to Florida in Violation of Custody Order", "Amber Alert Canceled After Child Found Safe at Motel"],
        primaryLaw: "transportChild", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Transported {KID}, age 7, outside North Carolina with the intent to violate a custody order of the Hollis County District Court awarding primary custody to {V}.",
        secondary: [],
        ageRange: 27...44, occupations: ["restaurant manager", "truck driver", "hair stylist", "warehouse worker"], hasVictim: true,
        summaries: [
            "Under a custody order entered eight months earlier, {V} had primary custody of their child, {KID}, 7, and {D} had every other weekend. On Friday, {DATE}, {DL} picked {KID} up for a weekend visit and did not return Sunday. {DL}'s phone was off. On Tuesday, police in Daytona Beach found the two at a motel after the Amber Alert. {DL} had withdrawn $3,000, enrolled {KID} in no school, and told the motel clerk they were \"moving down for good.\" {DL} says it was a spur-of-the-moment beach trip, that {D.he} meant to come back, and that {D.he} turned the phone off because {V} kept sending threatening messages."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Custody Order", "A district court order awarding {VL} primary custody and {DL} alternate weekends, with no travel outside North Carolina without written consent."),
            E(.statement, 2, "Motel Clerk", "The clerk says {DL} asked about weekly rates and said they were \"moving down for good.\""),
            E(.document, 2, "Bank Withdrawal", "{DL} withdrew $3,000 in cash, nearly all of {D.his} savings, the Thursday before the visit.", .search)
        ],
        defenseEvidence: [
            E(.digital, 2, "Messages From {VL}", "Messages from {VL} that weekend: \"You'll never see {KID} again after court.\""),
            E(.document, 1, "Return Plan", "A note in {DL}'s car listing \"back by Wed?\" and a school supply list.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Custodial parent",
                        direct: ["\"Sunday came and went. I called the police that night.\""],
                        cross: ["\"I was angry when I sent those messages.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened that weekend?", "\"{DL} was supposed to bring {KID} back Sunday at six. By eight I'd called fifteen times. The phone was off.\""),
                            .cross("You told {DL} {D.he}'d never see {KID} again?", "\"I said it after {D.he} stopped answering. I was terrified.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective, missing persons",
                        direct: ["\"{DL} asked the clerk about weekly rates.\""],
                        cross: ["\"{KID} was safe and happy.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you learn in Florida?", "\"{DL} had paid a week in advance and asked about monthly rates. The clerk said {D.he} told her they were moving down.\""),
                            .cross("{KID} was healthy and unharmed?", "\"Yes. Playing in the motel pool when officers arrived.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s sibling",
                        direct: ["\"{DL} told me they'd be back Wednesday.\""],
                        cross: ["\"I didn't know about the custody order's travel limits.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That {D.he} was taking {KID} to the beach for a few days and would be back by Wednesday.\""),
                            .cross("Wednesday is three days past the end of the visit?", "\"I guess it is.\"")
                        ])
        ],
        prosecutionTheory: ["{D} emptied {D.his} savings, turned off {D.his} phone, crossed three states, and told a clerk they were moving for good."],
        defenseTheory: ["A badly judged beach trip by a parent being threatened with losing {D.his} child. {DL} planned to come back."],
        aggravating: [],
        mitigating: ["The child was unharmed", "The defendant has no prior criminal record"],
        victimImpacts: ["{V}: \"Three days I didn't know if my child was alive.\""],
        allocutions: ["\"I was scared of losing {KID}. I know I did it the wrong way.\""],
        guiltyTruths: ["{DL} had applied for jobs in Daytona Beach the week before the visit."],
        innocentTruths: ["{DL} had bought return bus tickets for Wednesday, found later in the motel safe."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["KID": ["Mason", "Ella", "Liam", "Sophie"]],
        story: StoryExtras(
            timeline: [(-1, "{DL} withdraws $3,000."), (0, "Friday: {DL} picks up {KID}."), (2, "Sunday 6 p.m.: {KID} not returned."), (2, "Sunday 8 p.m.: police called; Amber Alert issued."), (4, "Tuesday: found at a Daytona Beach motel.")],
            howIdentified: "The custody order and {DL}'s visit.",
            notDone: ["The motel room was not searched for return tickets."],
            defendantExam: [
                .direct("Did you mean to keep {KID} in Florida?", "\"No. I needed a few days away from everything.\""),
                .cross("You told the clerk you were moving for good.", "\"I said a lot of things to a stranger.\""),
                .cross("Why turn off your phone?", "\"Because of {VL}'s messages.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"You'd been trying to get {DL}'s visits taken away entirely, hadn't you?\"",
                                  answer: "\"I'd filed a motion, yes.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "A witness's interest in the outcome is always relevant to bias.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "$3,000, a dark phone, and 'moving down for good.'",
            defenseOpening: "A frightened parent took a child to the beach.",
            prosecutionClosing: "Intent is shown by what {DL} did: the savings, the phone, the weekly rate.",
            defenseClosing: "A note saying 'back by Wednesday' is reasonable doubt about intent."
        )
    )

    // MARK: - 135. Friday night (a brawl after a rivalry game)

    static let footballRiot = CaseTemplate(
        key: "story.footballRiot", category: .publicOrder,
        headlines: ["Brawl After Rivalry Game Spills Into Parking Lot", "Parent Charged After Folding Chair Strikes Another Fan"],
        primaryLaw: "riot", lesserLaw: "disorderly", threshold: 7, lesserThreshold: 5,
        specification: "Willfully engaged in a riot, a public disturbance involving an assemblage of three or more persons, at {SCHOOL} stadium in {HOOD}.",
        secondary: [
            SecondaryCharge(lawID: "awdw", specification: "Assaulted {V} with a deadly weapon, a metal folding chair.", chance: 1.0, threshold: 0)
        ],
        ageRange: 36...52, occupations: ["car salesman", "insurance agent", "HVAC technician", "real estate agent"], hasVictim: true,
        summaries: [
            "After a last-second loss in the rivalry game at {SCHOOL} on {DATE}, an argument between fans near the visitors' gate grew into a fight involving more than twenty people. {D}, a parent of one of the home team's players, was filmed by several phones swinging a metal folding chair. One swing struck {V}, a visiting fan, across the back, cracking two ribs. {DL} says {V} and three others had cornered {D.his} teenage son by the fence, and {D.he} grabbed the nearest thing to get them off him."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Phone Videos", "Three phone videos show {DL} swinging a folding chair twice into the crowd; the second swing hits {VL} across the back.", .search),
            E(.document, 2, "Medical Records", "Two cracked ribs; {VL} treated and released."),
            E(.statement, 2, "School Resource Officer", "The officer saw at least twenty people fighting near the gate.")
        ],
        defenseEvidence: [
            E(.video, 2, "Earlier Clip", "A shorter clip, seconds earlier, shows several adults around {DL}'s son by the fence."),
            E(.statement, 1, "Son's Injuries", "{DL}'s son had a bloody nose and a cut lip.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "School resource officer",
                        direct: ["\"Twenty, maybe thirty people throwing punches.\""],
                        cross: ["\"I didn't see how it started.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you see at the gate?", "\"A crowd of twenty or thirty fighting. I saw a metal folding chair go up over heads twice.\""),
                            .cross("You didn't see what happened to the player by the fence?", "\"No. I came around the concession stand after it started.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Visiting fan",
                        direct: ["\"Something hit me across the back.\""],
                        cross: ["\"I was near the fence. I wasn't touching anyone's kid.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened?", "\"I was trying to pull my brother out of it. Something slammed into my back and I couldn't breathe.\""),
                            .cross("You were near the fence where the player was?", "\"Near it. I never touched that boy.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s teenage son",
                        direct: ["\"They had me against the fence.\""],
                        cross: ["\"I can't say who was who.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened to you?", "\"Three or four grown men had me against the fence. One hit me in the face. Then my dad was there.\""),
                            .cross("Was {VL} one of them?", "\"I don't know. It was all fast.\"")
                        ])
        ],
        prosecutionTheory: ["{D} joined a brawl and swung a metal chair into a crowd, breaking a man's ribs."],
        defenseTheory: ["A father saw grown men beating his son against a fence and acted to stop it. That's defense of another."],
        aggravating: [],
        mitigating: ["The defendant acted to protect a family member", "No prior criminal record"],
        victimImpacts: ["{V}: \"It was a high school football game. I brought my nephew.\""],
        allocutions: ["\"I'd do anything for my son. I'm sorry the chair hit someone who wasn't part of it.\""],
        guiltyTruths: ["A fourth video shows the fight at the fence had broken up before {DL} picked up the chair."],
        innocentTruths: ["Another fan later identified {VL} as one of the men holding {DL}'s son."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        extras: ["SCHOOL": ["Hollis Central High", "East Hollis High", "Bayard County High"]],
        story: StoryExtras(
            timeline: [(0, "9:48 p.m.: game ends."), (0, "9:55 p.m.: fight at the visitors' gate."), (0, "10:02 p.m.: officers clear the lot."), (6, "Videos reviewed; {DL} charged.")],
            howIdentified: "Phone videos posted online, and {DL}'s jersey with {D.his} son's number.",
            notDone: ["Not all of the more than twenty participants were identified."],
            defendantExam: [
                .direct("Why did you pick up the chair?", "\"Men had my son against the fence. I couldn't get to him through the crowd.\""),
                .cross("You swung it twice into people who weren't near the fence.", "\"I was swinging to clear a way.\""),
                .cross("The fight at the fence was already over.", "\"It didn't look over to me.\"")
            ],
            prosecutionOpening: "Twenty people in a parking lot, and a metal chair in {DL}'s hands.",
            defenseOpening: "A father and a son in danger.",
            prosecutionClosing: "Defense of another allows reasonable force against the attacker, not a chair swung into a crowd.",
            defenseClosing: "{DL} believed {D.his} son was in danger, and that belief was reasonable.",
            genders: ["D": .male, "V": .male]
        )
    )

    // MARK: - 136. The straightaway (a street race ends in a death)

    static let dragRaceDeath = CaseTemplate(
        key: "story.dragRaceDeath", category: .traffic,
        headlines: ["Street Race on Industrial Boulevard Kills Driver", "Racer Charged With Manslaughter; Other Driver Still Sought"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Unlawfully and unintentionally killed {V} by culpable negligence, racing another vehicle at more than 100 mph on Industrial Boulevard.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly in willful disregard of the rights and safety of others by racing another vehicle on a public street.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...24, occupations: ["auto parts clerk", "college student", "mechanic's apprentice"], hasVictim: true,
        summaries: [
            "Shortly after midnight on {DATE}, two cars lined up at a light on Industrial Boulevard in {HOOD}, where a crowd gathers on weekends to watch street races. When the light changed, both accelerated. A quarter mile on, {D}'s Mustang, going about 104 mph, struck {V}'s car as it pulled out of a warehouse lot after a night shift. {VL} died at the scene. The other racing car drove off. {DL} stayed, called 911, and tried CPR. {DL} says {D.he} wasn't racing, just accelerating hard, and that {VL} pulled out without looking."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Event Data Recorder", "{DL}'s Mustang at 104 mph two seconds before impact, throttle at 100 percent.", .search),
            E(.video, 3, "Spectator Video", "A spectator's phone shows two cars launching side by side from the light, the crowd cheering.", .search),
            E(.document, 2, "Social Media Post", "{DL} posted that afternoon: \"Industrial tonight. Bringing the 5.0.\"", .search)
        ],
        defenseEvidence: [
            E(.video, 2, "Warehouse Camera", "{VL}'s car pulls out of the lot without stopping at the stop line."),
            E(.statement, 1, "Rendered Aid", "{DL} called 911 and performed CPR until paramedics arrived.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Police crash reconstructionist",
                        direct: ["\"104 miles an hour in a 35 zone.\""],
                        cross: ["\"{VL} didn't stop at the line.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How fast was the Mustang going?", "\"104 two seconds before impact, with the throttle wide open. The limit there is 35.\""),
                            .cross("{VL} pulled out without stopping?", "\"A rolling stop. At 35, the Mustang would have had time to stop. At 104, it had none.\"")
                        ]),
            WitnessSeed(name: nil, role: "Spectator",
                        direct: ["\"Everybody knew they were racing.\""],
                        cross: ["\"I didn't see the crash itself.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see at the light?", "\"Two cars revving side by side, people lined up on the curb. Somebody counted it down. They took off.\""),
                            .cross("You didn't see the crash?", "\"I heard it. I was filming the start.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Paramedic",
                        direct: ["\"{DL} was doing CPR when we got there.\""],
                        cross: ["\"{D.He} told me {D.he} was going too fast.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you see when you arrived?", "\"The driver of the Mustang doing chest compressions on {VL}, crying.\""),
                            .cross("Did {DL} say anything?", "\"{D.He} kept saying '{D.he} came out of nowhere, I was going too fast.'\"")
                        ])
        ],
        prosecutionTheory: ["{D} announced the race, lined up at the light, and drove 104 mph down a street lined with spectators and workplaces. That's culpable negligence."],
        defenseTheory: ["{DL} drove too fast and is devastated, but {VL} rolled into traffic without stopping. Without that, there's no crash."],
        aggravating: [],
        mitigating: ["The defendant stayed at the scene and rendered aid", "The defendant has accepted responsibility", "The defendant was young at the time of the offense"],
        victimImpacts: ["{VL}'s spouse: \"{V.He} worked nights so we could save for a house. {V.He} was ten minutes from home.\""],
        allocutions: ["\"I killed someone for a stupid race. I'll carry that every day.\""],
        guiltyTruths: ["{DL}'s messages show {D.he} had raced on Industrial Boulevard almost every weekend that summer."],
        innocentTruths: ["The warehouse camera's later enhancement showed {VL}'s headlights were off as {V.he} pulled out."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "12:14 a.m.: two cars launch from the light."), (0, "12:14 a.m.: Mustang strikes {VL}'s car."), (0, "12:15 a.m.: {DL} calls 911."), (2, "Event data recorder downloaded under warrant."), (10, "{DL} charged.")],
            howIdentified: "{DL} remained at the scene.",
            notDone: ["The second racing car's driver was never identified."],
            defendantExam: [
                .direct("Were you racing?", "\"Yes. I lied before. We were racing.\""),
                .cross("104 in a 35, past a crowd.", "\"A hundred and four, and people on both sidewalks.\""),
                .cross("You posted about it that afternoon.", "\"That afternoon. I shouldn't have.\"")
            ],
            prosecutionOpening: "A post, a countdown, and 104 miles an hour.",
            defenseOpening: "A tragedy with two causes, one of them in {VL}'s car.",
            prosecutionClosing: "Racing on a public street at three times the limit is culpable negligence by definition.",
            defenseClosing: "Speed was {DL}'s fault. The rolling stop was not."
        )
    )

    // MARK: - 137. Deer camp (a rifle in a felon's truck)

    static let deerCampFelon = CaseTemplate(
        key: "story.deerCampFelon", category: .publicOrder,
        headlines: ["Felon Charged With Rifle at Hunting Camp", "\"It's My Uncle's Gun,\" Hunter Says"],
        primaryLaw: "felonFirearm", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Having been previously convicted of a felony, possessed a firearm, a .30-06 bolt-action rifle.",
        secondary: [],
        ageRange: 32...55, occupations: ["logger", "construction laborer", "welder"], forcedPriorOffenses: ["Breaking or Entering@14"], hasVictim: false,
        summaries: [
            "On the opening day of deer season, {DATE}, a wildlife officer checked licenses at a hunting camp in the woods outside {HOOD}. {D}, convicted of felony breaking or entering fourteen years earlier, was sitting in {D.his} pickup with a .30-06 rifle in a case on the back seat and a fresh-killed doe in the truck bed. {DL} says the rifle belongs to {D.his} uncle, who shot the deer and asked {DL} to drive it and the rifle back to camp, and that {D.he} never handled the gun. The uncle confirms it. A box of .30-06 shells in the truck's console had {DL}'s fingerprint."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Rifle in Truck", "A .30-06 rifle in a soft case on the back seat of {DL}'s pickup, within arm's reach of the driver.", .search),
            E(.forensic, 2, "Fingerprint on Ammunition Box", "{DL}'s fingerprint on the box of .30-06 cartridges in the console.", .search),
            E(.document, 2, "Prior Felony Judgment", "{DL}'s conviction for felony breaking or entering fourteen years ago.")
        ],
        defenseEvidence: [
            E(.document, 2, "Uncle's Hunting License", "{DL}'s uncle held a valid big game license and had a tag filled for the doe."),
            E(.forensic, 1, "No Prints on Rifle", "No usable prints on the rifle itself.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Wildlife officer",
                        direct: ["\"The rifle was in reach of the driver's seat.\""],
                        cross: ["\"The uncle had a valid tag.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find in the truck?", "\"A rifle in a soft case on the back seat, a box of shells in the console, and a doe in the bed.\""),
                            .direct("What did {DL} say?", "\"That it was {D.his} uncle's gun and {D.he} was just hauling it.\""),
                            .cross("The uncle came over and said the gun was his?", "\"Yes, and he had a filled tag.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s uncle",
                        direct: ["\"It's my rifle. I shot that doe.\""],
                        cross: ["\"The shells were in the truck all season.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Whose rifle is it?", "\"Mine. I shot the doe, and my knees are bad, so I asked {DL} to drive it back to camp. I put the rifle in the truck myself.\""),
                            .cross("How did {DL}'s fingerprint get on the shells?", "\"I don't know. They've been in that truck since September.\"")
                        ])
        ],
        prosecutionTheory: ["The rifle was in {DL}'s truck, within reach, with {D.his} fingerprint on the ammunition. That's possession, whoever owns the gun."],
        defenseTheory: ["Ownership isn't the question, but knowledge and intent to control are. {DL} drove {D.his} uncle's gun and deer back to camp as a favor. {D.He} never handled it."],
        aggravating: [],
        mitigating: ["The prior felony is old and nonviolent", "The defendant has been gainfully employed"],
        allocutions: ["\"I haven't been in trouble in fourteen years. I was helping my uncle.\""],
        guiltyTruths: ["A trail camera at the stand showed {DL}, not the uncle, carrying the rifle into the woods at dawn."],
        innocentTruths: ["The uncle's hunting partner confirmed the uncle carried the rifle all morning and loaded it into the truck."],
        moods: [.sympathetic], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Dawn: hunters head to stands."), (0, "10:30 a.m.: doe taken."), (0, "11:15 a.m.: license check at camp."), (21, "Fingerprint result; {DL} charged.")],
            howIdentified: "{DL} was in the driver's seat.",
            notDone: ["Trail cameras near the stands were not checked."],
            defendantExam: [
                .direct("Did you ever handle the rifle?", "\"No. My uncle put it in the back seat.\""),
                .cross("Your fingerprint is on the shells.", "\"I moved that box to get to my sunglasses in the console.\""),
                .cross("You knew the rifle was in your truck.", "\"Yes. I knew it was there.\"")
            ],
            prosecutionOpening: "A felon, a rifle within reach, and {D.his} fingerprint on the shells.",
            defenseOpening: "A favor for a family member with bad knees.",
            prosecutionClosing: "Knowing a gun is in your truck within reach, with the power to use it, is possession.",
            defenseClosing: "Proximity isn't possession when the owner is standing right there."
        )
    )

    // MARK: - 138. The coach (anonymous messages to a youth coach)

    static let coachCyberstalking = CaseTemplate(
        key: "story.coachCyberstalking", category: .cyber,
        headlines: ["Parent Charged With Cyberstalking Youth Baseball Coach", "Anonymous Messages Followed Benching of Player"],
        primaryLaw: "cyberstalking", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Electronically communicated with {V} repeatedly from anonymous accounts for the purpose of abusing, annoying, threatening, and harassing {V.him}.",
        secondary: [
            SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened to physically injure {V}, writing, \"Coach better watch the parking lot after practice,\" in a manner that made {V} believe the threat would be carried out.", chance: 1.0, threshold: 0)
        ],
        ageRange: 36...50, occupations: ["dental hygienist", "accountant", "sales manager", "pharmacist"], hasVictim: true,
        summaries: [
            "{V} volunteers as head coach of a 12-and-under travel baseball team in {HOOD}. After benching several players for missing practice, {VL} began receiving messages from anonymous accounts: dozens over three weeks, insulting {V.his} coaching, posting {V.his} home address, and on {DATE} writing, \"Coach better watch the parking lot after practice.\" A subpoena to the platform traced two of the accounts to an IP address at {D}'s house. {DL}'s child was one of the benched players. {DL} says {D.his} teenage nephew stayed at the house that month and used the home internet."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Messages", "Sixty-one messages from three anonymous accounts over three weeks, including {VL}'s home address and \"Coach better watch the parking lot after practice.\"", .search),
            E(.document, 3, "Subscriber Records", "Two accounts created and used from the IP address assigned to {DL}'s home internet.", .search),
            E(.digital, 2, "Writing Style", "The messages repeat a misspelling, \"definately,\" that appears in {DL}'s team group texts.")
        ],
        defenseEvidence: [
            E(.statement, 2, "The Nephew", "{DL}'s nephew, 17, lived at the house that month and was angry about his cousin's benching."),
            E(.document, 1, "Open Wi-Fi", "The home router had a weak password shared with neighbors.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Youth baseball coach",
                        direct: ["\"They posted my address. I have kids.\""],
                        cross: ["\"I never saw who sent them.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did the messages affect you?", "\"I stopped letting my kids play in the front yard. When the parking lot message came, I had a deputy at practice.\""),
                            .cross("You don't know who typed them?", "\"No. I know which family was angriest about the benching.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective, cyber unit",
                        direct: ["\"Two accounts, one home IP address.\""],
                        cross: ["\"An IP address identifies a connection, not a person.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the subpoena return?", "\"Two of the three accounts were created and used from the IP address assigned to {DL}'s home.\""),
                            .cross("Anyone using that home's internet would show the same address?", "\"Yes. That's why we also compared the writing.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s spouse",
                        direct: ["\"Our nephew was on that computer every night.\""],
                        cross: ["\"I never saw what he was typing.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Who used the home computer that month?", "\"Our nephew, mostly. He was furious about his cousin being benched.\""),
                            .cross("Did you see the messages being written?", "\"I saw them after they were sent. Not before.\"")
                        ])
        ],
        prosecutionTheory: ["The accounts trace to {D}'s home, the messages share {D.his} misspelling, and {D.his} child was the one benched."],
        defenseTheory: ["A teenage nephew, an open router, and a misspelling half the country makes. The State hasn't put {DL} at the keyboard."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I volunteered to coach twelve-year-olds. I quit after this season.\""],
        allocutions: ["\"I was angry about my kid. I'm sorry for all of it.\""],
        guiltyTruths: ["The third account was later traced to {DL}'s work computer."],
        innocentTruths: ["The nephew admitted to his school counselor that he wrote every message."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-21, "First anonymous message."), (-14, "{VL}'s address posted."), (0, "\"Watch the parking lot\" message."), (25, "Platform subpoena returned."), (35, "{DL} charged.")],
            howIdentified: "Subscriber records for two of the accounts.",
            notDone: ["The nephew was not interviewed.", "The third account's subscriber records were not obtained."],
            defendantExam: [
                .direct("Did you send those messages?", "\"No. I complained to the league director by email, under my own name.\""),
                .cross("You spell 'definitely' with an 'a' in your team texts.", "\"So does my nephew. So does half the team.\""),
                .cross("Your child was benched.", "\"Yes. I was angry. I didn't threaten anyone.\"")
            ],
            prosecutionOpening: "A benched child, a parent's IP address, and a threat about the parking lot.",
            defenseOpening: "A house with a teenager and an open router.",
            prosecutionClosing: "Motive, the address, and the spelling all point one way.",
            defenseClosing: "An IP address is a house, not a person."
        )
    )
}
