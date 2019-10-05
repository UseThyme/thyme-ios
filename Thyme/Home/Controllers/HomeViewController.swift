import UIKit

class HomeViewController: ViewController, ContentSizeChangable {
    let plateCellIdentifier = "HYPPlateCellIdentifier"

    var deleteTimersMessageIsBeingDisplayed: Bool = false
    var cellRect: CGRect?

    override var theme: Themable? {
        willSet(newTheme) {
            gradientLayer.colors = newTheme?.colors
            gradientLayer.locations = newTheme?.locations as [NSNumber]?
            titleLabel.textColor = newTheme?.labelColor
            subtitleLabel.textColor = newTheme?.labelColor
            plateCollectionView.setNeedsDisplay()
            ovenCollectionView.setNeedsDisplay()
        }
    }

    lazy var stoveView: UIView = { [unowned self] in
        var frame = self.view.bounds
        frame.origin.y = self.topMargin
        let view = UIView(frame: frame)

        return view
    }()

    var maxMinutesLeft: NSNumber? {
        didSet(newValue) {
            if let maxMinutesLeft = maxMinutesLeft {
                titleLabel.text = "YOUR DISH WILL BE DONE".localized
                if maxMinutesLeft == 0.0 {
                    subtitleLabel.text = "IN LESS THAN A MINUTE".localized
                } else {
                    subtitleLabel.text = Alarm.subtitleForHomescreenUsingMinutes(maxMinutesLeft)
                }
            } else {
                titleLabel.text = Alarm.titleForHomescreen()
                subtitleLabel.text = Alarm.subtitleForHomescreen()
            }
        }
    }

    lazy var topMargin: CGFloat = {
        let margin: CGFloat

        if Screen.isPad {
            margin = 70
        } else {
            if Screen.height == 480 {
                margin = 42
            } else if Screen.height == 568 {
                margin = 50
            } else if Screen.height == 667 {
                margin = 64
            } else if Screen.height == 896 {
                margin = 75
            } else {
                margin = 75
            }
        }

        return margin
    }()

    lazy var plateFactor: CGFloat = {
        let factor: CGFloat = Screen.isPad ? 0.36 : 0.32
        return factor
    }()

    lazy var ovenFactor: CGFloat = {
        let factor: CGFloat = Screen.isPad ? 0.29 : 0.25
        return factor
    }()

    lazy var alarms: [[Alarm]] = {
        var alarms = [[Alarm]]()

        for i in 0 ..< 2 { alarms.append([Alarm(), Alarm()]) }

        return alarms
    }()

    lazy var ovenAlarms: [[Alarm]] = {
        var alarms = [[Alarm]]()

        for i in 0 ..< 1 { alarms.append([Alarm(type: .oven)]) }

        return alarms
    }()

