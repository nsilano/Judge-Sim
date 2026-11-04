import Foundation

/// What follows the batch AO everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAO: [String: [Beat]] = [
        "story.vendingMachinePry": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Vending Machine Pried Open Behind Laundromat",
                 body: "Same Method, New Machine for Defendant From Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.vendingAgain"], sameVictim: true)
        ],
        "story.busDriverYell": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Threatens Bus Driver Weeks After Stop Dispute",
                 body: "Communicating Threats Charge After School Bus Incident. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.busStopThreat"])
        ],
        "story.junkyardTires": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Used Tires Sold From Same Yard Where Rims Were Found",
                 body: "Second Stolen Tire Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tireResale"])
        ],
        "story.deerStandTrespass": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hunter Back on Posted Land With New Stand",
                 body: "Second Trespass for Man From Hunting Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deerStandAgain"])
        ],
        "story.flagTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Flag Burned on Veteran's Lawn",
                 body: "Property Damage Charge After Flag Theft Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.flagBurn"], sameVictim: true)
        ],
        "story.borrowedTruck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Driving Borrowed Truck Had No License",
                 body: "Driving While Revoked Follows Truck Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.truckNoLicense"])
        ],
        "story.donationBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Collection Plate Taken During Church Service",
                 body: "Second Church Theft for Man in Donation Box Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.collectionPlateTheft"])
        ],
        "story.skateboardRefuse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Skates Away From Deputy Again",
                 body: "Resisting Charge Follows Church Steps Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.skateboardEscape"])
        ],
        "story.fireAlarmPull": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Alarm Pulled at Same Apartment Complex",
                 body: "Second False Alarm Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fireAlarmAgain"])
        ],
        "story.dryerClothes": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Clothes Taken From Backyard Line",
                 body: "Second Laundry Theft for Woman in Laundromat Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clotheslineTheft"])
        ],
        "story.softballFieldFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Coach Threatens Umpire Before Next Game",
                 body: "Communicating Threats After League Fight. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.softballThreat"], sameVictim: true)
        ],
        "story.ticketScalper": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fake Tickets Sold Again for Different Show",
                 body: "Second Ticket Scam Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ticketScalperTwo"])
        ],
        "story.cameraSmash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbors Fight Over Replaced Camera",
                 body: "Simple Assault After Camera Smash Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cameraSmashAssault"], sameVictim: true)
        ],
        "story.rideshareRunner": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Driver Says Passenger Ran From Fare",
                 body: "Larceny Charge After Another Rideshare Run. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rideshareRunnerTwo"])
        ],
        "story.wheelBootCut": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Screams at Tow Truck Driver Over Boot",
                 body: "Disorderly Conduct After Boot Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.parkingLotDispute"])
        ],
        "story.noonBurglary": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen Laptop Traced to Man From Burglary Case",
                 body: "Receiving Charge After Daytime Break-In. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.burglaryReceiving"], sameVictim: true)
        ],
        "story.bankNoteRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Leads Deputies on Chase After Bank Case",
                 body: "Fleeing Charge Follows Robbery Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.robberyGetaway"])
        ],
        "story.barParkingKnife": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Letter Threatens Man Cut in Bar Fight",
                 body: "Communicating Threats After Knife Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.knifeThreatLetter"], sameVictim: true)
        ],
        "story.cocaineBagStop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Drugs Found in Car at Traffic Stop Weeks After Earlier Case",
                 body: "Second Schedule II Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pwisdAgain"])
        ],
        "story.sellPillsAtWork": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacist Spots Altered Prescription From Warehouse Worker",
                 body: "Prescription Fraud After Pill Delivery Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillRefill"])
        ],
        "story.domesticChoke": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Texts Woman Despite Protective Order",
                 body: "Violation of Domestic Violence Protective Order. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dvpoViolationText"], sameVictim: true)
        ],
        "story.phoneSnatch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Card From Snatched Phone Case Used at Convenience Store",
                 body: "Card Fraud After Phone Robbery Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.snatchCardUse"], sameVictim: true)
        ],
        "story.payrollCheckForge": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bookkeeper Passes Forged Check at New Job",
                 body: "Uttering Charge After Payroll Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.forgedCheckUttering"], sameVictim: true)
        ],
        "story.taxRefundTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Client's Refund Taken by Tax Preparer",
                 body: "Second Identity Theft Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.refundIdentity"])
        ],
        "story.dopeHouseTrailer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Search of Trailer Finds Paraphernalia",
                 body: "Paraphernalia Charge After Trailer Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dwellingRaid"])
        ],
        "story.atvTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen ATV Parts Found in Uncle's Barn",
                 body: "Possession Charge After ATV Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.atvChopShop"], sameVictim: true)
        ],
        "story.deputyShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Who Shoved Deputy Pulls Away Again",
                 body: "Resisting Charge After Assault on Officer Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deputyResist"])
        ],
        "story.pistolFromTruck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Convicted in Pistol Case Found With Another Gun",
                 body: "Felon in Possession Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.felonFirearmPossession"])
        ],
        "story.trafficCocaineMotel": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cocaine Found at Another Motel Room",
                 body: "Second Cocaine Charge After Motel Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cokeMotelAgain"])
        ],
        "story.deliveryRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Delivery Driver Threatened After Identifying Suspect",
                 body: "Communicating Threats After Robbery Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.robberyIntimidation"], sameVictim: true)
        ]
    ]
}
