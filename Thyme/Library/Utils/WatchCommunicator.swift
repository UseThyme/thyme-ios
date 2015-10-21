import Foundation
import WatchConnectivity

class WatchCommunicator {

  struct Message {

    struct Inbox {
      static let FetchAlarms = "App:fetchAlarms"
      static let FetchAlarm = "App:fetchAlarm"
      static let CancelAlarm = "App:cancelAlarm"
      static let CancelAlarms = "App:cancelAlarms"
      static let UpdateAlarm = "App:updateAlarm"
    }

    struct Outbox {
      static let UpdateAlarms = "Watch:updateAlarms"
      static let UpdateAlarm = "Watch:updateAlarm"
    }
  }

  private var wormhole: MMWormhole!
  private var listeningWormhole: MMWormholeSession!

  private var routesConfigured = false

  static let sharedInstance = WatchCommunicator()

  // MARK: - Routing

  func configureRoutes() {
    if routesConfigured { return }

    listeningWormhole = MMWormholeSession.sharedListeningSession()

    wormhole = MMWormhole(
      applicationGroupIdentifier: "group.no.hyper.thyme",
      optionalDirectory: "wormhole",
      transitingType: .SessionContext)

    listeningWormhole.listenForMessageWithIdentifier(Message.Inbox.FetchAlarms) { messageObject in
      self.sendAlarms()
    }

    listeningWormhole.listenForMessageWithIdentifier(Message.Inbox.FetchAlarm) { messageObject in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int else { return }

      self.sendAlarm(index)
    }

    listeningWormhole.listenForMessageWithIdentifier(Message.Inbox.CancelAlarms) { messageObject in
      AlarmCenter.cancelAllNotifications()
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)

      self.sendAlarms()
    }

    listeningWormhole.listenForMessageWithIdentifier(Message.Inbox.CancelAlarm) { messageObject in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int else { return }

      let alarm = Alarm.create(index)
      AlarmCenter.cancelNotification(alarm.alarmID!)
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)

      self.sendAlarm(index)
    }

    listeningWormhole.listenForMessageWithIdentifier(Message.Inbox.UpdateAlarm) { messageObject in
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
    }

    listeningWormhole.activateSessionListening()

    routesConfigured = true
  }

  // MARK: - Send Helpers

  func sendAlarms() {
    let message = ["alarms": self.getAlarmsData()]
    self.wormhole.passMessageObject(message, identifier: Message.Outbox.UpdateAlarms)
  }

  func sendAlarm(index: Int, data: [String: AnyObject]? = nil) {
    let alarmData = data ?? self.getAlarmData(index)
    let message = [
      "alarm": alarmData,
      "index": index
    ]
    self.wormhole.passMessageObject(message, identifier: Message.Outbox.UpdateAlarm)
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
