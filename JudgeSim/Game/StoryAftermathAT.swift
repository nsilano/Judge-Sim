import Foundation

/// What follows the batch AT everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAT: [String: [Beat]] = [
        "story.donationJarTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Collection Jar Missing From Another Store",
                 body: "Defendant From Charity Jar Case Seen at Counter. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jarAgain"])
        ],
        "story.parkSwingDamage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Playground Slide Cut Overnight",
                 body: "Park Damage Linked to Earlier Defendant. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.swingSetAgain"], sameVictim: true)
        ],
        "story.guitarPawned": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Amplifier Pawned After Roommate Leaves",
                 body: "Another Pawn Ticket Names Defendant. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.guitarShopAgain"])
        ],
        "story.handicapPlacardForge": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Counterfeit Placard Found on Another Car",
                 body: "Defendant From Placard Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.placardAgain"])
        ],
        "story.poolAfterHours": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Closed Pool Entered Again",
                 body: "Defendant From Pool Case Over the Fence Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.poolAgain"], sameVictim: true)
        ],
        "story.fireworksStreet": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fireworks Again on Quiet Street",
                 body: "Defendant From Earlier Cul-de-Sac Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fireworksAgain"])
        ],
        "story.usedCarScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Car Sale Collapses",
                 body: "Buyer Says Same Seller Offered Another Title Promise. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.carScamAgain"])
        ],
        "story.pickupLineSpeeding": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Speeding Near School Again",
                 body: "Defendant From Pickup Line Case Cited Near Crosswalk. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pickupLineRepeat"])
        ],
        "story.rifleAtKids": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landowner Confronts Another Group",
                 body: "Defendant From Rifle Case Accused of New Confrontation. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rifleAgain"])
        ],
        "story.textbookTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Textbooks Taken From Another Campus Store",
                 body: "Defendant From Bookstore Case Back With Backpack. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.textbookAgain"])
        ],
        "story.golfCartDwi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Stopped Again on Golf Cart",
                 body: "Defendant From Golf Cart Case Stopped After Party. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cartDwiAgain"])
        ],
        "story.giftCardSwap": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Gift Cards Drained at Second Store",
                 body: "Defendant From Sticker Swap Case Flagged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.giftCardAgain"])
        ],
        "story.stagedFallClaim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fall Claim Questioned Again",
                 body: "Defendant From Staged Fall Case Files New Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stagedAgain"])
        ],
        "story.churchTreasurerSkim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Congregation Reports Missing Offering",
                 body: "Treasurer From Earlier Case Hired by New Church. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.treasurerAgain"])
        ],
        "story.liquorStoreHoldup": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Clerk Threatened at Closing",
                 body: "Defendant From Liquor Store Case Linked by Cap. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.liquorAgain"])
        ],
        "story.bakeryRearBreakin": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bakery Door Pried Again",
                 body: "Defendant From Break-In Case Seen at Second Bakery. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bakeryAgain"])
        ],
        "story.pedestrianHit": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver From Crosswalk Case Stopped With Revoked License",
                 body: "Defendant Caught Driving a Week After Plea. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.walkerDwlr"])
        ],
        "story.packagedMarijuana": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Deputies Find Packaged Marijuana Again",
                 body: "Defendant From Bagged Marijuana Case Searched Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.packagedAgain"])
        ],
        "story.neighborStalking": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor Appears Again After Stalking Order",
                 body: "Defendant From Fence Case Seen Outside Window. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stalkNeighborOrder"], sameVictim: true)
        ],
        "story.nursingAideNeglect": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Care Facility Reports Missing Charts Again",
                 body: "Aide From Neglect Case Hired at New Facility. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.aideCharted"])
        ],
        "story.trafficStopPunch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Resists Deputy Again",
                 body: "Defendant From Traffic Stop Case Pulls Away. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deputySecond"])
        ],
        "story.roommateStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Threat Made to Dead Man's Family",
                 body: "Defendant From Stabbing Case Contacts Relative. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.roommateThreat"])
        ],
        "story.ambushAtHome": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Witness From Shooting Case Receives Threat",
                 body: "Defendant From Window Shooting Case Contacts Witness. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ambushWitness"])
        ],
        "story.armedConvenienceRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Store Robbed After Earlier Case",
                 body: "Defendant From Convenience Robbery Case Linked by Mask. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.convenienceAgain"])
        ],
        "story.fairgroundRiot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fair Organizers Receive Threat After Riot Case",
                 body: "Defendant From Fairground Disturbance Threatens Vendor. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.riotThreat"])
        ]
    ]
}
