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
    UIImage *image;
    if ([UIScreen andy_isPad]) {
        image = [UIImage imageNamed:@"background~iPad"];
    } else {
        image = [UIImage imageNamed:@"background"];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

@end