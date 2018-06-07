import AVFoundation
import Foundation

open class TimerControl: UIControl, ContentSizeChangable {
    let CircleSizeFactor: CGFloat = 0.8

    var alarm: Alarm?
    var alarmID: String?
    var circleRect: CGRect = CGRect.zero
    var completedMode: Bool
    var lastPoint: CGPoint = CGPoint.zero
    var timer: Timer?
    var title: String = Alarm.messageForSetAlarm()
    var touchesAreActive: Bool = false
    var theme: Themable? {
        didSet {
            if let theme = theme {
                hoursLabel.textColor = theme.textColor
                timerTitleValueLabel.textColor = theme.textColor
                timerSubtitleLabel.textColor = theme.textColor
            }
        }
    }

    var angle: Int = 0 {
        willSet(value) {
            let minute = value / 6
            if completedMode == false && hours > 0 {
                if minute < 10 {
                    timerTitleValueLabel.text = "\(hours):0\(minute)"
                } else {
                    timerTitleValueLabel.text = "\(hours):\(minute)"
                }
            } else {
                timerTitleValueLabel.text = "\(minute)"
                if minute > 0 {
                    timerSubtitleLabel.text = NSLocalizedString("MINUTES LEFT", comment: "MINUTES LEFT")
                } else {
                    timerTitleValueLabel.text = "\(seconds)"
                    timerSubtitleLabel.text = NSLocalizedString("SECONDS LEFT", comment: "SECONDS LEFT")
                }
            }
        }
    }

    var hours: Int = 0 {
        willSet(value) {
            if value == 0 {
                hoursLabel.isHidden = true
            } else {
                hoursLabel.isHidden = false
                hoursLabel.text = value == 1
                    ? NSLocalizedString("\(value) HOUR", comment: "\(value) HOUR")
                    : NSLocalizedString("\(value) HOURS", comment: "\(value) HOURS")
            }
        }
    }

    var minutes: Int = 0 {
        willSet(value) {
            angle = value * 6
            setNeedsDisplay()
        }
    }

    var seconds: Int = 0 {
        willSet(value) {
            if minutes < 1 && hours < 1 && seconds > 0 {
                timerTitleValueLabel.text = "\(seconds - 1)"
                timerSubtitleLabel.text = NSLocalizedString("SECONDS LEFT", comment: "SECONDS LEFT")
            }
        }
    }

