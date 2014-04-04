//
//  LPCOptionsCell.m
//  London Pub Crawl
//
//  Created by Daniel Hough on 06/01/2014.
//  Copyright (c) 2014 LondonPubCrawl. All rights reserved.
//

#import "LPCOptionsCell.h"

@implementation LPCOptionsCell

- (IBAction)happilyButtonClicked:(id)sender {
    [self.delegate happilyButtonClicked];
}

- (IBAction)helpButtonClicked:(id)sender {
    [self.delegate helpButtonClicked];
}
@end
