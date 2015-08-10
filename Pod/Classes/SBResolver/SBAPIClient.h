//
//  SBAPIClient.h
//  Pods
//
//  Created by Andrei Stoleru on 06/08/15.
//
//

#import <Foundation/Foundation.h>

@import JSONModel;

@import tolo;

#import "SBAPIModels.h"

@interface SBELayout : NSObject
@property (strong, nonatomic) SBMLayout *layout;
@property (strong, nonatomic) NSError *error;
@end

@interface SBAPIClient : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithBaseURL:(NSString*)baseURL andAPI:(NSString*)apiKey
#if NS_ENFORCE_NSOBJECT_DESIGNATED_INITIALIZER
NS_DESIGNATED_INITIALIZER
#endif
;

- (void)getLayout;

@end
