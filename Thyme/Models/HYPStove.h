//
//  HYPStove.h
//  Thyme
//
//  Created by Elvis Nunez on 27/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYPStove : NSObject
@property (nonatomic, strong) NSNumber *date;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic, getter = isOven) BOOL oven;
@end