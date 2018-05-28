//
//  SBModel.m
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

#import "SBModel.h"

#import "SensorbergSDK.h"

#import "NSString+SBUUID.h"

emptyImplementation(SBModel)

emptyImplementation(SBMTrigger)

@implementation SBMCampaignAction

- (NSString *)action {
    return self.uuid;
}

@end

#pragma mark - SBPeripheral

@implementation SBMRegion

- (instancetype)initWithString:(NSString*)UUID {
    self = [super init];
    if (self) {
        self.tid = UUID;
    }
    return self;
}

@end

@implementation SBMBeacon

- (instancetype)initWithCLBeacon:(CLBeacon*)beacon {
    self = [super init];
    if (self) {
        self.uuid = [[NSString stripHyphensFromUUIDString:beacon.proximityUUID.UUIDString] lowercaseString];
        self.major = [beacon.major intValue];
        self.minor = [beacon.minor intValue];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)fullUUID {
    self = [super init];
    if (self) {
        NSString *tmpUUID = [fullUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if (tmpUUID.length != 42)
        {
            SBLog(@"Given fullUUID should have 42.");
            return nil;
        }
        
        if (tmpUUID.length>=32) {
            self.uuid = [[tmpUUID substringToIndex:32] lowercaseString];
        }
        if (tmpUUID.length>=37) {
            self.major = [[tmpUUID substringWithRange:(NSRange){32, 5}] intValue];
        }
        if (tmpUUID.length>=42) {
            self.minor = [[tmpUUID substringWithRange:(NSRange){37, 5}] intValue];
        }
    }
    return self;
}

- (instancetype)initWithUuid:(NSString *)uuid major:(int)major minor:(int)minor {
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.major = major;
        self.minor = minor;
    }

    return self;
}

+ (instancetype)beaconWithUuid:(NSString *)uuid major:(int)major minor:(int)minor {
    return [[self alloc] initWithUuid:uuid major:major minor:minor];
}


- (BOOL)isEqual:(SBMBeacon*)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    return self.major==object.major && self.minor==object.minor && [self.uuid isEqualToString:object.uuid];
}

- (NSString*)tid {
    return [NSString stringWithFormat:@"%@%@%@", self.uuid, //uuid
            [NSString stringWithFormat:@"%0*d",5,self.major], // major, padded with 0's to length 5
            [NSString stringWithFormat:@"%0*d",5,self.minor]]; // minor, padded with 0's to length 5
}

- (NSUUID*)UUID {
    return [[NSUUID alloc] initWithUUIDString:[NSString hyphenateUUIDString:self.uuid]];
}

@end

@implementation SBMGeofence

- (instancetype)initWithGeoHash:(NSString *)geohash {
    self = [super init];
    if (self) {
        GHArea *area = [GeoHash areaForHash:[geohash substringToIndex:8]];
        if (area) {
            self.latitude = area.latitude.min.doubleValue + (area.latitude.max.doubleValue - area.latitude.min.doubleValue)/2;
            self.longitude = area.longitude.min.doubleValue + (area.longitude.max.doubleValue - area.longitude.min.doubleValue)/2;
            self.radius = [geohash substringFromIndex:8].doubleValue;
            
            self.tid = geohash;
        }
    }
    return self;
}

- (instancetype)initWithRegion:(CLCircularRegion *)region {
    self = [super init];
    if (self) {
        self.latitude = region.center.latitude;
        self.longitude = region.center.longitude;
        self.radius = region.radius;
        //
        self.tid = [GeoHash hashForLatitude:region.center.latitude longitude:region.center.longitude length:9];
    }
    return self;
}

@end
