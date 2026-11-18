import Foundation

/// Some people keep coming back to court: a long record, or a life that keeps pulling them in. Nothing is stored on the
/// person; the pattern is worked out from who they are and their record, so every save (and every telling) agrees.
extension PersonRecord {
    /// A fixed number from 0 to 99 for this person, used for their style of reoffending.
    var styleRoll: Int { id.styleRoll }

    /// A second fixed number, independent of the style, that makes about one person in eight chronic from the start.
    private var chronicRoll: Int { id.uuidString.utf8.reduce(7) { ($0 &* 17 &+ Int($1)) & 0xffff } % 100 }

    /// People who are in and out of court: about one in eight from the start, and anyone with four or more
    /// appearances in this court. Prior convictions alone do not count: most defendants arrive with a record.
    var isChronic: Bool {
        // Hearings on a probation violation count for less than new cases: four new matters, or six of any kind.
        appearances.filter { !$0.docket.hasSuffix("(PV)") }.count >= 4 || appearances.count >= 6 || chronicRoll < 12
    }

    /// How much likelier than most this person is to be the one who comes back.
    var returnWeight: Double { isChronic ? 3 : 1 }

    /// Appearances in this court, counting the first.
    var appearanceCount: Int { appearances.count }
}

extension UUID {
    /// A fixed number from 0 to 99 for this person.
    var styleRoll: Int { uuidString.utf8.reduce(0) { ($0 &* 31 &+ Int($1)) & 0xffff } % 100 }

    /// Some people with a record don't respond to treatment or supervision, however the court sets it up: about one in
    /// three, fixed for the person.
    func resistsTreatment(priors: Int) -> Bool { priors >= 2 && styleRoll % 3 == 0 }
}

extension PersonRecord {
    /// How likely a chronic person still is to come back, given how long they have stayed out of court: it fades after a
    /// year, and more after two. Finishing a treatment program lowers it further.
    func quietFactor(on date: Date) -> Double {
        guard let last = appearances.last?.date else { return 1 }
        let days = CourtCalendar.calendar.dateComponents([.day], from: last, to: date).day ?? 0
        var factor = days > 730 ? 0.1 : days > 365 ? 0.35 : 1.0
        if appearances.contains(where: { ($0.charges + " " + $0.outcome).lowercased().contains("graduat") }) { factor *= 0.5 }
        return factor
    }
}
