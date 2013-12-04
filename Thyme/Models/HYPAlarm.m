//
//  HYPAlarm.m
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPAlarm.h"

@implementation HYPAlarm

#define A_DEFAULT_TEXT @"------------------SWIPE CLOCKWISE TO SET TIMER------------------"
#define B_DEFAULT_TEXT @"------------------RELEASE TO SET TIMER------------------"
#define ALARM_ID @"THYME_ALARM_ID_0"

- (instancetype)initWithNotification:(UILocalNotification *)notification
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    _alarmID = [self idForIndexPath:indexPath];
}

+ (NSString *)titleForHomescreen
{
    return @"Bet you've been working all day";
}

+ (NSString *)subtitleForHomescreen
{
    return @"YOU MUST BE STARVING";
}

+ (NSString *)messageForSetAlarm
{
    return A_DEFAULT_TEXT;
}

+ (NSString *)messageForReleaseToSetAlarm
{
    return B_DEFAULT_TEXT;
}

- (NSString *)timerTitle
{
    if (self.isOven) {
        return @"------------------OVEN------------------";
    }
    
    NSString *leading;

    if (self.indexPath.section == 0) {
        leading = @"TOP";
    } else {
        leading = @"BOTTOM";
    }

    NSString *position;
    if (self.indexPath.row == 0) {
        position = @"LEFT";
    } else {
        position = @"RIGHT";
    }

    return [NSString stringWithFormat:@"------------------%@ %@ PLATE------------------", leading, position];
}

+ (NSString *)defaultAlarmID
{
    return ALARM_ID;
}

- (NSString *)idForIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOven) {
        return [NSString stringWithFormat:@"HYPAlert oven section: %ld row: %ld", (long)indexPath.section, (long)indexPath.row];
    }
    return [NSString stringWithFormat:@"HYPAlert section: %ld row: %ld", (long)indexPath.section, (long)indexPath.row];
}

@end
