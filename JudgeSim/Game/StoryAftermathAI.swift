import Foundation

/// What follows the batch AI written cases. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
extension StoryAftermath {
    static let beatsAI: [String: [Beat]] = [
        "story.fosterChildInjury": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Toddler burned while being babysat, parent says",
                 body: "A parent says a two-year-old came home from {D}'s house with a burn across the back of the hand. {DL}, whose foster child case was heard by Judge {JUDGE}, had been babysitting neighborhood children.",
                 followUps: ["story.followup.babysittingBurn"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 30...150,
                 headline: "Social worker reports threat after foster license revoked",
                 body: "A DSS social worker says {D}, whose foster care license was revoked after the case heard by Judge {JUDGE}, waited by the worker's car and said, \"I know where you live.\"",
                 followUps: ["story.followup.socialWorkerThreat"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 20...120,
                 headline: "County seeks more foster homes as cases grow",
                 body: "Hollis County DSS says it has 61 children in foster care and 34 licensed homes. The director said the case of {D} \"shook a lot of good foster parents\" and asked the community to consider fostering."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Home video shows foster child's fall from bunk bed",
                 body: "A home security camera nobody checked before trial shows the toddler in {DL}'s care slipping from the bunk ladder with an arm caught in the rungs while {DL} was in the kitchen. {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ],
        "story.dogfightingRing": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Scarred dogs and a treadmill found behind rental house",
                 body: "Animal services seized four dogs with fresh wounds from a rental house where {D} lives, along with a carpet-covered treadmill. {DL}'s earlier case over fourteen dogs on Shiloh Road was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.dogsBehindRental"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 20...120,
                 headline: "Neighbor says {DL} made a threat over dog tip",
                 body: "A Shiloh Road neighbor's doorbell camera recorded {D} saying \"snitches end up in the same hole as those dogs.\" {DL}'s dogfighting case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.tipsterThreat"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.6, days: 30...150,
                 headline: "Dogs seized on Shiloh Road find homes",
                 body: "Nine of the fourteen dogs seized from {D}'s property have been adopted after months of rehabilitation, the county rescue league says. One, a gray female named Biscuit, now visits the children's ward at the hospital as a therapy dog.")
        ],
        "story.crabPotTheft": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Gill nets slashed at Bayard landing",
                 body: "Two gill nets were cut where they hung drying at the Bayard landing overnight. The landing's new camera shows one truck in the lot: {D}'s. {DL}'s crab pot case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.cutNets"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Fight on the dock ends with a gaff and nine stitches",
                 body: "An argument over a channel at the Bayard landing ended with a waterman stitched up after {D} swung a steel gaff. Witnesses disagree about who came at whom. Judge {JUDGE} heard {DL}'s earlier case.",
                 followUps: ["story.followup.landingGaff"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 15...90,
                 headline: "Landing gets a camera after crab pot case",
                 body: "The county put a camera and lights on the Bayard Boat Landing after the crab pot case against {D}. Watermen say gear theft has gone on for years. \"Now maybe it'll stop,\" {V} said.")
        ],
        "story.hotelPartyOverdose": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 45...240,
                 headline: "Deputy revives overdose victim; texts point to {DL}",
                 body: "A deputy used two doses of naloxone to revive a young adult outside a convenience store. Texts on the phone show a request for \"one\" and the reply \"outside\" from {D}, whose case after a motel overdose death was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.naloxoneNight"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Driver slumped at wheel after crash; naloxone revives",
                 body: "A car took out three mailboxes and stopped in a yard. Deputies found {D} slumped at the wheel and gave naloxone. A blood test showed fentanyl. Judge {JUDGE} heard {DL}'s earlier case.",
                 followUps: ["story.followup.fentanylCrash"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.7, days: 15...90,
                 headline: "{VL}'s mother hands out naloxone at the motel where {V.he} died",
                 body: "{V}'s mother stood outside the motel where {V.he} died and handed out free naloxone kits with the county health department. \"If one of these had been in that room, {V.he}'d be twenty-one next month,\" she said."),
            Beat(triggers: [.cleared, .freed], chance: 0.4, days: 20...120,
                 headline: "Lawmakers asked to rewrite death by distribution law",
                 body: "After the case of {D}, whose charge turned on whether a $20 payment was a sale, the district attorney asked local legislators to change the law so that delivering a fatal dose is enough."),
        ],
        "story.weddingRingPawn": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.35, days: 45...240,
                 headline: "Widow's account drained at ATM, bank says",
                 body: "Bank cameras show {D} making nine late-night ATM withdrawals from {D.his} grandmother's account. {DL}'s earlier case over her wedding ring was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.grandmasCard"], sameVictim: true),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 60...300,
                 headline: "Neighbor's tools turn up at pawn shop",
                 body: "A chainsaw and trimmer taken from an open garage were pawned the next morning under {D}'s license. Judge {JUDGE} heard {DL}'s earlier case over a pawned wedding ring.",
                 followUps: ["story.followup.neighborsChainsaw"]),
            Beat(triggers: [.probation, .prison, .cleared, .freed], chance: 0.6, days: 15...90,
                 headline: "{VL} gets her ring back",
                 body: "{V}'s wedding ring is back on her hand. Church members took up a collection to pay the pawn shop. \"I keep turning it with my thumb,\" {V} said. \"Earl would laugh at all this fuss.\"")
        ]
    ]
}
