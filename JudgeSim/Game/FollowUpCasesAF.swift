import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the batch AF stories. Each is a complete new incident; the earlier case appears only as {PRIOR}
/// and {PRIORDATE}, so it reads the same whatever the earlier verdict was.
extension FollowUpCases {
    static let batchAF: [CaseTemplate] = [
        trailerTheft, dockCopper, fakeReturns, drawerShort, concertTickets, rentalListing, atmSkimmer, washedChecks, roofDeposit, pawnedRing
    ]

    /// Roles that get no case-detective name but aren't ordinary lay witnesses either: lab and medical staff (the county's
    /// regulars fill them), and officials with their own names.
    private static func isOfficialRole(_ role: String) -> Bool {
        let r = role.lowercased()
        return ["animal control", "fire marshal", "fire investigator", "marine patrol", "social worker", "probation", "parole",
                "crime lab", "laborator", "forensic", "analyst", "examiner", "chemist", "toxicolog", "dna", "latent", "firearms",
                "medical examiner", "coroner"].contains { r.contains($0) }
    }

    /// The token for a law enforcement role (detective, deputy, trooper, officer), or nil for anyone else.
    private static func officerToken(_ role: String) -> String? {
        let r = role.lowercased()
        if ["insurance", "bank", "loss prevention", "private", "security", "store", "real estate", "travel", "talent", "compliance", "loan", "claims", "hospital", "wildlife"].contains(where: { r.contains($0) }) { return nil }
        if r.contains("trooper") { return "{TROOPER}" }
        if r.contains("deputy") || r.contains("officer") || r.contains("corrections") || r.contains("jailer") { return "{OFF}" }
        if ["detective", "investigator", "agent", "sbi", "sheriff", "police", "task force", "lieutenant", "sergeant"].contains(where: { r.contains($0) }) { return "{DET}" }
        return nil
    }

    /// An ordinary witness (a clerk, a dentist, a tenant, a dispatcher) is named like any other civilian; only
    /// law enforcement roles use the case's officers.
    static func isCivilianRole(_ role: String) -> Bool {
        officerToken(role) == nil && !isOfficialRole(role)
    }

    static func witnessName(for role: String) -> String? {
        officerToken(role)
    }

    /// The name token for the State's witness: a law enforcement role gets the case's officer, and a witness who is the victim
    /// (the victim, the homeowner, the car owner...) is named {V}, so the person on the stand is the person the charge names.
    /// An exam that talks about {V} in the third person is about someone else, so that witness stays an ordinary civilian.
    static func stateWitnessToken(role: String, victim: Bool, exam: [ExamLine], defendant: [ExamLine] = []) -> String? {
        if let officer = witnessName(for: role) { return officer }
        let victimRoles: Set<String> = ["victim", "homeowner", "car owner", "truck owner", "owner", "cardholder", "account owner", "dog owner",
                                        "farm owner", "bakery owner", "bar owner", "restaurant owner", "shop owner", "tire shop owner",
                                        "company owner", "orchard owner", "buyer", "equipment buyer", "renter", "investor", "donor", "customer", "account holder", "property owner", "store owner"]
        let named = ["{V}", "{VL}", "{VF}", "{V."]
        // "A witness" the defendant is asked about by the victim's name ("Did you send {V} $600?") is the victim.
        if victim, role.lowercased() == "witness" {
            let theirs = exam.flatMap { $0.questions + $0.answers }.joined(separator: " ")
            let hers = defendant.flatMap { $0.questions + $0.answers }.joined(separator: " ")
            return !named.contains(where: { theirs.contains($0) }) && named.contains(where: { hers.contains($0) }) ? "{V}" : nil
        }
        guard victim, victimRoles.contains(role.lowercased()) else { return nil }
        let text = exam.flatMap { $0.questions + $0.answers }.joined(separator: " ")
        return ["{V}", "{VL}", "{VF}", "{V."].contains(where: { text.contains($0) }) ? nil : "{V}"
    }

    /// A short follow-up: one investigating witness, two exhibits for the State, one for the defense.
    /// Shared by the later batches.
    static func followUp(key: String, category: LawCategory, headlines: [String], law: String, lesser: String? = nil,
                                 threshold: Int = 6, spec: String, ages: ClosedRange<Int> = 22...55, victim: Bool,
                                 summary: String, state: [EvidenceSeed], defense: [EvidenceSeed], witnessRole: String,
                                 exam: [ExamLine], theory: (String, String), allocution: String, truths: (String, String),
                                 defendant: [ExamLine], openings: (String, String), closings: (String, String),
                                 timeline: [(Int, String)], identified: String, notDone: [String] = [],
                                 impact: String? = nil, doctrines: [String] = ["burdenOfProof"],
                                 extras: [String: [String]] = [:]) -> CaseTemplate {
        CaseTemplate(
            key: key, category: category, headlines: headlines, primaryLaw: law, lesserLaw: lesser,
            threshold: threshold, lesserThreshold: lesser == nil ? 0 : threshold - 2, specification: spec,
            ageRange: ages, occupations: [], hasVictim: victim, summaries: [summary],
            prosecutionEvidence: state, defenseEvidence: defense,
            prosecutionWitnesses: [WitnessSeed(name: stateWitnessToken(role: witnessRole, victim: victim, exam: exam, defendant: defendant), role: witnessRole, direct: [], cross: [], weight: 2, lay: isCivilianRole(witnessRole), exam: exam)],
            defenseWitnesses: [],
            prosecutionTheory: [theory.0], defenseTheory: [theory.1],
            aggravating: [], mitigating: [], victimImpacts: impact.map { [$0] } ?? [], allocutions: [allocution],
            guiltyTruths: [truths.0], innocentTruths: [truths.1], moods: [.indifferent], doctrines: doctrines, extras: extras,
            story: StoryExtras(timeline: timeline, howIdentified: identified, notDone: notDone, defendantExam: defendant,
                               prosecutionOpening: openings.0, defenseOpening: openings.1,
                               prosecutionClosing: closings.0, defenseClosing: closings.1)
        )
    }

    // MARK: - After the outboard motors

