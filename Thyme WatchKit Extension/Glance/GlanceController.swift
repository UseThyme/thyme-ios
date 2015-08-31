import WatchKit
import Foundation

class GlanceController: WKInterfaceController {

  struct Request {
    static let getAlarms = "getAlarms"
  }

  @IBOutlet weak var activeGroup: WKInterfaceGroup!
  @IBOutlet weak var inactiveGroup: WKInterfaceGroup!

  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var timeLabel: WKInterfaceLabel!
  @IBOutlet weak var infoLabel: WKInterfaceLabel!

  @IBOutlet weak var happyHerbie: WKInterfaceGroup!
  @IBOutlet weak var startLabel: WKInterfaceLabel!

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    infoLabel.setText(NSLocalizedString("Yum! That smells amazing!", comment: ""))
    startLabel.setText(NSLocalizedString("Start cooking", comment: ""))
  }

  override func willActivate() {
    super.willActivate()
    request(Request.getAlarms)
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - Communication

  func request(name: String) {
    WKInterfaceController.openParentApplication(["request": name]) {
      [unowned self] response, error in
      if let response = response,
        alarmData = response["alarms"] as? [AnyObject] {
          self.setupInterface(alarmData)
      } else {
        println("Error with fetching of alarms from the parent app")
      }
    }
  }

  func setupInterface(alarmData: [AnyObject]) {
    var closestAlarm: Alarm?

    for (index, alarmInfo) in enumerate(alarmData) {
      if let alarmInfo = alarmInfo as? [String: AnyObject] {
        let alarm = Alarm(
          firedDate: alarmInfo["firedDate"] as? NSDate,
          numberOfSeconds: alarmInfo["numberOfSeconds"] as? NSNumber)

        if alarm.secondsLeft < closestAlarm?.secondsLeft || index == 0 {
          closestAlarm = alarm
        }
      }
    }

    activeGroup.setHidden(closestAlarm == nil)
    inactiveGroup.setHidden(closestAlarm != nil)

    if let alarm = closestAlarm {
      happyHerbie.setBackgroundImageNamed(nil)
      titleLabel.setText(alarm.title)

      var timeText = ""
      if alarm.hours > 0 {
        timeText = alarm.shortText
      } else {
        if alarm.minutes > 0 {
          timeText = "\(alarm.minutes) "
            + NSLocalizedString("minutes", comment: "").capitalizedString
        } else if alarm.seconds > 0 {
          timeText = "\(alarm.seconds) "
            + NSLocalizedString("seconds", comment: "").capitalizedString
        }
      }
    } else {
      happyHerbie.setBackgroundImageNamed(ImageList.Glance.happyHerbieSequence)
      happyHerbie.startAnimatingWithImagesInRange(
        NSRange(location: 0, length: 24),
        duration: 5, repeatCount: Int.max)
    }
  }
}
