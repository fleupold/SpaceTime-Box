//
//  SpaceTimeSDK.m
//  BoxSDKSampleApp
//
//  Created by Felix Leupold on 9/6/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimeSDK.h"
#import "AFJSONRequestOperation.h"

@implementation SpaceTimeSDK
@synthesize url;

static SpaceTimeSDK *instance;

+(SpaceTimeSDK *)sharedSDK {
    if(!instance) {
        instance = [[SpaceTimeSDK alloc] init];
    }
    return instance;
}

- (void)setURLFromString: (NSString *)urlString {
    self.url =  [NSURL URLWithString: urlString];
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

    NSURL *availableFilesURL = [NSURL URLWithString: @"availableFiles" relativeToURL:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL: availableFilesURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success: success failure: failure];
    
    [operation start];
}

@end
