//
//  SpaceTimeSDK.h
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpaceTimeLocation.h"
#import "AFHTTPClient.h"

@interface SpaceTimeSDK : NSObject

@property NSURL *url;
@property NSSet *availableFileNames;
@property NSMutableArray *locations;
@property AFHTTPClient *client;

+(SpaceTimeSDK *)sharedSDK;
-(void)loadAvailableFiles;
-(void)loadLocations;
-(void)uploadFile: (NSString *)filename forLocation: (SpaceTimeLocation *)location;
-(void)setURLFromString: (NSString *)urlString;

@end
