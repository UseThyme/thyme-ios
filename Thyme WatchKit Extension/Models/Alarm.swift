import Foundation

class Alarm {

  var firedDate: NSDate?
  var numberOfSeconds: NSNumber?

  var hours = 0
  var minutes = 0
  var seconds = 0

  var active: Bool {
    return hours > 0 || minutes > 0 || seconds > 0
  }

  init(firedDate: NSDate? = nil, numberOfSeconds: NSNumber? = nil) {
    self.firedDate = firedDate
    self.numberOfSeconds = numberOfSeconds

    if let firedDate = self.firedDate, numberOfSeconds = self.numberOfSeconds {
      let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
      let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
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
