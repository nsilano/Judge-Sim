import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the batch AM everyday-crime stories.
extension FollowUpCases {
    static let batchAM: [CaseTemplate] = [gasDriveOffTwo, barBanTrespass, libraryBanScream, mowerResale, leashThreat, carClaimFalse,
                                          packageCardUse, golfCartTrespass, refusedIDAgain, oxyRefill, dineDashTwo, fenceKickAssault, walletCardGas]

    static let gasDriveOffTwo = followUp(
        key: "story.followup.gasDriveOffTwo", category: .property,
        headlines: ["Driver Skips Out on Gas Bill Again", "Second Gas Drive-Off Charge for Same Driver"],
        law: "misdLarceny", threshold: 5, spec: "Stole $71 in motor fuel from a gas station, on {DATE}.", ages: 19...58, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a different station's camera recorded {D} filling up at pump four and leaving without paying. The plate matched. {D} says the clerk waved {D.him} off.",
        state: [E(.video, 3, "Pump Camera", "{D} pumps $71 of fuel and drives off."), E(.document, 2, "Plate Return", "The plate is registered to {D}.")],
        defense: [E(.statement, 1, "Clerk's Wave", "{D} says the clerk waved at {D.him} through the window.")],
        witnessRole: "Gas station clerk",
        exam: [.direct("What happened?", "\"{DL} pumped $71 and left.\""), .direct("Did you wave?", "\"I waved at a friend. {DL} was just in the line of sight.\""),
               .cross("It could look like a wave off.", "\"Maybe.\""), .cross("{DL} came back?", "\"No.\"")],
        theory: ("{D} did it again at a new station.", "A wave misread."),
        allocution: "\"I'll pay both bills.\"", truths: ("The same plate left unpaid at two more stations.", "The clerk later said {D.he} had waved at {D.him}."),
        defendant: [.direct("Why did you leave?", "\"The clerk waved. I thought we were done.\""), .direct("Did you pay?", "\"No.\""),
                    .cross("After your last case.", "\"I know.\""), .cross("You didn't go in.", "\"I thought I had permission.\"")],
        openings: ("Another tank, another pump.", "A wave and a misunderstanding."), closings: ("Twice isn't a mistake.", "A clerk's wave."),
        timeline: [(0, "Night: second drive-off.")], identified: "A second station's camera.", impact: nil)

    static let barBanTrespass = followUp(
        key: "story.followup.barBanTrespass", category: .property,
        headlines: ["Man Banned From Bar Returns, Charged With Trespass", "Trespass Charge After Window Case"],
        law: "trespass2", threshold: 5, spec: "Entered and remained on the premises of a bar after being notified not to enter, on {DATE}.", ages: 21...54, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, the bar's owner told {D} in writing never to return. On {DATE}, {D} walked in, ordered a beer, and was arrested when the bartender called deputies. {D} says the owner had said the ban was over.",
        state: [E(.document, 3, "Written Ban", "A letter from the owner dated after the earlier case."), E(.statement, 2, "Bartender", "The bartender knew of the ban and called deputies.")],
        defense: [E(.statement, 1, "Truce", "{D} says the owner told {D.him} \"all forgiven\" two weeks earlier.")],
        witnessRole: "Bartender",
        exam: [.direct("What happened?", "\"{DL} walked in and ordered a beer. I knew about the ban.\""), .direct("Did you call deputies?", "\"Right away.\""),
               .cross("The owner said all forgiven?", "\"I didn't hear that.\""), .cross("{D.He} didn't cause trouble.", "\"No.\"")],
        theory: ("{D} walked into a bar {D.he} was banned from.", "A forgiven dispute."),
        allocution: "\"I thought we'd made peace.\"", truths: ("The owner had said, \"stay away for a year.\"", "The owner and {DL} had shaken hands at a church supper."),
        defendant: [.direct("Why did you go?", "\"The owner told me all was forgiven.\""), .direct("Was it written?", "\"No.\""),
                    .cross("You had a written ban.", "\"I forgot.\""), .cross("After your last case.", "\"I know.\"")],
        openings: ("A banned man at the bar.", "A handshake and a peace."), closings: ("The ban was written.", "A forgiven man."),
        timeline: [(0, "Evening: {DL} returns to the bar.")], identified: "The bartender's call.", impact: nil)

