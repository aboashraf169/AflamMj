import Foundation

// MARK: - Protocol
protocol ContentRepository {
    func featured()    async throws -> [Movie]
    func trending()    async throws -> [Movie]
    func topRated()    async throws -> [Movie]
    func latest()      async throws -> [Movie]
    func exclusives()  async throws -> [Movie]
    func recommended() async throws -> [Movie]
    func byGenre(_ genre: Genre)  async throws -> [Movie]
    func search(_ query: String)  async throws -> [Movie]
    func find(id: String)         async throws -> Movie?
}

// MARK: - TMDB implementation
final class TMDBContentRepository: ContentRepository {
    private let client = TMDBClient.shared

    // Each call de-duplicates and strips items without a poster.
    private func movies(_ path: String, params: [String: String] = [:]) async throws -> [Movie] {
        let page: TMDBPage<TMDBItem> = try await client.get(path, params: params)
        return page.results
            .filter { $0.posterPath != nil }
            .map    { $0.toMovie() }
    }

    func featured() async throws -> [Movie] {
        try await movies("/trending/all/week", params: ["page": "1"])
    }

    func trending() async throws -> [Movie] {
        try await movies("/trending/movie/week")
    }

    func topRated() async throws -> [Movie] {
        try await movies("/movie/top_rated")
    }

    func latest() async throws -> [Movie] {
        try await movies("/movie/now_playing")
    }

    func exclusives() async throws -> [Movie] {
        // "Exclusives" = upcoming titles — great visual since they have fresh posters
        try await movies("/movie/upcoming")
    }

    func recommended() async throws -> [Movie] {
        try await movies("/tv/popular")
    }

    func byGenre(_ genre: Genre) async throws -> [Movie] {
        guard let gid = TMDBGenreMap.tmdbId(for: genre) else { return [] }
        return try await movies("/discover/movie", params: [
            "with_genres": "\(gid)",
            "sort_by": "popularity.desc"
        ])
    }

    func search(_ query: String) async throws -> [Movie] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        // Fetch movies and TV in parallel
        async let moviePage: TMDBPage<TMDBItem> = client.get(
            "/search/movie", params: ["query": q])
        async let tvPage: TMDBPage<TMDBItem>    = client.get(
            "/search/tv",    params: ["query": q])

        let (mp, tp) = try await (moviePage, tvPage)
        let combined = (mp.results + tp.results)
            .filter { $0.posterPath != nil }
            .sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        return combined.map { $0.toMovie() }
    }

    func find(id: String) async throws -> Movie? {
        // Try movie first, then TV
        if let intId = Int(id) {
            let item: TMDBItem? = try? await client.get("/movie/\(intId)")
            if let item { return item.toMovie() }
            let tv: TMDBItem? = try? await client.get("/tv/\(intId)")
            return tv?.toMovie()
        }
        return nil
    }
}
