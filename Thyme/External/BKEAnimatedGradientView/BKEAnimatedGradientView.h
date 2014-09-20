//
//  BKEAnimatedGradientView.h
//  BKEAnimatedGradientView
//
//  Created by Brian Kenny on 03/02/2014.
//  Updated by Elvis Nuñez on 20/09/2014.
//  Copyright (c) 2014 Brian Kenny. All rights reserved.
//

@import UIKit;

@interface BKEAnimatedGradientView : UIView

/*
 Array of Colors
*/
@property (nonatomic, copy) NSArray *gradientColors;

- (void)changeGradientWithAnimation:(NSArray *)gradientColors delay:(CGFloat)delay duration:(CGFloat)duration;

@end
