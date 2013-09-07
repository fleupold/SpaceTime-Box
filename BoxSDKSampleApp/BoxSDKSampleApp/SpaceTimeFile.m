//
//  SpaceTimeFile.m
//  SpaceTime
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "SpaceTimeFile.h"

@implementation SpaceTimeFile
@synthesize location, filename;

-(id)initWithString:(NSString *)aString {
    self = [self init];
    self.filename = aString;
    return self;
}
- (unichar)characterAtIndex:(NSUInteger)index {
    return [self.filename characterAtIndex:index];
}
- (NSUInteger)length {
    return self.filename.length;
}


@end
