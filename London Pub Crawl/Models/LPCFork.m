#import "LPCFork.h"

#import "LPCLine.h"

@implementation LPCFork

NSArray *forkInitialStations;

- (id)initWithBranches:(NSDictionary *)branches forLine:(LPCLine *)line withPosition:(LPCLinePosition *)position {
    self.linePosition = position;
    NSMutableArray *destinationStations = [[NSMutableArray alloc] init];
    NSMutableArray *firstStations = [[NSMutableArray alloc] init];
    // Go through each of our options
    for (NSString *branchDestination in branches) {
        if ([branchDestination isEqualToString:@"_parent"]) {
            // This option is to stay on/return to the main line
            if ([[branches valueForKeyPath:@"_parent.direction"] isEqualToString:@"top"]) {
                // We're going back up
                LPCStation *previousStationBeforeFork = [line stationBeforePosition:self.linePosition];
                if (previousStationBeforeFork) {
                    [firstStations addObject:previousStationBeforeFork];
                    [destinationStations addObject:@"top"];
                }
            } else {
                // We're going down
                [firstStations addObject:[line stationAfterPosition:self.linePosition]];
                [destinationStations addObject:@"bottom"];
            }
        } else {
            [destinationStations addObject:[line stationWithCode:branchDestination]];
            NSDictionary *branchStations = [branches valueForKey:branchDestination];
            NSArray *branchStationKeys = [[branchStations allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
            
            long finalBranchStationIndex = [[branchStations valueForKey:[branchStationKeys lastObject]] integerValue];
            long firstBranchStationIndex = [[branchStations valueForKey:[branchStationKeys firstObject]] integerValue];
            
            LPCStation *finalStation = [line.allStations objectAtIndex:finalBranchStationIndex];
            LPCStation *firstStation = [line.allStations objectAtIndex:firstBranchStationIndex];
            if ([finalStation.nestoriaCode isEqualToString:branchDestination] && [branchStationKeys count] > 1) {
                [firstStations addObject:firstStation];
                self.direction = Right;
            } else {
                [firstStations addObject:finalStation];
                self.direction = Left;
            }
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
