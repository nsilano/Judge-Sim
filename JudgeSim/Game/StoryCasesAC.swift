import Foundation

private typealias E = EvidenceSeed

/// Assaults, domestic violence, threats and traffic crimes: five written trials. Follow-ups live in
/// FollowUpCasesAC.swift and are brought back by the beats in StoryAftermathAC.swift.
extension StoryCases {
    static let batchAC: [CaseTemplate] = [pickupLineDWI, phoneOnTheFloor, barStool, unmarkedCar, pruittMillRoad]

    // MARK: - The car-rider line (DWI with a child in the car)

    static let pickupLineDWI = CaseTemplate(
        key: "story.pickupLineDWI", category: .traffic,
        headlines: ["Parent Charged With DWI in Elementary School Pickup Line", "Minivan Rolls Into SUV at School; Driver Blew 0.14, Deputy Says"],
        primaryLaw: "dwi", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Drove a motor vehicle on the car-rider lane of {HOOD} Elementary School, a public vehicular area, while under the influence of an impairing substance and with an alcohol concentration of 0.08 or more, with a child under 18 in the vehicle.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly in the school car-rider lane, striking the rear of a stopped SUV.", chance: 0.5, threshold: 6)
        ],
        ageRange: 28...48, occupations: ["real estate agent", "office manager", "insurance adjuster"], hasVictim: false,
        summaries: [
            "On {DATE} at about 3:05 p.m., {D}'s gray minivan rolled into the back of a stopped SUV in the car-rider line at {HOOD} Elementary School. No one was hurt. {DL}'s seven-year-old was buckled in the back seat. The assistant principal who walked over smelled alcohol and took the keys, and the school resource deputy gave field sobriety tests in the bus loop. An insulated tumbler in the cup holder held white wine. {DL} blew 0.14 on the Intoxilyzer at 4:02 p.m. {DL} says {D.he} had one glass of wine at lunch, that the sun was in {D.his} eyes when the van crept forward, and that {D.his} acid reflux skewed the breath test."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Intoxilyzer Result", "0.14 at 4:02 p.m., 57 minutes after the bump, after a 15-minute observation period logged by the deputy."),
            E(.video, 3, "Body Camera", "The deputy's body camera records the field tests: six of six clues on the eye test, a missed heel-to-toe on four steps and a stop to steady {D.him}self on the walk-and-turn, and {DL} putting a foot down at a count of seven on the one-leg stand."),
            E(.physical, 2, "Tumbler", "An insulated tumbler from the minivan's front cup holder, about a third full of white wine. The lab confirmed 12 percent alcohol.", .search),
            E(.video, 2, "Car-Line Camera", "The school's car-line camera shows the minivan drifting forward from a full stop into the back of the SUV at walking speed, with no brake lights until after contact.")
        ],
        defenseEvidence: [
            E(.document, 1, "Lunch Receipt", "A restaurant receipt from 12:40 p.m. that day showing one glass of pinot grigio and a salad."),
            E(.document, 1, "Prescription Record", "A prescription for acid reflux medication filled two months earlier.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Assistant principal",
                        direct: ["\"I smelled it as soon as the window came down.\""],
                        cross: ["\"I'm not trained in impairment. I know what wine smells like.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What drew you to the minivan?", "\"I was working the car line and heard the bump. The van had rolled into the SUV in front of it.\""),
                            .direct("What did you notice when you reached the driver's window?", "\"A strong smell of alcohol, and the speech was slow. I asked for the keys and {DL} handed them over.\""),
                            .direct("Who else was in the van?", "\"The child, buckled in the back seat on the passenger side, crying because of the bump.\""),
                            .cross("You've never been trained to judge whether someone is impaired?", "\"No. I called the deputy for that.\""),
                            .cross("No one was hurt?", "\"No one was hurt. The SUV had a scuffed bumper.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "School resource deputy",
                        direct: ["\"Six of six clues, and 0.14 on the instrument.\""],
                        cross: ["\"The observation period was fifteen full minutes. I logged the start and end.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you observe when you reached {DL}?", "\"Red, glassy eyes, slurred speech, and an odor of alcohol. There was a tumbler of white wine in the front cup holder.\""),
                            .direct("How did {DL} do on the field sobriety tests?", "\"Six of six clues on the eye test. On the walk-and-turn, {D.he} missed heel-to-toe on four steps and stopped to steady {D.him}self. On the one-leg stand, the foot came down at seven.\""),
                            .direct("What was the breath test result?", "\"0.14 at 4:02 p.m., on an instrument certified that month.\""),
                            .cross("Did you ask about reflux before the test?", "\"I asked whether {D.he} had vomited or belched. {D.He} said no. If {D.he} had, I'd have restarted the fifteen minutes.\""),
                            .cross("You did the field tests in a bus loop, on pavement with painted lines?", "\"On a level, dry stretch of the loop. The buses had already left.\"")
                        ]),
            WitnessSeed(name: nil, role: "Driver of the SUV",
                        direct: ["\"I was at a dead stop. The van just came into me.\""],
                        cross: ["\"The sun was behind us, not in front.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened while you waited in the line?", "\"I was stopped, waiting for my son's teacher to wave us up, and I felt a thump from behind.\""),
                            .direct("Were you moving at the time?", "\"No. I was in park.\""),
                            .cross("It was a light tap?", "\"Light enough. The bumper's scuffed, nothing broken.\""),
                            .cross("The sun was low that afternoon?", "\"It was behind us. The line faces east.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend who had lunch with {DL}",
                        direct: ["\"One glass. I watched {D.him} leave half of it.\""],
                        cross: ["\"I didn't see {D.him} after one o'clock.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} drink at lunch?", "\"One glass of white wine. {D.He} didn't even finish it.\""),
                            .direct("How did {D.he} seem when you left?", "\"Normal. Tired. It's been a hard year for {D.him}.\""),
                            .cross("You didn't see {DL} between one o'clock and the pickup line?", "\"No. We split up in the parking lot around one.\""),
                            .cross("You don't know what was in the tumbler?", "\"No. I never saw a tumbler.\"")
                        ])
        ],
        prosecutionTheory: ["{D} drank, put a seven-year-old in the back seat, and drove into a school pickup line at 0.14."],
        defenseTheory: ["One glass at lunch, a low-speed bump, and a breath number thrown off by reflux. The deputy decided before the tests began."],
        aggravating: ["A child under 18 was in the vehicle (grossly aggravating factor)", "Alcohol concentration of 0.14"],
        mitigating: ["No prior criminal record", "Completed a substance abuse assessment and recommended treatment before trial"],
        allocutions: ["\"My child was in that car. I know what could have happened. I've been sober since that day, and I'm going to stay that way.\""],
        guiltyTruths: ["{DL}'s texts that morning told a friend, \"Wine o'clock started early, don't judge me.\""],
        innocentTruths: ["The Intoxilyzer used that afternoon failed its next scheduled certification, reading 0.05 high on the known sample."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "12:40 p.m.: lunch receipt, one glass of wine."), (0, "3:05 p.m.: minivan rolls into the SUV in the car-rider line."),
                       (0, "3:12 p.m.: field sobriety tests in the bus loop."), (0, "4:02 p.m.: Intoxilyzer, 0.14."), (0, "5:30 p.m.: the child released to a grandparent.")],
            howIdentified: "{DL} was behind the wheel when the assistant principal reached the van.",
            defendantExam: [
                .direct("What did you drink that day?", "\"One glass of wine at lunch. That's all.\""),
                .direct("Why did the van roll forward?", "\"The sun hit the windshield and I eased off the brake without meaning to. It was a tap.\""),
                .cross("Then whose wine was in the tumbler in your cup holder?", "\"Mine. I poured it at home that morning. I hadn't been drinking it in the car.\""),
                .cross("The line faces east, and pickup is at three in the afternoon.", "\"I know what I felt. Something was in my eyes.\""),
                .cross("Your child was in the back seat.", "\"Yes. I think about that every day.\"")
            ],
            prosecutionOpening: "A school pickup line, a seven-year-old in the back seat, and a driver at almost twice the legal limit.",
            defenseOpening: "A tap at walking speed, a single glass of wine, and a breath machine that doesn't know about reflux.",
            prosecutionClosing: "The tumbler was in the cup holder. The van moved without brake lights. The number was 0.14.",
            defenseClosing: "Nobody was hurt, and the State's case rests on a number from a machine and a deputy's judgment in a bus loop.",
            when: .months([9, 10, 11, 1, 2, 3, 4, 5]),
            time: "3:05 p.m.",
            family: "Divorced, 1 child.",
            residence: "Rents a house in {HOOD}, near the elementary school."
        )
    )

    // MARK: - The phone on the floor (assault on a female; interfering with a 911 call)

    static let phoneOnTheFloor = CaseTemplate(
        key: "story.phoneOnTheFloor", category: .violent,
        headlines: ["Man Charged After Girlfriend's 911 Call Cut Off Mid-Sentence", "Nine Seconds on a 911 Line, Then a Shattered Phone"],
        primaryLaw: "assaultFemale", lesserLaw: "simpleAssault", threshold: 6, lesserThreshold: 4,
        specification: "Assaulted {V}, a female, by striking {V.him} in the face with his hand, {D} being a male person at least 18 years of age.",
        secondary: [
            SecondaryCharge(lawID: "interferingEmergency", specification: "Intentionally prevented {V} from completing a 911 call by taking {V.his} phone from {V.his} hand and throwing it against a wall.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Willfully damaged the cell phone of {V} by throwing it against a wall.", chance: 0.5, threshold: 4)
        ],
        ageRange: 22...45, occupations: ["warehouse worker", "line cook", "mechanic", "delivery driver"], hasVictim: true,
        summaries: [
            "On {DATE} at about 11:40 p.m., {V} told {D}, {V.his} boyfriend of two years, that {V.he} was moving out of their apartment on {STREET}. They argued. {V} dialed 911; the call connected for nine seconds. On the recording {V} says \"he's—\", a man's voice says \"give me that,\" and the line goes dead after a crack. The downstairs neighbor called 911 at 11:44 to report yelling and a thud. Officers arrived at 11:52 and found {V} with a split lip and a swollen left cheek, and {V.his} phone on the floor with a shattered screen. {DL} says {D.he} took the phone so {V} wouldn't \"lie to the cops,\" and that {V} hit {V.his} face on the kitchen counter when they both grabbed for it."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "911 Recording", "Nine seconds, 11:41 p.m.: {VL} says \"he's—\"; a man's voice says \"give me that\"; a crack, then silence. The dispatcher's callback at 11:42 went unanswered."),
            E(.video, 3, "Body Camera", "Officers' body cameras show {VL} holding a towel to {V.his} mouth, the split lip and swelling on the left cheek, and the phone on the floor beneath a dent in the living room drywall."),
            E(.document, 2, "Injury Photographs", "Photographs at 12:10 a.m. of a split lower lip and swelling below the left eye, and of the same cheek two days later, bruised purple."),
            E(.statement, 2, "Statement to Officer", "{DL} told the officer at the door: \"I took the phone. I wasn't going to let {V.him} call you and make something up.\"", .statement)
        ],
        defenseEvidence: [
            E(.physical, 1, "Kitchen Counter", "A granite counter with a squared edge sits about four feet from where officers found the phone."),
            E(.statement, 1, "No Prior Calls", "Police had never been called to the apartment before.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness",
                        direct: ["\"He grabbed the phone and hit me with his open hand.\""],
                        cross: ["\"The counter was nowhere near me.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened when you told {DL} you were leaving?", "\"He started yelling and followed me from room to room. I told him to stop or I'd call the police. He laughed, so I did.\""),
                            .direct("What happened while you were on the phone with 911?", "\"He yanked it out of my hand and threw it at the wall. Then he slapped me across the face. Hard enough that I tasted blood.\""),
                            .direct("How have you been since that night?", "\"I'm staying with my sister. I jump when anyone raises their voice. I loved him, and I can't believe he did that.\""),
                            .cross("You both grabbed for the phone, didn't you?", "\"No. I was holding it. He grabbed it.\""),
                            .cross("You were standing near the kitchen counter?", "\"I was in the living room, by the couch. The counter is in the other room.\"")
                        ]),
            WitnessSeed(name: nil, role: "Downstairs neighbor",
                        direct: ["\"Yelling, a crack against the wall, and then a slap.\""],
                        cross: ["\"I couldn't see anything. I heard it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you hear that night?", "\"A man yelling, then a woman's voice saying she was calling the police. Then a crack, like something hitting the wall.\""),
                            .direct("What came after the crack?", "\"A sharp sound, like a slap, and crying. I called 911.\""),
                            .cross("You couldn't see what happened upstairs?", "\"No. I heard it through the ceiling.\""),
                            .cross("A slap and a fall can sound alike through a ceiling?", "\"A fall is a thud. This was a smack, then crying.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Responding officer",
                        direct: ["\"He told me he took the phone so she couldn't call us.\""],
                        cross: ["\"I didn't measure the distance to the counter that night. I did two days later: fourteen feet.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find when you arrived?", "\"{VL} in the living room holding a bloody towel to {V.his} mouth, swelling under the left eye, and a phone with a shattered screen on the floor under a dent in the drywall.\""),
                            .direct("What did {DL} tell you?", "\"At the door, before I asked anything, he said he took the phone because he wasn't going to let {V.him} call us and make something up.\""),
                            .direct("Where was the phone relative to the kitchen counter?", "\"In the living room, fourteen feet from the counter. I measured it when I went back for photographs.\""),
                            .cross("Did my client have any injuries?", "\"A scratch on his right forearm. He said it came from the phone grab. I photographed it.\""),
                            .cross("He didn't try to leave?", "\"No. He opened the door when we knocked.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} cut off a 911 call mid-word and struck {V} in the face for trying to leave."],
        defenseTheory: ["A frightening argument and a struggle over a phone, and an accidental fall against a counter. {DL} never meant to hurt {V}."],
        aggravating: [],
        mitigating: ["No prior criminal record", "Has completed an intake for an abuser treatment program"],
        victimImpacts: ["{V}: \"I left with a duffel bag and a broken phone. I still can't sleep in a room with the door closed.\""],
        allocutions: ["\"I shouldn't have touched that phone. I shouldn't have done any of it. I'm sorry, {V}.\""],
        guiltyTruths: ["A text {DL} sent his brother at 12:30 a.m. read: \"Cops here. I smacked {V.him}, I lost it.\""],
        innocentTruths: ["A second neighbor, awake on the balcony, saw through the window that {V} fell sideways into the counter edge as both of them pulled at the phone."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "11:30 p.m.: {VL} says {V.he} is moving out; argument begins."), (0, "11:41 p.m.: 911 call connects for nine seconds."),
                       (0, "11:42 p.m.: dispatcher callback goes unanswered."), (0, "11:44 p.m.: downstairs neighbor calls 911."),
                       (0, "11:52 p.m.: officers arrive."), (0, "12:10 a.m.: injury photographs; {DL} arrested."), (2, "Follow-up photographs and measurements.")],
            howIdentified: "{VL} named {DL}, who was in the apartment when officers arrived.",
            defendantExam: [
                .direct("Why did you take the phone?", "\"I panicked. I thought {V.he} was going to tell them I hit {V.him}, and I hadn't.\""),
                .direct("How did {V} get hurt?", "\"We were both pulling on the phone. It came loose and {V.he} fell into the counter.\""),
                .cross("The phone was fourteen feet from that counter.", "\"I threw it after. I was angry. I'm not proud of that.\""),
                .cross("The neighbor heard a slap, then crying.", "\"{V.He} hit the counter. That's what it was.\""),
                .cross("You told the officer you weren't going to let {V.him} call the police.", "\"I said that. I was upset.\"")
            ],
            prosecutionOpening: "Nine seconds of a 911 call, a man's voice saying \"give me that,\" and then silence.",
            defenseOpening: "An argument nobody is proud of, a struggle over a phone, and a fall.",
            prosecutionClosing: "He said himself why he took the phone. The neighbor heard the slap. The counter was in another room.",
            defenseClosing: "Taking a phone in an argument is wrong. It isn't proof he hit anyone.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(relationship: "The defendant's girlfriend of two years; they lived together.", harm: ["Split lower lip", "Bruised, swollen left cheek"]),
            time: "11:40 p.m.",
            family: "Single, no children. Lived with his girlfriend, the victim in this case, until that night.",
            residence: "Lived in an apartment on {STREET} in {HOOD} with the victim."
        )
    )

    // MARK: - The bar stool (assault with a deadly weapon; self-defense)

    static let barStool = CaseTemplate(
        key: "story.barStool", category: .violent,
        headlines: ["Bar Stool Swing Leaves Patron With Shattered Cheekbone", "Self-Defense or Overkill? Bar Fight Goes to Trial"],
        primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 8, lesserThreshold: 6,
        specification: "Assaulted {V} with a deadly weapon, a wooden bar stool, by striking {V.him} in the face, inflicting serious injury: fractures of the left cheekbone and eye socket requiring surgery.",
        ageRange: 24...45, occupations: ["electrician"], hasVictim: true,
        summaries: [
            "On {DATE} at about 1:15 a.m., at the Loose Caboose bar on {STREET}, {D} and {V} argued over the pool table. {V}, who had been cut off by the bartender twenty minutes earlier, shoved {DL} backward into the jukebox. The bar's camera, which has no sound, shows four seconds pass; {V} then takes a step toward {DL}, and {DL} picks up a wooden bar stool and swings it into {V}'s face. {V}'s left cheekbone and eye socket were fractured, and a surgeon set them with two titanium plates. {V} is six foot three and about 240 pounds; {DL} is five foot nine and 160. {DL} says {V} had threatened to \"put {D.him} through the window\" and was coming to do it."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Bar Camera", "No audio. 1:14:52: {VL} shoves {DL} into the jukebox. 1:14:56: {VL} steps forward, hands at chest height. 1:14:57: {DL} swings a wooden stool into the left side of {VL}'s face. {VL} falls and does not get up."),
            E(.document, 3, "Surgical Records", "Fractures of the left zygoma and orbital floor, repaired with two titanium plates. {VL} has numbness in the left cheek and double vision when looking up."),
            E(.physical, 2, "Bar Stool", "A solid oak stool, 30 inches tall, 14 pounds, with a cracked rung.")
        ],
        defenseEvidence: [
            E(.document, 2, "Blood Alcohol at Hospital", "{VL}'s blood alcohol at 2:05 a.m. was 0.21."),
            E(.statement, 2, "Cut Off", "The bartender refused {VL} service at 12:55 a.m. for shouting at another customer.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness",
                        direct: ["\"I pushed him. I didn't deserve a stool to the face.\""],
                        cross: ["\"I don't remember everything I said. I'd had a lot.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened at the pool table?", "\"We argued about whose quarters were up. I pushed him. That was wrong.\""),
                            .direct("Why did you step toward {DL} afterward?", "\"To say I was sorry, or that's what I think. Then I woke up in an ambulance.\""),
                            .direct("How has the injury affected you?", "\"Two plates in my face. My cheek is numb. When I look up, I see two of everything, so I can't work on a ladder anymore.\""),
                            .cross("You were cut off twenty minutes earlier for shouting at another customer?", "\"I was. I'd had too much.\""),
                            .cross("Did you tell {DL} you'd put {D.him} through the window?", "\"I don't remember saying it. I can't say I didn't.\"")
                        ]),
            WitnessSeed(name: nil, role: "Bartender",
                        direct: ["\"He'd been loud all night, and then the stool.\""],
                        cross: ["\"Yes, I cut {VL} off. I'd have thrown {V.him} out in another minute.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see after the shove?", "\"{DL} bounced off the jukebox. A few seconds later {VL} took a step, and {DL} grabbed the nearest stool and swung it.\""),
                            .direct("Could {DL} have left?", "\"The back door is about ten feet behind the jukebox. It was unlocked.\""),
                            .cross("You cut {VL} off for shouting at another customer?", "\"At 12:55. I'd have thrown {V.him} out in another minute.\""),
                            .cross("Did you hear {VL} threaten {DL}?", "\"I heard yelling. With the music on, I couldn't make out words.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The hands were at chest height. No fist.\""],
                        cross: ["\"The camera doesn't record sound.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the video show in the four seconds after the shove?", "\"{DL} steadies against the jukebox. {VL} stands still, then takes one step forward with hands open at chest height.\""),
                            .direct("Did you interview the other people in the bar?", "\"All six who were there. Only {DL}'s friend said anything about a threat, and that was before the shove. Nobody else could make out words over the music.\""),
                            .cross("You can't tell from the video what {VL} intended by that step?", "\"No. I can tell you what the hands were doing.\""),
                            .cross("There's no sound to tell us whether {VL} was making threats?", "\"There's no sound.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend playing pool with {DL}",
                        direct: ["\"{VL} said {V.he} would put {D.him} through the window.\""],
                        cross: ["\"I was closer than anyone. I heard it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {VL} say before the shove?", "\"That {D.he} was going to put {DL} through the front window. Said it twice.\""),
                            .direct("What did {VL} say after the shove?", "\"'I'm not done.' Then {V.he} came forward.\""),
                            .cross("You're {DL}'s friend?", "\"Since high school. I'm telling you what I heard.\""),
                            .cross("You told the detective you didn't hear what {VL} said after the shove.", "\"I was shaken up that night. I heard it.\""),
                            .cross("How many beers had you had?", "\"Three, over about three hours.\"")
                        ])
        ],
        prosecutionTheory: ["A shove is not a license to break someone's face with a fourteen-pound oak stool. {DL} had four seconds, a back door, and a choice."],
        defenseTheory: ["A drunk, cut-off man nearly twice {DL}'s size threatened to throw {D.him} through a window, shoved {D.him}, and came back for more. {DL} had a second to decide."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The victim was the initial aggressor", "Steady employment as an electrician"],
        victimImpacts: ["{V}: \"I own that I pushed him. But I live with double vision now, and I'll never climb a ladder again. I'm a roofer. Was.\""],
        allocutions: ["\"I was scared. I'm not a fighter. I'm sorry for what it did to {V}'s face. I'd do anything to take that second back.\""],
        guiltyTruths: ["{DL} told a coworker the next day, \"I saw {V.him} coming to apologize and I figured, too late.\""],
        innocentTruths: ["A customer's phone video, found later, records {VL} after the shove saying, \"You're going through the glass,\" and lunging, not stepping."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "12:55 a.m.: bartender cuts {VL} off."), (0, "1:14 a.m.: argument at the pool table; {VL} shoves {DL}."),
                       (0, "1:15 a.m.: {DL} swings the stool."), (0, "1:24 a.m.: officers and EMS arrive."), (0, "2:05 a.m.: {VL}'s blood drawn at the hospital."),
                       (3, "Surgery; two plates placed."), (6, "{DL} charged after the video is reviewed.")],
            howIdentified: "{DL} stayed at the bar and told officers {D.he} swung the stool.",
            defendantExam: [
                .direct("What did {VL} say to you?", "\"That {V.he} was going to put me through the front window. Then {V.he} shoved me so hard the jukebox skipped.\""),
                .direct("Why did you pick up the stool?", "\"{V.He} came at me again. I'm five-nine. I wasn't going to win a fight with {V.him}.\""),
                .cross("The back door was ten feet behind you.", "\"I didn't think about the door. I had a second.\""),
                .cross("{VL}'s hands were open at chest height.", "\"I saw someone twice my size coming at me.\""),
                .cross("You swung a fourteen-pound oak stool at a person's head.", "\"I swung it to stop {V.him}. I didn't aim.\"")
            ],
            prosecutionOpening: "One shove, four seconds, and an oak stool to a man's face.",
            defenseOpening: "{DL} didn't start this. A drunk, cut-off, much bigger man did.",
            prosecutionClosing: "Open hands, one step, and a back door ten feet away. Self-defense requires a reasonable belief that this much force was needed.",
            defenseClosing: "The State has to prove beyond a reasonable doubt that {DL} wasn't defending {D.him}self. The video has no sound.",
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(occupation: "Roofer (unable to work on ladders since the injury)", harm: ["Fractured left cheekbone and eye socket, two titanium plates", "Numbness in the left cheek", "Double vision when looking up"]),
            time: "1:15 a.m.",
            employer: "Brandt Electrical Contractors",
            family: "Married, 1 child.",
            yearsAtJob: 4
        )
    )

    // MARK: - The unmarked car (felony speeding to elude)

    static let unmarkedCar = CaseTemplate(
        key: "story.unmarkedCar", category: .traffic,
        headlines: ["Driver Says Fear of Fake Cop Led to 96 MPH Run From Deputy", "Four Miles, a 911 Call, and an Unmarked Charger"],
        primaryLaw: "fleeing", lesserLaw: "recklessDriving", threshold: 7, lesserThreshold: 5,
        specification: "Operated a motor vehicle on Route 17 while fleeing and attempting to elude a deputy of the Hollis County Sheriff's Office in the lawful performance of duties, while speeding more than 15 mph over the limit and driving recklessly.",
        ageRange: 21...40, occupations: ["nursing assistant"], hasVictim: false,
        summaries: [
            "On {DATE} at about 10:50 p.m., a Hollis County deputy in an unmarked gray Charger turned on the grille lights and siren behind {D}'s pickup on Route 17 for 78 mph in a 55. {DL} sped up to 96 mph and ran the red light at Route 17 and {STREET}. At 10:53, {DL} called 911 and said someone with lights was behind {D.him} and {D.he} didn't know if it was a real officer. At 10:54 the dispatcher told {D.him} it was a deputy and to pull over. {DL} slowed to about 60 and drove another 1.6 miles before stopping at a lit gas station at 10:56. The whole run was 4.1 miles. {DL} says {D.he} had read the Sheriff's warning about fake traffic stops and was doing what it said."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dash Camera", "The Charger's dash camera, with its own GPS speed overlay, shows the pickup reaching 96 mph in a 55 and running the red light at Route 17 and {STREET} at 10:52 p.m., about a minute before {DL}'s 911 call."),
            E(.digital, 3, "911 Recording", "10:53 p.m.: \"There's somebody behind me with lights and I don't know if it's real.\" 10:54: dispatcher: \"That's a Hollis County deputy. You need to pull over.\" {DL}: \"Okay. Okay.\" The pickup stops at 10:56."),
            E(.document, 2, "Pursuit Report", "4.1 miles from lights-on to stop; 2.5 miles before the dispatcher's confirmation and 1.6 miles after it.")
        ],
        defenseEvidence: [
            E(.document, 3, "Sheriff's Public Notice", "A Sheriff's Office notice issued months earlier, after a man posing as a deputy stopped drivers on Route 17: drivers may call 911 and drive to a lit, public place before pulling over."),
            E(.document, 1, "Time Card", "{DL}'s shift at Hollis Regional Medical Center ended at 10:30 p.m. that night.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Deputy who made the stop",
                        direct: ["\"Lights and siren on, and the pickup went from 78 to 96.\""],
                        cross: ["\"The Charger is unmarked. The lights are in the grille and the back window.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What happened when you activated your lights?", "\"I turned on the grille lights and siren at 10:50. Within half a mile the pickup was at 96.\""),
                            .direct("What happened at {STREET}?", "\"The light was red. The pickup went through it at about 85. A car waiting to turn had to stay put.\""),
                            .direct("How did the pickup drive after 10:54?", "\"It slowed to the low sixties, used turn signals, and pulled into the gas station.\""),
                            .cross("Your car has no markings on it?", "\"No markings. Blue and red lights in the grille and rear window, and a siren.\""),
                            .cross("You know the Sheriff told the public to drive to a lit place?", "\"I know the notice. It says to drive at a safe speed to a lit place. Not 96.\"")
                        ]),
            WitnessSeed(name: nil, role: "911 dispatcher",
                        direct: ["\"I told the caller it was a deputy at 10:54.\""],
                        cross: ["\"The caller did sound frightened.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("When did {DL}'s call come in?", "\"10:53. The caller said someone with lights was behind and asked if it was real.\""),
                            .direct("What did you tell {D.him}?", "\"I checked the deputy's location on my screen and told the caller at 10:54 that it was a Hollis County deputy and to pull over.\""),
                            .direct("When did the pickup stop?", "\"10:56, at the gas station. I stayed on the line until the deputy was at the window.\""),
                            .cross("How did the caller sound?", "\"Scared. Breathing hard.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Coworker at Hollis Regional",
                        direct: ["\"We all read the warning. We talked about it on break.\""],
                        cross: ["\"I wasn't in the truck.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Did you discuss the fake traffic stops with {DL}?", "\"The whole unit did. Half of us drive Route 17 home at night. We printed the Sheriff's notice and put it on the break room fridge.\""),
                            .direct("How did {DL} seem when the shift ended?", "\"Tired. Normal. {D.He} left at 10:35.\""),
                            .cross("You weren't in the truck that night?", "\"No. I'm telling you what we talked about.\""),
                            .cross("Did the notice say anything about speed?", "\"It said to drive at a safe speed. I remember that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} saw lights, floored it to 96, and ran a red light before making any call. The 911 call came after the dangerous part was over."],
        defenseTheory: ["{DL} did what the Sheriff told the public to do: call 911 and drive to a lit place. A scared driver isn't a fleeing driver."],
        aggravating: [],
        mitigating: ["No prior criminal record", "Called 911 during the pursuit and stopped once directed", "Steady employment as a nursing assistant"],
        allocutions: ["\"I was scared. I should have slowed down instead of speeding up. I could have hurt somebody at that light.\""],
        guiltyTruths: ["{DL}'s license was set to be suspended the next week for unpaid tickets, and {D.he} had texted a friend that week, \"if I get pulled over again I'm done.\""],
        innocentTruths: ["Two weeks earlier, {DL} had reported a car with dash lights following {D.him} on Route 17; the report was in the Sheriff's system but never connected to this case."],
        moods: [.divided], doctrines: ["burdenOfProof", "necessity"],
        story: StoryExtras(
            timeline: [(0, "10:30 p.m.: {DL}'s shift ends."), (0, "10:50 p.m.: deputy activates lights and siren on Route 17."),
                       (0, "10:52 p.m.: pickup at 96 mph; red light run at {STREET}."), (0, "10:53 p.m.: {DL} calls 911."),
                       (0, "10:54 p.m.: dispatcher confirms the deputy."), (0, "10:56 p.m.: pickup stops at a lit gas station.")],
            howIdentified: "{DL} was driving the pickup when it stopped.",
            defendantExam: [
                .direct("Why didn't you stop when the lights came on?", "\"It was a car with no markings, on the road where the fake cop had been stopping people. I was alone. I was terrified.\""),
                .direct("Why did you call 911?", "\"The Sheriff's notice said to. I wanted to know if it was real.\""),
                .cross("You hit 96 and ran a red light before you made that call.", "\"I panicked. I was trying to get away from whoever it was.\""),
                .cross("After the dispatcher told you it was a deputy, you drove another 1.6 miles.", "\"To the first lit place. I slowed down and signaled the whole way.\""),
                .cross("The notice says to drive at a safe speed.", "\"I know. I didn't, at first.\"")
            ],
            prosecutionOpening: "A siren, 96 miles an hour, and a red light, all before a single phone call.",
            defenseOpening: "The Sheriff told drivers on Route 17 to call 911 and drive to a lit place. {DL} did.",
            prosecutionClosing: "The fear may have been real. The 96 was real too, and so was the red light.",
            defenseClosing: "Fleeing means trying to get away from a known officer. {DL} called the police to ask if it was the police.",
            time: "10:50 p.m.",
            employer: "Hollis Regional Medical Center",
            family: "Single, no children.",
            yearsAtJob: 2
        )
    )

    // MARK: - Pruitt Mill Road (felony hit and run, a thin identification)

    static let pruittMillRoad = CaseTemplate(
        key: "story.pruittMillRoad", category: .traffic,
        headlines: ["Pedestrian Struck, Left on Pruitt Mill Road; Pickup Owner Charged", "Hit-and-Run Case Rests on a Mirror Fragment"],
        primaryLaw: "hitAndRun", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Being the driver of a vehicle involved in a crash on Pruitt Mill Road that caused serious bodily injury to {V}, and knowing or having reason to know of the crash, willfully failed to stop and remain at the scene.",
        ageRange: 30...60, occupations: ["farm equipment mechanic", "HVAC technician", "truck driver"], hasVictim: true,
        summaries: [
            "On {DATE} at about 11:20 p.m., {V} was walking home from a shift at the poultry plant along the shoulder of Pruitt Mill Road when a vehicle struck {V.him} from behind and kept going. A passing driver found {V} in the ditch at 11:35. {V.His} left femur and pelvis were broken. Troopers recovered a piece of a passenger-side mirror housing from a 2014-2018 Chevrolet Silverado, silver. Eleven days later an anonymous caller named {D}, who lives three miles from the scene and drives a silver 2016 Silverado. Its passenger mirror had been replaced with a used one, and its right front fender was dented. {DL} says a deer did the fender two weeks before the crash, a mailbox took the mirror, and {D.he} was home asleep that night."
        ],
        prosecutionEvidence: [
            E(.physical, 2, "Mirror Fragment", "A piece of silver passenger-side mirror housing found 20 feet from where {VL} lay. The part number fits 2014-2018 Silverados."),
            E(.forensic, 2, "Paint Comparison", "Paint on the fragment matches the factory silver of {DL}'s truck. The analyst testified that the same paint was used on every silver Silverado of those years."),
            E(.document, 2, "Salvage Yard Receipt", "{DL} bought a used passenger mirror for a 2016 Silverado at a salvage yard four days after the crash, paying $45 in cash.", .search),
            E(.video, 1, "Store Camera", "A convenience store camera 1.2 miles from the scene shows a silver pickup passing toward Pruitt Mill Road at 11:17 p.m. The plate can't be read.")
        ],
        defenseEvidence: [
            E(.document, 3, "Registrations", "DMV records list 1,140 silver 2014-2018 Silverados registered in Hollis and the two neighboring counties."),
            E(.forensic, 2, "No Trace Evidence", "The lab found no blood, fibers or hair on {DL}'s truck."),
            E(.digital, 2, "Phone Search", "A search of {DL}'s phone under a warrant found no calls, texts or web searches about the crash.", .search)
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Pedestrian who was struck",
                        direct: ["\"Headlights behind me, then the ditch.\""],
                        cross: ["\"I never saw the vehicle. Not the color, not the shape.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What do you remember about that night?", "\"Walking home after second shift, on the shoulder like always. Headlights came up behind me, and then I was in the ditch and couldn't move my leg.\""),
                            .direct("How long were you there?", "\"I don't know. It felt like hours. I kept calling out. Somebody finally stopped.\""),
                            .direct("How has the injury changed your life?", "\"Three surgeries. I walk with a cane. I couldn't go back to the plant, and whoever did it never even slowed down. That's what I can't get past.\""),
                            .cross("You never saw what hit you?", "\"No. I saw lights. That's all.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Highway Patrol crash reconstructionist",
                        direct: ["\"The fragment came from that model and that color.\""],
                        cross: ["\"It fits every one of them, not just this truck.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you recover at the scene?", "\"A piece of passenger-side mirror housing, 20 feet north of where {VL} was found, and nothing else from the vehicle.\""),
                            .direct("What vehicles does it fit?", "\"Chevrolet Silverado, model years 2014 through 2018. The paint is the factory silver.\""),
                            .cross("Can you say the fragment came from my client's truck?", "\"No. The mirror that was on it is gone. I can say it came from a truck like it.\""),
                            .cross("Did the dent on the fender match the height of a pedestrian's hip?", "\"It's in the right range. A deer would be in that range too.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Trooper who investigated",
                        direct: ["\"A replacement mirror bought four days after, for cash.\""],
                        cross: ["\"The tip was anonymous. We never identified the caller.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you come to {DL}?", "\"An anonymous caller eleven days after the crash said {DL}'s silver Silverado had a new mirror and a dent.\""),
                            .direct("What did you find?", "\"A used passenger mirror, bought at a salvage yard four days after the crash for $45 cash, and a dent on the right front fender.\""),
                            .direct("What else did you check?", "\"The store camera, which shows a silver pickup at 11:17 with an unreadable plate, the truck for trace evidence, and {DL}'s phone and location records by warrant.\""),
                            .cross("What did the phone location records show?", "\"The phone was on the tower that serves both {DL}'s house and that stretch of Pruitt Mill Road all night. It doesn't tell us which.\""),
                            .cross("How many trucks like this are registered in the area?", "\"1,140 in the three counties. We looked at the ones with recent repairs that we could find.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s spouse",
                        direct: ["\"We went to bed around ten. The truck was in the driveway.\""],
                        cross: ["\"I was asleep. I can't swear to every minute.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where was {DL} that night?", "\"Home. We watched the news and went to bed around ten.\""),
                            .direct("Do you know how the fender got dented?", "\"A deer, on the way back from my mother's, about two weeks before. I was in the passenger seat.\""),
                            .cross("You were asleep by 10:30?", "\"Yes.\""),
                            .cross("So you can't say whether the truck left the driveway at eleven?", "\"I'd have heard it. It's loud. But I was asleep, so no, I can't swear to it.\""),
                            .cross("Why didn't the deer strike get reported to insurance?", "\"The dent wasn't worth the deductible.\"")
                        ])
        ],
        prosecutionTheory: ["A silver Silverado hit {V} and left a piece of its mirror behind. Four days later {DL} paid cash for a used mirror for {D.his} silver Silverado."],
        defenseTheory: ["There are 1,140 trucks like this one in three counties. A mailbox, a deer, and an anonymous tip don't prove who was driving on Pruitt Mill Road."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I used to walk that road every night. Now I can't walk to the mailbox without a cane, and I still don't know who left me there.\""],
        allocutions: ["\"I'm sorry for what happened to {V}. I wasn't on that road. That's all I can say.\""],
        guiltyTruths: ["The salvage yard's owner later found the original mirror in the scrap pile, cracked, with a strand of dark fabric in the hinge."],
        innocentTruths: ["A Silverado owner in the next county confessed to his pastor that he hit something on Pruitt Mill Road that night, and the pastor persuaded him to call the Highway Patrol."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "eyewitnessID"],
        story: StoryExtras(
            timeline: [(0, "11:17 p.m.: silver pickup on the store camera, 1.2 miles away."), (0, "11:20 p.m.: {VL} struck on Pruitt Mill Road."),
                       (0, "11:35 p.m.: passing driver finds {VL}."), (4, "{DL} buys a used mirror at a salvage yard."),
                       (11, "Anonymous tip names {DL}."), (14, "Truck examined; phone searched by warrant."), (30, "{DL} charged.")],
            howIdentified: "An anonymous tip, then the salvage yard receipt and the dented fender.",
            notDone: ["The anonymous caller was never identified."],
            defendantExam: [
                .direct("Where were you at 11:20 that night?", "\"In bed. I get up at five for work.\""),
                .direct("What happened to your mirror?", "\"I clipped a mailbox backing out of a job site the weekend after. I bought a used one because a new one was $300.\""),
                .cross("You bought it four days after a pedestrian was hit by a truck like yours.", "\"I didn't know anyone had been hit. I don't read the news.\""),
                .cross("Whose mailbox was it?", "\"A farm on Route 9. I didn't stop to tell them. It was already leaning.\""),
                .cross("You paid cash.", "\"I always pay cash at the salvage yard.\"")
            ],
            prosecutionOpening: "A piece of mirror at the scene, and a cash purchase of a replacement mirror four days later.",
            defenseOpening: "One thousand one hundred forty trucks, and the State picked the one an anonymous caller named.",
            prosecutionClosing: "Same model, same paint, same side, a new mirror four days later, and a dent in the right place.",
            defenseClosing: "{V} deserves an answer. A coincidence isn't one.",
            victim: VictimFacts(occupation: "Poultry plant worker (unable to return)", relationship: "Strangers.", harm: ["Broken left femur", "Fractured pelvis", "Three surgeries; walks with a cane"]),
            time: "11:20 p.m.",
            family: "Married, no children.",
            residence: "Lives in a house about three miles from the crash site on Pruitt Mill Road.",
            scene: "the shoulder of Pruitt Mill Road"
        )
    )
}
