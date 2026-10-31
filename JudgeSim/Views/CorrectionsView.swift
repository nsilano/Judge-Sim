import SwiftUI
import Charts

/// The jail, the state prisons, and the probation office as this court's rulings fill them, and the judge's own record.
struct CorrectionsView: View {
    @EnvironmentObject private var game: GameState
    @State private var section = 0

    var body: some View {
        NavigationStack {
            List {
                if let notice = game.corrections?.openNotice {
                    noticeSection(notice)
                }
                Picker("Corrections", selection: $section) {
                    Text("Jail").tag(0)
                    Text("Prison").tag(1)
                    Text("Probation").tag(2)
                    Text("My Record").tag(3)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)

                switch section {
                case 0: JailSections()
                case 1: PrisonSections()
                case 2: ProbationSections()
                default: JudgeRecordSections()
                }
            }
            .benchBackground()
            .navigationTitle("Corrections")
        }
    }

    @ViewBuilder
    private func noticeSection(_ notice: SheriffNotice) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label(notice.kind == .releases ? "Notice of early releases" : "Jail near capacity",
                      systemImage: notice.kind == .releases ? "exclamationmark.triangle.fill" : "bell.fill")
                    .font(.headline)
                    .foregroundStyle(notice.kind == .releases ? Theme.bad : Theme.gold)
                Text(notice.message).font(.system(.callout, design: .serif)).italic()
                Text("— Sheriff \(game.county?.sheriff ?? ""), \(SentenceFormat.shortDate(notice.issued))")
                    .font(.caption).foregroundStyle(.secondary)
                if let deadline = notice.deadline {
                    let days = max(0, CourtCalendar.calendar.dateComponents([.day], from: CourtCalendar.calendar.startOfDay(for: game.currentDate),
                                                                            to: CourtCalendar.calendar.startOfDay(for: deadline)).day ?? 0)
                    Pill(text: days == 0 ? "Releases begin today" : "Releases begin in \(days) day\(days == 1 ? "" : "s")",
                         color: Theme.bad, icon: "clock.fill")
                }
            }
            NavigationLink {
                ReleasePickerView()
            } label: {
                Label("Choose who goes from the jail roster", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

// MARK: - Jail

private struct JailSections: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        let state = game.corrections
        let roster = game.jailRoster()
        let beds = max(1, state?.beds ?? Corrections.beds(casesPerYear: 180))
        let pretrial = roster.filter { $0.kind == .pretrial }
        let sentenced = roster.filter { $0.kind == .sentenced }
        let awaitingBed = roster.filter { $0.kind == .awaitingBed }
        let share = Double(roster.count) / Double(beds)

        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(roster.count)").font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(share > 1 ? Theme.bad : (share >= Corrections.warnAt ? Theme.gold : Theme.text))
                    Text("of \(beds) beds").font(.headline).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int((share * 100).rounded()))%").font(.title3.weight(.bold).monospacedDigit())
                        .foregroundStyle(share > 1 ? Theme.bad : (share >= Corrections.warnAt ? Theme.gold : Theme.good))
                }
                CapacityBar(share: share)
                HStack {
                    miniStat("\(pretrial.count)", "Awaiting trial")
                    Spacer()
                    miniStat("\(sentenced.count)", "Serving jail terms")
                    Spacer()
                    miniStat("\(awaitingBed.count)", "Waiting for prison")
                }
            }
        } header: {
            Text("\(game.county?.name ?? "County") jail tonight")
        } footer: {
            Text("Only people held because of your rulings: bonds they couldn't post, jail terms, and prison commitments waiting for a state bed. The sheriff warns at \(Int(Corrections.warnAt * 100))% and gives \(Corrections.noticeDays) days' notice before releasing anyone once the jail is over capacity.")
        }

        if let log = state?.log, log.count > 1 {
            Section("The last year") {
                TrendChart(days: Array(log.suffix(365)))
                    .frame(height: 170)
                    .padding(.vertical, 4)
            }
        }

        if !awaitingBed.isEmpty {
            Section {
                ForEach(awaitingBed.sorted { ($0.bedDate ?? .distantFuture) < ($1.bedDate ?? .distantFuture) }) { inmate in
                    InmateRow(inmate: inmate)
                }
            } header: {
                Text("Waiting for a state prison bed")
            } footer: {
                let week = CourtCalendar.calendar.date(byAdding: .day, value: 7, to: game.currentDate) ?? game.currentDate
                let soon = awaitingBed.filter { ($0.bedDate ?? .distantFuture) <= week }.count
                Text("\(soon) bed\(soon == 1 ? "" : "s") free up in the next 7 days as people go to the state. The wait varies person to person, and runs longer when you've sent many people to prison lately.")
            }
        }

        Section {
            NavigationLink {
                JailRosterView()
            } label: {
                HStack {
                    Label("Full jail roster", systemImage: "list.bullet.rectangle")
                    Spacer()
                    Text("\(roster.count)").foregroundStyle(.secondary)
                }
            }
            NavigationLink {
                EarlyReleasesView()
            } label: {
                HStack {
                    Label("Early releases", systemImage: "door.left.hand.open")
                    Spacer()
                    Text("\(state?.releases.count ?? 0)").foregroundStyle(.secondary)
                }
            }
            NavigationLink {
                SheriffNoticesView()
            } label: {
                HStack {
                    Label("Letters from the sheriff", systemImage: "envelope.fill")
                    Spacer()
                    Text("\(state?.notices.count ?? 0)").foregroundStyle(.secondary)
                }
            }
        }

        Section("By the numbers") {
            let pretrialDays = pretrial.map { days(since: $0.since) }
            Group {
            row("Days over capacity this year", "\(state?.yearDaysOver ?? 0)")
            row("Days over capacity in this county", "\(state?.daysOver ?? 0)")
            row("Highest count", state.map { "\($0.peak)" + ($0.peakDate.map { " on \(SentenceFormat.shortDate($0))" } ?? "") } ?? "0")
            row("Average count, last 30 days", average(state?.log.suffix(30).map(\.jail)))
            row("Average wait in jail for trial", pretrialDays.isEmpty ? "None held" : "\(pretrialDays.reduce(0, +) / pretrialDays.count) days")
            row("Longest wait in jail for trial", pretrial.max { days(since: $0.since) < days(since: $1.since) }.map { "\(days(since: $0.since)) days · \($0.name)" } ?? "None held")
            row("Held on a bond under $1,000", "\(pretrial.filter { (bondAmount($0.bond) ?? .max) < 1_000 }.count)")
            row("Held on a bond under $5,000", "\(pretrial.filter { (bondAmount($0.bond) ?? .max) < 5_000 }.count)")
            }
            Group {
            row("Felony / misdemeanor", "\(roster.filter(\.felony).count) / \(roster.filter { !$0.felony }.count)")
            row("Violent / non-violent charge", "\(roster.filter(\.violent).count) / \(roster.filter { !$0.violent }.count)")
            row("Low / moderate / high risk", "\(roster.filter { $0.risk < 0.3 }.count) / \(roster.filter { $0.risk >= 0.3 && $0.risk < 0.55 }.count) / \(roster.filter { $0.risk >= 0.55 }.count)")
            row("Bed-days this year", (state?.yearBedDays ?? 0).formatted())
            row("Cost to the county this year", Corrections.money((state?.yearBedDays ?? 0) * Corrections.jailDayCost))
            row("Cost to the county, all told", Corrections.money((state?.bedDays ?? 0) * Corrections.jailDayCost))
            row("Daily cost tonight", Corrections.money(roster.count * Corrections.jailDayCost))
            }
        }

        let charges = Dictionary(grouping: roster, by: \.charge).map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
        if !charges.isEmpty {
            Section("Held tonight, by charge") {
                ForEach(charges.prefix(10), id: \.0) { charge in
                    row(charge.0, "\(charge.1)")
                }
            }
        }
    }

    private func days(since date: Date?) -> Int {
        guard let date else { return 0 }
        return max(0, CourtCalendar.calendar.dateComponents([.day], from: date, to: game.currentDate).day ?? 0)
    }

    private func average(_ values: [Int]?) -> String {
        guard let values, !values.isEmpty else { return "—" }
        return String(format: "%.1f", Double(values.reduce(0, +)) / Double(values.count))
    }
}

