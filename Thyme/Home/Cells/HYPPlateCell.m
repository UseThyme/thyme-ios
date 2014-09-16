//
//  HYPPlateCell.m
//  Thyme
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPPlateCell.h"
#import "HYPUtils.h"
#import "UIColor+HYPExtensions.h"

@interface HYPPlateCell ()

@end

@implementation HYPPlateCell

- (HYPTimerControl *)timerControl
{
    if (_timerControl) return _timerControl;

    CGRect frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
    _timerControl = [[HYPTimerControl alloc] initWithFrame:frame];
    _timerControl.userInteractionEnabled = NO;
    _timerControl.backgroundColor = [UIColor clearColor];

    return _timerControl;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.timerControl];
    }
    return self;
}

@end
