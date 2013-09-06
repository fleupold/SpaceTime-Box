//
//  SpaceTimeSDK.m
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimeSDK.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "SpaceTimeMacAdressFinder.h"

@implementation SpaceTimeSDK
@synthesize url, locations, client;

static SpaceTimeSDK *instance;

+(SpaceTimeSDK *)sharedSDK {
    if(!instance) {
        instance = [[SpaceTimeSDK alloc] init];
        [instance heartbeat];
    }
    return instance;
}

- (void)setURLFromString: (NSString *)urlString {
    self.url =  [NSURL URLWithString: urlString];
    self.client = [AFHTTPClient clientWithBaseURL: self.url];
}

-(void)heartbeat {
    [self loadAvailableFiles];
    [self loadLocations];
    [self performSelector:@selector(heartbeat) withObject:nil afterDelay:3];
}

-(void)loadAvailableFiles
{
    void (^failure)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"SpaceTimeSDK Failure %@", [error localizedDescription]);
    };
    
    void (^success)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Content: %@", [JSON description]);
        NSMutableSet *filenames = [NSMutableSet set];
        for (NSString *filename in [JSON valueForKey: @"files"]) {
            [filenames addObject: filename];
        }
        self.availableFileNames = [NSSet setWithSet: filenames];
    };

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[SpaceTimeMacAdressFinder getMacAddress] forKey:@"macaddress"];
    NSURLRequest *request = [self.client requestWithMethod:@"GET" path:@"availableFiles" parameters:parameters];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success: success failure: failure];
    
    [operation start];
}

-(void)loadLocations
{
    void (^failure)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"SpaceTimeSDK Failure %@", [error localizedDescription]);
    };
    
    void (^success)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Content: %@", [JSON description]);
        self.locations = [NSMutableArray array];
        for (NSString *location in [JSON valueForKey: @"location"]) {
            [self.locations addObject: [SpaceTimeLocation locationFromJSON: location]];
        }
    };
    
    NSURL *locationsURL = [NSURL URLWithString: @"location" relativeToURL:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL: locationsURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success: success failure: failure];
    
    [operation start];
}

-(void)uploadFile: (NSString *)filename forLocation: (SpaceTimeLocation *)location {
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"SpaceTimeSDK Failure %@", [error localizedDescription]);
    };
    
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SpaceTimeSDK Successfully registered file %@ for location %@", filename, location.description);
    };
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: filename, @"filename", location.id, @"location", nil];
    NSURLRequest *request = [self.client requestWithMethod:@"GET" path:@"upload" parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    [operation setCompletionBlockWithSuccess: success failure:failure];
    [operation start];
}




@end
