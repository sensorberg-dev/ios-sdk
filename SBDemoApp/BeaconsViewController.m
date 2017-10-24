
//  BeaconsViewController.m
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 12/01/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

#import "BeaconsViewController.h"

#import <SensorbergSDK/SensorbergSDK.h>

#import <SensorbergSDK/NSString+SBUUID.h>

#import <tolo/Tolo.h>

#warning Enter your API key here
#define kAPIKey     @"000"

@interface BeaconsViewController () {
    NSMutableDictionary *beacons;
}

@end

static NSString *const kReuseIdentifier = @"beaconCell";

@implementation BeaconsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    beacons = [NSMutableDictionary new];
    
    [[SBManager sharedManager] setApiKey:kAPIKey delegate:self];
    //
    [[SBManager sharedManager] requestLocationAuthorization:YES];
    [[SBManager sharedManager] requestNotificationsAuthorization];
    //
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"Beacons";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return beacons.allValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    
    if ([beacons.allValues[indexPath.row] isKindOfClass:[SBMBeacon class]]) {
        SBMBeacon *beacon = beacons.allValues[indexPath.row];
        NSString *proximityUUID = [[NSString hyphenateUUIDString:beacon.uuid] uppercaseString];
        if ([[SensorbergSDK defaultBeaconRegions] valueForKey:proximityUUID]) {
            cell.textLabel.text = [[SensorbergSDK defaultBeaconRegions] valueForKey:proximityUUID];
        } else {
            cell.textLabel.text = proximityUUID;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Major:%i  Minor:%i", beacon.major, beacon.minor];
        
        
    } else if ([beacons.allValues[indexPath.row] isKindOfClass:[CBPeripheral class]]) {
        CBPeripheral *p = beacons.allValues[indexPath.row];
        
        cell.textLabel.text = p.name ? p.name : @"No Name";
        cell.detailTextLabel.text = p.identifier.UUIDString;
        
        cell.imageView.image = [self imageFromText:@"BLE"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SensorbergSDK events

#pragma mark SBEventLocationAuthorization
SUBSCRIBE(SBEventLocationAuthorization) {
    if (event.locationAuthorization==SBLocationAuthorizationStatusAuthorized) {
            [[SBManager sharedManager] startMonitoring];
    } else {
        NSLog(@"Location Service OFF, monitoring doesn't work");
    }
}

#pragma mark SBEventBluetoothAuthorization
SUBSCRIBE(SBEventBluetoothAuthorization) {
    // You only need to ask for Bluetooth authorisation when working with GATT
}

SUBSCRIBE(SBEventNotificationsAuthorization) {
    if (!event.notificationsAuthorization) {
//        When notifications are not allowed
    }
}

#pragma mark SBEventRegionEnter
SUBSCRIBE(SBEventRegionEnter) {
    [beacons setValue:event.beacon forKey:event.beacon.tid];
    [self.tableView reloadData];
    //
}

#pragma mark SBEventRegionExit
SUBSCRIBE(SBEventRegionExit) {
    [beacons setValue:nil forKey:event.beacon.tid];
    [self.tableView reloadData];
}

#pragma mark SBEventRangedBeacon
SUBSCRIBE(SBEventRangedBeacon) {
    [beacons setValue:event.beacon forKey:event.beacon.tid];
}

#pragma mark SBEventPerformAction
SUBSCRIBE(SBEventPerformAction) {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertTitle = event.campaign.subject;
    notification.alertBody = [NSString stringWithFormat:@"Name: %@\nBody: %@",event.campaign.subject,event.campaign.beacon.tid];
    notification.alertAction = [NSString stringWithFormat:@"%@",event.campaign.payload];
    //
    if (event.campaign.fireDate) {
        notification.fireDate = event.campaign.fireDate;
    } else {
        if ([[SBManager sharedManager] canReceiveNotifications]) {
            [[SBManager sharedManager] reportConversion:kSBConversionSuccessful forCampaignAction:event.campaign.uuid];
        } else {
            [[SBManager sharedManager] reportConversion:kSBConversionUnavailable forCampaignAction:event.campaign.uuid];
        }
    }
    //
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //
}

#pragma mark - Utility

-(UIImage *)imageFromText:(NSString *)text
{
    CGSize size  = [text sizeWithAttributes:nil];
    
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    
    [text drawAtPoint:CGPointZero withAttributes:nil];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
