//
//  NSDictionary+FromJSONFile.h
//  PubCrawlLDN
//
//  Created by Daniel Hough on 08/04/2014.
//  Copyright (c) 2014 LondonPubCrawl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FromJSONFile)

+ (NSDictionary *)dictionaryWithContentsOfJSONFile:(NSString *)path;

@end
