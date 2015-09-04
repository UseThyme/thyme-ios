import WatchKit
import Foundation

class GlanceController: WKInterfaceController {

  @IBOutlet weak var activeGroup: WKInterfaceGroup!
  @IBOutlet weak var inactiveGroup: WKInterfaceGroup!

  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var timeLabel: WKInterfaceLabel!
  @IBOutlet weak var infoLabel: WKInterfaceLabel!

  @IBOutlet weak var happyHerbie: WKInterfaceGroup!
  @IBOutlet weak var startLabel: WKInterfaceLabel!

  var communicator: Communicator!

  // MARK: - Lifecycle

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    communicator = Communicator(self)

    infoLabel.setText(NSLocalizedString("Yum! That smells amazing!", comment: ""))
    startLabel.setText(NSLocalizedString("Start cooking", comment: ""))
    setupInterface()
  }

  override func willActivate() {
    super.willActivate()
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  // MARK: - UI

  func setupInterface(alarmData: [AnyObject] = []) {
    var closestAlarm: Alarm?

    for (_, alarmInfo) in alarmData.enumerate() {
      if let alarmInfo = alarmInfo as? [String: AnyObject],
        title = alarmInfo["title"] as? String,
        firedDate = alarmInfo["firedDate"] as? NSDate,
        numberOfSeconds = alarmInfo["numberOfSeconds"] as? NSNumber {
          let alarm = Alarm(
            title: title,
            firedDate: firedDate,
            numberOfSeconds: numberOfSeconds)

          if alarm.secondsLeft < closestAlarm?.secondsLeft || closestAlarm == nil {
            closestAlarm = alarm
          }
      }
    }

    activeGroup.setHidden(closestAlarm == nil)
    inactiveGroup.setHidden(closestAlarm != nil)

    if let alarm = closestAlarm {
      happyHerbie.setBackgroundImageNamed(nil)
      titleLabel.setText(alarm.title.uppercaseString)

      var timeText = ""

      if alarm.hours > 0 {
        timeText = alarm.shortText
      } else if alarm.minutes > 0 {
        timeText = "\(alarm.minutes) "
          + NSLocalizedString("minutes", comment: "").capitalizedString
      } else if alarm.seconds > 0 {
        timeText = "\(alarm.seconds) "
          + NSLocalizedString("seconds", comment: "").capitalizedString
      }

      timeLabel.setText(timeText)
    } else {
      happyHerbie.setBackgroundImageNamed(ImageList.Glance.happyHerbieSequence)
      happyHerbie.startAnimatingWithImagesInRange(
        NSRange(location: 0, length: 24),
        duration: 1, repeatCount: Int.max)
    }
  }
}

extension GlanceController: CommunicatorDelegate {

  func communicatorDidReceiveApplicationContext(context: [String : AnyObject]) {
    var data = [AnyObject]()

    if let alarmData = context["alarms"] as? [AnyObject] {
      data = alarmData
    } else {
      print("Error with fetching of application context from the parent app")
    }

    setupInterface(data)
  }
}
