import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAA: [CaseTemplate] = [taxPreparer, payrollRobbery, toddlerFentanyl, dmvCounter, brakeLines]

    // MARK: - 144. The storefront (a tax preparer and her clients' identities)

    static let taxPreparer = CaseTemplate(
        key: "story.taxPreparer", category: .whiteCollar,
        headlines: ["Tax Preparer Charged With Using Clients' Identities", "Credit Cards Opened in Names of Elderly Customers"],
        primaryLaw: "identityTheft", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Knowingly obtained and used the Social Security number and date of birth of {V}, a client, without consent, to open credit accounts in {V.his} name with the intent to fraudulently represent that {D.he} was {V}.",
        secondary: [
            SecondaryCharge(lawID: "identityTheft", specification: "Knowingly used the identifying information of a second client, {CLIENT2}, to open a credit account without consent.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "cardFraud", specification: "Used a credit card issued in {V}'s name without consent to obtain $7,800 in goods.", chance: 1.0, threshold: 0)
        ],
        ageRange: 30...56, occupations: ["tax preparer"], hasVictim: true,
        summaries: [
            "{D} ran a storefront tax preparation office in {HOOD}. In {DATE}'s credit report, {V}, 79, a client for six years, found three credit cards {V.he} never applied for, with $7,800 in charges at electronics stores. A second client, {CLIENT2}, found a similar account. All the applications used the clients' Social Security numbers and dates of birth exactly as they appeared on the returns {DL} prepared, and listed a mailing address at a post office box rented by {DL}. {DL} says a former employee had access to every client file, and that the post office box was the office's business box."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Credit Applications", "Three applications in {VL}'s name and one in {CLIENT2}'s, all listing a post office box rented by {DL}.", .search),
            E(.document, 3, "Card Statements", "$7,800 in purchases on the {VL} cards at two electronics stores.", .search),
            E(.video, 2, "Store Video", "A person resembling {DL} buying a laptop with one of the cards; partly obscured by a cap.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Former Employee", "Payroll records show a former employee worked at the office during the period and was fired for missing cash."),
            E(.document, 1, "Shared Box", "The post office box received the office's business mail, and two employees had keys.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Tax client",
                        direct: ["\"I never applied for any credit card.\""],
                        cross: ["\"Other people worked in that office.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How long had {DL} prepared your taxes?", "\"Six years. Every spring I gave {D.him} my Social Security number and birth date for the return.\""),
                            .direct("How did you learn about the cards?", "\"My grandson pulled my credit report. Three cards I'd never heard of, and bills for things I'd never bought.\""),
                            .direct("Did you give anyone permission to open those accounts?", "\"No. I never applied for any credit card.\""),
                            .cross("You don't know who actually filled out those applications, do you?", "\"No, I don't.\""),
                            .cross("You dealt with more than one person at the office?", "\"There was a young woman at the front desk some years.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Financial crimes detective",
                        direct: ["\"Every application went to {DL}'s post office box.\""],
                        cross: ["\"Two people had keys to the box.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What information was used on the applications?", "\"The clients' Social Security numbers and dates of birth, exactly as they appeared on the returns {DL} prepared.\""),
                            .direct("Where were the cards mailed?", "\"To a post office box rented in {DL}'s name. Every application used the same box.\""),
                            .direct("What was bought with the cards in {VL}'s name?", "\"$7,800 in purchases at two electronics stores.\""),
                            .cross("The store video doesn't show a clear face, does it?", "\"No. A cap blocks part of it.\""),
                            .cross("The former employee had a key to that box?", "\"Yes. She was fired two months before the last application.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Office receptionist",
                        direct: ["\"The former employee was always in the client files.\""],
                        cross: ["\"I never saw her apply for credit.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What mail came to the post office box?", "\"The office's business mail. Two employees had keys to it.\""),
                            .direct("Who handled the client files?", "\"Everyone, but she stayed late in the file room a lot.\""),
                            .direct("Why did she leave the office?", "\"She was fired for missing cash.\""),
                            .cross("You never saw her open any accounts?", "\"Not once. I just answered phones and sorted mail.\""),
                            .cross("The box itself was rented in {DL}'s name?", "\"Yes, it was in {D.his} name.\"")
                        ])
        ],
        prosecutionTheory: ["{D} prepared these clients' returns, used their numbers to open cards, and had the cards sent to {D.his} own box."],
        defenseTheory: ["A fired employee with the same files and a key to the same box. The video is too blurry to identify anyone."],
        aggravating: ["The victim was very old"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I was paying {D.him} to help me with my taxes.\""],
        allocutions: ["\"I've done honest returns for hundreds of families. I didn't do this.\""],
        guiltyTruths: ["The laptop bought with the card was registered online to {DL}'s nephew the next day."],
        innocentTruths: ["The former employee was later convicted of the same scheme against clients of another tax office."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["CLIENT2": ["Herman Bolick", "Edna Faircloth", "Walter Spruill"]],
        story: StoryExtras(
            timeline: [(-120, "First application in {VL}'s name."), (-90, "Former employee fired."), (-30, "Last application."), (0, "{VL}'s credit report."), (40, "Box rental records subpoenaed; {DL} charged.")],
            howIdentified: "The post office box on every application.",
            notDone: ["The former employee's phone and home were not searched."],
            defendantExam: [
                .direct("Did you open these accounts?", "\"No. I'd never steal from my clients.\""),
                .cross("Every card went to your box.", "\"Our business box. Two of us had keys.\""),
                .cross("The last application came after she was fired.", "\"She still had her key.\"")
            ],
            prosecutionOpening: "The person who held these clients' numbers had the cards mailed to {D.his} box.",
            defenseOpening: "A fired employee had the same files and the same key.",
            prosecutionClosing: "Opportunity, access, and the mailbox all point to {DL}.",
            defenseClosing: "Two keys, two suspects, one blurry video. That's reasonable doubt."
        )
    )

    // MARK: - 145. Payday (a snatch at the plant gate)

    static let payrollRobbery = CaseTemplate(
        key: "story.payrollRobbery", category: .robbery,
        headlines: ["Payroll Bag Snatched at Poultry Plant", "Manager Knocked Down; $9,200 Taken"],
        primaryLaw: "commonLawRobbery", lesserLaw: "misdLarceny", threshold: 8, lesserThreshold: 6,
        specification: "Took $9,200 in cash from the person and presence of {V} by violence and putting {V.him} in fear.",
        secondary: [],
        ageRange: 20...35, occupations: ["former poultry plant worker", "unemployed", "temp worker"], hasVictim: true,
        summaries: [
            "Every other Friday, {V}, an office manager at a poultry processing plant in {HOOD}, carried a bag of cash for workers who were paid in cash. On {DATE}, as {V} walked from the bank to the plant gate, someone in a hooded sweatshirt ran up, shoved {V.him} to the pavement, and grabbed the $9,200 bag. {V} broke {V.his} wrist in the fall. {D}, fired from the plant two months earlier, was identified from the gate camera by a supervisor. {DL} had paid off a $6,000 car loan in cash the next week. {DL} says {D.he} won the money gambling and was not at the plant that day."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Gate Camera", "A hooded figure shoving {VL} and running with the bag; the face is partly visible for one second.", .search),
            E(.statement, 3, "Supervisor's Identification", "A supervisor who worked with {DL} for a year recognized {D.his} build and gait on the video."),
            E(.document, 3, "Car Loan Payoff", "{DL} paid off a $6,000 car loan in cash six days after the robbery.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Casino Records", "A casino player's card in {DL}'s name shows a $4,500 slot win the month before."),
            E(.statement, 1, "Pay Schedule Known Widely", "Every plant worker knew when the payroll cash was carried.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Plant office manager",
                        direct: ["\"They shoved me down and took the bag.\""],
                        cross: ["\"I never saw a face.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What were you doing that morning?", "\"It was a payday Friday. I'd picked up the payroll cash at the bank and was walking it back to the plant gate.\""),
                            .direct("What happened?", "\"I heard running behind me. Two hands hit my back, I went down on my wrist, and the bag was gone.\""),
                            .direct("Were you hurt?", "\"Yes. My wrist broke when I hit the pavement.\""),
                            .cross("You never saw the person's face?", "\"No. Just a gray hood running away.\""),
                            .cross("And everyone at the plant knew which Fridays you carried that bag?", "\"Yes. It was every other Friday, and people knew.\"")
                        ]),
            WitnessSeed(name: nil, role: "Plant supervisor",
                        direct: ["\"I'd know that walk anywhere.\""],
                        cross: ["\"I didn't like {DL} much.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Did you watch the gate camera video after the robbery?", "\"Yes. I watched it two days after.\""),
                            .direct("How did you recognize the person on video?", "\"I worked next to {DL} for a year. The way {D.he} runs, the shoulders, the build. It's {D.him}.\""),
                            .direct("Could you see a face on the video?", "\"Partly, for about a second. It was mostly the build and the way {D.he} moves.\""),
                            .cross("The person in that clip had a hood up?", "\"Yes, the hood was up.\""),
                            .cross("You and {DL} didn't get along?", "\"I wrote {D.him} up twice. That doesn't change what I saw.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Casino host",
                        direct: ["\"{DL} won $4,500 on slots the month before.\""],
                        cross: ["\"Players' cards don't show what they lost.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What is a player's card?", "\"A card players put in the machine so we can track their play and their jackpots.\""),
                            .direct("Is there a player's card in {DL}'s name?", "\"Yes, there is.\""),
                            .direct("What do your records show?", "\"A $4,500 jackpot on {DL}'s player card the month before.\""),
                            .cross("Do the records show losses?", "\"Not reliably. Most people don't win overall.\""),
                            .cross("And $4,500 is less than the $6,000 that paid off the car loan?", "\"Yes, it's less.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew the pay schedule, was recognized on the video, and paid off {D.his} car in cash six days later."],
        defenseTheory: ["Everyone at the plant knew the schedule. A grudge-holding supervisor identified a hood from a one-second clip, and a slot win explains the money."],
        aggravating: [],
        mitigating: ["The defendant was young at the time of the offense"],
        victimImpacts: ["{V}: \"I can't carry the bag anymore. I can't even carry groceries with that hand some days.\""],
        allocutions: ["\"I didn't rob anybody.\""],
        guiltyTruths: ["Bills from the payroll bag, recorded by serial number at the bank, turned up in the car dealer's deposit."],
        innocentTruths: ["Another former worker was caught with the payroll bag and the gray hoodie the following month."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-60, "{DL} fired from the plant."), (0, "8:05 a.m.: payroll bag taken at the gate."), (2, "Supervisor identifies {DL} from video."), (6, "{DL} pays off car loan in cash."), (14, "{DL} charged.")],
            howIdentified: "A supervisor's identification from gate video.",
            notDone: ["The bank's serial-number list for the payroll cash was not compared with the car dealer's deposit."],
            defendantExam: [
                .direct("Where did the car money come from?", "\"A jackpot, and savings.\""),
                .cross("$6,000 in cash six days after the robbery.", "\"I had it saved.\""),
                .cross("You knew exactly when the payroll was carried.", "\"Everybody on the floor knew. It wasn't a secret.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"You wrote {DL} up twice and pushed to have {D.him} fired, didn't you?\"",
                                  answer: "\"I wrote {D.him} up. I didn't decide the firing.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "A witness's hostility toward the defendant is classic bias impeachment and always relevant.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A grudge, a schedule, a familiar run, and a car paid off in cash.",
            defenseOpening: "A one-second clip and a supervisor who wanted {DL} gone.",
            prosecutionClosing: "The jackpot was a month earlier and smaller than the payoff.",
            defenseClosing: "Recognizing a hood isn't identifying a person."
        )
    )

    // MARK: - 146. The nightstand (a toddler finds fentanyl)

    static let toddlerFentanyl = CaseTemplate(
        key: "story.toddlerFentanyl", category: .family,
        headlines: ["Toddler Revived With Narcan After Swallowing Fentanyl", "Parent Charged After Pills Left on Nightstand"],
        primaryLaw: "childAbuseMisd", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Being the parent of {KID}, age two, created a substantial risk of physical injury to the child other than by accidental means, by leaving fentanyl pills within the child's reach.",
        secondary: [
            SecondaryCharge(lawID: "possSchedII", specification: "Possessed fentanyl, a Schedule II controlled substance.", chance: 1.0, threshold: 0)
        ],
        ageRange: 21...35, occupations: ["fast food shift lead", "unemployed", "nail technician"], hasVictim: false,
        summaries: [
            "On {DATE}, {D} called 911 from {D.his} apartment in {HOOD}: {D.his} two-year-old, {KID}, was limp and barely breathing. Paramedics gave three doses of naloxone and {KID} recovered after two days in the pediatric unit; the hospital's urine screen was positive for fentanyl. Deputies found four blue pills on the nightstand beside the bed where {KID} napped, and a pill bottle with no label in a drawer. {DL} says the pills belonged to a houseguest who had stayed the night before, and that {D.he} didn't know they were there."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Hospital Records", "Opioid toxicity confirmed by urine screen positive for fentanyl; three naloxone doses; two days in the pediatric unit."),
            E(.physical, 3, "Pills on Nightstand", "Four blue pills on the nightstand, 18 inches from the bed's edge, testing positive for fentanyl.", .search),
            E(.digital, 2, "Messages", "{DL}'s texts the day before: \"got 10 blues, need anything?\"", .search)
        ],
        defenseEvidence: [
            E(.statement, 2, "Houseguest", "A friend of {DL}'s stayed overnight before the overdose and slept in that bedroom."),
            E(.statement, 1, "Immediate Call", "{DL} called 911 within a minute of finding {KID} limp and did rescue breathing as instructed.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Pediatric emergency physician",
                        direct: ["\"Without naloxone, this child would have died.\""],
                        cross: ["\"The 911 call came quickly.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How serious was {KID}'s condition?", "\"Pinpoint pupils, breathing four times a minute. Without the naloxone, {KID} would have died.\""),
                            .direct("What did the hospital's testing show?", "\"The urine screen was positive for fentanyl, consistent with opioid toxicity.\""),
                            .direct("How did {KID} recover?", "\"After three doses of naloxone, {KID} spent two days in the pediatric unit and went home.\""),
                            .cross("The quick 911 call likely saved {KID}?", "\"Yes. That and the paramedics.\""),
                            .cross("You can't tell us how the pills came to be in that apartment?", "\"No. I can only tell you what was in {KID}'s system.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"Four pills, eighteen inches from the bed.\""],
                        cross: ["\"A houseguest had stayed over.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where were the pills?", "\"On the nightstand, uncovered, eighteen inches from where {KID} napped.\""),
                            .direct("Was anything else found?", "\"A pill bottle with no label, in a drawer.\""),
                            .direct("What did {DL}'s phone show?", "\"A text the day before: 'got 10 blues, need anything?'\""),
                            .cross("A houseguest slept in that room the night before?", "\"So we were told.\""),
                            .cross("And {DL} called 911 within a minute of finding {KID}?", "\"That's my understanding, yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Houseguest",
                        direct: ["\"I stayed there the night before.\""],
                        cross: ["\"Those weren't my pills.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"We're friends.\""),
                            .direct("When did you stay at the apartment?", "\"The night before {KID} got sick. I slept over.\""),
                            .direct("Where did you sleep?", "\"In that bedroom. {DL} slept on the couch with {KID}.\""),
                            .cross("Were the pills yours?", "\"No. I don't touch that stuff.\""),
                            .cross("So you can't tell this jury whose pills those were?", "\"No. All I know is they weren't mine.\"")
                        ])
        ],
        prosecutionTheory: ["{D} had ten fentanyl pills the day before and left four on a nightstand where {D.his} toddler napped."],
        defenseTheory: ["{DL} didn't know the pills were there. The houseguest slept in that room, and {DL} saved {KID}'s life with a fast call."],
        aggravating: ["The victim was very young"],
        mitigating: ["The defendant called for help immediately and rendered aid", "The defendant has entered substance use treatment"],
        allocutions: ["\"I almost lost my baby because of me. I'm in treatment every day now.\""],
        guiltyTruths: ["{DL}'s own drug screen at intake was positive for fentanyl."],
        innocentTruths: ["The houseguest's fingerprints, not {DL}'s, were on the pill bottle in the drawer."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["KID": ["Aiden", "Harper", "Jayden", "Nova"]],
        story: StoryExtras(
            timeline: [(-1, "{DL} texts about \"10 blues.\""), (-1, "Houseguest stays the night."), (0, "2:35 p.m.: 911 call."), (0, "Paramedics give naloxone."), (2, "{KID} discharged; {DL} charged.")],
            howIdentified: "{DL} is the parent and leaseholder.",
            notDone: ["The houseguest's phone was not examined."],
            defendantExam: [
                .direct("Were those your pills?", "\"No. My friend stayed in that room.\""),
                .cross("You texted 'got 10 blues' the day before.", "\"I was asking for my friend.\""),
                .cross("You left your two-year-old to nap in that room.", "\"I didn't know they were there.\"")
            ],
            prosecutionOpening: "Ten blue pills the day before, four on the nightstand, and a toddler who stopped breathing.",
            defenseOpening: "A parent who didn't know, and who saved {D.his} child.",
            prosecutionClosing: "The text says whose pills they were.",
            defenseClosing: "A houseguest's pills in a houseguest's room. The State hasn't proven {DL} knew.",
            residence: "Rents an apartment on {STREET} in {HOOD}."
        )
    )

    // MARK: - 147. The counter (a DMV examiner assaulted)

    static let dmvCounter = CaseTemplate(
        key: "story.dmvCounter", category: .violent,
        headlines: ["DMV Examiner Assaulted Over Failed Road Test", "Customer Charged After Throwing Clipboard, Grabbing Worker"],
        primaryLaw: "assaultGovOfficial", lesserLaw: "simpleAssault", threshold: 7, lesserThreshold: 5,
        specification: "Assaulted {V}, a driver license examiner of the North Carolina Division of Motor Vehicles, while {V.he} was discharging {V.his} official duties, by grabbing {V.him} by the collar and shoving {V.him} against a wall.",
        secondary: [
            SecondaryCharge(lawID: "disorderly", specification: "Disrupted the business of the {HOOD} driver license office by shouting and throwing a clipboard.", chance: 1.0, threshold: 0)
        ],
        ageRange: 19...60, occupations: ["landscaper", "unemployed"], hasVictim: true,
        summaries: [
            "On {DATE}, {D} failed the road test at the {HOOD} driver license office for the third time. Back inside, {DL} threw the score clipboard at the counter, then reached over and grabbed examiner {V} by the collar, pushing {V.him} against the wall behind the counter and shouting that {V.he} was \"rigging it.\" A coworker pulled {DL} away. The lobby camera recorded the incident. {DL} says {D.he} grabbed {VL}'s shirt to keep from falling when {D.he} slipped, and that {D.he} never meant to hurt anyone."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Lobby Camera", "{DL} throws the clipboard, reaches across the counter, grabs {VL} by the collar, and pushes {V.him} back against the wall for about three seconds."),
            E(.statement, 2, "Coworker", "A second examiner pulled {DL}'s arm away from {VL}."),
            E(.document, 1, "Road Test Score Sheet", "{DL}'s third failed road test that month, for rolling a stop sign and failing to yield.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Wet Floor", "It was raining, and the lobby had a wet-floor sign near the counter."),
            E(.document, 1, "Need for License", "A job offer conditioned on {DL} getting a license by the end of the month.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "DMV driver license examiner",
                        direct: ["\"{D.He} grabbed my collar and slammed me into the wall.\""],
                        cross: ["\"The floor was wet in places.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Had you dealt with {DL} before that day?", "\"Yes. {D.He}'d been in for road tests before.\""),
                            .direct("What happened when {DL} came back in?", "\"{D.He} threw the clipboard, then reached across and grabbed my collar and shoved me into the wall, yelling that I was rigging the test.\""),
                            .direct("How long did {D.he} hold you there?", "\"About three seconds, until my coworker pulled {D.his} arm away.\""),
                            .cross("{DL} was upset about failing the test?", "\"Yes, {D.he} was upset.\""),
                            .cross("The floor was wet that day?", "\"By the door. Not at my counter.\"")
                        ]),
            WitnessSeed(name: nil, role: "Second examiner",
                        direct: ["\"I had to pull {D.his} arm off.\""],
                        cross: ["\"It was over in seconds.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see before you stepped in?", "\"{DL} had {VL} by the collar, pushed back against the wall behind the counter.\""),
                            .direct("Was {DL} saying anything?", "\"Yes. {D.He} was shouting that {VL} was rigging it.\""),
                            .direct("What did you do?", "\"I grabbed {DL}'s arm and pulled until {D.he} let go.\""),
                            .cross("How long did it last?", "\"Three, four seconds. It felt longer.\""),
                            .cross("You were watching {DL}'s hands, not {D.his} feet?", "\"Yes. I was watching the hands.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Customer in line",
                        direct: ["\"It looked like {D.he} slipped.\""],
                        cross: ["\"I was looking at my phone at first.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where were you?", "\"Standing in line in the lobby.\""),
                            .direct("What was the floor like that day?", "\"It was raining, and there was a wet-floor sign near the counter.\""),
                            .direct("What did you see?", "\"{D.He} kind of lurched forward at the counter, like {D.he} slipped.\""),
                            .cross("You were on your phone when it started?", "\"Until I heard the clipboard.\""),
                            .cross("So the clipboard was thrown before this lurch you saw?", "\"Yes. The clipboard came first.\"")
                        ])
        ],
        prosecutionTheory: ["{D} failed a test, got angry, and grabbed and shoved a state employee doing {V.his} job."],
        defenseTheory: ["A frustrated customer slipped and grabbed for balance. Frustration isn't an assault."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has expressed remorse"],
        victimImpacts: ["{V}: \"I asked to move to a back office. I don't want to be at that counter anymore.\""],
        allocutions: ["\"I needed that license for a job. I lost my temper. I'm sorry.\""],
        guiltyTruths: ["{DL} posted that night: \"Finally put hands on that DMV clown.\""],
        innocentTruths: ["A second camera angle shows {DL}'s foot sliding on a wet patch at the counter as {D.he} reached forward."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "2:10 p.m.: road test failed."), (0, "2:25 p.m.: incident at the counter."), (0, "2:40 p.m.: officers arrive."), (5, "Video obtained; {DL} charged.")],
            howIdentified: "{DL} was at the counter, and the examiners knew {D.him} from earlier tests.",
            notDone: ["The office's second camera was not reviewed."],
            defendantExam: [
                .direct("Why did you grab {VL}?", "\"I slipped. I grabbed the first thing to keep from falling.\""),
                .cross("You were shouting 'you're rigging it' while you held {V.him} against the wall.", "\"I was upset about the test.\""),
                .cross("You threw the clipboard before you 'slipped.'", "\"I threw it. That part's on me.\"")
            ],
            prosecutionOpening: "A clipboard thrown, a collar grabbed, and a state worker shoved into a wall.",
            defenseOpening: "Frustration and a wet floor.",
            prosecutionClosing: "People who slip don't shout accusations while they hold on.",
            defenseClosing: "Three seconds of a stumble, not an assault.",
            victim: VictimFacts(occupation: "Driver license examiner, N.C. Division of Motor Vehicles")
        )
    )

    // MARK: - 148. The brake lines (a business partner's car)

    static let brakeLines = CaseTemplate(
        key: "story.brakeLines", category: .violent,
        headlines: ["Business Partner Charged With Cutting Brake Lines", "Contractor's Truck Crashes Down Hill; Partner Accused"],
        primaryLaw: "attemptedMurder1", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "With malice, premeditation, and deliberation, attempted to kill {V} by cutting the brake lines of {V.his} truck.",
        secondary: [
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Willfully and wantonly damaged {V}'s pickup truck by cutting its brake lines.", chance: 1.0, threshold: 0)
        ],
        ageRange: 35...60, occupations: ["general contractor", "construction business owner"], hasVictim: true,
        summaries: [
            "{D} and {V} co-owned a construction company in {HOOD}. They were in a bitter dispute over buying each other out, and a $1 million key-person life insurance policy paid the company if either partner died. On {DATE}, {VL}'s pickup lost its brakes at the bottom of a steep hill and crashed into a ditch; {VL} walked away with bruises. A mechanic found both brake lines cut cleanly about two-thirds through, so they would hold at first and fail under hard braking. The company yard's camera shows {DL} beside {VL}'s truck for six minutes the evening before, after hours. {DL} says {D.he} was checking a tool box {VL} had borrowed, and that the lines must have rusted through."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Brake Line Examination", "A forensic engineer finds both lines cut two-thirds through with a sharp tool, edges clean, no corrosion at the cuts."),
            E(.video, 3, "Yard Camera", "{DL} crouched beside {VL}'s truck for six minutes at 7:40 p.m., partly hidden by the cab.", .search),
            E(.document, 2, "Insurance Policy", "A $1 million key-person policy payable to the company, which would pass to the surviving partner under the buy-sell agreement.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Truck Age", "{VL}'s truck was fourteen years old with no record of brake-line replacement."),
            E(.statement, 1, "Tool Box", "{VL} had borrowed {DL}'s tool box, which was in the truck bed that night.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Forensic engineer",
                        direct: ["\"Cut, not rusted. Two-thirds through.\""],
                        cross: ["\"Old lines do corrode.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you examine?", "\"Both brake lines from {VL}'s pickup after the crash.\""),
                            .direct("What caused the brake failure?", "\"Both lines were cut cleanly two-thirds through. A cut like that holds under light braking and bursts under hard braking, like at the bottom of a hill.\""),
                            .direct("How do you know it was a cut?", "\"Clean edges and no corrosion at the cut. That's the mark of a sharp tool.\""),
                            .cross("Fourteen-year-old lines can corrode through?", "\"They can. Corrosion leaves pitting and flaking. These edges were clean.\""),
                            .cross("You can't tell us who made the cuts?", "\"No. Only how they were made.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Business partner",
                        direct: ["\"The pedal went to the floor.\""],
                        cross: ["\"We were fighting over the company.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened on the hill?", "\"The brakes felt fine at the top. At the bottom I pressed and the pedal went to the floor.\""),
                            .direct("What happened next?", "\"The truck went into a ditch. I walked away with bruises.\""),
                            .direct("Does the company carry insurance on your life?", "\"Yes. A million dollars on each partner, paid to the company.\""),
                            .cross("You and {DL} were in a bitter dispute?", "\"Yes. Over money. Not over killing each other.\""),
                            .cross("The company mechanic told you the brakes needed looking at?", "\"Yes. I hadn't gotten to it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Company mechanic",
                        direct: ["\"That truck needed brake work.\""],
                        cross: ["\"I never saw the lines myself.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What do you do for the company?", "\"I keep the company's trucks running.\""),
                            .direct("How old was {VL}'s truck?", "\"Fourteen years, and there's no record of the brake lines ever being replaced.\""),
                            .direct("What was the condition of {VL}'s truck?", "\"Old and overdue. I'd told {VL} the brakes needed looking at.\""),
                            .cross("Did you ever look at the brake lines?", "\"No. Just the pads.\""),
                            .cross("So you can't say whether those lines were rusted or cut?", "\"No, I can't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} stood to gain a million dollars, was caught on camera at {VL}'s truck after hours, and the lines were cut, not worn."],
        defenseTheory: ["An old truck with overdue brakes, and a partner checking on {D.his} own tool box. A grudge isn't an attempted murder."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I drive my kids to school down that hill.\""],
        allocutions: ["\"I didn't touch his truck.\""],
        guiltyTruths: ["A tubing cutter with brake fluid residue was found in {DL}'s home workshop."],
        innocentTruths: ["A disgruntled former employee later admitted cutting the lines to get back at {VL}."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-90, "Buyout dispute begins."), (-1, "7:40 p.m.: {DL} beside {VL}'s truck in the yard."), (0, "7:15 a.m.: brakes fail; crash."), (10, "Forensic examination of the lines."), (30, "{DL} charged.")],
            howIdentified: "The yard camera and the insurance motive.",
            notDone: ["Former employees with access to the yard were not interviewed."],
            defendantExam: [
                .direct("What were you doing at the truck?", "\"Getting my tool box out of the bed. {VL} had borrowed it.\""),
                .cross("Six minutes crouched by the wheel, not the bed.", "\"I dropped my keys.\""),
                .cross("You'd get a million dollars if {VL} died.", "\"The company would. I didn't even think about that.\"")
            ],
            prosecutionOpening: "A million-dollar motive and six minutes crouched at the wheel.",
            defenseOpening: "An old truck and an old feud.",
            prosecutionClosing: "Rust doesn't cut clean, and it doesn't cut both lines the same.",
            defenseClosing: "The camera can't see what {DL}'s hands were doing.",
            genders: ["V": .male]
        )
    )
}
