//
//  SBSDKNetworkManager.m
//  SensorbergSDK
//
//   
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

#import "AFHTTPSessionManager.h"
#import "NSError+Networking.h"
#import "NSUUID+NSString.h"
#import "SBSDKBeacon.h"
#import "SBSDKBeaconEventResponseObject.h"
#import "SBSDKDeviceID.h"
#import "SBSDKRegionsResponseObject.h"
#import "MSWeakTimer.h"

#pragma mark -

// Error domain used in network manager of Sensorberg SDK
NSString *const SBSDKNetworkManagerErrorDomain = @"com.sensorberg.sdk.ios.error.networkmanager";

// Base URL string to the Sensorberg Beacon Management Platform.
NSString *const SBSDKBaseUrl = @"https://connect.sensorberg.com/api/";

// Query string used to access REST endpoint to retrieve regions.
NSString *const SBSDKRegionsQueryString = @"application/%@/uuids";

// Query string used to resolve a beacon event.
NSString *const SBSDKResolveBeaconEventQueryString = @"beacon/resolve?proximityId=%@&major=%@&minor=%@&deviceId=%@&event=%@&eventTime=%.0f";

// Default number of times a network call should be retried.
NSUInteger const SBSDKDefaultRetryCount = 3;

// Time interval after which the active regions used to monitor for beacons should be updated.
NSTimeInterval const SBSDKRegionsUpdateTimeInterval = 3600.0; // 1 hour

#pragma mark -

@interface SBSDKNetworkManager ()

// Device related object.
@property (nonatomic, strong) SBSDKDeviceID *deviceID;

// URL string to retrieve the active regions from the Sensorberg Beacon Management Platform.
@property (nonatomic, copy) NSString *regionsQueryString;

// Timer used to update the active regions to monitor.
@property (nonatomic, strong) MSWeakTimer *updateRegionsTimer;

//
// Properties redefined to be read-write.
//

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) AFHTTPSessionManager *manager;

// Method that will be called if the UIApplicationDidBecomeActiveNotification is being called.
//
// @param Notification object calling the observer.
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification;

// Method that will be called if the UIApplicationDidBecomeActiveNotification is being called.
//
// @param Notification object calling the observer.
- (void)applicationWillResignActiveNotification:(NSNotification *)notification;

// Method to retrieve the beacon regions to be monitored by the SDK.
- (void)updateRegionsWithRetryCount:(NSUInteger)retryCount;

// Method to retrieve the beacon regions to be monitored by the SDK, retrying a maximum of 3 times.
- (void)updateRegionsWithDefaultRetryCount;

// Method to activate the timer used to update the beacon regions to be monitored.
- (void)activateUpdateRegionsTimer;

// Method to deactivate and invalidate the timer used to update the beacon regions to be monitored.
- (void)deactivateUpdateRegionsTimer;

@end

#pragma mark -

@implementation SBSDKNetworkManager

@synthesize deviceID = _deviceID;
@synthesize regionsQueryString = _regionsQueryString;
@synthesize updateRegionsTimer = _updateRegionsTimer;
@synthesize baseURL = _baseURL;

#pragma mark - Lifecycle

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)init {
    NON_DESIGNATED_INIT(@"initWithApiKey:");
}

- (instancetype)initWithApiKey:(NSString *)apiKey {
    if ((self = [super init])) {
        _baseURL = [[NSURL alloc] initWithString:SBSDKBaseUrl];
        _apiKey = [apiKey copy];

        _deviceID = [[SBSDKDeviceID alloc] init];

        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];

        _manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        _manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];

        [_manager.requestSerializer setValue:_apiKey forHTTPHeaderField:@"Authorization"];
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

        [self activateUpdateRegionsTimer];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc {
    [self deactivateUpdateRegionsTimer];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma clang diagnostic pop

#pragma mark - Application lifecycle handling

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self activateUpdateRegionsTimer];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    [self deactivateUpdateRegionsTimer];
}

#pragma mark - Regions

- (NSString *)regionsQueryString {
    if (_regionsQueryString == nil) {
        _regionsQueryString = [[NSString stringWithFormat:SBSDKRegionsQueryString, self.apiKey] copy];
    }

    return _regionsQueryString;
}

- (void)updateRegions {
    [self updateRegionsWithDefaultRetryCount];
}

- (void)updateRegionsWithDefaultRetryCount {
    [self updateRegionsWithRetryCount:SBSDKDefaultRetryCount];
}

