//
//  SBBeaconsTableViewController.m
//  SensorbergSDK
//
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

#import "SBBeaconsTableViewController.h"

@interface SBBeaconsTableViewController ()

@end

@implementation SBBeaconsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    REGISTER();
    //
    items = [NSArray new];
    //
    values = [NSMutableDictionary new];
    //
    distances = [NSMutableDictionary new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
    self.title = NSLocalizedString(@"iBeacons", @"iBeacons");
    //
//    [[SBManager sharedManager] setDelegate:self];
    //
    if (!progressView) {
        progressView = [[JGProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.frame = CGRectMake(0,
                                        self.navigationController.navigationBar.frame.size.height-progressView.frame.size.height,
                                        self.navigationController.navigationBar.frame.size.width,
                                        progressView.frame.size.height);
        //
        [self.navigationController.navigationBar addSubview:progressView];
        progressView.animationSpeed = -0.5f;
        progressView.indeterminate = YES;
    }
}

#pragma mark - Resolver events

SUBSCRIBE(SBELayout) {
    if (event.error) {
        NSLog(@"%s %@", __func__, event.error);
        return;
    }
    //
//    NSLog(@"%s:\n%@", __func__, event.layout);
    //
}

#pragma mark - iBeacon events

SUBSCRIBE(SBERegionEnter) {
    SBMBeacon *beacon = [[SBMBeacon alloc] initWithString:event.fullUUID];
    //
    items = [items arrayByAddingObject:beacon];
    //
    [self.tableView reloadData];
}

SUBSCRIBE(SBERegionExit) {
    NSMutableArray *newItems = [NSMutableArray new];
    //
    for (SBMBeacon *beacon in items) {
        if (![beacon.fullUUID isEqualToString:event.fullUUID]) {
            [newItems addObject:beacon];
        }
    }
    //
    items = [NSArray arrayWithArray:newItems];
    //
    [self.tableView reloadData];
}

SUBSCRIBE(SBERangedBeacons) {
    if (event.proximity!=CLProximityUnknown) {
        [values setValue:[NSNumber numberWithInt:event.rssi] forKey:event.beacon.fullUUID];
        [distances setValue:[NSNumber numberWithFloat:event.rssi] forKey:event.beacon.fullUUID];
    }
    //
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"beaconCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    SBMBeacon *beacon = (SBMBeacon*)[items objectAtIndex:indexPath.row];
    
    NSNumber *rssi = [values valueForKey:beacon.fullUUID];
    
    cell.textLabel.text = beacon.uuid;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"major: %i, minor: %i, rssi: %i",beacon.major,beacon.minor,rssi.intValue];
    
    NSNumber *prox = [distances valueForKey:beacon.fullUUID];
    
    NSString *image = @"Proximity-";
    
    switch (prox.intValue) {
        case CLProximityImmediate:
        {
            image = [image stringByAppendingString:@"Immediate"];
            break;
        }
        case CLProximityNear:
        {
            image = [image stringByAppendingString:@"Near"];
            break;
        }
        case CLProximityFar:
        {
            image = [image stringByAppendingString:@"Far"];
            break;
        }
        default:
        {
            image = [image stringByAppendingString:@"Unknown"];
            break;
        }
    }
    //
    cell.imageView.image = [UIImage imageNamed:image];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
