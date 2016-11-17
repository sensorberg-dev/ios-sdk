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

#pragma mark - SBSettings

@interface SBSettings ()
@property (nonnull, nonatomic, copy, readwrite) SBMSettings *settings;
@end

@implementation SBSettings

#pragma mark - Static Interfaces

static dispatch_once_t once;
static SBSettings *_sharedManager = nil;

+ (instancetype _Nonnull)sharedManager
{
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
    self.settings = [SBMSettings new];
}

SUBSCRIBE(SBUpdateSettingEvent)
{
    if(event.error)
    {
        SBLog(@"ERROR : Failed To Update Setting : [%@]",event.error);
        PUBLISH((({
            SBSettingEvent *settingEvent = [SBSettingEvent new];
            settingEvent.error = event.error;
            settingEvent;
        })));
        return;
    }
    
    NSMutableDictionary *settingsDict = [event.responseDictionary[kSBSettingsDictionarySettingsKey] mutableCopy];
    
    NSError *mappingError = nil;
    SBMSettings *newSettings = [[SBMSettings alloc] initWithDictionary:settingsDict error:&mappingError];
    
    if (mappingError || [[newSettings toDictionary] isEqualToDictionary:[self.settings toDictionary]])
    {
        SBLog(@"ERROR : Failed To Update Setting : [%@]",mappingError);
        PUBLISH((({
            SBSettingEvent *settingEvent = [SBSettingEvent new];
            settingEvent.error = mappingError ?: [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCancelled userInfo:nil];
            settingEvent;
        })));
        return;
    }
    
    self.settings = newSettings;
    
    SBSettingEvent *settingEvent = [SBSettingEvent new];
    settingEvent.settings = [newSettings toDictionary];
    PUBLISH(settingEvent);
}

@end
