//
//  LPCBuyView.m
//  PubCrawlLDN
//
//  Created by Daniel Hough on 03/04/2014.
//  Copyright (c) 2014 LondonPubCrawl. All rights reserved.
//

#import "LPCBuyLineView.h"

@implementation LPCBuyLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setLine:(LPCLine *)line {
    _line = line;
    [self.lineNameLabel setText:[NSString stringWithFormat:@"%@ Line", line.name]];
}

- (void)buyAllButtonPressed:(id)sender {
    [self.delegate didChooseToBuyAll];
}

- (void)buyLineButtonPressed:(id)sender {
    [self.delegate didChooseToBuyLine:self.line];
}

@end
