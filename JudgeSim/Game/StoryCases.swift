import Foundation

private typealias E = EvidenceSeed

/// Fully written cases. Every line is authored for its case, so the story holds together from the first
/// exhibit to the last answer. Only names, places, and dates change from one telling to the next.
enum StoryCases {
    static let all: [CaseTemplate] = [oldMillRoad, churchBooks, duplexBurglary, kitchenStrangulation, sharedApartment,
                                       caregiverAccount, parkingLotShooting, contractorDeposits,
                                       fishingCabin, homeInvasion, protectiveOrder, afterTheParty, rentalFire,
                                       nurseryNight, snowbank, kennelShooting, missingToddler, streetRifle,
                                       harborDisappearance, bloodTestStartup, textMessages, restraintDeath, stagedAttack]
        + batches.flatMap { $0 }
    private static let batches: [[CaseTemplate]] = [
        batchC, batchD, batchE, batchF, batchG, batchH, batchI, batchJ, batchK, batchL,
        batchM, batchN, batchO, batchP, batchQ, batchR, batchS, batchT, batchU, batchV,
        batchW, batchX, batchY, batchZ, batchAA, batchAB, batchAC, batchAD, batchAE, batchAF, batchAG, batchAH, batchAI
    ]

    // MARK: - 1. A fatal crash after a closing shift

