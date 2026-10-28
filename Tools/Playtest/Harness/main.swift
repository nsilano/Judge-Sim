import Foundation

// Plays a Judge Sim career headlessly: every matter on every court day, decided the way a judge with the chosen
// temperament would, with each screen's substance written to a transcript and contradictions flagged as they happen.
//
//   Playtest [weeks] [style] [transcript path]
//   style: lenient | harsh | mixed (default mixed)

let args = CommandLine.arguments

// MARK: - Scan: build every written case and check all of its text

/// Every string inside a value, found by walking its fields.
func strings(in value: Any, into out: inout [String], depth: Int = 0) {
    guard depth < 12 else { return }
    if let s = value as? String { out.append(s); return }
    for child in Mirror(reflecting: value).children { strings(in: child.value, into: &out, depth: depth + 1) }
}

let firstSet = Set(NameBank.firstNames), lastSet = Set(NameBank.lastNames)
let namePattern = try! NSRegularExpression(pattern: "\\b([A-Z][a-z]+) ([A-Z][a-z']+(?:-[A-Z][a-z]+)?)\\b")

/// Person names ("First Last") a text mentions, by the game's own name banks.
func names(in text: String) -> [String] {
    let ns = text as NSString
    return namePattern.matches(in: text, range: NSRange(location: 0, length: ns.length)).compactMap { m in
        let first = ns.substring(with: m.range(at: 1)), last = ns.substring(with: m.range(at: 2))
        return firstSet.contains(first) && lastSet.contains(last) ? "\(first) \(last)" : nil
    }
}

/// Testimony and exhibits must agree with the case: nobody is named who isn't part of it, and a victim who died
/// doesn't take the stand.
@MainActor func consistency(_ c: CourtCase, template t: CaseTemplate, county: County) {
    var known = Set<String>([c.defendant.name, c.prosecutor, c.defenseAttorney] + c.witnesses.map(\.name) + [c.victimName].compactMap { $0 })
    known.formUnion([county.districtAttorney, county.chiefPublicDefender, county.clerk, county.sheriff, county.policeChief])
    known.formUnion(county.assistantDAs + county.assistantPDs + county.privateCounsel + county.troopers)
    known.formUnion(county.detectives.map(\.name) + county.officers.map(\.name))
    known.formUnion(Gazetteer.regulars(for: county).values)
    known.formUnion(t.extras.values.flatMap { $0 })
    // The case file itself is the record of who is involved.
    var fileText = [c.summary] + c.charges.map(\.specification)
    strings(in: c.background as Any, into: &fileText)
    strings(in: c.investigation as Any, into: &fileText)
    fileText += c.evidence.map { $0.title + ". " + $0.detail }
    for text in fileText { known.formUnion(names(in: text)) }
    let knownLast = Set(known.compactMap { $0.split(separator: " ").last.map(String.init) })
    var testimony: [String] = []
    for w in c.witnesses { strings(in: w, into: &testimony) }
    for text in testimony {
        for name in names(in: text) where !known.contains(name) {
            let last = String(name.split(separator: " ").last ?? "")
            if !knownLast.contains(last) { flag("\(t.key): \"\(name)\" is named in testimony or an exhibit but isn't part of the case — \"\(text.prefix(110))\"") }
        }
    }
    // Clock times, dates, and dollar amounts in testimony should come from the case file.
    let file = fileText.joined(separator: " ")
    func minutes(_ t: String) -> Int? {
        let parts = t.lowercased().replacingOccurrences(of: ".", with: "").split(whereSeparator: { $0 == ":" || $0 == " " })
        guard parts.count >= 3, var h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
        if parts[2].hasPrefix("p") && h != 12 { h += 12 }
        if parts[2].hasPrefix("a") && h == 12 { h = 0 }
        return h * 60 + m
    }
    func matches(_ pattern: String, _ text: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = text as NSString
        return re.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { ns.substring(with: $0.range) }
    }
    let timeRE = #"\b\d{1,2}:\d{2} [ap]\.m\."#
    let fileTimes = matches(timeRE, file).compactMap(minutes)
    let months = "January|February|March|April|May|June|July|August|September|October|November|December"
    let fileDates = Set(matches("(\(months)) \\d{1,2}\\b", file))
    let money = #"\$[\d,]+"#
    let fileAmounts = matches(money, file).compactMap { Int($0.dropFirst().replacingOccurrences(of: ",", with: "")) }
    for text in testimony {
        if !fileTimes.isEmpty {
            for tm in matches(timeRE, text) {
                if let m = minutes(tm), !fileTimes.contains(where: { abs($0 - m) <= 120 || abs($0 - m) >= 1320 }) {
                    flag("\(t.key) [time]: testimony says \(tm), the file's times are \(matches(timeRE, file).prefix(4).joined(separator: ", ")) — \"\(text.prefix(100))\"")
                }
            }
        }
        if !fileDates.isEmpty {
            for d in matches("(\(months)) \\d{1,2}\\b", text) where !fileDates.contains(d) {
                flag("\(t.key) [date]: testimony says \(d), not a date in the file — \"\(text.prefix(100))\"")
            }
        }
        for a in matches(money, text) {
            guard let v = Int(a.dropFirst().replacingOccurrences(of: ",", with: "")), v >= 500, !fileAmounts.isEmpty else { continue }
            if !fileAmounts.contains(where: { abs(Double($0 - v)) <= Double(max($0, v)) * 0.15 }) && !fileAmounts.contains(where: { $0 > v * 2 }) {
                flag("\(t.key) [money]: testimony says \(a), the file's amounts are \(matches(money, file).prefix(4).joined(separator: ", ")) — \"\(text.prefix(100))\"")
            }
        }
    }
    if Consequences.victimDied(c), let v = c.victimName, c.witnesses.contains(where: { $0.name == v }) {
        flag("\(t.key): the victim died but \(v) testifies")
    }
    if c.witnesses.contains(where: { $0.name == c.defendant.name && $0.isDefendant != true }) {
        flag("\(t.key): the defendant is listed as an ordinary witness")
    }
}

