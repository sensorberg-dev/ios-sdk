//
//  SBSDKRangingViewController.m
//  SensorbergSDK
//
//  Created by Max Horváth on 10.09.14.
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
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

#import "SBSDKDetectedBeaconsViewController.h"

#import "SBSDKAppDelegate.h"

@interface SBSDKDetectedBeaconsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *uuidLabel;
@property (nonatomic, strong) IBOutlet UILabel *majorMinorLabel;

@end

@implementation SBSDKDetectedBeaconsTableViewCell

@end

@implementation SBSDKDetectedBeaconsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.beaconManager = [(SBSDKAppDelegate *)[UIApplication sharedApplication].delegate beaconManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
                                                 name:SBSDKAppDelegateDetectedBeaconsUpdated
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

#pragma mark - Tableview data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.beaconManager.detectedBeacons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBSDKDetectedBeaconsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detectedBeaconsDefaultCell" forIndexPath:indexPath];

    SBSDKBeacon *beacon = self.beaconManager.detectedBeacons[indexPath.row];

    cell.uuidLabel.text = beacon.UUIDString;
    cell.majorMinorLabel.text = [NSString stringWithFormat:@"%@ / %@", beacon.major.stringValue, beacon.minor.stringValue];

    return cell;
}

@end
