//
//  NSDictionary+FromJSONFile.m
//  PubCrawlLDN
//
//  Created by Daniel Hough on 08/04/2014.
//  Copyright (c) 2014 LondonPubCrawl. All rights reserved.
//

#import "NSDictionary+FromJSONFile.h"

@implementation NSDictionary (FromJSONFile)

+ (id)dictionaryWithContentsOfJSONFile:(NSString *)path {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension] ofType:[path pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    // Be careful here. You add this as a category to NSDictionary
    // but you get an id back, which means that result
    // might be an NSArray as well!
    if (error != nil) return nil;
    return result;
}

@end
