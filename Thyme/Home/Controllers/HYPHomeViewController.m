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

#define IOS6_SHORT_TOP_MARGIN -10.0f
#define IOS6_TALL_TOP_MARGIN 30.0f

#define SHORT_TOP_MARGIN 10.0f
#define TALL_TOP_MARGIN 50.0f

static NSString * const HYPPlateCellIdentifier = @"HYPPlateCellIdentifier";

@interface HYPHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, HYPTimerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) CGFloat topMargin;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *ovenCollectionView;

@property (nonatomic, strong) UIImageView *ovenBackgroundImageView;
@property (nonatomic, strong) UIImageView *ovenShineImageView;

@property (nonatomic, strong) NSMutableArray *alarms;
@property (nonatomic, strong) NSMutableArray *ovenAlarms;

@property (nonatomic, strong) NSNumber *maxMinutesLeft;

@property (nonatomic) BOOL deleteTimersMessageIsBeingDisplayed;

@end

@implementation HYPHomeViewController

#pragma mark - Lazy instantiation

- (void)setMaxMinutesLeft:(NSNumber *)maxMinutesLeft
{
    _maxMinutesLeft = maxMinutesLeft;

    if (_maxMinutesLeft) {
        self.titleLabel.text = NSLocalizedString(@"YOUR DISH WILL BE DONE", @"YOUR DISH WILL BE DONE");
        if ([_maxMinutesLeft doubleValue] == 0.0f) {
            self.subtitleLabel.text = NSLocalizedString(@"IN LESS THAN A MINUTE", @"IN LESS THAN A MINUTE");
        } else {
            self.subtitleLabel.text = [HYPAlarm subtitleForHomescreenUsingMinutes:_maxMinutesLeft];
        }
    } else {
        self.titleLabel.text = [HYPAlarm titleForHomescreen];
        self.subtitleLabel.text = [HYPAlarm subtitleForHomescreen];
    }
}

- (NSMutableArray *)alarms
{
    if (_alarms) return _alarms;

    _alarms = [NSMutableArray array];
    HYPAlarm *alarm1 = [[HYPAlarm alloc] init];
    HYPAlarm *alarm2 = [[HYPAlarm alloc] init];
    HYPAlarm *alarm3 = [[HYPAlarm alloc] init];
    HYPAlarm *alarm4 = [[HYPAlarm alloc] init];
    [_alarms addObject:@[alarm1, alarm2]];
    [_alarms addObject:@[alarm3, alarm4]];

    return _alarms;
}

- (NSMutableArray *)ovenAlarms
{
    if (_ovenAlarms) return _ovenAlarms;

    _ovenAlarms = [NSMutableArray array];

    HYPAlarm *alarm1 = [[HYPAlarm alloc] init];
    alarm1.oven = YES;
    [_ovenAlarms addObject:@[alarm1]];

    return _ovenAlarms;
}

- (UIImageView *)ovenBackgroundImageView
{
    if (_ovenBackgroundImageView) return _ovenBackgroundImageView;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceHeight = bounds.size.height;

    UIImage *image;
    if ([UIScreen andy_isPad]) {
        image = [UIImage imageNamed:@"ovenBackground~iPad"];
    } else {
        image = [UIImage imageNamed:@"ovenBackground"];
    }

    CGFloat topMargin = 0.0;
    if ([UIScreen andy_isPad]) {
        topMargin = image.size.height + 175.0f;
    } else {
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            if ([HYPUtils isTallPhone]) {
                topMargin = image.size.height + 110.0f;
            } else {
                topMargin = image.size.height + 60.0f;
            }
        } else {
            if (deviceHeight == 480.0f) {

                topMargin = image.size.height + 40.0f;

            } else if (deviceHeight == 568.0f) {

                topMargin = image.size.height + 90.0f;

            } else if (deviceHeight == 667.0f) {
                
                topMargin = image.size.height + 150.0f;

            } else if (deviceHeight == 736.0f) {

                topMargin = image.size.height + 180.0f;
            }
        }
    }

    CGFloat x = CGRectGetWidth(bounds) / 2 - image.size.width / 2;
    CGFloat y = CGRectGetHeight(bounds) - topMargin;
    CGRect imageRect = CGRectMake(x, y, image.size.width, image.size.height);
    _ovenBackgroundImageView = [[UIImageView alloc] initWithFrame:imageRect];
    _ovenBackgroundImageView.image = image;

    return _ovenBackgroundImageView;
}

