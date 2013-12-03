//
//  HYPTimerControl+DrawingMethods.h
//  Thyme
//
//  Created by Elvis Nunez on 03/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPTimerControl.h"

@interface HYPTimerControl (DrawingMethods)

- (void)drawText:(CGContextRef)context rect:(CGRect)rect;
- (void)drawCircle:(CGContextRef)context withColor:(UIColor *)color inRect:(CGRect)rect;
- (void)drawMinutesIndicator:(CGContextRef)context withColor:(UIColor *)color radius:(CGFloat)radius angle:(NSInteger)angle;
- (void)drawSecondsIndicator:(CGContextRef)context withColor:(UIColor *)color andRadius:(CGFloat)radius;
@end
