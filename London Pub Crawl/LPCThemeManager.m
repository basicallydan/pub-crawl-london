//
//  LPCThemeManager.m
//  London Pub Crawl
//
//  Created by Daniel Hough on 15/10/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import "LPCThemeManager.h"

@implementation LPCThemeManager

+ (UIImage *)tubeLineForkWithColor:(UIColor *)color {
    UIImage *image = [UIImage imageNamed:@"tube-line-fork-central-line"];
    
    return [self recolorImage:image withColor:color];
}

+ (UIImage *)recolorImage:(UIImage *)image withColor:(UIColor *)color {
    CGRect rect;
    
    if ([UIScreen mainScreen].scale == 2.0) {
        rect = CGRectMake(0, 0, image.size.width * 2, image.size.height * 2);
    } else {
        rect = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;
}

@end