@MainActor func scanAll() {
    let county = County.generate(seed: 42)
    var flagged = 0
    var total = 0
    var qa = 0
    let templates = Array(CaseTemplates.byKey.values).sorted { $0.key < $1.key }
    for t in templates {
        for seed in [UInt64(7), 99, 1234, 5150] {
            var rng = SeededRNG(seed: seed)
            let ctx = CaseGenerator.Context(county: county, judgeName: "Morgan Hale", date: Date(), docketSequence: 2000, recentTemplateKeys: [])
            let c = CaseGenerator.build(t, seed: seed, band: .strong, context: ctx, rng: &rng)
            var texts: [String] = []
            strings(in: c, into: &texts)
            total += texts.count
            consistency(c, template: t, county: county)
            qa += texts.filter { $0.hasPrefix("\"") }.count
            for text in texts where text.count > 8 {
                let before = findings.count
                checkText(text, where: t.key)
                if findings.count > before { flagged += 1 }
            }
        }
    }
    // The news that follows each written case, filled the way the game fills it.
    var beatCount = 0
    for (key, beats) in StoryAftermath.beats {
        for beat in beats {
            beatCount += 1
            var text = (beat.headline + " " + beat.body).replacingOccurrences(of: "{D}", with: "Pat Doe").replacingOccurrences(of: "{DL}", with: "Doe")
                .replacingOccurrences(of: "{JUDGE}", with: "Hale").replacingOccurrences(of: "{V}", with: "Sam Roe").replacingOccurrences(of: "{VL}", with: "Roe")
            for (k, v) in Gender.male.tokens(for: "D") { text = text.replacingOccurrences(of: "{\(k)}", with: v) }
            for (k, v) in Gender.female.tokens(for: "V") { text = text.replacingOccurrences(of: "{\(k)}", with: v) }
            checkText(text, where: "aftermath \(key)")
        }
    }
    print("Scanned \(beatCount) news follow-ups.")
    chainCheck(county: county)
    print("Scanned \(templates.count) cases, \(total) text fields (\(qa) quoted answers). \(findings.count) flags.")
    for f in Set(findings).sorted() { print("- " + f) }
}

/// Builds each written case, then each follow-up the news can bring back, for the same person, the way the game does,
/// and checks that the second case is about the same person and the right earlier case.
@MainActor func chainCheck(county: County) {
    var chains = 0
    var samples: [String] = []
    let cal = CourtCalendar.calendar
    for (key, beats) in StoryAftermath.beats.sorted(by: { $0.key < $1.key }) {
        for beat in beats where !beat.followUps.isEmpty {
            for seed in [UInt64(11), 202, 3003] {
                let start = cal.date(from: DateComponents(year: 2027, month: 3, day: 10)) ?? Date()
                let ctx = CaseGenerator.Context(county: county, judgeName: "Morgan Hale", date: start, docketSequence: 3000, recentTemplateKeys: [])
                guard let t = CaseTemplates.byKey[key] else { findings.append("chain \(key): no such written case"); continue }
                var trng = SeededRNG(seed: seed)
                let c = CaseGenerator.build(t, seed: seed, band: .strong, context: ctx, rng: &trng)
                guard c.templateKey == key else { findings.append("chain \(key): the original case itself came out as \(c.templateKey)"); continue }
                let d = c.defendant
                let person = PersonRecord(id: d.personID, name: d.name, birthYear: cal.component(.year, from: start) - d.age,
                                          occupation: d.occupation, background: d.background, priors: d.priors,
                                          releaseDate: nil, probation: nil, propensity: 0.5, profile: d.profile)
                let later = cal.date(byAdding: .day, value: 200, to: start) ?? start
                var next = CaseGenerator.Context(county: county, judgeName: "Morgan Hale", date: later, docketSequence: 3100,
                                                 recentTemplateKeys: [key], returning: person, storySlot: false)
                next.forcedTemplateKeys = beat.followUps
                let carried = beat.sameVictim ? c.victimName : beat.victimRole.flatMap { role in c.witnesses.first { $0.role == role }?.name }
                next.victimOverride = carried
                next.priorOffense = c.charges.first?.law.title
                next.priorDate = start
                next.incidentDaysAgo = 60
                let f = CaseGenerator.generate(seed: seed &+ 1, context: next)
                chains += 1
                let tag = "chain \(key) -> \(f.templateKey)"
                if !beat.followUps.contains(f.templateKey) {
                    findings.append("\(tag): none of \(beat.followUps) fit a \(d.age)-year-old \(NameBank.gender(of: d.name)) defendant, so an unrelated case came instead")
                    continue
                }
                if f.defendant.name != d.name { findings.append("\(tag): defendant changed from \(d.name) to \(f.defendant.name)") }
                if f.defendant.personID != d.personID { findings.append("\(tag): defendant is a different person record") }
                if abs(f.defendant.age - d.age) > 1 { findings.append("\(tag): defendant was \(d.age), now \(f.defendant.age)") }
                var texts: [String] = []
                strings(in: f, into: &texts)
                let all = texts.joined(separator: "\n")
                if let prior = next.priorOffense, !all.lowercased().contains(prior.lowercased()) {
                    findings.append("\(tag): the follow-up never names the earlier offense (\(prior))")
                }
                if beat.victimRole != nil, f.victimName != carried {
                    findings.append("\(tag): the follow-up victim should be \(carried ?? "the original witness"), got \(f.victimName ?? "none")")
                }
                if let v = c.victimName {
                    if beat.sameVictim {
                        if f.victimName != v { findings.append("\(tag): should be the same victim \(v), got \(f.victimName ?? "none")") }
                    } else if all.contains(v) {
                        findings.append("\(tag): the earlier victim \(v) appears in a case about someone else")
                    }
                }
                // Anyone else from the first case (witnesses, officers) who turns up should be the same person in the same role.
                for w in c.witnesses where all.contains(w.name) && w.name != d.name && w.name != c.victimName {
                    if !f.witnesses.contains(where: { $0.name == w.name }) {
                        findings.append("\(tag): \(w.name) (\(w.role) in the first case) is mentioned but isn't part of the follow-up")
                    }
                }
                consistency(f, template: (FollowUpCases.all + CaseTemplates.all).first { $0.key == f.templateKey }!, county: county)
                for text in texts where text.count > 8 { checkText(text, where: tag) }
                if seed == 11 {
                    let first = c.summary.prefix(160)
                    samples.append("\(key) [\(d.name), \(d.age)]: \(first)...\n   -> \(f.templateKey) [\(f.defendant.name), \(f.defendant.age), victim \(f.victimName ?? "none")]: \(f.summary.prefix(260))...")
                }
            }
        }
    }
    print("Chained \(chains) original-to-follow-up cases.")
    try? samples.joined(separator: "\n\n").write(toFile: "/out/chains.txt", atomically: true, encoding: .utf8)
}

