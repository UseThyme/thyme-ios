import Foundation

public struct AlarmCenter {

  static let categoryIdentifier = "ThymeCategory"

  struct Actions {
    static let AddThreeMinutes = "AddThreeMinutes"
    static let AddFiveMinutes = "AddFiveMinutes"
  }

  // MARK: - Local notification management

  static func registerNotificationSettings() {
    var categories = Set<UIUserNotificationCategory>()

    let add3MinutesAction = UIMutableUserNotificationAction()
    add3MinutesAction.title = NSLocalizedString("Add 3 mins", comment: "")
    add3MinutesAction.identifier = Actions.AddThreeMinutes
    add3MinutesAction.activationMode = .Background
    add3MinutesAction.authenticationRequired = false

    let add5MinutesAction = UIMutableUserNotificationAction()
    add5MinutesAction.title = NSLocalizedString("Add 5 mins", comment: "")
    add5MinutesAction.identifier = Actions.AddFiveMinutes
    add5MinutesAction.activationMode = .Background
    add5MinutesAction.authenticationRequired = false

    let category = UIMutableUserNotificationCategory()
    category.setActions([add3MinutesAction, add5MinutesAction], forContext: .Default)
    category.identifier = AlarmCenter.categoryIdentifier

    categories.insert(category)

    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
    let settings = UIUserNotificationSettings(forTypes: types, categories: categories)

    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }

  static func scheduleNotification(seconds: NSTimeInterval, message: String, title: String?, alarmID: String) -> UILocalNotification {
    let fireDate = NSDate().dateByAddingTimeInterval(seconds)

    var userInfo = [NSObject : AnyObject]()
    userInfo[ThymeAlarmIDKey] = alarmID
    userInfo[ThymeAlarmFireDataKey] = NSDate()
    userInfo[ThymeAlarmFireInterval] = seconds

    let notification = UILocalNotification()
    notification.alertAction = title
    notification.alertBody = message
    notification.fireDate = fireDate
    notification.hasAction = title != nil
    notification.soundName = "alarm.caf"
    notification.timeZone = NSTimeZone.defaultTimeZone()
    notification.userInfo = userInfo
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)

    return notification
  }

  static func getNotification(alarmID: String) -> UILocalNotification? {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if let notificationAlarmID = notification.userInfo?[ThymeAlarmIDKey] as? String
        where notificationAlarmID == alarmID {
          return notification
      }
    }
    return nil
  }

  static func cancelNotification(alarmID: String) {
    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0

    if let notification = getNotification(alarmID) {
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
  }

  static func cancelAllNotifications() {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if let _ = notification.userInfo?[ThymeAlarmIDKey] as? String {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
      }
    }
  }

  // MARK: - Handling

  static func handleNotification(notification: UILocalNotification, action: String?) {
    
  }
}
