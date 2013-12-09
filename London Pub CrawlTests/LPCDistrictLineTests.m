#import <XCTest/XCTest.h>

#import "LPCLine.h"

@interface LPCDistrictLineTests : XCTestCase

@end

@implementation LPCDistrictLineTests

LPCLine *line;
NSDictionary *fakeDistrictLineDictionary;

NSDictionary *stationDictionary;

- (void)setUp
{
    [super setUp];
    stationDictionary =
    @{
      @"edgware": @{
              @"code": @"EGW",
              @"lat": @"51.61365",
              @"lng": @"-0.27493",
              @"name": @"Edgware",
              @"nestoria_code": @"edgware"
              },
      @"colindale": @{
              @"code": @"CND",
              @"lat": @"51.59543",
              @"lng": @"-0.24992",
              @"name": @"Colindale",
              @"nestoria_code": @"colindale"
              },
      @"high-barnet": @{
              @"code": @"HBT",
              @"lat": @"51.65054",
              @"lng": @"-0.19429",
              @"name": @"High Barnet",
              @"nestoria_code": @"high-barnet"
              },
      @"woodside-park": @{
              @"code": @"WOP",
              @"lat": @"51.61802",
              @"lng": @"-0.18542",
              @"name": @"Woodside Park",
              @"nestoria_code": @"woodside-park"
              },
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
      @"bank": @{
              @"code": @"BNK",
              @"lat": @"51.51342",
              @"lng": @"-0.08895",
              @"name": @"Bank",
              @"nestoria_code": @"bank"
              },
      @"moorgate": @{
              @"code": @"MGT",
              @"lat": @"51.51818",
              @"lng": @"-0.08832",
              @"name": @"Moorgate",
              @"nestoria_code": @"moorgate"
              },
      @"london-bridge": @{
              @"code": @"LNB",
              @"lat": @"51.50573",
              @"lng": @"-0.08887",
              @"name": @"London Bridge",
              @"nestoria_code": @"london-bridge"
              },
      @"charing-cross": @{
              @"code": @"CHX",
              @"lat": @"51.50741",
              @"lng": @"-0.12727",
              @"name": @"Charing Cross",
              @"nestoria_code": @"charing-cross"
              },
      @"leicester-square": @{
              @"code": @"LSQ",
              @"lat": @"51.51139",
              @"lng": @"-0.12842",
              @"name": @"Leicester Square",
              @"nestoria_code": @"leicester-square"
              },
      @"embankment": @{
              @"code": @"EMB",
              @"lat": @"51.50706",
              @"lng": @"-0.12266",
              @"name": @"Embankment",
              @"nestoria_code": @"embankment"
              },
      @"kennington": @{
              @"code": @"KNG",
              @"lat": @"51.48834",
              @"lng": @"-0.10596",
              @"name": @"Kennington",
              @"nestoria_code": @"kennington"
              },
      @"oval": @{
              @"code": @"OVL",
              @"lat": @"51.48185",
              @"lng": @"-0.11243",
              @"name": @"Oval",
              @"nestoria_code": @"oval"
              }
      };
    fakeDistrictLineDictionary =
    @{
      @"background-color": @"#000000",
      @"text-color": @"#ffffff",
      @"name": @"District",
      @"top-direction":@"Fake District",
      @"bottom-direction":@"Eastbound",
      @"stations": @[
              @"edgware",
              @"colindale",
              @{
                  @"high-barnet": @[
                      @"high-barnet",
                      @"woodside-park"
                  ],
                  @"_parent": @{ @"direction" : @"top" }
              },
              @"euston",
              @{
                  @"london-bridge" : @[
                      @"moorgate",
                      @"bank",
                      @"london-bridge"
                  ],
                  @"_parent" : @{ @"direction" : @"bottom" }
                  },
              @"kennington",
              @"oval"
      ]
      };
    line = [[LPCLine alloc] initWithLine:fakeDistrictLineDictionary andStations:stationDictionary];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLineContainsCorrectNumberOfStations {
    //    XCTAssertEqualObjects([line.allStations count], 14);
    XCTAssertEqual([line.allStations count], 10U);
}

- (void)testThatFirstStationOnHighBarnetBranchAfterColindaleIsCorrect {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 1;
    LPCFork *fork = [line forkAfterPosition:position];
    XCTAssertEqual(fork.direction, Left, @"The fork after London Bridge on the Bank Branch should be pointing left");
    XCTAssertEqual([fork firstStationForDestination:1].nestoriaCode, @"woodside-park", "The first station on the top branch should be Woodside Park");
}

- (void)testThatThereAreNoForksBeforeHighBarnetOnTheHighBarnetBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 2;
    position.branchCode = @"high-barnet";
    position.branchLineIndex = 0;
    XCTAssertFalse([line isForkBeforePosition:position], @"There should be no fork before High Barnet");
}

- (void)testThatThereAreNoForksAfterHighBarnetOnTheHighBarnetBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 2;
    position.branchCode = @"high-barnet";
    position.branchLineIndex = 0;
    XCTAssertFalse([line isForkAfterPosition:position], @"There should be no fork after High Barnet");
}

@end
