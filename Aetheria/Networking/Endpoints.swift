import Foundation

/// Placeholder endpoint definitions — wire these up to a real backend when ready.
enum Endpoints {
    static let base = URL(string: "https://api.aflamMj.example.com/v1/")!

    static let featured    = "discover/featured"
    static let trending    = "discover/trending"
    static let topRated    = "discover/top-rated"
    static let latest      = "discover/latest"
    static let exclusives  = "discover/exclusives"
    static let recommended = "discover/recommended"

    static func byGenre(_ id: String) -> String { "discover/genre/\(id)" }
    static func search(_ q: String) -> String   { "search?q=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
    static func detail(_ id: String) -> String  { "title/\(id)" }
}
