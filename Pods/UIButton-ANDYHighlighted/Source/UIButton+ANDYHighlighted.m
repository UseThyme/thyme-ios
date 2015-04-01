#import <objc/runtime.h>

#import "UIButton+ANDYHighlighted.h"

@interface UIButton (ANDYHighlightedPrivate)

@property (nonatomic, strong) UIColor *originalColor;

@end

@implementation UIButton (ANDYHighlighted)

@dynamic highlightedBackgroundColor;

- (instancetype)originalColor
{
    return objc_getAssociatedObject(self, @selector(originalColor));
}

- (instancetype)highlightedBackgroundColor
{
    return objc_getAssociatedObject(self, @selector(highlightedBackgroundColor));
}

- (void)setOriginalColor:(UIColor *)anOriginalColor
{
    objc_setAssociatedObject(self, @selector(originalColor), anOriginalColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setHighlightedBackgroundColor:(UIColor *)aHighlightedBackgroundColor
{
    self.originalColor = self.backgroundColor;

    objc_setAssociatedObject(self, @selector(highlightedBackgroundColor), aHighlightedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    self.backgroundColor = self.highlighted ? self.highlightedBackgroundColor : self.originalColor;
}

@end
