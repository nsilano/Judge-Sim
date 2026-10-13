import Foundation

/// One short matter handled at an administrative calendar call.
struct CalendarMatter: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case quickPlea, failureToAppear, continuance, bondModification, capacity, pvAdmission, earlyTermination

        var label: String {
            switch self {
            case .quickPlea: return "Plea"
            case .failureToAppear: return "Failure to appear"
            case .continuance: return "Motion to continue"
            case .bondModification: return "Bond motion"
            case .capacity: return "Capacity motion"
            case .pvAdmission: return "Probation violation admission"
            case .earlyTermination: return "Motion to end probation early"
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
}

struct CalendarCall: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var matters: [CalendarMatter]
}

enum CalendarCalls {

    private static let pleaLaws = ["felonyLarceny", "possSchedII", "breakingVehicle", "larcenyMerchant", "feloniousBE",
                                   "uttering", "pwisd", "commonLawRobbery", "possStolen", "strangulation", "awdwisi", "burglary2"]

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
                summary: "\(name), \(age), a \(occupation.lowercased()), offers to plead guilty to \(law.title) (\(cls.shortLabel)). Prior record: \(priorCount == 0 ? "none" : "\(priorCount) conviction\(priorCount == 1 ? "" : "s")").",
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
                    options: ["Issue an order for arrest and forfeit the bond", "Hold the matter open until the afternoon session", "Continue the case and send a new notice"]))
            case .continuance:
                matters.append(CalendarMatter(
                    kind: kind, personID: UUID(), personName: name, personAge: age, occupation: occupation, docket: d,
                    summary: "The defense moves to continue the trial of \(name) on \(law.title). It would be the \(rng.pick(["third", "fourth", "second"])) continuance.",
                    stateAsk: rng.pick(["The State objects. The victim has taken off work three times for this case.",
                                        "The State doesn't object, Judge."]),
                    defenseAsk: rng.pick(["We just received the lab report Friday. I can't effectively cross-examine the analyst without our own expert.",
                                          "I was appointed two weeks ago. Prior counsel withdrew. I haven't met my client in person yet."]),
                    options: ["Grant the continuance", "Deny; the case will be tried this session"]))
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
                    options: ["Order a forensic evaluation at Central Regional Hospital", "Order a local screening evaluation", "Find the defendant capable and proceed"]))
            default:
                break
            }
        }

        // A probationer from this court admits a technical violation.
        let probationers = people.filter { $0.status == .probation && $0.probation != nil && !excluding.contains($0.id) }
        let steady = probationers.filter { ($0.probation?.violationRisk ?? 0.2) < 0.25 }
        if let person = steady.isEmpty ? nil : rng.pick(steady), let term = person.probation, rng.chance(0.5) {
            let whose = term.imposedInThisCourt ? "You placed \(person.lastName) on probation." : (term.origin ?? "Sentenced in another court.")
            matters.append(CalendarMatter(
                kind: .earlyTermination, personID: person.id, personName: person.name, personAge: person.age(on: date),
                occupation: person.occupation, docket: term.docket,
                summary: "\(person.name) asks the court to end probation in \(term.docket) (\(term.offense)) early. \(whose) The probation officer reports every visit kept, clean drug screens, and steady work.",
                stateAsk: rng.pick(["The State takes no position.",
                                    "The State opposes. Restitution still isn't paid in full.",
                                    "The State doesn't object, provided all money owed is paid."]),
                defenseAsk: rng.pick(["My client has done everything asked. A new job requires travel that supervision makes impossible.",
                                      "Two-thirds of the term is served without a single violation. The goal of probation has been met.",
                                      "My client wants to move closer to family in another county and start over."]),
                options: ["Grant: probation ends successfully (G.S. 15A-1342(b))",
                          "Grant once all money owed is paid",
                          "Deny: probation continues as ordered"]))
        }
        if let person = probationers.isEmpty ? nil : rng.pick(probationers), let term = person.probation, rng.chance(0.6),
           !matters.contains(where: { $0.personID == person.id }) {
            matters.append(CalendarMatter(
                kind: .pvAdmission, personID: person.id, personName: person.name, personAge: person.age(on: date),
                occupation: person.occupation, docket: term.docket + " (PV)",
                summary: "\(person.name) admits missing two office visits and one drug screen while on probation in \(term.docket).",
                stateAsk: "The State asks for a two-day quick dip.",
                defenseAsk: "My client admits it and is back on track. We ask the court to continue probation.",
                options: ["Continue probation on the same terms", "Modify: add substance abuse treatment", "Order a two-day quick dip", "Order a CRV"]))
        }
        return CalendarCall(date: date, matters: matters)
    }

    struct Result {
        var lines: [String]
        var newPeople: [PersonRecord]
        var updates: [(UUID, (inout PersonRecord) -> Void)]
        var pending: [PendingEvent]
    }

    static func resolve(_ call: CalendarCall, choices: [UUID: Int], judgeName: String, county: County) -> Result {
        var rng = SeededRNG(seed: UInt64(truncatingIfNeeded: call.date.timeIntervalSince1970.bitPattern) ^ UInt64(call.matters.count))
        var lines: [String] = []
        var newPeople: [PersonRecord] = []
        var updates: [(UUID, (inout PersonRecord) -> Void)] = []
        var pending: [PendingEvent] = []
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
                                          background: "Pleaded guilty at a calendar call.", priors: m.priors,
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
                }
                person.priors.append(PriorConviction(offense: law.title, ncClass: cls, year: year, county: county.name,
                                                     sentence: sentence, fromThisCourt: true, docket: m.docket))
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
                updates.append((m.personID, { person in
                    guard let term = person.probation else { return }
                    person.probation = nil
                    person.status = .free
                    person.propensity = max(0.03, person.propensity * 0.85)
                    person.appearances.append(PersonRecord.Appearance(docket: term.docket, date: date, charges: "Motion to terminate probation early",
                                                                      outcome: choice == 1 ? "Granted on payment of all money owed: probation ended early"
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
                        term.crvCount = (term.crvCount ?? 0) + 1
                        person.status = .incarcerated
                        person.releaseDate = Calendar.current.date(byAdding: .day, value: term.isFelony ? 90 : min(90, max(1, term.activeMonths * 30)), to: date)
                    default:
                        break
                    }
                    person.probation = term
                    person.appearances.append(PersonRecord.Appearance(docket: m.docket, date: date, charges: "Probation violation (admitted)",
                                                                      outcome: "Calendar call: \(option)"))
                }))
            default:
                break
            }
        }
        return Result(lines: lines, newPeople: newPeople, updates: updates, pending: pending)
    }
}
