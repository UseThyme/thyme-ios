#import "HYPTimerControl.h"
@import QuartzCore;
#import "UIColor+HYPExtensions.h"
#import "HYPUtils.h"
#import "HYPAlarm.h"
#import "HYPMathHelpers.h"
@import CoreText;
#import "HYPTimerControl+DrawingMethods.h"
@import AVFoundation;
@import AudioToolbox;
#import "UIScreen+ANDYResolutions.h"
#import "Thyme-Swift.h"

/** Parameters **/
#define CIRCLE_SIZE_FACTOR 0.8f

#define UNACTIVE_SECONDS_INDICATOR_COLOR [UIColor whiteColor]
#define ACTIVE_SECONDS_INDICATOR_COLOR [UIColor colorFromHexString:@"ff5c5c"]
#define MINUTES_INDICATOR_COLOR [UIColor whiteColor]

@interface HYPTimerControl ()

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) UILabel *hoursLabel;
@property (nonatomic, strong) UILabel *minutesValueLabel;
@property (nonatomic, strong) UILabel *minutesTitleLabel;

@property (nonatomic) CGRect circleRect;
@property (nonatomic) NSInteger angle;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGPoint lastPoint;

@property (nonatomic) CGFloat minuteValueSize;
@property (nonatomic) CGFloat minuteTitleSize;
@end

@implementation HYPTimerControl

#pragma mark - Dealloc

- (void)dealloc
{
    [self.minutesValueLabel removeObserver:self forKeyPath:@"text"];
    [self stopTimer];
}

#pragma mark - Getters

- (AVAudioPlayer *)player {
    if (_player) return _player;

    NSString *file = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:file];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];

    return _player;
}

- (UILabel *)hoursLabel
{
    if (_hoursLabel) return _hoursLabel;

    //Define the Font
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat defaultSize = (self.isCompleteMode) ? self.minuteTitleSize : self.minuteTitleSize * 1.5;
    CGFloat fontSize = floor(defaultSize * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
    UIFont *font = [HYPUtils avenirLightWithSize:fontSize];
    NSString *sampleString = @"2 HOURS";
    NSDictionary *attributes = @{ NSFontAttributeName:font };

    CGSize textSize = [sampleString sizeWithAttributes:attributes];
    CGFloat yOffset = self.minutesValueLabel.frame.origin.y - 8.0f;
    CGFloat x = 0;
    CGFloat y = (self.frame.size.height - textSize.height) / 2 - yOffset;
    CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height);
    _hoursLabel = [[UILabel alloc] initWithFrame:rect];
    _hoursLabel.backgroundColor = [UIColor clearColor];
    NSString *customColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"TextColor"];
    if (customColor) {
        _hoursLabel.textColor = [UIColor colorFromHexString:customColor];
    } else {
        _hoursLabel.textColor = [UIColor colorFromHexString:@"1B807E"];
    }
    _hoursLabel.textAlignment = NSTextAlignmentCenter;
    _hoursLabel.font = font;
    _hoursLabel.text = sampleString;
    _hoursLabel.hidden = YES;

    return _hoursLabel;
}

- (UILabel *)minutesValueLabel
{
    if (_minutesValueLabel) return _minutesValueLabel;

    //Define the Font
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat defaultSize = (self.isCompleteMode) ? self.minuteValueSize : self.minuteValueSize * 0.9;
    CGFloat fontSize = floor(defaultSize * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
    UIFont *font = [HYPUtils helveticaNeueUltraLightWithSize:fontSize];
    NSString *sampleString = @"10:00";
    NSDictionary *attributes = @{ NSFontAttributeName:font };

    CGSize textSize = [sampleString sizeWithAttributes:attributes];
    CGFloat yOffset = 20.0f * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds);
    CGFloat x = 0;
    CGFloat y = (self.frame.size.height - textSize.height) / 2 - yOffset;
    CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height);
    _minutesValueLabel = [[UILabel alloc] initWithFrame:rect];
    _minutesValueLabel.backgroundColor = [UIColor clearColor];

    NSString *customColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"TextColor"];
    if (customColor) {
        _minutesValueLabel.textColor = [UIColor colorFromHexString:customColor];
    } else {
        _minutesValueLabel.textColor = [UIColor colorFromHexString:@"1B807E"];
    }

    _minutesValueLabel.textAlignment = NSTextAlignmentCenter;
    _minutesValueLabel.font = font;
    _minutesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.angle];

    return _minutesValueLabel;
}

