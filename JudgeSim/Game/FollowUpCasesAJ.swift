import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the batch AJ stories, built with the shared `followUp` helper in FollowUpCasesAF.
extension FollowUpCases {
    static let batchAJ: [CaseTemplate] = [parlorSecondRobbery, barnNeighborThreat, raffleMoney, trailerCattle, bouncerSecondFight]

    // MARK: - After the sweepstakes parlor

    static let parlorSecondRobbery = followUp(
        key: "story.followup.parlorSecondRobbery", category: .robbery,
        headlines: ["Convenience Store Clerk Robbed; Suspect Has Prior Parlor Case", "Second Robbery Charge for Man in Sweepstakes Case"],
        law: "commonLawRobbery", threshold: 6, spec: "Took $412 from the person and presence of {V}, a store clerk, by violence and putting {V.him} in fear, on {DATE}.", ages: 19...42, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} walked into a convenience store on {STREET} at 3 a.m. on {DATE}, reached across the counter, shoved the clerk, {V}, into the cigarette rack, and grabbed $412 from the open drawer. No weapon this time. The store's camera caught the face clearly, and {V} picked {DL} from a photo lineup the next day.",
        state: [E(.video, 3, "Store Camera", "A clear view of the robber's face as he leans across the counter and shoves {V}."),
                E(.document, 2, "Photo Lineup", "{V} picked {DL} from six photos, 90 percent sure, the morning after.")],
        defense: [E(.statement, 1, "Alibi", "{DL}'s girlfriend says {D.he} was asleep beside her at 3 a.m.")],
        witnessRole: "Police detective",
        exam: [.direct("What does the camera show?", "\"A clear face, leaning over the counter, a shove, the drawer.\""),
               .direct("How was the lineup run?", "\"Double-blind. The officer showing the photos didn't know which one was {DL}.\""),
               .cross("The girlfriend says {DL} was home.", "\"She also told us she was asleep.\""),
               .cross("No weapon this time.", "\"No. Just a shove into a metal rack.\"")],
        theory: ("{D} shoved a clerk into a rack and took the drawer, and the camera got {D.his} face.", "A stranger on a camera and an alibi the State can't disprove."),
        allocution: "\"I'm not going to lie this time. I need help with the gambling.\"",
        truths: ("{DL}'s phone pinged the tower behind the store at 2:58 a.m.",
                 "A cousin who looks much like {DL} was arrested in the next county with the store's bank bag."),
        defendant: [.direct("Where were you at 3 a.m.?", "\"Home in bed.\""),
                    .direct("Is that you on the video?", "\"It looks like me. It isn't.\""),
                    .cross("After your last case, you were told to stay away from gambling places.", "\"This was a gas station.\""),
                    .cross("The clerk picked you out of six photos.", "\"The clerk was scared.\"")],
        openings: ("A clear face on a camera and a clerk shoved into a rack.", "A look-alike and a man asleep at home."),
        closings: ("The face, the lineup, the phone. It's {DL}.", "Looking like someone isn't proof beyond a reasonable doubt."),
        timeline: [(0, "3:02 a.m.: robbery."), (1, "Photo lineup; {V} picks {DL}.")],
        identified: "The store camera and a photo lineup.",
        impact: "\"My shoulder still pops when I lift the drink crates.\"",
        doctrines: ["eyewitnessID", "burdenOfProof"])

    // MARK: - After the tobacco barn

    static let barnNeighborThreat = followUp(
        key: "story.followup.barnNeighborThreat", category: .publicOrder,
        headlines: ["Farmer Charged With Threatening Neighbor Who Testified About Barn Fire", "Threat Charge Follows Barn Fire Case"],
        law: "communicatingThreats", threshold: 5, spec: "Willfully threatened to burn the home of {V}, a witness in an earlier case, in a manner a reasonable person would believe would be carried out, on {DATE}.", ages: 40...72, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} drove to the farm of {V}, a neighbor who had talked to the fire investigator, and said across the fence: \"You know how fast an old house goes up. Think about that tonight.\" {V}'s teenage son recorded the last part on his phone.",
        state: [E(.video, 3, "Phone Video", "{D} at the fence: \"Think about that tonight.\""),
                E(.statement, 2, "Son's Account", "The son heard the first part: \"You know how fast an old house goes up.\"")],
        defense: [E(.statement, 1, "Context", "{DL} says {D.he} was talking about {V}'s own wiring, which {D.he} had warned {V} about for years.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("What did {V} do after?", "\"Sat up all night with a shotgun and the porch light on, then called us at dawn.\""),
               .direct("Had {DL} said anything about wiring before?", "\"Not that {V} ever mentioned.\""),
               .cross("The video only has the last sentence.", "\"The son heard the first one.\""),
               .cross("'Think about that' isn't a promise to do anything.", "\"After a barn fire case, it is.\"")],
        theory: ("{D} told a witness against {D.him} how fast an old house burns, and to think about it tonight.", "A warning about bad wiring, overheard in pieces by a teenager."),
        allocution: "\"I lost my temper at a man I thought turned on me.\"",
        truths: ("{DL} drove past {V}'s house three more times that night, a neighbor's camera showed.",
                 "{DL}'s electrician confirmed {D.he} had told {V} about the wiring twice the year before."),
        defendant: [.direct("What did you mean?", "\"That {V}'s wiring would burn that house down someday.\""),
                    .direct("Why go over there?", "\"To tell {V.him} I knew what {V.he} said about me.\""),
                    .cross("'Think about that tonight.'", "\"I was angry.\""),
                    .cross("You'd just been tried for burning a building.", "\"That's why I was angry.\"")],
        openings: ("A threat to a witness, from a man just tried for arson.", "A warning about old wiring."),
        closings: ("A reasonable person would believe it. {V} sat up all night believing it.", "Angry words aren't a threat to burn anything."),
        timeline: [(0, "Evening: {DL} at {V}'s fence."), (1, "{V} reports it at dawn.")],
        identified: "The son's phone video.",
        impact: "\"I put cameras on every corner of the house. My wife won't stay there alone.\"")

    // MARK: - After the fire department money

    static let raffleMoney = followUp(
        key: "story.followup.raffleMoney", category: .whiteCollar,
        headlines: ["Church Raffle Money Missing; Former Fire Department Treasurer Charged", "Second Embezzlement Case for Former Treasurer"],
        law: "embezzlement", threshold: 6, spec: "Being entrusted as a volunteer with funds of a church raffle, fraudulently embezzled $4,800, on {DATE}.", ages: 35...68, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a church in {HOOD} let {D} volunteer to sell raffle tickets for a truck to benefit its food pantry. {D} sold 480 tickets at $10 and turned in $1,200. The church's pastor found the ticket stubs: 480 names, phone numbers, and dates. A casino player's card shows {DL} buying in for $3,500 the weekend before the drawing.",
        state: [E(.document, 3, "Ticket Stubs", "480 stubs, each $10, in {DL}'s handwriting."),
                E(.document, 3, "Casino Records", "$3,500 in buy-ins on {DL}'s player's card the weekend before the drawing.")],
        defense: [E(.statement, 1, "Unpaid Tickets", "{DL} says many buyers promised to pay later and never did.")],
        witnessRole: "Pastor",
        exam: [.direct("What did you find?", "\"Four hundred eighty stubs. I called sixty buyers. Every one said they paid cash.\""),
               .direct("Did you know about {DL}'s earlier case?", "\"Yes. We believe in second chances. Maybe too much.\""),
               .cross("Some people do promise to pay later.", "\"Not one of the sixty I called.\""),
               .cross("You didn't call the other 420.", "\"No.\"")],
        theory: ("{D} sold $4,800 in raffle tickets, turned in $1,200, and went to the casino.", "Unpaid tickets and a church that never set up any controls."),
        allocution: "\"I'm in a treatment program now. I'll pay the church back.\"",
        truths: ("{DL}'s bank deposit slip for $3,400 in cash, dated the day after ticket sales ended, turned up in a later search.",
                 "The church secretary, who counted the money alone, was found to have kept part of it."),
        defendant: [.direct("How many tickets were paid?", "\"Maybe a third. People said they'd pay at the drawing.\""),
                    .direct("And the casino?", "\"I go sometimes.\""),
                    .cross("Sixty buyers say they paid cash.", "\"Some did.\""),
                    .cross("After your last case, you volunteered to handle cash again.", "\"They asked me.\"")],
        openings: ("Raffle money for a food pantry, gone to a casino.", "Unpaid tickets and no controls."),
        closings: ("Four hundred eighty stubs and twelve hundred dollars. The difference went to Cherokee.", "Nobody knows how many tickets were really paid."),
        timeline: [(-30, "Raffle sales begin."), (-3, "Casino buy-ins."), (0, "{DL} turns in $1,200 at the drawing.")],
        identified: "The ticket stubs and the casino records.",
        impact: nil)

    // MARK: - After the cattle sale

    static let trailerCattle = followUp(
        key: "story.followup.trailerCattle", category: .property,
        headlines: ["Stock Trailer Stolen From Sale Barn Lot", "Cattle Case Defendant Charged in Trailer Theft"],
        law: "felonyLarceny", lesser: "misdLarceny", threshold: 6, spec: "Stole a 20-foot livestock trailer valued at $9,500 belonging to {V}, on {DATE}.", ages: 28...62, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V}'s 20-foot stock trailer disappeared from the Hollis Livestock Market's lot on a Tuesday night. A month later a deputy spotted it behind {D}'s barn with the VIN plate pried off and the fenders painted red. {DL} says {D.he} bought it for $2,000 cash from a man at a gas station.",
        state: [E(.physical, 3, "The Trailer", "The VIN plate pried off; the hidden frame VIN matches {V}'s trailer."),
                E(.document, 2, "Value", "A 2019 20-foot gooseneck stock trailer, valued at $9,500.")],
        defense: [E(.statement, 1, "Purchase", "{DL} says {D.he} paid $2,000 cash to a stranger and got no title.")],
        witnessRole: "Sheriff's deputy",
        exam: [.direct("How did you identify the trailer?", "\"Manufacturers stamp a second VIN on the frame. It matched {V}'s.\""),
               .direct("What had been done to it?", "\"VIN plate pried off, fenders painted red over silver.\""),
               .cross("{DL} says {D.he} bought it.", "\"No title, no bill of sale, no name for the seller.\""),
               .cross("Painting fenders isn't a crime.", "\"Prying off a VIN plate is a sign.\"")],
        theory: ("{D} took {V}'s trailer from the sale barn lot, pried off the VIN, and painted it.", "{D} bought a trailer too cheap from a stranger. That's foolish, not theft."),
        allocution: "\"I should have known better than to buy without a title.\"",
        truths: ("The sale barn's lot camera showed {DL}'s truck hitching the trailer at 11 p.m.",
                 "A man arrested in Virginia for a string of trailer thefts named {DL} as one of his buyers."),
        defendant: [.direct("Where did you get the trailer?", "\"A man at a gas station on Route 17 sold it for two thousand cash.\""),
                    .direct("Who pried off the plate?", "\"It was like that when I got it.\""),
                    .cross("A $9,500 trailer for $2,000 cash and no title.", "\"I thought it was a deal.\""),
                    .cross("You painted the fenders.", "\"They were rusty.\"")],
        openings: ("A stolen trailer behind {DL}'s barn with its VIN pried off.", "A bad bargain from a stranger."),
        closings: ("The plate was pried and the fenders painted. That's hiding, not buying.", "The State never puts {DL} at that lot."),
        timeline: [(0, "Tuesday night: trailer taken from the sale barn lot."), (30, "Deputy finds it behind {DL}'s barn.")],
        identified: "The hidden frame VIN.",
        impact: "\"That trailer's how I haul my calves. I rented one for six weeks.\"")

    // MARK: - After the flashlight

    static let bouncerSecondFight = followUp(
        key: "story.followup.bouncerSecondFight", category: .violent,
        headlines: ["Former Bouncer Charged in Second Alley Fight", "Patron's Jaw Broken Outside Bar; Security Guard Charged"],
        law: "aisi", threshold: 5, spec: "Assaulted {V}, inflicting serious injury, a broken jaw, on {DATE}.", ages: 23...47, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} took a security job at another bar. On {DATE}, {D} punched {V}, a customer who'd been thrown out, after {V} came back to the door yelling. {V}'s jaw broke in two places. A door camera shows {V} with {V.his} hands in {V.his} pockets when {D} swung.",
        state: [E(.video, 3, "Door Camera", "{V} stands yelling with hands in pockets; {D} steps out and punches."),
                E(.document, 2, "Medical Records", "Jaw fractured in two places; wired shut six weeks.")],
        defense: [E(.statement, 1, "Threat", "{DL} says {V} said \"I've got something for you\" and reached in a pocket.")],
        witnessRole: "Police officer",
        exam: [.direct("What does the camera show?", "\"{V} yelling, hands in pockets the whole time. {DL} steps out and hits {V.him}.\""),
               .direct("Did {V} have anything?", "\"A phone and a lighter.\""),
               .cross("Hands in pockets can hide a weapon.", "\"They can. These didn't.\""),
               .cross("{V} came back after being thrown out.", "\"Yelling isn't a reason to break a jaw.\"")],
        theory: ("{D} broke a yelling man's jaw while {V.his} hands were in {V.his} pockets.", "Another threat, another reach, and a guard who'd learned what a pocket can hold."),
        allocution: "\"After the last time, every pocket looks like a knife to me.\"",
        truths: ("A coworker said {DL} told him, \"I'm not waiting to see what comes out of a pocket again,\" before stepping outside.",
                 "{V} admitted at a later civil deposition that {V.he} had a box cutter in that pocket and meant to use it."),
        defendant: [.direct("Why did you swing?", "\"{V.He} said '{V.he} had something for me' and went in {V.his} pocket.\""),
                    .direct("Did you see a weapon?", "\"I didn't wait to.\""),
                    .cross("{V}'s hands never came out of the pockets.", "\"I couldn't know that.\""),
                    .cross("Your last case was the same thing.", "\"That's why I'm careful.\"")],
        openings: ("A broken jaw, and hands that never left the pockets.", "A threat and a reach, again."),
        closings: ("You don't get to hit first because of the last fight.", "{DL} had a second to decide, again."),
        timeline: [(0, "12:40 a.m.: {V} thrown out; 12:55 a.m.: returns; punch.")],
        identified: "The door camera.",
        impact: "\"I ate through a straw for six weeks.\"",
        doctrines: ["selfDefense", "burdenOfProof"])
}