    var active: Bool = false {
        willSet(value) {
            timerTitleValueLabel.isHidden = !value
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
        let bounds = UIScreen.main.bounds
        let defaultSize = self.completedMode == true
            ? self.minuteTitleSize
            : self.minuteTitleSize * 1.5

        let fontSize = floor(defaultSize * self.frame.width) / bounds.width
        let font = Font.TimerControl.hoursLabel(fontSize)
        let sampleString = "2 HOURS"
        let attributes = [NSFontAttributeName: font]
        let textSize = (sampleString as NSString).size(attributes: attributes)
        let yOffset: CGFloat = textSize.height / 2
        let x: CGFloat = 0
        let y: CGFloat = self.timerTitleValueLabel.frame.origin.y - yOffset
        let rect = CGRect(x: x, y: y, width: self.frame.width, height: textSize.height)
        let label = UILabel(frame: rect)

        label.backgroundColor = UIColor.clear
        label.font = font
        label.isHidden = true
        label.text = sampleString
        label.textAlignment = .center

        return label
    }()

    lazy var timerTitleValueLabel: UILabel = { [unowned self] in
        let bounds = UIScreen.main.bounds
        let defaultSize = self.completedMode == true
            ? self.minuteValueSize
            : self.minuteValueSize * 0.9

        let fontSize = floor(defaultSize * self.frame.width) / bounds.width
        let font = Font.TimerControl.minutesValueLabel(fontSize)
        let sampleString = "10:00"
        let attributes = [NSFontAttributeName: font]
        let textSize = (sampleString as NSString).size(attributes: attributes)

        var yOffset: CGFloat = self.completedMode
            ? 20 * self.frame.width / bounds.width
            : 0

        let x: CGFloat = 0
        let y: CGFloat = (self.frame.size.height - textSize.height) / 2 - yOffset
        let rect = CGRect(x: x, y: y, width: self.frame.width, height: textSize.height)
        let label = UILabel(frame: rect)

        label.backgroundColor = UIColor.clear
        label.font = font
        label.textAlignment = .center
        label.text = "\(self.angle)"

        return label
    }()

    lazy var timerSubtitleLabel: UILabel = { [unowned self] in
        let bounds = UIScreen.main.bounds
        let defaultSize = self.completedMode == true
            ? self.minuteTitleSize
            : self.minuteTitleSize * 0.9

        let fontSize = floor(defaultSize * self.frame.width) / bounds.width
        let font = Font.TimerControl.minutesTitleLabel(fontSize)
        let minutesLeftText = NSLocalizedString("SECONDS LEFT", comment: "SECONDS LEFT")
        let attributes = [NSFontAttributeName: font]
        let textSize = (minutesLeftText as NSString).size(attributes: attributes)
        let factor: CGFloat = 5
        var yOffset: CGFloat = floor(factor * self.frame.width / bounds.width)

        if Screen.isPad { yOffset -= 10 }

        let x: CGFloat = 0
        let y: CGFloat = self.timerTitleValueLabel.frame.maxY - yOffset
        let rect = CGRect(x: x, y: y, width: self.frame.width, height: textSize.height)
        let label = UILabel(frame: rect)

        label.backgroundColor = UIColor.clear
        label.font = font
        label.text = minutesLeftText
        label.textAlignment = .center

        return label
    }()

    lazy var firstQuadrandRect: CGRect = { [unowned self] in
        let topMargin = self.frame.minX
        let rect = CGRect(x: self.circleRect.minX + self.circleRect.width / 2.0,
                          y: 0 - topMargin,
                          width: self.circleRect.maxX,
                          height: self.circleRect.minY + self.circleRect.height / 2.0 + topMargin)
        return rect
    }()

    lazy var secondQuadrandRect: CGRect = { [unowned self] in
        let topMargin = self.frame.minX
        let rect = CGRect(x: 0.0,
                          y: 0.0 - topMargin,
                          width: self.circleRect.minX + self.circleRect.width / 2.0,
                          height: self.circleRect.minY + self.circleRect.height / 2.0 + topMargin)
        return rect
    }()

    init(frame: CGRect, completedMode: Bool) {
        self.completedMode = completedMode
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        addSubview(timerTitleValueLabel)

        if completedMode {
            for subview in [timerSubtitleLabel, hoursLabel] { addSubview(subview) }
        }

        timerTitleValueLabel.addObserver(self,
                                         forKeyPath: "text",
                                         options: .new,
                                         context: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerControl.contentSizeCategoryDidChange(_:)),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timerTitleValueLabel.removeObserver(self, forKeyPath: "text")
        NotificationCenter.default.removeObserver(self)
        stopTimer()
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (object as! NSObject).isEqual(timerTitleValueLabel) {
            var baseSize: CGFloat
            if timerTitleValueLabel.text!.lengthOfBytes(using: String.Encoding.utf8) == 5 {
                baseSize = Screen.isPad ? 200 : minuteValueSize
            } else if timerTitleValueLabel.text!.lengthOfBytes(using: String.Encoding.utf8) == 4 {
                baseSize = Screen.isPad ? 220 : 100
            } else {
                baseSize = Screen.isPad ? 280 : 120
            }

            if completedMode == true {
                baseSize = Screen.isPad ? 250 : minuteValueSize
            }

            let bounds = UIScreen.main.bounds
            let fontSize = floor(baseSize * frame.width / bounds.width)
            timerTitleValueLabel.font = Font.TimerControl.minutesValueLabel(fontSize)
        }
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        let circleColor = colorForMinutesIndicator()
        let transform = CircleSizeFactor
        let sideMargin = floor(rect.width * (1 - transform) / 2)
        let length = rect.width * transform
        let circleRect = CGRect(x: sideMargin, y: sideMargin, width: length, height: length)
        let lineWidth: CGFloat = completedMode ? 5 : 3.0
        let circleOutlineRect = CGRect(
            x: sideMargin + lineWidth / 2,
            y: sideMargin + lineWidth / 2,
            width: length - lineWidth,
            height: length - lineWidth)

        drawCircle(context!, color: circleColor, rect: circleRect)

        self.circleRect = circleRect

        if active {
            let radius = circleRect.width / 2
            let minutesColor = UIColor.white
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

            if active {
                let secondsColor = UIColor.red
                if let timer = timer, timer.isValid {
                    let factor: CGFloat = completedMode ? 0.15 : 0.2
                    drawSecondsIndicator(context!, color: secondsColor, radius: sideMargin * factor, containerRect: circleRect, outlineWidth: lineWidth, outlineColor: theme.circleOutlineActive)
                }

                if completedMode { drawText(context!, rect: rect) }
            } else {
                let secondsColor = UIColor.white
                drawSecondsIndicator(context!, color: secondsColor, radius: sideMargin * 0.2, containerRect: circleRect, outlineWidth: 0, outlineColor: theme.circleOutlineActive)
            }
        }
    }

    func attributedString() -> NSAttributedString {
        let font: UIFont = Font.TimerControl.arcText

        var attributes = [String: AnyObject]()
        if let theme = theme {
            attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: theme.labelColor]
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
            UIColor(cgColor: topColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            alpha = CGFloat(angle) / 360.0 + 0.25
        }

        if let theme = theme, active {
            color = hours > 0 ? theme.circleActiveHours : theme.circleActive
        } else if let theme = theme {
            color = theme.circleInactive
        } else {
            color = unactiveCircleColor
        }

        return color
    }

    func shouldBlockTouchesForPoint(_ currentPoint: CGPoint) -> Bool {
        let xBlockCoordinate = frame.width / 2
        let pointBelongsToFirstHalfOfTheScreen = currentPoint.x < xBlockCoordinate
        let lastPointIsZero: Bool = lastPoint.equalTo(CGPoint.zero)
        let lastPointWasInFirstQuadrand: Bool = firstQuadrandRect.contains(lastPoint)

        if hours < 1 && pointBelongsToFirstHalfOfTheScreen == true &&
            lastPointIsZero == false &&
            lastPointWasInFirstQuadrand == true {
            return true
        }

        return false
    }

    func handleTouchesForPoint(_ currentPoint: CGPoint) {
        evaluateMinutesUsingPoint(currentPoint)
        lastPoint = currentPoint
        sendActions(for: .valueChanged)
    }

    func pointIsInFirstQuadrand(_ point: CGPoint) -> Bool {
        let currentPointIsInFirstQuadrand = firstQuadrandRect.contains(point)
        let lastPointWasInFirstQuadrand = firstQuadrandRect.contains(lastPoint)
        let lastPointIsZero = lastPoint.equalTo(CGPoint.zero)

        if currentPointIsInFirstQuadrand == true &&
            lastPointIsZero == false &&
            lastPointWasInFirstQuadrand == true {
            return true
        }

        return false
    }

    func pointIsComingFromSecondQuadrand(_ point: CGPoint) -> Bool {
        let currentPointIsInFirstQuadrand = firstQuadrandRect.contains(point)
        let lastPointWasInSecondQuadrand = secondQuadrandRect.contains(lastPoint)
        let lastPointIsZero = lastPoint.equalTo(CGPoint.zero)

        if currentPointIsInFirstQuadrand == true &&
            lastPointIsZero == false &&
            lastPointWasInSecondQuadrand == true {
            return true
        }

        return false
    }

    func pointIsComingFromFirstQuadrand(_ point: CGPoint) -> Bool {
        let currentPointIsInSecondQuadrand = secondQuadrandRect.contains(point)
        let lastPointWasInFirstQuadrand = firstQuadrandRect.contains(lastPoint)
        let lastPointIsZero = lastPoint.equalTo(CGPoint.zero)

        if currentPointIsInSecondQuadrand == true &&
            lastPointIsZero == false &&
            lastPointWasInFirstQuadrand == true {
            return true
        }

        return false
    }

    func startAlarm() {
        let numberOfSeconds = angle / 6 * 60 + hours * 3600
        handleNotificationWithNumberOfSeconds(TimeInterval(numberOfSeconds))
        if alarm != nil { title = alarm!.timerTitle }
        setNeedsDisplay()
    }

    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(TimerControl.updateSeconds(_:)),
                                         userInfo: nil,
                                         repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
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
        timerSubtitleLabel.text = NSLocalizedString("SECONDS LEFT", comment: "SECONDS LEFT")
        sendActions(for: .valueChanged)
    }

