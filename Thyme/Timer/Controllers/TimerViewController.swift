import UIKit

protocol TimerControllerDelegate {
    func dismissedTimerController(_ timerController: TimerViewController!)
}

class TimerViewController: ViewController {
    enum TimerDirection {
        case forward, backward
    }

    var alarm: Alarm
    var timer: Timer?
    var startRect: CGRect = CGRect.null
    var finalRect: CGRect = CGRect.null
    var delegate: TimerControllerDelegate?
    override var theme: Themable? {
        didSet {
            if let theme = theme {
                gradientLayer.colors = theme.colors
                gradientLayer.locations = theme.locations as [NSNumber]
                timerControl.theme = theme
            }
        }
    }

    lazy var timerControl: TimerControl = {
        var sideMargin: CGFloat = Screen.isPad ? 140 : 0
        var topMargin: CGFloat = 0
        let width = Screen.width - 2 * sideMargin

        if Screen.isPad {
            topMargin = 140
        } else {
            if Screen.height == 480 {
                topMargin = 30
            } else if Screen.height == 568 {
                topMargin = 60
            } else if Screen.height == 667 {
                topMargin = 70
            } else if Screen.height == 736 {
                topMargin = 78
            } else {
                topMargin = ((Screen.height - width) / 2) - 50
            }
        }

        let frame = CGRect(x: sideMargin, y: topMargin, width: width, height: width)
        let timerControl = TimerControl(frame: frame, completedMode: true)

        timerControl.active = true
        timerControl.backgroundColor = UIColor.clear

        return timerControl
    }()

    lazy var fingerView: UIImageView = {
        let image = UIImage(named: "fingerImage")!
        let x: CGFloat = self.timerControl.frame.maxX / 2 - image.size.width / 2
        let y: CGFloat = self.timerControl.frame.minY + image.size.height
        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height

        var xOffset: CGFloat = 61
        var yOffset: CGFloat = 18

        if Screen.height == 667 {
            xOffset = 70
            yOffset = 35
        } else if Screen.height == 736 {
            xOffset = 80
            yOffset = 45
        }

        self.startRect = CGRect(x: x, y: y, width: width, height: height)
        self.finalRect = CGRect(x: x + xOffset, y: y + yOffset, width: width, height: height)

        let imageView = UIImageView(image: image)
        imageView.frame = self.startRect
        imageView.isHidden = true

        return imageView
    }()

    lazy var kitchenButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageName = self.alarm.type == .oven
            ? "mini-oven"
            : "\(self.alarm.indexPath!.row)-\(self.alarm.indexPath!.section)"
        let image = UIImage(named: imageName)!

        var topMargin: CGFloat = image.size.height
        var x: CGFloat = Screen.width / 2 - image.size.width / 2
        var y: CGFloat = Screen.height / 2 - image.size.height / 2
        var width: CGFloat = image.size.width
        var height: CGFloat = image.size.height

        if Screen.isPad {
            y = Screen.height - 330
        } else {
            if Screen.height == 480 {
                y = Screen.height - 110
            } else if Screen.height == 568 {
                y = Screen.height - 140
            } else if Screen.height == 667 {
                y = Screen.height - 164
            } else if Screen.height == 736 {
                y = Screen.height - 181
            }
        }

