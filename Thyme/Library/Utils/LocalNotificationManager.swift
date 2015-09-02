import Foundation

public class LocalNotificationManager {

  static func createNotification(seconds: NSTimeInterval, message: String, title: String?, alarmID: String) -> UILocalNotification {
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

  static func existingNotificationWithAlarmID(alarmID: String) -> UILocalNotification? {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if let notificationAlarmID = notification.userInfo?[ThymeAlarmIDKey] as? String
        where notificationAlarmID == alarmID {
          return notification
      }
    }
    return nil
  }

  static func cancelAllLocalNotifications() {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if let _ = notification.userInfo?[ThymeAlarmIDKey] as? String {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
      }
    }
  }

}
