import Foundation

/// What follows the batch BB everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBB: [String: [Beat]] = [
        "story.cornFieldNight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Hauls Pumpkins From Field After Dark",
                 body: "Man Hauls Pumpkins From Field After Dark. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pumpkinFieldNight"])
        ],
        "story.ladderTruck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ladder Taken From Second Job Site",
                 body: "Ladder Taken From Second Job Site. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ladderAgain"])
        ],
        "story.dogTagScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Woman Sells Fake Pet Registration Door to Door",
                 body: "Woman Sells Fake Pet Registration Door to Door. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.leashTagScam"])
        ],
        "story.chemLawn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Sprays Brush Killer on Neighbor's Hedge",
                 body: "Man Sprays Brush Killer on Neighbor's Hedge. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chemHedge"])
        ],
        "story.pewShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Congregant Pushes Greeter Over Parking",
                 body: "Congregant Pushes Greeter Over Parking. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pewAgain"])
        ],
        "story.buffetCarryout": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Diners Carry Out Brunch Food in Purses",
                 body: "Diners Carry Out Brunch Food in Purses. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.brunchCarryout"])
        ],
        "story.salonWalkout": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Customer Walks Out of Barbershop Without Paying",
                 body: "Customer Walks Out of Barbershop Without Paying. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barberWalkout"])
        ],
        "story.moversHold": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Movers Hold Furniture for Extra Fees",
                 body: "Movers Hold Furniture for Extra Fees. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.moversAgain"])
        ],
        "story.valetGlovebox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Valet Takes Wallet From Console",
                 body: "Valet Takes Wallet From Console. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.valetWallet"])
        ],
        "story.rentalTires": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Customer Returns Rental With Swapped Wheels",
                 body: "Customer Returns Rental With Swapped Wheels. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rentalWipers"])
        ],
        "story.poolChemicals": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Pool Chemicals From Hardware Lot",
                 body: "Man Takes Pool Chemicals From Hardware Lot. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chlorineAgain"])
        ],
        "story.rentalBikeWreck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Customer Wrecks Rental Canoe and Leaves It",
                 body: "Customer Wrecks Rental Canoe and Leaves It. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.canoeWreck"])
        ],
        "story.rampLineFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parents Fight at Rink Over Snack Line",
                 body: "Parents Fight at Rink Over Snack Line. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rinkLineFight"])
        ],
        "story.raceTicketCopies": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Sells Copied Concert Tickets Outside Venue",
                 body: "Man Sells Copied Concert Tickets Outside Venue. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.concertTicketCopies"])
        ],
        "story.souvenirStroller": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shopper Hides Souvenirs in Backpack",
                 body: "Shopper Hides Souvenirs in Backpack. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stoleSouvenirs"])
        ],
        "story.chargerCable": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Cuts Cable From Second Charger",
                 body: "Man Cuts Cable From Second Charger. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cableAgain"])
        ],
        "story.ticketTearScream": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Tears Citation and Screams at Officer",
                 body: "Driver Tears Citation and Screams at Officer. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.citationScreamAgain"])
        ],
        "story.dogBiteSlap": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Strikes Owner of Dog That Lunged at Him",
                 body: "Man Strikes Owner of Dog That Lunged at Him. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.catBiteSlap"])
        ],
        "story.barredSinger": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Returns to Second Bar After Ban",
                 body: "Man Returns to Second Bar After Ban. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barredAgain"])
        ],
        "story.lifeguardChair": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Screams at Coach and Kicks Bench",
                 body: "Parent Screams at Coach and Kicks Bench. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.poolChairAgain"])
        ],
        "story.benchSmash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Smashes Park Pavilion Sign With a Bat",
                 body: "Teen Smashes Park Pavilion Sign With a Bat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shelterBatSmash"])
        ],
        "story.utilityGiftCards": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Caller Collects Gift Cards Claiming Water Will Be Cut",
                 body: "Caller Collects Gift Cards Claiming Water Will Be Cut. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.waterBillCards"])
        ],
        "story.payrollCheckCash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Cashes Stolen Check at Convenience Store",
                 body: "Man Cashes Stolen Check at Convenience Store. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stolenChecksAgain"])
        ],
        "story.mopedWrongWay": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teens on Scooters Ride Wrong Way Through Plaza",
                 body: "Teens on Scooters Ride Wrong Way Through Plaza. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scooterWrongWay"])
        ],
        "story.beachRoadRace": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rental Scooter Drivers Race Down Boardwalk Road",
                 body: "Rental Scooter Drivers Race Down Boardwalk Road. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boardwalkRace"])
        ],
        "story.firePitFeud": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Keeps Smoky Grill Going and Threatens Neighbor",
                 body: "Man Keeps Smoky Grill Going and Threatens Neighbor. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.grillFeud"])
        ],
        "story.treeHouseClimb": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Climbs Into Neighbor's Barn Loft",
                 body: "Man Climbs Into Neighbor's Barn Loft. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shedLoftClimb"])
        ],
        "story.bodegaBeer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Wine Bottles From Bodega Shelf",
                 body: "Man Takes Wine Bottles From Bodega Shelf. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bodegaWine"])
        ],
        "story.registerTwenties": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cashier Takes Cash From Till Over Weeks",
                 body: "Cashier Takes Cash From Till Over Weeks. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tillTwenties"])
        ],
        "story.groomerCage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Kennel Worker Leaves Dog in Hot Crate",
                 body: "Kennel Worker Leaves Dog in Hot Crate. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kennelDryer"])
        ],
        "story.drumKitVan": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Keyboard Taken From Church Van",
                 body: "Keyboard Taken From Church Van. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pianoVan"])
        ],
        "story.spotFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Vendors Fight Over Market Spot",
                 body: "Vendors Fight Over Market Spot. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.spotAgain"])
        ],
        "story.bikeLockCutter": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Student Cuts Scooter Lock and Rides Off",
                 body: "Student Cuts Scooter Lock and Rides Off. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scooterLockCutter"])
        ],
        "story.photoPrints": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Videographer Takes Payment and Never Delivers Footage",
                 body: "Videographer Takes Payment and Never Delivers Footage. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.videoNeverDelivered"])
        ],
        "story.swingChains": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Pulls Bolts From Playground Slide",
                 body: "Teen Pulls Bolts From Playground Slide. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.slidePins"])
        ],
        "story.lockChangeBelongings": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Locks Out Second Tenant and Keeps Belongings",
                 body: "Landlord Locks Out Second Tenant and Keeps Belongings. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lockoutSecond"])
        ],
        "story.plowSmash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Plow Driver Rams Parked Truck on Purpose",
                 body: "Plow Driver Rams Parked Truck on Purpose. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.plowAgain"])
        ],
        "story.trashCanBlaze": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Lights Dumpster Against Store Wall",
                 body: "Teen Lights Dumpster Against Store Wall. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dumpsterBlaze"])
        ],
        "story.aideCash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Aide Takes Jewelry From Another Resident's Room",
                 body: "Aide Takes Jewelry From Another Resident's Room. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.aideAgain"])
        ],
        "story.vapeGrab": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Grabs Energy Drinks and Runs",
                 body: "Teen Grabs Energy Drinks and Runs. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.energyDrinkGrab"])
        ],
        "story.foodDriveBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Cereal From Community Pantry Bin",
                 body: "Man Takes Cereal From Community Pantry Bin. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pantryBoxAgain"])
        ],
        "story.valveStems": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Cuts Valve Stems on Apartment Lot Cars",
                 body: "Man Cuts Valve Stems on Apartment Lot Cars. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stemsAgain"])
        ],
        "story.sidewalkLie": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Shouts From Curb After Bar Closes",
                 body: "Man Shouts From Curb After Bar Closes. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.curbShouter"])
        ],
        "story.resortRobes": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Guest Takes Cabin Bedding and Dishes",
                 body: "Guest Takes Cabin Bedding and Dishes. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cabinTowels"])
        ],
        "story.gymClose": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Studio Owner Sells Annual Passes Then Closes",
                 body: "Studio Owner Sells Annual Passes Then Closes. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.studioClose"])
        ],
        "story.greenhouseRocks": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor Throws Rocks Through Garage Windows",
                 body: "Neighbor Throws Rocks Through Garage Windows. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shedGlassRocks"])
        ],
        "story.lunchBenefits": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Lies on Application for Rent Assistance",
                 body: "Man Lies on Application for Rent Assistance. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.housingBenefits"])
        ],
        "story.propaneShort": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Seller Fills Camping Tanks Short and Charges Full",
                 body: "Seller Fills Camping Tanks Short and Charges Full. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.butaneShort"])
        ]
    ]
}
