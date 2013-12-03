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
@property (nonatomic, strong) NSString *name;
- (instancetype)initWithNotification:(UILocalNotification *)notification;
- (void)fillUsingIndexPath:(NSIndexPath *)indexPath;
+ (NSString *)messageForSetAlarm;
+ (NSString *)messageForReleaseToSetAlarm;
+ (NSString *)messageForCurrentAlarm;
+ (NSString *)defaultAlarmID;
@end