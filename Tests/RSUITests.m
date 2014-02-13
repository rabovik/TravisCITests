//
//  RSUITests.m
//  TravisCI
//
//  Created by Yan Rabovik on 14.02.14.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "RSMyLibView.h"

@interface RSUITests : SenTestCase

@end

@implementation RSUITests

- (void)testUI{
    RSMyLibView *view = [[RSMyLibView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    STAssertNotNil(view, @"View is nil");
}

- (void)testLogConfiguration {
    NSString *os = [NSString stringWithFormat:@"iOS %@", [UIDevice currentDevice].systemVersion];
    NSString *screen = NSStringFromCGSize([UIScreen mainScreen].bounds.size);
    CGFloat scale = [UIScreen mainScreen].scale;
#ifdef DEBUG
    NSString *config = @"Debug";
#else
    NSString *config = @"Release";
#endif
    NSLog(@"%s %@ %@ @%1.0fx (%@) %s", "\e[0;33m", os, screen, scale, config, "\e[m");
}

@end
