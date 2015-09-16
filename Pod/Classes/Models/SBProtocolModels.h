//
//  SBProtocolModels.h
//  Pods
//
//  Created by Andrei Stoleru on 15/09/15.
//
//

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

#import "SBResolverModels.h"

@interface SBCampaignAction : JSONModel

@property (strong, nonatomic) NSDate *fireDate;

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDictionary <Optional> *payload;
@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) NSString *eid;

@property (nonatomic) SBTriggerType trigger;
@property (nonatomic) SBActionType type;

@property (strong, nonatomic) SBMBeacon *beacon;
@end
