//
//  SBSDKRootViewController.m
//  SensorbergSDK
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

#import "SBSDKRootViewController.h"

#import "SBSDKDetectedBeaconsViewController.h"
#import "SBSDKStatusTableViewController.h"

@implementation SBSDKRootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.demos = @[ @[ @"Detected Beacons" ],
                    @[ @"Status" ] ];
}

#pragma mark - Tableview data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.demos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.demos[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Demos";

        case 1:
            return @"Miscellaneous";

        default:
            break;
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];

    cell.textLabel.text = [self.demos[indexPath.section] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                        [self performSegueWithIdentifier:@"detectedBeaconsSegue" sender:self];
                    }

                    break;
                    
                default:
                    break;
            }

            break;

        case 1:
            switch (indexPath.row) {
                case 0: {
                    [self performSegueWithIdentifier:@"statusSegue" sender:self];
                }

                    break;

                default:
                    break;
            }

            break;

        default:
            break;
    }
}

@end
