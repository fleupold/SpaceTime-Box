//
//  BoxFile.m
//  BoxSDK
//
//  Created on 3/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFile.h"

#import "BoxLog.h"
#import "BoxSDKConstants.h"

@implementation BoxFile

- (NSString *)SHA1
{
    return [NSJSONSerialization ensureObjectForKey:BoxAPIObjectKeySHA1
                                      inDictionary:self.rawResponseJSON
                                   hasExpectedType:[NSString class]
                                       nullAllowed:NO];
}

@end
