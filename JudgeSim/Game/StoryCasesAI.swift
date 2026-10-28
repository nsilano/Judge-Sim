import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAI: [CaseTemplate] = [fosterChildInjury, dogfightingRing, crabPotTheft, hotelPartyOverdose, weddingRingPawn]

    // MARK: - The bunk bed (a foster child's broken arm)

    static let fosterChildInjury = CaseTemplate(
        key: "story.fosterChildInjury", category: .family,
        headlines: ["Foster Parent Charged After Toddler's Arm Broken", "Doctors Disagree Over Foster Child's Spiral Fracture"],
        primaryLaw: "felonyChildAbuse", lesserLaw: "childAbuseMisd", threshold: 7, lesserThreshold: 5,
        specification: "Being the caretaker of {V}, a child under 16, intentionally inflicted serious physical injury, a spiral fracture of the left upper arm, on {DATE}.",
        ageRange: 32...55, occupations: ["school cafeteria manager", "church secretary", "long-haul trucker"], hasVictim: true,
        summaries: [
            "{V}, three, had lived with {D} as a foster child for five months when {D} brought {V.him} to the emergency room at 8:10 p.m. on {DATE} with a swollen left arm. X-rays showed a spiral fracture of the upper arm. {D} said {V} had fallen from the top bunk while playing with the older foster child, who is seven. The child abuse pediatrician who examined {V} found four bruises on the upper arm in the shape of fingertips, and says a spiral fracture in a three-year-old comes from twisting, not a fall. The defense's expert, a biomechanical engineer, says a child who catches an arm in a bunk bed ladder while falling can twist it the same way. The older foster child told a social worker \"{V.he} fell,\" then later, \"I don't know.\""
        ],
        prosecutionEvidence: [
            E(.document, 3, "Pediatrician's Report", "A spiral fracture of the left humerus and four oval bruises on the inner upper arm, \"consistent with a forceful grip.\" No other injuries, no prior fractures."),
            E(.document, 2, "Timeline", "{D} called the after-hours nurse line at 6:40 p.m. and arrived at the emergency room at 8:10 p.m."),
            E(.statement, 2, "Social Worker's Notes", "The older foster child said \"{V.he} fell\" on the first interview and \"I don't know\" on the second.")
        ],
        defenseEvidence: [
            E(.document, 3, "Biomechanics Report", "A child falling from 52 inches with an arm caught in the bunk ladder rungs can generate the twisting force for a spiral fracture."),
            E(.document, 1, "Licensing File", "Eleven years as a licensed foster parent, nineteen children, no substantiated reports.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Child abuse pediatrician",
                        direct: ["\"A spiral fracture in a toddler means twisting.\""],
                        cross: ["\"A caught arm in a fall can twist.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find?", "\"A spiral fracture of the upper arm and four oval bruises on the inside of the arm, about the size of adult fingertips. Nothing else: no bump on the head, no scrape, nothing you'd see from a fall off a bed.\""),
                            .direct("What causes a spiral fracture?", "\"Twisting force on a long bone. In a child this young, who isn't running and playing sports, we see it most from an adult gripping and twisting.\""),
                            .direct("And the delay?", "\"About an hour and a half between the nurse line and the emergency room. That alone isn't abuse. It's one more thing.\""),
                            .cross("Could a child whose arm caught in a ladder rung as they fell twist it this way?", "\"It's possible. I'd expect a mark from the rung, and there wasn't one.\""),
                            .cross("You've seen this kind of fracture from accidents.", "\"I have. Not often with grip marks.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator, crimes against children",
                        direct: ["\"The older child's story changed.\""],
                        cross: ["\"The older child is seven.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That {V} was on the top bunk with the older child, {D.he} heard a thump and crying, and found {V} on the floor holding {V.his} arm.\""),
                            .direct("What did the older child say?", "\"First, '{V.he} fell.' A week later, 'I don't know.' We didn't push a seven-year-old.\""),
                            .direct("Did you measure the bunk?", "\"Fifty-two inches to the top mattress. Carpet over concrete.\""),
                            .cross("In eleven years, {DL} has had no substantiated reports.", "\"That's what the file says.\""),
                            .cross("Did anyone see {DL} grab {V}?", "\"No.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Biomechanical engineer",
                        direct: ["\"A caught arm in a fall can produce a spiral fracture.\""],
                        cross: ["\"I didn't examine the child.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you test?", "\"A child-size dummy falling from the top bunk with the arm hooked in the ladder rung. The torque on the upper arm is enough for a spiral fracture in a three-year-old.\""),
                            .direct("What about the bruises?", "\"A child grabbed by an adult rushing to help after the fall would bruise the same way.\""),
                            .cross("You've never examined a living child.", "\"I'm an engineer. I study forces.\""),
                            .cross("The defense paid for your work.", "\"My usual rate, yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} gripped and twisted a three-year-old's arm hard enough to break it, then waited ninety minutes and blamed a fall."],
        defenseTheory: ["A toddler fell from a bunk bed with an arm caught in the ladder. Eleven years of foster care without a single complaint, and a science that can't rule out an accident."],
        aggravating: ["The victim was very young", "The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: ["The guardian ad litem reads a statement: \"{V} doesn't want anyone to pick {V.him} up anymore. {V.He} flinches when grown-ups reach for {V.his} arms. Whatever happened, {V.he} needs a home where that stops.\""],
        allocutions: ["\"I've loved every child who came through my door. I would never hurt that baby.\"", "\"I lost my temper. I've never said that out loud. I'm sorry.\""],
        guiltyTruths: ["The older foster child, in therapy a year later, said {DL} had \"squeezed and turned\" {V}'s arm when {V.he} wouldn't stop crying."],
        innocentTruths: ["A home security camera the court never saw showed {V} slipping from the ladder with an arm through the rungs while {DL} was in the kitchen."],
        moods: [.divided], doctrines: ["expertTestimony", "burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-150, "{V} placed with {DL} by DSS."), (0, "About 6:30 p.m.: {V} injured; 6:40 p.m. nurse line call."), (0, "8:10 p.m.: emergency room; spiral fracture found."), (1, "Child abuse pediatrician's exam; DSS and deputies notified."), (8, "Second interview of the older foster child.")],
            howIdentified: "{DL} was the only adult home.",
            notDone: ["The bunk ladder wasn't examined for skin or fabric.", "No one asked whether the home had any cameras."],
            defendantExam: [
                .direct("What happened that evening?", "\"I was making supper. I heard a thump and screaming. {V} was on the floor by the ladder holding {V.his} arm.\""),
                .direct("Why wait to go to the hospital?", "\"The nurse line said to ice it and watch for swelling. When it swelled, I went.\""),
                .cross("Four fingertip bruises on the inside of the arm.", "\"I grabbed {V.him} up off the floor. I was scared.\"", "\"I picked {V.him} up fast. I may have held too tight.\""),
                .cross("The child was crying a lot that week, wasn't {V.he}?", "\"{V.He} was teething and missing {V.his} mother. They all cry.\""),
                .cross("You were alone with two small children and supper on the stove.", "\"That's foster care.\"")
            ],
            prosecutionOpening: "A three-year-old's twisted arm and an adult's fingerprints on it.",
            defenseOpening: "A fall from a bunk bed, and eleven years of trust.",
            prosecutionClosing: "Spiral fractures come from twisting. Grip marks come from hands. Only {DL}'s were there.",
            defenseClosing: "Even the State's doctor says an accident is possible. That's reasonable doubt.",
            victim: VictimFacts(age: 3, occupation: "foster child", relationship: "Foster child in the defendant's home", harm: ["Spiral fracture of the left humerus"]),
            time: "6:30 p.m.",
            family: "Married; two grown children; a licensed foster parent for eleven years.",
            residence: "A brick ranch house on {STREET} in {HOOD}"
        )
    )

    // MARK: - Shiloh Road kennel (dogfighting)

    static let dogfightingRing = CaseTemplate(
        key: "story.dogfightingRing", category: .publicOrder,
        headlines: ["Fourteen Scarred Dogs Seized From Shiloh Road Property", "Owner Says He Breeds Dogs; Deputies Say He Fights Them"],
        primaryLaw: "animalCruelty", lesserLaw: nil, threshold: 7, lesserThreshold: 0,
        specification: "Maliciously tortured, mutilated, and cruelly killed animals, by keeping and training dogs for fighting and causing them to fight, on and before {DATE}.",
        ageRange: 30...55, occupations: ["mechanic", "landscaper", "tow truck driver"], hasVictim: false,
        summaries: [
            "Acting on a tip, deputies and county animal services searched {D}'s property off Shiloh Road on {DATE} with a warrant. They found fourteen pit bull-type dogs, each chained to a buried truck axle out of reach of the others, many with scars on their faces and front legs. In a shed they found a carpet-covered treadmill, a \"break stick\" used to pry dogs' jaws apart, injectable antibiotics, and a notebook of weights and dates. A shallow grave held two dogs with fresh wounds. {DL} says {D.he} breeds and sells dogs, the scars come from fights when dogs got loose, and a man who rented the back acre used the shed."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Shed Equipment", "A treadmill, a break stick, a spring pole, and antibiotics without a prescription.", .search),
            E(.document, 3, "Notebook", "Dog names, weights, and dates, with entries like \"Diesel 44 lb vs Duke's red, 51 min, W.\" Handwriting comparison points to {DL}.", .search),
            E(.forensic, 2, "Necropsy", "The two buried dogs died of bite wounds to the head and neck within days of each other.")
        ],
        defenseEvidence: [
            E(.document, 2, "Lease", "A handwritten lease of \"the back acre and shed\" to a man named Rudy, $200 a month."),
            E(.document, 1, "Sales Records", "Texts selling puppies for $400 to $800.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "County animal services director",
                        direct: ["\"Every dog had fight scars in the same places.\""],
                        cross: ["\"Dogs that get loose do fight.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find?", "\"Fourteen dogs on axles, each just out of reach of the next. That's how fighting dogs are kept, so they can see each other and never touch.\""),
                            .direct("What about the scars?", "\"Face, front legs, and chest, on almost every dog. Dogs fighting loose don't scar that evenly.\""),
                            .direct("What happened to the dogs?", "\"Nine were placed with rescue groups after rehabilitation. Five couldn't be.\"", "\"Five were too aggressive to place. That's the hardest part of my job.\""),
                            .cross("A breeder keeps dogs chained too.", "\"Not on buried axles, out of reach, with a treadmill in the shed.\""),
                            .cross("You didn't see a fight.", "\"No.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator",
                        direct: ["\"The notebook is a fight record.\""],
                        cross: ["\"I never found Rudy.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What is the notebook?", "\"A record of fights: two dogs, their weights, how long it lasted, and who won. 'W' and 'L.' Forty-one entries over two years.\""),
                            .direct("Who wrote it?", "\"The handwriting examiner says it's consistent with {DL}'s writing on the lease and on {D.his} truck title.\""),
                            .direct("What did the phone show?", "\"Texts setting 'a match' on Saturdays, with weights.\""),
                            .cross("The back acre was leased to someone else.", "\"To 'Rudy,' with no last name and no phone. The neighbors never saw him.\""),
                            .cross("Selling puppies is legal.", "\"It is.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Customer who bought a puppy",
                        direct: ["\"My dog from {DL} is the sweetest dog I've had.\""],
                        cross: ["\"I never went in the shed.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"I bought a puppy from {D.him} two years ago. Healthy, shots up to date.\""),
                            .direct("What did you see at the property?", "\"Dogs on chains. Water bowls. Nothing scary.\""),
                            .cross("Did you notice the scars on the adult dogs?", "\"Some had scars. I thought they were rescues.\""),
                            .cross("Did you go behind the house?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{D} kept fourteen dogs for fighting, trained them on a treadmill, kept a fight record in {D.his} own hand, and buried the losers."],
        defenseTheory: ["{D} breeds dogs. The shed was rented to someone else, and the State's case is a notebook nobody saw {D.him} write in."],
        aggravating: ["The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["The defendant has been gainfully employed"],
        victimImpacts: ["The animal services director: \"I held two of those dogs while the vet put them down. They wagged their tails at me. That's what got to me.\""],
        allocutions: ["\"I grew up around it. I know that's not an excuse.\"", "\"Those dogs were my life. I never hurt them.\""],
        guiltyTruths: ["A video on {DL}'s phone, recovered later, shows two dogs fighting in the shed while {DL} counts the minutes."],
        innocentTruths: ["A man named Rudolph Pace was arrested in South Carolina with the matching half of the notebook, in his handwriting."],
        moods: [.wantsConviction], doctrines: ["searchSeizure", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(-730, "First entry in the notebook."), (-10, "Anonymous tip to animal services."), (0, "Search warrant executed; fourteen dogs seized; two graves found."), (5, "Necropsy results.")],
            howIdentified: "The property is {DL}'s, and the notebook's handwriting.",
            notDone: ["The tipster was never identified.", "The phone that set \"matches\" was never tied to a subscriber."],
            defendantExam: [
                .direct("What do you do with the dogs?", "\"I breed them. I sell puppies. That's all.\""),
                .direct("The treadmill and the break stick?", "\"Rudy's. He rented the back acre and the shed.\""),
                .cross("The notebook is in your handwriting.", "\"Their expert says 'consistent.' That's not mine.\"", "\"It's not mine.\""),
                .cross("Two dogs buried with bite wounds.", "\"They got loose and fought. I buried them.\""),
                .cross("Where is Rudy?", "\"I don't know. He left when the deputies came.\"")
            ],
            prosecutionOpening: "Fourteen dogs on axles, a fight record, and two graves.",
            defenseOpening: "A breeder, a renter, and a notebook nobody saw written.",
            prosecutionClosing: "The axles, the treadmill, the scars, and the notebook in {DL}'s hand. This was a fighting yard.",
            defenseClosing: "Rudy rented the shed. The State never looked for him.",
            when: .months([3, 4, 5, 6, 7, 8, 9, 10]),
            genders: ["D": .male],
            family: "Divorced; one son.",
            residence: "A house on six acres off Shiloh Road"
        )
    )

    // MARK: - The Bayard creek line (crab pots)

    static let crabPotTheft = CaseTemplate(
        key: "story.crabPotTheft", category: .property,
        headlines: ["Waterman Says His Crab Pots Were Pulled and Repainted", "Marine Patrol Charges Man in Crab Pot Theft"],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 6, lesserThreshold: 4,
        specification: "Stole 32 crab pots and their catch, valued at $2,100, belonging to {V}, from the waters of Bayard Creek, on {DATE}.",
        ageRange: 25...60, occupations: ["commercial fisherman", "deckhand", "boat mechanic"], hasVictim: true,
        summaries: [
            "{V}, a commercial waterman, set a line of 32 crab pots in Bayard Creek with orange and white buoys carrying {V.his} license number. On {DATE} {V} found the line gone. Two days later a Marine Patrol officer checking licenses at the {PLACE.LANDING} found 30 pots in {D}'s skiff with the buoys freshly painted green and a different license number stenciled on. Under the green paint, the old numbers showed through. {DL} says {D.he} found the pots drifting loose after a storm, abandoned, and had every right to keep them."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Buoys", "Thirty buoys painted green, with {V}'s license number visible under the paint when held to the light.", .search),
            E(.document, 2, "License Records", "The number stenciled over the old one belongs to {DL}."),
            E(.document, 2, "Value", "Pots at $55 apiece plus the catch: $2,100.")
        ],
        defenseEvidence: [
            E(.document, 2, "Weather Report", "A nor'easter with 40-knot gusts passed four days before the theft was reported."),
            E(.statement, 1, "Found Gear", "{DL} says {D.he} found the pots tangled together near the mouth of the creek.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Commercial waterman",
                        direct: ["\"Those are my pots. I built every one.\""],
                        cross: ["\"Storms do move pots.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How do you know the pots are yours?", "\"My number's under that green paint. And I build my own pots with a zinc on the left corner. Nobody else does it that way.\""),
                            .direct("What did losing them cost you?", "\"Two weeks of fishing in peak season. I've got a boat payment and two kids.\"", "\"About three thousand in lost catch on top of the pots. In August.\""),
                            .direct("Were the pots tangled after the storm?", "\"I checked them the day after the blow. All thirty-two were sitting right where I set them.\""),
                            .cross("Storms move pots all the time.", "\"They do. They don't repaint them.\""),
                            .cross("You and {DL} have argued about that creek before.", "\"{D.He} thinks it's {D.his}. It isn't.\"")
                        ]),
            WitnessSeed(name: nil, role: "Marine Patrol officer",
                        direct: ["\"The old license number showed through the paint.\""],
                        cross: ["\"Abandoned gear does wash up.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find in the skiff?", "\"Thirty pots, buoys freshly painted green, still tacky, with {DL}'s number stenciled on. Hold one to the light and you can read {V}'s number underneath.\""),
                            .direct("What's the rule on found pots?", "\"You can't keep another licensee's marked gear. If it's derelict, you report it to Marine Fisheries.\""),
                            .direct("Did {DL} report finding them?", "\"No.\""),
                            .cross("The storm was four days earlier.", "\"It was. {V} checked the line after it.\""),
                            .cross("Did you see {DL} pull the pots?", "\"No.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fellow waterman",
                        direct: ["\"After a blow, gear is everywhere.\""],
                        cross: ["\"I'd call the owner.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What's the creek like after a nor'easter?", "\"Pots tangled up in the marsh grass, buoys torn off, lines everywhere. Everybody loses gear.\""),
                            .direct("What do people do with loose pots?", "\"Some keep them. Some call. Depends on the man.\""),
                            .cross("Would you repaint another man's buoys?", "\"No.\""),
                            .cross("Would you stencil your number over his?", "\"No, I wouldn't do that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pulled {V}'s line, painted over the buoys, and stenciled {D.his} own number on them."],
        defenseTheory: ["{D} found storm-tossed gear and thought it was abandoned. That's a Marine Fisheries violation, not larceny."],
        aggravating: ["The offense was committed for pecuniary gain"],
        mitigating: ["The defendant has been gainfully employed", "The defendant has a support system in the community"],
        victimImpacts: ["\"My daddy fished that creek and his daddy before him. I build every pot by hand in my yard. When somebody takes your line, they take your month.\""],
        allocutions: ["\"I should have called it in. I'll pay {V} for every pot.\""],
        guiltyTruths: ["A neighbor's camera at the landing showed {DL}'s skiff going out at 4 a.m. the morning the line disappeared, two days after the storm, and coming back loaded."],
        innocentTruths: ["A second waterman later admitted to pulling {V}'s line and dumping the pots where {DL} found them, to start trouble between the two."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "mistakeOfFact", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-4, "Nor'easter passes."), (-3, "{V} checks the line; all 32 pots in place."), (0, "{V} finds the line gone and reports it."), (2, "Marine Patrol finds 30 pots in {DL}'s skiff at the landing.")],
            howIdentified: "A license check at the landing.",
            notDone: ["The landing's camera was never checked.", "The two missing pots were never found."],
            defendantExam: [
                .direct("Where did you get the pots?", "\"Tangled up in the marsh by the mouth of the creek after the storm. I figured they were lost.\""),
                .direct("Why paint the buoys?", "\"So nobody would think I stole them.\""),
                .cross("Painting over another man's number so nobody would think you stole them.", "\"It sounds bad when you say it.\""),
                .cross("You didn't report them to Marine Fisheries.", "\"I didn't think about it.\""),
                .cross("You and {V} have argued about that creek before.", "\"Everybody argues about that creek.\"")
            ],
            prosecutionOpening: "Thirty pots with {V}'s number under fresh green paint.",
            defenseOpening: "Storm-tossed gear, and a bad decision about it.",
            prosecutionClosing: "You don't paint over a number on gear you think is abandoned.",
            defenseClosing: "Found gear after a nor'easter. The State can't prove {DL} pulled that line.",
            when: .months([5, 6, 7, 8, 9, 10]),
            victim: VictimFacts(age: 47, occupation: "commercial waterman", relationship: "Fishes the same creek", family: "Married, two children"),
            family: "Married, one child.",
            residence: "A house near the Bayard Boat Landing"
        )
    )

    // MARK: - Room 112 (an overdose at a motel party)

    static let hotelPartyOverdose = CaseTemplate(
        key: "story.hotelPartyOverdose", category: .drugs,
        headlines: ["Twenty-Year-Old Dies After Motel Party; Friend Charged", "Death by Distribution Charge Turns on a $20 Payment"],
        primaryLaw: "deathByDistribution", lesserLaw: "deliverSchedII", threshold: 7, lesserThreshold: 5,
        specification: "Unlawfully sold fentanyl to {V}, and the ingestion of the substance caused the death of {V}, on {DATE}.",
        ageRange: 19...28, occupations: ["line cook", "warehouse worker", "community college student"], hasVictim: true,
        summaries: [
            "{V}, 20, was found unresponsive in Room 112 at {PLACE.MOTEL} at 6:15 a.m. on {DATE}, after a birthday party that broke up around 2 a.m. The medical examiner found a fatal level of fentanyl. Texts show {V} asked {D} for \"two blues\" at 11:48 p.m., and {D} answered \"got u.\" At 12:20 a.m., {V} sent {D} $20 on a payment app with the note \"gas.\" {DL} admits giving {V} two pills from {D.his} own supply, but says {D.he} never sold anything: the $20 was for driving {V} to the party, and {D.he} took the same pills that night. The law requires a sale."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Texts and Payment", "11:48 p.m.: \"u got two blues?\" / \"got u.\" 12:20 a.m.: $20 from {V} to {DL}, note \"gas.\"", .search),
            E(.forensic, 3, "Medical Examiner", "Death from acute fentanyl toxicity; no other drugs except a small amount of alcohol."),
            E(.statement, 2, "Party Guest", "A guest saw {DL} hand {V} something in the bathroom doorway around 12:30 a.m.")
        ],
        defenseEvidence: [
            E(.digital, 2, "Ride Texts", "Texts earlier that evening: \"can u drive me to the party?\" / \"yeah\" from {V} to {DL}, at 9:05 p.m."),
            E(.forensic, 1, "Defendant's Blood", "{DL}'s own blood, drawn the next morning, showed fentanyl.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Overdose task force detective",
                        direct: ["\"Ask, answer, and a payment thirty minutes later.\""],
                        cross: ["\"{V} did ask for a ride earlier that night.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the phones show?", "\"At 11:48, {V} asks for two blues. {DL} says 'got u.' At 12:20, twenty dollars to {DL} with the note 'gas.'\""),
                            .direct("What do 'blues' cost around here?", "\"Ten dollars apiece, give or take. Two for twenty.\""),
                            .direct("Had {DL} been paid for pills before?", "\"Three other payments to {DL} with the note 'gas' in the past month, from people who didn't need a ride.\""),
                            .cross("{V} asked {DL} for a ride at 9:05 that night.", "\"{V} did.\""),
                            .cross("{DL} took the same pills that night.", "\"{D.His} blood says so.\"")
                        ]),
            WitnessSeed(name: nil, role: "{V}'s mother",
                        direct: ["\"I found out from a deputy on my porch at seven in the morning.\""],
                        cross: ["\"I didn't know {V.he} was using.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Tell the court about {V}.", "\"{V.He} turned twenty that night. {V.He} was saving for a car. {V.He} called me at ten to say happy birthday to {V.him}self, because I always say it first.\""),
                            .direct("How did you learn what happened?", "\"A deputy on my porch at seven in the morning. I knew before he said anything.\""),
                            .cross("Did you know {V} used pills?", "\"No. Maybe I didn't want to.\""),
                            .cross("{DL} and {V} were friends.", "\"Since middle school. {DL} ate at my table.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend who was at the party",
                        direct: ["\"{DL} drove {V} there. Everybody knew that.\""],
                        cross: ["\"I saw {DL} give {V} something.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did {V} get to the party?", "\"{DL} drove {V.him}. {V.His} car's been in the shop for a month.\""),
                            .direct("Did {DL} sell pills?", "\"Not that I ever saw. {D.He} shared what {D.he} had.\""),
                            .cross("You saw {DL} hand {V} something in the bathroom.", "\"I saw them in the doorway.\""),
                            .cross("Did anybody else pay {DL} for gas that month?", "\"I don't know about that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sold {V} two fentanyl pills for $20 and {V} died. Calling it gas money doesn't change what it was."],
        defenseTheory: ["Two friends shared pills; one died. That's a tragedy and it's delivery, but the statute requires a sale, and the $20 was for the ride {V} asked for at 9:05."],
        aggravating: ["The offense involved a controlled substance that caused a death"],
        mitigating: ["The defendant was young at the time of the offense", "The defendant has expressed remorse", "No prior criminal record"],
        victimImpacts: ["{V}'s mother: \"{V.He} called me at ten o'clock to say happy birthday to {V.him}self, because I always say it first. I didn't get to say it first this year. I'll never get to say it again.\""],
        allocutions: ["\"{V} was my best friend. I'd give anything to have that night back. I'm using every day I'm alive to make it mean something.\""],
        guiltyTruths: ["{DL}'s phone held a running list of names, amounts, and the word \"gas\" beside each, going back four months."],
        innocentTruths: ["The gas station receipt for that night, found later in {DL}'s car, shows $20 of gas bought at 8:50 p.m. on the way to pick {V} up."],
        moods: [.divided], doctrines: ["burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(0, "9:05 p.m.: {V} asks {DL} for a ride."), (0, "11:48 p.m.: \"u got two blues?\" / \"got u.\""), (0, "12:20 a.m.: $20 to {DL}, \"gas.\""), (1, "6:15 a.m.: {V} found unresponsive in Room 112.")],
            howIdentified: "The texts and the payment app on {V}'s phone.",
            notDone: ["{DL}'s supplier was never identified.", "The other guests weren't tested for fentanyl."],
            defendantExam: [
                .direct("Why did {V} send you $20?", "\"For gas. I drove {V.him} there from Cane Creek.\""),
                .direct("Did you give {V} pills?", "\"Two of mine. I took the same ones. I didn't know they were that strong.\""),
                .cross("'Got u.' Then twenty dollars.", "\"For the ride.\""),
                .cross("Three other 'gas' payments that month.", "\"I drive people. I have a car and they don't.\"", "\"Some of those were rides.\""),
                .cross("Where did you get the pills?", "\"A guy. I'm not going to say.\"")
            ],
            prosecutionOpening: "Two pills, twenty dollars, and a twentieth birthday that ended in Room 112.",
            defenseOpening: "Two friends, one terrible night, and a ride.",
            prosecutionClosing: "Ask, answer, pay. That's a sale.",
            defenseClosing: "{DL} delivered and {DL} is guilty of that. Not of selling.",
            victimDied: true,
            victim: VictimFacts(age: 20, occupation: "restaurant server", relationship: "Friend since middle school", family: "Lived with a parent"),
            time: "12:30 a.m."
        )
    )

    // MARK: - Grandmother's ring

    static let weddingRingPawn = CaseTemplate(
        key: "story.weddingRingPawn", category: .whiteCollar,
        headlines: ["Grandson Charged With Pawning Grandmother's Wedding Ring", "Elderly Widow's Ring and Watch Turn Up at Pawn Shop"],
        primaryLaw: "exploitationElder", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Being in a position of trust with {V}, an older adult, knowingly took {V}'s property, a wedding ring and a wristwatch valued at $3,500, by deception, and pawned them, on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole a wedding ring and a wristwatch, valued at $3,500, belonging to {V}.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...34, occupations: ["unemployed", "part-time warehouse worker", "landscaper"], hasVictim: true,
        summaries: [
            "{D} moved in with {D.his} grandmother, {V}, 78, a widow, after losing {D.his} apartment. On {DATE}, {D} pawned {V}'s diamond wedding ring and {D.his} late grandfather's gold watch at {PLACE.PAWN} for $650, under {D.his} own name. {V}'s daughter noticed the ring missing from {V}'s hand a week later. {V} first told a deputy {V.he} had never let the ring out of {V.his} sight; at a second interview {V.he} said {V.he} may have told {D} to \"take what you need.\" {V}'s doctor says {V.he} has early memory loss."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Pawn Ticket", "A diamond ring and a gold wristwatch pawned for $650 by {D}, with {D.his} thumbprint and license.", .search),
            E(.document, 2, "Appraisal", "Ring $2,400; watch $1,100."),
            E(.statement, 2, "First Interview", "{V}: \"I never take that ring off. Not once in fifty-four years.\"")
        ],
        defenseEvidence: [
            E(.statement, 2, "Second Interview", "{V}: \"I might have told {DL} to take what {D.he} needed. I don't remember.\""),
            E(.document, 1, "Doctor's Letter", "{V} has mild cognitive impairment; short-term memory is unreliable.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Grandmother",
                        direct: ["\"That ring was on my hand fifty-four years.\""],
                        cross: ["\"I don't remember everything anymore.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Tell the court about the ring.", "\"Earl gave it to me at the Methodist church in Wexley. I never took it off. Not to wash dishes, not in the hospital.\""),
                            .direct("Did you give it to {DL}?", "\"I don't think I would. Not that ring. I'd give {D.him} anything else.\"", "\"No. I wouldn't. Not that.\""),
                            .direct("How do you feel about this?", "\"I love that child. I want my ring back and I want {D.him} to get help. I don't want {D.him} in jail.\""),
                            .cross("Your doctor says your memory isn't what it was.", "\"It isn't. I remember Earl. I remember that ring.\""),
                            .cross("You told the deputy you might have told {DL} to take what {D.he} needed.", "\"Did I? I might have. I say that to everybody.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator",
                        direct: ["\"{DL} pawned both pieces under {D.his} own name.\""],
                        cross: ["\"{V}'s second statement was different.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you find the ring?", "\"The pawn shop's report to our database. Both pieces, pawned by {DL} for $650.\""),
                            .direct("What did {DL} say?", "\"That {D.his} grandmother said to take what {D.he} needed, and {D.he} meant to get them back when {D.he} got paid.\""),
                            .direct("Did {DL} have a job?", "\"Not then.\""),
                            .cross("The pawn was in {DL}'s own name.", "\"It was.\""),
                            .cross("{V} told you the second time {V.he} might have said to take what {D.he} needed.", "\"{V.He} did. {V.He} also cried and said {V.he} didn't remember.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defendant's aunt",
                        direct: ["\"Mama says 'take what you need' to all of us.\""],
                        cross: ["\"I never saw her take the ring off.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What does {V} say to family?", "\"'Take what you need.' Every time any of us is short. Groceries, gas money, whatever's in the jar.\""),
                            .direct("How is {DL} with {V}?", "\"{D.He} drives {V.him} to every appointment. {D.He} sets out {V.his} pills.\""),
                            .cross("Has {V} ever offered anyone the ring?", "\"No. Never that.\""),
                            .cross("Did {DL} tell anyone about the pawn?", "\"Not that I know of.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took {D.his} grandmother's wedding ring and {D.his} grandfather's watch while living under her roof, pawned them, and relied on her memory to cover it."],
        defenseTheory: ["{V} told {D} to take what {D.he} needed, the way {V.he} tells everyone. {D} pawned them in {D.his} own name, meaning to get them back. That isn't deception."],
        aggravating: ["The victim was very old", "The defendant took advantage of a position of trust"],
        mitigating: ["The defendant was young at the time of the offense", "The defendant has a support system in the community"],
        victimImpacts: ["\"I keep reaching for it with my thumb. Fifty-four years, it was always there. I'm not angry. I'm just sad, and I want it back.\""],
        allocutions: ["\"Grandma, I'm sorry. I was going to get it back. I'll get it back.\"", "\"I'm going to treatment. I'll pay the pawn shop out of my first check.\""],
        guiltyTruths: ["{DL} had pawned and lost two of {V}'s rings at another shop the year before, which the family never noticed."],
        innocentTruths: ["{V}'s neighbor, who was visiting that day, heard {V} tell {DL}, \"Take the ring and the watch, honey, Earl would want you to have a roof.\""],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(-90, "{DL} moves in with {V}."), (0, "Ring and watch pawned for $650."), (7, "{V}'s daughter notices the ring missing."), (8, "Pawn database match; first interview of {V}."), (20, "Second interview of {V}.")],
            howIdentified: "The pawn shop's report under {DL}'s own name.",
            notDone: ["No one asked the neighbors whether they heard anything that week."],
            defendantExam: [
                .direct("Did your grandmother give you permission?", "\"She says 'take what you need.' I needed rent money for a new place. I was going to get them back.\""),
                .direct("Why the ring?", "\"It was the only thing worth anything.\""),
                .cross("Her wedding ring, off her dresser, without asking about the ring itself.", "\"I didn't ask about the ring. I should have.\""),
                .cross("You didn't tell anyone.", "\"I was ashamed.\""),
                .cross("You didn't have a job to get them back with.", "\"I was looking.\"")
            ],
            prosecutionOpening: "A widow's ring of fifty-four years, pawned for $650.",
            defenseOpening: "'Take what you need.'",
            prosecutionClosing: "A blanket 'take what you need' doesn't cover a wedding ring, and {DL} knew it.",
            defenseClosing: "{DL} pawned it in {D.his} own name. People hiding a theft don't do that.",
            genders: ["V": .female],
            victim: VictimFacts(age: 78, occupation: "retired school cafeteria worker", relationship: "Grandmother", family: "Widowed; three children, seven grandchildren"),
            family: "Single, no children.",
            residence: "{D.His} grandmother's house in {HOOD}, since losing an apartment"
        )
    )
}
