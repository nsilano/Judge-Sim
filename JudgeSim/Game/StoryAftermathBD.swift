import Foundation

/// What follows the batch BD everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBD: [String: [Beat]] = [
        "story.windowFilmingNeighbor": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Aims Camera at New Neighbor's Windows",
                 body: "Neighbor Previously Charged With Stalking Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cameraAgain"])
        ],
        "story.firedWorkerTexts": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Laid-Off Worker Threatens Former Supervisor by Text",
                 body: "Texter From Prior Threat Case Writes Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.textsAgain"])
        ],
        "story.hospitalBombCall": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Caller Claims Gunman at Mall, Forcing Lockdown",
                 body: "Prepaid Phone Again Linked to Former Patient. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bombAgain"])
        ],
        "story.trailerToddlerNeglect": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Leaves Two Children in Car Overnight",
                 body: "Mother From Trailer Neglect Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.toddlerCarAgain"])
        ],
        "story.babysitterInfantInjury": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Child Care Worker Charged After Toddler Suffers Broken Arm",
                 body: "Caregiver From Infant Injury Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sitterAgain2"])
        ],
        "story.poolMotherLeft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Parent Leaves Children Alone at Water Park",
                 body: "Mother From Pool Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.poolAgain3"])
        ],
        "story.runawayRide": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Drives Another Runaway Out of State",
                 body: "Previously Charged Driver Linked to New Runaway. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.runawayAgain"])
        ],
        "story.benefitCardCash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Second Store Owner Cashes Benefit Balances",
                 body: "Store Owner From Benefit Case Audited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cardsAgain"])
        ],
        "story.therapyBillingGhost": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Counseling Practice Billed for Sessions Not Held",
                 body: "Clinic Owner From Billing Case Audited Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.therapyAgain"])
        ],
        "story.liftingBackClaim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Disability Claimant Seen Hauling Lumber on Video",
                 body: "Prior Claim Filer Again Under Surveillance. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.liftingAgain"])
        ],
        "story.stormRepairAdvance": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contractor Takes Flood Repair Advances and Vanishes",
                 body: "Storm Contractor From Earlier Case Hired Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.stormAgain"])
        ],
        "story.sickPuppiesPapers": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Breeder Sold Kittens as Purebred With Fake Papers",
                 body: "Breeder From Puppy Case Selling Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.puppiesAgain"])
        ],
        "story.executorEstateSales": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Executor Sold Land and Equipment and Kept Cash",
                 body: "Prior Executor Case Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.estateAgain"])
        ],
        "story.tuitionCheckBookkeeper": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Daycare Bookkeeper Deposited Parents' Checks Into Own Account",
                 body: "Bookkeeper From Tuition Case Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tuitionAgain"])
        ],
        "story.unionTreasurerChecks": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Local Treasurer Pays Himself From Dues Fund",
                 body: "Prior Union Treasurer Faces Second Audit. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.unionAgain"])
        ],
        "story.campaignTreasurerCar": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Committee Treasurer Pays Personal Loan From Donations",
                 body: "Prior Campaign Treasurer Faces New Complaint. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.campaignAgain"])
        ],
        "story.foodBankVacations": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shelter Director Charged Resort Stays to Charity Cards",
                 body: "Former Food Bank Director Faces Second Audit. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.foodBankAgain"])
        ],
        "story.vendingRouteSkim": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Laundromat Route Collector Reported Less Coin Than Taken",
                 body: "Prior Route Driver Skim Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.routeAgain"])
        ],
        "story.fireAuxTreasurer": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rescue Squad Auxiliary Treasurer Pays Personal Debts From Fund",
                 body: "Prior Fire Auxiliary Treasurer in New Dispute. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.auxAgain"])
        ],
        "story.washedChecks": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Cashes Chemically Altered Checks at Credit Union",
                 body: "Check Washer Linked to Earlier Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.washedAgain"])
        ],
        "story.scriptPadPrint": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Uses Printed Pads From Another Doctor's Template",
                 body: "Prescription Forger Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.padAgain"])
        ],
        "story.nursingDiplomaFake": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Applicant Presents Forged Pharmacy Technician Certificate",
                 body: "Prior Forger Presents New Credential. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.diplomaAgain"])
        ],
        "story.twentiesCounterfeit": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Passes Counterfeit Fifties in Three Towns",
                 body: "Counterfeit Passer Spotted Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.twentiesAgain"])
        ],
        "story.willForgeryHeir": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Nephew Presents Forged Codicil After Aunt's Death",
                 body: "Heir From Forged Will Case in New Dispute. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.willAgain2"])
        ],
        "story.barSkimmerPocket": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Server Copies Diners' Cards With Pocket Skimmer",
                 body: "Skimmer Found on Server From Earlier Bar Case. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barSkimmerAgain2"])
        ],
        "story.loyaltyCardClones": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Clerk Cloned Gift Cards at Pharmacy Register",
                 body: "Prior Cloner Linked to New Store. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.clonesAgain"])
        ],
        "story.electronicsCloneRing": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Linked to Cloned Card Buying Spree at Appliance Stores",
                 body: "Rental Car Again Holds Blank Cards. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ringAgain"])
        ],
        "story.deadWomanAccounts": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Spends Dead Neighbor's Savings Through Her Cards",
                 body: "Account User From Earlier Case Appears in New Logs. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.deadAccountsAgain"])
        ],
        "story.loanForgivenessPhone": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Caller Collects Fees for Fake Mortgage Relief",
                 body: "Prior Loan-Relief Caller Dials Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.forgivenessAgain"])
        ],
        "story.taxAgentGiftCards": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Caller Posing as Utility Rep Demands Gift Cards From Elderly",
                 body: "Prior Impostor Caller Back on the Line. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.taxAgain"])
        ],
        "story.wetlandsFillDump": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Contractor Fills Creek Bank With Rubble",
                 body: "Prior Wetland Filler Cited for Creek Damage. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.wetlandsAgain"])
        ],
        "story.muralPaintOver": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Crew Paints Over Library Mural",
                 body: "Prior Mural Painter Again Sprays a Wall. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.muralAgain"])
        ],
        "story.fountainDestroyed": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Teens Smash Memorial Pond Wall With Sledges",
                 body: "Prior Fountain Wrecker Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fountainAgain"])
        ],
        "story.busSeatsSlashed": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Students Slash Seats on Parked Church Vans",
                 body: "Prior Seat Slasher Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.busSeatsAgain"])
        ],
        "story.jailLockdownRiot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Detainees Riot at Juvenile Center After Lockdown",
                 body: "Prior Jail Rioter Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.jailAgain"])
        ],
        "story.courthouseHallFight": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Relatives Brawl in Courthouse Lot After Sentencing",
                 body: "Prior Courthouse Brawler Back in Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hallFightAgain"])
        ],
        "story.ambulanceEntryBlock": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Protesters Block Fire Station Bay Doors",
                 body: "Prior Blockade Protester Charged Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.blockadeAgain"])
        ],
        "story.paramedicCashTheft": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "EMT Takes Cash From Patients at Second Agency",
                 body: "Prior Paramedic Theft Case Linked Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.medicTheftAgain"])
        ]
    ]
}
