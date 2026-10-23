import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the AC batch of written cases. Each is a complete new incident; the earlier case appears only
/// as {PRIOR} and {PRIORDATE}.
extension FollowUpCases {
    static let batchAC: [CaseTemplate] = [
        checkpointRefusal, ditchCrash, dvpoParkingLot, newPartnerAssault, barThreat, poolHallCue, checkpointRun, trooperShove, stoplightRearEnd
    ]

    // MARK: - The checkpoint refusal (DWI again)

    static let checkpointRefusal = CaseTemplate(
        key: "story.followup.checkpointRefusal", category: .traffic,
        headlines: ["Driver Refuses Breath Test at Checkpoint; Blood Says 0.11", "Back in Court: DWI Charge at Route 9 Checkpoint"],
        primaryLaw: "dwi", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Drove a motor vehicle on Route 9 while under the influence of an impairing substance and with an alcohol concentration of 0.08 or more.",
        ageRange: 21...70, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} drove into a Highway Patrol checking station on Route 9 on {DATE} at about 12:40 a.m. The trooper at the window smelled alcohol and saw an open can of beer in the console. {DL} refused field tests and refused the Intoxilyzer. A magistrate signed a warrant, and a blood draw at 1:55 a.m. came back at 0.11. {DL} says {D.he} had two beers at a friend's house over three hours, that the open can belonged to a passenger dropped off earlier, and that {D.he} refused because {D.he} didn't trust the machine after last time."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Blood Test", "0.11 grams of alcohol per 100 milliliters, drawn at 1:55 a.m. under a search warrant and analyzed by the State Crime Lab.", .search),
            E(.video, 2, "Dash Camera", "The trooper's camera shows {DL} at the window fumbling twice for the license, and the open can in the console."),
            E(.document, 2, "Checking Station Plan", "A written plan signed by a sergeant, stopping every vehicle, with lit signs a quarter mile ahead.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Friend's Account", "The friend who hosted says {DL} had two beers between 9:30 p.m. and 12:30 a.m."),
            E(.document, 1, "Drop-Off Text", "A text at 12:25 a.m. from a passenger saying \"thx for the ride, left you my beer lol.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "State trooper at the checking station",
                        direct: ["\"Strong odor of alcohol, an open can, and a refusal.\""],
                        cross: ["\"I didn't see {DL} drink from the can.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you observe at the window?", "\"A strong odor of alcohol, red eyes, and an open can of beer in the console. {DL} dropped the license once and fumbled for it twice.\""),
                            .direct("What happened when you asked for tests?", "\"{DL} refused the field tests and then the Intoxilyzer. I applied for a warrant and the magistrate signed it.\""),
                            .direct("What was the blood result?", "\"0.11, drawn at 1:55 a.m.\""),
                            .cross("You never saw {DL} drink from that can?", "\"No. It was open and half full.\""),
                            .cross("It was after midnight, and drivers get red eyes?", "\"Some do. The odor and the fumbling were there too.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Crime Lab chemist",
                        direct: ["\"0.11, and it was dropping, not rising, by then.\""],
                        cross: ["\"I can't tell you how many drinks.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the blood sample show?", "\"An alcohol concentration of 0.11, run twice with the same result.\""),
                            .direct("What would it have been at 12:40, when {DL} was driving?", "\"Higher, if the last drink was around 12:30. Someone at 0.11 an hour and fifteen minutes later was well above 0.08 at the wheel.\""),
                            .cross("Could two beers produce a 0.11?", "\"Not two ordinary beers over three hours in an adult. It would take more.\""),
                            .cross("You don't know {DL}'s weight or what {D.he} ate?", "\"No. Those change the curve. They don't turn two beers into 0.11.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend who hosted",
                        direct: ["\"Two beers. I was counting because I knew {D.he} had to drive.\""],
                        cross: ["\"I went inside for a while around eleven.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How much did {DL} drink at your house?", "\"Two beers between 9:30 and 12:30. We were watching the game.\""),
                            .direct("Who left with {DL}?", "\"A buddy of ours who needed a ride home. He had a beer in his hand when he got in.\""),
                            .cross("Were you with {DL} the whole three hours?", "\"Mostly. I went inside for maybe twenty minutes around eleven.\""),
                            .cross("You didn't count the cans in the cooler?", "\"No. I'm telling you what I saw.\"")
                        ])
        ],
        prosecutionTheory: ["{D} drove to a checkpoint at 0.11 with an open beer in the console, and refused every test that might have helped."],
        defenseTheory: ["Two beers, a passenger's can, and a refusal born of distrust. A blood number an hour later is not proof of the number at the wheel."],
        aggravating: ["Willful refusal of a chemical test"],
        mitigating: [],
        allocutions: ["\"I should never have gotten behind the wheel. I'm asking for treatment, not just punishment.\""],
        guiltyTruths: ["The friend's doorbell camera shows {DL} carrying a twelve-pack in at 9:30 and an empty box out at 12:20."],
        innocentTruths: ["The lab later found that the blood kit used that night was from a lot recalled for contaminated preservative, which can raise readings."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "9:30 p.m.: {DL} arrives at a friend's house."), (0, "12:25 a.m.: passenger dropped off."), (0, "12:40 a.m.: checking station on Route 9."),
                       (0, "1:20 a.m.: magistrate signs blood warrant."), (0, "1:55 a.m.: blood drawn."), (21, "Lab result: 0.11.")],
            howIdentified: "{DL} was driving when the vehicle reached the checking station.",
            defendantExam: [
                .direct("How much did you drink that night?", "\"Two beers. That's the truth.\""),
                .direct("Why did you refuse the tests?", "\"After last time, I didn't trust them. I wanted a lawyer first.\""),
                .cross("Two beers don't make a 0.11.", "\"I can't explain the number.\""),
                .cross("The open can was half full in your console.", "\"It was my passenger's. He left it.\"")
            ],
            prosecutionOpening: "A checkpoint, an open beer, a refusal, and a blood warrant that came back at 0.11.",
            defenseOpening: "Two beers over three hours, and a can that wasn't {DL}'s.",
            prosecutionClosing: "The chemist told you two beers can't do this. The blood says what the refusal tried to hide.",
            defenseClosing: "A number taken more than an hour later, in a case where the earlier one is the reason {DL} is suspected.",
            time: "12:40 a.m."
        )
    )

    // MARK: - The ditch (who was driving?)

    static let ditchCrash = CaseTemplate(
        key: "story.followup.ditchCrash", category: .traffic,
        headlines: ["Vehicle in Ditch, Driver Found Walking Away, Troopers Say", "\"My Friend Was Driving\": DWI Defense Meets Airbag DNA"],
        primaryLaw: "dwi", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Drove a motor vehicle on Cane Creek Road while under the influence of an impairing substance and with an alcohol concentration of 0.08 or more.",
        ageRange: 21...70, occupations: [], hasVictim: false,
        summaries: [
            "On {DATE} at about 1:30 a.m., a vehicle registered to {D} left Cane Creek Road on a curve and nosed into a ditch; the driver's airbag deployed. A trooper found {DL} walking along the road 0.4 miles away at 1:52 a.m., with a cut on {D.his} chin. {DL} blew 0.16 at 2:45 a.m. {DL} says a friend was driving, panicked and ran off into the woods. The friend {DL} named was clocked in at a bakery on the night shift from 10 p.m. to 6 a.m. A swab of the driver's airbag matched {DL}'s DNA. This came after {DL}'s case in this court in {PRIORDATE} for {PRIOR}."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Airbag DNA", "A swab of blood on the deployed driver's airbag matched {DL}'s DNA. No other profile was found on it.", .search),
            E(.forensic, 3, "Intoxilyzer Result", "0.16 at 2:45 a.m."),
            E(.document, 2, "Bakery Time Records", "The friend {DL} named was clocked in from 9:58 p.m. to 6:04 a.m., and the bakery's camera shows the friend at the mixer at 1:30 a.m."),
            E(.physical, 1, "Seat Position", "The driver's seat was set to a position fitting {DL}'s height; the named friend is seven inches taller.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Single Key", "Only one key to the vehicle exists, and {DL} says {D.he} had handed it to the driver."),
            E(.statement, 1, "Walking Toward Help", "{DL} was walking toward the nearest house with a porch light when found.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "State trooper",
                        direct: ["\"Bloodied chin, 0.4 miles from the car, and a story about a friend.\""],
                        cross: ["\"I didn't see anyone driving. Nobody did.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did you find {DL}?", "\"Walking east on Cane Creek Road, 0.4 miles from the ditch, at 1:52 a.m., with a fresh cut on the chin.\""),
                            .direct("What did {DL} tell you?", "\"That a friend was driving and ran into the woods. {D.He} gave me the friend's name.\""),
                            .direct("What did you do with that name?", "\"I radioed it in, and a second trooper went to the friend's job at 2:30. The friend was at work at the bakery and had been since before ten.\""),
                            .cross("Nobody saw who was driving?", "\"No one saw the crash. The airbag tells us who was in the driver's seat.\""),
                            .cross("Did you search the woods?", "\"With a K-9 team at 2:30. The dog found no track leading from the car into the woods.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Crime Lab DNA analyst",
                        direct: ["\"One profile on the driver's airbag, and it's {DL}'s.\""],
                        cross: ["\"DNA can't tell you what time it got there.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find on the driver's airbag?", "\"A bloodstain at chin height with a single DNA profile.\""),
                            .direct("Whose profile was it?", "\"It matched {DL}. No second person's DNA was on the bag.\""),
                            .cross("Could the blood have gotten there after the crash?", "\"The stain is on the face of the bag, in the spray pattern you get when it deploys into someone. Not a smear.\""),
                            .cross("You can't say when the stain was made?", "\"Not by the clock. The bag deployed once, that night.\"")
                        ]),
            WitnessSeed(name: nil, role: "Friend {DL} named as the driver",
                        direct: ["\"I was at work. I've never driven that car.\""],
                        cross: ["\"We're not close anymore.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you at 1:30 that morning?", "\"At the bakery, on the night shift, running the mixer. I clocked in a little before ten.\""),
                            .direct("Have you ever driven {DL}'s car?", "\"Never. I've never even sat in it. I'm six-four; that seat would be up against my knees.\""),
                            .cross("You and {DL} had a falling out?", "\"A while back, over money. That doesn't change where I was.\""),
                            .cross("Could you have left the bakery without clocking out?", "\"The camera's on me the whole time. I was there.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} drove into a ditch at 0.16, walked away, and blamed a friend who was at work across the county."],
        defenseTheory: ["No one saw who drove. {DL} was frightened and confused after a crash."],
        aggravating: ["Alcohol concentration of 0.16"],
        mitigating: [],
        allocutions: ["\"I lied about my friend. I was scared. I'm ready to get help.\""],
        guiltyTruths: ["{DL}'s phone shows a call to a towing company at 1:33 a.m. that hung up after ten seconds."],
        innocentTruths: ["A different acquaintance, not the one {DL} first named out of panic, later admitted driving and running; the blood on the airbag came from {DL} reaching across to shut off the engine."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "1:30 a.m.: vehicle leaves Cane Creek Road into a ditch."), (0, "1:52 a.m.: trooper finds {DL} walking 0.4 miles away."),
                       (0, "2:30 a.m.: K-9 search; a second trooper visits the bakery."), (0, "2:45 a.m.: Intoxilyzer, 0.16."), (25, "Airbag DNA result.")],
            howIdentified: "The vehicle's registration, {DL}'s presence nearby, and the airbag DNA.",
            defendantExam: [
                .direct("Who was driving?", "\"Not me. I was in the passenger seat.\""),
                .direct("Why did you name your friend?", "\"I was scared and confused. I said the first name that came to mind.\""),
                .cross("Then who was driving?", "\"I'd rather not say.\""),
                .cross("Your blood is on the driver's airbag, and no one else's.", "\"I leaned over after the crash. I hit my chin.\"")
            ],
            prosecutionOpening: "One airbag, one bloodstain, one profile: {DL}'s.",
            defenseOpening: "No one saw who was driving.",
            prosecutionClosing: "The friend was at work on camera. The dog found no track. The airbag found {DL}.",
            defenseClosing: "A lie told in panic isn't proof of driving.",
            time: "1:30 a.m."
        )
    )

    // MARK: - The parking lot (protective order violation, same victim)

    static let dvpoParkingLot = CaseTemplate(
        key: "story.followup.dvpoParkingLot", category: .family,
        headlines: ["Man Found Waiting at Ex's Car Despite Protective Order", "A Letter on the Windshield, a Protective Order in Force"],
        primaryLaw: "dvpoViolation", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Knowingly violated a valid domestic violence protective order protecting {V} by going to {V.his} place of employment and leaving a written message on {V.his} car.",
        ageRange: 22...50, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V} obtained a one-year domestic violence protective order in district court. {DL} was served in the courtroom. The order bars {D.him} from {V}'s home and workplace and from any contact. On {DATE} at about 5:10 p.m., a coworker of {V}'s saw {DL} standing at {V}'s car in the parking lot of the dental office where {V} works. A handwritten letter signed with {DL}'s nickname was under the wiper. The office's parking lot camera shows {DL} walk to the car, place the letter and wait by the driver's door for eleven minutes. {DL} says {D.he} was picking up a prescription at the pharmacy next door and the letter was only an apology."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Protective Order and Service", "A one-year 50B order prohibiting contact and barring {DL} from {VL}'s workplace, with the deputy's return showing service on {DL} in the courtroom."),
            E(.video, 3, "Parking Lot Camera", "5:08 p.m.: {DL} walks across the lot to {VL}'s car, places a letter under the wiper, and stands at the driver's door until 5:19, leaving when the office door opens."),
            E(.physical, 2, "The Letter", "One page, handwritten: \"I just need you to hear me out. I'll wait as long as it takes.\" Signed with {DL}'s nickname.")
        ],
        defenseEvidence: [
            E(.document, 1, "Pharmacy Receipt", "A pharmacy receipt from the store next door, 4:52 p.m. that day.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Protected party",
                        direct: ["\"He was at my car. I couldn't go outside.\""],
                        cross: ["\"No, he didn't threaten me in the letter.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How did you learn {DL} was in the parking lot?", "\"My coworker came back in and said he was standing at my car. I looked through the blinds and it was him.\""),
                            .direct("What did you do?", "\"I called 911 and stayed in the back office until the deputy came. My hands were shaking so badly I couldn't dial at first.\""),
                            .direct("Why did you get the protective order?", "\"Because I was afraid of him. I wanted one place in my life he couldn't come.\""),
                            .cross("The letter was an apology, wasn't it?", "\"It said he'd wait as long as it takes. That isn't an apology to me.\"")
                        ]),
            WitnessSeed(name: nil, role: "Coworker at the dental office",
                        direct: ["\"He was right at the driver's door.\""],
                        cross: ["\"I'd never met him. I knew his face from the photo {VL} gave us.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see when you went outside?", "\"A man standing at {VL}'s driver's door with a paper under the wiper.\""),
                            .direct("How did you know who he was?", "\"{VL} gave the front desk a copy of the order with his photo, so we'd know.\""),
                            .cross("He didn't say anything to you?", "\"He asked if {VL} was still inside. I didn't answer.\""),
                            .cross("You'd never met him before?", "\"No. I recognized him from the photo.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Deputy",
                        direct: ["\"Served in the courtroom. He knew.\""],
                        cross: ["\"The pharmacy shares the lot, yes.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Was {DL} served with the order?", "\"In the courtroom, the day it was entered. The judge explained it to him and he signed the return.\""),
                            .direct("Where is {VL}'s car on the camera relative to the pharmacy?", "\"At the far end of the lot from the pharmacy, in the spaces marked for the dental office.\""),
                            .cross("The pharmacy and the dental office share one parking lot?", "\"One lot. The pharmacy entrance is about a hundred and twenty feet from {VL}'s car.\""),
                            .cross("The receipt shows a purchase at 4:52.", "\"And the camera shows him at the car from 5:08 to 5:19, after the purchase.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} knew the order, walked past the pharmacy to {V}'s car, left a letter, and waited at the driver's door."],
        defenseTheory: ["{DL} had a lawful reason to be in that lot and left an apology. Clumsy, not menacing."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"I thought the order meant I could go to work without looking over my shoulder. Now I park by the door and leave with someone.\""],
        allocutions: ["\"I wanted to say I was sorry. I see now that wasn't mine to decide.\""],
        guiltyTruths: ["{DL}'s phone showed three searches for the dental office's hours that afternoon."],
        innocentTruths: ["A pharmacy employee later said {DL} had asked her to deliver the letter for him because he knew he couldn't, and she refused; he left it on the car in frustration on his way to his own car parked beside it."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(-60, "Protective order entered; {DL} served in the courtroom."), (0, "4:52 p.m.: pharmacy receipt."),
                       (0, "5:08 p.m.: {DL} at {VL}'s car."), (0, "5:19 p.m.: {DL} leaves the lot."), (0, "5:30 p.m.: deputy arrives; {DL} arrested at home that evening.")],
            howIdentified: "The coworker recognized {DL} from the photo with the order; the parking lot camera.",
            defendantExam: [
                .direct("Why were you in that parking lot?", "\"I was at the pharmacy. I saw {V.his} car and wrote the note.\""),
                .direct("What did you want?", "\"To apologize. That's all the letter says.\""),
                .cross("You stood at {V.his} driver's door for eleven minutes.", "\"I was deciding whether to leave.\""),
                .cross("The judge explained the order to you in person.", "\"Yes. I knew about it.\"")
            ],
            prosecutionOpening: "A protective order, explained to {DL} in person, and eleven minutes at {V}'s driver's door.",
            defenseOpening: "A note of apology in a shared parking lot.",
            prosecutionClosing: "The order said no contact. A letter on a windshield is contact.",
            defenseClosing: "{DL} left before {V} came out and never said a word to {V.him}.",
            genders: ["D": .male, "V": .female],
            time: "5:10 p.m."
        )
    )

    // MARK: - A new partner (assault on a female)

    static let newPartnerAssault = CaseTemplate(
        key: "story.followup.newPartnerAssault", category: .violent,
        headlines: ["Man Charged After Woman Seen Bleeding at Gas Station", "New Relationship, Same Courtroom: Assault Charge"],
        primaryLaw: "assaultFemale", lesserLaw: "simpleAssault", threshold: 6, lesserThreshold: 4,
        specification: "Assaulted {V}, a female, by shoving her into the doorframe of a car and striking her in the mouth, {D} being a male person at least 18 years of age.",
        ageRange: 22...50, occupations: [], hasVictim: true,
        summaries: [
            "On {DATE} at about 9:20 p.m., a gas station clerk on {STREET} called 911 after {V} came inside bleeding from the mouth and asked to use the bathroom to hide. {V} had been dating {D} for four months, after {DL}'s case in this court in {PRIORDATE} for {PRIOR}. The station's pump camera shows {DL} and {V} arguing beside {DL}'s car, then {DL} shoving {V} into the open passenger doorframe; {V} turns away holding {V.his} mouth. {V} now says {V.he} slipped. {DL} says {V} was drunk, fell into the door, and that he never touched {V.him}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Pump Camera", "9:17 p.m.: {DL} and {VL} argue beside the car. {DL} puts both hands on {VL}'s shoulders and shoves; {VL}'s head and face hit the doorframe. {VL} turns away holding {V.his} mouth."),
            E(.digital, 3, "911 Call", "The clerk: \"She's in my bathroom bleeding, she says he hit her and she's scared to go back out.\""),
            E(.document, 2, "ER Record", "A split upper lip closed with three stitches and a chipped front tooth.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Victim's Recantation", "{VL} told the defense investigator that {V.he} had been drinking and slipped into the door."),
            E(.document, 1, "Bar Tab", "A bar tab from earlier that evening showing four drinks for {VL}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness",
                        direct: ["\"I'd been drinking. I don't want to be here.\""],
                        cross: ["\"I slipped. That's what I'm saying today.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened at the gas station?", "\"We were arguing. I'd had a few drinks. I ended up against the door and cut my lip.\""),
                            .direct("You told the clerk he hit you.", "\"I was upset. I said a lot of things.\""),
                            .direct("Why are you reluctant to testify today?", "\"Because I'm still with him, and I don't want my life in the newspaper.\""),
                            .cross("Did you slip?", "\"I slipped. That's what I'm saying today.\"")
                        ]),
            WitnessSeed(name: nil, role: "Gas station clerk",
                        direct: ["\"She said he hit her and asked me to hide her.\""],
                        cross: ["\"I could smell alcohol on her.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How did {VL} seem when {V.he} came inside?", "\"Bleeding from the mouth, crying, asking if there was somewhere to hide.\""),
                            .direct("What did {V.he} say?", "\"'He hit me. Please don't let him in.' I locked the bathroom door for her and called 911.\""),
                            .direct("What did you see outside afterward?", "\"He came to the door and tried it. It was locked. He left before the police came.\""),
                            .cross("{VL} had been drinking?", "\"I could smell it. She was still clear about what she was saying.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Officer",
                        direct: ["\"The video shows two hands on her shoulders and a shove.\""],
                        cross: ["\"The open door blocks the lower half of the view.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the pump camera show?", "\"Him putting both hands on her shoulders and shoving her back into the open doorframe. Her head snaps back and she turns away holding her mouth.\""),
                            .direct("Where did you find {DL}?", "\"At home, about forty minutes later. He said she fell.\""),
                            .cross("The open door blocks part of the view?", "\"The bottom half of her body. The shove and her head are clear.\""),
                            .cross("You didn't see any punch on video?", "\"No punch. A two-handed shove into a steel doorframe.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["The camera shows the shove. The clerk heard what {V} said while {V.he} was still bleeding."],
        defenseTheory: ["{V} has told this court {V.he} slipped. The State is asking you to disbelieve the only person who was there."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"I just want this to be over.\""],
        allocutions: ["\"I put my hands on her. I've told myself it was a push. It was more than that.\""],
        guiltyTruths: ["{DL} texted {V} the next morning: \"Tell them you fell. You know what happens if they take me again.\""],
        innocentTruths: ["A second camera angle, pulled later, shows {VL} pulling at {DL}'s collar and {DL} pushing {V.him} off, with {VL}'s heel catching the curb as {V.he} fell back."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "hearsayExceptions", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "9:17 p.m.: shove at the pump, on camera."), (0, "9:20 p.m.: {VL} runs inside; clerk calls 911."),
                       (0, "9:23 p.m.: {DL} tries the store door, leaves."), (0, "10:05 p.m.: officers find {DL} at home."), (0, "11:30 p.m.: {VL}'s lip stitched at the ER.")],
            howIdentified: "The clerk's 911 call and the pump camera; {VL} named {DL} that night.",
            defendantExam: [
                .direct("Did you hit {V}?", "\"No. {V.He} was drunk and fell into the door.\""),
                .direct("Why did you leave before the police came?", "\"{V.He} locked {V.him}self in there. I didn't know what to do.\""),
                .cross("The video shows both your hands on {V.his} shoulders.", "\"{V.He} was in my face. I pushed {V.him} back. I didn't mean for {V.him} to hit the door.\""),
                .cross("You tried the locked store door.", "\"I wanted to talk to {V.him}.\"")
            ],
            prosecutionOpening: "A shove on video, and a woman hiding in a gas station bathroom.",
            defenseOpening: "{V} told you what happened: {V.he} slipped.",
            prosecutionClosing: "People recant for many reasons. The camera doesn't.",
            defenseClosing: "The video is partly blocked, and the only person who was there says it was an accident.",
            genders: ["D": .male, "V": .female],
            time: "9:20 p.m.",
            victim: VictimFacts(relationship: "Dating the defendant for four months.", harm: ["Split upper lip, three stitches", "Chipped front tooth"])
        )
    )

    // MARK: - The bartender (communicating threats)

    static let barThreat = CaseTemplate(
        key: "story.followup.barThreat", category: .violent,
        headlines: ["Bartender Says Man Threatened to \"Finish What the Stool Started\"", "Threat Charge After Late-Night Visit to the Loose Caboose"],
        primaryLaw: "communicatingThreats", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Willfully threatened to physically injure {V}, communicating the threat orally in a manner and under circumstances that would cause a reasonable person to believe it was likely to be carried out, and {V} believed it would be.",
        ageRange: 24...50, occupations: [], hasVictim: true,
        summaries: [
            "On {DATE} at about 12:30 a.m., {D} came into the Loose Caboose bar on {STREET}, where {V}, who tended bar on the night of the incident in {PRIOR}, was working. {DL}'s case was in this court in {PRIORDATE}. {V} told officers {DL} leaned over the bar and said, \"You talk to the cops about me again, I'll finish what the stool started, on you.\" {DL} left after {V} picked up the phone to call 911. A regular at the bar heard the words. {DL} says {D.he} came in to say there were no hard feelings and said nothing like that."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Bar Camera", "No audio. 12:29 a.m.: {DL} leans over the bar toward {VL}, points at {V.him}, and leaves at 12:31 as {VL} lifts the phone."),
            E(.digital, 2, "911 Call", "12:31 a.m.: {VL}, voice shaking: \"He just told me he'd finish what the stool started on me.\""),
            E(.statement, 2, "Regular's Statement", "A regular two stools away gave officers the same words that night.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Sober", "{DL} had no drink at the bar and was there two minutes.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Bartender",
                        direct: ["\"He said he'd finish what the stool started, on me.\""],
                        cross: ["\"He didn't have anything in his hands.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did {DL} say to you?", "\"He leaned over the bar and said if I talked to the cops about him again, he'd finish what the stool started, on me.\""),
                            .direct("How did you take it?", "\"I believed him. I've seen what he did with a stool. My hands shook so hard I couldn't dial at first.\""),
                            .direct("What has it done to you?", "\"I don't close alone anymore. I park under the light and someone walks me out.\""),
                            .cross("He had nothing in his hands?", "\"Nothing. He pointed at me.\""),
                            .cross("He left as soon as you picked up the phone?", "\"He did. He was smiling.\"")
                        ]),
            WitnessSeed(name: nil, role: "Regular at the bar",
                        direct: ["\"I heard every word. I was two stools down.\""],
                        cross: ["\"I'd had two beers.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you hear?", "\"'You talk to the cops about me again, I'll finish what the stool started, on you.'\""),
                            .direct("How loud was it?", "\"Low, but the music was off by then. Last call had come and gone.\""),
                            .cross("You'd been drinking?", "\"Two beers in two hours. I heard it fine.\""),
                            .cross("Do you know {DL}?", "\"Only by what happened in the bar that night everybody talks about.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Officer",
                        direct: ["\"Both of them gave me the same words, separately.\""],
                        cross: ["\"There's no audio on the camera.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you take the statements?", "\"Separately. The bartender at the bar, the regular out by my car. Same words.\""),
                            .direct("What does the camera show?", "\"{DL} leaning in, pointing at the bartender, and walking out as the phone comes up. Two minutes total.\""),
                            .cross("No audio on the camera?", "\"No audio.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} went back to the bar to frighten the person who talked to police, and said so."],
        defenseTheory: ["Two minutes, no weapon, no audio, and a bartender with every reason to think the worst of {DL}."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"I pour drinks for a living. I didn't sign up to be afraid of the door.\""],
        allocutions: ["\"I shouldn't have gone back there. I was angry. I won't go back.\""],
        guiltyTruths: ["{DL} had posted that afternoon: \"Gonna pay a visit to the rat at the Caboose.\""],
        innocentTruths: ["The regular later admitted repeating what the bartender told the officer, having heard only mumbling over the ice machine."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "12:29 a.m.: {DL} at the bar."), (0, "12:31 a.m.: {DL} leaves; {VL} calls 911."), (0, "12:45 a.m.: statements taken."), (2, "{DL} charged.")],
            howIdentified: "{VL} knew {DL} from the earlier incident; the bar camera.",
            defendantExam: [
                .direct("Why did you go to the bar?", "\"To say no hard feelings. Clear the air.\""),
                .direct("What did you say?", "\"That I hoped we could move on. Nothing about any stool.\""),
                .cross("You pointed at the bartender.", "\"I talk with my hands.\""),
                .cross("You left the moment the phone came up.", "\"I could see it wasn't going well.\"")
            ],
            prosecutionOpening: "{DL} came back to the bar to tell the bartender what would happen if {V.he} talked to police again.",
            defenseOpening: "A two-minute visit and words no recording captured.",
            prosecutionClosing: "Two people, interviewed apart, gave the same words.",
            defenseClosing: "The bartender fears {DL} because of the past. That fear doesn't prove the words.",
            genders: ["D": .male, "V": .male],
            time: "12:30 a.m."
        )
    )

    // MARK: - The pool cue (assault with a deadly weapon)

    static let poolHallCue = CaseTemplate(
        key: "story.followup.poolHallCue", category: .violent,
        headlines: ["Pool Cue Swung in Billiards Hall Fight", "Second Bar Fight, Second Self-Defense Claim"],
        primaryLaw: "awdw", lesserLaw: "simpleAssault", threshold: 6, lesserThreshold: 4,
        specification: "Assaulted {V} with a deadly weapon, a wooden pool cue, by striking {V.him} across the forearm and shoulder.",
        ageRange: 24...50, occupations: [], hasVictim: true,
        summaries: [
            "On {DATE} at about 11:50 p.m., at Eight Ball Billiards on {STREET}, {D} and {V} argued over a $20 bet on a game. The hall's camera shows {V} jab a finger into {DL}'s chest; {DL} steps back, grips a pool cue by the narrow end, and swings it twice, hitting {V}'s raised forearm and then {V.his} shoulder. {V}'s forearm was bruised but not broken. It came after {DL}'s case in this court in {PRIORDATE} for {PRIOR}. {DL} says {V} had a friend closing in behind {D.him} and {D.he} was outnumbered."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Billiards Hall Camera", "11:49 p.m.: {VL} jabs {DL}'s chest. {DL} steps back, flips a cue to hold the narrow end, and swings twice. {VL}'s friend is about eight feet behind {DL}, standing still with a drink."),
            E(.document, 2, "Urgent Care Record", "A deep bruise to {VL}'s left forearm and right shoulder; X-rays negative."),
            E(.physical, 1, "Pool Cue", "A 19-ounce maple cue with a crack near the butt end.")
        ],
        defenseEvidence: [
            E(.statement, 1, "The Bet", "{VL} owed {DL} $20 from the earlier game, the hall owner confirmed.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness",
                        direct: ["\"I poked his chest. He swung a pool cue at my head.\""],
                        cross: ["\"I owed him twenty bucks.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What was the argument about?", "\"Twenty bucks on a game. He said I owed it. I said I'd pay next week.\""),
                            .direct("What happened next?", "\"I poked him in the chest. He flipped the cue around and swung at my head. I got my arm up.\""),
                            .cross("You poked him first?", "\"With a finger. He came back with a pool cue.\""),
                            .cross("Your friend was behind him?", "\"Across the room, holding a beer. Nowhere near him.\"")
                        ]),
            WitnessSeed(name: nil, role: "Billiards hall owner",
                        direct: ["\"I saw the cue go up from behind the counter.\""],
                        cross: ["\"{VL} started the jabbing.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{VL} poking him, then {DL} grabbing the cue by the thin end and swinging it like a bat. Twice.\""),
                            .direct("Where was {VL}'s friend?", "\"By the jukebox with a drink. Didn't move till it was over.\""),
                            .cross("{VL} owed {DL} money?", "\"Twenty dollars. I heard them settle the bet.\""),
                            .cross("{VL} was the one jabbing?", "\"{VL} started the jabbing. {DL} started the swinging.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Officer",
                        direct: ["\"Two swings, and the friend never moved.\""],
                        cross: ["\"I didn't measure the friend's distance; the floor tiles let me count it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the camera show of the friend?", "\"Standing about eight feet behind {DL}, holding a drink, the whole time.\""),
                            .direct("What did {DL} tell you?", "\"That he thought he was about to be jumped.\""),
                            .cross("How did you measure eight feet?", "\"The floor is one-foot tiles. I counted them on the video.\""),
                            .cross("{VL} did jab my client first?", "\"Yes. A finger to the chest.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["A finger to the chest, and {D} answered with two swings of a pool cue."],
        defenseTheory: ["{DL} was confronted by a man who owed {D.him} money, with that man's friend behind {D.him}."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"My arm was black for two weeks. Over twenty dollars.\""],
        allocutions: ["\"I've got to stop being in places like that. I'm sorry.\""],
        guiltyTruths: ["{DL} told a friend afterward, \"He poked me, so I took a swing. Should've been his head.\""],
        innocentTruths: ["A phone video from another table shows {VL}'s friend setting down the drink and starting toward {DL} just before the first swing, outside the hall camera's frame."],
        moods: [.indifferent], doctrines: ["selfDefense", "burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "11:30 p.m.: game and $20 bet."), (0, "11:49 p.m.: jab and two swings."), (0, "12:02 a.m.: officers arrive."), (1, "{VL} treated at urgent care.")],
            howIdentified: "{DL} was still at the hall when officers arrived; the hall camera.",
            defendantExam: [
                .direct("Why did you swing the cue?", "\"He jabbed me and his buddy was behind me. I thought they were going to jump me.\""),
                .direct("Did you aim for his head?", "\"No. I swung to back him off.\""),
                .cross("The friend never moved from the jukebox.", "\"I couldn't see behind me. I knew he was there.\""),
                .cross("You flipped the cue to hold the thin end.", "\"That's how you hold it to swing it. I wasn't thinking about it.\"")
            ],
            prosecutionOpening: "A finger to the chest, and two swings of a pool cue.",
            defenseOpening: "Two against one, in {DL}'s mind, and a second to act.",
            prosecutionClosing: "The friend was eight feet away holding a drink. A poke doesn't justify a weapon.",
            defenseClosing: "Self-defense is judged by what {DL} reasonably believed, not by what the camera knew.",
            genders: ["D": .male, "V": .male],
            time: "11:50 p.m."
        )
    )

    // MARK: - The checkpoint run (felony speeding to elude)

    static let checkpointRun = CaseTemplate(
        key: "story.followup.checkpointRun", category: .traffic,
        headlines: ["Driver U-Turns at Checkpoint, Runs From Deputy at 85", "Chase Ends in Pasture Fence on Hobbs Creek Road"],
        primaryLaw: "fleeing", lesserLaw: "recklessDriving", threshold: 7, lesserThreshold: 5,
        specification: "Operated a motor vehicle on Hobbs Creek Road while fleeing and attempting to elude a deputy of the Hollis County Sheriff's Office in the lawful performance of duties, while speeding more than 15 mph over the limit and driving recklessly.",
        ageRange: 21...50, occupations: [], hasVictim: false,
        summaries: [
            "On {DATE} at about 11:15 p.m., {D} made a U-turn a hundred yards short of a marked Sheriff's checking station on Hobbs Creek Road. A deputy in a marked patrol car with a light bar followed, lights and siren on. {DL} drove 2.8 miles at up to 85 mph in a 45 and crashed through a pasture fence. {DL} was not impaired; {D.his} breath test was 0.00. {DL} says {D.he} turned around because {D.he} had left {D.his} wallet at home, didn't notice the patrol car behind {D.him} because {D.his} music was loud, and lost control on a curve. This came after {DL}'s case in this court in {PRIORDATE} for {PRIOR}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dash Camera", "A marked patrol car, light bar and siren on from 11:15:40 p.m. The vehicle accelerates away and reaches 85 mph in a 45 on the GPS overlay. It crosses the center line on two curves before going through the fence at 11:18."),
            E(.document, 2, "Pursuit Report", "2.8 miles; top speed 85 in a 45; no other vehicles involved; $1,200 in damage to the pasture fence."),
            E(.physical, 1, "Wallet", "{DL}'s wallet, with license, found in the car's center console during the inventory.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Loud Music", "The car's stereo was found on, at high volume, after the crash.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Deputy who gave chase",
                        direct: ["\"Light bar, siren, and the car took off.\""],
                        cross: ["\"The music was loud when I got to the car. Siren was louder.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What made you follow the car?", "\"A U-turn a hundred yards short of a marked checkpoint, across a double yellow line.\""),
                            .direct("What happened when you turned on your lights?", "\"Light bar and siren from 11:15. The car sped up hard. It hit 85 in a 45 and crossed the center line on two curves.\""),
                            .direct("What did you find in the car?", "\"The wallet with the license, in the center console. And a breath test of 0.00.\""),
                            .cross("The stereo was very loud?", "\"It was. My siren is 120 decibels, and the light bar lights up the whole road.\""),
                            .cross("No one else was hurt?", "\"No one else. There was no traffic at that hour, thankfully.\"")
                        ]),
            WitnessSeed(name: nil, role: "Farmer who owns the pasture",
                        direct: ["\"I heard the siren from my porch, then the fence going.\""],
                        cross: ["\"I didn't see the car until after.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear that night?", "\"A siren coming down Hobbs Creek, a long way off, and an engine really winding. Then the fence snapping.\""),
                            .direct("How far is your porch from the road?", "\"A couple hundred yards. I could hear the siren plain as day.\""),
                            .cross("You didn't see the chase?", "\"Not until the car was in my pasture.\""),
                            .cross("Has the fence been paid for?", "\"Not yet. Twelve hundred dollars.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} turned away from a checkpoint and ran from a marked car with a siren at 85 in a 45."],
        defenseTheory: ["A forgotten wallet, a loud stereo, and a curve. {DL} wasn't fleeing anyone {D.he} knew was there."],
        aggravating: [],
        mitigating: [],
        allocutions: ["\"I knew they were behind me. I panicked. I'm lucky nobody was on that road.\""],
        guiltyTruths: ["{DL}'s phone shows a text sent at 11:16 p.m., during the chase: \"cops on me.\""],
        innocentTruths: ["The car's stereo had failed in a way that locked it at full volume, and a mechanic confirmed the speakers could drown out a siren inside the closed car."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "11:15 p.m.: U-turn short of the checkpoint."), (0, "11:15 p.m.: deputy's lights and siren on."),
                       (0, "11:18 p.m.: car through the pasture fence."), (0, "11:40 p.m.: breath test, 0.00.")],
            howIdentified: "{DL} was in the driver's seat when the car stopped in the pasture.",
            defendantExam: [
                .direct("Why did you turn around?", "\"I thought I'd left my wallet at home. I didn't want a ticket for no license.\""),
                .direct("Did you know the deputy was behind you?", "\"Not until the curve. The music was up.\""),
                .cross("Your wallet was in the console.", "\"I didn't know that then.\""),
                .cross("You hit 85 in a 45 to go home for a wallet?", "\"I was in a hurry. I drive too fast. I know.\"")
            ],
            prosecutionOpening: "A U-turn at a checkpoint, a light bar, a siren, and 85 miles an hour.",
            defenseOpening: "A driver who didn't hear the siren.",
            prosecutionClosing: "A farmer two hundred yards away heard the siren. {DL} was in front of it.",
            defenseClosing: "Speeding isn't eluding unless {DL} knew who was behind.",
            time: "11:15 p.m."
        )
    )

    // MARK: - The trooper's wrist (assault on an officer)

    static let trooperShove = CaseTemplate(
        key: "story.followup.trooperShove", category: .violent,
        headlines: ["Trooper Injured at Traffic Stop on Route 17", "Driver Charged With Shoving Trooper to the Pavement"],
        primaryLaw: "assaultLEO", lesserLaw: "resisting", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V}, a sworn member of the North Carolina State Highway Patrol performing official duties, by shoving {V.him} to the pavement, inflicting physical injury: a fractured left wrist.",
        secondary: [
            SecondaryCharge(lawID: "resisting", specification: "Resisted and delayed {V} by refusing lawful orders to step out of the vehicle and pulling away during the arrest.", chance: 1.0, threshold: 5)
        ],
        ageRange: 21...50, occupations: [], hasVictim: true,
        summaries: [
            "On {DATE} at about 4:40 p.m., Trooper {V} stopped {D} on Route 17 for 74 in a 55. {DL} argued about the ticket and, when the trooper smelled marijuana, refused four orders to step out. When {V} opened the door and took {DL}'s arm, {DL} came out of the car and shoved {V} with both hands; {V} fell backward onto the pavement and fractured {V.his} left wrist. The trooper's body camera and dash camera recorded it. {DL} says the trooper yanked {D.him} out by the arm and {D.he} pushed away by reflex. A search found a small amount of marijuana; {DL} was not charged with it. This came after {DL}'s case in this court in {PRIORDATE} for {PRIOR}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Camera", "Four orders to step out over ninety seconds. The trooper opens the door and takes {DL}'s left arm; {DL} stands and shoves the trooper's chest with both hands. The trooper falls back, catching the fall on the left hand."),
            E(.video, 2, "Dash Camera", "The same shove from behind the trooper's car, showing the trooper's feet leave the ground backward."),
            E(.document, 2, "Medical Record", "A distal radius fracture of the left wrist, cast for six weeks.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Arm Grab", "The body camera shows the trooper's hand closing on {DL}'s arm before the shove.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "State trooper",
                        direct: ["\"Four times I asked. Then two hands in my chest.\""],
                        cross: ["\"Yes, I took the arm. That's how you remove someone who refuses.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Why did you ask {DL} to step out?", "\"I smelled marijuana from the car. I had probable cause to search it.\""),
                            .direct("What happened when you took {DL}'s arm?", "\"{DL} came up out of the seat and shoved me with both hands. I went backward onto the pavement and caught myself on my left hand.\""),
                            .direct("What was the injury?", "\"A broken wrist. Six weeks in a cast, desk duty, and I still can't do a full push-up.\""),
                            .cross("You grabbed my client's arm?", "\"I took the arm after four lawful orders. Firmly, not a yank.\""),
                            .cross("Nothing from the search was charged?", "\"There was a small amount of marijuana. The DA chose not to charge it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Passing motorist",
                        direct: ["\"The trooper went down hard.\""],
                        cross: ["\"I was driving past at maybe forty.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see?", "\"The driver push the trooper, two hands, and the trooper fall back on the shoulder.\""),
                            .direct("What did you do?", "\"I pulled over ahead and called 911 to say a trooper was down.\""),
                            .cross("You were driving by when you saw it?", "\"Slowed down, about forty. I had a clear look through the passenger window.\""),
                            .cross("You didn't see what happened before the push?", "\"No, just the push and the fall.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} refused four lawful orders and shoved a trooper to the pavement hard enough to break a wrist."],
        defenseTheory: ["A trooper grabbed {DL}'s arm and {DL} pulled away by reflex. A reflex is not an assault."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"I've done this job eleven years. I'd never been put on the ground at a traffic stop. I think about it now every time I walk up to a window.\""],
        allocutions: ["\"I was angry about the ticket and I acted like it. I'm sorry, Trooper.\""],
        guiltyTruths: ["{DL} told a cellmate, \"I wasn't going to let that trooper put hands on me again.\""],
        innocentTruths: ["Frame-by-frame review of the body camera shows {DL}'s foot catching the door sill as {D.he} was pulled, and the hands coming up as {D.he} stumbled forward into the trooper."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "4:38 p.m.: stop for 74 in a 55."), (0, "4:40 p.m.: four orders to step out; the shove."), (0, "4:44 p.m.: backup arrives; {DL} arrested."), (0, "6:15 p.m.: trooper's wrist X-rayed.")],
            howIdentified: "{DL} was the driver stopped; the body and dash cameras.",
            defendantExam: [
                .direct("Why didn't you step out?", "\"I didn't think the trooper had a reason. I was arguing about the ticket.\""),
                .direct("Why did you push the trooper?", "\"I got yanked out of my seat. I put my hands up and pushed away. It was a reflex.\""),
                .cross("Both hands, to the chest.", "\"That's where the trooper was.\""),
                .cross("You were told four times.", "\"I know. I should have gotten out.\"")
            ],
            prosecutionOpening: "Four lawful orders, two hands to the chest, and a broken wrist.",
            defenseOpening: "A grab, and a reflex.",
            prosecutionClosing: "The camera shows a shove, not a stumble.",
            defenseClosing: "{DL} was pulled out of a seat. What came next happened in a second.",
            time: "4:40 p.m.",
            victim: VictimFacts(occupation: "Trooper, North Carolina State Highway Patrol", harm: ["Fractured left wrist, six weeks in a cast"])
        )
    )

    // MARK: - The stoplight (felony hit and run)

    static let stoplightRearEnd = CaseTemplate(
        key: "story.followup.stoplightRearEnd", category: .traffic,
        headlines: ["Driver Rear-Ends Car at Light, Drives Off; Dashcam Catches Plate", "Hit-and-Run Leaves Driver With Fractured Spine"],
        primaryLaw: "hitAndRun", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Being the driver of a vehicle involved in a crash at Route 17 and {STREET} that caused serious bodily injury to {V}, and knowing or having reason to know of the crash, willfully failed to stop and remain at the scene.",
        ageRange: 25...65, occupations: [], hasVictim: true,
        summaries: [
            "On {DATE} at about 6:10 p.m., a pickup rear-ended {V}'s sedan while it was stopped at the red light at Route 17 and {STREET}, pushing it into the intersection. The pickup backed up, went around, and drove off. {V} suffered a fractured vertebra. A dashcam in the car behind recorded the pickup's plate, which is registered to {D}. Deputies found the pickup at {DL}'s home that night with a crushed front bumper and the sedan's blue paint on it. {DL} says {D.he} thought it was a light bump, saw {V} wave, and believed {V} was all right. This came after {DL}'s case in this court in {PRIORDATE} for {PRIOR}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dashcam", "The pickup hits the stopped sedan hard enough to push it eight feet into the intersection, backs up, swings around, and leaves. The plate is readable. {VL} does not get out of the car."),
            E(.forensic, 2, "Paint Transfer", "Blue paint on {DL}'s front bumper matches {VL}'s sedan.", .search),
            E(.document, 3, "Medical Record", "A compression fracture of the L1 vertebra; {VL} wore a back brace for three months.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Wave", "{DL} told deputies {VL} waved as the pickup went around.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Driver who was struck",
                        direct: ["\"I couldn't move. I wasn't waving.\""],
                        cross: ["\"I might have lifted a hand. I was trying to get help.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened at the light?", "\"I was stopped at the red. Something slammed into me and threw me into the intersection.\""),
                            .direct("How did you feel right after?", "\"Like my back had been hit with a hammer. I couldn't turn around.\""),
                            .direct("What happened to the other driver?", "\"I heard the engine and saw the truck go around me. Then it was gone.\""),
                            .cross("Did you wave at the pickup?", "\"I might have lifted my hand. I was trying to get someone to stop. Not to say I was fine.\"")
                        ]),
            WitnessSeed(name: nil, role: "Driver whose dashcam recorded the crash",
                        direct: ["\"It hit hard. The sedan went into the intersection.\""],
                        cross: ["\"I couldn't see inside the pickup.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"The pickup didn't slow down. It hit the car in front of it and shoved it into the intersection.\""),
                            .direct("What did the pickup do after?", "\"Backed up, went around, and left. I stayed with the driver of the car and gave the deputies my camera card.\""),
                            .cross("You couldn't see who was driving?", "\"No. I could see the plate. It's on the video.\""),
                            .cross("Was it a light bump?", "\"No. It was loud. Glass came off.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Deputy",
                        direct: ["\"Plate, paint, and a crushed bumper in the driveway.\""],
                        cross: ["\"Yes, {DL} admitted to driving.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where did you find the pickup?", "\"In {DL}'s driveway, about three hours later, with the front bumper crushed and blue paint on it.\""),
                            .direct("What did {DL} say?", "\"That {D.he} was driving and thought it was a small bump, and that the other driver waved.\""),
                            .cross("My client admitted being the driver right away?", "\"Right away. {D.He} said {D.he} didn't think anyone was hurt.\""),
                            .cross("Did {DL} appear impaired?", "\"No. Breath test was 0.00.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} hit a stopped car hard enough to shove it into an intersection, and drove away from a driver who couldn't get out."],
        defenseTheory: ["{DL} thought the bump was small and saw a wave. The law punishes willful leaving, not a mistaken belief."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"Three months in a back brace. I still can't lift my grandson. The person who did it didn't even get out of the truck to look.\""],
        allocutions: ["\"I should have stopped. I told myself it was nothing because I didn't want it to be something.\""],
        guiltyTruths: ["{DL}'s phone shows a search at 6:25 p.m. that night: \"how long do police have to charge hit and run.\""],
        innocentTruths: ["{DL} had a seizure disorder flare that afternoon, later documented by a neurologist, that could explain confusion right after the impact."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(0, "6:10 p.m.: rear-end crash at Route 17 and {STREET}."), (0, "6:11 p.m.: pickup leaves."), (0, "6:30 p.m.: dashcam card given to deputies."),
                       (0, "9:15 p.m.: pickup found in {DL}'s driveway.")],
            howIdentified: "The dashcam recorded the pickup's plate, registered to {DL}.",
            defendantExam: [
                .direct("Why didn't you stop?", "\"I thought it was a bump. I saw a hand go up and figured that meant okay.\""),
                .direct("Did you know anyone was hurt?", "\"No. If I'd known, I'd have stayed.\""),
                .cross("You pushed that car eight feet into an intersection.", "\"It didn't feel like that from inside the truck.\""),
                .cross("Glass came off your bumper.", "\"I didn't see glass.\"")
            ],
            prosecutionOpening: "A crash that shoved a car into an intersection, and a pickup that went around it.",
            defenseOpening: "A driver who thought it was a small bump and saw a wave.",
            prosecutionClosing: "Nobody thinks that's a small bump.",
            defenseClosing: "Willful leaving requires knowing. {DL} believed {V} was fine.",
            time: "6:10 p.m.",
            victim: VictimFacts(age: 62, harm: ["Compression fracture of the L1 vertebra", "Three months in a back brace"])
        )
    )
}
