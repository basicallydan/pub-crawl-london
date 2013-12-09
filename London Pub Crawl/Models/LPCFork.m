#import "LPCFork.h"

#import "LPCLine.h"

@implementation LPCFork

NSArray *forkInitialStations;

- (id)initWithBranches:(NSDictionary *)branches forLine:(LPCLine *)line withPosition:(LPCLinePosition *)position fromPosition:(LPCLinePosition *)previousPosition {
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
            } else if ([finalStation.nestoriaCode isEqualToString:firstStation.nestoriaCode]) {
                [firstStations addObject:finalStation];
                self.direction = Left;
            } else {
                // So, it's somewhere in the middle. Let's determine direction based on where we are coming from
                if ([previousPosition beforePosition:self.linePosition]) {
                    if ([previousPosition isPartOfForkAtPosition:self.linePosition]) {
                        self.direction = Left;
                    } else {
                        self.direction = Right;
                    }
                    [firstStations addObject:firstStation];
                } else {
                    if ([previousPosition isPartOfForkAtPosition:self.linePosition]) {
                        self.direction = Right;
                    } else {
                        self.direction = Left;
                    }
                    [firstStations addObject:finalStation];
                }
            }
        }
    }
    
    forkInitialStations = [NSArray arrayWithArray:firstStations];
    self.destinationStations = [NSArray arrayWithArray:destinationStations];
    return self;
}

- (LPCStation *)firstStationForDestination:(int)destinationIndex {
    if (self.direction == Left) {
        
    }
    return (LPCStation *)forkInitialStations[destinationIndex];
}

@end
