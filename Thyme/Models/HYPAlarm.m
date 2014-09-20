//
//  HYPAlarm.m
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPAlarm.h"

@implementation HYPAlarm

#define ALARM_ID @"THYME_ALARM_ID_0"

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    _alarmID = [self idForIndexPath:indexPath];
}

+ (NSString *)titleForHomescreen
{
    return NSLocalizedString(@"IT'S TIME TO GET COOKING", @"IT'S TIME TO GET COOKING");
}

+ (NSString *)subtitleForHomescreen
{
    return NSLocalizedString(@"TAP A PLATE TO SET A TIMER", @"TAP A PLATE TO SET A TIMER");
}

+ (NSString *)subtitleForHomescreenUsingMinutes:(NSNumber *)maxMinutesLeft
{
    NSString *message;

    if ([maxMinutesLeft doubleValue] == 0.0f) {
        message = NSLocalizedString(@"IN LESS THAN A MINUTE", @"IN LESS THAN A MINUTE");
    } else {
        NSInteger hoursLeft = floor([maxMinutesLeft integerValue] / 60.0f);
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
                message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT 1 HOUR", @"IN ABOUT 1 HOUR")];
            } else if (hoursLeft == 1 && minutes > 0) {
                message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT 1 HOUR %ld MINUTES", @"IN ABOUT 1 HOUR %ld MINUTES"), (long)minutes];
            } else if (minutes == 0) {
                message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT %ld HOURS", @"IN ABOUT %ld HOURS"), (long)hoursLeft];
            } else {
                message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT %ld HOURS %ld MINUTES", @"IN ABOUT %ld HOURS %ld MINUTES"), (long)hoursLeft, (long)minutes];
            }
        } else {
            NSInteger m = [maxMinutesLeft integerValue] / 10.0f;
            NSInteger miniMinutes = [maxMinutesLeft integerValue] - (m * 10);
            if ([maxMinutesLeft integerValue] < 10) {
                message = [NSString stringWithFormat:NSLocalizedString(@"IN %ld MINUTES", @"IN %ld MINUTES"), (long)[maxMinutesLeft integerValue]];
            } else {
                if (miniMinutes < 3 || (miniMinutes >= 5 && miniMinutes < 8)) {
                    if (miniMinutes >= 5) {
                        message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT %ld MINUTES", @"IN ABOUT %ld MINUTES"), (long)(m * 10) + 5];
                    } else {
                        message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT %ld MINUTES", @"IN ABOUT %ld MINUTES"), (long)(m * 10)];
                    }
                } else {
                    if ([maxMinutesLeft integerValue] >= 58) {
                        message =  [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT 1 HOUR", @"IN ABOUT 1 HOUR")];
                    } else {
                        message = [NSString stringWithFormat:NSLocalizedString(@"IN ABOUT %ld MINUTES", @"IN ABOUT %ld MINUTES"), (long)minutes];
                    }
                }
            }
        }
    }

    return message;
}

+ (NSString *)messageForSetAlarm
{
    return NSLocalizedString(@"------------------SWIPE CLOCKWISE TO SET TIMER------------------", @"------------------SWIPE CLOCKWISE TO SET TIMER------------------");
}

+ (NSString *)messageForReleaseToSetAlarm
{
    return NSLocalizedString(@"------------------RELEASE TO SET TIMER------------------", @"------------------RELEASE TO SET TIMER------------------");
}

- (NSString *)title
{
    if (self.isOven) {
        return NSLocalizedString(@"OVEN", @"OVEN");
    }

    NSString *leading;

    if (self.indexPath.row == 0) {
        leading = NSLocalizedString(@"TOP", @"TOP");
    } else {
        leading = NSLocalizedString(@"BOTTOM", @"BOTTOM");
    }

    NSString *position;
    if (self.indexPath.section == 0) {
        position = NSLocalizedString(@"LEFT", @"LEFT");
    } else {
        position = NSLocalizedString(@"RIGHT", @"RIGHT");
    }

    return [NSString stringWithFormat:NSLocalizedString(@"%@ %@ PLATE", @"%@ %@ PLATE"), leading, position];
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
