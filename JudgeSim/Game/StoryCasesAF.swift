import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAF: [CaseTemplate] = [outboardMotors, giftCardDrain, counterfeitTickets, pumpSkimmer, utilityImpostor]

    // MARK: - Slips 14 and 15 (two outboard motors taken from the marina overnight)

    static let outboardMotors = CaseTemplate(
        key: "story.outboardMotors", category: .property,
        headlines: ["Two Outboards Vanish From Port Hollis Marina Overnight", "Boat Mechanic Charged After Stolen Motor Turns Up on Marketplace"],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 7, lesserThreshold: 5,
        specification: "Stole two outboard motors valued at $14,600 from boats docked at {FAC} on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "possStolen", specification: "Possessed a third outboard motor, reported stolen from a boat at the Bayard Boat Landing, knowing or having reason to believe it was stolen.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...48, occupations: ["boat mechanic", "marine engine repairman"], hasVictim: true,
        summaries: [
            "At 2:10 a.m. on {DATE}, the camera on the fuel dock at {FAC} recorded a jon boat with its running lights off tie up between slips 14 and 15. Forty minutes later it left, riding low. In the morning, {V} found the twin Yamaha 150s gone from {V.his} center console, and the slip next door had lost one more. Nine days later a Facebook Marketplace listing for a Yamaha 150, \"lower unit rebuilt, $3,900 cash,\" was posted from {D}'s account. A detective answered it, and at {D}'s repair shop on {STREET} in {HOOD} found the advertised motor and a second one with its serial plate ground off. The serial number stamped on the inside of the engine block matched {V}'s. {DL} says {D.he} bought both from a man named Wade at the Cane Creek flea market for parts and didn't know they were stolen."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Fuel Dock Camera", "Two figures in dark hooded jackets tie a jon boat between slips 14 and 15 at 2:10 a.m. and leave at 2:51 a.m. Faces are not visible."),
            E(.digital, 3, "Marketplace Listing", "The listing from {D}'s account: \"Yamaha 150, lower unit rebuilt, $3,900 cash, no trades,\" posted nine days after the theft, with photos taken inside {DL}'s shop."),
            E(.physical, 3, "Block Serial Number", "The second motor's serial plate was ground off, but the number stamped inside the block matched {V}'s registration and Yamaha's dealer record.", .search),
            E(.document, 2, "Price Records", "Dealer records value the two stolen motors at $14,600 together. {DL} told the detective {D.he} paid $1,800 for both.")
        ],
        defenseEvidence: [
            E(.document, 2, "Handwritten Receipt", "A receipt on notebook paper: \"2 Yamaha 150 for parts, $1,800, paid in full. Wade.\" No last name, no phone number."),
            E(.statement, 1, "Shop History", "Three customers say {DL} has bought and rebuilt used outboards for years and has always given them paperwork.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Boat owner",
                        direct: ["\"Both motors were gone. They'd cut the controls and the fuel lines.\""],
                        cross: ["\"I didn't see who did it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you find that morning?", "\"Both motors gone off the transom. They cut the steering cables and the fuel lines clean, so they knew what they were doing.\"", "\"Just the brackets. Somebody cut the cables and fuel lines and lifted both motors off.\""),
                            .direct("How do you know the motor in the shop was yours?", "\"There's a dent on the cowling from a piling at Bayard last summer, and the detective showed me the number inside the block. It's mine.\""),
                            .direct("What did those motors cost you?", "\"Seven thousand three hundred apiece, used, two years ago. I still owe on them.\""),
                            .cross("You didn't see who took them?", "\"No. I was home asleep.\""),
                            .cross("Lots of Yamaha cowlings have dents, don't they?", "\"Mine has that one. And the number inside doesn't lie.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Property crimes detective",
                        direct: ["\"The serial number inside the block was {V}'s.\""],
                        cross: ["\"I couldn't identify anyone on the dock camera.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you find the motor?", "\"I searched Marketplace for Yamaha 150s in the county every day after the theft. Nine days later one showed up from {DL}'s account, with the photos taken inside {D.his} shop.\""),
                            .direct("What happened when you went to the shop?", "\"The advertised motor was there, and a second one with its serial plate ground off. Yamaha stamps the number inside the block too. It matched {V}'s.\"", "\"Two Yamaha 150s. One had the plate ground off, but the number stamped inside the block matched {V}'s motor.\""),
                            .direct("What did {DL} tell you about where they came from?", "\"A man named Wade at the Cane Creek flea market, eighteen hundred for both. {D.He} couldn't give me a last name or a number.\""),
                            .cross("You can't see a face on the dock camera.", "\"No. Two people in hoods.\""),
                            .cross("Did you look for Wade?", "\"I went to the flea market two Saturdays. Nobody there knew a Wade who sold motors.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Longtime customer of the repair shop",
                        direct: ["\"{DL} always gave me paperwork on a used motor.\""],
                        cross: ["\"I never saw what {D.he} paid for them.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"{D.He}'s fixed my boat for six years. Fair price, never tried to cheat me.\""),
                            .direct("Have you bought a used motor from {D.him}?", "\"Two. Both times {D.he} gave me a bill of sale and the old registration.\""),
                            .cross("Did you know {D.he} paid $1,800 for two motors worth $14,600?", "\"I didn't know that.\""),
                            .cross("Would you buy two 150s for $1,800 without asking questions?", "\"I'd probably ask some questions.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pulled two motors off the marina dock, ground off one serial plate, and tried to sell the other nine days later."],
        defenseTheory: ["{D} is a mechanic who bought parts motors from a stranger. The State can't put {D.him} on that dock, and buying cheap isn't stealing."],
        aggravating: ["The property was taken for resale"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["\"I work two jobs to pay for that boat. My boy and I haven't been out on the water since.\""],
        allocutions: ["\"I should have walked away from a deal that cheap. I know that now.\""],
        guiltyTruths: ["{DL}'s phone was later shown to have connected to the marina's guest Wi-Fi at 2:22 a.m. that night."],
        innocentTruths: ["A man named Wade Pittman was arrested in Carteret County months later with four motors and a notebook of receipts in the same handwriting."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        extras: ["FAC": ["the Port Hollis Marina"]],
        story: StoryExtras(
            timeline: [(0, "2:10 a.m.: a jon boat ties up at slips 14 and 15 at {FAC}; leaves at 2:51 a.m."), (0, "Morning: {V} reports both motors stolen."), (9, "Marketplace listing posted from {D}'s account."), (11, "Detective answers the listing; shop searched by consent; two motors found.")],
            howIdentified: "A Marketplace listing from {D}'s account, then the serial number inside the block.",
            notDone: ["The jon boat on the camera was never identified.", "No one checked {DL}'s phone location for that night."],
            defendantExam: [
                .direct("Where did the motors come from?", "\"A man named Wade at the Cane Creek flea market. He had them on a trailer. Eighteen hundred for both, for parts.\""),
                .direct("Did you grind off the serial plate?", "\"No. It was already gone when I bought it. I figured it was a parts motor.\""),
                .cross("Two 150s for $1,800. You know what those motors are worth.", "\"Running, sure. He said they were seized up.\"", "\"Not seized ones. That's what he told me they were.\""),
                .cross("And you listed one for $3,900 nine days later, \"lower unit rebuilt.\"", "\"Because I rebuilt it. That's my work.\""),
                .cross("Where were you at 2 a.m. that night?", "\"Home, asleep. My wife can tell you that.\"")
            ],
            prosecutionOpening: "Two motors off the dock, one with its serial plate ground away, and both in {DL}'s shop.",
            defenseOpening: "A mechanic who bought parts from the wrong man.",
            prosecutionClosing: "Nobody honest pays $1,800 for $14,600 in motors and never asks for a last name. The ground-off plate tells you {DL} knew.",
            defenseClosing: "The camera shows two hoods, not {D}. Buying cheap from a stranger is careless, not theft.",
            victim: VictimFacts(restitution: 7300, restitutionBasis: "the second motor, never recovered"),
            time: "2:10 a.m.",
            employer: "his own repair shop on Water Street",
            yearsAtJob: 8
        )
    )

    // MARK: - Register 3 (gift cards loaded and never paid for)

    static let giftCardDrain = CaseTemplate(
        key: "story.giftCardDrain", category: .whiteCollar,
        headlines: ["Harbor Mart Cashier Charged With Loading $11,300 in Unpaid Gift Cards", "Voided Cash, Loaded Cards: Store Says Register 3 Told the Story"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Embezzled $11,300 belonging to {STORE}, by loading gift cards at register 3 and voiding the cash tenders, between four months before {DATE} and {DATE}.",
        ageRange: 20...34, occupations: ["cashier"], hasVictim: false,
        summaries: [
            "Over four months, {STORE}'s register 3 recorded 46 gift card loads, each paid in cash and then voided within a minute after the card was activated. The cards, worth $11,300 in all, were drained through online orders shipped to an address on {STREET} in {HOOD}, where {D}'s cousin lives. Every load ran under {D}'s register login. {DL}, a cashier there for two years, says managers used {D.his} login whenever theirs locked, which happened weekly, and that {D.he} never loaded a card {D.he} didn't sell."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Register Journal", "46 gift card loads under {DL}'s login, each followed within a minute by a voided cash tender. Total: $11,300."),
            E(.document, 2, "Shipping Records", "Thirty-one online orders paid with the cards, all shipped to the address on {STREET} where {DL}'s cousin lives.", .search),
            E(.video, 2, "Register Camera", "On the eleven dates the camera footage was kept, {DL} is at register 3 when the loads ran.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Shared Logins", "A former shift manager says managers routinely used cashiers' logins when their own locked, including {DL}'s."),
            E(.document, 1, "Password Reset Log", "IT records show the managers' logins locked out 19 times in those four months.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Asset protection investigator, {STORE}",
                        direct: ["\"Every one ran under {DL}'s login.\""],
                        cross: ["\"Managers did sometimes use cashier logins.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did the store find this?", "\"Our system flags a cash tender voided right after a gift card is activated. Register 3 had 46 of them in four months.\"", "\"An exception report. Gift card activated, cash voided a minute later. Forty-six times on register 3.\""),
                            .direct("Whose login?", "\"{DL}'s, every time.\""),
                            .direct("What about the camera?", "\"We keep footage thirty days. For the eleven dates we still had, {DL} is at register 3 when the loads run.\""),
                            .cross("Managers used cashiers' logins when theirs locked?", "\"It happened. It's against policy.\""),
                            .cross("For the other 35 loads, you have no video at all?", "\"No. It was overwritten.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"The orders went to {DL}'s cousin's address.\""],
                        cross: ["\"The cousin wasn't charged.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where did the money go?", "\"The cards paid for 31 online orders: tablets, gaming systems, sneakers. All shipped to the house on {STREET}.\""),
                            .direct("Who lives there?", "\"{DL}'s cousin. {DL}'s car was there three of the delivery days.\""),
                            .cross("Did you search the cousin's house?", "\"With a warrant. We found two of the tablets still in the box.\""),
                            .cross("Was the cousin charged?", "\"No. The cousin said {DL} had the packages sent there.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former shift manager, {STORE}",
                        direct: ["\"Managers used cashier logins all the time.\""],
                        cross: ["\"I never saw anyone else load cards on register 3.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Did managers use cashiers' logins?", "\"Constantly. Ours locked out every week, and IT took a day to reset them. We'd use whoever's register was open.\""),
                            .direct("Whose login got used most?", "\"Register 3's, because it's by the office.\""),
                            .cross("Did you ever see another person load gift cards on register 3 and void the cash?", "\"No, I never saw that.\""),
                            .cross("You left the store under a cloud yourself, didn't you?", "\"I was let go for attendance. That's all.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s login, {D.his} register, {D.his} face on camera, and {D.his} cousin's porch: $11,300 in gift cards {D.he} never paid for."],
        defenseTheory: ["Half the managers in that store used {D}'s login. The State has eleven days of video for 46 loads and a cousin who pointed the finger to stay out of it."],
        aggravating: ["Abuse of a position of trust"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["Store manager: \"We had to cut hours for the whole front end after the loss. People who did nothing wrong lost shifts.\""],
        allocutions: ["\"I'll pay it back. I just want to keep working.\""],
        guiltyTruths: ["Text messages later recovered from the cousin's phone showed {DL} sending order lists: \"this week: 2 ipads and the jordans.\""],
        innocentTruths: ["A night manager was fired a year later after the same pattern appeared on a different register under a different cashier's login."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["STORE": ["Harbor Mart"]],
        story: StoryExtras(
            timeline: [(-120, "First voided-cash gift card load on register 3."), (0, "Asset protection's exception report flags the 46th load."), (6, "{DL} interviewed and suspended."), (20, "Search warrant at the cousin's house; two tablets recovered.")],
            howIdentified: "An exception report, the register login, and the shipping address.",
            notDone: ["No one compared manager schedules against the 35 loads without video."],
            defendantExam: [
                .direct("Did you load those cards?", "\"No. I sold gift cards to customers who paid. I never voided their cash.\""),
                .direct("Who else used your login?", "\"Any manager whose login locked. Usually the night manager.\""),
                .cross("You're on camera at register 3 for all eleven dates the store still had.", "\"I worked register 3 most days. That's my register.\""),
                .cross("And the packages went to your cousin's house.", "\"I had some packages sent there because my apartment gets things stolen. Not those.\"", "\"Some of mine went there. I didn't order gaming systems with stolen cards.\"")
            ],
            prosecutionOpening: "Forty-six loads, one login, one cousin's porch.",
            defenseOpening: "A login half the store used.",
            prosecutionClosing: "The managers may have borrowed logins, but they didn't ship tablets to {DL}'s cousin.",
            defenseClosing: "Thirty-five loads with no video and a cousin who saved himself by naming {DL}. That isn't proof.",
            employer: "Harbor Mart", employmentEnded: true,
            yearsAtJob: 2
        )
    )

    // MARK: - Section 22, Row M (fake football tickets sold online)

    static let counterfeitTickets = CaseTemplate(
        key: "story.counterfeitTickets", category: .whiteCollar,
        headlines: ["Fans Turned Away at Stadium Gate Say Local Seller Sold Fake Tickets", "Six Buyers, Same Barcode: Ticket Seller Charged"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Obtained $1,840 from six buyers, including {V}, by selling them counterfeit tickets to a college football game, on or about {DATE}.",
        ageRange: 19...30, occupations: ["sporting goods clerk", "delivery driver", "community college student"], hasVictim: true,
        summaries: [
            "In the week before a sold-out rivalry game, {D} posted in a {HOOD} community Facebook group: \"4 tickets sec 22 row M, can't go, face value.\" Six buyers, including {V}, paid a total of $1,840 through a payment app to {D}'s account and received PDF tickets by message. At the stadium gate, all six sets scanned as invalid; several shared the same barcode. {DL} says {D.he} bought the tickets from an online reseller called TixKing, was scammed too, and showed deputies a $300 payment to that account."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Payment Records", "Six payments totaling $1,840 to {DL}'s payment app account in four days, each with a note like \"sec 22 tix.\""),
            E(.digital, 3, "The PDF Tickets", "Six sets of PDFs sent from {DL}'s account. Three sets carry the same barcode, and the metadata shows all of them were edited in the same app on {DL}'s phone.", .search),
            E(.statement, 2, "Gate Scans", "The stadium's ticket office reports every barcode scanned invalid; none was ever issued for Section 22, Row M.")
        ],
        defenseEvidence: [
            E(.digital, 2, "Payment to TixKing", "A $300 payment from {DL}'s account to an account called TixKing two days before the first sale."),
            E(.statement, 1, "Refund Offer", "{DL} messaged two buyers after the game offering to \"make it right.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Ticket buyer",
                        direct: ["\"All four scanned red at the gate.\""],
                        cross: ["\"{D.He} did message me after, saying {D.he}'d been scammed too.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you buy the tickets?", "\"{D.He} posted in the group. I messaged, paid $440 for four, and {D.he} sent me PDFs.\""),
                            .direct("What happened at the stadium?", "\"Every one scanned red. The man at the gate said a family ahead of us had the exact same barcode.\"", "\"Red light, all four. The gate man said he'd seen that barcode already that night.\""),
                            .direct("How did that feel?", "\"I'd promised my son that game for his birthday. We drove two hours and sat in the parking lot listening on the radio.\""),
                            .cross("{DL} contacted you afterward?", "\"The next day. Said {D.he}'d been scammed too and would try to make it right.\""),
                            .cross("Did {D.he} pay you back?", "\"No.\"")
                        ]),
            WitnessSeed(name: nil, role: "Digital forensic examiner, Sheriff's Office",
                        direct: ["\"The PDFs were edited on {DL}'s phone.\""],
                        cross: ["\"The TixKing payment is real.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find on the defendant's phone?", "\"The original ticket PDF, and six copies edited in a PDF editing app, changing the buyer name on each.\""),
                            .direct("Were the barcodes changed?", "\"No. Three sets kept the same barcode from the original. The other three had barcodes typed in by hand.\""),
                            .cross("There's a $300 payment to an account called TixKing?", "\"Yes. Two days before the first sale.\""),
                            .cross("So {DL} bought a ticket from someone.", "\"{D.He} bought something for $300. Then made six sets of it.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} paid $300 for one ticket, copied it six times on {D.his} phone, and sold $1,840 worth of nothing."],
        defenseTheory: ["{D} was scammed by TixKing first, and tried to make it right with the buyers. Being taken by a scammer isn't the same as being one."],
        aggravating: ["The offense involved multiple victims"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["\"It was his birthday. He still asks why someone would lie to us like that.\""],
        allocutions: ["\"I got greedy. I'm sorry to all of them.\""],
        guiltyTruths: ["The TixKing account belonged to {DL}'s roommate, who said {DL} paid him $300 for a single real ticket that {DL} then copied."],
        innocentTruths: ["TixKing was traced to a man in Georgia who had sold the same edited PDFs to dozens of resellers across three states."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(-9, "$300 payment to TixKing."), (-7, "{D} posts the tickets in the community group."), (-3, "Sixth buyer pays."), (0, "Game day: every barcode scans invalid."), (1, "{DL} messages two buyers offering to make it right."), (5, "Phone searched by warrant.")],
            howIdentified: "The payments went to {DL}'s own account.",
            notDone: ["The TixKing account was never traced."],
            defendantExam: [
                .direct("Where did the tickets come from?", "\"I bought them from TixKing for $300. He said they were transfers from a season ticket holder.\""),
                .direct("Why did you edit the PDFs?", "\"He told me to put each buyer's name on them. I didn't know the barcodes mattered.\""),
                .cross("You paid $300 and collected $1,840.", "\"He said I could resell at face. I didn't think about the math.\""),
                .cross("Three sets had the same barcode. You made those.", "\"I copied what he sent me. I thought each one was a different seat.\"")
            ],
            prosecutionOpening: "One $300 purchase, copied six times, sold for $1,840.",
            defenseOpening: "A fan who was scammed first.",
            prosecutionClosing: "The edits were on {DL}'s phone. {D.He} knew one ticket can't seat six families.",
            defenseClosing: "{DL} paid for real tickets, was cheated, and tried to fix it. Intent to deceive is the State's burden.",
            victim: VictimFacts(relationship: "Bought tickets from the defendant's post.")
        )
    )

    // MARK: - Pump 6 (a card skimmer at the gas station)

    static let pumpSkimmer = CaseTemplate(
        key: "story.pumpSkimmer", category: .whiteCollar,
        headlines: ["Skimmer Found Inside Pump 6; 212 Cards Compromised", "Deputies Say Man Caught With 31 Cloned Cards Installed Gas Pump Skimmer"],
        primaryLaw: "cardFraud", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Used counterfeit financial transaction cards, encoded with account numbers stolen through a skimmer, to obtain $6,250 in gift cards, on or about {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "identityTheft", specification: "Knowingly possessed the identifying information of 31 people, including {V}, with intent to use it fraudulently.", chance: 1.0, threshold: 0)
        ],
        ageRange: 25...45, occupations: ["HVAC technician", "tow truck driver", "unemployed"], hasVictim: true,
        summaries: [
            "A technician servicing pump 6 at {PLACE.GASSTATION} in {HOOD} found a Bluetooth skimmer wired inside the panel; 212 cards had been swiped there in two weeks. The station's camera showed a person in a gray ball cap opening the pump panel with a key at 4:50 a.m. twelve days earlier. {V}'s card, used at that pump, was then charged for gift cards at three stores. Deputies stopped a gray sedan seen leaving one of those stores; {D} was driving, and 31 blank-white cards encoded with stolen numbers were in the console. {DL} says the car is {D.his} cousin's, the cards were in it when {D.he} borrowed it, and {D.he} has never touched a gas pump panel."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Cloned Cards", "31 white plastic cards in the car's console, each encoded with a stolen account number, including {V}'s.", .search),
            E(.video, 2, "Pump Camera", "At 4:50 a.m., a person in a gray ball cap opens pump 6's panel with a key and works inside for three minutes. His face is mostly hidden by the cap."),
            E(.video, 3, "Store Cameras", "At two of the three stores, {DL} is on camera buying $500 gift cards with white cards on the days {V}'s number was used."),
            E(.physical, 2, "Pump Key", "A universal gas pump key on {DL}'s key ring.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Car Registration", "The gray sedan is registered to {DL}'s cousin, who has two prior fraud convictions."),
            E(.statement, 1, "Borrowed Car", "{DL}'s sister says {DL} borrowed the car that week because {D.his} own truck was in the shop.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Cardholder",
                        direct: ["\"I bought gas at pump 6. Two days later my card bought three gift cards in Wexley.\""],
                        cross: ["\"The bank refunded me.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("When did you use pump 6?", "\"Filling up on my way to work. I go there every week.\""),
                            .direct("What happened to your card?", "\"Two days later, $1,500 in gift cards at three stores I've never been to. My rent was due that week.\""),
                            .cross("Your bank refunded the charges?", "\"After three weeks. Meanwhile my rent check bounced.\""),
                            .cross("You don't know who made those charges?", "\"No. Just that I didn't.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"{DL} is on camera at two stores using the cloned cards.\""],
                        cross: ["\"I can't say the man at the pump is {DL}.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you connect the skimmer to the defendant?", "\"The stolen numbers were used at three stores. One store's lot camera had the plate of a gray sedan. We stopped it two days later with {DL} driving and 31 cloned cards in the console.\""),
                            .direct("What do the store videos show?", "\"{DL} at the register at two of the stores, buying $500 gift cards with white cards.\"", "\"{DL}, at two registers, paying for gift cards with plain white cards.\""),
                            .direct("What was on {D.his} key ring?", "\"A universal pump key. It opens most gas pump panels in the state.\""),
                            .cross("You can't see the face of the man at the pump.", "\"No. Gray cap, same build. That's as far as I'll go.\""),
                            .cross("The car belongs to a cousin with fraud convictions?", "\"It does. The cousin was in Durham that week, by his phone.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} put the skimmer in pump 6, cloned the cards, and spent them on camera. The pump key on {D.his} ring opens the door."],
        defenseTheory: ["{D} borrowed a car that belonged to a convicted fraudster. The State can't put {D.him} at the pump."],
        aggravating: ["The offense involved multiple victims", "The offense involved planning and sophistication"],
        mitigating: [],
        victimImpacts: ["\"My rent bounced and I paid a $75 late fee for something I didn't do.\""],
        allocutions: ["\"I used the cards. I didn't build anything. I'm sorry.\""],
        guiltyTruths: ["A search of {DL}'s phone months later found the skimmer's Bluetooth pairing app and data downloads from pump 6."],
        innocentTruths: ["The cousin was arrested in a neighboring county installing a skimmer in a gray cap a month later."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(-14, "4:50 a.m.: man in a gray cap opens pump 6's panel."), (-12, "{V} buys gas at pump 6."), (-10, "{V}'s number used for gift cards at three stores."), (0, "Technician finds the skimmer."), (2, "Gray sedan stopped; {DL} driving; 31 cloned cards in the console.")],
            howIdentified: "A store lot camera captured the car's plate; {DL} was driving when it was stopped.",
            notDone: ["{DL}'s phone wasn't searched for skimmer software."],
            defendantExam: [
                .direct("Whose car was it?", "\"My cousin's. My truck was in the shop that week.\""),
                .direct("Did you put a skimmer in pump 6?", "\"No. I don't know how those work.\""),
                .cross("You're on camera buying gift cards with white cards.", "\"My cousin asked me to pick some up for him. He gave me the cards.\"", "\"Those were my cousin's cards. He told me they were prepaid.\""),
                .cross("And the pump key on your key ring?", "\"I do some HVAC side work. I don't know what that key is.\"")
            ],
            prosecutionOpening: "The skimmer, the cloned cards, the store cameras, and the key.",
            defenseOpening: "A borrowed car with someone else's crimes in the console.",
            prosecutionClosing: "Plain white cards don't look like prepaid cards, and nobody carries a pump key by accident.",
            defenseClosing: "The man at the pump has no face. The car's owner has two fraud convictions.",
            victim: VictimFacts(relationship: "Strangers.")
        )
    )

    // MARK: - The man in the safety vest (a fake utility worker inside an elderly woman's home)

    static let utilityImpostor = CaseTemplate(
        key: "story.utilityImpostor", category: .property,
        headlines: ["Man Posing as Power Company Worker Takes Jewelry From 81-Year-Old", "\"He Had a Vest and a Clipboard\": Widow Lets Fake Utility Worker In"],
        primaryLaw: "feloniousBE", lesserLaw: "trespass2", threshold: 7, lesserThreshold: 4,
        specification: "Entered the residence of {V} by deception, falsely claiming to be a power company worker, with intent to commit larceny, on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole jewelry valued at $3,200 from the residence of {V}.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "exploitationElder", specification: "Knowingly took the property of {V}, an older adult, by deception.", chance: 0.6, threshold: 6)
        ],
        ageRange: 28...50, occupations: ["meter reader", "landscaper", "unemployed"], hasVictim: true,
        summaries: [
            "At about 10:15 a.m. on {DATE}, a man in an orange safety vest knocked at the home of {V}, 81, on {STREET} in {HOOD}, saying he was with the power company and needed to check the wiring in the back bedroom because of a line problem on the street. {V.He} let him in. He was inside twelve minutes. That evening {V} found {V.his} late husband's ring and {V.his} mother's pearls missing from the dresser. A neighbor's doorbell camera recorded the man walking to a white pickup. {V} picked {D} from a photo array five days later, saying, \"I think that's him.\" {DL}, who reads meters part-time for a contractor, says {D.he} was on a route in Cane Creek that morning."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Doorbell Camera", "A man in an orange vest and ball cap walks from {V}'s porch to a white pickup at 10:28 a.m. The face is visible for about a second, at a distance."),
            E(.document, 2, "Photo Array", "{V} picked photo 4, {DL}, after about a minute: \"I think that's him.\" The array was shown by a detective who knew which photo was the suspect."),
            E(.document, 2, "Power Company Records", "No power company worker was sent to {STREET} that day, and {DL} doesn't work for the power company.")
        ],
        defenseEvidence: [
            E(.document, 2, "Route Log", "The meter contractor's handheld log shows {DL}'s device reading meters in Cane Creek from 9:40 a.m. to 11:55 a.m., with readings every three to five minutes."),
            E(.statement, 1, "Truck", "{DL} drives a white pickup, as do, by DMV records, more than 600 people in the county.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"He said he was with the power company, and I let him in.\""],
                        cross: ["\"I said I think it's him. I'm not certain.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did the man say at your door?", "\"That there was a problem with the line and he had to check the back bedroom. He was polite. He had a vest and a clipboard.\""),
                            .direct("What did you find that evening?", "\"My husband's wedding ring was gone, and my mother's pearls. I've worn that ring on a chain every day since he passed, and I'd just taken it off to bathe.\"", "\"The ring box was empty. My husband's ring, and my mother's pearls.\""),
                            .direct("How did you feel after?", "\"I don't open the door now. I sit with the lights off when somebody knocks.\""),
                            .cross("In the photo lineup, you said \"I think that's him.\"", "\"That's what I said. It looked like him.\""),
                            .cross("You'd had cataract surgery that spring?", "\"Yes. I see all right for close up.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Property crimes detective",
                        direct: ["\"No power company worker was sent there that day.\""],
                        cross: ["\"I knew which photo was the suspect when I showed the array.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did {DL} become a suspect?", "\"A tip line caller said a meter reader drove a white pickup like the one in the doorbell video. That was {DL}.\""),
                            .direct("How was the photo array shown?", "\"Six photos, one at a time. {V} picked number 4, {DL}, after about a minute.\""),
                            .cross("You knew which photo was {DL} when you showed it?", "\"I did. We were short on staff that day.\""),
                            .cross("North Carolina law requires an officer who doesn't know the suspect to show the array, doesn't it?", "\"It does, when one is available. I should have waited for one.\""),
                            .cross("Did you check the meter contractor's route logs?", "\"Not until the defense sent them to me.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Field supervisor, meter reading contractor",
                        direct: ["\"{DL}'s handheld was reading meters in Cane Creek all morning.\""],
                        cross: ["\"The handheld logs the device, not the person holding it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the route log show?", "\"{DL}'s handheld read meters in Cane Creek from 9:40 to 11:55, every three to five minutes. No gaps.\""),
                            .direct("How far is Cane Creek from {STREET}?", "\"Twenty-five minutes, at least.\""),
                            .cross("The log shows the device, not who held it?", "\"That's right. But readers don't hand those off. It's against policy.\""),
                            .cross("Has anyone ever shared a device?", "\"It's happened. I've written people up for it.\"")
                        ])
        ],
        prosecutionTheory: ["{D} put on a vest, talked {D.his} way into an 81-year-old's home, and walked out with {V.his} husband's ring."],
        defenseTheory: ["{D} was reading meters in Cane Creek, and the log proves it. The identification was a tentative pick from an array shown by the detective who chose {D.him}."],
        aggravating: ["The victim was very old", "The defendant took advantage of a position of trust"],
        mitigating: [],
        victimImpacts: ["\"That ring was the last thing I had of him that he wore every day. I'd give them the pearls if I could just have the ring back.\""],
        allocutions: ["\"I didn't do this. I'm sorry for what happened to her.\""],
        guiltyTruths: ["The ring turned up at a pawn shop in another county, pawned under {DL}'s driver's license two days after the theft."],
        innocentTruths: ["A man arrested a year later for the same vest-and-clipboard scheme in two counties admitted the {STREET} theft and led deputies to the pearls."],
        moods: [.wantsConviction], doctrines: ["eyewitnessID", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "About 10:15 a.m.: a man in a vest enters {V}'s home; leaves at 10:28 a.m., per the doorbell camera."), (0, "Evening: {V} finds the ring and pearls missing."), (3, "Tip line names a meter reader with a white pickup."), (5, "Photo array: {V} picks {DL}."), (40, "Defense obtains the route log.")],
            howIdentified: "A tip, then a photo array shown by the lead detective.",
            notDone: ["The array wasn't shown by an independent administrator.", "Pawn shops weren't canvassed for the ring."],
            defendantExam: [
                .direct("Where were you that morning?", "\"On my route in Cane Creek, reading meters. My handheld shows it.\""),
                .direct("Have you ever been inside {V}'s home?", "\"Never. I don't go in houses. Meters are outside.\""),
                .cross("You drive a white pickup and own an orange vest.", "\"So does every meter reader in the county.\""),
                .cross("Did anyone else carry your handheld that day?", "\"No.\"")
            ],
            prosecutionOpening: "A vest, a clipboard, and a widow who let him in.",
            defenseOpening: "A route log that puts {DL} twenty-five minutes away.",
            prosecutionClosing: "{V} picked {DL}. The vest and the pickup fit. A handheld can be left on a dashboard.",
            defenseClosing: "A tentative pick from an array the detective shouldn't have run, against a log reading a meter every four minutes.",
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(age: 81, occupation: "retired schoolteacher", relationship: "Strangers."),
            time: "10:15 a.m."
        )
    )
}
