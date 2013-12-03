#import "LPCLine.h"

#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCLine

NSDictionary *stationPointers;

- (id)initWithLine:(NSDictionary *)line andStations:(NSDictionary *)stations {
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
                int existingStationArrayPointer = [[stationArrayPointers valueForKey:st.nestoriaCode] integerValue];
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
                            int existingStationArrayPointer = [[stationArrayPointers valueForKey:st.nestoriaCode] integerValue];
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
    
    return self;
}

- (BOOL)isForkBeforePosition:(LPCLinePosition *)position {
    
    LPCLinePosition *previousPosition;
    
    if (position.branchCode) {
        // This position is on a branch
        previousPosition = [position positionOfParentFork];
    } else {
        previousPosition = [position previousPossiblePosition];
    }
    
    id stationIndex = [self.stationPositions valueForKeyPath:[previousPosition description]];
    
    // So, if it's a dictionary type, then it's a branch
    if (stationIndex != nil && [stationIndex isKindOfClass:[NSDictionary class]]) {
//        LPCFork *parentFork = [[LPCFork alloc] initWithBranches:[self.stationPositions valueForKeyPath:[previousPosition description]] forLine:self withPosition:previousPosition fromPosition:position];
        if ([position afterPosition:previousPosition] && position.branchLineIndex == 0) {
            return YES;
        } else if ([self branchEndsWithPosition:position]) {
            return YES;
        } else {
            return NO;
        }
    }
    
    if ([stationIndex isKindOfClass:[NSNumber class]] || stationIndex == nil) {
        return NO;
    } else {
        return YES;
    }
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
    return self.allStations[[stationIndex integerValue]];
}

- (LPCFork *)forkBeforePosition:(LPCLinePosition *)position {
    LPCLinePosition *previousPosition = [position previousPossiblePosition];
    NSDictionary *possibleBranches = [self.stationPositions valueForKeyPath:[previousPosition description]];
    LPCFork *fork = [[LPCFork alloc] initWithBranches:possibleBranches forLine:self withPosition:previousPosition fromPosition:position];
    fork.linePosition = previousPosition;
    return fork;
}

- (BOOL)isForkAfterPosition:(LPCLinePosition *)position {
    id stationIndex = [self.stationPositions valueForKeyPath:[[position nextPossiblePosition] description]];
    
    if (stationIndex == nil && position.branchCode) {
        LPCLinePosition *parentForkPosition = [position positionOfParentFork];
        LPCFork *parentFork = [[LPCFork alloc] initWithBranches:[self.stationPositions valueForKeyPath:[parentForkPosition description]] forLine:self withPosition:parentForkPosition fromPosition:position];
        if (parentFork.direction == Left && position.branchLineIndex > 0) {
            return YES;
        }
//        stationIndex = [self.stationPositions valueForKeyPath:[[ nextPossiblePosition] description]];
    }
    
    if ([stationIndex isKindOfClass:[NSNumber class]] || stationIndex == nil) {
        return NO;
    } else {
        return YES;
    }
}

- (LPCStation *)stationAfterPosition:(LPCLinePosition *)position {
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
    
    return self.allStations[[stationPointer integerValue]];
}

- (LPCFork *)forkAfterPosition:(LPCLinePosition *)position {
    LPCLinePosition *forkPosition = [position nextPossiblePosition];
    NSDictionary *possibleBranches = [self.stationPositions valueForKeyPath:[forkPosition description]];
    if (!possibleBranches) {
        possibleBranches = [self.stationPositions valueForKeyPath:[[position positionOfParentFork] description]];
    }
    LPCFork *fork = [[LPCFork alloc] initWithBranches:possibleBranches forLine:self withPosition:forkPosition fromPosition:position];
    return fork;
}

- (LPCStation *)stationWithCode:(NSString *)nestoriaCode {
    return [self.allStations objectAtIndex:[[stationPointers valueForKey:nestoriaCode] integerValue]];
}

- (int)countOfStationsOnBranchOfStationPosition:(LPCLinePosition *)position {
    NSArray *stations = [self.stationPositions valueForKeyPath:[NSString stringWithFormat:@"%d.%@", position.mainLineIndex, position.branchCode]];
    return [stations count];
}

- (BOOL)branchEndsWithPosition:(LPCLinePosition *)position {
    if (!position.branchCode) {
        [NSException raise:@"Position is not on a branch" format:@"%@ is not a branch position", position];
    }
    return [self countOfStationsOnBranchOfStationPosition:position] - 1 == position.branchLineIndex;
}

@end
