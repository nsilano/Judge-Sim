import Foundation

private typealias E = EvidenceSeed

extension StoryCases {
    static let batchAD: [CaseTemplate] = [vapeShopCounter, printedPistol, passwordReset, shotsIntoHouse, sneakerMeetup]

    // MARK: - The drawer under the register (methamphetamine sold across a vape shop counter)

    static let vapeShopCounter = CaseTemplate(
        key: "story.vapeShopCounter", category: .drugs,
        headlines: ["Vape Shop Clerk Charged With Selling Meth Across the Counter", "Undercover Buys, Locked Drawer: Deputies Raid Hollis Vapor & Glass"],
        primaryLaw: "saleSchedII", lesserLaw: "possSchedII", threshold: 7, lesserThreshold: 4,
        specification: "Sold 6.9 grams of methamphetamine, a Schedule II controlled substance, to an undercover detective at Hollis Vapor & Glass on {DATE}.",
        secondary: [
            SecondaryCharge(lawID: "saleSchedII", specification: "Sold 3.4 grams of methamphetamine to the same undercover detective at Hollis Vapor & Glass fourteen days earlier.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "pwisd", specification: "Possessed with intent to sell or deliver 14.2 grams of methamphetamine, packaged in eight bags in a locked drawer under the register.", chance: 1.0, threshold: 0),
            SecondaryCharge(lawID: "maintainingDwelling", specification: "Knowingly kept a store, Hollis Vapor & Glass, used for keeping and selling methamphetamine.", chance: 0.6, threshold: 6)
        ],
        ageRange: 22...34, occupations: ["vape shop clerk"], hasVictim: false,
        summaries: [
            "{D} ran the evening shift at Hollis Vapor & Glass, a vape shop on {STREET} in {HOOD}. After a man arrested with methamphetamine told deputies he bought it from \"the night clerk\" there, an undercover detective went in twice. Fourteen days before {DATE}, the detective asked {DL} for \"an eighth of ice\" and paid $150; on {DATE} at 7:15 p.m., a quarter ounce for $280. Both times the shop's own camera shows {DL} unlocking a drawer under the register and weighing the bag on a digital scale. A search warrant served fifteen minutes after the second buy found 14.2 more grams in eight bags in that drawer, opened with a key on {DL}'s key ring, and the $280 in marked bills in {DL}'s front pocket. {DL} says the shop's owner, {OWNER}, kept the drawer stocked and told {D.him} to hand bags to certain customers, and that {D.he} never knew exactly what was in them."
        ],
        prosecutionEvidence: [
            E(.video, 3, "Shop Camera Footage", "The shop's own recorder, seized by warrant, shows {DL} unlocking the drawer under the register, weighing a bag on a digital scale, and handing it to the undercover detective during both buys.", .search),
            E(.forensic, 3, "Lab Report", "Methamphetamine in all three exhibits: 3.4 grams from the first buy, 6.9 grams from the second, and 14.2 grams in eight bags from the drawer."),
            E(.physical, 3, "Marked Bills and Drawer Key", "The $280 in pre-recorded bills from the second buy, found in {DL}'s front pocket; the drawer key on {DL}'s key ring.", .search),
            E(.digital, 2, "Phone Messages", "Texts from {DL}'s phone, searched by warrant, to a contact saved as \"T\": \"need a zip by friday\" twenty days before the arrest and \"ice better be good this time\" three days before.", .search)
        ],
        defenseEvidence: [
            E(.document, 2, "Owner's Key", "{OWNER}, the shop's owner, had the second key to the drawer and a possession of methamphetamine conviction from eight years ago."),
            E(.statement, 1, "Owner's Instructions", "A former clerk says {OWNER} told the staff the drawer was his and to hand its bags only to people he named.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{DET}", role: "Undercover narcotics detective",
                        direct: ["\"I asked for ice, and {DL} went to the drawer and weighed it out.\""],
                        cross: ["\"The owner had a key. The footage never shows him opening that drawer.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("How did the investigation start?", "\"A man we arrested with methamphetamine said he'd been buying it at Hollis Vapor & Glass from the clerk who worked nights. That clerk was {DL}.\""),
                            .direct("What happened on the first buy?", "\"I asked for an eighth of ice. {DL} unlocked a drawer under the register, weighed a bag on a little scale, put it inside an empty vape box, and took a hundred and fifty dollars.\"", "\"I said I needed an eighth of ice. {DL} went to a locked drawer under the register, weighed out a bag, and sold it to me inside a vape box for a hundred and fifty.\""),
                            .direct("And on {DATE}?", "\"A quarter ounce for two hundred and eighty dollars in marked bills, same drawer, same scale. We served the search warrant fifteen minutes later, and those bills were in {DL}'s front pocket.\""),
                            .cross("The owner, {OWNER}, also had a key to that drawer?", "\"He did. We kept thirty days of the shop's footage, and he never opens that drawer in any of it.\""),
                            .cross("Did you look at {OWNER}'s phone?", "\"He consented to a search. Nothing in it about drugs, and nothing to or from the contact {DL} was texting.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic chemist, State Crime Laboratory",
                        direct: ["\"All three exhibits were methamphetamine.\""],
                        cross: ["\"I can't tell you who packaged them.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you test?", "\"Three exhibits: one bag from each undercover buy and eight bags from the drawer.\""),
                            .direct("What were the results?", "\"Methamphetamine in all of them. 3.4 grams net from the first buy, 6.9 grams from the second, and 14.2 grams total from the eight drawer bags.\""),
                            .cross("Can you tell who packaged the bags?", "\"No. My work tells you what's in a bag and how much, not whose hands were on it.\"")
                        ]),
            WitnessSeed(name: nil, role: "Digital forensic examiner, Sheriff's Office",
                        direct: ["\"The texts came from {DL}'s phone, to a contact saved as T.\""],
                        cross: ["\"The texts don't say who T is.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did you find on the defendant's phone?", "\"A thread with a contact saved as T. Twenty days before the arrest, {DL} wrote 'need a zip by friday.' Three days before, 'ice better be good this time.'\""),
                            .direct("What does 'a zip' mean in that context?", "\"An ounce. 'Ice' is a common name for crystal methamphetamine.\""),
                            .cross("Did you identify who T is?", "\"The number belongs to a prepaid phone with no subscriber name. We couldn't put a name on it.\""),
                            .cross("Could those texts be about buying for personal use?", "\"An ounce is about twenty-eight grams. That's far more than people buy for themselves, in my experience, but the texts don't say.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Former clerk at the shop",
                        direct: ["\"{OWNER} told us that drawer was his.\""],
                        cross: ["\"I saw {DL} open it at night.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What were the clerks told about the drawer under the register?", "\"{OWNER} said it was his drawer, and that if certain people came in asking for him, we gave them what was in there and put the money aside for him.\""),
                            .direct("Did you ever open it?", "\"Twice, when {OWNER} told me to. I didn't look in the bags.\""),
                            .cross("You left the shop six months before {DL}'s arrest?", "\"About six months, yes.\""),
                            .cross("You saw {DL} open that drawer?", "\"Yes, on nights {OWNER} wasn't there. That's when the nights people came in.\"")
                        ])
        ],
        prosecutionTheory: ["{D} sold methamphetamine out of a locked drawer, weighed it on camera, pocketed the marked money, and was texting about buying ounces."],
        defenseTheory: ["{OWNER} owned the shop, the drawer, and the business inside it. A night clerk handed over what the boss told {D.him} to hand over."],
        aggravating: [],
        mitigating: ["The defendant has a substance use disorder", "No prior criminal record"],
        victimImpacts: [],
        allocutions: ["\"I was using every day, and that drawer was how I paid for it. I'm three months clean in jail. I want to stay that way.\""],
        guiltyTruths: ["The prepaid number saved as T was later traced to a supplier in another county, who told agents {DL} had been buying an ounce every two weeks for six months."],
        innocentTruths: ["{OWNER} was arrested a year later running the same drawer through a new clerk at a second shop; that clerk told agents {OWNER} filled it and called the bags \"product.\""],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "searchSeizure"],
        extras: ["OWNER": ["Dale Pruitt", "Rick Tedder", "Gary Honeycutt"]],
        story: StoryExtras(
            timeline: [(-40, "A man arrested with methamphetamine names the night clerk at Hollis Vapor & Glass."), (-14, "First undercover buy: 3.4 grams for $150."), (0, "Second undercover buy at 7:15 p.m.: 6.9 grams for $280. Search warrant served at 7:30 p.m.; 14.2 grams in the drawer; {DL} arrested."), (2, "Warrant for {DL}'s phone; the texts with T recovered."), (5, "{OWNER} interviewed; consents to a phone search."), (31, "Lab confirms methamphetamine in all three exhibits.")],
            howIdentified: "Named by an arrested buyer, then two undercover buys recorded by the shop's own camera.",
            notDone: ["The person behind the prepaid number saved as T was never identified."],
            defendantExam: [
                .direct("What was in that drawer, as far as you knew?", "\"{OWNER}'s stuff. He told me certain people would come in and I should weigh out what they asked for and keep the cash for him.\""),
                .direct("Why was the $280 in your pocket?", "\"I was holding it for {OWNER}. He came by in the mornings and I'd hand it over.\""),
                .cross("You asked T for 'a zip' and complained the ice wasn't good.", "\"That was for me. I was using.\"", "\"I had a habit. That was about my own use.\""),
                .cross("An ounce, every couple of weeks, for yourself?", "\"I used a lot.\""),
                .cross("And the man who asked for ice got it from you, weighed, in a vape box.", "\"I did what I was told to do.\"")
            ],
            prosecutionOpening: "Two buys on camera, a drawer full of methamphetamine, and the marked money in {DL}'s pocket.",
            defenseOpening: "The owner's drawer, the owner's customers, and a clerk following orders.",
            prosecutionClosing: "Thirty days of footage, and the only person who ever opens that drawer is {DL}. A scale, a key ring, and the marked bills finish it.",
            defenseClosing: "{OWNER} had a key, a record, and a former clerk who says it was his drawer. The State never charged the one person who stocked it.",
            time: "7:15 p.m.",
            employer: "Hollis Vapor & Glass", employmentEnded: true,
            family: "Single, no children.",
            yearsAtJob: 2
        )
    )

