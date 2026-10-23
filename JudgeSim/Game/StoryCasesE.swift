import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchE: [CaseTemplate] = [longDrive, neighborsMailbox, wrongDoor, lastPill, alibiWitness]

    // MARK: - 34. The long drive (kidnapping)

    static let longDrive = CaseTemplate(
        key: "story.longDrive", category: .robbery,
        headlines: ["Ex-Partner Charged With Kidnapping After Five-Hour Drive", "Held Against Will, or a Long Talk?"],
        primaryLaw: "kidnapping2", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Unlawfully restrained and removed {V} for the purpose of terrorizing {V.him}.",
        secondary: [
            SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened to drive {V} and {D.himself} off a bridge.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "interferingEmergency", specification: "Interfered with {V}'s ability to call for help by taking {V.his} phone.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "misdLarceny", specification: "Took {V}'s phone and kept it during the drive.", chance: 1.0, threshold: 3)
        ],
        ageRange: 26...42, occupations: ["HVAC technician"], hasVictim: true,
        summaries: [
            "On {DATE}, {D} showed up at {V}'s workplace parking lot in {HOOD} at shift change, six weeks after {V.he} ended their relationship. {VL} got into {DL}'s car. Five hours later {VL} jumped out at a gas station in Virginia and called 911, saying {DL} had locked the doors, taken {VL}'s phone, and threatened to drive them both off a bridge. {DL} says {VL} got in willingly to talk, that they argued for hours, and that {V.he} could have left at any of three stops."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "911 Call from Virginia", "{V}, sobbing: \"I got away, I've been in the car five hours, {DL} took my phone, said we'd both go off the bridge.\""),
            E(.video, 2, "Workplace Lot Video", "{VL} walks to {DL}'s car, talks through the window for about a minute, and gets in the passenger seat. No visible force."),
            E(.physical, 2, "Child-Lock Setting", "The passenger rear and front power locks were set to driver-only control; {VL}'s phone was found in the driver's door pocket.", .search),
            E(.video, 2, "Gas Station Video", "At the final stop, {VL} bolts from the car toward the store while {DL} pumps gas.")
        ],
        defenseEvidence: [
            E(.video, 3, "Earlier Stop Video", "At a rest stop two hours into the trip, {VL} walks alone into the restroom building, stays four minutes, and walks back to the car."),
            E(.document, 2, "Texts Before the Drive", "{VL} texted {DL} that morning: \"Fine. Come by after my shift. We can talk one more time.\""),
            E(.document, 1, "Lock Settings", "The car's owner's manual shows driver-only lock control is the factory default for that model.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complainant",
                        direct: ["\"I got in to talk. I couldn't get out.\""],
                        cross: ["\"At the rest stop I went back to the car.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you get into the car?", "\"Because {DL} had been texting nonstop for weeks and I thought if we talked one more time, face to face, it would end. I said we could talk in the lot.\""),
                            .direct("What happened when you got in?", "\"{DL} pulled out of the lot before I closed the door all the way. I said where are we going. {DL} said 'somewhere you'll listen.' I reached for the handle and the lock clicked.\""),
                            .direct("What did {DL} say during the drive?", "\"That if I didn't come back, there was no reason for either of us to be alive. When we went over the James River bridge, {DL} slowed down and said 'right here would be easy.'\""),
                            .direct("Why didn't you run sooner?", "\"{DL} had my phone. We were on the interstate. At the rest stop I was terrified that if I ran and {DL} caught me, it would be worse. At the gas station I saw a trooper's car across the road and I ran.\""),
                            .cross("You texted {DL} that morning to come by after work?", "\"To talk in the parking lot. Not to get driven to Virginia.\""),
                            .cross("At the rest stop you walked into the building alone and walked back to the car?", "\"Yes. I've explained why.\""),
                            .cross("You never told anyone at the rest stop you needed help?", "\"There was one person in there, and I was shaking too hard to speak.\"")
                        ]),
            WitnessSeed(name: nil, role: "Virginia State Police trooper",
                        direct: ["\"{VL} was hysterical and shaking.\""],
                        cross: ["\"{DL} didn't try to leave.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you see?", "\"{VL} running across the road toward my car, crying, saying 'please, please.' Couldn't hold a pen to fill out a statement for twenty minutes.\""),
                            .direct("What did you find in the car?", "\"{VL}'s phone in the driver's door pocket, and the locks set so only the driver could open the passenger doors.\""),
                            .cross("{DL} stayed at the pump and waited for you?", "\"Yes. {DL} was calm and said they'd been talking.\""),
                            .cross("Driver-only locks are the factory setting on that car?", "\"I didn't know that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s sibling",
                        direct: ["\"{DL} told me they were going to talk things out.\""],
                        cross: ["\"{DL} was struggling after the breakup.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} tell you that day?", "\"That {VL} had agreed to talk after work and maybe they'd drive to the mountains like they used to. {DL} was hopeful.\""),
                            .direct("Has {DL} ever been violent?", "\"Never. {DL} is the gentlest person in our family.\""),
                            .cross("{DL} had been struggling since the breakup?", "\"Badly. Not sleeping, not eating.\""),
                            .cross("{DL} had talked about not wanting to live?", "\"Once. I told {DL} to see somebody.\"")
                        ])
        ],
        prosecutionTheory: ["{D} drove {V} across state lines for five hours with the doors locked and {V.his} phone in {DL}'s door, threatening a bridge. That's kidnapping for the purpose of terrorizing."],
        defenseTheory: ["{VL} chose to get in, walked into a rest stop alone and walked back out. This was a painful, desperate breakup conversation, not a kidnapping."],
        aggravating: ["{DL} threatened to kill {VL}"],
        mitigating: ["No prior criminal record", "{DL} was in emotional crisis"],
        victimImpacts: ["{V}: \"I don't drive over bridges anymore. I moved apartments twice.\""],
        allocutions: ["\"I scared {VL}, and I'm sorry. I wanted one more chance to talk. I would never have hurt {VL}.\""],
        guiltyTruths: ["{DL}'s journal, found later, described the bridge as 'the plan if {VL} says no.'"],
        innocentTruths: ["The rest-stop attendant later said {VL} told them the drive was 'a fight, not a kidnapping.'"],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "6:05 a.m.: {VL} texts {DL} to come by after work."),
                       (0, "3:10 p.m.: {VL} gets into {DL}'s car. 5:20 p.m.: rest stop. 8:15 p.m.: {VL} flees at a Virginia gas station."),
                       (1, "{DL} extradited to North Carolina."),
                       (20, "{DL} charged with second-degree kidnapping.")],
            howIdentified: "{VL} identified {DL}, and {D.he} was arrested at the scene.",
            notDone: ["The rest-stop attendant was never interviewed."],
            defendantExam: [
                .direct("Why did you drive so far?", "\"We started driving and talking and I didn't want it to end. I kept thinking if we got to the mountains, {VL} would remember.\""),
                .direct("Did you take {VL}'s phone?", "\"It was ringing and {VL}'s friend kept calling. I took it and put it in my door so we could talk. I should have given it back.\""),
                .direct("What did you mean on the bridge?", "\"I said it would be easy to just disappear. I meant me. I was in a bad place. I'm getting help now.\""),
                .cross("You pulled out before the door was closed.", "\"I don't remember it that way. I remember the door shutting.\""),
                .cross("{VL} asked to go home and you kept driving.", "\"{VL} said it more than once. I kept saying just a little longer.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Did {VL} seem like a kidnapping victim to you?\"",
                                  answer: "\"Absolutely.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation; improper opinion", shouldSustain: true,
                                  explanation: "The trooper can describe {VL}'s condition, not offer a conclusion on whether a crime occurred.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "Locked doors, a phone taken, five hours, and a bridge. {D} held {V} to terrorize {V.him}.",
            defenseOpening: "{VL} invited {DL} to talk, got in willingly, and walked back to the car from a rest stop. That's not kidnapping.",
            prosecutionClosing: "Consent to talk in a parking lot isn't consent to a five-hour drive with a threat.",
            defenseClosing: "The State has to prove restraint beyond a reasonable doubt. The rest stop shows otherwise.",
            victim: VictimFacts(relationship: "A former partner of the defendant.")
        )
    )

    // MARK: - 35. The neighbor's mailbox (identity theft)

    static let neighborsMailbox = CaseTemplate(
        key: "story.neighborsMailbox", category: .whiteCollar,
        headlines: ["Neighbor Charged in Identity Theft of Retiree", "Credit Cards in a Shared Mailbox"],
        primaryLaw: "identityTheft", lesserLaw: nil, threshold: 3, lesserThreshold: 1,
        specification: "Knowingly used identifying information of {V} to open credit accounts and obtain goods.",
        secondary: [
            SecondaryCharge(lawID: "identityTheft", specification: "Used {V}'s identifying information to open a second store credit account.", chance: 1.0, threshold: 3),
            SecondaryCharge(lawID: "identityTheft", specification: "Used {V}'s identifying information to open a third credit card account.", chance: 1.0, threshold: 3),
            SecondaryCharge(lawID: "cardFraud", specification: "Used credit cards issued in {V}'s name to buy $23,000 in electronics.", chance: 1.0, threshold: 2),
            SecondaryCharge(lawID: "misdLarceny", specification: "Stole mail addressed to {V} from the cluster mailbox.", chance: 1.0, threshold: 1)
        ],
        ageRange: 24...40, occupations: ["online reseller"], hasVictim: true,
        summaries: [
            "{V}, 79, lives in a duplex on {STREET} in {HOOD}, sharing a cluster mailbox with {D}, who lives next door and resells electronics online. Over four months, five credit cards were opened in {VL}'s name and used to buy $23,000 in laptops, gaming consoles, and phones, delivered to the cluster box or to a locker at a nearby store. {DL} sold more than thirty of those same models online during those months. {DL} says {D.he} buys inventory in bulk from liquidation sales, and that a mail carrier substitute that season was later fired for mail theft."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Credit Applications", "Five cards opened online in {VL}'s name, all listing a phone number registered to a prepaid account bought at the store where {DL} shops."),
            E(.digital, 3, "Matching Resales", "Serial numbers on four laptops {DL} sold online match laptops bought with the fraudulent cards.", .search),
            E(.video, 2, "Locker Pickup", "Store video of a person in a hooded jacket and mask collecting three packages from a locker; height and build similar to {DL}'s.")
        ],
        defenseEvidence: [
            E(.document, 3, "Liquidation Receipts", "Invoices from two liquidation auctions showing {DL} bought hundreds of electronics, including the same laptop models, during the same months."),
            E(.document, 2, "Fired Mail Carrier", "A substitute mail carrier on the route that season was fired for stealing mail from cluster boxes and is under federal investigation."),
            E(.document, 1, "Phone Purchase", "The prepaid phone used on the applications was bought with cash; no video of the purchase survived.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Identity theft victim",
                        direct: ["\"I never opened a credit card in my life.\""],
                        cross: ["\"{DL} always helped me with my groceries.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did you find out?", "\"A collection agency called about a balance on a card I'd never heard of. Then another. I thought it was a scam call. It was real.\""),
                            .direct("What has it done to you?", "\"My credit is ruined at seventy-nine. I couldn't refinance my roof. I check my mailbox three times a day now, and I hate going near it.\""),
                            .cross("{DL} helped you carry groceries and fixed your Wi-Fi?", "\"Many times. That's what hurts so much, if it was {DL}.\""),
                            .cross("You'd had trouble with missing mail that season?", "\"Some of my bills never came. I thought it was the post office.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"Four of the stolen laptops were sold by {DL}.\""],
                        cross: ["\"{DL} buys the same models in bulk legally.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did the investigation lead to {DL}?", "\"The fraud cards bought specific laptops with recorded serial numbers. Four of those serial numbers were later sold on {DL}'s online store.\""),
                            .direct("What about the prepaid phone?", "\"Bought for cash at a store {DL} visits weekly. We couldn't get video of the purchase.\""),
                            .cross("{DL} buys hundreds of the same laptops legitimately at liquidation auctions?", "\"The invoices show that.\""),
                            .cross("A liquidator could sell returned stolen goods without knowing?", "\"It happens.\""),
                            .cross("You didn't look into the substitute carrier fired for mail theft on that route?", "\"I learned about that after charging {DL}.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Liquidation auction manager",
                        direct: ["\"We sell returned and unclaimed electronics by the pallet.\""],
                        cross: ["\"Some returns turn out to be fraud purchases.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What does {DL} buy from you?", "\"Pallets of customer returns and unclaimed packages from big-box stores. {DL} is a regular, maybe twice a month.\""),
                            .direct("Could laptops bought with stolen cards end up in your pallets?", "\"Absolutely. Fraudsters return things for store credit all the time, and stores don't check serials before liquidating.\""),
                            .cross("You can't say these four laptops came through you?", "\"Not without the serials on our manifests, and we don't track serials.\"")
                        ])
        ],
        prosecutionTheory: ["{D} had access to {V}'s mail, sold four of the stolen laptops, and was the obvious beneficiary."],
        defenseTheory: ["{DL} buys the same laptops by the pallet from liquidators that resell fraud returns. A carrier fired for mail theft worked that route. The State never traced the phone."],
        aggravating: ["The victim was elderly"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I trusted my neighbor. Whoever did this took my good name at the end of my life.\""],
        allocutions: ["\"I would never steal from {VL}. I help {VL} with everything.\""],
        guiltyTruths: ["The prepaid phone was later found in a bag of {DL}'s shipping supplies."],
        innocentTruths: ["The fired carrier was federally indicted for opening cards in the names of twelve people on the route."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-120, "First card opened in {VL}'s name."),
                       (0, "Collection agency contacts {VL}; report filed."),
                       (40, "Serial numbers traced to {DL}'s online sales."),
                       (55, "{DL} charged with identity theft.")],
            howIdentified: "Serial numbers of laptops bought with the fraudulent cards matched {DL}'s online sales.",
            notDone: ["The substitute mail carrier was never investigated.", "The liquidation manifests were never compared."],
            defendantExam: [
                .direct("Where did you get those four laptops?", "\"Liquidation pallets. I buy forty, sixty at a time. I can't tell you which pallet each came from.\""),
                .direct("Did you ever take {VL}'s mail?", "\"No. I've brought {VL} mail that went to my box by mistake. I handed it right over.\""),
                .cross("You had access to the cluster box every day.", "\"Everyone on the street did. And the carrier.\""),
                .cross("The masked person at the locker is your height and build.", "\"And half the people in this county.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Isn't the real thief the fired mail carrier?\"",
                                  answer: "\"I don't know that.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "The question argues the defense theory rather than eliciting facts.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Access to {V}'s mail and four stolen laptops in {D}'s store.",
            defenseOpening: "Laptops from liquidation pallets, a mail thief on the route, and no proof {DL} ever touched {VL}'s identity.",
            prosecutionClosing: "The laptops tie it to {DL}.",
            defenseClosing: "The laptops tie it to a liquidator, not to a crime by {DL}."
        )
    )

    // MARK: - 36. The wrong door (shots at officers during a raid)

    static let wrongDoor = CaseTemplate(
        key: "story.wrongDoor", category: .violent,
        headlines: ["Homeowner Shoots Officer During Late-Night Raid", "Officers Hit the Wrong House?"],
        primaryLaw: "awdwikisi", lesserLaw: "awdwisi", threshold: 2, lesserThreshold: 1,
        specification: "Assaulted {OFF} with a firearm, with intent to kill, inflicting serious injury.",
        ageRange: 30...55, occupations: ["long-haul truck driver"], hasVictim: false,
        summaries: [
            "At about {TIME} on {DATE}, a narcotics team executed a no-knock search warrant at a house on {STREET} in {HOOD}. The target, a suspected dealer, had moved out two months earlier; {D}, a truck driver home between runs, had moved in. Officers rammed the door. {DL}, woken in the dark, grabbed a pistol from the nightstand and fired as the first officer came down the hall, hitting {OFF} in the thigh. {DL} says {D.he} thought it was a home invasion. Officers say they announced \"Police, search warrant\" as they breached."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Camera", "Lead officer's camera: the door is rammed, and within about two seconds the team shouts \"Police! Search warrant!\" as they enter. Four seconds later, two shots from down the hall."),
            E(.forensic, 3, "Officer's Injuries", "A gunshot wound to the thigh that nicked the femoral artery; {OFF} needed two surgeries and is on desk duty."),
            E(.statement, 2, "Neighbor's Statement", "A neighbor says officers were \"yelling police loud enough to wake the whole street.\"")
        ],
        defenseEvidence: [
            E(.document, 3, "Stale Warrant", "The warrant relied on a controlled buy nine weeks earlier at the address, from a person who moved out seven weeks before the raid. Officers didn't check utility records."),
            E(.statement, 2, "911 Call", "During the raid, {DL}'s phone dialed 911: \"Somebody's breaking in, I fired, I have a gun, please send police!\""),
            E(.document, 2, "Defendant's Background", "No criminal record, a concealed carry permit, and a commercial driver's license with no violations.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "Wounded narcotics officer",
                        direct: ["\"We announced police before I was ever in the hallway.\""],
                        cross: ["\"We had the wrong person.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What happened when you entered?", "\"We breached, I went in second, and we were all yelling 'Police, search warrant!' I had a vest that says POLICE in white letters. I turned into the hallway and saw a muzzle flash and went down.\""),
                            .direct("How has this affected you?", "\"Two surgeries, eight months of physical therapy. I may not go back to the street.\""),
                            .cross("The person you were looking for had moved out seven weeks before?", "\"I learned that afterward.\""),
                            .cross("Shouting 'police' while a door is being rammed in at 5 a.m., to someone asleep, may not be heard clearly?", "\"We were loud.\""),
                            .cross("It was dark in the hallway; your vest lettering was on your chest, behind your rifle?", "\"Partly behind it.\""),
                            .cross("{DL} called 911 during the raid?", "\"I've heard that recording.\"")
                        ]),
            WitnessSeed(name: nil, role: "Narcotics team sergeant",
                        direct: ["\"The warrant was signed by a magistrate.\""],
                        cross: ["\"We didn't check utilities.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Why a no-knock warrant?", "\"The target was believed to keep firearms and had a history of fleeing. A magistrate approved no-knock entry.\""),
                            .direct("Was the team announced?", "\"Every member yelled 'Police, search warrant' as we breached.\""),
                            .cross("You didn't check whether the target still lived there?", "\"Our information was nine weeks old. We should have checked.\""),
                            .cross("You found no drugs and no evidence of any crime in the house?", "\"Nothing at all.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Use-of-force and tactics expert",
                        direct: ["\"A sleeping homeowner can't process an announcement in two seconds.\""],
                        cross: ["\"Officers did announce.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does research say about dynamic entries at night?", "\"A person woken by a door being smashed is in a startle state for several seconds. Shouting is heard as noise, not words. That's why wrong-house raids so often end in gunfire.\""),
                            .direct("What did {DL} do after firing?", "\"Called 911 and reported being a victim. That is the behavior of someone who believes they're being robbed.\""),
                            .cross("The team did announce?", "\"They shouted while breaching, which isn't the same as giving someone a chance to hear.\"")
                        ])
        ],
        prosecutionTheory: ["Officers shouted 'police' as they entered, wearing marked vests. {D} fired at an officer in the hallway and nearly killed {OFF}."],
        defenseTheory: ["Police rammed the wrong house at 5 a.m. on a stale warrant. {DL}, asleep, believed {D.he} was being robbed, fired in self-defense, and called 911 for help."],
        aggravating: ["The victim was a law enforcement officer performing official duties"],
        mitigating: ["{DL} had no criminal record", "{DL} called 911 believing {D.he} was the victim"],
        victimImpacts: ["{OFF}: \"I don't hate {DL}. I hate that my career might be over because of bad information.\""],
        allocutions: ["\"I would never shoot a police officer knowingly. I thought I was going to die in my own bed.\""],
        guiltyTruths: ["A neighbor's doorbell camera later showed officers knocking and announcing for ten seconds before ramming."],
        innocentTruths: ["The body camera's audio, enhanced later, shows the 'police' shouts began only after the door was already down."],
        moods: [.divided], doctrines: ["selfDefense", "searchSeizure"],
        extras: ["TIME": ["5:04 a.m."]],
        story: StoryExtras(
            timeline: [(-63, "Controlled buy at the address from the target."),
                       (-49, "Target moves out; {DL} moves in."),
                       (-1, "No-knock warrant signed by a magistrate."),
                       (0, "5:04 a.m.: entry; two shots fired; {OFF} wounded. 5:04 a.m.: {DL}'s phone calls 911."),
                       (2, "{DL} charged with assault with a deadly weapon on an officer.")],
            howIdentified: "{DL} was the shooter, inside the home.",
            notDone: ["Officers didn't verify who lived at the address before the raid."],
            defendantExam: [
                .direct("What happened?", "\"A crash like a car hit the house. Screaming. Flashlights. I grabbed my pistol and fired at the shape coming down my hallway. I dialed 911 with my other hand.\""),
                .direct("Did you hear 'police'?", "\"I heard yelling. I didn't hear words. I was asleep thirty seconds before.\""),
                .direct("What did you think when you learned it was police?", "\"That I'd almost killed a cop doing their job at the wrong house. I've been sick about it.\""),
                .cross("Officers say they announced five, six times.", "\"Maybe they did. I didn't hear it over the door coming down.\""),
                .cross("The vest said POLICE.", "\"It was dark. I saw a flashlight and a rifle.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Your team has hit the wrong house before, hasn't it?\"",
                                  answer: "\"Once, three years ago.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance and prior acts", shouldSustain: false,
                                  explanation: "Prior wrong-address raids by the same team are relevant to the reliability of the team's procedures and the reasonableness of {DL}'s fear.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Officers announced, wore marked vests, and {D} fired anyway, nearly killing {OFF}.",
            defenseOpening: "The wrong house, a stale warrant, and {DL}, woken by the door coming down. {DL} called 911 because {D.he} thought {D.he} was the victim.",
            prosecutionClosing: "A reasonable person hears 'police.'",
            defenseClosing: "A reasonable person asleep doesn't, and the State's own error put everyone in that hallway."
        )
    )

    // MARK: - 37. The last pill (death by distribution)

    static let lastPill = CaseTemplate(
        key: "story.lastPill", category: .drugs,
        headlines: ["Friend Charged in Fentanyl Death", "Death by Distribution Case Tests Causation"],
        primaryLaw: "deathByDistribution", lesserLaw: "saleSchedII", threshold: 5, lesserThreshold: 3,
        specification: "Sold a pill containing fentanyl to {V}, whose ingestion of it caused {V.his} death.",
        secondary: [
            SecondaryCharge(lawID: "saleSchedII", specification: "Sold two pills containing fentanyl to {V} for $40.", chance: 1.0, threshold: 4)
        ],
        ageRange: 21...30, occupations: ["restaurant server"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 24, was found dead in {V.his} apartment in {HOOD}. Beside {VL} were an empty pill bag and a rolled-up dollar bill. Texts show {D}, a longtime friend and fellow server, sold {VL} two pills the night before for $40, which {DL} described as \"perc 30s.\" The pills were counterfeit and contained fentanyl. {VL}'s toxicology also showed alcohol and a sedative prescribed to {V.him}. {DL} says {D.he} was passing along pills from {D.his} own supply, didn't know they had fentanyl, and that {VL}'s mix of drugs, not {DL}'s pill, caused the death."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Text Messages", "{VL}: \"u got 2 of the perc 30s still?\" {DL}: \"ya 40 for both, come by after close.\" The night before {VL} died.", .search),
            E(.forensic, 3, "Toxicology", "Fentanyl at 14 ng/mL, a level often fatal by itself; also alcohol at 0.06 and a therapeutic level of a prescribed sedative."),
            E(.physical, 2, "Pills from {DL}", "Three more identical blue pills in {DL}'s apron at work, all containing fentanyl.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Defendant's Own Use", "{DL} has a documented opioid use disorder and bought the pills for {D.his} own use from an online source."),
            E(.forensic, 2, "Mixed Drug Death", "The medical examiner listed the cause as \"combined toxicity of fentanyl, alcohol, and alprazolam.\""),
            E(.document, 1, "No Profit Pattern", "No evidence {DL} sold to anyone else; the $40 matched what {DL} paid.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"The fentanyl alone was enough to kill.\""],
                        cross: ["\"I listed combined toxicity.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What killed {VL}?", "\"Respiratory depression from fentanyl, made worse by alcohol and a sedative.\""),
                            .direct("Was the fentanyl level alone fatal?", "\"At 14 nanograms per milliliter, in someone without high tolerance, it's in the range we routinely see as fatal by itself.\""),
                            .direct("Would {VL} have died without the fentanyl?", "\"No. The alcohol and sedative levels were modest. Without the fentanyl, I would not expect death.\""),
                            .cross("You certified the cause as combined toxicity?", "\"Yes, because all three contributed.\""),
                            .cross("The sedative and alcohol made the fentanyl more dangerous?", "\"They did.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Overdose task force detective",
                        direct: ["\"The texts are a sale.\""],
                        cross: ["\"{DL} was a user, not a dealer.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find?", "\"The texts, the empty bag matching the bag in {DL}'s apron, and three more pills, all fentanyl.\""),
                            .direct("What did {DL} say?", "\"That {DL} sold {VL} two pills at cost and thought they were real oxycodone.\""),
                            .cross("{DL} had a documented opioid addiction?", "\"Years of it. It's in {D.his} medical records.\""),
                            .cross("No evidence {DL} sold to anyone but {VL}?", "\"None we found.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Addiction specialist",
                        direct: ["\"People who share pills at cost are usually users, not dealers.\""],
                        cross: ["\"Sharing still spreads fentanyl.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What is your work?", "\"I treat people with opioid addiction.\""),
                            .direct("What's typical of people who sell a few pills to friends?", "\"They're almost always addicted themselves, splitting what they buy to afford their own supply. They usually believe the pills are what the label says.\""),
                            .direct("Does {DL}'s situation fit that pattern?", "\"Yes. A documented opioid use disorder, a few pills, and a price that matched what {D.he} paid.\""),
                            .cross("Sharing pills at cost still spreads fentanyl, doesn't it?", "\"Yes. It does.\""),
                            .cross("It doesn't matter to {VL}'s family whether {DL} was a dealer or a user?", "\"No. It matters to the law.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sold {V} fentanyl pills. Without the fentanyl, {VL} would be alive. That is death by distribution."],
        defenseTheory: ["{DL} was an addict sharing pills at cost with a friend, believing they were oxycodone. And {VL}'s own sedative and alcohol were part of what killed {V.him}."],
        aggravating: [],
        mitigating: ["{DL} has an opioid use disorder and was not selling for profit", "No prior criminal record"],
        victimImpacts: ["{VL}'s parent: \"Two kids who worked together, laughed together. One is gone and one is going to prison. Find whoever is making these pills.\""],
        allocutions: ["\"{VL} was my best friend at work. I'd take those pills back in a heartbeat. I'm in treatment now.\""],
        guiltyTruths: ["Messages later showed {DL} selling to six other coworkers at a markup."],
        innocentTruths: ["{DL}'s online supplier was later indicted for selling counterfeit pills advertised as pharmacy-grade."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-1, "10:14 p.m.: texts arranging two pills for $40. 11:20 p.m.: {VL} picks up at the restaurant."),
                       (0, "{VL} found dead at home."),
                       (2, "Search of {DL}'s apron at work; three pills found."),
                       (40, "Toxicology and laboratory results confirm fentanyl."),
                       (45, "{DL} charged with death by distribution.")],
            howIdentified: "Text messages on {VL}'s phone.",
            notDone: ["The online supplier was never identified."],
            defendantExam: [
                .direct("Why did you sell {VL} the pills?", "\"{VL} asked. I had some. I charged what I paid. I thought they were real percs. I'd been taking the same ones for weeks.\""),
                .direct("Did you know they had fentanyl?", "\"No. If I'd known I'd have flushed every one, starting with mine.\""),
                .cross("You took money for them.", "\"Forty dollars. What I paid.\""),
                .cross("You knew pills from online sources are often fake.", "\"I'd heard. I didn't think it would be mine.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"So {VL}'s own choices killed {V.him}, didn't they?\"",
                                  answer: "\"Every drug contributed.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "The question argues a conclusion to the witness instead of asking for facts.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Two pills for forty dollars, and fentanyl enough to kill.",
            defenseOpening: "An addict sharing pills with a friend at cost, both believing they were real. And a death the medical examiner calls combined.",
            prosecutionClosing: "Without the fentanyl, {VL} lives. That's causation.",
            defenseClosing: "The law aims at dealers. {DL} is a sick friend."
        )
    )

    // MARK: - 38. The alibi witness (perjury)

    static let alibiWitness = CaseTemplate(
        key: "story.alibiWitness", category: .publicOrder,
        headlines: ["Alibi Witness Charged With Perjury", "Video Contradicts Sworn Testimony"],
        primaryLaw: "perjury", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Willfully and falsely testified under oath, in a material matter, that {ALT} was with {DL} on the night of a robbery.",
        ageRange: 22...40, occupations: ["hair stylist"], hasVictim: false,
        summaries: [
            "Last year {ALT} was tried for an armed robbery in {CITY}. {D}, {ALT}'s partner, testified under oath that the two were at home watching a movie all night. The jury hung. Before the retrial, a detective found security video from a casino two hours away showing {DL} at a slot machine at 10:40 p.m. that night, alone. {DL} is now charged with perjury. {DL} says {D.he} confused the night with another, testified honestly, and was coached by no one."
        ],
        prosecutionEvidence: [
            E(.video, 4, "Casino Video", "{DL} at a slot machine from 10:12 p.m. to 11:50 p.m. on the night of the robbery, two hours from {CITY}, swiping a players' card in {DL}'s name."),
            E(.document, 3, "Trial Transcript", "{DL}: \"I'm certain. We were home all night. We watched a movie and I fell asleep on the couch around midnight.\""),
            E(.digital, 2, "Jail Calls", "Weeks before {ALT}'s trial, {ALT.he} told {DL} on a recorded jail call: \"Remember, it was movie night.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Similar Nights", "Bank records show {DL} and {ALT} rented movies on three other weekend nights that month."),
            E(.document, 2, "Gambling Disorder", "{DL} is in treatment for a gambling disorder and says {D.he} hid casino trips from everyone."),
            E(.document, 1, "Original Detective's Notes", "The first detective never asked {DL} about that specific date before trial.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{DL} was two hours away at a casino.\""],
                        cross: ["\"I don't know whether {DL} remembered the night correctly.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you find the casino video?", "\"Before the retrial I ran {DL}'s name through the casinos' players' card systems. A card in {DL}'s name was used that night. The casino pulled video.\""),
                            .direct("What did the jail calls show?", "\"{ALT} telling {DL}, three weeks before trial, 'Remember, it was movie night.' {D.He} said 'I know, I know.'\""),
                            .cross("They had movie nights three other weekends that month?", "\"The rental records show that.\""),
                            .cross("'Remember it was movie night' could be a reminder of an honest belief?", "\"It could be. In my experience, it wasn't.\"")
                        ]),
            WitnessSeed(name: nil, role: "Casino surveillance supervisor",
                        direct: ["\"The card and the face match.\""],
                        cross: ["\"I can't say what {DL} remembered.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What is your job?", "\"I run the casino's surveillance room. We keep video of the gaming floor and a record of every players' card swipe.\""),
                            .direct("How do you know it's {DL}?", "\"The players' card in {DL}'s name, and the face on our camera, which matches the ID scanned when the card was issued.\""),
                            .direct("How long was {DL} at the machine that night?", "\"From 10:12 to 11:50 p.m., by the card records, and the video matches.\""),
                            .cross("You were only asked to pull that one night, not {DL}'s other visits?", "\"Just that one night.\""),
                            .cross("You can't say anything about {DL}'s memory?", "\"My cameras record where people stand, not what they remember.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Gambling addiction counselor",
                        direct: ["\"People with gambling disorder hide and blur their casino trips.\""],
                        cross: ["\"Hiding is lying.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What is your work?", "\"I counsel people in treatment for gambling disorder.\""),
                            .direct("How does gambling disorder affect memory of these trips?", "\"Patients often keep trips completely secret, even from themselves. Nights run together. Many genuinely can't say which weekend they went.\""),
                            .direct("Is it common for patients to hide trips from their partners?", "\"Very common. Secrecy is one of the main signs of the disorder.\""),
                            .cross("Hiding trips from family is lying to them?", "\"It's a form of lying, yes. It's also a symptom.\""),
                            .cross("You can't tell this jury what {DL} actually remembered when {D.he} testified?", "\"No. I can't see inside anyone's memory.\"")
                        ])
        ],
        prosecutionTheory: ["{D} swore {ALT} was home with {DL} all night. {DL} was two hours away at a casino, and {ALT} had told {DL} what to say."],
        defenseTheory: ["{DL} hid gambling from everyone, even in {D.his} own memory. Several movie nights blurred together. A false memory isn't perjury; perjury requires knowing falsehood."],
        aggravating: ["The false testimony was given to secure an acquittal in a violent felony trial"],
        mitigating: ["No prior criminal record", "{DL} is in treatment for a gambling disorder"],
        allocutions: ["\"I believed what I said. I've learned how much my addiction made me lie, even to myself.\""],
        guiltyTruths: ["A text from {DL} to a friend the night of the robbery read: \"at the casino again, don't tell {ALT}.\""],
        innocentTruths: ["Another jail call showed {DL} asking {ALT}, 'Was that the night of the casino or movie night? I can't remember.'"],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-400, "Night of the robbery: {DL}'s players' card used at a casino from 10:12 to 11:50 p.m."),
                       (-120, "Jail call: 'Remember, it was movie night.'"),
                       (-90, "{DL} testifies at {ALT}'s trial; mistrial."),
                       (-20, "Detective finds the casino video."),
                       (0, "{DL} charged with perjury.")],
            howIdentified: "Casino records contradicted {DL}'s sworn testimony.",
            notDone: ["{DL}'s other casino trips that month weren't reviewed."],
            defendantExam: [
                .direct("Did you lie at {ALT}'s trial?", "\"No. I believed it. We had movie nights almost every weekend. I hid my casino trips from {ALT} and everyone. I'd half erased them myself.\""),
                .direct("What about 'remember, it was movie night'?", "\"{ALT} said it, and I said I know, because I thought I did know.\""),
                .cross("You were certain on the stand.", "\"I was. I was wrong.\""),
                .cross("You swiped a card in your own name.", "\"Because I didn't think anyone would ever look.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"Didn't the original detective coach {DL} on dates?\"",
                                  answer: "\"I have no knowledge of that.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Assumes facts not in evidence", shouldSustain: true,
                                  explanation: "Nothing in evidence suggests coaching; the question presumes a fact without a basis.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Under oath, {D} said 'home all night.' The casino video says otherwise.",
            defenseOpening: "A false memory from a hidden addiction isn't a knowing lie.",
            prosecutionClosing: "The jail call shows the story was rehearsed.",
            defenseClosing: "The State must prove {DL} knew it was false.",
            family: "In a long-term relationship, no children."
        )
    )
}
