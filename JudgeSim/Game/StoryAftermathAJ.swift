import Foundation

/// What follows the batch AJ written cases. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
extension StoryAftermath {
    static let beatsAJ: [String: [Beat]] = [
        "story.sweepstakesParlor": [
            Beat(triggers: [.freed, .probation], chance: 0.3, days: 45...240,
                 headline: "Convenience store clerk shoved, robbed overnight",
                 body: "A clerk was shoved into a cigarette rack and robbed of $412 overnight. Police say the store camera shows {D}, whose sweepstakes parlor robbery case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.parlorSecondRobbery"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 20...120,
                 headline: "County commissioners weigh limits on sweepstakes parlors",
                 body: "After the robbery at Lucky 7 Sweepstakes, commissioners are considering a rule closing sweepstakes parlors at midnight. Clerks told the board they work alone with thousands in cash."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Roommate admits sweepstakes robbery, lawyer says",
                 body: "{DL}'s roommate, arrested in another robbery, told detectives he borrowed {DL}'s car the night of the Lucky 7 holdup and left the money and the BB pistol in it. {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ],
        "story.tobaccoBarnFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...150,
                 headline: "Neighbor says farmer threatened him after barn fire case",
                 body: "A neighboring farmer says {D}, whose barn fire case was heard by Judge {JUDGE}, came to his fence and said, \"You know how fast an old house goes up.\" His son recorded part of it.",
                 followUps: ["story.followup.barnNeighborThreat"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 30...180,
                 headline: "Historical society maps the county's last log tobacco barns",
                 body: "After the {DL} family barn burned, the county historical society began cataloging the log tobacco barns still standing. It has found 31, down from more than 2,000 a century ago."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 90...300,
                 headline: "Fired farmhand admits setting barn fires",
                 body: "A former farmhand arrested for burning a barn in the next county told investigators he also set the fire at {DL}'s farm, a week after {DL} fired him. {DL}'s lawyer has asked Judge {JUDGE} to vacate the conviction.")
        ],
        "story.fireDeptFunds": [
            Beat(triggers: [.freed, .probation], chance: 0.3, days: 60...300,
                 headline: "Church food pantry raffle comes up short",
                 body: "A local church says $3,600 in raffle money for its food pantry never arrived. The volunteer who sold the tickets was {D}, whose fire department case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.raffleMoney"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.6, days: 20...120,
                 headline: "Fire department replaces expired gear with community donations",
                 body: "The volunteer fire department bought twelve new sets of turnout gear after neighbors raised $14,000 online. The department now requires two signatures on every check."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 90...300,
                 headline: "Former fire department treasurer kept cash box key, audit finds",
                 body: "A second audit found that the fire department's previous treasurer still had a key to the cash box and took fundraiser money for years. {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ],
        "story.cattleAuction": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 45...240,
                 headline: "Stock trailer stolen from sale barn found behind barn",
                 body: "A gooseneck stock trailer stolen from the Hollis Livestock Market turned up behind {D}'s barn with its VIN plate pried off. {DL}'s cattle case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.trailerCattle"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 20...120,
                 headline: "Sale barn now checks ear tags against ownership papers",
                 body: "The Hollis Livestock Market says it will check every consignment's ear tags against the registry before a sale, after 22 head were sold by someone who didn't own them.")
        ],
        "story.bouncerFlashlight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 45...240,
                 headline: "Bar customer's jaw broken by security guard",
                 body: "A customer's jaw was broken in two places outside a downtown bar. The guard is {D}, whose flashlight case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.bouncerSecondFight"]),
            Beat(triggers: [.freed, .probation, .prison, .cleared], chance: 0.5, days: 20...120,
                 headline: "Bar owners rethink 'tactical' flashlights for bouncers",
                 body: "Several downtown bar owners say they've taken the steel flashlights away from their door staff after the {DL} case. \"A flashlight is for seeing IDs,\" one said."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Delivery driver says he saw knife in alley fight",
                 body: "A delivery driver parked in the alley the night of the bar fight says {V} had a knife half out of a pocket when {DL} swung. {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ]
    ]
}
