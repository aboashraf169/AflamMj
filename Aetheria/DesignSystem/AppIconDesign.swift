import SwiftUI

/// SwiftUI rendering of the AflamMj app icon.
/// Use the included `#Preview` to export at 1024×1024 — right-click the
/// preview → "Export Preview…" — then drop the PNG into AppIcon.appiconset.
struct AflamMjAppIcon: View {
    var size: CGFloat = 1024

    var body: some View {
        ZStack {
            // Deep cosmic background
            RadialGradient(
                colors: [
                    Color(red: 0.10, green: 0.06, blue: 0.22),
                    Color(red: 0.02, green: 0.01, blue: 0.06)
                ],
                center: .center,
                startRadius: size * 0.05,
                endRadius: size * 0.7
            )

            // Soft violet aura
            Circle()
                .fill(Color(red: 0.49, green: 0.27, blue: 0.95).opacity(0.55))
                .frame(width: size * 0.55, height: size * 0.55)
                .blur(radius: size * 0.13)
                .offset(x: -size * 0.05, y: -size * 0.08)

            Circle()
                .fill(Color(red: 0.22, green: 0.18, blue: 0.78).opacity(0.45))
                .frame(width: size * 0.45, height: size * 0.45)
                .blur(radius: size * 0.16)
                .offset(x: size * 0.12, y: size * 0.18)

            // Geometric diamond mark
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.66, green: 0.35, blue: 1.00),
                                Color(red: 0.49, green: 0.27, blue: 0.95),
                                Color(red: 0.22, green: 0.18, blue: 0.78)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.46, height: size * 0.46)
                    .rotationEffect(.degrees(45))
                    .shadow(color: Color(red: 0.66, green: 0.35, blue: 1.0).opacity(0.7), radius: size * 0.08)

                // Inner glow ring
                RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.7), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: size * 0.008
                    )
                    .frame(width: size * 0.46, height: size * 0.46)
                    .rotationEffect(.degrees(45))

                // Central "A" mark — bold geometric
                AflamMjMark()
                    .fill(
                        LinearGradient(
                            colors: [.white, Color(red: 0.92, green: 0.95, blue: 1.0)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        style: FillStyle(eoFill: true)
                    )
                    .frame(width: size * 0.22, height: size * 0.28)
                    .shadow(color: .black.opacity(0.35), radius: size * 0.01, y: size * 0.005)
            }

            // Top-left starlight
            Circle()
                .fill(.white)
                .frame(width: size * 0.012, height: size * 0.012)
                .offset(x: -size * 0.3, y: -size * 0.32)
                .shadow(color: .white, radius: size * 0.01)

            Circle()
                .fill(.white)
                .frame(width: size * 0.008, height: size * 0.008)
                .offset(x: size * 0.28, y: -size * 0.26)
                .shadow(color: .white, radius: size * 0.008)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

/// Geometric "A" mark — two diagonals + cross-bar, drawn as a single path.
private struct AflamMjMark: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let stroke = w * 0.18
        let apex   = CGPoint(x: rect.midX, y: rect.minY)
        let leftB  = CGPoint(x: rect.minX, y: rect.maxY)
        let rightB = CGPoint(x: rect.maxX, y: rect.maxY)

        // Outer triangle
        p.move(to: apex)
        p.addLine(to: leftB)
        p.addLine(to: rightB)
        p.closeSubpath()

        // Inner hole — smaller triangle, leaves the "A" outline
        let inset: CGFloat = stroke
        var inner = Path()
        inner.move(to: CGPoint(x: rect.midX, y: rect.minY + inset * 1.4))
        inner.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset * 0.6))
        inner.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset * 0.6))
        inner.closeSubpath()
        p.addPath(inner)

        // Cross-bar gap — punched as a rectangle
        let barY = rect.minY + h * 0.62
        let barRect = CGRect(x: rect.minX + inset * 1.6, y: barY,
                             width: w - inset * 3.2, height: stroke * 0.7)
        p.addRect(barRect)

        return p
    }
}

#Preview("App Icon — 1024") {
    AflamMjAppIcon(size: 1024)
        .frame(width: 1024, height: 1024)
        .background(.black)
}

#Preview("App Icon — 256") {
    AflamMjAppIcon(size: 256)
        .frame(width: 256, height: 256)
        .background(.black)
}
