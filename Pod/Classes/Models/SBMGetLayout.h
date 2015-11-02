//
//  SBMGetLayout.h
//  Pods
//
//  Created by Andrei Stoleru on 26/10/15.
//
//

#import "SBModel.h"

#import "SBResolverModels.h"

#import "SBUtility.h"

@protocol SBMGetLayout @end

@interface SBMGetLayout : SBModel

@property (strong, nonatomic) NSArray <NSString*> *accountProximityUUIDs;
@property (nonatomic) int reportTrigger;
@property (strong, nonatomic) NSArray <SBMAction> *actions;
@property (nonatomic) BOOL currentVersion;
@property (strong, nonatomic) NSArray <SBMContent> *instantActions;

- (void)checkCampaignsForBeacon:(SBMBeacon *)beacon trigger:(SBTriggerType)trigger;

@end
