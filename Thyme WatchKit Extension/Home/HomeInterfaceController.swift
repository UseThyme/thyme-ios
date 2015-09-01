import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var topLeftMinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var topRightMinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var bottomLeftMinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var bottomRightMinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenMinutesGroup: WKInterfaceGroup!

  @IBOutlet weak var topLeftSecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var topRightSecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var bottomLeftSecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var bottomRightSecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenSecondsGroup: WKInterfaceGroup!

  @IBOutlet weak var topLeftButton: WKInterfaceButton!
  @IBOutlet weak var topRightButton: WKInterfaceButton!
  @IBOutlet weak var bottomLeftButton: WKInterfaceButton!
  @IBOutlet weak var bottomRightButton: WKInterfaceButton!
  @IBOutlet weak var ovenButton: WKInterfaceButton!

  var minutesGroups = [WKInterfaceGroup]()
  var secondsGroups = [WKInterfaceGroup]()
  var buttons = [WKInterfaceButton]()

  var alarmTimer: AlarmTimer?

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    minutesGroups = [topLeftMinutesGroup, topRightMinutesGroup,
      bottomLeftMinutesGroup, bottomRightMinutesGroup, ovenMinutesGroup]
    secondsGroups = [topLeftSecondsGroup, topRightSecondsGroup,
      bottomLeftSecondsGroup, bottomRightSecondsGroup, ovenSecondsGroup]
    buttons = [topLeftButton, topRightButton,
      bottomLeftButton, bottomRightButton, ovenButton]
  }

  override func willActivate() {
    super.willActivate()
    request(.GetAlarms)
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Actions

  @IBAction func topLeftButtonDidTap() {
    presentController(0, title: NSLocalizedString("Upper Left", comment: ""))
  }

  @IBAction func topRightButtonDidTap() {
    presentController(1, title: NSLocalizedString("Upper Right", comment: ""))
  }

  @IBAction func bottomLeftButtonDidTap() {
    presentController(2, title: NSLocalizedString("Lower Left", comment: ""))
  }

  @IBAction func bottomRightButtonDidTap() {
    presentController(3, title: NSLocalizedString("Lower Right", comment: ""))
  }

  @IBAction func ovenButtonDidTap() {
    presentController(4, title: NSLocalizedString("Oven", comment: ""))
  }

  @IBAction func menuCancelAllButtonDidTap() {
    request(.CancelAlarms)
  }

  // MARK: - Communication

  func request(kind: Communication.Kind) {
    Communication.request(kind) {
      [unowned self] response, error in
      if let response = response,
        alarmData = response["alarms"] as? [AnyObject] {
          self.alarmTimer?.stop()
          self.setupAlarms(alarmData)
      } else {
        print("Error with fetching of alarms from the parent app")
      }
    }
  }

  // MARK: - UI

  func presentController(index: Int, title: String) {
    let context = TimerContext(index: index, title: title)
    pushControllerWithName("TimerController", context: context)
  }

  func updatePlate(index: Int, alarm: Alarm) {
    var text = ""

    if alarm.active {
      text = alarm.shortText

      minutesGroups[index].setBackgroundImageNamed(alarm.hours > 0
        ? ImageList.Timer.minuteHourSequence
        : ImageList.Timer.minuteSequence)
      minutesGroups[index].startAnimatingWithImagesInRange(
        NSRange(location: alarm.minutes, length: 1),
        duration: 0, repeatCount: 1)

      secondsGroups[index].setBackgroundImageNamed(ImageList.Timer.secondSequence)
      secondsGroups[index].startAnimatingWithImagesInRange(
        NSRange(location: 59 - alarm.seconds, length: 1),
        duration: 0, repeatCount: 1)
    } else {
      minutesGroups[index].setBackgroundImageNamed(index == 4
        ? nil
        : ImageList.Main.plateBackground)
      secondsGroups[index].setBackgroundImageNamed(nil)
    }

    buttons[index].setTitle(text)
  }

  // MARK: - Alarms

  func setupAlarms(alarmData: [AnyObject]) {
    var alarms = [Alarm]()

    for (index, alarmInfo) in enumerate(alarmData) {
      if index == self.minutesGroups.count {
        break
      }

      let alarm: Alarm

      if let alarmInfo = alarmInfo as? [String: AnyObject] {
        alarm = Alarm(
          firedDate: alarmInfo["firedDate"] as? NSDate,
          numberOfSeconds: alarmInfo["numberOfSeconds"] as? NSNumber)
      } else {
        alarm = Alarm()
      }

      updatePlate(index, alarm: alarm)
      alarms.append(alarm)
    }

    if alarms.filter({ $0.active }).count > 0 {
      alarmTimer = AlarmTimer(alarms: alarms, delegate: self)
      alarmTimer?.start()
    }
  }
}

// MARK: - AlarmTimerDelegate

extension HomeInterfaceController: AlarmTimerDelegate {

  func alarmTimerDidTick(alarmTimer: AlarmTimer, alarms: [Alarm]) {
    for (index, alarm) in enumerate(alarms) {
      updatePlate(index, alarm: alarm)
    }

    if alarms.filter({ $0.active }).count == 0 {
      alarmTimer.stop()
    }
  }
}
