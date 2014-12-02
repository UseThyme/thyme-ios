@import UIKit;

@protocol HYPWelcomeViewControllerDelegate;

@interface HYPWelcomeViewController : UIViewController

@property (nonatomic, weak) id <HYPWelcomeViewControllerDelegate> delegate;

@end

@protocol HYPWelcomeViewControllerDelegate <NSObject>

- (void)welcomeViewControlerDidPressAcceptButton:(HYPWelcomeViewController *)welcomeViewController;

@end
