import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchM: [CaseTemplate] = [nightNurse, coastalBodies, coldCaseGenealogy, truckStopKiller, collegeHouse]

    // MARK: - 74. The night nurse (three patients, one insulin vial)

    static let nightNurse = CaseTemplate(
        key: "story.nightNurse", category: .violent,
        headlines: ["Nurse Charged With Killing Three Patients", "Hospital Deaths: Insulin Found in Patients Who Weren't Diabetic"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 9, lesserThreshold: 7,
        specification: "With premeditation and deliberation, killed {V}, a patient at Hollis Regional Medical Center, by injecting insulin.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, a patient at Hollis Regional Medical Center, by injecting insulin.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC3}, a patient at Hollis Regional Medical Center, by injecting insulin.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "attemptedMurder1", specification: "Attempted to kill a fourth patient on the cardiac step-down unit by injecting insulin.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by altering medication administration records to hide insulin withdrawals.", chance: 1.0, threshold: 0)
        ],
        ageRange: 30...48, occupations: ["registered nurse"], hasVictim: true,
        summaries: [
            "Over seven weeks on the night shift of the cardiac step-down unit at Hollis Regional Medical Center, four patients who were not diabetic crashed with dangerously low blood sugar between 2 and 5 a.m. Three died: {V}, 71; {VIC2}, 64; and {VIC3}, 80. Lab tests on stored blood showed high insulin with almost no C-peptide, a sign the insulin came from a needle, not the body. {D}, a registered nurse, worked every one of those nights and had pulled insulin from the medication cabinet for patients who didn't need it. {DL} says the cabinet log is unreliable, that other nurses used each other's badges, and that very sick elderly patients sometimes crash for no clear reason."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Insulin and C-Peptide Tests", "Stored blood from all four patients: very high insulin, very low C-peptide, consistent only with injected insulin."),
            E(.document, 3, "Staffing Records", "{DL} was on duty for all four events; no other nurse worked more than two of them."),
            E(.digital, 2, "Medication Cabinet Log", "{DL}'s badge withdrew insulin 11 times in seven weeks for patients with no insulin order."),
            E(.document, 2, "Altered Charting", "Edits to medication records made from {DL}'s login after two of the deaths.")
        ],
        defenseEvidence: [
            E(.document, 2, "Badge Sharing", "A hospital audit found nurses on that unit routinely used each other's badges during busy nights."),
            E(.document, 2, "Understaffing", "The unit ran at half staffing on several of those nights, with {DL} covering two halls."),
            E(.forensic, 1, "Sample Storage", "Two of the four blood samples sat unrefrigerated for hours before testing.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Endocrinologist",
                        direct: ["\"Someone injected these patients with insulin.\""],
                        cross: ["\"I can't tell you whose hand held the needle.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What do the blood tests show?", "\"When your own pancreas makes insulin, it releases C-peptide in equal measure. These patients had huge insulin and almost no C-peptide. That means the insulin came from outside the body. A needle.\""),
                            .direct("Could their illnesses explain it?", "\"Sepsis or liver failure can drop blood sugar, but they don't produce this pattern. None of these four was diabetic or on insulin.\""),
                            .cross("Two samples sat unrefrigerated for hours?", "\"That would lower insulin readings, not raise them. If anything, the true levels were higher.\""),
                            .cross("You can't say who gave the insulin?", "\"No. Only that someone did.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"Four crashes, one nurse on every shift.\""],
                        cross: ["\"Nurses shared badges.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did {DL} become a suspect?", "\"The hospital's pharmacist flagged insulin pulled for patients who had no order. Every pull came from {DL}'s badge, and {DL} was on every shift where a patient crashed.\""),
                            .direct("What about the charting?", "\"After two of the deaths, someone logged in as {DL} and edited the medication records to remove the insulin pulls. The edits were made at 6:40 a.m., near the end of {D.his} shift.\""),
                            .cross("The hospital's own audit found badge sharing on that unit?", "\"It did.\""),
                            .cross("Did anyone see {DL} inject insulin into any patient?", "\"No one saw it.\""),
                            .cross("You searched {DL}'s home and car?", "\"We found nothing related.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Charge nurse on the unit",
                        direct: ["\"Everybody used each other's badges.\""],
                        cross: ["\"I never saw anyone else pull insulin for those rooms.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did the badges work on that unit?", "\"When you're running two halls alone at 3 a.m. and the cabinet's across the unit, you hand your badge to whoever's going. Everybody did it. It's against policy and we all did it.\""),
                            .direct("What kind of nurse is {DL}?", "\"One of the best I've worked with. Families asked for {D.him} by name.\""),
                            .cross("Did you ever pull insulin with {DL}'s badge?", "\"Never. I had my own badge and I used it.\""),
                            .cross("Do you know anyone who did?", "\"I can't name anyone.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was on duty for every crash, pulled insulin for patients who didn't need it, and then erased the record. Three people died."],
        defenseTheory: ["A broken hospital with shared badges and half staffing is looking for one person to blame. No one saw {DL} do anything, and the cabinet log can't say whose hand pulled the insulin."],
        aggravating: ["The victims were very old or infirm", "The defendant took advantage of a position of trust", "The offense involved multiple victims"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s child: \"Our parent went in for a heart rhythm problem and was supposed to come home on Friday.\""],
        allocutions: ["\"I became a nurse to take care of people. I never hurt one.\""],
        guiltyTruths: ["A used insulin syringe with {DL}'s fingerprints was later found in a sharps container in a locked supply room only {DL} had used that night."],
        innocentTruths: ["After {DL}'s arrest, another patient on the unit crashed with injected insulin on a night {DL} was in jail."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["VIC2": ["Walter Penland", "Doris Kemp", "Ernest Lyles"], "VIC3": ["Opal Haywood", "Clarence Batts", "Mae Sellers"]],
        story: StoryExtras(
            timeline: [(-49, "First unexplained low blood sugar crash on the unit."),
                       (-30, "{VIC2} dies after a 3 a.m. crash."),
                       (-11, "{VIC3} dies after a 4 a.m. crash."),
                       (0, "{V} dies after a 2:40 a.m. crash; the pharmacist flags insulin pulls."),
                       (14, "Stored blood samples tested for C-peptide."),
                       (40, "Charting edits traced to {DL}'s login."),
                       (55, "{DL} charged.")],
            howIdentified: "Pharmacy audit of insulin withdrawals and shift records.",
            notDone: ["Other nurses' badge use was never reconstructed from cabinet camera footage, which was overwritten."],
            defendantExam: [
                .direct("Did you give insulin to any of those patients?", "\"No. I pulled insulin for patients who had orders, and sometimes other nurses asked me to. I never gave it to anyone who didn't need it.\""),
                .direct("Why did you edit the charts?", "\"I was correcting late entries at the end of a terrible shift, the way we're told to.\""),
                .cross("You were on duty for every single crash.", "\"I worked more nights than anyone on that unit. I was there for a lot of things.\""),
                .cross("Your edits deleted the insulin pulls.", "\"They deleted pulls that were scanned to the wrong patient.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, in your training, do healthcare killers tend to be well-liked nurses?\"",
                                  answer: "\"Very often, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Testimony that the defendant fits a profile of people who commit this crime is inadmissible character evidence.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "Four patients, one needle, and one nurse on every shift.",
            defenseOpening: "A hospital with shared badges, too few nurses, and a need for someone to blame.",
            prosecutionClosing: "The insulin came from a needle, the needle came from {DL}'s badge, and the records were erased by {DL}'s login.",
            defenseClosing: "Opportunity isn't proof. Nobody saw anything, and the badges were everyone's.",
            victim: VictimFacts(relationship: "A patient on the defendant's unit."),
            employer: "Hollis Regional Medical Center"
        )
    )

    // MARK: - 75. The coastal bodies (three women along Highway 17)

    static let coastalBodies = CaseTemplate(
        key: "story.coastalBodies", category: .violent,
        headlines: ["Architect Charged in Highway 17 Killings", "Pizza Crust DNA Links Suspect to Three Bodies Found Along the Coast"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 7, lesserThreshold: 5,
        specification: "With premeditation and deliberation, killed {V}, whose remains were found along Highway 17 near {HOOD}.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, whose remains were found a quarter mile from {V}'s.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC3}, whose remains were found in the same stretch of marsh.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "concealingDeath", specification: "Concealed the deaths of three women by wrapping their bodies in burlap and leaving them in the marsh.", chance: 1.0, threshold: 0)
        ],
        ageRange: 50...62, occupations: ["architect"], hasVictim: true,
        summaries: [
            "Thirteen years ago, the remains of three young women, each wrapped in burlap, were found within a mile of each other in the marsh along Highway 17 outside {HOOD}. The case went cold. Last year a new task force traced burner phones used to contact each woman to cell towers near an architecture firm in Port Hollis, and a witness's old description of a dark green pickup to a truck {D} owned at the time. Detectives pulled a pizza crust {DL} threw away outside {D.his} office; its DNA matched male DNA found on a hair in the burlap around {VL}'s body. {DL}, a married father of two with no record, says {D.he} never met any of the women and that the hair DNA is too degraded to trust."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Hair DNA", "Nuclear DNA from a hair in the burlap around {VL}'s body matches the DNA on {DL}'s discarded pizza crust, using whole-genome sequencing."),
            E(.digital, 3, "Burner Phones", "Burner phones that contacted all three women before they disappeared connected to towers near {DL}'s office and home, and were silent when {DL} was traveling."),
            E(.physical, 2, "Green Pickup", "DMV records show {DL} owned a dark green pickup at the time; a witness described a man in a green pickup with one of the women the night she vanished."),
            E(.digital, 2, "Search History", "Thousands of searches from {DL}'s accounts for news about the case and for images of the victims, years after the killings.", .search)
        ],
        defenseEvidence: [
            E(.forensic, 3, "Degraded Sample", "The hair was a rootless fragment; the whole-genome method has never been used in a North Carolina trial."),
            E(.document, 2, "Common Truck", "More than 2,000 dark green pickups of that model were registered in the four surrounding counties."),
            E(.document, 1, "Tower Coverage", "The towers near {DL}'s office also cover a hospital, a mall, and two apartment complexes.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic DNA scientist",
                        direct: ["\"The DNA matches {DL}.\""],
                        cross: ["\"The method is new.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you compare?", "\"DNA from the hair in the burlap around {VL}'s body against DNA from the pizza crust collected from {DL}'s trash. Using whole-genome sequencing, they match. The chance of a random unrelated match is less than one in several billion.\""),
                            .direct("Why whole-genome sequencing?", "\"The hair had no root. Traditional testing can't read rootless hair. Sequencing can read the fragments.\""),
                            .cross("This method has never been used in a North Carolina courtroom?", "\"Not in this state. It's been accepted in others.\""),
                            .cross("The sample was thirteen years old and degraded?", "\"It was degraded. We accounted for that.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Task force lead investigator",
                        direct: ["\"The phones follow {DL}.\""],
                        cross: ["\"Lots of people live near those towers.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the burner phones show?", "\"Burner phones called each woman before she vanished. Those phones connected to towers by {DL}'s office in the day and {DL}'s house at night. When {DL}'s credit cards put {D.him} in Atlanta for a conference, the phones went quiet.\""),
                            .direct("What else did you find?", "\"A dark green pickup registered to {DL} at the time, and years of searches for news about these killings and for the victims' photos.\""),
                            .cross("Those towers serve thousands of people?", "\"They do. Not thousands who went quiet on the same days {DL} traveled.\""),
                            .cross("You never recovered the burner phones?", "\"They were never found. Probably in a river somewhere.\""),
                            .cross("Thousands of people searched for news about a famous case?", "\"Not in the middle of the night for nine years.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense DNA expert",
                        direct: ["\"This hasn't been tested enough to bet a life on.\""],
                        cross: ["\"I didn't retest the sample.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What concerns you about the hair evidence?", "\"A thirteen-year-old rootless fragment, a method with no published error rate for samples this degraded, and a single lab that developed it and tested it. That's not how science earns trust.\""),
                            .cross("Did you retest the sample yourself?", "\"There wasn't enough left.\""),
                            .cross("Can you point to any error in the lab's analysis?", "\"I can point to the absence of validation.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s DNA was in the burlap, the burner phones followed {D.his} life, and {D.he} owned the truck a witness saw. For years {D.he} searched for news of {D.his} own crimes."],
        defenseTheory: ["An untested DNA method on a degraded hair, towers that cover half the county, and a truck thousands of people drove. A thirteen-year-old case wants an ending, not the truth."],
        aggravating: ["The offense involved multiple victims", "The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s mother: \"I set a place at Christmas for thirteen years. I'd like to know I can stop.\""],
        allocutions: ["\"I've never hurt anyone. I have a family. I'm asking you to look at the science.\""],
        guiltyTruths: ["A storage unit rented under an alias by {DL} was later found to contain burlap and jewelry belonging to one of the victims."],
        innocentTruths: ["A second hair from the same burlap, tested later by another lab, excluded {DL} and matched a man already in prison for a similar killing."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["VIC2": ["Brittany Caulder", "Jasmine Royal", "Kayla Oxendine"], "VIC3": ["Destiny Hales", "Amber Locklear", "Tiffany Gore"]],
        story: StoryExtras(
            timeline: [(0, "{VL}'s remains found wrapped in burlap in the marsh."),
                       (2, "Remains of {VIC2} and {VIC3} found nearby."),
                       (60, "Investigation stalls."),
                       (4400, "New task force formed; burner phone records reanalyzed."),
                       (4560, "Pizza crust collected from {DL}'s office trash."),
                       (4620, "Whole-genome DNA match reported."),
                       (4625, "{DL} arrested.")],
            howIdentified: "Burner phone records, a vehicle description, and DNA from discarded food.",
            notDone: ["Hairs from the other two victims' burlap were never tested."],
            defendantExam: [
                .direct("Did you know any of these women?", "\"No. I've never met them. I design schools and churches.\""),
                .direct("Why did you search for news about them?", "\"Everybody in this county followed this case. I followed it more after my daughter turned their age.\""),
                .cross("You searched their photos at 3 a.m., hundreds of times.", "\"I don't sleep. I read the news.\""),
                .cross("Your DNA was in the burlap.", "\"A method nobody has tested says so.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"You're paid by the defense to attack every new science, aren't you?\"",
                                  answer: "\"I'm paid for my time, like the State's expert.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "Payment is fair game, but this question argues with the witness instead of asking for facts.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "The DNA, the phones, and the truck all point to one man in an office in Port Hollis.",
            defenseOpening: "Thirteen years of pressure, and a science nobody in this state has ever tested.",
            prosecutionClosing: "Three women, one man's DNA, and nine years of {D.him} reading about it at night.",
            defenseClosing: "New science deserves skepticism when a life is on the line.",
            when: .yearsAgo(13),
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(relationship: "No known connection to the defendant."),
            employer: "an architecture firm in Port Hollis",
            family: "Married, 2 children.",
            yearsAtJob: 25
        )
    )

    // MARK: - 76. The cold case (genetic genealogy solves a 1986 double murder)

    static let coldCaseGenealogy = CaseTemplate(
        key: "story.coldCaseGenealogy", category: .violent,
        headlines: ["Arrest in 1980s Double Murder After Genealogy Match", "Retired Deputy Charged in Decades-Old Killings"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 7, lesserThreshold: 5,
        specification: "With premeditation and deliberation, killed {V} in {V.his} home on {STREET} in the 1980s.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, {V}'s spouse, in their home in the 1980s.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "burglary1", specification: "Broke and entered the occupied home of {V} at night in the 1980s with intent to commit murder.", chance: 1.0, threshold: 0)
        ],
        ageRange: 68...76, occupations: ["retired sheriff's deputy"], hasVictim: true,
        summaries: [
            "Nearly forty years ago, {V} and {VIC2} were bound and killed in their home on {STREET} in {HOOD}. A string of nighttime break-ins had terrorized the area for months. The case went cold for decades. Last year, investigators uploaded DNA from the crime scene to a public genealogy database, built a family tree from distant cousins, and narrowed it to {D}, now a retired Hollis County sheriff's deputy who lived four miles away at the time. A tissue {DL} threw away at a grocery store matched the crime scene DNA. {DL} says {D.he} has no memory of the people, that the old evidence was stored in a basement that flooded twice, and that the genealogy search was done without a warrant."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "DNA Match", "DNA from the crime scene matches DNA from a tissue {DL} discarded at a grocery store."),
            E(.document, 2, "Genealogy Tree", "A family tree built from distant cousins' uploads narrowed the source to one family and then to {DL}."),
            E(.document, 2, "Work Schedule", "Sheriff's Office records show {DL} was off duty on the nights of seven of the nine linked break-ins, including the murders."),
            E(.physical, 1, "Twine", "The victims were tied with a distinctive waxed twine of a type sold at the time by a supply store where {DL} had an account.")
        ],
        defenseEvidence: [
            E(.document, 2, "Evidence Storage", "The original evidence was stored in a courthouse basement that flooded twice; the chain of custody has gaps of years."),
            E(.document, 2, "No Warrant", "Investigators uploaded the crime scene profile to the genealogy site without a warrant or the site's permission for law enforcement use."),
            E(.document, 1, "Off-Duty Nights", "{DL} was off duty on roughly half of all nights that year.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Genetic genealogist",
                        direct: ["\"The tree leads to one man.\""],
                        cross: ["\"The site's rules didn't allow police uploads then.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you identify {DL}?", "\"The crime scene profile matched distant cousins on a public site. I built their family trees back to a shared set of great-great-grandparents, then forward again. Of the descendants, one man was the right age, lived nearby, and was there at the time.\""),
                            .direct("Is a genealogy match proof of identity?", "\"No. It's a lead. The confirmation comes from a direct DNA comparison.\""),
                            .cross("At the time, the site's terms didn't permit law enforcement uploads?", "\"The terms changed later. At the time, they didn't allow it.\""),
                            .cross("You didn't have a warrant?", "\"We didn't believe one was required for a public database.\"")
                        ]),
            WitnessSeed(name: nil, role: "SBI forensic scientist",
                        direct: ["\"The tissue matches the scene.\""],
                        cross: ["\"The basement flooded.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you compare?", "\"Semen from the original sexual assault kit and the bedding against DNA from a tissue collected from a grocery store trash can after {DL} used it. Full match at every location tested.\""),
                            .cross("The evidence sat in a basement that flooded twice?", "\"The kit was sealed in a box on an upper shelf. The seals were intact when we opened it.\""),
                            .cross("There are years with no entry in the chain of custody?", "\"There are gaps in the log. The seals are what matter.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Retired sheriff's deputy and former partner",
                        direct: ["\"I rode with {DL} for twelve years.\""],
                        cross: ["\"I didn't see {D.him} off duty.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What kind of deputy was {DL}?", "\"Steady. Calm on bad calls. I trusted {D.him} with my life for twelve years.\""),
                            .cross("You weren't with {DL} on nights off?", "\"We were partners on the clock. Off it, we went our separate ways.\""),
                            .cross("Did {DL} ever talk about the break-ins that year?", "\"Everybody did. {DL} wanted to be on the task force and wasn't picked.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s DNA was at the scene of a double murder, the break-ins came on {D.his} nights off, and the twine came from {D.his} supply store."],
        defenseTheory: ["A warrantless genealogy search, evidence from a flooded basement with a broken chain of custody, and a match with no other proof. Forty years is too long for certainty."],
        aggravating: ["The offense involved multiple victims", "The defendant abused a position of public trust"],
        mitigating: ["The defendant has a long record of public service"],
        victimImpacts: ["{VL}'s daughter, now 53: \"I was fourteen and asleep down the hall. I've waited my whole adult life to say their names in this room.\""],
        allocutions: ["\"I served this county for thirty years. I don't know how my DNA got there.\""],
        guiltyTruths: ["A box of victims' jewelry from several of those old break-ins was found in {DL}'s attic after the trial."],
        innocentTruths: ["The genealogist later found an error in one branch of the tree; a cousin of {DL}'s, now dead, also fit the profile."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "searchSeizure", "chainOfCustody"],
        extras: ["VIC2": ["Harold Tisdale", "Ruth Tisdale", "Gene Albritton"]],
        story: StoryExtras(
            timeline: [(-180, "Series of nighttime break-ins in {HOOD} begins."),
                       (0, "{VL} and {VIC2} killed in their home."),
                       (13870, "Crime scene profile uploaded to a genealogy site."),
                       (13930, "Family tree narrowed to {DL}."),
                       (13945, "Discarded tissue collected; DNA match."),
                       (13950, "{DL} arrested.")],
            howIdentified: "Genetic genealogy and a discarded tissue.",
            notDone: ["The twine was never compared at the fiber level.", "Other men in the tree's narrowed branch were never excluded by DNA."],
            defendantExam: [
                .direct("Were you ever in that house?", "\"Not that I know of. I answered hundreds of calls that year.\""),
                .direct("Where were you the night of the murders?", "\"I don't know. It was almost forty years ago. I was probably home with my wife.\""),
                .cross("Your DNA was on their bedding.", "\"I can't explain it. I'm not going to make something up.\""),
                .cross("You wanted on the break-in task force and weren't picked.", "\"So did half the department.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"Isn't it true the evidence room was so badly run that your lab once tested the wrong kit in another case?\"",
                                  answer: "\"That was a different county and a different decade.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "Prior handling errors bear on the reliability of chain of custody, which the defense has put squarely at issue.",
                                  doctrineID: "chainOfCustody", weight: 0))
            ],
            prosecutionOpening: "Nearly forty years ago someone tied up two people and killed them. Science finally named him.",
            defenseOpening: "A broken chain of custody, a warrantless search, and nothing else.",
            prosecutionClosing: "The DNA doesn't age, and it doesn't lie.",
            defenseClosing: "If you can't trust the box, you can't trust what came out of it.",
            when: .yearsAgo(39),
            genders: ["D": .male],
            victim: VictimFacts(relationship: "No known connection; the defendant lived four miles away.")
        )
    )

    // MARK: - 77. The truck stop killer (two women, two truck stops)

    static let truckStopKiller = CaseTemplate(
        key: "story.truckStopKiller", category: .violent,
        headlines: ["Long-Haul Trucker Charged in Two Truck Stop Killings", "GPS Logs Put Driver at Both Scenes"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 9, lesserThreshold: 7,
        specification: "With premeditation and deliberation, killed {V}, whose body was found behind a truck stop on I-40 near {HOOD}.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, whose body was found behind a truck stop on I-95.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "kidnapping1", specification: "Kidnapped {V} by confining {V.him} in the sleeper cab of a tractor-trailer.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "kidnapping1", specification: "Kidnapped {VIC2} by confining the victim in the sleeper cab of a tractor-trailer.", chance: 1.0, threshold: 0)
        ],
        ageRange: 40...58, occupations: ["long-haul truck driver"], forcedPriorOffenses: ["Assault on a Female@20"], hasVictim: true,
        summaries: [
            "Seven months apart, two women who hitchhiked from truck stops were found strangled behind truck stops in North Carolina: {V}, 23, behind a stop on I-40 near {HOOD}, and {VIC2}, 29, behind one on I-95. Both had zip-tie marks on their wrists. The electronic logging device in {D}'s tractor-trailer puts {D.his} truck at both stops within an hour of each woman's last sighting. A zip tie of the same brand and an earring like one {VL} wore were found in {DL}'s sleeper cab. {DL} has a prior conviction for assault on a female. {DL} says thousands of trucks pass through those stops every day, that the zip ties are for securing loads, and that the earring was left by a different hitchhiker {D.he} gave a ride."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Electronic Logging Device", "{DL}'s truck logged a 47-minute stop at the I-40 truck stop the night {VL} vanished, and a 52-minute stop at the I-95 stop the night {VIC2} vanished."),
            E(.physical, 3, "Earring", "An earring in the sleeper cab matching the pair {VL}'s sister says {V.he} wore that night; the other was in {VL}'s ear.", .search),
            E(.physical, 2, "Zip Ties", "A bag of black zip ties of the same brand and width as the marks on both women's wrists.", .search),
            E(.video, 2, "Fuel Island Camera", "{VL} is seen walking toward the truck parking row at 1:14 a.m.; a tractor-trailer like {DL}'s leaves the row at 1:58 a.m.")
        ],
        defenseEvidence: [
            E(.document, 2, "Truck Traffic", "Each truck stop logs more than 1,500 trucks a day; investigators identified 300 trucks present during the relevant hours at the I-40 stop alone."),
            E(.forensic, 2, "No DNA in Cab", "No DNA from either woman was found in the sleeper cab."),
            E(.document, 1, "Common Zip Ties", "That brand of zip tie is sold at every truck stop on the East Coast.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s sister",
                        direct: ["\"That's my sister's earring.\""],
                        cross: ["\"They're from a mall kiosk.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What can you tell us about the earring?", "\"I bought my sister that pair for her birthday. Little silver moons with a blue stone. She had them on when she left.\""),
                            .cross("Those earrings were sold at mall kiosks all over the state?", "\"Probably. These were hers.\""),
                            .cross("How can you tell this one is hers and not an identical one?", "\"One of the stones was chipped. This one's chipped.\"")
                        ]),
            WitnessSeed(name: nil, role: "SBI agent",
                        direct: ["\"{DL}'s truck was at both stops when both women vanished.\""],
                        cross: ["\"Hundreds of trucks were there.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you identify {DL}'s truck?", "\"We pulled electronic logging data for every truck at the I-40 stop that night, about three hundred. Then we checked which of those trucks were also at the I-95 stop the night {VIC2} disappeared. One was. {DL}'s.\""),
                            .direct("What did you find in the cab?", "\"Zip ties matching the wrist marks, and an earring {VL}'s sister identified.\""),
                            .cross("No DNA from either woman in the cab?", "\"No. The cab had been cleaned.\""),
                            .cross("You can't say how the earring got there?", "\"I can say where it was found.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fellow trucker",
                        direct: ["\"Drivers give rides all the time.\""],
                        cross: ["\"I wasn't with {DL} those nights.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Do drivers pick up hitchhikers?", "\"It's against company rules and plenty of us do it anyway. People need rides. I've had a dozen in my cab over the years. Things get left behind.\""),
                            .cross("You weren't with {DL} on either night?", "\"Not either night. I was on the road myself.\""),
                            .cross("Do you zip-tie your passengers?", "\"Never had a reason to.\"")
                        ])
        ],
        prosecutionTheory: ["Of three hundred trucks at the first stop, only {D}'s was at the second. {D.His} cab held the victim's earring and the zip ties that bound both women."],
        defenseTheory: ["A common earring, common zip ties, and a truck route through two of the busiest truck stops in the state. No DNA, no witness, no confession."],
        aggravating: ["The offense involved multiple victims", "The offense was especially heinous, atrocious, or cruel"],
        mitigating: [],
        victimImpacts: ["{VL}'s sister: \"She was trying to get home to her son. She was twenty-three.\""],
        allocutions: ["\"I've given rides to a lot of people. I never hurt any of them.\""],
        guiltyTruths: ["A third woman, who escaped from a sleeper cab two years earlier, later identified {DL} from a photo array."],
        innocentTruths: ["A second driver whose logging device had been tampered with was later found to have been at both stops, and was linked by DNA to a third killing."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        extras: ["VIC2": ["Crystal Faircloth", "Jade Spivey", "Misty Hollowell"]],
        story: StoryExtras(
            timeline: [(-210, "{VIC2} last seen at an I-95 truck stop; found strangled the next day."),
                       (0, "{VL} last seen at an I-40 truck stop; found strangled behind it the next morning."),
                       (20, "Logging data for 300 trucks requested."),
                       (65, "{DL}'s truck identified at both stops."),
                       (70, "Search warrant for the tractor-trailer; earring and zip ties seized."),
                       (72, "{DL} charged.")],
            howIdentified: "Cross-matching electronic logging data from both truck stops.",
            notDone: ["The fuel island video was never enhanced to read the trailer number."],
            defendantExam: [
                .direct("Did you give {VL} a ride?", "\"I don't know. I've given rides to a lot of people at that stop. I don't remember faces from a year ago.\""),
                .direct("Why do you have zip ties?", "\"For tarps and load straps. Every driver does.\""),
                .cross("Of three hundred trucks, yours is the only one at both stops.", "\"I run that route every week. Of course I was at both.\""),
                .cross("You have a prior conviction for assaulting a woman.", "\"An argument with my ex twenty years ago. I served my time.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Agent, did {DL}'s prior conviction influence your investigation?\"",
                                  answer: "\"It showed {D.he} had a history of violence against women.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character evidence", shouldSustain: true,
                                  explanation: "The prior assault can't be offered to show a propensity for violence against women under Rule 404(b).",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "Three hundred trucks at one stop. One of them also at the other. And a dead woman's earring in its cab.",
            defenseOpening: "A busy route, common zip ties, and an earring from a mall kiosk.",
            prosecutionClosing: "Coincidence doesn't explain an earring from a dead woman's ear.",
            defenseClosing: "Without DNA or a witness, the State has a truck route and a hunch.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(relationship: "No known connection to the defendant.", family: "Single, one child, a son.")
        )
    )

    // MARK: - 78. The college house (four students killed in one night)

    static let collegeHouse = CaseTemplate(
        key: "story.collegeHouse", category: .violent,
        headlines: ["Four Hollis State Students Killed in Off-Campus House", "Knife Sheath DNA Leads to Graduate Student's Arrest"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 9, lesserThreshold: 7,
        specification: "With premeditation and deliberation, killed {V}, a student, in a house on {STREET}.",
        secondary: [
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC2}, a student, in the same house.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC3}, a student, in the same house.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "murder1", specification: "With premeditation and deliberation, killed {VIC4}, a visiting student, in the same house.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "burglary1", specification: "Broke and entered the occupied house on {STREET} at night with intent to commit murder.", chance: 1.0, threshold: 0)
        ],
        ageRange: 26...30, occupations: ["criminology graduate student"], hasVictim: true,
        summaries: [
            "At about 4 a.m. on {DATE}, four Hollis State University students were stabbed to death in a rented house on {STREET} in {HOOD}: {V}, {VIC2}, {VIC3}, and {VIC4}. Two roommates on the ground floor survived; one saw a masked figure with bushy eyebrows walk past a bedroom door. A tan leather knife sheath left on a bed held touch DNA that, through genetic genealogy and a trash pull from {D.his} family's home, matched {D}, a criminology graduate student at a university an hour away. Phone records show {DL}'s phone near the house on twelve earlier nights, and a white sedan like {DL}'s circled the block that night. {DL} says {D.he} was driving alone that night looking at the stars, and that touch DNA can transfer without contact."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Knife Sheath DNA", "Touch DNA on the snap of a knife sheath found on a victim's bed matches {DL}."),
            E(.digital, 3, "Phone Records", "{DL}'s phone connected to towers near the house on twelve nights in the prior four months, and went dark from 2:47 to 4:48 a.m. the night of the killings."),
            E(.video, 2, "Neighborhood Cameras", "A white sedan of the same make as {DL}'s passes the house four times between 3:29 and 4:20 a.m."),
            E(.statement, 2, "Surviving Roommate", "A roommate saw a masked figure \"with bushy eyebrows\" walk past the roommate's bedroom door toward the sliding door at about 4:17 a.m.")
        ],
        defenseEvidence: [
            E(.forensic, 2, "Touch DNA", "Touch DNA can transfer secondhand; no blood or DNA of the victims was found in {DL}'s car, apartment, or family home."),
            E(.forensic, 2, "Unknown DNA", "Unidentified male DNA from three other people was found in the house and on a glove outside."),
            E(.document, 1, "Common Car", "That sedan model was among the most common in the region.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Surviving roommate",
                        direct: ["\"A masked person walked right past me.\""],
                        cross: ["\"I'd been drinking.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see that night?", "\"I heard crying and someone saying 'there's someone here.' I opened my door and saw a person in black with a mask over the mouth and nose walk past toward the back door. I froze. I locked my door.\""),
                            .direct("What do you remember about the person?", "\"Bushy eyebrows. Tall, not very muscular, athletic. That's all.\""),
                            .cross("You'd been drinking that night?", "\"Some. I knew what I saw.\""),
                            .cross("You couldn't see the face?", "\"Only the eyebrows.\""),
                            .cross("You didn't call 911 for hours?", "\"I thought I was dreaming. I texted my roommate. I was in shock.\"")
                        ]),
            WitnessSeed(name: nil, role: "SBI forensic scientist",
                        direct: ["\"The DNA on the sheath is {DL}'s.\""],
                        cross: ["\"Touch DNA can transfer.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find on the sheath?", "\"A single-source male profile on the button snap. It matches {DL} at every location. The chance of a random match is about one in five octillion.\""),
                            .cross("Touch DNA can be transferred without the person touching the object?", "\"Secondary transfer is possible.\""),
                            .cross("You found no victim blood in {DL}'s car or homes?", "\"Not a trace of {V.his}. We swabbed everything.\""),
                            .cross("You found three other male profiles in the house you haven't identified?", "\"Three unknowns. They're still unknown.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense cell-phone expert",
                        direct: ["\"The phone never pinged the house that night.\""],
                        cross: ["\"It was off or offline.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Where was {DL}'s phone during the killings?", "\"Nowhere. It went off the network at 2:47 and came back at 4:48, south of town. There's no record placing it at the house that night.\""),
                            .cross("The phone going dark for exactly the window of the killings is consistent with turning it off?", "\"It's consistent with that, or with no signal.\""),
                            .cross("The phone was near the house on twelve earlier nights?", "\"That's what the records show.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s DNA was on the sheath left beside a victim, {D.his} car circled the house, and {D.his} phone went dark for exactly the two hours of the killings after twelve earlier visits."],
        defenseTheory: ["Touch DNA that can transfer without contact, three unidentified men's DNA in the house, no blood anywhere {DL} lived or drove, and a common car. The State has a profile, not proof."],
        aggravating: ["The offense involved multiple victims", "The offense was especially heinous, atrocious, or cruel"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s father: \"Four families are sitting in this room. Every holiday since, there has been an empty chair.\""],
        allocutions: ["\"I didn't know them. I didn't kill them.\""],
        guiltyTruths: ["The knife that fit the sheath was later found in a storage unit rented by {DL}'s relative, with a victim's blood in the handle seam."],
        innocentTruths: ["One of the three unidentified profiles in the house was later matched to a man with a history of stalking one of the victims."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["VIC2": ["Madison Kerr", "Ethan Ruiz", "Kaylee Monroe"], "VIC3": ["Xavier Kendall", "Brooke Haney", "Logan Pruitt"], "VIC4": ["Ava Delacroix", "Owen Bates", "Chloe Rand"]],
        story: StoryExtras(
            timeline: [(-120, "First of twelve nights {DL}'s phone connects near the house."),
                       (0, "About 4:00–4:20 a.m.: four students killed; a white sedan circles the block."),
                       (0, "Noon: 911 call from the house."),
                       (30, "Sheath DNA uploaded for genetic genealogy."),
                       (40, "Trash pull at {DL}'s family home confirms the match."),
                       (47, "{DL} arrested.")],
            howIdentified: "Touch DNA on a knife sheath, genetic genealogy, and a family trash pull.",
            notDone: ["The three other male profiles were never identified.", "The knife was never found."],
            defendantExam: [
                .direct("Where were you that night?", "\"Driving. I couldn't sleep, so I drove out to the country to look at the stars. I do it a lot.\""),
                .direct("How did your DNA get on the sheath?", "\"I don't know. I've never seen that sheath. DNA moves.\""),
                .cross("Your phone was near that house twelve times before.", "\"It's a college town. I drove through it.\""),
                .cross("Your phone went dark for two hours that night.", "\"There's no signal out where I go.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Did the person you saw look like the defendant sitting right there?\"",
                                  answer: "\"The eyebrows do.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Suggestive in-court identification", shouldSustain: false,
                                  explanation: "The witness may describe what the witness saw and compare features; the reliability of the comparison is for cross-examination and the factfinder.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Four students, a knife sheath beside one of them, and the defendant's DNA on its snap.",
            defenseOpening: "A crime this terrible demands certainty. Touch DNA isn't certainty.",
            prosecutionClosing: "Twelve visits, one sheath, and two dark hours.",
            defenseClosing: "Three men in that house are still unknown. The State stopped looking.",
            genders: ["D": .male],
            victim: VictimFacts(occupation: "Student at Hollis State University", relationship: "No known connection to the defendant."),
            school: "East Carolina University (graduate program in criminology)"
        )
    )
}
