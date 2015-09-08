//
//  SBResolverModels.m
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import "SBResolverModels.h"

#import "SBUtility.h"

#import "SBMBeacon.h"

emptyImplementation(SBMContent)

emptyImplementation(SBMTimeframe)

@implementation SBMAction

- (BOOL)validate:(NSError *__autoreleasing *)error {
    NSMutableArray *newBeacons = [NSMutableArray new];
    for (NSString *uuid in self.beacons) {
        [newBeacons addObject:[[SBMBeacon alloc] initWithString:uuid]];
    }
    self.beacons = [NSArray arrayWithArray:newBeacons];
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

emptyImplementation(SBMReportAction)

emptyImplementation(SBMPostLayout)