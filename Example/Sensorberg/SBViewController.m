//
//  SBViewController.m
//  Sensorberg
//
//  Created by tagyro on 08/10/2015.
//  Copyright (c) 2015 tagyro. All rights reserved.
//

#import "SBViewController.h"

@interface SBViewController ()

@end

@implementation SBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    REGISTER();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//

SUBSCRIBE(SBELayout) {
    NSLog(@"[%s]:%@",__func__,event);
    if (event.error) {
        return;
    }
    //
}

@end
