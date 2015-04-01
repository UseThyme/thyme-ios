#import "HYPSettingsViewController.h"

#import "HYPSetting.h"
#import "HYPSettingTableViewCell.h"
#import "UIColor+ANDYHex.h"

@interface HYPSettingsViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation HYPSettingsViewController

#pragma mark - Getters

- (NSMutableArray *)dataSource
{
    if (_dataSource) return _dataSource;

    _dataSource = [NSMutableArray array];

    NSMutableArray *soundsSection  = [NSMutableArray array];

    [soundsSection addObject:[[HYPSetting alloc] initWithTitle:@"Contemporary" action:^{
        NSLog(@"change contemporary sound");
    }]];

    [soundsSection addObject:[[HYPSetting alloc] initWithTitle:@"Modern" action:^{
        NSLog(@"change Modern sound");
    }]];

    [soundsSection addObject:[[HYPSetting alloc] initWithTitle:@"Neo" action:^{
        NSLog(@"change Neo sound");
    }]];

    [soundsSection addObject:[[HYPSetting alloc] initWithTitle:@"Renaisance" action:^{
        NSLog(@"change Renaisance sound");
    }]];

    [soundsSection addObject:[[HYPSetting alloc] initWithTitle:@"Classic" action:^{
        NSLog(@"change Classic sound");
    }]];

    NSMutableArray *visualSection = [NSMutableArray array];

    [visualSection addObject:[[HYPSetting alloc] initWithTitle:@"Daytime Colorscheme" action:^{
        NSLog(@"change Daytime Colorscheme");
    }]];

    [visualSection addObject:[[HYPSetting alloc] initWithTitle:@"Live sundial" action:^{
        NSLog(@"change Live sundial");
    }]];

    [visualSection addObject:[[HYPSetting alloc] initWithTitle:@"Extenden Stove" action:^{
        NSLog(@"change Extenden Stove");
    }]];

    [_dataSource addObject:@{@"title" : @"Sounds", @"items": soundsSection}];
    [_dataSource addObject:@{@"title" : @"Visuals", @"items": visualSection}];

    return _dataSource;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sc"]];
    self.tableView.backgroundView = backgroundImageView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass:[HYPSettingTableViewCell class] forCellReuseIdentifier:HYPSettingTableViewCellIdentitifer];
    self.tableView.contentInset = UIEdgeInsetsMake(30.0f, 0.0f, 0.0f, 0.0f);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionBody = self.dataSource[section];
    NSArray *items = sectionBody[@"items"];

    return items.count;
}

- (HYPSettingTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HYPSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HYPSettingTableViewCellIdentitifer
                                                            forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(HYPSettingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionBody = self.dataSource[indexPath.section];
    HYPSetting *setting = sectionBody[@"items"][indexPath.row];
    cell.setting = setting;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionBody = self.dataSource[indexPath.section];
    HYPSetting *setting = sectionBody[@"items"][indexPath.row];
    if (setting.action) {
        setting.action(self);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionBody = self.dataSource[section];
    NSString *title = sectionBody[@"title"];

    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    sectionLabel.text = [[NSString alloc] initWithFormat:@"   %@", title];
    sectionLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18.0f];
    sectionLabel.textColor = [UIColor colorFromHex:@"EE4A64"];
    sectionLabel.backgroundColor = [UIColor clearColor];

    return sectionLabel;
}

@end
