//
//  HYPAlarm.h
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ALARM_ID_KEY @"HYPAlarmID"
#define ALARM_FIRE_DATE_KEY @"HYPAlarmFireDate"
#define ALARM_FIRE_INTERVAL_KEY @"HYPAlarmFireInterval"

@interface HYPAlarm : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *alarmID;
@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic, getter = isOven) BOOL oven;

- (instancetype)initWithNotification:(UILocalNotification *)notification;

+ (NSString *)titleForHomescreen;
+ (NSString *)subtitleForHomescreen;
+ (NSString *)messageForSetAlarm;
+ (NSString *)messageForReleaseToSetAlarm;
+ (NSString *)messageForCurrentAlarm;
+ (NSString *)defaultAlarmID;

@end