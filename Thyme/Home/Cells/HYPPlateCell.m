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
#import "HYPTimerControl.h"

@interface HYPPlateCell ()
@property (nonatomic, strong) HYPTimerControl *timerControl;
@end

@implementation HYPPlateCell

- (HYPTimerControl *)timerControl
{
    if (!_timerControl) {
        _timerControl = [[HYPTimerControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
    }
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
