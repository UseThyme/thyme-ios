import Foundation
import AVFoundation

public class TimerControl: UIControl, ContentSizeChangable {

  let CircleSizeFactor: CGFloat = 0.8

  var alarm: Alarm?
  var alarmID: String?
  var circleRect: CGRect = CGRectZero
  var completedMode: Bool
  var lastPoint: CGPoint = CGPointZero
  var seconds: Int = 0
  var timer: NSTimer?
  var title: String = Alarm.messageForSetAlarm()
  var touchesAreActive: Bool = false
  var theme: Themable? {
    didSet {
      if let theme = theme {
        hoursLabel.textColor = theme.textColor
        minutesValueLabel.textColor = theme.textColor
        minutesTitleLabel.textColor = theme.textColor
      }
    }
  }

  lazy var player: AVAudioPlayer? = {
    let soundFilePath = NSBundle.mainBundle().pathForResource("tick", ofType: "wav")!
    let url = NSURL(fileURLWithPath: soundFilePath)
    
    var player: AVAudioPlayer?
    do { try player = AVAudioPlayer(contentsOfURL: url) } catch {}

    return player
    }()

  var angle: Int = 0 {
    willSet(value) {
      let minute = value/6
      if completedMode == false && hours > 0 {
        if minute < 10 {
          minutesValueLabel.text = "\(hours):0\(minute)"
        } else {
          minutesValueLabel.text = "\(hours):\(minute)"
        }
      } else {
        minutesValueLabel.text = "\(minute)"
      }
    }
  }

  var hours: Int = 0 {
    willSet(value) {
      if value == 0 {
        hoursLabel.hidden = true
      } else {
        hoursLabel.hidden = false
        hoursLabel.text = value == 1
          ? NSLocalizedString("\(value) HOUR", comment: "\(value) HOUR")
          : NSLocalizedString("\(value) HOURS", comment: "\(value) HOURS")
      }
    }
  }

  var minutes: Int = 0 {
    willSet(value) {
      if minutes != value && touchesAreActive == true {
        playInputClick()
      }

      angle = value * 6
      setNeedsDisplay()
    }
  }

  var active: Bool = false {
    willSet(value) {
      minutesValueLabel.hidden = !value
      angle = 0
      setNeedsDisplay()
    }
  }

  lazy var minuteValueSize: CGFloat = {
    return Screen.isPad ? 200 : 95
    }()

  lazy var minuteTitleSize: CGFloat = {
    return Screen.isPad ? 35 : 14
    }()

  lazy var hoursLabel: UILabel = { [unowned self] in
    let bounds = UIScreen.mainScreen().bounds
    let defaultSize = self.completedMode == true
      ? self.minuteTitleSize
      : self.minuteTitleSize * 1.5

    let fontSize = floor(defaultSize * CGRectGetWidth(self.frame)) / CGRectGetWidth(bounds)
    let font = Font.TimerControl.hoursLabel(fontSize)
    let sampleString = "2 HOURS"
    let attributes = [NSFontAttributeName : font]
    let textSize = (sampleString as NSString).sizeWithAttributes(attributes)
    let yOffset: CGFloat = self.minutesValueLabel.frame.origin.y - 8
    let x: CGFloat = 0
    let y: CGFloat = self.frame.size.height - textSize.height / 2 - yOffset
    let rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height)
    let label = UILabel(frame: rect)

    label.backgroundColor = UIColor.clearColor()
    label.font = font
    label.hidden = true
    label.text = sampleString
    label.textAlignment = .Center

