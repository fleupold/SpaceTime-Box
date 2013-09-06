//
//  SpaceTimeLocation.h
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpaceTimeLocation : NSObject
@property NSInteger id;
@property NSString *description;

+(SpaceTimeLocation *)locationFromJSON: (id)JSON;
@end
