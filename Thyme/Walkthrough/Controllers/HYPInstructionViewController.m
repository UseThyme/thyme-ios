#import "HYPInstructionViewController.h"

#import "HYPUtils.h"
#import "HYPInstructionsPageViewController.h"

#import "UIColor+ANDYHex.h"
#import "UIButton+ANDYHighlighted.h"

static const NSInteger HYPIconImageViewTopMargin = 50.0f;

static const NSInteger HYPTitleLabelTopMargin = 240.0f;
static const NSInteger HYPTitleLabelHeight = 60.0f;

static const NSInteger HYPMessageTextViewHorizontalMargin = 20.0f;
static const NSInteger HYPMessageTextViewHeight = 150.0f;

static const NSInteger HYPAcceptButtonBottomMargin = 30.0f;
static const NSInteger HYPAcceptButtonHorizontalMargin = 30.0f;
static const NSInteger HYPAcceptButtonHeight = 44.0f;

@interface HYPInstructionViewController ()

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *message;
@property (nonatomic) BOOL hasAction;
@property (nonatomic) BOOL isWelcome;
@property (nonatomic) BOOL isHidden;

@end

@implementation HYPInstructionViewController

#pragma mark - Initializers

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                      message:(NSString *)message
                    hasAction:(BOOL)hasAction
                    isWelcome:(BOOL)isWelcome
{
    self = [super init];
    if (!self) return nil;

    _image = image;
    self.title = title;
    _message = message;
    _hasAction = hasAction;
    _isWelcome = isWelcome;

    return self;
}

#pragma mark - Getters

- (UIImageView *)iconImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = [self iconImageViewFrameForImageView:imageView];

    return imageView;
}

- (UILabel *)titleLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    label.text = self.title;
    label.font = [HYPUtils avenirBookWithSize:27.0f];
    label.textColor = [UIColor colorFromHex:@"0896A2"];
    label.textAlignment = NSTextAlignmentCenter;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 568.0f) {
        label.font = [HYPUtils avenirBookWithSize:35.0f];
    } else if (deviceHeight >= 667.0f) {
        label.font = [HYPUtils avenirBookWithSize:40.0f];
    }

    return label;
}

- (UITextView *)messageTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:[self messageTextViewFrame]];
    textView.text = self.message;
    textView.font = [HYPUtils avenirLightWithSize:14.0f];
    textView.textColor = [UIColor colorFromHex:@"0896A2"];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 568.0f) {
        textView.font = [HYPUtils avenirLightWithSize:16.0f];
    } else if (deviceHeight >= 667.0f) {
        textView.font = [HYPUtils avenirLightWithSize:18.0f];
    }

    return textView;
}

