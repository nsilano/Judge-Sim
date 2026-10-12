import SwiftUI
import UIKit

enum Theme {
    static let gold = Color("AccentColor")
    static let mahogany = Color(red: 0.42, green: 0.18, blue: 0.11)
    static let prosecution = Color(red: 0.70, green: 0.20, blue: 0.20)
    static let defense = Color(red: 0.18, green: 0.38, blue: 0.68)
    static let good = Color.green
    static let bad = Color.red

    static func color(for side: Side) -> Color {
        side == .prosecution ? prosecution : defense
    }

    static let serif = Font.system(.title2, design: .serif).weight(.bold)
}

struct CardModifier: ViewModifier {
    var tint: Color? = nil

    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder((tint ?? .clear).opacity(0.55), lineWidth: tint == nil ? 0 : 1.5)
            )
    }
}

extension View {
    func card(tint: Color? = nil) -> some View {
        modifier(CardModifier(tint: tint))
    }
}

struct SectionTitle: View {
    let text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon).foregroundStyle(Theme.gold)
            }
            Text(text.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

struct Pill: View {
    let text: String
    var color: Color = .secondary
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon) }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(color)
        .background(Capsule().fill(color.opacity(0.14)))
    }
}

struct Meter: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(value)")
                    .font(.subheadline.monospacedDigit().weight(.bold))
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.tertiarySystemFill))
                    Capsule().fill(color)
                        .frame(width: proxy.size.width * CGFloat(max(0, min(100, value))) / 100)
                }
            }
            .frame(height: 8)
        }
    }
}

struct BulletList: View {
    let items: [String]
    var symbol: String = "circle.fill"
    var color: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: symbol)
                        .font(.system(size: symbol == "circle.fill" ? 6 : 13))
                        .foregroundStyle(color)
                    Text(item)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

/// A tappable chip that opens a Law Library entry.
struct LawLink: View {
    let lawID: String

    var body: some View {
        if let law = LawLibrary.lawIfPresent(lawID) {
            NavigationLink {
                LawDetailView(law: law)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "book.closed.fill")
                    Text("Law: \(law.title)")
                        .lineLimit(1)
                }
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.gold.opacity(0.18)))
                .foregroundStyle(Theme.gold)
            }
            .buttonStyle(.plain)
        }
    }
}

/// Two-option ruling control, e.g. Sustained / Overruled.
/// Two-option ruling control, e.g. Sustain / Overrule, with an optional explanation of each.
struct RulingPicker: View {
    let first: String
    let second: String
    var firstDetail: String? = nil
    var secondDetail: String? = nil
    @Binding var selection: Bool?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            option(first, detail: firstDetail, value: true)
            option(second, detail: secondDetail, value: false)
        }
    }

    private func option(_ title: String, detail: String?, value: Bool) -> some View {
        let isSelected = selection == value
        return Button {
            Haptics.tap()
            withAnimation(.snappy) { selection = value }
        } label: {
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    if isSelected { Image(systemName: "checkmark.circle.fill") }
                    Text(title).font(.subheadline.weight(.bold))
                }
                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .opacity(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Theme.gold : Color(.tertiarySystemFill))
            )
            .foregroundStyle(isSelected ? Color.black : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

/// The main action at the bottom of each screen. When disabled, says what's still needed.
struct PrimaryButton: View {
    let title: String
    var icon: String = "chevron.right"
    var enabled: Bool = true
    var hint: String? = nil
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                HStack {
                    Text(title).font(.headline)
                    Image(systemName: icon)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(enabled ? Theme.mahogany : Color(.systemGray4))
                )
                .foregroundStyle(enabled ? Color.white : Color.secondary)
            }
            .buttonStyle(.plain)
            .disabled(!enabled)

            if !enabled, let hint {
                Label(hint, systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 4)
    }
}

/// A collapsible card section, used to keep long screens manageable.
struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    var summary: String? = nil
    @State var expanded: Bool
    @ViewBuilder let content: () -> Content

    init(title: String, icon: String, summary: String? = nil, expanded: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.summary = summary
        self._expanded = State(initialValue: expanded)
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) { expanded.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon).foregroundStyle(Theme.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.headline)
                        if let summary, !expanded {
                            Text(summary).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(expanded ? 0 : -90))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                content()
            }
        }
        .card()
    }
}

enum Haptics {
    static func gavel() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

/// The app's marketing version and build number, read from the bundle.
struct VersionBadge: View {
    static var text: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "v\(version) (\(build))"
    }

    var body: some View {
        Text(Self.text)
            .font(.caption2.monospaced().weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color(.tertiarySystemFill)))
            .accessibilityLabel("Version \(Self.text)")
    }
}
