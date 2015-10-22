import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController, Communicable {

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
  var alarmTimer: AlarmTimer?
  
  var wormhole: MMWormhole!
  var listeningWormhole: MMWormholeSession!
  var communicationConfigured = false

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    retryButton.setTitle(NSLocalizedString("Try again", comment: ""))

    minutesGroups = [topLeftMinutesGroup, topRightMinutesGroup,
      bottomLeftMinutesGroup, bottomRightMinutesGroup, ovenMinutesGroup]
    secondsGroups = [topLeftSecondsGroup, topRightSecondsGroup,
      bottomLeftSecondsGroup, bottomRightSecondsGroup, ovenSecondsGroup]
    labels = [topLeftLabel, topRightLabel,
      bottomLeftLabel, bottomRightLabel, ovenLabel]

    configureCommunication()
  }

  override func willActivate() {
    super.willActivate()

    showLostConnection(false)
    wormhole.passMessageObject([:], identifier: Routes.App.alarms)
  }

  // MARK: - Local notifications

  override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
    if let alarmID = localNotification.userInfo?["HYPAlarmID"] as? String, actionID = identifier {
      var parameters = [String: AnyObject]()
      var identifier = Routes.App.updateAlarm

      switch actionID {
      case "AddThreeMinutes":
        parameters["amount"] = 3 * 60
      case "AddFiveMinutes":
        parameters["amount"] = 5 * 60
      default:
        identifier = Routes.App.cancelAlarm
        break
      }

      parameters["index"] = Alarm.indexFromString(alarmID)
      wormhole.passMessageObject(parameters, identifier: identifier)
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
    wormhole.passMessageObject([:], identifier: Routes.App.cancelAlarms)
  }

  @IBAction func retryButtonTapped() {
    wormhole.passMessageObject([:], identifier: Routes.App.alarms)
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

  func clearAllPlates() {
    for index in 0..<minutesGroups.count {
      minutesGroups[index].setBackgroundImageNamed(nil)
      secondsGroups[index].setBackgroundImageNamed(nil)
      labels[index].setText("")
    }
  }

  func showLostConnection(show: Bool) {
    mainGroup.setHidden(show)
    lostConnectionGroup.setHidden(!show)

    if show {
      alarmTimer?.stop()
      clearAllPlates()
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
    } else {
      clearAllPlates()
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

// MARK: - Communicable

extension HomeInterfaceController {

  func configureCommunication() {
    if communicationConfigured { return }

    clearAllPlates()
    configureSession()

    listeningWormhole.listenForMessageWithIdentifier(Routes.Watch.home) {
      [weak self] (messageObject) -> Void in

      guard let weakSelf = self, message = messageObject as? [String: AnyObject],
        alarmData = message["alarms"] as? [AnyObject] else {
          self?.showLostConnection(true)
          return
      }

      weakSelf.alarmTimer?.stop()
      weakSelf.showLostConnection(false)
      weakSelf.setupAlarms(alarmData)
    }

    listeningWormhole.activateSessionListening()
    communicationConfigured = true
  }
}
