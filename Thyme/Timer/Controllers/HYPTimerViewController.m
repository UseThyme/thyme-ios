//
//  HYPTimerViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPTimerViewController.h"
#import "HYPTimerControl.h"
#import "TBCircularSlider.h"

@interface HYPTimerViewController ()
@property (nonatomic, strong) HYPTimerControl *timerController;
@end

@implementation HYPTimerViewController

- (HYPTimerControl *)timerController
{
    if (!_timerController) {
        CGFloat sideMargin = 0.0f;
        CGFloat topMargin = 60.0f;//40.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _timerController = [[HYPTimerControl alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
    }
    return _timerController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.timerController];
}

@end
