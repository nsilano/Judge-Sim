import Foundation

/// What follows the batch AS everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAS: [String: [Beat]] = [
        "story.overpassGraffiti": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Overpass Painted, Same Lettering",
                 body: "Defendant From Graffiti Case Linked by Style. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.paintAgain"])
        ],
        "story.benefitsOverreport": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Housing Assistance Questioned After Earlier Benefits Case",
                 body: "Defendant Reports No Income Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.benefitsSecond"])
        ],
        "story.receiptReturnScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Return Fraud at Second Store",
                 body: "Defendant From Return Case Flagged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.returnScamSecond"])
        ],
        "story.erScuffle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Deputy Struggles With Same Man at Clinic",
                 body: "Defendant From Hospital Scuffle Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.erResistAgain"])
        ],
        "story.smallClaimsLie": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Keeps Deposit Again After Judgment",
                 body: "Defendant From Perjury Case Faces New Fraud Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.perjuryDeposit"])
        ],
        "story.dentistOfficeBreakin": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacy Door Pried Again",
                 body: "Defendant From Dental Break-In Seen at Pharmacy. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clinicBreakAgain"])
        ],
        "story.garageBurglary": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Garage Entered While Family Away",
                 body: "Defendant From Burglary Case Seen on Camera. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.garageAgain"])
        ],
        "story.shotgunFromTruck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Firearm Pawned After Truck Break-In",
                 body: "Defendant From Shotgun Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shotgunPawnAgain"])
        ],
        "story.barGlassInjury": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat Made to Bar Patron After Mug Case",
                 body: "Defendant From Bar Fight Case Cited for Threat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mugThreat"], sameVictim: true)
        ],
        "story.repeatBarAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Punch in Parking Lot Again, Victim Says",
                 body: "Defendant With Three Assault Priors Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotFightAgain"])
        ],
        "story.streetPillSale": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Street Sale to Undercover Officer",
                 body: "Defendant From Pill Sale Case Sells Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillSaleSecond"])
        ],
        "story.firefighterBurned": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Insurance Claim Filed for House Burned in Fire",
                 body: "Defendant From Firefighter Case Files False Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fireClaimBurn"])
        ]
    ]
}
