//
//  SBReminder.h
//  Pods
//
//  Created by Andrei Stoleru on 31/08/15.
//
//

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

@interface SBMNotification : JSONModel
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *caller;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) BOOL isFinal;
@property (nonatomic) BOOL isVolatile;
@property (nonatomic) BOOL isRepeating;
@end

@interface SBScheduler : NSObject

- (void)getNotifications;

- (void)addNotification:(SBMNotification*)notification;

@end
