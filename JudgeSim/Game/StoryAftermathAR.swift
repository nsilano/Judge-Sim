import Foundation

/// What follows the batch AR everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAR: [String: [Beat]] = [
        "story.hardwareShoplift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shopper Stopped With Tools at Different Store",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.toolShoplift"])
        ],
        "story.mailboxBaseball": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Night of Smashed Mailboxes",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mailboxAgain"])
        ],
        "story.ballgamePistol": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Defendant From Ballgame Case Stopped With Pistol in Console",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.expiredPermitAgain"])
        ],
        "story.streetRaceWreck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver in Race Wreck Caught Behind the Wheel With Suspended License",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.raceDwlr"])
        ],
        "story.laptopCarBreakin": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Trailhead Car Smashed, Camera Catches Man",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trailheadAgain"])
        ],
        "story.exTrespassPorch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ex Seen at Woman's Door Again After Trespass Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.porchReturns"], sameVictim: true)
        ],
        "story.phoneKnockedAway": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "911 Caller's Phone Taken Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.interfereAgain"], sameVictim: true)
        ],
        "story.tillShortage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Employer Reports Cash Missing After Clerk's Hiring",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tillAgain"])
        ],
        "story.roommateCreditCard": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Card Opened in Roommate's Name",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cardAgain"])
        ],
        "story.checkFromGrandma": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Check From Same Account Cashed",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.grandmaSecondCheck"], sameVictim: true)
        ],
        "story.checkpointDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Refuses Breath Test at Stop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.breathRefusalAgain"])
        ],
        "story.coachShoveRef": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Referee Gets Threatening Message After Court Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.refereeThreat"], sameVictim: true)
        ],
        "story.exPostingCampaign": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Posts About Ex Resume Under New Accounts",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.postsAgain"], sameVictim: true)
        ],
        "story.formerEmployeeFiles": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Former Employee Hits New Employer's Server",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.employeeFilesSecond"])
        ],
        "story.plannedPharmacyRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacy Gets Threatening Call",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pharmacyThreatsAgain"])
        ],
        "story.toddlerLeftHome": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Child Again Found Unsupervised, Neighbor Says",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.toddlerAgain"])
        ],
        "story.partyGrab": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Domestic Complaint Against Boyfriend",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.grabAgainParty"], sameVictim: true)
        ],
        "story.roadRageBat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver With Bat Threatens Motorist Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.batAgain"])
        ],
        "story.fourthDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver With Four Prior DWIs Stopped Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fifthDwi"])
        ],
        "story.debtKidnapping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threats Sent to Escaped Victim",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.debtThreatGarage"], sameVictim: true)
        ]
    ]
}
