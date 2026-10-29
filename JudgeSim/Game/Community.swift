import Foundation

/// What the public thinks of a case, in words that fit it, and how it takes the ruling. A community that wanted
/// accountability and saw probation remembers; one that rallied behind a defendant and saw a long sentence does too.
/// Its standing with the judge feeds the newspaper poll, and the poll feeds the election.
enum Community {
    /// The tag on a case: what people are saying about this one, not a stock phrase.
    static func label(_ c: CourtCase) -> String {
        var rng = SeededRNG(seed: c.seed ^ 0xC0_4D17)
        let victim = c.victimName != nil
        let died = c.charges.contains { ["murder", "manslaughter", "death by"].contains(where: $0.law.title.lowercased().contains) }
        let child = c.charges.contains { $0.law.title.lowercased().contains("child") }
        let loud = c.mediaAttention >= 2
        var options: [String]
        switch c.mood {
        case .wantsConviction:
            options = ["Community wants accountability", "Neighbors want a conviction", "Public is calling for a strong sentence",
                       "Letters to the editor demand accountability", "The gallery is here for a conviction"]
            if victim { options += ["Victim's supporters fill the gallery", "Victim's family has rallied the neighborhood"] }
            if died { options += ["A memorial outside the courthouse", "Vigils for the victim every week since"] }
            if child { options += ["Parents across the county are watching"] }
            if loud { options += ["Petition for the maximum: thousands of signatures", "Local TV is camped outside", "The paper's editorial board wants the maximum"] }
            if c.category == .whiteCollar || c.category == .cyber { options += ["People who lost money are watching", "Investors want their money back and someone to answer"] }
        case .sympathetic:
            options = ["Community sympathizes with the defendant", "Supporters fill the gallery", "Neighbors are asking for mercy",
                       "Coworkers and church members vouch for the defendant", "Letters asking for leniency keep arriving"]
            if loud { options += ["A fundraiser for the defense went viral", "Petition for leniency: thousands of signatures", "Local TV calls it a hard case"] }
            if c.defendant.age < 21 { options += ["Teachers and coaches are speaking up for the defendant"] }
            if c.defendant.age >= 65 { options += ["Neighbors say the defendant is a fixture in town"] }
        case .divided:
            options = ["Community is divided", "The town is split", "Dueling letters in the paper",
                       "Supporters and critics on opposite sides of the steps", "Arguments about it at every diner counter"]
            if loud { options += ["Dueling social media campaigns", "Protesters on both sides outside", "Talk radio can't stop arguing about it"] }
        case .indifferent:
            options = ["Little public attention", "Barely made the paper", "An empty gallery", "Just another case on the calendar",
                       "No one from the public has come to watch"]
        }
        return rng.pick(options)
    }

