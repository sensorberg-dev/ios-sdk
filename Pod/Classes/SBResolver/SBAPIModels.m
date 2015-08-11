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

EMPTY_IMPL(SBMUUID)

EMPTY_IMPL(SBMBeacon)

EMPTY_IMPL(SBMContent)

EMPTY_IMPL(SBMTimeframes)

EMPTY_IMPL(SBMLayout)

EMPTY_IMPL(SBAPIModels)

@implementation SBMAction

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end