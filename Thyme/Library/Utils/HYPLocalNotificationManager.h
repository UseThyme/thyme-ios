@import Foundation;
@import UIKit;

@interface HYPLocalNotificationManager : NSObject
+ (instancetype)sharedManager;
+ (void)createNotificationUsingNumberOfSeconds:(NSInteger)numberOfSeconds message:(NSString *)message actionTitle:(NSString *)actionTitle alarmID:(NSString *)alarmID;
+ (UILocalNotification *)existingNotificationWithAlarmID:(NSString *)alarmID;
+ (void)cancelAllLocalNotifications;
@end
