#import "HYPInstructionViewController.h"

#import "UIColor+ANDYHex.h"
#import "HYPUtils.h"
#import "HYPInstructionsPageViewController.h"

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
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:self.image];
    iconImageView.frame = [self iconImageViewFrameForImageView:iconImageView];

    return iconImageView;
}

- (UILabel *)titleLabel
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    titleLabel.text = self.title;
    titleLabel.font = [HYPUtils avenirBookWithSize:27.0f];
    titleLabel.textColor = [UIColor colorFromHex:@"0896A2"];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 568.0f) {
        titleLabel.font = [HYPUtils avenirBookWithSize:35.0f];
    } else if (deviceHeight >= 667.0f) {
        titleLabel.font = [HYPUtils avenirBookWithSize:40.0f];
    }

    return titleLabel;
}

- (UITextView *)messageTextView
{
    UITextView *messageTextView = [[UITextView alloc] initWithFrame:[self messageTextViewFrame]];
    messageTextView.text = self.message;
    messageTextView.font = [HYPUtils avenirLightWithSize:14.0f];
    messageTextView.textColor = [UIColor colorFromHex:@"0896A2"];
    messageTextView.textAlignment = NSTextAlignmentCenter;
    messageTextView.backgroundColor = [UIColor clearColor];
    messageTextView.editable = NO;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 568.0f) {
        messageTextView.font = [HYPUtils avenirLightWithSize:16.0f];
    } else if (deviceHeight >= 667.0f) {
        messageTextView.font = [HYPUtils avenirLightWithSize:18.0f];
    }

    return messageTextView;
}

- (UIButton *)acceptButton
{
    UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptButton.backgroundColor = [UIColor colorFromHex:@"FF5C5C"];
    acceptButton.layer.cornerRadius = 5.0f;
    acceptButton.frame = [self acceptButtonFrame];
    [acceptButton setTitle:NSLocalizedString(@"InstructionAction", nil) forState:UIControlStateNormal];
    acceptButton.titleLabel.font = [HYPUtils avenirHeavyWithSize:15.0f];
    [acceptButton addTarget:self action:@selector(acceptButtonAction) forControlEvents:UIControlEventTouchUpInside];

    return acceptButton;
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
        y += 20.0f;
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
        y += 20.0f;
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

    if (self.hasAction) {
        UIButton *acceptButton = [self acceptButton];
        [self.view addSubview:acceptButton];
    }
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
