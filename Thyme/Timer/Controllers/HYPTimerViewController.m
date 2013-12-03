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
@property (nonatomic, strong) HYPTimerControl *timerController;
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

- (HYPTimerControl *)timerController
{
    if (!_timerController) {
        CGFloat sideMargin = 0.0f;

        CGFloat topMargin;
        if ([HYPUtils isTallPhone]) {
            topMargin = 60.0f;
        } else {
            topMargin = 50.0f;
        }

        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _timerController = [[HYPTimerControl alloc] initShowingSubtitleWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
        _timerController.active = YES;
    }
    return _timerController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.timerController];
    [self.view addSubview:self.kitchenButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self currentNotificationRemainingTime];
}

- (void)currentNotificationRemainingTime
{
    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:[HYPAlarm defaultAlarmID]];

    if (existingNotification) {
        NSDate *firedDate = [existingNotification.userInfo objectForKey:ALARM_FIRE_DATE_KEY];
        NSNumber *numberOfSeconds = [existingNotification.userInfo objectForKey:ALARM_FIRE_INTERVAL_KEY];

        // Fired date + amount of seconds = target date
        NSTimeInterval secondsPassed = [[NSDate date] timeIntervalSinceDate:firedDate];
        NSInteger secondsLeft = ([numberOfSeconds integerValue] - secondsPassed);
        NSTimeInterval currentSecond = secondsLeft % 60;
        NSTimeInterval minutesLeft = floor(secondsLeft/60.0f);

        self.timerController.title = [HYPAlarm messageForCurrentAlarm];
        self.timerController.minutesLeft = minutesLeft;
        self.timerController.seconds = currentSecond;
        [self.timerController startTimer];
    }
}

- (void)kitchenButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
