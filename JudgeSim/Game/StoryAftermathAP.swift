import Foundation

/// What follows the batch AP everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAP: [String: [Beat]] = [
        "story.restaurantTipSkim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Server at New Restaurant Accused of Skimming Tip Jar Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tipSkimTwo"])
        ],
        "story.texterCrash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Whose License Was Revoked After Crash Stopped Behind the Wheel",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.texterNoLicense"])
        ],
        "story.dogInHotCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cat Found Panting in Locked Car Outside Grocery Store, Owner Charged Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.catInHotCar"])
        ],
        "story.fakeLandscaper": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contractor Takes $3,000 Deposit, Never Starts Roof",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakeRoofer"], sameVictim: true)
        ],
        "story.foundPhoneSold": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Who Found Wallet Used Its Cards, Police Say",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.foundWalletKept"], sameVictim: true)
        ],
        "story.waterTowerClimb": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Trespasser Climbs Radio Tower, Needs Rescue",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.radioTowerClimb"], sameVictim: true)
        ],
        "story.selfCheckoutBanana": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Self-Checkout Shopper Again Charged With Skipping Scan",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bananaTwo"])
        ],
        "story.holidayInflatables": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Holiday Display Stolen From Yard Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.inflatablesYard"])
        ],
        "story.funeralScene": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Disrupts Graveside Service, Deputy Called",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.graveyardScene"])
        ],
        "story.diveBarShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threatening Letter Sent to Bar Witness Before Trial",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.witnessThreatLetter"], sameVictim: true)
        ],
        "story.schoolZoneCrash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver in School Zone Crash Caught Driving While Revoked",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dwlrAfterCrash"])
        ],
        "story.homeInvasionBurglary": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Safe From Home Invasion Resurfaces at Pawn Shop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stolenSafeResale"], sameVictim: true)
        ],
        "story.apartmentFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fire Victim Files Inflated Insurance Claim",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.insuranceFireClaim"])
        ],
        "story.parkingLotAbduction": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "No-Contact Order Violated by Defendant From Abduction Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stalkingCourtOrderAbduction"], sameVictim: true)
        ],
        "story.festivalOverdose": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Defendant From Overdose Case Charged With New Sale",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillMillAgain"])
        ],
        "story.poisonCoffee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat at New Workplace Follows Poisoning Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.workplaceThreat"], sameVictim: true)
        ],
        "story.fatalPunchParty": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Detention Officer Struck During Intake",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jailAssault"], sameVictim: true)
        ],
        "story.wrenchAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Mechanic Threatened Again After Wrench Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.wrenchAssaultThreat"], sameVictim: true)
        ]
    ]
}
