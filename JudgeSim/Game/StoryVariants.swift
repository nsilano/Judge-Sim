import Foundation

/// Alternate tellings of a written case. A variant keeps the story's key, charge, category, victim, and people, and
/// rewrites how it plays out: the summary, exhibits, testimony, timeline, and arguments. The first time a story is heard
/// it is told as written; each time it comes back it is told another way, and only after every telling has been heard
/// does the original return.
enum StoryVariants {
    /// All variants by story key, in the order they are told.
    static let byKey: [String: [CaseTemplate]] = {
        var map: [String: [CaseTemplate]] = [:]
        for t in all { map[t.key, default: []].append(t) }
        return map
    }()

    static let all: [CaseTemplate] = batches.flatMap { $0 }

    private static let batches: [[CaseTemplate]] = [
        variantsA,
        // More batches: variantsB, variantsC, ...
    ]

    /// The telling this hearing gets, given how many times the story has been heard in this career.
    static func telling(of template: CaseTemplate, heard: Int) -> CaseTemplate {
        guard let variants = byKey[template.key], !variants.isEmpty else { return template }
        let index = heard % (variants.count + 1)
        return index == 0 ? template : variants[index - 1]
    }

    /// Problems with a variant: it must be the same case as the story it retells.
    static func problems(_ variant: CaseTemplate, base: CaseTemplate?) -> [String] {
        guard let base else { return ["\(variant.key): no story with this key"] }
        var out: [String] = []
        if variant.primaryLaw != base.primaryLaw { out.append("\(variant.key): charge differs (\(variant.primaryLaw) vs \(base.primaryLaw))") }
        if variant.category != base.category { out.append("\(variant.key): category differs") }
        if variant.hasVictim != base.hasVictim { out.append("\(variant.key): victim flag differs") }
        if variant.genders != base.genders { out.append("\(variant.key): fixed genders differ") }
        if variant.ageRange != base.ageRange { out.append("\(variant.key): age range differs") }
        if variant.victimDies != base.victimDies { out.append("\(variant.key): the victim's fate differs") }
        if variant.headlines == base.headlines { out.append("\(variant.key): same headlines as the original") }
        if variant.summaries == base.summaries { out.append("\(variant.key): same summary as the original") }
        return out
    }
}