/// `Playtest loadsave <save file> <weeks> <transcript>` loads an older version's saved career first.
let loadSavePath: String? = args.count > 2 && args[1] == "loadsave" ? args[2] : nil
if let path = loadSavePath {
    guard let data = FileManager.default.contents(atPath: path) else { print("no save at \(path)"); exit(1) }
    UserDefaults.standard.set(data, forKey: "JudgeSim.nc.save.v1")
}
let shift = loadSavePath == nil ? 0 : 1
let weeks = args.count > 1 + 2 * shift ? Int(args[1 + 2 * shift]) ?? 8 : 8
let style = loadSavePath == nil && args.count > 2 ? args[2] : "mixed"
let outPath: String = {
    if loadSavePath != nil { return args.count > 4 ? args[4] : "playtest.txt" }
    if args.count > 2 && args[1] == "stories" { return args[2] }
    return args.count > 3 ? args[3] : "playtest.txt"
}()

var rng = SeededRNG(seed: UInt64(Date().timeIntervalSince1970))
var transcript: [String] = []
var findings: [String] = []

func log(_ line: String = "") { transcript.append(line) }
func flag(_ line: String) {
    findings.append(line)
    transcript.append("!! FLAG: " + line)
}
func short(_ date: Date) -> String { SentenceFormat.shortDate(date) }
func days(_ from: Date, _ to: Date) -> Int { CourtCalendar.calendar.dateComponents([.day], from: from, to: to).day ?? 0 }

/// How readily this judge convicts and how hard it sentences.
let convictRate = style == "lenient" ? 0.5 : (style == "harsh" ? 0.85 : 0.68)

nonisolated(unsafe) var game: GameState!

var seenNews = 0
var seenNewsKeys = Set<String>()
var backlog: [String] = []
var heardKeys = Set<String>()
var sameNameFlagged = Set<String>()
var contemptHeard = 0
var petitionsHeard: [String: Int] = [:]
var incidentsSeen: [String: Int] = [:]
var continuedIDs = Set<UUID>()
var hearingDates: [UUID: Date] = [:]

// MARK: - Trials

/// Rules on the courtroom incidents at one point in the case, the way a player might; true when the ruling sent the
/// case to another date.
@MainActor func ruleOnIncidents(_ s: CaseSession, _ moment: CourtIncident.Moment, _ c: CourtCase) -> Bool {
    for incident in s.incidents(at: moment) where s.rulings.choice(for: incident) == nil {
        let o = rng.pick(incident.options)
        s.chooseIncident(incident, o)
        incidentsSeen[incident.kind.rawValue, default: 0] += 1
        log("  Incident: \(incident.title) -> \(o.label)\(o.error ? " [appealable error]" : "")")
        checkText(incident.title + ". " + incident.body + " " + o.label + ". " + o.result, where: "incident \(c.docket)")
        if o.effect == .removeWitness, let id = o.witnessID, s.courtCase.witnesses.contains(where: { $0.id == id }) {
            flag("\(c.docket): the witness ruled out for lack of an interpreter is still in the case")
        }
    }
    if let pending = s.incidentContinuance {
        let to = CourtCalendar.calendar.date(byAdding: .day, value: pending.option.days ?? 28, to: game.currentDate) ?? game.currentDate
        log("  Continued for the incident to about \(short(to))")
        continuedIDs.insert(c.id)
        game.continueMatter(c.id, to: to, reason: "\(pending.incident.title): \(pending.option.label.lowercased()).",
                            snapshot: pending.option.effect == .mistrial ? nil : s.snapshot)
        return true
    }
    return false
}

