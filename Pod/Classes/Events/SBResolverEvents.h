//
//  SBResolverEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBResolverModels.h"

@interface SBEReachabilityEvent : NSObject
@property (nonatomic) BOOL reachable;
@end

@interface SBELayout : NSObject
@property (strong, nonatomic) SBMGetLayout *layout;
@property (strong, nonatomic) NSError *error;
@end

