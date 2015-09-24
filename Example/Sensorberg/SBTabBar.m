//
//  SBTabBar.m
//  Sensorberg
//
//  Created by Andrei Stoleru on 22/09/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import "SBTabBar.h"

#import <Sensorberg/SensorbergSDK.h>

#define TESTING

#ifdef TESTING
#define kBaseURL    @"https://resolver.sensorberg.com/"
#define kApiKey     @"248b403be4d9041aca3c01bcb886f876d8fc1768379993f7c7e3b19f41526a2a"
#else
#define kBaseURL    @"https://staging-resolver.sensorberg.com/"
#define kApiKey     @"0000000000000000000000000000000000000000000000000000000000000000"
#endif

@interface SBTabBar ()

@end

@implementation SBTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    REGISTER();
    // Do any additional setup after loading the view.
    [[SBManager sharedManager] setupResolver:kBaseURL apiKey:kApiKey];
    [[SBManager sharedManager] requestLocationAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Shake event

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype==UIEventSubtypeMotionShake) {
        if (alert) {
            return;
        }
        //
        alert = [[UIAlertView alloc] initWithTitle:@"Reset SBManager"
                                           message:@"Do you want to reset the SBManager instance?"
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"YES", nil];
        //
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"cancel");
        }
            break;
        case 1:
        {
            [[SBManager sharedManager] resetSharedClient];
            //
            [[SBManager sharedManager] setupResolver:kBaseURL apiKey:kApiKey];
            [[SBManager sharedManager] requestLocationAuthorization];
        }
            break;
        default:
            break;
    }
    //
    alert = nil;
}

#pragma mark - SBManagerDelegate

- (void)onSBEventPerformAction:(SBEventPerformAction*)event {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (event.campaign.fireDate) {
        notification.fireDate = event.campaign.fireDate;
    } else {
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    }
    notification.alertTitle = event.campaign.subject;
    notification.alertBody = event.campaign.body;
    notification.alertAction = [NSString stringWithFormat:@"%@",event.campaign.payload];
    //
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

SUBSCRIBE(SBEventLocationAuthorization) {
    [[SBManager sharedManager] requestLayout];
}

SUBSCRIBE(SBEventBluetoothAuthorization) {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
