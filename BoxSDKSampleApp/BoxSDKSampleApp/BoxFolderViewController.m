//
//  BoxRootViewController.m
//  BoxSDKSampleApp
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <BoxSDK/BoxSDK.h>

#import "BoxFolderViewController.h"

#import "BoxAppDelegate.h"
#import "BoxNavigationController.h"
#import "BoxPreviewViewController.h"
#import "BoxTrashFolderViewController.h"

#import "SpaceTimeSDK.h"


#define TABLE_CELL_REUSE_IDENTIFIER  @"Cell"

@interface BoxFolderViewController ()

- (void)drillDownToFolderID:(NSString *)folderID name:(NSString *)name;
- (void)displayPreviewWebviewWithFileID:(NSString *)fileID filename:(NSString *)filename;
- (void)displayTrashFolder:(id)sender;
- (void)addFolderButtonClicked:(id)sender;
- (void)logoutButtonClicked:(id)sender;

- (void)boxTokensDidRefresh:(NSNotification *)notification;
- (void)boxDidGetLoggedOut:(NSNotification *)notification;

@end

@implementation BoxFolderViewController

@synthesize accessTokenLabel = _accessTokenLabel;
@synthesize refreshTokenLabel = _refreshTokenLabel;
@synthesize logoutButton = _logoutButton;
@synthesize folderItemsArray = _folderItemsArray;
@synthesize totalCount = _totalCount;
@synthesize folderID = _folderID;
@synthesize folderName = _folderName;
@synthesize logos = _logos;
@synthesize spinnerAlert = _spinnerAlert;
@synthesize location = _location;

+ (instancetype)folderViewFromStoryboardWithFolderID:(NSString *)folderID folderName:(NSString *)folderName;
{

    NSString *storyboardName = @"MainStoryboard_iPhone";
    if (IS_IPAD())
    {
        storyboardName = @"MainStoryboard_iPad";
    }

    BoxFolderViewController *folderViewController = (BoxFolderViewController *)[[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:@"FolderTableView"];

    folderViewController.folderID = folderID;
    folderViewController.folderName = folderName;

    return folderViewController;
}

- (void)viewDidLoad
{
    //Load Spinner
    self.spinnerAlert=[[GIDAAlertView alloc] initWithSpinnerWith:@"Fetching Files"];
    [self.spinnerAlert show];
    [self performSelector:@selector(dismissSpinner) withObject:nil afterDelay:3],
    
    self.accessTokenLabel.text = [BoxSDK sharedSDK].OAuth2Session.accessToken;
    self.refreshTokenLabel.text = [BoxSDK sharedSDK].OAuth2Session.refreshToken;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewDidPullToRefresh) forControlEvents:UIControlEventValueChanged];

    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(loadCameraView)];
    self.navigationItem.rightBarButtonItem = uploadButton;
    
    // Handle logged in
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxTokensDidRefresh:)
                                                name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                            object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxTokensDidRefresh:)
                                                name:BoxOAuth2SessionDidRefreshTokensNotification
                                            object:[BoxSDK sharedSDK].OAuth2Session];
    // Handle logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxDidGetLoggedOut:)
                                                name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                            object:[BoxSDK sharedSDK].OAuth2Session];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(boxDidGetLoggedOut:)
                                                name:BoxOAuth2SessionDidReceiveRefreshErrorNotification
                                                object:[BoxSDK sharedSDK].OAuth2Session];

    if (self.folderID == nil)
    {
        self.folderID = BoxAPIFolderIDRoot;
        self.folderName = @"All Files";
    }
    
    if (self.location) {
        self.folderName = self.location.description;
    }

    self.navigationItem.title = self.folderName;
}

-(void)dismissSpinner {
    [self.spinnerAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)boxTokensDidRefresh:(NSNotification *)notification
{
    BoxOAuth2Session *OAuth2Session = (BoxOAuth2Session *)notification.object;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.accessTokenLabel.text = OAuth2Session.accessToken;
        self.refreshTokenLabel.text = OAuth2Session.refreshToken;
        self.logoutButton.title = @"Logout";
    });
}

