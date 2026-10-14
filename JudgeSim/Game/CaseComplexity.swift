import Foundation

/// Extra counts that often ride along with the main charge, and complications that make close cases hard to call.
enum CaseComplexity {

    /// A count the State adds when the facts support it, with the evidence that goes with it.
    struct AddOn {
        let lawID: String
        let specification: String
        let categories: Set<LawCategory>
        /// Added to the template's threshold: negative means easier to prove than the main charge.
        let thresholdDelta: Int
        let evidence: EvidenceSeed
        var needsVictim = false
        var needsFelonyPrior = false
        /// Template keys this count would contradict.
        var excludedKeys: Set<String> = []
    }

    static let addOns: [AddOn] = [
        AddOn(lawID: "resisting",
              specification: "Resisted, delayed, and obstructed {OFF} by pulling away and refusing to be handcuffed during the arrest.",
              categories: [.violent, .robbery, .property, .drugs, .traffic, .publicOrder, .family],
              thresholdDelta: -3,
              evidence: EvidenceSeed(.video, 1, "Arrest Bodycam", "Bodycam shows {DL} twisting away twice before being taken to the ground and handcuffed.")),
        AddOn(lawID: "communicatingThreats",
              specification: "Threatened to kill {V}, in a manner and under circumstances that would cause a reasonable person to believe the threat would be carried out.",
              categories: [.violent, .robbery, .family],
              thresholdDelta: -2,
              evidence: EvidenceSeed(.digital, 2, "Threatening Message", "A text from {DL}'s number days earlier: \"You'll regret this. I mean it.\""),
              needsVictim: true),
        AddOn(lawID: "felonFirearm",
              specification: "Possessed a handgun after having been convicted of a felony.",
              categories: [.violent, .robbery, .drugs, .publicOrder],
              thresholdDelta: -1,
              evidence: EvidenceSeed(.physical, 2, "Handgun Under the Seat", "A loaded 9mm handgun recovered from under the driver's seat of the car {DL} was driving.", .search),
              needsFelonyPrior: true,
              excludedKeys: ["felonGun", "hiddenGun"]),
        AddOn(lawID: "concealedWeapon",
              specification: "Carried a concealed handgun about the person, off the defendant's own premises, without a permit.",
              categories: [.violent, .robbery, .drugs, .publicOrder],
              thresholdDelta: -2,
              evidence: EvidenceSeed(.physical, 1, "Waistband Pistol", "A small pistol found tucked in {DL}'s waistband under a jacket during the arrest.", .search),
              excludedKeys: ["felonGun", "hiddenGun", "unsecuredGun"]),
        AddOn(lawID: "injuryPersonalProperty",
              specification: "Willfully and wantonly damaged {V}'s cell phone and car window.",
              categories: [.violent, .robbery, .family],
              thresholdDelta: -3,
              evidence: EvidenceSeed(.physical, 1, "Damaged Property", "Photographs of a shattered phone screen and a cracked car window, with a repair estimate of $640."),
              needsVictim: true),
        AddOn(lawID: "possStolen",
              specification: "Possessed property belonging to {V}, knowing or having reasonable grounds to believe it was stolen.",
              categories: [.property, .robbery],
              thresholdDelta: -1,
              evidence: EvidenceSeed(.physical, 2, "Items in the Trunk", "A laptop and jewelry later identified by {V} were found in the trunk of {DL}'s car.", .search),
              needsVictim: true),
        AddOn(lawID: "injuryRealProperty",
              specification: "Willfully and wantonly damaged the rear door and window frame of the building.",
              categories: [.property],
              thresholdDelta: -2,
              evidence: EvidenceSeed(.physical, 1, "Pry Marks", "Fresh pry marks on the door frame, photographed the morning after.")),
        AddOn(lawID: "possParaphernalia",
              specification: "Possessed a glass pipe and digital scale with intent to use them with a controlled substance.",
              categories: [.drugs],
              thresholdDelta: -3,
              evidence: EvidenceSeed(.physical, 1, "Pipe and Scale", "A glass pipe with burnt residue and a digital scale, found in the center console.", .search)),
        AddOn(lawID: "possMarijuana",
              specification: "Possessed less than one-half ounce of marijuana.",
              categories: [.drugs, .traffic],
              thresholdDelta: -3,
              evidence: EvidenceSeed(.forensic, 1, "Green Plant Material", "A small bag of plant material, 4.1 grams. The lab report doesn't measure THC concentration.", .search)),
        AddOn(lawID: "dwlr",
              specification: "Drove a motor vehicle on a public highway while the defendant's driver's license was revoked.",
              categories: [.traffic, .drugs],
              thresholdDelta: -3,
              evidence: EvidenceSeed(.document, 1, "DMV Record", "A certified DMV record showing {DL}'s license revoked, with a notice mailed to an old address.")),
        AddOn(lawID: "obstruction",
              specification: "Obstructed justice by destroying records after learning of the investigation.",
              categories: [.whiteCollar, .cyber],
              thresholdDelta: -1,
              evidence: EvidenceSeed(.digital, 2, "Deleted Files", "Forensic recovery shows hundreds of files deleted from {DL}'s work laptop the day after the first subpoena.")),
        AddOn(lawID: "identityTheft",
              specification: "Used {V}'s personal identifying information to open accounts without consent.",
              categories: [.whiteCollar],
              thresholdDelta: 0,
              evidence: EvidenceSeed(.document, 2, "Account Applications", "Two credit applications in {V}'s name, listing {DL}'s mailing address."),
              needsVictim: true),
        AddOn(lawID: "cyberstalking",
              specification: "Repeatedly sent electronic messages to {V} for the purpose of abusing, annoying, threatening, or harassing.",
              categories: [.cyber, .family, .robbery],
              thresholdDelta: -2,
              evidence: EvidenceSeed(.digital, 1, "Message Log", "Forty-one messages to {V} over nine days, most of them after {V.he} blocked {DL}'s first account."),
              needsVictim: true)
    ]

