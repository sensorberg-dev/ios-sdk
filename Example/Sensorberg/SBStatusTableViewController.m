//
//  SBStatusTableViewController.m
//  Sensorberg
//
//  Created by Andrei Stoleru on 05/10/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import "SBStatusTableViewController.h"

#import "SBAppDelegate.h"

typedef enum : NSUInteger {
    kSBSectionAPIKey = 0,
    kSBSectionStatus = 1,
} kSBSections;

typedef enum : NSUInteger {
    kSBRowBeacons = 0,
    kSBRowResolver = 1,
    kSBRowLocation = 2,
    kSBRowBluetooth = 3,
    kSBRowBackground = 4,
} kSBRows;

typedef enum : NSUInteger {
    kSBAPIDefault=0,
    kSBAPIChange=1,
    kSBAPICancel=2,
} kSBAPISheet;

@interface SBStatusTableViewController ()

@end

@implementation SBStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    REGISTER();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
    [self getStatus:nil];
    //
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal methods

- (IBAction)getStatus:(id)sender {
    if (sender) {
        [[SBManager sharedManager] requestResolverStatus];
    }
    
    double ping = [[SBManager sharedManager] resolverLatency];
    //
    if (ping<0.0f) {
        statusResolver.detailTextLabel.text = @"-";
    } else {
        statusResolver.detailTextLabel.text = [NSString stringWithFormat:@"%.2fs",ping];
    }
    //
    NSString *location = @"<undefined>";
    switch ([[SBManager sharedManager] locationAuthorization]) {
        case SBLocationAuthorizationStatusAuthorized:
            location = @"authorized";
            break;
        case SBLocationAuthorizationStatusDenied:
            location = @"denied";
            break;
        case SBLocationAuthorizationStatusNotDetermined:
            location = @"unknown";
            break;
        case SBLocationAuthorizationStatusRestricted:
            location = @"restricted";
            break;
        case SBLocationAuthorizationStatusUnavailable:
            location = @"unavailable";
            break;
        case SBLocationAuthorizationStatusUnimplemented:
            location = @"unimplemented";
            break;
        default:
            break;
    }
    statusLocation.detailTextLabel.text = location;
    //
    NSString *bluetooth = @"<undefined>";
    switch ([[SBManager sharedManager] bluetoothAuthorization]) {
        case SBBluetoothOff:
            bluetooth = @"off";
            break;
        case SBBluetoothOn:
            bluetooth = @"on";
            break;
        case SBBluetoothUnknown:
            bluetooth = @"unknown";
            break;
        default:
            break;
    }
    statusBluetooth.detailTextLabel.text = bluetooth;
    //
    NSString *beacons = @"<undefined>";
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        beacons = @"available";
    } else {
        beacons = @"unavailable";
    }
    statusBeacons.detailTextLabel.text = beacons;
    //
    NSString *background = @"<undefined>";
    switch ([[SBManager sharedManager] backgroundAppRefreshStatus]) {
        case SBManagerBackgroundAppRefreshStatusAvailable:
        {
            background = @"available";
            break;
        }
        case SBManagerBackgroundAppRefreshStatusRestricted:
        {
            background = @"restricted";
            break;
        }
        case SBManagerBackgroundAppRefreshStatusDenied:
        {
            background = @"denied";
            break;
        }
        case SBManagerBackgroundAppRefreshStatusUnavailable:
        {
            background = @"unavailable";
            break;
        }
        default:
            break;
    }
    statusBackground.detailTextLabel.text = background;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    switch (indexPath.section) {
        case kSBSectionAPIKey:
        {
            [self changeAPIKey:nil];
            break;
        }
        
        case kSBSectionStatus:
        {
            //
            break;
        }
    }
}

#pragma mark - IBAction

- (IBAction)changeAPIKey:(id)sender {
    UIActionSheet *apiQuestion = [[UIActionSheet alloc] initWithTitle:@"API KEY"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Use demo API key", @"Scan QR code", nil];
    [apiQuestion showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case kSBAPIDefault:
        {
            //change to default api key
            break;
        }
        case 1:
        {
            if (!qrReader) {
                qrReader = [[QRCodeReader alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            }
            QRCodeReaderViewController *qrVC = [[QRCodeReaderViewController alloc] initWithCancelButtonTitle:@"Cancel" codeReader:qrReader];
            qrVC.modalPresentationStyle = UIModalPresentationFormSheet;
            qrVC.delegate = self;
            //
            [qrVC setCompletionWithBlock:^(NSString * _Nullable resultAsString) {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (resultAsString.length==64) {
                        [[NSUserDefaults standardUserDefaults] setObject:resultAsString forKey:kSBAPIKey];
                    }
                }];
            }];
            //
            [self presentViewController:qrVC animated:YES completion:NULL];
            break;
        }
        case 2:
        {
            NSLog(@"2");
            break;
        }
        default:
            break;
    }
    //
    
}

#pragma mark - SBSDK Events

SUBSCRIBE(SBEventLocationAuthorization) {
    [self getStatus:nil];
}

SUBSCRIBE(SBEventPing) {
    [self getStatus:nil];
}

SUBSCRIBE(SBEventGetLayout) {
    
}

@end
