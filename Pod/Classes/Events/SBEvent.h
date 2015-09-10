//
//  SBEvent.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import <Foundation/Foundation.h>

#import "SBResolverModels.h"

@interface SBEvent : NSObject
@property (strong, nonatomic) NSError *error;
@end

@interface SBEventApplicationLaunched : SBEvent
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@interface SBEventApplicationActive : SBEvent
@end

@interface SBEventApplicationForeground : SBEvent
@end

@interface SBEventPerformAction : SBEvent
@property (strong, nonatomic) SBMAction* action;
@end