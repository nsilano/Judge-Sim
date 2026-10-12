import Foundation

/// Builds a fresh, never-quite-the-same case from a template plus a seed.
enum CaseGenerator {

    /// How strong the State's case should be. Spread across bands so the player can't
    /// learn that "the answer is always guilty".
    private enum Band: CaseIterable {
        case strong, close, weak
    }

    static func generate(seed: UInt64, avoiding recentKeys: [String]) -> CourtCase {
        var rng = SeededRNG(seed: seed)
        let fresh = CaseTemplates.all.filter { !recentKeys.contains($0.key) }
        let template = rng.pick(fresh.isEmpty ? CaseTemplates.all : fresh)

        let roll = Double.random(in: 0..<1, using: &rng)
        let band: Band = roll < 0.38 ? .strong : (roll < 0.75 ? .close : .weak)

        var candidate = build(template, seed: seed, band: band, rng: &rng)
        for _ in 0..<24 {
            if matches(candidate, band: band) { return candidate }
            candidate = build(template, seed: seed, band: band, rng: &rng)
        }
        return candidate
    }

    private static func matches(_ courtCase: CourtCase, band: Band) -> Bool {
        guard let primary = courtCase.charges.first else { return true }
        let s = Scoring.properStrength(courtCase)
        let floor = primary.lesserLawID == nil ? primary.threshold : primary.lesserThreshold
        switch band {
        case .strong: return s >= primary.threshold + 2
        case .close: return s >= floor - 2 && s <= primary.threshold + 1
        case .weak: return s <= floor - 2
        }
    }

    // MARK: - Assembly

