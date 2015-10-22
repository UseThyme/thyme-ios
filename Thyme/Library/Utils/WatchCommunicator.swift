import Foundation
import WatchConnectivity

class WatchCommunicator {

  private var wormhole: MMWormhole!
  private var listeningWormhole: MMWormholeSession!

  private var routesConfigured = false

  static let sharedInstance = WatchCommunicator()

  // MARK: - Routing

  func configureRoutes() {
    if routesConfigured {
      listeningWormhole.activateSessionListening()
      return
    }

    listeningWormhole = MMWormholeSession.sharedListeningSession()

    wormhole = MMWormhole(
      applicationGroupIdentifier: "group.no.hyper.thyme",
      optionalDirectory: "wormhole",
      transitingType: .SessionMessage)

    listeningWormhole.listenForMessageWithIdentifier(Routes.App.alarms) { messageObject in
      self.sendAlarms()
    }

    listeningWormhole.listenForMessageWithIdentifier(Routes.App.alarm) { messageObject in
      self.sendAlarms()
    }

    listeningWormhole.listenForMessageWithIdentifier(Routes.App.cancelAlarms) { messageObject in
      AlarmCenter.cancelAllNotifications()
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)
    }

    listeningWormhole.listenForMessageWithIdentifier(Routes.App.cancelAlarm) { messageObject in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int else { return }

      let alarm = Alarm.create(index)
      AlarmCenter.cancelNotification(alarm.alarmID!)
      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)
    }

    listeningWormhole.listenForMessageWithIdentifier(Routes.App.updateAlarm) { messageObject in
      guard let message = messageObject as? [String: AnyObject],
        index = message["index"] as? Int,
        amount = message["amount"] as? Int else { return }

      let alarm = Alarm.create(index)
      let seconds = NSTimeInterval(amount)

      if let existingNotification = AlarmCenter.getNotification(alarm.alarmID!) {
        AlarmCenter.extendNotification(existingNotification, seconds: seconds)
      } else {
        AlarmCenter.scheduleNotification(alarm.alarmID!,
          seconds: seconds,
          message: NSLocalizedString("\(alarm.title) just finished", comment: ""))
      }

      NSNotificationCenter.defaultCenter().postNotificationName(
        AlarmCenter.Notifications.AlarmsDidUpdate,
        object: nil)
    }

    listeningWormhole.activateSessionListening()
    routesConfigured = true
  }

  // MARK: - Send Helpers

  func sendAlarms() {
    let message = ["alarms": self.getAlarmsData()]

    [Routes.Watch.glance, Routes.Watch.home, Routes.Watch.timer].forEach {
      wormhole.passMessageObject(message, identifier: $0)
    }
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
