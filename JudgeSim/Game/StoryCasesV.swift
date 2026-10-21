import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchV: [CaseTemplate] = [wrongWayDriver, copperTheft, daycareCameras, sheriffEvidenceMoney, catfishMeetup]

    // MARK: - 119. The wrong way (a drunk driver on the interstate)

    static let wrongWayDriver = CaseTemplate(
        key: "story.wrongWayDriver", category: .traffic,
        headlines: ["Wrong-Way Driver Kills Mother and Daughter on I-95", "Driver's Blood Alcohol Three Times Legal Limit, Troopers Say"],
        primaryLaw: "murder2", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Unlawfully and with malice killed {V} by driving while impaired the wrong way on Interstate 95, with three prior impaired driving convictions.",
        secondary: [
            SecondaryCharge(lawID: "murder2", specification: "Unlawfully and with malice killed {KID}, age 9, a passenger in {V}'s car.", chance: 1.0, threshold: 0),
            // Felony death by vehicle isn't a lesser included offense of second-degree murder; the State charges it separately.
            SecondaryCharge(lawID: "felonyDBV", specification: "Unintentionally caused the death of {V} while driving while impaired on Interstate 95.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "habitualDWI", specification: "Drove while impaired after three prior impaired driving convictions within ten years.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "dwlrImpaired", specification: "Drove while license revoked for impaired driving.", chance: 1.0, threshold: 0)
        ],
        ageRange: 33...52, occupations: ["restaurant cook", "warehouse supervisor", "roofing contractor"], forcedPriorOffenses: ["Driving While Impaired@3", "Driving While Impaired@6", "Driving While Impaired@8"], hasVictim: true,
        summaries: [
            "At 1:52 a.m. on {DATE}, 911 operators took eleven calls about a pickup driving south in the northbound lanes of Interstate 95 near the {HOOD} exit. Four minutes later it hit {V}'s sedan head-on at a combined speed of about 130 mph. {VL} and her daughter, {KID}, 9, died at the scene. {D} survived with a broken pelvis. {D.His} blood alcohol was 0.25 at the hospital. {D.His} license had been revoked after {D.his} third impaired driving conviction, and a court had ordered an ignition interlock device; the pickup belonged to a friend and had none. Because of {D.his} prior convictions and the circumstances, the district attorney charged second-degree murder, which requires malice."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Blood Alcohol", "BAC 0.25 from a hospital draw under a search warrant.", .search),
            E(.document, 3, "Prior Convictions and Warnings", "Three prior DWI convictions; at each, a judge warned in writing that impaired driving can kill and lead to a murder charge."),
            E(.statement, 2, "911 Calls", "Eleven callers over four minutes; one says the pickup flashed its lights at oncoming cars and kept going."),
            E(.forensic, 2, "Event Data Recorder", "The pickup at 74 mph with no braking before impact.")
        ],
        defenseEvidence: [
            E(.document, 2, "Confusing Interchange", "Three prior wrong-way entries at the same exit ramp, and a state DOT memo recommending better signs."),
            E(.statement, 1, "No Memory", "{DL} has no memory after leaving a bar at 12:40 a.m."),
            E(.document, 1, "Treatment History", "{DL} completed two court-ordered treatment programs.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Highway Patrol reconstructionist",
                        direct: ["\"No brakes, 74 mph, wrong way.\""],
                        cross: ["\"That ramp has had wrong-way entries.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What happened in the last seconds?", "\"The pickup traveled 3.8 miles in the wrong direction. Oncoming cars swerved around it. It never slowed. At impact it was at 74 mph with no brake application.\""),
                            .cross("The exit ramp has had three earlier wrong-way entries?", "\"Yes. All three by impaired drivers.\"")
                        ]),
            WitnessSeed(name: nil, role: "District court clerk",
                        direct: ["\"Every judgment carried the warning.\""],
                        cross: ["\"It's a form.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the records show about {DL}'s prior DWIs?", "\"Three certified judgments, and assessment and treatment records from each one. Every program covered how impaired driving kills people.\""),
                            .cross("Those are standard records?", "\"Standard, and certified. Three times over.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Traffic engineer",
                        direct: ["\"The signage is inadequate.\""],
                        cross: ["\"A sober driver wouldn't miss it.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What's wrong with the interchange?", "\"The off-ramp and on-ramp sit side by side with a single small sign. The DOT knew and planned new signs.\""),
                            .cross("Would a sober driver miss it?", "\"Very unlikely.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was warned three times, lost {D.his} license, drove a friend's truck to dodge the interlock, and drank to 0.25. Driving the wrong way at 74 mph after that is the depraved indifference that makes second-degree murder."],
        defenseTheory: ["{DL} is guilty of felony death by vehicle, and accepts it. Malice requires more than prior convictions. A dangerous interchange and blackout drunkenness aren't a choice to kill."],
        aggravating: ["The offense involved multiple victims", "The victim was very young", "The defendant knowingly created a great risk of death to more than one person"],
        mitigating: ["The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s husband: \"They were driving home from her mother's. I was asleep. A trooper knocked on my door at four in the morning.\""],
        allocutions: ["\"I've ruined everything I touched. I killed a mother and a little girl. I don't deserve to walk out of here.\""],
        guiltyTruths: ["The bartender later produced a text {DL} sent at 12:35 a.m.: \"I'm good to drive, been doing it drunk for years.\""],
        innocentTruths: ["Toxicology later found {DL} had been given a sedative in a drink at the bar by someone else, and witnesses said {D.he} had asked a friend to drive {D.him} home."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["KID": ["Lily", "Ava", "Maya"]],
        story: StoryExtras(
            timeline: [(-2900, "First DWI conviction."),
                       (-1100, "Third DWI conviction; license revoked; interlock ordered."),
                       (0, "12:40 a.m.: {DL} leaves a bar."),
                       (0, "1:52 a.m.: first 911 call about a wrong-way pickup."),
                       (0, "1:56 a.m.: head-on collision."),
                       (0, "3:10 a.m.: hospital blood draw under warrant."),
                       (21, "{DL} indicted for second-degree murder.")],
            howIdentified: "{DL} was the driver, found in the pickup.",
            notDone: ["The friend who lent the pickup was not charged."],
            defendantExam: [
                .direct("Do you remember the drive?", "\"No. I remember the bar. Then the hospital.\""),
                .direct("Why were you driving?", "\"I don't know. I'd told myself I'd never do it again.\""),
                .cross("You signed a warning three times that you could kill someone.", "\"I know.\""),
                .cross("You borrowed a truck without an interlock.", "\"I borrowed it. It didn't have one.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How many lives do drunk drivers take in North Carolina each year?\"",
                                  answer: "\"About four hundred.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Relevance; unfair prejudice", shouldSustain: true,
                                  explanation: "Statewide statistics say nothing about this defendant's mental state and invite punishment for others' conduct.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Three warnings, a revoked license, a borrowed truck, and 3.8 miles the wrong way.",
            defenseOpening: "A terrible crime, and felony death by vehicle. Not murder.",
            prosecutionClosing: "{D.He} knew exactly what drunk driving does. {D.He}'d signed it three times.",
            defenseClosing: "Recklessness is not malice.",
            genders: ["V": .female]
        )
    )

    // MARK: - 120. The substation (a copper theft that killed a partner)

    static let copperTheft = CaseTemplate(
        key: "story.copperTheft", category: .property,
        headlines: ["Man Electrocuted Stealing Copper From Substation; Partner Charged", "Copper Thieves Hit Power Substation, Cutting Power to 4,000"],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 10, lesserThreshold: 8,
        specification: "Took and carried away copper grounding wire worth $2,800 from a Tidewater Power & Light substation, intending to permanently deprive the owner of it.",
        secondary: [
            SecondaryCharge(lawID: "invManslaughter", specification: "Unlawfully caused the death of {V}, the defendant's partner, by culpable negligence in leading him into an energized substation at night.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Damaged substation equipment, causing a power outage to 4,000 customers and $180,000 in repairs.", chance: 1.0, threshold: 0)
        ],
        ageRange: 26...44, occupations: ["unemployed electrician's helper", "scrap metal collector"], hasVictim: true,
        summaries: [
            "Just after midnight on {DATE}, {D} and {V} cut through the fence of a power substation on the edge of {HOOD} with bolt cutters to steal copper grounding wire. {DL}, who had worked as an electrician's helper, told {VL} which wires were \"dead.\" One wasn't. {VL} was electrocuted when he cut a cable connected to an energized transformer. The arc flash knocked out power to 4,000 homes, including a nursing home on oxygen machines. {DL} dragged {VL} to the truck, drove him to the hospital, and left before police arrived. Investigators found 300 pounds of copper in the truck bed and {DL}'s fingerprints on the bolt cutters. {DL} admits the theft but says {VL} chose to come and chose the wire."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Copper in Truck", "300 pounds of stripped copper grounding wire in {DL}'s truck, matching cut ends at the substation.", .search),
            E(.forensic, 3, "Prints on Bolt Cutters", "{DL}'s fingerprints on bolt cutters left at the fence.", .search),
            E(.video, 2, "Substation Camera", "Two figures cutting the fence; one points at equipment while the other cuts."),
            E(.document, 2, "Outage Report", "4,000 customers without power for six hours, including a nursing home that moved residents onto backup oxygen.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Victim's Experience", "{VL} had stolen copper before and knew substations were dangerous."),
            E(.statement, 1, "Took Him to the Hospital", "{DL} drove {VL} to the emergency room."),
            E(.document, 1, "Scrap Prices", "Copper prices had tripled; both men were out of work.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Utility safety engineer",
                        direct: ["\"That cable carried 23,000 volts.\""],
                        cross: ["\"There were warning signs everywhere.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did {VL} cut?", "\"A grounding cable bonded to an energized transformer case during a fault. Twenty-three thousand volts found a path through him.\""),
                            .direct("Could someone with electrical experience tell live from dead wire?", "\"Not without meters and training. Someone told him it was safe. It wasn't.\""),
                            .cross("There were danger signs on the fence?", "\"Every ten feet.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator",
                        direct: ["\"{D.He} pointed, {V.he} cut.\""],
                        cross: ["\"{D.He} took {V.him} to the hospital.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the camera show?", "\"One man pointing to equipment while the other cuts. {DL}'s height and jacket match the one pointing.\""),
                            .cross("{DL} drove {VL} to the hospital?", "\"Then left before we got there.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Victim's cousin",
                        direct: ["\"{V.He} did this before.\""],
                        cross: ["\"{V.He} trusted {DL} about wires.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Had {VL} stolen copper before?", "\"A few times, from empty houses. {V.He} knew it was risky.\""),
                            .cross("Did {VL} rely on {DL} to know which wires were safe?", "\"{V.He} said {DL} knew electric.\"")
                        ])
        ],
        prosecutionTheory: ["{D} led a man into a live substation, told him which wire was safe, and was wrong. That's culpable negligence, on top of a theft that blacked out four thousand homes."],
        defenseTheory: ["{DL} admits the larceny. {VL} was an adult who chose to break into a substation. Two people committing a crime together don't make one of them guilty of the other's death."],
        aggravating: ["The defendant knowingly created a great risk of death to more than one person"],
        mitigating: ["{DL} sought medical help for the victim"],
        victimImpacts: ["{VL}'s mother: \"He died for a truckload of scrap copper.\""],
        allocutions: ["\"He was my best friend. I told him it was dead. I'll never forgive myself.\""],
        guiltyTruths: ["A text from {DL} to a scrap buyer the day before read: \"got a guy who'll do the cutting, I'll do the pointing.\""],
        innocentTruths: ["The utility later found the transformer had a fault that morning that energized cables normally dead, something no one outside the utility could know."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-14, "{DL} and {VL} scout the substation."),
                       (0, "12:10 a.m.: fence cut."),
                       (0, "12:24 a.m.: arc flash; power out to 4,000 homes."),
                       (0, "12:51 a.m.: {VL} dropped at the emergency room; pronounced dead."),
                       (1, "Truck found with copper; {DL} arrested.")],
            howIdentified: "The truck seen leaving the hospital, and prints on the bolt cutters.",
            notDone: ["The scrap buyer was never charged."],
            defendantExam: [
                .direct("Did you tell {VL} the wire was safe?", "\"I told him the ones I thought were grounds. I thought they were dead. I'd seen them done before.\""),
                .direct("Why did you leave the hospital?", "\"I panicked. I knew I'd be arrested.\""),
                .cross("You don't have an electrician's license.", "\"No. I was a helper.\""),
                .cross("You pointed and he cut.", "\"I pointed. He's the one with the knife.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How many people died during the outage?\"",
                                  answer: "\"None that we know of.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Relevance; unfair prejudice", shouldSustain: false,
                                  explanation: "The scope of the outage bears on the injury to real property count and the aggravating factor of great risk to others.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Bolt cutters, a live substation, and a man who said he knew which wire was dead.",
            defenseOpening: "A theft, admitted. A friend's death, mourned. Not manslaughter.",
            prosecutionClosing: "He took responsibility for knowing the wires. That's what makes it his.",
            defenseClosing: "Two men chose a crime. Only one chose to cut.",
            genders: ["D": .male, "V": .male],
            victim: VictimFacts(relationship: "The defendant's partner in the theft and a longtime friend.")
        )
    )

    // MARK: - 121. The nap room (a daycare teacher on camera)

    static let daycareCameras = CaseTemplate(
        key: "story.daycareCameras", category: .family,
        headlines: ["Parent App Video Shows Daycare Teacher Striking Toddlers", "Three Children Hurt; Teacher Charged With Felony Child Abuse"],
        primaryLaw: "felonyChildAbuse", lesserLaw: "childAbuseMisd", threshold: 11, lesserThreshold: 9,
        specification: "Intentionally inflicted serious physical injury on {KID}, age 2, a child in her care, by throwing him into a crib, fracturing his collarbone.",
        secondary: [
            SecondaryCharge(lawID: "childAbuseMisd", specification: "Inflicted physical injury on {KID2}, age 2, by slapping her on the face and pulling her hair.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "childAbuseMisd", specification: "Inflicted physical injury on {KID3}, age 1, by forcefully holding a blanket over her face to stop her crying.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Turned the nap room camera to face the wall on three occasions.", chance: 1.0, threshold: 0)
        ],
        ageRange: 23...35, occupations: ["daycare teacher"], hasVictim: false,
        summaries: [
            "On {DATE}, a mother checking the livestream app of a daycare in {HOOD} watched her son's teacher, {D}, throw him into a crib during nap time. She called police from her desk. Investigators reviewed three weeks of saved video from the toddler room: {DL} slapping a girl and pulling her hair, holding a blanket over a crying baby's face for eleven seconds, and, on three days, turning the camera toward the wall. The boy, {KID}, had a broken collarbone. {DL} had worked with the toddlers for eight months with no complaints. {DL} says she was handling eight toddlers alone, double what state ratios allow, and lost control on one bad day."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Nap Room Video", "Saved livestream video: {DL} throwing {KID} into a crib; slapping {KID2}; holding a blanket over {KID3}'s face.", .search),
            E(.forensic, 3, "Medical Records", "{KID}'s fractured right collarbone, consistent with being thrown."),
            E(.video, 2, "Camera Turned", "Three clips of {DL} turning the camera to the wall, then turning it back an hour later."),
            E(.statement, 2, "Co-Worker", "A co-worker says {DL} called the children \"little monsters\" and said \"nobody watches the nap camera.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Staffing Ratios", "Daycare records show {DL} alone with eight toddlers, double the state limit, on most afternoons."),
            E(.statement, 1, "No Prior Complaints", "No complaints in eight months."),
            E(.document, 1, "Stress", "{DL} had asked the director twice for help in the toddler room.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Mother who saw the livestream",
                        direct: ["\"I watched her throw my son.\""],
                        cross: ["\"I'd never seen anything before.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did you see?", "\"She picked him up by one arm and threw him into the crib. He hit the side and screamed. She walked away.\""),
                            .cross("You'd watched the app before and seen nothing wrong?", "\"Never. That's what scares me.\"")
                        ]),
            WitnessSeed(name: nil, role: "Pediatric child abuse specialist",
                        direct: ["\"That fracture takes force.\""],
                        cross: ["\"Toddlers fall.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the fracture show?", "\"A collarbone fracture in a two-year-old from impact against a crib rail. It takes real force. It matches the video.\""),
                            .cross("Toddlers fall all the time?", "\"They do. Not like that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former daycare assistant director",
                        direct: ["\"She was left alone with eight.\""],
                        cross: ["\"Understaffing doesn't explain the blanket.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How was the toddler room staffed?", "\"One teacher, eight toddlers, most afternoons. The owner wouldn't pay for a floater. We all complained.\""),
                            .cross("Does that explain holding a blanket over a baby's face?", "\"No. Nothing explains that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} hurt the children in her care and turned the camera to the wall so no one would see. The video shows it."],
        defenseTheory: ["{DL} was set up to fail by a daycare that broke the ratio laws. She lost control. The broken collarbone was not intended; it's misdemeanor abuse, not felony."],
        aggravating: ["The victim was very young", "The defendant took advantage of a position of trust", "The offense involved multiple victims"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{KID}'s mother: \"He won't take a nap anymore. He screams when we put him in his crib.\""],
        allocutions: ["\"I'm so sorry. I was overwhelmed and I took it out on babies. I'll never work with children again.\""],
        guiltyTruths: ["Deleted texts later recovered from {DL}'s phone showed {D.his} joking with a friend about \"shutting up the screamers.\""],
        innocentTruths: ["A neurologist later found the boy had a rare bone condition that makes fractures from ordinary handling more likely, though the other clips remained."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["KID": ["Owen", "Liam", "Noah"], "KID2": ["Emma", "Zoey", "Harper"], "KID3": ["Ella", "Nora", "Ruby"]],
        story: StoryExtras(
            timeline: [(-240, "{DL} begins in the toddler room."),
                       (-21, "First saved clip of the camera turned to the wall."),
                       (0, "1:20 p.m.: mother sees the livestream and calls police."),
                       (0, "{KID}'s collarbone fracture diagnosed."),
                       (2, "Three weeks of video reviewed; {DL} arrested.")],
            howIdentified: "A parent watching the daycare's livestream app.",
            notDone: ["The daycare owner was not charged over the ratio violations."],
            defendantExam: [
                .direct("What happened that afternoon?", "\"Eight toddlers, nobody to help, and he wouldn't stop screaming. I put him in the crib too hard. I didn't mean to hurt him.\""),
                .direct("Why turn the camera?", "\"So the parents wouldn't see the room was a mess.\""),
                .cross("You threw him by one arm.", "\"I'm not denying what's on the video.\""),
                .cross("And the blanket over the baby's face for eleven seconds?", "\"I don't know what I was thinking.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Did the owner ever tell her to hit children?\"",
                                  answer: "\"Of course not.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Argumentative", shouldSustain: false,
                                  explanation: "The question fairly tests the witness's suggestion that understaffing explains the conduct; it isn't argumentative.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A livestream, a broken collarbone, and a camera turned to the wall.",
            defenseOpening: "Eight toddlers, one teacher, and one terrible afternoon.",
            prosecutionClosing: "You don't turn the camera away from what you don't want seen by accident.",
            defenseClosing: "Abuse, yes. Intent to seriously injure, no.",
            genders: ["D": .female]
        )
    )

    // MARK: - 122. The evidence room (a sheriff takes seized cash)

    static let sheriffEvidenceMoney = CaseTemplate(
        key: "story.sheriffEvidenceMoney", category: .whiteCollar,
        headlines: ["Audit: $214,000 Missing From Sheriff's Seized Cash Account", "Former Sheriff Indicted; Accused of Spending Drug Money on Campaign and Cabin"],
        primaryLaw: "embezzlement100k", lesserLaw: "embezzlement", threshold: 11, lesserThreshold: 9,
        specification: "While sheriff, embezzled $214,000 in seized drug money held in trust in the Sheriff's Office evidence account.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Ordered the evidence clerk to falsify the seized property log to cover the withdrawals.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Threatened the evidence clerk with firing and prosecution to keep the clerk from telling state auditors about the withdrawals.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "bribery", specification: "Accepted $12,000 from a towing company in exchange for exclusive county towing referrals.", chance: 1.0, threshold: 0)
        ],
        ageRange: 52...64, occupations: ["former county sheriff"], hasVictim: false,
        summaries: [
            "A State Auditor's review of the Sheriff's Office found $214,000 missing from the account where cash seized in drug cases is held until the court orders it forfeited. On {DATE}, the former sheriff, {D}, who served four terms before losing the last election, was indicted. Bank records show cash withdrawals that line up with a down payment on a mountain cabin and campaign mailers. The evidence clerk, a 19-year employee, told auditors the sheriff ordered her to write \"returned to owner\" next to cases where no owner ever came. When she hesitated, she says, the sheriff told her, \"You can find another job, or you can find a lawyer.\" {DL} says the money was spent on drug investigations and confidential informants, as sheriffs are allowed, and the records were poorly kept."
        ],
        prosecutionEvidence: [
            E(.document, 3, "State Audit", "Forty-one cash withdrawals totaling $214,000 with no court order; 23 entries marked \"returned to owner\" with no owner signature."),
            E(.document, 3, "Bank Records", "Withdrawals within days of a $90,000 cabin down payment and $38,000 in campaign printing paid in cash."),
            E(.statement, 2, "Evidence Clerk", "The clerk's account of being ordered to falsify the log, and the threat."),
            E(.document, 2, "Towing Payments", "Checks from a towing company deposited to the sheriff's personal account.")
        ],
        defenseEvidence: [
            E(.document, 2, "Informant Fund Rules", "Sheriffs may use certain funds for confidential informant payments with limited documentation."),
            E(.statement, 1, "Clerk's Grudge", "The clerk was passed over for promotion the year before."),
            E(.document, 1, "Loan Records", "{DL} says the cabin money came from a family loan.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Evidence clerk",
                        direct: ["\"He told me to write 'returned to owner.'\""],
                        cross: ["\"I was passed over for promotion.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did the sheriff ask you to do?", "\"Write 'returned to owner' next to cash nobody ever claimed. When I asked who the owners were, he said, 'You can find another job, or you can find a lawyer.'\""),
                            .cross("You were passed over for promotion last year?", "\"Passed over, yes. I'm still telling the truth about that log.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Auditor's investigator",
                        direct: ["\"No court order for any of it.\""],
                        cross: ["\"Informant funds are loosely documented.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Were any of the withdrawals authorized?", "\"None had a court order. Seized cash can only leave that account by court order: forfeiture, or return to a real owner who signs for it.\""),
                            .cross("Informant payments are lightly documented?", "\"Those come from a different, budgeted fund. This was seized evidence.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former chief deputy",
                        direct: ["\"Informants get paid in cash.\""],
                        cross: ["\"Not from the evidence account.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How are informants paid?", "\"Cash, in the field. That's how it's always worked.\""),
                            .cross("From the seized evidence account?", "\"Not when I was there.\"")
                        ])
        ],
        prosecutionTheory: ["The county's chief law enforcement officer treated seized drug money as his own, had the books falsified, and threatened the clerk who knew."],
        defenseTheory: ["Sloppy records and a disgruntled clerk. Sheriffs have broad discretion over investigative spending; the State can't trace the cash to personal use."],
        aggravating: ["The defendant abused a position of public trust", "The offense involved the taking of property of great monetary value (G.S. 15A-1340.16(d)(14))"],
        mitigating: ["No prior criminal record", "The defendant has a long record of public service"],
        victimImpacts: ["A county commissioner: \"Every deputy in this county now has to explain to people that they aren't crooks.\""],
        allocutions: ["\"I served this county for twenty-six years. I made mistakes with paperwork. I never stole.\""],
        guiltyTruths: ["A ledger in the sheriff's desk, found later, tracked the withdrawals in his handwriting with the note \"pay back after election.\""],
        innocentTruths: ["The chief deputy later admitted making most of the withdrawals himself using the sheriff's signature stamp."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-900, "First unauthorized withdrawal."),
                       (-300, "Cabin down payment."),
                       (-120, "State Auditor begins review."),
                       (-90, "Clerk interviewed; says she was threatened."),
                       (0, "Former sheriff indicted.")],
            howIdentified: "A routine State Auditor review.",
            notDone: ["The chief deputy's accounts were never subpoenaed."],
            defendantExam: [
                .direct("Did you take the money?", "\"I used it for investigations. Buy money, informants, overtime for narcotics details. I didn't keep good enough records.\""),
                .direct("Did you threaten the clerk?", "\"I told her to do her job.\""),
                .cross("The cabin down payment was three days after a $40,000 withdrawal.", "\"Coincidence. My brother loaned me that money.\""),
                .cross("Your brother has no record of a loan.", "\"We're family. We don't write it down.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Isn't it true you wanted the sheriff's job yourself?\"",
                                  answer: "\"No.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Speculation; no good-faith basis", shouldSustain: false,
                                  explanation: "Asking about a witness's motive and bias is proper cross-examination, as long as counsel has a good-faith basis.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "Seized drug money, a mountain cabin, and a clerk told to write 'returned to owner.'",
            defenseOpening: "Bad bookkeeping by a career lawman, and a clerk with a grudge.",
            prosecutionClosing: "No court order. No owner. No excuse.",
            defenseClosing: "Proof of spending isn't proof of stealing.",
            genders: ["D": .male]
        )
    )

    // MARK: - 123. The meetup (an online date that became a kidnapping)

    static let catfishMeetup = CaseTemplate(
        key: "story.catfishMeetup", category: .robbery,
        headlines: ["Man Lured by Fake Dating Profile, Robbed and Held for Hours", "Three Charged in Dating App Kidnapping"],
        primaryLaw: "kidnapping1", lesserLaw: "kidnapping2", threshold: 10, lesserThreshold: 8,
        specification: "Unlawfully confined and restrained {V} for the purpose of committing robbery, and did not release him in a safe place.",
        secondary: [
            SecondaryCharge(lawID: "dangerousRobbery", specification: "Robbed {V} at gunpoint of his wallet, phone, and $2,600 withdrawn from ATMs.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "conspiracyRobbery", specification: "Agreed with two others to lure and rob a man through a fake dating profile.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "cardFraud", specification: "Used {V}'s debit card at three ATMs without permission.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...26, occupations: ["nail technician", "unemployed"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 31, drove to an apartment complex in {HOOD} to meet a woman he'd been messaging on a dating app for two weeks. When he got out of his car, two men put a gun to his head, forced him into the back seat, and drove him to three ATMs over four hours, then left him zip-tied in a field off a dirt road. The profile used photos stolen from a model's Instagram. The State says {D} ran the profile, wrote the messages, and planned the meeting place. {DL}'s phone sent the last message, \"I'm outside, come up,\" and the two men are {D.his} brother and cousin. {DL} says the brother used {D.his} phone and {D.he} never knew what they planned."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Dating App Records", "The profile was created and logged into from {DL}'s phone and home Wi-Fi; two weeks of messages.", .search),
            E(.video, 3, "ATM Cameras", "{VL} at three ATMs with a masked man beside him; a car registered to {DL}'s brother."),
            E(.digital, 2, "Group Chat", "A group chat between {DL}, the brother, and cousin: \"he's coming at 9, bring the ties.\"", .search),
            E(.statement, 2, "Cousin's Statement", "The cousin, cooperating, says {DL} picked the victims and ran the profiles.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Shared Phone", "Family members say the brother often used {DL}'s phone."),
            E(.document, 1, "Location", "{DL}'s workplace time clock shows {D.him} at the salon until 8:45 p.m."),
            E(.statement, 1, "Cousin's Deal", "The cousin pleaded to a lesser charge for testimony.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Victim",
                        direct: ["\"They put a gun to my head.\""],
                        cross: ["\"I never saw a woman.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened when you arrived?", "\"Two men came out from behind a van. One put a gun to my head. They zip-tied my hands and drove me around for four hours to ATMs. I thought they'd kill me in that field.\""),
                            .cross("You never saw a woman that night?", "\"I didn't see any woman.\"")
                        ]),
            WitnessSeed(name: nil, role: "Cousin (cooperating co-defendant)",
                        direct: ["\"{DL} ran the profiles.\""],
                        cross: ["\"I got a deal.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Who came up with the plan?", "\"{DL}. {D.He} made the profiles, picked guys with nice cars, and set up where to meet. We did the rest.\""),
                            .cross("You pleaded to a lesser charge for this testimony?", "\"Down to a misdemeanor. That's the deal.\""),
                            .cross("You held the gun?", "\"My cousin did.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Salon owner",
                        direct: ["\"{D.He} worked until close.\""],
                        cross: ["\"{D.He} was on {D.his} phone a lot.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where was {DL} that evening?", "\"At the salon until we closed at 8:45.\""),
                            .cross("Was {DL} on {D.his} phone during the day?", "\"Constantly.\"")
                        ])
        ],
        prosecutionTheory: ["{D} built the fake profile, groomed the victim for two weeks, and sent the message that brought him to the gun. {D.He} didn't need to be there; {D.he} planned it."],
        defenseTheory: ["{DL}'s brother used {D.his} phone. The only witness who blames {DL} is a cousin who got a deal. {DL} was at work."],
        aggravating: ["The defendant induced others to participate in the commission of the offense"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}: \"I don't answer messages from anybody now. I check every parking lot before I get out of my car.\""],
        allocutions: ["\"I didn't know they'd hurt him. I'm sorry.\""],
        guiltyTruths: ["A notebook in {DL}'s room, found later, listed four other men's names, car models, and \"meet spots.\""],
        innocentTruths: ["The brother later admitted in a recorded call that he set up the profile on {DL}'s phone without {D.his} knowledge."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-16, "Fake profile created on {DL}'s phone."),
                       (-14, "Messages with {VL} begin."),
                       (0, "8:58 p.m.: \"I'm outside, come up.\""),
                       (0, "9:05 p.m.: {VL} abducted at gunpoint."),
                       (0, "9:40 p.m.–12:50 a.m.: three ATM withdrawals."),
                       (1, "1:30 a.m.: {VL} found zip-tied in a field."),
                       (6, "{DL}, brother, and cousin arrested.")],
            howIdentified: "Dating app records and the brother's car on ATM video.",
            notDone: ["The other men on the notebook list were never contacted."],
            defendantExam: [
                .direct("Did you create the profile?", "\"No. My brother borrowed my phone all the time. He knew my passcode.\""),
                .direct("The group chat?", "\"They added me. I didn't read most of it.\""),
                .cross("'He's coming at 9, bring the ties.' You read that one.", "\"I didn't know what it meant.\""),
                .cross("You were off work at 8:45, and the last message was at 8:58.", "\"I was driving home.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"Your cousin is facing years in prison, isn't that right? And you just want to protect yourself?\"",
                                  answer: "\"I'm telling the truth.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Compound and argumentative", shouldSustain: true,
                                  explanation: "Two questions in one, the second argumentative; counsel can ask each separately.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A stolen photo, two weeks of messages, and one text: I'm outside, come up.",
            defenseOpening: "A shared phone and a cousin who made a deal.",
            prosecutionClosing: "Planning a kidnapping is committing one.",
            defenseClosing: "Using someone's phone doesn't make them guilty.",
            genders: ["D": .female, "V": .male]
        )
    )
}
