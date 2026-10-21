import SwiftUI

/// How full a day or week is.
enum CalendarLoad {
    case closed, open, light, steady, busy, overbooked

    init(ratio: Double) {
        switch ratio {
        case ..<0.01: self = .open
        case ..<0.45: self = .light
        case ..<0.8: self = .steady
        case ...1.0: self = .busy
        default: self = .overbooked
        }
    }

    var label: String {
        switch self {
        case .closed: return "Closed"
        case .open: return "Open"
        case .light: return "Light"
        case .steady: return "Steady"
        case .busy: return "Busy"
        case .overbooked: return "Overbooked"
        }
    }

    var color: Color {
        switch self {
        case .closed: return .secondary
        case .open: return Theme.secondaryText
        case .light: return Theme.good
        case .steady: return Theme.gold
        case .busy: return .orange
        case .overbooked: return Theme.bad
        }
    }
}

extension WeekPlan {
    var load: CalendarLoad {
        if courtDays.isEmpty { return .closed }
        if carryingOver > 0 { return .overbooked }
        return CalendarLoad(ratio: Double(plannedMinutes) / Double(max(1, capacity)))
    }

    func dayLoad(_ day: Date) -> CalendarLoad {
        if !CourtCalendar.isCourtDay(day) { return .closed }
        return CalendarLoad(ratio: load(on: day))
    }
}

func hoursText(_ minutes: Int) -> String {
    let h = minutes / 60, m = minutes % 60
    if h == 0 { return "\(m)m" }
    return m == 0 ? "\(h)h" : "\(h)h \(m)m"
}

struct CourtCalendarView: View {
    @EnvironmentObject private var game: GameState
    @State private var selected: Date?
    @State private var month: Date?
    @State private var continuing: PlannedMatter?
    @State private var caseFile: CourtCase?

    private let cal = CourtCalendar.calendar

    var body: some View {
        NavigationStack {
            let plans = game.weekPlans(count: 16)
            let today = cal.startOfDay(for: game.today?.clock ?? game.currentDate)
            let day = selected ?? today
            let shownMonth = month ?? today
            let horizon = plans.last.map { cal.date(byAdding: .day, value: 4, to: $0.monday) ?? $0.monday } ?? today
            let events = game.calendarEvents(from: plans.first?.monday ?? today, to: horizon)
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 16) {
                    MonthGrid(month: shownMonth, plans: plans, events: events, today: today, selected: day,
                              onSelect: { selected = $0 }, onMonth: { month = $0 })
                    CalendarLegend()
                    if let plan = plans.first(where: { cal.isDate(CourtCalendar.monday(onOrBefore: day), inSameDayAs: $0.monday) }) {
                        WeekSummaryCard(plan: plan, today: today)
                        DayDetailCard(day: day, plan: plan, events: events.filter { cal.isDate($0.date, inSameDayAs: day) }, today: today,
                                      onContinue: { continuing = $0 }, onCaseFile: { caseFile = $0 })
                    } else {
                        Text(day < today ? "That day has passed. Past cases are in Records." : "Nothing is set that far out yet.")
                            .font(.callout).foregroundStyle(.secondary).card()
                    }
                    UpcomingWeeks(plans: plans, selectedWeek: CourtCalendar.monday(onOrBefore: day)) { monday in
                        let first = CourtCalendar.weekday(onOrAfter: monday)
                        selected = first
                        month = first
                    }
                    UpcomingEvents(events: events.filter { $0.date >= today && $0.kind != .holiday }, orders: game.arrestOrders,
                                   on: game.currentDate)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Court Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $continuing) { matter in
                ContinueSheet(matter: matter, plans: plans) { date in
                    game.resetForCongestion(matter, to: date)
                    continuing = nil
                }
            }
            .sheet(item: Binding(get: { caseFile.map { CaseFileItem(courtCase: $0) } }, set: { caseFile = $0?.courtCase })) { item in
                NavigationStack {
                    PendingCaseFile(courtCase: item.courtCase)
                        .background(Theme.background)
                        .navigationTitle(item.courtCase.caption)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { caseFile = nil } } }
                }
            }
        }
    }
}

private struct CaseFileItem: Identifiable {
    let courtCase: CourtCase
    var id: UUID { courtCase.id }
}

// MARK: - Month grid

