import SwiftUI

enum AppAnimations {
    static let buttonSpring: Animation = .spring(response: 0.32, dampingFraction: 0.65)
    static let cardSpring:   Animation = .spring(response: 0.55, dampingFraction: 0.78)
    static let heroSpring:   Animation = .spring(response: 0.7,  dampingFraction: 0.82)
    static let smooth:       Animation = .smooth(duration: 0.35)
    static let fade:         Animation = .easeInOut(duration: 0.25)
    static let cinematic:    Animation = .interpolatingSpring(stiffness: 180, damping: 22)
}
