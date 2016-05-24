//
//  SBHTTPRequestManagerTests.m
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