    lazy var transition: Transition = { [unowned self] in
        let transition = Transition() { controller, show in

            controller.view.alpha = show ? 1 : 0
            controller.view.backgroundColor = UIColor.clear

            if !UIAccessibility.isReduceMotionEnabled {
                if let timerController = controller as? TimerViewController {
                    if show {
                        timerController.kitchenButton.alpha = 0
                        self.ovenShineImageView.alpha = 0
                        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -200)
                            self.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -200)
                            self.stoveView.transform = CGAffineTransform(scaleX: 0.21, y: 0.21)
                            self.stoveView.frame.origin.x = timerController.kitchenButton.frame.origin.x - 10
                            self.stoveView.frame.origin.y = timerController.kitchenButton.frame.origin.y - 25
                        }, completion: { _ in
                            timerController.kitchenButton.alpha = controller.isBeingDismissed ? 0 : 1
                        })

                        if controller.isBeingPresented {
                            timerController.timerControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            timerController.timerControl.alpha = 0.0
                            UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .beginFromCurrentState, animations: {
                                timerController.timerControl.transform = .identity
                                timerController.timerControl.alpha = 1
                            }, completion: nil)
                        }
                    } else {
                        if controller.isBeingDismissed {
                            UIView.animate(withDuration: 0.25) {
                                timerController.timerControl.alpha = 0.0
                                timerController.timerControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            }
                        }

                        self.titleLabel.transform = .identity
                        self.subtitleLabel.transform = .identity
                        self.stoveView.transform = .identity
                        self.stoveView.frame.origin.x = 0
                        self.stoveView.frame.origin.y = self.topMargin
                        self.ovenShineImageView.alpha = 1
                    }
                }
            }
        }

        return transition
    }()

    lazy var titleLabel: UILabel = { [unowned self] in
        let sideMargin: CGFloat = 20
        let width = Screen.width - 2 * sideMargin
        let height: CGFloat = 25
        var topMargin: CGFloat = 0

        if Screen.isPad {
            topMargin = 115
        } else {
            if Screen.height == 480 || Screen.height == 568 {
                topMargin = 60
            } else if Screen.height == 667 {
                topMargin = 74
            } else {
                topMargin = 82
            }
        }

        let label = UILabel(frame: CGRect(x: sideMargin, y: topMargin,
                                          width: width, height: height))
        label.font = Font.HomeViewController.title
        label.text = Alarm.titleForHomescreen()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    lazy var subtitleLabel: UILabel = { [unowned self] in
        let sideMargin: CGFloat = 20
        let width = Screen.width - 2 * sideMargin
        let height = self.titleLabel.frame.height
        var topMargin = self.titleLabel.frame.maxY

        if Screen.isPad { topMargin += 10 }

        let label = UILabel(frame: CGRect(x: sideMargin, y: topMargin,
                                          width: width, height: height))
        label.font = Font.HomeViewController.subtitle
        label.text = Alarm.subtitleForHomescreen()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    lazy var plateCollectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        var cellWidth: CGFloat = 0
        var sideMargin: CGFloat = 0

        if Screen.isPad {
            cellWidth = 175
            sideMargin = 200
        } else {
            if Screen.height == 480 || Screen.height == 568 {
                cellWidth = 100
                sideMargin = 50
            } else if Screen.height == 667 {
                cellWidth = 113
                sideMargin = 65
            } else {
                cellWidth = 122
                sideMargin = 75
            }
        }

        layout.itemSize = CGSize(width: cellWidth + 10, height: cellWidth + 2)
        layout.scrollDirection = .horizontal

        let width: CGFloat = Screen.width - 2 * sideMargin
        let collectionViewWidth = CGRect(x: sideMargin, y: 0,
                                         width: width, height: width)

        let collectionView = UICollectionView(frame: collectionViewWidth,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.clear

        self.applyTransformToLayer(collectionView.layer, factor: self.plateFactor)

        return collectionView
    }()

    lazy var ovenCollectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        var topMargin: CGFloat = self.plateCollectionView.frame.height + self.topMargin * 2
        var cellWidth: CGFloat = 0
        var sideMargin: CGFloat = 0

        if Screen.isPad {
            cellWidth = 175
            sideMargin = 200
        } else {
            if Screen.height == 480 {
                cellWidth = 120
                sideMargin = 100
            } else if Screen.height == 568 {
                cellWidth = 120
                sideMargin = 100
            } else if Screen.height == 667 {
                cellWidth = 140
                sideMargin = 120
            } else {
                cellWidth = 152
                sideMargin = 130
            }
        }

        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.scrollDirection = .horizontal

        let width: CGFloat = Screen.width - 2 * sideMargin
        let collectionViewWidth = CGRect(x: sideMargin, y: topMargin,
                                         width: width, height: width)

        let collectionView = UICollectionView(frame: collectionViewWidth,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.clear

        self.applyTransformToLayer(collectionView.layer, factor: self.ovenFactor)

        return collectionView
    }()

    lazy var ovenBackgroundImageView: UIImageView = {
        let imageView: UIImageView
        let image = UIImage(named: "Oven")

        var width: CGFloat = image!.size.width
        var height: CGFloat = image!.size.height
        var topMargin: CGFloat = image!.size.height

        if Screen.isPad {
            topMargin += 175
        } else {
            if Screen.height == 480 {
                topMargin += 10
                width -= 42
                height -= 42
            } else if Screen.height == 568 {
                width -= 42
                height -= 42
                topMargin += 70
            } else if Screen.height == 667 {
                topMargin += 118
            } else if Screen.height == 736 {
                topMargin += 128
            } else {
                topMargin += 258
            }
        }

        var x: CGFloat = Screen.width / 2 - width / 2

        let y = Screen.height - topMargin * 1.2
        imageView = UIImageView(frame: CGRect(x: x, y: y,
                                              width: width, height: height))
        imageView.image = image
        imageView.isUserInteractionEnabled = false

        return imageView
    }()

    lazy var ovenShineImageView: UIImageView = { [unowned self] in
        let imageView: UIImageView
        let image = UIImage(named: "OvenGloss")

        imageView = UIImageView(frame: self.ovenBackgroundImageView.frame)
        imageView.image = image
        imageView.isUserInteractionEnabled = false

        return imageView
    }()

    lazy var herbieController: HerbieController = {
        let controller = HerbieController()
        return controller
    }()

    convenience init(theme: Themable? = Theme.current()) {
        self.init()
        self.theme = theme
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.appWasShaked(_:)), name: NSNotification.Name(rawValue: "appWasShaked"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.alarmsDidUpdate(_:)), name: NSNotification.Name(rawValue: AlarmCenter.Notifications.AlarmsDidUpdate), object: nil)

        plateCollectionView.register(PlateCell.classForCoder(), forCellWithReuseIdentifier: plateCellIdentifier)
        ovenCollectionView.register(PlateCell.classForCoder(), forCellWithReuseIdentifier: plateCellIdentifier)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        stoveView.addSubview(ovenBackgroundImageView)
        stoveView.addSubview(ovenShineImageView)
        stoveView.addSubview(plateCollectionView)
        stoveView.addSubview(ovenCollectionView)
        view.addSubview(stoveView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated, addGradient: true)

        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.dismissedTimerController(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.contentSizeCategoryDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)

        setNeedsStatusBarAppearanceUpdate()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    @objc func contentSizeCategoryDidChange(_ notification: Notification) {
        titleLabel.font = Font.HomeViewController.title
        subtitleLabel.font = Font.HomeViewController.subtitle
    }

    @objc func appWasShaked(_ notification: Notification) {
        if notification.name.rawValue == "appWasShaked" && deleteTimersMessageIsBeingDisplayed == false {
            let alertController = UIAlertController(title: "Would you like to cancel all the timers?".localized, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { _ in
                AlarmCenter.cancelAllNotifications()
                self.maxMinutesLeft = nil
                self.plateCollectionView.reloadData()
                self.ovenCollectionView.reloadData()
                self.deleteTimersMessageIsBeingDisplayed = false
            }))
            alertController.addAction(UIAlertAction(title: "No".localized, style: .cancel, handler: { _ in
                self.deleteTimersMessageIsBeingDisplayed = false
            }))
            present(alertController, animated: true, completion: nil)
            deleteTimersMessageIsBeingDisplayed = true
        }
    }

    @objc func alarmsDidUpdate(_ notification: Notification) {
        if notification.name.rawValue == AlarmCenter.Notifications.AlarmsDidUpdate {
            DispatchQueue.main.async {
                self.maxMinutesLeft = nil
                self.plateCollectionView.reloadData()
                self.ovenCollectionView.reloadData()
            }
        }
    }

    func presentHerbie() {
        if let visibleViewController = navigationController?.visibleViewController, !visibleViewController.isKind(of: HerbieController.self) {
            herbieController.theme = theme
            herbieController.transitioningDelegate = transition
            present(herbieController, animated: true, completion: nil)
        }
    }

    func registeredForNotifications() {
        dismiss(animated: true, completion: nil)
    }

    func cancelledNotifications() {
        herbieController.cancelledNotifications()
    }

    func applyTransformToLayer(_ layer: CALayer, factor: CGFloat) {
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -800.0
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, π * factor, 1.0, 0.0, 0.0)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        layer.transform = rotationAndPerspectiveTransform
    }

    func alarmAtIndexPath(_ indexPath: IndexPath, collectionView: UICollectionView) -> Alarm {
        let row: [Alarm] = collectionView.isEqual(plateCollectionView)
            ? alarms[indexPath.section]
            : ovenAlarms[indexPath.section]

        return row[indexPath.row]
    }

    func configureCell(_ cell: PlateCell, indexPath: IndexPath, collectionView: UICollectionView) {
        let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)

        alarm.indexPath = indexPath
        cell.timerControl.active = alarm.active
        cell.timerControl.addTarget(self, action: #selector(HomeViewController.timerControlChangedValue(_:)), for: .valueChanged)
        cell.timerControl.theme = theme

        refreshTimerInCell(cell, alarm: alarm)
    }

    func refreshTimerInCell(_ cell: PlateCell, alarm: Alarm) {
        if let existingNotification = AlarmCenter.getNotification(alarm.alarmID!),
            let userinfo = existingNotification.userInfo,
            let firedDate = userinfo[Alarm.fireDateKey] as? Date,
            let numberOfSeconds = userinfo[Alarm.fireIntervalKey] as? NSNumber {
            let secondsPassed: TimeInterval = Date().timeIntervalSince(firedDate)
            let secondsLeft = TimeInterval(numberOfSeconds.intValue) - secondsPassed
            let currentSecond = secondsLeft.truncatingRemainder(dividingBy: 60)
            var minutesLeft = floor(secondsLeft / 60)
            let hoursLeft = floor(minutesLeft / 60)

            let maxMinutesLeftDouble = maxMinutesLeft?.doubleValue ?? 0
            if minutesLeft >= maxMinutesLeftDouble {
                maxMinutesLeft = minutesLeft as NSNumber
            }

            if hoursLeft > 0 {
                minutesLeft = minutesLeft - (hoursLeft * 60)
            }

            if minutesLeft < 0 {
                AlarmCenter.cancelNotification(alarm.alarmID!)
            }

            alarm.active = true
            cell.timerControl.active = true
            cell.timerControl.alarmID = alarm.alarmID
            cell.timerControl.seconds = Int(currentSecond)
            cell.timerControl.hours = Int(hoursLeft)
            cell.timerControl.minutes = Int(minutesLeft)
            cell.timerControl.startTimer()

            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "presentedClue")
            defaults.synchronize()

        } else {
            alarm.active = false
            cell.timerControl.active = false
            cell.timerControl.restartTimer()
            cell.timerControl.stopTimer()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView.isEqual(plateCollectionView)
            ? alarms.count
            : ovenAlarms.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.isEqual(plateCollectionView) ? alarms.first!.count : ovenAlarms.first!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: plateCellIdentifier, for: indexPath) as! PlateCell

        configureCell(cell, indexPath: indexPath, collectionView: collectionView)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            self.plateCollectionView.alpha = 0
            self.ovenCollectionView.alpha = 0
            self.ovenBackgroundImageView.alpha = 0
            self.ovenShineImageView.alpha = 0
            self.titleLabel.alpha = 0
            self.subtitleLabel.alpha = 0
        }

        let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)
        let timerController = TimerViewController(alarm: alarm)

        timerController.theme = theme
        timerController.delegate = self
        timerController.transitioningDelegate = transition

        if let cell = collectionView.cellForItem(at: indexPath) {
            cellRect = cell.convert(view.bounds, to: collectionView)
        }

        present(timerController, animated: true, completion: nil)
    }
}

// MARK: - HYPTimerControllerDelegate

extension HomeViewController: TimerControllerDelegate {
    @objc func dismissedTimerController(_ timerController: TimerViewController!) {
        maxMinutesLeft = nil
        plateCollectionView.reloadData()
        ovenCollectionView.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.plateCollectionView.alpha = 1
            self.ovenCollectionView.alpha = 1
            self.ovenBackgroundImageView.alpha = 1
            self.ovenShineImageView.alpha = 1
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }
    }

    @objc func timerControlChangedValue(_ timerControl: TimerControl) {
        if let maxMinutes = self.maxMinutesLeft, maxMinutes.int32Value - 1 == timerControl.minutes {
            maxMinutesLeft = timerControl.minutes as NSNumber
        } else if let maxMinutes = maxMinutesLeft, maxMinutes.floatValue == Float(0) && timerControl.minutes == 59 {
            maxMinutesLeft = nil
        }
    }
}
