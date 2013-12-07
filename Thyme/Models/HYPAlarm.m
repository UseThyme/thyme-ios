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

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    _alarmID = [self idForIndexPath:indexPath];
}

+ (NSString *)titleForHomescreen
{
    return @"BET YOU'VE BEEN WORKING ALL DAY";
}

+ (NSString *)subtitleForHomescreen
{
    return @"YOU MUST BE STARVING";
}

+ (NSString *)subtitleForHomescreenUsingMinutes:(NSNumber *)maxMinutesLeft
{
    NSString *message;

    if ([maxMinutesLeft doubleValue] == 0.0f) {
        message = @"IN LESS THAN A MINUTE";
    } else {
        NSInteger hoursLeft = floor([maxMinutesLeft integerValue]/60.0f);
        if (hoursLeft > 0) {
            maxMinutesLeft = @([maxMinutesLeft integerValue] - (hoursLeft * 60));
        }
        
        CGFloat result = [maxMinutesLeft integerValue] / 5.0f;
        NSInteger minutes = (result == 0.0f) ? 0 : (floor(result) + 1) * 5;
        
        if (hoursLeft > 0) {
            if (minutes == 60) {
                hoursLeft++;
                minutes = 0;
            }
            if (hoursLeft == 1 && minutes == 0) {
                message = [NSString stringWithFormat:@"IN ABOUT 1 HOUR"];
            } else if (hoursLeft == 1 && minutes > 0) {
                message = [NSString stringWithFormat:@"IN ABOUT 1 HOUR %ld MINUTES", (long)minutes];
            } else if (minutes == 0) {
                message = [NSString stringWithFormat:@"IN ABOUT %ld HOURS", (long)hoursLeft];
            } else {
                message = [NSString stringWithFormat:@"IN ABOUT %ld HOURS %ld MINUTES", (long)hoursLeft, (long)minutes];
            }
        } else {
            if (minutes == 60) {
                message = [NSString stringWithFormat:@"IN ABOUT 1 HOUR"];
            } else if (minutes > 10) {
                message = [NSString stringWithFormat:@"IN ABOUT %ld MINUTES", (long)minutes];
            } else {
                message = [NSString stringWithFormat:@"IN %ld MINUTES", (long)[maxMinutesLeft integerValue]];
            }
        }
    }

    return message;
}

+ (NSString *)messageForSetAlarm
{
    return A_DEFAULT_TEXT;
}

+ (NSString *)messageForReleaseToSetAlarm
{
    return B_DEFAULT_TEXT;
}

- (NSString *)title
{
    if (self.isOven) {
        return @"OVEN";
    }

    NSString *leading;

    if (self.indexPath.row == 0) {
        leading = @"TOP";
    } else {
        leading = @"BOTTOM";
    }

    NSString *position;
    if (self.indexPath.section == 0) {
        position = @"LEFT";
    } else {
        position = @"RIGHT";
    }

    return [NSString stringWithFormat:@"%@ %@ PLATE", leading, position];
}

- (NSString *)timerTitle
{
    return [NSString stringWithFormat:@"------------------%@------------------", [self title]];
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
