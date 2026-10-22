import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchH: [CaseTemplate] = [busStopPurse, officerPunch, tireIron, heatOfPassion, dogHoarding]

    // MARK: - 49. The bus stop purse (a shove, a purse, and a cross-racial identification)

    static let busStopPurse = CaseTemplate(
        key: "story.busStopPurse", category: .robbery,
        headlines: ["Woman, 74, Shoved to Ground in Bus Stop Purse Snatching", "Bus Stop Robbery Suspect Picked From Photo Lineup"],
        primaryLaw: "commonLawRobbery", lesserLaw: "misdLarceny", threshold: 3, lesserThreshold: 1,
        specification: "Took a purse and its contents from the person of {V} by violence, shoving {V.him} to the ground.",
        secondary: [
            SecondaryCharge(lawID: "aisi", specification: "Assaulted {V} by shoving {V.him} to the sidewalk, inflicting a broken wrist.", chance: 1.0, threshold: 2),
            SecondaryCharge(lawID: "misdLarceny", specification: "Stole a purse and its contents belonging to {V}.", chance: 1.0, threshold: 1)
        ],
        ageRange: 19...30, occupations: ["warehouse worker"], forcedPriorOffenses: ["Misdemeanor Larceny"], hasVictim: true,
        summaries: [
            "At about 5:40 p.m. on {DATE}, {V}, 74, was waiting for the bus on {STREET} in {HOOD} when someone in a gray hooded sweatshirt grabbed {V.his} purse, shoved {V.him} to the sidewalk, and ran toward the apartments behind the stop. {VL} broke a wrist. Two days later {VL} picked {D} from a photo lineup, saying {V.he} was \"pretty sure.\" {DL}, who lives in those apartments and has a prior shoplifting conviction, says {D.he} was at work across town until 6:00. {VL}'s bus pass turned up in a storm drain near {DL}'s building."
        ],
        prosecutionEvidence: [
            E(.statement, 2, "Photo Lineup", "{VL} chose {DL}'s photo from six, saying \"pretty sure, it's the eyes.\" The officer who ran the lineup was not involved in the case."),
            E(.physical, 2, "Bus Pass", "{VL}'s bus pass, found in a storm drain forty yards from {DL}'s apartment building the next morning."),
            E(.video, 2, "Apartment Camera", "At 5:44 p.m. a person in a gray hooded sweatshirt runs past the apartment complex's rear camera. The face is not visible."),
            E(.physical, 1, "Gray Sweatshirt", "A gray hooded sweatshirt found in {DL}'s closet during a consent search.", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "Time Clock", "{DL}'s employer's time clock shows a punch-out at 5:58 p.m. at a warehouse eleven miles away."),
            E(.document, 2, "Lineup Form", "{VL} told the 911 operator the robber was \"a young person, I didn't really see the face.\""),
            E(.document, 1, "Other Residents", "The complex has 140 units. Officers did not canvass beyond {DL}'s building.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Victim",
                        direct: ["\"I looked right at the person.\""],
                        cross: ["\"It happened fast.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened at the bus stop?", "\"I had my purse on my shoulder. Somebody came up from behind the shelter, yanked it, and when I held on, pushed me. I went down on my hand and heard the wrist go.\""),
                            .direct("Did you see the person's face?", "\"For a second, when they turned to pull. Young. Dark eyes, a little scar or mark by the eyebrow.\""),
                            .direct("How did you pick the photo?", "\"The officer showed me six pictures one at a time. I stopped at that one. I said I was pretty sure.\""),
                            .cross("You told the 911 operator you didn't really see the face.", "\"I was on the ground in pain. I said a lot of things.\""),
                            .cross("You were looking at the person for about a second?", "\"It felt longer. But yes, it was fast.\""),
                            .cross("Did the officer tell you anything after you picked the photo?", "\"He said, 'Okay, thank you.' That's all.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The pass was forty yards from {DL}'s door.\""],
                        cross: ["\"We didn't check the time clock until later.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did {DL} become a suspect?", "\"An officer who patrols the complex said the description fit a resident with a shoplifting record. That was {DL}.\""),
                            .direct("What did you find?", "\"The bus pass in the storm drain behind {DL}'s building the next morning. A gray hooded sweatshirt in {DL}'s closet, which {D.he} let us search.\""),
                            .cross("Gray hooded sweatshirts are common?", "\"Half the county owns one. I own two.\""),
                            .cross("The storm drain is also forty yards from three other buildings?", "\"It sits between them, yes.\""),
                            .cross("When did you get the time clock records?", "\"After the defense subpoenaed them. Six weeks later.\""),
                            .cross("Does the scar by the eyebrow match {DL}?", "\"{DL} has no scar there.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Warehouse shift lead",
                        direct: ["\"{DL} was on my line until six.\""],
                        cross: ["\"People do clock out for each other sometimes.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Was {DL} at work that afternoon?", "\"Yes. {DL} was on my line loading trailers. I remember because we were short two people and I kept everyone until close.\""),
                            .direct("When does that shift end?", "\"Six. The clock says 5:58 for {DL}. That's about right.\""),
                            .cross("Can you say you saw {DL} at 5:30 specifically?", "\"Not to the minute. I saw {D.him} on the dock that last hour.\""),
                            .cross("Have workers ever clocked out for each other?", "\"It's happened. We fired somebody for it last year.\"")
                        ])
        ],
        prosecutionTheory: ["{VL} saw the face, picked {DL} from a fair lineup, and the stolen bus pass was dumped behind {DL}'s building."],
        defenseTheory: ["A one-second look by a frightened victim, a description that doesn't match, and a time clock that puts {DL} eleven miles away."],
        aggravating: ["The victim was very old"],
        mitigating: ["The defendant has a support system in the community", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"I don't take the bus anymore. My grandson drives me. I used to go everywhere by myself.\""],
        allocutions: ["\"I'm sorry about what happened to {VL}. It wasn't me.\""],
        guiltyTruths: ["A coworker later admitted punching out for {DL} that day as a favor."],
        innocentTruths: ["A fingerprint on the recovered purse later matched another resident of the complex who had a mark above one eyebrow."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Purse snatching at the {STREET} bus stop; {VL} taken to the hospital."),
                       (1, "Bus pass recovered from a storm drain behind the apartments."),
                       (2, "{VL} picks {DL}'s photo from a six-person lineup."),
                       (3, "Consent search of {DL}'s apartment; gray sweatshirt collected."),
                       (3, "{DL} charged."),
                       (45, "Employer time clock records obtained by defense subpoena.")],
            howIdentified: "A patrol officer's tip and {VL}'s photo lineup identification.",
            notDone: ["The recovered purse was never processed for fingerprints.", "Other buildings in the complex were never canvassed."],
            defendantExam: [
                .direct("Where were you at 5:40 that evening?", "\"At work, on the loading dock. I clocked out at 5:58 and caught a ride home.\""),
                .direct("Do you own a gray hoodie?", "\"Two of them. So does everybody in my building.\""),
                .cross("You have a shoplifting conviction.", "\"Years ago. I paid for it.\""),
                .cross("Who drove you home?", "\"A guy from work. I don't know his last name. He quit.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, why did the patrol officer think of {DL}?\"",
                                  answer: "\"Because {DL} has a history of stealing.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character evidence", shouldSustain: true,
                                  explanation: "A prior theft offered to show the defendant is the type to steal is barred by Rule 404(b).",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "{VL} looked into the face of the person who knocked {V.him} down, and picked that face out of six.",
            defenseOpening: "One second, a frightened witness, and a time clock eleven miles away.",
            prosecutionClosing: "{VL} was sure enough to point. The bus pass was behind {DL}'s door.",
            defenseClosing: "Pretty sure isn't proof beyond a reasonable doubt.",
            genders: ["V": .female],
            victim: VictimFacts(age: 74, occupation: "Retired", relationship: "Strangers before the incident.", family: "Widowed; helps raise a grandson.", harm: ["A broken wrist; months of physical therapy.", "No longer rides the bus alone."])
        )
    )

    // MARK: - 50. The officer punch (who grabbed whom outside a bar)

    static let officerPunch = CaseTemplate(
        key: "story.officerPunch", category: .violent,
        headlines: ["Bar Patron Charged With Breaking Officer's Nose", "Body Camera Footage Disputed in Officer Assault Case"],
        primaryLaw: "assaultLEO", lesserLaw: "simpleAssault", threshold: 3, lesserThreshold: 1,
        specification: "Assaulted Officer {OFFICER}, a law enforcement officer performing official duties, by striking the officer in the face and inflicting physical injury.",
        secondary: [
            SecondaryCharge(lawID: "resisting", specification: "Resisted Officer {OFFICER} in the discharge of official duties during an arrest.", chance: 1.0, threshold: 2)
        ],
        ageRange: 23...38, occupations: ["electrician's apprentice", "line cook"], hasVictim: false,
        summaries: [
            "At 1:15 a.m. on {DATE}, Port Hollis officers were called to The Lantern Row Tavern for a fight that had already broken up. Officer {OFFICER} told {D}, who was arguing with a bouncer on the sidewalk, to leave. Within twenty seconds {DL} and the officer were on the ground and the officer's nose was broken. The officer says {DL} swung after being told {D.he} was under arrest. {DL} says the officer grabbed {D.his} neck from behind without a word and {D.he} threw an elbow by reflex. The officer's body camera fell off in the struggle. A bystander's phone video catches the last eight seconds."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Medical Records", "Officer {OFFICER}: nasal fracture, treated at Hollis Regional Medical Center the same night."),
            E(.video, 2, "Body Camera (Partial)", "The officer says \"You need to leave\" twice. {DL} says \"I'm going, I'm getting my friend.\" The camera then jolts and records pavement."),
            E(.statement, 2, "Bouncer's Statement", "The bouncer told police {DL} \"turned and swung\" at the officer."),
            E(.document, 1, "Blood Alcohol", "{DL}'s blood alcohol concentration was 0.13 two hours later.")
        ],
        defenseEvidence: [
            E(.video, 3, "Bystander Video", "Eight seconds, starting mid-struggle: the officer's forearm is across {DL}'s throat from behind; {DL}'s elbow comes back and connects."),
            E(.document, 2, "Use-of-Force Report", "The officer's own report says \"I placed my arm around the subject's upper body to effect the arrest\" and does not mention announcing an arrest."),
            E(.document, 1, "Bouncer's History", "The bouncer had been in the earlier fight and was not charged.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFFICER}", role: "Port Hollis police officer",
                        direct: ["\"I told {DL} {D.he} was under arrest.\""],
                        cross: ["\"I didn't say it on camera.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you approach {DL}?", "\"The fight was over, but {DL} was still yelling at the door staff. I told {D.him} twice to leave. {D.He} kept going back toward the door.\""),
                            .direct("What happened next?", "\"I said, 'You're under arrest for disorderly conduct.' I reached for {D.his} arm. {D.He} spun and hit me in the face.\""),
                            .direct("What injury did you suffer?", "\"A broken nose. I couldn't breathe through it for three weeks.\""),
                            .cross("Your camera recorded you telling {DL} to leave, but not saying 'under arrest'?", "\"It was knocked off right around then.\""),
                            .cross("Your report says you put your arm around {DL}'s upper body. Was that from behind?", "\"From the side and behind, yes.\""),
                            .cross("Was {DL} walking away when you grabbed?", "\"{D.He} was walking toward the door, not away from it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Bouncer at The Lantern Row Tavern",
                        direct: ["\"{DL} turned and swung.\""],
                        cross: ["\"I was in the first fight, yeah.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see?", "\"The cop told {DL} to go. {DL} kept saying {D.he} wanted {D.his} friend. Then the cop went to grab {D.him} and {DL} turned and swung.\""),
                            .direct("Did you hear the officer say 'under arrest'?", "\"I think so. It was loud.\""),
                            .cross("You were in the fight that brought police there?", "\"I broke it up.\""),
                            .cross("You weren't charged with anything?", "\"Nobody charged me. I was doing my job.\""),
                            .cross("You 'think' you heard 'under arrest'?", "\"I'm not a hundred percent.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Bystander who filmed the struggle",
                        direct: ["\"The officer had {DL} by the throat.\""],
                        cross: ["\"I started recording after it started.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see before you started recording?", "\"The officer came up behind {DL} and wrapped an arm around {D.his} neck. I didn't hear anything said. That's why I started filming.\""),
                            .direct("What does the video show?", "\"The arm across {DL}'s throat and {DL}'s elbow going back. Then they both go down.\""),
                            .cross("You'd been drinking that night too?", "\"Two beers.\""),
                            .cross("Could you hear anything over the music from the bar?", "\"Not well. But I saw the officer's mouth, and it didn't move.\"")
                        ])
        ],
        prosecutionTheory: ["{D}, drunk and told to leave, swung at an officer making a lawful arrest and broke the officer's nose."],
        defenseTheory: ["{DL} was grabbed by the throat from behind without warning and reacted by reflex. A person who doesn't know who grabbed {D.him} hasn't knowingly assaulted an officer."],
        aggravating: [],
        mitigating: ["The defendant has been gainfully employed", "No prior criminal record"],
        victimImpacts: ["Officer {OFFICER}: \"I've done this nine years. That was the first time I thought I was going to lose a fight.\""],
        allocutions: ["\"I never would have swung at a cop on purpose. I didn't know who had me.\""],
        guiltyTruths: ["A second bystander's video, found later, shows the officer saying \"You're under arrest\" before reaching for {DL}."],
        innocentTruths: ["A second bystander's video, found later, shows the officer grabbing {DL} from behind with no warning."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        extras: ["OFFICER": ["Casey Reyes", "Morgan Whitfield", "Jordan Okonkwo"]],
        story: StoryExtras(
            timeline: [(0, "1:15 a.m.: officers respond to The Lantern Row Tavern; officer injured; {DL} arrested."),
                       (0, "3:20 a.m.: blood drawn under warrant; 0.13."),
                       (2, "Body camera footage reviewed; recording ends when the camera falls."),
                       (9, "Bystander video provided by the defense.")],
            howIdentified: "{DL} was arrested at the scene.",
            notDone: ["Other patrons on the sidewalk were never identified or interviewed."],
            defendantExam: [
                .direct("What happened on the sidewalk?", "\"I was trying to get my friend out of the bar so we could leave. Then something hit my neck from behind and I couldn't breathe. I threw my elbow back. I didn't know it was a cop until I was on the ground.\""),
                .direct("Did you hear anyone say you were under arrest?", "\"No. I heard 'leave,' and I was leaving with my friend.\""),
                .cross("You had a 0.13 blood alcohol.", "\"I'd been drinking. I wasn't fighting anyone.\""),
                .cross("You were walking toward the door after being told to leave.", "\"Toward my friend, who was standing at the door.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Officer, you've had three prior complaints for excessive force, haven't you?\"",
                                  answer: "\"All three were unfounded.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper impeachment", shouldSustain: true,
                                  explanation: "Unproven complaints aren't convictions and aren't admissible to attack credibility without a proper basis under Rule 608.",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "A lawful order, a lawful arrest, and a broken nose.",
            defenseOpening: "An arm around the throat from behind, and a reflex.",
            prosecutionClosing: "{DL} knew who was arresting {D.him}. The uniform was right there.",
            defenseClosing: "The only video shows an officer choking someone from behind. The State hasn't proven {DL} knew who it was."
        )
    )

    // MARK: - 51. The tire iron (road rage at a red light)

    static let tireIron = CaseTemplate(
        key: "story.tireIron", category: .violent,
        headlines: ["Road Rage on {STREET}: Driver Swings Tire Iron", "Two Drivers, One Tire Iron, Two Stories"],
        primaryLaw: "awdw", lesserLaw: "simpleAssault", threshold: 3, lesserThreshold: 1,
        specification: "Assaulted {V} with a deadly weapon, a tire iron, by swinging it at {V.him}.",
        secondary: [
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Damaged {V}'s side mirror with a tire iron.", chance: 1.0, threshold: 1)
        ],
        ageRange: 35...60, occupations: ["HVAC technician", "construction laborer"], hasVictim: true,
        summaries: [
            "On {DATE}, after {V} cut off {D} merging onto {STREET} in {HOOD}, both drivers stopped at the next red light. {VL} got out and walked to {DL}'s window. {DL} got out with a tire iron. Witnesses agree {DL} swung it once and hit {VL}'s side mirror, not {VL}. They disagree about what {VL} was doing: one says {VL} was pounding on {DL}'s window and reaching inside; another says {VL} was just yelling. {VL} had a folding knife clipped to {V.his} pocket. This case was tried in district court, and {DL} appealed a conviction there."
        ],
        prosecutionEvidence: [
            E(.physical, 2, "Tire Iron", "A two-foot steel tire iron recovered from {DL}'s truck."),
            E(.physical, 2, "Broken Mirror", "{VL}'s side mirror, shattered, with a dent matching the tire iron's end."),
            E(.statement, 2, "Driver Behind", "The driver behind {VL} told police {DL} \"came out swinging\" while {VL} was \"just yelling.\"")
        ],
        defenseEvidence: [
            E(.physical, 2, "Folding Knife", "A clipped folding knife on {VL}'s pocket, noted by the responding officer."),
            E(.statement, 2, "Pedestrian", "A pedestrian on the corner told police {VL} was \"hitting the window and reaching in\" before {DL} got out."),
            E(.physical, 1, "Window Smudges", "Handprints on the outside of {DL}'s driver's window, photographed by the officer.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Other driver",
                        direct: ["\"I was just talking to {D.him}.\""],
                        cross: ["\"I might have knocked on the window.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you get out of your car?", "\"{DL} had been riding my bumper and honking for a mile. I wanted to ask what the problem was.\""),
                            .direct("What happened?", "\"I said, 'What's your problem?' {DL} jumped out with a tire iron and swung at my head. I ducked, and it hit my mirror.\""),
                            .cross("You cut {DL} off merging, didn't you?", "\"I merged. Maybe it was close.\""),
                            .cross("Did you put your hands on {DL}'s window?", "\"I might have knocked on it.\""),
                            .cross("You had a knife clipped to your pocket?", "\"For work. I never touched it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Driver stopped behind {VL}",
                        direct: ["\"{DL} came out swinging.\""],
                        cross: ["\"I couldn't see {VL}'s hands.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"The guy in front of me got out and walked up to the truck yelling. Then the truck door flew open and the driver came out swinging a tire iron.\""),
                            .cross("You were behind {VL}'s car?", "\"Yes, one car back.\""),
                            .cross("Could you see {VL}'s hands at {DL}'s window?", "\"Not really. {VL}'s back was to me.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pedestrian at the corner",
                        direct: ["\"{VL} was reaching in.\""],
                        cross: ["\"I was across the street.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"The first driver walked up and started pounding on the truck window, then the window came down a little and {VL} reached in. That's when the truck door opened.\""),
                            .direct("Did you see a weapon on {VL}?", "\"Something clipped on the pocket, shiny. I didn't know what it was.\""),
                            .cross("You were across the street?", "\"Across the intersection, maybe sixty feet.\""),
                            .cross("Did {VL} pull out the knife?", "\"No. I didn't see that.\"")
                        ])
        ],
        prosecutionTheory: ["Angry over a merge, {D} got out with a tire iron and swung it at an unarmed person."],
        defenseTheory: ["{VL} confronted {DL}, pounded on the window, and reached inside. {DL} had a right to defend against an attack in {D.his} own vehicle."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: ["{V}: \"I think about that swing every time I'm at a red light.\""],
        allocutions: ["\"I shouldn't have gotten out of the truck. But I didn't know what {VL} was reaching for.\""],
        guiltyTruths: ["A traffic camera clip later surfaced showing {VL} standing a step back from the truck, not reaching in, when {DL} got out."],
        innocentTruths: ["A traffic camera clip later surfaced showing {VL}'s arm inside {DL}'s window just before {DL} got out."],
        moods: [.divided], doctrines: ["selfDefense"],
        story: StoryExtras(
            timeline: [(0, "Confrontation at the red light; officers respond and take statements."),
                       (0, "Tire iron collected from {DL}'s truck; photos of the mirror and window."),
                       (5, "{DL} charged with assault with a deadly weapon.")],
            howIdentified: "Both drivers were at the scene when officers arrived.",
            notDone: ["Nobody requested the traffic camera footage at that intersection before it was overwritten."],
            defendantExam: [
                .direct("Why did you get out with a tire iron?", "\"{VL} was banging on my window and then reached in at my face. There was a knife on {V.his} pocket. I grabbed what was on the floor and got out to make {V.him} back off.\""),
                .direct("Did you swing at {VL}?", "\"I swung at the mirror to make {V.him} stop. If I wanted to hit {VL}, I would have.\""),
                .cross("You could have locked the door and stayed in the truck.", "\"The window was down. {V.His} arm was inside.\""),
                .cross("You honked and tailgated for a mile.", "\"I honked once when {V.he} cut me off.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Was {DL} acting like a reasonable person?\"",
                                  answer: "\"No, {D.he} was out of control.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Calls for a legal conclusion", shouldSustain: true,
                                  explanation: "Whether conduct was reasonable is for the factfinder; a lay witness may describe what was seen, not apply the legal standard.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A merge, a red light, and a tire iron swung at a person's head.",
            defenseOpening: "An arm through the window and a knife on the pocket.",
            prosecutionClosing: "Self-defense isn't getting out of your truck with a steel bar.",
            defenseClosing: "{DL} didn't start this. The State has to prove {D.he} wasn't defending {D.himself}."
        )
    )

    // MARK: - 52. Heat of passion (a killing in a kitchen after a confession of an affair)

    static let heatOfPassion = CaseTemplate(
        key: "story.heatOfPassion", category: .violent,
        headlines: ["Spouse Charged in Kitchen Stabbing After Argument", "Murder or Manslaughter? Defense Says Confession of Affair Set Off Killing"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 4, lesserThreshold: 2,
        specification: "Unlawfully killed {V} with malice by stabbing {V.him} with a kitchen knife.",
        ageRange: 35...55, occupations: ["school bus driver", "retail manager"], hasVictim: true,
        summaries: [
            "At 10:48 p.m. on {DATE}, {D} called 911 from the family's home on {STREET} in {HOOD} and said, \"I stabbed my spouse. Please hurry.\" {V} died of a single stab wound to the chest. {DL} told detectives that {VL} had just admitted to a two-year affair and said {V.he} was leaving in the morning, and that {DL} \"snapped\" and grabbed the knife from the counter. Text messages show {DL} had suspected the affair for a week and had written to a friend, \"If it's true I don't know what I'll do.\" There was no history of violence in the home."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Autopsy", "A single stab wound, five inches deep, to the left chest. Death within minutes."),
            E(.digital, 2, "Texts to a Friend", "Six days before: \"I think {VL} is cheating. If it's true I don't know what I'll do.\""),
            E(.statement, 2, "Statement to Detectives", "{DL}: \"{VL} told me everything and said {V.he} was leaving. I snapped. The knife was right there.\"", .statement),
            E(.physical, 1, "Knife", "An eight-inch chef's knife from the block on the kitchen counter.")
        ],
        defenseEvidence: [
            E(.document, 3, "911 Call", "{DL} called within ninety seconds, sobbing, and stayed on the line doing chest compressions as instructed."),
            E(.document, 2, "No History", "No prior calls to the home, no protective orders, and no record of violence by {DL}."),
            E(.digital, 2, "Victim's Texts", "Messages from {VL} to the other person that evening: \"Telling {DL} tonight. It's going to be bad.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"One wound, with real force.\""],
                        cross: ["\"One wound is consistent with a single impulsive act.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What caused {VL}'s death?", "\"A single stab wound to the chest that went through the heart. It took significant force to go five inches deep.\""),
                            .direct("Were there defensive wounds?", "\"A small cut on the left palm, which can happen when someone raises a hand.\""),
                            .cross("There was only one wound?", "\"One.\""),
                            .cross("In your experience, do planned killings with a knife usually involve one wound?", "\"I can't speak to planning. I can tell you there was one.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{DL} had suspected for a week.\""],
                        cross: ["\"{DL} called 911 and tried to save {VL}.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That {VL} confessed the affair and said {V.he} was leaving, and that {DL} snapped and grabbed the knife.\""),
                            .direct("What did the phone show?", "\"A text to a friend six days earlier: 'If it's true I don't know what I'll do.' And searches for divorce lawyers.\""),
                            .cross("The searches were for divorce lawyers, not weapons?", "\"Divorce lawyers.\""),
                            .cross("{DL} called 911 within ninety seconds and did CPR?", "\"Inside of two minutes. {D.He} was doing compressions when the first unit arrived.\""),
                            .cross("Is there any evidence {DL} took the knife out before the argument?", "\"No. The block was on the counter where they were standing.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend who received the texts",
                        direct: ["\"{DL} was heartbroken, not dangerous.\""],
                        cross: ["\"I didn't know what {D.he} meant.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you understand the text to mean?", "\"That {DL} would fall apart. {DL} cried on the phone with me for an hour that night. {D.He} talked about counseling.\""),
                            .direct("Had you ever seen {DL} violent?", "\"Never. Twenty years.\""),
                            .cross("'I don't know what I'll do' could mean a lot of things?", "\"I know what I thought it meant.\""),
                            .cross("Did you ask {D.him}?", "\"I didn't want to know the answer.\"")
                        ])
        ],
        prosecutionTheory: ["{D} suspected for a week, warned what might happen, and drove a knife five inches into {VL}'s chest. That's malice."],
        defenseTheory: ["A sudden confession, an argument in a kitchen, and a single blow in the heat of passion, followed by a desperate 911 call. That's voluntary manslaughter, not murder."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant accepted responsibility for the criminal conduct", "The defendant acted under strong provocation"],
        victimImpacts: ["{VL}'s sibling: \"{VL} made mistakes. {V.He} didn't deserve to die on the kitchen floor for them.\""],
        allocutions: ["\"I killed the person I loved most. I'll never forgive myself, and I'm not asking anyone else to.\""],
        guiltyTruths: ["A neighbor later recalled hearing {DL} shout \"I warned you\" ten minutes before the 911 call, suggesting a longer argument than {DL} described."],
        innocentTruths: ["{VL}'s own text to the other person, recovered later, said the conversation \"blew up in seconds.\""],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-6, "{DL} texts a friend about suspecting an affair."),
                       (-4, "{DL} searches for divorce lawyers."),
                       (0, "10:48 p.m.: 911 call from the home; {VL} pronounced dead at 11:20 p.m."),
                       (0, "{DL} interviewed after Miranda warnings; admits the stabbing."),
                       (1, "Autopsy."),
                       (2, "{DL} charged with murder.")],
            howIdentified: "{DL} called 911 and said what happened.",
            notDone: ["Neighbors were interviewed only on one side of the house."],
            defendantExam: [
                .direct("What happened in the kitchen?", "\"{VL} said it was true, two years, and {V.he} was leaving in the morning. {V.He} said {V.he} never loved me the way {V.he} loved this person. I don't remember picking up the knife. I remember {V.him} falling.\""),
                .direct("What did you do then?", "\"I called 911. I pressed on {V.his} chest until they pulled me off.\""),
                .cross("You texted 'I don't know what I'll do' six days before.", "\"Because I didn't know if I could survive it. I meant me.\""),
                .cross("It takes force to drive a knife five inches.", "\"I don't know what I did. I know I did it.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Doctor, would you agree this looks like a crime of passion?\"",
                                  answer: "\"It could be.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Beyond the witness's expertise", shouldSustain: true,
                                  explanation: "A pathologist can describe wounds; whether a killing was in the heat of passion is a mental-state question outside that expertise.",
                                  doctrineID: "expertTestimony", weight: -1))
            ],
            prosecutionOpening: "A week of suspicion, a warning, and a knife driven through the heart.",
            defenseOpening: "A confession, a kitchen, and ninety seconds later, a 911 call.",
            prosecutionClosing: "Words alone are never enough provocation. That's the law.",
            defenseClosing: "This was passion, not malice. The verdict that fits is voluntary manslaughter.",
            victim: VictimFacts(relationship: "Married to the defendant."),
            family: "Widowed. The late spouse is the victim in this case.",
            residence: "Lives in the family home on {STREET} in {HOOD}."
        )
    )

    // MARK: - 53. The dog hoarding case

    static let dogHoarding = CaseTemplate(
        key: "story.dogHoarding", category: .property,
        headlines: ["43 Dogs Seized From {HOOD} Home", "Rescue Founder Charged With Animal Cruelty"],
        primaryLaw: "animalCruelty", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Intentionally deprived animals of necessary sustenance and shelter, causing unjustifiable pain and suffering.",
        secondary: [
            SecondaryCharge(lawID: "animalCruelty", specification: "Deprived eleven dogs of necessary veterinary care, causing untreated skin infections.", chance: 1.0, threshold: 3),
            SecondaryCharge(lawID: "animalCruelty", specification: "Deprived three dogs of necessary care, causing suffering severe enough to require euthanasia.", chance: 1.0, threshold: 3)
        ],
        ageRange: 50...70, occupations: ["owner of a small dog rescue"], hasVictim: false,
        summaries: [
            "On {DATE}, Hollis County Animal Services seized 43 dogs from {D}'s home and backyard kennels on {STREET} in {HOOD}, after a neighbor complained of the smell. Officers found waste inches deep in two rooms, empty water bowls, and eleven dogs with untreated skin infections; three had to be euthanized. {DL} ran an unlicensed rescue for nine years and says {D.he} took dogs nobody else would, that {D.his} helper quit three weeks earlier, and that {D.he} was days away from getting help. Veterinary receipts show {DL} spent more than $14,000 on the dogs that year. {DL} was convicted in district court and appealed."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Seizure Video", "Animal Services video of the house: waste on the floors, ammonia readings above safe levels, empty bowls."),
            E(.document, 3, "Veterinary Exams", "Eleven dogs with untreated mange and infections; three euthanized for severe suffering."),
            E(.document, 1, "Prior Warning", "Animal Services told {DL} in writing eight months earlier to reduce to 15 dogs.")
        ],
        defenseEvidence: [
            E(.document, 3, "Vet Receipts", "$14,200 in veterinary bills for {DL}'s dogs in the prior year, including spay and neuter surgeries."),
            E(.document, 2, "Helper's Resignation", "A text from {DL}'s volunteer three weeks earlier: \"I can't do this anymore, I'm out.\""),
            E(.document, 1, "Adoption Records", "Records of 212 dogs adopted out through {DL}'s rescue over nine years.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Animal Services officer",
                        direct: ["\"I had to wear a respirator.\""],
                        cross: ["\"The dogs were fed.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find?", "\"Forty-three dogs, two rooms where you couldn't see the floor, and an ammonia reading that set off my meter. I wore a respirator to go in.\""),
                            .direct("Had you warned {DL} before?", "\"In writing, eight months earlier. Reduce to fifteen and fix the kennels. {DL} said {D.he} would.\""),
                            .cross("Was there dog food in the house?", "\"Plenty. Forty-pound bags. The dogs were fed.\""),
                            .cross("Were most of the dogs in reasonable body weight?", "\"Most, yes. The problem was the sanitation and the untreated skin.\"")
                        ]),
            WitnessSeed(name: nil, role: "County shelter veterinarian",
                        direct: ["\"Three were suffering beyond saving.\""],
                        cross: ["\"Some came in with conditions they already had.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What condition were the dogs in?", "\"Eleven had severe skin infections that had gone untreated for weeks or months. Three were in such pain from infection and untreated tumors that euthanasia was the humane choice.\""),
                            .cross("Rescues take in dogs that are already sick?", "\"All the time. We see heartworm and mange from rescues every week.\""),
                            .cross("Could some of those conditions have predated {DL}?", "\"Some. Not the weeks of neglect on top of them.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Adopter and former volunteer",
                        direct: ["\"{DL} saved dogs nobody wanted.\""],
                        cross: ["\"It got out of hand.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"I adopted two dogs from {D.him} and volunteered for three years. {DL} took the old ones, the sick ones, the ones the county was going to put down.\""),
                            .direct("What changed?", "\"Volunteers burned out. {DL} couldn't say no to a dog. By last year it was mostly {D.him} alone.\""),
                            .cross("You stopped volunteering because of the conditions?", "\"Partly. It got out of hand.\""),
                            .cross("Did you tell {DL} it was too many dogs?", "\"Every time I came over. {D.He} said they were family.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was warned eight months earlier and let 43 dogs live in filth with untreated infections. Good intentions don't excuse suffering."],
        defenseTheory: ["{DL} spent $14,000 caring for dogs nobody else would take, lost {D.his} only help, and was overwhelmed. Cruelty requires intent; this was a caregiver drowning."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: [],
        allocutions: ["\"I would have died for those dogs. I let them down. I know that.\""],
        guiltyTruths: ["Records later showed {DL} turned away an offer of volunteer cleaning help two weeks before the seizure."],
        innocentTruths: ["{DL}'s phone showed calls to four rescues the week before the seizure asking them to take dogs."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-240, "Animal Services written warning to reduce to 15 dogs."),
                       (-21, "{DL}'s volunteer quits."),
                       (-2, "Neighbor complaint about odor."),
                       (0, "Seizure of 43 dogs under a warrant."),
                       (3, "Veterinary exams; three dogs euthanized."),
                       (7, "{DL} charged.")],
            howIdentified: "{DL} owned the property and ran the rescue.",
            notDone: [],
            defendantExam: [
                .direct("Why did you have 43 dogs?", "\"Because every one of them was going to be put down somewhere else. I'd tell myself, just this one.\""),
                .direct("What happened in the last month?", "\"My helper quit. I was cleaning sixteen hours a day and falling behind. I'd called four rescues to take some. Nobody had room.\""),
                .cross("You were told eight months earlier to get down to fifteen.", "\"I got down to thirty. Then the county called me about more dogs.\""),
                .cross("Three dogs had to be put down.", "\"Two of them were dying when I took them in. I was trying to give them a home to die in.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Doctor, would a decent person keep dogs like that?\"",
                                  answer: "\"No decent person would.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "The question asks for a moral judgment, not veterinary testimony.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Forty-three dogs, two rooms of waste, and a warning ignored.",
            defenseOpening: "Nine years, two hundred adoptions, and one person who couldn't say no.",
            prosecutionClosing: "Love doesn't treat infections. {DL} let them suffer.",
            defenseClosing: "Overwhelmed isn't cruel. The law requires more.",
            residence: "Owns a house in {HOOD}, with kennels in the backyard.",
            yearsAtJob: 9
        )
    )
}