    return label
    }()

  lazy var minutesValueLabel: UILabel = { [unowned self] in
    let bounds = UIScreen.mainScreen().bounds
    let defaultSize = self.completedMode == true
      ? self.minuteValueSize
      : self.minuteValueSize * 0.9

    let fontSize = floor(defaultSize * CGRectGetWidth(self.frame)) / CGRectGetWidth(bounds)
    let font = Font.TimerControl.minutesValueLabel(fontSize)
    let sampleString = "10:00"
    let attributes = [NSFontAttributeName : font]
    let textSize = (sampleString as NSString).sizeWithAttributes(attributes)

    var yOffset: CGFloat = self.completedMode
      ? 20 * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds)
      : 0

    let x: CGFloat = 0
    let y: CGFloat = (self.frame.size.height - textSize.height) / 2 - yOffset
    let rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height)
    let label = UILabel(frame: rect)

    label.backgroundColor = UIColor.clearColor()
    label.font = font
    label.textAlignment = .Center
    label.text = "\(self.angle)"

    return label
    }()

  lazy var minutesTitleLabel: UILabel = { [unowned self] in
    let bounds = UIScreen.mainScreen().bounds
    let defaultSize = self.completedMode == true
      ? self.minuteTitleSize
      : self.minuteTitleSize * 0.9

    let fontSize = floor(defaultSize * CGRectGetWidth(self.frame)) / CGRectGetWidth(bounds)
    let font = Font.TimerControl.minutesTitleLabel(fontSize)
    let minutesLeftText = NSLocalizedString("MINUTES LEFT", comment: "MINUTES LEFT")
    let attributes = [NSFontAttributeName : font]
    let textSize = (minutesLeftText as NSString).sizeWithAttributes(attributes)
    let factor: CGFloat = 5
    var yOffset: CGFloat = floor(factor * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds))

    if Screen.isPad { yOffset -= 10 }

    let x: CGFloat = 0
    let y: CGFloat = CGRectGetMaxY(self.minutesValueLabel.frame) - yOffset
    let rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height)
    let label = UILabel(frame: rect)

    label.backgroundColor = UIColor.clearColor()
    label.font = font
    label.text = minutesLeftText
    label.textAlignment = .Center

    return label
    }()

  lazy var firstQuadrandRect: CGRect = { [unowned self] in
    let topMargin = CGRectGetMinX(self.frame)
    let rect = CGRectMake(CGRectGetMinX(self.circleRect) + CGRectGetWidth(self.circleRect) / 2.0,
      0 - topMargin,
      CGRectGetMaxX(self.circleRect),
      CGRectGetMinY(self.circleRect) + CGRectGetHeight(self.circleRect) / 2.0 + topMargin)
    return rect
    }()

  lazy var secondQuadrandRect: CGRect = { [unowned self] in
    let topMargin = CGRectGetMinX(self.frame)
    let rect = CGRectMake(0.0,
      0.0 - topMargin,
      CGRectGetMinX(self.circleRect) + CGRectGetWidth(self.circleRect) / 2.0,
      CGRectGetMinY(self.circleRect) + CGRectGetHeight(self.circleRect) / 2.0 + topMargin)
    return rect
    }()

  init(frame: CGRect, completedMode: Bool) {
    self.completedMode = completedMode
    super.init(frame: frame)

    backgroundColor = UIColor.clearColor()
    addSubview(minutesValueLabel)

    if completedMode {
      for subview in [minutesTitleLabel, hoursLabel] { addSubview(subview) }
    }

    minutesValueLabel.addObserver(self,
      forKeyPath: "text",
      options: .New,
      context: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "contentSizeCategoryDidChange:",
      name: UIContentSizeCategoryDidChangeNotification,
      object: nil)
  }

  required public init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    minutesValueLabel.removeObserver(self, forKeyPath: "text")
    NSNotificationCenter.defaultCenter().removeObserver(self)
    stopTimer()
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if (object as! NSObject).isEqual(minutesValueLabel) {
      var baseSize: CGFloat
      if minutesValueLabel.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 5 {
        baseSize = Screen.isPad ? 200 : minuteValueSize
      } else if minutesValueLabel.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 4 {
        baseSize = Screen.isPad ? 220 : 100
      } else {
        baseSize = Screen.isPad ? 280 : 120
      }

      if self.completedMode == true {
        baseSize = Screen.isPad ? 250 : minuteValueSize
      }

      let bounds = UIScreen.mainScreen().bounds
      let fontSize = floor(baseSize * CGRectGetWidth(frame) / CGRectGetWidth(bounds))
      minutesValueLabel.font = Font.TimerControl.minutesValueLabel(fontSize)
    }
  }

  override public func drawRect(rect: CGRect) {
    super.drawRect(rect)

    let context = UIGraphicsGetCurrentContext()
    let circleColor = colorForMinutesIndicator()
    let transform = CircleSizeFactor
    let sideMargin = floor(CGRectGetWidth(rect) * (1 - transform) / 2)
    let length = CGRectGetWidth(rect) * transform
    let circleRect = CGRectMake(sideMargin, sideMargin, length, length)
    let lineWidth: CGFloat = completedMode ? 5 : 3.5
    let circleOutlineRect = CGRect(
      x: sideMargin + lineWidth / 2,
      y: sideMargin + lineWidth / 2,
      width: length - lineWidth,
      height: length - lineWidth)

    drawCircle(context!, color: circleColor, rect: circleRect)

    self.circleRect = circleRect

    if active {
      let radius = CGRectGetWidth(circleRect) / 2
      let minutesColor = UIColor.whiteColor()
      drawMinutes(context!,
        color: minutesColor,
        radius: radius,
        angle: CGFloat(angle),
        containerRect: circleRect)
    }

    if let theme = theme {
      drawCircleOutline(context!,
        color: active ? theme.circleOutlineActive : theme.circleOutlineInactive,
        rect: circleOutlineRect,
        lineWidth: lineWidth)
    }

    if active {
      let secondsColor = UIColor.redColor()
      if let timer = timer where timer.valid {
        let factor: CGFloat = completedMode ? 0.1 : 0.2
        drawSecondsIndicator(context!, color: secondsColor, radius: sideMargin * factor, containerRect: circleRect)
      }

      if completedMode { drawText(context!, rect: rect) }
    } else {
      let secondsColor = UIColor.whiteColor()
      drawSecondsIndicator(context!, color: secondsColor, radius: sideMargin * 0.2, containerRect: circleRect)
    }
  }

  func attributedString() -> NSAttributedString {
    let font: UIFont = Font.TimerControl.arcText

    var attributes = [String : AnyObject]()
    if let theme = theme {
      attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: theme.labelColor]
    }
    let string = NSAttributedString(string: title, attributes: attributes)

    return string
  }

  func colorForMinutesIndicator() -> UIColor {
    let color: UIColor
    let unactiveCircleColor = UIColor(white: 1.0, alpha: 0.4)

    if let topColor = theme?.colors.first {
      var red: CGFloat = 0
      var blue: CGFloat = 0
      var green: CGFloat = 0
      var alpha: CGFloat = 0
      UIColor(CGColor: topColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      alpha = CGFloat(angle)/360.0 + 0.25
    }

    if let theme = theme where active {
      color = hours > 0 ? theme.circleActiveHours : theme.circleActive
    } else if let theme = theme {
      color = theme.circleInactive
    } else {
      color = unactiveCircleColor
    }

    return color
  }

  func shouldBlockTouchesForPoint(currentPoint: CGPoint) -> Bool {
    let xBlockCoordinate = CGRectGetWidth(frame) / 2
    let pointBelongsToFirstHalfOfTheScreen = currentPoint.x < xBlockCoordinate
    let lastPointIsZero: Bool = CGPointEqualToPoint(lastPoint, CGPointZero)
    let lastPointWasInFirstQuadrand: Bool = CGRectContainsPoint(self.firstQuadrandRect, lastPoint)

    if hours < 1 && pointBelongsToFirstHalfOfTheScreen == true &&
      lastPointIsZero == false &&
      lastPointWasInFirstQuadrand == true {
        return true
    }

    return false
  }

  func handleTouchesForPoint(currentPoint: CGPoint) {
    evaluateMinutesUsingPoint(currentPoint)
    lastPoint = currentPoint
    sendActionsForControlEvents(.ValueChanged)
  }

  func pointIsInFirstQuadrand(point: CGPoint) -> Bool {
    let currentPointIsInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, point)
    let lastPointWasInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, lastPoint)
    let lastPointIsZero = CGPointEqualToPoint(lastPoint, CGPointZero)

    if currentPointIsInFirstQuadrand == true &&
      lastPointIsZero == false &&
      lastPointWasInFirstQuadrand == true {
        return true
    }

    return false
  }

  func pointIsComingFromSecondQuadrand(point: CGPoint) -> Bool {
    let currentPointIsInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, point)
    let lastPointWasInSecondQuadrand = CGRectContainsPoint(secondQuadrandRect, lastPoint)
    let lastPointIsZero = CGPointEqualToPoint(lastPoint, CGPointZero)

    if currentPointIsInFirstQuadrand == true &&
      lastPointIsZero == false &&
      lastPointWasInSecondQuadrand == true {
        return true
    }

    return false
  }

  func pointIsComingFromFirstQuadrand(point: CGPoint) -> Bool {
    let currentPointIsInSecondQuadrand = CGRectContainsPoint(secondQuadrandRect, point)
    let lastPointWasInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, lastPoint)
    let lastPointIsZero = CGPointEqualToPoint(lastPoint, CGPointZero)

    if currentPointIsInSecondQuadrand == true &&
      lastPointIsZero == false &&
      lastPointWasInFirstQuadrand == true {
        return true
    }

    return false
  }

  func playInputClick() {
    player!.prepareToPlay()
    player!.play()
  }

  func startAlarm() {
    let numberOfSeconds = angle / 6 * 60 + hours * 3600
    handleNotificationWithNumberOfSeconds(NSTimeInterval(numberOfSeconds))
    if alarm != nil { title = alarm!.timerTitle }
    setNeedsDisplay()
  }

  func startTimer() {
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(1,
        target: self,
        selector: "updateSeconds:",
        userInfo: nil,
        repeats: true)
      NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  func restartTimer() {
    angle = 0
    hours = 0
    minutes = 0
    seconds = 0
    sendActionsForControlEvents(.ValueChanged)
  }

  func updateSeconds(timer: NSTimer) {
    seconds -= 1
    if seconds < 0 {
      angle = minutes - 1 * 6
      seconds = 59
      minutes -= 1

      if minutes < 0 && hours > 0 {
        minutes = 59
        hours -= 1
      }

      sendActionsForControlEvents(.ValueChanged)
    }

    if seconds == 0 && minutes == 0 && hours == 0 {
      restartTimer()
      title = Alarm.messageForSetAlarm()
      stopTimer()
    }

    if minutes == -1 { restartTimer() }

    setNeedsDisplay()
  }

  func evaluateMinutesUsingPoint(currentPoint: CGPoint) {
    let centerPoint = CGPointMake(frame.width / 2, frame.height / 2)
    let currentAngle: Float = AngleFromNorth(centerPoint, p2: currentPoint, flipped: true)
    let angle = floor(currentAngle)

    if pointIsComingFromSecondQuadrand(currentPoint) == true {
      hours += 1
    } else if hours > 0 && pointIsComingFromFirstQuadrand(currentPoint) == true {
      hours -= 1
    }

    minutes = Int(angle) / 6
    self.angle = Int(angle)
    setNeedsDisplay()
  }

  func cancelCurrentLocalNotification() {
    AlarmCenter.cleanUpNotification(alarmID!)
  }

  func handleNotificationWithNumberOfSeconds(numberOfSeconds: NSTimeInterval) {
    cancelCurrentLocalNotification()
    if numberOfSeconds > 0 {
      createNotificationUsingNumberOfSeconds(numberOfSeconds)
    }
  }

  func createNotificationUsingNumberOfSeconds(numberOfSeconds: NSTimeInterval) {
    seconds = 0
    startTimer()

    AlarmCenter.scheduleNotification(alarmID!,
      seconds: numberOfSeconds,
      message: NSLocalizedString("\(alarm!.title) just finished", comment: ""))
  }

  override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    super.beginTrackingWithTouch(touch, withEvent: event)

    title = Alarm.messageForReleaseToSetAlarm()
    stopTimer()
    return true
  }

  override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    super.continueTrackingWithTouch(touch, withEvent: event)
    let currentPoint = touch.locationInView(self)

    if touchesAreActive == true {
      if hours < 1 && shouldBlockTouchesForPoint(currentPoint) == true {
        touchesAreActive = false
        angle = 0
        setNeedsDisplay()
        return true
      } else {
        handleTouchesForPoint(currentPoint)
      }
    } else if pointIsComingFromSecondQuadrand(currentPoint) == true
      || pointIsInFirstQuadrand(currentPoint) == true {
        touchesAreActive = true
    }

    lastPoint = currentPoint

    return true
  }

  public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
    super.endTrackingWithTouch(touch, withEvent: event)

    let currentPoint = touch!.locationInView(self)

    if (pointIsComingFromFirstQuadrand(currentPoint) && hours == 0) ||
      (angle == 0 && hours == 0) ||
      (minutes == 0 && hours == 0) {
        angle = 0
        touchesAreActive = false
        title = Alarm.messageForSetAlarm()
        cancelCurrentLocalNotification()
        setNeedsDisplay()
    } else {
      // add delay
      startAlarm()
    }

    lastPoint = CGPointZero
  }

  func contentSizeCategoryDidChange(notification: NSNotification) {
    let defaultTitleSize = completedMode == true
      ? minuteTitleSize
      : minuteTitleSize * 1.5
    let defaultValueSize = self.completedMode == true
      ? self.minuteValueSize
      : self.minuteValueSize * 0.9
    let fontSize = floor(defaultTitleSize * CGRectGetWidth(frame)) / CGRectGetWidth(bounds)
    let fontValueSize = floor(defaultValueSize * CGRectGetWidth(frame)) / CGRectGetWidth(bounds)

    hoursLabel.font = Font.TimerControl.hoursLabel(fontSize)
    minutesTitleLabel.font = Font.TimerControl.minutesTitleLabel(fontSize)
    minutesValueLabel.font = Font.TimerControl.minutesValueLabel(fontValueSize)
    setNeedsDisplay()
  }
}
