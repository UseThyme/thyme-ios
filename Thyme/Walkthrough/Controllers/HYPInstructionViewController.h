@import UIKit;

@protocol HYPInstructionViewControllerDelegate;

@interface HYPInstructionViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                      message:(NSString *)message
                    hasAction:(BOOL)hasAction
                    isWelcome:(BOOL)isWelcome
                        index:(NSInteger)index;

@property (nonatomic, weak) id <HYPInstructionViewControllerDelegate> delegate;
@property (nonatomic) BOOL isFirst;
@property (nonatomic) BOOL isLast;

- (void)canceledNotifications;

@end

@protocol HYPInstructionViewControllerDelegate <NSObject>

@optional
- (void)instructionViewControlerDidPressAcceptButton:(HYPInstructionViewController *)instructionViewController;
- (void)instructionViewControlerDidPressNextButton:(HYPInstructionViewController *)instructionViewController;
- (void)instructionViewControlerDidPressPreviousButton:(HYPInstructionViewController *)instructionViewController;

@end
