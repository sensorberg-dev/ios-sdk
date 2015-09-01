//
//  SBAnalytics+Models.h
//  Pods
//
//  Created by Andrei Stoleru on 01/09/15.
//
//

#import "SBAnalytics.h"

#import <JSONModel/JSONModel.h>

@interface SBMEvent : JSONModel
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *eventDate;
@property (nonatomic) int trigger;
@end

@interface SBAnalytics (Models)

@end
