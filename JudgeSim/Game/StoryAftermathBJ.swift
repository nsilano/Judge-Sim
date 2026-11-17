import Foundation

/// What follows the batch BJ stories: the defendant returns to this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBJ: [String: [Beat]] = [
        "story.oldMillRoad": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver Clocked at 80 Through Highway Work Zone",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was stopped after troopers say {D} weaved through a marked work zone at high speed.",
                 followUps: ["story.followup.oldMillRoadBack"])
        ],
        "story.parkingLotShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Tow Driver Held at Gunpoint in Apartment Lot",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of drawing a handgun on the driver of a truck hooking {D}'s car.",
                 followUps: ["story.followup.parkingLotShootingBack"])
        ],
        "story.rentalFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Landlord Flattens Neighbor's Shed With Skid Steer",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of running heavy equipment through a shed that a neighbor says stood on the neighbor's land.",
                 followUps: ["story.followup.rentalFireBack"])
        ],
        "story.borrowedTruck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Man Keeps Borrowed Log Splitter, Sells It Online",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of selling a borrowed machine online without the owner's approval.",
                 followUps: ["story.followup.borrowedTruckBack"])
        ],
        "story.parkingKnifeIntent": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Dagger Found in Boot at Traffic Stop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was stopped for a brake light, and an officer reports a hidden blade in {D}'s footwear.",
                 followUps: ["story.followup.parkingKnifeIntentBack"])
        ],
        "story.copperWireStripping": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Aluminum Bleachers Vanish From Closed Ballfield",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of selling bleacher sections from a closed ballfield to a scrap yard.",
                 followUps: ["story.followup.copperWireStrippingBack"])
        ],
        "story.restaurantFireClaim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Owner Claims Theft of Walk-In Cooler Found in Storage Unit",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of claiming equipment stolen that investigators say was sitting in a rented storage unit.",
                 followUps: ["story.followup.restaurantFireClaimBack"])
        ],
        "story.tellerDrawer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Worker Cashes Forged $3,800 Check at Credit Union",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of cashing a check that the account holder says carries a forged signature.",
                 followUps: ["story.followup.tellerDrawerBack"])
        ],
        "story.gunUnderSeat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pistol Found in Tackle Box on Bass Boat",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was checked by a wildlife officer, who reports finding a loaded pistol aboard {D}'s boat.",
                 followUps: ["story.followup.gunUnderSeatBack"])
        ],
        "story.affairExtortion": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Deacon Pressured for $3,000 Over Gambling Debts",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of demanding money from a church member and threatening to reveal private debts.",
                 followUps: ["story.followup.affairExtortionBack"])
        ],
        "story.breakRoomCoffee": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Threatening Note Left in Coworker's Lunch Bag",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of leaving a written threat for a coworker at a new workplace.",
                 followUps: ["story.followup.breakRoomCoffeeBack"])
        ],
        "story.restaurantFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Leased Kitchen Equipment Sold From Closed Restaurant",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of selling kitchen equipment that a leasing company says it still owns.",
                 followUps: ["story.followup.restaurantFireBack"])
        ],
        "story.kennelShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Horses Found Thin and Unwatered at Dealer's Barn",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of leaving horses at a barn without enough food or water.",
                 followUps: ["story.followup.kennelShootingBack"])
        ],
        "story.bloodTestStartup": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Scooter Pre-Orders Total $12,000, None Delivered",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of taking customer pre-orders for products that never shipped.",
                 followUps: ["story.followup.bloodTestStartupBack"])
        ],
        "story.knifeFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Fan Ejected From Football Game Curses Deputies, Kicks Gate",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was ordered out of a school football game and is accused of cursing at deputies and kicking a gate.",
                 followUps: ["story.followup.knifeFightBack"])
        ],
        "story.coastalBodies": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Man Enters Former Client's Beach House After Being Told to Stay Out",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of walking onto a property after receiving a written notice to stay away.",
                 followUps: ["story.followup.coastalBodiesBack"])
        ],
        "story.joggerChase": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Retired Investigator Flashes Old Badge at Teen Cyclist",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of showing a retired badge to a teenager and claiming an official investigation.",
                 followUps: ["story.followup.joggerChaseBack"])
        ],
        "story.hotCarDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Ex-Employee Logs Into Company Code Server Using Old Password",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of using a retired password to enter a former employer's computer system.",
                 followUps: ["story.followup.hotCarDeathBack"])
        ],
        "story.swattingCall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Online Attack Knocks Esports Tournament Offline",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of paying for an online attack that shut down a gaming tournament.",
                 followUps: ["story.followup.swattingCallBack"])
        ],
        "story.neighborhoodWatch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Man Blocks Deputies at Gate During Neighborhood Dispute",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of holding up a deputies' response at a subdivision gate.",
                 followUps: ["story.followup.neighborhoodWatchBack"])
        ],
        "story.ptaTreasurer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Swim Club Treasurer Charged With Taking $14,000",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of moving club dues into a personal account while serving as treasurer.",
                 followUps: ["story.followup.ptaTreasurerBack"])
        ],
        "story.staircaseDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Novelist Sells Forged Signed Manuscripts for $4,200",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of selling a collector copies of a signed manuscript as originals.",
                 followUps: ["story.followup.staircaseDeathBack"])
        ],
        "story.lowcountryLawyer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Lawyer Moves $22,000 From Retired Client's Estate Account",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of moving money out of an older client's estate account without approval.",
                 followUps: ["story.followup.lowcountryLawyerBack"])
        ],
        "story.churchArsonist": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Fire Crews Rush to Lumber Yard Blaze That Never Existed",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of calling in a fire at a lumber yard that crews say was not burning.",
                 followUps: ["story.followup.churchArsonistBack"])
        ],
        "story.noteBandit": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Man Hands Tag Office Clerk a Note Demanding Cash",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of handing a clerk a written demand for cash at a tag agency window.",
                 followUps: ["story.followup.noteBanditBack"])
        ],
        "story.wrongWayDriver": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver With Revoked License Caught Behind the Wheel at Bait Shop",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was stopped for an expired tag, and a deputy reports that {D}'s license was revoked.",
                 followUps: ["story.followup.wrongWayDriverBack"])
        ],
        "story.catfishMeetup": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Woman Opens Phone Account in Former Roommate's Name",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of opening a phone account in a former roommate's name.",
                 followUps: ["story.followup.catfishMeetupBack"])
        ],
        "story.deerCampFelon": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Rifle Taken From Truck Rack at Feed Store",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of taking a rifle from a pickup's rack outside a feed store.",
                 followUps: ["story.followup.deerCampFelonBack"])
        ]
    ]
}
