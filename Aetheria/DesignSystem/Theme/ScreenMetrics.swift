import SwiftUI
import CoreGraphics

/// Bounded, predictable sizing constants. Anything that needs the real
/// available space should use a `GeometryReader` locally instead of reading
/// global screen bounds (which can be wrong during scene transitions).
enum ScreenMetrics {
    /// Compute the hero carousel height from the screen height passed in.
    static func heroHeight(for height: CGFloat) -> CGFloat {
        min(max(420, height * 0.58), 560)
    }

    /// Compute the backdrop height in the details screen.
    static func backdropHeight(for height: CGFloat) -> CGFloat {
        min(max(300, height * 0.42), 420)
    }

    // Used inside ScrollViews (where GeometryReader collapses): conservative defaults
    static let rowPosterWidth: CGFloat = 118
    static let continueTileWidth: CGFloat = 220
    static let featuredCardWidth: CGFloat = 280
    static let gridPosterMin: CGFloat = 140
    static let gridPosterMax: CGFloat = 180

    /// Extra bottom padding to clear the floating tab bar.
    static let tabBarClearance: CGFloat = 110
}
