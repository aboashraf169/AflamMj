import SwiftUI
import SwiftData

@main
struct AflamMjApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .tint(AppColors.accent)
        }
        .modelContainer(for: [
            FavoriteItem.self,
            DownloadItem.self,
            WatchProgress.self
        ])
    }
}

// MARK: - AppDelegate: controls allowed orientations per screen

class AppDelegate: NSObject, UIApplicationDelegate {
    /// Set to true while the player is presented to unlock landscape
    static var allowAllOrientations = false

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppDelegate.allowAllOrientations ? .all : .portrait
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: RootTab = .home
    @Published var hapticsEnabled: Bool = true
    @Published var reducedMotion: Bool = false
    let favoritesVM = FavoritesViewModel()
}

enum RootTab: Hashable {
    case home, search, downloads, favorites, settings
}