/// The first dollar amount in a bond line, e.g. 2500 from "Held on a $2,500 secured bond".
private func bondAmount(_ text: String?) -> Int? {
    guard let text, let range = text.range(of: #"\$[0-9,]+"#, options: .regularExpression) else { return nil }
    return Int(text[range].dropFirst().replacingOccurrences(of: ",", with: ""))
}

private func row(_ label: String, _ value: String) -> some View {
    HStack(alignment: .firstTextBaseline) {
        Text(label).font(.subheadline)
        Spacer()
        Text(value).font(.subheadline.monospacedDigit().weight(.semibold)).multilineTextAlignment(.trailing)
    }
}

private func miniStat(_ value: String, _ label: String) -> some View {
    VStack {
        Text(value).font(.system(.title3, design: .rounded).weight(.bold))
        Text(label).font(.caption2).foregroundStyle(.secondary)
    }
}

private struct CapacityBar: View {
    let share: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.raised)
                Capsule().fill(share > 1 ? Theme.bad : (share >= Corrections.warnAt ? Theme.gold : Theme.good))
                    .frame(width: proxy.size.width * CGFloat(min(1, max(0, share))))
                // Where the sheriff starts writing.
                Rectangle().fill(Theme.text.opacity(0.5))
                    .frame(width: 1.5)
                    .offset(x: proxy.size.width * CGFloat(Corrections.warnAt))
            }
        }
        .frame(height: 10)
    }
}

