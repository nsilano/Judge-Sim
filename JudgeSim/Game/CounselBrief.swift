import Foundation

/// The instructions and case file a lawyer works from when the judge asks a free-form question.
/// It holds only what that lawyer would know. What really happened is never included.
enum CounselBrief {

    /// Shortens text for the on-device model's small context window.
    static func clip(_ text: String, _ limit: Int) -> String {
        text.count <= limit ? text : String(text.prefix(limit)) + "…"
    }

    private static func compactPersona(name: String, style: CounselStyle, office: String) -> String {
        "You are \(name), \(office) in Hollis County, North Carolina. You are at the bench answering the judge's question. Your manner: \(style.label.lowercased()). "
            + "Speak in first person to the judge (\"Judge\" or \"Your Honor\"), one to three sentences. Answer exactly what was asked, in fresh words. "
            + "Advocate for your side but never misstate facts. Use only the case file; if it doesn't say, say you don't know. Never invent evidence. "
            + "No stage directions. Never mention AI or a game."
    }

    private static func persona(name: String, side: Side, style: CounselStyle, office: String) -> String {
        let manner: String
        switch style {
        case .methodical: manner = "methodical and precise; you cite the record and the statute, and you don't overstate"
        case .aggressive: manner = "aggressive; you rarely concede a point, but you never misstate the record"
        case .pragmatic: manner = "pragmatic; you look for a sensible resolution and will concede weak points to protect strong ones"
        case .earnest: manner = "earnest and client-focused; you humanize your client"
        case .combative: manner = "combative; you push every point and challenge the State's story"
        case .folksy: manner = "folksy and plain-spoken; small-town North Carolina, but sharp"
        }
        return """
        You are \(name), \(office) in Hollis County, North Carolina (a fictional county). You are standing at the bench in Superior Court, answering the judge's question in a bench conference. Your manner: \(manner).

        Rules for every answer:
        - Speak aloud to the judge, in the first person, as \(name). Address the judge as "Judge" or "Your Honor". One to four sentences unless the judge asks for more.
        - Answer the question actually asked. If the judge asks something you already answered, answer it again in fresh words, adding what's useful; don't repeat yourself verbatim.
        - Advocate for your side, but you owe the court candor (N.C. Rule of Professional Conduct 3.3): never misstate a fact or the law.
        - Use only the facts in the case file below. If the judge asks about something the file doesn't cover, say you don't know or would need to check. Never invent evidence, witnesses, records, or events.
        - North Carolina law applies: the Rules of Evidence, Chapter 15A, and Structured Sentencing. Be accurate; if unsure about a legal point, say so.
        - This is happening now, in the courtroom. Don't narrate, don't use stage directions, and never mention being an AI, a game, or a simulation.
        - Don't tell the judge how to rule on guilt as a certainty, and never claim to know what really happened beyond the evidence.
        - The game is latency-sensitive; begin your answer immediately.
        - Set raises_factor to false unless the instructions at the end say otherwise.
        """
    }

    // MARK: Trial cases

