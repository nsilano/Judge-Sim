import Foundation

/// What follows the batch L stories: a second return to this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBG: [String: [Beat]] = [
        "story.hatchetDispute": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Surveyor Threatened With Axe Over Boundary Stakes",
                 body: "Defendant From Driveway Case Charged With Assault Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hatchetDisputeAgain2"])
        ],
        "story.waterTowerClimb": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Teen Back on Roof of Abandoned Mill",
                 body: "Second Trespass Charge for Climber From Tower Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.waterTowerClimbAgain2"])
        ],
        "story.inspectorCash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Zoning Officer Accepts $2,000 for Septic Sign-Off",
                 body: "Former County Inspector Faces a New Bribery Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.inspectorCashAgain2"])
        ],
        "story.busDriverYell": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Parent Blocks School Drop-Off Lane to Confront Principal",
                 body: "Defendant From Bus Stop Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.busDriverYellAgain2"])
        ],
        "story.streetRaceBystander": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Racer Clocked at 112 on Interstate Exit Ramp",
                 body: "Prior Race Defendant Cited for Reckless Driving Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.streetRaceBystanderAgain2"])
        ],
        "story.scaleAndBags": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Glass Pipes Found Among Jewelry at Craft Fair Booth",
                 body: "Jewelry Seller From Scale Case Faces New Paraphernalia Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scaleAndBagsAgain2"])
        ],
        "story.bankNoteRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Demand Note Passed to Check-Cashing Clerk",
                 body: "Defendant From Bank Note Case Charged in New Robbery. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bankNoteRobberyAgain2"])
        ],
        "story.partyGrab": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Boyfriend Pulls Girlfriend by the Hair at Bowling Alley",
                 body: "Defendant From House Party Case Charged With Assault on a Female. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.partyGrabAgain2"])
        ],
        "story.deletedServer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Former Contractor Locks Clinic's Appointment System With Leftover Password",
                 body: "Prior Server Wipe Defendant Faces New Computer Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deletedServerAgain2"])
        ],
        "story.tailgateShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Man Shoves Parking Attendant at Fairgrounds Lot",
                 body: "Defendant From Tailgate Case Charged With Assault Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tailgateShoveAgain2"])
        ],
        "story.nightPharmacy": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Veterinary Clinic Burglarized Through Skylight; Controlled Drugs Taken",
                 body: "Roofer From Pharmacy Case Linked to New Break-In. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nightPharmacyAgain2"])
        ],
        "story.churchBooks": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Volunteer Fire Department Treasurer Accused of $38,000 Shortfall",
                 body: "Treasurer From Church Fund Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.churchBooksAgain2"])
        ],
        "story.fireAlarmPull": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "911 Caller Reports Smoke in Neighbor's Apartment, Engines Find Nothing",
                 body: "Tenant From False Alarm Case Charged With False Report. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fireAlarmPullAgain2"])
        ],
        "story.snowbank": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Driver Hits Cyclist in Sleet and Drives Off",
                 body: "Defendant From Culvert Case Charged With Leaving the Scene. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.snowbankAgain2"])
        ],
        "story.pillDiversion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Dental Assistant Takes Hydrocodone From Locked Cabinet",
                 body: "Technician From Pill Case Hired at a Dental Office. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillDiversionAgain2"])
        ],
        "story.longDrive": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Former Partner Follows Victim to Airport Lot Despite No-Contact Order",
                 body: "Defendant From Kidnapping Case Violates Protective Order. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.longDriveAgain2"], sameVictim: true)
        ],
        "story.mercyKilling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Elderly Friend Charged After Ill Neighbor's Fatal Insulin Dose",
                 body: "Defendant From Mercy Case Faces Manslaughter Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mercyKillingAgain2"])
        ]
    ]
}
