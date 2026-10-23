import SwiftUI

/// The county on paper: each town, its streets, the places people keep coming back to, the people who keep turning
/// up in court, and which cases came out of where.
struct CountyDirectoryView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        List {
            regularsSection
            eventsSection
            officersSection
            lawyersSection
            familiarSection
            ForEach(Gazetteer.towns, id: \.name) { town in
                TownSection(town: town)
            }
        }
        .navigationTitle("Hollis County")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var regularsSection: some View {
        if let county = game.county {
            let regulars = Gazetteer.regulars(for: county)
            Section("The people you'll see again") {
                ForEach(Self.regularTitles, id: \.0) { pair in
                    if let name = regulars[pair.0] {
                        NameLine(title: name, detail: pair.1)
                    }
                }
            }
        }
    }

    @ViewBuilder private var eventsSection: some View {
        let events: [LivingCounty.Event] = Array(game.living.events.suffix(12).reversed())
        if !events.isEmpty {
            Section("Lately in the county") {
                ForEach(events.indices, id: \.self) { i in
                    NameLine(title: events[i].headline, detail: SentenceFormat.shortDate(events[i].date), bold: false)
                }
            }
        }
    }

    @ViewBuilder private var officersSection: some View {
        let officers: [OfficerRecord] = game.officerRecords.values.sorted { $0.cases.count > $1.cases.count }
        if !officers.isEmpty {
            Section("Officers in your courtroom") {
                ForEach(officers, id: \.name) { r in
                    OfficerLine(record: r)
                }
            }
        }
    }

    @ViewBuilder private var lawyersSection: some View {
        let notes: [String] = game.lawyerRecords.values.sorted { $0.tried > $1.tried }.compactMap(TrackRecords.counselNote)
        if !notes.isEmpty {
            Section("Lawyers before you") {
                ForEach(notes, id: \.self) { note in
                    Text(note).font(.caption)
                }
            }
        }
    }

    @ViewBuilder private var familiarSection: some View {
        let familiar: [Resident] = Array(game.residents.filter { $0.roles.count >= 2 }.sorted { $0.roles.count > $1.roles.count }.prefix(40))
        if !familiar.isEmpty {
            Section("Familiar faces") {
                ForEach(familiar) { r in
                    ResidentLine(resident: r)
                }
            }
        }
    }

    static let regularTitles: [(String, String)] = [
        ("ME", "Medical examiner"), ("CHEMIST", "Forensic chemist, State Crime Laboratory"), ("TOX", "Forensic toxicologist"),
        ("FIREARMS", "Firearms examiner, State Crime Laboratory"), ("DNA", "DNA analyst, State Crime Laboratory"),
        ("PRINTS", "Latent print examiner"), ("FIRE", "Fire investigator"), ("DIGITAL", "Digital forensics examiner"),
        ("ERDOC", "Emergency physician, Hollis Regional Medical Center")
    ]
}

private struct NameLine: View {
    let title: String
    let detail: String
    var bold = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(bold ? .callout.weight(.semibold) : .callout)
            Text(detail).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct OfficerLine: View {
    let record: OfficerRecord

    var body: some View {
        let r = record
        let summary = "\(r.cases.count) case\(r.cases.count == 1 ? "" : "s"): \(r.convictions) conviction\(r.convictions == 1 ? "" : "s"), \(r.acquittals) acquittal\(r.acquittals == 1 ? "" : "s")"
        VStack(alignment: .leading, spacing: 2) {
            Text(r.name).font(.callout.weight(.semibold))
            Text(summary).font(.caption).foregroundStyle(.secondary)
            if !r.suppressed.isEmpty {
                let times = "\(r.suppressed.count) time\(r.suppressed.count == 1 ? "" : "s")"
                Text("Evidence suppressed \(times): " + r.suppressed.joined(separator: "; "))
                    .font(.caption).foregroundStyle(.orange)
            }
        }
    }
}

private struct ResidentLine: View {
    let resident: Resident

    var body: some View {
        let r = resident
        VStack(alignment: .leading, spacing: 2) {
            Text(r.name + (r.deceased ? " (deceased)" : "")).font(.callout.weight(.semibold))
            if let job = r.occupation { Text(job).font(.caption).foregroundStyle(.secondary) }
            ForEach(r.roles, id: \.docket) { role in
                Text("\(role.part) · \(role.caption)").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

private struct TownSection: View {
    @EnvironmentObject private var game: GameState
    let town: Gazetteer.Town

    var body: some View {
        let places: [Gazetteer.Place] = (Gazetteer.places + game.living.opened).filter { $0.town == town.name }.sorted { $0.name < $1.name }
        let character = town.character.prefix(1).uppercased() + String(town.character.dropFirst())
        let streets = "Streets: " + town.streets.joined(separator: ", ") + ". Roads: " + town.roads.joined(separator: ", ") + "."
        Section {
            Text(character).font(.caption).foregroundStyle(.secondary)
            Text(streets).font(.caption).foregroundStyle(.secondary)
            ForEach(places, id: \.name) { place in
                PlaceLine(place: place)
            }
        } header: {
            Text(town.name)
        }
    }
}

private struct PlaceLine: View {
    @EnvironmentObject private var game: GameState
    let place: Gazetteer.Place

    private var detail: String {
        var text = place.street
        if let owner = game.living.owners[place.name] { text += " · owner: \(owner)" }
        if let closed = game.living.closed[place.name] {
            text += closed == .distantPast ? " · closed" : " · closed \(SentenceFormat.shortDate(closed))"
        }
        if game.living.opened.contains(place) { text += " · new" }
        return text
    }

    var body: some View {
        let cases = game.placeHistory[place.name]?.count ?? 0
        let isClosed = game.living.closed[place.name] != nil
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name).font(.callout).strikethrough(isClosed).foregroundStyle(isClosed ? Color.secondary : Color.primary)
                Text(detail).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            if cases > 0 {
                Text("\(cases) case\(cases == 1 ? "" : "s")").font(.caption.weight(.semibold)).foregroundStyle(Theme.gold)
            }
        }
    }
}
