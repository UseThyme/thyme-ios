//
//  HYPHomeViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPHomeViewController.h"
#import "HYPPlateCell.h"
#import "HYPUtils.h"
#import "HYPTimerViewController.h"
#import "HYPAlarm.h"
#import "HYPLocalNotificationManager.h"
#import <HockeySDK/HockeySDK.h>

#define SHORT_TOP_MARGIN 10
#define TALL_TOP_MARGIN 50

static NSString * const HYPPlateCellIdentifier = @"HYPPlateCellIdentifier";

@interface HYPHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, HYPTimerControllerDelegate>

@property (nonatomic) CGFloat topMargin;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *ovenCollectionView;

@property (nonatomic, strong) UIImageView *ovenBackgroundImageView;
@property (nonatomic, strong) UIImageView *ovenShineImageView;

@property (nonatomic, strong) NSMutableArray *alarms;
@property (nonatomic, strong) NSMutableArray *ovenAlarms;

@property (nonatomic, strong) UIButton *feedbackButton;
@property (nonatomic, strong) NSNumber *maxMinutesLeft;

@end

@implementation HYPHomeViewController

#pragma mark - Lazy instantiation

- (void)setMaxMinutesLeft:(NSNumber *)maxMinutesLeft
{
    _maxMinutesLeft = maxMinutesLeft;
    
    if (_maxMinutesLeft) {
        self.titleLabel.text = @"YOUR DISH WILL BE DONE";
        if ([_maxMinutesLeft doubleValue] == 0.0f) {
            self.subtitleLabel.text = @"IN LESS THAN A MINUTE";
        } else {
            self.subtitleLabel.text = [HYPAlarm subtitleForHomescreenUsingMinutes:_maxMinutesLeft];
        }
    } else {
        self.titleLabel.text = [HYPAlarm titleForHomescreen];
        self.subtitleLabel.text = [HYPAlarm subtitleForHomescreen];
    }
}

- (UIButton *)feedbackButton
{
    if (!_feedbackButton) {
        _feedbackButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [_feedbackButton addTarget:self action:@selector(feedbackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat y = CGRectGetHeight(bounds) - 44.0f - 15.0f;
        _feedbackButton.frame = CGRectMake(15.0f, y, 44.0f, 44.0f);
        _feedbackButton.tintColor = [UIColor whiteColor];
    }
    return _feedbackButton;
}

- (NSMutableArray *)alarms
{
    if (!_alarms) {
        _alarms = [NSMutableArray array];
        HYPAlarm *alarm1 = [[HYPAlarm alloc] init];
        HYPAlarm *alarm2 = [[HYPAlarm alloc] init];
        HYPAlarm *alarm3 = [[HYPAlarm alloc] init];
        HYPAlarm *alarm4 = [[HYPAlarm alloc] init];
        [_alarms addObject:@[alarm1, alarm2]];
        [_alarms addObject:@[alarm3, alarm4]];
    }
    return _alarms;
}

- (NSMutableArray *)ovenAlarms
{
    if (!_ovenAlarms) {
        _ovenAlarms = [NSMutableArray array];

        HYPAlarm *alarm1 = [[HYPAlarm alloc] init];
        alarm1.oven = YES;
        [_ovenAlarms addObject:@[alarm1]];
    }
    return _ovenAlarms;
}

- (UIImageView *)ovenBackgroundImageView
{
    if (!_ovenBackgroundImageView) {
        UIImage *image = [UIImage imageNamed:@"ovenBackground"];
        CGRect bounds = [[UIScreen mainScreen] bounds];


        CGFloat topMargin;
        if ([HYPUtils isTallPhone]) {
            topMargin = image.size.height + 110.0f;
        } else {
            topMargin = image.size.height + 60.0f;
        }

        CGFloat x = CGRectGetWidth(bounds) / 2 - image.size.width / 2;
        CGFloat y = CGRectGetHeight(bounds) - topMargin;
        _ovenBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
        _ovenBackgroundImageView.image = image;
    }
    return _ovenBackgroundImageView;
}

- (UIImageView *)ovenShineImageView
{
    if (!_ovenShineImageView) {
        _ovenShineImageView = [[UIImageView alloc] initWithFrame:self.ovenBackgroundImageView.frame];
        _ovenShineImageView.image = [UIImage imageNamed:@"ovenShine"];
    }
    return _ovenShineImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        CGFloat sideMargin = 20.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;

        CGFloat topMargin;
        if ([HYPUtils isTallPhone]) {
            topMargin = 60.0f;
        } else {
            topMargin = 40.0f;
        }
        CGFloat height = 25.0f;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
        _titleLabel.font = [HYPUtils avenirLightWithSize:15.0f];
        _titleLabel.text = [HYPAlarm titleForHomescreen];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        CGFloat sideMargin = CGRectGetMinX(self.titleLabel.frame);
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        CGFloat topMargin = CGRectGetMaxY(self.titleLabel.frame);
        CGFloat height = CGRectGetHeight(self.titleLabel.frame);
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
        _subtitleLabel.font = [HYPUtils avenirBlackWithSize:19.0f];
        _subtitleLabel.text = [HYPAlarm subtitleForHomescreen];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _subtitleLabel;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {

        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = 100.0f;
        [flowLayout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        CGFloat sideMargin = 55.0f;
        CGFloat topMargin = self.topMargin;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self applyTransformToLayer:_collectionView.layer usingFactor:0.30];
    }
    return _collectionView;
}

- (UICollectionView *)ovenCollectionView
{
    if (!_ovenCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = 120.0f;
        [flowLayout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        CGFloat sideMargin = 100.0f;
        CGFloat topMargin = self.topMargin + 240.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _ovenCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width) collectionViewLayout:flowLayout];
        _ovenCollectionView.dataSource = self;
        _ovenCollectionView.delegate = self;
        _ovenCollectionView.backgroundColor = [UIColor clearColor];
        [self applyTransformToLayer:_ovenCollectionView.layer usingFactor:0.25];
    }
    return _ovenCollectionView;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([HYPUtils isTallPhone]) {
        self.topMargin = TALL_TOP_MARGIN;
    } else {
        self.topMargin = SHORT_TOP_MARGIN;
    }

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.ovenBackgroundImageView];

    [self.collectionView registerClass:[HYPPlateCell class] forCellWithReuseIdentifier:HYPPlateCellIdentifier];
    [self.ovenCollectionView registerClass:[HYPPlateCell class] forCellWithReuseIdentifier:HYPPlateCellIdentifier];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.ovenCollectionView];
    [self.view addSubview:self.ovenShineImageView];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];

