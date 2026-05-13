import SwiftUI

struct IconButton: View {
    let systemName: String
    var label: String? = nil
    var size: CGFloat = 18
    var tint: Color = .white
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(AppColors.glassStroke, lineWidth: 1))
                        .frame(width: 44, height: 44)
                    Image(systemName: systemName)
                        .font(.system(size: size, weight: .semibold))
                        .foregroundStyle(tint)
                }
                if let label {
                    Text(label)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.subtleText)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.pressable)
    }
}
