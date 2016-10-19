//
//  SBManagerTests.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SBTestCase.h"

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

FOUNDATION_EXPORT NSString * const SBDefaultResolverURL;

@interface SBManager ()
SUBSCRIBE(SBEventGetLayout);
SUBSCRIBE(SBEventReportHistory);
SUBSCRIBE(SBEventRangedBeacon);
@end

@interface SBManager (XCTestCase)
- (void)setResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate;
@end

@interface SBFakeManager : SBManager
@property (nullable, strong) XCTestExpectation *expectation;
@property (nonnull, strong) SBEventRangedBeacon *expectedRangedBeaconEvent;
@property (nonnull, strong) NSArray <NSString*> *UUIDs;
- (void)startMonitoring:(NSArray <NSString*>*)UUIDs;
SUBSCRIBE(SBEventGetLayout);
SUBSCRIBE(SBEventReportHistory);
SUBSCRIBE(SBEventRangedBeacon);
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-declarations"

@implementation SBFakeManager

SUBSCRIBE(SBEventRangedBeacon)
{
    [super onSBEventRangedBeacon:event];
    self.expectedRangedBeaconEvent = event;
    [self.expectation fulfill];
    self.expectation = nil;
}

SUBSCRIBE(SBEventGetLayout)
{
    [super onSBEventGetLayout:event];
}
SUBSCRIBE(SBEventReportHistory)
{
    [super onSBEventReportHistory:event];
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.expectation fulfill];
        weakself.expectation = nil;
    });
}
#pragma clan diagnostic pop
- (void)startMonitoring:(NSArray <NSString*>*)UUIDs
{
    [super startMonitoring:UUIDs];
    _UUIDs = UUIDs;
    [self.expectation fulfill];
    self.expectation = nil;
}
@end

@interface SBManagerTests : SBTestCase
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
    
    self.sut = [SBManager sharedManager];
    self.defaultAPIKey = @"c36553abc7e22a18a4611885addd6fdf457cc69890ba4edc7650fe242aa42378";
    [self.sut setApiKey:self.defaultAPIKey delegate:nil];
    [self.sut requestNotificationsAuthorization];
    [self.sut requestLocationAuthorization:YES];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    SBLocationAuthorizationStatus locState = [self.sut locationAuthorization];
    [self.sut requestBluetoothAuthorization];
    SBBluetoothStatus bleState = [self.sut bluetoothAuthorization];
    [[Tolo sharedInstance] subscribe:self.sut];
#pragma clang diagnostic pop
    REGISTER();
}

- (void)tearDown {
    [[Tolo sharedInstance] unsubscribe:self.sut];
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
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testResetSharedClientInBackgroundThread"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"testResetSharedClientInBackgroundThread"];
    [expectation fulfill];
}

SUBSCRIBE(SBEventGetLayout)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"testSetResolverApiKeyDelegateInBackgroundThread"];
}

SUBSCRIBE(SBEventUpdateHeaders)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testSetIDFAValue"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"testSetIDFAValue"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"testSetIDFAValue"];
}

SUBSCRIBE(SBEventReportHistory)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testOnSBEventGetLayoutWithDelay"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"testOnSBEventGetLayoutWithDelay"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"testOnSBEventGetLayoutWithDelay"];
}

SUBSCRIBE(SBEventPerformAction)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testOnSBEventRegionExit"];
    if (!expectation)
    {
        return;
    }
    
    [self.events setObject:event forKey:@"testOnSBEventRegionExit"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"testOnSBEventRegionExit"];
}

SUBSCRIBE(SBEventPostLayout)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"test023OnSBEventReportHistoryNoForce"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"test023OnSBEventReportHistoryNoForce"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"test023OnSBEventReportHistoryNoForce"];
}

SUBSCRIBE(SBEventApplicationLaunched)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testApplicationDidFinishLaunchingWithOptions"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"testApplicationDidFinishLaunchingWithOptions"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"testApplicationDidFinishLaunchingWithOptions"];
}

SUBSCRIBE(SBEventApplicationActive)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"testApplicationDidBecomeActive"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"testApplicationDidBecomeActive"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"testApplicationDidBecomeActive"];
}

SUBSCRIBE(SBEventApplicationWillTerminate)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"applicationWillTerminateNotification"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"applicationWillTerminateNotification"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"applicationWillTerminateNotification"];
}

