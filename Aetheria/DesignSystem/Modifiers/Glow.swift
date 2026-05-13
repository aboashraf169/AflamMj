import SwiftUI

struct Glow: ViewModifier {
    var color: Color = AppColors.violet
    var radius: CGFloat = 22
    var intensity: Double = 0.7

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(intensity * 0.5), radius: radius * 1.6, x: 0, y: 0)
    }
}

extension View {
    func glow(color: Color = AppColors.violet, radius: CGFloat = 22, intensity: Double = 0.7) -> some View {
        modifier(Glow(color: color, radius: radius, intensity: intensity))
    }
}
