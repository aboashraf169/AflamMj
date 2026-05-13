import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var featured:     [Movie] = []
    @Published var trending:     [Movie] = []
    @Published var latest:       [Movie] = []
    @Published var topRated:     [Movie] = []
    @Published var recommended:  [Movie] = []
    @Published var byGenre: [Genre: [Movie]] = [:]
    @Published var isLoading:    Bool    = false
    @Published var errorMessage: String?

    private let repo: ContentRepository

    init(repo: ContentRepository = TMDBContentRepository()) {
        self.repo = repo
    }

    func load() async {
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let f  = repo.featured()
            async let t  = repo.trending()
            async let l  = repo.latest()
            async let tr = repo.topRated()
            async let r  = repo.recommended()

            featured    = try await f
            trending    = try await t
            latest      = try await l
            topRated    = try await tr
            recommended = try await r

            var genreMap: [Genre: [Movie]] = [:]
            for genre in [Genre.sciFi, .thriller, .drama, .action] {
                genreMap[genre] = try await repo.byGenre(genre)
            }
            byGenre = genreMap
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
