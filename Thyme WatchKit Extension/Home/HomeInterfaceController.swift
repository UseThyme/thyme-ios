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

  @IBOutlet var topLeftLabel: WKInterfaceLabel!
  @IBOutlet var topRightLabel: WKInterfaceLabel!
  @IBOutlet var bottomLeftLabel: WKInterfaceLabel!
  @IBOutlet var bottomRightLabel: WKInterfaceLabel!
  @IBOutlet var ovenLabel: WKInterfaceLabel!

  var minutesGroups = [WKInterfaceGroup]()
  var secondsGroups = [WKInterfaceGroup]()
  var labels = [WKInterfaceLabel]()

  var alarmTimer: AlarmTimer?

  lazy var communicator: Communicator = {
    let communicator = Communicator()
    return communicator
    }()

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    minutesGroups = [topLeftMinutesGroup, topRightMinutesGroup,
      bottomLeftMinutesGroup, bottomRightMinutesGroup, ovenMinutesGroup]
    secondsGroups = [topLeftSecondsGroup, topRightSecondsGroup,
      bottomLeftSecondsGroup, bottomRightSecondsGroup, ovenSecondsGroup]
    labels = [topLeftLabel, topRightLabel,
      bottomLeftLabel, bottomRightLabel, ovenLabel]
  }

  override func willActivate() {
    super.willActivate()
    sendMessage(Message(.GetAlarms))
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Local notifications

  override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
    if let alarmID = localNotification.userInfo?["HYPAlarmID"] as? String, actionID = identifier {
      var parameters = [String: AnyObject]()
      var kind: Message.Kind

      switch actionID {
      case "AddThreeMinutes":
        parameters["amount"] = 3
        kind = .UpdateAlarmMinutes
      case "AddFiveMinutes":
        parameters["amount"] = 5
        kind = .UpdateAlarmMinutes
      default:
        kind = .CancelAlarm
        break
      }

      parameters["index"] = Alarm.indexFromString(alarmID)
      sendMessage(Message(kind, parameters))
    }
  }

  // MARK: - Actions

  @IBAction func topLeftButtonDidTap() {
    presentController(0, title: NSLocalizedString("Top Left", comment: ""))
  }

  @IBAction func topRightButtonDidTap() {
    presentController(1, title: NSLocalizedString("Top Right", comment: ""))
  }

  @IBAction func bottomLeftButtonDidTap() {
    presentController(2, title: NSLocalizedString("Bottom Left", comment: ""))
  }

  @IBAction func bottomRightButtonDidTap() {
    presentController(3, title: NSLocalizedString("Bottom Right", comment: ""))
  }

  @IBAction func ovenButtonDidTap() {
    presentController(4, title: NSLocalizedString("Oven", comment: ""))
  }

  @IBAction func menuCancelAllButtonDidTap() {
    sendMessage(Message(.CancelAlarms))
  }

  // MARK: - Communication

  func sendMessage(message: Message) {
    communicator.sendMessage(message) {
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

    labels[index].setText(text)
  }

  // MARK: - Alarms

  func setupAlarms(alarmData: [AnyObject]) {
    var alarms = [Alarm]()

    for (index, alarmInfo) in alarmData.enumerate() {
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
    for (index, alarm) in alarms.enumerate() {
      updatePlate(index, alarm: alarm)
    }

    if alarms.filter({ $0.active }).count == 0 {
      alarmTimer.stop()
    }
  }
}
