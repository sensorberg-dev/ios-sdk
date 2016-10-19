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

#import "SensorbergSDK.h"

#import "SBSettings.h"
#import "SBHTTPRequestManager.h"
#import <tolo/Tolo.h>

#pragma mark - Constants

NSString * const kSBSettingsDictionarySettingsKey = @"settings";


NSString * const SBDefaultResolverURL = @"https://resolver.sensorberg.com";
NSString * const kSBSettingsDefaultPathFormat = @"applications/%@/settings/iOS";

#pragma mark - SBMSettings

@interface SBMSettings ()
@end

@implementation SBMSettings

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([@"defaultBeaconRegions" isEqualToString:propertyName])
    {
        return YES;
    }
    
    return NO;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _monitoringDelay = 30.0f; // 30 seconds
        _postSuppression = 60.0f; // 1 minute
        _defaultBeaconRegions = @{
                                     @"73676723-7400-0000-FFFF-0000FFFF0000":@"SB-0",
                                     @"73676723-7400-0000-FFFF-0000FFFF0001":@"SB-1",
                                     @"73676723-7400-0000-FFFF-0000FFFF0002":@"SB-2",
                                     @"73676723-7400-0000-FFFF-0000FFFF0003":@"SB-3",
                                     @"73676723-7400-0000-FFFF-0000FFFF0004":@"SB-4",
                                     @"73676723-7400-0000-FFFF-0000FFFF0005":@"SB-5",
                                     @"73676723-7400-0000-FFFF-0000FFFF0006":@"SB-6",
                                     @"73676723-7400-0000-FFFF-0000FFFF0007":@"SB-7",
                                     @"B9407F30-F5F8-466E-AFF9-25556B57FE6D":@"Estimote",
                                     @"F7826DA6-4FA2-4E98-8024-BC5B71E0893E":@"Kontakt.io",
                                     @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6":@"Radius Network",
                                     @"F0018B9B-7509-4C31-A905-1A27D39C003C":@"Beacon Inside",
                                     @"23A01AF0-232A-4518-9C0E-323FB773F5EF":@"Sensoro"
                                     };
    }
    return self;
}

#pragma mark -

- (id)copy
{
    return [[SBMSettings alloc] initWithDictionary:[self toDictionary] error:nil];
}

@end

#pragma mark - SBSettingEvent

emptyImplementation(SBSettingEvent);

#pragma mark - SBSettingUpdateEvent

@interface SBUpdateSettingEvent : SBEvent
@property (nullable, nonatomic, strong) NSDictionary *responseDictionary;
@property (nullable, nonatomic, copy) NSString *apiKey;
@end

emptyImplementation(SBUpdateSettingEvent);

#pragma mark - SBSettings

@interface SBSettings ()
@property (nonnull, nonatomic, copy, readwrite) SBMSettings *settings;
@end

@implementation SBSettings

#pragma mark - Static Interfaces

+ (instancetype _Nonnull)sharedManager
{
    static dispatch_once_t once;
    static SBSettings *_sharedManager = nil;
    
    dispatch_once(&once, ^{
        _sharedManager = [SBSettings new];
        
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

#pragma mark - Accessors

- (nonnull SBMSettings *)settings
{
    if (isNull(_settings))
    {
        _settings = [SBMSettings new];
    }
    return _settings;
}

#pragma mark -

- (void)reset
{
    self.settings = nil;
}

- (void)requestSettingsWithAPIKey:(NSString *)key
{
    if (key.length == 0)
    {
        PUBLISH((({
            SBUpdateSettingEvent *event = [SBUpdateSettingEvent new];
            event.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorBadURL userInfo:nil];
            event;
        })));
        return;
    }
    
    NSString *baseURL = [SBDefaultResolverURL copy];
    NSString *path = [NSString stringWithFormat:kSBSettingsDefaultPathFormat, key];
    NSString *fullPath = [baseURL stringByAppendingPathComponent:path];
    NSURL *URL = [NSURL URLWithString:fullPath];
    
    SBHTTPRequestManager *manager = [SBHTTPRequestManager sharedManager];
    [manager getDataFromURL:URL headerFields:nil useCache:YES completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        NSError *blockError = error;
        NSDictionary *responseDict = nil;
        
        if (isNull(blockError))
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
                SBUpdateSettingEvent *event = [SBUpdateSettingEvent new];
                event.responseDictionary = responseDict;
                event.error = blockError;
                event.apiKey = key;
                event;
            })));
        });
    }];
}

SUBSCRIBE(SBUpdateSettingEvent)
{
    if(event.error)
    {
        SBLog(@"ERROR : Failed To Update Setting : [%@]",event.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            PUBLISH((({
                SBSettingEvent *settingEvent = [SBSettingEvent new];
                settingEvent.settings = nil;
                settingEvent.error = event.error;
                settingEvent;
            })));
        });
        return;
    }
    
    NSMutableDictionary *settingsDict = [event.responseDictionary[kSBSettingsDictionarySettingsKey] mutableCopy];
    
    NSError *mappingError = nil;
    SBMSettings *newSettings = [[SBMSettings alloc] initWithDictionary:settingsDict error:&mappingError];
    
    if (mappingError || [[newSettings toDictionary] isEqualToDictionary:[self.settings toDictionary]])
    {
        SBLog(@"ERROR : Failed To Update Setting : [%@]",event.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            PUBLISH((({
                SBSettingEvent *settingEvent = [SBSettingEvent new];
                settingEvent.settings = [self.settings copy];
                settingEvent.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCancelled userInfo:nil];
                settingEvent;
            })));
        });
        return;
    }
    
    if (isNull(mappingError))
    {
        self.settings = newSettings;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PUBLISH((({
            SBSettingEvent *settingEvent = [SBSettingEvent new];
            settingEvent.settings = mappingError ? nil : [self.settings copy];
            settingEvent.error = mappingError;
            settingEvent;
        })));
    });
}

@end
