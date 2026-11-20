import Foundation

/// What a victim or the victim's family says at a hearing, by kind of case and kind of hearing. It's said, never counted:
/// the card shows what was said, and what the court does with it shows up afterward.
enum VictimStatement {
    /// The statement and what the victim wants ("custody", "nocontact", "lenient", "active", "agree", "restitution", "deny").
    static func statement(for c: CourtCase, kind: CalendarMatter.Kind, seed: UInt64) -> (text: String, wish: String)? {
        guard let victim = c.victimName, !victim.isEmpty else { return nil }
        var rng = SeededRNG(seed: seed ^ 0x71C7)
        guard rng.chance(0.55) else { return nil }
        let d = c.defendant.lastName
        let violent = [LawCategory.violent, .robbery].contains(c.category)
        let family = c.category == .family
        switch kind {
        case .firstAppearance:
            if violent || family {
                return rng.pick([
                    ("\(victim) is in the gallery and asks the court to keep \(d) in custody until trial.", "custody"),
                    ("\(victim)'s family sits in the second row. A relative asks for a no-contact condition if \(d) is released.", "nocontact"),
                    ("\(victim) says it is hard to sleep with \(d) out and asks the court to take that into account.", "custody"),
                    ("\(victim) does not want to be in the same room as \(d) and asks for a stay-away condition.", "nocontact")])
            }
            return rng.pick([
                ("\(victim) asks only that \(d) be ordered to stay away from the property and make it right.", "nocontact"),
                ("\(victim) says the loss was serious but does not want \(d) held on a bond \(d) can't pay.", "lenient"),
                ("\(victim) asks the court to make sure \(d) understands this was not a prank.", "custody")])
        case .quickPlea:
            return rng.pick([
                ("\(victim) was told about the plea and asks the court to make sure the sentence reflects what happened.", "active"),
                ("\(victim) has been consulted and agrees with the State's recommendation.", "agree"),
                ("\(victim) wants restitution above all and says jail time matters less.", "restitution"),
                ("\(victim) asks to be heard and says the plea does not feel like enough.", "active")])
        case .continuance:
            return rng.pick([
                ("\(victim) asks the court not to delay again; the case has hung over \(victim) for months.", "deny"),
                ("\(victim) took off work for this date and asks that it go forward.", "deny")])
        default:
            return nil
        }
    }

    /// Whether the ruling went the way the victim asked. nil when there is nothing to compare.
    static func satisfied(wish: String, kind: CalendarMatter.Kind, choice: Int) -> Bool? {
        switch (kind, wish) {
        case (.firstAppearance, "custody"): return choice >= 3
        case (.firstAppearance, "nocontact"): return choice >= 3
        case (.firstAppearance, "lenient"): return choice <= 3
        case (.quickPlea, "active"): return choice == 2 || choice == 4
        case (.quickPlea, "agree"): return choice != 3
        case (.quickPlea, "restitution"): return choice == 0 || choice == 1
        case (.continuance, "deny"): return choice == 1
        default: return nil
        }
    }

    /// What the family says leaving the courtroom after a ruling that went against them.
    static func disappointment(victim: String, defendant: String, kind: CalendarMatter.Kind, rng: inout SeededRNG) -> String {
        switch kind {
        case .firstAppearance:
            return rng.pick(["\(victim)'s family left the courtroom without speaking after \(defendant) was released.",
                             "\(victim) told the clerk afterward that \(victim) is afraid of what happens when \(defendant) gets home."])
        case .quickPlea:
            return rng.pick(["\(victim) shook \(victim)'s head at the sentence and left before the next case was called.",
                             "\(victim)'s family said afterward that the plea did not feel like justice."])
        default:
            return "\(victim) left the courtroom visibly frustrated by another delay."
        }
    }
}

/// Questions about the judge's own conduct under the North Carolina Code of Judicial Conduct. Each has an option that is
/// plainly right, one that is a small lapse, and one that is a real problem; what comes of the choice shows up later.
enum EthicsQuestions {
    struct Scenario {
        var id: String
        var summary: String
        var note: String
        var options: [String]
        /// How each option rates: 0 right, 1 a small lapse, 2 a real problem.
        var severity: [Int]
        /// Which side hears about it if it goes wrong: true the State, false the defense.
        var stateAggrieved: Bool
    }

