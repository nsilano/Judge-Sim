import Foundation

/// What follows particular written cases, by what the judge decided. Each beat is written for its case; some bring a
/// new case back to this court. Tokens: {D} and {DL} for the defendant, {V} and {VL} for the victim, {JUDGE}.
enum StoryAftermath {
    typealias Beat = Aftermath.Beat

    static let beats: [String: [Beat]] = [
        "story.lastPill": [
            Beat(triggers: [.freed], chance: 0.3, days: 120...300,
                 headline: "Second overdose death traced to pills from {DL}, police say",
                 body: "Investigators say a 22-year-old line cook died after taking a pill sold by {D}, months after Judge {JUDGE} acquitted {DL} in the death of {V}. Coworkers told detectives {DL} had kept selling at the restaurant.",
                 followUps: ["story.followup.overdoseDeath"]),
            Beat(triggers: [.probation], chance: 0.6, days: 150...330,
                 headline: "{D} finishes treatment, speaks to restaurant workers about fentanyl",
                 body: "{D}, on probation for selling the pills that killed {V}, told a room of restaurant workers this week that the pills looked exactly like the real thing. \"I'd give anything to have flushed them,\" {DL} said."),
            Beat(triggers: [.prison], chance: 0.5, days: 90...240,
                 headline: "Two mothers, one table: {VL}'s and {DL}'s families meet",
                 body: "The mothers of {V} and of {D}, now in prison for the sale that killed {VL}, spoke together at a county overdose awareness night. \"We both lost a kid to those pills,\" one said."),
        ],
        "story.duplexBurglary": [
            Beat(triggers: [.freed], chance: 0.3, days: 90...240,
                 headline: "Break-ins return to the duplexes off {DL}'s street",
                 body: "A string of car break-ins near the duplex where {V} was burglarized led deputies back to {D}, acquitted in that case by Judge {JUDGE}. Stolen property was found in a storage unit in {DL}'s name.",
                 followUps: ["story.followup.carBreakIns"]),
            Beat(triggers: [.probation], chance: 0.6, days: 120...300,
                 headline: "{VL} gets the last restitution check from {DL}",
                 body: "{V} said the final restitution payment from {D} arrived this month. \"It doesn't give me back the feeling of my own hallway,\" {VL} said. \"But it's something.\""),
            Beat(triggers: [.cleared], chance: 0.5, days: 60...200,
                 headline: "Man in red truck charged with laptop thefts across three counties",
                 body: "A man arrested in a neighboring county with stolen laptops confessed to a break-in at {V}'s duplex. {D}, acquitted by Judge {JUDGE}, had told the court {DL} bought the laptop from a man at a gas station."),
        ],
        "story.homeInvasion": [
            Beat(triggers: [.freed], chance: 0.35, days: 120...300,
                 headline: "Ring from {VL} home invasion turns up with {DL}'s relative",
                 body: "One of the rings taken from {V}'s home surfaced with a relative of {D}, who was acquitted of the home invasion by Judge {JUDGE}. Detectives say they are reviewing the case, but {DL} can't be tried twice for it.",
                 followUps: ["story.followup.occupiedHouse"]),
            Beat(triggers: [.prison], chance: 0.5, days: 200...400,
                 headline: "{VL} and spouse sell the house on their street",
                 body: "{V} and {VL}'s spouse sold the home where they were held at gunpoint. \"We were proud of that house for thirty years,\" {VL} said. \"We couldn't sleep in it one more night.\""),
            Beat(triggers: [.cleared, .wronglyConvicted], chance: 0.6, days: 150...400,
                 headline: "Another arrest in the {VL} home invasion",
                 body: "Deputies arrested a second man in the armed home invasion at {V}'s house, after he confessed to it while charged in a similar crime. He named the State's cooperating witness as his partner, not {D}."),
        ],
        "story.motorcycleChase": [
            Beat(triggers: [.freed], chance: 0.35, days: 60...200,
                 headline: "Trooper clocks the same black motorcycle again",
                 body: "A state trooper says the black sport bike {D} told Judge {JUDGE} {DL} had sold was clocked at over 120 mph near the same exit. This time the rider was caught a mile later.",
                 followUps: ["story.followup.eludingStop"]),
            Beat(triggers: [.cleared], chance: 0.6, days: 60...200,
                 headline: "Marketplace records name the buyer of {DL}'s motorcycle",
                 body: "Records from the online marketplace identified the man who bought {D}'s motorcycle for cash. He has three prior convictions for fleeing police. {DL} was acquitted by Judge {JUDGE}."),
        ],
        "story.fakeCop": [
            Beat(triggers: [.freed], chance: 0.4, days: 60...180,
                 headline: "Another driver reports a fake traffic stop on Route 17",
                 body: "A driver told deputies a man with blue dash lights pulled her over on Route 17 late at night and asked if anyone was waiting for her. Deputies say the description matches the case in which Judge {JUDGE} acquitted {D}."),
            Beat(triggers: [.cleared], chance: 0.6, days: 60...180,
                 headline: "Neighboring county arrests man for fake traffic stops",
                 body: "Deputies in a neighboring county arrested a man driving a dark sedan with blue dash lights after he stopped a woman on a rural road. Investigators are comparing his car to the one {V} described. {D} was acquitted in that case."),
            Beat(triggers: [.probation, .prison], chance: 0.5, days: 90...240,
                 headline: "Sheriff warns: real deputies will let you drive to a lit place",
                 body: "After {D}'s conviction for impersonating an officer, the Sheriff's Office reminded drivers they may call 911 and drive to a lit, public place before pulling over. {V} helped write the notice."),
        ],
        "story.afterTheParty": [
            Beat(triggers: [.freed], chance: 0.4, days: 90...240,
                 headline: "Second student comes forward about {DL}",
                 body: "A second student told campus police that {D}, acquitted of the assault on {V} by Judge {JUDGE}, assaulted her after a party last spring. The university has opened its own investigation."),
            Beat(triggers: [.probation, .prison], chance: 0.5, days: 120...300,
                 headline: "Students march for consent education after {DL} verdict",
                 body: "Hundreds of Hollis State students marched Friday, months after {D}'s conviction. {V} did not speak, but friends carried a sign {VL} had made."),
            Beat(triggers: [.cleared], chance: 0.4, days: 120...300,
                 headline: "{DL} transfers out of Hollis State",
                 body: "{D}, acquitted after a trial before Judge {JUDGE}, has transferred to a school out of state. \"Everyone here knows my name for the worst reason,\" {DL} told the student paper."),
        ],
        "story.followup.gasStationKnife": [
            Beat(triggers: [.freed], chance: 0.35, days: 60...200,
                 headline: "Same gray hoodie, another store, police say",
                 body: "A convenience store clerk was robbed at knifepoint by a man in a gray hooded sweatshirt this week. Detectives say they are looking at {D}, acquitted of a nearly identical robbery by Judge {JUDGE}.",
                 followUps: ["story.followup.occupiedHouse"]),
            Beat(triggers: [.prison], chance: 0.5, days: 90...240,
                 headline: "{VL} back behind the counter",
                 body: "{V} went back to work at the gas station this month, with a new panic button under the counter. \"I wasn't going to let one night take the job too,\" {VL} said."),
        ],
    ]
}
