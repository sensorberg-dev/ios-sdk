//
//  SBUtilityTests.m
//  SensorbergSDK
//
//  Created by ParkSanggeon on 20/05/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBUtility.h"

@interface SBUtility (XCTests)
+ (NSString *)applicationIdentifier;
@end

@interface SBUtilityTests : XCTestCase

@end

@implementation SBUtilityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoad {
    dateFormatter = nil;
    [SBUtility load];
    
    XCTAssert(dateFormatter);
}


- (void)testUserAgent {
    
    SBMUserAgent *agent = [SBUtility userAgent];
    
    XCTAssert(agent);
    
    XCTAssert([agent.sdk isEqualToString:kSensorbergSDKVersion]);
    XCTAssert(agent.os.length);
    XCTAssert(agent.app.length);
}

@end
