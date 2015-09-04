#import <XCTest/XCTest.h>

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

@end
