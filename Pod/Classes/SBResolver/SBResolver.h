//
//  SBResolver.h
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//
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

- (void)getLayout;

@end
