import Foundation

/// Lesser-included offenses the court may convict of instead of the charged crime, most serious first.
enum LesserIncluded {
    static let table: [String: [String]] = [
        "murder1": ["murder2", "volManslaughter", "invManslaughter"],
        "murder2": ["volManslaughter", "invManslaughter"],
        "volManslaughter": ["invManslaughter"],
        "awdwikisi": ["awdwisi", "awdwik", "aisi", "awdw", "simpleAssault"],
        "awdwik": ["awdw", "simpleAssault"],
        "awdwisi": ["aisi", "awdw", "simpleAssault"],
        "aisi": ["simpleAssault"],
        "awdw": ["simpleAssault"],
        "assaultFemale": ["simpleAssault"],
        "strangulation": ["aisi", "simpleAssault"],
        "assaultLEO": ["simpleAssault"],
        "assaultGovOfficial": ["simpleAssault"],
        "habitualMisdAssault": ["simpleAssault"],
        "rape2": ["sexualBattery"],
        "dangerousRobbery": ["commonLawRobbery", "awdw", "felonyLarceny", "misdLarceny"],
        "commonLawRobbery": ["misdLarceny", "simpleAssault"],
        "kidnapping1": ["kidnapping2"],
        "burglary1": ["burglary2", "feloniousBE"],
        "burglary2": ["feloniousBE"],
        "felonyLarceny": ["misdLarceny"],
        "traffickingCocaine": ["pwisd", "possSchedII"],
        "traffickingOpioid": ["pwisd", "possSchedII"],
        "saleSchedII": ["deliverSchedII", "pwisd", "possSchedII"],
        "deliverSchedII": ["possSchedII"],
        "pwisd": ["possSchedII"],
        "deathByDistribution": ["deliverSchedII", "possSchedII"],
        "falsePretenses100k": ["falsePretenses"],
        "embezzlement100k": ["embezzlement"],
        "habitualDWI": ["dwi"],
        "felonyDBV": ["misdDBV"],
        "felonyChildAbuse": ["childAbuseMisd"],
    ]

    /// Every lesser offense available for a charge: the one the case was built with, then the rest of the ladder.
    static func options(for charge: Charge, original: String?) -> [Law] {
        var ids: [String] = []
        if let original { ids.append(original) }
        ids += table[charge.lawID] ?? []
        var seen = Set<String>()
        return ids.filter { $0 != charge.lawID && seen.insert($0).inserted }.map { LawLibrary.law($0) }
    }
}
