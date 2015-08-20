//
//  SBResolver.m
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBResolver.h"

#import "SBResolver+Events.h"
#import "SBResolver+Models.h"
#import "JSONValueTransformer+SBResolver.h"

#import "SBManager.h"

#define kAPIHeaderTag   @"X-Api-Key"
#define kUserAgentTag   @"User-Agent"

@interface SBResolver() {
    AFHTTPRequestOperationManager *manager;
    NSOperationQueue *operationQueue;
    //
    BOOL noCache;
}

@end

emptyImplementation(SBReachabilityEvent)

@implementation SBResolver

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kSBResolver]];
        //
        [manager.requestSerializer setValue:kSBAPIKey forHTTPHeaderField:kAPIHeaderTag];
        [manager.requestSerializer setValue:[SBUtility userAgent] forHTTPHeaderField:kUserAgentTag];
        //
        operationQueue = manager.operationQueue;
        //
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    PUBLISH(({
                        SBReachabilityEvent *event = [SBReachabilityEvent new];
                        event.reachable = YES;
                        event;
                    }));
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    PUBLISH(({
                        SBReachabilityEvent *event = [SBReachabilityEvent new];
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
    [self getLayout];
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

- (void)getLayout {
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
                                                 NSLog(@"response: %@",[responseObject class]);
                                                 //
                                                 SBMLayout *layout = [[SBMLayout alloc] initWithDictionary:responseObject error:&error];
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

#pragma mark - Reachability event

SUBSCRIBE(SBReachabilityEvent) {
    operationQueue.suspended = !event.reachable;
}

@end
