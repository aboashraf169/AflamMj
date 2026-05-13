import Foundation

// MARK: - Page envelope
struct TMDBPage<T: Decodable>: Decodable {
    let results: [T]
}

// MARK: - Result item (movies + TV mixed)
struct TMDBItem: Decodable {
    let id: Int
    // movie fields
    let title: String?
    let releaseDate: String?
    // tv fields
    let name: String?
    let firstAirDate: String?
    // shared
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let genreIds: [Int]?
    let mediaType: String?   // only present in /trending/all
    let runtime: Int?        // only in detail responses

    var resolvedTitle: String { title ?? name ?? "Unknown" }

    var resolvedYear: String {
        let raw = releaseDate ?? firstAirDate ?? ""
        return raw.isEmpty ? "" : String(raw.prefix(4))
    }

    var isSeries: Bool {
        if let mt = mediaType { return mt == "tv" }
        return name != nil && title == nil
    }

    // MARK: - Convert to app Movie
    func toMovie() -> Movie {
        let kind: ContentKind = isSeries ? .series : .movie
        let genres: [Genre]   = (genreIds ?? []).compactMap(TMDBGenreMap.genre)
        let dur               = runtime ?? (isSeries ? 45 : 105)

        // streamimdb.ru uses TMDB ID to build a direct watch URL
        let streamPath = isSeries ? "tv" : "movie"
        let streamURL  = URL(string: "https://streamimdb.ru/embed/\(streamPath)/\(id)")!

        return Movie(
            id:                 "\(id)",
            title:              resolvedTitle,
            tagline:            "",
            synopsis:           overview?.isEmpty == false ? overview! : "No synopsis available.",
            year:               resolvedYear.isEmpty ? "2024" : resolvedYear,
            duration:           dur > 0 ? dur : (isSeries ? 45 : 105),
            rating:             min(10, max(0, voteAverage ?? 0)),
            kind:               kind,
            genres:             genres.isEmpty ? [.drama] : genres,
            cast:               [],
            director:           "",
            isExclusive:        false,
            streamURL:          streamURL,
            trailerURL:         nil,
            availableQualities: [.auto, .fhd, .hd, .sd],
            subtitleLanguages:  ["English", "Arabic"],
            seasons:            [],
            posterURL:          posterPath.map   { TMDBConfig.posterBase   + $0 },
            backdropURL:        backdropPath.map { TMDBConfig.backdropBase + $0 }
        )
    }
}

// MARK: - Videos response (trailers)
struct TMDBVideosResponse: Decodable {
    let results: [TMDBVideo]

    /// Best trailer key: official YouTube trailer first, then any YouTube video.
    var bestTrailerKey: String? {
        let yt = results.filter { $0.site.lowercased() == "youtube" }
        return yt.first(where: { $0.type.lowercased() == "trailer" && $0.official == true })?.key
            ?? yt.first(where: { $0.type.lowercased() == "trailer" })?.key
            ?? yt.first?.key
    }
}

struct TMDBVideo: Decodable {
    let key:      String
    let site:     String
    let type:     String
    let official: Bool?
}

// MARK: - Genre ID ↔ app Genre mapping
enum TMDBGenreMap {
    static func genre(for tmdbId: Int) -> Genre? {
        switch tmdbId {
        case 28:    return .action
        case 18:    return .drama
        case 878:   return .sciFi
        case 53:    return .thriller
        case 10749: return .romance
        case 27:    return .horror
        case 16:    return .animation
        case 99:    return .documentary
        case 14:    return .fantasy
        case 80:    return .crime
        case 12, 10752: return .action   // adventure / war
        case 9648:  return .thriller     // mystery
        default:    return nil
        }
    }

    static func tmdbId(for genre: Genre) -> Int? {
        switch genre.id {
        case "action":      return 28
        case "drama":       return 18
        case "sci-fi":      return 878
        case "thriller":    return 53
        case "romance":     return 10749
        case "horror":      return 27
        case "animation":   return 16
        case "documentary": return 99
        case "fantasy":     return 14
        case "crime":       return 80
        default:            return nil
        }
    }
}
