import Foundation

private typealias E = EvidenceSeed

/// A fully written case: an organized street takeover that ends with a car sliding into a dealership lot.
extension StoryCases {
    static let batchBG: [CaseTemplate] = [streetTakeover]

    static let streetTakeover = CaseTemplate(
        key: "story.streetTakeover", category: .traffic,
        headlines: ["Street Takeover Ends With Car Sliding Into Dealership Lot", "Organizer of Intersection Takeover Charged After Cars Wrecked"],
        primaryLaw: "injuryPersonalProperty", lesserLaw: nil, threshold: 9, lesserThreshold: 0,
        specification: "Willfully and wantonly injured personal property of {V}, four vehicles on {V}'s lot, causing damage of $15,900, when a car {D} drove in a street takeover {D} organized slid into them.",
        secondary: [
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Willfully and wantonly injured real property of {V}, a fence, gate and light pole, causing damage of $5,500.", chance: 1.0, threshold: 8),
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly in willful disregard of the rights and safety of others, spinning a car in circles at the crowded intersection of Dunmore Road and Tanner Lane.", chance: 1.0, threshold: 6),
            SecondaryCharge(lawID: "riot", specification: "Willfully engaged in a riot, a public disturbance by an assemblage of three or more persons that, by disorderly conduct, damaged property at Dunmore Road and Tanner Lane.", chance: 0.5, threshold: 8)
        ],
        ageRange: 20...34, occupations: ["tire technician"], hasVictim: true,
        summaries: [
            "For three days before {DATE}, an account called @tanner_lane_nights advertised a takeover of the intersection of Dunmore Road and Tanner Lane in {HOOD}. That night about forty cars and a crowd of about 150 filled the intersection. Drivers parked across both lanes to block traffic, then took turns spinning donuts in the middle while spectators stood at the curb. The first 911 call came at 11:08 p.m. At 11:26 p.m. a silver sedan went sideways out of the intersection, slid across the entrance of Dunmore Auto Sales, struck a row of used cars, a fence and a light pole, and drove off. {V}, who owns the lot, counted $21,400 in damage. Deputies traced the account to {D}, who drives a silver Dodge Charger."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dealership Lot Camera", "At 11:26 p.m. a silver four-door with a rear spoiler slides sideways into the lot entrance, hits the first car in the front row, pushes it into the next, and drives off. The plate can't be read."),
            E(.digital, 3, "Flyer, Group Chat and Payments", "The flyer, posted from @tanner_lane_nights three days before: \"We take the light at Dunmore and Tanner this weekend, 11 p.m. Blockers in at 10:45. Bring the smoke.\" The account's recovery number is {DL}'s. {DL}'s cash-app account received thirty-one $10 payments from drivers, $310 in all."),
            E(.physical, 3, "Tire Marks and Lot Debris", "One tire mark about ninety-four feet long curves out of the intersection into the lot entrance and ends at the first car in the row, where silver paint is smeared on the white Camry's rear quarter panel."),
            E(.physical, 2, "{DL}'s Charger", "Photographed outside {DL}'s apartment two days after the night: a silver Dodge Charger with a cracked right headlight cover and a scuffed right front fender."),
            E(.forensic, 2, "Paint Transfer Examination", "The silver metallic paint on the Camry has four layers in the same order and pigments as the paint on the Charger's fender. The examiner calls it consistent with the fender, not unique to it."),
            E(.document, 2, "Damage Estimates", "Four cars on the front row: $15,900. Fence and gate: $3,900. Light pole: $1,600. Total: $21,400.")
        ],
        defenseEvidence: [
            E(.video, 2, "Fan Phone Videos", "Three clips from the crowd show at least a dozen silver or gray cars in the intersection, including a silver Audi that spins repeatedly. None shows the slide into the lot or a plate on the Audi."),
            E(.statement, 1, "Left Early", "{DL} says {D.he} left the intersection about 11:20 p.m. and drove toward the highway."),
            E(.document, 1, "Lot Post Note", "{DL}'s manager wrote that {DL} backed the Charger into a post in the work lot the Tuesday before.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sheriff's deputy, traffic unit",
                        direct: ["\"The tire mark starts in the intersection and ends in the lot. Whatever made it was going sideways.\""],
                        cross: ["\"I didn't see who was driving.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("When did you respond?", "\"The first 911 call came at 11:08 p.m. from a neighbor on Tanner Lane about engines and a crowd. Two more followed. I was on the other side of the county and got there at 11:33.\""),
                            .direct("What did you find?", "\"The crowd was gone. Cones, black circles all over the intersection, and glass and plastic at the entrance of Dunmore Auto Sales.\""),
                            .direct("What did the lot look like?", "\"Four cars on the front row were hit, one pushed into the next. The gate was folded in and a light pole was leaning. The owner got there about 11:55, after the alarm company called him.\""),
                            .direct("What did the tire mark tell you?", "\"One mark, about ninety-four feet, curving out of the intersection into the lot entrance. That's what a car leaves when it slides sideways with the rear wheels spinning. It ends at the first car in the row, where there's silver paint on the rear quarter panel.\""),
                            .direct("What did the lot camera show?", "\"A silver four-door with a rear spoiler sliding in sideways at 11:26, hitting the row, and driving away. The plate isn't readable.\""),
                            .direct("How did you get to {DL}?", "\"A neighbor sent the flyer to our tip line the next morning. The account's recovery number belongs to {DL}.\""),
                            .direct("What did {DL}'s car look like when you saw it?", "\"Two days after, outside {D.his} apartment. A silver Charger, cracked right headlight cover, scuffed right front fender.\""),
                            .cross("You didn't see the slide yourself?", "\"No. I got there seven minutes after it.\""),
                            .cross("The plate isn't readable on the lot video?", "\"Correct.\""),
                            .cross("There was a silver Audi in that intersection too, wasn't there?", "\"On the fan videos, yes. I count at least a dozen silver or gray cars. One of them is a Audi.\""),
                            .cross("You never found the Audi's owner?", "\"No. None of the videos shows its plate.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Owner of Dunmore Auto Sales",
                        direct: ["\"Four cars I couldn't afford to lose, and a fence I'd just put up.\""],
                        cross: ["\"I was home. I didn't see it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you that night?", "\"At home, about twenty minutes from the lot. The alarm company called at 11:28 when the gate sensor tripped.\""),
                            .direct("What did you find when you got there?", "\"About 11:55. A white Camry hit and pushed into a blue Civic, a black Tahoe and a red Ranger scraped down the side. The gate was folded in and the light pole was leaning.\""),
                            .direct("What did the damage cost?", "\"The estimates came to $21,400. Fifteen thousand nine hundred for the four cars, $3,900 for the fence and gate, $1,600 for the pole.\""),
                            .direct("Do you know {DL}?", "\"No. I know the name now.\""),
                            .direct("How has it affected the business?", "\"I couldn't sell the Camry or the Civic for two months. I paid for the repairs first and put bollards in front of the gate.\""),
                            .cross("You didn't see the car that hit your lot?", "\"No. Only the camera.\""),
                            .cross("The camera doesn't show the plate?", "\"No. It's a wide lens for the gate.\"")
                        ]),
            WitnessSeed(name: nil, role: "Sheriff's detective, social media and phone records",
                        direct: ["\"The flyer, the group chat and the payments all lead to {DL}'s account.\""],
                        cross: ["\"Nothing in the chat says {DL} hit anything.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you link @tanner_lane_nights to {DL}?", "\"The account's recovery number belongs to {DL}'s phone, the profile photo is {DL}'s car, and {DL}'s account is the admin of the group chat.\""),
                            .direct("What did the flyer say?", "\"'We take the light at Dunmore and Tanner this weekend, 11 p.m. Blockers in at 10:45. Bring the smoke.' It was posted three days before, at 8:15 p.m.\""),
                            .direct("Did {DL} collect money?", "\"Thirty-one payments of $10 from drivers to {DL}'s cash-app account in the two days before. Each is marked 'spot' or 'entry'. $310 in all.\""),
                            .direct("What did {DL}'s account write that night?", "\"At 10:52, 'blockers set, light is ours.' At 11:02, 'who's first.' At 11:12, 'if you hear sirens we scatter.' At 11:27, 'WHO WAS THAT.' At 11:31, 'everybody go home NOW.'\""),
                            .direct("Did {DL} post video?", "\"A twelve-second clip at 11:09 p.m. of a silver Charger spinning in the intersection, shot from inside the car.\""),
                            .cross("There are two other admins on that chat, aren't there?", "\"Yes. We never identified either one.\""),
                            .cross("No message from {DL} says that {D.he} hit a lot?", "\"No. Nothing in the chat admits the slide.\""),
                            .cross("'WHO WAS THAT' reads like someone who didn't know who it was, doesn't it?", "\"It can be read that way. It can also be read as someone reacting to what {D.he} had just done.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Crime Laboratory trace evidence examiner",
                        direct: ["\"The Camry's paint is consistent with the paint on {DL}'s fender.\""],
                        cross: ["\"Consistent is not unique.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you examine?", "\"Paint smears from the Camry's rear quarter panel and a reference sample from {DL}'s Charger's right front fender.\""),
                            .direct("What did you find?", "\"The smears are silver metallic over gray primer with a clear coat, four layers. The fender has the same four layers, in the same order, with the same pigments.\""),
                            .direct("How much does that tell you?", "\"It's a factory silver used on several models. The Camry's paint is consistent with having come from {DL}'s fender. It is not unique. There are thousands of silver cars with that structure in the state.\""),
                            .cross("You can't say it came from {DL}'s car and no other?", "\"Correct. Consistent with, not identical to.\""),
                            .cross("A silver Audi of a similar year could leave a similar smear?", "\"The color family is similar. Layer structure differs a little by maker, but nobody gave me a Audi to compare, so I can't say.\""),
                            .cross("You found no white paint from the Camry on the Charger?", "\"I examined the scuff on the fender. I didn't find white paint.\""),
                            .cross("The scuff and cracked cover could come from a post?", "\"I'm a paint examiner. I can tell you the paint under the scuff is intact. I can't say what caused it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend who helped block the intersection",
                        direct: ["\"{DL} left before the crash. I watched the Charger go.\""],
                        cross: ["\"I wasn't charged. I don't know why.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"We've been friends since high school. I was one of the blockers that night, parked across Tanner Lane.\""),
                            .direct("What did {DL} do that night?", "\"{D.He} ran it. Collected from drivers, told people when to go. {D.He} did donuts early, ten minutes or so.\""),
                            .direct("When did {DL} leave?", "\"Around 11:20. {D.He} said {D.he} was done and heading home, and the Charger pulled out onto Dunmore toward the highway.\""),
                            .direct("What happened at 11:26?", "\"I was looking down Tanner, waving cars off. I heard the crash and turned around. Afterward I saw the Audi that had been running all night take off down Tanner.\""),
                            .direct("What did {DL} tell you about the Charger?", "\"That {D.he} backed into a post at work. {D.He} said it the Tuesday before, before any of this.\""),
                            .cross("You helped set up the blockade?", "\"Yes.\""),
                            .cross("You didn't see the slide itself?", "\"No. I heard it.\""),
                            .cross("You told the deputy you didn't remember when {DL} left?", "\"I said around eleven-something. I wasn't looking at a clock.\""),
                            .cross("You and {DL} talked about your testimony?", "\"We talked about what we remembered.\"")
                        ])
        ],
        prosecutionTheory: ["{D} organized the takeover, took money from drivers, and drove the silver Charger that slid into {V}'s lot."],
        defenseTheory: ["{DL} organized a car meet and did donuts, which is reckless driving, but left before a different silver car slid into the lot. The State can't prove whose car it was."],
        aggravating: ["About 150 people stood at the curb within feet of the sliding car", "{DL} collected money from drivers to take part", "Both lanes of Dunmore Road were blocked for more than half an hour"],
        mitigating: ["No prior criminal record", "{DL} has offered to repay part of the damage", "No one was hurt"],
        victimImpacts: ["{VL}: \"I've run that lot for nineteen years. Nobody drives through my cars and keeps going. Everyone there went home and posted about it, and I spent two months paying for it.\""],
        allocutions: ["\"I put people in that intersection, and I'm sorry for what it cost you. I should have known somebody would get hurt.\""],
        guiltyTruths: ["{DL} texted a friend at 11:40 p.m., 'clipped a lot, don't say anything,' and deleted the thread the next morning."],
        innocentTruths: ["The Audi's driver told a friend that night that he had 'put one through a car lot.'"],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "alibi", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-3, "8:15 p.m.: The flyer for the takeover is posted on @tanner_lane_nights."),
                       (0, "10:50 p.m.: Cars block both lanes at Dunmore Road and Tanner Lane. 11:08 p.m.: First 911 call. 11:26 p.m.: A silver car slides into the lot of Dunmore Auto Sales. 11:33 p.m.: A deputy arrives and the crowd is gone."),
                       (1, "A neighbor sends the flyer to the Sheriff's tip line, and {V} gives deputies the lot camera video."),
                       (2, "Deputies photograph {DL}'s silver Charger outside {D.his} apartment: cracked right headlight cover, scuffed right front fender."),
                       (3, "A body shop writes an estimate for the Charger's right front damage."),
                       (9, "Search warrants for the flyer account and {DL}'s cash-app records."),
                       (24, "State Crime Laboratory reports the Camry's paint is consistent with the Charger's fender."),
                       (31, "{DL} charged.")],
            howIdentified: "A neighbor sent the flyer to the Sheriff's tip line the next morning. The account's recovery number belonged to {DL}, who drives a silver Charger with a cracked right headlight.",
            notDone: ["The silver Audi seen in the fan videos was never traced; none of the videos shows its plate.", "The manager who wrote the post note was never asked when {DL} first reported the damage."],
            defendantExam: [
                .direct("Tell the court about that night.", "\"I put the meet together. I'm not going to say I didn't. I posted the flyer Tuesday night, I set up the blockers, and I took money from drivers for cones. About forty cars came, and a lot of people with phones.\""),
                .direct("Did you drive?", "\"Yes. A few donuts in the intersection starting around 11:05, ten minutes maybe. That was stupid and I know it.\""),
                .direct("When did you leave?", "\"Around 11:20. I'd done my part and I didn't want to be there when the police came. I took Dunmore toward the highway.\""),
                .direct("Where were you at 11:26?", "\"On the highway on-ramp. I was home about 11:40.\""),
                .direct("How did the Charger get damaged?", "\"I backed it into a post in the lot at work on Tuesday. The headlight cover cracked and the fender scuffed. I told my boss that day.\""),
                .direct("Why did you write 'WHO WAS THAT' at 11:27?", "\"A friend called me and said somebody had lost it. I typed it before I thought.\""),
                .cross("You took $310 from thirty-one drivers.", "\"For cones, and to cover gas for the blockers. I didn't keep it.\""),
                .cross("You wrote 'bring the smoke.'", "\"That's how people talk. It means burnouts.\""),
                .cross("You knew it was illegal to shut down that intersection.", "\"Yes. I thought it would be a few donuts and gone before anybody got hurt.\""),
                .cross("You told everybody to go home at 11:31. Why, if you didn't know what happened?", "\"Because the friend said it hit a lot and the police were coming.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"In your experience, who is usually behind the wheel when a takeover ends in a crash?\"",
                                  answer: "\"The organizers. They're the ones showing off.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation; generalization from other cases", shouldSustain: true,
                                  explanation: "What usually happens at other takeovers doesn't show who was driving the car on this night. It is a guess dressed up as experience, and the question is who drove this car.",
                                  doctrineID: "speculation", weight: 1)),
                (2, ObjectionSeed(question: "Prosecutor: \"What did the member who sent you the screenshot say about whose car it was?\"",
                                  answer: "\"The member said it was {DL}'s car that hit the lot.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: true,
                                  explanation: "The member's statement was made out of court and is offered for its truth, that the car was {DL}'s. The member isn't here to be cross-examined, and no exception applies.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "For three days {D} advertised a street takeover, collected $310 from drivers, and told them to bring the smoke. At 11:26 p.m., a silver car went sideways out of that intersection and into {V}'s lot, and {D} drives a silver Charger with a cracked headlight and a scuffed fender. The State will prove {D} organized it, drove in it, and wrecked {V}'s cars.",
            defenseOpening: "{DL} organized a car meet, and {D.he} will tell the court so. {D.He} did donuts, and that's reckless driving. But {D.he} left around 11:20, minutes before a different silver car slid into a lot. The State can't read the plate, can't name the driver, and can't tell one silver car from another.",
            prosecutionClosing: "{DL} built the stage, collected from the drivers, and drove in the show. The paint, the fender and the money trail all point to one car, and the one person who told everyone to bring the smoke is the one who answers for what the smoke did.",
            defenseClosing: "Reckless driving is what {DL} did, and {D.he} admits it. The damage to {V}'s lot is something else, and the State has to prove whose car did it. It has paint that is 'consistent with' thousands of cars, a plate nobody can read, and a friend who watched the Charger leave. That is reasonable doubt on the count that matters.",
            when: .weekday(6),
            victim: VictimFacts(age: 57, occupation: "Used-car dealer", harm: ["No physical injury. Four cars on the front row, the fence and gate, and a light pole were damaged, and two of the cars could not be sold for two months."], restitution: 21400, restitutionBasis: "four damaged cars, the fence and gate, and a light pole"),
            time: "11:26 p.m.",
            alibiCheck: AlibiCheck(
                holds: AlibiCheck.Finding(title: "Doorbell Camera", detail: "A doorbell camera three blocks east on Dunmore Road shows {DL}'s Charger heading toward the highway at 11:19 p.m., seven minutes before the slide.", kind: .video),
                breaks: AlibiCheck.Finding(title: "Phone Location Records", detail: "{DL}'s phone stays on the tower serving Dunmore Road and Tanner Lane until 11:41 p.m.", kind: .digital)),
            scene: "the intersection of Dunmore Road and Tanner Lane in {HOOD}"
        )
    )
}
