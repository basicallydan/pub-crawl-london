#import "LPCFork.h"

#import "LPCLine.h"

@implementation LPCFork

NSArray *forkInitialStations;

- (id)initWithFork:(NSDictionary *)fork forLine:(LPCLine *)line {
    NSMutableArray *destinationStations = [[NSMutableArray alloc] init];
    NSMutableArray *firstStations = [[NSMutableArray alloc] init];
    for (NSString *forkDestinationStation in fork) {
        if ([forkDestinationStation isEqualToString:@"_parent"]) {
            if ([fork valueForKey:forkDestinationStation] == 0) {
                // We're going back up
                [firstStations addObject:[line stationBeforePosition:self.linePosition]];
                [destinationStations addObject:@"_up"];
            } else {
                // We're going down
                [firstStations addObject:[line stationAfterPosition:self.linePosition]];
                [destinationStations addObject:@"_up"];
            }
        } else {
            [destinationStations addObject:[line stationWithCode:forkDestinationStation]];
            NSDictionary *branchStations = [fork valueForKey:forkDestinationStation];
            NSArray *branchStationKeys = [[branchStations allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
            
            long finalBranchStationIndex = [[branchStations valueForKey:[branchStationKeys lastObject]] integerValue];
            long firstBranchStationIndex = [[branchStations valueForKey:[branchStationKeys firstObject]] integerValue];
            
            LPCStation *finalStation = [line.allStations objectAtIndex:finalBranchStationIndex];
            LPCStation *firstStation = [line.allStations objectAtIndex:firstBranchStationIndex];
            if ([finalStation.nestoriaCode isEqualToString:forkDestinationStation]) {
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

- (id)initWithFork:(NSDictionary *)fork forLine:(LPCLine *)line withPosition:(LPCLinePosition *)position {
    self.linePosition = position;
    NSMutableArray *destinationStations = [[NSMutableArray alloc] init];
    NSMutableArray *firstStations = [[NSMutableArray alloc] init];
    for (NSString *forkDestinationStation in fork) {
        if ([forkDestinationStation isEqualToString:@"_parent"]) {
            int forkDirection = [[fork objectForKey:forkDestinationStation] integerValue];
            if (forkDirection == 0) {
                // We're going back up
                [firstStations addObject:[line stationBeforePosition:self.linePosition]];
                [destinationStations addObject:@"_up"];
            } else {
                // We're going down
                [firstStations addObject:[line stationAfterPosition:self.linePosition]];
                [destinationStations addObject:@"_up"];
            }
        } else {
            [destinationStations addObject:[line stationWithCode:forkDestinationStation]];
            NSDictionary *branchStations = [fork valueForKey:forkDestinationStation];
            NSArray *branchStationKeys = [[branchStations allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
            
            long finalBranchStationIndex = [[branchStations valueForKey:[branchStationKeys lastObject]] integerValue];
            long firstBranchStationIndex = [[branchStations valueForKey:[branchStationKeys firstObject]] integerValue];
            
            LPCStation *finalStation = [line.allStations objectAtIndex:finalBranchStationIndex];
            LPCStation *firstStation = [line.allStations objectAtIndex:firstBranchStationIndex];
            if ([finalStation.nestoriaCode isEqualToString:forkDestinationStation]) {
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