- (UIButton *)acceptButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorFromHex:@"FF5C5C"];
    button.highlightedBackgroundColor = [UIColor colorFromHex:@"E94F4F"];
    button.layer.cornerRadius = 5.0f;
    button.frame = [self acceptButtonFrame];
    button.titleLabel.font = [HYPUtils avenirHeavyWithSize:15.0f];
    [button setTitle:NSLocalizedString(@"InstructionAction", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(acceptButtonAction) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIButton *)previousButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = [self previousButtonFrame];
    button.titleLabel.font = [HYPUtils avenirLightWithSize:15.0f];
    [button setTitleColor:[UIColor colorFromHex:@"FA5A58"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Previous", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(previousButtonAction) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (UIButton *)nextButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = [self nextButtonFrame];
    button.titleLabel.font = [HYPUtils avenirLightWithSize:15.0f];
    [button setTitleColor:[UIColor colorFromHex:@"FA5A58"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

#pragma mark - Frames

- (CGRect)iconImageViewFrameForImageView:(UIImageView *)imageView
{
    CGRect iconImageViewFrame = imageView.frame;

    if (self.isWelcome) {
        iconImageViewFrame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageView.frame)) / 2.0f;
        iconImageViewFrame.origin.y = HYPIconImageViewTopMargin;
    } else {
        iconImageViewFrame.origin.y = HYPIconImageViewTopMargin;

        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat deviceHeight = bounds.size.height;
        if (deviceHeight == 480.0f) {
            iconImageViewFrame.origin.y -= 25.0f;
        }

        if (deviceHeight == 568.0f || deviceHeight == 480.0f) {
            iconImageViewFrame.size.width = 640.0f/4.0f;
            iconImageViewFrame.size.height = 780.0f/4.0f;
        } else if (deviceHeight >= 667.0f) {
            iconImageViewFrame.size.width = 640.0f/3.0f;
            iconImageViewFrame.size.height = 780.0f/3.0f;
        }

        iconImageViewFrame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(iconImageViewFrame)) / 2.0f;
    }

    return iconImageViewFrame;
}

- (CGRect)titleLabelFrame
{
    CGFloat y = HYPTitleLabelTopMargin;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 480.0f) {
        if (!self.isWelcome) y -= 40.0f;
    } else if (deviceHeight == 667.0f) {
        y += 60.0f;
    } else if (deviceHeight == 736.0f) {
        y += 70.0f;
    }

    if (!self.isWelcome) {
        y += 20.0f;
    }

    return CGRectMake(0.0f, y, CGRectGetWidth(self.view.frame), HYPTitleLabelHeight);
}

- (CGRect)messageTextViewFrame
{
    CGFloat y = HYPTitleLabelTopMargin + HYPTitleLabelHeight;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 480.0f) {
        if (!self.isWelcome) y -= 50.0f;
    } else if (deviceHeight == 667.0f) {
        y += 60.0f;
    } else if (deviceHeight == 736.0f) {
        y += 80.0f;
    }

    if (!self.isWelcome) {
        y += 20.0f;
    }

    return CGRectMake(HYPMessageTextViewHorizontalMargin,
                      y,
                      CGRectGetWidth(self.view.frame) - HYPMessageTextViewHorizontalMargin * 2.0f,
                      HYPMessageTextViewHeight);
}

- (CGRect)acceptButtonFrame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;
    CGFloat y = deviceHeight - HYPAcceptButtonHeight - HYPAcceptButtonBottomMargin;

    if (!self.isWelcome) {
        y -= 15.0f;
    }

    return CGRectMake(HYPAcceptButtonHorizontalMargin,
                      y,
                      CGRectGetWidth(self.view.frame) - HYPAcceptButtonHorizontalMargin * 2.0f,
                      HYPAcceptButtonHeight);
}

- (CGRect)previousButtonFrame
{
    return CGRectMake(10.0f, 10.0f, 80.0f, 50.0f);
}

- (CGRect)nextButtonFrame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat width = 80.0f;
    CGFloat x = CGRectGetWidth(bounds) - width - 10.0f;

    return CGRectMake(x, 10.0f, 80.0f, 50.0f);
}

#pragma mark - View lifycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorFromHex:@"EDFFFF"];

    UIImageView *iconImageView = [self iconImageView];
    [self.view addSubview:iconImageView];

    UILabel *titleLabel = [self titleLabel];
    [self.view addSubview:titleLabel];

    UITextView *messageTextView = [self messageTextView];
    [self.view addSubview:messageTextView];

    UIButton *previousButton = [self previousButton];
    [self.view addSubview:previousButton];

    UIButton *nextButton = [self nextButton];
    [self.view addSubview:nextButton];

    if (self.hasAction) {
        UIButton *acceptButton = [self acceptButton];
        [self.view addSubview:acceptButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    self.isHidden = YES;
}

#pragma mark - Actions

- (void)acceptButtonAction
{
    if ([self.delegate respondsToSelector:@selector(instructionViewControlerDidPressAcceptButton:)]) {
        [self.delegate instructionViewControlerDidPressAcceptButton:self];
    }
}

- (void)previousButtonAction
{
    if ([self.delegate respondsToSelector:@selector(instructionViewControlerDidPressPreviousButton:)]) {
        [self.delegate instructionViewControlerDidPressPreviousButton:self];
    }
}

- (void)nextButtonAction
{
    if ([self.delegate respondsToSelector:@selector(instructionViewControlerDidPressNextButton:)]) {
        [self.delegate instructionViewControlerDidPressNextButton:self];
    }
}

#pragma mark - Public methods

- (void)canceledNotifications
{
    if (self.isHidden) return;

    HYPInstructionsPageViewController *instructionsController = [[HYPInstructionsPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                                                             navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                                                           options:nil];

    [self.navigationController pushViewController:instructionsController animated:YES];
}

@end
