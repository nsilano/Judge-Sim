import Foundation

private typealias E = EvidenceSeed

/// Everyday cases: petty theft, running from officers, trespass, driving while revoked, small drug possession.
/// These are the offenses that fill a real county's courtrooms, so the story director favors them.
extension StoryCases {
    static let batchAL: [CaseTemplate] = [aisleSeven, footChase, parkingLotScream, postedPond, revokedToWork,
                                          gloveboxLeaf, parkingSpace, truckBedTools, adderallStop, bicycleRack]

    // MARK: - Aisle seven (a woman who can't stop taking things)

    static let aisleSeven = CaseTemplate(
        key: "story.aisleSeven", category: .property,
        headlines: ["Woman Caught Walking Out of Grocery With Unpaid Items Again", "Lawyer Says Client's Shoplifting Is a Compulsion, Not a Plan"],
        primaryLaw: "misdLarceny", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Stole $86 in groceries and household items from a retail grocery store, on {DATE}.",
        ageRange: 38...64, occupations: ["retired bookkeeper", "school bus aide", "dental receptionist"], hasVictim: false,
        summaries: [
            "A loss prevention officer watched {D} slip a $19 scented candle and two packs of batteries into {D.his} purse at a grocery on {DATE}, then pay for a gallon of milk and walk out. {D} has stopped here three times this year for small items, always paying for something cheap. {D} has more than enough in {D.his} account: the receipt in {D.his} purse for the milk was $3. {DL} says {D.he} doesn't know why {D.he} does it, that the urge comes on like a wave, and that {D.he} has been seeing a therapist for it since the spring."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Store Camera", "{D} puts a candle and two packs of batteries into a purse at the end of aisle seven, then pays for milk at the register."),
            E(.document, 2, "Loss Report", "$86 in unpaid merchandise; three earlier stops this year, each with a small purchase to cover.")
        ],
        defenseEvidence: [
            E(.document, 3, "Therapist's Letter", "{D} is in treatment for kleptomania, an impulse control disorder; no financial motive.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Store loss prevention officer",
                        direct: ["\"I watched the whole thing on the camera.\""], cross: ["\"{D.He} never ran.\""], weight: 3, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{DL} put a candle and two packs of batteries into {D.his} purse, bought a gallon of milk, and walked out.\""),
                            .direct("Had you seen {D.him} before?", "\"Three times this year. Always something small in the purse, and always something cheap on the belt.\""),
                            .cross("{D.He} didn't run when you stopped {D.him}.", "\"{D.He} just stood there and cried. {D.He} said, 'I did it again.'\""),
                            .cross("{D.He} had money in {D.his} purse.", "\"Plenty. That's what I don't understand.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's therapist",
                        direct: ["\"This is a compulsion. {D.He} gets no benefit from it.\""], cross: ["\"{D.He} knew it was wrong.\""], weight: 2, lay: false,
                        exam: [
                            .direct("What is kleptomania?", "\"The repeated failure to resist an urge to take things that aren't needed. Tension rises, the taking brings relief, and then shame.\""),
                            .direct("Does {DL} fit?", "\"Entirely. The items are cheap and useless to {D.him}, and {D.he} hides them in a closet.\""),
                            .cross("{D.He} knew it was wrong.", "\"Yes. That's what makes {D.him} so ashamed.\""),
                            .cross("{D.He} paid for the milk.", "\"To look normal. People with this do that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} walked out of the store with items {D.he} didn't pay for. Whatever the reason, the law calls that larceny."],
        defenseTheory: ["{D} has a diagnosed disorder and is in treatment. A lecture from the court and treatment serve everyone better than a sentence."],
        aggravating: ["The defendant has prior convictions of the same kind"],
        mitigating: ["The defendant was suffering from a mental or physical condition that reduced culpability", "The defendant has accepted responsibility", "The defendant has a support system in the community"],
        victimImpacts: [],
        allocutions: ["\"I know how it looks. I'm in treatment. I don't want to do this anymore.\"", "\"I'm so ashamed. I have the money. I can't make it stop.\""],
        guiltyTruths: ["A closet in {DL}'s home held forty-one unopened items from stores around the county."],
        innocentTruths: ["{DL} had stopped for six weeks while on a new medication and relapsed after missing three therapy appointments."],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "insanity"],
        story: StoryExtras(
            timeline: [(-210, "First recorded stop at the store."), (-60, "{DL} begins therapy."), (0, "Midday: items taken from aisle seven; loss prevention stops {DL} in the parking lot.")],
            howIdentified: "Store camera and a loss prevention officer.",
            notDone: ["The earlier stops were never charged.", "No one checked whether {DL} had paid for anything else that day."],
            defendantExam: [
                .direct("Why did you take the candle?", "\"I don't know. I felt wound up, and then I had it in my hand.\""),
                .direct("Did you need any of it?", "\"No. I don't even like that candle.\""),
                .cross("You paid for the milk.", "\"So nobody would look at me.\""),
                .cross("You've been caught before.", "\"Three times. I keep promising myself.\"")
            ],
            prosecutionOpening: "A candle, two packs of batteries, and a purse.",
            defenseOpening: "A woman with a disorder, in treatment, who needs help more than a record.",
            prosecutionClosing: "Compulsion is a reason for sentencing, not a defense to larceny.",
            defenseClosing: "{DL} took nothing {D.he} needed and has asked for help.",
            family: "Married; two grown children.",
            residence: "A brick ranch house in {HOOD}"
        )
    )

    // MARK: - Over the fence (resisting)

    static let footChase = CaseTemplate(
        key: "story.footChase", category: .publicOrder,
        headlines: ["Man Runs From Deputies, Climbs Fence, Gets Stuck", "Resisting Charge After Foot Chase Behind Dollar Store"],
        primaryLaw: "resisting", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Willfully resisted, delayed, and obstructed a public officer, a sheriff's deputy, in discharging a duty of the officer's office, on {DATE}.",
        ageRange: 19...38, occupations: ["line cook", "warehouse worker", "unemployed"], hasVictim: false,
        summaries: [
            "On {DATE} a deputy approached {D} outside a dollar store after a clerk reported a man \"casing\" the store. When the deputy asked for ID, {D} said, \"I didn't do anything,\" and ran. The deputy chased {D} through a back alley and over a chain-link fence, where {D}'s jacket caught and {D} hung until the deputy arrived. {D} had nothing illegal on {D.him}. {DL} says {D.he} ran because {D.he} had an unpaid ticket and was afraid of being jailed, and that the deputy had no reason to stop {D.him}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Camera", "The deputy asks for ID; {D} runs; the deputy yells \"Stop, sheriff's office\" twice during the chase."),
            E(.document, 2, "Clerk's 911 Call", "A clerk reports a man \"looking at the registers and the door for twenty minutes.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Prior Ticket", "{D} had an outstanding failure-to-appear on a traffic ticket, which {D.he} says is why {D.he} ran.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sheriff's deputy",
                        direct: ["\"I told {D.him} to stop twice.\""], cross: ["\"I had no crime to point to.\""], weight: 3, lay: false,
                        exam: [
                            .direct("What did you do when you arrived?", "\"I walked up, said hello, and asked for ID. {D.He} said 'I didn't do anything' and ran.\""),
                            .direct("What happened then?", "\"I yelled 'Stop, sheriff's office.' Twice. {D.He} climbed a fence and hung there by the jacket.\""),
                            .cross("You didn't see a crime.", "\"No. A clerk called about suspicious behavior.\""),
                            .cross("{D.He} had nothing on {D.him}.", "\"Correct.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} knew {D.he} was talking to a deputy, was told to stop twice, and ran. That's resisting, whether or not {D.he} was guilty of anything else."],
        defenseTheory: ["The deputy had no reasonable suspicion to detain {D}. Without a lawful stop, there's no duty to stop. Running scared isn't a crime."],
        aggravating: ["The defendant has prior convictions of the same kind"],
        mitigating: ["The defendant has accepted responsibility", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"I panicked. I had a ticket and I thought I'd go to jail.\"", "\"I shouldn't have run. I'm sorry.\""],
        guiltyTruths: ["{DL} had a small bag of marijuana in a sock and ran partly because of it."],
        innocentTruths: ["The clerk who called was later fired for calling the sheriff on several customers who weren't doing anything."],
        moods: [.indifferent], doctrines: ["searchSeizure", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Late afternoon: clerk calls about a man by the registers."), (0, "Deputy approaches {DL} outside the store; foot chase."), (0, "{DL} is caught on the fence and arrested.")],
            howIdentified: "The deputy chased {DL} on foot and caught {D.him} at the fence.",
            notDone: ["The clerk was never asked what {DL} was actually doing for twenty minutes."],
            defendantExam: [
                .direct("Why did you run?", "\"I had a ticket I didn't pay. I figured they'd take me to jail.\""),
                .direct("Did you hear the deputy say stop?", "\"I heard something. I just kept going.\""),
                .cross("He identified himself twice.", "\"Yes. I didn't stop.\""),
                .cross("You hung from a fence.", "\"It was a bad idea.\"")
            ],
            prosecutionOpening: "A deputy said stop twice. {DL} kept running.",
            defenseOpening: "A man with an unpaid ticket and a deputy with no reason to stop him.",
            prosecutionClosing: "When an officer says stop, you stop.",
            defenseClosing: "No lawful stop, no resisting.",
            family: "Single; shares an apartment with a cousin.",
            residence: "An apartment in {HOOD}"
        )
    )

    // MARK: - The parking lot (disorderly conduct)

    static let parkingLotScream = CaseTemplate(
        key: "story.parkingLotScream", category: .publicOrder,
        headlines: ["Customer Screams at Cashier, Blocks Parking Lot Lane", "Disorderly Conduct Charge After Return Dispute"],
        primaryLaw: "disorderly", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Engaged in disorderly conduct in a public place by making a public disturbance in a retail store parking lot, on {DATE}.",
        ageRange: 28...60, occupations: ["electrician", "bank teller", "retired mail carrier"], hasVictim: false,
        summaries: [
            "On {DATE}, {D} tried to return a $240 space heater to a home goods store without a receipt and was refused. {D} began shouting at the cashier, followed {D.him} into the parking lot, stood in the lane blocking cars, and screamed that the store was \"robbing people.\" A manager called deputies after {D} refused to move for ten minutes. {DL} says {D.he} was upset because the heater had been a gift for {D.his} mother and that the manager was rude."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Parking Lot Camera", "{D} stands in the traffic lane for ten minutes, arms waving, while four cars wait."),
            E(.statement, 2, "Manager's Statement", "{D} used foul language and refused three requests to move.")
        ],
        defenseEvidence: [
            E(.document, 1, "Receipt From Another Store", "The heater was bought at a different chain; the return was refused for lack of a receipt.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Store manager",
                        direct: ["\"Four cars were stuck behind {D.him}.\""], cross: ["\"No one was hurt.\""], weight: 2, lay: true,
                        exam: [
                            .direct("What did {DL} do?", "\"Shouted, followed my cashier outside, and stood in the lane yelling for ten minutes.\""),
                            .direct("Did you ask {D.him} to move?", "\"Three times. {D.He} told me what I could do with my store.\""),
                            .cross("No one was hurt.", "\"No. People were scared.\""),
                            .cross("The return was refused.", "\"No receipt, no return. It's the policy.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} blocked a traffic lane and screamed in a public place, disrupting customers and stopping cars."],
        defenseTheory: ["An upset customer, a rude manager, and words that didn't threaten anyone. Disorderly conduct is for real disturbances."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"I lost my temper over a space heater. I'm embarrassed.\""],
        guiltyTruths: ["{DL}'s texts that day said, \"going to make a scene at that store until they give me my money.\""],
        innocentTruths: ["A customer in the lane later testified {DL} moved the moment deputies arrived and apologized to the drivers."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Midday: return refused; {DL} follows the cashier into the lot."), (0, "Ten minutes in the lane; manager calls deputies.")],
            howIdentified: "The manager's call and the lot camera.",
            defendantExam: [
                .direct("What happened?", "\"They wouldn't take back a gift for my mother. I got loud.\""),
                .direct("Why stand in the lane?", "\"I wanted the manager to come out. I didn't think about the cars.\""),
                .cross("Ten minutes in the lane.", "\"I didn't know it was that long.\""),
                .cross("You cursed at the manager.", "\"I'm not proud of it.\"")
            ],
            prosecutionOpening: "Four cars stopped behind a man who wouldn't move.",
            defenseOpening: "A customer's bad day over a space heater.",
            prosecutionClosing: "A public disturbance is a public disturbance, whatever the reason.",
            defenseClosing: "No threat, no violence. Just an angry customer.",
            family: "Married; one teenager.",
            residence: "A house in {HOOD}"
        )
    )

    // MARK: - The posted pond (trespass)

    static let postedPond = CaseTemplate(
        key: "story.postedPond", category: .property,
        headlines: ["Fisherman Charged With Trespass at Private Pond", "Man Says 'No Trespassing' Signs Were Hidden by Brush"],
        primaryLaw: "trespass2", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Entered and remained on premises of {V}, a private farm pond, after being notified not to enter, on {DATE}.",
        ageRange: 24...62, occupations: ["welder", "truck driver", "HVAC technician"], hasVictim: true,
        summaries: [
            "{V} owns a farm outside {HOOD} with a stocked pond. After finding trash and a cut fence, {V} posted four \"No Trespassing\" signs and told {D} personally, a month earlier, not to fish there. On {DATE}, {V} saw {D}'s truck at the gate and found {D} fishing at the pond with two coolers. {D} says the signs were hidden by brush, that {V}'s earlier warning was about the creek, and that the pond has been fished by locals for fifty years."
        ],
        prosecutionEvidence: [
            E(.physical, 2, "Posted Signs", "Four weathered \"No Trespassing\" signs on posts along the fence line; one at the gate."),
            E(.statement, 2, "Earlier Warning", "{V} says {V.he} told {D} to stay out of the pond a month earlier.")
        ],
        defenseEvidence: [
            E(.physical, 2, "Photo of the Gate Sign", "{D}'s phone photo shows the gate sign half covered by honeysuckle.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Pond owner",
                        direct: ["\"I told {D.him} to stay out.\""], cross: ["\"People have fished here for years.\""], weight: 3, lay: true,
                        exam: [
                            .direct("Did you warn {DL}?", "\"A month ago, at the gate. I said, 'You can't fish the pond anymore.'\""),
                            .direct("What did you find that day?", "\"{D.His} truck at the gate and {D.him} at the water, two coolers on the bank.\""),
                            .cross("The signs are weathered.", "\"I put them up in the spring.\""),
                            .cross("Locals have fished here forever.", "\"They asked first. I always said yes. Then someone cut my fence.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} was warned in person and by four signs, and went onto the pond anyway."],
        defenseTheory: ["The gate sign was hidden by brush, the earlier warning was about the creek, and fifty years of local custom led {D} to believe the pond was open."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility"],
        victimImpacts: ["\"I've asked nicely for years. People take that as permission.\""],
        allocutions: ["\"I thought it was still okay. I'll stay off.\""],
        guiltyTruths: ["{DL}'s text to a friend said, \"he told me not to fish there but he's never around, meet me at the pond.\""],
        innocentTruths: ["{V}'s earlier warning had been to a different man, who looked like {DL}."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(-30, "{V} says {V.he} warned {DL} at the gate."), (0, "Morning: {V} finds {DL} fishing at the pond.")],
            howIdentified: "{V} found {DL} at the pond.",
            defendantExam: [
                .direct("Did {V} tell you to stay out?", "\"{V.He} told somebody. I thought it was about the creek.\""),
                .direct("Did you see the signs?", "\"The gate one was covered in vines.\""),
                .cross("Four signs and a warning.", "\"I only saw the gate. I didn't walk the fence.\""),
                .cross("You brought two coolers.", "\"We always fish there.\"")
            ],
            prosecutionOpening: "Signs, a warning, and a man at the water.",
            defenseOpening: "Hidden signs and fifty years of local habit.",
            prosecutionClosing: "{V} told {D.him} plainly.",
            defenseClosing: "A hidden sign and a vague warning aren't notice.",
            when: .months([4, 5, 6, 7, 8, 9]),
            victim: VictimFacts(age: 66, occupation: "retired farmer", relationship: "Owns the farm pond"),
            family: "Single.",
            residence: "A mobile home in {HOOD}"
        )
    )

    // MARK: - Driving to work while revoked

    static let revokedToWork = CaseTemplate(
        key: "story.revokedToWork", category: .traffic,
        headlines: ["Man Stopped for Taillight Was Driving on Revoked License", "Driver Says He Had No Other Way to Reach Work"],
        primaryLaw: "dwlr", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Drove a motor vehicle on a public highway while {D.his} driver's license was revoked, on {DATE}.",
        ageRange: 25...58, occupations: ["dishwasher", "poultry plant worker", "roofing laborer"], hasVictim: false,
        summaries: [
            "A trooper stopped {D} on {DATE} at 5:40 a.m. for a broken taillight. A records check showed {D}'s license had been revoked eight months earlier after {D} failed to pay a fine and missed a court date on a speeding ticket. {D} was on the way to a 6 a.m. shift at a poultry plant twenty-two miles away, with no bus line and no one to carry {D.him}. {DL} says {D.he} didn't know the revocation was still in effect because the notice went to an old address."
        ],
        prosecutionEvidence: [
            E(.document, 3, "DMV Records", "A revocation effective eight months earlier for failure to appear and unpaid fines; notice mailed to the address on file."),
            E(.video, 2, "Dash Camera", "The stop at 5:40 a.m.; {D} hands over an expired ID and says, \"I know I shouldn't be driving.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Old Address", "{D} moved four months before the notice was mailed; the DMV had the previous address on file.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State Highway Patrol trooper",
                        direct: ["\"{D.He} admitted {D.he} shouldn't be driving.\""], cross: ["\"{D.He} was going to work.\""], weight: 3, lay: false,
                        exam: [
                            .direct("What happened at the stop?", "\"Broken taillight. A check showed a revoked license. {D.He} said, 'I know I shouldn't be driving.'\""),
                            .direct("Was the notice mailed?", "\"Yes, to the address on file.\""),
                            .cross("{D.He} was on the way to work.", "\"That's what {D.he} said.\""),
                            .cross("The address was old.", "\"It was the address on file. That's {D.his} responsibility.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} drove on a revoked license and admitted knowing {D.he} shouldn't."],
        defenseTheory: ["{D} didn't get the notice. Without notice, there's no willful violation, and {D} was simply trying to keep a job."],
        aggravating: [],
        mitigating: ["The defendant has a positive employment history and is gainfully employed", "The defendant has accepted responsibility"],
        victimImpacts: [],
        allocutions: ["\"I had no way to get to work. I should have fixed my license.\""],
        guiltyTruths: ["{DL}'s phone held a letter photo from the DMV, taken two months before the stop."],
        innocentTruths: ["The DMV later admitted mailing the notice to {DL}'s previous address even after a change-of-address was filed."],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(-240, "License revoked."), (0, "5:40 a.m.: stop for a broken taillight on the way to work.")],
            howIdentified: "A trooper's traffic stop.",
            defendantExam: [
                .direct("Did you know your license was revoked?", "\"I knew I had a ticket. Nobody told me about a revocation.\"", "\"I figured I did. I had no choice.\""),
                .direct("Why drive?", "\"The plant is twenty-two miles away and my shift starts at six.\""),
                .cross("You told the trooper you shouldn't be driving.", "\"I figured something was wrong.\""),
                .cross("Rides were available?", "\"Not at that hour.\"")
            ],
            prosecutionOpening: "A revoked license and a man who admitted it.",
            defenseOpening: "A worker and a notice that went to the wrong place.",
            prosecutionClosing: "The law requires notice, and the State mailed it.",
            defenseClosing: "{DL} was never told.",
            family: "Married; three children.",
            residence: "A rental house in {HOOD}"
        )
    )

    // MARK: - The glove box (small marijuana possession)

    static let gloveboxLeaf = CaseTemplate(
        key: "story.gloveboxLeaf", category: .drugs,
        headlines: ["Deputies Find Marijuana in Glove Box During Traffic Stop", "Driver Says Marijuana Belonged to a Former Passenger"],
        primaryLaw: "possMarijuana", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Knowingly possessed marijuana, a Schedule VI controlled substance, in an amount of half an ounce or less, on {DATE}.",
        ageRange: 19...44, occupations: ["line cook", "tire shop worker", "college student"], hasVictim: false,
        summaries: [
            "A deputy stopped {D} on {DATE} for a rolling stop at a four-way. The deputy smelled marijuana, searched the car, and found a sandwich bag with 6 grams in the glove box and a grinder in the console. {DL} says the car is a shared family car, that {D.his} cousin used it all week and left the bag, and that {D.he} never opened the glove box. The defense moves to suppress: the deputy had the smell of marijuana but hemp products also smell the same, and the State has no lab report separating legal hemp from marijuana."
        ],
        prosecutionEvidence: [
            E(.physical, 2, "Bag and Grinder", "A sandwich bag with about 6 grams of plant material in the glove box; a metal grinder in the console.", .search),
            E(.statement, 2, "Statement at the Stop", "{D} said, \"It's not much, it's just weed.\"")
        ],
        defenseEvidence: [
            E(.statement, 2, "Cousin's Use of the Car", "{D}'s cousin borrowed the car all week; a gas receipt from his card is in the console.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sheriff's deputy",
                        direct: ["\"I smelled marijuana as soon as the window came down.\""], cross: ["\"Hemp smells the same.\""], weight: 3, lay: false,
                        exam: [
                            .direct("What happened at the stop?", "\"Rolling stop. When the window came down, I smelled burnt marijuana.\""),
                            .direct("What did you find?", "\"A bag with about six grams in the glove box and a grinder in the console.\""),
                            .cross("Hemp smells the same as marijuana.", "\"It can. I've been trained on the difference.\""),
                            .cross("The lab didn't test for THC percentage.", "\"The state lab did a chemical test and a color test. It came back positive.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} was driving a car with marijuana in the glove box and admitted to the deputy that it was weed."],
        defenseTheory: ["A shared car, a cousin's bag, and a search based on a smell that hemp can also produce. No knowing possession, and a search that never should have happened."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"It's just weed. I'm sorry I wasted the court's time.\"", "\"That wasn't mine. I'd never keep it in a car.\""],
        guiltyTruths: ["{DL}'s phone held texts about buying the bag from a friend two days before the stop."],
        innocentTruths: ["The cousin was arrested months later with a larger amount from the same dealer and admitted leaving the bag."],
        moods: [.indifferent], doctrines: ["searchSeizure", "fruitPoisonousTree", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Evening: rolling stop at a four-way; the deputy smells marijuana."), (0, "Search of the car; bag found in the glove box.")],
            howIdentified: "A traffic stop and a vehicle search.",
            defendantExam: [
                .direct("Whose bag is it?", "\"My cousin's. He drives the car when I'm at work.\"", "\"Mine. It's six grams, it's not a big deal.\""),
                .direct("Did you open the glove box?", "\"Only for the registration, a week before.\""),
                .cross("You told the deputy 'it's just weed.'", "\"I was trying to be honest.\""),
                .cross("You were driving.", "\"But it's the family car.\"")
            ],
            prosecutionOpening: "Marijuana in the glove box, and {D} said so.",
            defenseOpening: "A shared car, a cousin, and a smell.",
            prosecutionClosing: "{D.He} knew it was there. {D.He} said so.",
            defenseClosing: "Without a lawful search, there's no evidence. Without knowledge, there's no possession.",
            family: "Single; lives with {D.his} parents.",
            residence: "{D.His} parents' house in {HOOD}"
        )
    )

    // MARK: - The parking space (simple assault)

    static let parkingSpace = CaseTemplate(
        key: "story.parkingSpace", category: .violent,
        headlines: ["Argument Over Parking Space Ends With a Shove", "Man Charged With Assault After Church Lot Dispute"],
        primaryLaw: "simpleAssault", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Assaulted {V} by pushing {V.him} in the chest with both hands, on {DATE}.",
        ageRange: 28...66, occupations: ["retired mechanic", "church deacon", "insurance adjuster"], hasVictim: true,
        summaries: [
            "On {DATE}, after a funeral at a church in {HOOD}, {D} and {V} reached the last parking space near the door at the same time. Words were exchanged. {D} got out and walked to {V}'s window. According to {V}, {D} shoved {V.him} in the chest when {V.he} got out of the car, and {V.he} stumbled into the neighboring bumper. {D} says {V} stepped toward {D.him} with a closed fist and {D.he} put out {D.his} hands to keep {V.him} back. A church usher saw part of it."
        ],
        prosecutionEvidence: [
            E(.statement, 2, "Usher's Statement", "The usher saw {D} \"put both hands on {V}'s chest\" but didn't see what happened before."),
            E(.document, 1, "Medical Note", "{V} was seen at urgent care for a bruise on the chest and a sore wrist.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Second Witness", "A mourner says {V} \"was pointing and cursing\" before {D} put {D.his} hands out.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Other driver",
                        direct: ["\"{D.He} came at me and pushed me.\""], cross: ["\"I was upset about the parking space.\""], weight: 2, lay: true,
                        exam: [
                            .direct("What happened?", "\"{D.He} walked to my window, I got out, and {D.he} shoved me into the next car.\""),
                            .direct("Were you hurt?", "\"A bruise on my chest and a sore wrist.\""),
                            .cross("You were angry.", "\"I'd been at a funeral. I was upset.\""),
                            .cross("Did you step toward {D.him}?", "\"I got out of my car. That's all.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Mourner",
                        direct: ["\"{V} was pointing in {D.his} face.\""], cross: ["\"I didn't see the push.\""], weight: 1, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{V} cursing and pointing in {D}'s face. {D} put {D.his} hands out and {V} stepped back.\""),
                            .cross("Did you see the push?", "\"I saw hands on a chest.\"")
                        ])
        ],
        prosecutionTheory: ["{D} put hands on {V} over a parking space. A shove is an assault."],
        defenseTheory: ["{D} held out {D.his} hands to keep an angry man away. A defensive gesture isn't an assault."],
        aggravating: [],
        mitigating: ["The defendant acted under strong provocation", "The defendant has accepted responsibility"],
        victimImpacts: ["\"At a funeral. Over a parking space. I'm still ashamed of how I acted.\""],
        allocutions: ["\"I put my hands up. I'd do it again, and I'm sorry it happened.\"", "\"I lost my temper. I'm sorry for what I did at that church.\""],
        guiltyTruths: ["A second usher later recalled {D} saying, \"Keep your hands off my space,\" before the shove."],
        innocentTruths: ["{V}'s own sister later said {V} had been raising a fist and calling {D} names."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "After the funeral: two cars, one space."), (0, "The shove; deputies called by the church.")],
            howIdentified: "Both men stayed at the scene.",
            defendantExam: [
                .direct("What did {V} do?", "\"{V.He} got out yelling and stepped toward me with a closed fist.\""),
                .direct("What did you do?", "\"I put my hands out to stop {V.him}.\""),
                .cross("{V} stumbled into a bumper.", "\"I didn't mean for that.\""),
                .cross("You were angry about the space.", "\"Everybody was upset. It was a funeral.\"")
            ],
            prosecutionOpening: "A shove at a funeral over a parking space.",
            defenseOpening: "Two hands held up to stop a man's fist.",
            prosecutionClosing: "Hands on a chest are an assault.",
            defenseClosing: "{D} protected himself and has regretted it ever since.",
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(age: 52, occupation: "insurance adjuster", relationship: "A mourner at the same funeral", harm: ["A bruise on the chest and a sore wrist"]),
            family: "Married; three grown children.",
            residence: "A house in {HOOD}"
        )
    )

    // MARK: - The truck bed (breaking into vehicles)

    static let truckBedTools = CaseTemplate(
        key: "story.truckBedTools", category: .property,
        headlines: ["Unlocked Trucks Hit Overnight in Contractor Subdivision", "Man With Flashlight Seen Going Door to Door at Parked Trucks"],
        primaryLaw: "breakingVehicle", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Broke into and entered a motor vehicle belonging to {V}, with intent to commit larceny therein, on {DATE}.",
        ageRange: 19...42, occupations: ["unemployed", "line cook", "day laborer"], hasVictim: true,
        summaries: [
            "Overnight on {DATE}, five trucks parked in a subdivision were entered and ransacked. {V}'s truck lost a $400 cordless drill set and a nail gun. A doorbell camera two houses down recorded a man in a gray hoodie with a flashlight moving from truck to truck at 2:10 a.m. A deputy saw {D} walking nearby twenty minutes later with a duffel bag containing a drill set, a nail gun, and a flashlight. {DL} says {D.he} found the bag on the roadside and was walking home."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Doorbell Camera", "A man in a gray hoodie with a flashlight tries door handles on five parked trucks; the video is grainy.", .search),
            E(.physical, 3, "The Duffel Bag", "A cordless drill set and a nail gun with {V}'s etched initials, found in {D}'s duffel bag.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Found Bag", "{DL} says the bag was on the side of the road near a ditch.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Truck owner",
                        direct: ["\"That's my drill, my initials.\""], cross: ["\"I left the truck unlocked.\""], weight: 3, lay: true,
                        exam: [
                            .direct("How do you know the tools are yours?", "\"I etch my initials on everything. They were on the drill and the nail gun.\""),
                            .direct("What was taken?", "\"A drill set and a nail gun. Four hundred dollars, and a day's work lost.\""),
                            .cross("You left the truck unlocked.", "\"I did. I'm learning.\""),
                            .cross("You didn't see who took them.", "\"No. I saw them in {D.his} bag.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} went door to door at parked trucks and was found twenty minutes later with the stolen tools."],
        defenseTheory: ["{D} found a bag on a roadside. The camera shows a man in a hoodie, not a face. Possession of found property isn't breaking and entering."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility"],
        victimImpacts: ["\"I lost a day's work and a drill I'd had since my first job. Now I take everything inside.\""],
        allocutions: ["\"I needed money. I'm sorry.\""],
        guiltyTruths: ["The gray hoodie was found in {DL}'s closet with a small flashlight in the pocket."],
        innocentTruths: ["A neighbor's camera later showed another man in a gray hoodie dropping a duffel in the ditch where {DL} said {D.he} found it."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "eyewitnessID"],
        story: StoryExtras(
            timeline: [(0, "2:10 a.m.: a man tries truck door handles on camera."), (0, "2:30 a.m.: a deputy stops {DL} on foot with a duffel bag.")],
            howIdentified: "A deputy stopped {DL} with the stolen tools.",
            notDone: ["The camera footage was never enhanced.", "The other trucks' owners weren't asked about missing tools."],
            defendantExam: [
                .direct("Where did you get the bag?", "\"On the side of the road. I thought somebody dumped it.\"", "\"Out of a truck. I'm not going to lie.\""),
                .direct("Why carry it?", "\"I figured I could pawn it.\""),
                .cross("Etched initials on the drill.", "\"I didn't look.\""),
                .cross("A flashlight in your hand at 2:30 a.m.", "\"I walk at night.\"")
            ],
            prosecutionOpening: "A duffel bag with another man's initials on the tools.",
            defenseOpening: "A bag in a ditch, and a man who picked it up.",
            prosecutionClosing: "Twenty minutes and a bag of stolen tools.",
            defenseClosing: "Nobody saw {D.him} touch a truck.",
            genders: ["D": .male],
            victim: VictimFacts(age: 38, occupation: "carpenter", relationship: "None", harm: ["Lost a $400 drill set and a nail gun"], restitution: 400, restitutionBasis: "the stolen tools"),
            family: "Single; sleeps at a friend's house.",
            residence: "A friend's couch in {HOOD}"
        )
    )

    // MARK: - The Adderall at the stop

    static let adderallStop = CaseTemplate(
        key: "story.adderallStop", category: .drugs,
        headlines: ["Student Charged After Pills Found in Backpack at Traffic Stop", "College Student Says Pills Were a Friend's Prescription"],
        primaryLaw: "possSchedII", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Knowingly possessed amphetamine, a Schedule II controlled substance, on {DATE}.",
        ageRange: 19...27, occupations: ["college student", "line cook", "delivery driver"], hasVictim: false,
        summaries: [
            "A trooper stopped {D} on {DATE} for speeding and searched the car after {D} consented. In the backpack was an unlabeled sandwich bag with 22 pills identified as amphetamine salts (Adderall). {D} has no prescription. {DL} says a friend gave {D.him} the pills to hold during exams, that {D.he} never took any, and that {D.he} forgot they were in the backpack."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "The Pills", "22 pills in a sandwich bag, identified by the State Crime Laboratory as amphetamine salts.", .search),
            E(.document, 2, "Prescription Check", "No prescription for {D} in the state controlled substances database.")
        ],
        defenseEvidence: [
            E(.document, 2, "Friend's Prescription", "The friend's prescription bottle for the same dosage, filled three weeks earlier.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State Highway Patrol trooper",
                        direct: ["\"{D.He} consented, and I found the bag.\""], cross: ["\"{D.He} was cooperative.\""], weight: 3, lay: false,
                        exam: [
                            .direct("What happened?", "\"A speeding stop. I asked to look in the car and {D.he} said yes. In the backpack, I found an unlabeled bag of pills.\""),
                            .direct("What did {D.he} say?", "\"That a friend gave them to {D.him}. {D.He} said {D.he} forgot they were there.\""),
                            .cross("{D.He} was cooperative.", "\"Very.\""),
                            .cross("There's no sign {D.he} took any.", "\"No.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} had 22 Adderall pills without a prescription in {D.his} backpack. Possession is possession."],
        defenseTheory: ["The pills were a friend's, forgotten in a backpack. {D} never knew they were there, and the friend's prescription proves where they came from."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility", "The defendant has a support system in the community"],
        victimImpacts: [],
        allocutions: ["\"I was holding them for a friend. I know that's not an excuse.\""],
        guiltyTruths: ["{DL}'s messages showed {D.he} had asked the friend for pills before exams the week before."],
        innocentTruths: ["The friend came forward and said {DL} had never asked for or taken any."],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(0, "Afternoon: speeding stop on a county road; consent search.")],
            howIdentified: "A traffic stop and a consent search.",
            defendantExam: [
                .direct("Whose pills are they?", "\"My friend's. I was holding them.\""),
                .direct("Did you know they were in the bag?", "\"I forgot. It was months of exams.\""),
                .cross("You consented to the search.", "\"I had nothing to hide. I forgot.\""),
                .cross("You don't have a prescription.", "\"No.\"")
            ],
            prosecutionOpening: "Twenty-two Adderall pills and no prescription.",
            defenseOpening: "A friend's pills, forgotten in a backpack.",
            prosecutionClosing: "You can't hold someone else's controlled substances.",
            defenseClosing: "{D} didn't know, and the friend says so.",
            family: "Single; a student away from home.",
            residence: "A shared apartment near campus"
        )
    )

    // MARK: - The bicycle rack

    static let bicycleRack = CaseTemplate(
        key: "story.bicycleRack", category: .property,
        headlines: ["Stolen Bicycles Turn Up in Pawn Shop; Seller Charged", "Man Says He Bought Bike From Stranger Outside Library"],
        primaryLaw: "misdLarceny", lesserLaw: nil, threshold: 5, lesserThreshold: 0,
        specification: "Stole a bicycle valued at $480 belonging to {V}, on {DATE}.",
        ageRange: 18...36, occupations: ["unemployed", "dishwasher", "day laborer"], hasVictim: true,
        summaries: [
            "{V}'s $480 commuter bicycle was cut from a bike rack outside the {HOOD} public library on {DATE}. Four days later, {D} sold a bicycle matching its description to a pawn shop, handing over a state ID and signing the pawn ticket. {V}'s serial number matches. {DL} says {D.he} bought the bike for $60 from a man outside the library and didn't know it was stolen."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Pawn Ticket", "A pawn ticket signed by {D} with {D.his} ID number; the bicycle's serial number matches {V}'s purchase receipt."),
            E(.video, 2, "Library Camera", "A hooded person cuts a cable lock and rides off; the face isn't visible.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Bought for $60", "{DL} says {D.he} paid $60 cash to a man outside the library and has no receipt.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Bicycle owner",
                        direct: ["\"I rode that bike to work every day.\""], cross: ["\"I didn't see who took it.\""], weight: 2, lay: true,
                        exam: [
                            .direct("How do you know it's yours?", "\"The serial number on the frame matches my receipt, and it has a scratch on the fork from when I fell last winter.\""),
                            .direct("What did losing it mean?", "\"I got to work an hour late for two weeks. I almost lost my job.\""),
                            .cross("You didn't see who took it.", "\"No.\""),
                            .cross("Bicycles resell all the time.", "\"Not with a serial number.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} sold {V}'s bicycle to a pawn shop four days after it was stolen. Possession of recently stolen property supports the inference {D.he} stole it."],
        defenseTheory: ["{D} bought a bike and sold it. The State can't show {D.he} knew it was stolen, or that {D.he} cut the lock."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility"],
        victimImpacts: ["\"I'd saved up for that bike. I take the bus now, and it adds an hour.\""],
        allocutions: ["\"I needed the money. I should have asked more questions.\""],
        guiltyTruths: ["{DL}'s phone had a photo of the bike taken the night of the theft, next to a bolt cutter."],
        innocentTruths: ["A man arrested later for a string of bicycle thefts admitted selling the bike to {DL} outside the library."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(0, "Afternoon: {V}'s bicycle cut from the library rack."), (4, "{DL} pawns a matching bicycle.")],
            howIdentified: "The pawn ticket and the serial number.",
            defendantExam: [
                .direct("Where did you get the bike?", "\"A man outside the library. Sixty dollars cash.\""),
                .direct("Why sell it?", "\"I needed the money and I didn't need the bike.\""),
                .cross("You paid $60 for a $480 bike.", "\"It was a good deal.\""),
                .cross("You signed the pawn ticket with your own ID.", "\"I had nothing to hide.\"")
            ],
            prosecutionOpening: "A stolen bicycle and a pawn ticket with {D.his} signature.",
            defenseOpening: "A bargain from a stranger.",
            prosecutionClosing: "The man who pawns the bike is usually the man who took it.",
            defenseClosing: "{D} signed his own name. That's not what a thief does.",
            victim: VictimFacts(age: 29, occupation: "pharmacy technician", relationship: "None", harm: ["Lost a $480 commuter bicycle"], restitution: 480, restitutionBasis: "the stolen bicycle"),
            family: "Single; shares a room.",
            residence: "A rented room in {HOOD}"
        )
    )
}
