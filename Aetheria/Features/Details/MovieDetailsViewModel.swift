import SwiftUI

@MainActor
final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie
    @Published var related: [Movie] = []
    @Published var isFavorite: Bool = false
    @Published var selectedSeasonID: String? = nil
    @Published var selectedQuality: VideoQuality = .auto
    @Published var selectedSubtitle: String = "English"

    private let repo: ContentRepository
    weak var favoritesVM: FavoritesViewModel? = nil

    init(movie: Movie, repo: ContentRepository = TMDBContentRepository()) {
        self.movie = movie
        self.repo = repo
        self.selectedSeasonID = movie.seasons.first?.id
    }

    func syncFavoriteState() {
        isFavorite = favoritesVM?.isFavorite(movie) ?? false
    }

    func load() async {
        syncFavoriteState()
        do {
            if let g = movie.genres.first {
                let bucket = try await repo.byGenre(g).filter { $0.id != movie.id }
                self.related = Array(bucket.prefix(8))
            }
        } catch {
            self.related = []
        }
    }

    func toggleFavorite() {
        guard let fvm = favoritesVM else { return }
        if fvm.isFavorite(movie) {
            fvm.remove(movie)
            isFavorite = false
        } else {
            fvm.add(movie)
            isFavorite = true
        }
    }
}
