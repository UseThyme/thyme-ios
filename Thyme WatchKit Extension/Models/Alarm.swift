import Foundation

class Alarm {

  static func indexFromString(string: String) -> Int {
    var index = 4

    switch string {
    case "HYPAlert section: 0 row: 0":
      index = 0
    case "HYPAlert section: 1 row: 0":
      index = 1
    case "HYPAlert section: 0 row: 1":
      index = 2
    case "HYPAlert section: 1 row: 1":
      index = 3
    default:
      break
    }

    return index
  }

  var title: String
  var firedDate: NSDate?
  var numberOfSeconds: NSNumber?

  var hours = 0
  var minutes = 0
  var seconds = 0
  var secondsLeft: NSTimeInterval = 0

  var active: Bool {
    return hours > 0 || minutes > 0 || seconds > 0
  }

  var shortText: String {
    var text: String

    if hours > 0 {
      if minutes < 10 {
        text = "\(hours):0\(minutes)"
      } else {
        text = "\(hours):\(minutes)"
      }
    } else if minutes > 0 {
      text = "\(minutes)"
    } else {
      text = "\(seconds)"
    }

    return text
  }

  init(title: String = "", firedDate: NSDate? = nil, numberOfSeconds: NSNumber? = nil) {
    self.title = title
    self.firedDate = firedDate
    self.numberOfSeconds = numberOfSeconds

    if let firedDate = self.firedDate, numberOfSeconds = self.numberOfSeconds {
      secondsLeft = NSTimeInterval(numberOfSeconds.integerValue)
        - NSDate().timeIntervalSinceDate(firedDate)
      
      let currentSecond = secondsLeft % 60
      var minutesLeft = floor(secondsLeft / 60)
      let hoursLeft = floor(minutesLeft / 60)

      if hoursLeft > 0 {
        minutesLeft = minutesLeft - (hoursLeft * 60)
      }

      self.hours = Int(hoursLeft)
      self.minutes = Int(minutesLeft)
      self.seconds = Int(currentSecond)
    }
  }

  func reset() {
    hours = 0
    minutes = 0
    seconds = 0
  }

  func update() {
    seconds -= 1

    if seconds < 0 {
      seconds = 59
      minutes -= 1

      if minutes < 0 && hours > 0 {
        minutes = 59
        hours -= 1
      }
    }

    if seconds == 0 && minutes == 0 && hours == 0 {
      reset()
    }

    if minutes == -1 {
      reset()
    }
  }
}