    static let trailerTheft = followUp(
        key: "story.followup.trailerTheft", category: .property,
        headlines: ["Boat Trailer Taken From Driveway Turns Up Repainted", "Man From Marina Motor Case Charged in Trailer Theft"],
        law: "felonyLarceny", lesser: "misdLarceny",
        spec: "Stole a tandem-axle boat trailer valued at $4,800 belonging to {V}, on {DATE}.", victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a tandem-axle boat trailer disappeared from {V}'s driveway on {STREET} in {HOOD} overnight on {DATE}. Three weeks later a deputy saw a freshly painted black trailer behind {D}'s shop with a homemade tag. The VIN plate was gone, but the axle stamp matched the trailer {V} bought new. {DL} says {D.he} bought it from a man at a gas station for $600 and painted it to sell.",
        state: [E(.physical, 3, "Axle Stamp", "The manufacturer's stamp on the rear axle matches {V}'s purchase record.", .search),
                E(.physical, 2, "Fresh Paint", "Black spray paint over the original silver, with silver showing under the fenders.")],
        defense: [E(.statement, 1, "Gas Station Sale", "{DL} says a stranger sold it for $600 cash with no title.")],
        witnessRole: "Property crimes detective",
        exam: [.direct("How did you find the trailer?", "\"A deputy saw a homemade tag on a freshly painted trailer behind {DL}'s shop and called it in.\""),
               .direct("How do you know it's {V}'s?", "\"The VIN plate was gone, but the axle stamp matched {V}'s purchase paperwork.\""),
               .direct("Where was the trailer when it was taken?", "\"It sat in {V}'s driveway on {STREET} in {HOOD}, and it was gone the next morning. The tongue jack was still down, so someone had hitched it up and driven it off in the night.\""),
               .direct("What did you notice about the trailer behind {DL}'s shop?", "\"It had been painted solid black over the original silver, and the paint was fresh enough to smell. Silver still showed under the fenders where the spray had not reached.\""),
               .direct("How long was it between the theft and the discovery?", "\"About three weeks. A deputy driving past {DL}'s shop saw a black trailer with a homemade tag and thought the paint job looked rushed, so he stopped and called it in.\""),
               .direct("What did you do to confirm whose trailer it was?", "\"I looked for the stamp the manufacturer puts on the rear axle and compared it to {V}'s purchase record. The numbers matched, and that is how we knew whose trailer it was.\""),
               .cross("Nobody saw {DL} take it?", "\"No. Nobody saw {D.him} take it, and there's no video of it either.\""),
               .cross("Did you look for the man at the gas station?", "\"{DL} couldn't say which station or describe the man past 'tall.'\""),
               .cross("Painting a trailer isn't illegal, is it?", "\"No, it is not. A person can paint a trailer any color he likes. What mattered was the missing VIN plate, the homemade tag and the axle stamp that matched {V}'s paperwork.\""),
               .cross("You never found anyone who saw {DL} take it?", "\"That is right. At the time of the report nobody had seen the trailer taken. The neighbor's camera that later showed a truck backing up the driveway was found after the arrest.\""),
               .cross("The man at the gas station could be real, couldn't he?", "\"He could be. {DL} could not tell us which station it was, and could only describe him as tall. I looked, and I could not find him, but I can't say he does not exist.\"")],
        theory: ("{D} took a trailer, painted it, and pulled the VIN plate, the same way the marina motors lost their serial plates.",
                 "{D} bought a trailer cheap from a stranger. Painting a trailer you mean to sell isn't a crime."),
        allocution: "\"I bought that trailer from a man at a gas station for six hundred dollars in cash. It was rusty, and I paint everything I sell. I didn't think to check where it came from. I keep buying things I shouldn't. I'm done with that.\"",
        truths: ("{V}'s neighbor's camera, found later, showed {DL}'s truck backing up the driveway at 3 a.m.",
                 "A man arrested for a string of trailer thefts in two counties had sold {DL} the trailer at a Cane Creek gas station."),
        defendant: [.direct("Where did you get the trailer?", "\"A man at a gas station. Six hundred cash.\""),
               .direct("Why paint it?", "\"It was rusty. I paint everything I sell.\""),
               .direct("Who did you buy the trailer from?", "\"A man at a gas station out near Cane Creek. He said he needed money quickly, and I paid him six hundred dollars in cash. I never got his name or a title.\""),
               .direct("Did you do anything to the trailer yourself?", "\"I sanded it and painted it black because it was rusty and ugly. I made a homemade tag so I could pull it down the road, which I knew was not the right way to do it.\""),
               .direct("Why did you buy a trailer from a stranger?", "\"The price was too good to pass up. I fix and sell equipment for a living, and a trailer for six hundred dollars looked like an easy profit once it was cleaned up.\""),
               .direct("Did you know the trailer was stolen?", "\"No, I did not. I knew the deal was cheap and the seller was in a hurry, but I did not know it had been taken from anyone's driveway.\""),
               .cross("No title, no VIN plate, and $600 for a $4,800 trailer.", "\"I didn't think about it.\""),
               .cross("Just like the motors.", "\"That was different. The motors were a separate situation from this one.\""),
               .cross("The VIN plate was gone when you bought it, wasn't it?", "\"It was already gone when I got it, as far as I recall. I should have asked about that, and I did not. I know that looks bad for me.\""),
               .cross("You never asked for a title?", "\"No. He said the title was lost and he would mail it, and I let it go. I have bought things from people before without paperwork, and I should have known better by now.\""),
               .cross("Your truck was seen backing up that driveway at 3 a.m., wasn't it?", "\"That was not me. My truck was in my yard that night, and I have no idea whose truck was on that camera or why people think it looked like mine.\"")],
        openings: ("{V}'s boat trailer vanished from a driveway on {STREET} overnight, and three weeks later a deputy found it painted black behind {D}'s shop with its VIN plate missing, a homemade tag on it, and an axle stamp that still matched {V}'s purchase record.", "The defense will say {D} bought a rusty trailer from a stranger for $600 and painted it to sell, as {D.he} does with everything. A can of paint and a bad deal are not proof that {D} took anything from a driveway."),
        closings: ("A boat trailer disappeared, the VIN plate was gone, and the axle stamp matched {V}'s receipt. {D} had already been in this court over {PRIOR}, and {D.he} cannot name the man who supposedly sold a $4,800 trailer for $600.", "{D} bought a trailer without a title and painted it, which was careless but not criminal. Nobody saw {D} at {V}'s driveway, and the State must prove {D} knew the trailer was stolen, not that {D.he} made a bad bargain."),
        timeline: [(0, "Trailer taken from {V}'s driveway overnight."), (21, "Deputy spots the painted trailer behind {DL}'s shop.")],
        identified: "A deputy noticed the homemade tag; the axle stamp matched.",
        impact: "\"That trailer was how I got my boat to the river. My father and I fished every Saturday.\"")

    static let dockCopper = followUp(
        key: "story.followup.dockCopper", category: .property,
        headlines: ["Copper Cable Cut From Marina Docks; Scrap Yard Tickets Name Local Man", "Marina Power Out After Wire Theft"],
        law: "felonyLarceny", lesser: "misdLarceny",
        spec: "Stole 340 feet of copper shore-power cable valued at $2,900 from the docks at the Port Hollis Marina, on {DATE}.", victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, 340 feet of copper shore-power cable was cut from the floating docks at the Port Hollis Marina overnight on {DATE}, leaving forty boats without power. Two days later {D} sold 212 pounds of stripped copper at a scrap yard in Cane Creek, with a photo and thumbprint as state law requires. The insulation found in a burn barrel behind {D.his} shop was the same marine-grade jacket. {DL} says the copper came from a house {D.he} gutted for a friend.",
        state: [E(.document, 3, "Scrap Yard Ticket", "212 pounds of bare bright copper sold by {DL} two days after the theft, with photo and thumbprint."),
                E(.physical, 2, "Burned Insulation", "Melted yellow marine-grade cable jacket in a burn barrel behind {DL}'s shop.", .search)],
        defense: [E(.statement, 1, "Gutted House", "A friend says {DL} pulled wiring out of a house the friend was renovating that month.")],
        witnessRole: "Property crimes detective",
        exam: [.direct("How did you connect the copper to the marina?", "\"Scrap yards have to record every copper seller. {DL} sold 212 pounds two days later. Marina cable is a heavy gauge you don't find in houses.\""),
               .direct("What was in the burn barrel?", "\"Melted yellow jacket, the same marine-grade cable that was cut from the docks.\""),
               .direct("What was taken from the marina?", "\"About 340 feet of heavy copper shore-power cable was cut from the floating docks overnight. It left forty boats without power, and the marina had to bring in an electrician the next day.\""),
               .direct("How did you find the person who sold it?", "\"Scrap yards in this state have to photograph every copper seller and take a thumbprint. {DL}'s ticket showed 212 pounds of bare bright copper sold two days after the theft.\""),
               .direct("What was special about the cable?", "\"It was marine-grade, with a yellow jacket and a thick gauge. Homes are not wired with it, which is why the copper from the scrap yard pointed to the docks and not to a house.\""),
               .direct("What did you find at {DL}'s shop?", "\"A burn barrel behind the shop held melted yellow insulation. When we compared it to the cable jacket cut from the marina docks, it was the same material.\""),
               .cross("Copper is copper once it's stripped.", "\"The gauge isn't. Residential wire is thinner.\""),
               .cross("The friend says {DL} gutted a house that month.", "\"The friend's house had about thirty pounds of wire in it, by the contractor's count.\""),
               .cross("{DL} had a reason to have copper, didn't {D.he}?", "\"{D.He} did gut a house that month, I have no quarrel with that. But the house had about thirty pounds of wire by the contractor's count, and {D.he} sold 212.\""),
               .cross("You never saw {DL} at the marina?", "\"No one did that night. The marina's own camera caught {DL}'s jon boat at the docks at one in the morning, but I can't tell you who was in it.\""),
               .cross("Anyone can burn wire jackets in a barrel, can't they?", "\"Anyone can. Yellow marine jacket is not what you find in a house, and that is the part that matters to me.\"")],
        theory: ("{D} cut the marina's shore power, burned the jacket, and sold the copper two days later.",
                 "The copper came from a house {D} gutted for a friend. Stripped copper doesn't carry a name."),
        allocution: "\"That wire came from a house I gutted for a friend, old wiring and a lot of it. I burn the jackets from every job. I don't know what color the marina's cable was. I'll pay the marina back, and I need to keep working.\"",
        truths: ("A marina camera showed {DL}'s jon boat at the docks at 1 a.m.", "A dockhand fired the week before had sold the rest of the cable at a different yard."),
        defendant: [.direct("Where did the copper come from?", "\"A house I gutted for a friend. Old wiring, a lot of it.\""),
               .direct("What about the burn barrel?", "\"I burn wire jackets from every job.\""),
               .direct("What work were you doing that month?", "\"I was gutting an old house for a friend who was renovating it. I pulled out wiring, plumbing and plaster, and I took the copper to the scrap yard because that is how I get paid for demolition.\""),
               .direct("Why did you sell the copper two days after the dock cut?", "\"It happened to fall that way. I had finished the house and loaded the truck, and I took it in as soon as I had a free day. I did not know anything about the marina.\""),
               .direct("Where were you the night the cable was cut?", "\"I was home most of the night. I do have a jon boat, and I do fish the river, but I was not at the marina cutting anybody's cable.\""),
               .direct("Why do you burn wire jackets behind your shop?", "\"It is the cheapest way to get rid of them. I burn jackets from every job, and I have done it for years. Nobody ever told me it was a problem.\""),
               .cross("Yellow marine cable, in a house?", "\"I don't know what color it was.\""),
               .cross("212 pounds from one house with thirty pounds of wire.", "\"There was more than they think.\""),
               .cross("Your jon boat was on the marina camera at 1 a.m., wasn't it?", "\"That is what they say. I fish at night, and a lot of boats look alike on a grainy camera. I will not tell you it was not mine, but I was not cutting cable.\""),
               .cross("The house had thirty pounds of wire and you sold 212.", "\"There was more wire in that house than the contractor counted. It was an old farmhouse, and there was copper in places he never looked.\""),
               .cross("You can't show the court a receipt for the demolition job, can you?", "\"Not with me. My friend paid in cash for the work, and he can tell you I was there. I understand that it is my word against a scrap ticket.\"")],
        openings: ("Forty boats lost power when 340 feet of marine copper cable was cut from the Port Hollis Marina docks. Two days later {D} sold 212 pounds of stripped copper, and melted yellow insulation, the same cable jacket, sat in a burn barrel behind {D.his} shop.", "The defense will say {D} gutted a house for a friend that month, which is where the copper came from, and burns wire jackets after every job. Copper does not carry a name, and nobody saw {D} at the marina."),
        closings: ("The scrap yard ticket, the burn barrel and the yellow marine jacket all lead back to {D}, who had already been here over {PRIOR}. A house with thirty pounds of wire does not produce 212 pounds of copper.", "No camera shows {D}'s face, no witness puts {D} at the docks, and stripped copper looks like any other copper. The State must prove {D} cut this cable, and a boat on a grainy camera is not enough."),
        timeline: [(0, "Cable cut from the docks overnight."), (2, "{DL} sells 212 pounds of copper in Cane Creek."), (5, "Burn barrel searched with a warrant.")],
        identified: "The scrap yard's mandatory seller records.")

