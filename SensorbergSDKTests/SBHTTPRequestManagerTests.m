//
//  SBHTTPRequestManagerTests.m
//  SensorbergSDK
//
//  Created by Sanggeon Park on 23/05/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SBHTTPRequestManager.h"
#import "SBEvent.h"

#import <tolo/Tolo.h>


@interface SBHTTPRequestManagerTests : XCTestCase
@property (nonatomic, strong) SBHTTPRequestManager *sut;
@end

@implementation SBHTTPRequestManagerTests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    self.sut = nil;
    [super tearDown];
}


- (void)testUploadLayout
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response"];
    self.sut = [SBHTTPRequestManager new];
    NSURL *URL = [NSURL URLWithString:@"https://resolver.sensorberg.com/layout"];
    [self.sut postData:nil URL:URL headerFields:@{} completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(data);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
    self.sut = nil;
}

- (void)testUploadLayoutWithWrongURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response"];
    self.sut = [SBHTTPRequestManager new];
    NSURL *URL = [NSURL URLWithString:@"https://Layout:D"];
    [self.sut postData:nil URL:URL headerFields:@{} completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssert(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}

- (void)testDownloadLayout
{
    self.sut = [SBHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response"];
    NSURL *URL = [NSURL URLWithString:@"https://resolver.sensorberg.com/layout"];
    [self.sut getDataFromURL:URL headerFields:nil useCache:YES completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(data);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}

- (void)testDownloadLayoutNoCache
{
    self.sut = [SBHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response"];
    NSURL *URL = [NSURL URLWithString:@"https://resolver.sensorberg.com/layout"];
    [self.sut getDataFromURL:URL headerFields:nil useCache:NO completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(data);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}

- (void)testDownloadLayoutWorngURL
{
    self.sut = [SBHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response With Wrong URL"];
    NSURL *URL = [NSURL URLWithString:@"https://Layout:D"];
    [self.sut getDataFromURL:URL headerFields:nil useCache:YES completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssert(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}


@end
