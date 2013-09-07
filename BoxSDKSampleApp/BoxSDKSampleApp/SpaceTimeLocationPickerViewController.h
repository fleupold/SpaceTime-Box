//
//  SpaceTimeLocationPickerViewController.h
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpaceTimeLocation.h"

@protocol SpaceTimeLocationPickerDelegate <NSObject>
@required
-(void) uploadImage:(UIImage *)image forLocation: (SpaceTimeLocation *)location;
@end

@interface SpaceTimeLocationPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSArray *locations;
@property SpaceTimeLocation *selectedLocation;
@property UIImage *selectedImage;
@property id<SpaceTimeLocationPickerDelegate> delegate;
@property IBOutlet UITableView *tableView;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
