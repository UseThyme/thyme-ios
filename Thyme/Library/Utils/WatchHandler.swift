import Foundation

struct WatchHandler {

  static func response(request: String, _ userInfo: [NSObject : AnyObject]?) -> [NSObject : AnyObject] {
    var data = [NSObject : AnyObject]()

    if request == "getAlarms" {
      data = ["alarms": getAlarmsData()]
    } else if request == "getAlarm" {
      if let userInfo = userInfo, index = userInfo["index"] as? Int {
        data["alarm"] = getAlarmData(index)
      }
    } else if request == "cancelAlarm" {
      LocalNotificationManager.cancelAllLocalNotifications()
      data = ["alarms": getAlarmsData()]
    }

    return data
  }

  private static func getAlarmsData() -> [AnyObject] {
    var notifications = [String]()

    var alarms = [AnyObject]()
    for index in 0...4 {
      alarms.append(getAlarmData(index))
    }

    return alarms
  }

  private static func getAlarmData(index: Int) -> [String: AnyObject] {
    var alarmData = [String: AnyObject]()

    let section = index == 1 || index == 3  ? 1 : 0
    let item = index == 2 || index == 3 ? 1 : 0
    let indexPath = NSIndexPath(forItem: item, inSection: section)

    let alarm = Alarm()
    alarm.oven = index == 4
    alarm.indexPath = indexPath

    if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!),
      userinfo = notification.userInfo,
      firedDate = userinfo["HYPAlarmFireDate"] as? NSDate,
      numberOfSeconds = userinfo["HYPAlarmFireInterval"] as? NSNumber {
        alarmData["firedDate"] = firedDate
        alarmData["numberOfSeconds"] = numberOfSeconds
    }

    return alarmData
  }
}
