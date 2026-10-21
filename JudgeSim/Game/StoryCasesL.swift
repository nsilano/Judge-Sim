import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchL: [CaseTemplate] = [informantBuy, grandparentHouse, motorcycleChase, deletedFootage, exHouseKey]

    // MARK: - 69. The informant buy (a paid informant and a recorded sale)

    static let informantBuy = CaseTemplate(
        key: "story.informantBuy", category: .drugs,
        headlines: ["Undercover Buy Leads to Cocaine Sale Charge", "Defense Attacks Paid Informant's Credibility"],
        primaryLaw: "saleSchedII", lesserLaw: "possSchedII", threshold: 5, lesserThreshold: 3,
        specification: "Sold 3.4 grams of cocaine, a Schedule II controlled substance, to a confidential informant.",
        secondary: [
            SecondaryCharge(lawID: "possSchedII", specification: "Possessed cocaine, a Schedule II controlled substance.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "pwisd", specification: "Possessed cocaine with intent to sell or deliver.", chance: 1.0, threshold: 5)
        ],
        ageRange: 23...35, occupations: ["barber", "line cook"], forcedPriorOffenses: ["Possession of Schedule II (cocaine)@5"], hasVictim: false,
        summaries: [
            "On {DATE}, a paid confidential informant working with the Hollis County Sheriff's narcotics unit met {D} in the parking lot of a laundromat on {STREET} and, according to the informant, bought 3.4 grams of cocaine for $200 in marked bills. The informant wore an audio recorder; the video camera hidden in the informant's car pointed the wrong way. Deputies searched the informant before and after. {DL} was arrested two months later. {DL} says {D.he} met the informant to collect a $200 debt and that the informant had the cocaine all along. The informant has been paid $6,800 over two years and is hoping to get two pending felony charges reduced."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Lab Report", "3.4 grams of cocaine hydrochloride, confirmed by the State Crime Lab."),
            E(.digital, 2, "Audio Recording", "Seven minutes of audio: greetings, a car door, someone says \"that's two,\" and \"same as last time.\""),
            E(.document, 2, "Search of Informant", "Deputies documented searching the informant and the informant's car before and after the meeting."),
            E(.physical, 1, "Marked Bills", "Not recovered; {DL} was not arrested until two months later.")
        ],
        defenseEvidence: [
            E(.document, 3, "Informant's Payments and Charges", "$6,800 paid over two years, and two pending felony charges the informant hopes to have reduced."),
            E(.document, 2, "Search Gaps", "The 'after' search of the car didn't include the trunk or the area under the seats, per the deputy's own notes."),
            E(.digital, 1, "Debt Texts", "Texts from {DL} to the informant a week earlier: \"you still owe me 200.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Confidential informant",
                        direct: ["\"I bought it from {DL}.\""],
                        cross: ["\"I get paid per buy.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened in the parking lot?", "\"{DL} got in my passenger seat. I handed {D.him} the two hundred, {D.he} handed me a bag. {D.He} said, 'Same as last time.'\""),
                            .direct("What did you do after?", "\"Drove straight back to the deputies and gave them the bag.\""),
                            .cross("You've been paid $6,800 over two years?", "\"About that.\""),
                            .cross("You have two felony charges pending that you hope to reduce?", "\"I'm hoping. Nobody promised me anything.\""),
                            .cross("You owed {DL} $200, didn't you?", "\"Not anymore.\"")
                        ]),
            WitnessSeed(name: nil, role: "Narcotics deputy",
                        direct: ["\"We searched the informant before and after.\""],
                        cross: ["\"We didn't search the trunk.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How do you control a buy like this?", "\"We search the informant and the car before, give marked money, watch from a distance, and search again after.\""),
                            .direct("What did you see?", "\"{DL} get into the informant's car for about four minutes, then get out.\""),
                            .cross("You didn't search under the seats or the trunk?", "\"Not after. We checked the person and the front.\""),
                            .cross("The video camera was pointed at the dashboard?", "\"It got knocked. It happens.\""),
                            .cross("You didn't arrest {DL} for two months, and the marked bills were never found?", "\"We were protecting the informant's identity.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s coworker",
                        direct: ["\"{DL} was chasing that $200 for weeks.\""],
                        cross: ["\"I don't know what happened in the car.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} say about the informant?", "\"For weeks: 'That fool owes me two hundred.' When {D.he} finally got it, {D.he} bought lunch for the shop.\""),
                            .cross("You don't know what happened in the car?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["A controlled buy: the informant was searched, went in clean, came out with cocaine, and the recording catches 'that's two' and 'same as last time.'"],
        defenseTheory: ["A paid informant with pending charges, an incomplete search, a camera that conveniently missed everything, and a real $200 debt. The State's case is the word of someone paid to deliver cases."],
        aggravating: [],
        mitigating: ["The defendant has been gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"I went to get my money. That's all.\""],
        guiltyTruths: ["A second recorded buy from {DL}, by a different informant, surfaced in another county's case file."],
        innocentTruths: ["The informant was later caught planting drugs during a buy in another case and was decertified."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "entrapment"],
        story: StoryExtras(
            timeline: [(-7, "{DL} texts the informant about a $200 debt."),
                       (0, "Controlled buy in the laundromat parking lot."),
                       (3, "Substance submitted to the State Crime Lab."),
                       (30, "Lab confirms cocaine."),
                       (61, "{DL} arrested.")],
            howIdentified: "The informant named {DL} as a seller.",
            notDone: ["The informant's car was not fully searched after the buy.", "The marked bills were never recovered."],
            defendantExam: [
                .direct("Why did you get in the informant's car?", "\"To get my two hundred dollars. I'd lent it a month before. I've got the texts.\""),
                .direct("What does 'same as last time' mean?", "\"That they were late paying me back, same as last time.\""),
                .cross("You have a prior conviction for possessing cocaine.", "\"Possessing. Five years ago. I've never sold anything.\""),
                .cross("What did 'that's two' mean?", "\"Two hundred. The money.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Deputy, how reliable has this informant been in the past?\"",
                                  answer: "\"Very. Thirty-one buys, all good.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper bolstering", shouldSustain: true,
                                  explanation: "A party can't bolster its witness's credibility before it has been attacked on that point, and the deputy's opinion of reliability vouches for the informant.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "A controlled buy, recorded and documented, start to finish.",
            defenseOpening: "A paid informant, a debt, and a search that left the trunk unopened.",
            prosecutionClosing: "The informant went in clean and came out with cocaine.",
            defenseClosing: "You can't convict on the word of someone paid by the case."
        )
    )

    // MARK: - 70. The grandparent's house (whose house is it?)

    static let grandparentHouse = CaseTemplate(
        key: "story.grandparentHouse", category: .drugs,
        headlines: ["Grandparent Charged After Drug Raid on Family Home", "Was the House Hers, or Her Grandson's?"],
        primaryLaw: "maintainingDwelling", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Knowingly kept or maintained a dwelling on {STREET} that was resorted to by persons using or selling controlled substances.",
        ageRange: 71...78, occupations: ["retired school cafeteria manager"], hasVictim: false,
        summaries: [
            "On {DATE}, deputies executed a search warrant at {D}'s house on {STREET} in {HOOD} after weeks of complaints about short visits at all hours. They found 40 grams of cocaine, scales, and $3,100 in the back bedroom used by {DL}'s grandson, who pleaded guilty to trafficking. {D} owns the house and lives in the front bedroom. Deputies say neighbors complained to {DL} directly and that {D.he} told one, \"I can't control what grown folks do.\" {DL} says {D.he} never went into the back bedroom and had no idea what was happening."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Deed and Utilities", "{DL} owns the house and pays every utility bill."),
            E(.physical, 2, "Back Bedroom", "40 grams of cocaine, two scales, baggies, and $3,100 in the back bedroom.", .search),
            E(.statement, 2, "Neighbor's Complaint", "A neighbor told {DL} about cars coming and going all night; {DL} replied, \"I can't control what grown folks do.\""),
            E(.document, 1, "Traffic Log", "Deputies logged 23 short visits in four nights of surveillance.")
        ],
        defenseEvidence: [
            E(.document, 2, "Medical Records", "{DL} takes a prescribed sleep aid and hears poorly without hearing aids, which {D.he} removes at night."),
            E(.document, 2, "Separate Lock", "The back bedroom had a keyed lock; only the grandson had the key."),
            E(.document, 1, "Grandson's Plea", "In his guilty plea, the grandson said his grandparent \"didn't know nothing.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor across the street",
                        direct: ["\"I told {D.him} what was going on.\""],
                        cross: ["\"I didn't say 'drugs.'\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Cars pulling in at two, three in the morning, somebody running in, running out in two minutes. Every night for months.\""),
                            .direct("Did you talk to {DL}?", "\"I told {D.him} at the mailbox, 'You know what's going on at your house at night?' {D.He} said, 'I can't control what grown folks do.'\""),
                            .cross("You didn't use the word 'drugs'?", "\"I didn't have to.\""),
                            .cross("{DL} goes to bed early and doesn't hear well?", "\"{D.He}'s old. I know {D.he} doesn't hear well.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Narcotics detective",
                        direct: ["\"It's {DL}'s house, top to bottom.\""],
                        cross: ["\"The bedroom was locked.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Whose house is it?", "\"{DL}'s. Deed, power, water, cable. The grandson paid nothing.\""),
                            .direct("What did you find?", "\"In the back bedroom, forty grams, scales, baggies, and cash. In the kitchen, a box of baggies of the same brand.\""),
                            .cross("The back bedroom had a keyed lock?", "\"It did. We had to force it.\""),
                            .cross("Baggies in a kitchen are common?", "\"Very common.\""),
                            .cross("The grandson said {DL} didn't know?", "\"He did say that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s pastor",
                        direct: ["\"{DL} is in bed by nine.\""],
                        cross: ["\"I don't live there.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"Thirty years at our church. {DL} runs the food pantry. Bed by nine, up at five for prayer.\""),
                            .direct("Did {DL} ever talk about the grandson?", "\"Worried about him all the time. Took him in when no one else would.\""),
                            .cross("You don't know what happened at that house at night?", "\"No, I don't live there.\"")
                        ])
        ],
        prosecutionTheory: ["{D} owns the house, was told what was happening, and chose to do nothing. Knowingly allowing it is maintaining a dwelling."],
        defenseTheory: ["A grandparent in {D.his} seventies who sleeps with no hearing aids, a locked bedroom, and a grandson who confessed and cleared {D.him}. Not doing something isn't the same as knowing."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: [],
        allocutions: ["\"I took my grandbaby in so he wouldn't be on the street. I didn't know he brought the street with him.\""],
        guiltyTruths: ["The grandson later told a cellmate his grandparent counted the money with him some nights."],
        innocentTruths: ["The grandson's girlfriend later confirmed the grandparent was never told and never entered the back room."],
        moods: [.sympathetic], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-60, "Neighbor complaints begin."),
                       (-14, "Four nights of surveillance; 23 short visits logged."),
                       (0, "Search warrant executed; grandson arrested."),
                       (40, "Grandson pleads guilty to trafficking."),
                       (45, "{DL} charged.")],
            howIdentified: "{DL} owns the house.",
            notDone: [],
            defendantExam: [
                .direct("Did you know your grandson was selling drugs?", "\"No. I knew he had friends over. I go to bed at nine and take my hearing aids out.\""),
                .direct("What did you mean by 'grown folks'?", "\"I thought the neighbor was complaining about noise and cars. He's grown. I can't make his friends leave.\""),
                .cross("You never went in his room?", "\"He had a lock. I respected that. He's a man.\""),
                .cross("You saw cars at all hours.", "\"I saw headlights some nights when I got up for the bathroom.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, do grandparents usually know when this goes on in their homes?\"",
                                  answer: "\"In my experience, they almost always know.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation", shouldSustain: true,
                                  explanation: "What other people generally know says nothing reliable about what this defendant knew.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "{D.His} house, {D.his} bills, {D.his} neighbor's warning.",
            defenseOpening: "A locked door, a grandson's confession, and a grandmother asleep by nine.",
            prosecutionClosing: "{DL} was told, and {DL} did nothing.",
            defenseClosing: "Knowledge is an element. The only person who knew says {DL} didn't.",
            genders: ["D": .female]
        )
    )

    // MARK: - 71. The motorcycle chase (who was riding?)

    static let motorcycleChase = CaseTemplate(
        key: "story.motorcycleChase", category: .traffic,
        headlines: ["Motorcycle Flees Trooper at 130 MPH on I-40", "Rider Charged From Plate, Not Face"],
        primaryLaw: "fleeing", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Operated a motorcycle on I-40 while fleeing a law enforcement officer, with speed more than 15 mph over the limit and reckless driving.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove a motorcycle at over 130 mph through traffic on I-40.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "resisting", specification: "Resisted and delayed a state trooper by fleeing a traffic stop.", chance: 1.0, threshold: 4)
        ],
        ageRange: 21...32, occupations: ["mechanic", "warehouse worker"], hasVictim: false,
        summaries: [
            "At 9:30 p.m. on {DATE}, a state trooper clocked a black sport motorcycle at 112 mph on I-40 near the {HOOD} exit. When the trooper turned on the blue lights, the rider accelerated past 130, weaved through traffic, and escaped. The trooper's dashcam caught the plate, registered to {D}. The rider wore a full-face helmet. {DL} says {D.he} sold the bike two weeks earlier for cash to someone from a social media marketplace and never transferred the title."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dashcam", "The plate is legible as the bike pulls away. The rider wears a black full-face helmet and a red jacket."),
            E(.document, 2, "Registration", "The motorcycle is registered and insured in {DL}'s name."),
            E(.digital, 2, "Social Media Post", "Three weeks before, {DL} posted a photo of {D.himself} on the bike in a red jacket: \"130 or bust.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Marketplace Listing", "A listing for the bike on a marketplace site, posted a month earlier, marked sold sixteen days before the chase."),
            E(.document, 2, "Cash Deposit", "A $6,500 cash deposit to {DL}'s bank account fifteen days before the chase."),
            E(.document, 1, "No Bike Found", "Police never found the motorcycle.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State Highway Patrol trooper",
                        direct: ["\"130 through traffic.\""],
                        cross: ["\"I couldn't see the face.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What happened?", "\"I clocked 112 on radar. When I lit up, the rider tucked down and opened it up. I paced it past 130 before I called it off for public safety.\""),
                            .direct("What did you see of the rider?", "\"Black full-face helmet, red jacket, slim build.\""),
                            .cross("You couldn't see the rider's face?", "\"No.\""),
                            .cross("Slim build in a red jacket describes a lot of riders?", "\"It does.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"No bill of sale, no title transfer.\""],
                        cross: ["\"There was a cash deposit.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} say?", "\"That {D.he} sold the bike for cash to someone named 'Chris' from a marketplace app and didn't do the title.\""),
                            .direct("Could you find the buyer?", "\"The account {DL} named was deleted. No bill of sale.\""),
                            .cross("{DL}'s listing was marked sold sixteen days before?", "\"Yes.\""),
                            .cross("A $6,500 cash deposit fifteen days before?", "\"Yes.\""),
                            .cross("Did you ask the marketplace for the buyer's account records?", "\"We sent a request. They haven't responded.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s roommate",
                        direct: ["\"{DL} was home that night.\""],
                        cross: ["\"I saw the bike leave with someone else.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where was {DL} at 9:30 that night?", "\"On the couch with me watching the game. Second half started at nine.\""),
                            .direct("Did you see the bike sold?", "\"A guy came with cash, counted it on the hood, and rode it off. Two weeks before.\""),
                            .cross("You're {DL}'s close friend?", "\"Since middle school.\""),
                            .cross("Can you describe the buyer?", "\"Skinny, wore a helmet when he left.\"")
                        ])
        ],
        prosecutionTheory: ["The bike is {D}'s, the jacket is {D.his}, and {D.he} bragged about 130. 'Sold it for cash to someone I can't find' is what people say."],
        defenseTheory: ["{DL} listed the bike, marked it sold, and deposited $6,500 two weeks before. The State can't put {DL} on the motorcycle."],
        aggravating: ["The offense created a great risk of death to others"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: [],
        allocutions: ["\"I should have done the title. I wasn't on that bike.\""],
        guiltyTruths: ["The bike was found months later in {DL}'s cousin's barn, with {DL}'s helmet on the seat."],
        innocentTruths: ["The marketplace finally returned records identifying the buyer, who had a history of fleeing police."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-30, "Motorcycle listed for sale."),
                       (-16, "Listing marked sold."),
                       (-15, "$6,500 cash deposit to {DL}'s account."),
                       (0, "9:30 p.m.: chase on I-40; trooper ends pursuit."),
                       (2, "Plate traced to {DL}; interview."),
                       (10, "{DL} charged.")],
            howIdentified: "The license plate on the trooper's dashcam.",
            notDone: ["The marketplace never responded, and no follow-up subpoena was sent.", "The roommate's account was not checked against phone records."],
            defendantExam: [
                .direct("Who was riding your old motorcycle?", "\"The guy who bought it. 'Chris.' Paid sixty-five hundred cash. I know I should have done the title.\""),
                .direct("Where were you?", "\"On my couch with my roommate, watching the game.\""),
                .cross("You posted '130 or bust' three weeks before.", "\"That was a joke. And I was selling the bike.\""),
                .cross("You don't have a bill of sale?", "\"We shook hands. I know.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Trooper, does the rider's build match {DL}?\"",
                                  answer: "\"It looks about the same.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Lack of foundation", shouldSustain: false,
                                  explanation: "A witness who saw the rider may compare general build to the defendant in court; the weight is for the factfinder.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "{DL}'s bike, {DL}'s jacket, and {DL}'s own words: 130 or bust.",
            defenseOpening: "A sale, a deposit, and a buyer no one looked for.",
            prosecutionClosing: "The convenient stranger is a story.",
            defenseClosing: "The State proved who owned the bike on paper. Not who rode it."
        )
    )

    // MARK: - 72. The deleted footage (an officer and a missing video)

    static let deletedFootage = CaseTemplate(
        key: "story.deletedFootage", category: .publicOrder,
        headlines: ["Officer Charged With Deleting Body Camera Video", "Arrest Video Vanished; Sergeant Says It Was a Glitch"],
        primaryLaw: "obstruction", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Obstructed public justice by deleting body camera video of an arrest that was the subject of a use-of-force complaint.",
        secondary: [
            SecondaryCharge(lawID: "accessingComputers", specification: "Accessed the department's camera system to destroy records for an unauthorized purpose.", chance: 1.0, threshold: 3)
        ],
        ageRange: 32...50, occupations: ["police sergeant"], hasVictim: true,
        summaries: [
            "On {DATE}, Port Hollis officers arrested {V} outside a convenience store; {VL} later complained that an officer slammed {V.his} head against the patrol car. When internal affairs requested the footage, the body camera video from that arrest was gone. The camera system's audit log shows the video was deleted at 2:14 a.m. the next morning from a desktop login belonging to {D}, the shift sergeant, who was not the arresting officer. {DL} says {D.he} was bulk-clearing \"non-evidentiary\" recordings, which the system allows sergeants to do, and the arrest video was miscategorized."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Audit Log", "The video was deleted at 2:14 a.m. under {DL}'s login, eleven hours before the complaint was filed but three hours after {VL} told the jail nurse \"I'm suing.\""),
            E(.document, 2, "Category", "The video was categorized as 'Arrest - Felony,' which the policy says must be kept for three years."),
            E(.statement, 2, "Arresting Officer", "The arresting officer told internal affairs that {DL} came into the report room that night and asked, \"Is there anything on your camera I need to worry about?\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Bulk Deletion", "The same login deleted 214 other videos in the same session, all routine."),
            E(.document, 2, "System Bug", "The vendor issued a bulletin two months later about a bug that displayed some videos with a default category."),
            E(.document, 1, "Clean Record", "{DL} has 17 years with the department and no discipline.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Internal affairs lieutenant",
                        direct: ["\"It was categorized as a felony arrest.\""],
                        cross: ["\"214 other videos were deleted too.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the audit log show?", "\"A deletion at 2:14 a.m. under Sergeant {DL}'s login. The video was categorized 'Arrest - Felony,' which can't be deleted under policy.\""),
                            .direct("How did the deletion relate to the complaint?", "\"{VL} told the jail nurse at 11 p.m. that {V.he} was going to sue. The deletion was three hours later.\""),
                            .cross("The same session deleted 214 other videos?", "\"Yes. All routine.\""),
                            .cross("The vendor later reported a bug that showed some videos with the wrong category?", "\"There was a bulletin. We don't know if it affected this video.\""),
                            .cross("Is there any evidence {DL} knew about the nurse conversation?", "\"Not directly.\"")
                        ]),
            WitnessSeed(name: nil, role: "Arresting officer",
                        direct: ["\"{DL} asked if there was anything on my camera to worry about.\""],
                        cross: ["\"Sergeants ask that all the time.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} say to you that night?", "\"Came into the report room and asked, 'Anything on your camera I need to worry about?' I said the suspect was fighting, I took them down hard, it's on there.\""),
                            .cross("Sergeants ask that after any use of force?", "\"It's a normal question. That's how I took it then.\""),
                            .cross("You've been suspended for the force you used on {VL}?", "\"I'm on administrative leave.\""),
                            .cross("You'd benefit if the blame moved to {DL}?", "\"I'm telling what happened.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Vendor support engineer",
                        direct: ["\"The bug was real.\""],
                        cross: ["\"I can't say it hit this video.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was the bug?", "\"For about three months, the bulk-clear screen showed some videos as 'Uncategorized' even when they had a category. Supervisors could select and delete them with routine footage.\""),
                            .cross("Can you say this video displayed as uncategorized?", "\"The screen state isn't logged. I can't say either way.\""),
                            .cross("How many departments reported deleting a felony video by mistake?", "\"Four that I know of.\"")
                        ])
        ],
        prosecutionTheory: ["{D} asked whether there was anything to worry about, learned there was, and deleted the video that night under {D.his} own login."],
        defenseTheory: ["A routine bulk clear of 215 videos, a known software bug that hid categories, and a question every sergeant asks. Obstruction requires intent."],
        aggravating: ["The defendant abused a position of public trust"],
        mitigating: ["No prior criminal record", "The defendant has a long record of public service"],
        victimImpacts: ["{V}: \"The video was the only proof I had. Now it's my word against a badge.\""],
        allocutions: ["\"I've cleared thousands of videos. I never deleted one on purpose to hide anything.\""],
        guiltyTruths: ["A text from {DL} to the arresting officer, recovered later, said \"Took care of it.\""],
        innocentTruths: ["The vendor later confirmed the arrest video displayed as uncategorized on {DL}'s screen."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "9:40 p.m.: {VL} arrested."),
                       (0, "11:00 p.m.: {VL} tells the jail nurse {V.he} will sue."),
                       (1, "2:14 a.m.: video deleted under {DL}'s login."),
                       (1, "1:00 p.m.: {VL} files a complaint."),
                       (3, "Internal affairs finds the video missing."),
                       (60, "Vendor bulletin about the category bug."),
                       (75, "{DL} charged.")],
            howIdentified: "The camera system's audit log.",
            notDone: ["The vendor was not asked to reconstruct {DL}'s screen view before charging."],
            defendantExam: [
                .direct("Why were you deleting videos at 2 a.m.?", "\"Quiet part of the shift. Storage was at ninety-six percent, and the system was warning us. I cleared the uncategorized pile, like every month.\""),
                .direct("Why did you ask about the camera?", "\"I ask after every hands-on arrest. That's my job.\""),
                .cross("The video was a felony arrest.", "\"It didn't show that way on my screen.\""),
                .cross("You knew the arrest involved force.", "\"I knew. That's why I'd never have touched it on purpose.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"You're on leave and facing your own charges, and you'd like the focus on someone else?\"",
                                  answer: "\"I'd like the truth to come out.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: false,
                                  explanation: "A witness's pending exposure is classic bias impeachment; the question is proper.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A question about the camera, an answer, and a deletion three hours later.",
            defenseOpening: "A bulk clear, a known bug, and seventeen clean years.",
            prosecutionClosing: "Of 215 videos, the one that mattered was gone.",
            defenseClosing: "A coincidence isn't a crime, and the bug is real."
        )
    )

    // MARK: - 73. The ex's house key (a home that was once shared)

    static let exHouseKey = CaseTemplate(
        key: "story.exHouseKey", category: .property,
        headlines: ["Ex-Partner Charged With Burglary After Late-Night Entry", "'It Was Still My Stuff,' Burglary Defendant Says"],
        primaryLaw: "burglary2", lesserLaw: "feloniousBE", threshold: 3, lesserThreshold: 1,
        specification: "Broke and entered the dwelling house of {V} on {STREET} in the nighttime with intent to commit larceny therein.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole a television and jewelry box valued over $1,000 belonging to {V}.", chance: 1.0, threshold: 2),
            SecondaryCharge(lawID: "trespass2", specification: "Entered {V}'s home after being told in writing not to.", chance: 1.0, threshold: 1)
        ],
        ageRange: 28...45, occupations: ["real estate agent", "HVAC technician"], hasVictim: true,
        summaries: [
            "Six weeks after {D} moved out of the house {D.he} had shared with {V} on {STREET} in {HOOD}, {VL} woke at 1:30 a.m. on {DATE} to find {DL} in the living room carrying a television and a box of jewelry. {DL} still had a key, and nothing was forced. {DL} says the television and half the jewelry were {D.his}, that {VL} had refused for weeks to let {D.him} get {D.his} things, and that {D.he} came at night to avoid a fight. {VL} had texted {DL} two weeks earlier: \"Don't you dare come in this house again.\" The house is in {VL}'s name alone."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Text Message", "{VL} to {DL}, two weeks earlier: \"Don't you dare come in this house again. Your key doesn't mean you're welcome.\""),
            E(.document, 2, "Deed", "The house is titled solely to {VL}."),
            E(.statement, 2, "911 Call", "{VL}: \"My ex is in my house with my TV and my jewelry.\"")
        ],
        defenseEvidence: [
            E(.document, 3, "TV Receipt", "A receipt for the television, bought with {DL}'s credit card a year earlier."),
            E(.digital, 2, "Requests for Belongings", "Seven texts from {DL} over five weeks asking when {D.he} could pick up {D.his} things; {VL} replied to two, saying \"not yet.\""),
            E(.document, 1, "Jewelry Gifts", "Two pieces in the box were gifts from {DL}'s mother, per an insurance rider in {DL}'s name.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"I told {D.him} never to come in again.\""],
                        cross: ["\"The TV was on {D.his} card.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened that night?", "\"I heard the door. I came out with my phone and {DL} was walking toward the door with the TV and my jewelry box. I screamed and called 911.\""),
                            .direct("Had you told {DL} not to come in?", "\"In writing. 'Don't you dare come in this house again.'\""),
                            .cross("The TV was bought on {DL}'s card?", "\"For the house. It was a gift.\""),
                            .cross("{DL} asked seven times to get {D.his} belongings?", "\"I wasn't ready to see {D.him}.\""),
                            .cross("Some of the jewelry belonged to {DL}'s mother?", "\"Two pieces. The rest is mine.\"")
                        ]),
            WitnessSeed(name: nil, role: "Responding officer",
                        direct: ["\"{DL} had the jewelry box in the car.\""],
                        cross: ["\"{DL} waited for us.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find?", "\"The TV on the lawn and the jewelry box on {DL}'s front seat.\""),
                            .cross("{DL} waited in the driveway for you to arrive?", "\"Yes. {D.He} was calm and said, 'It's my stuff.'\""),
                            .cross("Was anything forced?", "\"No. {DL} used a key.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s sibling",
                        direct: ["\"{DL} begged for weeks to get {D.his} things.\""],
                        cross: ["\"Going at 1:30 in the morning was dumb.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That {VL} wouldn't let {D.him} get {D.his} clothes, {D.his} TV, or our mom's rings. {DL} slept on my couch in borrowed shirts for six weeks.\""),
                            .cross("Going in at 1:30 a.m. was a choice?", "\"A dumb one. To avoid a fight.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was told in writing never to enter, came in at 1:30 a.m. with an old key, and carried out {VL}'s property. That's burglary."],
        defenseTheory: ["{DL} took {D.his} own TV and {D.his} mother's jewelry after weeks of being refused. Burglary requires intent to steal; you can't steal what you honestly believe is yours."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"I changed the locks, put in cameras, and I still sleep with a light on.\""],
        allocutions: ["\"I just wanted my things and my mom's rings. I'm sorry I scared {VL}.\""],
        guiltyTruths: ["Pawn shop records later showed {DL} had pawned two of {VL}'s rings from an earlier, unreported entry."],
        innocentTruths: ["{VL} later admitted in family court that most of the jewelry in the box belonged to {DL}'s family."],
        moods: [.divided], doctrines: ["mistakeOfFact", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(-42, "{DL} moves out."),
                       (-35, "First of seven texts asking to collect belongings."),
                       (-14, "{VL} texts: 'Don't you dare come in this house again.'"),
                       (0, "1:30 a.m.: {DL} enters with a key; {VL} calls 911."),
                       (1, "{DL} charged with second-degree burglary.")],
            howIdentified: "{VL} saw {DL} inside the house.",
            notDone: ["No one sorted which items in the jewelry box belonged to whom before charging."],
            defendantExam: [
                .direct("Why did you go in at 1:30 a.m.?", "\"Because every time I asked, {VL} said 'not yet,' and I didn't want another screaming match. I thought I'd be in and out.\""),
                .direct("Whose things did you take?", "\"The TV I bought, and my mother's rings. I grabbed the box because they were in it.\""),
                .cross("You were told in writing not to come in.", "\"I was told a lot of things in anger. My clothes were still in the closet.\""),
                .cross("Most of what's in that box is {VL}'s.", "\"I was going to give back what wasn't mine. I didn't have time to sort it in the dark.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Isn't it true you kept {DL}'s things to punish {D.him} for leaving?\"",
                                  answer: "\"I kept them because I wasn't ready.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: false,
                                  explanation: "The witness's motive for withholding the property bears directly on the defense of claim of right; it's proper cross.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A written warning, an old key, and 1:30 in the morning.",
            defenseOpening: "A person who wanted their own TV and their mother's rings.",
            prosecutionClosing: "{DL} was told never to come in, and came in anyway, at night, and took what wasn't {D.hers}.",
            defenseClosing: "An honest claim to your own property isn't intent to steal.",
            victim: VictimFacts(relationship: "A former partner of the defendant; they shared the house until six weeks earlier.")
        )
    )
}
