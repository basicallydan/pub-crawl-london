#import "LPCLine.h"

#import "LPCAppDelegate.h"
#import <UIColor-HexString/UIColor+HexString.h>

@implementation LPCLine

NSDictionary *stationPointers;

- (id)initWithLine:(NSDictionary *)line {
    NSArray *lineStations = [line valueForKey:@"stations"];
    
    NSMutableArray *leafStations = [[NSMutableArray alloc] init];
    NSMutableArray *allStations = [[NSMutableArray alloc] init];
    
    // todo: NOOOO! MUTABLE YOU DUMBASS
    NSMutableDictionary *stationPositions = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *stationArrayPointers = [[NSMutableDictionary alloc] init];
    
    for (int s = 0; s < [lineStations count]; s++) {
        id station = lineStations[s];
        LPCLinePosition *pointer = [[LPCLinePosition alloc] init];
        if ([station isKindOfClass:[NSString class]]) {
            // It's an actual station
            LPCStation *st = [LPCAppDelegate stationWithNestoriaCode:station];
            
            pointer.mainLineIndex = s;
            
            st.linePosition = pointer;
            
            [allStations addObject:st];
            [stationArrayPointers setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKey:st.nestoriaCode];
            
            if ([stationPositions valueForKey:st.nestoriaCode]) {
                NSLog(@"%@ is in there more than once!", st.nestoriaCode);
            }
            
            [stationPositions setValue:pointer forKey:st.nestoriaCode];
        } else {
            NSDictionary *branches = station;
            
            // Get all the 'leaf' stations - i.e. the ones at the ends of the line or ends of branches
            for (id leafStation in [branches allKeys]) {
                [leafStations addObject:[LPCAppDelegate stationWithNestoriaCode:leafStation]];
            }
            
            // Get all of the stations, in full
            for (NSString *branch in branches) {
                NSArray *branchStations = [branches valueForKey:branch];
                for (int bs = 0; bs < [branchStations count]; bs++) {
                    id branchStation = branchStations[bs];
                    
                    LPCStation *st = [LPCAppDelegate stationWithNestoriaCode:branchStation];
                    
                    pointer.mainLineIndex = s;
                    pointer.branchCode = branch;
                    pointer.branchLineIndex = bs;
                    
                    st.linePosition = pointer;
                    
                    [allStations addObject:st];
                    [stationArrayPointers setValue:[NSNumber numberWithInteger:[allStations count] - 1] forKey:st.nestoriaCode];
                    
                    if ([stationPositions valueForKey:st.nestoriaCode]) {
                        NSLog(@"%@ is in there more than once!", st.nestoriaCode);
                    }
                    
                    [stationPositions setValue:pointer forKey:st.nestoriaCode];
                }
            }
        }
    }
    
    self.leafStations = [NSArray arrayWithArray:leafStations];
    self.allStations = [NSArray arrayWithArray:allStations];
    self.stationPositions = [NSDictionary dictionaryWithDictionary:stationPointers];
    stationPointers = [NSDictionary dictionaryWithDictionary:stationArrayPointers];
    
    // Then some visual stuff
    self.lineColour = [UIColor colorWithHexString:[line valueForKey:@"background-color"]];
    self.bottomOfLineDirection = [line valueForKey:@"bottom-direction"]; // Direction we're heading if we're going twd end of the array of stations
    self.topOfLineDirection = [line valueForKey:@"top-direction"]; // Direction we're heading if we're going twd start of the array of stations
    
    return self;
}

- (LPCStation *)stationAtPosition:(LPCLinePosition *)position {
    if (position.branchCode) {
        // This one is on a branch
    } else {
        // This one is not on a branch
    }
    // TODO: This is actually meant to work
    return [[LPCStation alloc] init];
}

@end