    static let oldMillRoad = CaseTemplate(
        key: "story.oldMillRoad", category: .traffic,
        headlines: ["Head-On Crash on Old Mill Road", "A Nurse Killed Driving Home"],
        primaryLaw: "felonyDBV", lesserLaw: "misdDBV", threshold: 10, lesserThreshold: 7,
        specification: "While impaired, unlawfully and unintentionally caused the death of {V} in a collision on Old Mill Road.",
        secondary: [
            SecondaryCharge(lawID: "recklessDriving", specification: "Drove carelessly and heedlessly across the center line on a curve on Old Mill Road.", chance: 1.0, threshold: 8)
        ],
        ageRange: 24...41, occupations: ["line cook"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {D}'s Honda Civic crossed the center line on a curve on Old Mill Road outside {HOOD} and struck a Toyota Corolla head-on. The Corolla's driver, {V}, 34, a nurse driving home from a twelve-hour shift, died at the scene. {D}, a line cook at {REST}, had stayed after closing that night. A hospital blood test about ninety minutes after the crash and a second, State Crime Laboratory test about three hours after it disagree on whether {DL} was over the legal limit when the cars collided. {DL} says a deer came out of the tree line and {D.he} swerved."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "State Crime Laboratory Blood Result", "Blood drawn under a search warrant at 2:51 a.m., nearly three hours after the crash, measured 0.06 grams of alcohol per 100 milliliters of whole blood.", .search),
            E(.document, 2, "Hospital Blood Panel", "The emergency department ran a serum alcohol test at 1:24 a.m. for treatment purposes: 98 mg/dL, which the hospital reported as 0.098 percent. Serum results run higher than whole blood."),
            E(.document, 2, "Point-of-Sale Records from {REST}", "Staff tab after closing: four 16-ounce draft beers rung to {DL}'s employee number between 10:05 and 11:31 p.m."),
            E(.physical, 3, "Crash Scene Diagram", "{TROOPER}'s measurements place the point of impact 2 feet 7 inches into the Corolla's lane, at the apex of the curve. Gouge marks and debris fields agree."),
            E(.video, 2, "Body-Camera Footage", "Shows {DL} at the scene, crying, saying \"I only had a couple, I swear\" and \"I didn't see them.\" Slight sway while standing; speech clear.")
        ],
        defenseEvidence: [
            E(.physical, 2, "Deer Hair on Bumper", "Hair recovered from the Civic's front passenger-side bumper was identified by an N.C. Wildlife Resources biologist as white-tailed deer. It can't be dated."),
            E(.document, 2, "Retrograde Extrapolation Critique", "The defense toxicologist calculates {DL}'s concentration at the time of the crash at 0.07 to 0.09, depending on whether alcohol was still being absorbed, and says a 0.08 conclusion can't be reached to a scientific certainty."),
            E(.document, 1, "NCDOT Crash History", "Seven crashes in five years on the same curve; two involved deer. A warning sign was recommended in 2019 and never installed.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{TROOPER}", role: "N.C. State Highway Patrol crash investigator",
                        direct: ["\"The point of impact was more than two and a half feet into the Corolla's lane.\""],
                        cross: ["\"I can't tell you what was in the road a second before the crash.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("How long have you worked crash investigations?", "\"Eleven years with the Highway Patrol, the last six as a certified reconstructionist. I've worked a little over three hundred serious-injury and fatal collisions.\""),
                            .direct("When did you get to Old Mill Road that night?", "\"At 12:09 a.m. Fire and EMS were already there. The Corolla's driver had been pronounced dead. {DL} was sitting on the guardrail with a paramedic.\""),
                            .direct("Where did the cars hit?", "\"On the curve, just past the Hester Creek bridge. I located the point of impact from the gouge marks in the asphalt, where the Corolla's frame was driven down into the road, and from where the fluid and glass started. That point is two feet seven inches over the center line, in the Corolla's lane.\""),
                            .direct("Could the Corolla have caused the crash by drifting over itself?", "\"Nothing I found points that way. The Corolla's tire marks stay in its own lane right up to impact. If anything, it was braking and steering toward the shoulder, which is what you'd do if a car came at you.\""),
                            .direct("What speed was the Civic going?", "\"The airbag control module recorded 51 miles per hour five seconds before the crash and 47 at impact. The posted limit there is 45. The advisory speed for that curve is 35.\""),
                            .direct("Did you speak with {DL}?", "\"Briefly. I asked what happened. {DL} said, 'I came around the curve and they were just there.' A minute later {D.he} said there'd been a deer. That was the first I heard of a deer.\""),
                            .direct("Did you notice anything about {DL}'s condition?", "\"An odor of alcohol on the breath, red, glassy eyes. Speech was clear. I didn't do field sobriety tests because of the injuries, a cut forehead and a sore wrist. I applied for a search warrant for blood instead.\""),
                            .cross("You found deer hair on my client's bumper, didn't you?", "\"I collected it and sent it to Wildlife. It came back as deer. There's no way to know if it's from that night or last fall.\""),
                            .cross("You didn't look for a deer in the woods that night?", "\"No. It was dark and we were working a fatality. I didn't see one, and nobody reported one.\""),
                            .cross("The ECM shows braking began 1.6 seconds before impact, correct?", "\"Correct. Hard braking and a steering input to the left, toward the center line.\""),
                            .cross("Steering left at the last second is what a driver does to avoid something on the right shoulder, isn't it?", "\"It's one explanation. Another is a driver who realizes too late they've drifted and overcorrects. The data can't tell you which.\""),
                            .cross("There's no warning sign at that curve?", "\"There's not. There should be.\"")
                        ]),
            WitnessSeed(name: nil, role: "Bartender at {REST}",
                        direct: ["\"I poured {DL} four beers after close. Maybe a sip of a fifth.\""],
                        cross: ["\"{DL} ate a full plate of wings around ten.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"We've worked together at {REST} about two years. {DL} runs the line; I run the bar. We're friends, honestly.\""),
                            .direct("What happens after closing?", "\"Kitchen and bar staff get a shift drink, sometimes more. Managers let it slide as long as it's rung up on the staff tab. We close at ten on weeknights.\""),
                            .direct("What did {DL} drink that night?", "\"Four sixteen-ounce drafts of the house lager. That's what's on the tab, and that matches what I remember pouring. There may have been a sip of somebody else's fifth beer. I'm not sure.\""),
                            .direct("When did {DL} leave?", "\"Right around 11:35. I remember because I was counting the drawer and {DL} said goodnight and tapped the bar like always.\""),
                            .direct("How did {DL} seem?", "\"Normal. Tired. Laughing. I wouldn't have let anybody drive that I thought was drunk, and I'd have said something.\""),
                            .cross("{DL} ate a full meal that night?", "\"Yes. A plate of wings and fries around ten, before the beers really got going. Staff meal.\""),
                            .cross("You've been trained to spot impaired customers?", "\"Yes, we do the responsible-serving course every year. I didn't see any signs.\""),
                            .cross("The house lager is about 4.5 percent alcohol?", "\"Four point two, I think. It's a light beer.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic toxicologist, State Crime Laboratory",
                        direct: ["\"Working back from the 0.06 result, {DL}'s concentration at the time of the crash would have been about 0.09 to 0.10.\""],
                        cross: ["\"If {DL} was still absorbing alcohol, the number at the crash could have been lower.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your work at the Laboratory?", "\"I'm a forensic scientist in the toxicology section. I've analyzed blood for alcohol for nine years and testified about two hundred times, for the State and, in a few cases, called by the defense.\""),
                            .direct("What did the blood sample show?", "\"The sample drawn at 2:51 a.m. contained 0.06 grams of alcohol per 100 milliliters of whole blood. I ran it twice by headspace gas chromatography; both results agreed within the allowed tolerance.\""),
                            .direct("That's under 0.08. Why does it matter?", "\"Because it was drawn almost three hours after the crash. The body eliminates alcohol at a fairly steady rate once absorption is finished, usually between 0.015 and 0.020 per hour. Working backward, the concentration at 11:52 would have been around 0.09 to 0.10.\""),
                            .direct("What about the hospital result of 0.098?", "\"That was serum, not whole blood. Serum reads higher, by about 10 to 20 percent. Converted, it's roughly 0.08 to 0.09 at 1:24 a.m., which is consistent with my calculation.\""),
                            .direct("Does a person need to be over 0.08 to be impaired?", "\"No. Effects on judgment and divided attention, the kind of thing driving requires, begin well below 0.08. At 0.08 almost everyone is measurably impaired.\""),
                            .cross("Your back-calculation assumes {DL} had finished absorbing all the alcohol by the time of the crash?", "\"It does. That's the standard assumption when the drinking stopped twenty or more minutes before.\""),
                            .cross("But {DL} finished a beer at 11:31 and ate a large meal. Food slows absorption, doesn't it?", "\"It does. If {DL} was still absorbing at 11:52, the concentration at the crash could have been lower than at 1:24. It could have been under 0.08.\""),
                            .cross("So you can't tell the court to a scientific certainty that my client was at 0.08 or above when the cars hit?", "\"Not to a certainty. My opinion is that it's more likely than not. The range runs from about 0.07 to 0.10.\""),
                            .cross("You never saw {DL} drive, talk, or walk that night?", "\"No. I see blood, not people.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Pharmacologist retained by the defense",
                        direct: ["\"A 0.08 conclusion can't be reached to scientific certainty.\""],
                        cross: ["\"My range includes 0.08 and 0.09.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your background?", "\"I hold a doctorate in pharmacology and taught at a medical school for twenty years. I consult on alcohol cases now, for both prosecutors and defense lawyers, at about the same rate.\""),
                            .direct("What did you review?", "\"Both blood results, the point-of-sale records, the meal times, the bartender's account, and {DL}'s height and weight, five foot nine and 185 pounds.\""),
                            .direct("What is your opinion?", "\"With a large meal at ten and the last beer finished at 11:31, {DL} was very likely still absorbing alcohol at 11:52. On a full stomach, peak can come sixty to ninety minutes after the last drink. That means the crash happened on the way up, not the way down.\""),
                            .direct("So what was the concentration at the crash?", "\"My best estimate is 0.07 to 0.09. You simply cannot say it was 0.08 or higher with scientific confidence. Anybody who tells you otherwise is assuming something the evidence doesn't show.\""),
                            .cross("You're being paid for your time today?", "\"$350 an hour, the same rate I charge the State when it hires me.\""),
                            .cross("Your own range goes up to 0.09?", "\"It does. I'm not telling the court {DL} was sober. I'm telling the court the number is uncertain.\""),
                            .cross("Four sixteen-ounce beers in ninety minutes would impair most people's driving to some degree?", "\"To some degree, yes. Whether it's 'appreciable' impairment is the question for the court, not for me.\""),
                            .cross("You never examined {DL}?", "\"No. My opinion is based on the records.\"")
                        ])
        ],
        prosecutionTheory: ["{D} drank four beers after closing and drove a dark curve too fast, crossed the center line, and killed {V}."],
        defenseTheory: ["A deer, a dangerous curve without a sign, and a blood number nobody can pin down. That's a tragedy, not a crime."],
        aggravating: ["{DL} drove at 51 miles per hour into a curve with a 35 mph advisory"],
        mitigating: ["{DL} remained at the scene and tried to help", "No prior driving record", "{DL} has accepted responsibility for drinking before driving"],
        victimImpacts: ["{VL}'s spouse: \"We have two kids. One of them still sets a place for {V.him} at dinner. I don't know how to make that stop.\""],
        allocutions: ["\"I think about {VL} every single time I get in a car. I'd give anything to have taken a ride home that night.\""],
        guiltyTruths: ["{DL} later admitted to a counselor that there'd been two shots of whiskey in the walk-in cooler that never made it onto the tab."],
        innocentTruths: ["A neighbor's trail camera, found a year later, showed three deer crossing Old Mill Road at 11:51 that night."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["TIME": ["11:52 p.m."], "REST": ["Big Lou's Smokehouse", "The Copper Kettle", "Riverside Grill"]],
        story: StoryExtras(
            timeline: [(0, "11:52 p.m.: 911 calls report a head-on collision on Old Mill Road. {TROOPER} arrives at 12:09 a.m."),
                       (1, "1:24 a.m.: Hospital serum alcohol test, 98 mg/dL. 2:51 a.m.: Blood drawn under search warrant."),
                       (2, "Airbag control modules downloaded from both vehicles."),
                       (9, "Point-of-sale records obtained from {REST} by subpoena."),
                       (31, "State Crime Laboratory reports 0.06 whole-blood alcohol concentration."),
                       (38, "{DL} charged with felony death by vehicle.")],
            howIdentified: "{DL} was the driver of the Civic and remained at the scene.",
            notDone: ["No search for a deer or deer carcass along the road that night.", "The fifth beer the bartender mentioned was never accounted for."],
            defendantExam: [
                .direct("Tell the court about your night.", "\"I worked a double, open to close. After close we ate, and I had some beers with the staff, the four on the tab. I left about 11:35 to drive home, the same way I've driven a thousand times.\""),
                .direct("Did you feel impaired?", "\"No. I felt tired. I'd eaten. I wouldn't have driven if I felt drunk, I've called rides before.\""),
                .direct("What happened on the curve?", "\"I came around and something big and pale came out from the right, from the trees. I hit the brakes and jerked the wheel left. I felt a thump on the right side, and then the headlights were right there. That's the last clear thing I remember.\""),
                .direct("Why didn't you mention the deer right away?", "\"I couldn't think. There was somebody in that car and I could see... I was trying to get to them. The deer didn't matter to me then.\""),
                .cross("You told the trooper first that the other car was 'just there.' Not a deer.", "\"That's what I remember saying. The deer came back to me a minute later.\""),
                .cross("You were going 51 into a curve marked 35?", "\"I didn't know I was going that fast. I'm not proud of it.\""),
                .cross("And you'd had four beers in an hour and a half.", "\"Yes, with food. I'm not saying I should have driven. I'm saying I wasn't drunk.\""),
                .cross("You said on camera, 'I only had a couple.' Four isn't a couple.", "\"I was panicking. I said a lot of things.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"Do you think {DL} should have driven that night?\"",
                                  answer: "\"Looking back? No. Nobody should drive after four beers.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation and improper opinion", shouldSustain: true,
                                  explanation: "A lay witness can describe what the witness saw of {DL}'s condition, but not offer an opinion on the ultimate question of whether {D.he} was impaired.",
                                  doctrineID: "speculation", weight: 1)),
                (0, ObjectionSeed(question: "Defense attorney: \"Isn't it true the State never installed the warning sign because of budget cuts?\"",
                                  answer: "\"I believe that's what DOT said, yes.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Relevance", shouldSustain: true,
                                  explanation: "Why the sign was never installed doesn't bear on whether {DL} was impaired or caused the crash; the curve's condition was already in evidence.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "Four beers, a curve marked 35, a car doing 51, and a nurse on the way home who never got there. The State will show {D} was impaired and that the impairment killed {V}.",
            defenseOpening: "Your Honor will hear two blood tests that don't agree, a toxicologist who admits the number isn't certain, and deer hair on the bumper of a car that swerved left to avoid something. {DL} has carried this every day since. But grief is not proof of impairment.",
            prosecutionClosing: "The law doesn't require a number. It requires appreciable impairment. Four beers, speed, a missed curve, and an odor of alcohol. That's impairment, and it caused {V}'s death.",
            defenseClosing: "The State's own expert couldn't say {DL} was at 0.08. Their trooper couldn't rule out the deer. If the court has a reasonable doubt about impairment, the most it can find is a misdemeanor death by vehicle.",
            victim: VictimFacts(age: 34, occupation: "Nurse"),
            employer: "{REST}",
            scene: "the curve on Old Mill Road just past the Hester Creek bridge, outside {HOOD}"
        )
    )

    // MARK: - 2. The church treasurer

    static let churchBooks = CaseTemplate(
        key: "story.churchBooks", category: .whiteCollar,
        headlines: ["Church Treasurer Charged in Missing Building Fund", "$112,000 and a Handshake"],
        primaryLaw: "embezzlement100k", lesserLaw: "embezzlement", threshold: 6, lesserThreshold: 4,
        specification: "As treasurer, embezzled $112,400 from {CHURCH}.",
        ageRange: 44...63, occupations: ["school bus mechanic"], hasVictim: false,
        summaries: [
            "For six years {D}, a school bus mechanic for Hollis County Schools, served as the volunteer treasurer of {CHURCH} in {HOOD}. When a new trustee asked for the building fund statements, $112,400 was gone, moved over three years in 41 checks and transfers to an account in the name of \"DL Property Services.\" {DL} says Pastor {PASTOR} approved every payment as short-term loans to the contractor rebuilding the fellowship hall, and that the paperwork was handshakes. The pastor, now retired and in poor health, says no such arrangement existed."
        ],
        prosecutionEvidence: [
            E(.document, 4, "Bank Records", "Forty-one checks and online transfers from the building fund to DL Property Services between 2021 and 2024, totaling $112,400. {DL} opened DL Property Services' account and was its only signer.", .search),
            E(.document, 3, "Forensic Accounting Report", "Of the money moved to DL Property Services, $58,900 was spent on {DL}'s mortgage, truck payments, and credit cards. $41,000 went to Carver Construction. $12,500 is unaccounted for."),
            E(.document, 2, "Treasurer's Reports to the Congregation", "Quarterly reports {DL} read aloud show the building fund balance $60,000 to $110,000 higher than the bank statements for the same dates."),
            E(.statement, 2, "Interview with Investigator", "\"I was going to put it back. Pastor knew. Everybody knew we were short on the contractor.\"", .statement)
        ],
        defenseEvidence: [
            E(.document, 3, "Contractor's Ledger", "Carver Construction's ledger shows $41,000 in payments from DL Property Services marked \"church hall\" and a note: \"Pastor says advance OK, treasurer handles.\""),
            E(.document, 2, "Text Messages from the Pastor", "2022: \"Do what you need to keep Carver working. We'll square it with the trustees after the dedication.\""),
            E(.document, 1, "Repayment Deposits", "Three deposits from {DL} back into the building fund in 2023, totaling $9,600.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Chair of the {CHURCH} trustee board",
                        direct: ["\"The congregation was told the fund was healthy. It wasn't.\""],
                        cross: ["\"I've never seen the pastor's texts before today.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How long have you been a member of {CHURCH}?", "\"Thirty-one years. I was elected chair of the trustees two years ago.\""),
                            .direct("What made you look at the building fund?", "\"The fellowship hall was supposed to be finished. Carver's crew kept stopping work, saying they hadn't been paid. That didn't make sense to me, because {DL} was reporting a building fund over a hundred thousand dollars every quarter.\""),
                            .direct("What did you do?", "\"I asked {DL} for the bank statements. {DL} said they were at home and kept putting me off. After a month I went to the bank with the pastor's authorization and got them myself.\""),
                            .direct("What did they show?", "\"About eleven thousand dollars. Not a hundred and twenty. And dozens of checks to something called DL Property Services, which I'd never heard of.\""),
                            .direct("Did the trustees ever approve loans to a contractor out of the building fund?", "\"Never. It isn't in a single set of minutes. Any expense over five thousand needs a trustee vote under our bylaws.\""),
                            .cross("The pastor ran that church for twenty-six years?", "\"He did. He's a good man.\""),
                            .cross("If the pastor told the treasurer to keep the contractor working, the treasurer would listen?", "\"I suppose most of us would. That doesn't make it right with the bylaws.\""),
                            .cross("You've never seen these texts from the pastor before today?", "\"No. I'd like to know why he never told us.\""),
                            .cross("{DL} repaid some of the money before anyone asked?", "\"Some. Ninety-six hundred. Out of a hundred and twelve thousand.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic accountant",
                        direct: ["\"About $58,900 was spent on {DL}'s personal bills.\""],
                        cross: ["\"About $41,000 did go to the contractor.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the District Attorney's office ask you to do?", "\"Trace every dollar that left the building fund from January 2021 forward, and say where it ended up.\""),
                            .direct("What did you find?", "\"Forty-one payments totaling $112,400 went from the building fund to DL Property Services. From there, $41,000 went to Carver Construction. $58,900 went to {DL}'s mortgage lender, a truck loan, and three credit cards. About $12,500 was withdrawn in cash and I can't trace it.\""),
                            .direct("Was the money spent on the contractor paid before or after the personal payments?", "\"Mostly after. The personal spending started in the first six months. The Carver payments cluster in late 2022, right around when the pastor's texts were sent.\""),
                            .direct("What about the reports to the congregation?", "\"They overstated the balance every single quarter for three years. The gap tracked the money moved out almost exactly. Someone knew the real number and reported a different one.\""),
                            .cross("You agree $41,000 really did go to rebuilding the fellowship hall?", "\"I do. That money did what the congregation wanted it to do.\""),
                            .cross("And $9,600 came back from {DL}?", "\"Yes. Three deposits in 2023.\""),
                            .cross("You never spoke with the pastor?", "\"I asked to. His family said his health wouldn't allow it.\""),
                            .cross("You can't say what the cash withdrawals were for?", "\"No. I can say they went to {DL}'s hands, not to Carver's.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Owner of Carver Construction",
                        direct: ["\"The pastor told me the treasurer would handle my advances.\""],
                        cross: ["\"I never saw the trustees approve anything.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What work did you do for {CHURCH}?", "\"We were rebuilding the fellowship hall after the roof collapse. Framing, roof, electrical rough-in. About a two-hundred-thousand-dollar job in all.\""),
                            .direct("How were you paid?", "\"At first by church check, signed by {DL} and a trustee. Then the money stopped. In the fall of 2022 the pastor called me in and said the treasurer would get me advances so we didn't lose the crew.\""),
                            .direct("Who paid those advances?", "\"Checks from DL Property Services. I asked {DL} what that was and {D.he} said it was how they were moving the money so it didn't hold up the dedication. I didn't care whose name was on it, honestly. It cleared.\""),
                            .direct("Read the note in your ledger.", "\"'Pastor says advance OK, treasurer handles.' I wrote that the day he told me.\""),
                            .cross("You were paid about $41,000 that way?", "\"Forty-one, give or take. I never added it up until the detective did.\""),
                            .cross("You never saw a trustee vote approving it?", "\"No. That's church business.\""),
                            .cross("Did you know {DL} was also paying a mortgage from the same account?", "\"No. Nobody told me that.\""),
                            .cross("You still want to be paid for the rest of the job, don't you?", "\"I'm owed about sixty thousand. Sure I want paying. It's got nothing to do with what I'm telling you.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took the congregation's building fund for three years, told them every quarter that it was safe, and spent most of it on {D.his} own bills."],
        defenseTheory: ["The pastor ran that church and told {DL} to keep the contractor working off the books. {DL} made a mess of the accounts. That is not the same as stealing."],
        aggravating: ["The reports to the congregation were falsified for three years"],
        mitigating: ["{DL} repaid $9,600 before the theft was discovered", "$41,000 was spent on the congregation's own building project", "No prior criminal record"],
        allocutions: ["\"I love that church. I was baptized there. I made a terrible decision when I started borrowing to cover my own house, and I lied to cover it. I'm sorry.\""],
        guiltyTruths: ["After trial, {DL}'s spouse found a notebook in the garage tracking the personal withdrawals, labeled \"to pay back someday.\""],
        innocentTruths: ["Months later, the retired pastor told a deacon he had promised {DL} the church would cover {D.his} mortgage while {D.he} fronted the contractor money, and was too ashamed to say so."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["CHURCH": ["Pleasant Grove Missionary Baptist Church", "Mount Zion AME Zion Church", "Cedar Hill United Methodist Church"],
                 "PASTOR": ["Harold Peebles", "Willie Ransom", "Earl Upchurch"]],
        story: StoryExtras(
            timeline: [(0, "Trustee chair obtains building fund statements from the bank; balance $11,214."),
                       (6, "Trustees report the shortfall to the Sheriff's Office. Case assigned to {DET}."),
                       (21, "Search warrants for DL Property Services and {DL}'s personal accounts."),
                       (40, "{DL} interviewed; admits the account and says the pastor approved advances."),
                       (95, "Forensic accounting report completed."),
                       (102, "{DL} charged with embezzlement of more than $100,000.")],
            howIdentified: "{DL} was the treasurer and the only signer on the account that received the money.",
            notDone: ["The retired pastor was never formally interviewed.", "The $12,500 in cash withdrawals was never traced."],
            defendantExam: [
                .direct("Why did you open DL Property Services?", "\"Pastor said the trustees would never approve advances before the dedication, and Carver was about to walk. He said, keep it separate, keep it moving, we'll square it after. So I opened an account I could write from.\""),
                .direct("Did you use the money for yourself?", "\"Yes. I did. Not at first. My hours got cut in 2021 and we were going to lose the house. I told myself it was a loan like the contractor's. I paid some back. Not enough.\""),
                .direct("Did the pastor know about that part?", "\"I told him I was behind on the house. He said the Lord would make a way and the church takes care of its own. I took that as permission. I know now that's not what it was.\""),
                .cross("You read false balances to the congregation for three years.", "\"For three years. Every January, from the pulpit steps.\""),
                .cross("If the pastor approved it, why lie to everyone else?", "\"Because I was ashamed, and because he said wait until after the dedication. Then it was too big to explain.\""),
                .cross("Nothing in writing from the pastor mentions your mortgage, does it?", "\"No. Just what he said to me in his office.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense attorney: \"What did the pastor tell you about the trustees?\"",
                                  answer: "\"He said, 'The trustees will slow us down. The treasurer will handle it.'\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Hearsay", shouldSustain: false,
                                  explanation: "Offered to show why the contractor accepted payment from DL Property Services and what {DL} was told, not for the truth of whether the trustees approved. It is admissible for that purpose.",
                                  doctrineID: "hearsay", weight: -1))
            ],
            prosecutionOpening: "The congregation trusted {D} with the money for a new fellowship hall. For three years, {DL} told them it was safe. Most of it went to {DL}'s mortgage, truck, and credit cards.",
            defenseOpening: "The pastor told {DL} to keep the contractor working off the books. Forty-one thousand dollars went to that building. {DL} made terrible choices with the rest, and {D.he} will tell you so. The question is what crime, and how much.",
            prosecutionClosing: "Maybe the pastor said keep Carver working. Nobody said pay your mortgage. Fifty-eight thousand dollars and three years of false reports is embezzlement.",
            defenseClosing: "The State counts $112,400. But $41,000 went exactly where the congregation wanted, and $9,600 came back. If the court finds embezzlement, the real number is under one hundred thousand."
        )
    )

    // MARK: - 3. A break-in at night

    static let duplexBurglary = CaseTemplate(
        key: "story.duplexBurglary", category: .property,
        headlines: ["Intruder in the Hallway on {STREET}", "Night Break-In Ends in Pawn Shop Arrest"],
        primaryLaw: "burglary1", lesserLaw: "burglary2", threshold: 7, lesserThreshold: 5,
        specification: "Broke and entered the occupied dwelling of {V} at night with intent to commit larceny.",
        secondary: [
            SecondaryCharge(lawID: "felonyLarceny", specification: "Stole a laptop, wallet, and prescription medication from {V} during a burglary.", chance: 1.0, threshold: 6),
            SecondaryCharge(lawID: "injuryRealProperty", specification: "Damaged the rear door of {V}'s home by prying it open.", chance: 1.0, threshold: 5)
        ],
        ageRange: 24...36, forcedPriorOffenses: ["Misdemeanor Larceny", "Possession of Stolen Goods@6"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {V} woke to a noise in a duplex on {STREET} in {HOOD} and saw a stranger in the hallway, lit only by a nightlight. The intruder ran out the back door, which had been pried open, taking a laptop, a wallet, and a bottle of prescription pain pills. Four days later {D} sold the laptop to a pawn shop a few miles away. {DL} says the laptop came from a man at a gas station who sold it for $80, and that {D.he} was home asleep that night."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Pawn Transaction Record", "{DL} sold the victim's laptop, serial number matching the purchase receipt, to {PAWN} four days after the burglary, showing {D.his} driver's license and giving a thumbprint as required by law."),
            E(.document, 2, "Photo Lineup", "Six-photo sequential lineup, administered by an officer who didn't know the suspect. {V} picked {DL}'s photo and said, \"I think that's them. Seventy, maybe seventy-five percent.\""),
            E(.physical, 2, "Shoe Impression", "Muddy impression on the back steps from a size 10 athletic shoe with a common tread pattern. {DL} wears size 10. No shoe was ever recovered."),
            E(.digital, 2, "Cell-Site Records", "{DL}'s phone connected to a tower serving the area around {STREET} at 3:02 a.m. That tower also serves {DL}'s own apartment, 1.4 miles away.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Gas Station Video Request", "The defense's subpoena for the Kwik Fuel's cameras came 40 days after the arrest; the store keeps video 30 days."),
            E(.document, 2, "Eyewitness Memory Research", "Identification accuracy drops sharply in low light, under stress, and with brief exposure; confidence below 80 percent at a first lineup is a recognized warning sign."),
            E(.document, 1, "Pill Bottle Not Found", "The stolen prescription bottle was never found. {DL} has no drug history and tested negative at booking.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Resident of the duplex",
                        direct: ["\"I saw the side of a face in the nightlight, and then they ran.\""],
                        cross: ["\"It was three, maybe four seconds.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you that night?", "\"Asleep in my bedroom. I work early at the hospital laundry, so I'm in bed by ten. Something woke me, like a drawer sliding.\""),
                            .direct("What did you do?", "\"I got up and opened my door. There's a nightlight in the hall by the bathroom. Somebody was standing at the end of the hall by the kitchen, holding my laptop bag.\""),
                            .direct("What did you see of the person?", "\"Dark hoodie, hood down. Short hair. I saw the side of their face when they turned, and then they ran out the back. I screamed, honestly. I didn't chase them.\""),
                            .direct("What was missing?", "\"My laptop, my wallet off the counter, and my pain pills from a knee surgery. The back door was open. The frame was splintered by the lock.\""),
                            .direct("Tell the court about the lineup.", "\"The officer showed me photos one at a time and said the person might not be there. When I got to the fourth one, my stomach dropped. I said I thought that was them. I said seventy, seventy-five percent.\""),
                            .cross("You saw this person for about three or four seconds?", "\"Three, maybe four. Long enough to see a face.\""),
                            .cross("In the light of a nightlight, from the other end of a hallway?", "\"About twenty feet. Yes.\""),
                            .cross("You told the 911 dispatcher you 'couldn't really see their face.'", "\"I was hysterical. I saw the side of it.\""),
                            .cross("Before the lineup, the detective told you they'd found your laptop at a pawn shop?", "\"The detective said they had a lead from the laptop, but not who.\"")
                        ]),
            WitnessSeed(name: nil, role: "Clerk at {PAWN}",
                        direct: ["\"{DL} sold it and gave a thumbprint, like the law requires.\""],
                        cross: ["\"{DL} didn't act nervous.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What is the procedure when someone sells you an item?", "\"Photo ID, a thumbprint on the ticket, and we enter the serial number into the police database. It's state law. Then we hold it thirty days before we can sell it.\""),
                            .direct("Do you remember this sale?", "\"Yes, because of what happened after. {DL} brought in a silver laptop, no charger, and asked for a hundred and fifty. I offered ninety. {DL} took ninety.\""),
                            .direct("Did {DL} say where it came from?", "\"I asked, like I always do. {DL} said 'it was my cousin's, they upgraded.'\""),
                            .cross("{DL} used a real license and a real thumbprint?", "\"Yes. Name, address, everything.\""),
                            .cross("Did {DL} seem nervous?", "\"No. Kind of casual about it, actually.\""),
                            .cross("Would someone who just burglarized a house usually pawn it under their own name?", "\"You'd be surprised. But no, the smart ones don't.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Property crimes detective",
                        direct: ["\"The laptop led us to {DL}.\""],
                        cross: ["\"We never found the pills or the wallet.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did {DL} become a suspect?", "\"Four days after the burglary the laptop's serial number hit in the pawn database. The ticket had {DL}'s name, license, and thumbprint.\""),
                            .direct("What did you do next?", "\"I put {DL}'s photo in a sequential lineup with five fillers, and had an officer who didn't know who the suspect was show it, which is our policy. {V} picked {DL} at 70 to 75 percent.\""),
                            .direct("Did you speak with {DL}?", "\"Yes. {DL} said the laptop was bought at a Kwik Fuel on Route 17 from a man in a red truck for eighty dollars. {DL} couldn't give a name or plate.\""),
                            .direct("Did anything else connect {DL} to the house?", "\"{DL} wears a size 10 shoe, consistent with the impression on the steps. And {DL}'s phone hit a tower that covers the area of the duplex at 3:02 a.m.\""),
                            .cross("That tower also covers my client's own apartment?", "\"It does. It covers about two square miles.\""),
                            .cross("Size 10 is the most common men's size in the country, isn't it?", "\"It's one of the most common, yes.\""),
                            .cross("You never pulled the Kwik Fuel video?", "\"No. I didn't think the story was credible enough to chase. In hindsight, I should have.\""),
                            .cross("You told {V} before the lineup that the laptop led you to someone?", "\"I told {V} we had a lead. I didn't say who, and I wasn't the one who gave the lineup.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s partner",
                        direct: ["\"{DL} was in bed with me all night.\""],
                        cross: ["\"I take a sleep aid most nights.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where was {DL} the night of {DATE}?", "\"Home with me. We watched a movie and went to bed around midnight. {DL} was there when my alarm went off at six.\""),
                            .direct("How do you remember that night in particular?", "\"Because two days later {DL} came home with the laptop and said look what I got for eighty bucks at the Kwik Fuel. I said that's probably stolen. {DL} said the guy said it was his.\""),
                            .cross("You take a prescription sleep aid most nights?", "\"Most nights, yes. That night too, probably.\""),
                            .cross("So you'd have no idea if {DL} left at two in the morning and came back at four?", "\"I'd like to think I'd know. Honestly, I sleep hard.\""),
                            .cross("You told {DL} the laptop was probably stolen, and {D.he} pawned it anyway?", "\"Yes. I'm not saying it was smart.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pried open the back door of an occupied home in the middle of the night, was seen by the person living there, and four days later sold what was taken."],
        defenseTheory: ["{DL} bought a stolen laptop for eighty dollars, which was foolish and maybe a crime in itself. But the identification is weak, and nothing else puts {DL} in that house."],
        aggravating: ["The victim was confronted face to face and has suffered lasting fear"],
        mitigating: ["{DL} sold the laptop openly under {D.his} own name", "No prior burglary convictions"],
        victimImpacts: ["{V}: \"I sleep with a chair under my door now. I moved out of that duplex. I couldn't stand the hallway.\""],
        allocutions: ["\"I knew that laptop wasn't right when I bought it. That's on me. I wasn't in that house.\""],
        guiltyTruths: ["A year later, the stolen wallet turned up in a storage unit rented in {DL}'s name."],
        innocentTruths: ["The man in the red truck was arrested in another county with three more laptops from break-ins the same week, and confessed to {VL}'s."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["TIME": ["3:05 a.m."], "PAWN": ["Hollis Gold & Pawn", "Cash Corner Pawn", "Route 17 Pawn & Loan"]],
        story: StoryExtras(
            timeline: [(0, "3:05 a.m.: {V} calls 911 reporting an intruder. Patrol finds the back door pried open."),
                       (0, "Shoe impression photographed and cast on the back steps."),
                       (4, "Laptop serial number reported by {PAWN} through the pawn database."),
                       (6, "Sequential photo lineup; {V} selects {DL} at 70 to 75 percent confidence."),
                       (7, "{DL} interviewed and arrested."),
                       (20, "Cell-site records obtained by warrant.")],
            howIdentified: "The stolen laptop was pawned under {DL}'s name four days after the burglary.",
            notDone: ["Kwik Fuel surveillance video was never requested and has been overwritten.", "No search for the wallet or pills at {DL}'s apartment."],
            defendantExam: [
                .direct("Where did you get the laptop?", "\"At the Kwik Fuel on Route 17, two days after whatever night this was. A guy in a red pickup was selling it out of a backpack by the air pump. He wanted a hundred and I gave him eighty.\""),
                .direct("Did you think it was stolen?", "\"I thought maybe. My partner said so. I told myself the guy said it was his. It was a stupid thing to do.\""),
                .direct("Why pawn it under your own name?", "\"Because I didn't think I'd done anything that bad. I needed money for rent. If I'd broken into somebody's house I wouldn't walk it into a shop that takes your thumbprint.\""),
                .direct("Were you in that duplex?", "\"No. I've never been on that street.\""),
                .cross("You told the pawn clerk the laptop was your cousin's.", "\"I did. That was a lie. I didn't want to explain the gas station.\""),
                .cross("So you lie when it helps you.", "\"I lied to a pawn clerk about where a laptop came from. I'm not lying about breaking into somebody's home.\""),
                .cross("You've been convicted of possession of stolen goods before.", "\"Six years ago. It's exactly why I should have known better than to buy that laptop.\""),
                .cross("You can't name the man, describe his plate, or show any video.", "\"No. I asked my lawyer to get the video. It was gone.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Do you think {DL} is the person you saw?\"",
                                  answer: "\"Now that I see them in person, I'm sure of it.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Suggestive in-court identification", shouldSustain: true,
                                  explanation: "An in-court identification with the defendant seated at counsel table, after a 70 percent out-of-court pick, is inherently suggestive and adds little reliable weight.",
                                  doctrineID: "relevance", weight: 2))
            ],
            prosecutionOpening: "Somebody pried open {V}'s back door at three in the morning and was standing in the hallway when {V.he} came out of the bedroom. Four days later {D} sold the laptop that was taken. {V} picked {DL} out of a lineup.",
            defenseOpening: "{DL} bought a laptop that was too cheap to be honest, then walked it into a pawn shop with a license and a thumbprint. That's what an innocent fool does. The rest of the State's case is a nightlight and three seconds.",
            prosecutionClosing: "The laptop, the lineup, the shoe size, the phone tower, and a story about a man in a red truck nobody can find. Put together, it's {DL}.",
            defenseClosing: "Seventy percent from a nightlight. A shoe size half the men in the county wear. A tower that covers {DL}'s own bed. And video that would have settled this, never collected. That's reasonable doubt.",
            victim: VictimFacts(relationship: "Strangers before the burglary.", harm: ["No physical injury. Woke to a stranger in the hallway; says she no longer sleeps through the night."], restitution: 900, restitutionBasis: "the wallet and its cash, the prescription, and the pried-open back door"),
            alibiCheck: AlibiCheck(holds: AlibiCheck.Finding(title: "Phone and Gas Station Records", detail: "{DL}'s phone stayed on the home Wi-Fi from 11:40 p.m. until 6:15 the next morning. The Kwik Fuel's camera, two days later, shows {DL} handing cash to a man at the tailgate of a red pickup and walking away with a laptop.", kind: .digital),
                                   breaks: AlibiCheck.Finding(title: "Phone Location Records", detail: "Records obtained by warrant show {DL}'s phone dropping off the home Wi-Fi after 1 a.m., connecting to the tower that serves the duplex's block for about forty minutes around the break-in, and returning home before four.", kind: .digital))
        )
    )

    // MARK: - 4. A fight in the kitchen

    static let kitchenStrangulation = CaseTemplate(
        key: "story.kitchenStrangulation", category: .violent,
        headlines: ["Domestic Call on {STREET} Ends in Strangulation Charge", "Two Stories From One Kitchen"],
        primaryLaw: "strangulation", lesserLaw: "simpleAssault", threshold: 5, lesserThreshold: 3,
        specification: "Assaulted {V} and inflicted physical injury by strangulation.",
        ageRange: 26...45, forcedPriorOffenses: ["Driving While Impaired"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {V} called 911 from a bathroom in the house on {STREET} that {V.he} shared with {D}, saying {DL} had choked {V.him} in the kitchen. Deputies found red marks on {VL}'s neck and a broken skillet on the floor; {DL} had fresh scratches on the face and forearm. {DL} says {VL} came at {DL} with the skillet after a night of drinking and {D.he} grabbed {VL} to stop it. By trial, {V} says {V.he} had been drinking heavily and can't remember who started it."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "911 Recording", "{V}, whispering: \"They choked me. I couldn't breathe. I thought I was going to die. I'm locked in the bathroom.\" The call lasts four minutes."),
            E(.forensic, 3, "Forensic Nurse Examination", "Petechiae (pinpoint bleeding) in both eyes, a linear bruise and abrasions on both sides of the neck, and a hoarse voice, documented about three hours after the call."),
            E(.video, 2, "Body-Camera Footage", "{VL} at the door, crying, holding the neck; says \"I tried to hit them with the pan after.\" {DL} in the kitchen says \"I had to hold {VL} off me.\"")
        ],
        defenseEvidence: [
            E(.physical, 2, "Defendant's Injuries", "Photos taken at the jail: four parallel scratches on {DL}'s left cheek and a bruise on the right forearm."),
            E(.document, 2, "Neighbor's Statement", "Next-door neighbor heard a crash and {VL} yelling \"I'll kill you, I swear to God\" before the screaming stopped."),
            E(.document, 1, "Recantation Letter", "A notarized letter from {V} to the District Attorney, written five weeks later: \"I was very drunk. I don't remember who started it. Please drop this.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{OFF}", role: "Responding deputy",
                        direct: ["\"The marks on the neck were fresh.\""],
                        cross: ["\"{DL} had scratches too.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find when you arrived?", "\"I got there at 1:22 a.m. {V} came to the door holding a towel to the neck, crying, voice raspy. In the kitchen a cast-iron skillet was on the floor with the handle cracked off, and a chair was knocked over.\""),
                            .direct("What did you see on {V}?", "\"Red marks on both sides of the neck, under the jaw, and what looked like fingernail scrapes. {VL}'s eyes were bloodshot. I photographed everything.\""),
                            .direct("What did {DL} say?", "\"That {VL} came at {DL} with the skillet and {D.he} grabbed {VL} to stop it. {DL} said, 'I had to hold {VL} off me.' I asked where {DL}'s hands were. {DL} said 'on {VL}'s shoulders, maybe the neck, I don't know.'\""),
                            .direct("Who was arrested?", "\"{DL}. Under our policy I have to identify the primary aggressor. Strangulation is the more serious injury, and {VL} was the one locked in a bathroom calling for help.\""),
                            .cross("My client had four scratches on the face and a bruised forearm?", "\"Yes. Fresh ones.\""),
                            .cross("{V} told you on camera that {V.he} tried to hit {DL} with the pan?", "\"{VL} said 'I tried to hit them with the pan after.' After.\""),
                            .cross("Both of them had been drinking?", "\"Both had an odor of alcohol. {V} more so. There were a dozen empty cans on the counter.\""),
                            .cross("You didn't interview the neighbor that night?", "\"No. The neighbor called in a statement two days later.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic nurse examiner",
                        direct: ["\"Petechiae in both eyes means blood flow was cut off.\""],
                        cross: ["\"I can't tell from the injuries who started the fight.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your training?", "\"I'm a registered nurse with forensic nurse examiner certification. I've examined about four hundred patients after assaults, around a hundred of them after strangulation.\""),
                            .direct("What did you find on {V}?", "\"Petechiae in both eyes, a linear bruise on the left side of the neck, abrasions on both sides, and a hoarse voice. {VL} reported trouble swallowing and a moment of losing vision.\""),
                            .direct("What causes petechiae?", "\"Pressure on the neck that blocks blood from draining out of the head. The tiny vessels in the eyes burst. It takes real, sustained pressure. It doesn't come from a push.\""),
                            .direct("Are those injuries consistent with someone being held off by the shoulders?", "\"Not really. Hands on the shoulders don't produce petechiae. Pressure on the neck does.\""),
                            .cross("Strangulation injuries can happen in a mutual struggle, can't they?", "\"They can happen in any struggle where hands end up on the neck.\""),
                            .cross("You can't tell the court who started the fight?", "\"No. I can tell the court what happened to {VL}'s neck.\""),
                            .cross("{V} told you {V.he} had about eight beers?", "\"{VL} said 'eight, maybe ten.'\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Complaining witness, testifying under subpoena",
                        direct: ["\"I don't remember who started it.\""],
                        cross: ["\"I picked up the pan. I remember that.\""],
                        weight: 0, lay: true,
                        exam: [
                            .direct("Do you want to be here today?", "\"No. I wrote the DA a letter asking to drop it. I got a subpoena anyway.\""),
                            .direct("What happened in the kitchen?", "\"We were arguing about money. We'd both been drinking. I was a lot drunker. I remember yelling. I remember the pan. Then I remember being on the floor and not being able to breathe, and then I was in the bathroom on the phone.\""),
                            .direct("You told the 911 operator {DL} choked you. Was that true?", "\"I couldn't breathe. That part's true. I was scared. I don't know what happened right before.\""),
                            .direct("Has {DL} asked you to change your story?", "\"No. Nobody asked me to. I just don't want {DL} in prison over a night I can't even remember right.\""),
                            .cross("You picked up the skillet first, didn't you?", "\"I remember having it in my hand. I don't remember if it was before or after.\""),
                            .cross("You told the neighbor's whole street 'I'll kill you'?", "\"If I said it, I was drunk. I've said stupid things drunk.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Next-door neighbor",
                        direct: ["\"I heard a crash, then {VL} yelling 'I'll kill you.'\""],
                        cross: ["\"I didn't see anything. I only heard it.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where were you that night?", "\"In bed. Our bedrooms share a wall with their kitchen. I've heard plenty of arguments over there, mostly just loud.\""),
                            .direct("What did you hear?", "\"A big metal crash, like a pan hitting the floor or the counter. Then {VL} screaming 'I'll kill you, I swear to God.' Then some thumping and a chair going over. Then it went quiet, and a minute later crying.\""),
                            .direct("Which came first, the crash or the threat?", "\"The crash, and then the yelling. I'm sure about that.\""),
                            .cross("You couldn't see anything?", "\"No. Just heard it through the wall.\""),
                            .cross("You didn't call 911 even after it went quiet?", "\"No. I figured it was more of the same. I feel bad about that now.\""),
                            .cross("You're friends with {DL}?", "\"We wave. {DL} helped me jump my car once. That's it.\"")
                        ])
        ],
        prosecutionTheory: ["{D} put both hands on {V}'s neck and pressed hard enough to burst blood vessels in {V.his} eyes. That's strangulation, whatever {VL} says now."],
        defenseTheory: ["{V} came at {DL} with a cast-iron skillet, screaming a death threat. {DL} grabbed {VL} to survive. Self-defense."],
        aggravating: ["The offense was committed in the home the victim shared with the defendant"],
        mitigating: ["{DL} was injured in the same incident", "{V} does not wish the prosecution to continue", "{DL} has no prior assault convictions"],
        victimImpacts: ["{V}: \"I'm not a victim of {DL}. We were both a mess that night. I'm in AA now. I'd like {DL} to go too, not to prison.\""],
        allocutions: ["\"I should have walked out the door. I didn't. I'll carry that.\""],
        guiltyTruths: ["{DL} later told a cellmate the skillet came out only after {D.he} had {VL} against the counter."],
        innocentTruths: ["Months after trial, {V} told a counselor {V.he} swung the pan first and only remembered once sober."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        extras: ["TIME": ["1:09 a.m."]],
        story: StoryExtras(
            timeline: [(0, "1:09 a.m.: 911 call from {V}. {OFF} arrives at 1:22 a.m.; {DL} arrested."),
                       (0, "4:15 a.m.: Forensic nurse examination of {V} documents petechiae and neck injuries."),
                       (2, "Neighbor calls the Sheriff's Office with a statement."),
                       (36, "{V} sends a notarized letter to the District Attorney asking that the charge be dropped.")],
            howIdentified: "{DL} was in the house when deputies arrived; both parties named each other.",
            notDone: ["The skillet was not tested for fingerprints or blood.", "{DL}'s injuries were photographed at the jail but not examined by a medical professional."],
            defendantExam: [
                .direct("What started the argument?", "\"Rent. {VL} had spent it. We'd been drinking since the afternoon. It got loud.\""),
                .direct("What happened with the skillet?", "\"{VL} grabbed it off the stove and swung at my head. I put my arm up and it caught my forearm. Then {VL} scratched my face. I grabbed {VL} and pinned {V.him} against the counter so it would stop.\""),
                .direct("Where were your hands?", "\"I was grabbing whatever I could. Shoulders, collar, I don't know. Maybe the neck. I wasn't trying to choke anybody. I was trying to not get hit with a pan again.\""),
                .direct("How long did you hold on?", "\"A few seconds. Until {VL} dropped the pan. Then I let go and {VL} ran to the bathroom.\""),
                .cross("Petechiae take sustained pressure. A few seconds?", "\"It felt like a few seconds. I don't know how long it was.\""),
                .cross("You told the deputy your hands were on the shoulders.", "\"That's what I thought at the time. I've had a long time to think about it.\""),
                .cross("{VL} told 911 the pan came after.", "\"{VL} was terrified and drunk. So was I. The pan came first.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"Isn't it true you told the forensic nurse, 'They squeezed until I saw black'?\"",
                                  answer: "\"I might have. I don't remember.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Leading", shouldSustain: false,
                                  explanation: "A party may lead its own witness when the witness has become hostile or adverse. {V} is testifying under subpoena against the State's position, so leading is permitted (Rule 611(c)).",
                                  doctrineID: "leading", weight: 1))
            ],
            prosecutionOpening: "Burst blood vessels in both eyes. A whisper to 911 from a locked bathroom. {V} doesn't want to be here, and the law understands why. The injuries tell the story.",
            defenseOpening: "A cast-iron skillet. Scratches down {DL}'s face. A neighbor who heard {VL} scream 'I'll kill you.' And {V}, who now asks this court not to punish {DL}. This is self-defense.",
            prosecutionClosing: "Even if {VL} picked up the pan, holding someone by the neck until their eyes hemorrhage isn't reasonable force. That's strangulation.",
            defenseClosing: "The State has to disprove self-defense beyond a reasonable doubt. On this record, with a death threat and a skillet, it hasn't.",
            victim: VictimFacts(relationship: "Shared a house with the defendant.")
        )
    )

    // MARK: - 5. Three people, one closet

    static let sharedApartment = CaseTemplate(
        key: "story.sharedApartment", category: .drugs,
        headlines: ["Cocaine Found in Shared Apartment", "Whose Shoebox Is It?"],
        primaryLaw: "pwisd", lesserLaw: "possSchedII", threshold: 4, lesserThreshold: 2,
        specification: "Possessed cocaine with intent to sell or deliver.",
        secondary: [
            SecondaryCharge(lawID: "possSchedII", specification: "Possessed cocaine, a Schedule II controlled substance.", chance: 1.0, threshold: 2),
            SecondaryCharge(lawID: "maintainingDwelling", specification: "Kept and maintained the apartment on {STREET} for keeping and selling controlled substances.", chance: 1.0, threshold: 3),
            SecondaryCharge(lawID: "possParaphernalia", specification: "Possessed a digital scale and baggies for packaging controlled substances.", chance: 1.0, threshold: 2)
        ],
        ageRange: 21...34, occupations: ["warehouse worker"], hasVictim: false,
        summaries: [
            "On {DATE}, narcotics detectives executed a search warrant at a three-bedroom apartment on {STREET} in {HOOD}, leased to {D} and shared with two roommates. In a shoebox on the top shelf of the hall closet they found 31 knotted baggies of cocaine totaling 22.4 grams and $1,840 in cash; a digital scale was in a kitchen drawer. {DL} was the only person home. One roommate, {ALT}, who has a prior conviction for selling cocaine, moved out two days later. {DL}, a warehouse forklift operator, says the closet was shared and the box wasn't {D.hers}."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Shoebox Contents", "Thirty-one knotted corner baggies of white powder and $1,840 in mostly twenties, in a size 11 sneaker box on the top shelf of the hall closet. {DL} wears a size 11.", .search),
            E(.forensic, 2, "State Crime Laboratory Report", "Representative sampling confirmed cocaine hydrochloride; total net weight 22.4 grams."),
            E(.digital, 3, "Text Messages", "From {DL}'s phone over two weeks: \"u good for tonight?\" \"need 2 of the usual\" \"bring 40.\" {DL}'s replies include \"5 mins\" and \"at the door.\"", .search),
            E(.physical, 1, "Digital Scale", "A pocket scale with white residue in a kitchen drawer used by all three roommates.", .search)
        ],
        defenseEvidence: [
            E(.document, 3, "Roommate's Record", "{ALT} has a 2021 conviction for selling cocaine and moved out of the apartment two days after the search, leaving the lease to {DL}."),
            E(.forensic, 2, "Fingerprint Results", "The State Crime Laboratory found two usable latent prints on the shoebox. Neither matches {DL}. They were never compared to {ALT}."),
            E(.document, 1, "Pay Stubs", "{DL} has worked full time at a distribution warehouse for three years, earning about $38,000 a year.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Narcotics detective",
                        direct: ["\"The baggies were packaged for street sale.\""],
                        cross: ["\"Neither print on the box was {DL}'s.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What led to the search warrant?", "\"A confidential source reported buying cocaine at that apartment twice in the prior month. We did one controlled buy through the source; the source went inside and came out with two baggies. I used that to get the warrant.\""),
                            .direct("Who was home when you executed it?", "\"Only {DL}, in the living room. The other two roommates weren't there.\""),
                            .direct("What did you find?", "\"In the hall closet, top shelf, a size 11 sneaker box with thirty-one knotted baggies of cocaine and eighteen hundred and forty dollars. A scale in the kitchen drawer. {DL}'s phone, which {D.he} unlocked for us, had the texts in evidence.\""),
                            .direct("Why do you believe this was for sale and not personal use?", "\"Thirty-one individually packaged bags of about three-quarters of a gram each, cash in small bills, a scale, and texts that read like orders. A user buys a bag. A seller has thirty-one.\""),
                            .direct("What do the texts mean, in your experience?", "\"'Need 2 of the usual' and 'bring 40' are typical ways of ordering two bags at twenty dollars each. '5 mins' and 'at the door' sound like delivery.\""),
                            .cross("The controlled buy: who did your source buy from?", "\"The source couldn't identify the seller by name. Said it was 'one of the people who lives there.'\""),
                            .cross("That closet is in a shared hallway used by all three tenants?", "\"All three of them use it. There's a vacuum and somebody's bike in there too.\""),
                            .cross("Neither print on the shoebox matched my client?", "\"Neither one. One was the landlord's, one we never identified.\""),
                            .cross("You never compared them to {ALT}?", "\"No. By then {ALT} had moved and we'd charged {DL}. That was a mistake.\""),
                            .cross("The texts could just as easily be about picking up food, or splitting a bill?", "\"They could be about something else. In my experience, they aren't.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic chemist, State Crime Laboratory",
                        direct: ["\"It was cocaine, 22.4 grams net.\""],
                        cross: ["\"I don't know who owned it.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you test?", "\"Thirty-one baggies. I weighed each and tested a statistically representative sample of them by gas chromatography and mass spectrometry, which is our accredited procedure.\""),
                            .direct("What were the results?", "\"Every sample tested was cocaine hydrochloride. The total net weight of all thirty-one bags, without packaging, was 22.4 grams.\""),
                            .cross("You didn't test all thirty-one bags?", "\"No, a representative sample, which the court can rely on under our accredited method. Every one I tested was cocaine.\""),
                            .cross("You have no information about who owned the box?", "\"None. I test what's in it.\""),
                            .cross("Twenty-two grams is under the 28-gram trafficking threshold?", "\"Six grams under it, yes.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former partner of {ALT}",
                        direct: ["\"{ALT} kept a shoebox in that closet.\""],
                        cross: ["\"I never looked inside it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How do you know the apartment?", "\"I dated {ALT} for about a year and stayed there most weekends until we broke up, about a month before the raid.\""),
                            .direct("Did you see {ALT} use the hall closet?", "\"All the time. {ALT} kept a sneaker box on the top shelf and told me not to touch it. One time I went to get a towel and {ALT} grabbed my arm and said, 'Not that shelf.'\""),
                            .direct("Did you ever see {DL} use that box?", "\"No. {DL} worked early mornings and was usually asleep when we came in.\""),
                            .cross("You never actually looked inside the box?", "\"I didn't open it. I knew what it was.\""),
                            .cross("You and {ALT} broke up badly?", "\"Badly enough. That doesn't change what I saw.\""),
                            .cross("What size shoe does {ALT} wear?", "\"I don't know. Big. Eleven, twelve.\"")
                        ])
        ],
        prosecutionTheory: ["The lease is in {DL}'s name, the shoebox is {D.his} size, the texts are on {D.his} phone, and {D.he} was the one home. {D} was selling cocaine out of that apartment."],
        defenseTheory: ["Three people lived there. The one with a cocaine-dealing record moved out two days after the raid, and the State never checked whether the prints on the box were that person's."],
        aggravating: ["Sales were conducted from a residence"],
        mitigating: ["{DL} has steady full-time employment", "No prior drug convictions"],
        allocutions: ["\"I've never sold anything in my life except my old car. I should have watched who I lived with.\""],
        guiltyTruths: ["After trial, {DL}'s phone backup turned up a contact saved as \"plug\" with dozens of messages arranging pickups."],
        innocentTruths: ["A year later, {ALT} was caught with an identical sneaker box in another apartment, and the old latent prints from the first box matched {ALT.him}."],
        moods: [.indifferent], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(-30, "Confidential source reports buying cocaine at the apartment."),
                       (-6, "Controlled buy through the source at the apartment door."),
                       (0, "Search warrant executed. Shoebox, cash, and scale seized; {DL} arrested."),
                       (2, "{ALT} moves out of the apartment."),
                       (44, "State Crime Laboratory confirms 22.4 grams of cocaine."),
                       (61, "Latent print report: two usable prints on the shoebox, neither {DL}'s.")],
            howIdentified: "{DL} held the lease and was the only person home when the warrant was executed.",
            notDone: ["The latent prints on the shoebox were never compared to {ALT}.", "{ALT} was never interviewed."],
            defendantExam: [
                .direct("Whose shoebox was that?", "\"Not mine. I've seen {ALT} take it down. I never opened it. I don't go in that closet much; my stuff is in my room.\""),
                .direct("What about the texts?", "\"I'm the one with a car. People in the building text me for rides, to bring them food, to split a delivery. 'Bring 40' was my cousin owing me forty dollars for a tank of gas.\""),
                .direct("Why did you unlock your phone for the detectives?", "\"Because I had nothing to hide. I thought they'd see that.\""),
                .cross("'Need 2 of the usual' is about a tank of gas?", "\"That one was a friend wanting two plates from the Jamaican place downstairs. They know what I usually get.\""),
                .cross("The box is your shoe size.", "\"It's also {ALT}'s. Half the guys I know wear an eleven.\""),
                .cross("And you never once wondered why {ALT} guarded a shoebox?", "\"I wondered. I didn't ask. I should have.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"What did your confidential source tell you about who was selling?\"",
                                  answer: "\"That one of the people who lived there was selling out of the apartment.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay and confrontation", shouldSustain: true,
                                  explanation: "The source isn't testifying. Offering the source's out-of-court accusation for its truth is hearsay and denies the defendant the chance to cross-examine.",
                                  doctrineID: "hearsay", weight: 2))
            ],
            prosecutionOpening: "A shoebox of cocaine packaged for sale, in {DL}'s apartment, in {D.his} size, with texts on {D.his} phone that read like orders. The State will prove {D} possessed it to sell it.",
            defenseOpening: "Three people shared that hallway closet. One had a record for selling cocaine and moved out two days later. The prints on the box aren't {DL}'s, and nobody ever checked whether they were that roommate's.",
            prosecutionClosing: "Possession can be shared. {DL} controlled that apartment, and the texts show {D.he} was dealing. The State has proven intent to sell.",
            defenseClosing: "Constructive possession in a shared space needs more than a lease. The State had the means to find out whose prints were on that box and chose not to. That's reasonable doubt.",
            employer: "Harborview Distribution Center",
            yearsAtJob: 3
        )
    )

    // MARK: - 6. The caregiver and the checkbook

    static let caregiverAccount = CaseTemplate(
        key: "story.caregiverAccount", category: .whiteCollar,
        headlines: ["Caregiver Accused of Draining Client's Savings", "Gifts or Theft? $68,000 From a 91-Year-Old"],
        primaryLaw: "exploitationElder", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Knowingly exploited {V}, an older adult, by using {V.his} funds for {DL}'s own benefit through deception and undue influence.",
        secondary: [
            SecondaryCharge(lawID: "exploitationElder", specification: "Knowingly exploited {V} by having a used car purchased with {V.his} funds and titled in {DL}'s name.", chance: 1.0, threshold: 3),
            SecondaryCharge(lawID: "cardFraud", specification: "Used {V}'s debit card without consent for $6,700 in cash withdrawals over fourteen months.", chance: 1.0, threshold: 3)
        ],
        ageRange: 29...52, occupations: ["home health aide"], hasVictim: true,
        summaries: [
            "For two years {D}, a home health aide, cared for {V}, 91, a retired textile mill supervisor who lives alone in {HOOD}. Over fourteen months, $68,000 left {VL}'s savings: checks to {DL} written in {D.his} handwriting and signed by {VL}, a used car titled to {DL}, and cash withdrawals made with {VL}'s debit card. {VL}'s niece, who lives in Ohio, found the statements after {V.he} fell and was hospitalized. {DL} says {VL} insisted on every gift and called {DL} \"the only family who shows up.\" {VL}, who has mild dementia but sometimes recalls things clearly, has told different people different things."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Bank Statements", "Thirty-one checks payable to {DL} totaling $41,500, a $19,800 check to Hollis Auto Sales for a car titled in {D.his} name, and $6,700 in ATM withdrawals with {VL}'s card at times {DL} was on shift.", .search),
            E(.document, 2, "Neurologist's Records", "Diagnosis of mild-to-moderate Alzheimer's-type dementia eighteen months before the first large check; notes say {VL} \"needs assistance with finances.\""),
            E(.document, 2, "Agency Policy", "{DL}'s employer, {AGENCY}, prohibits aides from accepting any gift over $25 from a client. {DL} signed the policy every year."),
            E(.statement, 2, "Statement to Adult Protective Services", "{V}: \"I don't know anything about a car. I don't drive anymore. Did I buy a car?\"")
        ],
        defenseEvidence: [
            E(.document, 3, "Handwritten Note", "A note in {VL}'s hand, dated during the period: \"I want {DL} to have the car and what {D.he} needs. Nobody else comes. — {V}\" A handwriting examiner for the defense says it is {VL}'s writing."),
            E(.statement, 2, "Video Recorded by {DL}", "A 40-second phone video: {VL}, at the kitchen table, says \"I'm giving you this because I want to, and I'll tell anybody.\""),
            E(.document, 1, "Niece's Visit Log", "Visitor sign-in at {VL}'s doctor's office and the niece's own texts show two visits in three years.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s niece",
                        direct: ["\"My aunt would never buy a stranger a car.\""],
                        cross: ["\"I visited twice in three years.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What is your relationship to {V}?", "\"My aunt is my late mother's sister. I'm the only family left. I live outside Columbus and I hold the power of attorney, though I'd never had to use it before the fall.\""),
                            .direct("How did you find out about the money?", "\"When my aunt was in the hospital I went through the mail to pay bills. The savings account had nine thousand dollars in it. When my uncle died there was close to eighty.\""),
                            .direct("What kind of person is your aunt with money?", "\"Careful. Mill supervisor for thirty-four years. Clipped coupons, saved string. She bought one car in a lifetime and drove it twenty years. A gift of twenty thousand dollars to anyone is unimaginable.\""),
                            .direct("Did you talk to your aunt about it?", "\"I asked if she had bought {DL} a car. She looked confused and asked me who {DL} was. A minute later she said {DL} was a sweetheart who did {VL}'s hair. {VL} goes in and out.\""),
                            .cross("You visited your aunt twice in three years?", "\"Twice in person. I called every Sunday.\""),
                            .cross("{VL} told you on the phone {V.he} was lonely?", "\"Often. That's why I paid for an aide.\""),
                            .cross("You're the sole heir under {VL}'s will?", "\"I am. I'm not here about the inheritance. I'm here because somebody took advantage of my aunt.\""),
                            .cross("Your aunt calls {DL} by name and asks about {D.him} in the hospital?", "\"Sometimes. She also asks about my mother, who's been dead nine years.\"")
                        ]),
            WitnessSeed(name: nil, role: "Adult Protective Services investigator",
                        direct: ["\"The pattern fits financial exploitation.\""],
                        cross: ["\"I never saw the handwritten note before the case was filed.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your role?", "\"I'm a social worker with the Department of Social Services, Adult Protective Services. I've investigated financial exploitation reports for eight years.\""),
                            .direct("What did you find?", "\"Checks written in {DL}'s handwriting with only {VL}'s signature, a vehicle in {DL}'s name paid for by {VL}, and cash withdrawals during {DL}'s shifts. {VL} could not tell me the account balance, the year, or the purpose of any of the checks.\""),
                            .direct("Why does it matter who wrote the checks?", "\"When a caregiver fills out the check and the older adult only signs, it tells me the caregiver is driving the transaction. Combined with cognitive decline and isolation, that's the textbook pattern.\""),
                            .direct("Did {VL} understand what was happening, in your judgment?", "\"Not consistently. On my second visit {VL} said the car was for a church raffle. On my third {VL} didn't remember the car at all.\""),
                            .cross("You never saw the handwritten note or the video before charges were filed?", "\"No. They came from the defense.\""),
                            .cross("People with mild dementia can still make real decisions about who they love?", "\"They can. Capacity isn't all or nothing. The question is whether these decisions were {VL}'s own.\""),
                            .cross("You'd agree loneliness can be real, and kindness can be real, even inside a pattern like this?", "\"I'd agree. I see it every week. That's what makes these cases hard.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{VL}'s neighbor and fellow church member",
                        direct: ["\"{VL} told me {DL} was the daughter {VL} never had.\""],
                        cross: ["\"I don't know what was said about money.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How long have you known {V}?", "\"Forty years. We sat two pews apart at Bethel. I live three houses down.\""),
                            .direct("What did you see of {DL}?", "\"Every day, rain or shine. {DL} took {VL} to the doctor, to church, to the beauty shop on Thursdays. Brought {VL} to my porch for tea. Nobody else did that, including the niece.\""),
                            .direct("Did {VL} ever talk to you about {DL}?", "\"Many times. {VL} said, 'That child is the daughter I never had.' Last spring {V.he} said, 'I bought {DL} a car so {D.he} could get here when the old one broke down, and I'd do it again.' {VL} was clear as a bell that day.\""),
                            .cross("Was {VL} clear as a bell every day?", "\"No. Some days {VL} called me by my brother's name.\""),
                            .cross("You never saw a check written?", "\"No. I don't know anything about the checks.\""),
                            .cross("Did {VL} ever mention giving away forty thousand dollars beyond the car?", "\"No. Just the car.\"")
                        ])
        ],
        prosecutionTheory: ["{D} was paid to care for a 91-year-old with dementia and instead filled out checks payable to {D.him}, bought {D.him} a car with {VL}'s savings, and drained the account."],
        defenseTheory: ["{V} was lonely, and {DL} was the only person who showed up. {VL} chose to be generous, wrote it down, and said it on video. Generosity isn't a crime."],
        aggravating: ["{V} was especially vulnerable due to age and dementia"],
        mitigating: ["{DL} provided genuine daily care for two years", "No prior criminal record"],
        victimImpacts: ["{V}'s niece, for {V.him}: \"My aunt keeps asking when {DL} is coming back. I don't know how to explain any of this to her.\""],
        allocutions: ["\"I loved {VL}. I still do. I should have said no to the money. I didn't know how to say no to someone who'd given me so much more than money.\""],
        guiltyTruths: ["After the trial, {DL}'s cousin told investigators {D.he} had bragged about having \"an old lady checkbook.\""],
        innocentTruths: ["{VL}'s pastor later produced a sealed letter {V.he} had left with the church a year earlier, leaving the house to {DL}."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        extras: ["AGENCY": ["Carolina Comfort Home Care", "Hollis Senior Companions", "Piedmont Home Health"]],
        story: StoryExtras(
            timeline: [(0, "{V} falls at home and is admitted to Hollis Regional Medical Center."),
                       (5, "Niece reviews bank statements and reports suspected exploitation to Adult Protective Services."),
                       (12, "APS investigator interviews {V} at a rehabilitation center."),
                       (30, "Bank records and vehicle title obtained by the Sheriff's Office."),
                       (52, "{DL} interviewed; produces the handwritten note and video."),
                       (66, "{DL} charged with exploitation of an older adult.")],
            howIdentified: "{DL} wrote the checks, received the money, and holds title to the car bought with {VL}'s funds.",
            notDone: ["The State never had the handwritten note independently examined.", "No capacity evaluation of {V} was performed during the fourteen months."],
            defendantExam: [
                .direct("How did you come to care for {V}?", "\"The agency sent me two years ago. Four hours a day at first, then eight. After a while I came on weekends without pay because {VL} was alone.\""),
                .direct("Why did you write out the checks?", "\"{VL}'s hands shake. {VL} would tell me the amount and I'd fill it in and {V.he} would sign. I did the same for the power bill and the pharmacy. That's how it worked.\""),
                .direct("Why record the video?", "\"Because I was scared of exactly this. My mother told me, if somebody gives you something big, get it in writing. So I asked {VL} to write it down and say it on camera.\""),
                .direct("What about the ATM withdrawals?", "\"Groceries, prescriptions, the beauty shop, church envelopes. Some of it was cash for me when {VL} insisted. I didn't keep receipts. I should have.\""),
                .cross("Your employer's policy forbids gifts over $25. You signed it four times.", "\"I know. I broke it. I'm not proud of that.\""),
                .cross("You asked {VL} to make that video. You chose the words.", "\"I asked {VL} to say it in {V.his} own words. Those are {VL}'s words.\""),
                .cross("Forty-one thousand dollars in checks, beyond the car. What was that for?", "\"Rent when I was behind, my son's braces, a lot of things. {VL} kept saying, 'What else do you need?' I should have said nothing.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Prosecutor: \"In your experience, do caregivers who exploit clients usually make videos like this one?\"",
                                  answer: "\"It's become more common. They do it to protect themselves.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Improper profile evidence", shouldSustain: true,
                                  explanation: "Testimony that the defendant's conduct matches a 'profile' of guilty people invites the factfinder to convict by category rather than evidence.",
                                  doctrineID: "relevance", weight: 1))
            ],
            prosecutionOpening: "A 91-year-old with dementia, a caregiver who filled out the checks, a car in the caregiver's name, and an account that went from eighty thousand to nine. The State will prove exploitation.",
            defenseOpening: "You'll hear {VL} in {V.his} own voice, and see it in {V.his} own handwriting: this was a gift to the one person who showed up. The question is whose choice it was. It was {VL}'s.",
            prosecutionClosing: "A note and a video, both arranged by the person taking the money, don't make it a free choice. Undue influence is exactly this.",
            defenseClosing: "The State's own investigator says capacity isn't all or nothing and that kindness was real. On this record there's reasonable doubt that {DL} deceived or overpowered anyone.",
            genders: ["D": .female, "V": .female],
            victim: VictimFacts(occupation: "Retired textile mill supervisor", relationship: "The defendant was the victim's home health aide.", family: "Widowed; a niece in Ohio.", harm: ["No physical injury. Most of her savings are gone."], restitution: 68000, restitutionBasis: "the $68,000 that left her savings, including the car"),
            employer: "{AGENCY}"
        )
    )

    // MARK: - 7. Shots in a parking lot

    static let parkingLotShooting = CaseTemplate(
        key: "story.parkingLotShooting", category: .violent,
        headlines: ["Driver Shot in {LOT} Parking Lot", "Road Rage or Self-Defense?"],
        primaryLaw: "awdwikisi", lesserLaw: "awdwisi", threshold: 4, lesserThreshold: 2,
        specification: "Assaulted {V} with a handgun, with intent to kill, inflicting serious injury.",
        ageRange: 23...48, hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, after a near-collision on {STREET}, {V} followed {D}'s pickup into the parking lot of {LOT} in {HOOD}. {V} got out and walked to {DL}'s driver's door. {DL}, who has a concealed carry permit, fired twice through the open window, hitting {V} in the shoulder and abdomen. {V} survived after surgery. {DL} says {V} reached into the truck and grabbed {DL}'s collar; {V} says {V.he} only knocked on the door frame and yelled. A store camera caught most of it from sixty yards away."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Store Surveillance Video", "From sixty yards: {V} walks quickly to the truck and stands at the driver's window for about six seconds, arms moving. Two muzzle flashes. {V}'s left arm is near or inside the window frame; the angle and a light pole block the view of {VL}'s hands for most of it."),
            E(.forensic, 2, "Surgical and Wound Records", "Two entry wounds, left shoulder and left upper abdomen, no exit; trajectory slightly downward. Emergency surgery to repair the spleen and colon."),
            E(.physical, 2, "No Weapon on {V}", "Officers found no weapon on {V} or in {V.his} car. A phone was in {VL}'s right hand when officers arrived."),
            E(.statement, 2, "911 Call by {DL}", "\"I just shot somebody, they came at my truck, they were grabbing me, send an ambulance.\" Call placed 40 seconds after the shots.")
        ],
        defenseEvidence: [
            E(.physical, 3, "Torn Shirt Collar", "{DL}'s shirt collar is torn at the left seam, photographed by officers at the scene. {V}'s DNA is on the collar, according to the State Crime Laboratory."),
            E(.document, 2, "Victim's Prior Record", "{V} has a 2019 conviction for assault on a female and a 2022 charge for road-rage assault, dismissed when the complainant didn't appear."),
            E(.document, 1, "Concealed Carry Permit", "{DL} has held a concealed handgun permit for six years with no incidents.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Shooting victim",
                        direct: ["\"I knocked on the door frame and told {DL} to learn to drive. Then {DL} shot me.\""],
                        cross: ["\"I might have touched the shirt. I don't remember grabbing it.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What happened on {STREET}?", "\"{DL}'s truck cut into my lane coming out of the gas station. I had to stand on the brakes. My kid's car seat was in the back, empty thank God. I laid on the horn.\""),
                            .direct("Why did you follow the truck?", "\"I was angry. I wanted to tell {DL} they almost killed somebody. It was stupid. I know that.\""),
                            .direct("What happened at the truck?", "\"I walked up and banged on the door frame and said 'You almost hit me, learn to drive.' I was loud. I was cussing. I wasn't trying to hurt anybody. I didn't have anything in my hands but my phone.\""),
                            .direct("Then what?", "\"I saw the gun come up and I turned. I felt the first one in my shoulder and the second one knocked the air out of me. I don't remember much after that until the ambulance.\""),
                            .direct("What has your recovery been like?", "\"Two surgeries. I lost my spleen and part of my colon. I couldn't go back to work at the plant for five months.\""),
                            .cross("You followed a stranger a half mile into a parking lot because you were angry?", "\"I was mad. I wanted the plate number. That's all I was thinking.\""),
                            .cross("You reached your arm inside the window, didn't you?", "\"My hand might have gone in when I was banging. I don't remember grabbing anybody.\""),
                            .cross("Your DNA is on my client's torn collar. How did it get there?", "\"I don't know. Maybe I touched it. I'm telling you I didn't try to drag anybody out of a truck.\""),
                            .cross("This isn't the first time you've confronted a driver, is it?", "\"That other thing was dismissed.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Lead detective, violent crimes unit",
                        direct: ["\"{VL} was unarmed and the truck could have driven away.\""],
                        cross: ["\"The collar was torn and had {VL}'s DNA on it.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find at the scene?", "\"{DL}'s pickup was parked nose-in with its engine running. The driver's window was down. There was open pavement to the left and behind the truck. {VL}'s sedan was parked crooked behind and to the right, partly boxing the truck in on that side but not the other.\""),
                            .direct("Could {DL} have driven away?", "\"In my opinion, yes. Reversing left was open. It would have taken a three-point turn, maybe five seconds.\""),
                            .direct("What did the video show?", "\"About six seconds of {VL} at the window, arms moving. Then two flashes. The light pole blocks {VL}'s hands for much of it. You can't tell from the video whether {VL} grabbed anything.\""),
                            .direct("Was {VL} armed?", "\"No. A phone in the right hand. Nothing in the car.\""),
                            .cross("{DL} called 911 within forty seconds and stayed?", "\"Yes. {DL} was standing by the truck with the gun on the hood when patrol got there.\""),
                            .cross("You photographed a fresh tear in {DL}'s collar?", "\"I did. The lab later found {VL}'s DNA on it.\""),
                            .cross("Reversing would have meant taking your eyes off someone who already had an arm in your window?", "\"It would have meant turning to look behind, yes.\""),
                            .cross("North Carolina doesn't require a person in their own vehicle to retreat, does it?", "\"I'm not the lawyer. I know the castle doctrine covers occupied vehicles in some circumstances.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Shopper in the parking lot",
                        direct: ["\"{VL} had {DL} by the shirt, pulling.\""],
                        cross: ["\"I was about forty feet away, loading groceries.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where were you?", "\"Loading groceries into my trunk, two rows over. Maybe forty feet. I heard the screech of tires and the horn first, so I was already looking.\""),
                            .direct("What did you see?", "\"The other driver got out fast and stomped up to the truck yelling, reached in the window with the left arm. I saw the driver's head jerk toward the window, like it was being pulled.\""),
                            .direct("How sure are you of that?", "\"Sure about the arm going in and the head jerking. That's why I started toward them, I thought that driver was about to be pulled out. Then the shots.\""),
                            .cross("You told the first officer you 'didn't really see what happened at the window.'", "\"I said I didn't see the gun. I was shaking. I told the detective about the arm the next day.\""),
                            .cross("A light pole stands between the store camera and that window. Was it between you and the window too?", "\"No. I was off to the side, the other way.\""),
                            .cross("You've never met either of them?", "\"Never. I'd never seen either one before that night.\"")
                        ])
        ],
        prosecutionTheory: ["{V} was angry and loud, but unarmed. {D} had a running engine and an open lane, and chose to fire twice instead."],
        defenseTheory: ["{V} chased {DL} into a parking lot, reached into {D.his} truck, and grabbed {D.him} by the collar. {DL} had every right to defend against someone trying to drag {D.him} out of {D.his} own vehicle."],
        aggravating: ["{DL} fired twice at close range"],
        mitigating: ["{DL} called 911 immediately and remained at the scene", "{V} was the initial aggressor in following and confronting {DL}", "No prior criminal record"],
        victimImpacts: ["{V}: \"I was wrong to follow that truck. I've said that from day one. I didn't deserve to bleed out in a parking lot for it.\""],
        allocutions: ["\"I've replayed those six seconds every night. I was sure {VL} was going to pull me out of that truck. I'm sorry {VL} was hurt. I don't know what else I could have done.\""],
        guiltyTruths: ["{DL}'s dashcam, which {D.he} had told police wasn't recording, turned up a year later: {V}'s hands were on the door frame, not the collar, when {DL} fired."],
        innocentTruths: ["A second shopper's phone video, posted online after the trial, showed {V} pulling {DL} halfway out of the window by the shirt."],
        moods: [.divided], doctrines: ["selfDefense", "imperfectSelfDefense", "burdenOfProof"],
        extras: ["TIME": ["8:47 p.m."], "LOT": ["Food Lion", "Harris Teeter", "the Dollar General on Route 17"]],
        story: StoryExtras(
            timeline: [(0, "8:47 p.m.: two shots reported in the parking lot of {LOT}. {DL} calls 911 at 8:48 p.m. and remains at the scene."),
                       (0, "{V} taken to Hollis Regional Medical Center for emergency surgery. {DL}'s shirt and handgun collected."),
                       (1, "Shopper gives a recorded statement describing {V}'s arm inside the truck window."),
                       (2, "Store surveillance video obtained."),
                       (9, "{DL} charged with assault with a deadly weapon with intent to kill inflicting serious injury."),
                       (58, "State Crime Laboratory reports {V}'s DNA on {DL}'s collar.")],
            howIdentified: "{DL} called 911, identified as the shooter, and remained at the scene.",
            notDone: ["{DL}'s pickup was not checked for a working dashcam.", "Other shoppers in the lot were not canvassed beyond the one who came forward."],
            defendantExam: [
                .direct("What happened on {STREET}?", "\"I pulled out of the gas station and didn't see the other car. It was coming fast. I raised my hand to say sorry. The other car laid on the horn and followed me for half a mile, right on my bumper.\""),
                .direct("Why pull into the parking lot?", "\"I thought they'd keep going if I got off the road. And there'd be people around. I was trying to make it stop.\""),
                .direct("What happened at your window?", "\"{VL} was screaming, then an arm came through the window, grabbed my collar, and yanked. My head hit the door frame. I thought I was being pulled out, and I didn't know what {VL} had in the other hand.\""),
                .direct("Why not drive away?", "\"{VL}'s car was behind me on the right. To back out I'd have had to turn around and look, with {VL}'s hand on my shirt. I didn't think I had five seconds.\""),
                .cross("You had your gun out before {VL} ever reached in, didn't you?", "\"It was in the console. I got it out when they grabbed me.\""),
                .cross("You told 911 'they came at my truck.' Not 'they grabbed me.'", "\"I said they were grabbing me. Listen to the whole call.\""),
                .cross("Two shots. After the first, {VL} was turning away.", "\"It happened in about one second. I didn't decide to fire twice. I just fired.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"Tell the court about the 2022 road-rage charge.\"",
                                  answer: "\"Some driver said I punched their window. It got dismissed.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper character evidence", shouldSustain: false,
                                  explanation: "When self-defense is raised, the victim's prior violent acts known to the defendant, or offered to show who was the aggressor, can be admissible (Rule 404(a)(2) and 405). The dismissal goes to weight.",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "An unarmed driver, angry and foolish, at a truck window for six seconds. {D} had an open lane and a running engine, and fired twice instead. That isn't self-defense.",
            defenseOpening: "A stranger chased {DL} half a mile, boxed {D.him} in, and reached into {D.his} truck. {VL}'s DNA is on {DL}'s torn collar. {DL} fired, called 911, and waited for police.",
            prosecutionClosing: "Even if {VL} touched the collar, deadly force has to be reasonable. Two rounds into an unarmed person, with a way out, isn't.",
            defenseClosing: "The State must disprove self-defense beyond a reasonable doubt. A torn collar with {VL}'s DNA and an eyewitness who saw the arm go in. The State hasn't done it."
        )
    )

    // MARK: - 8. Deposits for kitchens that never came

    static let contractorDeposits = CaseTemplate(
        key: "story.contractorDeposits", category: .whiteCollar,
        headlines: ["Six Families, Six Deposits, No Kitchens", "Contractor Charged After Remodels Never Start"],
        primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 6, lesserThreshold: 4,
        specification: "Obtained a $14,500 deposit from {V} by falsely representing that materials had been ordered for {V.his} kitchen remodel.",
        secondary: [
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained an $8,200 deposit from a homeowner on {STREET} by falsely representing that tile had been ordered.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained an $11,000 deposit from a homeowner in {HOOD} by falsely representing that a crew was scheduled.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained a $9,600 deposit from a retired couple in {HOOD} by falsely representing that permits had been pulled.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained a $7,700 deposit from a homeowner in {CITY} by falsely representing that cabinets were on order.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "falsePretenses", specification: "Obtained a $10,000 deposit from a homeowner in {HOOD} by falsely representing that countertops had been fabricated.", chance: 1.0, threshold: 5)
        ],
        ageRange: 35...58, occupations: ["remodeling contractor"], hasVictim: true,
        summaries: [
            "Over five months, {D}, owner of {BIZ} in {HOOD}, took deposits from six homeowners for kitchen and bathroom remodels, $61,000 in all. None of the work was finished; three jobs never started. {V} paid $14,500 after {DL} told {VL} the cabinets were \"already on order and arriving in three weeks.\" No cabinets were ever ordered. {DL} says the business collapsed when a supplier went under and {D.he} was robbing Peter to pay Paul to keep it alive, not stealing. The State charged each family's deposit as its own count; {VL}'s leads the indictment because of what {DL} said to get it."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Text Message to {V}", "From {DL}, the day before the deposit: \"Cabinets are already on order, arriving in 3 wks. Need the deposit to lock in install date.\""),
            E(.document, 3, "Supplier Records", "Carolina Cabinet Supply's records show no order for {VL}'s address, and that {BIZ}'s credit account had been closed for nonpayment two months earlier.", .search),
            E(.document, 2, "Business Bank Records", "{VL}'s $14,500 was deposited and, within six days, $9,200 went to another homeowner's countertop installer, $3,100 to {DL}'s truck payment and payroll, and the rest to overdue fees.", .search),
            E(.document, 1, "Pattern of Complaints", "Five other homeowners filed complaints with the Attorney General's consumer protection division describing similar deposits and delays.")
        ],
        defenseEvidence: [
            E(.document, 2, "Completed Jobs", "{BIZ} finished 41 remodels in the four years before the collapse, with no complaints on file before this year."),
            E(.document, 2, "Supplier Bankruptcy", "{DL}'s main cabinet supplier, Tidewater Millwork, filed Chapter 7 bankruptcy, taking $22,000 in {BIZ}'s prepaid orders with it."),
            E(.document, 2, "Partial Refund", "{DL} refunded $4,000 to {V} before charges were filed and signed a repayment agreement for the rest.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"{DL} told me the cabinets were already ordered. That's why I paid.\""],
                        cross: ["\"{DL} did give me back four thousand dollars.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("How did you choose {BIZ}?", "\"My sister-in-law had a kitchen done by them two years ago and it was beautiful. {DL} came out, measured, was friendly and knew the work. The bid was fair.\""),
                            .direct("What made you pay the deposit when you did?", "\"I'd been holding off because I wanted a start date in writing. Then {DL} texted that the cabinets were already on order and arriving in three weeks, and the deposit was needed to lock in the install. If they were already ordered, I figured I'd better pay.\""),
                            .direct("What happened after you paid?", "\"Three weeks went by. Then five. {DL} said the truck was delayed, then the color was backordered. After two months {DL} stopped answering. I called the cabinet company myself. They'd never heard of my order.\""),
                            .direct("Did you get anything for your money?", "\"Demolition. They tore out my old kitchen in a day. We cooked on a hot plate in the dining room for seven months.\""),
                            .cross("{DL} refunded you four thousand dollars before anyone filed charges?", "\"Yes, in two payments. I'm still out ten and a half.\""),
                            .cross("And {DL}'s crew did the demolition, which you'd have paid for anyway?", "\"About two days of work. Not fourteen thousand dollars of it.\""),
                            .cross("When you met {DL} at the house, did {D.he} seem like someone planning to cheat you?", "\"No. That's what hurts. I believed {DL}.\"")
                        ]),
            WitnessSeed(name: nil, role: "Investigator, Attorney General's Consumer Protection Division",
                        direct: ["\"The deposits paid for older jobs and overhead.\""],
                        cross: ["\"The business had a real track record before this year.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did your investigation find?", "\"Six homeowners paid {BIZ} a total of sixty-one thousand dollars in deposits over five months. Not one deposit was used to buy materials for the job it was paid for. Each new deposit paid for the last customer's overdue job, payroll, and bills.\""),
                            .direct("When was {DL} on notice the business was failing?", "\"The cabinet supplier closed the credit account two months before, for nonpayment. The text to {VL} saying the cabinets were 'already on order' came after that.\""),
                            .direct("So at the time of that text, could {DL} have ordered cabinets on credit?", "\"No. The account was closed. To order, {DL} would have had to pay cash up front, and the business account was overdrawn that week.\""),
                            .cross("{BIZ} completed forty-one jobs in four years without a single complaint?", "\"That's correct. This was a business that worked, until it didn't.\""),
                            .cross("Tidewater Millwork's bankruptcy cost {DL} twenty-two thousand dollars in prepaid orders?", "\"It did. That's when the trouble started.\""),
                            .cross("Using new deposits to finish old jobs is bad business. Is it always a crime?", "\"Not always. What makes it fraud is a false statement to get the money. Here, the cabinets.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s former office manager",
                        direct: ["\"{DL} was trying to finish everyone's job.\""],
                        cross: ["\"I don't know if the cabinets were ordered.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you do at {BIZ}?", "\"Scheduling, billing, ordering. I was there six years until it closed.\""),
                            .direct("What happened after the supplier went bankrupt?", "\"Everything fell apart. We'd prepaid for six kitchens with Tidewater. That money was just gone. {DL} took out a second mortgage to keep the crew paid. {DL} wasn't sleeping.\""),
                            .direct("Was {DL} trying to take people's money and run?", "\"No. {DL} was trying to finish everyone's job, one at a time, with whatever came in. It was a terrible way to do it. But {DL} didn't go anywhere. {DL} still lives in the same house.\""),
                            .cross("You handled the ordering. Did you order cabinets for {VL}'s kitchen?", "\"No. By then I wasn't placing any orders; we didn't have credit anywhere.\""),
                            .cross("So when {DL} texted that the cabinets were on order, that wasn't true?", "\"Not from my end. {DL} might have been talking to another supplier. I don't know.\"")
                        ])
        ],
        prosecutionTheory: ["{D} knew {BIZ} had no credit to order cabinets and texted {V} that they were already ordered anyway, to get $14,500. That's obtaining property by false pretenses."],
        defenseTheory: ["A real business with a real track record, wrecked by a supplier's bankruptcy. {DL} juggled deposits trying to save it and failed. That's a breach of contract, not a crime."],
        aggravating: ["The offense was part of a pattern affecting six households"],
        mitigating: ["{DL} made partial restitution before charges were filed", "{DL} had operated a legitimate business for years", "No prior criminal record"],
        victimImpacts: ["{V}: \"It wasn't just the money. It was seven months of hot plates and paper plates, and feeling stupid for trusting somebody.\""],
        allocutions: ["\"I lied about those cabinets because I believed I'd have the money to order them in a week. I didn't. Every one of those families deserves to be paid back, and I'll do it if I'm allowed to work.\""],
        guiltyTruths: ["A seventh homeowner came forward after trial with a nearly identical text, sent the same week."],
        innocentTruths: ["Phone records produced later showed {DL} had called a second supplier the morning of the text and been promised cabinets on credit, a promise that fell through."],
        moods: [.wantsConviction, .divided], doctrines: ["burdenOfProof"],
        extras: ["BIZ": ["Heritage Kitchen & Bath", "Pinecrest Remodeling", "Blue Ridge Home Renovations"]],
        story: StoryExtras(
            timeline: [(-60, "Carolina Cabinet Supply closes {BIZ}'s credit account for nonpayment."),
                       (-1, "{DL} texts {V}: cabinets 'already on order, arriving in 3 wks.'"),
                       (0, "{V} pays a $14,500 deposit."),
                       (90, "{V} learns no cabinets were ordered and files a complaint with the Attorney General."),
                       (130, "Consumer Protection Division completes review of {BIZ}'s bank records."),
                       (150, "{DL} charged with obtaining property by false pretenses.")],
            howIdentified: "{DL} owned {BIZ} and personally sent the text to {V}.",
            notDone: ["{DL}'s phone records for the day of the text were never obtained.", "Only one of the six deposits was charged."],
            defendantExam: [
                .direct("Why did you text {V} that the cabinets were on order?", "\"Because that morning a supplier in Greensboro told me they'd open an account for me. I thought I'd place the order that afternoon. It fell through two days later. I should have told {VL}, and I didn't.\""),
                .direct("Where did {VL}'s money go?", "\"To finish the Hendersons' countertops, which were three months overdue, and to make payroll. I was trying to keep the crew so I could finish everybody.\""),
                .direct("Did you intend to cheat {V}?", "\"No. I intended to do that kitchen. I've done forty-one of them. I took out a second mortgage trying to save the business.\""),
                .cross("Your Carolina Cabinet account had been closed for two months. You knew that.", "\"I knew that account was closed. I thought I had another one coming.\""),
                .cross("You never mentioned a Greensboro supplier to investigators. Not once.", "\"Nobody asked me. My lawyer told me not to talk.\""),
                .cross("Six families paid you deposits after your credit was gone.", "\"Yes. I believed I could get out of the hole. I was wrong.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"How many other families did this happen to?\"",
                                  answer: "\"Five others. I found them on a Facebook group.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Other bad acts (Rule 404(b))", shouldSustain: false,
                                  explanation: "The other deposits are admissible to show intent and a common plan under Rule 404(b), the central issue in a false pretenses case. They can't be used just to show bad character.",
                                  doctrineID: "priorActs", weight: 2))
            ],
            prosecutionOpening: "One text: 'Cabinets are already on order.' It wasn't true, {D} knew the account was closed, and {V} paid $14,500 because of it.",
            defenseOpening: "Forty-one finished kitchens. A supplier bankruptcy. A second mortgage. {DL} made promises {D.he} couldn't keep, but believed {D.he} could. Broken promises are for civil court.",
            prosecutionClosing: "Intent is judged at the moment of the lie. {DL} knew there was no account, said the cabinets were ordered, and took the money for something else.",
            defenseClosing: "If {DL} believed another supplier would come through, that text wasn't a knowing lie. The State never pulled the phone records that would have settled it.",
            victim: VictimFacts(relationship: "A customer of the defendant's remodeling company.", harm: ["No physical injury. Paid a $14,500 deposit for cabinets that were never ordered."], restitution: 14500, restitutionBasis: "her $14,500 deposit")
        )
    )

    // MARK: - 9. A shot at the fishing cabin

    static let fishingCabin = CaseTemplate(
        key: "story.fishingCabin", category: .violent,
        headlines: ["Business Partner Shot Dead at {LAKE} Cabin", "Accident or Murder at the Lake?"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 5, lesserThreshold: 3,
        specification: "Killed {V} with a shotgun, with malice, premeditation, and deliberation.",
        secondary: [
            SecondaryCharge(lawID: "insuranceFraud", specification: "Presented a claim on the $500,000 partnership life insurance policy on {V}, knowing it contained false statements about how {VL} died.", chance: 1.0, threshold: 4)
        ],
        ageRange: 38...60, occupations: ["co-owner of a marine supply business"], hasVictim: true,
        summaries: [
            "{D} and {V} owned {SHOP} together for eleven years. On {DATE}, during a cold snap, the two drove to {VL}'s cabin on {LAKE} to hunt ducks. At about {TIME}, {DL} called 911 to say the shotgun had gone off while {D.he} was unloading it on the porch and {VL} was dead. The medical examiner says the shot was fired from about four feet away. Three weeks earlier, {VL} had told a lawyer {V.he} wanted to force {DL} out of the business, and the company held a $500,000 life insurance policy on each partner payable to the other."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Autopsy and Wound Analysis", "A single 12-gauge wound to the left chest. Shot pattern spread of about 3 inches puts the muzzle roughly 3 to 5 feet away, level or slightly downward. Death within a minute."),
            E(.document, 3, "Buy-Sell Insurance Policy", "A $500,000 policy on each partner, payable to the surviving partner, purchased six years earlier. {DL} called the insurer to ask about the claim process four days after the death."),
            E(.document, 2, "Attorney's Notes", "{VL}'s business lawyer's notes from three weeks before: \"Wants out of partnership or wants {DL} out. Suspects {DL} of skimming from the parts account. Will raise at the quarterly meeting.\" The meeting was set for the Monday after the trip."),
            E(.statement, 2, "Statement to Deputies", "{DL}: \"I was unloading on the porch, the shell stuck, I was working the slide and it went off. {VL} was right there by the door.\"")
        ],
        defenseEvidence: [
            E(.forensic, 3, "Firearm Examination", "The State Crime Laboratory found the shotgun's trigger pull light at 2.1 pounds and noted wear on the sear consistent with an older gun that can fire if jarred while the action is partly closed."),
            E(.document, 2, "Nineteen Years of Hunting Trips", "Photos and guest books from the cabin show the two partners hunting together every season for nineteen years."),
            E(.document, 2, "Business Audit", "An outside accountant hired by the estate found $11,400 in parts orders that couldn't be matched, but couldn't attribute them to either partner.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Lead investigator, Sheriff's Office",
                        direct: ["\"The story of a stuck shell doesn't fit the distance or the angle.\""],
                        cross: ["\"The lab found the gun could fire if jarred.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find at the cabin?", "\"{VL} was on the porch floor just outside the door, on {V.his} back, wearing waders and a camouflage jacket. The shotgun was on a bench by the steps. A box of shells was on the rail. {DL} was sitting in the truck with the door open, hands shaking.\""),
                            .direct("What did {DL} say happened?", "\"That a shell jammed while {DL} was unloading, and while {D.he} worked the slide it fired. {DL} said {VL} was 'right there by the door.'\""),
                            .direct("Does that fit what you found?", "\"Not well. The medical examiner puts the muzzle three to five feet from {VL}, level with the chest. Someone clearing a jam usually points the barrel down or away. For it to hit {VL} that way, the gun had to be up and pointed across the porch.\""),
                            .direct("What did you learn about the business?", "\"{VL} had met with a lawyer three weeks earlier about forcing {DL} out, and suspected skimming. There was a meeting set for the Monday after the trip. And four days after the death, {DL} called the insurance company about the half-million-dollar policy.\""),
                            .cross("The lab found the gun's trigger was light and could fire if jarred while partly closed?", "\"That's what the report says.\""),
                            .cross("You've cleared a jammed pump shotgun yourself?", "\"More times than I can count. Every qualification, and once in a duck blind.\""),
                            .cross("In a hurry, cold, wearing gloves, a person might hold it up at chest level to see the jam?", "\"Some people might. It's not how I was taught.\""),
                            .cross("You have no evidence {DL} knew about the lawyer meeting?", "\"Nothing direct. The meeting was on the shared office calendar.\""),
                            .cross("Calling about a policy is something every surviving partner does eventually, isn't it?", "\"Eventually. Four days is quick.\"")
                        ]),
            WitnessSeed(name: nil, role: "Medical examiner",
                        direct: ["\"The muzzle was about three to five feet from the chest.\""],
                        cross: ["\"The wound can't tell me whether the trigger was pulled on purpose.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did the autopsy show?", "\"A single shotgun wound to the left chest, with pellets through the heart and left lung. Death within a minute or so.\""),
                            .direct("How do you estimate distance?", "\"From the spread of the shot. At contact, the wound is one round hole. As distance grows the pellets spread. Here the pattern was about three inches across, which in test firing with that gun and those shells corresponds to roughly three to five feet.\""),
                            .direct("And the angle?", "\"Level to slightly downward, front to back. The gun was at about chest height.\""),
                            .cross("You can't tell the court whether the trigger was pulled deliberately?", "\"No. A wound records distance and direction. Not intent.\""),
                            .cross("If someone holding the gun at chest height to look at a jammed shell were three or four feet from {VL}, this wound would result?", "\"Yes. The wound is consistent with that, and with an intentional shot.\"")
                        ]),
            WitnessSeed(name: nil, role: "{VL}'s business lawyer",
                        direct: ["\"{VL} wanted {DL} out of the business.\""],
                        cross: ["\"{VL} said {V.he} wasn't sure about the skimming.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("Why did {VL} come to see you?", "\"To talk about getting out of the partnership, or buying {DL} out. {VL} thought money was missing from the parts account and wanted to bring it up at the quarterly meeting.\""),
                            .direct("What was {VL}'s state of mind?", "\"Upset. {VL} said, 'Eleven years, and I think {DL}'s stealing from me.' {VL} was also afraid to say it out loud.\""),
                            .cross("{VL} told you {V.he} wasn't sure about the skimming?", "\"{VL} said 'I could be wrong, I hope I'm wrong.'\""),
                            .cross("Did {VL} ever say {V.he} was afraid of {DL}?", "\"No. Afraid of the conversation, not of {DL}.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Retired gunsmith",
                        direct: ["\"That shotgun could fire while you were clearing a jam.\""],
                        cross: ["\"Someone still has to have a finger near the trigger.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your experience?", "\"Forty years as a gunsmith in {HOOD}. I've repaired thousands of pump shotguns, including this model.\""),
                            .direct("What did you find on this gun?", "\"The sear is worn and the trigger breaks at about two pounds, about half of what it should. If the slide isn't fully closed and you slam it forward with your hand near the grip, it can go off. I've seen it happen on three guns of this model.\""),
                            .direct("Would a person clearing a jam hold it at chest height?", "\"In the cold with gloves on, trying to see the shell? Sure. You tip it up to look in the ejection port. People do it all the time. It's why I tell them never to do it pointed at anybody.\""),
                            .cross("For it to fire, something has to touch the trigger?", "\"With a sear this worn, a glove brushing it could do it. But yes, something touches the trigger.\""),
                            .cross("You've been paid for your examination?", "\"Four hundred dollars. I'd have said the same for free.\"")
                        ])
        ],
        prosecutionTheory: ["{VL} was about to accuse {DL} of stealing and force {D.him} out. {D} took {VL} to a cabin far from anyone, shot {V.him} from four feet away, and called it an accident."],
        defenseTheory: ["Two friends of nineteen years, a worn-out shotgun with a hair trigger, a jammed shell on a cold morning. This is the worst day of {DL}'s life, not a murder."],
        aggravating: ["The offense was committed for pecuniary gain"],
        mitigating: ["{DL} called 911 immediately and stayed with {VL}", "No prior criminal record"],
        victimImpacts: ["{VL}'s son: \"I grew up calling {DL} my uncle. I don't know what to believe. I just want the truth.\""],
        allocutions: ["\"I've hunted with {VL} since we were in our twenties. I'd give anything to have that morning back. I didn't do this on purpose.\""],
        guiltyTruths: ["{DL}'s second phone, found later in the shop, held a search from the night before the trip: \"shotgun accident what happens legally.\""],
        innocentTruths: ["The same shotgun fired by itself on a sheriff's office test range a year later when the slide was closed hard, a finger nowhere near the trigger."],
        moods: [.divided], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["TIME": ["7:14 a.m."], "LAKE": ["Lake Hollis", "Sutton Lake", "Black Creek Reservoir"],
                 "SHOP": ["Tidewater Marine Supply", "Harbor Point Outboard", "Riverbend Boat & Motor"]],
        story: StoryExtras(
            timeline: [(-21, "{VL} meets with a business lawyer about leaving or dissolving the partnership."),
                       (0, "7:14 a.m.: {DL} calls 911 from the cabin. Deputies arrive at 7:41 a.m."),
                       (1, "Autopsy performed; shotgun and shells sent to the State Crime Laboratory."),
                       (4, "{DL} calls the insurer about the buy-sell policy."),
                       (33, "Laboratory test-fires the shotgun and reports the light trigger pull and worn sear."),
                       (47, "{DL} charged with first-degree murder.")],
            howIdentified: "{DL} was the only other person at the cabin and reported the shooting.",
            notDone: ["The porch was not measured to reconstruct where each partner stood.", "The parts-account shortfall was never traced to either partner."],
            defendantExam: [
                .direct("What happened that morning?", "\"We'd hunted the dawn flight and come back up for coffee. I was unloading on the porch. The last shell hung up. I tipped the gun up to look in the port and worked the slide, and it went off. {VL} was coming out the door.\""),
                .direct("Did you know about the lawyer?", "\"No. I knew {VL} was unhappy about the parts account. We'd argued about it. I didn't know {VL} had gone to a lawyer.\""),
                .direct("Did you take money from the business?", "\"No. Parts orders get messed up in that system all the time. I'd have opened every book I had.\""),
                .direct("Why call the insurance company four days later?", "\"Because the bank called me. The business couldn't make payroll without {VL}. I didn't want the money. I needed to keep twelve people employed.\""),
                .cross("You've hunted for thirty years. You know never to point a gun at a person.", "\"I know it. I wasn't pointing it at {VL}. I didn't know {VL} was coming out the door.\""),
                .cross("Your finger was on the trigger.", "\"I don't think it was. I had gloves on. I don't know.\""),
                .cross("The Monday meeting was on the shared calendar. You saw it.", "\"I saw a quarterly meeting. We have one every quarter.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Prosecutor: \"What did {VL} tell you {DL} was doing with the money?\"",
                                  answer: "\"{VL} said, 'I think {DL}'s stealing from me.'\"",
                                  raisedBy: .defense, onCross: false, grounds: "Hearsay", shouldSustain: false,
                                  explanation: "Offered to show {VL}'s state of mind and plan to confront {DL}, which bears on motive. It is admissible for that purpose under Rule 803(3), not to prove {DL} actually stole.",
                                  doctrineID: "hearsayExceptions", weight: 2))
            ],
            prosecutionOpening: "A partnership about to end, an accusation coming on Monday, a half-million-dollar policy, and a shot from four feet at chest height. The State will prove {D} killed {V} on purpose.",
            defenseOpening: "Nineteen years of hunting together. A gun with a hair trigger the State's own lab confirmed. {DL} called 911 within a minute and tried to stop the bleeding. This was a terrible accident.",
            prosecutionClosing: "Premeditation can form in moments. But this was planned: the cabin, the timing before Monday, the gun at chest level. That's first-degree murder.",
            defenseClosing: "The medical examiner can't tell you intent. The gunsmith and the lab say this gun could fire on its own. That's reasonable doubt about murder of any degree.",
            when: .months([11, 12, 1]),
            genders: ["D": .male],
            victim: VictimFacts(occupation: "Business owner", relationship: "The defendant's business partner of eleven years."),
            yearsAtJob: 11,
            scene: "the porch of {VL}'s cabin on Sutton Lake"
        )
    )

    // MARK: - 10. Masks at the door

    static let homeInvasion = CaseTemplate(
        key: "story.homeInvasion", category: .robbery,
        headlines: ["Couple Tied Up in {HOOD} Home Invasion", "Accomplice Points Finger at Former Friend"],
        primaryLaw: "dangerousRobbery", lesserLaw: "commonLawRobbery", threshold: 6, lesserThreshold: 4,
        specification: "With another person, robbed {V} in {V.his} home while armed with a handgun.",
        secondary: [
            SecondaryCharge(lawID: "dangerousRobbery", specification: "With another person, robbed {V}'s spouse in their home while armed with a handgun.", chance: 1.0, threshold: 6),
            SecondaryCharge(lawID: "kidnapping2", specification: "Restrained {V} by binding {V.his} wrists with zip ties to facilitate the robbery.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "kidnapping2", specification: "Restrained {V}'s spouse by binding their wrists with zip ties to facilitate the robbery.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "conspiracyRobbery", specification: "Agreed with {ALT} to rob {V} with a dangerous weapon.", chance: 1.0, threshold: 5),
            SecondaryCharge(lawID: "feloniousBE", specification: "Broke and entered the dwelling of {V} with intent to commit robbery therein.", chance: 1.0, threshold: 5)
        ],
        ageRange: 20...33, forcedPriorOffenses: ["Misdemeanor Larceny", "Breaking or Entering@9"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, two masked people forced their way into the home of {V}, 67, and {V.his} spouse on {STREET} in {HOOD}, held them at gunpoint, zip-tied their wrists, and took a gun safe's contents, jewelry, and $3,000 in cash. Two weeks later police arrested {ALT}, who sold one of the stolen rifles. {ALT} agreed to testify in exchange for a reduced charge and named {D} as the partner who carried the handgun. {DL} says {ALT} is protecting the real accomplice."
        ],
        prosecutionEvidence: [
            E(.statement, 3, "Accomplice Testimony Agreement", "{ALT} pleaded guilty to common law robbery, with the State recommending 20 months instead of the 64-plus months {ALT.he} faced, in exchange for truthful testimony against {DL}."),
            E(.digital, 3, "Cell-Site Records", "{DL}'s phone connected to the tower nearest the {STREET} home between 1:40 and 2:30 a.m., then went silent for 50 minutes.", .search),
            E(.physical, 2, "Zip Ties", "A bag of the same brand and color of zip ties was found in {DL}'s car trunk.", .search),
            E(.document, 1, "Victim's Description", "{V} described the gunman as \"slim, about six feet, with a deep voice.\" {DL} is 5'11\" and 160 pounds.")
        ],
        defenseEvidence: [
            E(.document, 3, "Accomplice's Text", "Two days after the robbery, {ALT} texted a cousin: \"me and {COUSIN} hit a lick, dont say nothing.\" {COUSIN} is not {DL}."),
            E(.document, 2, "Cell Tower Coverage Map", "The same tower serves {DL}'s girlfriend's apartment, where {D.he} says {D.he} spent the night, 1.1 miles from the home."),
            E(.physical, 1, "No Stolen Property", "A search of {DL}'s apartment and car found none of the stolen jewelry, guns, or cash.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"The one with the handgun did the talking.\""],
                        cross: ["\"I never saw a face.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened that night?", "\"The doorbell rang twice around a quarter to two. I thought it was a neighbor in trouble. When I opened the door, two people in masks pushed in. One had a pistol right against my chest.\""),
                            .direct("What did they do?", "\"Made us lie face down on the living room floor. The one with the pistol zip-tied our hands while the other one went through the house. The one with the gun kept asking where the safe key was. Deep voice. Calm. That was the worst part, how calm.\""),
                            .direct("What did they take?", "\"Everything in the gun safe, four rifles and two shotguns, my late mother's rings, and three thousand in cash we kept for emergencies.\""),
                            .direct("How long were they there?", "\"Twenty-five minutes, maybe. After they left it took us another twenty to get loose and call.\""),
                            .cross("You never saw either person's face?", "\"No. Ski masks, gloves, dark clothes.\""),
                            .cross("'Slim, about six feet, deep voice' describes a lot of young men in this county?", "\"I suppose it does.\""),
                            .cross("You couldn't recognize {DL}'s voice today if you heard it?", "\"I don't know. I'd be afraid of getting it wrong.\"")
                        ]),
            WitnessSeed(name: "{ALT}", role: "Co-defendant testifying for the State",
                        direct: ["\"{DL} had the gun. I went through the house.\""],
                        cross: ["\"I got a deal. Twenty months instead of five years.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How do you know {DL}?", "\"We came up together. Same block, same school. We were tight until all this.\""),
                            .direct("Whose idea was the robbery?", "\"Mine, honestly. I'd done some yard work for them and saw the gun safe. I told {DL} about it and {D.he} said 'say less.'\""),
                            .direct("What did each of you do?", "\"{DL} had the pistol and did the talking. I went through the bedrooms and the safe. {DL} zip-tied them. We split the cash, fifteen hundred each, and I took the guns to sell.\""),
                            .direct("Why are you testifying?", "\"Because I got caught, and because I'm done. I'm not going to lie for anybody.\""),
                            .cross("Your deal takes you from more than five years to twenty months?", "\"Twenty months. My lawyer explained it to me twice.\""),
                            .cross("Two days after the robbery you texted your cousin 'me and {COUSIN} hit a lick.' Who is {COUSIN}?", "\"A friend. I was trying to keep {DL}'s name out of my phone.\""),
                            .cross("{COUSIN} is about six feet with a deep voice, isn't that right?", "\"I guess so. A lot of people are.\""),
                            .cross("You'd say whatever got you the best deal, wouldn't you?", "\"The deal says I have to tell the truth. That's what I'm doing.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Robbery detective",
                        direct: ["\"{DL}'s phone was near the home during the robbery.\""],
                        cross: ["\"The tower also covers where {DL} says {D.he} was.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("How did you identify {ALT}?", "\"One of the stolen rifles turned up in a pawn database, sold by {ALT} under {ALT.his} own name. We arrested {ALT} the next day.\""),
                            .direct("How did {DL} come into it?", "\"{ALT} named {DL} after agreeing to cooperate. I then got {DL}'s phone records by warrant and searched {D.his} car.\""),
                            .direct("What did the phone records show?", "\"{DL}'s phone was on the tower nearest the home from 1:40 to 2:30 a.m., then no activity for 50 minutes, which is unusual for that phone. Normally it's busy all night.\""),
                            .cross("That tower also covers the apartment where {DL} says {D.he} slept?", "\"It covers a mile and a half in every direction. That apartment's inside it.\""),
                            .cross("You never got a warrant for {COUSIN}'s phone?", "\"No. We had a cooperating witness naming {DL}.\""),
                            .cross("Zip ties of that brand are sold at every hardware store in the county?", "\"They're common.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s girlfriend",
                        direct: ["\"{DL} was asleep next to me.\""],
                        cross: ["\"I was asleep too.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Where was {DL} that night?", "\"At my apartment. We got takeout around nine, watched a show, and went to bed around midnight. {DL} was there when I got up for work at six.\""),
                            .direct("Why would {DL}'s phone go quiet?", "\"Because {DL} was asleep. {DL} games on that phone half the night when {D.he} can't sleep. That night {DL} slept.\""),
                            .cross("You were asleep from midnight to six?", "\"Out cold. I work a five a.m. shift.\""),
                            .cross("So you can't say whether {DL} left between 1:30 and 3?", "\"I'd have felt the bed. I'm a light sleeper.\""),
                            .cross("You love {DL} and don't want {D.him} to go to prison?", "\"Yes. That doesn't make me a liar.\"")
                        ])
        ],
        prosecutionTheory: ["{D} held a pistol on a retired couple in their own living room while {ALT} emptied the safe. The accomplice, the phone, and the zip ties all point to {DL}."],
        defenseTheory: ["The State's case is a co-defendant who sold stolen rifles under {ALT}'s own name and bought four years off by naming {DL}, after texting that someone else was the partner."],
        aggravating: ["The victims were elderly and restrained in their own home"],
        mitigating: ["{DL} has no prior violent convictions"],
        victimImpacts: ["{V}: \"We sold the house. My spouse can't sleep there. Every doorbell, we both jump.\""],
        allocutions: ["\"I'm sorry for what happened to those people. I'm not the one who did it.\""],
        guiltyTruths: ["One of the stolen rings turned up a year later with {DL}'s sister, who said {D.he} gave it to her."],
        innocentTruths: ["{COUSIN} was arrested for another home invasion months later and confessed to this one, with {ALT}."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["TIME": ["1:45 a.m."], "COUSIN": ["\"Peanut\"", "\"Tank\"", "\"Lil Dre\""]],
        story: StoryExtras(
            timeline: [(0, "1:45 a.m.: home invasion. Victims free themselves and call 911 at 2:31 a.m."),
                       (13, "Stolen rifle flagged in pawn database, sold by {ALT}."),
                       (14, "{ALT} arrested; interviewed; agrees to cooperate and names {DL}."),
                       (17, "Search warrant for {DL}'s car: zip ties recovered. Phone records requested."),
                       (40, "{ALT} pleads guilty to common law robbery under a cooperation agreement.")],
            howIdentified: "{DL} was named by the co-defendant, {ALT}, after {ALT.he} agreed to cooperate.",
            notDone: ["{COUSIN}, named in {ALT}'s own text message, was never identified or interviewed.", "No DNA testing of the zip ties left on the victims."],
            defendantExam: [
                .direct("Where were you that night?", "\"At my girlfriend's place, all night. We ate, watched TV, went to bed. I didn't go anywhere.\""),
                .direct("Why would {ALT} name you?", "\"Because {ALT} needed a name the cops would believe, and we grew up together. If {ALT} names the real partner, that person comes after {ALT.him}. I'm the safe name.\""),
                .direct("What about the zip ties in your car?", "\"I work landscaping on weekends. We use them on every job, for tarps and plants. Half the trucks at the yard have that same bag.\""),
                .cross("{ALT} told you about the gun safe weeks before.", "\"{ALT} told a lot of people about a lot of things. I didn't go.\""),
                .cross("Your phone, busy every other night, went silent for fifty minutes at 2 a.m.", "\"I was asleep. It's allowed.\""),
                .cross("You have a felony breaking-and-entering conviction.", "\"Years ago. An empty storage unit. I did my probation and I haven't been in trouble since.\""),
                .cross("You're six feet, slim, with a deep voice.", "\"So is {COUSIN}. Ask {ALT} who that is.\"")
            ],
            objections: [
                (1, ObjectionSeed(question: "Defense attorney: \"Isn't it true you've lied to police before, in your 2019 larceny case?\"",
                                  answer: "\"I said I found the bike. That was a lie.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Improper impeachment", shouldSustain: false,
                                  explanation: "Specific instances of untruthfulness may be inquired into on cross to attack credibility (Rule 608(b)). It's especially relevant for an accomplice testifying under a plea deal.",
                                  doctrineID: "characterEvidence", weight: -1))
            ],
            prosecutionOpening: "A pistol against a 67-year-old's chest, zip ties on two people face-down in their own living room. The person who planned it is telling you who held the gun: {D}.",
            defenseOpening: "The State's case rides on {ALT}, who got years off a prison term for naming somebody, and who texted that the partner was {COUSIN}. Nobody ever looked for {COUSIN}.",
            prosecutionClosing: "Accomplice testimony is scrutinized, and here it's corroborated: the phone near the house, the silence during the robbery, the zip ties in the trunk.",
            defenseClosing: "The court should view a bargained-for accomplice with great caution. Strip away {ALT}, and the State has a cell tower that covers {DL}'s bed and zip ties from a hardware store.",
            victim: VictimFacts(relationship: "Strangers before the robbery.", harm: ["No physical injury. Held at gunpoint with his wrists zip-tied, alongside his spouse."]),
            alibiCheck: AlibiCheck(holds: AlibiCheck.Finding(title: "Apartment Entrance Camera", detail: "The camera over the only entrance to the girlfriend's building shows {DL} going in with a takeout bag at 9:06 p.m. and not coming out again until 6:20 the next morning.", kind: .video),
                                   breaks: AlibiCheck.Finding(title: "Apartment Entrance Camera", detail: "The camera over the girlfriend's building entrance shows {DL} walking out at 12:58 a.m. in a dark hooded jacket and coming back in at 3:41 a.m., carrying a duffel bag.", kind: .video))
        )
    )

    // MARK: - 11. The protective order

    static let protectiveOrder = CaseTemplate(
        key: "story.protectiveOrder", category: .violent,
        headlines: ["Ex-Partner Cut During Visit Under Protective Order", "A Box Cutter and Two Stories"],
        primaryLaw: "awdwisi", lesserLaw: "awdw", threshold: 4, lesserThreshold: 2,
        specification: "Assaulted {V} with a box cutter, a deadly weapon, inflicting serious injury, while a domestic violence protective order was in effect.",
        secondary: [
            SecondaryCharge(lawID: "dvpoViolation", specification: "Knowingly violated a domestic violence protective order by going to {V}'s apartment without arrangement.", chance: 1.0, threshold: 2)
        ],
        ageRange: 25...44, forcedPriorOffenses: ["Simple Assault@1"], hasVictim: true,
        summaries: [
            "{V} held a domestic violence protective order against {D}, the other parent of their eight-year-old, that barred contact except for exchanges arranged through a relative. On {DATE}, {DL} came to {VL}'s apartment on {STREET} unannounced at about {TIME} to pick up the child's medicine and school clothes. Minutes later {VL} called 911 with a deep cut across the forearm that took nineteen stitches and nerve repair. {VL} says {DL} pulled a box cutter. {DL} says {VL} grabbed the box cutter off the counter and {DL} was cut too trying to take it away."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Protective Order", "A one-year domestic violence protective order entered seven months earlier after {VL} testified {DL} had pushed {VL} into a wall; {DL} later pleaded guilty to simple assault for that incident. It barred {DL} from {VL}'s residence."),
            E(.forensic, 3, "Hand Surgeon's Records", "A 9-centimeter laceration across the left forearm with a partial tendon cut and nerve damage; surgical repair; permanent numbness in two fingers."),
            E(.statement, 2, "911 Call", "{V}: \"{DL} cut me, {D.he} has a box cutter, my kid's here, please hurry.\""),
            E(.physical, 1, "Box Cutter", "A yellow box cutter found on the kitchen floor. {DL}'s and {VL}'s fingerprints are both on it.", .search)
        ],
        defenseEvidence: [
            E(.physical, 2, "Defendant's Hand Wound", "{DL} had a 3-centimeter cut across the right palm, treated at urgent care that night, consistent with grabbing a blade."),
            E(.document, 2, "Child's Statement", "The child told a forensic interviewer that {VL} \"picked up the cutter thing because of being mad and then they were fighting over it.\""),
            E(.document, 1, "Text Messages", "That afternoon {VL} texted {DL}: \"come get her stuff yourself, I'm not driving it over again.\"")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Protected party",
                        direct: ["\"{DL} pulled the box cutter out of a pocket.\""],
                        cross: ["\"I did text {DL} to come get the stuff.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why did you have a protective order?", "\"Last spring {DL} shoved me into a wall during an argument in front of our daughter. I went to court and got the order. I didn't want our daughter growing up like that.\""),
                            .direct("What happened that evening?", "\"I heard knocking, and it was {DL}. I told {DL} through the door I'd call the police. {DL} said just give me the medicine and the clothes. I opened the door a few inches and {DL} pushed it open.\""),
                            .direct("Then what?", "\"We argued in the kitchen. I was opening a box from the pharmacy with the cutter and I put it down. {DL} picked it up and I grabbed {D.his} wrist and then my arm was open. There was blood everywhere.\""),
                            .direct("How has the injury affected you?", "\"I've got two fingers that don't feel anything. I do hair for a living. I'm still learning to hold the shears.\""),
                            .cross("You texted {DL} that afternoon to come get the things in person.", "\"I said come get them. I meant through my sister like the order says.\""),
                            .cross("Earlier you told the deputy {DL} pulled the box cutter from a pocket. Today you said it was yours, from the counter.", "\"It was mine. I was confused that night. I'd lost a lot of blood.\""),
                            .cross("You grabbed for the blade first?", "\"I grabbed {DL}'s wrist. I don't know who had what.\""),
                            .cross("Your daughter told the interviewer you picked it up because you were mad.", "\"She's eight. She was scared. I had it in my hand earlier, opening the box.\"")
                        ]),
            WitnessSeed(name: "{OFF}", role: "Responding officer",
                        direct: ["\"There was a protective order and {DL} was inside the residence.\""],
                        cross: ["\"{DL} had a fresh cut on the palm.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did you find?", "\"{VL} in the kitchen with a towel around the arm, soaked through. The child in a back bedroom crying. {DL} standing in the hall with a bloody hand, saying 'it was an accident, it was an accident.'\""),
                            .direct("What did {VL} tell you?", "\"That {DL} pulled a box cutter out of a pocket during an argument and cut {VL}. That's what's in my report.\""),
                            .direct("What did you confirm about the protective order?", "\"It was active and served. {DL} was inside the protected residence, a violation on its own.\""),
                            .cross("{DL} had a fresh cut across the palm?", "\"Yes. Bleeding. I had EMS look at it.\""),
                            .cross("A palm cut like that is what you see when someone grabs a blade, isn't it?", "\"It can be.\""),
                            .cross("{DL} stayed and waited for you?", "\"Yes. Didn't try to leave.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Child forensic interviewer",
                        direct: ["\"The child said {VL} picked up the cutter.\""],
                        cross: ["\"Children's accounts of fast, frightening events can be incomplete.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your role?", "\"I'm a forensic interviewer at the county's child advocacy center. I use a structured, non-leading protocol and the interview is recorded.\""),
                            .direct("What did the child say?", "\"That both parents were yelling, and that {VL} 'picked up the cutter thing, mad, and then they were fighting over it, and then there was blood.'\""),
                            .direct("Was the child coached, in your view?", "\"I saw no signs of coaching. The language was age-appropriate and the account was spontaneous.\""),
                            .cross("The child was in the hallway, partly out of sight of the kitchen?", "\"The child said 'by the door,' which from the photos was partly behind the wall.\""),
                            .cross("An eight-year-old's account of a few frightening seconds can miss things?", "\"It can. I report what was said, not whether it's complete.\"")
                        ])
        ],
        prosecutionTheory: ["{D} violated a protective order, forced the door, and opened {V}'s arm to the tendon with a box cutter in front of their child."],
        defenseTheory: ["{DL} came because {VL} said to come. {VL} picked up the box cutter, as their own child says, and {DL} was cut trying to take it away. Being somewhere you shouldn't isn't the same as attacking someone."],
        aggravating: ["The offense was committed in the presence of a child"],
        mitigating: ["{DL} stayed at the scene until deputies arrived", "{DL} was also injured"],
        victimImpacts: ["{V}: \"I can't do what I used to do for a living. I just want to be safe and for my daughter to be safe.\""],
        allocutions: ["\"I should never have gone to that door, order or no order. I would never cut {VL}. I was trying to get it away from both of us.\""],
        guiltyTruths: ["A neighbor's doorbell camera, recovered later, recorded {DL} saying \"you're going to regret this\" before forcing the door."],
        innocentTruths: ["{VL} later told a counselor {V.he} had picked up the cutter first and swung it when {DL} pushed in."],
        moods: [.divided], doctrines: ["selfDefense", "burdenOfProof"],
        extras: ["TIME": ["6:40 p.m."]],
        story: StoryExtras(
            timeline: [(-210, "Domestic violence protective order entered against {DL}."),
                       (0, "6:40 p.m.: {DL} arrives at {VL}'s apartment. 6:47 p.m.: 911 call. {OFF} arrives at 6:54 p.m."),
                       (0, "{VL} undergoes surgical repair of the forearm. {DL} treated at urgent care for a palm laceration, then arrested."),
                       (3, "Forensic interview of the child at the child advocacy center."),
                       (21, "Latent print report: both parties' prints on the box cutter.")],
            howIdentified: "{DL} was present when officers arrived; both parties described a struggle over the box cutter.",
            notDone: ["The neighbors along the hallway were not canvassed.", "No blood-pattern analysis of the kitchen."],
            defendantExam: [
                .direct("Why did you go to the apartment?", "\"Our daughter needed her inhaler for school and {VL} texted 'come get her stuff yourself.' I knew the order said no. I went anyway. That was wrong.\""),
                .direct("What happened in the kitchen?", "\"We were yelling about the medicine. {VL} picked up the box cutter off the counter and pointed it at me and said get out. I grabbed for it. We were both pulling and it went across {VL}'s arm and my hand.\""),
                .direct("Did you bring a box cutter?", "\"No. It was {VL}'s, from opening the pharmacy box. I've never carried one.\""),
                .cross("You pushed the door open on someone with a protective order against you.", "\"I pushed it when {VL} started to close it. I shouldn't have.\""),
                .cross("You're stronger than {VL}. You could have walked out.", "\"With a blade pointed at me and our daughter down the hall? I didn't think. I grabbed.\""),
                .cross("You were already under an order for putting {VL} into a wall.", "\"Yes. And I've done the classes since. I'm not that person.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Tell the court about the other times {DL} hurt you.\"",
                                  answer: "\"There were times before the wall. A lot of times.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Other bad acts (Rule 404(b))", shouldSustain: true,
                                  explanation: "Vague, unproven prior acts offered to show {DL} is violent are propensity evidence. The protective order itself is already in evidence; unspecific additional acts add prejudice without a proper purpose.",
                                  doctrineID: "priorActs", weight: 1))
            ],
            prosecutionOpening: "A protective order. A forced door. A box cutter, and a forearm laid open to the tendon in front of an eight-year-old. {D} did this.",
            defenseOpening: "{DL} broke the order by coming over, and should answer for that. But the child who saw it says {VL} picked up the box cutter, and {DL}'s own hand was cut grabbing for it.",
            prosecutionClosing: "Even if {VL} touched the cutter first, {DL} wasn't supposed to be in that kitchen at all. The injury and the order tell you who brought the danger.",
            defenseClosing: "Being where you shouldn't be isn't assault with a deadly weapon. The child, the palm wound, and {VL}'s own changed story leave reasonable doubt about who wielded that blade.",
            victim: VictimFacts(relationship: "The defendant's former partner and co-parent of their eight-year-old.", family: "Single, one child, eight years old.")
        )
    )

    // MARK: - 12. After the party

    static let afterTheParty = CaseTemplate(
        key: "story.afterTheParty", category: .violent,
        headlines: ["Rape Charge After Off-Campus Party", "Consent and Memory at Trial"],
        primaryLaw: "rape2", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Engaged in vaginal intercourse with {V}, who was physically helpless and mentally incapacitated by alcohol, when {DL} knew or should reasonably have known of that condition.",
        secondary: [
            SecondaryCharge(lawID: "sexualBattery", specification: "Engaged in sexual contact with {V} while {V.he} was mentally incapacitated and physically helpless.", chance: 1.0, threshold: 8)
        ],
        ageRange: 20...26, occupations: ["college senior and part-time restaurant server"], hasVictim: true,
        summaries: [
            "On {DATE}, {V} and {D}, students at Hollis State University, were both at an off-campus party on {STREET}. Friends say {VL} drank heavily over several hours. At about {TIME}, {DL} and {VL} left together for {DL}'s apartment two blocks away. The next morning {VL} woke there with no memory after the party and went to the hospital, where a sexual assault examination was done. {DL} says {VL} was drunk but awake, talking, and an eager participant. {VL} says {V.he} could not have agreed to anything."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Toxicology Back-Calculation", "{VL}'s blood alcohol at 9:20 a.m. was 0.04. A toxicologist estimates 0.20 to 0.26 at 1:30 a.m., a range associated with blackouts, confusion, and loss of motor control."),
            E(.video, 3, "Party Video", "A guest's phone video at 1:12 a.m. shows {VL} unable to stand without help, eyes half closed, slurring. {DL} is next to {VL}, holding {V.his} waist."),
            E(.statement, 2, "Text from {DL}", "At 9:51 a.m. the next morning, to a friend: \"they were gone last night lol. hope they remember my name\""),
            E(.forensic, 2, "Sexual Assault Examination", "Evidence of recent intercourse; DNA consistent with {DL}. No injuries documented.")
        ],
        defenseEvidence: [
            E(.video, 2, "Building Hallway Camera", "At 1:34 a.m., {VL} walks down {DL}'s apartment hallway under {VL}'s own power, holding {DL}'s hand, and appears to laugh."),
            E(.document, 2, "Late-Night Text", "At 2:47 a.m., {VL}'s phone sent {DL}'s roommate's number a message: \"is ur roommate always this cute\" The roommate never answered."),
            E(.document, 1, "Prior Dating", "{DL} and {VL} went on two dates the previous month, according to messages between them.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Complaining witness",
                        direct: ["\"The last thing I remember is the kitchen at the party.\""],
                        cross: ["\"I don't remember texting anyone at 2:47.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What do you remember about the party?", "\"Getting there around ten. Doing shots in the kitchen with my roommate. Talking to {DL} by the speakers. After about midnight it's pieces. A staircase. Somebody's hand on my arm. Then nothing.\""),
                            .direct("What happened the next morning?", "\"I woke up in {DL}'s bed. I didn't know where I was at first. My clothes were on the floor. I felt sick and confused and scared, and I didn't know what had happened to me. I got dressed and left while {DL} was in the shower.\""),
                            .direct("Why did you go to the hospital?", "\"Because I didn't know. My roommate drove me. I wanted someone to tell me what happened, since I couldn't.\""),
                            .direct("Did you and {DL} have a relationship before that night?", "\"We'd gone out twice. I liked {DL}. I don't think I'd have said no to {DL} sober. But I wasn't sober. I wasn't anything.\""),
                            .cross("The hallway video shows you walking on your own, holding {DL}'s hand, laughing.", "\"I've seen it. I don't remember it. People can walk in a blackout.\""),
                            .cross("Your phone sent a flirtatious message at 2:47 a.m.", "\"I don't remember sending it. I don't doubt my phone sent it.\""),
                            .cross("You told the nurse you 'might have wanted to go home with {DL}.'", "\"I said I didn't know. That's the whole point.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic toxicologist",
                        direct: ["\"At 0.20 to 0.26, many people are in an alcohol blackout.\""],
                        cross: ["\"A person in a blackout can walk, talk, and appear to make choices.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was {VL}'s alcohol level during the night?", "\"Working back from 0.04 at 9:20 a.m., using standard elimination rates, {VL} was between 0.20 and 0.26 around 1:30 a.m.\""),
                            .direct("What does that level do to a person?", "\"For most people it's severe impairment: unsteadiness, slurred speech, nausea, and very often an alcohol blackout, where the brain stops recording memories.\""),
                            .direct("Can someone at that level consent to sex?", "\"That's a legal question, not mine. I can say that judgment and awareness are profoundly affected, and that a person may be unable to understand what's happening.\""),
                            .cross("A person in a blackout can walk, talk, and laugh?", "\"Yes. Blackout isn't unconsciousness. Others may not be able to tell.\""),
                            .cross("So an observer might reasonably think the person was making choices?", "\"An observer might. Whether that's reasonable depends on what the observer saw.\"")
                        ]),
            WitnessSeed(name: nil, role: "{VL}'s roommate",
                        direct: ["\"{VL} couldn't stand up by one o'clock.\""],
                        cross: ["\"{VL} said {V.he} wanted to go with {DL}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("How was {VL} by the end of the party?", "\"Gone. I had to hold {VL}'s hair while {V.he} threw up in the bathroom around 12:45. {VL} couldn't stand without leaning on the wall.\""),
                            .direct("What happened when {VL} left?", "\"{DL} said 'I'll take {VL} home.' I said I'd take {V.him}. {DL} said {D.his} place was closer and {VL} could sleep it off there. {VL} was leaning on {DL}. I let it happen. I think about that every day.\""),
                            .cross("{VL} said {V.he} wanted to go with {DL}?", "\"{VL} said 'I'm fine, I'm going with {DL}.' {VL} was slurring it.\""),
                            .cross("You'd also been drinking that night?", "\"Some. Not like {VL}.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s roommate",
                        direct: ["\"They came in laughing at about one-thirty.\""],
                        cross: ["\"I went to my room and put headphones on.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you see when they came in?", "\"I was on the couch. They came in laughing. {VL} said hi, asked my name, said our apartment was nicer than theirs. {VL} was clearly drunk, but talking, making jokes.\""),
                            .direct("Did {VL} seem to know where {V.he} was?", "\"{VL} seemed to. {VL} asked for water and asked which room was {DL}'s.\""),
                            .cross("You went to your room and put on headphones right away?", "\"After a few minutes.\""),
                            .cross("You didn't see anything after that?", "\"Nothing. My door was shut and my music was loud.\""),
                            .cross("Someone who can't remember the night can still ask for water and make jokes, can't they?", "\"I guess so. I'm not a doctor.\"")
                        ])
        ],
        prosecutionTheory: ["{V} couldn't stand at the party, and {D} held {VL} up on the way out. {DL} knew {VL} was incapacitated and had sex with {V.him} anyway, then joked about it the next morning."],
        defenseTheory: ["{VL} was drunk, but awake, walking, laughing, and texting. Two people who had dated went home together. Regret and memory loss are not proof that {DL} knew {VL} couldn't consent."],
        aggravating: [],
        mitigating: ["{DL} has no prior criminal record", "{DL} was also drinking"],
        victimImpacts: ["{V}: \"I left school for a semester. I don't go to parties. I don't trust my own memory anymore, and that's the part I can't get back.\""],
        allocutions: ["\"I thought {VL} wanted to be with me. If I was wrong, I'm sorry. I'd never knowingly hurt {VL}.\""],
        guiltyTruths: ["A second roommate later told investigators {VL} was unresponsive on {DL}'s bed when the roommate looked in at 1:50 a.m."],
        innocentTruths: ["{VL} later told a counselor fragments came back: {VL} remembered asking {DL} to stay and being happy about it."],
        moods: [.divided], doctrines: ["burdenOfProof", "lesserIncluded"],
        extras: ["TIME": ["1:28 a.m."]],
        story: StoryExtras(
            timeline: [(0, "1:12 a.m.: party video shows {VL} unable to stand. 1:28 a.m.: {DL} and {VL} leave. 1:34 a.m.: hallway camera."),
                       (0, "9:20 a.m.: {VL} arrives at Hollis Regional; sexual assault examination performed; blood drawn."),
                       (0, "9:51 a.m.: {DL} sends text to a friend."),
                       (4, "{VL} reports to Hollis State University police and the Sheriff's Office."),
                       (52, "State Crime Laboratory DNA results consistent with {DL}."),
                       (60, "{DL} charged with second-degree forcible rape.")],
            howIdentified: "{VL} woke in {DL}'s apartment; DNA confirmed intercourse with {DL}.",
            notDone: ["The other partygoers in the video were not all interviewed.", "{DL}'s second roommate was interviewed only briefly."],
            defendantExam: [
                .direct("How did you and {VL} know each other?", "\"We had a class together and went out twice. I really liked {VL}. At the party we talked most of the night.\""),
                .direct("How drunk was {VL}?", "\"Drunk. I'm not going to say otherwise. But talking, joking, making plans. {VL} asked to come to my place.\""),
                .direct("What happened at your apartment?", "\"We talked to my roommate, got water, went to my room. {VL} kissed me first. We were both into it, as far as I could tell. Afterward we fell asleep.\""),
                .direct("What did your text the next morning mean?", "\"It was a stupid, gross thing to send a friend. It meant {VL} had been really drunk. I didn't think {VL} wouldn't remember anything.\""),
                .cross("You were holding {VL} upright at the party at 1:12.", "\"{VL} was wobbly. I was helping.\""),
                .cross("{VL}'s roommate offered to take {V.him} home and you said no.", "\"I said my place was closer. {VL} said {V.he} wanted to come.\""),
                .cross("'They were gone last night.' Those are your words.", "\"They are. I'm ashamed of them.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Defense attorney: \"How many sexual partners have you had in the last year?\"",
                                  answer: "\"I don't want to answer that.\"",
                                  raisedBy: .prosecution, onCross: true, grounds: "Rape Shield (Rule 412)", shouldSustain: true,
                                  explanation: "North Carolina's Rape Shield rule bars evidence of the complainant's sexual behavior with others except in narrow circumstances not present here. The prior dates with {DL} are in evidence; this question is not permitted.",
                                  doctrineID: "relevance", weight: 0))
            ],
            prosecutionOpening: "{V} couldn't stand by one in the morning, and {D} was holding {VL} up. The next morning {DL} texted, 'they were gone last night.' {D.he} knew.",
            defenseOpening: "Two people who had dated, both drinking, left a party together. On video, {VL} walks down the hall laughing. The question isn't whether {VL} remembers. It's whether {DL} knew {VL} couldn't consent.",
            prosecutionClosing: "Incapacity doesn't mean unconscious. It means unable to understand or resist. The vomiting, the video, the roommate's warning, and {DL}'s own text show {D.he} knew.",
            defenseClosing: "Even the State's toxicologist says an observer might not be able to tell. The hallway video and the 2:47 message are reasonable doubt about what {DL} knew.",
            genders: ["D": .male, "V": .female],
            victim: VictimFacts(age: 20, occupation: "Student at Hollis State University", relationship: "A fellow student; acquaintances."),
            school: "Hollis State University"
        )
    )

