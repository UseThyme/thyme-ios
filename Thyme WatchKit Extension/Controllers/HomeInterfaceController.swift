import Foundation
import WatchKit

class HomeInterfaceController: WKInterfaceController, Communicable {
    @IBOutlet var mainGroup: WKInterfaceGroup!

    @IBOutlet var lostConnectionGroup: WKInterfaceGroup!
    @IBOutlet var lostConnectionImage: WKInterfaceImage!
    @IBOutlet var retryButton: WKInterfaceButton!

    @IBOutlet var topLeftMinutesGroup: WKInterfaceGroup!
    @IBOutlet var topRightMinutesGroup: WKInterfaceGroup!
    @IBOutlet var bottomLeftMinutesGroup: WKInterfaceGroup!
    @IBOutlet var bottomRightMinutesGroup: WKInterfaceGroup!
    @IBOutlet var ovenMinutesGroup: WKInterfaceGroup!

    @IBOutlet var topLeftSecondsGroup: WKInterfaceGroup!
    @IBOutlet var topRightSecondsGroup: WKInterfaceGroup!
    @IBOutlet var bottomLeftSecondsGroup: WKInterfaceGroup!
    @IBOutlet var bottomRightSecondsGroup: WKInterfaceGroup!
    @IBOutlet var ovenSecondsGroup: WKInterfaceGroup!

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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        retryButton.setTitle(NSLocalizedString("Try again", comment: ""))

        minutesGroups = [
            topLeftMinutesGroup, topRightMinutesGroup,
            bottomLeftMinutesGroup, bottomRightMinutesGroup, ovenMinutesGroup,
        ]
        secondsGroups = [
            topLeftSecondsGroup, topRightSecondsGroup,
            bottomLeftSecondsGroup, bottomRightSecondsGroup, ovenSecondsGroup,
        ]
        labels = [
            topLeftLabel, topRightLabel,
            bottomLeftLabel, bottomRightLabel, ovenLabel,
        ]

        configureCommunication()
    }

    override func willActivate() {
        super.willActivate()

        showLostConnection(false)
        wormhole.passMessageObject(nil, identifier: Routes.App.alarms)
    }

    // MARK: - Local notifications

    override func handleAction(withIdentifier identifier: String?, for localNotification: UILocalNotification) {
        if let alarmID = localNotification.userInfo?["HYPAlarmID"] as? String, let actionID = identifier {
            var parameters = [String: AnyObject]()
            var identifier = Routes.App.updateAlarm

            switch actionID {
            case "AddThreeMinutes":
                parameters["amount"] = 3 * 60 as AnyObject
            case "AddFiveMinutes":
                parameters["amount"] = 5 * 60 as AnyObject
            default:
                identifier = Routes.App.cancelAlarm
                break
            }

            parameters["index"] = Alarm.indexFromString(alarmID) as AnyObject
            wormhole.passMessageObject(parameters as NSCoding, identifier: identifier)
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
        WKInterfaceDevice.current().play(.stop)
        wormhole.passMessageObject(nil, identifier: Routes.App.cancelAlarms)
    }

    @IBAction func retryButtonTapped() {
        wormhole.passMessageObject(nil, identifier: Routes.App.alarms)
    }

    // MARK: - UI

    func presentController(_ index: Int, title: String) {
        let context = TimerContext(index: index, title: title)
        pushController(withName: "TimerController", context: context)
    }

    func updatePlate(_ index: Int, alarm: Alarm) {
        var text = ""

        if alarm.active {
            text = alarm.shortText

            minutesGroups[index].setBackgroundImageNamed(ImageList.Home.minuteSequence)
            minutesGroups[index].startAnimatingWithImages(
                in: NSRange(location: alarm.minutes, length: 1),
                duration: 0, repeatCount: 1)

            secondsGroups[index].setBackgroundImageNamed(ImageList.Home.secondSequence)
            secondsGroups[index].startAnimatingWithImages(
                in: NSRange(location: 59 - alarm.seconds, length: 1),
                duration: 0, repeatCount: 1)
        } else {
            minutesGroups[index].setBackgroundImageNamed(nil)
            secondsGroups[index].setBackgroundImageNamed(nil)
        }

        labels[index].setText(text)
    }

    func clearAllPlates() {
        for index in 0 ..< minutesGroups.count {
            minutesGroups[index].setBackgroundImageNamed(nil)
            secondsGroups[index].setBackgroundImageNamed(nil)
            labels[index].setText("")
        }
    }

    func showLostConnection(_ show: Bool) {
        mainGroup.setHidden(show)
        lostConnectionGroup.setHidden(!show)

        if show {
            alarmTimer?.stop()
            clearAllPlates()
        }
    }

    // MARK: - Alarms

    func setupAlarms(_ alarmData: [AnyObject]) {
        var alarms = [Alarm]()

        for (index, alarmInfo) in alarmData.enumerated() {
            if index == minutesGroups.count {
                break
            }

            let alarm: Alarm

            if let alarmInfo = alarmInfo as? [String: AnyObject] {
                alarm = Alarm(
                    firedDate: alarmInfo["firedDate"] as? Date,
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
    func alarmTimerDidTick(_ alarmTimer: AlarmTimer, alarms: [Alarm]) {
        for (index, alarm) in alarms.enumerated() {
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

        listeningWormhole.listenForMessage(withIdentifier: Routes.Watch.home) {
            [weak self] (messageObject) -> Void in

            guard let weakSelf = self, let message = messageObject as? [String: AnyObject],
                let alarmData = message["alarms"] as? [AnyObject] else {
                self?.showLostConnection(true)
                return
            }

            weakSelf.alarmTimer?.stop()
            weakSelf.showLostConnection(false)
            weakSelf.setupAlarms(alarmData)
        }

        listeningWormhole.activateListening()
        communicationConfigured = true
    }
}
