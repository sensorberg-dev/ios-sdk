//
//  SBResolver.h
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@import tolo;
@import JSONModel;

@import AFNetworking;

@interface SBReachabilityEvent : NSObject
@property (nonatomic) BOOL reachable;
@end

#import "SBUtility.h"

@interface SBResolver : NSObject

- (void)updateLayout;

- (void)ping;

- (void)getLayout;

@end
