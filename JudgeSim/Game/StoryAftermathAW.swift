import Foundation

/// What follows the batch AW everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAW: [String: [Beat]] = [
        "story.officeLaptopRaid": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen Office Laptops Resurface at Pawn Shop",
                 body: "Defendant From Office Raid Case Linked by Serials. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.laptopResale"])
        ],
        "story.cabDriverRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Receives Threat After Robbery Case",
                 body: "Defendant From Taxi Robbery Case Contacts Driver. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cabThreat"], sameVictim: true)
        ],
        "story.inspectorShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Inspector Pushed at Same Property",
                 body: "Defendant From Code Inspector Case Pushes Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.inspectorAgain"])
        ],
        "story.employeeIdentityTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Coworker Finds Card in Name",
                 body: "Defendant From Payroll Identity Case Linked by Address. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.identityAgain"])
        ],
        "story.trafficStopBribe": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Offer of Cash to Deputy",
                 body: "Defendant From Citation Bribe Case Offers Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bribeAgain"])
        ],
        "story.videoThreatExtortion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Client Threatened Over Payment",
                 body: "Defendant From Video Extortion Case Texts Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.extortionVideo"])
        ],
        "story.pillDiversion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Missing Pills at Second Pharmacy",
                 body: "Defendant From Pill Diversion Case Hired Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillsAgain"])
        ],
        "story.quadWreckDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Caught on ATV After Fatal Wreck",
                 body: "Defendant From ATV Death Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.atvAgain"])
        ],
        "story.keyboardSabotage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Employer's Files Deleted",
                 body: "Defendant From Wiped Server Case Hired Elsewhere. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sabotageAgain"])
        ],
        "story.hatchetDispute": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat to Victim's Family After Fatal Dispute",
                 body: "Defendant From Driveway Case Contacts Relatives. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hatchetThreat"])
        ],
        "story.pawnShopKilling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Witness in Pawn Shop Case Threatened",
                 body: "Defendant From Shop Killing Case Sends Message. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pawnThreat"])
        ],
        "story.funeralFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Mourner in Funeral Death Case Swings Again",
                 body: "Defendant From Funeral Fight Case Charged With New Assault. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fightAgain"])
        ],
        "story.deerStandAccident": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hunter Cited for Shooting From a Road",
                 body: "Defendant From Hunting Death Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.huntAgain"])
        ],
        "story.exPartnerStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Victim Receives Threat After Stabbing Case",
                 body: "Defendant From Parking Lot Stabbing Case Contacts Victim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stabThreat"], sameVictim: true)
        ],
        "story.dealerKidnapping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Victim Threatened Again After Basement Case",
                 body: "Defendant From Basement Case Sends Message. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kidnapThreat"], sameVictim: true)
        ],
        "story.restaurantFireClaim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Insurance Claim Filed for Restaurant Fire",
                 body: "Defendant From Restaurant Fire Case Claims Losses. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fireClaimRestaurant"])
        ],
        "story.rentalBatAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Threatened Again",
                 body: "Defendant From Bat Case Texts Landlord. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.batThreat"], sameVictim: true)
        ],
        "story.elderHomeNight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Night Intruder Near Elderly Resident's Street",
                 body: "Defendant From Elderly Burglary Case Seen on Camera. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.elderHomeAgain"])
        ],
        "story.jewelryHoldup": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen Rings Turn Up at Second Pawn Shop",
                 body: "Defendant From Jewelry Store Case Linked by Tags. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jewelryFence"])
        ],
        "story.parkingOfficeSafe": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Municipal Office Safe Taken",
                 body: "Defendant From Parking Office Case Linked by Pickup. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.officeSafeAgain"])
        ],
        "story.classmateMessages": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Messages Resume Under New Accounts",
                 body: "Defendant From Classmate Messages Case Sends More. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.messagesAgain"], sameVictim: true)
        ],
        "story.barBrokenBottle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Patron Threatened After Bar Fight Case",
                 body: "Defendant From Bottle Case Messages Victim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bottleThreat"], sameVictim: true)
        ],
        "story.dieselDrainage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Diesel Taken From Another Yard",
                 body: "Defendant From Diesel Case Linked by Hose. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dieselAgain"])
        ],
        "story.lotInvestmentFraud": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Land Sale Collapses",
                 body: "Defendant From Lot Case Offers Another Investment. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotFraudAgain"])
        ]
    ]
}
