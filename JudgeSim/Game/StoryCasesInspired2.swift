import Foundation

private typealias E = EvidenceSeed

/// More written cases built around the dilemmas of well-known trials. Every person, place, and fact is fictional.
extension StoryCases {

    // MARK: - 19. The lake (a pregnant spouse vanishes)

    static let harborDisappearance = CaseTemplate(
        key: "story.harborDisappearance", category: .violent,
        headlines: ["Pregnant Spouse Vanishes on Thanksgiving Morning", "Kayaking Alibi Under Scrutiny"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 6, lesserThreshold: 4,
        specification: "Killed {V}, the defendant's spouse, with malice, premeditation, and deliberation.",
        secondary: [
            SecondaryCharge(lawID: "concealingDeath", specification: "Concealed the death of {V} by disposing of {V.his} body in {LAKE}.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by giving investigators a false account of the morning {V} disappeared.", chance: 1.0, threshold: 4)
        ],
        ageRange: 28...36, occupations: ["pharmaceutical sales representative"], hasVictim: true,
        summaries: [
            "On Thanksgiving morning, {DATE}, {V}, seven months pregnant, was reported missing from the couple's home in {HOOD} by {D}, who said {D.he} had gone kayaking alone on {LAKE}, forty miles away, and came home to find {VL} gone and the dog in the yard. Three months later {VL}'s remains surfaced in a cove of {LAKE} about a mile from the boat ramp {DL} said {D.he} used. Investigators learned {DL} had a secret relationship with a coworker, had bought the kayak six days before without telling anyone, and was stopped at the Charlotte airport with a newly issued passport and $9,000 in cash the week the remains were found."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Location of the Remains", "The remains surfaced in a cove about a mile from the boat ramp {DL} named as {D.his} only alibi. Weights matching cinder-block fragments were found nearby."),
            E(.statement, 3, "The Secret Relationship", "The coworker recorded calls at police request in which {DL} claimed to be on a business trip to Denver while actually attending a candlelight vigil for {VL}."),
            E(.physical, 2, "At the Airport", "Stopped at Charlotte airport with a passport issued nine days earlier, $9,000 in cash, two phones, and a one-way ticket to Lisbon."),
            E(.physical, 2, "The Kayak Purchase", "Receipt for a two-person sit-on kayak and anchor kit bought six days before the disappearance, paid in cash.")
        ],
        defenseEvidence: [
            E(.document, 3, "No Crime Scene", "No blood, no struggle, no cause of death. Investigators found no trace evidence of {VL} in the kayak."),
            E(.document, 2, "Neighbor Sightings", "Two neighbors reported seeing a pregnant person walking a brown dog on the street at about 10:15 a.m., after {DL}'s receipt shows {D.him} at a bait shop near the lake at 9:40 a.m."),
            E(.document, 2, "Break-In Nearby", "A house two doors down was burglarized that morning; the burglars were never identified.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s coworker",
                        direct: ["\"{DL} told me {D.he} was single and had 'lost' a spouse.\""],
                        cross: ["\"{DL} never said anything violent.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you come to know {DL}?", "\"We worked the same sales territory. In September {DL} asked me out. {DL} said {D.he} was single.\""),
                            .direct("What did {DL} tell you in early November?", "\"That {DL} had 'lost' a spouse and this would be the first holiday season without them. I thought {DL} meant a death, years ago. Three weeks later {VL} disappeared.\""),
                            .direct("Why did you record your calls?", "\"When I saw {VL}'s face on the news, I called the detective. They asked me to keep talking to {DL} and record it.\""),
                            .direct("What did {DL} say on those calls?", "\"That {DL} was in Denver for work, that {D.he} missed me, that we'd go to Portugal in the spring. I could hear the vigil in the background.\""),
                            .cross("{DL} never said anything about hurting {VL}?", "\"Not a word. {D.He} talked about {VL} like {D.he} hung the moon.\""),
                            .cross("{DL} never said {D.he} wanted a new life without the baby?", "\"Not in those words.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"The remains surfaced a mile from {DL}'s alibi.\""],
                        cross: ["\"We have no cause of death and no crime scene.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} tell you on day one?", "\"That {DL} left at 7:30 a.m. to try a new kayak on {LAKE}, forty miles away, and came home around 2 to find the house empty and the dog in the yard with the leash on.\""),
                            .direct("Why does the cove matter?", "\"Of every body of water in three counties, {VL} came to the surface a mile from the ramp {DL} told us about on day one. {DL} named that ramp and bought a boat and anchor kit six days before.\""),
                            .direct("What about the airport?", "\"The week the remains surfaced, {DL} had a nine-day-old passport, nine thousand in cash, and a one-way ticket.\""),
                            .cross("No blood, no cause of death, no crime scene?", "\"None of the three. We built it from the disappearance and what came after.\""),
                            .cross("Two neighbors saw a pregnant person with a dog at 10:15, after {DL} was at the bait shop?", "\"They told us that. We couldn't confirm it was {VL}.\""),
                            .cross("You never identified the burglars two doors down?", "\"We never did. Those cases are still open.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Neighbor",
                        direct: ["\"I saw a pregnant person walking a brown dog at 10:15.\""],
                        cross: ["\"I only saw them from behind.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see Thanksgiving morning?", "\"I was taking out recycling around 10:15. A pregnant person in a gray coat was walking a brown dog toward the park. I thought it was {VL}; I'd seen them walk that dog a hundred times.\""),
                            .direct("How sure are you of the time?", "\"The parade was on and the first band had just started. I checked later. 10:12.\""),
                            .cross("You only saw them from behind?", "\"From behind and the side.\""),
                            .cross("Lots of people walk brown dogs past your house?", "\"Some. Not pregnant ones in that coat.\"")
                        ])
        ],
        prosecutionTheory: ["{D} wanted a new life without a spouse and a baby, bought a kayak and anchor kit, and sank {V} in the lake {DL} named as an alibi."],
        defenseTheory: ["No cause of death, no crime scene, and witnesses who saw {VL} alive after {DL} was forty miles away. The State is prosecuting a liar and a cheat, not proving a murder."],
        aggravating: ["The victim was pregnant"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{VL}'s parent: \"We lost our child and our grandchild on the same day. I set two extra places at Thanksgiving every year.\""],
        allocutions: ["\"I've done things I'm ashamed of. I didn't kill my family.\""],
        guiltyTruths: ["A hair caught in the kayak's anchor cleat was later matched to {VL}."],
        innocentTruths: ["One of the burglars confessed years later that {VL} surprised them in a neighbor's yard that morning."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["LAKE": ["Lake Wylie", "High Rock Lake", "Falls Lake"]],
        story: StoryExtras(
            timeline: [(-6, "{DL} buys a kayak and anchor kit with cash."),
                       (0, "9:40 a.m.: bait shop receipt near the lake. 2:20 p.m.: {DL} reports {VL} missing."),
                       (21, "Coworker begins recording calls at police request."),
                       (92, "Remains surface in a cove of the lake."),
                       (96, "{DL} stopped at Charlotte airport and arrested.")],
            howIdentified: "The remains surfaced near {DL}'s only alibi location.",
            notDone: ["The neighborhood burglary was never solved.", "No cause of death could be determined."],
            defendantExam: [
                .direct("Where were you that morning?", "\"On the lake. I'd bought the kayak to get away from everything for a few hours. I knew my life was a mess.\""),
                .direct("Why lie to your coworker?", "\"Because I'm a coward. I'd been lying to everyone for months. It doesn't make me a murderer.\""),
                .direct("Why the passport and cash?", "\"Reporters were camped on my lawn. People spat at me in the grocery store. I wanted to disappear.\""),
                .cross("You told the coworker you'd 'lost' your spouse three weeks before {VL} vanished.", "\"I said it to explain why I was alone on holidays. It was a lie, a terrible one.\""),
                .cross("An anchor kit, paid in cash.", "\"Kayaks need anchors.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Do you think {DL} killed {VL}?\"",
                                  answer: "\"I think {DL} is capable of anything now.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation", shouldSustain: true,
                                  explanation: "A lay witness's opinion on guilt is improper and speculative.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "Of every lake in North Carolina, {V} surfaced a mile from {D}'s alibi. Add the secret relationship and the one-way ticket.",
            defenseOpening: "No cause of death. No crime scene. Neighbors who saw {VL} alive. {DL} is a liar, and the State wants you to stop there.",
            prosecutionClosing: "Coincidence can't put a body a mile from the alibi.",
            defenseClosing: "Suspicion, however strong, isn't proof beyond a reasonable doubt.",
            when: .thanksgiving,
            genders: ["V": .female]
        )
    )

    // MARK: - 20. The startup (a medical device that didn't work)

    static let bloodTestStartup = CaseTemplate(
        key: "story.bloodTestStartup", category: .whiteCollar,
        headlines: ["Startup Founder Charged in Heart-Monitor Fraud", "The Device That Never Worked"],
        primaryLaw: "securitiesFraud", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "In the offer and sale of securities, made untrue statements of material fact to {V} and other North Carolina investors.",
        secondary: [
            SecondaryCharge(lawID: "securitiesFraud", specification: "Made untrue statements of material fact to a Raleigh pension fund in the sale of {STARTUP} securities.", chance: 1.0, threshold: 8),
            SecondaryCharge(lawID: "securitiesFraud", specification: "Made untrue statements of material fact to a Charlotte family office in the sale of {STARTUP} securities.", chance: 1.0, threshold: 8),
            SecondaryCharge(lawID: "falsePretenses100k", specification: "Obtained $2.4 million from investors by false pretenses using pre-recorded demo results.", chance: 1.0, threshold: 7),
            SecondaryCharge(lawID: "forgery", specification: "Forged a letter of endorsement from a hospital's chief of cardiology.", chance: 1.0, threshold: 7),
            SecondaryCharge(lawID: "uttering", specification: "Used the forged hospital endorsement letter in investor presentations, knowing it was forged.", chance: 1.0, threshold: 7)
        ],
        ageRange: 29...42, occupations: ["startup founder and CEO"], hasVictim: true,
        summaries: [
            "{D} founded {STARTUP}, a {CITY} company promising a ring that could detect heart attacks hours before they happened. North Carolina investors, including {V}, a retired dentist, put in $11 million. Former engineers say the ring never detected anything reliably, that demo results were pre-recorded, and that a letter of endorsement from a major hospital was written by {DL}. {DL} says the technology was close, that the chief engineer told {D.him} it worked, and that startups always sell the future."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Investor Deck", "Slides claiming 94 percent accuracy in a clinical study and a partnership with Atlantic Heart Institute. No such study existed; the hospital says it never partnered."),
            E(.document, 3, "Hospital Letter", "A letter of endorsement on the hospital's letterhead. The cardiologist whose signature appears says {DL} drafted it and the signature is not theirs."),
            E(.document, 2, "Pre-Recorded Demos", "Engineers' messages show investor demos played recorded data from a healthy volunteer, not live readings."),
            E(.digital, 2, "Internal Email", "{DL} to the chief engineer, six weeks before {VL}'s investment: \"Do not show raw data to anyone outside. We need the Series B.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Chief Engineer's Assurances", "Emails from the chief engineer to {DL}: \"We're at 90 percent in the lab, the clinical numbers will follow.\""),
            E(.document, 2, "No Personal Profit", "{DL} never sold shares, took a $65,000 salary, and personally lent the company $400,000."),
            E(.document, 1, "Sophisticated Investors", "Several investors were experienced venture funds that conducted their own diligence.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Investor",
                        direct: ["\"I invested because of the hospital letter and the study.\""],
                        cross: ["\"I didn't hire anyone to check the technology.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How much did you invest?", "\"Four hundred thousand dollars. About a third of my retirement.\""),
                            .direct("Why?", "\"My father died of a heart attack nobody saw coming. {DL} showed me a study, 94 percent, and a letter from Atlantic Heart. I watched the ring flag an arrhythmia live on a volunteer. I believed it.\""),
                            .direct("What happened?", "\"The company folded eighteen months later. My shares are worthless.\""),
                            .cross("You didn't hire an engineer or doctor to evaluate the technology?", "\"No. I trusted the hospital letter.\""),
                            .cross("Your subscription agreement warned that the investment was high-risk and you could lose it all?", "\"It did. It didn't say the study was fake.\"")
                        ]),
            WitnessSeed(name: nil, role: "Former senior engineer",
                        direct: ["\"I told {DL} the ring couldn't detect anything reliably.\""],
                        cross: ["\"The chief engineer told {DL} something different.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was your role?", "\"I led the signal processing team for two years.\""),
                            .direct("Did the ring work?", "\"In the lab, sitting still, it could sometimes pick up an obvious arrhythmia. In real life, walking, sleeping, it was noise. We never got close to predicting a heart attack.\""),
                            .direct("What about the demos?", "\"We played a recording from a volunteer through the app. {DL} called it 'demo mode.' Investors were told it was live.\""),
                            .direct("Did you tell {DL}?", "\"In writing, three times. The last time {DL} told me to stop being negative or find another job. I found another job.\""),
                            .cross("The chief engineer told {DL} the lab numbers were at 90 percent?", "\"The chief engineer said that. It wasn't what our data showed.\""),
                            .cross("Every startup demo shows the best case?", "\"Showing the best case is one thing. Playing a recording and calling it live is another.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Venture capital investor",
                        direct: ["\"Founders always pitch the future.\""],
                        cross: ["\"A forged letter isn't optimism.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What do investors expect from a founder?", "\"Vision. Optimism. Every founder pitches what the product will be, not what it is. Experienced investors discount that.\""),
                            .direct("Did you invest?", "\"Our fund did, two million. We did our own diligence and accepted the risk.\""),
                            .cross("You didn't know the hospital letter was written by {DL}?", "\"No. That's not optimism; that's something else.\""),
                            .cross("Or that demos were recordings?", "\"Nobody told me that. I'd have walked out of the room.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sold investors a study that didn't exist, a hospital endorsement {D.he} wrote, and recorded demos called live. That's fraud, not optimism."],
        defenseTheory: ["{DL} believed the chief engineer, poured personal money into the company, and never cashed out. Failure isn't fraud."],
        aggravating: ["The offense caused large monetary losses", "The offense involved forged documents"],
        mitigating: ["{DL} did not profit personally", "No prior criminal record"],
        victimImpacts: ["{V}: \"I'm seventy-one. That money was the cushion. Now I'm working part-time at a hardware store.\""],
        allocutions: ["\"I believed we were going to save lives. I cut corners I should never have cut. I'm sorry.\""],
        guiltyTruths: ["A deleted voice memo surfaced: \"If they ever see the raw data, we're done.\""],
        innocentTruths: ["The chief engineer later admitted fabricating the lab numbers shown to {DL}."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["STARTUP": ["Pulsewise", "CardiaRing", "Sentinel Health"]],
        story: StoryExtras(
            timeline: [(-600, "{STARTUP} founded; seed funding raised."),
                       (-42, "{DL} emails chief engineer not to show raw data outside."),
                       (0, "{V} invests $400,000 after a live demo."),
                       (540, "{STARTUP} ceases operations."),
                       (610, "Secretary of State's Securities Division refers case for prosecution.")],
            howIdentified: "{DL} made the presentations and signed the offering documents.",
            notDone: ["The chief engineer was never interviewed; the engineer left the country."],
            defendantExam: [
                .direct("Did you believe the ring worked?", "\"I believed it would. My chief engineer told me we were at 90 percent in the lab.\""),
                .direct("The hospital letter?", "\"A cardiologist there told me verbally they loved it. I drafted the letter to save time and sent it for signature. I assumed it was signed. I should never have used it without seeing it signed.\""),
                .direct("The demos?", "\"Demo mode was supposed to be labeled. I didn't make sure it was.\""),
                .cross("'Do not show raw data to anyone outside. We need the Series B.' Your words.", "\"Startups protect their data.\""),
                .cross("You told {V} the study showed 94 percent.", "\"That's what I was told.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"You were fired for poor performance, weren't you?\"",
                                  answer: "\"I resigned.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Assumes facts not in evidence", shouldSustain: true,
                                  explanation: "Nothing in evidence shows the engineer was fired. The question asserts a fact without a good-faith basis shown.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A study that didn't exist, a letter {D} wrote and signed someone else's name to, and recorded demos called live.",
            defenseOpening: "A founder who believed, who never sold a share, and who was misled by the person whose job was to tell the truth about the technology.",
            prosecutionClosing: "The forged letter alone proves {DL} knew.",
            defenseClosing: "The State must prove {DL} knew the statements were false. The chief engineer told {DL} otherwise."
        )
    )

    // MARK: - 21. The messages (can words cause a death?)

    static let textMessages = CaseTemplate(
        key: "story.textMessages", category: .violent,
        headlines: ["Teen Charged After Messages Urged Partner's Suicide", "Can Words Be Manslaughter?"],
        primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 3, lesserThreshold: 1,
        specification: "By culpable negligence, through repeated messages encouraging {VL}'s suicide, unintentionally caused the death of {V.him}.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Repeatedly sent electronic messages to {V} for the purpose of harassing and abusing {V.him}.", chance: 1.0, threshold: 1)
        ],
        ageRange: 19...19, occupations: ["college freshman"], hasVictim: true,
        summaries: [
            "{V}, 18, died by suicide in {HOOD} on {DATE}. Over the previous six weeks, {D}, {VL}'s partner of two years, sent hundreds of messages urging {V.him} to stop delaying and follow through, and was on a video call during the final hour without calling for help. Earlier in the relationship, {DL} had repeatedly urged {VL} to get treatment. The State says {DL}'s pressure was the cause, and that the failure to call for help was culpable negligence. The defense says {VL} had struggled for years, that words alone aren't a cause of death, and that {DL} was a teenager in crisis too."
        ],
        prosecutionEvidence: [
            E(.digital, 4, "Messages in the Final Weeks", "Hundreds of messages from {DL} pressing {VL} to stop postponing, including on the final day: \"You said tonight. Don't back out again.\"", .search),
            E(.digital, 3, "Video Call Records", "A 52-minute video call between {DL} and {VL} ended minutes before the time of death. {DL} called no one.", .search),
            E(.digital, 2, "Message to a Friend", "Two weeks later, {DL} wrote to a friend: \"I could have stopped it. I didn't.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "Mental Health History", "{VL} had been hospitalized twice for depression before the relationship began, and had a prior attempt at 15."),
            E(.digital, 2, "Earlier Messages", "For more than a year, {DL} had urged {VL} to see a counselor, sent hotline numbers, and offered to drive {V.him} to appointments.", .search),
            E(.document, 2, "Defendant's Own Treatment", "{DL} was being treated for depression and had started a new medication five weeks before {VL}'s death.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s parent",
                        direct: ["\"{VL} was making plans for the future.\""],
                        cross: ["\"{VL} had been hospitalized before.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How was {VL} in the month before?", "\"Better than in years. {VL} had a job at a bike shop, was saving for a car, talked about community college in the fall.\""),
                            .direct("Did you know about the messages?", "\"Not until the detective showed me. I read them in one sitting and I couldn't breathe.\""),
                            .cross("{VL} was hospitalized twice before meeting {DL}?", "\"Yes. {VL} had a hard road.\""),
                            .cross("{DL} encouraged {VL} to see a counselor many times?", "\"I didn't know that until I saw the earlier messages.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"{DL} was on a video call and didn't call for help.\""],
                        cross: ["\"{DL} wasn't physically present.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the phones show?", "\"Six weeks of escalating messages from {DL} pressing {VL} to follow through. Then a 52-minute video call that ended at 9:41 p.m. The time of death was shortly after.\""),
                            .direct("Did {DL} call 911 or {VL}'s family?", "\"No. {DL} called no one that night.\""),
                            .direct("What did {DL} say to you?", "\"That {DL} thought {VL} was going to do it anyway and {DL} wanted {VL} to stop suffering.\""),
                            .cross("{DL} was thirty miles away, never physically present?", "\"Thirty miles off. Everything happened through a phone.\""),
                            .cross("For a year before, {DL} sent hotline numbers and offered rides to appointments?", "\"The messages show that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Adolescent psychiatrist for the defense",
                        direct: ["\"{DL}'s judgment was impaired by depression and a medication change.\""],
                        cross: ["\"{DL} understood the words {D.he} wrote.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was {DL}'s condition?", "\"A depressed teenager who had just started an antidepressant that carries a warning for agitation and distorted thinking in young people, in a relationship consumed by the other person's suicidality.\""),
                            .direct("How does that matter?", "\"It can produce a kind of hopeless, distorted logic: that the person you love will never stop hurting, and that helping them die is mercy. It's tragic and wrong, but it's illness, not malice.\""),
                            .cross("{DL} understood what the words meant?", "\"Literally, yes. Whether {DL} could weigh the consequences is another question.\""),
                            .cross("{DL} could have called 911 that night?", "\"Physically, yes.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pressured a vulnerable person into suicide for six weeks, stayed on the call to the end, and called no one. That is culpable negligence that caused a death."],
        defenseTheory: ["{VL} struggled long before {DL}. {DL} spent a year begging {VL} to get help, then broke under illness and a new medication. Cruel words, however wrong, are not the cause of death the law requires."],
        aggravating: ["The victim was especially vulnerable"],
        mitigating: ["{DL} was a teenager and suffering from mental illness", "{DL} had previously encouraged {VL} to seek treatment"],
        victimImpacts: ["{VL}'s parent: \"I don't want revenge. I want every kid who reads those messages to know words can kill.\""],
        allocutions: ["\"I'll live with what I wrote every day. I thought I was helping {VL} stop hurting. I was so wrong.\""],
        guiltyTruths: ["Later-recovered messages showed {DL} telling a friend that being the grieving partner would make people pay attention."],
        innocentTruths: ["{VL}'s journal, found later, showed the plan was fixed months before {DL}'s messages changed."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-400, "Messages show {DL} urging {VL} to get treatment."),
                       (-42, "{DL} starts a new antidepressant; messages begin to change."),
                       (0, "52-minute video call ends at 9:41 p.m.; {VL} dies shortly after."),
                       (14, "{DL} messages a friend: 'I could have stopped it.'"),
                       (90, "{DL} charged with involuntary manslaughter.")],
            howIdentified: "Messages on {VL}'s phone.",
            notDone: ["{VL}'s treating therapists were never interviewed."],
            defendantExam: [
                .direct("For a year you begged {VL} to get help. What changed?", "\"I was falling apart too. New medicine, no sleep. I started believing {VL} would never stop hurting and that I was being selfish to keep {V.him} here for me.\""),
                .direct("Why didn't you call anyone that night?", "\"I froze. I told myself it was what {VL} wanted. I've replayed that hour a thousand times.\""),
                .cross("'Don't back out again.' Your words, on the last day.", "\"My words. I've read them a hundred times since.\""),
                .cross("You could have called 911 at any point in 52 minutes.", "\"I could have. I didn't.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How has this affected your family?\"",
                                  answer: "\"We'll never recover.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Relevance", shouldSustain: true,
                                  explanation: "Victim impact goes to sentencing, not to whether {DL}'s conduct caused the death.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "Six weeks of pressure, fifty-two minutes on the call, and not one call for help.",
            defenseOpening: "A year of {DL} begging {VL} to get help, then two young people both drowning. Cruel words aren't the cause the law requires.",
            prosecutionClosing: "{DL} had the power to stop it with one call, and chose not to.",
            defenseClosing: "{VL}'s illness came long before {DL}. Causation isn't proven beyond a reasonable doubt."
        )
    )

    // MARK: - 22. The restraint (a death in custody)

    static let restraintDeath = CaseTemplate(
        key: "story.restraintDeath", category: .violent,
        headlines: ["Jail Officer Charged in Inmate's Death", "Six Minutes on the Floor of Cell Block C"],
        primaryLaw: "murder2", lesserLaw: "invManslaughter", threshold: 6, lesserThreshold: 4,
        specification: "Killed {V}, a detainee, by kneeling on {V.his} back and neck during a cell extraction, with malice.",
        ageRange: 30...48, occupations: ["detention officer sergeant"], hasVictim: true,
        summaries: [
            "On {DATE}, {V}, 34, held in the Hollis County Detention Center on a probation violation, refused to leave a cell for a medical check during a mental health crisis. {D}, the sergeant leading a five-officer extraction team, pinned {VL} face-down and knelt across {V.his} upper back and neck for about six minutes after {V.he} was handcuffed. On jail video, {VL} says \"I can't breathe\" eleven times. {VL} stopped responding and died at the hospital. The defense says {VL} was violently resisting, had cocaine in {V.his} system, and died of an enlarged heart under stress."
        ],
        prosecutionEvidence: [
            E(.video, 4, "Jail Camera Video", "Six minutes and ten seconds of {DL} kneeling on {VL}'s back and neck after handcuffing, including about two minutes after {V.he} stopped moving."),
            E(.forensic, 3, "Autopsy", "Cause of death: cardiopulmonary arrest during restraint with compression of the neck and back. Manner: homicide."),
            E(.document, 2, "Detention Policy", "Training requires moving a restrained person to a recovery position as soon as they're handcuffed and checking breathing.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Toxicology and Heart", "Cocaine in {VL}'s blood and an enlarged heart weighing 520 grams."),
            E(.document, 2, "Resistance", "The first minute of video shows {VL} kicking and biting an officer before the handcuffs were on."),
            E(.document, 1, "Officer's Record", "{DL} had no use-of-force complaints in fourteen years.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Pulmonologist",
                        direct: ["\"{VL} died because {V.he} couldn't breathe under that weight.\""],
                        cross: ["\"Cocaine and a big heart made {VL} more vulnerable.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What caused {VL}'s death?", "\"Low oxygen. Face-down, handcuffed, with an adult's weight across the back and neck, the chest can't expand. On the video you can see {VL} using the shoulder to push up for air, again and again, until it stops.\""),
                            .direct("Would a healthy person have died?", "\"In my opinion, yes. Six minutes in that position with that weight would kill a healthy adult.\""),
                            .cross("Cocaine raises heart rate and oxygen demand?", "\"It does. It made {VL} more vulnerable, not less likely to die from the restraint.\""),
                            .cross("An enlarged heart can fail suddenly under stress?", "\"It can. The stress here was suffocation.\"")
                        ]),
            WitnessSeed(name: nil, role: "Detention center training captain",
                        direct: ["\"That isn't what we train.\""],
                        cross: ["\"{VL} was resisting violently at first.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does your training say?", "\"Once a person is handcuffed, get them on their side, check breathing, and stop applying weight. We teach that every year, and {DL} has taught it.\""),
                            .direct("Was the restraint after handcuffing consistent with that?", "\"Not even close. Once the cuffs are on, the threat is over.\""),
                            .cross("{VL} kicked and bit an officer before the cuffs went on?", "\"Yes, in the first minute.\""),
                            .cross("In a chaotic extraction, officers may not realize the moment resistance ends?", "\"It can be hard. That's why we train to check.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Forensic pathologist for the defense",
                        direct: ["\"The heart and drugs caused the death.\""],
                        cross: ["\"The restraint was a contributing factor.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What caused the death in your opinion?", "\"A sudden cardiac arrhythmia in an enlarged heart, triggered by cocaine and the physical exertion of fighting. That can happen whether or not someone is on the floor.\""),
                            .direct("Did the restraint matter?", "\"It was part of the stress. I wouldn't call it the cause.\""),
                            .cross("You'd agree the restraint was a contributing factor?", "\"A contributing factor, yes.\""),
                            .cross("Under the law, a contributing cause can be enough?", "\"That's a legal question.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knelt on a handcuffed detainee's back and neck for six minutes while {V} said 'I can't breathe' eleven times. That's malice."],
        defenseTheory: ["{DL} restrained a violent detainee in a chaotic extraction. {VL} died of cocaine and a damaged heart, not of a trained restraint."],
        aggravating: ["The offense was committed by a public officer", "The victim was restrained and defenseless"],
        mitigating: ["No prior use-of-force complaints in fourteen years"],
        victimImpacts: ["{VL}'s sibling: \"{VL} was in a mental health crisis and needed a doctor. {VL} got six minutes on a concrete floor.\""],
        allocutions: ["\"I'm sorry for the family's loss. I was doing the job I was trained to do.\""],
        guiltyTruths: ["An officer on the team later testified {DL} said \"{VL}'s faking\" when another officer asked to roll {VL} over."],
        innocentTruths: ["A cardiologist's review later found {VL}'s heart condition alone could have caused sudden death that day."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        story: StoryExtras(
            timeline: [(0, "11:02 a.m.: extraction begins. 11:03 a.m.: {VL} handcuffed. 11:09 a.m.: {DL} stands; {VL} unresponsive."),
                       (0, "11:26 a.m.: {VL} pronounced dead at Hollis Regional Medical Center."),
                       (3, "SBI opens an investigation; jail video preserved."),
                       (40, "Autopsy report rules the death a homicide."),
                       (55, "{DL} charged with second-degree murder.")],
            howIdentified: "{DL} led the extraction team, on video.",
            notDone: ["The other four officers' body positions were never separately analyzed."],
            defendantExam: [
                .direct("Why keep your weight on {VL}?", "\"{VL} had just bitten an officer. I was afraid that if I let up, {VL} would start fighting again. I didn't realize {VL} had stopped.\""),
                .direct("Did you hear 'I can't breathe'?", "\"I heard it. In fourteen years I've heard it from people who were breathing fine. I'll regret not listening for the rest of my life.\""),
                .cross("You teach the recovery-position rule.", "\"I do.\""),
                .cross("Two minutes after {VL} stopped moving, you were still there.", "\"I didn't know {VL} had stopped.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Have other officers at the jail used the same hold without anyone dying?\"",
                                  answer: "\"I'm sure they have.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Speculation and relevance", shouldSustain: true,
                                  explanation: "What other officers did on other occasions is speculative and doesn't bear on whether this restraint was reasonable.",
                                  doctrineID: "speculation", weight: 0))
            ],
            prosecutionOpening: "Six minutes. 'I can't breathe,' eleven times. Two minutes after {V} stopped moving. Watch the video.",
            defenseOpening: "A violent detainee, a chaotic extraction, cocaine, and an enlarged heart. The State wants you to see six minutes and stop thinking.",
            prosecutionClosing: "{DL} ignored training {D.he} taught. That's malice in the law's sense.",
            defenseClosing: "The medical evidence is divided. That's reasonable doubt about causation and intent."
        )
    )

    // MARK: - 23. The staged attack (a false report)

    static let stagedAttack = CaseTemplate(
        key: "story.stagedAttack", category: .publicOrder,
        headlines: ["Council Candidate Charged With Faking Assault", "Campaign Volunteers Tell Police It Was Staged"],
        primaryLaw: "falseReport", lesserLaw: nil, threshold: 5, lesserThreshold: 3,
        specification: "Willfully made a false report to the {CITY} Police Department that {DL} had been assaulted.",
        secondary: [
            SecondaryCharge(lawID: "obstruction", specification: "Obstructed justice by staging a fake hate crime scene at the campaign office.", chance: 1.0, threshold: 4),
            SecondaryCharge(lawID: "injuryPersonalProperty", specification: "Arranged the spray-painting of the campaign office window to stage a hate crime.", chance: 1.0, threshold: 3)
        ],
        ageRange: 32...45, occupations: ["city council candidate and small business owner"], hasVictim: false,
        summaries: [
            "Eleven days before a close {CITY} council election, {D} told police two masked people jumped {D.him} outside {D.his} campaign office at about {TIME} on {DATE}, spray-painting a slur on the window and punching {D.him}. The story went national. Police spent three weeks on it. Then two campaign volunteers said {DL} had paid them $1,800 to stage it, walked them through it the day before, and told them where the cameras were. {DL} says the attack was real and the volunteers turned on {D.him} to avoid charges."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Payment", "A $1,800 payment from {DL}'s personal account to one volunteer, memo \"door-knocking stipend,\" sent the day before. Other volunteers were paid $100 a week."),
            E(.video, 3, "Hardware Store Video", "The two volunteers buying black spray paint and ski masks two days before, with {DL}'s campaign credit card."),
            E(.digital, 2, "Messages", "{DL} to a volunteer, three days before: \"Need you two for something big this week. Keep it off the group chat.\"", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Volunteers' Changing Stories", "Both volunteers denied involvement in two interviews, then changed their accounts after being told they'd be charged with felony assault."),
            E(.forensic, 2, "Injuries", "Urgent care documented a bruised cheek and a cut lip the night of the report."),
            E(.document, 1, "Threats", "{DL} had received threatening voicemails during the campaign, reported to police weeks earlier.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Campaign volunteer",
                        direct: ["\"{DL} paid us to fake it.\""],
                        cross: ["\"We lied to police twice first.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {DL} ask you to do?", "\"Wear masks, spray-paint the window, and push {DL} down in front of the office at a set time. {DL} picked the spot because a store camera would catch it from a distance, not close enough to see faces.\""),
                            .direct("Who planned it?", "\"{DL}. We rehearsed it in the office parking lot the day before. {DL} told us what to yell.\""),
                            .direct("Why did you agree?", "\"{DL} said it would win the election and we'd have jobs in the council office. And the money.\""),
                            .cross("You lied to police twice before telling this story?", "\"Yes. We were scared.\""),
                            .cross("Your story changed after police said you'd face felony assault charges?", "\"That's when we told the truth.\""),
                            .cross("You have an agreement with the State not to be charged?", "\"For a misdemeanor plea, yes.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Detective",
                        direct: ["\"We spent three weeks on an attack that never happened.\""],
                        cross: ["\"{DL} had real injuries.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did the investigation unfold?", "\"We canvassed for days, pulled every camera in a six-block area, and found the hardware store video. That led to the volunteers.\""),
                            .direct("What did it cost?", "\"About 1,900 officer-hours. Two detectives full-time for three weeks.\""),
                            .cross("{DL} had a bruised cheek and cut lip?", "\"Yes. Minor injuries.\""),
                            .cross("{DL} had reported threatening voicemails before?", "\"Yes, weeks earlier.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Campaign manager",
                        direct: ["\"{DL} was shaken that night.\""],
                        cross: ["\"I wasn't there when it happened.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see that night?", "\"{DL} came into the back office bleeding from the lip, shaking. {DL} wanted to drop out of the race.\""),
                            .direct("What about the $1,800?", "\"The two of them were going to knock doors full-time the last two weeks. That's a stipend, about right.\""),
                            .cross("You weren't outside when it happened?", "\"I was inside working the phones.\""),
                            .cross("Other full-time volunteers were paid $100 a week?", "\"Part-time ones were.\"")
                        ])
        ],
        prosecutionTheory: ["{D} paid two volunteers to stage an attack for votes, then lied to police and the public for three weeks."],
        defenseTheory: ["{DL} was attacked. The volunteers lied twice, then changed their story to avoid felony charges. The State's case depends on them."],
        aggravating: ["The false report diverted significant public resources"],
        mitigating: ["No prior criminal record"],
        allocutions: ["\"I've told the truth from the first night.\""],
        guiltyTruths: ["A rehearsal video turned up on one volunteer's cloud backup, with {DL}'s voice giving directions."],
        innocentTruths: ["A man arrested for vandalizing another candidate's office later admitted to the attack."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["TIME": ["9:20 p.m."]],
        story: StoryExtras(
            timeline: [(-3, "{DL} messages a volunteer: 'Keep it off the group chat.'"),
                       (-2, "Volunteers buy spray paint and masks with the campaign card."),
                       (-1, "$1,800 payment to a volunteer."),
                       (0, "9:20 p.m.: {DL} reports the attack."),
                       (21, "Volunteers questioned a third time; they say the attack was staged.")],
            howIdentified: "The volunteers named {DL} after the hardware store video identified them.",
            notDone: ["The masks were never found.", "No independent analysis of {DL}'s injuries."],
            defendantExam: [
                .direct("Was the attack real?", "\"Yes. Two people in masks knocked me down and punched me. I still have the scar on my lip.\""),
                .direct("Why pay them $1,800?", "\"For full-time door-knocking the last two weeks. I paid them because they were broke college students.\""),
                .cross("They bought masks and spray paint with your campaign card two days before.", "\"I don't know what they did with my card. They had it for supplies.\""),
                .cross("'Keep it off the group chat.' What was the big thing?", "\"A surprise rally. It's politics.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"Isn't it true you were fired from your last job for stealing?\"",
                                  answer: "\"I was let go. It wasn't for stealing.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper impeachment", shouldSustain: false,
                                  explanation: "A good-faith inquiry into a specific act of dishonesty is permitted on cross to attack credibility (Rule 608(b)), though the answer must be accepted.",
                                  doctrineID: "characterEvidence", weight: 0))
            ],
            prosecutionOpening: "Masks bought on the campaign card, a payment the day before, and a rehearsal in the parking lot. {D} staged it.",
            defenseOpening: "Two witnesses who lied twice and changed their story to avoid felonies. That's the State's case.",
            prosecutionClosing: "The receipts don't lie, even if the volunteers did.",
            defenseClosing: "Without the volunteers, the State has a stipend and a shopping trip."
        )
    )
}
