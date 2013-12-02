//
//  HYPLocalNotificationManager.h
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYPLocalNotificationManager : NSObject
+ (instancetype)sharedManager;
+ (void)createNotificationUsingNumberOfSeconds:(NSInteger)numberOfSeconds message:(NSString *)message actionTitle:(NSString *)actionTitle alarmID:(NSString *)alarmID;
+ (UILocalNotification *)existingNotificationWithAlarmID:(NSString *)alarmID;
@end
