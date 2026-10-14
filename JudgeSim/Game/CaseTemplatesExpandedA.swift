import Foundation

private typealias E = EvidenceSeed

extension CaseTemplates {
    static let expandedA: [CaseTemplate] = [

        CaseTemplate(
            key: "dvStrangulation", category: .violent,
            headlines: ["The Kitchen on {STREET}", "The Victim Wants the Charges Dropped"],
            primaryLaw: "strangulation", lesserLaw: "assaultFemale", threshold: 9, lesserThreshold: 7,
            specification: "Assaulted {V}, inflicting physical injury by strangulation.",
            secondary: [SecondaryCharge(lawID: "dvpoViolation", specification: "Knowingly violated an ex parte domestic violence protective order by contacting {V}.", chance: 0.3, threshold: 0)],
            ageRange: 22...50, hasVictim: true,
            summaries: [
                "Deputies answered a 911 hang-up at a duplex on {STREET} and found {V} with red marks across the neck and a broken lamp on the kitchen floor. {V} said {D}, a live-in partner of four years, had choked them. A week later, {VL} asked the District Attorney to drop the case.",
                "A neighbor called 911 after hearing screaming through the wall. {V} told the responding deputy that {D} pinned them against the refrigerator by the throat. At the probable cause hearing, {VL} said they had \"overreacted.\"",
                "{V} walked into the Magistrate's office at 2 a.m. with a hoarse voice and petechiae in both eyes and swore out a warrant against {D}. By trial, the couple had reconciled."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "SANE Nurse Exam", "Petechiae in both eyes, a hoarse voice, and linear bruising on both sides of the neck, documented within three hours."),
                E(.video, 4, "Bodycam Statement", "On the deputy's bodycam, {V}, crying: \"{DL}'s hands were on my throat. I couldn't breathe.\""),
                E(.document, 3, "Prior 911 Calls", "Two prior calls from the same address in the past year, both closed without arrest."),
                E(.digital, 3, "Apology Texts", "From {DL}'s phone that night: \"im sorry i lost it. it wont happen again. please dont call them\"", .search),
                E(.statement, 3, "Statement to Deputy", "\"We were both yelling. I grabbed {VL} to calm things down, that's it.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 3, "Victim's Affidavit of Non-Prosecution", "A notarized affidavit from {V}: \"I exaggerated because I was angry. I want this dropped.\""),
                E(.document, 2, "Scratches on Defendant", "Booking photos show fresh scratches on {DL}'s forearms."),
                E(.document, 2, "Alcohol Level", "The deputy noted {V} had been drinking heavily that night.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Sexual assault nurse examiner",
                            direct: ["\"Petechiae like these come from pressure on the neck that blocks blood flow. It takes force, and it takes time.\""],
                            cross: ["\"I can't tell you who applied the pressure. Only that someone did.\""],
                            weight: 2, lay: false),
                WitnessSeed(name: "{OFF}", role: "Responding officer",
                            direct: ["\"{VL} could barely speak above a whisper. There were marks on both sides of the neck.\""],
                            cross: ["\"Yes, {DL} had scratches too. {DL} said they were from {VL}.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: "{V}", role: "Complainant, called by the defense",
                            direct: ["\"I was drunk and angry. I said things to get {DL} in trouble. I don't want this.\""],
                            cross: ["\"I don't remember what I told the officer. I don't remember the nurse.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["Strangulation is the most dangerous warning sign there is. The recantation doesn't erase the petechiae, the bodycam, or the apology."],
            defenseTheory: ["Two people had a drunken fight, and the only person who saw it says it didn't happen the way the State claims."],
            aggravating: ["Committed in the presence of a child", "History of domestic violence calls to the residence"],
            mitigating: ["The victim requests leniency", "The defendant has enrolled in an abuser treatment program"],
            victimImpacts: ["{V}, reading from a note: \"I just want us to move on. Please don't take {DL} away from the kids.\"", "{V}'s sister: \"{VL} is going to defend {DL} until the day that's no longer possible. Please hear what {VL} said that night, not what {VL} is saying now.\""],
            guiltyTruths: ["Eight months later, deputies were called to the same duplex again. This time {V} was hospitalized."],
            innocentTruths: ["{V} later told a victim advocate that the marks came from a fall during a fight that {VL} started, and that {DL} had only pushed {VL} away."],
            moods: [.divided, .wantsConviction],
            doctrines: ["hearsayExceptions", "selfDefense", "lesserIncluded"]
        ),

        CaseTemplate(
            key: "catalyticConverters", category: .property,
            headlines: ["Sawzall at Midnight", "The Converter Ring"],
            primaryLaw: "possStolen", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Possessed {COUNT} catalytic converters, knowing or having reason to believe they were stolen.",
            secondary: [SecondaryCharge(lawID: "felonyLarceny", specification: "Larceny of a catalytic converter from a vehicle at {LOT}.", chance: 0.6, threshold: 0)],
            ageRange: 19...45, hasVictim: false,
            summaries: [
                "A Hollis County deputy stopped a van with a broken taillight at {TIME} and found {COUNT} catalytic converters in the back, along with a battery-powered reciprocating saw. Fourteen vehicles at {LOT} had their converters cut off that week.",
                "A scrap yard in {HOOD} called police when {D} tried to sell {COUNT} catalytic converters without a business license. Several had fresh cut marks and road grime.",
                "After a rash of converter thefts at {LOT}, detectives set up a camera. Three nights later, a person matching {D}'s description crawled under a delivery truck."
            ],
            prosecutionEvidence: [
                E(.physical, 4, "The Converters", "{COUNT} catalytic converters, three with fresh saw cuts and VIN fragments matching vehicles reported stolen from.", .search),
                E(.physical, 3, "Reciprocating Saw", "A cordless saw with metal shavings in the blade guard.", .search),
                E(.video, 3, "Lot Camera", "A hooded figure sliding under a box truck at {LOT} at 1:40 a.m. The face is not visible."),
                E(.document, 3, "Scrap Yard Records", "{DL} sold 31 converters in four months, never with documentation of where they came from."),
                E(.statement, 2, "Roadside Statement", "\"I buy them off people. I don't ask where they come from.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 3, "Muffler Shop Receipts", "{DL} worked part-time at a muffler shop that legitimately replaces converters."),
                E(.document, 2, "Borrowed Van", "The van belongs to a coworker who also uses it."),
                E(.document, 2, "Price Paid", "Texts show {DL} paid near-market prices, which is inconsistent with knowing they were stolen.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{DET}", role: "Property crimes investigator",
                            direct: ["\"Fresh cuts, road grime, no paperwork, and three converters matched to reported thefts. Legitimate shops don't operate that way.\""],
                            cross: ["\"No, I can't match most of the converters to specific victims.\""],
                            weight: 2, lay: false),
                WitnessSeed(name: nil, role: "Fleet manager at the victim business",
                            direct: ["\"Fourteen trucks out of service in a week. Twenty-two thousand dollars in repairs.\""],
                            cross: ["\"I never saw who did it.\""],
                            weight: 1, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Muffler shop owner",
                            direct: ["\"{DL} hauls our old converters to scrap. Has for two years.\""],
                            cross: ["\"No, we didn't send {DL} with fourteen in one week.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["{D} wasn't a buyer. {D} was the one under the trucks with the saw."],
            defenseTheory: ["Scrap metal is a legal business. The State has a van full of parts and no proof {DL} knew they were stolen."],
            aggravating: ["The offense involved damage causing great monetary loss", "Part of an organized pattern of thefts"],
            mitigating: ["The defendant has a positive employment history", "Restitution has been partially paid"],
            guiltyTruths: ["A co-defendant arrested in another county later named {DL} as the one who did the cutting."],
            innocentTruths: ["The coworker who owned the van, {ALT}, was caught a month later cutting converters at the same lot."],
            moods: [.wantsConviction, .indifferent],
            doctrines: ["searchSeizure", "warrantExceptions"],
            extras: ["COUNT": ["nine", "fourteen", "six"],
                     "LOT": ["the Hollis Transit depot", "a church parking lot in Wexley", "the U-Haul lot on Harbor Street"]]
        ),

        CaseTemplate(
            key: "carBreakIns", category: .property,
            headlines: ["The Apartment Lot Break-Ins", "Tried Every Door Handle"],
            primaryLaw: "breakingVehicle", lesserLaw: nil, threshold: 8, lesserThreshold: 8,
            specification: "Broke and entered a vehicle at {COMPLEX} containing things of value, with intent to commit larceny.",
            secondary: [SecondaryCharge(lawID: "misdLarceny", specification: "Stole {ITEM} from the vehicle.", chance: 0.7, threshold: 0)],
            ageRange: 17...28, hasVictim: true,
            summaries: [
                "Residents of {COMPLEX} woke to find a dozen cars rummaged through. A doorbell camera caught someone trying door handles at {TIME}. {D} was stopped two blocks away with {ITEM}.",
                "{V}'s car window was smashed in the {COMPLEX} parking lot and {ITEM} taken. A fingerprint from the door frame came back to {D}."
            ],
            prosecutionEvidence: [
                E(.video, 3, "Doorbell Camera", "A slim figure in a dark hoodie checking door handles down a row of cars."),
                E(.physical, 4, "Property Recovered", "{ITEM} found in {DL}'s backpack during a pat-down.", .search),
                E(.forensic, 4, "Latent Print", "A print on the inside of the driver's door frame matches {DL}."),
                E(.statement, 2, "Statement to Officer", "\"I found that bag on the sidewalk.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 2, "Visitor", "{DL} has a friend who lives at {COMPLEX} and visits often."),
                E(.document, 2, "Doorbell Quality", "The camera footage is low-resolution and the person is never identified.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Car owner",
                            direct: ["\"My {ITEM} was on the passenger seat when I went to bed.\""],
                            cross: ["\"I may have left the car unlocked. I'm not sure.\""],
                            weight: 1, lay: true),
                WitnessSeed(name: "{OFF}", role: "Patrol officer",
                            direct: ["\"{DL} was walking away from {COMPLEX} at 3 a.m. and changed direction when my car turned the corner.\""],
                            cross: ["\"Walking at 3 a.m. isn't a crime, no.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s friend at {COMPLEX}",
                            direct: ["\"{DL} left my place around 2:45. We'd been playing video games.\""],
                            cross: ["\"I was asleep by the time {DL} actually left, I think.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["The print, the property, and the timing. {D} went car to car until a door opened."],
            defenseTheory: ["{DL} found a bag and picked it up. The print could be from any visit to a friend's lot."],
            aggravating: ["Multiple vehicles entered", "The defendant was on pretrial release"],
            mitigating: ["Youth", "The defendant has no prior criminal record", "Property returned"],
            victimImpacts: ["{V}: \"It's not the stuff. It's that I don't feel safe walking to my car anymore.\""],
            guiltyTruths: ["A phone recovered later held photos of the inside of four of the cars, timestamped that night."],
            innocentTruths: ["Another resident of {COMPLEX}, {ALT}, was arrested a week later with property from six of the cars."],
            moods: [.indifferent, .wantsConviction],
            doctrines: ["searchSeizure", "warrantExceptions"],
            extras: ["COMPLEX": ["the Riverbend Apartments", "Cedar Hill Commons", "the Harbor Point complex"],
                     "ITEM": ["a laptop bag", "a pair of AirPods and $60 in cash", "a handgun in a case"]]
        ),

        CaseTemplate(
            key: "purseSnatch", category: .robbery,
            headlines: ["Grocery Store Parking Lot", "Dragged Across the Lot"],
            primaryLaw: "commonLawRobbery", lesserLaw: "felonyLarceny", threshold: 8, lesserThreshold: 6,
            specification: "Took a purse from the person of {V}, 78, by violence.",
            ageRange: 18...35, hasVictim: true,
            summaries: [
                "{V}, 78, was loading groceries outside {STORE} when someone grabbed {VL}'s purse. {VL} held on and was dragged several feet, breaking a wrist. {D} was arrested after using {VL}'s debit card at a gas station.",
                "Outside {STORE}, a person on a bicycle yanked {V}'s purse away and pedaled off. {V}, 78, fell and fractured a hip. The stolen credit card was used an hour later by {D}."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Gas Station Video", "{DL} using {VL}'s debit card at a pump forty minutes after the robbery."),
                E(.video, 3, "Store Lot Camera", "A distant figure grabbing a purse and fleeing. Clothing resembles what {DL} wore at the gas station."),
                E(.forensic, 3, "Medical Records", "{V} suffered a fractured wrist and bruising requiring surgery."),
                E(.physical, 3, "The Purse", "Found in a dumpster behind {DL}'s apartment building, wallet missing.", .none)
            ],
            defenseEvidence: [
                E(.document, 3, "Card Purchase Story", "{DL} told police a man at the gas station sold the card for $20."),
                E(.document, 2, "Different Shoes", "The lot camera shows white shoes; {DL} wore black boots at the pump.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Victim",
                            direct: ["\"I wouldn't let go. That was everything I had. I hit the pavement and heard my wrist snap.\""],
                            cross: ["\"No, I didn't see the face. It all happened so fast.\""],
                            weight: 2, lay: true),
                WitnessSeed(name: "{DET}", role: "Investigator",
                            direct: ["\"Forty minutes from the robbery to the pump. The card was used once and then never again.\""],
                            cross: ["\"We didn't find the wallet or the cash.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Gas station regular",
                            direct: ["\"There was a guy selling cards out by the air pump that night. I've seen him before.\""],
                            cross: ["\"I don't know his name. I couldn't pick him out.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["A 78-year-old broke bones holding onto a purse. Forty minutes later, {D} was using the card."],
            defenseTheory: ["Buying a stolen card is a crime. Robbing someone is a different crime. The State has proof of the first, not the second."],
            aggravating: ["The victim was very old", "The victim suffered serious injury"],
            mitigating: ["The defendant has a substance use disorder and has entered treatment", "The defendant accepted responsibility for using the card"],
            victimImpacts: ["{V}: \"I used to walk to church. Now my son drives me everywhere. I'm afraid of parking lots.\"", "{V}'s daughter: \"My parent hasn't been the same. Sleeps with the lights on now.\""],
            guiltyTruths: ["The wallet, with {VL}'s ID still inside, was later found in a storage unit rented by {DL}."],
            innocentTruths: ["The man selling cards at the gas station, {ALT}, was arrested for two more purse snatchings in Wexley."],
            moods: [.wantsConviction],
            doctrines: ["lesserIncluded", "burdenOfProof"],
            extras: ["STORE": ["the Food Lion on Pell Avenue", "Hollis Piggly Wiggly", "the Harris Teeter in Cedar Hill"]]
        ),

        CaseTemplate(
            key: "homeInvasion", category: .property,
            headlines: ["Someone Was Inside", "Awake at 3 A.M."],
            primaryLaw: "burglary1", lesserLaw: "feloniousBE", threshold: 7, lesserThreshold: 5,
            specification: "Broke and entered the occupied dwelling of {V} in the nighttime, with intent to commit larceny.",
            ageRange: 19...40, hasVictim: true,
            summaries: [
                "{V} woke at 3 a.m. to footsteps downstairs and found a stranger pulling a TV off the wall. The intruder ran out the back door. Police found {D} hiding in a shed two houses down.",
                "A family of four was asleep on {STREET} when someone pried open the back door. {V} confronted the intruder with a baseball bat. {D} was arrested at a nearby convenience store an hour later, cut on one hand."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "Blood on Door", "Blood on the pried back door matches {DL}'s DNA."),
                E(.physical, 3, "Pry Bar", "A pry bar found in the shed where {DL} was hiding.", .search),
                E(.document, 3, "Show-up Identification", "{V} identified {DL}, in handcuffs in the back of a patrol car, as the intruder."),
                E(.statement, 3, "Admission", "\"I thought nobody was home. I swear I thought it was empty.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 3, "Suggestive Show-up", "The only person shown to {V} was {DL}, handcuffed, under a spotlight."),
                E(.document, 2, "Intoxication", "{DL}'s blood alcohol was 0.19 at booking.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Homeowner",
                            direct: ["\"My kids were asleep upstairs. I've never been so scared in my life.\""],
                            cross: ["\"It was dark. I saw the person for maybe three seconds.\""],
                            weight: 2, lay: true),
                WitnessSeed(name: "{OFF}", role: "Responding officer",
                            direct: ["\"{DL} was crouched in the shed, breathing hard, with a fresh cut on the right hand.\""],
                            cross: ["\"I conducted the show-up because it's standard practice.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Eyewitness identification expert",
                            direct: ["\"A show-up of a handcuffed suspect is the most suggestive identification procedure there is.\""],
                            cross: ["\"The DNA is a different matter. I'm only talking about the identification.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["{D} pried open a family's back door at 3 a.m. That's first-degree burglary, exactly what the statute was written for."],
            defenseTheory: ["{DL} was drunk and thought the house was empty. Breaking in, yes. Into an occupied home with that knowledge, no."],
            aggravating: ["Children were present in the home", "The defendant was armed with a pry bar"],
            mitigating: ["The defendant's intoxication reduced culpability", "Nothing was taken"],
            victimImpacts: ["{V}: \"My eight-year-old asks every night if the bad person is coming back.\""],
            guiltyTruths: ["{DL} had cased the street for a week; a notebook with house numbers and \"dog?\" next to them was later found."],
            innocentTruths: ["{DL}'s blood on the door came from a cut earlier that night; the real intruder, {ALT}, was caught in a similar break-in a month later."],
            moods: [.wantsConviction],
            doctrines: ["lesserIncluded", "intoxication"]
        ),

        CaseTemplate(
            key: "driveByShooting", category: .violent,
            headlines: ["Shots on {STREET}", "Eleven Casings"],
            primaryLaw: "dischargingOccupied", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Discharged a firearm into an occupied dwelling on {STREET}.",
            ageRange: 17...30, hasVictim: true,
            summaries: [
                "Eleven shots hit a house on {STREET} where {V} was watching TV with two grandchildren. No one was hit. Detectives say {D} fired from a passing car over a social media feud with a grandson.",
                "A bullet passed through a child's bedroom wall on {STREET} at {TIME}. The home belongs to {V}. Police arrested {D} after a tip and a ShotSpotter alert."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "Shell Casings", "Eleven 9mm casings in the street, matched by NIBIN to a pistol found in {DL}'s girlfriend's car.", .search),
                E(.digital, 3, "Social Media Threats", "{DL}'s account posted, hours earlier: \"y'all gone learn tonight\" with the grandson's photo."),
                E(.digital, 3, "Phone Location", "{DL}'s phone was on {STREET} at the time of the shooting.", .search),
                E(.video, 2, "Doorbell Video", "A dark sedan slows; muzzle flashes from the passenger side. No faces visible.")
            ],
            defenseEvidence: [
                E(.document, 3, "Not the Driver or Shooter", "The sedan is registered to another person; {DL} says they lent the phone to a cousin that night."),
                E(.document, 2, "Gun Access", "At least three people had access to the car where the gun was found.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Homeowner",
                            direct: ["\"I put my body over the babies on the floor. I counted the shots. Eleven.\""],
                            cross: ["\"I don't know who was in the car.\""],
                            weight: 1, lay: true),
                WitnessSeed(name: "{DET}", role: "Gang and gun violence investigator",
                            direct: ["\"The post, the phone, the gun. They all point to {DL}.\""],
                            cross: ["\"No, we didn't get fingerprints off the gun.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s cousin",
                            direct: ["\"I had {DL}'s phone that night. Mine was broke.\""],
                            cross: ["\"No, I'm not saying I was the shooter.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} announced it online, then emptied a magazine into a house with children inside."],
            defenseTheory: ["A phone, a post, and a gun anyone could reach. That isn't proof of who pulled the trigger."],
            aggravating: ["The defendant knowingly created a great risk of death to more than one person", "Children were present"],
            mitigating: ["Youth", "The defendant has a support system in the community"],
            victimImpacts: ["{V}: \"My grandbabies won't sleep in the front room anymore. They sleep in the bathtub when they hear fireworks.\""],
            guiltyTruths: ["The driver, arrested months later, testified in federal court that {DL} fired every shot."],
            innocentTruths: ["The cousin, {ALT}, was later convicted of a second shooting with the same gun."],
            moods: [.wantsConviction],
            doctrines: ["searchSeizure", "expertTestimony"]
        ),

        CaseTemplate(
            key: "propertyLineShooting", category: .violent,
            headlines: ["The Fence Line", "Twenty Years of Feuding"],
            primaryLaw: "awdwikisi", lesserLaw: "awdwisi", threshold: 8, lesserThreshold: 6,
            specification: "Assaulted {V} with a shotgun, with intent to kill, inflicting serious injury.",
            ageRange: 50...78, hasVictim: true,
            summaries: [
                "Neighbors {D} and {V} had argued over a property line in rural {HOOD} for twenty years. When {VL} came over with a surveyor's stake and a shovel, {DL} fired a shotgun, hitting {VL} in the leg and hip.",
                "A survey dispute in {HOOD} ended with {V} airlifted to Chapel Hill with shotgun wounds. {D}, 71, says {VL} charged at them with a shovel raised."
            ],
            prosecutionEvidence: [
                E(.forensic, 4, "Shotgun Wound Pattern", "Wound spread indicates a distance of 20 to 25 feet, not close range."),
                E(.physical, 3, "Shotgun", "A 12-gauge recovered from {DL}'s porch, one shell spent."),
                E(.document, 3, "Prior Threats", "A magistrate's record of {DL} telling {VL} in 2019: \"Step on my land again and you'll leave in a bag.\""),
                E(.statement, 3, "911 Call", "{DL}: \"I shot the son of a bitch. Send somebody.\"")
            ],
            defenseEvidence: [
                E(.physical, 3, "The Shovel", "A shovel found near {VL}, blade raised in the photograph."),
                E(.document, 3, "Prior Assault by Victim", "{VL} was convicted of assaulting another neighbor in 2016."),
                E(.document, 2, "Defendant's Frailty", "{DL} has a hip replacement and walks with a cane.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Neighbor",
                            direct: ["\"I was putting in a survey stake on my own land. I never raised that shovel.\""],
                            cross: ["\"Yes, I was angry. Yes, I walked toward the porch.\""],
                            weight: 2, lay: true),
                WitnessSeed(name: nil, role: "State Crime Laboratory firearms examiner",
                            direct: ["\"The spread pattern puts the shooter twenty feet or more away.\""],
                            cross: ["\"Twenty feet is about two seconds if someone is running.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s spouse",
                            direct: ["\"{VL} was coming fast with that shovel up over the shoulder. I screamed.\""],
                            cross: ["\"I was inside at the window. I saw it through the curtain.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["Twenty years of threats, then {D} finally did what they had promised."],
            defenseTheory: ["A 71-year-old with a cane saw a neighbor charging with a raised shovel. North Carolina doesn't require you to wait to be hit."],
            aggravating: ["Prior threats against the victim"],
            mitigating: ["The defendant's age and physical infirmity", "The victim was the aggressor in prior incidents", "No prior criminal record"],
            victimImpacts: ["{V}: \"I'll walk with a limp the rest of my life over eleven feet of dirt.\""],
            guiltyTruths: ["A trail camera on {VL}'s side of the line later surfaced. It showed {VL} standing still, shovel down, when the shot came."],
            innocentTruths: ["The same trail camera showed {VL} running at the porch with the shovel overhead."],
            moods: [.divided, .indifferent],
            doctrines: ["selfDefense", "lesserIncluded", "priorActs"]
        ),

        CaseTemplate(
            key: "unsecuredGun", category: .violent,
            headlines: ["The Gun in the Nightstand", "Two Fourteen-Year-Olds"],
            primaryLaw: "invManslaughter", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Caused the death of a child through culpable negligence in leaving a loaded handgun accessible to minors.",
            secondary: [SecondaryCharge(lawID: "firearmStorage", specification: "Stored a loaded firearm where a minor was likely to gain access.", chance: 0.8, threshold: 0)],
            ageRange: 32...55, hasVictim: true,
            summaries: [
                "{D}'s 14-year-old found a loaded pistol in an unlocked nightstand and showed it to a friend, {V}. It went off. {V} died at the scene. {DL} had been warned by a family member to lock it up.",
                "Two teenagers were home alone at {D}'s house in {HOOD} when one picked up a loaded handgun from a kitchen drawer. {V}, 14, was shot and killed."
            ],
            prosecutionEvidence: [
                E(.physical, 4, "Unlocked Nightstand", "A loaded 9mm with a round chambered, in an unlocked drawer next to a child's backpack."),
                E(.digital, 3, "Warning Text", "{DL}'s sister, six months earlier: \"Please put a lock on that gun. The kids know where it is.\""),
                E(.document, 3, "Unopened Gun Lock", "A free cable lock from the Sheriff's Office, still in its package in the closet.", .search),
                E(.statement, 2, "Statement to Detective", "\"I thought my kid knew better. I taught them.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 3, "Firearm Training", "The child had completed a hunter safety course and was taught never to touch guns."),
                E(.document, 2, "Hidden Location", "The gun was under clothing in a closed drawer in the parents' bedroom.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{DET}", role: "Investigator",
                            direct: ["\"There was a gun lock in the closet that had never been opened.\""],
                            cross: ["\"No, there's no evidence {DL} knew the kids were home alone with access.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Neighbor and family friend",
                            direct: ["\"{DL} is the most careful parent I know. This could've happened in half the houses on this street.\""],
                            cross: ["\"I didn't know where {DL} kept the gun.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} was warned, had a lock in the closet, and left a loaded gun where children would find it. A child is dead."],
            defenseTheory: ["This is a tragedy, not a crime. {DL} is already serving the worst sentence there is: their own child lives with this."],
            aggravating: ["The defendant was specifically warned"],
            mitigating: ["Deep remorse", "No prior criminal record", "The defendant has surrendered all firearms"],
            victimImpacts: ["{VL}'s mother: \"I don't want {DL} in prison. I want every parent who hears about this to lock up their gun.\"", "{VL}'s father: \"My child went over to play video games. Somebody has to answer for that.\""],
            guiltyTruths: ["{DL}'s spouse later told investigators they'd argued about locking the gun the very week before."],
            innocentTruths: ["It emerged that a relative visiting that weekend had taken the gun out of the locked safe and left it in the drawer."],
            moods: [.divided, .sympathetic],
            doctrines: ["burdenOfProof"]
        ),

        CaseTemplate(
            key: "fleeingElude", category: .traffic,
            headlines: ["110 on the Bypass", "The Chase"],
            primaryLaw: "fleeing", lesserLaw: nil, threshold: 7, lesserThreshold: 7,
            specification: "Fled a law enforcement officer in a motor vehicle at more than 15 mph over the limit while driving recklessly and with a revoked license.",
            secondary: [SecondaryCharge(lawID: "resisting", specification: "Ran from officers after the vehicle stopped.", chance: 0.6, threshold: 0)],
            ageRange: 18...35, hasVictim: false,
            summaries: [
                "A deputy tried to stop a sedan for a broken headlight on the {ROAD}. The driver accelerated to 110 mph, ran two red lights, and crashed into a ditch in {HOOD}. {D} was found hiding in a cornfield.",
                "A Highway Patrol trooper clocked a car at 92 in a 55 near {HOOD}. The car fled for eleven miles. {D}, whose license was revoked, was arrested after the car ran out of gas."
            ],
            prosecutionEvidence: [
                E(.video, 5, "Dashcam", "Eleven minutes of pursuit footage: speeds over 100, two red lights, oncoming traffic swerving."),
                E(.document, 3, "Revoked License", "DMV record: {DL}'s license was revoked for a prior DWI."),
                E(.forensic, 2, "Crash Data", "The car's event data recorder shows 108 mph four seconds before the crash."),
                E(.statement, 2, "Statement", "\"I panicked. I've got a revoked license and I didn't want to go back to jail.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 3, "Identity Dispute", "The car belongs to {DL}'s cousin; no one saw the driver's face during the chase."),
                E(.document, 2, "Pursuit Policy", "The deputy's pursuit for a headlight violated department policy.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{TROOPER}", role: "Pursuing officer",
                            direct: ["\"I lost sight of the car for about ninety seconds before the crash. When I got there, the driver's door was open and footprints led into the corn.\""],
                            cross: ["\"No, I never saw the driver's face.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Former police pursuit trainer",
                            direct: ["\"No department policy I know of allows a 100-mile-an-hour chase over a headlight.\""],
                            cross: ["\"Policy violations by the officer don't change what the driver did.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["{D} chose to put every driver on that road at risk instead of taking a ticket."],
            defenseTheory: ["Nobody saw who was driving, and the officer turned a headlight into a high-speed chase."],
            aggravating: ["The defendant knowingly created a great risk of death to more than one person"],
            mitigating: ["Youth", "No one was injured"],
            guiltyTruths: ["{DL}'s phone, found in the car's console, had been unlocked and in use during the chase."],
            innocentTruths: ["{DL}'s cousin, {ALT}, later admitted being the driver and that {DL} was asleep in the back seat."],
            moods: [.indifferent, .wantsConviction],
            doctrines: ["burdenOfProof"],
            extras: ["ROAD": ["U.S. 17 bypass", "N.C. 87", "Old Quarry Road"]]
        ),

        CaseTemplate(
            key: "schoolThreat", category: .publicOrder,
            headlines: ["The Snapchat Post", "Lockdown at Hollis High"],
            primaryLaw: "massViolenceThreat", lesserLaw: "communicatingThreats", threshold: 5, lesserThreshold: 3,
            specification: "Communicated a threat to commit an act of mass violence at {SCHOOL}.",
            ageRange: 18...19, hasVictim: false,
            summaries: [
                "At 6:40 a.m., a post appeared on a student group chat: \"dont come to school tmrw. im serious. bringing the AR.\" {SCHOOL} locked down and 1,200 students were sent home. The post came from {D}, a senior.",
                "{D}, 18, posted a photo of a rifle with the caption \"{SCHOOL} gonna remember my name.\" Deputies arrested {DL} that night. No gun was found in the home."
            ],
            prosecutionEvidence: [
                E(.digital, 5, "The Post", "Screenshots of the post, with metadata tied to {DL}'s account and phone."),
                E(.digital, 3, "Search History", "Searches for \"school shooting body count\" in the week before.", .search),
                E(.document, 2, "School Disruption", "The district reports a lockdown, a closed day, and over 300 parent calls."),
                E(.statement, 2, "Interview", "\"It was a joke. Everybody posts stuff like that.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 3, "No Weapon Access", "No firearm in the home or access to one; the rifle photo was a stock image."),
                E(.document, 3, "Psychological Evaluation", "A psychologist found no violent intent and diagnosed social anxiety and depression."),
                E(.digital, 2, "Context", "The group chat was full of exaggerated threats and memes; others posted similar jokes.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "School resource officer",
                            direct: ["\"We have to treat every one of these as real. We don't get to find out the hard way.\""],
                            cross: ["\"No, {DL} had no prior discipline record.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Forensic psychologist",
                            direct: ["\"This was a bid for attention from an isolated kid, not a plan.\""],
                            cross: ["\"I can't promise anyone what someone will or won't do.\""],
                            weight: 2, lay: false)
            ],
            prosecutionTheory: ["{D} terrified a whole community. Whether it was a joke doesn't matter; the statute punishes the threat."],
            defenseTheory: ["A depressed teenager posted something stupid. The law requires a true threat, and this wasn't one."],
            aggravating: ["The offense caused a school-wide lockdown and closure"],
            mitigating: ["Youth: the defendant is 18", "The defendant has a mental condition that reduced culpability", "No prior record"],
            guiltyTruths: ["A notebook later found under {DL}'s mattress had a hand-drawn map of the school cafeteria."],
            innocentTruths: ["Classmates later admitted they had dared {DL} to post it."],
            moods: [.divided, .wantsConviction],
            doctrines: ["lesserIncluded", "burdenOfProof"],
            extras: ["SCHOOL": ["Hollis High School", "Wexley Senior High", "Cane Creek Early College"]]
        ),

        CaseTemplate(
            key: "officerInjured", category: .violent,
            headlines: ["The Bar Fight Arrest", "Broken Finger, Bloody Lip"],
            primaryLaw: "assaultLEO", lesserLaw: "resisting", threshold: 4, lesserThreshold: 2,
            specification: "Assaulted {OFF}, a law enforcement officer performing official duties, inflicting physical injury.",
            ageRange: 21...40, hasVictim: false,
            summaries: [
                "Called to a fight outside a bar in {HOOD}, {OFF} tried to arrest {D}. In the struggle, the officer's finger was broken. {DL} says the officer tackled first and hard.",
                "During a traffic stop, {D} refused to get out of the car. {OFF} pulled {DL} out; the officer's lip was split by an elbow. Bodycam footage is partially obscured."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Bodycam", "The camera shows {DL}'s elbow swinging back into the officer's face, then the feed goes dark when the officer falls."),
                E(.forensic, 3, "Officer's Injuries", "A fractured finger and a split lip, treated at Hollis Regional."),
                E(.statement, 2, "Statement at Booking", "\"The officer grabbed me first. I didn't know it was a cop.\"", .statement)
            ],
            defenseEvidence: [
                E(.video, 3, "Bystander Video", "A cell phone video shows the officer tackling {DL} without any warning given."),
                E(.forensic, 2, "Defendant's Injuries", "{DL} suffered a concussion and two cracked ribs.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{OFF}", role: "Arresting officer",
                            direct: ["\"I gave three commands. {DL} pulled away and swung an elbow into my face.\""],
                            cross: ["\"I was in full uniform. I'm sure I identified myself.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Bystander who filmed the arrest",
                            direct: ["\"The cop came out of nowhere and slammed {DL}. I didn't hear anybody say police.\""],
                            cross: ["\"It was loud out there. People were yelling.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["Officers have to be able to do their job without being assaulted for it."],
            defenseTheory: ["If you get tackled from behind without warning, flailing isn't an assault. It's a reflex."],
            aggravating: ["The offense was committed against a law enforcement officer"],
            mitigating: ["The defendant was himself seriously injured", "No prior record"],
            guiltyTruths: ["A second officer's bodycam, released later, showed {DL} turning and deliberately throwing the elbow."],
            innocentTruths: ["The second officer's footage showed the tackle came first, with no command given."],
            moods: [.divided],
            doctrines: ["selfDefense", "lesserIncluded"]
        ),

        CaseTemplate(
            key: "dmvClerkAssault", category: .violent,
            headlines: ["Number 47", "The DMV Line"],
            primaryLaw: "assaultGovOfficial", lesserLaw: "simpleAssault", threshold: 5, lesserThreshold: 3,
            specification: "Assaulted {V}, an employee of the N.C. Division of Motor Vehicles, while {VL} was discharging official duties.",
            ageRange: 30...70, hasVictim: true,
            summaries: [
                "After a four-hour wait at the Port Hollis DMV office, {D} was told the paperwork was incomplete. {DL} reached across the counter and shoved {V}, a clerk, into a filing cabinet.",
                "{D} threw a clipboard at DMV examiner {V} after failing a road test for the third time. It struck {VL} in the face."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Office Camera", "Overhead footage of {DL} reaching across the counter and shoving {V}."),
                E(.document, 2, "Injury Report", "{V} was treated for a bruised shoulder."),
                E(.statement, 2, "Statement", "\"Four hours. FOUR hours. I lost my temper.\"", .statement)
            ],
            defenseEvidence: [
                E(.document, 2, "Medical Condition", "{DL} had not eaten in eight hours and is diabetic; low blood sugar can cause irritability."),
                E(.document, 1, "Apology Letter", "{DL} wrote a letter of apology to {V} the next day.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "DMV clerk",
                            direct: ["\"I've worked that counter nineteen years. I've been cussed at plenty. I've never been put on the floor.\""],
                            cross: ["\"Yes, I told {DL} to come back another day. Maybe I said it short.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Another customer in line",
                            direct: ["\"It was more of a reach than a shove. The clerk stumbled.\""],
                            cross: ["\"I was about twenty feet back.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["Public servants deserve protection from people who take their frustration out on them."],
            defenseTheory: ["A sick, exhausted person lost their temper for two seconds and apologized the next day."],
            aggravating: ["The victim was a public employee performing duties"],
            mitigating: ["The defendant apologized and accepted responsibility", "No prior record"],
            victimImpacts: ["{V}: \"I don't want {DL} in jail. I want people to remember there's a person behind the counter.\""],
            guiltyTruths: ["The DMV later disclosed {DL} had been banned from another office for a similar outburst."],
            innocentTruths: ["Medical records later confirmed {DL} had a hypoglycemic episode and was taken to urgent care that afternoon."],
            moods: [.indifferent],
            doctrines: ["lesserIncluded"]
        ),

        CaseTemplate(
            key: "trapHouse", category: .drugs,
            headlines: ["The House on {STREET}", "Forty Visitors a Day"],
            primaryLaw: "maintainingDwelling", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Knowingly kept and maintained a dwelling on {STREET} used for keeping and selling controlled substances.",
            secondary: [SecondaryCharge(lawID: "pwisd", specification: "Possessed cocaine with intent to sell or deliver.", chance: 0.6, threshold: 0)],
            ageRange: 22...55, hasVictim: false,
            summaries: [
                "Neighbors on {STREET} complained for months about cars stopping for two minutes at a time. After two controlled buys, a search warrant turned up cocaine, scales, and $3,100 in a house where {D} is on the lease.",
                "A narcotics task force raided a rental house in {HOOD}. Three people were inside; {D}'s name is on the utilities."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Lease and Utilities", "{DL} is the sole leaseholder and pays the power bill."),
                E(.physical, 4, "Search Results", "Cocaine in a kitchen cabinet, two scales, and $3,100 in a shoebox.", .search),
                E(.video, 3, "Pole Camera", "Thirty-eight short visits in one day, documented by a pole camera across the street."),
                E(.document, 2, "Controlled Buys", "A confidential informant made two purchases at the front door.")
            ],
            defenseEvidence: [
                E(.document, 3, "Defendant Moved Out", "{DL} moved in with a partner in Wexley three months earlier but stayed on the lease."),
                E(.document, 2, "Other Occupants", "Two other people with drug convictions were living there.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{DET}", role: "Narcotics task force agent",
                            direct: ["\"This is what we call a trap house. Short visits, constant traffic, product and money on site.\""],
                            cross: ["\"{DL} wasn't present for either controlled buy.\""],
                            weight: 2, lay: false),
                WitnessSeed(name: nil, role: "Neighbor",
                            direct: ["\"Cars all night. Kids couldn't play outside.\""],
                            cross: ["\"I couldn't tell you who lived there.\""],
                            weight: 1, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s landlord",
                            direct: ["\"{DL} called me in the spring to ask how to get off the lease.\""],
                            cross: ["\"No, {DL} never actually signed anything to end it.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["{D}'s name, {D}'s house, {D}'s responsibility."],
            defenseTheory: ["A name on a lease doesn't mean {DL} knew what other people were doing in a house {DL} had left."],
            aggravating: ["The dwelling was near a school or park"],
            mitigating: ["The defendant has a positive employment history"],
            guiltyTruths: ["A ledger later recovered from {DL}'s car listed customers and amounts owed."],
            innocentTruths: ["One of the occupants, {ALT}, pleaded guilty in federal court and said {DL} hadn't been there in months."],
            moods: [.wantsConviction, .indifferent],
            doctrines: ["searchSeizure", "warrantExceptions"]
        ),

        CaseTemplate(
            key: "caregiverExploitation", category: .whiteCollar,
            headlines: ["The Home Health Aide", "Power of Attorney"],
            primaryLaw: "exploitationElder", lesserLaw: nil, threshold: 7, lesserThreshold: 7,
            specification: "As caregiver to {V}, 88, knowingly used their funds by deception, totaling {AMT}.",
            ageRange: 30...60, occupations: ["home health aide", "caregiver"], hasVictim: true,
            summaries: [
                "{D} cared for {V}, 88, five days a week for three years. When {VL}'s son reviewed the accounts after a fall, {AMT} had gone to {DL} through checks, a car purchase, and a power of attorney {VL} doesn't remember signing.",
                "A bank teller flagged repeated large withdrawals from the account of {V}, 88, who has dementia. The withdrawals were made by {D}, the live-in caregiver, under a power of attorney."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Bank Records", "{AMT} in checks and transfers to {DL} over 20 months."),
                E(.document, 3, "Power of Attorney", "Signed two weeks after {V} was diagnosed with moderate dementia."),
                E(.document, 3, "Car Purchase", "A used SUV bought with a check drawn on {VL}'s account, titled to {DL}."),
                E(.document, 2, "Neurologist Notes", "\"Patient lacks capacity for complex financial decisions.\"")
            ],
            defenseEvidence: [
                E(.document, 3, "Gifts", "Handwritten notes from {V}: \"For my angel, for everything you do.\""),
                E(.document, 2, "Unpaid Overtime", "{DL} worked 60-hour weeks and was paid for 40.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "{VL}'s son",
                            direct: ["\"{VL} didn't know what year it was. There's no way {VL} gave away a car.\""],
                            cross: ["\"I lived in Charlotte. I visited a few times a year.\""],
                            weight: 2, lay: true),
                WitnessSeed(name: nil, role: "Bank fraud specialist",
                            direct: ["\"The pattern escalated over time. Classic exploitation.\""],
                            cross: ["\"Some of the early checks were small and could've been gifts.\""],
                            weight: 2, lay: false)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{VL}'s neighbor",
                            direct: ["\"{VL} adored {DL}. Said {DL} was more family than family.\""],
                            cross: ["\"I don't know anything about the money.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} took the trust of someone who couldn't protect themselves and turned it into a car and a bank account."],
            defenseTheory: ["A lonely person gave gifts to the only one who showed up. The family is angry they weren't the ones."],
            aggravating: ["The defendant took advantage of a position of trust", "The victim was very old and mentally infirm"],
            mitigating: ["The defendant has repaid part of the money", "No prior record"],
            victimImpacts: ["{VL}'s son: \"{VL} is in a facility on Medicaid now. That money was supposed to keep {VL} home.\""],
            guiltyTruths: ["A second elderly client of {DL}'s was found to have lost $40,000 the same way."],
            innocentTruths: ["A recording later surfaced of {V}, in a lucid moment, telling a lawyer to make sure {DL} got the car."],
            moods: [.wantsConviction],
            doctrines: ["victimRights", "burdenOfProof"],
            extras: ["AMT": ["$46,800", "$71,250", "$33,900"]]
        ),

        CaseTemplate(
            key: "contractorFraud", category: .whiteCollar,
            headlines: ["After the Hurricane", "Paid for a Roof Never Built"],
            primaryLaw: "falsePretenses", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "Obtained a {AMT} deposit from {V} by falsely representing that the defendant would repair storm damage.",
            ageRange: 28...60, occupations: ["roofing contractor", "home repair contractor"], hasVictim: true,
            summaries: [
                "After Hurricane Delphine, {D} went door to door in {HOOD} offering roof repairs. {V} paid a {AMT} deposit. {DL} never returned. Eleven other homeowners say the same.",
                "{D} took a {AMT} deposit from {V} for storm repairs, delivered a pile of shingles, and disappeared. {DL} says the business failed, not that it was a scam."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Pattern of Deposits", "Twelve deposits totaling $88,000 in three weeks; no permits pulled for any job."),
                E(.document, 3, "Unlicensed", "{DL} has no general contractor's license and an out-of-state business address that is a mailbox store."),
                E(.digital, 3, "Texts to Victim", "\"Crew coming Monday for sure!!\" sent four Mondays in a row.", .search),
                E(.document, 2, "Spending", "Deposits withdrawn as cash within days.")
            ],
            defenseEvidence: [
                E(.document, 3, "Partial Work", "Receipts show $14,000 in materials purchased for some jobs."),
                E(.document, 2, "Crew Quit", "Texts from {DL}'s crew chief quitting mid-month.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Homeowner",
                            direct: ["\"That was our insurance check. We've had a tarp on the roof since September.\""],
                            cross: ["\"Yes, some shingles were dropped off.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "{DL}'s former crew chief",
                            direct: ["\"We meant to do those jobs. It fell apart when the supplier backordered everything.\""],
                            cross: ["\"I quit because I wasn't getting paid either.\""],
                            weight: 2, lay: true)
            ],
            prosecutionTheory: ["{D} saw a disaster and a lot of desperate people with insurance checks."],
            defenseTheory: ["A failed business is a civil case. {DL} bought materials and tried."],
            aggravating: ["The offense involved multiple victims", "The offense took advantage of a declared disaster"],
            mitigating: ["The defendant made partial restitution"],
            victimImpacts: ["{V}: \"The mold came in through the roof. My granddaughter has asthma.\""],
            guiltyTruths: ["{DL} was arrested in South Carolina a year later after doing the same thing following another storm."],
            innocentTruths: ["Bankruptcy filings later showed {DL} had lost a house trying to keep the business afloat."],
            moods: [.wantsConviction],
            doctrines: ["victimRights"],
            extras: ["AMT": ["$7,500", "$12,000", "$4,800"]]
        ),

        CaseTemplate(
            key: "forgedChecks", category: .whiteCollar,
            headlines: ["The Stolen Checkbook", "Forty Checks"],
            primaryLaw: "uttering", lesserLaw: nil, threshold: 6, lesserThreshold: 6,
            specification: "Uttered forged checks drawn on the account of {V}, knowing them to be forged.",
            secondary: [SecondaryCharge(lawID: "identityTheft", specification: "Used {V}'s identifying information to open a credit account.", chance: 0.4, threshold: 0)],
            ageRange: 20...45, hasVictim: true,
            summaries: [
                "{V}'s checkbook was stolen from a mailbox. Over the next month, checks totaling $6,200 were cashed at four check-cashing stores. The ID used was {D}'s real driver's license.",
                "A teller at Hollis Federal Credit Union noticed {V}'s signature didn't match. {D} was standing at the window."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Check-Cashing Video", "{DL} at the counter cashing a check payable to {DL}, signed \"{V}.\""),
                E(.document, 3, "Handwriting Analysis", "A State Crime Laboratory document examiner says the signatures were probably written by {DL}."),
                E(.document, 3, "Endorsements", "Every check is endorsed by {DL} and deposited or cashed with {DL}'s ID.")
            ],
            defenseEvidence: [
                E(.document, 3, "Payment for Work", "{DL} says a man who called himself \"{VL}'s nephew\" paid {DL} with checks for yard work."),
                E(.document, 2, "Handwriting Limits", "The examiner's report says \"probably,\" the second-weakest conclusion on the scale.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: "{V}", role: "Account holder",
                            direct: ["\"I never wrote a single one of those checks. I don't even know this person.\""],
                            cross: ["\"I don't have a nephew, no.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Neighbor of the defendant",
                            direct: ["\"{DL} was doing yard work all over the neighborhood that month.\""],
                            cross: ["\"I never saw who paid {DL}.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["{D} cashed the checks with their own face and license. There's no mystery here."],
            defenseTheory: ["Who uses their own ID to commit forgery? {DL} was paid with bad checks and got used."],
            aggravating: ["The victim was very old"],
            mitigating: ["Restitution has been paid in full"],
            victimImpacts: ["{V}: \"My rent check bounced. I'm 74 and I had to borrow from my church.\""],
            guiltyTruths: ["Practice signatures of {VL}'s name were found in a notebook in {DL}'s car."],
            innocentTruths: ["A ring that recruited day laborers to cash forged checks was broken up the next year; {DL}'s name was on its list of people it had used."],
            moods: [.indifferent, .wantsConviction],
            doctrines: ["expertTestimony"]
        ),

        CaseTemplate(
            key: "employeeTheft", category: .whiteCollar,
            headlines: ["The Night Manager", "Short Every Friday"],
            primaryLaw: "embezzlement", lesserLaw: nil, threshold: 5, lesserThreshold: 5,
            specification: "As night manager of {BIZ}, fraudulently converted {AMT} in store deposits.",
            ageRange: 22...50, occupations: ["store night manager", "restaurant shift manager"], hasVictim: false,
            summaries: [
                "{BIZ}'s Friday deposits came up short for nine months, a few hundred dollars at a time. The total was {AMT}. {D} was the only manager who closed every Friday.",
                "A new owner at {BIZ} found voided sales and missing deposits totaling {AMT}, all on shifts run by {D}."
            ],
            prosecutionEvidence: [
                E(.document, 4, "Deposit Records", "Every short deposit was prepared on a shift {DL} closed."),
                E(.document, 3, "Voided Sales", "Hundreds of cash sales voided after the customer left, all under {DL}'s login."),
                E(.video, 3, "Office Camera", "{DL} counting cash in the back office, then placing an envelope in a jacket pocket.")
            ],
            defenseEvidence: [
                E(.document, 3, "Shared Login", "Three employees knew the manager login, which was written on a sticky note."),
                E(.document, 2, "Owner's Bookkeeping", "The prior owner kept the books on paper and was known to be sloppy.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Store owner",
                            direct: ["\"I trusted {DL} with the keys. I gave {DL} a raise last Christmas.\""],
                            cross: ["\"Yes, the login was on a sticky note. That was a mistake.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Former cashier",
                            direct: ["\"Other people used the manager code all the time to void stuff.\""],
                            cross: ["\"I wasn't there on Fridays.\""],
                            weight: 1, lay: true)
            ],
            prosecutionTheory: ["Every Friday, {D} closed, and every Friday, money disappeared."],
            defenseTheory: ["A shared login, sloppy books, and an envelope on a camera that could hold anything."],
            aggravating: ["The defendant took advantage of a position of trust"],
            mitigating: ["The defendant supports the defendant's family", "No prior record"],
            guiltyTruths: ["{DL} later confessed to a coworker that the money went to online sports betting."],
            innocentTruths: ["An assistant manager, {ALT}, was caught voiding sales at a new job and admitted to the earlier thefts."],
            moods: [.indifferent],
            doctrines: ["victimRights"],
            extras: ["BIZ": ["the Bojangles on Marlowe Boulevard", "Hollis Hardware", "the Dollar General in Bayard"],
                     "AMT": ["$18,400", "$9,750", "$26,100"]]
        ),

        CaseTemplate(
            key: "organizedRetailTheft", category: .property,
            headlines: ["The Booster Bag", "Out the Fire Exit"],
            primaryLaw: "larcenyMerchant", lesserLaw: "misdLarceny", threshold: 4, lesserThreshold: 2,
            specification: "Committed larceny from {STORE2} using a foil-lined booster bag and an emergency exit.",
            ageRange: 19...40, hasVictim: false,
            summaries: [
                "Loss prevention at {STORE2} watched {D} fill a foil-lined bag with $900 in razors and teeth-whitening kits, then leave through an emergency exit, setting off the alarm.",
                "{D} was stopped in the parking lot of {STORE2} with a foil-lined shopping bag full of designer perfume. Store records show seven similar thefts in a month."
            ],
            prosecutionEvidence: [
                E(.video, 4, "Store Video", "{DL} sweeping shelves of razor cartridges into a lined bag."),
                E(.physical, 3, "Booster Bag", "A shopping bag lined with layers of aluminum foil to defeat security sensors.", .search),
                E(.document, 2, "Fire Exit Alarm Log", "The emergency exit alarm triggered at the time {DL} left.")
            ],
            defenseEvidence: [
                E(.document, 2, "Coerced by Partner", "Texts show {DL}'s partner demanding {DL} \"go get the list.\""),
                E(.document, 2, "Addiction", "{DL} has an opioid use disorder; the goods were resold for drugs.")
            ],
            prosecutionWitnesses: [
                WitnessSeed(name: nil, role: "Loss prevention investigator",
                            direct: ["\"Foil bags, fire exits, a shopping list of high-value items. That's organized retail theft.\""],
                            cross: ["\"I never saw {DL} sell anything.\""],
                            weight: 2, lay: true)
            ],
            defenseWitnesses: [
                WitnessSeed(name: nil, role: "Addiction counselor",
                            direct: ["\"{DL} has been clean 90 days in our program and is working the steps.\""],
                            cross: ["\"Relapse is part of recovery. I can't promise it won't happen.\""],
                            weight: 1, lay: false)
            ],
            prosecutionTheory: ["Booster bags and fire exits aren't impulses. They're tools."],
            defenseTheory: ["{DL} was a pawn in someone else's operation, feeding an addiction."],
            aggravating: ["Part of an organized pattern of thefts"],
            mitigating: ["The defendant acted under duress or coercion", "The defendant is in a treatment program"],
            guiltyTruths: ["A fence arrested later had {DL}'s number saved as \"Razors.\""],
            innocentTruths: ["It came out that {DL}'s partner, {ALT}, ran the operation and had threatened {DL} with violence."],
            moods: [.indifferent, .sympathetic],
            doctrines: ["duress", "lesserIncluded"],
            extras: ["STORE2": ["the Walgreens on Pell Avenue", "Hollis Target", "the CVS in Cedar Hill"]]
        )
    ]
}