private struct MonthGrid: View {
    let month: Date
    let plans: [WeekPlan]
    let events: [CalendarEvent]
    let today: Date
    let selected: Date
    let onSelect: (Date) -> Void
    let onMonth: (Date) -> Void

    private let cal = CourtCalendar.calendar

    private var firstOfMonth: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month
    }

    /// The Mondays of every week that touches this month.
    private var mondays: [Date] {
        let first = firstOfMonth
        let end = cal.date(byAdding: DateComponents(month: 1, day: -1), to: first) ?? first
        var out: [Date] = []
        var monday = CourtCalendar.monday(onOrBefore: first)
        while monday <= end {
            out.append(monday)
            monday = cal.date(byAdding: .day, value: 7, to: monday) ?? end
        }
        return out
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { onMonth(cal.date(byAdding: .month, value: -1, to: firstOfMonth) ?? month) } label: {
                    Image(systemName: "chevron.left").padding(8)
                }
                Spacer()
                Text(firstOfMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.system(.title3, design: .serif).weight(.bold))
                Spacer()
                Button { onMonth(cal.date(byAdding: .month, value: 1, to: firstOfMonth) ?? month) } label: {
                    Image(systemName: "chevron.right").padding(8)
                }
            }
            HStack(spacing: 4) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri"], id: \.self) { name in
                    Text(name).font(.caption2.weight(.bold)).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            ForEach(mondays, id: \.self) { monday in
                let plan = plans.first { cal.isDate($0.monday, inSameDayAs: monday) }
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { offset in
                        let day = cal.date(byAdding: .day, value: offset, to: monday) ?? monday
                        DayCell(day: day, inMonth: cal.isDate(day, equalTo: firstOfMonth, toGranularity: .month), plan: plan,
                                events: events.filter { cal.isDate($0.date, inSameDayAs: day) && $0.kind != .holiday },
                                isToday: cal.isDate(day, inSameDayAs: today), isPast: day < today,
                                isSelected: cal.isDate(day, inSameDayAs: selected))
                            .onTapGesture { Haptics.tap(); onSelect(day) }
                    }
                }
            }
        }
        .card()
    }
}

private struct DayCell: View {
    let day: Date
    let inMonth: Bool
    let plan: WeekPlan?
    let events: [CalendarEvent]
    let isToday: Bool
    let isPast: Bool
    let isSelected: Bool

    var body: some View {
        let closed = !CourtCalendar.isCourtDay(day)
        let load = plan?.dayLoad(day) ?? (closed ? .closed : .open)
        let matters = plan?.matters(on: day) ?? []
        let trials = matters.filter { $0.kind == .trial }.count
        let hearings = matters.filter { $0.kind == .hearing }.count
        let call = matters.contains { $0.kind == .calendarCall }
        VStack(spacing: 3) {
            Text(day.formatted(.dateTime.day()))
                .font(.subheadline.weight(isToday ? .bold : .regular).monospacedDigit())
                .foregroundStyle(isToday ? Theme.gold : (inMonth ? Theme.text : Theme.secondaryText))
            if closed {
                Image(systemName: "flag.fill").font(.system(size: 9)).foregroundStyle(Theme.gold)
            } else {
                Capsule().fill(load.color.opacity(plan == nil || isPast ? 0.25 : 0.9)).frame(height: 4)
            }
            HStack(spacing: 2) {
                if call { Circle().fill(Color.purple).frame(width: 5, height: 5) }
                if trials > 0 { Text("\(trials)").font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.gold) }
                if hearings > 0 { Circle().fill(Theme.defense).frame(width: 5, height: 5) }
                if !events.isEmpty { Circle().fill(Theme.secondaryText).frame(width: 5, height: 5) }
            }
            .frame(height: 9)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .opacity(isPast && !isToday ? 0.5 : 1)
        .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? Theme.raised : Color.clear))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(isToday ? Theme.gold : Color.clear, lineWidth: 1.5))
        .contentShape(Rectangle())
        .accessibilityLabel("\(day.formatted(.dateTime.weekday(.wide).month().day())), \(closed ? "courthouse closed" : load.label)")
    }
}

