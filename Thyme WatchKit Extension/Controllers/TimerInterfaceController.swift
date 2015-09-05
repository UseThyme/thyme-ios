import WatchKit
import Foundation
import WatchConnectivity

class TimerInterfaceController: WKInterfaceController {

  @IBOutlet weak var minutesGroup: WKInterfaceGroup!
  @IBOutlet weak var secondsGroup: WKInterfaceGroup!

  @IBOutlet weak var minutesTextLabel: WKInterfaceLabel!
  @IBOutlet weak var hoursTextLabel: WKInterfaceLabel!
  @IBOutlet weak var minutesLabel: WKInterfaceLabel!

  var session : WCSession!
  var alarmTimer: AlarmTimer?
  var index = 0

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

    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
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

    session.sendMessage(message.data,
      replyHandler: { [weak self] response in
        if let weakSelf = self, alarmData = response["alarm"] as? [String: AnyObject] {
          weakSelf.alarmTimer?.stop()
          weakSelf.setupAlarm(alarmData)
        }
      }, errorHandler: { error in
        print(error)
    })
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

// MARK: - WCSessionDelegate

extension TimerInterfaceController: WCSessionDelegate {

  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    if let alarms = applicationContext["alarms"] as? [AnyObject],
      alarmData = alarms[index] as? [String: AnyObject] where alarms.count > index {
        alarmTimer?.stop()
        setupAlarm(alarmData)
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
