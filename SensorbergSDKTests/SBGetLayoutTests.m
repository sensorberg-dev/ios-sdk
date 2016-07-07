//
//  SBGetLayoutTests.m
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

#import "SBResolver.h"
#import "SBSettings.h"
#import "SBInternalModels.h"
#import "SBEvent.h"
#import "SBInternalEvents.h"

#import "SBUtility.h"
#import <tolo/Tolo.h>

@interface SBMGetLayout (XCTests)
- (BOOL)campaignIsInTimeframes:(NSArray <SBMTimeframe> *)timeframes;
- (SBMCampaignAction *)campainActionWithAction:(SBMAction *)action beacon:(SBMBeacon *)beacon trigger:(SBTriggerType)trigger;
- (void)fireAction:(SBMAction *)action forBeacon:(SBMBeacon *)beacon withTrigger:(SBTriggerType)trigger;
- (BOOL)campaignHasFired:(NSString*)eid;
- (NSTimeInterval)secondsSinceLastFire:(NSString*)eid;

@end

@interface SBGetLayoutTests : SBTestCase
@property (nullable, nonatomic, strong) XCTestExpectation *expectation;
@property (nullable, nonatomic, strong) SBEvent *expectedEvent;
@property (nullable, nonatomic, strong) SBEvent *expectedReportHistoryEvent;
@property (nullable, nonatomic, strong) SBEvent *expectedGetLayoutEvent;
@property (nullable, nonatomic, strong) NSMutableDictionary *defaultLayoutDict;
@property (nullable, nonatomic, strong) NSMutableDictionary *suppressionTimeLayoutDict;
@property (nullable, nonatomic, strong) SBMBeacon *defaultBeacon;
@property (nullable, nonatomic, strong) SBMBeacon *suppressionTimeBeacon;
@end