private struct CalendarLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                ForEach([CalendarLoad.light, .steady, .busy, .overbooked], id: \.label) { load in
                    HStack(spacing: 4) {
                        Capsule().fill(load.color).frame(width: 14, height: 4)
                        Text(load.label).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            HStack(spacing: 10) {
                HStack(spacing: 4) { Circle().fill(Color.purple).frame(width: 6, height: 6); Text("Calendar call") }
                HStack(spacing: 4) { Text("2").bold().foregroundStyle(Theme.gold); Text("Trials") }
                HStack(spacing: 4) { Circle().fill(Theme.defense).frame(width: 6, height: 6); Text("Hearing") }
                HStack(spacing: 4) { Circle().fill(Theme.secondaryText).frame(width: 6, height: 6); Text("Other") }
            }
            .font(.caption2).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Week and day

private struct WeekSummaryCard: View {
    let plan: WeekPlan
    let today: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(CourtCalendar.weekTitle(plan.monday)).font(.system(.headline, design: .serif))
                Spacer()
                Pill(text: plan.load.label, color: plan.load.color)
            }
            if plan.courtDays.isEmpty {
                Text("The courthouse is closed all week.").font(.callout)
            } else {
                ProgressView(value: min(1, Double(plan.plannedMinutes) / Double(max(1, plan.capacity))))
                    .tint(plan.load.color)
                Text("About \(hoursText(plan.plannedMinutes)) of matters set, with \(hoursText(plan.capacity)) of courtroom time over \(plan.courtDays.count) day\(plan.courtDays.count == 1 ? "" : "s").")
                    .font(.caption).foregroundStyle(.secondary)
                Label("\(plan.trialsSet) of \(plan.cap) trial seats taken" + (plan.isCurrent ? " this week" : ""), systemImage: "scalemass.fill")
                    .font(.caption)
                if !plan.isCurrent && plan.openSeats > 0 {
                    Label("\(plan.openSeats) open seat\(plan.openSeats == 1 ? "" : "s") will be filled with new cases when the week opens.", systemImage: "plus.circle")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if !plan.isCurrent {
                    Label("Probation violation hearings, usually one or two, are added when the week opens.", systemImage: "person.badge.clock")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if plan.carryingOver > 0 {
                    Label("\(plan.carryingOver) trial\(plan.carryingOver == 1 ? " is" : "s are") past the week's limit and will carry over. Continue one to pick its week yourself.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundStyle(Theme.bad)
                }
            }
            ForEach(plan.holidays, id: \.0) { holiday in
                Label("\(holiday.0.formatted(.dateTime.weekday(.wide))): \(holiday.1). The courthouse is closed.", systemImage: "flag.fill")
                    .font(.caption).foregroundStyle(Theme.gold)
            }
        }
        .card(tint: plan.load == .overbooked ? Theme.bad : nil)
    }
}

private struct DayDetailCard: View {
    let day: Date
    let plan: WeekPlan
    let events: [CalendarEvent]
    let today: Date
    let onContinue: (PlannedMatter) -> Void
    let onCaseFile: (CourtCase) -> Void

    var body: some View {
        let matters = plan.matters(on: day)
        let load = plan.dayLoad(day)
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(CourtCalendar.dayTitle(day)).font(.system(.headline, design: .serif))
                Spacer()
                if CourtCalendar.isCourtDay(day) && day >= today { Pill(text: load.label, color: load.color) }
            }
            if let holiday = CourtCalendar.holiday(on: day) {
                Label("\(holiday). The courthouse is closed; matters move to the next court day.", systemImage: "flag.fill")
                    .font(.callout).foregroundStyle(Theme.gold)
            } else if CourtCalendar.isWeekend(day) {
                Text("Court doesn't sit on weekends.").font(.callout).foregroundStyle(.secondary)
            } else if day < today {
                Text("This day has passed.").font(.callout).foregroundStyle(.secondary)
            } else if matters.isEmpty {
                Text(plan.isCurrent ? "Nothing is projected for this day yet. Matters run in the order you take them."
                                    : "Nothing set for this day yet. New cases and hearings are added when the week opens.")
                    .font(.callout).foregroundStyle(.secondary)
            } else {
                let minutes = plan.minutesByDay[CourtCalendar.calendar.startOfDay(for: day)] ?? 0
                Text("About \(hoursText(minutes)) of the \(hoursText(plan.dayCapacity)) court day." + (load == .overbooked ? " Expect to run late." : ""))
                    .font(.caption).foregroundStyle(load == .overbooked ? Theme.bad : .secondary)
                ForEach(matters) { matter in
                    MatterRow(matter: matter, onContinue: onContinue, onCaseFile: onCaseFile)
                }
            }
            if plan.isCurrent && CourtCalendar.isSameDay(day, plan.courtDays.first ?? day) {
                let done = plan.matters.filter(\.done)
                if !done.isEmpty {
                    Text("Already heard this week").font(.caption.weight(.bold)).foregroundStyle(.secondary).padding(.top, 4)
                    ForEach(done) { matter in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(matter.title).font(.subheadline.weight(.semibold))
                            if let outcome = matter.outcome { Text(outcome).font(.caption2).foregroundStyle(.secondary).lineLimit(2) }
                        }
                        .opacity(0.7)
                    }
                }
            }
            let carrying = plan.matters.filter(\.carriesOver)
            if !carrying.isEmpty && CourtCalendar.isSameDay(day, plan.courtDays.first ?? day) {
                Text("Waiting for a seat this week").font(.caption.weight(.bold)).foregroundStyle(Theme.bad).padding(.top, 4)
                ForEach(carrying) { matter in
                    MatterRow(matter: matter, onContinue: onContinue, onCaseFile: onCaseFile)
                }
            }
            if !events.isEmpty {
                Divider()
                ForEach(events) { event in EventRow(event: event) }
            }
        }
        .card()
    }
}

