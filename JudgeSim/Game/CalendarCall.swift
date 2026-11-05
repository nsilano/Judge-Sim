import Foundation

/// One short matter handled at an administrative calendar call.
struct CalendarMatter: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case quickPlea, failureToAppear, continuance, bondModification, capacity, pvAdmission, earlyTermination, searchWarrant, motionForRelief, firstAppearance, arraignment, contempt
        case expunction, bondForfeiture, drivingPrivilege, treatmentReview, treatmentGraduation, counselWithdrawal

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
            case .contempt: return "Show cause: contempt"
            case .expunction: return "Petition to expunge"
            case .bondForfeiture: return "Motion to set aside bond forfeiture"
            case .drivingPrivilege: return "Limited driving privilege"
            case .treatmentReview: return "Treatment court review"
            case .treatmentGraduation: return "Treatment court graduation"
            case .counselWithdrawal: return "Motion to withdraw as counsel"
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
            case .contempt: return "exclamationmark.shield.fill"
            case .expunction: return "eraser.fill"
            case .bondForfeiture: return "banknote.fill"
            case .drivingPrivilege: return "car.fill"
            case .treatmentReview: return "heart.text.square.fill"
            case .treatmentGraduation: return "graduationcap.fill"
            case .counselWithdrawal: return "person.crop.circle.badge.minus"
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
    /// A different starting figure for some amount options (an unsecured bond starts lower than a secured one).
    var suggestedAmounts: [Int: Int]? = nil

    /// The amount the picker starts at for this option.
    func suggested(for choice: Int?) -> Int? {
        choice.flatMap { suggestedAmounts?[$0] } ?? suggestedAmount
    }
    /// Options the law doesn't allow here (a PJC on a Class A through E felony), kept out of the list.
    var unavailableOptions: Set<Int>? = nil
    /// For a petition (expunction, bond forfeiture, driving privilege): what the law turns on, kept off the card.
    var petition: PetitionFacts? = nil
    /// For a treatment court review or graduation: the program, phase, and this period's report.
    var review: TreatmentReviewFacts? = nil

    /// How the matter is captioned on its card.
    var caption: String {
        switch kind {
        case .searchWarrant: return "In re: search of \(personName)"
        case .expunction: return "In re: petition of \(personName)"
        case .drivingPrivilege: return "In re: \(personName), limited driving privilege"
        case .bondForfeiture: return "State v. \(personName) · surety: \(petition?.company ?? "the bonding company")"
        default: return "State v. \(personName)"
        }
    }

    /// The option text with the amount the judge chose filled in.
    func optionText(_ choice: Int, amount: Int?) -> String {
        let option = options.indices.contains(choice) ? options[choice] : (options.first ?? "")
        guard amountOptions?.contains(choice) == true, let amount = amount ?? suggested(for: choice) else { return option }
        return option.replacingOccurrences(of: "an amount you set", with: "$\(amount.formatted())")
    }

    /// The person's whole file is worth opening for these.
    var concernsProbationer: Bool {
        [.pvAdmission, .earlyTermination, .contempt, .expunction, .bondForfeiture, .drivingPrivilege, .treatmentReview, .treatmentGraduation].contains(kind)
    }
}

/// A petition decided on the papers and short argument. Whether the law allows it is in the facts on the card, not
/// announced; a ruling the law doesn't support comes back later.
struct PetitionFacts: Codable, Hashable {
    var eligible: Bool
    /// Why the law allows it or doesn't, in a sentence, for the result and any later news.
    var reason: String
    var offense: String?
    var priorID: UUID?
    /// Bond forfeiture: the amount; the surety.
    var amount: Int?
    var company: String?
    /// Driving privilege: how likely the person is to drive impaired again, and whether an interlock is required.
    var risk: Double?
    var interlockRequired: Bool?
    /// The person isn't in the court's records yet (a petitioner from another court or years ago).
    var newPerson: Bool?
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
    /// A bail bondsman's fee, as a share of the bond, and whether one will write it (optional for older saves:
    /// those bonds had to be posted in cash).
    var feeRate: Double? = nil
    var bondsman: Bool? = nil

    var money: BailMoney { BailMoney(cash: canPost, feeRate: feeRate ?? 0.15, bondsman: bondsman ?? false) }
}

/// What a defendant can come up with for bail: cash on hand, and whether a bail bondsman will write the bond for a fee.
/// North Carolina caps a bondsman's premium at 15 percent of the bond (G.S. 58-71-95); the bondsman posts the whole
/// amount and keeps the fee.
struct BailMoney: Hashable {
    var cash: Int
    var feeRate: Double
    var bondsman: Bool

    /// The largest secured bond the defendant can make: in cash, or through a bondsman who will write up to $250,000.
    var reach: Int {
        guard bondsman, cash > 0 else { return cash }
        let viaBondsman = Int((Double(cash) / feeRate / 500).rounded(.down)) * 500
        return max(cash, min(250_000, viaBondsman))
    }

    func canMake(_ amount: Int) -> Bool { amount <= reach }

    /// Whether a bond of this amount would go through a bondsman rather than cash.
    func throughBondsman(_ amount: Int) -> Bool { amount > cash && canMake(amount) }

    func fee(on amount: Int) -> Int { Int((Double(amount) * feeRate).rounded()) }

    /// One short line for a calendar card: "Can pay ~$5,000; a bondsman would cover up to $50,000."
    func short(against ask: Int?) -> String {
        if cash == 0 { return "Can't pay anything." }
        if let ask, ask > 0, cash >= ask { return "Can post the State's $\(ask.formatted()) in cash." }
        if !bondsman { return "Has ~$\(cash.formatted()); no bondsman will take it." }
        return "Can pay ~$\(cash.formatted()); a bondsman would cover up to $\(reach.formatted())."
    }

    /// The same, measured against the bond the State wants: whether it can be posted outright, through a bondsman, or not at all.
    func plain(against ask: Int?) -> String {
        guard let ask, ask > 0, cash > 0 else { return plain }
        let pct = Int((feeRate * 100).rounded())
        if cash >= ask {
            return "can pay about $\(cash.formatted()), enough to post the State's $\(ask.formatted()) in cash and get it back at the end of the case"
                + (bondsman ? " (through a bondsman, a bond up to about $\(reach.formatted()))" : "")
        }
        if bondsman && reach >= ask {
            return "can pay about $\(cash.formatted()): not the State's $\(ask.formatted()) in cash, but enough for a bondsman's \(pct)% fee on it (a $\(fee(on: ask).formatted()) fee); the most a bondsman would write is about $\(reach.formatted())"
        }
        return plain + ", short of the State's $\(ask.formatted())"
    }

