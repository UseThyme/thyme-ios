import WatchKit
import Foundation
import WatchConnectivity

class GlanceController: WKInterfaceController {

  @IBOutlet weak var activeGroup: WKInterfaceGroup!
  @IBOutlet weak var inactiveGroup: WKInterfaceGroup!
  @IBOutlet var herbieImage: WKInterfaceImage!
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var timeLabel: WKInterfaceLabel!
  @IBOutlet weak var infoLabel: WKInterfaceLabel!
  @IBOutlet weak var startLabel: WKInterfaceLabel!

  var session : WCSession!

  // MARK: - Lifecycle

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    infoLabel.setText(NSLocalizedString("Yum! That smells amazing!", comment: ""))
    startLabel.setText(NSLocalizedString("Start cooking", comment: ""))
    herbieImage.stopAnimating()
    setupInterface()
  }

  override func willActivate() {
    super.willActivate()

    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }

    sendMessage(Message(.GetAlarms))
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
      herbieImage.stopAnimating()
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
      herbieImage.startAnimating()
    }
  }

  // MARK: - Communication

  func sendMessage(message: Message) {
    session.sendMessage(message.data,
      replyHandler: { [weak self] response in
        if let weakSelf = self, alarmData = response["alarms"] as? [AnyObject] {
          weakSelf.setupInterface(alarmData)
        }
      }, errorHandler: { error in
        print(error)
    })
  }
}

// MARK: - WCSessionDelegate

extension GlanceController: WCSessionDelegate {

  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    var data = [AnyObject]()

    if let alarmData = applicationContext["alarms"] as? [AnyObject] {
      data = alarmData
    } else {
      print("Error with fetching of application context from the parent app")
    }

    setupInterface(data)
  }
}
