#import <Foundation/Foundation.h>
#import "LPCStation.h"
#import "LPCLinePosition.h"

@class LPCLine; // Import in the .m file

@interface LPCFork : NSObject

@property (strong, nonatomic) NSArray *destinationStations;

- (id)initWithFork:(NSDictionary *)fork forLine:(LPCLine *)line;

- (LPCStation *)firstStationForDestination:(int)destinationIndex;

@end