    /// How the community takes the outcome: +2 pleased to -2 angry, scaled by how closely it was watching, and the
    /// local story that says so. Nothing for a case no one was following.
    static func reaction(_ c: CourtCase, convicted: Bool, active: Bool, position: SentencePosition?, judgeLast: String,
                         date: Date) -> (delta: Int, news: NewsItem?) {
        var rng = SeededRNG(seed: c.seed ^ 0x2EAC_7100)
        let d = c.defendant
        let last = d.lastName
        let wanted: String = switch c.mood {
        case .wantsConviction: rng.pick(["Many in the community had wanted to see \(last) held to account.",
                                         "From the start, much of the community wanted accountability in this case."])
        case .sympathetic: rng.pick(["\(last) had drawn wide support in the community before trial.",
                                     "Much of the community had rallied behind \(last)."])
        case .divided: "The case had split the community from the start."
        case .indifferent: ""
        }
        var delta = 0
        var headline = ""
        var body = ""
        switch c.mood {
        case .indifferent:
            return (0, nil)
        case .wantsConviction:
            if !convicted {
                delta = -2
                headline = rng.pick(["Anger after \(last) walks free", "'Where is the justice?' Crowd reacts to \(last) ruling",
                                     "Petition circulates against Judge \(judgeLast) after \(last) case"])
                body = rng.pick(["People who packed the courtroom for months left shouting.", "A crowd gathered on the courthouse steps after the ruling, some in tears, some furious.",
                                 "By evening, a petition criticizing Judge \(judgeLast) had hundreds of signatures."])
            } else if !active {
                delta = -1
                headline = rng.pick(["'Probation for that?' Community reacts to \(last) sentence", "Neighbors say \(last) sentence was too light",
                                     "Letters pour in after \(last) avoids prison"])
                body = rng.pick(["Many who followed the case had expected prison and said so outside the courthouse.",
                                 "The newspaper's inbox filled with letters calling the sentence a slap on the wrist.",
                                 "Several people who came for every hearing said they felt the court had let them down."])
            } else if position == .below {
                delta = 0
                headline = rng.pick(["Mixed feelings after \(last) sentence", "\(last) goes to prison, but some wanted more"])
                body = "Some who followed the case welcomed the prison term; others said it was shorter than it should have been."
            } else {
                delta = 1
                headline = rng.pick(["'Justice was done': supporters react to \(last) sentence", "Relief in the gallery as \(last) is sentenced",
                                     "Community that followed \(last) case says the court listened"])
                body = rng.pick(["People who had come to every hearing embraced outside the courtroom.",
                                 "Several said they had worried the case would end with probation, and were relieved.",
                                 c.victimName != nil ? "The victim's supporters thanked the prosecutors on the courthouse steps."
                                    : "Several thanked the prosecutors on the courthouse steps."])
                if position == .above { body += " A few defense lawyers in the hallway called the sentence harsh." }
            }
        case .sympathetic:
            if !convicted || !active {
                delta = 1
                headline = rng.pick(["Supporters celebrate \(last)'s second chance", "Cheers outside the courthouse for \(last)",
                                     "'The judge saw the whole person': supporters react"])
                body = rng.pick(["Supporters who had filled the gallery hugged on the courthouse steps.",
                                 "Family and friends said they would hold \(last) to the chance the court gave.",
                                 "A pastor who spoke at sentencing thanked the court."])
            } else if position == .below {
                delta = 0
                headline = "Tears and relief after \(last) sentence"
                body = "Supporters had hoped to avoid prison, but several said the court had shown some mercy."
            } else {
                delta = position == .above ? -2 : -1
                headline = rng.pick(["Supporters stunned as \(last) is led away", "Vigil for \(last) after prison sentence",
                                     "'This isn't who \(last) is': supporters react to sentence"])
                body = rng.pick(["Supporters sat silent as deputies led \(last) out, then gathered outside to pray.",
                                 "A petition asking the governor for clemency for \(last) went up the same night.",
                                 "Several who wrote letters to the court said they felt nobody had read them."])
                if position == .above { body += " Some called the sentence the harshest they had seen from Judge \(judgeLast)." }
            }
        case .divided:
            delta = 0
            headline = rng.pick(["Ruling in \(last) case settles nothing for a divided town", "Both sides speak out after \(last) ruling",
                                 "\(last) ruling: cheers on one side of the steps, anger on the other"])
            body = convicted ? "One group outside the courthouse applauded; the other said the court got it wrong."
                : "Supporters celebrated while critics said the ruling would only deepen the split."
        }
        // The more people were watching, the more it counts.
        let weight = c.mediaAttention >= 2 ? 2 : 1
        let news = NewsItem(date: date, kind: .community, headline: headline, body: wanted + " " + body,
                            docket: c.docket, prominence: max(0, c.mediaAttention - 1), section: "Local")
        return (delta * weight, news)
    }

    /// What people around town say about the judge, from the rulings they followed.
    static func townTalk(standing: Int) -> String {
        switch standing {
        case ...(-6): return "Around town: people are angry. Letters to the paper and a petition say this court doesn't listen to the community."
        case -5...(-3): return "Around town: grumbling. Several rulings the public followed closely didn't land the way people wanted."
        case -2...2: return "Around town: no strong feelings either way about how this court has handled the cases people followed."
        case 3...5: return "Around town: people feel heard. The cases the public followed ended about the way it hoped."
        default: return "Around town: strong support. The paper's letters page praises this court's handling of the cases people cared about."
        }
    }
}