    static func make(for c: CourtCase, side: Side, stage: CaseSession.Stage, rulings r: Rulings, units: [SentencingUnit],
                     compact: Bool = false) -> String {
        let n = compact ? 160 : 2_000
        let bg = c.background ?? CounselDialogue.fallbackBackground
        let name = CounselDialogue.name(c, side: side)
        let office = side == .prosecution
            ? "an Assistant District Attorney prosecuting this case for the State"
            : (c.defenseAttorney.contains("Public Defender") ? "an Assistant Public Defender representing the defendant" : "private defense counsel retained by the defendant")
        let style = CounselDialogue.style(c, side: side)
        var lines: [String] = [compact ? compactPersona(name: name, style: style, office: office)
                                       : persona(name: name, side: side, style: style, office: office), "", "CASE FILE"]

        lines.append("\(c.caption), \(c.docket). \(c.court.label). Investigating agency: \(c.investigatingAgency).")
        lines.append("Opposing counsel: \(side == .prosecution ? c.defenseAttorney : c.prosecutor).")
        lines.append("Summary: \(clip(c.summary, n * 2))")
        for charge in c.charges {
            var text = "Count \(charge.count): \(charge.law.title) (\(charge.law.statute), \(charge.law.ncClass?.label ?? "")). \(charge.specification)"
            if let lesser = charge.lesserLaw { text += " Lesser-included offense: \(lesser.title)." }
            lines.append(text)
        }
        if !compact { lines.append(contentsOf: c.proceduralNotes.map { "Procedural note: \($0)" }) }

        let d = c.defendant
        lines.append("Defendant: \(d.name), age \(d.age), \(d.occupation). \(clip(d.background, n))")
        lines.append(d.priors.isEmpty ? "Prior record: none." :
            "Prior record: " + d.priors.map { "\($0.year) \($0.offense) (\($0.ncClass.shortLabel), \($0.county)): \($0.sentence)" }.joined(separator: "; ") + ".")
        if let probation = d.probation {
            lines.append("On probation at the time in \(probation.docket) for \(probation.offense); suspended sentence \(probation.suspendedSentence).")
        }
        if let profile = d.profile {
            lines.append("Defendant's work: " + profile.jobs.map { "\($0.title), \($0.employer) (\($0.years))" }.joined(separator: "; ") + ".")
            if !compact { lines.append("Defendant's life: \(profile.education) \(profile.family) \(profile.residence) \(profile.income)") }
        }
        if let victim = c.victimName { lines.append("Victim: \(victim).") }
        if let report = c.investigation {
            lines.append("Investigation (\(report.agency), lead \(report.leadInvestigator)): \(report.howIdentified)" + (report.notDone.isEmpty ? " Nothing obvious was left undone." : " Not done: \(report.notDone.joined(separator: " "))"))
            if !compact {
                lines.append("Timeline: " + report.timeline.map { "\($0.when): \($0.what)" }.joined(separator: " | "))
                if !report.lab.isEmpty { lines.append("Lab: " + report.lab.joined(separator: " ")) }
            }
        }

        lines.append("Evidence:")
        let excluded = r.excludedEvidence(in: c)
        for e in c.evidence {
            lines.append("- \(e.exhibit) (\(e.side.rawValue), \(e.kind.label)): \(e.title). \(clip(e.detail, n))" + (excluded.contains(e.id) ? " [SUPPRESSED by the judge's ruling; it may not be considered.]" : ""))
        }
        lines.append("Witnesses:")
        for w in c.witnesses {
            if !compact, let exchanges = w.exchanges {
                lines.append("- \(w.name), \(w.role), called by the \(w.calledBy.rawValue): " + exchanges.map { $0.question.isEmpty ? $0.answer : "Q: \($0.question) A: \($0.answer)" }.joined(separator: " "))
            } else {
                lines.append("- \(w.name), \(w.role), called by the \(w.calledBy.rawValue). Direct: \(clip(w.direct.joined(separator: " "), n)) Cross: \(clip(w.cross.joined(separator: " "), n))")
            }
        }
        for m in c.motions {
            let ruling = r.motions[m.id].map { $0 ? "GRANTED" : "DENIED" } ?? "not yet ruled on"
            lines.append(compact
                ? "Motion: \(m.kind.title). Facts: \(clip(m.facts, n)) Ruling: \(ruling)."
                : "Motion: \(m.kind.title). Facts: \(m.facts) Defense: \(m.defenseArgument) State: \(m.prosecutionResponse) Ruling: \(ruling).")
        }
        lines.append("State's theory: \(clip(c.prosecutionOpening, n))")
        lines.append("Defense theory: \(clip(c.defenseOpening, n))")
        if let twist = c.twist { lines.append("Also known: \(twist)") }

        // What this side knows that the other may not
        if side == .prosecution {
            lines.append("What you know as the prosecutor:")
            lines.append("- Plea: " + (bg.arrangementPresented == true ? "an arrangement is before the court: \(bg.arrangementTerms ?? "")" : (bg.pleaOffer.map { "you offered: \($0) It was rejected." } ?? "no offer was made.")))
            lines.append("- Victim's position: \(bg.victimStanceDetail)")
            lines.append("- Restitution: " + (bg.restitution > 0 ? "\(SentenceFormat.dollars(bg.restitution)) for \(bg.restitutionBasis ?? "losses"), documented." : "none sought."))
            lines.append("- Discovery: " + (bg.discoveryIssue ?? "fully complied, open file."))
            lines.append("- Advanced Supervised Release: the State \(bg.stateObjectsToASR ? "objects" : "does not object").")
            if d.probation != nil {
                lines.append("- Notice of the probation point: " + ((bg.probationPointNotice ?? true) ? "served more than 30 days before trial." : "NOT served. Concede it if asked."))
            }
            if c.habitualIndicted { lines.append("- Habitual felon indictment based on prior felonies.") }
            lines.append("- Aggravating factors you will argue: " + (c.aggravating.isEmpty ? "none" : c.aggravating.joined(separator: "; ")) + ".")
        } else {
            lines.append("What you know as defense counsel (privileged; share only what helps your client and is true):")
            lines.append("- Plea: " + (bg.arrangementPresented == true ? "your client agreed to: \(bg.arrangementTerms ?? "")" : (bg.pleaRejection ?? "no offer you could take back to your client.")))
            lines.append("- Custody: \(bg.bondStatus)")
            lines.append("- Will the client testify: \(bg.willTestify ? "likely yes" : "no; it's the client's decision and they've chosen not to").")
            if let need = bg.treatmentDetail { lines.append("- Treatment need: \(need) Treatment bed \(bg.treatmentBedAvailable ? "available next week" : "waitlisted").") }
            lines.append("- Plan if released: \(bg.employmentPlan ?? "still being worked out").")
            lines.append("- Ability to pay: \(bg.indigent ? "indigent, no assets" : "employed, can make monthly payments").")
            if let support = bg.supportPeople { lines.append("- Support: \(support)") }
            if let disputed = bg.disputedPriorReason { lines.append("- You dispute a prior: \(disputed)") }
            lines.append("- Mitigating factors you will argue: " + (c.mitigating.isEmpty ? "none" : c.mitigating.joined(separator: "; ")) + ".")
        }

        // Where the case stands right now
        lines.append("")
        lines.append("WHERE THE CASE STANDS NOW")
        lines.append("Stage: \(stage.title).")
        if r.pleaAccepted == true { lines.append("The judge accepted a \(r.pleaKind.label.lowercased()) plea; there was no trial.") }
        if r.pleaWithdrawn { lines.append("The defendant withdrew a plea after the judge announced a harsher sentence; the case is being tried.") }
        let sustained = c.objections.filter { r.objections[$0.id] == true }.count
        let overruled = c.objections.filter { r.objections[$0.id] == false }.count
        if sustained + overruled > 0 { lines.append("Objections so far: \(sustained) sustained, \(overruled) overruled.") }
        for charge in c.charges {
            if let h = r.halftime[charge.id] { lines.append("Motion to dismiss count \(charge.count): \(h.label).") }
            if let v = r.verdicts[charge.id], stage.rawValue > CaseSession.Stage.verdict.rawValue || r.pleaAccepted == true {
                lines.append("Count \(charge.count) result: \(v == .guilty ? "guilty" : v == .lesser ? "guilty of \(charge.lesserLaw?.title ?? "the lesser offense")" : "not guilty").")
            }
        }
        if let testifies = r.defendantTestifies { lines.append(testifies ? "The defendant testified." : "The defendant did not testify.") }
        if stage == .sentencing, let unit = units.first {
            lines.append("Sentencing: \(unit.classLine).")
            if let cell = unit.felonyCell {
                lines.append("Chart ranges (minimum months): mitigated \(cell.mitigated.text), presumptive \(cell.presumptive.text)\(cell.aggravated.map { ", aggravated \($0.text)" } ?? ""). Dispositions allowed: \(cell.dispositionCode).")
            } else if let cell = unit.misdemeanorCell {
                lines.append("Authorized: 1–\(cell.maxDays) day\(cell.maxDays == 1 ? "" : "s"). Dispositions allowed: \(cell.dispositionCode).")
            }
            lines.append("Your recommendation: \(CounselDialogue.recommendation(c, side: side, units: units, rulings: r))")
        }
        if stage == .probation, let probation = d.probation {
            lines.append("The judge is deciding the probation violation in \(probation.docket).")
        }

        // A point held back until the judge opens the door
        let hidden = side == .prosecution ? bg.hiddenAggravator : bg.hiddenMitigator
        if stage == .sentencing, let hidden {
            lines.append("")
            lines.append(compact
                ? "ADDITIONAL FACTOR: \"\(hidden)\". Mention it only if the judge's question invites it; when you do, set raisesFactor to true. Otherwise false."
                : "ADDITIONAL FACTOR: You can document this \(side == .prosecution ? "aggravating" : "mitigating") factor: \"\(hidden)\". \(side == .prosecution ? "It was not included in the State's written notice." : "") Raise it only if the judge's question gives a natural opening (for example, asking about the defendant's background, conduct, anything else the court should know, or the factors). When you raise it, set raises_factor to true.")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: Violation hearings

    static func make(for h: ViolationHearing, side: Side, compact: Bool = false) -> String {
        let rawName = side == .prosecution ? h.prosecutor : h.defenseAttorney
        let name = rawName.components(separatedBy: ",").first ?? rawName
        let office = side == .prosecution ? "an Assistant District Attorney" : "an Assistant Public Defender representing the probationer"
        let style = CounselStyle.forName(name, side: side)
        var lines = [compact ? compactPersona(name: name, style: style, office: office)
                             : persona(name: name, side: side, style: style, office: office), "", "HEARING FILE"]
        lines.append("Probation violation hearing for \(h.personName), age \(h.personAge), in \(h.probation.docket) (\(h.probation.offense)).")
        lines.append("Suspended sentence: \(h.probation.suspendedSentence). Probation ends \(SentenceFormat.shortDate(h.probation.ends)). Prior CRVs: \(h.probation.crvCount ?? 0).")
        if let conditions = h.probation.conditions, !conditions.isEmpty { lines.append("Special conditions: \(conditions.joined(separator: " "))") }
        lines.append("Officer's report: \(h.officerReport)")
        lines.append("Alleged violations: " + h.violations.joined(separator: " "))
        lines.append("The probationer \((h.admits ?? true) ? "admits" : "denies") the violations.")
        lines.append("Revocation is authorized only for a new criminal offense, absconding, or after two prior CRVs (G.S. 15A-1344(a)). This case: \(ViolationHearings.canRevoke(h) ? "revocation is authorized" : "revocation is not authorized").")
        if side == .defense {
            lines.append("What you know: \(h.circumstances) Your position: \(h.defenseExplanation)")
        } else {
            lines.append("What you know: the probation officer, \(h.officerName), describes the probationer as \(h.willful ? "avoidant and noncompliant" : "trying, but struggling with circumstances").")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: The probationer, spoken to directly

    /// The person on probation, answering the judge in their own words at a violation hearing.
    static func probationer(_ h: ViolationHearing, profile: DefendantProfile?, judge: String, compact: Bool) -> String {
        let lawyer = h.defenseAttorney.components(separatedBy: ",").first ?? h.defenseAttorney
        let manner = h.willful
            ? "You know you messed up, and you're a little defensive about it, but you want to stay out of jail."
            : "You've been struggling and you're scared of going to jail; you want the judge to understand."
        let stance = (h.admits ?? true) ? "You admit what you did, though you may explain it." : "You deny it or play it down; you think the officer has it wrong."
        var lines = [
            "You are \(h.personName), \(h.personAge), on probation in \(h.probation.docket) for \(h.probation.offense.lowercased()). You are standing in Superior Court in Hollis County, North Carolina, at your probation violation hearing, and Judge \(judge) is speaking to you directly. Your lawyer, \(lawyer), is beside you.",
            "Speak as yourself, out loud, in the first person: plain everyday words, one to three sentences. You are not a lawyer; don't use legal terms or cite laws. Call the judge \"Judge\" or \"sir\" or \"ma'am\". \(manner) \(stance)",
            "Stick to the facts below. If the judge asks about something they don't cover, give a short, believable answer that doesn't contradict them, or say you don't remember. If a question could hurt you on a pending charge, you can say your lawyer told you not to talk about that. No stage directions. Never mention AI or a game. Set raises_factor to false.",
            "",
            "WHAT THE OFFICER REPORTED: " + h.violations.joined(separator: " "),
            "WHAT'S GOING ON IN YOUR LIFE (your lawyer's words; say it your own way): \(h.circumstances)"
        ]
        if let p = profile {
            let job = p.currentJob.map { "You work as \($0.title.lowercased()) at \($0.employer)." } ?? "You don't have a job right now."
            lines.append("YOUR LIFE: \(job) Family: \(p.family). Home: \(p.residence). School: \(p.education).")
        }
        let text = lines.joined(separator: "\n")
        return compact ? clip(text, 1_800) : text
    }
}
