//
//  HYPTimerViewController.h
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPViewController.h"

@protocol HYPTimerControllerDelegate;
@class HYPAlarm;

@interface HYPTimerViewController : HYPViewController
@property (nonatomic, weak) id <HYPTimerControllerDelegate> delegate;
@property (nonatomic, strong) HYPAlarm *alarm;
@end

@protocol HYPTimerControllerDelegate <NSObject>
- (void)dismissedTimerController:(HYPTimerViewController *)timerController;
@end