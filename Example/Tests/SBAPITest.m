//
//  SBAPITest.m
//  Sensorberg
//
//  Created by Andrei Stoleru on 11/08/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JSONServer.h"

@import Sensorberg;
@import tolo;
@import JSONModel;

@interface SBAPITest : XCTestCase <JSONServerResponseGenerator>
// JSON HTTP Server
@property (strong, nonatomic) JSONServer *server;
// SensorbergSDK Manager
@property (strong, nonatomic) SBManager *manager;
@end

#define kLocalURL       @"http://localhost/"
#define kRemoteURL      @"https://resolver.sensorberg.com"
#define kApiKey        @"248b403be4d9041aca3c01bcb886f876d8fc1768379993f7c7e3b19f41526a2a"


@implementation SBAPITest

- (void)setUp {
    [super setUp];
    REGISTER();
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.server = [[JSONServer alloc] initWithResponseGenerator:self];
    //
    NSString *host = [NSString stringWithFormat:@"http://localhost:%i/",self.server.port];
    self.manager = [SBManager sharedManager];
    [self.manager setupResolver:kRemoteURL apiKey:kApiKey];
}

- (void)tearDown {
    self.server = nil;
    //
    UNREGISTER();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testServer {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssert(self.server,@"Server is not running");
    //
    XCTAssert(self.manager, @"Sensorberg Manager is not initialized");
    //
    [self.manager.apiClient requestLayout];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - SBAPIEvents



#pragma mark - JSONServerResponseGenerator protocol

- (JSONResponse *)responseForJSONServer:(JSONServer *)server request:(JSONRequest *)request {
    JSONResponse *response = [[JSONResponse alloc] init];
    //
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSData *responseData;
    //
    if ([request.path containsString:@"layout"]) {
        responseData = [NSData dataWithContentsOfFile:[mainBundle pathForResource:@"layout" ofType:@"json" inDirectory:@"Responses"]];
    } else if ([request.path containsString:@"invalid"]) {
        responseData = [NSData dataWithContentsOfFile:[mainBundle pathForResource:@"invalid" ofType:@"json" inDirectory:@"Responses"]];
    } else if ([request.path containsString:@"ping"]) {
        responseData = [NSData dataWithContentsOfFile:[mainBundle pathForResource:@"ping" ofType:@"json" inDirectory:@"Responses"]];
    }
    //
    XCTAssertNotNil(responseData);
    //
    response.jsonObject = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    return response;
}

@end
