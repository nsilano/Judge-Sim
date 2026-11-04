import Foundation

/// What follows the batch AU everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAU: [String: [Beat]] = [
        "story.fakeTicketResale": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Ticket Sale Collapses",
                 body: "Defendant From Ticket Case Lists Sports Tickets. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ticketsAgain"])
        ],
        "story.mowerShedTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Yard Tool Taken From a Shed",
                 body: "Defendant From Mower Case Seen at Neighbor's Shed. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mowerAgain"], sameVictim: true)
        ],
        "story.constructionDumping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Debris Dumped on Another Property",
                 body: "Defendant From Pasture Dumping Case Linked by Slip. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dumpingAgain"])
        ],
        "story.copperWireStripping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Copper Stripped From Another Empty House",
                 body: "Scrap Yard Flags Defendant From Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.copperAgain"])
        ],
        "story.scratchOffTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Scratch-Off Tickets Taken Again",
                 body: "Defendant From Lottery Roll Case Back at Counter. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scratchAgain"])
        ],
        "story.neighborDogShot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor's Cat Found Wounded",
                 body: "Defendant From Dog Case Accused Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dogAgain"], sameVictim: true)
        ],
        "story.weddingDriveImpaired": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver With Revoked License Stopped Again",
                 body: "Defendant From Reception Case Caught After Dinner. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.impairedAgain"])
        ],
        "story.busPhoneSnatch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Passenger's Phone Taken Again on Bus",
                 body: "Defendant From Bus Case Filmed Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.phoneAgain"])
        ],
        "story.seniorPhoneScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Elderly Victim Wires Money",
                 body: "Defendant From Wire Scam Collects Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scamSecond"])
        ],
        "story.badRentCheck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rent Check Bounces Again",
                 body: "Defendant From Closed-Account Case Writes More. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rentAgain"])
        ],
        "story.skateparkScuffle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Skate Park Fight Again",
                 body: "Defendant From Rail Shove Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.skateAgain"])
        ],
        "story.campusThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Threatening Email From Same Student",
                 body: "Defendant From Campus Case Writes a Dean. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.campusAgain"])
        ],
        "story.courthouseKnife": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Knife Found at Security Again",
                 body: "Defendant From Courthouse Case Stopped With Blade. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.knifeAgain"])
        ],
        "story.motorcycleFlee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Motorcycle Flees Deputy Again",
                 body: "Defendant From Highway Chase Rides Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bikeFleeAgain"])
        ],
        "story.occupiedHouseNight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Home Entered at Night",
                 body: "Defendant From Overnight Burglary Case Linked by Card. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.housePurseAgain"])
        ],
        "story.tireIronAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat Made to Injured Driver",
                 body: "Defendant From Tire Iron Case Contacts Victim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tireIronThreat"], sameVictim: true)
        ],
        "story.photoExtortion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Demand Letter Arrives",
                 body: "Defendant From Photo Case Sends New Demand. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.extortionAgain"], sameVictim: true)
        ],
        "story.inspectorBribe": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Inspector Offered Gift Basket",
                 body: "Contractor From Bribery Case Offers Another Inspector a Gift. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.inspectorGift"])
        ],
        "story.investmentClub": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Club Collects Deposits",
                 body: "Defendant From Investment Case Starts New Fund. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clubAgain"])
        ],
        "story.payrollClerkTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Employer Finds Missing Pay",
                 body: "Defendant From Payroll Case Hired Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.payrollAgain"])
        ],
        "story.deceasedParentCards": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cards Opened in Another Relative's Name",
                 body: "Defendant From Estate Case Faces New Credit Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.estateCardsAgain"])
        ],
        "story.contractKillingPlot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Spouse Receives Threatening Texts After Plot Case",
                 body: "Defendant From Murder-for-Hire Case Contacts Victim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hitmanTexts"], sameVictim: true)
        ],
        "story.boatCrashFatal": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Skipper Charged With Boating While Impaired Again",
                 body: "Defendant From Fatal Boat Case Stopped on Lake. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boatDwi"])
        ],
        "story.fentanylStash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Unit Raided After Earlier Stash",
                 body: "Defendant From Storage Unit Case Rents Another. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stashPhone"])
        ],
        "story.unlockedGunToddler": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Child Again Finds Unsecured Weapon",
                 body: "Defendant From Unsecured Gun Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gunLockLapse"])
        ]
    ]
}
