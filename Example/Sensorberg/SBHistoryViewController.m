//
//  SBHistoryViewController.m
//  Sensorberg
//
//  Created by Andrei Stoleru on 07/09/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBHistoryViewController.h"

#define kSBCacheFolder            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

#define logPath             [kSBCacheFolder stringByAppendingPathComponent:@"console.log"]

@interface SBHistoryViewController ()

@end

@implementation SBHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [consoleLog setDelegate:self];
    //
//    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
//        int handle = open([logPath cStringUsingEncoding:NSUTF8StringEncoding], O_EVTONLY);
//        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, handle, DISPATCH_VNODE_WRITE, dispatch_get_main_queue());
//        dispatch_source_set_event_handler(source, ^{
//            [self reloadConsole:nil];
//        });
//        dispatch_resume(source);
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = NSLocalizedString(@"Console", @"Console");
}

- (void)viewDidAppear:(BOOL)animated {
    [self reloadConsole:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    reloadButton.enabled = trashButton.enabled = NO;
    [activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [activity stopAnimating];
        reloadButton.enabled = trashButton.enabled = YES;
    });
}


#pragma mark - IBActions

- (IBAction)reloadConsole:(id)sender {
    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        [consoleLog loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:logPath]]];
    } else {
        [consoleLog loadHTMLString:@"Empty console log" baseURL:nil];
    }
}

- (IBAction)trashConsole:(id)sender {
    [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
    //
    [self reloadConsole:nil];
}

- (IBAction)exportConsole:(id)sender {
    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        if ([MFMailComposeViewController canSendMail]) {
            //
            composer = [[MFMailComposeViewController alloc] init];
            [composer addAttachmentData:[NSData dataWithContentsOfFile:logPath] mimeType:@"text/log" fileName:@"console.log"];
            //
            [composer setModalPresentationStyle:UIModalPresentationFormSheet];
            //
            [composer setSubject:[NSString stringWithFormat:@"Console %@",[NSDate date]]];
            
            [composer setMailComposeDelegate:self];
            //
            [self presentViewController:composer animated:YES completion:nil];
        }
    }
}

- (IBAction)goDown:(id)sender {
    CGRect bottom = CGRectMake(0, consoleLog.scrollView.contentSize.height, 1, consoleLog.scrollView.contentSize.height);
    [[consoleLog scrollView] scrollRectToVisible:bottom animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    //
    [self dismissViewControllerAnimated:YES completion:^{
        composer = nil;
    }];
    //
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
