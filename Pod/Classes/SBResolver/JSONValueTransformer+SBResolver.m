//
//  JSONValueTransformer+SBResolver.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
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
