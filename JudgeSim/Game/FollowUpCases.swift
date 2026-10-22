import Foundation

private typealias E = EvidenceSeed

/// Written cases for someone this court has already judged: a stay-away order broken, worse conduct after the court
/// let a guilty person go, or a new arrest. None has a fixed defendant. Each is cast with the person coming back,
/// the earlier victim where it fits, and {PRIOR} and {PRIORDATE}, the earlier case in this court.
/// They come to the docket only as follow-ups, never in the ordinary rotation.
enum FollowUpCases {
    static let all: [CaseTemplate] = [
        workplaceVisit, newNumber, parkingLotWatch, notesOnTheCar,
        kitchenAgain, hospitalNight, barParkingLot, occupiedHouse, gasStationKnife, secondCrash, overdoseDeath, newMark,
        eludingStop, warehouseTheft, carBreakIns,
        harassAgain, assaultAgain, theftAgain, drugsAgain
    ]

    /// Stay-away order violations: domestic first, then the rest.
    static let domesticViolations = ["story.followup.workplaceVisit", "story.followup.newNumber"]
    static let otherViolations = ["story.followup.parkingLotWatch", "story.followup.notesOnTheCar"]
    /// Whether a follow-up written for people of a certain age fits someone this age (a little older allowed, for the time since).
    static func fits(_ key: String, age: Int) -> Bool {
        guard let t = all.first(where: { $0.key == key }) else { return true }
        return (t.ageRange.lowerBound - 3...t.ageRange.upperBound + 8).contains(age)
    }

    /// New arrests unrelated to the earlier case.
    static let newCharges = ["story.followup.eludingStop", "story.followup.warehouseTheft", "story.followup.carBreakIns",
                             "story.followup.theftAgain", "story.followup.drugsAgain"]

    // MARK: - Stay-away violations