private struct TrendChart: View {
    let days: [CorrectionsDay]

    var body: some View {
        Chart {
            ForEach(days, id: \.date) { day in
                AreaMark(x: .value("Date", day.date), y: .value("In jail", day.jail))
                    .foregroundStyle(Theme.gold.opacity(0.25))
                LineMark(x: .value("Date", day.date), y: .value("In jail", day.jail), series: .value("Series", "Jail"))
                    .foregroundStyle(Theme.gold)
                LineMark(x: .value("Date", day.date), y: .value("Beds", day.beds), series: .value("Series", "Beds"))
                    .foregroundStyle(Theme.bad)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 2)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
    }
}

private struct InmateRow: View {
    @EnvironmentObject private var game: GameState
    let inmate: JailInmate

    var body: some View {
        let content = VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(inmate.name).font(.system(.subheadline, design: .serif).weight(.semibold))
                Text("\(inmate.age)").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Pill(text: inmate.riskLabel, color: inmate.risk < 0.3 ? Theme.good : (inmate.risk < 0.55 ? Theme.gold : Theme.bad))
            }
            Text(inmate.charge).font(.caption)
            Text(detail).font(.caption2).foregroundStyle(.secondary)
            if !inmate.flags.isEmpty {
                Text(inmate.flags.joined(separator: " · ")).font(.caption2).foregroundStyle(Theme.gold)
            }
        }
        if let person = game.person(inmate.personID) {
            NavigationLink { PersonDetail(person: person, today: game.currentDate) } label: { content }
        } else {
            content
        }
    }

    private var detail: String {
        switch inmate.kind {
        case .pretrial:
            let held = inmate.since.map { "Held since \(SentenceFormat.shortDate($0))" } ?? "Held"
            return "\(held) · \(inmate.docket)" + (bondAmount(inmate.bond).map { " · $\($0.formatted()) bond" } ?? "")
        case .sentenced:
            return "Jail term · out \(inmate.releaseDate.map(SentenceFormat.shortDate) ?? "—") · \(inmate.docket)"
        case .awaitingBed:
            let bed = inmate.bedDate.map { "State bed expected \(SentenceFormat.shortDate($0))" } ?? "State bed date pending"
            return "\(bed) · \(inmate.docket)"
        }
    }
}

