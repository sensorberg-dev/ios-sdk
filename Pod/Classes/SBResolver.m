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

#import "SBMSession.h"

#import "SBManager.h"

#import "SBResolverEvents.h"

#import "JSONValueTransformer+SBResolver.h"

#import <AFNetworking/AFNetworking.h>

#import <tolo/Tolo.h>

#define kAPIHeaderTag   @"X-Api-Key"
#define kUserAgentTag   @"User-Agent"
#define kInstallId      @"X-iid"

@interface SBResolver() {
    AFHTTPRequestOperationManager *manager;
    NSOperationQueue *operationQueue;
    //
    BOOL noCache;
}

@end

@implementation SBResolver

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[SBManager sharedManager].kSBResolver]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //
        NSString *ua = [SBUtility userAgent];
        [manager.requestSerializer setValue:[SBManager sharedManager].kSBAPIKey forHTTPHeaderField:kAPIHeaderTag];
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
                        SBEReachabilityEvent *event = [SBEReachabilityEvent new];
                        event.reachable = YES;
                        event;
                    }));
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    PUBLISH(({
                        SBEReachabilityEvent *event = [SBEReachabilityEvent new];
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
    AFHTTPRequestOperation *ping = [manager GET:@"ping"
                                     parameters:nil
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            //
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            //
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
                                                 SBELayout *event = [SBELayout new];
                                                 event.error = [error copy];
                                                 event.layout = layout;
                                                 PUBLISH(event);
                                                 //
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 SBELayout *event = [SBELayout new];
                                                 event.error = [error copy];
                                                 PUBLISH(event);
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
                                                   NSLog(@"success post");
                                               }
                                               failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                                   NSLog(@"error posting");
                                               }];
    //
    NSLog(@"post: %@",data);
    //
    [postLayout resume];
}

#pragma mark - Reachability event

SUBSCRIBE(SBEReachabilityEvent) {
    operationQueue.suspended = !event.reachable;
}

#pragma mark - Connection availability

- (BOOL)isConnected {
    return !operationQueue.suspended;
}

@end
