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

FOUNDATION_EXPORT NSString * const kSBSettingsUserDefaultKey;
FOUNDATION_EXPORT NSString * const kSBSettingsDictionaryRevisionKey;

@interface SBSettingsTests : SBTestCase
@property (nonatomic, strong) SBSettings *target;
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) SBSettingEvent *responseEvent;
@end

@implementation SBSettingsTests

- (void)setUp
{
    [super setUp];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSBSettingsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    sleep(0.5);
    self.expectation = nil;
    self.responseEvent = nil;
    self.target = [SBSettings new];
}

- (void)tearDown
{
    self.expectation = nil;
    self.responseEvent = nil;
    self.target = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSBSettingsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super tearDown];
}

SUBSCRIBE(SBSettingEvent) {
    self.responseEvent = event;
    [self.expectation fulfill];
    self.expectation = nil;
}

- (void)test001RequestSettingsWithAPIKey {
    REGISTER();
    self.expectation = [self expectationWithDescription:@"Wait for connect server response With Wrong Key"];
    
    [self.target requestSettingsWithAPIKey:@"Hey%20:D"];
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
    
    XCTAssert(self.responseEvent.error);
    self.expectation = nil;
    self.responseEvent = nil;
    
    self.expectation = [self expectationWithDescription:@"Wait for connect server response With Empty Key"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.target requestSettingsWithAPIKey:nil];
#pragma clang diagnostic pop
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssertNil(self.responseEvent.settings);
    XCTAssert(self.responseEvent.error);
    
    self.expectation = nil;
    self.responseEvent = nil;
    
    self.expectation = [self expectationWithDescription:@"Wait for connect server response With Right APIKey"];
    // Key from "Gunnih Onboarding" App.
    [self.target requestSettingsWithAPIKey:@"c36553abc7e22a18a4611885addd6fdf457cc69890ba4edc7650fe242aa42378"];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssert(self.responseEvent.settings);
    if (self.responseEvent.error.code != NSURLErrorCancelled)
    {
        XCTAssertNil(self.responseEvent.error);
    }
    else
    {
        // in case : got same setting.
        XCTAssert(self.responseEvent.error);
    }
    self.expectation = nil;
    UNREGISTER();
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