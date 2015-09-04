import WatchKit
import Foundation

class TimerInterfaceController: WKInterfaceController {

  @IBOutlet weak var minutesGroup: WKInterfaceGroup!
  @IBOutlet weak var secondsGroup: WKInterfaceGroup!

  @IBOutlet weak var minutesTextLabel: WKInterfaceLabel!
  @IBOutlet weak var hoursTextLabel: WKInterfaceLabel!
  @IBOutlet weak var minutesLabel: WKInterfaceLabel!

  var alarmTimer: AlarmTimer?
  var index = 0

  lazy var communicator: Communicator = {
    let communicator = Communicator()
    return communicator
    }()

  // MARK: - Lifecycle

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    if let context = context as? TimerContext {
      index = context.index
      setTitle(context.title)
    }
  }

  override func willActivate() {
    super.willActivate()
    sendMessage(Message(.GetAlarm))
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Actions

  @IBAction func menu3MinutesButtonDidTap() {
    sendMessage(Message(.UpdateAlarmMinutes, ["amount": 3]))
  }
  
  @IBAction func menu5MinutesButtonDidTap() {
    sendMessage(Message(.UpdateAlarmMinutes, ["amount": 5]))
  }
  
  @IBAction func menuCancelButtonDidTap() {
    sendMessage(Message(.CancelAlarm))
  }

  // MARK: - Communication

  func sendMessage(var message: Message) {
    message.parameters["index"] = index
    
    communicator.sendMessage(message) {
      [unowned self] response, error in
      if let response = response,
        alarmInfo = response["alarm"] as? [String: AnyObject] where error == nil {
          self.alarmTimer?.stop()
          self.setupAlarm(alarmInfo)
      } else {
        print("Error with fetching of the alarm with index = \(self.index) from the parent app")
      }
    }
  }

  // MARK: - UI

  func updatePlate(alarm: Alarm) {
    var hoursText = ""

    if alarm.active {
      if alarm.hours > 0 {
        hoursText = "\(alarm.hours) " + NSLocalizedString("hour", comment: "")
      }

      secondsGroup.setBackgroundImageNamed(ImageList.Timer.secondSequence)
      secondsGroup.startAnimatingWithImagesInRange(
        NSRange(location: 59 - alarm.seconds, length: 1),
        duration: 0, repeatCount: 1)
    } else {
      secondsGroup.setBackgroundImageNamed(nil)
    }

    minutesGroup.setBackgroundImageNamed(ImageList.Timer.minuteSequence)
    minutesGroup.startAnimatingWithImagesInRange(
      NSRange(location: alarm.minutes, length: 1),
      duration: 0, repeatCount: 1)

    minutesLabel.setText("\(alarm.minutes)")
    minutesTextLabel.setText(NSLocalizedString("minutes", comment: "").uppercaseString)
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
