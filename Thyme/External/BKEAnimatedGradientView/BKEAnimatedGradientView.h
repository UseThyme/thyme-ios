
@import UIKit;

@interface BKEAnimatedGradientView : UIView

/*
 Array of Colors
*/
@property (nonatomic, copy) NSArray *gradientColors;

- (void)changeGradientWithAnimation:(NSArray *)gradientColors delay:(CGFloat)delay duration:(CGFloat)duration;

@end
