//
//  SBResolverEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBResolverModels.h"

@interface SBEventReachabilityEvent : NSObject
@property (nonatomic) BOOL reachable;
@end

@interface SBEventGetLayout : NSObject
@property (strong, nonatomic) SBMGetLayout *layout;
@property (strong, nonatomic) NSError *error;
@end

@interface SBEventPostLayout : NSObject
@property (strong, nonatomic) NSError *error;
@end