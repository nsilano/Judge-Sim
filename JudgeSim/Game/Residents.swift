import Foundation

/// Someone who has come through this court other than as a defendant: a victim, a neighbor who testified, the
/// bartender who called 911. Kept for the whole career, so the same people turn up again, in the right town and the
/// right job, and the record shows everywhere they've been.
struct Resident: Identifiable, Codable, Hashable {
    struct Role: Codable, Hashable {
        var date: Date
        var docket: String
        var caption: String
        /// "Victim", or "State's witness (neighbor)".
        var part: String
    }

    var id = UUID()
    var name: String
    /// The town they live in, when a case said so (a neighbor lives where it happened).
    var town: String?
    /// A job tied to a place, when a case named it: "Bartender at The Lantern Row Tavern".
    var occupation: String?
    var deceased = false
    var roles: [Role] = []
}

/// What case generation needs to know about a resident.
struct ResidentRef {
    let name: String
    let town: String?
    let occupation: String?
    /// The last case they testified in, for "Have you testified here before?".
    let lastCaption: String?
}

enum Residents {
    /// Roles anyone could fill, given the right town for a neighbor.
    private static let generic = ["neighbor", "bystander", "passerby", "customer", "patron", "shopper", "motorist", "jogger", "dog walker"]

    /// Whether a witness role is a job at a place on the county map: those are always the same person.
    static func isPlaceJob(_ role: String) -> Bool {
        Gazetteer.places.contains { role.contains(" at \($0.name)") || role.hasSuffix(" at \($0.name)") }
    }

    /// Someone already known to the court who fits this witness role, or nil for a new face.
    static func pick(for role: String, gender: Gender?, town: String, from pool: [ResidentRef], used: Set<String>,
                     rng: inout SeededRNG) -> ResidentRef? {
        let fits = pool.filter { !used.contains($0.name) && (gender == nil || NameBank.gender(of: $0.name) == gender) }
        // The bartender at the Lantern Row is the same bartender every time.
        if isPlaceJob(role) { return fits.first { $0.occupation == role } }
        let lower = role.lowercased()
        guard generic.contains(where: lower.contains) else { return nil }
        // A neighbor lives in the town where it happened; anyone else could have been passing through.
        let local = lower.contains("neighbor") ? fits.filter { $0.town == town } : fits
        guard !local.isEmpty, rng.chance(0.3) else { return nil }
        return rng.pick(local)
    }
}
