#import "LPCLine.h"

#import "LPCAppDelegate.h"

@implementation LPCLine

- (id)initWithLine:(NSDictionary *)line {
    NSArray *lineStations = [line valueForKey:@"stations"];
    
    NSMutableArray *leafStations = [[NSMutableArray alloc] init];
    NSMutableArray *allStations = [[NSMutableArray alloc] init];
    
    for (id station in lineStations) {
        if ([station isKindOfClass:[NSString class]]) {
            // It's an actual station
            [allStations addObject:[LPCAppDelegate stationWithNestoriaCode:station]];
        } else {
            NSDictionary *branches = station;
            
            // Get all the 'leaf' stations - i.e. the ones at the ends of the line or ends of branches
            for (id leafStation in [branches allKeys]) {
                [leafStations addObject:[LPCAppDelegate stationWithNestoriaCode:leafStation]];
            }
            
            // Get all of the stations, in full
            for (NSString *branch in branches) {
                for (id branchStation in [branches valueForKey:branch]) {
                    [allStations addObject:[LPCAppDelegate stationWithNestoriaCode:branchStation]];
                }
            }
        }
    }
    
    self.leafStations = leafStations;
    self.allStations = allStations;
    
    return self;
}

@end
