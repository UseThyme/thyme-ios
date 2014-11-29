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

- (NSNumber *)secondsForHours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds
{
    return @(hours * 3600 + minutes * 60 + seconds);
}

- (void)testSubtitleForHomescreenUsingMinutes
{
    NSNumber *minutes = [self minutesForHours:0 andMinutes:7];
    NSString *message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN 7 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:22];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 20 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:23];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 25 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:24];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 25 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:25];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 25 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:27];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 25 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:28];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 30 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:29];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 30 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:34];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 35 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:56];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 55 MINUTES", @"");

    minutes = [self minutesForHours:0 andMinutes:58];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR", @"");

    minutes = [self minutesForHours:1 andMinutes:0];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR", @"");

    minutes = [self minutesForHours:1 andMinutes:4];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR 5 MINUTES", @"");

    minutes = [self minutesForHours:1 andMinutes:54];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 1 HOUR 55 MINUTES", @"");

    minutes = [self minutesForHours:1 andMinutes:56];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS", @"");

    minutes = [self minutesForHours:2 andMinutes:0];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS", @"");

    minutes = [self minutesForHours:2 andMinutes:1];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS 5 MINUTES", @"");

    minutes = [self minutesForHours:2 andMinutes:16];
    message = [HYPAlarm subtitleForHomescreenUsingMinutes:minutes];
    XCTAssertEqualObjects(message, @"IN ABOUT 2 HOURS 20 MINUTES", @"");
}

@end
