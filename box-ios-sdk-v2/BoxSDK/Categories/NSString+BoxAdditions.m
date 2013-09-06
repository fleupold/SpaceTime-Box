//
//  NSString+BoxAdditions.m
//  BoxSDK
//
//  Created on 6/3/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

long long const BOX_KILOBYTE = 1024;
long long const BOX_MEGABYTE = BOX_KILOBYTE * 1024;
long long const BOX_GIGABYTE = BOX_MEGABYTE * 1024;
long long const BOX_TERABYTE = BOX_GIGABYTE * 1024;

#import "NSString+BoxAdditions.h"

@implementation NSString (BoxAdditions)

+ (NSString *)humanReadableStringForByteSize:(NSNumber *)size
{
    NSString * result_str = nil;
	long long fileSize = [size longLongValue];
    
    if (fileSize >= BOX_TERABYTE) 
    {
        double dSize = fileSize / (double)BOX_TERABYTE;
		result_str = [NSString stringWithFormat:@"%1.1f TB", dSize];
    }
	else if (fileSize >= BOX_GIGABYTE)
	{
		double dSize = fileSize / (double)BOX_GIGABYTE;
		result_str = [NSString stringWithFormat:@"%1.1f GB", dSize];
	}
	else if (fileSize >= BOX_MEGABYTE)
	{
		double dSize = fileSize / (double)BOX_MEGABYTE;
		result_str = [NSString stringWithFormat:@"%1.1f MB", dSize];
	}
	else if (fileSize >= BOX_KILOBYTE)
	{
		double dSize = fileSize / (double)BOX_KILOBYTE;
		result_str = [NSString stringWithFormat:@"%1.1f KB", dSize];
	}
    else if(fileSize > 0)
    {
        result_str = [NSString stringWithFormat:@"%lld B", fileSize];
    }
	else
	{
		result_str = @"Empty";
	}
    
    return result_str;
}

@end