    static let workplaceVisit = CaseTemplate(
        key: "story.followup.workplaceVisit", category: .family,
        headlines: ["Defendant Under Court Order Shows Up at Victim's Job", "Stay-Away Order Broken in Grocery Store Checkout Line"],
        primaryLaw: "stalkingCourtOrder", lesserLaw: "stalking", threshold: 9, lesserThreshold: 7,
        specification: "While a court order prohibiting contact was in effect, engaged in a course of conduct directed at {V}, appearing at {V.his} workplace and following {V.him} to {V.his} car, causing {V.him} to fear for {V.his} safety.",
        secondary: [
            SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened to physically injure {V}, saying, \"You don't get to just erase me. Next time you won't walk to your car,\" in a manner that made {V} believe {D.he} would act on it.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. The judgment ordered {D.him} to have no contact with {V} and to stay away from {V.his} home and work. On {DATE}, {DL} walked into the grocery store in {HOOD} where {V} works as a cashier and got in {V.his} line with a single pack of gum. {V} called the manager. {DL} waited in the parking lot for fifty minutes and followed {V} to {V.his} car when {V.his} shift ended, saying, \"You don't get to just erase me. Next time you won't walk to your car.\" {DL} says {D.he} needed to talk about getting {D.his} belongings back and didn't think a grocery store counted."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Stay-Away Order", "The judgment from {PRIORDATE}, signed by {DL}, ordering no contact with {V} and no presence at {V.his} home or workplace."),
            E(.video, 3, "Store Cameras", "{DL} enters at 4:12 p.m., passes three open registers, and waits in {VL}'s line; a second camera shows {D.him} in the lot until 5:02 p.m."),
            E(.statement, 2, "Manager's Statement", "\"{VL} went white. {V.He} said, 'That's the person from the court case,' and asked me to call the police.\"")
        ],
        defenseEvidence: [
            E(.document, 1, "Text About Belongings", "A text from {DL} to a mutual friend two days earlier asking how to get {D.his} tools back."),
            E(.statement, 1, "Never Touched", "No one saw {DL} touch {V} or block {V.his} car.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s store manager",
                        direct: ["\"{D.He} walked past three open lanes to get in {VL}'s.\""],
                        cross: ["\"I didn't hear what was said in the parking lot.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Three registers open, no lines. {D.He} walked past all of them and stood in {VL}'s line with one pack of gum.\""),
                            .cross("You never heard {DL} threaten anyone inside the store?", "\"No. {D.He} didn't say a word inside. {D.He} just stood there looking at {V.him}.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Domestic violence investigator",
                        direct: ["\"The order was served on {D.him} in court. {D.He} signed it.\""],
                        cross: ["\"{D.He} didn't have a weapon.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Was {DL} aware of the order?", "\"It was entered with {D.his} judgment in open court, and {D.his} signature is on the copy {D.he} received.\""),
                            .cross("{DL} had no weapon when arrested?", "\"No weapon. Just the gum.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Mutual friend",
                        direct: ["\"{D.He} kept asking how to get {D.his} tools back.\""],
                        cross: ["\"I told {D.him} to go through a lawyer.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What had {DL} told you?", "\"That {D.his} tools were still in {VL}'s garage and {D.he} needed them for work.\""),
                            .cross("And you told {D.him} how to get them?", "\"I told {D.him} to go through a lawyer and not to go near {V.him}.\"")
                        ])
        ],
        prosecutionTheory: ["The court told {D} to stay away from {V}'s work. {D.He} went there, waited for {V.him}, followed {V.him} to {V.his} car, and threatened {V.him}."],
        defenseTheory: ["A clumsy attempt to get {D.his} belongings back, in a public store, with no touching. Angry words in a parking lot aren't a true threat."],
        aggravating: [],
        mitigating: ["No physical contact occurred"],
        victimImpacts: ["{VL}: \"I changed my schedule, my route, my phone. {D.He} still found me at work.\""],
        allocutions: ["\"I just wanted my tools. I know I went about it wrong.\""],
        guiltyTruths: ["{DL}'s phone showed searches for {VL}'s work schedule the night before."],
        innocentTruths: ["The store had moved {VL} to a new shift that week; {DL}'s friend had told {D.him} {VL} wouldn't be working."],
        moods: [.wantsConviction], doctrines: ["victimRights", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "4:12 p.m.: {DL} enters the store."), (0, "5:02 p.m.: {DL} follows {VL} to {V.his} car."), (0, "5:20 p.m.: deputies arrest {DL} two blocks away.")],
            howIdentified: "{VL} and the store manager knew {D.him}; cameras confirmed it.",
            notDone: ["No one asked the mutual friend about the tools before charging."],
            defendantExam: [
                .direct("Why did you go to the store?", "\"To ask about my tools. That's all. I didn't think a grocery store was {V.his} workplace in the way the order meant.\""),
                .cross("The order says workplace. You knew {V.he} worked there.", "\"...I knew. Everyone knew where {V.he} worked.\""),
                .cross("You waited in the lot for fifty minutes.", "\"I wanted to talk.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense: \"And {VL} had texted {DL} a month earlier, hadn't {V.he}? So {V.he} didn't really want no contact?\"",
                                  answer: "\"I don't know about any text.\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Relevance: the protected person can't waive the order", shouldSustain: true,
                                  explanation: "Only the court can modify its order. Whether the protected person reached out is not a defense to violating it.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "The court drew a line. {D.He} walked right over it, past three empty registers.",
            defenseOpening: "A pack of gum and a request for tools. Not a threat.",
            prosecutionClosing: "Stay away means stay away.",
            defenseClosing: "Bad judgment isn't stalking.",
            victim: VictimFacts(occupation: "Grocery store cashier")
        )
    )

    static let newNumber = CaseTemplate(
        key: "story.followup.newNumber", category: .family,
        headlines: ["140 Texts From a New Number, Despite Court Order", "Order Said No Contact. The Messages Kept Coming."],
        primaryLaw: "stalkingCourtOrder", lesserLaw: "stalking", threshold: 7, lesserThreshold: 5,
        specification: "While a court order prohibiting contact was in effect, engaged in a course of conduct directed at {V} by sending repeated electronic messages from a number {D.he} bought for the purpose, causing {V.him} substantial emotional distress.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Electronically communicated to {V} repeatedly for the purpose of abusing, annoying, and harassing {V.him}.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, the judgment barred any contact with {V}. Over nine days ending {DATE}, {V} received 140 texts from a number {V.he} didn't recognize: apologies, then accusations, then photographs of {V.his} own front porch. The number traced to a prepaid phone bought at a {HOOD} gas station; the store's camera shows {DL} buying it. {DL} says a friend set up the phone and sent the messages, and that {D.he} never touched it."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Message Log", "140 messages over nine days, including \"I just want you to say you're sorry too\" and three photographs of {VL}'s porch at night.", .search),
            E(.video, 3, "Gas Station Purchase", "{DL} buying a prepaid phone and a $25 card at the counter, paying cash."),
            E(.digital, 2, "Tower Records", "The prepaid phone and {DL}'s own phone hit the same towers, at the same times, on all nine days.", .search)
        ],
        defenseEvidence: [
            E(.statement, 2, "The Friend", "A friend of {DL}'s says {D.he} borrowed the prepaid phone for a few days that week."),
            E(.document, 1, "No Prints", "No usable prints on the prepaid phone recovered from a trash can.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Detective, digital forensics",
                        direct: ["\"The two phones traveled together for nine days.\""],
                        cross: ["\"Tower records show location, not who's typing.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the tower records show?", "\"Every message from the prepaid phone came from a tower the defendant's own phone was using at the same minute. Home, work, the gym. For nine days.\""),
                            .cross("Two phones in the same pocket, or two people standing together, look the same on tower records?", "\"They would. That's why we have the purchase video.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s friend",
                        direct: ["\"I had that phone some of those days.\""],
                        cross: ["\"I don't know {VL}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Did you have the prepaid phone?", "\"Some of those days, yeah. Mine was broken.\""),
                            .cross("Why would you text 140 times to someone you've never met?", "\"I didn't say I sent them all.\"")
                        ])
        ],
        prosecutionTheory: ["{D} bought a phone the court couldn't see and used it to do exactly what the court forbade."],
        defenseTheory: ["Someone else had the phone. Tower records put two phones in the same place, not {D}'s thumbs on the screen."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"Every time my phone buzzes, my heart stops. Every time.\""],
        allocutions: ["\"I needed {V.him} to hear me. I couldn't stand the silence.\""],
        guiltyTruths: ["A draft of message 72 was found in {DL}'s own phone's notes app."],
        innocentTruths: ["The friend's own phone, examined later, held screenshots of the messages being typed."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "victimRights"],
        story: StoryExtras(
            timeline: [(-9, "Prepaid phone bought at a {HOOD} gas station."), (-9, "First message."), (0, "140th message; {VL} goes to the sheriff."), (6, "Tower records returned; {DL} arrested.")],
            howIdentified: "The gas station camera and matching tower records.",
            notDone: ["The friend's phone was not searched."],
            defendantExam: [
                .direct("Did you send those messages?", "\"No. A friend set up that phone and sent them. I never touched it.\""),
                .cross("You bought the phone.", "\"I bought it for my friend.\""),
                .cross("Which ones did you send?", "\"The apologies.\"")
            ],
            prosecutionOpening: "A phone bought with cash, a court order, and 140 messages.",
            defenseOpening: "A borrowed phone and a lot of guessing.",
            prosecutionClosing: "The phones moved together because they were in the same pocket.",
            defenseClosing: "Tower records can't tell you who was typing."
        )
    )

    static let parkingLotWatch = CaseTemplate(
        key: "story.followup.parkingLotWatch", category: .violent,
        headlines: ["Parked Outside, Night After Night, Despite Court Order", "Neighbors Log 11 Nights of a Car Outside a Protected Victim's Home"],
        primaryLaw: "stalkingCourtOrder", lesserLaw: "stalking", threshold: 5, lesserThreshold: 3,
        specification: "While a court order prohibiting contact was in effect, engaged in a course of conduct directed at {V}, repeatedly parking outside {V.his} home at night and following {V.him}, causing {V.him} to fear for {V.his} safety.",
        secondary: [
            SecondaryCharge(lawID: "trespass2", specification: "Entered and remained on the posted property of {V}'s apartment complex after being told to leave.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "When {DL} was sentenced in this court in {PRIORDATE} for {PRIOR}, the judgment ordered {D.him} to stay away from {V}. Starting three weeks before {DATE}, neighbors at {V}'s apartment complex in {HOOD} noticed the same gray sedan parked across from {V.his} building after dark. One wrote down the plate and the times: eleven nights. On {DATE}, the sedan followed {V} out of the lot. It is registered to {DL}. {DL} says {D.he} was visiting a cousin who lives in the next building."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Neighbor's Log", "Eleven handwritten entries: dates, times, \"gray sedan, same plate, engine running.\""),
            E(.video, 2, "Doorbell Camera", "A neighbor's doorbell camera shows the sedan pull out behind {VL}'s car on {DATE}."),
            E(.document, 2, "Trespass Notice", "The complex's written notice barring {DL} from the property, served by a deputy two months earlier.")
        ],
        defenseEvidence: [
            E(.statement, 2, "The Cousin", "{DL}'s cousin lives in the next building and says {DL} visited often."),
            E(.document, 1, "Same Exit", "There is only one exit from the lot, so any car leaving follows any other.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor who kept the log",
                        direct: ["\"Eleven nights. Engine running. Facing {VL}'s door.\""],
                        cross: ["\"I couldn't see the driver's face.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why did you start writing it down?", "\"Because it was always facing {VL}'s door, with the engine running, and nobody ever got out.\""),
                            .cross("You never saw the driver's face?", "\"Not clearly. I saw the plate every time.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s cousin",
                        direct: ["\"{D.He} came by a lot. I live right there.\""],
                        cross: ["\"{D.He} didn't come inside every time.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How often did {DL} visit?", "\"Couple times a week, maybe more.\""),
                            .cross("On the nights the car sat outside with the engine running, did {DL} come into your apartment?", "\"Not every time.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sat outside {V}'s door eleven nights and followed {V.him} out. The court's order existed for exactly this."],
        defenseTheory: ["A cousin in the next building and a parking lot with one exit."],
        aggravating: [],
        mitigating: ["No physical contact occurred"],
        victimImpacts: ["{VL}: \"I sleep at my sister's now. I pay rent on an apartment I'm afraid to go home to.\""],
        allocutions: ["\"I was visiting family. I never meant to scare anybody.\""],
        guiltyTruths: ["The cousin moved out of the complex a month before the first logged night."],
        innocentTruths: ["The cousin's lease and mail confirm the cousin still lived there, with an assigned parking spot facing {VL}'s building."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-21, "First night logged."), (0, "The sedan follows {VL} out of the lot."), (2, "{DL} arrested.")],
            howIdentified: "The plate number in the neighbor's log.",
            notDone: ["No one checked whether the cousin still lived at the complex."],
            defendantExam: [
                .direct("Why were you parked there?", "\"Waiting on my cousin, who works late.\""),
                .cross("Engine running, facing {VL}'s door, eleven nights.", "\"That's where the space was.\"")
            ],
            prosecutionOpening: "Eleven nights in the dark across from the one person the court said to stay away from.",
            defenseOpening: "A cousin, a parking lot, and a neighbor with a notebook.",
            prosecutionClosing: "Visitors get out of the car.",
            defenseClosing: "Proximity isn't a course of conduct."
        )
    )

    static let notesOnTheCar = CaseTemplate(
        key: "story.followup.notesOnTheCar", category: .violent,
        headlines: ["Notes on Windshield, Slashed Tire: Court Order Ignored", "\"I Still See You\": Notes Left on Victim's Car"],
        primaryLaw: "stalkingCourtOrder", lesserLaw: "stalking", threshold: 6, lesserThreshold: 4,
        specification: "While a court order prohibiting contact was in effect, engaged in a course of conduct directed at {V} by leaving written messages on {V.his} car and damaging it, causing {V.him} to fear for {V.his} safety.",
        secondary: [
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Willfully and wantonly slashed a tire on {V}'s car.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "This court ordered {DL} to stay away from {V} in {PRIORDATE}, after {D.his} case for {PRIOR}. Over a month ending {DATE}, {V} found four handwritten notes under {V.his} windshield wiper in the lot where {V.he} works in {HOOD}: \"I still see you,\" \"You did this to me,\" and twice just {V.his} first name. The last morning, a tire was slashed. A handwriting examiner matched the notes to {DL}'s signature on the court's order. {DL} says {D.he} never wrote them."
        ],
        prosecutionEvidence: [
            E(.document, 3, "The Four Notes", "Handwritten on torn notebook paper: \"I still see you.\" \"You did this to me.\" Two with only {VL}'s first name."),
            E(.forensic, 3, "Handwriting Comparison", "A State Crime Laboratory examiner finds the notes were \"highly probably\" written by the person who signed {DL}'s copy of the order."),
            E(.physical, 1, "Slashed Tire", "A single puncture in the sidewall, consistent with a knife.")
        ],
        defenseEvidence: [
            E(.document, 2, "Handwriting Limits", "Handwriting comparison has a significant error rate and is not a quantified science."),
            E(.statement, 1, "Other People", "{VL}'s car sits in a shared lot used by three businesses.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic document examiner",
                        direct: ["\"Highly probable. That's our second-highest level.\""],
                        cross: ["\"It isn't a certainty.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you conclude?", "\"The letter forms, the slant, and the way the writer crosses a 't' match the known signature and writing. I concluded it's highly probable the same person wrote them.\""),
                            .cross("Highly probable is not certain?", "\"No. Certain would be our highest level. I didn't reach it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense handwriting consultant",
                        direct: ["\"Too little known writing to say.\""],
                        cross: ["\"I didn't examine the originals.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What's wrong with the comparison?", "\"One signature and one page of known writing. That's thin for an opinion this strong.\""),
                            .cross("You worked from photocopies?", "\"Photocopies. The originals were in evidence.\"")
                        ])
        ],
        prosecutionTheory: ["{D} kept watching {V} after the court told {D.him} to stop, and left notes to make sure {V.he} knew it."],
        defenseTheory: ["A shared lot, an anonymous note writer, and a handwriting opinion that stops short of certainty."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"'You did this to me.' {D.He} blames me for what this court did.\""],
        allocutions: ["\"I didn't write those notes.\""],
        guiltyTruths: ["A notebook with matching torn edges was found in {DL}'s truck."],
        innocentTruths: ["A coworker of {VL}'s later admitted leaving the notes during a workplace feud."],
        moods: [.wantsConviction], doctrines: ["expertTestimony", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(-30, "First note found."), (0, "Fourth note; tire slashed."), (20, "Handwriting report returned; {DL} arrested.")],
            howIdentified: "Handwriting comparison against {DL}'s signature on the court's order.",
            notDone: ["The lot's single camera was not checked before it recorded over."],
            defendantExam: [
                .direct("Did you write these notes?", "\"No. I haven't been near that lot.\""),
                .cross("\"You did this to me.\" Who else would write that?", "\"Anybody who was there.\"")
            ],
            prosecutionOpening: "Four notes in {D.his} handwriting, on the car of the person the court protected.",
            defenseOpening: "Handwriting comparison is an opinion, not a fingerprint.",
            prosecutionClosing: "\"You did this to me.\" Only one person had that grudge.",
            defenseClosing: "Highly probable isn't beyond a reasonable doubt."
        )
    )

    // MARK: - Worse, after the court let a guilty person go

    static let kitchenAgain = CaseTemplate(
        key: "story.followup.kitchenAgain", category: .family,
        headlines: ["Back in Court, Same Kitchen, Same Victim", "Strangulation Charge Months After Earlier Case"],
        primaryLaw: "strangulation", lesserLaw: "simpleAssault", threshold: 9, lesserThreshold: 7,
        specification: "Assaulted {V} and inflicted physical injury by strangulation.",
        secondary: [],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}, with {V} as the complaining witness. On {DATE}, deputies were called to the home in {HOOD} the two share again. {V} had red marks across {V.his} throat, a hoarse voice, and burst blood vessels in one eye. {V.He} told the deputy {DL} pinned {V.him} against the kitchen counter by the neck over a phone bill. At trial, {V} says {V.he} fell against the counter and doesn't want to testify against {D.him}."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Forensic Nurse Exam", "Petechiae in the left eye, a linear abrasion on both sides of the neck, voice changes, and pain swallowing."),
            E(.video, 3, "Body Camera", "A deputy's camera captures {VL}, crying and hoarse, saying \"{D.He} had me by the throat against the counter.\""),
            E(.document, 2, "911 Call", "A neighbor's call: \"There's screaming next door, and then it just stopped.\"")
        ],
        defenseEvidence: [
            E(.statement, 2, "Recantation", "{VL} now says {V.he} slipped and hit {V.his} neck on the counter edge."),
            E(.document, 1, "Kitchen Photos", "The counter has a rounded edge at about neck height when kneeling.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic nurse examiner",
                        direct: ["\"Petechiae in the eye come from pressure on the neck, not a bump.\""],
                        cross: ["\"A hard fall can bruise a neck.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What do burst blood vessels in the eye tell you?", "\"Blood couldn't leave the head. That's pressure around the neck. A fall against a counter bruises one spot; it doesn't do that.\""),
                            .cross("A hard fall against an edge can bruise the neck?", "\"One side, in one place. Not both sides.\"")
                        ]),
            WitnessSeed(name: nil, role: "Responding deputy",
                        direct: ["\"{V.He} said {D.he} had {V.him} by the throat.\""],
                        cross: ["\"{V.He} has since said {V.he} fell.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {VL} tell you that night?", "\"Hoarse, crying: '{D.He} had me by the throat against the counter.' It's on my camera.\""),
                            .cross("{VL} has told you since that {V.he} fell?", "\"{V.He} has. That's common in these cases.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness, called by the defense",
                        direct: ["\"I fell. I was upset that night and said things.\""],
                        cross: ["\"I don't want {D.him} to go to prison.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened that night?", "\"We argued. I slipped and hit the counter. I was upset and I said things to the deputy.\""),
                            .cross("You've been through this before, in this courtroom.", "\"...Twice now. Same courtroom.\"")
                        ])
        ],
        prosecutionTheory: ["The second time is the most dangerous time. The marks on {V}'s neck and {V.his} words that night tell what happened, whatever {V.he} says now."],
        defenseTheory: ["The only person who was there says {V.he} fell. The State is prosecuting a family that doesn't want this."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I don't want to talk about it.\""],
        allocutions: ["\"I'm getting help this time. I mean it.\""],
        guiltyTruths: ["A text {VL} sent {V.his} sister that night read: \"{D.He} did it again. I couldn't breathe.\""],
        innocentTruths: ["A visiting relative later told police {VL} had fallen while reaching for a cabinet, and the marks came from a necklace caught as {V.he} fell."],
        moods: [.wantsConviction], doctrines: ["victimRights", "hearsayExceptions"],
        story: StoryExtras(
            timeline: [(0, "Neighbor calls 911."), (0, "Deputy's body camera interview of {VL}."), (1, "Forensic nurse exam."), (40, "{VL} signs a statement recanting.")],
            howIdentified: "{VL}'s statement on the deputy's body camera.",
            notDone: ["{VL}'s phone was not examined."],
            defendantExam: [
                .direct("Did you put your hands on {VL}'s neck?", "\"No. {V.He} fell. We were arguing and {V.he} slipped.\""),
                .cross("This is the second time {VL} has been the victim in a case against you.", "\"{V.He} isn't a victim. {V.He} told you that.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Deputy, what did {VL} say to you that night?\"",
                                  answer: "\"'{D.He} had me by the throat against the counter.'\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: false,
                                  explanation: "Said moments after the attack, while still crying and hoarse, it is an excited utterance (Rule 803(2)), and statements to an officer responding to an ongoing emergency are generally not testimonial.",
                                  doctrineID: "hearsayExceptions", weight: 2))
            ],
            prosecutionOpening: "Burst blood vessels don't recant.",
            defenseOpening: "The only witness says {V.he} fell.",
            prosecutionClosing: "Listen to {V.him} that night, not after.",
            defenseClosing: "The State wants you to believe {VL} except when {V.he} disagrees with them."
        )
    )

    static let hospitalNight = CaseTemplate(
        key: "story.followup.hospitalNight", category: .family,
        headlines: ["Victim Hospitalized; Defendant Was Before Same Court Months Ago", "Skillet Assault Sends Victim to Trauma Unit"],
        primaryLaw: "awdwisi", lesserLaw: "aisi", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon, a cast-iron skillet, inflicting serious injury.",
        secondary: [],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "In {PRIORDATE}, {DL} came through this court on a charge of {PRIOR} involving {V}. On {DATE}, {V} arrived at the emergency room in {HOOD} with a fractured cheekbone and a cut above {V.his} eye that took nine stitches. {V.He} told the triage nurse {DL} hit {V.him} with a cast-iron skillet. A skillet with blood on its edge was in the sink when deputies arrived; {DL} was gone. {DL}, arrested two days later, says {V} came at {D.him} first and {D.he} swung to defend {D.himself}."
        ],
        prosecutionEvidence: [
            E(.document, 3, "ER Records", "Fractured left zygoma, 4 cm laceration closed with 9 sutures. Patient states: \"{DL} hit me with a frying pan.\""),
            E(.physical, 3, "The Skillet", "A 12-inch cast-iron skillet with {VL}'s blood on the rim, recovered from the kitchen sink.", .search),
            E(.statement, 2, "Flight", "{DL} left before deputies arrived and turned off {D.his} phone for two days.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Scratches", "{DL} had scratches on {D.his} forearm when booked."),
            E(.document, 1, "Prior Call", "A neighbor once called police about {VL} yelling at {DL}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Emergency physician",
                        direct: ["\"A fractured cheekbone takes real force.\""],
                        cross: ["\"I can't say who swung first.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Is this a serious injury?", "\"A displaced facial fracture with risk to the eye. Yes. Serious.\""),
                            .cross("You can't tell the court who struck first?", "\"No. I can tell you what a skillet does to a face.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Booking officer",
                        direct: ["\"{D.He} had scratches on {D.his} arm.\""],
                        cross: ["\"Two days after the fight.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you note at booking?", "\"Three parallel scratches on the left forearm.\""),
                            .cross("Booking was two days later?", "\"That's right.\"")
                        ])
        ],
        prosecutionTheory: ["{D} hit {V} in the face with a skillet, ran, and hid for two days. Self-defense doesn't look like that."],
        defenseTheory: ["{V} attacked first; {D} grabbed what was in reach. Scratches don't lie."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I have metal plates in my face. I still flinch when someone raises a hand.\""],
        allocutions: ["\"{V.He} was coming at me. I didn't mean for it to be that bad.\""],
        guiltyTruths: ["A neighbor's doorbell camera audio caught {DL} shouting \"Look what you made me do\" as {D.he} left."],
        innocentTruths: ["{VL}'s blood alcohol at the hospital was 0.21, and {V.his} own statement that night began \"I went after {D.him} first.\""],
        moods: [.wantsConviction], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "{VL} arrives at the ER."), (0, "Deputies find the skillet; {DL} is gone."), (2, "{DL} arrested at a relative's home.")],
            howIdentified: "{VL}'s statement to the triage nurse.",
            notDone: ["No knife or other weapon {VL} might have held was looked for."],
            defendantExam: [
                .direct("Why did you swing the skillet?", "\"{V.He} was clawing at me. I grabbed the first thing I touched.\""),
                .cross("Then you ran and turned off your phone for two days.", "\"I panicked.\"")
            ],
            prosecutionOpening: "Cast iron, a fractured face, and a defendant who ran.",
            defenseOpening: "Scratches on {D.his} arm, and a fight {D.he} didn't start.",
            prosecutionClosing: "People defending themselves call 911. They don't hide.",
            defenseClosing: "The State can't disprove self-defense, and it has to."
        )
    )

    static let barParkingLot = CaseTemplate(
        key: "story.followup.barParkingLot", category: .violent,
        headlines: ["Bar Fight Leaves Stranger With Brain Bleed", "Months After Earlier Case, Defendant Charged in Parking-Lot Beating"],
        primaryLaw: "awdwisi", lesserLaw: "aisi", threshold: 6, lesserThreshold: 4,
        specification: "Assaulted {V} with a deadly weapon, a beer bottle, inflicting serious injury.",
        secondary: [],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "Months after {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} was at a bar in {HOOD} on {DATE} when an argument over a pool table spilled into the parking lot. {V}, who had never met {DL}, was struck in the head with a bottle and fell against the curb. {V.He} spent five days in the hospital with a brain bleed. A witness says {DL} swung the bottle without warning; {DL} says {V} had a pool cue and was swinging it at {D.him}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Parking Lot Camera", "Grainy footage: two figures face off; one swings a bottle; the other drops. The pool cue is not visible.", .search),
            E(.forensic, 3, "Bottle and Prints", "A broken bottle neck with {DL}'s fingerprint, recovered beside the curb."),
            E(.document, 2, "Medical Records", "Subdural hematoma; five days in the trauma unit.")
        ],
        defenseEvidence: [
            E(.physical, 2, "Pool Cue", "A pool cue was found in the lot, though no one saw who carried it out."),
            E(.statement, 1, "Bartender", "The bartender cut {VL} off for being aggressive an hour earlier.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Bar patron",
                        direct: ["\"{VL} was walking away when {D.he} swung.\""],
                        cross: ["\"I'd had a few drinks.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{VL} said something, turned to walk off, and {DL} came up and swung the bottle at {V.his} head.\""),
                            .cross("You'd been drinking for three hours?", "\"Yes. I saw it anyway.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Bartender",
                        direct: ["\"I cut {VL} off. {V.He} was looking for a fight.\""],
                        cross: ["\"I was inside when it happened.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why did you stop serving {VL}?", "\"{V.He} was getting in people's faces at the pool table.\""),
                            .cross("You didn't see the parking lot?", "\"No. I was behind the bar.\"")
                        ])
        ],
        prosecutionTheory: ["{D} hit someone who was walking away, with a glass bottle. That's not self-defense."],
        defenseTheory: ["An aggressive drunk with a pool cue, and a split-second reaction."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I still lose words in the middle of sentences. I went out to play pool.\""],
        allocutions: ["\"I thought {V.he} was going to hit me with that cue.\""],
        guiltyTruths: ["A second camera angle, recovered later, shows the pool cue still leaning inside the door when the bottle was swung."],
        innocentTruths: ["A patron's phone video, found later, shows {VL} swinging the cue at {DL}'s head first."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "11:40 p.m.: argument at the pool table."), (0, "11:52 p.m.: the bottle swung in the lot."), (1, "{DL} identified from prints.")],
            howIdentified: "A fingerprint on the bottle and the patron's identification.",
            notDone: ["No one asked other patrons for phone video."],
            defendantExam: [
                .direct("Why did you swing the bottle?", "\"{V.He} had the cue up. I thought I was about to get my head split.\""),
                .cross("The camera doesn't show a cue.", "\"The camera's not good enough to show a lot of things.\"")
            ],
            prosecutionOpening: "Someone walking away, and a bottle to the back of the head.",
            defenseOpening: "A drunk with a pool cue, and a split second.",
            prosecutionClosing: "{VL} was walking away.",
            defenseClosing: "The law doesn't make you wait to get hit."
        )
    )

    static let occupiedHouse = CaseTemplate(
        key: "story.followup.occupiedHouse", category: .property,
        headlines: ["Family Asleep as Burglar Climbed Through Window", "Earlier Case, Now a Nighttime Break-In With People Home"],
        primaryLaw: "burglary1", lesserLaw: "burglary2", threshold: 7, lesserThreshold: 5,
        specification: "In the nighttime, broke and entered the occupied dwelling of {V} with the intent to commit larceny therein.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Took a laptop, jewelry, and a handgun from {V}'s home.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} was arrested for a break-in on {DATE} in {HOOD}. At about 3 a.m., {V} woke to a noise downstairs while {V.his} two children slept. By the time {V.he} reached the kitchen, the back window was open and a laptop, jewelry box, and a handgun from a closet shelf were gone. Two days later {DL} tried to sell the jewelry at a pawn shop. {DL} says {D.he} bought it from a man at a gas station and never went inside the house."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Pawn Ticket", "{DL}'s ID and thumbprint on a ticket for three rings and a necklace, two days after the break-in."),
            E(.forensic, 2, "Window Print", "A partial palm print on the outside of the kitchen window matches {DL}."),
            E(.statement, 2, "{VL}'s Account", "\"I heard the window, then footsteps, then the back door. My kids were upstairs.\"")
        ],
        defenseEvidence: [
            E(.statement, 2, "The Seller", "{DL} says {D.he} bought the jewelry for $60 from a man at a gas station."),
            E(.document, 1, "Partial Print", "The palm print had only eight comparison points.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"My children were asleep upstairs.\""],
                        cross: ["\"I never saw the person.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you hear?", "\"The window slide, footsteps across the kitchen, then the back door. My kids were asleep right above it.\""),
                            .cross("You never saw who it was?", "\"No. Thank God.\"")
                        ]),
            WitnessSeed(name: nil, role: "Latent print examiner",
                        direct: ["\"The palm print is {DL}'s.\""],
                        cross: ["\"Eight points is enough for our standard.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Whose print was on the window?", "\"I identified it to {DL}'s right palm.\""),
                            .cross("Only eight points?", "\"Our standard is quality, not a count. It was verified by a second examiner.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Gas station clerk",
                        direct: ["\"People sell stuff out of their trunks there.\""],
                        cross: ["\"I never saw {DL} buy anything.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Do people sell things in your lot?", "\"All the time. I run them off when I see them.\""),
                            .cross("Did you see {DL} buy jewelry that week?", "\"Nothing like that. Gas, cigarettes, a lottery ticket.\"")
                        ])
        ],
        prosecutionTheory: ["{D}'s palm on the window and {D.his} thumb on the pawn ticket. {D.He} went in while a family slept."],
        defenseTheory: ["Buying stolen jewelry at a gas station is foolish; it isn't burglary. A partial print doesn't put {D.him} inside."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"My son sleeps in my room now. The gun is still out there.\""],
        allocutions: ["\"I bought that jewelry. I didn't go in anybody's house.\""],
        guiltyTruths: ["The missing handgun was recovered months later in a car {DL} had sold."],
        innocentTruths: ["The man who sold the jewelry at the gas station was arrested later with the laptop and the gun."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "About 3:00 a.m.: break-in while {VL} and the children sleep."), (2, "{DL} pawns the jewelry."), (5, "Print identified; {DL} arrested.")],
            howIdentified: "The pawn database flagged the jewelry; the palm print followed.",
            notDone: ["The gas station's camera was not checked for the claimed sale."],
            defendantExam: [
                .direct("Where did you get the jewelry?", "\"A guy at the gas station on the highway. Sixty dollars.\""),
                .cross("And your palm print on the window?", "\"I don't know how it got there.\"")
            ],
            prosecutionOpening: "A family asleep upstairs, and {D.his} palm on the window.",
            defenseOpening: "A bad purchase at a gas station is not a burglary.",
            prosecutionClosing: "{D.His} hand was on that window in the middle of the night.",
            defenseClosing: "Eight points and a pawn ticket don't put {D.him} inside."
        )
    )

    static let gasStationKnife = CaseTemplate(
        key: "story.followup.gasStationKnife", category: .robbery,
        headlines: ["Clerk Held at Knifepoint; Defendant Was Recently Before Same Judge", "Knife to the Clerk's Neck for $340"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 7, lesserThreshold: 5,
        specification: "Took $340 from the person and presence of {V} by the use of a dangerous weapon, a knife, whereby {V.his} life was threatened.",
        secondary: [],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. On {DATE}, a person in a gray hooded sweatshirt walked into a gas station in {HOOD}, came around the counter, held a folding knife to clerk {V}'s neck, and took $340 from the register. {V} picked {DL} from a photo lineup the next day. A gray hoodie with a small cut in the pocket was found in {DL}'s car. {DL} says {D.he} was at home and the hoodie is a common one."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Store Camera", "A hooded figure behind the counter with a knife at the clerk's neck; the face is partly covered.", .search),
            E(.statement, 3, "Photo Lineup", "{VL} picked {DL} from a six-person array run by an officer who didn't know the suspect: \"That's the one. I'll never forget the eyes.\""),
            E(.physical, 2, "Hoodie", "A gray hoodie with a cut in the right pocket where a folding knife clip would sit.", .search)
        ],
        defenseEvidence: [
            E(.statement, 2, "At Home", "{DL}'s roommate says {D.he} was home watching a game."),
            E(.document, 1, "Common Hoodie", "The same hoodie is sold at three stores in the county.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Gas station clerk",
                        direct: ["\"The knife was right here, under my jaw.\""],
                        cross: ["\"The hood was up.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("How close was the person?", "\"Close enough to smell. The knife was under my jaw. I looked at the eyes the whole time.\""),
                            .cross("The hood was up and the lower face was covered?", "\"Yes. The eyes weren't.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s roommate",
                        direct: ["\"We were watching the game.\""],
                        cross: ["\"I fell asleep at halftime.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where was {DL} that night?", "\"On the couch with me watching the game.\""),
                            .cross("The whole game?", "\"...I fell asleep around halftime.\"")
                        ])
        ],
        prosecutionTheory: ["{V} looked into those eyes from six inches away, and {D.his} hoodie was in {D.his} car."],
        defenseTheory: ["A hooded, masked robber, a frightened clerk, and a hoodie half the county owns."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I quit. I can't work a register anymore.\""],
        allocutions: ["\"I didn't rob anybody.\""],
        guiltyTruths: ["{DL}'s phone was at the gas station's tower at the time of the robbery."],
        innocentTruths: ["The same robber hit another store a week later while {DL} was in jail."],
        moods: [.wantsConviction], doctrines: ["eyewitnessID", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "10:48 p.m.: robbery."), (1, "Photo lineup; {VL} identifies {DL}."), (3, "Hoodie found in {DL}'s car.")],
            howIdentified: "{VL}'s photo lineup identification.",
            notDone: ["{DL}'s phone location was not requested."],
            defendantExam: [
                .direct("Where were you that night?", "\"Home. Watching the game.\""),
                .cross("Your roommate fell asleep at halftime.", "\"I didn't.\"")
            ],
            prosecutionOpening: "Six inches from a knife, {V} memorized the eyes.",
            defenseOpening: "A covered face and a common sweatshirt.",
            prosecutionClosing: "{V.He} didn't hesitate in the lineup.",
            defenseClosing: "Certainty isn't accuracy.",
            residence: "Shares an apartment with a roommate in {HOOD}.",
            alibiCheck: AlibiCheck(holds: AlibiCheck.Finding(title: "Phone and Streaming Records", detail: "{DL}'s phone stayed on the apartment's Wi-Fi through the whole evening and streamed the second half of the game, start to finish, during the time of the robbery.", kind: .digital),
                                   breaks: AlibiCheck.Finding(title: "Phone Location Records", detail: "{DL}'s phone left the apartment's Wi-Fi at halftime, connected to the tower beside the gas station at the time of the robbery, and was back home twenty minutes later.", kind: .digital))
        )
    )

    static let secondCrash = CaseTemplate(
        key: "story.followup.secondCrash", category: .traffic,
        headlines: ["Driver Kills Motorcyclist Months After Earlier Case", "Impaired Driver Runs Red Light; Rider Dies"],
        primaryLaw: "felonyDBV", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Unintentionally caused the death of {V} while driving while impaired, the impaired driving being the proximate cause of the death.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly through a red light at 58 mph in a 35 zone.", chance: 1.0, threshold: 0)
        ],
        ageRange: 21...65, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. Shortly before midnight on {DATE}, {D.his} pickup ran a red light in {HOOD} at 58 mph and struck {V}, a 34-year-old nurse riding a motorcycle home from a shift. {V} died at the scene. {DL}'s blood alcohol, drawn under a warrant two hours later, was 0.13. {DL} says the light was yellow and {V} entered the intersection too fast."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Blood Alcohol", "0.13 grams per 100 milliliters, drawn under a warrant two hours after the crash; the analyst estimates 0.16 at the time."),
            E(.video, 3, "Intersection Camera", "The signal for {DL}'s direction had been red for 2.4 seconds when the pickup entered.", .search),
            E(.document, 2, "Crash Data Recorder", "The pickup was traveling 58 mph with no braking in the five seconds before impact.", .search)
        ],
        defenseEvidence: [
            E(.document, 1, "Motorcycle Speed", "The reconstructionist estimates the motorcycle at 41 mph in a 35 zone."),
            E(.statement, 1, "Retrograde Doubts", "Extrapolating blood alcohol backward depends on assumptions about when drinking stopped.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Highway Patrol crash reconstructionist",
                        direct: ["\"Red for 2.4 seconds. No brakes.\""],
                        cross: ["\"The motorcycle was six over.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What caused this crash?", "\"The pickup entered on a light that had been red for 2.4 seconds, at 58, without braking. At the speed limit and sober, the driver would have stopped.\""),
                            .cross("The motorcycle was speeding too?", "\"Six over. It didn't cause the pickup to run the light.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense toxicologist",
                        direct: ["\"Back-calculation is an estimate.\""],
                        cross: ["\"0.13 two hours later is still over the limit.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Can anyone say what the level was at the crash?", "\"Only estimate it, based on assumptions.\""),
                            .cross("0.13 two hours later is impaired under the law regardless?", "\"At 0.13, the law says impaired. I don't dispute that.\"")
                        ])
        ],
        prosecutionTheory: ["{D} came through this court once already. {D.He} drank, drove, and ran a red light into {V}."],
        defenseTheory: ["A tragic crash with a speeding motorcycle. The State's alcohol math is an estimate."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}'s mother: \"{V.He} spent twelve hours keeping strangers alive. {V.He} was ten minutes from home.\""],
        allocutions: ["\"I would trade places with {V.him}. I mean that.\""],
        guiltyTruths: ["A bar receipt showed six drinks ordered on {DL}'s card in the two hours before the crash."],
        innocentTruths: ["The signal controller was later found to have a timing fault at that intersection that night."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "11:51 p.m.: crash."), (0, "1:50 a.m.: blood drawn under a warrant."), (30, "Lab result; charges filed.")],
            howIdentified: "{DL} was the driver at the scene.",
            notDone: ["The signal controller's logs were not pulled."],
            defendantExam: [
                .direct("Was the light red?", "\"It was yellow when I looked.\""),
                .cross("You'd been drinking.", "\"I'd had a couple.\"")
            ],
            prosecutionOpening: "Red for 2.4 seconds. No brakes. A nurse on {V.his} way home.",
            defenseOpening: "A terrible crash with two drivers going too fast.",
            prosecutionClosing: "Sober, {D.he} stops.",
            defenseClosing: "Estimates aren't proof beyond a reasonable doubt.",
            victim: VictimFacts(age: 34, occupation: "Nurse")
        )
    )

    static let overdoseDeath = CaseTemplate(
        key: "story.followup.overdoseDeath", category: .drugs,
        headlines: ["Overdose Death Traced to Dealer Before This Court Last Year", "Fentanyl Death Charge: \"It Was Supposed to Be Percocet\""],
        primaryLaw: "deathByDistribution", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Unlawfully sold a mixture containing fentanyl to {V}, and the ingestion of the substance caused {V.his} death.",
        secondary: [
            SecondaryCharge(lawID: "pwisd", specification: "Possessed fentanyl with the intent to sell or deliver.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...60, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. On {DATE}, {V}, 22, was found dead in {V.his} bedroom in {HOOD}. Beside {V.him} were two blue pills stamped like Percocet that turned out to be fentanyl. {V.His} phone showed a conversation that afternoon with a contact saved as \"{DL} plug\": \"two blues?\" \"40, outside in 10.\" A search of {DL}'s apartment found 61 identical pills. {DL} says {D.he} sold {V} Percocet, not fentanyl, and didn't know the pills were fake."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "The Messages", "\"two blues?\" \"40, outside in 10.\" Sent from {DL}'s number to {VL} at 3:12 p.m.", .search),
            E(.forensic, 3, "Toxicology and Pills", "Fentanyl in {VL}'s blood at a lethal level; the remaining pills and the 61 seized from {DL} are chemically identical.", .search),
            E(.physical, 2, "Apartment Search", "61 pressed pills, a digital scale, and $2,100 in cash.", .search)
        ],
        defenseEvidence: [
            E(.statement, 2, "Didn't Know", "{DL} says {D.he} believed the pills were real Percocet."),
            E(.document, 1, "Other Sources", "{VL}'s phone showed contacts with two other suppliers that month.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"Fentanyl toxicity. Nothing else in {V.his} system could have killed {V.him}.\""],
                        cross: ["\"I can't tell you where {V.he} got it.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What caused {VL}'s death?", "\"Fentanyl toxicity. The level was lethal on its own.\""),
                            .cross("You can't say which seller the fentanyl came from?", "\"No. The lab matched the pills.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Defense pharmacologist",
                        direct: ["\"Counterfeit pills look exactly like the real thing.\""],
                        cross: ["\"The law doesn't require knowing it's fentanyl.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Could a seller tell these were fake?", "\"Not by looking. They're pressed with the same markings.\""),
                            .cross("Selling a controlled substance that kills someone is enough under the statute?", "\"That's my understanding of the statute.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sold {V} two pills that afternoon, and they killed {V.him}. The statute doesn't ask what {D.he} thought {D.he} was selling."],
        defenseTheory: ["{V} had other sources. The State can't prove these were the pills."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}'s father: \"{V.He} was eleven weeks sober. {V.He} thought it was one Percocet.\""],
        allocutions: ["\"I didn't know they were fake. I swear to God.\""],
        guiltyTruths: ["{DL} had texted another buyer that week: \"these are the strong ones, go slow.\""],
        innocentTruths: ["A second supplier admitted delivering pills to {VL} later that evening."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "3:12 p.m.: messages exchanged."), (0, "3:24 p.m.: {DL}'s car on a neighbor's camera outside {VL}'s house."), (0, "That evening: {VL} found dead."), (9, "Search warrant executed at {DL}'s apartment.")],
            howIdentified: "The messages on {VL}'s phone.",
            notDone: ["The two other suppliers in {VL}'s phone were not interviewed."],
            defendantExam: [
                .direct("Did you sell {VL} those pills?", "\"Two Percocets. That's what I thought they were.\""),
                .cross("You had 61 of the same pills at home.", "\"Same batch. I didn't know.\"")
            ],
            prosecutionOpening: "Two blue pills for forty dollars, and a twenty-two-year-old who never woke up.",
            defenseOpening: "Other sellers, the same pills, and a lot of assumptions.",
            prosecutionClosing: "The pills beside {V.him} match the pills in {D.his} apartment.",
            defenseClosing: "Matching batches don't tell you who handed {V.him} those two.",
            residence: "Rents an apartment on {STREET} in {HOOD}."
        )
    )

    static let newMark = CaseTemplate(
        key: "story.followup.newMark", category: .whiteCollar,
        headlines: ["Widow Loses Savings to 'Helper' Previously Before Same Court", "Exploitation Charge: Neighbor Drained Account Over Months"],
        primaryLaw: "exploitationElder", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "While in a position of trust with {V}, an older adult, knowingly by deception obtained and used {V.his} funds with intent to permanently deprive {V.him} of them.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $9,500 from {V} by falsely representing it would pay for a roof repair.", chance: 1.0, threshold: 0)
        ],
        ageRange: 20...65, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. Over the following months {D.he} befriended {V}, 81, a widow living alone in {HOOD}: running errands, driving {V.him} to appointments, and eventually helping with {V.his} mail and bills. By {DATE}, $38,000 had left {V.his} account in checks written to {DL}, including $9,500 for a roof repair that was never done. {DL} says {V} gave {D.him} the money freely and that the roof money went to a contractor who disappeared."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Records", "Fourteen checks to {DL} totaling $38,000 over seven months, several in handwriting that is not {VL}'s.", .search),
            E(.document, 2, "No Roof Work", "{VL}'s roof has no new shingles; no contractor pulled a permit."),
            E(.statement, 2, "Memory Evaluation", "{VL}'s doctor documented moderate cognitive decline four months before the first check.")
        ],
        defenseEvidence: [
            E(.document, 2, "Thank-You Card", "A card from {VL}: \"For everything you do. I don't know what I'd do without you.\""),
            E(.statement, 1, "The Contractor", "{DL} names a contractor who can't be found.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Bank fraud investigator",
                        direct: ["\"Several checks are in a different hand.\""],
                        cross: ["\"{VL} signed some of them.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the checks show?", "\"Fourteen checks to {DL}. Eight are filled out entirely in a hand that isn't {VL}'s; {V.he} only signed them.\""),
                            .cross("{VL} signed every one?", "\"{V.He} signed them. Whether {V.he} understood them is another question.\"")
                        ]),
            WitnessSeed(name: nil, role: "{VL}'s physician",
                        direct: ["\"{V.He} couldn't manage {V.his} own finances.\""],
                        cross: ["\"{V.He} had good days.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was {VL}'s condition?", "\"Moderate cognitive decline. I recommended someone else handle {V.his} finances.\""),
                            .cross("{V.He} had lucid days?", "\"Some. Not enough to manage a checkbook.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s neighbor",
                        direct: ["\"{DL} was over there every day helping.\""],
                        cross: ["\"I don't know anything about the checks.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{DL} brought groceries, mowed the yard, drove {V.him} to church.\""),
                            .cross("You don't know anything about the checks?", "\"I wouldn't know a thing about {V.his} checkbook.\"")
                        ])
        ],
        prosecutionTheory: ["{D} found a lonely widow with a failing memory and a checkbook, and emptied it."],
        defenseTheory: ["Gifts from a grateful friend, and a contractor who skipped town."],
        aggravating: ["The victim was mentally infirm"],
        mitigating: [],
        victimImpacts: ["{VL}'s daughter: \"Mama's in a nursing home on Medicaid now. That was her house money.\""],
        allocutions: ["\"I loved that lady. She wanted me to have it.\""],
        guiltyTruths: ["{DL} had opened a second bank account in {VL}'s name and was the only signer."],
        innocentTruths: ["The missing contractor was later arrested in South Carolina with {VL}'s $9,500 check endorsed to him."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-100, "First check to {DL}."), (0, "{VL}'s daughter finds the bank statements."), (45, "Bank investigation complete; charges filed.")],
            howIdentified: "{VL}'s daughter reviewed the bank statements.",
            notDone: ["The contractor {DL} named was never searched for."],
            defendantExam: [
                .direct("Did {VL} give you that money?", "\"{V.He} insisted. {V.He} said {V.his} kids never came around.\""),
                .cross("You filled out eight of those checks yourself.", "\"{V.His} hands shook. {V.He} asked me to.\"")
            ],
            prosecutionOpening: "Fourteen checks, a failing memory, and a roof that was never fixed.",
            defenseOpening: "A friend who showed up when family didn't.",
            prosecutionClosing: "Gratitude doesn't fill out its own checks.",
            defenseClosing: "Generosity isn't a crime.",
            genders: ["V": .female]
        )
    )

    // MARK: - Back on something new

    static let eludingStop = CaseTemplate(
        key: "story.followup.eludingStop", category: .traffic,
        headlines: ["Chase Through Neighborhood at 90 MPH", "Driver Previously Before This Court Flees Traffic Stop"],
        primaryLaw: "fleeing", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "While fleeing a law enforcement officer in the lawful performance of duties, operated a motor vehicle at more than 15 mph over the limit and recklessly.",
        secondary: [
            SecondaryCharge(lawID: "resisting", specification: "Resisted and delayed the arresting officer by running on foot after the car stopped.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...60, occupations: [], hasVictim: false,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. On {DATE}, a deputy tried to stop {D.his} car in {HOOD} for an expired tag. {DL} accelerated, ran two stop signs, and reached 90 mph on a 45 mph road before spinning into a ditch and running into the woods, where {D.he} was caught ten minutes later. {DL} says {D.he} panicked because {D.he} thought there was a warrant out for {D.him}."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dash Camera", "Four minutes of pursuit: two stop signs run, the speedometer overlay reaching 90 in a 45 zone.", .search),
            E(.video, 2, "Body Camera", "The foot chase into the woods and the arrest.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Panic", "{DL} believed there was an outstanding warrant and says {D.he} acted out of fear.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Pursuing deputy",
                        direct: ["\"Ninety in a forty-five, through two stop signs.\""],
                        cross: ["\"The stop was for an expired tag.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What happened when you lit the car up?", "\"It accelerated. Two stop signs, ninety in a forty-five, until it went in the ditch.\""),
                            .cross("All this over an expired tag?", "\"That's what the stop was for. The chase was the defendant's choice.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["An expired tag turned into a 90 mph chase through a neighborhood because {D} chose to run."],
        defenseTheory: ["Fear, not malice. No one was hurt."],
        aggravating: [],
        mitigating: ["No one was injured"],
        victimImpacts: [],
        allocutions: ["\"I panicked. I thought I was going back to jail.\""],
        guiltyTruths: ["There was no warrant; {DL} had a bag of pills in the car {D.he} threw into the woods."],
        innocentTruths: ["A records error had in fact listed an old warrant under {DL}'s name that night."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Stop attempted for an expired tag."), (0, "Four-minute pursuit."), (0, "Foot chase; arrest.")],
            howIdentified: "Caught at the scene.",
            notDone: [],
            defendantExam: [
                .direct("Why did you run?", "\"I thought there was a warrant. I panicked.\""),
                .cross("Ninety miles an hour past houses with kids in them.", "\"I wasn't thinking.\"")
            ],
            prosecutionOpening: "An expired tag. Ninety miles an hour.",
            defenseOpening: "Panic is not a plan.",
            prosecutionClosing: "The dash camera is the case.",
            defenseClosing: "Nobody was hurt."
        )
    )

    static let warehouseTheft = CaseTemplate(
        key: "story.followup.warehouseTheft", category: .property,
        headlines: ["Warehouse Worker Charged in Theft of Power Tools", "Pallets of Tools Walk Out the Back Door"],
        primaryLaw: "felonyLarceny", lesserLaw: "misdLarceny", threshold: 7, lesserThreshold: 5,
        specification: "Took and carried away power tools valued at $6,400, the property of {V}'s company, intending to permanently deprive the owner of them.",
        secondary: [],
        ageRange: 18...62, occupations: [], hasVictim: true,
        summaries: [
            "Months after {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} took a job on the night shift at a building-supply warehouse in {HOOD} owned by {V}. Over three weeks ending {DATE}, $6,400 in cordless drills and saws disappeared from the receiving dock. A camera shows {DL} loading boxes into {D.his} trunk at 2 a.m. twice; several of the tools were then listed for sale online. {DL} says the boxes were damaged returns a supervisor told {D.him} to throw away."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Dock Camera", "{DL} carrying boxes from the receiving dock to {D.his} trunk at 2:04 a.m. on two nights.", .search),
            E(.digital, 2, "Online Listings", "Seven tools with matching serial numbers listed for sale on a marketplace account linked to {DL}'s email.", .search),
            E(.document, 2, "Inventory Audit", "$6,400 in tools missing from received shipments over three weeks.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Damaged Returns", "{DL} says a supervisor told {D.him} to toss damaged boxes."),
            E(.document, 1, "Return Policy", "The company does throw out some damaged returns.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Warehouse owner",
                        direct: ["\"Nothing on that dock was damaged. It was new stock.\""],
                        cross: ["\"We do throw some things away.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Were those damaged returns?", "\"No. New stock, received that week, still sealed.\""),
                            .cross("You do throw away damaged returns?", "\"In the dumpster. Not into an employee's trunk.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} loaded new tools into {D.his} trunk at 2 a.m. and sold them online."],
        defenseTheory: ["A night-shift worker following a supervisor's instructions about damaged boxes."],
        aggravating: ["The defendant took advantage of a position of trust"],
        mitigating: [],
        victimImpacts: ["{VL}: \"Small business. I gave {D.him} a chance when nobody else would.\""],
        allocutions: ["\"I needed the money. I know that's not an excuse.\""],
        guiltyTruths: ["No supervisor was on duty either night."],
        innocentTruths: ["The night supervisor admitted telling {DL} to take the boxes and later selling some {D.himself}."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-21, "First shortage noticed."), (0, "Audit complete; dock video reviewed."), (6, "Online listings matched by serial number.")],
            howIdentified: "Dock camera and the serial numbers in the online listings.",
            notDone: ["The night supervisor was not interviewed."],
            defendantExam: [
                .direct("Why were you loading boxes into your car?", "\"My supervisor said they were damaged returns, to get rid of them.\""),
                .cross("And then you sold them online.", "\"They worked fine. Seemed like a waste.\"")
            ],
            prosecutionOpening: "New tools, an empty dock, and {D.his} online store.",
            defenseOpening: "Following instructions isn't stealing.",
            prosecutionClosing: "Damaged returns don't sell online with their serial numbers.",
            defenseClosing: "The State never asked the supervisor.",
            employer: "a building-supply warehouse in {HOOD}"
        )
    )

    static let carBreakIns = CaseTemplate(
        key: "story.followup.carBreakIns", category: .property,
        headlines: ["Car Break-Ins at Apartment Complex; Suspect Known to Court", "Window Punch, Grab, Run: Six Cars in One Night"],
        primaryLaw: "breakingVehicle", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Broke and entered a motor vehicle belonging to {V}, containing goods and things of value, with intent to commit larceny therein.",
        secondary: [
            SecondaryCharge(lawID: "misdLarceny", specification: "Took a laptop bag and a wallet from {V}'s car.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...55, occupations: [], hasVictim: true,
        summaries: [
            "{DL} was in this courtroom in {PRIORDATE} on a charge of {PRIOR}. Early on {DATE}, six cars were broken into at an apartment complex in {HOOD}. {V}'s car window was punched out with a spark-plug chip and {V.his} laptop bag and wallet taken. An hour later {V}'s debit card was declined at a gas station where the camera caught {DL} at the counter. {DL} says {D.he} found the wallet on the sidewalk and was going to turn it in."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Gas Station Camera", "{DL} trying {VL}'s debit card twice at 4:41 a.m.", .search),
            E(.physical, 2, "Spark Plug Chips", "Ceramic chips in {DL}'s jacket pocket when arrested.", .search),
            E(.document, 2, "Card Declines", "{VL}'s bank shows two declined attempts at the gas station at 4:41 a.m.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Found Wallet", "{DL} says {D.he} found the wallet on a sidewalk.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Car owner",
                        direct: ["\"My window was in pieces on the seat.\""],
                        cross: ["\"I didn't see who did it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you find that morning?", "\"Glass all over the seat and my laptop bag gone, wallet with it.\""),
                            .cross("You didn't see who broke in?", "\"No. I saw who used my card.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} broke into the car, took the wallet, and tried the card within the hour, with the window-breaking tool still in {D.his} pocket."],
        defenseTheory: ["Using a found card is wrong. It isn't breaking into a car."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"My work laptop. I almost lost my job over it.\""],
        allocutions: ["\"I found that wallet. I shouldn't have tried the card.\""],
        guiltyTruths: ["The laptop bag was found in a dumpster behind {DL}'s building."],
        innocentTruths: ["Another man was arrested the next week with the other five victims' property and spark-plug chips."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "About 3:30 a.m.: six cars broken into."), (0, "4:41 a.m.: {VL}'s card declined twice."), (2, "{DL} arrested.")],
            howIdentified: "Gas station video of the card attempts.",
            notDone: ["The other five break-ins were not tied to anyone."],
            defendantExam: [
                .direct("Where did you get the wallet?", "\"On the sidewalk by the bus stop.\""),
                .cross("With spark-plug chips in your pocket.", "\"I don't know how those got there.\"")
            ],
            prosecutionOpening: "A broken window, a stolen card, and the tool in {D.his} pocket.",
            defenseOpening: "A found wallet and a bad decision.",
            prosecutionClosing: "Nobody finds spark-plug chips.",
            defenseClosing: "Trying a card isn't breaking a window."
        )
    )
}
