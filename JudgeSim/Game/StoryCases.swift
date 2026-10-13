import Foundation

private typealias E = EvidenceSeed

/// Fully written cases. Every line is authored for its case, so the story holds together from the first
/// exhibit to the last answer. Only names, places, and dates change from one telling to the next.
enum StoryCases {
    static let all: [CaseTemplate] = [oldMillRoad, churchBooks, duplexBurglary, kitchenStrangulation, sharedApartment]

    // MARK: - 1. A fatal crash after a closing shift

    static let oldMillRoad = CaseTemplate(
        key: "story.oldMillRoad", category: .traffic,
        headlines: ["Head-On Crash on Old Mill Road", "A Nurse Killed Driving Home"],
        primaryLaw: "felonyDBV", lesserLaw: "misdDBV", threshold: 10, lesserThreshold: 7,
        specification: "While impaired, unlawfully and unintentionally caused the death of {V} in a collision on Old Mill Road.",
        ageRange: 24...41, occupations: ["line cook"], hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {D}'s Honda Civic crossed the center line on a curve on Old Mill Road outside {HOOD} and struck a Toyota Corolla head-on. The Corolla's driver, {V}, 34, a nurse driving home from a twelve-hour shift, died at the scene. {D}, a line cook at {REST}, had stayed after closing that night. A hospital blood test about ninety minutes after the crash and a second, State Crime Laboratory test about three hours after it disagree on whether {DL} was over the legal limit when the cars collided. {DL} says a deer came out of the tree line and {DL} swerved."
        ],
        prosecutionEvidence: [
            E(.forensic, 3, "State Crime Laboratory Blood Result", "Blood drawn under a search warrant at 2:51 a.m., nearly three hours after the crash, measured 0.06 grams of alcohol per 100 milliliters of whole blood.", .search),
            E(.document, 2, "Hospital Blood Panel", "The emergency department ran a serum alcohol test at 1:24 a.m. for treatment purposes: 98 mg/dL, which the hospital reported as 0.098 percent. Serum results run higher than whole blood."),
            E(.document, 2, "Point-of-Sale Records from {REST}", "Staff tab after closing: four 16-ounce draft beers rung to {DL}'s employee number between 10:05 and 11:31 p.m."),
            E(.physical, 3, "Crash Scene Diagram", "Trooper {TROOPER}'s measurements place the point of impact 2 feet 7 inches into the Corolla's lane, at the apex of the curve. Gouge marks and debris fields agree."),
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
                            .direct("Did you speak with {DL}?", "\"Briefly. I asked what happened. {DL} said, 'I came around the curve and they were just there.' A minute later {DL} said there'd been a deer. That was the first I heard of a deer.\""),
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
        victimImpacts: ["{VL}'s spouse: \"We have two kids. One of them still sets a place for {VL} at dinner. I don't know how to make that stop.\""],
        allocutions: ["\"I think about {VL} every single time I get in a car. I'd give anything to have taken a ride home that night.\""],
        guiltyTruths: ["{DL} later admitted to a counselor that there'd been two shots of whiskey in the walk-in cooler that never made it onto the tab."],
        innocentTruths: ["A neighbor's trail camera, found a year later, showed three deer crossing Old Mill Road at 11:51 that night."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        extras: ["TIME": ["11:52 p.m."], "REST": ["Big Lou's Smokehouse", "The Copper Kettle", "Riverside Grill"]],
        story: StoryExtras(
            timeline: [(0, "11:52 p.m.: 911 calls report a head-on collision on Old Mill Road. Trooper {TROOPER} arrives at 12:09 a.m."),
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
                                  explanation: "A lay witness can describe what the witness saw of {DL}'s condition, but not offer an opinion on the ultimate question of whether {DL} was impaired.",
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
            defenseClosing: "The State's own expert couldn't say {DL} was at 0.08. Their trooper couldn't rule out the deer. If the court has a reasonable doubt about impairment, the most it can find is a misdemeanor death by vehicle."
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
                            .direct("Who paid those advances?", "\"Checks from DL Property Services. I asked {DL} what that was and {DL} said it was how they were moving the money so it didn't hold up the dedication. I didn't care whose name was on it, honestly. It cleared.\""),
                            .direct("Read the note in your ledger.", "\"'Pastor says advance OK, treasurer handles.' I wrote that the day he told me.\""),
                            .cross("You were paid about $41,000 that way?", "\"About that.\""),
                            .cross("You never saw a trustee vote approving it?", "\"No. That's church business.\""),
                            .cross("Did you know {DL} was also paying a mortgage from the same account?", "\"No. Nobody told me that.\""),
                            .cross("You still want to be paid for the rest of the job, don't you?", "\"I'm owed about sixty thousand. Sure I want paying. It's got nothing to do with what I'm telling you.\"")
                        ])
        ],
        prosecutionTheory: ["{D} took the congregation's building fund for three years, told them every quarter that it was safe, and spent most of it on {DL}'s own bills."],
        defenseTheory: ["The pastor ran that church and told {DL} to keep the contractor working off the books. {DL} made a mess of the accounts. That is not the same as stealing."],
        aggravating: ["The offense involved a position of trust in a religious congregation", "The reports to the congregation were falsified for three years"],
        mitigating: ["{DL} repaid $9,600 before the theft was discovered", "$41,000 was spent on the congregation's own building project", "No prior criminal record"],
        allocutions: ["\"I love that church. I was baptized there. I made a terrible decision when I started borrowing to cover my own house, and I lied to cover it. I'm sorry.\""],
        guiltyTruths: ["After trial, {DL}'s spouse found a notebook in the garage tracking the personal withdrawals, labeled \"to pay back someday.\""],
        innocentTruths: ["Months later, the retired pastor told a deacon he had promised {DL} the church would cover {DL}'s mortgage while {DL} fronted the contractor money, and was too ashamed to say so."],
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
                .cross("You read false balances to the congregation for three years.", "\"Yes.\""),
                .cross("If the pastor approved it, why lie to everyone else?", "\"Because I was ashamed, and because he said wait until after the dedication. Then it was too big to explain.\""),
                .cross("Nothing in writing from the pastor mentions your mortgage, does it?", "\"No. Just what he said to me in his office.\"")
            ],
            objections: [
                (2, ObjectionSeed(question: "Defense attorney: \"What did the pastor tell you about the trustees?\"",
                                  answer: "\"He said, 'The trustees will slow us down. The treasurer will handle it.'\"",
                                  raisedBy: .prosecution, onCross: false, grounds: "Hearsay", shouldSustain: false,
                                  explanation: "Offered to show why the contractor accepted payment from DL Property Services and what {DL} was told, not for the truth of whether the trustees approved. It is admissible for that purpose.",
                                  doctrineID: "hearsay", weight: 1))
            ],
            prosecutionOpening: "The congregation trusted {D} with the money for a new fellowship hall. For three years, {DL} told them it was safe. Most of it went to {DL}'s mortgage, truck, and credit cards.",
            defenseOpening: "The pastor told {DL} to keep the contractor working off the books. Forty-one thousand dollars went to that building. {DL} made terrible choices with the rest, and {DL} will tell you so. The question is what crime, and how much.",
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
        ageRange: 20...36, hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {V} woke to a noise in a duplex on {STREET} in {HOOD} and saw a stranger in the hallway, lit only by a nightlight. The intruder ran out the back door, which had been pried open, taking a laptop, a wallet, and a bottle of prescription pain pills. Four days later {D} sold the laptop to a pawn shop across town. {DL} says the laptop came from a man at a gas station who sold it for $80, and that {DL} was home asleep that night."
        ],
        prosecutionEvidence: [
            E(.document, 3, "Pawn Transaction Record", "{DL} sold the victim's laptop, serial number matching the purchase receipt, to {PAWN} four days after the burglary, showing {DL}'s driver's license and giving a thumbprint as required by law."),
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
                            .cross("You saw this person for about three or four seconds?", "\"About that.\""),
                            .cross("In the light of a nightlight, from the other end of a hallway?", "\"About twenty feet. Yes.\""),
                            .cross("You told the 911 dispatcher you 'couldn't really see their face.'", "\"I was hysterical. I saw the side of it.\""),
                            .cross("Before the lineup, the detective told you they'd found your laptop at a pawn shop?", "\"He said they had a lead from the laptop. He didn't say who.\"")
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
                            .cross("You told {DL} the laptop was probably stolen, and {DL} pawned it anyway?", "\"Yes. I'm not saying it was smart.\"")
                        ])
        ],
        prosecutionTheory: ["{D} pried open the back door of an occupied home in the middle of the night, was seen by the person living there, and four days later sold what was taken."],
        defenseTheory: ["{DL} bought a stolen laptop for eighty dollars, which was foolish and maybe a crime in itself. But the identification is weak, and nothing else puts {DL} in that house."],
        aggravating: ["The home was occupied and the resident confronted the intruder"],
        mitigating: ["{DL} sold the laptop openly under {DL}'s own name", "No prior burglary convictions"],
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
                .cross("You can't name the man, describe his plate, or show any video.", "\"No. I asked my lawyer to get the video. It was gone.\"")
            ],
            objections: [
                (0, ObjectionSeed(question: "Prosecutor: \"Do you think {DL} is the person you saw?\"",
                                  answer: "\"Now that I see them in person, I'm sure of it.\"",
                                  raisedBy: .defense, onCross: false, grounds: "Suggestive in-court identification", shouldSustain: true,
                                  explanation: "An in-court identification with the defendant seated at counsel table, after a 70 percent out-of-court pick, is inherently suggestive and adds little reliable weight.",
                                  doctrineID: "relevance", weight: 2))
            ],
            prosecutionOpening: "Somebody pried open {V}'s back door at three in the morning and was standing in the hallway when {V} came out of the bedroom. Four days later {D} sold the laptop that was taken. {V} picked {DL} out of a lineup.",
            defenseOpening: "{DL} bought a laptop that was too cheap to be honest, then walked it into a pawn shop with a license and a thumbprint. That's what an innocent fool does. The rest of the State's case is a nightlight and three seconds.",
            prosecutionClosing: "The laptop, the lineup, the shoe size, the phone tower, and a story about a man in a red truck nobody can find. Put together, it's {DL}.",
            defenseClosing: "Seventy percent from a nightlight. A shoe size half the men in the county wear. A tower that covers {DL}'s own bed. And video that would have settled this, never collected. That's reasonable doubt."
        )
    )

    // MARK: - 4. A fight in the kitchen

    static let kitchenStrangulation = CaseTemplate(
        key: "story.kitchenStrangulation", category: .violent,
        headlines: ["Domestic Call on {STREET} Ends in Strangulation Charge", "Two Stories From One Kitchen"],
        primaryLaw: "strangulation", lesserLaw: "simpleAssault", threshold: 5, lesserThreshold: 3,
        specification: "Assaulted {V} and inflicted physical injury by strangulation.",
        ageRange: 26...45, hasVictim: true,
        summaries: [
            "At about {TIME} on {DATE}, {V} called 911 from a bathroom in the house on {STREET} that {VL} shared with {D}, saying {DL} had choked {VL} in the kitchen. Deputies found red marks on {VL}'s neck and a broken skillet on the floor; {DL} had fresh scratches on the face and forearm. {DL} says {VL} came at {DL} with the skillet after a night of drinking and {DL} grabbed {VL} to stop it. By trial, {V} says {VL} had been drinking heavily and can't remember who started it."
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
                            .direct("What did {DL} say?", "\"That {VL} came at {DL} with the skillet and {DL} grabbed {VL} to stop it. {DL} said, 'I had to hold {VL} off me.' I asked where {DL}'s hands were. {DL} said 'on {VL}'s shoulders, maybe the neck, I don't know.'\""),
                            .direct("Who was arrested?", "\"{DL}. Under our policy I have to identify the primary aggressor. Strangulation is the more serious injury, and {VL} was the one locked in a bathroom calling for help.\""),
                            .cross("My client had four scratches on the face and a bruised forearm?", "\"Yes. Fresh ones.\""),
                            .cross("{V} told you on camera that {VL} tried to hit {DL} with the pan?", "\"{VL} said 'I tried to hit them with the pan after.' After.\""),
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
                            .cross("{V} told you {VL} had about eight beers?", "\"{VL} said 'eight, maybe ten.'\"")
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
        prosecutionTheory: ["{D} put both hands on {V}'s neck and pressed hard enough to burst blood vessels in {VL}'s eyes. That's strangulation, whatever {VL} says now."],
        defenseTheory: ["{V} came at {DL} with a cast-iron skillet, screaming a death threat. {DL} grabbed {VL} to survive. Self-defense."],
        aggravating: ["Petechiae indicate sustained pressure on the neck"],
        mitigating: ["{DL} was injured in the same incident", "{V} does not wish the prosecution to continue", "{DL} has no prior assault convictions"],
        victimImpacts: ["{V}: \"I'm not a victim of {DL}. We were both a mess that night. I'm in AA now. I'd like {DL} to go too, not to prison.\""],
        allocutions: ["\"I should have walked out the door. I didn't. I'll carry that.\""],
        guiltyTruths: ["{DL} later told a cellmate the skillet came out only after {DL} had {VL} against the counter."],
        innocentTruths: ["Months after trial, {V} told a counselor {VL} swung the pan first and only remembered once sober."],
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
                .direct("What happened with the skillet?", "\"{VL} grabbed it off the stove and swung at my head. I put my arm up and it caught my forearm. Then {VL} scratched my face. I grabbed {VL} and pinned {VL} against the counter so it would stop.\""),
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
            defenseClosing: "The State has to disprove self-defense beyond a reasonable doubt. On this record, with a death threat and a skillet, it hasn't."
        )
    )

    // MARK: - 5. Three people, one closet

    static let sharedApartment = CaseTemplate(
        key: "story.sharedApartment", category: .drugs,
        headlines: ["Cocaine Found in Shared Apartment", "Whose Shoebox Is It?"],
        primaryLaw: "pwisd", lesserLaw: "possSchedII", threshold: 4, lesserThreshold: 2,
        specification: "Possessed cocaine with intent to sell or deliver.",
        ageRange: 21...34, hasVictim: false,
        summaries: [
            "On {DATE}, narcotics detectives executed a search warrant at a three-bedroom apartment on {STREET} in {HOOD}, leased to {D} and shared with two roommates. In a shoebox on the top shelf of the hall closet they found 31 knotted baggies of cocaine totaling 22.4 grams and $1,840 in cash; a digital scale was in a kitchen drawer. {DL} was the only person home. One roommate, {ALT}, who has a prior conviction for selling cocaine, moved out two days later. {DL}, a warehouse forklift operator, says the closet was shared and the box wasn't {DL}'s."
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
                            .direct("What did you find?", "\"In the hall closet, top shelf, a size 11 sneaker box with thirty-one knotted baggies of cocaine and eighteen hundred and forty dollars. A scale in the kitchen drawer. {DL}'s phone, which {DL} unlocked for us, had the texts in evidence.\""),
                            .direct("Why do you believe this was for sale and not personal use?", "\"Thirty-one individually packaged bags of about three-quarters of a gram each, cash in small bills, a scale, and texts that read like orders. A user buys a bag. A seller has thirty-one.\""),
                            .direct("What do the texts mean, in your experience?", "\"'Need 2 of the usual' and 'bring 40' are typical ways of ordering two bags at twenty dollars each. '5 mins' and 'at the door' sound like delivery.\""),
                            .cross("The controlled buy: who did your source buy from?", "\"The source couldn't identify the seller by name. Said it was 'one of the people who lives there.'\""),
                            .cross("That closet is in a shared hallway used by all three tenants?", "\"Yes.\""),
                            .cross("Neither print on the shoebox matched my client?", "\"Correct.\""),
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
                            .cross("Twenty-two grams is under the 28-gram trafficking threshold?", "\"It is.\"")
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
                            .cross("You never actually looked inside the box?", "\"No.\""),
                            .cross("You and {ALT} broke up badly?", "\"Badly enough. That doesn't change what I saw.\""),
                            .cross("What size shoe does {ALT} wear?", "\"I don't know. Big. Eleven, twelve.\"")
                        ])
        ],
        prosecutionTheory: ["The lease is in {DL}'s name, the shoebox is {DL}'s size, the texts are on {DL}'s phone, and {DL} was the one home. {D} was selling cocaine out of that apartment."],
        defenseTheory: ["Three people lived there. The one with a cocaine-dealing record moved out two days after the raid, and the State never checked whether the prints on the box were that person's."],
        aggravating: ["Sales were conducted from a residence"],
        mitigating: ["{DL} has steady full-time employment", "No prior drug convictions"],
        allocutions: ["\"I've never sold anything in my life except my old car. I should have watched who I lived with.\""],
        guiltyTruths: ["After trial, {DL}'s phone backup turned up a contact saved as \"plug\" with dozens of messages arranging pickups."],
        innocentTruths: ["A year later, {ALT} was caught with an identical sneaker box in another apartment, and the old latent prints from the first box matched {ALT}."],
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
            prosecutionOpening: "A shoebox of cocaine packaged for sale, in {DL}'s apartment, in {DL}'s size, with texts on {DL}'s phone that read like orders. The State will prove {D} possessed it to sell it.",
            defenseOpening: "Three people shared that hallway closet. One had a record for selling cocaine and moved out two days later. The prints on the box aren't {DL}'s, and nobody ever checked whether they were that roommate's.",
            prosecutionClosing: "Possession can be shared. {DL} controlled that apartment, and the texts show {DL} was dealing. The State has proven intent to sell.",
            defenseClosing: "Constructive possession in a shared space needs more than a lease. The State had the means to find out whose prints were on that box and chose not to. That's reasonable doubt."
        )
    )
}
