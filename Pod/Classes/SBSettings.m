//
//  SBSettings.m
//  Pods
//
//  Created by andsto on 12/11/15.
//
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
