//
//  SBLocationTests.m
//  SensorbergSDK
//
//  Created by ParkSanggeon on 01/07/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import "SBTestCase.h"
#import "SBLocation.h"
#import "SBInternalModels.h"
#import "NSString+SBUUID.h"

NSString * const kSBUnitTestRegionUUID0 = @"00000000-0000-0000-0000-000000000000";
NSString * const kSBUnitTestRegionUUID1 = @"11111111-1111-1111-1111-111111111111";
NSString * const kSBUnitTestRegionUUID2 = @"22222222-2222-2222-2222-222222222222";
NSString * const kSBUnitTestRegionUUID3 = @"33333333-3333-3333-3333-333333333333";

@interface SBUnitTestBeacon : NSObject
@property (nonatomic, strong) NSUUID *proximityUUID;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;
@property (nonatomic) CLProximity proximity;
@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic) NSInteger rssi;
@end

@implementation SBUnitTestBeacon @end

@interface SBLocation (UnitTests)
- (void)didFindBeacons:(NSArray <CLBeacon *> *)beacons;
- (void)clearSessionWithRegions:(NSArray <NSString *> *)regions;
- (void)checkRegionExitWithRegionUUID:(NSString *)UUID inRegion:(BOOL)inRegoin dispatchedTimeIntervalSince1970:(NSTimeInterval)dispatchedTimeInterval;
- (void)checkRegionExitWithRegionUUID:(NSString *)UUID inRegion:(BOOL)inRegoin;
@end


@interface SBLocationTests : SBTestCase
@property (nonatomic, strong) SBLocation *sut;
@property (nonatomic, strong) NSArray <CLBeacon *> *beacons;
@end

@implementation SBLocationTests

- (void)setUp {
    [super setUp];
    self.sut = [SBLocation new];
    
    SBUnitTestBeacon *beacon0 = [SBUnitTestBeacon new];
    beacon0.proximityUUID = [[NSUUID alloc] initWithUUIDString:kSBUnitTestRegionUUID0];
    beacon0.major = @(0);
    beacon0.minor = @(0);
    
    SBUnitTestBeacon *beacon1 = [SBUnitTestBeacon new];
    beacon1.proximityUUID = [[NSUUID alloc] initWithUUIDString:kSBUnitTestRegionUUID1];
    beacon1.major = @(1);
    beacon1.minor = @(1);
    
    SBUnitTestBeacon *beacon2 = [SBUnitTestBeacon new];
    beacon2.proximityUUID = [[NSUUID alloc] initWithUUIDString:kSBUnitTestRegionUUID2];
    beacon2.major = @(2);
    beacon2.minor = @(2);
    
    self.beacons = @[(CLBeacon *)beacon0,(CLBeacon *)beacon1,(CLBeacon *)beacon2];
    [self.sut didFindBeacons:self.beacons];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.sut = nil;
    self.beacons = nil;
    [super tearDown];
}

- (void)testDidFindBeacons
{
    NSString *proximityUUIDPrefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    
    NSDictionary *sessions = [self.sut currentSessions];
    
    BOOL hasBeaconSession = NO;
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUIDPrefix])
        {
            hasBeaconSession = YES;
            break;
        }
    }
    
    XCTAssert(hasBeaconSession);
}

- (void)testClearSessionWithRegionsForAllBeacons
{
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    NSString *proximityUUID1Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID1] lowercaseString];
    NSString *proximityUUID2Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID2] lowercaseString];
    
    [self.sut clearSessionWithRegions:@[kSBUnitTestRegionUUID3]];
    
    NSDictionary *sessions = [self.sut currentSessions];
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix] ||
            [session.pid hasPrefix:proximityUUID1Prefix] ||
            [session.pid hasPrefix:proximityUUID2Prefix])
        {
            XCTAssert(NO, @"There should not be any sessions.");
            break;
        }
    }
}

- (void)testClearSessionWithRegionsForOneBeacon
{
    NSString *proximityUUID2Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID2] lowercaseString];
    
    NSDictionary *sessions = [self.sut currentSessions];
    
    [self.sut clearSessionWithRegions:@[kSBUnitTestRegionUUID0,kSBUnitTestRegionUUID1]];
    
    sessions = [self.sut currentSessions];
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID2Prefix])
        {
            XCTAssert(NO, @"There should not be any sessions for proximityUUID2");
            break;
        }
    }
}

