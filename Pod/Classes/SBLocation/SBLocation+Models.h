//
//  SBLocation+Models.h
//  Pods
//
//  Created by Andrei Stoleru on 02/09/15.
//
//

#import "SBLocation.h"

#import "SBUtility.h"

@interface SBMSession : JSONModel
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSDate *enter;
@property (strong, nonatomic) NSDate *exit;
@property (strong, nonatomic) NSDate *lastSeen;
@end

@interface SBLocation (Models)

@end
