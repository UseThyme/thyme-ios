import Foundation
import WatchConnectivity

class WatchCommunicator {
    fileprivate var wormhole: MMWormhole!
    fileprivate var listeningWormhole: MMWormholeSession!

    fileprivate var routesConfigured = false

    static let sharedInstance = WatchCommunicator()

    // MARK: - Routing

    func configureRoutes() {
        if routesConfigured {
            listeningWormhole.activateListening()
            return
        }

        listeningWormhole = MMWormholeSession.sharedListening()

        wormhole = MMWormhole(
            applicationGroupIdentifier: "group.no.hyper.thyme",
            optionalDirectory: "wormhole",
            transitingType: .sessionMessage)

        listeningWormhole.listenForMessage(withIdentifier: Routes.App.alarms) { _ in
            self.sendAlarms()
        }

        listeningWormhole.listenForMessage(withIdentifier: Routes.App.alarm) { _ in
            self.sendAlarms()
        }

        listeningWormhole.listenForMessage(withIdentifier: Routes.App.cancelAlarms) { _ in
            AlarmCenter.cancelAllNotifications()
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: AlarmCenter.Notifications.AlarmsDidUpdate),
                object: nil)
        }

        listeningWormhole.listenForMessage(withIdentifier: Routes.App.cancelAlarm) { messageObject in
            guard let message = messageObject as? [String: AnyObject],
                let index = message["index"] as? Int else { return }

            let alarm = Alarm.create(index)
            AlarmCenter.cancelNotification(alarm.alarmID!)
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: AlarmCenter.Notifications.AlarmsDidUpdate),
                object: nil)
        }

        listeningWormhole.listenForMessage(withIdentifier: Routes.App.updateAlarm) { messageObject in
            guard let message = messageObject as? [String: AnyObject],
                let index = message["index"] as? Int,
                let amount = message["amount"] as? Int else { return }

            let alarm = Alarm.create(index)
            let seconds = TimeInterval(amount)

            if let existingNotification = AlarmCenter.getNotification(alarm.alarmID!) {
                AlarmCenter.extendNotification(existingNotification, seconds: seconds)
            } else {
                AlarmCenter.scheduleNotification(alarm.alarmID!,
                                                 seconds: seconds,
                                                 message: NSLocalizedString("\(alarm.title) just finished", comment: ""))
            }

            NotificationCenter.default.post(
                name: Notification.Name(rawValue: AlarmCenter.Notifications.AlarmsDidUpdate),
                object: nil)
        }

        listeningWormhole.activateListening()
        routesConfigured = true
    }

    // MARK: - Send Helpers

    func sendAlarms() {
        let message = ["alarms": self.getAlarmsData()]

        [Routes.Watch.glance, Routes.Watch.home, Routes.Watch.timer].forEach {
            wormhole.passMessageObject(message as NSCoding, identifier: $0)
        }
    }

    // MARK: - Data Helpers

    fileprivate func getAlarmsData() -> [AnyObject] {
        var alarms = [AnyObject]()

        for index in 0 ... 4 {
            alarms.append(getAlarmData(index) as AnyObject)
        }

        return alarms
    }

    fileprivate func getAlarmData(_ index: Int) -> [String: AnyObject] {
        let alarm = Alarm.create(index)
        var alarmData = [String: AnyObject]()

        if let notification = AlarmCenter.getNotification(alarm.alarmID!) {
            alarmData = extractAlarmData(notification)
            alarmData["title"] = alarm.title as AnyObject
        }

        return alarmData
    }

    func extractAlarmData(_ notification: UILocalNotification) -> [String: AnyObject] {
        var alarmData = [String: AnyObject]()

        if let userInfo = notification.userInfo,
            let firedDate = userInfo[Alarm.fireDateKey] as? Date,
            let numberOfSeconds = userInfo[Alarm.fireIntervalKey] as? NSNumber {
            alarmData["firedDate"] = firedDate as AnyObject
            alarmData["numberOfSeconds"] = numberOfSeconds
        }

        return alarmData
    }
}
