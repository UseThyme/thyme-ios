//
//  HYPTimerControl.m
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPTimerControl.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HYPExtensions.h"

/** Helper Functions **/
#define ToRad(deg)                 ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)                ( (180.0 * (rad)) / M_PI )
#define SQR(x)                        ( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 60
#define TB_BACKGROUND_WIDTH 60                      //The width of the dark background
#define TB_LINE_WIDTH 40                            //The width of the active area (the gradient) and the width of the handle

@interface HYPTimerControl ()
@property (nonatomic) NSInteger radius;
@property (nonatomic) NSInteger angle;
@end

@implementation HYPTimerControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.radius = self.frame.size.width/2 - TB_SAFEAREA_PADDING;
        self.angle = 360;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor colorFromHexString:@"bcf5e9"] set];
    CGContextFillEllipseInRect(ctx, rect);

    [self drawTheHandle:ctx];
}

/** Draw a white knob over the circle **/
- (void)drawTheHandle:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);

    //I Love shadows
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);

    //Get the handle position
    CGPoint handleCenter =  [self pointFromAngle:self.angle];

    //Draw It!
    [[UIColor colorWithWhite:1.0 alpha:0.7]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, TB_LINE_WIDTH, TB_LINE_WIDTH));

    CGContextRestoreGState(ctx);
}

- (CGPoint)pointFromAngle:(int)angleInt
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);
    CGPoint result;
    result.y = round(centerPoint.y * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x * cos(ToRad(-angleInt)));
    return result;
}

@end
