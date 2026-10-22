import SwiftUI

/// An administrative session: several short matters, each decided with one ruling.
struct CalendarCallView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    let call: CalendarCall
    @State private var choices: [UUID: Int] = [:]
    @State private var amounts: [UUID: Int] = [:]
    @State private var dates: [UUID: Date] = [:]
    @State private var showLibrary = false
    @State private var confirmLeave = false
    @State private var showResults = false

    /// An arraignment set for trial now needs the day picked before the calendar can close.
    private func needsDate(_ m: CalendarMatter) -> Bool { m.kind == .arraignment && choices[m.id] == 0 }

    var body: some View {
        NavigationStack {
            Group {
            if showResults {
                CalendarResults(lines: game.lastCalendarResults) { dismiss() }
            } else {
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ADMINISTRATIVE SESSION · CALENDAR CALL")
                            .font(.caption2.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(Theme.gold)
                        Text(SentenceFormat.date(call.date)).font(.caption.monospaced()).foregroundStyle(.secondary)
                        Text("The courtroom is full. The clerk calls the calendar, and the matters come up one at a time.")
                            .font(.callout)
                    }

                    ForEach(call.matters) { matter in
                        MatterCard(matter: matter, choice: Binding(get: { choices[matter.id] }, set: { choices[matter.id] = $0 }),
                                   amount: Binding(get: { amounts[matter.id] ?? matter.suggestedAmount ?? 0 },
                                                   set: { amounts[matter.id] = $0 }),
                                   date: Binding(get: { dates[matter.id] }, set: { dates[matter.id] = $0 }))
                    }

                    PrimaryButton(title: "Close the Calendar Call", icon: "hammer.fill",
                                  enabled: call.matters.allSatisfy { choices[$0.id] != nil && !(needsDate($0) && dates[$0.id] == nil) },
                                  hint: "Rule on every matter on the calendar.") {
                        Haptics.gavel()
                        game.completeCalendar(call, choices: choices, amounts: amounts, dates: dates)
                        withAnimation { showResults = true }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            }
            }
            .background(Theme.background)
            .navigationTitle(showResults ? "Calendar Call Results" : "Calendar Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { if showResults { dismiss() } else { confirmLeave = true } } label: {
                        Label("Leave", systemImage: "chevron.left").labelStyle(.titleAndIcon)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showLibrary = true } label: {
                        Label("Laws", systemImage: "books.vertical.fill").labelStyle(.titleAndIcon)
                    }
                }
            }
            .sheet(isPresented: $showLibrary) {
                LawLibraryView(highlightIDs: call.matters.compactMap(\.lawID) + ["pjc", "dispositions", "crv"], showsDoneButton: true)
            }
            .confirmationDialog("Leave the calendar call?", isPresented: $confirmLeave, titleVisibility: .visible) {
                Button("Leave; resume later") { dismiss() }
                Button("Stay", role: .cancel) {}
            } message: {
                Text("The session stays on your docket. Your rulings so far won't be kept.")
            }
        }
        .interactiveDismissDisabled()
    }
}

