import Foundation

private typealias E = EvidenceSeed

extension CaseTemplates {
    static let expandedB: [CaseTemplate] = [

        CaseTemplate(
            key: "shakenInfant", category: .family,
            headlines: ["Four Months Old", "The Babysitter's Account"],
            primaryLaw: "felonyChildAbuse", lesserLaw: "childAbuseMisd", threshold: 5, lesserThreshold: 3,
            specification: "As caretaker of a four-month-old infant, intentionally inflicted serious physical injury.",
            ageRange: 19...40, hasVictim: false,
            summaries: [
                "A four-month-old was rushed to Hollis Regional limp and vomiting. Doctors found bleeding around the brain and two healing rib fractures. {D}, a parent's partner, was the only adult home that afternoon.",
                "{D} called 911 saying the baby they were babysitting \"stopped breathing.\" A CT scan showed a subdural hematoma and retinal hemorrhages. {DL} says the baby rolled off a couch."
            ],
            prosecutionEvidence: [
                E(.forensic, 5, "Child Abuse Pediatrician", "Subdural hemorrhage, retinal hemorrhages, and healing rib fractures: findings the pediatrician calls \"diagnostic of abusive head trauma.\""),
                E(.document, 3, "Timeline", "The infant was normal at drop-off according to daycare records; symptoms began while {DL} was alone with the baby."),
                E(.statement, 3, "Changing Accounts", "{DL} told EMS the baby choked, told the nurse the baby fell, and told detectives the baby rolled off a couch.", .statement)
            ],
            defenseEvidence: [
                E(.document, 4, "Defense Biomechanical Expert", "Short falls can, rarely, cause subdural bleeding; the rib fractures may be from birth."),
                E(.document, 2, "Vitamin D Deficiency", "Lab work shows the infant had low vitamin D, which some experts link to fragile bones.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Board-certified child abuse pediatrician",
                            direct: ["\"A fall from a couch does not cause this constellation of injuries.\""],
                            cross: ["\"The science around shaken baby syndrome has been debated. I'm confident in this diagnosis.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Biomechanical engineer",
                            direct: ["\"The 'triad' alone does not prove shaking. Several convictions based on it have been overturned.\""],
                            cross: ["\"I'm not a medical doctor.\""],
                            weight: 2, lay: false)
            ],
            prosecutionTheory: ["The baby was fine at noon and fighting for life by three. {D} was the only one there."],
            defenseTheory: ["This case is built on contested science and a frightened caregiver's inconsistent memory of a terrifying moment."],
            aggravating: ["The victim was very young", "The offense was especially heinous, atrocious, or cruel"],
            mitigating: ["No prior record", "The defendant called 911 immediately"],
            guiltyTruths: ["{DL} later admitted to a jail chaplain shaking the baby to stop the crying."],
            innocentTruths: ["Genetic testing a year later found the infant had a rare collagen disorder causing fragile vessels and bones."],
            moods: [.wantsConviction, .divided],
            doctrines: ["expertTestimony", "lesserIncluded"]
        ),

        CaseTemplate(
            key: "animalHoarding", category: .publicOrder,
            headlines: ["Forty-One Dogs", "The Rescue That Wasn't"],
            primaryLaw: "animalCruelty", lesserLaw: nil, threshold: 4, lesserThreshold: 4,
            specification: "Deprived animals of necessary sustenance and shelter at a property in {HOOD}.",
            ageRange: 45...75, hasVictim: false,
            summaries: [
                "Animal control removed 41 dogs from {D}'s mobile home in {HOOD}. Many were emaciated and several had untreated infections. {DL} ran an unlicensed \"rescue\" for a decade.",
                "Neighbors complained about the smell for months. When deputies entered {D}'s house, they found 23 cats, 9 dead, and ammonia levels that required respirators."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Veterinary Reports", "Body condition scores of 1 or 2 out of 9 for most animals."),
                E(.video, 3, "Seizure Video", "Footage of the conditions inside the home.", .search),
                E(.document, 2, "Prior Warnings", "Two prior animal control warnings in 2022 and 2023.")
            ],
            defenseEvidence: [
                E(.document, 3, "Mental Health Evaluation", "A psychologist diagnoses hoarding disorder."),
                E(.document, 2, "Rescue Intake Records", "Many animals arrived already sick from other owners.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Hollis County Animal Services veterinarian",
                            direct: ["\"These animals were starving in the presence of someone who loved them.\""],
                            cross: ["\"Some came in with conditions that predated the seizure, yes.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Clinical psychologist",
                            direct: ["\"Hoarding disorder is a recognized mental illness. {DL} genuinely believes they were saving these animals.\""],
                            cross: ["\"Understanding it doesn't undo what the animals went through.\""],
                            weight: 2, lay: false)
            ],
            prosecutionTheory: ["Good intentions don't feed a dog."],
            defenseTheory: ["{DL} needs treatment, not a criminal record."],
            aggravating: ["Large number of animals affected"],
            mitigating: ["The defendant has a mental condition that reduced culpability", "Advanced age"],
            guiltyTruths: ["After the case, {DL} was found with eleven new dogs in another county."],
            innocentTruths: ["{DL} entered treatment and now volunteers, supervised, at the county shelter."],
            moods: [.divided, .sympathetic],
            doctrines: ["dispositions"]
        ),

        CaseTemplate(
            key: "roadRage", category: .violent,
            headlines: ["Tire Iron on Marlowe Boulevard", "The Merge"],
            primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 4, lesserThreshold: 2,
            specification: "Assaulted {V} with a tire iron, inflicting serious injury.",
            ageRange: 25...60, hasVictim: true,
            summaries: [
                "After a near-collision at a merge on Marlowe Boulevard, both drivers got out. {V} ended up with a fractured eye socket. {D} says {VL} came at them with fists and a tire iron was the only thing in reach.",
                "Dashcam footage went viral: {D} swinging a tire iron at {V}'s windshield, then at {VL}, at a red light in {HOOD}."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Dashcam Video", "A third driver's dashcam shows {DL} retrieving a tire iron from the trunk before the confrontation."),
                E(.forensic, 3, "Medical Records", "Orbital fracture requiring surgery."),
                E(.physical, 2, "Tire Iron", "Recovered from {DL}'s trunk with blood on the end.", .search)
            ],
            defenseEvidence: [
                E(.video, 3, "Victim Approached First", "The same dashcam shows {VL} getting out first and walking toward {DL}'s car yelling."),
                E(.document, 2, "Victim's Size", "{VL} is six inches taller and 80 pounds heavier than {DL}.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Other driver",
                            direct: ["\"I walked over to talk. I never touched {DL}.\""],
                            cross: ["\"I was yelling, sure. I was mad.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Passenger in the defendant's car",
                            direct: ["\"{VL} was screaming about killing us. {DL} grabbed the first thing in the trunk.\""],
                            cross: ["\"The tire iron was in the trunk, so {DL} had to walk around to get it.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["{D} went to the trunk, got a weapon, and used it. That's a choice."],
            defenseTheory: ["A much bigger person approached screaming threats. {DL} had every right to defend themselves."],
            aggravating: ["Use of a deadly weapon"],
            mitigating: ["The victim was the initial aggressor in words", "No prior record"],
            victimImpacts: ["{V}: \"I have double vision. I can't drive at night anymore.\""],
            guiltyTruths: ["{DL} had posted online a month earlier: \"Next person who cuts me off gets the tire iron.\""],
            innocentTruths: ["{VL} had two prior road rage convictions in Virginia, which surfaced after the trial."],
            moods: [.divided, .indifferent],
            doctrines: ["selfDefense", "lesserIncluded"]
        ),

        CaseTemplate(
            key: "stolenWorkTruck", category: .property,
            headlines: ["The Stolen F-250", "Keys in the Ignition"],
            primaryLaw: "felonyLarceny", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Stole a pickup truck and tools worth more than $1,000 belonging to {V}.",
            secondary: [SecondaryCharge(lawID: "fleeing", specification: "Fled a deputy in the stolen truck with two aggravating factors.", chance: 0.35, threshold: 0)],
            ageRange: 18...35, hasVictim: true,
            summaries: [
                "{V}, a contractor, left a work truck running outside a gas station in {HOOD}. It was gone in thirty seconds, along with $9,000 in tools. A deputy spotted it two days later with {D} at the wheel.",
                "A truck stolen from a job site turned up in {D}'s driveway with the tools missing. {DL} says it was bought for $800 cash from a stranger."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Gas Station Video", "Someone in a red jacket climbing into the running truck."),
                E(.physical, 3, "Red Jacket", "A red jacket in {DL}'s closet.", .search),
                E(.document, 3, "Pawn Records", "Two of {VL}'s saws pawned by {DL} the next day.")
            ],
            defenseEvidence: [
                E(.document, 3, "Bill of Sale", "A handwritten bill of sale for $800 signed by an \"R. Jones.\""),
                E(.document, 2, "Common Jacket", "The red jacket is a common hunting-store brand.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Truck owner",
                            direct: ["\"Thirty seconds. I went in for a coffee. That truck is my whole business.\""],
                            cross: ["\"Yes, I left it running.\""],
                            weight: 1, lay: true),
                WitnessSeed(name: "{DET}", role: "Investigator",
                            direct: ["\"An $800 bill of sale for a $40,000 truck tells you the buyer knew.\""],
                            cross: ["\"We never located an R. Jones.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s roommate",
                            direct: ["\"I was there when {DL} bought it. Some guy in a parking lot.\""],
                            cross: ["\"I thought it was a little cheap, sure.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} drove off in a running truck and pawned the tools the next morning."],
            defenseTheory: ["{DL} made a bad deal with the wrong person. That's not larceny."],
            aggravating: ["The offense involved damage causing great monetary loss"],
            mitigating: ["Youth", "The truck was recovered"],
            victimImpacts: ["{V}: \"I lost three jobs waiting on new tools. I had to lay off my nephew.\""],
            guiltyTruths: ["A gas station clerk later identified {DL} from a photo array as the person in the red jacket."],
            innocentTruths: ["A man named {ALT} was arrested selling two more stolen trucks with the same kind of bill of sale."],
            moods: [.indifferent],
            doctrines: ["searchSeizure"]
        ),

        CaseTemplate(
            key: "prescriptionForgery", category: .drugs,
            headlines: ["The Prescription Pad", "Dr. Who?"],
            primaryLaw: "prescriptionFraud", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Obtained oxycodone from {PHARM} by presenting a forged prescription.",
            ageRange: 25...55, hasVictim: false,
            summaries: [
                "A pharmacist at {PHARM} called a doctor's office to verify an oxycodone prescription. The doctor had never seen {D}. A stolen prescription pad had been reported a month earlier.",
                "{D} filled oxycodone prescriptions at five pharmacies in three weeks, all written on a pad stolen from an urgent care clinic."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Forged Prescription", "Written on a reported-stolen pad, with a misspelled drug name."),
                E(.video, 3, "Pharmacy Video", "{DL} handing the prescription to the pharmacist."),
                E(.document, 3, "PDMP Report", "The state prescription database shows five fills in three weeks.")
            ],
            defenseEvidence: [
                E(.document, 3, "Chronic Pain History", "Records of a spinal injury and years of legitimate pain prescriptions until a clinic closed."),
                E(.document, 2, "Pad from Friend", "{DL} says a friend who \"worked at a clinic\" provided the prescriptions.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Pharmacist",
                            direct: ["\"Oxycodone spelled with an 'e.' No doctor writes that.\""],
                            cross: ["\"{DL} was polite and waited while I called.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Pain management physician",
                            direct: ["\"When a clinic closes, patients are cut off cold. Some go to the street. Some do this.\""],
                            cross: ["\"That doesn't make forging prescriptions legal.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["{D} knew those prescriptions were forged and used them anyway."],
            defenseTheory: ["{DL} is a pain patient who was abandoned by the medical system."],
            aggravating: ["Multiple pharmacies defrauded"],
            mitigating: ["The defendant has a physical condition that reduced culpability", "The defendant has entered treatment"],
            guiltyTruths: ["{DL}'s fingerprints were found on the stolen pad's cardboard backing."],
            innocentTruths: ["The friend, {ALT}, was charged with stealing pads from three clinics and selling forged prescriptions."],
            moods: [.sympathetic, .indifferent],
            doctrines: ["dispositions"],
            extras: ["PHARM": ["the Walgreens on Pell Avenue", "Hollis Drug & Sundry", "the CVS in Bayard"]]
        ),

        CaseTemplate(
            key: "fakeCop", category: .publicOrder,
            headlines: ["Blue Lights on a Dark Road", "Not a Real Deputy"],
            primaryLaw: "impersonatingLEO", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Falsely represented being a sworn law enforcement officer by operating blue lights on a private vehicle.",
            ageRange: 25...60, hasVictim: true,
            summaries: [
                "{V} was pulled over on a dark road in {HOOD} by a car with blue dash lights. The \"officer\" asked for a license and let {VL} go. {VL} reported it; the Sheriff's Office had no deputy there. {D} was arrested with blue lights and a fake badge.",
                "Several drivers reported a fake traffic stop on U.S. 17. A deputy pulled over {D}'s Crown Victoria and found a light bar, a scanner, and a holstered airsoft gun."
            ],
            prosecutionEvidence: [
                E(.physical, 4, "Blue Lights and Badge", "Dash-mounted blue lights and a novelty badge in the car.", .search),
                E(.document, 3, "Victim Identification", "{V} identified {DL}'s car by its distinctive dent and wheels."),
                E(.digital, 2, "Online Purchases", "Orders for a light bar and \"police-style\" badge.", .search)
            ],
            defenseEvidence: [
                E(.document, 2, "Security Guard Job", "{DL} works as a licensed security guard and uses amber lights at work."),
                E(.document, 2, "Collector", "{DL} collects police memorabilia and belongs to a collectors' club.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Driver who was stopped",
                            direct: ["\"I thought I was going to die on that road. Nobody knew where I was.\""],
                            cross: ["\"No, nothing happened besides checking my license.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Collectors' club president",
                            direct: ["\"Lots of our members have lights. They're display pieces.\""],
                            cross: ["\"No, we don't put them on the dashboard and turn them on.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["Every fake stop teaches people not to trust a real one."],
            defenseTheory: ["Owning lights isn't a crime, and nobody saw {DL} use them."],
            aggravating: ["The defendant targeted lone drivers at night"],
            mitigating: ["No one was harmed", "No prior record"],
            victimImpacts: ["{V}: \"I don't pull over for blue lights anymore. I drive to a gas station first.\""],
            guiltyTruths: ["A camera on {DL}'s dash had recorded nine traffic stops."],
            innocentTruths: ["Another collector, {ALT}, was arrested a year later after a similar stop; the car matched the description."],
            moods: [.wantsConviction],
            doctrines: ["searchSeizure"]
        ),

        CaseTemplate(
            key: "perjuryTrial", category: .publicOrder,
            headlines: ["The Alibi That Wasn't", "Lied Under Oath"],
            primaryLaw: "perjury", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Willfully and corruptly testified falsely, under oath, in a prior Hollis County criminal trial.",
            ageRange: 22...55, hasVictim: false,
            summaries: [
                "Last year, {D} testified at a cousin's robbery trial in this courthouse that the cousin was at {D}'s apartment all night. Phone records later put {D} in Raleigh that night.",
                "{D} swore at a probation hearing that {D} had never met a key witness. Text messages between the two surfaced afterward."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Trial Transcript", "The certified transcript of {DL}'s sworn testimony."),
                E(.digital, 4, "Phone Records", "{DL}'s phone was in Raleigh from 6 p.m. to 2 a.m. that night.", .search),
                E(.document, 2, "Hotel Receipt", "A Raleigh hotel receipt in {DL}'s name.")
            ],
            defenseEvidence: [
                E(.document, 3, "Confusion About Dates", "{DL} made two trips to Raleigh that month and testified a year after the events."),
                E(.document, 2, "Phone Lent Out", "{DL} says a sibling borrowed the phone for the trip.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Assistant District Attorney who tried the robbery case",
                            direct: ["\"The alibi was the defense's whole case. The jury hung because of it.\""],
                            cross: ["\"I didn't know about the phone records at the time.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s sibling",
                            direct: ["\"I had {DL}'s phone and car that weekend.\""],
                            cross: ["\"I didn't mention that to anybody for a year.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} lied to a jury to free a cousin. If that's not punished, the oath means nothing."],
            defenseTheory: ["A mistaken memory about dates a year later isn't a willful lie."],
            aggravating: ["The perjury caused a mistrial in a serious felony case"],
            mitigating: ["No prior record"],
            guiltyTruths: ["The cousin, convicted at retrial, admitted at sentencing that {DL} lied to cover for the cousin."],
            innocentTruths: ["Hotel staff later confirmed the guest that night was {DL}'s sibling, using {DL}'s card."],
            moods: [.indifferent],
            doctrines: ["burdenOfProof"]
        ),

        CaseTemplate(
            key: "hiddenGun", category: .publicOrder,
            headlines: ["The Gun in the Attic", "A Parent's Instinct"],
            primaryLaw: "obstruction", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Obstructed justice by concealing a firearm sought as evidence in a homicide investigation.",
            ageRange: 40...65, hasVictim: false,
            summaries: [
                "After a shooting in {HOOD}, detectives searched {D}'s house for a pistol belonging to {D}'s 19-year-old son. They found it wrapped in a towel in the attic insulation. {DL} had told them there was no gun.",
                "{D} drove to a pond the morning after a shooting and threw something in. Divers recovered the pistol used in the shooting."
            ],
            prosecutionEvidence: [
                E(.physical, 4, "The Pistol", "Recovered from the attic, wrapped in a towel from {DL}'s bathroom.", .search),
                E(.statement, 3, "Denial to Detectives", "\"There's no gun in this house. I don't allow them.\"", .statement),
                E(.video, 2, "Neighbor's Camera", "{DL} carrying a towel-wrapped bundle to the garage the night of the shooting.")
            ],
            defenseEvidence: [
                E(.document, 2, "Son's Access", "The son had keys and lived at the house; anyone could have hidden it."),
                E(.document, 2, "Panic", "{DL} has an anxiety disorder and says they panicked when detectives arrived.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{DET}", role: "Homicide detective",
                            direct: ["\"That gun was the key to a murder case. It took us four days to find it because of {DL}.\""],
                            cross: ["\"The son was charged separately, yes.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s pastor",
                            direct: ["\"{DL} is a good parent who was terrified for a child.\""],
                            cross: ["\"I don't know what {DL} did with the gun.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["Love for a child doesn't give anyone the right to hide a murder weapon."],
            defenseTheory: ["The State can't prove {DL}, rather than the son, hid that gun."],
            aggravating: ["The obstruction concerned a homicide investigation"],
            mitigating: ["The defendant acted out of concern for a family member", "No prior record"],
            guiltyTruths: ["{DL} later admitted to wrapping the gun, in a letter to the son in jail."],
            innocentTruths: ["The son told his lawyer he hid the gun himself before his parent got home."],
            moods: [.divided, .sympathetic],
            doctrines: ["searchSeizure", "burdenOfProof"]
        ),

        CaseTemplate(
            key: "protectiveOrderParty", category: .family,
            headlines: ["The Birthday Party", "Five Hundred Feet"],
            primaryLaw: "dvpoViolation", lesserLaw: nil, threshold: 4, lesserThreshold: 4,
            specification: "Knowingly violated a domestic violence protective order by coming to {V}'s residence.",
            secondary: [SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened to harm {V}.", chance: 0.4, threshold: 0)],
            ageRange: 24...45, hasVictim: true,
            summaries: [
                "{V} had a one-year protective order against {D}. On their child's sixth birthday, {DL} showed up at the party with a gift. Deputies arrived as {DL} was leaving.",
                "Three weeks after a protective order was served, {D} sat in a parked car outside {V}'s workplace for an hour. A coworker took photos."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Protective Order", "A Chapter 50B order, served personally on {DL}, prohibiting contact and coming within 500 feet."),
                E(.video, 3, "Party Video", "A guest's phone video shows {DL} in the backyard holding a wrapped present."),
                E(.document, 2, "Prior Violation Report", "A prior report of {DL} texting {V}, not prosecuted.")
            ],
            defenseEvidence: [
                E(.document, 3, "Invitation", "A text from {V}'s mother: \"Come by for a few minutes, the baby misses you.\""),
                E(.document, 2, "Custody Order", "A separate custody order grants {DL} visitation.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Protected party",
                            direct: ["\"I got that order because I was scared. Seeing {DL} in my yard, I froze.\""],
                            cross: ["\"I didn't know my mother texted {DL}.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{VL}'s mother",
                            direct: ["\"I invited {DL}. It was a child's birthday.\""],
                            cross: ["\"I knew about the order. I thought one day wouldn't hurt.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["The order said 500 feet. {D} was in the backyard."],
            defenseTheory: ["{DL} was invited by family to a child's party and left the moment it was clear it was a problem."],
            aggravating: ["Prior violations of the order"],
            mitigating: ["The defendant was invited by a family member", "The defendant left voluntarily"],
            victimImpacts: ["{V}: \"I need the court to tell me that order means something.\""],
            guiltyTruths: ["The next month, {DL} was arrested with a knife outside {VL}'s new apartment."],
            innocentTruths: ["{DL} completed a batterer intervention program and the parties now co-parent through a supervised exchange center."],
            moods: [.divided],
            doctrines: ["mistakeOfFact"]
        ),

        CaseTemplate(
            key: "umpirePunch", category: .violent,
            headlines: ["Called Strike Three", "Little League Brawl"],
            primaryLaw: "aisi", lesserLaw: "simpleAssault", threshold: 4, lesserThreshold: 2,
            specification: "Assaulted {V}, a youth baseball umpire, inflicting serious injury.",
            ageRange: 30...55, hasVictim: true,
            summaries: [
                "At a 12-and-under baseball game in {HOOD}, {D} walked onto the field after a called third strike and punched umpire {V}, 67. {VL} fell and broke a hip.",
                "A parent, {D}, confronted volunteer umpire {V} in the parking lot after a game. One punch broke {VL}'s jaw."
            ],
            prosecutionEvidence: [
                E(.video, 5, "Parents' Videos", "Three parents filmed {DL} walking onto the field and punching the umpire."),
                E(.forensic, 3, "Medical Records", "A hip fracture requiring replacement surgery.")
            ],
            defenseEvidence: [
                E(.document, 2, "Umpire Shoved First", "One video shows {VL} poking {DL} in the chest with a finger first."),
                E(.document, 2, "Remorse", "{DL} paid {VL}'s deductible and wrote a letter of apology.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Volunteer umpire",
                            direct: ["\"I've umpired for thirty years for free. I just wanted to call the game.\""],
                            cross: ["\"Yes, I poked my finger. I said get off my field.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Another parent",
                            direct: ["\"The ump had been jawing at parents all game.\""],
                            cross: ["\"Nobody deserves to get punched, no.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} attacked a 67-year-old volunteer in front of a field full of kids."],
            defenseTheory: ["{DL} lost their temper after being poked in the chest. It's a misdemeanor-sized mistake."],
            aggravating: ["The victim was very old", "Committed in the presence of children"],
            mitigating: ["The defendant made restitution", "The defendant accepted responsibility"],
            victimImpacts: ["{V}: \"I won't umpire again. That's what I lost.\""],
            guiltyTruths: ["{DL} had been banned from two other leagues for confronting officials."],
            innocentTruths: ["The league president later said the umpire had a history of provoking parents."],
            moods: [.wantsConviction],
            doctrines: ["lesserIncluded", "selfDefense"]
        ),

        CaseTemplate(
            key: "landlordArson", category: .property,
            headlines: ["The Eviction and the Fire", "Tenants Asleep Upstairs"],
            primaryLaw: "arson1", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Willfully and maliciously burned an occupied dwelling on {STREET}.",
            ageRange: 25...60, hasVictim: true,
            summaries: [
                "Two days after being evicted from the downstairs unit of a duplex on {STREET}, {D} was seen near the building at 2 a.m. Minutes later the porch was in flames. {V} and two children escaped from the upstairs unit.",
                "A fire broke out at a rooming house in {HOOD} where {D} had been thrown out after a fight with the landlord. Six residents escaped; one was hospitalized for smoke inhalation."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "Accelerant", "Gasoline detected on the porch boards by a lab analysis."),
                E(.video, 3, "Neighbor's Camera", "A figure walking toward the duplex with a container at 1:58 a.m."),
                E(.digital, 3, "Threatening Text", "To the landlord the day of the eviction: \"you'll regret this.\"", .search),
                E(.document, 2, "Gas Can Purchase", "A gas can purchased with {DL}'s debit card that evening.")
            ],
            defenseEvidence: [
                E(.document, 3, "Lawn Mower", "{DL} says the gas was for a lawn mower {DL} used for side work."),
                E(.document, 2, "Other Grudges", "The landlord had evicted three tenants that month.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Upstairs tenant",
                            direct: ["\"I woke up to smoke. I carried my kids down the back stairs through it.\""],
                            cross: ["\"No, I didn't see who set it.\""],
                            weight: 1, lay: true),
                WitnessSeed(name: nil, role: "Fire marshal",
                            direct: ["\"Gasoline poured on the porch and lit. No accidental source.\""],
                            cross: ["\"I can't tell you who poured it.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Former neighbor",
                            direct: ["\"{DL} cut grass all over the neighborhood. Always had gas cans in the car.\""],
                            cross: ["\"I wasn't there that night.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} wanted revenge on a landlord and didn't care who was asleep upstairs."],
            defenseTheory: ["A gas can and an angry text aren't proof of arson."],
            aggravating: ["The defendant knowingly created a great risk of death to more than one person", "Children were in the dwelling"],
            mitigating: ["No prior record"],
            victimImpacts: ["{V}: \"We lost everything. My son still won't sleep without the light on.\""],
            guiltyTruths: ["The gas can, with {DL}'s fingerprints, was found in a storm drain months later."],
            innocentTruths: ["A different evicted tenant, {ALT}, was later convicted of setting fire to another of the landlord's buildings."],
            moods: [.wantsConviction],
            doctrines: ["expertTestimony"]
        ),

        CaseTemplate(
            key: "insiderPayroll", category: .cyber,
            headlines: ["The Payroll Diversion", "Ghost Employees"],
            primaryLaw: "accessingComputers", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Accessed {BIZ}'s payroll system to divert {AMT} to accounts the defendant controlled.",
            ageRange: 25...50, occupations: ["IT administrator", "payroll specialist"], hasVictim: false,
            summaries: [
                "An audit at {BIZ} found three \"ghost employees\" on the payroll, each paid direct deposit for 14 months. The accounts led back to {D}, the company's IT administrator.",
                "Someone changed the direct-deposit details for six employees at {BIZ} just before payday. {AMT} vanished. The changes came from {D}'s admin login."
            ],
            prosecutionEvidence: [
                E(.digital, 4, "System Logs", "The payroll changes were made from {DL}'s admin account and workstation."),
                E(.document, 4, "Bank Accounts", "Prepaid debit accounts opened with {DL}'s address."),
                E(.digital, 2, "Deleted Logs", "An attempt to delete the audit log, from {DL}'s account.")
            ],
            defenseEvidence: [
                E(.digital, 3, "Shared Admin Password", "The admin password was shared with an outside contractor."),
                E(.document, 2, "Phishing Email", "A phishing email in {DL}'s inbox two weeks earlier that may have captured the password.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Forensic IT examiner",
                            direct: ["\"The changes came from {DL}'s machine, during {DL}'s working hours.\""],
                            cross: ["\"A compromised account could produce the same logs.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Cybersecurity consultant",
                            direct: ["\"Remote access malware can make an attacker look exactly like the logged-in user.\""],
                            cross: ["\"I found no malware on the workstation.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["{D} had the keys to the system and used them to pay {DL}self."],
            defenseTheory: ["Shared passwords and a phishing attack. The logs show the account, not the person."],
            aggravating: ["The defendant took advantage of a position of trust"],
            mitigating: ["No prior record"],
            guiltyTruths: ["One of the prepaid cards was later used to buy a gaming PC shipped to {DL}'s mother."],
            innocentTruths: ["The outside contractor, {ALT}, was indicted for the same scheme at three other companies."],
            moods: [.indifferent],
            doctrines: ["expertTestimony"],
            extras: ["BIZ": ["Coastal Plains Logistics", "Hollis Memorial Gardens", "the Port Hollis Marina"],
                     "AMT": ["$61,000", "$23,500", "$112,000"]]
        ),

        CaseTemplate(
            key: "carjacking", category: .robbery,
            headlines: ["Drive or Else", "The Back Seat"],
            primaryLaw: "kidnapping2", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Unlawfully restrained and removed {V} for the purpose of facilitating a felony, releasing {VL} in a safe place.",
            secondary: [SecondaryCharge(lawID: "commonLawRobbery", specification: "Took {V}'s vehicle by putting {VL} in fear.", chance: 0.7, threshold: 0)],
            ageRange: 18...32, hasVictim: true,
            summaries: [
                "{V} was getting into the car outside a laundromat when someone got in the back seat and said, \"Drive.\" Twenty minutes later, {VL} was ordered out on a dirt road. The car was found burned. {D}'s fingerprints were on the rear door.",
                "At a gas pump in {HOOD}, {D} allegedly forced {V} into the passenger seat and drove off with {VL} for nine miles before letting {VL} out at a church."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "Fingerprints", "{DL}'s prints on the rear passenger door handle."),
                E(.document, 3, "Photo Lineup", "{V} picked {DL} from a sequential lineup with \"high confidence.\""),
                E(.digital, 3, "Phone Location", "{DL}'s phone moved along the same route as the car.", .search)
            ],
            defenseEvidence: [
                E(.document, 3, "Prior Ride", "{DL} says {DL} got a paid ride from {V} a week earlier, explaining the prints."),
                E(.document, 2, "Lineup Concerns", "The lineup administrator knew who the suspect was.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Victim",
                            direct: ["\"I could feel something pressed against the back of my seat. I thought I'd die on that dirt road.\""],
                            cross: ["\"I never saw a weapon.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Rideshare acquaintance",
                            direct: ["\"{VL} gives people rides for cash. {DL} used them before.\""],
                            cross: ["\"I wasn't there that week.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} took a person, not just a car, and that's kidnapping."],
            defenseTheory: ["{DL}'s prints are there because {DL} paid {VL} for rides before."],
            aggravating: ["The victim was held for an extended time"],
            mitigating: ["The victim was released unharmed in a safe place", "Youth"],
            victimImpacts: ["{V}: \"I sold the car they gave back to me. I take the bus now.\""],
            guiltyTruths: ["The phone later yielded a photo, taken from the back seat, of {VL} driving."],
            innocentTruths: ["Another man, {ALT}, was caught committing a nearly identical carjacking two weeks later."],
            moods: [.wantsConviction],
            doctrines: ["searchSeizure", "expertTestimony"]
        ),

        CaseTemplate(
            key: "onePunch", category: .violent,
            headlines: ["One Punch on Canal Street", "The Curb"],
            primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 4, lesserThreshold: 4,
            specification: "Unlawfully caused the death of {V} by an assault.",
            ageRange: 19...35, hasVictim: true,
            summaries: [
                "Outside a downtown Port Hollis bar, {D} threw one punch at {V} after an argument. {VL} fell backward, struck the curb, and died two days later.",
                "In a parking lot after a high school football game, {D} punched {V} once. {VL}'s head hit the pavement. {VL} never woke up."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Street Camera", "{DL} walking up to {VL} and throwing one punch; {VL} falls straight back."),
                E(.forensic, 3, "Autopsy", "Death from blunt force head injury consistent with striking the curb."),
                E(.statement, 2, "911 Call", "{DL}: \"Somebody help, they're not moving, I didn't mean it.\"", .statement)
            ],
            defenseEvidence: [
                E(.video, 3, "Victim Advanced", "The same video, slowed down, shows {VL} stepping toward {DL} with a fist raised."),
                E(.document, 2, "Aid Rendered", "{DL} stayed, called 911, and held {VL}'s head until EMS arrived.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Bystander",
                            direct: ["\"It was over in a second. One swing, and then the sound.\""],
                            cross: ["\"They'd both been yelling. I didn't see who stepped up first.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "EMT who responded",
                            direct: ["\"{DL} was cradling {VL}'s head and sobbing. Wouldn't let go until we got there.\""],
                            cross: ["\"I didn't see the punch.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} chose to throw a punch. The law holds people responsible for the consequences of an unlawful assault."],
            defenseTheory: ["{DL} reacted to a raised fist. No one throws a single punch expecting someone to die."],
            aggravating: ["The victim died"],
            mitigating: ["The defendant called 911 and rendered aid", "No prior record", "Deep remorse"],
            victimImpacts: ["{VL}'s mother: \"I forgive you. I don't know how, but I do. I need to.\"", "{VL}'s brother: \"One punch. That's all it took to end my whole family.\""],
            guiltyTruths: ["A friend of {DL}'s later testified in a civil suit that {DL} had said, before the fight, \"I'm going to knock that guy out.\""],
            innocentTruths: ["A second video showed {VL} swinging first, and {DL}'s punch coming as {DL} ducked."],
            moods: [.divided, .sympathetic],
            doctrines: ["selfDefense"]
        ),

        CaseTemplate(
            key: "pedestrianHitRun", category: .traffic,
            headlines: ["The Crosswalk on Fifth", "Came Forward the Next Day"],
            primaryLaw: "hitAndRun", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Willfully failed to stop and remain at the scene of a crash that caused the death of {V}.",
            ageRange: 19...65, hasVictim: true,
            summaries: [
                "{V} was struck in a crosswalk on Fifth Street at night. The driver didn't stop. The next afternoon, {D} walked into the police department with a lawyer and said \"I think I hit something.\"",
                "A cyclist, {V}, was killed on Old Quarry Road by a hit-and-run driver. Paint chips led investigators to {D}'s SUV, which had been at a body shop the next morning."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "Vehicle Damage", "{DL}'s car had a dented hood and a cracked windshield with fibers matching {VL}'s jacket.", .search),
                E(.video, 3, "Traffic Camera", "{DL}'s car passing through the intersection without braking."),
                E(.document, 3, "Body Shop", "{DL} asked a body shop the next morning for a \"cash job.\"")
            ],
            defenseEvidence: [
                E(.document, 3, "Turned Self In", "{DL} came forward voluntarily within 18 hours."),
                E(.document, 2, "Visibility", "The streetlight at that crosswalk had been out for weeks; {VL} wore dark clothing.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{TROOPER}", role: "Crash reconstruction trooper",
                            direct: ["\"The impact was hard enough to crack the windshield. You couldn't not know.\""],
                            cross: ["\"There's no evidence {DL} was speeding or impaired.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s spouse",
                            direct: ["\"{DL} came home shaking and said a deer hit the car.\""],
                            cross: ["\"There's no deer on Fifth Street. I know.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{V} was left in the street to die. {D} went home, then tried to get the car fixed for cash."],
            defenseTheory: ["{DL} panicked, didn't know a person had been hit, and turned themselves in the next day."],
            aggravating: ["The victim died", "The defendant attempted to conceal the vehicle damage"],
            mitigating: ["The defendant voluntarily surrendered", "No prior record"],
            victimImpacts: ["{VL}'s partner: \"An ambulance might have saved {VL} if you'd stopped. You'll never know. Neither will I.\""],
            guiltyTruths: ["Phone records showed {DL} searched \"hit and run penalties NC\" at 11:52 that night."],
            innocentTruths: ["The medical examiner later concluded {VL} died on impact; no aid could have helped."],
            moods: [.wantsConviction],
            doctrines: ["searchSeizure"]
        ),

        CaseTemplate(
            key: "habitualDWI", category: .traffic,
            headlines: ["DWI Number Four", "The Interlock Bypass"],
            primaryLaw: "habitualDWI", lesserLaw: nil, threshold: 8, lesserThreshold: 8,
            specification: "Drove while impaired, having three or more prior impaired-driving convictions within ten years.",
            ageRange: 35...65, forcedPriorOffenses: ["Driving While Impaired", "Driving While Impaired", "Driving While Impaired"],
            hasVictim: false,
            summaries: [
                "A trooper stopped {D}'s pickup for weaving on U.S. 17 at {TIME}. {DL} blew 0.17. It's {DL}'s fourth DWI in eight years.",
                "{D} rear-ended a car at a stoplight in {HOOD}. No one was hurt. {DL} blew 0.21 and had three prior DWIs."
            ],
            prosecutionEvidence: [
                E(.forensic, 5, "Intoximeter Result", "0.17 on the Intox EC/IR II, 40 minutes after the stop."),
                E(.video, 3, "Dashcam", "The truck drifting over the fog line four times."),
                E(.document, 4, "Prior Judgments", "Certified copies of three prior DWI convictions.")
            ],
            defenseEvidence: [
                E(.document, 3, "Stop Basis", "The defense argues weaving within a lane isn't reasonable suspicion."),
                E(.document, 2, "Treatment", "{DL} has been sober 7 months in a residential program since the arrest.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{TROOPER}", role: "Arresting trooper",
                            direct: ["\"Strong odor of alcohol, glassy eyes, six of six clues on HGN.\""],
                            cross: ["\"The truck didn't cross the center line.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Treatment program director",
                            direct: ["\"{DL} is one of the most committed people in our program.\""],
                            cross: ["\"Most people with four DWIs have tried treatment before. So has {DL}.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["Four times now. The next one might kill somebody."],
            defenseTheory: ["{DL} is sick and finally getting help. Prison interrupts that."],
            aggravating: ["The defendant's alcohol concentration was 0.15 or more"],
            mitigating: ["The defendant is participating in a treatment program"],
            guiltyTruths: ["{DL} was arrested again for driving with a revoked license, on the way to a bar, eight months after the case ended."],
            innocentTruths: ["A blood test the defense obtained showed a lower concentration than the breath test, but by then the case was over."],
            moods: [.wantsConviction],
            doctrines: ["searchSeizure", "dispositions"]
        ),

        CaseTemplate(
            key: "romanceScam", category: .whiteCollar,
            headlines: ["The Colonel Who Didn't Exist", "Love and Wire Transfers"],
            primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 4, lesserThreshold: 4,
            specification: "Obtained {AMT} from {V} by falsely representing a romantic relationship and a need for money.",
            ageRange: 25...45, hasVictim: true,
            summaries: [
                "{V}, recently widowed, in {HOOD}, wired {AMT} over eight months to \"Colonel James,\" an online suitor stationed overseas. The money went to an account controlled by {D}, a Port Hollis resident.",
                "{V} met someone online who needed money for customs fees on a gold shipment. Every transfer was picked up by {D}."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Bank Records", "Each transfer landed in {DL}'s account and was withdrawn within a day."),
                E(.digital, 3, "Chat Logs", "Messages from the \"Colonel\" sent from an IP address at {DL}'s apartment.", .search),
                E(.document, 2, "Stock Photos", "The Colonel's profile photos belong to a real Army officer who has no connection to the case.")
            ],
            defenseEvidence: [
                E(.document, 3, "Recruited Mule", "{DL} says an online employer paid {DL} to receive and forward funds."),
                E(.digital, 2, "Shared Wi-Fi", "The apartment's Wi-Fi was open to neighbors.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Victim",
                            direct: ["\"The Colonel knew everything about me. We prayed together on the phone.\""],
                            cross: ["\"I never spoke to anyone named {DL}.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Fraud researcher",
                            direct: ["\"Romance scam rings are usually overseas and use local mules.\""],
                            cross: ["\"Mules often know more than they let on.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["{D} wasn't a middleman. {D} was the Colonel."],
            defenseTheory: ["{DL} was a pawn for people {DL} never met."],
            aggravating: ["The victim was very old", "Victim lost life savings"],
            mitigating: ["The defendant has cooperated with investigators"],
            victimImpacts: ["{V}: \"I lost my money and my pride. I believed someone loved me.\""],
            guiltyTruths: ["A laptop seized later held scripts for 40 different fake suitors."],
            innocentTruths: ["Federal agents took down the overseas ring; its records list {DL} as an unwitting recruit."],
            moods: [.wantsConviction],
            doctrines: ["mistakeOfFact", "victimRights"],
            extras: ["AMT": ["$68,000", "$142,000", "$24,500"]]
        ),

        CaseTemplate(
            key: "witnessIntimidation", category: .robbery,
            headlines: ["Snitches Get Stitches", "The Witness Who Stopped Talking"],
            primaryLaw: "witnessIntimidation", lesserLaw: "communicatingThreats", threshold: 5, lesserThreshold: 3,
            specification: "Attempted by threats to deter {V} from testifying in a pending Hollis County criminal case.",
            ageRange: 19...40, hasVictim: true,
            summaries: [
                "{V} was the State's main witness in a pending assault case. Two weeks before trial, {D}, the defendant's cousin, approached {VL} at a gas station and said, \"You know what happens to people who talk.\"",
                "A photo of {V}'s house with a red X over it was slipped under the door. A doorbell camera shows {D} on the porch."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Gas Station Video", "{DL} leaning close to {VL} at the pump, then walking away. No audio."),
                E(.digital, 3, "Instagram Post", "{DL} posted a screenshot of {VL}'s witness statement with the caption \"rats.\"", .search),
                E(.document, 2, "Witness Recanted", "{VL} told the DA after the encounter that {VL} \"didn't remember\" the original assault.")
            ],
            defenseEvidence: [
                E(.document, 2, "No Audio", "No recording of what was actually said at the gas station."),
                E(.document, 2, "Prior Friendship", "{DL} and {VL} went to high school together and spoke often.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Witness in the other case",
                            direct: ["\"I knew exactly what it meant. I have kids.\""],
                            cross: ["\"No, there were no specific words about hurting me.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Gas station clerk",
                            direct: ["\"Looked like two people talking. Nobody seemed upset.\""],
                            cross: ["\"I couldn't hear anything from inside.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["If witnesses can be scared off, courts stop working."],
            defenseTheory: ["Two old classmates talked at a gas station. The rest is the State reading menace into silence."],
            aggravating: ["The offense was committed to hinder the administration of justice"],
            mitigating: ["Youth"],
            victimImpacts: ["{V}: \"I moved. I changed my number. I'm still looking over my shoulder.\""],
            guiltyTruths: ["A jail phone call recorded the cousin telling {DL}, \"Go see {VL}. Make sure they understand.\""],
            innocentTruths: ["{VL} later admitted the conversation was about a mutual friend's funeral."],
            moods: [.wantsConviction],
            doctrines: ["lesserIncluded"]
        ),

        CaseTemplate(
            key: "statueToppled", category: .publicOrder,
            headlines: ["The Monument on the Courthouse Lawn", "Ropes at Midnight"],
            primaryLaw: "injuryRealProperty", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Willfully and wantonly damaged a monument on the grounds of the {CH}.",
            secondary: [SecondaryCharge(lawID: "riot", specification: "Willfully engaged in a riot on the courthouse grounds.", chance: 0.4, threshold: 0)],
            ageRange: 19...35, hasVictim: false,
            summaries: [
                "After a rally, a group of about thirty people pulled down a 1903 monument on the {CH} lawn with ropes. {D} was identified from news footage holding one of the ropes.",
                "Someone spray-painted and toppled a statue outside the {CH} overnight. {D} was arrested after posting a video of the statue on the ground."
            ],
            prosecutionEvidence: [
                E(.video, 4, "News Footage", "{DL} clearly visible pulling a rope attached to the statue."),
                E(.digital, 3, "Social Media Video", "{DL} posted, \"we did that,\" with video of the fallen statue.", .search),
                E(.document, 2, "Damage Estimate", "Repair and reinstallation estimated at $180,000.")
            ],
            defenseEvidence: [
                E(.document, 2, "Crowd", "Dozens of people pulled ropes; {DL} was one of many."),
                E(.document, 2, "Council Vote", "The county had already voted to remove the monument but hadn't acted.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{OFF}", role: "Officer on scene",
                            direct: ["\"By the time we got through the crowd, it was down.\""],
                            cross: ["\"No one was injured, no.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "County commissioner",
                            direct: ["\"We voted to take it down last year. We just never did it.\""],
                            cross: ["\"That doesn't authorize anyone to do it themselves.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["Whatever anyone thinks of the monument, the law doesn't let a crowd decide."],
            defenseTheory: ["{DL} was one of thirty people, and the county itself had voted to remove it."],
            aggravating: ["The offense involved damage causing great monetary loss"],
            mitigating: ["No one was injured", "No prior record"],
            guiltyTruths: ["Organizers later named {DL} as the person who brought the ropes."],
            innocentTruths: ["Footage released later showed {DL} had grabbed the rope only after the statue was already falling."],
            moods: [.divided],
            doctrines: ["lesserIncluded"],
            extras: ["CH": ["Hollis County Courthouse", "old Wexley Town Hall"]]
        )
    ]
}
