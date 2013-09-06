//
//  SpaceTimeLocation.m
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimeLocation.h"

@implementation SpaceTimeLocation
@synthesize id, description;

+(SpaceTimeLocation *)locationFromJSON: (id)JSON {
    SpaceTimeLocation *location = [[SpaceTimeLocation alloc] init];
    location.id = (NSInteger)[JSON objectForKey: @"id"];
    location.description = [JSON objectForKey: @"description"];
    return location;
}


@end
