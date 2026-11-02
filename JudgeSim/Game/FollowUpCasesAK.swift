import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the batch AK stories, built with the shared `followUp` helper in FollowUpCasesAF.
extension FollowUpCases {
    static let batchAK: [CaseTemplate] = [chainsawResale, secondPowerOfAttorney, boatWhileImpaired, schoolPickupStalking, utilityAccountFraud]

    // MARK: - After the Marketplace trailer

    static let chainsawResale = followUp(
        key: "story.followup.chainsawResale", category: .property,
        headlines: ["Stolen Chainsaws Found in Small Engine Shop", "Equipment Dealer Charged Again in Stolen Goods Case"],
        law: "possStolen", threshold: 6, spec: "Possessed six chainsaws and two pressure washers valued at $6,300, the property of {V}, knowing and having reasonable grounds to believe them stolen, on {DATE}.", ages: 22...58, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a rental store owned by {V} lost six chainsaws and two pressure washers in a break-in. Two weeks later a deputy found all eight in {D}'s shop with the rental store's inventory stickers peeled off but the adhesive outline still there. {DL} says {D.he} took them in on trade from a customer {D.he} can't name.",
        state: [E(.physical, 3, "Equipment", "Eight units with the rental store's sticker outlines still visible; serials match the store's inventory.", .search),
                E(.document, 2, "Trade Log", "{DL}'s shop log shows no trade-in entry for any of the eight.")],
        defense: [E(.statement, 1, "Trade-In", "{DL} says a customer traded them for a rebuilt mower and {D.he} didn't write it down.")],
        witnessRole: "Sheriff's property crimes detective",
        exam: [.direct("What did you find?", "\"All eight items, stickers peeled, outlines still on the housings. Serials match.\""),
               .direct("Was there a record of a trade?", "\"No. And this is a dealer who was just in court for not keeping records.\""),
               .cross("{DL} didn't break into the rental store.", "\"We're not saying {D.he} did.\""),
               .cross("Customers do trade equipment.", "\"With a name and a receipt, usually.\"")],
        theory: ("A dealer already caught once took in stolen equipment again and peeled off the stickers.", "A trade-in {DL} didn't write down."),
        allocution: "\"I'm closing the shop. I can't keep doing this.\"",
        truths: ("{DL}'s phone had texts arranging the 'trade' the morning after the break-in.",
                 "The burglar, caught later, said he'd sold the saws to a flea market vendor who resold them to {DL} with the stickers already peeled."),
        defendant: [.direct("Where did the saws come from?", "\"A customer traded them in.\""),
                    .direct("Who?", "\"I don't remember the name.\""),
                    .cross("After your last case, you didn't keep a record?", "\"I should have.\""),
                    .cross("The sticker outlines are still on them.", "\"I didn't notice.\"")],
        openings: ("Stolen saws with the stickers peeled, in a shop already caught once.", "A trade-in with no paperwork."),
        closings: ("Twice is knowledge.", "Sloppy paperwork twice is still sloppy paperwork."),
        timeline: [(-14, "Break-in at {V}'s rental store."), (0, "Deputy finds the equipment at {DL}'s shop.")],
        identified: "A deputy's check of the shop after the earlier case.",
        impact: "\"My insurance went up forty percent. I've got bars on the windows now.\"")

    // MARK: - After the power of attorney

