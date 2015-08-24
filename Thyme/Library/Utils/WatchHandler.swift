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

        alarms[index] = NSNull()
        if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!) {
          alarms[index] = notification
        }
      }

      data = ["alarms": alarms]
    }

    return data
  }
}
