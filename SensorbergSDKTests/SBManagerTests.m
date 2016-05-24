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
#import "SBResolver.h"
#import "SBLocation.h"
#import "SBAnalytics.h"
#import "SBBluetooth.h"

FOUNDATION_EXPORT NSString *kPostLayout;
FOUNDATION_EXPORT NSString *kSBAppActive;
FOUNDATION_EXPORT NSString *SBAPIKey;
FOUNDATION_EXPORT NSString *SBResolverURL;

FOUNDATION_EXPORT UICKeyChainStore *keychain;
FOUNDATION_EXPORT NSString * const kIDFA;

FOUNDATION_EXPORT NSString * const kSBSettingsDefaultResolverURL;

@interface SBManager (XCTestCase)
- (void)setResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate;
@end

@interface SBFakeManager : SBManager
@property (nonnull, strong) XCTestExpectation *expectation;
@property (nonnull, strong) NSArray <NSString*> *UUIDs;
- (void)startMonitoring:(NSArray <NSString*>*)UUIDs;
SUBSCRIBE(SBEventGetLayout);
@end

@implementation SBFakeManager
- (void)startMonitoring:(NSArray <NSString*>*)UUIDs
{
    [super startMonitoring:UUIDs];
    _UUIDs = UUIDs;
    [self.expectation fulfill];
}
@end

@interface SBManagerTests : XCTestCase
@property (nullable, nonatomic, strong) SBManager *sut;
@property (nullable, nonatomic, strong) NSString *defaultAPIKey;
@property (nullable, nonatomic, strong) NSMutableDictionary *expectations;
@property (nullable, nonatomic, strong) NSMutableDictionary *events;
@property (nullable, nonatomic, strong) NSMutableDictionary *defaultLayoutDict;
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
    
    self.defaultLayoutDict = [@{
                                @"accountProximityUUIDs" : [@[@"7367672374000000ffff0000ffff0003"] mutableCopy],
                                @"actions" : [@[
                                                [@{
                                                   @"eid": @"367348a0dfa84492a0078ead26cf9385",
                                                   @"trigger": @(kSBTriggerEnter),
                                                   @"beacons": @[
                                                           @"7367672374000000ffff0000ffff00030000200747"
                                                           ],
                                                   @"suppressionTime": @(-1),
                                                   @"content": @{
                                                           @"subject": @"SBGetLayoutTests",
                                                           @"body": @"testCheckCampaignsForBeaconAndTriggerShouldFire",
                                                           @"payload": [NSNull null],
                                                           @"url": @"http://www.sensorberg.com"
                                                           },
                                                   @"type": @(1),
                                                   @"timeframes": [@[
                                                                     [@{
                                                                        @"start": @"2016-05-01T10:00:00.000+0000",
                                                                        @"end": @"2100-05-31T23:00:00.000+0000"
                                                                        } mutableCopy]
                                                                     ] mutableCopy],
                                                   @"sendOnlyOnce": @(NO),
                                                   @"typeString": @"notification"
                                                   } mutableCopy]
                                                ] mutableCopy],
                                @"currentVersion": @(NO)
                                } mutableCopy];
    
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
    self.defaultLayoutDict = nil;
    [self.sut resetSharedClient];
    UNREGISTER();
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

- (void)testStartMonitoringWithLayout
{
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    SBEventGetLayout *event = [SBEventGetLayout new];
    event.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    [manager onSBEventGetLayout:event];
    [manager startMonitoring];
    XCTAssert(manager.UUIDs.count);
    
    [[Tolo sharedInstance] unsubscribe:manager];
}

- (void)testStartMonitoringWithNullLayout
{
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    [manager startMonitoring];
    XCTAssertFalse(manager.UUIDs.count);
    
    [[Tolo sharedInstance] unsubscribe:manager];
}

- (void)testOnSBEventGetLayoutWithError
{
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    
    SBEventGetLayout *event = [SBEventGetLayout new];
    event.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    event.error = [[NSError alloc] initWithDomain:@"XCTTestExpectedError" code:100 userInfo:nil];
    [manager onSBEventGetLayout:event];
    XCTAssertFalse(manager.UUIDs.count);
    
    [[Tolo sharedInstance] unsubscribe:manager];
}

SUBSCRIBE(SBEventUpdateHeaders)
{
    [self.events setObject:event forKey:@"testSetIDFAValue"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testSetIDFAValue"];
    [expectation fulfill];
}
- (void)testSetIDFAValue
{
    [self.expectations setObject:[self expectationWithDescription:@"testSetIDFAValue"]
                          forKey:@"testSetIDFAValue"];
    REGISTER();
    [self.sut setIDFAValue:@"KindOfIDFAString"];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    SBEventUpdateHeaders *event = [self.events objectForKey:@"testSetIDFAValue"];
    XCTAssert(event);
    XCTAssert([keychain stringForKey:kIDFA]);
    UNREGISTER();
    
}

- (void)testSetIDFAValueWithZeroLength
{
    [keychain removeItemForKey:kIDFA];
    REGISTER();
    [self.sut setIDFAValue:@""];
    XCTAssertNil([keychain stringForKey:kIDFA]);
    UNREGISTER();
    
}

- (void)testSetIDFAValueWithNSNullInstance
{
    [keychain removeItemForKey:kIDFA];
    REGISTER();
    [self.sut setIDFAValue:(NSString *)[NSNull null]];
    XCTAssertNil([keychain stringForKey:kIDFA]);
    UNREGISTER();
    
}

- (void)testSetIDFAValueWithWrongClassInstance
{
    [keychain removeItemForKey:kIDFA];
    REGISTER();
    [self.sut setIDFAValue:(NSString *)@(0)];
    XCTAssertNil([keychain stringForKey:kIDFA]);
    UNREGISTER();
    
}

@end
