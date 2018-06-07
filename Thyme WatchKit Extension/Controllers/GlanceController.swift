import Foundation
import WatchKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class GlanceController: WKInterfaceController, Communicable {
    @IBOutlet var activeGroup: WKInterfaceGroup!
    @IBOutlet var inactiveGroup: WKInterfaceGroup!
    @IBOutlet var lostConnectionImage: WKInterfaceImage!
    @IBOutlet var herbieImage: WKInterfaceImage!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var infoLabel: WKInterfaceLabel!
    @IBOutlet var startLabel: WKInterfaceLabel!

    var wormhole: MMWormhole!
    var listeningWormhole: MMWormholeSession!
    var communicationConfigured = false

    // MARK: - Lifecycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        infoLabel.setText(NSLocalizedString("Yum! That smells amazing!", comment: ""))
        startLabel.setText(NSLocalizedString("Start cooking", comment: ""))
        herbieImage.stopAnimating()

        configureCommunication()
    }

    override func willActivate() {
        super.willActivate()

        lostConnectionImage.setHidden(true)
        wormhole.passMessageObject(nil, identifier: Routes.App.alarms)
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    // MARK: - UI

    func setupInterface(_ alarmData: [AnyObject] = []) {
        var closestAlarm: Alarm?

        for (_, alarmInfo) in alarmData.enumerated() {
            if let alarmInfo = alarmInfo as? [String: AnyObject],
                let title = alarmInfo["title"] as? String,
                let firedDate = alarmInfo["firedDate"] as? Date,
                let numberOfSeconds = alarmInfo["numberOfSeconds"] as? NSNumber {
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
            titleLabel.setText(alarm.title.uppercased())

            var timeText = ""

            if alarm.hours > 0 {
                timeText = alarm.shortText
            } else if alarm.minutes > 0 {
                timeText = "\(alarm.minutes) "
                    + NSLocalizedString("minutes", comment: "").capitalized
            } else if alarm.seconds > 0 {
                timeText = "\(alarm.seconds) "
                    + NSLocalizedString("seconds", comment: "").capitalized
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

        listeningWormhole.listenForMessage(withIdentifier: Routes.Watch.glance) {
            [weak self] (messageObject) -> Void in

            guard let weakSelf = self, let message = messageObject as? [String: AnyObject],
                let alarmData = message["alarms"] as? [AnyObject] else { return }

            weakSelf.setupInterface(alarmData)
        }

        listeningWormhole.activateListening()
        communicationConfigured = true
    }
}
