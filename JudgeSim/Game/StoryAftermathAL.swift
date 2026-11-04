import Foundation

/// What follows the batch AL and AM everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAL: [String: [Beat]] = [
        "story.aisleSeven": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Woman from shoplifting case pulls away from deputy at department store",
                 body: "A woman stopped at a department store refused to stand or give her name for twelve minutes. She is {D}, whose shoplifting case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.aisleResisting"]),
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 60...240,
                 headline: "Thrift store reports another shoplifting incident",
                 body: "A thrift store manager says {D}, whose earlier shoplifting case was heard by Judge {JUDGE}, was seen on camera taking items again.",
                 followUps: ["story.followup.thriftStoreSecond"])
        ],
        "story.footChase": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man leads deputies on six-minute car chase",
                 body: "Deputies say {D}, whose earlier resisting case was heard by Judge {JUDGE}, sped through two neighborhoods before stopping on a dead-end street.",
                 followUps: ["story.followup.footChaseElude"])
        ],
        "story.parkingLotScream": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Store manager says customer threatened to wait in the parking lot",
                 body: "A manager reported a threatening call from {D}, whose earlier disorderly conduct case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.managerThreat"])
        ],
        "story.postedPond": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Gate chain cut at farm pond",
                 body: "A farmer says the chain on his pond gate was cut overnight. A trail camera shows a truck like {D}'s, whose trespass case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.pondGateChain"], sameVictim: true)
        ],
        "story.revokedToWork": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man stopped again at checkpoint on revoked license",
                 body: "A trooper stopped {D}, whose earlier revoked license case was heard by Judge {JUDGE}, at a checkpoint near a poultry plant.",
                 followUps: ["story.followup.revokedAgain"])
        ],
        "story.gloveboxLeaf": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Glass pipe found in car at traffic stop",
                 body: "Deputies found a glass pipe in a car driven by {D}, whose marijuana case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.paraphernaliaPipe"])
        ],
        "story.parkingSpace": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Car keyed in church parking lot during Sunday service",
                 body: "A man says his car was keyed during a Sunday service. His parking space dispute with {D} was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.keyedCar"], sameVictim: true)
        ],
        "story.truckBedTools": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen saw shows up at pawn shop",
                 body: "A pawn shop clerk flagged a circular saw stolen from a truck. The ticket was signed by {D}, whose earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.pawnedDrill"], sameVictim: true)
        ],
        "story.adderallStop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacist refuses suspicious prescription",
                 body: "A pharmacist refused to fill a prescription for sixty Adderall after noticing a mismatched signature. The patient was {D}, whose earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.scriptRefill"])
        ],
        "story.bicycleRack": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pawn shop flags second stolen bicycle",
                 body: "The pawn shop clerk who handled an earlier stolen bicycle recognized the seller, {D}, when a second bike came in. Judge {JUDGE} heard the first case.",
                 followUps: ["story.followup.bikeResaleTwo"])
        ],
        "story.gasDriveOff": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another gas drive-off reported",
                 body: "A gas station camera caught {D}, whose earlier gas theft case was heard by Judge {JUDGE}, driving away without paying again.",
                 followUps: ["story.followup.gasDriveOffTwo"])
        ],
        "story.bottleWindow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Banned bar customer returns",
                 body: "A bartender called deputies when {D}, whose earlier window case was heard by Judge {JUDGE}, walked in after being banned.",
                 followUps: ["story.followup.barBanTrespass"])
        ],
        "story.libraryBan": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man shouts at riders outside library bus stop",
                 body: "A bus driver reported {D}, whose library trespass case was heard by Judge {JUDGE}, blocking the shelter and shouting.",
                 followUps: ["story.followup.libraryBanScream"])
        ],
        "story.lawnMowerNeighbor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor's push mower turns up at flea market",
                 body: "A woman found her push mower for sale at a flea market. The seller, {D}, had a lawn mower case heard by Judge {JUDGE}.",
                 followUps: ["story.followup.mowerResale"], sameVictim: true)
        ],
        "story.leashFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Park walker reports threat",
                 body: "A park walker recorded {D}, whose earlier assault case was heard by Judge {JUDGE}, saying he would put him on the ground again.",
                 followUps: ["story.followup.leashThreat"], sameVictim: true)
        ],
        "story.stolenCarReport": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Insurer questions stolen car claim",
                 body: "An insurer paid a claim on a car it later learned had been found. The claimant is {D}, whose false report case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.carClaimFalse"])
        ],
        "story.packageThief": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Debit card from stolen package used at dollar store",
                 body: "A debit card mailed in a package that was taken from a porch was used three times at a dollar store. {D}, whose package theft case was heard by Judge {JUDGE}, is charged.",
                 followUps: ["story.followup.packageCardUse"], sameVictim: true)
        ],
        "story.golfCartJoyride": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen back at pond where golf cart was dumped",
                 body: "Deputies found {D}, whose golf cart case was heard by Judge {JUDGE}, sitting by the same pond at 1 a.m.",
                 followUps: ["story.followup.golfCartTrespass"])
        ],
        "story.refusedID": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man refuses to give name to deputy again",
                 body: "A deputy says {D}, whose earlier refused ID case was heard by Judge {JUDGE}, refused to give a name three times at a gas station.",
                 followUps: ["story.followup.refusedIDAgain"])
        ],
        "story.oxyBottle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Altered prescription flagged by pharmacist",
                 body: "A pharmacist noticed a prescription quantity changed from 10 to 40. The patient was {D}, whose pill bottle case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.oxyRefill"])
        ],
        "story.dineDash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pizza place reports walk-out from sheriff's flyer",
                 body: "A restaurant owner recognized two customers from a sheriff's flyer after they left without paying. One was {D}, whose diner case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.dineDashTwo"])
        ],
        "story.fenceKick": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbors scuffle again over fence line",
                 body: "A man says his neighbor shoved him against a truck while he was installing new fence posts. The neighbor is {D}, whose fence case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.fenceKickAssault"], sameVictim: true)
        ],
        "story.walletCard": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen card used for gas at same station",
                 body: "A credit card stolen from a truck was used for $96 in fuel. The pump camera shows {D}, whose found wallet case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.walletCardGas"])
        ]
    ]
}
