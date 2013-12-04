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

@property (nonatomic) NSTimeInterval minutesLeft;
@property (nonatomic) NSTimeInterval seconds;

@property (nonatomic) BOOL showSubtitle;
@property (nonatomic, getter = isActive) BOOL active;

- (id)initShowingSubtitleWithFrame:(CGRect)frame;
- (void)startTimer;
- (void)stopTimer;

@end