import Foundation

/// What follows the batch BA everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBA: [String: [Beat]] = [
        "story.rodeoLotStabbing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Cuts Bull Rider After Dispute at Feed Store",
                 body: "Defendant From Rodeo Stabbing Case Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.rodeoAgain"])
        ],
        "story.gravelPlantPayroll": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Quarry Office Robbed at Gunpoint on Payday",
                 body: "Voice Again Identified by Clerk. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.quarryAgain"])
        ],
        "story.boxCutterStation": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Box Cutter Robbery at Corner Store",
                 body: "Cap Seen in Second Robbery. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boxCutterAgain"])
        ],
        "story.jewelrySmashGrab": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Window Smashed at Pawn Shop; Trays Taken",
                 body: "Hammer Marks Match Earlier Break-In. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.storeWindowAgain"])
        ],
        "story.dayCareNightFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Preschool Shed Burned at Night",
                 body: "Defendant From Day Care Fire Case Seen Nearby. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.preschoolFire"])
        ],
        "story.nurseSalineSwap": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Nurse's Withdrawals Spike at Second Hospital",
                 body: "Former Diverter Back in Records. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.nurseAgain"])
        ],
        "story.motelMethRoom": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Chemical Smell at Second Motel Leads to Lab",
                 body: "Defendant From Motel Lab Case Registered Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.motelLabAgain"])
        ],
        "story.pillMillClinic": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Doctor Prescribes Without Exam at New Clinic",
                 body: "Medical Board Flags Return to Pills. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pillMillSecond"])
        ],
        "story.cockfightBarnRaid": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Cockfight Raid Nets Thirty Birds",
                 body: "Landowner Again at the Gate. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cockfightAgain"])
        ],
        "story.carChokeBar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Accused of Choking Another Partner in Truck",
                 body: "Defendant From Parked-Car Choking Case Arrested Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.choke2"])
        ],
        "story.gpsTrackerEx": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Tracker Found on Another Ex's Car",
                 body: "Defendant From GPS Stalking Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.trackerAgain"])
        ],
        "story.fakeProfileCampaign": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fake Profiles Target Neighbor After Dispute",
                 body: "Defendant From Cyberstalking Case Linked to New Accounts. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.profilesAgain"])
        ],
        "story.doorbellHackFamilies": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Hacked Baby Monitors",
                 body: "Defendant From Camera Hacking Case Again in Logs. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cameraHackAgain"])
        ],
        "story.schoolRansomLock": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Town Hall Systems Locked by Ransomware",
                 body: "Contractor Credentials Again Used. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ransomAgain"])
        ],
        "story.bankFileSale": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Credit Union Files Sold to Scammers",
                 body: "Former Bank Insider at New Employer. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bankFileAgain"])
        ],
        "story.fakeFundraiserOnline": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fundraiser for Fire Victims Raised Money But No Family Existed",
                 body: "Defendant From Fake Medical Fundraiser Posts Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fundraiserAgain"])
        ],
        "story.churchInvestmentPonzi": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pastor Pitches Land Fund at New Church",
                 body: "Former Preacher Collects From Members Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ponziAgain"])
        ],
        "story.homeBuilderDeposits": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contractor Took Deposits for Garages and Built None",
                 body: "Builder Linked to Earlier Deposits Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.buildDepositsAgain"])
        ],
        "story.realtorEscrowTake": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Agent's Client Funds Short at Another Closing",
                 body: "Real Estate Agent Again in Escrow Dispute. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.escrowAgain"])
        ],
        "story.chopShopTrucks": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Shop Raided With Stripped Vans",
                 body: "Owner From Chop Shop Case Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chopAgain"])
        ],
        "story.cyclistDawnHitRun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Jogger Struck at Dawn; Driver Left",
                 body: "Mirror Piece Matches Earlier Defendant's Truck. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hitRunAgain"])
        ],
        "story.flowersAtWork": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Leaves Gift at Ex's Home Despite Protective Order",
                 body: "Order Violator Again Seen on Doorbell Camera. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.protectiveFlowersAgain"])
        ],
        "story.lakeCabinRansom": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teen Held in Hunting Cabin; Demand Sent to Mother",
                 body: "Acquaintance From Lake Cabin Case Arrested Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cabinHoldAgain"])
        ],
        "story.roadMergeShooting": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Fires at Car After Lane Dispute",
                 body: "Defendant From Highway Shooting Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.mergeAgain"])
        ],
        "story.churchStairShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Shoves Usher Down Fellowship Hall Steps",
                 body: "Defendant From Church Stair Death Case in New Dispute. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chapelShoveAgain"])
        ],
        "story.ranchPipeAssault": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Foreman Strikes Worker With Hose Reel Handle",
                 body: "Defendant From Ranch Pipe Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pipeAgain"])
        ],
        "story.raceTrackBrawl": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fight at Demolition Derby Injures Four",
                 body: "Brawl Participant Again on Video. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.raceBrawlAgain"])
        ],
        "story.schoolBoardContract": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "County Commissioner Took Cash for Paving Contract",
                 body: "Former School Board Member at County Hall. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boardCashAgain"])
        ],
        "story.lyingWitnessStand": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Witness Charged With Perjury at Second Trial",
                 body: "Video Again Contradicts Same Witness. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lyingAgain"])
        ],
        "story.hiddenGunFriend": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Hides Cousin's Knife From Deputies",
                 body: "Defendant From Hidden Gun Case Again Concealing Evidence. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hiddenAgain"])
        ],
        "story.restaurantOrderHack": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pizza Chain Ordering Lockout Brings Demand",
                 body: "Former Server's Old Login Again Used. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hackAgain"])
        ],
        "story.churchFireFormer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fellowship Hall Burned After Leadership Vote",
                 body: "Former Member Again Seen Leaving. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chapelFireAgain"])
        ],
        "story.tireSparePills": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pills Hidden in Roof Liner at Checkpoint Stop",
                 body: "Driver From Tire Stash Case Stopped Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tireAgain"])
        ],
        "story.pawnStrawBuy": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Woman Buys Rifle at Gun Show for Same Felon Boyfriend",
                 body: "Straw Buyer Again on Records. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.strawAgain"])
        ],
        "story.forgedDeedLot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Forged Deed Sells Neighbor's Farmland",
                 body: "Forged Notary Stamp Again Linked to Same Man. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deedAgain"])
        ],
        "story.cafeBurnedForInsurance": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bakery Fire Brings Insurance Claim From Same Owner",
                 body: "Grease Fire Theory Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cafeFireAgain"])
        ],
        "story.groupHomeWanderFreeze": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Resident Wanders From Care Home; Aide Asleep Again",
                 body: "Night Aide From Frostbite Case at New Home. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.groupHomeAgain"])
        ],
        "story.roofingWidowScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Roofing Crew Targets Another Widow With Phony Hail Damage",
                 body: "Same Crew Chief, New Victim. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.roofSecond"])
        ],
        "story.loanSharkThreats": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Lender Threatens Second Borrower With 'Collection Visit'",
                 body: "Loan Shark Voicemails Return. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lenderAgain"])
        ],
        "story.bailBondsJailer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Bondsman Pays Dispatcher for Arrest Lists",
                 body: "Cash App Trail Repeats. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bondsmanAgain"])
        ],
        "story.barnFeudFire": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor's Shop Burned After Boundary Ruling",
                 body: "Feuding Farmer Again Near a Fire. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.feudFireAgain"])
        ],
        "story.chaserStagedInjuries": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Runner Recruits Claimants for Second Law Office",
                 body: "Same Clinic, New Claims. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.chaserAgain"])
        ],
        "story.hayrideTractorWreck": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Impaired Farmer Overturns Cart With Passengers",
                 body: "Hayride Driver From Fatal Case Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.wagonAgain"])
        ],
        "story.teacherHallAttack": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Pushes Coach at Ball Game",
                 body: "Defendant From School Hallway Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.teacherAgain"])
        ],
        "story.illegalFireworksBlast": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Fireworks Cache Burns in Rented Shed",
                 body: "Storage Renter From Warehouse Blast Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shedFireworksAgain"])
        ],
        "story.medicSpitBite": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Patient Strikes Nurse in ER Hallway",
                 body: "EMS Defendant Charged Again After Treatment. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.medicBiteAgain"])
        ],
        "story.countyClerkFees": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Town Clerk Pockets Permit Fees",
                 body: "Former County Clerk's Employee at Town Hall. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clerkFeesAgain"])
        ],
        "story.crossbowNeighborDispute": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor Points Bow at Delivery Driver",
                 body: "Defendant From Crossbow Case Aims Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.crossbowAgain"])
        ],
        "story.lakeBoatCrashDeath": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Pontoon Operator Charged After Dock Collision Injures Two",
                 body: "Boater From Fatal Dock Crash Cited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dockPontoonAgain"])
        ],
        "story.checkKitingRing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Check Float Between Two Banks Collapses Again",
                 body: "Account Holder From Kiting Case Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kiteAgain"])
        ]
    ]
}
