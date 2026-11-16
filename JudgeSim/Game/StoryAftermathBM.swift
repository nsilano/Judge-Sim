import Foundation

/// What follows the batch BM stories: a return to this court. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBM: [String: [Beat]] = [
        "story.caregiverAccount": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Church Volunteer Driver Accused of Taking Older Neighbor's Savings",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of taking money from another older person.",
                 followUps: ["story.followup.caregiverAccountBack"])
        ],
        "story.brakeLines": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Contractor Slashes Tires on Rival's Trucks",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of damaging a rival contractor's truck.",
                 followUps: ["story.followup.brakeLinesBack"])
        ],
        "story.stalkerCoworker": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Fake Social Media Accounts Follow Gym Trainer's Every Move",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of tormenting a gym trainer online.",
                 followUps: ["story.followup.stalkerCoworkerBack"])
        ],
        "story.armedConvenienceRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Pizza Driver Shoved and Robbed of Tips and Pay Envelope",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of robbing a delivery driver.",
                 followUps: ["story.followup.armedConvenienceRobberyBack"])
        ],
        "story.trafficStopBribe": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver Offers Road Test Examiner $100 to Pass",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of offering cash to a license examiner.",
                 followUps: ["story.followup.trafficStopBribeBack"])
        ],
        "story.onePunch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Former Bouncer Swings at Heckler Outside Bowling Alley",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was cited after a scuffle outside a bowling alley.",
                 followUps: ["story.followup.onePunchBack"])
        ],
        "story.wrongDoor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Truck Driver Carries Pistol Into Truck Stop Diner",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of carrying a loaded pistol into a diner.",
                 followUps: ["story.followup.wrongDoorBack"])
        ],
        "story.romanceScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Puppy Seller Takes $900 Deposits and Never Delivers",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of taking deposits for a puppy that never arrived.",
                 followUps: ["story.followup.romanceScamBack"])
        ],
        "story.busStopPurse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Wallet Vanishes From Laundromat Counter",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of taking a wallet from a laundromat.",
                 followUps: ["story.followup.busStopPurseBack"])
        ],
        "story.nurseryNight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Former Resident Found in Backyard of Old Family Home",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was found in the yard of a former home.",
                 followUps: ["story.followup.nurseryNightBack"])
        ],
        "story.harborDisappearance": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Podcast Host Gets Threatening Messages After Episode on Cold Case",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of sending threats to a podcast host.",
                 followUps: ["story.followup.harborDisappearanceBack"])
        ],
        "story.driveBy": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Neighbor Charged in Vandalism of Truck and Fence",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of smashing a neighbor's truck.",
                 followUps: ["story.followup.driveByBack"])
        ],
        "story.nightNurse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Nurse Caught Taking Pain Pills From Clinic Cabinet",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of presenting a forged prescription.",
                 followUps: ["story.followup.nightNurseBack"])
        ],
        "story.collegeHouse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Graduate Student Found Inside Closed Campus Lab",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was found inside a campus lab despite a ban.",
                 followUps: ["story.followup.collegeHouseBack"])
        ],
        "story.movieSetGun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Former Armorer Carries Pistol Into Community Theater",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of carrying a loaded pistol into a theater.",
                 followUps: ["story.followup.movieSetGunBack"])
        ],
        "story.eyeDropPoisoning": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Neighbor Charged With Using Elder's Debit Card at Drugstore",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of using an older neighbor's debit card.",
                 followUps: ["story.followup.eyeDropPoisoningBack"])
        ],
        "story.ponziAdvisor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Retired Advisor Takes $60,000 From Retiree for 'Safe' Investment",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of taking $60,000 for a fake investment.",
                 followUps: ["story.followup.ponziAdvisorBack"])
        ],
        "story.chopShop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Farm Tractor Trailers Found on Lot of Equipment Dealer",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of holding stolen farm trailers.",
                 followUps: ["story.followup.chopShopBack"])
        ],
        "story.odometerRollback": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Dealer Sold Flood-Damaged Sedan as Clean, Buyer Says",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of selling a flood-damaged car as clean.",
                 followUps: ["story.followup.odometerRollbackBack"])
        ],
        "story.motelCarbonMonoxide": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Property Manager Takes Rent for House Not Theirs",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of renting out a house that was not theirs to rent.",
                 followUps: ["story.followup.motelCarbonMonoxideBack"])
        ],
        "story.nursingHomeNeglect": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Nurse Used Forged Training Certificates to Land Staffing Job",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of using forged certificates to get a job.",
                 followUps: ["story.followup.nursingHomeNeglectBack"])
        ],
        "story.stolenValor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Fundraiser Collected $4,000 for Fake Wounded-Veteran Fund",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of collecting money for a veteran who does not exist.",
                 followUps: ["story.followup.stolenValorBack"])
        ],
        "story.boatLanding": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Fisherman's Boat Damaged With Hammer at Marina Slip",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of wrecking a fisherman's boat.",
                 followUps: ["story.followup.boatLandingBack"])
        ],
        "story.dragRaceDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Driver With Revoked License Stopped Outside Race Meet",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, was stopped driving with a revoked license.",
                 followUps: ["story.followup.dragRaceDeathBack"])
        ],
        "story.beachHouse": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...240,
                 headline: "Gym Parking Lot Break-Ins Tied to Former Cleaner",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is accused of breaking into a car in a gym lot.",
                 followUps: ["story.followup.beachHouseBack"])
        ]
    ]
}
