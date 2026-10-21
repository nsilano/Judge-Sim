import Foundation

/// A judge who believes a witness lied under oath can send the transcript to the district attorney. The judge doesn't
/// charge anyone: the DA decides, a grand jury indicts, and another judge tries it, since this one heard the testimony.
/// Perjury (G.S. 14-209) needs a false statement, about something that mattered, made knowing it was false; and the
/// falsity has to be proved by more than one witness's word against another's.
enum Perjury {

    /// How the DA sees a referral.
    struct Assessment {
        /// What the witness said that the referral is about, in the witness's words.
        let statement: String?
        let falseInFact: Bool
        /// Not just wrong: the witness had to know. Someone who was asleep, or unsure, can be wrong without lying.
        let knowing: Bool
        /// Proof beyond the witness's own contradiction: strong evidence, or records that broke the alibi.
        let provable: Bool
        var charged: Bool { falseInFact && knowing && provable }
    }

    /// Words that show a witness was guessing, or couldn't have known.
    private static let hedges = ["asleep", "fell asleep", "sleep aid", "sleep hard", "i think", "maybe", "i'm not sure", "not sure", "i guess",
                                 "probably", "couldn't see", "it was dark", "i was scared", "it happened fast", "i don't remember", "i assume",
                                 "i believe", "pretty sure", "headphones"]

    /// Words that put the witness personally, and awake, with the defendant somewhere else.
    private static let presence = ["with me", "we were", "together", "the whole", "all night", "all evening", "the entire", "on the couch with me",
                                   "i was with", "we watched", "we went", "we got", "i drove", "we drove", "never left", "right next to me"]

    static func answers(_ w: Witness) -> [String] {
        (w.exchanges?.map(\.answer) ?? (w.direct + w.cross))
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\" ")) }
            .filter { !$0.isEmpty }
    }

    static func assess(_ w: Witness, in c: CourtCase, convicted: Bool) -> Assessment {
        let said = answers(w)
        let text = said.joined(separator: " ").lowercased()
        // Officers and experts give opinions and reports; a rejected opinion isn't a lie.
        let lay = w.lay ?? !Testimony.isOfficial(w.role)
        let favorsDefense = w.calledBy == .defense
        let falseInFact = lay && (favorsDefense ? c.truth.actuallyGuilty && convicted : !c.truth.actuallyGuilty)
        let hedged = hedges.contains { text.contains($0) }
        let present = presence.contains { text.contains($0) }
        let knowing = falseInFact && present && !hedged
        // The State needs proof of falsity beyond one witness against another: records that broke an alibi,
        // or a case strong enough that the testimony can't be squared with it.
        let brokeAlibi = c.evidence.contains { $0.side == .prosecution && ($0.supplemental ?? "").contains("alibi was checked") }
        let strong = c.charges.first.map { Judgment.properStrength(c) >= $0.threshold + 2 } ?? false
        let provable = brokeAlibi || (favorsDefense ? strong : false)
        let statement = said.first { line in presence.contains { line.lowercased().contains($0) } } ?? said.first
        return Assessment(statement: statement, falseInFact: falseInFact, knowing: knowing, provable: provable)
    }

    /// The news that follows a referral: the DA's decision, and if there's a charge, how it ends.
    static func events(for w: Witness, in c: CourtCase, convicted: Bool, judgeLast: String, date: Date) -> [PendingEvent] {
        var rng = SeededRNG(seed: c.seed ^ SeededRNG.stableHash(w.name) ^ 0x9E7)
        let a = assess(w, in: c, convicted: convicted)
        let cal = CourtCalendar.calendar
        let decided = cal.date(byAdding: .day, value: rng.int(18...40), to: date) ?? date
        let who = "\(w.name), who testified as \(w.role.lowercased().withIndefiniteArticle) in \(c.caption)"
        let quote = a.statement.map { " Under oath, \(w.name) told the court: \"\(CounselBrief.clip($0, 160))\"" } ?? ""
        guard a.charged else {
            let reason: String
            if !a.falseInFact {
                reason = "The district attorney's office said nothing it found shows the testimony was false."
            } else if !a.knowing {
                reason = rng.pick(["\"Being wrong isn't lying,\" the district attorney said. \"The witness could have honestly believed it.\"",
                                   "The district attorney's office said the witness may have been mistaken, and perjury requires a knowing lie.",
                                   "Prosecutors said the witness's account was wrong but not provably dishonest; the witness wasn't in a position to know."])
            } else {
                reason = "The district attorney's office said it couldn't prove the testimony false with more than the witness's word against another's, as North Carolina law requires."
            }
            return [PendingEvent(due: decided, news: NewsItem(date: decided, kind: .community,
                                                              headline: "No perjury charge for witness in \(c.defendant.lastName) case",
                                                              body: "Prosecutors will not charge \(who), with perjury after Judge \(judgeLast) referred the testimony for review.\(quote) \(reason)",
                                                              docket: c.docket, prominence: 1))]
        }
        let indicted = PendingEvent(due: decided, news: NewsItem(
            date: decided, kind: .arrest, headline: "\(w.name) indicted for perjury",
            body: "A Hollis County grand jury indicted \(who), on a charge of perjury, a Class F felony (G.S. 14-209). Judge \(judgeLast) referred the testimony to the district attorney after the trial.\(quote) The case will be heard by another judge, since Judge \(judgeLast) heard the testimony.",
            docket: c.docket, prominence: 2))
        let resolved = cal.date(byAdding: .day, value: rng.int(70...140), to: decided) ?? decided
        let judge = "Judge " + rng.pick(NameBank.lastNames)
        let ending = rng.chance(0.75)
            ? "\(w.name) pleaded guilty to perjury before \(judge) and received a suspended sentence of 10 to 21 months, 24 months of supervised probation and 50 hours of community service."
            : "\(w.name) was convicted of perjury after a short trial before \(judge) and sentenced to 10 to 21 months in prison."
        let done = PendingEvent(due: resolved, news: NewsItem(
            date: resolved, kind: .verdict, headline: "Witness in \(c.defendant.lastName) case convicted of perjury",
            body: "\(ending) Prosecutors said records proved the testimony at \(c.defendant.lastName)'s trial false, and that \(w.name) knew it when testifying.",
            docket: c.docket, prominence: 1))
        return [indicted, done]
    }
}
