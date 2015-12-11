import Foundation
import Sugar

enum PlateType {
  case Oven, Plate
}

class Alarm {

  var type: PlateType

  var indexPath: NSIndexPath? {
    willSet(newValue) {
      if newValue != nil {
        self.alarmID = idForIndexPath(newValue! as NSIndexPath)
      }
    }
  }

  var alarmID: String?
  var active: Bool = false

  lazy var title: String = {
    if self.type == .Oven { return localizedString("OVEN") }

    let leading: String = self.indexPath?.item == 0
      ? localizedString("TOP")
      : localizedString("BOTTOM")
    let position: String = self.indexPath?.section == 0
      ? localizedString("LEFT")
      : localizedString("RIGHT")

    return localizedString("\(leading) \(position) PLATE")
    }()

  lazy var timerTitle: String = {
    return "------------------\(self.title)------------------"
    }()

  init(type: PlateType = .Plate) {
    self.type = type
  }

  static func create(index: Int) -> Alarm {
    let section = index == 1 || index == 3  ? 1 : 0
    let item = index == 2 || index == 3 ? 1 : 0
    let indexPath = NSIndexPath(forItem: item, inSection: section)
    let alarm = Alarm(type: index == 4 ? .Oven : .Plate)

    alarm.indexPath = indexPath

    return alarm
  }

  static func titleForHomescreen() -> String {
    return localizedString("IT'S TIME TO GET COOKING")
  }

  static func subtitleForHomescreen() -> String {
    return localizedString("TAP A PLATE TO SET A TIMER");
  }

  static func subtitleForHomescreenUsingMinutes(maxMinutesLeft: NSNumber) -> String {
    var message: String

    if maxMinutesLeft.doubleValue == 0.0 {
      message = localizedString("IN LESS THAN A MINUTE")
    } else {
      let hoursLeft = floor(maxMinutesLeft.doubleValue / 60.0)
      let minutesLeft = maxMinutesLeft.doubleValue - (hoursLeft * 60)

      if hoursLeft > 0 {
        if hoursLeft == 1 && minutesLeft == 0 {
          message = localizedString("IN ABOUT 1 HOUR")
        } else if hoursLeft == 1 && minutesLeft > 0 {
          message = localizedString("IN ABOUT 1 HOUR \(Int(minutesLeft)) MINUTES")
        } else {
          message = localizedString("IN ABOUT \(Int(hoursLeft)) HOURS \(Int(minutesLeft)) MINUTES")
        }
      } else {
        if minutesLeft >= 57 {
          message = localizedString("IN ABOUT 1 HOUR")
        } else if minutesLeft < 10 {
          message = localizedString("IN \(Int(minutesLeft)) MINUTES")
        } else {
          var minutes = minutesLeft
          let mod = minutes % 5

          if mod != 0 {
            let nextMinutes = minutesLeft + 5
            let nextMod = nextMinutes % 5
            minutes = mod < 2 || (mod == 2 && (minutes - mod) % 10 == 0)
              ? minutes - mod
              : nextMinutes - nextMod
          }

          message = localizedString("IN ABOUT \(Int(minutes)) MINUTES")
        }
      }
    }

    return message
  }

  static func messageForSetAlarm() -> String {
    return localizedString("------------------SWIPE CLOCKWISE TO SET TIMER------------------")
  }

  static func messageForReleaseToSetAlarm() -> String {
    return localizedString("------------------RELEASE TO SET TIMER------------------")
  }

  static func defaultAlarmID() -> String {
    return ThymeAlarmIDKey
  }

  func idForIndexPath(indexPath: NSIndexPath) -> String {
    if type == .Oven {
      return "HYPAlert oven section: \(indexPath.section) row: \(indexPath.row)"
    }

    return "HYPAlert section: \(indexPath.section) row: \(indexPath.row)"
  }
}
