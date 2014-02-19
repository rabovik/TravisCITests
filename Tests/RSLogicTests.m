//
//  RSLogicTests.m
//  TravisCI
//
//  Created by Yan Rabovik on 12.02.14.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "RSMyLibLogic.h"

@interface RSLogicTests : SenTestCase

@end

@implementation RSLogicTests

- (void)testLogic {
    RSMyLibLogic *lib = [RSMyLibLogic new];
    STAssertTrue(42 == [lib return42], @"-[RSMyLibLogic return42] returns %lu", (unsigned long)[lib return42]);
}

- (void)testLogConfiguration {
    #if TARGET_OS_IPHONE
        NSString *os = [NSString stringWithFormat:@"iOS %@", [UIDevice currentDevice].systemVersion];
    #else
        NSString *os = @"OSX";
    #endif
    #ifdef DEBUG
        NSString *config = @"Debug";
    #else
        NSString *config = @"Release";
    #endif
    #ifdef __LP64__
        unsigned int bits = 64;
    #else
        unsigned int bits = 32;
    #endif
    NSLog(@"%s %@ %u-bit (%@) %s", "\e[0;33m", os, bits, config, "\e[m");
}

- (void)testFailOnIOS6_1{
    #if TARGET_OS_IPHONE
    if ([UIDevice currentDevice].systemVersion.floatValue == 6.1f) {
        STFail(@"Some fail on iOS 6.1");
    }
    #endif
}

@end
