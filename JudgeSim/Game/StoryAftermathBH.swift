import Foundation

/// What follows the batch BH stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBH: [String: [Beat]] = [
        "story.scaldChildAbuse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Parent Again Charged After Child Found Alone in Parking Lot at 2 A.M.",
                 body: "A neighbor called deputies about a child outside at night. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.scaldChildAbuseAgain2"])
        ],
        "story.privateImagesPost": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Ex-Partner Posts Private Photos to a 40-Member Team Chat",
                 body: "A league moderator saved a screenshot before the post vanished. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.privateImagesPostAgain2"])
        ],
        "story.clubAmbushKilling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Shotgun Pointed at Biker Club Member at Fuel Pump",
                 body: "A pump camera recorded the confrontation. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.clubAmbushKillingAgain2"])
        ],
        "story.constructionDumping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Roofing Crew Loads Shingles at Supply Yard Without Paying",
                 body: "The yard says the company's account was on hold. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.constructionDumpingAgain2"])
        ],
        "story.payrollClerkTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Co-op Bookkeeper Sent Customer Refunds to a Prepaid Card",
                 body: "An audit found refunds no customer had asked for. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.payrollClerkTheftAgain2"])
        ],
        "story.prankNineOneOne": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Caller Reports Two Children Unconscious at Wrong Address",
                 body: "Deputies forced a door and found an empty house. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.prankNineOneOneAgain2"])
        ],
        "story.painClinic": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Weight-Loss Telehealth Clinic Prescribed Amphetamine After Video Visits",
                 body: "Pharmacies noticed the same prescription pattern again. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.painClinicAgain2"])
        ],
        "story.homeInvasion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Gun Found in Trunk of Rideshare Car Driven by Driver With a Felony",
                 body: "A passenger's photo reached the ride company, which called deputies. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.homeInvasionAgain2"])
        ],
        "story.formerRoommateKey": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Note Under Windshield Wiper Threatens Former Housemate's Family",
                 body: "A doorbell camera caught someone at the car before dawn. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.formerRoommateKeyAgain2"])
        ],
        "story.formerEmployeeFiles": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "School Aide Changes Fourteen Grades Through Teacher's Login",
                 body: "The district noticed the edits after a parent called. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.formerEmployeeFilesAgain2"])
        ],
        "story.heatOfPassion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Restaurant Argument Ends With Shove Through Glass Door",
                 body: "An injured customer needed forty stitches. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.heatOfPassionAgain2"])
        ],
        "story.loyaltyCardClones": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Tire Shop Writer Used Pocket Reader on Customers' Cards",
                 body: "A bank traced dozens of cards to one counter. Authorities say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.loyaltyCardClonesAgain2"])
        ],
        "story.jailLockdownRiot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Chairs Thrown at County Board Meeting Over Jail Conditions",
                 body: "The meeting stopped for forty minutes. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.jailLockdownRiotAgain2"])
        ],
        "story.lakeCrashFatal": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Truck Hauling Boat Trailer Passes on Double Yellow, Forces Car Into Ditch",
                 body: "An oncoming driver's dashcam captured the pass. Troopers say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.lakeCrashFatalAgain2"])
        ],
        "story.pillPress": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Blue Pills Found Inside Hollowed Speaker at Highway Stop",
                 body: "A dog alerted on the vehicle during a routine stop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge.",
                 followUps: ["story.followup.pillPressAgain2"])
        ]
    ]
}
