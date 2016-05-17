//
//  SBSettingsTests.m
//  SensorbergSDK
//
//  Created by ParkSanggeon on 13/05/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <tolo/Tolo.h>

#import "SBSettings.h"
#import "SBHTTPRequestManager.h"

@interface WhiteLabelSettingManagerTests : XCTestCase
@property (nonatomic, assign) SBSettings *target;
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) SBSettingEvent *responseEvent;
@end

@implementation WhiteLabelSettingManagerTests

- (void)setUp
{
    [super setUp];
    UNREGISTER();
    REGISTER();
    NSLog(@"TEST - REGISTER");
    self.target = [SBSettings sharedManager];
}

- (void)tearDown
{
    UNREGISTER();
    NSLog(@"TEST - UNREGISTER");
    self.expectation = nil;
    self.responseEvent = nil;
    [super tearDown];
}

- (void)testSharedInstance {
    SBSettings *testTarget = [SBSettings sharedManager];
    XCTAssert(self.target == testTarget);
}

SUBSCRIBE(SBSettingEvent) {
    self.responseEvent = event;
    [self.expectation fulfill];
    self.expectation = nil;
}

- (void)testRequestSettingsWithAPIKey {
    
    self.expectation = [self expectationWithDescription:@"Wait for connect server response"];
    // Key from "Gunnih Onboarding" App.
    [self.target requestSettingsWithAPIKey:@"c25c2c8dd3c5c01b539c9d656f7aa97e124fe88ff780fcaf55db6cae64a20e27"];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssert(self.responseEvent.settings);
    if (self.responseEvent.error.code != NSURLErrorCancelled)
    {
        XCTAssertNil(self.responseEvent.error);
    }
    else
    {
        // in case : got same setting.
        XCTAssert(self.responseEvent.error);
    }
    self.expectation = nil;
}

- (void)testRequestSettingsWithAPIKeyForWrongKey {
    self.expectation = [self expectationWithDescription:@"Wait for connect server response"];
    
    [self.target requestSettingsWithAPIKey:@"Hey :D"];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    XCTAssertNil(self.responseEvent.settings);
    XCTAssert(self.responseEvent.error);
    self.expectation = nil;
}

- (void)testRequestSettingsWithAPIKeyForEmptyKey {
    self.expectation = [self expectationWithDescription:@"Wait for connect server response"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.target requestSettingsWithAPIKey:nil];
#pragma clang diagnostic pop
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssertNil(self.responseEvent.settings);
    XCTAssert(self.responseEvent.error);
    self.expectation = nil;
}

@end