- (void)testClearSessionWithRegionsForNothing
{
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    NSString *proximityUUID1Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID1] lowercaseString];
    NSString *proximityUUID2Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID2] lowercaseString];
    
    [self.sut clearSessionWithRegions:@[kSBUnitTestRegionUUID0,kSBUnitTestRegionUUID1,kSBUnitTestRegionUUID2]];
    
    NSDictionary *sessions = [self.sut currentSessions];
    
    for (SBMSession *session in sessions.allValues)
    {
        if (![session.pid hasPrefix:proximityUUID0Prefix] &&
            ![session.pid hasPrefix:proximityUUID1Prefix] &&
            ![session.pid hasPrefix:proximityUUID2Prefix])
        {
            XCTAssert(NO, @"There should not be any session which doesn't have known UUID prefixes.");
            break;
        }
    }
}

- (void)testCheckRegionExitWithRegionUUIDInRegionDispatchedTimeIntervalSince1970
{
    [self.sut checkRegionExitWithRegionUUID:kSBUnitTestRegionUUID0 inRegion:YES dispatchedTimeIntervalSince1970:[NSDate date].timeIntervalSince1970];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    
    NSDictionary *sessions = [self.sut currentSessions];
    
    BOOL hasSession = NO;
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix])
        { // it should have session because of monitoring interval.
            hasSession = YES;
            break;
        }
    }
    
    XCTAssert(hasSession, @"session for Beacon is removed.");
}

- (void)testCheckRegionExitWithRegionUUIDInRegionDispatchedTimeIntervalSince1970WithDisappearedBeacon
{
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = [NSDate dateWithTimeIntervalSinceNow: -60];
    [self.sut checkRegionExitWithRegionUUID:kSBUnitTestRegionUUID0 inRegion:YES dispatchedTimeIntervalSince1970:[NSDate date].timeIntervalSince1970];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    
    sessions = [self.sut currentSessions];
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix])
        { // it should have session because of monitoring interval.
            XCTAssert(NO, @"It should be removed.");
            break;
        }
    }
}

- (void)testCheckRegionExitWithRegionUUIDInRegionDispatchedTimeIntervalSince1970WithDisappearedBeaconButInvalidFunctionCall
{
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = [NSDate dateWithTimeIntervalSinceNow: -60];
    [self.sut checkRegionExitWithRegionUUID:kSBUnitTestRegionUUID0 inRegion:YES dispatchedTimeIntervalSince1970:[NSDate date].timeIntervalSince1970 - 10];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    
    sessions = [self.sut currentSessions];
    BOOL hasBeaconSession = NO;
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix])
        { // it should have session because of monitoring interval.
            hasBeaconSession = YES;
            break;
        }
    }
    
    XCTAssert(hasBeaconSession, @"It should not be removed. Because the function call was not in valid timing.");
}

- (void)testCheckRegionExitWithRegionUUIDInRegion
{
    [self.sut checkRegionExitWithRegionUUID:kSBUnitTestRegionUUID0 inRegion:YES];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    
    NSDictionary *sessions = [self.sut currentSessions];
    
    BOOL hasSession = NO;
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix])
        { // it should have session because of monitoring interval.
            hasSession = YES;
            break;
        }
    }
    
    XCTAssert(hasSession, @"session for Beacon is removed.");
}

- (void)testCheckRegionExitWithRegionUUIDInRegionWithNotInRegion
{
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = [NSDate dateWithTimeIntervalSinceNow: -60];
    SBMSession *beacon1Session = sessions[@"111111111111111111111111111111110000100001"];
    beacon1Session.lastSeen = [NSDate dateWithTimeIntervalSinceNow: -60];
    SBMSession *beacon2Session = sessions[@"222222222222222222222222222222220000200002"];
    beacon2Session.lastSeen = [NSDate dateWithTimeIntervalSinceNow: -60];
    
    [self.sut checkRegionExitWithRegionUUID:kSBUnitTestRegionUUID0 inRegion:NO];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    NSString *proximityUUID1Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID1] lowercaseString];
    NSString *proximityUUID2Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID2] lowercaseString];
    
    sessions = [self.sut currentSessions];
    
    BOOL hasBeacon0 = NO;
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix])
        {
            hasBeacon0 = YES;
        }
        if ([session.pid hasPrefix:proximityUUID1Prefix] || [session.pid hasPrefix:proximityUUID2Prefix])
        { // it should not have session
            XCTAssert(NO, @"this session should be removed.");
            break;
        }
    }
    
    XCTAssert(hasBeacon0, @"even last seen date is older than monitoringTiming, this beacon was not in checking scope. therefore it should be there.");
}

@end
