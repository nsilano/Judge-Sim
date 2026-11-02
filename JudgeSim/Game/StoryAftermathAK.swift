import Foundation

/// What follows the batch AK written cases. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
extension StoryAftermath {
    static let beatsAK: [String: [Beat]] = [
        "story.marketplaceTrailer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 45...240,
                 headline: "Stolen rental store chainsaws found in small engine shop",
                 body: "Six chainsaws and two pressure washers taken in a rental store break-in turned up in {D}'s shop with the stickers peeled off. {DL}'s stolen trailer case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.chainsawResale"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 20...120,
                 headline: "Sheriff warns buyers about too-good-to-be-true equipment deals",
                 body: "After the {DL} case, the sheriff's office is urging buyers to ask for a bill of sale and check serial numbers before paying cash for mowers, trailers, or tools online.")
        ],
        "story.auntPowerOfAttorney": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 60...300,
                 headline: "Church widower's account drained, son says",
                 body: "An 81-year-old widower's son says {D}, a volunteer driver at the man's church, was added to his father's checking account and spent $18,200. {DL}'s case over an aunt's savings was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.secondPowerOfAttorney"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.6, days: 20...120,
                 headline: "Elder law clinic offers free power of attorney reviews",
                 body: "The county bar's elder law committee will review powers of attorney for free at the senior center on Thursdays. Organizers cited the {DL} case, in which an 88-year-old nearly lost her nursing home bed."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Note in aunt's hymnal says 'buy that boy his truck'",
                 body: "A handwritten note found in the hymnal of the 88-year-old in the {DL} power of attorney case reads, \"Buy that boy his truck. He's my right hand.\" {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ],
        "story.golfCartDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 60...300,
                 headline: "Driver in golf cart death charged with DWI on causeway",
                 body: "Highway Patrol says {D}, whose golf cart death case was heard by Judge {JUDGE}, blew 0.12 after drifting across the causeway's center line at 1 a.m.",
                 followUps: ["story.followup.boatWhileImpaired"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.6, days: 20...120,
                 headline: "Port Hollis to require lap belts and speed limiters on rental carts",
                 body: "The town council voted to require working lap belts, brake inspections, and 15-mph limiters on all rental golf carts after the death of {V} on Ocean Drive."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Rental shop admits golf cart brake was patched with hose clamp",
                 body: "A mechanic for the rental company says the left rear brake cable on the cart in the {DL} case had been patched with a hose clamp after an earlier complaint. {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ],
        "story.birthdayParty": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.35, days: 30...180,
                 headline: "Principal reports man under protective order outside school",
                 body: "An elementary school principal says {D}, whose stalking case was heard by Judge {JUDGE}, parked across from the pickup line three afternoons in one week.",
                 followUps: ["story.followup.schoolPickupStalking"], sameVictim: true),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 20...120,
                 headline: "Domestic violence shelter adds court advocates",
                 body: "The county's domestic violence shelter has hired two advocates to go with victims to protective order hearings. The director said cases like {V}'s show \"the order is only paper until someone enforces it.\"")
        ],
        "story.deadBrotherIdentity": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 45...240,
                 headline: "Utility accounts opened in name of woman in memory care",
                 body: "A collections letter reached a nursing home for a resident in memory care. Deputies say the accounts were opened by her son, {D}, whose identity theft case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.utilityAccountFraud"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 20...120,
                 headline: "DMV now checks death records before issuing duplicate licenses",
                 body: "The DMV says its system now flags duplicate license requests for anyone listed as deceased, after a license was issued in a dead man's name in the {DL} case."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 90...300,
                 headline: "Widow's boyfriend found with second license in dead man's name",
                 body: "Deputies found a second license in {V}'s name on the boyfriend of {V}'s widow, who admitted using the papers. {DL}'s lawyer has asked Judge {JUDGE} to vacate the conviction.")
        ]
    ]
}
