import Foundation
import WatchKit

class TimerInterfaceController: WKInterfaceController, Communicable {
    enum State {
        case active, inactive, error, unknown
    }

    // MARK: - Root interface views

    @IBOutlet var activeGroup: WKInterfaceGroup!
    @IBOutlet var inactiveGroup: WKInterfaceGroup!
    @IBOutlet var lostConnectionImage: WKInterfaceImage!
    @IBOutlet var button: WKInterfaceButton!

    // MARK: - Active group views

    @IBOutlet var minutesGroup: WKInterfaceGroup!
    @IBOutlet var secondsGroup: WKInterfaceGroup!
    @IBOutlet var minutesTextLabel: WKInterfaceLabel!
    @IBOutlet var hoursTextLabel: WKInterfaceLabel!
    @IBOutlet var minutesLabel: WKInterfaceLabel!

    // MARK: - Inactive group views

    @IBOutlet var hourPicker: WKInterfacePicker!
    @IBOutlet var hourLabel: WKInterfaceLabel!
    @IBOutlet var hourOutlineGroup: WKInterfaceGroup!

    @IBOutlet var minutePicker: WKInterfacePicker!
    @IBOutlet var minuteLabel: WKInterfaceLabel!
    @IBOutlet var minuteOutlineGroup: WKInterfaceGroup!

    // MARK: - Class variables

    var alarmTimer: AlarmTimer?
    var index = 0
    var pickerHours = 0
    var pickerMinutes = 0

    var wormhole: MMWormhole!
    var listeningWormhole: MMWormholeSession!
    var communicationConfigured = false

    var state: State = .unknown {
        didSet {
            button.setHidden(state == .unknown)

            switch state {
            case .active:
                lostConnectionImage.setHidden(true)
                inactiveGroup.setHidden(true)
                activeGroup.setHidden(false)

                button.setTitle(NSLocalizedString("End timer", comment: ""))
                button.setEnabled(true)
            case .inactive:
                lostConnectionImage.setHidden(true)
                activeGroup.setHidden(true)
                inactiveGroup.setHidden(false)

                button.setTitle(NSLocalizedString("Start timer", comment: ""))
                button.setEnabled(pickerHours > 0 || pickerMinutes > 0)

                minutePicker.focus()
            case .error:
                activeGroup.setHidden(true)
                inactiveGroup.setHidden(true)
                lostConnectionImage.setHidden(false)

                button.setTitle(NSLocalizedString("Try again", comment: ""))
                button.setEnabled(true)
            case .unknown:
                activeGroup.setHidden(true)
                inactiveGroup.setHidden(true)
                lostConnectionImage.setHidden(true)
            }
        }
    }

    // MARK: - Lifecycle

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let context = context as? TimerContext {
            index = context.index
            setTitle(context.title)
            hourLabel.setText(NSLocalizedString("hr", comment: "").uppercased())
            minuteLabel.setText(NSLocalizedString("min", comment: "").uppercased())
        }

