//
//  SBAnalytics+Events.h
//  Pods
//
//  Created by Andrei Stoleru on 01/09/15.
//
//

#import "SBAnalytics.h"

#import <JSONModel/JSONModel.h>

@protocol SBEMonitorEvent @end

@interface SBEMonitorEvent : JSONModel
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSDate *dt;
@property (nonatomic) int trigger;

@end

@interface SBAnalytics (Events)

@end
