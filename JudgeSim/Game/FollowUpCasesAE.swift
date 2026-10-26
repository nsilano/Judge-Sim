import Foundation

private typealias E = EvidenceSeed

/// Follow-up trials for the batch AE story. Each is a complete new incident; the earlier case appears only as {PRIOR}
/// and {PRIORDATE}, so it reads the same whatever the earlier verdict was.
extension FollowUpCases {
    static let batchAE: [CaseTemplate] = [filmingStop, parkingLotWords]

    // MARK: - After the receipt check: filming a traffic stop

    static let filmingStop = CaseTemplate(
        key: "story.followup.filmingStop", category: .publicOrder,
        headlines: ["Man Filming Traffic Stop Charged With Obstructing Deputy", "\"Step Back\": Video of Roadside Stop Ends in Arrest"],
        primaryLaw: "resisting", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Willfully resisted, delayed, and obstructed a deputy during a traffic stop by refusing orders to step back and moving toward the stopped car, on {DATE}.",
        ageRange: 24...50, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} now records police whenever {D.he} sees a stop. On {DATE} at about 9:15 p.m., deputies stopped a car with two men in it on {STREET} in {HOOD} on a tip that one had a gun. {DL} pulled over across the road and started filming. A deputy told {D.him} three times to stay back by {D.his} own car. The deputy says {DL} walked to within a few feet of the passenger door while the passenger was being taken out, and was arrested. {DL} says {D.he} stayed on the shoulder the whole time, more than twenty feet away, and that the arrest was because {D.he} was filming. Both {DL}'s video and the deputy's body camera were recovered."
        ],
        prosecutionEvidence: [
            E(.video, 2, "Deputy's Body Camera", "The deputy says \"Stay back by your car\" three times. In the last part, {DL} is visible at the edge of the frame near the rear of the stopped car while the passenger is being searched."),
            E(.statement, 2, "Second Deputy's Report", "The second deputy writes that {DL} came \"within arm's reach of the passenger door\" while a possible gun was unaccounted for.")
        ],
        defenseEvidence: [
            E(.video, 2, "Defendant's Recording", "{DL}'s own video, shot from across the road. The stopped car stays small in the frame until the last ten seconds, when the picture moves closer."),
            E(.document, 1, "Measured Diagram", "A defense investigator's diagram of the roadside, putting the shoulder where {DL} says {D.he} stood twenty-four feet from the passenger door.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Deputy, Hollis County Sheriff's Office",
                        direct: ["\"I told {D.him} three times to stay back.\""],
                        cross: ["\"Filming was fine. Coming closer wasn't.\""],
                        weight: 2, lay: false,
                        exam: [
                            .direct("Why did you tell {DL} to stay back?", "\"We had a tip one of those men had a gun. Until we found it, nobody else needed to be near that car.\""),
                            .direct("Did {D.he} stay back?", "\"Not after the third time. {D.He} walked across the road toward the passenger side while we were getting the passenger out.\"", "\"{D.He} came across the road while my partner had the passenger out. That's when I arrested {D.him}.\""),
                            .direct("Did you find a gun?", "\"Under the passenger seat.\""),
                            .cross("You'd agree {DL} had every right to record you?", "\"Yes. I told {D.him} to record from by {D.his} car.\""),
                            .cross("How close was {D.he}, exactly?", "\"Close enough I took my eyes off the passenger to deal with {D.him}. I'd say ten feet.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["Recording is lawful. Walking up on an armed traffic stop after three orders to stay back is not."],
        defenseTheory: ["{DL} filmed from the shoulder across the road. {D.He} was arrested for the camera, not for where {D.he} stood."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        allocutions: ["\"I film because of what happened to me before. I'll keep doing it, from farther back.\""],
        guiltyTruths: ["The passenger's own phone, recovered later, filmed {DL} standing beside the rear door, close enough to touch it, while the gun was still under the seat."],
        innocentTruths: ["A neighbor's doorbell camera across the road showed {DL} on the shoulder the whole time; the closer shot on {D.his} video was the phone's zoom."],
        moods: [.divided], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(0, "9:15 p.m.: deputies stop a car on a gun tip; {DL} begins filming across the road. 9:19 p.m.: third order to stay back. 9:20 p.m.: {DL} arrested; a handgun found under the passenger seat."), (2, "Both videos collected.")],
            howIdentified: "Arrested at the scene.",
            notDone: ["Nobody canvassed the houses across the road for cameras."],
            defendantExam: [
                .direct("Where were you standing?", "\"On the shoulder across the road, by my car. I never crossed the center line.\""),
                .direct("Why were you filming?", "\"After what happened to me at Harbor Mart, I film every stop I see. People deserve a record.\""),
                .cross("You heard the deputy tell you three times to stay back.", "\"I heard the order. I was back.\""),
                .cross("Your own video gets closer at the end.", "\"I zoomed in. My feet didn't move.\"")
            ],
            prosecutionOpening: "Three orders to stay back, and a gun still in the car.",
            defenseOpening: "Someone with a phone on the far shoulder.",
            prosecutionClosing: "This wasn't an arrest for a camera. It was an arrest of someone who walked up on an armed stop after being told three times not to.",
            defenseClosing: "Zooming a phone isn't walking across a road. The State has to prove where {DL}'s feet were, and it can't."
        )
    )

    // MARK: - After the receipt check: words in the parking lot

    static let parkingLotWords = CaseTemplate(
        key: "story.followup.parkingLotWords", category: .publicOrder,
        headlines: ["Words in a Store Parking Lot End in Threat Charge", "Loss Prevention Worker Reports Threat From Former Shopper"],
        primaryLaw: "communicatingThreats", lesserLaw: nil, threshold: 6, lesserThreshold: 0,
        specification: "Willfully threatened to physically injure a Harbor Mart loss prevention associate, in a manner that a reasonable person would believe would be carried out, on {DATE}.",
        ageRange: 24...50, occupations: [], hasVictim: false,
        summaries: [
            "After {DL}'s case in this court in {PRIORDATE} for {PRIOR}, {D} saw the Harbor Mart loss prevention associate from that night in the store's parking lot on {DATE} at about 8:30 p.m. The associate says {DL} walked up to the associate's car and said, \"You got me locked up. You're going to see me again, and next time you won't walk away.\" {DL} says {D.he} said, \"You're going to see me again, in civil court,\" and walked off. Nobody else heard the words. A parking lot camera shows the two men talking for about forty seconds and {DL} walking away."
        ],
        prosecutionEvidence: [
            E(.statement, 2, "Associate's Statement", "The associate's written statement the same night: the words {DL} is said to have used, and \"I believed it.\""),
            E(.video, 1, "Parking Lot Camera", "Forty seconds of silent footage: {DL} walks up, the two men talk, {DL} points at the associate once, then walks away.")
        ],
        defenseEvidence: [
            E(.document, 2, "Civil Complaint", "A lawsuit against Harbor Mart filed by {DL}'s lawyer two weeks before, naming the associate as a witness.")
        ],
        prosecutionWitnesses: [
            WitnessSeed(name: nil, role: "Loss prevention associate, Harbor Mart",
                        direct: ["\"{D.He} said next time I wouldn't walk away.\""],
                        cross: ["\"Nobody else heard it.\""],
                        weight: 2, lay: true,
                        exam: [
                            .direct("What did {DL} say to you?", "\"'You got me locked up. You're going to see me again, and next time you won't walk away.'\""),
                            .direct("How did you take that?", "\"As a threat. {D.He} pointed at me when {D.he} said it.\""),
                            .cross("You knew {DL} had sued the store?", "\"I'd heard. My manager told me I might have to testify.\""),
                            .cross("Could {D.he} have said you'd see {D.him} in civil court?", "\"That's not what I heard.\"", "\"I know what I heard.\""),
                            .cross("Nobody else heard the words?", "\"No. It was just us.\"")
                        ])
        ],
        defenseWitnesses: [],
        prosecutionTheory: ["{DL} sought out the man who stopped {D.him}, pointed at him, and told him next time he wouldn't walk away."],
        defenseTheory: ["{DL} told a witness in {D.his} lawsuit he'd see {D.him} in court. A threat case needs more than one man's ear."],
        aggravating: [],
        mitigating: ["No prior criminal record"],
        allocutions: ["\"I shouldn't have walked over there. I was angry. I didn't threaten anybody.\""],
        guiltyTruths: ["{DL} texted a cousin twenty minutes later: \"ran into that loss prevention from harbor mart. told em to watch their back.\""],
        innocentTruths: ["A shopper loading groceries two cars over came forward after the case: she heard {DL} say \"civil court\" and laugh on the way back to {D.his} car."],
        moods: [.indifferent], doctrines: ["burdenOfProof"],
        story: StoryExtras(
            timeline: [(-14, "{DL}'s lawsuit against Harbor Mart filed."), (0, "8:30 p.m.: {DL} and the associate talk in the parking lot; the associate calls deputies."), (1, "{DL} charged on the associate's statement.")],
            howIdentified: "Named by the associate, who knew {D.him} from the earlier case.",
            notDone: ["Deputies didn't look for other shoppers in the lot."],
            defendantExam: [
                .direct("Why did you walk over there?", "\"I recognized the loss prevention worker from that night. I wanted to show I wasn't scared anymore.\""),
                .direct("What did you say?", "\"'You're going to see me again, in civil court.' That's it.\""),
                .cross("You pointed.", "\"I pointed. I didn't threaten.\""),
                .cross("You walked across a parking lot to confront a witness in your own lawsuit.", "\"Looking back, I shouldn't have.\"")
            ],
            prosecutionOpening: "A defendant who walked up to the witness against {D.him} and said the witness wouldn't walk away next time.",
            defenseOpening: "Two words the State left out: civil court.",
            prosecutionClosing: "{DL} went looking for the witness, pointed, and made sure the witness was scared. That's a threat.",
            defenseClosing: "One person heard it, and that person is a witness in a lawsuit against the store. That isn't proof beyond a reasonable doubt."
        )
    )
}
