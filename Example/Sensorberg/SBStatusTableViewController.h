//
//  SBStatusTableViewController.h
//  Sensorberg
//
//  Created by Andrei Stoleru on 05/10/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QRCodeReaderViewController/QRCodeReaderViewController.h>

@interface SBStatusTableViewController : UITableViewController <QRCodeReaderDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    QRCodeReader *qrReader;
    
    IBOutlet UITableViewCell *keyCell;
    IBOutlet UITableViewCell *resolverCell;
    
    IBOutlet UITableViewCell *statusBeacons;
    IBOutlet UITableViewCell *statusResolver;
    IBOutlet UITableViewCell *statusLocation;
    IBOutlet UITableViewCell *statusBluetooth;
    IBOutlet UITableViewCell *statusBackground;
    
    UIActionSheet *apiQuestion;
    UIActionSheet *resolverQuestion;
    
    UIAlertView *enterResolver;
}

@end