    static func matter(county: County, rng: inout SeededRNG) -> CalendarMatter {
        let defense = rng.pick(county.assistantPDs + county.privateCounsel).components(separatedBy: ",").first ?? "a defense lawyer"
        let prosecutor = rng.pick(county.assistantDAs)
        let scenario = scenarios(defense: defense, prosecutor: prosecutor, clerk: county.clerk, newspaper: county.newspaper).randomElement(using: &rng)!
        return CalendarMatter(kind: .ethics, personID: UUID(), personName: "Judicial conduct", personAge: 0, occupation: "", docket: "Chambers",
                              summary: scenario.summary, stateAsk: "", defenseAsk: "", options: scenario.options, lawID: scenario.id, lawNote: scenario.note)
    }

    static func scenario(id: String, county: County) -> Scenario? {
        scenarios(defense: "", prosecutor: "", clerk: county.clerk, newspaper: county.newspaper).first { $0.id == id }
    }

    private static func scenarios(defense: String, prosecutor: String, clerk: String, newspaper: String) -> [Scenario] {
        [
            Scenario(id: "ethics.exParte",
                     summary: "Before court, defense counsel \(defense) catches you in the hallway to talk about the merits of a pending case. The prosecutor is not there.",
                     note: "Canon 3A(4): a judge may not consider ex parte communications about a pending matter.",
                     options: ["Stop the conversation and disclose it on the record to the State", "Listen briefly and say nothing about it", "Hear the whole argument; it is only a continuance"],
                     severity: [0, 1, 2], stateAggrieved: true),
            Scenario(id: "ethics.neighbor",
                     summary: "A witness the State plans to call in next month's trial turns out to be a neighbor you have known for years.",
                     note: "Canon 3C: a judge must disqualify when impartiality might reasonably be questioned. The parties may waive after disclosure.",
                     options: ["Disclose it on the record and offer to step aside", "Disclose it and continue if both sides waive", "Say nothing; it is only a witness"],
                     severity: [0, 0, 2], stateAggrieved: false),
            Scenario(id: "ethics.gift",
                     summary: "A gift basket arrives at chambers from prosecutor \(prosecutor), with a note thanking you for your \"fair rulings.\"",
                     note: "Canon 4D: a judge may not accept a gift from a lawyer likely to appear before the court.",
                     options: ["Return it with a polite note", "Donate it to a charity and tell the defense bar", "Keep it"],
                     severity: [0, 0, 1], stateAggrieved: false),
            Scenario(id: "ethics.campaign",
                     summary: "A lawyer who appears before you every week offers a contribution to your next campaign.",
                     note: "Canon 7: a judge may not solicit funds personally, and contributions from lawyers who appear before the judge invite questions.",
                     options: ["Decline, and ask the committee to refuse it", "Let the committee accept it and disclose it on the record in the lawyer's cases", "Accept it and say nothing"],
                     severity: [0, 1, 2], stateAggrieved: false),
            Scenario(id: "ethics.press",
                     summary: "A reporter from \(newspaper) asks you to comment on a case still pending in your court.",
                     note: "Canon 3A(6): a judge may not make a public comment on a pending matter that might affect its outcome.",
                     options: ["Decline to comment on a pending case", "Say something general about how bail works", "Discuss the case; the public deserves to know"],
                     severity: [0, 1, 2], stateAggrieved: true),
            Scenario(id: "ethics.clerk",
                     summary: "Clerk \(clerk) mentions that the lawyer on a pending motion has called three times to ask when you will rule.",
                     note: "Canon 3A(4) and 3B: communications about a pending matter should go through the court, with the other side informed.",
                     options: ["Tell the clerk to answer only with the court's schedule, and tell both sides", "Tell the clerk to say you will rule soon", "Tell the clerk to let the lawyer know which way you are leaning"],
                     severity: [0, 1, 2], stateAggrieved: false)
        ]
    }
}