private struct JailRosterView: View {
    @EnvironmentObject private var game: GameState
    @State private var filter = 0

    var body: some View {
        let roster = game.jailRoster()
        let shown = roster.filter { inmate in
            switch filter {
            case 1: return inmate.kind == .pretrial
            case 2: return inmate.kind == .sentenced
            case 3: return inmate.kind == .awaitingBed
            default: return true
            }
        }.sorted { $0.name < $1.name }
        List {
            Picker("Show", selection: $filter) {
                Text("All").tag(0)
                Text("Trial").tag(1)
                Text("Jail term").tag(2)
                Text("To prison").tag(3)
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            Section("\(shown.count) \(shown.count == 1 ? "person" : "people")") {
                if shown.isEmpty { Text("No one.").foregroundStyle(.secondary) }
                ForEach(shown) { InmateRow(inmate: $0) }
            }
        }
        .benchBackground()
        .navigationTitle("Jail roster")
    }
}

/// The judge picks who leaves before the sheriff does.
struct ReleasePickerView: View {
    @EnvironmentObject private var game: GameState
    @Environment(\.dismiss) private var dismiss
    @State private var picked: Set<UUID> = []
    @State private var confirm = false

    var body: some View {
        let roster = game.jailRoster()
        let beds = game.corrections?.beds ?? Corrections.beds(casesPerYear: 180)
        let over = max(0, roster.count - beds)
        let candidates = roster.filter(\.canRelease).sorted { $0.risk < $1.risk }
        List {
            Section {
                let floor = Int(Double(beds) * Corrections.releaseFloor)
                Text("The jail holds \(roster.count) for \(beds) beds. Releasing \(max(0, roster.count - floor)) would bring it down to \(floor) and end the sheriff's notice. Releasing \(over) brings it to capacity, and the sheriff releases no one if it's still there on the deadline; above capacity, the sheriff releases down to \(floor).")
                    .font(.callout)
                HStack {
                    Text("Selected").font(.subheadline)
                    Spacer()
                    Text("\(picked.count)").font(.headline.monospacedDigit())
                        .foregroundStyle(picked.count >= max(0, roster.count - Int(Double(beds) * Corrections.releaseFloor)) ? Theme.good : Theme.gold)
                }
            } footer: {
                Text("A person awaiting trial goes home on a written promise to appear; a person serving a jail term goes home with the rest of the term forgiven. People held for the state's prisons can't be released. Anyone you let go who is arrested again will be news, and the paper will say who let them out.")
            }
            Section("Lowest risk first") {
                if candidates.isEmpty { Text("No one on the roster can be released.").foregroundStyle(.secondary) }
                ForEach(candidates) { inmate in
                    Button {
                        if picked.contains(inmate.personID) { picked.remove(inmate.personID) } else { picked.insert(inmate.personID) }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: picked.contains(inmate.personID) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(picked.contains(inmate.personID) ? Theme.gold : .secondary)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(inmate.name).font(.system(.subheadline, design: .serif).weight(.semibold))
                                    Spacer()
                                    Pill(text: inmate.riskLabel, color: inmate.risk < 0.3 ? Theme.good : (inmate.risk < 0.55 ? Theme.gold : Theme.bad))
                                }
                                Text("\(inmate.kindLabel) · \(inmate.charge)").font(.caption)
                                Text(timeLine(inmate)).font(.caption2).foregroundStyle(.secondary)
                                if !inmate.flags.isEmpty {
                                    Text(inmate.flags.joined(separator: " · ")).font(.caption2).foregroundStyle(Theme.gold)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            if !picked.isEmpty {
                Section {
                    Button("Order \(picked.count) release\(picked.count == 1 ? "" : "s")", role: .destructive) { confirm = true }
                        .font(.headline)
                }
            }
        }
        .benchBackground()
        .navigationTitle("Early releases")
        .confirmationDialog("Release \(picked.count) \(picked.count == 1 ? "person" : "people") from the jail today?",
                            isPresented: $confirm, titleVisibility: .visible) {
            Button("Order the releases", role: .destructive) {
                game.orderEarlyRelease(picked)
                picked = []
                dismiss()
            }
        }
    }

    private func timeLine(_ inmate: JailInmate) -> String {
        let cal = CourtCalendar.calendar
        switch inmate.kind {
        case .pretrial:
            let held = inmate.since.map { max(0, cal.dateComponents([.day], from: $0, to: game.currentDate).day ?? 0) } ?? 0
            return "Held \(held) day\(held == 1 ? "" : "s") awaiting trial" + (bondAmount(inmate.bond).map { " on a $\($0.formatted()) bond" } ?? "")
        default:
            let left = inmate.releaseDate.map { max(0, cal.dateComponents([.day], from: game.currentDate, to: $0).day ?? 0) } ?? 0
            return "\(left) day\(left == 1 ? "" : "s") left to serve"
        }
    }
}

private struct EarlyReleasesView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        let releases = (game.corrections?.releases ?? []).reversed()
        List {
            Section {
                row("Chosen by you", "\(releases.filter(\.byJudge).count)")
                row("Chosen by the sheriff", "\(releases.filter { !$0.byJudge }.count)")
                row("Arrested again, your picks", rate(releases.filter(\.byJudge)))
                row("Arrested again, the sheriff's picks", rate(releases.filter { !$0.byJudge }))
            }
            Section("Everyone released early") {
                if releases.isEmpty { Text("No one yet.").foregroundStyle(.secondary) }
                ForEach(Array(releases)) { r in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(r.name).font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(SentenceFormat.shortDate(r.date)).font(.caption2).foregroundStyle(.secondary)
                        }
                        Text("\(r.charge) · \(r.pretrial ? "awaiting trial, held \(r.days) days" : "\(r.days) days left on the term")").font(.caption)
                        Text(r.byJudge ? "Your choice" : "The sheriff's choice").font(.caption2).foregroundStyle(Theme.gold)
                        if let again = r.rearrested {
                            Text("Arrested again \(SentenceFormat.shortDate(again))").font(.caption2.weight(.semibold)).foregroundStyle(Theme.bad)
                        }
                    }
                }
            }
        }
        .benchBackground()
        .navigationTitle("Early releases")
    }

