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
FOUNDATION_EXPORT NSString *kPostLayout;

FOUNDATION_EXPORT NSString * const kSBSettingsDefaultResolverURL;

@interface SBManager ()
SUBSCRIBE(SBEventGetLayout);
SUBSCRIBE(SBEventReportHistory);
@end

@interface SBManager (XCTestCase)
- (void)setResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate;
@end

@interface SBFakeManager : SBManager
@property (nonnull, strong) XCTestExpectation *expectation;
@property (nonnull, strong) NSArray <NSString*> *UUIDs;
- (void)startMonitoring:(NSArray <NSString*>*)UUIDs;
SUBSCRIBE(SBEventGetLayout);
SUBSCRIBE(SBEventReportHistory);
@end

@implementation SBFakeManager
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-declarations"
SUBSCRIBE(SBEventGetLayout)
{
    [super onSBEventGetLayout:event];
}
SUBSCRIBE(SBEventReportHistory)
{
    [super onSBEventReportHistory:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.expectation fulfill];
    });
}
#pragma clan diagnostic pop
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
                                                   @"trigger": @(kSBTriggerEnterExit),
                                                   @"beacons": @[
                                                           @"7367672374000000ffff0000ffff00000376000004"
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
    [[Tolo sharedInstance] subscribe:self.sut];

    REGISTER();
}

- (void)tearDown {
    [[Tolo sharedInstance] unsubscribe:self.sut];
    self.sut = nil;
    self.defaultAPIKey = nil;
    self.defaultLayoutDict = nil;
    [self.sut resetSharedClient];
    UNREGISTER();
    [super tearDown];
}

