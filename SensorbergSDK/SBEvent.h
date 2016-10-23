//
//  SBEvent.h
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

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "SBModel.h"

#pragma mark - Application life-cycle events

@protocol SBEvent @end
@interface SBEvent : NSObject
@property (strong, nonatomic) NSError *error;
@end

@interface SBEventPerformAction : SBEvent
@property (strong, nonatomic) SBMCampaignAction *campaign;

- (NSDictionary *)toDictionary;

@end

@protocol SBEventResetManager @end
@interface SBEventResetManager : SBEvent
@end

@protocol SBEventReportHistory @end
@interface SBEventReportHistory : SBEvent
@property (nonatomic) BOOL forced;
@end

@interface SBEventReportConversion : SBEvent
@property (strong, nonatomic) NSString *action;
@property (nonatomic) SBConversionType conversionType;
@property (strong, nonatomic) CLLocation *gps;
@end

@protocol SBEventUpdateHeaders @end
@interface SBEventUpdateHeaders : SBEvent
@end

@protocol SBEventStatusUpdate @end
@interface SBEventStatusUpdate : SBEvent
@end

#pragma mark - Location events

@interface SBEventRangedBeacon : SBEvent
@property (strong, nonatomic) SBMBeacon *beacon;
@property (nonatomic) int rssi;
@property (nonatomic) CLProximity proximity;
@property (nonatomic) CLLocationAccuracy accuracy;
@end

@interface SBEventRegionEnter : SBEventRangedBeacon
@property (strong, nonatomic) CLLocation *location;
@end

@interface SBEventRegionExit : SBEventRangedBeacon
@property (strong, nonatomic) CLLocation *location;
@end

#pragma mark - Authorization events

@interface SBEventLocationAuthorization : SBEvent
@property (nonatomic) SBLocationAuthorizationStatus locationAuthorization;
@end

@interface SBEventBluetoothAuthorization : SBEvent
@property (nonatomic) SBBluetoothStatus bluetoothAuthorization;
@end

@interface SBEventNotificationsAuthorization : SBEvent
@property (nonatomic) BOOL notificationsAuthorization;
@end

#pragma mark - CoreBluetooth events


/**
    Event fired when a software-emulated iBeacon is started
 */
@interface SBEventBluetoothEmulation : SBEvent
@end

/**
    Event fired when a new CBPeripheral has been discovered
 */
@interface SBEventDeviceDiscovered : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@end

/**
    Event fired when information about a previously discovered CBPeripheral is updated
 */
@interface SBEventDeviceUpdated : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@end

/**
    Event fired when a CBPeripheral has disconnected
 */
@interface SBEventDeviceDisconnected : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@end

/**
    Event fired when a connection is made to a CBPeripheral
 */
@interface SBEventDeviceConnected : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@end

/**
    Event fired when the list of services of a CBPeripheral has been updated
 */
@interface SBEventServicesUpdated : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@end

/**
    Event fired when a CBCharacteristic of a CBPeripheral has been updated
 */
@interface SBEventCharacteristicsUpdate : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *characteristic;
@end

/**
    Event fired when a value has been written to a CBCharacteristic
 */
@interface SBEventCharacteristicWrite : SBEvent
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *characteristic;
@end

#pragma mark - Application lifecycle events

@interface SBEventApplicationLaunched : SBEvent
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@interface SBEventApplicationActive : SBEvent
@end

@interface SBEventApplicationForeground : SBEvent
@end

@interface SBEventApplicationWillResignActive : SBEvent
@end

@interface SBEventApplicationWillTerminate : SBEvent
@end

@interface SBEventApplicationWillEnterForeground : SBEvent
@end

#pragma mark - Resolver events

/**
    Event fired when the general internet reachability of the SBManager changes 
 */
@interface SBEventReachabilityEvent : SBEvent
@property (nonatomic) BOOL reachable;
@end