@MainActor func playTrial(_ c: CourtCase, resume: CaseSnapshot?) {
    guard let county = game.county else { return }
    let s = CaseSession(courtCase: c, judgeName: game.judgeName ?? "", county: county, resume: resume)
    let d = c.defendant
    heardKeys.insert(c.templateKey)
    if let facts = c.investigation?.facts {
        for (place, closedOn) in Gazetteer.living.closed where closedOn != .distantPast && closedOn < facts.incident && facts.place.contains(place) {
            flag("\(c.docket): the crime happened at \(place), which closed on \(short(closedOn)), before the incident on \(short(facts.incident))")
        }
        let held = c.background?.custodyDays ?? 0
        if held > days(facts.incident, c.sessionDate) + 2 {
            flag("\(c.docket): \(held) days of jail credit, but the incident was only \(days(facts.incident, c.sessionDate)) days ago")
        }
    }
    for w in c.witnesses where game.residents.contains(where: { $0.name == w.name && $0.deceased }) {
        flag("\(c.docket): \(w.name) testifies, but the county remembers that person as deceased")
    }
    if let person = game.person(c.defendant.personID), abs(person.age(on: c.sessionDate) - c.defendant.age) > 1 {
        flag("\(c.docket): \(c.defendant.name) is \(c.defendant.age) in the case but \(person.age(on: c.sessionDate)) by the record")
    }
    if resume != nil { log("  (resumed after a continuance)") }
    continuedIDs.remove(c.id)
    log("TRIAL \(c.docket) · \(c.caption)")
    log("  Charges: " + c.charges.map { $0.law.title }.joined(separator: "; "))
    log("  Defendant: \(d.name), \(d.age), \(d.occupation); priors: \(d.priors.count); \(c.background?.bondStatus ?? "")")
    log("  Summary: \(c.summary)")
    checkText(c.summary + " " + c.charges.map { $0.law.title + ": " + $0.specification }.joined(separator: " "), where: "trial \(c.docket)")
    if s.continuanceMotionPending { s.denyContinuanceMotion(); log("  Continuance motion: denied") }
    if ruleOnIncidents(s, .beforeTrial, c) { return }
    if s.pleaPresented && rng.chance(0.6) {
        log("  Plea arrangement accepted: \(c.background?.arrangementTerms ?? "")")
        s.acceptPlea()
    } else {
        if s.pleaPresented { s.rejectPlea(); log("  Plea arrangement rejected") }
        s.advance() // briefing
        if s.stage == .motions {
            for m in c.motions { s.rulings.motions[m.id] = rng.chance(0.3) }
            s.advance()
        }
        if s.stage == .trial {
            for o in c.objections { s.rulings.objections[o.id] = rng.chance(0.5) }
            for ch in c.charges { s.rulings.halftime[ch.id] = rng.chance(0.1) ? .dismiss : .deny }
            s.adviseRightToTestify()
            for o in c.objections where s.rulings.objections[o.id] == nil { s.rulings.objections[o.id] = rng.chance(0.5) }
            if let ethics = c.ethics, let first = ethics.options.first { s.chooseEthics(first) }
            if ruleOnIncidents(s, .trial, c) { return }
            s.advance()
        }
        if s.stage == .verdict {
            for ch in s.courtCase.charges where s.rulings.verdicts[ch.id] == nil {
                let options = s.verdictOptions(ch)
                if options.contains(.insanity) && rng.chance(0.3) { s.rulings.verdicts[ch.id] = .insanity; log("  Verdict: not guilty by reason of insanity"); continue }
                let convict = rng.chance(convictRate)
                let pick: Verdict? = convict ? (options.contains(.lesser) && rng.chance(0.2) ? .lesser : options.first { $0.isConviction })
                                             : options.first { !$0.isConviction }
                s.rulings.verdicts[ch.id] = pick ?? options.first
            }
            log("  Verdicts: " + s.courtCase.charges.map { "\($0.law.title): \(s.rulings.verdicts[$0.id].map { "\($0)" } ?? "?")" }.joined(separator: "; "))
            s.advance()
        }
    }
    // Now and then the judge stops mid-trial and continues the case, the way a player might.
    if resume == nil && s.stage == .sentencing && rng.chance(0.06) {
        let to = CourtCalendar.calendar.date(byAdding: .day, value: 21, to: game.currentDate) ?? game.currentDate
        log("  Continued mid-trial to about \(short(to))")
        continuedIDs.insert(c.id)
        game.continueMatter(c.id, to: to, reason: "A witness is unavailable", snapshot: s.snapshot)
        return
    }
    if s.stage == .sentencing {
        _ = ruleOnIncidents(s, .sentencing, c)
        // The rarer forms of judgment, where the law allows them.
        if s.pjcAvailable && rng.chance(0.1) { s.rulings.special = .prayerForJudgment; log("  Form of judgment: PJC") }
        else if s.conditionalDischargeAvailable && rng.chance(0.15) { s.rulings.special = .conditionalDischarge; log("  Form of judgment: conditional discharge") }
        if s.needsHabitualDecision { s.setHabitual(rng.chance(0.6)) }
        // Protect the victim the way a judge often does: no contact as a condition, or a stand-alone stay-away order.
        if s.courtCase.victimName != nil && !Consequences.victimDied(s.courtCase) && !Consequences.victimIsChild(s.courtCase) {
            if rng.chance(0.5) { s.rulings.conditions.noContactVictim = true; log("  Condition: no contact with the victim") }
            if rng.chance(0.35) { s.rulings.stayAwayYears = rng.int(1...3); log("  Stay-away order: \(s.rulings.stayAwayYears) years") }
        }
        for unit in s.units {
            var choice = Judgment.defaultChoice(for: unit)
            if unit.isDWI { choice.dwiLevel = rng.int(1...5); log("  DWI level \(choice.dwiLevel ?? 0)") }
            let allowed = unit.felonyCell?.dispositions ?? unit.misdemeanorCell?.dispositions ?? []
            let wantActive = style == "harsh" || (style == "mixed" && rng.chance(0.4))
            if !choice.lifeWithoutParole && !unit.isDWI {
                if wantActive, allowed.contains(.active) { choice.disposition = .active }
                else if allowed.contains(.community) { choice.disposition = .community }
                else if allowed.contains(.intermediate) { choice.disposition = .intermediate }
            }
            s.rulings.sentences[unit.id] = choice
        }
        // Treatment court for some of those who stay out.
        if s.courtCase.defendant.background.isEmpty == false && rng.chance(0.15) {
            if TreatmentCourts.isVeteran(s.courtCase.defendant.background) { s.rulings.conditions.veteransTreatmentCourt = true; log("  Condition: Veterans Treatment Court") }
            else { s.rulings.conditions.drugTreatmentCourt = true; log("  Condition: Drug Treatment Court") }
        }
    }
    for _ in 0..<8 where s.stage != .judgment {
        if s.pendingPleaDeparture != nil { s.informDefendantOfDeparture() }
        s.advance()
    }
    guard let outcome = s.outcome else {
        flag("\(c.docket): trial never reached a judgment (stuck at \(s.stage))")
        return
    }
    for j in outcome.judgments { log("  [\(j.title)] " + j.lines.joined(separator: " | ")) }
    for r in outcome.reactions { log("  Reaction: \(r)") }
    log("  News: \(outcome.news.headline) — \(outcome.news.body)")
    for r in outcome.reactions { checkText(r, where: "reaction \(c.docket)") }
    // Time served must not read like a trip to prison.
    let released = outcome.judgments.contains { $0.lines.contains { $0.contains("credit satisfies") } }
    let newsText = (outcome.news.headline + " " + outcome.news.body + " " + outcome.reactions.joined(separator: " ")).lowercased()
    if released && outcome.custodyMonths == 0 && (newsText.contains("headed to prison") || newsText.contains("taken into custody") || newsText.contains("years? for this")) {
        flag("\(c.docket): jail credit satisfied the sentence, but the news or reactions describe going to prison")
    }
    if !outcome.convicted && (newsText.contains("sentenced") && !newsText.contains("not")) {
        flag("\(c.docket): acquittal/dismissal but news talks about a sentence")
    }
    game.complete(s.courtCase, outcome: outcome)
}

