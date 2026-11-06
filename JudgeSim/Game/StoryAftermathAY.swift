import Foundation

/// What follows the batch AY everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAY: [String: [Beat]] = [
        "story.ferryDeckStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Passenger Cut at Dock After Argument",
                 body: "Defendant From Ferry Case Seen Holding a Blade. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ferryAgain"])
        ],
        "story.marinaHullCocaine": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cocaine Found in Boat Engine Compartment",
                 body: "Boat Owner From Earlier Case Again at the Marina. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hullBricksAgain"])
        ],
        "story.deerStandShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hunter Fires Toward Occupied Stand Again",
                 body: "Defendant From Earlier Shot Case Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.standShotAgain"])
        ],
        "story.poolPartyDrowning": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Toddler Pulled From Hot Tub at Cookout",
                 body: "Host From Earlier Drowning Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hotTubAgain"])
        ],
        "story.tractorTheftRing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Skid Steer and Mower Taken From Farm",
                 body: "Hauler From Tractor Case Linked to New Theft. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tractorsAgain"])
        ],
        "story.ghostGunKit": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Kit-Built Rifle Surfaces",
                 body: "Convicted Felon Again Linked to Serial-Less Gun. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kitAgain"])
        ],
        "story.promNightFentanyl": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pills Pressed With Fentanyl Seized From Student",
                 body: "Seller From Prom Night Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fentanylAgain"])
        ],
        "story.landlordRentThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Threatens Another Tenant About Papers",
                 body: "Landlord From Earlier Extortion Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rentThreatAgain"])
        ],
        "story.caretakerSavingsMove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Caretaker Charged With Taking Widow's Checks",
                 body: "Defendant From Earlier Savings Case Faces New Client's Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.caretakerAgain"])
        ],
        "story.custodyExchangeFlight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Mother's Boyfriend Keeps Child After School Pickup",
                 body: "Defendant From Custody Flight Case Accused of Keeping Child. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.exchangeAgain"])
        ],
        "story.rooftopPharmacyBreakIn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Vet Clinic Roof Cut for Drug Cabinet",
                 body: "Roof Tool Linked to Defendant in Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.roofAgain"])
        ],
        "story.hospitalBillingIdentity": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Clinic Receptionist's Logins Linked to Fraud Alerts",
                 body: "Defendant From Hospital ID Case Now at a Clinic. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clinicIdentityAgain"])
        ],
        "story.tavernTruckShots": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shots Fired Into Roadside Store From Truck",
                 body: "Defendant From Tavern Shooting Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tavernAgain"])
        ],
        "story.fishPlantGhostPayroll": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ghost Employees Found at Second Employer",
                 body: "Payroll Manager From Seafood Case Now at a Warehouse. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ghostPayrollAgain"])
        ],
        "story.countyFuelDepotSkim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Town Garage Loses Fuel Over Months",
                 body: "Fuel Attendant From County Case Linked to Town Garage. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.depotAgain"])
        ],
        "story.stagedCrashClaim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Low-Speed Crash Claim Raises Flags",
                 body: "Claimant From Staged Crash Case Files Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stagedClaimAgain"])
        ],
        "story.diningWitnessThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Warns Another Witness Outside Courthouse",
                 body: "Defendant From Diner Threat Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.threatAgain"])
        ],
        "story.highSchoolPostThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Online Threat Names Middle School Dance",
                 body: "Defendant From School Threat Case Linked to New Post. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.schoolPostAgain"])
        ],
        "story.bridgeRescueAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Strikes Deputy During Second Welfare Check",
                 body: "Defendant From Bridge Rescue Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bridgeAgain"])
        ],
        "story.parkedAmbulanceJoyride": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fire Truck Moved From Bay by Visitor",
                 body: "Defendant From Ambulance Case Seen at Another Station. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ambulanceAgain"])
        ]
    ]
}
