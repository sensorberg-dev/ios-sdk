//
//  NSObject+SBObject.h
//  Pods
//
//  Created by Andrei Stoleru on 25/04/16.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (SBObject)

- (NSArray *)allProperties;

- (NSDictionary*)propertyDictionary;

@end