// MARK: - Violation hearings

@MainActor func playHearing(_ h: ViolationHearing) {
    guard let county = game.county else { return }
    log("HEARING \(h.probation.docket) · \(h.personName), \(h.personAge) · on probation for \(h.probation.offense)")
    for v in h.violations { log("  Violation: \(v)") }
    log("  Defense: \(h.defenseExplanation)")
    // A routine violation within 60 days of probation starting shouldn't happen.
    if let person = game.person(h.personID), let start = ViolationHearings.probationStart(person, h.probation),
       days(start, h.date) < 60, !h.newCriminalConduct {
        flag("\(h.personName) (\(h.probation.docket)): violation hearing \(days(start, h.date)) days after probation began")
    }
    if let person = game.person(h.personID), person.status != .probation, person.postRelease == nil {
        flag("\(h.personName): violation hearing, but the person's status is \(person.status)")
    }
    if h.violations.contains(where: { $0.contains("arrears on court-ordered payments") }) && (h.probation.monthlyObligation ?? 0) == 0 {
        flag("\(h.personName): violation for unpaid payments, but the judgment ordered no monthly payments")
    }
    let s = HearingSession(hearing: h, judgeName: game.judgeName ?? "", county: county)
    s.rulings.finding = rng.chance(0.75) ? .established : (rng.chance(0.5) ? .excused : .notProven)
    var decisions: [HearingDecision] = [.continueAsIs, .modify, .quickDip, .crv]
    if s.canRevoke { decisions.append(.revoke) }
    if style == "harsh" { decisions = s.canRevoke ? [.revoke, .crv] : [.crv, .quickDip] }
    if style == "lenient" { decisions = [.continueAsIs, .modify] }
    s.rulings.decision = s.rulings.finding == .established ? rng.pick(decisions) : .continueAsIs
    s.finish()
    guard let outcome = s.outcome else { flag("\(h.personName): hearing produced no outcome"); return }
    log("  Ruling: \(s.rulings.finding.map { "\($0)" } ?? "?") / \(s.rulings.decision.map { "\($0)" } ?? "?")")
    for line in outcome.lines { log("  \(line)") }
    game.completeHearing(h, outcome: outcome)
}

// MARK: - Calendar calls

