//
//  UIScreen+ANDYResolutions.m
//
//  Created by Elvis Nunez on 2/13/14.
//  Copyright (c) 2014 Elvis Nuñez. All rights reserved.
//

#import "UIScreen+ANDYResolutions.h"

@implementation UIScreen (ANDYResolutions)

+ (BOOL)andy_isPhone
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return YES;
    }

    return NO;
}

+ (BOOL)andy_isPad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }

    return NO;
}

+ (BOOL)andy_isSmallScreen
{
    BOOL isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (isPhone && [[UIScreen mainScreen] bounds].size.height == 480.0f) {
        return YES;
    }
    return NO;
}

@end
