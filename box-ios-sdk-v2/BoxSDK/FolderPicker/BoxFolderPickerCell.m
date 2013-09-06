//
//  BoxFolderPickerCell.m
//  BoxSDK
//
//  Created on 5/30/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "UIImage+BoxAdditions.h"
#import "NSString+BoxAdditions.h"

#import "BoxFolderPickerCell.h"
#import "BoxItem.h"
#import "BoxFolder.h"
#import "BoxFolderPickerHelper.h"
#import "BoxSDK.h"

#import <QuartzCore/QuartzCore.h>

#define kCellHeight 58.0

#define kImageViewOffsetX 12.0
#define kImageViewSide 40.0

#define kImageToLabelOffsetX 12.0
#define kNameStringOriginY 11.0
#define kNameStringHeight 20.0

#define kPaddingNameDescription 20.0
#define kDisclosureIndicatorOriginY 23.0

#define kDisabledAlpha 0.3

// @NOTE: This enum was renamed in iOS 6
#ifdef __IPHONE_6_0
#   define BOX_LINE_BREAK_MODE (NSLineBreakByTruncatingMiddle)
#else
#   define BOX_LINE_BREAK_MODE (UILineBreakModeMiddleTruncation)
#endif

@interface BoxFolderPickerCell ()

@property (nonatomic, readwrite, strong) UIImageView *thumbnailImageView;

@end

@implementation BoxFolderPickerCell

@synthesize helper = _helper;
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize item = _item;
@synthesize cachePath = _cachePath;
@synthesize showThumbnails;
@synthesize enabled = _enabled;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect r = CGRectMake(0, 0, kImageViewSide, kImageViewSide);
        r.origin.y = (kCellHeight / 2) - (kImageViewSide / 2) -1;
        r.origin.x = kImageViewOffsetX;
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:r];
        
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_thumbnailImageView];
    }
    return self;
}

- (void)setItem:(BoxItem *)item
{
    if (item == nil || self.item == item) {
        return ;
    }
    
    _item = item;
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect r;
    
    if (self.selected || self.isHighlighted) {
         CGContextRef context = UIGraphicsGetCurrentContext();      
        
        r.origin.y = rect.size.height ;
        CGContextSetRGBFillColor(context, 250.0f/255.0f, 250.0f/255.0f, 250.0f/255.0f, 1);
        CGContextFillRect(context, r);
        
        CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 1.0 };
        
        // step 1, step 2 - start by drawing top gradient, light to dark, draw it after the end location
        
        // can we replace rect.size.width / 2 with 0?
        CGPoint startPoint = CGPointMake(rect.size.width / 2, 0);
        CGPoint endPoint = CGPointMake(rect.size.width / 2, 3);
        
        CGFloat topGradientComponents[8] = {205.0f/255.0f, 205.0f/255.0f, 205.0f/255.0f, 1, 218.0f/255.0f, 218.0f/255.0f, 218.0f/255.0f, 1};
        CGGradientRef topGradient = CGGradientCreateWithColorComponents(rgbColorspace, topGradientComponents, locations, num_locations);
        CGContextDrawLinearGradient(context, topGradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
        
        // step 2 - bottom gradient, light to dark
        startPoint = CGPointMake(rect.size.width / 2, rect.size.height - 4);
        endPoint = CGPointMake(rect.size.width / 2, rect.size.height - 1);
        
        CGFloat bottomGradientComponents[8] = {218.0f/255.0f, 218.0f/255.0f, 218.0f/255.0f, 1, 205.0f/255.0f, 205.0f/255.0f, 205.0f/255.0f, 1};
        CGGradientRef bottomGradient = CGGradientCreateWithColorComponents(rgbColorspace, bottomGradientComponents, locations, num_locations);
        CGContextDrawLinearGradient(context, bottomGradient, startPoint, endPoint, 0);
        
        // release all allocations
        CGGradientRelease(topGradient);    
        CGGradientRelease(bottomGradient);
        CGColorSpaceRelease(rgbColorspace);
    }
    
    r = self.thumbnailImageView.frame;
    
    NSString *cachedThumbnailPath = [self.cachePath stringByAppendingPathComponent:self.item.modelID];
    
    [self.helper itemNeedsAPICall:self.item cachePath:cachedThumbnailPath completion:^(BOOL needsAPICall, UIImage *cachedImage) {
        
        self.thumbnailImageView.image = cachedImage;
        
        // Checking if we need to download the thumbnail for the current item 
        if ([self.helper shouldDiplayThumbnailForItem:self.item] && needsAPICall && showThumbnails) {
            __block BoxFolderPickerCell *cell = self;
            __block BoxItem *currentItem = self.item;
            
            [self.helper thumbnailForItem:self.item cachePath:self.cachePath refreshed:^(UIImage *image) {
                if (image && cell.item == currentItem) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.thumbnailImageView setImage:image];
                        
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        
                        [cell.thumbnailImageView.layer addAnimation:transition forKey:nil];
                    });
                }
            }];
        }
    }];
    
    // Drawing name label
    if (self.item.name) {
        // Positionnning the name label by offset from the image
        r.origin.x += kImageViewSide + kImageToLabelOffsetX;
        r.origin.y += 4.0;
        r.size.height = kNameStringHeight;
        r.size.width = rect.size.width - kImageToLabelOffsetX - kImageViewSide - kImageViewOffsetX - 24.0;
        
        [[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:self.enabled ? 1.0 : kDisabledAlpha] set];
        [self.item.name drawInRect:r withFont:[UIFont boldSystemFontOfSize:16.0] lineBreakMode:BOX_LINE_BREAK_MODE];
    }
    
    r.origin.y += kPaddingNameDescription;
    
    NSString * desc = [NSString stringWithFormat:@"%@ - Last update : %@", [NSString humanReadableStringForByteSize:self.item.size], [self.helper dateStringForItem:self.item]];
    
    if(desc){
        [[UIColor colorWithRed:174.0f/255.0f green:174.0f/255.0f blue:174.0f/255.0f alpha:self.enabled ? 1.0 : kDisabledAlpha] set];
        [desc drawInRect:r withFont:[UIFont boldSystemFontOfSize:12.0] lineBreakMode:BOX_LINE_BREAK_MODE];
    }
    
    // If the item is a folder, draw the disclosure indicator
    if ([self.item isKindOfClass:[BoxFolder class]]) {
        r.origin.x = rect.size.width - 15;
        r.origin.y = kDisclosureIndicatorOriginY;
        
        [[UIImage  imageFromBoxSDKResourcesBundleWithName:@"icon-disclosure"] drawAtPoint:r.origin];
    }
    
    self.thumbnailImageView.alpha = self.enabled ? 1.0 : kDisabledAlpha;
}

@end
