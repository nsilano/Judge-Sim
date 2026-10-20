import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchQ: [CaseTemplate] = [chopShop, ptaTreasurer, jailSmuggling, dogMauling, odometerRollback]

    // MARK: - 94. The body shop (stolen trucks taken apart for parts)

    static let chopShop = CaseTemplate(
        key: "story.chopShop", category: .property,
        headlines: ["Police Raid {HOOD} Body Shop, Find Parts From 30 Stolen Trucks", "Owner Says He Bought Parts in Good Faith"],
        primaryLaw: "possStolen", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Possessed a stolen 2021 Ford F-250 belonging to {V}, knowing it had been stolen.",
        secondary: [
            SecondaryCharge(lawID: "possStolen", specification: "Possessed the cab and frame of a stolen 2020 Chevrolet Silverado taken from a {CITY} dealership lot.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "possStolen", specification: "Possessed a stolen 2022 Ram 2500 tailgate, engine, and transmission bearing a ground-off VIN.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "possStolen", specification: "Possessed a stolen enclosed cargo trailer and its contents, including welding equipment.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "felonFirearm", specification: "Possessed a 9mm pistol in a desk drawer at the shop after a prior felony conviction.", chance: 1.0, threshold: 0)
        ],
        ageRange: 38...50, occupations: ["auto body shop owner"], forcedPriorOffenses: ["Possession of Stolen Goods"], hasVictim: true,
        summaries: [
            "On {DATE}, after a GPS tracker hidden in {V}'s stolen pickup pinged inside a body shop in {HOOD}, detectives got a warrant. Inside they found {VL}'s truck half-stripped on a lift, and in the back lot, cabs, frames, engines, and tailgates from about 30 pickups reported stolen across three counties. Several had their vehicle identification numbers ground off. The shop's owner, {D}, says {D.he} buys salvage parts from many sellers, keeps receipts, and had no idea anything was stolen. Two young men arrested for stealing trucks told police {DL} paid them $1,500 a truck, cash, and told them which models {D.he} needed each week."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Stolen Vehicles", "{VL}'s truck on a lift and parts from 29 other stolen trucks in the yard.", .search),
            E(.forensic, 3, "Ground-Off VINs", "VINs filed off frames and engines; the crime lab recovered 11 numbers with acid etching, all from reported stolen trucks.", .search),
            E(.statement, 2, "Thieves' Statements", "Two men say {DL} paid $1,500 cash per truck and texted a \"shopping list\" of models."),
            E(.digital, 2, "Text Messages", "\"Need two F-250s and a Silverado this week. Diesel only.\" sent from {DL}'s phone.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Purchase Receipts", "Handwritten receipts for some parts from various individual sellers."),
            E(.document, 1, "Salvage License", "{DL} holds a valid salvage and repair license."),
            E(.statement, 1, "Customer Testimony", "Long-time customers who say the shop did honest work.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Auto theft detective",
                        direct: ["\"Legitimate salvage doesn't have ground-off VINs.\""],
                        cross: ["\"Some parts had receipts.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Why does a ground-off VIN matter?", "\"Nobody grinds a VIN off a legitimate salvage part. You grind it off because the part is hot. Every one we recovered was from a reported stolen truck.\""),
                            .direct("What did the texts say?", "\"'Need two F-250s and a Silverado this week. Diesel only.' That's an order.\""),
                            .cross("{DL} had handwritten receipts for some parts?", "\"From sellers with no last names, no addresses, cash, at a fraction of value.\""),
                            .cross("Could the texts mean {DL} wanted to buy salvage?", "\"Salvage doesn't come in this week's model list.\"")
                        ]),
            WitnessSeed(name: nil, role: "Truck thief (cooperating)",
                        direct: ["\"{DL} paid fifteen hundred a truck.\""],
                        cross: ["\"I'm getting a deal.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did it work?", "\"{DL} texted what {D.he} needed. We found them, took them at night, drove them in the back gate. {D.He} paid cash, fifteen hundred.\""),
                            .direct("Did {DL} know they were stolen?", "\"{D.He} told us to come after midnight and keep the gate quiet. {D.He} knew.\""),
                            .cross("You're testifying to get probation?", "\"The DA said they'd consider it.\""),
                            .cross("You stole trucks before you ever met {DL}?", "\"Yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Longtime customer",
                        direct: ["\"{DL} fixed my car for ten years.\""],
                        cross: ["\"I never went in the back lot.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What kind of business did {DL} run?", "\"Honest. Fair prices. Fixed my car after a wreck and charged less than the estimate.\""),
                            .cross("Did you ever go in the back lot?", "\"No.\""),
                            .cross("Did you know {DL} had a prior conviction for possessing stolen goods?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{D} ran a chop shop: {D.he} ordered trucks by model, paid thieves cash, ground off the VINs, and sold the parts."],
        defenseTheory: ["{DL} buys salvage from many sellers and had no reason to suspect these parts. The State's case rests on two thieves trying to save themselves."],
        aggravating: ["The offense involved the taking of property of great monetary value (G.S. 15A-1340.16(d)(14))"],
        mitigating: ["The defendant has been gainfully employed", "The defendant has a support system in the community"],
        victimImpacts: ["{VL}: \"That truck was my business. I lost three weeks of contracts and my insurance doubled.\""],
        allocutions: ["\"I should have asked more questions about where the parts came from.\""],
        guiltyTruths: ["A ledger in the shop's ceiling, found later, listed each truck by model, the thief's nickname, and $1,500."],
        innocentTruths: ["The texts were later traced to {DL}'s shop manager, who used {DL}'s old phone and ran the back lot at night without {DL}'s knowledge."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(-120, "Truck thefts across three counties increase."),
                       (-1, "{VL}'s F-250 stolen from a job site."),
                       (0, "GPS tracker pings inside the body shop; search warrant executed."),
                       (2, "Two thieves arrested; both name {DL}."),
                       (20, "Crime lab recovers 11 VINs.")],
            howIdentified: "A GPS tracker in {VL}'s truck.",
            notDone: ["The shop manager's phone was never searched."],
            defendantExam: [
                .direct("Where did the parts come from?", "\"People come by with parts all the time. Salvage auctions, wrecks, private sellers. I paid fair prices.\""),
                .direct("What about the ground-off VINs?", "\"I didn't grind anything. Some parts come that way.\""),
                .cross("$1,500 for a diesel truck worth $60,000. That's a fair price?", "\"For parts, sometimes.\""),
                .cross("Why tell people to come after midnight?", "\"I never said that.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Did you know {DL} had a prior conviction for possessing stolen goods?\"",
                                  answer: "\"No.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Improper character evidence", shouldSustain: false,
                                  explanation: "When a defense witness vouches for the defendant's honesty, the State may test the basis of that opinion by asking whether the witness knew of relevant prior conduct.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "A shopping list, cash at midnight, and ground-off VINs.",
            defenseOpening: "A busy shop, many sellers, and two thieves who want a deal.",
            prosecutionClosing: "Innocent buyers don't get VINs filed off. Thieves' customers do.",
            defenseClosing: "The thieves' word isn't enough to prove what {DL} knew.",
            genders: ["D": .male]
        )
    )

    // MARK: - 95. The treasurer (school booster money)

    static let ptaTreasurer = CaseTemplate(
        key: "story.ptaTreasurer", category: .whiteCollar,
        headlines: ["PTA Treasurer Charged With Taking $68,000 From Elementary School", "Field Trip Money Spent on Vacations"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "As treasurer of the {HOOD} Elementary PTA, embezzled $68,400 entrusted to {D.him} for the PTA's programs.",
        secondary: [
            SecondaryCharge(lawID: "embezzlement", specification: "As treasurer of the {HOOD} Middle School Band Boosters, embezzled $14,200 raised for band travel.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Forged the PTA president's signature on 22 checks.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "uttering", specification: "Passed forged PTA checks payable to cash and to {D.his} own credit card company.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Created false bank statements presented to the PTA board at four meetings.", chance: 1.0, threshold: 0)
        ],
        ageRange: 36...46, occupations: ["dental office manager", "real estate agent"], hasVictim: false,
        summaries: [
            "On {DATE}, the new president of the {HOOD} Elementary PTA asked the bank for statements directly, after the treasurer, {D}, kept bringing photocopies to meetings. The real statements showed a balance of $212 instead of $68,000. Over three years, {DL} had written 22 checks to cash or to {D.his} credit card company, forging the outgoing president's co-signature. The money had been raised for field trips, a playground, and teacher grants. {DL} was also treasurer of the middle school band boosters, where $14,200 was missing. {DL} admits taking money but says {D.he} meant to repay it, had a gambling problem, and has paid back $9,000."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Records", "Twenty-two checks, $68,400 total, to cash or to {DL}'s credit card; real balance $212."),
            E(.document, 3, "Altered Statements", "Photocopies presented to the board showing a $67,800 balance, made by pasting numbers over a real statement.", .search),
            E(.forensic, 2, "Handwriting Analysis", "The co-signer signatures on 22 checks were not written by the PTA president."),
            E(.document, 2, "Spending", "Credit card charges for two beach trips, a hot tub, and online casino deposits.")
        ],
        defenseEvidence: [
            E(.document, 2, "Repayments", "$9,000 repaid to the PTA after discovery."),
            E(.document, 2, "Gambling Treatment", "Records showing {DL} entered gambling addiction treatment the week the theft was discovered."),
            E(.statement, 1, "Volunteer Hours", "{DL} volunteered hundreds of hours over six years.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "PTA president",
                        direct: ["\"There was $212 in the account.\""],
                        cross: ["\"{DL} volunteered more than anyone.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did you find?", "\"$212. We'd told teachers they'd get grants. We'd booked buses for the zoo trip. There was nothing.\""),
                            .direct("Did you sign those checks?", "\"No. Not one. That isn't my signature.\""),
                            .cross("{DL} volunteered more hours than anyone?", "\"Yes. Which is why nobody looked.\""),
                            .cross("{DL} has paid back $9,000?", "\"After we caught it.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"The statements were cut and pasted.\""],
                        cross: ["\"{DL} confessed right away.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How were the statements altered?", "\"{DL} took a real statement from the first year, covered the numbers, typed new ones, and photocopied it. We found the master copies on {D.his} home printer.\""),
                            .direct("Where did the money go?", "\"About a third to online casinos. The rest to trips, a hot tub, and the family credit card.\""),
                            .cross("{DL} admitted taking the money the first time you asked?", "\"Yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Gambling addiction counselor",
                        direct: ["\"{DL} has a gambling disorder.\""],
                        cross: ["\"Addiction isn't a defense.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you diagnose?", "\"Severe gambling disorder. Online slots. Chasing losses, borrowing, hiding it. {DL} has been in treatment and attending meetings since.\""),
                            .cross("Did the gambling make {DL} forge signatures?", "\"It made {D.him} desperate. The choices were {D.his}.\""),
                            .cross("Treatment started the week {D.he} was caught?", "\"Yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took money raised by children and parents, forged signatures, and faked bank statements for three years."],
        defenseTheory: ["{DL} doesn't contest the facts. {D.He} is an addict who is in treatment and repaying. The court should focus on restitution."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant made substantial or full restitution to the victim", "The defendant has expressed remorse"],
        victimImpacts: ["A teacher: \"My students sold wrapping paper for a year to go to the aquarium. I had to tell them it wasn't happening.\""],
        allocutions: ["\"I'm ashamed. I'll repay every dollar. I'm sorry to the kids.\""],
        guiltyTruths: ["A message from {DL} to a friend that spring: \"PTA money is the easiest money in the world, nobody checks.\""],
        innocentTruths: ["The outgoing PTA president later admitted co-signing several of the cash checks for a shared 'reimbursement' the two of them had agreed on."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-1095, "{DL} becomes PTA treasurer."),
                       (-1000, "First check to cash."),
                       (-400, "{DL} becomes band boosters treasurer."),
                       (0, "New president gets bank statements directly."),
                       (5, "{DL} admits taking money; enters treatment."),
                       (60, "Charges filed after audit.")],
            howIdentified: "Bank statements obtained directly by the new PTA president.",
            notDone: ["The outgoing president's own accounts were not reviewed."],
            defendantExam: [
                .direct("Why did you take the money?", "\"I was losing at online slots and I kept thinking I'd win it back and put it back. Every month it got worse.\""),
                .direct("Have you repaid any?", "\"$9,000. I'm selling my car for more.\""),
                .cross("You also bought a hot tub and took two beach trips.", "\"Yes. I'm not proud of that.\""),
                .cross("And you forged the president's signature 22 times.", "\"Yes.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"Should someone with this disorder go to prison?\"",
                                  answer: "\"Treatment is far more effective.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Relevance to guilt", shouldSustain: true,
                                  explanation: "Opinions about the proper punishment don't bear on whether the elements were proved; they may be presented at sentencing.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Zoo trips, playground money, and teacher grants, turned into slot machine credits.",
            defenseOpening: "No one disputes this happened. {DL} is sick and trying to make it right.",
            prosecutionClosing: "Every forged signature was a separate choice.",
            defenseClosing: "Restitution and treatment serve these children better than a cell."
        )
    )

    // MARK: - 96. The detention officer (fentanyl smuggled into the jail)

    static let jailSmuggling = CaseTemplate(
        key: "story.jailSmuggling", category: .drugs,
        headlines: ["Inmate Dies of Overdose in Hollis County Jail", "Detention Officer Charged With Smuggling Fentanyl"],
        primaryLaw: "deathByDistribution", lesserLaw: "deliverSchedII", threshold: 9, lesserThreshold: 7,
        specification: "Unlawfully sold fentanyl inside the Hollis County Detention Center, the ingestion of which caused the death of {V}.",
        secondary: [
            SecondaryCharge(lawID: "bribery", specification: "As a detention officer, accepted $2,000 per delivery to bring contraband into the detention center.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "deliverSchedII", specification: "Delivered fentanyl-laced paper strips to an inmate in Pod C on a separate occasion.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "pwisd", specification: "Possessed with intent to deliver 12 grams of fentanyl found in {D.his} car in the staff lot.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Falsified cell-check logs to show rounds that were never made the night of {V}'s overdose.", chance: 1.0, threshold: 0)
        ],
        ageRange: 25...34, occupations: ["detention officer"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 31, was found unresponsive in a cell at the Hollis County Detention Center, where {V.he} was being held on a probation violation. {V.He} died of fentanyl toxicity. Two other inmates in the same pod overdosed that week and survived. Investigators traced the drugs to letters soaked in fentanyl and to small balloons. Jail phone calls in code and a cash app account led to {D}, a detention officer in Pod C. A search of {DL}'s car in the staff lot found 12 grams of fentanyl. An inmate who was the go-between says {DL} was paid $2,000 a trip by an outside dealer. The logs show {DL} made cell checks every 30 minutes the night {VL} died; video shows {D.he} never left the officer's desk."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Cash App Payments", "Eleven payments of $2,000 from an account linked to a known dealer to {DL}'s account.", .search),
            E(.physical, 3, "Fentanyl in Car", "Fourteen grams of fentanyl in balloons in {DL}'s console, found under a warrant.", .search),
            E(.video, 2, "Pod Video", "{DL} passing a folded item to the go-between inmate during a cell check the afternoon before {VL}'s death; no cell checks that night."),
            E(.forensic, 2, "Autopsy and Toxicology", "Death from fentanyl toxicity; the drug in {VL}'s cell matched the composition of the fentanyl from {DL}'s car.")
        ],
        defenseEvidence: [
            E(.document, 2, "Mail Room Failures", "Fentanyl-soaked letters got through the mail room, a separate route not tied to {DL}."),
            E(.statement, 2, "Informant's Record", "The go-between inmate has eight convictions and is getting a sentence reduction."),
            E(.document, 1, "Understaffing", "Pod C was staffed at half the required level that month.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Inmate go-between (cooperating)",
                        direct: ["\"{DL} brought the balloons in.\""],
                        cross: ["\"I'm getting time off.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did the drugs get into Pod C?", "\"{DL} brought them in. My people on the outside paid {D.him} two thousand a trip. {D.He}'d hand it to me during rounds and I'd sell it.\""),
                            .direct("Did you sell to {VL}?", "\"Yes. The night before. {V.He} paid in commissary.\""),
                            .cross("You've got eight prior convictions and you're getting a reduced sentence?", "\"Yes.\""),
                            .cross("Fentanyl was coming in through the mail too?", "\"Some. The good stuff came from {DL}.\"")
                        ]),
            WitnessSeed(name: nil, role: "SBI agent",
                        direct: ["\"The drugs matched the car.\""],
                        cross: ["\"The mail room was a problem.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you tie {DL} to the death?", "\"The fentanyl in {VL}'s cell had the same cutting agents and ratios as what we found in {DL}'s car. The letters had a different mix. And the money trail goes straight to {DL}.\""),
                            .direct("What about the cell checks?", "\"The log shows checks every 30 minutes. The video shows {DL} at the desk all night. {VL} was dead for hours before anyone found {V.him}.\""),
                            .cross("Fentanyl was also coming through the mail room?", "\"Yes. Different composition.\""),
                            .cross("The pod was understaffed?", "\"Yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fellow detention officer",
                        direct: ["\"We were working doubles at half staff.\""],
                        cross: ["\"I never took money.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What were conditions like?", "\"Half staff. Sixteen-hour shifts. You can't do every round. Everybody fudges logs sometimes because you can't physically do it.\""),
                            .cross("Did you ever take money to bring anything in?", "\"No.\""),
                            .cross("Does understaffing explain fentanyl in {DL}'s car?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was paid to smuggle fentanyl into the jail. {D.He} sold death to people in {D.his} custody, then sat at the desk while {V} died."],
        defenseTheory: ["Fentanyl was pouring into the jail through the mail. The State can't prove {DL}'s drugs, rather than the mail's, killed {VL}, and its case rests on a career criminal's deal."],
        aggravating: ["The defendant abused a position of public trust", "The offense involved multiple victims"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s mother: \"My child was in jail on a probation violation. They were supposed to be safe. The person paid to watch them sold them the drug that killed them.\""],
        allocutions: ["\"I needed the money. I never thought anyone would die.\""],
        guiltyTruths: ["A message from {DL} to the dealer the day after the death: \"Lay low, somebody in C died. Next drop next week.\""],
        innocentTruths: ["A later lab retest found the fentanyl in {VL}'s cell matched a batch of soaked letters better than {DL}'s supply."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(-90, "Cash payments to {DL} begin."),
                       (-1, "Pod video: {DL} hands an item to the go-between."),
                       (0, "Night: {VL} overdoses; no cell checks for six hours."),
                       (0, "6:10 a.m.: {VL} found unresponsive."),
                       (3, "Two more overdoses in Pod C."),
                       (12, "{DL}'s car searched in staff lot; arrested.")],
            howIdentified: "Cash app records and the go-between's statement.",
            notDone: ["The mail room staff were never investigated."],
            defendantExam: [
                .direct("Did you bring drugs into the jail?", "\"I brought in cigarettes and phones. I didn't know there was fentanyl in what they handed me.\""),
                .direct("What about the 12 grams in your car?", "\"I'd been handed a package to bring in. I didn't open it.\""),
                .cross("$2,000 a trip for cigarettes?", "\"That's what they paid.\""),
                .cross("You logged cell checks you never made.", "\"Everybody did.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Did other inmates tell you {DL} was the source?\"",
                                  answer: "\"Everybody in the pod knew it was {D.him}.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: true,
                                  explanation: "What other inmates said, offered to prove {DL} was the source, is hearsay with no exception, and the witness's claim about what 'everybody knew' is speculation.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "The person paid to keep {VL} safe was paid more to bring in the drug that killed {V.him}.",
            defenseOpening: "A jail flooded with fentanyl, and a snitch who needs someone to blame.",
            prosecutionClosing: "Same drug, same mix, same pod, same officer who never checked the cell.",
            defenseClosing: "Two sources of fentanyl and no proof which one killed {VL}.",
            victim: VictimFacts(record: "Held in the county jail on a probation violation at the time of death.")
        )
    )

    // MARK: - 97. The dogs (a neighbor killed in an apartment hallway)

    static let dogMauling = CaseTemplate(
        key: "story.dogMauling", category: .violent,
        headlines: ["Woman Mauled to Death by Neighbor's Dogs in Apartment Hallway", "Owner Charged With Murder After Dozens of Warnings"],
        primaryLaw: "murder2", lesserLaw: "invManslaughter", threshold: 10, lesserThreshold: 8,
        specification: "Unlawfully and with malice killed {V} by bringing into a shared hallway two dogs {D.he} knew to be dangerous and failing to restrain them.",
        secondary: [
            SecondaryCharge(lawID: "awdwisi", specification: "Assaulted a delivery driver with a deadly weapon, a 120-pound dog, inflicting serious injury, two months earlier.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "animalCruelty", specification: "Kept the dogs confined in a 600-square-foot apartment without adequate exercise and trained them for aggression.", chance: 1.0, threshold: 0)
        ],
        ageRange: 44...50, occupations: ["paralegal"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 33, a college lacrosse coach, was carrying groceries to {V.his} apartment in a {HOOD} building when two Presa Canario dogs, each over 100 pounds, attacked {V.him} in the hallway. The dogs' owner, {D}, was holding one leash. {VL} suffered 77 wounds and died that night. Building residents had complained about the dogs more than 30 times. A delivery driver had been bitten two months earlier, and a neighbor had been pinned against a wall. The dogs had come from a breeding operation run by inmates, and letters showed {DL} knew the dogs had been bred for guarding. {DL} says {D.he} threw {D.himself} on {VL} to stop the attack and that no one could have predicted it."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Prior Incidents", "Thirty-one complaints to building management, a bite on a delivery driver, and a veterinarian's written warning that the dogs were \"a time bomb.\""),
            E(.forensic, 3, "Autopsy", "Seventy-seven wounds; every part of {VL}'s body except the scalp and feet was bitten."),
            E(.document, 2, "Letters", "Letters between {DL} and the breeder describing the dogs as \"guard dogs\" and joking about their aggression."),
            E(.statement, 2, "Neighbor Testimony", "A neighbor heard {VL} screaming for over five minutes and no commands to the dogs.")
        ],
        defenseEvidence: [
            E(.forensic, 2, "{DL}'s Injuries", "Bite wounds on {DL}'s hands consistent with trying to pull the dogs off."),
            E(.document, 1, "Size of Defendant", "{DL} weighs 115 pounds; the dog weighed 140."),
            E(.statement, 1, "Dog Trainer", "A trainer who says the dogs had been well behaved in sessions.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Veterinarian",
                        direct: ["\"I told {DL} the dogs were a time bomb.\""],
                        cross: ["\"I never saw them attack anyone.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you tell {DL}?", "\"That the dogs were dangerous, should never be in public without muzzles, and that one day they'd kill someone. I wrote it in a letter too.\""),
                            .direct("How did {DL} respond?", "\"{D.He} laughed and said that was the point of the breed.\""),
                            .cross("You never saw the dogs attack anyone?", "\"I saw them lunge at my staff. That was enough.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead investigator",
                        direct: ["\"Thirty-one complaints.\""],
                        cross: ["\"{DL} was bitten too.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What warnings did {DL} have?", "\"Thirty-one complaints, a bitten delivery driver, a neighbor pinned to the wall, a vet's letter, and a dog trainer who quit after two sessions.\""),
                            .direct("What did {DL} do after the attack?", "\"Put the dogs back in the apartment. Never called 911. A neighbor did.\""),
                            .cross("{DL} had bite wounds on {D.his} hands?", "\"Minor ones.\""),
                            .cross("{DL} says {D.he} threw {D.himself} on top of {VL}?", "\"That's what {D.he} says. The neighbor didn't see that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Dog trainer",
                        direct: ["\"They were manageable in sessions.\""],
                        cross: ["\"I only had two sessions.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did the dogs behave with you?", "\"Responsive to commands. Big, protective, but manageable with proper handling.\""),
                            .cross("How many sessions did you have?", "\"Two.\""),
                            .cross("Did you recommend muzzles in public?", "\"I did.\""),
                            .cross("Did {DL} use them?", "\"Not that I saw.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew {D.his} dogs were killers. After dozens of warnings, {D.he} walked them unmuzzled into a narrow hallway, couldn't hold them, and didn't even call 911. That's malice: a depraved indifference to human life."],
        defenseTheory: ["{DL} loved {D.his} dogs and never imagined they'd kill. {D.He} tried to stop the attack and was injured. At most this is a negligent failure: involuntary manslaughter, not murder."],
        aggravating: ["The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s partner: \"She was coming home with groceries. She fought for five minutes. She was the strongest person I knew.\""],
        allocutions: ["\"I'm so sorry. I'd give anything to undo that day.\""],
        guiltyTruths: ["A neighbor later disclosed a recording of {DL} saying weeks earlier, \"If that coach complains one more time, I'll let them say hello.\""],
        innocentTruths: ["A building camera, found later, showed a maintenance worker leaving the dogs' door unlatched and the dogs bolting out before {DL} could grab them."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-365, "First complaint to building management."),
                       (-60, "Delivery driver bitten in the lobby."),
                       (-30, "Veterinarian's warning letter."),
                       (0, "4:00 p.m.: {VL} attacked in hallway."),
                       (0, "4:06 p.m.: neighbor calls 911."),
                       (0, "10:40 p.m.: {VL} dies at the hospital."),
                       (40, "{DL} indicted for second-degree murder.")],
            howIdentified: "{DL} was present and the dogs were {D.his}.",
            notDone: ["The building's hallway cameras weren't pulled until weeks later."],
            defendantExam: [
                .direct("What happened in the hallway?", "\"{VL} was at {V.his} door. The dog lunged. I couldn't hold him. I threw myself on {V.him}. I was screaming at the dogs.\""),
                .direct("Did you think they were dangerous?", "\"They were protective, not killers.\""),
                .cross("Thirty-one complaints. A bitten delivery driver. A vet's letter.", "\"People were afraid of their size.\""),
                .cross("You didn't call 911.", "\"I was getting the dogs away.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, what did the delivery driver tell you about the bite?\"",
                                  answer: "\"That the dog came at him with no warning and {DL} laughed.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: true,
                                  explanation: "The driver's statement to the detective is hearsay; the State must call the driver or use the incident report under a proper exception.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "Thirty-one warnings. A vet who called them a time bomb. Seventy-seven wounds.",
            defenseOpening: "A horrible accident and an owner who tried to stop it.",
            prosecutionClosing: "Knowing the risk and walking them anyway is malice.",
            defenseClosing: "Negligence, even gross negligence, is manslaughter, not murder.",
            genders: ["D": .female, "V": .female]
        )
    )

    // MARK: - 98. The odometer (a used-car lot rolls back miles)

    static let odometerRollback = CaseTemplate(
        key: "story.odometerRollback", category: .whiteCollar,
        headlines: ["{CITY} Used Car Dealer Accused of Rolling Back Odometers", "Buyers Paid Thousands Extra for 'Low-Mile' Cars"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Obtained $18,900 from {V} by selling a 2017 Honda Accord with an odometer rolled back from 162,000 miles to 61,000.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $14,500 from {VIC2} by selling a 2016 Toyota Camry with an odometer rolled back by 88,000 miles.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $22,300 from a {CITY} church by selling a 15-passenger van with an odometer rolled back by 110,000 miles.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Forged odometer disclosure statements on three vehicle titles.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "uttering", specification: "Submitted forged odometer disclosure statements to the Division of Motor Vehicles.", chance: 1.0, threshold: 0)
        ],
        ageRange: 42...60, occupations: ["used car dealer"], hasVictim: true,
        summaries: [
            "On {DATE}, {V} took a 2017 Honda Accord bought eight months earlier from {D}'s lot in {HOOD} in for a transmission repair. The mechanic plugged in a scanner: the transmission computer recorded 164,000 miles. The odometer read 68,000. A DMV investigation found 41 cars sold from {DL}'s lot over two years with mileage dropped between 40,000 and 110,000 miles, using a $300 handheld device bought online. Many of the cars had been bought at auctions with their true mileage printed on the auction sheets. {DL} says {D.he} buys cars as-is, never touched an odometer, and that the cars must have been tampered with before {D.he} got them."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Auction Records", "Auction purchase sheets for each car showing true mileage on the day {DL}'s lot bought it, weeks before resale."),
            E(.digital, 3, "Module Readouts", "Engine and transmission computers in 41 cars recorded mileage far above the odometer reading."),
            E(.physical, 2, "Rollback Device", "A handheld odometer programmer found in {DL}'s office desk, with a log of 39 uses.", .search),
            E(.document, 2, "Signed Disclosures", "Odometer disclosure statements signed by {DL} certifying the low mileage as actual.")
        ],
        defenseEvidence: [
            E(.document, 2, "As-Is Contracts", "Each buyer signed an as-is, no-warranty contract."),
            E(.statement, 1, "Employee Access", "Three employees and a former partner had keys to the office."),
            E(.document, 1, "Device Uses", "The programmer is also used for legitimate repairs like replacing a cluster.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "DMV License and Theft Bureau inspector",
                        direct: ["\"The auction sheets prove it.\""],
                        cross: ["\"Others had access to the device.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How do you know the rollbacks happened on {DL}'s lot?", "\"The auction sheets. Every car was bought with its true mileage printed on the sheet, and sold weeks later with less. The miles disappeared between the auction and the sale.\""),
                            .direct("What did the device log show?", "\"Thirty-nine programming events, matching the dates cars came in from auction.\""),
                            .cross("Others had keys to the office?", "\"Yes. {DL} signed the disclosures.\""),
                            .cross("As-is sales mean no warranty?", "\"No warranty. They don't make lying about mileage legal.\"")
                        ]),
            WitnessSeed(name: nil, role: "Buyer",
                        direct: ["\"I paid extra for low miles.\""],
                        cross: ["\"I didn't get an inspection.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you choose that car?", "\"Low miles. Sixty-one thousand. I paid $4,000 more than for the same car with high miles.\""),
                            .direct("What did {DL} say?", "\"That it was a one-owner car that sat in a garage.\""),
                            .cross("You didn't get an independent inspection?", "\"No. I trusted the odometer.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former lot manager",
                        direct: ["\"The ex-partner did the reconditioning.\""],
                        cross: ["\"{DL} signed every title.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Who handled cars between auction and sale?", "\"{DL}'s old partner did the reconditioning in the back bay. {DL} was out front selling.\""),
                            .cross("Who signed the odometer statements?", "\"{DL}.\""),
                            .cross("Was the partner still there the last eight months?", "\"No, {DL} bought {D.his} share out.\"")
                        ])
        ],
        prosecutionTheory: ["{D} bought high-mileage cars at auction, rolled them back with a device in {D.his} desk, signed false disclosures, and sold them as low-mile cars."],
        defenseTheory: ["Others had access and motive. {DL} relied on the reconditioning staff and didn't know. An as-is sale isn't a crime."],
        aggravating: ["The offense involved multiple victims"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{VL}: \"I bought that car for my kid's commute to nursing school. The transmission went because it had 160,000 miles on it.\""],
        allocutions: ["\"I'll make every buyer whole.\""],
        guiltyTruths: ["A text from {DL} to the former partner: \"Take another 80 off the Camry, it's moving slow.\""],
        innocentTruths: ["The device's account was registered to the former partner, and the purchase was made from the partner's home address."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["VIC2": ["Terrence Wade", "Alicia Moody", "Ray Fulcher"]],
        story: StoryExtras(
            timeline: [(-730, "Rollback device purchased online."),
                       (-240, "{V} buys the Accord."),
                       (0, "Transmission computer shows 164,000 miles."),
                       (21, "DMV inspectors execute a search warrant at the lot."),
                       (90, "Charges filed after review of 41 cars.")],
            howIdentified: "A mechanic's scan and {VL}'s complaint to the DMV.",
            notDone: ["The former partner was never interviewed."],
            defendantExam: [
                .direct("Did you roll back odometers?", "\"No. I sell cars. Reconditioning was in the back. I signed what the paperwork said.\""),
                .direct("Why was the device in your desk?", "\"It's for replacing instrument clusters.\""),
                .cross("Thirty-nine uses, each the week a car came from auction.", "\"I don't know who used it.\""),
                .cross("The auction sheet was in your file for each car, with the true miles.", "\"I don't read every sheet.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Did you ever learn that other buyers had the same problem?\"",
                                  answer: "\"Yes, I read about 40 of them in the paper.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay and lack of personal knowledge", shouldSustain: true,
                                  explanation: "The witness's knowledge comes from a newspaper; it's hearsay and not within personal knowledge.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "Miles went in at auction and disappeared on {DL}'s lot.",
            defenseOpening: "As-is cars, a busy lot, and many hands in the back bay.",
            prosecutionClosing: "{DL} signed every false statement. {D.He} owned the device. {D.He} owned the lot.",
            defenseClosing: "Access by others leaves reasonable doubt about who did the rolling."
        )
    )
}
