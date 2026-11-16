import Foundation

/// What follows the batch BL stories: the defendant returns to this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBL: [String: [Beat]] = [
        "story.sharedApartment": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pills Found in Warehouse Locker After Tip",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a manager found a bottle of pills in a work locker.",
                 followUps: ["story.followup.sharedApartmentBack"])
        ],
        "story.fishingCabin": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Marina Dock Hand Says Boater Threatened to Drown Them",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with threatening a dock hand during a fee argument at a lake marina.",
                 followUps: ["story.followup.fishingCabinBack"])
        ],
        "story.payrollRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Car Wash Deposit Pouch Snatched From Attendant",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with shoving a car wash worker and taking a deposit pouch.",
                 followUps: ["story.followup.payrollRobberyBack"])
        ],
        "story.carjackingRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Wallet and Phone Taken From Locked Car at Gym",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with smashing a car window at a gym and taking a wallet and phone.",
                 followUps: ["story.followup.carjackingRobberyBack"])
        ],
        "story.pickupLineSpeeding": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver Races Through Soccer Field Parking Lot",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with speeding through a crowded youth soccer lot.",
                 followUps: ["story.followup.pickupLineSpeedingBack"])
        ],
        "story.altereCheckMail": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Lost Wallet Card Used at Vape Shop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with using a lost debit card four times at a vape shop.",
                 followUps: ["story.followup.altereCheckMailBack"])
        ],
        "story.rentalCarPills": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pills Found in Hotel Room Safe After Noise Complaint",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after deputies found pills in a hotel room safe.",
                 followUps: ["story.followup.rentalCarPillsBack"])
        ],
        "story.parkingLotSleeper": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Revoked Driver Caught Waiting in Car Wash Line",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a deputy saw a revoked driver leave a car wash.",
                 followUps: ["story.followup.parkingLotSleeperBack"])
        ],
        "story.roadBlockade": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Flagger Hit by Mirror as Driver Speeds Through Road Work Zone",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a car clipped a traffic flagger at a road work zone.",
                 followUps: ["story.followup.roadBlockadeBack"])
        ],
        "story.restraintDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Ex-Officer Falsifies Log at Security Job",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a security log did not match gate video.",
                 followUps: ["story.followup.restraintDeathBack"])
        ],
        "story.exHouseKey": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Ex-Tenant Charged After Entering Former Landlord's Rental",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with going into a former landlord's vacant duplex after a no-trespass letter.",
                 followUps: ["story.followup.exHouseKeyBack"])
        ],
        "story.truckStopKiller": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Trucker Runs Weigh Station Lane at Speed",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with speeding a tractor-trailer through a closed weigh station lane.",
                 followUps: ["story.followup.truckStopKillerBack"])
        ],
        "story.taserMistake": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Woman Wears Old Police Badge at Crash Scene",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with wearing a badge and directing traffic at a crash.",
                 followUps: ["story.followup.taserMistakeBack"])
        ],
        "story.paradeSUV": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Defendant Violates Protective Order at Ex's Workplace",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with going to a protected person's workplace despite a court order.",
                 followUps: ["story.followup.paradeSUVBack"])
        ],
        "story.parentsMansion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Online Tennis Lesson Packages Never Delivered",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with taking money for tennis lessons that were never given.",
                 followUps: ["story.followup.parentsMansionBack"])
        ],
        "story.trailMurders": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Man Charged After Outburst at Library Board Meeting",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after an outburst ended a library board meeting.",
                 followUps: ["story.followup.trailMurdersBack"])
        ],
        "story.dogMauling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Puppy Left in Hot Car at Mall Lot",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a puppy was found in a hot car at a mall.",
                 followUps: ["story.followup.dogMaulingBack"])
        ],
        "story.cityStrangler": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Repeated Messages to Former Coworker Lead to Stalking Complaint",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with sending dozens of messages after being told to stop.",
                 followUps: ["story.followup.cityStranglerBack"])
        ],
        "story.hazingDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Student Punches Man in Bar Lot After Football Game",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with a punch outside a bar after a football game.",
                 followUps: ["story.followup.hazingDeathBack"])
        ],
        "story.hurricaneFraud": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driveway Sealing Deposits Taken, Work Never Done",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with taking a driveway deposit and never doing the work.",
                 followUps: ["story.followup.hurricaneFraudBack"])
        ],
        "story.fakeDoctor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Vitamin Injection Packages Sold From Van",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time with selling injection packages from a van.",
                 followUps: ["story.followup.fakeDoctorBack"])
        ],
        "story.daycareCameras": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Teacher at Dance Studio Charged After Grabbing Child's Arm",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a dance studio video showed a child grabbed by the arm.",
                 followUps: ["story.followup.daycareCamerasBack"])
        ],
        "story.feedStoreFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Farmer Claims Stolen Tractor Attachments Never Existed",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a theft claim for equipment that had already been sold.",
                 followUps: ["story.followup.feedStoreFireBack"])
        ],
        "story.tractorDWI": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Farmer Driving Pickup With Revoked License Stopped at Feed Store",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is charged again, this time after a deputy saw a revoked driver leave a pickup at a feed store.",
                 followUps: ["story.followup.tractorDWIBack"])
        ],
    ]
}
