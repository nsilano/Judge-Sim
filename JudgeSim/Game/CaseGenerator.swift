import Foundation

/// Builds a fresh case from a template, the county's standing cast, and (sometimes) a returning defendant.
enum CaseGenerator {

    struct Context {
        let county: County
        let judgeName: String
        let date: Date
        let docketSequence: Int
        let recentTemplateKeys: [String]
        let returning: PersonRecord?
    }

    /// How strong the State's case should be, so that the evidence doesn't always point one way.
    private enum Band {
        case strong, close, weak
    }

    static func generate(seed: UInt64, context: Context) -> CourtCase {
        var rng = SeededRNG(seed: seed)
        var pool = CaseTemplates.all
        if let person = context.returning {
            let hasFelony = person.priors.contains { $0.ncClass.isFelony }
            pool = pool.filter { $0.occupations.isEmpty && (!$0.requiresFelonyPrior || hasFelony) }
        }
        let fresh = pool.filter { !context.recentTemplateKeys.contains($0.key) }
        let template = rng.pick(fresh.isEmpty ? pool : fresh)

        let roll = Double.random(in: 0..<1, using: &rng)
        let band: Band = roll < 0.38 ? .strong : (roll < 0.75 ? .close : .weak)

        var candidate = build(template, seed: seed, band: band, context: context, rng: &rng)
        for _ in 0..<24 {
            if matches(candidate, band: band) { return candidate }
            candidate = build(template, seed: seed, band: band, context: context, rng: &rng)
        }
        return candidate
    }

