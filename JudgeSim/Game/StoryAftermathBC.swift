import Foundation

/// What follows the batch BC everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBC: [String: [Beat]] = [
        "story.trawlerCatchShare": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shrimp Boat Crewman Cut in Dock Argument",
                 body: "First Mate From Trawler Case Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trawlerAgain"])
        ],
        "story.hospitalStairwellBeating": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Nursing Home Resident Bruised After Guard Escort",
                 body: "Security Guard From Hospital Case Faces New Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stairwellAgain"])
        ],
        "story.dialysisStaffThreat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pharmacy Staff Threatened in Letter After Refill Dispute",
                 body: "Author of Clinic Threat Note Writes Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dialysisAgain"])
        ],
        "story.restStopWrench": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Struck With Tire Iron at Truck Stop",
                 body: "Rest Area Defendant Back After New Fight. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotWrenchAgain"])
        ],
        "story.quarryHopperShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Foreman Shoves Worker at Gravel Pit",
                 body: "Quarry Foreman Back in Court After New Fall. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.quarryShoveAgain"])
        ],
        "story.ferryPilotBreath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Tour Boat Captain Tests Over Limit at Dock",
                 body: "Pilot From Ferry DWI Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ferryPilotAgain"])
        ],
        "story.deerCarcassFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hunting Dispute Ends With Pellet Wound",
                 body: "Hunter From Deer Dispute Case Fires Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.buckAgain"])
        ],
        "story.volunteerFireSetter": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Brush Fires Linked to Reserve Firefighter",
                 body: "Former Volunteer Firefighter Again First on Scene. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.firesAgain"])
        ],
        "story.tentRevivalCures": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Preacher Sells 'Healing Oil' at New Revival",
                 body: "Tent Revival Preacher Back With New Product. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.revivalAgain"])
        ],
        "story.aideWillChange": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Aide Named in Second Client's New Will",
                 body: "Home Aide Again Inherits From Client. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.willAgain"])
        ],
        "story.catfishSingerGiftCards": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Poses as Actor Online to Collect Money",
                 body: "Impersonator From Singer Case Returns. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.catfishAgain"])
        ],
        "story.payrollTaxSkim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bookkeeping Firm Kept Clients' Tax Payments",
                 body: "Payroll Owner Again Faces Missing Funds. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.payrollTaxAgain"])
        ],
        "story.hospiceMorphineSwap": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Home Health Nurse Took Patients' Pain Medication",
                 body: "Nurse From Hospice Case Under Review Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hospiceAgain"])
        ],
        "story.courierDriveUpRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Armed Men Rob Courier at Credit Union",
                 body: "Phone Evidence Again Points to Ex-Driver. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.courierAgain"])
        ],
        "story.carWashToyGun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Robs Pizza Worker With Airsoft Pistol",
                 body: "Defendant From Toy Gun Robbery Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.toyGunAgain"])
        ],
        "story.laundromatClosingRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Robs Dry Cleaner With Knife at Closing",
                 body: "Bus Driver Again Identifies Same Man. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.launderRobAgain"])
        ],
        "story.bakeryDawnRobbery": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man With Revolver Robs Donut Shop at Dawn",
                 body: "Former Employee Again Identified by Driver. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bakeryRevolverAgain"])
        ],
        "story.armoredRoutePlot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cash Truck Crew Plan Another Heist, Chat Shows",
                 body: "Armored Route Plotter Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.routePlotAgain"])
        ],
        "story.trophyShotguns": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Intruder Takes Rifles From Hunting Lodge",
                 body: "Lost Driver Again Near a Burglary. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trophyAgain"])
        ],
        "story.funeralHomeJewelry": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Thieves Pry Chapel Door and Take Offering Silver",
                 body: "Funeral Home Burglar Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.funeralAgain"])
        ],
        "story.bandRoomBurglary": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Thieves Take Choir Risers and Keyboards From Middle School",
                 body: "Former Parent With Key Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bandAgain"])
        ],
        "story.churchOfficeSafe": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Thieves Cut Synagogue Office Safe",
                 body: "Torch Owner From Church Safe Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.churchSafeAgain"])
        ],
        "story.vanWithSleepingChild": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Truck Taken With Sleeping Toddler Inside",
                 body: "Thief Abandons Truck Near School. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.vanAgain"])
        ],
        "story.kayakLoadTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Paddleboards Stolen From Lake Outfitter",
                 body: "Trailer Owner From Kayak Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kayakRentalAgain"])
        ],
        "story.busConverterRing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Converters Cut From Fire Trucks at Station Lot",
                 body: "Mechanic From Bus Converter Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.converterAgain"])
        ],
        "story.truckStopRigTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Box Truck of Furniture Stolen From Truck Stop",
                 body: "Lot Renter From Rig Theft Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rigAgain"])
        ],
        "story.calfBarnTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Goats Stolen From Livestock Barn",
                 body: "Trailer Linked to Calf Theft Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.calvesAgain"])
        ],
        "story.lumberLoadTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Roofing Shingles Hauled Off From New Build",
                 body: "Flatbed Dent Matches Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lumberAgain"])
        ],
        "story.beeHiveTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Forty Hives Taken From Blueberry Farm",
                 body: "Beekeeper With Matching Brands Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hivesAgain"])
        ],
        "story.hardwareGreenhouseGrow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Plants Under Lights Found in Nursery Greenhouse",
                 body: "Greenhouse Lessee From Hardware Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nurseryGrowAgain"])
        ],
        "story.poolHallScales": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Meth and Ledger Found at Bowling Alley Owner's Home",
                 body: "Pool Hall Owner Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.poolHallAgain"])
        ],
        "story.fentanylPatchStash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Nurse Aide Caught With Patches at Second Facility",
                 body: "Aide From Patch Stash Case Under Review Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.patchAgain"])
        ],
        "story.boatRampCooler": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Cooler of Cocaine Found at Second Boat Ramp",
                 body: "Trailer Owner From Ramp Case Stopped Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rampAgain"])
        ],
        "story.bathSaltsPorch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Sells 'Plant Food' From Garage",
                 body: "Bath Salts Seller Caught by Same Deputy. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bathSaltsAgain"])
        ],
        "story.twoOverdoseDealer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Dealer Linked to Two More Overdoses",
                 body: "Same Mark Found on Seized Pills. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.overdoseAgain"])
        ],
        "story.alteredScripts": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Alters Prescriptions at Five Pharmacies",
                 body: "Altered Scripts Return With New Name. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scriptsAgain"])
        ],
        "story.fakeGameWarden": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Poses as Park Ranger to Collect Fees",
                 body: "Fake Warden Returns in New Uniform. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakeRangerAgain"])
        ],
        "story.blueLightsRoadStops": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver With Red-and-Blue Lights Stops Teen on County Road",
                 body: "Impersonator Again Pulls Over Drivers. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.blueAgain"])
        ]
    ]
}
