import Foundation

/// What follows the street takeover story: a return to this court on a different driving or property charge each time.
/// Tokens: {D} and {DL} for the defendant, {JUDGE}.
extension StoryAftermath {
    static let beatsBO: [String: [Beat]] = [
        "story.streetTakeover": [
            Beat(triggers: [.freed, .probation, .cleared], chance: 0.35, days: 30...200,
                 headline: "Car Meet Organizer Arrested Again",
                 body: "Deputies say {D}, whose earlier case was heard by Judge {JUDGE}, is facing a new charge from another night of racing and car meets.",
                 followUps: ["story.followup.takeoverRaceBack", "story.followup.takeoverEludeBack",
                             "story.followup.takeoverFieldBack", "story.followup.takeoverDisperseBack"]),
            Beat(triggers: [.probation, .prison, .freed], chance: 0.3, days: 40...150,
                 headline: "Sheriff Sets Up Task Force on Street Takeovers",
                 body: "Weeks after Judge {JUDGE} heard a street takeover case, the sheriff announced a weekend task force. Deputies now watch empty lots and country roads for car meets.")
        ]
    ]
}
