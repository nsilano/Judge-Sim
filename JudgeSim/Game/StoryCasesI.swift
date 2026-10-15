import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchI: [CaseTemplate] = [restaurantFire, deletedServer, witnessThreat, voicemailThreat, storageUnits]

    // MARK: - 54. The restaurant fire (an owner, a failing business, and a burned kitchen)

    static let restaurantFire = CaseTemplate(
        key: "story.restaurantFire", category: .property,
        headlines: ["Fire Destroys {REST} After Hours", "Restaurant Owner Charged With Burning Own Business"],
        primaryLaw: "burningBuildings", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Willfully and wantonly set fire to {REST}, a business building on {STREET} in {HOOD}.",
        secondary: [SecondaryCharge(lawID: "burningBuildings", specification: "Willfully set fire spreading to the dental office adjoining {REST}.", chance: 1.0, threshold: 7),
                    SecondaryCharge(lawID: "insuranceFraud", specification: "Knowingly presented a false insurance claim for fire damage to {REST} in the amount of $310,000.", chance: 1.0, threshold: 0)],
        ageRange: 38...60, occupations: ["restaurant owner"], hasVictim: false,
        summaries: [
            "At 2:50 a.m. on {DATE}, a fire gutted {REST}, a family restaurant on {STREET} in {HOOD} owned by {D}. The fire marshal found the origin in the kitchen near the fryers and traces of gasoline on the floor. {REST} was four months behind on rent and had raised its insurance coverage from $150,000 to $310,000 six weeks earlier. {DL}'s phone connected to a tower near the restaurant at 2:31 a.m.; {DL} says {D.he} drove past on the way home from {D.his} sibling's house and that a fired cook had threatened to \"burn the place down.\""
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Fire Marshal's Report", "Point of origin at the kitchen floor near the fryers; gasoline detected in floor debris by the State Crime Lab."),
            E(.document, 3, "Insurance Increase", "Coverage raised from $150,000 to $310,000 six weeks before the fire, with {DL}'s signature."),
            E(.document, 2, "Rent Ledger", "{REST} four months behind on rent; the landlord had served a notice to vacate."),
            E(.digital, 2, "Cell Site Records", "{DL}'s phone used a tower serving the block at 2:31 a.m.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Fired Cook's Threat", "A server told police that a cook fired two weeks earlier said on the way out, \"I'll burn this place down.\""),
            E(.document, 2, "Broken Back Lock", "The fire marshal noted the back door lock was broken but couldn't say whether before or during the fire."),
            E(.document, 1, "Equipment Upgrade", "Invoices for $60,000 in new kitchen equipment bought the same month as the insurance increase.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Deputy fire marshal",
                        direct: ["\"This was an incendiary fire.\""],
                        cross: ["\"The back lock was broken.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where did the fire start?", "\"On the kitchen floor in front of the fryers. The burn pattern shows a pour trail toward the dining room, and the lab found gasoline in the floor samples.\""),
                            .direct("Could it have been an accident?", "\"I ruled out the fryers, the wiring, and the gas lines. Gasoline on a kitchen floor isn't an accident.\""),
                            .cross("You can't say who poured the gasoline?", "\"No.\""),
                            .cross("The back door lock was broken?", "\"It was. Firefighters may have forced it. I can't say.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The money and the phone point to {DL}.\""],
                        cross: ["\"We spoke to the cook once.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you focus on {DL}?", "\"The business was failing, the landlord was evicting, coverage had doubled six weeks earlier, and {DL}'s phone was near the restaurant twenty minutes before the alarm.\""),
                            .direct("What did {DL} say about the phone?", "\"That {D.he} drove past on the way home from a sibling's house in Bayard.\""),
                            .cross("The fired cook threatened to burn the place down?", "\"So a server says.\""),
                            .cross("Where was the cook that night?", "\"Says home asleep. We didn't verify it.\""),
                            .cross("The insurance increase came with $60,000 in new equipment?", "\"There were invoices, yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Server at {REST}",
                        direct: ["\"The cook said, 'I'll burn this place down.'\""],
                        cross: ["\"People say things when they're fired.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did the cook say when fired?", "\"Threw the apron on the floor and said, 'I'll burn this place down. You'll see.' Everybody heard it.\""),
                            .direct("What kind of owner was {DL}?", "\"Worked harder than any of us. Paid us when {D.he} couldn't pay {D.himself}.\""),
                            .cross("People say angry things when they're fired?", "\"Sure.\""),
                            .cross("Did {DL} ever talk about the business failing?", "\"{D.He} said if things didn't turn around we'd close by summer.\"")
                        ])
        ],
        prosecutionTheory: ["Facing eviction and four months of debt, {D} doubled the insurance and burned the restaurant for the money."],
        defenseTheory: ["A fired cook threatened to burn {REST}, the back lock was broken, and the insurance went up because {DL} bought new equipment. The State never investigated anyone else."],
        aggravating: ["The offense involved planning and financial motive"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["The building's owner: \"The fire spread to the dentist's office next door. Two businesses closed for a year.\""],
        allocutions: ["\"That restaurant was my parents' dream before it was mine. I'd never burn it.\""],
        guiltyTruths: ["A gas station receipt from {DL}'s credit card for a two-gallon can and gasoline at 1:58 a.m. surfaced after trial."],
        innocentTruths: ["The fired cook's roommate later told police the cook came home at 3:30 a.m. smelling of smoke."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["REST": ["Mama Lu's Kitchen", "The Harbor Table", "Delgado's Family Restaurant"]],
        story: StoryExtras(
            timeline: [(-42, "Insurance coverage raised to $310,000."),
                       (-14, "A cook is fired and makes a threat."),
                       (0, "2:50 a.m.: fire reported; building gutted."),
                       (6, "Lab confirms gasoline in floor samples."),
                       (20, "Cell site records returned."),
                       (31, "{DL} charged.")],
            howIdentified: "Financial motive and cell site records.",
            notDone: ["The fired cook's alibi was never checked.", "No one canvassed for gas station purchases that night."],
            defendantExam: [
                .direct("Why did you raise the insurance?", "\"I'd just put sixty thousand into new equipment on a loan. The bank required it.\""),
                .direct("Why was your phone near the restaurant at 2:31?", "\"I drive that way home from my sister's. I looked at the building as I went by. I always do.\""),
                .cross("You were four months behind on rent.", "\"Restaurants run behind. I was working it out with the landlord.\""),
                .cross("You were driving past your business at 2:31 in the morning?", "\"I'd been helping my sister move. We finished late.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, in your experience do owners with failing businesses often burn them?\"",
                                  answer: "\"It's the most common motive we see.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Evidence that people in the defendant's situation often commit the crime invites conviction by category.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A failing restaurant, doubled insurance, gasoline on the floor, and the owner's phone down the block.",
            defenseOpening: "A fired cook's threat, a broken lock, and an investigation that stopped at the owner.",
            prosecutionClosing: "Every road leads back to the insurance check.",
            defenseClosing: "Motive isn't proof. The State never looked anywhere else."
        )
    )

    // MARK: - 55. The deleted server (a fired IT administrator)

    static let deletedServer = CaseTemplate(
        key: "story.deletedServer", category: .cyber,
        headlines: ["Fired IT Manager Accused of Wiping Company Servers", "Logistics Firm Loses Three Years of Records"],
        primaryLaw: "accessingComputers", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Willfully and without authorization accessed the computer network of {CO} to destroy data, causing damage over $1,000.",
        secondary: [
            SecondaryCharge(lawID: "accessingComputers", specification: "Accessed {CO}'s backup server without authorization to delete backup volumes.", chance: 1.0, threshold: 6),
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Damaged {CO}'s data and records worth more than $186,000.", chance: 1.0, threshold: 5)
        ],
        ageRange: 30...50, occupations: ["IT systems administrator"], hasVictim: false,
        summaries: [
            "On {DATE}, three days after {D} was fired as IT manager at {CO} in Port Hollis, someone logged in with a forgotten service account at 11:47 p.m. and deleted three years of shipping records and backups. The company spent $186,000 recovering what it could. The login came from a home internet address assigned to {DL}'s apartment. {DL} says the password for that account was on a sticky note in the server room for years, that two other employees knew it, and that {D.his} wireless network had no password."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Server Logs", "A login to the 'svc-backup' account at 11:47 p.m. from an IP address assigned to {DL}'s internet account, followed by deletion commands."),
            E(.document, 2, "Termination Email", "{DL}'s reply to the termination: \"You'll find out how much you needed me.\""),
            E(.digital, 2, "Search History", "{DL}'s laptop, searched under warrant, contained a search two days earlier: \"can deleted backups be recovered\".", .search),
            E(.document, 2, "Recovery Costs", "Invoices totaling $186,000 for data recovery and lost business.")
        ],
        defenseEvidence: [
            E(.physical, 2, "Sticky Note", "A photo taken by an employee a year earlier shows the svc-backup password on a sticky note on the server rack."),
            E(.document, 2, "Open Wi-Fi", "The defense expert found {DL}'s home router had no password; neighbors' devices had connected to it."),
            E(.document, 1, "Others Knew", "Two other IT staff had used the svc-backup account in the prior month.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic examiner, State Bureau of Investigation",
                        direct: ["\"The login came from {DL}'s internet connection.\""],
                        cross: ["\"An IP address identifies a connection, not a person.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the logs show?", "\"A login to the backup service account at 11:47 p.m., from an IP address the provider assigned to {DL}'s account, followed by commands deleting the shipping database and every backup volume.\""),
                            .direct("What was on {DL}'s laptop?", "\"A search for whether deleted backups can be recovered, two days before the deletion. No remote session software that would match the login.\""),
                            .cross("An IP address identifies a connection, not a person?", "\"That's correct.\""),
                            .cross("Was {DL}'s router password-protected?", "\"I understand it wasn't.\""),
                            .cross("You found no trace of the login on {DL}'s laptop?", "\"Not on that laptop.\"")
                        ]),
            WitnessSeed(name: nil, role: "{CO} operations director",
                        direct: ["\"{DL} was the only one who knew the system that well.\""],
                        cross: ["\"The password was on a note for a while.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why was {DL} fired?", "\"Repeated conflicts with management and missed deadlines on a migration project.\""),
                            .direct("What did {DL} say when fired?", "\"In writing: 'You'll find out how much you needed me.'\""),
                            .cross("The backup account's password was on a sticky note on the rack?", "\"Until about a year ago. I thought it had been changed.\""),
                            .cross("Was it changed when {DL} was fired?", "\"No. Nobody knew that account existed but IT.\""),
                            .cross("Two other IT employees knew it?", "\"Apparently.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense computer forensics expert",
                        direct: ["\"Anyone in range of that router could have done this.\""],
                        cross: ["\"I can't name anyone else.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find about {DL}'s network?", "\"An open wireless network with no password. Logs on the router show eleven unknown devices connected over the prior month, including that night.\""),
                            .direct("What about the search?", "\"{DL} was the backup administrator. Knowing whether deleted backups can be recovered is part of that job.\""),
                            .cross("You can't identify who used the network that night?", "\"No.\""),
                            .cross("Did any unknown device connect at 11:47?", "\"One connected at 11:40 and left at 12:05.\"")
                        ])
        ],
        prosecutionTheory: ["Fired and angry, {D} warned the company, researched recovering backups, and used a password only IT knew from {D.his} own home connection to wipe the servers."],
        defenseTheory: ["An open network, a password on a sticky note, and two other employees who used that account. The State traced a connection, not a person."],
        aggravating: ["The offense caused damage over $100,000"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{CO}'s owner: \"We laid off nine people the month after. Three years of customer history, gone.\""],
        allocutions: ["\"I was angry. I sent a stupid email. I didn't touch their servers.\""],
        guiltyTruths: ["A second laptop belonging to {DL}, later found at a relative's house, contained the remote session logs."],
        innocentTruths: ["One of the other IT employees, fired a month later, was found to have used the same account from a neighbor's driveway."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        extras: ["CO": ["Tidewater Freight Logistics", "Coastal Carriers Inc.", "Harborview Distribution"]],
        story: StoryExtras(
            timeline: [(-3, "{DL} fired; replies 'You'll find out how much you needed me.'"),
                       (-2, "Search on {DL}'s laptop about recovering deleted backups."),
                       (0, "11:47 p.m.: login to the backup account; deletions begin."),
                       (1, "Company discovers the loss and calls police."),
                       (14, "Internet provider returns the subscriber for the IP address."),
                       (16, "Search warrant for {DL}'s apartment; laptop seized."),
                       (40, "{DL} charged.")],
            howIdentified: "The internet provider's records for the login's IP address.",
            notDone: ["The other two IT employees' devices were never examined.", "The router's connection logs were not collected by police."],
            defendantExam: [
                .direct("Did you log in to the company's system after you were fired?", "\"No. I was home watching a game. I didn't even know my access was still alive.\""),
                .direct("Why did you search about recovering deleted backups?", "\"Because I was worried about the migration I'd left half-done. If something broke, I wanted to know if they could get it back.\""),
                .cross("You told them they'd find out how much they needed you.", "\"Because I was the only one who knew the system. Not because I was going to break it.\""),
                .cross("You never put a password on your Wi-Fi? You're an IT manager.", "\"I know. The cobbler's kids have no shoes.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Your client hired you, and you'd say whatever helps, wouldn't you?\"",
                                  answer: "\"I'd say what the logs show.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "Bias can be explored by asking about payment and relationship, but this question argues with the witness instead.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A threat, a search, and a login from {DL}'s home.",
            defenseOpening: "An open network, a password on a sticky note, and an investigation that stopped at one name.",
            prosecutionClosing: "Only an IT insider knew that account, and it came from {DL}'s house.",
            defenseClosing: "A connection isn't a person. That's reasonable doubt."
        )
    )

    // MARK: - 56. The witness threat (a brother at the gas pump)

    static let witnessThreat = CaseTemplate(
        key: "story.witnessThreat", category: .violent,
        headlines: ["Witness Says Defendant's Brother Threatened Her at Gas Station", "Intimidation Charge Filed Days Before Shooting Trial"],
        primaryLaw: "witnessIntimidation", lesserLaw: "communicatingThreats", threshold: 6, lesserThreshold: 4,
        specification: "By threats, attempted to intimidate {V}, a State's witness in a pending felony case, from testifying.",
        secondary: [
            SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened {V} with harm in a manner a reasonable person would believe.", chance: 1.0, threshold: 5)
        ],
        ageRange: 22...40, occupations: ["barber", "delivery driver"], forcedPriorOffenses: ["Possession of Schedule II (cocaine)"], hasVictim: true,
        summaries: [
            "{V} is the State's eyewitness in a pending shooting case against {D}'s younger sibling. On {DATE}, at a gas station on {STREET} in {HOOD}, {DL} walked up to {VL}'s pump and, according to {VL}, said: \"You know you don't have to go to court. Nobody needs to get hurt over this.\" {VL} reported it that night and asked to be moved. {DL} says {D.he} only asked {VL} to \"tell the truth\" and that {D.he} doesn't know what {VL} saw. The station's camera has video but no audio."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Gas Station Video", "{DL} walks from {D.his} car to {VL}'s pump, stands close for 40 seconds, and leaves. {VL} gets back in {V.his} car without finishing pumping."),
            E(.statement, 3, "911 Call", "{VL} called 911 eleven minutes later, crying: \"The brother just came up to me and said nobody needs to get hurt.\""),
            E(.document, 2, "Witness List", "{VL} was named on the State's witness list served on the defense two weeks earlier.")
        ],
        defenseEvidence: [
            E(.statement, 2, "{DL}'s Statement", "{DL} told the detective: \"I asked {VL} to tell the truth, that's all.\"", .statement),
            E(.document, 2, "Chance Meeting", "{DL}'s debit card shows {D.he} buys gas at that station four times a week; it's two blocks from {D.his} shop."),
            E(.document, 1, "No Contact Before", "No calls, texts, or social media contact from {DL} to {VL}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "State's witness in the shooting case",
                        direct: ["\"'Nobody needs to get hurt.'\""],
                        cross: ["\"{DL} didn't touch me.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did {DL} say to you?", "\"{DL} walked right up to me at the pump and said, real quiet, 'You know you don't have to go to court. Nobody needs to get hurt over this.' Then {D.he} looked at my car seat in the back.\""),
                            .direct("How did you feel?", "\"Like I was going to throw up. My son was in the car. I left the nozzle hanging.\""),
                            .cross("{DL} never touched you or showed a weapon?", "\"No.\""),
                            .cross("Isn't it true {DL} said 'just tell the truth'?", "\"That's not what {D.he} said.\""),
                            .cross("You'd already told the detective you were scared to testify, before this?", "\"Of course I was scared. That's why it worked.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{VL} called 911 within minutes.\""],
                        cross: ["\"There's no audio.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the video show?", "\"{DL} going straight to {VL}'s pump, standing close for about forty seconds, and leaving. {VL} gets in the car without finishing.\""),
                            .direct("What did {DL} say when interviewed?", "\"That {D.he} asked {VL} to tell the truth. When I asked how {D.he} knew who {VL} was, {D.he} said 'everybody knows.'\""),
                            .cross("The video has no audio?", "\"No audio.\""),
                            .cross("{DL} gets gas there four times a week?", "\"So the card records show.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Customer at the next pump",
                        direct: ["\"I heard 'tell the truth.'\""],
                        cross: ["\"I didn't hear all of it.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear?", "\"I heard the one say, 'Just tell the truth about what you saw.' That's the part I heard.\""),
                            .direct("Did it sound threatening?", "\"Not the way I heard it. Quiet.\""),
                            .cross("You know {DL}?", "\"From the barbershop. {D.He} cuts my hair.\""),
                            .cross("You didn't hear the whole forty seconds?", "\"No, I was paying at the pump.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sought out the witness against {D.his} sibling and delivered a quiet threat designed to keep {VL} off the stand."],
        defenseTheory: ["A chance meeting at a station {DL} uses four times a week, and a plea to tell the truth. Fear is understandable, but it isn't proof of a threat."],
        aggravating: ["The offense was committed to hinder the administration of justice"],
        mitigating: ["The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"I moved my son out of the county. He had to change schools. I still testified.\""],
        allocutions: ["\"I love my brother. I never threatened anybody.\""],
        guiltyTruths: ["Jail call recordings later showed {DL}'s sibling telling {DL} to \"go talk to\" {VL} the day before."],
        innocentTruths: ["A second customer, found later, heard {DL} say only \"tell the truth, please\" and \"I'm sorry.\""],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-14, "State's witness list naming {VL} served on the defense in the shooting case."),
                       (0, "Encounter at the gas station; {VL} calls 911."),
                       (1, "Video collected from the station."),
                       (3, "{DL} interviewed and charged.")],
            howIdentified: "{VL} recognized {DL} as the defendant's brother.",
            notDone: ["Jail calls from {DL}'s sibling were not reviewed before trial."],
            defendantExam: [
                .direct("Why did you go to {VL}'s pump?", "\"I saw {V.him} and I just wanted to say: please tell the truth. My brother says he didn't do it.\""),
                .direct("Did you say 'nobody needs to get hurt'?", "\"I said, 'Nobody else needs to get hurt over this.' Meaning my brother going to prison for something he didn't do.\""),
                .cross("You knew who {VL} was and that {V.he} was a witness.", "\"Everybody in the neighborhood knows.\""),
                .cross("You looked at {V.his} child's car seat.", "\"I don't remember doing that.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"Ms. {VL}, isn't it true your own cousin has a grudge against my client's family?\"",
                                  answer: "\"My cousin has nothing to do with this.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: true,
                                  explanation: "A relative's grudge, with no showing the witness shares it, doesn't bear on the witness's own bias.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Forty seconds at a gas pump, and a message delivered quietly.",
            defenseOpening: "A brother's plea for the truth, heard through a witness's fear.",
            prosecutionClosing: "'Nobody needs to get hurt' only means one thing to a witness.",
            defenseClosing: "Words without audio, a station {DL} uses every day, and reasonable doubt.",
            genders: ["V": .female]
        )
    )

    // MARK: - 57. The voicemail threat (a neighbor and a property line)

    static let voicemailThreat = CaseTemplate(
        key: "story.voicemailThreat", category: .violent,
        headlines: ["Neighbor Charged Over Voicemail: 'You'll Be Sorry'", "Property Line Feud Ends Up in Superior Court"],
        primaryLaw: "communicatingThreats", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Willfully threatened to physically injure {V} in a voicemail, in a manner that a reasonable person would believe the threat was likely to be carried out.",
        ageRange: 55...75, occupations: ["retired machinist"], hasVictim: true,
        summaries: [
            "After {V} built a fence that {D} said was two feet onto {D.his} land on {STREET} in {HOOD}, {DL} left a voicemail on {DATE}: \"Take that fence down by Friday or you'll be sorry. I've got a shotgun and I know how to use it, and I've got nothing to lose.\" {VL} called the sheriff. {DL} owns a shotgun and had shot a raccoon in {D.his} yard a month earlier. {DL} says {D.he} meant {D.he}'d sue and that the shotgun line was about raccoons. {DL} was convicted in district court and appealed."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Voicemail", "The 31-second voicemail, in {DL}'s voice, played in court."),
            E(.physical, 2, "Shotgun", "A 12-gauge shotgun {DL} keeps by the back door, surrendered voluntarily."),
            E(.document, 1, "Prior Complaint", "{VL} had reported {DL} for yelling at {V.his} contractor two weeks earlier.")
        ],
        defenseEvidence: [
            E(.document, 2, "Survey", "A licensed survey shows {VL}'s fence is 1.8 feet onto {DL}'s property."),
            E(.document, 2, "Lawyer Consultation", "A receipt for a consultation with a real estate lawyer the day after the voicemail."),
            E(.document, 1, "No Approach", "{DL} never went onto {VL}'s property or confronted {V.him} in person after the voicemail.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Neighbor",
                        direct: ["\"I believed {D.he} would shoot me.\""],
                        cross: ["\"I knew about the survey.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you react to the voicemail?", "\"I didn't let my kids play in the backyard for a month. I'd seen {DL} shoot an animal from the porch.\""),
                            .direct("Why did you believe it?", "\"'I've got a shotgun and I know how to use it, and I've got nothing to lose.' What else does that mean?\""),
                            .cross("You'd seen the survey showing your fence is on {DL}'s land?", "\"I'd heard about it. I had my own survey.\""),
                            .cross("{DL} never came on your property or confronted you after the voicemail?", "\"No. We stayed away.\"")
                        ]),
            WitnessSeed(name: nil, role: "Sheriff's deputy",
                        direct: ["\"{DL} said 'I meant every word.'\""],
                        cross: ["\"{D.He} said {D.he} meant the lawsuit.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} say when you visited?", "\"That {D.he} meant every word. Then {D.he} said {D.he} meant {D.he}'d take {VL} to court.\""),
                            .direct("Did {DL} have the shotgun?", "\"By the back door, loaded. {D.He} handed it over when I asked.\""),
                            .cross("{DL} said the shotgun was for raccoons getting in {D.his} chicken coop?", "\"{D.He} did say that.\""),
                            .cross("{DL} cooperated completely?", "\"Yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Surveyor",
                        direct: ["\"The fence is on {DL}'s land.\""],
                        cross: ["\"That doesn't excuse a threat.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Where is the fence?", "\"Between 1.6 and 2.1 feet onto {DL}'s parcel along its whole length.\""),
                            .cross("A property dispute doesn't justify a threat?", "\"I'm a surveyor. I can tell you where the line is.\"")
                        ])
        ],
        prosecutionTheory: ["{D} mentioned a shotgun, said {D.he} had nothing to lose, and set a deadline. A reasonable person would believe that."],
        defenseTheory: ["An angry old neighbor with a real grievance, who meant a lawsuit, saw a lawyer the next day, and never came near {VL}. Bluster isn't a true threat."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community"],
        victimImpacts: ["{V}: \"I still check the window before I let the kids out.\""],
        allocutions: ["\"I said a stupid thing in anger. I'm seventy years old. I wasn't going to shoot anybody over a fence.\""],
        guiltyTruths: ["A second voicemail, deleted by {VL} and recovered from the carrier, said \"I'll be waiting.\""],
        innocentTruths: ["{DL}'s doctor later confirmed {DL} had early dementia that affected impulse control at the time."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-30, "{DL} shoots a raccoon from the porch."),
                       (-14, "{VL} reports {DL} for yelling at a fence contractor."),
                       (0, "Voicemail left; {VL} calls the sheriff."),
                       (0, "Deputy visits {DL}; shotgun surrendered."),
                       (1, "{DL} consults a real estate lawyer."),
                       (2, "{DL} charged.")],
            howIdentified: "{DL}'s own voicemail.",
            notDone: [],
            defendantExam: [
                .direct("What did you mean by 'you'll be sorry'?", "\"That I'd sue. I went to a lawyer the next morning. You can check.\""),
                .direct("Why mention the shotgun?", "\"Because I'd told {VL} the week before I'd been shooting raccoons and {V.he} called me crazy. It was a dumb thing to throw in.\""),
                .cross("'I've got nothing to lose.' What did you mean?", "\"My spouse is gone, my knees are shot, and someone stole two feet of my land. I meant I'd spend whatever it took in court.\""),
                .cross("You told the deputy you meant every word.", "\"I meant I was serious about the fence.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"You built that fence on purpose to provoke {DL}, didn't you?\"",
                                  answer: "\"No.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Assumes facts not in evidence", shouldSustain: false,
                                  explanation: "The survey is in evidence; asking whether the fence was deliberate is fair cross-examination about motive and bias.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A deadline, a shotgun, and nothing to lose.",
            defenseOpening: "An old neighbor, a real property dispute, and an angry voicemail followed by a lawyer.",
            prosecutionClosing: "A reasonable person hears that message and fears for their life.",
            defenseClosing: "Ugly words, real grievance, no true threat."
        )
    )

    // MARK: - 58. The storage units (a string of break-ins and a keypad log)

    static let storageUnits = CaseTemplate(
        key: "story.storageUnits", category: .property,
        headlines: ["Nine Storage Units Broken Into Overnight", "Self-Storage Break-Ins: Keypad Code Leads to Tenant"],
        primaryLaw: "feloniousBE", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Broke and entered storage units at {FAC} on {STREET} with intent to commit larceny therein.",
        secondary: [SecondaryCharge(lawID: "feloniousBE", specification: "Broke and entered a second storage unit at {FAC} with intent to commit larceny.", chance: 1.0, threshold: 5),
                    SecondaryCharge(lawID: "feloniousBE", specification: "Broke and entered a third storage unit at {FAC} with intent to commit larceny.", chance: 1.0, threshold: 5),
                    SecondaryCharge(lawID: "feloniousBE", specification: "Broke and entered a fourth storage unit at {FAC} with intent to commit larceny.", chance: 1.0, threshold: 5),
                    SecondaryCharge(lawID: "possStolen", specification: "Possessed a generator belonging to {V}, knowing it to be stolen.", chance: 1.0, threshold: 4),
                    SecondaryCharge(lawID: "injuryRealProperty", specification: "Damaged nine storage unit locks at {FAC}.", chance: 1.0, threshold: 3),
                    SecondaryCharge(lawID: "felonyLarceny", specification: "Stole tools, electronics, and a generator valued at more than $1,000 from storage units at {FAC}.", chance: 1.0, threshold: 0)],
        ageRange: 25...45, occupations: ["online reseller"], forcedPriorOffenses: ["Breaking or Entering"], hasVictim: true,
        summaries: [
            "Overnight on {DATE}, nine units at {FAC} on {STREET} were opened with bolt cutters, and tools, electronics, and a generator were taken, including {V}'s. The gate keypad log shows {D}'s personal code entered at 1:12 a.m. and again at 3:40 a.m. {DL} rents a unit there and sells used tools online; two weeks later, a listing on {DL}'s account showed a generator matching {VL}'s, with a serial number one digit off. {DL} says {D.he} came that night to pick up inventory, that {D.his} code was on a lanyard {D.he} lent to a friend, and that {D.he} bought the generator at a flea market."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Keypad Log", "{DL}'s personal gate code entered at 1:12 a.m. and 3:40 a.m.; no other codes used between 11:00 p.m. and 6:00 a.m."),
            E(.digital, 2, "Online Listing", "A listing on {DL}'s reseller account for a generator matching {VL}'s model, posted 14 days later."),
            E(.physical, 2, "Bolt Cutters", "Bolt cutters in {DL}'s unit, with paint transfer consistent with the cut locks.", .search),
            E(.video, 1, "Gate Camera", "A pickup enters at 1:12 a.m. Plate not legible; same color and body style as {DL}'s truck.")
        ],
        defenseEvidence: [
            E(.document, 2, "Serial Number", "The generator in the listing has a serial number one digit different from {VL}'s receipt."),
            E(.document, 2, "Flea Market Receipt", "A handwritten receipt for a generator from a flea market vendor, dated nine days after the break-ins."),
            E(.statement, 1, "Lanyard", "{DL}'s friend acknowledged borrowing the keycard lanyard \"sometime that month.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Storage tenant",
                        direct: ["\"That's my generator.\""],
                        cross: ["\"The serial number's off by one.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was taken from your unit?", "\"A generator, a miter saw, and two drills. About $2,400.\""),
                            .direct("Did you recognize the listing?", "\"The scratch on the handle where I backed into it. That's mine.\""),
                            .cross("The serial number in the photo doesn't match your receipt?", "\"One digit. Maybe the photo's blurry.\""),
                            .cross("That model is common?", "\"It's popular, yeah.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The only code used that night was {DL}'s.\""],
                        cross: ["\"Codes can be shared.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the keypad log show?", "\"{DL}'s code at 1:12 and 3:40. Nobody else entered between eleven and six.\""),
                            .direct("What was in {DL}'s unit?", "\"Bolt cutters with paint transfer that matched the color of the cut locks, and resale inventory.\""),
                            .cross("Was the gate ever propped open or broken?", "\"The manager says it sometimes sticks open.\""),
                            .cross("Lock paint transfer is a common color?", "\"The locks are the facility's standard red. It's a common red.\""),
                            .cross("Did you find any of the stolen tools in {DL}'s unit?", "\"No.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Flea market vendor",
                        direct: ["\"I sold {DL} a generator.\""],
                        cross: ["\"I don't keep records of where I get stuff.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Did you sell {DL} a generator?", "\"Yes, at the Saturday market. {DL} buys from me a lot. I wrote a receipt.\""),
                            .cross("Where did you get that generator?", "\"Somebody brought it to my table. I don't ask.\""),
                            .cross("So it could have been stolen?", "\"I suppose anything could.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s code opened the gate twice that night, {D.his} bolt cutters match the locks, and {D.he} listed a stolen generator two weeks later."],
        defenseTheory: ["A code on a borrowed lanyard, a gate that sticks open, a serial number that doesn't match, and none of the stolen property in {DL}'s unit."],
        aggravating: [],
        mitigating: ["The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"Those tools were my side business. I couldn't take jobs for two months.\""],
        allocutions: ["\"I buy and sell. That's not a crime. I didn't break into anybody's unit.\""],
        guiltyTruths: ["The friend later said the lanyard was returned two weeks before the break-ins."],
        innocentTruths: ["The friend who borrowed the lanyard was arrested a month later with tools from the same break-ins."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["FAC": ["Route 17 Self Storage", "Harbor Lock & Store", "Cane Creek Mini Storage"]],
        story: StoryExtras(
            timeline: [(0, "1:12 a.m. and 3:40 a.m.: {DL}'s gate code used; nine units broken into."),
                       (1, "Tenants report losses; keypad log pulled."),
                       (14, "Generator listing appears on {DL}'s account."),
                       (16, "Search warrant for {DL}'s unit; bolt cutters seized."),
                       (17, "{DL} charged.")],
            howIdentified: "The facility's keypad log.",
            notDone: ["The friend who borrowed the lanyard was never interviewed by police.", "The listed generator was never physically examined."],
            defendantExam: [
                .direct("Were you at the facility that night?", "\"No. I was home. I'd lent my keycard lanyard with the code on it to a friend who needed to store a couch.\""),
                .direct("Where did the generator come from?", "\"A flea market vendor I buy from every week. I have the receipt.\""),
                .cross("You have a prior breaking or entering conviction.", "\"Eight years ago. I've built a business since then.\""),
                .cross("The code was written on the lanyard?", "\"On a piece of tape. I'm bad with numbers.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, was {DL} already known to you?\"",
                                  answer: "\"Yes, from a prior break-in case.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character evidence", shouldSustain: true,
                                  explanation: "Mentioning the prior case to show propensity violates Rule 404(b).",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "{DL}'s code, {DL}'s bolt cutters, and {DL}'s listing.",
            defenseOpening: "A borrowed code, a common lock color, and a serial number that doesn't match.",
            prosecutionClosing: "Only one code opened that gate that night.",
            defenseClosing: "A code isn't a person, and the generator isn't the victim's."
        )
    )
}
