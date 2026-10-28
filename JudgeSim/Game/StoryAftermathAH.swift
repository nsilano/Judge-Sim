import Foundation

/// What follows the batch AH written cases. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
extension StoryAftermath {
    static let beatsAH: [String: [Beat]] = [
        "story.mailedPills": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Deputies find 40 fentanyl pills in traffic stop",
                 body: "A stop for a dead taillight turned up 40 blue M30 pills, $1,300 in twenties, and a second phone under the driver's seat, deputies say. The driver was {D}, whose case over pills mailed to a post office box was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.pressedPills"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Mailbox rented with a stranger's lost license",
                 body: "A shipping store mailbox was rented using a Hollis County resident's lost driver's license, and credit cards in that name started arriving. The store's camera shows {D}. Judge {JUDGE} heard {DL}'s earlier case.",
                 followUps: ["story.followup.boxUnderAnotherName"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 10...90,
                 headline: "Postal inspectors: fentanyl pills are coming through the mail",
                 body: "After the case of {D}, postal inspectors told county commissioners that packages of pressed fentanyl pills addressed to rented boxes are turning up every month in eastern North Carolina. They asked post office clerks to report boxes rented with suspicious IDs.")
        ],
        "story.crossingGuardCrash": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Driver in crossing guard death clocked at 52 in same school zone",
                 body: "A deputy says {D}, whose case over the death of crossing guard {V} was heard by Judge {JUDGE}, drove 52 miles per hour through the school zone during drop-off and passed a stopping bus.",
                 followUps: ["story.followup.schoolZoneSpeeding"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Driver speeds away from checkpoint; chase ends in ditch",
                 body: "A trooper says {D} turned around short of a license checkpoint and fled at 80 miles per hour before sliding into a ditch on Shiloh Road. {DL}'s earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.checkpointFlight"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.7, days: 20...120,
                 headline: "Crosswalk named for {VL}",
                 body: "The town council voted to name the crosswalk outside the elementary school for {V}, who guided children across it for twelve years. Flashing beacons go up next month. Students made a mural of handprints for the corner."),
            Beat(triggers: [.cleared, .freed], chance: 0.4, days: 15...90,
                 headline: "{VL}'s family: 'Somebody should have to answer'",
                 body: "{V}'s family says they are disappointed in the outcome of the case against {D}. \"We don't want revenge,\" a son said. \"We want somebody to say they were wrong to drive away.\"")
        ],
        "story.mobileHomeSale": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Truck sold with forged lien release, buyer says",
                 body: "A Hollis County buyer says they paid $11,000 for a pickup whose title still shows a credit union lien, and that the release they were handed was forged. The seller was {D}, whose mobile home sale case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.forgedLienRelease"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Owner says property manager kept tenants' deposits",
                 body: "A landlord says {D}, hired to manage four rental houses, kept $6,750 in tenants' security deposits that the law requires to be held in trust. {DL}'s earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.keptDeposits"]),
            Beat(triggers: [.probation], chance: 0.5, days: 60...240,
                 headline: "{VL} family moves into new home with restitution",
                 body: "{V}, who lost $18,500 on a mobile home {D} sold without clear title, says the first restitution payments and help from a church let the family put a deposit on a rental. \"It isn't the home we bought,\" {VL} said. \"But we're out of the motel.\"")
        ],
        "story.fakeFundraiser": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Fire department says it never authorized truck raffle",
                 body: "A volunteer fire chief says {D} sold $4,900 in raffle tickets for a pickup truck in the department's name, and the department never saw a ticket or a truck. Judge {JUDGE} heard {DL}'s earlier fundraiser case.",
                 followUps: ["story.followup.truckRaffle"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Fire marshal: shed was empty before it burned",
                 body: "An insurance claim for $14,200 in tools lost in a shed fire is under investigation after the fire marshal found no tools in the ashes. The claim was filed by {D}, whose earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.shedFire"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 15...90,
                 headline: "Family burned out of home gets help, two years late",
                 body: "Churches and the volunteer fire department have raised enough to put the family whose fire was used for the fundraiser in the case of {D} into a rental house. Organizers say every dollar is going through a church account this time."),
            Beat(triggers: [.probation], chance: 0.4, days: 60...200,
                 headline: "Donors repaid in fundraiser case",
                 body: "{V} and other donors to the fundraiser run by {D} have been repaid in full as a condition of {DL}'s probation, a probation officer reported to Judge {JUDGE}.")
        ],
        "story.prescriptionPadForgery": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Pharmacist catches phoned-in painkiller order",
                 body: "A pharmacist called back the orthopedic practice that supposedly phoned in an oxycodone prescription and learned no one there had called. Deputies arrested {D} at the counter. Judge {JUDGE} heard {DL}'s earlier prescription case.",
                 followUps: ["story.followup.phonedInScript"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Home health aide charged with taking patient's pain pills",
                 body: "A family says a camera caught {D}, the home health aide caring for their 84-year-old parent, taking oxycodone from the pill bottle. {DL}'s earlier case over forged prescriptions was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.patientsPills"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 15...90,
                 headline: "Dentists switch to electronic prescriptions after forgery case",
                 body: "Most Hollis County dental offices now send controlled-substance prescriptions electronically, the dental society says, after the case of {D}, a dental assistant charged with forging oxycodone scripts on a dentist's pad.")
        ]
    ]
}