- (void)boxDidGetLoggedOut:(NSNotification *)notification
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        // clear old folder items
        self.folderItemsArray = [NSMutableArray array];
        [self.tableView reloadData];
        self.accessTokenLabel.text = @"";
        self.refreshTokenLabel.text = @"";
        self.logoutButton.title = @"Login";
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchFolderItemsWithFolderID:self.folderID name:self.folderName];
}

#pragma mark - UITableViewController refresh control
- (void)tableViewDidPullToRefresh
{
    [self fetchFolderItemsWithFolderID:self.folderID name:self.folderName];
}

#pragma mark - UITabableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOXAssert([indexPath row] < self.folderItemsArray.count, @"Table cell requested for row greater than number of items in folder");

    BoxItem *item = (BoxItem *)[self.folderItemsArray objectAtIndex:[indexPath row]];

    UITableViewCell *cell = (UITableViewCell  *)[self.tableView dequeueReusableCellWithIdentifier:TABLE_CELL_REUSE_IDENTIFIER];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLE_CELL_REUSE_IDENTIFIER];
    }
    if ([item.type isEqualToString:BoxAPIItemTypeFolder]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed: @"folder_icon.png"];
    }
    else {
        
        
        NSString *logoString = [self.logos valueForKey:[item.name pathExtension]];
        if (!logoString) {
            logoString = @"default_icon";
        }
        cell.imageView.image = [UIImage imageNamed: logoString];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", item.name]];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![BoxSDK sharedSDK].OAuth2Session.isAuthorized)
    {
        return 0;
    }
    else
    {
        return self.folderItemsArray.count;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *IDToDelete = ((BoxModel *)[self.folderItemsArray objectAtIndex:indexPath.row]).modelID;
        NSString *typeToDelete = ((BoxModel *)[self.folderItemsArray objectAtIndex:indexPath.row]).type;

        BoxSuccessfulDeleteBlock success = ^(NSString *deletedID)
        {
            // refresh folder contents
            [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationItem.title];
        };

        if ([typeToDelete isEqualToString:BoxAPIItemTypeFolder])
        {
            [self.refreshControl beginRefreshing];

            BoxFoldersRequestBuilder * builder = [[BoxFoldersRequestBuilder alloc] initWithRecursiveKey:YES];
            [[BoxSDK sharedSDK].foldersManager deleteFolderWithID:IDToDelete requestBuilder:builder success:success failure:nil];
        }
        else if ([typeToDelete isEqualToString:BoxAPIItemTypeFile])
        {
            [self.refreshControl beginRefreshing];
            [[BoxSDK sharedSDK].filesManager deleteFileWithID:IDToDelete requestBuilder:nil success:success failure:nil];
        }

    }
}

- (void)fetchFolderItemsWithFolderID:(NSString *)folderID name:(NSString *)name
{
    [[SpaceTimeSDK sharedSDK] heartbeat];
    BoxCollectionBlock success = ^(BoxCollection *collection)
    {
        [self.spinnerAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.folderItemsArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < collection.numberOfEntries; i++)
        {
            BoxItem *item = (BoxItem *)[collection modelAtIndex: i];
            if (![[[SpaceTimeSDK sharedSDK] availableFileNamesForLocation: self.location] containsObject: item.name]) {
                continue;
            }
            [self.folderItemsArray addObject: item];
        }
        self.totalCount = [collection.totalCount integerValue];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    };
    BoxAPIJSONFailureBlock failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        NSLog(@"folder items error: %@", error);
    };

    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:folderID requestBuilder:nil success:success failure:failure];
}

- (void)drillDownToFolderID:(NSString *)folderID name:(NSString *)name
{
    BoxFolderViewController *drillDownViewController = [BoxFolderViewController folderViewFromStoryboardWithFolderID:folderID folderName:name];

    [self.navigationController pushViewController:drillDownViewController animated:YES];
}

