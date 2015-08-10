//
//  SBAPIModels.m
//  Pods
//
//  Created by Andrei Stoleru on 10/08/15.
//
//

#import "SBAPIModels.h"

@implementation JSONValueTransformer (SBValueFormatter)

- (NSDate *)NSDateFromNSString:(NSString*)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:APIDateFormat];
    return [formatter dateFromString:string];
}

- (id)JSONObjectFromNSDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:APIDateFormat];
    return [formatter stringFromDate:date];
}

@end

@implementation SBMUUID
@end

@implementation SBMBeacon
@end

@implementation SBMContent
@end

@implementation SBMTimeframes

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBMAction

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBMLayout
@end

@implementation SBAPIModels

@end
