import Foundation

/// An officer's history in this court: the cases worked, and the times the judge threw out what they found.
struct OfficerRecord: Codable, Hashable {
    var name: String
    var cases: [String] = []
    /// Captions of cases where the judge suppressed evidence from this officer's work.
    var suppressed: [String] = []
    var convictions = 0
    var acquittals = 0
}

/// A lawyer's history before this judge.
struct LawyerRecord: Codable, Hashable {
    var name: String
    var prosecutor: Bool
    var convictions = 0
    var acquittals = 0
    var lastCaption: String?
    /// "conviction" or "acquittal", for the last case.
    var lastResult: String?

    var tried: Int { convictions + acquittals }
}

enum TrackRecords {
    /// The case-file note about the lawyers in a case, from their record before this judge.
    static func counselNote(_ r: LawyerRecord) -> String? {
        guard r.tried > 0 else { return nil }
        let role = r.prosecutor ? "ADA" : "Defense counsel"
        let name = r.prosecutor ? r.name : (r.name.components(separatedBy: ",").first ?? r.name)
        var line = "\(role) \(name) has tried \(r.tried) case\(r.tried == 1 ? "" : "s") before you: \(r.convictions) conviction\(r.convictions == 1 ? "" : "s"), \(r.acquittals) acquittal\(r.acquittals == 1 ? "" : "s")."
        if let last = r.lastCaption, let result = r.lastResult { line += " Most recently, \(last) (\(result))." }
        return line
    }

    /// What the defense asks an officer whose earlier work this court threw out.
    static func suppressionCross(_ caption: String, count: Int, rng: inout SeededRNG) -> (String, String) {
        let question = count > 1
            ? "This court has suppressed evidence from your work \(count) times, including in \(caption), hasn't it?"
            : "This court suppressed evidence from your search in \(caption), didn't it?"
        let answer = rng.pick(["\"It did. Every case is different, and I followed procedure in this one.\"",
                               "\"Yes. I've changed how I write my affidavits since then.\"",
                               "\"It did. I disagreed with the ruling, but I respect it.\""])
        return (question, answer)
    }
}
