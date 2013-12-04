//
//  HYPLocalNotificationManager.m
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPLocalNotificationManager.h"
#import "HYPAlarm.h"

@interface HYPLocalNotificationManager ()
@end

@implementation HYPLocalNotificationManager

+ (instancetype)sharedManager
{
    static HYPLocalNotificationManager *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[HYPLocalNotificationManager alloc] init];
    });

    return __sharedInstance;
}

+ (void)createNotificationUsingNumberOfSeconds:(NSInteger)numberOfSeconds message:(NSString *)message actionTitle:(NSString *)actionTitle alarmID:(NSString *)alarmID
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.soundName = @"alarm.caf";
    if (!notification)
        return;

    NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:numberOfSeconds];
    notification.fireDate = fireDate;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = actionTitle;
    if (actionTitle) {
        notification.hasAction = YES;
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:alarmID forKey:ALARM_ID_KEY];
    [userInfo setObject:[NSDate date] forKey:ALARM_FIRE_DATE_KEY];
    [userInfo setObject:@(numberOfSeconds) forKey:ALARM_FIRE_INTERVAL_KEY];
    notification.userInfo = userInfo;

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (UILocalNotification *)existingNotificationWithAlarmID:(NSString *)alarmID
{
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[notification.userInfo objectForKey:ALARM_ID_KEY] isEqualToString:alarmID]) {
            return notification;
        }
    }

    return nil;
}

@end