    private static func build(_ t: CaseTemplate, seed: UInt64, band: Band, rng: inout SeededRNG) -> CourtCase {
        var used = Set<String>()
        let defendantName = NameBank.person(using: &rng, excluding: &used)
        let victimName = t.hasVictim ? NameBank.person(using: &rng, excluding: &used) : nil
        let detective = NameBank.person(using: &rng, excluding: &used)
        let officer = NameBank.person(using: &rng, excluding: &used)
        let alternate = NameBank.person(using: &rng, excluding: &used)
        let prosecutor = NameBank.person(using: &rng, excluding: &used)
        let defenseLawyer = NameBank.person(using: &rng, excluding: &used)

        let age = rng.int(t.ageRange)
        let occupation = t.occupations.isEmpty ? rng.pick(NameBank.occupations) : rng.pick(t.occupations)

        var values: [String: String] = [
            "D": defendantName,
            "DL": lastName(defendantName),
            "DA": "\(age)",
            "DO": occupation,
            "DET": "Detective \(detective)",
            "OFF": "Officer \(officer)",
            "ALT": alternate,
            "PROS": prosecutor,
            "DEF": defenseLawyer,
            "STREET": rng.pick(NameBank.streets),
            "TIME": rng.pick(NameBank.times),
            "DATE": rng.pick(NameBank.dates),
            "HOOD": rng.pick(NameBank.neighborhoods),
            "CITY": "Port Hollis",
            "V": victimName ?? "the complainant",
            "VL": victimName.map(lastName) ?? "the complainant"
        ]
        for key in t.extras.keys.sorted() {
            if let options = t.extras[key] { values[key] = rng.pick(options) }
        }
        let fill = TextFiller(values: values)

        // Defendant
        var priors = t.forcedPriors
        let priorRoll = Double.random(in: 0..<1, using: &rng)
        let randomPriorCount = priorRoll < 0.5 ? 0 : (priorRoll < 0.8 ? 1 : rng.int(2...3))
        let currentYear = Calendar.current.component(.year, from: Date())
        var years = Array((currentYear - 14)...(currentYear - 2)).shuffled(using: &rng).prefix(randomPriorCount).sorted()
        for offense in rng.pick(NameBank.priorOffenses, count: randomPriorCount) {
            let year = years.isEmpty ? currentYear - 5 : years.removeFirst()
            priors.append("\(year): \(offense)")
        }
        let defendant = Defendant(name: defendantName, age: age, occupation: occupation.capitalizedFirst,
                                  background: fill(rng.pick(NameBank.backgrounds)), priorRecord: priors)

        // Charges
        var charges = [Charge(count: 1, lawID: t.primaryLaw, lesserLawID: t.lesserLaw,
                              specification: fill(t.specification), threshold: t.threshold,
                              lesserThreshold: t.lesserThreshold)]
        for extra in t.secondary where rng.chance(extra.chance) {
            charges.append(Charge(count: charges.count + 1, lawID: extra.lawID, lesserLawID: nil,
                                  specification: fill(extra.specification), threshold: extra.threshold,
                                  lesserThreshold: extra.threshold))
        }

        // Evidence
        let prosecutionCount = min(t.prosecutionEvidence.count, band == .weak ? 3 : rng.int(3...4))
        let defenseCount = min(t.defenseEvidence.count, band == .weak ? 2 : (band == .strong ? 1 : rng.int(1...2)))
        let prosecutionSeeds = rng.pick(t.prosecutionEvidence, count: prosecutionCount)
        let defenseSeeds = rng.pick(t.defenseEvidence, count: defenseCount)

        var evidence: [Evidence] = []
        var searchable: [(UUID, EvidenceKind)] = []
        var statements: [UUID] = []
        for (index, seed) in prosecutionSeeds.enumerated() {
            let item = Evidence(exhibit: "State's Exhibit \(index + 1)", title: fill(seed.title), detail: fill(seed.detail),
                                side: .prosecution, kind: seed.kind, weight: seed.weight)
            evidence.append(item)
            switch seed.acquisition {
            case .search: searchable.append((item.id, seed.kind))
            case .statement: statements.append(item.id)
            case .none: break
            }
        }
        let letters = ["A", "B", "C", "D"]
        for (index, seed) in defenseSeeds.enumerated() {
            evidence.append(Evidence(exhibit: "Defense Exhibit \(letters[index % letters.count])", title: fill(seed.title),
                                     detail: fill(seed.detail), side: .defense, kind: seed.kind, weight: seed.weight))
        }

        // Witnesses
        var witnesses: [Witness] = []
        let prosecutionWitnessCount = min(t.prosecutionWitnesses.count, rng.int(1...2))
        for seed in rng.pick(t.prosecutionWitnesses, count: prosecutionWitnessCount) {
            witnesses.append(makeWitness(seed, side: .prosecution, fill: fill, rng: &rng, used: &used))
        }
        if !t.defenseWitnesses.isEmpty && (band == .weak || rng.chance(0.75)) {
            witnesses.append(makeWitness(rng.pick(t.defenseWitnesses), side: .defense, fill: fill, rng: &rng, used: &used))
        }

        // Objections
        var objections: [Objection] = []
        var usedObjectionGrounds = Set<String>()
        for witness in witnesses where rng.chance(0.6) {
            let options = GenericPools.objectionSeeds.filter { seed in
                let raisedDuringThisSide = seed.onCross ? seed.raisedBy == witness.calledBy : seed.raisedBy != witness.calledBy
                return raisedDuringThisSide
                    && (!seed.needsVictim || t.hasVictim)
                    && !usedObjectionGrounds.contains(seed.question)
            }
            guard !options.isEmpty else { continue }
            let seed = rng.pick(options)
            usedObjectionGrounds.insert(seed.question)
            objections.append(Objection(witnessID: witness.id, question: fill(seed.question), answer: fill(seed.answer),
                                        raisedBy: seed.raisedBy, grounds: seed.grounds, shouldSustain: seed.shouldSustain,
                                        explanation: fill(seed.explanation), doctrineID: seed.doctrineID,
                                        weightIfAdmitted: seed.weight))
        }

        // Motions
        var motions: [Motion] = []
        if !searchable.isEmpty && rng.chance(0.6) {
            let target = rng.pick(searchable)
            let fitting = GenericPools.suppressSearchSeeds.filter { $0.kinds.isEmpty || $0.kinds.contains(target.1) }
            let wantGrant = rng.chance(0.45)
            let pool = fitting.filter { $0.shouldGrant == wantGrant }
            let seed = rng.pick(pool.isEmpty ? fitting : pool)
            let title = evidence.first { $0.id == target.0 }?.title ?? "the evidence"
            motions.append(makeMotion(seed, target: target.0, targetTitle: title, fill: fill))
        }
        if !statements.isEmpty && rng.chance(0.55) {
            let target = rng.pick(statements)
            let seed = rng.pick(GenericPools.suppressStatementSeeds)
            let title = evidence.first { $0.id == target }?.title ?? "the statement"
            motions.append(makeMotion(seed, target: target, targetTitle: title, fill: fill))
        }
        if rng.chance(0.07) {
            motions.append(makeMotion(rng.pick(GenericPools.speedyTrialSeeds), target: nil, targetTitle: nil, fill: fill))
        }

        // Sentencing factors, twists, and mood
        let aggravatingCount = rng.int(1...2)
        let mitigatingCount = rng.int(1...2)
        var aggravating = fill(rng.pick(t.aggravating, count: aggravatingCount))
        var mitigating = fill(rng.pick(t.mitigating, count: mitigatingCount))
        var mood = rng.pick(t.moods)
        var media = rng.int(1...2)
        var doctrines = t.doctrines
        var twistText: String?
        if rng.chance(0.55) {
            let twist = rng.pick(GenericPools.twists)
            twistText = fill(twist.text)
            if let m = twist.mitigating { mitigating.append(fill(m)) }
            if let a = twist.aggravating { aggravating.append(fill(a)) }
            if let m = twist.mood { mood = m }
            media += twist.mediaBoost
            if let d = twist.doctrine { doctrines.append(d) }
        }
        media = min(3, max(1, media))
        doctrines.append(contentsOf: ["burdenOfProof", "sentencingFactors"])

        // Ethics dilemma
        var ethics: EthicsEvent?
        if rng.chance(0.35) {
            var event = rng.pick(GenericPools.ethicsEvents(hasVictim: t.hasVictim))
            event.body = fill(event.body)
            event.options = event.options.map { option in
                var o = option
                o.label = fill(o.label)
                o.result = fill(o.result)
                return o
            }
            ethics = event
        }

        // The hidden truth
        let rawStrength = evidence.reduce(0) { $0 + ($1.side == .prosecution ? $1.weight : -$1.weight) }
            + witnesses.reduce(0) { $0 + ($1.calledBy == .prosecution ? $1.weight : -$1.weight) }
        // Suppressed evidence still counts here: the truth doesn't care about the exclusionary rule.
        let guiltProbability = min(0.93, max(0.12, 0.5 + Double(rawStrength - t.threshold) * 0.08))
        let actuallyGuilty = rng.chance(guiltProbability)
        let truth = HiddenTruth(actuallyGuilty: actuallyGuilty,
                                revelation: fill(rng.pick(actuallyGuilty ? t.guiltyTruths : t.innocentTruths)))

        let victimImpact = t.victimImpacts.isEmpty ? nil : fill(rng.pick(t.victimImpacts))
        let allocution = fill(rng.pick(t.allocutions + GenericPools.genericAllocutions))

        return CourtCase(
            seed: seed,
            templateKey: t.key,
            docket: "CR-\(currentYear)-\(String(format: "%05d", Int(seed % 90_000) + 10_000))",
            headline: fill(rng.pick(t.headlines)),
            category: t.category,
            summary: fill(rng.pick(t.summaries)),
            defendant: defendant,
            victimName: victimName,
            charges: charges,
            motions: motions,
            prosecutor: "ADA \(prosecutor)",
            defenseAttorney: rng.chance(0.6) ? "\(defenseLawyer), Public Defender" : "\(defenseLawyer), retained counsel",
            prosecutionOpening: fill(rng.pick(t.prosecutionTheory)),
            defenseOpening: fill(rng.pick(t.defenseTheory)),
            prosecutionClosing: fill(rng.pick(GenericPools.prosecutionClosings)),
            defenseClosing: fill(rng.pick(GenericPools.defenseClosings)),
            evidence: evidence,
            witnesses: witnesses,
            objections: objections,
            aggravating: aggravating,
            mitigating: mitigating,
            victimImpact: victimImpact,
            allocution: allocution,
            twist: twistText,
            ethics: ethics,
            mood: mood,
            mediaAttention: media,
            truth: truth,
            relatedDoctrines: doctrines
        )
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
            defense = "The defense moves to exclude \(item) as the product of an unconstitutional search."
            prosecution = "The State argues the search was lawful, or that an exception to the warrant requirement applies."
        case .suppressStatement:
            defense = "The defense moves to exclude \(item), arguing it was obtained in violation of the defendant's constitutional rights."
            prosecution = "The State argues the statement was voluntary and lawfully obtained."
        case .dismissSpeedyTrial:
            defense = "The defense moves to dismiss all charges with prejudice for violation of the right to a speedy trial."
            prosecution = "The State argues the delay was justified and the defendant was not prejudiced."
        }
        return Motion(kind: seed.kind, facts: fill(seed.facts), defenseArgument: defense, prosecutionResponse: prosecution,
                      targetEvidenceID: target, shouldGrant: seed.shouldGrant, explanation: fill(seed.explanation),
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