private struct MatterRow: View {
    let matter: PlannedMatter
    let onContinue: (PlannedMatter) -> Void
    let onCaseFile: (CourtCase) -> Void

    private var icon: String {
        switch matter.kind {
        case .calendarCall: return "list.bullet.rectangle.portrait.fill"
        case .trial: return "scalemass.fill"
        case .hearing: return "person.badge.clock.fill"
        }
    }

    private var tint: Color {
        switch matter.kind {
        case .calendarCall: return .purple
        case .trial: return Theme.gold
        case .hearing: return Theme.defense
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: icon).foregroundStyle(tint).frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if let start = matter.start, !matter.carriesOver {
                            Text("~" + CourtCalendar.time(start)).font(.caption.monospacedDigit().weight(.semibold)).foregroundStyle(Theme.gold)
                        }
                        Text(hoursText(matter.minutes)).font(.caption2).foregroundStyle(.secondary)
                        if case .expected = matter.source { Pill(text: "Expected", color: .secondary) }
                    }
                    Text(matter.title).font(.subheadline.weight(.semibold))
                    Text(matter.subtitle).font(.caption).foregroundStyle(.secondary)
                    ForEach(matter.notes, id: \.self) { note in
                        Text("• " + note).font(.caption2).foregroundStyle(note.hasPrefix("Past this week") ? Theme.bad : Theme.quoteText)
                    }
                }
            }
            if matter.canContinue || matter.courtCase != nil {
                HStack(spacing: 8) {
                    if let c = matter.courtCase {
                        Button { onCaseFile(c) } label: { Label("Case file", systemImage: "folder.fill") }
                            .buttonStyle(.bordered).tint(.secondary)
                    }
                    if matter.canContinue {
                        Button { onContinue(matter) } label: { Label("Continue", systemImage: "calendar.badge.clock") }
                            .buttonStyle(.bordered).tint(Theme.gold)
                    }
                }
                .font(.caption.weight(.semibold))
                .padding(.leading, 32)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.raised.opacity(matter.carriesOver ? 0.4 : 0.7)))
    }
}

private struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: event.icon).foregroundStyle(Theme.gold).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).font(.subheadline.weight(.semibold))
                Text(event.detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Looking ahead

private struct UpcomingWeeks: View {
    let plans: [WeekPlan]
    let selectedWeek: Date
    let onSelect: (Date) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "Weeks ahead", icon: "calendar")
            ForEach(plans.prefix(10)) { plan in
                Button { Haptics.tap(); onSelect(plan.monday) } label: {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2).fill(plan.load.color).frame(width: 4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(CourtCalendar.weekTitle(plan.monday)).font(.subheadline.weight(.semibold))
                            Text(weekLine(plan)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(plan.load.label).font(.caption.weight(.semibold)).foregroundStyle(plan.load.color)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(CourtCalendar.isSameDay(plan.monday, selectedWeek) ? Theme.raised : Theme.surface))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func weekLine(_ plan: WeekPlan) -> String {
        if plan.courtDays.isEmpty { return "Courthouse closed" }
        var parts = ["\(plan.trialsSet)/\(plan.cap) trials", "~\(hoursText(plan.plannedMinutes))"]
        if plan.carryingOver > 0 { parts.append("\(plan.carryingOver) waiting") }
        if !plan.holidays.isEmpty { parts.append("\(plan.courtDays.count)-day week") }
        let hearings = plan.matters.filter { $0.kind == .hearing }.count
        if hearings > 0 { parts.append("\(hearings) hearing\(hearings == 1 ? "" : "s")") }
        return parts.joined(separator: " · ")
    }
}

private struct UpcomingEvents: View {
    let events: [CalendarEvent]
    let orders: [ArrestOrder]
    let on: Date

    var body: some View {
        let outstanding = orders.filter { !$0.resolved && !$0.served && $0.servedOn > on }
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(text: "Also coming up", icon: "bell.fill")
            if events.isEmpty && outstanding.isEmpty {
                Text("No appeals, releases or other dates in the next few months.").font(.caption).foregroundStyle(.secondary)
            }
            ForEach(events.prefix(20)) { event in
                HStack(alignment: .top, spacing: 10) {
                    Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.caption.monospacedDigit().weight(.semibold)).foregroundStyle(Theme.gold)
                        .frame(width: 48, alignment: .leading)
                    EventRow(event: event)
                }
            }
            if !outstanding.isEmpty {
                Label("\(outstanding.count) order\(outstanding.count == 1 ? "" : "s") for arrest not yet served. When one is served, the case is set for trial.", systemImage: "exclamationmark.shield.fill")
                    .font(.caption).foregroundStyle(.orange)
            }
        }
        .card()
    }
}

// MARK: - Continuing a matter

private struct ContinueSheet: View {
    let matter: PlannedMatter
    let plans: [WeekPlan]
    let onChoose: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var choice: Date?

    var body: some View {
        NavigationStack {
            FixedWidthScroll {
                VStack(alignment: .leading, spacing: 12) {
                    Text(matter.title).font(.system(.title3, design: .serif).weight(.bold))
                    Text(matter.subtitle).font(.caption).foregroundStyle(.secondary)
                    Text("The court resets this matter because the calendar is too full. Neither side asked for it, so it doesn't count against either one. Pick a week with room.")
                        .font(.callout)
                    if matter.courtCase?.background?.isJailed == true {
                        Label("The defendant is in jail. Every week of delay is another week held before trial.", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundStyle(.orange)
                    }
                    ForEach(plans.dropFirst().filter { !$0.courtDays.isEmpty }.prefix(10)) { plan in
                        let current = plan.matters.contains { $0.id == matter.id }
                        Button { Haptics.tap(); choice = plan.monday } label: {
                            HStack(spacing: 10) {
                                Image(systemName: choice == plan.monday ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(Theme.gold)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(CourtCalendar.weekTitle(plan.monday)).font(.subheadline.weight(.semibold))
                                    Text("\(plan.trialsSet)/\(plan.cap) trials · ~\(hoursText(plan.plannedMinutes)) of \(hoursText(plan.capacity))"
                                         + (plan.holidays.isEmpty ? "" : " · \(plan.courtDays.count)-day week")
                                         + (current ? " · now set here" : ""))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(plan.load.label).font(.caption.weight(.semibold)).foregroundStyle(plan.load.color)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(choice == plan.monday ? Theme.raised : Theme.surface))
                        }
                        .buttonStyle(.plain)
                        .disabled(current)
                        .opacity(current ? 0.5 : 1)
                    }
                    Button {
                        if let choice { Haptics.gavel(); onChoose(choice) }
                    } label: {
                        Text(choice.map { "Continue to the " + CourtCalendar.weekTitle($0).lowercasedFirstWord } ?? "Choose a week")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)
                    .disabled(choice == nil)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Continue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

private extension String {
    /// "Week of …" → "week of …"
    var lowercasedFirstWord: String {
        guard let first = self.first else { return self }
        return first.lowercased() + String(self.dropFirst())
    }
}
