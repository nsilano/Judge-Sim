import Foundation

/// Builds a fresh case from a template, the county's standing cast, and (sometimes) a returning defendant.
enum CaseGenerator {

    struct Context {
        let county: County
        let judgeName: String
        let date: Date
        let docketSequence: Int
        let recentTemplateKeys: [String]
        /// Scenario signatures already heard in this career, so no exact scenario repeats.
        var usedSignatures: Set<String> = []
        let returning: PersonRecord?
    }

    /// How strong the State's case should be, so that the evidence doesn't always point one way.
    private enum Band {
        case strong, close, weak
    }

    static func generate(seed: UInt64, context: Context) -> CourtCase {
        var rng = SeededRNG(seed: seed)
        var pool = CaseTemplates.all
        // Written cases come up first, until each has been heard once.
        let unheardStories = StoryCases.all.filter { story in !context.usedSignatures.contains { $0.hasPrefix(story.key + "|") } }
        if context.returning == nil, !unheardStories.isEmpty, rng.chance(0.6) {
            let story = rng.pick(unheardStories)
            return build(story, seed: seed, band: .close, context: context, rng: &rng)
        }
        // A written case is heard once per career, and only with a new defendant, whose history it describes.
        if context.returning == nil { pool += unheardStories }
        if let person = context.returning {
            let hasFelony = person.priors.contains { $0.ncClass.isFelony }
            let age = person.age(on: context.date)
            let fitting = pool.filter { template in
                template.occupations.isEmpty
                    && (!template.requiresFelonyPrior || hasFelony)
                    && template.forcedPriorOffenses.isEmpty
                    && age >= template.ageRange.lowerBound - 3 && age <= template.ageRange.upperBound + 8
            }
            if !fitting.isEmpty { pool = fitting }
        }

        // Serious felonies come up most; low-level cases still appear, but rarely.
        func weight(_ template: CaseTemplate) -> Double {
            switch LawLibrary.law(template.primaryLaw).ncClass {
            case .A?, .B1?, .B2?, .C?, .D?, .E?: return 5
            case .F?, .G?: return 3.5
            case .H?: return 2
            case .I?: return 1
            default: return 0.6
            }
        }
        // Rotate through the kinds of cases in proportion to their weight before any repeats.
        func uses(_ template: CaseTemplate) -> Int {
            context.usedSignatures.filter { $0.hasPrefix(template.key + "|") }.count
        }
        func score(_ template: CaseTemplate) -> Double { Double(uses(template) + 1) / weight(template) }
        let lowest = pool.map(score).min() ?? 0
        var choices = pool.filter { score($0) <= lowest + 0.0001 }
        let notRecent = choices.filter { !context.recentTemplateKeys.contains($0.key) }
        if !notRecent.isEmpty { choices = notRecent }
        let template = rng.pick(choices)

        let roll = Double.random(in: 0..<1, using: &rng)
        // Some cases are clear one way or the other; about half sit on the line.
        let band: Band = roll < 0.32 ? .strong : (roll < 0.82 ? .close : .weak)

        // Never repeat an exact scenario (same template, set-up, headline, and details).
        var fallback: CourtCase?
        var unheard: CourtCase?
        for _ in 0..<60 {
            let candidate = build(template, seed: seed, band: band, context: context, rng: &rng)
            let fresh = !context.usedSignatures.contains(candidate.scenarioSignature ?? "")
            if fresh && (matches(candidate, band: band) || template.story != nil) { return candidate }
            if fresh && unheard == nil { unheard = candidate }
            if fallback == nil { fallback = candidate }
        }
        return unheard ?? fallback!
    }

    private static func matches(_ courtCase: CourtCase, band: Band) -> Bool {
        guard let primary = courtCase.charges.first else { return true }
        let s = Judgment.properStrength(courtCase)
        let floor = primary.lesserLawID == nil ? primary.threshold : primary.lesserThreshold
        switch band {
        case .strong: return s >= primary.threshold + 3
        case .close: return s >= min(floor, primary.threshold - 1) && s <= primary.threshold + 1
        case .weak: return s <= floor - 3
        }
    }

    // MARK: - Assembly

