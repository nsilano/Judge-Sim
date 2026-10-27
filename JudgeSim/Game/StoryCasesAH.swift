import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAH: [CaseTemplate] = [mailedPills, crossingGuardCrash, mobileHomeSale, fakeFundraiser, prescriptionPadForgery]

    // MARK: - Box 214 (pressed pills in the mail)

    static let mailedPills = CaseTemplate(
        key: "story.mailedPills", category: .drugs,
        headlines: ["Postal Inspectors Intercept Fentanyl Pills Bound for Hollis County", "Arrest After Controlled Delivery of Pill Package to P.O. Box"],
        primaryLaw: "traffickingOpioid", lesserLaw: "possSchedII", threshold: 7, lesserThreshold: 5,
        specification: "Trafficked in an opioid by possessing 4 grams or more but less than 14 grams of fentanyl, in the form of pressed pills, on {DATE}.",
        ageRange: 21...38, occupations: ["unemployed", "delivery driver", "tattoo artist"], hasVictim: false,
        summaries: [
            "A postal inspector in Charlotte flagged a padded envelope bound for Box 214 at the {PLACE.LANDING.TOWN} post office: a handwritten return address that didn't exist, heavy tape, and postage paid in cash. A drug dog alerted, and a federal magistrate signed a warrant. Inside, wrapped in a child's coloring book, were 100 blue pills stamped \"M30,\" which the lab found contained 9.6 grams of fentanyl mixture. Inspectors resealed it and watched the box. On {DATE}, {D} opened Box 214 with a key, took the envelope, and was arrested in the parking lot. The box was rented under the name \"Jay Moore\" with a fake ID. {DL} says a friend paid {D.him} $50 to pick up \"a package\" and {D.he} had no idea what was inside."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Lab Report", "100 pressed blue tablets marked M30, containing fentanyl, 9.6 grams in total."),
            E(.video, 2, "Post Office Camera", "{D} opens Box 214 with a key at 10:12 a.m., looks around the lobby, and tucks the envelope inside {D.his} jacket."),
            E(.document, 2, "Box Rental Form", "Box 214 rented for six months under the name \"Jay Moore,\" with a driver's license number that belongs to no one. The photo on the license copy resembles {DL}.")
        ],
        defenseEvidence: [
            E(.digital, 2, "Text Messages", "A text to {DL} the night before from a contact saved as \"T\": \"Grab my mail at 214 tmrw, key's under your mat, $50.\""),
            E(.document, 1, "Handwriting", "A handwriting examiner could not say whether {DL} wrote the address on the envelope or signed the rental form.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "U.S. postal inspector",
                        direct: ["\"The package had every marker we look for.\""],
                        cross: ["\"I can't say who mailed it.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Why did you flag the envelope?", "\"A return address that doesn't exist, heavy tape on every seam, a handwritten label, and cash postage from a kiosk. A dog alerted on it, and we got a federal warrant.\""),
                            .direct("What was inside?", "\"A child's coloring book with a hole cut through the pages, and a bag of 100 blue pills stamped M30. They're made to look like oxycodone. They're fentanyl.\""),
                            .direct("What did {DL} do in the lobby?", "\"Opened the box with a key, looked over both shoulders, and put the envelope inside {D.his} jacket instead of carrying it.\""),
                            .cross("You don't know who mailed the package.", "\"No.\""),
                            .cross("Lots of people look around in a post office lobby.", "\"And most of them carry their mail in their hand.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Narcotics detective",
                        direct: ["\"The photo on the box rental license resembles {DL}.\""],
                        cross: ["\"I can't prove {DL} rented the box.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you learn about the box?", "\"Rented six months earlier as Jay Moore with a fake license. The photo on the copy is grainy, but it resembles {DL}.\""),
                            .direct("What did {DL} say when arrested?", "\"That a friend named T paid {D.him} fifty dollars to get the mail. {D.He} wouldn't tell us who T was.\""),
                            .direct("Is $50 to pick up mail normal?", "\"Not for a box across the county. People get paid to pick up packages because the sender wants someone else holding them.\""),
                            .cross("You never found T.", "\"{DL} wouldn't give us a last name or a number beyond the text.\""),
                            .cross("The handwriting examiner couldn't tie {DL} to the label.", "\"That's right.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's roommate",
                        direct: ["\"The key showed up under our mat that morning.\""],
                        cross: ["\"I didn't see who left it.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see that morning?", "\"A little key under the mat. {DL} picked it up and said a buddy needed {D.him} to grab his mail.\""),
                            .direct("Had you ever seen that key before?", "\"Never.\""),
                            .cross("You don't know who T is either?", "\"No.\""),
                            .cross("Did {DL} have extra cash around that time?", "\"I don't know about that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} rented a box under a fake name to receive fentanyl by mail and picked it up when it came."],
        defenseTheory: ["{D} was a $50 errand runner for someone named T. The State can't prove {D.he} knew what was in the envelope."],
        aggravating: ["The offense involved a large quantity of controlled substance"],
        mitigating: ["The defendant has accepted responsibility", "The defendant is young"],
        victimImpacts: [],
        allocutions: ["\"I didn't ask what was in it because I didn't want to know. I know that's not an excuse.\""],
        guiltyTruths: ["{DL}'s phone later showed {D.he} had tracked the package's postal tracking number six times in the two days before pickup."],
        innocentTruths: ["A man named Tavon Moore was arrested in a second county months later with three more P.O. box keys and a fake license in the name Jay Moore with his own photo on it."],
        moods: [.wantsConviction], doctrines: ["searchSeizure", "burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-180, "Box 214 rented as \"Jay Moore\" with a fake license."), (-3, "Postal inspector flags the envelope; dog alert; federal warrant; 100 pills found."), (-1, "Text from \"T\" to {DL}: \"Grab my mail at 214 tmrw.\""), (0, "10:12 a.m.: {DL} opens the box and is arrested in the lot.")],
            howIdentified: "Arrested after a controlled delivery to the box.",
            notDone: ["The phone number for \"T\" was never subpoenaed.", "The rental form wasn't tested for fingerprints."],
            defendantExam: [
                .direct("Why did you pick up the envelope?", "\"T texted and said grab his mail, key's under my mat, fifty bucks. I needed fifty bucks.\""),
                .direct("Did you know what was in it?", "\"No. I thought it was, I don't know, a phone or something he didn't want at his house.\""),
                .cross("Something he didn't want at his house. Why would that be?", "\"I didn't think about it.\""),
                .cross("Why did you put it in your jacket?", "\"It was raining.\"", "\"So I wouldn't drop it.\""),
                .cross("Who is T?", "\"I'm not saying. I've got family here.\"")
            ],
            prosecutionOpening: "A fake name, a box across the county, and 100 fentanyl pills in a coloring book.",
            defenseOpening: "A $50 errand for someone else.",
            prosecutionClosing: "Nobody pays $50 to pick up a box of nothing. {DL} looked over both shoulders and hid it in {D.his} jacket.",
            defenseClosing: "The State has the pills. It doesn't have proof {DL} knew they were there, and it never looked for T.",
            time: "10:12 a.m."
        )
    )

    // MARK: - The crosswalk on School Street (a crossing guard struck and left)

    static let crossingGuardCrash = CaseTemplate(
        key: "story.crossingGuardCrash", category: .traffic,
        headlines: ["School Crossing Guard Killed; Driver Didn't Stop", "Driver Charged in Hit-and-Run Death of Crossing Guard"],
        primaryLaw: "hitAndRun", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Failed to stop at the scene of a crash the defendant knew or reasonably should have known resulted in the death of {V}, near {PLACE.SCHOOL}, on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "misdDBV", specification: "Unintentionally caused the death of {V} while failing to yield to a pedestrian in a marked crosswalk.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...62, occupations: ["sales representative", "contractor", "insurance adjuster"], hasVictim: true,
        summaries: [
            "At 7:48 a.m. on {DATE}, {V}, 68, a crossing guard for twelve years at {PLACE.SCHOOL}, stepped into the marked crosswalk with a stop sign raised. A silver SUV coming out of the sun hit {V} and kept going. {V} died at the hospital that afternoon. Two parents gave partial plates. That evening a trooper found {D}'s SUV in {D.his} garage with a cracked headlight, a dented hood, and {V}'s orange vest fibers in the grille. {DL} says {D.he} was blinded by the sun, felt a hit, thought {D.he} had struck the sign on the curb, and kept driving to a client meeting. {D.He} didn't learn a person had been hit until the trooper came to the door."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Vest Fibers", "Orange polyester fibers in the grille match {V}'s safety vest.", .search),
            E(.physical, 2, "SUV Damage", "A cracked right headlight and a dent in the hood with a crease the trooper says matches a person's body, not a post."),
            E(.statement, 2, "Parent Witness", "A parent in line at the school says the SUV \"never even slowed down\" and that {V} was thrown onto the hood.")
        ],
        defenseEvidence: [
            E(.document, 2, "Sun Angle", "A solar chart showing the sun 7 degrees above the horizon, directly behind the crosswalk to an eastbound driver, at 7:48 a.m. that day."),
            E(.document, 1, "Phone Records", "{DL}'s phone shows no calls or texts between 7:40 and 8:05 a.m.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Parent who saw the crash",
                        direct: ["\"{V} went up onto the hood. The SUV just kept going.\""],
                        cross: ["\"The sun was bad that morning.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{V} stepped out with the sign up like every morning. The SUV didn't slow at all. {V.He} went up onto the hood and off the side.\""),
                            .direct("What did the SUV do then?", "\"It swerved a little and kept going. It never even tapped the brakes. I was screaming.\"", "\"Kept going. I saw the brake lights flash for a second, maybe, and then it was gone.\""),
                            .direct("Did you know {V}?", "\"Every parent at that school knew {V}. {V.He} knew every kid's name. {V.He} had candy canes at Christmas.\""),
                            .cross("The sun was right behind the crosswalk that morning.", "\"It was. I had my visor down.\""),
                            .cross("You said the brake lights might have flashed.", "\"Maybe. For a second.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "State Highway Patrol trooper",
                        direct: ["\"That dent is a body, not a sign post.\""],
                        cross: ["\"I can't tell you what {DL} saw.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you find the SUV?", "\"Two parents gave partial plates. I ran the combinations against silver SUVs registered nearby and went door to door. {DL}'s was in the garage.\""),
                            .direct("What did the damage tell you?", "\"A broad dent in the hood with a crease and a cracked windshield on the passenger side. A sign post leaves a narrow dent low on the bumper. This is a person.\""),
                            .direct("Would the driver have known?", "\"With the windshield cracked a foot from the driver's eyes, and a body on the hood? I don't see how not.\""),
                            .cross("The sign post at that corner was also bent.", "\"It was. {V} was thrown into it.\""),
                            .cross("{DL} answered the door and admitted driving that route.", "\"{D.He} did. {D.He} was cooperative.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Optometrist",
                        direct: ["\"Low sun can blind a driver completely for a few seconds.\""],
                        cross: ["\"It wouldn't hide the impact itself.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What does sun glare do at that angle?", "\"At seven degrees, straight ahead, it washes out everything. Drivers report seeing nothing at all for two or three seconds.\""),
                            .direct("Could a driver mistake what was hit?", "\"If you never saw it, you're left guessing from sound and feel.\""),
                            .cross("The windshield cracked a foot in front of {DL}'s face.", "\"That would be hard to miss.\""),
                            .cross("A driver who can't see is supposed to slow down.", "\"That's the safe thing to do, yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} hit {V} in a marked crosswalk, cracked {D.his} own windshield on {V.him}, and drove on to a meeting."],
        defenseTheory: ["{D} was blinded by the sun and thought {D.he} hit the sign. The crash was a tragedy, but leaving requires knowing a person was hurt."],
        aggravating: ["The victim was very old"],
        mitigating: ["No prior criminal record", "The defendant has accepted responsibility", "The defendant has been a person of good character"],
        victimImpacts: ["\"Mom did that corner for twelve years. She said it kept her young. The kids made a banner of handprints for the funeral. Whoever you are, you didn't even stop to see if she was alive.\"", "\"Dad wouldn't take the money they paid him. He said he'd do it for free. He lay in that street while you drove to a meeting.\""],
        allocutions: ["\"I didn't know. I swear to God I didn't know. I'd have stopped. I'm so sorry.\""],
        guiltyTruths: ["{DL}'s car's crash data recorder showed {D.he} braked hard for half a second after the impact, then accelerated."],
        innocentTruths: ["The SUV's crash data recorder showed no braking at all, consistent with a driver who never saw what was hit."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(0, "7:48 a.m.: {V} hit in the crosswalk; SUV leaves."), (0, "Afternoon: {V} dies at the hospital."), (0, "Evening: trooper finds the SUV in {DL}'s garage.")],
            howIdentified: "Partial plates from two parents, then a door-to-door search of matching SUVs.",
            notDone: ["The SUV's crash data recorder was not downloaded before trial.", "No one tested how the sun looked from a driver's seat at that corner at 7:48 a.m."],
            defendantExam: [
                .direct("What happened?", "\"The sun was straight in my eyes. I couldn't see anything. There was a bang and the windshield cracked and I thought I'd hit the sign.\""),
                .direct("Why didn't you stop?", "\"I thought it was a sign post. I was late for a client. I was going to deal with the car later.\""),
                .cross("Your windshield cracked a foot from your face and you didn't stop?", "\"I know. I know how it sounds.\""),
                .cross("It was a school zone at drop-off.", "\"I drive it every day. I'd never seen a guard there before.\"", "\"Yes.\""),
                .cross("You couldn't see, and you kept driving at the same speed?", "\"I should have slowed down. I didn't.\"")
            ],
            prosecutionOpening: "A crossing guard with a stop sign raised, and a driver who went to a meeting.",
            defenseOpening: "The sun, a bang, and a driver who thought {D.he} hit a sign.",
            prosecutionClosing: "A person on the hood and a cracked windshield. {DL} knew, or should have known, and kept going.",
            defenseClosing: "The death-by-vehicle count answers for the crash. Leaving the scene requires knowledge, and the sun took that from {D.him}.",
            when: .months([9, 10, 11, 12, 1, 2, 3, 4, 5]),
            victimDied: true,
            victim: VictimFacts(age: 68, occupation: "school crossing guard", relationship: "Stranger", family: "Widowed; three grown children and seven grandchildren"),
            time: "7:48 a.m."
        )
    )

    // MARK: - Lot 9 at Pine Haven (a mobile home sold twice)

    static let mobileHomeSale = CaseTemplate(
        key: "story.mobileHomeSale", category: .whiteCollar,
        headlines: ["Family Paid $18,500 Cash for Mobile Home the Seller Didn't Own", "Mobile Home Sold to Two Families; Seller Charged"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Obtained $18,500 from {V} by falsely representing that {D.he} owned and could sell a mobile home at Lot 9, Pine Haven Mobile Home Park, on or about {DATE}.",
        ageRange: 35...62, occupations: ["handyman", "used car salesman", "property manager"], hasVictim: true,
        summaries: [
            "On {DATE}, {V} paid {D} $18,500 in cash for a 2004 single-wide at Lot 9 of Pine Haven Mobile Home Park, saved over three years. {D} handed over a bill of sale and said the title would come in the mail. It never did. Two months later a bank repossessed the home: the title was in {D}'s late mother's name, with a lien of $22,000 that hadn't been paid in a year. Records show {D} had sold the same home a year earlier to another buyer, who backed out and got half the money back. {DL} says {D.he} was the heir, believed {D.he} could sell it, and spent the money paying down the lien before the bank \"jumped the gun.\""
        ],
        prosecutionEvidence: [
            E(.document, 3, "Title and Lien", "The DMV title in the name of {DL}'s late mother, with a $22,000 bank lien and no payment in twelve months."),
            E(.document, 2, "Bill of Sale", "\"Sold to {V}, 2004 single-wide, Lot 9, $18,500 paid in full. Clear title to follow.\" Signed by {DL}."),
            E(.document, 2, "Bank Records", "Of the $18,500, $1,200 went to the lender. The rest went to a truck payment, a casino in Cherokee, and cash withdrawals.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Estate File", "{DL} is the only heir in {D.his} mother's estate file, opened eight months before the sale."),
            E(.document, 1, "Lender Payment", "A $1,200 payment from {DL} to the lender a week after the sale.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Buyer",
                        direct: ["\"{D.He} told me the title was clear. Those were {D.his} words.\""],
                        cross: ["\"I didn't run a title search. I didn't know you could.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you come up with $18,500?", "\"Three years of overtime at the plant and every tax refund. My kids had their own rooms for the first time.\"", "\"Three years. I worked every Saturday shift they had.\""),
                            .direct("What did {DL} tell you about the title?", "\"That it was clear and {D.he}'d mail it. I asked twice. {D.He} said the DMV was slow.\""),
                            .direct("What happened?", "\"A man from the bank knocked and said we had thirty days. We'd lived there two months. We're in a motel now.\""),
                            .cross("You didn't ask to see the title before paying?", "\"{D.He} showed me a bill of sale. I trusted {D.him}.\""),
                            .cross("You never asked about a lien?", "\"I didn't know what a lien was.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"About $1,200 of the $18,500 went to the lender.\""],
                        cross: ["\"{DL} is the legal heir.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the money go?", "\"Of the $18,500, $1,200 to the lender. Then a truck payment, about four thousand at a casino in Cherokee, and cash withdrawals.\""),
                            .direct("Had {DL} sold the home before?", "\"A year earlier, to another buyer, who backed out after a title search and got half back.\""),
                            .direct("Did {DL} know about the lien?", "\"The first buyer's title search showed it, and {DL} got a copy.\""),
                            .cross("{DL} is the only heir.", "\"{D.He} is. An heir inherits the debt with the home.\""),
                            .cross("{DL} made a payment to the lender.", "\"One, of $1,200, on a $22,000 lien.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Estate lawyer",
                        direct: ["\"An heir can sell estate property, with the right steps.\""],
                        cross: ["\"{DL} didn't take those steps.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Could {DL} sell the home?", "\"As the only heir, with the estate's authority and the lien paid off at closing, yes.\""),
                            .direct("Is it common for heirs to get this wrong?", "\"All the time. People think 'heir' means 'owner, free and clear.'\""),
                            .cross("Did {DL} pay off the lien at closing?", "\"No.\""),
                            .cross("Did {DL} tell the buyer about the lien?", "\"Not that I'm aware of.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew about the lien from the first failed sale, told {V} the title was clear, took $18,500, and gambled most of it."],
        defenseTheory: ["{D} was the heir and believed {D.he} could sell. {D.He} paid the lender and meant to clear it. A bad deal isn't a crime."],
        aggravating: ["The victim suffered serious financial loss"],
        mitigating: ["The defendant has made partial restitution"],
        victimImpacts: ["\"My kids asked if we're ever going home. I don't know what to tell them. That was every dollar we had.\""],
        allocutions: ["\"I thought I could make it right before anybody got hurt. I was wrong.\""],
        guiltyTruths: ["{DL} had listed the same home on Marketplace again the week after {V}'s sale."],
        innocentTruths: ["{DL} had an appointment with the lender to pay off the lien from an insurance payout that was delayed by a month."],
        moods: [.sympathetic], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-365, "First buyer backs out after a title search shows the lien."), (-240, "{DL}'s mother's estate opened."), (0, "{V} pays $18,500 cash; bill of sale signed."), (7, "{DL} pays the lender $1,200."), (60, "Bank repossesses the home.")],
            howIdentified: "{V} reported it after the bank's notice; {DL} signed the bill of sale.",
            notDone: ["No one interviewed the lender about whether {DL} ever called about a payoff."],
            defendantExam: [
                .direct("Did you believe you could sell the home?", "\"It was Mama's. I'm all that's left. I thought it was mine.\""),
                .direct("What about the lien?", "\"I was going to pay it out of the sale and the insurance money. The bank moved before I could.\""),
                .cross("You told {V} the title was clear.", "\"I told {V.him} it would be.\"", "\"I meant it would be clear.\""),
                .cross("$1,200 of $18,500 went to the bank. Four thousand went to a casino.", "\"I was trying to win enough to pay it off.\""),
                .cross("You knew about the lien from the first buyer.", "\"I knew there was some debt.\"")
            ],
            prosecutionOpening: "$18,500 for a home {DL} couldn't sell, and most of it gone in a week.",
            defenseOpening: "An heir who got in over {D.his} head.",
            prosecutionClosing: "{DL} knew about the lien, said the title was clear, and gambled the money. That's false pretenses.",
            defenseClosing: "{DL} believed it was {D.his} to sell. Bad judgment isn't intent to cheat.",
            victim: VictimFacts(age: 39, occupation: "poultry plant worker", relationship: "Stranger; answered a sign at the park", family: "Single parent of three"),
            family: "Divorced, no children at home.",
            residence: "A house in {HOOD} left by {D.his} mother"
        )
    )

    // MARK: - The pancake breakfast (money raised for a burned-out family)

    static let fakeFundraiser = CaseTemplate(
        key: "story.fakeFundraiser", category: .whiteCollar,
        headlines: ["Fire Victims Say They Never Saw Money Raised in Their Name", "Organizer Charged After Fundraiser for Burned-Out Family"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Obtained $7,400 from donors, including {V}, by falsely representing that the money would go to a family whose home burned, on or about {DATE}.",
        ageRange: 28...55, occupations: ["event planner", "church volunteer coordinator", "salon owner"], hasVictim: true,
        summaries: [
            "After a house fire in {HOOD} left a family of five with nothing, {D} set up an online fundraiser with photos of the burned house and organized a pancake breakfast at the fire hall on {DATE}. Donors gave $7,400 in all. {V}, a retired teacher, gave $500. The family received $600 in gift cards and was told the rest \"went to costs.\" Bank records show the online money and the breakfast cash went to {D}'s personal account, then to {D.his} rent, a car repair, and a beach weekend. {DL} says {D.he} was holding the rest for a deposit on a rental house for the family and spent some by mistake from the same account."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Records", "$7,400 in donations deposited to {DL}'s personal account. Withdrawals: rent, a $1,100 car repair, a beach rental, and $600 in gift cards.", .search),
            E(.digital, 2, "Fundraiser Page", "\"Every penny goes to the family.\" Posted by {DL}, with photos of the burned house."),
            E(.statement, 2, "Family's Statement", "The fire victims say they got $600 in gift cards and were told the rest went to costs.")
        ],
        defenseEvidence: [
            E(.digital, 2, "Rental Messages", "Messages from {DL} to a landlord asking about a three-bedroom rental \"for a family that lost everything.\""),
            E(.document, 1, "Breakfast Costs", "Receipts for $380 in food and supplies for the pancake breakfast.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Donor",
                        direct: ["\"I gave $500 because {D.he} said every penny went to the family.\""],
                        cross: ["\"I didn't know the family personally.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you give?", "\"I taught two of those children. I saw the pictures of the house. I gave $500 at the breakfast, in an envelope with the family's name on it.\""),
                            .direct("What were you told about the money?", "\"Every penny to the family. {D.He} said it at the door, and it was on the page.\""),
                            .direct("How did you feel when you learned what happened?", "\"Sick. I'm on a pension. That was money I'd saved for my own roof.\"", "\"Foolish, and then angry. I've given to every fundraiser in this town for forty years.\""),
                            .cross("You don't know whether {DL} meant to give them more later.", "\"I know they didn't get it.\""),
                            .cross("Some costs are normal for an event.", "\"Pancake mix doesn't cost seven thousand dollars.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"The money went to {DL}'s rent, car, and a beach rental.\""],
                        cross: ["\"{DL} did ask a landlord about a rental for the family.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the $7,400 go?", "\"Into {DL}'s personal account. Then rent, a $1,100 car repair, a beach rental, and $600 in gift cards for the family.\""),
                            .direct("What were the event costs?", "\"About $380 in receipts. The fire hall was donated.\""),
                            .direct("Did {DL} ever pay a rental deposit for the family?", "\"No. {D.He} asked one landlord about it once.\""),
                            .cross("{DL} gave the family $600.", "\"{D.He} did, out of $7,400.\""),
                            .cross("{DL} has no prior record.", "\"None.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fire hall volunteer",
                        direct: ["\"{DL} worked harder on that breakfast than anybody.\""],
                        cross: ["\"I never handled the money.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was {DL}'s role?", "\"{D.He} did everything: flyers, the page, the food, setup. {D.He} was there at five in the morning.\""),
                            .direct("Did {D.he} talk about the family?", "\"All the time. {D.He} said {D.he} wanted to get them into a real house, not a motel.\""),
                            .cross("You never saw where the money went.", "\"No.\""),
                            .cross("Did you know about the beach trip?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{D} used a family's fire to raise $7,400, told donors every penny was theirs, and spent most of it on {D.him}self."],
        defenseTheory: ["{D} meant to use the money for the family's rental deposit, mixed it into {D.his} own account, and spent some carelessly. That's a debt, not a fraud."],
        aggravating: ["The offense was committed against the public's charity"],
        mitigating: ["No prior criminal record", "The defendant has made partial restitution"],
        victimImpacts: ["\"I've lived here my whole life. This is a town that shows up when your house burns. You made people wonder if they should.\""],
        allocutions: ["\"I let it get mixed up with my own money and then it was gone. I'm going to pay back every cent.\""],
        guiltyTruths: ["{DL} had run a nearly identical fundraiser two years earlier in another county for a family that also never saw the money."],
        innocentTruths: ["{DL} had a signed lease and a deposit appointment for the family the week {D.he} was arrested, and paid the full $7,400 back from a loan within a month."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-21, "House fire in {HOOD}; family of five loses everything."), (-18, "{DL} starts the online fundraiser."), (0, "Pancake breakfast at the fire hall."), (30, "Family receives $600 in gift cards."), (75, "Family reports it; bank records subpoenaed.")],
            howIdentified: "The family and donors compared notes and went to the Sheriff's Office.",
            notDone: ["No one checked whether {DL} had run fundraisers before."],
            defendantExam: [
                .direct("What did you plan to do with the money?", "\"Get them into a rental. A deposit and first months' rent. I was talking to a landlord.\""),
                .direct("Why did it go into your own account?", "\"I didn't have another one. I thought I'd keep track.\""),
                .cross("A beach rental, {DL}.", "\"I know. I told myself I'd put it back.\""),
                .cross("Every penny goes to the family. Your words.", "\"I meant it when I wrote it.\""),
                .cross("Seven months later, they've gotten $600.", "\"Yes.\"")
            ],
            prosecutionOpening: "A burned-out family, a promise of every penny, and a beach weekend.",
            defenseOpening: "A volunteer who mixed money that should have been kept separate.",
            prosecutionClosing: "Every penny goes to the family. {DL} wrote that and spent the money on {D.him}self. That's the lie the law punishes.",
            defenseClosing: "{DL} did the work, gave the family something, and was looking for a house. Carelessness isn't fraud.",
            victim: VictimFacts(age: 71, occupation: "retired teacher", relationship: "Donor; did not know {DL}"),
            family: "Married, one child."
        )
    )

    // MARK: - Dr. Sato's pad (forged painkiller prescriptions)

    static let prescriptionPadForgery = CaseTemplate(
        key: "story.prescriptionPadForgery", category: .drugs,
        headlines: ["Dental Assistant Charged With Forging Painkiller Prescriptions", "Pharmacist Flags Oxycodone Scripts From Dentist's Stolen Pad"],
        primaryLaw: "prescriptionFraud", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Obtained oxycodone by fraud, by presenting forged prescriptions on the prescription pad of a Hollis County dentist, on {DATE} and on five earlier dates.",
        secondary: [
            SecondaryCharge(lawID: "forgery", specification: "Falsely made prescriptions bearing the signature of a licensed dentist, with intent to defraud.", chance: 1.0, threshold: 0)
        ],
        ageRange: 23...40, occupations: ["dental assistant", "dental office receptionist"], hasVictim: false,
        summaries: [
            "A pharmacist at {PHARM} noticed something wrong on {DATE}: a prescription for 30 oxycodone tablets from a dentist, for a patient who'd supposedly had a root canal, written in a dentist's name for a dose dentists almost never write. The pharmacist called the office. The dentist had never seen the patient. The state's prescription database showed six such scripts on the same dentist's pad in two months, at four pharmacies, for four different patient names, all picked up by a person who matched {D}, a dental assistant at the practice. Pharmacy cameras at two stores show {D}. {DL} says a former coworker forged them and asked {D.him} to pick them up for \"family members who couldn't drive.\""
        ],
        prosecutionEvidence: [
            E(.video, 3, "Pharmacy Cameras", "{D} at the counter at two pharmacies picking up oxycodone prescriptions in other people's names."),
            E(.document, 2, "Prescription Database", "Six oxycodone prescriptions on the dentist's pad in two months, 180 tablets in all. The dentist wrote none of them."),
            E(.document, 2, "Missing Pad", "The practice's records show a pad of 50 prescription sheets signed out to the front desk and never returned.")
        ],
        defenseEvidence: [
            E(.document, 2, "Handwriting", "A handwriting examiner found the forged signatures \"not consistent\" with {DL}'s writing samples."),
            E(.statement, 1, "Former Coworker", "{DL} names a former receptionist who was fired from the practice a month before the first script.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Pharmacist",
                        direct: ["\"Dentists don't write that.\""],
                        cross: ["\"I didn't see who wrote it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What made you call the dentist?", "\"Thirty oxycodone for a root canal. Most dentists write a few days of something weaker, if that. And the handwriting was too neat.\""),
                            .direct("What did the dentist tell you?", "\"Never heard of the patient. Never wrote it.\""),
                            .direct("Who picked it up?", "\"The same person who had picked up two others I found in our records, under different names. I recognized {D.him} from the camera.\""),
                            .cross("You didn't see who wrote the script.", "\"No.\""),
                            .cross("People pick up prescriptions for family all the time.", "\"They do. Not for four different families.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Narcotics detective",
                        direct: ["\"All six were picked up by {DL} or someone who looks just like {D.him}.\""],
                        cross: ["\"The handwriting expert didn't match {DL}.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the database show?", "\"Six oxycodone scripts on that dentist's pad in two months, at four pharmacies, under four patient names. 180 tablets.\""),
                            .direct("Were the patients real?", "\"Two were real people who'd never been to that dentist. Two names don't exist.\""),
                            .direct("Who had access to the pads?", "\"The front desk staff. {DL} covered the front desk on Fridays. Five of the six were filled on a Friday or Saturday.\""),
                            .cross("The handwriting doesn't match {DL}.", "\"No. Someone else may have written them. {DL} picked them up.\""),
                            .cross("Did you look at the fired receptionist?", "\"She'd moved to Georgia two weeks before the first one was filled.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Forensic document examiner",
                        direct: ["\"The signatures are not consistent with {DL}'s hand.\""],
                        cross: ["\"Disguised writing is possible.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you compare?", "\"The six forged signatures against twenty of {DL}'s writing samples. Letter forms, slant, pressure. Not consistent.\""),
                            .direct("What does 'not consistent' mean?", "\"I found no evidence {DL} wrote them.\""),
                            .cross("Can a writer disguise their hand?", "\"Yes. Forgers often do.\""),
                            .cross("Your opinion says nothing about who picked up the pills.", "\"That's right.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took a pad from the front desk, filled out scripts in fake and borrowed names, and picked up 180 oxycodone tablets at four pharmacies."],
        defenseTheory: ["Someone else wrote those prescriptions; the handwriting proves it. {D} was a go-between who believed {D.he} was picking up for family members."],
        aggravating: [],
        mitigating: ["The defendant has accepted responsibility", "The defendant has entered a drug treatment program"],
        victimImpacts: [],
        allocutions: ["\"I got hooked after my C-section and I couldn't stop. I'm in treatment now. I'm sorry for what I did to Dr. Sato's practice.\""],
        guiltyTruths: ["The missing prescription pad was found in {DL}'s glove box when {D.his} car was searched after trial in an unrelated stop."],
        innocentTruths: ["The fired receptionist's boyfriend later admitted he wrote the scripts and had {DL} pick them up, telling {D.him} they were for his sick relatives."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["PHARM": ["Harbor Mart Pharmacy", "Main Street Drug", "Bayard Family Pharmacy"]],
        story: StoryExtras(
            timeline: [(-60, "First forged script filled."), (-30, "Former receptionist fired; moves to Georgia two weeks later."), (0, "Pharmacist flags a script and calls the dentist."), (3, "Prescription database pulled; six scripts found; {DL} identified on camera.")],
            howIdentified: "Pharmacy cameras at two stores and the pharmacist's recognition.",
            notDone: ["The pad was never found.", "No one checked the fingerprints on the forged scripts."],
            defendantExam: [
                .direct("Who asked you to pick up the prescriptions?", "\"Someone I trusted. I don't want to say more than that.\""),
                .direct("Did you write any of them?", "\"No.\""),
                .cross("Four different names at four different pharmacies.", "\"I was told they were family.\""),
                .cross("You work at a dental office. You know dentists don't write thirty oxycodone.", "\"I'm an assistant, not a dentist.\""),
                .cross("Where did the pills go?", "\"I handed them over.\"", "\"Some of them I took. I'm not going to lie about that.\"")
            ],
            prosecutionOpening: "Six forged scripts and the same face at every counter.",
            defenseOpening: "The handwriting isn't {DL}'s.",
            prosecutionClosing: "{DL} didn't need to write them. {D.He} presented them, at four counters, under four names.",
            defenseClosing: "Someone else forged them. The State hasn't proved {DL} knew.",
            employer: "a Hollis County dental practice",
            employmentEnded: true,
            yearsAtJob: 3
        )
    )
}