- (UILabel *)minutesTitleLabel
{
    if (_minutesTitleLabel) return _minutesTitleLabel;

    //Define the Font
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat fontSize = floor(self.minuteTitleSize * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
    UIFont *font = [HYPUtils avenirLightWithSize:fontSize];
    NSString *minutesLeftText = NSLocalizedString(@"MINUTES LEFT", @"MINUTES LEFT");
    NSDictionary *attributes = @{ NSFontAttributeName:font };

    CGSize textSize = [minutesLeftText sizeWithAttributes:attributes];
    CGFloat x = 0;
    CGFloat factor = 5.0f;
    CGFloat yOffset = floor(factor * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
    if ([UIScreen andy_isPad]) {
        yOffset = -10;
    }
    CGFloat y = CGRectGetMaxY(self.minutesValueLabel.frame) - yOffset;
    CGRect rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height);
    _minutesTitleLabel = [[UILabel alloc] initWithFrame:rect];
    _minutesTitleLabel.backgroundColor = [UIColor clearColor];
    NSString *customColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"TextColor"];
    if (customColor) {
        _minutesTitleLabel.textColor = [UIColor colorFromHexString:customColor];
    } else {
        _minutesTitleLabel.textColor = [UIColor colorFromHexString:@"1B807E"];
    }
    _minutesTitleLabel.textAlignment = NSTextAlignmentCenter;
    _minutesTitleLabel.font = font;
    _minutesTitleLabel.text = minutesLeftText;

    return _minutesTitleLabel;
}

#pragma mark - Setters

- (void)setAngle:(NSInteger)angle
{
    _angle = angle;

    if (!self.isCompleteMode && self.isHoursMode) {
        NSInteger minute = (long)self.angle/6;
        if (minute < 10) {
            self.minutesValueLabel.text = [NSString stringWithFormat:@"%ld:0%ld", (long)self.hours, (long)self.angle/6];
        } else {
            self.minutesValueLabel.text = [NSString stringWithFormat:@"%ld:%ld", (long)self.hours, (long)self.angle/6];
        }
    } else {
        self.minutesValueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.angle/6];
    }
}

- (void)setMinutes:(NSInteger)minutes
{
    if (minutes != _minutes && self.touchesAreActive) {
        [self playInputClick];
    }
    _minutes = minutes;
    self.angle = minutes * 6;
    [self setNeedsDisplay];
}

- (void)setActive:(BOOL)active
{
    _active = active;
    self.minutesValueLabel.hidden = !_active;
    self.angle = 0;
    [self setNeedsDisplay];
}

- (void)setHours:(NSInteger)hours
{
    _hours = hours;
    if (_hours == 0) {
        self.hoursLabel.hidden = YES;
    } else {
        self.hoursLabel.hidden = NO;
        if (_hours == 1) {
            self.hoursLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld HOUR", @"%ld HOUR"), (long)_hours];
        } else {
            self.hoursLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld HOURS", @"%ld HOURS"), (long)_hours];
        }
    }
}

#pragma mark - Initializators

- (instancetype)initCompleteModeWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame completeMode:YES];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame completeMode:NO];
}

