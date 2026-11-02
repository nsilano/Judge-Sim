import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAJ: [CaseTemplate] = [sweepstakesParlor, tobaccoBarnFire, fireDeptFunds, cattleAuction, bouncerFlashlight]

    // MARK: - The sweepstakes parlor (a robbery with a BB pistol)

    static let sweepstakesParlor = CaseTemplate(
        key: "story.sweepstakesParlor", category: .robbery,
        headlines: ["Clerk Robbed at Gunpoint in Sweepstakes Parlor", "Robbery Suspect's Gun Was a BB Pistol, Lawyer Says"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 7, lesserThreshold: 5,
        specification: "Took $1,840 in cash from the person and presence of {V}, an employee of Lucky 7 Sweepstakes, by the use and threatened use of a dangerous weapon, a black pistol, whereby {V}'s life was endangered and threatened, on {DATE}.",
        ageRange: 19...40, occupations: [], hasVictim: true,
        summaries: [
            "Just after 1 a.m. on {DATE}, a man in a gray hoodie walked into Lucky 7 Sweepstakes on {STREET} in {HOOD}, pointed a black pistol at the clerk, {V}, and said, \"Drawer. Now.\" {V} handed over $1,840. Deputies stopped {D} eleven minutes later two miles away and found $1,790 in a sock in the console and a black pistol under the seat. The pistol is a Daisy BB pistol made to look like a Glock, with the orange tip painted black. {DL} admits nothing. The defense says a BB pistol, unloaded when found, isn't a dangerous weapon, and the State has to prove {V}'s life was actually endangered."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Parlor Camera", "A man in a gray hoodie points a black pistol at {V} across the counter; {V} empties the drawer with shaking hands."),
            E(.physical, 3, "Cash and Pistol", "$1,790 in a sock in the console; a Daisy BB pistol under the driver's seat, orange tip painted black, the CO2 cartridge spent.", .search),
            E(.document, 2, "Stop Report", "The car matched {V}'s description of a silver Altima; stopped eleven minutes after the robbery.")
        ],
        defenseEvidence: [
            E(.document, 2, "Manufacturer's Specifications", "The pistol fires .177 steel BBs at 410 feet per second when charged; it was empty when seized."),
            E(.statement, 1, "Face Covering", "The robber's hood and mask hid the face; the camera never shows it.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Sweepstakes parlor clerk",
                        direct: ["\"I thought I was going to die over a cash drawer.\""],
                        cross: ["\"I never saw a face.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened when the man came in?", "\"He walked straight to the counter, pulled the gun out of his hoodie, and pointed it at my chest. He said 'Drawer. Now.'\""),
                            .direct("Did you think the gun was real?", "\"Yes. It looked like the one my cousin carries. I wasn't going to find out.\""),
                            .direct("How have you been since?", "\"I quit. I can't work nights anymore.\""),
                            .cross("You never saw his face.", "\"He had a mask under the hood. I saw the gun.\""),
                            .cross("You told deputies he was 'about six feet.' {DL} is five-eight.", "\"He was standing over me. Everybody looks tall with a gun.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's detective",
                        direct: ["\"The cash, the car, and the pistol, eleven minutes later.\""],
                        cross: ["\"It was a BB pistol.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find in the car?", "\"$1,790 rolled in a sock in the console, a gray hoodie on the back seat, and the pistol under the driver's seat.\""),
                            .direct("Tell the jury about the pistol.", "\"A Daisy BB pistol built to look like a Glock 17. The orange safety tip had been painted black.\""),
                            .direct("Can a BB pistol hurt someone?", "\"At close range it can put out an eye. Swung, it's a pound and a half of metal.\""),
                            .cross("It was empty when you found it.", "\"The CO2 was spent. We don't know about earlier that night.\""),
                            .cross("No fingerprints on the drawer.", "\"He never touched it. {V} handed him the money.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Firearms examiner retained by the defense",
                        direct: ["\"Empty, it can't fire anything.\""],
                        cross: ["\"Charged, it can blind someone.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Could this pistol have endangered anyone's life?", "\"Without a CO2 cartridge it's a toy that looks like a gun. With one, it's a BB gun. Neither one is a firearm.\""),
                            .direct("Why paint the tip?", "\"People do it to make them look real. That's about fear, not harm.\""),
                            .cross("Charged, at three feet, a BB to the eye?", "\"It could cause serious injury, yes.\""),
                            .cross("Swung as a club?", "\"Anything heavy can hurt someone.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pointed a pistol painted to look real at a clerk's chest and took the drawer. {V}'s fear was exactly what {D} wanted."],
        defenseTheory: ["Maybe a robbery, but not with a dangerous weapon. An empty BB pistol can't endanger a life. At most this is common law robbery, and the State still can't show it was {DL} under that mask."],
        aggravating: ["The defendant planned the offense", "The offense was committed for pecuniary gain"],
        mitigating: ["The defendant was suffering from a mental or physical condition that reduced culpability", "The defendant has accepted responsibility"],
        victimImpacts: ["\"I was putting myself through community college working nights. I had to drop my classes. I still see that gun when I close my eyes.\""],
        allocutions: ["\"I owed money to the wrong people. I never wanted to hurt anybody. That's why I took a BB gun.\"", "\"I didn't rob anybody. I was just driving home.\""],
        guiltyTruths: ["{DL}'s phone, searched later, held a photo of the painted pistol taken the afternoon before the robbery, with the caption \"looks real enough.\""],
        innocentTruths: ["{DL}'s roommate, arrested months later on another robbery, admitted borrowing {DL}'s car that night and stashing the money and pistol in it."],
        moods: [.wantsConviction], doctrines: ["lesserIncluded", "burdenOfProof", "eyewitnessID"],
        story: StoryExtras(
            timeline: [(0, "1:04 a.m.: robbery at Lucky 7 Sweepstakes."), (0, "1:15 a.m.: deputies stop {DL}'s silver Altima two miles away."), (1, "Search warrant for the parlor's camera system."), (3, "{V} views the pistol and says it looks like the one used.")],
            howIdentified: "A traffic stop eleven minutes after the robbery, in a car matching {V}'s description.",
            notDone: ["{V} was never shown a lineup.", "The hoodie was never tested for DNA.", "No one checked whether {DL} had a CO2 cartridge or BBs anywhere."],
            defendantExam: [
                .direct("Where were you that night?", "\"Driving home from my girlfriend's. I didn't know anything was in the car.\"", "\"I did it. I was in trouble with money, and I picked a BB gun so nobody would get hurt.\""),
                .direct("Whose pistol is it?", "\"It's mine. I bought it for target practice in the backyard.\""),
                .cross("You painted the orange tip black.", "\"It looked better.\""),
                .cross("$1,790 in a sock in your console, eleven minutes after a robbery.", "\"I can't explain that.\"", "\"Yes, sir.\""),
                .cross("You wanted the clerk to think it was real.", "\"Anybody would think it was real. That's the point of it.\"")
            ],
            prosecutionOpening: "A pistol painted to look like death, pointed at a clerk's chest.",
            defenseOpening: "An empty BB gun is not a dangerous weapon, and a mask is not an identification.",
            prosecutionClosing: "Money, hoodie, pistol, car, eleven minutes. And {V} believed the gun was real, because {DL} made it look real.",
            defenseClosing: "Even if you think {DL} was there, the State hasn't proved a dangerous weapon. That's common law robbery at most.",
            victim: VictimFacts(age: 22, occupation: "sweepstakes parlor clerk and community college student", relationship: "None; the clerk on duty", harm: ["No physical injury; quit the job and dropped out of classes"], restitution: 50, restitutionBasis: "the $50 never recovered"),
            time: "1:04 a.m.",
            family: "Single; lives with a roommate.",
            residence: "An apartment off {STREET} in {HOOD}",
            scene: "Lucky 7 Sweepstakes on {STREET} in {HOOD}"
        )
    )

    // MARK: - The tobacco barn (a fire for the insurance)

    static let tobaccoBarnFire = CaseTemplate(
        key: "story.tobaccoBarnFire", category: .property,
        headlines: ["Century-Old Tobacco Barn Burns on Family Farm", "Farmer Charged After Fire Investigator Finds Gasoline Trail"],
        primaryLaw: "burningBuildings", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Willfully and wantonly set fire to and burned a barn, a building used for curing tobacco and storing farm equipment, on {DATE}.",
        ageRange: 40...70, occupations: ["farmer", "farm equipment dealer", "feed store owner"], hasVictim: false,
        summaries: [
            "A 1920s log tobacco barn on {D}'s farm outside {HOOD} burned to the ground around 2 a.m. on {DATE}, along with a tractor and a hay baler inside. Six weeks earlier {D} had raised the barn's insurance from $40,000 to $185,000, listing it as \"historic.\" The farm was three payments behind on its equipment loan. The State fire investigator found a pour pattern across the dirt floor and a gas can melted near the doorway, and a lab found gasoline in the soil samples. {DL} says the barn had a wood stove for curing and an old wiring run, that the tractor always leaked fuel, and that {D.he} was asleep at home a mile away when the fire started."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Lab Report", "Gasoline identified in four of six soil samples from the barn floor, in a line from the doorway to the tractor."),
            E(.document, 3, "Insurance Records", "Coverage raised from $40,000 to $185,000 forty-four days before the fire; the agent's note reads \"customer insisted.\""),
            E(.document, 2, "Loan Records", "Three missed payments on the $140,000 equipment loan; a default notice mailed ten days before the fire.")
        ],
        defenseEvidence: [
            E(.document, 2, "Tractor Service Record", "A repair shop note from the spring: \"fuel line weeping, owner declined repair.\""),
            E(.document, 1, "Phone Location", "{DL}'s phone stayed at the farmhouse a mile away all night.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State fire investigator",
                        direct: ["\"A pour pattern doesn't come from a leak.\""],
                        cross: ["\"Fuel can leak and burn.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the fire start?", "\"Low, at the doorway, and it ran in a line across the floor to the tractor. That's what a pour looks like.\""),
                            .direct("Could the wood stove have started it?", "\"The stove is in the far corner, and that corner burned last. The fire moved toward it, not away.\""),
                            .direct("What about the wiring?", "\"The power to the barn was off at the panel. I checked the breaker.\""),
                            .cross("A leaking tractor puts gasoline on the floor.", "\"Under the tractor. Not in a line from the door.\""),
                            .cross("Burn patterns are interpretation.", "\"The lab results aren't.\"")
                        ]),
            WitnessSeed(name: nil, role: "Insurance agent",
                        direct: ["\"{DL} wanted the barn insured as historic, and wanted it right then.\""],
                        cross: ["\"It was a historic barn.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did the coverage go up?", "\"{DL} came in and said the barn was a historic structure and asked for $185,000. I told {D.him} the premium would triple. {D.He} said do it today.\""),
                            .direct("Had {DL} ever changed coverage before?", "\"Not in nineteen years.\""),
                            .cross("Barns like that are rare now.", "\"They are. That's what {D.he} said too.\""),
                            .cross("Some people insure what they love.", "\"Some people do.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's neighbor",
                        direct: ["\"That tractor leaked like a sieve.\""],
                        cross: ["\"I didn't see the fire start.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What do you know about the tractor?", "\"I borrowed it in April. It left a puddle of gas everywhere it sat. I told {DL} to fix it.\""),
                            .direct("What did {DL} say about the barn?", "\"That it was the last one like it in the county and {D.his} granddaddy built it.\""),
                            .cross("Did you know about the loan default?", "\"No.\""),
                            .cross("Did you see the fire start?", "\"No, I woke up to the sirens.\"")
                        ])
        ],
        prosecutionTheory: ["Behind on the loan and facing default, {D} quadrupled the coverage, then poured gasoline from the door to the tractor and lit it."],
        defenseTheory: ["An old barn, a leaking tractor, and a farmer asleep a mile away. The insurance change was pride in a family barn, not a plan."],
        aggravating: ["The offense was committed for pecuniary gain", "The defendant planned the offense"],
        mitigating: ["The defendant has a support system in the community", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"I'd never burn my granddaddy's barn. That barn was the farm.\"", "\"I was going to lose the farm. I thought I could save it. I was wrong.\""],
        guiltyTruths: ["A feed store receipt found in {DL}'s truck showed two gas cans bought the evening before the fire, though the farm's tractor ran on diesel at the pump."],
        innocentTruths: ["A farmhand fired the week before, arrested a year later for another barn fire, admitted setting this one for revenge."],
        moods: [.divided], doctrines: ["expertTestimony", "burdenOfProof", "characterEvidence"],
        story: StoryExtras(
            timeline: [(-44, "{DL} raises the barn's coverage to $185,000."), (-10, "Default notice mailed on the equipment loan."), (0, "About 2 a.m.: barn burns; volunteer fire department responds."), (2, "State fire investigator examines the scene and takes soil samples."), (30, "Lab finds gasoline in four of six samples.")],
            howIdentified: "The fire investigator's findings and the insurance records.",
            notDone: ["The farmhand fired the week before was never interviewed.", "No one checked the farm's road for tire tracks that night."],
            defendantExam: [
                .direct("Why did you raise the insurance?", "\"A man from the historical society said the barn was worth saving and I should protect it. So I did.\""),
                .direct("Where were you that night?", "\"Asleep. My phone was on the nightstand. The sirens woke me.\""),
                .cross("You were three payments behind and had a default notice.", "\"Farming's like that some years.\""),
                .cross("Gasoline in a line from the door to the tractor.", "\"That tractor leaked. I told everybody it leaked.\""),
                .cross("Your phone on a nightstand doesn't mean you were in the bed.", "\"I was in the bed.\"")
            ],
            prosecutionOpening: "A barn insured for four times its value, and a trail of gasoline to the tractor.",
            defenseOpening: "A family barn, a leaking tractor, and a fire nobody saw start.",
            prosecutionClosing: "Pride doesn't pour gasoline in a line. Debt does.",
            defenseClosing: "Motive isn't proof. Nobody puts {DL} in that barn at 2 a.m.",
            time: "about 2 a.m.",
            family: "Married; three grown children; the farm has been in the family four generations.",
            residence: "The family farmhouse outside {HOOD}",
            scene: "The tobacco barn on the family farm outside {HOOD}"
        )
    )

    // MARK: - The volunteer fire department's account

    static let fireDeptFunds = CaseTemplate(
        key: "story.fireDeptFunds", category: .whiteCollar,
        headlines: ["Volunteer Fire Department Treasurer Charged in $63,000 Theft", "Fire Department Fish Fry Money Went to Casino, Deputies Say"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Being the treasurer of the {HOOD} Volunteer Fire Department, a nonprofit corporation, fraudulently embezzled $63,400 entrusted to {D.him} in that capacity, between January and {DATE}.",
        ageRange: 35...65, occupations: ["bank teller", "insurance agent", "school bookkeeper", "auto parts store manager"], hasVictim: false,
        summaries: [
            "{D} kept the books for the {HOOD} Volunteer Fire Department for nine years, signing checks and depositing fish fry, raffle, and county money. When the department's new chief tried to buy a $12,000 set of turnout gear in the spring, the bank said the account held $814. An audit found $63,400 missing over fourteen months: cash from fundraisers never deposited and 41 checks written to {DL} marked \"reimbursement\" with no receipts. Casino records show {DL} spent $58,000 at a casino in Cherokee over the same months. {DL} says the chief and the board approved every reimbursement, that much of the money paid for supplies {D.he} bought with {D.his} own card, and that the department's records were a shoebox mess long before {D.he} took over."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Forensic Audit", "$63,400 unaccounted for: $21,600 in fundraiser cash never deposited and $41,800 in 41 checks to {DL} marked \"reimbursement\" with no receipts."),
            E(.document, 3, "Casino Records", "Player's card records show $58,000 in cash buy-ins by {DL} over the same fourteen months."),
            E(.document, 2, "Board Minutes", "No meeting minutes approving any reimbursement over $200.")
        ],
        defenseEvidence: [
            E(.document, 2, "Credit Card Statements", "$7,300 in charges at a restaurant supply store and a hardware store over the period, on {DL}'s personal card."),
            E(.statement, 1, "Old Books", "The prior treasurer's records were kept in a shoebox; the department was never audited before.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic accountant",
                        direct: ["\"The deposits stopped matching the events.\""],
                        cross: ["\"Some reimbursements may be real.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you find the missing cash?", "\"The department advertises every fish fry. I matched the sales sheets to the deposits. Eleven events, $21,600 in sales, nothing deposited.\""),
                            .direct("And the checks?", "\"Forty-one checks to {DL}, all signed by {DL}, all marked reimbursement. Not one receipt.\""),
                            .direct("Did the casino play line up?", "\"Buy-ins at Cherokee track the checks within a few days, month after month.\""),
                            .cross("{DL}'s card shows $7,300 at supply stores.", "\"It does. That's $7,300 of a $63,400 hole.\""),
                            .cross("The books were a mess before {DL}.", "\"They were sloppy. They weren't empty.\"")
                        ]),
            WitnessSeed(name: nil, role: "Fire chief",
                        direct: ["\"We had $814 and a truck that needed tires.\""],
                        cross: ["\"I signed a few things without reading them.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened when you tried to buy the gear?", "\"The bank said we had $814. Our turnout gear is past its date. Men are going into fires in coats that should've been thrown out.\""),
                            .direct("Did you approve reimbursements to {DL}?", "\"Small ones. Fifty dollars for ice. Not thousands.\""),
                            .cross("You signed blank checks for {DL} to fill in.", "\"A couple of times, when I was out of town. I trusted {D.him}.\""),
                            .cross("You never once asked to see a bank statement.", "\"No. I'm a firefighter, not an accountant.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Department board member",
                        direct: ["\"{DL} worked every fish fry for nine years.\""],
                        cross: ["\"We never approved those checks.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What kind of treasurer was {DL}?", "\"The kind who showed up at 4 a.m. to start the fryers and was the last one to leave.\""),
                            .direct("Did {DL} buy supplies for the department?", "\"All the time. Fish, oil, cups, the raffle prizes.\""),
                            .cross("$63,000 worth?", "\"No. Not anything like that.\""),
                            .cross("Did the board approve forty-one checks to {DL}?", "\"Not that I remember.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pocketed the fish fry cash and wrote {D.himself} checks with no receipts, and the money went to a casino while firefighters wore expired gear."],
        defenseTheory: ["A sloppy volunteer department with no controls, a treasurer who paid for supplies out of pocket, and a chief who signed blank checks. Bad bookkeeping isn't embezzlement."],
        aggravating: ["The defendant took advantage of a position of trust or confidence", "The offense involved an actual loss of more than $50,000"],
        mitigating: ["The defendant has made substantial or full restitution", "The defendant has a support system in the community"],
        victimImpacts: ["The fire chief reads: \"We bought new gear with a GoFundMe from people who'd already given at our fish fries. Folks in {HOOD} pay for that department twice now.\""],
        allocutions: ["\"I have a gambling problem. I'm in meetings now. I'll pay back every dime.\"", "\"I spent my own money on that department for nine years. I didn't steal from it.\""],
        guiltyTruths: ["{DL}'s text to a friend, found later, said \"I'll put it back before anyone looks, I always do.\""],
        innocentTruths: ["The department's prior treasurer, who kept a key to the cash box, was later found to have taken the fundraiser cash for years."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-420, "First unreceipted check to {DL}."), (-30, "New chief finds $814 in the account."), (0, "Last unreceipted check clears."), (20, "Board orders a forensic audit."), (75, "Audit completed; casino records subpoenaed.")],
            howIdentified: "The forensic audit and casino player's card records.",
            notDone: ["The prior treasurer was never asked about the cash box key.", "Not every reimbursement was checked against supply store receipts."],
            defendantExam: [
                .direct("Tell the jury about the reimbursements.", "\"I bought fish, oil, everything for the fry. I paid myself back. I should have kept receipts.\""),
                .direct("And the casino?", "\"I go. A lot. I'm not proud of it. That was my money.\"", "\"I have a problem. Some of it was the department's money. I meant to put it back.\""),
                .cross("$41,800 in checks and $7,300 in supply purchases.", "\"I didn't keep track.\""),
                .cross("Eleven fish fries and not one deposit.", "\"Some of that cash went to buying for the next one.\""),
                .cross("You signed every one of those checks to yourself.", "\"I was the treasurer.\"")
            ],
            prosecutionOpening: "Fish fry money and fire gear money, gone to a casino.",
            defenseOpening: "A shoebox of records and a treasurer who gave nine years.",
            prosecutionClosing: "Forty-one checks to {D.himself}, no receipts, and the casino buy-ins right behind them.",
            defenseClosing: "A department with no rules can't convict a volunteer for breaking them.",
            employer: "the {HOOD} Volunteer Fire Department (treasurer, unpaid)",
            family: "Married; two teenagers.",
            residence: "A house on {STREET} in {HOOD}"
        )
    )

    // MARK: - The livestock auction (selling cattle that weren't {D.his})

    static let cattleAuction = CaseTemplate(
        key: "story.cattleAuction", category: .whiteCollar,
        headlines: ["Neighbor's Cattle Sold at Livestock Auction, Farmer Says", "Man Charged After Selling 22 Head of Cattle He Didn't Own"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Knowingly and designedly, with intent to cheat and defraud, obtained $26,950 from the Hollis Livestock Market by falsely representing that {D.he} owned 22 head of cattle belonging to {V}, on {DATE}.",
        ageRange: 28...60, occupations: ["farmhand", "cattle hauler", "farmer"], hasVictim: true,
        summaries: [
            "{V} leased pasture next to {D}'s land and ran 40 head of black Angus there. On {DATE}, {D} hauled 22 of them to the Hollis Livestock Market and sold them in the Tuesday sale for $26,950, signing a form swearing the cattle were {D.his}. {V} noticed the herd short a week later. The cattle carried {V}'s ear tags, and the market's video shows {D} unloading them. {DL} says {V} owed {D.him} $31,000 for two years of hay, fencing, and feeding the cattle through a drought, and that {V} told {D.him} to \"sell what you need to make it right.\" {V} says no such conversation ever happened."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Sale Barn Records", "Consignment form signed by {DL} certifying ownership of 22 head; check for $26,950 cashed the next day."),
            E(.video, 2, "Sale Barn Video", "{DL} backs a stock trailer to the chute and unloads black Angus with yellow ear tags."),
            E(.document, 2, "Ear Tag Registry", "The tag numbers are registered to {V}'s herd.")
        ],
        defenseEvidence: [
            E(.document, 2, "Hay and Feed Ledger", "{DL}'s handwritten ledger: hay, fencing, and feed for {V}'s cattle, totaling $31,200 over two years, unpaid."),
            E(.digital, 2, "Text Message", "{V} to {DL}, during the drought: \"I'll make it right with you this fall, I promise.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Cattle owner",
                        direct: ["\"I never told {D.him} to sell anything.\""],
                        cross: ["\"I owed {D.him} something for hay.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you find out?", "\"I counted 18 head where there should've been 40. The sale barn manager called me when I asked around.\""),
                            .direct("Did you give {DL} permission to sell your cattle?", "\"Never. Those were my bred cows. You don't sell bred cows in September.\""),
                            .cross("You owed {DL} for two years of hay.", "\"Some. Not thirty thousand dollars. And not my cows.\""),
                            .cross("You texted 'I'll make it right with you this fall.'", "\"With money. When I sold my calves. Not with {D.him} hauling off my herd.\"")
                        ]),
            WitnessSeed(name: nil, role: "Livestock market manager",
                        direct: ["\"{D.He} signed that the cattle were {D.his}.\""],
                        cross: ["\"People sell for each other all the time.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What does the consignment form say?", "\"That the seller owns the animals free and clear. {DL} signed it at the window.\""),
                            .direct("What if someone is selling for another owner?", "\"They write the owner's name and we pay the owner. That's the rule.\""),
                            .cross("You didn't check the ear tags.", "\"We don't check every tag on a sale day.\""),
                            .cross("Neighbors sell for neighbors here.", "\"With the owner's name on the form.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Feed store owner",
                        direct: ["\"{DL} bought feed for those cows all through the drought.\""],
                        cross: ["\"I don't know what they agreed.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} buy that summer?", "\"Pallets of feed every week and round bales on credit. {D.He} told me it was for {V}'s cattle on the lease.\""),
                            .direct("Did {V} ever pay for that feed?", "\"Not at my counter.\""),
                            .cross("Did you hear {V} tell {DL} to sell the cattle?", "\"No.\""),
                            .cross("Did {DL} ever say {D.he} was going to?", "\"{D.He} said {D.he} was tired of waiting.\"")
                        ])
        ],
        prosecutionTheory: ["{D} hauled off {V}'s cattle, swore at the sale barn they were {D.his}, and cashed the check. A debt doesn't give anyone the right to lie for money."],
        defenseTheory: ["{D} fed those cattle through a drought for two years on {D.his} own credit. {V} told {D.him} to make it right. Selling them was settling a debt, not a fraud."],
        aggravating: ["The offense was committed for pecuniary gain"],
        mitigating: ["The defendant has made substantial or full restitution", "The defendant acted under strong provocation"],
        victimImpacts: ["\"Those were bred cows, my next two years of calves. I had to sell the rest to pay the lease.\""],
        allocutions: ["\"I fed those cows when nobody else would. I took what I was owed.\"", "\"I should've taken {V} to small claims court. I'm sorry.\""],
        guiltyTruths: ["The sale barn's office camera recorded {DL} telling a buyer, \"Owner's out of state, he won't miss them.\""],
        innocentTruths: ["{V}'s own brother later testified in a civil case that he heard {V} tell {DL} to \"sell what you need\" over the fence that August."],
        moods: [.divided], doctrines: ["burdenOfProof", "mistakeOfFact", "justification"],
        story: StoryExtras(
            timeline: [(-700, "{V} leases the pasture next to {DL}'s land."), (-90, "Drought; {DL} buys feed on credit for the herd."), (0, "Tuesday sale: {DL} sells 22 head for $26,950."), (7, "{V} finds the herd short and calls the sale barn."), (10, "{V} reports it to the sheriff.")],
            howIdentified: "The sale barn's consignment form and the ear tags.",
            notDone: ["No one asked {V}'s family about any conversation with {DL}.", "The feed bills were never totaled by the State."],
            defendantExam: [
                .direct("Why did you sell the cattle?", "\"Two years of hay and feed, and a drought. {V} said make it right. I made it right.\""),
                .direct("Why sign that they were yours?", "\"Because to me they were. I'd paid for every pound on them.\""),
                .cross("The form says you owned them free and clear.", "\"I didn't read the fine print.\""),
                .cross("You sold them in September, bred, at the bottom of the market.", "\"I needed the money then.\""),
                .cross("You never told {V} before the sale.", "\"{V} wasn't answering my calls.\"")
            ],
            prosecutionOpening: "Twenty-two head of somebody else's cattle and a signature that said they were {DL}'s.",
            defenseOpening: "Two years of hay, a drought, and a promise to make it right.",
            prosecutionClosing: "A debt is for a courthouse. {DL} took it to the sale barn and lied on the form.",
            defenseClosing: "{DL} believed {D.he} had the right. Without intent to cheat, there's no false pretense.",
            when: .months([8, 9, 10]),
            victim: VictimFacts(age: 58, occupation: "cattle farmer", relationship: "Leased the pasture next to the defendant's land", family: "Married", harm: ["Lost 22 bred cows; sold the rest of the herd to pay the lease"], restitution: 26950, restitutionBasis: "the sale price of the 22 cattle"),
            family: "Married; one son.",
            residence: "A farm outside {HOOD}"
        )
    )

    // MARK: - The bouncer's flashlight

    static let bouncerFlashlight = CaseTemplate(
        key: "story.bouncerFlashlight", category: .violent,
        headlines: ["Bar Patron's Skull Fractured in Fight With Bouncer", "Bouncer Says He Swung Flashlight in Self-Defense"],
        primaryLaw: "awdwisi", lesserLaw: "aisi", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon, a steel tactical flashlight, inflicting serious injury, a skull fracture, on {DATE}.",
        ageRange: 23...45, occupations: ["bouncer", "nightclub security guard"], hasVictim: true,
        summaries: [
            "At closing time on {DATE}, {D}, a bouncer at a bar on {STREET} in {HOOD}, walked {V} out the back door after {V} refused to leave. In the alley, {D} hit {V} once in the head with a 14-inch steel flashlight. {V} fell and fractured {V.his} skull on the curb and spent nine days in the hospital. The alley camera shows {V} turning and raising {V.his} hands toward {D} a second before the swing, but is too grainy to show whether {V} was holding anything. {DL} says {V} had threatened to \"cut\" {D.him} inside and reached into {V.his} pocket. Deputies found a closed folding knife in {V}'s jacket pocket at the hospital."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Alley Camera", "{D} walks {V} out; {V} turns, hands rising; {D} swings the flashlight once; {V} drops."),
            E(.document, 3, "Medical Records", "A depressed skull fracture and brain bleed; nine days in the hospital; lasting hearing loss in one ear."),
            E(.physical, 2, "Flashlight", "A 14-inch steel tactical flashlight, 1.3 pounds, sold as a \"defensive\" light.", .search)
        ],
        defenseEvidence: [
            E(.physical, 2, "Folding Knife", "A closed 3-inch folding knife recovered from {V}'s jacket pocket at the hospital.", .search),
            E(.statement, 2, "Bartender's Account", "The bartender heard {V} tell {DL}, \"I'll cut you, you rent-a-cop,\" twenty minutes before closing.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Bar patron",
                        direct: ["\"I turned around to ask for my hat.\""],
                        cross: ["\"I'd had a lot to drink.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened in the alley?", "\"He shoved me out the door. I turned around to ask for my hat, which fell off inside. Next thing I remember is the hospital.\""),
                            .direct("Did you reach for your knife?", "\"No. I carry it for work. I never touched it.\""),
                            .cross("You told {DL} you'd cut {D.him}.", "\"I don't remember saying that. I was drunk.\""),
                            .cross("How many drinks?", "\"Maybe eight.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Police detective",
                        direct: ["\"{V}'s hands were empty on the video.\""],
                        cross: ["\"The video is grainy.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the video show?", "\"{V} turns, hands come up about chest high, open as far as I can tell. One swing to the head.\""),
                            .direct("Where was the knife?", "\"Closed, in the inside jacket pocket, zipped. The nurse found it.\""),
                            .cross("You can't see {V}'s hands clearly.", "\"Not clearly, no.\""),
                            .cross("The pocket was on the side {V} reached toward.", "\"{V}'s hands went up, not toward the pocket.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Bartender",
                        direct: ["\"{V} said 'I'll cut you.'\""],
                        cross: ["\"I didn't see the alley.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you hear inside?", "\"{V} got loud when we cut {V.him} off and told {DL}, 'I'll cut you, you rent-a-cop.' Patted {V.his} jacket when {V.he} said it.\""),
                            .direct("What did {DL} do?", "\"Stayed calm. Told {V} it was time to go.\""),
                            .cross("Did you see what happened in the alley?", "\"No. I was closing out the register.\""),
                            .cross("The bar tells its bouncers to carry those flashlights.", "\"The owner bought them, yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} walked a drunk customer into an alley and crushed {V.his} skull with a steel club. {V}'s hands were up and the knife was zipped in a pocket."],
        defenseTheory: ["{V} threatened to cut {D}, patted the knife, and turned on {D.him} in a dark alley. One swing to stop an armed man is self-defense."],
        aggravating: ["The defendant was armed with a deadly weapon at the time of the crime", "The defendant took advantage of a position of trust or confidence"],
        mitigating: ["The defendant acted under strong provocation", "The defendant has a positive employment history and is gainfully employed"],
        victimImpacts: ["\"I can't hear out of my left ear. I lost my job on a roofing crew because I can't keep my balance on a ladder. I was a drunk fool that night, but I didn't deserve a skull fracture.\""],
        allocutions: ["\"He said he'd cut me and he turned on me. I had a second to decide.\"", "\"I swung too hard. I knew it the second I did it.\""],
        guiltyTruths: ["A second camera in the bar's kitchen doorway, found later, showed {V}'s hands empty and open at chest height when {DL} swung."],
        innocentTruths: ["A delivery driver parked in the alley later came forward and said {V} had the knife half out of the pocket when {DL} swung."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(0, "About 1:40 a.m.: {V} cut off at the bar; threat to {DL}."), (0, "2:02 a.m.: {DL} walks {V} out the back; one swing in the alley."), (0, "2:20 a.m.: {V} taken to the hospital; knife found in jacket."), (2, "Alley video recovered by warrant.")],
            howIdentified: "The bar's alley camera and {DL}'s own account to officers.",
            notDone: ["The bar's kitchen camera was never checked.", "No one canvassed the alley for a delivery driver who was parked there."],
            defendantExam: [
                .direct("Why did you take {V} out the back?", "\"Policy. You never walk an angry drunk out the front past the line.\""),
                .direct("What happened when {V} turned?", "\"{V.His} hand went toward that pocket where {V.he}'d patted the knife. I swung before {V.he} could get it out.\"", "\"{V.He} turned fast and I swung. I didn't see a knife. I just knew {V.he}'d said it.\""),
                .cross("{V}'s knife was closed and zipped in a pocket.", "\"I didn't know that. I knew what {V.he} said.\""),
                .cross("You hit {V.him} in the head with a steel flashlight.", "\"It's what I had in my hand.\""),
                .cross("You're bigger than {V}, and sober.", "\"Size doesn't matter against a knife.\"")
            ],
            prosecutionOpening: "One swing of a steel club at a man with his hands up.",
            defenseOpening: "A threat to cut, a pat on a knife, and a turn in a dark alley.",
            prosecutionClosing: "Fear has to be reasonable. A zipped pocket and raised hands don't make it reasonable.",
            defenseClosing: "{DL} didn't have to wait to be cut. One swing, then {D.he} called 911.",
            victim: VictimFacts(age: 34, occupation: "roofer", relationship: "A customer at the bar", harm: ["Depressed skull fracture and brain bleed", "Permanent hearing loss in the left ear"], restitution: 18400, restitutionBasis: "hospital bills not covered by insurance"),
            time: "2:02 a.m.",
            employer: "a bar on {STREET} in {HOOD}",
            family: "Single; shares custody of a daughter.",
            residence: "An apartment in {HOOD}",
            scene: "The alley behind a bar on {STREET} in {HOOD}"
        )
    )
}
