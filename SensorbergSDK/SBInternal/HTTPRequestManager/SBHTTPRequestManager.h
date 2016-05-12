//
//  SBHTTPRequestManager.h
//  WhiteLabel
//
//  Created by ParkSanggeon on 27/04/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SBNetworkReachability) {
    SBNetworkReachabilityUnknown    = -1,
    SBNetworkReachabilityNone       = 0,
    SBNetworkReachabilityViaWWAN    = 1,
    SBNetworkReachabilityViaWiFi    = 2,
};

@interface SBHTTPRequestManager : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue * _Nonnull operationQueue;

// Please Subscribe @SBNetworkReachabilityChangedEvent
@property (readonly, nonatomic, assign) SBNetworkReachability reachabilityStatus;
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

+ (instancetype _Nonnull)sharedManager;

- (void)getDataFromURL:(nonnull NSURL *)URL
          headerFields:(nullable NSDictionary *)header
              useCache:(BOOL)useCache
            completion:(nonnull void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

- (void)postData:(nullable NSData *)data
             URL:(nonnull NSURL *)URL
    headerFields:(nonnull NSDictionary *)header
      completion:(nonnull void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;

@end