- (instancetype)initWithFrame:(CGRect)frame completeMode:(BOOL)completeMode
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([UIScreen andy_isPad]) {
            self.minuteValueSize = 200.0f;
            self.minuteTitleSize = 35.0f;
        } else {
            self.minuteValueSize = 95.0f;
            self.minuteTitleSize = 14.0f;
        }

        self.backgroundColor = [UIColor clearColor];
        self.completeMode = completeMode;
        self.angle = 0;
        self.title = [HYPAlarm messageForSetAlarm];
        [self addSubview:self.minutesValueLabel];
        if (self.isCompleteMode) {
            [self addSubview:self.minutesTitleLabel];
            [self addSubview:self.hoursLabel];
        }

        [self.minutesValueLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.minutesValueLabel]) {
        UILabel *aLabel = (UILabel *)object;

        //Define the Font
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat baseSize;
        if (aLabel.text.length == 5) {
            if ([UIScreen andy_isPad]) {
                baseSize = 200.0f;
            } else {
                baseSize = self.minuteValueSize;
            }
        } else if (aLabel.text.length == 4) {
            if ([UIScreen andy_isPad]) {
                baseSize = 220.0f;
            } else {
                baseSize = 100.0f;
            }
        } else {
            if ([UIScreen andy_isPad]) {
                baseSize = 280.0f;
            } else {
                baseSize = 120.0f;
            }
        }

        if (self.isCompleteMode) {
            if ([UIScreen andy_isPad]) {
                baseSize = 250.0f;
            } else {
                baseSize = self.minuteValueSize;
            }
        }

        CGFloat fontSize = floor(baseSize * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds));
        UIFont *font = [HYPUtils helveticaNeueUltraLightWithSize:fontSize];
        self.minutesValueLabel.font = font;
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *circleColor = [self colorForMinutesIndicator];
    CGFloat transform = CIRCLE_SIZE_FACTOR;
    CGFloat sideMargin = floor(CGRectGetWidth(rect) * (1.0f - transform) / 2);
    CGFloat length = CGRectGetWidth(rect) * transform;
    CGRect circleRect = CGRectMake(sideMargin, sideMargin, length, length);
    [self drawCircle:context withColor:circleColor inRect:circleRect];
    self.circleRect = circleRect;

    if (self.isActive) {
        CGFloat radius = CGRectGetWidth(circleRect) / 2;
        UIColor *minutesColor = MINUTES_INDICATOR_COLOR;
        [self drawMinutesIndicator:context
                         withColor:minutesColor
                            radius:radius
                             angle:self.angle
                     containerRect:circleRect];

        UIColor *secondsColor = ACTIVE_SECONDS_INDICATOR_COLOR;
        BOOL shouldShowSeconds = (self.timer && [self.timer isValid]);
        if (shouldShowSeconds) {
            CGFloat factor = (self.isCompleteMode) ? 0.1f : 0.2f;
            [self drawSecondsIndicator:context
                             withColor:secondsColor
                             andRadius:sideMargin * factor
                         containerRect:circleRect];
        }

        if (self.isCompleteMode) {
            [self drawText:context rect:rect];
        }
    } else {
        UIColor *secondsColor = UNACTIVE_SECONDS_INDICATOR_COLOR;
        [self drawSecondsIndicator:context
                         withColor:secondsColor
                         andRadius:sideMargin * 0.2
                     containerRect:circleRect];
    }
}

#pragma mark - Drawing Helpers

- (UIColor *)colorForMinutesIndicator
{
    CGFloat saturationBaseOffset = 0.10f;
    CGFloat saturationBase = 0.20f;
    CGFloat saturationBasedOnAngle = saturationBase * (self.angle/360.0f) + saturationBaseOffset;

    UIColor *normalCircleColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.4];
    UIColor *calculatedColor = [UIColor colorWithHue:255
                                          saturation:saturationBasedOnAngle brightness:0.96f alpha:1.0f];
    UIColor *unactiveCircleColor = [UIColor colorWithWhite:1.0f alpha:0.4f];

    UIColor *circleColor;
    if (self.isActive) {
        if (self.isHoursMode) {
            circleColor = calculatedColor;
        } else {
            circleColor = normalCircleColor;
        }
    } else {
        circleColor = unactiveCircleColor;
    }
    return circleColor;
}

