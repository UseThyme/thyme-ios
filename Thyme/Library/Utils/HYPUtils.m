#import "HYPUtils.h"

@implementation HYPUtils

+ (UIFont *)avenirLightWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Light" size:size];
}

+ (UIFont *)avenirBookWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Book" size:size];
}

+ (UIFont *)avenirBlackWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Black" size:size];
}

+ (UIFont *)avenirHeavyWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Heavy" size:size];
}

+ (UIFont *)helveticaNeueUltraLightWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
}

+ (BOOL)isTallPhone
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return (bounds.size.height > 480.0f);
}

@end
