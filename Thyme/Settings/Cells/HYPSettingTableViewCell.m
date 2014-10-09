//
//  HYPSettingTableViewCell.m
//  Thyme
//
//  Created by Elvis Nunez on 9/30/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "HYPSettingTableViewCell.h"
#import "HYPSetting.h"

@implementation HYPSettingTableViewCell

#pragma mark - Initializers

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.textLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16.0f];
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor colorFromHex:@"B5B4B5"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

#pragma mark - Setters

- (void)setSetting:(HYPSetting *)setting
{
    _setting = setting;

    self.textLabel.text = setting.title;
}

#pragma mark - Private methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.textLabel.textColor = [UIColor colorFromHex:@"1C1A1C"];
    } else {
        self.textLabel.textColor = [UIColor colorFromHex:@"B5B4B5"];
    }
}

@end
