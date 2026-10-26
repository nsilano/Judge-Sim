import Foundation

/// What follows the batch AE written case. Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsAE: [String: [Beat]] = [
        "story.receiptCheck": [
            Beat(triggers: [.cleared], chance: 0.6, days: 45...200,
                 headline: "{DL} sues Harbor Mart and sheriff's office over receipt-check arrest",
                 body: "{D}, acquitted by Judge {JUDGE} after being arrested at a Harbor Mart exit with a television {DL} had paid for, has filed a federal lawsuit. It claims a loss prevention worker held {DL} without cause and a deputy seized {D.his} phone to stop a recording. Harbor Mart said it does not comment on pending litigation."),
            Beat(triggers: [.cleared, .freed], chance: 0.5, days: 30...150,
                 headline: "Harbor Mart retrains staff: receipt checks are voluntary",
                 body: "After the arrest of {D} at its exit, Harbor Mart says every loss prevention worker in Hollis County has been retrained: workers may ask for a receipt but may not block a customer's cart unless they saw a theft themselves."),
            Beat(triggers: [.cleared, .freed], chance: 0.4, days: 20...120,
                 headline: "Sheriff issues memo on recording deputies after Harbor Mart arrest",
                 body: "The sheriff told deputies in a memo that people may record them in public, and that a phone may not be taken just to stop a recording. The memo follows the case of {D}, whose phone a deputy took during a receipt dispute at Harbor Mart."),
            Beat(triggers: [.cleared, .freed, .probation], chance: 0.25, days: 120...330,
                 headline: "{DL} arrested while filming traffic stop",
                 body: "{D}, whose arrest at a Harbor Mart exit was heard by Judge {JUDGE}, was charged with obstructing a deputy while recording a roadside stop. Deputies say {DL} came too close to the stopped car; {DL} says {D.he} never left the far shoulder.",
                 followUps: ["story.followup.filmingStop"]),
            Beat(triggers: [.cleared, .freed, .probation], chance: 0.2, days: 90...300,
                 headline: "Harbor Mart worker says {DL} made a threat in the parking lot",
                 body: "A Harbor Mart loss prevention worker says {D} walked up in the store's parking lot and told the worker \"next time you won't walk away.\" {DL} says the words were \"see you in civil court.\" Judge {JUDGE} heard {DL}'s earlier case over a television and a missing receipt.",
                 followUps: ["story.followup.parkingLotWords"]),
            Beat(triggers: [.wronglyConvicted], chance: 0.6, days: 60...240,
                 headline: "Register log shows {DL}'s TV sale went through",
                 body: "A log from Harbor Mart's register vendor shows the television sale {D} was convicted of stealing actually posted at 6:24 p.m., while {DL} was being booked; a jammed printer had held it. {DL}'s lawyer has asked Judge {JUDGE} to set the conviction aside."),
            Beat(triggers: [.probation], chance: 0.4, days: 60...200,
                 headline: "{DL} pays Harbor Mart, finishes community service",
                 body: "{D}, on probation over a television that left Harbor Mart without a completed sale, has paid the store in full and finished community service, a probation officer reported.")
        ]
    ]
}
