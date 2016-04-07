//
//  SensorbergSDKTests.m
//  SensorbergSDKTests
//
//  Created by andsto on 01/12/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <SensorbergSDK/SensorbergSDK.h>

#import <SensorbergSDK/SBResolver.h>
#import <SensorbergSDK/SBInternalModels.h>
#import <SensorbergSDK/SBInternalEvents.h>

#import <tolo/Tolo.h>

@interface SensorbergSDKTests : XCTestCase {
    XCTestExpectation *testThatTheSBManagerIsResetExpectation;
    
    XCTestExpectation *testThatTheLayoutIsNotNullExpectation;
    
    XCTestExpectation *testThatTheCampaignFiresExpectation;
}
@end

static NSString *const kTestAPIKey = @"bfdfe1ec8020c2adb1ad7e56ce2fbf75791ce7213b505d63de5d6d3d39717a22";

static NSString *const kBeaconFullUUID = @"7367672374000000ffff0000ffff00030000200747";

static int const kRequestTimeout = 2;

@implementation SensorbergSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[SBManager sharedManager] setApiKey:kTestAPIKey delegate:self];
    
//    [[SBManager sharedManager] startMonitoring];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatSBManagerIsNotNull {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssertNotNil([SBManager sharedManager], @"Failed to initialized SBManager");
}

- (void)testThatTheLayoutIsNotNull {
    [[SBManager sharedManager] startMonitoring];
    
    testThatTheLayoutIsNotNullExpectation = [self expectationWithDescription:@"testThatTheLayoutIsNotNullExpectation"];
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SBEventRegionEnter *enter = [SBEventRegionEnter new];
//        SBMBeacon *beacon = [[SBMBeacon alloc] initWithString:kBeaconFullUUID];
        enter.beacon = nil;
        enter.rssi = -50;
        enter.proximity = CLProximityNear;
        enter.accuracy = kCLLocationAccuracyBest;
        PUBLISH(enter);
    });
    //
    [self waitForExpectationsWithTimeout:kRequestTimeout
                                 handler:^(NSError * _Nullable error) {
                                     //
                                 }];
    //
}

- (void)testThatTheCampaignFires {
//    [[SBManager sharedManager] startMonitoring];
    //
    testThatTheCampaignFiresExpectation = [self expectationWithDescription:@"testThatTheCampaignFiresExpectation"];
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SBMBeacon *beacon = [[SBMBeacon alloc] initWithString:kBeaconFullUUID];
        //
        NSError *error;
        NSString *jsonLayout = [[NSBundle bundleForClass:self.class] pathForResource:kTestAPIKey ofType:@"json"];
        XCTAssertNotNil(jsonLayout, @"Can't find json file %@.json",kTestAPIKey);
        //
        SBEventGetLayout *event = [SBEventGetLayout new];
        SBMGetLayout *layout = [[SBMGetLayout alloc] initWithData:[NSData dataWithContentsOfFile:jsonLayout] error:&error];
        event.layout = layout;
        event.beacon = beacon;
        event.trigger = kSBTriggerEnter;
        PUBLISH(event);
        //
        SBEventRegionEnter *enter = [SBEventRegionEnter new];
        enter.beacon = beacon;
        enter.rssi = -50;
        enter.proximity = CLProximityNear;
        enter.accuracy = kCLLocationAccuracyBest;
        PUBLISH(enter);
        //
        XCTAssertNil(error,@"Error loading JSON %@.json",kTestAPIKey);
        //
    });
    //
    [self waitForExpectationsWithTimeout:kRequestTimeout
                                 handler:^(NSError * _Nullable error) {
        //
    }];
}


- (void)testThatTheSBManagerIsReset {
    testThatTheSBManagerIsResetExpectation = [self expectationWithDescription:@"testThatTheSBManagerIsResetExpectation"];
    SBManager *manager = [SBManager sharedManager];
    [manager resetSharedClient];
    
    [self waitForExpectationsWithTimeout:kRequestTimeout
                                 handler:^(NSError * _Nullable error) {
                                     //
                                 }];
}

SUBSCRIBE(SBEventResetManager) {
    [testThatTheSBManagerIsResetExpectation fulfill];
}

SUBSCRIBE(SBEventRegionEnter) {
    if (event.beacon) {
        
    } else {
        // implement public layout event instead of using a beacon :)
        [testThatTheLayoutIsNotNullExpectation fulfill];
    }
}

SUBSCRIBE(SBEventPerformAction) {
    [testThatTheCampaignFiresExpectation fulfill];
}

@end
