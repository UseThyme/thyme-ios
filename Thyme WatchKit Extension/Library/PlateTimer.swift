import Foundation

protocol PlateTimerDelegate: class {

  func plateTimerDidTick(plateTimer: PlateTimer)
}

class PlateTimer {

  let firedDate: NSDate
  let numberOfSeconds: Int

  var hours = 0
  var minutes = 0
  var seconds = 0

  var timer: NSTimer?
  weak var delegate: PlateTimerDelegate?

  // MARK: - Initialization

  init(firedDate: NSDate, numberOfSeconds: Int) {
    self.firedDate = firedDate
    self.numberOfSeconds = numberOfSeconds
  }

  deinit {
    stop()
  }

  // MARK: - Timer

  func start() {
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(1,
        target: self,
        selector: "updateSeconds:",
        userInfo: nil,
        repeats: true)
      NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: - Actions

  func updateSeconds(timer: NSTimer) {
    seconds -= 1

    if seconds < 0 {
      seconds = 59
      minutes -= 1

      if minutes < 0 && hours > 0 {
        minutes = 59
        hours -= 1
      }
    }

    delegate?.plateTimerDidTick(self)
  }
}
