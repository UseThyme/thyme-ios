import WatchKit
import Foundation

class TimerInterfaceController: WKInterfaceController {

  struct Request {
    static let getAlarm = "getAlarm"
    static let updateAlarmMinutes = "updateAlarmMinutes"
    static let cancelAlarm = "cancelAlarm"
  }

  @IBOutlet weak var minutesGroup: WKInterfaceGroup!
  @IBOutlet weak var secondsGroup: WKInterfaceGroup!

  @IBOutlet weak var minutesTextLabel: WKInterfaceLabel!
  @IBOutlet weak var hoursTextLabel: WKInterfaceLabel!
  @IBOutlet weak var minutesLabel: WKInterfaceLabel!

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
    load(Request.getAlarm)
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Actions


  @IBAction func menu3MinutesButtonDidTap() {
    load(Request.updateAlarmMinutes, data: ["amount": 3])
  }
  
  @IBAction func menu5MinutesButtonDidTap() {
    load(Request.updateAlarmMinutes, data: ["amount": 5])
  }
  
  @IBAction func menuCancelButtonDidTap() {
    load(Request.cancelAlarm)
  }

  // MARK: - Communication

  func load(request: String, data: [NSObject : AnyObject] = [:]) {
    var requestData = data
    requestData["request"] = request
    requestData["index"] = index

    WKInterfaceController.openParentApplication(requestData) {
      [unowned self] response, error in

      if let response = response,
        alarmInfo = response["alarm"] as? [String: AnyObject] where error == nil {
          self.alarmTimer?.stop()
          self.setupAlarm(alarmInfo)
      } else {
        println("Error with fetching of the alarm with index = \(self.index) from the parent app")
      }
    }
  }

  // MARK: - UI

  func updatePlate(alarm: Alarm) {
    var minutesText = ""
    var hoursText = ""

    if alarm.active {
      minutesText = "\(alarm.minutes)"

      if alarm.hours > 0 {
        hoursText = "\(alarm.hours) " + NSLocalizedString("hour", comment: "")
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
    } else {
      minutesGroup.setBackgroundImageNamed(ImageList.Main.plateBackground)
      secondsGroup.setBackgroundImageNamed(nil)
    }

    minutesLabel.setText(minutesText)
    minutesTextLabel.setText(alarm.active ?
      NSLocalizedString("minutes", comment: "").uppercaseString : "")
    hoursTextLabel.setText(hoursText.uppercaseString)
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
