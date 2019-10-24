import Foundation

public struct AlarmCenter {
    enum Action: String {
        case AddThreeMinutes
        case AddFiveMinutes
    }

    static let categoryIdentifier = "ThymeNotificationCategory"

    struct Notifications {
        static let AlarmsDidUpdate = "WatchHandler.AlarmsDidUpdate"
    }

    // MARK: - Local notification management

    static func hasCorrectNotificationTypes(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationCategories { currentCategories in
            completion(currentCategories == notificationsCategories())
        }
    }

    static func notificationsCategories() -> Set<UNNotificationCategory> {
        var categories = Set<UNNotificationCategory>()

        let threeMinutesAction = UNNotificationAction(identifier: Action.AddThreeMinutes.rawValue, title: NSLocalizedString("Add 3 mins", comment: ""), options: [])

        let fiveMinutesAction = UNNotificationAction(identifier: Action.AddFiveMinutes.rawValue, title: NSLocalizedString("Add 5 mins", comment: ""), options: [])

        let category = UNNotificationCategory(identifier: AlarmCenter.categoryIdentifier, actions: [threeMinutesAction, fiveMinutesAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [])

        categories.insert(category)

        return categories
    }

    static func registerNotificationSettings() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            UNUserNotificationCenter.current().setNotificationCategories(notificationsCategories())
        }
    }

    static func scheduleNotification(_ alarmID: String, seconds: TimeInterval, message: String?) -> UNNotificationRequest {
        if let notification = getNotification(alarmID) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification])
            UIApplication.shared.cancelLocalNotification(notification)
        }

        let fireDate = Date().addingTimeInterval(seconds)

        var userInfo = [AnyHashable: Any]()
        userInfo[Alarm.idKey] = alarmID
        userInfo[Alarm.fireDateKey] = Date()
        userInfo[Alarm.fireIntervalKey] = seconds

        let notification = UILocalNotification()
        notification.alertBody = message
        notification.fireDate = fireDate
        notification.category = categoryIdentifier
        notification.soundName = "alarm.caf"
        notification.timeZone = TimeZone.current
        notification.userInfo = userInfo

        UIApplication.shared.scheduleLocalNotification(notification)

        return notification
    }

    static func extendNotification(_ notification: UILocalNotification, seconds: TimeInterval) -> UILocalNotification? {
        var updatedNotification: UILocalNotification?

        if let alarmID = notification.userInfo?[Alarm.idKey] as? String,
            let userInfo = notification.userInfo,
            let firedDate = userInfo[Alarm.fireIntervalKey] as? Date,
            let numberOfSeconds = userInfo[Alarm.fireIntervalKey] as? NSNumber {
            var secondsAmount = seconds

            let secondsPassed: TimeInterval = Date().timeIntervalSince(firedDate)
            let secondsLeft = TimeInterval(numberOfSeconds.intValue) - secondsPassed

            if secondsLeft > 0 { secondsAmount += secondsLeft }

            UIApplication.shared.cancelLocalNotification(notification)

            updatedNotification = AlarmCenter.scheduleNotification(alarmID,
                                                                   seconds: secondsAmount,
                                                                   message: notification.alertBody)
        }

        return updatedNotification
    }

    static func getNotification(_ alarmID: String) -> UILocalNotification? {
        // Use UNUserNotificationCenter instead
        let scheduledLocalNotifications = UIApplication.shared.scheduledLocalNotifications ?? [UILocalNotification]()
        for notification in scheduledLocalNotifications {
            if let notificationAlarmID = notification.userInfo?[Alarm.idKey] as? String, notificationAlarmID == alarmID {
                return notification
            }
        }
        return nil
    }

    static func cancelNotification(_ alarmID: String) {
        for badgeCount in [1, 0] { UIApplication.shared.applicationIconBadgeNumber = badgeCount }

        if let notification = getNotification(alarmID) {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }

    static func cancelAllNotifications() {
        for notification in UIApplication.shared.scheduledLocalNotifications! {
            if let _ = notification.userInfo?[Alarm.idKey] as? String {
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }

    // MARK: - Handling

    static func handleNotification(_ notification: UILocalNotification, actionID: String?) {
        if let actionID = actionID, let action = Action(rawValue: actionID) {
            switch action {
            case .AddThreeMinutes:
                _ = extendNotification(notification, seconds: TimeInterval(60 * 3))
            case .AddFiveMinutes:
                _ = extendNotification(notification, seconds: TimeInterval(60 * 5))
            }
        }
    }
}
