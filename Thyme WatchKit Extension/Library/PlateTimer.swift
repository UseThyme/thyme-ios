import Foundation

protocol PlateTimerDelegate: class {

  func plateTimerDidTick(plateTimer: PlateTimer, plates: [Plate])
}

class PlateTimer {

  var timer: NSTimer?
  var plates = [Plate]()
  weak var delegate: PlateTimerDelegate?

  // MARK: - Initialization

  init(plates: [Plate]) {
    self.plates = plates
  }

  deinit {
    stop()
  }

  // MARK: - Timer

  func start() {
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(1,
        target: self,
        selector: "update:",
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

  func update(timer: NSTimer) {
    plates.map { $0.updateSeconds() }
    delegate?.plateTimerDidTick(self, plates: plates)
  }
}
