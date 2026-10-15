import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchD: [CaseTemplate] = [onePunch, privateImagesPost, gunUnderSeat, burnedCar, schoolPost]

    // MARK: - 29. One punch

    static let onePunch = CaseTemplate(
        key: "story.onePunch", category: .violent,
        headlines: ["One Punch Outside {CLUB} Leaves One Dead", "Manslaughter Trial for Former Bouncer"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 3, lesserThreshold: 1,
        specification: "Unintentionally killed {V} by an unlawful assault, a single punch.",
        secondary: [
            SecondaryCharge(lawID: "simpleAssault", specification: "Assaulted {V} by punching {V.him} in the face.", chance: 1.0, threshold: 1)
        ],
        ageRange: 23...38, occupations: ["gym trainer and former bouncer"], hasVictim: true,
        summaries: [
            "At closing time on {DATE}, outside {CLUB} in {CITY}, {V}, 31, and {D} exchanged words after {VL} bumped {DL}'s friend in the line for rides. Video shows {VL} stepping toward {DL} and pointing in {D.his} face. {DL} threw a single punch. {VL} fell backward, struck the curb, and died two days later of a skull fracture and brain bleed. {DL} stayed, called 911, and held {VL}'s head still until paramedics came. The State says an unprovoked punch that kills is manslaughter. {DL} says {VL} was about to swing first."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Street Camera Video", "Sixteen seconds: {VL} steps toward {DL}, points, and says something; {DL} punches once; {VL} falls straight back and hits the curb. {VL}'s hands never rise above the waist."),
            E(.forensic, 3, "Autopsy", "Fracture at the back of the skull and brain hemorrhage from the fall; a bruise on the jaw from the punch. Blood alcohol 0.17."),
            E(.document, 1, "Training Background", "{DL} trains clients in boxing and worked as a bouncer for four years.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Witness Statement", "{DL}'s friend: \"{VL} said 'I'm about to knock you out' and stepped in.\""),
            E(.document, 2, "Victim's Earlier Behavior", "Club staff ejected {VL} an hour earlier for shoving another patron."),
            E(.statement, 2, "911 Call", "{DL}: \"I hit somebody and they're not waking up, please come fast. I'm keeping their head still.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Rideshare driver who witnessed it",
                        direct: ["\"{VL} was just talking. Then {DL} punched.\""],
                        cross: ["\"I couldn't hear the words.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you?", "\"In my car at the curb, waiting for a pickup, maybe twenty feet away with the window down.\""),
                            .direct("What did you see?", "\"Two people face to face. The shorter one, {VL}, was pointing and talking loud. {VL}'s hands were down. Then the other one, {DL}, threw a right hand, hard, and {VL} went straight back like a board. The sound of the head on the curb, I hear it at night.\""),
                            .direct("Did {VL} raise a hand to {DL}?", "\"Not that I saw. Pointing, that's it.\""),
                            .cross("You couldn't hear what {VL} said?", "\"Music from the club was too loud.\""),
                            .cross("{VL} stepped toward {DL} right before the punch?", "\"{VL} stepped in, yeah.\""),
                            .cross("{DL} stayed and helped until the ambulance came?", "\"Yes. Kneeling, holding {VL}'s head.\"")
                        ]),
            WitnessSeed(name: nil, role: "Neurosurgeon",
                        direct: ["\"The fall killed {VL}, and the punch caused the fall.\""],
                        cross: ["\"Alcohol made the fall worse.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What injuries did {VL} have?", "\"A skull fracture at the back of the head and a large bleed over the brain. We operated within an hour, but the swelling was too great.\""),
                            .direct("What caused them?", "\"The back of the head hitting concrete with full body weight. A person knocked unconscious can't break the fall.\""),
                            .cross("At 0.17 blood alcohol, {VL}'s reflexes and balance were impaired?", "\"Significantly.\""),
                            .cross("Most single punches don't cause death?", "\"Most don't. When the person falls onto concrete, they can.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s friend",
                        direct: ["\"{VL} said 'I'm about to knock you out.'\""],
                        cross: ["\"I've known {DL} since middle school.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What started it?", "\"{VL} bumped me in the ride line and spilled my drink, then got in my face. {DL} stepped between us.\""),
                            .direct("What did {VL} say?", "\"'I'm about to knock you out, you and your boy.' Then {VL} stepped right into {DL}, like this close.\""),
                            .cross("You've known {DL} since middle school?", "\"Yes.\""),
                            .cross("You'd had a few drinks too?", "\"A few. I know what I heard.\"")
                        ])
        ],
        prosecutionTheory: ["{VL} was loud and drunk, but never raised a hand. {D}, a trained fighter, threw a punch that killed. That is manslaughter."],
        defenseTheory: ["{VL}, ejected earlier for shoving, stepped into {DL} and threatened to knock {D.him} out. {DL} threw one punch in self-defense and then tried to save {VL}'s life."],
        aggravating: ["{DL} has professional fighting training"],
        mitigating: ["{DL} immediately called 911 and rendered aid", "{VL} was the initial verbal aggressor", "No prior criminal record"],
        victimImpacts: ["{VL}'s parent: \"One punch. That's all it took. I want people to know what one punch can do.\""],
        allocutions: ["\"I've thrown that punch a thousand times in a gym. I never imagined it could end a life. I'm so sorry.\""],
        guiltyTruths: ["Audio later enhanced from a phone video shows {VL} saying 'I'm just going home, man' before the punch."],
        innocentTruths: ["A second angle, from a doorbell camera, shows {VL} cocking a fist a half second before {DL} struck."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        extras: ["CLUB": ["Velvet Room", "The Anchor", "Station 9"]],
        story: StoryExtras(
            timeline: [(0, "1:58 a.m.: punch outside {CLUB}. 1:59 a.m.: {DL} calls 911."),
                       (0, "2:31 a.m.: emergency surgery at Hollis Regional."),
                       (2, "{VL} dies; {DL} charged."),
                       (10, "Street camera video obtained from the city.")],
            howIdentified: "{DL} called 911 and stayed at the scene.",
            notDone: ["Others in the ride line were not identified or interviewed."],
            defendantExam: [
                .direct("What happened?", "\"{VL} was in my friend's face, then mine. {VL} said 'I'm about to knock you out' and stepped in close. I've been sucker-punched before. I reacted.\""),
                .direct("Did you mean to hurt {VL}?", "\"I meant to stop {VL}. I didn't mean for {VL} to fall like that. Nobody falls like that in the gym.\""),
                .cross("{VL}'s hands never came up.", "\"{VL} was stepping into me. In my world, that's the punch coming.\""),
                .cross("You could have walked away.", "\"I could have. I'll think about that forever.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Isn't it true {VL} had been kicked out of the club for fighting?\"",
                                  answer: "\"I heard something about that.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Lack of personal knowledge", shouldSustain: true,
                                  explanation: "The surgeon has no personal knowledge of what happened inside the club. The fact can be proved through someone who saw it.",
                                  doctrineID: "speculation", weight: 0))
            ],
            prosecutionOpening: "{VL} never raised a hand. {D} threw a trained punch, and {VL} never woke up.",
            defenseOpening: "A drunk stranger stepped in close and threatened {DL}. {DL} threw one punch and then knelt in the street trying to save that stranger's life.",
            prosecutionClosing: "Words don't justify a punch from a trained fighter.",
            defenseClosing: "{DL} reasonably believed {D.he} was about to be hit. The law doesn't require waiting for the first blow."
        )
    )

    // MARK: - 30. The posted images

    static let privateImagesPost = CaseTemplate(
        key: "story.privateImagesPost", category: .cyber,
        headlines: ["Private Images Posted After Breakup", "Ex Says Account Was Hacked"],
        primaryLaw: "privateImages", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Knowingly disclosed private intimate images of {V} without consent, with intent to cause harm.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Repeatedly sent electronic messages to {V}'s coworkers to harass and embarrass {V.him}.", chance: 1.0, threshold: 3)
        ],
        ageRange: 23...35, occupations: ["IT help desk technician"], hasVictim: true,
        summaries: [
            "Three weeks after {V} ended a two-year relationship with {D}, private photos {VL} had shared only with {DL} appeared on a fake social media account tagged with {VL}'s employer and coworkers. The account was created from an IP address at {DL}'s apartment complex. {DL}, an IT help desk technician, says {D.his} old phone with the photos was stolen from {D.his} car two weeks earlier, that the complex's Wi-Fi is shared by 200 units, and that {D.he} would never do this."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Account Creation Records", "The fake account was created at 11:41 p.m. from an IP address belonging to the apartment complex's shared Wi-Fi. {DL}'s phone was connected to that network at the time.", .search),
            E(.digital, 3, "The Images", "Six images, with metadata showing they came from {VL}'s phone and were sent only to {DL}, according to {VL}'s message history.", .search),
            E(.digital, 2, "Messages After the Breakup", "{DL} to {VL}: \"You'll regret embarrassing me like this. Everyone will see who you really are.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "Police Report of Stolen Phone", "{DL} reported an old phone stolen from {D.his} unlocked car twelve days before the posting. That phone held the images."),
            E(.document, 2, "Shared Network", "The complex Wi-Fi serves 214 units; any resident or visitor in range could have used it."),
            E(.document, 1, "Phone Activity", "{DL}'s current phone shows a streaming app running from 11:15 p.m. to 12:30 a.m.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complainant",
                        direct: ["\"I sent those pictures to one person in the world.\""],
                        cross: ["\"I don't know who stole the phone.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Who had those images?", "\"Only {DL}. I sent them over two years, privately. I deleted them from my phone after we broke up.\""),
                            .direct("How did you find out they were posted?", "\"A coworker texted me a screenshot at work. Then my boss. Then my cousin. I threw up in the bathroom.\""),
                            .direct("What did {DL} say after the breakup?", "\"That I'd regret embarrassing {DL}, that everyone would see who I really was. I thought {DL} meant gossip.\""),
                            .cross("{DL} reported an old phone stolen before the posting?", "\"That's what I've been told.\""),
                            .cross("You never saw {DL} post anything?", "\"No.\""),
                            .cross("The account was tagged with your employer. {DL} knew where you worked, but so did a lot of people?", "\"Sure.\"")
                        ]),
            WitnessSeed(name: nil, role: "Digital forensics examiner",
                        direct: ["\"The account came from {DL}'s building network while {D.his} phone was on it.\""],
                        cross: ["\"I can't say which device created the account.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did the records show?", "\"The fake account was created and the images uploaded from the complex's public IP address, at 11:41 p.m. {DL}'s phone was connected to that network at that time.\""),
                            .direct("Could you identify the device?", "\"The platform records a browser type: an Android phone. {DL}'s current phone is an iPhone. The stolen phone was an Android.\""),
                            .cross("So the device that created the account was likely not {DL}'s current phone?", "\"Correct. It was consistent with the stolen phone, or any Android.\""),
                            .cross("Two hundred units share that IP?", "\"Yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Apartment complex manager",
                        direct: ["\"There were three car break-ins in our lot that month.\""],
                        cross: ["\"I don't know who did them.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What was happening in your lot that month?", "\"Three car break-ins in two weeks. {DL}'s was one. We sent a notice to every tenant.\""),
                            .direct("Who can use the Wi-Fi?", "\"Every tenant, their guests, anyone sitting in the parking lot who knows the password, which is posted in the lobby.\""),
                            .cross("You don't know who broke into the cars?", "\"No.\"")
                        ])
        ],
        prosecutionTheory: ["Only {DL} had the images, {D.he} threatened that 'everyone will see,' and they were posted from {D.his} building."],
        defenseTheory: ["The images were on a phone stolen from {DL}'s car before the posting, uploaded by an Android device {D.he} doesn't own, over Wi-Fi shared by two hundred units."],
        aggravating: ["The images were sent to the victim's employer and coworkers"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"I changed jobs. I changed my number. I still wonder who in the grocery store has seen them.\""],
        allocutions: ["\"I was hurt and I said ugly things. I did not post those pictures.\""],
        guiltyTruths: ["The stolen Android was later found in {DL}'s sock drawer during an unrelated search."],
        innocentTruths: ["A neighbor arrested for the car break-ins had the stolen phone and admitted posting the images to 'mess with' {DL}."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-33, "{VL} ends the relationship."),
                       (-12, "{DL} reports an old phone stolen from {D.his} car."),
                       (0, "11:41 p.m.: fake account created and images posted."),
                       (1, "{VL} reports to police."),
                       (45, "Platform records obtained by court order.")],
            howIdentified: "The images had been shared only with {DL}, and the account came from {D.his} apartment network.",
            notDone: ["The other apartment car break-ins were never linked or investigated.", "No search for the stolen phone."],
            defendantExam: [
                .direct("Did you post those images?", "\"No. I had them on my old phone, which I kept in my glovebox for music. Somebody broke into my car and took it.\""),
                .direct("What did you mean by 'everyone will see'?", "\"That people would see how {VL} treated me. I was talking about telling our friends. It was ugly and petty. It wasn't this.\""),
                .cross("You work in IT. You know how to make an account look like someone else's.", "\"I reset passwords for a living. And I'd know not to do it from my own building.\""),
                .cross("You didn't delete the images after the breakup.", "\"No. I should have.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"You'd sent intimate images to other partners before, hadn't you?\"",
                                  answer: "\"That's none of your business.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: true,
                                  explanation: "The complainant's other relationships have no bearing on whether {DL} disclosed these images without consent.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "One person had those images. That person threatened {V}, and they were posted from that person's building.",
            defenseOpening: "A stolen phone, an Android {DL} doesn't own, and a network shared by two hundred units.",
            prosecutionClosing: "The threat and the access point to one person.",
            defenseClosing: "The device that posted them wasn't {DL}'s."
        )
    )

    // MARK: - 31. The gun under the seat

    static let gunUnderSeat = CaseTemplate(
        key: "story.gunUnderSeat", category: .publicOrder,
        headlines: ["Felon Charged After Gun Found Under Car Seat", "Three People, One Pistol"],
        primaryLaw: "felonFirearm", lesserLaw: nil, threshold: 2, lesserThreshold: 1,
        specification: "Having been convicted of a felony, possessed a handgun.",
        secondary: [
            SecondaryCharge(lawID: "concealedWeapon", specification: "Carried a concealed handgun about {D.his} person in a vehicle without a permit.", chance: 1.0, threshold: 1)
        ],
        ageRange: 25...40, occupations: ["line cook"], forcedPriorOffenses: ["PWISD Cocaine"], hasVictim: false,
        summaries: [
            "At about {TIME} on {DATE}, officers stopped a sedan for a broken taillight on {STREET} in {HOOD}. {D}, who has a felony drug conviction from nine years ago, was in the front passenger seat. The car belonged to the driver, {DL}'s cousin; a third person sat in the back. Under the front passenger seat, officers found a loaded pistol. The cousin and the backseat passenger both say they've never seen it. {DL} says the same. Nobody's fingerprints were on it."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Pistol Under the Seat", "A loaded 9mm pistol on the floor directly under the front passenger seat, grip facing forward, reachable from that seat.", .search),
            E(.video, 2, "Body Camera", "As the officer approached, {DL} leaned forward and down for about two seconds, then sat up with both hands on the dash."),
            E(.document, 2, "Felony Conviction", "{DL}'s conviction for possession with intent to sell cocaine, nine years ago.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "No Prints or DNA", "No usable fingerprints; DNA on the grip was a mixture of at least three people, too complex to interpret."),
            E(.document, 2, "Gun Ownership", "The pistol was bought legally four years earlier by a man who reported it stolen; the backseat passenger once dated his sister."),
            E(.document, 1, "Reaching Room", "The backseat passenger could reach under the front passenger seat from behind, as an officer demonstrated.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "Patrol officer",
                        direct: ["\"{DL} leaned down right where the gun was.\""],
                        cross: ["\"The backseat passenger could reach it too.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you stop the car?", "\"A broken right taillight.\""),
                            .direct("What did you see as you walked up?", "\"The front passenger, {DL}, leaned forward and down, below the window, for a second or two. Then sat back with both hands on the dash, which nobody asked for.\""),
                            .direct("Where was the pistol?", "\"On the floor, directly under {DL}'s seat, grip forward, as if pushed there from the front.\""),
                            .cross("You never saw the gun in {DL}'s hands?", "\"No.\""),
                            .cross("The backseat passenger could reach under the front seat from behind?", "\"I tested it. Yes, with some effort.\""),
                            .cross("Leaning forward could be reaching for a phone, or for a seatbelt?", "\"Could be.\"")
                        ]),
            WitnessSeed(name: nil, role: "Latent print and DNA analyst",
                        direct: ["\"No usable prints, and the DNA was too mixed to interpret.\""],
                        cross: ["\"Nothing ties {DL} to the gun forensically.\""],
                        weight: 0, lay: false,
                        exam: [
                            .direct("What did you find on the pistol?", "\"No usable prints. The grip had DNA from at least three people, too complex to reliably compare to anyone.\""),
                            .cross("So nothing forensic ties {DL} to that gun?", "\"Correct.\""),
                            .cross("Nothing ties the other two passengers to it either?", "\"Correct.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s cousin, the driver",
                        direct: ["\"I picked {DL} up from work ten minutes before.\""],
                        cross: ["\"I don't know whose gun it is.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Whose car is it?", "\"Mine. I'd picked up {DL} from the restaurant ten minutes before. The backseat passenger, I'd given a ride all afternoon.\""),
                            .direct("Had {DL} been in the car before that day?", "\"Not for weeks.\""),
                            .cross("You don't know whose gun it was?", "\"No. It's not mine.\""),
                            .cross("You'd say anything to keep your cousin out of prison?", "\"I'm telling you what I know.\"")
                        ])
        ],
        prosecutionTheory: ["{D}, a convicted felon, leaned down and pushed a loaded pistol under {D.his} own seat when the officer approached."],
        defenseTheory: ["{DL} had been in the car ten minutes. The backseat passenger had been in it all afternoon and could reach under that seat. No forensic evidence ties anyone to the gun."],
        aggravating: ["The firearm was loaded"],
        mitigating: ["{DL} has been employed and arrest-free for nine years"],
        allocutions: ["\"I've stayed out of trouble nine years. I would never have a gun. I know what it'd cost me.\""],
        guiltyTruths: ["Jail calls recorded later show {DL} telling the cousin to 'say I just got in.'"],
        innocentTruths: ["The backseat passenger was later arrested with the stolen gun's matching holster in a backpack."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        extras: ["TIME": ["11:26 p.m."]],
        story: StoryExtras(
            timeline: [(0, "11:16 p.m.: cousin picks up {DL} after work. 11:26 p.m.: traffic stop; pistol found; {DL} arrested."),
                       (21, "Laboratory reports no usable prints and an uninterpretable DNA mixture."),
                       (30, "Trace shows the pistol was reported stolen.")],
            howIdentified: "{DL} was seated directly above the pistol and has a felony conviction.",
            notDone: ["The backseat passenger's phone and connection to the gun's owner were never investigated."],
            defendantExam: [
                .direct("What were you doing when the officer came up?", "\"Reaching for my phone. It slid off my lap when we braked. Then I put my hands where the officer could see them, because I know how this goes.\""),
                .direct("Was the gun yours?", "\"No. I've been in that car ten minutes. I didn't know it was there.\""),
                .cross("You put your hands on the dash before anyone asked.", "\"Because I've got a record and I know how traffic stops can go. I wanted to make it home.\""),
                .cross("You have a felony drug conviction.", "\"Nine years ago. I've been working since.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"In your experience, do people who lean down during stops usually have guns?\"",
                                  answer: "\"Usually, yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Generalizations about what 'people' usually do invite conviction by profile instead of evidence about this defendant.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A felon, a lean, and a loaded pistol directly beneath {D}'s seat.",
            defenseOpening: "Ten minutes in a cousin's car. A backseat passenger with all-afternoon access. No prints, no DNA.",
            prosecutionClosing: "Constructive possession: power and intent to control, shown by the lean.",
            defenseClosing: "Presence near a gun isn't possession."
        )
    )

    // MARK: - 32. The burned car

    static let burnedCar = CaseTemplate(
        key: "story.burnedCar", category: .whiteCollar,
        headlines: ["Stolen Car Found Burned; Owner Charged With Fraud", "Behind on Payments, Then 'Stolen'"],
        primaryLaw: "insuranceFraud", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Presented a false statement in support of an insurance claim for the theft of {DL}'s vehicle.",
        secondary: [
            SecondaryCharge(lawID: "falseReport", specification: "Made a false report to the Hollis County Sheriff's Office that {D.his} pickup had been stolen.", chance: 1.0, threshold: 4)
        ],
        ageRange: 26...45, occupations: ["real estate agent"], hasVictim: false,
        summaries: [
            "On {DATE}, {D} reported {D.his} pickup stolen from a restaurant parking lot in {HOOD} and filed a $41,000 insurance claim. Three days later the truck was found burned in a field six miles away. {DL} was three payments behind and owed more than the truck was worth. The fire was set with gasoline. Phone data puts {DL}'s phone a quarter mile from the field the night of the fire. {DL} says {D.he} drives that road to a client's house and that real thieves burn cars to destroy evidence."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Loan Records", "{DL} was three payments behind and owed $46,800 on a truck valued at $38,000. The lender had sent a repossession notice."),
            E(.digital, 3, "Phone Location", "{DL}'s phone was within a quarter mile of the field at 1:12 a.m. on the night the truck burned.", .search),
            E(.physical, 2, "Ignition", "The truck's ignition and steering column were undamaged; the fire investigator found no sign the truck was hot-wired.")
        ],
        defenseEvidence: [
            E(.document, 2, "Spare Key", "{DL} reported that a spare key had been in a magnetic box under the bumper."),
            E(.document, 2, "Client Address", "A client of {DL}'s lives on the road beside the field; {DL} showed that client a listing two weeks before."),
            E(.document, 1, "Stolen-Car Pattern", "Two other trucks were stolen and burned in the county that month.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Insurance special investigator",
                        direct: ["\"Upside-down loan, no hot-wire, phone at the field.\""],
                        cross: ["\"A spare key would explain the ignition.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did this claim get flagged?", "\"An owner behind on payments with negative equity, a truck that burned within days of being reported stolen, and no forced entry to the ignition. Those are the top three signs of owner give-up fraud.\""),
                            .direct("What did the phone records show?", "\"{DL}'s phone near the field at 1:12 a.m. the night of the fire. {DL} told me {D.he} was home asleep.\""),
                            .cross("A spare key under the bumper would explain an undamaged ignition?", "\"If the thief found it, yes.\""),
                            .cross("Two other trucks were stolen and burned in the county that month?", "\"I've read that.\""),
                            .cross("You're paid by the insurance company that would owe $41,000?", "\"I'm employed by them, yes.\"")
                        ]),
            WitnessSeed(name: nil, role: "Fire investigator",
                        direct: ["\"Someone poured gasoline in the cab.\""],
                        cross: ["\"I can't tell you who.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did the fire start?", "\"Gasoline poured in the cab and ignited. This was intentional.\""),
                            .cross("Thieves burn stolen cars to destroy fingerprints and DNA?", "\"Commonly.\""),
                            .cross("Nothing in the fire points to the owner?", "\"Nothing in the fire itself.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s client",
                        direct: ["\"{DL} drove past my place late more than once.\""],
                        cross: ["\"I didn't see {DL} that night.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"{DL} is helping me sell my house. It's on that road by the field.\""),
                            .direct("Does {DL} come by late?", "\"{DL} dropped off paperwork after showings a couple of times, at night. Real estate agents keep strange hours.\""),
                            .cross("You didn't see {DL} that night?", "\"No, I was asleep.\""),
                            .cross("At 1 a.m.?", "\"Not that late, no.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was underwater on the truck, about to lose it, and burned it for the insurance. {DL}'s phone was at the field that night."],
        defenseTheory: ["A spare key under the bumper, a rash of stolen and burned trucks, and a road {DL} drives for work. Debt isn't proof of fraud."],
        aggravating: ["The fraud involved setting a fire"],
        mitigating: ["No prior criminal record"],
        allocutions: ["\"I was behind on my truck. That's true. I didn't burn it.\""],
        guiltyTruths: ["A gas can receipt from {DL}'s credit card that afternoon surfaced in a later audit."],
        innocentTruths: ["The two men behind the other truck fires admitted taking {DL}'s truck with the spare key."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-20, "Lender sends repossession notice."),
                       (0, "{DL} reports the truck stolen; files a claim."),
                       (2, "1:12 a.m.: {DL}'s phone near the field. Truck burned that night."),
                       (3, "Truck found burned."),
                       (60, "Insurer refers case to the Department of Insurance criminal division.")],
            howIdentified: "Flagged by the insurer's special investigations unit.",
            notDone: ["The other truck thefts that month weren't compared."],
            defendantExam: [
                .direct("Where were you at 1 a.m.?", "\"Driving home from a late closing two towns over. That road is the fastest way. I told the investigator I was home because I'd lost track of the days.\""),
                .direct("Why keep a spare key under the bumper?", "\"I've locked myself out three times. Everybody in my family does it.\""),
                .cross("You were about to lose the truck.", "\"I was going to catch up. I'd just closed a sale.\""),
                .cross("You told the investigator you were home asleep.", "\"I was wrong. I checked my calendar after.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How often are claims like this one fraudulent?\"",
                                  answer: "\"In my experience, most of them.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Statistics about other people's claims invite conviction by category, not by evidence about this defendant.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Underwater, behind on payments, no hot-wire, and {D}'s phone at the field the night it burned.",
            defenseOpening: "A spare key, a crime wave of burned trucks, and an agent who drives that road for work.",
            prosecutionClosing: "Motive, opportunity, and a false alibi.",
            defenseClosing: "A wrong date isn't a lie, and debt isn't proof."
        )
    )

    // MARK: - 33. The school post

    static let schoolPost = CaseTemplate(
        key: "story.schoolPost", category: .publicOrder,
        headlines: ["Senior Charged After 'Don't Come Friday' Post", "Joke or Threat?"],
        primaryLaw: "massViolenceThreat", lesserLaw: "communicatingThreats", threshold: 1, lesserThreshold: 1,
        specification: "Threatened to commit an act of mass violence on educational property.",
        secondary: [
            SecondaryCharge(lawID: "communicatingThreats", specification: "Threatened students of {SCHOOL} with gun violence in a manner a reasonable person would believe.", chance: 1.0, threshold: 1),
            SecondaryCharge(lawID: "disorderly", specification: "Disrupted the operation of {SCHOOL} by a post that caused half the student body to stay home.", chance: 1.0, threshold: 1)
        ],
        ageRange: 18...19, occupations: ["high school senior"], hasVictim: false,
        summaries: [
            "On {DATE}, {D}, an 18-year-old senior at {SCHOOL}, posted a short video to a private story seen by about 140 classmates: a photo of the school with the caption \"don't come friday 💀\" and a song with gunshot sound effects. Within an hour, parents flooded the school with calls; Friday attendance dropped by half. Deputies found no weapons in {DL}'s home, though {D.his} parent owns two hunting rifles kept in a locked safe. {DL} says it was a joke about a canceled pep rally and a big test, and that everyone who knows {D.he} knew that."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "The Post", "The school photo, \"don't come friday 💀,\" and a rap song with gunshot sound effects, viewed by 143 accounts.", .search),
            E(.document, 2, "Attendance and Response", "Friday attendance dropped from 1,480 to 702. The school called in eight deputies."),
            E(.digital, 2, "Search History", "Two weeks earlier, {DL}'s phone searched \"how many people go to {SCHOOL}\" and \"school shooting statistics NC.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "Context", "The pep rally scheduled for Friday had been canceled that afternoon, and a calculus final was set for Friday; two friends had posted \"don't come friday\" jokes about the test earlier that week."),
            E(.document, 2, "Search Context", "{DL}'s civics class was assigned a paper on school safety policy two weeks earlier; the searches match the assignment's due date."),
            E(.document, 2, "Character", "No discipline history, honor roll, varsity soccer captain.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "School resource officer",
                        direct: ["\"Half the school stayed home in fear.\""],
                        cross: ["\"{DL} cooperated completely.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How did you learn of the post?", "\"Three parents and a student forwarded it within twenty minutes. By 9 p.m. I had forty calls.\""),
                            .direct("Why take it seriously?", "\"A picture of the school, 'don't come Friday,' a skull, and gunshots. After what's happened around the country, there's no such thing as a joke like that. I had to treat it as real.\""),
                            .direct("What happened Friday?", "\"Over half the students stayed home. Kids were crying in the parking lot. We had eight deputies on campus.\""),
                            .cross("{DL} answered the door, let you search, and apologized?", "\"Yes. {DL} was cooperative and seemed shocked.\""),
                            .cross("You found no weapon, no plan, no list, nothing?", "\"Nothing. The rifles were locked in a safe {DL} didn't have the code to.\""),
                            .cross("Other students posted 'don't come friday' about the calculus test that week?", "\"I saw some. Without the gunshots.\"")
                        ]),
            WitnessSeed(name: nil, role: "Classmate who reported the post",
                        direct: ["\"I was scared enough to tell my mom.\""],
                        cross: ["\"I don't really know {DL}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why did you report it?", "\"The gunshot sounds. I didn't know if it was a joke. My little sister goes there too.\""),
                            .cross("You don't know {DL} well?", "\"Not really. We had one class together.\""),
                            .cross("Did you know about the canceled pep rally or the calculus test?", "\"I'm not in calculus. I heard about the pep rally.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s best friend",
                        direct: ["\"It was a joke about the calc final.\""],
                        cross: ["\"The gunshots were a bad idea.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What was the joke?", "\"We'd been saying 'don't come Friday' all week because of the calc final. Like, it's going to kill us. Then they canceled the pep rally and {DL} posted it. The song was the one the soccer team plays on the bus.\""),
                            .direct("Did you take it as a threat?", "\"No. I laughed. Everybody who knows {DL} knew.\""),
                            .cross("Strangers saw it too?", "\"It was a private story, but yeah, a lot of people.\""),
                            .cross("The gunshot sounds were a bad idea?", "\"A really bad idea.\"")
                        ])
        ],
        prosecutionTheory: ["{D} posted a picture of the school, a skull, gunshots, and 'don't come Friday.' Half the school stayed home. That's a threat of mass violence, however it was meant."],
        defenseTheory: ["A bad joke about a calculus final, made to friends, by a kid with no weapons, no plan, and no history. A threat requires intent to threaten."],
        aggravating: ["The threat caused widespread fear and disruption"],
        mitigating: ["{DL} was 18 with no prior record", "{DL} cooperated fully and apologized immediately", "No weapons or plan found"],
        allocutions: ["\"I didn't think. I'd never hurt anyone. I'm so sorry for scaring people.\""],
        guiltyTruths: ["A deleted note on {DL}'s phone, recovered later, listed names of students who had bullied {D.him}."],
        innocentTruths: ["The calculus teacher later confirmed the 'don't come Friday' joke had started in class, from the teacher."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["SCHOOL": ["Hollis Central High School", "Eastview High School", "Port Hollis High School"]],
        story: StoryExtras(
            timeline: [(-14, "Civics class assigned a school-safety paper; searches on {DL}'s phone."),
                       (0, "3:40 p.m.: pep rally canceled. 8:02 p.m.: post. 9:15 p.m.: deputies at {DL}'s home; consent search; no weapons."),
                       (1, "Friday attendance drops by half."),
                       (3, "{DL} charged.")],
            howIdentified: "{DL} posted from {D.his} own account and admitted it immediately.",
            notDone: [],
            defendantExam: [
                .direct("Why did you post it?", "\"We'd been joking all week that the calc final would kill us. Then they canceled the pep rally, and I thought, perfect, nothing on Friday but the test. The song is what we play on the soccer bus.\""),
                .direct("Did you think anyone would be afraid?", "\"No. I posted it to my friends. I didn't think about anyone else seeing it, or what gunshots would mean to them. I should have.\""),
                .cross("You searched school shooting statistics two weeks before.", "\"For my civics paper. My teacher has it.\""),
                .cross("Half the school stayed home.", "\"I know. I'll never forget that.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Would you say this was a credible threat?\"",
                                  answer: "\"Absolutely.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Calls for a legal conclusion", shouldSustain: true,
                                  explanation: "Whether a statement is a true threat is the court's determination; the officer can explain why the school responded as it did.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A school, a skull, gunshots, and 'don't come Friday.' Seven hundred students stayed home.",
            defenseOpening: "A joke about a calculus test that went horribly wrong. No weapon, no plan, no intent to threaten.",
            prosecutionClosing: "In today's world, a reasonable person reads that as a threat.",
            defenseClosing: "Intent matters. {DL} meant a joke, and every person who knew {D.he} took it as one."
        )
    )
}
