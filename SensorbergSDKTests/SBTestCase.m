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
    
}

- (void)tearDown {
    [super tearDown];
}

@end
