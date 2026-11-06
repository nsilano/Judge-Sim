import Foundation

/// What follows the batch BF everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBF: [String: [Beat]] = [
        "story.coachRecruitBribes": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Former Coach Linked to a Second College's Recruit List",
                 body: "Prior Bribery Case Resurfaces at a New School. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.coachRecruitReturnBf"])
        ],
        "story.neverHeldFestival": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Promoter Sells Tickets to a New Festival Months After a Failed One",
                 body: "Prior Festival Promoter Faces Refund Claims Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.festivalAgainBf"])
        ],
        "story.falseTeamAccusation": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Student With Prior False Report Accuses Another Team",
                 body: "Door Camera Again Contradicts the Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.teamClaimAgainBf"])
        ],
        "story.deviceOnDeliveryDriver": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Delivery Driver Forced to Drive With a Device; Suspect Linked to Prior Case",
                 body: "Second Delivery Driver Held in a Fake Bomb Scheme. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deviceDriverAgainBf"])
        ],
        "story.lotteryClerkInsider": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Clerk Linked to Prior Lottery Fraud Redeems Another Unclaimed Ticket",
                 body: "Same Scheme, Same Clerk, Another Ticket. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotteryAgainBf"])
        ],
        "story.mugshotRemovalFees": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Website Operator Again Charges to Remove Arrest Photos",
                 body: "Prior Mugshot Site Case Returns With a New Domain. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mugshotAgainBf"])
        ],
        "story.laneClosurePayback": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Aide Again Orders Lane Closures to Punish a Rival",
                 body: "Prior Traffic Jam Scandal Linked to Second Order. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.laneClosureAgainBf"])
        ],
        "story.neighborsWatchStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighborhood Patrol Leader Again Accused of Attacking a Visitor",
                 body: "Prior Patrol Case Resurfaces in a New Stabbing. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.watchStabAgainBf"])
        ],
        "story.unneededSurgeries": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Surgeon Linked to Earlier Case Again Billed for Unneeded Procedures",
                 body: "Second Clinic Shows the Same Billing Pattern. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.surgeryAgainBf"])
        ],
        "story.phantomPatientClaims": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Billing Company Owner Again Sends Claims for Patients Who Do Not Exist",
                 body: "Reused Numbers Appear in a Second Insurer's Files. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.phantomAgainBf"])
        ],
        "story.tornadoReliefKept": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Charity Director Again Accused of Keeping Disaster Donations",
                 body: "Prior Relief Fund Case Returns After a Flood. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.reliefAgainBf"])
        ],
        "story.slowCarHoodClaims": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Claimant Again Steps in Front of Slow Cars, Files New Injury Claims",
                 body: "Prior Staged-Accident Case Returns With a Tenth Claim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hoodAgainBf"])
        ],
        "story.localCelebrityTracker": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fan With Prior Stalking Case Tracks Another Public Figure",
                 body: "Same Pattern, New Target. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trackerAgainBf"])
        ],
        "story.syrupReserveHeist": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Trucker Linked to Syrup Heist Accused of Hauling Away Honey",
                 body: "Prior Cargo Theft Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.syrupAgainBf"])
        ],
        "story.reptileHoardCruelty": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Breeder With Prior Animal Case Again Found With Dying Animals",
                 body: "Snakes and Lizards Seized From a New Barn. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.reptileAgainBf"])
        ],
        "story.brotherNameForTwentyYears": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Again Linked to Dead Relative's Name",
                 body: "Prior Identity Case Returns With a New Dead Name. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nameAgainBf"])
        ],
        "story.droneDropAtTheYard": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Drone Builder From Prior Case Back After a New Drop",
                 body: "Second Prison Delivery Traced to Same Block. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.droneAgainBf"])
        ],
        "story.riggedMidwayGame": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Midway Operator With Prior Case Runs a Fixed Balloon Game",
                 body: "Inspector Finds Lead Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.midwayAgainBf"])
        ],
        "story.santaSuitIntruder": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Suit-Wearing Intruder Back in Court After a Second Party",
                 body: "Prior Santa Burglary Defendant Wears a Costume Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.santaAgainBf"])
        ],
        "story.fortyDollarBankNote": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bank Robber Tied to Earlier Case Leaves Another Clue",
                 body: "Prior Robbery Defendant Uses a Pay Stub. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.slipAgainBf"])
        ],
        "story.stormLootingCrew": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Looter Tied to Prior Hurricane Case Hits Flooded Homes Again",
                 body: "Emergency Crews Find the Same Truck. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.floodLootAgainBf"])
        ],
        "story.vacationRentalNoHouse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rental Scammer With Prior Case Lists a Mountain Cabin",
                 body: "Guests Arrive to the Wrong Address Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rentalAgainBf"])
        ],
        "story.fairgroundSwingFall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ride Operator With Prior Case Faces New Failure at a Carnival",
                 body: "Another Weld Gives Way. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.swingAgainBf"])
        ],
        "story.campgroundBluegrassBrawl": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Camper Tied to Earlier Festival Fight Faces New Campground Assault",
                 body: "Fiddle Case Used as a Weapon. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bluegrassAgainBf"])
        ],
        "story.horseShowTreasurer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Clerk With Prior Embezzlement Case Under Review at a New Office",
                 body: "County Fund Again Pays for Horses. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.horseFundAgainBf"])
        ],
        "story.moonshineRunCrash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver From Earlier Chase Flees Again With a Trunk of Jars",
                 body: "Back Roads, New Crash. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.moonshineAgainBf"])
        ],
        "story.wrongHouseShot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Homeowner Tied to Earlier Shooting Fires Again Through a Door",
                 body: "Another Neighbor Wounded at the Wrong Door. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.doorShotAgainBf"])
        ],
        "story.nursingHomeNightShift": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Aide From Earlier Neglect Case Faces New Allegation at Another Home",
                 body: "Resident Left Unchecked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nightAideAgainBf"])
        ],
        "story.kittenFoodBurglars": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pet Sitter Tied to Earlier Burglaries Gets New Keys",
                 body: "Seven More Homes Report Missing Items. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.petSitterAgainBf"])
        ],
        "story.grandchildCallerScheme": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Courier From Earlier Scheme Collects Cash From More Seniors",
                 body: "Same Script, New Doorbells. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.callerAgainBf"])
        ],
        "story.bakeryInsuranceBlaze": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Owner From Earlier Fire Case Faces Blaze at a Second Shop",
                 body: "Insurance Claim Filed Within Hours. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bakeryFireAgainBf"])
        ],
        "story.fentanylSalineSwap": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Nurse From Earlier Case Under Review at a New Hospital",
                 body: "Saline Again Found in Painkiller Vials. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.vialsAgainBf"])
        ],
        "story.clinicWithoutLicense": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Unlicensed Clinic Operator Reopens Under a New Name",
                 body: "Prior Fake Clinic Case Linked to Spa Treatments. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clinicAgainBf"])
        ],
        "story.fakeIllnessFundraiser": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fundraiser With Prior Fraud Case Posts a New Plea for Help",
                 body: "Donors Again Find No Records. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fundraiserAgainBf"])
        ],
        "story.golfPartnerTips": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Golf Partner From Earlier Trading Case Buys Before Another Merger",
                 body: "Texts Again Hint at a Tip. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.golfTipAgainBf"])
        ],
        "story.mowerOnTheBypass": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Rides a Golf Cart Down the Bypass After Drinking",
                 body: "Driver Rides a Golf Cart Down the Bypass After Drinking. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mowerAgainBf"])
        ],
        "story.buriedCoinDig": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Treasure Hunter Digs Up a Pasture",
                 body: "Treasure Hunter Digs Up a Pasture. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.coinDigAgainBf"])
        ],
        "story.harborMonsterHoax": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Posts Fake Lake Creature Video, Triggers a Rescue",
                 body: "Man Posts Fake Lake Creature Video, Triggers a Rescue. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lakeMonsterAgainBf"])
        ],
        "story.cheeseTruckTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Trailer of Aged Wine Vanishes From a Truck Stop",
                 body: "Trailer of Aged Wine Vanishes From a Truck Stop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cheeseAgainBf"])
        ],
        "story.goatInTheSanctuary": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Prankster Lets Sheep Loose in a School Gym",
                 body: "Prankster Lets Sheep Loose in a School Gym. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.goatAgainBf"])
        ],
        "story.gardenGnomeHeist": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Thirty Lawn Flamingos From a Garden Shop",
                 body: "Man Takes Thirty Lawn Flamingos From a Garden Shop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gnomeAgainBf"])
        ],
        "story.creamPieSmash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Diner Throws a Pie at a School Board Member",
                 body: "Diner Throws a Pie at a School Board Member. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pieAgainBf"])
        ],
        "story.mascotNappingCase": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fan Takes a Hockey Team's Mascot Head",
                 body: "Fan Takes a Hockey Team's Mascot Head. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mascotAgainBf"])
        ],
        "story.giantPumpkinSmash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contest Favorite's Giant Watermelon Found Smashed",
                 body: "Contest Favorite's Giant Watermelon Found Smashed. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pumpkinAgainBf"])
        ],
        "story.spotlightHunt": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hunters Shine Spotlights at Bears From a Truck at Night",
                 body: "Hunters Shine Spotlights at Bears From a Truck at Night. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.spotlightAgainBf"])
        ],
        "story.electionSignSabotage": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Rips Down Dozens of Yard Signs for a School Levy",
                 body: "Driver Rips Down Dozens of Yard Signs for a School Levy. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.signAgainBf"])
        ],
        "story.oysterBedPoach": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Boater Cited for Harvesting Clams From a Closed Flat",
                 body: "Boater Cited for Harvesting Clams From a Closed Flat. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.oysterAgainBf"])
        ],
        "story.rodeoClownShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rodeo Clown Shoves a Heckler at the Chutes",
                 body: "Rodeo Clown Shoves a Heckler at the Chutes. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rodeoAgainBf"])
        ],
        "story.plowChaseLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Snowplow Driver Chases a Truck Through a Parking Lot",
                 body: "Snowplow Driver Chases a Truck Through a Parking Lot. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.plowAgainBf"])
        ],
        "story.pranksterBalloonCall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Calls in a Runaway Kite With a 'Child' Aboard",
                 body: "Man Calls in a Runaway Kite With a 'Child' Aboard. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.balloonAgainBf"])
        ]
    ]
}
