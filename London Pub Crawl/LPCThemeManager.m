//
//  LPCThemeManager.m
//  London Pub Crawl
//
//  Created by Daniel Hough on 15/10/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import "LPCThemeManager.h"

@implementation LPCThemeManager

static NSDictionary *colours = nil;

+ (UIColor *)colourForLine:(NSString *)line {
//    if ([line isEqualToString:@"B"]) {
//        return [UIColor colorWithRed:137 green:78 blue:36 alpha:1.0];
//    } else if ([line isEqualToString:@"C"]) {
//        return [UIColor colorWithRed:255 green:206 blue:0 alpha:1.0];
//    }
    if (colours == nil) {
        NSArray *lines = @[@"B",@"C",@"D",@"H",@"J",@"M",@"N",@"P",@"V",@"W"];
        NSArray *rgbValues = @[
                               [UIColor colorWithRed:137.0f/255.0f green:78.0f/255.0f blue:36.0f/255.0f alpha:1.0],
                               [UIColor colorWithRed:255.0f/255.0f green:206.0f/255.0f blue:0.0f alpha:1.0],
                               [UIColor colorWithRed:0 green:114/255.0f blue:41/255.0f alpha:1.0],
                               [UIColor colorWithRed:215/255.0f green:153/255.0f blue:175/255.0f alpha:1.0],
                               [UIColor colorWithRed:134/255.0f green:143/255.0f blue:152/255.0f alpha:1.0],
                               [UIColor colorWithRed:117/255.0f green:16/255.0f blue:86/255.0f alpha:1.0],
                               [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0],
                               [UIColor colorWithRed:0 green:25/255.0f blue:168/255.0f alpha:1.0],
                               [UIColor colorWithRed:0 green:160/255.0f blue:226/255.0f alpha:1.0],
                               [UIColor colorWithRed:118/255.0f green:208/255.0f blue:189/255.0f alpha:1.0]
                               ];
        colours = [[NSDictionary alloc] initWithObjects:rgbValues forKeys:lines];
    }
    return [colours valueForKey:line];
}

@end
