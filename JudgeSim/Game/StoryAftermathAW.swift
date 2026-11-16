import Foundation

/// What follows the batch AW everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAW: [String: [Beat]] = [
        "story.officeLaptopRaid": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen Office Laptops Resurface at Pawn Shop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.laptopResale"])
        ],
        "story.cabDriverRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Receives Threat After Robbery Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cabThreat"], sameVictim: true)
        ],
        "story.inspectorShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Inspector Pushed at Same Property",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.inspectorAgain"])
        ],
        "story.employeeIdentityTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Coworker Finds Card in Name",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.identityAgain"])
        ],
        "story.videoThreatExtortion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Client Threatened Over Payment",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.extortionVideo"])
        ],
        "story.pillDiversion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Missing Pills at Second Pharmacy",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillsAgain"])
        ],
        "story.quadWreckDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Caught on ATV After Fatal Wreck",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.atvAgain"])
        ],
        "story.keyboardSabotage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Employer's Files Deleted",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sabotageAgain"])
        ],
        "story.hatchetDispute": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat to Victim's Family After Fatal Dispute",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hatchetThreat"])
        ],
        "story.pawnShopKilling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Witness in Pawn Shop Case Threatened",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pawnThreat"])
        ],
        "story.exPartnerStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Victim Receives Threat After Stabbing Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stabThreat"], sameVictim: true)
        ],
        "story.rentalBatAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Threatened Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.batThreat"], sameVictim: true)
        ],
        "story.elderHomeNight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Night Intruder Near Elderly Resident's Street",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.elderHomeAgain"])
        ],
        "story.parkingOfficeSafe": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Municipal Office Safe Taken",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.officeSafeAgain"])
        ],
        "story.dieselDrainage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Diesel Taken From Another Yard",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dieselAgain"])
        ],
        "story.lotInvestmentFraud": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Land Sale Collapses",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotFraudAgain"])
        ]
    ]
}
