//
//  SBMSession.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import <JSONModel/JSONModel.h>

#import "JSONValueTransformer+SBResolver.h"

@protocol SBMMonitorEvent @end

@interface SBMMonitorEvent : JSONModel
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSDate *dt;
@property (nonatomic) int trigger;
@end

@protocol SBMSession @end

@interface SBMSession : JSONModel

- (instancetype)initWithUUID:(NSString*)UUID;

@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *enter;
@property (strong, nonatomic) NSDate *exit;
@property (strong, nonatomic) NSDate *lastSeen;

@end
