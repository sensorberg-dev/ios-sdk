//
//  SBResolver+Events.h
//  Pods
//
//  Created by Andrei Stoleru on 13/08/15.
//
//

#import "SBResolver.h"
#import "SBResolver+Models.h"

@interface SBELayout : NSObject
@property (strong, nonatomic) SBMLayout *layout;
@property (strong, nonatomic) NSError *error;
@end

@interface SBResolver (Events)

@end
