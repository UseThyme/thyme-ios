//
//  HYPSettingsViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 9/21/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "HYPSettingsViewController.h"

@interface HYPSettingsViewController ()

@end

@implementation HYPSettingsViewController

static NSString * const HYPCellIdentifier = @"HYPCellIdentifier";

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HYPCellIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HYPCellIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = @"Hola";
}


@end