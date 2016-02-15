//
//  SBSettings.m
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

#import "SBSettings.h"

#import <AFNetworking/AFNetworking.h>

@implementation SBMSettings
@end

@interface SBSettings () {
    SBMSettings *settings;
}

@end

@implementation SBSettings

#define kConnectURL        @"https://connect.sensorberg.com/"

#define kSettingsURL        @"api/applications/%@/settings/ios/"

#define kDefaultSettings   @""

- (void)requestSettingsForAPIKey:(NSString*)APIKey {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kConnectURL]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *requestURLString = [NSString stringWithFormat:kSettingsURL,APIKey];
    
    AFHTTPRequestOperation *req = [manager GET:requestURLString
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                           //
                                       }
                                       failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                           //
                                       }];
    
    [req resume];
}

- (SBMSettings *)settings {
    if (isNull(settings)) {
        settings = [[SBMSettings alloc] initWithString:kDefaultSettings error:nil];
        //
    }
    //
    return settings;
}

@end
