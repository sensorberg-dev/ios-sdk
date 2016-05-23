//
//  SBManagerTests.m
//  SensorbergSDK
//
//  Created by ParkSanggeon on 20/05/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <tolo/Tolo.h>
#import "SBManager.h"
#import "SBSettings.h"
#import "SBInternalEvents.h"

FOUNDATION_EXPORT NSString *kPostLayout;
FOUNDATION_EXPORT NSString *kSBAppActive;
FOUNDATION_EXPORT NSString *SBAPIKey;
FOUNDATION_EXPORT NSString *SBResolverURL;
FOUNDATION_EXPORT NSString *kSBDefaultAPIKey;

FOUNDATION_EXPORT NSString * const kSBSettingsDefaultResolverURL;

@interface SBManager (XCTests)
- (void)setResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate;
@end

@interface SBManagerTests : XCTestCase
@property (nullable, nonatomic, strong) SBManager *sut;
@property (nullable, nonatomic, strong) NSString *defaultAPIKey;
@property (nullable, nonatomic, strong) NSMutableDictionary *expectations;
@property (nullable, nonatomic, strong) NSMutableDictionary *events;
@end

@implementation SBManagerTests

- (void)setUp {
    [super setUp];
    if (!self.expectations)
    {
        self.expectations = [NSMutableDictionary new];
    }
    if (!self.events)
    {
        self.events = [NSMutableDictionary new];
    }
    self.sut = [SBManager new];
    self.defaultAPIKey = @"c25c2c8dd3c5c01b539c9d656f7aa97e124fe88ff780fcaf55db6cae64a20e27";
    [self.sut setApiKey:self.defaultAPIKey delegate:nil];
    [self.sut requestNotificationsAuthorization];
    [self.sut requestLocationAuthorization:YES];
    [self.sut requestBluetoothAuthorization];
    REGISTER();
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.sut = nil;
    self.defaultAPIKey = nil;
    [self.sut resetSharedClient];
    [super tearDown];
}

- (void)testInitalization {
    XCTAssert([SBAPIKey isEqualToString:self.defaultAPIKey]);
    XCTAssert([SBResolverURL isEqualToString:kSBSettingsDefaultResolverURL]);
}

- (void)testResetSharedClient {
    [[SBManager sharedManager] resetSharedClient];
    XCTAssertNil(SBAPIKey);
    XCTAssertNil(SBResolverURL);
}

SUBSCRIBE(SBEventResetManager)
{
    [self.events setObject:event forKey:@"testResetSharedClientInBackgroundThread"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testResetSharedClientInBackgroundThread"];
    [expectation fulfill];
}

- (void)testResetSharedClientInBackgroundThread
{
    [self.expectations setObject:[self expectationWithDescription:@"testResetSharedClientInBackgroundThread"]
                          forKey:@"testResetSharedClientInBackgroundThread"];
    REGISTER();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.sut resetSharedClient];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventResetManager *event = [self.events objectForKey:@"testResetSharedClientInBackgroundThread"];
    XCTAssert(event);
    UNREGISTER();
}

SUBSCRIBE(SBEventPing)
{
    [self.events setObject:event forKey:@"testResetSharedClientInBackgroundThread"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testResetSharedClientInBackgroundThread"];
    [expectation fulfill];
}

-(void)testPing
{
    [self.expectations setObject:[self expectationWithDescription:@"testResetSharedClientInBackgroundThread"]
                          forKey:@"testResetSharedClientInBackgroundThread"];
    REGISTER();
    [self.sut requestResolverStatus];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    SBEventPing *event = [self.events objectForKey:@"testResetSharedClientInBackgroundThread"];
    XCTAssert(event);
    XCTAssertNil(event.error);
    XCTAssert(event.latency == self.sut.resolverLatency);
    UNREGISTER();
}

-(void)testLatencyWithError
{
    SBEventPing *event = [SBEventPing new];
    event.error = nil;
    event.latency = 1.0f;
    PUBLISH(event);
    
    event = [SBEventPing new];
    event.error = [NSError new];
    event.latency = -1.0f;
    PUBLISH(event);
    
    XCTAssert([self.sut resolverLatency] == 1.0f);
}

- (void)testSetResolverApiKeyDelegateWithNilApiKey
{
    [self.sut setResolver:nil apiKey:nil delegate:nil];
    XCTAssert([SBAPIKey isEqualToString:kSBDefaultAPIKey]);
}

- (void)testSetResolverApiKeyDelegateWithCustomResolver
{
    NSString *customResolver = @"ThisIsCustomResolver.";
    [self.sut setResolver:customResolver apiKey:self.defaultAPIKey delegate:nil];
    XCTAssert([SBAPIKey isEqualToString:self.defaultAPIKey]);
    XCTAssert([SBResolverURL isEqualToString:customResolver]);
}


SUBSCRIBE(SBEventGetLayout)
{
    [self.events setObject:event forKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    [expectation fulfill];
}

- (void)testSetResolverApiKeyDelegateInBackgroundThread
{
    [self.expectations setObject:[self expectationWithDescription:@"testSetResolverApiKeyDelegateInBackgroundThread"]
                          forKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    REGISTER();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.sut setResolver:nil apiKey:self.defaultAPIKey delegate:nil];
    });
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
    SBEventGetLayout *event = [self.events objectForKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    XCTAssert(event);
    UNREGISTER();
}

@end