- (UIImageView *)ovenShineImageView
{
    if (_ovenShineImageView) return _ovenShineImageView;

    _ovenShineImageView = [[UIImageView alloc] initWithFrame:self.ovenBackgroundImageView.frame];
    UIImage *image;
    if ([UIScreen andy_isPad]) {
        image = [UIImage imageNamed:@"ovenShine~iPad"];
        _ovenShineImageView.hidden = YES;
    } else {
        image = [UIImage imageNamed:@"ovenShine"];
    }

    _ovenShineImageView.image = image;

    return _ovenShineImageView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel) return _titleLabel;

    CGFloat sideMargin = 20.0f;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;

    CGFloat topMargin;

    if ([UIScreen andy_isPad]) {
        topMargin = 115.0f;
    } else {
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            if ([HYPUtils isTallPhone]) {
                topMargin = 40.0f;
            } else {
                topMargin = 20.0f;
            }
        } else {
            if ([HYPUtils isTallPhone]) {
                topMargin = 60.0f;
            } else {
                topMargin = 40.0f;
            }
        }
    }

    CGFloat height = 25.0f;
    UIFont *font;
    if ([UIScreen andy_isPad]) {
        font = [HYPUtils avenirLightWithSize:20.0f];
    } else {
        font = [HYPUtils avenirLightWithSize:15.0f];
    }
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
    _titleLabel.font = font;
    _titleLabel.text = [HYPAlarm titleForHomescreen];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.adjustsFontSizeToFitWidth = YES;

    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (_subtitleLabel) return _subtitleLabel;

    CGFloat sideMargin = CGRectGetMinX(self.titleLabel.frame);
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
    CGFloat topMargin = CGRectGetMaxY(self.titleLabel.frame);
    if ([UIScreen andy_isPad]) {
        topMargin += 10.0f;
    }
    CGFloat height = CGRectGetHeight(self.titleLabel.frame);
    UIFont *font;
    if ([UIScreen andy_isPad]) {
        font = [HYPUtils avenirBlackWithSize:25.0f];
    } else {
        font = [HYPUtils avenirBlackWithSize:19.0f];
    }
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
    _subtitleLabel.font = font;
    _subtitleLabel.text = [HYPAlarm subtitleForHomescreen];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.adjustsFontSizeToFitWidth = YES;

    return _subtitleLabel;
}

- (UICollectionView *)collectionView
{
    if (_collectionView) return _collectionView;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceWidth = bounds.size.width;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    CGFloat cellWidth = 0.0f;

    if ([UIScreen andy_isPad]) {

        cellWidth = 175.0f;

    } else {
        if (deviceWidth == 320.0f) {

            cellWidth = 100.0f;

        } else if (deviceWidth == 375.0f) {

            cellWidth = 113.0f;

        } else if (deviceWidth == 414.0f) {

            cellWidth = 122.0f;

        }
    }

    [flowLayout setItemSize:CGSizeMake(cellWidth + 10.0f, cellWidth)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    CGFloat sideMargin = 0.0f;

    if ([UIScreen andy_isPad]) {

        sideMargin = 200.0f;

    } else {
        if (deviceWidth == 320.0f) {

            sideMargin = 50.0f;

        } else if (deviceWidth == 375.0f) {

            sideMargin = 65.0f;

        } else if (deviceWidth == 414.0f) {

            sideMargin = 75.0f;

        }
    }

    CGFloat topMargin = self.topMargin;
    CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)
                                         collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];

    CGFloat factor;
    if ([UIScreen andy_isPad]) {
        factor = 0.36f;
    } else {
        factor = 0.30f;
    }
    [self applyTransformToLayer:_collectionView.layer usingFactor:factor];

    return _collectionView;
}

