import Foundation
import WatchConnectivity

@available(iOS 9.0, *)
class WatchCommunicator: NSObject {

  struct Notifications {
    static let AlarmsDidUpdate = "WatchHandler.AlarmsDidUpdate"
  }

  var session: WCSession!

  override init() {
    super.init()

    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
  }

  func response(request: String, _ message: [String : AnyObject]) -> [String : AnyObject] {
    var data = [String : AnyObject]()

    switch request {
    case "getAlarms":
      data = ["alarms": getAlarmsData()]
    case "getAlarm":
      if let index = message["index"] as? Int {
        data["alarm"] = getAlarmData(index)
      }
    case "cancelAlarms":
      LocalNotificationManager.cancelAllLocalNotifications()
      data = ["alarms": getAlarmsData()]
    case "cancelAlarm":
      if let index = message["index"] as? Int {
        let alarm = Alarm.create(index)
        if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!) {
          UIApplication.sharedApplication().cancelLocalNotification(notification)
        }

        data["alarm"] = getAlarmData(index)
      }
    case "updateAlarmMinutes":
      if let index = message["index"] as? Int, amount = message["amount"] as? Int {
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

  private func getAlarmsData() -> [AnyObject] {
    var alarms = [AnyObject]()
    
    for index in 0...4 {
      alarms.append(getAlarmData(index))
    }

    return alarms
  }

  private func getAlarmData(index: Int) -> [String: AnyObject] {
    let alarm = Alarm.create(index)
    var alarmData = [String: AnyObject]()

    if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!) {
      alarmData = extractAlarmData(notification)
      alarmData["title"] = alarm.title
    }

    return alarmData
  }

  private func extractAlarmData(notification: UILocalNotification) -> [String: AnyObject] {
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

@available(iOS 9.0, *)
extension WatchCommunicator: WCSessionDelegate {

  func session(session: WCSession, didReceiveMessage message: [String : AnyObject],
    replyHandler: ([String : AnyObject]) -> Void) {
      if let request = message["request"] as? String {
        replyHandler(response(request, message))
      }
  }
}
