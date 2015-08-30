extension TimerControl {

  func drawCircle(context: CGContextRef, color: UIColor, rect: CGRect) {
    CGContextSaveGState(context)
    color.set()
    CGContextFillEllipseInRect(context, rect)
    CGContextRestoreGState(context)
  }

  func drawCircleOutline(context: CGContextRef, color: UIColor, rect: CGRect, lineWidth: CGFloat) {
    CGContextSaveGState(context)
    color.set()
    CGContextSetLineWidth(context, lineWidth)
    CGContextStrokeEllipseInRect(context, rect)
    CGContextRestoreGState(context)
  }

  func drawMinutes(context: CGContextRef, color: UIColor, radius: CGFloat, angle: CGFloat, containerRect: CGRect) {
    CGContextSaveGState(context)

    let angleTranslation: CGFloat = 0 - 90
    let startDeg: CGFloat = π * (0 + angleTranslation) / 180
    let endDeg: CGFloat = π * (angle + angleTranslation) / 180
    let x = CGRectGetWidth(containerRect) / 2 + containerRect.origin.x
    let y = CGRectGetWidth(containerRect) / 2 + containerRect.origin.y

    color.set()

    CGContextMoveToPoint(context, x, y)
    CGContextAddArc(context, x, y, radius, startDeg, endDeg, 0)
    CGContextClosePath(context)
    CGContextFillPath(context)
    CGContextRestoreGState(context)
  }

  func drawSecondsIndicator(context: CGContextRef, color: UIColor, radius: CGFloat, containerRect: CGRect) {
    let value = CGFloat(seconds) * 6.0
    let circleCenter = pointFromAngle(value, radius: radius, containerRect: containerRect)
    let circleRect = CGRectMake(circleCenter.x, circleCenter.y, radius * 2, radius * 2)
    CGContextSaveGState(context)
    color.set()
    CGContextFillEllipseInRect(context, circleRect)
    CGContextRestoreGState(context)
  }

  func drawText(context: CGContextRef, rect: CGRect) {
    HYPDrawText.drawText(context, rect: rect, attributedString: attributedString())
  }

  // MARK: Helper methods

  func pointFromAngle(angle: CGFloat, radius: CGFloat, containerRect: CGRect)  -> CGPoint {
    let centerPoint = CGPointMake(CGRectGetWidth(frame) / 2 - radius, CGRectGetHeight(frame) / 2 - radius)
    var result = CGPointMake(0.0,0.0)

    let angleTranslation: CGFloat = 0 - 90
    let magicFuckingNumber: CGFloat = CGRectGetWidth(containerRect) / 2
    result.x = centerPoint.x + magicFuckingNumber * cos(π * (angle + angleTranslation) / 180)
    result.y = centerPoint.x + magicFuckingNumber * sin(π * (angle + angleTranslation) / 180)

    return result
  }
}