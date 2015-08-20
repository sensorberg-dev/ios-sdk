//
//  JSONValueTransformer+SBResolver.h
//  Pods
//
//  Created by Andrei Stoleru on 20/08/15.
//
//

#import <JSONModel/JSONModel.h>

#import "SBResolver+Models.h"

@interface JSONValueTransformer (SBResolver)

- (NSDate *)NSDateFromNSString:(NSString*)string;
- (id)JSONObjectFromNSDate:(NSDate *)date;

- (SBMBeacon *)SBMBeaconFromNSString:(NSString*)fullUUID;
- (id)JSONObjectFromSBMBeacon:(SBMBeacon *)beacon;

@end
