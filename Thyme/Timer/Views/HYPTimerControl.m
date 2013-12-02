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
#import "HYPUtils.h"
#import "HYPAlarm.h"
#import "HYPLocalNotificationManager.h"

/** Helper Functions **/
#define DegToRad(deg)                 ( (M_PI * (deg)) / 180.0 )
#define RadToDeg(rad)                ( (180.0 * (rad)) / M_PI )
#define SQR(x)                        ( (x) * (x) )

/** Parameters **/
#define CIRCLE_COLOR [UIColor colorFromHexString:@"bcf5e9"]
#define CIRCLE_SIZE_FACTOR 0.8f
#define KNOB_COLOR [UIColor colorFromHexString:@"ff5c5c"]
#define ALARM_ID @"THYME_ALARM_ID_0"

@interface HYPTimerControl ()
@property (nonatomic, strong) UILabel *minutesValueLabel;
@property (nonatomic, strong) UILabel *minutesTitleLabel;
@property (nonatomic) NSInteger angle;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation HYPTimerControl

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    result = RadToDeg(atan2(v.x, (flipped ? - v.y : v.y)));
    return (result >= 0 ? result : result + 360.0);
}

- (UILabel *)minutesValueLabel
{
    if (!_minutesValueLabel) {
        //Define the Font
        UIFont *font = [HYPUtils helveticaNeueUltraLightWithSize:95.0f];
        NSString *sampleString = @"000";
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGSize fontSize = [sampleString sizeWithAttributes:attributes];
        CGFloat x = 0;
        CGFloat y = (self.frame.size.height - fontSize.height) / 2 - 20.0f;
        CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), fontSize.height);
        _minutesValueLabel = [[UILabel alloc] initWithFrame:rect];
        _minutesValueLabel.backgroundColor = [UIColor clearColor];
        _minutesValueLabel.textColor = [UIColor colorFromHexString:@"30cec6"];
        _minutesValueLabel.textAlignment = NSTextAlignmentCenter;
        _minutesValueLabel.font = font;
        _minutesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.angle];
    }
    return _minutesValueLabel;
}

- (UILabel *)minutesTitleLabel
{
    if (!_minutesTitleLabel) {
        //Define the Font
        UIFont *font = [HYPUtils avenirLightWithSize:14.0f];
        NSString *sampleString = @"MINUTES LEFT";
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGSize fontSize = [sampleString sizeWithAttributes:attributes];
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.minutesValueLabel.frame) - 5.0f;
        CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), fontSize.height);
        _minutesTitleLabel = [[UILabel alloc] initWithFrame:rect];
        _minutesTitleLabel.backgroundColor = [UIColor clearColor];
        _minutesTitleLabel.textColor = [UIColor colorFromHexString:@"30cec6"];
        _minutesTitleLabel.textAlignment = NSTextAlignmentCenter;
        _minutesTitleLabel.font = font;
        _minutesTitleLabel.text = @"MINUTES LEFT";
    }
    return _minutesTitleLabel;
}

- (void)setAngle:(NSInteger)angle
{
    _angle = angle;
    self.minutesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.angle/6];
}

