import Foundation

/// What follows the batch AV everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAV: [String: [Beat]] = [
        "story.laundromatChangeBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Change Machine Emptied at Second Laundromat",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.changeBoxAgain"])
        ],
        "story.libraryReadingRoom": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Library Patron Back at Desk After Warning",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.libraryAgain"])
        ],
        "story.leagueTreasurer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Booster Club Reports Missing Dues",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.treasurerSecond"])
        ],
        "story.formerRoommateKey": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Former Tenant Back Inside Another Apartment",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.keyAgain"])
        ],
        "story.petSuppliesBag": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pet Store Walkout Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.petSuppliesAgain"])
        ],
        "story.clothingBinTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Donation Bin Emptied Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.binAgain"])
        ],
        "story.remoteJobAdvance": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Job Ad Charges 'Training Fee'",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jobAdvanceAgain"])
        ],
        "story.mallBanReturn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Banned Shopper Returns to Another Mall",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mallAgain"])
        ],
        "story.couponStack": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Copied Coupons at New Chain",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.couponAgain"])
        ],
        "story.schoolRunDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Stopped After Evening Event",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dwiAgainSchool"])
        ],
        "story.expiredTagFlee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Chase Over an Expired Tag",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tagAgain"])
        ],
        "story.kayakDockTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Dock Loses a Kayak",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kayakAgain"])
        ],
        "story.fuelCardMisuse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fuel Card Charges Again at New Employer",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fuelCardAgain"])
        ],
        "story.hotelRoomTrashed": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hotel Room Damaged Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hotelAgain"])
        ],
        "story.weddingGiftBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Reception Loses Its Gift Box",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.giftBoxAgain"])
        ],
        "story.busPassingStopArm": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Passes Stopped Bus Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.busAgain"])
        ],
        "story.gymLockerWallet": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Locker Cut at Second Gym",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lockerAgain"])
        ],
        "story.ediblesAtFestival": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Gummies Found Again at Gate",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ediblesAgain"])
        ],
        "story.phantomLandlord": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Renter Pays Deposit on Unavailable Apartment",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.landlordAgain"])
        ],
        "story.neighborBoardPost": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Threatening Post on the Board",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boardAgain"], sameVictim: true)
        ],
        "story.campTableBurn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fire Ring and Table Burned at Another Park",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.campAgain"])
        ]
    ]
}
