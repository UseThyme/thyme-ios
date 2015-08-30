import Foundation

class Alarm {

  var indexPath: NSIndexPath? {
    willSet(newValue) {
      if newValue != nil {
        self.alarmID = idForIndexPath(newValue! as NSIndexPath)
      }
    }
  }

  var alarmID: String?
  var active: Bool = false
  var oven: Bool = false

  lazy var title: String = {
    if self.oven == true { return NSLocalizedString("OVEN", comment: "OVEN") }

    let leading: String = self.indexPath?.row == 0
      ? NSLocalizedString("TOP", comment: "TOP")
      : NSLocalizedString("LOWER", comment: "LOWER")
    let position: String = self.indexPath?.row == 0
      ? NSLocalizedString("LEFT", comment: "LEFT")
      : NSLocalizedString("RIGHT", comment: "RIGHT")

    return NSLocalizedString("\(leading) \(position) PLATE", comment: "\(leading) \(position) PLATE")
    }()

  lazy var timerTitle: String = {
    return "------------------\(self.title)------------------"
    }()

  static func create(index: Int) -> Alarm {
    let section = index == 1 || index == 3  ? 1 : 0
    let item = index == 2 || index == 3 ? 1 : 0
    let indexPath = NSIndexPath(forItem: item, inSection: section)

    let alarm = Alarm()
    alarm.oven = index == 4
    alarm.indexPath = indexPath

    return alarm
  }

  static func titleForHomescreen() -> String {
    return NSLocalizedString("IT'S TIME TO GET COOKING",
      comment: "IT'S TIME TO GET COOKING")
  }

  static func subtitleForHomescreen() -> String {
    return  NSLocalizedString("TAP A PLATE TO SET A TIMER", comment: "TAP A PLATE TO SET A TIMER");
  }

  static func subtitleForHomescreenUsingMinutes(maxMinutesLeft: NSNumber) -> String {
    var maxMinutesLeft = maxMinutesLeft
    var message: String

    if maxMinutesLeft.doubleValue == 0.0 {
      message = NSLocalizedString("IN LESS THAN A MINUTE", comment: "IN LESS THAN A MINUTE")
    } else {
      let minutesLeft = maxMinutesLeft.doubleValue
      var hoursLeft = floor(minutesLeft / 60.0)

      if hoursLeft > 0 {
        maxMinutesLeft = maxMinutesLeft.doubleValue - (hoursLeft * 60)
      }

      let result = Int(floor(maxMinutesLeft.doubleValue / 5))
      var minutes = result == 0 ? 0 : result + 1 * 5

      if hoursLeft > 0 {
        if  minutes == 60 {
          hoursLeft += 1
          minutes = 0
        }

        if hoursLeft == 1 && minutes == 0 {
          message = NSLocalizedString("IN ABOUT 1 HOUR",
            comment: "IN ABOUT 1 HOUR")
        } else if hoursLeft == 1 && minutes > 0 {
          message = NSLocalizedString("IN ABOUT 1 HOUR \(Int(minutes)) MINUTES",
            comment: "IN ABOUT 1 HOUR \(Int(minutes)) MINUTES")
        } else {
          message = NSLocalizedString("IN ABOUT \(Int(hoursLeft)) HOURS \(Int(minutes)) MINUTES",
            comment: "IN ABOUT \(Int(hoursLeft)) HOURS \(Int(minutes)) MINUTES")
        }
      } else {
        let m = maxMinutesLeft.doubleValue / 10
        let miniMinutes = maxMinutesLeft.doubleValue - m * 10

        if maxMinutesLeft.doubleValue < 10 {
          message = NSLocalizedString("IN \(maxMinutesLeft.integerValue) MINUTES",
            comment: "IN \(maxMinutesLeft.integerValue) MINUTES")
        } else {
          if miniMinutes < 3 || (miniMinutes >= 5 && miniMinutes < 8) {
            if miniMinutes >= 5 {
              message = NSLocalizedString("IN ABOUT \(Int((m * 10) + 5)) MINUTES",
                comment: "IN ABOUT \(Int((m * 10) + 5)) MINUTES")
            } else {
              message = NSLocalizedString("IN ABOUT \(Int((m * 10))) MINUTES",
                comment: "IN ABOUT \(Int((m * 10))) MINUTES")
            }
          } else {
            if maxMinutesLeft.integerValue >= 58 {
              message = NSLocalizedString("IN ABOUT 1 HOUR",
                comment: "IN ABOUT 1 HOUR")
            } else {
              message = NSLocalizedString("IN ABOUT \(Int(minutes)) MINUTES",
                comment: "IN ABOUT \(Int(minutes)) MINUTES")
            }
          }
        }
      }
    }

    return message
  }

  static func messageForSetAlarm() -> String {
    return NSLocalizedString("------------------SWIPE CLOCKWISE TO SET TIMER------------------",
      comment: "------------------SWIPE CLOCKWISE TO SET TIMER------------------")
  }

  static func messageForReleaseToSetAlarm() -> String {
    return NSLocalizedString("------------------RELEASE TO SET TIMER------------------", comment: "------------------RELEASE TO SET TIMER------------------")
  }

  static func defaultAlarmID() -> String {
    return ThymeAlarmIDKey
  }

  func idForIndexPath(indexPath: NSIndexPath) -> String {
    if oven {
      return "HYPAlert oven section: \(indexPath.section) row: \(indexPath.row)"
    }

    return "HYPAlert section: \(indexPath.section) row: \(indexPath.row)"
  }
}
