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

  lazy var deviceHeight: CGFloat = {
    return UIScreen.mainScreen().bounds.height
    }()

  lazy var deviceWidth: CGFloat = {
    return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }()

  lazy var timerControl: TimerControl = {
    var sideMargin: CGFloat = UIScreen.andy_isPad() ? 140 : 0
    var topMargin: CGFloat = 0

    if UIScreen.andy_isPad() {
      topMargin = 140
    } else {
      if self.deviceHeight == 480 {
        topMargin = 30
      } else if self.deviceHeight == 568 {
        topMargin = 60
      } else if self.deviceHeight == 667 {
        topMargin = 70
      } else if self.deviceHeight == 763 {
        topMargin = 78
      }
    }

    let width = self.deviceWidth - 2 * sideMargin
    let frame = CGRectMake(sideMargin, topMargin, width, width)
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

    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0

    if UIScreen.andy_isPad() {
      xOffset = 61
      yOffset = 18
    } else {
      if self.deviceHeight == 480 {
        xOffset = 61
        yOffset = 18
      } else if self.deviceHeight == 568 {
        xOffset = 61
        yOffset = 18
      } else if self.deviceHeight == 667 {
        xOffset = 70
        yOffset = 35
      } else if self.deviceHeight == 763 {
        xOffset = 80
        yOffset = 45
      }
    }
    
    self.startRect = CGRectMake(x,y,width,height)
    self.finalRect = CGRectMake(x + xOffset, y + yOffset, width, height)
    
    let imageView = UIImageView(image: image)
    imageView.frame = self.startRect
    imageView.hidden = true

    return imageView
  }()

  lazy var kitchenButton: UIButton = {
    let button = UIButton.buttonWithType(.Custom) as! UIButton
    let imageName = self.alarm.oven == true
      ? "oven"
      : "\(self.alarm.indexPath!.row)-\(self.alarm.indexPath!.section)"
    let image = UIImage(named: imageName)!

    var topMargin: CGFloat = image.size.height
    var x: CGFloat = self.deviceWidth / 2 - image.size.width / 2;
    var y: CGFloat = self.deviceWidth / 2 - image.size.width / 2;
    var width: CGFloat = image.size.width
    var height: CGFloat = image.size.height

    if UIScreen.andy_isPad() {
      topMargin = 330
      x = self.deviceWidth / 2 - image.size.width / 2;
      y = self.deviceHeight - topMargin;
      width = image.size.width;
      height = image.size.height;
    } else {
      if self.deviceHeight == 480 {
        topMargin = 110
        x = self.deviceWidth / 2 - image.size.width / 2;
        y = self.deviceHeight - topMargin;
        width = image.size.width;
        height = image.size.height;
      }  else if self.deviceHeight == 568 {
        topMargin = 140
        x = self.deviceWidth / 2 - image.size.width / 2;
        y = self.deviceHeight - topMargin;
        width = image.size.width;
        height = image.size.height;
      } else if self.deviceHeight == 667 {
        topMargin = 164
        x = 150
        y = self.deviceHeight - topMargin;
        width = 75
        height = 75
      } else if self.deviceHeight == 763 {
        topMargin = 181
        x = 166
        y = self.deviceHeight - topMargin;
        width = 83
        height = 83
      }
    }

    button.addTarget(self, action: "kitchenButtonPressed:", forControlEvents: .TouchUpInside)
    button.contentMode = .ScaleAspectFit
    button.frame = CGRectMake(x, y, width, height)
    button.imageEdgeInsets = UIEdgeInsetsZero
    button.setBackgroundImage(image, forState: .Highlighted)
    button.setBackgroundImage(image, forState: .Normal)
    button.setBackgroundImage(image, forState: .Selected)

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

    view.addSubview(timerControl)
    view.addSubview(kitchenButton)
    view.addSubview(fingerView)
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
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.boolForKey("presentedClue") == false {
      fingerView.hidden = false
      UIApplication.sharedApplication().beginIgnoringInteractionEvents()
      self.startTimerGoing(.Forward)
      UIView.animateWithDuration(0.8, animations: { () -> Void in
        self.fingerView.frame = self.finalRect
      }, completion: { (finished) -> Void in
        self.stopTimer()
        self.startTimerGoing(.Backward)
        UIView.animateWithDuration(0.8, animations: { () -> Void in
          self.fingerView.frame = self.startRect
          }, completion: { (finished) -> Void in
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
    if timerControl.minutes < 7 {
      timerControl.minutes += 1
    }
  }

  func updateBackward(timer: NSTimer) {
    if timerControl.minutes > 0 {
      timerControl.minutes -= 1
    }
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
      default:
        break
      }

      NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
  }

  func stopTimer() {
    if timer != nil {
      timer?.invalidate()
      timer = nil
    }
  }

  func refreshTimerForCurrentAlarm() {
    if let existingNotification = LocalNotificationManager.existingNotificationWithAlarmID(self.alarm.alarmID!),
      userinfo = existingNotification.userInfo,
      firedDate = userinfo[ThymeAlarmFireDataKey] as? NSDate,
      numberOfSeconds = userinfo[ThymeAlarmFireInterval] as? NSNumber
    {
      let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
      let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
      let currentSecond = secondsLeft % 60
      var minutesLeft = floor(secondsLeft/60)
      let hoursLeft = floor(minutesLeft/60)

      if hoursLeft > 0 {
        minutesLeft = minutesLeft - (hoursLeft * 60)
      }

      timerControl.title = self.alarm.timerTitle
      timerControl.seconds = Int(currentSecond)
      timerControl.minutes = Int(minutesLeft)
      timerControl.hours = Int(hoursLeft)
      timerControl.touchesAreActive = true

      timerControl.startTimer()
    }
  }

  func kitchenButtonPressed(button: UIButton) {
    if delegate != nil {
      delegate?.dismissedTimerController(self)
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
