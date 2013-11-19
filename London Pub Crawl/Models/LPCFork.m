#import "LPCFork.h"

#import "LPCLine.h"

@implementation LPCFork

NSArray *forkInitialStations;

- (id)initWithFork:(NSDictionary *)fork forLine:(LPCLine *)line {
    NSMutableArray *destinationStations = [[NSMutableArray alloc] init];
    NSMutableArray *firstStations = [[NSMutableArray alloc] init];
    for (NSString *forkDestinationStation in fork) {
        [destinationStations addObject:[line stationWithCode:forkDestinationStation]];
        NSDictionary *branchStations = [fork valueForKey:forkDestinationStation];
        NSArray *branchStationKeys = [[branchStations allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        int finalBranchStationIndex = [[branchStations valueForKey:[branchStationKeys lastObject]] integerValue];
        int firstBranchStationIndex = [[branchStations valueForKey:[branchStationKeys firstObject]] integerValue];
        
        LPCStation *finalStation = [line.allStations objectAtIndex:finalBranchStationIndex];
        LPCStation *firstStation = [line.allStations objectAtIndex:firstBranchStationIndex];
        if ([finalStation.nestoriaCode isEqualToString:forkDestinationStation]) {
            [firstStations addObject:firstStation];
        } else {
            [firstStations addObject:finalStation];
        }
    }
    
    forkInitialStations = [NSArray arrayWithArray:firstStations];
    self.destinationStations = [NSArray arrayWithArray:destinationStations];
    return self;
}

- (LPCStation *)firstStationForDestination:(int)destinationIndex {
    return (LPCStation *)forkInitialStations[destinationIndex];
}

@end
