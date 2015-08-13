//
//  SBResolver+Models.m
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//
//

#import "SBResolver+Models.h"

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

emptyImplementation(SBMUUID)

emptyImplementation(SBMBeacon)

emptyImplementation(SBMContent)

emptyImplementation(SBMTimeframes)

emptyImplementation(SBMLayout)

@implementation SBMAction

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation SBResolver (Models)

@end
