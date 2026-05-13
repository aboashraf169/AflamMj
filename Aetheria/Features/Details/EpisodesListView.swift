import SwiftUI

struct EpisodesListView: View {
    let movie: Movie
    @Binding var selectedSeasonID: String?
    var onPlayEpisode: () -> Void

    private var currentSeason: Season? {
        movie.seasons.first { $0.id == selectedSeasonID } ?? movie.seasons.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Episodes")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
                Menu {
                    ForEach(movie.seasons) { season in
                        Button("Season \(season.number)") {
                            selectedSeasonID = season.id
                            Haptics.selection()
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Season \(currentSeason?.number ?? 1)")
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(AppTypography.subhead)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
                }
            }
            .padding(.horizontal, Spacing.l)

            VStack(spacing: 10) {
                ForEach(currentSeason?.episodes ?? []) { episode in
                    EpisodeRow(episode: episode, onPlay: onPlayEpisode)
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedSeasonID: String? = "s1"
    let episodes = [
        Episode(id: "e1", title: "Winter Is Coming", synopsis: "Lord Eddard Stark is named Hand of the King.", duration: 62, number: 1, streamURL: URL(string: "https://example.com/e1")!),
        Episode(id: "e2", title: "The Kingsroad", synopsis: "Jon Snow joins the Night's Watch.", duration: 56, number: 2, streamURL: URL(string: "https://example.com/e2")!),
        Episode(id: "e3", title: "Lord Snow", synopsis: "Jon Snow trains with the Night's Watch.", duration: 58, number: 3, streamURL: URL(string: "https://example.com/e3")!)
    ]
    let movie = Movie(
        id: "got", title: "Game of Thrones", tagline: "Winter is coming.", synopsis: "Noble families vie for control.",
        year: "2011", duration: 0, rating: 9.2, kind: .series,
        genres: [.fantasy, .drama], cast: [], director: "Various",
        isExclusive: false, streamURL: URL(string: "https://example.com/stream")!,
        trailerURL: nil, availableQualities: [.fhd], subtitleLanguages: [],
        seasons: [Season(id: "s1", number: 1, episodes: episodes)]
    )
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            EpisodesListView(movie: movie, selectedSeasonID: $selectedSeasonID) { }
                .padding(.vertical)
        }
    }
    .preferredColorScheme(.dark)
}

private struct EpisodeRow: View {
    let episode: Episode
    let onPlay: () -> Void

    var body: some View {
        Button {
            Haptics.medium()
            onPlay()
        } label: {
            HStack(spacing: Spacing.s) {
                ZStack {
                    AppGradients.posterFallback(for: episode.id.hashValue)
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 6)
                }
                .frame(width: 110, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: Radius.s, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(episode.number). \(episode.title)")
                            .font(AppTypography.subhead)
                            .foregroundStyle(AppColors.primaryText)
                        Spacer()
                        Text("\(episode.duration)m")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.subtleText)
                    }
                    Text(episode.synopsis)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.subtleText)
                        .lineLimit(2)
                }
            }
            .padding(10)
            .glassBackground(cornerRadius: Radius.m)
        }
        .buttonStyle(.pressable(scale: 0.98))
    }
}
