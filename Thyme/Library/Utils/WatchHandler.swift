import Foundation

struct WatchHandler {

  static func response(request: String) -> [NSObject : AnyObject] {
    var data = [NSObject : AnyObject]()

    if request == "getAlarms" {
      var notifications = [String]()

      var alarms = [AnyObject]()
      for index in 0...4 {
        let section = index == 1 || index == 3  ? 1 : 0
        let item = index == 2 || index == 3 ? 1 : 0
        let indexPath = NSIndexPath(forItem: item, inSection: section)

        let alarm = Alarm()
        alarm.oven = index == 4
        alarm.indexPath = indexPath

        var alarmData = [String: AnyObject]()
        if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!),
          userinfo = notification.userInfo,
          firedDate = userinfo["HYPAlarmFireDate"] as? NSDate,
          numberOfSeconds = userinfo["HYPAlarmFireInterval"] as? NSNumber {
            alarmData["firedDate"] = firedDate
            alarmData["numberOfSeconds"] = numberOfSeconds
        }

        alarms.append(alarmData)
      }

      data = ["alarms": alarms]
    }

    return data
  }
}
