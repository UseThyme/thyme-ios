import Foundation

struct WatchHandler {

  struct Notifications {
    static let AlarmsDidUpdate = "WatchHandler.AlarmsDidUpdate"
  }

  static func response(request: String, _ userInfo: [NSObject : AnyObject]?) -> [NSObject : AnyObject] {
    var data = [NSObject : AnyObject]()

    switch request {
    case "getAlarms":
      data = ["alarms": getAlarmsData()]
    case "getAlarm":
      if let userInfo = userInfo, index = userInfo["index"] as? Int {
        data["alarm"] = getAlarmData(index)
      }
    case "cancelAlarms":
      LocalNotificationManager.cancelAllLocalNotifications()
      data = ["alarms": getAlarmsData()]
    case "cancelAlarm":
      if let userInfo = userInfo, index = userInfo["index"] as? Int {
        let alarm = Alarm.create(index)
        if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!) {
          UIApplication.sharedApplication().cancelLocalNotification(notification)
        }

        data["alarm"] = getAlarmData(index)
      }
    case "updateAlarmMinutes":
      if let userInfo = userInfo, index = userInfo["index"] as? Int, amount = userInfo["amount"] as? Int {
        let alarm = Alarm.create(index)
        var seconds: NSTimeInterval = 0

        if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!),
          userInfo = notification.userInfo,
          firedDate = userInfo[ThymeAlarmFireDataKey] as? NSDate,
          numberOfSeconds = userInfo[ThymeAlarmFireInterval] as? NSNumber {
            let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
            let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
            seconds = secondsLeft
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }

        let title = NSLocalizedString("\(alarm.title) just finished",
          comment: "\(alarm.title) just finished")
        seconds += NSTimeInterval(60 * amount)

        let notification = LocalNotificationManager.createNotification(seconds,
          message: title,
          title: NSLocalizedString("View Details", comment: "View Details"),
          alarmID: alarm.alarmID!)

        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AlarmsDidUpdate, object: notification)

        var alarmData = extractAlarmData(notification)
        alarmData["title"] = alarm.title
        data["alarm"] = alarmData
      }
    default:
      break
    }

    return data
  }

  private static func getAlarmsData() -> [AnyObject] {
    var alarms = [AnyObject]()
    
    for index in 0...4 {
      alarms.append(getAlarmData(index))
    }

    return alarms
  }

  private static func getAlarmData(index: Int) -> [String: AnyObject] {
    let alarm = Alarm.create(index)
    var alarmData = [String: AnyObject]()

    if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!) {
      alarmData = extractAlarmData(notification)
      alarmData["title"] = alarm.title
    }

    return alarmData
  }

  private static func extractAlarmData(notification: UILocalNotification) -> [String: AnyObject] {
    var alarmData = [String: AnyObject]()

    if let userInfo = notification.userInfo,
      firedDate = userInfo[ThymeAlarmFireDataKey] as? NSDate,
      numberOfSeconds = userInfo[ThymeAlarmFireInterval] as? NSNumber {
        alarmData["firedDate"] = firedDate
        alarmData["numberOfSeconds"] = numberOfSeconds
    }

    return alarmData
  }
}
