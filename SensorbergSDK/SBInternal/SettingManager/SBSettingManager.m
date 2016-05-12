//
//  SBSettingManager.m
//  WhiteLabel
//
//  Created by ParkSanggeon on 27/04/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import "SBSettingManager.h"
#import "SBHTTPRequestManager.h"
#import <tolo/Tolo.h>

#pragma mark - Constants

NSString * const kSBSettingsURLFormat = @"https://connect.sensorberg.com/api/applications/%@/settings/iOS";

#pragma mark - SBSettingEvent

@implementation SBSettingEvent @end

#pragma mark - SBSettingManager

@implementation SBSettingManager

#pragma mark - Static Interfaces

+ (instancetype _Nonnull)sharedManager
{
    static dispatch_once_t once;
    static SBSettingManager *_sharedManager = nil;
    
    dispatch_once(&once, ^{
        _sharedManager = [SBSettingManager new];
        
    });
    
    return _sharedManager;
}

#pragma mark - Public Interfaces

- (instancetype)init
{
    if (self = [super init])
    {
        REGISTER();
    }
    
    return self;
}

- (void)dealloc
{
    UNREGISTER();
}

- (void)requestSettingWithAPIKey:(NSString *)key
{
    if (key.length == 0)
    {
        PUBLISH((({
            SBSettingEvent *event = [SBSettingEvent new];
            event.settingsDictionary = nil;
            event.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil];;
            event;
        })));
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:kSBSettingsURLFormat, key]];
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    [manager getDataFromURL:URL headerFields:nil useCache:YES completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        NSError *blockError = error;
        NSDictionary *responseDict = nil;
        
        if (!blockError)
        {
            NSError *parseError =nil;
            responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:&parseError];
            if (parseError)
            {
                blockError = parseError;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            PUBLISH((({
                SBSettingEvent *event = [SBSettingEvent new];
                event.settingsDictionary = responseDict;
                event.error = blockError;
                event;
            })));
        });
    }];
}

@end
