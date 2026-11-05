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
        "story.patioShouting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Shouting at Cars Again After Earlier Citation",
                 body: "Deputy Finds Defendant From Patio Case in the Road. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.streetShoutingAgain"])
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
        "story.contractorTools": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Contractor's Tools Pawned",
                 body: "Pawn Records Name Defendant From Earlier Larceny Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.contractorToolsTwo"], sameVictim: true)
        ]
    ]
}