private struct MatterCard: View {
    @EnvironmentObject private var game: GameState
    let matter: CalendarMatter
    @Binding var choice: Int?
    @Binding var amount: Int
    @Binding var date: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(matter.kind.label, systemImage: matter.kind.icon).font(.headline)
                Spacer()
                Text(matter.docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            // A warrant application has no case yet; it names the person whose property would be searched.
            Text(matter.kind == .searchWarrant ? "In re: search of \(matter.personName)" : "State v. \(matter.personName)").font(.system(.subheadline, design: .serif).weight(.bold))
            Text(matter.summary).font(.callout)
            Label(matter.stateAsk, systemImage: "building.columns.fill")
                .font(.caption)
                .foregroundStyle(Theme.prosecution)
            Label(matter.defenseAsk, systemImage: "shield.fill")
                .font(.caption)
                .foregroundStyle(Theme.defense)
            if let note = matter.lawNote {
                Text(note).font(.caption).foregroundStyle(.orange)
            }
            ForEach(Array(matter.options.enumerated()), id: \.offset) { index, option in
                ChoiceRow(title: option, selected: choice == index) { choice = index }
            }
            if let choice, matter.amountOptions?.contains(choice) == true, let range = matter.amountRange {
                BondAmountPicker(amount: $amount, range: range)
            }
            if matter.kind == .arraignment && choice == 0 {
                Text("Pick the trial day. The State says about five weeks; too soon and the defense will ask for more time.")
                    .font(.caption).foregroundStyle(.secondary)
                DayPickerList(kind: .trial, count: 30, choice: $date)
            }
            if let warrant = matter.warrant {
                NavigationLink {
                    WarrantApplicationView(application: warrant, judge: game.judgeName ?? "")
                } label: {
                    Label("Read the application and affidavit", systemImage: "doc.text.magnifyingglass")
                        .font(.subheadline.weight(.semibold))
                }
            } else if matter.concernsProbationer, let person = game.person(matter.personID) {
                NavigationLink {
                    PersonDetail(person: person, today: game.currentDate)
                } label: {
                    Label("Open \(person.lastName)'s full file: the case, the judgment, probation, and every violation",
                          systemImage: "folder.fill")
                        .font(.subheadline.weight(.semibold))
                }
            } else if let c = matter.pendingCase {
                NavigationLink {
                    PendingCaseFile(courtCase: c)
                } label: {
                    Label("Open the case file", systemImage: "folder.fill").font(.subheadline.weight(.semibold))
                }
                if let person = game.person(c.defendant.personID) {
                    NavigationLink {
                        PersonDetail(person: person, today: game.currentDate)
                    } label: {
                        Label("\(person.lastName) has been in your court before: open the file", systemImage: "arrow.uturn.left")
                            .font(.caption.weight(.semibold))
                    }
                }
            }
            if let lawID = matter.lawID {
                LawLink(lawID: lawID)
            }
        }
        .card(tint: choice == nil ? nil : Theme.gold)
    }
}

/// The file on a case that comes up at the calendar call: the charges, what happened, the bond, the defendant's
/// record, and the evidence each side has listed, with each exhibit open to review.
struct PendingCaseFile: View {
    let courtCase: CourtCase

