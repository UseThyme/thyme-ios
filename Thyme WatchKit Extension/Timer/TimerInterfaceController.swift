import WatchKit
import Foundation

class TimerInterfaceController: WKInterfaceController {

  @IBOutlet weak var minutesGroup: WKInterfaceGroup!
  @IBOutlet weak var secondsGroup: WKInterfaceGroup!
  @IBOutlet weak var minutesLabel: WKInterfaceLabel!
  @IBOutlet weak var textLabel: WKInterfaceLabel!

  var alarmTimer: AlarmTimer?
  var index = 0

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    if let context = context as? TimerContext {
      index = context.index
      setTitle(context.title)
    }
  }

  override func willActivate() {
    super.willActivate()
    loadData()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Data

  func loadData() {
    WKInterfaceController.openParentApplication(["request": "getAlarm", "index": index]) {
      [unowned self] response, error in
      if let response = response,
        alarmInfo = response["alarm"] as? [String: AnyObject] {
          self.setupAlarm(alarmInfo)
      } else {
        println("Error with fetching of the alarm with index = \(self.index) from the parent app")
      }
    }
  }

  // MARK: - UI

  func updatePlate(alarm: Alarm) {
    var text = ""

    if alarm.active {
      if alarm.hours > 0 {
        if alarm.minutes < 10 {
          text = "\(alarm.hours):0\(alarm.minutes)"
        } else {
          text = "\(alarm.hours):\(alarm.minutes)"
        }
      } else {
        text = "\(alarm.minutes)"
      }

      minutesGroup.setBackgroundImageNamed(alarm.hours > 0
        ? ImageList.Timer.minuteHourSequence
        : ImageList.Timer.minuteSequence)
      minutesGroup.startAnimatingWithImagesInRange(
        NSRange(location: alarm.minutes, length: 1),
        duration: 0, repeatCount: 1)

      secondsGroup.setBackgroundImageNamed(ImageList.Timer.secondSequence)
      secondsGroup.startAnimatingWithImagesInRange(
        NSRange(location: 59 - alarm.seconds, length: 1),
        duration: 0, repeatCount: 1)
    }

    minutesLabel.setText(text)
    textLabel.setText(NSLocalizedString("minutes", comment: "").uppercaseString)
  }

  // MARK: - Alarms

  func setupAlarm(alarmInfo: [String: AnyObject]) {
    let alarm = Alarm(
      firedDate: alarmInfo["firedDate"] as? NSDate,
      numberOfSeconds: alarmInfo["numberOfSeconds"] as? NSNumber)

    updatePlate(alarm)

    if alarm.active {
      alarmTimer = AlarmTimer(alarms: [alarm], delegate: self)
      alarmTimer?.start()
    }
  }
}

// MARK: - AlarmTimerDelegate

extension TimerInterfaceController: AlarmTimerDelegate {

  func alarmTimerDidTick(alarmTimer: AlarmTimer, alarms: [Alarm]) {
    if let alarm = alarms.first {
      updatePlate(alarm)
      if !alarm.active {
        alarmTimer.stop()
      }
    }
  }
}
