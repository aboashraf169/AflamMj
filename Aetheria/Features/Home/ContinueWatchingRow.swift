import SwiftUI

struct ContinueWatchingRow: View {
    let movies: [Movie]
    var namespace: Namespace.ID
    var onSelect: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Continue watching", subtitle: "Pick up where you left off.", action: {})

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.s) {
                    ForEach(Array(movies.enumerated()), id: \.element.id) { idx, movie in
                        ContinueCard(
                            movie: movie,
                            progress: Double((idx + 2) * 13).truncatingRemainder(dividingBy: 100) / 100.0
                        ) {
                            onSelect(movie)
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var ns
    let movie = Movie(
        id: "1", title: "Dune: Part Two", tagline: "Long live the fighters.", synopsis: "Paul Atreides unites with Chani.",
        year: "2024", duration: 167, rating: 8.8, kind: .movie,
        genres: [.sciFi, .action], cast: [], director: "Denis Villeneuve",
        isExclusive: false, streamURL: URL(string: "https://example.com/stream")!,
        trailerURL: nil, availableQualities: [.fhd], subtitleLanguages: [], seasons: []
    )
    ZStack {
        AppColors.background.ignoresSafeArea()
        ContinueWatchingRow(movies: [movie, movie, movie], namespace: ns) { _ in }
    }
    .preferredColorScheme(.dark)
}

private struct ContinueCard: View {
    let movie: Movie
    let progress: Double
    let onTap: () -> Void

    private let tileWidth: CGFloat = ScreenMetrics.continueTileWidth

    var body: some View {
        Button {
            Haptics.selection()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    AppGradients.posterFallback(for: movie.id.hashValue)
                    LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 10)
                        .glow(color: AppColors.violet, radius: 16, intensity: 0.6)
                }
                .frame(width: tileWidth, height: tileWidth * 0.58)
                .clipShape(RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
                .overlay(alignment: .bottom) {
                    ProgressView(value: max(0.08, progress))
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.violet))
                        .scaleEffect(x: 1, y: 1.4, anchor: .center)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title)
                        .font(AppTypography.subhead)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                    Text("\(Int((1.0 - max(0.08, progress)) * Double(movie.duration))) min left")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.subtleText)
                }
                .frame(width: tileWidth, alignment: .leading)
            }
        }
        .buttonStyle(.pressable(scale: 0.96))
    }
}
