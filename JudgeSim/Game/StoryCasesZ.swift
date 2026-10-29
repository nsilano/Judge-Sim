import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchZ: [CaseTemplate] = [nightPharmacy, horseStarvation, groceryFall, gasStationKidnapping, beachHouse]

    // MARK: - 139. The night pharmacy (a break-in for pills)

    static let nightPharmacy = CaseTemplate(
        key: "story.nightPharmacy", category: .property,
        headlines: ["Pharmacy Burglarized Overnight; Oxycodone Taken", "Shoe Print and Glove Lead to Arrest in Pharmacy Break-In"],
        primaryLaw: "feloniousBE", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Broke and entered {PHARM}, a building in {HOOD}, with the intent to commit larceny therein.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole oxycodone and hydrocodone tablets and $340 in cash from {PHARM}, taken pursuant to a breaking or entering.", chance: 1.0, threshold: 0)
        ],
        ageRange: 22...40, occupations: ["roofer"], forcedPriorOffenses: ["Breaking or Entering@5"], hasVictim: true,
        summaries: [
            "At 3:20 a.m. on {DATE}, the alarm at {PHARM} in {HOOD} went off. Deputies found the back door pried open and the Schedule II safe emptied of about 900 oxycodone and hydrocodone tablets. A latex glove dropped by the door held DNA matching {D}, whose profile was in the state database from a prior conviction. A muddy shoe print on the counter matched the tread of work boots seized from {DL}'s truck. {V}, the pharmacist-owner, says the safe's code was known only to staff, but the safe had been left unlocked that night. {DL}, who had roofed the pharmacy three months earlier, says the glove must have been left during that job."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Glove DNA", "A latex glove by the pried door; the DNA inside matches {DL}.", .search),
            E(.forensic, 2, "Boot Print", "A muddy print on the counter consistent in tread and size with work boots seized from {DL}'s truck.", .search),
            E(.video, 2, "Interior Camera", "A hooded figure in gloves at the safe at 3:18 a.m.; face not visible.")
        ],
        defenseEvidence: [
            E(.document, 2, "Roofing Invoice", "An invoice showing {DL}'s crew roofed the pharmacy three months before, including work near the back door."),
            E(.statement, 1, "Common Boots", "The boot model is sold at every farm store in the county.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Pharmacist and owner",
                        direct: ["\"The back door was pried and the safe was empty.\""],
                        cross: ["\"The roofers did work around back.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Who knew the code to the safe?", "\"Only my staff.\""),
                            .direct("What did you find that morning?", "\"The back door frame splintered, the safe open, and every Schedule II tablet gone. About nine hundred.\""),
                            .direct("Was anything else taken?", "\"$340 in cash.\""),
                            .cross("The safe had been left unlocked that night?", "\"Yes, it had.\""),
                            .cross("{DL}'s crew worked near that door?", "\"Three months ago. We sweep and mop that hallway every night.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic biologist, State Crime Laboratory",
                        direct: ["\"The DNA inside the glove is {DL}'s.\""],
                        cross: ["\"DNA can't tell you when it was deposited.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you examine?", "\"A latex glove collected by the pried back door.\""),
                            .direct("What did you find?", "\"A single-source profile from the inside of the glove's fingers, matching {DL}.\""),
                            .direct("How was the profile identified?", "\"It was searched against the state DNA database, and it matched {DL}.\""),
                            .cross("You can't say when the glove was worn?", "\"No. DNA doesn't carry a date.\""),
                            .cross("DNA on a glove can last for months?", "\"It can, yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Roofing crew member",
                        direct: ["\"We all wore those gloves on that job.\""],
                        cross: ["\"I don't remember anyone leaving one inside.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Did you work on the pharmacy roof with {DL}?", "\"Yes, about three months before the break-in.\""),
                            .direct("Did that job include work near the back door?", "\"Yes. We were around back a lot.\""),
                            .direct("What gloves did the crew use?", "\"Boxes of latex gloves for the sealant. We tossed them everywhere.\""),
                            .cross("Did anyone leave gloves inside the building?", "\"I don't recall anybody taking gloves in.\""),
                            .cross("So you can't explain how {DL}'s glove ended up inside the pried door?", "\"No, I can't.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s DNA in a glove dropped at the pried door, and {D.his} boot print on the counter."],
        defenseTheory: ["{DL} worked at that building three months earlier. A glove from that job and a common boot tread don't prove a burglary."],
        aggravating: [],
        mitigating: ["The defendant has a substance use disorder and has sought treatment"],
        victimImpacts: ["{V}: \"My patients waited a week for pain medication while we replaced the stock.\""],
        allocutions: ["\"I've been sick on pills since I fell off a roof. That's not an excuse.\""],
        guiltyTruths: ["{DL} sold oxycodone tablets with the pharmacy's lot number to an informant the next day."],
        innocentTruths: ["Another member of the roofing crew was later caught with the stolen tablets and the pry bar."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["PHARM": ["Riverside Drug", "Main Street Pharmacy", "Coastal Family Pharmacy"]],
        story: StoryExtras(
            timeline: [(-90, "{DL}'s crew roofs the pharmacy."), (0, "3:18 a.m.: figure at the safe."), (0, "3:20 a.m.: alarm."), (28, "DNA database hit."), (31, "Boots seized from {DL}'s truck; {DL} charged.")],
            howIdentified: "A DNA database match from the glove.",
            notDone: ["Other members of the roofing crew were not swabbed."],
            defendantExam: [
                .direct("Were you in the pharmacy that night?", "\"No. I was home asleep.\""),
                .cross("Your glove was inside the pried door.", "\"I wore a hundred gloves on that job.\""),
                .cross("Your boot print was on the counter.", "\"Everybody in the county has those boots.\"")
            ],
            prosecutionOpening: "A glove with {DL}'s DNA, dropped at the door that was pried open.",
            defenseOpening: "A roofer's glove from a roofing job.",
            prosecutionClosing: "The floor is mopped every night. That glove was dropped the night of the burglary.",
            defenseClosing: "DNA tells you whose glove it is, not when it got there.",
            victim: VictimFacts(occupation: "Pharmacist and owner of the pharmacy", relationship: "The defendant had roofed her pharmacy three months earlier.", restitution: 6800, restitutionBasis: "the stolen medication and the damaged back door"),
            employer: "self-employed (roofing crew)"
        )
    )

    // MARK: - 140. The pasture (horses left to starve)

    static let horseStarvation = CaseTemplate(
        key: "story.horseStarvation", category: .publicOrder,
        headlines: ["Three Horses Found Starving in Muddy Pasture", "Owner Charged With Animal Cruelty After Neighbor's Photos"],
        primaryLaw: "animalCruelty", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Intentionally deprived three horses of necessary sustenance, causing unjustifiable pain and suffering.",
        secondary: [],
        ageRange: 40...70, occupations: ["horse boarder", "retired horse trainer", "contractor"], hasVictim: false,
        summaries: [
            "A neighbor photographed three horses on {D}'s property outside {HOOD} for six weeks as they grew thinner, standing in a muddy pasture with no hay and a dry water trough. On {DATE}, animal control seized them. A veterinarian scored all three a 1 on the 9-point body condition scale, the lowest possible; one had to be euthanized. {DL} says {D.he} was in the hospital for three weeks of that time, that {D.he} paid a farmhand to feed them, and that the farmhand quit without telling {D.him}."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Veterinary Report", "Body condition scores of 1 of 9 for all three horses; severe muscle wasting; one euthanized."),
            E(.document, 3, "Neighbor's Photos", "Dated photos over six weeks showing the horses' ribs and hip bones growing more visible, an empty hay rack, and a dry trough."),
            E(.statement, 2, "Feed Store Records", "{DL}'s last hay purchase was nine weeks before the seizure.")
        ],
        defenseEvidence: [
            E(.document, 2, "Hospital Records", "{DL} was hospitalized for 22 days within the six-week period."),
            E(.statement, 1, "Farmhand Payment", "A $400 check from {DL} to a farmhand, dated before the hospital stay.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Equine veterinarian",
                        direct: ["\"This takes months, not weeks.\""],
                        cross: ["\"A hospital stay could interrupt care.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What condition were the horses in?", "\"All three scored a 1 on the 9-point body condition scale, the lowest possible, with severe muscle wasting.\""),
                            .direct("Did all three survive?", "\"No. One had to be euthanized.\""),
                            .direct("How long does it take a horse to reach a score of 1?", "\"From a normal 5, two to three months of inadequate feed. This didn't happen in three weeks.\""),
                            .cross("A hospital stay could interrupt care?", "\"For three weeks. Not for three months.\""),
                            .cross("You can't say who was supposed to be feeding them day to day?", "\"No. I can say they weren't being fed.\"")
                        ]),
            WitnessSeed(name: nil, role: "Neighbor who took the photos",
                        direct: ["\"I watched them get thinner every week.\""],
                        cross: ["\"I never saw a farmhand out there.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How long did you photograph the horses?", "\"Six weeks.\""),
                            .direct("What did you see?", "\"Horses standing in mud, no hay, the trough dry. I took pictures every Sunday.\""),
                            .direct("What changed over those weeks?", "\"You could see more of their ribs and hip bones every week.\""),
                            .cross("You weren't watching that pasture every day?", "\"No. But I never saw a farmhand out there.\""),
                            .cross("You never called {DL}?", "\"I didn't have the number. I called animal control twice.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s physician",
                        direct: ["\"{DL} was in the hospital twenty-two days.\""],
                        cross: ["\"{D.He} was home before and after.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Did you treat {DL} during that hospital stay?", "\"Yes, I did.\""),
                            .direct("Why was {DL} hospitalized?", "\"A serious infection after surgery. Twenty-two days, including a week in intensive care.\""),
                            .direct("Could {DL} have cared for animals during those twenty-two days?", "\"No. {D.He} couldn't leave the hospital.\""),
                            .cross("{DL} was home for the rest of the six weeks?", "\"Yes, recovering, but able to get around.\""),
                            .cross("You know nothing about how the horses were fed, do you?", "\"No. I only know about my patient.\"")
                        ])
        ],
        prosecutionTheory: ["The horses starved over months, not just the weeks {DL} was hospitalized, and the last hay bought was nine weeks earlier."],
        defenseTheory: ["{DL} was in intensive care and paid someone to feed the horses. A farmhand's broken promise isn't {D.his} intentional cruelty."],
        aggravating: [],
        mitigating: ["The defendant was seriously ill during the period", "No prior criminal record"],
        allocutions: ["\"I've loved horses my whole life. I trusted the wrong person while I was sick.\""],
        guiltyTruths: ["The farmhand produced texts in which {DL} told him to stop feeding the horses because {D.he} planned to sell them for slaughter."],
        innocentTruths: ["The farmhand later admitted he cashed the check and never went to the property."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-63, "Last hay purchase."), (-42, "Neighbor's first photos."), (-30, "{DL} hospitalized for 22 days."), (0, "Animal control seizes the horses."), (2, "One horse euthanized.")],
            howIdentified: "{DL} owns the property and the horses.",
            notDone: ["The farmhand was not located before charging."],
            defendantExam: [
                .direct("Who was feeding the horses?", "\"I paid a farmhand $400 to feed them while I was in the hospital.\""),
                .cross("You were home three weeks before the hospital. The last hay was bought before that.", "\"I had some hay in the barn.\""),
                .cross("The hay rack was empty in every photo.", "\"I can't explain the photos.\"")
            ],
            prosecutionOpening: "Months of hunger, documented every Sunday.",
            defenseOpening: "A sick owner and a farmhand who took the money and left.",
            prosecutionClosing: "The hospital explains three weeks. It doesn't explain nine.",
            defenseClosing: "Intent is an element. Being in intensive care isn't intent.",
            residence: "Lives on the property outside {HOOD} where the horses were kept."
        )
    )

    // MARK: - 141. Aisle seven (a staged fall at a grocery store)

    static let groceryFall = CaseTemplate(
        key: "story.groceryFall", category: .whiteCollar,
        headlines: ["Grocery Store Fall Claim Was Staged, Insurer Says", "Camera Shows Shopper Pouring Oil Before Slip"],
        primaryLaw: "insuranceFraud", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Presented a claim to {INSURER} for $85,000 knowing it contained false information that {D.he} was injured in an accidental fall at {GROCER}.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained a $6,500 advance settlement payment from {INSURER} by falsely representing that {D.his} fall was accidental.", chance: 1.0, threshold: 0)
        ],
        ageRange: 30...55, occupations: ["unemployed", "rideshare driver", "home health aide"], hasVictim: false,
        summaries: [
            "On {DATE}, {D} fell in aisle seven at {GROCER} in {HOOD} and was taken to the emergency room complaining of back pain. {DL}'s lawyer sent a demand for $85,000, and the store's insurer paid a $6,500 advance for medical bills. The insurer's investigator then reviewed the store camera: thirty seconds before the fall, a person in {DL}'s clothing takes a bottle of cooking oil from the shelf, pours some on the floor, and puts the bottle back. The investigator also found two earlier fall claims by {DL} at other stores. {DL} says the camera angle is misleading, that {D.he} was reaching for the bottle when it leaked, and that {D.his} back injury is real."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Store Camera", "A shopper in {DL}'s clothing pours cooking oil on the floor, returns the bottle, walks to the end of the aisle, and comes back to fall in the spill thirty seconds later."),
            E(.document, 2, "Prior Claims", "Two earlier fall claims by {DL} at other stores in three years, both settled.", .search),
            E(.document, 2, "Claim Demand", "A demand for $85,000 describing \"an unseen hazard\" in aisle seven.")
        ],
        defenseEvidence: [
            E(.document, 2, "MRI", "An MRI showing a herniated disc in {DL}'s lower back."),
            E(.physical, 1, "Bottle Cap", "The oil bottle's cap was cracked when the store pulled it from the shelf.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Insurance fraud investigator",
                        direct: ["\"Pour, wait, walk back, fall.\""],
                        cross: ["\"The camera is thirty feet away.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you review?", "\"The $85,000 demand, the claim file, and the store camera from aisle seven.\""),
                            .direct("What does the video show?", "\"The shopper tilts the bottle over the floor for about four seconds, caps it, puts it back, walks to the end of the aisle, and comes back to fall in that exact spot.\""),
                            .direct("Had {DL} made fall claims before?", "\"Yes. Two earlier fall claims at other stores in three years, both settled.\""),
                            .cross("The camera is thirty feet away and the angle is high?", "\"Yes. You can still see the oil hit the floor.\""),
                            .cross("The video can't show whether the bottle was leaking on its own?", "\"It shows the bottle held over the floor for four seconds.\"")
                        ]),
            WitnessSeed(name: nil, role: "Store manager",
                        direct: ["\"The cap was put back on.\""],
                        cross: ["\"I can't say the bottle wasn't cracked before.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where did this happen?", "\"Aisle seven, in my store.\""),
                            .direct("What did you find in the aisle?", "\"A puddle of oil and the bottle back on the shelf with its cap on.\""),
                            .direct("What did you do with the bottle?", "\"Pulled it off the shelf and kept it.\""),
                            .cross("The cap was cracked?", "\"A little. I can't say when that happened.\""),
                            .cross("You didn't see how the oil got on the floor?", "\"No. I only saw it afterward.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Orthopedic surgeon",
                        direct: ["\"The herniated disc is real.\""],
                        cross: ["\"I can't say it came from this fall.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Did you review {DL}'s MRI?", "\"Yes, I did.\""),
                            .direct("What did the MRI show?", "\"A herniated lumbar disc consistent with the pain {DL} reports.\""),
                            .direct("Is that kind of injury painful?", "\"Yes. It can be very painful.\""),
                            .cross("Could the herniation predate this fall?", "\"It could. The MRI can't date it.\""),
                            .cross("Nothing in the MRI tells us how the oil got on the floor?", "\"No. That's not something an MRI can show.\"")
                        ])
        ],
        prosecutionTheory: ["{D} poured the oil, waited, and fell in it, for the third time in three years."],
        defenseTheory: ["A leaking bottle and a real injury. A grainy high-angle video doesn't show an intent to deceive."],
        aggravating: [],
        mitigating: ["The defendant has a documented back injury"],
        allocutions: ["\"My back really hurts. I was behind on everything.\""],
        guiltyTruths: ["{DL}'s phone held a note listing stores with \"no cameras in back aisles,\" with two crossed off."],
        innocentTruths: ["The bottle's manufacturer recalled that lot the next month for cracked caps that leaked when tipped."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["INSURER": ["Carolina Mutual Insurance", "Coastal Casualty Company"], "GROCER": ["Food Lion", "Harris Teeter", "Piggly Wiggly"]],
        story: StoryExtras(
            timeline: [(-900, "First earlier fall claim."), (-400, "Second earlier fall claim."), (0, "Fall in aisle seven."), (20, "$85,000 demand; $6,500 advance paid."), (60, "Video reviewed; claim referred to the Department of Insurance.")],
            howIdentified: "The claimant.",
            notDone: ["The cracked cap was not examined by a lab."],
            defendantExam: [
                .direct("Did you pour oil on the floor?", "\"No. I picked up the bottle and it leaked on my hand and the floor. I put it back.\""),
                .cross("Then you walked away and came back to that exact spot.", "\"I forgot something at the end of the aisle.\""),
                .cross("This is your third fall claim in three years.", "\"I have bad luck and a bad back.\"")
            ],
            prosecutionOpening: "Pour, wait, walk back, fall.",
            defenseOpening: "A leaky bottle and a bad back.",
            prosecutionClosing: "People who slip don't come back to the spill on purpose.",
            defenseClosing: "Video from thirty feet up can't show what's in someone's mind."
        )
    )

    // MARK: - 142. Pump four (an ex-partner forced into a car)

    static let gasStationKidnapping = CaseTemplate(
        key: "story.gasStationKidnapping", category: .robbery,
        headlines: ["Woman Forced Into Car at Gas Station, Found Hours Later", "Ex-Boyfriend Charged With Kidnapping"],
        primaryLaw: "kidnapping1", lesserLaw: "kidnapping2", threshold: 8, lesserThreshold: 6,
        specification: "Unlawfully confined, restrained, and removed {V} from one place to another without consent for the purpose of terrorizing {V.him}, and did not release {V.him} in a safe place.",
        secondary: [
            SecondaryCharge(lawID: "assaultFemale", specification: "Assaulted {V}, a female, by striking her in the face.", chance: 1.0, threshold: 0)
        ],
        ageRange: 24...42, occupations: ["forklift operator", "mechanic", "unemployed"], hasVictim: true,
        summaries: [
            "At 9:40 p.m. on {DATE}, a gas station camera on {STREET} in {HOOD} recorded {D} grabbing {V}, {D.his} ex-girlfriend, by the arm at pump four and pushing her into the passenger seat of his car. Four hours later {V} was found by a deputy walking along a dark rural road twelve miles away, with a swollen eye and no phone. She says {DL} drove her around, screaming that she had ruined his life, hit her once, and left her on the road. {DL} says {V} got in willingly to talk, that they argued, and that she asked to be let out."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Gas Station Camera", "{DL} gripping {VL}'s arm and pushing her into the passenger seat; {VL} pulling back.", .search),
            E(.document, 2, "Medical Records", "A swollen left eye and orbital bruising."),
            E(.digital, 2, "Phone Location", "{DL}'s phone moving through rural roads for four hours, stopping twelve miles out at 1:35 a.m.", .search)
        ],
        defenseEvidence: [
            E(.digital, 2, "Messages", "Texts from {VL} to {DL} two days earlier: \"We need to talk in person.\""),
            E(.statement, 1, "Clerk's Account", "The clerk didn't see a struggle and didn't call 911.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Former girlfriend",
                        direct: ["\"He pushed me in and locked the door.\""],
                        cross: ["\"I did text him that we should talk.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How did you get into the car?", "\"He grabbed my arm and pushed me in. When I reached for the handle he hit the locks and drove.\""),
                            .direct("What happened while he drove?", "\"He drove me around for hours, screaming that I'd ruined his life. He hit me once in the face.\""),
                            .direct("Where did he leave you?", "\"On a dirt road. No lights, no phone. He threw my phone out the window an hour earlier.\""),
                            .cross("Two days before, you texted that you needed to talk in person?", "\"About getting my things back. Not in a car at night.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "Patrol deputy",
                        direct: ["\"She was walking in the dark with a swollen eye.\""],
                        cross: ["\"She didn't have her phone, so she couldn't call.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you find {VL}?", "\"Walking on the shoulder of a dirt road at 1:50 in the morning, crying, eye swelling shut.\""),
                            .direct("How far was that from the gas station?", "\"About twelve miles.\""),
                            .direct("Did she have a phone with her?", "\"No.\""),
                            .cross("She didn't call anyone during the four hours?", "\"Her phone was gone. We found it later in a ditch on the route.\""),
                            .cross("You didn't see how {VL} got to that road?", "\"No. I found her walking.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Gas station clerk",
                        direct: ["\"I didn't see a fight.\""],
                        cross: ["\"I was ringing up a customer.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where were you that night?", "\"Behind the register at the station.\""),
                            .direct("Did you see anything at pump four?", "\"A couple talking by a car. I didn't see a fight.\""),
                            .direct("Did you call 911?", "\"No. Nothing looked wrong to me.\""),
                            .cross("You were ringing up customers the whole time?", "\"Mostly, yes.\""),
                            .cross("So you can't say whether she was pulling away from him?", "\"No, I can't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} forced {V} into his car, held her for four hours to terrify her, hit her, threw away her phone, and left her on a dark road."],
        defenseTheory: ["{VL} asked to talk, got in, and they argued. Letting someone out when they ask is not kidnapping."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"I can't pump gas at night anymore. I can't be in a car with the doors locked.\""],
        allocutions: ["\"I just wanted her to listen. I never meant for it to go that far.\""],
        guiltyTruths: ["{DL} texted a friend at 11 p.m.: \"Got her. She's not going anywhere till she hears me.\""],
        innocentTruths: ["A second camera at the station shows {VL} walking to the car and opening the door herself before the arm-grab seen on the first."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-2, "{VL} texts {DL}: \"We need to talk in person.\""), (0, "9:40 p.m.: pump four."), (0, "10:45 p.m.: {VL}'s phone thrown from the car."), (1, "1:35 a.m.: {VL} left on a dirt road."), (1, "1:50 a.m.: deputy finds {VL}.")],
            howIdentified: "{VL} named {DL}; the camera confirmed it.",
            notDone: ["The station's second camera was not pulled."],
            defendantExam: [
                .direct("Did you force {VL} into the car?", "\"No. I held her arm to help her in. She wanted to talk.\""),
                .cross("You locked the doors and drove for four hours.", "\"We were talking.\""),
                .cross("You left her on a dirt road with no phone.", "\"She asked to get out.\"")
            ],
            prosecutionOpening: "Pump four, a locked door, four hours, and a dirt road at two in the morning.",
            defenseOpening: "A conversation she asked for, that ended badly.",
            prosecutionClosing: "Leaving a woman on a dark road with no phone is not releasing her in a safe place.",
            defenseClosing: "Her own text asked for this talk.",
            genders: ["D": .male, "V": .female]
        )
    )

    // MARK: - 143. The beach house (a vacation rental burglarized)

    static let beachHouse = CaseTemplate(
        key: "story.beachHouse", category: .property,
        headlines: ["Vacation Rental Burglarized; Owner's Doorbell Camera Catches Entry", "Cleaning Contractor Charged in Beach House Break-In"],
        primaryLaw: "burglary2", lesserLaw: "feloniousBE", threshold: 8, lesserThreshold: 6,
        specification: "Broke and entered at night the dwelling house of {V} in {HOOD}, with the intent to commit larceny therein.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole two televisions, a laptop, and jewelry valued at more than $1,000 from the dwelling of {V}.", chance: 1.0, threshold: 0)
        ],
        ageRange: 23...45, occupations: ["cleaning contractor", "house cleaner"], hasVictim: true,
        summaries: [
            "{V} owns a beach house in {HOOD} that is rented weekly in season and sits empty in winter. At 11:52 p.m. on {DATE}, {V.his} doorbell camera recorded a person in a dark jacket opening the side door with a key-shaped object and going inside. Two televisions, a laptop, and jewelry were taken. {D}, whose company cleaned the house between rentals, had a key code to the lockbox. Two days later the laptop was sold at a pawn shop under {DL}'s name. {DL} says {D.he} bought the laptop from a stranger at a flea market and never went to the house that night."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Doorbell Camera", "A person in a dark jacket opens the side door with a key at 11:52 p.m.; the face is turned away.", .search),
            E(.document, 3, "Pawn Record", "The stolen laptop pawned by {DL}, with {D.his} driver's license and thumbprint, two days later.", .search),
            E(.document, 2, "Lockbox Log", "The lockbox opened with {DL}'s company code at 11:49 p.m.")
        ],
        defenseEvidence: [
            E(.document, 2, "Shared Code", "Three employees of {DL}'s cleaning company used the same lockbox code."),
            E(.statement, 1, "Flea Market", "A flea market vendor says laptops change hands there every weekend without receipts.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"Nobody had a reason to be there in January.\""],
                        cross: ["\"The cleaners had the code.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How is the house used?", "\"It's rented by the week in season. In winter it sits empty.\""),
                            .direct("Was anyone supposed to be in the house that night?", "\"No. It was January. The next cleaning wasn't until March.\""),
                            .direct("What was taken?", "\"Two televisions, a laptop, and jewelry.\""),
                            .cross("{DL}'s company had the lockbox code?", "\"Yes. The company, not one person.\""),
                            .cross("Your camera never showed the person's face?", "\"No. It was turned away.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Property crimes detective",
                        direct: ["\"The lockbox opened with {DL}'s company code three minutes before.\""],
                        cross: ["\"Three employees shared that code.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How was the house entered?", "\"The lockbox was opened with the cleaning company's code at 11:49, and the key used on the side door at 11:52.\""),
                            .direct("What does the doorbell video show?", "\"A person in a dark jacket opening the side door and going in. The face is turned away.\""),
                            .direct("How did {DL} become a suspect?", "\"The stolen laptop was pawned two days later with {DL}'s driver's license and thumbprint.\""),
                            .cross("Three employees used the same code?", "\"Yes. Only {DL} pawned the laptop.\""),
                            .cross("Nothing on the video identifies {DL}?", "\"Not the face, no.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former employee of {DL}'s company",
                        direct: ["\"All three of us had that code.\""],
                        cross: ["\"I wasn't there that night.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you do for {DL}'s company?", "\"Cleaned rental houses between guests.\""),
                            .direct("Who had the lockbox code?", "\"Me, {DL}, and another girl who quit in December.\""),
                            .direct("Did you all use the same code?", "\"Yes. One code for the company.\""),
                            .cross("Where were you that night?", "\"Home. I wasn't anywhere near the beach.\""),
                            .cross("So you have no idea who opened that lockbox at 11:49?", "\"No, I don't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} used the company code at 11:49, walked in at 11:52, and pawned the laptop under {D.his} own name two days later."],
        defenseTheory: ["Three people had the code, the face is never seen, and buying a laptop at a flea market is foolish, not burglary."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I trusted that company with my house. I've changed every lock.\""],
        allocutions: ["\"I bought that laptop. I didn't break into anyone's house.\""],
        guiltyTruths: ["{DL}'s phone was at the beach house's address from 11:45 p.m. to 12:30 a.m."],
        innocentTruths: ["The employee who quit in December was arrested with the televisions and the jewelry a month later."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "11:49 p.m.: lockbox opened with the company code."), (0, "11:52 p.m.: side door opened."), (2, "Laptop pawned under {DL}'s name."), (9, "Pawn record matched; {DL} charged.")],
            howIdentified: "The pawn shop record and the lockbox code.",
            notDone: ["The former employee who quit in December was not interviewed."],
            defendantExam: [
                .direct("Where did you get the laptop?", "\"A flea market in Bayard, from a guy with a table of electronics.\""),
                .cross("Your company code opened the lockbox three minutes before the entry.", "\"So did two other people's.\""),
                .cross("You pawned the laptop two days later.", "\"Because I needed money. I didn't know it was stolen.\"")
            ],
            prosecutionOpening: "A code, a key, and a laptop pawned under {DL}'s own name.",
            defenseOpening: "A shared code and a flea market purchase.",
            prosecutionClosing: "Recent possession of stolen property, plus the code, is proof of the break-in.",
            defenseClosing: "The face on the camera is never seen. Three people had that code.",
            when: .months([1]),
            victim: VictimFacts(relationship: "The defendant's company cleaned his rental house.", restitution: 3800, restitutionBasis: "the televisions and jewelry never recovered, and the side door"),
            employer: "own cleaning company"
        )
    )
}
