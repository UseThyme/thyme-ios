//
//  TimerControl+Draw.swift
//  Thyme
//
//  Created by Christoffer Winterkvist on 8/24/15.
//  Copyright (c) 2015 Hyper. All rights reserved.
//

extension TimerControl {

  func drawCircle(context: CGContextRef, color: UIColor, rect: CGRect) {
    CGContextSaveGState(context)
    color.set()
    CGContextFillEllipseInRect(context, rect)
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
    var t0 = CGContextGetCTM(context)
    let xScaleFactor = t0.a > 0 ? t0.a : 0-t0.a
    let yScaleFactor = t0.a > 0 ? t0.d : 0-t0.d
    t0 = CGAffineTransformInvert(t0)

    if xScaleFactor != 1.0 || yScaleFactor != 1.0 {
      t0 = CGAffineTransformScale(t0, xScaleFactor, yScaleFactor)
    }

    CGContextConcatCTM(context, t0)
    CGContextSetTextMatrix(context, CGAffineTransformIdentity)
    let line = CTLineCreateWithAttributedString(attributedString)


    let glyphCount = CTLineGetGlyphCount(line)
    if glyphCount == 0 {
      return
    }

    struct GlyphArcInfo {
      var width: CGFloat
      var angle: CGFloat
    }
  }
}
