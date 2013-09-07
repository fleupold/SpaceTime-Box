//
//  SpaceTimeFile.h
//  SpaceTime
//
//  Created by Felix Leupold on 9/7/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpaceTimeFile : NSString
@property NSInteger location;
@property NSString *filename;
-(id)initWithString:(NSString *)aString;
- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;
@end
