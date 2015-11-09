//
//  SBStatusTableViewController.m
//  Sensorberg
//
//  Created by Andrei Stoleru on 05/10/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import <Sensorberg/SBManager.h>
#import "SBStatusTableViewController.h"

#import "SBAppDelegate.h"

typedef enum : NSUInteger {
    kSBSectionAPIKey = 0,
    kSBSectionStatus = 1,
} kSBSections;

typedef enum : NSUInteger {
    kSBSetupApi = 0,
    kSBSetupResolver = 1,
} kSBSetupRows;

typedef enum : NSUInteger {
    kSBRowBeacons = 0,
    kSBRowResolver = 1,
    kSBRowLocation = 2,
    kSBRowBluetooth = 3,
    kSBRowBackground = 4,
} kSBStatusRows;

typedef enum : NSUInteger {
    kSBAPIDefault=0,
    kSBAPIChange=1,
    kSBAPICancel=2,
} kSBAPISheet;

typedef enum : NSUInteger {
    kSBResolverDefault=0,
    kSBResolverChange=1,
    kSBResolverCancel=2,
} kSBResolverSheet;

@interface SBStatusTableViewController ()

@end

@implementation SBStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //
    [self getStatus:nil];
    //
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal methods

- (void)setup {
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:kSBAPIKey];
    if (isNull(apiKey)) {
        apiKey = @"0000000000000000000000000000000000000000000000000000000000000000";
        [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:kSBAPIKey];
    }
    //
    NSString *resolver = [[NSUserDefaults standardUserDefaults] objectForKey:kSBResolver];
    if (isNull(resolver)) {
        resolver = @"https://resolver.sensorberg.com/";
        [[NSUserDefaults standardUserDefaults] setObject:resolver forKey:kSBResolver];
    }
    //
    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    [[SBManager sharedManager] setupResolver:resolver apiKey:apiKey delegate:self];
    //
    [[SBManager sharedManager] requestLocationAuthorization];
    //
    [[SBManager sharedManager] requestResolverStatus];
    //
}

- (void)resetManager {
    [[SBManager sharedManager] resetSharedClient];
    //
    [self setup];
}

- (IBAction)getStatus:(id)sender {
    if (!isNull(sender)) {
        [self resetManager];
        //
        return;
    }
    //
    keyCell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kSBAPIKey];
    resolverCell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kSBResolver];
    //
    double ping = [[SBManager sharedManager] resolverLatency];
    //
    if (ping<0.0f) {
        statusResolver.detailTextLabel.text = @"-";
    } else {
        statusResolver.detailTextLabel.text = [NSString stringWithFormat:@"%.2fs",ping];
    }
    //
    NSString *location = @"<undefined>";
    statusLocation.detailTextLabel.textColor = [UIColor blackColor];
    switch ([[SBManager sharedManager] locationAuthorization]) {
        case SBLocationAuthorizationStatusAuthorized:
            location = @"authorized";
            break;
        case SBLocationAuthorizationStatusDenied:
            location = @"denied";
            statusLocation.detailTextLabel.textColor = [UIColor redColor];
            break;
        case SBLocationAuthorizationStatusNotDetermined:
            location = @"unknown";
            statusLocation.detailTextLabel.textColor = [UIColor redColor];
            break;
        case SBLocationAuthorizationStatusRestricted:
            location = @"restricted";
            statusLocation.detailTextLabel.textColor = [UIColor redColor];
            break;
        case SBLocationAuthorizationStatusUnavailable:
            location = @"unavailable";
            statusLocation.detailTextLabel.textColor = [UIColor redColor];
            break;
        case SBLocationAuthorizationStatusUnimplemented:
            location = @"unimplemented";
            statusLocation.detailTextLabel.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
    statusLocation.detailTextLabel.text = location;
    //
    NSString *bluetooth = @"<undefined>";
    statusBluetooth.detailTextLabel.textColor = [UIColor blackColor];
    switch ([[SBManager sharedManager] bluetoothAuthorization]) {
        case SBBluetoothOff:
            bluetooth = @"off";
            statusBluetooth.detailTextLabel.textColor = [UIColor redColor];
            break;
        case SBBluetoothOn:
            bluetooth = @"on";
            break;
        case SBBluetoothUnknown:
            bluetooth = @"unknown";
            statusBluetooth.detailTextLabel.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
    statusBluetooth.detailTextLabel.text = bluetooth;
    //
    NSString *beacons = @"<undefined>";
    statusBeacons.detailTextLabel.textColor = [UIColor blackColor];
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        beacons = @"available";
    } else {
        beacons = @"unavailable";
        statusBeacons.detailTextLabel.textColor = [UIColor redColor];
    }
    statusBeacons.detailTextLabel.text = beacons;
    //
    NSString *background = @"<undefined>";
    statusBackground.detailTextLabel.textColor = [UIColor blackColor];
    switch ([[SBManager sharedManager] backgroundAppRefreshStatus]) {
        case SBManagerBackgroundAppRefreshStatusAvailable:
        {
            background = @"available";
            break;
        }
        case SBManagerBackgroundAppRefreshStatusRestricted:
        {
            background = @"restricted";
            statusBackground.detailTextLabel.textColor = [UIColor redColor];
            break;
        }
        case SBManagerBackgroundAppRefreshStatusDenied:
        {
            background = @"denied";
            statusBackground.detailTextLabel.textColor = [UIColor redColor];
            break;
        }
        case SBManagerBackgroundAppRefreshStatusUnavailable:
        {
            background = @"unavailable";
            statusBackground.detailTextLabel.textColor = [UIColor redColor];
            break;
        }
        default:
            break;
    }
    statusBackground.detailTextLabel.text = background;
    //
//    [wait dismissWithClickedButtonIndex:0 animated:YES];
    //
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    switch (indexPath.section) {
        case kSBSectionAPIKey:
        {
            if (indexPath.row==kSBSetupApi) {
                [self changeAPIKey:nil];
            } else if (indexPath.row==kSBSetupResolver) {
                [self changeResolver:nil];
            }
            break;
        }
        
        case kSBSectionStatus:
        {
            //
            break;
        }
        default:break;
    }
}

