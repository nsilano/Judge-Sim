import Foundation

private typealias E = EvidenceSeed

// Tokens available in all text: {D} defendant, {DL} defendant surname, {V}/{VL} victim,
// {DET} detective, {OFF} officer, {ALT} alternate suspect, {PROS} prosecutor, {DEF} defense lawyer,
// {STREET}, {TIME}, {DATE}, {HOOD}, {CITY}, plus each template's extras.

enum CaseTemplates {
    static let all: [CaseTemplate] = [
        storeRobbery, barFight, poisoning, burglary, embezzlement, trafficStopDrugs, overdose,
        drunkCrash, abusedSpouse, medicineTheft, ransomware, imageLeak, insuranceArson,
        protestAssault, elderScam, stalking, custodyFlight, policeForce, councilBribe, felonGun, ponzi
    ] + expandedA + expandedB

    // MARK: - Violent

    static let storeRobbery = CaseTemplate(
        key: "storeRobbery", category: .violent,
        headlines: ["Gunpoint Robbery at {BIZ}", "The Masked Robber of {STREET}"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 8, lesserThreshold: 6,
        specification: "Robbed {V} at {BIZ} while armed with {WEAPON}.",
        ageRange: 19...38, hasVictim: true,
        summaries: [
            "At {TIME} on {DATE}, a masked person walked into {BIZ} on {STREET}, pointed {WEAPON} at the clerk, {V}, and left with {AMT} from the register. Nine days later, police arrested {D} on an anonymous tip.",
            "{V} was alone behind the counter at {BIZ} when a masked figure demanded the register at gunpoint. The robber escaped with {AMT}. After a Crime Stoppers tip, detectives arrested {D}, a {DO} who lives six blocks away."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Security Footage", "Grainy CCTV shows a masked person of roughly {DL}'s height and build. The face is never visible."),
            E(.physical, 4, "Recovered Handgun", "A black handgun found in a shoebox in {DL}'s closet. It's similar to the weapon on the video.", .search),
            E(.physical, 2, "Banded Cash", "$290 in small bills, bound with a rubber band like the ones {BIZ} uses, found in {DL}'s car.", .search),
            E(.digital, 3, "Cell-Site Records", "{DL}'s phone connected to a tower about 300 meters from {BIZ} eight minutes before the robbery.", .search),
            E(.statement, 5, "Recorded Statement", "In a recorded interview, {DL} said: \"I needed the money, okay? Nobody got hurt.\"", .statement),
            E(.forensic, 5, "Thumbprint", "A partial print on the counter matches {DL}'s right thumb, at 11 points of comparison."),
            E(.document, 2, "Photo Lineup", "{V} picked {DL} from a photo lineup and said, \"I'm about 70 percent sure.\"")
        ],
        defenseEvidence: [
            E(.document, 3, "Laundromat Receipt", "A timestamped receipt from a laundromat across town, 14 minutes before the robbery, paid with {DL}'s debit card."),
            E(.physical, 2, "Height Discrepancy", "{DL} is 6'3\". On the 911 call, {V} described the robber as \"about my height,\" and {V} is 5'8\"."),
            E(.document, 2, "Eyewitness Expert Report", "When a weapon is present, witnesses focus on it, not the face. Under those conditions, misidentification rates exceed 40%."),
            E(.document, 2, "Inventory Gap", "The robber wore bright white sneakers. Police found no white shoes when they searched {DL}'s home.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Store clerk",
                        direct: ["\"I was restocking cigarettes when the door chimed. Then there was {WEAPON} pointed at my chest.\"",
                                 "\"I'll never forget the eyes. When I saw the photo lineup, I knew.\""],
                        cross: ["\"The mask covered everything except the eyes, yes.\"",
                                "\"I told 911 the robber was about my height. I was scared, okay?\""],
                        weight: 2, lay: true),
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"{DL} became a suspect through an anonymous Crime Stoppers tip.\"",
                                 "\"The cell records and the weapon corroborated that tip.\""],
                        cross: ["\"No, I can't tell the court who made the tip.\"",
                                "\"No shots were fired, so the gun can't be ballistically matched to anything.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s roommate",
                        direct: ["\"We were at the laundromat on Fifth that whole evening. I remember because the dryer ate my quarters.\""],
                        cross: ["\"I've known {DL} since high school.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["{D}, desperate for money, walked into {BIZ} with {WEAPON} and terrorized {V} for {AMT}. The evidence will prove it beyond a reasonable doubt."],
        defenseTheory: ["A masked robber. A terrified witness. An anonymous tip. That's not proof; it's a guess. {DL} was across town."],
        aggravating: ["The weapon was pointed at {V}'s chest from two feet away", "{V} quit the job and suffers ongoing panic attacks"],
        mitigating: ["{DL} was three months behind on rent and facing eviction", "No shots fired and no physical injury", "{DL} has since entered addiction treatment"],
        victimImpacts: ["{V}: \"I can't work nights anymore. Every time a door chimes, I'm back there with that thing pointed at me.\"",
                        "{V}: \"I don't want them to rot. I want them to get help. But I need them to know what they took from me.\""],
        guiltyTruths: ["Years later, at a parole hearing, {DL} described the register drawer sticking, a detail only the robber could know."],
        innocentTruths: ["Two years later, {ALT} was arrested for a string of identical robberies and confessed to the {BIZ} job, describing details police never released."],
        moods: [.wantsConviction, .indifferent],
        doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["BIZ": ["Quik-Stop Mart", "Hollis 24/7 Fuel", "Lucky Dragon Market", "Sunset Liquors", "Corner Pantry"],
                 "AMT": ["$312", "$640", "$1,180", "$215"],
                 "WEAPON": ["a black handgun", "what looked like a revolver", "a small silver pistol"]]
    )

    static let barFight = CaseTemplate(
        key: "barFight", category: .violent,
        headlines: ["Closing Time at {BAR}", "One Wound, Two Stories"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 5, lesserThreshold: 3,
        specification: "Killed {V} with a knife outside {BAR}.",
        ageRange: 22...50, hasVictim: true,
        summaries: [
            "At closing time outside {BAR}, an argument between {D} and {V} over a spilled drink turned into a fight. {V} died of a single stab wound to the chest. {DL} says {VL} attacked first and was choking {DL} against a wall.",
            "Witnesses saw {D} and {V} trade words inside {BAR}, then follow each other out. Ninety seconds later, {V} was on the sidewalk, bleeding out. {DL} claims self-defense."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Bloody Folding Knife", "A 4-inch folding knife with {VL}'s blood and {DL}'s fingerprints, recovered from a storm drain a block away."),
            E(.video, 4, "Bystander Phone Video", "Twelve shaky seconds. {DL} lunges forward, and {VL} staggers back. The start of the fight is off-camera."),
            E(.physical, 2, "Washed Clothing", "Police found {DL} at home three hours later. {DL}'s clothes were in a running washing machine.", .search),
            E(.digital, 3, "Text Message", "An hour before, {DL} texted a friend: \"if {VL} says one more word I swear to god\"", .search),
            E(.forensic, 3, "Autopsy", "A single wound angled downward, consistent with a deliberate overhand strike."),
            E(.statement, 3, "Statement to Police", "\"I just wanted it to stop. I didn't think. I just did it.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 4, "Victim's Violent History", "{V} had two prior assault convictions for bar fights, both known to {DL}."),
            E(.forensic, 3, "ER Records", "That night, {DL} was treated for a broken nose, bruised ribs, and finger-mark bruising on the neck."),
            E(.document, 2, "Bartender's Statement", "\"{VL} yelled 'I'll kill you' and followed {DL} out the door.\""),
            E(.physical, 1, "Work Knife", "{DL} is a line cook. Coworkers confirm the folding knife was carried to work every day.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Bar patron",
                        direct: ["\"I saw {DL} pull the knife and swing. {VL} just dropped.\""],
                        cross: ["\"It was dark outside. And no, I didn't see who threw the first punch.\""],
                        weight: 2, lay: true),
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"Cause of death: a penetrating stab wound to the left ventricle. Death within minutes.\""],
                        cross: ["\"The wound can't tell me who started the fight.\""],
                        weight: 1, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend of the defendant",
                        direct: ["\"{VL} grabbed {DL} by the throat and slammed {DL} into the brick wall. Twice. {DL}'s face was purple.\""],
                        cross: ["\"Yes, {DL} and I are close friends.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["{D} was angry, armed, and itching for a fight, and when it came, {DL} ended a life over a spilled drink."],
        defenseTheory: ["{V} had a history of violence and had {DL} by the throat. {DL} did what any of us would do to survive."],
        aggravating: ["Brought a knife into a fistfight", "Fled the scene and washed clothing"],
        mitigating: ["The victim was the initial aggressor in the physical fight", "{DL} suffered significant injuries", "No prior violent record"],
        victimImpacts: ["{VL}'s daughter: \"My dad wasn't perfect. But he was my dad, and he's never going to walk me down the aisle.\"",
                        "{VL}'s brother: \"{VL} had a temper. We all know it. But he didn't deserve to die on a sidewalk.\""],
        guiltyTruths: ["A second, longer video surfaced a year later: {VL} had let go and was backing away when {DL} struck."],
        innocentTruths: ["A security camera across the street, found during the appeal, showed {VL} choking {DL} nearly unconscious before the single, desperate strike."],
        moods: [.divided, .indifferent],
        doctrines: ["selfDefense", "imperfectSelfDefense", "lesserIncluded"],
        extras: ["BAR": ["The Rusty Anchor", "Mulligan's Tavern", "the Neon Moose", "the Lamplighter"]]
    )

    static let poisoning = CaseTemplate(
        key: "poisoning", category: .violent,
        headlines: ["The Antifreeze Marriage", "Death on {STREET}"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 7, lesserThreshold: 5,
        specification: "Poisoned spouse {V} with ethylene glycol, with premeditation.",
        ageRange: 40...68, hasVictim: true,
        summaries: [
            "{V}, 58, collapsed at home and died three days later. Toxicology found ethylene glycol (antifreeze). The State says {V}'s spouse, {D}, poisoned {VL} over weeks for a {POLICY} life insurance policy.",
            "When {V} died of kidney failure, doctors suspected nothing until a nurse noticed calcium oxalate crystals, the signature of antifreeze poisoning. {D}, the grieving spouse, stood to collect {POLICY}."
        ],
        prosecutionEvidence: [
            E(.forensic, 4, "Toxicology", "Ethylene glycol levels consistent with repeated doses over several days."),
            E(.document, 4, "Increased Policy", "Two months before the death, {DL} raised {VL}'s life insurance to {POLICY}."),
            E(.digital, 5, "Search History", "The family laptop searched \"can you taste antifreeze in a drink\" and \"ethylene glycol detectable autopsy.\"", .search),
            E(.document, 2, "Cash Receipt", "A gallon of antifreeze bought with cash. The couple owns only an electric car."),
            E(.digital, 3, "Affair Messages", "Messages show {DL} was in an affair and wrote: \"soon we won't have to hide.\"", .search),
            E(.statement, 3, "Denial to Detectives", "{DL} denied ever buying antifreeze until detectives produced the receipt.", .statement)
        ],
        defenseEvidence: [
            E(.document, 4, "Therapist's Notes", "{V} had severe depression, with two prior documented mentions of suicidal thoughts."),
            E(.digital, 3, "Shared Laptop", "The laptop had no password and was used by the whole household, including {V}."),
            E(.document, 2, "No Money Motive", "The couple had $900,000 in savings and no debts."),
            E(.document, 2, "Unsigned Note", "Found in {VL}'s desk: \"I'm so tired of being a burden.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Insurance agent",
                        direct: ["\"{DL} called asking how fast the policy pays out, 'in case of accident.'\""],
                        cross: ["\"People ask that more than you'd think.\""],
                        weight: 2, lay: true),
            WitnessSeed(name: nil, role: "Forensic toxicologist",
                        direct: ["\"This wasn't one dose. It was given repeatedly, over three to five days.\""],
                        cross: ["\"Could {VL} have taken it repeatedly? I can't rule it out scientifically.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s sibling",
                        direct: ["\"{VL} called me a month before and said, 'I don't see the point anymore.'\""],
                        cross: ["\"I'm in the will too, yes.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["This was a slow, deliberate murder. {D} researched it, bought the poison, raised the policy, and watched {V} die by degrees."],
        defenseTheory: ["{V} was suffering, and had told people so. The State has turned a family's tragedy into a murder story."],
        aggravating: ["Killing for financial gain", "Victim poisoned over days in their own home", "Breach of the deepest trust"],
        mitigating: ["No prior record", "Age {DA}"],
        victimImpacts: ["{VL}'s son: \"I've lost both my parents. One to the grave and one to this.\"",
                        "{VL}'s best friend: \"Every morning, {VL} made two cups of coffee. I can't stop thinking about who made the second cup.\""],
        guiltyTruths: ["After the trial, a deleted email from {DL} to the affair partner was recovered: \"two more days.\""],
        innocentTruths: ["A year later, {VL}'s journal was found in a storage unit. The final entries describe a private plan to die, and a wish to spare the family by making it look natural."],
        moods: [.wantsConviction, .divided],
        doctrines: ["burdenOfProof", "lesserIncluded", "expertTestimony"],
        extras: ["POLICY": ["$1.2 million", "$800,000", "$2 million"]]
    )

    static let abusedSpouse = CaseTemplate(
        key: "abusedSpouse", category: .violent,
        headlines: ["Fourteen Years", "The Night Before Tomorrow"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 6, lesserThreshold: 4,
        specification: "Shot and killed spouse {V} at their home on {STREET}.",
        ageRange: 30...55, hasVictim: true,
        summaries: [
            "{D} shot {V}, {DL}'s spouse of fourteen years, while {VL} was asleep. The defense says it ended a decade of documented abuse. Hours earlier, {VL} had said: \"Tomorrow, I'm going to kill you.\"",
            "Police found {D} sitting calmly on the porch next to a revolver. Inside, {V} was dead in bed. Neighbors had called police to that house eleven times in six years."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Gun Purchase", "{DL} bought the revolver two days before the shooting."),
            E(.forensic, 5, "Autopsy", "{V} was lying down, likely asleep, when shot. There was no struggle."),
            E(.statement, 3, "911 Call", "{DL} calmly told the dispatcher: \"I did it. It's over now.\"", .statement),
            E(.digital, 3, "Texts to a Friend", "\"I can't do this anymore. One of us has to go.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 4, "Hospital Records", "Seven ER visits in five years: a broken jaw, cracked ribs, a ruptured eardrum."),
            E(.document, 3, "Injury Photographs", "Photos {DL} hid in a shoebox, dated over eight years."),
            E(.document, 3, "Expert on Battered Person Syndrome", "Explains why victims can perceive danger as imminent even during a lull in violence."),
            E(.document, 2, "Abandoned Protective Order", "A protective order petition {DL} started but never filed, with a note: \"he'll find out.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Homicide detective",
                        direct: ["\"{VL} was asleep. Whatever happened before, there was no threat in that bedroom at that moment.\""],
                        cross: ["\"Yes, we'd been called to that house eleven times. No, no arrest was ever made.\""],
                        weight: 2, lay: false),
            WitnessSeed(name: nil, role: "{VL}'s coworker",
                        direct: ["\"{VL} was a good parent. Coached Little League. Never saw a temper.\""],
                        cross: ["\"I only knew {VL} at work.\""],
                        weight: 1, lay: true)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Next-door neighbor",
                        direct: ["\"For years I heard screaming through the walls. Things breaking. Once I saw {DL} run out barefoot in January.\""],
                        cross: ["\"No, I never saw a punch thrown myself.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["Whatever {V} did in the past, {D} bought a gun, waited for {VL} to fall asleep, and executed {VL}. That's not self-defense. That's murder."],
        defenseTheory: ["{D} lived in a war zone for fourteen years. When {VL} said 'tomorrow,' {DL} believed it, because {VL} had always kept those promises."],
        aggravating: ["Victim was asleep and defenseless", "Firearm purchased in advance"],
        mitigating: ["Fourteen years of documented abuse by the victim", "Immediately called 911 and confessed", "No criminal record"],
        victimImpacts: ["{VL}'s mother: \"My child was no angel. But this was an execution.\"",
                        "The couple's teenage child: \"Please. Please let my parent come home. I'm the one who knows what happened in that house.\""],
        guiltyTruths: ["Journals found later showed {DL} had planned it for months and had arranged a new life with someone else."],
        innocentTruths: ["The couple's child later testified at a clemency hearing that {VL} had loaded a shotgun that night and laid it under the bed."],
        moods: [.divided, .sympathetic],
        doctrines: ["selfDefense", "batteredSpouse", "imperfectSelfDefense", "lesserIncluded"]
    )

    static let protestAssault = CaseTemplate(
        key: "protestAssault", category: .violent,
        headlines: ["Chaos at City Hall", "The Thrown {OBJ}"],
        primaryLaw: "awdwisi", lesserLaw: "aisi", threshold: 5, lesserThreshold: 3,
        specification: "Struck {V} with a thrown {OBJ}, causing serious bodily injury.",
        secondary: [SecondaryCharge(lawID: "riot", specification: "Willfully engaged in a riot outside Port Hollis City Hall.", chance: 0.5, threshold: 4)],
        ageRange: 19...34, hasVictim: true,
        summaries: [
            "During a clash between protesters and counter-protesters outside City Hall, {V} was knocked unconscious by a thrown {OBJ} and suffered a fractured skull. {D} was identified from viral social media video.",
            "Two rival rallies collided on the City Hall steps. In the chaos, a {OBJ} hit {V} in the head. Online sleuths named {D}; police arrested {DL} the next day."
        ],
        prosecutionEvidence: [
            E(.video, 4, "Viral Video", "A figure in a black hoodie, face partly covered, hurls the {OBJ}. Online commenters identified the figure as {DL}."),
            E(.digital, 2, "Facial Recognition Match", "A facial recognition system flagged {DL} as a \"probable match\" at 78% confidence."),
            E(.physical, 3, "Black Hoodie and Gloves", "Found in {DL}'s backpack two days later.", .search),
            E(.digital, 3, "Social Media Post", "That night, {DL} posted: \"we didn't start it but we finished it.\"", .search),
            E(.forensic, 3, "Medical Records", "{V}'s skull fracture required surgery and caused permanent hearing loss.")
        ],
        defenseEvidence: [
            E(.video, 4, "Second Angle", "A different video shows {V} swinging a flagpole at protesters seconds earlier."),
            E(.document, 2, "Dozens of Black Hoodies", "Photographs show at least 30 protesters dressed identically."),
            E(.document, 3, "Facial Recognition Error Rates", "An audit found the system's error rate triples in low light and with partial face coverings.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Injured counter-protester",
                        direct: ["\"I turned around and everything went black. I woke up in the hospital and couldn't hear out of my left ear.\""],
                        cross: ["\"I had a flag. On a pole. It's a flag.\""],
                        weight: 1, lay: true),
            WitnessSeed(name: "{OFF}", role: "Crowd-control officer",
                        direct: ["\"I saw a person in a black hoodie throw something heavy. Moments later we arrested {DL} nearby.\""],
                        cross: ["\"There were a lot of people in black hoodies, yes.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Street medic",
                        direct: ["\"I was with {DL} the whole time near the fountain. We were treating someone who'd been pepper-sprayed.\""],
                        cross: ["\"We're in the same activist group, yes.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["Political passion doesn't excuse violence. {D} threw a {OBJ} at a human being's head."],
        defenseTheory: ["The State charged the hoodie, not the person. And whoever threw it was defending people from a flagpole."],
        aggravating: ["Permanent hearing loss", "Violence at a public demonstration"],
        mitigating: ["The victim was swinging a flagpole at the crowd", "No prior record", "Youth"],
        victimImpacts: ["{V}: \"I went to express my opinion. I came home deaf in one ear.\""],
        guiltyTruths: ["{DL} later admitted it on a podcast: \"Yeah, that was me. I'd do it again.\""],
        innocentTruths: ["A year later, an unblurred video identified the thrower as {ALT}, who had left the state the night of the protest."],
        moods: [.divided],
        doctrines: ["defenseOfOthers", "expertTestimony", "lesserIncluded"],
        extras: ["OBJ": ["brick", "frozen water bottle", "chunk of concrete"]]
    )

    static let policeForce = CaseTemplate(
        key: "policeForce", category: .violent,
        headlines: ["Nine Swings", "The Taillight Stop"],
        primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon (a police baton), inflicting serious injury.",
        ageRange: 29...50, occupations: ["police officer, 12 years on the force", "police sergeant, 19 years on the force"],
        hasVictim: true,
        summaries: [
            "Officer {D} pulled over {V} for a broken taillight. Within four minutes, {VL} was on the ground with a broken arm and an orbital fracture, struck nine times by {DL}'s baton. {DL} says {VL} reached for a weapon.",
            "Bodycam footage of {D} beating {V} during a traffic stop sparked protests across {CITY}. {DL}'s union says the footage doesn't show what {DL} saw."
        ],
        prosecutionEvidence: [
            E(.video, 5, "Bodycam Footage", "Nine baton strikes over 14 seconds. The last four come after {VL} is face-down."),
            E(.forensic, 3, "Medical Records", "Broken ulna, fractured orbital bone, and a concussion."),
            E(.document, 2, "Use-of-Force Policy", "Department policy requires force to stop once a subject is controlled."),
            E(.statement, 3, "Partner's Statement", "The partner told Internal Affairs: \"I yelled at {DL} to stop. {DL} didn't.\"", .statement)
        ],
        defenseEvidence: [
            E(.video, 3, "Waistband Reach", "Frame-by-frame, {VL}'s hand moves toward the waistband just before the first strike."),
            E(.forensic, 2, "Toxicology", "{VL} had PCP in their system, which is associated with high pain tolerance."),
            E(.document, 3, "Use-of-Force Expert", "A former training commander says the first five strikes were consistent with training given a perceived weapon threat.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Motorist",
                        direct: ["\"I was reaching to pull my pants up. They were falling down when I got out. I didn't have anything.\""],
                        cross: ["\"Yeah, I'd smoked something earlier. That doesn't mean I deserved this.\""],
                        weight: 2, lay: true),
            WitnessSeed(name: "{OFF}", role: "Partner officer (testifying reluctantly)",
                        direct: ["\"After the fifth strike, {VL} wasn't resisting anymore. I said 'stop.'\""],
                        cross: ["\"I couldn't see {VL}'s hands at the start. Yes, I'd have been worried too.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former police training commander",
                        direct: ["\"An officer has a split second. A hand to the waistband is the most dangerous movement there is.\""],
                        cross: ["\"I can't justify the last four strikes by my training, no.\""],
                        weight: 1, lay: false)
        ],
        prosecutionTheory: ["A badge is not a license. {D} kept swinging long after any threat was gone."],
        defenseTheory: ["{D} made a split-second decision in a dangerous stop, and is being judged by people watching in slow motion."],
        aggravating: ["Abuse of public trust and authority", "Strikes continued after the victim was subdued"],
        mitigating: ["Victim initially reached toward waistband", "Exemplary service record with two commendations"],
        victimImpacts: ["{V}: \"I can't lift my daughter with that arm anymore. For a taillight.\""],
        guiltyTruths: ["Text messages surfaced later: before the shift, {DL} had told a friend, \"Gonna crack some heads tonight.\""],
        innocentTruths: ["The department later found a defect in the bodycam that dropped frames. The restored video showed {VL} pulling a box cutter before the first strike."],
        moods: [.divided, .wantsConviction],
        doctrines: ["selfDefense", "lesserIncluded"]
    )

    static let custodyFlight = CaseTemplate(
        key: "custodyFlight", category: .family,
        headlines: ["Five Months on the Run", "A Parent's Choice"],
        primaryLaw: "transportChild", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Transported a six-year-old child outside North Carolina with intent to violate a custody order.",
        ageRange: 27...44, hasVictim: true,
        summaries: [
            "{D} took their six-year-old across state lines in violation of a custody order and hid for five months. {DL} says the child's other parent, {V}, was abusing the child, and that no one would listen.",
            "An AMBER alert ended when a motel clerk in another state recognized {D} and their six-year-old. {DL} had violated the custody order granting {V} primary custody. {DL} insists it was to save the child."
        ],
        prosecutionEvidence: [
            E(.document, 5, "Custody Order", "A family court order granting {V} primary custody. {DL} was served and acknowledged it."),
            E(.document, 3, "Motel Records", "Five months of cash payments under a false name, across three states."),
            E(.document, 3, "New School Enrollment", "{DL} enrolled the child in a new school under a different last name."),
            E(.statement, 3, "Statement at Arrest", "\"I'd do it again. I'd do it a hundred times.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Bruise Photographs", "Photos of bruises on the child's upper arms, taken after visits with {V}."),
            E(.document, 2, "Closed CPS Report", "A child-welfare report against {V}, closed as \"unsubstantiated\" after a 20-minute visit."),
            E(.document, 3, "Therapist's Notes", "The child told a therapist they were \"scared of the dark room\" at {VL}'s house.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Custodial parent",
                        direct: ["\"For five months I didn't know if my child was alive.\""],
                        cross: ["\"Those bruises came from soccer. CPS cleared me.\""],
                        weight: 2, lay: true)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Child's former teacher",
                        direct: ["\"After weekends with {VL}, the child would hide under the reading table and wouldn't come out.\""],
                        cross: ["\"No, the child never said {VL} hurt them.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["North Carolina has a process for custody disputes. {D} ignored a court order, ran, and made a child disappear."],
        defenseTheory: ["{D} did what the system wouldn't: protected a child. The necessity defense exists for parents like {DL}."],
        aggravating: ["Concealed the child for five months under a false name", "Crossed state lines"],
        mitigating: ["Credible concerns of abuse", "Child returned safe and healthy", "No criminal record"],
        victimImpacts: ["{V}: \"My child doesn't trust me now. {DL} told them I was dangerous. That's the real abuse.\""],
        guiltyTruths: ["A forensic interview after the case found no evidence of abuse. The child's fear had been coached by {DL}."],
        innocentTruths: ["Two years later, {V} was convicted of abusing a stepchild in another household."],
        moods: [.divided, .sympathetic],
        doctrines: ["necessity", "lesserIncluded"]
    )

    // MARK: - Property & white collar

    static let burglary = CaseTemplate(
        key: "burglary", category: .property,
        headlines: ["Vacation Break-In on {STREET}", "The Broken Window"],
        primaryLaw: "burglary2", lesserLaw: "feloniousBE", threshold: 7, lesserThreshold: 5,
        specification: "Broke and entered the {VL} home at night with intent to commit larceny.",
        secondary: [SecondaryCharge(lawID: "felonyLarceny", specification: "Larceny of {LOOT} pursuant to a breaking or entering.", chance: 0.8, threshold: 0)],
        ageRange: 18...45, hasVictim: true,
        summaries: [
            "While the {VL} family was on vacation, someone broke a back window of their home on {STREET} and took {LOOT}. A week later, {D} tried to sell some of the items.",
            "{V} came home from a funeral to find a shattered window and {LOOT} missing. A detective spotted one of the items in a pawn listing under {D}'s name."
        ],
        prosecutionEvidence: [
            E(.document, 4, "Pawn Receipt", "{DL} pawned a ring matching the stolen wedding band two days after the burglary."),
            E(.forensic, 5, "DNA on Glass", "DNA from blood on the broken window glass matches {DL}."),
            E(.video, 3, "Doorbell Camera", "A hooded figure in a neighbor's camera at 2 a.m. Height and build roughly match {DL}."),
            E(.statement, 2, "Statement to Police", "\"I found the stuff in a dumpster, I swear.\"", .statement),
            E(.physical, 4, "Items in Car", "Two of the stolen items were in {DL}'s car trunk.", .search),
            E(.forensic, 2, "Shoe Print", "A partial sneaker print in the flowerbed, a common size-10 brand.")
        ],
        defenseEvidence: [
            E(.document, 3, "Landscaping Records", "{DL} worked on a crew that maintained the {VL} yard. A mower-thrown rock broke that very window three weeks earlier, and {DL} cut a hand cleaning it up."),
            E(.document, 2, "Alley Post", "A neighborhood app post the morning after: \"Someone dumped a bunch of stuff in the alley behind {STREET}?\""),
            E(.document, 2, "Paid Fair Price", "Records show {DL} also tried to return one item to a lost-and-found website.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"That ring was my grandmother's. I felt sick seeing it on a pawn website.\""],
                        cross: ["\"Yes, the landscapers broke that window once before. We had it replaced.\""],
                        weight: 1, lay: true),
            WitnessSeed(name: "{DET}", role: "Property crimes detective",
                        direct: ["\"DNA at the point of entry, stolen property in the car. It's about as clean as burglaries get.\""],
                        cross: ["\"We didn't test whether the blood was fresh or weeks old.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Landscaping crew boss",
                        direct: ["\"{DL} cut a hand bad picking up that glass. I drove {DL} to urgent care myself.\""],
                        cross: ["\"I fired {DL} a week later. For lateness.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["{D} knew the house, knew the family was away, and came back for what was inside."],
        defenseTheory: ["{DL}'s blood was on that window because {DL} cleaned it up weeks before. Finding stolen goods doesn't make you the thief."],
        aggravating: ["Targeted a home {DL} knew from work", "Irreplaceable heirlooms taken"],
        mitigating: ["Some items returned", "Supporting a younger sibling"],
        victimImpacts: ["{V}: \"I don't sleep in my own house anymore. I bought a gun. I've never owned a gun.\""],
        guiltyTruths: ["{DL}'s former crewmate later admitted to driving the getaway car with {DL}."],
        innocentTruths: ["{ALT}, a neighbor's nephew, was caught a year later with more items from the same house in a storage unit."],
        moods: [.wantsConviction, .indifferent],
        doctrines: ["lesserIncluded", "chainOfCustody"],
        extras: ["LOOT": ["jewelry and two laptops", "a coin collection worth $14,000", "a gaming console, cash, and a wedding ring"]]
    )

    static let embezzlement = CaseTemplate(
        key: "embezzlement", category: .whiteCollar,
        headlines: ["The Treasurer of {CHARITY}", "Charity Begins at Home"],
        primaryLaw: "embezzlement100k", lesserLaw: nil, threshold: 7, lesserThreshold: 7,
        specification: "Diverted {AMT} in donations from {CHARITY} for personal use.",
        ageRange: 38...66, occupations: ["volunteer treasurer and accountant", "retired bank manager"],
        hasVictim: false,
        summaries: [
            "{D} served as treasurer of {CHARITY} for nine years. An audit found {AMT} missing. The State says {DL} funneled it into personal accounts through fake invoices.",
            "When {CHARITY} couldn't make payroll, the board called in auditors. The money trail led to the longtime treasurer, {D}, a pillar of the community."
        ],
        prosecutionEvidence: [
            E(.document, 5, "Bank Records", "Transfers totaling {AMT} from charity accounts to an account controlled by {DL}."),
            E(.document, 4, "Forensic Accountant's Report", "Systematic diversion over 4 years, timed after board meetings."),
            E(.document, 3, "Fake Invoices", "Invoices from a \"consulting firm\" registered to {DL}'s cousin, for services never performed."),
            E(.document, 2, "Boat Purchase", "{DL} bought a used boat for $48,000 in cash."),
            E(.digital, 3, "Email to Self", "\"Pay it back after the settlement comes in. Nobody needs to know.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "Board Minutes", "2019 minutes approve \"treasurer advances\" without defining them."),
            E(.document, 2, "Partial Repayment", "{DL} repaid $40,000 before the audit began."),
            E(.document, 3, "Co-Signatures", "Every check was co-signed by board president {ALT}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic accountant",
                        direct: ["\"This wasn't sloppy bookkeeping. It was engineered.\""],
                        cross: ["\"Yes, the board president signed every check as well.\""],
                        weight: 2, lay: false),
            WitnessSeed(name: nil, role: "Charity executive director",
                        direct: ["\"We cut our after-school program. Forty kids lost their only hot meal of the day.\""],
                        cross: ["\"{DL} was the one who founded that program, yes.\""],
                        weight: 1, lay: true)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former board member",
                        direct: ["\"The board knew about the advances. {ALT} called it 'the treasurer's float.'\""],
                        cross: ["\"No, I never saw a written agreement.\""],
                        weight: 2, lay: true)
        ],
        prosecutionTheory: ["{D} stole from children, veterans, and the hungry, and hid it behind a smile and nine years of trust."],
        defenseTheory: ["The board approved advances, signed every check, and is now pointing at the one person who wasn't careful with the paperwork."],
        aggravating: ["Stole from a charity", "Abuse of a position of trust", "Long-running scheme"],
        mitigating: ["Partial repayment", "Gambling addiction now in treatment", "Decades of community service"],
        victimImpacts: ["Executive director of {CHARITY}: \"Donations have dropped by half. People don't trust us anymore. That's the real loss.\""],
        guiltyTruths: ["{DL}'s gambling records later showed {AMT} lost at an offshore sportsbook during the same period."],
        innocentTruths: ["{ALT}, the board president, was later indicted for running the same scheme at two other nonprofits."],
        moods: [.wantsConviction],
        doctrines: ["victimRights", "burdenOfProof"],
        extras: ["CHARITY": ["the Port Hollis Children's Food Bank", "Harbor Street Animal Rescue", "the Hollis County Veterans' Fund"],
                 "AMT": ["$184,000", "$412,000", "$136,500"]]
    )

    static let medicineTheft = CaseTemplate(
        key: "medicineTheft", category: .property,
        headlines: ["Stolen Medicine", "A Mother's Insulin"],
        primaryLaw: "misdLarceny", lesserLaw: nil, threshold: 8, lesserThreshold: 8,
        specification: "Stole {MEDS} from {PHARM}.",
        secondary: [SecondaryCharge(lawID: "resisting", specification: "Pulled away from an officer during the arrest.", chance: 0.4, threshold: 9)],
        ageRange: 24...47, hasVictim: false,
        summaries: [
            "{D}, a {DO}, was stopped leaving {PHARM} with {MEDS} hidden in a coat. {DL} says it was for a child whose insurance had lapsed, and that {DL} couldn't afford it.",
            "Security at {PHARM} caught {D} concealing {MEDS}. The story went viral after {DL}'s sibling posted the child's medical bills online."
        ],
        prosecutionEvidence: [
            E(.video, 5, "Store Video", "Clear footage of {DL} placing the items inside a coat and walking past the registers."),
            E(.document, 3, "Loss Prevention Report", "Items recovered at the door, total retail value {AMT}."),
            E(.physical, 3, "Recovered Items", "{MEDS}, still in {PHARM} packaging, found in {DL}'s coat.", .search),
            E(.statement, 3, "Statement to Security", "\"I didn't have a choice. You don't understand.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 2, "Child's Medical Records", "{DL}'s child has a chronic condition requiring this medication daily."),
            E(.document, 2, "Insurance Denial", "A denial letter dated two weeks before, after {DL} lost a job."),
            E(.document, 1, "Payment Attempt", "{DL} had asked the pharmacist about a payment plan an hour earlier and was turned away.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Loss prevention officer",
                        direct: ["\"I watched the whole thing on camera. Very deliberate.\""],
                        cross: ["\"{DL} was crying when I stopped them, yes.\""],
                        weight: 2, lay: true)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pharmacist",
                        direct: ["\"{DL} asked me if there was any way to pay over time. I had to say no. Corporate policy.\""],
                        cross: ["\"There are charity programs. I didn't think to mention them.\""],
                        weight: 1, lay: true)
        ],
        prosecutionTheory: ["Sympathy is not a defense. {D} knowingly took property that wasn't {DL}'s. The law is the same for everyone."],
        defenseTheory: ["Necessity: a child's life against a corporation's merchandise. Any parent would have done the same."],
        aggravating: ["Prior theft conviction"],
        mitigating: ["Took life-sustaining medicine for a child", "Attempted to arrange payment first", "Items recovered undamaged"],
        allocutions: ["{DL}: \"I'd do anything for my kid. I know that's not an excuse. It's just the truth.\""],
        guiltyTruths: ["The child's medicine was real, and so was the theft. {DL} had done it before, three times, at other stores."],
        innocentTruths: ["Months later, {PHARM} found a scanning glitch. {DL} had actually paid for one of the items in a separate transaction. But the rest was taken."],
        moods: [.sympathetic],
        doctrines: ["necessity", "dispositions"],
        extras: ["MEDS": ["two boxes of insulin pens", "an asthma inhaler and antibiotics", "an EpiPen two-pack"],
                 "PHARM": ["MediMart Pharmacy", "Hollis Drug & Sundry", "CareWell Pharmacy"],
                 "AMT": ["$642", "$318", "$575"]]
    )

    static let insuranceArson = CaseTemplate(
        key: "insuranceArson", category: .violent,
        headlines: ["Fire at {REST}", "Burned for the Payout?"],
        primaryLaw: "burningBuildings", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
        specification: "Set fire to {REST}, a restaurant owned by the defendant.",
        secondary: [SecondaryCharge(lawID: "insuranceFraud", specification: "Submitted a $640,000 insurance claim for the fire, knowing it contained false information.", chance: 0.7, threshold: 6)],
        ageRange: 35...60, occupations: ["restaurant owner"], hasVictim: false,
        summaries: [
            "{REST}, a struggling restaurant owned by {D}, burned to the ground at 3 a.m. Six weeks earlier, {DL} had doubled the fire insurance. A firefighter was hospitalized.",
            "When {REST} went up in flames, the fire marshal called it arson within hours. The owner, {D}, was $200,000 in debt and had just raised the insurance."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Insurance Increase", "Coverage doubled to $640,000 six weeks before the fire."),
            E(.forensic, 3, "Pour Patterns", "The fire marshal identified \"pour patterns\" and \"crazed glass\" indicating an accelerant."),
            E(.forensic, 4, "Gasoline Residue", "Lab tests found gasoline residue near the back door."),
            E(.document, 3, "Debts", "$200,000 in unpaid loans and a pending eviction."),
            E(.digital, 3, "Phone Location", "{DL}'s phone was near the restaurant at 2:40 a.m., though {DL} told police they were home.", .search)
        ],
        defenseEvidence: [
            E(.document, 4, "Independent Fire Expert", "\"Pour patterns\" and \"crazed glass\" also appear in ordinary fires after flashover. The scientific community has rejected them as arson indicators."),
            E(.document, 3, "Code Violations", "An inspection two months earlier cited faulty wiring in the kitchen."),
            E(.physical, 2, "Generator Fuel", "{DL} stored gasoline by the back door for a backup generator, a fact noted in the inspection.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Deputy fire marshal",
                        direct: ["\"Twenty-two years on the job. I know an accelerant fire when I see one.\""],
                        cross: ["\"I haven't read the latest NFPA 921 revisions, no.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fire science professor",
                        direct: ["\"These 'indicators' sent innocent people to prison for decades. They don't hold up.\""],
                        cross: ["\"I can't tell you what did start the fire. Only that the marshal's methods can't either.\""],
                        weight: 2, lay: false)
        ],
        prosecutionTheory: ["{D} was drowning in debt, raised the insurance, and lit the match, and a firefighter nearly died for it."],
        defenseTheory: ["The State's case rests on fire science that's been discredited. Bad wiring burned that kitchen, not {DL}."],
        aggravating: ["A firefighter was hospitalized", "Financial motive"],
        mitigating: ["No prior record", "Twenty years of employing neighborhood kids"],
        victimImpacts: ["The injured firefighter: \"I've got burn scars on 30% of my body. If it was set on purpose, I want that person to know my name.\""],
        guiltyTruths: ["A cook later admitted {DL} had paid them $2,000 to \"not be there that night.\""],
        innocentTruths: ["An electrical engineer's reexamination traced the fire to a failed connection in the walk-in freezer."],
        moods: [.wantsConviction, .indifferent],
        doctrines: ["expertTestimony"],
        extras: ["REST": ["Rosalind's Diner", "Pho Golden", "the Blue Gull Grill", "Casa Mirasol"]]
    )

    static let elderScam = CaseTemplate(
        key: "elderScam", category: .whiteCollar,
        headlines: ["The Grandparent Scam", "Money Mule"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 8, lesserThreshold: 8,
        specification: "Obtained {AMT} from {V} by deception.",
        secondary: [SecondaryCharge(lawID: "identityTheft", specification: "Opened bank accounts using another person's identity.", chance: 0.4, threshold: 9)],
        ageRange: 20...35, hasVictim: true,
        summaries: [
            "{V}, 81, got a call from someone claiming to be a grandson in jail. {VL} wired {AMT}. Investigators say {D} was the \"money mule\" who received the money and forwarded it overseas.",
            "Elderly {V} lost {AMT} to a phone scammer. The money went into an account belonging to {D}, who says they thought it was a legitimate work-from-home job."
        ],
        prosecutionEvidence: [
            E(.document, 5, "Bank Records", "{AMT} from {V} landed in {DL}'s account, and 94% was wired abroad within two hours."),
            E(.video, 3, "ATM Footage", "{DL} withdrawing cash in maximum daily amounts for three days."),
            E(.physical, 3, "Burner Phone", "A prepaid phone found in {DL}'s apartment.", .search),
            E(.digital, 4, "Handler Messages", "\"Move it fast. Don't answer the bank if they call.\" {DL} replied: \"got it 👍\"", .search)
        ],
        defenseEvidence: [
            E(.digital, 4, "Job Offer Emails", "A professional-looking \"payment processing assistant\" job offer with a contract and a fake HR portal."),
            E(.document, 2, "{DL}'s Own Losses", "{DL} was never paid, and lost $1,800 of their own money in the \"job.\""),
            E(.document, 2, "Language Barrier", "{DL} reads English at a 4th-grade level. The job ad was in their first language.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Victim",
                        direct: ["\"He sounded just like my grandson. Crying. Said he'd been in a car accident.\""],
                        cross: ["\"No, I never spoke to the defendant.\""],
                        weight: 1, lay: true),
            WitnessSeed(name: nil, role: "Bank fraud investigator",
                        direct: ["\"Rapid in, rapid out. It's the textbook money-mule pattern.\""],
                        cross: ["\"Many mules are victims too. They're recruited with fake jobs.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Fraud researcher",
                        direct: ["\"Criminal networks deliberately recruit immigrants and students as unwitting mules.\""],
                        cross: ["\"A reasonable person might find being told to dodge the bank's calls suspicious, yes.\""],
                        weight: 1, lay: false)
        ],
        prosecutionTheory: ["{D} was the indispensable link that turned an old person's terror into cash for criminals overseas."],
        defenseTheory: ["{D} was scammed too: a job seeker used by the same criminals who targeted {V}."],
        aggravating: ["Elderly victim", "Victim lost life savings"],
        mitigating: ["Minimal profit", "Recruited through a fake job", "Cooperated with investigators"],
        victimImpacts: ["{V}: \"That was my funeral money. Now my kids will have to pay to bury me. I'm so ashamed.\""],
        guiltyTruths: ["Investigators later found {DL} had recruited three other mules and taken a 10% cut each time."],
        innocentTruths: ["The overseas ring was dismantled the next year. Its records listed {DL} under \"unaware recruits.\""],
        moods: [.wantsConviction, .divided],
        doctrines: ["mistakeOfFact", "victimRights"],
        extras: ["AMT": ["$46,000", "$12,500", "$88,000"]]
    )

    static let councilBribe = CaseTemplate(
        key: "councilBribe", category: .whiteCollar,
        headlines: ["Cash for Zoning", "The Councilmember's Envelope"],
        primaryLaw: "bribery", lesserLaw: nil, threshold: 7, lesserThreshold: 7,
        specification: "Accepted {AMT} from a developer in exchange for a zoning vote.",
        ageRange: 40...65, occupations: ["city councilmember"], hasVictim: false,
        summaries: [
            "Councilmember {D} is accused of taking {AMT} from developer {ALT} in exchange for a key zoning vote. The State Bureau of Investigation recorded their meetings using a cooperating witness facing his own charges.",
            "A sting operation caught City Councilmember {D} accepting an envelope at a steakhouse. Days later, {DL} flipped a vote on a waterfront tower."
        ],
        prosecutionEvidence: [
            E(.video, 4, "Recorded Meeting", "{DL}: \"We'll take care of this. You take care of us.\" An envelope changes hands."),
            E(.document, 4, "Deposit", "{AMT} deposited to {DL}'s campaign account two days later."),
            E(.document, 3, "Flipped Vote", "{DL} had publicly opposed the tower for a year, then voted yes.")
        ],
        defenseEvidence: [
            E(.document, 3, "Reported Contribution", "The deposit was reported as a campaign contribution, as the law requires."),
            E(.document, 2, "Informant's Deal", "The cooperating witness faces 20 years and will be sentenced after this trial."),
            E(.document, 3, "Planning Staff Report", "The city's planning staff recommended a yes vote after the developer added affordable housing.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Cooperating witness",
                        direct: ["\"Everyone knew {DL}'s vote was for sale. I just had to bring the envelope.\""],
                        cross: ["\"Yes, prosecutors told me my cooperation would be 'considered.'\""],
                        weight: 2, lay: true),
            WitnessSeed(name: nil, role: "SBI special agent",
                        direct: ["\"The recording speaks for itself.\""],
                        cross: ["\"The informant initiated all four meetings. {DL} declined the first two.\""],
                        weight: 1, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "City planning director",
                        direct: ["\"After the developer added 80 affordable units, a yes vote made sense. I recommended it.\""],
                        cross: ["\"I can't say why {DL} changed position, only that it was defensible.\""],
                        weight: 1, lay: false)
        ],
        prosecutionTheory: ["The vote was bought, plainly, on tape. Public office is a public trust, and {D} sold it."],
        defenseTheory: ["A lawful, reported contribution, a defensible vote, and an informant who'd say anything to stay out of prison. And the government pushed until it got a quote."],
        aggravating: ["Senior elected official", "Corruption of public decision-making"],
        mitigating: ["Contribution was publicly reported", "Long public service"],
        guiltyTruths: ["A second envelope, never mentioned at trial, was found in {DL}'s safe deposit box."],
        innocentTruths: ["The informant later recanted in a sworn affidavit: the \"take care of us\" line referred to affordable-housing commitments."],
        moods: [.wantsConviction, .divided],
        doctrines: ["entrapment", "burdenOfProof"],
        extras: ["AMT": ["$25,000", "$40,000", "$15,000"]]
    )

    static let ponzi = CaseTemplate(
        key: "ponzi", category: .whiteCollar,
        headlines: ["The Hollis Harbor Fund", "Returns Too Good to Be True"],
        primaryLaw: "falsePretenses100k", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Defrauded investors of {AMT} through false account statements.",
        secondary: [SecondaryCharge(lawID: "securitiesFraud", specification: "Made materially false statements in connection with the sale of securities.", chance: 0.6, threshold: 0)],
        ageRange: 38...64, occupations: ["financial advisor"], hasVictim: false,
        summaries: [
            "For six years, {D}'s Hollis Harbor Fund reported steady 11% returns. When a market dip triggered withdrawals, the fund collapsed. {AMT} from 140 investors, many retired teachers, was gone.",
            "Retirees trusted {D} with their savings. The statements looked perfect. The money, investigators say, had been used to pay earlier investors, and {DL}'s mortgage."
        ],
        prosecutionEvidence: [
            E(.document, 5, "Fabricated Statements", "Account statements show trades that never occurred at any exchange."),
            E(.document, 3, "Missing Registration", "The fund was never registered with state securities regulators."),
            E(.digital, 4, "Internal Emails", "{DL} to an assistant: \"Just roll the new money into the Patterson withdrawal. We'll fix it next quarter.\"", .search),
            E(.document, 3, "Lavish Spending", "$1.4 million of fund money went to {DL}'s lake house.")
        ],
        defenseEvidence: [
            E(.document, 2, "Real Losses", "The fund did hold real investments early on, and it lost heavily in a market crash."),
            E(.document, 3, "Compliance Advice", "An outside compliance consultant advised that registration \"wasn't required yet.\""),
            E(.document, 2, "Repayment Plan", "{DL} proposed a repayment plan and surrendered personal assets.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Retired teacher and investor",
                        direct: ["\"Thirty-one years of teaching. All of it, gone. I'm stocking shelves at 72.\""],
                        cross: ["\"No, {DL} never guaranteed the returns. Not in writing.\""],
                        weight: 2, lay: true),
            WitnessSeed(name: nil, role: "Forensic accountant",
                        direct: ["\"After 2021, no real investments existed. Only incoming money and outgoing money.\""],
                        cross: ["\"Before 2021, the trading was real.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Compliance consultant",
                        direct: ["\"I told {DL} the registration could wait. That was my mistake, not {DL}'s.\""],
                        cross: ["\"I never saw the account statements.\""],
                        weight: 1, lay: false)
        ],
        prosecutionTheory: ["{D} lied to people who trusted {DL} with everything, and kept lying until the money ran out."],
        defenseTheory: ["A real fund that failed. Bad judgment and bad advice, but not a criminal scheme."],
        aggravating: ["140 victims", "Retirees' life savings", "Years-long scheme"],
        mitigating: ["Surrendered personal assets", "No prior record"],
        victimImpacts: ["An investor: \"I had to tell my grandkids there's no college fund. I can't look at them.\""],
        guiltyTruths: ["An offshore account in {DL}'s name, holding $3 million, was discovered two years later."],
        innocentTruths: ["Investigators later found that {DL}'s operations manager, {ALT}, had generated the fake statements without {DL}'s knowledge."],
        moods: [.wantsConviction],
        doctrines: ["victimRights", "lesserIncluded"],
        extras: ["AMT": ["$23 million", "$8.7 million", "$41 million"]]
    )

    // MARK: - Drugs

    static let trafficStopDrugs = CaseTemplate(
        key: "trafficStopDrugs", category: .drugs,
        headlines: ["Route 9 Traffic Stop", "What Was in the Trunk"],
        primaryLaw: "pwisd", lesserLaw: "possSchedII", threshold: 6, lesserThreshold: 4,
        specification: "Possessed {QTY} of {DRUG} with intent to distribute.",
        ageRange: 19...45, hasVictim: false,
        summaries: [
            "During a traffic stop on N.C. 87 at {TIME}, Officer {OFF} found {QTY} of {DRUG} in {D}'s car, along with a digital scale and {CASH} in cash.",
            "{D} was pulled over a mile from {HOOD}. A search turned up {QTY} of {DRUG}. The State says {DL} is a dealer; {DL} says {DL} is an addict."
        ],
        prosecutionEvidence: [
            E(.physical, 5, "The Drugs", "{QTY} of {DRUG} in 14 individually knotted baggies.", .search),
            E(.physical, 3, "Scale and Baggies", "A digital scale with residue and a box of 200 small baggies.", .search),
            E(.physical, 2, "Cash", "{CASH} in mixed small bills.", .search),
            E(.digital, 4, "Text Messages", "\"need a half by 9?\" and \"same price as last time\" from {DL}'s phone.", .search),
            E(.statement, 1, "Roadside Statement", "\"It's mine. For me. I'm not selling anything.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Addiction Treatment Records", "{DL} has been in and out of treatment for opioid use disorder for six years."),
            E(.document, 2, "Paycheck Stub", "{DL} cashed a paycheck the same day for nearly the same amount."),
            E(.document, 3, "Shared Car", "The car is registered to {DL}'s brother, who drives it most days.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "Arresting officer",
                        direct: ["\"I stopped the vehicle and observed the packaging in plain view.\""],
                        cross: ["\"The trunk was closed, yes. I opened it.\""],
                        weight: 2, lay: false),
            WitnessSeed(name: nil, role: "Narcotics detective",
                        direct: ["\"Individual baggies, scale, cash: that's distribution. Users don't package like that.\""],
                        cross: ["\"Some heavy users buy in bulk to save money, yes.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Addiction counselor",
                        direct: ["\"At {DL}'s tolerance, that quantity could be a three-week personal supply.\""],
                        cross: ["\"I can't explain the text messages.\""],
                        weight: 2, lay: false)
        ],
        prosecutionTheory: ["The quantity, the packaging, the scale, the cash, the texts. Everything here says dealer."],
        defenseTheory: ["{D} is sick, not a kingpin. This is a possession case dressed up as a distribution case."],
        aggravating: ["Distribution activity in a residential neighborhood", "Prior drug convictions"],
        mitigating: ["Long history of addiction", "Low-level role", "Enrolled in treatment since arrest"],
        guiltyTruths: ["{DL} was arrested a year later with three times the amount and a customer list."],
        innocentTruths: ["{DL}'s brother later admitted the scale and texts were his. The drugs in the glovebox were {DL}'s personal supply."],
        moods: [.indifferent, .divided],
        doctrines: ["searchSeizure", "warrantExceptions", "lesserIncluded"],
        extras: ["QTY": ["14 grams", "21 grams", "26 grams"],
                 "DRUG": ["cocaine", "methamphetamine"],
                 "CASH": ["$2,340", "$880", "$4,100"]]
    )

    static let overdose = CaseTemplate(
        key: "overdose", category: .drugs,
        headlines: ["One Pill", "Best Friends"],
        primaryLaw: "deathByDistribution", lesserLaw: "deliverSchedII", threshold: 6, lesserThreshold: 4,
        specification: "Sold a controlled substance whose ingestion caused the death of {V}.",
        ageRange: 19...26, hasVictim: true,
        summaries: [
            "{V}, 22, died of a fentanyl overdose at a party in {HOOD}. {D}, {VL}'s best friend since grade school, is accused of buying the pills and handing one to {VL}.",
            "Two friends took what they thought were Percocets. One woke up. {D} called 911 and did CPR until paramedics arrived, but {V} was already gone."
        ],
        prosecutionEvidence: [
            E(.digital, 5, "Purchase Texts", "{DL} arranged the buy with a dealer: \"2 blues for me and my boy.\"", .search),
            E(.digital, 3, "Payment App", "{V} sent {DL} $40 an hour before, with the memo \"🍕\"."),
            E(.forensic, 3, "Toxicology", "{V} died of fentanyl toxicity. No other drugs were present."),
            E(.statement, 4, "Statement at Hospital", "\"I got them from a guy. I gave {VL} one. Oh my god, I killed my best friend.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "911 Call and CPR", "{DL} called 911 within a minute and did CPR for eleven minutes."),
            E(.digital, 3, "Joint Purchase", "{V} suggested buying the pills and paid half."),
            E(.digital, 2, "Victim's Own Source", "{V}'s phone shows contact with a different dealer the week before.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Overdose task force detective",
                        direct: ["\"Every fentanyl death has a supply chain. {DL} was the last link.\""],
                        cross: ["\"{DL} didn't profit. They split it. Yes.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Paramedic",
                        direct: ["\"{DL} was doing compressions, sobbing, begging {VL} to breathe. I've seen dealers run. That wasn't a dealer.\""],
                        cross: ["\"I don't know who bought the pills.\""],
                        weight: 2, lay: false)
        ],
        prosecutionTheory: ["The General Assembly made it a crime to sell the drug that kills someone. {D} sold it."],
        defenseTheory: ["Two friends made a terrible choice together. One died. Charging the survivor with homicide doesn't bring {V} back."],
        aggravating: ["Fentanyl crisis in the community"],
        mitigating: ["Called 911 and performed CPR", "No profit motive", "Close friend of the victim", "Own addiction"],
        victimImpacts: ["{VL}'s mother: \"Please don't send another child to prison. My baby is gone. I can't stand to see two families destroyed.\"",
                        "{VL}'s father: \"Somebody handed my son poison. I don't care if they were friends. Somebody has to answer for it.\""],
        guiltyTruths: ["Phone records later showed {DL} had been selling pills to classmates for months."],
        innocentTruths: ["The full message history showed {V} had arranged the buy; {DL} only picked it up."],
        moods: [.sympathetic, .divided],
        doctrines: ["lesserIncluded"]
    )

    // MARK: - Traffic

    static let drunkCrash = CaseTemplate(
        key: "drunkCrash", category: .traffic,
        headlines: ["Crash on {ROAD}", "Six Beers and a Missing Sign"],
        primaryLaw: "felonyDBV", lesserLaw: "misdDBV", threshold: 6, lesserThreshold: 4,
        specification: "Unintentionally caused the death of {V} while engaged in impaired driving.",
        ageRange: 21...60, hasVictim: true,
        summaries: [
            "At {TIME}, {D}'s pickup crossed the center line on {ROAD} and struck a sedan, killing {V}, a nurse heading home from a night shift.",
            "{V} was killed instantly when {D}'s truck drifted into oncoming traffic on {ROAD}. {DL}'s blood-alcohol was drawn three hours later."
        ],
        prosecutionEvidence: [
            E(.forensic, 5, "Blood Alcohol Test", "{DL}'s BAC was 0.14%, drawn at the hospital without a warrant or consent.", .search),
            E(.document, 4, "Crash Reconstruction", "The pickup was 3 feet over the center line at impact."),
            E(.document, 2, "Bar Tab", "Six beers on {DL}'s tab, closed 40 minutes before the crash."),
            E(.video, 3, "Dashcam", "A trucker's dashcam shows the pickup weaving for half a mile."),
            E(.statement, 1, "Roadside Statement", "\"I only had a couple. The road just disappeared.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Missing Warning Sign", "A city work order shows the curve warning sign had been down for six weeks."),
            E(.document, 3, "Victim's Speed", "The sedan's black box recorded 58 mph in a 35 zone."),
            E(.document, 2, "Rising BAC Expert", "With a draw three hours later, {DL}'s BAC at the time of driving could have been below 0.08%.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{TROOPER}", role: "N.C. State Highway Patrol trooper",
                        direct: ["\"Strong odor of alcohol, slurred speech, couldn't walk a line.\""],
                        cross: ["\"{DL} had a head injury from the airbag, yes. That can cause slurring.\""],
                        weight: 2, lay: false),
            WitnessSeed(name: nil, role: "Crash reconstructionist",
                        direct: ["\"The pickup was in the wrong lane. That's physics, not opinion.\""],
                        cross: ["\"At 58 miles an hour, the sedan's stopping distance doubles. Yes.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Forensic toxicologist",
                        direct: ["\"Alcohol absorption can take up to two hours. A late draw tells you very little.\""],
                        cross: ["\"Six beers in two hours would put most people over the limit.\""],
                        weight: 2, lay: false)
        ],
        prosecutionTheory: ["{D} chose to drink, chose to drive, and {V} paid with their life."],
        defenseTheory: ["A missing sign, a speeding car, and a blood test taken three hours late. The State can't prove {DL}'s drinking caused this crash."],
        aggravating: ["BAC nearly twice the legal limit", "Victim killed instantly"],
        mitigating: ["Stayed at the scene and tried to help", "Deep remorse", "Victim was speeding"],
        victimImpacts: ["{VL}'s spouse: \"She saved lives for twenty years. She was coming home to us.\"",
                        "{VL}'s sister: \"I forgive you. I have to, or I'll drown. But please never drive drunk again.\""],
        guiltyTruths: ["{DL} had texted a friend that night: \"too drunk to drive lol, doing it anyway.\""],
        innocentTruths: ["A city engineer later testified the curve had a design flaw that had caused four other crashes that year."],
        moods: [.wantsConviction],
        doctrines: ["searchSeizure", "warrantExceptions", "lesserIncluded"],
        extras: ["ROAD": ["N.C. 87", "Old Quarry Road", "the Harbor Bridge", "U.S. 17"]]
    )

    // MARK: - Cyber

    static let ransomware = CaseTemplate(
        key: "ransomware", category: .cyber,
        headlines: ["Hospital Held Hostage", "The Encrypted Emergency Room"],
        primaryLaw: "extortion", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Threatened to keep {HOSP}'s systems encrypted unless paid {RANSOM}, with intent to wrongfully obtain it.",
        secondary: [SecondaryCharge(lawID: "accessingComputers", specification: "Accessed {HOSP}'s computer network to execute a scheme to obtain property.", chance: 0.7, threshold: 0)],
        ageRange: 19...29, occupations: ["self-taught programmer", "IT help desk technician", "computer science student"],
        hasVictim: false,
        summaries: [
            "{HOSP}'s computer systems were encrypted for nine days, forcing ambulances to divert. The attacker demanded {RANSOM}. Investigators traced the ransom wallet to {D}.",
            "A ransomware attack shut down {HOSP}'s records, pharmacy, and imaging. A patient in cardiac arrest was diverted 30 minutes away. FBI cyber agents arrested {D} three months later."
        ],
        prosecutionEvidence: [
            E(.digital, 4, "Wallet Trace", "Blockchain analysis links the ransom wallet to an exchange account verified with {DL}'s ID."),
            E(.digital, 3, "Forum Posts", "Posts by the handle \"n1ghtsh4de\" sold access to hospital networks. The handle was registered with an email {DL} used."),
            E(.digital, 5, "Seized Laptop", "{DL}'s laptop held the ransomware builder and the hospital's decryption key.", .search),
            E(.document, 2, "Ambulance Diversion Logs", "47 ambulances were diverted during the outage.")
        ],
        defenseEvidence: [
            E(.digital, 3, "Open Wi-Fi", "{DL}'s home network had an unsecured guest Wi-Fi used by neighbors."),
            E(.digital, 2, "Shared Handle", "Forum moderators say \"n1ghtsh4de\" was a group account used by at least three people."),
            E(.document, 2, "Stolen ID", "{DL} reported a stolen wallet, with ID, eight months earlier.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "FBI cyber analyst",
                        direct: ["\"The decryption key on {DL}'s laptop is the only one that unlocks this hospital's files. That's like finding the murder weapon.\""],
                        cross: ["\"Someone with access to the network could, in theory, have planted it.\""],
                        weight: 3, lay: false),
            WitnessSeed(name: nil, role: "Hospital chief medical officer",
                        direct: ["\"We went back to paper charts. We couldn't see allergies. We couldn't see scans.\""],
                        cross: ["\"No patient deaths have been attributed to the attack.\""],
                        weight: 1, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Independent security researcher",
                        direct: ["\"Ransomware gangs routinely frame newcomers. Laptops get compromised.\""],
                        cross: ["\"I found no evidence {DL}'s laptop was compromised.\""],
                        weight: 1, lay: false)
        ],
        prosecutionTheory: ["{D} held a hospital hostage for money while patients waited for care."],
        defenseTheory: ["Open Wi-Fi, a shared handle, a stolen ID. The digital trail points at {DL} because someone wanted it to."],
        aggravating: ["Targeted a hospital, endangering patients", "Large ransom demand"],
        mitigating: ["Youth", "No prior record", "Provided decryption help after arrest"],
        victimImpacts: ["A nurse at {HOSP}: \"We were hand-writing medication doses in the dark. One mistake and someone dies.\""],
        guiltyTruths: ["Seized server logs from the ransomware group, published a year later, showed {DL} as an administrator."],
        innocentTruths: ["{DL}'s roommate, {ALT}, fled the country the week of trial. The FBI later found the real operation on {ALT}'s cloud server."],
        moods: [.wantsConviction],
        doctrines: ["expertTestimony", "searchSeizure", "lesserIncluded"],
        extras: ["HOSP": ["St. Brigid's Medical Center", "Port Hollis General", "Hollis Regional Medical Center"],
                 "RANSOM": ["$2.5 million", "$800,000", "$4 million"]]
    )

    static let imageLeak = CaseTemplate(
        key: "imageLeak", category: .cyber,
        headlines: ["After the Breakup", "Leaked"],
        primaryLaw: "privateImages", lesserLaw: nil, threshold: 9, lesserThreshold: 9,
        specification: "Distributed intimate images of {V} without consent.",
        secondary: [SecondaryCharge(lawID: "cyberstalking", specification: "Repeatedly sent electronic messages to {V} to harass and terrify.", chance: 0.35, threshold: 10)],
        ageRange: 20...35, hasVictim: true,
        summaries: [
            "Weeks after their breakup, private photos of {V} appeared on a forum and were emailed to {VL}'s employer. {VL} says only {D} ever had them.",
            "{V} lost a teaching job after intimate photos were sent to the school board. {VL} accuses ex-partner {D}, who denies everything."
        ],
        prosecutionEvidence: [
            E(.digital, 4, "IP Address Logs", "The forum upload came from an IP address assigned to {DL}'s apartment building."),
            E(.digital, 4, "Threatening Message", "Three days before: \"everyone's going to see who you really are.\""),
            E(.digital, 3, "Photos on Phone", "The same images were found on {DL}'s phone.", .search),
            E(.digital, 3, "Burner Email", "The email to the employer was sent from an account recovered with {DL}'s phone number.")
        ],
        defenseEvidence: [
            E(.document, 3, "Cloud Breach", "{V}'s cloud storage provider disclosed a data breach affecting 2 million accounts that month."),
            E(.digital, 2, "Shared Building IP", "The building has one shared IP address for 60 units."),
            E(.digital, 2, "Shared Password", "{V} and {DL} shared streaming and email passwords for two years.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complainant",
                        direct: ["\"My students' parents saw them. I can't go to the grocery store without wondering who's seen me.\""],
                        cross: ["\"Yes, I got the breach notification email. I didn't think anything of it.\""],
                        weight: 2, lay: true),
            WitnessSeed(name: nil, role: "Digital forensics examiner",
                        direct: ["\"The account recovery number belongs to {DL}. That's not a coincidence.\""],
                        cross: ["\"Anyone who knew the password could change a recovery number.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s coworker",
                        direct: ["\"{DL} was with me at a work conference three hours away when that email was sent.\""],
                        cross: ["\"You can send an email from anywhere, I guess.\""],
                        weight: 1, lay: true)
        ],
        prosecutionTheory: ["A threat, then a leak. {D} warned {V} exactly what was coming, then did it."],
        defenseTheory: ["A massive data breach, a shared IP, shared passwords. A bitter text isn't proof."],
        aggravating: ["Images sent to the victim's employer", "Victim lost their job"],
        mitigating: ["No prior record", "Youth"],
        victimImpacts: ["{V}: \"That's the first thing that comes up when you search my name now. Forever.\""],
        guiltyTruths: ["A deleted draft of the email was later recovered from {DL}'s laptop."],
        innocentTruths: ["The images turned up on a breach-dump marketplace alongside thousands of others from the same cloud hack."],
        moods: [.wantsConviction, .indifferent],
        doctrines: ["searchSeizure", "burdenOfProof"]
    )

    static let stalking = CaseTemplate(
        key: "stalking", category: .violent,
        headlines: ["The Tracker Under the Bumper", "Sixty Messages"],
        primaryLaw: "stalking", lesserLaw: nil, threshold: 8, lesserThreshold: 8,
        specification: "Engaged in a course of conduct directed at {V} causing fear for safety.",
        ageRange: 24...50, hasVictim: true,
        summaries: [
            "Weeks after leaving {D}, {V} found a GPS tracker under the car's bumper. {VL} also reports 60+ unanswered messages and {DL}'s car parked outside {VL}'s new apartment six times.",
            "{V} moved across town to get away from {D}. Within a week, {DL} was \"coincidentally\" at the same coffee shop, gym, and grocery store."
        ],
        prosecutionEvidence: [
            E(.document, 4, "Tracker Purchase", "{DL}'s account bought the same model GPS tracker two weeks after the breakup."),
            E(.digital, 4, "Message Log", "64 messages in nine days, ending with: \"You can't hide from me. I'll always find you.\""),
            E(.video, 3, "Neighbor's Photos", "Timestamped photos of {DL}'s car outside {VL}'s building on six nights."),
            E(.digital, 4, "Tracker App Login", "The tracker's app was logged into from {DL}'s phone.", .search)
        ],
        defenseEvidence: [
            E(.digital, 3, "Dog Custody Messages", "Many messages concerned custody of a shared dog, and {VL} sometimes replied."),
            E(.document, 2, "Commute Route", "{DL}'s workplace is three blocks from {VL}'s new building."),
            E(.document, 2, "Tracker for the Dog", "{DL} says the tracker was for the dog's collar and went missing during a handoff.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complainant",
                        direct: ["\"I sleep with a chair under the doorknob. I check my car with a flashlight every morning.\""],
                        cross: ["\"Yes, we were arguing about the dog. That doesn't explain the tracker.\""],
                        weight: 2, lay: true)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Dog walker",
                        direct: ["\"{DL} asked me if I'd seen the dog's GPS tag after a handoff. That was weeks before any of this.\""],
                        cross: ["\"{DL} pays me, yes.\""],
                        weight: 1, lay: true)
        ],
        prosecutionTheory: ["The messages, the tracker, the car outside. {D} made it impossible for {V} to feel safe anywhere."],
        defenseTheory: ["A messy breakup and a shared dog. Not every heartbroken ex is a stalker."],
        aggravating: ["Used a GPS tracking device", "Threatening language"],
        mitigating: ["No physical contact", "Engaged in counseling since arrest"],
        victimImpacts: ["{V}: \"If you let {DL} go, I need you to know I'll be moving again. Probably out of state.\""],
        guiltyTruths: ["Six months later, police found a second tracker on {VL}'s new car. {DL} was arrested in the parking lot."],
        innocentTruths: ["The tracker's serial number matched the dog's lost collar tag, registered under {VL}'s own account."],
        moods: [.wantsConviction, .indifferent],
        doctrines: ["searchSeizure"]
    )

    // MARK: - Weapons

    static let felonGun = CaseTemplate(
        key: "felonGun", category: .publicOrder,
        headlines: ["Protection or Crime?", "The Gun in the Glovebox"],
        primaryLaw: "felonFirearm", lesserLaw: nil, threshold: 7, lesserThreshold: 7,
        specification: "Possessed a loaded firearm while prohibited due to a prior felony conviction.",
        ageRange: 30...52, requiresFelonyPrior: true,
        hasVictim: false,
        summaries: [
            "{D}, convicted of a nonviolent felony twelve years ago, was found with a loaded pistol in the glovebox. {DL} says it was for protection after the house was shot at twice in a month. In North Carolina, that is a Class G felony no matter the reason.",
            "After two drive-by shootings at {DL}'s home in {HOOD}, police did nothing. Then they stopped {D} for a cracked windshield and found a gun. Under G.S. 14-415.1, a felon cannot possess a firearm, period."
        ],
        prosecutionEvidence: [
            E(.physical, 5, "Loaded Pistol", "A 9mm handgun with seven rounds, in the glovebox.", .search),
            E(.document, 4, "Prior Conviction Record", "Certified record of {DL}'s felony conviction."),
            E(.statement, 3, "Roadside Admission", "\"Yeah, it's mine. You'd carry one too if you lived on my street.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Shooting Reports", "Two police reports of shots fired into {DL}'s home, with bullet holes in a child's bedroom."),
            E(.digital, 3, "Threatening Messages", "\"Next time we won't miss.\""),
            E(.document, 1, "Restraining Order Application", "{DL} applied for a restraining order against an unknown person, which was denied.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "Arresting officer",
                        direct: ["\"I saw the grip of a handgun when {DL} opened the glovebox for the registration.\""],
                        cross: ["\"I was aware of the shootings at the house, yes.\""],
                        weight: 2, lay: false)
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s teenage daughter",
                        direct: ["\"I was asleep when the bullet came through my window. It hit the wall right above my bed.\""],
                        cross: ["\"No, I didn't know Dad kept a gun.\""],
                        weight: 1, lay: true)
        ],
        prosecutionTheory: ["The General Assembly decided people with felony convictions may not possess firearms. Fear, however real, isn't a license."],
        defenseTheory: ["Justification. {D}'s family was being shot at and police did nothing. The law can't demand that a parent wait to die."],
        aggravating: ["Loaded firearm in a vehicle"],
        mitigating: ["Documented threats against the family", "Old nonviolent prior", "Steady employment for a decade"],
        guiltyTruths: ["The shootings were real. So was the gun. {DL} had been carrying it for years, long before the threats."],
        innocentTruths: ["Six months later, the people who shot at {DL}'s house were arrested. The gun had been bought the day after the first shooting."],
        moods: [.sympathetic, .divided],
        doctrines: ["justification", "searchSeizure", "priorRecord"]
    )
}
