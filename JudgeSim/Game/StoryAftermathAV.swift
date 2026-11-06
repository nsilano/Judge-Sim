import Foundation

/// What follows the batch AV everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAV: [String: [Beat]] = [
        "story.laundromatChangeBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Change Machine Emptied at Second Laundromat",
                 body: "Defendant From Coin Door Case Seen on Camera Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.changeBoxAgain"])
        ],
        "story.libraryReadingRoom": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Library Patron Back at Desk After Warning",
                 body: "Defendant From Library Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.libraryAgain"])
        ],
        "story.leagueTreasurer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Booster Club Reports Missing Dues",
                 body: "Treasurer From Youth League Case Runs Another Fund. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.treasurerSecond"])
        ],
        "story.formerRoommateKey": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Former Tenant Back Inside Another Apartment",
                 body: "Defendant From Key Case Enters With Old Key. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.keyAgain"])
        ],
        "story.petSuppliesBag": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pet Store Walkout Again",
                 body: "Defendant From Dog Supplies Case Filled a Bag. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.petSuppliesAgain"])
        ],
        "story.clothingBinTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Donation Bin Emptied Again",
                 body: "Defendant From Clothing Bin Case Linked by Van. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.binAgain"])
        ],
        "story.remoteJobAdvance": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Job Ad Charges 'Training Fee'",
                 body: "Defendant From Job Scam Case Posts Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jobAdvanceAgain"])
        ],
        "story.mallBanReturn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Banned Shopper Returns to Another Mall",
                 body: "Defendant From Mall Ban Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mallAgain"])
        ],
        "story.couponStack": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Copied Coupons at New Chain",
                 body: "Defendant From Coupon Case Redeems More. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.couponAgain"])
        ],
        "story.schoolRunDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Stopped After Evening Event",
                 body: "Defendant From School-Run DWI Stopped Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dwiAgainSchool"])
        ],
        "story.expiredTagFlee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Chase Over an Expired Tag",
                 body: "Defendant From Hedge Keys Case Flees Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tagAgain"])
        ],
        "story.kayakDockTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Dock Loses a Kayak",
                 body: "Defendant From Kayak Case Linked by Truck. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kayakAgain"])
        ],
        "story.fuelCardMisuse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fuel Card Charges Again at New Employer",
                 body: "Defendant From Fuel Card Case Hired Elsewhere. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fuelCardAgain"])
        ],
        "story.hotelRoomTrashed": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hotel Room Damaged Again",
                 body: "Defendant From Hotel Case Rents at Another Hotel. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hotelAgain"])
        ],
        "story.weddingGiftBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Reception Loses Its Gift Box",
                 body: "Defendant From Wedding Box Case at New Wedding. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.giftBoxAgain"])
        ],
        "story.busPassingStopArm": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Passes Stopped Bus Again",
                 body: "Defendant From Stop-Arm Case Passes Another Bus. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.busAgain"])
        ],
        "story.gymLockerWallet": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Locker Cut at Second Gym",
                 body: "Defendant From Gym Wallet Case Signs In as Guest Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lockerAgain"])
        ],
        "story.ediblesAtFestival": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Gummies Found Again at Gate",
                 body: "Defendant From Festival Case Searched Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ediblesAgain"])
        ],
        "story.phantomLandlord": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Renter Pays Deposit on Unavailable Apartment",
                 body: "Defendant From Fake Landlord Case Lists Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.landlordAgain"])
        ],
        "story.neighborBoardPost": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Threatening Post on the Board",
                 body: "Defendant From Board Case Posts Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boardAgain"], sameVictim: true)
        ],
        "story.campTableBurn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fire Ring and Table Burned at Another Park",
                 body: "Defendant From Campground Burn Case Seen Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.campAgain"])
        ]
    ]
}