    var body: some View {
        let c = courtCase
        FixedWidthScroll {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(c.docket).font(.caption.monospaced()).foregroundStyle(.secondary)
                    Text(c.caption).font(.system(.title3, design: .serif).weight(.bold))
                }
                SectionTitle(text: "Charges", icon: "list.number")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(c.charges, id: \.id) { charge in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Count \(charge.count): \(charge.law.title)").font(.subheadline.weight(.semibold))
                            Text(charge.specification).font(.callout).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .card()
                SectionTitle(text: "What happened", icon: "doc.text.fill")
                Text(c.summary).font(.callout).fixedSize(horizontal: false, vertical: true).card()
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(c.defendant.name), \(c.defendant.age), \(c.defendant.occupation)").font(.subheadline.weight(.semibold))
                    if let bg = c.background { Text(bg.bondStatus).font(.callout) }
                    Text(c.defendant.priors.isEmpty ? "No prior convictions."
                         : "Prior convictions: " + c.defendant.priors.map { "\($0.offense) (\($0.year))" }.joined(separator: "; ") + ".")
                        .font(.callout)
                }
                .card()
                let state = c.evidence.filter { $0.side == .prosecution }
                let defense = c.evidence.filter { $0.side == .defense }
                if !state.isEmpty {
                    SectionTitle(text: "The State's evidence", icon: "building.columns.fill")
                    ForEach(state) { EvidenceCard(evidence: $0, suppressed: false, courtCase: c) }
                }
                if !defense.isEmpty {
                    SectionTitle(text: "The defense's evidence", icon: "shield.fill")
                    ForEach(defense) { EvidenceCard(evidence: $0, suppressed: false, courtCase: c) }
                }
                if !c.witnesses.isEmpty {
                    SectionTitle(text: "Witnesses listed", icon: "person.2.fill")
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(c.witnesses) { w in
                            Text("\(w.name), \(w.role) (\(w.calledBy == .prosecution ? "State" : "defense"))").font(.callout)
                        }
                    }
                    .card()
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Case File")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The warrant application as a court paper: the place, the items, and the sworn affidavit.
struct WarrantApplicationView: View {
    let application: WarrantApplication
    let judge: String

    var body: some View {
        let w = application
        FixedWidthScroll {
            VStack(alignment: .leading, spacing: 12) {
                Text("APPLICATION FOR SEARCH WARRANT").font(DocInk.serif(.headline, weight: .bold))
                Text("G.S. 15A-244 · \(w.kind.label)").font(DocInk.serif(.caption)).foregroundStyle(DocInk.faint)
                DocRule(double: true)
                DocField(label: "Applicant", value: "\(w.affiant), \(w.agency)")
                DocField(label: "Date", value: SentenceFormat.date(w.applied))
                DocSection(title: "Place to be searched")
                DocText(w.place)
                DocSection(title: "Items to be seized")
                ForEach(Array(w.items.enumerated()), id: \.offset) { i, item in
                    DocNumbered(number: i + 1, text: item)
                }
                DocSection(title: "Affidavit")
                ForEach(Array(w.affidavit.enumerated()), id: \.offset) { i, paragraph in
                    DocNumbered(number: i + 1, text: paragraph)
                }
                DocRule()
                DocText("Ask: Is the source reliable, or corroborated by what the officers saw themselves? Is the information fresh? Does it tie evidence to this place? Are the items described with particularity? A judge may sign, strike language and sign, or deny (G.S. 15A-245, 15A-246).", italic: true)
            }
            .foregroundStyle(DocInk.ink)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 4).fill(DocInk.paper))
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(DocInk.rule, lineWidth: 0.5))
            .padding(16)
        }
        .background(DocInk.desk)
        .navigationTitle("Warrant Application")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Sets a bond amount: type any figure, or tap a common one.
private struct BondAmountPicker: View {
    @Binding var amount: Int
    let range: ClosedRange<Int>
    @FocusState private var typing: Bool

    private var presets: [Int] {
        [500, 1_000, 2_500, 5_000, 10_000, 15_000, 25_000, 50_000, 75_000, 100_000, 250_000].filter { range.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bond amount").font(.subheadline.weight(.semibold))
                Spacer()
                Text("$").font(.title3.weight(.bold))
                TextField("Amount", value: Binding(get: { amount }, set: { amount = min(max($0, range.lowerBound), range.upperBound) }),
                          format: .number)
                    .keyboardType(.numberPad)
                    .font(.title3.monospacedDigit().weight(.bold))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 140)
                    .focused($typing)
                if typing {
                    Button("Done") { typing = false }
                        .font(.subheadline.weight(.bold))
                        .tint(Theme.gold)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(presets, id: \.self) { value in
                        Button("$\(value.formatted())") { amount = value; typing = false }
                            .buttonStyle(.bordered)
                            .tint(amount == value ? Theme.gold : .secondary)
                            .font(.caption.weight(.semibold))
                    }
                }
            }
            Stepper("Adjust by $500", value: Binding(get: { amount }, set: { amount = min(max($0, range.lowerBound), range.upperBound) }),
                    in: range, step: 500)
                .font(.caption)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised))
    }
}

/// What the calendar call decided, matter by matter, and where each case goes next.
struct CalendarResults: View {
    let lines: [String]
    let onDone: () -> Void

    var body: some View {
        FixedWidthScroll {
            VStack(alignment: .leading, spacing: 12) {
                Label("The calendar call is closed.", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(Theme.gold)
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    if line.hasSuffix(":") {
                        Text(line).font(.caption.weight(.bold)).foregroundStyle(.secondary).padding(.top, 6)
                    } else {
                        Text(line).font(.callout).fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised))
                    }
                }
                PrimaryButton(title: "Back to Chambers", icon: "arrow.uturn.backward", enabled: true, hint: nil) { onDone() }
            }
            .padding()
        }
    }
}