    private func rate<S: Sequence>(_ list: S) -> String where S.Element == EarlyRelease {
        let all = Array(list)
        guard !all.isEmpty else { return "—" }
        let again = all.filter { $0.rearrested != nil }.count
        return "\(again) of \(all.count)"
    }
}

private struct SheriffNoticesView: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        List {
            let notices = (game.corrections?.notices ?? []).reversed()
            if notices.isEmpty { Text("The sheriff hasn't written.").foregroundStyle(.secondary) }
            ForEach(Array(notices)) { notice in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notice.kind == .releases ? "Notice of early releases" : "Near capacity").font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(SentenceFormat.shortDate(notice.issued)).font(.caption2).foregroundStyle(.secondary)
                    }
                    Text("\(notice.population) held for \(notice.beds) beds").font(.caption)
                    Text(notice.outcome ?? "Still open.").font(.caption2).foregroundStyle(notice.isOpen ? Theme.gold : .secondary)
                }
            }
        }
        .benchBackground()
        .navigationTitle("Letters from the sheriff")
    }
}

// MARK: - Prison

private struct PrisonSections: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        let date = game.currentDate
        let cal = CourtCalendar.calendar
        let committed = game.people.filter { $0.custodyPlace == .prison }
        let inPrison = committed.filter { !$0.awaitingStateBed(on: date) }
        let waiting = committed.filter { $0.awaitingStateBed(on: date) }
        let yearOut = cal.date(byAdding: .year, value: 1, to: date) ?? date
        let life = committed.filter { $0.releaseDate == .distantFuture }
        let releasing = committed.filter { ($0.releaseDate ?? .distantFuture) <= yearOut }
        let remaining = committed.compactMap { p -> Int? in
            guard let end = p.releaseDate, end != .distantFuture else { return nil }
            return max(0, cal.dateComponents([.day], from: date, to: end).day ?? 0)
        }
        let prs = game.people.filter { $0.status != .incarcerated && $0.postRelease != nil }

        Section {
            HStack {
                miniStat("\(inPrison.count)", "In state prison")
                Spacer()
                miniStat("\(waiting.count)", "Waiting in jail")
                Spacer()
                miniStat("\(prs.count)", "Post-release")
            }
        } header: {
            Text("People you sent to prison")
        } footer: {
            Text("The state runs the prisons, so there is no cap. Each new commitment waits in the county jail for a state bed first, and the wait grows when you've sent many people lately.")
        }

        Section("By the numbers") {
            row("Prison commitments in the past year", "\(game.corrections?.prisonAdmissions.count ?? 0)")
            row("Serving life", "\(life.count)")
            row("Released within the next year", "\(releasing.count)")
            row("Average time left (not life)", remaining.isEmpty ? "—" : years(remaining.reduce(0, +) / remaining.count))
            row("Years left to serve, all told", remaining.isEmpty ? "0" : String(format: "%.1f", Double(remaining.reduce(0, +)) / 365))
            row("Daily cost to the state", Corrections.money(inPrison.count * Corrections.prisonDayCost))
            row("Yearly cost at today's count", Corrections.money(inPrison.count * Corrections.prisonDayCost * 365))
            row("Released from prison, career", "\(game.stats.releasedFromPrison)")
        }

        let byClass = Dictionary(grouping: committed) { p -> String in
            let docket = p.custodyDocket
            return p.priors.last { $0.docket == docket }.map { "Class \($0.ncClass.rawValue)" } ?? "Other"
        }.map { ($0.key, $0.value.count) }.sorted { $0.0 < $1.0 }
        if !byClass.isEmpty {
            Section("By offense class") {
                ForEach(byClass, id: \.0) { row($0.0, "\($0.1)") }
            }
        }

        Section("Coming home next") {
            let next = committed.filter { $0.releaseDate != .distantFuture }.sorted { ($0.releaseDate ?? .distantFuture) < ($1.releaseDate ?? .distantFuture) }
            if next.isEmpty { Text("No one in prison from your court.").foregroundStyle(.secondary) }
            ForEach(next.prefix(15)) { person in
                NavigationLink { PersonDetail(person: person, today: date) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.name).font(.subheadline.weight(.semibold))
                            Text(person.awaitingStateBed(on: date) ? "In the county jail, waiting for a bed" : "State prison")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(person.releaseDate.map(SentenceFormat.shortDate) ?? "—").font(.caption.monospacedDigit())
                    }
                }
            }
        }
    }

    private func years(_ days: Int) -> String {
        days >= 365 ? String(format: "%.1f years", Double(days) / 365) : "\(days / 30) months"
    }
}

