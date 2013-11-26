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
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HYPPlateCell

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
    }
    return _backgroundImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [HYPUtils helveticaNeueUltraLightWithSize:63.0f];
        _titleLabel.text = @"9";
        _titleLabel.textColor = [UIColor colorFromHexString:@"4bd1c2"];
    }
    return _titleLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView.image = [UIImage imageNamed:@"inactivePlate"];
        self.backgroundView = self.backgroundImageView;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)setActive:(BOOL)active
{
    _active = active;

    if (active) {
        self.backgroundImageView.image = [UIImage imageNamed:@"activePlate"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"inactivePlate"];
    }
}

@end
