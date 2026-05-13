import SwiftUI

struct MovieDetailsView: View {
    let movie: Movie
    var namespace: Namespace.ID
    var onPlay: () -> Void   // kept for callers that need a callback

    @StateObject private var vm: MovieDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var favoritesVM: FavoritesViewModel
    @State private var relatedMovie: Movie? = nil
    @State private var playingMovie: Movie? = nil

    init(movie: Movie, namespace: Namespace.ID, onPlay: @escaping () -> Void) {
        self.movie     = movie
        self.namespace = namespace
        self.onPlay    = onPlay
        _vm = StateObject(wrappedValue: MovieDetailsViewModel(movie: movie))
    }

    var body: some View {
        GeometryReader { proxy in
            let backdropH = ScreenMetrics.backdropHeight(for: proxy.size.height)

            ZStack(alignment: .top) {
                AppColors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        backdrop
                            .frame(height: backdropH)

                        contentStack
                            .padding(.top, Spacing.m)
                            .padding(.bottom, 60)
                    }
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(edges: .top)

                topBar
                    .padding(.horizontal, Spacing.l)
                    .padding(.top, 12)
            }
        }
        .task {
            vm.favoritesVM = favoritesVM
            await vm.load()
        }
        .sheet(item: $relatedMovie) { movie in
            MovieDetailsView(movie: movie, namespace: namespace) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    playingMovie = movie
                }
            }
            .presentationBackground(AppColors.background)
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $playingMovie) { movie in
            WebPlayerView(movie: movie)
        }
    }

    // MARK: - Backdrop (Bug-fix #1 & #2 — use real AsyncImage)

    private var backdrop: some View {
        ZStack(alignment: .bottomLeading) {
            // Real poster/backdrop image with gradient fallback
            GeometryReader { geo in
                backdropImage
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(AppGradients.heroOverlay)
            }

            VStack(alignment: .leading, spacing: 6) {
                if movie.isExclusive { ExclusiveBadge() }

                Text(movie.title)
                    .font(AppTypography.title2)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 10, y: 3)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                if !movie.tagline.isEmpty {
                    Text(movie.tagline)
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Prefers the 16:9 backdrop; falls back to the portrait poster; then gradient.
    @ViewBuilder
    private var backdropImage: some View {
        let url = (movie.backdropURL ?? movie.posterURL).flatMap { URL(string: $0) }

        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                default:
                    gradientFallback
                }
            }
        } else {
            gradientFallback
        }
    }

    private var gradientFallback: some View {
        AppGradients.posterFallback(for: movie.id.hashValue)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            CircularGlass(systemName: "xmark") {
                Haptics.tap(); dismiss()
            }
            Spacer()
            CircularGlass(systemName: "square.and.arrow.up") {
                Haptics.tap()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            metaRow
            actionsRow
            quickButtonsRow
            synopsisBlock
            castBlock

            if !movie.seasons.isEmpty {
                EpisodesListView(movie: movie, selectedSeasonID: $vm.selectedSeasonID) {
                    dismiss(); onPlay()
                }
            }

            preferencesBlock

            if !vm.related.isEmpty {
                ContentRow(
                    title: "More like this",
                    movies: vm.related,
                    namespace: namespace
                ) { relatedMovie = $0 }
            }
        }
    }

    private var metaRow: some View {
        HStack(spacing: 6) {
            Text(movie.year)
            Text("•")
            Text(movie.prettyDuration)
            Text("•")
            HStack(spacing: 3) {
                Image(systemName: "star.fill").foregroundStyle(AppColors.warning)
                Text(String(format: "%.1f", movie.rating))
            }
            Spacer(minLength: 4)
            Text(movie.primaryGenres)
                .foregroundStyle(AppColors.subtleText)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .font(AppTypography.caption)
        .foregroundStyle(AppColors.subtleText)
        .padding(.horizontal, Spacing.l)
    }

    private var actionsRow: some View {
        HStack(spacing: Spacing.xs) {
            PrimaryButton(title: "Play", icon: "play.fill", style: .accent) {
                // Dismiss the sheet first so the parent's fullScreenCover
                // can present the player without a presentation conflict.
                dismiss()
                onPlay()
            }
            PrimaryButton(
                title: vm.isFavorite ? "Saved" : "Save",
                icon: vm.isFavorite ? "heart.fill" : "heart",
                fullWidth: false,
                style: .glass
            ) { vm.toggleFavorite() }
        }
        .padding(.horizontal, Spacing.l)
    }

    private var quickButtonsRow: some View {
        HStack(spacing: 14) {
            IconButton(systemName: "arrow.down.circle.fill", label: "Download") { }
            IconButton(systemName: "play.rectangle.fill",   label: "Trailer")   { }
            IconButton(systemName: "person.2.fill",         label: "Party")     { }
            IconButton(systemName: "square.grid.2x2.fill",  label: "More")      { }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.l)
    }

    private var synopsisBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            Text(movie.synopsis)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.subtleText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Spacing.l)
    }

    private var castBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Cast & Crew")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
                if !movie.director.isEmpty {
                    Text("Dir. \(movie.director)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.subtleText)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, Spacing.l)
            CastListView(cast: movie.cast)
        }
    }

    private var preferencesBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Playback")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, Spacing.l)

            GlassCard {
                VStack(spacing: 12) {
                    PreferenceRow(label: "Quality",
                                  value: vm.selectedQuality.rawValue,
                                  icon: "sparkles")
                    Divider().overlay(AppColors.glassStroke)
                    PreferenceRow(label: "Subtitles",
                                  value: vm.selectedSubtitle,
                                  icon: "captions.bubble")
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var ns
    let movie = Movie(
        id: "872585", title: "Oppenheimer", tagline: "The world forever changes.", synopsis: "The story of J. Robert Oppenheimer and the Manhattan Project, told through the eyes of the brilliant physicist himself.",
        year: "2023", duration: 180, rating: 8.9, kind: .movie,
        genres: [.drama, .thriller, .sciFi], cast: [
            CastMember(id: "1", name: "Cillian Murphy", role: "Oppenheimer"),
            CastMember(id: "2", name: "Emily Blunt", role: "Kitty"),
            CastMember(id: "3", name: "Matt Damon", role: "Groves")
        ], director: "Christopher Nolan",
        isExclusive: true, streamURL: URL(string: "https://streamimdb.ru/embed/movie/872585")!,
        trailerURL: nil, availableQualities: [.hd, .fhd, .uhd], subtitleLanguages: ["English", "Arabic"], seasons: [],
        posterURL: "https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
        backdropURL: "https://image.tmdb.org/t/p/w1280/rLb2cwF3Pazuxaj0sRXQ037tGI1.jpg"
    )
    MovieDetailsView(movie: movie, namespace: ns) { }
        .preferredColorScheme(.dark)
}

// MARK: - Helpers

private struct CircularGlass: View {
    let systemName: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(.ultraThinMaterial)
                Circle().stroke(AppColors.glassStroke, lineWidth: 1)
                Image(systemName: systemName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 34, height: 34)
        }
        .buttonStyle(.pressable)
    }
}

private struct PreferenceRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(AppColors.aqua)
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            Spacer()
            Text(value)
                .font(AppTypography.subhead)
                .foregroundStyle(AppColors.subtleText)
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.mutedText)
        }
    }
}
