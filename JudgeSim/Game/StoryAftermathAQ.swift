import Foundation

/// What follows the batch AQ everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAQ: [String: [Beat]] = [
        "story.bikeRackTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Electric Scooter Cut From Rack Near Campus",
                 body: "Second Rack Theft Traced to Defendant From Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scooterTheft"])
        ],
        "story.keyedCarLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Car Keyed at Parking Lot Dispute",
                 body: "Defendant From Earlier Case Named in New Vandalism Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.keyedAgain"])
        ],
        "story.patioShouting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Shouting at Cars Again After Earlier Citation",
                 body: "Deputy Finds Defendant From Patio Case in the Road. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.streetShoutingAgain"])
        ],
        "story.gloveboxMarijuana": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Marijuana Found Again in Traffic Stop",
                 body: "Second Possession Charge for Defendant From Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gloveboxTwo"])
        ],
        "story.prankNineOneOne": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another False Emergency Call Traced to Defendant",
                 body: "Hoax Call Brings Deputies to Neighbor's House Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.prankAgain"])
        ],
        "story.porchPackages": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "More Packages Stolen After Earlier Case",
                 body: "Doorbell Camera Shows Defendant Taking Boxes Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.porchPackagesTwo"])
        ],
        "story.forgedPrescription": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacist Flags Another Suspicious Prescription",
                 body: "Defendant From Earlier Forgery Case Back at the Counter. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.forgedPrescriptionAgain"])
        ],
        "story.caretakerAccount": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Elderly Client Reports Missing Money",
                 body: "Home Aide From Earlier Case Named in New Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.caretakerSecondClient"])
        ],
        "story.fenderBenderRun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pickup Hits Parked Car and Leaves Again",
                 body: "Defendant From Earlier Hit-and-Run Linked by Paint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hitAndRunSecond"])
        ],
        "story.contractorTools": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Contractor's Tools Pawned",
                 body: "Pawn Records Name Defendant From Earlier Larceny Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.contractorToolsTwo"], sameVictim: true)
        ],
        "story.skimmerGasPump": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cloned Cards Used at ATMs Across Two Counties",
                 body: "Defendant From Skimmer Case Linked to New Fraud. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.skimmerAgain"])
        ],
        "story.strangleDispute": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "No-Contact Order Violated Weeks After Choking Case",
                 body: "Defendant From Domestic Case Appears at Victim's Door. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dvpoAfterChoke"], sameVictim: true)
        ],
        "story.trunkOpioids": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pills Found in Defendant's Car After New Stop",
                 body: "Fentanyl Case Defendant Stopped Again With Pills. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trunkPillsPwisd"])
        ],
        "story.housePorchShots": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat Made to Neighbor After Shooting Case",
                 body: "Defendant From Fence Dispute Case Accused of New Threat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shotsAgainFence"], sameVictim: true)
        ],
        "story.lakeCrashFatal": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver in Fatal Lake Road Crash Stopped Behind the Wheel",
                 body: "Defendant Charged With Driving While License Revoked. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dwiAfterLakeCrash"])
        ]
    ]
}
