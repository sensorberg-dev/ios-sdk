//
//  SBResolver+Models.h
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBResolver.h"

@interface SBMBeacon : JSONModel
@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;
@end

@interface SBMContent : JSONModel
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDictionary <Optional> *payload;
@property (strong, nonatomic) NSString *url;
@end

@interface SBMTimeframes : JSONModel
@property (strong, nonatomic) NSDate <Optional> *start;
@property (strong, nonatomic) NSDate <Optional> *end;
@end

@interface SBMAction : JSONModel
@property (strong, nonatomic) NSString *eid;
@property (nonatomic) int trigger;
@property (strong, nonatomic) NSArray <SBMBeacon*> *beacons;
@property (nonatomic) int supressionTime;
@property (nonatomic) int suppressionTime;
@property (nonatomic) int delay; //
@property (nonatomic) BOOL reportImmediately; // when true flush the history immediately
@property (nonatomic) BOOL sendOnlyOnce; //
@property (strong, nonatomic) NSDate *deliverAt;
@property (strong, nonatomic) SBMContent *content;
@property (nonatomic) int type;
@property (strong, nonatomic) NSArray <SBMTimeframes*> *timeframes;
@property (strong, nonatomic) NSString *typeString;
@end

@interface SBMLayout : JSONModel
@property (strong, nonatomic) NSArray *accountProximityUUIDs;
@property (nonatomic) int reportTrigger;
@property (strong, nonatomic) NSArray <SBMAction*> *actions;
@property (nonatomic) BOOL currentVersion;
@property (strong, nonatomic) NSArray <SBMAction*> *instantActions;
@end

@interface SBResolver (Models)

@end