- (void)setMinutesLeft:(NSTimeInterval)minutesLeft
{
    _minutesLeft = minutesLeft;
    self.angle = minutesLeft * 6;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.angle = 0;
        [self addSubview:self.minutesValueLabel];
        [self addSubview:self.minutesTitleLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat transform = CIRCLE_SIZE_FACTOR;
    CGFloat sideMargin = floor(CGRectGetWidth(rect) * (1.0f - transform) / 2);
    CGFloat length = CGRectGetWidth(rect) * transform;
    CGRect circleRect = CGRectMake(sideMargin, sideMargin, length, length);
    [self drawCircle:context withColor:CIRCLE_COLOR inRect:circleRect];

    CGFloat radius = CGRectGetWidth(circleRect) / 2;
    [self drawMinutesIndicator:context withColor:[UIColor whiteColor] radius:radius];

    UIColor *secondsColor = KNOB_COLOR;
    if (self.timer && [self.timer isValid]) {
        [self drawSecondsIndicator:context withColor:secondsColor andRadius:sideMargin * 0.2];
    }
}

- (void)drawCircle:(CGContextRef)context withColor:(UIColor *)color inRect:(CGRect)rect
{
    CGContextSaveGState(context);

    [color set];
    CGContextFillEllipseInRect(context, rect);

    CGContextRestoreGState(context);
}

- (void)drawMinutesIndicator:(CGContextRef)context withColor:(UIColor *)color radius:(CGFloat)radius
{
    CGContextSaveGState(context);

    NSInteger angleTranslation = -90;
    CGFloat startDeg = DegToRad(0 + angleTranslation);
    CGFloat endDeg = DegToRad(self.angle + angleTranslation);
    CGFloat x = 159;
    CGFloat y = 159;

    [color set];
    CGContextMoveToPoint(context, x, y);
    CGContextAddArc(context, x, y, radius, startDeg, endDeg, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextRestoreGState(context);
}

- (void)drawSecondsIndicator:(CGContextRef)context withColor:(UIColor *)color andRadius:(CGFloat)radius
{
    CGContextSaveGState(context);

    [color set];
    CGFloat value = (60 - self.seconds) * 6;
    CGPoint circleCenter =  [self pointFromAngle:value usingRadius:radius];
    CGRect circleRect = CGRectMake(circleCenter.x, circleCenter.y, radius * 2, radius * 2);
    CGContextFillEllipseInRect(context, circleRect);

    CGContextRestoreGState(context);
}

// Magic function (not really)
- (CGPoint)pointFromAngle:(NSInteger)angle usingRadius:(CGFloat)radius
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2 - radius, self.frame.size.height / 2 - radius);
    CGPoint result;
    NSInteger angleTranslation = -90;
    NSInteger magicFuckingNumber = 130;
    result.x = round(centerPoint.x + magicFuckingNumber * cos(DegToRad(angle+angleTranslation)));
    result.y = round(centerPoint.y + magicFuckingNumber * sin(DegToRad(angle+angleTranslation)));
    return result;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    [self stopTimer];
    [self setNeedsDisplay];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint = [touch locationInView:self];
    [self evaluateMinutesUsingPoint:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)evaluateMinutesUsingPoint:(CGPoint)lastPoint
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);

    //Calculate the direction from the center point to an arbitrary position.
    CGFloat currentAngle = AngleFromNorth(centerPoint, lastPoint, YES);
    NSInteger angle = floor(currentAngle);
    self.angle = angle;
    self.minutesLeft = self.angle / 6;
    [self setNeedsDisplay];
    // Draw chart
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self performSelector:@selector(startAlarm) withObject:nil afterDelay:1.0];
}

- (void)startAlarm
{
    NSInteger numberOfSeconds = (self.angle / 6) * 60;
    [self handleNotificationWithNumberOfSeconds:numberOfSeconds];
}

- (void)updateSeconds:(NSTimer *)timer
{
    self.seconds += 1;
    if (self.seconds >= 60) {
        self.angle = (self.minutesLeft - 1) * 6;
        self.seconds = 0;
    }

    if (self.minutesLeft == 0 && self.seconds == 59) {
        self.angle = 0;
        self.seconds = 0;
        self.minutesLeft = 0;
        [self stopTimer];
    }

    [self setNeedsDisplay];
}

- (void)handleNotificationWithNumberOfSeconds:(NSInteger)numberOfSeconds
{
    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:ALARM_ID];

    if (existingNotification) {
        NSLog(@"notification exists");
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
        
        if (numberOfSeconds == 0) {
            NSLog(@"just cancel");
        } else {
            NSLog(@"update local notification");
            [self createNotificationUsingNumberOfSeconds:numberOfSeconds];
        }
    } else if (numberOfSeconds > 0) {
        NSLog(@"create new notification");
        [self createNotificationUsingNumberOfSeconds:numberOfSeconds];
    }
}

- (void)createNotificationUsingNumberOfSeconds:(NSInteger)numberOfSeconds
{
    self.seconds = 1;
    self.minutesLeft--;
    [self startTimer];
    [HYPLocalNotificationManager createNotificationUsingNumberOfSeconds:numberOfSeconds message:@"Your meal is ready!" actionTitle:@"View Details" alarmID:ALARM_ID];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer
{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSeconds:) userInfo:nil repeats:YES];
    }
}

@end