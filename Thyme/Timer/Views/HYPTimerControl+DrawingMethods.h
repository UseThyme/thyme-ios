#import "HYPTimerControl.h"

@interface HYPTimerControl (DrawingMethods)

- (void)drawText:(CGContextRef)context rect:(CGRect)rect;
- (void)drawCircle:(CGContextRef)context withColor:(UIColor *)color inRect:(CGRect)rect;
- (void)drawMinutesIndicator:(CGContextRef)context withColor:(UIColor *)color radius:(CGFloat)radius angle:(NSInteger)angle containerRect:(CGRect)containerRect;
- (void)drawSecondsIndicator:(CGContextRef)context withColor:(UIColor *)color andRadius:(CGFloat)radius containerRect:(CGRect)containerRect;

@end
