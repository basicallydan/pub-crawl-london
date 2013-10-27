//
//  LPCCircleView.m
//  London Pub Crawl
//
//  Created by Daniel Hough on 27/10/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import "LPCCircleView.h"

@implementation LPCCircleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGRect borderRect = CGRectMake(3.5f, 3.5f, 29.0f, 29.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 3.5f);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}



@end
