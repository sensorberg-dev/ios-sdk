//
//  SBLocationEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBEvent.h"

#import "SBMBeacon.h"

#import "SBLocation.h"

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
