import SwiftUI

/// Subtle 3D tilt driven by drag for premium spatial feel.
struct ParallaxTilt: ViewModifier {
    var maxAngle: Double = 10
    @State private var translation: CGSize = .zero
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(Double(-translation.height / 8).clamped(to: -maxAngle...maxAngle)),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.85
            )
            .rotation3DEffect(
                .degrees(Double(translation.width / 8).clamped(to: -maxAngle...maxAngle)),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.85
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isPressed = true
                        translation = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                            translation = .zero
                            isPressed = false
                        }
                    }
            )
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: translation)
    }
}

extension View {
    func parallaxTilt(maxAngle: Double = 10) -> some View {
        modifier(ParallaxTilt(maxAngle: maxAngle))
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
