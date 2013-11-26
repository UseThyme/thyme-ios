//
//  UIColor+HYPExtensions.h
//  Thyme
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HYPExtensions)

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