SUBSCRIBE(SBEventApplicationWillResignActive)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"applicationWillResignActive"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"applicationWillResignActive"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"applicationWillResignActive"];
}

SUBSCRIBE(SBEventApplicationWillEnterForeground)
{
    XCTestExpectation *expectation = [self.expectations objectForKey:@"applicationWillEnterForeground"];
    if (!expectation)
    {
        return;
    }
    [self.events setObject:event forKey:@"applicationWillEnterForeground"];
    [expectation fulfill];
    [self.expectations removeObjectForKey:@"applicationWillEnterForeground"];
}

- (void)testInitalization {
    XCTAssert([SBAPIKey isEqualToString:self.defaultAPIKey]);
#if TEST_STAGING
    XCTAssert([SBResolverURL isEqualToString:[kSBStagingResolverURL copy]]);
#else
    XCTAssert([SBResolverURL isEqualToString:SBDefaultResolverURL]);
#endif
}

- (void)test000ResetSharedClient {
    [[SBManager sharedManager] resetSharedClient];
    XCTAssertNil(SBAPIKey);
    XCTAssertNil(SBResolverURL);
}

- (void)test001ResetSharedClientInBackgroundThread
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

-(void)test002Ping
{
    [self.expectations setObject:[self expectationWithDescription:@"testResetSharedClientInBackgroundThread"]
                          forKey:@"testResetSharedClientInBackgroundThread"];
    REGISTER();
    [self.sut requestResolverStatus];
    [self waitForExpectationsWithTimeout:6 handler:nil];
    SBEventPing *event = [self.events objectForKey:@"testResetSharedClientInBackgroundThread"];
    XCTAssert(event);
    XCTAssertNil(event.error);
    XCTAssert(event.latency == self.sut.resolverLatency);
    UNREGISTER();
}

-(void)test003LatencyWithError
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

- (void)test004SetResolverApiKeyDelegateWithNilApiKey
{
    [self.sut setResolver:nil apiKey:nil delegate:nil];
    XCTAssert([SBAPIKey isEqualToString:kSBDefaultAPIKey]);
}

- (void)test005SetResolverApiKeyDelegateWithCustomResolver
{
    NSString *customResolver = @"ThisIsCustomResolver.";
    [self.sut setResolver:customResolver apiKey:self.defaultAPIKey delegate:nil];
    XCTAssert([SBAPIKey isEqualToString:self.defaultAPIKey]);
    XCTAssert([SBResolverURL isEqualToString:customResolver]);
}

- (void)test006SetResolverApiKeyDelegateInBackgroundThread
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

- (void)test007StartMonitoringWithLayout
{
    SBFakeManager *manager = [SBFakeManager new];
    SBEventGetLayout *event = [SBEventGetLayout new];
    event.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    PUBLISH(event);
    [manager startMonitoring];
    XCTAssert(manager.UUIDs.count >= [SBSettings sharedManager].settings.customBeaconRegions.allKeys.count);
}

- (void)test008StartMonitoringWithNullLayout
{
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    [manager startMonitoring];
    XCTAssertTrue(manager.UUIDs.count == [SBSettings sharedManager].settings.defaultBeaconRegions.allKeys.count);
    
    [[Tolo sharedInstance] unsubscribe:manager];
}

- (void)test009OnSBEventGetLayoutWithError
{
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    
    SBEventGetLayout *event = [SBEventGetLayout new];
    event.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    event.error = [[NSError alloc] initWithDomain:@"XCTTestExpectedError" code:100 userInfo:nil];
    PUBLISH(event);
    XCTAssertFalse(manager.UUIDs.count >= [SBSettings sharedManager].settings.defaultBeaconRegions.allKeys.count);
    
    [[Tolo sharedInstance] unsubscribe:manager];
}

- (void)test010OnSBEventGetLayoutWithDelay
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
    UNREGISTER();
}

- (void)test011OnSBEventPostLayoutWithError
{
    [keychain removeItemForKey:kPostLayout];
    SBEventPostLayout *event = [SBEventPostLayout new];
    event.error = [[NSError alloc] initWithDomain:@"XCTTestExpectedError" code:100 userInfo:nil];
    PUBLISH(event);
    XCTAssertNil([keychain stringForKey:kPostLayout]);
}

- (void)test012OnSBEventPostLayout
{
    [keychain removeItemForKey:kPostLayout];
    SBEventPostLayout *event = [SBEventPostLayout new];
    PUBLISH(event);
    XCTAssert([keychain stringForKey:kPostLayout]);
}

