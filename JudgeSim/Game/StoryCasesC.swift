import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchC: [CaseTemplate] = [pharmacyRobbery, babysitterInjury, tellerDrawer, cyclistHitAndRun, rentalCarPills]

    // MARK: - 24. The pharmacy and the BB gun

    static let pharmacyRobbery = CaseTemplate(
        key: "story.pharmacyRobbery", category: .robbery,
        headlines: ["Pharmacy Robbed of Painkillers at Gunpoint", "Was It a Real Gun?"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 6, lesserThreshold: 4,
        specification: "Robbed {V}, a pharmacist at {PHARM}, of oxycodone while armed with what appeared to be a handgun.",
        secondary: [
            SecondaryCharge(lawID: "possSchedII", specification: "Possessed oxycodone, a Schedule II controlled substance, taken in the robbery.", chance: 1.0, threshold: 4)
        ],
        ageRange: 27...41, occupations: ["roofer"], forcedPriorOffenses: ["Possession of Schedule II (cocaine)@9"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, a person in a hooded sweatshirt and surgical mask walked up to the pharmacy counter at {PHARM} in {HOOD}, lifted a black pistol from a jacket pocket, and told {V}, the pharmacist on duty, to empty the oxycodone drawer. {V} handed over 340 tablets. Police arrested {D}, a roofer with a pain-pill addiction, a week later after a tip; in {DL}'s truck they found a black CO2-powered BB pistol. {DL} admits the robbery and is pleading for the lesser charge: {DL} says it was a BB gun, not a firearm, and nobody's life was ever in danger."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Pharmacy Video", "Clear footage of the robber lifting a black pistol and pointing it at {V} from four feet away for about eight seconds."),
            E(.physical, 2, "BB Pistol", "A black CO2 BB pistol modeled on a 9mm handgun, orange tip removed, recovered from {DL}'s truck. The CO2 cartridge was full and the magazine loaded with steel BBs.", .search),
            E(.statement, 3, "Confession", "\"I did it. I was dope-sick. It's a BB gun. I'd never hurt anybody.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 2, "Manufacturer Specifications", "The BB pistol fires steel BBs at about 410 feet per second, according to the box."),
            E(.document, 2, "Treatment Records", "{DL} entered a methadone program four days after the robbery, before the arrest, and has been compliant since."),
            E(.physical, 1, "Recovered Pills", "Two hundred ninety of the 340 tablets were recovered from {DL}'s truck.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Pharmacist",
                        direct: ["\"I thought I was going to die over a drawer of pills.\""],
                        cross: ["\"I couldn't tell it wasn't real.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened at the counter?", "\"The person said 'I need you to do exactly what I say,' and then the gun came out of the pocket and pointed right at my chest. I put my hands up. I said take whatever you want.\""),
                            .direct("What did you think the gun was?", "\"A handgun. Black, heavy-looking. I grew up around guns. It looked like my uncle's.\""),
                            .direct("How has this affected you?", "\"I transferred to a store across the county. I still can't stand at a counter with my back to the door.\""),
                            .cross("You had no way of knowing it was a BB gun?", "\"No. And I don't think that matters to how scared I was.\""),
                            .cross("The person never threatened to shoot, never touched you?", "\"No words like that. The gun did the talking.\""),
                            .cross("When you said 'take whatever you want,' the person took only the oxycodone and left?", "\"Just the oxycodone. Walked right past the cash drawer.\"")
                        ]),
            WitnessSeed(name: nil, role: "Firearms examiner, State Crime Laboratory",
                        direct: ["\"At four feet this BB pistol can blind someone or break skin.\""],
                        cross: ["\"It isn't a firearm under the law.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you test?", "\"The BB pistol from {DL}'s truck. I chronographed ten shots: an average of 398 feet per second with steel BBs.\""),
                            .direct("Is that dangerous?", "\"At four feet, a steel BB at that speed can penetrate skin and can cause permanent eye injury. I've seen hospital records of both.\""),
                            .direct("Could it kill?", "\"Death is rare, but there are documented deaths from BB guns, usually from eye or head wounds, especially in children.\""),
                            .cross("It isn't a firearm?", "\"It doesn't use gunpowder, so it's not a firearm.\""),
                            .cross("Death is rare even when someone is hit?", "\"Very rare.\""),
                            .cross("The person never fired it in the store?", "\"Correct, as far as I know.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Addiction medicine physician",
                        direct: ["\"{DL} was in severe opioid withdrawal.\""],
                        cross: ["\"Withdrawal doesn't excuse a robbery.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did {DL} become addicted?", "\"A fall from a roof six years ago, a broken back, eighteen months of prescribed oxycodone, and then the prescription stopped. That's the most common path I see.\""),
                            .direct("What does withdrawal feel like?", "\"Like the worst flu of your life plus panic. People do things they'd never do otherwise.\""),
                            .direct("How is {DL} doing now?", "\"On methadone since four days after the robbery. Every drug screen clean since, and back at work.\""),
                            .cross("Withdrawal doesn't make someone rob a pharmacy at gunpoint, does it?", "\"It doesn't make them. It explains why they might.\""),
                            .cross("{DL} chose to remove the orange tip so the gun looked real.", "\"I don't know anything about that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pointed a realistic pistol at {V}'s chest to rob a pharmacy. A BB pistol that can blind someone at four feet is a dangerous weapon."],
        defenseTheory: ["{DL} committed a robbery, and admits it. But it was a BB gun that was never fired. That's common law robbery, not armed robbery."],
        aggravating: ["The weapon was altered to look like a real firearm"],
        mitigating: ["{DL} entered addiction treatment before arrest", "{DL} confessed and most of the pills were recovered", "The offense was driven by opioid withdrawal following a work injury"],
        victimImpacts: ["{V}: \"I believed I was going to be shot. That's what I'll remember, not what kind of gun it turned out to be.\""],
        allocutions: ["\"I'm ashamed. I scared a person who was just doing their job. I've been clean fourteen months and I'll stay clean.\""],
        guiltyTruths: ["A friend later told police {DL} had said the BB gun was 'good enough to make them think it's real.'"],
        innocentTruths: ["{DL} had told {D.his} sponsor before the arrest that {D.he} had removed the orange tip years earlier for a costume and forgotten it."],
        moods: [.divided], doctrines: ["lesserIncluded"],
        extras: ["TIME": ["7:52 p.m."], "PHARM": ["Hollis Family Pharmacy", "Medicap Drugs", "Riverside Apothecary"]],
        story: StoryExtras(
            timeline: [(0, "7:52 p.m.: robbery at {PHARM}; 340 oxycodone tablets taken."),
                       (4, "{DL} enrolls in a methadone program."),
                       (7, "Anonymous tip; search warrant for {DL}'s truck: BB pistol and 290 tablets recovered. {DL} arrested and confesses."),
                       (40, "Laboratory test-fires the BB pistol.")],
            howIdentified: "An anonymous tip, confirmed by the pharmacy video and the items in {DL}'s truck.",
            notDone: [],
            defendantExam: [
                .direct("Why did you rob the pharmacy?", "\"I'd been out of pills for three days. I couldn't stand up straight. I told myself nobody would get hurt if I didn't have a real gun.\""),
                .direct("Why remove the orange tip?", "\"So it would look real. I'm not going to lie about that.\""),
                .direct("Did you ever intend to fire it?", "\"No. It wasn't even pointed at a person in my mind. I know how that sounds.\""),
                .cross("You pointed it at {V}'s chest.", "\"At the middle of {V.his} chest. I won't pretend otherwise.\""),
                .cross("You have a prior drug conviction.", "\"Possession, nine years ago. Before the injury.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Is a BB gun a dangerous weapon under North Carolina law?\"",
                                  answer: "\"In my opinion, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Calls for a legal conclusion", shouldSustain: true,
                                  explanation: "Whether an instrument is a dangerous weapon for armed robbery is a legal question for the court; the expert can describe its capacity to cause injury, not the legal classification.",
                                  doctrineID: "expertTestimony", weight: 1))
            ],
            prosecutionOpening: "{V} looked down the barrel of what anyone would believe was a handgun. {D} made sure of that by removing the orange tip.",
            defenseOpening: "{DL} robbed the pharmacy and confessed. The only question is whether a BB gun that was never fired makes it armed robbery. It doesn't.",
            prosecutionClosing: "Under our law, a robbery with an instrument that appears to be a firearm and that can cause serious injury is armed robbery.",
            defenseClosing: "Common law robbery fully punishes what {DL} did. Armed robbery requires a real danger to life that wasn't there.",
            victim: VictimFacts(occupation: "Pharmacist")
        )
    )

    // MARK: - 25. The babysitter (abusive head trauma or a short fall?)

    static let babysitterInjury = CaseTemplate(
        key: "story.babysitterInjury", category: .family,
        headlines: ["Babysitter Charged After Infant's Brain Injury", "Shaken Baby or Accidental Fall?"],
        primaryLaw: "felonyChildAbuse", lesserLaw: "childAbuseMisd", threshold: 2, lesserThreshold: 1,
        specification: "Intentionally inflicted serious physical injury on {INFANT}, a seven-month-old, by violent shaking.",
        ageRange: 26...40, occupations: ["in-home child care provider"], hasVictim: false,
        summaries: [
            "{D} ran a small licensed day care from {D.his} home in {HOOD}. On {DATE}, {DL} called 911 at about {TIME} to say seven-month-old {INFANT} had gone limp after falling from a changing table. At the hospital, doctors found bleeding beneath the skull, bleeding in both retinas, and brain swelling, and diagnosed abusive head trauma. {INFANT} survived with lasting developmental delays. {DL} says the baby rolled off the table while {D.he} reached for a diaper, and that the parents had noticed {INFANT} was fussy and vomiting the night before."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Child Abuse Pediatrician's Report", "Subdural hemorrhage, extensive multilayered retinal hemorrhages in both eyes, and brain swelling, which the hospital's child abuse team found \"diagnostic of abusive head trauma\" and inconsistent with a three-foot fall."),
            E(.statement, 2, "Changing Accounts", "{DL} first told dispatch the baby \"just went limp,\" then told the ER the baby fell from the changing table, then told the detective the baby rolled off while {DL} turned around."),
            E(.document, 2, "Timeline", "The parents dropped {INFANT} off at 7:30 a.m., behaving normally according to the day care's own sign-in note: \"happy, ate well.\"")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Defense Neuroradiologist", "Imaging shows a small older collection of fluid that may predate the day of the injury, which could make the infant vulnerable to re-bleeding after a minor fall."),
            E(.document, 2, "Parent's Text the Night Before", "The parent texted a relative at 10 p.m. the night before: \"Baby threw up twice and won't settle, hope it's not a bug.\""),
            E(.document, 2, "Clean Inspection History", "Six years of clean state inspections; parents of eleven other children describe {DL} as gentle and patient.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Child abuse pediatrician",
                        direct: ["\"A short fall doesn't cause these injuries.\""],
                        cross: ["\"There's ongoing debate in the field.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What is your specialty?", "\"I'm board-certified in child abuse pediatrics and lead the child protection team at the regional children's hospital.\""),
                            .direct("What injuries did {INFANT} have?", "\"Bleeding beneath the covering of the brain on both sides, retinal hemorrhages in both eyes too numerous to count and extending to the edges, and swelling of the brain.\""),
                            .direct("Can a fall from a changing table cause that?", "\"Short falls can cause a skull fracture or a small bleed at the point of impact. They don't cause this combination, especially the retinal hemorrhages in both eyes, which come from violent acceleration and deceleration.\""),
                            .direct("When did the injury happen?", "\"An infant with injuries this severe would be symptomatic almost immediately, unable to feed or act normally. A happy, feeding baby at 7:30 makes the injury most likely after drop-off.\""),
                            .cross("There's a debate in medicine about whether this triad always means shaking?", "\"There's a vocal minority. The great majority of the field accepts this diagnosis.\""),
                            .cross("You noted an older collection of fluid on the imaging?", "\"A small one. I don't believe it explains the acute findings.\""),
                            .cross("Vomiting the night before can be a sign of an earlier brain injury?", "\"It can also be a stomach bug, which is far more common.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective, crimes against children",
                        direct: ["\"{DL}'s story changed three times.\""],
                        cross: ["\"{DL} called 911 right away.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did {DL} tell you?", "\"That {INFANT} rolled off the changing table while {DL} turned to get a diaper, hit the floor, cried, and then went limp a few minutes later.\""),
                            .direct("Why does the sequence of accounts matter?", "\"Dispatch first, then the ER, then me. 'Went limp,' then 'fell,' then 'rolled while I turned.' Each version got more detailed. That concerned me.\""),
                            .cross("{DL} called 911 within a minute?", "\"Within about two minutes, yes.\""),
                            .cross("People in a panic often give fuller accounts as they calm down?", "\"That happens.\""),
                            .cross("You never interviewed the parents about the night before?", "\"I asked about the morning. Not in detail about the night before.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pediatric neuroradiologist",
                        direct: ["\"An older bleed can re-bleed after a minor fall.\""],
                        cross: ["\"I can't rule out abuse.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the scans show?", "\"Alongside the fresh blood, there's a thin collection with a different density, consistent with blood that's days to weeks old. That's an older injury.\""),
                            .direct("Why does that matter?", "\"An infant with an existing collection can re-bleed dramatically from a minor impact. The fresh bleeding could come from a short fall onto a hard floor.\""),
                            .direct("And the retinal hemorrhages?", "\"Severe retinal hemorrhages are more strongly associated with abuse, but they're also reported with raised pressure in the head from other causes.\""),
                            .cross("You can't rule out shaking?", "\"No. I can say there's a reasonable alternative.\""),
                            .cross("You testify mostly for the defense in these cases?", "\"Yes, because the hospitals rarely ask for a second opinion.\"")
                        ])
        ],
        prosecutionTheory: ["{INFANT} was dropped off healthy and left with injuries only violent shaking causes. {D}'s story changed because the truth was worse."],
        defenseTheory: ["An older bleed, a sick baby the night before, and a short fall. The science of 'shaken baby' is not as certain as the State says, and {DL} has six spotless years."],
        aggravating: ["The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record or licensing complaints", "{DL} immediately called 911"],
        victimImpacts: ["{INFANT}'s parent: \"Our baby will be one soon and still can't sit up. We trusted you.\""],
        allocutions: ["\"I would never hurt a child. I've cared for dozens. I'll think about that changing table for the rest of my life.\""],
        guiltyTruths: ["A neighbor later said they heard {DL} yelling \"stop crying\" and a thud through the window that morning."],
        innocentTruths: ["Genetic testing a year later found {INFANT} had a rare clotting disorder that makes the brain bleed easily."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["TIME": ["11:18 a.m."], "INFANT": ["Mila", "Jonah", "Ezra", "Ruby"]],
        story: StoryExtras(
            timeline: [(-1, "10:00 p.m.: parent texts that the baby vomited twice and won't settle."),
                       (0, "7:30 a.m.: drop-off. 11:18 a.m.: 911 call. 11:52 a.m.: CT scan shows bleeding."),
                       (2, "Child abuse team diagnosis; {DET} interviews {DL}."),
                       (60, "{DL} charged with felony child abuse.")],
            howIdentified: "{DL} was the only adult caring for {INFANT} when symptoms appeared.",
            notDone: ["No genetic or clotting tests were ordered.", "The parents weren't questioned in detail about the night before."],
            defendantExam: [
                .direct("What happened?", "\"I had {INFANT} on the changing table and turned to grab a diaper from the shelf. One second. I heard the thud. The baby screamed, then got quiet, then went floppy. I called 911.\""),
                .direct("Why did your story seem to change?", "\"It didn't change. I was screaming at the dispatcher. I said 'limp' because that's what scared me. Later I could say the whole thing.\""),
                .direct("Did you shake {INFANT}?", "\"No. I picked the baby up and patted the back when the breathing got strange. That's all.\""),
                .cross("You left a seven-month-old alone on a changing table.", "\"For a second. I'll regret it forever. It's a mistake, not abuse.\""),
                .cross("You were caring for four other children that morning.", "\"Three others. All napping.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Doctor, in your opinion was this child abused?\"",
                                  answer: "\"Yes. This was abuse.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper opinion", shouldSustain: false,
                                  explanation: "A qualified medical expert may testify that injuries are consistent with or diagnostic of abusive trauma, which is a medical diagnosis. The expert may not say who did it.",
                                  doctrineID: "expertTestimony", weight: 1))
            ],
            prosecutionOpening: "A happy baby at 7:30. A brain bleed and blood in both eyes by 11:18. Injuries a short fall doesn't cause.",
            defenseOpening: "An older bleed on the scans, a sick baby the night before, and a short fall. The State's certainty isn't shared by the science.",
            prosecutionClosing: "The medical evidence points to violence after drop-off, while the baby was in {DL}'s hands alone.",
            defenseClosing: "When qualified experts disagree about the cause, that's reasonable doubt.",
            residence: "Runs a licensed home day care out of a house in {HOOD}."
        )
    )

    // MARK: - 26. The teller drawer

    static let tellerDrawer = CaseTemplate(
        key: "story.tellerDrawer", category: .whiteCollar,
        headlines: ["Bank Teller Charged With $38,000 Theft", "A Shared Drawer and a Missing Bag"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 3, lesserThreshold: 1,
        specification: "As an employee of {BANK}, embezzled $38,000 entrusted to {DL}.",
        secondary: [
        ],
        ageRange: 22...36, occupations: ["bank teller"], hasVictim: false,
        summaries: [
            "On {DATE}, a cash shipment in four sealed bags arrived at the {HOOD} branch of {BANK}. {D}, a teller, signed for it and placed it in the vault. At the end-of-day count, one bag, holding $38,000, was gone. Only {DL} and the assistant manager had vault access that afternoon, and the vault camera had been offline for nine days awaiting repair. Three weeks later, {DL} paid off a $14,000 car loan in cash. {DL} says the money came from a relative's settlement, and that the assistant manager had gambling debts."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Vault Access Log", "Badge records show {DL} entered the vault four times that afternoon; the assistant manager entered once, at 9:15 a.m., before the shipment arrived."),
            E(.document, 3, "Cash Loan Payoff", "Twenty-two days later, {DL} paid off a $14,200 car loan at a credit union with cash in $100 bills."),
            E(.statement, 2, "Interview", "{DL} first said {D.he} \"didn't remember\" how many times {DL} entered the vault, then said twice.", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Override Codes", "The vault door can be opened with a manager override code that doesn't create a badge record. The assistant manager knew the code."),
            E(.document, 2, "Settlement Papers", "A wrongful death settlement paid to {DL}'s grandparent eight months earlier, and a $15,000 check from the grandparent to {D.him} a month before the payoff."),
            E(.document, 2, "Manager's Debts", "The assistant manager had $40,000 in past-due online gambling debts and resigned two weeks after the theft.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{BANK} branch manager",
                        direct: ["\"Only {DL} handled that shipment.\""],
                        cross: ["\"The override code doesn't leave a badge record.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How does a cash shipment work?", "\"An armored carrier delivers sealed bags. A teller signs for them, verifies the seals, and places them in the vault cash cart. We count at close.\""),
                            .direct("Who signed for this one?", "\"{DL}. At 1:40 p.m. Four bags, all seals intact.\""),
                            .direct("What happened at close?", "\"Three bags. The missing one was $38,000. We searched every drawer, every trash can, the carrier's truck. Nothing.\""),
                            .direct("Why was the vault camera down?", "\"A failed hard drive. I'd put in a ticket. The vendor was backlogged. I should have pushed harder.\""),
                            .cross("The vault can be opened with a manager override code that leaves no badge record?", "\"Yes. For emergencies.\""),
                            .cross("Your assistant manager knew that code?", "\"All managers do.\""),
                            .cross("The assistant manager resigned two weeks later?", "\"For personal reasons, the letter said.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"{DL} paid off a loan in hundreds three weeks later.\""],
                        cross: ["\"The grandparent's check was real.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did your investigation find?", "\"{DL}'s badge in the vault four times after the shipment arrived, nobody else's after 9:15, and a $14,200 cash loan payoff twenty-two days later.\""),
                            .direct("What did {DL} say about the cash?", "\"That it was from a grandparent's settlement. The check was deposited, but {DL} withdrew it in cash and kept it at home for weeks before paying off the loan. That's unusual.\""),
                            .cross("The grandparent's $15,000 check is real and cleared?", "\"It's real, and it cleared.\""),
                            .cross("You never examined the override code logs?", "\"The system doesn't log override codes by user.\""),
                            .cross("You never interviewed the assistant manager about the gambling debts?", "\"We interviewed the assistant manager once. Not about debts.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s grandparent",
                        direct: ["\"I gave {DL} fifteen thousand to get out of that car loan.\""],
                        cross: ["\"I didn't know {DL} took it out in cash.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why did you give {DL} money?", "\"My son died in a crash at the paper mill. The company settled. {DL} was paying 18 percent on a car. I told {DL} pay it off, I don't want to see you broke.\""),
                            .direct("Did {DL} ever ask you for money?", "\"Never once. I had to make {DL} take it.\""),
                            .cross("You didn't know {DL} withdrew it in cash and kept it at home?", "\"No. Young people don't trust banks, I guess. Even ones who work at them.\""),
                            .cross("You love your grandchild?", "\"More than anything. I'd still tell you the truth.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was the only one with badge access after the shipment, and three weeks later paid off a loan in hundred-dollar bills."],
        defenseTheory: ["A broken camera, a manager override code that leaves no trace, a manager with gambling debts who quit, and a real check from a grandparent. That's reasonable doubt."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        allocutions: ["\"I didn't take that money. I've worked at that bank since I was nineteen.\""],
        guiltyTruths: ["The bank's armored carrier later found a torn shipment seal in a storm drain behind {DL}'s apartment."],
        innocentTruths: ["The assistant manager was later charged with taking cash from another branch using the override code."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        extras: ["BANK": ["Piedmont Federal Bank", "Carolina Trust", "Hollis Savings Bank"]],
        story: StoryExtras(
            timeline: [(-9, "Vault camera fails; repair ticket opened."),
                       (0, "1:40 p.m.: {DL} signs for four bags. 5:30 p.m.: one bag missing at close."),
                       (14, "Assistant manager resigns."),
                       (22, "{DL} pays off car loan with $14,200 cash."),
                       (35, "{DL} charged with embezzlement.")],
            howIdentified: "Vault badge records after the shipment arrived showed only {DL}.",
            notDone: ["The assistant manager's finances were never examined.", "The override code's use was never investigated."],
            defendantExam: [
                .direct("Why were you in the vault four times?", "\"To restock my drawer twice, to take the shipment in, and to help a customer with a coin order. That's a normal afternoon.\""),
                .direct("Why keep the grandparent's money in cash?", "\"I'd seen how fast the overdraft fees ate me alive. I wanted it where I could see it until I was ready to pay the loan.\""),
                .cross("You told the detective you went in twice.", "\"I guessed. I didn't count.\""),
                .cross("Hundred-dollar bills. The shipment was hundreds.", "\"That's what the credit union gave me when I withdrew. Banks give hundreds.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Isn't the real thief the assistant manager?\"",
                                  answer: "\"I have no evidence of that.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative", shouldSustain: true,
                                  explanation: "The question argues the defense theory to the witness rather than asking for facts.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Four trips into the vault, no one else, and a car loan paid off in hundreds three weeks later.",
            defenseOpening: "No camera, a code that leaves no trace, and a manager drowning in gambling debt. {DL} was the convenient answer.",
            prosecutionClosing: "Access, opportunity, and cash.",
            defenseClosing: "Opportunity without proof is suspicion.",
            employer: "{BANK}"
        )
    )

    // MARK: - 27. The cyclist on the county road

    static let cyclistHitAndRun = CaseTemplate(
        key: "story.cyclistHitAndRun", category: .traffic,
        headlines: ["Cyclist Killed; Driver Says It Looked Like a Deer", "Hit-and-Run on Rock Quarry Road"],
        primaryLaw: "hitAndRun", lesserLaw: nil, threshold: 2, lesserThreshold: 1,
        specification: "Knowing or having reason to know that the vehicle was involved in a crash causing death, failed to stop and remain at the scene.",
        ageRange: 40...62, occupations: ["dental hygienist"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {V}, 29, was riding home on Rock Quarry Road outside {HOOD} when a car struck the bike from behind. {VL} died in the ditch. The driver didn't stop. Two days later, a body shop called police about a silver sedan with a shattered windshield brought in by {D}. {DL} admits driving that road that night and says {D.he} heard a bang, saw nothing in the mirror in the dark and rain, assumed it was a deer, and drove home. The question is whether {DL} knew, or had reason to know, a person was hit."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Windshield Damage", "A spiderweb fracture on the passenger side of the windshield, about twelve inches across, with fabric fibers matching {VL}'s jacket embedded in the glass."),
            E(.statement, 2, "Body Shop", "{DL} brought the car to a body shop forty miles away, not the one {D.he} normally used, and asked how fast it could be fixed."),
            E(.forensic, 2, "Bike Reflectors and Light", "{VL}'s bike had a rear blinking light and reflectors; the light was found switched on in the ditch.")
        ],
        defenseEvidence: [
            E(.document, 3, "Weather and Lighting", "Heavy rain that night, no streetlights on that stretch, and a 55 mph limit."),
            E(.document, 2, "Deer Strikes", "Rock Quarry Road had 14 reported deer collisions in the past two years, the most in the county."),
            E(.document, 1, "Phone Records", "{DL}'s phone shows no calls or texts after 10 p.m. that night; {DL} went to bed at 10:40, according to a smart-home log.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{TROOPER}", role: "Highway Patrol crash investigator",
                        direct: ["\"A person's body hitting the windshield is unmistakable.\""],
                        cross: ["\"Deer also hit windshields.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What happened, as you reconstruct it?", "\"The car struck the bike's rear wheel, and {VL} was thrown onto the hood and into the windshield, passenger side, then off into the ditch.\""),
                            .direct("Would a driver know they'd hit a person?", "\"In my experience, a body on the hood and against the windshield is impossible to miss. You'd see the jacket, an arm, a shape, right in front of you, even in rain.\""),
                            .direct("What about the bike light?", "\"It was on and blinking when we found it. A driver paying attention would have seen it for several hundred feet.\""),
                            .cross("Deer strikes routinely shatter windshields?", "\"They do, when the deer goes over the hood.\""),
                            .cross("In heavy rain at night, at 55, a driver could see the impact as a gray shape for a fraction of a second?", "\"A fraction of a second, yes. But then you stop and look.\""),
                            .cross("The law requires knowledge or reason to know, not certainty?", "\"That's my understanding.\"")
                        ]),
            WitnessSeed(name: nil, role: "Body shop owner",
                        direct: ["\"{DL} wanted it fixed fast and quiet.\""],
                        cross: ["\"{DL} said it was a deer.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened when {DL} came in?", "\"Silver sedan, windshield smashed on the passenger side, a dent in the hood. {DL} asked how fast I could do it and if I needed to file with insurance.\""),
                            .direct("Why did you call the police?", "\"I'd seen the news about the cyclist. There were threads of dark fabric in the glass. Deer don't wear jackets.\""),
                            .cross("{DL} told you it was a deer?", "\"Yes. Right away.\""),
                            .cross("{DL} gave you {D.his} real name and phone number?", "\"Real name, real number.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Human factors expert",
                        direct: ["\"In those conditions a driver can genuinely misperceive what was hit.\""],
                        cross: ["\"A reasonable driver would stop and look.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is human factors?", "\"The study of how people perceive and react. I study driver perception at night.\""),
                            .direct("Could {DL} have believed it was a deer?", "\"Yes. Rain, darkness, oncoming glare, and a sudden impact. The brain fills in with what's most expected on that road: a deer. Studies show drivers routinely misidentify what they've struck at night.\""),
                            .cross("A reasonable driver who hits something that shatters the windshield would stop and look?", "\"Many would. Many are too frightened to stop on a dark road.\""),
                            .cross("You're paid by the defense?", "\"Yes, at my usual rate.\"")
                        ])
        ],
        prosecutionTheory: ["A body hit {D}'s windshield. {DL} drove home, went to bed, and took the car to a body shop forty miles away."],
        defenseTheory: ["A bang in the rain on the county's worst deer road. {DL} truly believed it was a deer. The law punishes knowing flight, not a terrible mistake."],
        aggravating: ["{DL} sought to conceal the damage"],
        mitigating: ["No prior criminal or driving record", "{DL} gave the body shop {D.his} real name"],
        victimImpacts: ["{VL}'s partner: \"{VL} lay in that ditch alive, maybe for a while. Somebody could have called.\""],
        allocutions: ["\"If I'd known it was a person, I'd have stopped. I didn't know. I'll never forgive myself for not looking.\""],
        guiltyTruths: ["A dashcam in a passing truck later showed {DL}'s brake lights coming on and the car slowing for several seconds before driving away."],
        innocentTruths: ["A deer carcass was found by a road crew a quarter mile further that week, with silver paint transfer on its hide."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["TIME": ["9:47 p.m."]],
        story: StoryExtras(
            timeline: [(0, "9:47 p.m.: cyclist struck on Rock Quarry Road. 10:12 p.m.: passing driver finds {VL} and calls 911."),
                       (2, "Body shop owner calls police about {DL}'s car."),
                       (3, "{DL} interviewed; admits driving the road and says it was a deer."),
                       (30, "Laboratory matches fibers in the windshield to {VL}'s jacket.")],
            howIdentified: "A body shop owner reported {DL}'s damaged car.",
            notDone: ["No search for a deer carcass along the road."],
            defendantExam: [
                .direct("What happened on Rock Quarry Road?", "\"Rain was coming down hard. There was a bang, the windshield cracked, something gray. I thought, deer, again. I've hit two on that road.\""),
                .direct("Why didn't you stop?", "\"It was pitch dark and pouring and I was alone. I was scared. I slowed down, looked in the mirror, saw nothing, and went home.\""),
                .direct("Why a body shop forty miles away?", "\"My usual shop was booked three weeks out. I found that one online with a same-week opening.\""),
                .cross("You saw a blinking red light ahead of you.", "\"I don't remember any light. I've thought about it every day.\""),
                .cross("A windshield shattered and you went to bed.", "\"I went to bed thinking I'd hit a deer.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Do you believe {DL} knew it was a person?\"",
                                  answer: "\"Anyone would know.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation", shouldSustain: true,
                                  explanation: "The trooper can describe what a driver could have seen, but not testify to what {DL} actually knew.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A blinking light, a body on the windshield, and a drive home. {D} had every reason to know.",
            defenseOpening: "A bang in the dark and rain on a road known for deer. {DL} made a terrible mistake, not a knowing choice.",
            prosecutionClosing: "Reason to know is enough. A shattered windshield is reason to know.",
            defenseClosing: "Reason to know a person was hit isn't proven when a reasonable driver could believe it was a deer.",
            victimDied: true,
            scene: "Rock Quarry Road outside {CITY}"
        )
    )

    // MARK: - 28. The rental car

    static let rentalCarPills = CaseTemplate(
        key: "story.rentalCarPills", category: .drugs,
        headlines: ["Fentanyl Pills Found in Rental Car on I-40", "Driver Says Passenger's Bag"],
        primaryLaw: "traffickingOpioid28", lesserLaw: "possSchedII", threshold: 2, lesserThreshold: 1,
        specification: "Trafficked in opioids by possessing 28 grams or more of fentanyl pills.",
        secondary: [
            SecondaryCharge(lawID: "traffickingOpioid28", specification: "Trafficked in opioids by transporting 28 grams or more of fentanyl pills on I-40.", chance: 1.0, threshold: 2),
            SecondaryCharge(lawID: "pwisd", specification: "Possessed fentanyl pills with intent to sell or deliver.", chance: 1.0, threshold: 1)
        ],
        ageRange: 22...35, occupations: ["warehouse supervisor"], hasVictim: false,
        summaries: [
            "At about {TIME} on {DATE}, a trooper stopped a rental SUV for following too closely on I-40 near {HOOD}. {D} was driving; {ALT} was the passenger. A drug dog alerted, and in a duffel bag behind the passenger seat troopers found 1,100 blue pills, 121 grams, later confirmed as fentanyl. The SUV was rented in {DL}'s name. {DL} says {ALT} asked for a ride to Charlotte and brought the bag. {ALT} told the trooper the bag was {DL}'s and has since disappeared."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Pills and Duffel", "1,100 pressed blue pills stamped like prescription oxycodone, 121 grams, in a black duffel behind the passenger seat. A receipt in the bag's side pocket was from a gas station near {DL}'s apartment.", .search),
            E(.document, 2, "Rental Agreement", "The SUV was rented in {DL}'s name the day before for a one-way trip to Charlotte, paid with a prepaid card."),
            E(.statement, 2, "Roadside Statements", "{DL} said they were going to Charlotte \"to visit family\"; {ALT} said \"to a concert.\" Neither could name the family or the concert.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Fingerprints", "{ALT}'s fingerprints are on the pill bags; {DL}'s are not on the bags or the duffel."),
            E(.document, 2, "Passenger's Record", "{ALT} has two prior trafficking convictions and failed to appear after release."),
            E(.document, 2, "Defendant's Job", "{DL} has worked at the same warehouse for five years, with a promotion last year.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{TROOPER}", role: "Highway Patrol trooper",
                        direct: ["\"Both of them were nervous, and their stories didn't match.\""],
                        cross: ["\"{ALT} said the bag was {DL}'s, then ran.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you stop the SUV?", "\"Following a tractor-trailer at about one car length at 70 miles an hour.\""),
                            .direct("What did you notice?", "\"A one-way rental, two phones on the console, the driver's hands shaking, the passenger staring straight ahead. Their stories about the trip didn't match.\""),
                            .direct("What did you find?", "\"After the dog alerted, a black duffel behind the passenger seat with eleven bags of blue pills, about a hundred each.\""),
                            .direct("What did each say?", "\"{DL} said, 'I don't know anything about that bag.' {ALT} said, 'That's {DL}'s, I'm just riding.'\""),
                            .cross("The duffel was directly behind the passenger seat, within the passenger's reach?", "\"Right behind the seat. An arm's length from the passenger, if that.\""),
                            .cross("{ALT}'s prints are on the pill bags and {DL}'s aren't?", "\"That's what the lab reported.\""),
                            .cross("{ALT} was released and never came back to court?", "\"Released, and that's the last anyone saw of {ALT}.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic chemist, State Crime Laboratory",
                        direct: ["\"They're fentanyl, 121 grams.\""],
                        cross: ["\"I don't know who owned them.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What were the pills?", "\"Counterfeit oxycodone tablets containing fentanyl. Total weight 121 grams. Each pill is a potentially lethal dose for someone without tolerance.\""),
                            .cross("You can't say who owned them?", "\"Ownership isn't something chemistry can tell you.\""),
                            .cross("The receipt in the bag came from a store that's a mile from many apartments?", "\"I wouldn't know.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s supervisor",
                        direct: ["\"{DL} is the most reliable person I have.\""],
                        cross: ["\"I don't know what {DL} does on weekends.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How long has {DL} worked for you?", "\"Five years. Promoted to shift supervisor last spring. Never missed a shift, never failed a drug test, and we test randomly.\""),
                            .direct("Did {DL} take time off that week?", "\"Requested a Friday off two weeks earlier for a family trip.\""),
                            .cross("You don't know who {DL} spends time with outside work?", "\"I see {D.him} eight hours a day. What {D.he} does after that is {D.his} business.\"")
                        ])
        ],
        prosecutionTheory: ["{D} rented the car, drove it, and lied about the trip. The pills were within reach of both people in the SUV, and the State only has to prove knowing possession."],
        defenseTheory: ["The bag belonged to {ALT}, whose prints are on the pills, who has trafficked before, and who blamed {DL} and fled. Renting a car isn't trafficking."],
        aggravating: ["The quantity of fentanyl posed a risk of mass overdose"],
        mitigating: ["No prior criminal record", "Steady five-year employment"],
        allocutions: ["\"I gave someone I thought was a friend a ride. I didn't know what was in that bag.\""],
        guiltyTruths: ["Messages recovered later showed {DL} arranging a 'pickup' in Charlotte for the same day."],
        innocentTruths: ["{ALT} was arrested a year later in another state and admitted the pills were {ALT.hers}."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        extras: ["TIME": ["2:14 p.m."]],
        story: StoryExtras(
            timeline: [(-1, "{DL} rents an SUV one-way to Charlotte with a prepaid card."),
                       (0, "2:14 p.m.: traffic stop on I-40; K-9 alert; 1,100 pills found. Both occupants arrested."),
                       (9, "{ALT} released on bond; later fails to appear."),
                       (52, "Laboratory confirms 121 grams of fentanyl; latent prints match {ALT}.")],
            howIdentified: "{DL} was driving the rental SUV, rented in {D.his} name.",
            notDone: ["{DL}'s and {ALT}'s phones were never searched."],
            defendantExam: [
                .direct("Why were you driving to Charlotte?", "\"My cousin's kid's birthday on Saturday. {ALT} heard I was going and asked for a ride. We'd known each other since high school.\""),
                .direct("Why a prepaid card?", "\"My credit card was maxed. I used the prepaid one I use for gas.\""),
                .direct("Whose bag was it?", "\"{ALT}'s. {ALT} put it behind the seat. I never touched it.\""),
                .cross("You couldn't name the cousin at the roadside.", "\"I was panicking with a dog circling the car. I named them later.\""),
                .cross("The receipt in the bag came from a store near your apartment.", "\"{ALT} stayed at my place the night before.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"What did {ALT} tell you about the bag?\"",
                                  answer: "\"That it was {DL}'s.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay and confrontation", shouldSustain: true,
                                  explanation: "{ALT} isn't testifying; the accusation is offered for its truth and {DL} can't cross-examine its maker.",
                                  doctrineID: "hearsay", weight: 2))
            ],
            prosecutionOpening: "A rental in {D}'s name, a one-way trip, a story that didn't match, and enough fentanyl to kill a thousand people.",
            defenseOpening: "{ALT}'s bag, {ALT.his} fingerprints, {ALT.his} record, and {ALT.his} disappearance. {DL} gave a ride.",
            prosecutionClosing: "Knowing possession can be shared. {DL} controlled that car.",
            defenseClosing: "Proximity isn't knowledge.",
            residence: "Rents an apartment in {HOOD}.",
            yearsAtJob: 5,
            scene: "I-40 near {CITY}"
        )
    )
}
