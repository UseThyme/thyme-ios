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

/** Helper Functions **/
#define ToRad(deg)                 ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)                ( (180.0 * (rad)) / M_PI )
#define SQR(x)                        ( (x) * (x) )

/** Parameters **/
#define CIRCLE_COLOR [UIColor colorFromHexString:@"bcf5e9"]
#define CIRCLE_SIZE_FACTOR 0.8f
#define KNOB_COLOR [UIColor colorWithWhite:1.0 alpha:0.7]

@interface HYPTimerControl ()
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) NSInteger angle;
@end

@implementation HYPTimerControl

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    result = ToDeg(atan2(v.x, (flipped ? - v.y : v.y)));
    return (result >= 0 ? result : result + 360.0);
}

- (UITextField *)textField
{
    if (!_textField) {
        //Define the Font
        UIFont *font = [HYPUtils helveticaNeueUltraLightWithSize:95.0f];
        NSString *sampleString = @"000";
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGSize fontSize = [sampleString sizeWithAttributes:attributes];
        CGFloat x = (self.frame.size.width - fontSize.width) / 2;
        CGFloat y = (self.frame.size.height - fontSize.height) / 2 - 20.0f;
        CGRect rect = CGRectMake(x, y, fontSize.width, fontSize.height);
        _textField = [[UITextField alloc] initWithFrame:rect];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorFromHexString:@"30cec6"];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = font;
        _textField.text = [NSString stringWithFormat:@"%ld", (long)self.angle];
        _textField.enabled = NO;
    }
    return _textField;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        //Define the Font
        UIFont *font = [HYPUtils avenirLightWithSize:14.0f];
        NSString *sampleString = @"MINUTES";
        NSDictionary *attributes = @{ NSFontAttributeName:font };
        CGSize fontSize = [sampleString sizeWithAttributes:attributes];
        CGFloat x = (self.frame.size.width - fontSize.width) / 2;
        CGFloat y = CGRectGetMaxY(self.textField.frame) - 5.0f;
        CGRect rect = CGRectMake(x, y, fontSize.width, fontSize.height);
        _titleLabel = [[UILabel alloc] initWithFrame:rect];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorFromHexString:@"30cec6"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = font;
        _titleLabel.text = @"MINUTES";
    }
    return _titleLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.angle = 0;
        [self addSubview:self.textField];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *circleColor = CIRCLE_COLOR;
    [circleColor set];
    CGFloat transform = CIRCLE_SIZE_FACTOR;
    CGFloat sideMargin = floor(CGRectGetWidth(rect) * (1.0f - transform) / 2);
    CGFloat length = CGRectGetWidth(rect) * transform;
    CGRect circleRect = CGRectMake(sideMargin, sideMargin, length, length);
    CGContextFillEllipseInRect(context, circleRect);

    UIColor *knobColor = KNOB_COLOR;
    [self drawKnob:context withColor:knobColor andRadius:sideMargin];
}

- (void)drawKnob:(CGContextRef)context withColor:(UIColor *)color andRadius:(CGFloat)radius
{
    CGContextSaveGState(context);

    // Draw knob
    [color set];
    CGPoint knobCenter =  [self pointFromAngle:self.angle usingRadius:radius];
    CGRect knobRect = CGRectMake(knobCenter.x, knobCenter.y, radius * 2, radius * 2);
    CGContextFillEllipseInRect(context, knobRect);

    CGContextRestoreGState(context);
}

// Magic function (not really)
- (CGPoint)pointFromAngle:(NSInteger)angle usingRadius:(CGFloat)radius
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2 - radius, self.frame.size.height / 2 - radius);
    CGPoint result;
    NSInteger angleTranslation = -90;
    NSInteger magicFuckingNumber = 120;
    result.x = round(centerPoint.x + magicFuckingNumber * cos(ToRad(angle+angleTranslation)));
    result.y = round(centerPoint.y + magicFuckingNumber * sin(ToRad(angle+angleTranslation)));
    return result;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];

    CGPoint lastPoint = [touch locationInView:self];
    [self moveKnobToPoint:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)moveKnobToPoint:(CGPoint)lastPoint
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);

    //Calculate the direction from the center point to an arbitrary position.
    CGFloat currentAngle = AngleFromNorth(centerPoint, lastPoint, YES);
    NSInteger angle = floor(currentAngle);
    self.angle = angle;

    //Textfielf
    self.textField.text = [NSString stringWithFormat:@"%ld", (long)self.angle/6];

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
    NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:numberOfSeconds];

    if (numberOfSeconds > 0) {
        [self createNotificationWithFireDate:fireDate];
        /*UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = fireDate;
        notification.soundName = nil;
        //notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = [NSString stringWithFormat:@"Your meal is ready!"];
        notification.alertAction = NSLocalizedString(@"View Details", nil);

        //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
        //notification.userInfo = infoDict;

        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

        // seconds timer
        NSTimer *secondsTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(secondUpdated:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:secondsTimer forMode:NSDefaultRunLoopMode];

        // minute timer
        NSTimer *minutesTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:60] interval:60 target:self selector:@selector(minuteUpdated:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:minutesTimer forMode:NSDefaultRunLoopMode];*/

    } else {
        // seconds is zero, cancel alarm if happening
    }
}

- (void)secondUpdated:(NSTimer *)timer
{
    NSLog(@"second timer: %f", timer.timeInterval);
}

- (void)minuteUpdated:(NSTimer *)timer
{
    NSLog(@"minute timer: %f", timer.timeInterval);
}

- (void)createNotificationWithFireDate:(NSDate *)fireDate
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    if (!localNotification)
        return;

    localNotification.repeatInterval = NSDayCalendarUnit;
    [localNotification setFireDate:fireDate];
    [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
    // Setup alert notification
    [localNotification setAlertBody:@"Your meal is ready!"];
    [localNotification setAlertAction:@"View Details"];
    [localNotification setHasAction:YES];

    NSNumber* uidToStore = [NSNumber numberWithInt:100];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:uidToStore forKey:@"notificationID"];
    localNotification.userInfo = userInfo;

    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