SUBSCRIBE(SBEventResetManager)
{
    [self.events setObject:event forKey:@"testResetSharedClientInBackgroundThread"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testResetSharedClientInBackgroundThread"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventReportConversion)
{
    [self.events setObject:event forKey:@"testReportConversion"];
}

SUBSCRIBE(SBEventPing)
{
    [self.events setObject:event forKey:@"testResetSharedClientInBackgroundThread"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testResetSharedClientInBackgroundThread"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventGetLayout)
{
    [self.events setObject:event forKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventUpdateHeaders)
{
    [self.events setObject:event forKey:@"testSetIDFAValue"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testSetIDFAValue"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventReportHistory)
{
    [self.events setObject:event forKey:@"testOnSBEventGetLayoutWithDelay"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testOnSBEventGetLayoutWithDelay"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventPerformAction)
{
    [self.events setObject:event forKey:@"testOnSBEventRegionExit"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testOnSBEventRegionExit"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventPostLayout)
{
    [self.events setObject:event forKey:@"testOnSBEventReportHistoryNoForce"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testOnSBEventReportHistoryNoForce"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventApplicationLaunched)
{
    [self.events setObject:event forKey:@"testApplicationDidFinishLaunchingWithOptions"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testApplicationDidFinishLaunchingWithOptions"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventApplicationActive)
{
    [self.events setObject:event forKey:@"testApplicationDidBecomeActive"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testApplicationDidBecomeActive"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventApplicationWillTerminate)
{
    [self.events setObject:event forKey:@"applicationWillTerminateNotification"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"applicationWillTerminateNotification"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventApplicationWillResignActive)
{
    [self.events setObject:event forKey:@"applicationWillResignActive"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"applicationWillResignActive"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventApplicationWillEnterForeground)
{
    [self.events setObject:event forKey:@"applicationWillEnterForeground"];
    XCTestExpectation *expectation = [self.expectations objectForKey:@"applicationWillEnterForeground"];
    [expectation fulfill];
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
    SBEventGetLayout *event = [SBEventGetLayout new];
    event.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    PUBLISH(event);
    [manager startMonitoring];
    XCTAssert(manager.UUIDs.count);
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
    PUBLISH(event);
    XCTAssertFalse(manager.UUIDs.count);
    
    [[Tolo sharedInstance] unsubscribe:manager];
}

- (void)testOnSBEventGetLayoutWithDelay
{
    [self.expectations setObject:[self expectationWithDescription:@"testOnSBEventGetLayoutWithDelay"]
                          forKey:@"testOnSBEventGetLayoutWithDelay"];
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    REGISTER();
    SBEventGetLayout *layoutEvent = [SBEventGetLayout new];
    layoutEvent.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    layoutEvent.error = [[NSError alloc] initWithDomain:@"XCTTestExpectedError" code:100 userInfo:nil];
    for (NSInteger index = 0; index < 5; index++)
    {
        [manager onSBEventGetLayout:layoutEvent];
    }
    SBEventGetLayout *delayedEvent = [SBEventGetLayout new];
    delayedEvent.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    [manager onSBEventGetLayout:delayedEvent];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventResetManager *event = [self.events objectForKey:@"testOnSBEventGetLayoutWithDelay"];
    XCTAssert(event);
    [[Tolo sharedInstance] unsubscribe:manager];
    
}

- (void)testOnSBEventPostLayoutWithError
{
    [keychain removeItemForKey:kPostLayout];
    SBEventPostLayout *event = [SBEventPostLayout new];
    event.error = [[NSError alloc] initWithDomain:@"XCTTestExpectedError" code:100 userInfo:nil];
    PUBLISH(event);
    XCTAssertNil([keychain stringForKey:kPostLayout]);
}

- (void)testOnSBEventPostLayout
{
    [keychain removeItemForKey:kPostLayout];
    SBEventPostLayout *event = [SBEventPostLayout new];
    PUBLISH(event);
    XCTAssert([keychain stringForKey:kPostLayout]);
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

- (void)testReportConversion
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaign:@"testReportConversion"];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssert(event);
    XCTAssert(event.conversionType == kSBConversionUnavailable);
    UNREGISTER();
}

- (void)testReportConversionWithZeroLength
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaign:@""];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssertNil(event);
    UNREGISTER();
}

- (void)testReportConversionWithNSNullInstance
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaign:(NSString *)[NSNull null]];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssertNil(event);
    UNREGISTER();
}

- (void)testReportConversionWithWrongClassInstance
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaign:(NSString *)@(1982)];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssertNil(event);
    UNREGISTER();
}

- (void)testOnSBEventRegionExit
{
    SBEventGetLayout *layoutEvent = [SBEventGetLayout new];
    layoutEvent.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    PUBLISH(layoutEvent);
    
    SBEventRegionEnter *enterEvent = [SBEventRegionEnter new];
    enterEvent.beacon = [layoutEvent.layout.actions[0] beacons][0];
    PUBLISH(enterEvent);
    
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"testOnSBEventRegionExit"]
                          forKey:@"testOnSBEventRegionExit"];
    SBEventRegionExit *exitEvent = [SBEventRegionExit new];
    exitEvent.beacon = [layoutEvent.layout.actions[0] beacons][0];
    PUBLISH(exitEvent);
    [self waitForExpectationsWithTimeout:4 handler:nil];
    SBEventPerformAction *event = [self.events objectForKey:@"testOnSBEventRegionExit"];
    XCTAssert(event);
    UNREGISTER();
}

- (void)testOnSBEventReportHistoryNoForce
{
    SBFakeManager *manager = [SBFakeManager new];
    manager.expectation = [self expectationWithDescription:@"testOnSBEventReportHistoryNoForce"];
    [[Tolo sharedInstance] subscribe:manager];
    REGISTER();
    SBEventGetLayout *layoutEvent = [SBEventGetLayout new];
    layoutEvent.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    PUBLISH(layoutEvent);
    
    SBEventReportHistory *reportHistoryEvent = [SBEventReportHistory new];
    reportHistoryEvent.forced = NO;
    PUBLISH(reportHistoryEvent);
    [self waitForExpectationsWithTimeout:4 handler:nil];
    SBEventPostLayout *event = [self.events objectForKey:@"testOnSBEventReportHistoryNoForce"];
    
    //SBEventPostLayout event should not be fired.
    XCTAssertNil(event);
    [[Tolo sharedInstance] unsubscribe:manager];
    UNREGISTER();
}

- (void)testApplicationDidFinishLaunchingWithOptions
{
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"testApplicationDidFinishLaunchingWithOptions"]
                          forKey:@"testApplicationDidFinishLaunchingWithOptions"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification object:nil];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventApplicationLaunched *event = [self.events objectForKey:@"testApplicationDidFinishLaunchingWithOptions"];
    XCTAssert(event);
    UNREGISTER();
}

- (void)testApplicationDidBecomeActive
{
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"testApplicationDidBecomeActive"]
                          forKey:@"testApplicationDidBecomeActive"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventApplicationActive *event = [self.events objectForKey:@"testApplicationDidBecomeActive"];
    XCTAssert(event);
    UNREGISTER();
}

- (void)testApplicationWillResignActive
{
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"applicationWillResignActive"]
                          forKey:@"applicationWillResignActive"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:nil];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventApplicationWillResignActive *event = [self.events objectForKey:@"applicationWillResignActive"];
    XCTAssert(event);
    UNREGISTER();
}

- (void)testApplicationWillEnterForeground
{
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"applicationWillEnterForeground"]
                          forKey:@"applicationWillEnterForeground"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventApplicationWillEnterForeground *event = [self.events objectForKey:@"applicationWillEnterForeground"];
    XCTAssert(event);
    UNREGISTER();
}

- (void)testApplicationWillTerminate
{
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"applicationWillTerminateNotification"]
                          forKey:@"applicationWillTerminateNotification"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:nil];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    SBEventApplicationWillTerminate *event = [self.events objectForKey:@"applicationWillTerminateNotification"];
    XCTAssert(event);
    UNREGISTER();
}

@end
