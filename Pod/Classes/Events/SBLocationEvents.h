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

@interface SBELocationAuthorization : SBEvent
@property (nonatomic) SBLocationAuthorizationStatus locationAuthorization;
@end

@interface SBERangedBeacons : SBEvent
@property (strong, nonatomic) SBMBeacon *beacon;
@property (nonatomic) int rssi;
@property (nonatomic) CLProximity proximity;
@property (nonatomic) CLLocationAccuracy accuracy;
@end

@interface SBEDeterminedState : SBEvent
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int state;
@end

@interface SBERegionEnter : SBEvent
@property (strong, nonatomic) NSString *fullUUID;
@end

@interface SBERegionExit : SBEvent
@property (strong, nonatomic) NSString *fullUUID;
@end