    /// "can pay about $2,500, enough for a bondsman's fee on a bond up to about $16,500"
    var plain: String {
        if cash == 0 { return "can't pay anything toward a bond" }
        if !bondsman { return "has about $\(cash.formatted()), but no bail bondsman will take the case, so any secured bond has to be paid in full out of pocket" }
        return "can pay about $\(cash.formatted()), enough for a bondsman's \(Int((feeRate * 100).rounded()))% fee on a bond up to about $\(reach.formatted())"
    }

    static func draw(employed: Bool, local: Bool, ftas: Int, rng: inout SeededRNG) -> BailMoney {
        var cash = employed
            ? rng.pick([500, 750, 1_000, 1_500, 2_000, 3_000, 4_000, 5_000, 7_500, 10_000, 15_000, 25_000])
            : rng.pick([0, 0, 250, 500, 750, 1_000, 1_500, 2_500])
        // Family sometimes chips in.
        if rng.chance(0.3) { cash += rng.pick([300, 500, 1_000, 2_000, 5_000]) }
        let rate = rng.pick([0.10, 0.12, 0.15, 0.15])
        // A bondsman won't take someone who has skipped court twice, and is wary of someone with no ties here.
        let willing = ftas < 2 && (local || rng.chance(0.5)) && rng.chance(0.92)
        return BailMoney(cash: cash, feeRate: rate, bondsman: willing)
    }
}