    // MARK: - The back bedroom (a printed pistol in a house a felon shares with his brother)

    static let printedPistol = CaseTemplate(
        key: "story.printedPistol", category: .publicOrder,
        headlines: ["Landlord's Inspection Turns Up 3D-Printed Pistol", "\"It's My Brother's Printer,\" Says Felon Charged With Gun"],
        primaryLaw: "felonFirearm", lesserLaw: nil, threshold: 7, lesserThreshold: 5,
        specification: "Possessed a firearm, an unserialized 9mm pistol with a 3D-printed frame, after having been convicted of a felony.",
        ageRange: 28...40, occupations: ["line cook", "auto detailer", "forklift operator"], forcedPriorOffenses: ["PWISD Cocaine@8"], hasVictim: false,
        summaries: [
            "{D}, who has a felony drug conviction from about eight years ago, lives with an older brother, {ALT}, in a rented house on {STREET} in {HOOD}. The lease is in {ALT}'s name, with {DL} added as an occupant. On {DATE} at 10:15 a.m., the landlord came for a scheduled inspection; {DL} let the landlord in while {ALT} was at work. In the back bedroom, where {DL} sleeps on a futon, the landlord saw a black pistol on the desk beside a 3D printer. When the landlord asked about it, {DL} said, \"It's not loaded, don't worry about it.\" Deputies returned with a search warrant at 2:05 p.m. and found the pistol, loaded with ten rounds, on the same desk. {DL}'s phone held a photo of the pistol lying on the futon, taken nineteen days earlier. {ALT} says he printed and assembled the pistol himself and that the back room is his workroom as much as anyone's bedroom."
        ],
        prosecutionEvidence: [
            E(.physical, 3, "Printed Pistol", "An unserialized 9mm pistol with a printed polymer frame and a factory slide and barrel, loaded with ten rounds, on the desk in the back bedroom where {DL} sleeps.", .search),
            E(.statement, 2, "Landlord's Account", "The landlord saw the pistol on the desk at 10:15 a.m., and {DL} said, \"It's not loaded, don't worry about it.\""),
            E(.digital, 2, "Phone Photo", "A photo on {DL}'s phone, taken nineteen days before {DATE}, of the pistol lying on the futon in the back bedroom, sent to a friend with the text \"look what this fool printed now.\"", .search),
            E(.forensic, 1, "DNA Report", "A mixture of at least two people on the grip: {ALT} is the major contributor; {DL} cannot be excluded as a minor contributor.")
        ],
        defenseEvidence: [
            E(.digital, 2, "Printer and Parts Purchases", "The printer's app account, the filament, and the slide and barrel were all bought on {ALT}'s account with {ALT}'s card."),
            E(.document, 1, "Lease", "The lease is in {ALT}'s name; the back bedroom holds {ALT}'s desk, printer, and work files as well as {DL}'s futon and clothes.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Landlord",
                        direct: ["\"There was a pistol on the desk, right next to the printer.\""],
                        cross: ["\"I don't know whose desk it was.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Why were you at the house?", "\"A yearly inspection. I'd given them a week's notice in writing. {DL} let me in.\""),
                            .direct("What did you see in the back bedroom?", "\"A futon, clothes on the floor, a desk with one of those 3D printers on it, and a black pistol lying next to the printer.\"", "\"Clothes, a futon made up as a bed, a printer on the desk, and a black handgun right beside it.\""),
                            .direct("Did you say anything about it?", "\"I asked whose it was. {DL} said, 'It's not loaded, don't worry about it.'\""),
                            .cross("Did {DL} say the pistol was {D.his}?", "\"No. Just that it wasn't loaded.\""),
                            .cross("Why did you call the sheriff?", "\"When {DL} was added to the lease, the background check showed a felony. I didn't want a gun problem in my house.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's detective",
                        direct: ["\"Same pistol, same desk, loaded with ten rounds.\""],
                        cross: ["\"The printer and the parts were bought by the brother.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you find when you served the warrant?", "\"At 2:05 p.m., a 9mm pistol on the desk in the back bedroom, where the landlord described it. Ten rounds in the magazine. No serial number anywhere on it.\""),
                            .direct("Whose things were in that room?", "\"{DL}'s clothes, {DL}'s mail on the desk, a made-up futon. The desk also had {ALT}'s work files and the printer.\""),
                            .direct("What was on {DL}'s phone?", "\"A photo of the same pistol lying on that futon, taken nineteen days earlier and sent to a friend with the words 'look what this fool printed now.'\""),
                            .cross("Every purchase for the printer and the gun parts was on {ALT}'s card?", "\"Yes. The printer account, the filament, the slide and barrel. All {ALT}.\""),
                            .cross("You found no fingerprints of {DL} on the pistol?", "\"No usable prints from anyone. The printed frame is textured.\"")
                        ]),
            WitnessSeed(name: nil, role: "DNA analyst, State Crime Laboratory",
                        direct: ["\"{DL} cannot be excluded as a minor contributor.\""],
                        cross: ["\"DNA can transfer without the person touching the item.\""],
                        weight: 1, lay: false,
                        exam: [
                            .direct("What did the swab of the grip show?", "\"A mixture from at least two people. {ALT} is the major contributor. {DL} cannot be excluded as a minor contributor.\""),
                            .cross("Can a minor contribution come from secondary transfer?", "\"It can. Two people living in the same house share towels, door handles, a desk. A small amount can move from one surface to another.\""),
                            .cross("So you can't say {DL} ever held this gun?", "\"I can't say when or how the DNA got there.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: "{ALT}", role: "{DL}'s older brother",
                        direct: ["\"I printed it. It's mine.\""],
                        cross: ["\"I didn't think about where I left it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Whose pistol is it?", "\"Mine. I bought the printer, I bought the slide and barrel, and I built it over about a month at that desk.\""),
                            .direct("Why is your desk in the room where your brother sleeps?", "\"It's a two-bedroom house. My room is too small for the desk. The back room was my workroom before {DL} moved in, and it still is in the evenings.\""),
                            .direct("Did your brother ever handle it?", "\"Not that I ever saw. {DL} knows {D.he} can't.\""),
                            .cross("You left a loaded gun on a desk in the room your brother, a convicted felon, sleeps in?", "\"I wasn't thinking about it that way. It was my desk.\"", "\"I didn't think about it. It's where I work.\""),
                            .cross("And the photo of it on {DL}'s futon?", "\"I'd just finished it. I set it down there to show {DL}.\"")
                        ])
        ],
        prosecutionTheory: ["The pistol sat loaded in {DL}'s bedroom, {DL} vouched that it wasn't loaded, and {DL} had photographed it on {D.his} own bed. That is knowing possession."],
        defenseTheory: ["{ALT} printed it, paid for it, and left it on his own desk. A felon living in a room with a brother's gun doesn't possess it."],
        aggravating: [],
        mitigating: ["The defendant has been gainfully employed", "The defendant has a support system in the community"],
        victimImpacts: [],
        allocutions: ["\"I've stayed out of trouble for eight years. I should have moved out of that room the day that gun showed up.\""],
        guiltyTruths: ["A friend later told deputies {DL} had taken the pistol to a gravel pit and fired it twice the week before the inspection."],
        innocentTruths: ["{ALT} was later cited for leaving the pistol where a prohibited person lived, and the friend who received the photo said {DL} had sent it complaining that {ALT} wouldn't put it away."],
        moods: [.divided], doctrines: ["burdenOfProof", "searchSeizure"],
        story: StoryExtras(
            timeline: [(-19, "Photo of the pistol on the futon taken on {DL}'s phone and sent to a friend."), (-7, "Landlord gives written notice of the inspection."), (0, "10:15 a.m. inspection; landlord sees the pistol and calls the sheriff. 2:05 p.m. search warrant served; pistol seized; {DL} arrested."), (1, "{ALT} interviewed; says the pistol is {ALT}'s."), (3, "Warrant for {DL}'s phone."), (45, "DNA report.")],
            howIdentified: "The landlord's call after the inspection.",
            notDone: [],
            defendantExam: [
                .direct("Did the pistol belong to you?", "\"No. My brother built it. It was always on his side of that desk.\""),
                .direct("Why did you tell the landlord it wasn't loaded?", "\"I didn't want the landlord scared. I didn't actually know.\""),
                .cross("You took a picture of it on your bed.", "\"My brother set it there to show me. I sent it to a friend because I thought it was ridiculous.\""),
                .cross("And you never picked it up.", "\"No. I know what one gun means for me.\"")
            ],
            prosecutionOpening: "A loaded gun in the room where {DL} sleeps, a photo of it on {D.his} bed, and {D.his} own words about it.",
            defenseOpening: "Everything about this gun leads to {ALT}: the printer, the parts, the money, and the major DNA.",
            prosecutionClosing: "Possession doesn't need a receipt. {DL} lived with that gun, knew its condition, and had it within reach every night.",
            defenseClosing: "Being near a gun isn't possessing it. The State needs more than a shared room, and it doesn't have it.",
            genders: ["ALT": .male],
            time: "10:15 a.m.",
            family: "Single, no children. Lives with an older brother.",
            residence: "A rented house on {STREET} in {HOOD}, shared with an older brother"
        )
    )

    // MARK: - The recovery code (an ex-partner's accounts taken over)

    static let passwordReset = CaseTemplate(
        key: "story.passwordReset", category: .cyber,
        headlines: ["Ex-Partner Charged After Private Messages Posted From Victim's Own Account", "Logins Traced to Defendant's Home Internet, Detectives Say"],
        primaryLaw: "accessingComputers", lesserLaw: nil, threshold: 8, lesserThreshold: 6,
        specification: "Willfully and without authorization accessed {V}'s email and social media accounts, changing their passwords and recovery information.",
        secondary: [
            SecondaryCharge(lawID: "cyberstalking", specification: "Electronically posted and sent messages from {V}'s accounts, including {V}'s private conversations, for the purpose of abusing and embarrassing {V}.", chance: 1.0, threshold: 6)
        ],
        ageRange: 24...38, occupations: ["warehouse shift lead", "insurance claims adjuster", "pharmacy technician"], hasVictim: true,
        summaries: [
            "{V} ended a two-year relationship with {D} a month before {DATE}. At 11:52 p.m. that night, someone signed into {V}'s email with the password {V} had used for years and that {DL} knew, then used it to reset {V}'s social media password and change the recovery number to a prepaid phone bought with cash the day before. Over the next two nights, {V}'s own account posted screenshots of {V}'s private messages with a friend, captioned as proof that {V} was a liar and a cheat, and messaged {V}'s manager at work. Records obtained by warrant show all three nights' logins came from the internet address assigned to {DL}'s apartment. {DL}'s laptop's browser history had been cleared the morning after the last post. {DL} says the upstairs tenant has used {D.his} Wi-Fi for months and that {D.he} never touched {V}'s accounts."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "Login Records", "Email and social media records show logins to {VL}'s accounts at 11:52 p.m. on {DATE}, 10:14 p.m. the next night, and 9:40 p.m. the night after, all from the internet address assigned to {DL}'s apartment, from a Windows laptop.", .search),
            E(.digital, 2, "Breakup Texts", "Ten days before the logins, {DL} texted {V}: \"Everybody's going to know who you really are.\"", .search),
            E(.digital, 2, "Cleared Laptop", "{DL}'s Windows laptop, seized by warrant: browser history and saved passwords cleared at 7:06 a.m. the morning after the last post.", .search),
            E(.video, 1, "Prepaid Phone Purchase", "A store camera shows a person in a hooded jacket, face turned down, buying a prepaid phone with cash at 8:41 p.m. the day before, four-tenths of a mile from {DL}'s apartment.")
        ],
        defenseEvidence: [
            E(.statement, 2, "Shared Wi-Fi", "The upstairs tenant in {DL}'s fourplex has used {DL}'s Wi-Fi password for months and owns a Windows laptop."),
            E(.document, 1, "No Prepaid Phone", "No prepaid phone, packaging, or receipt was found in {DL}'s apartment, car, or trash.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Account holder",
                        direct: ["\"My own account was telling everyone I was a liar.\""],
                        cross: ["\"{DL} knew my password. I never gave it to anyone else.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("When did you realize something was wrong?", "\"The next morning I couldn't get into anything. My phone was full of messages from friends asking why I'd posted our private conversations.\"", "\"I woke up locked out of my own accounts, and my friends were texting me screenshots of things I'd only ever said privately.\""),
                            .direct("What had been posted?", "\"Screenshots of my messages with my best friend, about my breakup. Captions calling me a liar and a cheat. Then it messaged my manager.\""),
                            .direct("How did that affect you?", "\"I felt like someone had walked through my house and read my diary out loud on the street. I didn't go to work for three days. I still check my accounts every hour.\""),
                            .cross("Many people could have known or guessed your password?", "\"It wasn't a guessable password. {DL} knew it because we shared a laptop for two years. I'd never given it to anyone else.\""),
                            .cross("You never saw who did this?", "\"No. I saw what was done.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Computer crimes detective",
                        direct: ["\"All three nights came from {DL}'s internet account.\""],
                        cross: ["\"An internet address tells you the connection, not the person at the keyboard.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Where did the logins come from?", "\"Warrant returns from both companies show all three logins came from one internet address, and the internet provider says that address was assigned to {DL}'s apartment those nights. The device was a Windows laptop.\""),
                            .direct("What did you find on {DL}'s laptop?", "\"It's a Windows laptop. The browser history and saved passwords had been cleared at 7:06 the morning after the last post. Nothing before that cleanup was recoverable.\""),
                            .direct("And the recovery phone?", "\"A prepaid phone bought with cash the evening before, at a store four-tenths of a mile from {DL}'s apartment. It received one text, the reset code, and was never used again.\""),
                            .cross("The upstairs tenant uses the same Wi-Fi?", "\"Yes. The tenant told us that and showed us the laptop, also Windows.\""),
                            .cross("Did you search the tenant's laptop?", "\"The tenant let us look at the browser and the accounts signed in. Nothing connected to {V}. The tenant has never met {V}.\""),
                            .cross("The store video doesn't show a face?", "\"No. A hooded jacket and a lowered head.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "Upstairs tenant in the fourplex",
                        direct: ["\"I've used that Wi-Fi every day for months.\""],
                        cross: ["\"I don't know {V}.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Whose internet do you use?", "\"{DL}'s. My own service got cut off in the spring, and {DL} gave me the password.\""),
                            .direct("Were you online the nights in question?", "\"Probably. I'm online most nights.\""),
                            .cross("Do you know {V}?", "\"I've never met {V}. I'd never heard the name before this case.\""),
                            .cross("You let the detective look through your laptop?", "\"Yes. I had nothing to hide.\"")
                        ])
        ],
        prosecutionTheory: ["{DL} knew the password, threatened to expose {V}, logged in from {D.his} own apartment three nights running, and wiped {D.his} laptop the morning after."],
        defenseTheory: ["An internet address is a building, not a person. Two people used that connection, the prepaid phone was never found, and the video shows no face."],
        aggravating: [],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"Those were the most private things I'd ever written, and they went out under my own name. I don't feel safe typing anything anymore.\""],
        allocutions: ["\"I said something cruel in a text. I didn't do the rest of this.\""],
        guiltyTruths: ["The prepaid phone's box turned up months later in a storage bin {DL} rented, with the receipt still inside."],
        innocentTruths: ["A friend of {V}'s who had sat beside {V} at the shared laptop for years was later found to have bought the prepaid phone and to have parked outside {DL}'s fourplex those nights."],
        moods: [.divided], doctrines: ["burdenOfProof", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-31, "{V} ends the relationship."), (-10, "{DL} texts: \"Everybody's going to know who you really are.\""), (-1, "Prepaid phone bought with cash at 8:41 p.m."), (0, "11:52 p.m. login; passwords and recovery number changed."), (1, "Posts and a message to {VL}'s manager; 10:14 p.m. login."), (2, "9:40 p.m. login; more posts."), (3, "7:06 a.m. {DL}'s laptop history cleared; {V} regains the accounts and reports."), (20, "Warrant returns trace the logins to {DL}'s apartment; laptop seized."), (24, "Upstairs tenant interviewed.")],
            howIdentified: "Warrant returns tracing the logins to the internet account at {DL}'s apartment.",
            notDone: ["No usable fingerprints were recovered from the store counter where the prepaid phone was bought."],
            defendantExam: [
                .direct("Did you sign into {V}'s accounts?", "\"No. I knew the password from when we were together. I never used it after.\""),
                .direct("Why send that text ten days before?", "\"I was angry and hurt. It was a stupid thing to write. I meant I'd tell our friends my side, not this.\""),
                .cross("Your laptop was wiped the morning after the last post.", "\"I clear it all the time.\"", "\"I clear my history. Lots of people do.\""),
                .cross("Three nights, your apartment's connection, a Windows laptop like yours.", "\"And the upstairs tenant's, on my Wi-Fi.\""),
                .cross("The upstairs tenant has never met {V}.", "\"I can't tell you why anyone did this.\"")
            ],
            prosecutionOpening: "The person who knew the password, threatened exposure, and wiped a laptop the morning after.",
            defenseOpening: "Two laptops, one Wi-Fi password, and no face on the video.",
            prosecutionClosing: "Only one person on that connection knew {V}, knew the password, and promised to do exactly this.",
            defenseClosing: "Motive isn't proof. The State traced a building and asked you to fill in the name.",
            victim: VictimFacts(occupation: "dental office manager", relationship: "Former partner; ended the relationship a month before", restitution: 0),
            time: "11:52 p.m.",
            family: "Single, no children.",
            residence: "An apartment in a fourplex in {HOOD}"
        )
    )

    // MARK: - Four casings in the street (shots into a house after a quarrel over money)

    static let shotsIntoHouse = CaseTemplate(
        key: "story.shotsIntoHouse", category: .violent,
        headlines: ["Four Shots Fired Into Home Overnight; No One Hurt", "Man Charged Two Days After Cookout Argument Over $400"],
        primaryLaw: "dischargingOccupied", lesserLaw: nil, threshold: 9, lesserThreshold: 7,
        specification: "Willfully discharged a firearm into the occupied dwelling of {V} on {STREET}.",
        ageRange: 25...45, occupations: ["mechanic"], hasVictim: true,
        summaries: [
            "At 2:15 a.m. on {DATE}, four shots were fired into {V}'s house on {STREET} in {HOOD}. One went through the front window and into the couch where {V} had been asleep in front of the television until about 1:50 a.m.; {V} was in the bedroom by then, and no one was hurt. Two days earlier, at a cookout, {V} and {D}, a mechanic, had argued over $400 {V} owed {DL} for a car repair, and {DL} said in front of several people, \"You'll pay one way or another.\" A neighbor's doorbell camera recorded a silver sedan passing at 2:15 a.m., consistent with a 2013 to 2018 Nissan Altima; the plate is unreadable. {DL} drives a 2016 silver Altima. A search of {DL}'s home and car found no gun and no ammunition, a gunshot residue test of {DL}'s hands that morning was negative, and {DL}'s phone stayed on the tower near {D.his} apartment, three miles away, all night. {DL} says {D.he} was asleep at home."
        ],
        prosecutionEvidence: [
            E(.statement, 2, "Cookout Threat", "Several guests heard {DL} tell {V}, \"You'll pay one way or another,\" two days before the shooting, during an argument over a $400 repair bill."),
            E(.video, 2, "Doorbell Video", "A silver sedan passing {VL}'s house at 2:15 a.m. with its headlights off, consistent with a 2013 to 2018 Nissan Altima; the plate cannot be read."),
            E(.physical, 1, "Shell Casings", "Four 9mm casings in the street in front of {VL}'s house; no gun has been found to compare them to.")
        ],
        defenseEvidence: [
            E(.digital, 3, "Phone Location Records", "{DL}'s phone connected only to the tower serving {D.his} apartment, three miles away, from 12:30 a.m. to 6:10 a.m.", .search),
            E(.physical, 2, "Search Results", "A search of {DL}'s apartment and car the same day found no gun, no ammunition, and no gun case or receipts."),
            E(.forensic, 1, "Gunshot Residue", "A residue kit taken from {DL}'s hands at 11:00 a.m. was negative.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: "{V}", role: "Homeowner",
                        direct: ["\"I'd been asleep on that couch twenty minutes before.\""],
                        cross: ["\"I didn't see who it was.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What happened that night?", "\"I fell asleep on the couch watching TV and woke up around ten till two and went to bed. About twenty minutes later, four bangs, glass everywhere. I got on the floor and called 911.\""),
                            .direct("What did you find in the morning?", "\"A hole in the couch cushion right where my head had been. I can't sit in that room anymore.\"", "\"A bullet in the couch, right where I'd been lying. I've moved the couch, and I still sleep in the back room.\""),
                            .direct("What happened at the cookout?", "\"I owed {DL} four hundred dollars for work on my car. I told {D.him} I'd pay when I could. {D.He} said, 'You'll pay one way or another.'\""),
                            .cross("You didn't see the shooter or the car?", "\"No. I was on the floor.\""),
                            .cross("Do you owe money to anyone else?", "\"A few people. Nobody else threatened me.\"")
                        ]),
            WitnessSeed(name: nil, role: "Guest at the cookout",
                        direct: ["\"I heard {DL} say, 'You'll pay one way or another.'\""],
                        cross: ["\"People say things when they're mad.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("What did you hear between {DL} and {V}?", "\"They were arguing about money for a car repair. {DL} said, 'You'll pay one way or another,' and left.\""),
                            .cross("Had {DL} been drinking?", "\"We all had a couple of beers.\""),
                            .cross("Did {DL} mention a gun?", "\"No. Nobody said anything about a gun.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Sheriff's detective",
                        direct: ["\"The car on the doorbell video is consistent with {DL}'s.\""],
                        cross: ["\"There are hundreds of silver Altimas in this county.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What did the doorbell video show?", "\"A silver sedan passing at 2:15 a.m. with its headlights off. The shape of the taillights fits a 2013 to 2018 Altima. {DL} drives a 2016 silver Altima.\""),
                            .direct("What did you find at the scene?", "\"Four 9mm casings in the street, and four bullet holes in the front of the house.\""),
                            .cross("How many silver or gray Altimas of those years are registered in this county?", "\"More than nine hundred.\""),
                            .cross("Your search of my client's home and car found no gun, no ammunition?", "\"Nothing. We also found no receipts or cases.\""),
                            .cross("And the residue test and phone records?", "\"The residue test was negative, though nine hours had passed. The phone stayed near the apartment all night.\""),
                            .redirect("Does a phone at home put its owner at home?", "\"No. It tells you where the phone was.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s partner",
                        direct: ["\"{DL} was asleep next to me.\""],
                        cross: ["\"I sleep hard.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("Where was {DL} that night?", "\"Home. We went to bed around twelve-thirty. When the alarm went off at six-forty, {DL} was right there.\""),
                            .direct("Did {DL} own a gun?", "\"Not since I've known {D.him}. There's never been one in our place.\""),
                            .cross("You were asleep between twelve-thirty and six-forty?", "\"Yes.\""),
                            .cross("So you can't say {DL} didn't get up at two?", "\"I'd have heard the car. It's loud. But I was asleep, yes.\"")
                        ])
        ],
        prosecutionTheory: ["Two days after promising {V} would pay one way or another, a car like {DL}'s rolled past with its lights off and someone emptied a pistol into the house."],
        defenseTheory: ["A heated sentence, one of nine hundred silver cars, and nothing else. No gun, no residue, and {DL}'s phone at home all night."],
        aggravating: ["The defendant knowingly created a great risk of death to more than one person"],
        mitigating: ["No prior criminal record", "The defendant has been gainfully employed"],
        victimImpacts: ["{V}: \"My head was on that cushion twenty minutes before. I don't sleep more than a couple of hours at a time now.\""],
        allocutions: ["\"I wanted my four hundred dollars. I didn't shoot at anybody's house.\""],
        guiltyTruths: ["A 9mm pistol later recovered from a creek near {DL}'s apartment was matched to the four casings; a friend admitted selling it to {DL} the day after the cookout."],
        innocentTruths: ["The casings were matched months later to a gun seized from a man {V} owed $1,200, who admitted the shooting."],
        moods: [.divided], doctrines: ["burdenOfProof", "alibi"],
        story: StoryExtras(
            timeline: [(-2, "Cookout argument; {DL} says, \"You'll pay one way or another.\""), (0, "2:15 a.m. four shots into {VL}'s house; casings collected; doorbell video found. 11:00 a.m. residue kit from {DL}'s hands. Afternoon search of {DL}'s apartment and car."), (6, "Phone location records returned."), (14, "{DL} charged.")],
            howIdentified: "{V} named {DL} because of the cookout argument; the doorbell video showed a car like {DL}'s.",
            notDone: ["No license plate readers cover the roads between {DL}'s apartment and {VL}'s house."],
            defendantExam: [
                .direct("What did you mean at the cookout?", "\"I meant small claims court. I'd done eight hours of work on that car.\""),
                .direct("Where were you at 2:15 that morning?", "\"Asleep, at home, three miles away.\""),
                .cross("You drive a silver 2016 Altima.", "\"So do a lot of people.\""),
                .cross("You said 'one way or another.'", "\"I did. I was mad. I'd never shoot into a house.\"")
            ],
            prosecutionOpening: "A threat, a car with its lights off, and four bullets into a house where {V} was sleeping.",
            defenseOpening: "No gun, no residue, a phone at home, and one of nine hundred cars.",
            prosecutionClosing: "Who else had a reason two days earlier and a car like that one?",
            defenseClosing: "The State has a motive and a car color. That's suspicion, and suspicion is not proof beyond a reasonable doubt.",
            victim: VictimFacts(relationship: "An acquaintance who owed the defendant $400 for a car repair.", harm: ["No one was hurt; a bullet went into the couch where she had been sleeping half an hour earlier."], restitution: 1800, restitutionBasis: "the front window and the couch"),
            time: "2:15 a.m.",
            family: "Lives with a partner; no children.",
            residence: "An apartment about three miles from {VL}'s house"
        )
    )

    // MARK: - Size 11 (a resale meetup that ended in a killing)

    static let sneakerMeetup = CaseTemplate(
        key: "story.sneakerMeetup", category: .violent,
        headlines: ["Teen Shot Dead Selling Sneakers in Apartment Parking Lot", "Buyer From Resale App Charged With Murder"],
        primaryLaw: "murder1", lesserLaw: "murder2", threshold: 8, lesserThreshold: 6,
        specification: "Killed {V} by shooting {V.him} in the chest during the perpetration of a robbery with a firearm (first-degree murder under the felony murder rule).",
        secondary: [
            SecondaryCharge(lawID: "dangerousRobbery", specification: "Took a pair of sneakers worth $650 from {V} by the use of a firearm, endangering {V}'s life.", chance: 1.0, threshold: 0)
        ],
        ageRange: 18...24, occupations: ["unemployed", "fast-food worker"], hasVictim: true,
        summaries: [
            "{V}, 19, paid for community college by reselling sneakers. A buyer on a resale app agreed to pay $650 for a pair of limited-release shoes, size 11, and set the meeting for 8:40 p.m. on {DATE} in the parking lot of an apartment complex on {STREET} in {HOOD}. {V} drove there with a friend in the passenger seat. The buyer got into the back seat to look at the shoes, pulled a pistol, and said, \"Run it.\" When {V} grabbed for the box, the buyer fired twice, hitting {V} in the chest, and ran with the shoes. {V} died at the hospital at 9:52 p.m. The buyer's account was registered to {D}'s phone number, and the phone's location data put it in the parking lot at the time. Two days later, a search of {DL}'s apartment, four miles away, found the shoe box with {V}'s handwritten inventory label and a 9mm pistol that fired both casings. {DL} says {D.he} lent {D.his} phone that evening to a man {D.he} knew as Dre, who left the shoes and a backpack at {D.his} apartment the next morning."
        ],
        prosecutionEvidence: [
            E(.digital, 3, "App Records", "The buyer account was created three days earlier with {DL}'s phone number and used only from {DL}'s phone; it arranged the 8:40 p.m. meeting and the $650 price.", .search),
            E(.digital, 3, "Phone Location Data", "{DL}'s phone was within 40 meters of the parking lot from 8:36 to 8:44 p.m., then moved toward {DL}'s apartment.", .search),
            E(.physical, 3, "Shoe Box and Pistol", "In {DL}'s bedroom closet: the size 11 shoes in a box labeled in {VL}'s handwriting \"#47 – size 11 – $650,\" and a 9mm pistol in a backpack.", .search),
            E(.forensic, 3, "Firearms Comparison", "Both casings from the car and the bullet recovered at autopsy were fired from the 9mm pistol in {DL}'s closet."),
            E(.statement, 2, "Photo Lineup", "{VL}'s friend picked {DL} from a blind-administered photo lineup two days later: \"I'm pretty sure that's the one.\"")
        ],
        defenseEvidence: [
            E(.statement, 1, "Lineup Confidence", "The friend saw the buyer for a few seconds by the dome light and described the confidence as \"pretty sure.\""),
            E(.statement, 1, "Dre", "{DL}'s cousin says a man called Dre spent time at {DL}'s apartment that week.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Friend of {VL}, in the passenger seat",
                        direct: ["\"The buyer pulled a gun and shot {VL} over a box of shoes.\""],
                        cross: ["\"I saw the face for a few seconds.\""],
                        weight: 3, lay: true,
                        exam: [
                            .direct("What happened when the buyer got in the car?", "\"The dome light was on. The buyer looked at the shoes for a second, then pulled a gun out of a hoodie pocket and said, 'Run it.'\"", "\"{VL} handed the box back. The buyer opened it, then came up with a pistol and said, 'Run it.'\""),
                            .direct("What did {VL} do?", "\"Grabbed for the box. It was instinct. The buyer fired twice, and then the door was open and the buyer was gone with the shoes.\""),
                            .direct("What do you remember after that?", "\"Holding my hands on {VL}'s chest and screaming at the 911 operator. {VL} kept trying to talk. I don't know what {VL} was trying to say.\""),
                            .cross("You saw the buyer's face for a few seconds?", "\"A few seconds, with the light on, from about three feet.\""),
                            .cross("And at the lineup you said 'pretty sure'?", "\"I said pretty sure because I didn't want to get it wrong. I picked who I saw.\"")
                        ]),
            WitnessSeed(name: "{DET}", role: "Homicide detective",
                        direct: ["\"The account, the phone, the shoes, and the gun all lead to {DL}.\""],
                        cross: ["\"We looked for a Dre. We never found one tied to this.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("Whose was the buyer account?", "\"Created three days before with {DL}'s phone number, and every login came from {DL}'s phone.\""),
                            .direct("Where was that phone at 8:40 p.m.?", "\"Its location data, by warrant, puts it within forty meters of the parking lot from 8:36 to 8:44, and then heading back toward {DL}'s apartment.\""),
                            .direct("What did you find in the apartment?", "\"In {DL}'s bedroom closet, the size 11 shoes in a box with {VL}'s handwritten label, number 47, and a backpack with a 9mm pistol in it.\""),
                            .cross("{DL} told you a man named Dre borrowed the phone.", "\"Yes. {DL} couldn't give us a last name, a number, or an address. We checked {DL}'s contacts and messages for anyone called Dre and found no one.\""),
                            .cross("Did you test the backpack for DNA?", "\"Yes. {DL}'s DNA was on the straps. No one else's was found.\"")
                        ]),
            WitnessSeed(name: nil, role: "Firearms examiner, State Crime Laboratory",
                        direct: ["\"Both casings and the bullet came from that pistol.\""],
                        cross: ["\"I can't tell you who pulled the trigger.\""],
                        weight: 3, lay: false,
                        exam: [
                            .direct("What did you compare?", "\"Two 9mm casings from the back seat of {VL}'s car and the bullet from the autopsy, against test fires from the pistol in the backpack.\""),
                            .direct("And your conclusion?", "\"All three were fired from that pistol, to the exclusion of other firearms.\""),
                            .cross("Your work says nothing about who fired it?", "\"Correct. Only which gun.\"")
                        ]),
            WitnessSeed(name: nil, role: "Forensic pathologist, Office of the Chief Medical Examiner",
                        direct: ["\"A gunshot wound to the chest, through the heart.\""],
                        cross: ["\"Close range, a few feet.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("What was the cause of death?", "\"A gunshot wound to the chest. The bullet passed through the heart. A second shot missed.\""),
                            .direct("Could {VL} have survived?", "\"With that injury, almost no one does. {VL} lived about an hour.\""),
                            .cross("Can you tell the range?", "\"Close. A few feet, consistent with someone in the back seat.\"")
                        ])
        ],
        defenseWitnesses: [
            WitnessSeed(name: nil, role: "{DL}'s cousin",
                        direct: ["\"There was a guy called Dre around that week.\""],
                        cross: ["\"I don't know his last name.\""],
                        weight: 1, lay: true,
                        exam: [
                            .direct("Who is Dre?", "\"A guy who was around {DL}'s place a few times that week. Tall, always had a backpack.\""),
                            .direct("Were you at the apartment on the night of the shooting?", "\"No. I was there the day before.\""),
                            .cross("What's Dre's last name?", "\"I don't know.\""),
                            .cross("Phone number? Where he lives?", "\"No. I just know him as Dre.\""),
                            .cross("So you can't say who had {DL}'s phone at 8:40 that night?", "\"No, I can't.\"")
                        ])
        ],
        prosecutionTheory: ["{D} set up the meeting on {D.his} own phone, went there with a pistol, killed {V} over a box of shoes, and took the shoes home to {D.his} closet."],
        defenseTheory: ["A rushed photo lineup and a man called Dre who had {DL}'s phone that night. Everything found in the apartment could have been left there."],
        aggravating: ["The defendant was armed with a deadly weapon", "The offense was committed for pecuniary gain"],
        mitigating: ["The defendant was young at the time of the offense"],
        victimImpacts: ["{VL}'s mother: \"{VL} labeled every box by hand and kept a notebook of every sale, saving for a four-year school. I have that notebook. The last line is number 47.\"", "{VL}'s younger sibling: \"I still text {VL}'s phone. I know nobody's going to answer.\""],
        allocutions: ["\"I'm sorry for that family. I didn't kill anyone.\""],
        guiltyTruths: ["A jail call recorded after the arrest captured {DL} telling a friend, \"I told {V.him} to let go of the box.\""],
        innocentTruths: ["A man known as Dre was arrested months later in a second app robbery with an identical pistol, and a witness placed him with {DL}'s phone the night {V} was killed."],
        moods: [.wantsConviction], doctrines: ["burdenOfProof", "eyewitnessID", "expertTestimony"],
        story: StoryExtras(
            timeline: [(-3, "Buyer account created with {DL}'s phone number."), (0, "8:40 p.m. meeting in the apartment lot; {V} shot. 9:52 p.m. {V} dies at the hospital."), (1, "Autopsy; app records requested by warrant."), (2, "Photo lineup; {VL}'s friend picks {DL}. Search warrant at {DL}'s apartment; shoes and pistol seized; {DL} arrested."), (40, "Firearms comparison links the pistol to both casings and the bullet.")],
            howIdentified: "App records tying the buyer account to {DL}'s phone, then the photo lineup.",
            notDone: [],
            defendantExam: [
                .direct("Where were you at 8:40 that night?", "\"At my apartment. Dre had my phone because his was broken.\""),
                .direct("How did the shoes get in your closet?", "\"Dre brought them by the next morning with that backpack and said he'd come back for them.\""),
                .cross("You don't know Dre's last name, number, or address.", "\"I knew him from around. That's how it is.\""),
                .cross("The account was made with your number three days earlier.", "\"Dre had my phone a lot that week.\""),
                .cross("Your DNA is on the backpack straps, and no one else's.", "\"I moved it to the closet. That's all.\"")
            ],
            prosecutionOpening: "{V} came to sell a pair of shoes. {DL} came with a gun.",
            defenseOpening: "A frightened witness who was only pretty sure, and a man named Dre the police never found.",
            prosecutionClosing: "The account, the phone, the label in {VL}'s handwriting, and the gun. Dre is a name with no last name, no number, and no trace.",
            defenseClosing: "Things in an apartment and a phone in someone's hand don't tell you who was in that back seat.",
            victimDied: true,
            victim: VictimFacts(age: 19, occupation: "Community college student who resold sneakers", relationship: "None; met through a resale app", family: "Lived with a parent and a younger sibling"),
            time: "8:40 p.m.",
            family: "Single, no children.",
            residence: "An apartment about four miles from the apartment complex where {V} was shot"
        )
    )
}
