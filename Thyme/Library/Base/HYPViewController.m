#import "HYPViewController.h"
#import "BKEAnimatedGradientView.h"
#import "UIColor+HYPExtensions.h"

@interface HYPViewController ()

@end

@implementation HYPViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.userInteractionEnabled = YES;

    BKEAnimatedGradientView *gradientView = [[BKEAnimatedGradientView alloc] initWithFrame:self.view.frame];
    [gradientView setGradientColors:@[[UIColor colorFromHexString:@"3bf5e6"], [UIColor colorFromHexString:@"00979b"]]];
    [self.view addSubview:gradientView];

    //[gradientView changeGradientWithAnimation:@[[UIColor redColor], [UIColor orangeColor]] delay:1.0f duration:5.0f];
}

@end
