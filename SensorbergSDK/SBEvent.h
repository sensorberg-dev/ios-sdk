//
//  SBEvents.h
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "SBModel.h"

#pragma mark - Application life-cycle events

@interface SBEvent : NSObject
@property (strong, nonatomic) NSError *error;
@end

#pragma mark - Protocol events

@interface SBEventPerformAction : SBEvent
@property (strong, nonatomic) SBCampaignAction *campaign;
@end

@interface SBEventResetManager : SBEvent
@end

@interface SBEventReportHistory : SBEvent
@end

#pragma mark - Location events

@interface SBEventLocationAuthorization : SBEvent
@property (nonatomic) SBLocationAuthorizationStatus locationAuthorization;
@end

@interface SBEventRangedBeacons : SBEvent
@property (strong, nonatomic) SBMBeacon *beacon;
@property (nonatomic) int rssi;
@property (nonatomic) CLProximity proximity;
@property (nonatomic) CLLocationAccuracy accuracy;
@end

@interface SBEventDeterminedState : SBEvent
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int state;
@end

@interface SBEventRegionEnter : SBEvent
@property (strong, nonatomic) SBMBeacon *beacon;
@property (strong, nonatomic) CLLocation *location;
@end

@interface SBEventRegionExit : SBEvent
@property (strong, nonatomic) SBMBeacon *beacon;
@property (strong, nonatomic) CLLocation *location;
@end



#pragma mark - Bluetooth events

@interface SBEventBluetoothAuthorization : NSObject
@property (nonatomic) SBBluetoothStatus bluetoothAuthorization;
@end