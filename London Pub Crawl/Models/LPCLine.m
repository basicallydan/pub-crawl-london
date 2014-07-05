#import "LPCLine.h"

#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCLine

NSDictionary *stationPointers;

- (id)initWithLine:(NSDictionary *)line andStations:(NSDictionary *)stations {
    self.name = [line valueForKey:@"name"];
    
    NSArray *lineStations = [line valueForKey:@"stations"];
    
    NSMutableArray *leafStations = [[NSMutableArray alloc] init];
    NSMutableArray *allStations = [[NSMutableArray alloc] init];
    
    // stationPositions stores the same structure as the original dictionary but rather than objects as
    // leaf nodes, it stores integers pointing to objects in allStations. I.e., it describres the
    // structure of the line
    NSMutableDictionary *stationPositions = [[NSMutableDictionary alloc] init];
    
    // stationArrayPointers refers to where in allStations a station is stored
    NSMutableDictionary *stationArrayPointers = [[NSMutableDictionary alloc] init];
    
    int s;
    for (s = 0; s < [lineStations count]; s++) {
        id station = lineStations[s];
        [stationPositions setValue:[[NSMutableDictionary alloc] init] forKey:[NSString stringWithFormat:@"%d", s]];
        if ([station isKindOfClass:[NSString class]]) {
            // It's an actual station
            LPCLinePosition *position = [[LPCLinePosition alloc] init];
            position.mainLineIndex = s;
            
            NSDictionary *stationDictionary = [stations objectForKey:station];
            LPCStation *st = [[LPCStation alloc] initWithStation:stationDictionary];
            st.linePosition = position;
            
            if (![stationArrayPointers valueForKey:st.nestoriaCode]) {
                [allStations addObject:st];
                [stationArrayPointers setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKey:st.nestoriaCode];
                [stationPositions setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKeyPath:[position description]];
            } else {
                int existingStationArrayPointer = (int)[[stationArrayPointers valueForKey:st.nestoriaCode] integerValue];
                NSLog(@"%@ is in there more than once, using station at position %d!", st.nestoriaCode, existingStationArrayPointer);
                [stationPositions setValue:[NSNumber numberWithInteger:existingStationArrayPointer] forKeyPath:[position description]];
            }
            
        } else {
            NSDictionary *branches = station;
            // Get all the 'leaf' stations - i.e. the ones at the ends of the line or ends of branches
            for (id leafStation in [branches allKeys]) {
                if ([leafStation isEqualToString:@"_parent"]) {
                    // WTF?
                    [stationPositions setValue:[branches valueForKey:leafStation] forKeyPath:[NSString stringWithFormat:@"%d.%@", s, leafStation]];
                } else {
                    [stationPositions setValue:[[NSMutableDictionary alloc] init] forKeyPath:[NSString stringWithFormat:@"%d.%@", s, leafStation]];
                    [leafStations addObject:leafStation];
                }
            }
            
            // Get all of the stations, in full
            for (NSString *branch in branches) {
                NSArray *branchStations = [branches valueForKey:branch];
                int bs;
                if ([branch isEqualToString:@"_parent"]) {
                    
                } else {
                    for (bs = 0; bs < [branchStations count]; bs++) {
                        LPCLinePosition *position = [[LPCLinePosition alloc] init];
                        NSString *branchStation = branchStations[bs];
                        
                        position.mainLineIndex = s;
                        position.branchCode = branch;
                        position.branchLineIndex = bs;
                        
                        NSDictionary *stationDictionary = [stations objectForKey:branchStation];
                        LPCStation *st = [[LPCStation alloc] initWithStation:stationDictionary];
                        st.linePosition = position;
                        
                        if (![stationArrayPointers valueForKey:st.nestoriaCode]) {
                            [allStations addObject:st];
                            [stationArrayPointers setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKey:st.nestoriaCode];
                            [stationPositions setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKeyPath:[position description]];
                        } else {
                            int existingStationArrayPointer = (int)[[stationArrayPointers valueForKey:st.nestoriaCode] integerValue];
                            NSLog(@"%@ is in there more than once, using station at position %d!", st.nestoriaCode, existingStationArrayPointer);
                            [stationPositions setValue:[NSNumber numberWithInteger:existingStationArrayPointer] forKeyPath:[position description]];
                        }
                    }
                }
            }
        }
    }
    
    self.leafStations = [NSArray arrayWithArray:leafStations];
    self.allStations = [NSArray arrayWithArray:allStations];
    self.stationPositions = [NSDictionary dictionaryWithDictionary:stationPositions];
    stationPointers = [NSDictionary dictionaryWithDictionary:stationArrayPointers];
    
    // Then some visual stuff
    self.lineColour = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    self.bottomOfLineDirection = [line valueForKey:@"bottom-direction"]; // Direction we're heading if we're going twd end of the array of stations
    self.topOfLineDirection = [line valueForKey:@"top-direction"]; // Direction we're heading if we're going twd start of the array of stations
    self.iapProductIdentifier = [line valueForKey:@"iap-product-identifier"];
    
    return self;
}

