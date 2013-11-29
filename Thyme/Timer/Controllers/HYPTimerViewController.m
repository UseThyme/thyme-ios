//
//  HYPTimerViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPTimerViewController.h"
#import "HYPTimerControl.h"

#define ALARM_ID @"THYME_ALARM_ID_0"
#define ALARM_ID_KEY @"HYPAlarmID"
#define ALARM_FIRE_DATE_KEY @"HYPAlarmFireDate"

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
    UILocalNotification *existingNotification = nil;
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[notification.userInfo objectForKey:ALARM_ID_KEY] isEqualToString:ALARM_ID]) {
            existingNotification = notification;
            break;
        }
    }

    if (existingNotification) {
        NSDate *firedDate = [existingNotification.userInfo objectForKey:ALARM_FIRE_DATE_KEY];
        NSLog(@"fired date: %f", [firedDate timeIntervalSinceNow]); // -120 = - 2 minutes to sound
    } else {
        NSLog(@"notification not found");
    }
}

@end
