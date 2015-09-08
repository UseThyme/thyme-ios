import WatchKit
import Foundation
import WatchConnectivity

class HomeInterfaceController: WKInterfaceController, Sessionable {

  @IBOutlet var mainGroup: WKInterfaceGroup!

  @IBOutlet var lostConnectionGroup: WKInterfaceGroup!
  @IBOutlet var lostConnectionImage: WKInterfaceImage!
  @IBOutlet var retryButton: WKInterfaceButton!

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

  var session : WCSession!
  var alarmTimer: AlarmTimer?

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    retryButton.setTitle(NSLocalizedString("Try again", comment: ""))

    minutesGroups = [topLeftMinutesGroup, topRightMinutesGroup,
      bottomLeftMinutesGroup, bottomRightMinutesGroup, ovenMinutesGroup]
    secondsGroups = [topLeftSecondsGroup, topRightSecondsGroup,
      bottomLeftSecondsGroup, bottomRightSecondsGroup, ovenSecondsGroup]
    labels = [topLeftLabel, topRightLabel,
      bottomLeftLabel, bottomRightLabel, ovenLabel]
  }

  override func willActivate() {
    super.willActivate()

    showLostConnection(false)
    activateSession()
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
        parameters["amount"] = 3 * 60
        kind = .UpdateAlarm
      case "AddFiveMinutes":
        parameters["amount"] = 5 * 60
        kind = .UpdateAlarm
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
    WKInterfaceDevice.currentDevice().playHaptic(.Stop)
    sendMessage(Message(.CancelAlarms))
  }

  @IBAction func retryButtonTapped() {
    activateSession()
    sendMessage(Message(.GetAlarms))
  }

  // MARK: - Communication

  func sendMessage(message: Message) {
    session.sendMessage(message.data,
      replyHandler: { [weak self] response in
        if let weakSelf = self, alarmData = response["alarms"] as? [AnyObject] {
          weakSelf.alarmTimer?.stop()
          weakSelf.showLostConnection(false)
          weakSelf.setupAlarms(alarmData)
        }
      }, errorHandler: { [weak self] error in
        if let weakSelf = self {
          weakSelf.showLostConnection(true)
        }
        print(error)
    })
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

      minutesGroups[index].setBackgroundImageNamed(ImageList.Home.minuteSequence)
      minutesGroups[index].startAnimatingWithImagesInRange(
        NSRange(location: alarm.minutes, length: 1),
        duration: 0, repeatCount: 1)

      secondsGroups[index].setBackgroundImageNamed(ImageList.Home.secondSequence)
      secondsGroups[index].startAnimatingWithImagesInRange(
        NSRange(location: 59 - alarm.seconds, length: 1),
        duration: 0, repeatCount: 1)
    } else {
      minutesGroups[index].setBackgroundImageNamed(nil)
      secondsGroups[index].setBackgroundImageNamed(nil)
    }

    labels[index].setText(text)
  }

  func showLostConnection(show: Bool) {
    mainGroup.setHidden(show)
    lostConnectionGroup.setHidden(!show)

    if show {
      alarmTimer?.stop()

      for index in 0..<minutesGroups.count {
        minutesGroups[index].setBackgroundImageNamed(nil)
        secondsGroups[index].setBackgroundImageNamed(nil)
      }

      lostConnectionImage.startAnimating()
    } else {
      lostConnectionImage.stopAnimating()
    }
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

// MARK: - WCSessionDelegate

extension HomeInterfaceController: WCSessionDelegate {

  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    if let alarmData = applicationContext["alarms"] as? [AnyObject] {
      alarmTimer?.stop()
      showLostConnection(false)
      setupAlarms(alarmData)
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
