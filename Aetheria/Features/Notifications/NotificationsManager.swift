import Foundation
import UserNotifications

enum AflamMjNotification {
    case newEpisode(title: String, episode: String)
    case downloadComplete(title: String)
    case watchReminder(title: String)

    var content: UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.sound = .default
        switch self {
        case .newEpisode(let title, let episode):
            c.title = "New episode released"
            c.body  = "\(title) — \(episode) is ready to stream."
            c.threadIdentifier = "aflamMj.newEpisode"
        case .downloadComplete(let title):
            c.title = "Download complete"
            c.body  = "\(title) is now available offline."
            c.threadIdentifier = "aflamMj.download"
        case .watchReminder(let title):
            c.title = "Pick up where you left off"
            c.body  = "\(title) is waiting."
            c.threadIdentifier = "aflamMj.reminder"
        }
        return c
    }
}

@MainActor
final class NotificationsManager {
    static let shared = NotificationsManager()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func schedule(_ notification: AflamMjNotification, after seconds: TimeInterval = 3) async {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notification.content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