    func updateSeconds(_ timer: Timer) {
        seconds -= 1
        if seconds < 0 {
            angle = minutes - 1 * 6
            seconds = 59
            minutes -= 1

            if minutes < 0 && hours > 0 {
                minutes = 59
                hours -= 1
            }

            sendActions(for: .valueChanged)
        }

        if seconds == 0 && minutes == 0 && hours == 0 {
            restartTimer()
            title = Alarm.messageForSetAlarm()
            stopTimer()
        }

        if minutes == -1 { restartTimer() }

        setNeedsDisplay()
    }

    func evaluateMinutesUsingPoint(_ currentPoint: CGPoint) {
        let centerPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
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

    func handleNotificationWithNumberOfSeconds(_ numberOfSeconds: TimeInterval) {
        if numberOfSeconds > 0 {
            createNotificationUsingNumberOfSeconds(numberOfSeconds)
        } else {
            AlarmCenter.cancelNotification(alarmID!)
        }
    }

    func createNotificationUsingNumberOfSeconds(_ numberOfSeconds: TimeInterval) {
        seconds = 0
        startTimer()

        AlarmCenter.scheduleNotification(alarmID!,
                                         seconds: numberOfSeconds,
                                         message: NSLocalizedString("\(alarm!.title) just finished", comment: ""))
    }

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)

