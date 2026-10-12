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
                if query.isEmpty && !highlightIDs.isEmpty {
                    Section("Relevant to This Case") {
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
            .searchable(text: $query, prompt: "Search crimes, rules, defenses")
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
                || $0.code.lowercased().contains(q)
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
                    Text(law.code)
                    if let sentence = law.sentence {
                        Text("·")
                        Text(sentence.summary)
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
                    .font(.body)
                    .card()

                if let sentence = law.sentence {
                    SentenceRangeCard(sentence: sentence)
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

                if !law.aggravating.isEmpty {
                    SectionTitle(text: "Aggravating factors", icon: "arrow.up.circle.fill")
                    BulletList(items: law.aggravating, symbol: "plus.circle.fill", color: Theme.bad).card()
                }
                if !law.mitigating.isEmpty {
                    SectionTitle(text: "Mitigating factors", icon: "arrow.down.circle.fill")
                    BulletList(items: law.mitigating, symbol: "minus.circle.fill", color: Theme.good).card()
                }
                if !law.defenses.isEmpty {
                    SectionTitle(text: "Common defenses", icon: "shield.lefthalf.filled")
                    BulletList(items: law.defenses).card()
                }
                if let notes = law.notes {
                    Label(notes, systemImage: "exclamationmark.triangle.fill")
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
                Pill(text: law.code, icon: "number")
                if let offenseClass = law.offenseClass {
                    Pill(text: offenseClass.rawValue, color: offenseClass.isFelony ? Theme.bad : .orange)
                }
            }
        }
    }
}

struct SentenceRangeCard: View {
    let sentence: SentenceRange

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Sentencing range", systemImage: "scalemass.fill")
                .font(.headline)

            HStack {
                stat("Minimum", SentenceFormat.months(sentence.minMonths))
                Spacer()
                stat("Typical", SentenceFormat.months(sentence.typicalMonths), highlight: true)
                Spacer()
                stat("Maximum", SentenceFormat.months(sentence.maxMonths))
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                let span = Double(max(1, sentence.maxMonths - sentence.minMonths))
                let typical = Double(sentence.typicalMonths - sentence.minMonths) / span
                ZStack(alignment: .leading) {
                    Capsule().fill(
                        LinearGradient(colors: [Theme.good.opacity(0.6), .orange.opacity(0.7), Theme.bad.opacity(0.8)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    Circle()
                        .fill(Color.white)
                        .overlay(Circle().stroke(Color.black.opacity(0.6), lineWidth: 2))
                        .frame(width: 16, height: 16)
                        .offset(x: max(0, min(width - 16, width * typical - 8)))
                }
            }
            .frame(height: 16)

            VStack(alignment: .leading, spacing: 6) {
                Label("Maximum fine: \(SentenceFormat.dollars(sentence.maxFine))", systemImage: "dollarsign.circle")
                Label(sentence.probationEligible && !sentence.mandatoryMinimum ? "Probation available" : "Probation NOT available",
                      systemImage: sentence.probationEligible && !sentence.mandatoryMinimum ? "checkmark.circle" : "xmark.circle")
                if sentence.mandatoryMinimum {
                    Label("Mandatory minimum: \(SentenceFormat.months(sentence.minMonths))", systemImage: "lock.fill")
                        .foregroundStyle(Theme.bad)
                }
            }
            .font(.subheadline)
        }
        .card(tint: Theme.gold)
    }

    private func stat(_ label: String, _ value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(highlight ? Theme.gold : .primary)
        }
    }
}
