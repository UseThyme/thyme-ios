extension TimerControl {
    func drawCircle(_ context: CGContext, color: UIColor, rect: CGRect) {
        context.saveGState()
        color.set()
        context.fillEllipse(in: rect)
        context.restoreGState()
    }

    func drawCircleOutline(_ context: CGContext, color: UIColor, rect: CGRect, lineWidth: CGFloat) {
        context.saveGState()
        color.set()
        context.setLineWidth(lineWidth)

        var frame = rect
        let offset: CGFloat = completedMode ? 5 : 3
        frame.origin.x = rect.origin.x - offset / 2
        frame.origin.y = rect.origin.x - offset / 2
        frame.size.width = rect.width + offset
        frame.size.height = rect.height + offset

        context.strokeEllipse(in: frame)
        context.restoreGState()
    }

    func drawMinutes(_ context: CGContext, color: UIColor, radius: CGFloat, angle: CGFloat, containerRect: CGRect) {
        context.saveGState()

        let angleTranslation: CGFloat = -90
        let startDeg: CGFloat = DegToRad(angleTranslation)
        let endDeg: CGFloat = DegToRad(angle + angleTranslation)
        let x = containerRect.width / 2 + containerRect.origin.x
        let y = containerRect.width / 2 + containerRect.origin.y

        color.set()

        context.move(to: CGPoint(x: x, y: y))

        let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        context.addArc(center: center, radius: radius, startAngle: startDeg, endAngle: endDeg, clockwise: false)
        context.closePath()
        context.fillPath()
        context.restoreGState()
    }

    func drawSecondsIndicator(_ context: CGContext, color: UIColor, radius: CGFloat, containerRect: CGRect, outlineWidth: CGFloat, outlineColor: UIColor = UIColor.white) {
        let value = CGFloat(seconds) * 6.0
        let circleCenter = pointFromAngle(value, radius: radius, containerRect: containerRect)
        let circleRect = CGRect(x: circleCenter.x - radius / 4, y: circleCenter.y - radius / 4, width: radius * 2, height: radius * 2)
        context.saveGState()

        outlineColor.set()
        context.setLineWidth(outlineWidth)
        context.strokeEllipse(in: circleRect)

        color.set()
        context.fillEllipse(in: circleRect)

        context.restoreGState()
    }

    func drawText(_ context: CGContext, rect: CGRect) {
        HYPDrawText.drawText(context, rect: rect, attributedString: attributedString())
    }

    // MARK: Helper methods

    func pointFromAngle(_ angle: CGFloat, radius: CGFloat, containerRect: CGRect) -> CGPoint {
        let centerPoint = CGPoint(x: frame.width / 2 - radius, y: frame.height / 2 - radius)
        var result = CGPoint(x: 0.0, y: 0.0)

        let angleTranslation: CGFloat = 0 - 90
        let magicFuckingNumber: CGFloat = containerRect.width / 2
        result.x = centerPoint.x + magicFuckingNumber * cos(π * (angle + angleTranslation) / 180)
        result.y = centerPoint.x + magicFuckingNumber * sin(π * (angle + angleTranslation) / 180)

        return result
    }
}
