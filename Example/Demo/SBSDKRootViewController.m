//
//  SBSDKRootViewController.m
//  SensorbergSDK
//
//  Created by Max Horvath on 09/09/2014.
//  Copyright (c) 2014 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "SBSDKRootViewController.h"

#import "SBSDKDetectedBeaconsViewController.h"
#import "SBSDKStatusTableViewController.h"
#import "SBSDKAppDelegate.h"

@implementation SBSDKRootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.demos = @[ @[ @"Detected Beacons" ],
                    @[ @"Status" ],
                    @[ API_KEY, [NSString stringWithFormat:@"SDK: %@", SENSORBERGSDK_VERSION] ],
                    @[ @"Reset" ]
                    ];
}

#pragma mark - Tableview data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.demos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.demos[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Demos";
        case 1:
            return @"Miscellaneous";
        case 2:
            return @"API Key";
        case 3:
            return @"Reset Device Identifier";

        default:
            break;
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];

    cell.textLabel.text = [self.demos[indexPath.section] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            [self performSegueWithIdentifier:@"detectedBeaconsSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"statusSegue" sender:self];
            break;
        case 2:
            [[[UIAlertView alloc] initWithTitle:@"API Key"
                                        message:API_KEY
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            break;
        case 3:
            [[[UIAlertView alloc] initWithTitle:@"Reset Device Identifier"
                                        message:@"Do you really want to reset the device identifier for testing purposes? 'Send only once' and 'Send every X Minutes' campaigns will work again."
                                       delegate:self
                              cancelButtonTitle:@"NO"
                              otherButtonTitles:@"YES", nil] show];
            break;
        default:
            break;
    }
}
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.firstOtherButtonIndex){
        SBSDKAppDelegate * delegate = (SBSDKAppDelegate*) [UIApplication sharedApplication].delegate;
        [delegate.beaconManager disconnectFromBeaconManagementPlatformAndResetDeviceIdentifier];
        NSError *connectionError = nil;
        [delegate.beaconManager connectToBeaconManagementPlatformUsingApiKey:API_KEY
                                                                       error:&connectionError];

        if (!connectionError) {
            [delegate.beaconManager requestAuthorization];
            [delegate.beaconManager startMonitoringBeacons];

        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error setting up the SDK"
                                        message:[NSString stringWithFormat:@"There was an error setting up the SDK\nDetecting beacons will not work:\n'%@'", connectionError.localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            NSLog(@"there was an connection error: %@", connectionError.localizedDescription);
        }
    }
}

@end
