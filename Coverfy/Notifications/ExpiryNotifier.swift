import Foundation
import UserNotifications

enum ExpiryNotifier {

    static func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
    }

    /// Schedules local alerts 30 and 7 days before the warranty expires.
    static func scheduleAlerts(for warranty: Warranty) {
        let center = UNUserNotificationCenter.current()
        let id = warranty.persistentModelID.hashValue

        for daysBefore in [30, 7] {
            guard let fireDate = Calendar.current.date(
                byAdding: .day, value: -daysBefore, to: warranty.expiryDate
            ), fireDate > .now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Garantía a punto de caducar"
            content.body = "\(warranty.productName): caduca en \(daysBefore) días"
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components, repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "coverfy-\(id)-\(daysBefore)",
                content: content, trigger: trigger
            )
            center.add(request)
        }
    }

    static func cancelAlerts(for warranty: Warranty) {
        let id = warranty.persistentModelID.hashValue
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["coverfy-\(id)-30", "coverfy-\(id)-7"]
        )
    }
}
