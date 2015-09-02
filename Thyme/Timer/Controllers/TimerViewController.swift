import UIKit

protocol TimerControllerDelegate {
  func dismissedTimerController(timerController: TimerViewController!)
}

class TimerViewController: ViewController {

  enum TimerDirection {
    case Forward, Backward
  }

  var alarm: Alarm
  var timer: NSTimer?
  var startRect: CGRect = CGRectNull
  var finalRect: CGRect = CGRectNull
  var delegate: TimerControllerDelegate?
  override var theme: Themable? {
    didSet {
      if let theme = theme {
        gradientLayer.colors = theme.colors
        gradientLayer.locations = theme.locations
        timerControl.theme = theme
      }
    }
  }

  lazy var timerControl: TimerControl = {
    var sideMargin: CGFloat = Screen.isPad ? 140 : 0
    var topMargin: CGFloat = 0

    if Screen.isPad {
      topMargin = 140
    } else {
      if Screen.height == 480 {
        topMargin = 30
      } else if Screen.height == 568 {
        topMargin = 60
      } else if Screen.height == 667 {
        topMargin = 70
      } else if Screen.height == 763 {
        topMargin = 78
      }
    }

    let width = Screen.width - 2 * sideMargin
    let frame = CGRect(x: sideMargin, y: topMargin, width: width, height: width)
    let timerControl = TimerControl(frame: frame, completedMode: true)

    timerControl.active = true
    timerControl.backgroundColor = UIColor.clearColor()

    return timerControl
  }()

  lazy var fingerView: UIImageView = {
    let image = UIImage(named: "fingerImage")!
    let x: CGFloat = CGRectGetMaxX(self.timerControl.frame) / 2 - image.size.width / 2
    let y: CGFloat = CGRectGetMinY(self.timerControl.frame) + image.size.height
    let width: CGFloat = image.size.width
    let height: CGFloat = image.size.height

    var xOffset: CGFloat = 61
    var yOffset: CGFloat = 18

    if Screen.height == 667 {
      xOffset = 70
      yOffset = 35
    } else if Screen.height == 763 {
      xOffset = 80
      yOffset = 45
    }

    self.startRect = CGRect(x: x, y: y, width: width, height: height)
    self.finalRect = CGRect(x: x + xOffset, y: y + yOffset, width: width, height: height)

    let imageView = UIImageView(image: image)
    imageView.frame = self.startRect
    imageView.hidden = true

    return imageView
  }()

  lazy var kitchenButton: UIButton = {
    let button = UIButton(type: .Custom)
    let imageName = self.alarm.type == .Oven
      ? "oven"
      : "\(self.alarm.indexPath!.row)-\(self.alarm.indexPath!.section)"
    let image = UIImage(named: imageName)!

    var topMargin: CGFloat = image.size.height
    var x: CGFloat = Screen.width / 2 - image.size.width / 2
    var y: CGFloat = Screen.width / 2 - image.size.width / 2
    var width: CGFloat = image.size.width
    var height: CGFloat = image.size.height

    if Screen.isPad {
      topMargin = 330
      y = Screen.height - topMargin
    } else {
      if Screen.height == 480 {
        topMargin = 110
        y = Screen.height - topMargin
      }  else if Screen.height == 568 {
        topMargin = 140
        y = Screen.height - topMargin
      } else if Screen.height == 667 {
        topMargin = 164
        x = 150
        y = Screen.height - topMargin
        width = 75
        height = 75
      } else if Screen.height == 763 {
        topMargin = 181
        x = 166
        y = Screen.height - topMargin
        width = 83
        height = 83
      }
    }

    button.addTarget(self, action: "kitchenButtonPressed:",
      forControlEvents: .TouchUpInside)
    button.contentMode = .ScaleAspectFit
    button.frame = CGRect(x: x, y: y, width: width, height: height)
    button.imageEdgeInsets = UIEdgeInsetsZero

    let states: [UIControlState] = [.Highlighted, .Normal, .Selected]
    for state in states {
      button.setBackgroundImage(image, forState: state)
    }

    return button
  }()

  init(alarm: Alarm) {
    self.alarm = alarm

    super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    for subview in [timerControl, kitchenButton, fingerView] { view.addSubview(subview) }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    timerControl.alarm = alarm
    timerControl.alarmID = alarm.alarmID
    refreshTimerForCurrentAlarm()

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "kitchenButtonPressed:",
      name: UIApplicationDidBecomeActiveNotification,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "alarmsDidUpdate:",
      name: WatchCommunicator.Notifications.AlarmsDidUpdate,
      object: nil)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.boolForKey("presentedClue") == false {
      fingerView.hidden = false
      UIApplication.sharedApplication().beginIgnoringInteractionEvents()
      startTimerGoing(.Forward)
      UIView.animateWithDuration(0.8, animations: {
        self.fingerView.frame = self.finalRect
      }, completion: { _ in
        self.stopTimer()
        self.startTimerGoing(.Backward)
        UIView.animateWithDuration(0.8, animations: {
          self.fingerView.frame = self.startRect
          }, completion: { _ in
            self.fingerView.hidden = true
            self.stopTimer()
        })
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        defaults.setBool(true, forKey: "presentedClue")
        defaults.synchronize()
      })
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func updateForward(timer: NSTimer) {
    if timerControl.minutes < 7 { timerControl.minutes += 1 }
  }

  func updateBackward(timer: NSTimer) {
    if timerControl.minutes > 0 { timerControl.minutes -= 1 }
  }

  func startTimerGoing(direction: TimerDirection) {
    if timer == nil {
      switch direction {
      case .Forward:
        timer = NSTimer(timeInterval: 0.1,
          target: self,
          selector: "updateForward:",
          userInfo: nil,
          repeats: true)
        break
      case .Backward:
        timer = NSTimer(timeInterval: 0.1,
          target: self,
          selector: "updateBackward:",
          userInfo: nil,
          repeats: true)
        break
      }

      NSRunLoop.currentRunLoop().addTimer(timer!,
        forMode: NSRunLoopCommonModes)
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
    }
  }

  func refreshTimerForNotification(notification: UILocalNotification) {
    if let userinfo = notification.userInfo,
      firedDate = userinfo[ThymeAlarmFireDataKey] as? NSDate,
      numberOfSeconds = userinfo[ThymeAlarmFireInterval] as? NSNumber {
        let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
        let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
        let currentSecond = secondsLeft % 60
        var minutesLeft = floor(secondsLeft/60)
        let hoursLeft = floor(minutesLeft/60)

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

  func kitchenButtonPressed(button: UIButton) {
    delegate?.dismissedTimerController(self)
    dismissViewControllerAnimated(true, completion: nil)
    timerControl.touchesAreActive = false
  }

  func alarmsDidUpdate(notification: NSNotification) {
    if let localNotification = notification.object as? UILocalNotification where notification.name == WatchCommunicator.Notifications.AlarmsDidUpdate {
      timerControl.stopTimer()
      refreshTimerForNotification(localNotification)
    }
  }
}
