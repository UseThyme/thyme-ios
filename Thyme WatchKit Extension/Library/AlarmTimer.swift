import Foundation

protocol AlarmTimerDelegate: class {
    func alarmTimerDidTick(_ alarmTimer: AlarmTimer, alarms: [Alarm])
}

class AlarmTimer: NSObject {
    var timer: Timer?
    var alarms = [Alarm]()
    weak var delegate: AlarmTimerDelegate?

    // MARK: - Initialization

    init(alarms: [Alarm], delegate: AlarmTimerDelegate? = nil) {
        self.alarms = alarms
        self.delegate = delegate
    }

    deinit {
        stop()
    }

    // MARK: - Timer

    func start() {
        if timer == nil {
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(AlarmTimer.update(_:)),
                                                  userInfo: nil,
                                                  repeats: true)
                RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.common)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Actions

    @objc func update(_ timer: Timer) {
        for alarm in alarms { alarm.update() }

        delegate?.alarmTimerDidTick(self, alarms: alarms)
    }
}
