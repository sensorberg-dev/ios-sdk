//
//  SBMBeaconTests.m
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
#import "SBModel.h"
#import "NSString+SBUUID.h"


@interface SBCLBeacon : NSObject
@property (nonatomic, strong) NSUUID *proximityUUID;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;
@property (nonatomic) CLProximity proximity;
@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic) NSInteger rssi;
@end

@implementation SBCLBeacon
@end

@interface SBMBeaconTests : SBTestCase
@property (nonatomic, strong) NSString *sutUUID;
@property (nonatomic, strong) NSString *sutFullUUID;
@end

@implementation SBMBeaconTests

- (void)setUp {
    [super setUp];
    self.sutUUID = @"7367672374000000ffff0000ffff0003";
    self.sutFullUUID = @"7367672374000000ffff0000ffff00030000200747";
    self.continueAfterFailure = NO;
}

- (void)tearDown {
    self.sutUUID = nil;
    self.sutFullUUID = nil;
    [super tearDown];
}

- (void)test000InitWithCLBeacon
{
    SBCLBeacon *beacon = [SBCLBeacon new];
    beacon.proximityUUID = [[NSUUID alloc ] initWithUUIDString:[NSString hyphenateUUIDString:self.sutUUID]];
    beacon.major = @(2);
    beacon.minor = @(747);
    beacon.proximity = CLProximityNear;
    beacon.accuracy = 2;
    beacon.rssi = -48;
    
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithCLBeacon:(CLBeacon *)beacon];
    XCTAssert([sbBeacon.UUID isEqual:beacon.proximityUUID]);
    XCTAssert(sbBeacon.major == beacon.major.integerValue);
    XCTAssert(sbBeacon.minor == beacon.minor.integerValue);
    XCTAssert([sbBeacon.fullUUID isEqualToString:self.sutFullUUID]);
}

- (void)test001InitWithStringShorterThan32
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:@"shorter than 32 chars"];
    XCTAssertNil(sbBeacon);
}

- (void)test002InitWithString32
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:self.sutUUID];
    XCTAssertNil(sbBeacon);
}

- (void)test003InitWithString37
{
    NSString *inputUUID = [NSString stringWithFormat:@"%@00002", self.sutUUID];
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:inputUUID];
    XCTAssertNil(sbBeacon);
}

- (void)test004InitWithString42
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    XCTAssert(sbBeacon.major == 2);
    XCTAssert(sbBeacon.minor == 747);
    XCTAssert([sbBeacon.fullUUID isEqualToString:self.sutFullUUID]);
}
- (void)test005InitWithStringLongerThan42
{
    NSString *inputUUID = [NSString stringWithFormat:@"%@AEFDBC", self.sutFullUUID];
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:inputUUID];
    XCTAssertNil(sbBeacon);
}

- (void)test006InitWithStringWithHyphenateUUIDString
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:[NSString hyphenateUUIDString:self.sutFullUUID]];
    XCTAssert(sbBeacon.major == 2);
    XCTAssert(sbBeacon.minor == 747);
    XCTAssert([sbBeacon.fullUUID isEqualToString:self.sutFullUUID]);
}

- (void)test007InitWithStringWithLongHyphenateUUIDString
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:[NSString stripHyphensFromUUIDString:self.sutUUID]];
    // it should be failed to initialize properties.
    XCTAssert(sbBeacon.major == 0);
    XCTAssert(sbBeacon.minor == 0);
}

- (void)test008IsEqualWithSameObject
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    XCTAssert([sbBeacon isEqual:sbBeacon]);
}

- (void)test009IsEqualWithDifferentObjectAndSameUUID
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    SBMBeacon *targetBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    XCTAssert([sbBeacon isEqual:targetBeacon]);
}

- (void)test010IsEqualWithDifferentUUIDs
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    SBMBeacon *targetBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    XCTAssert([sbBeacon isEqual:targetBeacon]);
}

- (void)test011IsEqualWithDifferentTypeOfObject
{
    SBMBeacon *sbBeacon = [[SBMBeacon alloc] initWithString:self.sutFullUUID];
    XCTAssertFalse([sbBeacon isEqual:@"NSString"]);
    XCTAssertFalse([sbBeacon isEqual:@(9999)]);
}

@end
