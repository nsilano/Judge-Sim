import Foundation

/// What follows the batch BN stories: a return to this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBN: [String: [Beat]] = [
        "story.babysitterInjury": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Parent Threatens Teacher in School Pickup Line",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of threatening a school employee.",
                 followUps: ["story.followup.pickupLineThreatsBack"])
        ],
        "story.brakeCheckShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Motorist Drives Along Shoulder to Skip Exit Backup",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of driving along a highway shoulder.",
                 followUps: ["story.followup.shoulderPassBack"])
        ],
        "story.clerkShootsBack": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Shopper Returns to Closed Store Lot After Written Trespass Warning",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of entering a store lot after a written warning.",
                 followUps: ["story.followup.closedStoreLotBack"])
        ],
        "story.gasStationKidnapping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Bouquet With Handwritten Note Delivered to Protected Person",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of violating a protective order.",
                 followUps: ["story.followup.flowersNoteBack"])
        ],
        "story.neighborsMailbox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "'Mystery Box' Seller Ships Bricks to Online Buyers",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of selling boxes of bricks as electronics.",
                 followUps: ["story.followup.mysteryBoxBack"])
        ],
        "story.pharmacyRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pharmacist Spots Altered Quantity on Painkiller Prescription",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of changing a prescription.",
                 followUps: ["story.followup.alteredScriptBack"])
        ],
        "story.protectiveOrder": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Parent Ejected From Youth Soccer Game After Shouting Match",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of disorderly conduct at a youth soccer game.",
                 followUps: ["story.followup.soccerSidelineBack"])
        ],
        "story.sheriffEvidenceMoney": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Hunting Cabin 'Break-In' Claim Questioned by Insurer",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of making a false insurance claim.",
                 followUps: ["story.followup.cabinClaimBack"])
        ],
        "story.storageUnits": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Contractor's Truck Toolboxes Pried Open at Job Site",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of breaking into a contractor's truck.",
                 followUps: ["story.followup.jobsiteToolboxBack"])
        ],
        "story.streetRifle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Handgun Seen in Waistband at Youth Football Game",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of carrying a concealed handgun at a youth game.",
                 followUps: ["story.followup.waistbandGunBack"])
        ],
        "story.textMessages": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Student Portal Altered After Account Login From Home Network",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of changing grades through a teacher's account.",
                 followUps: ["story.followup.gradePortalBack"])
        ],
        "story.weddingDriveImpaired": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver Found Asleep in Running Truck at Boat Ramp",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of impaired driving.",
                 followUps: ["story.followup.boatRampDwiBack"])
        ]
    ]
}
