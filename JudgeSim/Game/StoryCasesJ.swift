import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchJ: [CaseTemplate] = [catalyticConverters, pawnTools, forgedCheck, unsecuredGun, fakeAccounts]

    // MARK: - 59. The catalytic converters (a church van and a reciprocating saw)

    static let catalyticConverters = CaseTemplate(
        key: "story.catalyticConverters", category: .property,
        headlines: ["Catalytic Converters Cut From Church Vans", "Converter Thefts: Suspect Caught With Saw and Six Converters"],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 5, lesserThreshold: 3,
        specification: "Stole catalytic converters valued at more than $1,000 from vehicles belonging to {CHURCH}.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole catalytic converters from three other vehicles found in the hatchback.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Damaged three passenger vans belonging to {CHURCH} by cutting out their exhaust components.", chance: 1.0, threshold: 4)
        ],
        ageRange: 20...35, occupations: ["unemployed", "construction laborer"], forcedPriorOffenses: ["Possession of Stolen Goods"], hasVictim: false,
        summaries: [
            "Before dawn on {DATE}, someone cut the catalytic converters from three passenger vans in the lot of {CHURCH} in {HOOD}. Twenty minutes later, a deputy stopped {D}'s hatchback four miles away for a broken taillight and saw six converters and a battery-powered reciprocating saw in the back. Three of the converters had fresh cuts and paint flecks matching the vans. {DL} says a man named \"Tank\" paid {D.him} $100 to drive the converters to a scrap yard in Bayard and that {D.he} never went to the church."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Converters in the Car", "Six catalytic converters in {DL}'s hatchback; three with fresh saw cuts and white paint flecks matching the church vans.", .search),
            E(.physical, 2, "Saw", "A reciprocating saw with a metal-cutting blade, warm battery, in the back seat.", .search),
            E(.document, 2, "Replacement Cost", "Replacement and repair for the three vans: $5,850."),
            E(.statement, 1, "Statement at the Stop", "{DL} told the deputy, \"Those aren't mine, I'm just driving them.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 2, "No Camera", "The church lot had no camera, and no one saw the theft."),
            E(.statement, 2, "Tank", "{DL} gave detectives a first name, a phone number, and a description of the man who hired {D.him}; the number belonged to a burner phone."),
            E(.document, 1, "No Prints", "Fingerprints on the saw were smudged and unusable.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Sheriff's deputy",
                        direct: ["\"Six converters and a warm saw.\""],
                        cross: ["\"I didn't see {DL} at the church.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you stop {DL}?", "\"A broken taillight at 5:10 a.m. on Route 17. When I walked up, I could see converters stacked behind the seat.\""),
                            .direct("What did you notice about them?", "\"Three had bright, fresh cuts and white paint on the pipe. The saw on the seat had a warm battery.\""),
                            .direct("What did {DL} say?", "\"'Those aren't mine, I'm just driving them.'\""),
                            .cross("You didn't see {DL} at the church?", "\"I didn't. I was on patrol out on 17; I never went by the church.\""),
                            .cross("Was anyone else in the car?", "\"No. Just {DL}.\""),
                            .cross("A battery stays warm after charging, too?", "\"For a while, sure.\"")
                        ]),
            WitnessSeed(name: nil, role: "Church facilities manager",
                        direct: ["\"The vans were fine at 10 p.m.\""],
                        cross: ["\"I don't know who did it.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("When had you last seen the vans?", "\"I checked the lot at 10 p.m. the night before. All three were fine.\""),
                            .direct("What happened to the vans?", "\"I came in at 6:30 and the first one roared like a motorcycle when I started it. All three had the converters cut out. We couldn't drive the seniors to their appointments for two weeks.\""),
                            .direct("What did the repairs cost?", "\"$5,850 to replace the converters and repair all three vans.\""),
                            .cross("The lot has no cameras?", "\"No. We've asked for donations for them.\""),
                            .cross("So you don't know who cut the converters?", "\"No. I wasn't there, and nobody saw it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s former roommate",
                        direct: ["\"There's a guy called Tank.\""],
                        cross: ["\"I don't know his real name.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Do you know someone called Tank?", "\"Yeah. Big guy, hangs around the scrap yards. He pays people to haul stuff so his name isn't on anything.\""),
                            .direct("Did {DL} work for him?", "\"{DL} drove for him a couple of times when {D.he} needed money. Hauling, that's all.\""),
                            .cross("You don't know Tank's real name?", "\"Just Tank. I never asked for more than that.\""),
                            .cross("You've been convicted of larceny yourself?", "\"Two years ago.\"")
                        ])
        ],
        prosecutionTheory: ["Twenty minutes after the theft, {D} was alone with the church's converters, fresh paint on them, and a warm saw. Possession of recently stolen property is evidence of theft."],
        defenseTheory: ["{DL} was a paid driver for someone else. Nobody saw who cut the converters, and the State never looked for Tank."],
        aggravating: ["The offense harmed a charitable organization"],
        mitigating: [],
        victimImpacts: ["The church's pastor: \"Forty seniors missed dialysis rides and doctor's appointments. People had to choose between groceries and a cab.\""],
        allocutions: ["\"I needed a hundred dollars. I should have asked what I was hauling.\""],
        guiltyTruths: ["A gas station camera near the church later showed {DL}'s hatchback pulling out of the church's street at 4:44 a.m."],
        innocentTruths: ["A scrap yard later identified a regular seller called Tank who had sent three different drivers in with converters that month."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["CHURCH": ["Greater Hope Baptist Church", "St. Mark's Lutheran Church", "New Life Fellowship"]],
        story: StoryExtras(
            timeline: [(0, "About 4:30 a.m.: converters cut from three church vans."),
                       (0, "5:10 a.m.: traffic stop; converters and saw found."),
                       (0, "6:30 a.m.: church discovers the theft."),
                       (1, "Paint flecks compared; {DL} charged."),
                       (4, "Phone number for 'Tank' traced to a burner.")],
            howIdentified: "A traffic stop twenty minutes after the theft.",
            notDone: ["Scrap yards in Bayard were never asked about a seller called Tank.", "Nearby business cameras were not canvassed."],
            defendantExam: [
                .direct("How did the converters get in your car?", "\"Tank met me at a gas station on 17 and loaded them in. He said take them to the yard in Bayard and he'd meet me with a hundred bucks.\""),
                .direct("Whose saw was it?", "\"Tank put it in too. I didn't look at it.\""),
                .cross("You didn't wonder why someone pays $100 to haul converters at 5 a.m.?", "\"I wondered. I needed the money more than I wanted to know.\""),
                .cross("You have a prior conviction for possessing stolen goods.", "\"I do. That's why I should've known better.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Deputy, what did you think when you saw the converters?\"",
                                  answer: "\"That I'd caught the guy who's been hitting every church lot in the county.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation and uncharged acts", shouldSustain: true,
                                  explanation: "The deputy's belief about other thefts is speculation and suggests uncharged crimes.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "Twenty minutes, four miles, and the church's converters in the back seat.",
            defenseOpening: "A driver paid to haul, and a man called Tank nobody looked for.",
            prosecutionClosing: "Recently stolen property, in {DL}'s possession, with the tool that cut it. That's theft.",
            defenseClosing: "Possession is evidence; it isn't proof {DL} was the one under those vans."
        )
    )

    // MARK: - 60. The pawn shop tools (did the owner know?)

    static let pawnTools = CaseTemplate(
        key: "story.pawnTools", category: .property,
        headlines: ["Pawn Shop Owner Charged After Stolen Tools Found on Shelves", "Contractor Finds Stolen Tools for Sale"],
        primaryLaw: "possStolen", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Possessed tools valued at more than $1,000 belonging to {V}, knowing or having reasonable grounds to believe they were stolen.",
        ageRange: 40...65, occupations: ["pawn shop owner"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, a contractor whose trailer had been broken into the week before, walked into {PAWN} on {STREET} and found eleven of {V.his} engraved tools on the shelf. The shop's records show {D}, the owner, bought them from one seller in a single visit for $340, against a retail value of about $4,800, and that the engravings reading \"{VL} CONSTRUCTION\" were plainly visible. The seller gave a fake address. {DL} says {D.he} followed the law, checked ID, reported the purchase to the police database, and that engraved tools are common in estate sales."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Engraved Tools", "Eleven tools engraved \"{VL} CONSTRUCTION,\" recovered from {DL}'s shelves."),
            E(.document, 2, "Purchase Record", "All eleven bought from one seller in one visit for $340; retail value about $4,800."),
            E(.document, 2, "Seller's Address", "The seller's listed address was a vacant lot."),
            E(.video, 1, "Counter Video", "The counter camera shows {DL} turning one tool over and looking at the engraving before paying.")
        ],
        defenseEvidence: [
            E(.document, 3, "Police Database Report", "{DL} reported the purchase, with the seller's ID and item descriptions including the engravings, to the police pawn database the same day, as required."),
            E(.document, 2, "Hold Period", "{DL} held the items the full required period before putting them out for sale."),
            E(.document, 1, "Clean Inspections", "Six years of police pawn inspections with no violations.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Contractor",
                        direct: ["\"My name was right on them.\""],
                        cross: ["\"The pawn shop reported them.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you find your tools?", "\"I'd been checking every pawn shop in the county. I walked into {PAWN} and there was my rotary hammer with my company name engraved on the side.\""),
                            .direct("What were they worth?", "\"About forty-eight hundred to replace. {DL} paid three-forty for all of them.\""),
                            .cross("Did you report your company name to police when you reported the theft?", "\"I said the tools were engraved, yes.\""),
                            .cross("The shop put the engraving in its report to the police database?", "\"That's what I was told. Nobody at the police called me.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"$340 for $4,800 in tools is a red flag.\""],
                        cross: ["\"{DL} reported everything correctly.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What made you suspect {DL} knew?", "\"Eleven engraved tools from one company, sold by one person for seven cents on the dollar, with a fake address. And the video shows {DL} reading the engraving.\""),
                            .cross("{DL} reported the purchase, the seller's ID, and the engraving to the police database the same day?", "\"Same afternoon. Seller's license, the engraving, all of it.\""),
                            .cross("Did anyone at the police department check the database against the contractor's theft report?", "\"No. That should have been caught on our end.\""),
                            .cross("Pawn shops always pay a fraction of retail?", "\"Usually a quarter to a third. Seven percent is low.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Retired police pawn detail officer",
                        direct: ["\"{DL} did it by the book.\""],
                        cross: ["\"Low prices can be a sign.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you do on the pawn detail?", "\"I inspected pawn shops and checked their reports to the police database.\""),
                            .direct("How did {DL}'s shop do on inspections?", "\"Six years, no violations. {DL} was one of the shops we didn't worry about. Thieves avoid places that report everything.\""),
                            .direct("Did {DL} report these tools the way the rules require?", "\"Yes. Same day, with the seller's ID and the engraving in the description. Then {D.he} held them the full period.\""),
                            .cross("Would a $340 price for $4,800 in tools concern you?", "\"It would make me look harder. Used tools sell low, but that's low.\""),
                            .cross("Eleven tools with one company's name on them, from one seller, would concern you too?", "\"It would. I'd want to know how one person came to have them all.\"")
                        ])
        ],
        prosecutionTheory: ["{D} paid $340 for $4,800 in tools engraved with a company name, from a seller with a fake address, and read the engraving on camera. {D.He} had reasonable grounds to know."],
        defenseTheory: ["{DL} reported everything, engraving included, to the police the same day and held the tools the full period. A fence doesn't hand the police the evidence."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"I paid to rent tools for a month while mine sat on a shelf with my name on them.\""],
        allocutions: ["\"I did what the law told me to do. I should have called the number on the tools.\""],
        guiltyTruths: ["The seller, later arrested, said {DL} told him \"bring me more, just no names next time.\""],
        innocentTruths: ["The seller, later arrested, said he picked {DL}'s shop because it paid fast and \"doesn't ask much,\" and that {DL} never knew."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["PAWN": ["Hollis Gold & Pawn", "Cash Corner Pawn", "Route 17 Pawn & Loan"]],
        story: StoryExtras(
            timeline: [(-9, "{VL}'s trailer broken into; tools stolen."),
                       (-7, "Seller pawns eleven tools at {PAWN}; {DL} reports them to the police database."),
                       (0, "{VL} finds the tools on the shelf and calls police."),
                       (5, "{DL} charged.")],
            howIdentified: "{VL} found the tools on display in {DL}'s shop.",
            notDone: ["The seller was never located.", "The police database report was never matched against the theft report."],
            defendantExam: [
                .direct("Why did you pay $340?", "\"Used tools don't move. I've got a wall of drills I can't sell for twenty bucks. I pay what I can sell them for.\""),
                .direct("Did you see the engraving?", "\"I did. I wrote it in the police report. People engrave their tools and then die, and their kids sell them.\""),
                .cross("The seller's address was a vacant lot.", "\"The ID was valid. I don't drive to people's houses.\""),
                .cross("Eleven tools from one company didn't make you call that company?", "\"In hindsight, it should have.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"Detective, your own department dropped the ball here, didn't it?\"",
                                  answer: "\"We could have caught it sooner.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: false,
                                  explanation: "Whether the police checked the database is relevant to the defense theory that the shop acted in good faith; the question is fair.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Seven cents on the dollar, a fake address, and a name engraved in the steel.",
            defenseOpening: "A shop owner who reported every detail to the police the same day.",
            prosecutionClosing: "Reasonable grounds to believe they were stolen is all the law requires.",
            defenseClosing: "Nobody who knows they're fencing tools sends the police a description.",
            victim: VictimFacts(restitution: 0)
        )
    )

    // MARK: - 61. The forged check (an estate, a sibling, and a signature)

    static let forgedCheck = CaseTemplate(
        key: "story.forgedCheck", category: .whiteCollar,
        headlines: ["Sibling Charged With Cashing Late Parent's $22,000 Check", "Estate Dispute Becomes Forgery Case"],
        primaryLaw: "uttering", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Knowingly passed a forged check for $22,000 drawn on the account of the late {PARENT}, with intent to defraud.",
        secondary: [
            SecondaryCharge(lawID: "forgery", specification: "Forged the signature of {PARENT} on a $22,000 check.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $22,000 from the estate of {PARENT} by presenting the forged check.", chance: 1.0, threshold: 4)
        ],
        ageRange: 40...60, occupations: ["real estate agent", "hair stylist"], hasVictim: true,
        summaries: [
            "Three days after {PARENT} died on {DATE}, {D} deposited a $22,000 check from {PARENT}'s account, made out to {DL} and dated the day before the death. {V}, {DL}'s sibling and executor of the estate, says their parent was in a coma by then and could not have signed anything. A State Bureau of Investigation document examiner says the signature is \"probably not genuine.\" {DL} says {PARENT} signed the check two weeks earlier as repayment for years of caregiving and told {D.him} to fill in the date later."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Hospital Records", "{PARENT} was unresponsive and on a ventilator from twelve days before death."),
            E(.forensic, 2, "Document Examiner", "The signature is \"probably not genuine\": slower line quality and different letter forms from known samples."),
            E(.document, 2, "Bank Deposit", "{DL} deposited the check by phone three days after the death and withdrew $18,000 within a week.")
        ],
        defenseEvidence: [
            E(.document, 2, "Caregiving Texts", "Two years of texts showing {DL} drove {PARENT} to appointments several times a week."),
            E(.document, 2, "Blank Date", "The ink in the date line is different from the ink in the signature, consistent with filling in the date later."),
            E(.statement, 1, "Neighbor's Account", "A neighbor heard {PARENT} say, about a month before the coma, \"I'm going to take care of {DL} for everything.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Executor and sibling",
                        direct: ["\"Our parent couldn't hold a pen.\""],
                        cross: ["\"{DL} did most of the caregiving.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("When did you find the check?", "\"Going through the account as executor. A twenty-two-thousand-dollar check dated the day before the death. {PARENT} had been on a ventilator for almost two weeks.\""),
                            .direct("Is that your parent's signature?", "\"It looks like someone trying to copy it.\""),
                            .cross("{DL} drove your parent to appointments for two years while you lived in Charlotte?", "\"{DL} lived ten minutes away. I came when I could.\""),
                            .cross("You'd receive half of that $22,000 under the will if it stays in the estate?", "\"Half, yes. I'd give it to charity to see this done right.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic document examiner, State Bureau of Investigation",
                        direct: ["\"Probably not genuine.\""],
                        cross: ["\"The ink in the date is different.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you conclude?", "\"That the signature is probably not genuine. The line quality is slow and hesitant, and three letter forms differ from twenty known samples.\""),
                            .direct("What does 'probably' mean on your scale?", "\"It's the second-strongest finding below 'identified.' I'm confident, not certain.\""),
                            .cross("Could an elderly, ill person's signature also be slow and hesitant?", "\"Yes. Illness and age can cause tremor.\""),
                            .cross("The date line is in a different ink than the signature?", "\"Yes, a different pen.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor",
                        direct: ["\"{PARENT} wanted to pay {DL} back.\""],
                        cross: ["\"I didn't see a check.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear?", "\"About a month before the coma, sitting on the porch, {PARENT} said, 'I'm going to take care of {DL} for everything. That child gave up two years.'\""),
                            .cross("You never saw a check signed?", "\"I wasn't in the room for any of that.\""),
                            .cross("'Take care of' could mean in the will?", "\"It could.\"")
                        ])
        ],
        prosecutionTheory: ["The check is dated while {PARENT} was on a ventilator, the signature is probably forged, and {DL} cashed it three days after the death."],
        defenseTheory: ["{PARENT} signed the check weeks earlier to repay two years of caregiving and left the date blank. The different ink shows exactly that. A shaky signature is what illness looks like."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant provided caregiving to the family member"],
        victimImpacts: ["{V}: \"Our parent's last wishes were in the will. This made us strangers at the funeral.\""],
        allocutions: ["\"I never forged anything. I took care of our parent when nobody else would.\""],
        guiltyTruths: ["A practice sheet with repeated signatures of {PARENT} was later found in {DL}'s desk."],
        innocentTruths: ["A bank teller later remembered {PARENT} asking, weeks before the coma, how to write a check \"for a big gift.\""],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["PARENT": ["Loretta Haines", "Walter Pruitt", "Gladys Merriweather"]],
        story: StoryExtras(
            timeline: [(-30, "Neighbor hears {PARENT} talk about 'taking care of' {DL}."),
                       (-12, "{PARENT} on a ventilator, unresponsive."),
                       (0, "{PARENT} dies."),
                       (3, "{DL} deposits the $22,000 check by phone."),
                       (40, "Executor {VL} discovers the check and reports it."),
                       (90, "Document examiner's report; {DL} charged.")],
            howIdentified: "The executor's review of the estate account.",
            notDone: ["The bank's teller and branch staff were never interviewed."],
            defendantExam: [
                .direct("When did your parent sign the check?", "\"About two weeks before the coma, at the kitchen table. {PARENT} said, 'Fill in the date when you need it. I don't want your sibling fighting you on it.'\""),
                .direct("Why did you deposit it after the death?", "\"Because I couldn't afford the funeral deposit and the bank told me the account would freeze.\""),
                .cross("You dated it the day before the death.", "\"I didn't know what date to put. I was grieving and stupid.\""),
                .cross("You withdrew $18,000 in a week.", "\"Funeral, back rent, and the car I wore out driving to the hospital.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Was {DL} always the one who wanted money from your parent?\"",
                                  answer: "\"Always. Since we were kids.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character evidence", shouldSustain: true,
                                  explanation: "A general claim that the defendant is greedy is character evidence offered to prove conduct, barred by Rule 404(a).",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "A check dated while the signer was on a ventilator.",
            defenseOpening: "A parent's thank-you, signed early and dated late.",
            prosecutionClosing: "The dead can't sign checks, and {PARENT} couldn't sign this one.",
            defenseClosing: "Probably isn't beyond a reasonable doubt.",
            victim: VictimFacts(relationship: "The defendant's sibling and the executor of their parent's estate.", harm: ["No physical injury."], restitution: 22000, restitutionBasis: "the $22,000 taken from their parent's estate")
        )
    )

    // MARK: - 62. The unsecured gun (a child, a nightstand, and a parent's grief)

    static let unsecuredGun = CaseTemplate(
        key: "story.unsecuredGun", category: .violent,
        headlines: ["Child, 6, Dies After Finding Gun in Nightstand", "Parent Charged After Accidental Shooting of Cousin"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Unintentionally killed {V}, age 6, by culpable negligence in leaving a loaded handgun unsecured where children were present.",
        secondary: [SecondaryCharge(lawID: "firearmStorage", specification: "Stored a loaded firearm in a manner that a minor could gain access to it, and a minor did gain access.", chance: 1.0, threshold: 0)],
        ageRange: 28...42, occupations: ["sales manager", "welder"], hasVictim: true,
        summaries: [
            "On {DATE}, during a birthday party at {D}'s house on {STREET} in {HOOD}, {D}'s eight-year-old found a loaded 9mm handgun in an unlocked nightstand drawer in the main bedroom. While showing it to cousins, the child fired once, killing {V}, 6. {DL} kept the gun loaded with a round in the chamber for home protection, had a lockbox in the closet that was not used, and had told family the drawer was \"off limits.\" {DL} says the bedroom door was closed and the children had been told to stay in the yard."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Handgun", "A loaded 9mm with a round chambered and no external safety, found on the bedroom floor."),
            E(.physical, 2, "Unused Lockbox", "A biometric lockbox, still in its box in the bedroom closet, bought fourteen months earlier."),
            E(.statement, 2, "Statement", "{DL} told officers: \"I always keep it in the drawer. The kids know not to go in there.\"", .statement)
        ],
        defenseEvidence: [
            E(.statement, 2, "Closed Door", "Two adults at the party say the bedroom door was closed and the children had been told to stay outside."),
            E(.document, 2, "Gun Safety Course", "A certificate showing {DL} completed a firearms safety course three years earlier."),
            E(.document, 1, "No Prior Incidents", "No prior reports involving the children and the gun.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"A loaded gun in an unlocked drawer, with a lockbox in the closet.\""],
                        cross: ["\"The door was closed.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where was the gun kept?", "\"In the top nightstand drawer, unlocked, loaded with a round in the chamber. Twelve children were at the party.\""),
                            .direct("What did you find in the closet?", "\"A biometric gun safe, still in the shipping box, bought over a year earlier.\""),
                            .cross("The bedroom door was closed and children were told to stay out?", "\"That's what the adults said.\""),
                            .cross("North Carolina doesn't require a gun to be locked if no child can reasonably access it?", "\"Correct. The question is whether a child could.\"")
                        ]),
            WitnessSeed(name: nil, role: "{VL}'s parent",
                        direct: ["\"I trusted my sibling's house.\""],
                        cross: ["\"I didn't know about the gun.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened at the party?", "\"The kids were in the yard. I went to get the cake from the car. I heard one pop and screaming from inside.\""),
                            .direct("Did you know about the gun?", "\"I knew {DL} had one. I didn't know where. I would never have let my child in that house.\""),
                            .cross("You'd been to that house many times with your child?", "\"Every holiday.\""),
                            .cross("You've told people you don't want {DL} to go to prison?", "\"I don't know what I want. I want my baby back.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Family friend at the party",
                        direct: ["\"The kids were told to stay outside.\""],
                        cross: ["\"Kids don't always listen.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Were the children told to stay out of the house?", "\"Twice. {DL} said bathrooms only, stay in the yard. The bedroom door was shut.\""),
                            .direct("How is {DL} doing?", "\"{D.He} hasn't slept in the bedroom since. {D.He} sold the gun the next week.\""),
                            .cross("Children at a birthday party don't always listen?", "\"Not at that age. You tell them twice and then you watch.\""),
                            .cross("Was the bedroom door locked?", "\"Just closed.\"")
                        ])
        ],
        prosecutionTheory: ["A loaded, chambered handgun in an unlocked drawer, a party with twelve children, and a lockbox never taken out of its box. That's culpable negligence."],
        defenseTheory: ["{DL} kept the gun in a closed room, told every child to stay outside, and never imagined {D.his} child would go in. This is a tragedy, not a crime."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has accepted responsibility", "The defendant's family suffered the same loss"],
        victimImpacts: ["{VL}'s parent: \"Every birthday party, every family dinner, there's an empty chair, and the gun belonged to my own sibling.\""],
        allocutions: ["\"I bought that lockbox and never opened it. There's nothing a court can do to me that's worse than that.\""],
        guiltyTruths: ["A relative later told police the children had found the gun in that drawer once before and {DL} had laughed it off."],
        innocentTruths: ["{DL}'s child later said an older cousin had gone into the bedroom to find a phone charger and saw the drawer open."],
        moods: [.sympathetic], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-420, "Biometric lockbox delivered to {DL}'s house."),
                       (0, "4:15 p.m.: shot fired during the party; {VL} pronounced dead at the hospital."),
                       (0, "{DL} interviewed at the house."),
                       (2, "Autopsy confirms a single gunshot wound."),
                       (21, "{DL} charged.")],
            howIdentified: "{DL} owned the gun and the house.",
            notDone: [],
            defendantExam: [
                .direct("Why was the gun in the drawer?", "\"So I could reach it at night. I'd had a break-in two years before. I told myself the kids knew.\""),
                .direct("Why wasn't it in the lockbox?", "\"I kept meaning to set it up. It needed a fingerprint program and I never sat down to do it.\""),
                .cross("Twelve children were in your home and the gun was loaded and chambered.", "\"Loaded, chambered, in the nightstand. With twelve kids in the house.\""),
                .cross("You'd have known your child was curious about it.", "\"I thought I'd taught my child better. I was wrong.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"You'd agree your sibling is a good parent, wouldn't you?\"",
                                  answer: "\"Before this, yes.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper character evidence", shouldSustain: false,
                                  explanation: "The defense may elicit testimony about a pertinent trait, such as care for children, under Rule 404(a)(1).",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "A chambered gun, an unlocked drawer, a dozen children, and a safe still in its box.",
            defenseOpening: "A closed door, clear instructions, and a family that lost a child.",
            prosecutionClosing: "Culpable negligence is ignoring a danger anyone could see.",
            defenseClosing: "{DL} made a terrible mistake, not a crime.",
            victim: VictimFacts(relationship: "A child at the defendant's birthday party; a cousin of the defendant's child."),
            residence: "Owns a house on {STREET} in {HOOD}."
        )
    )

    // MARK: - 63. The fake accounts (harassing an ex's new partner)

    static let fakeAccounts = CaseTemplate(
        key: "story.fakeAccounts", category: .cyber,
        headlines: ["Woman Says Fake Accounts Harassed Her for Months", "Cyberstalking Charge Rests on IP Addresses and a Typo"],
        primaryLaw: "cyberstalking", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Repeatedly sent electronic messages to {V} for the purpose of abusing, annoying, threatening, or harassing {V.him}.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Created a second set of accounts to send messages to {V} after being blocked.", chance: 1.0, threshold: 4)
        ],
        ageRange: 24...40, occupations: ["physical therapist", "retail manager"], hasVictim: true,
        summaries: [
            "For four months beginning on {DATE}, {V} received more than 200 messages from nine different social media accounts calling {V.him} names, mocking {V.his} weight, and saying {V.his} new partner \"will leave you like he left me.\" The new partner is {D}'s ex. Four of the accounts were created from an IP address at {D}'s gym; two used an email recovery address with {DL}'s initials. Many messages misspelled \"definitely\" as \"definately,\" which {DL} also does in texts. {DL} says {D.he} has never contacted {VL}, that hundreds of people use that gym's Wi-Fi, and that half the internet can't spell \"definitely.\" {DL} was convicted in district court and appealed."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Account Records", "Four of the nine accounts were created from the IP address of {GYM}, where {DL} trains clients; three at times {DL} was on the schedule."),
            E(.digital, 2, "Recovery Email", "Two accounts listed a recovery email beginning with {DL}'s initials and birth year."),
            E(.digital, 1, "Spelling", "\"Definately\" appears in 37 of the messages and in 14 of {DL}'s texts to the ex.")
        ],
        defenseEvidence: [
            E(.document, 2, "Gym Traffic", "{GYM} has about 600 members and an open guest Wi-Fi network."),
            E(.document, 2, "Initials", "The recovery email used initials and a birth year shared by at least one other member of {GYM}."),
            E(.document, 1, "Schedule Gaps", "Two accounts were created at times {DL} was not on the schedule.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Target of the messages",
                        direct: ["\"It was relentless.\""],
                        cross: ["\"I never saw {DL} send anything.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did the messages say?", "\"That I was fat, that I was a placeholder, that he'd leave me 'like he left me.' Two hundred of them. Every time I blocked one, a new account popped up.\""),
                            .direct("How did it affect you?", "\"I deleted my accounts. I stopped going to the grocery store near my house because one message mentioned it.\""),
                            .cross("You've never had any contact with {DL}?", "\"I've seen {D.him} once, across a parking lot.\""),
                            .cross("You don't know who wrote the messages?", "\"I know who they're about. Only one person talks about being left.\"")
                        ]),
            WitnessSeed(name: nil, role: "Police digital investigator",
                        direct: ["\"Four accounts came from {DL}'s gym.\""],
                        cross: ["\"The Wi-Fi was open.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the account records show?", "\"Four of the nine were created on {GYM}'s network, three during {DL}'s scheduled hours. Two used a recovery email with {DL}'s initials and birth year.\""),
                            .direct("Did you compare the language?", "\"The same misspelling of 'definitely' in 37 messages and in {DL}'s texts to the ex.\""),
                            .cross("The gym Wi-Fi was open to anyone?", "\"No password. Anybody in the parking lot could get on.\""),
                            .cross("Another member has the same initials and birth year?", "\"One that I know of.\""),
                            .cross("You didn't get a warrant for {DL}'s phone?", "\"It was denied as overbroad.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{GYM} manager",
                        direct: ["\"Hundreds of people use our Wi-Fi.\""],
                        cross: ["\"{DL} is there most days.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Who uses the gym's Wi-Fi?", "\"Members, guests, delivery drivers, people in the parking lot. It's not password protected.\""),
                            .cross("{DL} is there most days?", "\"{D.He} trains clients six days a week.\""),
                            .cross("Did you know the other member with those initials?", "\"A little. Quiet person.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s gym, {D.his} initials, {D.his} spelling, and only one person with a reason to say 'he'll leave you like he left me.'"],
        defenseTheory: ["An open network used by hundreds, initials shared by another member, accounts made when {DL} wasn't there, and a common misspelling. That's a theory, not proof."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"I still flinch when my phone buzzes.\""],
        allocutions: ["\"I was hurt when the relationship ended. I didn't spend four months harassing anybody.\""],
        guiltyTruths: ["A later warrant for {DL}'s cloud backup found screenshots of {VL}'s profile saved the night each new account was created."],
        innocentTruths: ["The other member with the same initials was later found to have dated the same ex years earlier."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["GYM": ["Iron Harbor Fitness", "Coastal CrossFit", "Pell Avenue Athletic Club"]],
        story: StoryExtras(
            timeline: [(0, "First message from an anonymous account."),
                       (45, "{VL} reports the messages to police."),
                       (70, "Platform records returned under court order."),
                       (90, "Warrant for {DL}'s phone denied as overbroad."),
                       (120, "{DL} charged.")],
            howIdentified: "Account creation records traced to {GYM}'s network and a recovery email with {DL}'s initials.",
            notDone: ["The other member with matching initials was never interviewed."],
            defendantExam: [
                .direct("Did you create those accounts?", "\"No. I've never sent {VL} a single message.\""),
                .direct("What about the misspelling?", "\"I misspell it. So do my clients, my mother, and half the comments on any post.\""),
                .cross("Two accounts used your initials and birth year.", "\"And someone else's. I don't have an email like that.\""),
                .cross("'He'll leave you like he left me.' Who else would say that?", "\"Anyone he's ever dated.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"You'd like {DL} convicted so the messages stop?\"",
                                  answer: "\"I'd like the messages to stop.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: false,
                                  explanation: "Exploring the witness's interest in the outcome is proper cross-examination for bias.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Two hundred messages, nine accounts, and a trail back to one person's gym and initials.",
            defenseOpening: "An open network, a shared set of initials, and a common typo.",
            prosecutionClosing: "Each piece alone could be coincidence. Together they're {DL}.",
            defenseClosing: "Coincidences stacked up are still coincidences.",
            genders: ["V": .female],
            victim: VictimFacts(relationship: "No relationship; she is dating the defendant's ex.", restitution: 1800, restitutionBasis: "counseling costs")
        )
    )
}
