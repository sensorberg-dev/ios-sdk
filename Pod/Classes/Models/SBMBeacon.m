//
//  SBMBeacon.m
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBMBeacon.h"

#import "NSString+SBUUID.h"

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
        if (fullUUID.length>=32) {
            self.uuid = [[fullUUID substringToIndex:32] lowercaseString];
        }
        if (fullUUID.length>=37) {
            self.major = [[fullUUID substringWithRange:(NSRange){32, 5}] intValue];
        }
        if (fullUUID.length>=42) {
            self.minor = [[fullUUID substringWithRange:(NSRange){37, 5}] intValue];
        }
    }
    return self;
}

- (BOOL)isEqual:(SBMBeacon*)object {
    // we first compare the major and minor values because they're less expensive
    return self.major==object.major && self.minor==object.minor && [self.uuid isEqualToString:object.uuid];
}

- (NSString*)fullUUID {
    return [NSString stringWithFormat:@"%@%@%@", self.uuid, //uuid
            [NSString stringWithFormat:@"%0*d",5,self.major], // major, padded with 0's to length 5
            [NSString stringWithFormat:@"%0*d",5,self.minor]]; // minor, padded with 0's to length 5
}

- (NSString *)description {
    return [NSString stringWithFormat:@"U:%@ M:%@ m:%@", self.uuid, //uuid
            [NSString stringWithFormat:@"%0*d",5,self.major], // major, padded with 0's to length 5
            [NSString stringWithFormat:@"%0*d",5,self.minor]];
}

@end
