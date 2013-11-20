#import "LPCLine.h"

#import "LPCAppDelegate.h"
#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCLine

NSDictionary *stationPointers;

- (id)initWithLine:(NSDictionary *)line {
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
            
            LPCStation *st = [LPCAppDelegate stationWithNestoriaCode:station atPosition:position];
            
            [allStations addObject:st];
            [stationArrayPointers setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKey:st.nestoriaCode];
            [stationPositions setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKeyPath:[position description]];
            
            if ([stationPositions valueForKey:st.nestoriaCode]) {
                NSLog(@"%@ is in there more than once!", st.nestoriaCode);
            }
            
        } else {
            NSDictionary *branches = station;
            
            // Get all the 'leaf' stations - i.e. the ones at the ends of the line or ends of branches
            for (id leafStation in [branches allKeys]) {
                [stationPositions setValue:[[NSMutableDictionary alloc] init] forKeyPath:[NSString stringWithFormat:@"%d.%@", s, leafStation]];
                [leafStations addObject:leafStation];
            }
            
            // Get all of the stations, in full
            for (NSString *branch in branches) {
                NSArray *branchStations = [branches valueForKey:branch];
                int bs;
                for (bs = 0; bs < [branchStations count]; bs++) {
                    LPCLinePosition *position = [[LPCLinePosition alloc] init];
                    NSString *branchStation = branchStations[bs];
                    
                    position.mainLineIndex = s;
                    position.branchCode = branch;
                    position.branchLineIndex = bs;
                    
                    LPCStation *st = [LPCAppDelegate stationWithNestoriaCode:branchStation atPosition:position];
                    
                    [allStations addObject:st];
                    [stationArrayPointers setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKey:st.nestoriaCode];
                    [stationPositions setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKeyPath:[position description]];
                    
                    if ([stationPositions valueForKey:st.nestoriaCode]) {
                        NSLog(@"%@ is in there more than once!", st.nestoriaCode);
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
    LPCLinePosition *previousPosition = [position previousPossiblePosition];
    
    if (!previousPosition) {
        return NO;
    }
    
    id stationIndex = [self.stationPositions valueForKeyPath:[previousPosition description]];
    if ([stationIndex isKindOfClass:[NSNumber class]]) {
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
    int stationIndex = [[self.stationPositions valueForKeyPath:[previousPosition description]] integerValue];
    return self.allStations[stationIndex];
}

- (LPCFork *)forkBeforePosition:(LPCLinePosition *)position {
    LPCLinePosition *previousPosition = [position previousPossiblePosition];
    NSDictionary *possibleBranches = [self.stationPositions valueForKeyPath:[previousPosition description]];
    LPCFork *fork = [[LPCFork alloc] initWithFork:possibleBranches forLine:self];
    fork.linePosition = previousPosition;
    return fork;
}

- (BOOL)isForkAfterPosition:(LPCLinePosition *)position {
    id stationIndex = [self.stationPositions valueForKeyPath:[[position nextPossiblePosition] description]];
    if ([stationIndex isKindOfClass:[NSNumber class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (LPCStation *)stationAfterPosition:(LPCLinePosition *)position {
    int stationIndex = [[self.stationPositions valueForKeyPath:[[position nextPossiblePosition] description]] integerValue];
    return self.allStations[stationIndex];
}

- (LPCFork *)forkAfterPosition:(LPCLinePosition *)position {
    NSDictionary *possibleBranches = [self.stationPositions valueForKeyPath:[[position nextPossiblePosition] description]];
    if (!possibleBranches) {
        possibleBranches = [self.stationPositions valueForKeyPath:[[position positionOfParentFork] description]];
    }
    LPCFork *fork = [[LPCFork alloc] initWithFork:possibleBranches forLine:self];
    return fork;
}

- (LPCStation *)stationWithCode:(NSString *)nestoriaCode {
    return [self.allStations objectAtIndex:[[stationPointers valueForKey:nestoriaCode] integerValue]];
}

@end
