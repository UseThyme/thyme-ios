//
//  HYPTimerViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPTimerViewController.h"
#import "HYPTimerControl.h"
#import "HYPLocalNotificationManager.h"
#import "HYPUtils.h"
#import "HYPMathHelpers.h"

#import "HYPAlarm.h"

@interface HYPTimerViewController ()
@property (nonatomic, strong) HYPTimerControl *timerControl;
@property (nonatomic, strong) UIButton *kitchenButton;
@end

@implementation HYPTimerViewController

- (UIButton *)kitchenButton
{
    if (!_kitchenButton) {
        _kitchenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"kitchenImage"];
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat topMargin = 100.0f;
        CGFloat x = CGRectGetWidth(bounds) / 2 - image.size.width / 2;
        CGFloat y = CGRectGetHeight(bounds) - topMargin;
        _kitchenButton.frame = CGRectMake(x, y, image.size.width, image.size.height);
        [_kitchenButton setImage:image forState:UIControlStateNormal];
        [_kitchenButton addTarget:self action:@selector(kitchenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kitchenButton;
}

- (HYPTimerControl *)timerControl
{
    if (!_timerControl) {
        CGFloat sideMargin = 0.0f;

        CGFloat topMargin;
        if ([HYPUtils isTallPhone]) {
            topMargin = 60.0f;
        } else {
            topMargin = 50.0f;
        }

        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _timerControl = [[HYPTimerControl alloc] initShowingSubtitleWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
        _timerControl.active = YES;
    }
    return _timerControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.timerControl];
    [self.view addSubview:self.kitchenButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timerControl.alarmID = self.alarm.alarmID;
    [self refreshTimerForCurrentAlarm];
}

- (void)refreshTimerForCurrentAlarm
{
    if (!self.alarm) {
        abort();
    }

    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:self.alarm.alarmID];

    if (existingNotification) {
        NSDate *firedDate = [existingNotification.userInfo objectForKey:ALARM_FIRE_DATE_KEY];
        NSNumber *numberOfSeconds = [existingNotification.userInfo objectForKey:ALARM_FIRE_INTERVAL_KEY];

        // Fired date + amount of seconds = target date
        NSTimeInterval secondsPassed = [[NSDate date] timeIntervalSinceDate:firedDate];
        NSInteger secondsLeft = ([numberOfSeconds integerValue] - secondsPassed);
        NSTimeInterval currentSecond = secondsLeft % 60;
        NSTimeInterval minutesLeft = floor(secondsLeft/60.0f);

        self.timerControl.title = [HYPAlarm messageForCurrentAlarm];
        self.timerControl.minutesLeft = minutesLeft;
        self.timerControl.seconds = currentSecond;
        [self.timerControl startTimer];
    }
}

- (void)kitchenButtonPressed:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(dismissedTimerController:)]) {
        [self.delegate dismissedTimerController:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
