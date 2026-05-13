import UIKit

/// Lightweight haptics facade. All methods must be called from the main thread
/// (SwiftUI guarantees this from view bodies, gesture callbacks, and Binding setters).
enum Haptics {
    private static let selectionGen = UISelectionFeedbackGenerator()
    private static let lightImpact  = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let rigidImpact  = UIImpactFeedbackGenerator(style: .rigid)
    private static let softImpact   = UIImpactFeedbackGenerator(style: .soft)
    private static let notification = UINotificationFeedbackGenerator()

    nonisolated(unsafe) static var enabled: Bool = true

    static func selection() {
        guard enabled else { return }
        selectionGen.selectionChanged()
    }

    static func tap() {
        guard enabled else { return }
        softImpact.impactOccurred(intensity: 0.6)
    }

    static func light() {
        guard enabled else { return }
        lightImpact.impactOccurred()
    }

    static func medium() {
        guard enabled else { return }
        mediumImpact.impactOccurred()
    }

    static func snap() {
        guard enabled else { return }
        rigidImpact.impactOccurred(intensity: 0.85)
    }

    static func success() {
        guard enabled else { return }
        notification.notificationOccurred(.success)
    }

    static func warning() {
        guard enabled else { return }
        notification.notificationOccurred(.warning)
    }

    static func error() {
        guard enabled else { return }
        notification.notificationOccurred(.error)
    }
}
