import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the batch AD stories. Each is a complete new incident; the earlier case appears only as {PRIOR}
/// and {PRIORDATE}, so it reads the same whatever the earlier verdict was.
extension FollowUpCases {
    static let batchAD: [CaseTemplate] = [
        appDrugSale, motelDelivery, gloveboxPistol, backyardRifle, fakeProfile, managerInbox, pointedPistol, pistolWhip
    ]

    // MARK: - After the vape shop: a sale arranged by message

    static let appDrugSale = CaseTemplate(
        key: "story.followup.appDrugSale", category: .drugs,
        headlines: ["Meth Sale Arranged by Phone App Ends in Fast-Food Parking Lot Arrest", "Undercover Detective Buys a Quarter Ounce, Deputies Say"],
        primaryLaw: "saleSchedII", lesserLaw: "possSchedII", threshold: 7, lesserThreshold: 4,
        specification: "Sold 6.8 grams of methamphetamine, a Schedule II controlled substance, to an undercover detective on {DATE}.",
        ageRange: 22...40, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a buyer arrested on another charge gave narcotics detectives a messaging-app username and said it sold methamphetamine. An undercover detective messaged the account, agreed on a quarter ounce for $260, and on {DATE} at 4:20 p.m. met the seller in a fast-food parking lot in {HOOD}. {DL} walked to the detective's car, handed over a bag, and took $260 in marked bills, and was arrested in the lot. The bag held 6.8 grams of methamphetamine. The messaging account was signed in on {DL}'s phone. {DL} says a friend had been using {D.his} phone and asked {D.him} to drop off a bag, and {D.he} didn't know what was in it."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "App Messages", "The thread between the undercover account and the seller's username: \"quarter is 260,\" \"4:20 at the burger place on {STREET},\" and \"i'm in the black truck.\" The account was signed in on {DL}'s phone at arrest.", .search),
            E(.video, 3, "Body Camera", "The detective's hidden camera shows {DL} handing a bag through the car window and taking the bills."),
            E(.forensic, 3, "Lab Report", "6.8 grams of methamphetamine."),
            E(.physical, 2, "Marked Bills", "The $260 in pre-recorded bills in {DL}'s hand at arrest.", .search)
        ],
        defenseEvidence: [
            E(.statement, 1, "Borrowed Phone", "{DL} says a friend used {D.his} phone that week and asked {D.him} to make the drop.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Undercover narcotics detective",
                        direct: ["\"{DL} handed me the bag and took the money.\""],
                        cross: ["\"I never saw who typed the messages.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How was the sale arranged?", "\"Through the app. I asked for a quarter. The answer was 'quarter is 260,' and the seller picked the place and time.\""),
                            .direct("What happened at 4:20?", "\"{DL} got out of a black truck, walked to my window, handed me a bag, and took two hundred sixty dollars in marked bills. We arrested {D.him} right there.\"", "\"A black truck pulled in, the way the messages said. {DL} came to my window with a bag and took the marked bills, and the arrest team moved in.\""),
                            .direct("Where was the account signed in?", "\"On the phone in {DL}'s pocket. The thread was open on the screen.\""),
                            .cross("You never saw who typed those messages?", "\"No. I saw who showed up with the bag.\""),
                            .cross("Did you look for the friend {DL} named?", "\"We did. {DL} gave a first name only, and the phone shows no one by that name in the week before.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic chemist, State Crime Laboratory",
                        direct: ["\"6.8 grams of methamphetamine.\""],
                        cross: ["\"One bag, tested in full.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was in the bag?", "\"Crystalline material, 6.8 grams net. It was methamphetamine.\""),
                            .cross("Was there more than one bag?", "\"One bag. I tested a sample from it and weighed all of it.\""),
                            .cross("You can't say who packaged it?", "\"No.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{DL}'s phone made the deal, {DL} made the handoff, and {DL} took the money. It's on camera."],
        defenseTheory: ["{DL} was a courier who didn't know what was in the bag. The State can't show who typed the messages."],
        aggravating: [],
        mitigating: ["The defendant has a substance use disorder"],
        victimImpacts: [],
        allocutions: ["\"I've got to get away from the people I was around. I know that now.\""],
        guiltyTruths: ["Deleted photos recovered later from {DL}'s phone showed the same bag on a scale an hour before the sale."],
        innocentTruths: ["The friend {DL} named was arrested a month later with the same app account signed in on a second phone."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-9, "Arrested buyer gives detectives the seller's username."), (-2, "Undercover detective messages the account; price agreed."), (0, "4:20 p.m. handoff in the fast-food lot; {DL} arrested; phone seized."), (3, "Phone search warrant."), (26, "Lab confirms methamphetamine.")],
            howIdentified: "Arrested at the handoff the messages set up.",
            notDone: [],
            defendantExam: [
                .direct("Did you write those messages?", "\"No. My friend had my phone most of that week. His was cut off.\""),
                .direct("Why did you bring the bag?", "\"He asked me to drop it to somebody and bring back the money. I didn't open it.\""),
                .cross("The account was open on your phone in your pocket.", "\"He gave the phone back that morning.\""),
                .cross("You can't tell us his last name.", "\"I only know him by his first name.\"")
            ],
            prosecutionOpening: "The messages, the handoff, and the money in one person's hands.",
            defenseOpening: "A courier, not a dealer.",
            prosecutionClosing: "Couriers don't carry the seller's phone with the deal open on the screen.",
            defenseClosing: "The State proved who carried a bag. It didn't prove who knew what was in it."
        )
    )

    // MARK: - After the vape shop: a speaker box in the trunk

    static let motelDelivery = CaseTemplate(
        key: "story.followup.motelDelivery", category: .drugs,
        headlines: ["Meth Found in Speaker Box After Motel Stop", "Driver Says Passenger Loaded the Trunk"],
        primaryLaw: "pwisd", lesserLaw: "possSchedII", threshold: 8, lesserThreshold: 5,
        specification: "Possessed with intent to sell or deliver 11.4 grams of methamphetamine, a Schedule II controlled substance, in six bags hidden in a speaker box in the trunk of {D.his} car.",
        secondary: [
            SecondaryCharge(lawID: "maintainingDwelling", specification: "Knowingly kept a vehicle used for keeping and transporting methamphetamine.", chance: 0.6, threshold: 6)
        ],
        ageRange: 22...42, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, deputies watching a motel on {STREET} known for drug complaints saw {DL}'s car pull in at 10:05 p.m. on {DATE}. The passenger, {ALT}, went into Room 112 for three minutes and came back. Deputies stopped the car four blocks away for weaving across the center line. In the trunk, inside a speaker box, they found six bags holding 11.4 grams of methamphetamine and a digital scale; {DL} had $640 in cash in {D.his} wallet. The car is registered to {DL}. {ALT}'s thumbprint was on one bag; none of {DL}'s prints were found. {DL} says {D.he} was giving {ALT} a ride for gas money, that {ALT} put the speaker box in the trunk that afternoon, and that the cash was rent money."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Speaker Box", "Six bags of methamphetamine, 11.4 grams in all, and a digital scale inside a speaker box in the trunk of {DL}'s car.", .search),
            E(.video, 2, "Surveillance and Dash Camera", "Deputies' video of the car at the motel and the stop; {DL} is driving.", .search),
            E(.physical, 2, "Cash", "$640 in twenties and tens in {DL}'s wallet.", .search),
            E(.document, 1, "Registration", "The car is registered to {DL}.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Fingerprint Report", "{ALT}'s thumbprint on one bag; no prints of {DL} on any bag, the scale, or the speaker box."),
            E(.statement, 1, "Friend's Account", "A friend saw {ALT} carry the speaker box to {DL}'s car that afternoon.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Sheriff's narcotics deputy",
                        direct: ["\"Six bags and a scale in a speaker box in {DL}'s trunk.\""],
                        cross: ["\"The passenger went into the room. {DL} stayed in the car.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you see at the motel?", "\"{DL}'s car pulled in at 10:05. The passenger went into Room 112, came out three minutes later, and they left.\""),
                            .direct("Why did you stop the car?", "\"It crossed the center line twice in four blocks. That's on the dash camera.\""),
                            .direct("What did you find?", "\"A speaker box in the trunk with the back panel loose. Inside, six bags of crystal and a digital scale. {DL} had six hundred forty dollars in {D.his} wallet.\"", "\"Behind a loose panel in a speaker box in the trunk, six bags and a scale. Six hundred forty in cash on {DL}.\""),
                            .cross("{DL} never got out of the car at the motel?", "\"No. {DL} stayed behind the wheel.\""),
                            .cross("And {ALT}'s print, not {DL}'s, was on the bag?", "\"{ALT}'s thumbprint on one bag. No prints of {DL}'s anywhere on it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Latent print examiner, Sheriff's Office",
                        direct: ["\"One identifiable print: {ALT}'s.\""],
                        cross: ["\"No print of {DL} anywhere.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find on the bags?", "\"One identifiable thumbprint on one bag. It belongs to {ALT}.\""),
                            .cross("Any prints of {DL}?", "\"None on the bags, the scale, or the speaker box.\""),
                            .redirect("Does no print mean someone didn't touch an item?", "\"No. Most touches leave nothing I can identify.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend of {DL}",
                        direct: ["\"I watched {ALT} put that speaker box in the trunk.\""],
                        cross: ["\"I've known {DL} since high school.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see that afternoon?", "\"{ALT} came out of my building carrying a speaker box and asked {DL} to pop the trunk.\""),
                            .direct("Did {DL} touch it?", "\"No. {DL} was in the driver's seat the whole time.\""),
                            .cross("You've known {DL} for years?", "\"Since high school.\""),
                            .cross("You didn't tell deputies this until a month later?", "\"Nobody asked me until the lawyer did.\"")
                        ])
        ],
        prosecutionTheory: ["{DL}'s car, {DL}'s trunk, {DL} driving to and from a drug room, and $640 in {DL}'s wallet."],
        defenseTheory: ["{ALT} went into the room, {ALT}'s print is on the bag, and a witness saw {ALT} load the box. {DL} was the ride."],
        aggravating: [],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"I gave somebody a ride. I should have asked what was in that box.\""],
        guiltyTruths: ["Texts on {DL}'s phone that night told a buyer, \"got it, be there by 11.\""],
        innocentTruths: ["{ALT} later pleaded guilty and told the court the speaker box and everything in it were {ALT}'s alone."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(0, "10:05 p.m. car at the motel; stop four blocks away; speaker box searched; {DL} and {ALT} arrested."), (2, "Phone search warrants for both."), (18, "Fingerprint report."), (28, "Lab confirms methamphetamine.")],
            howIdentified: "Stopped after leaving a motel room under surveillance.",
            notDone: ["{ALT}, charged separately, declined to testify."],
            defendantExam: [
                .direct("Why were you at the motel?", "\"{ALT} needed a ride and gave me twenty dollars for gas. I waited in the car.\""),
                .direct("Whose speaker box was it?", "\"{ALT}'s. It went in my trunk that afternoon.\""),
                .cross("Six hundred forty dollars in cash?", "\"Rent money. It was due that week.\""),
                .cross("You never asked what was in the box?", "\"It was a speaker box. I didn't think to.\"")
            ],
            prosecutionOpening: "{DL} drove to a drug room and back with methamphetamine in {D.his} own trunk.",
            defenseOpening: "The passenger's room, the passenger's box, the passenger's print.",
            prosecutionClosing: "A car is the driver's. Knowledge comes from the trip, the cash, and the timing.",
            defenseClosing: "Being the driver isn't knowing. The only print is {ALT}'s."
        )
    )

    // MARK: - After the printed pistol: a revolver in a friend's glove box

    static let gloveboxPistol = CaseTemplate(
        key: "story.followup.gloveboxPistol", category: .publicOrder,
        headlines: ["Felon Charged After Trooper Sees Revolver in Glove Box", "\"It's My Friend's Car,\" Driver Says"],
        primaryLaw: "felonFirearm", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Possessed a firearm, a .38 revolver, in the glove box of a car {D.he} was driving, after having been convicted of a felony.",
        ageRange: 28...48, occupations: [], requiresFelonyPrior: true, hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a state trooper stopped a car on {STREET} at 11:40 p.m. on {DATE} for a dead headlight. {DL}, who has a felony conviction, was driving alone; the car belongs to a friend, {ALT}. When {DL} opened the glove box for the registration, the trooper's flashlight lit a .38 revolver, and {DL} pushed the glove box shut. The trooper's body camera recorded it. A swab of the revolver's grip held a mixture of three people's DNA; {DL} cannot be excluded. {ALT} says the revolver is {ALT}'s and that {DL} didn't know it was there."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Camera", "{DL} opens the glove box, the light falls on a revolver, and {DL} shuts it in less than a second and hands over the registration from the visor instead."),
            E(.physical, 2, "Revolver", "A loaded .38 revolver in the glove box, reported stolen two years earlier from a home in another county.", .search),
            E(.forensic, 1, "DNA Report", "A mixture of three people on the grip; {DL} cannot be excluded.")
        ],
        defenseEvidence: [
            E(.document, 2, "Registration", "The car is registered to {ALT}; {DL} had borrowed it that evening."),
            E(.statement, 2, "Owner's Account", "{ALT} says the revolver is {ALT}'s and was never mentioned to {DL}.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "State Highway Patrol trooper",
                        direct: ["\"The light hit the revolver and the glove box slammed shut.\""],
                        cross: ["\"It wasn't the driver's car.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Why did you stop the car?", "\"Driver's side headlight was out on {STREET}, 11:40 at night.\""),
                            .direct("What happened when you asked for the registration?", "\"{DL} opened the glove box. My light was on it, and I saw the grip of a revolver. The glove box shut fast, and {DL} reached for the visor and handed me the registration from there.\"", "\"The glove box came open, my flashlight landed on a revolver, and {DL} shut it right away and pulled the registration from the visor.\""),
                            .direct("What did {DL} say about the gun?", "\"'That's not mine. It's his car.'\""),
                            .cross("The car belongs to {ALT}?", "\"Yes. Registered to {ALT}.\""),
                            .cross("You never saw {DL} touch the revolver?", "\"No. I saw {DL} see it and close the door on it.\"")
                        ]),
            WitnessSeed(name: nil, role: "DNA analyst, State Crime Laboratory",
                        direct: ["\"{DL} cannot be excluded from the mixture.\""],
                        cross: ["\"A three-person mixture is hard to interpret.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find on the grip?", "\"A mixture from three people. {DL} cannot be excluded as one of them.\""),
                            .cross("How common is a 'cannot be excluded' result in a three-person mixture?", "\"More common than in a single-source sample. The statistic is weaker.\""),
                            .cross("Is {ALT} also included?", "\"{ALT} is also included.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: "{ALT}", role: "Owner of the car",
                        direct: ["\"It's my revolver. I never told {DL} about it.\""],
                        cross: ["\"I knew {DL} had a record.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Whose revolver is it?", "\"Mine. I keep it in the glove box.\""),
                            .direct("Did you tell {DL} it was there?", "\"No. {DL} asked to borrow the car to pick up a cousin, and I gave the keys.\""),
                            .cross("Where did you get it?", "\"From a guy at a yard sale.\""),
                            .cross("It was reported stolen.", "\"I didn't know that.\""),
                            .cross("You knew {DL} has a felony record when you handed over a car with a loaded gun in it?", "\"I forgot it was in there.\"")
                        ])
        ],
        prosecutionTheory: ["{DL} knew the revolver was there the instant the light hit it and moved to hide it. Driving alone with it in reach is possession."],
        defenseTheory: ["Someone else's car, someone else's gun, and a reflex to close a door. Seeing a gun isn't possessing it."],
        aggravating: [],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"I borrowed a car. I didn't know what was in it until that light came on.\""],
        guiltyTruths: ["A text from {DL}'s phone that afternoon asked {ALT}, \"is the 38 still in the box?\""],
        innocentTruths: ["{ALT}'s cousin later admitted leaving the revolver in the glove box without telling anyone."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "11:40 p.m. stop on {STREET}; revolver seized; {DL} arrested."), (1, "{ALT} interviewed."), (2, "Revolver traced as stolen."), (40, "DNA report.")],
            howIdentified: "Seen during a traffic stop.",
            notDone: [],
            defendantExam: [
                .direct("Did you know the revolver was in the glove box?", "\"Not until the light hit it.\""),
                .direct("Why did you shut it?", "\"Panic. I know what a gun means for me.\""),
                .cross("You closed it in under a second and went for the visor.", "\"Because I wanted it away from me.\""),
                .cross("Your DNA can't be excluded from the grip.", "\"I've ridden in that car a hundred times. I never touched that gun.\"")
            ],
            prosecutionOpening: "One look, one slam, and a revolver within arm's reach of a felon.",
            defenseOpening: "A borrowed car, and a gun the owner admits is his.",
            prosecutionClosing: "Knowledge and access. {DL} had both the moment that light came on, and chose to hide it.",
            defenseClosing: "Possession needs intent to control. Closing a door on a gun is the opposite.",
            genders: ["ALT": .male],
            time: "11:40 p.m."
        )
    )

    // MARK: - After the printed pistol: target practice on a neighbor's video

    static let backyardRifle = CaseTemplate(
        key: "story.followup.backyardRifle", category: .publicOrder,
        headlines: ["Neighbor's Video Shows Felon Firing Rifle at Cans, Deputies Say", "Backyard Target Practice Leads to Gun Charge"],
        primaryLaw: "felonFirearm", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Possessed a firearm, a .22 caliber rifle, after having been convicted of a felony.",
        ageRange: 28...48, occupations: [], requiresFelonyPrior: true, hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, a neighbor in {HOOD} called deputies at 4:10 p.m. on {DATE} about shooting in the next backyard and sent a phone video. The video, recorded from about 40 yards, shows {DL} in a red cap firing a .22 rifle at cans on a fence rail, five shots, then handing the rifle to the homeowner, {ALT}. Deputies arrived at 4:25 and found the rifle on a picnic table and three people in the yard. {DL}, who has a felony conviction, told a deputy, \"I only shot it a couple of times.\" {ALT} owns the rifle."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Neighbor's Video", "Fifty-two seconds from about 40 yards: a person in a red cap fires a .22 rifle five times at cans, then hands it to {ALT}. {DL} was the only person in a red cap when deputies arrived."),
            E(.statement, 3, "Statement to Deputy", "{DL}, standing in the yard and not under arrest, told the deputy, \"I only shot it a couple of times.\"", .statement),
            E(.physical, 1, "Rifle", "A .22 rifle owned by {ALT}, on the picnic table, with five spent casings in the grass nearby.")
        ],
        defenseEvidence: [
            E(.statement, 1, "Distance", "The video is taken from about 40 yards, and the face of the shooter is not visible.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor who recorded the video",
                        direct: ["\"The one in the red cap was shooting.\""],
                        cross: ["\"I couldn't see a face from there.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Three people in the yard next door, shooting at cans on the fence. My grandkids were in my yard. I took them inside and started recording.\""),
                            .direct("Who was shooting on the video?", "\"The one in the red cap. Five shots, then handed the rifle to the homeowner.\""),
                            .cross("You couldn't see the face?", "\"Not from there. I could see the red cap.\""),
                            .cross("Do you know {DL}?", "\"I'd seen {DL} over there before. We'd never talked.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's deputy",
                        direct: ["\"{DL} told me, 'I only shot it a couple of times.'\""],
                        cross: ["\"{DL} wasn't under arrest when {DL} said it.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find at 4:25?", "\"Three people in the yard, a .22 rifle on the picnic table, five spent casings in the grass by the fence. {DL} was the only one in a red cap.\""),
                            .direct("What did {DL} say?", "\"I asked who'd been shooting. {DL} said, 'I only shot it a couple of times.'\"", "\"When I asked who was shooting, {DL} said, 'I only shot it a couple of times.'\""),
                            .cross("You didn't read {DL} any rights first?", "\"No. {DL} wasn't in custody. I was standing in a backyard asking what happened.\""),
                            .cross("The rifle belongs to {ALT}?", "\"Yes. Lawfully owned.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: "{ALT}", role: "Homeowner",
                        direct: ["\"It's my rifle.\""],
                        cross: ["\"{DL} was in a red cap.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Whose rifle is it?", "\"Mine. My grandfather's, actually.\""),
                            .direct("Did you hand it to {DL}?", "\"I don't remember who handed what to who. We were just out back.\""),
                            .cross("Who was wearing the red cap that day?", "\"{DL}.\""),
                            .cross("And the person in the red cap is firing the rifle on the video.", "\"That's what the video shows.\"")
                        ])
        ],
        prosecutionTheory: ["The video shows the red cap firing, {DL} was the red cap, and {DL} said so."],
        defenseTheory: ["A faceless figure from forty yards, and a casual answer the State is treating as a confession."],
        aggravating: [],
        mitigating: [],
        victimImpacts: [],
        allocutions: ["\"It was cans in a backyard. I know it doesn't matter to the law.\""],
        guiltyTruths: ["{DL}'s own phone held a video from the same afternoon of {DL} firing the rifle, sent to a cousin."],
        innocentTruths: ["A visiting relative of {ALT}'s had borrowed {DL}'s red cap earlier that afternoon and admitted being the shooter on the video."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "miranda"],
        story: StoryExtras(
            timeline: [(0, "4:10 p.m. neighbor calls and sends the video; 4:25 p.m. deputies arrive; {DL}'s statement; rifle photographed."), (5, "{DL} charged.")],
            howIdentified: "The neighbor's video and {DL}'s own statement.",
            notDone: [],
            defendantExam: [
                .direct("Did you fire that rifle?", "\"I said a couple of times because the deputy was asking and I wanted to get it over with. I was mostly watching.\""),
                .cross("Mostly watching?", "\"I might have shot it. I don't know exactly.\""),
                .cross("You were in the red cap.", "\"Yes.\"")
            ],
            prosecutionOpening: "A red cap, a rifle, and {DL}'s own words.",
            defenseOpening: "Forty yards and no face.",
            prosecutionClosing: "Holding and firing a rifle is possession, however briefly. {DL} told the deputy as much.",
            defenseClosing: "A statement made to end a conversation isn't proof beyond a reasonable doubt.",
            time: "4:10 p.m."
        )
    )

    // MARK: - After the password reset: a fake dating profile (same victim)

    static let fakeProfile = CaseTemplate(
        key: "story.followup.fakeProfile", category: .cyber,
        headlines: ["Fake Dating Profile Sent Strangers to a Home in {HOOD}, Deputies Say", "Private Photos Used in Online Impersonation"],
        primaryLaw: "cyberstalking", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Electronically posted a dating profile in {V}'s name with {V}'s photographs and phone number, and sent messages from it, for the purpose of abusing, embarrassing, and harassing {V}.",
        secondary: [
            SecondaryCharge(lawID: "stalking", specification: "Willfully engaged in a course of conduct directed at {V}, causing strangers to come to {V}'s home, that would cause a reasonable person to fear for {V.his} safety.", chance: 0.6, threshold: 8)
        ],
        ageRange: 24...42, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V} began getting calls from strangers. A dating profile created on {DATE} at 6:12 p.m. used {V}'s name, real phone number, and six photos, and told men to \"just come by\" {V}'s street. Two strangers came to {V}'s door over the next week. The profile was made with an email address created a minute earlier from a public library branch in {HOOD}; the library's sign-in log and camera put {DL} at computer 4 from 6:05 to 6:40 p.m. Two of the six photos had never been posted anywhere; {V} had sent them only to {DL} during their relationship. Nine other people were signed into library computers at 6:12, all sharing the same internet address. {DL} says {D.he} was applying for jobs."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Library Sign-In Log", "{DL}'s library card signed into computer 4 from 6:05 to 6:40 p.m. on {DATE}.", .search),
            E(.video, 2, "Library Camera", "{DL} seated at computer 4 throughout; the screen is not visible."),
            E(.digital, 3, "Private Photos", "Two of the six photos on the profile had never been posted online; {V} sent them only to {DL}."),
            E(.digital, 2, "Platform Records", "The email address and the profile were created from the library's internet address at 6:11 and 6:12 p.m.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Shared Address", "Ten computers were in use at 6:12 p.m., all behind the same library internet address."),
            E(.document, 1, "Job Applications", "Two job applications were submitted from {DL}'s email during the same session.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Person impersonated",
                        direct: ["\"Strangers came to my door because of a profile with my face on it.\""],
                        cross: ["\"I only ever sent those two photos to one person.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened after the profile went up?", "\"My phone started ringing at all hours. Men I'd never met, asking if tonight was still on. Then one knocked on my door at eleven at night.\"", "\"Calls and texts from strangers, day and night. Then two of them showed up at my house.\""),
                            .direct("How did that feel?", "\"I moved my bed into the room with a lock. I still jump every time a car slows down on my street.\""),
                            .direct("What about the photos?", "\"Two of them I'd only ever sent to {DL}. I've never posted them. Nobody else had them.\""),
                            .cross("Could someone have gotten them off an old phone or a cloud account?", "\"Not from me. I'd changed every password and locked everything down long before this.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Computer crimes detective",
                        direct: ["\"The profile came from the library while {DL} sat at computer 4.\""],
                        cross: ["\"Nine other people were on library computers at that minute.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the profile come from?", "\"The email account was created at 6:11 and the profile at 6:12, both from the library branch's internet address.\""),
                            .direct("Who was there?", "\"Ten people signed into computers at 6:12. {DL} was at computer 4, on camera, from 6:05 to 6:40.\""),
                            .direct("Did you look at the other nine?", "\"Yes. None had any connection to {V} that we could find, and the computers' own logs show the other nine on job sites, games, and email.\""),
                            .cross("The library computers wipe their history at logout?", "\"They do. We couldn't recover what was on computer 4's screen.\""),
                            .cross("You searched {DL}'s phone?", "\"Yes. The two private photos were still in the old message thread with {V}.\"")
                        ]),
            WitnessSeed(name: nil, role: "Library branch manager",
                        direct: ["\"{DL}'s card was signed in at computer 4.\""],
                        cross: ["\"Our machines erase everything at logout.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How do patrons use the computers?", "\"They sign in with a library card. The log records the card, the machine, and the times.\""),
                            .direct("What does the log show?", "\"{DL}'s card on computer 4, 6:05 to 6:40.\""),
                            .cross("Do the machines keep a browsing history?", "\"No. Everything is erased at logout, for patrons' privacy.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["Only one person on earth had those two photos and sat at a library computer the minute the profile was made."],
        defenseTheory: ["Ten computers, one internet address, and a wiped machine. {DL} was applying for jobs."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"I thought it was over. Then strangers were at my door with my picture on their phones.\""],
        allocutions: ["\"I didn't make that profile.\""],
        guiltyTruths: ["The profile's password matched one {DL} had used for an old streaming account."],
        innocentTruths: ["A friend of {V}'s who had borrowed {V}'s old phone admitted copying the photos and making the profile from the same library."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "6:11 p.m. email account and 6:12 p.m. profile created from the library."), (1, "Calls to {VL} begin."), (4, "First stranger at {VL}'s door."), (7, "Second stranger; {V} reports."), (15, "Platform and library records returned."), (18, "{DL}'s phone searched by warrant; {DL} charged.")],
            howIdentified: "Platform records led to the library; the sign-in log and camera to {DL}.",
            notDone: [],
            defendantExam: [
                .direct("What were you doing at the library?", "\"Applying for jobs. Two applications went out from my email that night.\""),
                .direct("Did you make the profile?", "\"No.\""),
                .cross("Two photos only you had.", "\"They were on {V}'s phone too. Anyone could have them.\""),
                .cross("And the one minute you happen to be at computer 4.", "\"Along with nine other people.\"")
            ],
            prosecutionOpening: "Two photos only {DL} had, and {DL} at the computer when they went online.",
            defenseOpening: "A public library, ten patrons, and nothing on the screen.",
            prosecutionClosing: "The other nine have no tie to {V}. {DL} has the photos, the history, and the seat.",
            defenseClosing: "Opportunity and a past aren't proof of who typed.",
            victim: VictimFacts(relationship: "Former partner of the defendant"),
            time: "6:12 p.m."
        )
    )

    // MARK: - After the password reset: a manager's inbox

    static let managerInbox = CaseTemplate(
        key: "story.followup.managerInbox", category: .cyber,
        headlines: ["Fake Resignation Email Sent From Manager's Account", "Night-Shift Worker Charged in Workplace Email Break-In"],
        primaryLaw: "accessingComputers", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Willfully and without authorization accessed {V}'s work email account and sent messages from it.",
        ageRange: 24...42, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {DL} took a night-shift job at a distribution center in {HOOD}. A week after shift manager {V} gave {DL} a written warning, at 2:14 a.m. on {DATE}, someone signed into {V}'s work email from the break-room computer and sent every employee a fake resignation from {V}, full of insults about coworkers, along with {V}'s private notes on three employees' discipline. {V} kept the password on a sticky note in the shared office. The break-room camera, aimed at the door, shows {DL} entering at 2:09 and leaving at 2:22; another worker came in from 2:11 to 2:13. {DL} says {D.he} was eating at the table and never touched the computer."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Login Records", "{VL}'s account signed in from the break-room computer at 2:14 a.m.; the email went out at 2:19 a.m.; signed out at 2:21 a.m."),
            E(.video, 2, "Break-Room Camera", "{DL} enters at 2:09 and leaves at 2:22; one other worker enters at 2:11 and leaves at 2:13. The computer is out of frame."),
            E(.document, 2, "Written Warning", "{V} gave {DL} a written warning for attendance a week earlier; {DL} told a coworker, \"Somebody ought to show everybody who {VL} really is.\"")
        ],
        defenseEvidence: [
            E(.document, 2, "Sticky Note", "{VL}'s password was on a sticky note in the shared office used by every lead on the shift."),
            E(.statement, 1, "Coworker", "The coworker who came in at 2:11 says {DL} was eating at the table.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Shift manager",
                        direct: ["\"Everyone I work with got a letter in my name calling them names.\""],
                        cross: ["\"Yes, my password was on a sticky note.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you find when you woke up?", "\"Forty missed calls. My whole staff had an email from me quitting and insulting them, and my notes on three people's discipline attached.\""),
                            .direct("How did that affect you?", "\"Some of those people still won't look at me. I'd spent six years earning their trust.\""),
                            .direct("Had you disciplined {DL}?", "\"A written warning for attendance, a week before.\""),
                            .cross("Your password was on a sticky note in an office the leads share?", "\"It was. That was stupid of me.\"")
                        ]),
            WitnessSeed(name: nil, role: "IT security manager",
                        direct: ["\"The login came from the break-room computer at 2:14.\""],
                        cross: ["\"The computer doesn't know who's sitting at it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Where was the account accessed from?", "\"The shared computer in the break room. Signed in at 2:14, sent the email at 2:19, signed out at 2:21.\""),
                            .direct("Who can use that computer?", "\"Anyone on shift. It's for timecards and benefits. No individual sign-in.\""),
                            .cross("So the computer can't tell you who used it?", "\"No. Only when.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's detective",
                        direct: ["\"{DL} was in the room for the whole login.\""],
                        cross: ["\"Another worker was in the room for two of those minutes.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What does the camera show?", "\"{DL} walks in at 2:09 and out at 2:22. The login is 2:14 to 2:21. One other worker is in the room from 2:11 to 2:13.\""),
                            .direct("Did anyone else hear {DL} talk about {V}?", "\"A coworker told us {DL} said, 'Somebody ought to show everybody who {VL} really is,' the day after the warning.\""),
                            .cross("The other worker left a minute before the login?", "\"At 2:13, a minute before. That worker was on the loading dock camera from 2:14 on.\""),
                            .cross("Did you search {DL}'s phone?", "\"Yes. Nothing about the email on it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Coworker on the night shift",
                        direct: ["\"{DL} was eating at the table when I came in.\""],
                        cross: ["\"I was only there two minutes.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see in the break room?", "\"{DL} at the table with a sandwich. Nobody at the computer.\""),
                            .direct("Did people know about the sticky note?", "\"Every lead knew. It was on the monitor in the office for months.\""),
                            .cross("You were in the room from 2:11 to 2:13?", "\"About that.\""),
                            .cross("So you don't know what happened at 2:14.", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["{DL} had a grudge, said what {D.he} wanted to do, and was alone in the room for every minute of the login."],
        defenseTheory: ["A password on a sticky note any lead could read, a computer out of frame, and nothing on {DL}'s phone."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"Six years of trust, gone in one email I never wrote.\""],
        allocutions: ["\"I didn't send it. I was eating my lunch.\""],
        guiltyTruths: ["A photo of the sticky note, taken in the shared office two days earlier, was later found in {DL}'s deleted pictures."],
        innocentTruths: ["A shift lead who had also been disciplined by {V} admitted signing in remotely to the break-room computer through a timecard tool."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-7, "{V} gives {DL} a written warning."), (-6, "{DL}'s remark to a coworker."), (0, "2:14 a.m. login; 2:19 a.m. email sent; 2:21 a.m. sign-out."), (2, "Break-room and dock video pulled."), (9, "{DL}'s phone searched by warrant; {DL} charged.")],
            howIdentified: "The break-room camera during the login window.",
            notDone: [],
            defendantExam: [
                .direct("What were you doing in the break room?", "\"Eating. My break is two to two-twenty.\""),
                .direct("Did you use the computer?", "\"No. I didn't even know {VL}'s password.\""),
                .cross("You said someone ought to show everybody who {VL} really is.", "\"I was mad about the warning. I didn't mean this.\""),
                .cross("You were alone in that room from 2:13 to 2:22.", "\"Eating a sandwich.\"")
            ],
            prosecutionOpening: "A grudge, a promise, and nine minutes alone with the computer.",
            defenseOpening: "A password anyone could read and a computer no camera could see.",
            prosecutionClosing: "For every minute of that login, {DL} was the only person in the room.",
            defenseClosing: "The camera shows a door, not a keyboard.",
            time: "2:14 a.m.",
            employer: "A distribution center in {HOOD}"
        )
    )

    // MARK: - After the shots into a house: a pistol at a gas pump

    static let pointedPistol = CaseTemplate(
        key: "story.followup.pointedPistol", category: .violent,
        headlines: ["Pistol Pointed at Driver in Gas Pump Argument", "Station Camera Records Confrontation"],
        primaryLaw: "assaultPointingGun", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Pointed a 9mm pistol at {V} at a gas station on {STREET}, without legal justification.",
        ageRange: 25...50, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {DL} and {V} argued at a gas station on {STREET} at 9:05 p.m. on {DATE} over who was next at a pump. The station camera shows {V} walking toward {DL} with arms out, yelling, and stopping about six feet away; {DL} reaches into {D.his} car, raises a pistol at {V} for about four seconds, then drives off. Deputies found a 9mm pistol in {DL}'s car the next morning. {DL} says {V} was coming at {D.him} and {D.he} was afraid of being beaten."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Station Camera", "{V} stops six feet from {DL}; {DL} reaches into the car, points a pistol at {V} for about four seconds, and drives away. {V}'s hands are empty."),
            E(.physical, 2, "Pistol", "A 9mm pistol in {DL}'s car's center console the next morning.", .search),
            E(.statement, 2, "Clerk's 911 Call", "The clerk called 911 at 9:06 p.m.: \"Somebody just pulled a gun on a customer at pump 6.\"")
        ],
        defenseEvidence: [
            E(.statement, 2, "Aggressor", "The video shows {V} closing the distance, yelling, arms spread, before any gun appears.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Driver at the pump",
                        direct: ["\"I was looking down the barrel of a gun over a gas pump.\""],
                        cross: ["\"I was yelling. I never touched anybody.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened?", "\"I'd been waiting for that pump. {DL} cut in. I got out and told {D.him} so.\"", "\"{DL} pulled in ahead of me at the pump I was waiting on. I got out to say something.\""),
                            .direct("And then?", "\"{D.He} reached into the car and came up with a pistol pointed at my chest. I thought that was it. I froze.\""),
                            .direct("How has it affected you?", "\"I don't get out of my car anymore when somebody's rude. I just drive away.\""),
                            .cross("You walked toward {DL} yelling?", "\"I was angry. I stopped. I never raised a hand.\"")
                        ]),
            WitnessSeed(name: nil, role: "Gas station clerk",
                        direct: ["\"I called 911 as soon as I saw the gun.\""],
                        cross: ["\"The other customer was loud.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see?", "\"Two people arguing at pump 6. Then one of them had a pistol out, pointed at the other.\""),
                            .direct("What did you do?", "\"Called 911. By the time I was talking, the car was gone.\""),
                            .cross("Was the customer without the gun being aggressive?", "\"Loud. Walking toward the other car. I didn't see a punch.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's deputy",
                        direct: ["\"The plate on the video led to {DL}.\""],
                        cross: ["\"{V}'s hands are empty on the video.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you identify the driver?", "\"The station camera caught the plate. It's registered to {DL}, and {DL} was driving it the next morning.\""),
                            .direct("What did you find?", "\"A 9mm pistol in the center console.\""),
                            .cross("Did {V} have a weapon?", "\"No. {V}'s hands are empty in every frame.\""),
                            .cross("{V} was the one who approached?", "\"{V} walked toward {DL} and stopped about six feet away.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["An empty-handed, angry stranger six feet away doesn't justify pointing a gun at someone's chest."],
        defenseTheory: ["A stranger charged at {DL} yelling. {DL} showed a gun, didn't fire, and left."],
        aggravating: [],
        mitigating: [],
        victimImpacts: ["{V}: \"Over a gas pump. I keep thinking how close that was.\""],
        allocutions: ["\"I thought I was about to get beat. I left. I didn't shoot.\""],
        guiltyTruths: ["A friend later told deputies {DL} bragged about \"making that dude freeze.\""],
        innocentTruths: ["{V} had been convicted twice of assault in fights started at gas stations."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "9:05 p.m. confrontation at pump 6; 9:06 p.m. clerk calls 911; video pulled."), (1, "Plate traced; pistol found in {DL}'s car; {DL} charged.")],
            howIdentified: "The license plate on the station camera.",
            notDone: [],
            defendantExam: [
                .direct("Why did you take out the pistol?", "\"{V} was coming at me yelling. I thought I was about to get jumped.\""),
                .direct("Did you fire?", "\"No. I showed it and left.\""),
                .cross("{V}'s hands were empty and {V} stopped six feet away.", "\"I didn't know that was where {V} was going to stop.\""),
                .cross("You could have gotten in your car and left without the gun.", "\"Maybe. It happened fast.\"")
            ],
            prosecutionOpening: "A gun pointed at an unarmed person over a gas pump.",
            defenseOpening: "Fear, a raised gun, no shot, and a car pulling away.",
            prosecutionClosing: "Yelling isn't deadly force. Nothing justified that gun.",
            defenseClosing: "{DL} believed {D.he} was about to be attacked, and the State must prove that belief unreasonable.",
            time: "9:05 p.m."
        )
    )

    // MARK: - After the shots into a house: a pistol strike at a party

    static let pistolWhip = CaseTemplate(
        key: "story.followup.pistolWhip", category: .violent,
        headlines: ["Partygoer Struck With Pistol, Needs Eye Surgery", "Guests Disagree on Who Swung the Gun"],
        primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 8, lesserThreshold: 5,
        specification: "Assaulted {V} with a deadly weapon, a handgun, by striking {V} in the face, inflicting serious injury: a fractured eye socket and a cut requiring fourteen stitches.",
        ageRange: 25...50, occupations: [], hasVictim: true,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {V} was struck in the face with a handgun at a house party in {HOOD} at about 12:30 a.m. on {DATE}, breaking the bone around {V}'s left eye and opening a cut that took fourteen stitches. {V} says {DL}, who had argued with {V} about a card game an hour earlier, swung the gun. One guest says the same; another says it was a different man in a black hoodie. No gun was recovered. A search of {DL}'s car found a holster but no gun. {DL} says {D.he} left the party before the fight."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Victim's Identification", "{V}, who had played cards with {DL} that night, says {DL} struck the blow."),
            E(.forensic, 2, "Medical Records", "A fractured left orbital bone requiring surgery and a 14-stitch laceration."),
            E(.statement, 2, "Guest's Account", "A guest saw {DL} swing a pistol at {V}."),
            E(.physical, 1, "Holster", "An empty pistol holster in {DL}'s car.", .search)
        ],
        defenseEvidence: [
            E(.statement, 2, "Second Guest", "Another guest says the man who swung the gun wore a black hoodie and was not {DL}."),
            E(.digital, 1, "Rideshare Receipt", "{DL}'s card paid for a rideshare from the party street at 12:34 a.m.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Party guest who was struck",
                        direct: ["\"{DL} hit me in the face with a gun.\""],
                        cross: ["\"I'd been drinking.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened before you were hit?", "\"We'd argued over a card game an hour before. I thought it was done.\""),
                            .direct("And then?", "\"I was in the kitchen doorway. {DL} came up on my left side and swung. I saw the gun in {D.his} hand right before it hit me.\"", "\"{DL} walked up on my left and swung a pistol at my face. I saw it a second before.\""),
                            .direct("What were your injuries?", "\"A broken eye socket, surgery, fourteen stitches. I still see double when I'm tired.\""),
                            .cross("You'd had several drinks?", "\"Four or five beers. I know who I played cards with.\""),
                            .cross("You were struck on the left, from your blind side?", "\"I saw {D.him} coming. Just not in time.\"")
                        ]),
            WitnessSeed(name: nil, role: "Guest at the party",
                        direct: ["\"I saw {DL} swing the gun.\""],
                        cross: ["\"It was crowded and loud.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"{DL} walked to the kitchen doorway, pulled a pistol from a waistband, and hit {V} across the face.\""),
                            .cross("How far away were you?", "\"Across the living room. Maybe fifteen feet.\""),
                            .cross("Was the room crowded?", "\"Twenty, thirty people. But I saw it.\""),
                            .cross("You're a friend of {V}'s?", "\"We work together.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's detective",
                        direct: ["\"An empty holster was in {DL}'s car.\""],
                        cross: ["\"Witnesses gave two different descriptions.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did your investigation find?", "\"{V} and one guest named {DL}. We searched {DL}'s car by warrant and found an empty pistol holster under the seat.\""),
                            .direct("And the rideshare receipt?", "\"A ride from that street at 12:34. The assault was about 12:30. It fits leaving right after.\""),
                            .cross("Another guest described a man in a black hoodie?", "\"Yes. We couldn't identify anyone from that description.\""),
                            .cross("No gun was ever recovered?", "\"No.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Second guest at the party",
                        direct: ["\"It was a guy in a black hoodie, not {DL}.\""],
                        cross: ["\"I didn't know the guy in the hoodie.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did you see?", "\"A man in a black hoodie with the hood up came through the back door and hit {V} with something black, then ran out the back.\""),
                            .direct("Was it {DL}?", "\"No. {DL} was wearing a white shirt that night. I'd been talking to {DL} earlier.\""),
                            .cross("Did you see {DL} at 12:30?", "\"Not right at 12:30.\""),
                            .cross("You're friends with {DL}?", "\"We know each other.\"")
                        ])
        ],
        prosecutionTheory: ["The person {V} argued with over cards came back with a pistol. Two eyewitnesses say so, and {DL} left in a car four minutes later."],
        defenseTheory: ["A drunk victim hit from the blind side, a guest across a crowded room, and a man in a black hoodie no one has identified."],
        aggravating: ["The defendant was armed with a deadly weapon"],
        mitigating: [],
        victimImpacts: ["{V}: \"I see double when I'm tired. I flinch when anybody comes up on my left.\""],
        allocutions: ["\"I left that party. I didn't hit anybody.\""],
        guiltyTruths: ["A pistol found months later in a ditch near the party house had {DL}'s DNA on the grip and {V}'s blood on the slide."],
        innocentTruths: ["The man in the black hoodie was identified later from another guest's phone video and charged."],
        moods: [.divided], doctrines: ["eyewitnessID", "burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "12:30 a.m. {V} struck in the kitchen doorway; 12:34 a.m. rideshare from the street paid by {DL}'s card."), (1, "{V} has surgery; names {DL}."), (3, "Guests interviewed; search of {DL}'s car finds a holster."), (10, "{DL} charged.")],
            howIdentified: "{V} and a guest named {DL}.",
            notDone: ["No phone video from the party was found despite asking every guest identified."],
            defendantExam: [
                .direct("When did you leave the party?", "\"Around 12:30. I'd lost at cards and I was done. I called a ride.\""),
                .direct("Did you hit {V}?", "\"No.\""),
                .cross("You left four minutes after {V} was hit.", "\"I didn't know anything had happened.\""),
                .cross("There was an empty holster in your car.", "\"It's an old one. I don't have a gun.\"")
            ],
            prosecutionOpening: "A card game, a grudge, and a pistol across {V}'s face.",
            defenseOpening: "Two guests, two stories, and a man in a black hoodie.",
            prosecutionClosing: "The victim knew {DL}, the guest saw {DL}, and {DL} was gone four minutes later.",
            defenseClosing: "When the witnesses can't agree on the man, the law doesn't let you pick one.",
            time: "12:30 a.m."
        )
    )
}
