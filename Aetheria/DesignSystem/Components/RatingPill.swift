import SwiftUI

struct RatingPill: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(AppColors.warning)
            Text(String(format: "%.1f", rating))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
    }
}

struct ExclusiveBadge: View {
    var body: some View {
        Text("EXCLUSIVE")
            .font(.system(size: 8, weight: .heavy, design: .rounded))
            .tracking(0.8)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(AppGradients.accent, in: Capsule())
            .glow(color: AppColors.violet, radius: 8, intensity: 0.6)
    }
}
