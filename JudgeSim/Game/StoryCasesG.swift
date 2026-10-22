import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchG: [CaseTemplate] = [breakRoomCoffee, evidenceRoom, hiddenTracker, roadBlockade, painClinic]

    // MARK: - 44. The break room coffee (poisoning)

    static let breakRoomCoffee = CaseTemplate(
        key: "story.breakRoomCoffee", category: .violent,
        headlines: ["Coworker Charged With Poisoning Supervisor's Coffee", "Antifreeze in the Break Room"],
        primaryLaw: "awdwikisi", lesserLaw: "awdwisi", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with ethylene glycol, a deadly weapon, with intent to kill, inflicting serious injury.",
        secondary: [
            SecondaryCharge(lawID: "attemptedMurder1", specification: "With premeditation and deliberation, attempted to kill {V} by poisoning {V.his} coffee.", chance: 1.0, threshold: 8)
        ],
        ageRange: 30...55, occupations: ["dispatcher at a trucking company"], hasVictim: true,
        summaries: [
            "Over three weeks at a trucking company in {HOOD}, {V}, the dispatch supervisor, grew sicker: nausea, confusion, then kidney failure. Doctors found ethylene glycol, the main ingredient in antifreeze. {VL} survives on dialysis. {VL} drank from the same personal coffee thermos every day, kept in the break room fridge. {D}, a dispatcher {VL} had written up twice and recommended for firing, was the only coworker seen on camera opening the fridge at odd hours. {DL} says {D.he} kept {D.his} own lunch there, and that half the office resented {VL}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Break Room Camera", "{DL} opens the fridge alone at 6:12 a.m. on eight mornings over three weeks, before others arrive. {DL}'s shift starts at 7."),
            E(.forensic, 3, "Thermos Testing", "Residue in {VL}'s thermos contained ethylene glycol. The fridge's other containers were clean."),
            E(.digital, 2, "Search History", "{DL}'s work computer searched \"antifreeze taste coffee\" six weeks before {VL} got sick.", .search),
            E(.document, 2, "Write-Ups", "Two disciplinary write-ups by {VL} and a pending recommendation to terminate {DL}.")
        ],
        defenseEvidence: [
            E(.document, 2, "Early Arrivals", "{DL} had come in early for two years to beat traffic, according to badge records."),
            E(.document, 2, "Shared Computer", "The dispatch computer with the search was shared by four dispatchers on rotating shifts; {DL} was on shift, but so were two others."),
            E(.document, 2, "Other Grievances", "Three other employees had filed complaints against {VL}, and one had been fired a week before {V.he} got sick.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Nephrologist",
                        direct: ["\"Repeated small doses, over weeks.\""],
                        cross: ["\"I can't say who put it there.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What happened to {VL}?", "\"Ethylene glycol poisoning. It's metabolized into crystals that destroy the kidneys. {VL}'s kidneys failed. {VL} will need dialysis or a transplant.\""),
                            .direct("Was it one dose or many?", "\"The pattern of illness over three weeks, with good days and bad days, fits repeated small doses rather than one large one.\""),
                            .cross("You can't say who put it there?", "\"Who put it there is your question, not mine. I can tell you it was there.\""),
                            .cross("Or exactly which days?", "\"Not exactly.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{DL} was alone at that fridge on eight mornings.\""],
                        cross: ["\"Others had motive too.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the camera show?", "\"{DL} opening the fridge alone at 6:12 a.m. on eight mornings. {DL}'s back is to the camera; we can't see hands.\""),
                            .direct("What about the search?", "\"'Antifreeze taste coffee,' on the dispatch computer during {DL}'s shift, six weeks before.\""),
                            .direct("What did {DL} say?", "\"That {DL} came early every day and kept lunch in the fridge. When I showed {DL} the search, {D.he} said someone else must have done it.\""),
                            .cross("Two other dispatchers were on that shift and used that computer?", "\"Two others, and the computer didn't require a separate login.\""),
                            .cross("The employee fired a week before {VL} got sick still had building access for a week?", "\"Their badge worked until it was deactivated, yes.\""),
                            .cross("You never searched {DL}'s home or car for antifreeze?", "\"We did. We found a jug in the garage. Most garages have one.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fellow dispatcher",
                        direct: ["\"{DL} always came in early.\""],
                        cross: ["\"{DL} talked about {VL} a lot.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What were {DL}'s habits?", "\"First one in, every day, for as long as I've worked there. Makes the coffee for everybody, puts lunch in the fridge.\""),
                            .direct("How did people feel about {VL}?", "\"Most of us couldn't stand {VL}. Yelling, write-ups for nothing. When {DL}'s termination paperwork went up, people were angry for {D.him}.\""),
                            .cross("{DL} complained about {VL} constantly?", "\"Everybody did. {DL} more than most.\""),
                            .cross("Did you ever see anyone else near {VL}'s thermos?", "\"Nobody. It sat where it always sat.\"")
                        ])
        ],
        prosecutionTheory: ["{D}, about to be fired by {V}, searched how to hide antifreeze in coffee and was alone at the fridge with {V.his} thermos on eight mornings."],
        defenseTheory: ["{DL} came in early for two years, shared a computer with others, and was one of many people who resented {VL}. The State has suspicion, not proof."],
        aggravating: ["The offense was committed over weeks with planning", "The victim suffered permanent injury"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"Three times a week I sit in a chair for four hours while a machine cleans my blood. I'm fifty-one.\""],
        allocutions: ["\"I didn't like {VL}. I didn't poison {VL}.\""],
        guiltyTruths: ["A small dropper bottle with ethylene glycol residue was later found in {DL}'s desk drawer."],
        innocentTruths: ["The employee fired a week earlier was later caught on a different camera entering after hours."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-42, "Search 'antifreeze taste coffee' on the dispatch computer."),
                       (-28, "{VL} recommends {DL}'s termination."),
                       (-21, "{VL} begins getting sick."),
                       (0, "{VL} hospitalized; ethylene glycol found."),
                       (10, "Thermos tested; camera reviewed."),
                       (30, "{DL} charged.")],
            howIdentified: "Break room camera footage and the search on the dispatch computer.",
            notDone: ["The recently fired employee was never seriously investigated."],
            defendantExam: [
                .direct("Why were you at the fridge every morning?", "\"I come in early to beat the traffic on 17. I put my lunch away and start the coffee for everyone. I've done it for two years.\""),
                .direct("Did you search 'antifreeze taste coffee'?", "\"No. I didn't. Three of us use that computer.\""),
                .cross("{VL} was about to have you fired.", "\"And I was looking for another job, not poisoning anyone.\""),
                .cross("Antifreeze was in your garage.", "\"For my car. Like everyone.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, do poisoners usually act like {DL} did?\"",
                                  answer: "\"In my experience, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Testimony that the defendant fits a 'profile' of guilty people is improper; it invites conviction by category.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A motive, a search, and eight mornings alone at the fridge with {V}'s thermos.",
            defenseOpening: "Two years of early arrivals, a shared computer, and an office full of people who resented {VL}.",
            prosecutionClosing: "The pieces fit only one person.",
            defenseClosing: "The pieces fit several. That's reasonable doubt.",
            victim: VictimFacts(age: 51, occupation: "Dispatch supervisor at a trucking company", relationship: "The defendant's supervisor at work.")
        )
    )

    // MARK: - 45. The evidence room

    static let evidenceRoom = CaseTemplate(
        key: "story.evidenceRoom", category: .whiteCollar,
        headlines: ["Deputy Charged With Stealing Seized Cash", "$31,000 Missing From Evidence Room"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 2, lesserThreshold: 1,
        specification: "As evidence custodian for the Hollis County Sheriff's Office, embezzled $31,000 in seized cash.",
        secondary: [
            SecondaryCharge(lawID: "embezzlement", specification: "As evidence custodian, embezzled $11,500 seized in a second drug case.", chance: 1.0, threshold: 1),
            SecondaryCharge(lawID: "embezzlement", specification: "As evidence custodian, embezzled $8,000 seized in a third drug case.", chance: 1.0, threshold: 1),
            SecondaryCharge(lawID: "embezzlement", specification: "As evidence custodian, embezzled $13,500 seized in three other cases.", chance: 1.0, threshold: 1),
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by replacing seized cash with cut newspaper in sealed evidence bags.", chance: 1.0, threshold: 1),
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by falsifying evidence room logs.", chance: 1.0, threshold: 1)
        ],
        ageRange: 38...55, occupations: ["sheriff's deputy and evidence custodian"], hasVictim: false,
        summaries: [
            "{D}, a nineteen-year deputy, ran the Hollis County Sheriff's Office evidence room. On {DATE}, a prosecutor asked for $31,000 seized in a drug case to be brought to court; the sealed bag held cut newspaper. An audit found $64,000 missing from nine cases over two years. {DL} had keys and kept the logs. {DL} had also been paying down large medical bills for a child's cancer treatment. {DL} says the evidence room's lock had been broken for months and two other deputies had keys."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Evidence Logs", "{DL} signed the log for every one of the nine affected bags, including resealing entries no one else witnessed."),
            E(.document, 3, "Medical Debt Payments", "{DL} paid $47,000 in cash toward hospital bills over two years; {DL}'s salary is $58,000."),
            E(.forensic, 2, "Seal Tape", "Replacement evidence tape on the bag had {DL}'s initials and a fingerprint matching {D.him}.")
        ],
        defenseEvidence: [
            E(.document, 3, "Broken Lock Reports", "Maintenance tickets show the evidence room's secondary door lock was broken for seven months; {DL} reported it three times."),
            E(.document, 2, "Other Key Holders", "Two other deputies held keys; one retired abruptly during the audit."),
            E(.document, 2, "Fundraiser Records", "A church fundraiser and online fundraising page raised $38,000 in cash and checks for {DL}'s child's treatment.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Internal affairs captain",
                        direct: ["\"{DL}'s initials are on every resealed bag.\""],
                        cross: ["\"The lock was broken.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the audit find?", "\"Nine cases with cash replaced by paper, $64,000 total, all resealed with tape initialed by {DL}, and logged by {D.him}.\""),
                            .direct("Why does resealing matter?", "\"Opening a sealed bag requires a witness and a log entry explaining why. Each of these resealings has {DL}'s initials and no witness.\""),
                            .cross("{DL} reported the broken lock three times?", "\"The tickets show that.\""),
                            .cross("Another deputy with keys retired during the audit?", "\"For medical reasons, I'm told.\""),
                            .cross("Initials on tape can be copied by anyone holding a roll?", "\"In theory.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic accountant",
                        direct: ["\"{DL} paid far more in cash than {D.he} could explain.\""],
                        cross: ["\"Fundraiser money was real.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find?", "\"$47,000 in cash paid to hospitals over two years. {DL}'s bank withdrawals cover only about $9,000 of that.\""),
                            .cross("A church fundraiser raised $38,000 in cash and checks?", "\"If those receipts are accurate, they could explain much of the gap.\""),
                            .cross("So the unexplained cash is closer to zero?", "\"Closer. Not zero.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Church treasurer",
                        direct: ["\"We raised $38,000 for {DL}'s child.\""],
                        cross: ["\"Much of it was cash.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did the church do?", "\"Barbecue plate sales, a gospel concert, a raffle. We handed {DL} envelopes of cash every few weeks for a year and a half.\""),
                            .direct("How much?", "\"Our books show $38,000 between the cash events and the online page.\""),
                            .cross("You can't prove how much cash went to {DL} versus deposited?", "\"I can show you every envelope in our ledger.\""),
                            .cross("You love {DL}'s family?", "\"Our whole church does.\"")
                        ])
        ],
        prosecutionTheory: ["{D} controlled the evidence room, initialed every resealed bag, and paid tens of thousands in cash on a deputy's salary."],
        defenseTheory: ["A broken lock for seven months, two other key holders, one of whom retired during the audit, and a church that raised $38,000 for a sick child."],
        aggravating: [],
        mitigating: ["Nineteen years of service", "No prior criminal record", "Severe family medical hardship"],
        allocutions: ["\"I've guarded that room for six years. I would never steal there, not even for my child.\""],
        guiltyTruths: ["A bundle of seized bills with case markings was later found in {DL}'s attic."],
        innocentTruths: ["The retired deputy's estate later turned over $52,000 in bundled cash with evidence tags."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-730, "First affected case sealed."),
                       (-210, "Secondary lock reported broken."),
                       (0, "Bag opened at the prosecutor's request; newspaper inside."),
                       (14, "Audit finds nine affected cases; another key-holding deputy retires."),
                       (60, "{DL} charged with embezzlement.")],
            howIdentified: "{DL}'s initials and fingerprint on the replacement tape.",
            notDone: ["The retired deputy's finances were never examined."],
            defendantExam: [
                .direct("Why are your initials on the resealed bags?", "\"Because every time I found a bag with a damaged seal, I resealed it and initialed it, like I was trained. I reported damaged seals to my lieutenant twice.\""),
                .direct("Where did the cash for the hospital come from?", "\"The church. Envelopes every few weeks. I have their ledger.\""),
                .cross("Your log entries don't say 'damaged seal.' They say 'inventory.'", "\"That's the category in the system. I should have written more.\""),
                .cross("You were drowning in medical bills.", "\"Yes. And my church carried us.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"The deputy who retired was under investigation for gambling, wasn't that deputy?\"",
                                  answer: "\"I can't speak to that.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Assumes facts not in evidence", shouldSustain: true,
                                  explanation: "No evidence of a gambling investigation has been offered; the question assumes it.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Every resealed bag carries {D}'s initials.",
            defenseOpening: "A broken lock, other keys, and a church that raised the money.",
            prosecutionClosing: "The custodian is responsible for the room.",
            defenseClosing: "Responsibility isn't proof of theft."
        )
    )

    // MARK: - 46. The hidden tracker (stalking)

    static let hiddenTracker = CaseTemplate(
        key: "story.hiddenTracker", category: .robbery,
        headlines: ["Tracker Found Hidden in Ex's Car", "Stalking or Shared Device?"],
        primaryLaw: "stalking", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Willfully on more than one occasion followed and surveilled {V} without legal purpose, causing substantial emotional distress.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Used an electronic tracking device to monitor {V}'s location without consent.", chance: 1.0, threshold: 5)
        ],
        ageRange: 25...45, occupations: ["sales manager"], hasVictim: true,
        summaries: [
            "Two months after {V} moved out, {V.his} phone alerted that an unknown tracker was moving with {V.him}. A mechanic found a small Bluetooth tracker taped inside the rear bumper of {VL}'s car. The tracker was registered to {D}'s account. Over the next weeks {DL} \"happened\" to appear at {VL}'s gym and at a restaurant {V.he} visited with a new partner. {DL} says the tracker had been on the car since they bought it together, to find it in parking lots, and that {D.he} forgot to remove it; and that the gym and restaurant were places they'd always gone together."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "The Tracker", "A Bluetooth tracker registered to {DL}'s account, wrapped in black electrical tape inside the rear bumper cavity.", .search),
            E(.digital, 3, "Location History", "{DL}'s account checked the tracker's location 212 times in the six weeks after {VL} moved out, often late at night.", .search),
            E(.statement, 2, "Encounters", "{DL} appeared at {VL}'s gym three times and at a restaurant within forty minutes of {V.him} arriving.")
        ],
        defenseEvidence: [
            E(.document, 2, "Car Purchase", "The car was bought jointly; the tracker was registered the week of purchase, a year and a half earlier."),
            E(.document, 2, "Shared Routine", "{DL}'s gym membership predates the relationship; the restaurant is {DL}'s regular lunch spot according to receipts."),
            E(.document, 1, "No Threats", "No threatening messages; {DL} never approached {VL} during the encounters.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complainant",
                        direct: ["\"Everywhere I went, there {DL} was.\""],
                        cross: ["\"{DL} never threatened me.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("When did you notice {DL} appearing?", "\"Two weeks after I moved out. The gym on a Tuesday, then a Thursday, then a Saturday morning, which {DL} never did. Then a restaurant on my first date in two years.\""),
                            .direct("How did you find the tracker?", "\"My phone kept saying 'unknown tracker moving with you.' I thought it was a glitch. My mechanic found it wrapped in tape in the bumper.\""),
                            .direct("How did that feel?", "\"Like my skin was crawling. I changed my route to work, my gym, my phone. I still look at my rearview mirror constantly.\""),
                            .cross("You and {DL} bought that car together, and {D.he} put a tracker on it then?", "\"I didn't know it was there.\""),
                            .cross("{DL} never approached you, never said a word at the gym or the restaurant?", "\"Just looked at me. That was enough.\""),
                            .cross("{DL} has gone to that gym for ten years?", "\"Not on Saturdays.\"")
                        ]),
            WitnessSeed(name: nil, role: "Digital forensics examiner",
                        direct: ["\"{DL} checked the tracker 212 times.\""],
                        cross: ["\"The tracker was set up a year and a half ago.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the account records show?", "\"{DL}'s account opened the tracker's location 212 times in six weeks after {VL} moved out, compared to four times in the prior six months.\""),
                            .direct("When?", "\"Mostly between 10 p.m. and 2 a.m.\""),
                            .cross("The tracker was registered when the car was bought?", "\"When the car was bought, in {D.his} name.\""),
                            .cross("Someone could check a tracker out of habit or worry?", "\"212 times is a lot of habit.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s therapist",
                        direct: ["\"{DL} was in grief, not pursuit.\""],
                        cross: ["\"Checking the tracker was unhealthy.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What was {DL}'s state after the breakup?", "\"Acute grief, insomnia, rumination. {DL} told me {D.he} checked the tracker at night to know {VL} was safe, and was ashamed of it.\""),
                            .cross("Checking an ex's location 212 times is unhealthy?", "\"It's a sign of obsession. I'd use that word.\""),
                            .cross("{DL} never told you {D.he} removed it?", "\"It never came up in session.\"")
                        ])
        ],
        prosecutionTheory: ["{D} kept a hidden tracker on {V}'s car, checked it 212 times, and kept appearing wherever {V.he} went."],
        defenseTheory: ["A tracker put on a jointly bought car long before the breakup, a gym and restaurant {DL} has used for years, and not one threat. Grief isn't stalking."],
        aggravating: ["The surveillance was covert and prolonged"],
        mitigating: ["No threats were made", "No prior criminal record"],
        victimImpacts: ["{V}: \"I check under my car before I get in. Every single time.\""],
        allocutions: ["\"I should have removed it. I was falling apart. I'd never hurt {VL}.\""],
        guiltyTruths: ["Receipts later showed {DL} bought the electrical tape the day after {VL} moved out."],
        innocentTruths: ["The mechanic who originally installed the bumper confirmed the tape had been there since the purchase."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-540, "Car purchased; tracker registered to {DL}'s account."),
                       (-60, "{VL} moves out."),
                       (-45, "Tracker location checks increase sharply."),
                       (0, "Mechanic finds the tracker; {VL} reports to police."),
                       (25, "{DL} charged with stalking.")],
            howIdentified: "The tracker was registered to {DL}'s account.",
            notDone: ["The tape's age was never analyzed."],
            defendantExam: [
                .direct("Why was the tracker on the car?", "\"We put it there when we bought the car, so we could find it at the airport. I forgot it was there until {VL} left. Then I couldn't stop looking.\""),
                .direct("Why did you keep showing up?", "\"I've gone to that gym for ten years and that restaurant for lunch for five. I started going Saturdays because I couldn't sleep.\""),
                .cross("You checked the tracker 212 times.", "\"I know. It was sick. I'm getting help.\""),
                .cross("The restaurant was {VL}'s first date.", "\"I didn't know that until I saw them.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"Your new partner moved in quickly, didn't they?\"",
                                  answer: "\"That's none of anyone's business.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: true,
                                  explanation: "The complainant's new relationship has no bearing on whether {DL}'s conduct was stalking.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A hidden tracker, 212 checks, and {D} wherever {V} went.",
            defenseOpening: "A tracker from the day they bought the car, places {DL} always went, and no threats.",
            prosecutionClosing: "The law requires distress, not threats.",
            defenseClosing: "The law requires following, not grief.",
            victim: VictimFacts(relationship: "A former partner of the defendant.")
        )
    )

    // MARK: - 47. The blocked road

    static let roadBlockade = CaseTemplate(
        key: "story.roadBlockade", category: .violent,
        headlines: ["Driver Plows Through Protesters, Injuring One", "Fear or Rage on {STREET}?"],
        primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 2, lesserThreshold: 1,
        specification: "Assaulted {V} with a motor vehicle, a deadly weapon, inflicting serious injury.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove into a crowd of protesters on {STREET}.", chance: 1.0, threshold: 1)
        ],
        ageRange: 30...60, occupations: ["home health nurse"], hasVictim: true,
        summaries: [
            "On {DATE}, about forty protesters blocked {STREET} in {CITY}. {D}, a home health nurse on the way to a patient, stopped, then inched forward as protesters surrounded the car. Someone struck the windshield with a sign pole and another kicked the door. {DL} accelerated. The car struck {V}, a protester standing in front of the bumper, who suffered a fractured pelvis. {DL} drove three blocks, stopped, and called 911. The State says {DL} chose to drive through people. The defense says {DL} was surrounded, attacked, and fled in fear."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Livestream Video", "{DL}'s car stops, then moves forward slowly for about ten seconds while people step aside; then a pole hits the windshield and the car accelerates, striking {VL} at about 15 mph."),
            E(.forensic, 3, "Injuries", "Fractured pelvis and a broken wrist; {VL} spent eleven days in the hospital."),
            E(.statement, 2, "Statement to Officers", "{DL}: \"I wasn't going to sit there and get dragged out of my car.\"", .statement)
        ],
        defenseEvidence: [
            E(.video, 3, "Second Angle", "A different phone shows two people beating on the driver's window and one yanking the door handle before the acceleration."),
            E(.physical, 2, "Car Damage", "A cracked windshield, a dented door, and a broken side mirror."),
            E(.statement, 2, "911 Call", "{DL}, sobbing: \"I hit someone, they were attacking my car, I'm three blocks away, please send someone.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Injured protester",
                        direct: ["\"I was standing still in front of the car.\""],
                        cross: ["\"I didn't see who hit the windshield.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why were you in the road?", "\"The march had a permit for the sidewalk. People spilled into the street. I was standing there holding a banner when the car started pushing forward.\""),
                            .direct("What happened?", "\"It crept toward me, I put my hand on the hood to say stop, and then the engine roared and I was on the ground.\""),
                            .cross("You didn't see who hit the windshield or kicked the door?", "\"I was in front. I heard banging.\""),
                            .cross("The march's permit was for the sidewalk, not the street?", "\"The permit said sidewalk. We spilled into the street when it got crowded.\""),
                            .cross("When the car crept forward, people moved and you stayed?", "\"I didn't think anyone would drive through a person.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "Officer on scene",
                        direct: ["\"{DL} said 'I wasn't going to sit there.'\""],
                        cross: ["\"The car was damaged and people were striking it.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did {DL} say?", "\"That {DL} wasn't going to sit there and get dragged out. {DL} was shaking badly.\""),
                            .cross("You saw a cracked windshield and dented door?", "\"Cracked windshield, dented door. That's what I wrote down.\""),
                            .cross("Officers had been told not to clear the street?", "\"We were ordered to monitor, not disperse.\""),
                            .cross("{DL} called 911 and waited for you?", "\"Called it in and was standing by the car when I pulled up.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Bystander who filmed the second angle",
                        direct: ["\"People were beating on the car.\""],
                        cross: ["\"The driver didn't have to accelerate that fast.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Two guys pounding on the driver's window, one pulling the door handle, somebody smacking the windshield with a pole. The driver looked terrified.\""),
                            .direct("Were you with the march?", "\"I was. I support it. I'm still telling you what I saw.\""),
                            .cross("The driver accelerated hard toward a person standing still?", "\"Hard, yeah. Too hard.\"")
                        ])
        ],
        prosecutionTheory: ["{D} chose to drive into a person standing in front of the car. Fear doesn't justify running someone over."],
        defenseTheory: ["{DL} was surrounded, the windshield and door were attacked, and someone was trying to open the door. {DL} fled in reasonable fear and called 911."],
        aggravating: [],
        mitigating: ["{DL}'s vehicle was being attacked", "{DL} stopped and called 911", "No prior criminal record"],
        victimImpacts: ["{V}: \"I walk with a cane now. I'm thirty-four.\""],
        allocutions: ["\"I've spent my life taking care of people. I'm sorry {VL} was hurt. I truly thought I was going to be dragged out of that car.\""],
        guiltyTruths: ["{DL}'s earlier social media post read: \"If they block my road, I'm not stopping.\""],
        innocentTruths: ["The man pulling the door handle later admitted he was trying to get {DL} out to 'teach a lesson.'"],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "4:12 p.m.: march spills into {STREET}. 4:31 p.m.: car stops, inches forward, accelerates; {VL} struck. 4:32 p.m.: {DL} calls 911."),
                       (1, "Livestream and second-angle videos collected."),
                       (10, "{DL} charged with assault with a deadly weapon inflicting serious injury.")],
            howIdentified: "{DL} called 911 and reported the collision.",
            notDone: ["The people striking the car were never identified."],
            defendantExam: [
                .direct("Why did you move forward at all?", "\"My patient was waiting for insulin. I inched forward because people were moving aside. Then they weren't.\""),
                .direct("Why accelerate?", "\"The windshield cracked, somebody was pulling my door, my window was being punched. I panicked and hit the gas.\""),
                .cross("{VL} was standing still in front of you.", "\"I saw a person and I saw my door opening. I chose wrong in a second.\""),
                .cross("'I wasn't going to sit there.'", "\"I wasn't going to sit there and be pulled out. That's what I meant.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"Your group wanted a confrontation that day, didn't it?\"",
                                  answer: "\"No. We wanted to be heard.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative; speculation", shouldSustain: true,
                                  explanation: "The question asks the witness to speak for a group's intent and argues the defense theory.",
                                  doctrineID: "speculation", weight: 0))
            ],
            prosecutionOpening: "{V} stood still in front of a car. {D} hit the gas.",
            defenseOpening: "A cracked windshield, a door being yanked, and a nurse who fled in fear.",
            prosecutionClosing: "Fear doesn't justify driving into a person who poses no threat.",
            defenseClosing: "{DL} reasonably feared serious harm from the crowd attacking the car.",
            victim: VictimFacts(age: 34, occupation: "Protester; works as a teacher's aide", relationship: "Strangers before the incident.")
        )
    )

    // MARK: - 48. The pain clinic

    static let painClinic = CaseTemplate(
        key: "story.painClinic", category: .drugs,
        headlines: ["Nurse Practitioner Charged With Selling Prescriptions", "Pain Clinic or Pill Mill?"],
        primaryLaw: "deliverSchedII", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Delivered oxycodone by writing prescriptions without a legitimate medical purpose.",
        secondary: [
            SecondaryCharge(lawID: "deliverSchedII", specification: "Delivered oxycodone to a second patient who later died of an overdose.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "deliverSchedII", specification: "Delivered 90 oxycodone pills to an undercover officer after a seven-minute visit with no exam.", chance: 1.0, threshold: 3),
            SecondaryCharge(lawID: "deathByDistribution", specification: "Sold oxycodone, for a cash visit fee and a prescription without legitimate medical purpose, to a patient whose ingestion of it caused death.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "maintainingDwelling", specification: "Kept and maintained the clinic in {HOOD} for distributing controlled substances.", chance: 1.0, threshold: 3)
        ],
        ageRange: 38...60, occupations: ["nurse practitioner"], hasVictim: false,
        summaries: [
            "{D}, a nurse practitioner, ran a cash-only pain clinic in {HOOD}. Over two years {DL} wrote more oxycodone prescriptions than any provider in the county. An undercover officer posing as a patient with \"back pain\" got a 90-pill prescription after a seven-minute visit with no exam and no records. Two of {DL}'s patients died of overdoses. {DL} says {D.he} treated a rural population of injured laborers abandoned by other providers, and that the undercover officer lied on the intake form."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Undercover Visit", "A seven-minute visit: no physical exam, no prior records requested, a $300 cash payment, and a 90-tablet oxycodone 30 mg prescription."),
            E(.document, 3, "Prescription Data", "The state controlled substances database shows {DL} wrote 14,000 oxycodone prescriptions in two years, ten times the county's next-highest prescriber."),
            E(.document, 2, "Patient Overdoses", "Two patients died of overdoses within a month of filling prescriptions from {DL}.")
        ],
        defenseEvidence: [
            E(.document, 3, "Patient Population", "Most of {DL}'s patients had documented injuries from construction, logging, and farm work; many had been discharged by other providers after state prescribing limits."),
            E(.document, 2, "Drug Screens", "{DL} ran urine drug screens on most patients and discharged forty for misuse."),
            E(.document, 2, "Intake Form", "The undercover officer's intake form described a fictitious fall and prior surgery.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Undercover officer",
                        direct: ["\"Seven minutes, no exam, ninety pills.\""],
                        cross: ["\"I lied on the intake form.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What happened at your visit?", "\"I filled out a form saying I'd hurt my back. {DL} asked my pain level, I said eight. {DL} asked what worked before, I said oxycodone 30s. {DL} wrote ninety. Seven minutes. No exam.\""),
                            .direct("What did you pay?", "\"Three hundred cash. They don't take insurance.\""),
                            .cross("You wrote that you'd had back surgery and a fall from a ladder?", "\"Yes. Those were lies, as part of the investigation.\""),
                            .cross("{DL} relied on what you told {D.him}?", "\"{DL} didn't check any of it.\""),
                            .cross("{DL} ordered a urine drug screen?", "\"Yes, at the end.\"")
                        ]),
            WitnessSeed(name: nil, role: "Pain medicine physician for the State",
                        direct: ["\"No legitimate practice prescribes like this.\""],
                        cross: ["\"Some rural patients are badly undertreated.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is the standard of care?", "\"A physical exam, prior records, a treatment plan, non-opioid therapy first, and close monitoring. Starting a new patient on 30 mg oxycodone, ninety tablets, after seven minutes, isn't medicine.\""),
                            .direct("What about the volume?", "\"Ten times the next prescriber in the county. That's not a busy practice; that's a distribution point.\""),
                            .cross("Many rural chronic pain patients were cut off abruptly after state limits?", "\"Yes, and some suffered for it.\""),
                            .cross("{DL} discharged forty patients for misuse?", "\"That shows some monitoring.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Longtime patient",
                        direct: ["\"{DL} is the only reason I can work.\""],
                        cross: ["\"I paid cash every month.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why did you see {DL}?", "\"Fell off a roof eight years ago. Two surgeries. My doctor retired and nobody else would take me. {DL} did.\""),
                            .direct("How has treatment helped?", "\"I'm back to work part-time. Without it I'm in bed.\""),
                            .cross("Your visits were five minutes and cash?", "\"Usually. {DL} knew my history.\""),
                            .cross("Did {DL} ever examine you?", "\"The first visit, years ago.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sold oxycodone prescriptions for cash after seven-minute visits. That's drug distribution with a prescription pad."],
        defenseTheory: ["{DL} treated injured working people that other providers abandoned, screened them, and discharged abusers. A deceived provider isn't a dealer."],
        aggravating: ["The offense involved large quantities over a long period", "{DL} abused a professional license"],
        mitigating: ["{DL} monitored patients and discharged those who misused", "No prior criminal record"],
        allocutions: ["\"I took the patients no one else would. I may have trusted too much. I never sold anything.\""],
        guiltyTruths: ["The clinic's own office manager later testified {DL} told staff to 'keep them moving, cash only, no records.'"],
        innocentTruths: ["A review by the state medical board after trial found most of {DL}'s patients had legitimate, documented injuries."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-730, "Clinic opens."),
                       (-90, "Prescribing data flagged by the state."),
                       (-45, "Undercover visit."),
                       (0, "Search warrant at the clinic."),
                       (60, "{DL} charged.")],
            howIdentified: "State prescribing data and an undercover visit.",
            notDone: ["The patients who died were not linked to specific prescriptions from {DL}."],
            defendantExam: [
                .direct("Why so many prescriptions?", "\"Because nobody else would see these people. Loggers, roofers, farmers. When the limits came in, other offices dropped them overnight.\""),
                .direct("Why no exam for the officer?", "\"The officer described a documented injury and surgery. I trusted it, ordered a drug screen, and planned an exam on the next visit. I should have done it then.\""),
                .cross("Cash only.", "\"Insurers wouldn't pay for pain management. Most of my patients didn't have insurance.\""),
                .cross("Two patients died.", "\"And I grieve them. I can't control what people do with medicine after they leave.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Is {DL} a drug dealer?\"",
                                  answer: "\"In my opinion, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper opinion on guilt", shouldSustain: true,
                                  explanation: "An expert may testify about the standard of care, not offer an opinion on the defendant's guilt.",
                                  doctrineID: "expertTestimony", weight: 1))
            ],
            prosecutionOpening: "Seven minutes, no exam, ninety pills, cash. {D} ran a pill mill.",
            defenseOpening: "Injured working people abandoned by every other provider. {DL} treated them.",
            prosecutionClosing: "Prescriptions without medical purpose are distribution.",
            defenseClosing: "A provider who's lied to isn't a dealer.",
            employer: "own pain clinic"
        )
    )
}
