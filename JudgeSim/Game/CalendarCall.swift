import Foundation

/// One short matter handled at an administrative calendar call.
struct CalendarMatter: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case quickPlea, failureToAppear, continuance, bondModification, capacity, pvAdmission, earlyTermination, searchWarrant, motionForRelief, firstAppearance, arraignment

        var label: String {
            switch self {
            case .quickPlea: return "Plea"
            case .failureToAppear: return "Failure to appear"
            case .continuance: return "Motion to continue"
            case .bondModification: return "Bond motion"
            case .capacity: return "Capacity motion"
            case .pvAdmission: return "Probation violation admission"
            case .earlyTermination: return "Motion to end probation early"
            case .searchWarrant: return "Search warrant application"
            case .motionForRelief: return "Motion for appropriate relief"
            case .firstAppearance: return "Bond hearing"
            case .arraignment: return "Arraignment"
            }
        }

        var icon: String {
            switch self {
            case .quickPlea: return "signature"
            case .failureToAppear: return "person.fill.xmark"
            case .continuance: return "calendar.badge.clock"
            case .bondModification: return "dollarsign.circle"
            case .capacity: return "brain.head.profile"
            case .pvAdmission: return "person.badge.clock.fill"
            case .earlyTermination: return "checkmark.seal.fill"
            case .searchWarrant: return "doc.text.magnifyingglass"
            case .motionForRelief: return "arrow.uturn.backward.circle.fill"
            case .firstAppearance: return "lock.open.fill"
            case .arraignment: return "person.wave.2.fill"
            }
        }
    }

    var id = UUID()
    var kind: Kind
    var personID: UUID
    var personName: String
    var personAge: Int
    var occupation: String
    var docket: String
    var summary: String
    var stateAsk: String
    var defenseAsk: String
    var options: [String]
    /// For pleas: the offense and its class.
    var lawID: String?
    var priors: [PriorConviction] = []
    /// Days or months that go with option 2 of a plea (an active term).
    var activeTerm: Int = 0
    var isFelony = false
    var lawNote: String?
    /// For early termination: whether the probationer still owes money under the judgment (optional for older saves).
    var owesMoney: Bool?
    /// The real case behind a plea, a motion to continue, a failure to appear, or a capacity motion. Whatever the
    /// court orders puts it on an actual calendar (optional for older saves).
    var pendingCase: CourtCase? = nil
    /// For a warrant application: the affidavit and what it asks to search.
    var warrant: WarrantApplication? = nil
    /// For a motion for appropriate relief: the motion and the case as it would be retried.
    var relief: ReliefMotion? = nil
    /// For a bond hearing: what each option sets and what the court can't see.
    var bond: BondFacts? = nil
    /// Options where the judge sets the dollar amount, and the range allowed.
    var amountOptions: [Int]? = nil
    var amountRange: ClosedRange<Int>? = nil
    var suggestedAmount: Int? = nil

    /// The option text with the amount the judge chose filled in.
    func optionText(_ choice: Int, amount: Int?) -> String {
        let option = options.indices.contains(choice) ? options[choice] : (options.first ?? "")
        guard amountOptions?.contains(choice) == true, let amount else { return option }
        return option.replacingOccurrences(of: "an amount you set", with: "$\(amount.formatted())")
    }

    /// The person's whole file is worth opening for these.
    var concernsProbationer: Bool { kind == .pvAdmission || kind == .earlyTermination }
}

/// Pretrial release under G.S. 15A-534: the least restrictive conditions that will reasonably assure the
/// defendant appears and the public is safe.
struct BondFacts: Codable, Hashable {
    /// Secured bond amounts for options 2 and 3.
    var moderate: Int
    var high: Int
    /// The most the defendant can post.
    var canPost: Int
    /// Hidden: how likely the defendant is to miss court if released, and to be arrested again.
    var flightRisk: Double
    var danger: Double
}

struct CalendarCall: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var matters: [CalendarMatter]
}

enum CalendarCalls {
    /// How hard the State bargains in front of this judge, from its memory of the judge's rulings (-0.3 to 0.3).
    static var prosecutorEdge = 0.0


    private static let pleaLaws = ["felonyLarceny", "possSchedII", "breakingVehicle", "larcenyMerchant", "feloniousBE",
                                   "uttering", "pwisd", "commonLawRobbery", "possStolen", "strangulation", "awdwisi", "burglary2"]

    /// Where the parties stand on a plea. The State doesn't hand out probation: with a record, a victim, or a chart
    /// that calls for prison, it fights for time, and the defense fights back.
    struct PleaPositions {
        var stateAsk: String
        var defenseAsk: String
        var options: [String]
    }

