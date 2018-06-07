let π = CGFloat(M_PI)

func RadToDeg(_ rad: CGFloat) -> CGFloat {
    return (180.0 * rad) / π
}

func DegToRad(_ deg: CGFloat) -> CGFloat {
    return (π * deg) / 180.0
}

func SQR(_ x: CGFloat) -> CGFloat {
    return x * x
}

func AngleFromNorth(_ p1: CGPoint, p2: CGPoint, flipped: Bool) -> Float {
    let v = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)

    let result = RadToDeg(CGFloat(atan2f(Float(v.x), flipped
            ? Float(-v.y)
            : Float(v.y)))
    )
    return Float(result >= 0 ? result : result + 360.0)
}
