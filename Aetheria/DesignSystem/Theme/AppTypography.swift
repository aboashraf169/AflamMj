import SwiftUI

enum AppTypography {
    static let display      = Font.system(size: 40, weight: .heavy,    design: .rounded)
    static let title        = Font.system(size: 28, weight: .bold,     design: .rounded)
    static let title2       = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let sectionTitle = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline     = Font.system(size: 17, weight: .semibold, design: .default)
    static let body         = Font.system(size: 15, weight: .regular,  design: .default)
    static let subhead      = Font.system(size: 14, weight: .medium,   design: .default)
    static let caption      = Font.system(size: 11, weight: .medium,   design: .rounded)
    static let mono         = Font.system(size: 13, weight: .medium,   design: .monospaced)
}
