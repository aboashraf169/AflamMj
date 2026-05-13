import Foundation

struct Genre: Identifiable, Hashable, Codable {
    let id: String
    let name: String

    static let action      = Genre(id: "action",       name: "Action")
    static let drama       = Genre(id: "drama",        name: "Drama")
    static let sciFi       = Genre(id: "sci-fi",       name: "Sci-Fi")
    static let thriller    = Genre(id: "thriller",     name: "Thriller")
    static let romance     = Genre(id: "romance",      name: "Romance")
    static let horror      = Genre(id: "horror",       name: "Horror")
    static let animation   = Genre(id: "animation",    name: "Animation")
    static let documentary = Genre(id: "documentary",  name: "Documentary")
    static let fantasy     = Genre(id: "fantasy",      name: "Fantasy")
    static let crime       = Genre(id: "crime",        name: "Crime")

    static let all: [Genre] = [
        .action, .drama, .sciFi, .thriller, .romance,
        .horror, .animation, .documentary, .fantasy, .crime
    ]
}
