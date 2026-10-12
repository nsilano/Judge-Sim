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
                    Text(law.title)
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
struct RulingPicker: View {
    let first: String
    let second: String
    @Binding var selection: Bool?

    var body: some View {
        HStack(spacing: 10) {
            option(first, value: true)
            option(second, value: false)
        }
    }

    private func option(_ title: String, value: Bool) -> some View {
        let isSelected = selection == value
        return Button {
            withAnimation(.snappy) { selection = value }
        } label: {
            Text(title)
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? Theme.gold : Color(.tertiarySystemFill))
                )
                .foregroundStyle(isSelected ? Color.black : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String = "chevron.right"
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
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
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
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
