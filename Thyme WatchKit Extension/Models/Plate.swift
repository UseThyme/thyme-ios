import Foundation

class Plate {

  let firedDate: NSDate
  let numberOfSeconds: Int

  var hours = 0
  var minutes = 0
  var seconds = 0

  init(firedDate: NSDate, numberOfSeconds: Int) {
    self.firedDate = firedDate
    self.numberOfSeconds = numberOfSeconds
  }

  func updateSeconds() {
    seconds -= 1

    if seconds < 0 {
      seconds = 59
      minutes -= 1

      if minutes < 0 && hours > 0 {
        minutes = 59
        hours -= 1
      }
    }
  }
}
