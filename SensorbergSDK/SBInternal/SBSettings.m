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

NSString * const kSBSettingsURLFormat = @"https://connect.sensorberg.com/api/applications/%@/settings/iOS";
NSString * const kSBSettingsUserDefaultKey = @"kSBSettingsUserDefaultKey";
NSString * const kSBSettingsDictionaryRevisionKey = @"revision";
NSString * const kSBSettingsDictionarySettingsKey = @"settings";

#pragma mark - SBMSettings

@interface SBMSettings ()
@property (nonatomic, copy) NSNumber *revisionNumber;

- (void)updateSettingsFromSettings:(SBMSettings *)aSettings;
@end

@implementation SBMSettings

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.revisionNumber = @(-1);
    }
    return self;
}

- (void)updateSettingsFromSettings:(SBMSettings *)aSettings
{
    
}

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
@end

emptyImplementation(SBUpdateSettingEvent);

#pragma mark - SBSettings

@interface SBSettings () {
    SBMSettings *settings;
}

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

- (void)dealloc
{
    UNREGISTER();
}

- (nonnull SBMSettings *)settings
{
    if (!settings)
    {
        NSDictionary *settingsDict = [[NSUserDefaults standardUserDefaults] objectForKey:kSBSettingsUserDefaultKey];
        NSError *parseError = nil;
        if (settingsDict)
        {
            settings = [[SBMSettings alloc] initWithDictionary:settingsDict error:&parseError];
        }
        
        if (!settingsDict || parseError)
        {
            SBLog(@"WARNING : No Default Setting in Cache! %@ %@", parseError ? @"Parse Error : " : @"", parseError ?: @"");
        }
        
        if (!settings)
        {
            settings = [SBMSettings new];
            [[NSUserDefaults standardUserDefaults] setObject:[settings toDictionary] forKey:kSBSettingsUserDefaultKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return settings;
}

- (void)requestSettingsWithAPIKey:(NSString *)key
{
    if (key.length == 0)
    {
        PUBLISH((({
            SBUpdateSettingEvent *event = [SBUpdateSettingEvent new];
            event.responseDictionary = nil;
            event.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorBadURL userInfo:nil];
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
                SBUpdateSettingEvent *event = [SBUpdateSettingEvent new];
                event.responseDictionary = responseDict;
                event.error = blockError;
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
    
    NSMutableDictionary *settingsDict = event.responseDictionary[kSBSettingsDictionarySettingsKey];
    NSNumber *newRevisionNumber = event.responseDictionary[kSBSettingsDictionaryRevisionKey];
    
    if (newRevisionNumber)
    {
        [settingsDict setObject:newRevisionNumber forKey:kSBSettingsDictionaryRevisionKey];
    }
    
    if (!newRevisionNumber || [newRevisionNumber compare:settings.revisionNumber] != NSOrderedDescending)
    {
        SBLog(@"ERROR : Failed To Update Setting : [%@]",event.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            PUBLISH((({
                SBSettingEvent *settingEvent = [SBSettingEvent new];
                settingEvent.settings = [settings copy];
                settingEvent.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCancelled userInfo:nil];
                settingEvent;
            })));
        });
        return;
    }
    
    NSError *mappingError = nil;
    SBMSettings *newSettings = [[SBMSettings alloc] initWithDictionary:settingsDict error:&mappingError];
    
    if (!mappingError)
    {
        [settings updateSettingsFromSettings:newSettings];
        [[NSUserDefaults standardUserDefaults] setObject:[settings toDictionary] forKey:kSBSettingsUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PUBLISH((({
            SBSettingEvent *settingEvent = [SBSettingEvent new];
            settingEvent.settings = [settings copy];
            settingEvent.error = mappingError;
            settingEvent;
        })));
    });
}

@end
