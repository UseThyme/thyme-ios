#import "HYPWelcomeViewController.h"

#import "UIColor+ANDYHex.h"
#import "HYPUtils.h"

static const NSInteger HYPIconImageViewTopMargin = 50.0f;

static const NSInteger HYPTitleLabelTopMargin = 240.0f;
static const NSInteger HYPTitleLabelHeight = 60.0f;

static const NSInteger HYPMessageTextViewHorizontalMargin = 20.0f;
static const NSInteger HYPMessageTextViewHeight = 100.0f;

static const NSInteger HYPAcceptButtonHorizontalMargin = 30.0f;
static const NSInteger HYPAcceptButtonHeight = 44.0f;

@interface HYPWelcomeViewController ()

@end

@implementation HYPWelcomeViewController

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    self.view.backgroundColor = [UIColor colorFromHex:@"F2F2F2"];

    UIImageView *iconImageView = [self iconImageView];
    [self.view addSubview:iconImageView];

    UILabel *titleLabel = [self titleLabel];
    [self.view addSubview:titleLabel];

    UITextView *messageTextView = [self messageTextView];
    [self.view addSubview:messageTextView];

    UIButton *acceptButton = [self acceptButton];
    [self.view addSubview:acceptButton];

    return self;
}

#pragma mark - Views

- (UIImageView *)iconImageView
{
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomeIcon"]];
    iconImageView.frame = [self iconImageViewFrameForImageView:iconImageView];

    return iconImageView;
}

- (UILabel *)titleLabel
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    titleLabel.text = @"Hello there!";
    titleLabel.font = [HYPUtils avenirBookWithSize:35.0f];
    titleLabel.textColor = [UIColor colorFromHex:@"0896A2"];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    return titleLabel;
}

- (UITextView *)messageTextView
{
    UITextView *messageTextView = [[UITextView alloc] initWithFrame:[self messageTextViewFrame]];
    messageTextView.text = @"Thyme is a timer app and needs the ability to pop up a notification and alert you with a sound when it's done.";
    messageTextView.font = [HYPUtils avenirLightWithSize:15.0f];
    messageTextView.textColor = [UIColor colorFromHex:@"0896A2"];
    messageTextView.textAlignment = NSTextAlignmentCenter;
    messageTextView.backgroundColor = [UIColor colorFromHex:@"F2F2F2"];
    messageTextView.editable = NO;

    return messageTextView;
}

- (UIButton *)acceptButton
{
    UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptButton.backgroundColor = [UIColor colorFromHex:@"FF5C5C"];
    acceptButton.layer.cornerRadius = 5.0f;
    acceptButton.frame = [self acceptButtonFrame];
    [acceptButton setTitle:@"Ok, got it!" forState:UIControlStateNormal];
    acceptButton.titleLabel.font = [HYPUtils avenirHeavyWithSize:15.0f];
    [acceptButton addTarget:self action:@selector(acceptButtonAction) forControlEvents:UIControlEventTouchUpInside];

    return acceptButton;
}

#pragma mark - Frames

- (CGRect)iconImageViewFrameForImageView:(UIImageView *)imageView
{
    CGRect iconImageViewFrame = imageView.frame;
    iconImageViewFrame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(imageView.frame)) / 2.0f;
    iconImageViewFrame.origin.y = HYPIconImageViewTopMargin;

    return iconImageViewFrame;
}

- (CGRect)titleLabelFrame
{
    CGFloat y = HYPTitleLabelTopMargin;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 667.0f) {
        y += 20.0f;
    } else if (deviceHeight == 736.0f) {
        y += 70.0f;
    }

    return CGRectMake(0.0f, y, CGRectGetWidth(self.view.frame), HYPTitleLabelHeight);
}

- (CGRect)messageTextViewFrame
{
    CGFloat y = HYPTitleLabelTopMargin + HYPTitleLabelHeight;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 667.0f) {
        y += 20.0f;
    } else if (deviceHeight == 736.0f) {
        y += 70.0f;
    }

    return CGRectMake(HYPMessageTextViewHorizontalMargin,
                      y,
                      CGRectGetWidth(self.view.frame) - HYPMessageTextViewHorizontalMargin * 2.0f,
                      HYPMessageTextViewHeight);
}

- (CGRect)acceptButtonFrame
{
    CGFloat y = HYPTitleLabelTopMargin + HYPTitleLabelHeight + HYPMessageTextViewHeight;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    if (deviceHeight == 667.0f) {
        y += 60.0f;
    } else if (deviceHeight == 736.0f) {
        y += 120.0f;
    }

    return CGRectMake(HYPAcceptButtonHorizontalMargin,
                      y,
                      CGRectGetWidth(self.view.frame) - HYPAcceptButtonHorizontalMargin * 2.0f,
                      HYPAcceptButtonHeight);
}

#pragma mark - Actions

- (void)acceptButtonAction
{
    if ([self.delegate respondsToSelector:@selector(welcomeViewControlerDidPressAcceptButton:)]) {
        [self.delegate welcomeViewControlerDidPressAcceptButton:self];
    }
}

@end
