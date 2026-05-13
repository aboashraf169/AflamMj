import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Radius.l
    var padding: CGFloat = Spacing.m
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AppGradients.glass)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(AppGradients.cardEdge, lineWidth: 1)
                    }
            }
            .cardShadow()
    }
}
