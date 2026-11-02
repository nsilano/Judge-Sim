import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAK: [CaseTemplate] = [marketplaceTrailer, auntPowerOfAttorney, golfCartDeath, birthdayParty, deadBrotherIdentity]

    // MARK: - The Marketplace trailer

    static let marketplaceTrailer = CaseTemplate(
        key: "story.marketplaceTrailer", category: .property,
        headlines: ["Landscaper's Stolen Trailer and Mowers Found for Sale Online", "Seller Says He Bought Stolen Equipment Fair and Square"],
        primaryLaw: "possStolen", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Possessed a landscaping trailer and two zero-turn mowers valued at $21,500, the property of {V}, knowing and having reasonable grounds to believe them stolen, on {DATE}.",
        ageRange: 22...55, occupations: ["small engine mechanic", "used equipment dealer", "lawn care operator"], hasVictim: true,
        summaries: [
            "{V}'s enclosed landscaping trailer, with two zero-turn mowers inside, was taken from the lot behind {V.his} business in {HOOD} over a weekend. Nine days later {V}'s office manager found the mowers listed on Facebook Marketplace at $3,200 each, about a third of their value, by {D}. When a deputy posing as a buyer met {D} at {D.his} shop, the trailer was out back with {V}'s company decals scraped off and the mowers' serial plates ground smooth. {DL} says {D.he} bought everything for $4,000 cash from a man who said he was closing his business, and that {D.he} grinds plates off all the used equipment {D.he} rebuilds."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Marketplace Listings", "Two zero-turn mowers at $3,200 each, posted by {DL}'s account four days after the theft; the photos show {V}'s mower deck stickers."),
            E(.physical, 3, "Ground Serial Plates", "Both mowers' serial plates ground smooth; a hidden frame number on one matches {V}'s purchase records.", .search),
            E(.document, 2, "Value", "Trailer $7,500; two mowers $14,000 new two years ago.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Cash Purchase", "{DL} says {D.he} paid $4,000 cash in a gas station parking lot to a man who called himself \"Ricky.\""),
            E(.document, 1, "Shop Records", "{DL}'s shop rebuilds and resells about forty used mowers a year.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Landscaping business owner",
                        direct: ["\"Those are my mowers. My stickers are on the deck.\""],
                        cross: ["\"I didn't see who took them.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How do you know they're yours?", "\"My company sticker on the deck, a cracked seat I taped myself, and a frame number they missed.\""),
                            .direct("What did the theft cost you?", "\"Two crews idle for a week in May. I lost three accounts.\""),
                            .cross("You didn't see who took them.", "\"No. I saw who was selling them.\""),
                            .cross("Equipment gets resold all the time.", "\"Not with the plates ground off.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's property crimes detective",
                        direct: ["\"The prices were a third of what they're worth.\""],
                        cross: ["\"We never found 'Ricky.'\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find at the shop?", "\"The trailer out back with the decals scraped off, both mowers inside with the serial plates ground smooth.\""),
                            .direct("What did {DL} say?", "\"That {D.he} bought them from a guy named Ricky. No last name, no phone number, no paperwork.\""),
                            .direct("What should a dealer do?", "\"Get a bill of sale and an ID, and run the serials. It takes five minutes.\""),
                            .cross("Did you look for Ricky?", "\"There was nothing to look with.\""),
                            .cross("Grinding plates is common in rebuild shops.", "\"Not that I've ever heard.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Small engine mechanic",
                        direct: ["\"Rebuilt units get new plates sometimes.\""],
                        cross: ["\"You'd keep the old number.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Do shops ever grind serial plates?", "\"When you swap a deck or a frame, sometimes the old plate comes off.\""),
                            .direct("Is $4,000 for a trailer and two mowers believable?", "\"For a guy dumping a business fast, maybe.\""),
                            .cross("Would you record the old serial number?", "\"Yes. For warranty, for the buyer.\""),
                            .cross("Would you buy $21,000 of equipment from a stranger with no paperwork?", "\"No, I wouldn't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} bought a trailer full of equipment for a fifth of its value from a man with no name, ground off the serial plates, and listed it four days later. {D.He} knew."],
        defenseTheory: ["{D} made a bad deal in a gas station lot. Knowing something is stolen is the whole case, and the State has no proof {D.he} knew."],
        aggravating: ["The offense was committed for pecuniary gain"],
        mitigating: ["The defendant has made substantial or full restitution", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: ["\"I built that business mowing yards out of my truck bed. Losing two crews in May nearly put me under.\""],
        allocutions: ["\"I should've asked for paperwork. I'll make {V} whole.\"", "\"I knew it was too cheap. I didn't want to ask.\""],
        guiltyTruths: ["{DL}'s phone held a text from the seller the night of the theft: \"got 2 more zero turns, same deal as last time.\""],
        innocentTruths: ["The man called Ricky was arrested months later with a storage unit full of stolen mowers and named eleven buyers, none of whom he'd told the truth."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(-9, "Weekend: trailer and mowers taken from {V}'s lot."), (-5, "{DL} posts the mowers on Marketplace."), (0, "{V}'s office manager finds the listing; a deputy arranges a meeting."), (0, "Afternoon: trailer and mowers found at {DL}'s shop.")],
            howIdentified: "The Marketplace listing and a deputy posing as a buyer.",
            notDone: ["No one checked the gas station's camera for the cash sale.", "{DL}'s other used equipment was never checked for stolen serials."],
            defendantExam: [
                .direct("Where did you get the equipment?", "\"A man named Ricky said he was closing his lawn business and needed cash that day.\""),
                .direct("Why grind the plates?", "\"I rebuild everything I sell. I always do that.\"", "\"So nobody could trace them back. I knew they were hot.\""),
                .cross("$4,000 for $21,000 of equipment.", "\"People in a hurry take less.\""),
                .cross("No name, no phone number, no receipt.", "\"It was cash.\""),
                .cross("You scraped the company decals off the trailer.", "\"I was going to repaint it.\"")
            ],
            prosecutionOpening: "A fifth of the price, a man with no last name, and serial plates ground smooth.",
            defenseOpening: "A bad bargain isn't a crime unless {DL} knew.",
            prosecutionClosing: "Nobody grinds plates on equipment they think is clean.",
            defenseClosing: "The State has to prove {DL} knew. A cheap price isn't knowledge.",
            when: .months([4, 5, 6, 7, 8]),
            victim: VictimFacts(age: 41, occupation: "landscaping business owner", relationship: "None", harm: ["Lost three accounts during the week without equipment"], restitution: 2800, restitutionBasis: "a week of lost work and repairs to the mowers"),
            family: "Married; two children.",
            residence: "A house behind {D.his} small engine shop in {HOOD}"
        )
    )

    // MARK: - Aunt Ruth's power of attorney

    static let auntPowerOfAttorney = CaseTemplate(
        key: "story.auntPowerOfAttorney", category: .whiteCollar,
        headlines: ["Nephew With Power of Attorney Charged in Aunt's Lost Savings", "$140,000 Gone From 88-Year-Old's Accounts, Deputies Say"],
        primaryLaw: "exploitationElder", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Being in a position of trust and confidence with {V}, an older adult, knowingly by deception used {V}'s funds for {D.his} own benefit, $140,600, between March and {DATE}.",
        ageRange: 35...62, occupations: ["car salesman", "real estate agent", "retired Army sergeant", "restaurant manager"], hasVictim: true,
        summaries: [
            "{V}, 88, signed a power of attorney naming {V.his} nephew {D} after a fall two years ago. Over the next nineteen months, $140,600 left {V}'s savings: $62,000 for a pickup truck titled to {D}, $38,000 in transfers to {D}'s account marked \"caregiving,\" and the rest in cash withdrawals. {V}'s nursing home bill went unpaid for five months, and the home moved to discharge {V}. {DL} says {V} wanted {D.him} to have the truck as thanks for taking care of {V.him}, that the caregiving payments were what any aide would charge, and that {D.his} aunt's mind was sharp when {V.he} said so. {V} now has moderate dementia and doesn't remember."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Records", "$140,600 out over nineteen months: a $62,000 truck dealer check, $38,000 in transfers to {DL}, and $40,600 in ATM and teller cash."),
            E(.document, 3, "Nursing Home Ledger", "Five months unpaid, $31,000; a discharge notice for nonpayment."),
            E(.document, 2, "Power of Attorney", "The form forbids gifts to the agent unless written into the document. None were.")
        ],
        defenseEvidence: [
            E(.document, 2, "Caregiving Log", "{DL}'s calendar of visits, doctor runs, and nights at {V}'s house before the nursing home."),
            E(.statement, 2, "Neighbor's Account", "A neighbor heard {V} say, before the dementia, \"that boy deserves a new truck for all he does.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Adult Protective Services social worker",
                        direct: ["\"The money went everywhere except {V}'s care.\""],
                        cross: ["\"{DL} did visit often.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did the case come to you?", "\"The nursing home's business office called. Five months unpaid, and the agent wasn't returning calls.\""),
                            .direct("What did the records show?", "\"A new truck in {DL}'s name, transfers labeled caregiving, and cash withdrawals at casinos and bars.\""),
                            .direct("Can an agent pay himself for care?", "\"Only if the document allows it, or a court approves. This one didn't.\""),
                            .cross("{DL} drove {V} to every doctor's appointment.", "\"The records show that, yes.\""),
                            .cross("{V} could have made a gift before the dementia.", "\"A gift through a power of attorney has to be in the document.\"")
                        ]),
            WitnessSeed(name: nil, role: "Nursing home business manager",
                        direct: ["\"We sent eleven letters.\""],
                        cross: ["\"{DL} paid for the first year.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened with the bill?", "\"Paid for twelve months, then nothing. I sent eleven letters and called every week.\""),
                            .direct("What did {DL} say?", "\"That the money was tied up. Then {D.he} stopped answering.\""),
                            .cross("{DL} visited {V} every Sunday.", "\"Most Sundays, yes.\""),
                            .cross("Medicaid applications take time.", "\"{DL} never filed one.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{V}'s neighbor",
                        direct: ["\"{V} said that boy deserved a truck.\""],
                        cross: ["\"I don't know about the bank.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear {V} say?", "\"On {V.his} porch, before the fall got bad: 'That boy deserves a new truck for all he does for me.'\""),
                            .direct("Did {DL} care for {V}?", "\"Every day for a year before the home. Groceries, pills, rides.\""),
                            .cross("Did {V} say $62,000?", "\"{V.He} didn't say a number.\""),
                            .cross("Did you know the nursing home bill wasn't paid?", "\"No. That's not right.\"")
                        ])
        ],
        prosecutionTheory: ["{D} used {V.his} aunt's power of attorney like a checkbook: a truck, paychecks to {D.himself}, and cash, while {V} faced eviction from {V.his} nursing home."],
        defenseTheory: ["{D} gave up two years caring for {V} and took what {V} wanted {D.him} to have. Mistakes with a power of attorney aren't deception."],
        aggravating: ["The victim was very old", "The defendant took advantage of a position of trust or confidence", "The offense involved an actual loss of more than $50,000"],
        mitigating: ["The defendant has made substantial or full restitution", "The defendant has a support system in the community"],
        victimImpacts: ["{V}'s daughter reads: \"Mama worked forty years at the hosiery mill and saved every penny so she'd never be a burden. She almost ended up in a hallway with her suitcase.\""],
        allocutions: ["\"I took care of her when nobody else would. She wanted me to have that truck.\"", "\"I lost control of it. The casino got the rest. I'm so sorry, Aunt {VF}.\""],
        guiltyTruths: ["{DL}'s ex-wife produced a text from {D.him}: \"Aunt won't remember, she can't even remember my name half the time.\""],
        innocentTruths: ["A note in {V}'s handwriting, found in a hymnal after trial, said, \"Buy that boy his truck. He's my right hand.\""],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "victimRights"],
        story: StoryExtras(
            timeline: [(-730, "{V} falls and signs a power of attorney naming {DL}."), (-570, "Truck bought with a check from {V}'s account."), (-150, "Nursing home payments stop."), (-30, "Discharge notice; nursing home calls Adult Protective Services."), (0, "Last cash withdrawal on {V}'s account.")],
            howIdentified: "The nursing home's report to Adult Protective Services.",
            notDone: ["No one asked {V}'s doctors when the dementia began.", "{V}'s papers at home were never searched for written wishes."],
            defendantExam: [
                .direct("Why did you buy the truck?", "\"Aunt {VF} told me to. She said I'd earned it.\""),
                .direct("Why did the nursing home bill go unpaid?", "\"I thought the money would last longer. I was going to fix it.\""),
                .cross("Cash withdrawals at a casino in Cherokee.", "\"Some of that was mine.\"", "\"I'm not going to lie. I gambled some of it.\""),
                .cross("The power of attorney says no gifts to yourself.", "\"I never read the whole thing.\""),
                .cross("Your aunt was nearly put out of her nursing home.", "\"I'd never have let that happen.\"")
            ],
            prosecutionOpening: "An 88-year-old's life savings, a truck in her nephew's name, and a discharge notice.",
            defenseOpening: "Two years of caregiving, and an aunt who wanted to say thank you.",
            prosecutionClosing: "A power of attorney is a trust, not a gift card.",
            defenseClosing: "{V} wanted {DL} to have that truck. Mistakes aren't deception.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(age: 88, occupation: "retired hosiery mill worker", relationship: "The defendant's aunt", family: "Widowed; one daughter in another state", harm: ["$140,600 of life savings lost", "Nearly discharged from the nursing home for nonpayment"], restitution: 140600, restitutionBasis: "the money taken from the aunt's accounts"),
            family: "Divorced; one grown son.",
            residence: "A rental house in {HOOD}"
        )
    )

    // MARK: - The golf cart on Ocean Drive

    static let golfCartDeath = CaseTemplate(
        key: "story.golfCartDeath", category: .traffic,
        headlines: ["Woman Killed When Golf Cart Overturns on Beach Road", "Golf Cart Driver Charged With Felony Death by Vehicle"],
        primaryLaw: "felonyDBV", lesserLaw: "misdDBV", threshold: 7, lesserThreshold: 5,
        specification: "Unlawfully and unintentionally caused the death of {V} while driving a street-legal golf cart while impaired, on {DATE}.",
        ageRange: 24...60, occupations: ["dentist", "pharmaceutical sales rep", "real estate broker", "athletic director"], hasVictim: true,
        summaries: [
            "Around 11:30 p.m. on {DATE}, {D} was driving a rented street-legal golf cart on Ocean Drive in Port Hollis after a beach bar's karaoke night, with {V}, a friend from home, in the passenger seat. Taking the turn onto a side street at speed, the cart rolled. {V}, who wasn't wearing the lap belt, was thrown onto the pavement and died of a head injury. {DL}'s blood alcohol concentration was 0.11 two hours later. {DL} says {D.he} had three beers over four hours, that the cart's brakes grabbed and pulled left on the turn, and that the rental company had a complaint about the same cart the week before."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Blood Test", "BAC 0.11 from a blood draw at 1:35 a.m., two hours after the crash."),
            E(.document, 3, "Crash Reconstruction", "The cart was going about 22 mph into a 90-degree turn; the cart's limit is 20 mph and the posted speed 25."),
            E(.statement, 2, "Bar Tab", "Five beers and two shots on {DL}'s card between 7:15 and 11:10 p.m.")
        ],
        defenseEvidence: [
            E(.document, 2, "Rental Complaint", "A renter wrote the week before: \"brakes grab and pull hard left.\""),
            E(.document, 1, "Maintenance Log", "No brake service recorded on the cart in eleven months.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Highway Patrol crash reconstructionist",
                        direct: ["\"Too fast for that turn, with a driver over the limit.\""],
                        cross: ["\"I couldn't test the brakes after the crash.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How fast was the cart going?", "\"About 22 miles an hour, near its top speed, into a 90-degree turn. A golf cart has a high center of gravity and no roll protection.\""),
                            .direct("What about the brakes?", "\"The skid marks are even on both rear tires. I don't see a pull.\""),
                            .direct("Could a sober driver have made that turn at that speed?", "\"Not safely. A sober driver slows down for it.\""),
                            .cross("You couldn't test the brake system.", "\"The front end was crushed. No.\""),
                            .cross("The rental company had a brake complaint.", "\"I learned that later. The marks don't show it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Bartender",
                        direct: ["\"{DL} closed out after two shots.\""],
                        cross: ["\"{DL} wasn't stumbling.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {DL} drink?", "\"Five beers on the tab, then two shots during karaoke for the group.\""),
                            .direct("How did {DL} seem?", "\"Happy, loud, singing. Normal karaoke night.\""),
                            .cross("Some of those drinks may have been for others.", "\"It was one tab for the group. I can't say who drank what.\""),
                            .cross("{DL} wasn't stumbling.", "\"No, {D.he} walked fine.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Golf cart mechanic",
                        direct: ["\"Grabbing brakes on these carts can flip them.\""],
                        cross: ["\"Speed matters most.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does 'brakes grab and pull left' mean?", "\"One rear drum locks up before the other. In a turn, that can snap the back end around and tip the cart.\""),
                            .direct("Was this cart serviced?", "\"No brake work in eleven months on a rental that runs every day in summer. That's not right.\""),
                            .cross("Would a slower driver have rolled?", "\"Less likely. Speed always matters.\""),
                            .cross("You never inspected this cart.", "\"The rental company scrapped it before I could.\"")
                        ])
        ],
        prosecutionTheory: ["{D} drank through karaoke night, then drove a golf cart full speed into a sharp turn. {V} died because {D} was impaired."],
        defenseTheory: ["A cart with known bad brakes, a rental company that never fixed them, and a friend who didn't buckle a lap belt. Tragedy isn't always a crime, and the State can't prove impairment caused the crash."],
        aggravating: ["The defendant's driving placed others at serious risk"],
        mitigating: ["The defendant has accepted responsibility", "The defendant has a support system in the community", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: ["{V}'s mother reads: \"They went to the beach for a weekend. I picked out my child's casket instead of picking {V.him} up at the airport. I don't hate {DL}. I just want {D.him} to understand.\""],
        allocutions: ["\"{V} was my best friend. I'd give anything to have taken that turn slower.\"", "\"I shouldn't have been driving. I knew it then.\""],
        guiltyTruths: ["Another friend in the group later told a civil lawyer that {DL} had been \"doing donuts\" in a parking lot with the cart twenty minutes before the crash."],
        innocentTruths: ["The rental company's own repair shop later admitted the cart's left rear brake cable had been jury-rigged with a hose clamp after an earlier complaint."],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "expertTestimony", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-7, "Renter complains the cart's brakes grab and pull left."), (0, "7:15 p.m.: group arrives at the beach bar."), (0, "11:31 p.m.: cart rolls on the turn off Ocean Drive."), (0, "1:35 a.m.: blood drawn from {DL} at the hospital."), (14, "Highway Patrol reconstruction completed.")],
            howIdentified: "{DL} was at the wheel when officers arrived.",
            notDone: ["The rental company scrapped the cart before the defense could inspect it.", "No one interviewed the earlier renter who complained."],
            defendantExam: [
                .direct("How much did you drink?", "\"Three beers, maybe four, over four hours. The shots were for the group.\""),
                .direct("What happened at the turn?", "\"I braked and the back end jerked left and we were over.\"", "\"I took it too fast. I was showing off a little.\""),
                .cross("Your BAC was 0.11 two hours later.", "\"I can't argue with the test.\""),
                .cross("You drove a golf cart at its top speed into a 90-degree turn.", "\"I didn't think a golf cart could flip.\""),
                .cross("You knew {V} wasn't buckled.", "\"Nobody buckles in a golf cart.\"")
            ],
            prosecutionOpening: "A karaoke tab, a 90-degree turn, and a friend thrown onto the pavement.",
            defenseOpening: "A cart with brakes the rental company knew were bad.",
            prosecutionClosing: "Impaired drivers misjudge turns. That's why the law exists.",
            defenseClosing: "The State can't prove impairment, rather than a broken brake, killed {V}.",
            when: .months([5, 6, 7, 8, 9]),
            victimDied: true,
            victim: VictimFacts(age: 31, occupation: "elementary school teacher", relationship: "A friend from home, on the same beach trip", harm: ["Fatal head injury"], restitution: 14800, restitutionBasis: "funeral expenses"),
            time: "11:31 p.m.",
            family: "Married; one young child.",
            residence: "A house in another county, at the beach for a weekend",
            scene: "The turn off Ocean Drive in Port Hollis"
        )
    )

    // MARK: - The birthday party

    static let birthdayParty = CaseTemplate(
        key: "story.birthdayParty", category: .robbery,
        headlines: ["Man Under Protective Order Shows Up at Daughter's Birthday Party", "Stalking Charge After Ex Watches Child's Party From Parked Car"],
        primaryLaw: "stalkingCourtOrder", lesserLaw: "stalking", threshold: 6, lesserThreshold: 4,
        specification: "On more than one occasion followed, was in the presence of, and watched {V} without legal purpose while a domestic violence protective order prohibiting that conduct was in effect, causing {V} to fear for {V.his} safety, between October and {DATE}.",
        ageRange: 26...45, occupations: ["HVAC technician", "warehouse supervisor", "truck driver", "electrician"], hasVictim: true,
        summaries: [
            "{V} has a one-year protective order against {D}, her ex-husband, ordering him to stay 500 feet from her and from their daughter's school except for exchanges set by the custody order. On {DATE} {D} parked across the street from the park pavilion where {V} was holding their daughter's sixth birthday party, sat for an hour, then walked over with a wrapped present and handed it to the girl. A teacher at the party called 911. {V}'s phone log shows {D}'s truck outside her apartment four other nights in three weeks, recorded by her doorbell camera. {DL} says he came to give his daughter a present on her birthday, that the custody order lets him see her, and that he lives two blocks from {V}'s apartment and drives past it to work."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Protective Order", "A one-year DVPO: no contact with {V}, stay 500 feet from her home, workplace, and the child's school, except custody exchanges at the sheriff's office."),
            E(.video, 3, "Doorbell Camera", "{DL}'s truck parked outside {V}'s apartment, engine running, on four nights over three weeks, each time 20 to 50 minutes."),
            E(.statement, 2, "911 Call", "A teacher at the party: \"He's been sitting in that truck watching us for an hour.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Custody Order", "Every other weekend with the daughter; exchanges at the sheriff's office."),
            E(.document, 1, "Lease", "{DL}'s apartment is two blocks from {V}'s, on the route to his job.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Defendant's ex-wife",
                        direct: ["\"I can't sleep without checking the doorbell camera.\""],
                        cross: ["\"He's never hurt our daughter.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("Why did you get the protective order?", "\"He put me through a door. The judge saw the photos.\""),
                            .direct("What did you see at the party?", "\"His truck across the street. He sat there the whole time. Then he walked straight through the kids to her.\""),
                            .direct("And the nights outside your apartment?", "\"I'd wake up and check the camera, and there he'd be, engine running, just sitting.\""),
                            .cross("He brought his daughter a birthday present.", "\"He could've brought it to the exchange at the sheriff's office. That's what the order says.\""),
                            .cross("He's never hurt your daughter.", "\"No. It's me he watches.\"")
                        ]),
            WitnessSeed(name: nil, role: "Kindergarten teacher",
                        direct: ["\"He watched us for an hour.\""],
                        cross: ["\"He was gentle with the girl.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What made you call 911?", "\"{V} told me about the order, and he'd been sitting in that truck staring at the pavilion for an hour.\""),
                            .direct("What happened when he walked over?", "\"{V} froze. The kids kept playing. He handed the present over and stood there looking at {V}.\""),
                            .cross("He didn't speak to {V}.", "\"He didn't. He looked at her.\""),
                            .cross("He was gentle with his daughter.", "\"He was.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's coworker",
                        direct: ["\"He talked about that party for weeks.\""],
                        cross: ["\"He knew about the order.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did he say about the party?", "\"That his little girl was turning six and he'd bought her a bike helmet with unicorns on it. He just wanted to see her open it.\""),
                            .direct("What's his route to work?", "\"Same as mine. Past those apartments every day.\""),
                            .cross("He knew he wasn't supposed to be near {V}.", "\"He knew about the order.\""),
                            .cross("Did he say he'd been parking outside her place at night?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["Under a court order to stay away, {D} parked outside {V}'s home four nights, then sat outside their daughter's party for an hour. A present doesn't change what the order says."],
        defenseTheory: ["A father brought his daughter a present on her birthday. He drives past that apartment to work. Loneliness isn't stalking."],
        aggravating: ["The defendant committed the offense while a court order was in effect", "The victim was particularly vulnerable"],
        mitigating: ["The defendant has a positive employment history and is gainfully employed", "The defendant has a support system in the community"],
        victimImpacts: ["\"My daughter's sixth birthday, and the photo I have is me frozen by the cake table. I just want to live without checking a camera every night.\""],
        allocutions: ["\"I just wanted to see my little girl blow out her candles.\"", "\"I couldn't let go. I know I have to.\""],
        guiltyTruths: ["A GPS tracker, found later magnetized under {V}'s car, was registered to {DL}'s email address."],
        innocentTruths: ["{DL}'s phone location showed his truck was at the night shift job site on two of the four nights the doorbell camera recorded, and the truck outside was his brother's, the same make and color."],
        moods: [.divided], doctrines: ["burdenOfProof", "victimRights"],
        story: StoryExtras(
            timeline: [(-120, "Protective order entered after a hearing."), (-21, "First night {DL}'s truck appears on {V}'s doorbell camera."), (-6, "Fourth night."), (0, "Afternoon: {DL} watches the party for an hour, then walks over with a present."), (0, "Teacher calls 911; deputies arrest {DL} at the park.")],
            howIdentified: "The 911 call from the party, and {V}'s doorbell camera.",
            notDone: ["{DL}'s phone location records were never pulled.", "No one checked whether anyone else drove a truck like his."],
            defendantExam: [
                .direct("Why did you go to the party?", "\"It was her birthday. I bought her a helmet for her new bike.\""),
                .direct("Why were you outside {V}'s apartment those nights?", "\"I drive that way to work. Sometimes I'd stop and look at the window and think about my family.\"", "\"I wasn't. That's not always me in that truck.\""),
                .cross("The order says exchanges at the sheriff's office only.", "\"It was her birthday.\""),
                .cross("You sat in your truck watching for an hour first.", "\"I was getting up my nerve.\""),
                .cross("Engine running, 50 minutes, outside her door at midnight.", "\"I was thinking.\"")
            ],
            prosecutionOpening: "A court order said stay away, and he kept coming back.",
            defenseOpening: "A father, a birthday, and a bike helmet with unicorns on it.",
            prosecutionClosing: "Four nights in the dark and an hour at a party. That's watching, and it's what the order forbids.",
            defenseClosing: "Driving to work and bringing a present isn't a course of conduct meant to frighten anyone.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(age: 29, occupation: "dental hygienist", relationship: "The defendant's ex-wife; protected by a DVPO", family: "Divorced; one daughter, six", harm: ["Fear for her safety; moved her daughter's school pickup to a relative"], restitution: 0),
            time: "about 3 p.m.",
            family: "Divorced; one daughter, six.",
            residence: "An apartment two blocks from {V}'s in {HOOD}"
        )
    )

    // MARK: - The dead brother's name

    static let deadBrotherIdentity = CaseTemplate(
        key: "story.deadBrotherIdentity", category: .whiteCollar,
        headlines: ["Man Took Out Loans in Dead Brother's Name, Prosecutors Say", "Bank Discovers Car Loan Borrower Died Three Years Ago"],
        primaryLaw: "identityTheft", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Knowingly obtained and used the identifying information of {V}, deceased, with intent to fraudulently represent that {D.he} was {V} to obtain credit, a $34,000 car loan and two credit cards, between June and {DATE}.",
        ageRange: 28...55, occupations: ["unemployed", "tow truck driver", "restaurant cook", "warehouse worker"], hasVictim: true,
        summaries: [
            "{V} died of a heart attack three years ago, at 39. In the past eighteen months, someone using {V}'s name, Social Security number, and date of birth took out a $34,000 car loan at a dealership in {CITY} and opened two credit cards that ran up $11,200. The loan defaulted, and the bank's investigator found the death record. The dealership's copy of the driver's license shows {V}'s name with a photo of {D}, {V}'s younger brother, who looks much like {V}. {DL} says {D.his} brother's widow, {ALT}, had all of {V}'s papers and must have done it, using {D.his} photo from a family album, to get back at {D.him} for a fight over the estate."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Dealership File", "A copy of a driver's license in {V}'s name with {DL}'s photo; a signature on the loan contract."),
            E(.document, 3, "DMV Records", "A duplicate license in {V}'s name issued two years after {V}'s death, at the {CITY} DMV office, with a new photo."),
            E(.forensic, 2, "Handwriting Comparison", "The loan signature shares features with {DL}'s known writing; the examiner calls it \"probably written by\" {DL}.")
        ],
        defenseEvidence: [
            E(.document, 2, "Estate Dispute", "{ALT} sued {DL} over {V}'s house; the case was pending when the loans began."),
            E(.statement, 1, "Papers", "{ALT} kept {V}'s wallet, Social Security card, and birth certificate after the funeral.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Bank fraud investigator",
                        direct: ["\"Our borrower had been dead for two years.\""],
                        cross: ["\"I didn't see who signed.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you find the problem?", "\"The loan defaulted. When we skip-traced the borrower, we found a death certificate.\""),
                            .direct("Who was in the license photo?", "\"Not the deceased. We compared it to {V}'s old license. Similar, younger, different nose and ears.\""),
                            .direct("Where did the car go?", "\"Recovered at a body shop in {CITY}. The shop says {DL} dropped it off.\""),
                            .cross("You didn't see who signed the contract.", "\"No.\""),
                            .cross("Brothers can look alike.", "\"That's why the photo was chosen, I'd think.\"")
                        ]),
            WitnessSeed(name: nil, role: "DMV license examiner",
                        direct: ["\"The person in that photo stood at my counter.\""],
                        cross: ["\"We see hundreds a day.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How is a duplicate license issued?", "\"The person brings a birth certificate and Social Security card, and we take a new photo on the spot.\""),
                            .direct("So the person in the photo was there?", "\"The camera's at the counter. Whoever's in the picture stood in front of it.\""),
                            .cross("Do you remember this person?", "\"No. We see three hundred people a day.\""),
                            .cross("You didn't check death records.", "\"The system didn't flag it then. It does now.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: "{ALT}", role: "The deceased's widow",
                        direct: ["\"I kept {V}'s papers in a lockbox.\""],
                        cross: ["\"I'm suing {DL} over the house.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where were {V}'s papers kept?", "\"In a lockbox in my closet. The birth certificate, Social Security card, all of it.\""),
                            .direct("Did anyone else have access?", "\"{DL} stayed with me for a month after the funeral, helping with things.\""),
                            .cross("You're suing {DL} over {V}'s house.", "\"I am. That doesn't mean I'd do this.\""),
                            .cross("Did you check the lockbox after {DL} left?", "\"Not until the bank called. The papers were gone.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took {V.his} dead brother's papers, stood at a DMV counter for a new license in {V}'s name, and borrowed $45,000 on a dead man's credit."],
        defenseTheory: ["{ALT} had the papers, the motive, and a grudge. A photo of a man who looks like his brother isn't proof of who used it."],
        aggravating: ["The offense was committed for pecuniary gain", "The defendant planned the offense"],
        mitigating: ["The defendant has made substantial or full restitution", "The defendant was suffering from a mental or physical condition that reduced culpability"],
        victimImpacts: ["{ALT} reads: \"Collection agencies called my house asking for my dead husband. I had to send his death certificate to six companies. Every letter was like burying him again.\""],
        allocutions: ["\"I didn't do this. She's lying because of the house.\"", "\"I was drowning in debt after he died. I told myself he'd want to help.\""],
        guiltyTruths: ["{DL}'s phone, searched later, held photos of {V}'s birth certificate and Social Security card taken the week {D.he} stayed with {ALT}."],
        innocentTruths: ["{ALT}'s boyfriend, who resembled both brothers, was later found with a second license in {V}'s name and admitted using the papers."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "eyewitnessID", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-1100, "{V} dies of a heart attack."), (-540, "Duplicate license issued in {V}'s name at the {CITY} DMV."), (-520, "$34,000 car loan at a {CITY} dealership."), (-300, "Two credit cards opened in {V}'s name."), (0, "Loan defaults; bank investigator finds the death record.")],
            howIdentified: "The license photo in the dealership's loan file.",
            notDone: ["The DMV counter camera's video was never requested.", "No one asked {ALT}'s boyfriend where he was the day the license was issued."],
            defendantExam: [
                .direct("Is that you in the license photo?", "\"It looks like me. People mixed us up our whole lives.\"", "\"Yes. I'm not going to say it isn't.\""),
                .direct("Did you take your brother's papers?", "\"No. {ALT} had them locked up.\""),
                .cross("The body shop says you dropped off the car.", "\"I've taken a lot of cars there.\""),
                .cross("You stayed in {ALT}'s house the month after the funeral.", "\"I was helping her.\""),
                .cross("The handwriting examiner says probably you.", "\"Probably isn't for sure.\"")
            ],
            prosecutionOpening: "A dead man's name, a living brother's face.",
            defenseOpening: "A grieving family, a lawsuit, and a lockbox that wasn't his.",
            prosecutionClosing: "Whoever's in that photo stood at the DMV counter. It's {DL}.",
            defenseClosing: "Looking like your brother isn't a crime. The State can't rule out {ALT}.",
            genders: ["D": .male, "V": .male, "ALT": .female],
            victimDied: true,
            victim: VictimFacts(age: 39, occupation: "lineman for the power company (deceased)", relationship: "The defendant's older brother", family: "Survived by his wife", harm: ["His identity used for $45,200 in credit after his death"], restitution: 45200, restitutionBasis: "the loan and credit card losses"),
            family: "Single; no children.",
            residence: "A rental duplex in {CITY}",
            sameSurname: true,
            altSameSurname: true
        )
    )
}
