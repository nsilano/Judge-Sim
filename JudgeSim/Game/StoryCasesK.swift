import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchK: [CaseTemplate] = [massageTable, driveBy, knifeFight, youthReferee, fakeCop]

    // MARK: - 64. The massage table (a client's accusation)

    static let massageTable = CaseTemplate(
        key: "story.massageTable", category: .violent,
        headlines: ["Massage Therapist Charged With Sexual Battery", "Client Says Therapist Touched Her During Session"],
        primaryLaw: "sexualBattery", lesserLaw: "simpleAssault", threshold: 4, lesserThreshold: 2,
        specification: "For the purpose of sexual gratification, engaged in sexual contact with {V} by force and against {V.his} will during a massage.",
        ageRange: 30...55, occupations: ["licensed massage therapist"], hasVictim: true,
        summaries: [
            "On {DATE}, {V} booked a 60-minute massage at {SPA} on {STREET} with {D}, a licensed therapist for twelve years. Forty minutes in, {VL} says, {DL} moved the drape and touched {V.his} breast and inner thigh. {VL} froze, then got up, dressed, and left without paying, texting a friend from the parking lot: \"Something just happened. I need you to call me.\" {DL} says {D.he} did a standard pectoral and adductor technique {VL} consented to on the intake form, and that {VL} was upset about an unrelated phone call. {DL} was convicted in district court and appealed."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Parking Lot Text", "At 3:47 p.m., from the spa's lot: \"Something just happened. I need you to call me.\""),
            E(.statement, 2, "Prompt Report", "{VL} reported to police the same evening and gave a consistent account to a nurse the next day."),
            E(.document, 2, "Prior Complaint", "A complaint to the state massage board by another client two years earlier, closed for lack of evidence, describing similar draping.")
        ],
        defenseEvidence: [
            E(.document, 2, "Intake Form", "{VL} checked 'chest/pectoral work: yes' and 'inner leg/adductors: yes' on the intake form."),
            E(.document, 2, "Twelve Years", "No board discipline in twelve years and more than 9,000 sessions."),
            E(.digital, 1, "Phone Call", "{VL}'s phone shows a 4-minute call from a family member ending at 3:05 p.m., during the session, that {VL} answered on the table.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Client",
                        direct: ["\"I froze.\""],
                        cross: ["\"I checked the boxes on the form.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened forty minutes in?", "\"{DL} pulled the sheet down past my chest and put a hand on my breast. Not the muscle, the breast. Then the hand went up the inside of my thigh much higher than anything before. I couldn't move.\""),
                            .direct("What did you do?", "\"I said, 'I'm done.' I got dressed shaking and walked out. I texted my friend from the car.\""),
                            .cross("You checked 'yes' to chest and inner leg work?", "\"Pectoral muscles. Not my breast. There's a difference.\""),
                            .cross("You took a phone call during the session that upset you?", "\"My mom called about a bill. I wasn't upset about it.\""),
                            .cross("You didn't say anything to {DL} at the time?", "\"I said I was done. That's all I could get out.\"")
                        ]),
            WitnessSeed(name: nil, role: "Friend who received the text",
                        direct: ["\"{VL} was sobbing.\""],
                        cross: ["\"I wasn't there.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {VL} say when you called?", "\"{VL} was sobbing. {V.He} said the therapist touched {V.his} breast and kept going up {V.his} leg, and {V.he} didn't know what to do.\""),
                            .cross("You weren't there?", "\"I was two hours away. I just got the text.\""),
                            .cross("{VL} told you about the phone call with {V.his} mother too?", "\"Not then. Later.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Massage therapy instructor",
                        direct: ["\"Pectoral and adductor work can feel invasive.\""],
                        cross: ["\"Touching the breast is never part of it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is pectoral and adductor work?", "\"Pectoral work goes along the upper chest just under the collarbone, sometimes near the breast tissue. Adductor work is the inner thigh, high up. Done right, with draping, it's standard. It can still feel invasive if a client isn't expecting it.\""),
                            .direct("Should a therapist explain before starting?", "\"Best practice is to check in. Not everyone does.\""),
                            .cross("Is touching the breast itself ever part of pectoral work?", "\"Never. Not in any curriculum I've taught.\""),
                            .cross("Is moving the drape below the chest standard?", "\"That's not standard. You'd stop and ask first.\"")
                        ])
        ],
        prosecutionTheory: ["{D} moved the drape and touched {VL}'s breast and inner thigh for no therapeutic reason. {VL}'s immediate flight and text show what happened."],
        defenseTheory: ["{VL} consented in writing to chest and inner leg work. A standard technique, done after an upsetting phone call, felt wrong. Twelve years and 9,000 sessions say {DL} isn't a predator."],
        aggravating: ["The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I can't let anyone touch my shoulders. Not even my partner.\""],
        allocutions: ["\"I would never do that to a client. I'm sorry {VL} felt violated, but I didn't do what {V.he} says.\""],
        guiltyTruths: ["After the trial, two more former clients came forward with nearly identical accounts."],
        innocentTruths: ["{VL} later told a therapist {V.he} had a past trauma triggered when {DL} began pectoral work without warning."],
        moods: [.divided], doctrines: ["burdenOfProof", "priorActs"],
        extras: ["SPA": ["Harbor Wellness Spa", "Serenity Day Spa", "Coastal Massage Studio"]],
        story: StoryExtras(
            timeline: [(0, "3:00 p.m.: session begins."),
                       (0, "3:47 p.m.: {VL} leaves and texts a friend."),
                       (0, "7:30 p.m.: report to police."),
                       (1, "Sexual assault nurse examination; no injury."),
                       (12, "Detective learns of the prior board complaint."),
                       (20, "{DL} charged.")],
            howIdentified: "{VL} knew {DL} as the therapist.",
            notDone: ["The prior complainant was never interviewed by police."],
            defendantExam: [
                .direct("What did you do in the last part of the session?", "\"Pectoral release along the upper chest with the drape folded at the sternum, then adductors with the leg draped. Both were on the form.\""),
                .direct("Did you touch {VL}'s breast?", "\"No. My hand was above the breast tissue. If the drape slipped, it was an accident.\""),
                .cross("You didn't check in before starting that work?", "\"I asked if the pressure was okay. I should have explained more.\""),
                .cross("There was a prior complaint about you.", "\"It was investigated and closed.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Did you know another client complained about {DL} two years ago?\"",
                                  answer: "\"The detective told me.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay and improper prior acts", shouldSustain: true,
                                  explanation: "The witness has no personal knowledge of the earlier complaint, and it can't come in through her as propensity evidence.",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "A drape pulled down, a hand where it never belonged, and a text from the parking lot.",
            defenseOpening: "A signed intake form, a standard technique, and twelve clean years.",
            prosecutionClosing: "No technique involves the breast. {VL} ran because it happened.",
            defenseClosing: "Fear and misunderstanding aren't proof beyond a reasonable doubt.",
            genders: ["V": .female]
        )
    )

    // MARK: - 65. The drive-by (shots into a house, an ID from a car)

    static let driveBy = CaseTemplate(
        key: "story.driveBy", category: .violent,
        headlines: ["Shots Fired Into {HOOD} Home With Children Inside", "Drive-By Suspect Tied to Car, Not Trigger"],
        primaryLaw: "dischargingOccupied", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Willfully discharged a firearm into the occupied residence of {V} on {STREET}.",
        secondary: [
            SecondaryCharge(lawID: "dischargingOccupied", specification: "Discharged a firearm into the occupied bedroom where {V}'s two children were asleep.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "awdwik", specification: "Assaulted {V} with a firearm, with intent to kill, by shooting into the home.", chance: 1.0, threshold: 5)
        ],
        ageRange: 18...26, occupations: ["unemployed", "delivery driver"], forcedPriorOffenses: ["Possession of Drug Paraphernalia"], hasVictim: true,
        summaries: [
            "At 11:20 p.m. on {DATE}, six shots were fired from a passing car into {V}'s house on {STREET} in {HOOD}. One went through the bedroom where {VL}'s two children were asleep. A neighbor's camera recorded a silver sedan with a dented rear quarter panel. Three days later police stopped {D} in a silver sedan with that dent; a shell casing that matched the scene was under the passenger seat. {DL} says {D.he} lends the car to friends, wasn't driving that night, and doesn't own a gun. {VL}'s nephew had been in a fight with {DL}'s cousin the week before."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Neighbor's Camera", "A silver sedan slows, shots flash from the passenger side, and it drives off. The rear quarter panel dent matches {DL}'s car."),
            E(.forensic, 3, "Shell Casing", "A 9mm casing under {DL}'s passenger seat, fired from the same gun as the six casings at the scene.", .search),
            E(.document, 1, "Motive", "{VL}'s nephew fought {DL}'s cousin a week before the shooting.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Lent Car", "A coworker says {DL} let several people borrow the car, including the cousin."),
            E(.document, 2, "Shots From the Passenger Side", "The video shows the shots came from the passenger window, not the driver's."),
            E(.forensic, 1, "Gunshot Residue", "No gun was found, and {DL} was not tested for residue.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"A bullet went over my daughter's bed.\""],
                        cross: ["\"I didn't see who was in the car.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened that night?", "\"Pop-pop-pop, six of them. I ran to the kids' room. There was a hole in the wall eight inches above my daughter's pillow.\""),
                            .direct("Do you know {DL}?", "\"I know {DL}'s cousin. My nephew and the cousin got into it the week before.\""),
                            .cross("You didn't see who was in the car?", "\"I only saw headlights and the back of it.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The car and the casing tie this to {DL}.\""],
                        cross: ["\"The shooter was the passenger.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you find the car?", "\"The dent was distinctive. A patrol officer spotted it three days later with {DL} driving.\""),
                            .direct("What was in the car?", "\"A 9mm casing under the passenger seat. The State Crime Lab matched it to the six from the house.\""),
                            .cross("The video shows shots from the passenger side?", "\"From the passenger window. You can see the flash.\""),
                            .cross("So if {DL} was in the car, {D.he} was driving, not shooting?", "\"If {D.he} was driving, yes.\""),
                            .cross("You never asked who else drove that car?", "\"{DL} wouldn't say.\""),
                            .cross("Did you interview the cousin?", "\"The cousin declined to talk.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s coworker",
                        direct: ["\"Everybody borrowed that car.\""],
                        cross: ["\"I don't know who had it that night.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Who used {DL}'s car?", "\"{DL} let half the family use it. The cousin had it all the time.\""),
                            .cross("Do you know who had it that night?", "\"I couldn't tell you.\""),
                            .cross("Did {DL} ever lend it overnight?", "\"Sometimes for days.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s car, with {D.his} dent, fired six shots into a house, and a matching casing was in {D.his} car three days later. Whether driver or shooter, {DL} acted in concert."],
        defenseTheory: ["{DL} lends that car to family, including the cousin who had the grudge. The shots came from the passenger side, and the State can't put {DL} in the car at all."],
        aggravating: ["The offense endangered children"],
        mitigating: [],
        victimImpacts: ["{V}: \"My kids sleep on the living room floor now, away from the windows.\""],
        allocutions: ["\"I didn't shoot anybody's house. I'm not going to say who had my car.\""],
        guiltyTruths: ["{DL}'s phone, later obtained, connected to a tower a block from the house at 11:19 p.m."],
        innocentTruths: ["The cousin was later arrested with the gun that fired the casings and admitted using {DL}'s car that night."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-7, "Fight between {VL}'s nephew and {DL}'s cousin."),
                       (0, "11:20 p.m.: six shots into the house."),
                       (1, "Neighbor's video collected."),
                       (3, "Traffic stop; casing found in the car."),
                       (10, "Crime lab matches the casing."),
                       (11, "{DL} charged.")],
            howIdentified: "The dented sedan on the neighbor's video.",
            notDone: ["{DL}'s phone location was never requested.", "{DL} was never tested for gunshot residue."],
            defendantExam: [
                .direct("Were you driving your car that night?", "\"No. I was home. I'd lent it out.\""),
                .direct("To whom?", "\"I'm not saying. I'm not putting anybody's name in this.\""),
                .cross("You'll go to prison to protect whoever did this?", "\"I didn't do it. That's all I'm here to say.\""),
                .cross("A casing from that gun was under your seat.", "\"Somebody else's casing in my car. I don't own a gun.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, is {DL} associated with a gang?\"",
                                  answer: "\"We believe so.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Unfair prejudice", shouldSustain: true,
                                  explanation: "Unsupported gang association is highly prejudicial and not tied to any element; it should be excluded under Rule 403.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Six shots, a sleeping child, and a car with a dent that leads to {DL}.",
            defenseOpening: "A borrowed car, a passenger-side shooter, and a cousin with a grudge.",
            prosecutionClosing: "{DL} was in that car. Driving or shooting, {D.he} is guilty.",
            defenseClosing: "The State proved whose car it was. Not who was in it.",
            victim: VictimFacts(relationship: "No direct relationship; the victim's nephew had fought with the defendant's cousin.", family: "Two children, who were asleep in the house.")
        )
    )

    // MARK: - 66. The knife fight (a parking lot, two men, one dead)

    static let knifeFight = CaseTemplate(
        key: "story.knifeFight", category: .violent,
        headlines: ["Man Stabbed to Death in Bar Parking Lot", "Killer Says Victim Came at Him With a Bottle"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 2, lesserThreshold: 1,
        specification: "Unlawfully and with malice killed {V} by stabbing him with a knife.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by throwing the knife into a creek after the stabbing.", chance: 1.0, threshold: 1)
        ],
        ageRange: 24...40, occupations: ["welder", "roofer"], forcedPriorOffenses: ["Assault with a Deadly Weapon"], hasVictim: true,
        summaries: [
            "At 1:40 a.m. on {DATE}, in the parking lot of {BAR} on {STREET}, {D} stabbed {V} three times after an argument that began inside over a pool game. {VL} died at the scene. Witnesses agree {VL} followed {DL} outside, shouting. They disagree whether {VL} swung a beer bottle first. A broken bottle was found near {VL}'s body. {DL} carried a folding knife for work, left the scene, and turned himself in the next morning. {DL} has a prior conviction for assault with a deadly weapon."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Autopsy", "Three stab wounds: chest, abdomen, and back. The back wound suggests {VL} was turning away."),
            E(.statement, 2, "Bartender", "The bartender heard {DL} say inside, \"Keep talking and see what happens.\""),
            E(.document, 2, "Flight", "{DL} drove away, threw the knife in a creek, and turned himself in eight hours later.")
        ],
        defenseEvidence: [
            E(.physical, 3, "Broken Bottle", "A broken beer bottle beside {VL}'s right hand, with {VL}'s fingerprints on the neck."),
            E(.document, 2, "Toxicology", "{VL}'s blood alcohol was 0.21."),
            E(.statement, 2, "Patron Outside", "A patron smoking outside told police {VL} \"came at {DL} with the bottle.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"The third wound was to the back.\""],
                        cross: ["\"The order of the wounds is uncertain.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What wounds did {VL} have?", "\"Three: one to the chest that went into the lung, one to the abdomen, and one to the lower back. The chest wound was fatal.\""),
                            .direct("What does the back wound suggest?", "\"That {VL} was turned away, at least partly, when it was inflicted.\""),
                            .cross("You can't tell the order of the wounds?", "\"Not with certainty.\""),
                            .cross("In a struggle, people twist and turn?", "\"They twist, they grab, they fall. It's never like the diagrams.\"")
                        ]),
            WitnessSeed(name: nil, role: "Bartender at {BAR}",
                        direct: ["\"'Keep talking and see what happens.'\""],
                        cross: ["\"{VL} was the louder one.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened inside?", "\"They argued over a bet on a pool game. {DL} said, 'Keep talking and see what happens,' and walked out. {VL} followed.\""),
                            .cross("{VL} was the louder one?", "\"{VL} was drunk and loud. I'd cut {VL} off twenty minutes earlier.\""),
                            .cross("{VL} followed {DL} outside, yelling?", "\"Yelling the whole way to the door.\""),
                            .cross("Did you see anything in the parking lot?", "\"I was behind the bar. No windows back there.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Patron smoking outside",
                        direct: ["\"{VL} came at {DL} with a bottle.\""],
                        cross: ["\"It was dark and fast.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{DL} was walking to {D.his} truck. {VL} came out yelling, broke a bottle on a car, and came at {DL} with it. Then they were tangled up, and {VL} went down.\""),
                            .direct("Did you see a knife?", "\"Not until after.\""),
                            .cross("You'd been drinking?", "\"A few beers.\""),
                            .cross("It was dark and it happened fast?", "\"Fast. The lot lights were on.\""),
                            .cross("You didn't stay to talk to police?", "\"I called 911 and gave my name. Then I left.\"")
                        ])
        ],
        prosecutionTheory: ["{D} threatened {VL} inside, stabbed {V.him} three times outside, one in the back, then threw away the knife and fled. That's malice, not self-defense."],
        defenseTheory: ["{VL}, drunk and enraged, chased {DL} into the lot and came at {D.him} with a broken bottle. {DL} defended {D.himself}. At most, this is manslaughter."],
        aggravating: [],
        mitigating: ["The victim was the initial aggressor", "The defendant voluntarily surrendered"],
        victimImpacts: ["{VL}'s brother: \"Over a pool game. Twenty dollars.\""],
        allocutions: ["\"I didn't want any of it. I wish I'd driven away faster.\""],
        guiltyTruths: ["A dashcam in a parked car later showed {DL} turning back toward {VL} after {VL} dropped the bottle."],
        innocentTruths: ["A dashcam in a parked car later showed {VL} slashing at {DL}'s face with the bottle before {DL} pulled the knife."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense"],
        extras: ["BAR": ["The Anchor Tavern", "Rusty's Pool Hall", "The Spillway Bar"]],
        story: StoryExtras(
            timeline: [(0, "1:15 a.m.: argument over a pool game inside {BAR}."),
                       (0, "1:40 a.m.: stabbing in the parking lot; {VL} dies at the scene."),
                       (0, "9:45 a.m.: {DL} turns himself in."),
                       (1, "Autopsy; bottle fingerprints processed."),
                       (2, "{DL} charged with second-degree murder.")],
            howIdentified: "The bartender identified {DL}, and {DL} turned himself in.",
            notDone: ["Parked cars in the lot were not checked for dashcams.", "The knife was never recovered from the creek."],
            defendantExam: [
                .direct("What happened in the lot?", "\"I left to avoid a fight. {VL} came out screaming, smashed a bottle, and came at my face with it. I got my knife out and we went down together.\""),
                .direct("Why did you leave and throw away the knife?", "\"I panicked. I've got a record. I knew how it would look. I turned myself in when I calmed down.\""),
                .cross("You told {VL} to 'keep talking and see what happens.'", "\"I meant I'd leave. Bad choice of words.\""),
                .cross("One wound was in {VL}'s back.", "\"We were rolling on the ground. I don't know where I hit.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Did {DL} have a reputation as a fighter?\"",
                                  answer: "\"Everybody knew not to mess with him.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper character evidence", shouldSustain: true,
                                  explanation: "The State can't introduce bad character to prove conduct unless the defendant first offers good character.",
                                  doctrineID: "characterEvidence", weight: 1))
            ],
            prosecutionOpening: "A threat inside, three wounds outside, a knife in the creek.",
            defenseOpening: "A drunk man with a broken bottle chasing someone who walked away.",
            prosecutionClosing: "A wound in the back isn't self-defense.",
            defenseClosing: "{VL} brought a bottle to a man who was leaving. At most, it's manslaughter.",
            genders: ["D": .male, "V": .male]
        )
    )

    // MARK: - 67. The youth referee (a parent and a broken jaw)

    static let youthReferee = CaseTemplate(
        key: "story.youthReferee", category: .violent,
        headlines: ["Parent Charged After Youth Soccer Referee's Jaw Broken", "Sideline Fight: 'The Ref Pushed Me First'"],
        primaryLaw: "aisi", lesserLaw: "simpleAssault", threshold: 5, lesserThreshold: 3,
        specification: "Assaulted {V}, a youth soccer referee, by punching {V.him}, inflicting serious injury.",
        secondary: [
            SecondaryCharge(lawID: "disorderly", specification: "Disrupted a youth soccer event by entering the field and fighting.", chance: 1.0, threshold: 3)
        ],
        ageRange: 35...50, occupations: ["pharmaceutical sales representative", "HVAC technician"], hasVictim: true,
        summaries: [
            "On {DATE}, after a U-12 soccer game at the {HOOD} recreation fields, {D}, a parent, confronted {V}, the 19-year-old referee, over a red card given to {D}'s child. Video from another parent's phone shows {DL} walking onto the field, the two standing chest to chest, a blur of movement, and {VL} on the ground. {VL}'s jaw was broken in two places. {DL} says {VL} shoved {D.him} in the chest first and {D.he} reacted. {DL} was convicted in district court and appealed."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Parent's Video", "{DL} walks onto the field shouting; 1.5 seconds of blur when they're chest to chest; {VL} falls."),
            E(.document, 3, "Medical Records", "Mandible fractured in two places; jaw wired shut for six weeks."),
            E(.statement, 2, "League Coordinator", "The coordinator heard {DL} yell, \"You want to throw my kid out? Let's go.\"")
        ],
        defenseEvidence: [
            E(.statement, 2, "Assistant Coach", "An assistant coach from the other team told police {VL} \"put both hands on the parent's chest and shoved\" first."),
            E(.document, 1, "Referee Training", "League rules require referees to walk away from confrontations and call the coordinator."),
            E(.video, 1, "Video Frames", "Slowed down, one frame shows {VL}'s arms extended toward {DL} before the punch.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Referee",
                        direct: ["\"I put my hands up to keep distance.\""],
                        cross: ["\"My hands might have touched {D.his} chest.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened after the game?", "\"{DL} came straight onto the field yelling that I'd ruined {D.his} kid's season. Got right in my face. I put my hands up to keep some space, and then I was on the ground and couldn't close my mouth.\""),
                            .direct("How has the injury affected you?", "\"Six weeks wired shut. Two surgeries. I quit refereeing.\""),
                            .cross("Your hands touched {DL}'s chest?", "\"Maybe. I was trying to create space.\""),
                            .cross("League rules say walk away and call the coordinator?", "\"I was trying to. {DL} was in my way.\"")
                        ]),
            WitnessSeed(name: nil, role: "League coordinator",
                        direct: ["\"'Let's go,' {DL} said.\""],
                        cross: ["\"I didn't see the first contact.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear?", "\"{DL} yelling, 'You want to throw my kid out? Let's go.' I started running over.\""),
                            .cross("Did you see who touched whom first?", "\"No. I was forty yards away.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Opposing team's assistant coach",
                        direct: ["\"The ref shoved first.\""],
                        cross: ["\"The parent walked onto the field.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"The ref put both hands on the parent's chest and shoved hard. The parent stumbled back, came forward, and swung once.\""),
                            .direct("Do you know either of them?", "\"Never met either one. I coach the other team.\""),
                            .cross("{DL} walked onto the field and got in the referee's face?", "\"Yes. That was wrong.\""),
                            .cross("A shove doesn't justify breaking someone's jaw?", "\"I'm telling you what happened.\"")
                        ])
        ],
        prosecutionTheory: ["{D} stormed onto the field, invited a fight with a teenager, and broke {V.his} jaw. Raising your hands to keep distance isn't an attack."],
        defenseTheory: ["{VL} shoved {DL} first, hard, and {DL} reacted with a single punch. Ugly, but self-defense, or at most simple assault."],
        aggravating: ["The victim was a youth sports official"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"I was nineteen and doing it for gas money. I'll never step on a field again.\""],
        allocutions: ["\"I'm ashamed of how I acted in front of my kid. I'm sorry for {VL}'s injury.\""],
        guiltyTruths: ["A second video, from the bleachers, later showed {VL}'s hands open and stationary, not pushing."],
        innocentTruths: ["A second video, from the bleachers, later showed {VL} shoving {DL} back several feet."],
        moods: [.wantsConviction], doctrines: ["selfDefense"],
        story: StoryExtras(
            timeline: [(0, "Game ends; confrontation on the field; {VL} taken to the hospital."),
                       (1, "{VL}'s jaw surgically repaired."),
                       (2, "Phone video obtained from a parent."),
                       (4, "{DL} charged.")],
            howIdentified: "Many parents knew {DL}.",
            notDone: ["Other parents filming from the bleachers were not asked for video."],
            defendantExam: [
                .direct("Why did you go onto the field?", "\"To ask why my child got a red card for a clean tackle. I was angry. I shouldn't have gone.\""),
                .direct("What happened?", "\"{VL} shoved me hard enough that I almost went down. I swung once without thinking.\""),
                .cross("You said 'Let's go.'", "\"I said 'Let's go talk.' It got cut off.\""),
                .cross("You outweigh {VL} by eighty pounds.", "\"I wasn't thinking about weight. I was thinking I'd been shoved.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"You're friends with a lot of the parents on {DL}'s team, aren't you?\"",
                                  answer: "\"No, I'm on the other team.\"",
                                  raisedBy: .defense, onCross: true, grounds: "Assumes facts not in evidence", shouldSustain: true,
                                  explanation: "There's no basis for the premise that the witness is friends with the defendant's team.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A parent, a red card, and a teenager's broken jaw.",
            defenseOpening: "A shove, and a single reflexive punch.",
            prosecutionClosing: "{DL} went looking for a fight and found one.",
            defenseClosing: "The only neutral witness says {VL} shoved first.",
            victim: VictimFacts(age: 19, occupation: "Youth soccer referee and college student", relationship: "No relationship; refereed a game the defendant's child played in.")
        )
    )

    // MARK: - 68. The fake cop (blue lights on a dark road)

    static let fakeCop = CaseTemplate(
        key: "story.fakeCop", category: .violent,
        headlines: ["Driver Says Fake Officer Pulled Her Over on Route 17", "Man With Blue Lights Charged With Impersonating Police"],
        primaryLaw: "impersonatingLEO", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Falsely represented to {V} that he was a sworn law enforcement officer by using blue lights and a badge to stop {V.his} vehicle.",
        ageRange: 30...55, occupations: ["security guard"], hasVictim: true,
        summaries: [
            "At 11:05 p.m. on {DATE}, {V}, driving alone on Route 17 outside {HOOD}, pulled over for a dark sedan flashing blue lights on the dashboard. A man in a black polo with a badge on his belt asked for {V.his} license, shone a flashlight inside, and asked where {V.he} was headed and whether anyone was waiting for {V.him}. When {VL} said {V.he} was calling 911 to confirm, he walked back to his car and drove off. {VL} noted a partial plate. {D}, a private security guard, owns a dark sedan with that partial plate and blue dash lights. {DL} says the lights are amber-and-blue \"security lights\" for {D.his} job and that {D.he} was at home."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Victim's 911 Call", "{VL}: \"A man with blue lights pulled me over and he's not a real cop, I don't think. Partial plate 7-K-R.\""),
            E(.physical, 2, "Dash Light Bar", "A blue-and-amber dash light bar in {DL}'s sedan, plate beginning 7KR.", .search),
            E(.physical, 2, "Badge", "A gold 'Special Officer' badge in {DL}'s glove box.", .search),
            E(.statement, 2, "Photo Lineup", "{VL} picked {DL} from six photos: \"I think that's him, the mustache.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Employer Letter", "{DL}'s security company issues the badge and permits amber lights on company property only."),
            E(.document, 2, "Plate Search", "Fourteen dark sedans in Hollis County have plates beginning 7KR."),
            E(.statement, 1, "Home That Night", "{DL}'s spouse says {DL} was home after 10 p.m.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Driver",
                        direct: ["\"He asked if anyone was waiting for me.\""],
                        cross: ["\"It was dark.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened when you stopped?", "\"A man in a black polo came to my window with a flashlight. He had a badge on his belt. He asked for my license, where I was going, and whether anyone was waiting for me at home. That's when my stomach dropped.\""),
                            .direct("What did you do?", "\"I said, 'I'm going to call 911 and confirm you're an officer.' He said, 'Don't bother,' walked back, and drove away fast.\""),
                            .cross("It was dark and the flashlight was in your eyes?", "\"Mostly. I saw his face when he turned.\""),
                            .cross("You said 'I think' when you picked the photo?", "\"I did. The mustache, the build.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"Blue lights and a badge in {DL}'s car.\""],
                        cross: ["\"Fourteen sedans share that partial plate.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you identify {DL}?", "\"Of fourteen dark sedans with plates starting 7KR, one had a registered owner with a security job. That was {DL}.\""),
                            .direct("What did the search find?", "\"A blue-and-amber dash light bar and a gold badge that says 'Special Officer.'\""),
                            .cross("Did you look at the other thirteen cars?", "\"Not in person.\""),
                            .cross("The badge says 'Special Officer,' not police?", "\"'Special Officer.' It's the kind you can order online.\""),
                            .cross("Did you get {DL}'s phone location?", "\"We didn't request it. I should have.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s spouse",
                        direct: ["\"{DL} was home.\""],
                        cross: ["\"I fell asleep around eleven.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where was {DL} that night?", "\"Home. We watched a show starting at ten.\""),
                            .cross("When did you fall asleep?", "\"Around eleven, maybe a little before.\""),
                            .cross("You wouldn't know if {DL} left after that?", "\"I'd have heard the garage.\"")
                        ])
        ],
        prosecutionTheory: ["{D}, a security guard with blue lights and a badge, stopped a woman alone at night and fled when she called 911."],
        defenseTheory: ["Fourteen cars share that partial plate, the badge says 'Special Officer' for {D.his} job, and an uncertain identification from a flashlit window isn't proof."],
        aggravating: ["The offense targeted a person traveling alone at night"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"Now when real blue lights come up behind me, I drive to a gas station before I stop.\""],
        allocutions: ["\"I didn't stop anybody. I'd never do that.\""],
        guiltyTruths: ["{DL}'s phone, obtained later, connected to a tower on Route 17 at 11:03 p.m."],
        innocentTruths: ["Another of the fourteen sedans belonged to a man later caught doing the same thing in a neighboring county."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "11:05 p.m.: stop on Route 17; {VL} calls 911 at 11:09."),
                       (3, "DMV search for dark sedans with plates beginning 7KR."),
                       (6, "{VL} views a photo lineup and picks {DL}."),
                       (7, "Search warrant for {DL}'s car; lights and badge seized."),
                       (8, "{DL} charged.")],
            howIdentified: "A partial plate narrowed by DMV records and a photo lineup.",
            notDone: ["{DL}'s phone location was never requested.", "The other thirteen sedans were not checked for lights."],
            defendantExam: [
                .direct("Why do you have blue lights in your car?", "\"They're blue and amber. My company issues them for patrolling the industrial park. I don't use them on the road.\""),
                .direct("Where were you at 11:05?", "\"Asleep on the couch at home.\""),
                .cross("Your badge says 'Special Officer.'", "\"Because that's my title at work.\""),
                .cross("You have a mustache, a dark sedan, a 7KR plate, and blue lights.", "\"So do other people, apparently.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, did {DL} once apply to be a deputy?\"",
                                  answer: "\"Yes, and was rejected.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Relevance", shouldSustain: false,
                                  explanation: "A rejected application to law enforcement is relevant to motive to pose as an officer, and its probative value isn't substantially outweighed by prejudice.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Blue lights, a badge, and a question no real officer asks: is anyone waiting for you?",
            defenseOpening: "Fourteen cars, a work badge, and a frightened 'I think.'",
            prosecutionClosing: "Every detail fits {DL}, and {D.he} has the lights and the badge.",
            defenseClosing: "Fits isn't proven. The State checked one car out of fourteen.",
            genders: ["D": .male, "V": .female]
        )
    )
}