- (UICollectionView *)ovenCollectionView
{
    if (_ovenCollectionView) return _ovenCollectionView;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat deviceWidth = bounds.size.width;
    CGFloat deviceHeight = bounds.size.height;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat cellWidth = 0.0f;
    if ([UIScreen andy_isPad]) {
        cellWidth = 220.0f;
    } else {
        if (deviceWidth == 320.0f) {

            cellWidth = 120.0f;

        } else if (deviceWidth == 375.0f) {

            cellWidth = 133.0f;

        } else if (deviceWidth == 414.0f) {

            cellWidth = 142.0f;
            
        }
    }

    [flowLayout setItemSize:CGSizeMake(cellWidth, cellWidth)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    CGFloat sideMargin = 0.0f;
    if ([UIScreen andy_isPad]) {
        sideMargin = 274.0f;
    } else {
        if (deviceWidth == 320.0f) {

            sideMargin = 100.0f;

        } else if (deviceWidth == 375.0f) {

            sideMargin = 120.0f;

        } else if (deviceWidth == 414.0f) {

            sideMargin = 135.0f;

        }
    }

    CGFloat topMargin = 0.0f;
    if ([UIScreen andy_isPad]) {
        topMargin = self.topMargin + 475.0f;
    } else {
        if (deviceHeight == 480.0f) {

            topMargin = self.topMargin + 260.0f;

        } else if (deviceHeight == 568.0f) {

            topMargin = self.topMargin + 260.0f;

        } else if (deviceHeight == 667.0f) {

            topMargin = self.topMargin + 280.0f;

        } else if (deviceHeight == 736.0f) {

            topMargin = self.topMargin + 310.0f;
        }
    }

    CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
    _ovenCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)
                                             collectionViewLayout:flowLayout];
    _ovenCollectionView.dataSource = self;
    _ovenCollectionView.delegate = self;
    _ovenCollectionView.backgroundColor = [UIColor clearColor];

    CGFloat factor;
    if ([UIScreen andy_isPad]) {
        factor = 0.29f;
    } else {
        factor = 0.25f;
    }
    [self applyTransformToLayer:_ovenCollectionView.layer usingFactor:factor];

    return _ovenCollectionView;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWasShaked:)
                                                 name:@"appWasShaked"
                                               object:nil];

    if ([UIScreen andy_isPad]) {
        self.topMargin = 70.0f;
    } else {
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            if ([HYPUtils isTallPhone]) {
                self.topMargin = IOS6_TALL_TOP_MARGIN;
            } else {
                self.topMargin = IOS6_SHORT_TOP_MARGIN;
            }
        } else {
            if ([HYPUtils isTallPhone]) {
                self.topMargin = TALL_TOP_MARGIN;
            } else {
                self.topMargin = SHORT_TOP_MARGIN;
            }
        }
    }

    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.ovenBackgroundImageView];

    [self.collectionView registerClass:[HYPPlateCell class] forCellWithReuseIdentifier:HYPPlateCellIdentifier];
    [self.ovenCollectionView registerClass:[HYPPlateCell class] forCellWithReuseIdentifier:HYPPlateCellIdentifier];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.ovenCollectionView];
    [self.view addSubview:self.ovenShineImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissedTimerController:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
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
        NSArray *array = (self.alarms)[0];
        NSInteger rows = [array count];
        return rows;
    }

    NSArray *array = (self.ovenAlarms)[0];
    NSInteger rows = [array count];
    return rows;
}

- (HYPPlateCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPPlateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HYPPlateCellIdentifier
                                                                   forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath collectionView:collectionView];

    return cell;
}

- (void)configureCell:(HYPPlateCell *)cell atIndexPath:(NSIndexPath *)indexPath
       collectionView:(UICollectionView *)collectionView;
{
    HYPAlarm *alarm = [self alarmAtIndexPath:indexPath collectionView:collectionView];
    alarm.indexPath = indexPath;
    cell.timerControl.active = alarm.active;
    [cell.timerControl addTarget:self
                          action:@selector(timerControlChangedValue:)
                forControlEvents:UIControlEventValueChanged];
    [self refreshTimerInCell:cell forCurrentAlarm:alarm];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPTimerViewController *timerController = [[HYPTimerViewController alloc] init];
    timerController.delegate = self;
    HYPAlarm *alarm = [self alarmAtIndexPath:indexPath collectionView:collectionView];
    timerController.alarm = alarm;
    [self presentViewController:timerController animated:YES completion:nil];
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

#pragma mark - Helpers

- (HYPAlarm *)alarmAtIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView
{
    NSArray *row;
    if ([collectionView isEqual:self.collectionView]) {
        row = (self.alarms)[indexPath.section];
    } else {
        row = (self.ovenAlarms)[indexPath.section];
    }
    HYPAlarm *alarm = row[indexPath.row];
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
        NSDate *firedDate = (existingNotification.userInfo)[ALARM_FIRE_DATE_KEY];
        NSNumber *numberOfSeconds = (existingNotification.userInfo)[ALARM_FIRE_INTERVAL_KEY];

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

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"presentedClue"];
        [defaults synchronize];

    } else {
        alarm.active = NO;
        cell.timerControl.active = NO;
        [cell.timerControl restartTimer];
        [cell.timerControl stopTimer];
    }
}

#pragma mark - Shake Support

- (void)appWasShaked:(NSNotification *)notification
{
    if (self.deleteTimersMessageIsBeingDisplayed) {
        return;
    }

    if ([[notification name] isEqualToString:@"appWasShaked"]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Would you like to cancel all the timers?", nil)
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"No", nil)
                          otherButtonTitles:NSLocalizedString(@"Ok", nil), nil] show];
        self.deleteTimersMessageIsBeingDisplayed = YES;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accepted = (buttonIndex == 1);
    if (accepted) {
        [HYPLocalNotificationManager cancelAllLocalNotifications];
        [self.collectionView reloadData];
    }
    self.deleteTimersMessageIsBeingDisplayed = NO;
}

@end