    static func pleaPositions(_ law: Law, priors: [PriorConviction], rangeText: String, notes: [String], name: String,
                              rng: inout SeededRNG) -> PleaPositions {
        let cls = law.ncClass ?? .misd1
        let last = name.components(separatedBy: " ").last ?? name
        let felonies = priors.filter { $0.ncClass.isFelony }.count
        let sameKind = priors.filter { $0.offense.lowercased().contains(law.title.lowercased().components(separatedBy: " ").last ?? "~") }.count
        let violent = [LawCategory.violent, .robbery].contains(law.category) || ["strangulation", "awdwisi", "commonLawRobbery", "burglary2"].contains(law.id)
        let chartActive = notes.contains { $0.contains("calls for an active sentence") }
        // How hard the State pushes: 0 joint probation, 1 split sentence, 2 active time.
        var push = 0.0
        if cls.isFelony { push += 0.25 }
        push += 0.2 * Double(min(3, felonies)) + 0.1 * Double(min(3, priors.count))
        if violent { push += 0.3 }
        if sameKind > 0 { push += 0.25 }
        if chartActive { push += 0.5 }
        // The DA's office remembers this judge: after lenient rulings it digs in, after tough ones it bargains more freely.
        // It leans, but never so far that every plea is the same.
        push += max(-0.15, min(0.15, prosecutorEdge))
        // Overloaded offices deal: a first offense with nobody hurt often goes for less.
        if priors.isEmpty && !violent { push -= 0.2 }
        let roll = Double.random(in: 0..<1, using: &rng)
        // 0 probation, 1 split sentence, 2 active time, 3 prayer for judgment, 4 no position.
        var stance = chartActive || roll < push - 0.45 ? 2 : (roll < push ? 1 : 0)
        if !chartActive {
            if !cls.isFelony && priors.isEmpty && !violent && rng.chance(0.3) { stance = 3 }
            else if stance != 2 && rng.chance(0.12) { stance = 4 }
        }
        let jailDays = cls.isFelony ? rng.pick([30, 45, 60, 90]) : rng.pick([10, 14, 30])

        var reasons: [String] = []
        if felonies >= 2 { reasons.append("\(last) has \(felonies) prior felonies. Probation has been tried.") }
        else if !priors.isEmpty { reasons.append(rng.pick(["This isn't \(last)'s first time in front of a judge.", "\(last) has been given breaks before."])) }
        if sameKind > 0 { reasons.append("It's the same kind of offense \(last) was convicted of before.") }
        if violent { reasons.append(rng.pick(["Somebody got hurt here.", "The victim wants \(last) to serve time, and the State agrees."])) }
        if chartActive { reasons.append("The sentencing chart calls for an active sentence at this record level.") }
        if reasons.isEmpty { reasons.append(rng.pick(["A plea doesn't erase what happened.", "The State made its offer already. This is it."])) }
        let why = reasons.prefix(2).joined(separator: " ")

        // The probation a joint recommendation names; the judgment entered on it carries the same terms.
        let months = rng.pick([12, 18, 24])
        let supervision = !cls.isFelony && priors.isEmpty && rng.chance(0.4) ? "unsupervised" : "supervised"
        let hours = rng.pick([24, 50, 75, 100])
        let condition = rng.pick(["", " and \(hours) hours of community service", " and a substance abuse assessment with any treatment recommended",
                                  " and an anger management course", " and a curfew for the first six months"])
        let stateAsk: String
        let defenseAsk: String
        switch stance {
        case 2:
            stateAsk = "The State will take the plea, but not a probation deal. We ask for \(rangeText) active. " + why
            defenseAsk = rng.pick(["Judge, \(last) took responsibility and saved the State a trial. Suspend the sentence; put \(last) on supervised probation with treatment.",
                                   "Prison won't fix this. \(last) has a job lined up and family support. We ask for a suspended sentence.",
                                   "We'd ask the court to consider a split sentence at most. \(last) has already sat in jail on this."])
        case 1:
            stateAsk = "The State asks for \(rangeText) suspended, with \(jailDays) days in the county jail up front as special probation, then 18 months supervised. " + why
            defenseAsk = rng.pick(["Straight probation is enough, Judge. Jail time costs \(last) the job that pays the restitution.",
                                   "My client has been clean since the arrest. Jail now undoes that. We ask for regular probation.",
                                   "Give \(last) a chance at probation without the jail time. If it doesn't work, the court will see us again."])
        case 3:
            stateAsk = rng.pick(["The State doesn't oppose a prayer for judgment continued on payment of costs. \(last) has no record, and this was a mistake, not a pattern.",
                                 "The State is satisfied with a PJC and costs. \(last) has done everything asked since the arrest.",
                                 "Given \(last)'s clean record, the State asks for a prayer for judgment continued. The conviction stays on the books; that's enough."])
            defenseAsk = rng.pick(["We join the State, Judge. My client has learned from this.", "We agree, Judge. My client paid the costs this morning."])
        case 4:
            stateAsk = rng.pick(["The State takes no position on the sentence, Judge. We'll leave it to the court.",
                                 "The plea is to the charge; the State makes no recommendation on punishment.",
                                 "The State defers to the court on sentencing. The victim has been told the court will decide."])
            defenseAsk = rng.pick(["We ask for a suspended sentence and probation, Judge. \(last) has work and a family that depends on that check.",
                                   "We'd ask for probation with treatment. \(last) started going to meetings the week after the arrest.",
                                   "A suspended sentence, Judge. \(last) has already lost a lot over this."])
        default:
            stateAsk = "The State and defense jointly recommend \(rangeText), suspended, \(months) months of \(supervision) probation\(condition), and costs. "
                + rng.pick(["\(last) has no real record and took responsibility early.", "The victim was consulted and agrees.",
                            "It's a fair resolution for a first offense of this kind.", "Our office has more cases than it can try; this one resolves fairly.",
                            "The evidence had a problem we'd rather not litigate, and this is a sound result.",
                            "\(last) gave a full statement and returned what was taken."])
            defenseAsk = rng.pick(["My client has a job and wants to keep it.", "My client has been sober since the arrest.", "This is about one bad night, Judge.",
                                   "My client is ready to start today.", "We agree with the State, Judge."])
        }
        let options = [
            stance == 0 ? "Accept the plea; suspended sentence, \(months) months \(supervision) probation\(condition) (joint recommendation)"
                : "Accept the plea; suspended sentence, 12 months supervised probation" + (stance == 3 ? "" : " (defense's ask)"),
            "Accept the plea; continue prayer for judgment on costs" + (stance == 3 ? " (State's ask)" : ""),
            "Accept the plea; impose \(rangeText) active" + (stance == 2 ? " (State's ask)" : ""),
            "Reject the plea; set the case for trial",
            "Accept the plea; split sentence: \(jailDays) days in jail, then probation" + (stance == 1 ? " (State's ask)" : "")
        ]
        return PleaPositions(stateAsk: stateAsk, defenseAsk: defenseAsk, options: options)
    }

