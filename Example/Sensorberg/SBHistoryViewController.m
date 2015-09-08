//
//  SBHistoryViewController.m
//  Sensorberg
//
//  Created by Andrei Stoleru on 07/09/15.
//  Copyright © 2015 tagyro. All rights reserved.
//

#import "SBHistoryViewController.h"

#define kSBCache            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

@interface SBHistoryViewController ()

@end

@implementation SBHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = NSLocalizedString(@"log", @"Log");
    //
    NSString *logPath = [kSBCache stringByAppendingPathComponent:@"console.log"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        consoleLog.text = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    }
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
