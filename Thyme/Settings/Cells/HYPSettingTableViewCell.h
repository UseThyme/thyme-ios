@import UIKit;

@class HYPSetting;

static NSString * const HYPSettingTableViewCellIdentitifer = @"HYPSettingTableViewCellIdentitifer";

@interface HYPSettingTableViewCell : UITableViewCell

@property (nonatomic, weak) HYPSetting *setting;

@end
