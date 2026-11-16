import Foundation

/// What follows sixteen earlier stories: the same defendant back in this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBI: [String: [Beat]] = [
        "story.motorcycleChase": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Rider Pops Wheelie Through School Crosswalk, Bystander Video Shows",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.motorcycleChaseAgain2"])
        ],
        "story.dopeHouseTrailer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Pharmacist Spots Altered Prescription From Trailer Park Resident",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dopeHouseTrailerAgain2"])
        ],
        "story.parkingDeckRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Power Tools Walked Out of Hardware Store in Duffel Bag",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.parkingDeckRobberyAgain2"])
        ],
        "story.nursingAideNeglect": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Home Care Aide Used Client's Debit Card for Personal Bills, Family Says",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nursingAideNeglectAgain2"])
        ],
        "story.passwordReset": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Course Partner's Thesis Folder Deleted at 2 A.M.",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.passwordResetAgain2"])
        ],
        "story.dmvCounter": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Voicemails Threaten License Examiner and Supervisor",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dmvCounterAgain2"])
        ],
        "story.gasCanSiphon": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Church Van's Catalytic Converter Sawed Off Overnight",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gasCanSiphonAgain2"])
        ],
        "story.photoExtortion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Private Photos of Former Partner Posted to Group Page",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.photoExtortionAgain2"])
        ],
        "story.schoolPost": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Student Reports Armed Man Outside Gym; Nothing Found",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.schoolPostAgain2"])
        ],
        "story.minivanChildDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Driver With Revoked License Stopped at Checkpoint",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.minivanChildDeathAgain2"])
        ],
        "story.cocaineBagStop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Undercover Buy at Laundromat Lot Recorded on Camera",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cocaineBagStopAgain2"])
        ],
        "story.sweepstakesParlor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Dagger Found in Jacket After Bar Disturbance Call",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sweepstakesParlorAgain2"])
        ],
        "story.unlockedGunToddler": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Toddler Left in Hot Car While Parent Shops",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.unlockedGunToddlerAgain2"])
        ],
        "story.employeeIdentityTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Dental Office Bookkeeper Skims Patient Refunds",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.employeeIdentityTheftAgain2"])
        ],
        "story.lotteryWinner": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Retirees Paid Fees to a Self-Styled Money Manager",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotteryWinnerAgain2"])
        ],
        "story.keyedCarLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.25, days: 30...240,
                 headline: "Neighbor's Fence Panels Pulled Down and Dumped",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.keyedCarLotAgain2"])
        ]
    ]
}
