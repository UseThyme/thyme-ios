#import "UIScreen+ANDYResolutions.h"

@implementation UIScreen (ANDYResolutions)

+ (BOOL)andy_isPhone
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (BOOL)andy_isPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

@end