        button.addTarget(self, action: #selector(TimerViewController.kitchenButtonPressed(_:)),
                         for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        button.imageEdgeInsets = UIEdgeInsets.zero

        let states: [UIControl.State] = [.highlighted, .selected]
        for state in states {
            button.setBackgroundImage(image, for: state)
        }
        button.alpha = UIAccessibility.isReduceMotionEnabled ? 1.0 : 0.0

        return button
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: "closeButton"), for: .normal)
        button.addTarget(self, action: #selector(kitchenButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    init(alarm: Alarm) {
        self.alarm = alarm

        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in [timerControl, kitchenButton, fingerView, closeButton] as [Any] { view.addSubview(subview as! UIView) }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerViewController.alarmsDidUpdate(_:)),
                                               name: NSNotification.Name(rawValue: AlarmCenter.Notifications.AlarmsDidUpdate),
                                               object: nil)
        
        NSLayoutConstraint.activate([
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
            ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        timerControl.alarm = alarm
        timerControl.alarmID = alarm.alarmID
        refreshTimerForCurrentAlarm()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerViewController.kitchenButtonPressed(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        if UIAccessibility.isReduceMotionEnabled {
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !UIAccessibility.isReduceMotionEnabled {
            view.layer.insertSublayer(gradientLayer, at: 0)
        }

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "presentedClue") == false {
            fingerView.isHidden = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            startTimerGoing(.forward)
            UIView.animate(withDuration: 0.8, animations: {
                self.fingerView.frame = self.finalRect
            }, completion: { _ in
                self.stopTimer()
                self.startTimerGoing(.backward)
                UIView.animate(withDuration: 0.8, animations: {
                    self.fingerView.frame = self.startRect
                }, completion: { _ in
                    self.fingerView.isHidden = true
                    self.stopTimer()
                })
                UIApplication.shared.endIgnoringInteractionEvents()
                defaults.set(true, forKey: "presentedClue")
                defaults.synchronize()
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !UIAccessibility.isReduceMotionEnabled {
            gradientLayer.removeFromSuperlayer()
        }
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateForward(_ timer: Timer) {
        if timerControl.minutes < 7 { timerControl.minutes += 1 }
    }

    @objc func updateBackward(_ timer: Timer) {
        if timerControl.minutes > 0 { timerControl.minutes -= 1 }
    }

    func startTimerGoing(_ direction: TimerDirection) {
        if timer == nil {
            switch direction {
            case .forward:
                timer = Timer(timeInterval: 0.1,
                              target: self,
                              selector: #selector(TimerViewController.updateForward(_:)),
                              userInfo: nil,
                              repeats: true)
                break
            case .backward:
                timer = Timer(timeInterval: 0.1,
                              target: self,
                              selector: #selector(TimerViewController.updateBackward(_:)),
                              userInfo: nil,
                              repeats: true)
                break
            }

            RunLoop.current.add(timer!,
                                forMode: RunLoop.Mode.common)
        }
    }

    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }

    func refreshTimerForCurrentAlarm() {
        if let existingNotification = AlarmCenter.getNotification(alarm.alarmID!) {
            refreshTimerForNotification(existingNotification)
        } else {
            timerControl.seconds = 0
            timerControl.minutes = 0
            timerControl.hours = 0
        }
    }

    func refreshTimerForNotification(_ notification: UILocalNotification) {
        if let userinfo = notification.userInfo,
            let firedDate = userinfo[Alarm.fireDateKey] as? Date,
            let numberOfSeconds = userinfo[Alarm.fireIntervalKey] as? NSNumber {
            let secondsPassed: TimeInterval = Date().timeIntervalSince(firedDate)
            let secondsLeft = TimeInterval(numberOfSeconds.intValue) - secondsPassed
            let currentSecond = secondsLeft.truncatingRemainder(dividingBy: 60)
            var minutesLeft = floor(secondsLeft / 60)
            let hoursLeft = floor(minutesLeft / 60)

            if hoursLeft > 0 {
                minutesLeft = minutesLeft - (hoursLeft * 60)
            }

            timerControl.title = alarm.timerTitle
            timerControl.seconds = Int(currentSecond)
            timerControl.minutes = Int(minutesLeft)
            timerControl.hours = Int(hoursLeft)
            timerControl.touchesAreActive = true

            timerControl.startTimer()
        }
    }

    @objc func kitchenButtonPressed(_ button: UIButton) {
        delegate?.dismissedTimerController(self)
        dismiss(animated: true, completion: nil)
        timerControl.touchesAreActive = false
    }

    @objc func alarmsDidUpdate(_ notification: Notification) {
        if notification.name.rawValue == AlarmCenter.Notifications.AlarmsDidUpdate {
            DispatchQueue.main.async {
                self.timerControl.stopTimer()
                self.refreshTimerForCurrentAlarm()
            }
        }
    }
}