// MARK: - Probation

private struct ProbationSections: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        let officers = game.corrections?.officers ?? Corrections.officers(casesPerYear: 180)
        let mine = game.people.filter { $0.status == .probation && ($0.probation?.imposedInThisCourt ?? false) }
        let supervised = mine.filter { $0.probation?.supervised ?? true }
        let perOfficer = Double(supervised.count) / Double(max(1, officers))
        let load = perOfficer / Double(Corrections.caseloadPerOfficer)
        let risks = supervised.map { $0.probation?.violationRisk ?? 0.2 }
        let violators = mine.filter { person in (person.violations ?? []).contains { $0.docket == person.probation?.docket } }
        let s = game.stats

        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(String(format: "%.0f", perOfficer)).font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(load > 1 ? Theme.bad : (load >= 0.9 ? Theme.gold : Theme.text))
                    Text("cases per officer").font(.headline).foregroundStyle(.secondary)
                    Spacer()
                    Text("of \(Corrections.caseloadPerOfficer)").font(.subheadline).foregroundStyle(.secondary)
                }
                CapacityBar(share: load)
                HStack {
                    miniStat("\(supervised.count)", "Supervised")
                    Spacer()
                    miniStat("\(mine.count - supervised.count)", "Unsupervised")
                    Spacer()
                    miniStat("\(officers)", "Officers")
                }
            }
        } header: {
            Text("Probation office")
        } footer: {
            Text(load > 1
                 ? "The chief probation officer says the office is stretched: officers see people less often, violations slip by, and more probationers are arrested again. Crowded caseloads count against you in the public poll, at half the weight of a full jail."
                 : "Officers are meant to carry about \(Corrections.caseloadPerOfficer) cases. Past that, supervision thins, fewer violations are caught, and more probationers are arrested again.")
        }

        if let log = game.corrections?.log, log.count > 1 {
            Section("The last year") {
                Chart {
                    ForEach(log.suffix(365), id: \.date) { day in
                        LineMark(x: .value("Date", day.date), y: .value("On probation", day.probation), series: .value("Series", "Probation"))
                            .foregroundStyle(Theme.gold)
                        LineMark(x: .value("Date", day.date), y: .value("Capacity", officers * Corrections.caseloadPerOfficer), series: .value("Series", "Capacity"))
                            .foregroundStyle(Theme.bad)
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month, count: 2)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 150)
                .padding(.vertical, 4)
            }
        }

        Section("By the numbers") {
            row("Low / moderate / high risk", "\(risks.filter { $0 < 0.2 }.count) / \(risks.filter { $0 >= 0.2 && $0 < 0.35 }.count) / \(risks.filter { $0 >= 0.35 }.count)")
            row("With a violation on this term", "\(violators.count)")
            row("In treatment court", "\(mine.filter { $0.probation?.treatmentCourt != nil }.count)")
            row("Finished probation, career", "\(s.probationCompleted)")
            row("Revoked, career", "\(s.probationRevoked)")
            let finished = s.probationCompleted + s.probationRevoked
            row("Finished successfully", finished == 0 ? "—" : "\(s.probationCompleted * 100 / finished)%")
            row("Average term left", averageLeft(mine))
            row("Daily cost", Corrections.money(supervised.count * Corrections.probationDayCost))
        }

        Section("Ending soonest") {
            let soon = mine.sorted { ($0.probation?.ends ?? .distantFuture) < ($1.probation?.ends ?? .distantFuture) }
            if soon.isEmpty { Text("No one on probation from your court.").foregroundStyle(.secondary) }
            ForEach(soon.prefix(12)) { person in
                NavigationLink { PersonDetail(person: person, today: game.currentDate) } label: {
                    HStack {
                        Text(person.name).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(person.probation.map { SentenceFormat.shortDate($0.ends) } ?? "—").font(.caption.monospacedDigit())
                    }
                }
            }
        }
    }

    private func averageLeft(_ people: [PersonRecord]) -> String {
        let days = people.compactMap { $0.probation.map { max(0, CourtCalendar.calendar.dateComponents([.day], from: game.currentDate, to: $0.ends).day ?? 0) } }
        guard !days.isEmpty else { return "—" }
        return "\(days.reduce(0, +) / days.count / 30) months"
    }
}

