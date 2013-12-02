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

#define ALARM_ID @"THYME_ALARM_ID_0"
#import "HYPAlarm.h"

@interface HYPTimerViewController ()
@property (nonatomic, strong) HYPTimerControl *timerController;
@end

@implementation HYPTimerViewController

- (HYPTimerControl *)timerController
{
    if (!_timerController) {
        CGFloat sideMargin = 0.0f;
        CGFloat topMargin = 60.0f;//40.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _timerController = [[HYPTimerControl alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
    }
    return _timerController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.timerController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self currentNotificationRemainingTime];
}

- (void)currentNotificationRemainingTime
{
    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:ALARM_ID];
    if (existingNotification) {
        NSDate *firedDate = [existingNotification.userInfo objectForKey:ALARM_FIRE_DATE_KEY];
        NSNumber *numberOfSeconds = [existingNotification.userInfo objectForKey:ALARM_FIRE_INTERVAL_KEY];

        // Fired date + amount of seconds = target date
        NSTimeInterval secondsPassed = [[NSDate date] timeIntervalSinceDate:firedDate];
        NSLog(@"secondsPassed: %f", secondsPassed);
        NSLog(@"numberOfSeconds: %@", numberOfSeconds);
        NSInteger secondsLeft = ([numberOfSeconds integerValue] - secondsPassed);
        NSLog(@"secondsLeft: %ld", (long)secondsLeft);
        NSTimeInterval currentSecond = secondsLeft % 60;
        NSLog(@"currentSecond: %f", currentSecond);

        self.timerController.minutesLeft = secondsLeft/60;
        self.timerController.seconds = currentSecond;
        [self.timerController startTimer];

    } else {
        NSLog(@"notification not found");
    }
}

@end
