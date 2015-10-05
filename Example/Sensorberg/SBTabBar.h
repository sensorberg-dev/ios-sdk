//
//  SBTabBar.h
//  Sensorberg
//
//  Created by Andrei Stoleru on 22/09/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBDemoNotificationEvent : NSObject
@property (strong, nonatomic) UILocalNotification *notification;
@end

@interface SBTabBar : UITabBarController <UIAlertViewDelegate> {
    UIAlertView *alert;
}

@end