    /// Picks extra counts that fit the template, so more cases carry several charges.
    static func pickAddOns(for t: CaseTemplate, hasFelonyPrior: Bool, existing: Set<String>, rng: inout SeededRNG) -> [AddOn] {
        let fitting = addOns.filter { addOn in
            addOn.categories.contains(t.category)
                && !existing.contains(addOn.lawID)
                && addOn.lawID != t.primaryLaw && addOn.lawID != t.lesserLaw
                && !addOn.excludedKeys.contains(t.key)
                && (!addOn.needsVictim || t.hasVictim)
                && (!addOn.needsFelonyPrior || hasFelonyPrior)
        }
        guard !fitting.isEmpty else { return [] }
        let roll = Double.random(in: 0..<1, using: &rng)
        let count = roll < 0.3 ? 0 : (roll < 0.72 ? 1 : 2)
        return rng.pick(fitting, count: min(count, fitting.count))
    }

    // MARK: Complications for cases on the line

    struct Complication {
        let side: Side
        let evidence: EvidenceSeed
        /// Paper crimes (fraud, computer) get their own set.
        let paper: Bool
    }

    static let complications: [Complication] = [
        // Points toward the defense
        Complication(side: .defense, evidence: EvidenceSeed(.forensic, 3, "Second DNA Profile", "The lab also found a second, unidentified person's DNA on the same item. It was never run through the database."), paper: false),
        Complication(side: .defense, evidence: EvidenceSeed(.digital, 3, "Phone Location Gap", "Phone records place {DL}'s phone across town 14 minutes before the incident. The drive takes at least 12 minutes without traffic."), paper: false),
        Complication(side: .defense, evidence: EvidenceSeed(.document, 3, "Uninvestigated Tip", "A Crime Stoppers tip named another person, {ALT}, who matches the description. Detectives never followed up."), paper: false),
        Complication(side: .defense, evidence: EvidenceSeed(.video, 2, "Missing Bodycam Minutes", "The first eleven minutes of the responding officer's bodycam were never uploaded. The department says the battery died."), paper: false),
        Complication(side: .defense, evidence: EvidenceSeed(.document, 2, "Witness's Second Statement", "A State's witness gave a second written statement saying, \"I'm not as sure as I was. It happened fast.\""), paper: false),
        Complication(side: .defense, evidence: EvidenceSeed(.digital, 3, "Shared Credentials", "Audit logs show three other employees used the same login during the relevant months."), paper: true),
        Complication(side: .defense, evidence: EvidenceSeed(.document, 3, "Supervisor's Approval", "An email from a supervisor appears to approve the transactions the State calls theft."), paper: true),
        Complication(side: .defense, evidence: EvidenceSeed(.document, 2, "Accounting Errors", "The State's forensic accountant corrected their own totals twice before trial."), paper: true),
        // Points toward the State
        Complication(side: .prosecution, evidence: EvidenceSeed(.statement, 3, "Jail Phone Call", "On a recorded jail call after the arrest, {DL} told a relative to \"make sure that thing stays gone.\""), paper: false),
        Complication(side: .prosecution, evidence: EvidenceSeed(.statement, 2, "Two Different Stories", "{DL} told the first officer one account of the evening, and told the detective a different one an hour later."), paper: false),
        Complication(side: .prosecution, evidence: EvidenceSeed(.document, 3, "Gas Station Receipt", "A receipt from {DL}'s debit card, timestamped nine minutes before the incident, two blocks away."), paper: false),
        Complication(side: .prosecution, evidence: EvidenceSeed(.digital, 2, "Deleted Account", "{DL} deleted social media accounts the night of the incident and changed phone numbers two days later."), paper: false),
        Complication(side: .prosecution, evidence: EvidenceSeed(.document, 3, "Spending Records", "Bank records show {DL} paid off a car loan and two credit cards in the same months the money went missing."), paper: true),
        Complication(side: .prosecution, evidence: EvidenceSeed(.digital, 2, "After-Hours Logins", "Every disputed transaction was entered between 11 p.m. and 2 a.m. from {DL}'s home IP address."), paper: true)
    ]

    /// One complication on each side, so a close case pulls both ways.
    static func pickComplications(for t: CaseTemplate, rng: inout SeededRNG) -> [Complication] {
        let paper = t.category == .whiteCollar || t.category == .cyber
        let pool = complications.filter { $0.paper == paper }
        let defense = pool.filter { $0.side == .defense }
        let state = pool.filter { $0.side == .prosecution }
        guard !defense.isEmpty, !state.isEmpty else { return [] }
        return [rng.pick(defense), rng.pick(state)]
    }
}
