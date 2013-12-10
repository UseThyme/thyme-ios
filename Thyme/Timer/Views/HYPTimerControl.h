//
//  HYPTimerControl.h
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYPAlarm;

@interface HYPTimerControl : UIControl

@property (nonatomic, strong) HYPAlarm *alarm;
@property (nonatomic, strong) NSString *alarmID;
@property (nonatomic, strong) NSString *title;

@property (nonatomic) NSInteger hours;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger seconds;
@property (nonatomic) BOOL touchesAreActive;

// SimpleMode
// YES: Timer on main screen
// NO: Timer in detail screen
@property (nonatomic, getter = isCompleteMode) BOOL completeMode;

// Active
// YES: This timer has an alarm
// NO: No alarm was set for this timer
@property (nonatomic, getter = isActive) BOOL active;

- (id)initCompleteModeWithFrame:(CGRect)frame;
- (void)restartTimer;
- (void)startTimer;
- (void)stopTimer;

@end