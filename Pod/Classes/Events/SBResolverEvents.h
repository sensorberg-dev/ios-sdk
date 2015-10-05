//
//  SBResolverEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBResolverModels.h"

#import "SBEvent.h"

@interface SBEventReachabilityEvent : SBEvent
@property (nonatomic) BOOL reachable;
@end

@interface SBEventGetLayout : SBEvent
@property (strong, nonatomic) SBMGetLayout *layout;
@end

@interface SBEventPostLayout : SBEvent
@end

@interface SBEventPing : SBEvent
@property (nonatomic) double latency;
@end