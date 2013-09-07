//
//  SpaceTimePlaceViewController.m
//  SpaceTime
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimePlaceViewController.h"
#import "SpaceTimeLocation.h"
#import "SpaceTimeSDK.h"

#import "BoxFolderViewController.h"
#import "BoxNavigationController.h"

@interface SpaceTimePlaceViewController ()

@end

@implementation SpaceTimePlaceViewController
@synthesize buttonLocationMapping;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.buttonLocationMapping = [NSMutableDictionary dictionary];
	// Do any additional setup after loading the view.
    
    for (SpaceTimeLocation *location in [[SpaceTimeSDK sharedSDK] locations]) {
        UIButton *locationMarker = [UIButton buttonWithType: UIButtonTypeCustom];
        if (location.is_visited) {
            [locationMarker setImage: [UIImage imageNamed: @"marker_green"] forState:UIControlStateNormal];
        } else {
            [locationMarker setImage: [UIImage imageNamed: @"marker_red"] forState:UIControlStateNormal];
        }
        [locationMarker addTarget: self action:@selector(markerPressed:) forControlEvents:UIControlEventTouchUpInside];
        locationMarker.frame = CGRectMake(location.coordinate.x, location.coordinate.y, 32, 48);
        [self.view addSubview: locationMarker];
        locationMarker.tag = location.location_id;
        [self.buttonLocationMapping setValue:location forKey: [NSString stringWithFormat: @"%d", locationMarker.tag]];
    }
    
}

-(void)markerPressed: (UIButton *)button {
    SpaceTimeLocation *location = [self.buttonLocationMapping objectForKey: [NSString stringWithFormat: @"%d", button.tag]];
    if (location.is_visited) {
        BoxFolderViewController *boxFolderVC = [[BoxFolderViewController alloc] init];
        boxFolderVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissBoxVC)];
        boxFolderVC.location = location;
        BoxNavigationController *boxNavVC = [[BoxNavigationController alloc] initWithRootViewController:boxFolderVC];
        [self presentViewController:boxNavVC animated:YES completion:nil];
    } else {
        NSString *message = [NSString stringWithFormat:@"You haven't been at %@ yet", location.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location locked" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)dismissBoxVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
