#import "HYPTimerViewController.h"
#import "HYPTimerControl.h"
#import "HYPLocalNotificationManager.h"
#import "HYPUtils.h"
#import "HYPMathHelpers.h"

#import "HYPAlarm.h"
#import "HYPMathHelpers.h"
#import <QuartzCore/QuartzCore.h>
#import "UIScreen+ANDYResolutions.h"

@interface HYPTimerViewController ()

@property (nonatomic, strong) HYPTimerControl *timerControl;
@property (nonatomic, strong) UIButton *kitchenButton;
@property (nonatomic, strong) UIImageView *fingerView;
@property (nonatomic) CGRect startRect;
@property (nonatomic) CGRect finalRect;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HYPTimerViewController

- (void)startTimerGoingForward:(BOOL)forward
{
    if (!self.timer) {
        if (forward) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                          target:self
                                                        selector:@selector(updateForward:)
                                                        userInfo:nil
                                                         repeats:YES];
        } else {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                          target:self
                                                        selector:@selector(updateBackwards:)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    }
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (UIImageView *)fingerView
{
    if (_fingerView) return _fingerView;

    UIImage *image = [UIImage imageNamed:@"fingerImage"];
    _fingerView = [[UIImageView alloc] initWithImage:image];
    CGFloat x = CGRectGetMaxX(self.timerControl.frame) / 2.0f - image.size.width / 2.0f;
    CGFloat y = CGRectGetMinY(self.timerControl.frame) + image.size.height;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;
    CGFloat xOffset;
    CGFloat yOffset;

    if ([UIScreen andy_isPad]) {
        xOffset = 61.0f;
        yOffset = 18.0f;
    } else {
        if (deviceHeight == 480.0f) {
            xOffset = 61.0f;
            yOffset = 18.0f;
        } else if (deviceHeight == 568.0f) {
            xOffset = 61.0f;
            yOffset = 18.0f;
        } else if (deviceHeight == 667.0f) {
            xOffset = 70.0f;
            yOffset = 35.0f;
        } else {
            xOffset = 80.0f;
            yOffset = 45.0f;
        }
    }

    self.startRect = CGRectMake(x, y, width, height);
    self.finalRect = CGRectMake(x + xOffset, y + yOffset, width, height);
    _fingerView.frame = self.startRect;
    _fingerView.hidden = YES;

    return _fingerView;
}

