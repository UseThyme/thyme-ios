import Foundation
import WatchConnectivity

struct WatchCommunicator {

  static func updateApplicationContext() {
    do {
      let context = ["alarms": getAlarmsData()]
      if #available(iOS 9.0, *) {
        try WCSession.defaultSession().updateApplicationContext(context)
      }
    } catch {
      print("Error with saving application context to WCSession")
    }
  }

  static func response(request: String, _ message: [String : AnyObject]) -> [String : AnyObject] {
    var data = [String : AnyObject]()
    var updateAlarms = false

    switch request {
    case "getAlarms":
      data = ["alarms": getAlarmsData()]
    case "getAlarm":
      if let index = message["index"] as? Int {
        data["alarm"] = getAlarmData(index)
      }
    case "cancelAlarms":
      AlarmCenter.cancelAllNotifications()
      updateAlarms = true
      data = ["alarms": getAlarmsData()]
    case "cancelAlarm":
      if let index = message["index"] as? Int {
        let alarm = Alarm.create(index)
        AlarmCenter.cleanUpNotification(alarm.alarmID!)
        updateAlarms = true

        data["alarm"] = getAlarmData(index)
      }
    case "updateAlarm":
      if let index = message["index"] as? Int, amount = message["amount"] as? Int {
        let alarm = Alarm.create(index)
        let seconds = NSTimeInterval(amount)

        var notification: UILocalNotification?

        if let existingNotification = AlarmCenter.getNotification(alarm.alarmID!) {
          notification = AlarmCenter.extendNotification(existingNotification, seconds: seconds)
        } else {
          notification = AlarmCenter.scheduleNotification(alarm.alarmID!,
            seconds: seconds,
            message: NSLocalizedString("\(alarm.title) just finished", comment: ""))
        }

        updateAlarms = true

        if let notification = notification {
          var alarmData = extractAlarmData(notification)
          alarmData["title"] = alarm.title
          data["alarm"] = alarmData
        }
      }
    default:
      break
    }

    if updateAlarms {
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)
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
