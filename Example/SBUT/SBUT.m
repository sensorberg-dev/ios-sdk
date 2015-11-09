//
//  SBUT.m
//  SBUT
//
//  Created by Andrei Stoleru on 02/11/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <XCTest/XCTest.h>


#import <Sensorberg/SBManager.h>

#import <Sensorberg/SBResolverEvents.h>

@interface SBUT : XCTestCase {
    SBManager *manager;
    //
    XCTestExpectation *cacheExpectation;
}

@end

@implementation SBUT

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    manager = [SBManager sharedManager];
    //
    [manager setupResolver:nil apiKey:nil delegate:self];
    //
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    //
    manager = nil;
    //
}

- (void)testCache {
    cacheExpectation = [self expectationWithDescription:@"Cache expectation"];
    //
    [manager requestLayout];
    //
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError * _Nullable error) {
        //
    }];
}

SUBSCRIBE(SBEventGetLayout) {
    if (isNull(event.error)) {
        [cacheExpectation fulfill];
    }
}

@end