@MainActor func playCalendar(_ call: CalendarCall) {
    log("CALENDAR CALL · \(call.matters.count) matters")
    var choices: [UUID: Int] = [:]
    var dates: [UUID: Date] = [:]
    for m in call.matters {
        let allowed = m.options.indices.filter { !(m.unavailableOptions ?? []).contains($0) }
        let pick = allowed.isEmpty ? 0 : rng.pick(allowed)
        choices[m.id] = pick
        log("  \(m.kind.label) · \(m.docket) · \(m.personName): \(m.summary)")
        checkText(m.summary + " " + m.stateAsk + " " + m.defenseAsk, where: "calendar \(m.docket)")
        log("    State: \(m.stateAsk)")
        log("    Defense: \(m.defenseAsk)")
        log("    Ruling: \(m.options.indices.contains(pick) ? m.options[pick] : "-")")
        if m.kind == .arraignment && pick == 0 {
            dates[m.id] = game.nextSittingDay(onOrAfter: CourtCalendar.calendar.date(byAdding: .day, value: 35, to: game.currentDate) ?? game.currentDate)
        }
        // A missed court date should be about a case that was due in court.
        if m.kind == .failureToAppear, let c = m.pendingCase,
           let set = game.scheduled.first(where: { if case .trial(let t) = $0.entry.matter { return t.id == c.id } else { return false } }),
           days(game.currentDate, set.date) > 14 {
            flag("\(m.docket): failure to appear on a case whose trial is \(days(game.currentDate, set.date)) days away")
        }
    }
    game.completeCalendar(call, choices: choices, dates: dates)
    for line in game.lastCalendarResults { log("  → \(line)") }
    // A petition's ruling shows up on the person's record, and a granted expunction clears the conviction.
    for m in call.matters where [.expunction, .bondForfeiture, .drivingPrivilege].contains(m.kind) {
        petitionsHeard[m.kind.label, default: 0] += 1
        guard let person = game.person(m.personID) else { flag("\(m.docket): petition for someone the court never recorded"); continue }
        if !person.appearances.contains(where: { $0.docket == m.docket }) { flag("\(m.docket): petition ruling missing from \(person.name)'s record") }
        if m.kind == .expunction, choices[m.id] == 0, let id = m.petition?.priorID, person.priors.contains(where: { $0.id == id }) {
            flag("\(m.docket): expunction granted but the conviction is still on \(person.name)'s record")
        }
    }
    for m in call.matters where m.kind == .treatmentReview || m.kind == .treatmentGraduation {
        petitionsHeard[m.kind.label, default: 0] += 1
        guard let person = game.person(m.personID) else { flag("\(m.docket): treatment review for someone with no record"); continue }
        if m.kind == .treatmentGraduation && choices[m.id] == 0 && person.probation != nil { flag("\(m.docket): graduated with probation ended, but \(person.name) is still on probation") }
        if m.kind == .treatmentReview && m.options.count == 4 && choices[m.id] == 3 {
            petitionsHeard["Treatment court terminations", default: 0] += 1
            if person.probation?.treatmentCourt != nil { flag("\(m.docket): terminated from treatment court but still in it") }
        }
    }
    // A contempt ruling has to take effect on the person: jail is jail, a finding of not willful leaves them free.
    for m in call.matters where m.kind == .contempt {
        contemptHeard += 1
        guard let person = game.person(m.personID) else { flag("\(m.docket): contempt hearing for someone with no record"); continue }
        let pick = choices[m.id] ?? 0
        if pick <= 1 && person.status != .incarcerated { flag("\(m.docket): contempt jail ordered, but \(person.name) is \(person.status)") }
        if pick >= 2 && person.status == .incarcerated && person.custodyDocket == m.docket { flag("\(m.docket): no jail ordered for contempt, but \(person.name) is held on it") }
    }
}

// MARK: - Text checks

/// Words repeated back to back ("Serious Injury with Intent to Kill Inflicting Serious Injury with Intent to Kill"),
/// unfilled tokens, and empty sentences.
func checkText(_ text: String, where place: String) {
    if text.contains("{") && text.contains("}") { flag("\(place): unfilled token in \"\(text.prefix(120))\"") }
    let words = text.split(separator: " ").map(String.init)
    if words.count >= 10 {
        // Three capitalized words in a row repeated ("Inflicting Serious Injury Inflicting Serious Injury") is a doubled title.
        for i in 0..<max(0, words.count - 5) where words[i].first?.isUppercase == true && words[i..<(i + 3)] == words[(i + 3)..<(i + 6)] {
            flag("\(place): repeated phrase \"\(words[i..<(i + 3)].joined(separator: " "))\""); return
        }
        for n in [6, 5, 4] {
            var i = 0
            while i + 2 * n <= words.count {
                if words[i..<(i + n)] == words[(i + n)..<(i + 2 * n)] || (i + 2 * n + 1 <= words.count && words[i..<(i + n)] == words[(i + n + 1)..<(i + 2 * n + 1)] && n >= 5) {
                    flag("\(place): repeated phrase \"\(words[i..<(i + n)].joined(separator: " "))\""); return
                }
                i += 1
            }
        }
    }
}

// MARK: - World checks after each day