    /// The days in jail a split sentence's option names.
    static func splitDays(_ option: String) -> Int {
        guard let range = option.range(of: #"\d+(?= days in jail)"#, options: .regularExpression) else { return 30 }
        return Int(option[range]) ?? 30
    }

    /// The sentence a plea would carry for this offense and record: the term for an active sentence, the range as
    /// the parties describe it, and anything the court should know about what the chart allows.
    static func pleaTerms(_ law: Law, priors: [PriorConviction]) -> (active: Int, rangeText: String, notes: [String]) {
        let cls = law.ncClass ?? .misd1
        let record = PriorRecord(priors: priors, onSupervision: false)
        var notes: [String] = []
        if cls.isFelony, let cell = StructuredSentencing.felonyCell(cls, level: record.felonyLevel) {
            if [.A, .B1, .B2, .C, .D, .E].contains(cls) { notes.append("PJC not allowed for this class.") }
            if !cell.dispositions.contains(.community) && !cell.dispositions.contains(.intermediate) {
                notes.append("At prior record level \(SentenceFormat.romanLevels[record.felonyLevel - 1]) the chart calls for an active sentence; suspending it departs from Structured Sentencing.")
            }
            if !cell.dispositions.contains(.active) {
                notes.append("At prior record level \(SentenceFormat.romanLevels[record.felonyLevel - 1]) the chart allows only community punishment; an active term departs from Structured Sentencing.")
            }
            return (cell.presumptive.low, "\(cell.presumptive.low)–\(StructuredSentencing.maximum(forMinimum: cell.presumptive.low, cls: cls)) months", notes)
        }
        let cell = StructuredSentencing.misdemeanorCell(cls, level: record.misdemeanorLevel)
        let active = max(1, (cell?.maxDays ?? 30) / 3)
        if let cell, !cell.dispositions.contains(.active) {
            notes.append("At this prior conviction level the chart allows only community punishment; an active term departs from it.")
        }
        return (active, "\(active) days", notes)
    }

    /// Ties a matter to the real case it is about: the defendant, the docket, the charge, and the record.
    static func bind(_ m: CalendarMatter, to c: CourtCase) -> CalendarMatter {
        var bound = m
        let oldName = m.personName
        let law = c.charges.first?.law
        func swap(_ text: String) -> String {
            var out = text.replacingOccurrences(of: oldName, with: c.defendant.name)
            if let oldLaw = m.lawID.map({ LawLibrary.law($0).title }), let law, oldLaw != law.title, !out.contains(law.title) {
                out = out.replacingOccurrences(of: oldLaw, with: law.title)
            }
            return out
        }
        bound.personID = c.defendant.personID
        bound.personName = c.defendant.name
        bound.personAge = c.defendant.age
        bound.occupation = c.defendant.occupation
        bound.docket = c.docket
        bound.pendingCase = c
        if m.kind == .quickPlea, let charged = law {
            // Most pleas are bargains: the State often reduces the charge, more so when the charge as filed would carry
            // mandatory prison time.
            var bargainRNG = SeededRNG(seed: c.seed ^ 0xBA6A)
            let lesser = c.charges.first?.lesserLaw
            let chargedForcesActive = pleaTerms(charged, priors: c.defendant.priors).notes.contains { $0.contains("calls for an active sentence") }
            let reduced = lesser.map { _ in bargainRNG.chance(chargedForcesActive ? 0.75 : 0.5) } ?? false
            let law = reduced ? lesser! : charged
            let cls = law.ncClass ?? .misd1
            let terms = pleaTerms(law, priors: c.defendant.priors)
            let priorCount = c.defendant.priors.count
            bound.lawID = law.id
            bound.priors = c.defendant.priors
            bound.isFelony = cls.isFelony
            bound.activeTerm = terms.active
            bound.lawNote = terms.notes.isEmpty ? nil : terms.notes.joined(separator: " ")
            bound.summary = "\(c.defendant.name), \(c.defendant.age), \(c.defendant.occupation.lowercasedPhrase.withIndefiniteArticle), offers to plead guilty to "
                + (reduced ? "the reduced charge of \(law.title) (\(cls.shortLabel)); the State will dismiss the \(charged.title) charge" : "\(law.title) (\(cls.shortLabel))")
                + ". Prior record: \(priorCount == 0 ? "none" : "\(priorCount) conviction\(priorCount == 1 ? "" : "s")")."
            var rng = SeededRNG(seed: c.seed ^ 0x9EA)
            let positions = pleaPositions(law, priors: c.defendant.priors, rangeText: terms.rangeText, notes: terms.notes,
                                          name: c.defendant.name, rng: &rng)
            bound.stateAsk = positions.stateAsk
            bound.defenseAsk = positions.defenseAsk
            bound.options = positions.options
        } else {
            bound.summary = m.summary.replacingOccurrences(of: oldName, with: c.defendant.name)
            if let law {
                // Only the placeholder charge as a whole ("on Felony Larceny." or "on Felony Larceny,"), never as the start of a
                // longer title, or "Assault with a Deadly Weapon" turns into a doubled name.
                for id in ["felonyLarceny", "pwisd", "awdw", "feloniousBE", "fleeing", "embezzlement"] {
                    let old = LawLibrary.law(id).title
                    for end in [".", ",", ";"] {
                        bound.summary = bound.summary.replacingOccurrences(of: " on \(old)\(end)", with: " on \(law.title)\(end)")
                    }
                }
            }
            bound.stateAsk = swap(m.stateAsk)
            bound.defenseAsk = swap(m.defenseAsk)
        }
        return bound
    }

    /// What the State asks for at a first appearance, scaled to the most serious charge, the felony record and
    /// missed court dates. A murder charge draws a request to hold without bond; a Class I gets an unsecured bond.
    static func bondScale(_ cls: NCClass?, violent: Bool, felonies: Int, ftas: Int,
                          rng: inout SeededRNG) -> (unsecured: Int, secured: Int, stateAsk: String) {
        let base = bondBase(cls)
        let factor = (1.0 + 0.25 * Double(min(felonies, 6)) + 0.5 * Double(min(ftas, 3))) * (violent ? 1.25 : 1.0)
        let jitter = Double.random(in: 0.85...1.2, using: &rng)
        let secured = roundBond(Double(base) * factor * jitter)
        let unsecured = roundBond(Double(min(base, 15_000)) / 2)
        let severity = cls?.severity ?? NCClass.H.severity
        let why = ftas > 0 ? "The defendant has missed court \(ftas == 1 ? "before" : "\(ftas) times")."
            : felonies >= 2 ? "The defendant has \(felonies) prior felony convictions."
            : violent ? "The charge is one of violence."
            : "The State has no objection to release, but the charge calls for security."
        let ask: String
        if cls == .A {
            ask = "The State asks that the defendant be held without bond. In the alternative, a $\(secured.formatted()) secured bond with electronic house arrest and no contact with the victim's family."
        } else if severity <= NCClass.E.severity && (violent || felonies > 0 || ftas > 0) {
            ask = "The State asks for a $\(secured.formatted()) secured bond with electronic house arrest. \(why)"
        } else if severity <= NCClass.G.severity || felonies >= 2 || ftas > 0 {
            ask = "The State asks for a $\(secured.formatted()) secured bond. \(why)"
        } else if rng.chance(0.5) {
            ask = "The State asks for a $\(secured.formatted()) secured bond."
        } else {
            ask = "The State would agree to an unsecured bond of $\(unsecured.formatted()) with the standard conditions."
        }
        return (unsecured, secured, ask)
    }

    /// The usual secured bond for a charge of this class, before record and missed court dates.
    static func bondBase(_ cls: NCClass?) -> Int {
        switch cls {
        case .A: return 1_000_000
        case .B1, .B2: return 500_000
        case .C: return 250_000
        case .D: return 150_000
        case .E: return 75_000
        case .F: return 50_000
        case .G: return 30_000
        case .H: return 15_000
        case .I: return 7_500
        case .misdA1: return 5_000
        case .misd1: return 2_500
        default: return 1_000
        }
    }

    /// Bonds come in round amounts.
    static func roundBond(_ x: Double) -> Int {
        let step = x >= 100_000 ? 25_000.0 : x >= 20_000 ? 5_000.0 : x >= 5_000 ? 1_000.0 : 500.0
        return max(500, Int((x / step).rounded()) * Int(step))
    }

    /// A newly charged defendant's first appearance in superior court: setting conditions of release.
    static func bondMatter(for c: CourtCase, rng: inout SeededRNG) -> CalendarMatter {
        let d = c.defendant
        let felonies = d.priors.filter { $0.ncClass.isFelony }.count
        let ftas = d.priors.filter { $0.offense.lowercased().contains("failure to appear") }.count + (rng.chance(0.25) ? 1 : 0)
        let violent = c.category == .violent || c.category == .robbery
        let employed = !d.occupation.lowercasedPhrase.contains("unemployed")
        let local = rng.chance(0.75)
        let flight = min(0.6, 0.06 + 0.12 * Double(ftas) + (local ? 0 : 0.12) + (employed ? 0 : 0.06) + 0.02 * Double(d.priors.count))
        let danger = min(0.5, 0.04 + (violent ? 0.08 : 0) + 0.05 * Double(felonies))
        let worst = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let scale = bondScale(worst, violent: violent, felonies: felonies, ftas: ftas, rng: &rng)
        let moderate = scale.unsecured
        let high = scale.secured
        let canPost = employed ? rng.pick([1_000, 2_500, 5_000, 10_000, 25_000]) : rng.pick([0, 500, 1_000, 2_500])
        let law = c.charges.first?.law
        var record = d.priors.isEmpty ? "No prior convictions" : "\(d.priors.count) prior conviction\(d.priors.count == 1 ? "" : "s") (\(felonies) felon\(felonies == 1 ? "y" : "ies"))"
        if ftas > 0 { record += "; \(ftas) prior failure\(ftas == 1 ? "" : "s") to appear" }
        let ties = [employed ? "works as \(d.occupation.lowercasedPhrase.withIndefiniteArticle)" : "is out of work",
                    local ? "has lived in the county most of \(NameBank.gender(of: d.name) == .female ? "her" : "his") life" : "moved here from out of state last year"]
        return CalendarMatter(kind: .firstAppearance, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation,
                              docket: c.docket,
                              summary: "\(d.name), \(d.age), arrested this week and charged with \(law?.title.lowercased() ?? "a felony"), is before the court on conditions of release (G.S. 15A-534). \(record). \(d.lastName) \(ties.joined(separator: " and ")). The magistrate set no bond pending this hearing.",
                              stateAsk: scale.stateAsk,
                              defenseAsk: canPost == 0
                                ? "My client has no money. Any secured bond is a detention order. We ask for a written promise to appear."
                                : "My client can post about $\(canPost.formatted()). We ask for an unsecured bond so \(d.lastName) can keep working and help with the defense.",
                              options: ["Written promise to appear",
                                        "Unsecured bond of $\(moderate.formatted())",
                                        "Secured bond of an amount you set",
                                        "Secured bond of an amount you set, with electronic house arrest"],
                              pendingCase: c, bond: BondFacts(moderate: moderate, high: high, canPost: canPost, flightRisk: flight, danger: danger),
                              amountOptions: [2, 3], amountRange: 500...max(500_000, high * 2), suggestedAmount: high)
    }

    /// A jailed defendant asks to have the bond lowered (G.S. 15A-538). The judge sets the new amount.
    static func bondReductionMatter(for c: CourtCase, rng: inout SeededRNG) -> CalendarMatter {
        let d = c.defendant
        let held = c.background.map { max($0.custodyDays, 1) } ?? rng.int(40...210)
        let worstClass = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let priorFelonies = d.priors.filter { $0.ncClass.isFelony }.count
        let current = bondScale(worstClass, violent: c.category == .violent || c.category == .robbery,
                                felonies: priorFelonies, ftas: 0, rng: &rng).secured
        // The file shows the bond the defendant is actually held on.
        var jailed = c
        if var bg = jailed.background {
            bg.custodyDays = held
            bg.onRelease = false
            bg.bondStatus = "Held on a $\(current.formatted()) secured bond; in custody for \(held) days."
            jailed.background = bg
        }
        let employed = !d.occupation.lowercasedPhrase.contains("unemployed")
        let canPost = employed ? rng.pick([1_000, 2_500, 5_000, 10_000, 15_000]) : rng.pick([0, 500, 1_000, 2_500])
        let ftas = d.priors.filter { $0.offense.lowercased().contains("failure to appear") }.count + (rng.chance(0.3) ? 1 : 0)
        let felonies = d.priors.filter { $0.ncClass.isFelony }.count
        let violent = c.category == .violent || c.category == .robbery
        let flight = min(0.6, 0.06 + 0.12 * Double(ftas) + (employed ? 0 : 0.06) + 0.02 * Double(d.priors.count))
        let danger = min(0.5, 0.04 + (violent ? 0.08 : 0) + 0.05 * Double(felonies))
        let law = c.charges.first?.law.title.lowercased() ?? "the charge"
        return CalendarMatter(kind: .bondModification, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation,
                              docket: c.docket,
                              summary: "\(d.name), held \(held) days on a $\(current.formatted()) secured bond on \(law), asks the court to reduce it (G.S. 15A-538). \(d.priors.isEmpty ? "No prior convictions" : "\(d.priors.count) prior conviction\(d.priors.count == 1 ? "" : "s")")\(ftas > 0 ? ", \(ftas) prior failure\(ftas == 1 ? "" : "s") to appear" : ""). \(employed ? "\(d.lastName)'s employer will hold the job for two more weeks." : "\(d.lastName) was out of work before the arrest.")",
                              stateAsk: ftas > 0 || violent
                                ? "The State opposes any reduction. \(ftas > 0 ? "The defendant has missed court before." : "The charge is violent and the evidence is strong.")"
                                : "The State would agree to a modest reduction with electronic monitoring.",
                              defenseAsk: "My client can post about $\(canPost.formatted()). Anything higher is a detention order by another name. There's a job and a family waiting.",
                              options: ["Reduce the bond to an amount you set", "Leave the bond at $\(current.formatted())",
                                        "Reduce the bond to an amount you set, with electronic house arrest"],
                              pendingCase: jailed,
                              bond: BondFacts(moderate: current, high: current, canPost: canPost, flightRisk: flight, danger: danger),
                              amountOptions: [0, 2], amountRange: 500...max(1_000, current - 500), suggestedAmount: max(500, current / 2))
    }

    /// Arraignment in superior court (G.S. 15A-941): the plea is entered and the court sets the trial date.
    static func arraignmentMatter(for c: CourtCase) -> CalendarMatter {
        let d = c.defendant
        let jailed = c.background?.isJailed ?? false
        let counts = c.charges.count
        return CalendarMatter(kind: .arraignment, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation,
                              docket: c.docket,
                              summary: "\(d.name) is arraigned on \(counts) count\(counts == 1 ? "" : "s"), led by \(c.charges.first?.law.title.lowercased() ?? "the indictment"), and pleads not guilty. \(jailed ? "\(d.lastName) is in custody." : "\(d.lastName) is out on bond.") Set the trial date.",
                              stateAsk: "The State will be ready in about five weeks; the lab work is back.",
                              defenseAsk: counts > 2 ? "With this many counts we need time for discovery. Ten weeks." : "We'd like five weeks to review discovery.",
                              options: ["Set the trial date now", "Put it on the waiting list; set the date later"],
                              pendingCase: c)
    }

    /// A convicted defendant asks the trial judge for a new trial on newly discovered evidence.
    static func reliefMatter(_ m: ReliefMotion, judgeLast: String) -> CalendarMatter {
        let hearing = m.hearingHeld == true
        let heardText = hearing
            ? (m.meritorious
                ? " At the evidentiary hearing last week, the new witness testified in detail and held up on cross-examination; the documents check out."
                : " At the evidentiary hearing last week, the witness contradicted the affidavit twice and admitted a relative of the defendant drafted it.")
            : ""
        var options = ["Grant: vacate the conviction and order a new trial", "Deny the motion"]
        if !hearing { options.insert("Hold an evidentiary hearing next week before ruling", at: 1) }
        return CalendarMatter(kind: .motionForRelief, personID: m.personID, personName: m.personName, personAge: m.retrial.defendant.age,
                              occupation: m.retrial.defendant.occupation, docket: m.docket,
                              summary: "\(m.personName), whom you convicted of \(m.offense.lowercased()), moves for a new trial on newly discovered evidence (G.S. 15A-1415(c)): \(m.newEvidence)" + heardText,
                              stateAsk: "The State opposes. The evidence could have been found before trial with due diligence, and it wouldn't change the result.",
                              defenseAsk: "This wasn't available at trial, and it goes to the heart of the case. Justice requires a new trial.",
                              options: options, pendingCase: m.retrial, relief: m)
    }

    /// An officer brings a search warrant application to the judge between matters.
    static func warrantMatter(_ w: WarrantApplication, for c: CourtCase) -> CalendarMatter {
        CalendarMatter(kind: .searchWarrant, personID: c.defendant.personID, personName: c.defendant.name, personAge: c.defendant.age,
                       occupation: c.defendant.occupation, docket: "Warrant application",
                       summary: "\(w.affiant) of the \(w.agency) asks you to sign a search warrant. To be searched: \(w.place). Read the affidavit before you rule.",
                       stateAsk: "The officer swears to the affidavit before you (G.S. 15A-244).",
                       defenseAsk: "No one appears for the person to be searched; a warrant is issued ex parte.",
                       // Striking is only an option when the list of items has catch-all language to strike.
                       options: w.flaw == .overbroad
                        ? ["Sign the warrant as written", "Strike the catch-all language and sign the rest",
                           "Deny: the affidavit doesn't show probable cause"]
                        : ["Sign the warrant as written", "Deny: the affidavit doesn't show probable cause"],
                       pendingCase: c, warrant: w)
    }

    static func make(county: County, date: Date, docketSequence: Int, people: [PersonRecord], excluding: Set<UUID> = [],
                     seed: UInt64) -> CalendarCall {
        var rng = SeededRNG(seed: seed)
        var used = Set(people.map(\.name))
        let year = Calendar.current.component(.year, from: date) % 100
        var sequence = docketSequence
        func docket(_ felony: Bool) -> String {
            sequence += rng.int(3...40)
            return String(format: "%02d %@ %06d", year, felony ? "CRS" : "CR", sequence)
        }

        var matters: [CalendarMatter] = []
        let pleaCount = rng.int(1...2)
        for _ in 0..<pleaCount {
            let law = LawLibrary.law(rng.pick(pleaLaws))
            let cls = law.ncClass ?? .misd1
            let name = NameBank.person(using: &rng, excluding: &used)
            let age = rng.int(19...58)
            let priorCount = rng.chance(0.5) ? 0 : rng.int(1...3)
            var priors: [PriorConviction] = []
            for _ in 0..<priorCount {
                let p = rng.pick(GenericPools.priorSeeds)
                priors.append(PriorConviction(offense: p.offense, ncClass: p.ncClass,
                                              year: Calendar.current.component(.year, from: date) - rng.int(1...max(1, min(15, age - 18))),
                                              county: rng.chance(0.6) ? county.name : rng.pick(GenericPools.otherCounties),
                                              sentence: rng.pick(p.sentences)))
            }
            // The same sentencing math as a plea bound to a real case.
            let (active, rangeText, notes) = pleaTerms(law, priors: priors)
            let positions = pleaPositions(law, priors: priors, rangeText: rangeText, notes: notes, name: name, rng: &rng)
            let occupation = rng.pick(NameBank.occupations)
            matters.append(CalendarMatter(
                kind: .quickPlea, personID: UUID(), personName: name, personAge: age, occupation: occupation,
                docket: docket(cls.isFelony),
                summary: "\(name), \(age), \(occupation.lowercasedPhrase.withIndefiniteArticle), offers to plead guilty to \(law.title) (\(cls.shortLabel)). Prior record: \(priorCount == 0 ? "none" : "\(priorCount) conviction\(priorCount == 1 ? "" : "s")").",
                stateAsk: positions.stateAsk,
                defenseAsk: positions.defenseAsk,
                options: positions.options,
                lawID: law.id, priors: priors, activeTerm: active, isFelony: cls.isFelony,
                lawNote: notes.isEmpty ? nil : notes.joined(separator: " ")))
        }

        let others: [CalendarMatter.Kind] = rng.pick([.failureToAppear, .continuance, .bondModification, .capacity], count: 2)
        for kind in others {
            let name = NameBank.person(using: &rng, excluding: &used)
            let age = rng.int(19...60)
            let law = LawLibrary.law(rng.pick(["felonyLarceny", "pwisd", "awdw", "feloniousBE", "fleeing", "embezzlement"]))
            let d = docket(true)
            let occupation = rng.pick(NameBank.occupations)
            switch kind {
            case .failureToAppear:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: rng.pick([
                        "\(name) was ordered to appear at this morning's calendar call on \(law.title) and did not answer when called three times in the hallway.",
                        "\(name), charged with \(law.title), did not answer when the case was called at the calendar call. The bondsman is in the courtroom.",
                        "\(name) did not appear at the calendar call on \(law.title). It is \(rng.pick(["the second", "the third", "the first"])) missed court date in this case.",
                        "The clerk called \(name) on \(law.title) twice. Defense counsel is present; the defendant is not."]),
                    stateAsk: rng.pick([
                        "The State asks for an order for arrest and forfeiture of the \(rng.pick(["$5,000", "$10,000", "$20,000"])) bond.",
                        "The State asks for an order for arrest with no bond. The defendant was told in open court to be here today.",
                        "The State asks for an order for arrest and that any new bond be doubled. This defendant has missed court before.",
                        "The defendant signed the notice to appear for today. We ask for an order for arrest and forfeiture."]),
                    defenseAsk: rng.pick([
                        "I spoke with my client last week. They knew the date. I can't explain it.",
                        "My client texted me this morning that the car broke down on Highway 17. I've asked for a photo of the tow receipt.",
                        "My client works second shift and may have confused the date. I'd ask for the afternoon to reach them.",
                        "I haven't been able to reach my client in a month. The phone is disconnected. I have nothing to offer the court.",
                        "My client's ride fell through this morning, and the first bus from Bayard doesn't get in until eleven. I'd ask for a new date.",
                        "My client is in custody in another county on an unrelated matter. I just learned it from the jail roster.",
                        "My client's mother called my office this morning. There may have been a hospital visit. I'd ask for a day to find out.",
                        "Judge, my client told me last week they couldn't afford to miss another day of work. I warned them. I'll leave it to the court."]),
                    options: ["Issue an order for arrest and forfeit the bond", "Hold the matter open until the afternoon session",
                              "Continue the case three weeks and send a new notice"]))
            case .continuance:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: "The defense moves to continue the trial of \(name) on \(law.title). It would be the \(rng.pick(["third", "fourth", "second"])) continuance.",
                    stateAsk: rng.pick(["The State objects. The victim has taken off work three times for this case.",
                                        "The State doesn't object, Judge.",
                                        "The State objects strongly. Our key witness is moving out of state next month.",
                                        "The State objects. This case is over a year old, and the defense has had the discovery for months.",
                                        "The State takes no position, but asks that this be the last continuance."]),
                    defenseAsk: rng.pick(["We just received the lab report Friday. I can't effectively cross-examine the analyst without our own expert.",
                                          "I was appointed two weeks ago. Prior counsel withdrew. I haven't met my client in person yet.",
                                          "A defense witness is deployed with the National Guard until next month.",
                                          "The State turned over body camera video last week, nearly four hours of it. I need time to review it.",
                                          "I'm in a murder trial in another county that's running long.",
                                          "My client was just admitted to an inpatient treatment program and can't leave for 28 days."]),
                    options: ["Grant the continuance; reset for trial in four weeks", "Deny; the case is ready for trial and you set the date"]))
            case .bondModification:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: "\(name), held \(rng.int(40...210)) days on a \(rng.pick(["$25,000", "$50,000", "$75,000"])) secured bond on \(law.title), asks the court to reduce it (G.S. 15A-534).",
                    stateAsk: rng.pick(["The State opposes. The defendant has two prior failures to appear.",
                                        "The State would agree to a modest reduction with electronic monitoring."]),
                    defenseAsk: "My client can't make this bond. That's not a bond, it's a detention order. A job is waiting.",
                    options: ["Reduce to an unsecured bond with electronic monitoring", "Leave the bond as set", "Reduce to a $5,000 secured bond"]))
            case .capacity:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: "Defense counsel questions whether \(name) has the capacity to proceed to trial on \(law.title) (G.S. 15A-1001).",
                    stateAsk: "The State takes no position but notes the defendant seemed oriented at the bond hearing.",
                    defenseAsk: "My client believes I work for the District Attorney and won't discuss the case. I can't assist in a defense under these conditions.",
                    options: ["Order a forensic evaluation at Central Regional Hospital (about ten weeks)",
                              "Order a local screening evaluation (about three weeks)", "Find the defendant capable; the case is tried this week"]))
            default:
                break
            }
        }

        // A steady probationer asks to end probation early: only once at least half the term is served.
        let probationers = people.filter { $0.status == .probation && $0.probation != nil && !excluding.contains($0.id) }
        let steady = probationers.filter { person in
            guard let term = person.probation, (term.violationRisk ?? 0.2) < 0.25,
                  let start = ViolationHearings.probationStart(person, term) else { return false }
            let halfway = start.addingTimeInterval(term.ends.timeIntervalSince(start) / 2)
            return halfway <= date
        }
        if let person = steady.isEmpty ? nil : rng.pick(steady), let term = person.probation, rng.chance(0.5) {
            let whose = term.imposedInThisCourt ? "You placed \(person.lastName) on probation." : (term.origin ?? "Sentenced in another court.")
            let owes = (term.monthlyObligation ?? 0) > 0
            let compliance = (term.supervised ?? true)
                ? "The probation officer reports every visit kept, clean drug screens, and steady work."
                : "The clerk's file shows no new charges and steady work" + (owes ? ", with payments current." : ".")
            matters.append(CalendarMatter(
                kind: .earlyTermination, personID: person.id, personName: person.name, personAge: person.age(on: date),
                occupation: person.occupation, docket: term.docket,
                summary: "\(person.name) asks the court to end probation in \(term.docket) (\(term.offense)) early. \(whose) \(compliance)",
                stateAsk: owes
                    ? rng.pick(["The State takes no position.",
                                "The State opposes. Money owed under the judgment still isn't paid in full.",
                                "The State doesn't object, provided all money owed is paid."])
                    : rng.pick(["The State takes no position.", "The State doesn't object."]),
                defenseAsk: rng.pick(["My client has done everything asked. A new job requires travel that supervision makes impossible.",
                                      "Half the term and more is served without a single violation. The goal of probation has been met.",
                                      "My client wants to move closer to family in another county and start over."]),
                options: ["Grant: probation ends successfully (G.S. 15A-1342(b))",
                          owes ? "Grant once all money owed is paid" : "Grant; nothing is owed, so probation ends today",
                          "Deny: probation continues as ordered"],
                owesMoney: owes))
        }
        if let person = probationers.isEmpty ? nil : rng.pick(probationers), let term = person.probation, rng.chance(0.6),
           !matters.contains(where: { $0.personID == person.id }) {
            let supervised = term.supervised ?? true
            let crv = ViolationHearings.crvDays(term)
            matters.append(CalendarMatter(
                kind: .pvAdmission, personID: person.id, personName: person.name, personAge: person.age(on: date),
                occupation: person.occupation, docket: term.docket + " (PV)",
                summary: "\(person.name) admits " + pvAdmissionConduct(supervised: supervised) + " while on probation in \(term.docket).",
                stateAsk: "The State asks for a three-day quick dip.",
                defenseAsk: "My client admits it and is back on track. We ask the court to continue probation.",
                options: ["Continue probation on the same terms", "Modify: add substance abuse treatment", "Order a three-day quick dip",
                          crv > 0 ? "Order a \(crv)-day CRV" : "Order a CRV (no suspended time remains)"]))
        }
        return CalendarCall(date: date, matters: matters)
    }

    /// What a probationer admits at the calendar call. Unsupervised probation has no office visits or drug screens.
    static func pvAdmissionConduct(supervised: Bool) -> String {
        supervised ? "missing two office visits and one drug screen" : "falling behind on court-ordered payments and not finishing the community service ordered"
    }

    struct Result {
        var lines: [String]
        var newPeople: [PersonRecord]
        var updates: [(UUID, (inout PersonRecord) -> Void)]
        var pending: [PendingEvent]
        /// For the career statistics: active and suspended sentences entered on pleas, and probation ended successfully today.
        var activeSentences = 0
        var suspendedSentences = 0
        var probationCompleted = 0
    }

    static func resolve(_ call: CalendarCall, choices: [UUID: Int], amounts: [UUID: Int] = [:], judgeName: String, county: County) -> Result {
        var rng = SeededRNG(seed: UInt64(truncatingIfNeeded: call.date.timeIntervalSince1970.bitPattern) ^ UInt64(call.matters.count))
        var lines: [String] = []
        var newPeople: [PersonRecord] = []
        var updates: [(UUID, (inout PersonRecord) -> Void)] = []
        var pending: [PendingEvent] = []
        var activeSentences = 0, suspendedSentences = 0, probationCompleted = 0
        let date = call.date
        let year = Calendar.current.component(.year, from: date)
        let judgeLast = judgeName.components(separatedBy: " ").last ?? judgeName

        for m in call.matters {
            let choice = choices[m.id] ?? 0
            let option = m.optionText(choice, amount: amounts[m.id] ?? m.suggestedAmount)
            lines.append("\(m.docket) · \(m.personName) · \(m.kind.label): \(option).")
            switch m.kind {
            case .quickPlea:
                guard choice != 3, let lawID = m.lawID else { continue }
                let law = LawLibrary.law(lawID)
                let cls = law.ncClass ?? .misd1
                let birthYear = year - m.personAge
                var person = PersonRecord(id: m.personID, name: m.personName, birthYear: birthYear, occupation: m.occupation,
                                          background: BackgroundLines.pick(age: m.personAge, occupation: m.occupation, used: [],
                                                                           towns: county.towns, rng: &rng),
                                          priors: m.priors,
                                          propensity: m.priors.isEmpty ? 0.18 : 0.3)
                let termText = m.isFelony ? "\(m.activeTerm)–\(StructuredSentencing.maximum(forMinimum: m.activeTerm, cls: cls)) months" : "\(m.activeTerm) days"
                let sentence: String
                var choice = choice
                if choice == 1 && [.A, .B1, .B2, .C, .D, .E].contains(cls) {
                    // A PJC isn't available for a Class A through E felony; the joint recommendation is entered instead.
                    lines.append("A prayer for judgment continued isn't available for a \(cls.shortLabel) felony; the joint recommendation was entered instead.")
                    choice = 0
                }
                // Days already spent in jail on this charge count against an active term (G.S. 15-196.1).
                let credit = m.pendingCase?.background?.custodyDays ?? 0
                switch choice {
                case 0:
                    // The terms named in the option the judge chose: length, supervision, and any special condition.
                    let text = m.options.first ?? ""
                    let months = text.range(of: #"\d+(?= months)"#, options: .regularExpression).flatMap { Int(text[$0]) } ?? 12
                    let supervised = !text.contains("unsupervised")
                    var conditions: [String] = []
                    if let r = text.range(of: #"\d+(?= hours of community service)"#, options: .regularExpression) {
                        conditions.append("Complete \(text[r]) hours of community service.")
                    }
                    if text.contains("substance abuse") { conditions.append("Obtain a substance abuse assessment and complete recommended treatment.") }
                    if text.contains("anger management") { conditions.append("Complete an anger management course.") }
                    if text.contains("curfew") { conditions.append("Observe a curfew for the first six months.") }
                    sentence = "\(termText) suspended, \(months) months \(supervised ? "supervised" : "unsupervised") probation"
                        + (conditions.isEmpty ? "" : "; " + conditions.map { $0.dropLast().lowercased() }.joined(separator: "; "))
                    person.status = .probation
                    person.probation = ProbationTerm(docket: m.docket, offense: law.title, isFelony: m.isFelony,
                                                     suspendedSentence: termText,
                                                     activeMonths: m.isFelony ? m.activeTerm : max(1, m.activeTerm / 30),
                                                     ends: Calendar.current.date(byAdding: .month, value: months, to: date) ?? date,
                                                     imposedInThisCourt: true, supervised: supervised, conditions: conditions,
                                                     monthlyObligation: 60, violationRisk: rng.chance(0.5) ? 0.2 : 0.12,
                                                     crvCount: 0, treatmentNeed: TreatmentNeed.none)
                    person.probation?.activeDays = m.isFelony ? nil : m.activeTerm
                    person.probation?.offenseClass = cls
                    person.probation?.starts = date
                case 1:
                    sentence = "Prayer for judgment continued"
                case 4:
                    // Special probation (G.S. 15A-1351): jail first, then supervised probation on the suspended term.
                    let days = splitDays(m.options.indices.contains(4) ? m.options[4] : "")
                    sentence = "\(termText) suspended; special probation with \(days) days active, then 18 months supervised probation"
                    person.probation = ProbationTerm(docket: m.docket, offense: law.title, isFelony: m.isFelony,
                                                     suspendedSentence: termText,
                                                     activeMonths: m.isFelony ? m.activeTerm : max(1, m.activeTerm / 30),
                                                     ends: Calendar.current.date(byAdding: .month, value: 18, to: date) ?? date,
                                                     imposedInThisCourt: true, supervised: true, conditions: ["Special probation: \(days) days in the county jail."],
                                                     monthlyObligation: 60, violationRisk: rng.chance(0.5) ? 0.18 : 0.1,
                                                     crvCount: 0, treatmentNeed: TreatmentNeed.none)
                    person.probation?.activeDays = m.isFelony ? nil : m.activeTerm
                    person.probation?.offenseClass = cls
                    person.probation?.starts = date
                    let out = Calendar.current.date(byAdding: .day, value: max(0, days - credit), to: date) ?? date
                    if out > date {
                        person.status = .incarcerated
                        person.releaseDate = out
                        person.releaseNote = "Special probation: \(days) days in the county jail, ordered on a plea at the calendar call. Probation follows release."
                    } else {
                        person.status = .probation
                    }
                default:
                    sentence = "\(termText) active" + (credit > 0 ? ", with credit for \(credit) days served" : "")
                    let full = Calendar.current.date(byAdding: m.isFelony ? .month : .day, value: m.activeTerm, to: date) ?? date
                    let release = Calendar.current.date(byAdding: .day, value: -credit, to: full) ?? full
                    if release <= date {
                        // The credit covers the whole term: released from the courtroom.
                        person.status = .free
                        person.releaseNote = "Pleaded guilty at the calendar call; \(termText) active, fully served by \(credit) days of pretrial credit."
                    } else {
                        person.status = .incarcerated
                        person.releaseDate = release
                        person.releaseNote = "Committed on a guilty plea at the calendar call: \(termText) active" + (credit > 0 ? ", less \(credit) days of credit." : ".")
                    }
                    if m.isFelony {
                        // Felony actives carry post-release supervision after release (G.S. 15A-1368.2).
                        let start = person.releaseDate ?? date
                        let months = StructuredSentencing.postReleaseMonths(for: cls)
                        let prs = PostReleaseTerm(docket: m.docket, offense: law.title,
                                                  ends: Calendar.current.date(byAdding: .month, value: months, to: start) ?? start,
                                                  supervisionMonths: months, remainingMonths: months)
                        if person.status == .incarcerated { person.pendingPostRelease = prs } else { person.postRelease = prs }
                    }
                }
                if choice == 0 || choice == 4 { suspendedSentences += 1 } else if choice != 1 { activeSentences += 1 }
                person.priors.append(PriorConviction(offense: law.title, ncClass: cls, year: year, county: county.name,
                                                     sentence: sentence, fromThisCourt: true, docket: m.docket,
                                                     sessionKey: Judgment.sessionKey(county: county, date: date)))
                person.appearances.append(PersonRecord.Appearance(docket: m.docket, date: date, charges: law.title,
                                                                  outcome: "Guilty plea at calendar call. \(sentence)"))
                newPeople.append(person)
            case .bondModification where m.pendingCase == nil && choice == 0 && rng.chance(0.2):
                pending.append(PendingEvent(due: Calendar.current.date(byAdding: .day, value: rng.int(20...90), to: date) ?? date,
                                            news: NewsItem(date: date, kind: .arrest,
                                                           headline: "Defendant released on reduced bond charged again",
                                                           body: "\(m.personName), whose bond Judge \(judgeLast) reduced at a calendar call, was arrested again this week, according to the Sheriff's Office.",
                                                           docket: m.docket)))
            case .failureToAppear where choice == 0:
                lines.append("Order for arrest issued; bond forfeiture entered (G.S. 15A-544.3).")
            case .earlyTermination:
                guard choice != 2 else { continue }
                if choice == 1 && m.owesMoney == true {
                    // Money is still owed: probation ends only once it is paid, within the next three months.
                    updates.append((m.personID, { person in
                        guard var term = person.probation else { return }
                        term.conditions = (term.conditions ?? []) + ["Probation terminates upon payment in full of all money owed."]
                        term.ends = min(term.ends, Calendar.current.date(byAdding: .month, value: 3, to: date) ?? term.ends)
                        person.probation = term
                        person.appearances.append(PersonRecord.Appearance(docket: term.docket, date: date, charges: "Motion to terminate probation early",
                                                                          outcome: "Granted on condition: probation ends once all money owed is paid"))
                    }))
                    continue
                }
                probationCompleted += 1
                updates.append((m.personID, { person in
                    guard let term = person.probation else { return }
                    person.probation = nil
                    person.status = .free
                    person.propensity = max(0.03, person.propensity * 0.85)
                    person.appearances.append(PersonRecord.Appearance(docket: term.docket, date: date, charges: "Motion to terminate probation early",
                                                                      outcome: choice == 1 ? "Granted; nothing is owed: probation ended early"
                                                                                           : "Granted: probation ended early"))
                }))
            case .pvAdmission:
                updates.append((m.personID, { person in
                    guard var term = person.probation else { return }
                    switch choice {
                    case 1:
                        term.conditions = (term.conditions ?? []) + ["Obtain a substance abuse assessment and complete recommended treatment."]
                        term.violationRisk = max(0.05, (term.violationRisk ?? 0.2) - 0.06)
                    case 2:
                        // A quick dip: three days in the county jail, then back on probation (G.S. 15A-1343(a1)(3)).
                        term.violationRisk = max(0.05, (term.violationRisk ?? 0.2) - 0.03)
                        person.status = .incarcerated
                        person.releaseDate = Calendar.current.date(byAdding: .day, value: 3, to: date)
                        person.releaseNote = "Quick dip: three days in the county jail, ordered at the calendar call. Probation resumes on release."
                    case 3:
                        // Credit for earlier CRVs: a misdemeanor CRV never exceeds the suspended time left.
                        let days = ViolationHearings.crvDays(term)
                        guard days > 0 else { break }
                        term.crvCount = (term.crvCount ?? 0) + 1
                        term.crvDaysServed = term.crvCreditDays + days
                        person.status = .incarcerated
                        person.releaseDate = Calendar.current.date(byAdding: .day, value: days, to: date)
                        person.releaseNote = "Confinement in response to violation: \(days) days, ordered at the calendar call. Probation resumes on release."
                    default:
                        break
                    }
                    person.probation = term
                    // The admission is a violation found by the court.
                    person.violations = (person.violations ?? []) + [SupervisionViolation(
                        docket: term.docket, date: date, kind: "Probation violation",
                        conduct: "Admitted the violation at the calendar call",
                        result: option.trimmingTrailingPeriods)]
                    person.appearances.append(PersonRecord.Appearance(docket: m.docket, date: date, charges: "Probation violation (admitted)",
                                                                      outcome: "Calendar call: \(option)"))
                }))
            default:
                break
            }
        }
        return Result(lines: lines, newPeople: newPeople, updates: updates, pending: pending,
                      activeSentences: activeSentences, suspendedSentences: suspendedSentences, probationCompleted: probationCompleted)
    }
}

