import Foundation

// Plays a Judge Sim career headlessly: every matter on every court day, decided the way a judge with the chosen
// temperament would, with each screen's substance written to a transcript and contradictions flagged as they happen.
//
//   Playtest [weeks] [style] [transcript path]
//   style: lenient | harsh | mixed (default mixed)

let args = CommandLine.arguments
let weeks = args.count > 1 ? Int(args[1]) ?? 8 : 8
let style = args.count > 2 ? args[2] : "mixed"
let outPath = args.count > 3 ? args[3] : "playtest.txt"

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
var hearingDates: [UUID: Date] = [:]

// MARK: - Trials

@MainActor func playTrial(_ c: CourtCase, resume: CaseSnapshot?) {
    guard let county = game.county else { return }
    let s = CaseSession(courtCase: c, judgeName: game.judgeName ?? "", county: county, resume: resume)
    let d = c.defendant
    log("TRIAL \(c.docket) · \(c.caption)")
    log("  Charges: " + c.charges.map { $0.law.title }.joined(separator: "; "))
    log("  Defendant: \(d.name), \(d.age), \(d.occupation); priors: \(d.priors.count); \(c.background?.bondStatus ?? "")")
    log("  Summary: \(c.summary)")
    checkText(c.summary + " " + c.charges.map { $0.law.title + ": " + $0.specification }.joined(separator: " "), where: "trial \(c.docket)")
    if s.continuanceMotionPending { s.denyContinuanceMotion(); log("  Continuance motion: denied") }
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
            s.advance()
        }
        if s.stage == .verdict {
            for ch in s.courtCase.charges where s.rulings.verdicts[ch.id] == nil {
                let options = s.verdictOptions(ch)
                let convict = rng.chance(convictRate)
                let pick: Verdict? = convict ? (options.contains(.lesser) && rng.chance(0.2) ? .lesser : options.first { $0.isConviction })
                                             : options.first { !$0.isConviction }
                s.rulings.verdicts[ch.id] = pick ?? options.first
            }
            log("  Verdicts: " + s.courtCase.charges.map { "\($0.law.title): \(s.rulings.verdicts[$0.id].map { "\($0)" } ?? "?")" }.joined(separator: "; "))
            s.advance()
        }
    }
    if s.stage == .sentencing {
        if s.needsHabitualDecision { s.setHabitual(rng.chance(0.6)) }
        for unit in s.units {
            var choice = Judgment.defaultChoice(for: unit)
            let allowed = unit.felonyCell?.dispositions ?? unit.misdemeanorCell?.dispositions ?? []
            let wantActive = style == "harsh" || (style == "mixed" && rng.chance(0.4))
            if !choice.lifeWithoutParole && !unit.isDWI {
                if wantActive, allowed.contains(.active) { choice.disposition = .active }
                else if allowed.contains(.community) { choice.disposition = .community }
                else if allowed.contains(.intermediate) { choice.disposition = .intermediate }
            }
            s.rulings.sentences[unit.id] = choice
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
        let pick = m.options.isEmpty ? 0 : rng.int(0...(m.options.count - 1))
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

// MARK: - The career

@MainActor func runCareer() {
    game = GameState()
    game.resetCareer()
    game.startCareer(name: "Morgan Hale", start: Date())
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
        game.acceptSuggestions(game.suggestedDates())
        game.adjourn()
        checkWorld()
    }

    let onProbation = game.people.filter { $0.status == .probation }.count
    log("")
    log("END \(short(game.currentDate)) · cases heard \(game.casesHeard) · on probation \(onProbation) · awaiting \(game.awaiting.count) · scheduled \(game.scheduled.count)")
    log("")
    log("BACKLOG BY MONTH")
    for b in backlog { log("  \(b)") }
    log("FINDINGS (\(findings.count))")
    for f in findings { log("- \(f)") }
    try? transcript.joined(separator: "\n").write(toFile: outPath, atomically: true, encoding: .utf8)
    print("Played \(weeks) weeks (\(style)). \(game.casesHeard) cases heard. \(findings.count) flags. Transcript: \(outPath)")
}

MainActor.assumeIsolated { runCareer() }
