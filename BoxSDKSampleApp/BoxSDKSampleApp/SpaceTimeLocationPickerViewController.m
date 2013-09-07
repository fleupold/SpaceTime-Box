//
//  SpaceTimeLocationPickerViewController.m
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimeLocationPickerViewController.h"
#import "SpaceTimeSDK.h"

@interface SpaceTimeLocationPickerViewController ()

@end

@implementation SpaceTimeLocationPickerViewController
@synthesize locations, selectedLocation, selectedImage, delegate, tableView;

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
    self.locations = [SpaceTimeSDK sharedSDK].locations;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.navigationItem setTitle: @"Select location for File"];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpaceTimeLocation *location = [self.locations objectAtIndex: indexPath.row];
    UITableViewCell *cell = (UITableViewCell  *)[self.tableView dequeueReusableCellWithIdentifier:@"LOCATION_CELL_IDENTIFIER"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LOCATION_CELL_IDENTIFIER"];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", location.description]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate uploadImage:self.selectedImage forLocation: [self.locations objectAtIndex: indexPath.row]];
}


@end