@MainActor func checkWorld() {
    let now = game.currentDate
    // The game keeps only the latest stories, so track each one rather than counting.
    for item in game.news.filter({ !seenNewsKeys.contains($0.headline + "|" + short($0.date)) }).reversed() {
        seenNewsKeys.insert(item.headline + "|" + short(item.date))
        log("NEWS \(short(item.date)) · \(item.headline) — \(item.body)")
        if item.headline.contains("with no trial date"), let docket = item.docket {
            if let wait = game.awaiting.first(where: { $0.courtCase?.docket == docket }) {
                if days(max(wait.since, wait.earliest ?? wait.since), now) < 30 {
                    flag("\(docket): 'no trial date' story after only \(days(wait.since, now)) days on the list")
                }
            } else {
                flag("\(docket): 'no trial date' story, but the case isn't on the awaiting list")
            }
        }
        // A trial date announced in the past.
        if item.headline.hasPrefix("Trial date set"), let range = item.body.range(of: #"trial for \d{1,2} \w{3} \d{4}"#, options: .regularExpression) {
            let text = String(item.body[range]).replacingOccurrences(of: "trial for ", with: "")
            let f = DateFormatter(); f.dateFormat = "d MMM yyyy"; f.locale = Locale(identifier: "en_US")
            if let set = f.date(from: text), days(set, item.date) > 0 { flag("News on \(short(item.date)) announces a trial date already past: \(item.headline) (\(text))") }
        }
        checkText(item.headline + " — " + item.body, where: "news \(short(item.date))")
        let full = item.headline + " " + item.body
        // City police only work inside the city.
        if let r = full.range(of: #"Port Hollis Police Department (investigating|is asking)[^.]* in (Wexley|Cane Creek|Dunmore Mills|Bayard)"#, options: .regularExpression) {
            flag("City police outside the city: \(full[r].prefix(120))")
        }
        if full.lowercased().contains("murder") && full.contains("was released on bond") { flag("Murder arrest released on bond: \(item.headline)") }
        if item.headline.lowercased().contains("stretched thin") {
            let onProbation = game.people.filter { $0.status == .probation }.count
            if onProbation < 25 { flag("'Probation officers stretched thin' with only \(onProbation) on probation") }
        }
    }
    for order in game.arrestOrders where !order.served && order.servedOn > now {
        let entries = game.awaiting.map(\.entry) + game.scheduled.map(\.entry)
        for e in entries {
            if case .trial(let c) = e.matter, c.docket == order.docket, c.background?.bondStatus.hasPrefix("Arrested on the order") == true {
                flag("\(order.docket): order for arrest not yet served, but the case file says the defendant was arrested")
            }
        }
    }
    let cal = CourtCalendar.calendar
    for set in game.scheduled {
        let weekday = cal.component(.weekday, from: set.date)
        if !game.schedule.courtDays.contains(weekday) || CourtCalendar.holiday(on: set.date) != nil
            || game.schedule.timeOff.contains(CourtSchedule.key(set.date)) {
            flag("\(set.entry.title) set on \(short(set.date)), a day court doesn't sit (\(CourtCalendar.holiday(on: set.date) ?? "weekday off or time off"))")
        }
    }
    // Two different people never share a full name.
    var ids: [String: Set<UUID>] = [:]
    func note(_ name: String, _ id: UUID) { ids[name, default: []].insert(id) }
    game.people.forEach { note($0.name, $0.id) }
    var cases: [CourtCase] = game.investigations.map(\.courtCase) + game.bondQueue.map(\.courtCase)
    for entry in (game.today?.entries ?? []) + game.scheduled.map(\.entry) + game.awaiting.map(\.entry) {
        if case .trial(let c) = entry.matter { cases.append(c) }
        if case .calendar(let call) = entry.matter { cases += call.matters.compactMap(\.pendingCase) }
    }
    cases.forEach { note($0.defendant.name, $0.defendant.personID) }
    for (name, set) in ids where set.count > 1 && !sameNameFlagged.contains(name) {
        sameNameFlagged.insert(name)
        flag("two different defendants are both named \(name)")
    }
    for appeal in game.appeals {
        if let record = game.history.first(where: { $0.docket == appeal.docket && $0.resolvedKind == "trial" }),
           record.outcome.lowercased().contains("not guilty") || record.outcome.lowercased().contains("acquit"),
           !record.outcome.lowercased().replacingOccurrences(of: "not guilty", with: "").contains("guilty") {
            if !appeal.appellant.lowercased().contains("state") || !appeal.issue.lowercased().contains("suppress") {
                flag("\(appeal.docket): appeal by \(appeal.appellant) after an acquittal (\(record.outcome))")
            }
        }
    }
    for item in game.bondQueue where days(item.arrest, now) > 10 {
        flag("\(item.courtCase.defendant.name): arrested \(days(item.arrest, now)) days ago and still waiting for a bond hearing")
    }
    for p in game.people where p.status == .probation {
        if let term = p.probation, days(term.ends, now) > 7 {
            flag("\(p.name): still on probation \(days(term.ends, now)) days after it was due to end (\(term.docket))")
        }
        if p.probation == nil { flag("\(p.name): status is probation but no probation term on file") }
    }
    for p in game.people where p.status == .incarcerated {
        if let release = p.releaseDate, days(release, now) > 3 {
            flag("\(p.name): still shown incarcerated \(days(release, now)) days after the release date")
        }
    }
}

if args.count > 1 && args[1] == "scan" {
    MainActor.assumeIsolated { scanAll() }
    exit(0)
}

// MARK: - Every written case, tried once

/// Tries every written case in a fresh career, the ones a normal career rarely reaches included, with the same
/// checks as a career.
@MainActor func tryEveryStory() {
    game = GameState()
    game.resetCareer()
    game.startCareer(name: "Morgan Hale", start: Date())
    guard let county = game.county else { return }
    var tried = 0
    for (i, t) in StoryCases.all.enumerated() {
        var ctx = CaseGenerator.Context(county: county, judgeName: "Morgan Hale", date: game.currentDate, docketSequence: 5000 + i * 10,
                                        recentTemplateKeys: [])
        ctx.reservedNames = game.namesInPlay()
        var trng = SeededRNG(seed: UInt64(i) &* 7919 &+ 17)
        let c = CaseGenerator.build(t, seed: UInt64(i) &+ 1, band: rng.chance(0.5) ? .strong : .close, context: ctx, rng: &trng)
        log("")
        log("=== \(t.key) ===")
        playTrial(c, resume: nil)
        tried += 1
    }
    log("FINDINGS (\(findings.count))")
    for f in findings { log("- \(f)") }
    try? transcript.joined(separator: "\n").write(toFile: outPath, atomically: true, encoding: .utf8)
    print("Tried \(tried) written cases. \(findings.count) flags. Transcript: \(outPath)")
}

// MARK: - The career

