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

#import "SBTestCase.h"
#import "SBHTTPRequestManager.h"
#import "SBEvent.h"

#import <tolo/Tolo.h>


@interface SBHTTPRequestManagerTests : SBTestCase
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

- (NSData *)postData
{
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:@{}
                                                   options:0
                                                     error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    // This will be the json string in the preferred format
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    // And this will be the json data object
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
}

- (void)test000UploadLayout
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response"];
    self.sut = [SBHTTPRequestManager new];
    NSURL *URL = [NSURL URLWithString:@"https://resolver.sensorberg.com/layout"];
    NSDictionary *httpHeader = @{@"X-Api-Key" : @"c36553abc7e22a18a4611885addd6fdf457cc69890ba4edc7650fe242aa42378",
                                 @"Content-Type" : @"application/json"};
    [self.sut postData:[self postData] URL:URL headerFields:httpHeader completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(data);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4 handler:nil];
    self.sut = nil;
}

- (void)test001UploadLayoutWithWrongURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response with Wrong URL"];
    self.sut = [SBHTTPRequestManager new];
    NSURL *URL = [NSURL URLWithString:@"https://Layout:D"];
    [self.sut postData:[self postData] URL:URL headerFields:@{} completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}

- (void)test002DownloadLayout
{
    self.sut = [SBHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response"];
    NSURL *URL = [NSURL URLWithString:@"https://resolver.sensorberg.com/layout"];
    NSDictionary *httpHeader = @{@"X-Api-Key" : @"c36553abc7e22a18a4611885addd6fdf457cc69890ba4edc7650fe242aa42378",
                                 @"Content-Type" : @"application/json"};
    [self.sut getDataFromURL:URL headerFields:httpHeader useCache:YES completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(data);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}

- (void)test003DownloadLayoutNoCache
{
    self.sut = [SBHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for connect server response without cache"];
    NSURL *URL = [NSURL URLWithString:@"https://resolver.sensorberg.com/layout"];
    NSDictionary *httpHeader = @{@"X-Api-Key" : @"c36553abc7e22a18a4611885addd6fdf457cc69890ba4edc7650fe242aa42378",
                                 @"Content-Type" : @"application/json"};
    [self.sut getDataFromURL:URL headerFields:httpHeader useCache:NO completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssert(data);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    self.sut = nil;
}

- (void)test004DownloadLayoutWrongURL
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