- (UIButton *)kitchenButton
{
    if (_kitchenButton) return _kitchenButton;

    _kitchenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image;
    if (self.alarm.isOven) {
        image = [UIImage imageNamed:@"oven"];
    } else {
        NSString *imageName = [NSString stringWithFormat:@"%ld-%ld", (long)self.alarm.indexPath.row, (long)self.alarm.indexPath.section];
        image = [UIImage imageNamed:imageName];
    }
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    CGFloat topMargin;
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;

    if ([UIScreen andy_isPad]) {
        topMargin = 330.0f;
        x = CGRectGetWidth(bounds) / 2 - image.size.width / 2;
        y = CGRectGetHeight(bounds) - topMargin;
        width = image.size.width;
        height = image.size.height;
    } else {
        if (deviceHeight == 480.0f) {
            topMargin = 110.0f;
            x = CGRectGetWidth(bounds) / 2 - image.size.width / 2;
            y = CGRectGetHeight(bounds) - topMargin;
            width = image.size.width;
            height = image.size.height;
        } else if (deviceHeight == 568.0f) {
            topMargin = 140.0f;
            x = CGRectGetWidth(bounds) / 2 - image.size.width / 2;
            y = CGRectGetHeight(bounds) - topMargin;
            width = image.size.width;
            height = image.size.height;
        } else if (deviceHeight == 667.0f) {
            topMargin = 164.0f;
            x = 150.0f;
            y = CGRectGetHeight(bounds) - topMargin;
            width = 75.0f;
            height = 75.0f;
        } else {
            topMargin = 181.0f;
            x = 166.0f;
            y = CGRectGetHeight(bounds) - topMargin;
            width = 83.0f;
            height = 83.0f;
        }
    }

    _kitchenButton.frame = CGRectMake(x, y, width, height);
    _kitchenButton.contentMode = UIViewContentModeScaleAspectFit;
    _kitchenButton.imageEdgeInsets = UIEdgeInsetsZero;

    [_kitchenButton setBackgroundImage:image forState:UIControlStateNormal];
    [_kitchenButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [_kitchenButton setBackgroundImage:image forState:UIControlStateSelected];
    [_kitchenButton addTarget:self action:@selector(kitchenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    return _kitchenButton;
}

- (HYPTimerControl *)timerControl
{
    if (_timerControl) return _timerControl;

    CGFloat sideMargin = 0.0f;
    if ([UIScreen andy_isPad]) {
        sideMargin = 140.0f;
    }

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    CGFloat topMargin;

    if ([UIScreen andy_isPad]) {
        topMargin = 140.0f;
    } else {
        if (deviceHeight == 480.0f) {
            topMargin = 30.0f;
        } else if (deviceHeight == 568.0f) {
            topMargin = 60.0f;
        } else if (deviceHeight == 667.0f) {
            topMargin = 70.0f;
        } else {
            topMargin = 78.0f;
        }
    }

    CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
    _timerControl = [[HYPTimerControl alloc] initCompleteModeWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
    _timerControl.active = YES;
    _timerControl.backgroundColor = [UIColor clearColor];

    return _timerControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.timerControl];
    [self.view addSubview:self.kitchenButton];
    [self.view addSubview:self.fingerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.timerControl.alarm = self.alarm;
    self.timerControl.alarmID = self.alarm.alarmID;
    [self refreshTimerForCurrentAlarm];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kitchenButtonPressed:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL presentedClue = [defaults boolForKey:@"presentedClue"];
    if (!presentedClue) {
        self.fingerView.hidden = NO;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self startTimerGoingForward:YES];
        [UIView animateWithDuration:0.8f animations:^{
            self.fingerView.frame = self.finalRect;
        } completion:^(BOOL finished) {
            [self stopTimer];
            [self startTimerGoingForward:NO];
            [UIView animateWithDuration:0.8f animations:^{
                self.fingerView.frame = self.startRect;
            } completion:^(BOOL finished) {
                self.fingerView.hidden = YES;
                [self stopTimer];
            }];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [defaults setBool:YES forKey:@"presentedClue"];
            [defaults synchronize];
        }];
    }
}

- (void)updateForward:(NSTimer *)timer
{
    if (self.timerControl.minutes < 7) {
        self.timerControl.minutes += 1;
    }
}

- (void)updateBackwards:(NSTimer *)timer
{
    if (self.timerControl.minutes > 0) {
        self.timerControl.minutes -= 1;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshTimerForCurrentAlarm
{
    if (!self.alarm) {
        abort();
    }

    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:self.alarm.alarmID];

    if (existingNotification) {
        NSDate *firedDate = (existingNotification.userInfo)[ALARM_FIRE_DATE_KEY];
        NSNumber *numberOfSeconds = (existingNotification.userInfo)[ALARM_FIRE_INTERVAL_KEY];

        // Fired date + amount of seconds = target date
        NSTimeInterval secondsPassed = [[NSDate date] timeIntervalSinceDate:firedDate];
        NSInteger secondsLeft = ([numberOfSeconds integerValue] - secondsPassed);
        NSTimeInterval currentSecond = secondsLeft % 60;
        NSTimeInterval minutesLeft = floor(secondsLeft / 60.0f);
        NSTimeInterval hoursLeft = floor(minutesLeft / 60.0f);
        if (hoursLeft > 0) {
            minutesLeft = minutesLeft - (hoursLeft * 60);
        }

        self.timerControl.title = [self.alarm timerTitle];
        self.timerControl.seconds = currentSecond;
        self.timerControl.hours = hoursLeft;
        self.timerControl.minutes = minutesLeft;
        self.timerControl.touchesAreActive = YES;
        [self.timerControl startTimer];
    }
}

- (void)kitchenButtonPressed:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(dismissedTimerController:)]) {
        [self.delegate dismissedTimerController:self];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
