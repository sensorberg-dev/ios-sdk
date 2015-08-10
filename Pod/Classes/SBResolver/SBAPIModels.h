//
//  SBAPIModels.h
//  Pods
//
//  Created by Andrei Stoleru on 10/08/15.
//
//

#import <Foundation/Foundation.h>

@import JSONModel;

#import "SBUtility.h"

@interface JSONValueTransformer (SBValueFormatter)
@end

@interface SBMUUID : JSONModel
@property (strong, nonatomic) NSString *proximityUUID;
@end

@interface SBMBeacon : JSONModel
@property (strong, nonatomic) NSString *fullUUID;
@end

@interface SBMContent : JSONModel
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *payload;
@property (strong, nonatomic) NSString *url;
@end

@interface SBMTimeframes : JSONModel
@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *end;
@end

@interface SBMAction : JSONModel
@property (strong, nonatomic) NSString *eid;
@property (nonatomic) int trigger;
@property (strong, nonatomic) NSArray <SBMBeacon *> *beacons;
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
@property (strong, nonatomic) NSArray <SBMUUID*> *accountProximityUUIDs; //only trigger a layout call for these UUIDs
@property (nonatomic) int reportTrigger; //in seconds, flush the history every x seconds
@property (strong, nonatomic) NSArray <SBMAction*> *actions;
@property (nonatomic) BOOL *currentVersion;
@property (strong, nonatomic) NSArray <SBMAction*> *instantActions;
@end

@interface SBAPIModels : NSObject

@end
