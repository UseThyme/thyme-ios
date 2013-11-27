//
//  HYPAppDelegate.m
//  Thyme
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPAppDelegate.h"
#import "HYPHomeViewController.h"
#import "HYPTimerViewController.h"

@implementation HYPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    //HYPHomeViewController *homeController = [[HYPHomeViewController alloc] init];
    //self.window.rootViewController = homeController;

    HYPTimerViewController *timerController = [[HYPTimerViewController alloc] init];
    self.window.rootViewController = timerController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end