import SwiftUI

enum AppColors {
    // Core surfaces
    static let background     = Color(red: 0.03, green: 0.02, blue: 0.07)   // deep cosmic black
    static let surface        = Color(red: 0.07, green: 0.06, blue: 0.13)
    static let surfaceElevated = Color(red: 0.11, green: 0.09, blue: 0.18)
    static let glassStroke    = Color.white.opacity(0.08)

    // Brand palette
    static let violet   = Color(red: 0.49, green: 0.27, blue: 0.95)   // electric violet
    static let neon     = Color(red: 0.66, green: 0.35, blue: 1.00)   // neon purple
    static let indigo   = Color(red: 0.22, green: 0.18, blue: 0.78)   // indigo glow
    static let aqua     = Color(red: 0.35, green: 0.80, blue: 1.00)   // accent highlight
    static let magenta  = Color(red: 0.95, green: 0.30, blue: 0.78)

    // Semantic
    static let accent       = violet
    static let primaryText  = Color.white
    static let subtleText   = Color.white.opacity(0.62)
    static let mutedText    = Color.white.opacity(0.42)
    static let danger       = Color(red: 1.0, green: 0.35, blue: 0.42)
    static let success      = Color(red: 0.40, green: 0.95, blue: 0.65)
    static let warning      = Color(red: 1.0, green: 0.78, blue: 0.32)
}
