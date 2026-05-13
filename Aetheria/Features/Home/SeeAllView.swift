import SwiftUI

// MARK: - Preview

#Preview {
    let movie = Movie(
        id: "1", title: "Gladiator II", tagline: "Rise as one.", synopsis: "Lucius is captured and taken to Rome.",
        year: "2024", duration: 148, rating: 7.5, kind: .movie,
        genres: [.action, .drama], cast: [], director: "Ridley Scott",
        isExclusive: false, streamURL: URL(string: "https://example.com/stream")!,
        trailerURL: nil, availableQualities: [.fhd], subtitleLanguages: [], seasons: []
    )
    SeeAllView(title: "Action & Drama", movies: Array(repeating: movie, count: 12))
        .preferredColorScheme(.dark)
}

struct SeeAllView: View {
    let title:    String
    let movies:   [Movie]

    @Environment(\.dismiss) private var dismiss
    @State private var presentedMovie: Movie? = nil
    @State private var playingMovie:   Movie? = nil
    @Namespace private var ns

    private let columns = [
        GridItem(.adaptive(minimum: ScreenMetrics.gridPosterMin,
                           maximum: ScreenMetrics.gridPosterMax),
                 spacing: Spacing.m)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    // spacer for top bar
                    Color.clear.frame(height: 52)

                    LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.m) {
                        ForEach(movies) { movie in
                            Button {
                                Haptics.selection()
                                presentedMovie = movie
                            } label: {
                                PosterCard(movie: movie, width: nil, namespace: ns)
                            }
                            .buttonStyle(.pressable(scale: 0.96))
                        }
                    }
                    .padding(.horizontal, Spacing.l)

                    Color.clear.frame(height: ScreenMetrics.tabBarClearance)
                }
            }

            // Fixed top bar
            HStack {
                Button {
                    Haptics.tap(); dismiss()
                } label: {
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        Circle().stroke(AppColors.glassStroke, lineWidth: 1)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 34, height: 34)
                }
                .buttonStyle(.pressable)

                Spacer()

                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                // mirror button for centering
                Color.clear.frame(width: 34, height: 34)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, 8)
            .background(.ultraThinMaterial.opacity(0.95))
        }
        .sheet(item: $presentedMovie) { movie in
            MovieDetailsView(movie: movie, namespace: ns) {
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
}