- (void)updateRegionsWithRetryCount:(NSUInteger)retryCount {
    [self.manager GET:self.regionsQueryString
           parameters:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  SBSDKRegionsResponseObject *apiResponseObject = [[SBSDKRegionsResponseObject alloc] initWithResponseObject:responseObject];

                  if (apiResponseObject.success) {
                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:didUpdateRegions:)]) {
                          [self.delegate networkManager:self didUpdateRegions:apiResponseObject.regions];
                      }
                  } else if (retryCount > 0) {
                      [self updateRegionsWithRetryCount:(retryCount - 1)];
                  } else {
                      NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"The Beacon Management Platform did not provide an updated list of beacon regions to be monitored.", @"SensorbergSDK", nil) };

                      NSError *error = [[NSError alloc] initWithDomain:SBSDKNetworkManagerErrorDomain
                                                                  code:SBSDKNetworkManagerErrorUpdateRegionsFailed
                                                              userInfo:userInfo];

                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:updateRegionsDidFailWithError:)]) {
                          [self.delegate networkManager:self updateRegionsDidFailWithError:error];
                      }
                  }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (!error.isFatalNetworkingError && retryCount > 0) {
                      [self updateRegionsWithRetryCount:(retryCount - 1)];
                  } else {
                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:updateRegionsDidFailWithError:)]) {
                          [self.delegate networkManager:self updateRegionsDidFailWithError:error];
                      }
                  }
              }];
}

#pragma mark - Resolve beacon events

- (void)resolveBeaconActionForBeacon:(SBSDKBeacon *)beacon beaconEvent:(SBSDKBeaconEvent)beaconEvent {
    [self resolveBeaconActionWithDefaultRetryCountForBeacon:beacon beaconEvent:beaconEvent];
}

- (void)resolveBeaconActionWithDefaultRetryCountForBeacon:(SBSDKBeacon *)beacon beaconEvent:(SBSDKBeaconEvent)beaconEvent {
    [self resolveBeaconActionWithRetryCount:SBSDKDefaultRetryCount forBeacon:beacon beaconEvent:beaconEvent];
}

- (void)resolveBeaconActionWithRetryCount:(NSUInteger)retryCount forBeacon:(SBSDKBeacon *)beacon beaconEvent:(SBSDKBeaconEvent)beaconEvent {
    __block NSString *eventType = (beaconEvent == SBSDKBeaconEventEnter) ? @"enter" : @"exit";

    NSString *resolveBeaconEventQueryString = [NSString stringWithFormat:SBSDKResolveBeaconEventQueryString,
                                                                         [NSUUID stripHyphensFromUUIDString:beacon.UUIDString],
                                                                         beacon.major,
                                                                         beacon.minor,
                                                                         [NSUUID stripHyphensFromUUIDString:self.deviceID.UUIDString],
                                                                         eventType,
                                                                         beacon.lastSeenAt.timeIntervalSince1970];

    [self.manager GET:resolveBeaconEventQueryString
           parameters:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  SBSDKBeaconEventResponseObject *beaconEventResponseObject = [[SBSDKBeaconEventResponseObject alloc] initWithResponseObject:responseObject];

                  if (beaconEventResponseObject.success) {
                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:didResolveBeaconActions:)]) {
                          [self.delegate networkManager:self didResolveBeaconActions:beaconEventResponseObject.events];
                      }
                  } else if (retryCount > 0) {
                      [self resolveBeaconActionWithRetryCount:(retryCount - 1) forBeacon:beacon beaconEvent:beaconEvent];
                  } else {
                      NSString *errorDescription = [NSString stringWithFormat:@"The Beacon Management Platform did not resolve the actions for a beacon event (%@, on %@).", [beacon.beacon description], eventType];

                      NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(errorDescription, @"SensorbergSDK", nil) };

                      NSError *error = [[NSError alloc] initWithDomain:SBSDKNetworkManagerErrorDomain
                                                                  code:SBSDKNetworkManagerErrorResolveBeaconActionFailed
                                                              userInfo:userInfo];

                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:resolveBeaconActionsDidFailWithError:)]) {
                          [self.delegate networkManager:self resolveBeaconActionsDidFailWithError:error];
                      }
                  }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (!error.isFatalNetworkingError && retryCount > 0) {
                      [self resolveBeaconActionWithRetryCount:(retryCount - 1) forBeacon:beacon beaconEvent:beaconEvent];
                  } else {
                      if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(SBSDKNetworkManagerDelegate)] && [self.delegate respondsToSelector:@selector(networkManager:resolveBeaconActionsDidFailWithError:)]) {
                          [self.delegate networkManager:self resolveBeaconActionsDidFailWithError:error];
                      }
                  }
              }];
}

#pragma mark - Timer

- (void)activateUpdateRegionsTimer {
    if (self.updateRegionsTimer == nil) {
        self.updateRegionsTimer = [MSWeakTimer scheduledTimerWithTimeInterval:SBSDKRegionsUpdateTimeInterval
                                                                       target:self
                                                                     selector:@selector(updateRegionsWithDefaultRetryCount)
                                                                     userInfo:nil
                                                                      repeats:YES
                                                                dispatchQueue:dispatch_get_main_queue()];

        self.updateRegionsTimer.tolerance = 60.0;
    }

    [self.updateRegionsTimer fire];
}

- (void)deactivateUpdateRegionsTimer {
    if (self.updateRegionsTimer != nil) {
        [self.updateRegionsTimer invalidate];

        self.updateRegionsTimer = nil;
    };
}

@end
