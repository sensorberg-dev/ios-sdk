//
//  JSONValueTransformer+SBResolver.m
//  Pods
//
//  Created by Andrei Stoleru on 20/08/15.
//
//

#import "JSONValueTransformer+SBResolver.h"

@implementation JSONValueTransformer (SBResolver)

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

- (SBMBeacon *)SBMBeaconFromNSString:(NSString*)fullUUID {
    //7367672374000000ffff0000ffff0003 00002 00747
    SBMBeacon *beacon = [SBMBeacon new];
    beacon.uuid = [fullUUID substringToIndex:32];
    beacon.major = [[fullUUID substringWithRange:(NSRange){32, 37}] intValue];
    beacon.minor = [[fullUUID substringWithRange:(NSRange){37, fullUUID.length-1}] intValue];
    //
    return beacon;
}

- (id)JSONObjectFromSBMBeacon:(SBMBeacon *)beacon {
    return [NSString stringWithFormat:@"%@%@%@", beacon.uuid, //uuid
            [NSString stringWithFormat:@"%0*d",5,beacon.major], // major, padded with 0's to length 5
            [NSString stringWithFormat:@"%0*d",5,beacon.minor]]; // minor, padded with 0's to length 5
}

@end
