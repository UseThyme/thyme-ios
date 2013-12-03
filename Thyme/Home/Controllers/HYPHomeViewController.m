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

#define SHORT_TOP_MARGIN 10
#define TALL_TOP_MARGIN 50

static NSString * const HYPPlateCellIdentifier = @"HYPPlateCellIdentifier";

@interface HYPHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) CGFloat topMargin;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *ovenCollectionView;

@property (nonatomic, strong) UIImageView *ovenBackgroundImageView;

@property (nonatomic) BOOL kitchenIsMinized;
@property (nonatomic) CGPoint kitchenCenter;
@property (nonatomic) CGPoint ovenCenter;
@property (nonatomic) CGPoint totalCenter;
@end

@implementation HYPHomeViewController

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

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        CGFloat sideMargin = 20.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        CGFloat topMargin = 40.0f;
        CGFloat height = 25.0f;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
        _titleLabel.font = [HYPUtils avenirLightWithSize:12.0f];
        _titleLabel.text = @"YOUR DISH WILL BE DONE IN";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
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
        _subtitleLabel.text = @"ABOUT 20 MINUTES";
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor whiteColor];
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

- (void)applyTransformToLayer:(CALayer *)layer usingFactor:(CGFloat)factor
{
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -800.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * factor, 1.0f, 0.0f, 0.0f);

    //[UIView animateWithDuration:0.5 animations:^{
        layer.anchorPoint = CGPointMake(0.5, 0);
        layer.transform = rotationAndPerspectiveTransform;
    //}];
}

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
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.collectionView]) {
        return 4;
    }

    return 1;
}

- (HYPPlateCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPPlateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HYPPlateCellIdentifier forIndexPath:indexPath];
    /*if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor greenColor];
    } else if (indexPath.row == 1) {
        cell.backgroundColor = [UIColor grayColor];
    } else if (indexPath.row == 2) {
        cell.backgroundColor = [UIColor brownColor];
    } else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }*/
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPTimerViewController *timerController = [[HYPTimerViewController alloc] init];
    [self.navigationController pushViewController:timerController animated:YES];
}

@end