- (void)displayPreviewWebviewWithFileID:(NSString *)fileID filename:(NSString *)filename
{
    GIDAAlertView *previewSpinner=[[GIDAAlertView alloc] initWithSpinnerWith:@"Loading Preview"];
    [previewSpinner show];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *path = [documentRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", fileID, filename]];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];

    BoxDownloadSuccessBlock successBlock = ^(NSString *downloadedFileID, long long expectedContentLength)
    {
        [previewSpinner dismissWithClickedButtonIndex:0 animated:YES];
        NSLog(@"downloaded file - %@", fileID);
        NSString *blockPath = path;
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:blockPath options:0 error:&error];

        NSString *MIMETypeString;

        // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
        // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[blockPath pathExtension], NULL);
        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        if (!mimeType) {
            MIMETypeString =  @"application/octet-stream";
        }
        else
        {
            MIMETypeString = (__bridge NSString *)mimeType ;
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            BoxPreviewViewController *controller = [[BoxPreviewViewController alloc] initWithFileID:fileID filename:filename parentFolderID:self.folderID data:data MIMEType:MIMETypeString];
            [self.navigationController pushViewController:controller animated:YES];
        });
    };

    BoxDownloadFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        NSLog(@"download error with response code: %i", response.statusCode);
    };

    [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:successBlock failure:failureBlock];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoxItem *item = (BoxItem *)[self.folderItemsArray objectAtIndex:[indexPath row]];

    if ([item.type isEqualToString:BoxAPIItemTypeFolder])
    {
        [self drillDownToFolderID:item.modelID name:item.name];
    }
    else if ([item.type isEqualToString:BoxAPIItemTypeFile])
    {
        [self displayPreviewWebviewWithFileID:item.modelID filename:item.name];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemType = ((BoxItem *)[self.folderItemsArray objectAtIndex:indexPath.row]).type;
    return [itemType isEqualToString:BoxAPIItemTypeFolder] || [itemType isEqualToString:BoxAPIItemTypeFile];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemType = ((BoxModel *)[self.folderItemsArray objectAtIndex:indexPath.row]).type;
    if ([itemType isEqualToString:BoxAPIItemTypeFolder] || [itemType isEqualToString:BoxAPIItemTypeFile])
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Move To Trash";
}

#pragma mark - Navigation Bar Button
- (void)displayTrashFolder:(id)sender
{
    BoxTrashFolderViewController *drillDownViewController = [BoxTrashFolderViewController folderViewFromStoryboardWithFolderID:BoxAPIFolderIDTrash folderName:@"Trash"];

    UINavigationController *modalViewController = [[UINavigationController alloc] initWithRootViewController:drillDownViewController];
    [self presentViewController:modalViewController animated:YES completion:nil];
}

#pragma mark - ImagePicker

-(void)loadCameraView {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    [self presentViewController: imagePicker animated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //Load Location Picker
    if (!self.location) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        SpaceTimeLocationPickerViewController *locationPickerController = [storyboard instantiateViewControllerWithIdentifier:@"SpaceTimeLocationPickerViewController"];
        locationPickerController.selectedImage = image;
        locationPickerController.delegate = self;
        [picker presentViewController: locationPickerController animated:YES completion: nil];
    } else {
        [self uploadImage: image forLocation: self.location];
    }
}

-(void) uploadImage:(UIImage *)image forLocation: (SpaceTimeLocation *)location {
    [self dismissViewControllerAnimated:YES completion:nil];
    BoxFileBlock fileBlock = ^(BoxFile *file)
    {
        [self fetchFolderItemsWithFolderID:self.folderID name:self.navigationController.title];

        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Upload Successful" message:[NSString stringWithFormat:@"File has id: %@", file.modelID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        });
    };

    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        BOXLog(@"status code: %i", response.statusCode);
        BOXLog(@"upload response JSON: %@", JSONDictionary);
    };

    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    
    builder.name = [NSString stringWithFormat: @"image_%.0f.jpg", [[NSDate date] timeIntervalSince1970]];
    builder.parentID = self.folderID;

    NSData *imageData = UIImageJPEGRepresentation(image, .4);
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData: imageData];
    long long contentLength = [imageData length];

    [[BoxSDK sharedSDK].filesManager uploadFileWithInputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:nil];
    [[SpaceTimeSDK sharedSDK] uploadFile:builder.name forLocation: location];
}

#pragma mark - Shake Gesture

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"Reload!");
        [self fetchFolderItemsWithFolderID:self.folderID name:self.folderName];
        [self.tableView reloadData];
    }
}

-(NSDictionary *)logos {
    if (!_logos)
        _logos = [[NSDictionary alloc] initWithObjectsAndKeys: @"pdf_icon", @"pdf", @"jpg_icon.gif", @"jpg", nil];
    return _logos;
    
}

@end
