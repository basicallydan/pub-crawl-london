//
//  LPCAppDelegate.h
//  London Pub Crawl
//
//  Created by Dan on 15/10/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *lines;
@property (strong, nonatomic) NSDictionary *stationOrdersForLines;
@property (strong, nonatomic) NSDictionary *stationCoordinates;
@property (strong, nonatomic) NSDictionary *stations;
@property (strong, nonatomic) NSArray *linesArray;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
