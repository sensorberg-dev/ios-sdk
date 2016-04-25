//
//  SBResolver.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
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

#import "SBResolver.h"

#import "SensorbergSDK.h"

#import "SBInternalEvents.h"

#import <AFNetworking/AFNetworking.h>

#import <tolo/Tolo.h>

@interface SBResolver() {
    AFHTTPRequestOperationManager *manager;
    NSOperationQueue *operationQueue;
    //
    double timestamp;
    
    NSString *cacheIdentifier;
}

@end

@implementation SBResolver

- (instancetype)initWithResolver:(NSString*)resolverURL apiKey:(NSString*)apiKey
{
    self = [super init];
    if (self) {
        //
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:resolverURL]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //
        NSString *ua = [[SBUtility userAgent] toJSONString];
        [manager.requestSerializer setValue:apiKey forHTTPHeaderField:kAPIHeaderTag];
        [manager.requestSerializer setValue:ua forHTTPHeaderField:kUserAgentTag];
        // IDFA
        NSString *IDFA = [keychain stringForKey:kIDFA];
        if (IDFA && IDFA.length>0) {
            [manager.requestSerializer setValue:IDFA forHTTPHeaderField:kIDFA];
        } else {
            [manager.requestSerializer setValue:nil forHTTPHeaderField:kIDFA];
        }
        //
        NSString *iid = [[NSUserDefaults standardUserDefaults] valueForKey:kSBIdentifier];
        if (isNull(iid)) {
            iid = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setValue:iid forKey:kSBIdentifier];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //
        cacheIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:kCacheKey];
        if (![cacheIdentifier isEqualToString:apiKey]) {
            [[NSUserDefaults standardUserDefaults] setValue:apiKey forKey:kCacheKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            
            SBLog(@"Cleared cache because API Key changed");
        }
        //
        [manager.requestSerializer setValue:iid forHTTPHeaderField:kInstallId];
        //
        operationQueue = manager.operationQueue;
        //
        [manager.reachabilityManager startMonitoring];
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            SBEventReachabilityEvent *event = [SBEventReachabilityEvent new];
            event.reachable = (status==AFNetworkReachabilityStatusNotReachable || status==AFNetworkReachabilityStatusUnknown) ? NO : YES;
            PUBLISH(event);
        }];
    }
    return self;
}

#pragma mark - Resolver calls

- (void)ping {
    timestamp = [NSDate timeIntervalSinceReferenceDate];
    //
    AFHTTPRequestOperation *ping = [manager GET:@"layout"
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            PUBLISH((({
                                                SBEventPing *event = [SBEventPing new];
                                                event.latency = [NSDate timeIntervalSinceReferenceDate]-timestamp;
                                                event;
                                            })));
                                            //
                                            PUBLISH((({
                                                SBEventReachabilityEvent *event = [SBEventReachabilityEvent new];
                                                event.reachable = YES;
                                                event;
                                            })));
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            PUBLISH(({
                                                SBEventPing *event = [SBEventPing new];
                                                event.error = [error copy];
                                                event;
                                            }));
                                        }];
    //
    [ping resume];
}

- (void)requestLayoutForBeacon:(SBMBeacon*)beacon trigger:(SBTriggerType)trigger useCache:(BOOL)useCache {
    SBLog(@"❓ GET Layout %@|%@|%@",
          isNull(beacon) ? @"Without UUID" : beacon.description,
          trigger==1 ? @"Enter"  : @"Exit",
          useCache==YES ? @"Cached" : @"No cache");
    //
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    //
    if (useCache) {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    //
    AFHTTPRequestOperation *getLayout = [manager GET:@"layout"
                                          parameters:@{}
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 NSError *error;
                                                 //
                                                 SBMGetLayout *layout = [[SBMGetLayout alloc] initWithDictionary:responseObject error:&error];
                                                 //
                                                 if (isNull(beacon)) {
                                                     PUBLISH((({
                                                         SBEventGetLayout *event = [SBEventGetLayout new];
                                                         event.error = [error copy];
                                                         event.layout = layout;
                                                         event;
                                                     })));
                                                 } else {
                                                     [layout checkCampaignsForBeacon:beacon trigger:trigger];
                                                     //
                                                 }
                                                 //
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 PUBLISH(({
                                                     SBEventGetLayout *event = [SBEventGetLayout new];
                                                     event.error = [error copy];
                                                     event.beacon = beacon;
                                                     event.trigger = trigger;
                                                     event;
                                                 }));
                                             }];
    //
    [getLayout resume];
}

- (void)postLayout:(SBMPostLayout*)postData {
    NSDictionary *data = [postData toDictionary];
    //
    AFHTTPRequestOperation *postLayout = [manager POST:@"layout"
                                            parameters:data
                                               success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                   PUBLISH([SBEventPostLayout new]);
                                               }
                                               failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                                   PUBLISH((({
                                                       SBEventPostLayout *event = [SBEventPostLayout new];
                                                       event.error = [error copy];
                                                       event;
                                                   })));
                                               }];
    //
    [postLayout resume];
}

#pragma mark - Reachability event

SUBSCRIBE(SBEventReachabilityEvent) {
    SBLog(@"Reachable: %@",event.reachable==YES ? @"YES" : @"NO");
    operationQueue.suspended = !event.reachable;
}

#pragma mark - Connection availability

- (BOOL)isConnected {
    return !operationQueue.suspended;
}

#pragma mark - SBEventUpdateHeaders

SUBSCRIBE(SBEventUpdateHeaders) {
    
    NSString *IDFA = [keychain stringForKey:kIDFA];
    
    if (IDFA && IDFA.length>0) {
        [manager.requestSerializer setValue:IDFA forHTTPHeaderField:kIDFA];
    } else {
        [manager.requestSerializer setValue:nil forHTTPHeaderField:kIDFA];
    }
}

@end
