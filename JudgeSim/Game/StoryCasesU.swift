import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchU: [CaseTemplate] = [noteBandit, sovereignStop, huntingAccident, fakeDoctor, stolenValor]

    // MARK: - 114. The note (a polite bank robber in a ballcap)

    static let noteBandit = CaseTemplate(
        key: "story.noteBandit", category: .robbery,
        headlines: ["'Polite Bandit' Hits Fourth Bank With a Handwritten Note", "Arrest in String of Note-Job Bank Robberies"],
        primaryLaw: "commonLawRobbery", lesserLaw: "felonyLarceny", threshold: 10, lesserThreshold: 8,
        specification: "Took $3,140 from a teller at the First Coastal Bank branch in {HOOD} by passing a note threatening violence.",
        secondary: [
            SecondaryCharge(lawID: "commonLawRobbery", specification: "Took $2,260 from a teller at the Hollis Federal Credit Union by passing a note threatening violence.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "commonLawRobbery", specification: "Took $4,000 from a teller at the Seaboard Savings branch in Wexley by passing a note threatening violence.", chance: 1.0, threshold: 0),
            // A hand in a pocket is not a dangerous weapon (State v. Hinton, 361 N.C. 207 (2007)): common law robbery.
            SecondaryCharge(lawID: "commonLawRobbery", specification: "Took $1,880 from a teller at Coastal Trust while implying, by a hand in a jacket pocket, that he had a gun.", chance: 1.0, threshold: 0),
        ],
        ageRange: 48...60, occupations: ["unemployed roofer"], forcedPriorOffenses: ["Common Law Robbery", "Breaking or Entering", "Possession of Stolen Goods"], hasVictim: true,
        summaries: [
            "Over five weeks, four bank branches in and around {HOOD} were robbed the same way: a man in a ballcap and reading glasses waited in line, slid a note across the counter reading \"I have a gun. Give me the money in your drawer. No dye packs. Thank you,\" and walked out. On {DATE}, the fourth teller, {V}, saw him put his hand in his jacket pocket. A dye pack exploded in the bag outside. A witness photographed a red-stained man getting into a gold Buick. {D}, a roofer out of work after a back injury, owns a gold Buick, and red-stained bills were found in a trash can at {D.his} motel. {DL} admits the last robbery but says {D.he} had nothing to do with the first three."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Bank Cameras", "Four videos of a man in a ballcap and reading glasses passing notes; the fourth shows the hand going into the jacket pocket."),
            E(.document, 3, "Handwriting", "The notes from all four robberies are on the same pad, in matching handwriting, with the same \"Thank you.\""),
            E(.physical, 2, "Dye-Stained Cash", "$1,640 in red-stained bills in a trash can outside {DL}'s motel room.", .search),
            E(.statement, 2, "Photo of Buick", "A witness's phone photo of a dye-stained man getting into a gold Buick with a partial tag.")
        ],
        defenseEvidence: [
            E(.document, 2, "Alibi for First Robbery", "A pharmacy receipt timestamped twenty minutes before the first robbery, thirty miles away."),
            E(.document, 1, "Handwriting Limits", "The State's examiner could only say the notes were \"probably\" written by {DL}."),
            E(.statement, 1, "No Gun", "No gun was ever found.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Teller at Coastal Trust",
                        direct: ["\"He put his hand in his pocket.\""],
                        cross: ["\"I never saw a gun.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened at your window?", "\"He slid the note across. When I looked at it, he put his hand in his jacket pocket and pushed it forward, like a gun. I gave him everything in my drawer and the dye pack.\""),
                            .cross("You never saw a gun?", "\"I saw what he wanted me to think was a gun.\"")
                        ]),
            WitnessSeed(name: nil, role: "FBI forensic document examiner",
                        direct: ["\"Same pad, same writer.\""],
                        cross: ["\"Probably isn't certainly.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What links the notes?", "\"Indentations show all four came from the same pad. The writing matches across all four, including the 'Thank you.'\""),
                            .cross("You said 'probably' {DL}?", "\"Probably {DL}. Definitely the same writer for all four.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pharmacy clerk",
                        direct: ["\"{D.He} was in my store.\""],
                        cross: ["\"The receipt time could be off.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("When was {DL} in your pharmacy?", "\"That receipt says 10:42. I remember the back brace.\""),
                            .cross("Does the register clock get set for daylight saving time?", "\"Not always. It's been an hour off before.\"")
                        ])
        ],
        prosecutionTheory: ["One man, one pad, one note, four banks. {D} admits the last; the handwriting and the method prove the rest."],
        defenseTheory: ["{DL} did the last robbery out of desperation and admits it. {DL} copied the first three robberies from the news coverage, which reported the method in detail, and {DL} has an alibi for the first."],
        aggravating: ["The offense involved multiple victims"],
        mitigating: ["The defendant has expressed remorse", "The defendant accepted responsibility"],
        victimImpacts: ["{VL}: \"I can't stand at a window with my back to the door anymore. I quit.\""],
        allocutions: ["\"I was about to be homeless with a broken back. I'm ashamed. I never had a gun.\""],
        guiltyTruths: ["The pad of paper, with the indentations of all four notes, was found later in the Buick's trunk."],
        innocentTruths: ["A man arrested in Virginia for the same kind of robberies later confessed to the first two Hollis County banks, describing details."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(-36, "First Coastal Bank robbed with a note."),
                       (-22, "Hollis Federal Credit Union robbed."),
                       (-9, "Seaboard Savings robbed; the 'Polite Bandit' nickname appears in the news."),
                       (0, "Coastal Trust robbed; dye pack explodes."),
                       (1, "{DL} arrested at a motel; stained cash recovered.")],
            howIdentified: "A witness's photo of the gold Buick and partial tag.",
            notDone: ["The pharmacy register's clock was never checked."],
            defendantExam: [
                .direct("Did you rob Coastal Trust?", "\"Yes. I'd seen the stories about the guy with the note. I thought it would work for me.\""),
                .direct("And the other three?", "\"No. I was at the pharmacy for the first one.\""),
                .cross("Same pad, same handwriting, same 'Thank you.'", "\"I copied what I read in the paper.\""),
                .cross("The newspaper never printed the 'Thank you.'", "\"Then I don't know what you're asking me.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"In your opinion, is the defendant the Polite Bandit?\"",
                                  answer: "\"Yes.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Beyond the expert's field; ultimate issue", shouldSustain: true,
                                  explanation: "A document examiner can compare writing; whether the defendant committed the robberies is for the factfinder.",
                                  doctrineID: "expertTestimony", weight: 1))
            ],
            prosecutionOpening: "Four notes from one pad, in one hand, with one 'Thank you.'",
            defenseOpening: "One robbery, admitted. Three more, borrowed from the news.",
            prosecutionClosing: "Copycats don't know what the paper didn't print.",
            defenseClosing: "Probably isn't proof beyond a reasonable doubt.",
            genders: ["D": .male],
            victim: VictimFacts(occupation: "Bank teller"),
            residence: "Lives in a weekly-rate motel in {HOOD}."
        )
    )

    // MARK: - 115. The traveler (a sovereign citizen at a traffic stop)

    static let sovereignStop = CaseTemplate(
        key: "story.sovereignStop", category: .publicOrder,
        headlines: ["Driver Claiming 'Sovereign' Status Drags Deputy at Traffic Stop", "Self-Styled 'Traveler' Rejects Court's Authority, Then Goes to Trial"],
        primaryLaw: "assaultLEO", lesserLaw: "simpleAssault", threshold: 10, lesserThreshold: 8,
        specification: "Assaulted Deputy {OFFICER}, a law enforcement officer performing official duties, by driving off while the deputy's arm was caught in the car window, inflicting physical injury.",
        secondary: [
            SecondaryCharge(lawID: "resisting", specification: "Resisted, delayed, and obstructed a deputy during a lawful traffic stop by refusing to provide identification or exit the vehicle.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "dwlr", specification: "Drove a motor vehicle on a highway while license revoked.", chance: 1.0, threshold: 0)
        ],
        ageRange: 38...55, occupations: ["self-employed handyman"], hasVictim: false,
        summaries: [
            "On {DATE}, a deputy stopped {D} on {STREET} in {HOOD} for driving with a homemade license plate reading \"PRIVATE TRAVELER - NOT FOR HIRE.\" {DL}'s license had been revoked for two years. {DL} refused to give a name, read from a laminated card claiming {D.he} was \"not a person under the jurisdiction of the corporate State of North Carolina,\" and filmed the stop on {D.his} phone. When the deputy reached in to take the keys, {DL} rolled up the window on the deputy's arm and drove off, dragging the deputy twenty feet. {DL} was arrested at home later that day. {DL} has filed forty pages of handwritten motions claiming the court has no authority over {D.him}, and has clashed with appointed counsel over every filing."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Body Camera", "The deputy's camera: the refusal, the deputy reaching for the keys, the window rising, the car pulling away."),
            E(.video, 3, "Defendant's Own Video", "{DL}'s phone video, posted online, shows the same events and {DL} saying \"you're trespassing on my property\" as the car moves."),
            E(.forensic, 2, "Deputy's Injuries", "A torn rotator cuff and road rash; the deputy was out of work for three months."),
            E(.document, 2, "License Record", "DMV records showing {DL}'s license revoked for two years.")
        ],
        defenseEvidence: [
            E(.document, 1, "Defendant's Filings", "Forty pages claiming the State has no jurisdiction over a \"living soul\" traveling for private purposes."),
            E(.video, 1, "The Reach", "The deputy reached into the car before {DL} rolled up the window."),
            E(.statement, 1, "No Intent", "{DL} says {D.he} didn't know the deputy's arm was caught.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFFICER}", role: "Sheriff's deputy",
                        direct: ["\"The window came up on my arm.\""],
                        cross: ["\"I reached into the car.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened when you reached for the keys?", "\"{D.He} rolled the window up on my arm and put it in drive. I was running alongside the car trying to pull free until I fell.\""),
                            .cross("You reached into {DL}'s car?", "\"To take the keys from a driver refusing a lawful order. That's what we're trained to do.\""),
                            .cross("You didn't wait for backup?", "\"Backup was four minutes out. I should have.\"")
                        ]),
            WitnessSeed(name: nil, role: "DMV records custodian",
                        direct: ["\"Revoked two years.\""],
                        cross: ["\"I don't know what {D.he} believes.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What was the status of {DL}'s license?", "\"Revoked, with notice mailed to the address on file. It's in the certified record.\""),
                            .cross("You can't say {DL} received the notice?", "\"The record shows it was mailed.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Friend who watched the video live",
                        direct: ["\"{D.He} was scared.\""],
                        cross: ["\"{D.He} drove off.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How did {DL} sound on the live video?", "\"Scared. {D.He}'s had bad experiences with police.\""),
                            .cross("You watched {D.him} drive away with the deputy's arm in the window?", "\"I saw the car move.\"")
                        ])
        ],
        prosecutionTheory: ["{D} decided the law didn't apply to {D.him}, refused a lawful stop, and dragged a deputy down the road. {D.His} own video proves it."],
        defenseTheory: ["{DL}'s beliefs are wrong, but beliefs aren't crimes. The deputy reached into the car first, and {DL} panicked. There was no intent to hurt anyone."],
        aggravating: [],
        mitigating: ["No prior violent record"],
        victimImpacts: ["Deputy {OFFICER}: \"I've done a thousand traffic stops. This is the one I think about.\""],
        allocutions: ["\"I do not consent to these proceedings. I am a living soul, not a corporate fiction.\""],
        guiltyTruths: ["A message {DL} posted the week before, recovered later, read: \"Next time one of them reaches in my car, I'm leaving with their arm.\""],
        innocentTruths: ["Frame-by-frame analysis of {DL}'s phone video later suggested the window was already rising before the deputy reached in."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "rightToCounsel"],
        extras: ["OFFICER": ["Kyle Brantley", "Renee Coble", "Travis Odom"]],
        story: StoryExtras(
            timeline: [(-730, "{DL}'s license is revoked."),
                       (0, "10:15 a.m.: traffic stop for a homemade plate."),
                       (0, "10:24 a.m.: deputy dragged as {DL} drives off."),
                       (0, "1:40 p.m.: {DL} arrested at home."),
                       (30, "{DL} files forty pages of motions disputing jurisdiction.")],
            howIdentified: "{DL} was identified from the vehicle and {D.his} own posted video.",
            notDone: ["The responding backup unit's camera wasn't preserved."],
            defendantExam: [
                .direct("Why didn't you give the deputy your license?", "\"Because I'm not driving, I'm traveling. A license is a contract and I never signed one.\""),
                .direct("Did you know the arm was caught?", "\"No. I rolled up my window to end the trespass.\""),
                .cross("You were filming. Your video shows the arm in the window.", "\"I wasn't looking at the video.\""),
                .cross("You understand the court has jurisdiction over you?", "\"I don't consent to it.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defendant (pro se): \"Under what authority do you claim to stop a free traveler?\"",
                                  answer: "\"North Carolina law. G.S. 20-111.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Argumentative; calls for a legal conclusion", shouldSustain: true,
                                  explanation: "A witness can't be asked to argue the law with the defendant. The court can rule on the legal question, and the 'sovereign' jurisdiction theory has been uniformly rejected.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A homemade plate, a revoked license, and a deputy's arm in a closing window.",
            defenseOpening: "Wrong beliefs aren't a crime, and panic isn't intent.",
            prosecutionClosing: "{D.He} filmed it. Watch it.",
            defenseClosing: "The deputy reached in first."
        )
    )

    // MARK: - 116. The tree stand (a hunter shoots a man he mistook for a deer)

    static let huntingAccident = CaseTemplate(
        key: "story.huntingAccident", category: .violent,
        headlines: ["Hunter Kills Man Walking His Dog, Says He Thought It Was a Deer", "No Blaze Orange, No Clear View: Hunter Charged"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 10, lesserThreshold: 8,
        specification: "Unlawfully and unintentionally killed {V} by culpable negligence in firing a rifle at an unidentified target near a public trail.",
        secondary: [
            SecondaryCharge(lawID: "trespass2", specification: "Hunted on posted land owned by the county without permission.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "obstruction", specification: "Moved {V}'s body and the dog's leash before calling 911.", chance: 1.0, threshold: 0)
        ],
        ageRange: 25...60, occupations: ["machinist", "long-haul truck driver", "plumber"], hasVictim: true,
        summaries: [
            "At dusk on {DATE}, {V}, 58, was walking a dog on a county greenway in {HOOD} when a single rifle shot hit {V.him} in the chest from 140 yards. {D}, hunting from a tree stand on posted county land that borders the trail, said {D.he} saw brown movement through the brush and thought it was a deer. {VL} was wearing a tan jacket. It was 23 minutes after legal shooting time ended. {DL} called 911 eleven minutes after the shot; investigators say the leash had been moved and the body turned. {DL} says {D.he} was trying to help."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Scope and Light Test", "A wildlife officer's test from the same stand at the same time of evening: through {DL}'s scope, a person in brown is visible but not clearly identifiable."),
            E(.document, 3, "Shooting Hours", "The shot was fired 23 minutes after legal shooting time ended."),
            E(.document, 2, "Posted Land", "County No Hunting signs on the trees around the stand."),
            E(.forensic, 2, "Scene Disturbance", "Drag marks and the leash moved about fifteen feet from where blood shows {VL} fell.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Moving Brush", "{DL} says {D.he} saw an animal-shaped movement and heard what sounded like a deer."),
            E(.document, 1, "Greenway Signs", "No signs on the greenway warned that the woods were near hunting land."),
            E(.statement, 1, "CPR", "{DL} attempted CPR before calling 911, which explains moving the body.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Wildlife enforcement officer",
                        direct: ["\"You can't tell a man from a deer at that light.\""],
                        cross: ["\"The trail wasn't signed.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did your test show?", "\"From that stand, twenty minutes past legal light, through that scope, you can see a shape. You cannot tell what it is. The first rule of hunting is you identify your target before you shoot.\""),
                            .cross("The greenway didn't warn walkers about hunting?", "\"No. But the land was posted no hunting at all.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's investigator",
                        direct: ["\"The body had been moved.\""],
                        cross: ["\"CPR would move a body.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the scene show?", "\"Blood where {VL} fell, then drag marks. The leash was in the brush, away from the body. Eleven minutes passed before the call.\""),
                            .cross("Attempting CPR would move a body?", "\"Turn it, yes. Not drag it fifteen feet.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Hunting companion",
                        direct: ["\"{D.He} is the most careful hunter I know.\""],
                        cross: ["\"We knew the land was posted.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What kind of hunter is {DL}?", "\"Careful. Hunter safety instructor for the church youth group.\""),
                            .cross("You knew that land was posted?", "\"Everybody hunts it.\"")
                        ])
        ],
        prosecutionTheory: ["{D} hunted where hunting was forbidden, after legal light, and fired at a shape {D.he} couldn't identify, beside a public trail. That's culpable negligence."],
        defenseTheory: ["A terrible accident by an experienced hunter who honestly believed {D.he} saw a deer. Bad judgment isn't culpable negligence."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has expressed remorse"],
        victimImpacts: ["{VL}'s spouse: \"The dog came home alone. That's how I knew.\""],
        allocutions: ["\"I've hunted since I was eight. I broke every rule I teach. I'm so sorry.\""],
        guiltyTruths: ["A text {DL} sent a friend that evening, before calling 911, read: \"I think I shot somebody. What do I do.\""],
        innocentTruths: ["A neighbor's trail camera, found later, showed a deer crossing the brush seconds before {VL} walked into the same spot."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "5:10 p.m.: legal shooting time ends."),
                       (0, "5:33 p.m.: the shot."),
                       (0, "5:44 p.m.: {DL} calls 911."),
                       (0, "6:02 p.m.: deputies arrive; {VL} is dead."),
                       (20, "Wildlife officer's light test; charges filed.")],
            howIdentified: "{DL} called 911 and stayed at the scene.",
            notDone: ["{DL}'s phone was not examined for the eleven minutes before the call."],
            defendantExam: [
                .direct("What did you see?", "\"Brown moving low through the brush, and I heard it step like a deer. I was sure.\""),
                .direct("Why did it take eleven minutes to call?", "\"I ran to it. I tried to help. I tried CPR. I couldn't think.\""),
                .cross("You fired after legal light, on posted land, next to a trail.", "\"After light, on posted land, next to a trail. All three.\""),
                .cross("You never saw antlers. You never saw a deer.", "\"I believed it was.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Detective, was the defendant trying to cover it up?\"",
                                  answer: "\"It looked like it.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation about the defendant's state of mind", shouldSustain: true,
                                  explanation: "The investigator can describe the scene; whether the defendant intended to conceal anything is an inference for the factfinder.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "Posted land, after dark, and a shape he couldn't identify beside a public trail.",
            defenseOpening: "A careful hunter and a terrible mistake.",
            prosecutionClosing: "You don't shoot what you can't see.",
            defenseClosing: "Culpable negligence means more than a mistake.",
            when: .months([11, 12, 1]),
            genders: ["D": .male, "V": .male]
        )
    )

    // MARK: - 117. The doctor (a fake physician giving injections)

    static let fakeDoctor = CaseTemplate(
        key: "story.fakeDoctor", category: .whiteCollar,
        headlines: ["'Doctor' at Wellness Clinic Had No Medical License", "Patients Hospitalized After Injections at Unlicensed Clinic"],
        primaryLaw: "awdwisi", lesserLaw: "simpleAssault", threshold: 10, lesserThreshold: 8,
        specification: "Assaulted {V} with a deadly weapon, a syringe of an unapproved substance, inflicting serious injury, by injecting her without valid consent obtained by fraud.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $8,400 from {V} by falsely representing herself as a licensed physician.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "falsePretenses100k", specification: "Obtained more than $100,000 from 60 patients by falsely representing herself as a licensed physician.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "forgery", specification: "Forged a medical diploma and a state medical board license certificate.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "awdwisi", specification: "Assaulted {VIC2} with a deadly weapon, a syringe, inflicting serious injury.", chance: 1.0, threshold: 0)
        ],
        ageRange: 38...50, occupations: ["wellness clinic owner"], hasVictim: true,
        summaries: [
            "For two years, {D} ran a \"regenerative wellness\" clinic in {HOOD}, wearing a white coat embroidered \"Dr. {DL}\" and offering IV vitamin drips and \"stem cell\" injections for joint pain at $4,000 a course. She had no medical degree; the diploma on the wall was from a school that doesn't exist, and the license number belonged to a retired Asheville pediatrician. On {DATE}, {V} was hospitalized with a severe infection in both knees after injections; {VIC2} was treated for sepsis a week later. Lab testing found the vials contained unsterile cord blood product from an overseas website. {DL} says she held a naturopathic certificate, never claimed to be a medical doctor, and that patients signed consent forms."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Fake Credentials", "A diploma from a nonexistent medical school and a license number belonging to another doctor.", .search),
            E(.forensic, 3, "Vial Testing", "Vials seized from the clinic contained bacteria and unapproved product ordered from an overseas website.", .search),
            E(.document, 2, "Patient Records", "Sixty patients paid a total of $214,000; intake forms list \"physician: Dr. {DL}.\""),
            E(.forensic, 2, "Medical Records", "{VL}'s septic arthritis in both knees required three surgeries.")
        ],
        defenseEvidence: [
            E(.document, 2, "Consent Forms", "Signed forms stating the treatments were \"experimental and not FDA approved.\""),
            E(.document, 1, "Naturopathy Certificate", "A certificate from an online naturopathy program."),
            E(.statement, 1, "Satisfied Patients", "Several patients say the drips helped them.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Patient",
                        direct: ["\"She said she was a doctor.\""],
                        cross: ["\"I signed the form.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What did {DL} tell you about {D.his} training?", "\"That she did a residency in orthopedics and left hospitals to do real healing. Her coat said doctor. The wall said doctor.\""),
                            .direct("What happened after the injections?", "\"Both knees swelled up and turned red. I had a fever of 104. Three surgeries. I walk with a cane now.\""),
                            .cross("You signed a form saying the treatment was experimental?", "\"I signed a form a doctor handed me.\"")
                        ]),
            WitnessSeed(name: nil, role: "State Medical Board investigator",
                        direct: ["\"That license belongs to someone else.\""],
                        cross: ["\"Naturopaths aren't licensed in North Carolina.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Whose license number is on {DL}'s certificate?", "\"A retired pediatrician in Asheville. {DL} has never been licensed to practice medicine anywhere.\""),
                            .cross("North Carolina doesn't license naturopaths?", "\"Correct. Which means no one can practice as one with injections.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Satisfied patient",
                        direct: ["\"The drips helped my energy.\""],
                        cross: ["\"I thought she was a doctor.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How was your experience?", "\"Good. The vitamin drips helped my energy, and she listened more than any doctor.\""),
                            .cross("Did you believe {DL} was a medical doctor?", "\"Yes. Wasn't she?\"")
                        ])
        ],
        prosecutionTheory: ["{D} pretended to be a doctor, forged credentials, and injected people with contaminated product from a website. Consent obtained by fraud isn't consent."],
        defenseTheory: ["{DL} offered alternative treatments to adults who signed consent forms saying they were experimental. Infections are a known risk of any injection. This is a regulatory matter, not assault."],
        aggravating: ["The offense involved multiple victims", "The defendant took advantage of a position of trust"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}: \"I wanted to keep playing with my grandkids. Now I can't get on the floor with them at all.\""],
        allocutions: ["\"I believed in what I was doing. I never meant for anyone to get hurt.\""],
        guiltyTruths: ["An email {DL} sent a supplier read: \"Don't worry about sterility certificates, my patients don't ask.\""],
        innocentTruths: ["The supplier later admitted relabeling a recalled lot and shipping it to {DL} as a new, tested batch."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["VIC2": ["Glenda Hardee", "Ron Pittman", "Teresa Vann"]],
        story: StoryExtras(
            timeline: [(-730, "Clinic opens."),
                       (-30, "{V} begins a course of knee injections."),
                       (0, "{VL} hospitalized with septic arthritis."),
                       (7, "{VIC2} treated for sepsis after an IV drip."),
                       (21, "Search warrant; vials and credentials seized."),
                       (60, "{DL} indicted.")],
            howIdentified: "Hospital reports to the health department.",
            notDone: ["Other patients were never tested for infection."],
            defendantExam: [
                .direct("Did you say you were a medical doctor?", "\"I said I was a doctor of naturopathy. People heard what they wanted.\""),
                .direct("The license number?", "\"Someone set up my paperwork. I didn't check it.\""),
                .cross("Your coat said 'Dr.' and your intake forms said 'physician.'", "\"That's a title.\""),
                .cross("You ordered the vials from a website with no sterility testing.", "\"It was a reputable company.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense: \"You chose this clinic because you distrust regular doctors, didn't you?\"",
                                  answer: "\"I'd had some bad experiences.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: false,
                                  explanation: "Why the patient chose the clinic bears on whether she relied on the claimed credentials, an element of false pretenses.",
                                  doctrineID: "relevance", weight: -1))
            ],
            prosecutionOpening: "A white coat, a fake diploma, and vials from a website.",
            defenseOpening: "Alternative care, signed consent, and a known risk.",
            prosecutionClosing: "Consent to a doctor isn't consent to an impostor.",
            defenseClosing: "Regulatory violations aren't assaults.",
            genders: ["D": .female, "V": .female]
        )
    )

    // MARK: - 118. The medals (a fake veteran's charity)

    static let stolenValor = CaseTemplate(
        key: "story.stolenValor", category: .whiteCollar,
        headlines: ["Local 'War Hero' Never Served, Records Show", "Veterans' Charity Founder Charged With Fraud"],
        primaryLaw: "falsePretenses100k", lesserLaw: "falsePretenses", threshold: 10, lesserThreshold: 8,
        specification: "Obtained more than $100,000 in donations to a veterans' charity by falsely representing himself as a decorated combat veteran and the charity as a registered nonprofit.",
        secondary: [
            SecondaryCharge(lawID: "forgery", specification: "Forged a DD-214 discharge record showing a Bronze Star and Purple Heart.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained $8,000 from {V}, a Gold Star mother, for a memorial bench that was never built.", chance: 1.0, threshold: 0)
        ],
        ageRange: 44...58, occupations: ["charity founder"], hasVictim: true,
        summaries: [
            "For six years, {D} spoke at Veterans Day events across {HOOD} in a uniform with a Bronze Star and a Purple Heart, telling of a firefight in Fallujah. {D.His} charity, Hometown Heroes Fund, raised $340,000 for veterans' housing and memorials. On {DATE}, a reporter's records request revealed that {DL} had never served in the military. The charity was never registered with the Secretary of State and had built one wheelchair ramp. Bank records show $61,000 went to a bass boat, a timeshare, and cash. {V}, whose son was killed in Afghanistan, paid $8,000 for a memorial bench in her son's name; it was never built. {DL} says {D.he} exaggerated but that the charity did real good."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Military Records", "The National Personnel Records Center has no record of {DL}'s service; the DD-214 {D.he} displayed has a serial number belonging to someone else."),
            E(.document, 3, "Bank Records", "$340,000 raised; $61,000 to personal spending; one ramp built for $2,800."),
            E(.video, 2, "Speeches", "Video of {DL} at five events describing the firefight and wearing the medals."),
            E(.document, 2, "Not Registered", "The Secretary of State has no charitable solicitation license for the fund.")
        ],
        defenseEvidence: [
            E(.document, 2, "Donations Delivered", "Receipts for $40,000 in groceries and gift cards given to veterans' families."),
            E(.statement, 1, "Veterans Helped", "Two veterans say the fund helped them with rent."),
            E(.document, 1, "Free Speech", "Lying about military service isn't a crime by itself (United States v. Alvarez).")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Gold Star mother",
                        direct: ["\"He said he served with men like my son.\""],
                        cross: ["\"I wanted to believe him.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("Why did you give {DL} $8,000?", "\"He came to my house in uniform. He said he'd lost friends over there like my son. He said the bench would be in the park by Memorial Day.\""),
                            .cross("You never asked to see a receipt?", "\"You don't ask a soldier for a receipt.\"")
                        ]),
            WitnessSeed(name: nil, role: "Army records specialist",
                        direct: ["\"He never served a day.\""],
                        cross: ["\"Records fires have destroyed some files.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Did {DL} serve?", "\"No record in any branch. The DD-214 he showed uses another soldier's service number, a man who died in 2009.\""),
                            .cross("Some records were lost in fires?", "\"From before 1973. Not from Iraq.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Veteran helped by the fund",
                        direct: ["\"He paid my rent when nobody else would.\""],
                        cross: ["\"I didn't know he never served.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did the fund do for you?", "\"Paid two months' rent when I was about to be evicted. He came himself.\""),
                            .cross("Did you know he never served?", "\"No. That makes me sick.\"")
                        ])
        ],
        prosecutionTheory: ["{D} invented a war record to raise money from a grieving community, then spent it on himself. Lying for money is fraud."],
        defenseTheory: ["The lies about service were shameful but protected speech. The charity did real good; disputes over how money was spent are civil matters."],
        aggravating: ["The offense involved multiple victims", "The defendant took advantage of a position of trust"],
        mitigating: [],
        victimImpacts: ["{VL}: \"He used my son's name to take my money. There's no bench. There's nothing.\""],
        allocutions: ["\"I wanted to be somebody. I did some good. I'll pay it back.\""],
        guiltyTruths: ["A storage unit rented by {DL} held boxes of unused donated goods and receipts showing he resold some online."],
        innocentTruths: ["The bench {VL} paid for turned up in a city warehouse, delivered and paid for by {DL} but never installed by the parks department."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-2190, "Hometown Heroes Fund founded."),
                       (-400, "{V} pays $8,000 for a memorial bench."),
                       (-10, "Reporter files a military records request."),
                       (0, "Records show {DL} never served."),
                       (45, "Bank records subpoenaed; {DL} indicted.")],
            howIdentified: "A newspaper's records request.",
            notDone: ["Not every donor was contacted."],
            defendantExam: [
                .direct("Did you serve?", "\"No. I tried to enlist and failed the physical. I've regretted it my whole life, and I started telling people a story.\""),
                .direct("Where did the money go?", "\"Most to veterans. Some I used for living expenses. I should have kept better books.\""),
                .cross("A bass boat is a living expense?", "\"I used it to take veterans fishing.\""),
                .cross("You forged a dead soldier's service number.", "\"I didn't know whose it was.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense: \"Isn't lying about medals protected by the First Amendment?\"",
                                  answer: "\"I'm not a lawyer.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Calls for a legal conclusion", shouldSustain: true,
                                  explanation: "A records witness can't be asked to give legal conclusions; Alvarez protects false claims alone, not lies used to obtain money, which is fraud.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A Bronze Star he never earned, and $340,000 from people who believed him.",
            defenseOpening: "Shameful lies, protected speech, and a charity that helped real people.",
            prosecutionClosing: "The lie was the reason people gave.",
            defenseClosing: "Bad bookkeeping isn't a crime.",
            genders: ["D": .male, "V": .female]
        )
    )
}
