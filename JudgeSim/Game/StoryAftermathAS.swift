import Foundation

/// What follows the batch AS everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAS: [String: [Beat]] = [
        "story.starvedHorses": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Animal Control Returns to Farm After Earlier Case",
                 body: "Goats Found Without Water at Defendant's Property. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.horsesAgain"])
        ],
        "story.huntingPostedLand": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hunter Returns to Posted Land",
                 body: "Landowner Finds Defendant From Earlier Case in Same Field. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stillHunting"], sameVictim: true)
        ],
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
        "story.converterThefts": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Converters Cut From Church Vans",
                 body: "Defendant From Converter Case Linked by Scrap Yard. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.convertersAgain"])
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
        "story.mopedChaseNight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Moped Rider Flees From Deputy a Second Time",
                 body: "Defendant From Moped Chase Case Hides Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mopedAgain"])
        ],
        "story.pillsInPurse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pills Found in Car After Concert Case",
                 body: "Defendant Stopped With Oxycodone Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillsSecond"])
        ],
        "story.falseNameStop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "False Name Given Again at Traffic Stop",
                 body: "Warrant Found After Second Lie. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.falseNameAgain"])
        ],
        "story.smallClaimsLie": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Keeps Deposit Again After Judgment",
                 body: "Defendant From Perjury Case Faces New Fraud Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.perjuryDeposit"], sameVictim: true)
        ],
        "story.trapHouseDwelling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbors Report Visitors at New Address",
                 body: "Defendant From Drug House Case Raided Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.houseAgain"])
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
        "story.felonInPossession": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Felon Stopped With Ammunition and Holster",
                 body: "Defendant From Firearm Case Stopped Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.felonPistolAgain"])
        ],
        "story.barGlassInjury": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat Made to Bar Patron After Mug Case",
                 body: "Defendant From Bar Fight Case Cited for Threat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mugThreat"], sameVictim: true)
        ],
        "story.stalkerCoworker": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Order Violated Weeks After Stalking Case",
                 body: "Defendant From Coworker Case Seen Outside Workplace. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stalkerOrderViolation"], sameVictim: true)
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
        "story.parkingKnifeIntent": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Victim Receives Threat After Stabbing Case",
                 body: "Defendant From Nightclub Stabbing Case Contacts Witness. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.knifeThreatClub"], sameVictim: true)
        ],
        "story.vanCocaine": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver From Trafficking Case Stopped With Revoked License",
                 body: "Defendant Caught Driving a Week After Release. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.vanDwlr"])
        ],
        "story.firefighterBurned": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Insurance Claim Filed for House Burned in Fire",
                 body: "Defendant From Firefighter Case Files False Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fireClaimBurn"])
        ],
        "story.scaldChildAbuse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Child-Care Complaint After Earlier Injury Case",
                 body: "Defendant From Burn Case Faces Neglect Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.childCareLapse"])
        ],
        "story.schoolThreatPost": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Threatening Post Traced to Same Student",
                 body: "Defendant From School Threat Case Posts Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.postThreatAgain"])
        ]
    ]
}
