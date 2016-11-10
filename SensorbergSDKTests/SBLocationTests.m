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
#import <tolo/Tolo.h>

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
- (void)updateSessionsWithBeacons:(NSArray <CLBeacon *> *)beacons;
- (void)checkRegionExit;
@end


@interface SBLocationTests : SBTestCase
@property (nonatomic, strong) SBLocation *sut;
@property (nonatomic, strong) NSArray <CLBeacon *> *beacons;
@end

@implementation SBLocationTests

- (void)setUp {
    [super setUp];
    self.sut = [SBLocation new];
    [[Tolo sharedInstance] subscribe:self.sut];
    
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
    [self.sut updateSessionsWithBeacons:self.beacons];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[Tolo sharedInstance] unsubscribe:self.sut];
    self.sut = nil;
    self.beacons = nil;
    [super tearDown];
}

- (void)test000DidFindBeacons
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

- (void)test004CheckRegionExitWithRegionUUIDInRegionDispatchedTimeIntervalSince1970
{
    [self.sut checkRegionExit];
    
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

- (void)test005CheckRegionExitWithRegionUUIDInRegionDispatchedTimeIntervalSince1970WithDisappearedBeacon
{
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = [[NSDate date] timeIntervalSince1970] - 120;
    [self.sut checkRegionExit];
    beacon0Session.exit = [[NSDate date] timeIntervalSince1970] - 4;
    [self.sut checkRegionExit];
    
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

- (void)test006CheckRegionExitWithRegionUUIDInRegionDispatchedTimeIntervalSince1970WithDisappearedBeaconButInvalidFunctionCall
{
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = [[NSDate date] timeIntervalSince1970] - 20;
    [self.sut checkRegionExit];
    
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

- (void)test007CheckRegionExitWithRegionUUIDInRegion
{
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = [NSDate date].timeIntervalSince1970 - 5;
    [self.sut checkRegionExit];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    
    BOOL hasSession = NO;
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix] && session.exit <= 0)
        { // it should have session because of monitoring delay.
            hasSession = YES;
            break;
        }
    }
    
    XCTAssert(hasSession, @"session for Beacon is removed.");
}

- (void)test008CheckRegionExitWithRegionUUIDInRegionWithNotInRegion
{
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    NSDictionary *sessions = [self.sut currentSessions];
    SBMSession *beacon0Session = sessions[@"000000000000000000000000000000000000000000"];
    beacon0Session.lastSeen = now - 120;
    SBMSession *beacon1Session = sessions[@"111111111111111111111111111111110000100001"];
    beacon1Session.lastSeen = now - 120;
    SBMSession *beacon2Session = sessions[@"222222222222222222222222222222220000200002"];
    beacon2Session.lastSeen = now - 120;
    
    [self.sut checkRegionExit];
    
    XCTAssert(beacon0Session.exit > now);
    XCTAssert(beacon1Session.exit > now);
    XCTAssert(beacon2Session.exit > now);
    
    beacon0Session.exit = beacon0Session.exit - 4.5f;
    beacon1Session.exit = beacon1Session.exit - 4.5f;
    beacon2Session.exit = beacon2Session.exit - 4.5f;
    
    [self.sut checkRegionExit];
    
    NSString *proximityUUID0Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID0] lowercaseString];
    NSString *proximityUUID1Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID1] lowercaseString];
    NSString *proximityUUID2Prefix = [[NSString stripHyphensFromUUIDString:kSBUnitTestRegionUUID2] lowercaseString];
    
    sessions = [self.sut currentSessions];
    
    for (SBMSession *session in sessions.allValues)
    {
        if ([session.pid hasPrefix:proximityUUID0Prefix] ||
            [session.pid hasPrefix:proximityUUID1Prefix] ||
            [session.pid hasPrefix:proximityUUID2Prefix])
        { // it should not have session
            XCTAssert(NO, @"this session should be removed.");
            break;
        }
    }
}

@end
