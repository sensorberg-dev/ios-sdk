//
//  SBHistoryViewController.h
//  Sensorberg
//
//  Created by Andrei Stoleru on 07/09/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

@interface SBHistoryViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIWebView *consoleLog;
    IBOutlet UIActivityIndicatorView *activity;
    //
    IBOutlet UIBarButtonItem *reloadButton;
    IBOutlet UIBarButtonItem *trashButton;
    //
    MFMailComposeViewController *composer;
}

@end
