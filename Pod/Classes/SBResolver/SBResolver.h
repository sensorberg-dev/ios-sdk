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

#import "SBUtility.h"

@interface SBResolver : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithBaseURL:(NSString*)baseURL andAPI:(NSString*)apiKey
#if NS_ENFORCE_NSOBJECT_DESIGNATED_INITIALIZER
NS_DESIGNATED_INITIALIZER
#endif
;

- (void)getLayout;

@end