    private static func build(_ t: CaseTemplate, seed: UInt64, band: Band, context: Context, rng: inout SeededRNG) -> CourtCase {
        let county = context.county
        let currentYear = Calendar.current.component(.year, from: context.date)

        var used = Set<String>()
        let castNames = [county.districtAttorney, county.chiefPublicDefender, county.clerk, county.sheriff, county.policeChief]
            + county.assistantDAs + county.assistantPDs + county.privateCounsel
            + county.detectives.map(\.name) + county.officers.map(\.name) + county.troopers
        for name in castNames {
            used.insert(name)
            used.insert(lastName(name))
        }

        // Defendant
        let defendant: Defendant
        if let person = context.returning {
            used.insert(person.name)
            used.insert(person.lastName)
            defendant = Defendant(personID: person.id, name: person.name, age: person.age(on: context.date),
                                  occupation: person.occupation, background: person.background, priors: person.priors,
                                  probation: person.status == .probation ? person.probation : nil,
                                  history: person.appearances)
        } else {
            let name = NameBank.person(using: &rng, excluding: &used)
            let age = rng.int(t.ageRange)
            let occupation = t.occupations.isEmpty ? rng.pick(NameBank.occupations) : rng.pick(t.occupations)
            // Written cases describe the defendant's record themselves; most say there is none.
            var priors = t.story != nil ? [] : randomPriors(age: age, year: currentYear, county: county, rng: &rng)
            for (offset, name) in t.forcedPriorOffenses.enumerated() {
                guard let seed = GenericPools.priorSeeds.first(where: { $0.offense == name }) else { continue }
                priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass,
                                              year: currentYear - 1 - offset * 2 - rng.int(0...1),
                                              county: rng.chance(0.6) ? county.name : rng.pick(GenericPools.otherCounties),
                                              sentence: rng.pick(seed.sentences)))
            }
            priors.sort { $0.year < $1.year }
            if t.requiresFelonyPrior && !priors.contains(where: { $0.ncClass.isFelony }) {
                priors.insert(PriorConviction(offense: "Possession of Stolen Goods", ncClass: .H, year: currentYear - 12,
                                              county: rng.pick(GenericPools.otherCounties),
                                              sentence: "6–17 months active"), at: 0)
            }
            let background = TextFiller(values: ["HOOD": rng.pick(county.towns)])(rng.pick(NameBank.backgrounds))
            defendant = Defendant(personID: UUID(), name: name, age: age, occupation: occupation.capitalizedFirst,
                                  background: background, priors: priors, probation: nil, history: [])
        }

        let victimName = t.hasVictim ? NameBank.person(using: &rng, excluding: &used) : nil
        let alternate = NameBank.person(using: &rng, excluding: &used)
        let setting = CaseSetting.of(category: t.category, key: t.key)
        // Highway crashes and impaired driving are worked by the Highway Patrol.
        let trooperName = rng.pick(county.troopers)
        let detective = setting == .road
            ? CastMember(name: trooperName, title: rng.pick(["Trooper", "Master Trooper", "Sergeant"]), agency: "N.C. State Highway Patrol")
            : rng.pick(county.detectives)
        let officer = setting == .road && rng.chance(0.5)
            ? CastMember(name: NameBank.person(using: &rng, excluding: &used), title: "Trooper", agency: "N.C. State Highway Patrol")
            : rng.pick(county.officers)
        // The day it happened, fixed once so every report, witness, and exhibit agrees.
        let incident = Calendar.current.date(byAdding: .day, value: -rng.int(150...330), to: context.date) ?? context.date
        let prosecutor = rng.pick(county.assistantDAs)
        let usePublicDefender = rng.chance(0.6)
        let defenseLawyer = usePublicDefender ? rng.pick(county.assistantPDs) : rng.pick(county.privateCounsel)

        var values: [String: String] = [
            "D": defendant.name,
            "DL": defendant.lastName,
            "DA": "\(defendant.age)",
            "DO": defendant.occupation.lowercased(),
            "DET": detective.display,
            "OFF": officer.display,
            "TROOPER": setting == .road ? detective.display : "Trooper \(trooperName)",
            "ALT": alternate,
            "PROS": prosecutor,
            "DEF": defenseLawyer,
            "ELECTEDDA": county.districtAttorney,
            "SHERIFF": county.sheriff,
            "JUDGE": lastName(context.judgeName),
            "STREET": rng.pick(NameBank.streets),
            "TIME": rng.pick(NameBank.times),
            "DATE": CaseDates.day(incident),
            "HOOD": rng.pick(county.towns),
            "CITY": county.seat,
            "V": victimName ?? "the complainant",
            "VL": victimName.map(lastName) ?? "the complainant"
        ]
        for key in t.extras.keys.sorted() {
            if let options = t.extras[key] { values[key] = rng.pick(options) }
        }
        let fill = TextFiller(values: values)

        // Charges
        var charges = [Charge(count: 1, lawID: t.primaryLaw, lesserLawID: t.lesserLaw,
                              specification: fill(t.specification), threshold: t.threshold,
                              lesserThreshold: t.lesserThreshold)]
        for extra in t.secondary where rng.chance(extra.chance) {
            let threshold = extra.threshold == 0 ? t.threshold : extra.threshold
            charges.append(Charge(count: charges.count + 1, lawID: extra.lawID, lesserLawID: nil,
                                  specification: fill(extra.specification), threshold: threshold,
                                  lesserThreshold: threshold))
        }
        // Extra counts the facts support
        let addOns = CaseComplexity.pickAddOns(for: t, hasFelonyPrior: defendant.priors.contains { $0.ncClass.isFelony },
                                               existing: Set(charges.map(\.lawID)), rng: &rng).filter { _ in t.story == nil }

        // Sometimes the State indicts a whole series of incidents: a big case with 7 to 9 counts.
        var seriesCount = 0
        let seriesCategories: Set<LawCategory> = [.property, .drugs, .whiteCollar, .cyber]
        if t.story == nil && seriesCategories.contains(t.category) && rng.chance(0.22) {
            let target = rng.int(7...9)
            let extraIncidents = max(2, target - charges.count - addOns.count)
            seriesCount = extraIncidents + 1
            charges[0].specification += " (Incident 1 of \(seriesCount).)"
            var day = incident
            for index in 2...seriesCount {
                day = Calendar.current.date(byAdding: .day, value: rng.int(9...40), to: day) ?? day
                let when = day.formatted(.dateTime.month(.wide).day().year())
                let threshold = max(3, t.threshold + rng.int(-1...1))
                let lesserThreshold = max(3, t.lesserThreshold + rng.int(-1...1))
                charges.append(Charge(count: charges.count + 1, lawID: t.primaryLaw, lesserLawID: t.lesserLaw,
                                      specification: "A separate incident on or about \(when), of the same kind as Count 1. (Incident \(index) of \(seriesCount).)",
                                      threshold: threshold, lesserThreshold: lesserThreshold))
            }
        }
        for addOn in addOns {
            let threshold = max(3, t.threshold + addOn.thresholdDelta)
            charges.append(Charge(count: charges.count + 1, lawID: addOn.lawID, lesserLawID: nil,
                                  specification: fill(addOn.specification), threshold: threshold, lesserThreshold: threshold))
        }
        let isFelonyCase = charges.contains { $0.law.ncClass?.isFelony ?? false }
        let court: CourtKind = isFelonyCase ? .felony : .misdemeanorAppeal

        // Evidence
        let prosecutionCount = t.story != nil ? t.prosecutionEvidence.count : min(t.prosecutionEvidence.count, band == .weak ? rng.int(2...3) : (band == .strong ? rng.int(4...5) : rng.int(3...4)))
        let defenseCount = t.story != nil ? t.defenseEvidence.count : min(t.defenseEvidence.count, band == .weak ? rng.int(2...3) : (band == .strong ? rng.int(0...1) : 2))
        var prosecutionSeeds = rng.pick(t.prosecutionEvidence, count: prosecutionCount) + addOns.map(\.evidence)
        var defenseSeeds = rng.pick(t.defenseEvidence, count: defenseCount)
        if seriesCount > 0 {
            prosecutionSeeds.append(EvidenceSeed(.document, 2, "Pattern Chart",
                                                 "A chart the lead investigator prepared, linking \(seriesCount) separate incidents to {DL} by date, method, and location. Some links are stronger than others."))
            defenseSeeds.append(EvidenceSeed(.document, 2, "Gaps in the Pattern",
                                             "For several of the \(seriesCount) incidents, the State has no witness, no video, and no physical evidence tying {DL} to that date."))
        }
        if band == .close && t.story == nil {
            // A case on the line pulls both ways: something real for each side.
            for complication in CaseComplexity.pickComplications(for: t, rng: &rng) {
                if complication.side == .prosecution { prosecutionSeeds.append(complication.evidence) } else { defenseSeeds.append(complication.evidence) }
            }
        }

        var evidence: [Evidence] = []
        var searchable: [(UUID, EvidenceKind, SearchPlace)] = []
        var statements: [UUID] = []
        for (index, item) in prosecutionSeeds.enumerated() {
            let exhibit = Evidence(exhibit: "State's Exhibit \(index + 1)", title: fill(item.title), detail: fill(item.detail),
                                   side: .prosecution, kind: item.kind, weight: item.weight)
            evidence.append(exhibit)
            switch item.acquisition {
            case .search: searchable.append((exhibit.id, item.kind, SearchPlace.infer(exhibit.title + " " + exhibit.detail, kind: item.kind)))
            case .statement: statements.append(exhibit.id)
            case .none: break
            }
        }
        for (index, item) in defenseSeeds.enumerated() {
            evidence.append(Evidence(exhibit: "Defendant's Exhibit \(index + 1)", title: fill(item.title),
                                     detail: fill(item.detail), side: .defense, kind: item.kind, weight: item.weight))
        }

        // Witnesses
        var witnesses: [Witness] = []
        if t.story != nil {
            // A written case calls every witness, in order, exactly as written.
            for item in t.prosecutionWitnesses {
                witnesses.append(makeWitness(item, side: .prosecution, fill: fill, rng: &rng, used: &used, impeach: false))
            }
            for item in t.defenseWitnesses {
                witnesses.append(makeWitness(item, side: .defense, fill: fill, rng: &rng, used: &used, impeach: false))
            }
        }
        let prosecutionWitnessCount = t.story != nil ? 0 : min(t.prosecutionWitnesses.count, rng.int(1...2))
        for item in rng.pick(t.prosecutionWitnesses, count: prosecutionWitnessCount) {
            witnesses.append(makeWitness(item, side: .prosecution, fill: fill, rng: &rng, used: &used))
        }
        if t.story == nil && !t.defenseWitnesses.isEmpty && (band != .strong || rng.chance(0.3)) {
            witnesses.append(makeWitness(rng.pick(t.defenseWitnesses), side: .defense, fill: fill, rng: &rng, used: &used))
        }

        // The investigation file and fact sheet come first: every generated witness reads from them.
        var profiledDefendant = defendant
        profiledDefendant.profile = DefendantProfiles.make(for: defendant, county: county)
        let factText = (t.summaries.map { fill($0) } + charges.map(\.specification) + evidence.map { $0.title + ". " + $0.detail }
                        + witnesses.flatMap { $0.direct + $0.cross }).joined(separator: " ")
        let facts = CaseFacts(key: t.key, category: t.category, hasVictim: t.hasVictim, text: factText)
        var (investigation, gaps) = Investigations.make(t: t, facts: facts, values: values, incident: incident, sessionDate: context.date,
                                                        detective: detective, officer: officer, evidence: evidence,
                                                        defendant: profiledDefendant, charges: charges, victimName: victimName,
                                                        year: currentYear, rng: &rng)
        let sheet = investigation.facts ?? CaseFactSheet(setting: setting, incident: incident, time: values["TIME"],
                                                         place: values["STREET"] ?? "", street: values["STREET"] ?? "",
                                                         town: values["HOOD"] ?? county.seat, arrivalTime: nil, assigned: incident,
                                                         arrest: incident, interview: nil, labSubmitted: nil, labReturned: nil,
                                                         agency: detective.agency, lead: detective.display, firstOfficer: officer.display)
        let testimonyContext = Testimony.Context(facts: facts, sheet: sheet, report: investigation, gaps: gaps, evidence: evidence,
                                                 charges: charges, defendant: profiledDefendant, victim: victimName, values: values,
                                                 defenseTheory: fill(rng.pick(t.defenseTheory)))
        for index in witnesses.indices where witnesses[index].exchanges == nil {
            witnesses[index].exchanges = Testimony.examination(for: witnesses[index], isVictim: witnesses[index].name == victimName,
                                                               ctx: testimonyContext, impeachment: nil,
                                                               timingSlip: witnesses[index].lay == true && rng.chance(0.3), rng: &rng)
        }
        let roles = witnesses.map { $0.role.lowercased() }
        var added: [Witness] = []
        if t.story == nil && !roles.contains(where: { $0.contains("detective") || $0.contains("investigator") || $0.contains("agent") || $0.contains("trooper") }) {
            added.append(Testimony.leadInvestigator(name: detective.display, agency: detective.agency, ctx: testimonyContext,
                                                    madeTheStop: facts.origin == .stop && rng.chance(0.5), rng: &rng))
        }
        if t.story == nil && setting != .paper && !roles.contains(where: { $0.contains("officer") || $0.contains("deputy") }) && rng.chance(0.65) {
            added.append(Testimony.firstOfficer(name: officer.display, agency: officer.agency, ctx: testimonyContext, rng: &rng))
        }
        if t.story == nil && !roles.contains(where: { $0.contains("analyst") || $0.contains("examiner") || $0.contains("scientist") || $0.contains("chemist") }) {
            let names = (0..<3).map { _ in NameBank.person(using: &rng, excluding: &used) }
            added += Testimony.analysts(ctx: testimonyContext, names: names, rng: &rng)
        }
        if t.story == nil && rng.chance(0.55) {
            added.append(Testimony.characterWitness(name: NameBank.person(using: &rng, excluding: &used), ctx: testimonyContext, rng: &rng))
        }
        // State witnesses first, then the defense's.
        witnesses = added.filter { $0.calledBy == .prosecution } + witnesses.filter { $0.calledBy == .prosecution }
            + witnesses.filter { $0.calledBy == .defense } + added.filter { $0.calledBy == .defense }
        investigation.interviews = witnesses.filter { $0.isDefendant != true && !$0.role.contains("State Crime Laboratory") }
            .map { "\($0.name), \($0.role.lowercased())" } + [investigation.interviews.last ?? ""]

        // Objections, built from each witness and the facts of this case
        var objections: [Objection] = []
        if let story = t.story {
            for (index, seed) in story.objections where witnesses.indices.contains(index) {
                objections.append(Objection(witnessID: witnesses[index].id, question: fill(seed.question), answer: fill(seed.answer),
                                            raisedBy: seed.raisedBy, grounds: seed.grounds, shouldSustain: seed.shouldSustain,
                                            appellateNote: fill(seed.explanation), doctrineID: seed.doctrineID, weightIfAdmitted: seed.weight))
            }
            investigation.timeline = story.timeline.map { offset, what in
                InvestigationReport.Entry(when: CaseDates.dayYear(CaseDates.add(offset, to: incident)), what: fill(what))
            }
            investigation.howIdentified = fill(story.howIdentified)
            investigation.notDone = story.notDone.map { fill($0) }
        } else {
            for witness in witnesses where rng.chance(0.55) {
                if let objection = ObjectionEngine.make(for: witness, ctx: testimonyContext, rng: &rng) { objections.append(objection) }
            }
        }

        // Motions
        var motions: [Motion] = []
        if t.story == nil && !searchable.isEmpty && rng.chance(0.6) {
            let target = rng.pick(searchable)
            let fitting = GenericPools.suppressSearchSeeds.filter {
                ($0.kinds.isEmpty || $0.kinds.contains(target.1)) && ($0.places.isEmpty || $0.places.contains(target.2))
            }
            let wantGrant = rng.chance(0.45)
            let preferred = fitting.filter { $0.shouldGrant == wantGrant }
            let pool = preferred.isEmpty ? fitting : preferred
            if !pool.isEmpty {
                let option = rng.pick(pool)
                let title = evidence.first { $0.id == target.0 }?.title ?? "the evidence"
                motions.append(makeMotion(option, target: target.0, targetTitle: title, fill: fill))
            }
        }
        if t.story == nil && !statements.isEmpty && rng.chance(0.55) {
            let target = rng.pick(statements)
            let option = rng.pick(GenericPools.suppressStatementSeeds)
            let title = evidence.first { $0.id == target }?.title ?? "the statement"
            motions.append(makeMotion(option, target: target, targetTitle: title, fill: fill))
        }
        if t.story == nil && rng.chance(0.07) {
            motions.append(makeMotion(rng.pick(GenericPools.speedyTrialSeeds), target: nil, targetTitle: nil, fill: fill))
        }

        // Status and procedural posture
        let priorFelonies = defendant.priors.filter { $0.ncClass.isFelony }.count
        let habitual = isFelonyCase && priorFelonies >= 3 && t.primaryLaw != "murder1" && rng.chance(0.65)
        var notes: [String] = []
        if isFelonyCase {
            if t.primaryLaw == "murder1" {
                notes.append("The State has declared this a non-capital case, so a jury may be waived. Bench trials for first-degree murder are rare in North Carolina; the defense requested one and you consented after hearing from the State.")
            }
            notes.append("The defendant waived the right to trial by jury in writing (N.C. Const. art. I, § 24). After hearing from the State, you consented on the record.")
        } else {
            notes.append("The defendant was convicted in Hollis County District Court and appealed for a trial de novo in Superior Court, then waived a jury. You hear the case fresh; the district court's verdict carries no weight.")
        }
        if habitual {
            notes.append("The defendant has also been indicted as a habitual felon (G.S. 14-7.1), based on \(priorFelonies) prior felony convictions. If you convict on a felony, you will decide that status before sentencing.")
        }
        if let probation = defendant.probation {
            notes.append("When this offense allegedly occurred, the defendant was on probation in \(probation.docket) (\(probation.offense)), with a suspended sentence of \(probation.suspendedSentence). A probation violation report alleging a new criminal offense has been filed.")
        }

        // Factors, twists, community mood
        let aggravatingCount = rng.int(1...2)
        let mitigatingCount = rng.int(1...2)
        let hasPriors = !defendant.priors.isEmpty
        let aboutRecord: (String) -> Bool = { text in
            let l = text.lowercased()
            return l.contains("record") || l.hasPrefix("prior") || l.contains("first offense") || l.contains("first-time")
        }
        let aggravatingPool = t.aggravating.filter { hasPriors || !aboutRecord($0) }
        let mitigatingPool = t.mitigating.filter { !hasPriors || !aboutRecord($0) }
        var aggravating = fill(rng.pick(aggravatingPool.isEmpty ? t.aggravating : aggravatingPool, count: aggravatingCount))
        var mitigating = fill(rng.pick(mitigatingPool.isEmpty ? t.mitigating : mitigatingPool, count: mitigatingCount))
        if !hasPriors {
            aggravating.removeAll(where: aboutRecord)
            if !mitigating.contains(where: aboutRecord) {
                mitigating.append("The defendant has no prior criminal record")
            }
        } else {
            mitigating.removeAll(where: aboutRecord)
        }
        if !defendant.occupation.lowercased().contains("unemployed") && rng.chance(0.5) {
            mitigating.append("The defendant has a positive employment history and is gainfully employed")
        }
        var mood = rng.pick(t.moods)
        var media = rng.int(1...2)
        var doctrines = t.doctrines
        var twistText: String?
        var twistKey: String?
        var chosenTwist: TwistSeed?
        let twistPool = GenericPools.twists.filter { $0.ages.contains(defendant.age) }
        if t.story == nil, rng.chance(0.5), !twistPool.isEmpty {
            let twist = rng.pick(twistPool)
            twistKey = twist.key
            chosenTwist = twist
            twistText = fill(twist.text)
            if let m = twist.mitigating { mitigating.append(fill(m)) }
            if let a = twist.aggravating { aggravating.append(fill(a)) }
            if let m = twist.mood { mood = m }
            media += twist.mediaBoost
            if let d = twist.doctrine { doctrines.append(d) }
        }
        if defendant.isReturning { media += 1 }
        media = min(3, max(1, media))
        doctrines.append(contentsOf: ["burdenOfProof", "juryWaiver", isFelonyCase ? "punishmentChart" : "misdemeanorSentencing", "aggravatingFactors"])

        // Ethics dilemma
        var ethics: EthicsEvent?
        if rng.chance(0.3) {
            var event = rng.pick(GenericPools.ethicsEvents(hasVictim: t.hasVictim, retainedCounsel: !usePublicDefender))
            event.body = fill(event.body)
            event.options = event.options.map { option in
                var o = option
                o.label = fill(o.label)
                o.result = fill(o.result)
                o.laterHeadline = o.laterHeadline.map { fill($0) }
                return o
            }
            ethics = event
        }

        // The hidden truth. Suppressed evidence still counts here: the truth doesn't care about the exclusionary rule.
        let rawStrength = evidence.reduce(0) { $0 + ($1.side == .prosecution ? $1.weight : -$1.weight) }
            + witnesses.reduce(0) { $0 + ($1.calledBy == .prosecution ? $1.weight : -$1.weight) }
        var guiltProbability = 0.5 + Double(rawStrength - t.threshold) * 0.08
        if let person = context.returning { guiltProbability += (person.propensity - 0.3) * 0.3 }
        guiltProbability = min(0.93, max(0.1, guiltProbability))
        let actuallyGuilty = rng.chance(guiltProbability)
        let truth = HiddenTruth(actuallyGuilty: actuallyGuilty,
                                revelation: fill(rng.pick(actuallyGuilty ? t.guiltyTruths : t.innocentTruths)))

        let summaryIndex = rng.int(0...(t.summaries.count - 1))
        let headlineIndex = rng.int(0...(t.headlines.count - 1))
        let extrasSignature = t.extras.keys.sorted().compactMap { values[$0] }.joined(separator: ",")
        let addOnSignature = addOns.map(\.lawID).joined(separator: ",") + (seriesCount > 0 ? ",x\(seriesCount)" : "")
        let signature = "\(t.key)|s\(summaryIndex)|h\(headlineIndex)|\(extrasSignature)" + (addOnSignature.isEmpty ? "" : "|+\(addOnSignature)")

        let yy = String(format: "%02d", currentYear % 100)
        let docket = "\(yy) \(isFelonyCase ? "CRS" : "CR") \(String(format: "%06d", context.docketSequence))"

        // What the defendant would say on the stand
        let strongestState = evidence.filter { $0.side == .prosecution }.max { $0.weight < $1.weight }
        let testimonyHolds = !actuallyGuilty || rng.chance(0.2)
        let testimony = Witness(
            name: defendant.name, role: "Defendant, testifying in their own defense", calledBy: .defense,
            direct: ["\(defendant.lastName) gives their account, consistent with the defense theory: " + fill(rng.pick(t.defenseTheory)),
                     rng.pick(["\"I want the court to hear it from me.\"",
                               "\"I've waited a long time to tell my side.\"",
                               "\"I'm not going to pretend I'm perfect. But I didn't do what they say.\""])],
            cross: testimonyHolds
                ? ["On cross, \(defendant.lastName) stays calm and consistent, and concedes only small details."]
                : ["On cross, \(defendant.lastName) has no explanation for \(strongestState.map { "\"\($0.title)\"" } ?? "the State's evidence") and contradicts an earlier statement."],
            weight: testimonyHolds ? 2 : -2,
            lay: true, isDefendant: true)
        var fullTestimony = testimony
        fullTestimony.exchanges = Testimony.defendant(testimony, ctx: testimonyContext, holds: testimonyHolds,
                                                      sessionDate: context.date, rng: &rng)
        if let story = t.story {
            fullTestimony.exchanges = story.defendantExam.map { line in
                TestimonyExchange(phase: line.phase, examiner: line.phase == .cross ? .prosecution : .defense,
                                  question: fill(line.question(0)), answer: fill(line.answer(0)))
            }
        }
        if let objection = rng.chance(0.4) ? ObjectionEngine.make(for: fullTestimony, ctx: testimonyContext, rng: &rng) : nil {
            objections.append(objection)
        }

        var background = makeBackground(t, defendant: defendant, charges: charges, values: values, mood: mood,
                                        publicDefender: usePublicDefender, mitigating: mitigating,
                                        isFelony: isFelonyCase, habitual: habitual, rng: &rng)
        if let twist = chosenTwist {
            if twist.trialOnly && background.arrangementPresented == true {
                twistText = nil
                if let a = twist.aggravating { aggravating.removeAll { $0 == fill(a) } }
            }
            if twistKey == "jailed" {
                background.custodyDays = 330
                background.bondStatus = "Held in the Hollis County jail on a $5,000 secured bond for 330 days."
            }
            if twistKey == "rehab" && background.custodyDays > 0 {
                background.custodyDays = 0
                background.bondStatus = "Released on a secured bond. Has made every court date."
            }
        }

        return CourtCase(
            seed: seed,
            templateKey: t.key,
            docket: docket,
            court: court,
            sessionDate: context.date,
            headline: fill(t.headlines[headlineIndex]),
            category: t.category,
            summary: fill(t.summaries[summaryIndex]),
            defendant: profiledDefendant,
            victimName: victimName,
            charges: charges,
            habitualIndicted: habitual,
            proceduralNotes: notes,
            motions: motions,
            prosecutor: "ADA \(prosecutor)",
            defenseAttorney: usePublicDefender ? "\(defenseLawyer), Assistant Public Defender" : "\(defenseLawyer), retained counsel",
            investigatingAgency: detective.agency,
            prosecutionOpening: fill(t.story?.prosecutionOpening ?? rng.pick(t.prosecutionTheory)),
            defenseOpening: fill(t.story?.defenseOpening ?? rng.pick(t.defenseTheory)),
            prosecutionClosing: fill(t.story?.prosecutionClosing ?? rng.pick(GenericPools.prosecutionClosings)),
            defenseClosing: fill(t.story?.defenseClosing ?? rng.pick(GenericPools.defenseClosings)),
            evidence: evidence,
            witnesses: witnesses,
            objections: objections,
            aggravating: aggravating,
            mitigating: mitigating,
            victimImpact: t.victimImpacts.isEmpty ? nil : fill(rng.pick(t.victimImpacts)),
            allocution: fill(rng.pick(t.allocutions + GenericPools.genericAllocutions)),
            twist: twistText,
            ethics: ethics,
            mood: mood,
            mediaAttention: media,
            truth: truth,
            relatedDoctrines: doctrines,
            background: background,
            scenarioSignature: signature,
            defendantTestimony: fullTestimony,
            investigation: investigation
        )
    }

    // MARK: - Background known to counsel

    private static func dollars(in text: String?) -> Int? {
        guard let text else { return nil }
        let lower = text.lowercased()
        let digits = lower.filter { $0.isNumber || $0 == "." }
        guard let value = Double(digits) else { return nil }
        if lower.contains("million") { return Int(value * 1_000_000) }
        return Int(value)
    }

    private static func makeBackground(_ t: CaseTemplate, defendant: Defendant, charges: [Charge], values: [String: String],
                                       mood: PublicMood, publicDefender: Bool, mitigating: [String], isFelony: Bool,
                                       habitual: Bool, rng: inout SeededRNG) -> CaseBackground {
        let fill = TextFiller(values: values)
        let primary = charges[0]

        // Plea negotiations
        var pleaOffer: String?
        var pleaRejection: String?
        if rng.chance(0.65) {
            if let lesser = primary.lesserLaw, let cls = lesser.ncClass {
                pleaOffer = rng.pick([
                    "Plead guilty to \(lesser.title) (\(cls.shortLabel)), remaining charges dismissed, sentencing in the court's discretion.",
                    "Plead guilty to \(lesser.title) (\(cls.shortLabel)) with a sentence at the bottom of the presumptive range."
                ])
            } else if isFelony {
                pleaOffer = rng.pick([
                    "Plead guilty as charged with a mitigated-range sentence, remaining charges dismissed.",
                    "Plead guilty as charged; the State would not oppose a suspended sentence."
                ])
            } else {
                pleaOffer = "Plead guilty and receive a prayer for judgment continued on payment of costs."
            }
            pleaRejection = rng.pick([
                "My client maintains their innocence, Judge. They won't plead to something they didn't do.",
                "Even the reduced charge carried a felony record, and that would end my client's career.",
                "We think the suppression issue is strong, and my client wanted it decided.",
                "My client has three kids at home. An active sentence wasn't something they could accept.",
                "My client was worried about immigration consequences of any conviction."
            ])
        }

        // Custody
        let inCustody = rng.chance(0.45)
        let custodyDays = inCustody ? rng.int(21...420) : 0
        let bond = rng.pick(["$2,500", "$10,000", "$25,000", "$50,000", "$100,000"])
        let bondStatus = inCustody
            ? "Held in the Hollis County jail on a \(bond) secured bond for \(custodyDays) days."
            : rng.pick(["Released on a \(bond) secured bond. Has made every court date.",
                        "Released on a written promise to appear, with electronic monitoring.",
                        "Released on a \(bond) secured bond; missed one court date early on, then was re-released."])

        // Restitution
        var restitution = 0
        var basis: String?
        switch t.key {
        case "storeRobbery":
            restitution = dollars(in: values["AMT"]) ?? 400; basis = "cash taken from the register"
        case "burglary":
            restitution = rng.int(3...16) * 1_000; basis = "unrecovered property and window repair"
        case "embezzlement", "elderScam":
            restitution = dollars(in: values["AMT"]) ?? 50_000; basis = "funds taken"
        case "ponzi":
            restitution = dollars(in: values["AMT"]) ?? 5_000_000; basis = "investor losses"
        case "insuranceArson":
            restitution = 640_000; basis = "insurer's payout exposure and the firefighter's medical bills"
        case "ransomware":
            restitution = rng.int(8...25) * 100_000; basis = "the hospital's recovery costs"
        case "barFight", "abusedSpouse", "poisoning", "drunkCrash", "overdose":
            restitution = rng.int(7...16) * 1_000; basis = "funeral expenses"
        case "protestAssault", "policeForce":
            restitution = rng.int(12...70) * 1_000; basis = "medical bills"
        case "imageLeak", "stalking":
            restitution = rng.int(2...9) * 500; basis = "counseling costs and lost wages"
        default:
            break
        }

        // Victim stance
        let stance: VictimStance
        let stanceDetail: String
        if t.hasVictim {
            switch mood {
            case .sympathetic:
                stance = rng.chance(0.6) ? .wantsLeniency : .wantsAccountability
            case .wantsConviction:
                stance = rng.chance(0.6) ? .wantsMaximum : .wantsAccountability
            default:
                stance = rng.pick([.wantsMaximum, .wantsAccountability, .wantsLeniency])
            }
            switch stance {
            case .wantsMaximum:
                stanceDetail = fill("I've spoken with {VL}'s family several times. They want the maximum, and they've asked to be notified of every hearing.")
            case .wantsAccountability:
                stanceDetail = fill("{VL}'s family wants accountability, Judge. They aren't asking for a specific number. Mostly they want this taken seriously.")
            case .wantsLeniency:
                stanceDetail = fill("This is unusual, but {VL}'s family has told me they don't want {DL} to go to prison. They want help for {DL}, not punishment.")
            case .none:
                stanceDetail = "There's no identified victim in this case."
            }
        } else {
            stance = .none
            stanceDetail = "There's no individual victim in this case, Judge."
        }

        // Treatment
        let need: TreatmentNeed
        if t.category == .drugs || t.key == "drunkCrash" {
            need = rng.chance(0.75) ? (rng.chance(0.2) ? .both : .substance) : .none
        } else if defendant.background.lowercased().contains("depression") || defendant.background.lowercased().contains("ptsd") {
            need = rng.chance(0.7) ? .mentalHealth : .both
        } else {
            let roll = Double.random(in: 0..<1, using: &rng)
            need = roll < 0.22 ? .substance : (roll < 0.36 ? .mentalHealth : (roll < 0.42 ? .both : .none))
        }
        let treatmentDetail: String?
        switch need {
        case .none: treatmentDetail = nil
        case .substance: treatmentDetail = rng.pick(["An opioid use disorder going back about six years.", "Alcohol, Judge. It's been the thread through everything.", "Methamphetamine use that started after a back injury at work."])
        case .mentalHealth: treatmentDetail = rng.pick(["Diagnosed bipolar disorder, untreated since losing Medicaid coverage.", "Severe depression, with one hospitalization last year.", "PTSD, documented by the VA."])
        case .both: treatmentDetail = "Co-occurring: a substance use disorder layered on untreated depression."
        }

        // Life circumstances
        let plan: String? = rng.chance(0.6) ? fill(rng.pick([
            "A job offer from a roofing company in {HOOD}, starting the Monday after sentencing.",
            "Return to the night shift at the distribution center. The manager wrote a letter.",
            "Enrollment in the welding program at Hollis Community College this spring.",
            "Moving in with an aunt in {HOOD}, away from the people involved in this case."
        ])) : nil
        let indigent = publicDefender ? rng.chance(0.85) : rng.chance(0.2)
        let support: String? = rng.chance(0.6) ? rng.pick([
            "My client's mother, two sisters, and their pastor are in the gallery today.",
            "A former employer drove in from Raleigh to be here.",
            "My client's partner is here with their two children.",
            "The client's grandmother, who raised them, is in the second row."
        ]) : nil
        let discovery: String? = rng.chance(0.25) ? rng.pick([
            "The State Crime Laboratory report arrived late; we turned it over nine days before trial.",
            "A supplemental police report surfaced last week and was disclosed immediately.",
            "Body camera footage from a second officer was located and disclosed on Friday."
        ]) : nil

        let hiddenMitigatorPool = [
            "The defendant voluntarily acknowledged wrongdoing at an early stage of the criminal process",
            "The defendant supports the defendant's family",
            "The defendant has been a person of good character or has had a good reputation in the community",
            "The defendant has successfully completed a substance abuse program while in custody",
            "The defendant was suffering from a mental condition that significantly reduced culpability"
        ].filter { !mitigating.contains($0) }
        let hiddenAggravatorPool = [
            "The defendant committed the offense while on pretrial release on another charge",
            "The defendant attempted to contact a State's witness from the jail",
            "The defendant has been found in willful violation of probation within the past 10 years"
        ]

        let violent = t.category == .violent || t.category == .robbery

        // Sometimes the parties reach a deal and present it to the court before trial.
        var arrangementPresented = false
        var arrangementLawID: String?
        var arrangementTerms: String?
        var arrangementHabitual: Bool?
        var arrangementKind: String?
        // A written case is meant to be tried, so it never arrives as a negotiated plea.
        if t.story == nil && pleaOffer != nil && rng.chance(0.3) {
            arrangementPresented = true
            let pleaLaw = primary.lesserLaw ?? primary.law
            arrangementLawID = pleaLaw.id
            let pleaFelony = pleaLaw.ncClass?.isFelony ?? false
            var dismissed = charges.count > 1 ? " The State will dismiss the remaining counts." : ""
            if habitual {
                if pleaFelony && rng.chance(0.5) {
                    arrangementHabitual = true
                    dismissed += " The defendant admits habitual felon status and will be sentenced as a habitual felon."
                } else {
                    arrangementHabitual = false
                    dismissed += " The State will dismiss the habitual felon indictment."
                }
            }
            let probationTerms = restitution > 0
                ? "a suspended sentence with supervised probation and \(restitution.formatted(.currency(code: "USD").precision(.fractionLength(0)))) in restitution"
                : "a suspended sentence with supervised probation"
            let bottom = pleaFelony ? "a sentence at the bottom of the presumptive range" : "a sentence at the low end of the authorized range"
            let kindIndex = rng.int(0...2)
            arrangementKind = ["bottom", "suspended", "open"][kindIndex]
            let withdrawNote = " If the court decides on a harsher sentence, the defendant may withdraw the plea (G.S. 15A-1024)."
            arrangementTerms = [
                "The defendant will plead guilty to \(pleaLaw.title).\(dismissed) The State recommends \(bottom).\(withdrawNote)",
                "The defendant will plead guilty to \(pleaLaw.title).\(dismissed) The parties jointly recommend \(probationTerms).\(withdrawNote)",
                "The defendant will plead guilty to \(pleaLaw.title).\(dismissed) Sentencing is left to the discretion of the court."
            ][kindIndex]
            pleaRejection = nil
        }

        // Notice, disputed priors, and the posture below
        let probationNotice: Bool? = defendant.probation == nil ? nil : rng.chance(0.75)
        var disputedID: UUID?
        var disputedReason: String?
        if !defendant.priors.isEmpty && rng.chance(0.2) {
            let prior = rng.pick(defendant.priors.filter { !$0.fromThisCourt }.isEmpty ? defendant.priors : defendant.priors.filter { !$0.fromThisCourt })
            disputedID = prior.id
            disputedReason = rng.pick([
                "The State's only proof of the \(prior.year) \(prior.offense) conviction is a DCI printout. My client says that was a cousin with the same name, and the date of birth on the printout is off by a year.",
                "The \(prior.year) \(prior.offense) in \(prior.county) was a plea without counsel, Judge, and there's no waiver of counsel in the file.",
                "We dispute the \(prior.year) \(prior.offense). The State has no judgment, just a line in a statewide database, and the file number doesn't match."
            ])
        }
        var districtSentence: String?
        if !isFelony, let cls = primary.law.ncClass {
            let days = cls == .misdA1 ? rng.int(30...75) : (cls == .misd1 ? rng.int(20...45) : rng.int(10...30))
            districtSentence = rng.chance(0.5)
                ? "\(days) days suspended, 12 months supervised probation"
                : "\(days) days active"
        }

        return CaseBackground(
            pleaOffer: pleaOffer,
            pleaRejection: pleaRejection,
            custodyDays: custodyDays,
            bondStatus: bondStatus,
            restitution: restitution,
            restitutionBasis: basis,
            victimStance: stance,
            victimStanceDetail: stanceDetail,
            treatmentNeed: need,
            treatmentDetail: treatmentDetail,
            treatmentBedAvailable: rng.chance(0.5),
            employmentPlan: plan,
            indigent: indigent,
            supportPeople: support,
            willTestify: rng.chance(defendant.priors.contains { $0.ncClass.isFelony } ? 0.45 : 0.7),
            discoveryIssue: discovery,
            stateObjectsToASR: rng.chance(violent ? 0.7 : 0.3),
            hiddenMitigator: rng.chance(0.7) && !hiddenMitigatorPool.isEmpty ? rng.pick(hiddenMitigatorPool) : nil,
            hiddenAggravator: rng.chance(0.4) ? rng.pick(hiddenAggravatorPool) : nil,
            attorneyFeeEstimate: isFelony ? rng.int(15...45) * 100 : rng.int(3...8) * 100,
            arrangementPresented: arrangementPresented,
            arrangementLawID: arrangementLawID,
            arrangementTerms: arrangementTerms,
            arrangementHabitual: arrangementHabitual,
            probationPointNotice: probationNotice,
            disputedPriorID: disputedID,
            disputedPriorReason: disputedReason,
            stateJoinsDischarge: stance == .wantsMaximum ? false : rng.chance(t.hasVictim ? 0.4 : 0.65),
            districtCourtSentence: districtSentence,
            arrangementKind: arrangementKind,
            stateConsentsNoContest: !t.hasVictim && rng.chance(0.6)
        )
    }

    private static func randomPriors(age: Int, year: Int, county: County, rng: inout SeededRNG) -> [PriorConviction] {
        let roll = Double.random(in: 0..<1, using: &rng)
        let count: Int
        if roll < 0.45 { count = 0 }
        else if roll < 0.72 { count = rng.int(1...2) }
        else if roll < 0.9 { count = rng.int(3...4) }
        else { count = rng.int(5...7) }
        guard count > 0 else { return [] }

        let earliest = year - max(1, min(age - 17, 20))
        let latest = year - 1
        guard earliest <= latest else { return [] }

        var priors: [PriorConviction] = []
        for _ in 0..<count {
            let seed = rng.pick(GenericPools.priorSeeds)
            if let last = priors.last, rng.chance(0.15) {
                // Two convictions entered in the same session of court.
                let key = last.sessionKey ?? UUID().uuidString
                priors[priors.count - 1].sessionKey = key
                priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: last.year,
                                              county: last.county, sentence: rng.pick(seed.sentences), sessionKey: key))
                continue
            }
            let where_ = rng.chance(0.55) ? county.name : rng.pick(GenericPools.otherCounties)
            priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: rng.int(earliest...latest),
                                          county: where_, sentence: rng.pick(seed.sentences)))
        }
        return priors.sorted { $0.year < $1.year }
    }

    private static func makeWitness(_ seed: WitnessSeed, side: Side, fill: TextFiller,
                                    rng: inout SeededRNG, used: inout Set<String>, impeach: Bool = true) -> Witness {
        let name: String
        if let token = seed.name {
            name = fill(token)
        } else {
            name = NameBank.person(using: &rng, excluding: &used)
        }
        var cross = fill(seed.cross)
        var weight = seed.weight
        let isVictim = seed.name == "{V}"
        if impeach && seed.lay && rng.chance(0.45) {
            let pool = (side == .prosecution ? GenericPools.prosecutionImpeachments : GenericPools.defenseImpeachments)
                .filter { !isVictim || $0.victimSafe }
            let impeachment = rng.pick(pool)
            cross.append(fill(impeachment.text))
            weight = max(0, weight - impeachment.penalty)
        }
        var witness = Witness(name: name, role: fill(seed.role), calledBy: side, direct: fill(seed.direct), cross: cross, weight: weight,
                              lay: seed.lay)
        if !seed.exam.isEmpty {
            let opposing: Side = side == .prosecution ? .defense : .prosecution
            let versions = seed.exam.map { max($0.answers.count, $0.questions.count) }.max() ?? 1
            let version = rng.int(0...(max(1, versions) - 1))
            var exchanges = seed.exam.filter { !$0.optional || rng.chance(0.6) }.map { line in
                TestimonyExchange(phase: line.phase, examiner: line.phase == .cross ? opposing : side,
                                  question: fill(line.question(version)), answer: fill(line.answer(version)))
            }
            // A generic credibility problem drawn on cross shows up as a narrated moment before redirect.
            let extra = cross.count > seed.cross.count ? cross.last : nil
            if let extra {
                let insertAt = exchanges.firstIndex { $0.phase == .redirect } ?? exchanges.count
                exchanges.insert(TestimonyExchange(phase: .cross, examiner: opposing, question: "", answer: extra), at: insertAt)
            }
            witness.exchanges = exchanges
            witness.direct = exchanges.filter { $0.phase == .direct }.map(\.answer)
            witness.cross = exchanges.filter { $0.phase != .direct }.map(\.answer)
        }
        return witness
    }

    private static func makeMotion(_ seed: MotionSeed, target: UUID?, targetTitle: String?, fill: TextFiller) -> Motion {
        let item = targetTitle.map { "\"\($0)\"" } ?? "the case"
        let defense: String
        let prosecution: String
        switch seed.kind {
        case .suppressSearch:
            defense = "The defense moves under G.S. 15A-974 to suppress \(item) as the product of an unconstitutional search."
            prosecution = "The State contends the search was lawful, or that an exception to the warrant requirement applies."
        case .suppressStatement:
            defense = "The defense moves to suppress \(item), arguing it was obtained in violation of the defendant's constitutional rights."
            prosecution = "The State contends the statement was voluntary and lawfully obtained."
        case .dismissSpeedyTrial:
            defense = "The defense moves to dismiss all charges for violation of the right to a speedy trial."
            prosecution = "The State contends the delay was justified and caused no prejudice."
        }
        return Motion(kind: seed.kind, facts: fill(seed.facts), defenseArgument: defense, prosecutionResponse: prosecution,
                      targetEvidenceID: target, shouldGrant: seed.shouldGrant, appellateNote: fill(seed.explanation),
                      doctrineIDs: seed.doctrines)
    }

    private static func lastName(_ name: String) -> String {
        name.components(separatedBy: " ").last ?? name
    }
}

extension String {
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
