import Foundation

private typealias E = EvidenceSeed

/// Alternate tellings of the street takeover story.
extension StoryVariants {
    static let variantsY: [CaseTemplate] = [streetTakeoverV1, streetTakeoverV2]

    /// A plaza lot beside an apartment complex, and a car someone else may have been driving.
    static let streetTakeoverV1 = CaseTemplate(
        key: "story.streetTakeover", category: .traffic,
        headlines: ["Lot Takeover Ends With Car Plowing Into Apartment Parking", "Organizer Charged After Spinning Car Hits Residents' Vehicles"],
        primaryLaw: "injuryPersonalProperty", lesserLaw: nil, threshold: 9, lesserThreshold: 0,
        specification: "Willfully and wantonly injured personal property of {V}, a Honda Civic and a Ford Ranger parked at Willow Run Apartments, causing damage of $11,800, when a car {D} drove in a takeover {D} organized struck them.",
        secondary: [
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Willfully and wantonly injured real property of Willow Run Apartments, a mail kiosk and a dumpster enclosure, causing damage of $4,100.", chance: 1.0, threshold: 8),
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly in willful disregard of the rights and safety of others, spinning a car at speed in a lot full of spectators and parked cars.", chance: 1.0, threshold: 6),
            SecondaryCharge(lawID: "riot", specification: "Willfully engaged in a riot, a public disturbance by an assemblage of three or more persons that, by disorderly conduct, damaged property at the Parkside Plaza lot.", chance: 0.5, threshold: 8)
        ],
        ageRange: 20...34, occupations: ["welder", "forklift operator", "HVAC installer"], hasVictim: true,
        summaries: [
            "From 10:40 p.m. on {DATE}, drivers poured into the Parkside Plaza lot in {HOOD}, empty since the grocery store left, for a meet that {D} had organized in a group chat called plaza_nights. About thirty cars and a hundred spectators lined the access road while drivers took turns spinning in the open lot. At 11:14 p.m. a black Subaru WRX lost its tail on a spin, crossed the access lane, and hit two cars in the visitor row of the Willow Run Apartments next door, then a mail kiosk and a dumpster enclosure. {V}, a resident, owns both cars: a Honda Civic and an old Ford Ranger. The damage to the two cars came to $11,800. The WRX is registered to {D}. {D} says someone else was driving it."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Apartment Building Camera", "A black Subaru WRX slides sideways across the access lane at 11:14 p.m. and hits the Civic and the Ranger in the visitor row, then clips the mail kiosk. The glare off the windshield hides the driver."),
            E(.digital, 3, "Live Stream", "A spectator's stream at 11:11 p.m. shows {DL} in the WRX's driver seat, revving the engine and saying, \"Watch this, I'm going all the way around.\""),
            E(.forensic, 2, "Paint and Registration", "Blue paint on the WRX's right rear bumper is consistent with the Civic's factory blue. The WRX is registered to {DL}."),
            E(.physical, 3, "WRX Damage", "The WRX's right rear bumper and quarter panel are crushed; a taillight is gone. The car was parked behind {DL}'s house the next morning."),
            E(.digital, 2, "Group Chat Export", "From {DL}'s account at 10:31 p.m.: \"Lot opens at 10:45. First spin is mine. Keep the visitor row clear.\" At 11:16 p.m.: \"Everyone out now, go.\""),
            E(.document, 2, "Repair Estimates", "Civic: $7,400. Ranger: $4,400. Mail kiosk and dumpster enclosure: $4,100.")
        ],
        defenseEvidence: [
            E(.video, 2, "Second Phone Clip", "A clip at 11:12 p.m. shows {DL} standing at the open driver's door of the WRX, handing something to a taller person in a gray hoodie. The clip ends before the car moves."),
            E(.statement, 1, "Borrowed Keys", "{DL} says {D.he} gave the keys to a friend called Kai for one spin and walked to the curb."),
            E(.document, 1, "Spin Lane Map", "A sketch the group chat posted marking the spin lane in the open lot, with the visitor row to be kept clear.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sheriff's deputy, patrol",
                        direct: ["\"There was rubber on the access lane and glass in the visitor row. The crowd was gone when I got there.\""],
                        cross: ["\"I didn't see who got out of the car.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("When did you get there?", "\"A resident called at 11:15 about a crash. I arrived at 11:27. The lot was almost empty, a few cones and about a dozen people walking away.\""),
                            .direct("What did you find?", "\"A Civic and a Ranger pushed together in the visitor row, a mail kiosk knocked over, and a dumpster enclosure leaning. A trail of rubber ran from the lot across the access lane.\""),
                            .direct("Where was the WRX?", "\"Gone. We found it the next morning parked behind {DL}'s house with the right rear crushed.\""),
                            .direct("Did you speak with {DL}?", "\"That morning. {D.He} said {D.he} had organized the meet and was at the curb when the car went. {D.He} said a friend named Kai was driving.\""),
                            .cross("You never saw anyone get out of the WRX?", "\"No. I arrived twelve minutes after the crash.\""),
                            .cross("Did you ever find Kai?", "\"No. {DL} gave a first name and no number.\""),
                            .cross("The building camera can't show who was driving?", "\"Correct. The windshield reflects the lights.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Resident of Willow Run Apartments, owner of the Civic and the Ranger",
                        direct: ["\"They were my only two vehicles, and I need both to get to work.\""],
                        cross: ["\"I was asleep. I didn't see it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you at 11:14 p.m.?", "\"Asleep in my apartment, second floor. A neighbor knocked about ten minutes later.\""),
                            .direct("What did you see?", "\"My Civic and my Ranger smashed together and a piece of a taillight on the ground. The mail kiosk was on its side.\""),
                            .direct("What did it cost?", "\"The Civic was $7,400 and the Ranger $4,400. I have no collision coverage on the Ranger.\""),
                            .direct("How did you get to work?", "\"I borrowed a car for three weeks, then took the bus.\""),
                            .cross("You didn't see who was driving?", "\"No.\""),
                            .cross("The visitor row is next to the access lane?", "\"Yes, about twelve feet.\"")
                        ]),
            WitnessSeed(name: nil, role: "Sheriff's detective, phone and live stream records",
                        direct: ["\"The stream shows {DL} getting into the WRX and saying 'watch this.'\""],
                        cross: ["\"The stream doesn't show the crash.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you find the stream?", "\"A spectator posted it publicly at 11:11. We downloaded it the next morning.\""),
                            .direct("What does it show?", "\"{DL} in the driver's seat, the dash lights, {D.him} saying 'watch this, I'm going all the way around.' Then the stream cuts to the crowd.\""),
                            .direct("What did {DL}'s chat say?", "\"At 10:31, 'first spin is mine, keep the visitor row clear.' At 11:16, 'everyone out now, go.'\""),
                            .direct("Did you look for a Kai?", "\"There is no Kai in the group chat or in {DL}'s phone contacts.\""),
                            .cross("The 11:12 clip shows {DL} outside the car?", "\"It shows {DL} at the open door, handing something to a taller person in a gray hoodie.\""),
                            .cross("That could be keys?", "\"It could be. It could also be a drink.\""),
                            .cross("The stream stops before the car moves?", "\"Yes. About three minutes pass between the stream and the crash.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Crime Laboratory trace evidence examiner",
                        direct: ["\"The blue paint on the WRX's bumper is consistent with the Civic's.\""],
                        cross: ["\"I can say the car hit the Civic, not who drove it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you compare?", "\"Blue paint smears on the WRX's right rear bumper and a sample from the Civic's door.\""),
                            .direct("What did you find?", "\"The layers and pigments match the Civic's factory blue, in the same order.\""),
                            .direct("Does that tie the WRX to the crash?", "\"Yes. It ties that bumper to that Civic. It says nothing about who was behind the wheel.\""),
                            .cross("Nothing in your examination identifies the driver?", "\"Nothing.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Spectator who streamed the meet",
                        direct: ["\"I saw {DL} hand the keys to someone in a hoodie right before the spin.\""],
                        cross: ["\"I didn't see the face of the person who drove.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why were you at the meet?", "\"I stream car stuff. I know most of the regulars by sight.\""),
                            .direct("What did you see at 11:12?", "\"{DL} got out of the WRX, held the door, and handed keys to somebody taller in a gray hoodie. I filmed it on my second phone.\""),
                            .direct("Did you know the person in the hoodie?", "\"I've seen Kai at other meets. I only know a first name.\""),
                            .direct("Where was {DL} when the car spun?", "\"Standing at the curb with the cones. I saw {D.him} yelling at the crowd to back up.\""),
                            .cross("You didn't see the driver's face at the crash?", "\"No. It was moving too fast.\""),
                            .cross("You and {DL} are friends?", "\"We know each other from the meets.\""),
                            .cross("You never gave Kai's full name to deputies?", "\"They never asked me. I don't have one.\"")
                        ])
        ],
        prosecutionTheory: ["{D} organized the meet, announced {D.his} own spin, and drove the WRX into the residents' cars."],
        defenseTheory: ["{DL} organized the meet but handed the keys to another driver before the spin. Registration shows whose car it was, not who was driving."],
        aggravating: ["The visitor row sat twelve feet from the spin lane with spectators at the curb", "{DL} announced the spin in the group chat beforehand"],
        mitigating: ["No prior criminal record", "{DL} has offered to pay for the Civic", "No one was hurt"],
        victimImpacts: ["{VL}: \"I live on the second floor. I came down to a car wrapped around my truck. I was without a car for three weeks, and I had to take the bus to work.\""],
        allocutions: ["\"I started that meet, and I put those cars in danger. I'm sorry to the people who live there.\""],
        guiltyTruths: ["Kai held the keys for a moment, handed them back, and {DL} made the final spin {D.himself}."],
        innocentTruths: ["A third phone video, never turned over, shows the person in the gray hoodie in the WRX's driver seat as the spin begins."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "eyewitnessID", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-2, "The plaza_nights group chat posts the meet."),
                       (0, "10:31 p.m.: {DL}'s chat says the lot opens at 10:45. 10:40 p.m.: Cars begin arriving at the Parkside Plaza lot. 11:11 p.m.: A live stream shows {DL} in the WRX. 11:12 p.m.: A second clip shows {DL} at the open driver's door. 11:14 p.m.: The WRX slides into the visitor row. 11:27 p.m.: A deputy arrives."),
                       (1, "Deputies find the WRX behind {DL}'s house with the right rear crushed, and take the stream and building camera video."),
                       (1, "{DL} tells a deputy that a friend named Kai was driving."),
                       (12, "A search warrant for {DL}'s phone and the group chat returns no contact named Kai."),
                       (22, "State Crime Laboratory reports the WRX's bumper paint is consistent with the Civic's."),
                       (30, "{DL} charged.")],
            howIdentified: "The WRX was registered to {DL}, and a public live stream showed {DL} in its driver's seat three minutes before the crash.",
            notDone: ["No one ever found the person {DL} calls Kai.", "The spectator's other phone was not examined for more video."],
            defendantExam: [
                .direct("Tell the court about the night.", "\"I organized the meet. I posted it, I set the cones, and I told people to keep the visitor row clear. I did the first spin to get it started.\""),
                .direct("What happened after your spin?", "\"I got out around 11:12 and Kai asked to try it. I gave Kai the keys and walked to the curb with the cones.\""),
                .direct("Who is Kai?", "\"A guy I know from other meets. I only know the name. I wish I knew more.\""),
                .direct("What did you see at 11:14?", "\"I heard the engine and then the crash. I yelled at everybody to back up, and then I told them to go.\""),
                .direct("What happened to your car?", "\"Kai drove off in it. I found it behind my house the next morning with the back crushed.\""),
                .cross("You told the crowd it was your spin.", "\"The first one. Not the one that crashed.\""),
                .cross("You can't give a last name or number for Kai.", "\"No. I don't have either.\""),
                .cross("You got the car back and didn't call police or {V}.", "\"I was scared. I should have.\""),
                .cross("You knew the visitor row was twelve feet from the spin lane.", "\"I told everyone to keep it clear. I knew it was close.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Isn't it true people who organize takeovers always drive the first car?\"",
                                  answer: "\"In the ones I've seen, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation; other events", shouldSustain: true,
                                  explanation: "What happened at other takeovers doesn't show who drove this one. The question is who was in the WRX at 11:14 p.m.",
                                  doctrineID: "speculation", weight: 1)),
                (4, ObjectionSeed(question: "Prosecutor: \"Isn't it true {DL} told you Kai is just a name {D.he} made up?\"",
                                  answer: "\"{D.He} never said that.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Assumes facts not in evidence", shouldSustain: true,
                                  explanation: "No evidence shows {DL} ever said that. A question that assumes a statement nobody has proved puts a fact before the court that isn't there.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "{D} organized the meet, announced a spin, climbed into a black WRX, and said 'watch this.' Three minutes later that car slid into the Civic and Ranger of a family who lives next door. {D} says someone called Kai was driving, but no Kai appears in the chat, in {D.his} phone, or anywhere else.",
            defenseOpening: "{DL} started the meet and takes responsibility for that. But the one thing the State has to prove is who was in the driver's seat at 11:14 p.m. A second clip shows {DL} handing the keys to someone in a hoodie, and a third camera shows nothing at all.",
            prosecutionClosing: "It's {DL}'s car, {DL}'s meet, and {DL}'s announced spin. A friend with no last name, no number and no face is not a defense. The paint ties the WRX to the Civic. {DL} owns what it did.",
            defenseClosing: "Registration proves who owns a car, not who drove it. The State's own video shows {DL} giving the keys away before the car moved. If the court has a doubt about who sat in that seat at 11:14, it has to resolve it for {DL}.",
            victim: VictimFacts(age: 41, occupation: "Plumber", harm: ["No physical injury. The Civic and the Ranger were damaged, and the owner was without a car for three weeks."], restitution: 11800, restitutionBasis: "a Honda Civic and a Ford Ranger damaged in the visitor row"),
            time: "11:14 p.m.",
            scene: "the Parkside Plaza lot and the visitor row of the Willow Run Apartments in {HOOD}"
        )
    )

    /// A fairgrounds lot in the rain, and whether sliding on wet pavement can be willful.
    static let streetTakeoverV2 = CaseTemplate(
        key: "story.streetTakeover", category: .traffic,
        headlines: ["Rainy Fairgrounds Takeover Ends With Car Hitting Food Truck", "Meet Organizer Charged After Car Slides Into Vendor Row"],
        primaryLaw: "injuryPersonalProperty", lesserLaw: nil, threshold: 9, lesserThreshold: 0,
        specification: "Willfully and wantonly injured personal property of {V}, a food truck and a pickup truck parked at the county fairgrounds, causing damage of $13,700, when a car {D} drove in a takeover {D} organized slid into them.",
        secondary: [
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Willfully and wantonly injured real property of the county agricultural society, a section of fence and a light pole at the fairgrounds, causing damage of $2,800.", chance: 1.0, threshold: 8),
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly in willful disregard of the rights and safety of others, spinning a car on wet pavement near parked vehicles and spectators.", chance: 1.0, threshold: 6),
            SecondaryCharge(lawID: "riot", specification: "Willfully engaged in a riot, a public disturbance by an assemblage of three or more persons that, by disorderly conduct, damaged property at the county fairgrounds.", chance: 0.5, threshold: 8)
        ],
        ageRange: 20...34, occupations: ["auto body technician", "delivery driver", "diesel mechanic"], hasVictim: true,
        summaries: [
            "On the night of {DATE} it rained steadily in {HOOD}. After a car show ended at the county fairgrounds at 9 p.m., {D} told the group chat the meet would continue in the big gravel-and-asphalt lot behind the grandstand. About forty cars and eighty spectators stayed. At 10:52 p.m., a white Nissan 370Z that {D} was driving slid out of a spin and hit a food truck and a pickup truck parked in the vendor row, then a section of fence and a light pole. {V}, who runs the food truck and owns the pickup, counted $13,700 in damage to the two vehicles. Deputies took the first 911 call at 10:55 p.m. {D} says the wet pavement, not {D.his} driving, caused the slide."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Fairgrounds Gate Camera", "At 10:52 p.m. a white car slides sideways across the lot and strikes the vendor row. The same car had spun in the same area at 10:31, 10:38 and 10:44 p.m."),
            E(.digital, 3, "In-Car Video", "Footage recovered from a camera on {DL}'s dash shows {DL} laughing and saying, \"The rain makes it better\" during the spins, then a hard slide at 10:52 p.m."),
            E(.document, 3, "Fairgrounds Rules", "A posted rule that no car show participant may drive in the back lot after 9 p.m. The sign is visible at the gate."),
            E(.physical, 2, "Nissan Damage", "The Z's right front fender is crushed and its right headlight is gone. It was parked behind {DL}'s house the next morning."),
            E(.document, 2, "Repair Estimates", "Food truck: $9,900. Pickup truck: $3,800. Fence and light pole: $2,800."),
            E(.digital, 2, "Group Chat Export", "From {DL}'s account at 9:14 p.m.: \"Rain or not, meet moves to the back lot. Vendors stay behind the cones.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Weather Record", "A weather station recorded 0.6 inches of rain between 9 and 11 p.m. The back lot has gravel patches and no drain on the north end."),
            E(.statement, 1, "Slick Lot", "{DL} says the lot was slick and the car got away from {D.him} on a normal turn."),
            E(.document, 1, "Cone Photos", "Photos show cones set in a line twenty-five feet in front of the vendor row.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sheriff's deputy, patrol",
                        direct: ["\"The marks run for sixty feet toward the vendor row. The pavement was wet, but the marks were deliberate spins.\""],
                        cross: ["\"I didn't see the Z move.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("When did you respond?", "\"A fairgrounds guard called at 10:55. I got there at 11:08. Most of the cars had already gone out the back.\""),
                            .direct("What did you find?", "\"A food truck with its side caved in, a pickup pushed against it, a fence section down and a light pole leaning. Glass on the pavement.\""),
                            .direct("What did the marks tell you?", "\"Four sets of spin marks in the same area, one running sixty feet from the middle of the lot to the vendor row. Wet roads don't draw circles like that.\""),
                            .direct("Where was the Nissan?", "\"We found it behind {DL}'s house the next morning with the right front crushed.\""),
                            .cross("You weren't there when it happened?", "\"No. Thirteen minutes later.\""),
                            .cross("It was raining hard?", "\"A steady rain. The lot was wet and the north end had standing water.\""),
                            .cross("Cones were set in front of the vendor row?", "\"Yes, twenty-five feet out. The car went through them.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Owner of the food truck and pickup truck",
                        direct: ["\"They didn't just hit my truck. They hit my living.\""],
                        cross: ["\"I was inside the food truck when it hit.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you at 10:52?", "\"Inside the food truck, wiping down the grill. We were packing up late because the rain slowed everybody.\""),
                            .direct("What happened?", "\"I heard the engine, then a bang, and the whole truck jumped. The generator shifted and the side panel buckled.\""),
                            .direct("What did it cost?", "\"$9,900 to fix the truck and $3,800 for the pickup. I missed two weeks of events, which isn't in the estimates.\""),
                            .direct("Did anyone tell you to move?", "\"A guy told us to stay behind the cones. He said we'd be fine. Nobody said the cars would be sliding toward us.\""),
                            .cross("You stayed in the vendor row after the show ended?", "\"We were packing up. The rain delayed us.\""),
                            .cross("The cones were between the lot and your truck?", "\"They were, but twenty-five feet isn't far.\"")
                        ]),
            WitnessSeed(name: nil, role: "Sheriff's detective, video and phone records",
                        direct: ["\"The in-car video shows {DL} choosing to spin on wet pavement for twenty minutes before the slide.\""],
                        cross: ["\"The video shows {DL} braking just before the slide.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you get the in-car video?", "\"A search warrant for the Nissan and for the memory card in its dash camera.\""),
                            .direct("What did it show?", "\"Three spins before the slide. {DL} says 'the rain makes it better.' At 10:52, a spin starts at about thirty miles an hour and the car goes into the vendor row.\""),
                            .direct("What did the group chat say?", "\"At 9:14 p.m., {DL} told people the meet would move to the back lot and that vendors should stay behind the cones.\""),
                            .direct("Did {DL} tell people to leave?", "\"At 11:02: 'everybody go.' That was ten minutes after the slide.\""),
                            .cross("The video shows {DL} braking before the slide?", "\"Yes. The brake lights come on about a second before the car starts to slide.\""),
                            .cross("Nothing on the video shows {DL} aiming at the trucks?", "\"No. It shows a driver who lost control.\"")
                        ]),
            WitnessSeed(name: nil, role: "Fairgrounds security guard",
                        direct: ["\"I told {DL} at 9:30 that the lot was closed to driving.\""],
                        cross: ["\"I didn't call deputies until the crash.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened at 9:30?", "\"I walked back and told {DL} the lot was closed to cars after 9. {D.He} said they'd be quick.\""),
                            .direct("Did you tell anyone else?", "\"I told the show manager. He said he'd handle it. I went back to the gate.\""),
                            .cross("You didn't call deputies at 9:30?", "\"No. I thought they'd leave.\""),
                            .cross("You can't say what was said to the vendors?", "\"No. I wasn't there.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pavement and traction consultant",
                        direct: ["\"On that lot, in that rain, any car can break loose on a turn.\""],
                        cross: ["\"I wasn't there that night.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you review?", "\"The weather record, photos of the lot, and the in-car video. I also tested a sample of the surface.\""),
                            .direct("What did you find?", "\"A thin wet film over polished asphalt and a gravel patch at the north end cuts friction badly. A rear-drive car can lose the rear at fairly low speed there.\""),
                            .direct("Does the video show {DL} braking?", "\"Yes. Hard braking at the start of the slide. Braking on that surface makes the slide worse.\""),
                            .cross("{DL} had spun on the same surface three times before?", "\"The video shows that.\""),
                            .cross("Doing donuts on wet asphalt makes a slide more likely?", "\"Yes. It increases the risk.\""),
                            .cross("A careful driver would have stopped?", "\"A careful driver would not have been there.\"")
                        ])
        ],
        prosecutionTheory: ["{D} organized the meet, spun a car on wet pavement four times beside the vendor row, and wrecked {V}'s trucks on the fourth."],
        defenseTheory: ["The lot was slick and the slide was an accident, not a willful act. {DL} is guilty of reckless driving at most."],
        aggravating: ["{DL} was told the lot was closed to driving at 9:30 p.m.", "{DL} spun on the same wet pavement four times beside parked trucks"],
        mitigating: ["No prior criminal record", "{DL} has offered to repay part of the damage", "No one was hurt"],
        victimImpacts: ["{VL}: \"I was inside. If that truck had come in a few feet further, I'd have been under it. Two weeks without events cost me more than the repair.\""],
        allocutions: ["\"I told people to stay behind the cones, and I still put them in the way. I'm sorry for what it did to {VL}'s work.\""],
        guiltyTruths: ["{DL} had planned the spins on the wet lot and told a friend beforehand it would be 'the best slide night yet.'"],
        innocentTruths: ["The north end of the lot had standing water from a blocked drain that the fairgrounds had been told about in the spring."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(0, "9 p.m.: The car show ends. 9:14 p.m.: {DL} moves the meet to the back lot in the group chat. 9:30 p.m.: A guard tells {DL} the lot is closed to driving. 10:31 p.m.: The first spin. 10:52 p.m.: The Nissan slides into the vendor row. 10:55 p.m.: First 911 call. 11:08 p.m.: A deputy arrives."),
                       (1, "Deputies find the Nissan behind {DL}'s house and take the gate camera footage."),
                       (5, "A search warrant for the Nissan's dash camera and {DL}'s phone."),
                       (14, "The dash camera footage is recovered."),
                       (20, "A pavement consultant hired by the defense tests the lot surface."),
                       (28, "{DL} charged.")],
            howIdentified: "The gate camera showed a white Nissan 370Z; the group chat's organizer, {DL}, owns one and drove it that night.",
            notDone: ["The show manager who was told at 9:30 that the lot was closed was never interviewed.", "No one measured the surface's friction in the rain until the defense did."],
            defendantExam: [
                .direct("Tell the court about the night.", "\"The car show ended at nine and it was pouring. I thought, let's keep the meet going in the back lot. I told people to keep vendors behind the cones.\""),
                .direct("Were you told the lot was closed?", "\"A guard said it was closed to cars after nine. I said we'd be quick. I should have left it there.\""),
                .direct("What did you do?", "\"A few spins to get it going. Three or four. I figured the rain made it safe because it's slower.\""),
                .direct("What happened at 10:52?", "\"I started a turn and the rear came around. I braked. It got worse. I couldn't stop it.\""),
                .direct("What did you do after?", "\"I stopped, looked, saw the truck. I told people to go because I panicked.\""),
                .cross("You said on camera 'the rain makes it better.'", "\"I did. I was wrong about that.\""),
                .cross("You spun four times on that surface before the slide.", "\"Yes.\""),
                .cross("You were twenty-five feet from the vendor row.", "\"I thought that was enough. It wasn't.\""),
                .cross("You left and didn't talk to {V}.", "\"I was scared. I would handle it differently now.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Is it fair to say anyone who does donuts on wet pavement intends to wreck something?\"",
                                  answer: "\"I'd say they accept the risk.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation; calls for opinion on intent", shouldSustain: true,
                                  explanation: "Whether {DL} intended to damage anything is the question the court decides. A deputy can describe what the marks show, but not what was in the driver's mind.",
                                  doctrineID: "speculation", weight: 1)),
                (3, ObjectionSeed(question: "Prosecutor: \"What did the show manager tell you about the lot?\"",
                                  answer: "\"He said he'd handle it.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: false,
                                  explanation: "The manager's reply isn't offered for its truth. It shows what the guard did next, so it isn't hearsay.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "The lot was posted closed to driving, a guard told {D} to stop, and {D} spun a white Nissan on wet pavement four times beside a row of parked trucks. On the fourth, the car slid into {V}'s food truck. The State will prove that was willful and wanton, not bad luck.",
            defenseOpening: "It was a rainy night, a slick lot and a driver who braked and still couldn't stop. That's reckless, and {DL} will say so. But the State has to prove a willful, wanton injury to {V}'s truck, and the video shows {D.him} trying to stop.",
            prosecutionClosing: "Four spins on wet pavement, twenty-five feet from a food truck, after being told to stop. {DL} made the risk, took it, and lost. The law calls that wanton.",
            defenseClosing: "Nobody wanted that truck hit. The video shows brake lights, the expert shows a slick surface, and the cones were where {DL} said they'd be. The State proved recklessness. It didn't prove a willful injury to {V}'s property.",
            victim: VictimFacts(age: 46, occupation: "Food truck owner", harm: ["No physical injury. The food truck and pickup truck were damaged, and the owner lost two weeks of events."], restitution: 13700, restitutionBasis: "a food truck and a pickup truck damaged at the fairgrounds"),
            time: "10:52 p.m.",
            scene: "the back lot behind the grandstand at the county fairgrounds in {HOOD}"
        )
    )
}
