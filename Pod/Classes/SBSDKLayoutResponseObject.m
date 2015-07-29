//
//  SBSDKBeaconEventResponseObject.m
//  SensorbergSDK
//
//  Created by Thomas Ploentzke.
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

#import "SBSDKLayoutResponseObject.h"

#import "SBSDKMacros.h"

#import "SBSDKBeaconAction.h"

#pragma mark -

@interface SBSDKLayoutResponseObject ()

//
// Properties redefined to be read-write.
//

@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSArray* actions;
@property (nonatomic, strong) NSArray* accountProximityUUIDs;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSString* Etag;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) NSNumber* maxAge;

@end

#define SBSDKLayoutResponseActionKey @"actions"
#define SBSDKLayoutResponseRegionsKey @"accountProximityUUIDs"
#define SBSDKLayoutResponseVersionKey @"currentVersion"
#define SBSDKAPIResponseHeaderEtagKey @"Etag"
#define SBSDKAPIResponseHeaderCacheControlKey @"Cache-Control"

#pragma mark -

@implementation SBSDKLayoutResponseObject

@synthesize success = _success;
@synthesize response = _response;

#pragma mark - Response handling

- (instancetype)init {
    NON_DESIGNATED_INIT(@"-initWithTask:responseObject:");
}

- (instancetype)initWithResponseObject:(id)responseObject {
    NON_DESIGNATED_INIT(@"-initWithTask:responseObject:");
}

- (instancetype)initWithTask:(NSURLSessionTask *)task responseObject:(id)responseObject {
    if ((self = [super init])) {
        
        self.task = task;
        
        self.responseObject = responseObject;
    }
    
    return self;
}

#pragma clang diagnostic pop

#pragma mark - Response handling

- (void)setTask:(NSURLSessionTask *)task {
    if (task != self.task) {
        self.success = NO;
        
        // parse eTag FIeld
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
            
            if ([response.allHeaderFields objectForKey:SBSDKAPIResponseHeaderEtagKey] && [[response.allHeaderFields objectForKey:SBSDKAPIResponseHeaderEtagKey] isKindOfClass:[NSString class]]) {
                self.Etag = [response.allHeaderFields objectForKey:SBSDKAPIResponseHeaderEtagKey];
            }
            
            self.maxAge = [NSNumber numberWithInt:0];
            
            if ([response.allHeaderFields objectForKey:SBSDKAPIResponseHeaderCacheControlKey] && [[response.allHeaderFields objectForKey:SBSDKAPIResponseHeaderCacheControlKey] isKindOfClass:[NSString class]]) {
                
                NSArray* rules = [[response.allHeaderFields objectForKey:SBSDKAPIResponseHeaderCacheControlKey] componentsSeparatedByString:@","];
                
                for (NSString* rule in rules) {
                    
                    if ([rule hasPrefix:@"max-age="]) {
                        
                        int maxAgeInt = [[rule stringByReplacingOccurrencesOfString:@"max-age=" withString:@""] intValue];
                        
                        if ( maxAgeInt > 0 ) {
                            self.maxAge = [NSNumber numberWithInt:maxAgeInt];
                        }
                        break;
                    }
                }
            }
            
            self.statusCode = response.statusCode;
            
            if (self.statusCode == 200 || self.statusCode == 304) {
                self.success = YES;
            }
        }
    }
}

- (void)setResponseObject:(id)responseObject {
    if (responseObject != self.responseObject) {
        if (self.success) {
            self.response = responseObject;
        }
    }
}

- (void)setResponse:(id)response {
    if (response != self.response) {
        _response = response;

        if ([_response isKindOfClass:[NSDictionary class]]) {
            if ([_response[SBSDKLayoutResponseActionKey] isKindOfClass:[NSArray class]]) {
                NSMutableArray *newActions = [NSMutableArray array];

                for (id eachObject in (NSArray *)_response[SBSDKLayoutResponseActionKey]) {
                    if ([eachObject isKindOfClass:[NSDictionary class]]) {
                        [newActions addObject:[[SBSDKBeaconAction alloc] initWithAction:(NSDictionary *)eachObject]];
                    }
                }

                self.actions = [newActions copy];
            }
            
            if ([_response[SBSDKLayoutResponseRegionsKey] isKindOfClass:[NSArray class]]) {
                NSMutableArray *newProximityUUIDs = [NSMutableArray array];
                
                for (id eachObject in (NSArray *)_response[SBSDKLayoutResponseRegionsKey]) {
                    if ([eachObject isKindOfClass:[NSString class]]) {
                        [newProximityUUIDs addObject:eachObject];
                    }
                }
                
                self.accountProximityUUIDs = [newProximityUUIDs copy];
            }
        }
    }
}

@end
