import SwiftUI

struct CastListView: View {
    let cast: [CastMember]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Spacing.m) {
                ForEach(cast) { member in
                    VStack(spacing: 8) {
                        ZStack {
                            AppGradients.posterFallback(for: member.id.hashValue)
                            Text(initials(of: member.name))
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.glassStroke, lineWidth: 1))
                        .glow(color: AppColors.violet, radius: 12, intensity: 0.35)

                        Text(member.name)
                            .font(AppTypography.subhead)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)
                        Text(member.role)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.subtleText)
                    }
                    .frame(width: 92)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func initials(of name: String) -> String {
        name.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
    }
}

// MARK: - Preview

#Preview {
    let cast = [
        CastMember(id: "1", name: "Cillian Murphy", role: "J. Robert Oppenheimer"),
        CastMember(id: "2", name: "Emily Blunt", role: "Kitty Oppenheimer"),
        CastMember(id: "3", name: "Matt Damon", role: "Leslie Groves"),
        CastMember(id: "4", name: "Robert Downey Jr.", role: "Lewis Strauss")
    ]
    ZStack {
        AppColors.background.ignoresSafeArea()
        CastListView(cast: cast)
    }
    .preferredColorScheme(.dark)
}
