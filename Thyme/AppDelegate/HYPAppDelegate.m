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
#import <HockeySDK/HockeySDK.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface HYPAppDelegate () <BITHockeyManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation HYPAppDelegate

- (AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"caf"];
        NSURL *file = [[NSURL alloc] initFileURLWithPath:path];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&error];
        if (error) {
            NSLog(@"error loading sound: %@", [error description]);
        }
    }
    return _audioPlayer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if IS_RELEASE_VERSION
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"2cf664c4f20eed78d8ef3fe53f27fe3b" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[UIApplication sharedApplication].idleTimerDisabled = YES;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    HYPHomeViewController *homeController = [[HYPHomeViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeController];
    navController.navigationBarHidden = YES;
    self.window.rootViewController = navController;

    //HYPTimerViewController *timerController = [[HYPTimerViewController alloc] init];
    //self.window.rootViewController = timerController;

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    [[[UIAlertView alloc] initWithTitle:@"Your meal is ready!" message:nil delegate:self cancelButtonTitle:@"OK, thanks" otherButtonTitles:nil, nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.audioPlayer stop];
}

@end