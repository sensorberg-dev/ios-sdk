//
//  SBProtocolEvents.h
//  Pods
//
//  Created by Andrei Stoleru on 16/09/15.
//
//

#import "SBEvent.h"

@interface SBEventPerformAction : SBEvent
@property (strong, nonatomic) SBCampaignAction *campaign;
@end

@interface SBEventResetManager : SBEvent
@end