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