import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials shared by many cases: someone this court already judged, charged again with the same kind of
/// conduct. Each is a complete new incident written out in full; the earlier case appears only as {PRIOR} and
/// {PRIORDATE}, and the earlier victim only where the trial is written about the same person. Alternate answers
/// change the wording, never the facts, so no two witnesses can contradict each other.
extension FollowUpCases {

    // MARK: - Harassment again (the same person)

    static let harassAgain = CaseTemplate(
        key: "story.followup.harassAgain", category: .violent,
        headlines: ["Accused Again: Messages and a Car Outside the Same Home", "Same Defendant, Same Target, Deputies Say"],
        primaryLaw: "stalking", lesserLaw: "cyberstalking", threshold: 7, lesserThreshold: 5,
        specification: "Willfully engaged in a course of conduct directed at {V}, without legal purpose, that would cause a reasonable person to fear for {V.his} safety and caused {V.him} substantial emotional distress.",
        ageRange: 19...70, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V} told deputies on {DATE} that it had started again. Over three weeks, {V} received 61 messages from two new social media accounts with no names, and a car like {DL}'s was parked across from {V}'s home on three nights, recorded by {V}'s doorbell camera. Records obtained by warrant put {DL}'s phone within a block of {V}'s home on all three nights. {DL} says {D.he} lives two miles away, drives that road to work, and had nothing to do with the accounts."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Message Log", "61 messages over three weeks from two unnamed accounts, including \"you think the last time ended anything?\" and a photo of {VL}'s front door taken at night.", .search),
            E(.video, 3, "Doorbell Video", "A dark sedan parked across from {VL}'s home for more than an hour on three nights, engine running, between 11 p.m. and 1 a.m."),
            E(.digital, 3, "Phone Location Records", "{DL}'s phone connected to the tower serving {VL}'s street on all three nights, at the times the sedan is on video.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Commute Route", "{DL}'s workplace is reached most directly by the road that passes {VL}'s street."),
            E(.digital, 2, "No Subscriber Match", "The platform's records show both accounts were created through a VPN; neither is registered to {DL}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness",
                        direct: ["\"It was the same car, the same hour, the same feeling.\""],
                        cross: ["\"I never saw who was in the car.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("When did the messages start?", "\"About three weeks before I called the sheriff. Two accounts, no names, no pictures.\"", "\"Three weeks before I called. Two new accounts with no names on them.\""),
                            .direct("What did they say?", "\"That the last time didn't end anything. Then a picture of my front door, at night.\"", "\"One said 'you think the last time ended anything?' Then one was just a picture of my door, at night.\""),
                            .direct("What did your doorbell camera show?", "\"A dark car across the street with the engine running. Three nights. Over an hour each time.\""),
                            .cross("You never saw who was driving that car?", "\"No. It was dark. I saw the car.\"", "\"I couldn't see inside it. I could see the car.\""),
                            .cross("Lots of people own a dark sedan?", "\"Sure. Not lots of people park outside my house at midnight.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"The phone was there every night the car was.\""],
                        cross: ["\"I can't tie the accounts to a name.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did the location records show?", "\"The defendant's phone on the tower that serves that street, all three nights, during the hour the car is on video.\""),
                            .direct("Could the commute explain that?", "\"Not at midnight, for an hour, three times. The commute is a two-minute drive past.\"", "\"Driving past takes two minutes. This was an hour, around midnight, three nights.\""),
                            .cross("You couldn't tie either account to my client?", "\"No. Both were made through a VPN.\"", "\"The platform gave us a VPN address. That's where it stopped.\""),
                            .cross("A tower covers a lot of houses?", "\"It does. It covers that street, and the phone was on it.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} came back: messages from accounts with no names, and a car outside {VL}'s home at midnight with {DL}'s phone inside it."],
        defenseTheory: ["A common car, a commute route, and anonymous accounts nobody can tie to {DL}. The earlier case made {DL} the easy answer."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I thought the court case was the end of it. I sleep with the lights on again.\""],
        allocutions: ["\"I know how this looks because of the last time. I'm asking you to look at what's actually here.\""],
        guiltyTruths: ["A search of {DL}'s laptop later found the login for both accounts saved in the browser."],
        innocentTruths: ["The sedan was traced to a neighbor's adult son who worked nights and parked there to sleep."],
        moods: [.divided], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(-21, "First message from an unnamed account."), (-12, "Sedan on doorbell video, first night."), (-3, "Sedan on video, third night."),
                       (0, "{VL} reports to deputies."), (14, "Phone location records returned."), (20, "{DL} charged with stalking.")],
            howIdentified: "{VL}'s report, the doorbell video, and the phone location records.",
            notDone: ["No one ran the sedan's plate; the video never caught it clearly."],
            defendantExam: [
                .direct("Were you outside that house those nights?", "\"I drive that road to work. I didn't park there. I don't go near that house.\"", "\"I drive past on the way to work. I never stopped there.\""),
                .direct("Did you make those accounts?", "\"No. I don't even use that app.\""),
                .cross("Your phone sat on that tower for an hour, three nights.", "\"I can't explain the phone. I can tell you I wasn't parked there.\"", "\"I don't know what the phone did. I know where I was.\""),
                .cross("At midnight, on your way to work?", "\"Some nights I can't sleep and I drive.\"")
            ],
            prosecutionOpening: "The same person, the same house, and a phone that was there every night the car was.",
            defenseOpening: "The State has a common car and a tower that covers a whole neighborhood. It has nothing tying {DL} to a single message.",
            prosecutionClosing: "Three nights, an hour each, midnight. That isn't a commute.",
            defenseClosing: "The earlier case is why {DL} is here. It isn't proof of anything that happened this time."
        )
    )

    // MARK: - Assault again (someone new)

    static let assaultAgain = CaseTemplate(
        key: "story.followup.assaultAgain", category: .violent,
        headlines: ["Gas Pump Argument Ends With a Broken Eye Socket", "Back in Court After a Punch at the Pump"],
        primaryLaw: "aisi", lesserLaw: "simpleAssault", threshold: 7, lesserThreshold: 4,
        specification: "Assaulted {V} and inflicted serious injury, a fractured orbital bone.",
        ageRange: 19...65, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} was arrested on {DATE} at a gas station in {HOOD}. {V}, who had never met {DL}, says {DL} cut ahead of {V.him} for a pump, the two argued, and {DL} punched {V.him} once in the face, breaking the bone around {V.his} eye. The station's camera shows the argument and the punch but not the few seconds before it, when {DL} says {V} stepped toward {D.him} holding a tire gauge."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Station Camera", "{DL} and {VL} arguing at pump 4; {DL} throws one punch; {VL} falls against the pump. The frames just before the punch are blocked by a delivery truck."),
            E(.document, 3, "ER Records", "A fracture of the orbital floor around {VL}'s left eye, repaired with surgery two days later."),
            E(.statement, 2, "Clerk's Statement", "The clerk saw the argument through the window and says {VL} was \"backing up, hands down\" when the punch landed.")
        ],
        defenseEvidence: [
            E(.physical, 2, "Tire Gauge", "A metal tire gauge recovered from the ground beside pump 4."),
            E(.statement, 1, "Defendant's Account", "{DL} told the deputy {VL} stepped toward {D.him} with something metal in {V.his} hand.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Assault victim",
                        direct: ["\"I said it was my pump. Next thing I was on the ground.\""],
                        cross: ["\"I was holding my tire gauge. I was checking my tires.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened at the pump?", "\"I was waiting for pump 4. The defendant pulled in ahead of me. I said that was my pump. We argued. Then I was on the ground.\"", "\"I'd been waiting for pump 4 and the defendant cut in. I said something, we argued, and then I was on the ground.\""),
                            .direct("What were your injuries?", "\"The bone under my eye broke. They put a plate in two days later. I still see double when I'm tired.\""),
                            .cross("You had a metal tire gauge in your hand?", "\"I'd been checking my tires. I wasn't holding it like anything.\"", "\"I was checking my tires while I waited. It was just in my hand.\""),
                            .cross("You stepped toward my client?", "\"I don't think so. I might have. I was mad.\"")
                        ]),
            WitnessSeed(name: nil, role: "Gas station clerk",
                        direct: ["\"The other one was backing up when the punch came.\""],
                        cross: ["\"I was looking through the window, about forty feet.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Two people yelling at pump 4. Then one punch. The one who got hit was backing up, hands down.\"", "\"Yelling at pump 4, then a punch. The one who got hit was stepping back with their hands down.\""),
                            .cross("You were inside, looking through the window?", "\"Yes, about forty feet. Through the glass.\""),
                            .cross("The delivery truck blocked part of your view?", "\"For a second or two, before the punch. Not the punch itself.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} cut in line, lost an argument, and broke a stranger's eye socket with one punch."],
        defenseTheory: ["{VL} came at {DL} with a metal gauge in the seconds the camera can't see. {DL} threw one punch to stop it."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{VL}: \"I don't go to that station anymore. I don't argue with anybody anymore. I just leave.\""],
        allocutions: ["\"I thought I was about to get hit. I know I hit harder than I needed to.\""],
        guiltyTruths: ["The delivery driver later said {VL} never moved toward {DL}; the gauge was at {VL}'s side the whole time."],
        innocentTruths: ["The delivery driver later said {VL} lunged at {DL} with the gauge raised, just before the punch."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "Argument and punch at pump 4; {DL} arrested at the scene."), (2, "{VL}'s surgery."), (9, "Station video reviewed.")],
            howIdentified: "Arrested at the scene by the responding deputy.",
            notDone: ["The delivery truck's driver was never interviewed."],
            defendantExam: [
                .direct("Why did you punch {VL}?", "\"{VL} came at me with something metal in {V.his} hand. I thought I was about to get hit.\"", "\"I saw metal in {V.his} hand coming at me. I swung first.\""),
                .direct("Did you know it was a tire gauge?", "\"Not then. I found out at the jail.\""),
                .cross("You cut ahead of {VL} for the pump.", "\"I didn't see anybody waiting. I said that.\""),
                .cross("Given what happened in your earlier case, you knew how fast a fight can go wrong.", "\"That's why I hit once and stopped.\"")
            ],
            prosecutionOpening: "One punch, a stranger, a broken eye socket, over a gas pump.",
            defenseOpening: "The camera misses the two seconds that matter. In those two seconds, {VL} came forward with a piece of metal.",
            prosecutionClosing: "The clerk saw {VL} backing up, hands down. That's not someone attacking.",
            defenseClosing: "Fear of a metal object coming at your face is reasonable, even over something as small as a gas pump."
        )
    )

    // MARK: - Theft again (a new employer)

    static let theftAgain = CaseTemplate(
        key: "story.followup.theftAgain", category: .whiteCollar,
        headlines: ["Voided Sales, Missing Cash at Farm Supply Store", "New Job, Same Kind of Charge"],
        primaryLaw: "embezzlement", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Being an employee of {V}'s store, fraudulently converted to {D.his} own use $2,900 in cash entrusted to {D.him} in that capacity.",
        ageRange: 19...65, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D.he} took a job as a cashier at a farm supply store in {HOOD} owned by {V}. Over six weeks ending {DATE}, the register on {DL}'s shifts recorded 47 voided cash sales totaling $2,900, most within a minute of the customer leaving. The store camera shows {DL} folding bills into {D.his} apron pocket after two of the voids. {DL} says other cashiers knew {D.his} login and that the pocketed money was {D.his} own change."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Register Void Report", "47 voided cash sales on {DL}'s login over six weeks, totaling $2,900. Voids on other cashiers' logins in the same period: 6."),
            E(.video, 3, "Register Camera", "After two of the voids, {DL} folds bills from the drawer and puts them in an apron pocket."),
            E(.document, 2, "Drawer Counts", "{DL}'s drawer balanced at the end of each shift; the voided sales left no cash shortage behind.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Shared Login", "A former coworker says cashiers sometimes used whoever's login was open when the store was busy."),
            E(.document, 1, "Personal Cash", "{DL} carried personal cash in the apron for lunch, by {D.his} account.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Store owner",
                        direct: ["\"Forty-seven voids on one login. Six on everyone else's.\""],
                        cross: ["\"People did share logins sometimes when it got busy.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did the void report show?", "\"Forty-seven voided cash sales on one login in six weeks. Everyone else together had six.\"", "\"Forty-seven voids on the defendant's login. The rest of my cashiers had six between them.\""),
                            .direct("Why does a void matter if the drawer balances?", "\"Because the drawer balances by design. Ring it up, the customer pays, void it, take the cash. Nothing's short.\""),
                            .cross("Your cashiers shared logins when the store was busy?", "\"Sometimes, on a Saturday. Not forty-seven times on a Tuesday afternoon.\""),
                            .cross("You gave my client a job knowing about the earlier case?", "\"I did. I believe in second chances. I still do.\"")
                        ]),
            WitnessSeed(name: nil, role: "Loss prevention auditor",
                        direct: ["\"Most voids came within a minute of the customer leaving.\""],
                        cross: ["\"The camera covers two of the voids, not all of them.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What pattern did you find?", "\"Cash sales only, voided within about a minute of the customer walking out, almost always on that login.\""),
                            .direct("What does the camera show?", "\"On two of the voids, bills come out of the drawer and go into an apron pocket.\"", "\"Two of the voids are on camera. Both times, cash goes from the drawer into the apron.\""),
                            .cross("The camera covers only two of the forty-seven?", "\"Two are on camera. The pattern covers the rest.\""),
                            .cross("You can't say whose hand was on the keyboard for the other forty-five?", "\"Not from video. The login says whose they were.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} rang up cash sales, voided them as the customers left, and kept the money. The drawer balanced every time because that's how the scheme works."],
        defenseTheory: ["A shared login, two clips of a cashier with {D.his} own lunch money, and an earlier case that made {DL} the first suspect."],
        aggravating: ["The defendant took advantage of a position of trust"],
        mitigating: [],
        victimImpacts: ["{VL}: \"I hired {D.him} knowing about the last time. I'd do it again. I just wish it hadn't been at my register.\""],
        allocutions: ["\"I needed this job. I know what it looks like.\""],
        guiltyTruths: ["The voids stopped the day {DL} was suspended, and never happened on {D.his} days off."],
        innocentTruths: ["After {DL} left, the voids kept happening on a new cashier's login, during a coworker's shifts."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "priorActs"],
        story: StoryExtras(
            timeline: [(-42, "{DL} hired as a cashier."), (-14, "Owner notices the void count."), (0, "Audit complete; register video reviewed."), (5, "{DL} suspended and charged.")],
            howIdentified: "The register's void report and the store camera.",
            notDone: ["No one checked whether the voids continued after {DL} was suspended."],
            defendantExam: [
                .direct("Did you take money from the register?", "\"No. The money in my apron was mine, for lunch.\"", "\"No. I keep lunch money in my apron. That's what's on the video.\""),
                .direct("Why so many voids on your login?", "\"Because other people used it. When it got busy nobody logged out.\""),
                .cross("Forty-seven voids, on a Tuesday afternoon, while you were at the register.", "\"I can't tell you who was at my register every minute.\""),
                .cross("Your lunch money came out of the cash drawer?", "\"It looks like that on the video. It wasn't.\"")
            ],
            prosecutionOpening: "A register that always balanced, and a cashier who knew why.",
            defenseOpening: "A shared login and two seconds of video. That's the State's case, and the earlier case is doing the rest.",
            prosecutionClosing: "Forty-seven to six. The login, the video, and the pattern all point one way.",
            defenseClosing: "If the voids happened when {DL} wasn't there, the State never checked.",
            employer: "{V}'s farm supply store in {HOOD}",
            employmentEnded: true
        )
    )

    // MARK: - Drugs again (an undercover buy)

    static let drugsAgain = CaseTemplate(
        key: "story.followup.drugsAgain", category: .drugs,
        headlines: ["Undercover Buy Leads to Fentanyl Charge", "Pills for Sale in a Grocery Store Lot, Detectives Say"],
        primaryLaw: "saleSchedII", lesserLaw: "possSchedII", threshold: 7, lesserThreshold: 4,
        specification: "Sold to an undercover officer ten pills containing fentanyl, a Schedule II controlled substance.",
        secondary: [
            SecondaryCharge(lawID: "pwisd", specification: "Possessed with intent to sell or deliver fentanyl, a Schedule II controlled substance.", chance: 0.6, threshold: 5)
        ],
        ageRange: 19...60, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a narcotics detective working undercover arranged through a contact to buy ten blue pills for $200. On {DATE}, in a grocery store parking lot in {HOOD}, {DL} handed the detective a sandwich bag of ten pills; the State Crime Laboratory confirmed fentanyl. A body wire recorded the exchange. {DL} says the contact, a paid informant, pressured {D.him} for weeks to find pills, and that {D.he} had never sold anything before {D.he} was asked."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Wire Recording", "Audio and video of {DL} handing over a sandwich bag of ten blue pills and taking $200 in marked bills."),
            E(.forensic, 3, "Lab Report", "Ten tablets stamped \"M30\"; four tested, all containing fentanyl. Net weight 1.1 grams."),
            E(.physical, 2, "Marked Bills", "The $200 in pre-recorded bills recovered from {DL}'s wallet at arrest.", .search)
        ],
        defenseEvidence: [
            E(.digital, 3, "Informant Texts", "Thirty-one texts over five weeks from the informant to {DL}, asking again and again whether {DL} could \"find blues,\" and offering to \"make it worth it.\""),
            E(.document, 2, "Informant Payments", "The informant was paid $150 per completed buy and had charges pending.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Undercover narcotics detective",
                        direct: ["\"I paid two hundred dollars and got ten pills.\""],
                        cross: ["\"The informant set up the contact. I didn't read every text.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What happened in the parking lot?", "\"The defendant walked to my car, handed me a sandwich bag with ten blue pills, and took two hundred dollars.\"", "\"The defendant came to my window with a sandwich bag of ten pills. I handed over two hundred dollars in marked bills.\""),
                            .direct("Was it recorded?", "\"Audio and video, on a body wire.\""),
                            .cross("The informant texted my client thirty-one times before this?", "\"I know there were texts. I didn't review all of them before the buy.\"", "\"There were a lot of texts. I hadn't read them all.\""),
                            .cross("The informant gets paid per buy?", "\"A hundred and fifty dollars a completed buy. That's standard.\""),
                            .cross("And had charges pending?", "\"Yes. That's common with informants.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic chemist, State Crime Laboratory",
                        direct: ["\"Fentanyl, in all four tablets I tested.\""],
                        cross: ["\"I tested four of ten.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find?", "\"Ten blue tablets stamped M30. I tested four by GC-MS. All four contained fentanyl.\""),
                            .cross("You tested four of the ten?", "\"Four, chosen at random, consistent with our sampling plan.\""),
                            .cross("You can't say where the pills came from?", "\"No. Only what's in them.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{D} sold ten fentanyl pills in a grocery store parking lot to a buyer {D.he} thought was a customer. It's on video."],
        defenseTheory: ["A paid informant with charges pending texted {DL} thirty-one times until {D.he} found pills. That's the State creating a crime, not catching one."],
        aggravating: [],
        mitigating: ["The defendant has a substance use disorder"],
        victimImpacts: [],
        allocutions: ["\"I didn't go looking to sell anything. I was asked and asked until I did it. I know I still did it.\""],
        guiltyTruths: ["Messages found later on {DL}'s phone showed {D.him} offering pills to two other people the same month, unprompted."],
        innocentTruths: ["The informant later admitted in another case that he had supplied the pills to {DL} himself the day before the buy."],
        moods: [.divided], doctrines: ["entrapment", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(-35, "First informant text to {DL}."), (-1, "Buy arranged."), (0, "Undercover buy in the grocery store lot; {DL} arrested."), (21, "Lab confirms fentanyl.")],
            howIdentified: "A controlled buy set up through a paid informant.",
            notDone: ["The informant was not called as a witness."],
            defendantExam: [
                .direct("Why did you sell the pills?", "\"He wouldn't stop asking. Five weeks. I finally found some just to make it stop.\"", "\"Because he asked every few days for five weeks. I gave in.\""),
                .direct("Had you sold pills before?", "\"No. Never.\""),
                .cross("You found ten fentanyl pills in a day.", "\"I knew who to ask. That's not the same as selling.\""),
                .cross("And you took the two hundred dollars.", "\"I gave it to the person I got them from.\"")
            ],
            prosecutionOpening: "Ten fentanyl pills, two hundred dollars, and a recording of the whole thing.",
            defenseOpening: "Thirty-one texts from a paid informant who needed a buy to work off his own charges.",
            prosecutionClosing: "Being asked isn't a defense. {DL} knew where to get pills and how to sell them.",
            defenseClosing: "The State's own informant manufactured this sale. Entrapment exists for cases like this one."
        )
    )
}
