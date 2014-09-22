//
//  HYPSettingsViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 9/21/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "HYPSettingsViewController.h"
#import "HYPSetting.h"

@interface HYPSettingsViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation HYPSettingsViewController

static NSString * const HYPCellIdentifier = @"HYPCellIdentifier";

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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HYPCellIdentifier];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HYPCellIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionBody = self.dataSource[indexPath.section];
    HYPSetting *setting = sectionBody[@"items"][indexPath.row];
    cell.textLabel.text = setting.title;
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

    return sectionLabel;
}

@end