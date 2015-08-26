import WatchKit
import Foundation

class HomeInterfaceController: WKInterfaceController {

  @IBOutlet weak var plate1MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var plate2MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var plate3MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var plate4MinutesGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenMinutesGroup: WKInterfaceGroup!

  @IBOutlet weak var plate1SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var plate2SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var plate3SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var plate4SecondsGroup: WKInterfaceGroup!
  @IBOutlet weak var ovenSecondsGroup: WKInterfaceGroup!

  @IBOutlet weak var plate1Button: WKInterfaceButton!
  @IBOutlet weak var plate2Button: WKInterfaceButton!
  @IBOutlet weak var plate3Button: WKInterfaceButton!
  @IBOutlet weak var plate4Button: WKInterfaceButton!
  @IBOutlet weak var ovenButton: WKInterfaceButton!

  var plateMinutesGroups = [WKInterfaceGroup]()
  var plateSecondsGroups = [WKInterfaceGroup]()
  var plateButtons = [WKInterfaceButton]()

  var alarmTimer: AlarmTimer?

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    plateMinutesGroups = [plate1MinutesGroup, plate2MinutesGroup,
      plate3MinutesGroup, plate4MinutesGroup, ovenMinutesGroup]
    plateSecondsGroups = [plate1SecondsGroup, plate2SecondsGroup,
      plate3SecondsGroup, plate4SecondsGroup, ovenSecondsGroup]
    plateButtons = [plate1Button, plate2Button,
      plate3Button, plate4Button, ovenButton]
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
    WKInterfaceController.openParentApplication(["request": "getAlarms"]) {
      [unowned self] response, error in
      if let response = response,
        alarmData = response["alarms"] as? [AnyObject] {
          self.setupAlarms(alarmData)
      } else {
        println("Error with fetching of alarms from the parent app")
      }
    }
  }

  // MARK: - UI

  func updatePlate(index: Int, alarm: Alarm) {
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

      plateMinutesGroups[index].setBackgroundImageNamed(ImageList.Plate.minuteSequence)
      plateMinutesGroups[index].startAnimatingWithImagesInRange(
        NSRange(location: alarm.minutes, length: 1),
        duration: 0, repeatCount: 1)

      plateSecondsGroups[index].setBackgroundImageNamed(ImageList.Plate.secondSequence)
      plateSecondsGroups[index].startAnimatingWithImagesInRange(
        NSRange(location: 59 - alarm.seconds, length: 1),
        duration: 0, repeatCount: 1)
    } else {
      plateMinutesGroups[index].setBackgroundImageNamed(index == 4
        ? nil
        : ImageList.Main.plateBackground)
      plateSecondsGroups[index].setBackgroundImageNamed(nil)
    }

    self.plateButtons[index].setTitle(text)
  }

  // MARK: - Alarms

  func setupAlarms(alarmData: [AnyObject]) {
    var alarms = [Alarm]()

    for (index, alarmInfo) in enumerate(alarmData) {
      if index == self.plateMinutesGroups.count {
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
    var stopTimer = true

    for (index, alarm) in enumerate(alarms) {
      updatePlate(index, alarm: alarm)
    }

    if alarms.filter({ $0.active }).count == 0 {
      alarmTimer.stop()
    }
  }
}
