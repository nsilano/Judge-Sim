import Foundation

/// What follows the batch BK stories: the defendant returns to this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBK: [String: [Beat]] = [
        "story.kitchenStrangulation": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Protective Order Violated at Ex-Partner's Gym",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge after the same court order was again at issue.",
                 followUps: ["story.followup.kitchenStrangulationBack"])
        ],
        "story.contractorDeposits": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Storm Tarp Deposit Vanishes With Contractor",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge involving a different homeowner.",
                 followUps: ["story.followup.contractorDepositsBack"])
        ],
        "story.taxPreparer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Preparer Forged Client's Signature on Refund Loan",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new forgery charge from a former client.",
                 followUps: ["story.followup.taxPreparerBack"])
        ],
        "story.sellPillsAtWork": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pills Found in Glovebox Pill Bottle Marked for Someone Else",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was stopped on a routine traffic matter and faces a new drug count.",
                 followUps: ["story.followup.sellPillsAtWorkBack"])
        ],
        "story.vanCocaine": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Cocaine Found in Dry Box at Lake Boat Ramp",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was stopped for a routine boat check and faces a new drug count.",
                 followUps: ["story.followup.vanCocaineBack"])
        ],
        "story.barBrokenBottle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pharmacy Clerk Shoved Over Refill Delay",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new assault charge from a trip to a pharmacy.",
                 followUps: ["story.followup.barBrokenBottleBack"])
        ],
        "story.cyclistHitAndRun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver Raced Freight Train Over Crossing, Deputies Say",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new traffic charge from a railroad crossing.",
                 followUps: ["story.followup.cyclistHitAndRunBack"])
        ],
        "story.burnedCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pontoon Boat Reported Stolen Turns Up in Relative's Barn",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new insurance fraud charge over a missing boat.",
                 followUps: ["story.followup.burnedCarBack"])
        ],
        "story.fenceLine": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Neighbor's Pecan Trees Cut Down Along New Property Line",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge from another boundary quarrel.",
                 followUps: ["story.followup.fenceLineBack"])
        ],
        "story.evidenceRoom": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Youth Baseball League Treasurer Missing $9,000",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new embezzlement charge involving another organization.",
                 followUps: ["story.followup.evidenceRoomBack"])
        ],
        "story.witnessThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Tow Driver Threatened Over Impounded Car",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new threat charge after a confrontation with a driver.",
                 followUps: ["story.followup.witnessThreatBack"])
        ],
        "story.missingToddler": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Child Left Alone in Hot Car at Discount Store",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new child neglect charge.",
                 followUps: ["story.followup.missingToddlerBack"])
        ],
        "story.informantBuy": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Food Truck Window Used for Cocaine Sale, Deputies Say",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new sale charge after another undercover buy.",
                 followUps: ["story.followup.informantBuyBack"])
        ],
        "story.coldCaseGenealogy": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Retired Deputy Flashes Old Badge at Campground",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge after an encounter at a campground.",
                 followUps: ["story.followup.coldCaseGenealogyBack"])
        ],
        "story.wrongApartment": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Off-Duty Officer Charged With Blocking Deputy at Cousin's Stop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge after a traffic stop involving a relative.",
                 followUps: ["story.followup.wrongApartmentBack"])
        ],
        "story.affluenzaCrash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Truck Tears Up High School Football Field in Late-Night Spin-Outs",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new property charge from a night at a school field.",
                 followUps: ["story.followup.affluenzaCrashBack"])
        ],
        "story.showerStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Paint Thrown on Former Roommate's Door and Porch",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new vandalism charge involving a former roommate.",
                 followUps: ["story.followup.showerStabbingBack"])
        ],
        "story.hiredTeen": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Burglary Claim for Jewelry Questioned by Insurer",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new fraud charge involving an insurance claim.",
                 followUps: ["story.followup.hiredTeenBack"])
        ],
        "story.jailSmuggling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Forged Refill at Pharmacy Drive-Thru Leads to Fraud Charge",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge involving a pharmacy.",
                 followUps: ["story.followup.jailSmugglingBack"])
        ],
        "story.arsenicWidow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Elderly Neighbor Says $18,000 Went Missing After Helping With Bills",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge involving an elderly neighbor.",
                 followUps: ["story.followup.arsenicWidowBack"])
        ],
        "story.textingSuicide": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Home Address and Daily Route Posted in Gaming Server",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new harassment charge.",
                 followUps: ["story.followup.textingSuicideBack"])
        ],
        "story.moonshineExplosion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Hounds Found Without Water in Backyard Pen",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new animal cruelty charge.",
                 followUps: ["story.followup.moonshineExplosionBack"])
        ],
        "story.huntingAccident": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Hunter Found on Posted Farmland Without Permission",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge from another hunting season.",
                 followUps: ["story.followup.huntingAccidentBack"])
        ],
        "story.copperTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Catalytic Converters Found in Man's Shed, Deputies Say",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new stolen-goods charge.",
                 followUps: ["story.followup.copperTheftBack"])
        ],
        "story.bingoHall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Fake Fire Department Fund Collected Cash From Shop Owners",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new fraud charge involving a charity collection.",
                 followUps: ["story.followup.bingoHallBack"])
        ],
        "story.deedForgery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Forged Lien Release Handed to Title Clerk",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge after a document was filed in the county office.",
                 followUps: ["story.followup.deedForgeryBack"])
        ],
        "story.groceryFall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Basement Flood Claim Listed Old Appliances as New, Insurer Says",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new insurance fraud charge over a flooded basement.",
                 followUps: ["story.followup.groceryFallBack"])
        ]
    ]
}