struct CalendarCall: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var matters: [CalendarMatter]
    /// First appearances and show-cause hearings: short matters heard apart from the week's calendar call.
    var bondSession: Bool? = nil
    var isBondSession: Bool { bondSession == true }
    /// What the short session is called, by what's on it.
    var sessionTitle: String {
        let contempt = matters.contains { $0.kind == .contempt }
        let bonds = matters.contains { $0.kind == .firstAppearance }
        return contempt && bonds ? "Bond and show-cause hearings" : (contempt ? "Show-cause hearings" : "First appearances: bond hearings")
    }
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
        if violent { reasons.append(rng.pick(["This was a violent offense, and the State takes it seriously.", "The victim wants \(last) to serve time, and the State agrees."])) }
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
            stateAsk = "The State asks for \(rangeText) suspended, with \(jailDays) day\(jailDays == 1 ? "" : "s") in the county jail up front as special probation, then 18 months supervised. " + why
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
            "Accept the plea; split sentence: \(jailDays) day\(jailDays == 1 ? "" : "s") in jail, then probation" + (stance == 1 ? " (State's ask)" : "")
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
        return (active, "\(active) day\(active == 1 ? "" : "s")", notes)
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
            bound.lawNote = terms.notes.filter { !$0.hasPrefix("PJC not allowed") }.joined(separator: " ")
            if bound.lawNote?.isEmpty == true { bound.lawNote = nil }
            // Option 1 is the prayer for judgment; it isn't offered where the law bars it.
            if [NCClass.A, .B1, .B2, .C, .D, .E].contains(cls) { bound.unavailableOptions = [1] }
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
                          rng: inout SeededRNG) -> (unsecured: Int, secured: Int, stateAsk: String, wantsSecured: Bool) {
        let base = bondBase(cls)
        let factor = (1.0 + 0.25 * Double(min(felonies, 6)) + 0.5 * Double(min(ftas, 3))) * (violent ? 1.25 : 1.0)
        let jitter = Double.random(in: 0.85...1.2, using: &rng)
        let secured = roundBond(Double(base) * factor * jitter)
        let unsecured = roundBond(Double(min(base, 15_000)) * Double.random(in: 0.2...0.8, using: &rng))
        let severity = cls?.severity ?? NCClass.H.severity
        let why = ftas > 0 ? " Missed court before." : felonies >= 2 ? " \(felonies) prior felonies." : violent ? " Violent charge." : ""
        let ask: String
        if cls == .A {
            ask = "Hold without bond, or $\(secured.formatted()) secured with house arrest."
        } else if severity <= NCClass.E.severity && (violent || felonies > 0 || ftas > 0) {
            ask = "$\(secured.formatted()) secured with house arrest." + why
        } else if severity <= NCClass.G.severity || felonies >= 2 || ftas > 0 {
            ask = "$\(secured.formatted()) secured." + why
        } else if rng.chance(0.5) {
            ask = "$\(secured.formatted()) secured."
        } else {
            ask = "Agrees to an unsecured bond of $\(unsecured.formatted())."
            return (unsecured, secured, ask, false)
        }
        return (unsecured, secured, ask, true)
    }

    /// The defense answers the State's position: what the client can raise, in cash or through a bondsman, matters only
    /// against a secured bond.
    static func defenseBondAsk(_ scale: (unsecured: Int, secured: Int, stateAsk: String, wantsSecured: Bool), money: BailMoney, last: String,
                               rng: inout SeededRNG) -> String {
        let keeper = rng.pick(["a parent", "a relative", "the pastor", "a pretrial release program", "a sibling", "a grandparent"])
        if !scale.wantsSecured {
            return rng.pick(["Agrees to the unsecured bond.", "Asks for a written promise; won't fight the unsecured bond."])
        }
        let reach = money.reach
        if reach == 0 {
            return rng.pick(["Can't pay anything. Asks for a written promise to appear.",
                             "Asks for release to \(keeper).",
                             "Asks for an unsecured bond of $\(scale.unsecured.formatted()) instead.",
                             "Asks for house arrest with no money bond."])
        }
        if money.cash >= scale.secured {
            return rng.pick(["Will post the State's figure.",
                             "Asks for an unsecured bond instead.",
                             "Won't fight the bond; asks to skip the monitor."])
        }
        if reach >= scale.secured {
            let lower = roundBond(Double(min(scale.secured, money.cash)) * 0.8)
            return rng.pick(["Asks for an unsecured bond; a bondsman's fee is money \(last) never gets back.",
                             "Asks for $\(max(500, lower).formatted()) secured, which \(last) can post in cash.",
                             "Won't go above the State's figure."])
        }
        let ask = roundBond(Double(reach) * Double.random(in: 0.7...1.0, using: &rng))
        if !money.bondsman {
            return "Asks for $\(min(ask, money.cash).formatted()) secured (no bondsman will take it) or release to \(keeper)."
        }
        return rng.pick(["Asks for $\(ask.formatted()) secured, which a bondsman would write.",
                         "Asks for $\(ask.formatted()) secured with house arrest.",
                         "Asks for release to \(keeper)."])
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
    /// Court dates the defendant has missed before: failure-to-appear convictions, plus, for someone with an earlier case,
    /// sometimes a missed date that never became a conviction. The same answer at every hearing. A person with no
    /// record has no earlier court dates to miss.
    static func missedCourtDates(_ c: CourtCase) -> Int {
        let d = c.defendant
        // The court date missed in this very case counts too.
        let thisCase = c.background?.missedCourt != nil ? 1 : 0
        guard !d.priors.isEmpty else { return thisCase }
        let convictions = d.priors.filter { $0.offense.lowercased().contains("failure to appear") }.count
        var rng = SeededRNG(seed: c.seed ^ 0xF7A)
        return thisCase + convictions + (rng.chance(0.25) ? 1 : 0)
    }

    static func bondMatter(for c: CourtCase, rng: inout SeededRNG) -> CalendarMatter {
        let d = c.defendant
        let felonies = d.priors.filter { $0.ncClass.isFelony }.count
        let ftas = missedCourtDates(c)
        let violent = c.category == .violent || c.category == .robbery
        let employed = !d.occupation.lowercasedPhrase.contains("unemployed")
        let local = rng.chance(0.75)
        let flight = min(0.6, 0.06 + 0.12 * Double(ftas) + (local ? 0 : 0.12) + (employed ? 0 : 0.06) + 0.02 * Double(d.priors.count))
        let danger = min(0.5, 0.04 + (violent ? 0.08 : 0) + 0.05 * Double(felonies))
        let worst = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let scale = bondScale(worst, violent: violent, felonies: felonies, ftas: ftas, rng: &rng)
        let moderate = scale.unsecured
        let high = scale.secured
        let money = BailMoney.draw(employed: employed, local: local, ftas: ftas, rng: &rng)
        let canPost = money.cash
        let law = c.charges.first?.law
        // Iryna's Law (S.L. 2025-93): a felony charge involving violence. Only a judge sets conditions, the law presumes
        // no condition will reasonably assure the public's safety, and the judge may hold the defendant without bond.
        // Release, if any, is on a secured bond or house arrest with electronic monitoring; after an earlier violent
        // conviction, house arrest with monitoring only.
        let violentOffense = c.charges.contains { $0.law.ncClass?.isFelony == true }
            && (violent || c.charges.contains { Corrections.soundsViolent($0.law.title) })
        let priorViolent = d.priors.contains { $0.ncClass.isFelony && Corrections.soundsViolent($0.offense) }
        var record = d.priors.isEmpty ? "No record" : "\(d.priors.count) prior\(d.priors.count == 1 ? "" : "s") (\(felonies) felon\(felonies == 1 ? "y" : "ies"))"
        if ftas > 0 { record += ", \(ftas) missed court date\(ftas == 1 ? "" : "s")" }
        var stateAsk = scale.stateAsk
        var defenseAsk = defenseBondAsk(scale, money: money, last: d.lastName, rng: &rng)
        var options = ["Written promise to appear",
                       "Release to the custody of a designated person or program",
                       "Unsecured bond of an amount you set",
                       "Secured bond of an amount you set",
                       "Secured bond of an amount you set, with electronic house arrest"]
        var unavailable: Set<Int>? = nil
        var lawNote: String? = nil
        if violentOffense {
            options.append("Hold without bond: no condition of release will reasonably assure the public's safety (Iryna's Law)")
            unavailable = priorViolent ? [0, 1, 2, 3] : [0, 1, 2]
            lawNote = "Iryna's Law: violent felony. You may hold without bond; release only on "
                + (priorViolent ? "house arrest (earlier violent conviction)." : "a secured bond or house arrest.")
            if danger >= 0.15 || felonies > 0 || [NCClass.A, .B1, .B2, .C].contains(worst ?? .misd1) {
                stateAsk = "Hold without bond (Iryna's Law)."
            } else {
                stateAsk = "$\(scale.secured.formatted()) secured."
            }
            let figure = max(min(money.reach, scale.secured, max(money.cash, money.reach / 2)), 1_000)
            defenseAsk = priorViolent || money.reach == 0 ? "Asks for house arrest with a monitor." : "Asks for $\(figure.formatted()) secured with a monitor."
        }
        var summary = "\(d.name), \(d.age), arrested this week on \(law?.title.lowercased() ?? "a felony"). \(record). \(money.short(against: scale.wantsSecured || violentOffense ? scale.secured : nil))"
        var flightRisk = flight
        var floor = 500
        var suggested = high
        // Back on the court's own order for arrest after missing court: the law requires a secured bond of at least
        // double the last secured bond, or $1,000, and rules out a promise, a custody release, or an unsecured bond
        // (G.S. 15A-534(d1)). A missed court date alone is no ground to hold without bond.
        if let missed = c.background?.missedCourt, let served = c.background?.servedOrder {
            let minimum = c.background?.ftaMinimumBond ?? 1_000
            floor = minimum
            suggested = max(high, minimum)
            flightRisk = min(0.7, flight + 0.15)
            unavailable = (unavailable ?? []).union([0, 1, 2])
            let missedWord = SentenceFormat.shortDate(missed)
            summary = "Back on your order for arrest: \(d.name) missed court on \(missedWord) (\(law?.title.lowercased() ?? "the charges")) and was picked up \(SentenceFormat.shortDate(served)). \(record). \(money.short(against: suggested))"
            stateAsk = "$\(suggested.formatted()) secured. The law requires at least $\(minimum.formatted())."
            defenseAsk = rng.pick(["\(d.lastName) says the notice went to an old address; asks for the $\(minimum.formatted()) minimum.",
                                   "\(d.lastName) mixed up the date; asks for the $\(minimum.formatted()) minimum.",
                                   "\(d.lastName) had no ride that morning; asks for the $\(minimum.formatted()) minimum.",
                                   "\(d.lastName) was at work and afraid of losing the job; asks for the $\(minimum.formatted()) minimum."])
            lawNote = (lawNote.map { $0 + " " } ?? "")
                + "Missed court: the law requires a secured bond of at least $\(minimum.formatted()) (G.S. 15A-534(d1)). A missed court date alone doesn't allow holding without bond."
        }
        return CalendarMatter(kind: .firstAppearance, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation,
                              docket: c.docket,
                              summary: summary,
                              stateAsk: stateAsk,
                              defenseAsk: defenseAsk,
                              // Every condition G.S. 15A-534(a) allows, with the judge setting any amount.
                              options: options,
                              lawNote: lawNote,
                              pendingCase: c, bond: BondFacts(moderate: moderate, high: high, canPost: canPost, flightRisk: flightRisk, danger: danger,
                                                              feeRate: money.feeRate, bondsman: money.bondsman),
                              amountOptions: [2, 3, 4], amountRange: floor...max(500_000, high * 2, floor * 2), suggestedAmount: suggested,
                              suggestedAmounts: [2: moderate], unavailableOptions: unavailable)
    }

    /// A jailed defendant asks to have the bond lowered (G.S. 15A-538). The judge sets the new amount.
    static func bondReductionMatter(for c: CourtCase, on date: Date? = nil, courtOrdered: Bool = false, rng: inout SeededRNG) -> CalendarMatter {
        let d = c.defendant
        var held = c.background.map { max($0.custodyDays, 1) } ?? rng.int(40...210)
        // No more days in jail than have passed since the arrest.
        if let date, let arrest = c.investigation?.facts?.arrest ?? c.investigation?.facts?.incident {
            let since = CourtCalendar.calendar.dateComponents([.day], from: CourtCalendar.calendar.startOfDay(for: arrest),
                                                             to: CourtCalendar.calendar.startOfDay(for: date)).day ?? held
            held = max(1, min(held, since))
        }
        let worstClass = c.charges.compactMap { $0.law.ncClass }.min { $0.severity < $1.severity }
        let priorFelonies = d.priors.filter { $0.ncClass.isFelony }.count
        let violent = c.category == .violent || c.category == .robbery
        let noBond = c.background?.bondStatus.hasPrefix("Held without bond") ?? false
        // The bond the defendant is actually held on, when the file says it.
        let current = Corrections.dollars(in: c.background?.bondStatus)
            ?? bondScale(worstClass, violent: violent, felonies: priorFelonies, ftas: 0, rng: &rng).secured
        var jailed = c
        if var bg = jailed.background {
            bg.custodyDays = held
            bg.onRelease = false
            bg.bondStatus = noBond
                ? "Held without bond under Iryna's Law; in custody for \(held) day\(held == 1 ? "" : "s")."
                : "Held on a $\(current.formatted()) secured bond; in custody for \(held) day\(held == 1 ? "" : "s")."
            jailed.background = bg
        }
        let employed = !d.occupation.lowercasedPhrase.contains("unemployed")
        // What the defendant told the court at the first hearing, when the court heard it.
        let ftas = missedCourtDates(c)
        let drawn = BailMoney.draw(employed: employed, local: true, ftas: ftas, rng: &rng)
        let money = BailMoney(cash: c.background?.canPost ?? drawn.cash, feeRate: c.background?.bondsmanRate ?? drawn.feeRate,
                              bondsman: c.background?.bondsmanWilling ?? drawn.bondsman)
        let canPost = money.cash
        let felonies = d.priors.filter { $0.ncClass.isFelony }.count
        let flight = min(0.6, 0.06 + 0.12 * Double(ftas) + (employed ? 0 : 0.06) + 0.02 * Double(d.priors.count))
        let danger = min(0.5, 0.04 + (violent ? 0.08 : 0) + 0.05 * Double(felonies))
        let law = c.charges.first?.law.title.lowercased() ?? "the charge"
        // Iryna's Law limits release on a violent felony to a secured bond or house arrest.
        let violentOffense = c.charges.contains { $0.law.ncClass?.isFelony == true }
            && (violent || c.charges.contains { Corrections.soundsViolent($0.law.title) })
        let priorViolent = d.priors.contains { $0.ncClass.isFelony && Corrections.soundsViolent($0.offense) }
        let unavailable: Set<Int>? = violentOffense ? (priorViolent ? [0, 3, 4] : [3, 4]) : nil
        let record = (d.priors.isEmpty ? "No record" : "\(d.priors.count) prior\(d.priors.count == 1 ? "" : "s")")
            + (ftas > 0 ? ", \(ftas) missed court date\(ftas == 1 ? "" : "s")" : "") + "."
        let heldText = noBond ? "held \(held) day\(held == 1 ? "" : "s") without bond" : "held \(held) day\(held == 1 ? "" : "s") on $\(current.formatted())"
        let opening = courtOrdered
            ? "Your bond review: \(d.name), \(heldText) on \(law)."
            : "\(d.name), \(heldText) on \(law), asks for \(noBond ? "conditions of release" : "a lower bond")."
        let stateAsk: String
        if noBond { stateAsk = "Keep holding without bond." }
        else if ftas > 0 { stateAsk = "Opposes: missed court before." }
        else if violent { stateAsk = "Opposes: violent charge." }
        else { stateAsk = "Would agree to a modest cut with a monitor." }
        let defenseAsk: String
        if !noBond && money.canMake(current) {
            defenseAsk = "Can post the $\(current.formatted()) as it stands; asks to leave it."
        } else if money.reach == 0 {
            defenseAsk = rng.pick(["Can't pay anything; asks for a written promise.", "Asks for release to a pretrial program."])
        } else {
            defenseAsk = "Asks for $\(roundBond(Double(money.reach) * 0.8).formatted()), within reach through \(money.bondsman ? "a bondsman" : "savings")."
        }
        return CalendarMatter(kind: .bondModification, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation,
                              docket: c.docket,
                              summary: "\(opening) \(record) \(money.short(against: noBond ? nil : current))",
                              stateAsk: stateAsk,
                              defenseAsk: defenseAsk,
                              options: ["Set a new secured bond of an amount you set",
                                        noBond ? "Keep \(d.lastName) held without bond" : "Leave the bond at $\(current.formatted())",
                                        "Set a new secured bond of an amount you set, with electronic house arrest",
                                        "Change to an unsecured bond of an amount you set",
                                        "Release on a written promise to appear"],
                              lawNote: violentOffense ? "Iryna's Law: release only on " + (priorViolent ? "house arrest (earlier violent conviction)." : "a secured bond or house arrest.") : nil,
                              pendingCase: jailed,
                              bond: BondFacts(moderate: current, high: current, canPost: canPost, flightRisk: flight, danger: danger,
                                              feeRate: money.feeRate, bondsman: money.bondsman),
                              amountOptions: [0, 2, 3], amountRange: 500...max(500_000, current * 2), suggestedAmount: max(500, min(current / 2, max(500, money.reach))),
                              suggestedAmounts: [3: max(500, current / 2)], unavailableOptions: unavailable)
    }

    /// A stay-away order broken by someone not on probation: a short hearing on criminal contempt (G.S. 5A-11, 5A-15),
    /// not a new trial. The court may jail the person up to 30 days or fine up to $500 (G.S. 5A-12).
    static func contemptMatter(person: PersonRecord, order: StayAwayOrder, conduct: String, date: Date, rng: inout SeededRNG) -> CalendarMatter {
        let last = person.lastName
        return CalendarMatter(
            kind: .contempt, personID: person.id, personName: person.name, personAge: person.age(on: date), occupation: person.occupation,
            docket: order.docket + " (contempt)",
            summary: "\(person.name) is accused of violating the stay-away order protecting \(order.protectedName): \(last) \(conduct).",
            stateAsk: rng.pick(["30 days in jail; \(order.protectedName) is afraid.", "Find willful contempt; active time.", "Find contempt."]),
            defenseAsk: rng.pick(["Says it was a chance meeting; asks for a warning.", "Didn't know the order still applied; asks for a warning.",
                                  "Accepts responsibility; asks for a fine."]),
            options: ["Find willful contempt: 30 days in the county jail", "Find willful contempt: 10 days in the county jail",
                      "Find contempt: a $500 fine", "Not willful: warn \(last) and continue the order"])
    }

    /// Arraignment in superior court (G.S. 15A-941): the plea is entered and the court sets the trial date.
    /// A defendant arrested and brought before the court earlier offers to plead at arraignment.
    static func pleaMatter(for c: CourtCase) -> CalendarMatter {
        let law = c.charges.first?.law ?? LawLibrary.law("felonyLarceny")
        let m = CalendarMatter(kind: .quickPlea, personID: c.defendant.personID, personName: c.defendant.name, personAge: c.defendant.age,
                               occupation: c.defendant.occupation, docket: c.docket, summary: "", stateAsk: "", defenseAsk: "", options: [],
                               lawID: law.id)
        return bind(m, to: c)
    }

    static func arraignmentMatter(for c: CourtCase) -> CalendarMatter {
        let d = c.defendant
        let jailed = c.background?.isJailed ?? false
        let counts = c.charges.count
        return CalendarMatter(kind: .arraignment, personID: d.personID, personName: d.name, personAge: d.age, occupation: d.occupation,
                              docket: c.docket,
                              summary: "\(d.name) pleads not guilty to \(counts) count\(counts == 1 ? "" : "s") (\(c.charges.first?.law.title.lowercased() ?? "the indictment")). \(jailed ? "In custody." : "Out on bond.")",
                              stateAsk: "Ready in about five weeks.",
                              defenseAsk: counts > 2 ? "Wants ten weeks for discovery." : "Wants five weeks for discovery.",
                              options: ["Set the trial date now", "Put it on the waiting list; set the date later"],
                              pendingCase: c)
    }

    /// A convicted defendant asks the trial judge for a new trial on newly discovered evidence.
    static func reliefMatter(_ m: ReliefMotion, judgeLast: String) -> CalendarMatter {
        let hearing = m.hearingHeld == true
        let heardText = hearing
            ? (m.meritorious
                ? " Hearing: the witness held up on cross."
                : " Hearing: the witness contradicted the affidavit.")
            : ""
        var options = ["Grant: vacate the conviction and order a new trial", "Deny the motion"]
        if !hearing { options.insert("Hold an evidentiary hearing next week before ruling", at: 1) }
        return CalendarMatter(kind: .motionForRelief, personID: m.personID, personName: m.personName, personAge: m.retrial.defendant.age,
                              occupation: m.retrial.defendant.occupation, docket: m.docket,
                              summary: "\(m.personName), convicted of \(m.offense.lowercased()), asks for a new trial on new evidence: \(m.newEvidence)" + heardText,
                              stateAsk: "Opposes: could have been found before trial.",
                              defenseAsk: "New evidence that goes to the heart of the case.",
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
                     seed: UInt64, takenNames: Set<String> = []) -> CalendarCall {
        var rng = SeededRNG(seed: seed)
        var used = Set(people.map(\.name)).union(takenNames)
        let year = Calendar.current.component(.year, from: date) % 100
        var sequence = docketSequence
        func docket(_ felony: Bool) -> String {
            sequence += rng.int(3...40)
            return String(format: "%02d %@ %06d", year, felony ? "CRS" : "CR", sequence)
        }

        var matters: [CalendarMatter] = []
        // Pleas come only from defendants already arrested and brought before the court (see GameState).

        // Capacity motions are rare: only now and then, and only for a defendant with a known mental health need.
        var others: [CalendarMatter.Kind] = rng.pick([.failureToAppear, .continuance, .bondModification], count: 2)
        if rng.chance(0.1) { others.append(.capacity) }
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
                    summary: "\(name) didn't answer today's calendar call on \(law.title).",
                    stateAsk: rng.pick(["Order for arrest; forfeit the bond.", "Order for arrest, no bond.", "Order for arrest; double the bond."]),
                    defenseAsk: rng.pick(["Knew the date; no explanation.", "Car broke down; asks for the afternoon.", "May have confused the date; asks for the afternoon.",
                                          "Can't reach the client.", "Ride fell through; asks for a new date.", "Possible hospital visit; asks for a day."]),
                    options: ["Issue an order for arrest and forfeit the bond", "Hold the matter open until the afternoon session",
                              "Continue the case three weeks and send a new notice"]))
            case .continuance:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: "The defense moves to continue the trial of \(name) on \(law.title). It would be the \(rng.pick(["third", "fourth", "second"])) continuance.",
                    stateAsk: rng.pick(fittingStateObjections(for: law) + ["No objection.", "No position; make it the last."]),
                    defenseAsk: rng.pick(["Lab report just arrived; needs an expert.", "Newly appointed; hasn't met the client.",
                                          "A defense witness is deployed until next month.", "Four hours of new bodycam video to review.",
                                          "Stuck in a murder trial in another county.", "Client is in inpatient treatment for 28 days."]),
                    options: ["Grant the continuance and pick the new trial date", "Deny; the case is ready for trial and you set the date"]))
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
                    summary: "The defense questions whether \(name) is capable of standing trial on \(law.title).",
                    stateAsk: "No position; seemed oriented at the bond hearing.",
                    defenseAsk: "Client thinks counsel works for the DA and won't talk.",
                    options: ["Order a forensic evaluation at Central Regional Hospital (about ten weeks)",
                              "Order a local screening evaluation (about three weeks)", "Find the defendant capable; the case is tried this week"]))
            default:
                break
            }
        }

        // A steady probationer asks to end probation early: only once at least half the term is served.
        // Only probation this court imposed: a term from another court goes back to that court.
        let probationers = people.filter { $0.status == .probation && ($0.probation?.imposedInThisCourt ?? false) && !excluding.contains($0.id) }
        let steady = probationers.filter { person in
            guard let term = person.probation, (term.violationRisk ?? 0.2) < 0.25,
                  !(person.violations ?? []).contains(where: { $0.docket == term.docket }),
                  let start = ViolationHearings.probationStart(person, term) else { return false }
            let halfway = start.addingTimeInterval(term.ends.timeIntervalSince(start) / 2)
            return halfway <= date
        }
        if let person = steady.isEmpty ? nil : rng.pick(steady), let term = person.probation, rng.chance(0.5) {
            let owes = (term.monthlyObligation ?? 0) > 0
            let compliance = (term.supervised ?? true) ? "Officer reports full compliance." : "No new charges" + (owes ? "; payments current." : ".")
            matters.append(CalendarMatter(
                kind: .earlyTermination, personID: person.id, personName: person.name, personAge: person.age(on: date),
                occupation: person.occupation, docket: term.docket,
                summary: "\(person.name) asks to end probation early (\(term.offense)). \(compliance)",
                stateAsk: owes
                    ? rng.pick(["No position.", "Opposes: money still owed.", "No objection once paid in full."])
                    : rng.pick(["No position.", "No objection."]),
                defenseAsk: rng.pick(["A new job needs travel.", "Over half served, no violations.", "Wants to move closer to family."]),
                options: ["Grant: probation ends successfully (G.S. 15A-1342(b))",
                          owes ? "Grant once all money owed is paid" : "Grant; nothing is owed, so probation ends today",
                          "Deny: probation continues as ordered"],
                owesMoney: owes))
        }
        // An admission comes from someone who has had time to slip, hasn't just been before the court, and, more often
        // than not, has a record: first offenders mostly keep their conditions.
        let cal = CourtCalendar.calendar
        let settled = cal.date(byAdding: .day, value: -60, to: date) ?? date
        let recent = cal.date(byAdding: .day, value: -45, to: date) ?? date
        let slipping = probationers.filter { person in
            guard let term = person.probation, (ViolationHearings.probationStart(person, term) ?? .distantPast) < settled,
                  (person.lastReleased ?? .distantPast) < settled,
                  (person.appearances.last?.date ?? .distantPast) < recent else { return false }
            let others = person.priors.filter { $0.docket == nil || $0.docket != term.docket }.count
            return rng.chance(others == 0 ? 0.25 : (others >= 3 ? 1 : 0.7))
        }
        if let person = slipping.isEmpty ? nil : rng.pick(slipping), let term = person.probation, rng.chance(0.6),
           !matters.contains(where: { $0.personID == person.id }) {
            let supervised = term.supervised ?? true
            let crv = ViolationHearings.crvDays(term)
            matters.append(CalendarMatter(
                kind: .pvAdmission, personID: person.id, personName: person.name, personAge: person.age(on: date),
                occupation: person.occupation, docket: term.docket + " (PV)",
                summary: "\(person.name) admits " + pvAdmissionConduct(supervised: supervised) + " while on probation in \(term.docket).",
                stateAsk: "Three-day quick dip.",
                defenseAsk: "Admits it; asks to continue probation.",
                options: ["Continue probation on the same terms", "Modify: add substance abuse treatment", "Order a three-day quick dip"]
                    + (crv > 0 ? ["Order a \(crv)-day CRV"] : [])))
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
                let termText = m.isFelony ? "\(m.activeTerm)–\(StructuredSentencing.maximum(forMinimum: m.activeTerm, cls: cls)) months" : "\(m.activeTerm) day\(m.activeTerm == 1 ? "" : "s")"
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
                    sentence = "\(termText) suspended; special probation with \(days) day\(days == 1 ? "" : "s") active, then 18 months supervised probation"
                    person.probation = ProbationTerm(docket: m.docket, offense: law.title, isFelony: m.isFelony,
                                                     suspendedSentence: termText,
                                                     activeMonths: m.isFelony ? m.activeTerm : max(1, m.activeTerm / 30),
                                                     ends: Calendar.current.date(byAdding: .month, value: 18, to: date) ?? date,
                                                     imposedInThisCourt: true, supervised: true, conditions: ["Special probation: \(days) day\(days == 1 ? "" : "s") in the county jail."],
                                                     monthlyObligation: 60, violationRisk: rng.chance(0.5) ? 0.18 : 0.1,
                                                     crvCount: 0, treatmentNeed: TreatmentNeed.none)
                    person.probation?.activeDays = m.isFelony ? nil : m.activeTerm
                    person.probation?.offenseClass = cls
                    person.probation?.starts = date
                    let out = Calendar.current.date(byAdding: .day, value: max(0, days - credit), to: date) ?? date
                    if out > date {
                        person.status = .incarcerated
                        person.releaseDate = out
                        person.releaseNote = "Special probation: \(days) day\(days == 1 ? "" : "s") in the county jail, ordered on a plea at the calendar call. Probation follows release."
                    } else {
                        person.status = .probation
                    }
                default:
                    sentence = "\(termText) active" + (credit > 0 ? ", with credit for \(credit) day\(credit == 1 ? "" : "s") served" : "")
                    let full = Calendar.current.date(byAdding: m.isFelony ? .month : .day, value: m.activeTerm, to: date) ?? date
                    let release = Calendar.current.date(byAdding: .day, value: -credit, to: full) ?? full
                    if release <= date {
                        // The credit covers the whole term: released from the courtroom.
                        person.status = .free
                        person.releaseNote = "Pleaded guilty at the calendar call; \(termText) active, fully served by \(credit) day\(credit == 1 ? "" : "s") of pretrial credit."
                    } else {
                        person.status = .incarcerated
                        person.releaseDate = release
                        person.releaseNote = "Committed on a guilty plea at the calendar call: \(termText) active" + (credit > 0 ? ", less \(credit) day\(credit == 1 ? "" : "s") of credit." : ".")
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
            case .expunction, .bondForfeiture, .drivingPrivilege:
                guard let p = m.petition else { continue }
                let r = Petitions.resolve(m, facts: p, choice: choice, date: date, judgeLast: judgeLast, rng: &rng)
                if p.newPerson == true {
                    var person = PersonRecord(id: m.personID, name: m.personName, birthYear: year - m.personAge, occupation: m.occupation,
                                              background: BackgroundLines.pick(age: m.personAge, occupation: m.occupation, used: [], towns: county.towns, rng: &rng),
                                              priors: m.priors, releaseDate: nil, probation: nil, propensity: p.risk ?? 0.2)
                    r.update(&person)
                    newPeople.append(person)
                } else {
                    updates.append((m.personID, r.update))
                }
                pending += r.later
            case .treatmentReview, .treatmentGraduation:
                guard let r = m.review else { continue }
                let ruling = TreatmentCourts.resolve(m, facts: r, choice: choice, date: date, judgeLast: judgeLast, rng: &rng)
                updates.append((m.personID, ruling.update))
                pending += ruling.later
                if ruling.endsProbation { probationCompleted += 1 }
            case .contempt:
                let days = choice == 0 ? 30 : (choice == 1 ? 10 : 0)
                updates.append((m.personID, { person in
                    if days > 0 {
                        person.status = .incarcerated
                        person.releaseDate = Calendar.current.date(byAdding: .day, value: days, to: date)
                        person.releaseNote = "Criminal contempt: \(days) day\(days == 1 ? "" : "s") in the county jail for violating a stay-away order."
                    }
                    person.appearances.append(PersonRecord.Appearance(docket: m.docket, date: date, charges: "Criminal contempt (stay-away order)",
                                                                      outcome: option.trimmingTrailingPeriods))
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
                        person.releaseNote = "Confinement in response to violation: \(days) day\(days == 1 ? "" : "s"), ordered at the calendar call. Probation resumes on release."
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
        unavailableOptions = try c.decodeIfPresent(Set<Int>.self, forKey: .unavailableOptions)
        petition = try c.decodeIfPresent(PetitionFacts.self, forKey: .petition)
        review = try c.decodeIfPresent(TreatmentReviewFacts.self, forKey: .review)
        suggestedAmounts = try c.decodeIfPresent([Int: Int].self, forKey: .suggestedAmounts)
    }
}

/// Near Thanksgiving and Christmas, a defendant charged with something non-violent who has a family at home may ask
/// to be there for it: out on bond for the holiday, or a sentence that doesn't put them in jail over it.
enum HolidayAsks {
    /// The holiday a call falls just before: within three weeks of Thanksgiving or Christmas.
    static func upcoming(after date: Date) -> (name: String, date: Date)? {
        let cal = CourtCalendar.calendar
        let year = cal.component(.year, from: date)
        var candidates: [(String, Date)] = []
        for (day, name) in CourtCalendar.holidays(in: year) where name == "Thanksgiving" { candidates.append(("Thanksgiving", day)) }
        if let christmas = cal.date(from: DateComponents(year: year, month: 12, day: 25)) { candidates.append(("Christmas", christmas)) }
        let start = cal.startOfDay(for: date)
        return candidates.first { pair in
            let days = cal.dateComponents([.day], from: start, to: cal.startOfDay(for: pair.1)).day ?? -1
            return days >= 1 && days <= 21
        }.map { (name: $0.0, date: $0.1) }
    }

    static func apply(_ call: inout CalendarCall) {
        guard let holiday = upcoming(after: call.date) else { return }
        for i in call.matters.indices {
            let m = call.matters[i]
            guard [.quickPlea, .bondModification, .firstAppearance].contains(m.kind), let c = m.pendingCase,
                  ![LawCategory.violent, .robbery, .family].contains(c.category),
                  !c.charges.contains(where: { Corrections.soundsViolent($0.law.title) }) else { continue }
            let profile = c.defendant.profile
            let kids = profile?.childCount ?? 0
            let married = profile?.married ?? false
            guard kids > 0 || married else { continue }
            var rng = SeededRNG(seed: c.seed ^ 0x401_1DA7)
            guard rng.chance(0.55) else { continue }
            let last = c.defendant.lastName
            let count = ["", "one", "two", "three", "four", "five"]
            let who = kids > 0 ? (kids == 1 ? "a child" : "\(kids < count.count ? count[kids] : "\(kids)") children") : "a spouse"
            let family = kids > 0 ? (kids == 1 ? "the child" : "the kids") : "the spouse"
            let days = CourtCalendar.calendar.dateComponents([.day], from: CourtCalendar.calendar.startOfDay(for: call.date),
                                                              to: holiday.date).day ?? 0
            let when = days <= 2 ? "in \(days) day\(days == 1 ? "" : "s")" : days <= 9 ? "next week" : days <= 16 ? "in two weeks" : "in three weeks"
            _ = family
            switch m.kind {
            case .quickPlea:
                call.matters[i].defenseAsk += " Wants to be home for \(holiday.name) (\(when))."
            default:
                call.matters[i].summary += " Has \(who); wants to be home for \(holiday.name) (\(when))."
            }
        }
    }
}

/// What the judge decided on one calendar-call or bond-hearing matter, kept so it can be looked back on.
struct CalendarRuling: Codable, Hashable, Identifiable {
    var id = UUID()
    var date: Date
    var kind: CalendarMatter.Kind
    var personName: String
    var docket: String
    var summary: String
    var ruling: String

    /// Which filter in Records shows it.
    enum Group: String, CaseIterable, Identifiable {
        case all, bond, pleas, probation, other
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "All"
            case .bond: return "Bond"
            case .pleas: return "Pleas"
            case .probation: return "Probation"
            case .other: return "Other"
            }
        }
    }

    var group: Group {
        switch kind {
        case .firstAppearance, .bondModification, .failureToAppear, .bondForfeiture: return .bond
        case .quickPlea, .arraignment: return .pleas
        case .pvAdmission, .earlyTermination, .treatmentReview, .treatmentGraduation: return .probation
        default: return .other
        }
    }
}


extension CalendarCalls {
    /// What the State says when it objects to a continuance. Each reason is different, so the same line doesn't repeat.
    /// The State's reasons for objecting to a delay, limited to the ones that make sense for this charge: a ballistics
    /// report in an assault case, a lab in a drug case, a bank's records in an embezzlement.
    static func fittingStateObjections(for law: Law) -> [String] {
        let id = law.id
        func has(_ line: String, _ words: [String]) -> Bool { words.contains { line.lowercased().contains($0) } }
        return stateObjections.filter { line in
            if has(line, ["ballistics", "firearms expert"]) && id != "awdw" { return false }
            if has(line, ["fingerprint", "dna"]) && !["awdw", "feloniousBE", "felonyLarceny"].contains(id) { return false }
            if has(line, ["toxicology", "medical examiner", "autopsy"]) && id != "pwisd" { return false }
            if has(line, ["lineup"]) && !["awdw", "feloniousBE", "felonyLarceny"].contains(id) { return false }
            if has(line, ["bank records", "handwriting", "forensic accountant", "adjuster", "lost wages", "repair estimate"]) && !["embezzlement", "felonyLarceny"].contains(id) { return false }
            if has(line, ["victim", "physician who treated"]) && ["pwisd", "fleeing"].contains(id) { return false }
            if has(line, ["youth witness", "juvenile co-defendant", "gas station", "dash camera"]) && !["awdw", "feloniousBE", "felonyLarceny", "fleeing"].contains(id) { return false }
            return true
        }
    }

    static let stateObjections: [String] = [
        "Objects: the victim has missed work three times for this case.",
        "Objects: the case is over a year old and the victim is tired of waiting.",
        "Objects: a key witness is leaving the county for a new job.",
        "Objects: the detective on the case is transferring to another agency next month.",
        "Objects: the State's lab analyst is on leave until the end of the month.",
        "Objects: a witness has a medical procedure scheduled and can't be subpoenaed in time.",
        "Objects: the State's expert is out of the country for three weeks.",
        "Objects: a civilian witness has moved and the State is still finding them.",
        "Objects: the defense has had the State's file for months.",
        "Objects: the officer who made the stop is on a training assignment.",
        "Objects: the State's photographs haven't come back from the lab.",
        "Objects: the victim is willing to testify this month and may not be next month.",
        "Objects: the State's only eyewitness changed phone numbers and hasn't answered.",
        "Objects: the medical examiner's report is in, but the State hasn't finished reviewing it.",
        "Objects: a deputy who saw the arrest has been reassigned to the coast.",
        "Objects: the victim has moved to another state and wants the case over with.",
        "Objects: the jail transport for the State's witness fell through last time.",
        "Objects: the defense is stalling, and the State's witnesses have already taken time off work.",
        "No objection, but the State wants a firm date on the calendar.",
        "No position; the State will be ready whichever way the court goes.",
        "Objects: the trooper who wrote the citation starts a two-week leave on the 15th.",
        "Objects: the State's medical records custodian is retiring and the file has to be re-certified.",
        "Objects: a fingerprint examiner is out with a broken wrist and the State's report is unsigned.",
        "Objects: the 911 recordings were sent to the wrong agency and must be requested again.",
        "Objects: the victim's mother is in the hospital and the State wants her on the stand.",
        "Objects: the State's ballistics comparison is waiting on a second test firing.",
        "Objects: the youth witness's school schedule conflicts with every date the court offered.",
        "Objects: the State's bank records subpoena came back with half the pages missing.",
        "Objects: the investigating deputy has been called to a federal grand jury in another district.",
        "Objects: the State's toxicology report is still pending at the state lab.",
        "Objects: the video from the gas station was overwritten and the State is reconstructing it from a phone.",
        "Objects: the detective's notes are in a box at the old sheriff's annex and haven't been pulled.",
        "Objects: the State's cooperating witness has been moved to another facility.",
        "Objects: the victim wants a lawyer of her own to advise her before she testifies.",
        "Objects: the physician who treated the victim is abroad until the spring.",
        "Objects: the State needs an interpreter for two witnesses and the court has none this month.",
        "Objects: the State's handwriting examiner needs the original document, which the bank still holds.",
        "Objects: the State's DNA results are due back next Tuesday.",
        "Objects: a juvenile co-defendant's case has to be resolved first.",
        "Objects: the victim's insurance adjuster has the only copy of the repair estimate.",
        "Objects: the arresting officer's dash camera was pulled for a repair, and the State must re-request it.",
        "Objects: the State's photo lineup administrator is in training until the end of the quarter.",
        "Objects: the autopsy photographs were redacted and the State is waiting on the redacted set.",
        "Objects: two of the State's witnesses are on a fishing trip that they'll be back from next week.",
        "Objects: a forensic accountant the State retained has resigned from the firm.",
        "Objects: the phone carrier's records took six weeks and the State only received the first half.",
        "Objects: the victim's employer has to confirm the lost wages and hasn't returned the State's calls.",
        "Objects: the State just found a second witness and needs time to interview them.",
        "Objects: the county's surveillance system was upgraded and the State can't pull the old footage yet.",
        "Objects: the victim's family moved out of state and the State is arranging remote testimony.",
        "Objects: the State's firearms expert is testifying in another county on the same date.",
    ]
}
