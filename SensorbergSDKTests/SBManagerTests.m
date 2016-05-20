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

FOUNDATION_EXPORT NSString *kPostLayout;
FOUNDATION_EXPORT NSString *kSBAppActive;
FOUNDATION_EXPORT NSString *SBAPIKey;
FOUNDATION_EXPORT NSString *SBResolverURL;
FOUNDATION_EXPORT NSString * const kSBSettingsDefaultResolverURL;

@interface SBManager (XCTests)
- (void)setResolver:(NSString*)resolver apiKey:(NSString*)apiKey delegate:(id)delegate;
@end

@interface SBManagerTests : XCTestCase
@property (nullable, nonatomic, strong) SBManager *sut;
@property (nullable, nonatomic, strong) NSString *defaultAPIKey;
@end

@implementation SBManagerTests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
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
    [self.sut resetSharedClient];
    self.sut = nil;
    self.defaultAPIKey = nil;
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

- (void)testSetResolverApiKeyDelegateWithCustomResolver
{
    NSString *customResolver = @"ThisIsCustomResolver.";
    [self.sut setResolver:customResolver apiKey:self.defaultAPIKey delegate:nil];
    XCTAssert([SBAPIKey isEqualToString:self.defaultAPIKey]);
    XCTAssert([SBResolverURL isEqualToString:customResolver]);
}

- (void)testSetResolverApiKeyDelegateWithCustomResolverInBackgroundThread
{
    
    NSString *customResolver = @"ThisIsCustomResolver.";
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      [self.sut setResolver:customResolver apiKey:self.defaultAPIKey delegate:nil];
    });
    
    XCTAssert([SBAPIKey isEqualToString:self.defaultAPIKey]);
    XCTAssert([SBResolverURL isEqualToString:customResolver]);
}

@end