    // MARK: - 13. Fire in the rental

    static let rentalFire = CaseTemplate(
        key: "story.rentalFire", category: .property,
        headlines: ["Landlord Charged After Fire Guts Rental with Tenants Inside", "Arson or a Bad Space Heater?"],
        primaryLaw: "arson1", lesserLaw: nil, threshold: 4, lesserThreshold: 2,
        specification: "Willfully and maliciously burned the dwelling at {STREET}, occupied at the time by {V} and family.",
        ageRange: 45...66, occupations: ["owner of six rental houses"], hasVictim: true,
        summaries: [
            "{D} owns six rental houses in {HOOD}. For four months {DL} had been trying to evict {V}, who withheld rent over a broken furnace and filed a complaint with the city housing inspector. At about {TIME} on {DATE}, fire broke out in the rental's back room while {V} and {V.his} two children slept. A smoke alarm woke them and all three escaped. The fire marshal found gasoline in the back room. {DL} says {D.he} was home asleep, and that the tenants were running a space heater on an extension cord because of the furnace."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "Laboratory Analysis of Debris", "The State Crime Laboratory identified gasoline in floor debris from two separate spots in the back room, about six feet apart."),
            E(.document, 2, "Eviction Filings and Texts", "{DL}'s magistrate filings and a text to {VL} the week before: \"You will be out of my house one way or another.\""),
            E(.digital, 2, "Neighbor's Doorbell Camera", "At 3:41 a.m., a pickup similar in shape and color to {DL}'s passes the house slowly without headlights. The plate isn't visible.", .search),
            E(.document, 2, "Insurance Policy", "{DL} raised the house's fire coverage from $90,000 to $140,000 seven weeks before the fire.")
        ],
        defenseEvidence: [
            E(.physical, 3, "Space Heater and Extension Cord", "A melted space heater and a light-duty extension cord were found in the back room. The defense's electrical engineer found arcing on the cord."),
            E(.document, 2, "Housing Inspector Report", "The city inspector cited the furnace as inoperable four weeks before the fire and noted the tenants were heating with \"portable electric units.\""),
            E(.document, 1, "Lawn Equipment", "{V} kept a gas can and a push mower in the back room, according to the tenant's own statement.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Deputy State Fire Marshal",
                        direct: ["\"Gasoline in two separate places means it was poured.\""],
                        cross: ["\"There was a gas can in the room.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What is your training?", "\"I'm a certified fire investigator with the Office of State Fire Marshal. I've investigated about five hundred fires over fourteen years.\""),
                            .direct("Where did the fire start?", "\"In the back room, near the floor. The burn patterns, the depth of charring, and the floor damage all point to that room as the origin.\""),
                            .direct("What did the lab find?", "\"Gasoline in floor samples from two separate locations about six feet apart. Two separate pools of gasoline on a floor is what we see when someone pours it.\""),
                            .direct("Did you consider the space heater?", "\"I did. The heater was badly melted, but the arcing on its cord was at the far end, near the outlet, not at the origin area. And a heater doesn't put gasoline in two places.\""),
                            .cross("There was a gas can in that room, for the mower?", "\"There was, and it ruptured in the fire. That could account for gasoline in one area. I don't believe it explains two.\""),
                            .cross("A ruptured can could spill and flow along a sloped floor?", "\"The floor was fairly level. But I can't rule it out completely.\""),
                            .cross("You found nothing that identifies who set the fire, if it was set?", "\"No. That's not my job. I determine the cause.\"")
                        ]),
            WitnessSeed(name: "{V}", role: "Tenant",
                        direct: ["\"{DL} told me I'd be out one way or another.\""],
                        cross: ["\"Yes, we ran the space heater on an extension cord.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Why weren't you paying rent?", "\"The furnace broke in October. I told {DL} for six weeks. Nothing. My kids were sleeping in coats. A legal aid lawyer told me to put the rent in escrow and file with the housing inspector, so I did.\""),
                            .direct("How did {DL} react?", "\"Furious. Filed to evict me twice. Texted me I'd be out one way or another. Came by and banged on the door once and yelled at my oldest.\""),
                            .direct("What happened the night of the fire?", "\"The smoke alarm went off a little before four. The back of the house was orange. I got both kids out the front window. We stood across the street in our socks and watched it burn.\""),
                            .cross("You ran a space heater in the back room on an extension cord?", "\"Yes, because the furnace didn't work.\""),
                            .cross("Was it on that night?", "\"I think I turned it off before bed. I'm not sure.\""),
                            .cross("And you kept a gas can in the same room?", "\"For the mower. On the far side.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Electrical engineer",
                        direct: ["\"The extension cord shows arcing. It could have started this fire.\""],
                        cross: ["\"Arcing can also be caused by the fire.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you examine?", "\"The space heater, the extension cord, and the room's wiring, from the evidence the fire marshal collected.\""),
                            .direct("What did you find?", "\"Arc beads on the extension cord, which is rated for a lamp, not a 1,500-watt heater. Running that heater on that cord for hours can overheat it until it fails and ignites what's around it.\""),
                            .direct("Could that explain gasoline in two places?", "\"If the cord ignited near the gas can, the can would fail, and gasoline would flow and burn wherever the floor took it, including under the shelving. Two samples six feet apart don't require two pours.\""),
                            .cross("Arc beads can form when a fire burns a live cord, not just when the cord starts the fire?", "\"Yes. That's the hard part of these cases.\""),
                            .cross("The arcing you found was near the outlet end, away from where the fire started?", "\"Some of it. Some was mid-cord. I can't place the cord's exact position that night.\""),
                            .cross("You're being paid by the defense?", "\"I'm paid for my time. I'd say the same to the State.\"")
                        ])
        ],
        prosecutionTheory: ["A landlord who wanted a tenant gone, raised the insurance, threatened 'one way or another,' and drove past at 3:41 with the headlights off. Twenty minutes later, gasoline was burning in two places."],
        defenseTheory: ["A broken furnace, a 1,500-watt heater on a lamp cord, and a gas can in the same room. The State has a motive story and a pickup without a plate. It doesn't have an arsonist."],
        aggravating: ["The dwelling was occupied by children at the time of the fire"],
        mitigating: ["No prior criminal record"],
        victimImpacts: ["{V}: \"We lost everything we owned. My youngest still asks if the house is going to catch fire when we turn the heat on.\""],
        allocutions: ["\"I was angry at a tenant. I'd never burn a house with children in it.\""],
        guiltyTruths: ["A hardware store receipt for a two-gallon gas can, bought by {DL} the afternoon before the fire, turned up in an insurance audit."],
        innocentTruths: ["A second engineer's analysis after trial placed the cord's failure precisely at the fire's origin, beside the gas can."],
        moods: [.wantsConviction, .divided], doctrines: ["burdenOfProof"],
        extras: ["TIME": ["3:58 a.m."]],
        story: StoryExtras(
            timeline: [(-120, "{V} begins paying rent into escrow over the broken furnace."),
                       (-49, "{DL} raises the property's fire coverage to $140,000."),
                       (-28, "City housing inspector cites the furnace as inoperable."),
                       (0, "3:41 a.m.: pickup passes without headlights. 3:58 a.m.: 911 call. All occupants escape."),
                       (2, "Fire marshal's scene examination; debris samples collected."),
                       (38, "Laboratory reports gasoline in two samples."),
                       (55, "{DL} charged with first-degree arson.")],
            howIdentified: "Investigators focused on {DL} based on the eviction dispute, the threatening text, the insurance increase, and a pickup resembling {D.his} on a neighbor's camera.",
            notDone: ["{DL}'s truck was not examined for gasoline residue.", "Cell-site records for {DL}'s phone were never requested."],
            defendantExam: [
                .direct("Why did you want {V} out?", "\"I hadn't been paid in four months. I've got a mortgage on that house. I filed to evict the legal way, through the magistrate.\""),
                .direct("What about the text, 'one way or another'?", "\"I meant through the court. I was angry. It was a stupid way to say it.\""),
                .direct("Why raise the insurance?", "\"My agent told me the old policy was below replacement cost. I raised all six houses that month. The paperwork shows all six.\""),
                .direct("Where were you at 3:41 a.m.?", "\"Asleep at home, eleven miles away. My truck was in my driveway.\""),
                .cross("Nobody can confirm you were home.", "\"My spouse was asleep. No, nobody watched me sleep.\""),
                .cross("You yelled at a child on that porch.", "\"I raised my voice at the door. I'm not proud of it.\""),
                .cross("You never fixed the furnace in six weeks.", "\"The part was backordered. I offered space heaters.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"In your opinion, who set this fire?\"",
                                  answer: "\"Somebody with a reason to want that house empty.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Speculation; beyond expertise", shouldSustain: true,
                                  explanation: "A fire investigator may give an opinion on cause and origin, not on who set a fire or why. That's outside the witness's expertise and the factfinder's question.",
                                  doctrineID: "expertTestimony", weight: 2))
            ],
            prosecutionOpening: "Two pools of gasoline in a house with three people asleep inside. A landlord who wanted them out 'one way or another,' a bigger insurance policy, and a truck with its lights off. The State will prove {D} set that fire.",
            defenseOpening: "No furnace, a space heater on a lamp cord, and a can of gas for the mower in the same back room. That's a recipe for an accidental fire, and the State never looked at {DL}'s truck or phone.",
            prosecutionClosing: "One spill doesn't make two pools six feet apart. Motive, threat, insurance, and the truck at 3:41 make this an intentional fire, and the fire marshal says so.",
            defenseClosing: "The State's own investigator can't rule out the can. Its case on who did it is a pickup with no plate. Arson is about proof, and this isn't enough.",
            when: .months([12, 1, 2]),
            victim: VictimFacts(relationship: "The defendant's tenant.", family: "Two children, who live with the victim.", harm: ["No physical injury. She and her two children escaped the fire; they lost everything they owned."], restitution: 14000, restitutionBasis: "clothing, furniture, and belongings lost in the fire")
        )
    )
}
