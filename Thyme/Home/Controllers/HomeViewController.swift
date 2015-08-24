import UIKit

class HomeViewController: ViewController {

  let plateCellIdentifier = "HYPPlateCellIdentifier"

  var deleteTimersMessageIsBeingDisplayed: Bool = false

  var maxMinutesLeft: NSNumber? {
    didSet(newValue) {
      if let maxMinutesLeft = maxMinutesLeft {
        titleLabel.text = NSLocalizedString("YOUR DISH WILL BE DONE",
          comment: "YOUR DISH WILL BE DONE");
        if (maxMinutesLeft == 0.0) {
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
      if self.deviceHeight == 480 {
        margin = 10
      } else if self.deviceHeight == 568 {
        margin = 50
      } else if self.deviceHeight == 667 {
        margin = 68
      } else {
        margin = 75
      }
    }

    return margin
  }()

  lazy var plateFactor: CGFloat = {
    let factor: CGFloat = Screen.isPad ? 0.36 : 0.30
    return factor
    }()

  lazy var ovenFactor: CGFloat = {
    let factor: CGFloat = Screen.isPad ? 0.29 : 0.25
    return factor
    }()

  lazy var deviceHeight: CGFloat = {
    return UIScreen.mainScreen().bounds.height
    }()

  lazy var deviceWidth: CGFloat = {
    return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }()

  lazy var alarms: [[Alarm]] = {
    var alarms = [[Alarm]]()

    for i in 0..<2 {
      alarms.append([Alarm(), Alarm()])
    }

    return alarms
    }()

  lazy var ovenAlarms: [[Alarm]] = {
    var alarms = [[Alarm]]()

    for i in 0..<1 {
      let alarm = Alarm()
      alarm.oven = true
      alarms.append([alarm])
    }

    return alarms
    }()

  lazy var titleLabel: UILabel = {
    let sideMargin: CGFloat = 20
    let width = self.deviceWidth - 2 * sideMargin
    let height: CGFloat = 25
    var topMargin: CGFloat = 0
    var font: UIFont

    if Screen.isPad {
      topMargin  = 115
      font = HYPUtils.avenirLightWithSize(20)
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        topMargin = 60
        font = HYPUtils.avenirLightWithSize(15)
      } else if self.deviceHeight == 667 {
        topMargin = 74
        font = HYPUtils.avenirLightWithSize(18)
      } else {
        topMargin = 82
        font = HYPUtils.avenirLightWithSize(19)
      }
    }

    let label = UILabel(frame: CGRectMake(sideMargin, topMargin, width, height))
    label.font = font
    label.text = Alarm.titleForHomescreen()
    label.textAlignment = .Center
    label.textColor = UIColor.whiteColor()
    label.backgroundColor = UIColor.clearColor()
    label.adjustsFontSizeToFitWidth = true

    return label
    }()

  lazy var subtitleLabel: UILabel = {
    let sideMargin: CGFloat = 20
    let width = self.deviceWidth - 2 * sideMargin
    let height = CGRectGetHeight(self.titleLabel.frame)
    var topMargin = CGRectGetMaxY(self.titleLabel.frame)
    var font: UIFont

    if Screen.isPad {
      topMargin += 10
      font = HYPUtils.avenirBlackWithSize(25)
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        font = HYPUtils.avenirBlackWithSize(19)
      } else if self.deviceHeight == 667 {
        topMargin += 4
        font = HYPUtils.avenirBlackWithSize(22)
      } else {
        topMargin += 7
        font = HYPUtils.avenirBlackWithSize(24)
      }
    }

    let label = UILabel(frame: CGRectMake(sideMargin, topMargin, width, height))
    label.font = font
    label.text = Alarm.subtitleForHomescreen()
    label.textAlignment = .Center
    label.textColor = UIColor.whiteColor()
    label.backgroundColor = UIColor.clearColor()
    label.adjustsFontSizeToFitWidth = true

    return label
    }()

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    var cellWidth: CGFloat = 0
    var sideMargin: CGFloat = 0