    static let libraryBanScream = followUp(
        key: "story.followup.libraryBanScream", category: .publicOrder,
        headlines: ["Man Banned From Library Disrupts Bus Stop Outside", "Disorderly Conduct Charge Follows Trespass Case"],
        law: "disorderly", threshold: 5, spec: "Engaged in disorderly conduct in a public place, yelling at passersby and blocking a bus shelter, on {DATE}.", ages: 22...66, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} stood outside the library for an hour yelling that the staff had \"stolen\" his reading. A bus driver reported {D} blocking the shelter and shouting at riders. {D} says he was speaking to himself.",
        state: [E(.video, 2, "Bus Camera", "{D} stands in the shelter, shouting, while riders wait in the street."), E(.statement, 2, "Driver", "{D} blocked the doors for two minutes.")],
        defense: [E(.document, 2, "Medical Note", "{D} has a documented anxiety disorder and sometimes talks aloud.")],
        witnessRole: "Bus driver",
        exam: [.direct("What did you see?", "\"A man yelling in the shelter. Riders stayed in the street.\""), .direct("Did he block the doors?", "\"For about two minutes.\""),
               .cross("Was he threatening anyone?", "\"Not directly.\""), .cross("He was talking to himself.", "\"Loudly.\"")],
        theory: ("{D} shouted at riders and blocked a bus shelter.", "A man with an anxiety disorder, talking aloud."),
        allocution: "\"I'm trying to get help.\"", truths: ("{DL} had skipped his medication that week.", "He had been waiting for a case worker who never came."),
        defendant: [.direct("What happened?", "\"I was upset about the ban.\""), .direct("Were you shouting at people?", "\"At the building.\""),
                    .cross("Riders stayed in the street.", "\"I didn't mean to scare anyone.\""), .cross("You were banned.", "\"I know.\"")],
        openings: ("An hour of shouting at a bus stop.", "A man, a disorder, and a bad week."), closings: ("A public disturbance.", "Illness, not defiance."),
        timeline: [(0, "Midday: {DL} outside the library; the bus arrives.")], identified: "The bus driver's report.", impact: nil)

    static let mowerResale = followUp(
        key: "story.followup.mowerResale", category: .property,
        headlines: ["Neighbor's Mower Surfaces at Flea Market; Seller Charged", "Second Mower Case for Same Neighbor Dispute"],
        law: "possStolen", threshold: 5, spec: "Possessed a push mower valued at $320 belonging to {V}, knowing and having reasonable grounds to believe it stolen, on {DATE}.", ages: 28...68, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V}'s push mower vanished from a shed. It turned up at a weekend flea market where {D} was the seller. {D} says {D.he} found it at the curb.",
        state: [E(.physical, 3, "The Mower", "{V}'s mower with a serial match, for sale at {D}'s table.", .search), E(.statement, 2, "Buyer", "A buyer says {D} asked $80 and said it was his own.")],
        defense: [E(.statement, 1, "Curb", "{D} says it was set out for trash.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("Where did you find it?", "\"On {DL}'s table at the flea market.\""), .direct("What did {D.he} say?", "\"That it was {D.his} own.\""),
               .cross("{D.He} said it was on the curb.", "\"That's a different story from the buyer's.\""), .cross("Serial plate matched?", "\"It did.\"")],
        theory: ("{D} sold a neighbor's mower and said it was his.", "A curbside find."),
        allocution: "\"I shouldn't have sold it.\"", truths: ("{DL} was seen carrying a mower from {V}'s shed.", "{V}'s son had set the mower out for trash."),
        defendant: [.direct("Where did you get it?", "\"The curb.\""), .direct("Why say it was yours?", "\"To get a better price.\""),
                    .cross("After your last case.", "\"I know.\""), .cross("The serial matches.", "\"I didn't look.\"")],
        openings: ("A mower with the neighbor's number.", "A curbside find."), closings: ("Twice with the same neighbor.", "A bargain at a flea market."),
        timeline: [(0, "Weekend: mower for sale at the flea market.")], identified: "The buyer's call.", impact: "\"It's the second time something of mine ended up at a flea market.\"")

    static let leashThreat = followUp(
        key: "story.followup.leashThreat", category: .publicOrder,
        headlines: ["Dog Walk Dispute Turns to Threats", "Park Threat Charge After Earlier Assault Case"],
        law: "communicatingThreats", threshold: 5, spec: "Willfully threatened to physically injure {V}, in a manner a reasonable person would believe would be carried out, on {DATE}.", ages: 24...68, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} saw {V} at the same park and said, \"I'll put you on the ground again.\" {V} recorded the last words on a phone.",
        state: [E(.digital, 3, "Phone Recording", "{D}: \"I'll put you on the ground again.\""), E(.statement, 2, "Walker", "A walker heard it.")],
        defense: [E(.statement, 1, "Joke", "{D} says it was a joke between neighbors.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("What does the recording say?", "\"'I'll put you on the ground again.'\""), .direct("What did {V} do?", "\"Left the park and called us.\""),
               .cross("{D.He} was smiling.", "\"We can't tell.\""), .cross("Nothing happened.", "\"No.\"")],
        theory: ("{D} threatened {V} with another fall.", "A bad joke."),
        allocution: "\"I'm sorry. I'll stay out of that park.\"", truths: ("{DL} followed {V} to the car.", "{V} had laughed first, a walker said."),
        defendant: [.direct("What did you mean?", "\"Nothing. It was a joke.\""), .direct("Why say it?", "\"I was nervous.\""),
                    .cross("After your last case.", "\"I know.\""), .cross("{V} didn't laugh.", "\"No.\"")],
        openings: ("A threat, recorded.", "A joke gone wrong."), closings: ("A reasonable person would believe it.", "Words without harm."),
        timeline: [(0, "Afternoon: {DL} meets {V} at the park.")], identified: "{V}'s recording.", impact: "\"I walk my dog before dawn now.\"")

    static let carClaimFalse = followUp(
        key: "story.followup.carClaimFalse", category: .whiteCollar,
        headlines: ["Insurance Claim Filed on Car Found at Girlfriend's House", "Insurance Fraud Charge After False Stolen Car Report"],
        law: "insuranceFraud", threshold: 6, spec: "Knowingly and with intent to defraud presented a written statement to an insurer, that {D.his} car had been stolen, in support of a claim for $9,400, on {DATE}.", ages: 20...58, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} filed a claim with the insurer saying the car had never been recovered, though a deputy had found it. The insurer paid $9,400, then learned the truth.",
        state: [E(.document, 3, "Claim Form", "{D} swore the car was not recovered; the deputy report says it was."), E(.document, 2, "Payment", "$9,400 paid to {D}.")],
        defense: [E(.statement, 1, "Paperwork Mix-Up", "{D} says the insurer never told {D.him} the car had been found.")],
        witnessRole: "Insurance special investigator",
        exam: [.direct("What did {DL} swear?", "\"That the car was never recovered.\""), .direct("What did the sheriff's report say?", "\"It was found two days after the report.\""),
               .cross("The insurer didn't tell {D.him}.", "\"They sent a letter.\""), .cross("{D.He} may not have read it.", "\"Possible.\"")],
        theory: ("{D} swore to a false claim and took $9,400.", "A paperwork mix-up."),
        allocution: "\"I'll pay it back.\"", truths: ("{DL} sold the car for parts after the payment.", "The letter was addressed to the old apartment."),
        defendant: [.direct("Did you know it was found?", "\"No.\"", "\"I figured it was.\""), .direct("Why file?", "\"I needed the money.\""),
                    .cross("After your last case.", "\"I know.\""), .cross("You sold the car.", "\"I didn't think about it.\"")],
        openings: ("A claim on a car that was found.", "A mailing that missed."), closings: ("The car was found, and he took the money.", "No intent to deceive."),
        timeline: [(0, "Claim paid.")], identified: "The insurer's special investigations unit.", impact: nil)

    static let packageCardUse = followUp(
        key: "story.followup.packageCardUse", category: .whiteCollar,
        headlines: ["Card From Stolen Package Used at Dollar Store", "Card Fraud Charge After Porch Package Case"],
        law: "cardFraud", threshold: 5, spec: "Used a debit card belonging to {V}, a card issued in another person's name, to obtain $188 in goods, without consent, on {DATE}.", ages: 18...50, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V}'s new debit card, mailed in a stolen envelope, was used three times at a dollar store for $188. The store camera showed {D}.",
        state: [E(.video, 3, "Store Camera", "{D} swipes the card three times."), E(.document, 2, "Bank Record", "Three charges totaling $188.")],
        defense: [E(.statement, 1, "Found Card", "{D} says {D.he} found the card on a sidewalk.")],
        witnessRole: "Dollar store clerk",
        exam: [.direct("What did you see?", "\"{DL} swiping a debit card three times.\""), .direct("Did {D.he} sign?", "\"No signature was needed.\""),
               .cross("{D.He} was polite.", "\"Very.\""), .cross("{D.He} had a PIN.", "\"No. {D.He} used the credit option.\"")],
        theory: ("{D} used a card that arrived in a stolen envelope.", "A found card."), allocution: "\"I'm sorry. I thought it was a gift card.\"",
        truths: ("The envelope was found in {DL}'s trash.", "The envelope had been dropped on a sidewalk by a mail carrier."),
        defendant: [.direct("Where did you get the card?", "\"The sidewalk.\""), .direct("Why use it?", "\"I thought it was a gift card.\""),
                    .cross("After your last case.", "\"I know.\""), .cross("Three swipes.", "\"I was shopping.\"")],
        openings: ("A card from a stolen package.", "A card on the sidewalk."), closings: ("Three swipes, one thief.", "A found card."),
        timeline: [(0, "Afternoon: card used three times.")], identified: "The dollar store's camera.", impact: "\"My new card, stolen from my mailbox, used within a day.\"")

    static let golfCartTrespass = followUp(
        key: "story.followup.golfCartTrespass", category: .property,
        headlines: ["Teen From Golf Cart Case Back on Same Subdivision Lot", "Trespass Charge After Golf Cart Ride"],
        law: "trespass2", threshold: 5, spec: "Entered and remained on the premises of {V}, a private subdivision pond, after being notified not to enter, on {DATE}.", ages: 18...24, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} was found at 1 a.m. sitting by the same retention pond with a friend, after the homeowners' association had put up \"No Trespassing\" signs. {D} says he was walking home.",
        state: [E(.document, 2, "Posted Signs", "Three new signs at the pond path."), E(.statement, 2, "Association Letter", "{D} was told in writing to stay out.")],
        defense: [E(.statement, 1, "Walking Home", "{D} says the pond is on his usual route.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("Where was {DL}?", "\"Sitting by the pond at 1 a.m.\""), .direct("Was there a sign?", "\"Three.\""),
               .cross("{D.He} was walking home.", "\"By the pond?\""), .cross("Nothing was damaged.", "\"No.\"")],
        theory: ("{D} was told to stay out and sat by the pond.", "A route home."), allocution: "\"I'll find another way home.\"",
        truths: ("{DL} had thrown rocks into the pond that night.", "The pond path was the only route to {D.his} apartment."),
        defendant: [.direct("Why were you there?", "\"Walking home.\""), .direct("Did you see the signs?", "\"Not at night.\""),
                    .cross("After the golf cart.", "\"I know.\""), .cross("You sat down.", "\"I was tired.\"")],
        openings: ("A pond, a sign, and a teen.", "The only way home."), closings: ("He was told.", "He lived there."),
        timeline: [(0, "1 a.m.: {DL} found at the pond.")], identified: "A patrolling deputy.", impact: nil)

    static let refusedIDAgain = followUp(
        key: "story.followup.refusedIDAgain", category: .publicOrder,
        headlines: ["Man Who Refused ID Last Time Does It Again", "Second Resisting Charge After Refusal to Identify"],
        law: "resisting", threshold: 5, spec: "Willfully resisted, delayed, and obstructed a public officer, a sheriff's deputy, by refusing to identify {D.himself} during a lawful stop, on {DATE}.", ages: 24...62, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} was stopped at a gas station parking lot after a clerk reported a man sleeping in a car. {D} again refused to give a name. The deputy had a camera running.",
        state: [E(.video, 3, "Body Camera", "The deputy asks for a name three times; {D} refuses."), E(.document, 2, "Clerk's Report", "A man sleeping in a car for two hours.")],
        defense: [E(.statement, 1, "Rights", "{D} says he's not required to give a name.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("What happened?", "\"I asked three times for a name. {DL} said no.\""), .direct("Was there a lawful reason for the stop?", "\"A report of a man asleep in a car.\""),
               .cross("{DL} stayed calm.", "\"Yes.\""), .cross("Was he a danger?", "\"No.\"")],
        theory: ("{D} refused again, after the court explained the law.", "A man asserting rights."), allocution: "\"I'll answer next time.\"",
        truths: ("{DL} had a warrant in another county.", "The clerk's call was a mistake; {D} was waiting for a tow."),
        defendant: [.direct("Why refuse?", "\"I don't have to.\""), .direct("Did you remember the last case?", "\"I did.\""),
                    .cross("You knew the risk.", "\"I know.\""), .cross("Three requests.", "\"Yes.\"")],
        openings: ("Three requests, three refusals.", "A calm man with rights."), closings: ("He knew the law.", "No crime was reported."),
        timeline: [(0, "Afternoon: deputy approaches the parked car.")], identified: "The deputy's body camera.", impact: nil)

    static let oxyRefill = followUp(
        key: "story.followup.oxyRefill", category: .drugs,
        headlines: ["Woman Charged With Altering Prescription for Pills", "Prescription Fraud Charge After Pill Bottle Case"],
        law: "prescriptionFraud", threshold: 6, spec: "Obtained a controlled substance by altering a prescription, changing a quantity from 10 to 40, on {DATE}.", ages: 25...64, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} handed a pharmacist a prescription whose quantity had been changed from 10 to 40. The pharmacist called the doctor's office, which had written 10.",
        state: [E(.document, 3, "Altered Prescription", "A \"1\" changed to a \"4\" in a different pen."), E(.statement, 2, "Doctor's Office", "The doctor wrote 10, not 40.")],
        defense: [E(.statement, 1, "Pain", "{D} says her back pain was unbearable and she didn't alter the paper.")],
        witnessRole: "Pharmacist",
        exam: [.direct("What did you notice?", "\"The 4 was in a different ink.\""), .direct("What did the doctor say?", "\"Ten.\""),
               .cross("Anyone could have altered it.", "\"{DL} handed it to me.\""), .cross("{D.He} wasn't hostile.", "\"No.\"")],
        theory: ("{D} altered a prescription to get thirty more pills.", "A handed-over paper that was already changed."),
        allocution: "\"I'm in pain and I made a terrible choice.\"", truths: ("{DL}'s pen matched the ink on the 4.", "The doctor's receptionist had changed the number herself and corrected it later."),
        defendant: [.direct("Did you alter it?", "\"No.\"", "\"Yes. I was in pain.\""), .direct("Where did you get it?", "\"From the doctor.\""),
                    .cross("After the bottle case.", "\"I know.\""), .cross("Ink was different.", "\"I don't know.\"")],
        openings: ("A one turned into a four.", "A paper handed over as it was."), closings: ("The ink gives it away.", "No proof who changed it."),
        timeline: [(0, "Afternoon: prescription presented.")], identified: "The pharmacist's call.", impact: nil)

    static let dineDashTwo = followUp(
        key: "story.followup.dineDashTwo", category: .property,
        headlines: ["Same Pair Skips Out on Another Diner Bill", "Second Walk-Out Charge for Diner Case Defendant"],
        law: "misdLarceny", threshold: 5, spec: "Stole $58 in food and service from a restaurant, on {DATE}.", ages: 19...52, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} and the same friend ate at a pizza place and left through a side door. The owner remembered the faces from a sheriff's flyer.",
        state: [E(.video, 3, "Restaurant Camera", "Two people leave through a side door without paying."), E(.document, 2, "Flyer", "A sheriff's flyer posted at three restaurants.")],
        defense: [E(.statement, 1, "Phone Call", "{D} says he stepped outside to take a phone call.")],
        witnessRole: "Restaurant owner",
        exam: [.direct("Who was it?", "\"The two from the flyer.\""), .direct("Which door?", "\"The side door.\""),
               .cross("{DL} took a call.", "\"He left with his friend.\""), .cross("They came back?", "\"No.\"")],
        theory: ("{D} did it again at a new restaurant.", "A phone call."), allocution: "\"I'll pay it.\"",
        truths: ("The pair had a list of restaurants taped inside a car window.", "{D}'s friend paid the check the next day."),
        defendant: [.direct("Why leave?", "\"A call.\""), .direct("Did you pay?", "\"My friend did later.\""),
                    .cross("After the last case.", "\"I know.\""), .cross("You left through a side door.", "\"It was closer.\"")],
        openings: ("The faces from the flyer.", "A phone call."), closings: ("Twice.", "Paid the next day."),
        timeline: [(0, "Evening: a second walk-out.")], identified: "The owner's memory of a flyer.", impact: nil)

    static let fenceKickAssault = followUp(
        key: "story.followup.fenceKickAssault", category: .violent,
        headlines: ["Fence Dispute Neighbors Scuffle Over New Posts", "Simple Assault After Fence Case"],
        law: "simpleAssault", threshold: 5, spec: "Assaulted {V} by shoving {V.him} against a truck, on {DATE}.", ages: 30...68, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V} installed new fence posts and {D} came over to stop {V.him}. According to {V}, {D} shoved {V.him} against a truck. {D} says {V} lunged first.",
        state: [E(.video, 3, "Doorbell Camera", "{D} puts both hands on {V} and pushes {V.him} against the truck."), E(.statement, 2, "Neighbor", "A neighbor saw {D}'s hands go out.")],
        defense: [E(.statement, 1, "Lunge", "{D} says {V} lunged with a post hole digger.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("What does the camera show?", "\"{D} pushing {V} into the truck.\""), .direct("Did {V} have a tool?", "\"A post hole digger in {V.his} hand.\""),
               .cross("{V} lunged.", "\"I can't tell.\""), .cross("Was {V} hurt?", "\"A bruise.\"")],
        theory: ("{D} shoved {V} after a court order.", "A man with a tool lunging."), allocution: "\"I lost my temper over a fence again.\"",
        truths: ("{V} had said he'd \"see {D} in court again.\"", "{V} had swung the digger first, a second angle shows."),
        defendant: [.direct("What happened?", "\"{V} came at me with the digger.\""), .direct("Did you push {V.him}?", "\"I put my hands out.\""),
                    .cross("After the fence case.", "\"I know.\""), .cross("A bruise.", "\"I'm sorry.\"")],
        openings: ("A shove at a fence line.", "A digger and a lunge."), closings: ("Again.", "He protected himself."),
        timeline: [(0, "Saturday: new posts; the scuffle.")], identified: "{V}'s doorbell camera.", impact: "\"I can't use my yard in peace.\"")

    static let walletCardGas = followUp(
        key: "story.followup.walletCardGas", category: .whiteCollar,
        headlines: ["Card Used at Same Gas Station After Found Wallet Case", "Second Card Fraud Charge for Finder"],
        law: "cardFraud", threshold: 5, spec: "Used a credit card belonging to {V}, a card issued in another person's name, to obtain $96 in fuel, without consent, on {DATE}.", ages: 19...58, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a card stolen from {V}'s truck was used for $96 in fuel. The pump camera showed {D}'s truck. {D} says he bought the card from a man.",
        state: [E(.video, 3, "Pump Camera", "{D}'s truck at pump three; the card is swiped."), E(.document, 2, "Card Record", "Reported stolen the day before.")],
        defense: [E(.statement, 1, "Bought Card", "{D} says he bought the card for $20.")],
        witnessRole: "Sheriff's detective",
        exam: [.direct("Whose truck?", "\"{DL}'s.\""), .direct("Who owned the card?", "\"{V}.\""),
               .cross("{D.He} says he bought it.", "\"From a man he can't name.\""), .cross("Did {D.he} know it was stolen?", "\"A $20 card? Yes.\"")],
        theory: ("{D} used a stolen card for gas.", "A bought card and a naive buyer."), allocution: "\"I'm trying to get out of this.\"",
        truths: ("{DL} had bought two other cards from the same man.", "The seller was arrested later with forty cards."),
        defendant: [.direct("Why use it?", "\"I bought it. I thought it was good.\""), .direct("Who sold it?", "\"A man outside the store.\""),
                    .cross("After the wallet case.", "\"I know.\""), .cross("$20 for a card.", "\"It was cheap.\"")],
        openings: ("Fuel, a stolen card, and a truck.", "A cheap card from a stranger."), closings: ("He knew.", "He didn't."),
        timeline: [(0, "Afternoon: fuel bought on a stolen card.")], identified: "The pump camera.", impact: "\"Another card, another fraud. I keep my cards in my hand now.\"")
}
