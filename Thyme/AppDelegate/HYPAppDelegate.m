#import "HYPAppDelegate.h"
#import "HYPHomeViewController.h"
#import "HYPTimerViewController.h"
#import <HockeySDK/HockeySDK.h>
@import AVFoundation;
#import "HYPAlarm.h"
#import "HYPLocalNotificationManager.h"
#import "UIColor+ANDYHex.h"

#ifdef DEBUG
/// Tests if .xctest bundle is loaded, so returns YES if the app is running with XCTest framework.
static inline BOOL IsUnitTesting() __attribute__((const));
static inline BOOL IsUnitTesting()
{
    NSDictionary *environment = [NSProcessInfo processInfo].environment;
    NSString *injectBundlePath = environment[@"XCInjectBundle"];
    return [injectBundlePath.pathExtension isEqualToString:@"xctest"];
}
#endif

@interface HYPAppDelegate () <BITHockeyManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) HYPHomeViewController *homeController;

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

- (HYPHomeViewController *)homeController
{
    if (_homeController) return _homeController;

    _homeController = [[HYPHomeViewController alloc] init];

    return _homeController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    if (IsUnitTesting()) {
        return YES;
    }
#endif

#if IS_PRE_RELEASE_VERSION
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"2cf664c4f20eed78d8ef3fe53f27fe3b" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorFromHex:@"D0E8E8"];
    pageControl.currentPageIndicatorTintColor = [UIColor colorFromHex:@"FF5C5C"];
    pageControl.backgroundColor = [UIColor colorFromHex:@"EDFFFF"];

//    application.applicationSupportsShakeToEdit = YES;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        [self handleLocalNotification:notification playingSound:NO];
    }

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.homeController];
    navController.navigationBarHidden = YES;
    self.window.rootViewController = navController;

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    BOOL playingSound = YES;
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        playingSound = NO;
    }

    if (notification) {
        [self handleLocalNotification:notification playingSound:playingSound];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.audioPlayer stop];
}

- (void)handleLocalNotification:(UILocalNotification *)notification playingSound:(BOOL)playingSound
{
    NSString *alarmID = (notification.userInfo)[ALARM_ID_KEY];
    [self cleanUpLocalNotificationWithAlarmID:alarmID];

    if (playingSound) {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
    [[[UIAlertView alloc] initWithTitle:notification.alertBody
                                message:nil
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)cleanUpLocalNotificationWithAlarmID:(NSString *)alarmID
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];

    UILocalNotification *notification = [HYPLocalNotificationManager existingNotificationWithAlarmID:alarmID];
    if (notification) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    if (notificationSettings.types != types) {
        [self.homeController canceledNotifications];
    } else {
        [self.homeController registeredForNotifications];
    }
}

//#pragma mark - Shake Support
//
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventSubtypeMotionShake) {
//        NSLog(@"motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event");
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"appWasShaked" object:nil];
//    }
//}

@end
