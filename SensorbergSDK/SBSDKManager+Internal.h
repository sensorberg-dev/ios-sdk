//
//  SBSDKManager+Internal.h
//  SensorbergSDK
//
//   
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
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

#import "SBSDKManager.h"

#import <MSWeakTimer/MSWeakTimer.h>

@interface SBSDKManager ()

/**
 Timer used to detect beacon exit events.
 */
@property (nonatomic, strong) MSWeakTimer *beaconExitEventTimer;

///---------------------------------------------
/// @name Properties redefined to be read-write.
///---------------------------------------------

@property (nonatomic, assign) BOOL iBeaconSupported;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, strong) SBSDKNetworkManager *networkManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, assign) SBSDKManagerBluetoothStatus bluetoothStatus;
@property (nonatomic, assign) SBSDKManagerConnectionState connectionState;
@property (nonatomic, assign) SBSDKManagerReachabilityState reachabilityState;

///------------------------------------
/// @name Application delegate handling
///------------------------------------

/**
 Starts to monitor for beacons with a given region identifier.

 @param regionString Region string to monitor beacons
 */
- (void)startMonitoringBeaconsWithRegionString:(NSString *)regionString;

///-----------------------
/// @name Internal helpers
///-----------------------

/**
 Returns a CLBeaconRegion object constructed from a given region identifier.

 @param proximityUUID Region string to be used for the CLBeaconRegion object.

 @return CLBeaconRegion object constructed from a given region identifier.
 */
- (CLBeaconRegion *)beaconRegionFromProximityUUID:(NSString *)proximityUUID;

///------------
/// @name Timer
///------------

/**
 Method to activate the timer used to detect beacon exit events.
 */
- (void)activateBeaconExitEventTimer;

/**
 Method to deactivate and invalidate the timer used to detect beacon exit events.
 */
- (void)deactivateBeaconExitEventTimer;

@end
