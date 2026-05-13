import SwiftUI

struct ContentRow: View {
    let title: String
    var subtitle: String? = nil
    let movies: [Movie]
    var namespace: Namespace.ID
    var posterWidth: CGFloat = ScreenMetrics.rowPosterWidth
    var onSeeAll: (() -> Void)? = nil
    var onSelect: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title, subtitle: subtitle, action: onSeeAll)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.s) {
                    ForEach(movies) { movie in
                        Button {
                            Haptics.selection()
                            onSelect(movie)
                        } label: {
                            PosterCard(
                                movie: movie,
                                width: posterWidth,
                                namespace: namespace,
                                heroID: "poster-\(movie.id)"
                            )
                        }
                        .buttonStyle(.pressable(scale: 0.95))
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, 4)
            }
        }
    }
}

struct FeaturedRow: View {
    let title: String
    let movies: [Movie]
    var namespace: Namespace.ID
    var onSelect: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title, subtitle: "Reserved for the bold.", action: {})

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.s) {
                    ForEach(movies) { movie in
                        FeaturedCard(movie: movie, namespace: namespace) {
                            onSelect(movie)
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
            }
        }
    }
}

// MARK: - Previews

private let previewMovie = Movie(
    id: "1", title: "Interstellar", tagline: "Mankind was born on Earth.", synopsis: "A team of explorers travel through a wormhole in space.",
    year: "2014", duration: 169, rating: 8.7, kind: .movie,
    genres: [.sciFi, .drama], cast: [], director: "Christopher Nolan",
    isExclusive: true, streamURL: URL(string: "https://example.com/stream")!,
    trailerURL: nil, availableQualities: [.hd, .fhd], subtitleLanguages: ["English"], seasons: []
)

#Preview("ContentRow") {
    @Previewable @Namespace var ns
    ZStack {
        AppColors.background.ignoresSafeArea()
        ContentRow(title: "Trending Now", subtitle: "Hot this week", movies: [previewMovie, previewMovie], namespace: ns) { _ in }
            .padding(.vertical)
    }
    .preferredColorScheme(.dark)
}

#Preview("FeaturedRow") {
    @Previewable @Namespace var ns
    ZStack {
        AppColors.background.ignoresSafeArea()
        FeaturedRow(title: "Aetheria Originals", movies: [previewMovie, previewMovie], namespace: ns) { _ in }
            .padding(.vertical)
    }
    .preferredColorScheme(.dark)
}

private struct FeaturedCard: View {
    let movie: Movie
    let namespace: Namespace.ID
    let onTap: () -> Void

    private let cardWidth = ScreenMetrics.featuredCardWidth

    var body: some View {
        Button {
            Haptics.selection()
            onTap()
        } label: {
            ZStack(alignment: .bottomLeading) {
                AppGradients.posterFallback(for: movie.id.hashValue)
                LinearGradient(
                    colors: [.clear, AppColors.background.opacity(0.85)],
                    startPoint: .top, endPoint: .bottom
                )
                VStack(alignment: .leading, spacing: 4) {
                    if movie.isExclusive { ExclusiveBadge() }
                    Text(movie.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(movie.primaryGenres)
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }
                .padding(12)
            }
            .frame(width: cardWidth, height: cardWidth * 0.6)
            .clipShape(RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    .stroke(AppColors.glassStroke, lineWidth: 1)
            )
            .cardShadow()
        }
        .buttonStyle(.pressable(scale: 0.96))
    }
}
