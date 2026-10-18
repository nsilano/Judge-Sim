import Foundation

/// One short matter handled at an administrative calendar call.
struct CalendarMatter: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case quickPlea, failureToAppear, continuance, bondModification, capacity, pvAdmission, earlyTermination, searchWarrant, motionForRelief

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

    /// The person's whole file is worth opening for these.
    var concernsProbationer: Bool { kind == .pvAdmission || kind == .earlyTermination }
}

struct CalendarCall: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var matters: [CalendarMatter]
}

enum CalendarCalls {

    private static let pleaLaws = ["felonyLarceny", "possSchedII", "breakingVehicle", "larcenyMerchant", "feloniousBE",
                                   "uttering", "pwisd", "commonLawRobbery", "possStolen", "strangulation", "awdwisi", "burglary2"]

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
            if let oldLaw = m.lawID.map({ LawLibrary.law($0).title }), let law { out = out.replacingOccurrences(of: oldLaw, with: law.title) }
            return out
        }
        bound.personID = c.defendant.personID
        bound.personName = c.defendant.name
        bound.personAge = c.defendant.age
        bound.occupation = c.defendant.occupation
        bound.docket = c.docket
        bound.pendingCase = c
        if m.kind == .quickPlea, let law {
            let cls = law.ncClass ?? .misd1
            let terms = pleaTerms(law, priors: c.defendant.priors)
            let priorCount = c.defendant.priors.count
            bound.lawID = law.id
            bound.priors = c.defendant.priors
            bound.isFelony = cls.isFelony
            bound.activeTerm = terms.active
            bound.lawNote = terms.notes.isEmpty ? nil : terms.notes.joined(separator: " ")
            bound.summary = "\(c.defendant.name), \(c.defendant.age), \(c.defendant.occupation.lowercased().withIndefiniteArticle), offers to plead guilty to \(law.title) (\(cls.shortLabel)). Prior record: \(priorCount == 0 ? "none" : "\(priorCount) conviction\(priorCount == 1 ? "" : "s")")."
            bound.stateAsk = "The State and defense jointly recommend \(terms.rangeText), suspended, 12 months of supervised probation, and costs."
            bound.options = ["Accept the plea; follow the joint recommendation",
                             "Accept the plea; continue prayer for judgment on costs",
                             "Accept the plea; impose \(terms.rangeText) active",
                             "Reject the plea; set the case for trial in two weeks"]
        } else {
            bound.summary = m.summary.replacingOccurrences(of: oldName, with: c.defendant.name)
            if let law {
                for id in ["felonyLarceny", "pwisd", "awdw", "feloniousBE", "fleeing", "embezzlement"] {
                    bound.summary = bound.summary.replacingOccurrences(of: " on \(LawLibrary.law(id).title)", with: " on \(law.title)")
                }
            }
            bound.stateAsk = swap(m.stateAsk)
            bound.defenseAsk = swap(m.defenseAsk)
        }
        return bound
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
                       options: ["Sign the warrant as written",
                                 "Strike the catch-all language and sign the rest",
                                 "Deny: the affidavit doesn't show probable cause"],
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
            let record = PriorRecord(priors: priors, onSupervision: false)
            let active: Int
            let rangeText: String
            var notes: [String] = []
            if cls.isFelony, let cell = StructuredSentencing.felonyCell(cls, level: record.felonyLevel) {
                active = cell.presumptive.low
                rangeText = "\(cell.presumptive.low)–\(StructuredSentencing.maximum(forMinimum: cell.presumptive.low, cls: cls)) months"
                if [.A, .B1, .B2, .C, .D, .E].contains(cls) { notes.append("PJC not allowed for this class.") }
                if !cell.dispositions.contains(.community) && !cell.dispositions.contains(.intermediate) {
                    notes.append("At prior record level \(SentenceFormat.romanLevels[record.felonyLevel - 1]) the chart calls for an active sentence; suspending it departs from Structured Sentencing.")
                }
            } else {
                let cell = StructuredSentencing.misdemeanorCell(cls, level: record.misdemeanorLevel)
                active = max(1, (cell?.maxDays ?? 30) / 2)
                rangeText = "\(active) days"
                if let cell, !cell.dispositions.contains(.active) {
                    notes.append("At this prior conviction level the chart allows only community punishment; an active term departs from it.")
                }
            }
            let occupation = rng.pick(NameBank.occupations)
            matters.append(CalendarMatter(
                kind: .quickPlea, personID: UUID(), personName: name, personAge: age, occupation: occupation,
                docket: docket(cls.isFelony),
                summary: "\(name), \(age), \(occupation.lowercased().withIndefiniteArticle), offers to plead guilty to \(law.title) (\(cls.shortLabel)). Prior record: \(priorCount == 0 ? "none" : "\(priorCount) conviction\(priorCount == 1 ? "" : "s")").",
                stateAsk: "The State and defense jointly recommend \(rangeText), suspended, 12 months of supervised probation, and costs.",
                defenseAsk: rng.pick(["My client has a job and wants to keep it.", "My client has been sober since the arrest.", "This is about one bad night, Judge."]),
                options: ["Accept the plea; follow the joint recommendation",
                          "Accept the plea; continue prayer for judgment on costs",
                          "Accept the plea; impose \(rangeText) active",
                          "Reject the plea; set the case for trial"],
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
                    summary: "\(name) was called three times in the hallway and did not appear for trial on \(law.title).",
                    stateAsk: "The State asks for an order for arrest and forfeiture of the \(rng.pick(["$5,000", "$10,000", "$20,000"])) bond.",
                    defenseAsk: rng.pick(["I spoke with my client last week. They knew the date. I can't explain it.",
                                          "My client's mother called my office this morning. There may have been a hospital visit. I'd ask for a day to find out."]),
                    options: ["Issue an order for arrest and forfeit the bond", "Hold the matter open until the afternoon session",
                              "Continue the case three weeks and send a new notice"]))
            case .continuance:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: "The defense moves to continue the trial of \(name) on \(law.title). It would be the \(rng.pick(["third", "fourth", "second"])) continuance.",
                    stateAsk: rng.pick(["The State objects. The victim has taken off work three times for this case.",
                                        "The State doesn't object, Judge."]),
                    defenseAsk: rng.pick(["We just received the lab report Friday. I can't effectively cross-examine the analyst without our own expert.",
                                          "I was appointed two weeks ago. Prior counsel withdrew. I haven't met my client in person yet."]),
                    options: ["Grant the continuance; reset for trial in four weeks", "Deny; the case is tried this week"]))
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
                stateAsk: "The State asks for a two-day quick dip.",
                defenseAsk: "My client admits it and is back on track. We ask the court to continue probation.",
                options: ["Continue probation on the same terms", "Modify: add substance abuse treatment", "Order a two-day quick dip",
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

    static func resolve(_ call: CalendarCall, choices: [UUID: Int], judgeName: String, county: County) -> Result {
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
            let option = m.options.indices.contains(choice) ? m.options[choice] : m.options[0]
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
                switch choice {
                case 0:
                    sentence = "\(termText) suspended, 12 months supervised probation"
                    person.status = .probation
                    person.probation = ProbationTerm(docket: m.docket, offense: law.title, isFelony: m.isFelony,
                                                     suspendedSentence: termText,
                                                     activeMonths: m.isFelony ? m.activeTerm : max(1, m.activeTerm / 30),
                                                     ends: Calendar.current.date(byAdding: .month, value: 12, to: date) ?? date,
                                                     imposedInThisCourt: true, supervised: true, conditions: [],
                                                     monthlyObligation: 60, violationRisk: rng.chance(0.5) ? 0.2 : 0.12,
                                                     crvCount: 0, treatmentNeed: TreatmentNeed.none)
                case 1:
                    sentence = "Prayer for judgment continued"
                default:
                    sentence = "\(termText) active"
                    person.status = .incarcerated
                    person.releaseDate = Calendar.current.date(byAdding: m.isFelony ? .month : .day, value: m.activeTerm, to: date)
                    person.releaseNote = "Committed on a guilty plea at the calendar call: \(termText) active."
                    if m.isFelony, let release = person.releaseDate {
                        // Felony actives carry post-release supervision after release (G.S. 15A-1368.2).
                        let months = StructuredSentencing.postReleaseMonths(for: cls)
                        person.pendingPostRelease = PostReleaseTerm(docket: m.docket, offense: law.title,
                                                                    ends: Calendar.current.date(byAdding: .month, value: months, to: release) ?? release,
                                                                    supervisionMonths: months, remainingMonths: months)
                    }
                }
                if choice == 0 { suspendedSentences += 1 } else if choice != 1 { activeSentences += 1 }
                person.priors.append(PriorConviction(offense: law.title, ncClass: cls, year: year, county: county.name,
                                                     sentence: sentence, fromThisCourt: true, docket: m.docket,
                                                     sessionKey: Judgment.sessionKey(county: county, date: date)))
                person.appearances.append(PersonRecord.Appearance(docket: m.docket, date: date, charges: law.title,
                                                                  outcome: "Guilty plea at calendar call. \(sentence)"))
                newPeople.append(person)
            case .bondModification where choice == 0 && rng.chance(0.2):
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
                        term.violationRisk = max(0.05, (term.violationRisk ?? 0.2) - 0.03)
                    case 3:
                        // Credit for earlier CRVs: a misdemeanor CRV never exceeds the suspended time left.
                        let days = max(1, ViolationHearings.crvDays(term))
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
