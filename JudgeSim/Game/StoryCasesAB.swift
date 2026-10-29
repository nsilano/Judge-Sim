import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAB: [CaseTemplate] = [returnDesk, fuelCard, zeroTurnMower, hailClaim, consignmentShop]

    // MARK: - 149. The return desk (shelf to service counter, no receipt)

    static let returnDesk = CaseTemplate(
        key: "story.returnDesk", category: .property,
        headlines: ["Shopper Charged With 'Returning' Tools Never Bought", "Seven No-Receipt Returns, One License, Store Says"],
        primaryLaw: "larcenyMerchant", lesserLaw: "misdLarceny", threshold: 7, lesserThreshold: 5,
        specification: "Took a 20-volt combo tool kit valued at $389 from the shelves of Tri-County Home Center and, without paying for it, returned it at the service desk without a receipt to obtain a store credit card for $389.",
        secondary: [
            SecondaryCharge(lawID: "larcenyMerchant", specification: "On four earlier dates within the prior three weeks, took merchandise valued at $1,243 from the shelves of Tri-County Home Center and returned it at the service desk without a receipt for store credit.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...48, occupations: ["handyman"], hasVictim: false,
        summaries: [
            "On {DATE} at about 2:47 p.m., {D} took a $389 cordless tool kit from aisle 14 of Tri-County Home Center in {HOOD}, carried it straight to the service desk, and returned it without a receipt for a $389 store credit card, the store says. Loss prevention had flagged {DL}'s driver's license after six earlier no-receipt returns in five weeks, worth $1,751. Store video shows {DL} taking the kit off the shelf. A deputy stopped {DL} in the parking lot at 2:58 p.m. with the credit card in {D.his} wallet, and a warrant search of {D.his} phone found six earlier store cards sold on a resale app for 70 cents on the dollar. {DL} says {D.he} had bought an identical kit at another location and only took a sealed one off the shelf because the box in {D.his} truck was torn."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Aisle 14 and Desk Video", "{DL} lifting a boxed 20-volt combo kit off the aisle 14 shelf at 2:44 p.m., walking it to the service desk without passing a register, and receiving a store card at 2:47 p.m."),
            E(.document, 3, "Return Log", "Seven no-receipt returns in five weeks, all on {DL}'s driver's license: six earlier totaling $1,751, and the $389 kit on {DATE}. Total $2,140."),
            E(.video, 2, "Earlier Return Videos", "Video of the four most recent earlier returns ($1,243 in all), each showing {DL} taking the item from a shelf and walking it to the desk. The first two returns are older than the store's 30-day video retention."),
            E(.digital, 3, "Resale App Records", "{DL}'s phone, searched by warrant, shows six Tri-County store cards sold on a gift card resale app for $1,226 total, each sold within a day of a return.", .search),
            E(.physical, 2, "Store Card", "The $389 store credit card issued at 2:47 p.m., found in {DL}'s wallet at 2:58 p.m.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Earlier Receipt", "A receipt from the Tri-County store across the county showing {DL} bought an identical 20-volt combo kit for $389 six weeks before {DATE}."),
            E(.document, 1, "Work Invoices", "Handyman invoices showing {DL} buys and uses a large number of tools.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Loss prevention officer",
                        direct: ["\"It never left the store. It went from the shelf to the desk.\""],
                        cross: ["\"Our policy allowed those returns with an ID.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Why were you watching the defendant on {DATE}?", "\"Our system flags a license after a run of no-receipt returns. This one had six in five weeks. When it scanned again, I pulled up the cameras.\""),
                            .direct("What did the cameras show?", "\"At 2:44 the defendant picks a combo kit off the aisle 14 shelf, walks it to the service desk, and returns it. Card issued at 2:47. The kit never went near a register.\""),
                            .direct("And the earlier returns?", "\"We keep video thirty days, so I had the last four. Same thing each time. Shelf, then desk.\""),
                            .cross("Store policy allowed no-receipt returns with an ID?", "\"For store credit, yes. The policy assumes you bought it.\""),
                            .cross("You never saw what was in the defendant's truck?", "\"No. I saw what came off our shelf.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Property crimes detective",
                        direct: ["\"Every card was sold within a day.\""],
                        cross: ["\"The earlier kit was real, and it was returned with its receipt.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the phone search show?", "\"A gift card resale app with six Tri-County cards sold for $1,226, each within a day of one of the returns.\""),
                            .direct("What about the receipt for the identical kit?", "\"It's genuine. But the store's records show that kit was returned with that same receipt three weeks before {DATE}, for cash.\""),
                            .cross("So my client really did buy a kit like this one?", "\"Yes. And returned it. There wasn't a kit left to swap.\""),
                            .cross("Selling a gift card isn't a crime?", "\"No. Getting it this way is.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's partner",
                        direct: ["\"{DL} goes through tools fast. That truck is full of them.\""],
                        cross: ["\"I don't know where every tool came from.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What does {DL} do for work?", "\"Handyman work. Decks, drywall, whatever people call about. {DL} is at that store all the time.\""),
                            .direct("Did {DL} have a combo kit in the truck that week?", "\"There was a kit in a torn box behind the seat. I saw it.\""),
                            .cross("Do you know where that kit came from?", "\"No. I assumed {DL} bought it.\""),
                            .cross("Did you know about the resale app?", "\"I knew {DL} sold some gift cards. I didn't ask where they came from.\"")
                        ])
        ],
        prosecutionTheory: ["{D} turned the store's return desk into an ATM: take it off the shelf, hand it over at the desk, sell the card."],
        defenseTheory: ["{DL} had bought this exact kit and was swapping a torn box for a clean one. It was a mistake about store policy, not a theft."],
        aggravating: ["Repeated over five weeks"],
        mitigating: ["No prior criminal record", "Working and supporting a household"],
        victimImpacts: [],
        allocutions: ["\"I needed the money and I told myself the store wouldn't miss it. I'll pay back every dollar.\""],
        guiltyTruths: ["A second phone in {DL}'s truck had notes listing which stores and which clerks didn't ask questions at the return desk."],
        innocentTruths: ["The cash return of the earlier kit was later traced to a desk associate who keyed refunds under customers' old receipts; {DL} still had that kit."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-35, "First no-receipt return on {DL}'s license."), (-21, "Earlier kit returned with its receipt for cash."), (-20, "First of the four returns still on video."),
                       (0, "Kit taken from aisle 14 and returned at 2:47 p.m.; {DL} stopped in the parking lot at 2:58 p.m."), (6, "Warrant search of {DL}'s phone."), (12, "Store return log and video turned over; {DL} charged, with an additional count.")],
            howIdentified: "The store's return system flagged {DL}'s driver's license; loss prevention watched on camera.",
            notDone: ["The first two returns were past the store's 30-day video retention before anyone flagged them."],
            defendantExam: [
                .direct("Why did you take the kit off the shelf?", "\"The one in my truck had a torn box. I grabbed a clean one to swap, figured it was the same thing.\""),
                .direct("Why did you take store credit?", "\"The desk offered it. I didn't think it through.\""),
                .cross("You'd already returned your kit, with its receipt, three weeks earlier.", "\"I bought more than one. I can't tell you which receipt was which.\""),
                .cross("Six earlier returns, six cards sold within a day.", "\"I sell gift cards. I need cash more than store credit.\""),
                .cross("Every one of those items came off a shelf on video.", "\"I know what the video shows.\"")
            ],
            prosecutionOpening: "Shelf, desk, card, sale. Seven times, on {DL}'s own license.",
            defenseOpening: "{DL} bought this kit. The question is whether a box swap at the return desk is a theft.",
            prosecutionClosing: "The receipt the defense showed you was already used. There was nothing left to swap.",
            defenseClosing: "Store policy invited this. The State has to prove {DL} knew it was stealing.",
            time: "2:47 p.m.",
            family: "Lives with a partner; no children."
        )
    )

    // MARK: - 150. Truck 214 (a county fuel card after midnight)

    static let fuelCard = CaseTemplate(
        key: "story.fuelCard", category: .whiteCollar,
        headlines: ["County Road Crew Leader Charged in Fuel Card Scheme", "38 Fill-Ups, Truck Parked: Audit Finds $3,960 in County Fuel"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Being an employee of Hollis County and entrusted with a county fleet fuel card, fraudulently converted to {D.his} own use $3,960 in fuel purchased with that card for {D.his} personal vehicle.",
        ageRange: 32...60, occupations: ["road crew leader"], hasVictim: false,
        summaries: [
            "{D}, a road maintenance crew leader with Hollis County Public Works for eleven years, was assigned fleet fuel card 214 and its personal PIN. A county audit found 38 fill-ups on that card over four months, totaling $3,960, made outside working hours while county truck 214 sat behind the locked gate of the county yard, according to the gate log and the truck's GPS. The last fill-up, at 11:52 p.m. on {DATE}, was recorded by a convenience store camera on {STREET}: {DL} pumping diesel into {D.his} personal red pickup. {DL} says a supervisor, since retired, told {D.him} to fuel {D.his} own truck on emergency callouts, and three of the 38 fill-ups fall on storm nights."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Fuel Card Report", "38 purchases on card 214 over four months, $3,960 total, all between 9 p.m. and 5 a.m. or on weekends, each with {DL}'s PIN."),
            E(.document, 3, "Gate Log and Truck GPS", "County truck 214 inside the locked yard during all 38 purchases."),
            E(.video, 3, "Store Camera", "At 11:52 p.m. on {DATE}, {DL} pumping diesel into a red personal pickup at the store on {STREET} and paying at the pump with a county fleet card."),
            E(.digital, 2, "Phone Location", "Records obtained by warrant put {DL}'s phone at or near the fuel stations for 35 of the 38 purchases.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Storm Callout Logs", "Three of the 38 purchases fall on nights {DL} was called out for downed trees during storms."),
            E(.document, 1, "Personnel File", "Eleven years with the county, no discipline, two safety awards.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "County internal auditor",
                        direct: ["\"The card was busy at midnight. The truck was locked up.\""],
                        cross: ["\"Three purchases match storm callouts.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the audit find?", "\"Thirty-eight purchases on card 214 in four months, $3,960, every one at night or on a weekend, every one with the PIN assigned to the defendant.\""),
                            .direct("Where was truck 214 during those purchases?", "\"Inside the yard. The gate log shows it never left, and the truck's GPS shows it parked.\""),
                            .direct("How much fuel does truck 214 normally use?", "\"About forty gallons a week on its daytime runs. Those purchases are on top of that.\""),
                            .cross("Three of those purchases fall on storm nights?", "\"Yes. Three. That leaves thirty-five.\""),
                            .cross("Is a written rule about callouts in personal vehicles in the policy?", "\"No written rule. The policy says county cards fuel county vehicles.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The video shows the defendant's own pickup.\""],
                        cross: ["\"I spoke to the retired supervisor.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the store video show?", "\"At 11:52 p.m. on {DATE}, the defendant fills a red pickup registered to the defendant with diesel and pays with a county fleet card.\""),
                            .direct("Was there a callout that night?", "\"No. No storm, no call, nothing in the dispatch log.\""),
                            .direct("What did the phone records show?", "\"The defendant's phone at or near the station for 35 of the 38 purchases.\""),
                            .cross("Did you interview the retired supervisor?", "\"Yes. The supervisor remembered allowing it once or twice during a hurricane, years ago. Not every weekend.\""),
                            .cross("So there was some permission, at some point?", "\"During a hurricane, years ago, according to the supervisor. Not for this.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Coworker on the road crew",
                        direct: ["\"Everybody knew the old supervisor let us fuel up on callouts.\""],
                        cross: ["\"I never filled my own truck on a Saturday.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did callouts work?", "\"Storm hits at night, you get a call, you go. Half the time you take your own truck because the yard's locked.\""),
                            .direct("Were you allowed to fuel your own truck on the county card?", "\"The old supervisor said it was fine on a callout. Everybody knew that.\""),
                            .cross("Was it ever in writing?", "\"No. It was just how it worked.\""),
                            .cross("Did you ever fill your own truck on a weekend with no callout?", "\"No. I wouldn't do that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} used the county's card to fuel {D.his} own truck for four months, at night, while the county truck sat locked in the yard."],
        defenseTheory: ["An unwritten callout practice, a supervisor who allowed it, and eleven clean years. This was a misunderstanding about a rule nobody wrote down."],
        aggravating: ["Abused a position of public trust"],
        mitigating: ["No prior criminal record", "Eleven years of public service"],
        victimImpacts: [],
        allocutions: ["\"I've plowed and cleared those roads for eleven years. I was wrong to use that card the way I did, and I'll pay it back.\""],
        guiltyTruths: ["{DL}'s neighbor later told the county {DL} had been selling diesel by the jug from a transfer tank in {D.his} driveway."],
        innocentTruths: ["A second worker who had watched {DL} enter the PIN at the pump had been using a cloned copy of card 214; the clone turned up in that worker's truck."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-120, "First after-hours purchase on card 214."), (0, "Last purchase, 11:52 p.m., on store video."), (9, "Audit flags card 214."),
                       (16, "Store video and phone location records obtained."), (21, "{DL} interviewed and placed on leave; charged."), (40, "{DL}'s employment ends.")],
            howIdentified: "A routine fuel audit matched card 214 to purchases made while truck 214 was locked in the yard.",
            notDone: [],
            defendantExam: [
                .direct("Who told you that you could fuel your own truck?", "\"My old supervisor. On callouts, if you used your own truck, you filled it on the county card.\""),
                .direct("Did you use your truck on callouts?", "\"Every storm. The yard's locked at night.\""),
                .cross("There was no callout on {DATE}.", "\"No. I'd run low from the week before.\""),
                .cross("Thirty-eight fill-ups and three storms.", "\"I got loose with it. I know that.\""),
                .cross("Your supervisor says it was a hurricane, years ago.", "\"It went on longer than that.\"")
            ],
            prosecutionOpening: "Thirty-eight fill-ups, one PIN, and a county truck that never left the yard.",
            defenseOpening: "The county let its crews fuel their own trucks on callouts. It never wrote down where that stopped.",
            prosecutionClosing: "Three storm nights don't explain thirty-five other ones.",
            defenseClosing: "Taking too much under an unwritten rule isn't the same as stealing.",
            time: "11:52 p.m.",
            employer: "Hollis County Public Works",
            employmentEnded: true,
            family: "Married, 2 children.",
            yearsAtJob: 11
        )
    )

    // MARK: - 151. The orange seat cover (a mower bought in a parking lot)

    static let zeroTurnMower = CaseTemplate(
        key: "story.zeroTurnMower", category: .property,
        headlines: ["Stolen Mower and Trailer Found in a Front Yard", "Landscaper Spots Stolen Mower Nine Days After Theft"],
        primaryLaw: "possStolen", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Possessed a zero-turn mower and 16-foot utility trailer, together valued at $11,400, belonging to {V}, knowing or having reasonable grounds to believe they had been stolen.",
        ageRange: 25...58, occupations: ["lawn care operator"], hasVictim: true,
        summaries: [
            "On the night of {DATE}, someone cut the chain on the gate of {V}'s landscaping shop lot in {HOOD} and drove off with a zero-turn mower worth $9,200 on a 16-foot trailer worth $2,200. Nine days later, {V} drove past a single-wide on {STREET} and saw the mower, with its custom orange seat cover and the company decal scraped off, parked in the yard of {D}. The serial number matched. {DL} told deputies {D.he} bought the mower and trailer together for $2,500 cash from a man in a shopping-center parking lot who answered a marketplace listing; the seller's account had been deleted. The State says the price, a trailer with no title, and the scraped decal gave {DL} every reason to know. {DL}'s phone puts {D.him} at home the night of the theft."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Serial Number", "The mower's frame serial number matches {VL}'s purchase invoice; the trailer's VIN plate matches {VL}'s registration."),
            E(.digital, 3, "Marketplace Messages", "{DL}'s messages with the seller, from {DL}'s phone: \"you got a title for the trailer?\" / \"lost it, I'll write you a bill of sale.\" No bill of sale was ever given.", .search),
            E(.document, 2, "Value Records", "{VL}'s invoices: mower $9,200, bought eleven months earlier; trailer $2,200."),
            E(.physical, 2, "Scraped Decal", "Fresh scrape marks where {VL}'s company decal had been on the mower's side panel.")
        ],
        defenseEvidence: [
            E(.digital, 3, "Marketplace Listing", "A screenshot of the listing, \"mower and trailer, moving, must sell,\" $3,000, posted two days after the theft."),
            E(.digital, 2, "Phone Location", "{DL}'s phone at {D.his} home all night on {DATE}, by records the State obtained by warrant."),
            E(.document, 1, "Bank Withdrawal", "A $2,500 cash withdrawal from {DL}'s account an hour before the meeting.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Owner of the mower",
                        direct: ["\"I'd know that seat cover anywhere. My kid sewed it.\""],
                        cross: ["\"I don't know who scraped the decal.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What was taken from your lot?", "\"My big mower and the trailer it rides on. Eleven months old. Somebody cut the chain on the gate that night.\""),
                            .direct("How did you find it?", "\"Nine days later I was driving past a place on {STREET} and there it was in the yard. Orange seat cover. My kid sewed that cover. I nearly drove into the ditch.\""),
                            .direct("What did losing it cost you?", "\"I had to rent one for two weeks and turn down three jobs. That mower is half my business.\""),
                            .cross("You don't know who stole it?", "\"No. I know where it ended up.\""),
                            .cross("You don't know when the decal was scraped?", "\"It was on there when it left my lot. That's what I know.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"No title, no bill of sale, a fourth of the price.\""],
                        cross: ["\"Your client's phone was home the night of the theft.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the defendant tell you?", "\"That {D.he} bought both for $2,500 cash in a shopping-center parking lot from a man who answered a marketplace listing.\""),
                            .direct("What did you find on the defendant's phone?", "\"The messages. The defendant asked about a title for the trailer. The seller said it was lost and promised a bill of sale. None was ever written.\""),
                            .direct("Did you look for the seller?", "\"The account was made two days before the listing and deleted the day after the sale. It was registered to a prepaid phone that's since been shut off.\""),
                            .cross("The phone records show my client at home the night of the theft?", "\"Yes. We're not saying the defendant cut the chain.\""),
                            .cross("Was the decal already scraped when my client bought it?", "\"I can't say when it was scraped. The marks were fresh.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's brother-in-law",
                        direct: ["\"It looked like a guy who needed money fast.\""],
                        cross: ["\"I didn't look at the side panel.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why were you at the parking lot?", "\"I went along to help load it. You don't go buy something off the internet alone.\""),
                            .direct("What did the seller say?", "\"Said he was moving out of state and needed it gone that day. That's why it was cheap.\""),
                            .cross("Did you ask for a title or a bill of sale?", "\"{DL} asked about the title. The guy said he'd mail a bill of sale.\""),
                            .cross("Did you notice the decal was scraped off?", "\"I was looking at the hitch and the tires. I didn't look at the side panel.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew mowers. A nearly new commercial mower and trailer for $2,500, no title, no paperwork, the company name scraped off. That's a stolen mower, and {DL} knew it."],
        defenseTheory: ["{DL} answered a public listing, paid with money from the bank, and parked the mower in plain view of the road. Thieves don't do that."],
        aggravating: ["Property was worth more than $10,000"],
        mitigating: ["No prior criminal record", "Was not the thief"],
        victimImpacts: ["{V}: \"I built that business one yard at a time. Every time I see a trailer go by now I look at the plate.\""],
        allocutions: ["\"I thought I got a good deal. I should have asked more questions, and I'm sorry for what {VL} went through.\""],
        guiltyTruths: ["The seller, later arrested for a string of equipment thefts, said {DL} had asked him whether the mower was 'hot' and laughed when told not to worry."],
        innocentTruths: ["The seller, later arrested for a string of equipment thefts, said he scraped the decal himself after the sale photos and told every buyer he was moving."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Gate chain cut; mower and trailer taken from {VL}'s lot overnight."), (2, "Marketplace listing posted."), (4, "{DL} buys the mower and trailer in a shopping-center parking lot for $2,500."),
                       (5, "Seller's account deleted."), (9, "{VL} spots the mower in {DL}'s yard; deputies confirm the serial number."), (14, "{DL}'s phone searched by warrant; charged.")],
            howIdentified: "{VL} recognized the mower in {DL}'s yard; the serial number matched.",
            notDone: ["The seller's marketplace account was deleted before the subpoena reached the company; its records came back empty."],
            defendantExam: [
                .direct("Why did you buy it?", "\"I mow yards on the side. A commercial mower for that price was a chance to take on bigger jobs.\""),
                .direct("Did you think it was stolen?", "\"No. He said he was moving. He had the key, he knew how it ran.\""),
                .cross("You know what a mower like that costs new.", "\"I know. I figured he was desperate.\""),
                .cross("No title for the trailer, no bill of sale.", "\"I asked. He said he'd mail it. I should have walked away.\""),
                .cross("The decal was scraped off.", "\"I didn't notice it till later. Used equipment gets scraped.\"")
            ],
            prosecutionOpening: "A $11,400 rig for $2,500, no title and no name on it. {DL} knew.",
            defenseOpening: "{DL} bought a mower off a public listing and parked it where the whole road could see it.",
            prosecutionClosing: "Reasonable grounds to believe. Every fact you heard gave {DL} grounds.",
            defenseClosing: "A good deal isn't a crime. The State has to prove what {DL} knew, not what {DL} should have asked.",
            victim: VictimFacts(occupation: "Landscaping business owner", relationship: "Strangers.", restitution: 0),
            family: "Married, 1 child.",
            residence: "A single-wide on {STREET}"
        )
    )

    // MARK: - 152. Round marks (a hail claim and a hammer)

    static let hailClaim = CaseTemplate(
        key: "story.hailClaim", category: .whiteCollar,
        headlines: ["Homeowner Charged After Hail Claim: Insurer Says Damage Was Hammered", "Neighbor Saw Homeowner on Roof With Hammer After Storm"],
        primaryLaw: "insuranceFraud", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "With intent to defraud, presented a claim to {D.his} homeowner's insurer for $23,600 to replace {D.his} roof, knowing the claim contained false information about hail damage that {D.he} had caused.",
        ageRange: 30...62, occupations: ["warehouse supervisor"], hasVictim: false,
        summaries: [
            "A hailstorm crossed {HOOD} on {DATE}. Three days later, {D} filed a claim for $23,600 to replace the roof of {D.his} house on {STREET}. The insurer's adjuster found 46 round marks on the shingles, nearly all the same size, many cut through the mat, and almost none on the north slope where the storm came from. An engineer hired by the insurer says the marks match a ball-peen hammer. The National Weather Service logged pea- to nickel-sized hail in {HOOD} that night, and two neighbors' minor claims were paid. A neighbor saw {DL} on the roof with a hammer two days after the storm. {DL} says {D.he} was nailing down a lifted ridge cap, and that a twenty-year-old roof bruises easily."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Adjuster's Report", "46 round marks, 1 to 1.1 inches across, on the south and west slopes; two on the north slope. 31 cut through the shingle mat."),
            E(.document, 3, "Engineer's Report", "Uniform size, crisp edges and mat fractures consistent with a ball-peen hammer; hail of the size recorded that night would leave smaller, softer bruises spread across all slopes."),
            E(.document, 2, "Weather Service Log", "Pea- to nickel-sized hail (up to 0.88 inches) reported in {HOOD} on {DATE}, wind from the north-northwest."),
            E(.digital, 2, "Phone Search", "{DL}'s phone, searched by warrant: the day after the storm, searches for \"how big hail to total roof\" and \"insurance roof replacement hail how much damage needed.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Neighbors' Claims", "Two homes on {STREET} were paid for hail damage from the same storm: $2,100 and $3,400."),
            E(.document, 2, "Roofer's Inspection", "A roofer {DL} called before filing found hail damage and recommended replacement; the roofer is not related to {DL}."),
            E(.physical, 1, "Ridge Cap Nails", "New roofing nails along the ridge cap, matching {DL}'s account of repairing it.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic engineer",
                        direct: ["\"Hail doesn't pick one size and avoid the side it came from.\""],
                        cross: ["\"Older shingles do bruise more easily.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find on the roof?", "\"Forty-six round marks, all about an inch across, almost all on the south and west slopes. Thirty-one cracked through the mat.\""),
                            .direct("Why does that matter?", "\"The storm came from the north-northwest with hail under an inch. That leaves smaller, softer bruises, most of them on the north side. These are the opposite.\""),
                            .direct("What made the marks, in your opinion?", "\"A ball-peen hammer, or something with the same round face. The edges are crisp and the size barely varies.\""),
                            .cross("A twenty-year-old roof bruises more easily than a new one?", "\"It does. It doesn't change where the hail came from or how big it was.\""),
                            .cross("You were paid by the insurer?", "\"I'm paid for my time, the same whatever I find.\"")
                        ]),
            WitnessSeed(name: nil, role: "Next-door neighbor",
                        direct: ["\"I saw {DL} up there with a hammer that Sunday.\""],
                        cross: ["\"I couldn't see what {DL} was hitting.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see two days after the storm?", "\"{DL} up on the roof in the afternoon with a hammer. Banging for maybe twenty minutes.\""),
                            .direct("Where on the roof?", "\"The back side, facing my yard. That's the south side.\""),
                            .cross("Could you see what {DL} was hitting?", "\"No. Just the hammer going up and down.\""),
                            .cross("You've had a dispute with my client over a fence?", "\"We had words about the fence two years ago. That's settled.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Insurance fraud investigator, Department of Insurance",
                        direct: ["\"The searches came the morning after the storm.\""],
                        cross: ["\"Anybody might search that after a hailstorm.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the phone search show?", "\"The morning after the storm, searches for how big hail has to be to total a roof, and how much damage the insurer needs to see.\""),
                            .direct("When was the claim filed?", "\"Three days after the storm. The day after the neighbor saw the hammer.\""),
                            .cross("A homeowner after a hailstorm might search those things honestly?", "\"Some would. Most search for a roofer.\""),
                            .cross("Two neighbors were paid for hail damage from this storm?", "\"Small claims. Bruising. Not forty-six one-inch fractures.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Roofing contractor",
                        direct: ["\"I've seen nickel hail break old shingles plenty of times.\""],
                        cross: ["\"I'd have written the estimate either way.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you see on the roof?", "\"Hail hits on a tired roof. Granule loss, cracks. I recommended replacement.\""),
                            .direct("Can nickel-sized hail crack a twenty-year-old shingle?", "\"Absolutely. Once the shingle dries out, it's brittle.\""),
                            .cross("Did you notice the marks were almost all on the south and west slopes?", "\"Wind swirls. I didn't measure them.\""),
                            .cross("You'd have gotten the replacement job?", "\"If the claim paid, yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} read up on what it takes to total a roof, climbed up with a hammer, and filed a $23,600 claim the next day."],
        defenseTheory: ["A real storm, paid claims next door, a roofer who saw hail damage, and a neighbor with a grudge who saw someone fix a ridge cap."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The claim was never paid"],
        victimImpacts: [],
        allocutions: ["\"That roof leaked for years. I wanted it fixed. I'm asking the court to remember the claim was never paid.\""],
        guiltyTruths: ["A ball-peen hammer with shingle granules packed in its face was found in {DL}'s garage after the trial, during an unrelated repair."],
        innocentTruths: ["A storm spotter's photos later showed hailstones over an inch wide falling on {STREET} that night, larger than the official log."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(0, "Hailstorm crosses {HOOD} at night."), (1, "Searches on {DL}'s phone about hail size and roof replacement; roofer inspects."), (2, "Neighbor sees {DL} on the roof with a hammer."),
                       (3, "{DL} files a $23,600 claim."), (12, "Adjuster's inspection."), (30, "Engineer's report; claim referred to the Department of Insurance."), (55, "Phone searched by warrant; {DL} charged.")],
            howIdentified: "The insurer's adjuster and engineer flagged the damage pattern and referred the claim.",
            notDone: ["No one checked {DL}'s tools for granule residue."],
            defendantExam: [
                .direct("Why were you on the roof with a hammer?", "\"The ridge cap lifted in the wind. I nailed it down so it wouldn't leak before the roofer came back.\""),
                .direct("Did you hit the shingles with that hammer?", "\"No. Just the ridge nails.\""),
                .cross("The roofer came the day before, and you were on the south slope, not the ridge.", "\"You have to walk the slope to get to the ridge.\""),
                .cross("You searched how much damage it takes to total a roof.", "\"I wanted to know if it was worth filing. Everybody looks that up.\""),
                .cross("Forty-six one-inch marks, from hail under an inch.", "\"I don't know how hail works. I know it hit my house.\"")
            ],
            prosecutionOpening: "Hail doesn't read the internet, and it doesn't come in one size.",
            defenseOpening: "There was a storm. The neighbors got paid. {DL} is the one with the fence dispute.",
            prosecutionClosing: "The searches, the hammer, the pattern. Each one alone might be chance. Together they're a plan.",
            defenseClosing: "Experts disagree about hail. When they do, there's reasonable doubt.",
            family: "Married, 3 children.",
            residence: "Owns a house on {STREET}"
        )
    )

    // MARK: - 153. Sixty percent (a consignment shop that closed)

    static let consignmentShop = CaseTemplate(
        key: "story.consignmentShop", category: .whiteCollar,
        headlines: ["Consignment Shop Owner Charged After Store Closes Owing $11,300", "Consignors Say They Were Never Paid for Sold Goods"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Having been entrusted as consignee with a dining set and a fur coat belonging to {V}, sold them and fraudulently converted to {D.his} own use $2,850 due to {V}.",
        ageRange: 34...65, occupations: ["shop owner"], hasVictim: true,
        summaries: [
            "{D} owned Second Act Consignment in {HOOD} for six years. Consignors were to be paid 60 percent of the sale price within 30 days. When the shop closed on {DATE}, 23 consignors were owed $11,300. {V}, a retired school librarian, had consigned a cherry dining set and a fur coat that sold for $4,750 in the shop's last two months; {VL}'s share, $2,850, was never paid. Bank records show the sale money went into the shop's operating account and out to rent, utilities and a part-time clerk, and that {DL} had drawn no pay for three months, then took a $4,000 check to {D.himself} in the last week. {DL} kept accepting new consignments after the landlord's eviction notice. {DL} says the shop simply ran out of money and that {D.he} has repaid four consignors in part."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Consignment Agreement", "{VL}'s signed agreement: 60 percent to the consignor, paid within 30 days of sale."),
            E(.document, 3, "Sales Records", "The dining set sold for $3,400 and the fur coat for $1,350, both within the shop's last two months. {VL}'s 60 percent: $2,850."),
            E(.document, 3, "Bank Records", "A $4,000 check from the shop account to {DL} six days before closing, labeled \"back pay.\"", .search),
            E(.document, 2, "Eviction Notice", "Served three weeks before the shop closed; nine new consignments were accepted after it.")
        ],
        defenseEvidence: [
            E(.document, 3, "Operating Account", "Every sale deposit went into the shop account; withdrawals were rent, utilities, the clerk's pay and suppliers, with no personal spending until the $4,000 check."),
            E(.document, 2, "Partial Repayments", "Checks from {DL}'s personal account to four consignors after closing, $1,900 in all."),
            E(.document, 1, "Payroll Gap", "{DL} drew no pay for the three months before the $4,000 check.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Consignor",
                        direct: ["\"That coat was my mother's. I trusted that shop with it.\""],
                        cross: ["\"I knew the shop was struggling. Everybody did.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you consign?", "\"My mother's cherry dining table and chairs, and her fur coat. I was downsizing. I couldn't keep them, and I couldn't give them away.\""),
                            .direct("What happened when they sold?", "\"I saw the table was gone and went in to ask about my check. I was told next week. Then next week again.\""),
                            .direct("How did you find out the shop closed?", "\"A paper sign on the door. I stood on the sidewalk and cried.\""),
                            .cross("You knew the shop was struggling?", "\"Everybody could see that. That's not the same as keeping my money.\""),
                            .cross("You're owed $2,850 and nobody's said you'll never be paid?", "\"Nobody's said anything. That's the problem.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"The last check out of that account went to the defendant.\""],
                        cross: ["\"I found no vacations, no cars, nothing personal before that check.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where did {VL}'s money go?", "\"Into the shop's one bank account, mixed with everything else. Out again to rent, power, the clerk, suppliers.\""),
                            .direct("What happened the last week?", "\"With 23 consignors owed $11,300, the defendant wrote a $4,000 check to the defendant, marked back pay.\""),
                            .direct("And new consignments?", "\"Nine new ones after the eviction notice. People dropping off things with a shop that knew it was closing.\""),
                            .cross("Before that check, did you find any personal spending?", "\"No. No trips, no cars. The money went to keeping the doors open.\""),
                            .cross("My client had drawn nothing for three months?", "\"That's right. Then took $4,000 in the last week.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Shop's part-time clerk",
                        direct: ["\"{DL} kept saying everybody would get paid.\""],
                        cross: ["\"I knew about the eviction notice.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was the shop like in the last months?", "\"Slow. {DL} cut my hours, then stopped taking a paycheck so I could keep mine.\""),
                            .direct("What did {DL} say about the consignors?", "\"That everybody would get paid once the holiday sales came. {DL} kept a list on the counter of who was owed.\""),
                            .cross("You knew the shop had an eviction notice?", "\"I knew. {DL} thought the landlord would work something out.\""),
                            .cross("You kept taking in new consignments after that?", "\"Yes. {DL} told me to.\"")
                        ])
        ],
        prosecutionTheory: ["{D} held {VL}'s money in trust, spent it on the shop, took out pay for {D.himself} on the way out, and kept taking new goods while {D.he} knew the doors were closing."],
        defenseTheory: ["A small business failed. The money went where the shop's money always went, and {DL} has been paying people back from {D.his} own pocket. That is a debt, not a crime."],
        aggravating: ["Took advantage of a position of trust"],
        mitigating: ["No prior criminal record", "Made partial restitution to other consignors", "No personal spending of the funds"],
        victimImpacts: ["{V}: \"I didn't care about the money as much as I cared that my mother's things went out the door and I got nothing but a paper sign.\""],
        allocutions: ["\"I put everything I had into that shop and it still wasn't enough. I owe {VL} that money, and I'm going to pay it.\""],
        guiltyTruths: ["The $4,000 check was deposited and spent the same day on a deposit for a new storefront in another county, under a different name."],
        innocentTruths: ["The $4,000 went straight to the shop's final power bill and a supplier; {DL}'s personal account never saw it."],
        moods: [.sympathetic], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-60, "{VL}'s dining set sells."), (-35, "{VL}'s fur coat sells."), (-21, "Eviction notice served."), (-6, "$4,000 check to {DL}, marked back pay."),
                       (0, "Shop closes; sign posted on the door."), (30, "Consignors complain to the Sheriff's Office."), (75, "Bank records subpoenaed; {DL} charged.")],
            howIdentified: "Complaints from consignors after the shop closed.",
            notDone: [],
            defendantExam: [
                .direct("Did you intend to keep {VL}'s money?", "\"No. I intended to pay everybody. The money ran out before the sales came.\""),
                .direct("Why the $4,000 check?", "\"Three months without pay. I had my own rent.\""),
                .cross("You paid yourself before you paid {VL}.", "\"I know how that looks. It was owed to me too.\""),
                .cross("You took nine new consignments after the eviction notice.", "\"I thought the landlord would give me more time. I was wrong.\""),
                .cross("{VL}'s share was {VL}'s, not the shop's.", "\"It went in the same account as everything else. I never thought of it as separate.\"")
            ],
            prosecutionOpening: "{VL}'s money was never {DL}'s to spend. And in the last week, {DL} paid {D.himself} first.",
            defenseOpening: "This is a story about a failing shop, not a theft.",
            prosecutionClosing: "Owing money is a debt. Paying yourself with someone else's money is embezzlement.",
            defenseClosing: "Fraudulent intent is the line. A shopkeeper who stops taking pay to keep the doors open hasn't crossed it.",
            victim: VictimFacts(age: 68, occupation: "Retired school librarian", relationship: "Consignor at the defendant's shop.", harm: ["Lost $2,850 and family heirlooms"]),
            employer: "Second Act Consignment",
            employmentEnded: true,
            family: "Divorced, 1 adult child.",
            yearsAtJob: 6
        )
    )
}
