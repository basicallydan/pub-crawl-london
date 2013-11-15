//
//  LPCLine.h
//  London Pub Crawl
//
//  Created by Daniel Hough on 14/11/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPCLine : NSObject

@property (strong, nonatomic) NSArray *leafStations;
@property (strong, nonatomic) NSArray *allStations;

- (id)initWithLine:(NSDictionary *)line;

@end
