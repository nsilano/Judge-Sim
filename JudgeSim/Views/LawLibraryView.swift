import SwiftUI

struct LawLibraryView: View {
    /// Laws to pin at the top, e.g. those relevant to the case being heard.
    var highlightIDs: [String] = []
    var showsDoneButton = false

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    Section {
                        NavigationLink {
                            PunishmentChartView()
                        } label: {
                            Label("Felony & Misdemeanor Punishment Charts", systemImage: "tablecells.fill")
                                .font(.body.weight(.semibold))
                        }
                    }
                }

                if query.isEmpty && !highlightIDs.isEmpty {
                    Section("Relevant to this case") {
                        ForEach(highlightIDs.compactMap(LawLibrary.lawIfPresent)) { law in
                            row(law)
                        }
                    }
                }

                ForEach(LawCategory.allCases) { category in
                    let laws = filtered.filter { $0.category == category }
                    if !laws.isEmpty {
                        Section {
                            ForEach(laws) { law in row(law) }
                        } header: {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                }

                Section {
                    Text(LawLibrary.disclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Law Library")
            .searchable(text: $query, prompt: "Search statutes, rules, defenses")
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .toolbar {
                if showsDoneButton {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }

    private var filtered: [Law] {
        guard !query.isEmpty else { return LawLibrary.all }
        let q = query.lowercased()
        return LawLibrary.all.filter {
            $0.title.lowercased().contains(q)
                || $0.summary.lowercased().contains(q)
                || $0.statute.lowercased().contains(q)
                || $0.category.rawValue.lowercased().contains(q)
        }
    }

    private func row(_ law: Law) -> some View {
        NavigationLink {
            LawDetailView(law: law)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(law.title).font(.body.weight(.semibold))
                HStack(spacing: 6) {
                    Text(law.statute)
                    if let cls = law.ncClass {
                        Text("·")
                        Text(cls.label)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

struct LawDetailView: View {
    let law: Law

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                Text(law.summary)
                    .card()

                if let special = law.specialPunishment {
                    Label(special, systemImage: "exclamationmark.octagon.fill")
                        .font(.callout)
                        .card(tint: Theme.bad)
                }

                if let cls = law.ncClass, law.specialPunishment == nil || cls != .A {
                    ClassPunishmentTable(cls: cls)
                }

                if !law.elements.isEmpty {
                    SectionTitle(text: law.category.isOffense ? "Elements the State must prove" : "Key rules", icon: "list.number")
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(law.elements.enumerated()), id: \.offset) { index, element in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.bold))
                                    .frame(width: 22, height: 22)
                                    .background(Circle().fill(Theme.gold.opacity(0.2)))
                                Text(element).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .card()
                }

                if !law.defenses.isEmpty {
                    SectionTitle(text: "Common defenses", icon: "shield.lefthalf.filled")
                    BulletList(items: law.defenses).card()
                }
                if let notes = law.notes {
                    Label(notes, systemImage: "info.circle.fill")
                        .font(.callout)
                        .card(tint: .orange)
                }
                if !law.related.isEmpty {
                    SectionTitle(text: "See also", icon: "link")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(law.related, id: \.self) { LawLink(lawID: $0) }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(law.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(law.category.rawValue, systemImage: law.category.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.gold)
            Text(law.title)
                .font(.system(.largeTitle, design: .serif).weight(.bold))
            HStack {
                Pill(text: law.statute, icon: "book.closed")
                if let cls = law.ncClass {
                    Pill(text: cls.label, color: cls.isFelony ? Theme.bad : .orange)
                }
            }
        }
    }
}

/// The punishment-chart row for one class, at every prior record level.
struct ClassPunishmentTable: View {
    let cls: NCClass

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(cls.isFelony ? "Typical sentence (presumptive minimum, months)" : "Authorized sentence (days)",
                  systemImage: "scalemass.fill")
                .font(.headline)

            if cls == .A {
                Text("Life imprisonment without parole, or death in a capital case.").font(.callout)
            } else if cls.isFelony, let cells = StructuredSentencing.felonyGrid[cls] {
                ForEach(Array(cells.enumerated()), id: \.offset) { index, cell in
                    HStack(alignment: .firstTextBaseline) {
                        Text("Level \(SentenceFormat.romanLevels[index])")
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 70, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(cell.presumptive.text) · \(SentenceFormat.months(cell.presumptive.low))–\(SentenceFormat.months(cell.presumptive.high))")
                                .font(.subheadline)
                            Text("Mitigated \(cell.mitigated.low)–\(cell.mitigated.high) · Aggravated \(cell.aggravated.map { "\($0.low)–\($0.high)" } ?? "LWOP") · \(cell.dispositionCode)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Text("Ranges are for the minimum term. The maximum is about 120% of the minimum plus \(cls.severity <= NCClass.E.severity ? 12 : 9) months of post-release supervision. A = Active, I = Intermediate, C = Community.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let cells = StructuredSentencing.misdemeanorGrid[cls] {
                ForEach(Array(cells.enumerated()), id: \.offset) { index, cell in
                    HStack {
                        Text("Level \(SentenceFormat.romanLevels[index])")
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 70, alignment: .leading)
                        Text("1–\(cell.maxDays) days · \(cell.dispositionCode)").font(.subheadline)
                    }
                }
                Text("Level I: no prior convictions. II: 1–4. III: 5 or more." + (cls.maxFine.map { " Maximum fine \(SentenceFormat.dollars($0))." } ?? " Fine in the court's discretion."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            LawLink(lawID: cls.isFelony ? "punishmentChart" : "misdemeanorSentencing")
        }
        .card(tint: Theme.gold)
    }
}

struct PunishmentChartView: View {
    @State private var selected: NCClass = .D

    private let felonyClasses: [NCClass] = [.B1, .B2, .C, .D, .E, .F, .G, .H, .I]
    private let misdemeanorClasses: [NCClass] = [.misdA1, .misd1, .misd2, .misd3]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("North Carolina Structured Sentencing, for offenses committed on or after October 1, 2013. Find the offense class and the defendant's prior record level.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                SectionTitle(text: "Felonies", icon: "tablecells")
                classPicker(felonyClasses)
                SectionTitle(text: "Misdemeanors", icon: "tablecells")
                classPicker(misdemeanorClasses)

                ClassPunishmentTable(cls: selected)

                HStack {
                    LawLink(lawID: "priorRecord")
                    LawLink(lawID: "habitualFelon")
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Punishment Charts")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func classPicker(_ classes: [NCClass]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(classes, id: \.self) { cls in
                    Button {
                        withAnimation(.snappy) { selected = cls }
                    } label: {
                        Text(cls.rawValue)
                            .font(.headline)
                            .frame(minWidth: 44, minHeight: 36)
                            .background(RoundedRectangle(cornerRadius: 8).fill(selected == cls ? Theme.gold : Color(.tertiarySystemFill)))
                            .foregroundStyle(selected == cls ? Color.black : Color.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
