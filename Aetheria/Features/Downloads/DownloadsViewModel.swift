import SwiftUI

struct DownloadRow: Identifiable {
    let id: String
    let movie: Movie
    var status: DownloadStatus
    var progress: Double
    var quality: VideoQuality
    var sizeMB: Double
}

@MainActor
final class DownloadsViewModel: ObservableObject {
    @Published var items: [DownloadRow] = []
    @Published var totalUsedMB: Double  = 0
    @Published var totalLimitMB: Double = 32_000

    private var tickTask: Task<Void, Never>?

    init() { startTicking() }

    deinit { tickTask?.cancel() }

    // Called from MovieDetailsView / elsewhere when user taps "Download"
    func add(movie: Movie, quality: VideoQuality = .fhd) {
        guard !items.contains(where: { $0.id == movie.id }) else { return }
        let size: Double = quality == .uhd ? 5800 : quality == .fhd ? 2350 : 1400
        let row = DownloadRow(id: movie.id, movie: movie,
                              status: .downloading, progress: 0,
                              quality: quality, sizeMB: size)
        items.insert(row, at: 0)
        recomputeUsage()
        Haptics.tap()
    }

    private func startTicking() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 800_000_000)
                await MainActor.run { self?.advanceDownloading() }
            }
        }
    }

    private func advanceDownloading() {
        for idx in items.indices where items[idx].status == .downloading {
            items[idx].progress = min(1.0, items[idx].progress + Double.random(in: 0.005...0.02))
            if items[idx].progress >= 1.0 {
                items[idx].status = .completed
                Haptics.success()
            }
        }
        recomputeUsage()
    }

    func toggle(_ row: DownloadRow) {
        guard let idx = items.firstIndex(where: { $0.id == row.id }) else { return }
        switch items[idx].status {
        case .downloading:        items[idx].status = .paused
        case .paused, .queued:    items[idx].status = .downloading
        case .completed, .failed: break
        }
        Haptics.tap()
    }

    func remove(_ row: DownloadRow) {
        items.removeAll { $0.id == row.id }
        recomputeUsage()
        Haptics.warning()
    }

    private func recomputeUsage() {
        totalUsedMB = items.reduce(0) { $0 + $1.sizeMB * $1.progress }
    }
}
