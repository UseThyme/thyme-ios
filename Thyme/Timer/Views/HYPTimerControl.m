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
#import "HYPMathHelpers.h"
#import <CoreText/CoreText.h>
#import "HYPTimerControl+DrawingMethods.h"

/** Parameters **/
#define CIRCLE_COLOR [UIColor colorFromHexString:@"bcf5e9"]
#define CIRCLE_SIZE_FACTOR 0.8f
#define KNOB_COLOR [UIColor colorFromHexString:@"ff5c5c"]

@interface HYPTimerControl ()
@property (nonatomic, strong) UILabel *minutesValueLabel;
@property (nonatomic, strong) UILabel *minutesTitleLabel;
@property (nonatomic) NSInteger angle;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation HYPTimerControl

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
        self.title = [HYPAlarm messageForSetAlarm];
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
    [self drawMinutesIndicator:context withColor:[UIColor whiteColor] radius:radius angle:self.angle];

    UIColor *secondsColor = KNOB_COLOR;
    if (self.timer && [self.timer isValid]) {
        [self drawSecondsIndicator:context withColor:secondsColor andRadius:sideMargin * 0.1];
    }

    [self drawText:context rect:rect];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    self.title = [HYPAlarm messageForReleaseToSetAlarm];
    [self stopTimer];

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
    
    if (numberOfSeconds == 0) {
        self.title = [HYPAlarm messageForSetAlarm];
    } else {
        self.title = [HYPAlarm messageForCurrentAlarm];
    }
    [self setNeedsDisplay];
}

- (void)updateSeconds:(NSTimer *)timer
{
    self.seconds -= 1;
    if (self.seconds < 0) {
        self.angle = (self.minutesLeft - 1) * 6;
        self.seconds = 59;
        self.minutesLeft--;
    }

    if (self.minutesLeft == 0 && self.seconds == 0) {
        self.angle = 0;
        self.seconds = 0;
        self.minutesLeft = 0;
        self.title = [HYPAlarm messageForSetAlarm];
        [self stopTimer];
    }

    [self setNeedsDisplay];
}

- (void)handleNotificationWithNumberOfSeconds:(NSInteger)numberOfSeconds
{
    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:[HYPAlarm defaultAlarmID]];
    BOOL createNotification = (numberOfSeconds > 0);

    if (existingNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
    }

    if (createNotification) {
        [self createNotificationUsingNumberOfSeconds:numberOfSeconds];
    }
}


- (void)createNotificationUsingNumberOfSeconds:(NSInteger)numberOfSeconds
{
    self.seconds = 0;
    [self startTimer];
    [HYPLocalNotificationManager createNotificationUsingNumberOfSeconds:numberOfSeconds message:@"Your meal is ready!" actionTitle:@"View Details" alarmID:[HYPAlarm defaultAlarmID]];
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