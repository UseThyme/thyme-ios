
#import "BKEAnimatedGradientView.h"

@interface BKEAnimatedGradientView()

@property (nonatomic, strong) CAGradientLayer *gradient;

@property (nonatomic) CGFloat duration;

@end

@implementation BKEAnimatedGradientView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self.layer addSublayer:self.gradient];

    return self;
}

#pragma mark - Setters

- (void)setGradientColors:(NSArray *)gradientColors
{
    _gradientColors = gradientColors;

    NSMutableArray *cgColors = [NSMutableArray new];

    for (UIColor *color in _gradientColors) {
        [cgColors addObject:(id)color.CGColor];
    }

    _gradientColors = cgColors;

    self.gradient.colors = _gradientColors;
}

#pragma mark - Getters

- (CAGradientLayer *)gradient
{
    if (_gradient) return _gradient;

    _gradient = [CAGradientLayer layer];
    _gradient.frame = self.frame;
    _gradient.locations = @[@0.05,@0.5,@0.95];

    return _gradient;
}

#pragma - Public methods

- (void)changeGradientWithAnimation:(NSArray *)gradientColors delay:(CGFloat)delay duration:(CGFloat)duration
{
    self.duration = duration;

    [self performSelector:@selector(startAnimation:) withObject:gradientColors afterDelay:delay];
}

#pragma - Private methods

- (void)startAnimation:(NSArray *)gradientColors
{
    [UIView animateWithDuration:self.duration animations:^{

        [CATransaction begin];

        [CATransaction setAnimationDuration:self.duration];

        [self setGradientColors:gradientColors];

        [CATransaction commit];

    }];
}

@end
