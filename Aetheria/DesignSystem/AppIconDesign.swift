import SwiftUI

/// SwiftUI rendering of the AflamMj app icon.
/// Open this file in Xcode, right-click the Preview canvas →
/// "Export Preview…" → save as PNG and drop into AppIcon.appiconset.
struct AflamMjAppIcon: View {
    var size: CGFloat = 512

    // Cap blur so the Preview renderer doesn't crash on large sizes
    private func blur(_ fraction: CGFloat) -> CGFloat {
        min(size * fraction, 24)
    }

    var body: some View {
        let violet = Color(red: 0.49, green: 0.27, blue: 0.95)
        let neon   = Color(red: 0.66, green: 0.35, blue: 1.00)
        let indigo = Color(red: 0.22, green: 0.18, blue: 0.78)
        let aqua   = Color(red: 0.35, green: 0.80, blue: 1.00)

        ZStack {

            // ── Background ──────────────────────────────────────────────────
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.03, blue: 0.16),
                         Color(red: 0.01, green: 0.01, blue: 0.05)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color(red: 0.30, green: 0.10, blue: 0.55).opacity(0.7), .clear],
                center: UnitPoint(x: 0.5, y: 0.18),
                startRadius: 0, endRadius: size * 0.65
            )

            // ── Ambient glow blobs ──────────────────────────────────────────
            Circle().fill(aqua.opacity(0.18))
                .frame(width: size * 0.6).blur(radius: blur(0.18))
                .offset(x: size * 0.22, y: size * 0.28)
            Circle().fill(violet.opacity(0.45))
                .frame(width: size * 0.55).blur(radius: blur(0.16))
                .offset(x: -size * 0.18, y: -size * 0.12)
            Circle().fill(neon.opacity(0.22))
                .frame(width: size * 0.38).blur(radius: blur(0.10))

            // ── Film strip bars ─────────────────────────────────────────────
            RoundedRectangle(cornerRadius: size * 0.012)
                .fill(Color.white.opacity(0.07))
                .frame(width: size * 0.78, height: size * 0.07)
                .offset(y: -size * 0.33)
            RoundedRectangle(cornerRadius: size * 0.012)
                .fill(Color.white.opacity(0.07))
                .frame(width: size * 0.78, height: size * 0.07)
                .offset(y: size * 0.33)

            // ── Film strip holes (top) ──────────────────────────────────────
            HStack(spacing: size * 0.095) {
                filmHole(size: size)
                filmHole(size: size)
                filmHole(size: size)
                filmHole(size: size)
                filmHole(size: size)
            }
            .offset(y: -size * 0.33)

            // ── Film strip holes (bottom) ───────────────────────────────────
            HStack(spacing: size * 0.095) {
                filmHole(size: size)
                filmHole(size: size)
                filmHole(size: size)
                filmHole(size: size)
                filmHole(size: size)
            }
            .offset(y: size * 0.33)

            // ── Glass card ──────────────────────────────────────────────────
            RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.14), Color.white.opacity(0.04)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.52, height: size * 0.52)
                .shadow(color: violet.opacity(0.55), radius: min(size * 0.07, 18))
            RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.005)
                .frame(width: size * 0.52, height: size * 0.52)

            // ── Glow circle ─────────────────────────────────────────────────
            Circle()
                .fill(LinearGradient(
                    colors: [neon, violet, indigo],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.30)
                .shadow(color: neon.opacity(0.8), radius: min(size * 0.06, 16))

            // ── Play triangle ───────────────────────────────────────────────
            PlayTriangle()
                .fill(Color.white)
                .frame(width: size * 0.12, height: size * 0.13)
                .offset(x: size * 0.012)

            // ── Outer glow ring ─────────────────────────────────────────────
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [neon.opacity(0.8), violet.opacity(0.4),
                                 aqua.opacity(0.5), neon.opacity(0.1), neon.opacity(0.8)],
                        center: .center),
                    lineWidth: size * 0.006)
                .frame(width: size * 0.63)

            // ── Stars ───────────────────────────────────────────────────────
            Circle().fill(Color.white.opacity(0.9))
                .frame(width: size * 0.013)
                .offset(x: -size * 0.32, y: -size * 0.30)
            Circle().fill(Color.white.opacity(0.7))
                .frame(width: size * 0.009)
                .offset(x: size * 0.30, y: -size * 0.24)
            Circle().fill(Color.white.opacity(0.6))
                .frame(width: size * 0.007)
                .offset(x: -size * 0.26, y: size * 0.31)
            Circle().fill(Color.white.opacity(0.5))
                .frame(width: size * 0.006)
                .offset(x: size * 0.34, y: size * 0.27)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

private func filmHole(size: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: size * 0.007)
        .fill(Color.white.opacity(0.14))
        .frame(width: size * 0.046, height: size * 0.036)
}

private struct PlayTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to:    CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Previews

#Preview("App Icon — 120") {
    AflamMjAppIcon(size: 120)
        .frame(width: 120, height: 120)
        .background(.black)
}

#Preview("App Icon — 256") {
    AflamMjAppIcon(size: 256)
        .frame(width: 256, height: 256)
        .background(.black)
}
