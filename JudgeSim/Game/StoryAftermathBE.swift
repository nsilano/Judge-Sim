import Foundation

/// What follows the batch BE everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBE: [String: [Beat]] = [
        "story.funeralRingsTaken": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Embalmer at Second Funeral Home Linked to Missing Jewelry",
                 body: "Prior Funeral Worker Case Linked to New Home. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ringsAgain"])
        ],
        "story.sergeantTicketCash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Lieutenant Took Cash to Void Citations",
                 body: "Prior Police Bribery Case Linked to New Department. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sergeantAgain"])
        ],
        "story.clerkDismissalFees": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Magistrate's Clerk Took Cash to Skip Hearings",
                 body: "Prior Clerk Bribery Case Linked to New Office. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clerkAgain"])
        ],
        "story.motherFalseAlibi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Aunt Lied Under Oath to Give Nephew an Alibi",
                 body: "Prior Alibi Perjury Case Linked to New Trial. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.alibiAgain"])
        ],
        "story.witnessPaidToLeave": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Defendant's Cousin Pays Witness to Skip Court",
                 body: "Prior Witness-Pay Case Linked to New Trial. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.witnessPayAgain"])
        ],
        "story.jurorParkingLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Approaches Juror at Courthouse Coffee Shop",
                 body: "Prior Juror-Contact Case Linked to New Trial. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jurorAgain"])
        ],
        "story.evidenceLogDetective": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Officer Altered Property Room Log After Cash Went Missing",
                 body: "Prior Evidence-Log Case Linked to New Officer. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.logAgain"])
        ],
        "story.teenFakeKidnapReport": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Reports Fake Carjacking to Explain Late Return",
                 body: "Prior False-Report Teen Reports Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kidnapReportAgain"])
        ],
        "story.rivalHouseSwatting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fake Hostage Call Sends Deputies to Classmate's Home",
                 body: "Prior Swatting Teen Linked to New Call. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.swatAgain"])
        ],
        "story.nineOneOneFlood": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Floods Non-Emergency Line With Calls After Warning",
                 body: "Prior 911 Jammer Calls Dispatch Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jamAgain"])
        ],
        "story.dragDeputyStop": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Pulls Away With Trooper at Window",
                 body: "Prior 'Sovereign' Stop Driver Pulls Away Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dragAgain"])
        ],
        "story.taserFootChase": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Flees on Foot After Being Stunned at Stop",
                 body: "Prior Foot-Chase Defendant Runs Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.footChaseAgain"])
        ],
        "story.kidsInBackChase": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Leads Deputies on Chase With Toddler in Back",
                 body: "Prior Chase Driver Flees Again With Child. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chaseKidsAgain"])
        ],
        "story.interstateTruckDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Impaired Truck Driver Crashes Into Stopped Traffic",
                 body: "Prior Fatal DWI Defendant Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.truckDeathAgain"])
        ],
        "story.streetRaceBystander": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Street Racers Crash Into Parked Cars, Injuring Two",
                 body: "Prior Race Crash Defendant Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.raceAgain2"])
        ],
        "story.crosswalkHitRun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Hits Cyclist in Crosswalk and Flees",
                 body: "Prior Hit-and-Run Defendant's Truck Matched Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.crosswalkAgain"])
        ],
        "story.minivanChildDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Impaired Driver Hits Minivan at Stop Sign, Injuring Three",
                 body: "Prior Fatal DWI Defendant Hits Another Van. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.minivanAgain"])
        ],
        "story.sixthDwiRollover": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man With Seven Prior DWIs Found Behind Wheel at Gas Station",
                 body: "Repeat DWI Defendant Arrested Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.seventhDwiAgain"])
        ],
        "story.revokedFamilyCrash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Revoked Driver Hits Cyclist While Impaired",
                 body: "Prior Revoked-License Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.revokedCyclistAgain"])
        ],
        "story.fleetBrakeWarning": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fleet Manager Ignored Warnings; Bus Driver Injured",
                 body: "Prior Fleet-Brake Case Linked to New Employer. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.brakeAgain"])
        ],
        "story.scaffoldNoHarness": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contractor Skipped Safety Gear; Roofer Falls and Is Hurt",
                 body: "Prior Scaffold Death Contractor Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scaffoldAgain"])
        ],
        "story.dogsKillChild": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Owner Kept Aggressive Dogs That Mauled a Delivery Worker",
                 body: "Prior Fatal Dog Case Owner Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dogsAgain"])
        ],
        "story.kennelFireAnimals": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Boarding Stable Burned With Horses Inside",
                 body: "Prior Kennel Fire Owner Linked to Stable Fire. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kennelAgain"])
        ],
        "story.warehouseInventoryBurn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Storage Building Burned After Stock Removed",
                 body: "Prior Warehouse Fire Tenant Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.warehouseAgain"])
        ],
        "story.neighborCarGarageBurn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Burns Neighbor's Truck After Fence Dispute",
                 body: "Prior Garage Arson Defendant Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.carBurnAgain"])
        ],
        "story.stillAndGenerators": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Barn Holds Stolen Tractors and a Still",
                 body: "Prior Moonshine Barn Owner Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stillAgain"])
        ],
        "story.scrapYardCopper": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Scrap Yard Bought Stolen Cable From Telecom Company",
                 body: "Prior Scrap Yard Owner Linked to New Thefts. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scrapCableAgain"])
        ],
        "story.poisonedNeighborDogs": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Poisons Neighbor's Cats",
                 body: "Prior Dog Poisoning Defendant Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.poisonAgain"])
        ],
        "story.puppyMillCrates": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Breeder Kept Thirty Cats in Filthy Cages",
                 body: "Prior Dog-Mill Breeder Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.puppyAgain"])
        ],
        "story.bearCubVideos": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Men Torture Fox Pup for Online Videos",
                 body: "Prior Cub-Video Defendant Posts Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bearAgain"])
        ],
        "story.barEjectedShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Ejected Patron Returns and Fires at Doorman",
                 body: "Prior Bar Shooting Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barShootAgain"])
        ],
        "story.rentTrailerShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Shoots at Roommate in Mobile Home Over Rent",
                 body: "Prior Trailer Shooting Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trailerShootAgain"])
        ],
        "story.clubAmbushKilling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rival Biker Shot at From Overlook",
                 body: "Prior Ambush Defendant Linked to New Shooting. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.overlookShotAgain"])
        ],
        "story.poolHallDebtKilling": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Shoots at Bowling Alley Patron Over Debt",
                 body: "Prior Pool Hall Shooting Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hallDebtAgain"])
        ],
        "story.houseDriveByShots": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shots Fired Into Apartment With Family Inside",
                 body: "Prior House Shooting Defendant Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.driveByAgain"])
        ],
        "story.backpackGunSchool": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Student Found With Pistol in Gym Bag",
                 body: "Prior School Gun Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.schoolGunAgain"])
        ],
        "story.fathersGunShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Fires Stepfather's Gun in Parking Lot, Wounds Classmate",
                 body: "Prior Teen Shooting Defendant Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.teenGunAgain"])
        ]
    ]
}