@MainActor func runCareer() {
    game = GameState()
    if let savePath = loadSavePath {
        // An older version's saved career: it must load whole and keep playing.
        guard game.county != nil, game.judgeName != nil else { flag("the saved career at \(savePath) did not load"); finish(); return }
        log("LOADED older save: date \(short(game.currentDate)), people \(game.people.count), history \(game.history.count), scheduled \(game.scheduled.count), awaiting \(game.awaiting.count), news \(game.news.count)")
        if game.people.isEmpty || game.history.isEmpty { flag("the saved career loaded empty") }
    } else {
        game.resetCareer()
        game.startCareer(name: "Morgan Hale", start: Date())
    }
    log("CAREER START \(short(game.currentDate)) · style \(style) · \(weeks) weeks")

    let endDate = CourtCalendar.calendar.date(byAdding: .day, value: 7 * weeks, to: game.currentDate) ?? game.currentDate
    var guardDays = 0
    while game.currentDate < endDate && guardDays < weeks * 7 + 20 {
        guardDays += 1
        log("")
        log("=== \(short(game.currentDate)) ===")
        if let today = game.today {
            for entry in today.entries where entry.isOpen {
                switch game.open(entry.id) {
                case .trial(let c, let resume)?: playTrial(c, resume: resume)
                case .hearing(let h)?: playHearing(h)
                case .calendar(let call)?: playCalendar(call)
                case nil: break
                }
            }
        }
        if CourtCalendar.calendar.component(.day, from: game.currentDate) <= 7 && CourtCalendar.calendar.component(.weekday, from: game.currentDate) == 2 {
            let furthest = game.scheduled.map(\.date).max().map { days(game.currentDate, $0) } ?? 0
            backlog.append("\(short(game.currentDate)): waiting \(game.awaiting.count), on calendars \(game.scheduled.count), furthest setting \(furthest) days out")
        }
        // Every quarter the judge books a week off; now and then a case is reassigned to clear the list.
        if guardDays % 90 == 45 {
            let start = CourtCalendar.calendar.date(byAdding: .day, value: 14, to: game.currentDate) ?? game.currentDate
            let end = CourtCalendar.calendar.date(byAdding: .day, value: 4, to: start) ?? start
            game.bookTimeOff(from: start, to: end)
            log("TIME OFF booked \(short(start))–\(short(end))")
        }
        if guardDays % 28 == 14 {
            let pending = game.trialsInPipeline
            if pending > 80 && (game.schedule.intake ?? .full) == .full { game.setIntake(.light); log("INTAKE set to light at \(pending) pending") }
            else if pending < 40 && (game.schedule.intake ?? .full) != .full { game.setIntake(.full); log("INTAKE back to full at \(pending) pending") }
        }
        if guardDays % 7 == 3, rng.chance(0.3), let first = game.awaiting.first {
            log("REASSIGNED \(first.courtCase?.docket ?? "?") to another judge")
            game.reassign(awaitingID: first.id)
        }
        game.acceptSuggestions(game.suggestedDates())
        // Close and reopen the app every four weeks: the saved game must come back exactly as it was.
        if guardDays % 28 == 0 {
            func print(_ g: GameState) -> String {
                "date \(short(g.currentDate)), people \(g.people.count), awaiting \(g.awaiting.count), scheduled \(g.scheduled.count), bond \(g.bondQueue.count), investigations \(g.investigations.count), history \(g.history.count), news \(g.news.count), orders \(g.arrestOrders.count), today \(g.today?.entries.count ?? -1)"
            }
            let before = print(game)
            game = GameState()
            let after = print(game)
            if before != after { flag("Reload changed the game: before [\(before)] after [\(after)]") }
        }
        game.adjourn()
        checkWorld()
    }

    let onProbation = game.people.filter { $0.status == .probation }.count
    log("")
    log("END \(short(game.currentDate)) · cases heard \(game.casesHeard) · on probation \(onProbation) · awaiting \(game.awaiting.count) · scheduled \(game.scheduled.count)")
    log("")
    let stories = Set(StoryCases.all.map(\.key))
    log("WRITTEN CASES HEARD: \(heardKeys.intersection(stories).count) of \(stories.count)")
    log("  never came up: " + stories.subtracting(heardKeys).sorted().joined(separator: ", "))
    if !continuedIDs.isEmpty { flag("\(continuedIDs.count) trial(s) continued mid-trial never came back") }
    let orders = game.people.flatMap { $0.stayAwayOrders ?? [] }
    log("STAY-AWAY ORDERS: \(orders.count) issued, \(game.stats.orderViolations ?? 0) violations, \(contemptHeard) contempt hearings heard, \(game.showCauseQueue.count) waiting")
    log("PETITIONS: " + petitionsHeard.sorted { $0.key < $1.key }.map { "\($0.key) \($0.value)" }.joined(separator: ", "))
    log("INCIDENTS: " + incidentsSeen.sorted { $0.key < $1.key }.map { "\($0.key) \($0.value)" }.joined(separator: ", "))
    log("BACKLOG BY MONTH")
    for b in backlog { log("  \(b)") }
    finish()
}

@MainActor func finish() {
    log("FINDINGS (\(findings.count))")
    for f in findings { log("- \(f)") }
    try? transcript.joined(separator: "\n").write(toFile: outPath, atomically: true, encoding: .utf8)
    print("Played \(weeks) weeks (\(style)). \(game.casesHeard) cases heard. \(findings.count) flags. Transcript: \(outPath)")
}

if args.count > 1 && args[1] == "stories" {
    MainActor.assumeIsolated { tryEveryStory() }
    exit(0)
}
MainActor.assumeIsolated { runCareer() }
