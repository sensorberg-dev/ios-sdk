//
//  SBResolverModels.m
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBResolverModels.h"

#import "SBUtility.h"

@implementation SBMContent

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

emptyImplementation(SBMTimeframe)

@implementation SBMAction

- (BOOL)validate:(NSError *__autoreleasing *)error {
    NSMutableArray *newBeacons = [NSMutableArray new];
    for (NSString *uuid in self.beacons) {
        SBMBeacon *beacon = [[SBMBeacon alloc] initWithString:uuid];
        if (!isNull(beacon)) {
            [newBeacons addObject:beacon];
        }
    }
    self.beacons = [NSArray <SBMBeacon> arrayWithArray:newBeacons];
    return [super validate:error];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBMGetLayout

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBMReportAction

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

emptyImplementation(SBMPostLayout)