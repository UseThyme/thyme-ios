#import <Foundation/Foundation.h>

/** Helper Functions **/
#define DegToRad(deg)                 ( (M_PI * (deg)) / 180.0 )
#define RadToDeg(rad)                ( (180.0 * (rad)) / M_PI )
#define SQR(x)                        ( (x) * (x) )

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    result = RadToDeg(atan2(v.x, (flipped ? - v.y : v.y)));
    return (result >= 0 ? result : result + 360.0);
}

@protocol HYPMathHelpers <NSObject>

@end
