#import "LPCLine.h"

@implementation LPCLine

- (id)initWithLine:(NSDictionary *)line {
    NSArray *lineStations = [line valueForKey:@"stations"];
    
    NSMutableArray *leafStations = [[NSMutableArray alloc] init];
    NSMutableArray *allStations = [[NSMutableArray alloc] init];
    
    for (id station in lineStations) {
        if ([station isKindOfClass:[NSString class]]) {
            // It's an actual station
            [allStations addObject:(NSString *)station];
        } else {
            NSDictionary *branches = station;
            [leafStations addObjectsFromArray:[branches allKeys]];
            for (NSString *branch in branches) {
                [allStations addObjectsFromArray:[branches valueForKey:branch]];
            }
        }
    }
    
    self.leafStations = leafStations;
    self.allStations = allStations;
    
    return self;
}

@end
