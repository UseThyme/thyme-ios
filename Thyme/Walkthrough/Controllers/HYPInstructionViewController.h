@import UIKit;

@protocol HYPInstructionViewControllerDelegate;

@interface HYPInstructionViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                      message:(NSString *)message
                    hasAction:(BOOL)hasAction
                    isWelcome:(BOOL)isWelcome;

@property (nonatomic, weak) id <HYPInstructionViewControllerDelegate> delegate;

- (void)canceledNotifications;

@end

@protocol HYPInstructionViewControllerDelegate <NSObject>

- (void)instructionViewControlerDidPressAcceptButton:(HYPInstructionViewController *)instructionViewController;

@end
