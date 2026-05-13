import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var fullWidth: Bool = true
    var style: Style = .accent
    var action: () -> Void

    enum Style { case accent, glass, danger }

    var body: some View {
        Button {
            Haptics.medium()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if style == .glass {
                    Capsule().stroke(AppColors.glassStroke, lineWidth: 1)
                }
            }
            .shadow(color: glowColor.opacity(style == .glass ? 0 : 0.5), radius: 18, y: 8)
        }
        .buttonStyle(.pressable)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .accent: AppGradients.accent
        case .glass:  Color.white.opacity(0.08).background(.ultraThinMaterial)
        case .danger: AppGradients.danger
        }
    }

    private var foreground: Color {
        switch style {
        case .accent, .danger: .white
        case .glass: AppColors.primaryText
        }
    }

    private var glowColor: Color {
        switch style {
        case .accent: AppColors.violet
        case .glass:  .clear
        case .danger: AppColors.danger
        }
    }
}
