import Foundation

private typealias E = EvidenceSeed

/// Written cases built around the legal dilemmas of well-known trials. Every person, place, and fact is fictional.
extension StoryCases {

    // MARK: - 14. The nursery (a parent's psychosis and the insanity defense)

    static let nurseryNight = CaseTemplate(
        key: "story.nurseryNight", category: .violent,
        headlines: ["Parent Charged in Deaths of Two Children", "Insanity Defense in {HOOD} Tragedy"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 3, lesserThreshold: 1,
        specification: "Killed {KID1} and {KID2}, the defendant's children, with malice, premeditation, and deliberation.",
        ageRange: 28...38, occupations: ["elementary school teacher"], hasVictim: true,
        summaries: [
            "On the night of {DATE}, {D}, a teacher on leave four months after the family's third child was born, was alone with the children in their home in {HOOD} while {DL}'s spouse worked an overnight shift at the hospital. Shortly after 2 a.m. a neighbor found {DL} in the backyard, soaked and shivering, saying \"they're safe now.\" Inside, the two older children, {KID1}, 6, and {KID2}, 4, had died of asphyxia in their beds. The baby was unharmed. In the months since the birth, {DL} had been seen by three providers and had stopped sleeping. The State says {DL} chose a night alone. The defense says {DL} was in a postpartum psychosis and believed {DL} was rescuing the children from something worse."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Calls to the Spouse", "At 9:40 p.m. {DL} called the spouse at work and asked whether the shift could run until 7 a.m. instead of 3 a.m. The spouse agreed to cover for a coworker."),
            E(.digital, 2, "Notes on the Phone", "A note written at 11:58 p.m.: \"I can't let them grow up into what's coming. I have to do it while they're asleep so they won't be scared.\"", .search),
            E(.statement, 2, "Statement to the Detective", "Recorded the next afternoon after Miranda warnings: \"I knew you'd come. I knew people would say it was wrong. They don't understand what I saw.\"", .statement),
            E(.forensic, 2, "Autopsy Findings", "Both children died of smothering; no defensive injuries, no other trauma.")
        ],
        defenseEvidence: [
            E(.document, 3, "Medical Records", "Three providers in four months. Notes progress from \"baby blues\" to \"severe anxiety, intrusive thoughts\" to, nine days before, \"patient reports a 'darkness' coming for the children; denies plan; refer to psychiatry.\" The referral appointment was five weeks out."),
            E(.document, 2, "Spouse's Messages", "To {DL}'s sister, six days before: \"{DL} hasn't slept in days. Says the house is 'marked.' Whispers to the kids. I don't know what to do.\""),
            E(.document, 2, "No Prior History", "No criminal record and no psychiatric history before the pregnancy. Colleagues describe a gentle, careful teacher.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"{DL} arranged to be alone with the children.\""],
                        cross: ["\"{DL} told the neighbor the children were 'safe now.'\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find in the house?", "\"The two older children in their beds, covered to the chin, as if tucked in. The baby asleep in a bassinet in the main bedroom. The back door was open. Nothing was disturbed or broken.\""),
                            .direct("Why does the call to the spouse matter?", "\"At 9:40 {DL} asked the spouse to stay at work four more hours. That created a window with no other adult in the house until seven in the morning. To me, that's planning.\""),
                            .direct("What did the note on the phone say?", "\"That {DL} had to do it while they were asleep 'so they won't be scared.' It was written about two hours before the neighbor found {DL}.\""),
                            .direct("What did {DL} say to you the next day?", "\"That {DL} knew people would say it was wrong, but they didn't understand what {DL} saw. I took that to mean {DL} understood it was wrong.\""),
                            .cross("The note says {DL} was saving them from 'what's coming.' What was coming?", "\"I don't know. {DL} never explained it in a way that made sense to me.\""),
                            .cross("{DL} told the neighbor 'they're safe now.' Not 'I'm sorry,' not 'help me.'", "\"That's what the neighbor reported.\""),
                            .cross("Someone planning to get away doesn't sit in a wet yard at 2 a.m. waiting to be found?", "\"I can't tell the court what {DL} was planning.\""),
                            .cross("You read the medical note about a 'darkness coming for the children'?", "\"I read it after the fact.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic psychiatrist for the State",
                        direct: ["\"{DL} was severely depressed but knew the act was wrong.\""],
                        cross: ["\"{DL} may have had psychotic symptoms.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you conclude?", "\"That {DL} had a major depression with postpartum onset and severe anxiety, and possibly some psychotic features. But in my opinion {DL} understood the nature of the act and that society, and the law, would see it as wrong.\""),
                            .direct("What leads you there?", "\"Arranging the spouse's absence. Choosing a time when the children were asleep. The statement 'I knew people would say it was wrong.' Those show awareness of wrongfulness.\""),
                            .direct("Isn't insanity about whether the person believed it was right?", "\"In North Carolina it's whether the person, because of mental disease, didn't know the nature and quality of the act or didn't know it was wrong. Knowing others would condemn it is knowing it's wrong in the legal sense.\""),
                            .cross("You'd agree {DL} believed {DL} was protecting the children?", "\"{DL} said so. A person can believe that and still know the law forbids it.\""),
                            .cross("You interviewed {DL} once, for three hours, eight months later?", "\"Yes.\""),
                            .cross("Postpartum psychosis can include organized planning?", "\"It can.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Perinatal psychiatrist for the defense",
                        direct: ["\"{DL} was in a postpartum psychosis and could not know it was wrong.\""],
                        cross: ["\"{DL} did take organized steps.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What is your specialty?", "\"Mental illness in pregnancy and after birth. I direct a perinatal psychiatry unit and have treated more than two hundred patients with postpartum psychosis.\""),
                            .direct("What is postpartum psychosis?", "\"A rare psychiatric emergency, one or two in a thousand births. Delusions, sometimes hallucinations, often a belief that the children are doomed or in danger. It can come and go within a single day.\""),
                            .direct("What is your opinion?", "\"That {DL} was in a postpartum psychosis with a fixed delusion that something terrible was coming for the children, and that death was a rescue. In that delusion, {DL} did not experience the act as wrong. {DL} experienced it as the only right thing left.\""),
                            .direct("What about 'I knew people would say it was wrong'?", "\"That's someone recognizing that other people don't share the delusion, not someone believing it's wrong. It's common in psychotic parents, and tragic.\""),
                            .cross("{DL} arranged the spouse's absence.", "\"Delusions can drive careful planning. That's why this illness is so dangerous.\""),
                            .cross("You testify mostly for the defense?", "\"In criminal cases, mostly. Prosecutors rarely call perinatal specialists.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was ill and overwhelmed, but planned a night alone and knew others would call it wrong. That is knowledge of wrongfulness."],
        defenseTheory: ["{DL} begged for help for four months and broke under a psychosis that turned love into a delusion. North Carolina does not punish a person who cannot know right from wrong."],
        aggravating: ["The victims were very young children"],
        mitigating: ["{DL} suffered from a severe mental illness that significantly reduced culpability", "No prior criminal record", "{DL} sought medical help before the offense"],
        victimImpacts: ["{DL}'s spouse: \"I've lost two children, and I've lost the person I married. I don't want prison. I want a hospital, and I want the doctors who sent {DL} home to answer for it.\""],
        allocutions: ["\"I would trade my life for theirs a thousand times. I didn't understand what I was doing until it was done.\""],
        guiltyTruths: ["A diary found after trial showed {DL} had written about \"getting free\" of motherhood weeks before the symptoms appeared."],
        innocentTruths: ["The treating doctor later admitted the psychiatry referral had been marked \"routine\" by mistake instead of \"urgent.\""],
        moods: [.divided], doctrines: ["insanity", "burdenOfProof"],
        extras: ["KID1": ["Nora", "Eli", "Maya", "Theo"], "KID2": ["Dylan", "Ava", "Sam", "Lily"]],
        story: StoryExtras(
            timeline: [(-120, "Third child born. Over four months, {DL} sees three providers for worsening symptoms."),
                       (-9, "Provider notes a 'darkness' coming for the children; psychiatry referral scheduled five weeks out."),
                       (0, "9:40 p.m.: {DL} asks the spouse to stay late. 2:11 a.m.: neighbor calls 911."),
                       (1, "Recorded interview with {DET} after Miranda warnings."),
                       (21, "Defense gives notice of insanity defense; court orders a forensic evaluation.")],
            howIdentified: "{DL} was the only adult in the home.",
            notDone: ["The State did not interview the providers who saw {DL} in the months before."],
            defendantExam: [
                .direct("How were you after the baby was born?", "\"I stopped sleeping. I started seeing a darkness around the house, like a stain. I knew, I just knew, something was coming for the older two, something that would make them suffer their whole lives.\""),
                .direct("Did you tell anyone?", "\"My doctor. I said it was a darkness. The doctor changed my medicine and sent me home. My psychiatry appointment was in five weeks.\""),
                .direct("Why ask your spouse to stay late?", "\"I don't remember deciding it. I remember thinking it had to be tonight, while they were asleep, so they wouldn't be afraid.\""),
                .direct("Did you think it was wrong?", "\"I thought it was the only way to keep them safe. I knew other people wouldn't understand. I didn't think it was wrong. I know now.\""),
                .cross("You wrote that you had to do it while they were asleep. That's a plan.", "\"It was. It was a plan to save them. That's how it felt.\""),
                .cross("You're a teacher. You know what it means to harm a child.", "\"Better than anyone. That's how sick I was.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Doctor, in your view is {DL} exaggerating the voices to avoid prison?\"",
                                  answer: "\"I think {DL}'s account has grown more dramatic over time.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper opinion on credibility", shouldSustain: true,
                                  explanation: "An expert may explain a diagnosis and its basis, but may not vouch for or against a witness's truthfulness.",
                                  doctrineID: "expertTestimony", weight: 1))
            ],
            prosecutionOpening: "A night arranged to be alone. A note about doing it while they slept. And {D}'s own words: 'I knew people would say it was wrong.'",
            defenseOpening: "This is a case about an illness that a doctor's note nine days before called a 'darkness coming for the children.' {DL} asked for help and was told to wait five weeks.",
            prosecutionClosing: "Mental illness is real, and tragic. But knowing that others would call it wrong is knowing it's wrong.",
            defenseClosing: "The defense has shown by the greater weight of the evidence that {DL} was psychotic and could not know right from wrong. The verdict the law provides is not guilty by reason of insanity."
        )
    )

    // MARK: - 15. The snowbank (a death outside a party, and a questioned investigation)

    static let snowbank = CaseTemplate(
        key: "story.snowbank", category: .traffic,
        headlines: ["Deputy Found Dead in Snow After Party", "Hit-and-Run or Cover-Up?"],
        primaryLaw: "murder2", lesserLaw: "invManslaughter", threshold: 3, lesserThreshold: 1,
        specification: "Killed {V} by striking {VL} with a motor vehicle while impaired, with malice.",
        ageRange: 33...46, occupations: ["physical therapist"], hasVictim: true,
        summaries: [
            "During an ice storm on {DATE}, {D} drove {DL}'s partner, {V}, a Hollis County sheriff's deputy, to a holiday party at a fellow deputy's house on {STREET}, after the two had argued at a bar. At 6:15 a.m., {DL} and two friends found {VL} unconscious in a ditch at the edge of the yard; {VL} died at the hospital of a head injury and hypothermia. {DL}'s SUV had a broken passenger mirror. The State says {DL}, drunk and furious, clipped {VL} while making a fast U-turn and drove away. The defense says {VL} went inside, something happened there, and the deputies at that party steered the investigation toward {DL}."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Mirror Glass", "Mirror glass and a black plastic housing piece matching {DL}'s SUV, found in the ditch eleven days later during a second search of the yard."),
            E(.digital, 2, "SUV Data", "At 12:24 a.m. the SUV made a sharp U-turn at 19 mph within about 30 feet of where {VL} was found."),
            E(.statement, 2, "Statements to First Responders", "A firefighter says {DL} repeated, \"Did I do this? I did this,\" while giving CPR."),
            E(.forensic, 2, "Blood Alcohol", "Blood drawn at 8:50 a.m. measured 0.07; extrapolated to roughly 0.12 to 0.21 at 12:24 a.m.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Injury Pattern", "No leg, hip, or pelvic injuries; a fractured skull at the back of the head; bruising around both eyes; and scratches on the right forearm."),
            E(.document, 2, "Investigator's Messages", "The lead investigator was friends with the homeowner and sent messages mocking {DL} during the investigation. The investigator was later removed from the case."),
            E(.document, 2, "Second Search", "The mirror pieces were found eleven days later, after the SUV had been in the Sheriff's Office garage, in an area searched twice before.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Crash reconstructionist",
                        direct: ["\"The U-turn put the mirror right where {VL} was standing.\""],
                        cross: ["\"A mirror strike doesn't usually fracture the back of the skull.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What does the vehicle data show?", "\"At 12:24 a.m. the SUV braked hard, turned sharply, and accelerated to 19 miles per hour within a few seconds, at the spot where the yard meets the road.\""),
                            .direct("How could that cause the death?", "\"The passenger mirror is at about elbow height on an adult. A strike at that speed could throw a person off balance, backward, into the ditch, where the head hits the frozen culvert.\""),
                            .direct("Does the mirror match?", "\"The glass and housing pieces found in the ditch are from that model and fit the broken mirror on {DL}'s SUV.\""),
                            .cross("The pieces were found eleven days later, in an area searched twice?", "\"That's when they were found. Snow had melted by then.\""),
                            .cross("A mirror strike at 19 mph usually bruises the arm or hip of the person struck?", "\"Usually there's an injury where the mirror contacts.\""),
                            .cross("There's no injury to {VL}'s hip, and the arm shows scratches, not impact bruising?", "\"That's correct.\"")
                        ]),
            WitnessSeed(name: nil, role: "Firefighter-paramedic",
                        direct: ["\"{DL} kept saying 'Did I do this? I did this.'\""],
                        cross: ["\"{DL} was hysterical and doing CPR.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you find?", "\"A person in uniform pants and a parka in the ditch, cold to the touch, no pulse at first. {DL} was doing CPR, screaming.\""),
                            .direct("What did {DL} say?", "\"Over and over: 'Did I do this? I did this.' I couldn't tell if it was a question or not.\""),
                            .cross("{DL} was trying to save {VL}'s life when you got there?", "\"Yes. Hard compressions. I had to pull {DL} back.\""),
                            .cross("You first wrote this down three weeks later, after investigators asked you about it?", "\"That's when I gave a statement.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Forensic pathologist for the defense",
                        direct: ["\"These injuries look like a fall or a fight, not a vehicle.\""],
                        cross: ["\"I can't say exactly what happened.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the injuries show?", "\"A fracture at the back of the skull from a fall onto a hard surface, bruises around both eyes that often follow that fracture, and scratches on the forearm. Nothing on the legs, hips, or torso.\""),
                            .direct("Is that consistent with a vehicle strike?", "\"Not typical. A moving vehicle almost always leaves impact injuries. This looks more like someone fell, or was knocked, backward onto something hard.\""),
                            .direct("And the scratches?", "\"Parallel, shallow, curved. They could be from an animal, from brush in the ditch, or from a struggle. They don't look like glass.\""),
                            .cross("You can't rule out a mirror knocking {VL} backward?", "\"I can't rule it out. I'd expect a mark where it hit.\""),
                            .cross("You never examined the body yourself?", "\"No. I reviewed the autopsy photos and report.\"")
                        ])
        ],
        prosecutionTheory: ["{D}, drunk and angry after a fight, whipped the SUV around in the dark and knocked {V} into a ditch, then left {VL} to freeze."],
        defenseTheory: ["The injuries don't fit a car, the mirror pieces showed up eleven days later, and the investigator was a friend of the homeowner who mocked {DL}. The answer is inside that house."],
        aggravating: ["{DL} left {VL} in freezing conditions"],
        mitigating: ["No prior criminal record", "{DL} searched for {VL} and attempted CPR"],
        victimImpacts: ["{VL}'s parent: \"Whatever happened, my child lay out there all night. Somebody knows.\""],
        allocutions: ["\"I loved {VL}. I didn't hit {VL}. I've spent every day since wondering what happened in that house.\""],
        guiltyTruths: ["A neighbor's trail camera, found years later, showed the SUV's mirror striking a figure at 12:24 a.m."],
        innocentTruths: ["A party guest later admitted {VL} had been in a fight in the garage and was carried outside."],
        moods: [.divided], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["TIME": ["12:24 a.m."]],
        story: StoryExtras(
            timeline: [(0, "12:24 a.m.: SUV records a sharp U-turn outside the house. 6:15 a.m.: {VL} found in a ditch; 911 call."),
                       (0, "8:50 a.m.: blood drawn from {DL}."),
                       (2, "SUV towed to the Sheriff's Office garage."),
                       (11, "Second yard search finds mirror glass and housing."),
                       (38, "{DL} charged with second-degree murder.")],
            howIdentified: "{DL} dropped {VL} off, and {DL}'s SUV had a broken mirror.",
            notDone: ["The house was never searched, and partygoers' phones were never examined.", "The scratches were never swabbed for DNA."],
            defendantExam: [
                .direct("What happened when you dropped {VL} off?", "\"We'd been arguing. I let {VL} out and waited to see if {VL} would come back out. {VL} didn't answer texts. I turned around and went home, angry.\""),
                .direct("How did your mirror break?", "\"I clipped the garage door frame backing out that morning, in the ice, when I went looking for {VL}. I told the detective that the first day.\""),
                .direct("What did you mean, 'Did I do this?'", "\"I meant, did I cause this by leaving? By fighting? I was out of my mind.\""),
                .cross("You'd had at least five drinks.", "\"Yes. I shouldn't have driven. I didn't hit anyone.\""),
                .cross("You made a sharp U-turn at the exact spot.", "\"Because that's where the road is. I turned around to go home.\""),
                .cross("You left {VL} in an ice storm.", "\"I left {VL} at a party full of {VL}'s friends. I thought {VL} was inside.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Did {DL} seem guilty to you?\"",
                                  answer: "\"{DL} seemed like someone who knew what {DL} had done.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation", shouldSustain: true,
                                  explanation: "A witness can describe what {DL} said and did, not offer an opinion on what {DL} knew or whether {DL} was guilty.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "A fight, drinks, a U-turn at 19 miles an hour, a broken mirror, and {D}'s own words: 'I did this.'",
            defenseOpening: "No impact injuries. Mirror glass found eleven days later. An investigator who was friends with the homeowner. You'll see why the doubt here is not just reasonable but overwhelming.",
            prosecutionClosing: "The data, the glass, and the admission all point to the same moment: 12:24 a.m.",
            defenseClosing: "When the investigation itself can't be trusted, neither can its conclusion.",
            when: .months([12, 1, 2])
        )
    )

    // MARK: - 16. The barn (a prominent family, a theft, and a video)

    static let kennelShooting = CaseTemplate(
        key: "story.kennelShooting", category: .violent,
        headlines: ["Car Dealer Charged in Spouse's Shooting", "The Video in the Horse Barn"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 5, lesserThreshold: 3,
        specification: "Killed {V}, the defendant's spouse, with a rifle, with malice, premeditation, and deliberation.",
        ageRange: 47...60, occupations: ["owner of a car dealership"], forcedPriorOffenses: ["Driving While Impaired"], hasVictim: true,
        summaries: [
            "{D} owns the biggest car dealership in Hollis County, founded by {DL}'s grandparent. At 9:52 p.m. on {DATE}, {DL} called 911 to report finding {DL}'s spouse, {V}, shot in the horse barn on the family's farm outside {HOOD}. {DL} said they had been at the house watching a game and then drove to check on an elderly parent. That afternoon, the dealership's bank had frozen its accounts over $1.2 million in customer down payments that never reached lenders. A video {VL} took of a sick horse at 8:31 p.m. captured {DL}'s voice in the barn."
        ],
        prosecutionEvidence: [
            E(.video, 4, "Barn Video", "A 38-second video on {VL}'s phone, timestamped 8:31 p.m., of a lame horse. Two voices are heard; three family members identify the second as {DL}'s. {DL} told police they were never at the barn that night."),
            E(.document, 3, "Bank Freeze", "The bank froze the dealership's accounts at 3:15 p.m. over $1.2 million in diverted down payments. {VL} was a co-signer on the business loans and had asked the bookkeeper that week for the account statements."),
            E(.digital, 2, "Phone and Vehicle Data", "{DL}'s phone shows no movement from 8:20 to 8:45 p.m., then 2,100 steps in 6 minutes. The truck's data shows {DL} driving 85 mph to the parent's house and back.", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "No Physical Evidence", "No blood or gunshot residue on {DL}'s clothes or truck; the rifle was never found."),
            E(.document, 2, "A Fired Farmhand", "A farmhand fired two weeks earlier for stealing tack had threatened {VL} and owned a rifle of the same caliber. The farmhand's alibi was never checked."),
            E(.document, 1, "Family Members", "Relatives describe {DL} as devoted to {VL}, if secretive about money.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "SBI agent",
                        direct: ["\"{DL} lied about being at the barn.\""],
                        cross: ["\"We never found the rifle.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did {DL} tell you that night?", "\"That {DL} was at the house from about eight watching a game, left around 9:00 to check on {DL}'s parent, came back, and found {VL}. {DL} said they never went to the barn.\""),
                            .direct("What did the video show?", "\"That at 8:31 {DL} was in the barn with {VL}. We got it off {VL}'s phone nine months later. {VL}'s phone has no activity after 8:37.\""),
                            .direct("Why the money?", "\"The bank froze the accounts that afternoon. {VL} had been asking for statements. The State's theory is that {VL} was about to find out, and that a tragedy would buy {DL} sympathy and time.\""),
                            .direct("What about the steps and the drive?", "\"Twenty-five minutes of no movement while {DL} says {DL} was on the couch, then a burst of 2,100 steps, then a drive at 85 to establish an alibi at the parent's house.\""),
                            .cross("No blood, no residue, no rifle?", "\"Correct.\""),
                            .cross("A fired farmhand who threatened {VL} owned a rifle of the same caliber?", "\"We looked at the farmhand early on. Not in depth.\""),
                            .cross("Your agency didn't open the phone for nine months?", "\"It took that long to get it unlocked.\"")
                        ]),
            WitnessSeed(name: nil, role: "Dealership bookkeeper",
                        direct: ["\"{VL} was asking for the statements that week.\""],
                        cross: ["\"{VL} never said {VL} was afraid of {DL}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did {VL} ask you?", "\"On Tuesday, {VL} asked for copies of the loan and deposit statements. {VL} said 'something doesn't add up.' I told {VL} {DL} handled those.\""),
                            .direct("What happened Friday afternoon?", "\"The bank called at 3:15 and froze everything. I called {DL}. {DL} said, 'I'll take care of it, don't tell anybody.'\""),
                            .cross("{VL} never said {VL} was afraid of {DL}?", "\"No. {VL} was worried about the business.\""),
                            .cross("Stealing from a business isn't the same as killing someone.", "\"I know that.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Ballistics expert for the defense",
                        direct: ["\"The rifle could match the farmhand's.\""],
                        cross: ["\"It could match thousands of rifles.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What do the bullets tell you?", "\"Two .243 caliber bullets from a rifle with six-groove, right-twist rifling. The farmhand's rifle is a .243 with that rifling.\""),
                            .direct("Was it ever tested?", "\"No. Nobody asked for it.\""),
                            .cross("Thousands of rifles in this county share that caliber and rifling?", "\"Thousands.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was caught stealing that afternoon and killed {V} before {VL} could find out, then lied about being at the barn."],
        defenseTheory: ["No blood, no residue, no rifle. A fired farmhand who threatened {VL} was never seriously checked. {DL} lied out of panic, not guilt."],
        aggravating: ["The offense was committed to avoid exposure of other crimes"],
        mitigating: ["No prior violent record"],
        victimImpacts: ["{VL}'s sibling: \"{VL} was the best person in that family. Find out who did this and make them pay.\""],
        allocutions: ["\"I lied about the barn because I knew how it would look with the money. I loved {VL}. I didn't kill {VL}.\""],
        guiltyTruths: ["A blue tarp with gunshot residue was found in the parent's shed a year after the trial."],
        innocentTruths: ["The farmhand was arrested two years later with a .243 rifle that matched the barn bullets."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof"],
        extras: ["TIME": ["8:31 p.m."]],
        story: StoryExtras(
            timeline: [(0, "3:15 p.m.: bank freezes dealership accounts."),
                       (0, "8:31 p.m.: barn video recorded. 8:37 p.m.: last activity on {VL}'s phone. 9:52 p.m.: {DL} calls 911."),
                       (272, "{VL}'s phone unlocked; barn video found."),
                       (310, "{DL} charged with first-degree murder.")],
            howIdentified: "The barn video placed {DL} with {VL} minutes before the shooting.",
            notDone: ["The fired farmhand's alibi and rifle were never checked.", "The rifle was never found."],
            defendantExam: [
                .direct("Why did you tell police you weren't at the barn?", "\"Because I knew the bank had frozen the accounts. I knew how it would look. I panicked, and then I was stuck with the lie.\""),
                .direct("What happened at the barn?", "\"{VL} called me down to look at the mare. We talked for a few minutes. I went back to the house. {VL} was fine.\""),
                .direct("Did you take the money?", "\"Yes. I moved deposits to cover other losses. I'm going to answer for that. It has nothing to do with this.\""),
                .cross("You lied to police for nine months.", "\"Yes.\""),
                .cross("Twenty-one hundred steps in six minutes, then 85 miles an hour.", "\"I was worried about my parent. I always drive fast.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Isn't it true {VL} had a gambling problem?\"",
                                  answer: "\"I heard rumors.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance and speculation", shouldSustain: true,
                                  explanation: "Rumors about the victim's habits, with no connection to the shooting, are irrelevant and speculative.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "A theft exposed at 3:15. {VL} asking questions. A video placing {D} in the barn at 8:31, and nine months of lying about it.",
            defenseOpening: "{DL} is a thief and a liar, and will answer for that. But no blood, no residue, no rifle, and a farmhand nobody checked. That's not proof of murder.",
            prosecutionClosing: "Only a killer needs that lie.",
            defenseClosing: "A lie about where you were is not proof of what you did."
        )
    )

    // MARK: - 17. Nineteen days (a missing child and a parent's lies)

    static let missingToddler = CaseTemplate(
        key: "story.missingToddler", category: .family,
        headlines: ["Parent Charged After Child Missing 19 Days", "Cadaver Dog Alerts in Garage"],
        primaryLaw: "murder1", lesserLaw: "felonyChildAbuse", threshold: 4, lesserThreshold: 2,
        specification: "Killed {KID}, age three, the defendant's child, with malice, premeditation, and deliberation.",
        ageRange: 20...28, occupations: ["cell phone store sales associate"], forcedPriorOffenses: ["Misdemeanor Larceny"], hasVictim: true,
        summaries: [
            "{KID}, three, was last seen at day care on {DATE}. For nineteen days {D} told family that {KID} was at the beach with a coworker's relative. When {DL}'s parent pressed and called the Sheriff's Office, {DL} admitted {KID} was missing but said {KID} had been taken from a park. Five weeks later, {KID}'s remains were found in a storage tote in a creek bed four miles from the apartment. The medical examiner could not determine a cause of death. The State says {DL} drugged and suffocated {KID}. The defense says {KID} died of an accidental overdose of allergy medicine and {DL}, terrified, hid it."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Cadaver Dog Alert", "A certified human remains detection dog alerted on {DL}'s storage closet and the trunk of {DL}'s car. A tote of the same brand and color was missing from a set in the closet."),
            E(.document, 3, "The Lies", "{DL} invented the beach trip, the coworker's relative, and a park abduction. Police found no coworker by that name and no park witnesses."),
            E(.digital, 2, "Searches", "Three weeks before {KID} went missing, {DL}'s phone searched \"how much benadryl to make a toddler sleep\" and \"how long does it take.\"", .search),
            E(.statement, 2, "Nineteen Days", "Social media posts show {DL} at a concert and two parties while {KID} was missing.")
        ],
        defenseEvidence: [
            E(.forensic, 3, "No Cause of Death", "With skeletal remains, the medical examiner listed the cause and manner of death as undetermined."),
            E(.document, 2, "Pharmacy Records", "{KID} had been prescribed an antihistamine for allergies by a pediatrician, with written dosing instructions."),
            E(.document, 2, "No Prior Abuse", "Day care staff and the pediatrician never observed signs of abuse or neglect.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s parent",
                        direct: ["\"{DL} kept making excuses for nineteen days.\""],
                        cross: ["\"{DL} was a loving parent, as far as I saw.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("When did you last see {KID}?", "\"Sunday dinner, the week before. Then {DL} said {KID} was at the beach with a friend from work. Every time I asked to FaceTime, there was a reason.\""),
                            .direct("What made you call the Sheriff?", "\"On day nineteen I drove to the apartment and {KID}'s bed hadn't been slept in. The car seat was gone. {DL} couldn't give me a phone number for the friend. I called.\""),
                            .direct("What did {DL} say then?", "\"That {KID} was taken from the park and {DL} was too scared to tell anyone. That made no sense to me.\""),
                            .cross("You saw {DL} with {KID} every week. Loving?", "\"Yes. {DL} loved that child.\""),
                            .cross("{DL} has always hidden things when scared, since childhood?", "\"{DL} has always lied to get out of trouble. Small things. Never anything like this.\"")
                        ]),
            WitnessSeed(name: nil, role: "Cadaver dog handler",
                        direct: ["\"My dog alerted on the closet and the trunk.\""],
                        cross: ["\"An alert isn't proof of a death.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What is your dog trained to find?", "\"Human remains odor. She's certified annually and has a documented accuracy rate above ninety percent in controlled tests.\""),
                            .direct("What happened at the apartment?", "\"She gave a final trained response at the storage closet and at the trunk of {DL}'s car. Nowhere else in the apartment.\""),
                            .cross("An alert tells you odor, not a cause or a time of death?", "\"Correct.\""),
                            .cross("Dogs can alert falsely, especially when the handler expects a find?", "\"It happens. We run blind tests to prevent it.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pediatric toxicologist for the defense",
                        direct: ["\"An accidental antihistamine overdose can kill a toddler.\""],
                        cross: ["\"I can't prove that's what happened.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How dangerous are these medicines for small children?", "\"Antihistamines are a leading cause of accidental poisoning deaths in toddlers. Parents give a little extra for sleep, a child gets into the bottle, and it turns fatal.\""),
                            .direct("Could this be an accident?", "\"It could. The searches show a parent wondering about doses for sleep, which is, sadly, common. It isn't proof of intent to kill.\""),
                            .cross("You can't tell the court how {KID} died?", "\"No one can, from these remains.\""),
                            .cross("An accident doesn't explain the tote and the creek.", "\"No. That's what a terrified person does after.\"")
                        ])
        ],
        prosecutionTheory: ["{D} drugged and smothered {KID}, hid the body in a tote, and partied for nineteen days."],
        defenseTheory: ["{KID} died of an accidental overdose, and {DL}, a lifelong liar when scared, hid it. Lies and hiding are crimes, but not murder."],
        aggravating: ["The victim was very young"],
        mitigating: ["No prior violent record"],
        allocutions: ["\"I loved my child. I made a mistake with the medicine, and then I made the worst choices of my life to hide it.\""],
        guiltyTruths: ["A message later recovered from {DL}'s deleted folder read: \"I just want my life back.\""],
        innocentTruths: ["A coroner's re-examination years later found trace antihistamine in hair from the remains."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["KID": ["Kaylee", "Jordan", "Riley", "Avery"]],
        story: StoryExtras(
            timeline: [(-21, "Searches for antihistamine dosing for sleep on {DL}'s phone."),
                       (0, "{KID} last seen at day care."),
                       (19, "{DL}'s parent calls the Sheriff's Office; {DL} reports an abduction."),
                       (21, "Cadaver dog alerts at the closet and car trunk."),
                       (54, "Remains found in a creek bed. Cause of death undetermined.")],
            howIdentified: "{DL} was the last adult with {KID} and gave false accounts.",
            notDone: ["The remains were not tested for antihistamine."],
            defendantExam: [
                .direct("What happened to {KID}?", "\"{KID} wouldn't sleep for days. I gave the allergy medicine, more than the label. The next morning {KID} wouldn't wake up. I tried CPR. I knew I'd killed {KID}.\""),
                .direct("Why not call 911?", "\"I was terrified. I've lied my whole life when I'm scared, and I did it again. It got bigger and bigger.\""),
                .cross("You put your child in a tote and drove to a creek.", "\"Yes. I'll never forgive myself.\""),
                .cross("You went to a concert a week later.", "\"I pretended everything was normal. That's what I do.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Would a loving parent do what {DL} did?\"",
                                  answer: "\"No loving parent would.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Argumentative; improper opinion", shouldSustain: true,
                                  explanation: "The question asks the witness to draw the ultimate inference for the factfinder; it's argument, not evidence.",
                                  doctrineID: "speculation", weight: 1))
            ],
            prosecutionOpening: "Nineteen days of lies, searches about making a toddler sleep, a cadaver dog alert, and a tote in a creek.",
            defenseOpening: "No one can say how {KID} died. {DL} lied and hid, and those are crimes. Murder is not proven.",
            prosecutionClosing: "Innocent accidents get a 911 call. Not nineteen days and a creek.",
            defenseClosing: "The cause of death is undetermined. That is reasonable doubt about murder."
        )
    )

    // MARK: - 18. The storm (an armed teen and self-defense)

    static let streetRifle = CaseTemplate(
        key: "story.streetRifle", category: .violent,
        headlines: ["Teen Guarding Store Shoots Two After Hurricane", "Protector or Vigilante?"],
        primaryLaw: "murder2", lesserLaw: "volManslaughter", threshold: 1, lesserThreshold: 1,
        specification: "Killed {V} with a rifle, with malice.",
        ageRange: 18...19, occupations: ["community college student"], hasVictim: true,
        summaries: [
            "Two nights after Hurricane {STORM} knocked out power across {CITY}, {D}, 18, stood outside {DL}'s uncle's hardware store on {STREET} with an AR-style rifle, saying {DL} was protecting it from looters. At about {TIME} on {DATE}, {V} walked up, argued with {DL}, and grabbed for the rifle. {DL} fired three times, killing {VL}. As {DL} backed away, {VL}'s friend came at {DL} with a tire iron, and {DL} fired again, wounding the friend. The State says {DL} brought a war rifle to a dark street and provoked the fight. The defense says {VL} tried to take the gun."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Store Camera on Battery Backup", "Grainy, no sound: {VL} approaches, points at {DL}, steps closer; both hands reach toward the rifle; three flashes in under a second."),
            E(.statement, 2, "Social Media Post", "Hours earlier, {DL} posted a photo with the rifle: \"Anybody wants to loot tonight, come find out.\""),
            E(.document, 2, "Curfew Order", "A citywide curfew from 8 p.m. was in effect; {DL} was outside after curfew with a rifle.")
        ],
        defenseEvidence: [
            E(.video, 3, "Phone Video from Across the Street", "Shows {VL} yelling \"I'll take that and use it on you\" and grabbing the rifle barrel with both hands before the shots."),
            E(.document, 2, "Uncle's Request", "The uncle texted {DL}: \"Can you watch the store tonight? Cops aren't coming.\""),
            E(.document, 2, "Surrender", "{DL} called 911 within a minute, laid the rifle down, and waited with hands raised.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Lead detective",
                        direct: ["\"{DL} chose a dark street, a rifle, and a public challenge.\""],
                        cross: ["\"{DL} called 911 and surrendered.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find?", "\"{VL} on the sidewalk with three wounds to the chest and abdomen, a friend wounded in the thigh. {DL} sitting on the curb, rifle on the ground ten feet away, hands up.\""),
                            .direct("Why does the social media post matter?", "\"'Come find out.' That's an invitation. {DL} went out armed, after curfew, looking for a confrontation.\""),
                            .direct("Was {VL} armed?", "\"No. A phone and keys.\""),
                            .cross("{DL} called 911 and waited for you with hands up?", "\"Yes.\""),
                            .cross("The across-the-street video shows {VL} grabbing the barrel with both hands?", "\"It shows hands on the barrel.\""),
                            .cross("North Carolina law allows deadly force to prevent someone from taking your firearm and using it on you?", "\"If the belief is reasonable. That's for the court.\"")
                        ]),
            WitnessSeed(name: nil, role: "{VL}'s friend, wounded",
                        direct: ["\"{VL} only wanted to talk.\""],
                        cross: ["\"I came at {DL} with a tire iron.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why did you go to the store?", "\"We were walking home from a friend's generator, charging phones. {VL} saw the rifle and got mad. {VL} said a kid shouldn't be pointing that at people.\""),
                            .direct("What happened?", "\"They argued. {VL} reached for it. Then {VL} was on the ground.\""),
                            .cross("You picked up a tire iron and charged {DL}?", "\"After {DL} shot my friend. Yes.\""),
                            .cross("{VL} said 'I'll take that and use it on you'?", "\"{VL} said something like that. {VL} was angry.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Use-of-force expert",
                        direct: ["\"A struggle over a rifle is a deadly threat.\""],
                        cross: ["\"{DL} chose to be there.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What do the videos show?", "\"A person grabbing a rifle barrel with two hands, while threatening to use it. Once two people fight over a loaded rifle, someone may die in seconds.\""),
                            .direct("And the second shooting?", "\"A man charging with a tire iron at close range. That is a deadly weapon.\""),
                            .cross("If {DL} had stayed home, no one would have died?", "\"That's true of most tragedies. It's a moral question, not a forensic one.\"")
                        ])
        ],
        prosecutionTheory: ["{D} went looking for trouble with a rifle and a public challenge, and found it. You can't create the danger and then claim self-defense."],
        defenseTheory: ["{DL} was asked to guard a family store when police weren't coming. {VL} tried to take the rifle and threatened to use it. Every shot was in self-defense."],
        aggravating: ["The offense occurred during a declared emergency"],
        mitigating: ["{DL} was 18", "{DL} called 911 and surrendered immediately"],
        allocutions: ["\"I didn't go out there to hurt anyone. I thought {VL} was going to take the gun and kill me.\""],
        guiltyTruths: ["A friend later produced texts where {DL} hoped to 'get a looter' that night."],
        innocentTruths: ["A newly found body camera from a passing deputy showed {VL} wrenching the rifle sideways before the shots."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense"],
        extras: ["TIME": ["10:52 p.m."], "STORM": ["Delphine", "Marcus", "Odette"]],
        story: StoryExtras(
            timeline: [(-2, "Hurricane makes landfall; power out citywide; curfew ordered."),
                       (0, "6:10 p.m.: {DL} posts the rifle photo. 10:52 p.m.: shooting. 10:53 p.m.: {DL} calls 911."),
                       (1, "{DL} interviewed; rifle and videos collected."),
                       (10, "{DL} charged with second-degree murder.")],
            howIdentified: "{DL} called 911 and identified as the shooter.",
            notDone: ["Witnesses who fled the scene were never located."],
            defendantExam: [
                .direct("Why were you there?", "\"My uncle asked. The police weren't coming. Stores up the street had been broken into the night before.\""),
                .direct("Why the post?", "\"It was stupid. I was trying to scare people off so nobody would come.\""),
                .direct("What happened with {VL}?", "\"{VL} got in my face, then grabbed the barrel with both hands and said {VL} was going to take it and use it on me. I couldn't pull it away. I fired.\""),
                .cross("You invited people to 'come find out.'", "\"I regret that every day.\""),
                .cross("You were out after curfew with a rifle.", "\"Guarding my family's store.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"Isn't it true {VL} had been arrested for robbery before?\"",
                                  answer: "\"Once, years ago.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper character evidence", shouldSustain: true,
                                  explanation: "The victim's prior arrest, unknown to {DL} at the time, isn't admissible to show {VL} was the aggressor through bad character; specific acts of violence would need a stronger foundation.",
                                  doctrineID: "characterEvidence", weight: 0))
            ],
            prosecutionOpening: "A rifle, a challenge posted online, and a dark street. {D} got the confrontation {DL} invited.",
            defenseOpening: "{VL} grabbed the rifle and threatened to use it. That's when {DL} fired. On video.",
            prosecutionClosing: "Self-defense isn't available to someone who provokes the fight.",
            defenseClosing: "Words online aren't provocation. Grabbing a loaded rifle is deadly force."
        )
    )
}
