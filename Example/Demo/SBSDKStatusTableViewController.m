//
//  SBSDKStatusTableViewController.m
//  SensorbergSDK
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

#import "SBSDKStatusTableViewController.h"

#import "SBSDKAppDelegate.h"

@implementation SBSDKStatusTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.beaconManager = [(SBSDKAppDelegate *)[UIApplication sharedApplication].delegate beaconManager];

    self.features = @[ @[ @"Ready to resolve iBeacon events:" ],
                       @[ @"Bluetooth:", @"Background App Refresh:", @"Location services authorized:" ],
                       @[ @"Connected to Platform:", @"Platform reachable:" ] ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
                                                 name:SBSDKAppDelegateAvailabilityStatusChanged
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

#pragma mark - Tableview data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.features.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.features[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"iOS";

        case 2:
            return @"Sensorberg Platform";

        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusDefaultCell"];

    cell.textLabel.text = [self.features[indexPath.section] objectAtIndex:indexPath.row];

    switch (indexPath.section) {
        case 0:
            cell.detailTextLabel.text = (self.beaconManager.availabilityStatus == SBSDKManagerAvailabilityStatusFullyFunctional) ? @"Yes" : @"No";
            break;

        case 1:
            switch (indexPath.row) {
                case 0:
                    switch (self.beaconManager.bluetoothStatus) {
                        case SBSDKManagerBluetoothStatusUnknown:
                            cell.detailTextLabel.text = @"Unknown";
                            break;

                        case SBSDKManagerBluetoothStatusPoweredOff:
                            cell.detailTextLabel.text = @"Disabled";
                            break;

                        case SBSDKManagerBluetoothStatusUnavailable:
                            cell.detailTextLabel.text = @"Unavailable";
                            break;

                        case SBSDKManagerBluetoothStatusPoweredOn:
                            cell.detailTextLabel.text = @"Enabled";
                            break;

                        default:
                            break;
                    }

                    break;

                case 1:
                    switch (self.beaconManager.backgroundAppRefreshStatus) {
                        case SBSDKManagerBackgroundAppRefreshStatusRestricted:
                        case SBSDKManagerBackgroundAppRefreshStatusDenied:
                            cell.detailTextLabel.text = @"Disabled";
                            break;

                        case SBSDKManagerBackgroundAppRefreshStatusUnavailable:
                            cell.detailTextLabel.text = @"Unavailable";
                            break;

                        case SBSDKManagerBackgroundAppRefreshStatusAvailable:
                            cell.detailTextLabel.text = @"Enabled";
                            break;

                        default:
                            break;
                    }

                case 2:
                    switch (self.beaconManager.authorizationStatus) {
                        case SBSDKManagerAuthorizationStatusNotDetermined:
                            cell.detailTextLabel.text = @"Not determined";
                            break;

                        case SBSDKManagerAuthorizationStatusUnimplemented:
                            cell.detailTextLabel.text = @"Unimplemented";
                            break;

                        case SBSDKManagerAuthorizationStatusUnavailable:
                            cell.detailTextLabel.text = @"Unavailable";
                            break;

                        case SBSDKManagerAuthorizationStatusRestricted:
                        case SBSDKManagerAuthorizationStatusDenied:
                            cell.detailTextLabel.text = @"Disabled";
                            break;

                        case SBSDKManagerAuthorizationStatusAuthorized:
                            cell.detailTextLabel.text = @"Enabled";
                            break;

                        default:
                            break;
                    }

                default:
                    break;
            }

            break;

        case 2:
            switch (indexPath.row) {
                case 0:
                    switch (self.beaconManager.connectionState) {
                        case SBSDKManagerConnectionStateDisconnected:
                            cell.detailTextLabel.text = @"Disconnected";
                            break;

                        case SBSDKManagerConnectionStateConnecting:
                            cell.detailTextLabel.text = @"Connecting";
                            break;
                        case SBSDKManagerConnectionStateConnected:
                            cell.detailTextLabel.text = @"Connected";
                            break;

                        default:
                            break;
                    }
                    break;

                case 1:
                    switch (self.beaconManager.reachabilityState) {
                        case SBSDKManagerReachabilityStateNotReachable:
                            cell.detailTextLabel.text = @"Not reachable";
                            break;

                        case SBSDKManagerReachabilityStateReachable:
                            cell.detailTextLabel.text = @"Reachable";
                            break;

                        default:
                            break;
                    }
                    
                default:
                    break;
            }

            break;

        default:
            break;
    }

    return cell;
}

@end
