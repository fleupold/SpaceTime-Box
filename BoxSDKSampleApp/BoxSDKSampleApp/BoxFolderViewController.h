//
//  BoxRootViewController.h
//  BoxSDKSampleApp
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpaceTimeLocationPickerViewController.h"
#import "SpaceTimeLocation.h"
#import "GIDAAlertView.h"

#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface BoxFolderViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SpaceTimeLocationPickerDelegate>

@property (nonatomic, readwrite, strong) IBOutlet UILabel *accessTokenLabel;
@property (nonatomic, readwrite, strong) IBOutlet UILabel *refreshTokenLabel;
@property (nonatomic, readwrite, strong) UIBarButtonItem *logoutButton;
@property (nonatomic, readwrite, strong) NSMutableArray *folderItemsArray;
@property (nonatomic, readwrite, assign) NSInteger totalCount;
@property (nonatomic, readwrite, strong) NSString *folderID;
@property (nonatomic, readwrite, strong) NSString *folderName;
@property NSDictionary *logos;
@property GIDAAlertView *spinnerAlert;
@property SpaceTimeLocation *location;

+ (instancetype)folderViewFromStoryboardWithFolderID:(NSString *)folderID folderName:(NSString *)folderName;

- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name;
- (void)tableViewDidPullToRefresh;

@end