#pragma mark - IBAction

- (IBAction)changeAPIKey:(id)sender {
    apiQuestion = [[UIActionSheet alloc] initWithTitle:@"API KEY"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Use demo API key", @"Scan QR code", nil];
    [apiQuestion showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)changeResolver:(id)sender {
    resolverQuestion = [[UIActionSheet alloc] initWithTitle:@"Resolver URL"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Use demo URL", @"Enter custom URL", nil];
    [resolverQuestion showFromTabBar:self.tabBarController.tabBar];
}


- (IBAction)doRefresh:(id)sender {
    [self getStatus:nil];
    //
    [sender endRefreshing];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet==apiQuestion) {
        switch (buttonIndex) {
            case kSBAPIDefault:
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"0000000000000000000000000000000000000000000000000000000000000000" forKey:kSBAPIKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //
                [self resetManager];
                //
                break;
            }
            case kSBAPIChange:
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
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //
                            [self resetManager];
                        }
                    }];
                }];
                //
                [self presentViewController:qrVC animated:YES completion:NULL];
                break;
            }
            default:
                break;
        }
    } else if (actionSheet==resolverQuestion) {
        switch (buttonIndex) {
            case kSBResolverDefault:
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"https://resolver.sensorberg.com/" forKey:kSBResolver];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //
                [self resetManager];
                //
                break;
            }
            case kSBResolverChange:
            {
                enterResolver = [[UIAlertView alloc] initWithTitle:@"Resolver URL"
                                                                        message:@"Please enter resolver URL"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"Save", nil];
                [enterResolver setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [enterResolver show];
                break;
            }
            default:
                break;
        }
    }
    //
    apiQuestion = nil;
    resolverQuestion = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        NSString *resolver = [alertView textFieldAtIndex:0].text;
        if (resolver.length>5) {
            [[NSUserDefaults standardUserDefaults] setObject:resolver forKey:kSBResolver];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //
            [self resetManager];
        }
        //
    }
}

#pragma mark - SBSDK Events

SUBSCRIBE(SBEventLocationAuthorization) {
    [self getStatus:nil];
}

SUBSCRIBE(SBEventPing) {
    [self getStatus:nil];
}

SUBSCRIBE(SBEventGetLayout) {
    [self getStatus:nil];
}

SUBSCRIBE(SBEventBluetoothAuthorization) {
    [self getStatus:nil];
}

@end
