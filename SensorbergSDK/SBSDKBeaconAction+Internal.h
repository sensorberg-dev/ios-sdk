#import <objc/NSObject.h>
#import "SBSDKBeaconAction.h"


@interface SBSDKBeaconAction (Internal)

/**
Designated initializer of the `SBSDKBeaconAction` object. You need to provide a `NSDictionary`
object that holds action information.

@param action Action object to be handled.

@return `SBSDKBeaconAction` object

@since 0.7.0
*/
- (instancetype)initWithJSONDictionary:(NSDictionary *)action;

@end
