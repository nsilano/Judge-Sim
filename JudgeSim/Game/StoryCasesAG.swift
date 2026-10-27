import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAG: [CaseTemplate] = [softballBat, farmGateShots, lockoutBreakIn, securityGuardShot, parkingDeckRobbery]

    // MARK: - Field 2 (a rec-league argument that ended with a bat)

    static let softballBat = CaseTemplate(
        key: "story.softballBat", category: .violent,
        headlines: ["Rec-League Softball Fight Ends With Player Hospitalized", "Player Charged After Bat Swing Breaks Opponent's Eye Socket"],
        primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon, an aluminum softball bat, inflicting serious injury, at {PLACE.PARK} on {DATE}.",
        ageRange: 26...50, occupations: ["HVAC technician", "warehouse supervisor", "auto body painter"], hasVictim: true,
        summaries: [
            "On {DATE}, after a close coed rec-league game at {PLACE.PARK}, {V} and {D} argued at the gate between the field and the gravel lot about a play at home plate. Witnesses agree {V} pushed {D} and followed {D.him} toward the cars, shouting. They disagree about what came next. {D} had a bag of bats over {D.his} shoulder. {D.He} pulled one out and swung once. It caught {V} beside the left eye and broke the orbital bone; {V} needed surgery and a titanium plate. {DL} says {V} came at {D.him} with fists raised and {D.he} swung to keep {V} off. Two teammates of {V}'s say {V} had stopped and turned away."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Surgical Records", "A fracture of the left orbital floor repaired with a titanium plate. {V} spent two nights in the hospital and still has double vision when looking up."),
            E(.video, 2, "Parent's Phone Video", "Eleven seconds from the bleachers, shot from about forty yards. {V} pushes {D}, follows toward the lot, and the bat swings. Whether {V}'s hands are up at the moment of the swing is not clear."),
            E(.physical, 2, "The Bat", "A 34-inch aluminum slowpitch bat with a dent near the sweet spot, seized from {DL}'s bag at the scene.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Umpire's Account", "The umpire told the deputy {V} had been warned twice during the game for arguing and \"was hot the whole night.\""),
            E(.document, 1, "League Record", "{V} was suspended for two games the prior season for shoving an opposing player.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Injured player",
                        direct: ["\"I turned to walk away and the lights went out.\""],
                        cross: ["\"I pushed {D.him}. I shouldn't have.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened after the game?", "\"We argued about the play at the plate. I was loud. I pushed {D.him}, once, and {D.he} walked off toward the lot, and I followed for a few steps still running my mouth.\""),
                            .direct("Then what?", "\"I said something like 'forget it' and turned toward my truck. Next thing I'm on the gravel and I can't see out of my left eye.\"", "\"I'd already turned to go. That's the last thing I remember before the gravel.\""),
                            .direct("How are you now?", "\"There's a plate under my eye. When I look up I see two of everything. I drive a forklift. I haven't been cleared to go back.\""),
                            .cross("You pushed {DL} first.", "\"I did. Once.\""),
                            .cross("And you were suspended last season for shoving another player.", "\"Yes. And I'd take a punch for that. Not a bat.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator",
                        direct: ["\"The swing was one blow, to the face.\""],
                        cross: ["\"The video doesn't clearly show {V}'s hands.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you collect at the field?", "\"The bat from {DL}'s bag, the parent's video, and statements from nine people. Most were on {V}'s team or {DL}'s, so I weighed them that way.\""),
                            .direct("What did {DL} tell you?", "\"That {V} came at {D.him} with fists up and {D.he} grabbed the first thing {D.he} had. {D.He} said {D.he} never meant to hit the face.\""),
                            .direct("Was {DL} injured?", "\"No marks on {D.him}. {D.He} declined medical.\""),
                            .cross("You can't tell from the video whether {V}'s hands were up.", "\"Not at the moment of the swing. It's too far and too short.\""),
                            .cross("Two people told you {V} was still coming forward.", "\"Two did. Both on {DL}'s team.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Teammate of the defendant",
                        direct: ["\"{V} was right on {D.him}, fists up.\""],
                        cross: ["\"I'm {DL}'s friend. I've played with {D.him} six years.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{V} shoved {D.him} and kept coming, yelling, fists up. {DL} backed up two or three steps and then swung.\""),
                            .direct("How close was {V}?", "\"An arm's length. Maybe less.\""),
                            .cross("You were walking to your car with your back to them, weren't you?", "\"I turned around when I heard the yelling.\""),
                            .cross("When did you turn, before or after the swing?", "\"Right before. I think.\"")
                        ])
        ],
        prosecutionTheory: ["{V} pushed first and was loud, but {V} had turned away. {D} answered words and a shove with a bat to the face."],
        defenseTheory: ["{V} had a history of starting fights, shoved {D}, and followed {D.him} with fists up. {D} swung once to stop the attack. The State can't disprove self-defense beyond a reasonable doubt."],
        aggravating: ["The victim suffered permanent injury"],
        mitigating: ["The victim was a voluntary participant in the conduct", "No prior criminal record"],
        victimImpacts: ["\"I've played ball in that league since I was nineteen. I can't play catch with my daughter now because I can't tell which ball is real. I was wrong to push. I wasn't wrong enough for this.\""],
        allocutions: ["\"I've played that night back a thousand times. I wish I'd kept walking.\""],
        guiltyTruths: ["A second video, found later on a player's phone, showed {V} with both hands at {V.his} sides, half-turned, when the bat came around."],
        innocentTruths: ["A second video, found later on a player's phone, showed {V} lunging with a fist cocked as {DL} swung."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(0, "About 9:40 p.m.: game ends; argument at the gate."), (0, "{V} pushes {D}; follows toward the lot; one swing."), (0, "Deputies arrive; bat seized; {V} taken to the hospital."), (2, "{V} has surgery; {DL} charged.")],
            howIdentified: "{DL} was at the scene and admitted the swing.",
            notDone: ["The lights over the gravel lot were never checked to see how well the gate was lit.", "Not every player's phone was asked for video."],
            defendantExam: [
                .direct("Why did you swing?", "\"{V} shoved me and kept coming with fists up. I'd seen {V.him} go after people before. I had the bag on my shoulder and I grabbed a bat to make {V.him} stop.\""),
                .direct("Did you aim for the face?", "\"No. I swung to back {V.him} off. {V.He} moved into it.\""),
                .cross("You were walking away. You could have kept walking to your car.", "\"With {V.him} on my back? I didn't know what {V.he}'d do.\""),
                .cross("{V} had no weapon.", "\"{V.He} had about forty pounds on me.\"", "\"No. But {V.he} had a temper and a head start.\""),
                .cross("You swung an aluminum bat at an unarmed person's head.", "\"I swung at {V.him}. I didn't pick where it landed.\"")
            ],
            prosecutionOpening: "A shove, some words, and a bat to the face of a player who had turned away.",
            defenseOpening: "One swing to stop a known hothead who started it.",
            prosecutionClosing: "Words and a shove don't justify a bat. {V} was walking away, and {DL} had every chance to do the same.",
            defenseClosing: "{V} started it, followed {D.him}, and had a history of doing exactly that. The video can't tell you where {V}'s hands were. That's reasonable doubt.",
            when: .months([4, 5, 6, 7, 8, 9]),
            victim: VictimFacts(age: 34, occupation: "forklift operator", relationship: "Played in the same rec league", harm: ["Fractured left orbital floor, repaired with a titanium plate", "Double vision when looking up"]),
            time: "9:40 p.m.",
            family: "Married, two children.",
            yearsAtJob: 7
        )
    )

    // MARK: - The farm gate on Shiloh Road (a truck turning around at night)

    static let farmGateShots = CaseTemplate(
        key: "story.farmGateShots", category: .violent,
        headlines: ["Farmer Charged After Shots Fired Into Truck at Gate", "Teen Passenger Hurt When Farmer Fires on Truck Turning Around"],
        primaryLaw: "dischargingOccupied", lesserLaw: "awdw", threshold: 6, lesserThreshold: 4,
        specification: "Discharged a firearm into an occupied vehicle, a pickup truck in which {V} was a passenger, while it was in operation, on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "awdwisi", specification: "Assaulted {V} with a deadly weapon, a .30-30 rifle, inflicting serious injury.", chance: 1.0, threshold: 0)
        ],
        ageRange: 52...71, occupations: ["farmer", "cattle farmer"], hasVictim: true,
        summaries: [
            "Around 11:20 p.m. on {DATE}, three young people who had been driving the back roads near Shiloh pulled a pickup into the gravel entrance of {D}'s farm to turn around. {D}, who had reported two tractor batteries and a welder stolen from the same barn in the past month, came down the hill with a .30-30 rifle and a flashlight. The driver says {D} yelled once and fired as the truck backed out. Two rounds hit the truck: one the tailgate, one the rear window, which spattered glass into the face and neck of {V}, 18, riding in the back seat. {DL} says {D.he} fired twice into the ground as a warning, and the truck came at {D.him} before it reversed."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Bullet Holes", "One hole through the tailgate and one through the rear window, both angled upward, from behind the truck. A fragment was recovered from the back seat headrest.", .search),
            E(.forensic, 2, "Ballistics", "The fragment and the tailgate bullet are .30-30 and consistent with {DL}'s rifle."),
            E(.document, 2, "Emergency Room Records", "{V} was treated for glass in the face and neck; one shard was removed from just below the left eye.")
        ],
        defenseEvidence: [
            E(.document, 2, "Prior Theft Reports", "Two reports {DL} made in the past month: tractor batteries and a welder taken from the same barn at night."),
            E(.physical, 1, "Tire Marks", "Ruts showing the truck pulled about twenty feet up the farm lane before reversing.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Passenger",
                        direct: ["\"The glass came in on me before I knew it was a gun.\""],
                        cross: ["\"I was in the back. I couldn't see much.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why were you on that road?", "\"Just riding around. It was a Friday. We missed the turn for Shiloh Road and pulled in the first gate to turn around.\""),
                            .direct("What happened?", "\"A light came down the hill and somebody yelled. My friend was already backing out. Then a bang, and the back window just came in on me.\"", "\"Somebody yelled and there was a bang and the glass hit me. I put my head down and screamed.\""),
                            .direct("How were you hurt?", "\"Glass in my face and neck. They pulled a piece out right under my eye. I still have a scar there. I don't ride in back seats anymore.\""),
                            .cross("You'd driven up the lane a ways, hadn't you?", "\"I don't know how far. I was in the back.\""),
                            .cross("Had anyone been drinking?", "\"Not me. I'm eighteen.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator",
                        direct: ["\"Both rounds came from behind the truck.\""],
                        cross: ["\"The truck did go about twenty feet up the lane.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the rounds hit?", "\"One through the tailgate, one through the rear window. Both angled upward, from behind, so the truck was backing away from the shooter when they hit.\""),
                            .direct("What about the warning shots?", "\"We searched the gravel at the gate with a metal detector. We didn't find a round in the ground.\""),
                            .direct("What did {DL} say?", "\"That {D.he}'d had batteries and a welder stolen and figured the thieves were back. {D.He} said the truck came at {D.him}.\""),
                            .cross("The tire marks show the truck came up the lane toward the barn.", "\"About twenty feet, then reversed. That's a turnaround.\""),
                            .cross("Could a round have gone into the soft ground and not been found?", "\"It's possible. But two rounds went into the truck.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighboring farmer",
                        direct: ["\"Everyone on Shiloh Road has had something stolen this year.\""],
                        cross: ["\"I wasn't there that night.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What's it been like out there?", "\"Batteries, fuel, a trailer, two four-wheelers. Thieves come at night with their lights off. The deputies are twenty minutes away on a good night.\""),
                            .direct("How do you know {DL}?", "\"Thirty years. {D.He}'s the one who pulls your cows out of the ditch. Never been in trouble.\""),
                            .cross("You weren't at the gate that night.", "\"No, sir.\""),
                            .cross("Would you shoot at a truck that was leaving?", "\"I hope I wouldn't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was tired of thieves and fired on a truckload of teenagers who were leaving. Both bullets hit the back of the truck."],
        defenseTheory: ["{D} came down to a dark lane where thieves had struck twice and saw a truck come toward {D.him}. {D.He} fired in fear. The State can't show where {D.he} aimed."],
        aggravating: ["The offense created a great risk of death to more than one person"],
        mitigating: ["No prior criminal record", "The defendant has a support system in the community", "The defendant has been a person of good character"],
        victimImpacts: ["\"I was eighteen and riding around with my friends because there's nothing else to do out there. I didn't steal anybody's batteries. Every time I look in a mirror I see the scar under my eye and I remember the sound of that window.\""],
        allocutions: ["\"I'm sorry for that child. I thought they were the ones who'd been robbing me. I was wrong.\""],
        guiltyTruths: ["{DL} told a neighbor the next morning, \"I wasn't going to let them leave this time.\""],
        innocentTruths: ["The driver later admitted to a friend that he'd driven up the lane toward {DL} with his high beams on \"to scare the old man\" before backing out."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-30, "{DL} reports tractor batteries stolen from the barn."), (-12, "{DL} reports a welder stolen."), (0, "11:20 p.m.: truck pulls into the farm gate; two rounds hit it as it backs out."), (0, "{V} treated at the hospital; {DL} arrested at home.")],
            howIdentified: "The driver went straight to the Sheriff's Office; {DL} said at the door that {D.he} had fired.",
            notDone: ["The driver's blood alcohol was never tested.", "No one measured where {DL} was standing."],
            defendantExam: [
                .direct("Why did you go down to the gate?", "\"I heard a truck in the lane at eleven at night. The last two times, that was the sound of somebody stealing from me.\""),
                .direct("What happened?", "\"The truck came up toward the barn, lights in my face. I yelled. It kept coming, then it stopped and backed. I fired twice. I meant both into the ground.\""),
                .cross("Both rounds hit the back of the truck. It was leaving.", "\"It happened fast. It had been coming at me a second before.\""),
                .cross("You could have called the Sheriff.", "\"I did, twice before. Nobody came till morning.\""),
                .cross("There were teenagers in that truck.", "\"I know that now. I didn't know who was in it.\"")
            ],
            prosecutionOpening: "Two bullets in the back of a truck full of teenagers who had stopped to turn around.",
            defenseOpening: "A farmer who'd been robbed twice, alone in the dark, with headlights coming at him.",
            prosecutionClosing: "Both rounds came from behind. You don't fire into the back of a leaving truck in self-defense.",
            defenseClosing: "The truck came twenty feet up {DL}'s lane at night. Fear isn't a crime, and the State hasn't proved {D.he} aimed at anyone.",
            when: .months([9, 10, 11, 12, 1, 2, 3]),
            genders: ["D": .male],
            victim: VictimFacts(age: 18, occupation: "high school senior", relationship: "Stranger", harm: ["Glass in the face and neck; a shard removed below the left eye", "A scar below the left eye"]),
            time: "11:20 p.m.",
            family: "Married forty years, three grown children.",
            residence: "The family farm off Shiloh Road"
        )
    )

    // MARK: - Unit 4 (a tenant locked out breaks back in)

    static let lockoutBreakIn = CaseTemplate(
        key: "story.lockoutBreakIn", category: .property,
        headlines: ["Tenant Charged With Breaking Into Own Apartment After Lockout", "Landlord Changed Locks; Tenant Broke Window to Get Back In"],
        primaryLaw: "feloniousBE", lesserLaw: "trespass2", threshold: 7, lesserThreshold: 4,
        specification: "Broke and entered the apartment at Unit 4, {PLACE.APARTMENTS}, with intent to commit larceny therein, on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Willfully damaged a window of Unit 4, the property of {V}.", chance: 1.0, threshold: 0)
        ],
        ageRange: 23...45, occupations: ["certified nursing assistant", "line cook", "school bus driver"], hasVictim: true,
        summaries: [
            "{D} was two months behind on rent at {PLACE.APARTMENTS}. On {DATE}, while {D} was at work, the landlord, {V}, changed the lock on Unit 4 and taped a notice to the door. No court had ordered an eviction. That night {D} broke the back window, climbed in, and filled two trash bags with clothes, {D.his} child's school things, and a laptop. {V}, who lives across the parking lot, called 911 and told deputies a burglar was carrying property out of the unit. {DL} says everything {D.he} took was {D.his}. {V} says the laptop and a television left in the unit were being held for the back rent under the lease."
        ],
        prosecutionEvidence: [
            E(.physical, 2, "Broken Window", "The back window of Unit 4 broken from outside, with blood on the sill from a cut on {DL}'s forearm."),
            E(.document, 2, "Lease", "A lease clause says the landlord may \"hold personal property for unpaid rent.\""),
            E(.statement, 2, "911 Call", "{V} reports \"someone breaking into my unit and carrying stuff out in trash bags.\"")
        ],
        defenseEvidence: [
            E(.document, 3, "Court Records", "The clerk's office has no summary ejectment filing for Unit 4. No magistrate or court ordered {DL} out."),
            E(.document, 2, "Inventory of the Bags", "The deputy's list: clothes, a child's backpack and school papers, medication in {DL}'s name, and a laptop bought by {DL}, per a receipt in {D.his} email.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Landlord",
                        direct: ["\"{D.He} owed me two months, and the lease says I can hold property.\""],
                        cross: ["\"I didn't go to court first.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you change the lock?", "\"Two months of rent and no answer to my calls. I have a mortgage on that building. The lease says I can hold property until rent is paid.\""),
                            .direct("What did you see that night?", "\"Somebody climbing out the back with trash bags. I called 911. I didn't know it was {DL} until the deputies got there.\"", "\"Someone going in and out the back window with bags. I called 911 right away.\""),
                            .direct("What about the window?", "\"Two hundred and eighty dollars to replace. I paid it.\""),
                            .cross("You never filed for eviction.", "\"No. It takes weeks and costs money.\""),
                            .cross("So you locked a parent and child out of their home without a court order.", "\"I locked my building.\"", "\"I thought the lease let me.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "Responding deputy",
                        direct: ["\"Everything in the bags appeared to be {DL}'s.\""],
                        cross: ["\"{DL} told me right away it was {D.his} apartment.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find?", "\"{DL} in the parking lot with two trash bags and a cut forearm. The back window was broken.\""),
                            .direct("What was in the bags?", "\"Clothes, a child's backpack, medication in {DL}'s name, and a laptop. {D.He} showed me a receipt for the laptop in {D.his} email.\""),
                            .direct("Why did you charge {D.him}?", "\"The landlord said the lease gave {V.him} the right to the property and the unit, and I had the broken window. I let the magistrate sort it out.\""),
                            .cross("Did you check whether there was an eviction order?", "\"Not that night.\""),
                            .cross("What did {DL} say to you?", "\"'This is my home. My kid's medicine is in there.'\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Legal aid paralegal",
                        direct: ["\"There was no eviction case filed for that unit.\""],
                        cross: ["\"I'm not a lawyer.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find in the court records?", "\"No summary ejectment filed by {V} for Unit 4, ever. Without a judgment and a sheriff's writ, a residential tenant can't be locked out in North Carolina.\""),
                            .direct("Can a lease give a landlord the right to hold a tenant's belongings?", "\"Not for residential tenants. That clause is void under our landlord-tenant law.\""),
                            .cross("You work for the office that represents {DL} in the civil case.", "\"Yes.\""),
                            .cross("Breaking a window is still breaking a window.", "\"It's {DL}'s window to answer for. It's not a burglary of {D.his} own home.\"")
                        ])
        ],
        prosecutionTheory: ["{D} broke into a unit {D.he} no longer had the right to enter and carried out property the lease let the landlord hold."],
        defenseTheory: ["It was {D}'s home. No court had evicted {D.him}, and the lease clause is void. A person can't commit larceny of {D.his} own belongings, so there was no felony intent, only a broken window."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant supports the defendant's family", "The defendant has been gainfully employed"],
        victimImpacts: ["\"I'm not a big company. I own eight units and I'm behind too. I didn't think I needed a lawyer to lock my own door.\""],
        allocutions: ["\"I'll pay for the window. My son's inhaler was in there. I wasn't going to leave it.\""],
        guiltyTruths: ["A neighbor later said {DL} told her {D.he} planned to take the television too and sell it before the landlord could."],
        innocentTruths: ["{V} had locked out two earlier tenants the same way, and a legal aid lawyer had warned {V.him} in writing that it was illegal."],
        moods: [.sympathetic], doctrines: ["burdenOfProof", "lesserIncluded", "mistakeOfFact"],
        story: StoryExtras(
            timeline: [(-60, "{DL} falls behind on rent."), (0, "Morning: {V} changes the lock on Unit 4 and posts a notice."), (0, "Night: {DL} breaks the back window and fills two bags; {V} calls 911."), (0, "{DL} arrested in the parking lot.")],
            howIdentified: "Found by the deputy in the parking lot with the bags.",
            notDone: ["No one checked the court records for an eviction until the defense did."],
            defendantExam: [
                .direct("Why did you break the window?", "\"I came home from a double shift and my key didn't work. My son's inhaler and his school things were inside. I called {V} three times and {V.he} didn't answer.\""),
                .direct("What did you take?", "\"Our clothes, his backpack and inhaler, my medicine, and my laptop. All mine. I left the TV because I couldn't carry it.\""),
                .cross("You owed two months of rent.", "\"I did. I was going to pay it. That's not a reason to lock out a child.\""),
                .cross("You could have called the Sheriff instead of breaking a window.", "\"At midnight with a nine-year-old in the car? I didn't know they'd help.\""),
                .cross("You knew the lease said the landlord could hold your property.", "\"I didn't read every line. I didn't think it meant my kid's medicine.\"")
            ],
            prosecutionOpening: "A broken window and a tenant who didn't pay carrying bags out in the night.",
            defenseOpening: "A parent breaking into {D.his} own home to get {D.his} child's inhaler.",
            prosecutionClosing: "{V} locked the unit. {DL} broke the window anyway and carried out property the lease let {V} hold.",
            defenseClosing: "No court evicted {D.him}. It was {D.his} home and {D.his} things. The window is a misdemeanor at most.",
            victim: VictimFacts(age: 58, occupation: "landlord and retired electrician", relationship: "Landlord"),
            time: "11:50 p.m.",
            family: "Single parent of a nine-year-old son.",
            residence: "Unit 4 at {PLACE.APARTMENTS} until the lockout"
        )
    )

    // MARK: - The door at closing time (a bouncer fires at an ejected patron)

    static let securityGuardShot = CaseTemplate(
        key: "story.securityGuardShot", category: .violent,
        headlines: ["Bar Security Guard Shoots Ejected Patron Outside Door", "Bouncer Says He Saw a Gun; Patron Was Holding a Phone"],
        primaryLaw: "awdwikisi", lesserLaw: "awdwisi", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon, a handgun, with intent to kill, inflicting serious injury, outside {BAR} on {DATE}.",
        ageRange: 28...46, occupations: ["licensed security guard", "armed security officer"], hasVictim: true,
        summaries: [
            "Shortly before closing on {DATE}, {D}, the armed security guard at {BAR}, put {V} out the door after {V} threw a drink at a bartender. Ten minutes later {V} came back up the sidewalk toward the door, shouting, with something dark in {V.his} right hand. {D} drew and fired three times. One round hit {V} in the hip. The object was a phone. {DL} says {V} had told {D.him} on the way out, \"I've got something in the car for you,\" and came back holding the dark object low like a pistol. The bar's door camera shows the approach but not {V}'s hand clearly."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Door Camera", "{V} walks up the sidewalk shouting, right arm at {V.his} side. {D} draws and fires three times from about twenty feet. The camera angle and the dark object in {V}'s hand make it impossible to tell what it is."),
            E(.physical, 2, "The Phone", "A black phone in a black case, found on the sidewalk under {V}. No weapon was found on {V} or in {V.his} car.", .search),
            E(.document, 2, "Medical Records", "A gunshot wound to the right hip with a fractured pelvis; {V} walks with a cane.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Bartender's Account", "The bartender heard {V} say, \"I've got something in the car for you,\" as {D} walked {V.him} out."),
            E(.document, 1, "Security License", "{DL}'s state armed guard registration and firearms qualification, both current.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Shooting victim",
                        direct: ["\"I came back to get my card. I had my phone in my hand.\""],
                        cross: ["\"I was drunk and I said things I shouldn't have.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you go back?", "\"My debit card was still behind the bar on my tab. I was going to ask for it. I had my phone out to call a ride.\""),
                            .direct("What happened?", "\"I was yelling, I'll admit that. Then I saw {D.him} reach and I heard the shots and I was on the ground.\"", "\"I was halfway up the sidewalk, yelling about my card, and {D.he} shot me. I never even got close.\""),
                            .direct("How are you now?", "\"There's a rod in my pelvis. I walk with a cane. I'm thirty-one.\""),
                            .cross("You told {DL}, \"I've got something in the car for you.\"", "\"I was drunk and mad. I don't own a gun. There was nothing in my car.\""),
                            .cross("You'd thrown a drink at a bartender.", "\"Yes. I'm ashamed of that.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{V} was holding a phone. No weapon anywhere.\""],
                        cross: ["\"On the video I can't tell what's in {V}'s hand either.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find at the scene?", "\"A black phone under {V}, three casings by the door, and no weapon. We searched {V}'s car with consent. Nothing.\""),
                            .direct("How far away was {V} when {DL} fired?", "\"About twenty feet, by the sidewalk seams on the video.\""),
                            .direct("Did {V}'s arm ever come up?", "\"Not on the video. It stays at {V.his} side.\""),
                            .cross("Could you tell from the video it was a phone?", "\"No. It's a dark shape. I only know because we found it.\""),
                            .cross("{DL} had just been told {V} had something in the car.", "\"That's what the bartender says {V} said.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Use-of-force instructor",
                        direct: ["\"At twenty feet, a person can close and fire before you can react.\""],
                        cross: ["\"A phone isn't a gun.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do you teach about distance?", "\"A person can cover twenty feet in under two seconds. If you wait to see a muzzle, you're late. Guards are trained to read the threat, not wait for it.\""),
                            .direct("Was it reasonable for {DL} to believe {V} was armed?", "\"A threat about something in the car, a return ten minutes later, shouting, and a dark object held low. That's a textbook pre-attack picture.\""),
                            .cross("{V}'s arm never came up.", "\"No. That's the point. If it does, you're already shot.\""),
                            .cross("Three shots at a person holding a phone.", "\"A tragic mistake isn't always an unreasonable one.\"")
                        ])
        ],
        prosecutionTheory: ["{D} shot a drunk, unarmed customer three times for walking up a sidewalk with a phone. {V}'s arm never rose."],
        defenseTheory: ["{V} threatened {D}, said there was something in the car, and came back minutes later with a dark object held low. {D} reasonably believed {D.he} was about to be shot."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["\"I acted like an idiot that night and I deserved to be thrown out. I didn't deserve a bullet. I used to run every morning. Now I count the steps to my mailbox.\""],
        allocutions: ["\"I thought I was about to die. I'm sorry it was a phone. I think about that every day.\""],
        guiltyTruths: ["{DL} texted a coworker an hour before the shooting, \"If that drunk comes back I'm going to light that drunk up.\""],
        innocentTruths: ["A phone video from across the street later showed {V} raise the phone toward {DL} in a two-handed grip, like a pistol, just before the shots."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense", "burdenOfProof", "lesserIncluded"],
        extras: ["BAR": ["The Anchor Tavern", "Rooster's on Main", "The Tap Room"]],
        story: StoryExtras(
            timeline: [(0, "About 1:30 a.m.: {V} put out of {BAR} after throwing a drink."), (0, "About 1:40 a.m.: {V} walks back toward the door; {D} fires three times."), (0, "No weapon found on {V} or in {V.his} car.")],
            howIdentified: "{DL} called 911 and reported the shooting.",
            notDone: ["{V}'s blood alcohol was measured, but no one tested how well the sidewalk was lit.", "Witnesses across the street were never canvassed."],
            defendantExam: [
                .direct("What did {V} say when you put {V.him} out?", "\"'I've got something in the car for you.' I've heard that before. Once it was a gun.\""),
                .direct("What did you see when {V} came back?", "\"Walking fast, yelling my name, right hand low with something black in it. I told {V.him} to stop. {V.He} didn't.\""),
                .cross("{V}'s arm never came up.", "\"I wasn't going to wait for it to.\""),
                .cross("You fired three times.", "\"I fired until the threat stopped. That's how I'm trained.\""),
                .cross("You could have gone inside and locked the door.", "\"With a full bar behind me? It's my job to stand there.\"")
            ],
            prosecutionOpening: "A phone, a sidewalk, and three shots.",
            defenseOpening: "A threat, a return, and two seconds to decide.",
            prosecutionClosing: "{V}'s arm never moved. A guard's job is to read a threat, and there wasn't one.",
            defenseClosing: "{V} told {DL} there was something in the car and came back for {D.him}. {DL} didn't have to wait to see a muzzle.",
            victim: VictimFacts(age: 31, occupation: "carpet installer", relationship: "Customer at the bar", harm: ["Gunshot wound to the right hip with a fractured pelvis", "Walks with a cane"]),
            time: "1:40 a.m.",
            employer: "the bar's security contractor",
            yearsAtJob: 5
        )
    )

    // MARK: - Level 3 of the hospital deck (a nurse robbed after a night shift)

    static let parkingDeckRobbery = CaseTemplate(
        key: "story.parkingDeckRobbery", category: .robbery,
        headlines: ["Nurse Robbed at Knifepoint in Hospital Parking Deck", "Arrest in Parking Deck Robbery After Stolen Card Used at Gas Station"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 7, lesserThreshold: 5,
        specification: "Took a purse and its contents from the person of {V}, by the use of a knife, whereby {V}'s life was threatened, at the parking deck of {PLACE.HOSPITAL} on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "cardFraud", specification: "Used {V}'s debit card without consent to obtain goods.", chance: 1.0, threshold: 0)
        ],
        ageRange: 19...34, occupations: ["unemployed", "day laborer", "fast food worker"], hasVictim: true,
        summaries: [
            "At 7:25 a.m. on {DATE}, {V}, a nurse coming off a twelve-hour night shift at {PLACE.HOSPITAL}, was unlocking {V.his} car on level 3 of the parking deck when a man in a gray hoodie held a folding knife to {V.his} side and took {V.his} purse. Forty minutes later {V}'s debit card bought $84 in gas and cigarettes at {PLACE.GASSTATION}. The station camera shows {D}. Two days later {V} picked {D} from a photo array as the man with the knife. {DL} says a man {D.he} knows only as \"Junior\" gave {D.him} the card to buy gas and {D.he} was nowhere near the hospital."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Gas Station Video", "{D} at the register at 8:05 a.m., paying $84 with {V}'s debit card, wearing a gray hoodie."),
            E(.document, 2, "Photo Array", "A six-photo array shown by an officer who didn't know the suspect. {V} picked {DL}'s photo and said, \"I'm pretty sure. Ninety percent.\""),
            E(.physical, 2, "Folding Knife", "A black folding knife found in the console of the car {DL} was driving when arrested.", .search)
        ],
        defenseEvidence: [
            E(.video, 2, "Deck Camera", "The camera on level 3 was pointed at the elevator. It shows {V} walk to the car, but not the robber's face."),
            E(.statement, 1, "Junior", "{DL} says a man called Junior handed {D.him} the card outside the station. No one named Junior was found.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Robbery victim",
                        direct: ["\"I felt the point of the knife through my scrubs.\""],
                        cross: ["\"I'd been up all night.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened on level 3?", "\"I'd just done twelve hours. I was getting my keys out and somebody was right against me, and I felt the point through my scrubs. He said 'purse' and nothing else.\""),
                            .direct("How long did you see his face?", "\"A few seconds. He was close. The hood was up but I saw his face under it.\"", "\"Three or four seconds, maybe. Close up, under the hood.\""),
                            .direct("How has this affected you?", "\"I park in the same deck every night. I don't anymore. My husband walks me in. I'm a nurse. I'm supposed to be the one who takes care of people, and now I'm scared of a stairwell.\""),
                            .cross("You'd been awake for more than twenty hours.", "\"Yes. I still saw him.\""),
                            .cross("You told the officer 'ninety percent,' not a hundred.", "\"I was being honest.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Robbery detective",
                        direct: ["\"The card was used forty minutes later by {DL}.\""],
                        cross: ["\"The deck camera doesn't show the robber's face.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did you identify {DL}?", "\"{V}'s bank flagged the card at {PLACE.GASSTATION} at 8:05 a.m. The station camera showed {DL} using it, in a gray hoodie like the one {V} described.\""),
                            .direct("How was the photo array done?", "\"A blind administrator, six photos, the standard instructions. {V} picked {DL} and said ninety percent.\""),
                            .direct("Where was the knife?", "\"In the console of the car {DL} was driving when we arrested {D.him}, two days later.\""),
                            .cross("Lots of people own gray hoodies and folding knives.", "\"Fewer of them have {V}'s card forty minutes after the robbery.\""),
                            .cross("Did you look for Junior?", "\"{DL} couldn't give me a last name, an address, or a phone number.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Eyewitness identification expert",
                        direct: ["\"Fatigue, stress, and a weapon all reduce accuracy.\""],
                        cross: ["\"The array itself was done properly.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What affects an eyewitness's accuracy?", "\"A weapon draws the eye away from the face. Stress, a few seconds of viewing, a hood, and being awake more than twenty hours all make mistakes more likely.\""),
                            .direct("Does confidence mean accuracy?", "\"Initial confidence can be meaningful when the procedure is clean. Ninety percent is high but it isn't certainty.\""),
                            .cross("The array was double-blind and properly instructed.", "\"Yes. That's in its favor.\""),
                            .cross("The person {V} picked had {V.his} card forty minutes later.", "\"That's not something I evaluate.\"")
                        ])
        ],
        prosecutionTheory: ["{D} robbed {V} at knifepoint and used {V.his} card forty minutes later. The identification, the hoodie, the card, and the knife all point to the same person."],
        defenseTheory: ["{D} used a card {D.he} shouldn't have, and that's the card charge. But the robbery identification came from an exhausted witness with a knife at {V.his} side, and the card came from Junior."],
        aggravating: ["The victim was targeted while leaving work"],
        mitigating: ["The defendant is young"],
        victimImpacts: ["\"I've worked nights at that hospital for eleven years. I've held people's hands while they died. I never once thought about walking to my car. Now I sit in it with the doors locked before I can start it.\""],
        allocutions: ["\"I used the card. I shouldn't have. I didn't rob anybody.\"", "\"I'm sorry for what {V} went through.\""],
        guiltyTruths: ["{V}'s purse was later found in a storm drain two blocks from {DL}'s mother's house, with {DL}'s fingerprint on the clasp."],
        innocentTruths: ["A man arrested for another deck robbery a month later had {V}'s hospital badge in his car and a cousin called Junior."],
        moods: [.wantsConviction], doctrines: ["eyewitnessID", "burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(0, "7:25 a.m.: {V} robbed at knifepoint on level 3 of the deck."), (0, "8:05 a.m.: {V}'s card used at {PLACE.GASSTATION}."), (2, "{V} picks {DL} from a blind photo array."), (2, "{DL} arrested; knife found in the car console.")],
            howIdentified: "The station camera, then {V}'s photo array pick.",
            notDone: ["The knife was not tested for {V}'s DNA or fibers from {V.his} scrubs.", "No one pulled {DL}'s phone location for 7:25 a.m."],
            defendantExam: [
                .direct("How did you get the card?", "\"Junior came up at the pump and said use it, fill up, give him the cigarettes. I knew it wasn't his. I did it anyway.\""),
                .direct("Were you at the hospital that morning?", "\"No. I was asleep at my mom's till about seven-thirty.\""),
                .cross("Can anyone confirm that?", "\"My mom left for work at six-thirty.\""),
                .cross("The knife in your car.", "\"I use it at work for opening boxes.\""),
                .cross("Who is Junior?", "\"Just a guy from around. I don't know his real name.\"")
            ],
            prosecutionOpening: "A knife at a nurse's side and {V.his} card in {DL}'s hand forty minutes later.",
            defenseOpening: "A bad decision at a gas pump, not a robbery.",
            prosecutionClosing: "Junior doesn't exist. {V} picked {DL}. {DL} had the card and the knife.",
            defenseClosing: "Using the card is a crime, and {DL} owns it. Holding the knife is a different crime, and the State proved it with a tired witness and a convenient story.",
            genders: ["D": .male],
            victim: VictimFacts(age: 47, occupation: "registered nurse", relationship: "Stranger", family: "Married, two teenagers"),
            time: "7:25 a.m.",
            family: "Single, no children. Lives with his mother.",
            residence: "His mother's house in {HOOD}"
        )
    )
}
