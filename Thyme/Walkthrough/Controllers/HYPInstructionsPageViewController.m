#import "HYPInstructionsPageViewController.h"
#import "Thyme-Swift.h"
#import "UIColor+ANDYHex.h"

@interface HYPInstructionsPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource,
InstructionDelegate>

@property (nonatomic, strong) NSArray *instructions;

@property (nonatomic) NSUInteger index;

@end

@implementation HYPInstructionsPageViewController

#pragma mark - Getters

- (NSArray *)instructions
{
    if (_instructions) return _instructions;

    NSMutableArray *instructions = [NSMutableArray new];

    InstructionController *instructionController = [[InstructionController alloc] initWithImage:[UIImage imageNamed:@"instructions"]
                                                                                                         title:NSLocalizedString(@"InstructionTitle", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessage", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO
                                                                                                         index:0];
    instructionController.delegate = self;
    instructionController.view.tag = 0;
    [instructions addObject:instructionController];

    InstructionController *instructionControllerA = [[InstructionController alloc] initWithImage:[UIImage imageNamed:@"instructionsA"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleA", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageA", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO
                                                                                                         index:1];
    instructionControllerA.delegate = self;
    instructionControllerA.view.tag = 1;
    [instructions addObject:instructionControllerA];

    InstructionController *instructionControllerB = [[InstructionController alloc] initWithImage:[UIImage imageNamed:@"instructionsB"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleB", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageB", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO
                                                                                                         index:2];
    instructionControllerB.delegate = self;
    instructionControllerB.view.tag = 2;
    [instructions addObject:instructionControllerB];

    InstructionController *instructionControllerC = [[InstructionController alloc] initWithImage:[UIImage imageNamed:@"instructionsC"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleC", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageC", nil)
                                                                                                     hasAction:NO
                                                                                                     isWelcome:NO
                                                                                                         index:3];
    instructionControllerC.delegate = self;
    instructionControllerC.view.tag = 3;
    [instructions addObject:instructionControllerC];

    InstructionController *instructionControllerD = [[InstructionController alloc] initWithImage:[UIImage imageNamed:@"instructionsD"]
                                                                                                         title:NSLocalizedString(@"InstructionTitleD", nil)
                                                                                                       message:NSLocalizedString(@"InstructionMessageD", nil)
                                                                                                     hasAction:YES
                                                                                                     isWelcome:NO
                                                                                                         index:4];
    instructionControllerD.delegate = self;
    instructionControllerD.view.tag = 4;
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

#pragma mark - View Life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController.view.tag == 0) return nil;

    self.index = viewController.view.tag - 1;
    UIViewController *controller = self.instructions[self.index];
    return controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController.view.tag == self.instructions.count - 1) return nil;

    self.index = viewController.view.tag + 1;
    UIViewController *controller = self.instructions[self.index];
    return controller;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.instructions.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.index;
}

#pragma mark - HYPInstructionViewControllerDelegate

- (void)instructionViewControlerDidTapAcceptButton:(InstructionController *)instructionViewController
{
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (void)instructionViewControlerDidTapPreviousButton:(InstructionController *)instructionViewController
{
    if (self.index == 0) return;

    self.index = instructionViewController.view.tag - 1;

    UIViewController *controller = self.instructions[self.index];

    [self setViewControllers:@[controller]
                   direction:UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:nil];
}

- (void)instructionViewControlerDidTapNextButton:(InstructionController *)instructionViewController
{
    if (self.index == self.instructions.count - 1) return;

    self.index = instructionViewController.view.tag + 1;

    UIViewController *controller = self.instructions[self.index];

    [self setViewControllers:@[controller]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

@end
