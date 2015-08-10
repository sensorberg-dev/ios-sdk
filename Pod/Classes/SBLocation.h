//
//  SBLocation.h
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 28/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface SBLocation : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *manager;
    //
    NSArray *monitoredRegions;
    //
    NSArray *defaultBeacons;
    //
    float prox;
}

@end
