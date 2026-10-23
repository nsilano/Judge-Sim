import SwiftUI

/// The county on paper: each town, its streets, the places people keep coming back to, the people who keep turning
/// up in court, and which cases came out of where.
struct CountyDirectoryView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        List {
            if let county = game.county {
                Section("The people you'll see again") {
                    let regulars = Gazetteer.regulars(for: county)
                    ForEach(Self.regularTitles, id: \.0) { key, title in
                        if let name = regulars[key] {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name).font(.callout.weight(.semibold))
                                Text(title).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            if !game.living.events.isEmpty {
                Section("Lately in the county") {
                    ForEach(Array(game.living.events.suffix(12).reversed().enumerated()), id: \.offset) { _, e in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(e.headline).font(.callout)
                            Text(SentenceFormat.shortDate(e.date)).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            let officers = game.officerRecords.values.sorted { $0.cases.count > $1.cases.count }
            if !officers.isEmpty {
                Section("Officers in your courtroom") {
                    ForEach(officers, id: \.name) { r in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.name).font(.callout.weight(.semibold))
                            Text("\(r.cases.count) case\(r.cases.count == 1 ? "" : "s"): \(r.convictions) conviction\(r.convictions == 1 ? "" : "s"), \(r.acquittals) acquittal\(r.acquittals == 1 ? "" : "s")")
                                .font(.caption).foregroundStyle(.secondary)
                            if !r.suppressed.isEmpty {
                                Text("Evidence suppressed \(r.suppressed.count) time\(r.suppressed.count == 1 ? "" : "s"): " + r.suppressed.joined(separator: "; "))
                                    .font(.caption).foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
            let lawyers = game.lawyerRecords.values.sorted { $0.tried > $1.tried }
            if !lawyers.isEmpty {
                Section("Lawyers before you") {
                    ForEach(lawyers, id: \.name) { r in
                        if let note = TrackRecords.counselNote(r) {
                            Text(note).font(.caption)
                        }
                    }
                }
            }
            let familiar = game.residents.filter { $0.roles.count >= 2 }.sorted { $0.roles.count > $1.roles.count }
            if !familiar.isEmpty {
                Section("Familiar faces") {
                    ForEach(familiar.prefix(40)) { r in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.name + (r.deceased ? " (deceased)" : "")).font(.callout.weight(.semibold))
                            if let job = r.occupation { Text(job).font(.caption).foregroundStyle(.secondary) }
                            ForEach(r.roles, id: \.docket) { role in
                                Text("\(role.part) · \(role.caption)").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            ForEach(Gazetteer.towns, id: \.name) { town in
                Section {
                    Text(town.character.prefix(1).uppercased() + String(town.character.dropFirst()))
                        .font(.caption).foregroundStyle(.secondary)
                    Text("Streets: " + town.streets.joined(separator: ", ") + ". Roads: " + town.roads.joined(separator: ", ") + ".")
                        .font(.caption).foregroundStyle(.secondary)
                    ForEach((Gazetteer.places + game.living.opened).filter { $0.town == town.name }.sorted { $0.name < $1.name }, id: \.name) { place in
                        let cases = game.placeHistory[place.name] ?? []
                        let closed = game.living.closed[place.name]
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name).font(.callout).strikethrough(closed != nil).foregroundStyle(closed != nil ? .secondary : .primary)
                                Text(place.street
                                     + (game.living.owners[place.name].map { " · owner: \($0)" } ?? "")
                                     + (closed.map { $0 == .distantPast ? " · closed" : " · closed \(SentenceFormat.shortDate($0))" } ?? "")
                                     + (game.living.opened.contains(place) ? " · new" : ""))
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !cases.isEmpty {
                                Text("\(cases.count) case\(cases.count == 1 ? "" : "s")")
                                    .font(.caption.weight(.semibold)).foregroundStyle(Theme.gold)
                            }
                        }
                    }
                } header: {
                    Text(town.name)
                }
            }
        }
        .navigationTitle("Hollis County")
        .navigationBarTitleDisplayMode(.inline)
    }

    static let regularTitles: [(String, String)] = [
        ("ME", "Medical examiner"), ("CHEMIST", "Forensic chemist, State Crime Laboratory"), ("TOX", "Forensic toxicologist"),
        ("FIREARMS", "Firearms examiner, State Crime Laboratory"), ("DNA", "DNA analyst, State Crime Laboratory"),
        ("PRINTS", "Latent print examiner"), ("FIRE", "Fire investigator"), ("DIGITAL", "Digital forensics examiner"),
        ("ERDOC", "Emergency physician, Hollis Regional Medical Center")
    ]
}