    // MARK: - After the gift cards

    static let fakeReturns = followUp(
        key: "story.followup.fakeReturns", category: .property,
        headlines: ["Return Desk Fraud at Three Stores Traced to One Receipt Printer", "Stolen Merchandise Returned for Cash, Store Says"],
        law: "larcenyMerchant", lesser: "misdLarceny",
        spec: "Stole merchandise from Harbor Mart and returned it for $1,640 in cash using counterfeit receipts, between {DATE} and the month before.", victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, loss prevention at Harbor Mart noticed eleven cash refunds on receipts with a font slightly different from the store's. Each return was a small appliance that had been taken from the shelf the same day. The returns, $1,640 in all, were made by {D}, who was on camera at the return desk each time. A receipt printer and a roll of thermal paper were found in {D.his} car. {DL} says a friend gave {D.him} the items and receipts to return and split the money.",
        state: [E(.video, 3, "Return Desk Camera", "{DL} at the return desk for all eleven refunds."),
                E(.physical, 3, "Receipt Printer", "A portable thermal receipt printer and paper in {DL}'s car.", .search)],
        defense: [E(.statement, 1, "The Friend", "{DL} names a friend who {D.he} says brought the items and receipts.")],
        witnessRole: "Retail crimes detective",
        exam: [.direct("What made the receipts stand out?", "\"The font was off by a hair, and the transaction numbers didn't exist in the store's system.\""),
               .direct("What was in the car?", "\"A portable receipt printer and thermal paper, the kind sold online for making receipts.\""),
               .direct("How did you first notice the problem?", "\"A refund auditor saw eleven cash returns on receipts printed in a font that was slightly off from the store's. When we ran the transaction numbers, none of them existed in our system.\""),
               .direct("What were the items that were returned?", "\"Small appliances, mostly toasters, coffee makers and blenders. Each one had been pulled off the shelf that same day, so the store was refunding cash for items it had never actually sold.\""),
               .direct("What does the return desk camera show?", "\"It shows {DL} at the desk for all eleven refunds, handing over an item and a receipt and walking away with cash. The total was $1,640.\""),
               .direct("What did the search of the car turn up?", "\"A portable thermal receipt printer and a roll of thermal paper in the back seat. The printer's memory held all eleven receipt templates, each one created the night before a return.\""),
               .cross("Did you talk to the friend {DL} named?", "\"The friend denied it and had no printer.\""),
               .cross("The camera shows the returns, not anyone taking items off the shelf?", "\"The shelf camera shows a hooded person. I can't say who.\""),
               .cross("{DL} didn't print those receipts at the desk, did {D.he}?", "\"No. The receipts were printed beforehand. What I can say is that {DL} presented them, and that the printer holding them was in {D.his} car.\""),
               .cross("The shelf camera doesn't show {DL} taking anything, does it?", "\"It shows a hooded person taking items from the shelf. I can't tell you who that is. {DL} is the person at the return desk.\""),
               .cross("The friend {DL} named told you {D.he} knew nothing, didn't he?", "\"He denied it and said he did not own a printer. We have only his word, and later his girlfriend told us something different.\"")],
        theory: ("{D} printed the receipts, took the items off the shelf, and returned them for cash.",
                 "{D} was the friend's errand runner. The State can't show who took the items."),
        allocution: "\"My friend handed me the bag and the receipt, and he said they were gifts people didn't want. He left a receipt in the bag, and I didn't know what it was for. I knew it wasn't right. I'm sorry, and I'll repay the store.\"",
        truths: ("The printer's memory held all eleven receipt templates, created the night before each return.", "The friend's girlfriend later told police the friend made the receipts and paid {DL} $20 a return."),
        defendant: [.direct("Who made the receipts?", "\"My friend. He'd hand me the bag and the receipt.\""),
               .direct("Why was the printer in your car?", "\"He left it in there. I didn't know what it was for.\""),
               .direct("Who gave you the items to return?", "\"A friend. He would hand me the bag and the receipt and tell me to take it to the store for him. I did it eleven times because he paid me a little each time.\""),
               .direct("How much were you paid?", "\"Twenty dollars a return. It was easy money, and I never asked why my friend did not simply return his own gifts.\""),
               .direct("Did you know the receipts were fake?", "\"At that point I believed they were genuine. I thought they were real receipts for gifts. Looking back, it is clear that I should have asked where they came from.\""),
               .direct("Did you ever see the friend make a receipt?", "\"No. He handed me the bag and the receipt already folded, and I never watched him print anything.\""),
                    .cross("Eleven times you stood at that desk and took cash.", "\"He said they were gifts people didn't want.\""),
               .cross("Without asking why every gift had a receipt from the same store that day?", "\"I didn't ask. I should have wondered why every gift had a receipt from the same store.\""),
               .cross("Eleven receipts, all from the same store, and you never wondered?", "\"I did not wonder enough. He said the gifts were things people did not want, and I took that at face value because I wanted the twenty dollars.\""),
               .cross("You were the one who stood at that desk and took the cash.", "\"Yes, I took the cash and I gave it to him, less my twenty. I am not saying I did nothing. I am saying I did not make the receipts.\""),
               .cross("The printer was found in your car, not his.", "\"It was in my car because he left it there. I did not want it and I did not know how to use it, and I would have told him to take it if I had known.\"")],
        openings: ("Eleven cash refunds at Harbor Mart, $1,640 in all, were made on receipts in a slightly wrong font for appliances taken off the shelf the same day. The return desk camera shows {D} each time, and a receipt printer was in {D.his} car.", "The defense will say {D} was a friend's errand runner who took items and receipts to the desk for twenty dollars a trip. {D} did not make the receipts, did not take anything off the shelf, and did not know they were fake."),
        closings: ("Eleven returns, eleven fake receipts, and the same face at the desk every time. {D} had been before this court over {PRIOR}, and a printer holding every receipt template was found in {D.his} car.", "{D} did what a friend asked and was paid twenty dollars a trip. The State cannot show who made the receipts or who took the items, and it must prove {D} knew the paper was false."),
        timeline: [(-30, "First counterfeit-receipt refund."), (0, "Eleventh refund; loss prevention calls deputies."), (1, "Printer found in {DL}'s car.")],
        identified: "Return desk cameras and the store's refund records.")

