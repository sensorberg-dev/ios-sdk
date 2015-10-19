//
//  SBTesting.m
//  SBTesting
//
//  Created by Andrei Stoleru on 19/10/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <BluetoothManager/BluetoothManager.h>

@interface SBTesting : XCTestCase {
    //
    BluetoothManager *blManager;
    //
}

@end

@implementation SBTesting

- (void)setUp {
    [super setUp];
    //
    blManager = [BluetoothManager sharedInstance];
    //
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    //
    [blManager setPowered:YES];
    [blManager setEnabled:YES];
    //
    NSLog(@"running");
    //
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