        title = Alarm.messageForReleaseToSetAlarm()
        stopTimer()
        return true
    }

    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let currentPoint = touch.location(in: self)

        if touchesAreActive == true {
            if hours < 1 && shouldBlockTouchesForPoint(currentPoint) == true {
                touchesAreActive = false
                angle = 0
                seconds = 0
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

    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)

        let currentPoint = touch!.location(in: self)

        if (pointIsComingFromFirstQuadrand(currentPoint) && hours == 0) ||
            (angle == 0 && hours == 0) ||
            (minutes == 0 && hours == 0) {
            angle = 0
            touchesAreActive = false
            title = Alarm.messageForSetAlarm()
            AlarmCenter.cancelNotification(alarmID!)
            setNeedsDisplay()
        } else {
            // add delay
            startAlarm()
        }

        lastPoint = CGPoint.zero
    }

    func contentSizeCategoryDidChange(_ notification: Notification) {
        let defaultTitleSize = completedMode == true
            ? minuteTitleSize
            : minuteTitleSize * 1.5
        let defaultValueSize = completedMode == true
            ? minuteValueSize
            : minuteValueSize * 0.9
        let fontSize = floor(defaultTitleSize * frame.width) / bounds.width
        let fontValueSize = floor(defaultValueSize * frame.width) / bounds.width

        hoursLabel.font = Font.TimerControl.hoursLabel(fontSize)
        timerSubtitleLabel.font = Font.TimerControl.minutesTitleLabel(fontSize)
        timerTitleValueLabel.font = Font.TimerControl.minutesValueLabel(fontValueSize)
        setNeedsDisplay()
    }
}
