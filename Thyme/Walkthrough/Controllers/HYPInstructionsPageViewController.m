#import "HYPInstructionsPageViewController.h"

#import "HYPInstructionViewController.h"

#import "UIColor+ANDYHex.h"

@interface HYPInstructionsPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource,
HYPInstructionViewControllerDelegate>

@property (nonatomic, strong) NSArray *instructions;

@property (nonatomic) NSUInteger index;

@end

@implementation HYPInstructionsPageViewController

#pragma mark - Getters

- (NSArray *)instructions
{
    if (_instructions) return _instructions;

    NSMutableArray *instructions = [NSMutableArray new];

    HYPInstructionViewController *instructionControllerA = [[HYPInstructionViewController alloc] initWithImage:[UIImage imageNamed:@"instructionsA"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleA", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageA", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO];
    instructionControllerA.view.tag = 0;
    [instructions addObject:instructionControllerA];

    HYPInstructionViewController *instructionControllerB = [[HYPInstructionViewController alloc] initWithImage:[UIImage imageNamed:@"instructionsB"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleB", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageB", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO];
    instructionControllerB.view.tag = 1;
    [instructions addObject:instructionControllerB];

    HYPInstructionViewController *instructionControllerC = [[HYPInstructionViewController alloc] initWithImage:[UIImage imageNamed:@"instructionsC"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleC", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageC", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO];
    instructionControllerC.view.tag = 2;
    [instructions addObject:instructionControllerC];

    HYPInstructionViewController *instructionControllerD = [[HYPInstructionViewController alloc] initWithImage:[UIImage imageNamed:@"instructionsD"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleD", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageD", nil)
                                                                                                     hasAction:YES
                                                                                                     isWelcome:NO];
    instructionControllerD.delegate = self;
    instructionControllerD.view.tag = 3;
    [instructions addObject:instructionControllerD];

    _instructions = [instructions copy];

    return _instructions;
}

#pragma mark - Initialization

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (!self) return nil;

    self.view.backgroundColor = [UIColor colorFromHex:@"EDFFFF"];

    self.dataSource = self;
    self.delegate = self;
    self.index = 0;

    [self setViewControllers:@[[self.instructions firstObject]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];

    return self;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController.view.tag == 0) return nil;

    UIViewController *controller = self.instructions[viewController.view.tag - 1];
    return controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController.view.tag == self.instructions.count - 1) return nil;

    UIViewController *controller = self.instructions[viewController.view.tag + 1];
    return controller;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.instructions.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - HYPInstructionViewControllerDelegate

- (void)instructionViewControlerDidPressAcceptButton:(HYPInstructionViewController *)instructionViewController
{
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

@end
