import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailing: String? = "See all"
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(AppColors.subtleText)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            if let trailing, let action {
                Button(action: {
                    Haptics.selection()
                    action()
                }) {
                    HStack(spacing: 4) {
                        Text(trailing)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(AppTypography.subhead)
                    .foregroundStyle(AppColors.aqua)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
    }
}
