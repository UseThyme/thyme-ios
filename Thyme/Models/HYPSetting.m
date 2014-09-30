//
//  HYPSetting.m
//
//  Created by Christoffer Winterkvist on 7/4/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

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
