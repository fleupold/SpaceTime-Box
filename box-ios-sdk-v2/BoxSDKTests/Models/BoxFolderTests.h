//
//  BoxFolderTests.h
//  BoxSDK
//
//  Created on 3/18/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "BoxFolder.h"

@interface BoxFolderTests : SenTestCase
{
    NSDictionary *JSONDictionaryFull;
    NSDictionary *JSONDictionaryMini;
    BoxFolder *folder;
    BoxFolder *miniFolder;
}

@end
