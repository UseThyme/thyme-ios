//
//  HYPViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPViewController.h"

@interface HYPViewController ()

@end

@implementation HYPViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

@end