import Foundation

/// What follows the batch AR everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAR: [String: [Beat]] = [
        "story.hardwareShoplift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shopper Stopped With Tools at Different Store",
                 body: "Defendant From Drill Case Caught at Home Improvement Chain. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.toolShoplift"])
        ],
        "story.mailboxBaseball": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Night of Smashed Mailboxes",
                 body: "Pickup Seen Near Damaged Boxes, Registered to Defendant From Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mailboxAgain"])
        ],
        "story.ballgamePistol": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Defendant From Ballgame Case Stopped With Pistol in Console",
                 body: "Second Concealed Weapon Charge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.expiredPermitAgain"])
        ],
        "story.streetRaceWreck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver in Race Wreck Caught Behind the Wheel With Suspended License",
                 body: "Suspended Driver Stopped on County Road. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.raceDwlr"])
        ],
        "story.laptopCarBreakin": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Trailhead Car Smashed, Camera Catches Man",
                 body: "Break-In Pattern at Trail Lots Traced to Defendant. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trailheadAgain"])
        ],
        "story.exTrespassPorch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ex Seen at Woman's Door Again After Trespass Case",
                 body: "Second Trespass Complaint Follows Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.porchReturns"], sameVictim: true)
        ],
        "story.phoneKnockedAway": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "911 Caller's Phone Taken Again",
                 body: "Second Emergency-Line Interference Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.interfereAgain"], sameVictim: true)
        ],
        "story.tillShortage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "New Employer Reports Cash Missing After Clerk's Hiring",
                 body: "Defendant From Embezzlement Case Under Suspicion Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tillAgain"])
        ],
        "story.roommateCreditCard": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Card Opened in Roommate's Name",
                 body: "Defendant From Identity Case Faces New Credit Fraud. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cardAgain"])
        ],
        "story.checkFromGrandma": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Check From Same Account Cashed",
                 body: "Defendant From Forgery Case Back at the Bank. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.grandmaSecondCheck"], sameVictim: true)
        ],
        "story.checkpointDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Refuses Breath Test at Stop",
                 body: "Defendant From Checkpoint Case Charged With DWI Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.breathRefusalAgain"])
        ],
        "story.coachShoveRef": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Referee Gets Threatening Message After Court Case",
                 body: "Coach From Earlier Case Accused of Texting Threats. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.refereeThreat"], sameVictim: true)
        ],
        "story.exPostingCampaign": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Posts About Ex Resume Under New Accounts",
                 body: "Second Cyberstalking Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.postsAgain"], sameVictim: true)
        ],
        "story.formerEmployeeFiles": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Former Employee Hits New Employer's Server",
                 body: "Defendant From Earlier Access Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.employeeFilesSecond"])
        ],
        "story.plannedPharmacyRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacy Gets Threatening Call",
                 body: "Defendant From Planned Robbery Case Accused of Phoned Threat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pharmacyThreatsAgain"])
        ],
        "story.toddlerLeftHome": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Child Again Found Unsupervised, Neighbor Says",
                 body: "Second Child-Care Complaint Against Defendant. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.toddlerAgain"])
        ],
        "story.partyGrab": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Domestic Complaint Against Boyfriend",
                 body: "Defendant From Party Case Accused of Grabbing Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.grabAgainParty"], sameVictim: true)
        ],
        "story.roadRageBat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver With Bat Threatens Motorist Again",
                 body: "Defendant From Road Rage Case Accused of New Threat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.batAgain"])
        ],
        "story.fourthDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver With Four Prior DWIs Stopped Again",
                 body: "Repeat Impaired Driver Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fifthDwi"])
        ],
        "story.debtKidnapping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threats Sent to Escaped Victim",
                 body: "Defendant From Kidnapping Case Charged With New Threats. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.debtThreatGarage"], sameVictim: true)
        ]
    ]
}
