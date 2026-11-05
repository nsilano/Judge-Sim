import Foundation

/// What follows the batch AZ everyday-crime stories. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAZ: [String: [Beat]] = [
        "story.libraryKeyboard": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Self-Service Kiosk Smashed After Payment Error",
                 body: "Self-Service Kiosk Smashed After Payment Error. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.kioskSmash"])
        ],
        "story.mailboxFirework": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Firecracker Splits Apartment Mailbox Bank",
                 body: "Firecracker Splits Apartment Mailbox Bank. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.firecrackerBox"])
        ],
        "story.dumpsterDigger": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Returns to Second Store Dumpster After Notice",
                 body: "Man Returns to Second Store Dumpster After Notice. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dumpsterAgain"])
        ],
        "story.shelterGlass": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rock Breaks Pane at Second Bus Shelter",
                 body: "Rock Breaks Pane at Second Bus Shelter. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shelterAgain"])
        ],
        "story.sealcoatScam": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driveway Crew Takes Deposits in Second County",
                 body: "Driveway Crew Takes Deposits in Second County. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.sealcoatSecond"])
        ],
        "story.boosterRaffle": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Band Boosters Lose Concession Cash",
                 body: "Band Boosters Lose Concession Cash. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boosterTwo"])
        ],
        "story.closedHotTub": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Uses Closed Hotel Pool Again",
                 body: "Man Uses Closed Hotel Pool Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hotelPoolAgain"])
        ],
        "story.boatLakeDWI": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Boater Impaired on River",
                 body: "Boater Impaired on River. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.boatAgain"])
        ],
        "story.scooterShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Scooter Rider Shoves Cyclist",
                 body: "Scooter Rider Shoves Cyclist. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scooterAgain"])
        ],
        "story.yogaCubby": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Phone Taken From Gym Cubby",
                 body: "Phone Taken From Gym Cubby. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.gymCubby"])
        ],
        "story.airportPass": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Forges Hospital Garage Pass",
                 body: "Man Forges Hospital Garage Pass. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.garagePass"])
        ],
        "story.fakeSickNote": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Worker Hands Supervisor Forged Clinic Letter",
                 body: "Worker Hands Supervisor Forged Clinic Letter. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakeDoctorLetter"])
        ],
        "story.bakeSaleBox": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Church Bake Sale Box Taken",
                 body: "Church Bake Sale Box Taken. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.churchBakeSale"])
        ],
        "story.motelTv": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Guest Walks Out With Motel Bedding and Lamp",
                 body: "Guest Walks Out With Motel Bedding and Lamp. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.motelLamps"])
        ],
        "story.karaokeMic": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Hurls Chair at Karaoke Night",
                 body: "Man Hurls Chair at Karaoke Night. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.karaokeAgain"])
        ],
        "story.hydrantFlood": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Hydrant Opened Again in Hot Weather",
                 body: "Hydrant Opened Again in Hot Weather. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hydrantAgain"])
        ],
        "story.skateRamp": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Skaters Use Closed Tennis Court",
                 body: "Skaters Use Closed Tennis Court. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tennisCourtSkate"])
        ],
        "story.schoolLoiter": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Lingers at Day Care Fence After Warning",
                 body: "Man Lingers at Day Care Fence After Warning. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.daycareFenceLoiter"])
        ],
        "story.checkoutShove": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Shopper Shoves Another at Self-Checkout",
                 body: "Shopper Shoves Another at Self-Checkout. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.registerShove"])
        ],
        "story.roadCones": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Road Barricades Taken From Work Zone",
                 body: "Road Barricades Taken From Work Zone. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barricadeTaken"])
        ],
        "story.ebayBrick": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Seller Ships Empty Box for Laptop",
                 body: "Seller Ships Empty Box for Laptop. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.ebayEmpty"])
        ],
        "story.fittingLayers": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Customer Wears Store Jacket Out of Fitting Room",
                 body: "Customer Wears Store Jacket Out of Fitting Room. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fittingRoomTwo"])
        ],
        "story.gateArm": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Plows Through Lot Gate Again",
                 body: "Driver Plows Through Lot Gate Again. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lotGateAgain"])
        ],
        "story.wifiBorrow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Uses Neighbor's Network After Password Change",
                 body: "Man Uses Neighbor's Network After Password Change. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.wifiAgain"])
        ],
        "story.curbCouch": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Mattress From Curb That Was Not Free",
                 body: "Man Takes Mattress From Curb That Was Not Free. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.curbBed"])
        ],
        "story.barrelBurn": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Keeps Burning Trash After Fire Marshal Visit",
                 body: "Man Keeps Burning Trash After Fire Marshal Visit. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barrelAgain"])
        ],
        "story.paradeRoute": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Blocks Holiday Parade Float",
                 body: "Man Blocks Holiday Parade Float. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.paradeAgain"])
        ],
        "story.weddingCrasher": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Crashes Retirement Party and Refuses to Leave",
                 body: "Man Crashes Retirement Party and Refuses to Leave. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.receptionCrash"])
        ],
        "story.scooterHome": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Rider Keeps Rental E-Bike for Two Weeks",
                 body: "Rider Keeps Rental E-Bike for Two Weeks. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scooterTwo"])
        ],
        "story.casinoChips": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Cashes Altered Chips at Second Casino",
                 body: "Man Cashes Altered Chips at Second Casino. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.pokerChips"])
        ],
        "story.offeringPlate": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Tithes From Another Church Plate",
                 body: "Man Takes Tithes From Another Church Plate. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.tithePlate"])
        ],
        "story.fakeDealerTag": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Makes and Mounts Fake Temporary Tag",
                 body: "Man Makes and Mounts Fake Temporary Tag. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakeTempTag"])
        ],
        "story.pharmacyPills": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man With Unlabeled Hydrocodone Pills Stopped at Gas Station",
                 body: "Man With Unlabeled Hydrocodone Pills Stopped at Gas Station. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hydroPillsAgain"])
        ],
        "story.shoesOut": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Customer Wears New Boots Out of Store",
                 body: "Customer Wears New Boots Out of Store. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.bootsOut"])
        ],
        "story.fakeSticker": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Driver Shows Forged Registration Sticker",
                 body: "Driver Shows Forged Registration Sticker. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.fakePlateSticker"])
        ],
        "story.bikeShareRiver": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Throws Rental Scooter Into Creek",
                 body: "Man Throws Rental Scooter Into Creek. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.scooterRiver"])
        ],
        "story.neighborTree": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor Cuts Hedge Down Over Property Line",
                 body: "Neighbor Cuts Hedge Down Over Property Line. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.hedgeCut"])
        ],
        "story.forwardedMail": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Redirects Ex-Girlfriend's Packages to Own Door",
                 body: "Man Redirects Ex-Girlfriend's Packages to Own Door. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.redirectedPackages"])
        ],
        "story.foundWalletCash": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Finder Uses Cards From Found Purse",
                 body: "Finder Uses Cards From Found Purse. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.cardsFound"])
        ],
        "story.dogParkBrawl": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Dog Owners Fight at Second Park",
                 body: "Dog Owners Fight at Second Park. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.parkFightTwo"])
        ],
        "story.tattooDeposits": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Barber Takes Chair-Rental Deposits Then Vanishes",
                 body: "Barber Takes Chair-Rental Deposits Then Vanishes. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.barberDeposit"])
        ],
        "story.coopChickens": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Takes Ducks From Pond Pen",
                 body: "Man Takes Ducks From Pond Pen. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.duckCoop"])
        ],
        "story.weddingDjNoShow": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Photographer Takes Wedding Deposit and Never Shows",
                 body: "Photographer Takes Wedding Deposit and Never Shows. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.photographerDeposit"])
        ],
        "story.shovelSpot": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Neighbor Swings Shovel Over Driveway Dispute",
                 body: "Neighbor Swings Shovel Over Driveway Dispute. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.shovelDriveway"])
        ],
        "story.refundCheat": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Customer Claims Grocery Orders Never Arrived",
                 body: "Customer Claims Grocery Orders Never Arrived. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.refundGroceries"])
        ],
        "story.mallGrabRun": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Group Grabs Jackets at Outlet and Runs",
                 body: "Group Grabs Jackets at Outlet and Runs. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.storeGrabRun"])
        ],
        "story.busSpit": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Patient Spits on Paramedic",
                 body: "Patient Spits on Paramedic. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.paramedicSpit"])
        ],
        "story.trailBike": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "ATV Rider Tears Through Greenway",
                 body: "ATV Rider Tears Through Greenway. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.quadTrail"])
        ],
        "story.lostDogReward": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Demands Reward for Cat He Took From Porch",
                 body: "Man Demands Reward for Cat He Took From Porch. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.lostCatReward"])
        ],
        "story.siphonedDiesel": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.3, days: 30...180,
                 headline: "Man Siphons Fuel From Parked Dump Truck",
                 body: "Man Siphons Fuel From Parked Dump Truck. Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing the new charge.",
                 followUps: ["story.followup.dumpTruckDieselAgain"])
        ]
    ]
}
