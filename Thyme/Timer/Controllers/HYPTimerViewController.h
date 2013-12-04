//
//  HYPTimerViewController.h
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPViewController.h"
@class HYPAlarm;

@interface HYPTimerViewController : HYPViewController
@property (nonatomic, strong) HYPAlarm *alarm;
@end
