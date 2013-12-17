//
//  LPCVenueRetrievalHandlerTests.m
//  London Pub Crawl
//
//  Created by Daniel Hough on 17/12/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LPCLine.h"
#import "LPCVenueRetrievalHandler.h"

@interface LPCVenueRetrievalHandlerTests : XCTestCase

@end

@implementation LPCVenueRetrievalHandlerTests

LPCLine *line;
NSDictionary *fakeNorthernLineDictionary;

NSDictionary *stationDictionary;

- (void)setUp
{
    [super setUp];
    stationDictionary =
    @{
      @"mornington-crescent": @{
              @"code": @"MTC",
              @"lat": @"51.53468",
              @"lng": @"-0.13878",
              @"name": @"Mornington Crescent",
              @"nestoria_code": @"mornington-crescent"
              },
      @"euston": @{
              @"code": @"EUS",
              @"lat": @"51.528",
              @"lng": @"-0.13378",
              @"name": @"Euston",
              @"nestoria_code": @"euston"
              },
      @"oval": @{
              @"code": @"OVL",
              @"lat": @"51.48185",
              @"lng": @"-0.11243",
              @"name": @"Oval",
              @"nestoria_code": @"oval"
              }
      };
    fakeNorthernLineDictionary =
    @{
      @"background-color": @"#000000",
      @"text-color": @"#ffffff",
      @"name": @"Northern",
      @"top-direction":@"Northbound",
      @"bottom-direction":@"Southbound",
      @"stations": @[
              @"mornington-crescent",
              @"euston",
              @"oval"
              ]
      };
    line = [[LPCLine alloc] initWithLine:fakeNorthernLineDictionary andStations:stationDictionary];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatARetrievalCallWillOnlyReturnVenuesInTheCompletionBlock
{
    LPCStation *station = [line stationWithCode:@"oval"];
    LPCVenueRetrievalHandler *handler = [LPCVenueRetrievalHandler sharedHandler];
    
    __block BOOL waitingForBlock = YES;
    
    NSArray *venues = [handler venuesForStation:station completion:^(NSArray *venues) {
        waitingForBlock = NO;
        XCTAssertTrue([venues count] > 0, @"There should be some venues in the completion block");
    }];
    
    XCTAssertNil(venues, @"No venues should be returned on the first run");
    
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    NSArray *venuesAfterFirstSearch = [handler venuesForStation:station completion:nil];
    
    XCTAssertNotNil(venuesAfterFirstSearch, @"An array of venues should be returned on the second run");
    XCTAssertTrue([venuesAfterFirstSearch count] > 0, @"There should be some venues in the completion block");
}


@end
