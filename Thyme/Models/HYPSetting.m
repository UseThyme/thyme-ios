#import "HYPSetting.h"

@implementation HYPSetting

- (instancetype)initWithTitle:(NSString *)title action:(void (^)())action
{
    self = [super init];

    self.title = title;
    self.action = action;

    return self;
}

@end
