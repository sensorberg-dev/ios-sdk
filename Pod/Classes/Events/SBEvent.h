//
//  SBEvent.h
//  Pods
//
//  Created by Andrei Stoleru on 08/09/15.
//
//

#import <Foundation/Foundation.h>

#import "SBResolverModels.h"
#import "SBProtocolModels.h"

@interface SBEvent : JSONModel
@property (strong, nonatomic) NSError <Optional> *error;
@end

@interface SBEventApplicationLaunched : SBEvent
@property (strong, nonatomic) NSDictionary *userInfo;
@end

@interface SBEventApplicationActive : SBEvent
@end

@interface SBEventApplicationForeground : SBEvent
@end