#pragma mark - UIControl Overwritable methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    self.title = [HYPAlarm messageForReleaseToSetAlarm];
    [self stopTimer];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];

    CGPoint currentPoint = [touch locationInView:self];

    if (self.touchesAreActive) {

        BOOL shouldBlockTouchesForPoint = [self shouldBlockTouchesForPoint:currentPoint];
        if (!self.isHoursMode && shouldBlockTouchesForPoint) {
            self.touchesAreActive = NO;
            self.angle = 0;
            [self setNeedsDisplay];
            return YES;
        } else {
            [self handleTouchesForPoint:currentPoint];
        }

    } else if ([self pointIsComingFromSecondQuadrand:currentPoint] || [self pointIsInFirstQuadrand:currentPoint]) {
        self.touchesAreActive = YES;
    }

    self.lastPoint = currentPoint;

    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];

    CGPoint currentPoint = [touch locationInView:self];
    if (([self pointIsComingFromFirstQuadrand:currentPoint] && self.hours == 0) ||
        (self.angle == 0 && self.hours == 0) ||
        (self.minutes == 0 && self.hours == 0)) {
        self.angle = 0;
        self.touchesAreActive = NO;
        self.title = [HYPAlarm messageForSetAlarm];
        [self cancelCurrentLocalNotification];
        [self setNeedsDisplay];
    } else {
        [self performSelector:@selector(startAlarm) withObject:nil afterDelay:0.2f];
    }
    self.lastPoint = CGPointZero;
}

#pragma mark - Helpers

