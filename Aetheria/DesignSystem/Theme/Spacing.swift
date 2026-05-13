import SwiftUI
import CoreGraphics

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let s:   CGFloat = 12
    static let m:   CGFloat = 16
    static let l:   CGFloat = 20
    static let xl:  CGFloat = 28
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 56
}

enum Radius {
    static let xs: CGFloat = 8
    static let s:  CGFloat = 12
    static let m:  CGFloat = 18
    static let l:  CGFloat = 24
    static let xl: CGFloat = 32
    static let pill: CGFloat = 999
}

enum AppShadows {
    static func card(_ color: Color = .black) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.45), radius: 18, x: 0, y: 12)
    }
}

extension View {
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.45), radius: 18, x: 0, y: 12)
    }

    func deepShadow() -> some View {
        self.shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 18)
    }
}
