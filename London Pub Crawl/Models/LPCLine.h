#import <Foundation/Foundation.h>
#import "LPCFork.h"
#import "LPCLinePosition.h"
#import "LPCStation.h"

@interface LPCLine : NSObject

@property (strong, nonatomic) NSArray *leafStations;
@property (strong, nonatomic) NSArray *allStations;
@property (strong, nonatomic) NSDictionary *stationPositions;
@property (strong, nonatomic) UIColor *lineColour;
@property (strong, nonatomic) NSString *topOfLineDirection;
@property (strong, nonatomic) NSString *bottomOfLineDirection;

- (id)initWithLine:(NSDictionary *)line;
//- (LPCStation *)stationAtPosition:(LPCLinePosition *)position;
- (BOOL)isForkAfterPosition:(LPCLinePosition *)position;
- (LPCStation *)stationAfterPosition:(LPCLinePosition *)position;
- (LPCFork *)forkAfterPosition:(LPCLinePosition *)position;
- (LPCStation *)stationWithCode:(NSString *)nestoriaCode;

@end