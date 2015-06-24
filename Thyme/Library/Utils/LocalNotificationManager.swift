import Foundation

@objc public class LocalNotificationManager {

  static func createNotification(seconds: NSTimeInterval, message: String, title: String?, alarmID: String) {
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
  }

  static func existingNotificationWithAlarmID(alarmID: String) -> UILocalNotification? {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications {
      if let foundNotification = notification as? UILocalNotification,
        notificationAlarmID = foundNotification.userInfo?[ThymeAlarmIDKey] as? String
        where notificationAlarmID == alarmID {
          return foundNotification
      }
    }
    return nil
  }

  static func cancelAllLocalNotifications() {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications {
      if let notification = notification as? UILocalNotification,
        notificationAlarmID = notification.userInfo?[ThymeAlarmIDKey] as? String {
          UIApplication.sharedApplication().cancelLocalNotification(notification)
      }
    }
  }

}
