import Foundation

enum ContentKind: String, Codable, Hashable {
    case movie, series
}

struct CastMember: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let role: String
}

struct Movie: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let tagline: String
    let synopsis: String
    let year: String
    let duration: Int          // minutes
    let rating: Double         // 0..10
    let kind: ContentKind
    let genres: [Genre]
    let cast: [CastMember]
    let director: String
    let isExclusive: Bool
    let streamURL: URL
    let trailerURL: URL?
    let availableQualities: [VideoQuality]
    let subtitleLanguages: [String]
    let seasons: [Season]
    var posterURL: String?   = nil  // TMDB CDN poster  (2:3)
    var backdropURL: String? = nil  // TMDB CDN backdrop (16:9) – used in hero

    var prettyDuration: String {
        let h = duration / 60
        let m = duration % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    var primaryGenres: String {
        genres.prefix(3).map(\.name).joined(separator: " • ")
    }
}

struct Season: Identifiable, Hashable, Codable {
    let id: String
    let number: Int
    let episodes: [Episode]
}

struct Episode: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let synopsis: String
    let duration: Int          // minutes
    let number: Int
    let streamURL: URL
}

enum VideoQuality: String, Codable, Hashable, CaseIterable, Identifiable {
    case auto = "Auto"
    case sd   = "480p"
    case hd   = "720p"
    case fhd  = "1080p"
    case uhd  = "4K HDR"

    var id: String { rawValue }
}