    private static func matches(_ courtCase: CourtCase, band: Band) -> Bool {
        guard let primary = courtCase.charges.first else { return true }
        let s = Judgment.properStrength(courtCase)
        let floor = primary.lesserLawID == nil ? primary.threshold : primary.lesserThreshold
        switch band {
        case .strong: return s >= primary.threshold + 2
        case .close: return s >= floor - 2 && s <= primary.threshold + 1
        case .weak: return s <= floor - 2
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
            var priors = randomPriors(age: age, year: currentYear, county: county, rng: &rng)
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
        let detective = rng.pick(county.detectives)
        let officer = rng.pick(county.officers)
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
            "TROOPER": "Trooper \(rng.pick(county.troopers))",
            "ALT": alternate,
            "PROS": prosecutor,
            "DEF": defenseLawyer,
            "ELECTEDDA": county.districtAttorney,
            "SHERIFF": county.sheriff,
            "JUDGE": lastName(context.judgeName),
            "STREET": rng.pick(NameBank.streets),
            "TIME": rng.pick(NameBank.times),
            "DATE": rng.pick(NameBank.dates),
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
        let isFelonyCase = charges.contains { $0.law.ncClass?.isFelony ?? false }
        let court: CourtKind = isFelonyCase ? .felony : .misdemeanorAppeal

        // Evidence
        let prosecutionCount = min(t.prosecutionEvidence.count, band == .weak ? 3 : rng.int(3...4))
        let defenseCount = min(t.defenseEvidence.count, band == .weak ? 2 : (band == .strong ? 1 : rng.int(1...2)))
        let prosecutionSeeds = rng.pick(t.prosecutionEvidence, count: prosecutionCount)
        let defenseSeeds = rng.pick(t.defenseEvidence, count: defenseCount)

        var evidence: [Evidence] = []
        var searchable: [(UUID, EvidenceKind)] = []
        var statements: [UUID] = []
        for (index, item) in prosecutionSeeds.enumerated() {
            let exhibit = Evidence(exhibit: "State's Exhibit \(index + 1)", title: fill(item.title), detail: fill(item.detail),
                                   side: .prosecution, kind: item.kind, weight: item.weight)
            evidence.append(exhibit)
            switch item.acquisition {
            case .search: searchable.append((exhibit.id, item.kind))
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
        let prosecutionWitnessCount = min(t.prosecutionWitnesses.count, rng.int(1...2))
        for item in rng.pick(t.prosecutionWitnesses, count: prosecutionWitnessCount) {
            witnesses.append(makeWitness(item, side: .prosecution, fill: fill, rng: &rng, used: &used))
        }
        if !t.defenseWitnesses.isEmpty && (band == .weak || rng.chance(0.75)) {
            witnesses.append(makeWitness(rng.pick(t.defenseWitnesses), side: .defense, fill: fill, rng: &rng, used: &used))
        }

        // Objections
        var objections: [Objection] = []
        var usedQuestions = Set<String>()
        for witness in witnesses where rng.chance(0.6) {
            let options = GenericPools.objectionSeeds.filter { option in
                let fits = option.onCross ? option.raisedBy == witness.calledBy : option.raisedBy != witness.calledBy
                return fits && (!option.needsVictim || t.hasVictim) && !usedQuestions.contains(option.question)
            }
            guard !options.isEmpty else { continue }
            let option = rng.pick(options)
            usedQuestions.insert(option.question)
            objections.append(Objection(witnessID: witness.id, question: fill(option.question), answer: fill(option.answer),
                                        raisedBy: option.raisedBy, grounds: option.grounds, shouldSustain: option.shouldSustain,
                                        appellateNote: fill(option.explanation), doctrineID: option.doctrineID,
                                        weightIfAdmitted: option.weight))
        }

        // Motions
        var motions: [Motion] = []
        if !searchable.isEmpty && rng.chance(0.6) {
            let target = rng.pick(searchable)
            let fitting = GenericPools.suppressSearchSeeds.filter { $0.kinds.isEmpty || $0.kinds.contains(target.1) }
            let wantGrant = rng.chance(0.45)
            let preferred = fitting.filter { $0.shouldGrant == wantGrant }
            let option = rng.pick(preferred.isEmpty ? fitting : preferred)
            let title = evidence.first { $0.id == target.0 }?.title ?? "the evidence"
            motions.append(makeMotion(option, target: target.0, targetTitle: title, fill: fill))
        }
        if !statements.isEmpty && rng.chance(0.55) {
            let target = rng.pick(statements)
            let option = rng.pick(GenericPools.suppressStatementSeeds)
            let title = evidence.first { $0.id == target }?.title ?? "the statement"
            motions.append(makeMotion(option, target: target, targetTitle: title, fill: fill))
        }
        if rng.chance(0.07) {
            motions.append(makeMotion(rng.pick(GenericPools.speedyTrialSeeds), target: nil, targetTitle: nil, fill: fill))
        }

        // Status and procedural posture
        let priorFelonies = defendant.priors.filter { $0.ncClass.isFelony }.count
        let habitual = isFelonyCase && priorFelonies >= 3 && t.primaryLaw != "murder1" && rng.chance(0.65)
        var notes: [String] = []
        if isFelonyCase {
            if t.primaryLaw == "murder1" {
                notes.append("The State has declared this a non-capital case. A jury may therefore be waived.")
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
        var aggravating = fill(rng.pick(t.aggravating, count: aggravatingCount))
        var mitigating = fill(rng.pick(t.mitigating, count: mitigatingCount))
        if defendant.priors.isEmpty {
            mitigating.append("The defendant has no prior criminal record")
        }
        if !defendant.occupation.lowercased().contains("unemployed") && rng.chance(0.5) {
            mitigating.append("The defendant has a positive employment history and is gainfully employed")
        }
        var mood = rng.pick(t.moods)
        var media = rng.int(1...2)
        var doctrines = t.doctrines
        var twistText: String?
        if rng.chance(0.5) {
            let twist = rng.pick(GenericPools.twists)
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
            var event = rng.pick(GenericPools.ethicsEvents(hasVictim: t.hasVictim))
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

        let yy = String(format: "%02d", currentYear % 100)
        let docket = "\(yy) \(isFelonyCase ? "CRS" : "CR") \(String(format: "%06d", context.docketSequence))"

        return CourtCase(
            seed: seed,
            templateKey: t.key,
            docket: docket,
            court: court,
            sessionDate: context.date,
            headline: fill(rng.pick(t.headlines)),
            category: t.category,
            summary: fill(rng.pick(t.summaries)),
            defendant: defendant,
            victimName: victimName,
            charges: charges,
            habitualIndicted: habitual,
            proceduralNotes: notes,
            motions: motions,
            prosecutor: "ADA \(prosecutor)",
            defenseAttorney: usePublicDefender ? "\(defenseLawyer), Assistant Public Defender" : "\(defenseLawyer), retained counsel",
            investigatingAgency: detective.agency,
            prosecutionOpening: fill(rng.pick(t.prosecutionTheory)),
            defenseOpening: fill(rng.pick(t.defenseTheory)),
            prosecutionClosing: fill(rng.pick(GenericPools.prosecutionClosings)),
            defenseClosing: fill(rng.pick(GenericPools.defenseClosings)),
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
            relatedDoctrines: doctrines
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
            let where_ = rng.chance(0.55) ? county.name : rng.pick(GenericPools.otherCounties)
            priors.append(PriorConviction(offense: seed.offense, ncClass: seed.ncClass, year: rng.int(earliest...latest),
                                          county: where_, sentence: rng.pick(seed.sentences)))
        }
        return priors.sorted { $0.year < $1.year }
    }

    private static func makeWitness(_ seed: WitnessSeed, side: Side, fill: TextFiller,
                                    rng: inout SeededRNG, used: inout Set<String>) -> Witness {
        let name: String
        if let token = seed.name {
            name = fill(token)
        } else {
            name = NameBank.person(using: &rng, excluding: &used)
        }
        var cross = fill(seed.cross)
        var weight = seed.weight
        if seed.lay && rng.chance(0.45) {
            let pool = side == .prosecution ? GenericPools.prosecutionImpeachments : GenericPools.defenseImpeachments
            let impeachment = rng.pick(pool)
            cross.append(fill(impeachment.text))
            weight = max(0, weight - impeachment.penalty)
        }
        return Witness(name: name, role: fill(seed.role), calledBy: side, direct: fill(seed.direct), cross: cross, weight: weight)
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
