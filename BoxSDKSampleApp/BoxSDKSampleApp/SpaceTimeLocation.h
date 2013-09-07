//
//  SpaceTimeLocation.h
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpaceTimeLocation : NSObject
@property NSInteger location_id;
@property NSString *description;
@property BOOL is_visited;
@property CGPoint coordinate;

+(SpaceTimeLocation *)locationFromJSON: (id)JSON;
@end
