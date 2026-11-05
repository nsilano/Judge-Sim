import Foundation

/// What follows the batch AX everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAX: [String: [Beat]] = [
        "story.marketScale": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Vendor From Rigged Scale Case Sells at Another Market",
                 body: "Vendor From Rigged Scale Case Sells at Another Market. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scaleRecheck"])
        ],
        "story.driveThruDash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Drive-Thru Customer Leaves Without Paying Again",
                 body: "Drive-Thru Customer Leaves Without Paying Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.windowDashAgain"])
        ],
        "story.rareBookLift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Library Reports More Rare Books Missing After Earlier Case",
                 body: "Library Reports More Rare Books Missing After Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bookLiftAgain"])
        ],
        "story.churchBellPaint": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Church Painted After Earlier Case",
                 body: "Another Church Painted After Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.steepleAgain"])
        ],
        "story.plowMailbox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Plow Knocks Down Mailboxes Again",
                 body: "Plow Knocks Down Mailboxes Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mailboxAgain2"])
        ],
        "story.yardSignTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Campaign Signs Taken Again",
                 body: "Campaign Signs Taken Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.signsAgain"])
        ],
        "story.halloweenEggs": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Eggs Thrown at Cars Again",
                 body: "Eggs Thrown at Cars Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.eggsAgain"])
        ],
        "story.pumpkinPatchTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pumpkins Taken From Another Farm Stand",
                 body: "Pumpkins Taken From Another Farm Stand. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pumpkinsAgain"])
        ],
        "story.cemeteryFlowers": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Grave Flowers Missing at Second Cemetery",
                 body: "Grave Flowers Missing at Second Cemetery. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.flowersAgain"])
        ],
        "story.firewoodLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Firewood Taken Again From Roadside Seller",
                 body: "Firewood Taken Again From Roadside Seller. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.woodAgain"])
        ],
        "story.baitShopTill": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bait Shop Drawer Emptied Again",
                 body: "Bait Shop Drawer Emptied Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tillAgain2"])
        ],
        "story.cartInPond": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Carts Found in Creek After Earlier Case",
                 body: "Carts Found in Creek After Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cartsAgain"])
        ],
        "story.bowlingAlleyScuffle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bowler Back in Court After Another League Night",
                 body: "Bowler Back in Court After Another League Night. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bowlingAgain"])
        ],
        "story.barTabSkip": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Bar Tab Skipped",
                 body: "Another Bar Tab Skipped. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tabAgain"])
        ],
        "story.tireSwapScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Seller Of 'New' Tires Back With a Different Customer",
                 body: "Seller Of 'New' Tires Back With a Different Customer. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tiresAgain"])
        ],
        "story.mowCrewNoShow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Lawn Crew Takes Prepayment Again",
                 body: "Lawn Crew Takes Prepayment Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mowAgain"])
        ],
        "story.formulaShoplift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Formula Taken From Another Pharmacy",
                 body: "Formula Taken From Another Pharmacy. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.formulaAgain"])
        ],
        "story.perfumeShoplift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Perfume Taken From Second Store",
                 body: "Perfume Taken From Second Store. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.perfumeAgain"])
        ],
        "story.pizzaOrderScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fraudulent Pizza Order Picked Up Again",
                 body: "Fraudulent Pizza Order Picked Up Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pizzaAgain"])
        ],
        "story.utilityShutoffCall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Power-Cut Call Leads to Redeemed Cards",
                 body: "Another Power-Cut Call Leads to Redeemed Cards. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shutoffAgain"])
        ],
        "story.lockedPhoneSale": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Locked Phone Sold Again",
                 body: "Locked Phone Sold Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lockedAgain"])
        ],
        "story.towTruckOvercharge": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Tow Fees Questioned Again",
                 body: "Tow Fees Questioned Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.towAgain"])
        ],
        "story.stereoNoise": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Car Stereo Noise Again at Night",
                 body: "Car Stereo Noise Again at Night. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bassAgain"])
        ],
        "story.leafBlowerDawn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Leaf Blower at Dawn Again",
                 body: "Leaf Blower at Dawn Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.blowerAgain"])
        ],
        "story.cartParkingFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parking Lot Dispute Turns Physical Again",
                 body: "Parking Lot Dispute Turns Physical Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cartShoveAgain"])
        ],
        "story.roadRageGesture": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Shouts at Motorist Again",
                 body: "Driver Shouts at Motorist Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gestureAgain"])
        ],
        "story.shedSprayPaint": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Shed Painted",
                 body: "Another Shed Painted. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shedPaintAgain"])
        ],
        "story.pepperSprayParty": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pepper Spray Used Again at a Gathering",
                 body: "Pepper Spray Used Again at a Gathering. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pepperAgain"])
        ],
        "story.schoolLotMarijuana": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Marijuana Found in Car at School Event Again",
                 body: "Marijuana Found in Car at School Event Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.leafAgain"])
        ],
        "story.borrowedBike": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Borrowed Bike Sold Again",
                 body: "Borrowed Bike Sold Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bikeAgain"])
        ],
        "story.landfillSalvage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Scavenger Back at Landfill Fence",
                 body: "Scavenger Back at Landfill Fence. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.landfillAgain"])
        ],
        "story.cellTowerClimb": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Photographer Back at Tower Fence",
                 body: "Photographer Back at Tower Fence. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.towerAgain"])
        ],
        "story.schoolAfterHours": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Adult on Playground After Hours Again",
                 body: "Adult on Playground After Hours Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.playgroundAgain"])
        ],
        "story.tailgatingTruck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Tailgating Again on the Highway",
                 body: "Tailgating Again on the Highway. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tailgateAgain"])
        ],
        "story.expiredLicenseStop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Stopped Again After License Lapse",
                 body: "Driver Stopped Again After License Lapse. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.expiredAgain"])
        ],
        "story.taserCarry": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stun Gun Found at Another Event",
                 body: "Stun Gun Found at Another Event. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stunAgain"])
        ],
        "story.voicemailThreatBoss": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Former Cashier Leaves Another Voicemail",
                 body: "Former Cashier Leaves Another Voicemail. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.voicemailAgain"])
        ],
        "story.stolenTrailerHitch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Stolen Trailer Frame Sold Again",
                 body: "Stolen Trailer Frame Sold Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trailerAgain"])
        ],
        "story.fakeParkingTicket": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fake Citations Appear Again",
                 body: "Fake Citations Appear Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.citationsAgain"])
        ],
        "story.schoolPermitForge": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Student Forges Another Signature",
                 body: "Student Forges Another Signature. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.permitAgain"])
        ],
        "story.carBreakinGym": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another Truck Window Smashed Outside a Gym",
                 body: "Another Truck Window Smashed Outside a Gym. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gymBreakAgain"])
        ],
        "story.chaseOnBike": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cyclist Flees Deputy Again",
                 body: "Cyclist Flees Deputy Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bikeFleeAgain2"])
        ],
        "story.cardSwapGas": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cloned Card Used at Another Pump",
                 body: "Cloned Card Used at Another Pump. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cardSwapAgain"])
        ],
        "story.passwordBorrow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ex Logs Into Another Account",
                 body: "Ex Logs Into Another Account. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.passwordAgain"])
        ],
        "story.ghostKitchenFee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Permit Help Fee Taken Again",
                 body: "Permit Help Fee Taken Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.permitFeeAgain"])
        ],
        "story.stolenCharger": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Waiting Room Theft Again",
                 body: "Waiting Room Theft Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chargerAgain"])
        ],
        "story.lostPackageLocker": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Package Locker Opened With Wrong Code Again",
                 body: "Package Locker Opened With Wrong Code Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lockerAgain2"])
        ],
        "story.rentalTrailerNotReturned": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rental Trailer Kept Late Again",
                 body: "Rental Trailer Kept Late Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trailerLate"])
        ],
        "story.campgroundHookups": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Camper Hooks Up Without Paying Again",
                 body: "Camper Hooks Up Without Paying Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hookupAgain"])
        ],
        "story.hayBaleTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hay Bales Taken From Another Farm",
                 body: "Hay Bales Taken From Another Farm. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hayAgain"])
        ],
        "story.catchBasinCover": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "More Drain Covers Vanish",
                 body: "More Drain Covers Vanish. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.coversAgain"])
        ],
        "story.streetSignTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "More Street Signs Missing",
                 body: "More Street Signs Missing. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.signsAgain2"])
        ],
        "story.houseSitter": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "House Sitter Takes Jewelry Again",
                 body: "House Sitter Takes Jewelry Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sitterAgain"])
        ],
        "story.nannyPetty": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Babysitter Takes Cash Again",
                 body: "Babysitter Takes Cash Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sitterCash"])
        ],
        "story.coachFees": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Treasurer Uses Team Money Again",
                 body: "Treasurer Uses Team Money Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.treasurerThird"])
        ],
        "story.campusBike": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another E-Bike Listed Online",
                 body: "Another E-Bike Listed Online. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ebikeAgain"])
        ],
        "story.phoneWaitress": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Phone Pocketed at Another Restaurant",
                 body: "Phone Pocketed at Another Restaurant. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.phoneAgain2"])
        ],
        "story.glovesShoplift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Boots Worn Out of Another Store",
                 body: "Boots Worn Out of Another Store. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bootsAgain"])
        ],
        "story.bakerySkip": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pastry Box Leaves By Back Door Again",
                 body: "Pastry Box Leaves By Back Door Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pastryAgain"])
        ],
        "story.liquorTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Liquor Bottle Taken Again",
                 body: "Liquor Bottle Taken Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.liquorAgain2"])
        ],
        "story.cigarCaseSmash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Smoke Shop Case Smashed Again",
                 body: "Smoke Shop Case Smashed Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.caseAgain"])
        ],
        "story.atmHammer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "ATM Smashed at Second Bank",
                 body: "ATM Smashed at Second Bank. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.atmAgain"])
        ],
        "story.wrongWayRoad": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Wrong-Way Driver Again",
                 body: "Wrong-Way Driver Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.wrongWayAgain"])
        ],
        "story.hotelLobbySleep": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Lobby Sleeper Back at Another Hotel",
                 body: "Lobby Sleeper Back at Another Hotel. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lobbyAgain"])
        ],
        "story.barBanned": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Banned Patron Returns to Second Bar",
                 body: "Banned Patron Returns to Second Bar. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bannedAgain"])
        ],
        "story.burnoutLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Burnouts in Another Lot",
                 body: "Burnouts in Another Lot. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.burnoutsAgain"])
        ],
        "story.noiseGenerator": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Loud Generator Again After a Storm",
                 body: "Loud Generator Again After a Storm. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.generatorAgain"])
        ],
        "story.paintballStreet": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Paintball Shot at Pedestrian Again",
                 body: "Paintball Shot at Pedestrian Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.paintballAgain"])
        ],
        "story.snowballCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ice Thrown at Another Car",
                 body: "Ice Thrown at Another Car. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.snowballAgain"])
        ],
        "story.sprinklerFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor Dispute Over Hose Turns Physical Again",
                 body: "Neighbor Dispute Over Hose Turns Physical Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sprinklerAgain"])
        ],
        "story.bikeLaneShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cyclist Shoves Another Walker",
                 body: "Cyclist Shoves Another Walker. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trailShoveAgain"])
        ],
        "story.fakeCashMarket": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Counterfeit Bills at Another Market",
                 body: "Counterfeit Bills at Another Market. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakeBillsAgain"])
        ],
        "story.badCheckTires": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Worthless Check for Tires Again",
                 body: "Worthless Check for Tires Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tiresCheckAgain"])
        ],
        "story.stolenCheckbook": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Found Checkbook Used Again",
                 body: "Found Checkbook Used Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.checkbookAgain"])
        ],
        "story.transitFare": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cloned Pass Used Again",
                 body: "Cloned Pass Used Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fareAgain"])
        ],
        "story.radioStationFake": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contest Prize Under a Fake Name Again",
                 body: "Contest Prize Under a Fake Name Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.prizeAgain"])
        ],
        "story.bingoCheat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Altered Bingo Cards at Another Hall",
                 body: "Altered Bingo Cards at Another Hall. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bingoAgain"])
        ],
        "story.craigslistHorse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fake Livestock Sale Again",
                 body: "Fake Livestock Sale Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.horseAgain"])
        ],
        "story.rentalDepositKeep": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Landlord Keeps Another Deposit",
                 body: "Landlord Keeps Another Deposit. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.depositAgain"])
        ],
        "story.gardenGrow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "More Plants Found in Garden",
                 body: "More Plants Found in Garden. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.growAgain"])
        ],
        "story.catSittingFraud": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pet Sitter Takes Deposits Again",
                 body: "Pet Sitter Takes Deposits Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sitterRepeat"])
        ],
        "story.christmasLights": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor's Lights Taken Again",
                 body: "Neighbor's Lights Taken Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lightsAgain"])
        ],
        "story.fakeCharityDoor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Door-to-Door Fund Collector Returns",
                 body: "Door-to-Door Fund Collector Returns. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fundAgain"])
        ],
        "story.bridgeRailTag": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bridge Rail Tagged Again",
                 body: "Bridge Rail Tagged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.railTagAgain"])
        ],
        "story.trainCarTag": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Freight Car Painted Again",
                 body: "Freight Car Painted Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.freightAgain"])
        ],
        "story.carHoodDent": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hood Dent Dispute Again",
                 body: "Hood Dent Dispute Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hoodAgain"])
        ],
        "story.tireDeflate": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Tires Let Down Again",
                 body: "Tires Let Down Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tiresLetDown"])
        ],
        "story.windowEgg": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Eggs Hit Another Window",
                 body: "Eggs Hit Another Window. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.eggsWindowAgain"])
        ],
        "story.doorKick": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Door Kicked Again",
                 body: "Door Kicked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kickAgain"])
        ],
        "story.shutterTear": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shutters Torn Again",
                 body: "Shutters Torn Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shuttersAgain"])
        ],
        "story.fenceFlatten": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fence Backed Into Again",
                 body: "Fence Backed Into Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fenceAgain"])
        ],
        "story.drunkPorchBell": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Doorbell Rung Again at Midnight",
                 body: "Doorbell Rung Again at Midnight. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bellAgain"])
        ],
        "story.callbackPrank": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Repeat Calls to a Shop",
                 body: "Repeat Calls to a Shop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pranksAgain"])
        ],
        "story.fakeRobberyReport": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another False Robbery Report",
                 body: "Another False Robbery Report. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.robberyHoaxAgain"])
        ],
        "story.overdoseHoax": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Another False 911 Call",
                 body: "Another False 911 Call. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hoaxAgain"])
        ],
        "story.fakeStolenCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Car Reported Stolen",
                 body: "Second Car Reported Stolen. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stolenCarAgain"])
        ],
        "story.givenFalseDOB": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "False Name Given Again",
                 body: "False Name Given Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nameAgain"])
        ],
        "story.hidesInBushes": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hiding From Deputies Again",
                 body: "Hiding From Deputies Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hidesAgain"])
        ],
        "story.needlesCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Needles in Car Again",
                 body: "Needles in Car Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.needlesAgain"])
        ],
        "story.sleepingDriver": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Asleep at the Wheel Again",
                 body: "Asleep at the Wheel Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sleepAgain"])
        ]
    ]
}