    static let drawerShort = followUp(
        key: "story.followup.drawerShort", category: .whiteCollar,
        headlines: ["Restaurant Cashier Charged After Drawer Runs Short for Months", "Owner Says Cash Register Was Short $4,300"],
        law: "embezzlement",
        spec: "Embezzled $4,300 in cash from the register at {PLACE.DINER}, {D.his} employer, over the three months before {DATE}.", victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} took a cashier's job at {PLACE.DINER}. Over three months the owner noticed the drawer short on {DL}'s shifts by $4,300 in all, mostly in voided cash sales. A hidden camera the owner installed caught {DL} voiding a cash ticket and putting bills in an apron pocket. {DL} says the owner never trained {D.him} on voids and the pocket money was {D.his} tips.",
        state: [E(.video, 3, "Hidden Camera", "{DL} voids a $46 cash ticket and puts the bills in an apron pocket."),
                E(.document, 2, "Shift Reports", "Voided cash sales on {DL}'s shifts total $4,300 over three months; other cashiers average under $200.")],
        defense: [E(.statement, 1, "Tip Jar", "Two coworkers say the tip jar was emptied into aprons at the end of a shift.")],
        witnessRole: "Financial crimes detective",
        exam: [.direct("What do the shift reports show?", "\"Voided cash tickets on {DL}'s shifts total $4,300. Other cashiers average under $200 for the same period.\""),
               .direct("What does the camera show?", "\"{DL} rings a $46 ticket, voids it after the customer leaves, and pockets the cash.\""),
               .direct("How did you come to investigate the diner?", "\"The owner called us after three months of short drawers. He had checked the shift reports and saw that the shortages were mostly voided cash sales on one cashier's shifts.\""),
               .direct("What did the owner do next?", "\"He installed a hidden camera over the register. Within a week it recorded {DL} voiding a $46 cash ticket after the customer left and putting the bills in an apron pocket.\""),
               .direct("How did {DL}'s voids compare to the other cashiers'?", "\"{DL}'s voided cash sales totaled $4,300 over three months. The other cashiers averaged under $200 for the same period, and that gap is what first caught the owner's eye.\""),
               .direct("Was anything else found?", "\"A notebook in {DL}'s car with amounts written by date. Those dates matched the voided tickets on the shift reports, which suggests someone was keeping track of the cash.\""),
               .cross("Tips went into aprons too?", "\"At the end of the shift. This was at lunch.\""),
               .cross("The camera covers one ticket out of hundreds.", "\"One that shows exactly how it was done.\""),
               .cross("Tips go in aprons too, don't they?", "\"Tips do. Two coworkers told us the tip jar was emptied into aprons at the end of a shift. This clip was taken at lunch, and the cash was from a ticket that had just been rung.\""),
               .cross("The camera caught only one ticket, didn't it?", "\"It caught one on video that week. The shift reports show the pattern over three months, and the video shows how it was done.\""),
               .cross("The owner never trained {DL} on voids?", "\"{DL} says that, and the owner admits he gave no formal training. Even so, a void after the customer has left and the money is in your apron does not look like a training problem.\"")],
        theory: ("{D} rang sales, voided them, and pocketed the cash: $4,300 in three months.", "{D} was never trained, and tips went into aprons. One video clip isn't three months of theft."),
        allocution: "\"I voided mistakes because nobody showed me how to do it right. People hand me cash for the tip jar all day, and I must have rung something wrong. I needed the money, and that's not an excuse. I'm sorry to the owner, and I'll make up the drawer.\"",
        truths: ("A notebook in {DL}'s car tallied amounts by date matching the voids.", "The owner's nephew, who closed most nights, was later caught running the same voids on his own shifts."),
        defendant: [.direct("Did you void sales to keep the cash?", "\"No. I voided mistakes. Nobody showed me how to do it right.\""),
               .direct("What was the cash on the video?", "\"Tips. People hand me cash for the jar all day.\""),
               .direct("What was your job at the diner?", "\"I was a cashier. I rang up sales, took cash and cards, and cleaned the front counter. The owner showed me the register in about ten minutes and left me to it.\""),
               .direct("How did you learn to do voids?", "\"I figured it out by pushing buttons. When I made a mistake I voided it, and nobody told me there was a right way or that I needed a manager to approve it.\""),
               .direct("What was the cash in your apron?", "\"Tips. Customers hand me bills for the jar all day, and I put them in my apron until I can drop them in at the end of a shift.\""),
               .direct("Why do you keep a notebook in your car?", "\"I write down my tips and my hours because the owner pays in cash. I do not want to be shorted, and I want to know what I made each day.\""),
               .cross("A $46 ticket, voided after the customer left?", "\"I must have rung it wrong.\""),
               .cross("Your voids are twenty times anyone else's.", "\"I'm slower on the register than they are.\""),
               .cross("Your voids are twenty times higher than the other cashiers'.", "\"I was the new one, and I made more mistakes. I did not realize how that would look when the owner added them up.\""),
               .cross("The notebook dates match the voided tickets.", "\"I wrote down dates because I tracked my days. If the voids fall on my days, then the dates would match without my meaning anything by it.\""),
                    .cross("You never told the owner about the voided tickets.", "\"I did not. I did not think they were a problem, and no one ever told me they were.\"")],
        openings: ("For three months the drawer at the diner ran short on {D}'s shifts, $4,300 in all, mostly through voided cash sales. A hidden camera caught {D} voiding a $46 ticket after the customer left and putting the bills in an apron pocket.", "The defense will say {D} was never trained on voids, made mistakes as a new cashier, and kept tip money in an apron like everyone else. One clip of one ticket is not three months of theft."),
        closings: ("{D}'s voids were twenty times anyone else's, the hidden camera shows the cash going into an apron, and a notebook in {D.his} car tracked amounts by date. {D} had faced this court before, over {PRIOR}.", "An untrained cashier, an apron full of tips, and one clip of one ticket. The owner's own nephew was later caught running the same voids, and the State must prove it was {D} who took this cash."),
        timeline: [(-90, "Drawer shortages begin on {DL}'s shifts."), (-10, "Owner installs a hidden camera."), (0, "Owner calls the Sheriff's Office.")],
        identified: "Shift reports, then the owner's hidden camera.")

    // MARK: - After the football tickets

    static let concertTickets = followUp(
        key: "story.followup.concertTickets", category: .whiteCollar,
        headlines: ["Concert Fans Say They Paid for Tickets That Never Came", "Online Ticket Seller Charged Again"],
        law: "falsePretenses",
        spec: "Obtained $960 from four buyers, including {V}, by selling concert tickets {D.he} did not have, on or about {DATE}.", victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, four people, including {V}, paid {D} $960 through a payment app for tickets to a sold-out concert at the coliseum in Greensboro, after a post in a community group. No tickets ever arrived; {DL} stopped answering messages two days before the show. {DL} says {D.he} paid a seller for the tickets and was never sent them either, and has no record of that payment.",
        state: [E(.digital, 3, "Payment Records", "Four payments to {DL}'s account totaling $960, and no outgoing payment for tickets."),
                E(.digital, 2, "Messages", "{DL} to {V}: \"tickets will transfer friday.\" Friday came and went.")],
        defense: [E(.statement, 1, "Lost Seller", "{DL} says {D.he} paid a seller in cash at a gas station.")],
        witnessRole: "Financial crimes detective",
        exam: [.direct("What do {DL}'s account records show?", "\"Four payments in, $960. Nothing out to any ticket seller.\""),
               .direct("What did {D.he} tell buyers?", "\"That the tickets would transfer Friday. Then nothing.\""),
               .direct("How did people find {DL}'s offer?", "\"Through a post in a community group. {DL} said {D.he} had four tickets to a sold-out concert at the coliseum in Greensboro, and four people sent money through a payment app.\""),
               .direct("How much did the buyers pay in total?", "\"$960, in four separate payments. {V} was one of the buyers, and each payment went to {DL}'s account.\""),
               .direct("What did you learn from the ticketing company?", "\"It has no tickets under {DL}'s name or email. There was no transfer, because there were no tickets to transfer.\""),
               .direct("How did you track down {DL}?", "\"The buyers gave us the payment app account, and the account was registered to {DL}'s name and phone number.\""),
                    .cross("{DL} says {D.he} paid a seller in cash?", "\"{D.He} withdrew no cash that week, by the bank records.\""),
               .cross("No tickets were ever in {D.his} account?", "\"The ticketing company has no tickets under {D.his} name or email.\""),
               .cross("{DL} says {D.he} was cheated too?", "\"That is what {D.he} says. The records show money coming in from four buyers and nothing going out to any seller.\""),
               .cross("Could {DL} have paid a seller in cash?", "\"Possibly. {D.He} withdrew no cash that week, though, and the bank records do not show any money leaving for tickets.\""),
               .cross("The seller in Greensboro could have taken advantage of {DL}, too?", "\"A seller in Greensboro was arrested for taking cash from many resellers. {DL} never gave us a name or a place that tied to that man.\"")],
        theory: ("{D} sold tickets {D.he} never had, took $960, and went silent.", "{D} paid a seller who never delivered, just like the buyers."),
        allocution: "\"I paid for those tickets and was supposed to get them Friday. When they didn't come, I panicked, because I didn't have their money anymore. I had cash at home. I'll pay every one of them back, and I'm sorry to {V} and the other three.\"",
        truths: ("{DL}'s bank records showed the $960 spent on rent the next day.", "A seller in Greensboro was arrested for taking cash from dozens of resellers for tickets that never existed."),
        defendant: [.direct("Did you have tickets?", "\"I paid for them. I was supposed to get them Friday too.\""),
               .direct("Why did you stop answering?", "\"I panicked. I didn't have their money anymore.\""),
               .direct("Where did you get the tickets?", "\"I thought I had them. A man I met at a gas station said he could get four tickets, and I paid him in cash, then posted an offer for people who wanted to buy them.\""),
               .direct("Why did you tell buyers they would transfer on Friday?", "\"That is what the seller told me. He said the tickets would be sent to my email on Friday, and I passed that on to the people who had paid.\""),
               .direct("What happened on Friday?", "\"Nothing arrived. I messaged the seller, and he did not answer. I kept waiting, and I did not know how to explain to the buyers.\""),
               .direct("What did you do with the money?", "\"I paid my rent. The money from the buyers went into my account, and the rent was due the next day, so I spent it.\""),
               .cross("Your bank shows no cash withdrawal that week.", "\"I had cash at home.\""),
               .cross("And the $960 paid your rent the next day.", "\"Rent was due. The money went straight to my landlord the next day.\""),
               .cross("Your rent was paid with their money.", "\"It was. I had already paid cash for tickets, and I told myself I would get the money back. That was not a good decision.\""),
               .cross("You never told the buyers you had been cheated too.", "\"No. I was embarrassed, and I stopped answering because I did not have their money anymore. I should have told them the truth.\""),
               .cross("You can't name the man at the gas station.", "\"I never got his name. He said he was a friend of a friend. I realize how that sounds.\"")],
        openings: ("Four people, including {V}, paid {D} $960 through a payment app for sold-out concert tickets that never existed. {D} promised a Friday transfer, stopped answering two days before the show, and spent the money on rent the next day.", "The defense will say {D} paid a seller for the tickets and was never sent them either. {D} passed along what the seller promised and had no record of that cash payment, but {D} was cheated too."),
        closings: ("Four payments in, nothing paid out, no tickets under {D}'s name, and the rent paid the next day with the buyers' money. {D} had already been here over {PRIOR}, and no seller has ever been named.", "{D} believed a man at a gas station and passed on his promise. A buyer who was cheated and then panicked is not a person who planned to defraud, and the State must prove {D} never had tickets to sell."),
        timeline: [(-10, "Post in the community group."), (-8, "Fourth buyer pays."), (-2, "{DL} stops answering."), (0, "Concert night; no tickets.")],
        identified: "Payments went to {DL}'s own account.",
        impact: "\"It was my daughter's first concert, and she had saved up for half of it herself. I paid for her ticket through the app, and then there was nothing. She cried when we realized it was gone. I'd like the court to know how much that evening meant to her.\"")

    static let rentalListing = followUp(
        key: "story.followup.rentalListing", category: .whiteCollar,
        headlines: ["Beach House Renters Arrive to Find Owners Home", "Fake Vacation Rental Listing Took $2,100 Deposit, Deputies Say"],
        law: "falsePretenses",
        spec: "Obtained a $2,100 rental deposit from {V} by advertising a vacation house {D.he} did not own or manage, on or about {DATE}.", victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a listing appeared online for a sound-front house in {HOOD}, using photos copied from a real estate site, at half the going weekly rate. {V} paid a $2,100 deposit to a payment app account and drove from Ohio with three children, to find the owners living in the house. The payment account and the listing's phone number traced to {D}. {DL} says {D.he} managed the house for someone who lied to {D.him}.",
        state: [E(.digital, 3, "Payment Account", "The $2,100 deposit went to {DL}'s account; the listing's phone number is {DL}'s."),
                E(.document, 2, "Owners' Statement", "The owners have never heard of {DL} and never listed the house.")],
        defense: [E(.statement, 1, "The Manager", "{DL} names a man {D.he} says hired {D.him} to handle bookings.")],
        witnessRole: "Financial crimes detective",
        exam: [.direct("Where did the deposit go?", "\"To {DL}'s payment app account. The listing's phone number is {DL}'s too.\""),
               .direct("Who owns the house?", "\"A retired couple who live there year-round. They've never rented it.\""),
               .direct("What did the online listing look like?", "\"A sound-front house in {HOOD}, with photos copied from a real estate site, at about half the going weekly rate. The price was what made {V} think it was a bargain.\""),
               .direct("What did {V} do after seeing the listing?", "\"{V} paid a $2,100 deposit to a payment app account and then drove from Ohio with three children, expecting to move into the house for the week.\""),
               .direct("What happened when {V} arrived?", "\"The owners, a retired couple, were living in the house. They had never heard of {DL} and had never put the house up for rent.\""),
               .direct("How did you tie the listing to {DL}?", "\"The deposit went to {DL}'s payment account, and the listing's phone number was {DL}'s. The site's records also showed that the listing account was created from {DL}'s phone.\""),
               .cross("{DL} says a man hired {D.him} to take bookings.", "\"{D.He} gave a first name and no number. The deposit stayed in {D.his} account.\""),
               .cross("Were there other bookings?", "\"Two more deposits, from people who caught on and disputed the charges.\""),
               .cross("{DL} says a man named Kurt hired {D.him}?", "\"{D.He} gave a first name and no number, and could not tell us where to find him. The deposit stayed in {D.his} own account the whole time.\""),
               .cross("Other people had also been taken by this listing?", "\"Two more deposits came in from people who caught on and disputed the charges, so the money was returned. {V}'s was the only one that was not.\""),
               .cross("You can't say who posted the photos?", "\"The site's records say the account was made from {DL}'s phone. Whether {DL} typed it or someone sat beside {D.him}, I cannot say.\"")],
        theory: ("{D} copied the photos, posted the listing, and kept the deposit.", "{D} answered phones for a man who ran the scam."),
        allocution: "\"A man named Kurt paid me to answer calls and take deposits. I was supposed to send the money to him, and he never gave me a way. I was waiting to hear from him. That family drove a long way.\"",
        truths: ("The listing account was created from {DL}'s phone, by the site's records.", "The man {DL} named was later arrested running the same listing in two other counties."),
        defendant: [.direct("Did you post the listing?", "\"No. A man named Kurt paid me to answer calls and take deposits.\""),
               .direct("Where's the money?", "\"I was supposed to send it to him. He never gave me a way.\""),
               .direct("How did you get involved?", "\"A man named Kurt offered me a little money to answer phone calls and take deposits for a rental house. I had been out of work, and I thought it was a simple way to earn a few dollars.\""),
               .direct("What did you tell {V} when {V.he} called?", "\"I said the house was available and the deposit would hold the week. I repeated what Kurt told me, and I thought the house was Kurt's to rent.\""),
               .direct("Where is the $2,100?", "\"It is still in my account. I was supposed to send it to Kurt, but he never gave me a way to do it, and I did not want to hand cash to a stranger.\""),
               .direct("When did you realize something was wrong?", "\"When {V} called me from the driveway and said the owners were inside. I told {V.him} I was sorry and that I did not know, and I stopped answering after that.\""),
               .cross("So you kept it.", "\"I was waiting to hear from him.\""),
               .cross("Kurt who?", "\"I don't know his last name.\""),
               .cross("You kept a family's deposit for weeks.", "\"I did, because I did not know what to do with it. I should have refunded it the minute I heard, and I did not.\""),
               .cross("The listing was made from your phone.", "\"That is what they say. Kurt had me install an app and set up some accounts, and I do not know what he did on my phone.\""),
                    .cross("You told {V} the house was available.", "\"I repeated what Kurt told me to say. I should not have said it as if I knew it was true.\"")],
        openings: ("A listing for a sound-front house in {HOOD} used photos copied from a real estate site and took a $2,100 deposit from {V}, who drove from Ohio with three children to find the real owners living there. The payment account and the phone number are {D}'s.", "The defense will say a man named Kurt paid {D} to answer calls and take deposits, and that {D} never posted the listing. {D} repeated what Kurt said and still has the deposit in {D.his} account."),
        closings: ("The deposit went to {D}'s account, the listing's phone number is {D}'s, and the site traces the listing account to {D}'s phone. {D} had been before this court over {PRIOR}, and Kurt has no last name and no number.", "{D} was an answering service for a stranger and kept a deposit {D.he} could not send on. The State must prove {D} knew the house was not for rent when {D.he} told {V} it was."),
        timeline: [(-30, "Listing posted."), (-21, "{V} pays the deposit."), (0, "{V} arrives to find the owners home.")],
        identified: "The payment account and the listing's phone number.",
        impact: "\"We had planned that beach week for a year and paid a two thousand one hundred dollar deposit to a listing that didn't exist. We drove there with the kids and had nowhere to stay, and my children slept in the car that night. We drove home the next day.\"")

    // MARK: - After the skimmer

    static let atmSkimmer = followUp(
        key: "story.followup.atmSkimmer", category: .whiteCollar,
        headlines: ["Skimmer and Pinhole Camera Found on Bank ATM", "Bank Says 60 Customers' Cards Copied at Branch ATM"],
        law: "cardFraud",
        spec: "Used counterfeit cards encoded with account numbers stolen from a bank ATM to withdraw $4,200, on or about {DATE}.", victim: false,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a branch manager at {PLACE.BANK} in {HOOD} found a card reader overlay and a pinhole camera on the drive-up ATM. Sixty customers' numbers had been copied. Over three nights, $4,200 was withdrawn with cloned cards at ATMs in two counties. The bank's cameras show a person in a mask at those machines; the overlay carried a partial fingerprint matching {D}. {DL} says {D.he} handles ATMs at work as a cleaning contractor and must have touched it then.",
        state: [E(.forensic, 3, "Fingerprint", "A partial print on the inside of the overlay matches {DL}'s right thumb."),
                E(.video, 2, "ATM Cameras", "A masked person makes the withdrawals; build and gait consistent with {DL}.")],
        defense: [E(.document, 1, "Work Orders", "{DL}'s cleaning company services that branch's drive-up ATMs monthly.")],
        witnessRole: "Financial crimes detective",
        exam: [.direct("Where was the print?", "\"Inside the overlay, on the glue side. You touch that when you build it, not when you wipe the machine.\""),
               .direct("What do the withdrawal videos show?", "\"A masked person. I can't give you a face.\""),
               .direct("What did the branch manager find at the drive-up ATM?", "\"A card reader overlay and a pinhole camera mounted above the keypad. Together they copied card numbers and recorded PINs from the people using the machine.\""),
               .direct("How many customers were affected?", "\"Sixty customers' card numbers were copied. Over three nights, $4,200 was withdrawn with cloned cards at ATMs in two counties.\""),
               .direct("What did the bank cameras show at the withdrawal machines?", "\"A person in a mask, in a hooded jacket, making the withdrawals at each of the three nights. The build and gait are consistent with {DL}, but the face is covered.\""),
               .direct("How was {DL} connected to this branch?", "\"{DL}'s cleaning company services that branch's drive-up ATMs every month. The work orders show {DL} was there to clean the machines.\""),
               .cross("{DL} cleans that ATM every month?", "\"{D.He} cleans the outside. The print was inside the overlay.\""),
               .cross("Can you say when the print was left?", "\"No. Prints don't carry a date.\""),
               .cross("The print could have come from cleaning, couldn't it?", "\"A cleaner touches the outside of a machine. This print was inside the overlay on the glue side, where you only touch the part when you are building it.\""),
               .cross("Someone else could have built the overlay, couldn't they?", "\"Someone else could have. A coworker who quit the week after later turned up with the encoder and the remaining cards, but we found the blank cards and an encoder in {DL}'s garage too.\""),
                    .cross("Other people could have touched that overlay?", "\"Anyone who built it or installed it could have. A coworker who quit the week after later turned up with the encoder, though I cannot say what he touched.\"")],
        theory: ("{D} built the overlay; {D.his} thumb is on the glue side.", "{D} cleans that ATM for a living. A print with no date isn't a crime."),
        allocution: "\"I clean those machines, and I must have touched it while I was cleaning. I don't know how that overlay got there. I never put anything on that ATM. I won't go near another bank card I don't own. I'm sorry to the bank.\"",
        truths: ("A search found blank cards and an encoder in {DL}'s garage.", "A coworker who quit the week after had the encoder and the remaining cards."),
        defendant: [.direct("How did your print get on that overlay?", "\"I clean those machines every month, so my prints could be on the outside of one. I don't know how one got on the inside of that overlay.\""),
               .direct("Did you make the withdrawals?", "\"No. I didn't make the withdrawals, and I never had the card.\""),
               .direct("What is your job?", "\"I run a small cleaning company. We clean offices, a few bank branches, and the drive-up ATMs on a monthly schedule. I did the work at that branch myself.\""),
               .direct("What do you do when you clean an ATM?", "\"I wipe down the screen, the keypad and the card slot, and I empty the trash bin next to the machine. I do not open anything or take anything apart.\""),
               .direct("Why did you have blank cards in your garage?", "\"I buy blank cards for a hobby, because I like making membership cards for a car club. I did not use them for anything else, and I did not have any customer numbers on them.\""),
               .direct("What about the encoder in your garage?", "\"The encoder was for the same car club cards. I know that sounds convenient, but there are a lot of people who use one for hobbies.\""),
               .cross("Inside the overlay, on the glue side?", "\"I have no idea how it came to be there. I only ever cleaned the outside of the machine.\""),
               .cross("Where were you the three nights of the withdrawals?", "\"Home. I was at home all three nights, and I can show you my phone.\""),
               .cross("Your print was inside the overlay.", "\"I cannot explain how it got there. I did not build an overlay, and I have been trying to understand how a print of mine ended up on that part.\""),
               .cross("The withdrawals were made by someone your size.", "\"A lot of people are my size. I was at home those nights and my phone will show where I was, and I was not at those machines.\""),
               .cross("A coworker who quit the week after had the remaining cards.", "\"That is true, and I have told the detective about him. He had a key to the garage and he knew my schedule.\"")],
        openings: ("A branch manager found a card reader overlay and a pinhole camera on the drive-up ATM, sixty customers' numbers were copied, and $4,200 was withdrawn over three nights. A partial print on the glue side of the overlay matches {D}'s right thumb.", "The defense will say {D} cleans that ATM every month for a living and that a print with no date proves nothing. {D} was home those nights, and a coworker who quit the next week had the encoder and the cards."),
        closings: ("A masked person withdrew $4,200 with cloned cards, and the thumbprint inside the overlay, on the glue side, is {D}'s. {D} had already been here over {PRIOR}, and blank cards and an encoder were in {D.his} garage.", "{D} cleans machines that other people touch, and a print has no date on it. A masked figure of {D}'s size is not {D}, and the State must prove {D} built the overlay and made the withdrawals."),
        timeline: [(-5, "Overlay installed on the drive-up ATM."), (-3, "First cloned-card withdrawals."), (0, "Branch manager finds the overlay.")],
        identified: "A fingerprint on the overlay.")

    static let washedChecks = followUp(
        key: "story.followup.washedChecks", category: .whiteCollar,
        headlines: ["Checks Stolen From Mailboxes Washed and Cashed, Deputies Say", "Mailbox Theft Ring: One Charged"],
        law: "uttering",
        spec: "Uttered a forged check drawn on the account of {V}, altered to $2,850 and payable to {D}, on {DATE}.", victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V} mailed a $45 check to the water department from {V.his} curbside mailbox in {HOOD}. It was cashed for $2,850, payable to {D}, at a check-cashing store, with the payee and amount chemically washed and rewritten. The store's camera shows {DL} at the counter with {D.his} own driver's license. {DL} says a man paid {D.him} $200 to cash checks he said were for odd jobs.",
        state: [E(.video, 3, "Counter Camera", "{DL} cashes the check with {D.his} own license."),
                E(.forensic, 2, "Document Examiner", "Ink washing removed the original payee and amount; the new writing was added over it.")],
        defense: [E(.statement, 1, "The Man With the Checks", "{DL} says a man paid {D.him} $200 per check to cash them.")],
        witnessRole: "Financial crimes detective",
        exam: [.direct("Who cashed the check?", "\"{DL}, on camera, with {D.his} own license.\""),
               .direct("What happened to the check?", "\"It was washed: the payee and amount removed with chemicals, and rewritten to {DL} for $2,850.\""),
               .direct("How did the check come to your attention?", "\"{V} mailed a $45 check to the water department from a curbside mailbox. When the bank returned it, it had been cashed for $2,850 and made out to {DL}, so {V} reported it.\""),
               .direct("What did the document examiner find?", "\"Ink washing had removed the original payee and amount, and new writing had been added over the same lines. The paper still showed the faint outline of the original $45.\""),
               .direct("Where was the check cashed?", "\"At a check-cashing store, where the counter camera shows {DL} handing over the check and showing {D.his} own driver's license. The clerk paid out $2,850.\""),
               .direct("What did the search of {DL}'s home turn up?", "\"A shoebox in {DL}'s closet held chemicals commonly used to wash checks and several stolen envelopes from other mailboxes. None of them belonged to {DL}.\""),
               .cross("Did {DL} alter the check?", "\"I can't say who washed it.\""),
               .cross("{DL} used {D.his} own ID. That's not what a forger usually does.\"", "\"It's what someone does when they're paid to take the risk.\""),
               .cross("{DL} used {D.his} own license at the counter, didn't {D.he}?", "\"Yes, {D.he} did. People who are paid to take a risk will often use their real identification, because the man who pays them is not the one standing at the counter.\""),
               .cross("You can't say who washed the check?", "\"I cannot. The examiner can say it was washed and rewritten, but not by whom. That is why the shoebox in the closet matters.\""),
               .cross("The man {DL} described was arrested in a sweep, wasn't he?", "\"He was. He had a list of people he paid to cash checks, and we found {DL}'s name on that list along with others.\"")],
        theory: ("{D} cashed a washed check made out to {D.him} for $2,850. Nobody honest gets paid $200 to cash a stranger's check.", "{D} was used by the man who stole and washed the checks."),
        allocution: "\"A man I met at the gas station said he paid people for odd jobs, and I cashed those checks for him because he said it was easier for him. They looked like checks. I should have known. I'm sorry to {V}, and I'll repay the twenty-eight hundred dollars.\"",
        truths: ("Chemicals and stolen envelopes were in a shoebox in {DL}'s closet.", "The man {DL} described was arrested in a mailbox theft sweep with a list of the people he paid to cash checks."),
        defendant: [.direct("Where did the check come from?", "\"A man I met at the gas station said he paid people for odd jobs by check and needed them cashed.\""),
               .direct("Did you know it was altered?", "\"No. It looked like a check.\""),
               .direct("How did you meet the man with the checks?", "\"At a gas station. He said he paid people for odd jobs by check and needed some of them cashed, and he offered me two hundred dollars for each one I took in.\""),
               .direct("Why did you agree to cash them?", "\"I was behind on my bills and the money looked easy. I did not think it was a crime to take a check from someone and cash it.\""),
               .direct("What was in the shoebox in your closet?", "\"The man left it with me. He said it held supplies for his work, and I never opened it. I did not know there were chemicals or envelopes inside.\""),
               .direct("Did you notice anything strange about the check?", "\"Only that it was made out to me, which seemed odd. He said it was easier for him that way, and the check looked normal to me when I took it in.\""),
               .cross("He paid you $200 to cash a check made out to you?", "\"He said it was easier for him.\""),
               .cross("For work you never did.", "\"I didn't think about it.\""),
               .cross("You used your own license because you thought it was legal.", "\"I used it because I had nothing to hide. I thought I was doing him a favor and getting paid for it, not doing anything wrong.\""),
               .cross("Chemicals and envelopes were found in your closet.", "\"They were in a box the man left. I have never washed a check, and I do not know how it is done.\""),
                    .cross("The man never gave you his name.", "\"He gave me a first name, and I did not ask for more. I know how foolish that sounds now.\"")],
        openings: ("{V} mailed a $45 check to the water department, and it came back cashed for $2,850, payable to {D}, with the payee and amount chemically washed away and rewritten. The store camera shows {D} at the counter with {D.his} own license.", "The defense will say a man at a gas station paid {D} $200 a check to cash checks for him, and that {D} did not know they had been washed. {D} stood in front of a camera with {D.his} real name and did not hide."),
        closings: ("A washed check, a rewritten payee, and {D}'s license on the counter camera. A shoebox of chemicals and stolen envelopes was in {D}'s closet, and This was not {D}'s first case here, since {PRIOR} came first.", "{D} was a courier for a man who washed the checks, and the man has been arrested. A person who shows {D.his} own ID did not mean to hide, and the State must prove {D} knew the check was altered."),
        timeline: [(-4, "{V} mails a $45 check."), (0, "The check is cashed for $2,850."), (6, "{V}'s bank flags the item.")],
        identified: "The check-cashing store's camera and ID scan.",
        impact: "\"I'm on a fixed income, and that check was supposed to be a forty-five dollar water bill. Instead it was cashed for twenty-eight hundred fifty dollars, and that was my whole month. I've had to ask my daughter for help with my rent.\"")

    // MARK: - After the fake utility worker

    static let roofDeposit = followUp(
        key: "story.followup.roofDeposit", category: .whiteCollar,
        headlines: ["Elderly Couple Paid $2,400 for Roof Work That Never Started", "Door-to-Door 'Roofer' Charged"],
        law: "exploitationElder", lesser: "falsePretenses",
        spec: "Obtained $2,400 from {V}, an older adult, by falsely promising roof repairs, on or about {DATE}.", victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a man knocked on doors on {STREET} in {HOOD} after a storm, saying he'd spotted loose shingles and could fix them that week. {V}, 79, paid $2,400 in cash as a deposit. No work was ever done, and the phone number on the handwritten estimate went dead. {V} and a neighbor both identified {D}, and the neighbor photographed {D.his} truck. {DL} says {D.he} meant to do the work and lost the job to a family emergency.",
        state: [E(.document, 2, "Handwritten Estimate", "A $4,800 estimate with {DL}'s first name and a disconnected number; \"$2,400 down, cash.\""),
                E(.statement, 3, "Neighbor's Photo", "The neighbor photographed {DL}'s truck and spoke to {D.him} on the street.")],
        defense: [E(.statement, 1, "Family Emergency", "{DL} says {D.his} mother was hospitalized that week.")],
        witnessRole: "Property crimes detective",
        exam: [.direct("How many homes did {DL} visit?", "\"Six on that street. Two paid deposits: {V}, and a man who got his back after threatening to call us.\""),
               .direct("Did {DL} buy any materials?", "\"No supply house in the county has a sale to {D.him} that month.\""),
               .direct("What did the man say when he knocked on {V}'s door?", "\"That he had spotted loose shingles after the storm and could fix them that week. He wrote up a handwritten estimate for $4,800 and asked for $2,400 down in cash.\""),
               .direct("How old is {V}?", "\"{V} is 79, lives alone, and paid the deposit in cash that afternoon. No work was ever done, and the phone number on the estimate went dead within days.\""),
               .direct("How was {DL} identified?", "\"{V} picked {DL} out, and a neighbor who spoke to {D.him} on the street identified {D.him} as well. The neighbor also photographed {D.his} truck.\""),
               .direct("What other homes did {DL} visit?", "\"Six on that street. Two people paid deposits: {V}, and a man who got his money back after threatening to call us.\""),
               .cross("{DL}'s mother was in the hospital that week?", "\"For two days. The deposit was taken eleven days before that.\""),
               .cross("{D.He} didn't flee the county.", "\"No. {D.He} changed phone numbers.\""),
               .cross("{DL} says {D.his} mother was in the hospital that week?", "\"That is true for two days. It was eleven days after the deposit was taken, so it does not explain why no work started.\""),
               .cross("{DL} lost the truck too, didn't {D.he}?", "\"{DL} says so. The truck was in the neighbor's photo on the street the day the deposit was taken, so it was running then.\""),
               .cross("{DL} paid {V} back, didn't {D.he}?", "\"Eventually, before the verdict, according to {V}'s family. That was after the charge was filed and months after the deposit.\"")],
        theory: ("{D} went door to door after a storm, took cash from a 79-year-old, and changed {D.his} number.", "{D} meant to do the job and got overwhelmed. That's a broken contract, not a crime."),
        allocution: "\"I meant to do the roof work. Then my mother went into the hospital and my truck broke down, and everything fell apart at once. I couldn't pay the bill, and the number went dead. I'll pay her back every dollar.\"",
        truths: ("{DL} took deposits from three more homeowners in another county the same month.", "{DL}'s mother's illness and lost truck were real; {D.he} paid {V} back in full before the verdict."),
        defendant: [.direct("Did you intend to do the work?", "\"Yes. Then my mother went in the hospital and my truck broke down.\""),
               .direct("Why change your number?", "\"I couldn't pay the bill.\""),
               .direct("What is your work?", "\"I do roofing and general repair, mostly on my own. After a storm there is a lot of work, and I knock on doors in neighborhoods that were hit.\""),
               .direct("What happened to your plans for the job?", "\"My mother went into the hospital and my truck broke down in the same week. I could not get materials or get to the house.\""),
               .direct("Did you pay {V} back?", "\"I did, in full, before the verdict. I wish I had done it sooner, and I am sorry that {V.he} had to wait.\""),
               .direct("What did you tell {V} about when you would start?", "\"That my crew would be there within the week. I meant it when I said it, and then everything fell apart.\""),
                    .cross("Two days in the hospital, eleven days after you took the money.", "\"Everything fell apart at once.\""),
               .cross("And not a shingle bought.", "\"I was going to buy them. I never got around to it, and I know how that looks.\""),
               .cross("You took $2,400 in cash from a woman who is 79.", "\"I did, and I meant to do the work. I know that is hard to believe now, but I did not go there planning to keep it.\""),
               .cross("You did the same thing in another county.", "\"I took deposits there too, and I did not finish those jobs either. I was in over my head and did not know how to stop.\""),
                    .cross("You took cash and gave no receipt.", "\"I wrote a handwritten estimate with the amount down. I did not write a receipt, and I should have.\"")],
        openings: ("After a storm, a man knocked on doors on {STREET} offering to fix loose shingles that week, and {V}, 79, paid $2,400 in cash on a handwritten estimate. No work was ever done, the phone number went dead, and {V} and a neighbor identified {D}.", "The defense will say {D} meant to do the job but {D.his} mother was hospitalized and {D.his} truck broke down, so the work never started. A broken contract is a civil matter, and {D} paid {V} back in full."),
        closings: ("A $2,400 cash deposit from a 79-year-old, no materials bought, a dead phone number, and a neighbor's photo of {D}'s truck. {D} had been before this court over {PRIOR} and had taken deposits from three more homeowners.", "{D} meant to do the work, then a hospital stay and a broken truck got in the way, and {D} paid {V} back in full. The State must prove {D} never intended to do the job when {D.he} took the money."),
        timeline: [(0, "{DL} knocks on doors on {STREET}; {V} pays $2,400."), (11, "{DL}'s mother hospitalized two days."), (21, "{V} reports the deposit.")],
        identified: "The neighbor's photo and the estimate.",
        impact: "\"I'm seventy-nine, and I took that money out of the bank in cash because the man asked me to. I paid him twenty-four hundred dollars as a deposit and never saw him again. I felt so foolish telling my family what I had done.\"")

    static let pawnedRing = followUp(
        key: "story.followup.pawnedRing", category: .property,
        headlines: ["Stolen Wedding Rings Pawned Under Local Man's License", "Pawn Shop Records Lead to Possession Charge"],
        law: "possStolen", lesser: "misdLarceny",
        spec: "Possessed and pawned two rings stolen from the home of {V}, knowing or having reason to believe they were stolen, on {DATE}.", victim: true,
        summary: "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, two rings stolen in a daytime break-in at {V}'s home in {HOOD} were pawned at {PLACE.PAWN} the next morning for $380, under {D}'s driver's license. Pawn shops report every item to the Sheriff's Office database, which flagged them. {DL} says a woman at a motel sold {D.him} the rings for $100 and {D.he} pawned them to make a quick profit.",
        state: [E(.document, 3, "Pawn Ticket", "Two rings pawned under {DL}'s license and thumbprint the morning after the break-in."),
                E(.statement, 2, "Database Hit", "The rings matched {V}'s stolen-property report by engraving.")],
        defense: [E(.statement, 1, "Motel Purchase", "{DL} says {D.he} bought the rings for $100 from a woman at a motel.")],
        witnessRole: "Property crimes detective",
        exam: [.direct("How were the rings found?", "\"Pawn shops report every item. The engraving matched {V}'s report.\""),
               .direct("When were they pawned?", "\"Nine the next morning. Less than a day after the break-in.\""),
               .direct("What was taken from {V}'s home?", "\"Two rings were stolen in a daytime break-in. Both carried an engraving, and {V} gave us the initials when {V.he} filed the report.\""),
               .direct("How were the rings located?", "\"Pawn shops report every item they take to a Sheriff's Office database. The engraving on the two rings matched {V}'s stolen-property report, and that triggered a hit.\""),
               .direct("Who pawned them?", "\"{DL} pawned both rings the next morning at nine, for $380, using {D.his} own driver's license and leaving a thumbprint on the ticket.\""),
               .direct("What did a neighbor's camera show?", "\"{DL}'s car on {V}'s street on the afternoon of the break-in. It was parked for about twenty minutes and then drove away.\""),
               .cross("Nothing ties {DL} to the break-in itself?", "\"No prints, no video at the house. {D.He}'s charged with having them.\""),
               .cross("Did you look for the woman at the motel?", "\"{DL} couldn't name the motel.\""),
               .cross("The pawn ticket is not proof that {DL} took the rings, is it?", "\"No, it isn't. It proves {DL} had them less than a day after they were stolen. The camera on the street is what ties {D.him} to the neighborhood.\""),
               .cross("Plenty of people park on that street, don't they?", "\"They do. But the car was {DL}'s, and it was there during the hours of the break-in.\""),
               .cross("The woman at the motel could be real?", "\"She is real. She sold stolen jewelry to several people at a Bayard motel that week. {DL} has never told us which motel, and I only learned about her from another case.\"")],
        theory: ("{D} pawned two engraved rings less than a day after they were stolen. {D.He} knew.", "{D} bought cheap jewelry and resold it. Buying isn't stealing."),
        allocution: "\"A woman at a motel needed money, and I gave her a hundred dollars for both rings. She said they were hers, and I didn't look that close. I know now that wasn't smart. I'll stay away from pawn shops, and I'm sorry to {V}.\"",
        truths: ("A neighbor's camera showed {DL}'s car on {V}'s street the afternoon of the break-in.", "The woman was found: she had sold stolen jewelry to several people at a Bayard motel that week."),
        defendant: [.direct("Where did you get the rings?", "\"A woman at a motel needed money. A hundred dollars for both.\""),
               .direct("Did you know they were stolen?", "\"No. She said they were hers.\""),
               .direct("How did you come to have the rings?", "\"A woman at a motel needed money quickly. She said the rings were hers and offered both for a hundred dollars, and I bought them at night.\""),
               .direct("Why did you pawn them the next morning?", "\"I figured I could make a quick profit. A hundred dollars for two rings looked like a deal, and the pawn shop was willing to pay $380.\""),
               .direct("Did you look at the rings before you bought them?", "\"Only quickly, in the dark of the motel parking lot. I could see they were gold, and I did not look for any engraving.\""),
               .direct("Why were you on {V}'s street that afternoon?", "\"I drive through there on my way to a friend's house. I may have parked there for a few minutes, but I never went near {V}'s home.\""),
               .cross("Engraved with someone else's initials?", "\"I didn't look that close.\""),
               .cross("Bought at night, pawned at nine the next morning.", "\"I needed the money. I bought it at night and pawned it the next morning, and I regret it.\""),
               .cross("You used your own license at the pawn shop.", "\"I did, because I had nothing to hide. A man who stole jewelry would not leave his thumbprint on a ticket.\""),
                    .cross("You paid $100 for two rings from a stranger at a motel.", "\"It was a good price, and I knew it. I should have asked why she was selling them so cheaply.\""), .cross("You cannot name the motel.", "\"I cannot. I was driving at night, and I did not look at the sign.\"")],
        openings: ("Two engraved rings were stolen in a daytime break-in at {V}'s home, and the next morning {D} pawned them for $380 under {D.his} own driver's license and thumbprint. A neighbor's camera shows {D}'s car on {V}'s street that afternoon.", "The defense will say a woman at a motel sold {D} the rings for $100 and {D} pawned them for a quick profit. Buying cheap jewelry is not stealing, and {D} used {D.his} own license and thumbprint."),
        closings: ("The engraving matched, the pawn ticket carries {D}'s license and thumbprint, and {D}'s car sat on {V}'s street during the break-in. {D} had been here over {PRIOR}, and {D.he} cannot name the motel.", "{D} bought cheap jewelry from a woman at a motel and sold it quickly. No print and no video places {D} at the house, and the State must prove {D} knew the rings were stolen."),
        timeline: [(-1, "Daytime break-in at {V}'s home."), (0, "Rings pawned at 9 a.m.")],
        identified: "The pawn shop's mandatory report to the Sheriff's Office.",
        impact: "\"One of those rings was my grandmother's, and I got it back. The other one the pawn shop had already sold, and I'll never see that stone again. It felt terrible to know a stranger had been through my bedroom while I was at work.\"")
}
