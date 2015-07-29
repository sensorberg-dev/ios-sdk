//
//  SBSDKNetworkManager.m
//  SensorbergSDK
//
//  Created by Max Horvath.
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SBSDKNetworkManager.h"
#import "SBSDKMacros.h"
#import "NSError+Networking.h"
#import "NSUUID+NSString.h"
#import "SBSDKBeacon.h"
#import "SBSDKBeaconAction.h"
#import "SBSDKLayoutResponseObject.h"
#import "SBSDKDeviceID.h"
#import "SBSDKPersistManager.h"

@import MSWeakTimer;
@import AFNetworking;

#pragma mark -

// Error domain used in network manager of Sensorberg SDK
NSString *const SBSDKNetworkManagerErrorDomain = @"com.sensorberg.sdk.ios.error.networkmanager";

// Query string used to resolve a beacon event.
NSString *const SBSDKResolveBeaconEventQueryString = @"beacon/resolve?proximityId=%@&major=%@&minor=%@&deviceId=%@&event=%@&eventTime=%.0f";

// Query string used to retrieve the layout of beacons for a given  API key.
NSString *const SBSDKLayoutQueryString = @"layout";

// Default number of times a network call should be retried.
NSUInteger const SBSDKDefaultRetryCount = 3;

// Time interval after which the active regions used to monitor for beacons should be updated.
NSTimeInterval const SBSDKLayoutUpdateTimeInterval = 60.0; // 1 hour

NSTimeInterval const SBSDKLayoutUpdateFailedRetryTimeInterval = 60.0;  //

NSString* const SBSDKLayoutResponseRegionsKey = @"accountProximityUUIDs";

#define SBSDKLayoutRequestEtagKey @"If-None-Match"

#define SBSDKLayoutResponseNothingChanged 304

//#define SBSDKSyncHistroyIDKey @"historyDumpID"

#pragma mark -

@interface SBSDKNetworkManager ()

// Device related object.
@property (nonatomic, strong) SBSDKDeviceID *deviceID;

// Timer used to update the active regions to monitor.
@property (nonatomic, strong) MSWeakTimer *updateLayoutTimer;

// Flag to suppress double calling of layout update.
@property (nonatomic) BOOL layoutUpdateIsRuning;

// Current Etag Value for Layout Requests.
@property (nonatomic) NSUInteger retryCount;

// Current Etag Value for Layout Requests.
@property (nonatomic) NSTimeInterval lastFireTimeStamp;

//
// Properties redefined to be read-write.
//

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSDictionary *beaconLayout;
@property (nonatomic, strong) AFHTTPSessionManager *manager;

// Method that will be called if the UIApplicationDidBecomeActiveNotification is being called.
//
// @param Notification object calling the observer.
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification;

// Method that will be called if the UIApplicationDidBecomeActiveNotification is being called.
//
// @param Notification object calling the observer.
- (void)applicationWillResignActiveNotification:(NSNotification *)notification;

// Method to activate the timer used to update the beacon regions to be monitored.
- (void)activateUpdateLayoutTimer;

// Method to deactivate and invalidate the timer used to update the beacon regions to be monitored.
- (void)deactivateUpdateLayoutTimer;

@end

#pragma mark -

@implementation SBSDKNetworkManager

@synthesize deviceID = _deviceID;
@synthesize updateLayoutTimer = _updateLayoutTimer;
@synthesize baseURL = _baseURL;
@synthesize beaconLayout = _beaconLayout;

#pragma mark - Lifecycle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    NON_DESIGNATED_INIT(@"-initWithBaseUrl:apiKey:");
}

- (instancetype)initWithApiKey:(NSString *)apiKey {
    NON_DESIGNATED_INIT(@"-initWithBaseUrl:apiKey:delegate:");
}

- (instancetype)initWithBaseUrl:(NSURL *)baseURL apiKey:(NSString *)apiKey delegate:(id<SBSDKNetworkManagerDelegate>)delegate {
    if ((self = [super init])) {
        _baseURL = baseURL;
        _apiKey = [apiKey copy];
        
        _delegate = delegate;

        _deviceID = [[SBSDKDeviceID alloc] init];

        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];

        _manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        _manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        
        NSMutableIndexSet* anhancedAcceptableStatusCodes =  [[NSMutableIndexSet alloc] initWithIndexSet:_manager.responseSerializer.acceptableStatusCodes];
        
        [anhancedAcceptableStatusCodes addIndex:304];
        
        _manager.responseSerializer.acceptableStatusCodes = anhancedAcceptableStatusCodes;
        
        [_manager.requestSerializer setValue:_apiKey forHTTPHeaderField:@"X-Api-Key"];
        [_manager.requestSerializer setValue:_deviceID.UUIDString forHTTPHeaderField:@"X-iid"];
        [_manager.requestSerializer setValue:_deviceID.userAgent forHTTPHeaderField:@"User-Agent"];

        NSOperationQueue *networkOperationQueue = _manager.operationQueue;

        __block __typeof(self) __weak weakSelf = self;

        [_manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    networkOperationQueue.suspended = NO;
                    break;

                case AFNetworkReachabilityStatusNotReachable:
                default:
                    networkOperationQueue.suspended = YES;
                    break;
            }

            if (weakSelf.delegate != nil && [weakSelf.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [weakSelf.delegate respondsToSelector:@selector(networkManager:sensorbergPlatformIsReachable:)]) {
                [weakSelf.delegate networkManager:weakSelf sensorbergPlatformIsReachable:!networkOperationQueue.isSuspended];
            }
        }];

        [_manager.reachabilityManager startMonitoring];

        [self activateUpdateLayoutTimer];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    
    self.retryCount = 3;
    
    // load persist beaconlayout first
    
    self.beaconLayout = [SBSDKPersistManager sharedInstance].persistLayout;
    
    if (self.beaconLayout != Nil) {
        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:didUpdateRegions:)]) {
            [self.delegate networkManager:self didUpdateRegions:self.beaconLayout[SBSDKLayoutResponseRegionsKey]];
        }
    }
    
    return self;
}


