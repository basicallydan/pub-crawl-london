#import "LPCLine.h"

@implementation LPCLine

- (id)initWithLine:(NSDictionary *)line {
    NSArray *lineStations = [line valueForKey:@"stations"];
    
    NSMutableArray *leafStations = [[NSMutableArray alloc] init];
    
    for (id station in lineStations) {
        if ([station isKindOfClass:[NSString class]]) {
            // It's an actual station
        } else {
            NSDictionary *branches = station;
            [leafStations addObjectsFromArray:[branches allKeys]];
        }
    }
    
    self.leafStations = leafStations;
    
    return self;
}

@end