extension CalendarMatter {
    /// Fields added since a calendar call was first saved decode as their defaults, so an older save still loads.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        kind = try c.decode(Kind.self, forKey: .kind)
        personID = try c.decodeIfPresent(UUID.self, forKey: .personID) ?? UUID()
        personName = try c.decodeIfPresent(String.self, forKey: .personName) ?? ""
        personAge = try c.decodeIfPresent(Int.self, forKey: .personAge) ?? 30
        occupation = try c.decodeIfPresent(String.self, forKey: .occupation) ?? ""
        docket = try c.decodeIfPresent(String.self, forKey: .docket) ?? ""
        summary = try c.decodeIfPresent(String.self, forKey: .summary) ?? ""
        stateAsk = try c.decodeIfPresent(String.self, forKey: .stateAsk) ?? ""
        defenseAsk = try c.decodeIfPresent(String.self, forKey: .defenseAsk) ?? ""
        options = try c.decodeIfPresent([String].self, forKey: .options) ?? []
        lawID = try c.decodeIfPresent(String.self, forKey: .lawID)
        priors = try c.decodeIfPresent([PriorConviction].self, forKey: .priors) ?? []
        activeTerm = try c.decodeIfPresent(Int.self, forKey: .activeTerm) ?? 0
        isFelony = try c.decodeIfPresent(Bool.self, forKey: .isFelony) ?? false
        lawNote = try c.decodeIfPresent(String.self, forKey: .lawNote)
        owesMoney = try c.decodeIfPresent(Bool.self, forKey: .owesMoney)
        pendingCase = try c.decodeIfPresent(CourtCase.self, forKey: .pendingCase)
        warrant = try c.decodeIfPresent(WarrantApplication.self, forKey: .warrant)
        relief = try c.decodeIfPresent(ReliefMotion.self, forKey: .relief)
        bond = try c.decodeIfPresent(BondFacts.self, forKey: .bond)
        amountOptions = try c.decodeIfPresent([Int].self, forKey: .amountOptions)
        amountRange = try c.decodeIfPresent(ClosedRange<Int>.self, forKey: .amountRange)
        suggestedAmount = try c.decodeIfPresent(Int.self, forKey: .suggestedAmount)
    }
}
