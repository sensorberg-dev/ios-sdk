//
//  SBResolver.m
//  SensorbergSDK
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

#import "SBResolver.h"

#import "SBManager.h"

#import "SBResolverEvents.h"

#import <AFNetworking/AFNetworking.h>

#define kAPIHeaderTag   @"X-Api-Key"
#define kUserAgentTag   @"User-Agent"
#define kInstallId      @"X-iid"

@interface SBResolver() {
    AFHTTPRequestOperationManager *manager;
    NSOperationQueue *operationQueue;
    //
    BOOL noCache;
    //
    double timestamp;
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
        NSString *ua = [SBUtility userAgent];
        [manager.requestSerializer setValue:apiKey forHTTPHeaderField:kAPIHeaderTag];
        [manager.requestSerializer setValue:ua forHTTPHeaderField:kUserAgentTag];
        //
        NSString *iid = [[NSUserDefaults standardUserDefaults] valueForKey:kSBIdentifier];
        if (isNull(iid)) {
            iid = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setValue:iid forKey:kSBIdentifier];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //
        [manager.requestSerializer setValue:iid forHTTPHeaderField:kInstallId];
        //
        operationQueue = manager.operationQueue;
        //
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    PUBLISH(({
                        SBEventReachabilityEvent *event = [SBEventReachabilityEvent new];
                        event.reachable = YES;
                        event;
                    }));
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    PUBLISH(({
                        SBEventReachabilityEvent *event = [SBEventReachabilityEvent new];
                        event.reachable = NO;
                        event;
                    }));
                    break;
            }
        }];
    }
    return self;
}

#pragma mark - External methods

- (void)updateLayout {
    noCache = YES;
    //
    [self requestLayout];
}

#pragma mark - Resolver calls

- (void)ping {
    timestamp = [NSDate timeIntervalSinceReferenceDate];
    //
    AFHTTPRequestOperation *ping = [manager GET:@"health"
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            PUBLISH((({
                                                SBEventPing *ping = [SBEventPing new];
                                                ping.latency = [NSDate timeIntervalSinceReferenceDate]-timestamp;
                                                ping;
                                            })));
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            PUBLISH((({
                                                SBEventPing *ping = [SBEventPing new];
                                                ping.error = [error copy];
                                                ping;
                                            })));
                                        }];
    //
    [ping resume];
}

- (void)requestLayout {
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    //
    if (noCache) {
        noCache = false;
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    //
    AFHTTPRequestOperation *getLayout = [manager GET:@"layout"
                                          parameters:@{}
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 NSError *error;
                                                 //
                                                 SBMGetLayout *layout = [[SBMGetLayout alloc] initWithDictionary:responseObject error:&error];
                                                 //
                                                 SBEventGetLayout *event = [SBEventGetLayout new];
                                                 event.error = [error copy];
                                                 event.layout = layout;
                                                 PUBLISH(event);
                                                 //
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 SBEventGetLayout *event = [SBEventGetLayout new];
                                                 event.error = [error copy];
                                                 PUBLISH(event);
                                             }];
    //
    [getLayout resume];
}

- (void)postLayout:(SBMPostLayout*)postData {
    NSDictionary *data = [postData toDictionary];
    if ([SBUtility debugging]) {
//        SBLog(@"> Post layout: %@",data);
    }
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
    operationQueue.suspended = !event.reachable;
}

#pragma mark - Connection availability

- (BOOL)isConnected {
    return !operationQueue.suspended;
}

@end
