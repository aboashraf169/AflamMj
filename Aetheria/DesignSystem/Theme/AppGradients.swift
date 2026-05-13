import SwiftUI

enum AppGradients {
    static let accent = LinearGradient(
        colors: [AppColors.violet, AppColors.neon],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentHorizontal = LinearGradient(
        colors: [AppColors.indigo, AppColors.violet, AppColors.neon],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let heroOverlay = LinearGradient(
        stops: [
            .init(color: .clear, location: 0.0),
            .init(color: AppColors.background.opacity(0.45), location: 0.55),
            .init(color: AppColors.background.opacity(0.95), location: 0.92),
            .init(color: AppColors.background, location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let posterShine = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.00),
            Color.white.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardEdge = LinearGradient(
        colors: [Color.white.opacity(0.18), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glass = LinearGradient(
        colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let danger = LinearGradient(
        colors: [Color(red: 1.0, green: 0.30, blue: 0.55), Color(red: 0.95, green: 0.20, blue: 0.30)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func posterFallback(for seed: Int) -> LinearGradient {
        let palettes: [[Color]] = [
            [AppColors.violet, AppColors.indigo],
            [AppColors.indigo, AppColors.aqua],
            [AppColors.magenta, AppColors.violet],
            [AppColors.neon, AppColors.indigo],
            [Color(red: 0.10, green: 0.50, blue: 0.90), AppColors.violet],
            [Color(red: 0.95, green: 0.45, blue: 0.20), AppColors.magenta],
            [Color(red: 0.20, green: 0.60, blue: 0.50), AppColors.indigo],
            [Color(red: 0.80, green: 0.20, blue: 0.45), AppColors.violet]
        ]
        return LinearGradient(
            colors: palettes[abs(seed) % palettes.count],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
