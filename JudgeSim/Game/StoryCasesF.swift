import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchF: [CaseTemplate] = [affairExtortion, fenceLine, inspectorCash, parkingLotSleeper, romanceScam]

    // MARK: - 39. Pay or I tell (extortion)

    static let affairExtortion = CaseTemplate(
        key: "story.affairExtortion", category: .whiteCollar,
        headlines: ["Former Employee Charged With Extorting Executive", "'Pay or Your Family Finds Out'"],
        primaryLaw: "extortion", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Threatened to disclose {V}'s private affair unless paid $60,000.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Sent electronic messages to {V} threatening to expose {V.him} to extort money.", chance: 1.0, threshold: 3)
        ],
        ageRange: 27...45, occupations: ["former executive assistant"], hasVictim: true,
        summaries: [
            "{D} worked for two years as executive assistant to {V}, a regional bank vice president in {CITY}, until being laid off in a restructuring. A month later, {VL} received an anonymous message with photos of {V.him} and a coworker at a hotel and the line: \"$60,000 or your spouse, your board, and the newspaper get these. You have a week.\" The payment instructions led to a crypto wallet. The State says {DL} sent it out of anger over the layoff. {DL} says {D.he} knew about the affair but never sent any message, and that the coworker, also laid off, had more reason to."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Crypto Wallet", "The wallet named in the demand had been funded once, months earlier, from an exchange account registered to {DL}.", .search),
            E(.digital, 2, "Hotel Photos", "The photos were taken from a parking lot with a phone model {DL} owns; their metadata was stripped.", .search),
            E(.statement, 2, "Exit Interview", "At {DL}'s exit interview: \"After everything I've covered for {VL}, this is how I'm treated? We'll see.\"")
        ],
        defenseEvidence: [
            E(.document, 3, "Wallet Sharing", "{DL} and the laid-off coworker co-managed a small crypto investment group; the coworker had the wallet's recovery phrase, according to group messages."),
            E(.document, 2, "Coworker's Layoff", "The coworker in the photos was laid off the same week and lost a $40,000 bonus."),
            E(.document, 1, "Phone Model", "The phone model that took the photos is the best-selling phone in the country.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Bank vice president",
                        direct: ["\"Only a handful of people knew, and {DL} kept my calendar.\""],
                        cross: ["\"The coworker in the photos was laid off too.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did the demand arrive?", "\"An encrypted message app I'd never used. The photos, the number, a wallet address, and a week. I went to the police that day. I told my spouse that night.\""),
                            .direct("Who knew about the relationship?", "\"The coworker, and {DL}, who kept my calendar and saw the hotel charges. Nobody else.\""),
                            .direct("How did {DL} react to the layoff?", "\"Bitter. {DL} said 'after everything I've covered for you.' I took that as a threat even then.\""),
                            .cross("The coworker in the photos was laid off the same week and lost a bonus?", "\"Yes.\""),
                            .cross("The coworker knew everything you just said {DL} knew, and more?", "\"Of course.\""),
                            .cross("You never received a single message from {DL}'s phone or accounts?", "\"Not directly.\"")
                        ]),
            WitnessSeed(name: nil, role: "Cyber crimes analyst",
                        direct: ["\"The wallet traces back to {DL}'s exchange account.\""],
                        cross: ["\"Anyone with the recovery phrase controls a wallet.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the blockchain show?", "\"The wallet in the demand received a single deposit seven months ago from an exchange account in {DL}'s name. Nothing since.\""),
                            .direct("Could someone else use that wallet?", "\"Only if they had the recovery phrase.\""),
                            .cross("The group messages show the coworker had the recovery phrase?", "\"Someone posted it in the group chat to the coworker, yes.\""),
                            .cross("The message app account was created from a VPN you couldn't trace?", "\"Correct.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Member of the crypto investment group",
                        direct: ["\"The coworker ran that wallet as much as {DL} did.\""],
                        cross: ["\"I don't know who sent the demand.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was the group?", "\"Five of us from work pooling small amounts into crypto. {DL} set up the wallet, but the coworker in the photos managed most of the trades and had the recovery phrase.\""),
                            .cross("You don't know who sent the message?", "\"No.\""),
                            .cross("{DL} set up the wallet?", "\"Yes, at the beginning.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew the secret, threatened revenge at the exit interview, and demanded payment into {D.his} own wallet."],
        defenseTheory: ["The coworker in the photos had the same knowledge, the same grudge, a lost bonus, and the wallet's recovery phrase. The State picked the assistant."],
        aggravating: ["The offense was motivated by revenge"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I made my own mistakes, and I've paid for them at home. Being hunted by someone I trusted is something else.\""],
        allocutions: ["\"I was angry about the layoff. I'd never blackmail anyone.\""],
        guiltyTruths: ["A draft of the demand was later found in {DL}'s cloud notes."],
        innocentTruths: ["The coworker later admitted sending the demand to {DL}'s former friend in a recorded call."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-210, "Single deposit to the wallet from {DL}'s exchange account."),
                       (-35, "{DL} and the coworker laid off."),
                       (0, "Demand message received by {VL}."),
                       (0, "{VL} reports to police."),
                       (40, "Blockchain analysis links wallet to {DL}; {DL} charged.")],
            howIdentified: "The wallet in the demand traced to {DL}'s exchange account.",
            notDone: ["The coworker was never interviewed as a suspect."],
            defendantExam: [
                .direct("Did you send the message?", "\"No. I knew about the affair for a year and never said a word to anyone. Why would I wait until I had nothing to lose and then use my own wallet?\""),
                .direct("What did you mean, 'We'll see'?", "\"That I'd see if I could get severance through a lawyer. That's all.\""),
                .cross("You set up that wallet.", "\"For our group. Four other people could access it.\""),
                .cross("You owned the same model phone that took the photos.", "\"So does half the country.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"How many times did you lie to your spouse during the affair?\"",
                                  answer: "\"I don't see how that's relevant.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance; harassment", shouldSustain: true,
                                  explanation: "The victim's private dishonesty in the affair has no bearing on who sent the demand; the court may protect witnesses from harassment (Rule 611).",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A secret {D} knew, a threat at the exit interview, and {D.his} own wallet.",
            defenseOpening: "The coworker had the secret, a bigger grudge, and the wallet's keys.",
            prosecutionClosing: "Revenge and access both point to {DL}.",
            defenseClosing: "Both point to the coworker too. That's reasonable doubt."
        )
    )

    // MARK: - 40. The fence line (defense of home)

    static let fenceLine = CaseTemplate(
        key: "story.fenceLine", category: .violent,
        headlines: ["Neighbor Shot Over Fence Dispute", "Did the Castle Doctrine Apply in the Backyard?"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 1, lesserThreshold: 1,
        specification: "Killed {V} with a shotgun, with malice.",
        ageRange: 50...72, occupations: ["retired machinist"], hasVictim: true,
        summaries: [
            "For two years {D} and {D.his} neighbor {V} fought over a property line in {HOOD}: surveys, a lawsuit, a torn-down fence, a magistrate's order. At about {TIME} on {DATE}, {VL} came into {DL}'s backyard with a sledgehammer to knock down a new fence post. {DL} came out the back door with a shotgun and told {VL} to leave. {VL} walked toward the porch. {DL} fired once from the porch steps; {VL} died in the yard twelve feet away. {DL} says {VL} came at {DL} with the sledgehammer raised. The State says {VL} was turning away and the hammer was down."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Autopsy", "A shotgun wound entering the left side and upper back, at an angle suggesting {VL} was turned partly away from the porch."),
            E(.physical, 2, "Sledgehammer Position", "The sledgehammer lay four feet from {VL}'s body, toward the fence, not toward the porch."),
            E(.statement, 2, "Prior Threat", "A neighbor heard {DL} say a week earlier: \"Next time {VL} comes over that line, it's the last time.\"")
        ],
        defenseEvidence: [
            E(.statement, 3, "911 Call", "{DL}, 40 seconds after the shot: \"{VL} came at me with a sledgehammer on my own porch, I shot {V.him}, send an ambulance.\""),
            E(.document, 2, "Restraining Order Request", "Two months earlier, {DL} asked a magistrate for a no-contact order, describing {VL} swinging a shovel at {DL}'s dog."),
            E(.document, 2, "Castle Doctrine", "The shooting occurred within {DL}'s own fenced backyard curtilage.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"{VL} was turned partly away.\""],
                        cross: ["\"A person swinging a hammer can twist.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the wound show?", "\"Pellets entered the left side of the chest and the left upper back. The center of the pattern was behind the left armpit.\""),
                            .direct("What does that mean for position?", "\"{VL}'s left side and back were toward the shooter. That's someone turned at least partly away.\""),
                            .cross("A right-handed person raising a sledgehammer over the right shoulder turns the left side toward whoever is in front?", "\"That's possible.\""),
                            .cross("You can't tell the court where the hammer was at the moment of the shot?", "\"No.\"")
                        ]),
            WitnessSeed(name: nil, role: "Neighbor across the street",
                        direct: ["\"{DL} said it would be the last time.\""],
                        cross: ["\"{VL} had threatened {DL} too.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear the week before?", "\"{DL} at the mailbox, telling me, 'Next time {VL} comes over that line, it's the last time.' I thought it was talk.\""),
                            .direct("What did you see the day of the shooting?", "\"{VL} walking into {DL}'s yard with the sledgehammer over a shoulder, calm, like going to work. I went inside. Then the shot.\""),
                            .cross("You didn't see the shooting itself?", "\"No.\""),
                            .cross("{VL} had swung a shovel at {DL}'s dog?", "\"I heard about it. I didn't see it.\""),
                            .cross("{VL} told you once that {DL} 'had it coming'?", "\"Something like that, last summer.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Crime scene reconstructionist",
                        direct: ["\"The hammer could have been thrown aside as {VL} fell.\""],
                        cross: ["\"I can't prove it was raised.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the hammer's location tell you?", "\"Very little. A person hit by a shotgun at twelve feet often spins and drops whatever they're holding. A hammer raised over the right shoulder would naturally fall behind and to the side.\""),
                            .direct("And the wound angle?", "\"Consistent with someone raising a hammer over the right shoulder while facing the porch.\""),
                            .cross("It's also consistent with someone turning away?", "\"It's consistent with both.\"")
                        ])
        ],
        prosecutionTheory: ["{D} promised it would be 'the last time,' came out armed, and shot {V} as {V.he} turned away."],
        defenseTheory: ["{VL} came into {DL}'s own yard with a sledgehammer after months of threats. North Carolina law presumes fear of death when someone unlawfully enters your home's curtilage with force."],
        aggravating: ["{DL} had announced an intent to harm {VL}"],
        mitigating: ["{VL} unlawfully entered {DL}'s yard with a weapon", "No prior criminal record", "{DL} immediately called 911"],
        victimImpacts: ["{VL}'s sibling: \"It was a fence. Two old neighbors and a fence.\""],
        allocutions: ["\"I didn't want this. I begged the magistrate for help. I thought {VL} was going to kill me on my own porch.\""],
        guiltyTruths: ["A home security camera later recovered from {DL}'s shed showed {VL} lowering the hammer and turning before the shot."],
        innocentTruths: ["The same camera showed the hammer raised over {VL}'s shoulder at the moment of the shot."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense"],
        extras: ["TIME": ["4:35 p.m."]],
        story: StoryExtras(
            timeline: [(-730, "Property line dispute begins."),
                       (-60, "{DL} requests a no-contact order."),
                       (-7, "{DL}'s remark to the neighbor about 'the last time.'"),
                       (0, "4:35 p.m.: shot fired; 4:36 p.m.: {DL} calls 911."),
                       (5, "{DL} charged with second-degree murder.")],
            howIdentified: "{DL} called 911 and reported the shooting.",
            notDone: ["{DL}'s home security system was not searched for video."],
            defendantExam: [
                .direct("What happened?", "\"I heard the hammer on the new post. I took the shotgun, went to the back door, and told {VL} to leave. {VL} turned toward me and came across the yard with the hammer coming up. I fired.\""),
                .direct("What did you mean, 'the last time'?", "\"That I'd call the sheriff and finally get an order. I'd been trying for months.\""),
                .cross("You brought a shotgun to tell someone to leave.", "\"{VL} had a sledgehammer. I'm sixty-eight.\""),
                .cross("{VL} was shot in the back.", "\"The side. {VL} was winding up.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Did you think {DL} was capable of killing someone?\"",
                                  answer: "\"After that comment, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character opinion", shouldSustain: true,
                                  explanation: "A lay witness's opinion that the defendant was 'capable of killing' is improper character evidence and speculation.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "'The last time.' Then a shotgun, and a wound in {V}'s side and back.",
            defenseOpening: "Someone with a sledgehammer in {DL}'s yard after months of threats. The law presumes {DL}'s fear was reasonable.",
            prosecutionClosing: "The presumption is rebutted when the intruder is leaving.",
            defenseClosing: "The State hasn't proven {VL} was leaving."
        )
    )

    // MARK: - 41. The inspector's envelope (bribery)

    static let inspectorCash = CaseTemplate(
        key: "story.inspectorCash", category: .whiteCollar,
        headlines: ["County Inspector Charged With Taking Bribes", "Cash Envelopes and Passed Inspections"],
        primaryLaw: "bribery", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "As a public officer, accepted cash from a contractor in exchange for passing building inspections.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by certifying fire blocking in two homes that had none.", chance: 1.0, threshold: 3)
        ],
        ageRange: 40...60, occupations: ["county building inspector"], hasVictim: false,
        summaries: [
            "{D}, a Hollis County building inspector for nineteen years, was recorded by an FBI-assisted sting taking an envelope with $1,500 from {CONTRACTOR}, a developer cooperating with investigators, at a job site on {STREET}. Over the prior year, {DL} had passed 38 inspections for that developer, including two homes later found with missing fire blocking. {DL} says the envelope was repayment of a personal loan to the developer, and that the developer set {D.him} up to escape {CONTRACTOR}'s own fraud charges."
        ],
        prosecutionEvidence: [
            E(.video, 4, "Recorded Handoff", "Hidden camera: {CONTRACTOR} hands {DL} an envelope and says \"for keeping things moving.\" {DL} says \"appreciate it\" and pockets it."),
            E(.document, 2, "Inspection Records", "{DL} passed 38 inspections for the developer in a year, two with missing fire blocking later found by another inspector."),
            E(.document, 2, "Bank Deposits", "Monthly cash deposits of $1,000 to $2,000 into {DL}'s account over the same year.")
        ],
        defenseEvidence: [
            E(.document, 3, "Developer's Plea Deal", "{CONTRACTOR} faces fraud charges for falsifying buyer documents and agreed to cooperate in exchange for leniency."),
            E(.document, 2, "Loan Text", "A year earlier {DL} texted {CONTRACTOR}: \"Need that $6,000 back by spring, no rush.\" {CONTRACTOR} replied: \"I'll pay you in chunks.\""),
            E(.document, 1, "Inspection Volume", "{DL} inspected over 1,100 homes that year; the two failures are within normal error rates.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{CONTRACTOR}, cooperating developer",
                        direct: ["\"I paid {DL} every month to pass my jobs.\""],
                        cross: ["\"I'm cooperating to get a deal.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did the payments start?", "\"Two years ago {DL} failed a framing inspection and told me there were ways to 'keep things moving.' I took the hint.\""),
                            .direct("How much did you pay?", "\"Fifteen hundred a month, cash, for about a year.\""),
                            .cross("You're charged with fraud yourself?", "\"Yes.\""),
                            .cross("Your deal depends on delivering someone?", "\"It depends on telling the truth.\""),
                            .cross("You borrowed $6,000 from {DL} and said you'd pay it back in chunks?", "\"That was a separate thing. I paid that back already.\""),
                            .cross("No receipt, no record of that repayment?", "\"It was cash.\"")
                        ]),
            WitnessSeed(name: nil, role: "FBI special agent",
                        direct: ["\"{DL} said 'appreciate it' and took the envelope.\""],
                        cross: ["\"{DL} didn't mention inspections on the recording.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the recording capture?", "\"{CONTRACTOR} saying 'for keeping things moving,' {DL} saying 'appreciate it' and pocketing $1,500 in marked bills.\""),
                            .direct("What do the deposits show?", "\"Cash deposits averaging about $1,500 a month into {DL}'s account, starting the month after the framing inspection {CONTRACTOR} described.\""),
                            .cross("{DL} never said the word 'inspection' on the recording?", "\"Not on that recording.\""),
                            .cross("{DL} also has a side business repairing lawn equipment for cash?", "\"We saw that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Senior county inspector",
                        direct: ["\"Missed fire blocking happens to good inspectors.\""],
                        cross: ["\"I never took cash from a builder.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How common are missed items?", "\"With our caseloads, twenty-plus inspections a day, we all miss things. Two misses out of thirty-eight isn't unusual.\""),
                            .direct("What's {DL}'s reputation?", "\"Honest, hard, a little gruff. Builders complained {DL} was too strict.\""),
                            .cross("Have you ever accepted cash from a builder?", "\"Never.\""),
                            .cross("Would you say 'appreciate it' if handed an envelope 'for keeping things moving'?", "\"I'd ask what it was for.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took $1,500 'for keeping things moving,' on camera, from a developer whose jobs {D.he} kept passing."],
        defenseTheory: ["{CONTRACTOR} owed {DL} $6,000 and is trading {D.him} for leniency on {CONTRACTOR}'s own fraud. 'Keeping things moving' was the developer's script, not {DL}'s words."],
        aggravating: ["The offense endangered public safety"],
        mitigating: ["Nineteen years of public service", "No prior criminal record"],
        allocutions: ["\"That money was mine. I lent it when {CONTRACTOR} was going under. I never sold an inspection.\""],
        guiltyTruths: ["A ledger in {DL}'s truck later listed the developer's address with monthly checkmarks."],
        innocentTruths: ["{CONTRACTOR}'s former bookkeeper later testified the developer bragged about framing the inspector who 'wouldn't play ball.'"],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["CONTRACTOR": ["Ridgeway Homes", "Pinnacle Builders", "Sterling Custom Homes"]],
        story: StoryExtras(
            timeline: [(-400, "{DL} texts about the $6,000 loan."),
                       (-360, "Monthly cash deposits begin in {DL}'s account."),
                       (-60, "{CONTRACTOR} charged with fraud; agrees to cooperate."),
                       (0, "Recorded handoff at the job site."),
                       (30, "{DL} charged with bribery.")],
            howIdentified: "A cooperating developer and a recorded handoff.",
            notDone: ["The claimed loan repayment was never investigated.", "{DL}'s lawn-equipment business income was never compared to the deposits."],
            defendantExam: [
                .direct("What was the envelope?", "\"Another payment on the six thousand. {CONTRACTOR} had paid me in chunks since spring. I said 'appreciate it' because I was getting my money back.\""),
                .direct("What about 'keeping things moving'?", "\"I didn't think about it. {CONTRACTOR} talks like that about everything.\""),
                .direct("And the monthly deposits?", "\"My lawn mower business. I fix engines on weekends, cash only.\""),
                .cross("A county inspector lending money to a developer you inspect?", "\"It was a mistake to lend it. It wasn't a bribe.\""),
                .cross("You passed two houses missing fire blocking.", "\"Out of eleven hundred inspections that year. I missed them.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Did other contractors pay {DL} too?\"",
                                  answer: "\"I heard some did.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay and speculation", shouldSustain: true,
                                  explanation: "Rumors about other payments are hearsay and speculation with no foundation.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "An envelope 'for keeping things moving,' on camera, and a year of cash deposits.",
            defenseOpening: "A cooperating fraudster who owed {DL} money and needed someone to trade.",
            prosecutionClosing: "The video speaks.",
            defenseClosing: "The video shows a payment, not a bribe."
        )
    )

    // MARK: - 42. Asleep at the wheel (habitual DWI)

    static let parkingLotSleeper = CaseTemplate(
        key: "story.parkingLotSleeper", category: .traffic,
        headlines: ["Driver Found Asleep in Running Car Charged With Habitual DWI", "Driving, or Sleeping It Off?"],
        primaryLaw: "habitualDWI", lesserLaw: "dwi", threshold: 2, lesserThreshold: 1,
        specification: "Drove a vehicle while impaired, having three prior DWI convictions within ten years.",
        secondary: [
            SecondaryCharge(lawID: "dwlrImpaired", specification: "Drove while {D.his} license was revoked for a prior impaired driving conviction.", chance: 1.0, threshold: 1)
        ],
        ageRange: 35...58, occupations: ["welder"], forcedPriorOffenses: ["Driving While Impaired@8", "Driving While Impaired@5", "Driving While Impaired@2"], hasVictim: false,
        summaries: [
            "At about {TIME} on {DATE}, an officer found {D} asleep in the driver's seat of {D.his} running pickup in the parking lot of a bar on {STREET} in {HOOD}, headlights on, heater running, transmission in park. {DL} blew 0.14. {DL} has three DWI convictions in the last nine years, making this a felony if {D.he} was \"driving.\" {DL} says {D.he} knew {D.he} was too drunk to drive, went to the truck to sleep it off in the heat, and never intended to move."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Breath Test", "Intoxilyzer result of 0.14 at 2:51 a.m., about forty minutes after {DL} was found."),
            E(.physical, 2, "Engine Running, Lights On", "Truck running, headlights on, in park. The hood was warm, and the bar's lot camera shows the truck arriving at 10:05 p.m."),
            E(.document, 2, "Prior Convictions", "Three DWI convictions in the past nine years.")
        ],
        defenseEvidence: [
            E(.document, 3, "Weather", "The temperature was 19°F; the heater needed the engine running."),
            E(.statement, 2, "Rideshare Attempt", "{DL}'s phone shows a canceled rideshare request at 12:48 a.m., with no drivers available."),
            E(.video, 2, "Lot Video", "The truck never moved after arriving at 10:05 p.m.; {DL} got in at 12:55 a.m. and the headlights came on with the engine.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "Patrol officer",
                        direct: ["\"{DL} was in the driver's seat with the engine running.\""],
                        cross: ["\"The truck was in park and never moved.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find?", "\"A pickup idling in the bar's lot, headlights on. {DL} slumped behind the wheel, keys in the ignition, foot near the brake. I knocked for a full minute.\""),
                            .direct("What did you observe?", "\"Strong odor of alcohol, slurred speech, unsteady when getting out. {DL} performed poorly on field sobriety tests.\""),
                            .direct("Why is that 'driving'?", "\"Under North Carolina law, being in the driver's seat with the engine running is being in actual physical control. That's driving.\""),
                            .cross("The truck was in park and never moved?", "\"Correct.\""),
                            .cross("It was nineteen degrees?", "\"It was cold.\""),
                            .cross("{DL} told you right away {D.he} was there to sleep, not drive?", "\"{DL} said that.\"")
                        ]),
            WitnessSeed(name: nil, role: "Bartender",
                        direct: ["\"I cut {DL} off at midnight.\""],
                        cross: ["\"{DL} asked me to call a ride.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How much did {DL} drink?", "\"Six or seven beers and two shots between ten and midnight. I cut {DL} off.\""),
                            .direct("What did {DL} do?", "\"Paid and went outside around a quarter to one.\""),
                            .cross("{DL} asked you to call a cab first?", "\"{DL} asked if I knew any. Rideshare was dead that night.\""),
                            .cross("{DL} told you 'I'm going to sleep in the truck'?", "\"Something like that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s sponsor",
                        direct: ["\"{DL} calls me before drinking and driving. That night {DL} slept instead.\""],
                        cross: ["\"{DL} relapsed that night.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {DL} tell you after?", "\"That {DL} relapsed, knew {D.he} couldn't drive, couldn't get a ride, and chose the truck heater over freezing. For {DL}, not driving was a victory.\""),
                            .cross("{DL} relapsed and drank at a bar?", "\"Yes. That's a relapse. Driving would have been a crime.\"")
                        ])
        ],
        prosecutionTheory: ["Driver's seat, keys in, engine running, lights on, 0.14, and three prior DWIs. Under our law that is driving, and habitual DWI."],
        defenseTheory: ["{DL} did the responsible thing: tried to get a ride, failed, and slept in a parked truck in nineteen-degree cold. The truck never moved."],
        aggravating: [],
        mitigating: ["The vehicle never moved", "{DL} attempted to arrange a ride", "{DL} is engaged in recovery"],
        allocutions: ["\"I relapsed, but I didn't drive. For the first time in my life, I didn't drive.\""],
        guiltyTruths: ["The truck's GPS showed it had been driven to a gas station and back at 1:30 a.m."],
        innocentTruths: ["A second camera confirmed the truck never moved from 10:05 p.m. until the tow."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["TIME": ["2:10 a.m."]],
        story: StoryExtras(
            timeline: [(0, "10:05 p.m.: truck arrives. 12:48 a.m.: rideshare request canceled. 12:55 a.m.: {DL} gets into truck."),
                       (0, "2:10 a.m.: officer finds {DL} asleep. 2:51 a.m.: breath test 0.14."),
                       (7, "Lot video obtained."),
                       (20, "{DL} charged with habitual DWI.")],
            howIdentified: "{DL} was found in the driver's seat.",
            notDone: [],
            defendantExam: [
                .direct("Why were you in the driver's seat?", "\"The back seat of my truck is full of welding gear. The driver's seat is the only one that reclines.\""),
                .direct("Why have the lights on?", "\"They come on with the engine. I didn't think about it.\""),
                .cross("You knew you had three priors.", "\"That's exactly why I didn't drive.\""),
                .cross("Your foot was near the brake.", "\"I was asleep. My foot was where my foot was.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Is being asleep in a running car 'driving' under the law?\"",
                                  answer: "\"Yes, it's actual physical control.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Calls for a legal conclusion", shouldSustain: true,
                                  explanation: "Whether the facts amount to 'driving' is a legal question for the court, not the officer.",
                                  doctrineID: "speculation", weight: 0))
            ],
            prosecutionOpening: "Driver's seat, keys in the ignition, engine on, lights on, 0.14, and three prior DWIs.",
            defenseOpening: "A parked truck that never moved, a canceled ride, and nineteen degrees.",
            prosecutionClosing: "Our law defines driving as actual physical control.",
            defenseClosing: "The court can find {DL} was impaired but not driving.",
            when: .months([11, 12, 1, 2])
        )
    )

    // MARK: - 43. The romance scam

    static let romanceScam = CaseTemplate(
        key: "story.romanceScam", category: .whiteCollar,
        headlines: ["Local Charged in $140,000 Romance Scam", "Mastermind or Money Mule?"],
        primaryLaw: "falsePretenses100k", lesserLaw: "falsePretenses", threshold: 6, lesserThreshold: 4,
        specification: "Obtained $140,000 from {V} by false pretenses as part of an online romance scheme.",
        ageRange: 24...38, occupations: ["unemployed former call center worker"], hasVictim: true,
        summaries: [
            "{V}, 68, recently widowed, of {HOOD}, met \"Daniel,\" who said he was an oil engineer working offshore, on a dating site. Over eight months {VL} sent $140,000 for customs fees, a frozen account, and a plane ticket that never came. The wire transfers went to bank accounts opened by {D}, who withdrew most of the money in cash and sent it overseas through money transfer apps. {DL} says {D.he} answered an online job ad for a \"payment processing assistant,\" was paid 8 percent, and didn't know the money was stolen."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Accounts", "Three accounts opened by {DL} within two months, receiving $140,000 from {VL} and $210,000 from other victims; {DL} withdrew cash within hours of each deposit.", .search),
            E(.digital, 3, "Messages with the 'Employer'", "{DL} to the handler: \"bank asked why so many deposits, what do I say.\" Handler: \"say it's gifts from family.\" {DL}: \"ok.\"", .search),
            E(.document, 2, "Commissions", "{DL} kept $28,000 in 'commissions' over five months.")
        ],
        defenseEvidence: [
            E(.document, 2, "Job Ad and Contract", "A professional-looking job posting and a signed 'independent contractor agreement' from 'Meridian Global Payments.'"),
            E(.document, 2, "No Contact with Victims", "{DL} never communicated with {VL} or any other victim."),
            E(.document, 1, "Financial Situation", "{DL} had been laid off and was facing eviction when {D.he} answered the ad.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Scam victim",
                        direct: ["\"I sent everything my spouse left me.\""],
                        cross: ["\"I never spoke with {DL}.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you meet 'Daniel'?", "\"A dating site for people over sixty. He was kind, he called every morning, he sent pictures from the rig. After my spouse died, I hadn't felt seen in years.\""),
                            .direct("How did the money start?", "\"Customs fees for a shipment of his things. Then his account was frozen in Malaysia. Then a lawyer's fee. Each time just once more, he said.\""),
                            .direct("What's left?", "\"Nothing. I'm selling my house. I'm moving in with my daughter.\""),
                            .cross("You never spoke with {DL}?", "\"I'd never heard the name until the detective said it.\""),
                            .cross("'Daniel' told you which accounts to send to?", "\"Yes. Different ones each time.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"{DL} knew enough to lie to the bank.\""],
                        cross: ["\"{DL} is a small part of a big operation.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} do?", "\"Opened three accounts, received wires from at least six victims, withdrew cash within hours, and sent it overseas in amounts just under reporting limits.\""),
                            .direct("Why do you believe {DL} knew it was fraud?", "\"When the bank questioned the deposits, {DL} asked the handler what to say and then told the bank they were family gifts. People who think their job is legitimate don't lie to banks.\""),
                            .cross("The handlers are overseas and will never be caught?", "\"Very likely.\""),
                            .cross("These operations recruit desperate people with fake job ads?", "\"That's their model.\""),
                            .cross("{DL} cooperated and gave you every message?", "\"{DL} did.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fraud researcher",
                        direct: ["\"Money mules are often victims themselves.\""],
                        cross: ["\"Many do realize.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Who are money mules?", "\"Usually people in financial crisis, recruited through fake job ads that look like real payment-processing work. Many genuinely don't understand at first.\""),
                            .cross("Many realize at some point and keep going for the money?", "\"Many do.\""),
                            .cross("Lying to a bank about the source of deposits is a red flag of knowledge?", "\"It's a strong one.\"")
                        ])
        ],
        prosecutionTheory: ["{D} moved stolen money for five months, kept $28,000, and lied to the bank when asked. That's knowing participation."],
        defenseTheory: ["{DL} answered a job ad while facing eviction and was used by an overseas ring that will never see a courtroom. {DL} never deceived {V}."],
        aggravating: ["The victim was elderly and the loss was devastating"],
        mitigating: ["{DL} cooperated fully with investigators", "{DL} did not personally deceive the victim", "No prior criminal record"],
        victimImpacts: ["{V}: \"I'm not angry at the person in that chair the way I'm angry at 'Daniel.' But somebody has to answer for my spouse's life savings.\""],
        allocutions: ["\"I needed a job. By the time I understood, I was afraid to stop. I'm sorry, {VL}.\""],
        guiltyTruths: ["Messages later recovered show {DL} recruiting two friends as mules for a bonus."],
        innocentTruths: ["A federal task force later found the ring had threatened {DL}'s family when {D.he} tried to quit."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-240, "{VL} meets 'Daniel' online."),
                       (-150, "{DL} answers job ad; opens first account."),
                       (-60, "Bank questions deposits; {DL} says they are family gifts."),
                       (0, "{VL}'s daughter reports the scam."),
                       (50, "{DL} charged; cooperates and provides messages.")],
            howIdentified: "Wire transfers traced to accounts opened by {DL}.",
            notDone: [],
            defendantExam: [
                .direct("Why did you take the job?", "\"I'd been laid off and had an eviction notice. The ad looked real, there was a contract, an onboarding call. Eight percent of every transfer.\""),
                .direct("When did you realize?", "\"When the bank called. I knew something was wrong. I asked the handler and they told me what to say, and I said it. I was scared and I needed the money.\""),
                .cross("You kept going for months after that.", "\"Yes.\""),
                .cross("You kept $28,000.", "\"I spent most of it on rent. I'd pay it back if I could.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How did it feel to lose your spouse's savings?\"",
                                  answer: "\"Like I lost my spouse twice.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Relevance", shouldSustain: false,
                                  explanation: "The impact on the victim is relevant to the amount and nature of the loss charged, though its weight is limited at the guilt phase.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "{D} moved a widowed retiree's savings overseas and lied to the bank to keep it flowing.",
            defenseOpening: "A desperate job seeker used by criminals who will never be caught.",
            prosecutionClosing: "Lying to the bank proves knowledge.",
            defenseClosing: "Fear isn't fraud."
        )
    )
}
