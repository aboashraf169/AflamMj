import Foundation

// MARK: - Configuration
// Get your free API key at: https://www.themoviedb.org/settings/api
enum TMDBConfig {
    static var apiKey: String {
        // 1. Preferred: place key in Secrets.plist → TMDB_API_KEY
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url),
           let key = dict["TMDB_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        // 2. Fallback: set this string to your own key
        return "8265bd1679663a7ea12ac168da84d2e8"
    }

    static let base         = "https://api.themoviedb.org/3"
    static let posterBase   = "https://image.tmdb.org/t/p/w342"   // ~342 px wide — fast load for cards
    static let backdropBase = "https://image.tmdb.org/t/p/w780"   // 780 px wide — good for detail header
}

// MARK: - TMDB Client
final class TMDBClient {
    static let shared = TMDBClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        session = URLSession(configuration: config)
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        decoder = dec
    }

    func get<T: Decodable>(_ path: String, params: [String: String] = [:]) async throws -> T {
        var components = URLComponents(string: TMDBConfig.base + path)!
        var items = [
            URLQueryItem(name: "api_key",  value: TMDBConfig.apiKey),
            URLQueryItem(name: "language", value: "en-US")
        ]
        items += params.map { URLQueryItem(name: $0.key, value: $0.value) }
        components.queryItems = items

        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw APIError.badStatus(http.statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