    static let secondPowerOfAttorney = followUp(
        key: "story.followup.secondPowerOfAttorney", category: .whiteCollar,
        headlines: ["Man Convicted in Aunt's Case Took Over Another Elder's Finances", "Second Exploitation Charge for Nephew in Power of Attorney Case"],
        law: "exploitationElder", threshold: 6, spec: "Being in a position of trust and confidence with {V}, an older adult, knowingly by deception used {V}'s funds for {D.his} own benefit, $18,200, on {DATE}.", ages: 35...65, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} began \"helping\" {V}, an 81-year-old widower at {D.his} church, with bills. {V} added {D} to {V.his} checking account. Over five months, $18,200 went to {DL}'s credit card bills and a used boat. {V}'s son found the statements when his father's power bill went unpaid.",
        state: [E(.document, 3, "Bank Records", "$18,200 from {V}'s account to {DL}'s credit cards and a boat dealer."),
                E(.document, 2, "Church Records", "{DL} signed up as a volunteer driver for homebound members two weeks after the earlier case ended.")],
        defense: [E(.statement, 1, "Gifts", "{DL} says {V} wanted to help {D.him} get back on {D.his} feet.")],
        witnessRole: "Adult Protective Services social worker",
        exam: [.direct("What did you find?", "\"A joint account with {DL} added, and almost every withdrawal went to {DL}'s bills.\""),
               .direct("What does {V} say?", "\"That {DL} was a nice young man from church who helped with the mail.\""),
               .cross("{V} added {DL} to the account voluntarily.", "\"{V.He} did. {V.He} didn't know about the earlier case.\""),
               .cross("Joint owners can withdraw money.", "\"Not to deceive the other owner.\"")],
        theory: ("{D} did it again: a new church, a new widower, and {V.his} money on {DL}'s bills.", "A lonely man's gifts to a friend."),
        allocution: "\"I need help. I keep doing this.\"",
        truths: ("{DL} told the boat dealer, \"My uncle's paying for it, he'll never notice.\"",
                 "{V}'s own notes, kept in a ledger, recorded several of the payments as \"loans to my friend, gladly.\""),
        defendant: [.direct("Why did {V} add you to the account?", "\"To help with {V.his} bills. {V.He} wanted to help with mine too.\""),
                    .direct("Did {V} know about the boat?", "\"{V.He} said get something for yourself.\""),
                    .cross("After what happened with your aunt, you did this again.", "\"This was different.\""),
                    .cross("{V}'s power bill went unpaid while you bought a boat.", "\"I didn't know about the power bill.\"")],
        openings: ("A second elder's account, the same pattern.", "A friendship and some gifts."),
        closings: ("A power bill unpaid and a boat bought. That's not a gift.", "{V} chose to help {DL}."),
        timeline: [(-150, "{DL} added to {V}'s account."), (0, "{V}'s son finds the statements.")],
        identified: "{V}'s son and the bank statements.",
        impact: "{V}'s son: \"Dad trusted everybody at that church. Now he won't answer the door.\"")

    // MARK: - After the golf cart

    static let boatWhileImpaired = followUp(
        key: "story.followup.boatWhileImpaired", category: .traffic,
        headlines: ["Driver in Golf Cart Death Charged After Boat Crash", "Impaired Driving Charge Follows Second Crash"],
        law: "dwi", threshold: 5, spec: "Drove a vehicle on a street or highway in Hollis County while subject to an impairing substance, on {DATE}.", ages: 24...62, victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, Highway Patrol stopped {D} at 1 a.m. on {DATE} on the causeway after {D.his} SUV drifted across the center line twice. {DL} blew 0.13 on the roadside test and 0.12 on the Intoxilyzer at the jail. A cooler of beer was open on the passenger floor.",
        state: [E(.document, 3, "Intoxilyzer Result", "0.12 at 1:52 a.m.; the 15-minute observation period logged."),
                E(.video, 2, "Dash Camera", "The SUV crosses the center line twice on the causeway.")],
        defense: [E(.statement, 1, "Wind", "{DL} says crosswinds on the causeway pushed the SUV.")],
        witnessRole: "Highway Patrol trooper",
        exam: [.direct("Why did you stop {DL}?", "\"Crossed the center line twice in half a mile.\""),
               .direct("What did you see in the car?", "\"An open cooler of beer and the smell of alcohol.\""),
               .cross("The causeway is windy.", "\"It was calm that night.\""),
               .cross("The roadside test isn't admissible as a number.", "\"The Intoxilyzer is.\"")],
        theory: ("After a friend died in a crash {D.he} caused, {D} drove impaired again.", "Wind on a causeway and a machine."),
        allocution: "\"I haven't forgiven myself. I've been drinking to forget it.\"",
        truths: ("A bar receipt in {DL}'s wallet showed nine drinks that night.",
                 "The Intoxilyzer's calibration log, reviewed later, showed it reading high that month."),
        defendant: [.direct("How much had you had?", "\"Two beers at dinner.\""),
                    .direct("Why cross the line?", "\"The wind.\""),
                    .cross("After your friend died in that golf cart.", "\"I know.\""),
                    .cross("An open cooler on the floor.", "\"It was from the beach.\"")],
        openings: ("A second impaired drive, after a death.", "Crosswinds and a machine."),
        closings: ("0.12. That's the law.", "The State's case is one machine."),
        timeline: [(0, "1 a.m.: stop on the causeway; 1:52 a.m.: Intoxilyzer.")],
        identified: "A Highway Patrol stop.",
        impact: nil,
        doctrines: ["burdenOfProof"])

    // MARK: - After the birthday party

    static let schoolPickupStalking = followUp(
        key: "story.followup.schoolPickupStalking", category: .robbery,
        headlines: ["Ex-Husband Seen at School Pickup Line Despite Order", "Second Stalking Charge After School Pickup"],
        law: "stalkingCourtOrder", lesser: "stalking", threshold: 6, spec: "On more than one occasion followed and watched {V} without legal purpose while a protective order prohibiting that conduct was in effect, causing {V} to fear for {V.his} safety, on {DATE}.", ages: 26...48, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V}'s protective order was renewed. On {DATE}, school staff saw {D} parked across from the elementary school's pickup line three afternoons in one week, watching {V}'s car. The school's camera recorded his truck each time, and the principal called deputies on the third day.",
        state: [E(.video, 3, "School Camera", "{DL}'s truck across from the pickup line three afternoons, 20 to 40 minutes each."),
                E(.document, 2, "Renewed Order", "Stay 500 feet from {V} and the child's school.")],
        defense: [E(.statement, 1, "Daughter", "{DL} says he only wanted to see his daughter come out of school.")],
        witnessRole: "School principal",
        exam: [.direct("What did you see?", "\"The same truck three afternoons, engine running, facing the pickup line.\""),
               .direct("Did he come onto school grounds?", "\"No. He just watched.\""),
               .cross("He never approached anyone.", "\"No. He didn't have to.\""),
               .cross("He has custody time with the child.", "\"Not at my pickup line.\"")],
        theory: ("Under a renewed order, {D} sat outside the school three afternoons watching {V}.", "A father watching his daughter walk out of school."),
        allocution: "\"I'll stay away. I'll do the classes. I just miss her.\"",
        truths: ("{DL} had texted a friend, \"she can't hide the kid from me, I know her schedule.\"",
                 "{DL}'s counselor had told him to drive by the school as part of 'exposure therapy,' a note in his records shows."),
        defendant: [.direct("Why were you at the school?", "\"To see my daughter walk out. That's all.\""),
                    .direct("Did you speak to anyone?", "\"No.\""),
                    .cross("The order says 500 feet from that school.", "\"I was across the street.\""),
                    .cross("Three afternoons, right after your last case.", "\"I know how it looks.\"")],
        openings: ("Three afternoons across from a pickup line, under a court order.", "A father who just wanted to see his girl."),
        closings: ("The order drew a line. He sat on the other side of it, watching.", "Across the street, never closer, never a word."),
        timeline: [(-4, "First afternoon at the school."), (0, "Third afternoon; principal calls deputies.")],
        identified: "The school's camera and staff.",
        impact: "\"I changed my daughter's school in the middle of the year.\"")

    // MARK: - After the dead brother's name

    static let utilityAccountFraud = followUp(
        key: "story.followup.utilityAccountFraud", category: .whiteCollar,
        headlines: ["Utility Accounts Opened in Mother's Name, Deputies Say", "Identity Theft Defendant Charged Again"],
        law: "identityTheft", threshold: 6, spec: "Knowingly used the identifying information of {V} to fraudulently open utility and phone accounts, $3,900, on {DATE}.", ages: 28...58, victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} moved into a rental house and opened the power, internet, and two phone lines in the name of {V}, {D.his} mother, who lives in a nursing home. The accounts ran up $3,900 unpaid before a collections letter reached the nursing home.",
        state: [E(.document, 3, "Account Records", "Four accounts opened online in {V}'s name, service address {DL}'s rental."),
                E(.document, 2, "Nursing Home Records", "{V} has lived in memory care for two years.")],
        defense: [E(.statement, 1, "Permission", "{DL} says his mother told him years ago he could use her name for anything he needed.")],
        witnessRole: "Sheriff's financial crimes detective",
        exam: [.direct("Whose address was on the accounts?", "\"{DL}'s rental house.\""),
               .direct("Could {V} have opened them?", "\"{V.He}'s in memory care. {V.He} doesn't use a computer.\""),
               .cross("{V} may have given permission years ago.", "\"For accounts that didn't exist then?\""),
               .cross("Family members share accounts.", "\"Not without telling the person.\"")],
        theory: ("After using a dead brother's name, {D} used {D.his} mother's.", "A son with his mother's blessing."),
        allocution: "\"I'll pay every bill. I was trying to keep the lights on.\"",
        truths: ("{DL}'s laptop held a spreadsheet of family members' Social Security numbers.",
                 "{DL}'s sister admitted opening the accounts in their mother's name and giving him the logins."),
        defendant: [.direct("Did you open the accounts?", "\"Mama always said use her name if I needed to.\""),
                    .direct("Why not your own name?", "\"My credit's ruined.\""),
                    .cross("Your mother is in memory care.", "\"She said it before.\""),
                    .cross("Right after your last identity theft case.", "\"It's my mother.\"")],
        openings: ("A mother in memory care, and four accounts in her name at her son's house.", "A son with permission."),
        closings: ("A woman in memory care can't consent to accounts she can't remember.", "Family isn't identity theft."),
        timeline: [(-120, "Accounts opened online."), (0, "Collections letter reaches the nursing home.")],
        identified: "The service address on the accounts.",
        impact: nil,
        doctrines: ["burdenOfProof"])
}
