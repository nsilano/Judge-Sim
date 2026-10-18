import SwiftUI

/// An administrative session: several short matters, each decided with one ruling.
struct CalendarCallView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    let call: CalendarCall
    @State private var choices: [UUID: Int] = [:]
    @State private var showLibrary = false
    @State private var confirmLeave = false

    var body: some View {
        NavigationStack {
            ScrollView {
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
                        MatterCard(matter: matter, choice: Binding(get: { choices[matter.id] }, set: { choices[matter.id] = $0 }))
                    }

                    PrimaryButton(title: "Close the Calendar Call", icon: "hammer.fill",
                                  enabled: call.matters.allSatisfy { choices[$0.id] != nil },
                                  hint: "Rule on every matter on the calendar.") {
                        Haptics.gavel()
                        game.completeCalendar(call, choices: choices)
                        dismiss()
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Calendar Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { confirmLeave = true } label: {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(matter.kind.label, systemImage: matter.kind.icon).font(.headline)
                Spacer()
                Text(matter.docket).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            Text("State v. \(matter.personName)").font(.system(.subheadline, design: .serif).weight(.bold))
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
            if matter.concernsProbationer, let person = game.person(matter.personID) {
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
        ScrollView {
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
