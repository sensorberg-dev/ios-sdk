//
//  SBResolver+Models.m
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBResolver+Models.h"

#import "JSONValueTransformer+SBResolver.h"

emptyImplementation(SBMBeacon)

emptyImplementation(SBMContent)

emptyImplementation(SBMTimeframes)

@implementation SBMLayout

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBMAction

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBResolver (Models)

@end
