import SwiftUI

struct ChipView: View {
    let label: String
    var icon: String? = nil
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            Haptics.selection()
            action?()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(label)
                    .font(AppTypography.subhead)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : AppColors.subtleText)
            .background {
                if isSelected {
                    Capsule().fill(AppGradients.accent)
                } else {
                    Capsule().fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
                }
            }
        }
        .buttonStyle(.pressable)
    }
}