- (void)dealloc {
    
    [self deactivateUpdateLayoutTimer];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma clang diagnostic pop

#pragma mark - Application lifecycle handling

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    
    if ([NSDate timeIntervalSinceReferenceDate] - self.lastFireTimeStamp > SBSDKLayoutUpdateFailedRetryTimeInterval) {
        // suppress double calling on application activation
        [self activateUpdateLayoutTimer];
    }
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    [self deactivateUpdateLayoutTimer];
}

- (void)syncWithBackEnd {
    
    self.lastFireTimeStamp = [NSDate timeIntervalSinceReferenceDate];
    
    NSMutableDictionary* history = [[SBSDKPersistManager sharedInstance] historyToSync];

    NSString* syncIdentifier = [history objectForKey:SBSDKSyncHistroyIDKey];
    
    // remove identifier to not confuse BE
    [history removeObjectForKey:SBSDKSyncHistroyIDKey];
    
    __weak __typeof__(self) weakSelf = self;
    
    [self.manager POST:SBSDKLayoutQueryString
           parameters:history
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  
                  __typeof__(self) strongSelf = weakSelf;
                  
                  SBSDKLayoutResponseObject *layoutResponseObject = [[SBSDKLayoutResponseObject alloc] initWithTask:task responseObject:responseObject];
                  
                  if (layoutResponseObject.statusCode != SBSDKLayoutResponseNothingChanged) {
                      
                      if (layoutResponseObject.Etag != Nil) {
                          [_manager.requestSerializer setValue:layoutResponseObject.Etag forHTTPHeaderField:SBSDKLayoutRequestEtagKey];
                      } else {
                          [_manager.requestSerializer setValue:Nil forHTTPHeaderField:SBSDKLayoutRequestEtagKey];
                      }
                      
                      if (layoutResponseObject.success) {
                          
                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                              
                              strongSelf.beaconLayout = [NSDictionary dictionaryWithDictionary:responseObject];
                              
                              [[SBSDKPersistManager sharedInstance] setPersistLayout:[NSDictionary dictionaryWithDictionary:strongSelf.beaconLayout] withMaxAgeInterval:layoutResponseObject.maxAge];
                              
                              if (strongSelf.delegate != nil && [strongSelf.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [strongSelf.delegate respondsToSelector:@selector(networkManager:didUpdateRegions:)]) {
                                  [strongSelf.delegate networkManager:strongSelf didUpdateRegions:layoutResponseObject.accountProximityUUIDs];
                              }
                              
                              strongSelf.retryCount = 3;
                          }
                      } else {
                          
                          if (strongSelf.retryCount == 0) {
                              if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:updateRegionsDidFailWithError:)]) {
                                  
                                  NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"The Sensorberg Resolver did not provide an correct beacon layout.", @"SensorbergSDK", nil) };
                                  
                                  NSError *error = [[NSError alloc] initWithDomain:SBSDKNetworkManagerErrorDomain
                                                                              code:SBSDKNetworkManagerErrorUpdateRegionsFailed
                                                                          userInfo:userInfo];
                                  
                                  [self.delegate networkManager:self updateRegionsDidFailWithError:error];
                                  
                                  strongSelf.retryCount = 10;
                              }
                          }
                          
                          // failed response parsing fire in
                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SBSDKLayoutUpdateFailedRetryTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              strongSelf.retryCount--;
                              [strongSelf.updateLayoutTimer fire];
                          });
                      }
                  }
                  
                  [[SBSDKPersistManager sharedInstance] historySyncSuccessWithIdentifier:syncIdentifier];
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  
                  if (weakSelf.retryCount == 0) {
                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:updateRegionsDidFailWithError:)]) {
                          
                          [self.delegate networkManager:self updateRegionsDidFailWithError:error];
                          
                          weakSelf.retryCount = 10;
                      }
                  }
                  
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SBSDKLayoutUpdateFailedRetryTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      weakSelf.retryCount--;
                      [weakSelf.updateLayoutTimer fire];
                  });
                  
              }];
}

#pragma mark - Timer

- (void)activateUpdateLayoutTimer {
    if (self.updateLayoutTimer == nil) {
        self.updateLayoutTimer = [MSWeakTimer scheduledTimerWithTimeInterval:SBSDKLayoutUpdateTimeInterval
                                                                       target:self
                                                                     selector:@selector(syncWithBackEnd)
                                                                     userInfo:nil
                                                                      repeats:YES
                                                                dispatchQueue:dispatch_get_main_queue()];

        self.updateLayoutTimer.tolerance = 60.0;
    }

    [self.updateLayoutTimer fire];
}

- (void)deactivateUpdateLayoutTimer {
    if (self.updateLayoutTimer != nil) {
        [self.updateLayoutTimer invalidate];

        self.updateLayoutTimer = nil;
    };
}

@end
