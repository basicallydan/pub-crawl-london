#import <XCTest/XCTest.h>

#import "LPCLine.h"

@interface LPCLineTests : XCTestCase

@end

@implementation LPCLineTests

LPCLine *line;
NSDictionary *lineDictionary;

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
    lineDictionary =
    @{
        @"background-color": @"#000000",
        @"text-color": @"#ffffff",
        @"name": @"Northern",
        @"top-direction":@"Northbound",
        @"bottom-direction":@"Southbound",
        @"stations": @[
            @{
                @"edgware" : @[
                    @"edgware",
                    @"colindale"
                ],
                @"high-barnet": @[
                    @"high-barnet",
                    @"woodside-park"
                ]
            },
            @"mornington-crescent",
            @"euston",
            @{
                @"bank" : @[
                    @"moorgate",
                    @"bank",
                    @"london-bridge"
                ],
                @"charing-cross" : @[
                    @"leicester-square",
                    @"charing-cross",
                    @"embankment"
                ]
            },
            @"kennington",
            @"oval"
        ]
    };
    line = [[LPCLine alloc] initWithLine:lineDictionary andStations:stationDictionary];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLineContainsCorrectNumberOfStations {
//    XCTAssertEqualObjects([line.allStations count], 14);
    XCTAssertEqual([line.allStations count], 14U);
}

- (void)testForForkBeforeEuston {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 2;
    XCTAssertFalse([line isForkBeforePosition:position], @"There should be a fork after Euston");
}

- (void)testForForkAfterEuston {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 2;
    XCTAssertTrue([line isForkAfterPosition:position], @"There should be a fork after Euston");
}

//-(void)testThatThereIsAStationAfterTheForkAfterLondonBridge {
//    LPCLinePosition *position = [[LPCLinePosition alloc] init];
//    position.mainLineIndex = 3;
//    position.branchCode = @"bank";
//    position.branchLineIndex = 2;
//    LPCFork *fork = [line forkAfterPosition:position];
//    XCTAssertTrue([line isStationAfterFork:fork], @"There should be a station after the fork when approaching from London Bridge");
//}

-(void)testThatThereIsNoStationAfterTheForkAfterEuston {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 2;
    LPCFork *fork = [line forkAfterPosition:position];
    XCTAssertFalse([line isStationAfterFork:fork], @"There should be no station after the fork when approaching from Euston");
}

- (void)testForForkBeforeMoorgateOnBankBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 3;
    position.branchCode = @"bank";
    position.branchLineIndex = 0;
    XCTAssertTrue([line isForkBeforePosition:position], @"There should be a fork before Moorgate on the Bank Branch");
}

- (void)testForForkAfterMoorgateOnBankBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 3;
    position.branchCode = @"bank";
    position.branchLineIndex = 0;
    XCTAssertFalse([line isForkAfterPosition:position], @"There should be no fork after Moorgate on the Bank Branch");
}

- (void)testForNoForkBeforeBankOnBankBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 3;
    position.branchCode = @"bank";
    position.branchLineIndex = 1;
    XCTAssertFalse([line isForkBeforePosition:position], @"There should be no fork before Bank on the Bank Branch");
}

- (void)testForNoForkBeforeEdgwareOnEdgwareBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 0;
    position.branchCode = @"edgware";
    position.branchLineIndex = 0;
    XCTAssertFalse([line isForkBeforePosition:position], @"There should be no fork before Edgware on the Edgware Branch");
}

- (void)testForForkAfterColindaleOnEdgwareBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 0;
    position.branchCode = @"edgware";
    position.branchLineIndex = 1;
    XCTAssertTrue([line isForkAfterPosition:position], @"There should be a fork after Colindale on the Edgware Branch");
}

-(void)testForForkAfterLondonBridgeOnBankBranch {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 3;
    position.branchCode = @"bank";
    position.branchLineIndex = 2;
    XCTAssertTrue([line isForkAfterPosition:position], @"There should be a fork after London Bridge on the Bank Branch");
}

-(void)testThatForkAfterLondonBridgeIsGoingLeft {
    LPCLinePosition *position = [[LPCLinePosition alloc] init];
    position.mainLineIndex = 3;
    position.branchCode = @"bank";
    position.branchLineIndex = 2;
    LPCFork *fork = [line forkAfterPosition:position];
    XCTAssertEqual(fork.direction, Left, @"The fork after London Bridge on the Bank Branch should be pointing left");
}

@end
