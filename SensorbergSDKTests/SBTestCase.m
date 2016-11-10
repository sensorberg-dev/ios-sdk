//
//  SBTestCase.m
//  SensorbergSDK
//
//  Created by ParkSanggeon on 28/06/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import "SBTestCase.h"
#import "SensorbergSDK.h"
#import "SBSettings.h"

const NSString *kSBStagingResolverURL = @"https://bm-resolver-staging.sensorberg.io";

@implementation SBTestCase

- (void)setUp {
    [super setUp];
    
#if TEST_STAGING
    [SBSettings sharedManager].settings.resolverURL = [kSBStagingResolverURL copy];
    NSLog(@"Use Staging Resolver");
#else
    [SBSettings sharedManager].settings.resolverURL = @"https://resolver.sensorberg.com";
    NSLog(@"Use Default Resolver");
#endif
    XCTestExpectation *expectation = [self expectationWithDescription:@"Timeinterval for next test"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
        //
    }];
}

- (void)tearDown {
    [super tearDown];
}

@end
