import UIKit
import Transition

class HomeViewController: ViewController, ContentSizeChangable {

  let plateCellIdentifier = "HYPPlateCellIdentifier"

  var deleteTimersMessageIsBeingDisplayed: Bool = false
  var cellRect: CGRect?

  override var theme: Themable? {
    willSet(newTheme) {
      gradientLayer.colors = newTheme?.colors
      gradientLayer.locations = newTheme?.locations
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
        titleLabel.text = NSLocalizedString("YOUR DISH WILL BE DONE",
          comment: "YOUR DISH WILL BE DONE")
        if maxMinutesLeft == 0.0 {
          subtitleLabel.text = NSLocalizedString("IN LESS THAN A MINUTE",
            comment: "IN LESS THAN A MINUTE")
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
      margin  = 70
    } else {
      if Screen.height == 480 {
        margin = 42
      } else if Screen.height == 568 {
        margin = 50
      } else if Screen.height == 667 {
        margin = 64
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

    for i in 0..<2 { alarms.append([Alarm(), Alarm()]) }

    return alarms
    }()

  lazy var ovenAlarms: [[Alarm]] = {
    var alarms = [[Alarm]]()

    for i in 0..<1 { alarms.append([Alarm(type: .Oven)]) }

    return alarms
    }()

  lazy var transition: Transition = { [unowned self] in
    let transition = Transition() {  controller, show in

      controller.view.alpha = show ? 1 : 0
      controller.view.backgroundColor = UIColor.clearColor()

      if !UIAccessibilityIsReduceMotionEnabled() {
        if let timerController = controller as? TimerViewController {
          if show {
            timerController.kitchenButton.alpha = 0
            UIView.animateWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {
              self.titleLabel.transform = CGAffineTransformMakeTranslation(0,-200)
              self.subtitleLabel.transform = CGAffineTransformMakeTranslation(0,-200)
              self.stoveView.transform = CGAffineTransformMakeScale(0.20, 0.20)
              self.stoveView.frame.origin.x = timerController.kitchenButton.frame.origin.x
              self.stoveView.frame.origin.y = timerController.kitchenButton.frame.origin.y - 25
              }, completion: { _ in
                timerController.kitchenButton.alpha = controller.isBeingDismissed() ? 0 : 1
              })

            if controller.isBeingPresented() {
              timerController.timerControl.transform = CGAffineTransformMakeScale(0.5, 0.5)
              timerController.timerControl.alpha = 0.0
              UIView.animateWithDuration(0.8, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .BeginFromCurrentState, animations: {
                timerController.timerControl.transform = CGAffineTransformIdentity
                timerController.timerControl.alpha = 1
                }, completion: nil)
            }
          } else {
            if controller.isBeingDismissed() {
              UIView.animateWithDuration(0.25) {
                timerController.timerControl.alpha = 0.0
                timerController.timerControl.transform = CGAffineTransformMakeScale(0.5, 0.5)
              }
            }
          
            self.titleLabel.transform = CGAffineTransformIdentity
            self.subtitleLabel.transform = CGAffineTransformIdentity
            self.stoveView.transform = CGAffineTransformIdentity
            self.stoveView.frame.origin.x = 0
            self.stoveView.frame.origin.y = self.topMargin
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
      topMargin  = 115
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
    label.textAlignment = .Center
    label.backgroundColor = UIColor.clearColor()
    label.adjustsFontSizeToFitWidth = true

    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let sideMargin: CGFloat = 20
    let width = Screen.width - 2 * sideMargin
    let height = CGRectGetHeight(self.titleLabel.frame)
    var topMargin = CGRectGetMaxY(self.titleLabel.frame)

    if Screen.isPad { topMargin += 10 }

    let label = UILabel(frame: CGRect(x: sideMargin, y: topMargin,
      width: width, height: height))
    label.font = Font.HomeViewController.subtitle
    label.text = Alarm.subtitleForHomescreen()
    label.textAlignment = .Center
    label.backgroundColor = UIColor.clearColor()
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
    layout.scrollDirection = .Horizontal

    let width: CGFloat = Screen.width - 2 * sideMargin
    let collectionViewWidth = CGRect(x: sideMargin, y: 0,
      width: width, height: width)

    let collectionView = UICollectionView(frame: collectionViewWidth,
      collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.scrollEnabled = false
    collectionView.backgroundColor = UIColor.clearColor()

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
    layout.scrollDirection = .Horizontal

    let width: CGFloat = Screen.width - 2 * sideMargin
    let collectionViewWidth = CGRect(x: sideMargin, y: topMargin,
      width: width, height: width)

    let collectionView = UICollectionView(frame: collectionViewWidth,
      collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.scrollEnabled = false
    collectionView.backgroundColor = UIColor.clearColor()

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
      }  else if Screen.height == 568 {
        width -= 42
        height -= 42
        topMargin += 70
      } else if Screen.height == 667 {
        topMargin += 118
      } else if Screen.height == 736 {
        topMargin += 128
      }
    }
    
    var x: CGFloat = Screen.width / 2 - width / 2

    let y = Screen.height - topMargin * 1.2
    imageView = UIImageView(frame: CGRect(x: x, y: y,
      width: width, height: height))
    imageView.image = image
    imageView.userInteractionEnabled = false

    return imageView
    }()

  lazy var ovenShineImageView: UIImageView = { [unowned self] in
    let imageView: UIImageView
    let image = UIImage(named: "OvenGloss")

    imageView = UIImageView(frame: self.ovenBackgroundImageView.frame)
    imageView.image = image
    imageView.userInteractionEnabled = false

    return imageView
    }()

  lazy var tapRecognizer: UITapGestureRecognizer = { [unowned self] in
    return UITapGestureRecognizer(target: self,
      action: "backgroundTapped:")
  }()

  lazy var herbieController: HerbieController = {
    let controller = HerbieController()
    return controller
  }()

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  convenience init(theme: Themable?) {
    self.init()
    self.theme = theme
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "appWasShaked:",
      name: "appWasShaked",
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "alarmsDidUpdate:",
      name: AlarmCenter.Notifications.AlarmsDidUpdate,
      object: nil)

    UIViewAnimationOptions.CurveEaseIn

    plateCollectionView.registerClass(PlateCell.classForCoder(),
      forCellWithReuseIdentifier: plateCellIdentifier)
    ovenCollectionView.registerClass(PlateCell.classForCoder(),
      forCellWithReuseIdentifier: plateCellIdentifier)

    for subview in [titleLabel, subtitleLabel] {
        view.addSubview(subview)
    }
    for subview in [ovenBackgroundImageView, ovenShineImageView, plateCollectionView, ovenCollectionView] {
      stoveView.addSubview(subview)
    }

    view.addSubview(stoveView)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated, addGradient: true)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "dismissedTimerController:",
      name: UIApplicationDidBecomeActiveNotification,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "contentSizeCategoryDidChange:",
      name: UIContentSizeCategoryDidChangeNotification,
      object: nil)

    self.setNeedsStatusBarAppearanceUpdate()
  }

  override func prefersStatusBarHidden() -> Bool {
    return false
  }

  func contentSizeCategoryDidChange(notification: NSNotification) {
    titleLabel.font = Font.HomeViewController.title
    subtitleLabel.font = Font.HomeViewController.subtitle
  }

  func appWasShaked(notification: NSNotification) {
    if notification.name == "appWasShaked" && deleteTimersMessageIsBeingDisplayed == false {
      UIAlertView(title: NSLocalizedString("Would you like to cancel all the timers?", comment: ""),
        message: "",
        delegate: self,
        cancelButtonTitle: NSLocalizedString("No", comment: ""),
        otherButtonTitles: NSLocalizedString("Ok", comment: "")).show()
      deleteTimersMessageIsBeingDisplayed = true
    }
  }

  func alarmsDidUpdate(notification: NSNotification) {
    if notification.name == AlarmCenter.Notifications.AlarmsDidUpdate {
      dispatch_async(dispatch_get_main_queue()) {
        self.maxMinutesLeft = nil
        self.plateCollectionView.reloadData()
        self.ovenCollectionView.reloadData()
      }
    }
  }

  func presentHerbie() {
    if let visibleViewController = navigationController?.visibleViewController where !visibleViewController.isKindOfClass(HerbieController.self) {
      herbieController.theme = theme
      herbieController.transitioningDelegate = transition
      presentViewController(herbieController, animated: true, completion: nil)
    }
  }

  func registeredForNotifications() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func cancelledNotifications() {
    herbieController.cancelledNotifications()
  }

  func applyTransformToLayer(layer: CALayer, factor: CGFloat) {
    var rotationAndPerspectiveTransform = CATransform3DIdentity
    rotationAndPerspectiveTransform.m34 = 1.0 / -800.0
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, π * factor, 1.0, 0.0, 0.0)
    layer.anchorPoint = CGPoint(x: 0.5, y: 0)
    layer.transform = rotationAndPerspectiveTransform
  }

  func alarmAtIndexPath(indexPath: NSIndexPath, collectionView: UICollectionView) -> Alarm {
    let row: [Alarm] = collectionView.isEqual(plateCollectionView)
      ? alarms[indexPath.section]
      : ovenAlarms[indexPath.section]

    return row[indexPath.row]
  }

  func configureCell(cell: PlateCell, indexPath: NSIndexPath, collectionView: UICollectionView) {
    let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)

    alarm.indexPath = indexPath
    cell.timerControl.active = alarm.active
    cell.timerControl.addTarget(self,
      action: "timerControlChangedValue:",
      forControlEvents: .ValueChanged)
    cell.timerControl.theme = theme

    refreshTimerInCell(cell, alarm: alarm)
  }

  func refreshTimerInCell(cell: PlateCell, alarm: Alarm) {
    if let existingNotification = AlarmCenter.getNotification(alarm.alarmID!),
      userinfo = existingNotification.userInfo,
      firedDate = userinfo[ThymeAlarmFireDataKey] as? NSDate,
      numberOfSeconds = userinfo[ThymeAlarmFireInterval] as? NSNumber
    {
      let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
      let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
      let currentSecond = secondsLeft % 60
      var minutesLeft = floor(secondsLeft/60)
      let hoursLeft = floor(minutesLeft/60)

      if minutesLeft >= maxMinutesLeft?.doubleValue {
          maxMinutesLeft = minutesLeft
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

      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setBool(true, forKey: "presentedClue")
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

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return collectionView.isEqual(plateCollectionView)
      ? alarms.count
      : ovenAlarms.count
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collectionView.isEqual(plateCollectionView)
    ? alarms.first!.count
    : ovenAlarms.first!.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(plateCellIdentifier,
      forIndexPath: indexPath) as! PlateCell

    configureCell(cell, indexPath: indexPath, collectionView: collectionView)

    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)
    let timerController = TimerViewController(alarm: alarm)

    timerController.theme = theme
    timerController.delegate = self
    timerController.transitioningDelegate = transition

    if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
      cellRect = cell.convertRect(view.bounds, toView: collectionView)
    }

    presentViewController(timerController, animated: true, completion: nil)
  }
}

// MARK: - UIAlertViewDelegate

extension HomeViewController: UIAlertViewDelegate {

  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    let accepted: Bool = buttonIndex == 1
    if accepted == true {
      AlarmCenter.cancelAllNotifications()
      maxMinutesLeft = nil
      plateCollectionView.reloadData()
      ovenCollectionView.reloadData()
    }
    deleteTimersMessageIsBeingDisplayed = false
  }
}

// MARK: - HYPTimerControllerDelegate

extension HomeViewController: TimerControllerDelegate {

  func dismissedTimerController(timerController: TimerViewController!) {
    maxMinutesLeft = nil
    plateCollectionView.reloadData()
    ovenCollectionView.reloadData()
  }

  func timerControlChangedValue(timerControl: TimerControl) {
    if let maxMinutes = self.maxMinutesLeft
      where maxMinutes.intValue - 1 == timerControl.minutes {
        maxMinutesLeft = timerControl.minutes
    } else if let maxMinutes = maxMinutesLeft
      where maxMinutes.floatValue == Float(0) && timerControl.minutes == 59 {
        maxMinutesLeft = nil
    }
  }
}
