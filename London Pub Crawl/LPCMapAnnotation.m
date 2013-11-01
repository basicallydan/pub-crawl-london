#import "LPCMapAnnotation.h"

@implementation LPCMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andType:(NSInteger)type {
    self.coordinate = coordinate;
    self.type = type;
    
    return self;
}

@end
