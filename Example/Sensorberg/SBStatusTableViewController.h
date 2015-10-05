//
//  SBStatusTableViewController.h
//  Sensorberg
//
//  Created by Andrei Stoleru on 05/10/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QRCodeReaderViewController/QRCodeReaderViewController.h>

@interface SBStatusTableViewController : UITableViewController <QRCodeReaderDelegate, UIActionSheetDelegate> {
    QRCodeReader *qrReader;
    
    IBOutlet UITableViewCell *keyCell;
    
    IBOutlet UITableViewCell *statusBeacons;
    IBOutlet UITableViewCell *statusResolver;
    IBOutlet UITableViewCell *statusLocation;
    IBOutlet UITableViewCell *statusBluetooth;
    IBOutlet UITableViewCell *statusBackground;
}

@end