    if Screen.isPad {
      cellWidth = 175
      sideMargin = 200
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        cellWidth = 100
        sideMargin = 50
      } else if self.deviceHeight == 667 {
        cellWidth = 113
        sideMargin = 65
      } else {
        cellWidth = 122
        sideMargin = 75
      }
    }

    layout.itemSize = CGSizeMake(cellWidth + 10, cellWidth)
    layout.scrollDirection = .Horizontal

    let width: CGFloat = self.deviceWidth - 2 * sideMargin
    let collectionViewWidth = CGRectMake(sideMargin, self.topMargin, width, width)

    let collectionView = UICollectionView(frame: collectionViewWidth,
      collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clearColor()

    self.applyTransformToLayer(collectionView.layer, factor: self.plateFactor)

    return collectionView
    }()

  lazy var ovenCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    var topMargin: CGFloat = self.topMargin
    var cellWidth: CGFloat = 0
    var sideMargin: CGFloat = 0

    if Screen.isPad {
      cellWidth = 175
      sideMargin = 200
      topMargin += 475
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        cellWidth = 120
        sideMargin = 100
        topMargin += 260
      } else if self.deviceHeight == 667 {
        cellWidth = 133
        sideMargin = 120
        topMargin += 300
      } else {
        cellWidth = 152
        sideMargin = 130
        topMargin += 328
      }
    }

    layout.itemSize = CGSizeMake(cellWidth, cellWidth)
    layout.scrollDirection = .Horizontal

    let width: CGFloat = self.deviceWidth - 2 * sideMargin
    let collectionViewWidth = CGRectMake(sideMargin, topMargin, width, width)

    let collectionView = UICollectionView(frame: collectionViewWidth,
      collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clearColor()

    self.applyTransformToLayer(collectionView.layer, factor: self.ovenFactor)

    return collectionView
    }()

  lazy var ovenBackgroundImageView: UIImageView = {
    let imageView: UIImageView
    let imageName = Screen.isPad
      ? "ovenBackground~iPad"
      : "ovenBackground"
    let image = UIImage(named: imageName)

    var topMargin: CGFloat = image!.size.height
    var x: CGFloat = self.deviceWidth / 2 - image!.size.width / 2;
    var width: CGFloat = image!.size.width
    var height: CGFloat = image!.size.height

    if Screen.isPad {
      topMargin += 175
    } else {
      if self.deviceHeight == 480 {
        topMargin += 40
      }  else if self.deviceHeight == 568 {
        topMargin += 90
      } else if self.deviceHeight == 667 {
        topMargin += 118
      } else if self.deviceHeight == 763 {
        height = 173
        topMargin += 128
        width = 304
        x = 54
      }
    }

    let y = self.deviceHeight - topMargin
    imageView = UIImageView(frame: CGRectMake(x, y, width, height))
    imageView.image = image

    return imageView
    }()

  lazy var ovenShineImageView: UIImageView = {
    let imageView: UIImageView
    let imageName = Screen.isPad
      ? "ovenShine~iPad"
      : "ovenShine"
    let image = UIImage(named: imageName)

    imageView = UIImageView(frame: self.ovenBackgroundImageView.frame)
    imageView.image = image

    return imageView
    }()

  lazy var settingsButton: UIButton = {
    let button = UIButton.buttonWithType(.InfoLight) as! UIButton
    button.addTarget(self, action: "settingsButtonAction", forControlEvents: .TouchUpInside)

    let y: CGFloat = self.deviceHeight - 44 - 15
    let x: CGFloat = 5

    button.frame = CGRectMake(x,y,44,44)
    button.tintColor = UIColor.whiteColor()

    return button
  }()

  lazy var tapRecognizer: UITapGestureRecognizer = {
    return UITapGestureRecognizer(target: self, action: "backgroundTapped:")
  }()

  lazy var welcomeController: InstructionController = {
    let controller = InstructionController(
      image: UIImage(named: "welcomeIcon")!,
      title: NSLocalizedString("WelcomeTitle", comment: ""),
      message: NSLocalizedString("WelcomeMessage", comment: ""),
      hasAction: true,
      isWelcome: true,
      index: -1)
    controller.delegate = self

    return controller
  }()

  lazy var settingsController: SettingsViewController = {
    let settingsController = SettingsViewController(style: .Grouped)
    return settingsController
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "appWasShaked:",
      name: "appWasShaked",
      object: nil)

    collectionView.registerClass(PlateCell.classForCoder(),
      forCellWithReuseIdentifier: plateCellIdentifier)
    ovenCollectionView.registerClass(PlateCell.classForCoder(),
      forCellWithReuseIdentifier: plateCellIdentifier)

    [titleLabel, subtitleLabel,
      ovenBackgroundImageView, ovenShineImageView,
      collectionView, ovenCollectionView].map { self.view.addSubview($0) }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "dismissedTimerController:",
      name: UIApplicationDidBecomeActiveNotification,
      object: nil)

    self.setNeedsStatusBarAppearanceUpdate()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let registredSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
    let types: UIUserNotificationType = .Alert | .Badge | .Sound

    if registredSettings.types != types {
      let navigationController = UINavigationController(rootViewController: welcomeController)
      navigationController.navigationBarHidden = true
      presentViewController(navigationController,
        animated: true,
        completion: nil)
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return false
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

  func backgroundTapped(gesture :UIGestureRecognizer) {
    var frame = UIScreen.mainScreen().bounds
    frame.size.width = 230
    frame.origin.x = -230
    UIView.animateWithDuration(0.3, animations: {
      self.settingsController.view.frame = frame
    }) { _ in
      self.removeViewController(self.settingsController)

      let applicationDelegate = UIApplication.sharedApplication().delegate
      if let window = applicationDelegate?.window {
        self.settingsController.view.removeFromSuperview()
        self.view.removeGestureRecognizer(self.tapRecognizer)
      }
    }
  }

  func settingsButtonAction() {
    var frame = UIScreen.mainScreen().bounds
    frame.size.width = 230
    frame.origin.x = -230

    let applicationDelegate = UIApplication.sharedApplication().delegate
    addViewController(settingsController, inFrame: frame)
    if let window = applicationDelegate?.window {
      window?.addSubview(settingsController.view)
    }

    frame.origin.x = 0
    UIView.animateWithDuration(0.3, animations: {
      self.settingsController.view.frame = frame
      self.view.addGestureRecognizer(self.tapRecognizer)
    })
  }

  func registeredForNotifications() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func cancelledNotifications() {
    welcomeController.cancelledNotifications()
  }

  func applyTransformToLayer(layer: CALayer, factor: CGFloat) {
    var rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -800.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, π * factor, 1.0, 0.0, 0.0);
    layer.anchorPoint = CGPointMake(0.5, 0);
    layer.transform = rotationAndPerspectiveTransform;
  }

  func alarmAtIndexPath(indexPath: NSIndexPath, collectionView: UICollectionView) -> Alarm {
    let row: [Alarm] = collectionView.isEqual(self.collectionView)
      ? alarms[indexPath.section]
      : ovenAlarms[indexPath.section]

    return row[indexPath.row]
  }

  func configureCell(cell: PlateCell, indexPath: NSIndexPath, collectionView: UICollectionView) {
    let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)
    alarm.indexPath = indexPath

    cell.timerControl.active = alarm.active
    cell.timerControl.addTarget(self, action: "timerControlChangedValue:", forControlEvents: .ValueChanged)

    refreshTimerInCell(cell, alarm: alarm)
  }

  func refreshTimerInCell(cell: PlateCell, alarm: Alarm) {
    if let existingNotification = LocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID!),
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
        UIApplication.sharedApplication().cancelLocalNotification(existingNotification)
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
    return collectionView.isEqual(self.collectionView)
      ? alarms.count
      : ovenAlarms.count
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collectionView.isEqual(self.collectionView)
    ? alarms[0].count
    : ovenAlarms[0].count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(plateCellIdentifier, forIndexPath: indexPath) as! PlateCell

    configureCell(cell, indexPath: indexPath, collectionView: collectionView)

    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)
    let timerController = TimerViewController(alarm: alarm)
    timerController.delegate = self

    presentViewController(timerController, animated: true, completion: nil)
  }
}

// MARK: - InstructionDelegate

extension HomeViewController: InstructionDelegate {

  func instructionControllerDidTapAcceptButton(controller: InstructionController) {
    let types: UIUserNotificationType = .Alert | .Badge | .Sound
    let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }
}

// MARK: - UIAlertViewDelegate

extension HomeViewController: UIAlertViewDelegate {

  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    let accepted: Bool = buttonIndex == 1
    if accepted == true {
      LocalNotificationManager.cancelAllLocalNotifications()
      maxMinutesLeft = nil
      collectionView.reloadData()
      ovenCollectionView.reloadData()
    }
    deleteTimersMessageIsBeingDisplayed = false
  }
}

// MARK: - HYPTimerControllerDelegate

extension HomeViewController: TimerControllerDelegate {

  func dismissedTimerController(timerController: TimerViewController!) {
    maxMinutesLeft = nil
    collectionView.reloadData()
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