@implementation SBGetLayoutTests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    self.defaultLayoutDict = [@{
                               @"accountProximityUUIDs" : [@[@"7367672374000000ffff0000ffff0003", @"7367672374000000ffff0000ffff0007"] mutableCopy],
                               @"actions" : [@[
                                       [@{
                                           @"eid": @"367348a0dfa84492a0078ead26cf9385",
                                           @"trigger": @(kSBTriggerEnter),
                                           @"beacons": @[
                                                   @"7367672374000000ffff0000ffff00030000200747",
                                                   @"7367672374000000ffff0000ffff00070100001200"
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
    
    self.suppressionTimeLayoutDict = [self.defaultLayoutDict mutableCopy];
    self.suppressionTimeLayoutDict[@"actions"][0][@"suppressionTime"] = @(2);
    
    self.defaultBeacon = [[SBMBeacon alloc] initWithString:@"7367672374000000ffff0000ffff00030000200747"];
    self.suppressionTimeBeacon = [[SBMBeacon alloc] initWithString:@"7367672374000000ffff0000ffff00070100001200"];
    keychain = [UICKeyChainStore keyChainStoreWithService:@"c36553abc7e22a18a4611885addd6fdf457cc69890ba4edc7650fe242aa42378"];

    REGISTER();
}

- (void)tearDown {
    UNREGISTER();
    self.expectation = nil;
    self.expectedEvent = nil;
    self.defaultLayoutDict = nil;
    self.suppressionTimeLayoutDict = nil;
    self.defaultBeacon = nil;
    self.suppressionTimeBeacon = nil;
    self.expectedReportHistoryEvent = nil;
    [keychain removeAllItems];
    keychain = nil;
    [super tearDown];
}

SUBSCRIBE(SBEventPerformAction)
{
    self.expectedEvent = event;
    [self.expectation fulfill];
}

SUBSCRIBE(SBEventReportHistory)
{
    self.expectedReportHistoryEvent = event;
    [self.expectation fulfill];
}

SUBSCRIBE(SBEventGetLayout)
{
    self.expectedGetLayoutEvent = event;
    [self.expectation fulfill];
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldFireWithRightTrigger
{
    self.expectation = [self expectationWithDescription:@"Waiting for firing SBEventPerformAction event"];
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:1];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
    XCTAssert(self.expectedEvent);
    XCTAssertTrue([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
    self.expectedEvent = nil;
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithWrongTrigger
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:0];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerExit];
    
    XCTAssertNil(self.expectedEvent);
    XCTAssertFalse([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithWrongTriggerInLayout
{
    NSMutableDictionary *newLayoutDict = [self.defaultLayoutDict mutableCopy];
    newLayoutDict[@"actions"][0][@"trigger"] = @(0);
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnterExit];
    
    XCTAssertNil(self.expectedEvent);
    XCTAssertFalse([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithWrongTimeFrame
{
    NSMutableDictionary *newLayoutDict = [self.defaultLayoutDict mutableCopy];
    newLayoutDict[@"actions"][0][@"timeframes"] = @[
                                                    @{
                                                        @"start": @"2016-04-01T10:00:00.000+0000",
                                                        @"end": @"2016-04-30T23:00:00.000+0000"
                                                        }
                                                    ];
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:newLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnter];
    XCTAssertNil(self.expectedEvent);
}


- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithWrongBeacon
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMBeacon *newBeacon = [[SBMBeacon alloc] initWithString:@"7367672374000000ffff0000eeee00030000200747"];
    [newLayout checkCampaignsForBeacon:newBeacon trigger:kSBTriggerEnterExit];
    
    XCTAssertNil(self.expectedEvent);
    XCTAssertFalse([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithAlreadyFiredBeaconForSendOnlyOnceAction
{
    NSMutableDictionary *newLayoutDict = [self.defaultLayoutDict mutableCopy];
    newLayoutDict[@"actions"][0][@"sendOnlyOnce"] = @(YES);
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:newLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnter];
    XCTAssert(self.expectedEvent);
    XCTAssert([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
    
    // reset expectedEvent.
    self.expectedEvent = nil;
    
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnter];
    
    XCTAssertNil(self.expectedEvent);
    XCTAssert([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithPastDeiveryAtProperty
{
    NSMutableDictionary *newLayoutDict = [self.defaultLayoutDict mutableCopy];
    newLayoutDict[@"actions"][0][@"deliverAt"] = [dateFormatter stringFromDate:[NSDate date]];
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:newLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnter];
    XCTAssertNil(self.expectedEvent);
    XCTAssertFalse([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
}

- (void)testCheckCampaignsForBeaconAndTriggerShouldNotFireWithSuppressionTime
{
    NSMutableDictionary *newLayoutDict = [self.suppressionTimeLayoutDict mutableCopy];
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:newLayoutDict error:nil];
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnter];
    XCTAssert(self.expectedEvent);
    XCTAssert([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
    
    // reset expectedEvent.
    self.expectedEvent = nil;
    
    [newLayout checkCampaignsForBeacon:self.defaultBeacon trigger:kSBTriggerEnter];
    
    XCTAssertNil(self.expectedEvent);
    XCTAssert([newLayout campaignHasFired:[newLayout.actions[0] eid]]);
}

- (void)testCampaignIsInTimeframesWithCorrectTimeFrames
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < 2; index++)
    {
        SBMTimeframe *timeframe = [SBMTimeframe new];
        timeframe.start = [NSDate date];
        timeframe.end = [NSDate dateWithTimeIntervalSinceNow:1000];
        [timeFrames addObject:timeframe];
    }
    
    XCTAssertTrue([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithEmptyTimeFrames
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    XCTAssertFalse([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithNullTimeFrames
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    XCTAssertFalse([newLayout campaignIsInTimeframes:nil]);
}

- (void)testCampaignIsInTimeframesWithWrongTimeFrames
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    
    SBMTimeframe *timeframe = [SBMTimeframe new];
    timeframe.start = [NSDate dateWithTimeIntervalSinceNow:-1000];
    timeframe.end = [NSDate date];
    [timeFrames addObject:timeframe];
    
    XCTAssertFalse([newLayout campaignIsInTimeframes:timeFrames]);
    
    timeframe = [SBMTimeframe new];
    timeframe.start = [NSDate date];
    timeframe.end = [NSDate dateWithTimeIntervalSinceNow:-1000];
    [timeFrames addObject:timeframe];
    
    XCTAssertFalse([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithNoStart
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    
    SBMTimeframe *timeframe = [SBMTimeframe new];
    timeframe.end = [NSDate dateWithTimeIntervalSinceNow:1000];
    [timeFrames addObject:timeframe];
    
    XCTAssertTrue([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithNoStartAndWrongEndDate
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    
    SBMTimeframe *timeframe = [SBMTimeframe new];
    timeframe.end = [NSDate dateWithTimeIntervalSinceNow:-1000];
    [timeFrames addObject:timeframe];
    
    XCTAssertFalse([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithNoEnd
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    
    SBMTimeframe *timeframe = [SBMTimeframe new];
    timeframe.start = [NSDate date];
    [timeFrames addObject:timeframe];
    
    XCTAssertTrue([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithNoEndAndDelayedStartDate
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    
    SBMTimeframe *timeframe = [SBMTimeframe new];
    timeframe.start = [NSDate dateWithTimeIntervalSinceNow:1000];
    [timeFrames addObject:timeframe];
    
    XCTAssertFalse([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampaignIsInTimeframesWithNoStartAndNoEnd
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    NSMutableArray <SBMTimeframe> *timeFrames = (NSMutableArray <SBMTimeframe> *)[[NSMutableArray alloc] init];
    
    SBMTimeframe *timeframe = [SBMTimeframe new];
    [timeFrames addObject:timeframe];
    
    XCTAssertTrue([newLayout campaignIsInTimeframes:timeFrames]);
}

- (void)testCampainActionWithActionBeaconTrigger
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    SBMCampaignAction *resultAction = [newLayout campainActionWithAction:action beacon:self.defaultBeacon trigger:kSBTriggerEnter];
    
    XCTAssert([resultAction.eid isEqualToString:action.eid]);
    
    if (resultAction.subject)
    {
        XCTAssert([resultAction.subject isEqualToString:action.content.subject]);
    }
    else
    {
        XCTAssertNil(action.content.subject);
    }
    
    if (resultAction.body)
    {
        XCTAssert([resultAction.body isEqualToString:action.content.body]);
    }
    else
    {
        XCTAssertNil(action.content.body);
    }
    
    if (resultAction.payload)
    {
        XCTAssert([resultAction.payload isEqual:action.content.payload]);
    }
    else
    {
        XCTAssertNil(action.content.payload);
    }
    
    if (resultAction.url)
    {
        XCTAssert([resultAction.url isEqualToString:action.content.url]);
    }
    else
    {
        XCTAssertNil(action.content.url);
    }
    
    XCTAssert(resultAction.trigger == kSBTriggerEnter);
    XCTAssert(resultAction.type == action.type);
}

- (void)testCampainActionWithActionBeaconTriggerWithDeliverAtProperty
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    action.deliverAt = [NSDate date];
    SBMCampaignAction *resultAction = [newLayout campainActionWithAction:action beacon:self.defaultBeacon trigger:kSBTriggerEnter];
    
    XCTAssert([resultAction.fireDate isEqual:action.deliverAt]);
}

- (void)testCampainActionWithActionBeaconTriggerWithDelay
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    action.delay = 120;
    NSDate *laterDate = [NSDate dateWithTimeIntervalSinceNow:120];
    SBMCampaignAction *resultAction = [newLayout campainActionWithAction:action beacon:self.defaultBeacon trigger:kSBTriggerEnter];
    
    XCTAssert([resultAction.fireDate laterDate:laterDate] == resultAction.fireDate);
}

- (void)testFireActionWithBeaconAndTrigger
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    [newLayout fireAction:action forBeacon:self.defaultBeacon withTrigger:kSBTriggerEnter];
    
    XCTAssert(self.expectedEvent);
    XCTAssertTrue([newLayout campaignHasFired:action.eid]);
}

- (void)testFireActionWithBeaconAndTriggerWithReportImmediately
{
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    action.reportImmediately = YES;
    [newLayout fireAction:action forBeacon:self.defaultBeacon withTrigger:kSBTriggerEnter];
    
    XCTAssert(self.expectedEvent);
    XCTAssertTrue([newLayout campaignHasFired:action.eid]);
}

- (void)testSecondsSinceLastFire
{
    NSTimeInterval lastFireTimeInterval = 0;
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    [newLayout fireAction:action forBeacon:self.defaultBeacon withTrigger:kSBTriggerEnter];
    lastFireTimeInterval = [newLayout secondsSinceLastFire:action.eid];
    
    XCTAssert(self.expectedEvent);
    XCTAssertTrue([newLayout campaignHasFired:action.eid]);
    XCTAssert(lastFireTimeInterval > 0);
}

- (void)testSecondsSinceLastFireWithWrongEventID
{
    NSTimeInterval lastFireTimeInterval = 0;
    SBMGetLayout *newLayout = [[SBMGetLayout alloc] initWithDictionary:self.defaultLayoutDict error:nil];
    SBMAction *action = newLayout.actions[0];
    [newLayout fireAction:action forBeacon:self.defaultBeacon withTrigger:kSBTriggerEnter];
    lastFireTimeInterval = [newLayout secondsSinceLastFire:@"This is Stupid ID"];
    
    XCTAssert(self.expectedEvent);
    XCTAssertTrue([newLayout campaignHasFired:action.eid]);
    XCTAssertFalse([newLayout campaignHasFired:@"This is Stupid ID"]);
    XCTAssert(lastFireTimeInterval == -1);
}

- (void)testSBMSession
{
    SBMSession *session = [[SBMSession alloc] initWithUUID:self.defaultBeacon.fullUUID];
    XCTAssert(session.pid.length);
    XCTAssert(session.enter);
    XCTAssertNil(session.exit);
    XCTAssert(session.lastSeen);
    XCTAssert([session.lastSeen isEqual:session.enter]);
}

- (void)testSuppressionTimeWithResolver
{
    self.expectation = [self expectationWithDescription:@"Waiting for firing SBEventGetLayout event"];
    SBResolver *testResolver = [[SBResolver alloc] initWithResolver:[SBSettings sharedManager].settings.resolverURL apiKey:@"10eede0e18b3b907c4257dbcf69c29e0781a45338f09bffd3d89d8dd941d0a45"];
    [testResolver requestLayoutForBeacon:nil trigger:kSBTriggerEnter useCache:YES];
    
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
    XCTAssertNotNil(self.expectedGetLayoutEvent);
    
    self.expectedGetLayoutEvent = nil;
    
    self.expectation = [self expectationWithDescription:@"Waiting for firing SBEventPerformAction event"];
    
    [testResolver requestLayoutForBeacon:self.suppressionTimeBeacon trigger:kSBTriggerEnter useCache:YES];
    
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    
    XCTAssert(self.expectedEvent);
    
    self.expectedEvent = nil;
    
    self.expectation = [self expectationWithDescription:@""];
    
    [testResolver requestLayoutForBeacon:self.suppressionTimeBeacon trigger:kSBTriggerEnter useCache:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertNil(self.expectedEvent);
}
@end
