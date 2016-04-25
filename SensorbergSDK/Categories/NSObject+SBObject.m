//
//  NSObject+SBObject.m
//  Pods
//
//  Created by Andrei Stoleru on 25/04/16.
//
//

#import "NSObject+SBObject.h"

#import <objc/runtime.h>

@implementation NSObject (SBObject)

- (NSArray *)allProperties
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

- (NSDictionary*)propertyDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (NSString *key in [self allProperties]) {
        if ([[self valueForKey:key] isKindOfClass:[NSObject class]]) {
            [dict setObject:[self valueForKey:key] forKey:key];
        }
    }
    
    return dict;
}

- (NSString*)jsonString {
    //
}

- (BOOL)isEqualToString:(NSString*)aString {
    return NO;
}

@end
