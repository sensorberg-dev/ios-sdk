//
//  SBInternalEvents.h
//  SensorbergSDK
//
//  Created by andsto on 30/11/15.
//  Copyright © 2015 Sensorberg GmbH. All rights reserved.
//

#import "SBInternalModels.h"

#import "SBEvent.h"

@interface SBInternalEvents : SBEvent
@end

#pragma mark - Application lifecycle events

@interface SBEventApplicationLaunched : SBEvent
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@interface SBEventApplicationActive : SBEvent
@end

@interface SBEventApplicationForeground : SBEvent
@end

@interface SBEventApplicationWillResignActive : SBEvent
@end

@interface SBEventApplicationWillTerminate : SBEvent
@end

@interface SBEventApplicationWillEnterForeground : SBEvent
@end

#pragma mark - Resolver events

@interface SBEventReachabilityEvent : SBEvent
@property (nonatomic) BOOL reachable;
@end

@interface SBEventGetLayout : SBEvent
@property (strong, nonatomic) SBMGetLayout  *layout;
@property (strong, nonatomic) SBMBeacon     *beacon;
@property (nonatomic) SBTriggerType         trigger;
@end

@interface SBEventPostLayout : SBEvent
@end

@interface SBEventPing : SBEvent
@property (nonatomic) double latency;
@end