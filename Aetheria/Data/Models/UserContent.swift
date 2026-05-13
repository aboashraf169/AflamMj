import Foundation
import SwiftData

@Model
final class FavoriteItem {
    @Attribute(.unique) var movieID: String
    var title: String
    var year: String
    var duration: Int
    var rating: Double
    var isSeries: Bool
    var posterURL: String?
    var backdropURL: String?
    var addedAt: Date

    init(movieID: String, title: String, year: String = "", duration: Int = 0,
         rating: Double = 0, isSeries: Bool = false,
         posterURL: String? = nil, backdropURL: String? = nil,
         addedAt: Date = .now) {
        self.movieID    = movieID
        self.title      = title
        self.year       = year
        self.duration   = duration
        self.rating     = rating
        self.isSeries   = isSeries
        self.posterURL  = posterURL
        self.backdropURL = backdropURL
        self.addedAt    = addedAt
    }
}

@Model
final class WatchProgress {
    @Attribute(.unique) var movieID: String
    var positionSeconds: Double
    var durationSeconds: Double
    var updatedAt: Date

    init(movieID: String, positionSeconds: Double, durationSeconds: Double, updatedAt: Date = .now) {
        self.movieID = movieID
        self.positionSeconds = positionSeconds
        self.durationSeconds = durationSeconds
        self.updatedAt = updatedAt
    }

    var fraction: Double {
        guard durationSeconds > 0 else { return 0 }
        return min(1.0, positionSeconds / durationSeconds)
    }
}

enum DownloadStatus: String, Codable {
    case queued, downloading, paused, completed, failed
}

@Model
final class DownloadItem {
    @Attribute(.unique) var movieID: String
    var title: String
    var status: String          // raw value of DownloadStatus
    var progress: Double        // 0..1
    var quality: String         // raw value of VideoQuality
    var sizeMB: Double
    var addedAt: Date

    init(movieID: String, title: String, status: DownloadStatus, progress: Double, quality: VideoQuality, sizeMB: Double, addedAt: Date = .now) {
        self.movieID = movieID
        self.title = title
        self.status = status.rawValue
        self.progress = progress
        self.quality = quality.rawValue
        self.sizeMB = sizeMB
        self.addedAt = addedAt
    }

    var downloadStatus: DownloadStatus {
        get { DownloadStatus(rawValue: status) ?? .queued }
        set { status = newValue.rawValue }
    }

    var videoQuality: VideoQuality {
        VideoQuality(rawValue: quality) ?? .hd
    }
}
