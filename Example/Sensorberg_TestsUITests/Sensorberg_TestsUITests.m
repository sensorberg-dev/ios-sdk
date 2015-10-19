//
//  Sensorberg_TestsUITests.m
//  Sensorberg_TestsUITests
//
//  Created by Andrei Stoleru on 19/10/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <BluetoothManager/BluetoothManager.h>

@interface Sensorberg_TestsUITests : XCTestCase {
    // the APP
    XCUIApplication *app;
    // bluetooth manager
    BluetoothManager    *btManager;
    // API keys for apps
    NSMutableArray      *appKeys;
}

@end

@implementation Sensorberg_TestsUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    
    // setup bluetooth interface
    btManager = [BluetoothManager sharedInstance];
    // setup bluetooth notification(s)
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothAvailabilityChanged:)
     name:@"BluetoothAvailabilityChangedNotification"
     object:nil];
    //
    [self performSelector:@selector(bluetoothON) withObject:nil afterDelay:1.0f];
    // the APP
    app = [[XCUIApplication alloc] init];
    NSLog(@"INITIALISED: %@",app);
}

#pragma mark - Internal methods

/* Bluetooth notifications */
- (void)bluetoothAvailabilityChanged:(NSNotification *)notification {
    NSLog(@"NOTIFICATION:bluetoothAvailabilityChanged called. BT State: %d", [btManager enabled]);
    //
    if ([btManager enabled]) {
        [app launch];
    }
}

#pragma mark - Bluetooth

/* Interface actions - bt on */
- (IBAction)bluetoothON {
    NSLog(@"bluetoothON called.");
    [btManager setPowered:YES];
    [btManager setEnabled:YES];
    
}

/* Interface actions - bt off */
- (IBAction)bluetoothOFF {
    NSLog(@"bluetoothOFF called.");
    //BluetoothManager *manager = [BluetoothManager sharedInstance];
    [btManager setEnabled:NO];
    [btManager setPowered:NO];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSLog(@"App launched");
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssert(btManager,@"Failed to load BluetoothManager");
}

@end
