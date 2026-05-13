import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet { scheduleSearch() }
    }
    @Published var results: [Movie]  = []
    @Published var isSearching: Bool = false
    @Published var recent: [String]  = []
    @Published var selectedGenre: Genre? = nil {
        didSet { Task { await refresh() } }
    }

    // Popular TMDB genres as default trending searches
    let trending: [String] = [
        "Action", "Drama", "Sci-Fi", "Thriller",
        "Animation", "Horror", "Crime", "Romance"
    ]

    private let repo: ContentRepository
    private var searchTask: Task<Void, Never>?

    init(repo: ContentRepository = TMDBContentRepository()) {
        self.repo = repo
    }

    func scheduleSearch() {
        searchTask?.cancel()
        let snapshot = query
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 280_000_000) // 280 ms debounce
            guard !Task.isCancelled, self?.query == snapshot else { return }
            await self?.refresh()
        }
    }

    func refresh() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || selectedGenre != nil else {
            results = []
            return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            if let genre = selectedGenre, trimmed.isEmpty {
                results = try await repo.byGenre(genre)
            } else {
                let res = try await repo.search(trimmed)
                results = selectedGenre.map { g in
                    res.filter { $0.genres.contains(g) }
                } ?? res
            }
        } catch {
            results = []
        }
    }

    func commitRecent() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        recent.removeAll { $0.caseInsensitiveCompare(q) == .orderedSame }
        recent.insert(q, at: 0)
        if recent.count > 8 { recent.removeLast() }
    }
}
