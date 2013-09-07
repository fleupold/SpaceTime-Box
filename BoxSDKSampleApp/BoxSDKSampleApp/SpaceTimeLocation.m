//
//  SpaceTimeLocation.m
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimeLocation.h"

@implementation SpaceTimeLocation
@synthesize location_id, description, coordinate;

+(SpaceTimeLocation *)locationFromJSON: (id)JSON {
    SpaceTimeLocation *location = [[SpaceTimeLocation alloc] init];
    location.location_id = [[JSON objectForKey: @"id"] integerValue];
    location.description = [JSON objectForKey: @"description"];
    location.is_visited = [[JSON objectForKey: @"is_visited"] boolValue];
    
    switch (location.location_id) {
        case 1:
            location.coordinate = CGPointMake(60, 60);
            break;
        case 2:
            location.coordinate = CGPointMake(60, 360);
            break;
        case 3:
            location.coordinate = CGPointMake(200, 330);
        default:
            break;
    }
    
    return location;
}


@end
