//
//  SBMSession.m
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBMSession.h"

#import "SBUtility.h"

emptyImplementation(SBMMonitorEvent)

@implementation SBMSession

- (instancetype)initWithUUID:(NSString*)UUID
{
    self = [super init];
    if (self) {
        _pid = UUID;
        _enter = now;
        _lastSeen = now;
    }
    return self;
}

@end
