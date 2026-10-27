import Foundation

/// What follows the batch AF written cases. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
extension StoryAftermath {
    static let beatsAF: [String: [Beat]] = [
        "story.outboardMotors": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 60...260,
                 headline: "Boat trailer missing from Bayard landing; deputies question {DL}",
                 body: "A boat trailer was taken overnight from a driveway near the Bayard Boat Landing, and deputies say a pickup like the one owned by {D} was seen towing it. {DL}'s earlier case over two outboard motors was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.trailerTheft"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 90...300,
                 headline: "Copper cable cut from Port Hollis Marina docks",
                 body: "Forty boats lost power when someone cut the shore-power cable at the Port Hollis Marina. Deputies say they are looking at scrap-yard records, and have spoken with {D}, whose earlier case over motors stolen from the same marina was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.dockCopper"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.4, days: 20...120,
                 headline: "Port Hollis Marina adds cameras and a night gate",
                 body: "After two outboard motors were taken from boats at its docks, the Port Hollis Marina has added cameras and a gate locked from 10 p.m. to 5 a.m. Slip holders get a code. The case against {D} went before Judge {JUDGE}."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Motors in {DL} case turn up in another man's shed",
                 body: "Deputies searching a Cane Creek shed in an unrelated case found engine covers and a fuel line matching the two outboard motors {D} was convicted of stealing. {DL}'s lawyer has asked Judge {JUDGE} for a new trial.")
        ],
        "story.giftCardDrain": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 60...240,
                 headline: "Harbor Mart says fake receipts used for cash refunds",
                 body: "Harbor Mart loss prevention says eleven cash refunds were made on receipts printed outside the store. The store says it has given video to deputies. {D}, a former Harbor Mart cashier whose gift-card case was heard by Judge {JUDGE}, has been questioned.",
                 followUps: ["story.followup.fakeReturns"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 90...300,
                 headline: "Diner owner reports drawer short on new cashier's shifts",
                 body: "A Hollis County diner owner says the register came up short by thousands of dollars over three months, mostly on the shifts of a cashier hired this year: {D}, whose earlier case over gift cards at Harbor Mart was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.drawerShort"]),
            Beat(triggers: [.probation, .prison], chance: 0.4, days: 30...150,
                 headline: "Harbor Mart limits gift card loads at registers",
                 body: "Harbor Mart now needs a manager's code to load more than $200 onto a gift card at a register, after the case of {D}, a cashier convicted of draining $11,300 that way. The store says it has paid back no customers because no customer lost money; the loss was the store's.")
        ],
        "story.counterfeitTickets": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 60...240,
                 headline: "Concert-goers turned away at gate say seller was {DL}",
                 body: "Four people say tickets they bought online for a concert in Raleigh did not exist, and that the seller met them in a Hollis County parking lot. Deputies say the seller's phone number belongs to {D}, whose case over football tickets was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.concertTickets"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 90...300,
                 headline: "Family pays deposit on beach house that wasn't for rent",
                 body: "Hollis County residents are being warned about a beach rental listing: a family paid a $2,100 deposit on a house whose real owner had never heard of the renter. Deputies say they have linked the listing to {D}.",
                 followUps: ["story.followup.rentalListing"]),
            Beat(triggers: [.probation], chance: 0.4, days: 60...200,
                 headline: "Ticket buyers get money back from {DL}",
                 body: "The six people who bought fake football tickets from {D} have been paid back in full as part of {DL}'s probation, a probation officer told Judge {JUDGE}. {V} said, \"I'll buy at the box office from now on.\"")
        ],
        "story.pumpSkimmer": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 60...240,
                 headline: "Skimmer found on downtown bank ATM",
                 body: "A bank technician found a card reader glued over the slot of a Hollis County ATM. The bank says some customers' accounts were drained with copied cards. Deputies say they have spoken with {D}, whose gas-pump skimmer case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.atmSkimmer"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 90...300,
                 headline: "Washed check cashed for $2,850; deputies name a suspect",
                 body: "A Hollis County resident mailed a $45 check to the water department. It came back cashed for $2,850, payable to {D}. The payee and amount had been washed off with chemicals. {DL}'s earlier card fraud case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.washedChecks"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.4, days: 20...120,
                 headline: "State inspectors check every gas pump in Hollis County",
                 body: "After a skimmer was found inside a pump in the case against {D}, state agriculture inspectors spent a week opening every pump in the county. They found no more skimmers. Stations now put security tape over pump doors.")
        ],
        "story.utilityImpostor": [
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.3, days: 60...240,
                 headline: "Older homeowner paid for a roof job that never started",
                 body: "An older Hollis County homeowner paid a $2,400 deposit to a man who knocked on the door offering roof repairs. No work was ever done. Deputies say the man was {D}, whose earlier case over a fake power company visit was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.roofDeposit"]),
            Beat(triggers: [.freed, .cleared, .probation], chance: 0.25, days: 90...300,
                 headline: "Rings stolen in daytime break-in turn up at pawn shop",
                 body: "Two rings taken from a house during the day were pawned the next morning for $380 under the driver's license of {D}. Pawn shops report every item to the Sheriff's Office. {DL}'s earlier case was heard by Judge {JUDGE}.",
                 followUps: ["story.followup.pawnedRing"]),
            Beat(triggers: [.freed, .cleared, .probation, .prison], chance: 0.5, days: 15...90,
                 headline: "Power company: our workers never need to come inside",
                 body: "The power company says its workers carry photo ID, drive marked trucks, and almost never need to enter a home. The warning follows the case of {D}, charged with posing as a utility worker to get into the home of {V}, 81."),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Same fake power worker strikes again while {DL} is locked up",
                 body: "A man in a reflective vest talked his way into an older woman's home and took her jewelry, the same way {V} was robbed. {D} was in custody at the time. {DL}'s lawyer has asked Judge {JUDGE} to look at the identification again.")
        ]
    ]
}
