import SwiftUI
import SwiftData

enum FavoritesSort: String, CaseIterable, Identifiable {
    case recent  = "Recent"
    case rating  = "Rating"
    case title   = "Title"
    case year    = "Year"

    var id: String { rawValue }
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var movies: [Movie]  = []
    @Published var sort: FavoritesSort = .recent {
        didSet { applySort() }
    }
    @Published var filter: Genre? = nil

    // SwiftData context injected after init
    var modelContext: ModelContext? = nil

    var filtered: [Movie] {
        guard let filter else { return movies }
        return movies.filter { $0.genres.contains(filter) }
    }

    // MARK: - Load saved favourites from SwiftData

    func load(context: ModelContext) {
        self.modelContext = context
        let descriptor = FetchDescriptor<FavoriteItem>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        let items = (try? context.fetch(descriptor)) ?? []
        // Rebuild Movie stubs from stored data (id + title only; full data loads on tap)
        movies = items.map { item in
            Movie(
                id: item.movieID,
                title: item.title,
                tagline: "", synopsis: "",
                year: item.year, duration: item.duration,
                rating: item.rating, kind: item.isSeries ? .series : .movie,
                genres: [], cast: [], director: "",
                isExclusive: false,
                streamURL: URL(string: "https://streamimdb.ru/embed/\(item.isSeries ? "tv" : "movie")/\(item.movieID)")!,
                trailerURL: nil,
                availableQualities: [.auto, .fhd, .hd],
                subtitleLanguages: [],
                seasons: [],
                posterURL: item.posterURL,
                backdropURL: item.backdropURL
            )
        }
    }

    // MARK: - Mutate

    func add(_ movie: Movie) {
        guard !movies.contains(where: { $0.id == movie.id }) else { return }
        movies.insert(movie, at: 0)
        applySort()
        Haptics.success()
        if let ctx = modelContext {
            let item = FavoriteItem(
                movieID: movie.id,
                title: movie.title,
                year: movie.year,
                duration: movie.duration,
                rating: movie.rating,
                isSeries: movie.kind == .series,
                posterURL: movie.posterURL,
                backdropURL: movie.backdropURL
            )
            ctx.insert(item)
            try? ctx.save()
        }
    }

    func remove(_ movie: Movie) {
        movies.removeAll { $0.id == movie.id }
        Haptics.warning()
        if let ctx = modelContext {
            let id = movie.id
            let descriptor = FetchDescriptor<FavoriteItem>(
                predicate: #Predicate { $0.movieID == id }
            )
            if let item = try? ctx.fetch(descriptor).first {
                ctx.delete(item)
                try? ctx.save()
            }
        }
    }

    func isFavorite(_ movie: Movie) -> Bool {
        movies.contains { $0.id == movie.id }
    }

    private func applySort() {
        switch sort {
        case .recent: break
        case .rating: movies.sort { $0.rating > $1.rating }
        case .title:  movies.sort { $0.title  < $1.title  }
        case .year:   movies.sort { $0.year   > $1.year   }
        }
    }
}