- (void)handleTouchesForPoint:(CGPoint)currentPoint
{
    [self evaluateMinutesUsingPoint:currentPoint];
    self.lastPoint = currentPoint;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (BOOL)pointIsInFirstQuadrand:(CGPoint)point
{
    BOOL currentPointIsInFirstQuadrand = CGRectContainsPoint([self firstQuadrandRect], point);
    BOOL lastPointWasInFirstQuadrand = CGRectContainsPoint([self firstQuadrandRect], self.lastPoint);
    BOOL lastPointIsZero = (CGPointEqualToPoint(self.lastPoint, CGPointZero));

    if (currentPointIsInFirstQuadrand) {
        if (!lastPointIsZero && lastPointWasInFirstQuadrand) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)pointIsComingFromSecondQuadrand:(CGPoint)point
{
    BOOL currentPointIsInFirstQuadrand = CGRectContainsPoint([self firstQuadrandRect], point);
    BOOL lastPointWasInSecondQuadrand = CGRectContainsPoint([self secondQuadrandRect], self.lastPoint);
    BOOL lastPointIsZero = (CGPointEqualToPoint(self.lastPoint, CGPointZero));

    if (currentPointIsInFirstQuadrand) {
        if (!lastPointIsZero && lastPointWasInSecondQuadrand) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)pointIsComingFromFirstQuadrand:(CGPoint)point
{
    BOOL currentPointIsInSecondQuadrand = CGRectContainsPoint([self secondQuadrandRect], point);
    BOOL lastPointWasInFirstQuadrand = CGRectContainsPoint([self firstQuadrandRect], self.lastPoint);
    BOOL lastPointIsZero = (CGPointEqualToPoint(self.lastPoint, CGPointZero));

    if (currentPointIsInSecondQuadrand) {
        if (!lastPointIsZero && lastPointWasInFirstQuadrand) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldBlockTouchesForPoint:(CGPoint)currentPoint
{
    CGFloat xBlockCoordinate = CGRectGetWidth(self.frame) / 2.0f;
    BOOL pointBelongsToFirstHalfOfTheScreen = (currentPoint.x < xBlockCoordinate);
    BOOL lastPointIsZero = CGPointEqualToPoint(self.lastPoint, CGPointZero);
    BOOL lastPointWasInFirstQuadrand = CGRectContainsPoint([self firstQuadrandRect], self.lastPoint);

    if (!self.isHoursMode && pointBelongsToFirstHalfOfTheScreen && (!lastPointIsZero && lastPointWasInFirstQuadrand)) {
        return YES;
    }

    return NO;
}

- (CGRect)firstQuadrandRect
{
    CGFloat topMargin = CGRectGetMinY(self.frame);
    CGRect firstQuadrandRect = CGRectMake(CGRectGetMinX(self.circleRect) + CGRectGetWidth(self.circleRect) / 2.0f,
                                          - topMargin,
                                          CGRectGetMaxX(self.circleRect),
                                          CGRectGetMinY(self.circleRect) + CGRectGetHeight(self.circleRect) / 2.0f + topMargin);
    return firstQuadrandRect;
}

- (CGRect)secondQuadrandRect
{
    CGFloat topMargin = CGRectGetMinY(self.frame);
    CGRect secondQuadrandRect = CGRectMake(0.0f,
                                           - topMargin,
                                           CGRectGetMinX(self.circleRect) + CGRectGetWidth(self.circleRect) / 2.0f,
                                           CGRectGetMinY(self.circleRect) + CGRectGetHeight(self.circleRect) / 2.0f + topMargin);
    return secondQuadrandRect;
}

- (void)evaluateMinutesUsingPoint:(CGPoint)currentPoint
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    CGFloat currentAngle = AngleFromNorth(centerPoint, currentPoint, YES);
    NSInteger angle = floor(currentAngle);

    if ([self pointIsComingFromSecondQuadrand:currentPoint]) {
        self.hours++;
    } else if (self.isHoursMode && [self pointIsComingFromFirstQuadrand:currentPoint]) {
        self.hours--;
    }
    self.minutes = angle / 6;
    self.angle = angle;
    [self setNeedsDisplay];
}

- (void)updateSeconds:(NSTimer *)timer
{
    self.seconds -= 1;
    if (self.seconds < 0) {
        self.angle = (self.minutes - 1) * 6;
        self.seconds = 59;
        self.minutes--;

        if (self.minutes < 0 && self.hours > 0) {
            self.minutes = 59;
            self.hours--;
        }

        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }

    if (self.minutes == 0 && self.seconds == 0 && self.hours == 0) {
        [self restartTimer];
        self.title = [HYPAlarm messageForSetAlarm];
        [self stopTimer];
    }

    if (self.minutes == -1) {
        [self restartTimer];
    }

    [self setNeedsDisplay];
}

- (BOOL)isHoursMode
{
    return (self.hours > 0);
}

#pragma mark - Alarm methods

- (void)startAlarm
{
    NSInteger numberOfSeconds = (self.angle / 6) * 60 + self.hours * 3600;
    [self handleNotificationWithNumberOfSeconds:numberOfSeconds];
    self.title = [self.alarm timerTitle];
    [self setNeedsDisplay];
}

- (void)restartTimer
{
    self.minutes = 59;
    self.angle = 0;
    self.seconds = 0;
    self.minutes = 0;
    self.hours = 0;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Timer

- (void)startTimer
{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(updateSeconds:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Handle Notifications

- (void)cancelCurrentLocalNotification
{
    if (!self.alarmID) {
        abort();
    }

    UILocalNotification *existingNotification = [LocalNotificationManager existingNotificationWithAlarmID:self.alarmID];
    if (existingNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
    }
}

- (void)handleNotificationWithNumberOfSeconds:(NSInteger)numberOfSeconds
{
    BOOL createNotification = (numberOfSeconds > 0);
    [self cancelCurrentLocalNotification];
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
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%@ just finished", @"%@ just finished"), [[self.alarm title] capitalizedString]];
    [LocalNotificationManager createNotification:numberOfSeconds
                                         message:title
                                           title:NSLocalizedString(@"View Details", @"View Details")
                                         alarmID:self.alarmID];
}

- (void)playInputClick
{
    [self.player play];
}

@end