// MARK: - The judge's record

private struct JudgeRecordSections: View {
    @EnvironmentObject private var game: GameState

    var body: some View {
        let s = game.stats
        let sentences = s.activeSentences + s.suspendedSentences
        let custodyRate = sentences == 0 ? nil : Double(s.activeSentences) / Double(sentences)

        Section {
            row("Active sentences", "\(s.activeSentences)")
            row("Suspended (probation) sentences", "\(s.suspendedSentences)")
            row("Custody rate", custodyRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "—")
            row("Typical North Carolina court", "about 40%")
        } header: {
            Text("How often you lock people up")
        } footer: {
            Text("Your record goes with you: these numbers follow you to any county you sit in. The jail and probation counts belong to the county.")
        }

        Section {
            ForEach(DispositionRecord.Group.allCases) { group in
                let list = game.dispositions.filter { $0.group == group }
                if !list.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(group.label).font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(list.count)").font(.subheadline.monospacedDigit())
                        }
                        Text(rearrestLine(list)).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            if game.dispositions.isEmpty { Text("No judgments entered yet.").foregroundStyle(.secondary) }
        } header: {
            Text("Arrested again, by what you did")
        } footer: {
            Text("Counted from the day each person walked free: judgment day for an acquittal, fine, or probation; release day for a jail or prison term. The one-year rate counts only people free for at least a year.")
        }

        Section("Bonds you set") {
            let kinds = (s.bondKinds ?? [:]).sorted { $0.value > $1.value }
            let total = kinds.map(\.value).reduce(0, +)
            if kinds.isEmpty { Text("No bonds set yet.").foregroundStyle(.secondary) }
            ForEach(kinds, id: \.key) { kind in
                row(kind.key, "\(kind.value) · \(total == 0 ? 0 : kind.value * 100 / total)%")
            }
            if total > 0 {
                row("Couldn't post the bond", "\(s.bondsNotPosted ?? 0) · \((s.bondsNotPosted ?? 0) * 100 / total)%")
            }
        }

        Section("What your rulings cost") {
            let jail = (s.jailBedDays ?? 0) * Corrections.jailDayCost
            let prison = (s.prisonBedDays ?? 0) * Corrections.prisonDayCost
            let probation = (s.probationDays ?? 0) * Corrections.probationDayCost
            row("County jail", Corrections.money(jail))
            row("State prison", Corrections.money(prison))
            row("Probation", Corrections.money(probation))
            row("All told", Corrections.money(jail + prison + probation))
            let cases = max(1, game.history.filter { $0.resolvedKind == "trial" }.count)
            row("Per case heard", Corrections.money((jail + prison + probation) / cases))
        }

        Section {
            row("Days the jail ran over capacity", "\(s.crowdedDays ?? 0)")
            row("Early releases you ordered", "\(s.earlyReleasesOrdered ?? 0)")
            row("Early releases the sheriff made", "\(s.earlyReleasesBySheriff ?? 0)")
            row("Released early, then arrested again", "\(s.earlyReleaseRearrests ?? 0)")
            let strain = min(150, s.crowdingStrain ?? 0)
            row("Cost in the public poll right now", strain == 0 ? "None" : "−\(max(1, strain / 8)) points")
        } header: {
            Text("Crowding")
        } footer: {
            Text("Crowding is yours alone: only people held because of your rulings count. The public's memory of it fades by half each New Year.")
        }
    }

    private func rearrestLine(_ list: [DispositionRecord]) -> String {
        let date = game.currentDate
        let cal = CourtCalendar.calendar
        let free = list.filter { ($0.freeFrom ?? .distantFuture) <= date }
        guard !free.isEmpty else { return "No one free yet." }
        let again = free.filter { $0.rearrested != nil }.count
        let yearAgo = cal.date(byAdding: .year, value: -1, to: date) ?? date
        let year = free.filter { ($0.freeFrom ?? .distantFuture) <= yearAgo }
        let withinYear = year.filter { r in
            guard let at = r.rearrested, let from = r.freeFrom else { return false }
            return at.timeIntervalSince(from) <= 365 * 86_400
        }.count
        var line = "\(again) of \(free.count) free so far arrested again (\(again * 100 / free.count)%)"
        if !year.isEmpty { line += " · within a year: \(withinYear * 100 / year.count)% of \(year.count)" }
        return line
    }
}
