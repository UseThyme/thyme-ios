//
//  HYPSetting.m
//
//  Created by Christoffer Winterkvist on 7/4/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

@interface HYPSetting : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void (^action)();

- (instancetype)initWithTitle:(NSString *)title action:(void (^)())action;

@end