- (BOOL)isForkBeforePosition:(LPCLinePosition *)position {
    LPCLinePosition *previousPosition;
    
    previousPosition = [position previousPossiblePosition];
    
    if ([self isStationAtPosition:previousPosition]) {
        return NO;
    } else if ([self isForkAtPosition:previousPosition] && !position.branchCode) {
        return YES;
    }
    
    // So it's neither a fork nor a station. Are we on a branch?
    if (!position.branchCode) {
        return NO;
    }
    
    // Since we're on a branch, does it end with this position?
    if ([self branchEndsWithPosition:position]) {
        return NO;
    }
    
    // Let's go to the fork then
    previousPosition = [position positionOfParentFork];
    
    return [self isForkAtPosition:previousPosition];
}

- (LPCStation *)stationBeforePosition:(LPCLinePosition *)position {
    LPCLinePosition *previousPosition = [position previousPossiblePosition];
    if (!previousPosition) {
        return nil;
    }
    id stationIndex = [self.stationPositions valueForKeyPath:[previousPosition description]];
    if (!stationIndex || ![stationIndex isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    return [self stationAtIndex:[stationIndex integerValue]];
}

- (LPCFork *)forkBeforePosition:(LPCLinePosition *)position {
    LPCLinePosition *previousPosition = [position previousPossiblePosition];
    NSDictionary *possibleBranches = [self.stationPositions valueForKeyPath:[previousPosition description]];
    LPCFork *fork = [[LPCFork alloc] initWithBranches:possibleBranches forLine:self withPosition:previousPosition fromPosition:position];
    fork.linePosition = previousPosition;
    return fork;
}

- (BOOL)isForkAfterPosition:(LPCLinePosition *)position {
    LPCLinePosition *nextPosition;
    
    nextPosition = [position nextPossiblePosition];
    
    if ([self isStationAtPosition:nextPosition]) {
        return NO;
    } else if ([self isForkAtPosition:nextPosition] && !position.branchCode) {
        return YES;
    }
    
    // So it's neither a fork nor a station. Are we on a branch?
    if (!position.branchCode) {
        return NO;
    }
    
    // Since we're on a branch, does it end with this position?
    if ([self branchEndsWithPosition:position]) {
        return NO;
    }
    
    // Let's go to the fork then
    nextPosition = [position positionOfParentFork];
    
    return [self isForkAtPosition:nextPosition];
}

- (LPCStation *)stationAfterPosition:(LPCLinePosition *)position {
    if (![self isStationAfterPosition:position]) {
        return nil;
    }
    
    LPCLinePosition *nextPosition = [position nextPossiblePosition];
    id stationPointer = [self.stationPositions valueForKeyPath:[nextPosition description]];
    if (![stationPointer isKindOfClass:[NSNumber class]]) {
        if (position.branchCode) {
            nextPosition = [[position positionOfParentFork] nextPossiblePosition];
            stationPointer = [self.stationPositions valueForKeyPath:[nextPosition description]];
        } else {
            return nil;
        }
    }
    
    if (![stationPointer isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    return [self stationAtIndex:[stationPointer integerValue]];
}

- (LPCFork *)forkAfterPosition:(LPCLinePosition *)position {
    LPCLinePosition *forkPosition = [position nextPossiblePosition];
    NSDictionary *possibleBranches = [self.stationPositions valueForKeyPath:[forkPosition description]];
    if (!possibleBranches) {
        forkPosition = [position positionOfParentFork];
        possibleBranches = [self.stationPositions valueForKeyPath:[forkPosition description]];
    }
    LPCFork *fork = [[LPCFork alloc] initWithBranches:possibleBranches forLine:self withPosition:forkPosition fromPosition:position];
    return fork;
}



- (BOOL)isStationAfterFork:(LPCFork *)fork {
    BOOL stationAfterPosition = [self isStationAfterPosition:fork.linePosition];
    
    return fork.direction == Left && stationAfterPosition;
}

- (LPCStation *)stationWithCode:(NSString *)nestoriaCode {
    NSUInteger stationIndex = [[stationPointers valueForKey:nestoriaCode] unsignedIntegerValue];
    return [self stationAtIndex:stationIndex];
}

#pragma mark - Private Methods

- (BOOL)isStationAtPosition:(LPCLinePosition *)position {
    id stationIndex = [self.stationPositions valueForKeyPath:[position description]];
    return stationIndex != nil && [stationIndex isKindOfClass:[NSNumber class]];
}

- (BOOL)isForkAtPosition:(LPCLinePosition *)position {
    id stationIndex = [self.stationPositions valueForKeyPath:[position description]];
    return stationIndex != nil && [stationIndex isKindOfClass:[NSDictionary class]];
}

- (LPCStation *)stationAtIndex:(NSUInteger)index {
    LPCStation *station = [self.allStations objectAtIndex:index];
    
    if ([self isStationAfterPosition:station.linePosition] == NO && [self isForkAfterPosition:station.linePosition] == NO) {
        // If there's nowt afterwards it should be a terminating station
        station.firstStation = NO;
        station.terminatingStation = YES;
    } else if ([self isStationBeforePosition:station.linePosition] == NO && [self isForkBeforePosition:station.linePosition] == NO) {
        // If there's nowt before it's a first station
        station.firstStation = YES;
        station.terminatingStation = NO;
    }
    
    return station;
}

- (BOOL)isStationBeforePosition:(LPCLinePosition *)position {
    LPCLinePosition *previousPosition;
    
    previousPosition = [position previousPossiblePosition];
    
    if ([self isStationAtPosition:previousPosition]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isStationAfterPosition:(LPCLinePosition *)position {
    LPCLinePosition *nextPosition;
    
    nextPosition = [position nextPossiblePosition];
    
    if ([self isStationAtPosition:nextPosition]) {
        return YES;
    } else {
        return NO;
    }
}

- (int)countOfStationsOnBranchOfStationPosition:(LPCLinePosition *)position {
    NSArray *stations = [self.stationPositions valueForKeyPath:[NSString stringWithFormat:@"%d.%@", position.mainLineIndex, position.branchCode]];
    return (int)[stations count];
}

- (BOOL)branchEndsWithPosition:(LPCLinePosition *)position {
    if (!position.branchCode) {
        [NSException raise:@"Position is not on a branch" format:@"%@ is not a branch position", position];
    }
    NSDictionary *stationsOnBranch = [self.stationPositions valueForKeyPath:[NSString stringWithFormat:@"%d.%@", position.mainLineIndex, position.branchCode]];
    int count = (int)[stationsOnBranch count];
    NSString *stringLast = [NSString stringWithFormat:@"%d", (count - 1)];
    
    LPCStation *firstStation = [self.allStations objectAtIndex:[[stationsOnBranch valueForKey:@"0"] integerValue]];
    LPCStation *lastStation = [self.allStations objectAtIndex:[[stationsOnBranch valueForKey:stringLast] integerValue]];
    
    if ([firstStation.nestoriaCode isEqualToString:position.branchCode]) {
        return position.branchLineIndex == 0;
    } else if ([lastStation.nestoriaCode isEqualToString:position.branchCode]) {
        return [stationsOnBranch count] - 1 == position.branchLineIndex;
    }
    return NO;
}

@end
