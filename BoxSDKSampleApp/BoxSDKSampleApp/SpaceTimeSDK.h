//
//  SpaceTimeSDK.h
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpaceTimeSDK : NSObject

@property NSURL *url;
@property NSSet *availableFileNames;

+(SpaceTimeSDK *)sharedSDK;
-(void)loadAvailableFiles;
-(void)setURLFromString: (NSString *)urlString;

@end
