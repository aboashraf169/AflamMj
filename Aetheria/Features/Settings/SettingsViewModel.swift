import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("aflamMj.defaultQuality") var defaultQualityRaw: String = VideoQuality.auto.rawValue
    @AppStorage("aflamMj.subtitleLanguage") var subtitleLanguage: String = "English"
    @AppStorage("aflamMj.autoplayNext") var autoplayNext: Bool = true
    @AppStorage("aflamMj.skipIntro")    var skipIntro: Bool = true
    @AppStorage("aflamMj.hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("aflamMj.reducedMotion") var reducedMotion: Bool = false
    @AppStorage("aflamMj.downloadsOnWifiOnly") var downloadsOnWifiOnly: Bool = true
    @AppStorage("aflamMj.notifyNewEpisodes") var notifyNewEpisodes: Bool = true

    @Published var cacheSizeMB: Double = 412.0

    var defaultQuality: VideoQuality {
        get { VideoQuality(rawValue: defaultQualityRaw) ?? .auto }
        set { defaultQualityRaw = newValue.rawValue }
    }

    func clearCache() {
        Haptics.warning()
        withAnimation(.smooth) { cacheSizeMB = 0 }
    }
}
