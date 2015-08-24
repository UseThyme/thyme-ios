//
//  Math.swift
//  Thyme
//
//  Created by Christoffer Winterkvist on 8/24/15.
//  Copyright (c) 2015 Hyper. All rights reserved.
//

let π = CGFloat(M_PI)

func RadToDeg(rad: CGFloat) -> CGFloat {
  return (180.0 * rad) / π
}

func DegToRad(deg: CGFloat) -> CGFloat {
  return (π * deg) / 180.0
}

func SQR(x: CGFloat) -> CGFloat {
  return x * x
}

func AngleFromNorth(p1: CGPoint, p2: CGPoint, flipped: Bool) -> Float {
  var v = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
  let vmag = sqrt(SQR(v.x) + SQR(v.y))

  var result = RadToDeg(CGFloat(atan2f(Float(v.x), flipped
    ? Float(-v.y)
    : Float(v.y)))
  )
  return Float(result >= 0 ? result : result + 360.0)
}
