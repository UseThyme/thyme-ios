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
#import <AVFoundation/AVAudioPlayer.h>

/** Parameters **/
#define CIRCLE_COLOR [UIColor colorFromHexString:@"bcf5e9"]
#define CIRCLE_SIZE_FACTOR 0.8f
#define KNOB_COLOR [UIColor colorFromHexString:@"ff5c5c"]
#define MINUTE_VALUE_SIZE 95.0f
#define MINUTE_TITLE_SIZE 14.0f

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
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat defaultSize = (self.showSubtitle) ? MINUTE_VALUE_SIZE : MINUTE_VALUE_SIZE * 1.5;
        CGFloat fontSize = floor(defaultSize * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
        UIFont *font = [HYPUtils helveticaNeueUltraLightWithSize:fontSize];
        NSString *sampleString = @"000";
        NSDictionary *attributes = @{ NSFontAttributeName:font };

        CGSize textSize;
        if ([sampleString respondsToSelector:@selector(sizeWithAttributes:)]) {
            textSize = [sampleString sizeWithAttributes:attributes];
        } else {
            textSize = [sampleString sizeWithFont:font];
        }

        CGFloat yOffset = (self.showSubtitle) ? floor(20.0f * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds)) : 0;
        CGFloat x = 0;
        CGFloat y = (self.frame.size.height - textSize.height) / 2 - yOffset;
        CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height);
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
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat fontSize = floor(MINUTE_TITLE_SIZE * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
        UIFont *font = [HYPUtils avenirLightWithSize:fontSize];
        NSString *sampleString = @"MINUTES LEFT";
        NSDictionary *attributes = @{ NSFontAttributeName:font };

        CGSize textSize;
        if ([sampleString respondsToSelector:@selector(sizeWithAttributes:)]) {
            textSize = [sampleString sizeWithAttributes:attributes];
        } else {
            textSize = [sampleString sizeWithFont:font];
        }

        CGFloat x = 0;
        CGFloat yOffset = floor(5.0f * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
        CGFloat y = CGRectGetMaxY(self.minutesValueLabel.frame) - yOffset;
        CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height);
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

- (id)initShowingSubtitleWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame showingSubtitle:YES];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame showingSubtitle:NO];
}

- (id)initWithFrame:(CGRect)frame showingSubtitle:(BOOL)showingSubtitle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showSubtitle = showingSubtitle;
        self.angle = 0;
        self.title = [HYPAlarm messageForSetAlarm];
        [self addSubview:self.minutesValueLabel];
        if (self.showSubtitle) {
            [self addSubview:self.minutesTitleLabel];
        }
    }
    return self;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    self.minutesValueLabel.hidden = !_active;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat transform = CIRCLE_SIZE_FACTOR;
    CGFloat sideMargin = floor(CGRectGetWidth(rect) * (1.0f - transform) / 2);
    CGFloat length = CGRectGetWidth(rect) * transform;
    CGRect circleRect = CGRectMake(sideMargin, sideMargin, length, length);
    UIColor *circleColor = (self.isActive) ? CIRCLE_COLOR : [UIColor colorWithWhite:1.0f alpha:0.4f];
    [self drawCircle:context withColor:circleColor inRect:circleRect];

    if (self.isActive) {

        CGFloat radius = CGRectGetWidth(circleRect) / 2;
        [self drawMinutesIndicator:context withColor:[UIColor whiteColor] radius:radius angle:self.angle containerRect:circleRect];

        UIColor *secondsColor = KNOB_COLOR;
        if (self.timer && [self.timer isValid]) {
            [self drawSecondsIndicator:context withColor:secondsColor andRadius:sideMargin * 0.2 containerRect:circleRect];
        }

        if (self.showSubtitle) {
            [self drawText:context rect:rect];
        }
    } else {
        UIColor *secondsColor = [UIColor whiteColor];
        [self drawSecondsIndicator:context withColor:secondsColor andRadius:sideMargin * 0.2 containerRect:circleRect];
    }
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
    if (!self.alarmID) {
        abort();
    }

    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:self.alarmID];
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
    if (!self.alarmID) {
        abort();
    }

    self.seconds = 0;
    [self startTimer];
    [HYPLocalNotificationManager createNotificationUsingNumberOfSeconds:numberOfSeconds message:@"Your meal is ready!" actionTitle:@"View Details" alarmID:self.alarmID];
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