        configureCommunication()
    }

    override func willActivate() {
        super.willActivate()

        alarmTimer?.stop()
        setupPickers()
        sendMessage(Routes.App.alarm)
    }

    override func didDeactivate() {
        super.didDeactivate()
        alarmTimer?.stop()
        alarmTimer = nil
        state = .unknown
    }

    // MARK: - Actions

    @IBAction func hourPickerChanged(_ value: Int) {
        pickerHours = value
        inactiveGroup.startAnimatingWithImages(
            in: NSRange(location: value, length: 1),
            duration: 0, repeatCount: 1)
        button.setEnabled(pickerHours > 0 || pickerMinutes > 0)
    }

    @IBAction func minutePickerChanged(_ value: Int) {
        pickerMinutes = value
        inactiveGroup.startAnimatingWithImages(
            in: NSRange(location: value, length: 1),
            duration: 0, repeatCount: 1)
        button.setEnabled(pickerHours > 0 || pickerMinutes > 0)
    }

    @IBAction func buttonDidTap() {
        if state == .active {
            WKInterfaceDevice.current().play(.stop)
            sendMessage(Routes.App.cancelAlarm)
        } else if state == .inactive {
            WKInterfaceDevice.current().play(.start)
            let amount = pickerHours * 60 * 60 + pickerMinutes * 60
            pickerHours = 0
            pickerMinutes = 0
            sendMessage(Routes.App.updateAlarm, parameters: ["amount": amount as AnyObject])
        } else {
            sendMessage(Routes.App.alarm)
        }

        button.setEnabled(false)
        setupPickers()
    }

    @IBAction func menu3MinutesButtonDidTap() {
        WKInterfaceDevice.current().play(.start)
        sendMessage(Routes.App.updateAlarm, parameters: ["amount": 3 * 60 as AnyObject])
    }

    @IBAction func menu5MinutesButtonDidTap() {
        WKInterfaceDevice.current().play(.start)
        sendMessage(Routes.App.updateAlarm, parameters: ["amount": 5 * 60 as AnyObject])
    }

    // MARK: - Communication

    func sendMessage(_ identifier: String, parameters: [String: AnyObject]? = nil) {
        var message = parameters ?? [:]
        message["index"] = index as AnyObject

        wormhole.passMessageObject(message as NSCoding,
                                   identifier: identifier)
    }

    // MARK: - Pickers

    override func pickerDidFocus(_ picker: WKInterfacePicker) {
        var location: Int

        if picker == minutePicker {
            hourOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutline)
            minuteOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutlineFocused)
            inactiveGroup.setBackgroundImageNamed(ImageList.Timer.pickerMinutes)

            location = pickerMinutes
        } else {
            minuteOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutline)
            hourOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutlineFocused)
            inactiveGroup.setBackgroundImageNamed(ImageList.Timer.pickerHours)

            location = pickerHours
        }

        inactiveGroup.startAnimatingWithImages(
            in: NSRange(location: location, length: 1),
            duration: 0, repeatCount: 1)
    }

    override func pickerDidSettle(_ picker: WKInterfacePicker) {
        WKInterfaceDevice.current().play(.click)
    }

    func setupPickers() {
        let hourPickerItems: [WKPickerItem] = Array(0 ... 12).map {
            let pickerItem = WKPickerItem()
            pickerItem.title = "\($0)"

            return pickerItem
        }

        hourPicker.setItems(hourPickerItems)
        hourPicker.setSelectedItemIndex(pickerHours)

        let minutePickerItems: [WKPickerItem] = Array(0 ... 59).map {
            let pickerItem = WKPickerItem()
            pickerItem.title = "\($0)"

            return pickerItem
        }

        minutePicker.setItems(minutePickerItems)
        minutePicker.setSelectedItemIndex(pickerMinutes)
    }

    // MARK: - Plate

    func updatePlate(_ alarm: Alarm) {
        var hoursText = ""

        if alarm.active {
            if alarm.hours > 0 {
                hoursText = "\(alarm.hours) " + NSLocalizedString("hour", comment: "")
            }

            secondsGroup.setBackgroundImageNamed(ImageList.Timer.secondSequence)
            secondsGroup.startAnimatingWithImages(
                in: NSRange(location: 59 - alarm.seconds, length: 1),
                duration: 0, repeatCount: 1)
        } else {
            secondsGroup.setBackgroundImageNamed(nil)
        }

        minutesGroup.setBackgroundImageNamed(ImageList.Timer.minuteSequence)
        minutesGroup.startAnimatingWithImages(
            in: NSRange(location: alarm.minutes, length: 1),
            duration: 0, repeatCount: 1)

        hoursTextLabel.setText(hoursText.uppercased())

        minutesLabel.setText(alarm.minutes > 0
            ? "\(alarm.minutes)"
            : "\(alarm.seconds)")
        minutesTextLabel.setText(alarm.minutes > 0
            ? NSLocalizedString("minutes", comment: "").uppercased()
            : NSLocalizedString("seconds", comment: "").uppercased())
    }

    // MARK: - Alarms

    func setupAlarm(_ alarmInfo: [String: AnyObject]) {
        let alarm = Alarm(
            firedDate: alarmInfo["firedDate"] as? Date,
            numberOfSeconds: alarmInfo["numberOfSeconds"] as? NSNumber)

        state = alarm.active ? .active : .inactive
        updatePlate(alarm)

        if alarm.active {
            alarmTimer = AlarmTimer(alarms: [alarm], delegate: self)
            alarmTimer?.start()
        }
    }
}

// MARK: - AlarmTimerDelegate

extension TimerInterfaceController: AlarmTimerDelegate {
    func alarmTimerDidTick(_ alarmTimer: AlarmTimer, alarms: [Alarm]) {
        if let alarm = alarms.first {
            updatePlate(alarm)
            if !alarm.active {
                alarmTimer.stop()
                sendMessage(Routes.App.alarm)
            }
        }
    }
}

// MARK: - Communicable

extension TimerInterfaceController {
    func configureCommunication() {
        if communicationConfigured { return }

        state = .unknown
        configureSession()

        listeningWormhole.listenForMessage(withIdentifier: Routes.Watch.timer) {
            [weak self] messageObject in

            guard let weakSelf = self, let message = messageObject as? [String: AnyObject],
                let data = message["alarms"] as? [AnyObject],
                let alarmData = data[weakSelf.index] as? [String: AnyObject], data.count > weakSelf.index
            else {
                self?.state = .inactive
                return
            }

            weakSelf.alarmTimer?.stop()
            weakSelf.setupAlarm(alarmData)
        }

        listeningWormhole.activateListening()
        communicationConfigured = true
    }
}
