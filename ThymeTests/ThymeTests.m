//
//  ThymeTests.m
//  ThymeTests
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HYPAlarm.h"

@interface ThymeTests : XCTestCase

@end

@implementation ThymeTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSNumber *)minutesForHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    return @(hours * 60 + minutes);
}

- (void)testSubtitleForHomescreenUsingMinutes
{
    // 0:07
    NSNumber *minutes = [self minutesForHours:0 andMinutes:7];
    NSString *message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN 7 MINUTES", @"");

    // 0:35
    minutes = [self minutesForHours:0 andMinutes:34];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 35 MINUTES", @"");

    // 0:56
    minutes = [self minutesForHours:0 andMinutes:56];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR", @"");

    // 1:00
    minutes = [self minutesForHours:1 andMinutes:0];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR", @"");

    // 1:04
    minutes = [self minutesForHours:1 andMinutes:4];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR 5 MINUTES", @"");

    // 1:54
    minutes = [self minutesForHours:1 andMinutes:54];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR 55 MINUTES", @"");

    // 1:56
    minutes = [self minutesForHours:1 andMinutes:56];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS", @"");

    // 2:00
    minutes = [self minutesForHours:2 andMinutes:0];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS", @"");

    // 2:01
    minutes = [self minutesForHours:2 andMinutes:1];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS 5 MINUTES", @"");

    // 2:16
    minutes = [self minutesForHours:2 andMinutes:16];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS 20 MINUTES", @"");
}

@end
