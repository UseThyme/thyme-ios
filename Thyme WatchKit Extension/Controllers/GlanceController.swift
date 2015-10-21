import WatchKit
import Foundation

class GlanceController: WKInterfaceController, Communicable {

  @IBOutlet weak var activeGroup: WKInterfaceGroup!
  @IBOutlet weak var inactiveGroup: WKInterfaceGroup!
  @IBOutlet var lostConnectionImage: WKInterfaceImage!
  @IBOutlet var herbieImage: WKInterfaceImage!
  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var timeLabel: WKInterfaceLabel!
  @IBOutlet weak var infoLabel: WKInterfaceLabel!
  @IBOutlet weak var startLabel: WKInterfaceLabel!

  var wormhole: MMWormhole!
  var listeningWormhole: MMWormholeSession!
  var communicationConfigured = false

  // MARK: - Lifecycle

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    infoLabel.setText(NSLocalizedString("Yum! That smells amazing!", comment: ""))
    startLabel.setText(NSLocalizedString("Start cooking", comment: ""))
    herbieImage.stopAnimating()

    configureCommunication()
  }

  override func willActivate() {
    super.willActivate()

    lostConnectionImage.setHidden(true)
    wormhole.passMessageObject(nil, identifier: Message.Outbox.FetchAlarms)
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

    lostConnectionImage.setHidden(true)
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
}

// MARK: - Communicable

extension GlanceController {

  func configureCommunication() {
    if communicationConfigured { return }

    configureSession()

    listeningWormhole.listenForMessageWithIdentifier(Message.Inbox.UpdateAlarms) {
      [weak self] (messageObject) -> Void in

      guard let weakSelf = self, message = messageObject as? [String: AnyObject],
        alarmData = message["alarms"] as? [AnyObject] else { return }

      weakSelf.setupInterface(alarmData)
    }

    listeningWormhole.activateSessionListening()
    
    communicationConfigured = true
  }
}
