#import <UIKit/UIKit.h>

@class HYPAlarm;

@interface HYPTimerControl : UIControl

@property (nonatomic, strong) HYPAlarm *alarm;
@property (nonatomic, strong) NSString *alarmID;
@property (nonatomic, strong) NSString *title;

@property (nonatomic) NSInteger hours;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger seconds;
@property (nonatomic) BOOL touchesAreActive;

// SimpleMode
// YES: Timer on main screen
// NO: Timer in detail screen
@property (nonatomic, getter = isCompleteMode) BOOL completeMode;

// Active
// YES: This timer has an alarm
// NO: No alarm was set for this timer
@property (nonatomic, getter = isActive) BOOL active;

- (instancetype)initCompleteModeWithFrame:(CGRect)frame;
- (void)restartTimer;
- (void)startTimer;
- (void)stopTimer;

@end