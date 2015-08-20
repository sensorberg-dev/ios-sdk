//
//  SBLocation+Events.h
//  Pods
//
//  Created by Andrei Stoleru on 20/08/15.
//
//

#import <Sensorberg/SensorbergSDK.h>

@interface SBELocationAuthorization : NSObject
@property (nonatomic) SBLocationAuthorizationStatus locationAuthorization;
@end

@interface SBERangedBeacons : NSObject
@property (strong, nonatomic) NSArray *beacons;
@property (strong, nonatomic) CLBeaconRegion *region;
@end

@interface SBLocation (Events)

@end
