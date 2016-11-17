//
//  SBSettingsTests.m
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

#import "SensorbergSDK.h"
#import "SBSettings.h"
#import "SBHTTPRequestManager.h"


@interface SBSettingsTests : SBTestCase
@property (nonatomic, strong) SBSettings *target;
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) SBSettingEvent *responseEvent;
@end

@implementation SBSettingsTests

- (void)setUp
{
    [super setUp];
    self.expectation = nil;
    self.responseEvent = nil;
    self.target = [SBSettings new];
}

- (void)tearDown
{
    self.expectation = nil;
    self.responseEvent = nil;
    self.target = nil;
    [super tearDown];
}

SUBSCRIBE(SBSettingEvent) {
    self.responseEvent = event;
    [self.expectation fulfill];
    self.expectation = nil;
}

- (void)test002SettingsWithCachedDictionary
{
    SBMSettings *newSettings = self.target.settings;
    
    SBSettings *newTarget = [SBSettings new];
    XCTAssert([[newSettings toDictionary] isEqualToDictionary:[[newTarget settings] toDictionary]]);
}

- (void)test003SharedInstance {
    SBSettings *testTarget = [SBSettings sharedManager];
    XCTAssert(testTarget);
}

- (void)test04DefaultBeaconRegions {
    SBSettings *testTarget = [SBSettings sharedManager];
    
    XCTAssert([testTarget.settings.defaultBeaconRegions isEqualToDictionary:[SensorbergSDK defaultBeaconRegions]]);
}

@end
