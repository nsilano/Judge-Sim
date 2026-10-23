import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the cases in StoryCasesAB. Each is a complete new incident; the earlier case appears only
/// as {PRIOR} and {PRIORDATE}, so each reads the same whatever the earlier verdict was.
extension FollowUpCases {
    static let batchAB: [CaseTemplate] = [
        porchPackages, receiptPrinter, dieselTank, companyCard, trailerVIN,
        generatorYard, carFireClaim, stormDeposit, estateSale, layawayBooth
    ]

    // MARK: - Porch packages (after the return desk)

    static let porchPackages = CaseTemplate(
        key: "story.followup.porchPackages", category: .property,
        headlines: ["Doorbell Camera Catches Porch Thief in Broad Daylight", "Three Neighbors' Packages Found in One Car"],
        primaryLaw: "misdLarceny", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Took and carried away a package containing an air fryer valued at $189, the property of {V}, from {V.his} front porch without consent and with intent to permanently deprive {V.him} of it.",
        secondary: [
            SecondaryCharge(lawID: "misdLarceny", specification: "Took two packages valued together at $142 from the porches of two other homes on {STREET} the same afternoon.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...48, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V}'s doorbell camera on {STREET} in {HOOD} recorded a person in a gray hooded sweatshirt taking a package off the porch at 1:15 p.m. on {DATE} and driving off in a silver hatchback. A neighbor read the last four characters of the plate, which led deputies to {DL}'s car. A warrant search of the car that evening found {VL}'s box, opened, with the air fryer inside, and two more packages addressed to neighbors on the same street. {DL}'s phone was on {STREET} at 1:15 p.m. {DL} says {D.he} lent the car to a friend that afternoon and the boxes were left in it."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Doorbell Video", "At 1:15 p.m., a person in a gray hooded sweatshirt lifts a box off {VL}'s porch, walks to a silver hatchback, and drives away. The face is partly visible under the hood."),
            E(.physical, 3, "Car Search", "{VL}'s opened box with the $189 air fryer inside, and two unopened packages addressed to neighbors on {STREET}, found in {DL}'s hatchback by warrant.", .search),
            E(.digital, 3, "Phone Location", "{DL}'s phone on the tower serving {STREET} from 1:05 to 1:30 p.m., by warrant.", .search),
            E(.physical, 2, "Gray Sweatshirt", "A gray hooded sweatshirt on the back seat of the hatchback.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Defendant's Account", "{DL} told deputies a friend borrowed the car from noon to 3 p.m.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"I watched it on my phone at work. My own front door.\""],
                        cross: ["\"The hood covered most of the face.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see on your doorbell video?", "\"Somebody in a gray hoodie walk up my steps, pick up the box like it was theirs, and walk back to a little silver car.\""),
                            .direct("What was in the box?", "\"An air fryer. It was a birthday present for my mother. I'd already told her it was coming.\""),
                            .direct("How did it make you feel?", "\"Like my porch isn't mine. I have everything shipped to work now.\""),
                            .cross("You can't see the face clearly on the video?", "\"Not all of it. The hood was up.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The box was in the defendant's car, and the defendant's phone was on that street.\""],
                        cross: ["\"I spoke to the friend the defendant named.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you find the car?", "\"A neighbor read the last four of the plate. Only one silver hatchback in the county with those characters is registered to someone near {HOOD}: the defendant.\""),
                            .direct("What did the search find?", "\"{VL}'s box, opened, with the air fryer in it, two more packages addressed to neighbors on the same street, and a gray hoodie on the back seat.\""),
                            .direct("Where was the defendant's phone at 1:15?", "\"On the tower serving {STREET}, from 1:05 to 1:30.\""),
                            .cross("You spoke with the friend my client named?", "\"Yes. The friend was at work at a warehouse across the county from eleven to seven. The time clock confirms it.\""),
                            .cross("Lots of people own gray sweatshirts?", "\"They do. Not many of them have {VL}'s air fryer in the back seat.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} drove a street, picked up whatever was on the porches, and was caught with all three boxes."],
        defenseTheory: ["A hooded figure nobody can see clearly, and a car {DL} says was lent out that afternoon."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"It wasn't the air fryer. It was watching somebody walk up to my door like they belonged there.\""],
        allocutions: ["\"I'll pay for all of it. I'm not going to argue about the car anymore.\""],
        guiltyTruths: ["A fourth package from the same street, taken that morning, was found sold on a resale app from {DL}'s account."],
        innocentTruths: ["A relative with a key to the car later admitted taking it that afternoon and leaving {DL}'s phone in the console."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "eyewitnessID"],
        story: StoryExtras(
            timeline: [(0, "Packages taken from three porches on {STREET}; {VL}'s at 1:15 p.m. on doorbell video."), (0, "Warrant search of {DL}'s hatchback that evening."),
                       (5, "Phone location records returned; friend's time clock checked."), (7, "{DL} charged.")],
            howIdentified: "A partial plate read by a neighbor, matched to {DL}'s hatchback.",
            notDone: [],
            defendantExam: [
                .direct("Were you on {STREET} that afternoon?", "\"No. My friend had the car. I was home.\""),
                .direct("How did the packages get in your car?", "\"I don't know. They were there when I got it back.\""),
                .cross("Your friend was on the clock across the county.", "\"Then I don't know who had it.\""),
                .cross("Your phone was on {STREET} at 1:15.", "\"Maybe I left it in the car.\"")
            ],
            prosecutionOpening: "The box, the car, the hoodie, and the phone, all in one place.",
            defenseOpening: "Nobody can see a face on that video.",
            prosecutionClosing: "The friend was at work. The phone wasn't at home. That leaves {DL}.",
            defenseClosing: "A hood and a car aren't a face. The State's video never shows one.",
            time: "1:15 p.m."
        )
    )

    // MARK: - The receipt printer (after the return desk)

    static let receiptPrinter = CaseTemplate(
        key: "story.followup.receiptPrinter", category: .property,
        headlines: ["Fake Receipt Gets $279 Refund at Hardware Store, Police Say", "Receipt Printer and Templates Found on Suspect's Phone"],
        primaryLaw: "larcenyMerchant", lesserLaw: "misdLarceny", threshold: 7, lesserThreshold: 5,
        specification: "Obtained a $279 cash refund from Brennan's Hardware by returning a pressure washer taken from the store's garden center, using a receipt that was not the actual receipt for that merchandise.",
        ageRange: 24...48, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} was charged with a return fraud at Brennan's Hardware in {HOOD}. On {DATE} at about 10:20 a.m., {DL} returned a $279 pressure washer at the service counter with a printed receipt and was paid $279 in cash. The receipt's transaction number belonged to a real sale that day, but for a $12 box of screws. Garden center video shows a person in a ball cap taking a pressure washer off a pallet at 10:12 a.m. and wheeling it toward the service counter. A warrant search of {DL}'s phone found receipt templates for three hardware chains and an order for a thermal receipt printer. {DL} says {D.he} bought the washer and the receipt from a man in the parking lot for $150."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Counter Video", "{DL}, face clearly visible, returning a pressure washer at 10:20 a.m. and taking $279 in cash."),
            E(.video, 2, "Garden Center Video", "At 10:12 a.m., a person in a dark ball cap, face not visible, takes a pressure washer from a pallet and wheels it toward the front of the store. The cap and jacket match those on the counter video."),
            E(.document, 3, "Register Record", "The receipt's transaction number matches a $12 sale of screws at register 3 that morning, paid in cash."),
            E(.digital, 3, "Phone Search", "Receipt templates for three hardware chains, and an order for a thermal receipt printer delivered to {DL}'s address six weeks earlier.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Defendant's Account", "{DL} told the officer {D.he} paid a man in the parking lot $150 for the washer and its receipt.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Store manager",
                        direct: ["\"The receipt was for a box of screws.\""],
                        cross: ["\"I can't see the face in the garden center.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What was wrong with the receipt?", "\"The transaction number was real, but our system says that sale was a $12 box of screws, paid cash at register 3.\""),
                            .direct("What does the garden center video show?", "\"Somebody in a dark cap and the same jacket takes a washer off the pallet at 10:12 and wheels it toward the front. Eight minutes later, the defendant is at my counter with a washer and that cap on.\""),
                            .cross("You can't see a face on the garden center video?", "\"No. The cap's down. Same cap, same jacket.\""),
                            .cross("Did anyone report a person selling items in the parking lot?", "\"Not that day, no.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The phone had the templates and the printer order.\""],
                        cross: ["\"I couldn't find the man in the parking lot.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What was on the defendant's phone?", "\"Receipt templates for three hardware chains, including Brennan's, and an order for a thermal receipt printer, delivered to the defendant's address six weeks before.\""),
                            .direct("Did you check the parking lot cameras?", "\"Yes. The defendant parks at 10:09, walks in empty-handed at 10:10, and comes out at 10:22 with no washer. Nobody approaches the defendant in the lot.\""),
                            .cross("Did you find the printer at my client's home?", "\"No. We didn't find it in the search. The order is on the phone.\""),
                            .cross("You didn't find a man selling washers in the lot?", "\"There wasn't one on the cameras.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} walked in empty-handed, took a washer off a pallet, and turned it into cash with a receipt {D.he} printed at home."],
        defenseTheory: ["The garden center video shows no face. {DL} bought what {D.he} thought was a legitimate return from a stranger."],
        aggravating: ["Planned, using equipment bought for the purpose"],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"I'm not going to make excuses. I need help finding real work.\""],
        guiltyTruths: ["The receipt printer was found later in a storage unit rented in {DL}'s name, with a roll still loaded."],
        innocentTruths: ["The printer order had been placed by a roommate using {DL}'s phone, and the roommate later admitted printing the receipt and sending {DL} in to return the washer."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-42, "Thermal receipt printer delivered to {DL}'s address."), (0, "Washer taken at 10:12 a.m.; returned for $279 cash at 10:20 a.m."), (3, "Register audit flags the receipt."),
                       (8, "Parking lot video reviewed; {DL} identified from the counter video."), (15, "Phone searched by warrant; {DL} charged.")],
            howIdentified: "The counter video and the return log, which records the returning customer's ID.",
            notDone: [],
            defendantExam: [
                .direct("Where did you get the washer?", "\"A guy in the parking lot. He said he couldn't return it himself.\""),
                .direct("Why the printer and the templates?", "\"I was going to start a small business. I needed receipts.\""),
                .cross("The parking lot camera shows you walking in empty-handed.", "\"He met me inside.\""),
                .cross("Templates for three hardware chains, for your own business?", "\"I was looking at what receipts look like.\"")
            ],
            prosecutionOpening: "{DL} walked in with nothing and walked out with $279.",
            defenseOpening: "The one video that would show who took the washer doesn't show a face.",
            prosecutionClosing: "Empty-handed in, cash out, and a receipt printer at home.",
            defenseClosing: "The State's case rests on a cap and a jacket.",
            time: "10:20 a.m."
        )
    )

    // MARK: - Red diesel (after the fuel card)

    static let dieselTank = CaseTemplate(
        key: "story.followup.dieselTank", category: .property,
        headlines: ["260 Gallons of Diesel Siphoned From Construction Site", "Trail Camera Catches Pickup With Transfer Tank at 2 a.m."],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 7, lesserThreshold: 5,
        specification: "Took and carried away about 260 gallons of off-road diesel fuel valued at $1,183 from three excavators at a construction site, the property of Pruitt Grading, with intent to permanently deprive the owner of it.",
        ageRange: 32...60, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a site superintendent for Pruitt Grading found the tanks of three excavators nearly empty on the morning of {DATE} at a subdivision site off {STREET}. A trail camera at the site gate photographed a red pickup with a transfer tank in its bed entering at 2:04 a.m. and leaving at 2:41 a.m. The plate is readable in one frame and is registered to {DL}. A warrant search that afternoon found the transfer tank holding about 240 gallons of red-dyed diesel, the kind sold only for off-road use, and dye in the pickup's own fuel tank. {DL}'s phone was at the site from 2:05 to 2:40 a.m. {DL} says {D.he} bought the dyed diesel for a neighbor's tractor."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Trail Camera", "A red pickup with a bed-mounted transfer tank entering the site gate at 2:04 a.m. and leaving at 2:41 a.m.; one frame shows the plate, registered to {DL}."),
            E(.physical, 3, "Transfer Tank", "About 240 gallons of red-dyed off-road diesel in the transfer tank in {DL}'s pickup; red dye also in the pickup's road fuel tank.", .search),
            E(.digital, 3, "Phone Location", "{DL}'s phone at the construction site from 2:05 to 2:40 a.m., by warrant.", .search),
            E(.document, 2, "Fuel Logs", "Pruitt Grading topped off the three excavators the afternoon before; about 260 gallons were missing the next morning, at $4.55 a gallon."),
            E(.document, 2, "Co-op Records", "The farm co-op {DL} named has no sale of dyed diesel to {DL} or the neighbor in the past year.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Defendant's Account", "{DL} told deputies the fuel was for a neighbor's tractor and came from a farm co-op.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Site superintendent, Pruitt Grading",
                        direct: ["\"We topped them off at four. By seven they were dry.\""],
                        cross: ["\"Dyed diesel is sold at a lot of places.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you find that morning?", "\"Three excavators with the fuel caps off and the gauges near empty. We'd topped them off at four the afternoon before.\""),
                            .direct("How much was missing?", "\"About 260 gallons between the three. At what we pay, $1,183.\""),
                            .direct("What did the trail camera show?", "\"A red pickup with a transfer tank in the bed coming through the gate at 2:04 and leaving at 2:41.\""),
                            .cross("Off-road diesel is sold at farm co-ops and fuel docks all over the county?", "\"It is. Ours went missing the same night that truck came through.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The phone was at the site for thirty-five minutes at two in the morning.\""],
                        cross: ["\"Dyed fuel can't be traced to one tank.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the search of the pickup find?", "\"A transfer tank with about 240 gallons of red-dyed diesel, and dye in the truck's own tank. That's illegal on the road.\""),
                            .direct("Did you check the defendant's account of the co-op?", "\"The co-op has no sale to the defendant or to the neighbor in the last year. The neighbor's tractor runs on gasoline.\""),
                            .direct("Where was the defendant's phone?", "\"At the site, 2:05 to 2:40 a.m.\""),
                            .cross("You can't prove the diesel in the tank came from those excavators?", "\"Not chemically. I can prove where the truck and the phone were.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} drove into a dark construction site at two in the morning, drained three machines, and drove out with a tank full of their fuel."],
        defenseTheory: ["Dyed diesel is everywhere, and the State can't match the fuel in {DL}'s tank to the fuel that went missing."],
        aggravating: [],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"I've been out of work. I'm not proud of what I've done for money since.\""],
        guiltyTruths: ["A siphon hose with the same red dye was found coiled under the seat of {DL}'s pickup when it was released from the tow lot."],
        innocentTruths: ["A relative who borrowed the pickup that night, phone and all, later admitted the theft."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-1, "Excavators topped off at 4 p.m."), (0, "Pickup at the site from 2:04 to 2:41 a.m.; tanks found near empty at 7 a.m."), (0, "Plate traced; pickup searched by warrant that afternoon."),
                       (6, "Phone location records and co-op records returned; {DL} charged.")],
            howIdentified: "The plate in one trail camera frame.",
            notDone: [],
            defendantExam: [
                .direct("Why were you at the site at two in the morning?", "\"I wasn't. I don't know why my phone says that.\""),
                .direct("Where did the dyed diesel come from?", "\"I bought it for a neighbor's tractor.\""),
                .cross("The co-op has no record, and the tractor runs on gas.", "\"I bought it from a guy, not the co-op.\""),
                .cross("Your plate is on the trail camera.", "\"Then somebody had my truck.\"")
            ],
            prosecutionOpening: "A camera, a plate, a phone, and a tank full of red diesel.",
            defenseOpening: "The State can't tell you whose fuel is in that tank.",
            prosecutionClosing: "Thirty-five minutes at a closed site at two in the morning. That's what the fuel came from.",
            defenseClosing: "Red diesel is sold all over the county. Doubt about its source is doubt about the case.",
            time: "2:04 a.m."
        )
    )

    // MARK: - The company card (after the fuel card)

    static let companyCard = CaseTemplate(
        key: "story.followup.companyCard", category: .whiteCollar,
        headlines: ["Tow Truck Driver Charged With Spending $2,310 on Company Card", "Tires, Groceries and a Game Console on the Work Card"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Being an employee of {V} at Rollins Towing & Recovery and entrusted with a company credit card for fuel and roadside supplies, fraudulently converted $2,310 in purchases on that card to {D.his} own use.",
        ageRange: 32...60, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} was hired as a driver by {V}, owner of Rollins Towing & Recovery in {HOOD}, and given a company credit card for fuel and roadside supplies. Over seven weeks ending {DATE}, the card paid for four tires for {DL}'s own pickup ($1,140), a game console ($499) and groceries ($671), $2,310 in all. {V} found the charges on the statement and fired {DL}. {DL} says {V} told {D.him} to use the card in a pinch and take it out of {D.his} paycheck, and points to an earlier $200 personal fuel charge {V} did deduct that way."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Card Statement", "Tire shop $1,140, electronics store $499, grocery stores $671 over seven weeks; none for company trucks or supplies."),
            E(.document, 2, "Tire Shop Invoice", "Four tires mounted on a pickup with {DL}'s plate, signed by {DL}."),
            E(.document, 2, "Card Policy", "Signed by {DL} on the first day: \"Fuel and roadside supplies for company vehicles only.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Payroll Deduction", "A $200 deduction from {DL}'s third paycheck, marked \"fuel, personal,\" for a fill-up of {DL}'s pickup on the company card."),
            E(.digital, 1, "Text Message", "A text from {VL} in {DL}'s first week: \"if you get stuck use the card and we'll square up.\"", .search)
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Owner, Rollins Towing & Recovery",
                        direct: ["\"I said if you get stuck. I didn't say buy a game console.\""],
                        cross: ["\"I did take the $200 out of a check.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What was the card for?", "\"Fuel for the trucks, straps, flares, whatever you need on a call. It's in the policy {DL} signed.\""),
                            .direct("What did you find on the statement?", "\"Tires for a personal pickup, a game console and seven weeks of groceries. Twenty-three hundred dollars.\""),
                            .direct("How did that affect your business?", "\"I run four trucks. That's a month of insurance. I gave {DL} a job when other people wouldn't, and I felt like a fool.\""),
                            .cross("You told my client to use the card if stuck?", "\"Once, about gas, the first week. I meant gas to get home.\""),
                            .cross("You deducted $200 for personal fuel?", "\"Because {DL} told me about it. Nobody told me about the tires.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"None of the charges were disclosed until the statement came.\""],
                        cross: ["\"There was a text about using the card.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Did the defendant ever report these charges?", "\"No. The $200 fill-up was reported. The $2,310 wasn't, until the statement arrived.\""),
                            .direct("What did the tire invoice show?", "\"Four tires mounted on the defendant's own pickup, signed by the defendant.\""),
                            .cross("You saw the text from {VL} about using the card?", "\"Yes. 'If you get stuck use the card and we'll square up.' From the first week.\""),
                            .cross("So there was permission?", "\"Permission to get unstuck. Not a game console.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} was given a card for the trucks and used it on {D.himself}, quietly, until the statement came."],
        defenseTheory: ["{VL} told {DL} to use the card and square up later, and did exactly that once. This is a payroll dispute."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I took a chance on {DL}. I won't take one on anybody else for a long time.\""],
        allocutions: ["\"I thought I'd square it up like the first time. I let it get away from me.\""],
        guiltyTruths: ["The game console was resold online by {DL} the week after it was bought."],
        innocentTruths: ["{VL} had told {DL} in front of another driver to put the tires on the card and pay them off over the summer."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-56, "{DL} hired; signs the card policy."), (-49, "{VL}'s text about using the card."), (-40, "$200 personal fill-up deducted from {DL}'s paycheck."),
                       (-30, "Tires bought on the card."), (0, "Last grocery charge."), (8, "Statement arrives; {DL} fired."), (20, "{DL} charged.")],
            howIdentified: "{VL} found the charges on the monthly statement.",
            notDone: [],
            defendantExam: [
                .direct("Why did you use the card for tires?", "\"My truck's tires were bald and I couldn't get to work without it. {VL} said square up later.\""),
                .direct("Did you plan to pay it back?", "\"Yes. Same as the fuel.\""),
                .cross("You told {VL} about the fuel. Not about the tires.", "\"I was going to.\""),
                .cross("A game console isn't getting unstuck.", "\"No. That one I can't defend.\"")
            ],
            prosecutionOpening: "A card for the trucks, and $2,310 spent on anything but.",
            defenseOpening: "The boss said use it and square up. {DL} did.",
            prosecutionClosing: "Squaring up means telling. {DL} told about $200 and hid $2,310.",
            defenseClosing: "A deal between an employer and an employee went bad. That's a civil problem.",
            victim: VictimFacts(occupation: "Towing company owner", relationship: "The defendant's former employer."),
            employer: "Rollins Towing & Recovery",
            employmentEnded: true
        )
    )

    // MARK: - The ground-off VIN (after the mower)

    static let trailerVIN = CaseTemplate(
        key: "story.followup.trailerVIN", category: .property,
        headlines: ["Owner Finds Stolen Cargo Trailer in Online Listing", "VIN Ground Off, but Hidden Number Gives Trailer Away"],
        primaryLaw: "possStolen", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Possessed and offered for sale an enclosed cargo trailer valued at $6,800, the property of {V}, knowing or having reasonable grounds to believe it had been stolen.",
        ageRange: 25...58, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V}'s 7-by-14 enclosed cargo trailer, worth $6,800, was taken from {VL}'s driveway. Six weeks later, {V} found it listed online for $2,900, recognizing a roof vent {VL} had installed. Posing as a buyer, a detective met the seller, {DL}, at a gas station on {STREET} on {DATE}. The trailer's VIN plate had been ground off, but the manufacturer's second VIN, stamped inside the tongue, matched {VL}'s registration. {DL} says {D.he} bought it at a cash trailer auction. A warrant search of {DL}'s phone found a message from an unsaved number weeks before: \"flip it quick, don't run the VIN.\""
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Hidden VIN", "The VIN stamped inside the trailer tongue matches {VL}'s registration; the plate on the front rail has been ground smooth."),
            E(.digital, 3, "Phone Message", "From an unsaved number, eleven days before {DATE}: \"flip it quick, don't run the VIN.\" {DL} replied \"got it.\"", .search),
            E(.digital, 2, "Listing", "\"Enclosed trailer, great shape, $2,900 cash, no trades,\" posted from {DL}'s account."),
            E(.document, 2, "Owner's Records", "{VL}'s purchase invoice ($6,800) and a receipt for the roof vent {VL} installed.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Defendant's Account", "{DL} told the detective {D.he} bought the trailer at a cash auction in a neighboring county for $1,800.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Owner of the trailer",
                        direct: ["\"I put that vent in myself. I knew it the second I saw the picture.\""],
                        cross: ["\"I don't know who took it from my driveway.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened to your trailer?", "\"I went out one morning and the driveway was empty. Hitch lock cut and lying in the grass.\""),
                            .direct("How did you find it?", "\"I looked at listings every night. Six weeks later there it was, with the roof vent I put in myself.\""),
                            .direct("What did losing it mean for you?", "\"I haul for craft fairs on weekends. I lost two months of shows and most of a season's money.\""),
                            .cross("You don't know who took it?", "\"No. I know who was selling it.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"Somebody took a grinder to the VIN plate.\""],
                        cross: ["\"I couldn't identify the number that sent the message.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find when you met the defendant?", "\"The VIN plate on the front rail was ground smooth. The second VIN inside the tongue matched {VL}'s registration.\""),
                            .direct("What was on the defendant's phone?", "\"A message eleven days before: 'flip it quick, don't run the VIN.' The defendant answered 'got it.'\""),
                            .direct("Did you check the auction?", "\"The auction house the defendant named has no sale of an enclosed trailer to anyone in the last three months.\""),
                            .cross("You never identified who sent that message?", "\"A prepaid number, shut off since. No.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} was told not to run the VIN, answered 'got it,' and put a ground-off trailer up for less than half its value."],
        defenseTheory: ["{DL} didn't steal it, and the State can't say who sent the message or what it meant."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I check the driveway every morning before coffee now.\""],
        allocutions: ["\"I should have known better than to take that deal.\""],
        guiltyTruths: ["The prepaid number was later found to belong to a man {DL} had sold two other trailers for, both stolen."],
        innocentTruths: ["The message was about a different trailer {DL} was selling for a coworker, whose title was in the mail; the trailer at issue came from a cash sale {DL} had no reason to doubt."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-45, "Trailer taken from {VL}'s driveway."), (-11, "Message to {DL}: \"flip it quick, don't run the VIN.\""), (-4, "Listing posted from {DL}'s account."),
                       (-2, "{VL} recognizes the trailer and calls the Sheriff's Office."), (0, "Detective meets {DL} on {STREET}; hidden VIN matches."), (7, "Phone searched by warrant; {DL} charged.")],
            howIdentified: "{VL} recognized the trailer in the listing; a detective arranged to buy it.",
            notDone: [],
            defendantExam: [
                .direct("Where did you get the trailer?", "\"A cash auction. I paid $1,800 and figured I could make a little.\""),
                .direct("Did you grind off the VIN?", "\"No. It was like that.\""),
                .cross("The auction has no record of selling it.", "\"It was a cash sale at the back of the lot.\""),
                .cross("'Don't run the VIN.' And you said 'got it.'", "\"I didn't think about what that meant.\"")
            ],
            prosecutionOpening: "A ground-off VIN and a message telling {DL} not to look.",
            defenseOpening: "The State can't say who stole the trailer, or who sent that message.",
            prosecutionClosing: "Reasonable grounds to believe. 'Don't run the VIN' is the most reasonable ground there is.",
            defenseClosing: "A cheap trailer is not knowledge.",
            victim: VictimFacts(occupation: "Craft vendor", relationship: "A stranger to the defendant.")
        )
    )

    // MARK: - The rental yard (after the mower)

    static let generatorYard = CaseTemplate(
        key: "story.followup.generatorYard", category: .property,
        headlines: ["Two Generators Taken From Rental Yard Overnight", "Plate Reader Puts Pickup Near Yard Minutes After Theft"],
        primaryLaw: "felonyLarceny", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Took and carried away two portable generators valued at $5,200, the property of Hollis Equipment Rental, with intent to permanently deprive the owner of them.",
        ageRange: 25...58, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, someone cut through the fence of Hollis Equipment Rental in {HOOD} at about 3:05 a.m. on {DATE} and loaded two portable generators, worth $2,600 each, into a dark pickup. The yard camera shows one person in dark clothes with a face covering. A license plate reader on {STREET}, a quarter mile away, read {DL}'s pickup plate at 3:12 a.m. Four days later a warrant search found both generators in {DL}'s shed, asset tags peeled off, serial numbers matching. {DL} says a friend asked to store them there and {D.he} never asked where they came from."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Yard Camera", "At 3:05 a.m., one person in dark clothes and a face covering cuts the fence and loads two generators into a dark pickup; the plate is not visible."),
            E(.digital, 3, "Plate Reader", "{DL}'s pickup read on {STREET}, a quarter mile from the yard, at 3:12 a.m."),
            E(.physical, 3, "Shed Search", "Both generators in {DL}'s locked shed, asset tags peeled off, serial numbers matching the rental yard's records.", .search),
            E(.digital, 2, "Phone Location", "{DL}'s phone near the rental yard from 2:55 to 3:15 a.m., by warrant.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Defendant's Account", "{DL} told deputies a friend dropped the generators off to store and that {D.he} has the only key to the shed but leaves it unlocked by day.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Rental yard manager",
                        direct: ["\"Two generators gone, a hole in the fence.\""],
                        cross: ["\"You can't see a face on our camera.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you find that morning?", "\"A hole cut in the back fence and two of our big generators gone. $2,600 each.\""),
                            .direct("What does your camera show?", "\"One person, dark clothes, something over the face, loading them into a dark pickup at 3:05.\""),
                            .direct("How did you identify them later?", "\"Serial numbers. The tags were peeled off, but the numbers are stamped on the frames.\""),
                            .cross("You can't see a face or a plate on your video?", "\"No. Just the truck and the person.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The plate reader, the phone, and the shed.\""],
                        cross: ["\"I asked for the friend's name.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you come to the defendant?", "\"The plate reader on {STREET} logged the defendant's pickup at 3:12, seven minutes after the yard camera.\""),
                            .direct("What did the phone records show?", "\"The defendant's phone near the yard from 2:55 to 3:15.\""),
                            .direct("What was in the shed?", "\"Both generators, tags peeled off, serial numbers matching.\""),
                            .cross("You asked my client who dropped them off?", "\"I did. The defendant wouldn't give me a name.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D}'s truck and phone were at the yard at three in the morning, and the generators ended up in {D.his} shed with the tags peeled off."],
        defenseTheory: ["The video shows no face and no plate. A truck on a public road and generators someone else left in a shed."],
        aggravating: [],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"I'm not going to name anybody. I'll take what comes.\""],
        guiltyTruths: ["The bolt cutters used on the fence were in {DL}'s truck toolbox, with fence paint on the jaws."],
        innocentTruths: ["The friend {DL} wouldn't name had borrowed {DL}'s truck and phone that night, and later admitted the theft."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Fence cut and generators taken at 3:05 a.m.; plate reader logs {DL}'s pickup at 3:12 a.m."), (2, "Plate reader hit reviewed."),
                       (4, "Warrant search of {DL}'s shed; generators recovered."), (9, "Phone location records returned; {DL} charged.")],
            howIdentified: "A license plate reader near the yard.",
            notDone: [],
            defendantExam: [
                .direct("Where were you at 3 a.m. that night?", "\"Driving. I couldn't sleep.\""),
                .direct("How did the generators get in your shed?", "\"A friend asked to store them.\""),
                .cross("Who is the friend?", "\"I'm not going to say.\""),
                .cross("Your truck and phone were a quarter mile from the yard.", "\"That road's how I get anywhere.\"")
            ],
            prosecutionOpening: "At 3:05 the generators left the yard. At 3:12 {DL}'s truck went by. Four days later, they were in {DL}'s shed.",
            defenseOpening: "No face, no plate, and a shed anybody could reach.",
            prosecutionClosing: "A friend with no name is no defense.",
            defenseClosing: "Being near something isn't doing it.",
            time: "3:05 a.m."
        )
    )

    // MARK: - The burned SUV (after the hail claim)

    static let carFireClaim = CaseTemplate(
        key: "story.followup.carFireClaim", category: .whiteCollar,
        headlines: ["'Stolen' SUV Found Burned on Logging Road", "Owner's Phone Near the Fire, Investigators Say"],
        primaryLaw: "insuranceFraud", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "With intent to defraud, presented a claim to {D.his} auto insurer for the theft of {D.his} SUV, knowing the claim was false.",
        ageRange: 30...62, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} reported {D.his} SUV stolen from the Hollis Crossing mall lot at 9:40 p.m. on {DATE}. It was found burned on a logging road at 6 a.m. the next day, and {DL} filed a theft claim. {DL} was three payments behind on the SUV loan. The mall's entrance plate readers never logged the SUV that evening. {DL} told the deputy {D.he} went home by ride share and was asleep all night, but {D.his} phone, searched by warrant, was on the tower covering the logging road at 1:05 a.m. {DL} now says {D.he} went out driving to look for the SUV."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Mall Plate Readers", "The readers at all three mall entrances logged no sign of {DL}'s SUV between 4 p.m. and midnight."),
            E(.digital, 3, "Phone Location", "{DL}'s phone on the tower covering the logging road from 12:50 to 1:20 a.m.", .search),
            E(.document, 2, "Loan Records", "Three missed payments; $14,800 owed on an SUV valued at about $11,000."),
            E(.statement, 2, "Statement to Deputy", "{DL} said {D.he} took a ride share home at 9:50 p.m. and \"was asleep all night.\"", .statement),
            E(.forensic, 2, "Fire Report", "Gasoline poured on the front seats; the steering column was not forced.")
        ],
        defenseEvidence: [
            E(.document, 2, "Ride Share Receipt", "A ride from the mall to {DL}'s home at 9:52 p.m.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Fire investigator",
                        direct: ["\"It was set, from the inside, with gasoline.\""],
                        cross: ["\"A thief can burn a car too.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did the fire start?", "\"Gasoline poured on the front seats and lit. The pour pattern is clear.\""),
                            .direct("Was the SUV forced?", "\"The steering column was intact. Whoever drove it there had a way to start it.\""),
                            .cross("Thieves burn cars to destroy evidence?", "\"They do. Usually they've forced the column first.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Insurance fraud investigator, Department of Insurance",
                        direct: ["\"The SUV never went to the mall. The phone went to the fire.\""],
                        cross: ["\"The ride share receipt is real.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the mall's plate readers show?", "\"Nothing. All three entrances, four in the afternoon to midnight, and the SUV isn't there.\""),
                            .direct("Where was the defendant's phone that night?", "\"On the tower covering the logging road from 12:50 to 1:20 a.m. The defendant told the deputy the defendant was asleep.\""),
                            .direct("What was the defendant's financial situation?", "\"Three payments behind, owing $14,800 on an SUV worth about $11,000.\""),
                            .cross("The ride share from the mall is real?", "\"It is. The defendant got to the mall somehow. The SUV didn't.\""),
                            .cross("Could my client have been out looking for it?", "\"That's not what the defendant said that night.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} owed more than the SUV was worth, left it somewhere else, reported it stolen, and was on the logging road the night it burned."],
        defenseTheory: ["{DL} was at the mall, took a ride home, and went looking for the SUV. Plate readers miss cars."],
        aggravating: [],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"I was drowning in that loan. I'm not asking anyone to understand.\""],
        guiltyTruths: ["A gas can bought at a station near the logging road at 12:40 a.m. was paid for with {DL}'s debit card."],
        innocentTruths: ["A ring of car thieves operating at the mall was later caught using a fob reader to start SUVs; the mall readers had been down at one entrance that night."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "{DL} reports the SUV stolen at 9:40 p.m.; ride share home at 9:52 p.m."), (1, "Phone on the logging road tower, 12:50 to 1:20 a.m.; SUV found burned at 6 a.m."),
                       (2, "Theft claim filed."), (20, "Plate reader data and fire report returned."), (35, "Phone searched by warrant; {DL} charged.")],
            howIdentified: "The insurer referred the claim; the Department of Insurance investigated.",
            notDone: [],
            defendantExam: [
                .direct("Where did you leave the SUV?", "\"At the mall. I came out and it was gone.\""),
                .direct("Why was your phone on the logging road?", "\"I went driving around looking for it. I couldn't sleep.\""),
                .cross("You told the deputy you were asleep all night.", "\"I was upset. I didn't think it mattered.\""),
                .cross("Driving what? Your SUV was gone.", "\"My neighbor lent me a car.\""),
                .cross("Three readers never saw the SUV at the mall.", "\"I don't know how those work.\"")
            ],
            prosecutionOpening: "The SUV never went to the mall, and {DL} went to the fire.",
            defenseOpening: "Plate readers miss cars. People look for their stolen property.",
            prosecutionClosing: "Asleep all night, said {DL}. The phone says otherwise.",
            defenseClosing: "A changed story isn't proof of fraud.",
            time: "9:40 p.m."
        )
    )

    // MARK: - The storm deposit (after the hail claim)

    static let stormDeposit = CaseTemplate(
        key: "story.followup.stormDeposit", category: .whiteCollar,
        headlines: ["Door-to-Door Roofer Took $6,500 From Retiree, Never Started", "Deposit Spent the Same Day, Records Show"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Obtained $6,500 from {V} by falsely representing that {D.he} would buy materials and replace {V.his} storm-damaged roof, intending to deceive.",
        ageRange: 30...62, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} went door to door in {HOOD} after a windstorm, offering roof repairs. On {DATE}, {V}, 74, signed a contract for a $13,000 roof replacement and wrote {DL} a $6,500 check for materials. No materials were ordered and no work began. Bank records show {DL} cashed the check that afternoon and paid $4,000 on {D.his} credit card and car loan the same day. {DL} paid back $500 after a deputy called. {DL} says a supplier delay and a hurt back kept {D.him} from the job, and that {D.he} always meant to do it."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Contract and Check", "A $13,000 contract signed by {VL} and {DL}, and {VL}'s $6,500 check \"for materials,\" cashed the same afternoon."),
            E(.document, 3, "Bank Records", "On the day of the check: $2,600 to {DL}'s credit card and $1,400 to {D.his} car loan.", .search),
            E(.document, 2, "Supplier Records", "The two roofing suppliers in the county have no order from {DL} in the past year."),
            E(.digital, 2, "Phone Search", "Texts to {VL} over five weeks: \"shingles on backorder,\" \"next Monday for sure,\" \"hurt my back, one more week.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Repayment", "A $500 money order to {VL} after the deputy's call."),
            E(.document, 1, "Doctor's Note", "An urgent care note for back strain, dated two weeks after {DATE}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"Next Monday, every Monday.\""],
                        cross: ["\"I did get $500 back.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How did you meet the defendant?", "\"{DL} knocked on my door two days after the storm. Said shingles were blowing off my roof and I needed a new one before the rain.\""),
                            .direct("What did you pay?", "\"Half up front, $6,500, for materials. {DL} said they'd order that afternoon.\""),
                            .direct("What happened after?", "\"Texts. Backorder. Next Monday. A bad back. Five weeks of it. I put buckets in the bedroom when it rained.\""),
                            .cross("You received $500 back?", "\"After the deputy called. Not before.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"No order was ever placed. The money was gone that day.\""],
                        cross: ["\"There is a doctor's note.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Were any materials ordered?", "\"Neither roofing supplier in the county has an order from the defendant in the last year.\""),
                            .direct("Where did the $6,500 go?", "\"Cashed the same afternoon. $2,600 to a credit card and $1,400 to a car loan that day.\""),
                            .direct("Did the defendant pitch other homes?", "\"Three neighbors on the same street say the defendant knocked and quoted them. None paid.\""),
                            .cross("My client did hurt their back?", "\"Two weeks after taking the money. The backorder texts started before that.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} took a retiree's materials money and spent it on {D.his} own bills the same afternoon. There were never any shingles."],
        defenseTheory: ["{DL} is a bad contractor who got hurt and fell behind. A broken contract is a civil matter."],
        aggravating: ["Victim was elderly"],
        mitigating: [],
        victimImpacts: ["{VL}: \"I'm seventy-four. I can't climb up there. I trusted the person at my door.\""],
        allocutions: ["\"I meant to do that roof. I got in over my head and I'll pay {VL} back.\""],
        guiltyTruths: ["{DL} had taken a $4,000 deposit from a homeowner in the next county the week before, with the same texts about a backorder."],
        innocentTruths: ["{DL} had paid a roofing crew a $3,000 cash deposit that week, and the crew's owner skipped town with it."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-2, "Windstorm crosses {HOOD}."), (0, "{VL} signs the contract and pays $6,500; check cashed that afternoon."), (3, "First backorder text."),
                       (14, "Urgent care visit for back strain."), (35, "{VL} calls the Sheriff's Office."), (37, "$500 money order to {VL}."), (50, "Bank and supplier records returned; {DL} charged.")],
            howIdentified: "{VL} reported the contractor by name and phone number.",
            notDone: [],
            defendantExam: [
                .direct("Did you intend to do the roof?", "\"Yes. I was going to.\""),
                .direct("Why weren't materials ordered?", "\"I was waiting on a better price. Then I hurt my back.\""),
                .cross("You told {VL} shingles were on backorder. No order existed.", "\"I said that to buy time.\""),
                .cross("$4,000 to your own bills the day you got the check.", "\"I was going to put it back when the next job paid.\"")
            ],
            prosecutionOpening: "The money was for shingles. There were never any shingles.",
            defenseOpening: "A contractor failed. That's not the same as a fraud.",
            prosecutionClosing: "The lie about the backorder came before the bad back.",
            defenseClosing: "Bad business is not a crime unless the State proves the intent from the start.",
            victim: VictimFacts(age: 74, occupation: "Retired", relationship: "A stranger to the defendant.")
        )
    )

    // MARK: - The estate sale (after the consignment shop)

    static let estateSale = CaseTemplate(
        key: "story.followup.estateSale", category: .whiteCollar,
        headlines: ["Estate Sale Operator Charged With Keeping Family's $8,905", "Card Reader Shows Sales the Operator Didn't Report"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Having been entrusted with the proceeds of an estate sale held for {V}, fraudulently converted to {D.his} own use $8,905 due to {V}.",
        ageRange: 34...65, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} began running estate sales in {HOOD}. {V} hired {DL} to sell the contents of {VL}'s late aunt's house on {STREET}. The contract gave {DL} 35 percent and {V} 65 percent, paid within 14 days. The sale ended on {DATE}. {DL} reported total sales of $5,200 and paid nothing. {DL}'s card reader records alone show $9,100 in card sales, and a cousin of {VL}'s photographed {DL}'s own tally sheet at the close of the second day: $13,700. {VL}'s 65 percent of that is $8,905. {DL} says the tally sheet was gross before refunds and that the card reader included another sale."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Contract", "35 percent to {DL}, 65 percent to {VL}, within 14 days of the sale's end."),
            E(.document, 3, "Card Reader Records", "$9,100 in card sales at the sale address over the two days.", .search),
            E(.digital, 3, "Tally Sheet Photo", "Photo taken by {VL}'s cousin at 4:10 p.m. on the second day: {DL}'s handwritten total, \"$13,700.\""),
            E(.document, 2, "Bank Records", "$9,100 in card deposits to {DL}'s personal account; $3,800 in cash deposits the next week.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Defendant's Account", "{DL} says the tally was gross before refunds and the card reader included a second, smaller sale that weekend.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Family member who hired the defendant",
                        direct: ["\"My aunt's whole life went out that door, and I got nothing.\""],
                        cross: ["\"I wasn't there the whole time.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you hire the defendant?", "\"My aunt raised me after my parents died. I couldn't stand in that house and put prices on her things.\""),
                            .direct("What were you told about the sale?", "\"That it brought $5,200, and there were expenses, and a check was coming. It never came.\""),
                            .direct("How did you learn otherwise?", "\"My cousin had taken a picture of the tally sheet at the end. Thirteen thousand seven hundred.\""),
                            .cross("You weren't at the sale yourself?", "\"No. I couldn't be. That's why I paid someone.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"There was no other sale that weekend.\""],
                        cross: ["\"There were some refunds.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the card reader records show?", "\"$9,100 in card sales, all at the {STREET} address over the two days. That alone is more than the $5,200 the defendant reported.\""),
                            .direct("Was there a second sale that weekend?", "\"No. The defendant's own website and ads list one sale that weekend: this one.\""),
                            .direct("What about cash?", "\"$3,800 in cash deposits to the defendant's account the next week. That plus the card sales is $12,900.\""),
                            .cross("Were there refunds?", "\"Two, on the card reader, totaling $160. They're already netted out of the $9,100.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} told a grieving family the sale brought $5,200, kept every dollar, and the card reader alone proves the lie."],
        defenseTheory: ["Estate sale accounting is messy. {DL} owes {VL} money, but this is a contract dispute."],
        aggravating: ["Took advantage of a grieving family"],
        mitigating: [],
        victimImpacts: ["{VL}: \"I didn't need the money as much as I needed to know her things went to people who'd want them, and that I was told the truth.\""],
        allocutions: ["\"I'll make it right. I'll pay every dollar.\""],
        guiltyTruths: ["{DL} had under-reported two other estate sales the same spring by the same method."],
        innocentTruths: ["A helper {DL} hired had pocketed the cash box on the second day; {DL} reported only what {D.he} could account for."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-1, "First day of the sale."), (0, "Second day; tally sheet photographed at 4:10 p.m.; sale ends."), (14, "Payment due; none made."),
                       (20, "{DL} reports $5,200 in sales."), (40, "{VL} complains to the Sheriff's Office."), (70, "Card reader and bank records returned; {DL} charged.")],
            howIdentified: "{VL}'s complaint and the cousin's photo of the tally sheet.",
            notDone: [],
            defendantExam: [
                .direct("Why did you report $5,200?", "\"After refunds and expenses, that's what I had.\""),
                .direct("Did you mean to pay {VL}?", "\"Yes. I was going to when things settled.\""),
                .cross("Card sales alone were $9,100.", "\"Some of that was from another sale.\""),
                .cross("Your own ads list one sale that weekend.", "\"I helped a friend with a yard sale. It wasn't advertised.\"")
            ],
            prosecutionOpening: "The card reader alone shows $9,100. {DL} reported $5,200 and paid nothing.",
            defenseOpening: "Estate sales are cash, refunds, and messy books.",
            prosecutionClosing: "Under-reporting by thousands and paying nothing isn't messy books. It's taking.",
            defenseClosing: "{DL} owes a debt. The State hasn't proved a crime.",
            victim: VictimFacts(relationship: "Hired the defendant to run an estate sale.", family: "The late aunt raised {VL}.")
        )
    )

    // MARK: - The layaway booth (after the consignment shop)

    static let layawayBooth = CaseTemplate(
        key: "story.followup.layawayBooth", category: .whiteCollar,
        headlines: ["Flea Market Furniture Seller Vanishes With Customers' Deposits", "Six Custom Tables Paid For, None Delivered"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Obtained $1,450 from {V} by falsely representing that {D.he} would build and deliver a custom farmhouse table within four weeks, intending to deceive.",
        ageRange: 34...65, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} rented a booth at the {HOOD} flea market selling refurbished furniture and taking orders for custom farmhouse tables. On {DATE}, {V} paid a $1,450 deposit for a table promised in four weeks. Five other customers paid deposits over the same month, $6,200 in all. No tables were delivered, and {DL} gave up the booth seven weeks later. {DL} says the woodworker building the tables quit, and shows a $600 lumber receipt. The woodworker says {DL} never paid for any work and that the lumber was for one table."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Order Slip", "{VL}'s receipt: \"custom farmhouse table, 8 ft, delivery in 4 weeks, $1,450 deposit paid.\""),
            E(.document, 2, "Other Deposits", "Five more order slips over the same month; $6,200 in deposits in all."),
            E(.document, 2, "Bank Records", "Deposits went to {DL}'s personal account; withdrawals for rent and a car payment; $600 at a lumber yard.", .search),
            E(.digital, 2, "Phone Search", "Texts to the woodworker: \"just need one table to show, the rest later.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Lumber Receipt", "$600 in oak boards from a lumber yard, three days after {VL}'s deposit."),
            E(.digital, 1, "Woodworker's Text", "A text from the woodworker to {DL}: \"I'm out, can't do six tables.\"", .search)
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Customer",
                        direct: ["\"I wanted that table for the family at Thanksgiving.\""],
                        cross: ["\"{DL} did show me a table in the booth.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you order?", "\"An eight-foot farmhouse table. Our family's gotten big, and we've never all sat at one table.\""),
                            .direct("What did you pay?", "\"$1,450 down. Four weeks, I was told.\""),
                            .direct("What happened?", "\"Week five, excuses. Week seven, the booth was empty and the number didn't answer.\""),
                            .cross("My client showed you a finished table in the booth?", "\"A sample. I never saw one with my name on it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Woodworker",
                        direct: ["\"I was asked for one table. Then six.\""],
                        cross: ["\"I did quit.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did the defendant ask you to build?", "\"One table, to put in the booth. Later {DL} said there were six orders.\""),
                            .direct("Were you paid?", "\"Not a dollar. I built the sample from the $600 of lumber and that was it.\""),
                            .cross("You quit the job?", "\"I quit because I wasn't paid, and six tables is three months of work, not four weeks.\""),
                            .cross("So my client did buy lumber?", "\"Enough for one table.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The deposits went to rent and a car payment.\""],
                        cross: ["\"Some money went to lumber.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where did the deposits go?", "\"Into the defendant's personal account, then out to rent, a car payment, and everyday spending. $600 went to the lumber yard.\""),
                            .direct("Did the defendant contact the customers before leaving?", "\"No. The booth was cleared out and the phone stopped answering.\""),
                            .cross("So some money went to the work?", "\"$600 of $6,200.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} took six deposits for tables {D.he} had no way to build, spent the money on {D.his} own bills, and left."],
        defenseTheory: ["{DL} bought lumber, had a builder, and lost the builder. A business that failed isn't a fraud."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"We ate on card tables again. It's silly to cry over a table, and I did.\""],
        allocutions: ["\"I thought I could get it done. I owe those people.\""],
        guiltyTruths: ["{DL} was taking the same kind of deposits at a flea market in the next county under a different booth name."],
        innocentTruths: ["{DL} had lined up a second builder, who backed out after a fire in his shop, a week before the booth closed."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "{VL} pays a $1,450 deposit."), (3, "$600 in lumber bought."), (14, "Woodworker finishes the sample table."), (28, "{VL}'s promised delivery date."),
                       (30, "Woodworker quits."), (49, "Booth vacated; {DL}'s phone stops answering."), (60, "Customers complain; records subpoenaed."), (80, "{DL} charged.")],
            howIdentified: "Complaints from six customers with order slips.",
            notDone: [],
            defendantExam: [
                .direct("Did you intend to deliver the table?", "\"Yes. The builder quit on me.\""),
                .direct("Why not refund the deposits?", "\"The money was spent. I was trying to find another builder.\""),
                .cross("You took six orders with one builder you hadn't paid.", "\"I was going to pay when the tables sold.\""),
                .cross("You stopped answering your phone.", "\"I didn't know what to say to them.\"")
            ],
            prosecutionOpening: "Six deposits, one sample table, and an empty booth.",
            defenseOpening: "{DL} bought lumber and hired a builder. The builder quit.",
            prosecutionClosing: "Six tables in four weeks from one unpaid builder was never a real promise.",
            defenseClosing: "A broken promise is not a lie when it was made. The State must prove the second.",
            when: .months([9, 10, 11]),
            victim: VictimFacts(occupation: "Customer", relationship: "A stranger to the defendant.")
        )
    )
}
