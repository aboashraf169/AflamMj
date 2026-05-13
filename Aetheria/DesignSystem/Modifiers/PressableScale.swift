import SwiftUI

struct PressableScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    var hapticOnPress: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed && hapticOnPress { Haptics.tap() }
            }
    }
}

extension ButtonStyle where Self == PressableScaleStyle {
    static var pressable: PressableScaleStyle { PressableScaleStyle() }
    static func pressable(scale: CGFloat) -> PressableScaleStyle {
        PressableScaleStyle(scale: scale)
    }
}
