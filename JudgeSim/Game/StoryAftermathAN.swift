import Foundation

/// What follows the batch AN everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAN: [String: [Beat]] = [
        "story.priceTagSwitch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shopper Swapped Barcode Labels at Big Box Store",
                 body: "Second Price Tag Charge for Defendant From Hardware Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barcodeSwapTwo"])
        ],
        "story.mopedFlee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Moped Rider Without License Stopped Again",
                 body: "Driving While Revoked After Moped Chase. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mopedNoLicense"])
        ],
        "story.loudParty": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Party Host Resists Deputies, Charged Again",
                 body: "Resisting Charge After Second Noise Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.partyResisting"])
        ],
        "story.dirtBikeStreet": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Dirt Bike Tore Up Church Lawn",
                 body: "Property Damage Charge After Dirt Bike Stunts. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dirtBikeLawn"])
        ],
        "story.underpassPaint": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "School Wall Tagged Over Weekend",
                 body: "Same Tag Appears on School Building. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.schoolWallPaint"])
        ],
        "story.falseAlarmCall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another False Fire Call, Another Prepaid Phone",
                 body: "Second False Report for Man in Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.falseAlarmTwo"])
        ],
        "story.fakeBadgeTrick": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Told Deputy He Was an Officer, Charged Again",
                 body: "Obstruction Charge After Second Badge Incident. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.badgeObstruction"])
        ],
        "story.concealedPistolPurse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Loaded Pistol Found Under Truck Seat",
                 body: "Concealed Weapon Charge After Fair Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pistolInTruck"])
        ],
        "story.chainedDog": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Dog Found Chained Without Water",
                 body: "Animal Control Cites Owner Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.secondDogChained"])
        ],
        "story.hitAndRunBumper": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Hit Parked Truck, Left a Note With No Name",
                 body: "Second Hit-and-Run for Same Driver. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bumperAgain"])
        ],
        "story.badCheckFeed": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Bad Check, This Time at Hardware Store",
                 body: "Closed Account Check Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.badCheckHardware"])
        ],
        "story.facebookThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Text Threat Follows Facebook Post Case",
                 body: "Neighbor Says Text Said 'You'll Be Sorry'. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.threatByText"], sameVictim: true)
        ],
        "story.repeatedTexts": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Under Court Order Seen at Ex's Workplace",
                 body: "Stalking Charge While Order Was in Effect. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stalkingAtWork"], sameVictim: true)
        ],
        "story.drunkPorch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man on Neighbor's Porch Again After Warning",
                 body: "Second Trespass Charge After Porch Swing Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.drunkPorchTwo"], sameVictim: true)
        ],
        "story.mailTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Card From Stolen Mail Used at Pharmacy",
                 body: "Card Fraud Follows Mail Theft Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mailCardOpen"])
        ],
        "story.gasCanSiphon": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Siphoning Case for Same Man",
                 body: "Hose and Can Found Again at Dawn. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.siphonTwo"])
        ],
        "story.tireSlash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Windshield Smashed on Same Woman's Car",
                 body: "Second Property Damage Case After Slashed Tires. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.windshieldCrack"], sameVictim: true)
        ],
        "story.tailgateShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat at Next Home Game for Man in Shove Case",
                 body: "Communicating Threats After Tailgate Dispute. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tailgateThreat"], sameVictim: true)
        ],
        "story.falseNameDeputy": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Gave a Fake Name Again, Charged With Resisting",
                 body: "Second False Name at a Traffic Stop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.falseNameResisting"])
        ],
        "story.scrapGutters": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Copper Wire Sold at Scrap Yard After Vacant House Case",
                 body: "Stolen Copper Flagged at Scrap Yard. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.copperScrapYard"], sameVictim: true)
        ],
        "story.campusLaptop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Phone Pawned After Laptop Case",
                 body: "Stolen Phone Traced to Pawn Shop Seller. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.laptopPhoneTwo"])
        ],
        "story.returnFraud": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Return Scheme at Another Store",
                 body: "Receipt Check Ends Another Return. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.returnFraudTwo"])
        ],
        "story.fakeLicense": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Underage Man Tries Fake License at Bar",
                 body: "Bouncer Spots Forged ID. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakeLicenseBar"])
        ],
        "story.paintCans": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Back in Paint Aisle Weeks After Backpack Case",
                 body: "Second Larceny From Home Improvement Store. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.paintCansTwo"])
        ],
        "story.dumpsterFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Dumpster Fire Behind Same Restaurant",
                 body: "Fire Marshal Says Fire Was Set. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dumpsterFireTwo"], sameVictim: true)
        ],
        "story.tipJar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cash Box Taken From Coffee Shop Counter",
                 body: "Second Counter Theft at Same Shop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cashBoxCafe"], sameVictim: true)
        ],
        "story.shedBreakIn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shed Broken Into Again, Tools Taken",
                 body: "Neighbor's Shed Hit Twice. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shedBreakInTwo"], sameVictim: true)
        ],
        "story.scaleAndBags": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Scale and Bags Found Again in Car",
                 body: "Second Paraphernalia Charge for Jewelry Seller. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scaleAgain"])
        ],
        "story.airsoftCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Airsoft Pistol Pointed at Boys in School Lot",
                 body: "Toy Gun Pointed Again, Deputies Say. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.airsoftSchoolLot"])
        ]
    ]
}
