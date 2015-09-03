import Foundation

struct WatchCommunicator {

  static func response(request: String, _ message: [String : AnyObject]) -> [String : AnyObject] {
    var data = [String : AnyObject]()

    switch request {
    case "getAlarms":
      data = ["alarms": getAlarmsData()]
    case "getAlarm":
      if let index = message["index"] as? Int {
        data["alarm"] = getAlarmData(index)
      }
    case "cancelAlarms":
      AlarmCenter.cancelAllNotifications()
      data = ["alarms": getAlarmsData()]
    case "cancelAlarm":
      if let index = message["index"] as? Int {
        let alarm = Alarm.create(index)
        if let notification = AlarmCenter.getNotification(alarm.alarmID!) {
          UIApplication.sharedApplication().cancelLocalNotification(notification)
        }

        data["alarm"] = getAlarmData(index)
      }
    case "updateAlarmMinutes":
      if let index = message["index"] as? Int, amount = message["amount"] as? Int {
        let alarm = Alarm.create(index)
        let seconds = NSTimeInterval(60 * amount)
        if let notification = AlarmCenter.getNotification(alarm.alarmID!),
          extendedNotification = AlarmCenter.extendNotification(notification, seconds: seconds) {
            var alarmData = extractAlarmData(extendedNotification)
            alarmData["title"] = alarm.title
            data["alarm"] = alarmData
        }
      }
    default:
      break
    }

    return data
  }

  static func getAlarmsData() -> [AnyObject] {
    var alarms = [AnyObject]()

    for index in 0...4 {
      alarms.append(getAlarmData(index))
    }

    return alarms
  }

  static func getAlarmData(index: Int) -> [String: AnyObject] {
    let alarm = Alarm.create(index)
    var alarmData = [String: AnyObject]()

    if let notification = AlarmCenter.getNotification(alarm.alarmID!) {
      alarmData = extractAlarmData(notification)
      alarmData["title"] = alarm.title
    }

    return alarmData
  }

  static func extractAlarmData(notification: UILocalNotification) -> [String: AnyObject] {
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