#if IS_RELEASE_VERSION
    [self.view addSubview:self.feedbackButton];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissedTimerController:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([collectionView isEqual:self.collectionView]) {
        NSInteger rows = self.alarms.count;
        return rows;
    }

    NSInteger rows = self.ovenAlarms.count;
    return rows;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.collectionView]) {
        NSArray *array = [self.alarms objectAtIndex:0];
        NSInteger rows = [array count];
        return rows;
    }

    NSArray *array = [self.ovenAlarms objectAtIndex:0];
    NSInteger rows = [array count];
    return rows;
}

- (HYPPlateCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPPlateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HYPPlateCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath collectionView:collectionView];
    return cell;
}

- (void)configureCell:(HYPPlateCell *)cell atIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView;
{
    HYPAlarm *alarm = [self alarmAtIndexPath:indexPath collectionView:collectionView];
    alarm.indexPath = indexPath;
    cell.timerControl.active = alarm.active;
    [cell.timerControl addTarget:self action:@selector(timerControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self refreshTimerInCell:cell forCurrentAlarm:alarm];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPTimerViewController *timerController = [[HYPTimerViewController alloc] init];
    timerController.delegate = self;
    HYPAlarm *alarm = [self alarmAtIndexPath:indexPath collectionView:collectionView];
    timerController.alarm = alarm;
    [self.navigationController pushViewController:timerController animated:YES];
}

#pragma mark - HYPTimerControllerDelegate

- (void)dismissedTimerController:(HYPTimerViewController *)timerController
{
    self.maxMinutesLeft = nil;
    [self.collectionView reloadData];
    [self.ovenCollectionView reloadData];
}

- (void)timerControlChangedValue:(HYPTimerControl*)timerControl
{
    if ([self.maxMinutesLeft doubleValue] - 1 == timerControl.minutes) {
        self.maxMinutesLeft = @(timerControl.minutes);
    } else if ([self.maxMinutesLeft floatValue] == 0.0f && timerControl.minutes == 59.0f) {
        self.maxMinutesLeft = nil;
    }
}

#pragma mark - Feedback Action

- (void)feedbackButtonPressed:(UIButton *)button
{
    BITFeedbackManager *manager = [[BITFeedbackManager alloc] init];
    BITFeedbackComposeViewController *feedbackCompose = [manager feedbackComposeViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:feedbackCompose];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Helpers

- (HYPAlarm *)alarmAtIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView
{
    NSArray *row;
    if ([collectionView isEqual:self.collectionView]) {
        row = [self.alarms objectAtIndex:indexPath.section];
    } else {
        row = [self.ovenAlarms objectAtIndex:indexPath.section];
    }
    HYPAlarm *alarm = [row objectAtIndex:indexPath.row];
    return alarm;
}

- (void)applyTransformToLayer:(CALayer *)layer usingFactor:(CGFloat)factor
{
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -800.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * factor, 1.0f, 0.0f, 0.0f);
    layer.anchorPoint = CGPointMake(0.5, 0);
    layer.transform = rotationAndPerspectiveTransform;
}

- (void)refreshTimerInCell:(HYPPlateCell *)cell forCurrentAlarm:(HYPAlarm *)alarm
{
    UILocalNotification *existingNotification = [HYPLocalNotificationManager existingNotificationWithAlarmID:alarm.alarmID];

    if (existingNotification) {
        NSDate *firedDate = [existingNotification.userInfo objectForKey:ALARM_FIRE_DATE_KEY];
        NSNumber *numberOfSeconds = [existingNotification.userInfo objectForKey:ALARM_FIRE_INTERVAL_KEY];

        // Fired date + amount of seconds = target date
        NSTimeInterval secondsPassed = [[NSDate date] timeIntervalSinceDate:firedDate];
        NSInteger secondsLeft = ([numberOfSeconds integerValue] - secondsPassed);
        NSTimeInterval currentSecond = secondsLeft % 60;
        NSTimeInterval minutesLeft = floor(secondsLeft/60.0f);
        NSTimeInterval hoursLeft = floor(minutesLeft/60.0f);
        if (minutesLeft >= [self.maxMinutesLeft doubleValue]) {
            self.maxMinutesLeft = @(minutesLeft);
        }

        if (hoursLeft > 0) {
            minutesLeft = minutesLeft - (hoursLeft * 60);
        }
        if (minutesLeft < 0) { // clean up weird alarms
            [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
        }

        alarm.active = YES;
        cell.timerControl.active = YES;
        cell.timerControl.alarmID = alarm.alarmID;
        cell.timerControl.seconds = currentSecond;
        cell.timerControl.hours = hoursLeft;
        cell.timerControl.minutes = minutesLeft;
        [cell.timerControl startTimer];
    } else {
        alarm.active = NO;
        cell.timerControl.active = NO;
        [cell.timerControl restartTimer];
        [cell.timerControl stopTimer];
    }
}

@end
