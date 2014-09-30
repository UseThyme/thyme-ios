//
//  HYPSettingTableViewCell.h
//  Thyme
//
//  Created by Elvis Nunez on 9/30/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

@import UIKit;

@class HYPSetting;

static NSString * const HYPSettingTableViewCellIdentitifer = @"HYPSettingTableViewCellIdentitifer";

@interface HYPSettingTableViewCell : UITableViewCell

@property (nonatomic, weak) HYPSetting *setting;

@end
