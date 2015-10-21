import Foundation
import WatchConnectivity

class WatchCommunicator {

  private let wormhole = MMWormhole(
    applicationGroupIdentifier: "group.no.hyper.thyme",
    optionalDirectory: "wormhole")

  static let sharedInstance = WatchCommunicator()

  // MARK: - Routing

  func setupRoutes() {
    wormhole.listenForMessageWithIdentifier("App:alarms", listener: { (messageObject) -> Void in
      self.sendAlarms()
    })

    wormhole.listenForMessageWithIdentifier("App:alarm", listener: { (messageObject) -> Void in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int else { return }

      self.sendAlarm(index)
    })

    wormhole.listenForMessageWithIdentifier("App:cancelAlarms", listener: { (messageObject) -> Void in
      AlarmCenter.cancelAllNotifications()
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)

      self.sendAlarms()
    })

    wormhole.listenForMessageWithIdentifier("App:cancelAlarm", listener: { (messageObject) -> Void in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int else { return }

      let alarm = Alarm.create(index)
      AlarmCenter.cancelNotification(alarm.alarmID!)
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)

      self.sendAlarm(index)
    })

    wormhole.listenForMessageWithIdentifier("App:updateAlarm", listener: { (messageObject) -> Void in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int,
        amount = message["amount"] as? Int else { return }

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

      var alarmData = [String: AnyObject]()
      if let notification = notification {
        alarmData = self.extractAlarmData(notification)
        alarmData["title"] = alarm.title
      }

      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)

      self.sendAlarm(index, data: alarmData)
    })
  }

  // MARK: - Send Helpers

  func sendAlarms() {
    let message = ["alarms": self.getAlarmsData()]
    self.wormhole.passMessageObject(message, identifier: "Watch:alarms")
  }

  func sendAlarm(index: Int, data: [String: AnyObject]? = nil) {
    let alarmData = data ?? self.getAlarmData(index)
    let message = [
      "alarm": alarmData,
      "index": index
    ]
    self.wormhole.passMessageObject(message, identifier: "Watch:alarm")
  }

  // MARK: - Data Helpers

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

    if let notification = AlarmCenter.getNotification(alarm.alarmID!) {
      alarmData = extractAlarmData(notification)
      alarmData["title"] = alarm.title
    }

    return alarmData
  }

  func extractAlarmData(notification: UILocalNotification) -> [String: AnyObject] {
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