- (void)test013SetIDFAValue
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

- (void)test014SetIDFAValueWithZeroLength
{
    [keychain removeItemForKey:kIDFA];
    REGISTER();
    [self.sut setIDFAValue:@""];
    XCTAssertNil([keychain stringForKey:kIDFA]);
    UNREGISTER();
    
}

- (void)test015SetIDFAValueWithNSNullInstance
{
    [keychain removeItemForKey:kIDFA];
    REGISTER();
    [self.sut setIDFAValue:(NSString *)[NSNull null]];
    XCTAssertNil([keychain stringForKey:kIDFA]);
    UNREGISTER();
    
}

- (void)test016SetIDFAValueWithWrongClassInstance
{
    [keychain removeItemForKey:kIDFA];
    REGISTER();
    [self.sut setIDFAValue:(NSString *)@(0)];
    XCTAssertNil([keychain stringForKey:kIDFA]);
    UNREGISTER();
}

- (void)test017ReportConversion
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaignAction:@"testReportConversion"];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssert(event);
    XCTAssert(event.conversionType == kSBConversionUnavailable);
    UNREGISTER();
}

- (void)test018ReportConversionWithZeroLength
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaignAction:@""];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssertNil(event);
    UNREGISTER();
}

- (void)test019ReportConversionWithNSNullInstance
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaignAction:(NSString *)[NSNull null]];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssertNil(event);
    UNREGISTER();
}

- (void)test020ReportConversionWithWrongClassInstance
{
    REGISTER();
    [self.sut reportConversion:kSBConversionUnavailable forCampaignAction:(NSString *)@(1982)];
    SBEventReportConversion *event = [self.events objectForKey:@"testReportConversion"];
    XCTAssertNil(event);
    UNREGISTER();
}

- (void)test021OnSBEventRegionExit
{
    REGISTER();
    [self.expectations setObject:[self expectationWithDescription:@"testOnSBEventRegionExit"]
                          forKey:@"testOnSBEventRegionExit"];
    SBEventRegionExit *exitEvent = [SBEventRegionExit new];
    SBMGetLayout *layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    exitEvent.beacon = [layout.actions[0] beacons][0];
    PUBLISH(exitEvent);
    [self waitForExpectationsWithTimeout:10 handler:nil];
    SBEventPerformAction *event = [self.events objectForKey:@"testOnSBEventRegionExit"];
    XCTAssert(event);
    UNREGISTER();
}

- (void)test022OnSBEventRangedBeacon
{
    SBFakeManager *manager = [SBFakeManager new];
    [[Tolo sharedInstance] subscribe:manager];
    manager.expectation = [self expectationWithDescription:@"test022OnSBEventRangedBeacon"];
    REGISTER();
    SBEventRangedBeacon *rangeEvent = [SBEventRangedBeacon new];
    PUBLISH(rangeEvent);
    [self waitForExpectationsWithTimeout:1 handler:nil];
    //SBEventPostLayout event should not be fired.
    XCTAssert(manager.expectedRangedBeaconEvent);
    [[Tolo sharedInstance] unsubscribe:manager];
    UNREGISTER();
}


- (void)test023OnSBEventReportHistoryNoForce
{
    SBFakeManager *manager = [SBFakeManager new];
    manager.expectation = [self expectationWithDescription:@"test023OnSBEventReportHistoryNoForce"];
    [[Tolo sharedInstance] subscribe:manager];
    REGISTER();
    SBEventGetLayout *layoutEvent = [SBEventGetLayout new];
    layoutEvent.layout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    PUBLISH(layoutEvent);
    
    SBEventReportHistory *reportHistoryEvent = [SBEventReportHistory new];
    reportHistoryEvent.forced = NO;
    PUBLISH(reportHistoryEvent);
    [self waitForExpectationsWithTimeout:10 handler:nil];
    SBEventPostLayout *event = [self.events objectForKey:@"test023OnSBEventReportHistoryNoForce"];
    
    //SBEventPostLayout event should not be fired.
    XCTAssertNil(event);
    [[Tolo sharedInstance] unsubscribe:manager];
    UNREGISTER();
}

- (void)test024ApplicationDidFinishLaunchingWithOptions
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

- (void)test025ApplicationDidBecomeActive
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

- (void)test026ApplicationWillResignActive
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

- (void)test027ApplicationWillEnterForeground
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

- (void)test028ApplicationWillTerminate
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
